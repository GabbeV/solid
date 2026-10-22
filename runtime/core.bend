# src/core/core.ts and GlobalQueue.flush translated as a continuation machine.
# Defunctionalized expressions are reusable callbacks. The same machine drives
# nested pulls and the flush: the JS adapter has no scheduling implementation.
import Base
import ./truth-state.bend as Truth
import ./lanes-state.bend as Lanes
import ./verdict-state.bend as Verdict
import ./arrays.bend as Arrays
import ./map.bend as Maps
import ./keyed-map.bend as KeyedMap
import ./flatten.bend as Flatten
import ./small-move.bend as SmallMoves
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
import ./cleanup-state.bend as Cleanup
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

type MapMatch is Data:
  PrefixMatch{id: Nat, items: Nat, newLen: Nat, index: Nat, limit: Nat}
  SuffixMatch{id: Nat, items: Nat, newLen: Nat, start: Nat, end: Nat, newEnd: Nat}

type FlattenFrame is Data:
  FlattenFrame{children: Nat, results: Nat, index: Nat, needs: Bool, notReady: R.Slot, skip: Bool, defer: Bool}

type Task is Data:
  FlattenValue{skip: Bool, defer: Bool}
  FlattenChildValue{frame: FlattenFrame}
  FlattenLoop{frame: FlattenFrame}
  FlattenElementEnd{frame: FlattenFrame, saved: List<&2, R.Value>}
  FlattenDone{results: Nat, skip: Bool}
  FlattenReturn{results: Nat}
  MapMapper{list: R.Expr, fallback: R.InlineBody, keyed: R.Expr, previous: R.Value}
  MapInput{list: R.Expr, fallback: R.InlineBody, mapper: R.Value}
  MapCompareOld{matchFrame: MapMatch, key: R.Value, newItem: R.Value}
  MapCompareNew{matchFrame: MapMatch, oldKey: R.Value}
  MapPrepare{frame: R.MapFrame, cursor: Nat}
  MapPrepared{frame: R.MapFrame, index: Nat}
  MapOldKey{frame: R.MapFrame, index: Nat}
  MapRemovalNewKey{frame: R.MapFrame, oldIndex: Nat, newIndex: Nat}
  MapRemovalOld{frame: R.MapFrame, oldIndex: Nat, newIndex: Nat, newKey: R.Value}
  MapRemovalOldKey{frame: R.MapFrame, oldIndex: Nat, newIndex: Nat, newKey: R.Value}
  MapList{id: Nat}
  MapClear{id: Nat}
  MapEmpty{id: Nat}
  MapFallbackCreate{id: Nat}
  MapFallbackStore{id: Nat}
  MapReturn{id: Nat}
  MapPrefix{id: Nat, items: Nat, newLen: Nat, index: Nat, limit: Nat}
  MapSuffix{id: Nat, items: Nat, newLen: Nat, start: Nat, end: Nat, newEnd: Nat}
  MapAfterTrim{id: Nat, items: Nat, newLen: Nat, start: Nat, end: Nat, newEnd: Nat}
  MapRemoval{frame: R.MapFrame, index: Nat}
  MapRemovalMatch{frame: R.MapFrame, oldIndex: Nat, newIndex: Nat}
  MapOld{frame: R.MapFrame, index: Nat}
  MapCommitSuffix{frame: R.MapFrame, index: Nat}
  MapWindowGrowShift{frame: R.MapFrame, cursor: Nat, destination: Nat}
  MapWindowShrinkShift{frame: R.MapFrame, index: Nat, destination: Nat}
  MapRows{frame: R.MapFrame, index: Nat}
  MapMapped{frame: R.MapFrame, index: Nat, saved: List<&2, R.Value>}
  MapAbort{nodes: List<&2, Nat>, prior: R.Fault}
  MapInitialCommit{frame: R.MapFrame}
  MapInitialPublish{frame: R.MapFrame}
  MapCommitPrefix{frame: R.MapFrame, index: Nat}
  MapWindow{frame: R.MapFrame}
  MapWindowRows{frame: R.MapFrame, index: Nat}
  MapWindowSuffix{frame: R.MapFrame, index: Nat}
  MapRemoved{nodes: List<&2, Nat>}
  MapSmallCleanup{plan: R.SmallPlan, index: Nat}
  RepeatMapper{count: R.Expr, from: R.InlineBody, fallback: R.InlineBody}
  RepeatReady{node: Nat}
  RepeatCount{id: Nat}
  RepeatFrom{id: Nat, newLen: Nat}
  RepeatClear{id: Nat}
  RepeatEmpty{id: Nat}
  RepeatFallbackCreate{id: Nat}
  RepeatFallbackStore{id: Nat}
  RepeatReturn{id: Nat}
  RepeatCopy{frame: R.RepeatFrame, index: Nat}
  RepeatRows{frame: R.RepeatFrame, index: Nat}
  RepeatMapped{frame: R.RepeatFrame, index: Nat, saved: List<&2, R.Value>}
  RepeatAbort{frame: R.RepeatFrame, index: Nat, prior: R.Fault}
  RepeatCommit{frame: R.RepeatFrame}
  RepeatLeaving{frame: R.RepeatFrame, index: Nat}
  RepeatPublish{frame: R.RepeatFrame}
  ArrayItems{values: R.Expr, reversed: List<&2, R.Value>, previous: R.Value}
  ArrayItemValue{values: R.Expr, reversed: List<&2, R.Value>, previous: R.Value}
  ArrayAt{}
  ArrayLength{}
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
  SupersedeAfter{id: Nat, lane: Nat, parent: Nat, value: R.Value}
  DissolveLane{lane: Nat, into: Nat, except: Nat}
  DissolveNodes{lane: Nat, into: Nat, except: Nat, index: Nat}
  DissolveCommitted{id: Nat, effect: Bool, shown: R.Slot}
  DissolveCompared{id: Nat}
  DissolveShown{id: Nat, effect: Bool}
  DissolveHidden{id: Nat}
  LaneSeamNodes{lane: Nat, index: Nat}
  LaneSeamCleared{id: Nat}
  EndLanes{parent: Nat}
  EndLanesLoop{parent: Nat, remaining: Nat}
  TruthNode{id: Nat}
  TruthDeps{edge: Nat}
  TruthAfterDep{edge: Nat}
  TruthReadResult{id: Nat}
  HeldNotFinalCompared{}
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
  CleanupFinally{saved: List<&2, R.Value>}
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
      w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[action], returnsCleanup, 0n}]))
      B.Bundle{w, id}

# core.ts:isSame. Custom functions keep their original program identity and
# execute in the existing ambient scope with actual (a,b) arguments.
def isSame(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value) -> Machine:
  +callback = EQ.custom(w, id)
  B.choose(~Machine, Nat.is_eq(callback, 0n),
    _ => Machine{w, rest, R.Boolean{EQ.isSame(w, id, a, b)} <> stack},
    _ => Machine{w, Evaluate{R.CallWith{callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> EqualityCatch{id, stack} <> rest, stack})

# truth.ts / lanes.ts / verdict.ts call _equals directly. These calls have
# no isSame catch: raw verdicts and raw throws return to the actual caller.
def rawEquals(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value) -> Machine:
  +callback = EQ.custom(w, id)
  B.choose(~Machine, Nat.is_eq(callback, 0n),
    _ => Machine{w, rest, R.Boolean{EQ.isSame(w, id, a, b)} <> stack},
    _ => Machine{w, Evaluate{R.CallWith{callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> rest, stack})

# truth.ts:truth. The dependency cursor advances after recursive comparison,
# retaining the source's live edge object across arbitrary comparator callbacks.
def truthNode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, B.has(R.Node.config(n), K.CONFIG_GUESS()),
    _ => B.choose(~Machine, Bool.and(B.present(R.Node.pending(n)), R.Node.equals(n)),
      _ => rawEquals(w, rest, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), B.selected(R.Node.pending(n), R.NotPendingToken{})),
      _ => Machine{w, rest, R.Boolean{False{}} <> stack}),
    _ => B.choose(~Machine, B.present(R.Node.pending(n)), _ => Machine{w, rest, R.Undefined{} <> stack},
      _ => B.choose(~Machine, B.has(R.Node.config(n), K.CONFIG_OVERRIDE()),
        _ => Machine{w, TruthDeps{R.Node.deps(n)} <> rest, stack}, _ => Machine{w, rest, R.Number{1n} <> stack})))

def truthRead(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  Machine{w, TruthNode{id} <> TruthReadResult{id} <> rest, stack}

def truthReadResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  match stack:
    case value <> +tail:
      B.choose(~Machine, B.truth(value), _ => Machine{w, rest, Truth.laneValueOf(w, id) <> tail},
        _ => B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()),
          _ => Machine{w, rest, B.selected(R.Node.pending(B.node(w, id)), R.Node.value(B.node(w, id))) <> tail},
          _ =>
            +pair = P.notReadyError(w, 0n)
            Machine{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), rest, tail}))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# verdict.ts:heldNotFinal, including the raw _equals call at its source site.
def heldNotFinal(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, Bool.and(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.not(Verdict.quietPending(w, id))),
    _ => Machine{w, rest, R.Boolean{True{}} <> stack},
    _ => B.choose(~Machine, Bool.and(B.present(R.Node.pending(n)), Bool.and(Bool.not(R.VerdictState.latestActive(R.World.verdictState(w))), Bool.and(Bool.not(R.NodeExtension.reask(B.extension(w, id))), Bool.not(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()))))),
      _ => B.choose(~Machine, Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.not(R.Node.equals(n))),
        _ => Machine{w, rest, R.Boolean{True{}} <> stack},
        _ => rawEquals(w, HeldNotFinalCompared{} <> rest, stack, id, R.Node.value(n), B.selected(R.Node.pending(n), R.NotPendingToken{}))),
      _ => Machine{w, rest, R.Boolean{False{}} <> stack}))

# lanes.ts:laneRead, no folded store scope is represented by this internal
# profile. The optional folded callback remains an explicit store frontier.
def laneReadEnter(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, lane: Nat, +guess: Bool, +status: U32) -> Machine:
  +w = Lanes.enterLane(w, lane, reader)
  +value = B.choose(~R.Value, Bool.and(Bool.not(guess), B.has(status, K.STATUS_PENDING())), _ => R.NotPendingToken{}, _ => Truth.laneValueOf(w, id))
  Machine{w, rest, value <> stack}

def laneReadRenderEnd(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  B.choose(~Machine, Bool.or(R.Transaction.held(B.transaction(w, lane)), Bool.and(Bool.not(guess), B.has(status, K.STATUS_PENDING()))),
    _ => B.choose(~Machine, Bool.and(Bool.not(guess), Bool.and(Bool.not(R.Transaction.shown(B.transaction(w, lane))), B.has(status, K.STATUS_UNINITIALIZED()))),
      _ =>
        +pair = P.notReadyError(w, 0n)
        Machine{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), rest, stack},
      _ =>
        +w = B.choose(~R.World, B.has(R.Node.flags(B.node(w, reader)), K.REACTIVE_SCREEN_READ()), _ => w,
          _ =>
            +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), U32.or(K.REACTIVE_FRAME_READ(), K.REACTIVE_SCREEN_READ()))))
            B.store_transaction(w, lane, R.Transaction.with_reruns(B.transaction(w, lane), B.append(Nat, R.Transaction.reruns(B.transaction(w, lane)), [reader]))))
        Machine{w, rest, Lanes.display(w, id) <> stack}),
    _ => laneReadEnter(w, rest, stack, reader, id, lane, guess, status))

