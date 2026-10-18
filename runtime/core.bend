# src/core/core.ts and GlobalQueue.flush translated as a continuation machine.
# Defunctionalized expressions are reusable callbacks. The same machine drives
# nested pulls and the flush: the JS adapter has no scheduling implementation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./graph.bend as G
import ./heap.bend as H
import ./scheduler.bend as S
import ./constants.bend as K
import ./read-state.bend as V
import ./owner.bend as O
import ./status.bend as A
import ./extension.bend as E
import ./pending-state.bend as P

type Task is Data:
  Evaluate{expr: R.Expr, previous: R.Value}
  Binary{op: U32}
  Discard{}
  Branch{yes: R.Expr, no: R.Expr, previous: R.Value}
  RestoreTracking{tracking: Bool}
  ReadNode{id: Nat}
  ReadPrepared{id: Nat}
  ReadStatus{id: Nat}
  Serve{id: Nat}
  AfterServe{id: Nat}
  RaiseHeight{source: Nat, reader: Nat}
  Update{id: Nat}
  CheckDeps{id: Nat, edge: Nat}
  AfterCheck{id: Nat}
  ClearFlags{id: Nat}
  Recompute{id: Nat, create: Bool}
  Finish{id: Nat, create: Bool, context: Nat, tracking: Bool, oldHeight: Nat, reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value, saved: List<&2, R.Value>}
  InitialEffect{id: Nat, scheduled: Bool, deferred: Bool}
  RunEffect{id: Nat}
  Round{}
  HeapLoop{}
  Seam{}
  RenderQueue{}
  UserQueue{}
  RoundEnd{}
  FlushFinally{}

type Machine is Data:
  Machine{world: R.World, tasks: List<&2, Task>, values: List<&2, R.Value>}

def world(m: Machine) -> R.World:
  match m:
    case Machine{w, tasks, values}:
      w

def values(m: Machine) -> List<&2, R.Value>:
  match m:
    case Machine{w, tasks, values}:
      values

def idle(m: Machine) -> Bool:
  match m:
    case Machine{w, tasks, values}:
      List.is_empty(&2, Task, tasks)

def healthy(f: R.Fault) -> Bool:
  B.healthy(f)

def truth(v: R.Value) -> Bool:
  B.truth(v)

def arithmetic(op: U32, left: R.Value, right: R.Value) -> R.Value:
  match left right:
    case R.Number{+a} R.Number{+b}:
      B.choose(~R.Value, U32.is_eq(op, 0), _ => R.Number{Nat.add(a, b)}, _ => R.Number{Nat.mul(a, b)})
    case _ _:
      R.Undefined{}

def numeric(v: R.Value) -> Bool:
  match v:
    case R.Number{n}:
      True{}
    case _:
      False{}

def binary(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +op: U32) -> Machine:
  match stack:
    case +right <> +left <> +tail:
      B.choose(~Machine, U32.is_eq(op, 2),
        _ => Machine{w, rest, R.Boolean{B.equal(left, right)} <> tail},
        _ => B.choose(~Machine, Bool.and(numeric(left), numeric(right)),
          _ => Machine{w, rest, arithmetic(op, left, right) <> tail},
          _ => Machine{R.World.with_fault(w, R.TypeError{}), [], []}))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), [], []}

def branch(w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +yes: R.Expr, +no: R.Expr, +prev: R.Value) -> Machine:
  match stack:
    case v <> tail:
      Machine{w, Evaluate{B.choose(~R.Expr, truth(v), _ => yes, _ => no), prev} <> rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), [], []}

def evaluate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, expr: R.Expr, +prev: R.Value) -> Machine:
  match expr:
    case R.Literal{v}:
      Machine{w, rest, v <> stack}
    case R.Previous{}:
      Machine{w, rest, prev <> stack}
    case R.Read{id}:
      Machine{w, ReadNode{id} <> rest, stack}
    case R.Add{left, right}:
      Machine{w, Evaluate{left, prev} <> Evaluate{right, prev} <> Binary{0} <> rest, stack}
    case R.Multiply{left, right}:
      Machine{w, Evaluate{left, prev} <> Evaluate{right, prev} <> Binary{1} <> rest, stack}
    case R.Same{left, right}:
      Machine{w, Evaluate{left, prev} <> Evaluate{right, prev} <> Binary{2} <> rest, stack}
    case R.Select{condition, yes, no}:
      Machine{w, Evaluate{condition, prev} <> Branch{yes, no, prev} <> rest, stack}
    case R.Untracked{body}:
      Machine{R.World.with_tracking(w, False{}), Evaluate{body, prev} <> RestoreTracking{R.World.tracking(w)} <> rest, stack}
    case R.CallProgram{callback}:
      +w = O.invoke(w, callback)
      B.choose(~Machine, B.ok(w), _ => Machine{w, rest, R.Undefined{} <> stack}, _ => Machine{w, rest, stack})
    case R.Then{first, second}:
      Machine{w, Evaluate{first, prev} <> Discard{} <> Evaluate{second, prev} <> rest, stack}
    case R.Raise{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), rest, stack}

