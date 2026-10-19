# core/async.ts error/pending status propagation and effect.ts shared notifier.
# Flight callers and transaction/boundary entry remain an explicit frontier.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./write.bend as W
import ./heap.bend as H
import ./pending-state.bend as P
import ./transaction.bend as X
import ./error.bend as V

def unwrapStatusError(error: R.Value) -> R.Value:
  V.unwrapStatusError(error)

# Construct a NEW wrapper (effect-phase catch wraps even an existing wrapper).
def statusError(+w: R.World, source: Nat, cause: R.Value) -> B.Bundle<R.World, R.Value>:
  V.statusError(w, source, cause)

def wrapped(+w: R.World, source: Nat, error: R.Value) -> B.Bundle<R.World, R.Value>:
  match error:
    case R.StatusFailure{identity, owner, cause, message}:
      B.Bundle{w, R.StatusFailure{identity, owner, cause, message}}
    case R.NotReadyFailure{identity, owner}:
      B.Bundle{w, R.NotReadyFailure{identity, owner}}
    case e:
      statusError(w, source, e)

def haltReactivity(+w: R.World, +cause: R.Value) -> R.World:
  B.choose(~R.World, R.World.halted(w), _ => w,
    _ => B.report(R.World.with_halted(w, True{}), 0, B.choose(~R.Slot, B.equal(cause, R.Undefined{}), _ => R.Empty{}, _ => R.Present{cause})))

# effect.ts:notifyEffectStatus, including explicit blocked-forward arguments.
# A pending render observer enters joinFuture in the shared mainline transaction path.
def notifyEffectStatusOf(+w: R.World, +id: Nat, +status: U32, +error: R.Value) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.has(status, K.STATUS_ERROR()),
    _ => B.choose(~R.World, W.is_user(R.Node.kind(n)),
      _ => B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_ERROR()),
        _ => W.enqueue(B.store_node(w, id, R.Node.with_modified(n, True{})), id), _ => w),
      _ => R.World.with_fault(haltReactivity(w, unwrapStatusError(error)), R.CallbackThrown{error})),
    _ => B.choose(~R.World, Bool.and(Bool.not(W.is_user(R.Node.kind(n))), B.has(status, K.STATUS_PENDING())),
      _ => X.joinFuture(w, 0n), _ => w))

def notifyEffectStatus(+w: R.World, +id: Nat) -> R.World:
  notifyEffectStatusOf(w, id, R.Node.status(B.node(w, id)), R.NodeExtension.error(B.extension(w, id)))

# async.ts:clearStatus drops the node-owned source set and truthy error,
# preserves UNINITIALIZED unless requested, and calls the shared effect notifier.
# Its callers for actual pending flights/settlements remain unfinished.
def clearStatus(+w: R.World, +id: Nat, clearUninitialized: Bool) -> R.World:
  +w = P.clearPendingSources(w, id)
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

# async.ts:notifyStatus's local-node stores, before notifier/propagation.
def storeStatus(+w: R.World, +id: Nat, +status: U32, +error: R.Value) -> R.World:
  +source = P.notReadySource(error)
  B.choose(~R.World, Bool.and(U32.is_eq(status, K.STATUS_PENDING()), Nat.is_ne(source, 0n)),
    _ =>
      +w = B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR()),
        _ => B.store_extension(w, id, R.NodeExtension.with_shownError(B.extension(w, id), R.NodeExtension.error(B.extension(w, id)))), _ => w)
      +w = B.first(R.World, Bool, P.addPendingSource(w, id, source))
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(K.STATUS_PENDING(), U32.and(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))))
      P.setPendingError(w, id, source, error),
    _ =>
      +w = P.clearPendingSources(w, id)
      +flags = B.choose(~U32, U32.is_eq(status, K.STATUS_ERROR()), _ => status,
        _ => B.set(status, U32.and(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED())))
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), flags))
      +w = E.ext(w, id)
      B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), error)))

