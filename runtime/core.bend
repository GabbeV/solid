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
import ./transaction.bend as X
import ./pending.bend as Q
import ./flight.bend as F
import ./iterator-state.bend as I
import ./watch-state.bend as U
import ./write.bend as W
import ./ambient.bend as L
import ./owner-state.bend as D
import ./callback.bend as Z
import ./context.bend as Y
import ./callable.bend as J

# GlobalQueue.settle's detached own queues and captured joined transaction.
type SeamFrame is Data:
  SeamFrame{transaction: Nat, renders: List<&2, Nat>, users: List<&2, Nat>}

# Locals captured by recompute's try/catch/finally return point.
type PassFrame is Data:
  PassFrame{id: Nat, create: Bool, context: Nat, tracking: Bool, oldHeight: Nat,
    reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value,
    outgoingSources: Nat, wasPendingSource: Bool, oldFlight: Nat,
    saved: List<&2, R.Value>}

type Task is Data:
  Evaluate{expr: R.Expr, previous: R.Value}
  Callback{callback: Nat, actions: List<&2, R.CleanupAction>, first: R.Value, second: R.Value}
  CallArguments{callback: Nat}
  Invoke{}
  OnCleanup{}
  CallbackWrite{signal: Nat, updater: Bool}
  CallbackThrow{}
  WatchFinish{awaiter: Nat, saved: List<&2, R.Value>}
  Binary{op: U32}
  Discard{}
  Branch{yes: R.Expr, no: R.Expr, previous: R.Value}
  RestoreTracking{tracking: Bool}
  EnterOwner{body: R.Expr, previous: R.Value}
  RestoreContext{owner: Nat, tracking: Bool}
  CheckDisposed{}
  DisposeRoot{}
  ContextGet{key: Nat}
  ContextSet{key: Nat}
  ReadNode{id: Nat}
  ReadPrepared{id: Nat}
  ReadStatus{id: Nat}
  Serve{id: Nat}
  AfterServe{id: Nat}
  RaiseHeight{source: Nat, reader: Nat}
  Update{id: Nat}
  CheckDeps{id: Nat, edge: Nat}
  CheckNext{id: Nat, edge: Nat}
  AfterCheck{id: Nat}
  ClearFlags{id: Nat}
  Recompute{id: Nat, create: Bool}
  Finish{frame: PassFrame}
  AfterThen{frame: PassFrame, observer: Nat}
  RegisterFlight{frame: PassFrame, id: Nat, result: Nat}
  RegisterQuestion{frame: PassFrame, id: Nat, result: Nat}
  RegisterSources{frame: PassFrame, id: Nat, result: Nat}
  RegisterObserver{frame: PassFrame, id: Nat, result: Nat}
  SubscribeThen{frame: PassFrame, result: Nat, observer: Nat}
  AfterIterator{frame: PassFrame}
  IterateStream{stream: Nat}
  AfterStep{observer: Nat}
  AfterConsume{stream: Nat}
  IterateOrRelease{stream: Nat}
  AsyncFulfill{observer: Nat, value: R.Value}
  AsyncReject{observer: Nat, error: R.Value}
  AsyncFlush{}
  SettleAuto{id: Nat}
  DeliverObservers{observers: List<&2, Nat>, immediate: Bool, rejected: Bool, value: R.Value}
  InitialEffect{id: Nat, scheduled: Bool, deferred: Bool}
  RunEffect{id: Nat}
  ApplyEffect{id: Nat}
  InstallEffectCleanup{id: Nat}
  EffectFinally{id: Nat, clean: Bool, saved: List<&2, R.Value>}
  ErrorArmFinally{parameter: Nat, saved: List<&2, R.Value>}
  Round{}
  HeapLoop{}
  Seam{}
  Settle{}
  AfterSettle{}
  LandTransactions{frame: SeamFrame, remaining: Nat}
  LandNodes{frame: SeamFrame, transaction: Nat, index: Nat}
  LandEnd{frame: SeamFrame, transaction: Nat}
  CompleteSettle{frame: SeamFrame}
  ZombieLoop{nodes: List<&2, Nat>}
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
    case R.WatchExpr{+awaiter, expr}:
      Machine{U.capture(w, awaiter), Evaluate{expr, prev} <> WatchFinish{awaiter, stack} <> rest, stack}
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
    case R.WithOwner{owner, body}:
      Machine{w, Evaluate{owner, prev} <> EnterOwner{body, prev} <> rest, stack}
    case R.CurrentOwner{}:
      Machine{w, rest, L.reference(L.getOwner(w)) <> stack}
    case R.CurrentObserver{}:
      Machine{w, rest, L.reference(L.getObserver(w)) <> stack}
    case R.OwnerDisposed{owner}:
      Machine{w, Evaluate{owner, prev} <> CheckDisposed{} <> rest, stack}
    case R.RootScope{body, transparent}:
      +id = B.length(R.Node, R.World.nodes(w))
      Machine{L.enterOwner(D.createOwner(w, R.World.context(w), transparent), id),
        Evaluate{Z.bind(body, R.RootDisposerReference{id}, R.Undefined{}), prev} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> rest, stack}
    case R.DisposeRoot{owner}:
      Machine{w, Evaluate{owner, prev} <> DisposeRoot{} <> rest, stack}
    case R.ContextGet{key, owner}:
      Machine{w, Evaluate{owner, prev} <> ContextGet{key} <> rest, stack}
    case R.ContextSet{key, value, owner}:
      Machine{w, Evaluate{value, prev} <> Evaluate{owner, prev} <> ContextSet{key} <> rest, stack}
    case R.Argument{index}:
      Machine{w, rest, R.Undefined{} <> stack}
    case R.CallWith{callback, first, second}:
      Machine{w, Evaluate{first, prev} <> Evaluate{second, prev} <> CallArguments{callback} <> rest, stack}
    case R.Invoke{callee}:
      Machine{w, Evaluate{callee, prev} <> Invoke{} <> rest, stack}
    case R.OnCleanup{callee}:
      Machine{w, Evaluate{callee, prev} <> OnCleanup{} <> rest, stack}
    case R.CallProgram{+callback}:
      B.choose(~Machine, Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
        _ => Machine{w, Callback{callback, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[]})), R.Undefined{}, R.Undefined{}} <> rest, stack},
        _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), rest, stack})
    case R.Then{first, second}:
      Machine{w, Evaluate{first, prev} <> Discard{} <> Evaluate{second, prev} <> rest, stack}
    case R.Raise{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), rest, stack}

# User callback ABI, not a Solid scheduling operation. Statements execute in
# order in the current source callback scope. Arguments are bound as user-code
# data; return exits only this invocation. Reads use the ordinary ReadNode continuation.
def callbackAction(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, R.CleanupAction>, +first: R.Value, +second: R.Value, value: R.CleanupAction) -> Machine:
  match value:
    case R.CallbackEvaluate{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}
    case R.CallbackReturn{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> rest, stack}
    case R.CallbackWrite{signal, expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> CallbackWrite{signal, False{}} <> Callback{id, tail, first, second} <> rest, stack}
    case R.CallbackUpdate{+signal, expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), B.current(B.node(w, signal))} <> CallbackWrite{signal, True{}} <> Callback{id, tail, first, second} <> rest, stack}
    case R.CallbackThrow{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> CallbackThrow{} <> Callback{id, tail, first, second} <> rest, stack}
    case other:
      Machine{O.invokeAction(w, id, other), Callback{id, tail, first, second} <> rest, stack}

def callback(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +first: R.Value, +second: R.Value, actions: List<&2, R.CleanupAction>) -> Machine:
  match actions:
    case Nil{}:
      Machine{w, rest, R.Undefined{} <> stack}
    case value <> tail:
      callbackAction(w, rest, stack, id, tail, first, second, value)

def setterValue(+w: R.World, +signal: Nat, value: R.Value) -> R.World:
  match value:
    case R.RootDisposerReference{owner}:
      +w = O.disposeChildren(w, owner, True{}, False{})
      B.choose(~R.World, B.ok(w), _ => W.setSignal(w, signal, R.Undefined{}), _ => w)
    case other:
      W.setSignal(w, signal, other)