# Solid core/core.ts:stagedRead. The lane stagedReaders hook is unfinished;
# the pass flag remains source state even in the synchronous profile. A source
# ID of zero represents the optional el argument being absent (plain fast read).
def stagedRead(+w: R.World, +reader: Nat, source: Nat) -> R.World:
  B.choose(~R.World, Bool.not(B.has(R.Node.status(B.node(w, source)), K.STATUS_UNINITIALIZED())),
    _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_STAGED_READ()))),
    _ => w)

# core/core.ts:prepareComputed, with refresh=false at the read call site.
def prepareDisposed(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +parent = R.Node.parent(n)
  B.choose(~Machine, B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()),
    _ => B.choose(~Machine, Bool.and(Nat.is_ne(parent, 0n), B.has(R.Node.flags(B.node(w, parent)), K.REACTIVE_DISPOSED())),
      _ => Machine{B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()))), ReadPrepared{id} <> rest, stack},
      _ =>
        w = B.choose(~R.World, Bool.and(Nat.is_ne(parent, 0n), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE()))),
          _ => O.linkChild(w, parent, id), _ => w)
        Machine{w, Recompute{id, True{}} <> ReadPrepared{id} <> rest, stack}),
    _ => Machine{w, ReadPrepared{id} <> rest, stack})

def readNode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, B.valid(w, id),
    _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), 512),
      _ => Machine{B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), 512))),
        Recompute{id, True{}} <> ReadPrepared{id} <> rest, stack},
      _ => B.choose(~Machine, Bool.and(B.computed(R.Node.kind(B.node(w, id))), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())),
        _ => prepareDisposed(w, rest, stack, id), _ => Machine{w, ReadPrepared{id} <> rest, stack})),
    _ => Machine{R.World.with_fault(w, R.BadId{}), [], []})

def prepareSlow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +tracked = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, tracked, _ => G.link(w, id, reader), _ => w)
  B.choose(~Machine, Bool.and(tracked, B.computed(R.Node.kind(B.node(w, id)))),
    _ =>
      +w = B.choose(~R.World, Nat.is_ge(R.Node.height(B.node(w, id)), R.World.minimum(w)),
        _ => H.markHeap(H.markNode(w, reader, 2)), _ => w)
      todo = B.choose(~List<&2, Task>, Nat.is_ge(R.Node.height(B.node(w, id)), R.World.minimum(w)),
        _ => [Update{id}], _ => [])
      Machine{w, B.append(Task, todo, RaiseHeight{id, reader} <> ReadStatus{id} <> AfterServe{id} <> rest), stack},
    _ => Machine{w, ReadStatus{id} <> AfterServe{id} <> rest, stack})

def afterServe(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  dormant = Bool.and(Nat.is_eq(B.parentComputed(w, R.World.context(w)), 0n), Bool.and(B.computed(R.Node.kind(n)),
    Bool.and(B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()), Bool.and(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())), Nat.is_eq(R.Node.subs(n), 0n)))))
  w = B.choose(~R.World, dormant, _ => B.schedule(G.queueDormant(w, id)), _ => w)
  Machine{w, rest, stack}