type Task is Data:
  Notify{id: Nat, status: U32, error: R.Value, block: Bool}
  Propagate{edge: Nat, status: U32, error: R.Value, block: Bool}
  PropagateNext{edge: Nat, status: U32, error: R.Value, block: Bool}
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
    case Notify{+id, +status, +error, +block} <> +rest:
      +pair = B.choose(~B.Bundle<R.World, R.Value>, U32.is_eq(status, K.STATUS_ERROR()),
        _ => wrapped(w, id, error), _ => B.Bundle{w, error})
      +w = B.first(R.World, R.Value, pair)
      +error = B.second(R.World, R.Value, pair)
      +w = B.choose(~R.World, block, _ => w, _ => storeStatus(w, id, status, error))
      B.choose(~Machine, Bool.and(U32.is_eq(status, K.STATUS_PENDING()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())),
        _ => Machine{B.choose(~R.World, Nat.is_eq(R.World.passLane(w), 0n), _ => X.joinFuture(w, 0n), _ => w), rest, visited, scheduled},
        _ => B.choose(~Machine, B.effect(R.Node.kind(B.node(w, id))),
          _ =>
            w = B.choose(~R.World, Bool.and(block, U32.is_eq(status, K.STATUS_PENDING())), _ => w,
              _ => B.choose(~R.World, block, _ => notifyEffectStatusOf(w, id, status, error), _ => notifyEffectStatus(w, id)))
            Machine{w, rest, visited, scheduled},
          _ => Machine{w, Propagate{R.Node.subs(B.node(w, id)), status, error, block} <> rest, visited, scheduled}))
    case Propagate{+edge, +status, +error, +block} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, visited, scheduled},
        _ =>
          +id = R.Link.sub(B.link(w, edge))
          +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
          +sub = B.node(w, id)
          +pending = U32.is_eq(status, K.STATUS_PENDING())
          +source = B.choose(~Nat, pending, _ => P.notReadySource(error), _ => 0n)
          +next = {PropagateNext{edge, status, error, block} <> rest : List<&2, Task>}
          B.choose(~Machine, Bool.or(B.has(R.Node.config(sub), B.set(K.CONFIG_REDERIVE(), K.CONFIG_VERDICT())),
              Bool.and(pending, Nat.is_ne(R.Link.gen(B.link(w, edge)), R.Node.depGen(sub)))),
            _ => Machine{B.schedule(H.enqueueSub(w, id)), next, visited, scheduled},
            _ => B.choose(~Machine, Bool.and(pending, Bool.and(Nat.is_ne(source, 0n), P.hasSource(w, id, source))),
              _ =>
                w = B.choose(~R.World, Bool.and(Bool.and(B.has(R.Node.config(sub), K.CONFIG_HELD()), Bool.not(B.has(R.Node.config(sub), K.CONFIG_OVERRIDE()))), R.World.running(w)),
                  _ => X.joinNode(w, id), _ => w)
                Machine{w, next, visited, scheduled},
              _ => B.choose(~Machine, Bool.or(Bool.and(pending, Nat.is_ne(source, 0n)), Bool.and(Bool.not(pending),
                  Bool.or(Bool.not(B.equal(R.NodeExtension.error(B.extension(w, id)), error)), hasSources(B.pendingSources(w, id))))),
                _ =>
                  +w = B.choose(~R.World, block, _ => w, _ => W.queuePendingNode(w, id))
                  +w = B.choose(~R.World, Bool.and(Bool.not(block), Bool.and(pending, Bool.and(B.has(R.Node.config(sub), K.CONFIG_HELD()),
                    Bool.and(Bool.not(B.has(R.Node.config(sub), K.CONFIG_OVERRIDE())), Bool.not(B.effect(R.Node.kind(sub))))))),
                    _ => X.joinNode(w, id), _ => w)
                  Machine{w, Notify{id, status, error, block} <> next, visited, scheduled},
                _ => Machine{w, next, visited, scheduled}))))
    case PropagateNext{+edge, status, error, block} <> rest:
      Machine{w, Propagate{R.Link.nextSub(B.link(w, edge)), status, error, block} <> rest, visited, scheduled}
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
  run(Nat.mul(4n, B.budget(w)), Machine{w, [Notify{id, K.STATUS_ERROR(), error, False{}}], [], False{}})

def settleErroredDependents(+w: R.World, +id: Nat, error: R.Value) -> R.World:
  run(Nat.mul(4n, B.budget(w)), Machine{w, [SettleWalk{R.Node.subs(B.node(w, id)), error}, SettleEnd{}], [], False{}})

# General production status helper; callers with flights/transactions are open.
def notifyStatusWith(+w: R.World, id: Nat, status: U32, error: R.Value, block: Bool) -> R.World:
  run(Nat.mul(4n, B.budget(w)), Machine{w, [Notify{id, status, error, block}], [], False{}})
