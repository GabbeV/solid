# src/core/core.ts and GlobalQueue.flush translated as a continuation machine.
# Defunctionalized expressions are reusable callbacks. The same machine drives
# nested pulls and the flush: the JS adapter has no scheduling implementation.
import Base
import ./equality.bend as EQ
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./graph.bend as G
import ./graph-state.bend as GS
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
import ./memo-write.bend as MW
import ./ambient.bend as L
import ./owner-state.bend as D
import ./callback.bend as Z
import ./context.bend as Y
import ./callable.bend as J
import ./construct-state.bend as N
import ./lexical.bend as Local
import ./reaction-state.bend as Reaction
import ./action-state.bend as Action
import ./action-arguments.bend as ActionArgs
import ./question.bend as Question

# GlobalQueue.settle's detached own queues and captured joined transaction.
type SeamFrame is Data:
  SeamFrame{transaction: Nat, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>}

# Locals captured by recompute's try/catch/finally return point.
# b0ad1df5/#4171 adds prevMount/mount and laneRoot save/restore in Source.
# Active lanes are outside this profile: prevLane and inherited mount stay
# falsy, so joined still tests REACTIVE_JOINED alone at both finally entries.
# 0222d684/#4207 further requires prevLane || isEffect || !STATUS_PENDING
# before a mount includes STAGED_READ. With mount false the mask is unchanged;
# active verdict-mounted pending derivations remain outside this profile.
# Full-index TS installs lane hooks; their presence does not create a lane.
type PassFrame is Data:
  PassFrame{id: Nat, create: Bool, context: Nat, tracking: Bool, oldHeight: Nat,
    reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value,
    outgoingSources: Nat, wasPendingSource: Bool, oldFlight: Nat,
    saved: List<&2, R.Value>, released: Nat, stale: Bool}

def passStack(frame: PassFrame) -> List<&2, R.Value>:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      saved

def passId(frame: PassFrame) -> Nat:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      id

type Task is Data:
  ActionOpened{action: Nat}
  ActionExecutorEnd{action: Nat, saved: List<&2, R.Value>}
  ActionStepReturn{action: Nat, saved: List<&2, R.Value>}
  ActionSliceEnd{question: R.Question}
  ActionRestoreQuestion{question: R.Question}
  ActionYieldCatch{observer: Nat, saved: List<&2, R.Value>}
  IteratorResultValue{done: Bool}
  Evaluate{expr: R.Expr, previous: R.Value}
  Callback{callback: Nat, actions: List<&2, R.CleanupAction>, first: R.Value, second: R.Value}
  CallArguments{callback: Nat}
  EqualityCatch{id: Nat, saved: List<&2, R.Value>}
  SetSignalCompared{id: Nat, value: R.Value}
  PublishCompared{id: Nat, value: R.Value, create: Bool, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, joined: Bool, stagedErr: Bool}
  Invoke{}
  InvokeArgument{value: R.Expr, updater: Bool, previous: R.Value}
  InvokeApplied{callee: R.Value}
  InvokeArguments{}
  InvokeManyCallee{args: R.Expr, previous: R.Value}
  InvokeManyValue{callee: R.Value, args: R.Expr, reversed: List<&2, R.Value>, previous: R.Value}
  OwnerTasks{tasks: List<&2, O.Task>}
  PendingTasks{tasks: List<&2, Q.Task>, visited: List<&2, Nat>, released: List<&2, Nat>, scheduled: Bool}
  RetireSources{id: Nat, set: Nat, index: Nat, onlyDropped: Bool}
  PublishSettleSelf{id: Nat, wasPendingSource: Bool}
  CatchStageSettle{frame: PassFrame}
  CatchStageFinish{frame: PassFrame}
  CatchSelfRetire{frame: PassFrame, notReady: Bool, stagedErr: Bool}
  CatchRetireSources{frame: PassFrame, retire: Bool}
  CatchFinally{frame: PassFrame, stagedErr: Bool}
  RecomputeAfterFlight{id: Nat}
  RecomputePrepared{id: Nat, create: Bool, released: Nat}
  RestoreDeferredReleases{id: Nat, previous: Nat, released: Nat}
  RecomputeAfterTeardown{id: Nat, released: Nat}
  PassReleases{frame: PassFrame, index: Nat, value: R.Value, joined: Bool, stagedErr: Bool, missed: Bool, prior: R.Fault}
  FinishPublication{id: Nat, create: Bool, joined: Bool, missed: Bool}
  QueuePublication{id: Nat, create: Bool, missed: Bool}
  AfterDeadPass{id: Nat}
  TrimFinallyRestore{prior: R.Fault, saved: List<&2, R.Value>}
  RoundAfterSweep{}
  CommitPending{id: Nat}
  CommitFinish{id: Nat, inFlight: Bool}
  CommitAfterTrim{id: Nat, inFlight: Bool}
  CommitIntake{index: Nat}
  TrimIntake{index: Nat}
  FinishSettleIntake{transaction: Nat}
  OnCleanup{}
  CreateSignal{options: R.NodeOptions, body: R.Expr, previous: R.Value}
  SetSignalArgument{signal: Nat}
  SetMemoArgument{signal: Nat}
  SetMemoForward{signal: Nat, held: Bool}
  SetMemoAfter{signal: Nat, held: Bool}
  MemoSignalReady{signal: Nat, body: R.Expr, previous: R.Value}
  MemoAccessorReady{node: Nat}
  SetSignalResolved{signal: Nat, current: R.Value}
  CallbackThrow{}
  WatchFinish{awaiter: Nat, saved: List<&2, R.Value>}
  Binary{op: U32}
  Discard{}
  Branch{yes: R.Expr, no: R.Expr, previous: R.Value}
  RestoreTracking{tracking: Bool}
  RestoreStale{stale: Bool}
  EnterOwner{body: R.Expr, previous: R.Value}
  RestoreContext{owner: Nat, tracking: Bool}
  CheckDisposed{}
  DisposeRoot{self: Bool}
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
  ThenRejected{frame: PassFrame, error: R.Value}
  RegisterFlight{frame: PassFrame, id: Nat, result: Nat}
  RegisterQuestion{frame: PassFrame, id: Nat, result: Nat}
  RegisterSources{frame: PassFrame, id: Nat, result: Nat}
  RegisterObserver{frame: PassFrame, id: Nat, result: Nat}
  SubscribeThen{frame: PassFrame, result: Nat, observer: Nat}
  AfterIterator{frame: PassFrame}
  IterateStream{stream: Nat}
  AfterStep{observer: Nat}
  StepRejectedReturn{error: R.Value, initial: Bool}
  AfterConsume{stream: Nat}
  IterateOrRelease{stream: Nat}
  ProtocolCatch{id: Nat, result: Nat, saved: List<&2, R.Value>, successAuto: Bool, errorAuto: Bool}
  AsyncFulfill{observer: Nat, value: R.Value}
  AsyncReject{observer: Nat, error: R.Value}
  AsyncFlush{}
  AsyncWriteAfterSetter{id: Nat, then: List<&2, Task>}
  AsyncWriteAfterTrim{id: Nat}
  AsyncWriteSchedule{}
  ErrorAfterStage{id: Nat, error: R.Value}
  ErrorStageSettle{id: Nat, error: R.Value}
  ErrorSettleSource{id: Nat}
  ErrorAfterPending{id: Nat, pending: Bool}
  SettleAuto{id: Nat}
  DeliverObservers{observers: List<&2, Nat>, immediate: Bool, rejected: Bool, value: R.Value}
  InitialEffect{id: Nat, scheduled: Bool, deferred: Bool}
  RunEffect{id: Nat}
  ReactionArmClear{reaction: Nat}
  ReactionArmAfterDispose{reaction: Nat, tracking: R.Expr}
  ReactionReturn{node: Nat}
  ReactionFireValue{reaction: Nat}
  ReactionCallBody{reaction: Nat, node: Nat}
  ReactionAssignCleanup{reaction: Nat, node: Nat}
  ReactionArmValue{tracking: R.Expr}
  FireSettled{callback: Nat}
  RunTracked{id: Nat}
  TrackedAfterCleanup{id: Nat, body: R.Expr}
  ApplyEffect{id: Nat}
  InstallEffectCleanup{id: Nat}
  InstallReturnedCleanup{id: Nat}
  EffectFinally{id: Nat, clean: Bool, saved: List<&2, R.Value>}
  ErrorArmFinally{parameter: Nat, saved: List<&2, R.Value>}
  FlushArgument{}
  FlushCallbackFinally{saved: List<&2, R.Value>}
  FlushCallbackRestore{prior: R.Fault, saved: List<&2, R.Value>}
  Round{}
  HeapLoop{}
  Seam{}
  ParkIntake{transaction: Nat, index: Nat, count: Nat}
  ParkCompared{node: Nat, transaction: Nat, index: Nat, count: Nat}
  AfterPark{transaction: Nat}
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

# One source effect callback closure per inline body/creation. Its statements
# run in the existing callback machine. The descriptor's return policy belongs
# to this user-code closure, not to the source reactive node.
def inlineProgram(+w: R.World, body: R.InlineBody, program: Nat) -> B.Bundle<R.World, Nat>:
  match body:
    case R.NoInlineBody{}:
      B.Bundle{w, program}
    case R.SomeInlineBody{+expr, +returnsCleanup}:
      +id = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
      action = B.choose(~R.CleanupAction, returnsCleanup, _ => R.CallbackReturn{expr}, _ => R.CallbackEvaluate{expr})
      w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[action], returnsCleanup}]))
      B.Bundle{w, id}

# core.ts:isSame. Custom functions keep their original program identity and
# execute in the existing ambient scope with actual (a,b) arguments.
def isSame(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value) -> Machine:
  +callback = EQ.custom(w, id)
  B.choose(~Machine, Nat.is_eq(callback, 0n),
    _ => Machine{w, rest, R.Boolean{EQ.isSame(w, id, a, b)} <> stack},
    _ => Machine{w, Evaluate{R.CallWith{callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> EqualityCatch{id, stack} <> rest, stack})

# The isSame catch contains ordinary throws in node status, answering true;
# NotReady is ignored and answers undefined (falsy/change). A notifier throw
# escapes this catch just as it does in Source's catch clause.
def equalityCatch(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +id: Nat, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{+error}:
      +w = R.World.with_fault(w, R.Healthy{})
      B.choose(~Machine, P.isNotReady(error),
        _ => Machine{w, rest, R.Undefined{} <> saved},
        _ => Machine{A.notifyStatusWith(w, id, K.STATUS_ERROR(), error, False{}), rest, R.Boolean{True{}} <> saved})
    case other:
      Machine{w, rest, saved}

# core.ts:setSignal following updater execution. The entry value is never
# reloaded after a user callback. Default/disabled equality keeps its fast path.
def setResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
    _ => Machine{W.setResolved(w, id, current, value), rest, value <> stack},
    _ =>
      +w = W.beforeCompare(w, id)
      B.choose(~Machine, W.skipCompare(w, id),
        _ => Machine{W.stageResolved(w, id, value), rest, value <> stack},
        _ => isSame(w, SetSignalCompared{id, value} <> rest, stack, id, current, value)))

# core.ts:setSignal's updater call, with the source currentValue captured
# before evaluating the admitted function body. Every user updater entry shares
# this continuation, including a non-held setMemo delegation.
def signalUpdater(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +signal: Nat, value: R.Expr) -> Machine:
  +current = B.current(B.node(w, signal))
  Machine{w, Evaluate{value, current} <> SetSignalResolved{signal, current} <> rest, stack}

# signals.ts:createSignal's function overload. Both expression initializers and
# selected first-class functions share computed construction, eager/lazy setup,
# then CONFIG_AUTO_DISPOSE removal and const-pair binding at MemoSignalReady.
def signalCompute(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, compute: R.Expr, +options: R.NodeOptions, +body: R.Expr, +prev: R.Value) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{id})
  +w = N.computed(w, compute, options, R.World.context(w))
  tasks = B.choose(~List<&2, Task>, R.NodeOptions.lazy(options),
    _ => MemoSignalReady{id, body, prev} <> rest,
    _ => Recompute{id, True{}} <> MemoSignalReady{id, body, prev} <> rest)
  Machine{w, tasks, stack}

def callableSignal(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, value: R.Value, options: R.NodeOptions, body: R.Expr, +previous: R.Value) -> Machine:
  signalCompute(w, rest, stack, R.InvokeWith{R.Literal{value}, R.Previous{}, False{}}, options, body, previous)

# core/effect.ts:trackedEffect constructor. A lazy computed becomes a tracked
# leaf before its first heap wake; the user queue owns the actual first pass.
def trackedEffect(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, body: R.Expr) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{id})
  +w = N.computed(w, R.TrackedBody{body}, R.NodeOptions.with_lazy(N.defaults(), True{}), R.World.context(w))
  +n = B.node(w, id)
  +n = R.Node.with_cleanup(n, 0n)
  +n = R.Node.with_config(n, B.set(B.clear(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()), K.CONFIG_CHILDREN_FORBIDDEN()))
  +n = R.Node.with_modified(n, True{})
  +w = B.store_node(w, id, R.Node.with_kind(n, R.Tracked{}))
  Machine{B.schedule(H.enqueueSub(w, id)), rest, R.Undefined{} <> stack}

# signals.ts:onSettled: the owned branch uses trackedEffect/untrack. The other
# branch captures one plain fire closure; it must not allocate a reactive node.
def onSettled(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +body: R.Expr) -> Machine:
  B.choose(~Machine, Bool.and(Nat.is_ne(R.World.context(w), 0n), Bool.not(B.has(R.Node.config(B.node(w, R.World.context(w))), K.CONFIG_CHILDREN_FORBIDDEN()))),
    _ => trackedEffect(w, rest, stack, R.Untracked{body}),
    _ =>
      +id = B.length(R.Expr, R.World.settledCallbacks(w))
      +w = R.World.with_settledCallbacks(w, B.append(R.Expr, R.World.settledCallbacks(w), [body]))
      Machine{W.enqueueUserCallback(w, R.SettledFire{id}), rest, R.Undefined{} <> stack})