# core.ts:runWithOwner, after evaluating the user ABI's owner argument.
def enterOwnerValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value, +body: R.Expr, +prev: R.Value) -> Machine:
  match value:
    case R.Null{}:
      Machine{L.enterOwner(w, 0n), Evaluate{body, prev} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> rest, tail}
    case R.OwnerReference{id}:
      Machine{L.enterOwner(w, id), Evaluate{body, prev} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def enterOwner(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +body: R.Expr, +prev: R.Value) -> Machine:
  match stack:
    case value <> tail:
      enterOwnerValue(w, rest, tail, value, body, prev)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def checkDisposedValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.OwnerReference{id}:
      Machine{w, rest, R.Boolean{L.isDisposed(w, id)} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def checkDisposed(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      checkDisposedValue(w, rest, tail, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# owner.ts:disposeRootSelf with its bound receiver, self=true. Only actual root
# handles enter this user ABI operation; computed disposal has another source
# entry and must not be substituted for a root's dispose method.
def disposeRootValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.OwnerReference{+id}:
      B.choose(~Machine, B.root(R.Node.kind(B.node(w, id))),
        _ => Machine{O.disposeChildren(w, id, True{}, False{}), rest, R.Undefined{} <> tail},
        _ => Machine{R.World.with_fault(w, R.TypeError{}), rest, tail})
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def disposeRoot(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      disposeRootValue(w, rest, tail, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# Root init's bound disposeRootSelf(owner,true), invoked as a plain function.
def invokeValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{id}:
      Machine{O.disposeChildren(w, id, True{}, False{}), rest, R.Undefined{} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def invoke(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      invokeValue(w, rest, tail, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# signals.ts:onCleanup -> owner.ts:cleanup, selected bound disposer family.
# The source returns the very same callable, including without an owner.
def onCleanupValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{+root}:
      Machine{J.cleanup(w, R.World.context(w), root), rest, R.RootDisposerReference{root} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def onCleanup(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      onCleanupValue(w, rest, tail, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# core/context.ts argument/default-parameter seams. The value argument of a
# write is evaluated before the owner argument, as in the source call.
def contextGetAt(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, key: Nat, owner: Nat) -> Machine:
  +pair = Y.getContext(w, key, owner)
  +w = B.first(R.World, R.Value, pair)
  B.choose(~Machine, B.ok(w), _ => Machine{w, rest, B.second(R.World, R.Value, pair) <> tail}, _ => Machine{w, rest, tail})

def contextGetValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +key: Nat, owner: R.Value) -> Machine:
  match owner:
    case R.OwnerReference{id}:
      contextGetAt(w, rest, tail, key, id)
    case R.Null{}:
      contextGetAt(w, rest, tail, key, 0n)
    case R.Undefined{}:
      contextGetAt(w, rest, tail, key, R.World.context(w))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def contextGet(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +key: Nat) -> Machine:
  match stack:
    case owner <> tail:
      contextGetValue(w, rest, tail, key, owner)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def contextSetAt(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, key: Nat, value: R.Value, owner: Nat) -> Machine:
  +w = Y.setContext(w, key, value, owner)
  B.choose(~Machine, B.ok(w), _ => Machine{w, rest, R.Undefined{} <> tail}, _ => Machine{w, rest, tail})

def contextSetValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +key: Nat, +value: R.Value, owner: R.Value) -> Machine:
  match owner:
    case R.OwnerReference{id}:
      contextSetAt(w, rest, tail, key, value, id)
    case R.Null{}:
      contextSetAt(w, rest, tail, key, value, 0n)
    case R.Undefined{}:
      contextSetAt(w, rest, tail, key, value, R.World.context(w))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def contextSet(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +key: Nat) -> Machine:
  match stack:
    case owner <> value <> tail:
      contextSetValue(w, rest, tail, key, value, owner)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

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
        _ => [Update{id}], _ => B.choose(~List<&2, Task>, B.has(R.Node.config(B.node(w, reader)), K.CONFIG_FRESH_READ()), _ => [Update{id}], _ => []))
      Machine{w, B.append(Task, todo, RaiseHeight{id, reader} <> ReadStatus{id} <> rest), stack},
    _ => Machine{w, ReadStatus{id} <> rest, stack})

def afterServe(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  dormant = Bool.and(Nat.is_eq(B.parentComputed(w, R.World.context(w)), 0n), Bool.and(B.computed(R.Node.kind(n)),
    Bool.and(B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()), Bool.and(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())), Nat.is_eq(R.Node.subs(n), 0n)))))
  w = B.choose(~R.World, dormant, _ => B.schedule(G.queueDormant(w, id)), _ => w)
  Machine{w, rest, stack}

# Read event instrumentation belongs to the callback adapter, after value choice.
def served(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +value: R.Value) -> Machine:
  Machine{B.event(w, R.ReadValue{reader, id, value}), rest, value <> stack}

# Read's error/retry block follows pending handling, even for a forced frame read.
def readAnswer(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, Bool.and(B.computed(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_ERROR())),
    _ => B.choose(~Machine, Bool.and(R.World.tracking(w), Nat.is_lt(R.Node.time(n), R.World.clock(w))),
      _ => Machine{w, Recompute{id, False{}} <> ReadNode{id} <> rest, stack},
      _ => Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.error(B.extension(w, id))}), rest, stack}),
    _ => B.choose(~Machine, forced, _ => served(w, rest, stack, reader, id, R.Node.value(n)),
      _ => B.choose(~Machine, Bool.and(Nat.is_eq(reader, 0n), B.truth(R.NodeExtension.shownError(B.extension(w, id)))),
        _ => Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.shownError(B.extension(w, id))}), rest, stack},
        _ => Machine{w, Serve{id} <> AfterServe{id} <> rest, stack})))

# core/core.ts:read, after pull: held-entry, then pending/error/value selection.
def readStatus(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +pair = X.enterRead(w, reader, id, True{})
  +w = B.first(R.World, Bool, pair)
  +forced = B.second(R.World, Bool, pair)
  +n = B.node(w, id)
  +throws = Bool.and(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.and(Bool.not(forced),
    B.choose(~Bool, Nat.is_ne(reader, 0n),
      _ => Bool.or(Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())), B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())),
      _ => B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()))))
  B.choose(~Machine, throws,
    _ =>
      +w = B.choose(~R.World, Bool.and(Nat.is_ne(reader, 0n), Bool.and(Bool.not(R.World.tracking(w)), Nat.is_ne(id, reader))),
        _ => G.link(w, id, reader), _ => w)
      Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.error(B.extension(w, id))}), rest, stack},
    _ => readAnswer(w, rest, stack, id, reader, forced))

# core/core.ts:read's plain-signal fast block, under the admitted no-snapshot,
# no-verdict profile. Its source ternary intentionally stays separate from serve.
def readSignalFast(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +tracked = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, tracked, _ => G.link(w, id, reader), _ => w)
  +pair = X.enterRead(w, reader, id, False{})
  +w = B.first(R.World, Bool, pair)
  +n = B.node(w, id)
  +committed = Bool.or(B.second(R.World, Bool, pair), Bool.or(Nat.is_eq(reader, 0n), Bool.or(Bool.not(B.present(R.Node.pending(n))),
    B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN()))))
  +value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
  +w = B.choose(~R.World, committed, _ => w, _ => stagedRead(w, reader, 0n))
  served(w, rest, stack, reader, id, value)

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
      +w = B.choose(~R.World, committed, _ => w, _ => stagedRead(w, reader, id))
      B.choose(~Machine, Bool.and(Bool.not(committed), B.has(R.Node.config(n), K.CONFIG_STAGED_ERROR())),
        _ => Machine{R.World.with_fault(w, R.CallbackThrown{B.current(n)}), rest, stack},
        _ =>
          value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
          served(w, rest, stack, reader, id, value)))

