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

type Task is Data:
  Evaluate{expr: R.Expr, previous: R.Value}
  Binary{op: U32}
  Branch{yes: R.Expr, no: R.Expr, previous: R.Value}
  RestoreTracking{tracking: Bool}
  ReadNode{id: Nat}
  ReadPrepared{id: Nat}
  Serve{id: Nat}
  RaiseHeight{source: Nat, reader: Nat}
  Update{id: Nat}
  CheckDeps{id: Nat, edge: Nat}
  AfterCheck{id: Nat}
  ClearFlags{id: Nat}
  Recompute{id: Nat, create: Bool}
  Finish{id: Nat, create: Bool, context: Nat, tracking: Bool, oldHeight: Nat}
  InitialEffect{id: Nat, scheduled: Bool, deferred: Bool}
  RunEffect{id: Nat}
  Round{}
  HeapLoop{}
  Seam{}
  RenderQueue{}
  UserQueue{}
  RoundEnd{}

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
  match f:
    case R.Healthy{}:
      True{}
    case _:
      False{}

def truth(v: R.Value) -> Bool:
  match v:
    case R.Boolean{b}:
      b
    case R.Number{n}:
      Nat.is_ne(n, 0n)
    case R.Reference{id}:
      True{}
    case R.StringValue{s}:
      Bool.not(String.is_empty(s))
    case _:
      False{}

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
    case R.Raise{cause}:
      # Error-status propagation is not yet translated. Refuse explicitly.
      Machine{R.World.with_fault(w, R.Unsupported{1n}), [], []}

# Solid core/core.ts:stagedRead. The lane stagedReaders hook is unfinished;
# the pass flag remains source state even in the synchronous profile. A source
# ID of zero represents the optional el argument being absent (plain fast read).
def stagedRead(+w: R.World, +reader: Nat, source: Nat) -> R.World:
  B.choose(~R.World, Bool.not(B.has(R.Node.status(B.node(w, source)), K.STATUS_UNINITIALIZED())),
    _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_STAGED_READ()))),
    _ => w)

def readNode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, B.valid(w, id),
    _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), 512),
      _ => Machine{B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), 512))),
        Recompute{id, True{}} <> ReadPrepared{id} <> rest, stack},
      _ => Machine{w, ReadPrepared{id} <> rest, stack}),
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
      Machine{w, B.append(Task, todo, RaiseHeight{id, reader} <> Serve{id} <> rest), stack},
    _ => Machine{w, Serve{id} <> rest, stack})

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

def recompute(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +w = B.bump(w)
  +w = B.choose(~R.World, create, _ => w, _ => H.deleteFromHeap(w, id))
  +n = B.node(w, id)
  +n = R.Node.with_depsTail(n, 0n)
  +n = R.Node.with_depGen(n, 1n+R.Node.depGen(n))
  +n = R.Node.with_flags(n, B.set(K.REACTIVE_RECOMPUTING_DEPS(), U32.and(R.Node.flags(n), K.REACTIVE_REASK())))
  +n = R.Node.with_time(n, R.World.clock(w))
  +w = B.store_node(w, id, n)
  next = {Evaluate{R.Node.expr(n), B.current(n)} <> Finish{id, create, R.World.context(w), R.World.tracking(w), R.Node.height(n)} <> rest : List<&2, Task>}
  w = R.World.with_tracking(R.World.with_context(B.event(w, R.Invoked{id}), id), True{})
  Machine{w, next, stack}

def publish(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat) -> R.World:
  +n = B.node(w, id)
  +isEffect = B.effect(R.Node.kind(n))
  +changed = Bool.or(Bool.and(Bool.not(isEffect), B.has(R.Node.status(n), 4)),
    Bool.or(Bool.not(R.Node.equals(n)), Bool.not(B.equal(B.current(n), value))))
  +w = B.choose(~R.World, Bool.and(isEffect, changed),
    _ =>
      +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))
      B.choose(~R.World, create, _ => w, _ => S.enqueue(w, id)), _ => w)
  +w = B.choose(~R.World, changed,
    _ =>
      +w = B.choose(~R.World, Bool.or(create, isEffect),
        _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
        _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})))
      B.choose(~R.World, Nat.is_ne(R.Node.subs(n), 0n), _ => S.insertSubs(w, id), _ => w),
    _ => B.choose(~R.World, Nat.is_ne(R.Node.height(B.node(w, id)), oldHeight),
      _ => H.height_subs(B.budget(w), w, R.Node.subs(n)), _ => w))
  +n = B.node(w, id)
  +w = B.choose(~R.World, Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.not(R.Node.modified(n))),
    _ => B.choose(~R.World, create, _ => G.trimStaleDeps(w, id),
      _ => R.World.with_trims(w, B.append(Nat, R.World.trims(w), [id]))), _ => w)
  +n = B.node(w, id)
  +w = B.choose(~R.World, B.present(R.Node.pending(n)),
    _ => S.queuePendingNode(B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), 128))), id), _ => w)
  # Successful sync passes initialize at direct publication or commit.
  B.store_node(w, id, R.Node.with_status(B.node(w, id), 0))