# core/core.ts:read, status block after pull and before value selection.
def readStatus(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, B.has(R.Node.status(n), K.STATUS_PENDING()),
    _ => Machine{R.World.with_fault(w, R.Unsupported{9n}), rest, stack},
    _ => B.choose(~Machine, Bool.and(B.computed(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_ERROR())),
      _ => B.choose(~Machine, Bool.and(R.World.tracking(w), Nat.is_lt(R.Node.time(n), R.World.clock(w))),
        _ => Machine{w, Recompute{id, False{}} <> ReadNode{id} <> rest, stack},
        _ => Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.error(B.extension(w, id))}), rest, stack}),
      _ => B.choose(~Machine, Bool.and(Nat.is_eq(B.parentComputed(w, R.World.context(w)), 0n), B.truth(R.NodeExtension.shownError(B.extension(w, id)))),
        _ => Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.shownError(B.extension(w, id))}), rest, stack},
        _ => Machine{w, Serve{id} <> rest, stack})))

# Read event instrumentation belongs to the callback adapter, after value choice.
def served(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +value: R.Value) -> Machine:
  Machine{B.event(w, R.ReadValue{reader, id, value}), rest, value <> stack}

# core/core.ts:read's plain-signal fast block, under the admitted no-snapshot,
# no-verdict profile. Its source ternary intentionally stays separate from serve.
def readSignalFast(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +tracked = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, tracked, _ => G.link(w, id, reader), _ => w)
  B.choose(~Machine, Bool.and(Nat.is_ne(reader, 0n), Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
    Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())))),
    _ => Machine{R.World.with_fault(w, R.Unsupported{3n}), [], []},
    _ =>
      +n = B.node(w, id)
      +committed = Bool.or(Nat.is_eq(reader, 0n), Bool.or(Bool.not(B.present(R.Node.pending(n))),
        B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())))
      +value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
      +w = B.choose(~R.World, committed, _ => w, _ => stagedRead(w, reader, 0n))
      served(w, rest, stack, reader, id, value))

def readPrepared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  fast = Bool.and(Bool.not(B.computed(R.Node.kind(n))),
    Bool.and(Bool.or(Bool.not(R.World.unflushedStaged(w)), Bool.not(B.present(R.Node.pending(n)))),
      Bool.not(B.has(R.Node.config(n), K.CONFIG_OVERRIDE()))))
  B.choose(~Machine, fast, _ => readSignalFast(w, rest, stack, id), _ => prepareSlow(w, rest, stack, id))

def serveSelected(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +u: R.Slot) -> Machine:
  B.choose(~Machine, B.present(u),
    _ => served(V.markLateLinker(w, reader), rest, stack, reader, id, B.selected(u, R.Undefined{})),
    _ =>
      +n = B.node(w, id)
      +committed = V.readerSeesCommitted(w, id, reader)
      B.choose(~Machine, Bool.and(Bool.not(committed), B.has(R.Node.config(n), K.CONFIG_STAGED_ERROR())),
        _ => Machine{R.World.with_fault(w, R.Unsupported{2n}), [], []},
        _ =>
          +w = B.choose(~R.World, committed, _ => w, _ => stagedRead(w, reader, id))
          value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
          served(w, rest, stack, reader, id, value)))

# core/core.ts:serve. NotReady/error propagation and spectating are unfinished.
# The unsupported born-staged read refuses instead of serving fabricated data.
def serve(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +reader = B.parentComputed(w, R.World.context(w))
  +noAnswer = Bool.and(B.present(R.Node.pending(n)), Bool.and(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()),
    Bool.or(Nat.is_eq(reader, 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN()))))
  B.choose(~Machine, noAnswer,
    _ => Machine{R.World.with_fault(w, R.Unsupported{4n}), [], []},
    _ =>
      +pair = B.choose(~B.Bundle<R.World, R.Slot>, Bool.and(Nat.is_ne(reader, 0n), R.World.unflushedStaged(w)),
        _ => V.unflushedValue(w, id), _ => B.Bundle{w, R.Empty{}})
      +w = B.first(R.World, R.Slot, pair)
      B.choose(~Machine, healthy(R.World.fault(w)),
        _ => serveSelected(w, rest, stack, id, reader, B.second(R.World, R.Slot, pair)),
        _ => Machine{w, [], []}))

def raiseHeight(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +source: Nat, +reader: Nat) -> Machine:
  +height = R.Node.height(B.node(w, source))
  +c = B.node(w, reader)
  w = B.choose(~R.World, Bool.and(Nat.is_ge(height, R.Node.height(c)), Nat.is_ne(R.Node.parent(B.node(w, source)), reader)),
    _ => B.store_node(w, reader, R.Node.with_height(c, 1n+height)), _ => w)
  Machine{w, rest, stack}