# core/core.ts:serve. A born-staged plain/frame read throws NotReady(null).
def serve(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +reader = B.parentComputed(w, R.World.context(w))
  +noAnswer = Bool.and(B.present(R.Node.pending(n)), Bool.and(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()),
    Bool.or(Nat.is_eq(reader, 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN()))))
  B.choose(~Machine, noAnswer,
    _ =>
      +pair = P.notReadyError(w, 0n)
      Machine{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), rest, stack},
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
  +w = B.choose(~R.World, Bool.and(Nat.is_ge(height, R.Node.height(c)), Nat.is_ne(R.Node.parent(B.node(w, source)), reader)),
    _ => B.store_node(w, reader, R.Node.with_height(c, 1n+height)), _ => w)
  +w = B.choose(~R.World, Bool.not(B.effect(R.Node.kind(B.node(w, reader)))),
    _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), U32.and(R.Node.config(B.node(w, source)), K.CONFIG_VERDICT())))), _ => w)
  Machine{w, rest, stack}

def update(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, B.has(R.Node.flags(n), 68), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, B.has(R.Node.flags(n), 1),
      _ => Machine{w, CheckDeps{id, R.Node.deps(n)} <> AfterCheck{id} <> rest, stack},
      _ => Machine{w, AfterCheck{id} <> rest, stack}))

def checkDeps(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +edge: Nat) -> Machine:
  B.choose(~Machine, Nat.is_eq(edge, 0n),
    _ => Machine{w, rest, stack},
    _ =>
      +e = B.link(w, edge)
      +dep = R.Link.dep(e)
      todo = B.choose(~List<&2, Task>, B.computed(R.Node.kind(B.node(w, dep))), _ => [Update{dep}], _ => [])
      Machine{w, B.append(Task, todo, CheckNext{id, edge} <> rest), stack})

def afterCheck(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  todo = B.choose(~List<&2, Task>, Bool.or(B.has(R.Node.flags(B.node(w, id)), 2), Bool.and(B.truth(R.NodeExtension.error(B.extension(w, id))), Bool.and(Nat.is_lt(R.Node.time(B.node(w, id)), R.World.clock(w)), Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), 0n)))), _ => [Recompute{id, False{}}], _ => [])
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
      +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.reenterHeld(w, id), _ => w)
      B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED()),
          _ => O.disposeChildren(w, id, False{}, False{}),
          _ => B.choose(~R.World, Bool.or(Nat.is_ne(R.Node.firstChild(B.node(w, id)), 0n), Bool.not(B.noDisposal(R.Node.disposal(B.node(w, id))))),
            _ => O.parkChildren(w, id), _ => w)),
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
  frame = {PassFrame{id, create, context, R.World.tracking(w), R.Node.height(n), reask, B.current(n), B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()),
    B.choose(~R.Value, B.has(R.Node.status(n), K.STATUS_ERROR()), _ => R.NodeExtension.error(B.extension(w, id)), _ => R.Undefined{}),
    B.choose(~Nat, B.has(R.Node.status(n), K.STATUS_PENDING()), _ => R.NodeExtension.pendingSources(B.extension(w, id)), _ => 0n),
    P.hasSource(w, id, id), R.NodeExtension.inFlight(B.extension(w, id)), stack} : PassFrame}
  next = {Evaluate{R.Node.expr(n), B.current(n)} <> Finish{frame} <> rest : List<&2, Task>}
  w = R.World.with_tracking(B.event(w, R.Invoked{id}), True{})
  Machine{w, next, stack}

def recompute(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +w = B.bump(w)
  +w = B.choose(~R.World, create, _ => w, _ => prepareRecompute(w, id))
  B.choose(~Machine, B.ok(w), _ => recomputePrepared(w, rest, stack, id, create), _ => Machine{w, rest, stack})

# Source loops over a captured Set handle, not a copied member list. Its live
# cursor skips deleted slots and observes appends, as JS Set iteration does.
def retireSources(fuel: Nat, +w: R.World, +id: Nat, +set: Nat, +index: Nat, +onlyDropped: Bool) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, B.pendingSlots(w, set))), _ => w,
        _ =>
          +source = B.get(Nat, B.pendingSlots(w, set), index, 0n)
          +skip = Bool.or(Nat.is_eq(source, 0n), Bool.or(Nat.is_eq(source, id), Bool.and(onlyDropped, P.hasSource(w, id, source))))
          +w = B.choose(~R.World, skip, _ => w, _ => Q.settlePendingSource(w, id, source))
          B.choose(~R.World, B.ok(w), _ => retireSources(p, w, id, set, 1n+index, onlyDropped), _ => w))

def retireOutgoing(+w: R.World, id: Nat, +set: Nat, onlyDropped: Bool) -> R.World:
  retireSources(1n+Nat.add(B.budget(w), B.length(Nat, B.pendingSlots(w, set))), w, id, set, 0n, onlyDropped)

# No lane engine is installed: only joined/creator-pass posture makes a new
# value belong to flushTransaction/passTx (core.ts's born-held value arm).
def bornHeld(+w: R.World, joined: Bool) -> Bool:
  Bool.and(Bool.or(Nat.is_ne(R.World.flushTransaction(w), 0n), Nat.is_ne(R.World.passTx(w), 0n)),
    Bool.or(joined, B.has(R.Node.flags(B.node(w, B.parentComputed(w, R.World.context(w)))), K.REACTIVE_JOINED())))

def publicationTx(+w: R.World) -> Nat:
  B.choose(~Nat, Nat.is_ne(R.World.flushTransaction(w), 0n), _ => R.World.flushTransaction(w), _ => R.World.passTx(w))

def publishValue(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, wasUninitialized: Bool, +joined: Bool) -> B.Bundle<R.World, Bool>:
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
      +direct = B.choose(~Bool, create, _ => Bool.not(bornHeld(w, joined)), _ => Bool.and(isEffect, Bool.not(B.present(R.Node.pending(B.node(w, id))))))
      +w = B.choose(~R.World, direct,
        _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
        _ =>
          +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
          B.choose(~R.World, create,
            _ =>
              +w = X.holdNode(w, id, publicationTx(w))
              B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))), _ => w))
      B.choose(~R.World, Nat.is_ne(R.Node.subs(n), 0n), _ => S.insertSubs(w, id), _ => w),
    _ => B.choose(~R.World, Nat.is_ne(R.Node.height(B.node(w, id)), oldHeight),
      _ => H.height_subs(B.budget(w), w, R.Node.subs(n)), _ => w))
  B.Bundle{w, changed}

def finishPublication(+w: R.World, +id: Nat, +create: Bool, joined: Bool) -> R.World:
  +w = B.choose(~R.World, Bool.and(create, Bool.and(joined, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))),
    _ =>
      +t = publicationTx(w)
      B.choose(~R.World, Bool.and(Nat.is_ne(t, 0n), Bool.not(R.Transaction.lane(B.transaction(w, t)))), _ => X.holdNode(w, id, t), _ => w), _ => w)
  +n = B.node(w, id)
  +w = B.choose(~R.World, Bool.and(Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))), Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.not(R.Node.modified(n)))),
    _ => B.choose(~R.World, create, _ => G.trimStaleDeps(w, id),
      _ => R.World.with_trims(w, B.append(Nat, R.World.trims(w), [id]))), _ => w)
  B.choose(~R.World, B.ok(w),
    _ =>
      +n = B.node(w, id)
      queued = Bool.or(B.present(R.Node.pending(n)), Bool.or(O.parked(w, id),
        Bool.and(B.has(R.Node.status(n), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED())), Bool.or(Bool.not(create), B.has(R.Node.status(n), K.STATUS_PENDING())))))
      B.choose(~R.World, queued, _ => S.queuePendingNode(B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), K.CONFIG_STAGED()))), id), _ => w),
    _ => w)


def publish(+w: R.World, +id: Nat, value: R.Value, +create: Bool, oldHeight: Nat, wasUninitialized: Bool, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +joined: Bool, stagedErr: Bool) -> R.World:
  errored = Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), stagedErr)
  +w = B.choose(~R.World, errored, _ => w,
    _ =>
      +pair = publishValue(w, id, value, create, oldHeight, wasUninitialized, joined)
      +w = B.first(R.World, Bool, pair)
      +changed = B.second(R.World, Bool, pair)
      +w = B.choose(~R.World, Bool.and(Bool.not(changed), Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id))))),
        _ =>
          +w = B.choose(~R.World, B.equal(outgoing, R.Undefined{}), _ => w, _ => A.settleErroredDependents(w, id, outgoing))
          retireOutgoing(w, id, outgoingSources, False{}), _ => w)
      B.choose(~R.World, Bool.and(B.ok(w), Bool.and(wasPendingSource, Bool.not(B.has(R.Node.status(B.node(w, id)), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED()))))),
        _ => Q.settlePendingSource(w, id, id), _ => w))
  B.choose(~R.World, B.ok(w), _ => finishPublication(w, id, create, joined), _ => w)

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