# Its compute wrapper clears previous cleanup before calling it. staleValues
# surrounds only fn; assignment of its returned cleanup follows successful return.
def trackedBody(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, body: R.Expr) -> Machine:
  +id = R.World.context(w)
  +previous = R.Node.cleanup(B.node(w, id))
  +w = B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), 0n))
  +ending = {TrackedAfterCleanup{id, body} <> rest : List<&2, Task>}
  Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(previous, 0n), _ => OwnerTasks{[O.Invoke{previous}]} <> ending, _ => ending), stack}

# signals.ts:createMemo returns the accessor; the MemoRead user ABI adds a
# subsequent call. Both use the same source constructor and eager/lazy setup.
def memoExpression(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, compute: R.Expr, +options: R.NodeOptions, read: Bool) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{id})
  +w = N.computed(w, compute, options, R.World.context(w))
  +ending = B.choose(~List<&2, Task>, read,
    _ => ReadNode{id} <> rest,
    _ => Evaluate{R.Literal{J.accessor(id)}, R.Undefined{}} <> rest)
  +ending = {MemoAccessorReady{id} <> ending : List<&2, Task>}
  tasks = B.choose(~List<&2, Task>, R.NodeOptions.lazy(options),
    _ => ending,
    _ => Recompute{id, True{}} <> ending)
  Machine{w, tasks, stack}

def memoNode(kind: R.NodeKind) -> Bool:
  match kind:
    case R.Memo{}:
      True{}
    case _:
      False{}

def setterTask(+w: R.World, +id: Nat) -> Task:
  B.choose(~Task, memoNode(R.Node.kind(B.node(w, id))), _ => SetMemoArgument{id}, _ => SetSignalArgument{id})

# core.ts:setMemo's held function pre-call and non-held setter delegation.
def memoUpdater(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +expr: R.Expr) -> Machine:
  +pair = MW.held(w, id)
  +w = B.first(R.World, Bool, pair)
  held = B.second(R.World, Bool, pair)
  B.choose(~Machine, held,
    _ => Machine{w, Evaluate{expr, R.Node.value(B.node(w, id))} <> SetMemoForward{id, True{}} <> rest, stack},
    _ => signalUpdater(MW.recover(w, id), SetMemoAfter{id, False{}} <> rest, stack, id, expr))

# The constant closure `() => value` introduced by setMemo is represented by
# wrapped=True: it returns this stack value after setSignal captures its entry
# currentValue. User-returned callable data is consequently never invoked again.
def memoDelegate(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, held: Bool, wrapped: Bool) -> Machine:
  +w = MW.recover(w, id)
  +call = B.choose(~Task, wrapped, _ => SetSignalResolved{id, B.current(B.node(w, id))}, _ => SetSignalArgument{id})
  Machine{w, call <> SetMemoAfter{id, held} <> rest, stack}

# The selected setter's target determines the public entry, including named
# host/program calls to a constructor-produced writable memo.
def selectedUpdater(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +signal: Nat, +expr: R.Expr) -> Machine:
  B.choose(~Machine, memoNode(R.Node.kind(B.node(w, signal))),
    _ => memoUpdater(w, rest, stack, signal, expr),
    _ => signalUpdater(w, rest, stack, signal, expr))

# signals.ts:createReaction.track: dispose the superseded arm before clearing
# the captured cell; a cleanup throw skips that clear and the new constructor.
def reactionArm(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +reaction: Nat, +tracking: R.Expr) -> Machine:
  +arm = R.ReactionState.arm(Reaction.get(w, reaction))
  +ending = {ReactionArmAfterDispose{reaction, tracking} <> rest : List<&2, Task>}
  Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(arm, 0n), _ => OwnerTasks{[O.Dispose{arm}]} <> ReactionArmClear{reaction} <> ending, _ => ending), stack}

def reactionArmExpression(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, actions: List<&2, R.CleanupAction>, tracking: R.Expr) -> Machine:
  match actions:
    case R.ReactionTrack{reaction} <> Nil{}:
      reactionArm(w, rest, stack, reaction, tracking)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}

# The captured owner is entered only after successful old-arm disposal.
def reactionArmAfterDispose(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +reaction: Nat, tracking: R.Expr) -> Machine:
  +state = Reaction.get(w, reaction)
  +body = {R.ReactionFire{reaction, R.Argument{0n}} : R.Expr}
  +spec = {R.EffectSpec{True{}, 0n, R.ReactionState.options(state), R.ReactionState.scheduled(state), True{}, 0n, 0n, R.ReactionState.errorProgram(state), R.SomeInlineBody{body, False{}}} : R.EffectSpec}
  Machine{L.enterOwner(w, R.ReactionState.owner(state)), Evaluate{R.EffectCreate{R.ReactionTracking{reaction, tracking}, spec}, R.Undefined{}} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> rest, stack}

# arm is reset before cl?.(); cl itself is deliberately left installed until
# effectFn returns successfully. Cleanup throws retain the previous cl value.
def reactionFire(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +reaction: Nat, +node: Nat) -> Machine:
  +state = Reaction.get(w, reaction)
  +w = Reaction.store(w, reaction, R.ReactionState.with_arm(state, 0n))
  +ending = {ReactionCallBody{reaction, node} <> rest : List<&2, Task>}
  Machine{w, B.choose(~List<&2, Task>, B.nullish(R.ReactionState.cleanup(state)), _ => ending,
    _ => Evaluate{R.Invoke{R.Literal{R.ReactionState.cleanup(state)}}, R.Undefined{}} <> Discard{} <> ending), stack}

# scheduler.ts:flush callback arm. The callback keeps the caller's ambient
# owner/tracking; only syncDepth changes. flushEntry handles the earlier action
# guard; dev/observe diagnostics remain outside this production profile.
def flushCallback(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, body: R.Expr, prev: R.Value) -> Machine:
  Machine{R.World.with_syncDepth(w, 1n+R.World.syncDepth(w)), Evaluate{body, prev} <> FlushCallbackFinally{stack} <> rest, stack}

# The production action guard precedes the callback overload. It invokes fn
# directly, without syncDepth entry or a drain (development throws instead).
def flushEntry(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +body: R.Expr, +prev: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_ne(R.World.actionDepth(w), 0n),
    _ => Machine{w, Evaluate{body, prev} <> rest, stack},
    _ => flushCallback(w, rest, stack, body, prev))

# scheduler.ts:flush no-callback arm, including its running/halted no-op guards.
# The Round tasks implement the actual while(scheduled) drain.
def publicFlush(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  B.choose(~Machine, Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.running(w), Bool.or(R.World.halted(w), Bool.not(R.World.scheduled(w))))),
    _ => Machine{w, rest, stack}, _ => Machine{w, Round{} <> rest, stack})

# Source nested finally: drain even after callback throw; a drain throw overrides
# that error. Save the return stack across the drain and decrement after either
# success or failure. Partial callback operands are discarded on a throw.
def flushCallbackFinally(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, saved: List<&2, R.Value>) -> Machine:
  +prior = R.World.fault(w)
  +values = B.choose(~List<&2, R.Value>, healthy(prior), _ => stack, _ => saved)
  publicFlush(R.World.with_fault(w, R.Healthy{}), FlushCallbackRestore{prior, values} <> rest, values)

def flushCallbackRestore(+w: R.World, rest: List<&2, Task>, saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  Machine{R.World.with_fault(R.World.with_syncDepth(w, Nat.sub(R.World.syncDepth(w), 1n)), fault), rest, saved}

def evaluate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, expr: R.Expr, +prev: R.Value) -> Machine:
  match expr:
    case R.ActionParameter{depth, index}:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, stack}
    case R.ActionCreate{factory, methods}:
      +pair = Action.function(w, factory, methods, prev)
      Machine{B.first(R.World, R.Value, pair), rest, B.second(R.World, R.Value, pair) <> stack}
    case R.ActionMethods{next, catches, thrown, tail}:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, stack}
    case R.ActionEnd{}:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, stack}
    case R.ActionInvoke{factory, methods}:
      +pair = Action.create(w, methods)
      +w = B.first(R.World, Nat, pair)
      +id = B.second(R.World, Nat, pair)
      Machine{w, Evaluate{factory, prev} <> Discard{} <> ActionOpened{id} <> ActionExecutorEnd{id, stack} <> rest, stack}
    case R.IteratorResult{done, value}:
      Machine{w, Evaluate{value, prev} <> IteratorResultValue{done} <> rest, stack}
    case R.ReactionCreate{body, errorProgram, options, scheduled}:
      +pair = Reaction.create(w, body, errorProgram, options, scheduled)
      Machine{B.first(R.World, R.Value, pair), rest, B.second(R.World, R.Value, pair) <> stack}
    case R.ReactionArm{callee, tracking}:
      Machine{w, Evaluate{callee, prev} <> ReactionArmValue{tracking} <> rest, stack}
    case R.ReactionTracking{+reaction, body}:
      +node = R.World.context(w)
      w = Reaction.store(w, reaction, R.ReactionState.with_arm(Reaction.get(w, reaction), node))
      Machine{w, Evaluate{body, R.Undefined{}} <> Discard{} <> ReactionReturn{node} <> rest, stack}
    case R.ReactionFire{reaction, node}:
      Machine{w, Evaluate{node, prev} <> ReactionFireValue{reaction} <> rest, stack}
    case R.OnSettled{body}:
      onSettled(w, rest, stack, body)
    case R.TrackedCreate{body}:
      trackedEffect(w, rest, stack, body)
    case R.TrackedBody{body}:
      trackedBody(w, rest, stack, body)
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
    case R.FlushCallback{body}:
      flushEntry(w, rest, stack, body, prev)
    case R.FlushValue{callee}:
      Machine{w, Evaluate{callee, prev} <> FlushArgument{} <> rest, stack}
    case R.FlushNow{}:
      publicFlush(w, rest, R.Undefined{} <> stack)
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
    case R.SignalComputeScope{compute, options, body}:
      signalCompute(w, rest, stack, compute, options, body, prev)
    case R.SignalScope{initial, options, body}:
      Machine{w, Evaluate{initial, prev} <> CreateSignal{options, body, prev} <> rest, stack}
    case R.LocalRead{depth}:
      Machine{R.World.with_fault(w, R.Unsupported{20n}), rest, stack}
    case R.LocalAccessor{depth}:
      Machine{R.World.with_fault(w, R.Unsupported{20n}), rest, stack}
    case R.LocalSetter{depth}:
      Machine{R.World.with_fault(w, R.Unsupported{20n}), rest, stack}
    case R.LocalWrite{depth, value, updater}:
      Machine{R.World.with_fault(w, R.Unsupported{20n}), rest, stack}
    case R.WriteExpr{+signal, +value, +updater}:
      B.choose(~Machine, updater,
        _ => selectedUpdater(w, rest, stack, signal, value),
        _ => Machine{w, Evaluate{value, prev} <> setterTask(w, signal) <> rest, stack})
    case R.EffectCreate{compute, +spec}:
      +id = B.length(R.Node, R.World.nodes(w))
      +w = B.event(w, R.Constructed{id})
      # Attachment is the user ABI's mechanical output target, as in api.createEffect.
      +w = B.choose(~R.World, R.EffectSpec.user(spec), _ => w, _ => T.attach(w, 1n, R.EffectSpec.target(spec)))
      kind = B.choose(~R.NodeKind, R.EffectSpec.user(spec), _ => R.User{}, _ => R.Render{})
      +pair = inlineProgram(w, R.EffectSpec.body(spec), R.EffectSpec.program(spec))
      +w = B.first(R.World, Nat, pair)
      +w = N.createEffectNode(w, compute, kind, R.EffectSpec.target(spec), R.EffectSpec.options(spec), R.World.context(w), B.second(R.World, Nat, pair), R.EffectSpec.returnedCleanup(spec))
      +w = B.store_node(w, id, R.Node.with_errorProgram(B.node(w, id), R.EffectSpec.errorProgram(spec)))
      Machine{w, Recompute{id, True{}} <> InitialEffect{id, R.EffectSpec.scheduled(spec), R.EffectSpec.deferred(spec)} <> Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}} <> rest, stack}
    case R.MemoAccessor{compute, options}:
      memoExpression(w, rest, stack, compute, options, False{})
    case R.MemoRead{compute, options}:
      memoExpression(w, rest, stack, compute, options, True{})
    case R.RootScope{body, transparent}:
      +id = B.length(R.Node, R.World.nodes(w))
      Machine{L.enterOwner(D.createOwner(w, R.World.context(w), transparent), id),
        Evaluate{Z.bind(body, R.RootDisposerReference{id}, R.Undefined{}), prev} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> rest, stack}
    case R.OwnerCreate{transparent}:
      +id = B.length(R.Node, R.World.nodes(w))
      Machine{N.createOwner(w, R.World.context(w), transparent), rest, R.OwnerReference{id} <> stack}
    case R.DisposeRoot{owner, self}:
      Machine{w, Evaluate{owner, prev} <> DisposeRoot{self} <> rest, stack}
    case R.ContextGet{key, owner}:
      Machine{w, Evaluate{owner, prev} <> ContextGet{key} <> rest, stack}
    case R.ContextSet{key, value, owner}:
      Machine{w, Evaluate{value, prev} <> Evaluate{owner, prev} <> ContextSet{key} <> rest, stack}
    case R.Argument{index}:
      Machine{w, rest, R.Undefined{} <> stack}
    case R.CallWith{callback, first, second}:
      Machine{w, Evaluate{first, prev} <> Evaluate{second, prev} <> CallArguments{callback} <> rest, stack}
    case R.CallArgumentsEnd{}:
      Machine{R.World.with_fault(w, R.Unsupported{60n}), rest, stack}
    case R.CallArgumentsItem{value, tail}:
      Machine{R.World.with_fault(w, R.Unsupported{60n}), rest, stack}
    case R.InvokeMany{callee, args}:
      Machine{w, Evaluate{callee, prev} <> InvokeManyCallee{args, prev} <> rest, stack}
    case R.InvokeArguments{callee, first, second}:
      Machine{w, Evaluate{callee, prev} <> Evaluate{first, prev} <> Evaluate{second, prev} <> InvokeArguments{} <> rest, stack}
    case R.InvokeWith{callee, value, updater}:
      Machine{w, Evaluate{callee, prev} <> InvokeArgument{value, updater, prev} <> rest, stack}
    case R.Invoke{callee}:
      Machine{w, Evaluate{callee, prev} <> Invoke{} <> rest, stack}
    case R.OnCleanup{callee}:
      Machine{w, Evaluate{callee, prev} <> OnCleanup{} <> rest, stack}
    case R.CallProgram{+callback}:
      B.choose(~Machine, Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
        _ => Machine{w, Callback{callback, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}})), R.Undefined{}, R.Undefined{}} <> rest, stack},
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
    case R.ActionFunction{factory, methods, previous}:
      Machine{w, Evaluate{R.ActionInvoke{ActionArgs.bind(factory, 0n, first, second), ActionArgs.bind(methods, 0n, first, second)}, previous} <> rest, stack}
    case R.ReactionTrack{reaction}:
      reactionArm(w, rest, stack, reaction, R.InvokeWith{R.Literal{first}, R.Literal{R.Undefined{}}, False{}})
    case R.ReactionLifecycle{+reaction}:
      B.choose(~Machine, B.nullish(R.ReactionState.cleanup(Reaction.get(w, reaction))),
        _ => Machine{w, rest, R.Undefined{} <> stack},
        _ => Machine{w, Evaluate{R.Invoke{R.Literal{R.ReactionState.cleanup(Reaction.get(w, reaction))}}, R.Undefined{}} <> rest, stack})
    case R.CleanupBoundAccessor{signal}:
      Machine{w, ReadNode{signal} <> rest, stack}
    case R.CleanupWrite{signal, value}:
      Machine{w, setterTask(w, signal) <> Discard{} <> Callback{id, tail, first, second} <> rest, value <> stack}
    case R.CallbackEvaluate{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}
    case R.CallbackReturn{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> rest, stack}
    case R.CallbackWrite{signal, expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> setterTask(w, signal) <> Discard{} <> Callback{id, tail, first, second} <> rest, stack}
    case R.CallbackUpdate{+signal, expr}:
      selectedUpdater(w, Discard{} <> Callback{id, tail, first, second} <> rest, stack, signal, Z.bind(expr, first, second))
    case R.CallbackThrow{expr}:
      Machine{w, Evaluate{Z.bind(expr, first, second), R.Undefined{}} <> CallbackThrow{} <> Callback{id, tail, first, second} <> rest, stack}
    case other:
      Machine{w, OwnerTasks{[O.Action{id, other}]} <> Callback{id, tail, first, second} <> rest, stack}