def update(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, B.has(R.Node.flags(n), 68), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, B.has(R.Node.flags(n), 1),
      _ => Machine{w, CheckDeps{id, R.Node.deps(n)} <> AfterCheck{id} <> rest, stack},
      _ => Machine{w, AfterCheck{id} <> rest, stack}))

def checkDeps(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +edge: Nat) -> Machine:
  B.choose(~Machine, Bool.or(Nat.is_eq(edge, 0n), B.has(R.Node.flags(B.node(w, id)), 2)),
    _ => Machine{w, rest, stack},
    _ =>
      +e = B.link(w, edge)
      +dep = R.Link.dep(e)
      todo = B.choose(~List<&2, Task>, B.computed(R.Node.kind(B.node(w, dep))), _ => [Update{dep}], _ => [])
      Machine{w, B.append(Task, todo, CheckDeps{id, R.Link.nextDep(e)} <> rest), stack})

def afterCheck(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  todo = B.choose(~List<&2, Task>, B.has(R.Node.flags(B.node(w, id)), 2), _ => [Recompute{id, False{}}], _ => [])
  Machine{w, B.append(Task, todo, ClearFlags{id} <> rest), stack}

# core/core.ts:recompute before the compute try. Cleanup failures here unwind
# the caller; they are not caught as errors of this node's body.
def prepareRecompute(+w: R.World, +id: Nat) -> R.World:
  +w = H.deleteFromHeap(w, id)
  +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ =>
      +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n))
      O.releaseFlightTeardown(w, id),
    _ => w)
  B.choose(~R.World, B.ok(w),
    _ =>
      +n = B.node(w, id)
      +w = B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_PENDING()),
        _ => B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), K.CONFIG_VERDICT()))), _ => w)
      # Transaction/lane re-entry is still an unsupported domain.
      B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
        _ => R.World.with_fault(w, R.Unsupported{3n}),
        _ => B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED()),
          _ => O.disposeChildren(w, id, False{}, False{}),
          _ => B.choose(~R.World, Bool.or(Nat.is_ne(R.Node.firstChild(B.node(w, id)), 0n), Bool.not(B.noDisposal(R.Node.disposal(B.node(w, id))))),
            _ => O.parkChildren(w, id), _ => w))),
    _ => w)

def recomputePrepared(+w: R.World, rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +n = B.node(w, id)
  reask = Bool.and(B.has(R.Node.flags(n), K.REACTIVE_REASK()),
    Bool.not(Bool.and(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.and(Nat.is_ne(R.Node.x(n), 0n), Bool.not(R.NodeExtension.reask(B.extension(w, id)))))))
  +context = R.World.context(w)
  +w = R.World.with_context(w, id)
  +n = R.Node.with_depsTail(n, 0n)
  +n = R.Node.with_depGen(n, 1n+R.Node.depGen(n))
  +n = R.Node.with_flags(n, B.set(K.REACTIVE_RECOMPUTING_DEPS(), U32.and(R.Node.flags(n), B.set(K.REACTIVE_ZOMBIE(), K.REACTIVE_REASK()))))
  +n = R.Node.with_time(n, R.World.clock(w))
  +w = B.store_node(w, id, n)
  next = {Evaluate{R.Node.expr(n), B.current(n)} <> Finish{id, create, context, R.World.tracking(w), R.Node.height(n), reask, B.current(n), B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()),
    B.choose(~R.Value, B.has(R.Node.status(n), K.STATUS_ERROR()), _ => R.NodeExtension.error(B.extension(w, id)), _ => R.Undefined{}), stack} <> rest : List<&2, Task>}
  w = R.World.with_tracking(B.event(w, R.Invoked{id}), True{})
  Machine{w, next, stack}