def afterPass(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, create: Bool, value: R.Value, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, joined: Bool, stagedErr: Bool, missed: Bool) -> Machine:
  B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()),
    _ =>
      +w = G.clearDeps(w, id)
      w = B.choose(~R.World, Bool.and(B.ok(w), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      Machine{w, rest, stack},
    _ =>
      +w = publish(w, id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr)
      w = B.choose(~R.World, Bool.and(B.ok(w), missed), _ => B.schedule(H.enqueueSub(w, id)), _ => w)
      Machine{w, rest, stack})

def finishValue(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +create: Bool, context: Nat, tracking: Bool, oldHeight: Nat, reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, oldFlight: Nat, saved: List<&2, R.Value>, +keepFlight: Bool) -> Machine:
  match stack:
    case value <> +tail:
      +w = B.choose(~R.World, Bool.and(Bool.not(keepFlight), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      +w = B.choose(~R.World, keepFlight, _ => w, _ => B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})))
      +w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => A.clearStatus(w, id, create), _ => w)
      +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
      +joined = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED())
      +w = passFinally(w, id, create, context, tracking, reask)
      B.choose(~Machine, B.ok(w),
        _ => afterPass(w, rest, tail, id, create, value, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, False{}, missed),
        _ => Machine{w, rest, tail})
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def finishReady(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: PassFrame, keepFlight: Bool) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved}:
      finishValue(w, rest, stack, id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, keepFlight)

# .then invokes immediate callbacks in the live compute frame; native-style
# callbacks enter through the host outbox after that frame has returned.
def subscribeState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +observer: Nat, +immediate: Bool, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      Machine{w, AfterThen{frame, observer} <> rest, stack}
    case R.Fulfilled{+value}:
      B.choose(~Machine, immediate,
        _ => Machine{w, AsyncFulfill{observer, value} <> AfterThen{frame, observer} <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, observer, False{}, value), AfterThen{frame, observer} <> rest, stack})
    case R.Rejected{+error}:
      B.choose(~Machine, immediate,
        _ => Machine{w, AsyncReject{observer, error} <> AfterThen{frame, observer} <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, observer, True{}, error), AfterThen{frame, observer} <> rest, stack})

# Source assignment boundaries are explicit return points. They do not yield
# to host jobs: the same run continues to the .then call before returning.
def subscribe(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: PassFrame, id: Nat, result: Nat) -> Machine:
  Machine{w, RegisterFlight{frame, id, result} <> rest, stack}


# handleAsync:consumeIterator. The close callback belongs to the ambient
# owner for LIVE consumption, and directly to el for deferred flattening.
def consumeIterator(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, result: Nat, source: Nat, +deferred: Bool, initialValue: R.Value) -> Machine:
  +pair = I.newStream(w, id, result, source, deferred, initialValue)
  +w = B.first(R.World, Nat, pair)
  +stream = B.second(R.World, Nat, pair)
  +close = R.StreamState.close(B.stream(w, stream))
  +w = O.cleanup(w, B.choose(~Nat, deferred, _ => id, _ => R.World.context(w)), close)
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), close))
  Machine{w, IterateStream{stream} <> AfterConsume{stream} <> rest, stack}

def finishAsyncObject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +id: Nat, +result: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ne(R.AsyncObject.stream(B.asyncObject(w, result)), 0n),
    _ => consumeIterator(F.startFlight(w, id, result), AfterIterator{frame} <> rest, stack, id, result, result, False{}, R.Undefined{}),
    _ => subscribe(w, rest, stack, frame, id, result))

def finishShape(w: R.World, rest: List<&2, Task>, +stack: List<&2, R.Value>, frame: PassFrame, id: Nat) -> Machine:
  match stack:
    case R.AsyncValue{result} <> tail:
      finishAsyncObject(w, rest, tail, frame, id, result)
    case _:
      finishReady(w, rest, stack, frame, False{})

def finishResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +id: Nat, oldFlight: Nat) -> Machine:
  +selfRegistered = Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), oldFlight)
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SYNC()),
    _ => finishReady(w, rest, stack, frame, False{}),
    _ => B.choose(~Machine, selfRegistered, _ => finishReady(w, rest, stack, frame, True{}),
      _ => finishShape(w, rest, stack, frame, id)))

def finish(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame) -> Machine:
  match frame:
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, +flight, saved}:
      finishResult(w, rest, stack, frame, id, flight)

# Body throw -> source catch -> finally -> publication tail, with the caller's
# value stack restored. A throw from the prelude has no frame of its own here.
# recompute's pending/error catch. The loading-window arm changes neither
# read-visible status nor propagation. Replacement-source retirement follows
# successful notification, before the caller's finally frame.
def catchStatus(+w: R.World, +id: Nat, fault: R.Fault, +wasPendingSource: Bool, +outgoingSources: Nat) -> B.Bundle<R.World, Bool>:
  match fault:
    case R.CallbackThrown{+cause}:
      +w = R.World.with_fault(w, R.Healthy{})
      +notReady = P.isNotReady(cause)
      B.choose(~B.Bundle<R.World, Bool>, Bool.and(notReady, R.Node.loading(B.node(w, id))),
        _ => B.Bundle{P.parkLoadingWindow(w, id, cause), False{}},
        _ =>
          +pair = B.choose(~B.Bundle<R.World, Bool>, notReady, _ => B.Bundle{w, False{}}, _ => Q.stageError(w, id, cause, True{}))
          +w = B.first(R.World, Bool, pair)
          +stagedErr = B.second(R.World, Bool, pair)
          +w = B.choose(~R.World, Bool.or(notReady, Bool.not(stagedErr)),
            _ =>
              +w = B.choose(~R.World, notReady,
                _ =>
                  +w = E.ext(w, id)
                  B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{True{}}})), _ => w)
              +w = A.notifyStatusWith(w, id, B.choose(~U32, notReady, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), cause, False{})
              B.choose(~R.World, Bool.and(B.ok(w), Bool.and(notReady, Bool.and(wasPendingSource, Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), 0n)))),
                _ => Q.settlePendingSource(w, id, id), _ => w), _ => w)
          +w = B.choose(~R.World, Bool.and(B.ok(w), Bool.or(notReady, stagedErr)), _ => retireOutgoing(w, id, outgoingSources, True{}), _ => w)
          B.Bundle{w, stagedErr})
    case other:
      B.Bundle{w, False{}}

def catchValue(+w: R.World, +rest: List<&2, Task>, +id: Nat, +create: Bool, context: Nat, tracking: Bool, oldHeight: Nat, reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, oldFlight: Nat, +saved: List<&2, R.Value>) -> Machine:
  +pair = catchStatus(w, id, R.World.fault(w), wasPendingSource, outgoingSources)
  +w = B.first(R.World, Bool, pair)
  +stagedErr = B.second(R.World, Bool, pair)
  +joined = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED())
  +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
  +w = passFinally(w, id, create, context, tracking, reask)
  B.choose(~Machine, B.ok(w),
    _ => afterPass(w, rest, saved, id, create, previous, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr, missed),
    _ => Machine{w, rest, saved})

def catchPass(w: R.World, rest: List<&2, Task>, frame: PassFrame) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved}:
      catchValue(w, rest, id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved)

# handleAsync's post-.then verdict, still inside recompute's try/catch.
def iterable(+w: R.World, value: R.Value) -> Nat:
  match value:
    case R.AsyncValue{+id}:
      B.choose(~Nat, Nat.is_ne(R.AsyncObject.stream(B.asyncObject(w, id)), 0n), _ => id, _ => 0n)
    case _:
      0n