def callback(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +first: R.Value, +second: R.Value, actions: List<&2, R.CleanupAction>) -> Machine:
  match actions:
    case Nil{}:
      Machine{w, rest, R.Undefined{} <> stack}
    case value <> tail:
      callbackAction(w, rest, stack, id, tail, first, second, value)

# core.ts:setSignal's typeof-function branch. currentValue was captured before
# invoking the callable. A returned function is data in SetSignalResolved.
def resolveSignalArgument(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +signal: Nat, +current: R.Value, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{owner}:
      Machine{w, OwnerTasks{[O.Enter{owner, True{}, False{}}]} <> SetSignalResolved{signal, current} <> rest, R.Undefined{} <> tail}
    case R.ProgramReference{callback}:
      Machine{w, Evaluate{R.CallWith{callback, R.Literal{current}, R.Literal{R.Undefined{}}}, R.Undefined{}} <> SetSignalResolved{signal, current} <> rest, tail}
    case R.AccessorReference{id}:
      Machine{w, ReadNode{id} <> SetSignalResolved{signal, current} <> rest, tail}
    case R.SetterReference{id}:
      Machine{w, setterTask(w, id) <> SetSignalResolved{signal, current} <> rest, current <> tail}
    case other:
      Machine{w, SetSignalResolved{signal, current} <> rest, other <> tail}

def setSignalArgument(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +signal: Nat, value: R.Value) -> Machine:
  resolveSignalArgument(w, rest, tail, signal, B.current(B.node(w, signal)), value)

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

# owner.ts:disposeRootSelf with its receiver and supplied self flag. Only actual root
# handles enter this user ABI operation; computed disposal has another source
# entry and must not be substituted for a root's dispose method.
def disposeRootValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value, +self: Bool) -> Machine:
  match value:
    case R.OwnerReference{+id}:
      B.choose(~Machine, B.root(R.Node.kind(B.node(w, id))),
        _ => Machine{w, OwnerTasks{[O.Enter{id, self, False{}}]} <> rest, R.Undefined{} <> tail},
        _ => Machine{R.World.with_fault(w, R.TypeError{}), rest, tail})
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def disposeRoot(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +self: Bool) -> Machine:
  match stack:
    case value <> tail:
      disposeRootValue(w, rest, tail, value, self)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# Root init's bound disposeRootSelf(owner,true), invoked as a plain function.
def invokeValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{id}:
      Machine{w, OwnerTasks{[O.Enter{id, True{}, False{}}]} <> rest, R.Undefined{} <> tail}
    # signals.ts:accessor is read.bind(null,node); invocation enters the
    # ordinary read return points, with the caller stack/context intact.
    case R.ProgramReference{callback}:
      Machine{w, Evaluate{R.CallWith{callback, R.Literal{R.Undefined{}}, R.Literal{R.Undefined{}}}, R.Undefined{}} <> rest, tail}
    case R.AccessorReference{id}:
      Machine{w, ReadNode{id} <> rest, tail}
    case R.SetterReference{id}:
      Machine{w, setterTask(w, id) <> rest, R.Undefined{} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, tail}

def invoke(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      invokeValue(w, rest, tail, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# User call ABI: function value and raw argument have already evaluated.
def invokeApplied(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, callee: R.Value, +value: R.Value) -> Machine:
  match callee:
    case R.ProgramReference{callback}:
      Machine{w, Evaluate{R.CallWith{callback, R.Literal{value}, R.Literal{R.Undefined{}}}, R.Undefined{}} <> rest, tail}
    case R.SetterReference{id}:
      Machine{w, setterTask(w, id) <> rest, value <> tail}
    case other:
      invokeValue(w, rest, tail, other)

# core.ts:setMemo, an updater expression represents its original function
# argument. The held pre-call's answer is passed to setSignal as-is, preserving
# the pinned second-invocation bug for returned function data (SOLID-003).
def memoRawArgument(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +id: Nat, value: R.Value) -> Machine:
  match value:
    case R.RootDisposerReference{owner}:
      Machine{w, OwnerTasks{[O.Enter{owner, True{}, False{}}]} <> SetMemoForward{id, True{}} <> rest, R.Undefined{} <> tail}
    case R.ProgramReference{callback}:
      Machine{w, Evaluate{R.CallWith{callback, R.Literal{R.Node.value(B.node(w, id))}, R.Literal{R.Undefined{}}}, R.Undefined{}} <> SetMemoForward{id, True{}} <> rest, tail}
    case R.AccessorReference{node}:
      Machine{w, ReadNode{node} <> SetMemoForward{id, True{}} <> rest, tail}
    case R.SetterReference{node}:
      Machine{w, setterTask(w, node) <> SetMemoForward{id, True{}} <> rest, R.Node.value(B.node(w, id)) <> tail}
    case other:
      memoDelegate(w, rest, other <> tail, id, True{}, False{})


# Creating an updater closure does not execute its body. Accessors/disposers
# ignore that function argument; only setSignal invokes it with currentValue.
def invokeUpdater(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, callee: R.Value, +expr: R.Expr) -> Machine:
  match callee:
    case R.ProgramReference{callback}:
      Machine{R.World.with_fault(w, R.Unsupported{22n}), rest, tail}
    case R.SetterReference{+id}:
      B.choose(~Machine, memoNode(R.Node.kind(B.node(w, id))),
        _ => memoUpdater(w, rest, tail, id, expr),
        _ => signalUpdater(w, rest, tail, id, expr))
    case other:
      invokeValue(w, rest, tail, other)

# Callback IDs are the admitted host function representation. Owner callbacks
# now share the same read continuations at every active engine call site.
def callbackExists(+w: R.World, +callback: Nat) -> Bool:
  Bool.and(Nat.is_ne(callback, 0n), Nat.is_lt(callback, B.length(R.CleanupProgram, R.World.cleanupPrograms(w))))

# No-owner cleanup returns before inspecting or allocating a callback.
def registerProgramCleanup(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, +callback: Nat) -> Machine:
  B.choose(~Machine, Nat.is_eq(R.World.context(w), 0n), _ => Machine{w, rest, R.ProgramReference{callback} <> tail},
    _ => B.choose(~Machine, callbackExists(w, callback),
      _ =>
        +pair = J.encodeProgram(w, callback)
        +w = B.first(R.World, Nat, pair)
        Machine{O.cleanup(w, R.World.context(w), B.second(R.World, Nat, pair)), rest, R.ProgramReference{callback} <> tail},
      _ => Machine{R.World.with_fault(w, R.Unsupported{9n}), rest, tail}))

# signals.ts:onCleanup -> owner.ts:cleanup returns the original function.
def onCleanupValue(+w: R.World, +rest: List<&2, Task>, +tail: List<&2, R.Value>, value: R.Value) -> Machine:
  match value:
    case R.ProgramReference{callback}:
      registerProgramCleanup(w, rest, tail, callback)
    case R.RootDisposerReference{+root}:
      Machine{J.cleanup(w, R.World.context(w), root), rest, R.RootDisposerReference{root} <> tail}
    case R.AccessorReference{+signal}:
      Machine{J.cleanupAccessor(w, R.World.context(w), signal), rest, R.AccessorReference{signal} <> tail}
    case R.SetterReference{+signal}:
      Machine{J.cleanupSetter(w, R.World.context(w), signal), rest, R.SetterReference{signal} <> tail}
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
# User-code argument binding, not a source scheduler or callback replacement.
# Source functions stay identified by the original program ID; only parameter
# occurrences in their admitted syntax are captured before entering the same
# callback/action driver. Root and generator-resume binders remain distinct.
def bindCallAction(action: R.CleanupAction, +args: List<&2, R.Value>) -> R.CleanupAction:
  match action:
    case R.ActionFunction{factory, methods, previous}:
      R.ActionFunction{ActionArgs.bindMany(factory, 0n, args), ActionArgs.bindMany(methods, 0n, args), previous}
    case R.CallbackEvaluate{expr}:
      R.CallbackEvaluate{Z.bindMany(expr, args)}
    case R.CallbackReturn{expr}:
      R.CallbackReturn{Z.bindMany(expr, args)}
    case R.CallbackWrite{signal, expr}:
      R.CallbackWrite{signal, Z.bindMany(expr, args)}
    case R.CallbackUpdate{signal, expr}:
      R.CallbackUpdate{signal, Z.bindMany(expr, args)}
    case R.CallbackThrow{expr}:
      R.CallbackThrow{Z.bindMany(expr, args)}
    case other:
      other

def bindCallActions(actions: List<&2, R.CleanupAction>, args: List<&2, R.Value>) -> List<&2, R.CleanupAction>:
  B.mapWith(R.CleanupAction, R.CleanupAction, List<&2, R.Value>, values => action => bindCallAction(action, values), args, actions)

# JavaScript calls evaluate all arguments, even those a particular callable
# ignores. The ordinary bound getter/setter/disposer cases use their existing
# entry; named functions and action wrappers share callback's source behavior.
def invokeMany(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, callee: R.Value, +args: List<&2, R.Value>) -> Machine:
  match callee:
    case R.ProgramReference{+id}:
      B.choose(~Machine, callbackExists(w, id),
        _ => Machine{w, Callback{id, bindCallActions(R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), id, R.CleanupProgram{[], False{}})), args), B.get(R.Value, args, 0n, R.Undefined{}), B.get(R.Value, args, 1n, R.Undefined{})} <> rest, stack},
        _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), rest, stack})
    case other:
      invokeApplied(w, rest, stack, other, B.get(R.Value, args, 0n, R.Undefined{}))

# Callee first, then arguments left to right, once each. Accumulate in reverse
# so the immutable representation adds no quadratic argument-list copying.
def invokeManyArguments(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +callee: R.Value, args: R.Expr, +reversed: List<&2, R.Value>, +previous: R.Value) -> Machine:
  match args:
    case R.CallArgumentsEnd{}:
      invokeMany(w, rest, stack, callee, List.reverse(&2, R.Value, reversed))
    case R.CallArgumentsItem{head, tail}:
      Machine{w, Evaluate{head, previous} <> InvokeManyValue{callee, tail, reversed, previous} <> rest, stack}
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{60n}), rest, stack}

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

def recomputePrepared(+w: R.World, rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, released: Nat) -> Machine:
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
    P.hasSource(w, id, id), R.NodeExtension.inFlight(B.extension(w, id)), stack, released, R.World.stale(w)} : PassFrame}
  next = {Evaluate{R.Node.expr(n), B.current(n)} <> Finish{frame} <> rest : List<&2, Task>}
  +w = R.World.with_stale(w, Bool.or(R.World.stale(w), Bool.and(B.effect(R.Node.kind(n)), Bool.not(S.is_user(R.Node.kind(n))))))
  w = R.World.with_tracking(B.choose(~R.World, B.tracked(R.Node.kind(n)), _ => w, _ => B.event(w, R.Invoked{id})), True{})
  Machine{w, next, stack}