def recompute(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +w = B.bump(w)
  +w = B.choose(~R.World, create, _ => w, _ => prepareRecompute(w, id))
  B.choose(~Machine, B.ok(w), _ => recomputePrepared(w, rest, stack, id, create), _ => Machine{w, rest, stack})

def publish(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, wasUninitialized: Bool, +outgoing: R.Value) -> R.World:
  +w = B.choose(~R.World, B.truth(R.NodeExtension.error(B.extension(w, id))), _ => w,
    _ =>
      +n = B.node(w, id)
      +isEffect = B.effect(R.Node.kind(n))
      +changed = Bool.or(Bool.and(Bool.not(isEffect), wasUninitialized),
        Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.or(Bool.not(R.Node.equals(n)), Bool.not(B.equal(B.current(n), value)))))
      +w = B.choose(~R.World, Bool.and(isEffect, Bool.and(changed, Bool.not(B.present(R.Node.pending(n))))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))
          B.choose(~R.World, create, _ => w, _ => S.enqueue(w, id)), _ => w)
      +w = B.choose(~R.World, changed,
        _ =>
          +w = B.choose(~R.World, Bool.or(create, Bool.and(isEffect, Bool.not(B.present(R.Node.pending(B.node(w, id)))))),
            _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
            _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})))
          B.choose(~R.World, Nat.is_ne(R.Node.subs(n), 0n), _ => S.insertSubs(w, id), _ => w),
        _ => B.choose(~R.World, Nat.is_ne(R.Node.height(B.node(w, id)), oldHeight),
          _ => H.height_subs(B.budget(w), w, R.Node.subs(n)), _ => w))
      recover = Bool.and(Bool.not(changed), Bool.and(Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))), Bool.not(B.equal(outgoing, R.Undefined{}))))
      B.choose(~R.World, recover,
        _ => A.settleErroredDependents(w, id, outgoing), _ => w))
  +n = B.node(w, id)
  +w = B.choose(~R.World, Bool.and(Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))), Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.not(R.Node.modified(n)))),
    _ => B.choose(~R.World, create, _ => G.trimStaleDeps(w, id),
      _ => R.World.with_trims(w, B.append(Nat, R.World.trims(w), [id]))), _ => w)
  B.choose(~R.World, B.ok(w),
    _ =>
      +n = B.node(w, id)
      queued = Bool.or(B.present(R.Node.pending(n)), Bool.or(O.parked(w, id),
        Bool.and(B.has(R.Node.status(n), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED())), Bool.or(Bool.not(create), B.has(R.Node.status(n), K.STATUS_PENDING())))))
      +w = B.choose(~R.World, queued,
        _ => S.queuePendingNode(B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), 128))), id), _ => w)
      w,
    _ => w)

# recompute's finally is shared by normal return and exceptional unwind.
def passFinally(+w: R.World, +id: Nat, create: Bool, context: Nat, tracking: Bool, reask: Bool) -> R.World:
  +w = R.World.with_tracking(w, tracking)
  +n = B.node(w, id)
  +config = B.set(B.clear(R.Node.config(n), K.CONFIG_VERDICT()), U32.and(R.Node.flags(n), K.REACTIVE_PROBED()))
  +w = B.store_node(w, id, R.Node.with_config(n, config))
  +keep = B.set(K.REACTIVE_ZOMBIE(), B.set(K.REACTIVE_DISPOSED(), B.set(K.REACTIVE_FRAME_READ(), B.set(K.REACTIVE_STAGED_READ(),
    B.set(K.REACTIVE_LANE_READ(), B.set(K.REACTIVE_SCREEN_READ(), K.REACTIVE_PROBE_UNANSWERED()))))))
  keep = B.choose(~U32, create, _ => B.set(keep, K.REACTIVE_SNAPSHOT_STALE()), _ => keep)
  +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), U32.and(R.Node.flags(B.node(w, id)), keep)))
  +w = R.World.with_context(w, context)
  B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ => B.store_extension(w, id, R.NodeExtension.with_reask(B.extension(w, id), Bool.and(reask, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))), _ => w)