# The shared LIVE tail: a first yield or empty completion is a real answer;
# no synchronous answer returns the seed or throws NotReady inside the pass.
def afterIterator(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame) -> Machine:
  match stack:
    case R.StreamVerdict{+stream, landed, +value} <> +tail:
      +id = R.StreamState.node(B.stream(w, stream))
      B.choose(~Machine, landed,
        _ => finishReady(B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), rest, value <> tail, frame, True{}),
        _ => B.choose(~Machine, R.Node.loading(B.node(w, id)),
          _ => finishReady(w, rest, R.Node.value(B.node(w, id)) <> tail, frame, True{}),
          _ =>
            +pair = P.notReadyError(w, R.World.context(w))
            catchPass(R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), rest, frame)))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# .then returned; a synchronously fulfilled iterable is flattened LIVE using
# the same syncValue local (including the immediately empty source branch).
def afterThen(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +observer: Nat) -> Machine:
  +o = B.asyncObserver(w, observer)
  +source = iterable(w, R.AsyncObserver.syncValue(o))
  B.choose(~Machine, Bool.and(Bool.not(R.AsyncObserver.rejected(o)), Bool.and(R.AsyncObserver.resolved(o), Nat.is_ne(source, 0n))),
    _ =>
      +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
      consumeIterator(w, AfterIterator{frame} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), source, False{}, R.AsyncObserver.syncValue(o)),
    _ =>
      +pair = F.thenResult(w, observer)
      +w = B.first(R.World, R.Value, pair)
      B.choose(~Machine, B.ok(w),
        _ => finishReady(w, rest, B.second(R.World, R.Value, pair) <> stack, frame, True{}),
        _ => catchPass(w, rest, frame)))

# One next(). Bare IteratorResult is assimilated by the source's immediate
# then adapter; the same observer locals therefore serve all next shapes.
def subscribeStepState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +immediate: Bool, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      Machine{w, AfterStep{observer} <> rest, stack}
    case R.Fulfilled{+value}:
      B.choose(~Machine, immediate,
        _ => Machine{w, AsyncFulfill{observer, value} <> AfterStep{observer} <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, observer, False{}, value), AfterStep{observer} <> rest, stack})
    case R.Rejected{+error}:
      B.choose(~Machine, immediate,
        _ => Machine{w, AsyncReject{observer, error} <> AfterStep{observer} <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, observer, True{}, error), AfterStep{observer} <> rest, stack})

def nextInput(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +stream: Nat, input: R.NextInput) -> Machine:
  match input:
    case R.ThrowNext{error}:
      Machine{R.World.with_fault(w, R.CallbackThrown{error}), rest, stack}
    case R.BareNext{done, value}:
      +pair = I.newStepObserver(w, stream)
      +observer = B.second(R.World, Nat, pair)
      Machine{B.first(R.World, Nat, pair), AsyncFulfill{observer, R.StepResult{done, value}} <> AfterStep{observer} <> rest, stack}
    case R.PromiseNext{+result}:
      +pair = I.newStepObserver(w, stream)
      +w = B.first(R.World, Nat, pair)
      +observer = B.second(R.World, Nat, pair)
      +object = B.asyncObject(w, result)
      +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))
      subscribeStepState(w, rest, stack, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object))

def iterateStream(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  +pair = I.next(w, stream)
  nextInput(B.first(R.World, R.NextInput, pair), rest, stack, stream, B.second(R.World, R.NextInput, pair))

def afterStepResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +stream: Nat, +resolved: Bool, result: R.Value) -> Machine:
  match result:
    case R.StepResult{+done, value}:
      B.choose(~Machine, Bool.and(resolved, Bool.not(done)),
        _ =>
          +w = B.store_stream(w, stream, R.StreamState.with_hadValue(R.StreamState.with_syncValue(B.stream(w, stream), value), True{}))
          Machine{w, IterateStream{stream} <> rest, stack},
        _ => Machine{w, rest, R.Boolean{Bool.and(resolved, done)} <> stack})
    case _:
      Machine{w, rest, R.Boolean{False{}} <> stack}

def afterStep(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat) -> Machine:
  +o = B.asyncObserver(w, observer)
  +stream = R.AsyncObserver.stream(o)
  +s = B.stream(w, stream)
  +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
  B.choose(~Machine, R.AsyncObserver.rejected(o),
    _ =>
      +w = B.store_stream(w, stream, R.StreamState.with_completed(s, True{}))
      +w = F.handleError(w, R.StreamState.node(s), R.StreamState.result(s), R.AsyncObserver.syncError(o))
      +w = B.choose(~R.World, Bool.and(B.ok(w), R.StreamState.initialRead(s)), _ => R.World.with_fault(w, R.CallbackThrown{R.AsyncObserver.syncError(o)}), _ => w)
      Machine{w, rest, R.Boolean{True{}} <> stack},
    _ => afterStepResult(w, rest, stack, stream, R.AsyncObserver.resolved(o), R.AsyncObserver.syncValue(o)))

def afterConsume(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  match stack:
    case R.Boolean{done} <> tail:
      +s = B.stream(w, stream)
      +w = B.store_stream(w, stream, R.StreamState.with_initialRead(s, False{}))
      Machine{w, rest, R.StreamVerdict{stream, Bool.or(R.StreamState.hadValue(s), done), R.StreamState.syncValue(s)} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def stepDone(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  +s = B.stream(w, stream)
  +id = R.StreamState.node(s)
  +w = B.store_stream(w, stream, R.StreamState.with_completed(s, True{}))
  B.choose(~Machine, R.StreamState.hadValue(s),
    _ => Machine{B.schedule(w), AsyncFlush{} <> SettleAuto{id} <> rest, stack},
    _ =>
      +pair = F.asyncWrite(w, id, R.StreamState.result(s), R.Undefined{})
      Machine{B.first(R.World, Bool, pair), B.choose(~List<&2, Task>, B.second(R.World, Bool, pair),
        _ => AsyncFlush{} <> SettleAuto{id} <> rest, _ => SettleAuto{id} <> rest), stack})

def stepFulfilledResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, result: R.Value) -> Machine:
  match result:
    case R.StepResult{+done, +value}:
      +o = B.asyncObserver(w, observer)
      +stream = R.AsyncObserver.stream(o)
      +s = B.stream(w, stream)
      +id = R.StreamState.node(s)
      B.choose(~Machine, Bool.and(R.AsyncObserver.isSync(o), R.StreamState.initialRead(s)),
        _ =>
          +w = F.syncFulfilled(w, observer, R.StepResult{done, value})
          +w = B.choose(~R.World, done, _ => B.store_stream(w, stream, R.StreamState.with_completed(B.stream(w, stream), True{})), _ => w)
          Machine{w, rest, stack},
        _ => B.choose(~Machine, Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), R.StreamState.result(s)), _ => Machine{w, rest, stack},
          _ => B.choose(~Machine, done, _ => stepDone(w, rest, stack, stream),
            _ =>
              +w = B.store_stream(w, stream, R.StreamState.with_hadValue(s, True{}))
              +pair = F.asyncWrite(w, id, R.StreamState.result(s), value)
              Machine{B.first(R.World, Bool, pair), B.choose(~List<&2, Task>, B.second(R.World, Bool, pair),
                _ => AsyncFlush{} <> IterateOrRelease{stream} <> rest, _ => rest), stack})))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}

def stepRejected(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +error: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  +stream = R.AsyncObserver.stream(o)
  +s = B.stream(w, stream)
  +id = R.StreamState.node(s)
  B.choose(~Machine, Bool.and(R.AsyncObserver.isSync(o), R.StreamState.initialRead(s)), _ => Machine{F.syncRejected(w, observer, error), rest, stack},
    _ => B.choose(~Machine, Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), R.StreamState.result(s)),
      _ =>
        +w = B.store_stream(w, stream, R.StreamState.with_completed(s, True{}))
        Machine{F.handleError(w, id, R.StreamState.result(s), error), SettleAuto{id} <> rest, stack},
      _ => Machine{w, rest, stack}))

def promiseFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  +id = R.AsyncObserver.node(o)
  +source = iterable(w, value)
  B.choose(~Machine, R.AsyncObserver.isSync(o), _ => Machine{F.syncFulfilled(w, observer, value), rest, stack},
    _ => B.choose(~Machine, Bool.and(Nat.is_ne(source, 0n), Bool.and(Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), R.AsyncObserver.result(o)), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())))),
      _ => consumeIterator(w, Discard{} <> rest, stack, id, R.AsyncObserver.result(o), source, True{}, R.Undefined{}),
      _ =>
        +pair = F.asyncWrite(w, id, R.AsyncObserver.result(o), value)
        Machine{B.first(R.World, Bool, pair), B.choose(~List<&2, Task>, B.second(R.World, Bool, pair),
          _ => AsyncFlush{} <> SettleAuto{id} <> rest,
          _ => SettleAuto{id} <> rest), stack}))

def asyncFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(R.AsyncObserver.node(B.asyncObserver(w, observer)), 0n), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_ne(R.AsyncObserver.stream(B.asyncObserver(w, observer)), 0n),
      _ => stepFulfilledResult(w, rest, stack, observer, value), _ => promiseFulfill(w, rest, stack, observer, value)))

def promiseReject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +error: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  B.choose(~Machine, R.AsyncObserver.isSync(o), _ => Machine{F.syncRejected(w, observer, error), rest, stack},
    _ => Machine{F.handleError(w, R.AsyncObserver.node(o), R.AsyncObserver.result(o), error), SettleAuto{R.AsyncObserver.node(o)} <> rest, stack})

def asyncReject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +error: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(R.AsyncObserver.node(B.asyncObserver(w, observer)), 0n), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_ne(R.AsyncObserver.stream(B.asyncObserver(w, observer)), 0n),
      _ => stepRejected(w, rest, stack, observer, error), _ => promiseReject(w, rest, stack, observer, error)))

def deliverObservers(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, observers: List<&2, Nat>, +immediate: Bool, +rejected: Bool, +value: R.Value) -> Machine:
  match observers:
    case Nil{}:
      Machine{w, rest, stack}
    case +id <> +tail:
      +again = {DeliverObservers{tail, immediate, rejected, value} : Task}
      B.choose(~Machine, immediate,
        _ => Machine{w, B.choose(~Task, rejected, _ => AsyncReject{id, value}, _ => AsyncFulfill{id, value}) <> again <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, id, rejected, value), again <> rest, stack})

# effect.ts:runEffect's catch constructs a fresh wrapper and rethrows raw.
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
def userError(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = B.store_node(w, id, R.Node.with_prevValue(B.node(w, id), R.Node.value(B.node(w, id))))
  +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{}))
  +program = R.Node.errorProgram(B.node(w, id))
  +param = R.World.callbackEffect(w)
  B.choose(~Machine, Nat.is_ne(program, 0n),
    _ => Machine{R.World.with_callbackEffect(w, id), Evaluate{R.CallWith{program, R.Literal{A.unwrapStatusError(R.NodeExtension.error(B.extension(w, id)))}, R.Literal{R.Undefined{}}}, R.Undefined{}} <> Discard{} <> ErrorArmFinally{param, stack} <> rest, stack},
    _ => Machine{B.report(w, 2, R.Present{A.unwrapStatusError(R.NodeExtension.error(B.extension(w, id)))}), rest, stack})

# core/effect.ts:runEffect's finally after its callback/previous-cleanup catch.
# A nested read can run a full compute pass; the caller's stack is restored on
# both success and throw, just as at a recompute return boundary.
def effectFinally(+w: R.World, rest: List<&2, Task>, +id: Nat, clean: Bool, saved: List<&2, R.Value>) -> Machine:
  +w = effectCatch(w, id, R.World.fault(w))
  +w = B.store_node(w, id, R.Node.with_prevValue(B.node(w, id), R.Node.value(B.node(w, id))))
  +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{}))
  w = B.choose(~R.World, clean, _ => trimFinally(w, id, R.World.fault(w)), _ => w)
  Machine{w, rest, saved}

# The adapter's _effectFn records the application, executes the named body,
# and returns the separate cleanup token. A body's ordinary return is ignored.
def applyEffect(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = B.event(w, R.Applied{id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id))})
  +w = B.choose(~R.World, S.is_user(R.Node.kind(B.node(w, id))), _ => w,
    _ => T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))))
  +callback = R.Node.effectProgram(B.node(w, id))
  +todo = B.choose(~List<&2, Task>, Nat.is_ne(callback, 0n),
    _ => [Evaluate{R.CallWith{callback, R.Literal{R.Node.value(B.node(w, id))}, R.Literal{R.Node.prevValue(B.node(w, id))}}, R.Undefined{}}, Discard{}], _ => [])
  Machine{w, B.append(Task, todo, InstallEffectCleanup{id} <> rest), stack}

# core/effect.ts:runEffect. The pre-cleanup call and finally retain their source
# order; callback reads resume this machine rather than a second read engine.
def runEffect(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, Bool.and(R.Node.modified(n), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))),
    _ => B.choose(~Machine, Bool.and(S.is_user(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_ERROR())),
      _ => userError(w, rest, stack, id),
      _ =>
        +clean = B.nullish(R.NodeExtension.error(B.extension(w, id)))
        +prevCleanup = R.Node.cleanup(n)
        +w = B.store_node(w, id, R.Node.with_cleanup(n, 0n))
        +w = B.choose(~R.World, Nat.is_ne(prevCleanup, 0n), _ => O.invoke(w, prevCleanup), _ => w)
        Machine{w, ApplyEffect{id} <> EffectFinally{id, clean, stack} <> rest, stack}),
    _ => Machine{w, rest, stack})

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
          _ => B.choose(~Machine, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_LANE_DIRTY()))),
            _ => Machine{S.deferZombie(w, id), HeapLoop{} <> rest, stack},
            _ => Machine{w, Recompute{id, False{}} <> HeapLoop{} <> rest, stack}),
          _ => Machine{H.adjustHeight(w, id), HeapLoop{} <> rest, stack})))

def round(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +w = R.World.with_running(w, True{})
  +w = V.resyncUnflushedCompanions(w)
  +w = R.World.with_passTx(R.World.with_passLane(w, 0n), 0n)
  +w = G.sweepDormant(w)
  B.choose(~Machine, B.ok(w),
    _ =>
      w = R.World.with_marked(w, False{})
      w = R.World.with_minimum(w, 0n)
      Machine{w, HeapLoop{} <> FlushFinally{} <> RoundEnd{} <> rest, stack},
    _ => Machine{w, FlushFinally{} <> RoundEnd{} <> rest, stack})

# scheduler.ts:GlobalQueue.settle, before the transaction landing loop.
def beginSettle(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +joined = R.World.flushTransaction(w)
  +w = R.World.with_flushTransaction(w, 0n)
  +pair = B.choose(~B.Bundle<R.World, Nat>, Bool.and(Nat.is_ne(joined, 0n), Bool.not(R.Transaction.lane(B.transaction(w, joined)))),
    _ => X.resolveTx(w, joined), _ => B.Bundle{w, 0n})
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  +w = B.choose(~R.World, Nat.is_ne(t, 0n),
    _ =>
      +w = S.parkPendingNodes(w, t)
      B.choose(~R.World, B.ok(w), _ => R.World.with_deferredZombies(w, []), _ => w),
    _ => S.settle(w))
  B.choose(~Machine, B.ok(w),
    _ =>
      +w = R.World.with_trims(w, [])
      frame = {SeamFrame{t, R.World.renderQueue(w), R.World.userQueue(w)} : SeamFrame}
      +w = R.World.with_renderQueue(R.World.with_userQueue(w, []), [])
      Machine{w, LandTransactions{frame, B.length(Nat, R.World.transactions(w))} <> rest, stack},
    _ => Machine{w, rest, stack})

# Reverse scan restarts after each landing, since its commits can remove a
# zombie another transaction was blocked on, or a cleanup can register a join.
def landTransactions(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: SeamFrame, remaining: Nat) -> Machine:
  match remaining:
    case 0n:
      Machine{w, CompleteSettle{frame} <> rest, stack}
    case 1n+ +index:
      +t = B.get(Nat, R.World.transactions(w), index, 0n)
      +pair = X.blocked(w, t)
      +w = B.first(R.World, Bool, pair)
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => Machine{w, LandTransactions{frame, index} <> rest, stack},
        _ =>
          +w = R.World.with_transactions(w, X.removeIdentity(R.World.transactions(w), t))
          +w = S.reruns(w, t)
          # A non-null mark array requires the installed affects release hook.
          +w = B.choose(~R.World, B.ok(w),
            _ => B.choose(~R.World, X.noMarks(R.Transaction.marks(B.transaction(w, t))), _ => w, _ => R.World.with_fault(w, R.Unsupported{10n})), _ => w)
          Machine{w, LandNodes{frame, t, 0n} <> rest, stack})

def landNodes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: SeamFrame, +t: Nat, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, t)))),
    _ => Machine{w, LandEnd{frame, t} <> rest, stack},
    _ =>
      +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, t)), index, 0n)
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), 0n),
        _ =>
          +pair = X.txOf(w, id)
          B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), t)},
        _ => B.Bundle{w, False{}})
      +w = B.first(R.World, Bool, pair)
      w = B.choose(~R.World, B.second(R.World, Bool, pair),
        _ => S.commitPendingNode(B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n)), id), _ => w)
      Machine{w, LandNodes{frame, t, 1n+index} <> rest, stack})