# core.ts:recompute before its body try: callbacks here unwind the caller.
def recomputeAfterFlight(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  +w = B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_PENDING()),
    _ => B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), K.CONFIG_VERDICT()))), _ => w)
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.reenterHeld(w, id), _ => w)
  B.choose(~Machine, Bool.or(B.tracked(R.Node.kind(B.node(w, id))), B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED())),
    _ =>
      +previous = R.World.deferredReleases(w)
      +pair = GS.beginReleases(w)
      Machine{B.first(R.World, Nat, pair), OwnerTasks{[O.Enter{id, False{}, False{}}]} <> RestoreDeferredReleases{id, previous, B.second(R.World, Nat, pair)} <> rest, stack},
    _ =>
      w = B.choose(~R.World, Bool.or(Nat.is_ne(R.Node.firstChild(B.node(w, id)), 0n), Bool.not(B.noDisposal(R.Node.disposal(B.node(w, id))))),
        _ => O.parkChildren(w, id), _ => w)
      Machine{w, RecomputeAfterTeardown{id, 0n} <> rest, stack})

# core.ts:recompute after frame teardown and deferred-array restoration.
def recomputeAfterTeardown(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, released: Nat) -> Machine:
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()),
    _ =>
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{}))
      B.store_node(w, id, R.Node.with_config(B.node(w, id), U32.xor(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()))), _ => w)
  Machine{w, RecomputePrepared{id, False{}, released} <> rest, stack}

def recomputeFlight(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n))
  +callback = R.NodeExtension.flightTeardown(B.extension(w, id))
  B.choose(~Machine, Nat.is_ne(callback, 0n),
    _ => Machine{B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), 0n)),
      OwnerTasks{[O.Invoke{callback}]} <> RecomputeAfterFlight{id} <> rest, stack},
    _ => Machine{w, RecomputeAfterFlight{id} <> rest, stack})

def recompute(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +w = B.bump(w)
  B.choose(~Machine, create, _ => recomputePrepared(w, rest, stack, id, create, 0n),
    _ =>
      +w = H.deleteFromHeap(w, id)
      B.choose(~Machine, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => recomputeFlight(w, rest, stack, id),
        _ => recomputeAfterFlight(w, rest, stack, id)))

# The pending-source walk's captured visited/released locals survive owner
# callbacks. Its traversal completes before releases; callbacks may alter the
# graph, but do not replace this walk's private release list or cursor.
def pendingResume(+rest: List<&2, Task>, +stack: List<&2, R.Value>, machine: Q.Machine) -> Machine:
  match machine:
    case Q.Machine{world, tasks, visited, released, scheduled}:
      Machine{world, PendingTasks{tasks, visited, released, scheduled} <> rest, stack}

def pendingTasks(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, rest, stack}
    case Q.Release{+index} <> +tail:
      B.choose(~Machine, Nat.is_ge(index, B.length(Nat, released)),
        _ => Machine{w, PendingTasks{tail, visited, released, scheduled} <> rest, stack},
        _ =>
          +id = B.get(Nat, released, index, 0n)
          +again = {PendingTasks{Q.Release{1n+index} <> tail, visited, released, scheduled} <> rest : List<&2, Task>}
          Machine{w, B.choose(~List<&2, Task>, Q.releasable(w, id), _ => OwnerTasks{[O.Unobserved{id}]} <> again, _ => again), stack})
    case other:
      pendingResume(rest, stack, Q.advance(w, other, visited, released, scheduled))

# Source loops over a captured Set handle, not a copied member list. Its live
# cursor skips deleted slots and observes appends, as JS Set iteration does.
def retireSources(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +set: Nat, +index: Nat, +onlyDropped: Bool) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, B.pendingSlots(w, set))), _ => Machine{w, rest, stack},
    _ =>
      +source = B.get(Nat, B.pendingSlots(w, set), index, 0n)
      +skip = Bool.or(Nat.is_eq(source, 0n), Bool.or(Nat.is_eq(source, id), Bool.and(onlyDropped, P.hasSource(w, id, source))))
      +ending = {RetireSources{id, set, 1n+index, onlyDropped} <> rest : List<&2, Task>}
      B.choose(~Machine, skip, _ => Machine{w, ending, stack},
        _ => pendingResume(ending, stack, Q.beginSettlement(w, id, source))))

def retireOutgoing(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, id: Nat, set: Nat, onlyDropped: Bool) -> Machine:
  Machine{w, RetireSources{id, set, 0n, onlyDropped} <> rest, stack}

# No lane engine is installed: only joined/creator-pass posture makes a new
# value belong to flushTransaction/passTx (core.ts's born-held value arm).
# #4171 folds the former prevLane && STAGED_READ arm into mount-aware joined;
# both arms are absent with this profile's inactive lanes, not globally.
def bornHeld(+w: R.World, joined: Bool) -> Bool:
  Bool.and(Bool.or(Nat.is_ne(R.World.flushTransaction(w), 0n), Nat.is_ne(R.World.passTx(w), 0n)),
    Bool.or(joined, B.has(R.Node.flags(B.node(w, B.parentComputed(w, R.World.context(w)))), K.REACTIVE_JOINED())))

def publicationTx(+w: R.World) -> Nat:
  B.choose(~Nat, Nat.is_ne(R.World.flushTransaction(w), 0n), _ => R.World.flushTransaction(w), _ => R.World.passTx(w))

def publishValueChanged(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, joined: Bool, +changed: Bool) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  +isEffect = B.effect(R.Node.kind(n))
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

def publishValue(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, wasUninitialized: Bool, +joined: Bool) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  +isEffect = B.effect(R.Node.kind(n))
  +changed = Bool.or(Bool.and(Bool.not(isEffect), wasUninitialized),
    Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.not(EQ.isSame(w, id, B.current(n), value))))
  publishValueChanged(w, id, value, create, oldHeight, joined, changed)

# recompute's queue decision is after its successful dependency trim callback.
def queuePublication(+w: R.World, +id: Nat, create: Bool) -> R.World:
  B.choose(~R.World, B.ok(w),
    _ =>
      +n = B.node(w, id)
      queued = Bool.or(B.present(R.Node.pending(n)), Bool.or(O.parked(w, id),
        Bool.and(B.has(R.Node.status(n), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED())), Bool.or(Bool.not(create), B.has(R.Node.status(n), K.STATUS_PENDING())))))
      B.choose(~R.World, queued, _ => S.queuePendingNode(B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), K.CONFIG_STAGED()))), id), _ => w),
    _ => w)

def finishPublication(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, joined: Bool, +missed: Bool) -> Machine:
  +w = B.choose(~R.World, Bool.and(create, Bool.and(joined, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))),
    _ =>
      +t = publicationTx(w)
      B.choose(~R.World, Bool.and(Nat.is_ne(t, 0n), Bool.not(R.Transaction.lane(B.transaction(w, t)))), _ => X.holdNode(w, id, t), _ => w), _ => w)
  +n = B.node(w, id)
  +ending = {QueuePublication{id, create, missed} <> rest : List<&2, Task>}
  B.choose(~Machine, Bool.and(Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))), Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.not(R.Node.modified(n)))),
    _ => B.choose(~Machine, Bool.or(create, B.tracked(R.Node.kind(n))),
      _ => Machine{w, OwnerTasks{[O.TrimDeps{id}]} <> ending, stack},
      _ => Machine{R.World.with_trims(w, B.append(Nat, R.World.trims(w), [id])), ending, stack}),
    _ => Machine{w, ending, stack})


def publicationCompleted(+rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +pair: B.Bundle<R.World, Bool>) -> Machine:
  +w = B.first(R.World, Bool, pair)
  +changed = B.second(R.World, Bool, pair)
  +ending = {PublishSettleSelf{id, wasPendingSource} <> rest : List<&2, Task>}
  B.choose(~Machine, Bool.and(Bool.not(changed), Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id))))),
    _ =>
      +w = B.choose(~R.World, B.equal(outgoing, R.Undefined{}), _ => w, _ => A.settleErroredDependents(w, id, outgoing))
      retireOutgoing(w, ending, stack, id, outgoingSources, False{}),
    _ => Machine{w, ending, stack})

# Equality can read/write/throw before any publication stores. Preserve the
# recompute's captured value/height/outgoing locals across that callback.
def publishCompared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, value: R.Value, create: Bool, oldHeight: Nat, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, joined: Bool, changed: Bool) -> Machine:
  # Source's errored local was captured before the comparator; do not re-test
  # the live error here. A caught comparator answers same, then height/self
  # settlement still follows the original successful-body branch.
  publicationCompleted(rest, stack, id, outgoing, outgoingSources, wasPendingSource, publishValueChanged(w, id, value, create, oldHeight, joined, changed))

def publishState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, +wasUninitialized: Bool, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +joined: Bool, +stagedErr: Bool) -> Machine:
  +errored = Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), stagedErr)
  B.choose(~Machine, errored, _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
      _ => publicationCompleted(rest, stack, id, outgoing, outgoingSources, wasPendingSource, publishValue(w, id, value, create, oldHeight, wasUninitialized, joined)),
      _ => B.choose(~Machine, Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), wasUninitialized), B.truth(R.NodeExtension.shownError(B.extension(w, id)))),
        _ => publishCompared(w, rest, stack, id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, True{}),
        _ => isSame(w, PublishCompared{id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr} <> rest, stack, id, B.current(B.node(w, id)), value))))

# recompute's finally is shared by normal return and exceptional unwind.
def passFinally(+w: R.World, +id: Nat, create: Bool, context: Nat, tracking: Bool, reask: Bool, stale: Bool) -> R.World:
  +w = R.World.with_tracking(w, tracking)
  +w = R.World.with_stale(w, stale)
  +n = B.node(w, id)
  +config = B.set(B.clear(R.Node.config(n), K.CONFIG_VERDICT()), U32.and(R.Node.flags(n), K.REACTIVE_PROBED()))
  +w = B.store_node(w, id, R.Node.with_config(n, config))
  +keep = B.set(K.REACTIVE_ZOMBIE(), B.set(K.REACTIVE_DISPOSED(), B.set(K.REACTIVE_FRAME_READ(), B.set(K.REACTIVE_STAGED_READ(),
    B.set(K.REACTIVE_LANE_READ(), B.set(K.REACTIVE_SCREEN_READ(), K.REACTIVE_PROBE_UNANSWERED()))))))
  keep = B.choose(~U32, create, _ => B.set(keep, K.REACTIVE_SNAPSHOT_STALE()), _ => keep)
  +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), U32.and(R.Node.flags(B.node(w, id)), keep)))
  +w = R.World.with_context(w, context)
  w

def passFinallyTail(+w: R.World, +id: Nat, reask: Bool) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    _ => B.store_extension(w, id, R.NodeExtension.with_reask(B.extension(w, id), Bool.and(reask, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))), _ => w)

def afterPass(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, value: R.Value, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, +joined: Bool, stagedErr: Bool, missed: Bool) -> Machine:
  B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()),
    _ =>
      Machine{w, OwnerTasks{[O.ClearDeps{id}]} <> AfterDeadPass{id} <> rest, stack},
    _ =>
      publishState(w, FinishPublication{id, create, joined, missed} <> rest, stack, id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr))

# Source finally executes its deferred releases even when unwinding a body
# failure. A release failure replaces that failure and skips the remaining tail.
def startPassFinally(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame, value: R.Value, joined: Bool, stagedErr: Bool, missed: Bool) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      +w = passFinally(w, id, create, context, tracking, reask, stale)
      Machine{R.World.with_fault(w, R.Healthy{}), PassReleases{frame, 0n, value, joined, stagedErr, missed, R.World.fault(w)} <> rest, stack}

def passReleases(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +index: Nat, +value: R.Value, +joined: Bool, +stagedErr: Bool, +missed: Bool, +prior: R.Fault) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      +nodes = B.get(List<&2, Nat>, R.World.releaseLists(w), released, [])
      B.choose(~Machine, Nat.is_ge(index, B.length(Nat, nodes)),
        _ =>
          +w = R.World.with_fault(passFinallyTail(w, id, reask), prior)
          B.choose(~Machine, B.ok(w),
            _ => afterPass(w, rest, stack, id, create, value, height, uninitialized, outgoing, sources, pendingSource, joined, stagedErr, missed),
            _ => Machine{w, rest, stack}),
        _ =>
          +node = B.get(Nat, nodes, index, 0n)
          +ending = {PassReleases{frame, 1n+index, value, joined, stagedErr, missed, prior} <> rest : List<&2, Task>}
          Machine{w, B.choose(~List<&2, Task>, Q.releasable(w, node), _ => OwnerTasks{[O.Unobserved{node}]} <> ending, _ => ending), stack})

def finishReady(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame, +keepFlight: Bool) -> Machine:
  match stack frame:
    case value <> +tail PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      +w = B.choose(~R.World, Bool.and(Bool.not(keepFlight), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      +w = B.choose(~R.World, keepFlight, _ => w, _ => B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})))
      +w = B.choose(~R.World, Bool.or(U32.is_ne(R.Node.status(B.node(w, id)), 0), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => A.clearStatus(w, id, create), _ => w)
      +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
      +joined = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED())
      startPassFinally(w, rest, tail, frame, value, joined, False{}, missed)
    case _ _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

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
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, +flight, saved, released, stale}:
      finishResult(w, rest, stack, frame, id, flight)

# Body throw -> source catch -> finally -> publication tail, with the caller's
# value stack restored. A throw from the prelude has no frame of its own here.
# recompute's pending/error catch. The loading-window arm changes neither
# read-visible status nor propagation. Replacement-source retirement follows
# successful notification, before the caller's finally frame.
# A throw while executing the catch still executes this pass's finally.
# stageError's assignment is complete only after its release walk returns.
def finishCatch(+w: R.World, rest: List<&2, Task>, +frame: PassFrame, stagedErr: Bool) -> Machine:
  match frame:
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      +joined = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED())
      +missed = B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_MISSED_WAKE())
      startPassFinally(w, rest, saved, frame, previous, joined, stagedErr, missed)