def laneReadRender(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  B.choose(~Machine, Bool.and(Bool.not(guess), Bool.and(B.has(status, K.STATUS_PENDING()), Bool.not(B.present(R.NodeExtension.lane(B.extension(w, id)))))),
    _ => Machine{w, rest, R.NotPendingToken{} <> stack},
    _ => B.choose(~Machine, Bool.and(Bool.not(guess), Bool.and(B.present(R.Node.pending(B.node(w, id))), Bool.and(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_HELD()), Nat.is_ne(R.World.flushTransaction(w), 0n)))),
      _ =>
        +pair = X.resolveTx(w, R.World.flushTransaction(w))
        +w = B.first(R.World, Nat, pair)
        +flush = B.second(R.World, Nat, pair)
        +pair = X.txOf(w, reader)
        +w = B.first(R.World, Nat, pair)
        B.choose(~Machine, Nat.is_eq(flush, B.second(R.World, Nat, pair)),
          _ => Machine{w, rest, B.selected(R.Node.pending(B.node(w, id)), R.NotPendingToken{}) <> stack},
          _ => laneReadRenderEnd(w, rest, stack, reader, id, lane, guess, status)),
      _ => laneReadRenderEnd(w, rest, stack, reader, id, lane, guess, status)))

def laneReadReader(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  B.choose(~Machine, Nat.is_eq(reader, 0n), _ => Machine{w, rest, Truth.laneValueOf(w, id) <> stack},
    _ => B.choose(~Machine, Bool.or(Bool.not(R.World.tracking(w)), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())),
      _ => B.choose(~Machine, Bool.or(Nat.is_eq(R.World.passLane(w), 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())),
        _ => Machine{w, rest, Lanes.display(w, id) <> stack}, _ => laneReadEnter(w, rest, stack, reader, id, lane, guess, status)),
      _ => B.choose(~Machine, Bool.and(X.isRender(R.Node.kind(B.node(w, reader))), Bool.or(Nat.is_eq(R.World.passLane(w), 0n), Bool.not(Lanes.sameLane(w, R.World.passLane(w), lane)))),
        _ => laneReadRender(w, rest, stack, reader, id, lane, guess, status), _ => laneReadEnter(w, rest, stack, reader, id, lane, guess, status))))

def laneRead(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat) -> Machine:
  +guess = B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())
  +pair = X.txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +lane = B.second(R.World, Nat, pair)
  B.choose(~Machine, Bool.and(Nat.is_ne(reader, 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_AUTHORITATIVE())),
    _ => B.choose(~Machine, R.World.truthReadHook(w), _ => truthRead(w, rest, stack, id), _ => Machine{R.World.with_fault(w, R.Unsupported{89n}), rest, stack}),
    _ => B.choose(~Machine, Bool.and(Bool.not(guess), B.has(R.Node.status(B.node(w, id)), K.STATUS_ERROR())), _ => Machine{w, rest, R.NotPendingToken{} <> stack},
      _ => laneReadReader(w, rest, stack, reader, id, lane, guess, R.Node.status(B.node(w, id)))))

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
  B.choose(~Machine, Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.running(w), R.World.halted(w))),
    _ => Machine{w, rest, stack}, _ => B.choose(~Machine, R.World.scheduled(w), _ => Machine{w, Round{} <> rest, stack}, _ => Machine{Cleanup.rethrowCleanupError(w, False{}), rest, stack}))

# Source nested finally: drain even after callback throw; a drain throw overrides
# that error. Save the return stack across the drain and decrement after either
# success or failure. Partial callback operands are discarded on a throw.
def flushCallbackFinally(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, saved: List<&2, R.Value>) -> Machine:
  +prior = R.World.fault(w)
  +values = B.choose(~List<&2, R.Value>, healthy(prior), _ => stack, _ => saved)
  publicFlush(R.World.with_fault(w, R.Healthy{}), FlushCallbackRestore{prior, values} <> rest, values)

def flushCallbackRestore(+w: R.World, rest: List<&2, Task>, saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  Machine{R.World.with_fault(R.World.with_syncDepth(w, Nat.sub(R.World.syncDepth(w), 1n)), fault), rest, saved}

def repeatRead(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = Maps.updateParent(w, id)
  Machine{w, Evaluate{R.RepeatState.count(Maps.get(w, id)), R.Undefined{}} <> RepeatCount{id} <> rest, stack}

def mapRead(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +w = KeyedMap.updateParent(w, id)
  Machine{w, Evaluate{R.MapState.list(KeyedMap.get(w, id)), R.Undefined{}} <> MapList{id} <> rest, stack}

def evaluate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, expr: R.Expr, +prev: R.Value) -> Machine:
  match expr:
    case R.MapArrayCreate{list, mapper, fallback, keyed}:
      Machine{w, Evaluate{mapper, prev} <> MapMapper{list, fallback, keyed, prev} <> rest, stack}
    case R.MapArrayRead{id}:
      mapRead(w, rest, stack, id)
    case R.ArrayLiteral{values}:
      Machine{w, ArrayItems{values, [], prev} <> rest, stack}
    case R.ArrayAt{array, index}:
      Machine{w, Evaluate{array, prev} <> Evaluate{index, prev} <> ArrayAt{} <> rest, stack}
    case R.Flatten{children, skip, defer}:
      Machine{w, Evaluate{children, prev} <> FlattenValue{skip, defer} <> rest, stack}
    case R.ArrayLength{array}:
      Machine{w, Evaluate{array, prev} <> ArrayLength{} <> rest, stack}
    case R.RepeatCreate{count, mapper, from, fallback}:
      Machine{w, Evaluate{mapper, prev} <> RepeatMapper{count, from, fallback} <> rest, stack}
    case R.RepeatRead{id}:
      repeatRead(w, rest, stack, id)
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
        _ => Machine{w, Callback{callback, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}, 0n})), R.Undefined{}, R.Undefined{}} <> rest, stack},
        _ => Machine{R.World.with_fault(w, R.Unsupported{6n}), rest, stack})
    case R.Then{first, second}:
      Machine{w, Evaluate{first, prev} <> Discard{} <> Evaluate{second, prev} <> rest, stack}
    case R.Raise{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), rest, stack}

# User callback ABI, not a Solid scheduling operation. Statements execute in
# order in the current source callback scope. Arguments are bound as user-code
# data; return exits only this invocation. Reads use the ordinary ReadNode continuation.
# JavaScript dense array-literal evaluation: left to right, once, then allocate.
# The linked syntax is shared with user call vectors; no scheduler runs here.
def arrayItems(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, values: R.Expr, +reversed: List<&2, R.Value>, +previous: R.Value) -> Machine:
  match values:
    case R.CallArgumentsEnd{}:
      +pair = Arrays.allocate(w, Arrays.slots(List.reverse(&2, R.Value, reversed)))
      Machine{B.first(R.World, Nat, pair), rest, R.ArrayReference{B.second(R.World, Nat, pair)} <> stack}
    case R.CallArgumentsItem{value, tail}:
      Machine{w, Evaluate{value, previous} <> ArrayItemValue{tail, reversed, previous} <> rest, stack}
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, stack}

def callbackAction(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, R.CleanupAction>, +first: R.Value, +second: R.Value, value: R.CleanupAction) -> Machine:
  match value:
    case R.FlattenChildren{results, skip}:
      +pair = Arrays.fresh(w, 0n)
      +result = B.second(R.World, Nat, pair)
      Machine{B.first(R.World, Nat, pair), FlattenLoop{FlattenFrame{results, result, 0n, False{}, R.Empty{}, skip, False{}}} <> FlattenReturn{result} <> rest, stack}
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
      Machine{w, OwnerTasks{[O.Enter{owner, True{}, False{}}, O.RootEnd{}]} <> SetSignalResolved{signal, current} <> rest, R.Undefined{} <> tail}
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
        _ => Machine{w, OwnerTasks{[O.Enter{id, self, False{}}, O.RootEnd{}]} <> rest, R.Undefined{} <> tail},
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
      Machine{w, OwnerTasks{[O.Enter{id, True{}, False{}}, O.RootEnd{}]} <> rest, R.Undefined{} <> tail}
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
      Machine{w, OwnerTasks{[O.Enter{owner, True{}, False{}}, O.RootEnd{}]} <> SetMemoForward{id, True{}} <> rest, R.Undefined{} <> tail}
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
        _ => Machine{w, Callback{id, bindCallActions(R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), id, R.CleanupProgram{[], False{}, 0n})), args), B.get(R.Value, args, 0n, R.Undefined{}), B.get(R.Value, args, 1n, R.Undefined{})} <> rest, stack},
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

# flatten.ts return points: unwrap before filtering or array traversal.
def flattenResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, value: R.Value, +skip: Bool, +defer: Bool) -> Machine:
  match value:
    case R.ArrayReference{children}:
      +pair = Arrays.fresh(w, 0n)
      +result = B.second(R.World, Nat, pair)
      Machine{B.first(R.World, Nat, pair), FlattenLoop{FlattenFrame{children, result, 0n, False{}, R.Empty{}, skip, defer}} <> FlattenDone{result, skip} <> rest, stack}
    case other:
      Machine{w, rest, other <> stack}

def flattenPending(frame: FlattenFrame) -> R.Slot:
  match frame:
    case FlattenFrame{children, results, index, needs, notReady, skip, defer}:
      notReady

def flattenAdvance(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, frame: FlattenFrame, +childNeeds: Bool, +notReady: R.Slot) -> Machine:
  match frame:
    case FlattenFrame{children, results, index, needs, oldNotReady, skip, defer}:
      Machine{w, FlattenLoop{FlattenFrame{children, results, 1n+index, Bool.or(childNeeds, needs), notReady, skip, defer}} <> rest, stack}

# Source length is read live before each element, and an element's catch retains
# partial pushes. Nested fragment failure is caught again at its parent element.
def flattenCatch(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +frame: FlattenFrame, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{+cause}:
      B.choose(~Machine, P.isNotReady(cause),
        _ => flattenAdvance(R.World.with_fault(w, R.Healthy{}), rest, saved, frame, False{}, R.Present{cause}),
        _ => Machine{w, rest, saved})
    case other:
      Machine{w, rest, saved}

def flattenEnd(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +needs: Bool, notReady: R.Slot) -> Machine:
  match notReady:
    case R.Present{cause}:
      Machine{R.World.with_fault(w, R.CallbackThrown{cause}), rest, stack}
    case R.Empty{}:
      Machine{w, rest, R.Boolean{needs} <> stack}

def flattenChildResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +value: R.Value, +results: Nat, +skip: Bool, +defer: Bool) -> Machine:
  match value:
    case R.ArrayReference{children}:
      Machine{w, FlattenLoop{FlattenFrame{children, results, 0n, False{}, R.Empty{}, skip, defer}} <> rest, stack}
    case +other:
      +w = B.choose(~R.World, Bool.and(skip, Flatten.nonRendered(other)), _ => w, _ => Flatten.push(w, results, other))
      Machine{w, rest, R.Boolean{False{}} <> stack}

def flattenChild(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: FlattenFrame, +value: R.Value) -> Machine:
  match frame:
    case FlattenFrame{+children, +results, +index, +needs, +notReady, +skip, +defer}:
      B.choose(~Machine, Flatten.zeroArgument(w, value),
        _ => B.choose(~Machine, defer,
          _ => Machine{Flatten.push(w, results, value), rest, R.Boolean{True{}} <> stack},
          _ => invokeMany(w, FlattenChildValue{FlattenFrame{children, results, index, needs, notReady, skip, defer}} <> rest, stack, value, [])),
        _ => flattenChildResolved(w, rest, stack, value, results, skip, defer))

def flattenLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, frame: FlattenFrame) -> Machine:
  match frame:
    case FlattenFrame{+children, +results, +index, +needs, +notReady, +skip, +defer}:
      B.choose(~Machine, Nat.is_lt(index, Arrays.length(w, children)),
        _ => flattenChild(w, FlattenElementEnd{FlattenFrame{children, results, index, needs, notReady, skip, defer}, stack} <> rest, stack, FlattenFrame{children, results, index, needs, notReady, skip, defer}, Arrays.at(w, children, index)),
        _ => flattenEnd(w, rest, stack, needs, notReady))

def flattenValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +value: R.Value, +skip: Bool, +defer: Bool) -> Machine:
  B.choose(~Machine, Flatten.zeroArgument(w, value),
    _ => B.choose(~Machine, defer, _ => Machine{w, rest, value <> stack},
      _ => invokeMany(w, FlattenValue{skip, defer} <> rest, stack, value, [])),
    _ => B.choose(~Machine, Bool.and(skip, Flatten.nonRendered(value)),
      _ => Machine{w, rest, R.Undefined{} <> stack},
      _ => flattenResolved(w, rest, stack, value, skip, defer)))


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

# core/core.ts:stagedRead. Shared source helper retains the uninitialized
# guard, pass flag and lane staged-reader collection in one implementation.
def stagedRead(w: R.World, reader: Nat, source: Nat) -> R.World:
  V.stagedRead(w, reader, source)

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
  +returnsCleanup = R.CleanupProgram.returnsCleanup(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}, 0n}))
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
    case O.RunCleanup{callback} <> tail:
      Machine{w, Evaluate{R.CallProgram{callback}, R.Undefined{}} <> CleanupFinally{stack} <> OwnerTasks{tail} <> rest, stack}
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

# src/map.ts repeat/updateRepeat return-point continuations.
def repeatCreate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, count: R.Expr, mapper: R.Value, from: R.InlineBody, fallback: R.InlineBody) -> Machine:
  +pair = Maps.repeat(w, count, mapper, from, fallback)
  +w = B.first(R.World, Nat, pair)
  +repeat = B.second(R.World, Nat, pair)
  +node = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{node})
  +w = N.computed(w, R.RepeatRead{repeat}, N.defaults(), R.World.context(w))
  Machine{w, Recompute{node, True{}} <> RepeatReady{node} <> rest, stack}

# updateRepeat: parentComputed store, then count, then optional from, all before
# entering the internal owner. Existing read/throw/pending machinery is shared.
def repeatBegin(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +newLen: Nat, +from: Nat) -> Machine:
  +state = Maps.get(w, id)
  +ending = {RestoreContext{R.World.context(w), R.World.tracking(w)} <> RepeatReturn{id} <> rest : List<&2, Task>}
  +w = L.enterOwner(w, R.RepeatState.owner(state))
  B.choose(~Machine, Nat.is_eq(newLen, 0n),
    _ => B.choose(~Machine, Nat.is_ne(R.RepeatState.len(state), 0n),
      _ => Machine{w, OwnerTasks{[O.Enter{R.RepeatState.owner(state), False{}, False{}}]} <> RepeatClear{id} <> ending, stack},
      _ => Machine{w, RepeatEmpty{id} <> ending, stack}),
    _ =>
      +pair = Arrays.fresh(w, newLen)
      +w = B.first(R.World, Nat, pair)
      +frame = Maps.frame(id, state, newLen, from, B.second(R.World, Nat, pair))
      Machine{w, RepeatCopy{frame, R.RepeatFrame.keepStart(frame)} <> ending, stack})

# updateRepeat: options.from?.() || 0, within the natural offset profile.
def repeatFromValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +newLen: Nat, value: R.Value) -> Machine:
  match value:
    case R.Number{from}:
      repeatBegin(w, rest, stack, id, newLen, from)
    case other:
      B.choose(~Machine, B.truth(other), _ => Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, stack}, _ => repeatBegin(w, rest, stack, id, newLen, 0n))

def repeatFrom(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +newLen: Nat) -> Machine:
  match stack:
    case value <> tail:
      repeatFromValue(w, rest, tail, id, newLen, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def repeatFromBody(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +newLen: Nat, body: R.InlineBody) -> Machine:
  match body:
    case R.NoInlineBody{}:
      repeatFrom(w, rest, R.Number{0n} <> stack, id, newLen)
    case R.SomeInlineBody{expr, returns}:
      Machine{w, Evaluate{expr, R.Undefined{}} <> RepeatFrom{id, newLen} <> rest, stack}

def repeatCount(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  match stack:
    case R.Number{+newLen} <> +tail:
      repeatFromBody(w, rest, tail, id, newLen, R.RepeatState.from(Maps.get(w, id)))
    case _:
      Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, stack}

# map.ts: completed fallback is an array entry, even for falsy payloads (#4211).
def repeatEmptyBody(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, fallback: R.InlineBody) -> Machine:
  match fallback:
    case R.NoInlineBody{}:
      Machine{w, rest, stack}
    case R.SomeInlineBody{expr, returns}:
      +state = Maps.get(w, id)
      +old = B.get(Nat, R.RepeatState.nodes(state), 0n, 0n)
      B.choose(~Machine, Nat.is_ne(Arrays.length(w, R.RepeatState.mappings(state)), 0n), _ => Machine{w, rest, stack},
        _ => Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(old, 0n), _ => OwnerTasks{[O.Enter{old, True{}, False{}}]} <> RepeatFallbackCreate{id} <> rest, _ => RepeatFallbackCreate{id} <> rest), stack})

def repeatFallbackBody(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +owner: Nat, body: R.InlineBody) -> Machine:
  match body:
    case R.NoInlineBody{}:
      Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, stack}
    case R.SomeInlineBody{expr, returns}:
      Machine{L.enterOwner(w, owner), Evaluate{expr, R.Undefined{}} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> RepeatFallbackStore{id} <> rest, stack}

def repeatFallbackCreate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +owner = B.length(R.Node, R.World.nodes(w))
  +w = D.createOwner(w, R.World.context(w), False{})
  +state = Maps.get(w, id)
  +w = Maps.store(w, id, R.RepeatState.with_nodes(state, B.put(Nat, R.RepeatState.nodes(state), 0n, 0n, owner)))
  repeatFallbackBody(w, rest, stack, id, owner, R.RepeatState.fallback(state))

def repeatCopy(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.RepeatFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.RepeatFrame.keepEnd(frame)),
    _ =>
      +state = Maps.get(w, R.RepeatFrame.repeat(frame))
      +to = Nat.sub(index, R.RepeatFrame.from(frame))
      +at = Nat.sub(index, R.RepeatState.offset(state))
      +nodes = B.put(Nat, R.RepeatFrame.nodes(frame), to, 0n, B.get(Nat, R.RepeatState.nodes(state), at, 0n))
      +w = Arrays.put(w, R.RepeatFrame.mappings(frame), to, Arrays.at(w, R.RepeatState.mappings(state), at))
      Machine{w, RepeatCopy{R.RepeatFrame.with_nodes(frame, nodes), 1n+index} <> rest, stack},
    _ => Machine{w, RepeatRows{frame, R.RepeatFrame.from(frame)} <> rest, stack})

def repeatRows(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.RepeatFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.RepeatFrame.to(frame)),
    _ => B.choose(~Machine, Maps.retained(frame, index),
      _ => Machine{w, RepeatRows{frame, 1n+index} <> rest, stack},
      _ =>
        +owner = B.length(R.Node, R.World.nodes(w))
        +w = D.createOwner(w, R.World.context(w), False{})
        +nodes = B.put(Nat, R.RepeatFrame.nodes(frame), Nat.sub(index, R.RepeatFrame.from(frame)), 0n, owner)
        +frame = R.RepeatFrame.with_nodes(frame, nodes)
        +mapper = R.RepeatState.mapper(Maps.get(w, R.RepeatFrame.repeat(frame)))
        invokeMany(L.enterOwner(w, owner), RestoreContext{R.World.context(w), R.World.tracking(w)} <> RepeatMapped{frame, index, stack} <> rest, stack, mapper, [R.Number{index}])),
    _ => Machine{w, RepeatCommit{frame} <> rest, stack})

# This return point is also the mapper try/catch edge in unwind. Catch scope
# ends before the commit's disposal loop, so commit throws do not clean temps.
def repeatMapped(+w: R.World, +rest: List<&2, Task>, +frame: R.RepeatFrame, +index: Nat, saved: List<&2, R.Value>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      Machine{Arrays.put(w, R.RepeatFrame.mappings(frame), Nat.sub(index, R.RepeatFrame.from(frame)), value), RepeatRows{frame, 1n+index} <> rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, saved}

def repeatAbort(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.RepeatFrame, +index: Nat, +prior: R.Fault) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.RepeatFrame.to(frame)),
    _ =>
      +owner = B.get(Nat, R.RepeatFrame.nodes(frame), Nat.sub(index, R.RepeatFrame.from(frame)), 0n)
      +ending = {RepeatAbort{frame, 1n+index, prior} <> rest : List<&2, Task>}
      Machine{w, B.choose(~List<&2, Task>, Bool.and(Bool.not(Maps.retained(frame, index)), Nat.is_ne(owner, 0n)), _ => OwnerTasks{[O.Enter{owner, True{}, False{}}]} <> ending, _ => ending), stack},
    _ => Machine{R.World.with_fault(w, prior), rest, stack})

def repeatCommit(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.RepeatFrame) -> Machine:
  +state = Maps.get(w, R.RepeatFrame.repeat(frame))
  +old = B.get(Nat, R.RepeatState.nodes(state), 0n, 0n)
  B.choose(~Machine, Nat.is_eq(R.RepeatState.len(state), 0n),
    _ => Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(old, 0n), _ => OwnerTasks{[O.Enter{old, True{}, False{}}]} <> RepeatPublish{frame} <> rest, _ => RepeatPublish{frame} <> rest), stack},
    _ => Machine{w, RepeatLeaving{frame, R.RepeatState.offset(state)} <> rest, stack})

def repeatLeaving(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.RepeatFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.RepeatFrame.prevTo(frame)),
    _ =>
      +state = Maps.get(w, R.RepeatFrame.repeat(frame))
      +owner = B.get(Nat, R.RepeatState.nodes(state), Nat.sub(index, R.RepeatState.offset(state)), 0n)
      +ending = {RepeatLeaving{frame, 1n+index} <> rest : List<&2, Task>}
      Machine{w, B.choose(~List<&2, Task>, Bool.or(Nat.is_lt(index, R.RepeatFrame.from(frame)), Nat.is_ge(index, R.RepeatFrame.to(frame))), _ => OwnerTasks{[O.Enter{owner, True{}, False{}}]} <> ending, _ => ending), stack},
    _ => Machine{w, RepeatPublish{frame} <> rest, stack})

# src/map.ts mapArray/updateKeyedMap, plain keyed or keyed:false admission. General callbacks
# and teardown re-enter this same machine; no host reconciliation is involved.
def mapCreate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +list: R.Expr, +mapper: R.Value, +fallback: R.InlineBody, +byIndex: Bool, +key: R.Value) -> Machine:
  +pair = KeyedMap.mapArray(w, list, mapper, fallback, byIndex, J.functionLength(w, mapper), key)
  +w = B.first(R.World, Nat, pair)
  +map = B.second(R.World, Nat, pair)
  +node = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{node})
  +w = N.computed(w, R.MapArrayRead{map}, N.defaults(), R.World.context(w))
  Machine{w, Recompute{node, True{}} <> RepeatReady{node} <> rest, stack}