def afterPass(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, create: Bool, value: R.Value, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, missed: Bool) -> Machine:
  B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()),
    _ =>
      +w = G.clearDeps(w, id)
      w = B.choose(~R.World, Bool.and(B.ok(w), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      Machine{w, rest, stack},
    _ =>
      +w = publish(w, id, value, create, oldHeight, wasUninitialized, outgoing)
      w = B.choose(~R.World, Bool.and(B.ok(w), missed), _ => B.schedule(H.enqueueSub(w, id)), _ => w)
      Machine{w, rest, stack})

def finish(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +create: Bool, context: Nat, tracking: Bool, oldHeight: Nat, reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value, saved: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> +tail:
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
      +w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => A.clearStatus(w, id, create), _ => w)
      +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
      +w = passFinally(w, id, create, context, tracking, reask)
      B.choose(~Machine, B.ok(w),
        _ => afterPass(w, rest, tail, id, create, value, oldHeight, wasUninitialized, outgoing, missed),
        _ => Machine{w, rest, tail})
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# Body throw -> source catch -> finally -> publication tail, with the caller's
# value stack restored. A throw from the prelude has no frame of its own here.
def catchStatus(+w: R.World, +id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{+cause}:
      # Pending catch/flight callers are not yet connected. Refuse this typed
      # control outcome rather than misclassifying NotReady as a user error.
      B.choose(~R.World, Bool.or(P.isNotReady(cause), B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD())),
        _ => R.World.with_fault(w, R.Unsupported{9n}),
        _ => A.notifyStatus(R.World.with_fault(w, R.Healthy{}), id, cause))
    case other:
      w

def catchPass(+w: R.World, +rest: List<&2, Task>, +id: Nat, +create: Bool, context: Nat, tracking: Bool, oldHeight: Nat, reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value, +saved: List<&2, R.Value>) -> Machine:
  +w = catchStatus(w, id, R.World.fault(w))
  +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
  +w = passFinally(w, id, create, context, tracking, reask)
  B.choose(~Machine, B.ok(w),
    _ => afterPass(w, rest, saved, id, create, previous, oldHeight, wasUninitialized, outgoing, missed),
    _ => Machine{w, rest, saved})

# effect.ts:runEffect's catch always constructs a fresh StatusError, even if
# the thrown payload was itself a wrapper; the escaping throw remains raw.
def effectCatch(+w: R.World, +id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{+cause}:
      +pair = A.statusError(w, id, cause)
      +w = E.ext(B.first(R.World, R.Value, pair), id)
      +w = B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), B.second(R.World, R.Value, pair)))
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(R.Node.status(B.node(w, id)), K.STATUS_ERROR())))
      R.World.with_fault(A.haltReactivity(w, cause), R.CallbackThrown{cause})
    case other:
      w

# A finally callback runs despite an active throw; its own throw overrides it.
def trimFinally(+w: R.World, id: Nat, +prior: R.Fault) -> R.World:
  +w = G.trimStaleDeps(R.World.with_fault(w, R.Healthy{}), id)
  B.choose(~R.World, B.ok(w), _ => R.World.with_fault(w, prior), _ => w)

# Error-arm throws escalate without replacing the compute's status error.
def errorArmCatch(+w: R.World, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{cause}:
      A.haltReactivity(w, cause)
    case other:
      w

# User compute errors take the error arm in the effect phase. The helper
# passed to the program detaches prior cleanup, as the source closure does.
def userError(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_prevValue(B.node(w, id), R.Node.value(B.node(w, id))))
  +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{}))
  +program = R.Node.errorProgram(B.node(w, id))
  +param = R.World.callbackEffect(w)
  +w = B.choose(~R.World, Nat.is_ne(program, 0n),
    _ => O.invoke(R.World.with_callbackEffect(w, id), program),
    _ => B.report(w, 2, R.Present{A.unwrapStatusError(R.NodeExtension.error(B.extension(w, id)))}))
  +w = R.World.with_callbackEffect(w, param)
  errorArmCatch(w, R.World.fault(w))

# core/effect.ts:runEffect. Programs represent _effectFn and its return value.
def runEffect(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +w = B.choose(~R.World, Bool.and(R.Node.modified(n), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))),
    _ => B.choose(~R.World, Bool.and(S.is_user(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_ERROR())),
      _ => userError(w, id),
      _ =>
        +clean = B.nullish(R.NodeExtension.error(B.extension(w, id)))
        +prevCleanup = R.Node.cleanup(n)
        +w = B.store_node(w, id, R.Node.with_cleanup(n, 0n))
        +w = B.choose(~R.World, Nat.is_ne(prevCleanup, 0n), _ => O.invoke(w, prevCleanup), _ => w)
        +w = B.choose(~R.World, B.ok(w),
          _ =>
            +w = B.event(w, R.Applied{id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id))})
            +w = B.choose(~R.World, S.is_user(R.Node.kind(B.node(w, id))), _ => w,
              _ => T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))))
            +callback = R.Node.effectProgram(B.node(w, id))
            +w = B.choose(~R.World, Nat.is_ne(callback, 0n), _ => O.invoke(w, callback), _ => w)
            B.choose(~R.World, B.ok(w), _ => B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), R.Node.returnedCleanup(B.node(w, id)))), _ => w),
          _ => w)
        +w = effectCatch(w, id, R.World.fault(w))
        # Source finally, including an overriding trim exception.
        +w = B.store_node(w, id, R.Node.with_prevValue(B.node(w, id), R.Node.value(B.node(w, id))))
        +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{}))
        B.choose(~R.World, clean, _ => trimFinally(w, id, R.World.fault(w)), _ => w),
      ),
    _ => w)
  Machine{w, rest, stack}