def catchNotify(+w: R.World, rest: List<&2, Task>, +frame: PassFrame, cause: R.Value, +notReady: Bool, +stagedErr: Bool) -> Machine:
  +id = passId(frame)
  +w = B.choose(~R.World, Bool.or(notReady, Bool.not(stagedErr)),
    _ =>
      +w = B.choose(~R.World, notReady,
        _ =>
          +w = E.ext(w, id)
          B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{True{}}})), _ => w)
      A.notifyStatusWith(w, id, B.choose(~U32, notReady, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), cause, False{}), _ => w)
  Machine{w, CatchSelfRetire{frame, notReady, stagedErr} <> CatchFinally{frame, stagedErr} <> rest, passStack(frame)}

def catchStatus(+w: R.World, +rest: List<&2, Task>, +frame: PassFrame, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{+cause}:
      +w = R.World.with_fault(w, R.Healthy{})
      +id = passId(frame)
      +notReady = P.isNotReady(cause)
      B.choose(~Machine, Bool.and(notReady, R.Node.loading(B.node(w, id))),
        _ => Machine{P.parkLoadingWindow(w, id, cause), CatchFinally{frame, False{}} <> rest, passStack(frame)},
        _ => B.choose(~Machine, notReady,
          _ => catchNotify(w, rest, frame, cause, True{}, False{}),
          _ =>
            +pair = Q.beginStageError(w, id, cause, True{})
            +w = B.first(R.World, Bool, pair)
            B.choose(~Machine, B.second(R.World, Bool, pair),
              _ => Machine{w, CatchStageSettle{frame} <> CatchStageFinish{frame} <> rest, passStack(frame)},
              _ => catchNotify(w, rest, frame, cause, False{}, False{}))))
    case other:
      Machine{w, CatchFinally{frame, False{}} <> rest, passStack(frame)}

def catchPass(+w: R.World, rest: List<&2, Task>, frame: PassFrame) -> Machine:
  catchStatus(w, rest, frame, R.World.fault(w))

def catchSelfRetire(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +notReady: Bool, stagedErr: Bool) -> Machine:
  match frame:
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      +ending = {CatchRetireSources{frame, Bool.or(notReady, stagedErr)} <> rest : List<&2, Task>}
      B.choose(~Machine, Bool.and(notReady, Bool.and(pendingSource, Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), 0n))),
        _ => pendingResume(ending, stack, Q.beginSettlement(w, id, id)),
        _ => Machine{w, ending, stack})

def catchRetireSources(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, frame: PassFrame, +retire: Bool) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale}:
      B.choose(~Machine, retire, _ => retireOutgoing(w, rest, stack, id, sources, True{}), _ => Machine{w, rest, stack})

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

def finishHandleError(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, pending: Bool) -> Machine:
  +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  B.choose(~Machine, pending, _ => Machine{w, rest, stack},
    _ => pendingResume(rest, stack, Q.beginReleaseSettledDependents(w, id)))

def handleErrorNotify(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, error: R.Value, +pending: Bool, staged: Bool) -> Machine:
  +w = B.choose(~R.World, Bool.or(pending, Bool.not(staged)),
    _ => A.notifyStatusWith(w, id, B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), error, False{}), _ => w)
  Machine{w, B.choose(~List<&2, Task>, pending,
    _ => ErrorSettleSource{id} <> rest,
    _ => ErrorAfterPending{id, pending} <> rest), stack}

# async.ts:handleError retains its result-identity/loading guard, then pauses
# at stageError's and settlement's actual deferred release call boundaries.
def handleErrorStarted(+rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +error: R.Value, pair: B.Bundle<R.World, F.ErrorPosture>) -> Machine:
  match pair:
    case B.Bundle{world, F.ErrorDone{}}:
      Machine{world, rest, stack}
    case B.Bundle{world, F.ErrorPending{}}:
      handleErrorNotify(world, rest, stack, id, error, True{}, False{})
    case B.Bundle{world, F.ErrorActual{}}:
      +pair = Q.beginStageError(world, id, error, False{})
      +w = B.first(R.World, Bool, pair)
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => Machine{w, ErrorStageSettle{id, error} <> rest, stack},
        _ => handleErrorNotify(w, rest, stack, id, error, False{}, False{}))

def handleError(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, result: Nat, +error: R.Value) -> Machine:
  handleErrorStarted(rest, stack, id, error, F.beginHandleError(w, id, result, error))

# .then returned; a synchronously fulfilled iterable is flattened LIVE using
# the same syncValue local (including the immediately empty source branch).
def afterThen(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +observer: Nat) -> Machine:
  +o = B.asyncObserver(w, observer)
  +source = iterable(w, R.AsyncObserver.syncValue(o))
  B.choose(~Machine, R.AsyncObserver.rejected(o),
    _ =>
      +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
      handleError(w, ThenRejected{frame, R.AsyncObserver.syncError(o)} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), R.AsyncObserver.syncError(o)),
    _ => B.choose(~Machine, Bool.and(R.AsyncObserver.resolved(o), Nat.is_ne(source, 0n)),
      _ =>
        +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
        consumeIterator(w, AfterIterator{frame} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), source, False{}, R.Undefined{}),
      _ =>
        +pair = F.thenValue(w, observer)
        +w = B.first(R.World, R.Value, pair)
        B.choose(~Machine, B.ok(w),
          _ => finishReady(w, rest, B.second(R.World, R.Value, pair) <> stack, frame, True{}),
          _ => catchPass(w, rest, frame))))

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
      handleError(w, StepRejectedReturn{R.AsyncObserver.syncError(o), R.StreamState.initialRead(s)} <> rest, stack, R.StreamState.node(s), R.StreamState.result(s), R.AsyncObserver.syncError(o)),
    _ => afterStepResult(w, rest, stack, stream, R.AsyncObserver.resolved(o), R.AsyncObserver.syncValue(o)))

def afterConsume(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  match stack:
    case R.Boolean{done} <> tail:
      +s = B.stream(w, stream)
      +w = B.store_stream(w, stream, R.StreamState.with_initialRead(s, False{}))
      Machine{w, rest, R.StreamVerdict{stream, Bool.or(R.StreamState.hadValue(s), done), R.StreamState.syncValue(s)} <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# async.ts:asyncWrite. The optional `then` callback runs only after
# trim, pending-source release, schedule and the synchronous flush.
def asyncWriteAfterValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, then: List<&2, Task>) -> Machine:
  +ending = {AsyncWriteAfterTrim{id} <> AsyncWriteSchedule{} <> AsyncFlush{} <> B.append(Task, then, rest) : List<&2, Task>}
  B.choose(~Machine, Bool.not(B.present(R.Node.pending(B.node(w, id)))),
    _ => Machine{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), OwnerTasks{[O.TrimDeps{id}]} <> ending, stack},
    _ => Machine{w, ending, stack})

# The default facade and custom call share source before/after-write segments.
def asyncWrite(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, Task>) -> Machine:
  B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
    _ =>
      +pair = F.beginAsyncWrite(w, id, result, value)
      +w = B.first(R.World, Bool, pair)
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => asyncWriteAfterValue(w, rest, stack, id, then), _ => Machine{w, rest, stack}),
    _ =>
      +pair = F.prepareAsyncWrite(w, id, result)
      +w = B.first(R.World, Bool, pair)
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => setResolved(w, Discard{} <> AsyncWriteAfterSetter{id, then} <> rest, stack, id, B.current(B.node(w, id)), value),
        _ => Machine{w, rest, stack}))

def stepDone(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  +s = B.stream(w, stream)
  +id = R.StreamState.node(s)
  +w = B.store_stream(w, stream, R.StreamState.with_completed(s, True{}))
  B.choose(~Machine, R.StreamState.hadValue(s),
    _ => Machine{B.schedule(w), AsyncFlush{} <> SettleAuto{id} <> rest, stack},
    _ => asyncWrite(w, SettleAuto{id} <> rest, stack, id, R.StreamState.result(s), R.Undefined{}, []))

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
              asyncWrite(w, rest, stack, id, R.StreamState.result(s), value, [IterateOrRelease{stream}]))))
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
        handleError(w, SettleAuto{id} <> rest, stack, id, R.StreamState.result(s), error),
      _ => Machine{w, rest, stack}))

def promiseFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  +id = R.AsyncObserver.node(o)
  +source = iterable(w, value)
  B.choose(~Machine, R.AsyncObserver.isSync(o), _ => Machine{F.syncFulfilled(w, observer, value), rest, stack},
    _ => B.choose(~Machine, Bool.and(Nat.is_ne(source, 0n), Bool.and(Nat.is_eq(R.NodeExtension.inFlight(B.extension(w, id)), R.AsyncObserver.result(o)), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())))),
      _ => consumeIterator(w, Discard{} <> ProtocolCatch{id, R.AsyncObserver.result(o), stack, False{}, True{}} <> rest, stack, id, R.AsyncObserver.result(o), source, True{}, R.Undefined{}),
      _ => asyncWrite(w, ProtocolCatch{id, R.AsyncObserver.result(o), stack, True{}, True{}} <> rest, stack, id, R.AsyncObserver.result(o), value, [])))

def flightFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(R.AsyncObserver.node(B.asyncObserver(w, observer)), 0n), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_ne(R.AsyncObserver.stream(B.asyncObserver(w, observer)), 0n),
      _ => stepFulfilledResult(w, rest, stack, observer, value), _ => promiseFulfill(w, rest, stack, observer, value)))

def promiseReject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +error: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  B.choose(~Machine, R.AsyncObserver.isSync(o), _ => Machine{F.syncRejected(w, observer, error), rest, stack},
    _ => handleError(w, SettleAuto{R.AsyncObserver.node(o)} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), error))

def flightReject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +error: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(R.AsyncObserver.node(B.asyncObserver(w, observer)), 0n), _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_ne(R.AsyncObserver.stream(B.asyncObserver(w, observer)), 0n),
      _ => stepRejected(w, rest, stack, observer, error), _ => promiseReject(w, rest, stack, observer, error)))

# Shared native thenable delivery requests. Action callbacks and reactive
# flights retain separate consumers below; the host only delivers requests.
def deliverObservers(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, observers: List<&2, Nat>, +immediate: Bool, +rejected: Bool, +value: R.Value) -> Machine:
  match observers:
    case Nil{}:
      Machine{w, rest, stack}
    case +id <> +tail:
      +again = {DeliverObservers{tail, immediate, rejected, value} : Task}
      B.choose(~Machine, immediate,
        _ => Machine{w, B.choose(~Task, rejected, _ => AsyncReject{id, value}, _ => AsyncFulfill{id, value}) <> again <> rest, stack},
        _ => Machine{F.enqueueDelivery(w, id, rejected, value), again <> rest, stack})

# core/action.ts:step, with an admitted user generator state chain. Advancing
# the protocol is user-code IO; no owner/tracking scope is invented here.
def actionStepMethods(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +rejected: Bool, +state: R.ActionState, methods: R.Expr) -> Machine:
  match methods:
    case R.ActionEnd{}:
      +w = Action.enter(w)
      +w = B.choose(~R.World, rejected, _ => R.World.with_fault(w, R.CallbackThrown{value}), _ => w)
      Machine{w, ActionStepReturn{id, stack} <> rest, R.StepResult{True{}, R.Undefined{}} <> stack}
    case R.ActionMethods{next, catches, thrown, tail}:
      +w = Action.enter(w)
      +w = Action.store(w, id, R.ActionState.with_methods(state, tail))
      +expr = B.choose(~R.Expr, rejected, _ => B.choose(~R.Expr, catches, _ => Z.bind(thrown, value, R.Boolean{True{}}), _ => R.Raise{value}),
        _ => Z.bind(next, value, R.Boolean{False{}}))
      Machine{w, Evaluate{expr, R.Undefined{}} <> ActionStepReturn{id, stack} <> rest, stack}

    case _:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, stack}

def actionStep(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +rejected: Bool) -> Machine:
  +state = Action.get(w, id)
  actionStepMethods(w, rest, stack, id, value, rejected, state, R.ActionState.methods(state))

def actionSettled(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +result: Nat, +rejected: Bool, +value: R.Value) -> Machine:
  +object = B.asyncObject(w, result)
  +w = B.store_asyncObject(w, result, R.AsyncObject.with_state(object, B.choose(~R.AsyncSettlement, rejected, _ => R.Rejected{value}, _ => R.Fulfilled{value})))
  +w = R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.ActionOutcome{result, rejected, value}]))
  Machine{w, DeliverObservers{R.AsyncObject.observers(object), False{}, rejected, value} <> rest, stack}

# Native Promise resolve IO: returned typed thenables are adopted in a later
# resolution microtask; rejection reasons remain raw data.
def actionOutputValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +rejected: Bool, value: R.Value) -> Machine:
  match value:
    case R.AsyncValue{+source}:
      B.choose(~Machine, Bool.and(Bool.not(rejected), Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w, source)), 0n)),
        _ => Machine{R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.ActionAdopt{id, R.AsyncValue{source}}])), rest, stack},
        _ => actionSettled(w, rest, stack, result, rejected, R.AsyncValue{source}))
    case other:
      actionSettled(w, rest, stack, result, rejected, other)

def actionOutputState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +rejected: Bool, +value: R.Value, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      actionOutputValue(w, rest, stack, id, result, rejected, value)
    case _:
      Machine{w, rest, stack}

def actionOutput(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +rejected: Bool, +value: R.Value) -> Machine:
  +result = R.ActionState.result(Action.get(w, id))
  actionOutputState(w, rest, stack, id, result, rejected, value, R.AsyncObject.state(B.asyncObject(w, result)))

# core/action.ts:done closes the resolved transaction before resolve/reject.
def actionDone(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, rejected: Bool, value: R.Value) -> Machine:
  actionOutput(Action.done(w, id), rest, stack, id, rejected, value)