def finish(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +create: Bool, context: Nat, tracking: Bool, oldHeight: Nat) -> Machine:
  match stack:
    case value <> tail:
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
      +missed = B.has(R.Node.flags(B.node(w, id)), 4096)
      +w = R.World.with_tracking(R.World.with_context(w, context), tracking)
      +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), B.set(4103, K.REACTIVE_REASK()))))
      # Successful synchronous pass: the source finally consumes quiet-reask
      # metadata. Pending classification and clearStatus propagation are open.
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_reask(B.extension(w, id), False{})), _ => w)
      +w = publish(w, id, value, create, oldHeight)
      w = B.choose(~R.World, missed, _ => B.schedule(H.enqueueSub(w, id)), _ => w)
      Machine{w, rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), [], []}

def runEffect(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +w = B.choose(~R.World, Bool.and(R.Node.modified(n), Bool.not(B.has(R.Node.flags(n), 64))),
    _ =>
      +w = B.choose(~R.World, S.is_user(R.Node.kind(n)), _ => w, _ => T.setText(w, R.Node.target(n), R.Node.value(n)))
      +w = B.event(w, R.Applied{id, R.Node.value(n), R.Node.prevValue(n)})
      +w = B.store_node(w, id, R.Node.with_modified(R.Node.with_prevValue(B.node(w, id), R.Node.value(n)), False{}))
      G.trimStaleDeps(w, id), _ => w)
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

def round(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  w = R.World.with_running(w, True{})
  w = V.resyncUnflushedCompanions(w)
  # runHeap's entry writes, after GlobalQueue.flush's resync.
  w = R.World.with_marked(w, False{})
  w = R.World.with_minimum(w, 0n)
  Machine{w, HeapLoop{} <> rest, stack}

def seam(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  +w = S.settle(w)
  +w = R.World.with_clock(w, 1n+R.World.clock(w))
  w = R.World.with_scheduled(w, Bool.or(Nat.is_ge(R.World.maximum(w), R.World.minimum(w)), Bool.not(List.is_empty(&2, Nat, R.World.pendingNodes(w)))))
  Machine{w, RenderQueue{} <> rest, stack}

def dispatch(+w: R.World, tasks: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case Evaluate{expr, prev} <> +rest:
      evaluate(w, rest, stack, expr, prev)
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
    case Serve{id} <> +rest:
      serve(w, rest, stack, id)
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
    case Finish{id, create, context, tracking, oldHeight} <> +rest:
      finish(w, rest, stack, id, create, context, tracking, oldHeight)
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
        _ => Machine{w, RoundEnd{} <> rest, stack},
        _ => Machine{R.World.with_userQueue(w, []), B.append(Task, queue_tasks(R.World.userQueue(w)), RoundEnd{} <> rest), stack})
    case RoundEnd{} <> +rest:
      +w = R.World.with_running(w, False{})
      todo = B.choose(~List<&2, Task>, R.World.scheduled(w), _ => Round{} <> rest, _ => rest)
      Machine{w, todo, stack}

def step(m: Machine) -> Machine:
  match m:
    case Machine{w, tasks, stack}:
      dispatch(w, tasks, stack)

# Fuel is an explicit resource bound, not a progress theorem. Exhaustion
# remains visible to every caller and is rejected by the JS facade.
def run(fuel: Nat, m: Machine) -> Machine:
  match fuel m:
    case _ Machine{w, Nil{}, stack}:
      Machine{w, [], stack}
    case 0n Machine{w, tasks, stack}:
      Machine{R.World.with_fault(w, R.Exhausted{}), [], []}
    case 1n+p Machine{w, tasks, stack}:
      run(p, dispatch(w, tasks, stack))

def flush(fuel: Nat, +w: R.World) -> R.World:
  B.choose(~R.World, Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w))), _ => w,
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
