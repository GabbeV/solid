# core/async.ts synchronous error/status paths, and effect.ts's shared status
# notifier. Pending/transaction/boundary routing remains an explicit frontier.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./write.bend as W
import ./heap.bend as H

def unwrapStatusError(error: R.Value) -> R.Value:
  match error:
    case R.StatusFailure{identity, source, cause}:
      cause
    case other:
      other

# Construct a NEW wrapper (effect-phase catch wraps even an existing wrapper).
def statusError(+w: R.World, source: Nat, cause: R.Value) -> B.Bundle<R.World, R.Value>:
  +serial = Nat.add(1n, R.World.errorSerial(w))
  B.Bundle{R.World.with_errorSerial(w, serial), R.StatusFailure{serial, source, cause}}

def wrapped(+w: R.World, source: Nat, error: R.Value) -> B.Bundle<R.World, R.Value>:
  match error:
    case R.StatusFailure{identity, owner, cause}:
      B.Bundle{w, R.StatusFailure{identity, owner, cause}}
    case e:
      statusError(w, source, e)

def haltReactivity(+w: R.World, +cause: R.Value) -> R.World:
  B.choose(~R.World, R.World.halted(w), _ => w,
    _ => B.report(R.World.with_halted(w, True{}), 0, B.choose(~R.Slot, B.equal(cause, R.Undefined{}), _ => R.Empty{}, _ => R.Present{cause})))

# notifyEffectStatus's error arm. No boundary hook is installed in this profile.
def notifyEffectStatus(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_ERROR()),
    _ => B.choose(~R.World, W.is_user(R.Node.kind(n)),
      _ => W.enqueue(B.store_node(w, id, R.Node.with_modified(n, True{})), id),
      _ =>
        +error = R.NodeExtension.error(B.extension(w, id))
        R.World.with_fault(haltReactivity(w, unwrapStatusError(error)), R.CallbackThrown{error})),
    _ => B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_PENDING()),
      _ => R.World.with_fault(w, R.Unsupported{9n}), _ => w))

# async.ts:clearStatus drops the node-owned source set and truthy error,
# preserves UNINITIALIZED unless requested, and calls the shared effect notifier.
# Its callers for actual pending flights/settlements remain unfinished.
def clearStatus(+w: R.World, +id: Nat, clearUninitialized: Bool) -> R.World:
  +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ => B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), R.NoSources{})), _ => w)
  +w = B.choose(~R.World, B.truth(B.selected(R.NodeExtension.blocked(B.extension(w, id)), R.Undefined{})),
    _ => B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})), _ => w)
  +n = B.node(w, id)
  +w = B.store_node(w, id, R.Node.with_status(n, B.choose(~U32, clearUninitialized, _ => 0, _ => U32.and(R.Node.status(n), K.STATUS_UNINITIALIZED()))))
  +w = B.choose(~R.World, B.truth(R.NodeExtension.error(B.extension(w, id))),
    _ => B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), R.Null{})), _ => w)
  B.choose(~R.World, B.effect(R.Node.kind(B.node(w, id))), _ => notifyEffectStatus(w, id), _ => w)

def hasSources(sources: R.SourceSet) -> Bool:
  match sources:
    case R.NoSources{}:
      False{}
    case R.Sources{items}:
      True{}

type Task is Data:
  Notify{id: Nat, error: R.Value, block: Bool}
  Propagate{edge: Nat, error: R.Value, block: Bool}
  PropagateNext{edge: Nat, error: R.Value, block: Bool}
  SettleVisit{id: Nat, error: R.Value}
  SettleWalk{edge: Nat, error: R.Value}
  SettleNext{edge: Nat, error: R.Value}
  SettleEnd{}

type Machine is Data:
  Machine{world: R.World, tasks: List<&2, Task>, visited: List<&2, Nat>, scheduled: Bool}