def queue_tasks(ids: List<&2, Nat>) -> List<&2, Task>:
  match ids:
    case Nil{}:
      []
    case id <> +rest:
      RunEffect{id} <> queue_tasks(rest)

def heapLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  B.choose(~Machine, Nat.is_gt(R.World.minimum(w), R.World.maximum(w)),
    _ => Machine{R.World.with_maximum(w, 0n), Seam{} <> rest, stack},
    _ =>
      +id = B.bucket(w, R.World.minimum(w))
      B.choose(~Machine, Nat.is_eq(id, 0n),
        _ => Machine{R.World.with_minimum(w, 1n+R.World.minimum(w)), HeapLoop{} <> rest, stack},
        _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), 8),
          _ => Machine{w, Recompute{id, False{}} <> HeapLoop{} <> rest, stack},
          _ => Machine{H.adjustHeight(w, id), HeapLoop{} <> rest, stack})))

def round(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +w = R.World.with_running(w, True{})
  +w = V.resyncUnflushedCompanions(w)
  +w = G.sweepDormant(w)
  B.choose(~Machine, B.ok(w),
    _ =>
      w = R.World.with_marked(w, False{})
      w = R.World.with_minimum(w, 0n)
      Machine{w, HeapLoop{} <> FlushFinally{} <> RoundEnd{} <> rest, stack},
    _ => Machine{w, FlushFinally{} <> RoundEnd{} <> rest, stack})

def seam(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +w = S.settle(w)
  B.choose(~Machine, B.ok(w),
    _ =>
      +w = R.World.with_clock(w, 1n+R.World.clock(w))
      w = R.World.with_scheduled(w, Bool.or(Nat.is_ge(R.World.maximum(w), R.World.minimum(w)), Bool.not(List.is_empty(&2, Nat, R.World.pendingNodes(w)))))
      Machine{w, RenderQueue{} <> rest, stack},
    _ => Machine{w, rest, stack})

def dispatch(+w: R.World, tasks: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case Evaluate{expr, prev} <> +rest:
      evaluate(w, rest, stack, expr, prev)
    case Discard{} <> rest:
      match stack:
        case value <> +tail:
          Machine{w, rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case Binary{op} <> +rest:
      binary(w, rest, stack, op)
    case Branch{yes, no, prev} <> +rest:
      branch(w, rest, stack, yes, no, prev)
    case RestoreTracking{tracking} <> +rest:
      Machine{R.World.with_tracking(w, tracking), rest, stack}
    case ReadNode{id} <> +rest:
      readNode(w, rest, stack, id)
    case ReadPrepared{id} <> +rest:
      readPrepared(w, rest, stack, id)
    case ReadStatus{id} <> rest:
      readStatus(w, rest, stack, id)
    case Serve{id} <> +rest:
      serve(w, rest, stack, id)
    case AfterServe{id} <> rest:
      afterServe(w, rest, stack, id)
    case RaiseHeight{source, reader} <> +rest:
      raiseHeight(w, rest, stack, source, reader)
    case Update{id} <> +rest:
      update(w, rest, stack, id)
    case CheckDeps{id, edge} <> +rest:
      checkDeps(w, rest, stack, id, edge)
    case AfterCheck{id} <> +rest:
      afterCheck(w, rest, stack, id)
    case ClearFlags{+id} <> +rest:
      Machine{B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), 3))), rest, stack}
    case Recompute{id, create} <> +rest:
      recompute(w, rest, stack, id, create)
    case Finish{id, create, context, tracking, oldHeight, reask, previous, wasUninitialized, outgoing, saved} <> +rest:
      finish(w, rest, stack, id, create, context, tracking, oldHeight, reask, previous, wasUninitialized, outgoing, saved)
    case InitialEffect{+id, +scheduled, deferred} <> +rest:
      B.choose(~Machine, deferred, _ => Machine{w, rest, stack},
        _ => B.choose(~Machine, Bool.or(scheduled, S.is_user(R.Node.kind(B.node(w, id)))),
          _ => Machine{S.enqueue(w, id), rest, stack}, _ => Machine{w, RunEffect{id} <> rest, stack}))
    case RunEffect{id} <> +rest:
      runEffect(w, rest, stack, id)
    case Round{} <> +rest:
      round(w, rest, stack)
    case HeapLoop{} <> +rest:
      heapLoop(w, rest, stack)
    case Seam{} <> +rest:
      seam(w, rest, stack)
    case RenderQueue{} <> +rest:
      B.choose(~Machine, List.is_empty(&2, Nat, R.World.renderQueue(w)),
        _ => Machine{w, UserQueue{} <> rest, stack},
        _ => Machine{R.World.with_renderQueue(w, []), B.append(Task, queue_tasks(R.World.renderQueue(w)), UserQueue{} <> rest), stack})
    case UserQueue{} <> +rest:
      B.choose(~Machine, List.is_empty(&2, Nat, R.World.userQueue(w)),
        _ => Machine{w, rest, stack},
        _ => Machine{R.World.with_userQueue(w, []), B.append(Task, queue_tasks(R.World.userQueue(w)), rest), stack})
    case FlushFinally{} <> rest:
      Machine{R.World.with_running(w, False{}), rest, stack}
    case RoundEnd{} <> +rest:
      todo = B.choose(~List<&2, Task>, R.World.scheduled(w), _ => Round{} <> rest, _ => rest)
      Machine{w, todo, stack}