# run's bare-yield arm and the once-only yielded-value callbacks share exactly
# this inTransaction entry. Restoration is a normal return, not a finally.

def actionResume(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, value: R.Value, rejected: Bool) -> Machine:
  +previous = R.World.question(w)
  +state = Action.get(w, id)
  +w = Question.setQuestion(w, R.ActionState.question(state))
  +w = X.joinFuture(w, R.ActionState.transaction(state))
  actionStep(w, ActionSliceEnd{previous} <> rest, stack, id, value, rejected)

def actionSubscribed(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +immediate: Bool, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      Machine{w, rest, stack}
    case R.Fulfilled{value}:
      deliverObservers(w, rest, stack, [observer], immediate, False{}, value)
    case R.Rejected{error}:
      deliverObservers(w, rest, stack, [observer], immediate, True{}, error)

def actionSubscribe(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, id: Nat, +result: Nat, +kind: U32) -> Machine:
  +pair = Action.wait(w, id, result, kind)
  +w = B.first(R.World, Nat, pair)
  +observer = B.second(R.World, Nat, pair)
  +object = B.asyncObject(w, result)
  +ending = B.choose(~List<&2, Task>, U32.is_eq(kind, 0), _ => ActionYieldCatch{observer, stack} <> rest, _ => rest)
  actionSubscribed(w, ending, stack, observer, R.AsyncObject.immediate(object), R.AsyncObject.state(object))

def actionYield(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value) -> Machine:
  match value:
    case R.AsyncValue{+source}:
      B.choose(~Machine, Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w, source)), 0n),
        _ => actionSubscribe(w, rest, stack, id, source, 0),
        _ => actionResume(w, rest, stack, id, value, False{}))
    case _:
      actionResume(w, rest, stack, id, value, False{})

def actionRun(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, result: R.Value) -> Machine:
  match result:
    case R.StepResult{+done, +value}:
      B.choose(~Machine, done, _ => actionDone(w, rest, stack, id, False{}, value),
        _ => actionYield(w, rest, stack, id, value))
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, stack}

def actionStepResult(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +id: Nat, result: R.Value) -> Machine:
  match result:
    case R.AsyncValue{+source}:
      actionSubscribe(w, rest, saved, id, source, 1)
    case other:
      actionRun(w, rest, saved, id, other)

# A yielded-value callback owns a local settled cell. Iterator-result promises
# use their separate completion arm; their rejection never re-enters throw().

def actionStepValue(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +id: Nat, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case result <> tail:
      actionStepResult(w, rest, saved, id, result)
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{24n}), rest, saved}

def actionStepFault(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{error}:
      actionDone(R.World.with_fault(w, R.Healthy{}), rest, saved, id, True{}, error)
    case R.Healthy{}:
      actionStepValue(w, rest, saved, id, stack)
    case _:
      Machine{w, rest, saved}

def actionStepReturn(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +saved: List<&2, R.Value>) -> Machine:
  +w = Action.exit(w)
  actionStepFault(w, rest, stack, id, saved, R.World.fault(w))

def actionDelivery(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +entry: R.ActionWait, +rejected: Bool, +value: R.Value) -> Machine:
  +id = R.ActionWait.action(entry)
  B.choose(~Machine, Bool.and(U32.is_eq(R.ActionWait.kind(entry), 0), R.ActionWait.settled(entry)),
    _ => Machine{w, rest, stack},
    _ =>
      +w = R.World.with_actionWaits(w, Action.settleWait(R.World.actionWaits(w), R.ActionWait.observer(entry)))
      B.choose(~Machine, U32.is_eq(R.ActionWait.kind(entry), 0),
        _ => actionResume(w, rest, stack, id, value, rejected),
        _ => B.choose(~Machine, U32.is_eq(R.ActionWait.kind(entry), 1),
          _ => B.choose(~Machine, rejected, _ => actionDone(w, rest, stack, id, True{}, value), _ => actionRun(w, rest, stack, id, value)),
          _ => actionOutput(w, rest, stack, id, rejected, value))))

def asyncActionDelivery(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +rejected: Bool, +value: R.Value, found: Maybe<&2, R.ActionWait>) -> Machine:
  match found:
    case Some{entry}:
      actionDelivery(w, rest, stack, entry, rejected, value)
    case None{}:
      B.choose(~Machine, rejected, _ => flightReject(w, rest, stack, observer, value), _ => flightFulfill(w, rest, stack, observer, value))

def asyncFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  asyncActionDelivery(w, rest, stack, observer, False{}, value, Action.find(R.World.actionWaits(w), observer))

def asyncReject(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  asyncActionDelivery(w, rest, stack, observer, True{}, value, Action.find(R.World.actionWaits(w), observer))

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
def effectFinally(+w: R.World, +rest: List<&2, Task>, +id: Nat, clean: Bool, +saved: List<&2, R.Value>) -> Machine:
  +w = effectCatch(w, id, R.World.fault(w))
  +w = B.store_node(w, id, R.Node.with_prevValue(B.node(w, id), R.Node.value(B.node(w, id))))
  +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{}))
  B.choose(~Machine, clean,
    _ =>
      prior = R.World.fault(w)
      Machine{R.World.with_fault(w, R.Healthy{}), OwnerTasks{[O.TrimDeps{id}]} <> TrimFinallyRestore{prior, saved} <> rest, saved},
    _ => Machine{w, rest, saved})

# core/effect.ts:runEffect's assignment after the actual application callback.
# Callable IDs represent the original function identity in the owner walk.
def installReturned(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  match stack:
    case value <> +tail:
      match value:
        case R.Undefined{}:
          Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), 0n)), rest, tail}
        case R.RootDisposerReference{root}:
          +pair = J.encode(w, root)
          +w = B.first(R.World, Nat, pair)
          Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), B.second(R.World, Nat, pair))), rest, tail}
        case R.ProgramReference{+callback}:
          B.choose(~Machine, callbackExists(w, callback),
            _ =>
              +pair = J.encodeProgram(w, callback)
              +w = B.first(R.World, Nat, pair)
              Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), B.second(R.World, Nat, pair))), rest, tail},
            _ => Machine{R.World.with_fault(w, R.Unsupported{9n}), rest, tail})
        case R.SetterReference{signal}:
          +pair = J.encodeSetter(w, signal)
          +w = B.first(R.World, Nat, pair)
          Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), B.second(R.World, Nat, pair))), rest, tail}
        case R.AccessorReference{signal}:
          +pair = J.encodeAccessor(w, signal)
          +w = B.first(R.World, Nat, pair)
          Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), B.second(R.World, Nat, pair))), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.Unsupported{9n}), rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}

# The user-code wrapper records application and runs its body. Existing static
# wrappers discard ordinary returns; return-valued wrappers preserve the result
# until runEffect's _cleanup assignment. Throws skip both assignment tasks.
def applyEffect(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = B.event(w, R.Applied{id, R.Node.value(B.node(w, id)), R.Node.prevValue(B.node(w, id))})
  +w = B.choose(~R.World, S.is_user(R.Node.kind(B.node(w, id))), _ => w,
    _ => T.setText(w, R.Node.target(B.node(w, id)), R.Node.value(B.node(w, id))))
  +callback = R.Node.effectProgram(B.node(w, id))
  +returnsCleanup = R.CleanupProgram.returnsCleanup(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}}))
  +call = {Evaluate{R.CallWith{callback, R.Literal{R.Node.value(B.node(w, id))}, R.Literal{R.Node.prevValue(B.node(w, id))}}, R.Undefined{}} : Task}
  +todo = B.choose(~List<&2, Task>, Nat.is_ne(callback, 0n),
    _ => B.choose(~List<&2, Task>, returnsCleanup,
      _ => [call], _ => [call, Discard{}]), _ => [])
  ending = B.choose(~Task, returnsCleanup, _ => InstallReturnedCleanup{id}, _ => InstallEffectCleanup{id})
  Machine{w, B.append(Task, todo, ending <> rest), stack}

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
        +ending = {ApplyEffect{id} <> EffectFinally{id, clean, stack} <> rest : List<&2, Task>}
        todo = B.choose(~List<&2, Task>, Nat.is_ne(prevCleanup, 0n), _ => OwnerTasks{[O.Invoke{prevCleanup}]} <> ending, _ => ending)
        Machine{w, todo, stack}),
    _ => Machine{w, rest, stack})

def queue_tasks(+w: R.World, ids: List<&2, Nat>) -> List<&2, Task>:
  match ids:
    case Nil{}:
      []
    case +id <> +rest:
      B.choose(~Task, B.tracked(R.Node.kind(B.node(w, id))), _ => RunTracked{id}, _ => RunEffect{id}) <> queue_tasks(w, rest)

# Source user queues hold callable identities, including node-free onSettled.fire.
def user_task(+w: R.World, entry: R.QueueEntry) -> Task:
  match entry:
    case R.NodeRun{+id}:
      B.choose(~Task, B.tracked(R.Node.kind(B.node(w, id))), _ => RunTracked{id}, _ => RunEffect{id})
    case R.SettledFire{callback}:
      FireSettled{callback}

def user_tasks(+w: R.World, entries: List<&2, R.QueueEntry>) -> List<&2, Task>:
  match entries:
    case Nil{}:
      []
    case entry <> tail:
      user_task(w, entry) <> user_tasks(w, tail)

# signals.ts:onSettled.fire. Requeue the same closure while derivations remain;
# production drops its result. A throw retains the queue's existing unwind path.
def fireSettled(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +callback: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(R.World.maximum(w), R.World.minimum(w)),
    _ => Machine{W.enqueueUserCallback(w, R.SettledFire{callback}), rest, stack},
    _ => Machine{w, Evaluate{B.get(R.Expr, R.World.settledCallbacks(w), callback, R.Literal{R.Undefined{}}), R.Undefined{}} <> Discard{} <> rest, stack})

# core/effect.ts:trackedEffect.run. Multiple heap visits can enqueue this same
# bound closure: modified deduplicates its actual pass, not its queue entries.
def runTracked(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, Bool.and(R.Node.modified(B.node(w, id)), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()))),
    _ => Machine{B.store_node(w, id, R.Node.with_modified(B.node(w, id), False{})), Recompute{id, False{}} <> rest, stack},
    _ => Machine{w, rest, stack})

# core.ts:GlobalQueue._update. Tracked effects visit the heap before the seam
# and enqueue their _run in the user phase; their body executes only afterward.
def visitHeap(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, B.tracked(R.Node.kind(B.node(w, id))),
    _ =>
      +w = H.deleteFromHeap(w, id)
      +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))
      Machine{S.enqueue(w, id), HeapLoop{} <> rest, stack},
    _ => B.choose(~Machine, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_LANE_DIRTY()))),
      _ => Machine{S.deferZombie(w, id), HeapLoop{} <> rest, stack},
      _ => Machine{w, Recompute{id, False{}} <> HeapLoop{} <> rest, stack}))

def heapLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  B.choose(~Machine, Nat.is_gt(R.World.minimum(w), R.World.maximum(w)),
    _ => Machine{R.World.with_maximum(w, 0n), Seam{} <> rest, stack},
    _ =>
      +id = B.bucket(w, R.World.minimum(w))
      B.choose(~Machine, Nat.is_eq(id, 0n),
        _ => Machine{R.World.with_minimum(w, 1n+R.World.minimum(w)), HeapLoop{} <> rest, stack},
        _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), 8),
          _ => visitHeap(w, rest, stack, id),
          _ => Machine{H.adjustHeight(w, id), HeapLoop{} <> rest, stack})))

def round(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +w = R.World.with_running(w, True{})
  +w = V.resyncUnflushedCompanions(w)
  +w = R.World.with_passTx(R.World.with_passLane(w, 0n), 0n)
  +ending = {RoundAfterSweep{} <> FlushFinally{} <> RoundEnd{} <> rest : List<&2, Task>}
  todo = B.choose(~List<&2, Task>, List.is_empty(&2, Nat, R.World.dormantNodes(w)), _ => ending, _ => OwnerTasks{[O.SweepDormant{0n}]} <> ending)
  Machine{w, todo, stack}

# scheduler.ts:GlobalQueue.settle, before the transaction landing loop.
def commitPending(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, B.computed(R.Node.kind(B.node(w, id))),
    _ =>
      +pair = S.commitComputedPrefix(w, id)
      Machine{B.first(R.World, Bool, pair), CommitFinish{id, B.second(R.World, Bool, pair)} <> rest, stack},
    _ => Machine{S.commitSignal(w, id), rest, stack})

def commitFinish(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +inFlight: Bool) -> Machine:
  +w = S.finishCommitFields(w, id)
  +ending = {CommitAfterTrim{id, inFlight} <> rest : List<&2, Task>}
  todo = B.choose(~List<&2, Task>, B.nullish(R.NodeExtension.error(B.extension(w, id))),
    _ => OwnerTasks{[O.TrimDeps{id}]} <> ending, _ => ending)
  Machine{w, todo, stack}

def commitAfterTrim(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, inFlight: Bool) -> Machine:
  +w = S.afterCommitTrim(w, id)
  B.choose(~Machine, S.disposeCommittedFrame(w, id, inFlight),
    _ => Machine{w, OwnerTasks{[O.Enter{id, False{}, True{}}]} <> rest, stack}, _ => Machine{w, rest, stack})

# Live source pendingNodes.length and heldTrims.length; clears stay after walks.
def commitIntake(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.World.pendingNodes(w))),
    _ => Machine{R.World.with_pendingNodes(w, []), rest, stack},
    _ =>
      +id = B.get(Nat, R.World.pendingNodes(w), index, 0n)
      +ending = {CommitIntake{1n+index} <> rest : List<&2, Task>}
      todo = B.choose(~List<&2, Task>, B.has(R.Node.config(B.node(w, id)), B.set(K.CONFIG_OVERRIDE(), K.CONFIG_HELD())),
        _ => ending, _ => CommitPending{id} <> ending)
      Machine{w, todo, stack})