def mapInput(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +list: R.Expr, +fallback: R.InlineBody, +mapper: R.Value, +keyed: R.Value) -> Machine:
  match keyed:
    case R.Undefined{}:
      mapCreate(w, rest, stack, list, mapper, fallback, False{}, R.Undefined{})
    case R.Boolean{byKey}:
      mapCreate(w, rest, stack, list, mapper, fallback, Bool.not(byKey), R.Undefined{})
    case other:
      B.choose(~Machine, J.isFunction(other), _ => mapCreate(w, rest, stack, list, mapper, fallback, False{}, other), _ => Machine{R.World.with_fault(w, R.Unsupported{86n}), rest, stack})

def mapBegin(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat) -> Machine:
  +state = KeyedMap.get(w, id)
  +newLen = Arrays.length(w, items)
  +ending = {RestoreContext{R.World.context(w), R.World.tracking(w)} <> MapReturn{id} <> rest : List<&2, Task>}
  +w = L.enterOwner(w, R.MapState.owner(state))
  B.choose(~Machine, Nat.is_eq(newLen, 0n),
    _ => B.choose(~Machine, Nat.is_ne(R.MapState.len(state), 0n),
      _ => Machine{w, OwnerTasks{[O.Enter{R.MapState.owner(state), False{}, False{}}]} <> MapClear{id} <> ending, stack},
      _ => Machine{w, MapEmpty{id} <> ending, stack}),
    _ => B.choose(~Machine, Nat.is_eq(R.MapState.len(state), 0n),
      _ =>
        +pair = Arrays.fresh(w, newLen)
        +frame = KeyedMap.frame(id, items, newLen, 0n, 0n, B.second(R.World, Nat, pair), True{}, newLen, KeyedMap.hasRows(state), R.MapState.hasIndexes(state))
        Machine{B.first(R.World, Nat, pair), MapRows{frame, 0n} <> ending, stack},
      _ => Machine{w, MapPrefix{id, items, newLen, 0n, Nat.min(R.MapState.len(state), newLen)} <> ending, stack}))

def mapListValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value) -> Machine:
  match value:
    case R.ArrayReference{items}:
      mapBegin(w, rest, stack, id, items)
    case other:
      B.choose(~Machine, B.truth(other), _ => Machine{R.World.with_fault(w, R.Unsupported{82n}), rest, stack},
        _ =>
          +pair = Arrays.fresh(w, 0n)
          mapBegin(B.first(R.World, Nat, pair), rest, stack, id, B.second(R.World, Nat, pair)))

def mapEmptyBody(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +fallback: R.InlineBody) -> Machine:
  match fallback:
    case R.NoInlineBody{}:
      Machine{w, rest, stack}
    case R.SomeInlineBody{expr, returns}:
      +state = KeyedMap.get(w, id)
      +old = B.get(Nat, R.MapState.nodes(state), 0n, 0n)
      B.choose(~Machine, Nat.is_ne(Arrays.length(w, R.MapState.mappings(state)), 0n), _ => Machine{w, rest, stack},
        _ => Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(old, 0n), _ => OwnerTasks{[O.Enter{old, True{}, False{}}]} <> MapFallbackCreate{id} <> rest, _ => MapFallbackCreate{id} <> rest), stack})

def mapFallbackBody(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +owner: Nat, +body: R.InlineBody) -> Machine:
  match body:
    case R.NoInlineBody{}:
      Machine{R.World.with_fault(w, R.Unsupported{82n}), rest, stack}
    case R.SomeInlineBody{expr, returns}:
      Machine{L.enterOwner(w, owner), Evaluate{expr, R.Undefined{}} <> RestoreContext{R.World.context(w), R.World.tracking(w)} <> MapFallbackStore{id} <> rest, stack}

def mapFallbackCreate(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +owner = B.length(R.Node, R.World.nodes(w))
  +w = D.createOwner(w, R.World.context(w), False{})
  +state = KeyedMap.get(w, id)
  +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, B.put(Nat, R.MapState.nodes(state), 0n, 0n, owner)))
  mapFallbackBody(w, rest, stack, id, owner, R.MapState.fallback(state))

# compare(key,a,b) return points. The raw identity guard precedes key calls;
# both arguments and the key function are captured before its first callback.
def mapMatched(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, matchFrame: MapMatch, +matched: Bool) -> Machine:
  match matchFrame:
    case PrefixMatch{+id, +items, +newLen, +index, +limit}:
      +state = KeyedMap.get(w, id)
      B.choose(~Machine, matched,
        _ =>
          +row = B.get(Nat, R.MapState.rows(state), index, 0n)
          +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => W.setSignal(w, row, Arrays.at(w, items, index)), _ => w)
          Machine{w, MapPrefix{id, items, newLen, 1n+index, limit} <> rest, stack},
        _ => Machine{w, MapSuffix{id, items, newLen, index, R.MapState.len(state), newLen} <> rest, stack})
    case SuffixMatch{+id, +items, +newLen, +start, +end, +newEnd}:
      B.choose(~Machine, matched,
        _ => Machine{w, MapSuffix{id, items, newLen, start, Nat.sub(end, 1n), Nat.sub(newEnd, 1n)} <> rest, stack},
        _ => Machine{w, MapAfterTrim{id, items, newLen, start, end, newEnd} <> rest, stack})

def mapCompare(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +matchFrame: MapMatch, +id: Nat, +oldItem: R.Value, +newItem: R.Value) -> Machine:
  +state = KeyedMap.get(w, id)
  B.choose(~Machine, B.equal(oldItem, newItem),
    _ => mapMatched(w, rest, stack, matchFrame, True{}),
    _ => B.choose(~Machine, KeyedMap.hasRows(state),
      _ => B.choose(~Machine, B.truth(R.MapState.key(state)),
        _ => invokeMany(w, MapCompareOld{matchFrame, R.MapState.key(state), newItem} <> rest, stack, R.MapState.key(state), [oldItem]),
        _ => mapMatched(w, rest, stack, matchFrame, True{})),
      _ => mapMatched(w, rest, stack, matchFrame, False{})))

def mapPrefix(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat, +newLen: Nat, +index: Nat, +limit: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, limit),
    _ => mapCompare(w, rest, stack, PrefixMatch{id, items, newLen, index, limit}, id, Arrays.at(w, R.MapState.items(KeyedMap.get(w, id)), index), Arrays.at(w, items, index)),
    _ => Machine{w, MapSuffix{id, items, newLen, index, R.MapState.len(KeyedMap.get(w, id)), newLen} <> rest, stack})

def mapSuffix(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat, +newLen: Nat, +start: Nat, +end: Nat, +newEnd: Nat) -> Machine:
  B.choose(~Machine, Bool.and(Nat.is_gt(end, start), Nat.is_gt(newEnd, start)),
    _ => mapCompare(w, rest, stack, SuffixMatch{id, items, newLen, start, end, newEnd}, id, Arrays.at(w, R.MapState.items(KeyedMap.get(w, id)), Nat.sub(end, 1n)), Arrays.at(w, items, Nat.sub(newEnd, 1n))),
    _ => Machine{w, MapAfterTrim{id, items, newLen, start, end, newEnd} <> rest, stack})

# Keyed callbacks are outside the mapper catch. The no-key reverse loop keeps
# the existing pure helper; extracted keys resume one source call at a time.
def mapPrepareStart(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame) -> Machine:
  B.choose(~Machine, B.truth(R.MapState.key(KeyedMap.get(w, R.MapFrame.map(frame)))),
    _ => Machine{w, MapPrepare{frame, R.MapFrame.newEnd(frame)} <> rest, stack},
    _ => Machine{w, MapOld{KeyedMap.prepareIndices(R.MapFrame.newEnd(frame), w, frame), R.MapFrame.start(frame)} <> rest, stack})

def mapPrepare(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +cursor: Nat) -> Machine:
  B.choose(~Machine, Nat.is_gt(cursor, R.MapFrame.start(frame)),
    _ =>
      +index = Nat.sub(cursor, 1n)
      invokeMany(w, MapPrepared{frame, index} <> rest, stack, R.MapState.key(KeyedMap.get(w, R.MapFrame.map(frame))), [Arrays.at(w, R.MapFrame.newItems(frame), index)]),
    _ => Machine{w, MapOld{frame, R.MapFrame.start(frame)} <> rest, stack})

def mapPrepared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat, +key: R.Value) -> Machine:
  +old = KeyedMap.indexGet(R.MapFrame.keyIndices(frame), key)
  +frame = R.MapFrame.with_next(frame, B.put(R.MapIndex, R.MapFrame.next(frame), Nat.sub(index, R.MapFrame.start(frame)), R.MapMissing{}, KeyedMap.nextIndex(old)))
  +frame = R.MapFrame.with_keyIndices(frame, KeyedMap.indexSet(R.MapFrame.keyIndices(frame), key, R.MapAt{index}))
  Machine{w, MapPrepare{frame, index} <> rest, stack}

def mapGeneralStage(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat, +newLen: Nat, +start: Nat, +end: Nat, +newEnd: Nat) -> Machine:
  +oldLen = R.MapState.len(KeyedMap.get(w, id))
  +pair = Arrays.fresh(w, newLen)
  +w = B.first(R.World, Nat, pair)
  +frame = KeyedMap.frame(id, items, newLen, end, start, B.second(R.World, Nat, pair), False{}, newEnd, KeyedMap.hasRows(KeyedMap.get(w, id)), R.MapState.hasIndexes(KeyedMap.get(w, id)))
  B.choose(~Machine, Nat.is_lt(newLen, oldLen),
    _ => Machine{w, MapRemovalMatch{frame, start, start} <> rest, stack},
    _ => mapPrepareStart(w, rest, stack, frame))

def mapSmallMove(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat, +newLen: Nat, +start: Nat, +end: Nat, +newEnd: Nat) -> Machine:
  B.choose(~Machine, SmallMoves.probe(w, id, items, start, end, newEnd),
    _ =>
      +pair = SmallMoves.trySmallMove(w, id, items, newLen, start)
      +w = B.first(R.World, R.SmallPlan, pair)
      +plan = B.second(R.World, R.SmallPlan, pair)
      B.choose(~Machine, healthy(R.World.fault(w)),
        _ => B.choose(~Machine, R.SmallPlan.applied(plan), _ => Machine{w, MapSmallCleanup{plan, 0n} <> rest, stack}, _ => mapGeneralStage(w, rest, stack, id, items, newLen, start, end, newEnd)),
        _ => Machine{w, rest, stack}),
    _ => mapGeneralStage(w, rest, stack, id, items, newLen, start, end, newEnd))

# commitSmallMove's unmatched-source disposal is last and outside mapper catch.
def mapSmallCleanup(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +plan: R.SmallPlan, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, B.length(Nat, R.SmallPlan.srcPos(plan))),
    _ =>
      +ending = {MapSmallCleanup{plan, 1n+index} <> rest : List<&2, Task>}
      +owner = B.get(Nat, R.SmallPlan.oldNodes(plan), B.get(Nat, R.SmallPlan.srcPos(plan), index, 0n), 0n)
      Machine{w, B.choose(~List<&2, Task>, B.get(Bool, R.SmallPlan.consumed(plan), index, False{}), _ => ending, _ => OwnerTasks{[O.Enter{owner, True{}, False{}}]} <> ending), stack},
    _ => Machine{w, rest, stack})