# Source exceptions skip ordinary continuations and execute enclosing finally
# frames. Cleanup throws before the compute try do not become node status here.
def unwind(+w: R.World, tasks: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case RestoreTracking{tracking} <> rest:
      Machine{R.World.with_tracking(w, tracking), rest, stack}
    case Finish{id, create, context, tracking, height, reask, previous, wasUninitialized, outgoing, saved} <> rest:
      catchPass(w, rest, id, create, context, tracking, height, reask, previous, wasUninitialized, outgoing, saved)
    case FlushFinally{} <> rest:
      Machine{R.World.with_running(w, False{}), rest, stack}
    case task <> rest:
      Machine{w, rest, stack}

def step(m: Machine) -> Machine:
  match m:
    case Machine{w, Nil{}, stack}:
      Machine{w, [], stack}
    case Machine{+w, +tasks, +stack}:
      B.choose(~Machine, B.ok(w), _ => dispatch(w, tasks, stack), _ => unwind(w, tasks, stack))

# Fuel is an explicit resource bound, not a progress theorem. Exhaustion
# remains visible to every caller and is rejected by the JS facade.
def run(fuel: Nat, m: Machine) -> Machine:
  match fuel m:
    case _ Machine{w, Nil{}, stack}:
      Machine{w, [], stack}
    case 0n Machine{w, tasks, stack}:
      Machine{R.World.with_fault(w, R.Exhausted{}), [], []}
    case 1n+p Machine{w, tasks, stack}:
      run(p, step(Machine{w, tasks, stack}))

def flush(fuel: Nat, +w: R.World) -> R.World:
  B.choose(~R.World, Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w)))), _ => w,
    _ => world(run(fuel, Machine{w, [Round{}], []})))

def eval(fuel: Nat, w: R.World, expr: R.Expr, prev: R.Value) -> Machine:
  run(fuel, Machine{w, [Evaluate{expr, prev}], []})

# Solid core/core.ts:markRefresh, production branch. The dev owned-scope guard
# and observe attribution hook remain explicit tier omissions. This helper is
# invalidation, not the public signals.ts refresh waiter protocol.
def markRefresh(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, Bool.and(B.computed(R.Node.kind(n)), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))),
    _ =>
      +flags = R.Node.flags(n)
      reask = B.choose(~U32, B.has(flags, B.set(K.REACTIVE_DIRTY(), B.set(K.REACTIVE_CHECK(), K.REACTIVE_IN_HEAP()))),
        _ => 0, _ => K.REACTIVE_REASK())
      +flags = B.set(B.clear(flags, K.REACTIVE_CHECK()), B.set(K.REACTIVE_DIRTY(), reask))
      +w = B.store_node(w, id, R.Node.with_flags(n, flags))
      +w = H.insertIntoHeap(w, id)
      B.schedule(w),
    _ => w)