def trimIntake(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.World.trims(w))), _ => Machine{w, rest, stack},
    _ =>
      +id = B.get(Nat, R.World.trims(w), index, 0n)
      +ending = {TrimIntake{1n+index} <> rest : List<&2, Task>}
      todo = B.choose(~List<&2, Task>, Bool.and(B.nullish(R.NodeExtension.error(B.extension(w, id))), Bool.not(R.Node.modified(B.node(w, id)))),
        _ => OwnerTasks{[O.TrimDeps{id}]} <> ending, _ => ending)
      Machine{w, todo, stack})

def finishSettleIntake(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +t: Nat) -> Machine:
  +w = S.clearTrims(w)
  frame = {SeamFrame{t, R.World.renderQueue(w), R.World.userQueue(w)} : SeamFrame}
  +w = R.World.with_renderQueue(R.World.with_userQueue(w, []), [])
  Machine{w, LandTransactions{frame, B.length(Nat, R.World.transactions(w))} <> rest, stack}

def parkIntake(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +t: Nat, +index: Nat, +count: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, count), _ => Machine{w, rest, stack},
    _ =>
      +id = B.get(Nat, R.World.pendingNodes(w), index, 0n)
      +ending = {ParkIntake{t, 1n+index, count} <> rest : List<&2, Task>}
      B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
        _ => Machine{S.parkPendingNode(w, id, t), ending, stack},
        _ =>
          +eligible = S.parkEligible(w, id)
          B.choose(~Machine, Bool.and(eligible, S.parkLoading(w, id)), _ => Machine{w, ending, stack},
            _ => B.choose(~Machine, Bool.and(eligible, S.parkCanCompare(w, id)),
              _ => isSame(w, ParkCompared{id, t, index, count} <> rest, stack, id, R.Node.value(B.node(w, id)), B.current(B.node(w, id))),
              _ => Machine{S.parkChanged(w, id, t, eligible), ending, stack}))))

def beginSettle(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +joined = R.World.flushTransaction(w)
  +w = R.World.with_flushTransaction(w, 0n)
  +pair = B.choose(~B.Bundle<R.World, Nat>, Bool.and(Nat.is_ne(joined, 0n), Bool.not(R.Transaction.lane(B.transaction(w, joined)))),
    _ => X.resolveTx(w, joined), _ => B.Bundle{w, 0n})
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  B.choose(~Machine, Nat.is_ne(t, 0n),
    _ =>
      B.choose(~Machine, List.is_empty(&2, R.ComparatorBinding, R.World.comparators(w)),
        _ =>
          +w = S.parkPendingNodes(w, t)
          w = B.choose(~R.World, B.ok(w), _ => R.World.with_deferredZombies(w, []), _ => w)
          Machine{w, FinishSettleIntake{t} <> rest, stack},
        _ => Machine{w, ParkIntake{t, 0n, B.length(Nat, R.World.pendingNodes(w))} <> AfterPark{t} <> rest, stack}),
    _ => Machine{w, CommitIntake{0n} <> TrimIntake{0n} <> FinishSettleIntake{t} <> rest, stack})

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
      +ending = {LandNodes{frame, t, 1n+index} <> rest : List<&2, Task>}
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => Machine{B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n)), CommitPending{id} <> ending, stack},
        _ => Machine{w, ending, stack}))

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
          B.store_transaction(w, live, R.Transaction.with_userQueue(B.transaction(w, live), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, live)), users))),
        _ =>
          +w = R.World.with_renderQueue(w, B.append(Nat, renders, R.World.renderQueue(w)))
          R.World.with_userQueue(w, B.append(R.QueueEntry, users, R.World.userQueue(w))))
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

def ownerResume(+rest: List<&2, Task>, +stack: List<&2, R.Value>, machine: O.Machine) -> Machine:
  match machine:
    case O.Machine{world, tasks}:
      Machine{world, OwnerTasks{tasks} <> rest, stack}

# Same owner dispatcher, resumed after core has executed the user callback.
# The owner walk neither changes ambient context/tracking nor observes a return.
def ownerTasks(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, tasks: List<&2, O.Task>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, rest, stack}
    case O.Invoke{callback} <> tail:
      Machine{w, Evaluate{R.CallProgram{callback}, R.Undefined{}} <> Discard{} <> OwnerTasks{tail} <> rest, stack}
    case O.WriteValue{+id, current, value} <> tail:
      setResolved(w, Discard{} <> OwnerTasks{tail} <> rest, stack, id, current, value)
    case O.WriteForward{+id, value} <> tail:
      +w = MW.recover(w, id)
      setResolved(w, Discard{} <> OwnerTasks{tail} <> rest, stack, id, B.current(B.node(w, id)), value)
    case O.Action{callback, R.CleanupBoundSetter{id}} <> tail:
      Machine{w, setterTask(w, id) <> Discard{} <> OwnerTasks{tail} <> rest, R.Undefined{} <> stack}
    case other:
      ownerResume(rest, stack, O.dispatch(w, other))