def mapAfterTrim(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +items: Nat, +newLen: Nat, +start: Nat, +end: Nat, +newEnd: Nat) -> Machine:
  +state = KeyedMap.get(w, id)
  B.choose(~Machine, Bool.and(Nat.is_eq(start, newLen), Nat.is_eq(R.MapState.len(state), newLen)),
    _ => Machine{KeyedMap.saveItems(w, id, items), rest, stack},
    _ => B.choose(~Machine, Bool.and(Bool.and(Nat.is_le(newLen, R.MapState.len(state)), Nat.is_gt(Nat.sub(end, start), 65n)), Bool.and(Bool.not(KeyedMap.hasRows(state)), Bool.not(R.MapState.hasIndexes(state)))),
      _ => mapSmallMove(w, rest, stack, id, items, newLen, start, end, newEnd),
      _ => mapGeneralStage(w, rest, stack, id, items, newLen, start, end, newEnd)))

def mapRemoval(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.end(frame)),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +removed = B.append(Nat, R.MapFrame.removed(frame), [B.get(Nat, R.MapState.nodes(state), index, 0n)])
      Machine{w, MapRemoval{R.MapFrame.with_removed(frame, removed), 1n+index} <> rest, stack},
    _ => Machine{w, MapCommitPrefix{frame, 0n} <> rest, stack})

# Mapper closures: by-index uses a raw ownedWrite core signal and accessor;
# plain keyed mode passes the raw item. Callable items remain ordinary data.

def mapRemovalFound(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +oldIndex: Nat, +newIndex: Nat) -> Machine:
  +state = KeyedMap.get(w, R.MapFrame.map(frame))
  +slot = Nat.sub(newIndex, R.MapFrame.start(frame))
  +w = Arrays.put(w, R.MapFrame.mappings(frame), newIndex, Arrays.at(w, R.MapState.mappings(state), oldIndex))
  +frame = R.MapFrame.with_nodes(frame, B.put(Nat, R.MapFrame.nodes(frame), slot, 0n, B.get(Nat, R.MapState.nodes(state), oldIndex, 0n)))
  +frame = B.choose(~R.MapFrame, KeyedMap.hasRows(state), _ => R.MapFrame.with_rows(frame, B.put(Nat, R.MapFrame.rows(frame), slot, 0n, B.get(Nat, R.MapState.rows(state), oldIndex, 0n))), _ => frame)
  +frame = B.choose(~R.MapFrame, R.MapState.hasIndexes(state), _ => R.MapFrame.with_indexes(frame, B.put(Nat, R.MapFrame.indexes(frame), slot, 0n, B.get(Nat, R.MapState.indexes(state), oldIndex, 0n))), _ => frame)
  Machine{w, MapRemovalMatch{frame, 1n+oldIndex, 1n+newIndex} <> rest, stack}

def mapRemovalFailed(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame) -> Machine:
  +frame = R.MapFrame.with_nodes(frame, Maps.emptyNodes(Nat.sub(R.MapFrame.newEnd(frame), R.MapFrame.start(frame))))
  mapPrepareStart(w, rest, stack, R.MapFrame.with_removed(frame, []))

# Source stageRemoval caches each new key for its complete old-side scan.
def mapRemovalOld(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +oldIndex: Nat, +newIndex: Nat, +newKey: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_lt(oldIndex, R.MapFrame.end(frame)),
    _ => invokeMany(w, MapRemovalOldKey{frame, oldIndex, newIndex, newKey} <> rest, stack, R.MapState.key(KeyedMap.get(w, R.MapFrame.map(frame))), [Arrays.at(w, R.MapState.items(KeyedMap.get(w, R.MapFrame.map(frame))), oldIndex)]),
    _ => mapRemovalFailed(w, rest, stack, frame))

def mapRemovalOldKey(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +oldIndex: Nat, +newIndex: Nat, +newKey: R.Value, oldKey: R.Value) -> Machine:
  B.choose(~Machine, B.equal(oldKey, newKey),
    _ => mapRemovalFound(w, rest, stack, frame, oldIndex, newIndex),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +removed = B.append(Nat, R.MapFrame.removed(frame), [B.get(Nat, R.MapState.nodes(state), oldIndex, 0n)])
      Machine{w, MapRemovalOld{R.MapFrame.with_removed(frame, removed), 1n+oldIndex, newIndex, newKey} <> rest, stack})

# Plain comparisons have no callback. Extracted-key mode invokes the new key
# before testing old-side exhaustion, then caches it through that inner loop.
def mapRemovalMatch(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +oldIndex: Nat, +newIndex: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(newIndex, R.MapFrame.newEnd(frame)),
    _ => B.choose(~Machine, B.truth(R.MapState.key(KeyedMap.get(w, R.MapFrame.map(frame)))),
      _ => invokeMany(w, MapRemovalNewKey{frame, oldIndex, newIndex} <> rest, stack, R.MapState.key(KeyedMap.get(w, R.MapFrame.map(frame))), [Arrays.at(w, R.MapFrame.newItems(frame), newIndex)]),
      _ => B.choose(~Machine, Nat.is_lt(oldIndex, R.MapFrame.end(frame)),
        _ =>
          +state = KeyedMap.get(w, R.MapFrame.map(frame))
          B.choose(~Machine, B.equal(Arrays.at(w, R.MapState.items(state), oldIndex), Arrays.at(w, R.MapFrame.newItems(frame), newIndex)),
            _ => mapRemovalFound(w, rest, stack, frame, oldIndex, newIndex),
            _ =>
              +removed = B.append(Nat, R.MapFrame.removed(frame), [B.get(Nat, R.MapState.nodes(state), oldIndex, 0n)])
              Machine{w, MapRemovalMatch{R.MapFrame.with_removed(frame, removed), 1n+oldIndex, newIndex} <> rest, stack}),
        _ => mapRemovalFailed(w, rest, stack, frame))),
    _ => Machine{w, MapRemoval{frame, oldIndex} <> rest, stack})

# The old changed-window walk consumes the duplicate chain in occurrence order.
def mapOldPosition(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat, +item: R.Value, position: R.MapIndex) -> Machine:
  match position:
    case R.MapAt{+j}:
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +slot = Nat.sub(j, R.MapFrame.start(frame))
      +w = Arrays.put(w, R.MapFrame.mappings(frame), j, Arrays.at(w, R.MapState.mappings(state), index))
      +frame = R.MapFrame.with_nodes(frame, B.put(Nat, R.MapFrame.nodes(frame), slot, 0n, B.get(Nat, R.MapState.nodes(state), index, 0n)))
      +frame = B.choose(~R.MapFrame, KeyedMap.hasRows(state), _ => R.MapFrame.with_rows(frame, B.put(Nat, R.MapFrame.rows(frame), slot, 0n, B.get(Nat, R.MapState.rows(state), index, 0n))), _ => frame)
      +frame = B.choose(~R.MapFrame, R.MapState.hasIndexes(state), _ => R.MapFrame.with_indexes(frame, B.put(Nat, R.MapFrame.indexes(frame), slot, 0n, B.get(Nat, R.MapState.indexes(state), index, 0n))), _ => frame)
      +next = B.get(R.MapIndex, R.MapFrame.next(frame), slot, R.MapMissing{})
      +frame = R.MapFrame.with_keyIndices(frame, KeyedMap.indexSet(R.MapFrame.keyIndices(frame), item, next))
      Machine{w, MapOld{frame, 1n+index} <> rest, stack}
    case other:
      +owner = B.get(Nat, R.MapState.nodes(KeyedMap.get(w, R.MapFrame.map(frame))), index, 0n)
      Machine{w, MapOld{R.MapFrame.with_removed(frame, B.append(Nat, R.MapFrame.removed(frame), [owner])), 1n+index} <> rest, stack}

def mapOld(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.end(frame)),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +item = Arrays.at(w, R.MapState.items(state), index)
      B.choose(~Machine, B.truth(R.MapState.key(state)),
        _ => invokeMany(w, MapOldKey{frame, index} <> rest, stack, R.MapState.key(state), [item]),
        _ => mapOldPosition(w, rest, stack, frame, index, item, KeyedMap.indexGet(R.MapFrame.keyIndices(frame), item))),
    _ => Machine{w, MapRows{frame, R.MapFrame.start(frame)} <> rest, stack})

# Mapper closures: by-index uses a raw ownedWrite core signal and accessor;
# plain keyed mode passes the raw item. Callable items remain ordinary data.
def mapInvokeIndex(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat, +first: R.Value, +context: Nat, +tracking: Bool) -> Machine:
  +signal = B.length(R.Node, R.World.nodes(w))
  +w = N.signal(w, R.Number{index}, R.NodeOptions.with_ownedWrite(N.defaults(), True{}))
  +frame = R.MapFrame.with_indexes(frame, B.put(Nat, R.MapFrame.indexes(frame), Nat.sub(index, R.MapFrame.start(frame)), 0n, signal))
  +w = B.event(w, R.MapIndexBound{signal})
  invokeMany(w, RestoreContext{context, tracking} <> MapMapped{frame, index, stack} <> rest, stack, R.MapState.mapper(KeyedMap.get(w, R.MapFrame.map(frame))), [first, R.AccessorReference{signal}])

def mapInvokeRow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat, +context: Nat, +tracking: Bool) -> Machine:
  +state = KeyedMap.get(w, R.MapFrame.map(frame))
  +ending = {RestoreContext{context, tracking} <> MapMapped{frame, index, stack} <> rest : List<&2, Task>}
  B.choose(~Machine, KeyedMap.hasRows(state),
    _ =>
      +row = B.length(R.Node, R.World.nodes(w))
      +w = N.signal(w, Arrays.at(w, R.MapFrame.newItems(frame), index), R.NodeOptions.with_ownedWrite(N.defaults(), True{}))
      +frame = R.MapFrame.with_rows(frame, B.put(Nat, R.MapFrame.rows(frame), Nat.sub(index, R.MapFrame.start(frame)), 0n, row))
      +w = B.event(w, R.MapRowBound{row})
      B.choose(~Machine, R.MapState.byIndex(state),
        _ => invokeMany(w, RestoreContext{context, tracking} <> MapMapped{frame, index, stack} <> rest, stack, R.MapState.mapper(state), [R.AccessorReference{row}, R.Number{index}]),
        _ => B.choose(~Machine, R.MapState.hasIndexes(state),
          _ => mapInvokeIndex(w, rest, stack, frame, index, R.AccessorReference{row}, context, tracking),
          _ => invokeMany(w, RestoreContext{context, tracking} <> MapMapped{frame, index, stack} <> rest, stack, R.MapState.mapper(state), [R.AccessorReference{row}, R.Undefined{}]))),
    _ => B.choose(~Machine, R.MapState.hasIndexes(state), _ => mapInvokeIndex(w, rest, stack, frame, index, Arrays.at(w, R.MapFrame.newItems(frame), index), context, tracking), _ => invokeMany(w, ending, stack, R.MapState.mapper(state), [Arrays.at(w, R.MapFrame.newItems(frame), index)])))