def landEnd(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: SeamFrame, +t: Nat) -> Machine:
  +w = B.choose(~R.World, Nat.is_eq(R.World.flushTransaction(w), t), _ => R.World.with_flushTransaction(w, 0n), _ => w)
  +w = S.releaseQueues(w, t)
  Machine{w, LandTransactions{frame, B.length(Nat, R.World.transactions(w))} <> rest, stack}

def completeSettle(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: SeamFrame) -> Machine:
  match frame:
    case SeamFrame{+t, +renders, +users}:
      +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(t, 0n), _ => X.liveTx(w, t), _ => B.Bundle{w, 0n})
      +w = B.first(R.World, Nat, pair)
      +live = B.second(R.World, Nat, pair)
      +w = B.choose(~R.World, Nat.is_ne(live, 0n),
        _ =>
          +w = B.store_transaction(w, live, R.Transaction.with_renderQueue(B.transaction(w, live), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, live)), renders)))
          B.store_transaction(w, live, R.Transaction.with_userQueue(B.transaction(w, live), B.append(Nat, R.Transaction.userQueue(B.transaction(w, live)), users))),
        _ =>
          +w = R.World.with_renderQueue(w, B.append(Nat, renders, R.World.renderQueue(w)))
          R.World.with_userQueue(w, B.append(Nat, users, R.World.userQueue(w))))
      zombies = S.sortHeights(w, R.World.deferredZombies(w))
      Machine{R.World.with_deferredZombies(w, []), ZombieLoop{zombies} <> rest, stack}

# Only source survivors run, after all commits and queue ordering.
def zombieLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, nodes: List<&2, Nat>) -> Machine:
  match nodes:
    case Nil{}:
      Machine{w, rest, stack}
    case +id <> +tail:
      B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()),
        _ => Machine{w, ZombieLoop{tail} <> rest, stack},
        _ => Machine{w, Recompute{id, False{}} <> ZombieLoop{tail} <> rest, stack})

# GlobalQueue.flush resumes only after the complete settle operation returns.
def afterSettle(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  +w = R.World.with_clock(w, 1n+R.World.clock(w))
  w = R.World.with_scheduled(w, Bool.or(Nat.is_ge(R.World.maximum(w), R.World.minimum(w)), Bool.not(List.is_empty(&2, Nat, R.World.pendingNodes(w)))))
  Machine{w, RenderQueue{} <> rest, stack}

# signals.ts:watch's catch: NotReady remains a compute throw; real errors
# become microtask rejection answers, unwrapped once. Partial expression values
# are discarded when unwinding the user's callback.
def watchCause(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, awaiter: Nat, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{+cause}:
      B.choose(~Machine, P.isNotReady(cause), _ => Machine{w, rest, saved},
        _ => Machine{U.queueAnswer(R.World.with_fault(w, R.Healthy{}), awaiter, True{}, U.unwrap(cause)), rest, R.Undefined{} <> saved})
    case _:
      Machine{w, rest, saved}

def watchFinish(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +awaiter: Nat) -> Machine:
  match stack:
    case +value <> +tail:
      +target = R.Awaiter.target(B.awaiter(w, awaiter))
      B.choose(~Machine, Bool.and(R.Awaiter.refresh(B.awaiter(w, awaiter)), Bool.and(B.has(R.Node.config(B.node(w, target)), K.CONFIG_GUESS()), B.has(R.Node.status(B.node(w, target)), B.set(K.STATUS_PENDING(), K.STATUS_ERROR())))),
        _ => watchCause(w, rest, tail, awaiter, R.CallbackThrown{R.NodeExtension.error(B.extension(w, target))}),
        _ => Machine{U.queueAnswer(w, awaiter, False{}, value), rest, R.Undefined{} <> tail})
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def dispatch(+w: R.World, tasks: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case WatchFinish{awaiter, saved} <> rest:
      watchFinish(w, rest, stack, awaiter)
    case Evaluate{expr, prev} <> +rest:
      evaluate(w, rest, stack, expr, prev)
    case Callback{id, actions, first, second} <> rest:
      callback(w, rest, stack, id, first, second, actions)
    case CallArguments{+id} <> +rest:
      match stack:
        case second <> first <> +tail:
          B.choose(~Machine, Bool.and(Nat.is_ne(id, 0n), Nat.is_lt(id, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
            _ => Machine{w, Callback{id, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), id, R.CleanupProgram{[]})), first, second} <> rest, tail},
            _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), rest, tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case Invoke{} <> rest:
      invoke(w, rest, stack)
    case OnCleanup{} <> rest:
      onCleanup(w, rest, stack)
    case CallbackWrite{+signal, updater} <> rest:
      match stack:
        case +value <> tail:
          Machine{B.choose(~R.World, updater, _ => W.setSignal(w, signal, value), _ => setterValue(w, signal, value)), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case CallbackThrow{} <> rest:
      match stack:
        case value <> tail:
          Machine{R.World.with_fault(w, R.CallbackThrown{value}), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
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
    case EnterOwner{body, previous} <> rest:
      enterOwner(w, rest, stack, body, previous)
    case RestoreContext{owner, tracking} <> rest:
      Machine{L.restore(w, owner, tracking), rest, stack}
    case CheckDisposed{} <> rest:
      checkDisposed(w, rest, stack)
    case DisposeRoot{} <> rest:
      disposeRoot(w, rest, stack)
    case ContextGet{key} <> rest:
      contextGet(w, rest, stack, key)
    case ContextSet{key} <> rest:
      contextSet(w, rest, stack, key)
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
    case CheckNext{+id, +edge} <> +rest:
      B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DIRTY()), _ => Machine{w, rest, stack},
        _ => Machine{w, CheckDeps{id, R.Link.nextDep(B.link(w, edge))} <> rest, stack})
    case AfterCheck{id} <> +rest:
      afterCheck(w, rest, stack, id)
    case ClearFlags{+id} <> +rest:
      +keep = B.set(K.REACTIVE_SNAPSHOT_STALE(), B.set(K.REACTIVE_IN_HEAP(), B.set(K.REACTIVE_IN_HEAP_HEIGHT(), B.set(K.REACTIVE_ZOMBIE(), B.set(K.REACTIVE_DISPOSED(),
        B.set(K.REACTIVE_MANUAL_WRITE(), B.set(K.REACTIVE_FRAME_READ(), B.set(K.REACTIVE_STAGED_READ(), B.set(K.REACTIVE_LANE_READ(), B.set(K.REACTIVE_SCREEN_READ(), K.REACTIVE_PROBE_UNANSWERED()))))))))))
      Machine{B.store_node(w, id, R.Node.with_flags(B.node(w, id), U32.and(R.Node.flags(B.node(w, id)), keep))), rest, stack}
    case Recompute{id, create} <> +rest:
      recompute(w, rest, stack, id, create)
    case Finish{frame} <> rest:
      finish(w, rest, stack, frame)
    case RegisterFlight{frame, +id, +result} <> rest:
      Machine{F.recordFlight(w, id, result), RegisterQuestion{frame, id, result} <> rest, stack}
    case RegisterQuestion{frame, +id, result} <> rest:
      Machine{F.recordQuestion(w, id), RegisterSources{frame, id, result} <> rest, stack}
    case RegisterSources{frame, +id, result} <> rest:
      Machine{P.clearPendingSources(w, id), RegisterObserver{frame, id, result} <> rest, stack}
    case RegisterObserver{frame, id, +result} <> rest:
      +pair = F.newObserver(w, id, result)
      Machine{B.first(R.World, Nat, pair), SubscribeThen{frame, result, B.second(R.World, Nat, pair)} <> rest, stack}
    case SubscribeThen{frame, +result, +observer} <> rest:
      +w = F.addObserver(w, result, observer)
      subscribeState(w, rest, stack, frame, observer, R.AsyncObject.immediate(B.asyncObject(w, result)), R.AsyncObject.state(B.asyncObject(w, result)))
    case AfterThen{frame, observer} <> rest:
      afterThen(w, rest, stack, frame, observer)
    case AfterIterator{frame} <> rest:
      afterIterator(w, rest, stack, frame)
    case IterateStream{stream} <> rest:
      iterateStream(w, rest, stack, stream)
    case AfterStep{observer} <> rest:
      afterStep(w, rest, stack, observer)
    case AfterConsume{stream} <> rest:
      afterConsume(w, rest, stack, stream)
    case IterateOrRelease{+stream} <> +rest:
      +pair = F.settleAutodispose(w, R.StreamState.node(B.stream(w, stream)))
      Machine{B.first(R.World, Bool, pair), B.choose(~List<&2, Task>, B.second(R.World, Bool, pair), _ => rest, _ => IterateStream{stream} <> Discard{} <> rest), stack}
    case AsyncFulfill{observer, value} <> rest:
      asyncFulfill(w, rest, stack, observer, value)
    case AsyncReject{observer, error} <> rest:
      asyncReject(w, rest, stack, observer, error)
    case AsyncFlush{} <> +rest:
      B.choose(~Machine, Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w)))),
        _ => Machine{w, rest, stack}, _ => Machine{w, Round{} <> rest, stack})
    case SettleAuto{id} <> rest:
      Machine{B.first(R.World, Bool, F.settleAutodispose(w, id)), rest, stack}
    case DeliverObservers{observers, immediate, rejected, value} <> rest:
      deliverObservers(w, rest, stack, observers, immediate, rejected, value)
    case InitialEffect{+id, +scheduled, deferred} <> +rest:
      B.choose(~Machine, Bool.or(deferred, Bool.or(B.present(R.Node.pending(B.node(w, id))), R.Transaction.lane(B.transaction(w, R.NodeExtension.transaction(B.extension(w, id)))))), _ => Machine{w, rest, stack},
        _ => B.choose(~Machine, Bool.or(scheduled, S.is_user(R.Node.kind(B.node(w, id)))),
          _ => Machine{S.enqueue(w, id), rest, stack}, _ => Machine{w, RunEffect{id} <> rest, stack}))
    case RunEffect{id} <> +rest:
      runEffect(w, rest, stack, id)
    case ApplyEffect{id} <> rest:
      applyEffect(w, rest, stack, id)
    case InstallEffectCleanup{+id} <> rest:
      Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), R.Node.returnedCleanup(B.node(w, id)))), rest, stack}
    case EffectFinally{id, clean, saved} <> rest:
      effectFinally(w, rest, id, clean, saved)
    case ErrorArmFinally{parameter, saved} <> rest:
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.fault(w)), rest, saved}
    case Round{} <> +rest:
      round(w, rest, stack)
    case HeapLoop{} <> +rest:
      heapLoop(w, rest, stack)
    case Seam{} <> rest:
      Machine{w, Settle{} <> AfterSettle{} <> rest, stack}
    case Settle{} <> rest:
      beginSettle(w, rest, stack)
    case AfterSettle{} <> rest:
      afterSettle(w, rest, stack)
    case LandTransactions{frame, remaining} <> rest:
      landTransactions(w, rest, stack, frame, remaining)
    case LandNodes{frame, t, index} <> rest:
      landNodes(w, rest, stack, frame, t, index)
    case LandEnd{frame, t} <> rest:
      landEnd(w, rest, stack, frame, t)
    case CompleteSettle{frame} <> rest:
      completeSettle(w, rest, stack, frame)
    case ZombieLoop{nodes} <> rest:
      zombieLoop(w, rest, stack, nodes)
    case RenderQueue{} <> +rest:
      B.choose(~Machine, List.is_empty(&2, Nat, R.World.renderQueue(w)),
        _ => Machine{w, UserQueue{} <> rest, stack},
        _ => Machine{R.World.with_renderQueue(w, []), B.append(Task, queue_tasks(R.World.renderQueue(w)), UserQueue{} <> rest), stack})
    case UserQueue{} <> +rest:
      B.choose(~Machine, List.is_empty(&2, Nat, R.World.userQueue(w)),
        _ => Machine{w, rest, stack},
        _ => Machine{R.World.with_userQueue(w, []), B.append(Task, queue_tasks(R.World.userQueue(w)), rest), stack})
    case FlushFinally{} <> rest:
      Machine{R.World.with_passTx(R.World.with_running(w, False{}), 0n), rest, stack}
    case RoundEnd{} <> +rest:
      todo = B.choose(~List<&2, Task>, R.World.scheduled(w), _ => Round{} <> rest, _ => rest)
      Machine{w, todo, stack}