def dispatch(+w: R.World, tasks: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case Nil{}:
      Machine{w, [], stack}
    case ActionOpened{+id} <> rest:
      +w = Action.open(w, id)
      +w = X.joinFuture(w, R.ActionState.transaction(Action.get(w, id)))
      +question = R.World.question(w)
      +w = Question.setQuestion(w, R.ActionState.question(Action.get(w, id)))
      actionStep(w, ActionRestoreQuestion{question} <> rest, stack, id, R.Undefined{}, False{})
    case ActionExecutorEnd{+id, saved} <> rest:
      Machine{w, rest, R.AsyncValue{R.ActionState.result(Action.get(w, id))} <> saved}
    case ActionStepReturn{id, saved} <> rest:
      actionStepReturn(w, rest, stack, id, saved)
    case ActionSliceEnd{question} <> +rest:
      +ending = {ActionRestoreQuestion{question} <> rest : List<&2, Task>}
      B.choose(~Machine, Nat.is_eq(R.World.actionDepth(w), 0n),
        _ => publicFlush(w, ending, stack), _ => Machine{w, ending, stack})
    case ActionRestoreQuestion{question} <> rest:
      Machine{Question.setQuestion(w, question), rest, stack}
    case ActionYieldCatch{observer, saved} <> rest:
      Machine{w, rest, stack}
    case IteratorResultValue{done} <> rest:
      match stack:
        case value <> tail:
          Machine{w, rest, R.StepResult{done, value} <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}
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
            _ => Machine{w, Callback{id, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), id, R.CleanupProgram{[], False{}})), first, second} <> rest, tail},
            _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), rest, tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case CreateSignal{+options, +body, +previous} <> +rest:
      match stack:
        case +value <> +tail:
          match value:
            case R.RootDisposerReference{owner}:
              callableSignal(w, rest, tail, R.RootDisposerReference{owner}, options, body, previous)
            case R.AccessorReference{signal}:
              callableSignal(w, rest, tail, R.AccessorReference{signal}, options, body, previous)
            case R.ProgramReference{callback}:
              callableSignal(w, rest, tail, R.ProgramReference{callback}, options, body, previous)
            case R.SetterReference{signal}:
              callableSignal(w, rest, tail, R.SetterReference{signal}, options, body, previous)
            case other:
              +id = B.length(R.Node, R.World.nodes(w))
              +w = B.event(w, R.Constructed{id})
              Machine{N.signal(w, other, options), Evaluate{Local.bind(body, 0n, id), previous} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MemoAccessorReady{node} <> rest:
      Machine{B.event(w, R.AccessorBound{node}), rest, stack}
    case MemoSignalReady{+signal, body, previous} <> rest:
      +w = B.store_node(w, signal, R.Node.with_config(B.node(w, signal), B.clear(R.Node.config(B.node(w, signal)), K.CONFIG_AUTO_DISPOSE())))
      # User ABI observation: the constructor returned its actual const pair.
      # Failed constructors never bind/return that setter function.
      +w = B.event(w, R.SetterBound{signal})
      Machine{w, Evaluate{Local.bind(body, 0n, signal), previous} <> rest, stack}
    case EqualityCatch{id, saved} <> rest:
      Machine{w, rest, stack}
    case SetSignalCompared{+id, +value} <> rest:
      match stack:
        case equal <> tail:
          Machine{B.choose(~R.World, B.truth(equal), _ => w, _ => W.stageResolved(w, id, value)), rest, value <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case PublishCompared{id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr} <> rest:
      match stack:
        case equal <> tail:
          publishCompared(w, rest, tail, id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, Bool.not(B.truth(equal)))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case SetMemoArgument{+signal} <> +rest:
      match stack:
        case +value <> +tail:
          +pair = MW.held(w, signal)
          +w = B.first(R.World, Bool, pair)
          +held = B.second(R.World, Bool, pair)
          B.choose(~Machine, held,
            _ => memoRawArgument(w, rest, tail, signal, value),
            _ => memoDelegate(w, rest, value <> tail, signal, False{}, False{}))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case SetMemoForward{+signal, held} <> rest:
      memoDelegate(w, rest, stack, signal, held, True{})
    case SetMemoAfter{signal, held} <> rest:
      Machine{MW.finish(w, signal, held), rest, stack}
    case SetSignalArgument{signal} <> rest:
      match stack:
        case value <> tail:
          setSignalArgument(w, rest, tail, signal, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case SetSignalResolved{signal, current} <> rest:
      match stack:
        case +value <> tail:
          setResolved(w, rest, tail, signal, current, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case CommitPending{id} <> rest:
      commitPending(w, rest, stack, id)
    case CommitFinish{id, inFlight} <> rest:
      commitFinish(w, rest, stack, id, inFlight)
    case CommitAfterTrim{id, inFlight} <> rest:
      commitAfterTrim(w, rest, stack, id, inFlight)
    case CommitIntake{index} <> rest:
      commitIntake(w, rest, stack, index)
    case TrimIntake{index} <> rest:
      trimIntake(w, rest, stack, index)
    case FinishSettleIntake{t} <> rest:
      finishSettleIntake(w, rest, stack, t)
    case FinishPublication{id, create, joined, missed} <> rest:
      finishPublication(w, rest, stack, id, create, joined, missed)
    case QueuePublication{+id, create, missed} <> rest:
      +w = queuePublication(w, id, create)
      w = B.choose(~R.World, Bool.and(B.ok(w), missed), _ => B.schedule(H.enqueueSub(w, id)), _ => w)
      Machine{w, rest, stack}
    case AfterDeadPass{+id} <> rest:
      w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), _ => w)
      Machine{w, rest, stack}
    case TrimFinallyRestore{prior, saved} <> rest:
      Machine{R.World.with_fault(w, prior), rest, saved}
    case RoundAfterSweep{} <> rest:
      w = R.World.with_minimum(R.World.with_marked(w, False{}), 0n)
      Machine{w, HeapLoop{} <> rest, stack}
    case OwnerTasks{tasks} <> rest:
      ownerTasks(w, rest, stack, tasks)
    case PendingTasks{tasks, visited, released, scheduled} <> rest:
      pendingTasks(w, rest, stack, tasks, visited, released, scheduled)
    case RetireSources{id, set, index, onlyDropped} <> rest:
      retireSources(w, rest, stack, id, set, index, onlyDropped)
    case PublishSettleSelf{+id, wasPendingSource} <> +rest:
      B.choose(~Machine, Bool.and(wasPendingSource, Bool.not(B.has(R.Node.status(B.node(w, id)), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED())))),
        _ => pendingResume(rest, stack, Q.beginSettlement(w, id, id)), _ => Machine{w, rest, stack})
    case CatchStageSettle{frame} <> rest:
      +id = passId(frame)
      pendingResume(rest, stack, Q.beginSettlement(w, id, id))
    case CatchStageFinish{frame} <> rest:
      catchNotify(B.schedule(w), rest, frame, R.Undefined{}, False{}, True{})
    case CatchSelfRetire{frame, notReady, stagedErr} <> rest:
      catchSelfRetire(w, rest, stack, frame, notReady, stagedErr)
    case CatchRetireSources{frame, retire} <> rest:
      catchRetireSources(w, rest, stack, frame, retire)
    case CatchFinally{frame, stagedErr} <> rest:
      finishCatch(w, rest, frame, stagedErr)
    case RecomputeAfterFlight{id} <> rest:
      recomputeAfterFlight(w, rest, stack, id)
    case RestoreDeferredReleases{id, previous, released} <> rest:
      Machine{R.World.with_deferredReleases(w, previous), RecomputeAfterTeardown{id, released} <> rest, stack}
    case RecomputeAfterTeardown{id, released} <> rest:
      recomputeAfterTeardown(w, rest, stack, id, released)
    case RecomputePrepared{id, create, released} <> rest:
      recomputePrepared(w, rest, stack, id, create, released)
    case PassReleases{frame, index, value, joined, stagedErr, missed, prior} <> rest:
      passReleases(w, rest, stack, frame, index, value, joined, stagedErr, missed, prior)
    case InvokeManyCallee{args, previous} <> rest:
      match stack:
        case callee <> tail:
          invokeManyArguments(w, rest, tail, callee, args, [], previous)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case InvokeManyValue{callee, args, reversed, previous} <> rest:
      match stack:
        case value <> tail:
          invokeManyArguments(w, rest, tail, callee, args, value <> reversed, previous)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case InvokeArguments{} <> +rest:
      match stack:
        case second <> first <> callee <> tail:
          match callee:
            case R.ProgramReference{callback}:
              Machine{w, Evaluate{R.CallWith{callback, R.Literal{first}, R.Literal{second}}, R.Undefined{}} <> rest, tail}
            case other:
              invokeApplied(w, rest, tail, other, first)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case InvokeArgument{+value, +updater, +previous} <> +rest:
      match stack:
        case +callee <> +tail:
          B.choose(~Machine, updater,
            _ => invokeUpdater(w, rest, tail, callee, value),
            _ => Machine{w, Evaluate{value, previous} <> InvokeApplied{callee} <> rest, tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case InvokeApplied{callee} <> rest:
      match stack:
        case value <> tail:
          invokeApplied(w, rest, tail, callee, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case Invoke{} <> rest:
      invoke(w, rest, stack)
    case OnCleanup{} <> rest:
      onCleanup(w, rest, stack)
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
    case RestoreStale{stale} <> rest:
      Machine{R.World.with_stale(w, stale), rest, stack}
    case EnterOwner{body, previous} <> rest:
      enterOwner(w, rest, stack, body, previous)
    case RestoreContext{owner, tracking} <> rest:
      Machine{L.restore(w, owner, tracking), rest, stack}
    case CheckDisposed{} <> rest:
      checkDisposed(w, rest, stack)
    case DisposeRoot{self} <> rest:
      disposeRoot(w, rest, stack, self)
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
    case ThenRejected{frame, error} <> rest:
      catchPass(R.World.with_fault(w, R.CallbackThrown{error}), rest, frame)
    case AfterIterator{frame} <> rest:
      afterIterator(w, rest, stack, frame)
    case IterateStream{stream} <> rest:
      iterateStream(w, rest, stack, stream)
    case AfterStep{observer} <> rest:
      afterStep(w, rest, stack, observer)
    case StepRejectedReturn{error, initial} <> rest:
      Machine{B.choose(~R.World, initial, _ => R.World.with_fault(w, R.CallbackThrown{error}), _ => w), rest, R.Boolean{True{}} <> stack}
    case AfterConsume{stream} <> rest:
      afterConsume(w, rest, stack, stream)
    case IterateOrRelease{+stream} <> +rest:
      +s = B.stream(w, stream)
      +ending = {ProtocolCatch{R.StreamState.node(s), R.StreamState.result(s), stack, False{}, False{}} <> rest : List<&2, Task>}
      Machine{w, B.choose(~List<&2, Task>, F.shouldSettleAutodispose(w, R.StreamState.node(s)),
        _ => OwnerTasks{[O.Unobserved{R.StreamState.node(s)}]} <> ending,
        _ => IterateStream{stream} <> Discard{} <> ending), stack}
    case ProtocolCatch{id, result, saved, successAuto, errorAuto} <> +rest:
      Machine{w, B.choose(~List<&2, Task>, successAuto, _ => SettleAuto{id} <> rest, _ => rest), stack}
    case AsyncFulfill{observer, value} <> rest:
      asyncFulfill(w, rest, stack, observer, value)
    case AsyncReject{observer, error} <> rest:
      asyncReject(w, rest, stack, observer, error)
    case AsyncFlush{} <> +rest:
      publicFlush(w, rest, stack)
    case AsyncWriteAfterSetter{id, then} <> rest:
      asyncWriteAfterValue(w, rest, stack, id, then)
    case AsyncWriteAfterTrim{+id} <> rest:
      pendingResume(rest, stack, Q.beginSettlement(w, id, id))
    case AsyncWriteSchedule{} <> rest:
      Machine{B.schedule(w), rest, stack}
    case ErrorStageSettle{+id, error} <> rest:
      pendingResume(ErrorAfterStage{id, error} <> rest, stack, Q.beginSettlement(w, id, id))
    case ErrorAfterStage{id, error} <> rest:
      handleErrorNotify(B.schedule(w), rest, stack, id, error, False{}, True{})
    case ErrorSettleSource{+id} <> rest:
      pendingResume(ErrorAfterPending{id, True{}} <> rest, stack, Q.beginSettlement(w, id, id))
    case ErrorAfterPending{id, pending} <> rest:
      finishHandleError(w, rest, stack, id, pending)
    case SettleAuto{+id} <> +rest:
      Machine{w, B.choose(~List<&2, Task>, F.shouldSettleAutodispose(w, id),
        _ => OwnerTasks{[O.Unobserved{id}]} <> rest, _ => rest), stack}
    case DeliverObservers{observers, immediate, rejected, value} <> rest:
      deliverObservers(w, rest, stack, observers, immediate, rejected, value)
    case InitialEffect{+id, +scheduled, deferred} <> +rest:
      B.choose(~Machine, Bool.or(deferred, Bool.or(B.present(R.Node.pending(B.node(w, id))), R.Transaction.lane(B.transaction(w, R.NodeExtension.transaction(B.extension(w, id)))))), _ => Machine{w, rest, stack},
        _ => B.choose(~Machine, Bool.or(scheduled, S.is_user(R.Node.kind(B.node(w, id)))),
          _ => Machine{S.enqueue(w, id), rest, stack}, _ => Machine{w, RunEffect{id} <> rest, stack}))
    case RunEffect{id} <> +rest:
      runEffect(w, rest, stack, id)
    case ReactionArmValue{tracking} <> rest:
      match stack:
        case R.ProgramReference{callback} <> tail:
          reactionArmExpression(w, rest, tail, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}})), tracking)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}
    case ReactionArmClear{+reaction} <> rest:
      Machine{Reaction.store(w, reaction, R.ReactionState.with_arm(Reaction.get(w, reaction), 0n)), rest, stack}
    case ReactionArmAfterDispose{reaction, tracking} <> rest:
      reactionArmAfterDispose(w, rest, stack, reaction, tracking)
    case ReactionReturn{node} <> rest:
      Machine{w, rest, R.OwnerReference{node} <> stack}
    case ReactionFireValue{reaction} <> rest:
      match stack:
        case R.OwnerReference{node} <> tail:
          reactionFire(w, rest, tail, reaction, node)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}
    case ReactionCallBody{+reaction, node} <> rest:
      Machine{w, Evaluate{R.ReactionState.body(Reaction.get(w, reaction)), R.Undefined{}} <> ReactionAssignCleanup{reaction, node} <> rest, stack}
    case ReactionAssignCleanup{+reaction, node} <> rest:
      match stack:
        case value <> tail:
          Machine{Reaction.store(w, reaction, R.ReactionState.with_cleanup(Reaction.get(w, reaction), value)), OwnerTasks{[O.Dispose{node}]} <> Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, stack}
    case FireSettled{callback} <> rest:
      fireSettled(w, rest, stack, callback)
    case RunTracked{id} <> rest:
      runTracked(w, rest, stack, id)
    case TrackedAfterCleanup{+id, body} <> rest:
      Machine{R.World.with_stale(B.event(w, R.Invoked{id}), True{}), Evaluate{body, R.Undefined{}} <> RestoreStale{R.World.stale(w)} <> InstallReturnedCleanup{id} <> Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}} <> rest, stack}
    case ApplyEffect{id} <> rest:
      applyEffect(w, rest, stack, id)
    case InstallEffectCleanup{+id} <> rest:
      Machine{B.store_node(w, id, R.Node.with_cleanup(B.node(w, id), R.Node.returnedCleanup(B.node(w, id)))), rest, stack}
    case InstallReturnedCleanup{id} <> rest:
      installReturned(w, rest, stack, id)
    case EffectFinally{id, clean, saved} <> rest:
      effectFinally(w, rest, id, clean, saved)
    case ErrorArmFinally{parameter, saved} <> rest:
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.fault(w)), rest, saved}
    case FlushArgument{} <> +rest:
      match stack:
        case +callee <> +tail:
          B.choose(~Machine, B.truth(callee),
            _ => flushEntry(w, rest, tail, R.Invoke{R.Literal{callee}}, R.Undefined{}),
            _ => publicFlush(w, rest, R.Undefined{} <> tail))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FlushCallbackFinally{saved} <> rest:
      flushCallbackFinally(w, rest, stack, saved)
    case FlushCallbackRestore{prior, saved} <> rest:
      flushCallbackRestore(w, rest, saved, prior)
    case Round{} <> +rest:
      round(w, rest, stack)
    case HeapLoop{} <> +rest:
      heapLoop(w, rest, stack)
    case Seam{} <> rest:
      Machine{w, Settle{} <> AfterSettle{} <> rest, stack}
    case ParkIntake{t, index, count} <> rest:
      parkIntake(w, rest, stack, t, index, count)
    case ParkCompared{+id, +t, index, count} <> rest:
      match stack:
        case equal <> tail:
          Machine{B.choose(~R.World, B.truth(equal), _ => S.parkEqual(w, id), _ => S.parkChanged(w, id, t, True{})), ParkIntake{t, 1n+index, count} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case AfterPark{t} <> rest:
      Machine{R.World.with_deferredZombies(R.World.with_pendingNodes(w, []), []), FinishSettleIntake{t} <> rest, stack}
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
        _ => Machine{R.World.with_renderQueue(w, []), B.append(Task, queue_tasks(w, R.World.renderQueue(w)), UserQueue{} <> rest), stack})
    case UserQueue{} <> +rest:
      B.choose(~Machine, List.is_empty(&2, R.QueueEntry, R.World.userQueue(w)),
        _ => Machine{w, rest, stack},
        _ => Machine{R.World.with_userQueue(w, []), B.append(Task, user_tasks(w, R.World.userQueue(w)), rest), stack})
    case FlushFinally{} <> rest:
      Machine{R.World.with_passTx(R.World.with_running(w, False{}), 0n), rest, stack}
    case RoundEnd{} <> +rest:
      todo = B.choose(~List<&2, Task>, R.World.scheduled(w), _ => Round{} <> rest, _ => rest)
      Machine{w, todo, stack}

# Source exceptions skip ordinary continuations and execute enclosing finally
# frames. Cleanup throws before the compute try do not become node status here.
def catchProtocol(+w: R.World, +rest: List<&2, Task>, saved: List<&2, R.Value>, +id: Nat, result: Nat, errorAuto: Bool, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{error}:
      handleError(R.World.with_fault(w, R.Healthy{}), B.choose(~List<&2, Task>, errorAuto, _ => SettleAuto{id} <> rest, _ => rest), saved, id, result, error)
    case other:
      Machine{w, rest, saved}

# run's catch surrounds the .then call, including callbacks invoked before it
# returns. A throw after the first callback is ignored; a throw before it is
# delivered to the generator. Later callbacks execute outside this catch.
def actionYieldCaught(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +error: R.Value, found: Maybe<&2, R.ActionWait>) -> Machine:
  match found:
    case Some{+entry}:
      +w = R.World.with_fault(w, R.Healthy{})
      B.choose(~Machine, R.ActionWait.settled(entry), _ => Machine{w, rest, saved},
        _ => actionDelivery(w, rest, saved, entry, True{}, error))
    case None{}:
      Machine{w, rest, saved}

def actionYieldThrow(+w: R.World, rest: List<&2, Task>, saved: List<&2, R.Value>, observer: Nat, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{error}:
      actionYieldCaught(w, rest, saved, error, Action.find(R.World.actionWaits(w), observer))
    case _:
      Machine{w, rest, saved}

def actionExecutorThrow(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +id: Nat, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{error}:
      actionOutput(R.World.with_fault(w, R.Healthy{}), Evaluate{R.Literal{R.AsyncValue{R.ActionState.result(Action.get(w, id))}}, R.Undefined{}} <> rest, saved, id, True{}, error)
    case _:
      Machine{w, rest, saved}

def unwind(+w: R.World, tasks: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case ActionYieldCatch{observer, saved} <> rest:
      actionYieldThrow(w, rest, saved, observer, R.World.fault(w))
    case ActionStepReturn{id, saved} <> rest:
      actionStepReturn(w, rest, stack, id, saved)
    case ActionExecutorEnd{+id, +saved} <> +rest:
      actionExecutorThrow(w, rest, saved, id, R.World.fault(w))
    case Nil{}:
      Machine{w, [], stack}
    case EqualityCatch{id, saved} <> rest:
      equalityCatch(w, rest, saved, id, R.World.fault(w))
    case WatchFinish{awaiter, saved} <> rest:
      watchCause(w, rest, saved, awaiter, R.World.fault(w))
    case ProtocolCatch{id, result, saved, successAuto, errorAuto} <> rest:
      catchProtocol(w, rest, saved, id, result, errorAuto, R.World.fault(w))
    # core.ts recompute's finally: restore even when pre-body teardown throws.
    # Do not resume the interrupted teardown or drain its captured candidates.
    case RestoreDeferredReleases{id, previous, released} <> rest:
      Machine{R.World.with_deferredReleases(w, previous), rest, stack}
    case RestoreTracking{tracking} <> rest:
      Machine{R.World.with_tracking(w, tracking), rest, stack}
    case RestoreStale{stale} <> rest:
      Machine{R.World.with_stale(w, stale), rest, stack}
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
    case ThenRejected{frame, error} <> rest:
      catchPass(w, rest, frame)
    case CatchStageFinish{frame} <> rest:
      finishCatch(w, rest, frame, False{})
    case CatchFinally{frame, stagedErr} <> rest:
      finishCatch(w, rest, frame, stagedErr)
    case AfterIterator{frame} <> rest:
      catchPass(w, rest, frame)
    case EffectFinally{id, clean, saved} <> rest:
      effectFinally(w, rest, id, clean, saved)
    case ErrorArmFinally{parameter, saved} <> rest:
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.fault(w)), rest, saved}
    case PassReleases{frame, index, value, joined, stagedErr, missed, prior} <> rest:
      Machine{w, rest, passStack(frame)}
    case TrimFinallyRestore{prior, saved} <> rest:
      Machine{w, rest, saved}
    case FlushCallbackFinally{saved} <> rest:
      flushCallbackFinally(w, rest, stack, saved)
    case FlushCallbackRestore{prior, saved} <> rest:
      flushCallbackRestore(w, rest, saved, R.World.fault(w))
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
  B.choose(~R.World, Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.halted(w), Bool.or(R.World.running(w), Bool.not(R.World.scheduled(w))))), _ => w,
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

# External root/dispose facades use the same core step relation as callbacks.
def ownerWorld(fuel: Nat, w: R.World, tasks: List<&2, O.Task>) -> R.World:
  world(run(fuel, Machine{w, [OwnerTasks{tasks}], []}))