def mapRows(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.newEnd(frame)),
    _ => B.choose(~Machine, Nat.is_ne(B.get(Nat, R.MapFrame.nodes(frame), Nat.sub(index, R.MapFrame.start(frame)), 0n), 0n),
      _ => Machine{w, MapRows{frame, 1n+index} <> rest, stack},
      _ =>
        +slot = Nat.sub(index, R.MapFrame.start(frame))
        +owner = B.length(R.Node, R.World.nodes(w))
        +w = D.createOwner(w, R.World.context(w), False{})
        +frame = R.MapFrame.with_nodes(frame, B.put(Nat, R.MapFrame.nodes(frame), slot, 0n, owner))
        +frame = R.MapFrame.with_created(frame, B.append(Nat, R.MapFrame.created(frame), [owner]))
        mapInvokeRow(L.enterOwner(w, owner), rest, stack, frame, index, R.World.context(w), R.World.tracking(w))),
    _ => Machine{w, B.choose(~List<&2, Task>, R.MapFrame.initial(frame), _ => MapInitialCommit{frame} <> rest, _ => MapCommitPrefix{frame, 0n} <> rest), stack})

def mapMapped(+w: R.World, +rest: List<&2, Task>, +frame: R.MapFrame, +index: Nat, +saved: List<&2, R.Value>, +stack: List<&2, R.Value>) -> Machine:
  match stack:
    case value <> tail:
      Machine{Arrays.put(w, R.MapFrame.mappings(frame), index, value), MapRows{frame, 1n+index} <> rest, tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, saved}

def mapAbort(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +nodes: List<&2, Nat>, +prior: R.Fault) -> Machine:
  match nodes:
    case Nil{}:
      Machine{R.World.with_fault(w, prior), rest, stack}
    case node <> tail:
      Machine{w, OwnerTasks{[O.Enter{node, True{}, False{}}]} <> MapAbort{tail, prior} <> rest, stack}

# Create-all fallback disposal is outside the mapper catch and before stores.
def mapInitialCommit(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame) -> Machine:
  +old = B.get(Nat, R.MapState.nodes(KeyedMap.get(w, R.MapFrame.map(frame))), 0n, 0n)
  Machine{w, B.choose(~List<&2, Task>, Nat.is_ne(old, 0n), _ => OwnerTasks{[O.Enter{old, True{}, False{}}]} <> MapInitialPublish{frame} <> rest, _ => MapInitialPublish{frame} <> rest), stack}

# General commit: retained prefix/suffix values land before commitWindow.
def mapCommitPrefix(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.start(frame)),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +w = Arrays.put(w, R.MapFrame.mappings(frame), index, Arrays.at(w, R.MapState.mappings(state), index))
      Machine{w, MapCommitPrefix{frame, 1n+index} <> rest, stack},
    _ => Machine{w, MapCommitSuffix{frame, R.MapFrame.newEnd(frame)} <> rest, stack})

# Complete suffix copies into the fresh mapped result precede live bookkeeping.
def mapCommitSuffix(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.newLen(frame)),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +old = KeyedMap.sourceSlot(R.MapFrame.newLen(frame), R.MapState.len(state), index)
      +w = Arrays.put(w, R.MapFrame.mappings(frame), index, Arrays.at(w, R.MapState.mappings(state), old))
      Machine{w, MapCommitSuffix{frame, 1n+index} <> rest, stack},
    _ => Machine{w, MapWindow{frame} <> rest, stack})

# commitWindow: growing vectors resize before descending suffix copies; shrinking
# vectors shift from the front before their length stores. Existing live fields
# are reloaded at the stores, with no callback or alternate publication in here.
def mapWindow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame) -> Machine:
  +id = R.MapFrame.map(frame)
  +state = KeyedMap.get(w, id)
  +oldLen = R.MapState.len(state)
  B.choose(~Machine, Nat.is_gt(R.MapFrame.newLen(frame), oldLen),
    _ =>
      +nodes = B.append(Nat, R.MapState.nodes(state), Maps.emptyNodes(Nat.sub(R.MapFrame.newLen(frame), oldLen)))
      +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, nodes))
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => KeyedMap.store(w, id, R.MapState.with_rows(state, B.append(Nat, R.MapState.rows(state), Maps.emptyNodes(Nat.sub(R.MapFrame.newLen(frame), oldLen))))), _ => w)
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, R.MapState.hasIndexes(state), _ => KeyedMap.store(w, id, R.MapState.with_indexes(state, B.append(Nat, R.MapState.indexes(state), Maps.emptyNodes(Nat.sub(R.MapFrame.newLen(frame), oldLen))))), _ => w)
      Machine{w, MapWindowGrowShift{frame, oldLen, R.MapFrame.newLen(frame)} <> rest, stack},
    _ => B.choose(~Machine, Nat.is_lt(R.MapFrame.newLen(frame), oldLen),
      _ => Machine{w, MapWindowShrinkShift{frame, R.MapFrame.end(frame), R.MapFrame.newEnd(frame)} <> rest, stack},
      _ => Machine{w, MapWindowRows{frame, R.MapFrame.start(frame)} <> rest, stack}))

def mapWindowGrowShift(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +cursor: Nat, +destination: Nat) -> Machine:
  B.choose(~Machine, Nat.is_gt(cursor, R.MapFrame.end(frame)),
    _ =>
      +id = R.MapFrame.map(frame)
      +state = KeyedMap.get(w, id)
      +old = Nat.sub(cursor, 1n)
      +next = Nat.sub(destination, 1n)
      +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, B.put(Nat, R.MapState.nodes(state), next, 0n, B.get(Nat, R.MapState.nodes(state), old, 0n))))
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => KeyedMap.store(w, id, R.MapState.with_rows(state, B.put(Nat, R.MapState.rows(state), next, 0n, B.get(Nat, R.MapState.rows(state), old, 0n)))), _ => w)
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, R.MapState.hasIndexes(state), _ => KeyedMap.store(w, id, R.MapState.with_indexes(state, B.put(Nat, R.MapState.indexes(state), next, 0n, B.get(Nat, R.MapState.indexes(state), old, 0n)))), _ => w)
      Machine{w, MapWindowGrowShift{frame, old, next} <> rest, stack},
    _ => Machine{w, MapWindowRows{frame, R.MapFrame.start(frame)} <> rest, stack})

def mapWindowShrinkShift(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat, +destination: Nat) -> Machine:
  +id = R.MapFrame.map(frame)
  +state = KeyedMap.get(w, id)
  B.choose(~Machine, Nat.is_lt(index, R.MapState.len(state)),
    _ =>
      +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, B.put(Nat, R.MapState.nodes(state), destination, 0n, B.get(Nat, R.MapState.nodes(state), index, 0n))))
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => KeyedMap.store(w, id, R.MapState.with_rows(state, B.put(Nat, R.MapState.rows(state), destination, 0n, B.get(Nat, R.MapState.rows(state), index, 0n)))), _ => w)
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, R.MapState.hasIndexes(state), _ => KeyedMap.store(w, id, R.MapState.with_indexes(state, B.put(Nat, R.MapState.indexes(state), destination, 0n, B.get(Nat, R.MapState.indexes(state), index, 0n)))), _ => w)
      Machine{w, MapWindowShrinkShift{frame, 1n+index, 1n+destination} <> rest, stack},
    _ =>
      +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, KeyedMap.takeNodes(R.MapFrame.newLen(frame), R.MapState.nodes(state))))
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => KeyedMap.store(w, id, R.MapState.with_rows(state, KeyedMap.takeNodes(R.MapFrame.newLen(frame), R.MapState.rows(state)))), _ => w)
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, R.MapState.hasIndexes(state), _ => KeyedMap.store(w, id, R.MapState.with_indexes(state, KeyedMap.takeNodes(R.MapFrame.newLen(frame), R.MapState.indexes(state)))), _ => w)
      Machine{w, MapWindowRows{frame, R.MapFrame.start(frame)} <> rest, stack})

def mapWindowRows(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.newEnd(frame)),
    _ =>
      +id = R.MapFrame.map(frame)
      +slot = Nat.sub(index, R.MapFrame.start(frame))
      +state = KeyedMap.get(w, id)
      +w = KeyedMap.store(w, id, R.MapState.with_nodes(state, B.put(Nat, R.MapState.nodes(state), index, 0n, B.get(Nat, R.MapFrame.nodes(frame), slot, 0n))))
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, KeyedMap.hasRows(state),
        _ =>
          +row = B.get(Nat, R.MapFrame.rows(frame), slot, 0n)
          +w = KeyedMap.store(w, id, R.MapState.with_rows(state, B.put(Nat, R.MapState.rows(state), index, 0n, row)))
          W.setSignal(w, row, Arrays.at(w, R.MapFrame.newItems(frame), index)),
        _ => w)
      +state = KeyedMap.get(w, id)
      +w = B.choose(~R.World, R.MapState.hasIndexes(state),
        _ =>
          +signal = B.get(Nat, R.MapFrame.indexes(frame), slot, 0n)
          +w = KeyedMap.store(w, id, R.MapState.with_indexes(state, B.put(Nat, R.MapState.indexes(state), index, 0n, signal)))
          W.setSignal(w, signal, R.Number{index}),
        _ => w)
      Machine{w, MapWindowRows{frame, 1n+index} <> rest, stack},
    _ => Machine{w, MapWindowSuffix{frame, R.MapFrame.newEnd(frame)} <> rest, stack})

# commitWindow's suffix slot writes precede the caller's publication. Index
# signals update only when length changed; row slots retain their source guard.
def mapWindowSuffix(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: R.MapFrame, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_lt(index, R.MapFrame.newLen(frame)),
    _ =>
      +state = KeyedMap.get(w, R.MapFrame.map(frame))
      +w = B.choose(~R.World, KeyedMap.hasRows(state), _ => W.setSignal(w, B.get(Nat, R.MapState.rows(state), index, 0n), Arrays.at(w, R.MapFrame.newItems(frame), index)), _ => w)
      +w = B.choose(~R.World, Bool.and(R.MapState.hasIndexes(state), Nat.is_ne(R.MapFrame.newLen(frame), R.MapState.len(state))), _ => W.setSignal(w, B.get(Nat, R.MapState.indexes(state), index, 0n), R.Number{index}), _ => w)
      Machine{w, MapWindowSuffix{frame, 1n+index} <> rest, stack},
    _ => Machine{KeyedMap.publishWindow(w, frame), MapRemoved{R.MapFrame.removed(frame)} <> rest, stack})

def mapRemoved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +nodes: List<&2, Nat>) -> Machine:
  match nodes:
    case Nil{}:
      Machine{w, rest, stack}
    case node <> tail:
      Machine{w, OwnerTasks{[O.Enter{node, True{}, False{}}]} <> MapRemoved{tail} <> rest, stack}

# lanes.ts:supersede. The optional folded store echo hook is outside this
# ordinary-node profile; authoritative confirmation uses the installed hook.
def supersedeEnd(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +parent: Nat, +value: R.Value) -> Machine:
  +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
  Machine{X.joinFuture(w, parent), rest, stack}


def supersedeAfter(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lane: Nat, +parent: Nat, +value: R.Value) -> Machine:
  +w = B.choose(~R.World, R.Transaction.shown(B.transaction(w, lane)),
    _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}))), _ => w)
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS()))))
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Empty{}))
  +w = X.holdNode(w, id, parent)
  +w = B.choose(~R.World, Nat.is_ne(R.Node.subs(B.node(w, id)), 0n), _ => S.insertSubs(w, id), _ => w)
  supersedeEnd(w, rest, stack, id, parent, value)

# lanes.ts:dissolveLane. Live l._nodes length and the next index survive every
# commit/disposal/comparator return. shown is a Slot because NOT_PENDING differs
# from a successful undefined answer. Source locals effect/guess/slot/latest are
# captured before clearing the lane, not recomputed after a user callback.