# Source exceptions skip ordinary continuations and execute enclosing finally
# frames. Cleanup throws before the compute try do not become node status here.
def unwind(+w: R.World, tasks: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case WatchFinish{awaiter, saved} <> rest:
      watchCause(w, rest, saved, awaiter, R.World.fault(w))
    case RestoreTracking{tracking} <> rest:
      Machine{R.World.with_tracking(w, tracking), rest, stack}
    case RestoreContext{owner, tracking} <> rest:
      Machine{L.restore(w, owner, tracking), rest, stack}
    case Finish{frame} <> rest:
      catchPass(w, rest, frame)
    case RegisterFlight{frame, id, result} <> rest:
      catchPass(w, rest, frame)
    case RegisterQuestion{frame, id, result} <> rest:
      catchPass(w, rest, frame)
    case RegisterSources{frame, id, result} <> rest:
      catchPass(w, rest, frame)
    case RegisterObserver{frame, id, result} <> rest:
      catchPass(w, rest, frame)
    case SubscribeThen{frame, result, observer} <> rest:
      catchPass(w, rest, frame)
    case AfterThen{frame, observer} <> rest:
      catchPass(w, rest, frame)
    case AfterIterator{frame} <> rest:
      catchPass(w, rest, frame)
    case EffectFinally{id, clean, saved} <> rest:
      effectFinally(w, rest, id, clean, saved)
    case ErrorArmFinally{parameter, saved} <> rest:
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.fault(w)), rest, saved}
    case FlushFinally{} <> rest:
      Machine{R.World.with_passTx(R.World.with_running(w, False{}), 0n), rest, stack}
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

# Direct source-helper entry for state probes; full flush uses the same tasks.
def settleWorld(fuel: Nat, w: R.World) -> R.World:
  world(run(fuel, Machine{w, [Settle{}], []}))

# External callback input; the same machine performs asyncWrite's flush.
def deliver(fuel: Nat, w: R.World, +observer: Nat, rejected: Bool, +value: R.Value) -> R.World:
  world(run(fuel, Machine{w, [B.choose(~Task, rejected, _ => AsyncReject{observer, value}, _ => AsyncFulfill{observer, value})], []}))

def resolveThenableState(fuel: Nat, +w: R.World, +id: Nat, +rejected: Bool, +value: R.Value, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}:
      +o = B.asyncObject(w, id)
      +w = B.store_asyncObject(w, id, R.AsyncObject.with_state(o, B.choose(~R.AsyncSettlement, rejected, _ => R.Rejected{value}, _ => R.Fulfilled{value})))
      world(run(fuel, Machine{w, [DeliverObservers{R.AsyncObject.observers(o), R.AsyncObject.immediate(o), rejected, value}], []}))
    case _:
      w

def resolveThenable(fuel: Nat, +w: R.World, +id: Nat, rejected: Bool, value: R.Value) -> R.World:
  resolveThenableState(fuel, w, id, rejected, value, R.AsyncObject.state(B.asyncObject(w, id)))