def dispatch(+w: R.World, tasks: List<&2, Task>, +visited: List<&2, Nat>, +scheduled: Bool) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], visited, scheduled}
    case Notify{+id, +error, +block} <> +rest:
      +pair = wrapped(w, id, error)
      +w = B.first(R.World, R.Value, pair)
      +error = B.second(R.World, R.Value, pair)
      +w = B.choose(~R.World, block, _ => w,
        _ =>
          +w = E.ext(w, id)
          +w = B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), R.NoSources{}))
          +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), K.STATUS_ERROR()))
          B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), error)))
      B.choose(~Machine, B.effect(R.Node.kind(B.node(w, id))),
        _ => B.choose(~Machine, block, _ => Machine{R.World.with_fault(w, R.Unsupported{9n}), [], visited, scheduled},
          _ => Machine{notifyEffectStatus(w, id), rest, visited, scheduled}),
        _ => Machine{w, Propagate{R.Node.subs(B.node(w, id)), error, block} <> rest, visited, scheduled})
    case Propagate{+edge, +error, +block} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, visited, scheduled},
        _ =>
          +id = R.Link.sub(B.link(w, edge))
          +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
          +sub = B.node(w, id)
          +next = {PropagateNext{edge, error, block} <> rest : List<&2, Task>}
          B.choose(~Machine, B.has(R.Node.config(sub), B.set(K.CONFIG_REDERIVE(), K.CONFIG_VERDICT())),
            _ => Machine{B.schedule(H.enqueueSub(w, id)), next, visited, scheduled},
            _ => B.choose(~Machine, Bool.or(Bool.not(B.equal(R.NodeExtension.error(B.extension(w, id)), error)),
                hasSources(R.NodeExtension.pendingSources(B.extension(w, id)))),
              _ =>
                w = B.choose(~R.World, block, _ => w, _ => W.queuePendingNode(w, id))
                Machine{w, Notify{id, error, block} <> next, visited, scheduled},
              _ => Machine{w, next, visited, scheduled})))
    case PropagateNext{+edge, error, block} <> rest:
      Machine{w, Propagate{R.Link.nextSub(B.link(w, edge)), error, block} <> rest, visited, scheduled}
    case SettleVisit{+id, +error} <> +rest:
      B.choose(~Machine, B.contains(visited, id), _ => Machine{w, rest, visited, scheduled},
        _ =>
          visited = {id <> visited : List<&2, Nat>}
          +same = B.equal(R.NodeExtension.error(B.extension(w, id)), error)
          +w = B.choose(~R.World, same, _ => H.enqueueSub(w, id), _ => w)
          Machine{w, SettleWalk{R.Node.subs(B.node(w, id)), error} <> rest, visited, Bool.or(scheduled, same)})
    case SettleWalk{+edge, +error} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, visited, scheduled},
        _ => Machine{w, SettleVisit{R.Link.sub(B.link(w, edge)), error} <> SettleNext{edge, error} <> rest, visited, scheduled})
    case SettleNext{+edge, error} <> rest:
      Machine{w, SettleWalk{R.Link.nextSub(B.link(w, edge)), error} <> rest, visited, scheduled}
    case SettleEnd{} <> rest:
      Machine{B.choose(~R.World, scheduled, _ => B.schedule(w), _ => w), rest, visited, scheduled}

def run(fuel: Nat, m: Machine) -> R.World:
  match fuel m:
    case _ Machine{w, Nil{}, visited, scheduled}:
      w
    case 0n Machine{w, tasks, visited, scheduled}:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p Machine{+w, +tasks, +visited, +scheduled}:
      B.choose(~R.World, B.ok(w), _ => run(p, dispatch(w, tasks, visited, scheduled)), _ => w)

def notifyStatus(+w: R.World, id: Nat, error: R.Value) -> R.World:
  run(Nat.mul(4n, B.budget(w)), Machine{w, [Notify{id, error, False{}}], [], False{}})

def settleErroredDependents(+w: R.World, +id: Nat, error: R.Value) -> R.World:
  run(Nat.mul(4n, B.budget(w)), Machine{w, [SettleWalk{R.Node.subs(B.node(w, id)), error}, SettleEnd{}], [], False{}})