def supersede(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +changed: Bool) -> Machine:
  +pair = X.txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +lane = B.second(R.World, Nat, pair)
  +parent = R.Transaction.parent(B.transaction(w, lane))
  +pair = X.resolveTx(w, B.choose(~Nat, Nat.is_eq(parent, 0n), _ => lane, _ => parent))
  +w = B.first(R.World, Nat, pair)
  +parent = B.second(R.World, Nat, pair)
  B.choose(~Machine, changed,
    _ => Machine{w, DissolveLane{lane, parent, id} <> SupersedeAfter{id, lane, parent, value} <> rest, stack},
    _ =>
      +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_HELD())))
      +w = B.choose(~R.World, R.World.truthConfirmedHook(w), _ => Truth.truthConfirmed(w, lane), _ => w)
      supersedeEnd(w, rest, stack, id, parent, value))


def dissolveLane(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +lane: Nat, +into: Nat, +except: Nat) -> Machine:
  +state = R.World.laneState(w)
  +w = R.World.with_laneState(w, R.LaneState.with_live(state, X.removeIdentity(R.LaneState.live(state), lane)))
  +w = Lanes.unlink(w, lane)
  +verdict = R.Transaction.verdict(B.transaction(w, lane))
  +w = B.choose(~R.World, Nat.is_ne(verdict, 0n), _ => B.store_transaction(w, lane, R.Transaction.with_verdict(B.transaction(w, lane), 0n)), _ => w)
  +ending = {DissolveNodes{lane, into, except, 0n} <> rest : List<&2, Task>}
  todo = B.choose(~List<&2, Task>, Bool.and(Nat.is_ne(verdict, 0n), B.contains(R.LaneState.live(R.World.laneState(w)), verdict)), _ => DissolveLane{verdict, 0n, 0n} <> ending, _ => ending)
  Machine{w, todo, stack}


def dissolveCommitted(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +effect: Bool, +shown: R.Slot) -> Machine:
  B.choose(~Machine, effect, _ => Machine{w, rest, stack},
    _ =>
      +n = B.node(w, id)
      +dirty = Bool.or(B.has(R.Node.flags(n), U32.or(K.REACTIVE_IN_HEAP(), U32.or(K.REACTIVE_DIRTY(), K.REACTIVE_CHECK()))), B.has(R.Node.status(n), K.STATUS_PENDING()))
      +w = B.choose(~R.World, dirty, _ => B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), K.CONFIG_INPUTS_PUBLISHED()))), _ => w)
      B.choose(~Machine, B.present(shown),
        _ => rawEquals(w, DissolveCompared{id} <> rest, stack, id, B.selected(shown, R.Undefined{}), R.Node.value(B.node(w, id))),
        _ => Machine{w, rest, stack}))


def dissolveDerivation(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lane: Nat, +effect: Bool, +shown: R.Slot) -> Machine:
  +w = B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n))
  +w = B.choose(~R.World, effect, _ => w,
    _ =>
      +w = B.choose(~R.World, Bool.and(B.present(shown), R.Transaction.shown(B.transaction(w, lane))), _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), shown)), _ => w)
      B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()),
        _ => H.enqueueSub(B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n)), id), _ => w))
  B.choose(~Machine, R.Transaction.shown(B.transaction(w, lane)),
    _ => Machine{w, CommitPending{id} <> DissolveShown{id, effect} <> rest, stack},
    _ =>
      +ending = {DissolveHidden{id} <> rest : List<&2, Task>}
      todo = B.choose(~List<&2, Task>, Bool.or(Nat.is_ne(R.NodeExtension.pendingFirstChild(B.extension(w, id)), 0n), Bool.not(B.noDisposal(R.NodeExtension.pendingDisposal(B.extension(w, id))))), _ => OwnerTasks{[O.Enter{id, False{}, True{}}]} <> ending, _ => ending)
      Machine{w, todo, stack})

# lanes.ts:laneSeam; blocked retains the shared lane-aware judgment engine.

def dissolveNodes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +lane: Nat, +into: Nat, +except: Nat, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))),
    _ =>
      +w = B.choose(~R.World, Bool.or(Nat.is_eq(into, 0n), Bool.and(R.Transaction.shown(B.transaction(w, lane)), Bool.not(R.Transaction.held(B.transaction(w, lane))))),
        _ => S.releaseQueues(w, lane),
        _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(R.Transaction.with_renderQueue(B.transaction(w, lane), []), [])))
      Machine{w, rest, stack},
    _ =>
      +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, lane)), index, 0n)
      +ending = {DissolveNodes{lane, into, except, 1n+index} <> rest : List<&2, Task>}
      B.choose(~Machine, Bool.or(Nat.is_eq(id, except), Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), lane)), _ => Machine{w, ending, stack},
        _ =>
          +effect = B.effect(R.Node.kind(B.node(w, id)))
          +guess = B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())
          +slot = R.NodeExtension.lane(B.extension(w, id))
          +shown = B.choose(~R.Slot, Bool.and(R.Transaction.shown(B.transaction(w, lane)), Bool.not(effect)), _ => slot, _ => R.Present{R.Node.value(B.node(w, id))})
          +latest = Truth.laneValueOf(w, id)
          +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Empty{}))
          +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS()))))
          B.choose(~Machine, Nat.is_eq(into, 0n),
            _ =>
              +w = B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n))
              +w = B.choose(~R.World, Bool.and(Bool.not(effect), Bool.not(guess)), _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{latest})), _ => w)
              Machine{w, CommitPending{id} <> DissolveCommitted{id, effect, shown} <> ending, stack},
            _ => B.choose(~Machine, guess,
              _ =>
                +w = B.choose(~R.World, B.present(R.Node.pending(B.node(w, id))), _ => w, _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{R.Node.value(B.node(w, id))})))
                +w = B.choose(~R.World, R.Transaction.shown(B.transaction(w, lane)), _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), B.selected(slot, R.NotPendingToken{}))), _ => w)
                Machine{S.insertSubs(X.holdNode(w, id, into), id), ending, stack},
              _ => dissolveDerivation(w, ending, stack, id, lane, effect, shown)))))


def laneSeam(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +lane: Nat, +leaked: Bool) -> Machine:
  +pair = B.choose(~B.Bundle<R.World, Bool>, leaked, _ => B.Bundle{w, True{}}, _ => X.blocked(w, lane))
  +w = B.first(R.World, Bool, pair)
  B.choose(~Machine, B.second(R.World, Bool, pair),
    _ => Machine{B.store_transaction(w, lane, R.Transaction.with_held(B.transaction(w, lane), True{})), rest, stack},
    _ =>
      +w = B.store_transaction(w, lane, R.Transaction.with_shown(R.Transaction.with_held(B.transaction(w, lane), False{}), True{}))
      Machine{S.reruns(w, lane), LaneSeamNodes{lane, 0n} <> rest, stack})


def laneSeamNodes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +lane: Nat, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), _ => Machine{S.releaseQueues(w, lane), rest, stack},
    _ =>
      +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, lane)), index, 0n)
      +w = B.choose(~R.World, B.has(R.Node.flags(B.node(w, id)), Lanes.LEFT_SHOWN()),
        _ => S.insertSubs(B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), Lanes.LEFT_SHOWN()))), id), _ => w)
      +ending = {LaneSeamNodes{lane, 1n+index} <> rest : List<&2, Task>}
      B.choose(~Machine, Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), lane), _ => Machine{w, ending, stack},
        _ =>
          +w = B.choose(~R.World, Bool.and(Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())), Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), B.present(R.Node.pending(B.node(w, id))))),
            _ =>
              +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Node.pending(B.node(w, id))))
              B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{})), _ => w)
          +ending = {LaneSeamCleared{id} <> ending : List<&2, Task>}
          todo = B.choose(~List<&2, Task>, Bool.or(Nat.is_ne(R.NodeExtension.pendingFirstChild(B.extension(w, id)), 0n), Bool.not(B.noDisposal(R.NodeExtension.pendingDisposal(B.extension(w, id))))), _ => OwnerTasks{[O.Enter{id, False{}, True{}}]} <> ending, _ => ending)
          Machine{w, todo, stack}))

# lanes.ts:endLanes scans the current live array backwards, nested lanes first.

def endLanes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat) -> Machine:
  Machine{w, EndLanesLoop{parent, B.length(Nat, R.LaneState.live(R.World.laneState(w)))} <> rest, stack}


def endLanesLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +remaining: Nat) -> Machine:
  match remaining:
    case 0n:
      Machine{w, rest, stack}
    case 1n+ +index:
      +lane = B.get(Nat, R.LaneState.live(R.World.laneState(w)), index, 0n)
      +pair = X.resolveTx(w, R.Transaction.parent(B.transaction(w, lane)))
      +w = B.first(R.World, Nat, pair)
      +ending = {EndLanesLoop{parent, index} <> rest : List<&2, Task>}
      B.choose(~Machine, Nat.is_eq(B.second(R.World, Nat, pair), parent),
        _ => Machine{w, EndLanes{lane} <> DissolveLane{lane, 0n, 0n} <> ending, stack},
        _ => Machine{w, ending, stack})

def dispatch(+w: R.World, tasks: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case MapInput{list, fallback, mapper} <> rest:
      match stack:
        case keyed <> tail:
          mapInput(w, rest, tail, list, fallback, mapper, keyed)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapCompareOld{matchFrame, key, newItem} <> rest:
      match stack:
        case oldKey <> tail:
          invokeMany(w, MapCompareNew{matchFrame, oldKey} <> rest, tail, key, [newItem])
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapCompareNew{matchFrame, oldKey} <> rest:
      match stack:
        case newKey <> tail:
          mapMatched(w, rest, tail, matchFrame, B.equal(oldKey, newKey))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapPrepare{frame, cursor} <> rest:
      mapPrepare(w, rest, stack, frame, cursor)
    case MapPrepared{frame, index} <> rest:
      match stack:
        case key <> tail:
          mapPrepared(w, rest, tail, frame, index, key)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapOldKey{+frame, index} <> rest:
      match stack:
        case +key <> tail:
          mapOldPosition(w, rest, tail, frame, index, key, KeyedMap.indexGet(R.MapFrame.keyIndices(frame), key))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapRemovalNewKey{frame, oldIndex, newIndex} <> rest:
      match stack:
        case newKey <> tail:
          mapRemovalOld(w, rest, tail, frame, oldIndex, newIndex, newKey)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapRemovalOld{frame, oldIndex, newIndex, newKey} <> rest:
      mapRemovalOld(w, rest, stack, frame, oldIndex, newIndex, newKey)
    case MapRemovalOldKey{frame, oldIndex, newIndex, newKey} <> rest:
      match stack:
        case oldKey <> tail:
          mapRemovalOldKey(w, rest, tail, frame, oldIndex, newIndex, newKey, oldKey)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapMapper{list, fallback, keyed, previous} <> rest:
      match stack:
        case mapper <> tail:
          Machine{w, Evaluate{keyed, previous} <> MapInput{list, fallback, mapper} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapList{id} <> rest:
      match stack:
        case value <> tail:
          mapListValue(w, rest, tail, id, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapClear{+id} <> rest:
      Machine{KeyedMap.clear(w, id), MapEmpty{id} <> rest, stack}
    case MapEmpty{+id} <> rest:
      mapEmptyBody(w, rest, stack, id, R.MapState.fallback(KeyedMap.get(w, id)))
    case MapFallbackCreate{id} <> rest:
      mapFallbackCreate(w, rest, stack, id)
    case MapFallbackStore{id} <> rest:
      match stack:
        case value <> tail:
          Machine{Arrays.put(w, R.MapState.mappings(KeyedMap.get(w, id)), 0n, value), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case MapReturn{id} <> rest:
      Machine{w, rest, R.ArrayReference{R.MapState.mappings(KeyedMap.get(w, id))} <> stack}
    case MapPrefix{id, items, newLen, index, limit} <> rest:
      mapPrefix(w, rest, stack, id, items, newLen, index, limit)
    case MapSuffix{id, items, newLen, start, end, newEnd} <> rest:
      mapSuffix(w, rest, stack, id, items, newLen, start, end, newEnd)
    case MapSmallCleanup{plan, index} <> rest:
      mapSmallCleanup(w, rest, stack, plan, index)
    case MapAfterTrim{id, items, newLen, start, end, newEnd} <> rest:
      mapAfterTrim(w, rest, stack, id, items, newLen, start, end, newEnd)
    case MapRemovalMatch{frame, oldIndex, newIndex} <> rest:
      mapRemovalMatch(w, rest, stack, frame, oldIndex, newIndex)
    case MapOld{frame, index} <> rest:
      mapOld(w, rest, stack, frame, index)
    case MapCommitSuffix{frame, index} <> rest:
      mapCommitSuffix(w, rest, stack, frame, index)
    case MapWindowGrowShift{frame, cursor, destination} <> rest:
      mapWindowGrowShift(w, rest, stack, frame, cursor, destination)
    case MapWindowShrinkShift{frame, index, destination} <> rest:
      mapWindowShrinkShift(w, rest, stack, frame, index, destination)
    case MapRemoval{frame, index} <> rest:
      mapRemoval(w, rest, stack, frame, index)
    case MapRows{frame, index} <> rest:
      mapRows(w, rest, stack, frame, index)
    case MapMapped{frame, index, saved} <> rest:
      mapMapped(w, rest, frame, index, saved, stack)
    case MapAbort{nodes, prior} <> rest:
      mapAbort(w, rest, stack, nodes, prior)
    case MapInitialCommit{frame} <> rest:
      mapInitialCommit(w, rest, stack, frame)
    case MapInitialPublish{frame} <> rest:
      Machine{KeyedMap.publishInitial(w, frame), rest, stack}
    case MapCommitPrefix{frame, index} <> rest:
      mapCommitPrefix(w, rest, stack, frame, index)
    case MapWindow{frame} <> rest:
      mapWindow(w, rest, stack, frame)
    case MapWindowSuffix{frame, index} <> rest:
      mapWindowSuffix(w, rest, stack, frame, index)
    case MapWindowRows{frame, index} <> rest:
      mapWindowRows(w, rest, stack, frame, index)
    case MapRemoved{nodes} <> rest:
      mapRemoved(w, rest, stack, nodes)
    case RepeatMapper{count, from, fallback} <> rest:
      match stack:
        case mapper <> tail:
          repeatCreate(w, rest, tail, count, mapper, from, fallback)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case RepeatReady{+node} <> rest:
      +w = B.store_node(w, node, R.Node.with_config(B.node(w, node), B.clear(R.Node.config(B.node(w, node)), K.CONFIG_AUTO_DISPOSE())))
      Machine{B.event(w, R.AccessorBound{node}), rest, R.AccessorReference{node} <> stack}
    case RepeatCount{id} <> rest:
      repeatCount(w, rest, stack, id)
    case RepeatFrom{id, newLen} <> rest:
      repeatFrom(w, rest, stack, id, newLen)
    case RepeatClear{+id} <> rest:
      Machine{Maps.clear(w, id), RepeatEmpty{id} <> rest, stack}
    case RepeatEmpty{+id} <> rest:
      repeatEmptyBody(w, rest, stack, id, R.RepeatState.fallback(Maps.get(w, id)))
    case RepeatFallbackCreate{id} <> rest:
      repeatFallbackCreate(w, rest, stack, id)
    case RepeatFallbackStore{id} <> rest:
      match stack:
        case value <> tail:
          Machine{Arrays.put(w, R.RepeatState.mappings(Maps.get(w, id)), 0n, value), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case RepeatReturn{id} <> rest:
      Machine{w, rest, R.ArrayReference{R.RepeatState.mappings(Maps.get(w, id))} <> stack}
    case RepeatCopy{frame, index} <> rest:
      repeatCopy(w, rest, stack, frame, index)
    case RepeatRows{frame, index} <> rest:
      repeatRows(w, rest, stack, frame, index)
    case RepeatMapped{frame, index, saved} <> rest:
      repeatMapped(w, rest, frame, index, saved, stack)
    case RepeatAbort{frame, index, prior} <> rest:
      repeatAbort(w, rest, stack, frame, index, prior)
    case RepeatCommit{frame} <> rest:
      repeatCommit(w, rest, stack, frame)
    case RepeatLeaving{frame, index} <> rest:
      repeatLeaving(w, rest, stack, frame, index)
    case RepeatPublish{frame} <> rest:
      Machine{Maps.publish(w, frame), rest, stack}
    case ArrayItems{values, reversed, previous} <> rest:
      arrayItems(w, rest, stack, values, reversed, previous)
    case ArrayItemValue{values, reversed, previous} <> rest:
      match stack:
        case value <> tail:
          Machine{w, ArrayItems{values, value <> reversed, previous} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case ArrayAt{} <> rest:
      match stack:
        case R.Number{index} <> R.ArrayReference{id} <> tail:
          Machine{w, rest, Arrays.at(w, id, index) <> tail}
        case _:
          Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, []}
    case ArrayLength{} <> rest:
      match stack:
        case R.ArrayReference{id} <> tail:
          Machine{w, rest, R.Number{Arrays.length(w, id)} <> tail}
        case _:
          Machine{R.World.with_fault(w, R.Unsupported{80n}), rest, []}
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
    case FlattenValue{skip, defer} <> rest:
      match stack:
        case value <> tail:
          flattenValue(w, rest, tail, value, skip, defer)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FlattenChildValue{frame} <> rest:
      match stack:
        case value <> tail:
          flattenChild(w, rest, tail, frame, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FlattenLoop{frame} <> rest:
      flattenLoop(w, rest, stack, frame)
    case FlattenElementEnd{+frame, +saved} <> +rest:
      match stack:
        case R.Boolean{needs} <> tail:
          flattenAdvance(w, rest, saved, frame, needs, flattenPending(frame))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, saved}
    case FlattenDone{+results, +skip} <> +rest:
      match stack:
        case R.Boolean{needs} <> tail:
          B.choose(~Machine, needs,
            _ =>
              +pair = Flatten.wrapper(w, results, skip)
              Machine{B.first(R.World, R.Value, pair), rest, B.second(R.World, R.Value, pair) <> tail},
            _ => Machine{w, rest, R.ArrayReference{results} <> tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FlattenReturn{results} <> rest:
      match stack:
        case ignored <> tail:
          Machine{w, rest, R.ArrayReference{results} <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case Callback{id, actions, first, second} <> rest:
      callback(w, rest, stack, id, first, second, actions)
    case CallArguments{+id} <> +rest:
      match stack:
        case second <> first <> +tail:
          B.choose(~Machine, Bool.and(Nat.is_ne(id, 0n), Nat.is_lt(id, B.length(R.CleanupProgram, R.World.cleanupPrograms(w)))),
            _ => Machine{w, Callback{id, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), id, R.CleanupProgram{[], False{}, 0n})), first, second} <> rest, tail},
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
    case SupersedeAfter{id, lane, parent, value} <> rest:
      supersedeAfter(w, rest, stack, id, lane, parent, value)
    case DissolveLane{lane, into, except} <> rest:
      dissolveLane(w, rest, stack, lane, into, except)
    case DissolveNodes{lane, into, except, index} <> rest:
      dissolveNodes(w, rest, stack, lane, into, except, index)
    case DissolveCommitted{id, effect, shown} <> rest:
      dissolveCommitted(w, rest, stack, id, effect, shown)
    case DissolveCompared{+id} <> rest:
      match stack:
        case value <> tail:
          Machine{B.choose(~R.World, B.truth(value), _ => w, _ => S.insertSubs(w, id)), rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case DissolveShown{+id, effect} <> rest:
      Machine{B.choose(~R.World, effect, _ => w, _ => B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_INPUTS_PUBLISHED())))), rest, stack}
    case DissolveHidden{+id} <> rest:
      Machine{B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_STAGED(), U32.or(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME()))))), rest, stack}
    case LaneSeamNodes{lane, index} <> rest:
      laneSeamNodes(w, rest, stack, lane, index)
    case LaneSeamCleared{+id} <> rest:
      Machine{B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_STAGED()))), rest, stack}
    case EndLanes{parent} <> rest:
      endLanes(w, rest, stack, parent)
    case EndLanesLoop{parent, remaining} <> rest:
      endLanesLoop(w, rest, stack, parent, remaining)
    case TruthNode{id} <> rest:
      truthNode(w, rest, stack, id)
    case TruthDeps{+edge} <> +rest:
      B.choose(~Machine, Nat.is_eq(edge, 0n), _ => Machine{w, rest, R.Number{1n} <> stack}, _ => Machine{w, TruthNode{R.Link.dep(B.link(w, edge))} <> TruthAfterDep{edge} <> rest, stack})
    case TruthAfterDep{+edge} <> +rest:
      match stack:
        case value <> +tail:
          B.choose(~Machine, B.truth(value), _ => Machine{w, TruthDeps{R.Link.nextDep(B.link(w, edge))} <> rest, tail}, _ => Machine{w, rest, R.Undefined{} <> tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case TruthReadResult{id} <> rest:
      truthReadResult(w, rest, stack, id)
    case HeldNotFinalCompared{} <> rest:
      match stack:
        case value <> tail:
          Machine{w, rest, R.Boolean{Bool.not(B.truth(value))} <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
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
          reactionArmExpression(w, rest, tail, R.CleanupProgram.actions(B.get(R.CleanupProgram, R.World.cleanupPrograms(w), callback, R.CleanupProgram{[], False{}, 0n})), tracking)
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
    case CleanupFinally{saved} <> rest:
      Machine{w, rest, saved}
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
      Machine{B.choose(~R.World, R.World.scheduled(w), _ => w, _ => Cleanup.rethrowCleanupError(w, False{})), todo, stack}

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
    case FlattenElementEnd{+frame, +saved} <> +rest:
      flattenCatch(w, rest, saved, frame, R.World.fault(w))
    case MapMapped{+frame, index, saved} <> rest:
      Machine{R.World.with_fault(w, R.Healthy{}), MapAbort{R.MapFrame.created(frame), R.World.fault(w)} <> rest, saved}
    case RepeatMapped{+frame, index, saved} <> rest:
      Machine{R.World.with_fault(w, R.Healthy{}), RepeatAbort{frame, R.RepeatFrame.from(frame), R.World.fault(w)} <> rest, saved}
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
    case CleanupFinally{saved} <> rest:
      Machine{Cleanup.runCleanupCatch(w, R.World.fault(w)), rest, saved}
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
  B.choose(~R.World, Bool.or(Nat.is_ne(R.World.actionDepth(w), 0n), Bool.or(R.World.halted(w), R.World.running(w))), _ => w,
    _ => B.choose(~R.World, R.World.scheduled(w), _ => world(run(fuel, Machine{w, [Round{}], []})), _ => Cleanup.rethrowCleanupError(w, False{})))

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
