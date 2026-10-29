# src/core/core.ts and GlobalQueue.flush translated as a continuation machine.
# Defunctionalized expressions are reusable callbacks. The same machine drives
# nested pulls and the flush: the JS adapter has no scheduling implementation.
import Base
import ./on-flush.bend as OnFlush
import ./deferred-runtime.bend as Deferred
import ./deferred-stream.bend as DeferredStream
import ./from-state.bend as From
import ./from-wrap.bend as WrappedFrom
import ./iterator-methods.bend as IteratorMethods
import ./promise-input.bend as NativePromise
import ./supersede.bend as Supersede
import ./iterator-input.bend as IteratorInput
import ./truth-state.bend as Truth
import ./lanes-state.bend as Lanes
import ./verdict-state.bend as Verdict
import ./affects-marks.bend as Marks
import ./affects-scope.bend as MarkScope
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
  SeamFrame{transaction: Nat, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>, laneRenders: List<&2, Nat>, laneUsers: List<&2, R.QueueEntry>}

# Locals captured by recompute's source try/catch/finally, including #4171's
# laneRoot/mount posture and #4207's pending nested-derivation guard.
type LanePass is Data:
  LanePass{previousLane: Nat, previousMount: R.LaneMount, mount: R.LaneMount}

type PassFrame is Data:
  PassFrame{id: Nat, create: Bool, context: Nat, tracking: Bool, oldHeight: Nat,
    reask: Bool, previous: R.Value, wasUninitialized: Bool, outgoing: R.Value,
    outgoingSources: Nat, wasPendingSource: Bool, oldFlight: R.Flight,
    saved: List<&2, R.Value>, released: Nat, stale: Bool, lanePass: LanePass}

def passStack(frame: PassFrame) -> List<&2, R.Value>:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      saved

def passId(frame: PassFrame) -> Nat:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      id

type MapMatch is Data:
  PrefixMatch{id: Nat, items: Nat, newLen: Nat, index: Nat, limit: Nat}
  SuffixMatch{id: Nat, items: Nat, newLen: Nat, start: Nat, end: Nat, newEnd: Nat}

type FlattenFrame is Data:
  FlattenFrame{children: Nat, results: Nat, index: Nat, needs: Bool, notReady: R.Slot, skip: Bool, defer: Bool}

type Task is Data:
  DeferredCreate{cell: Nat, compute: R.Expr, options: R.NodeOptions, read: Bool}
  DeferredConfigure{cell: Nat, compute: R.Expr, previous: R.Value}
  DeferredCleanup{cell: Nat, compute: R.Expr, previous: R.Value}
  DeferredOpen{cell: Nat, compute: R.Expr, previous: R.Value}
  DeferredResult{cell: Nat, open: Bool, saved: List<&2, R.Value>}
  DeferredCatch{cell: Nat, open: Bool, saved: List<&2, R.Value>}
  DeferredObserve{cell: Nat, result: Nat}
  DeferredRegisterFlight{cell: Nat, node: Nat, result: Nat}
  DeferredRegisterQuestion{cell: Nat, node: Nat, result: Nat}
  DeferredRegisterSources{cell: Nat, node: Nat, result: Nat}
  DeferredRegisterObserver{cell: Nat, node: Nat, result: Nat}
  DeferredSubscribeThen{cell: Nat, result: Nat, observer: Nat}
  DeferredAfterThen{cell: Nat, observer: Nat}
  DeferredAfterIterator{cell: Nat}
  DeferredStreamCall{cell: Nat, source: Nat}
  FromInput{}
  FromOpen{source: Nat}
  FromWrapOpened{}
  FromWrapFinishFinally{saved: List<&2, R.Value>}
  FromSubscribed{iterator: Nat}
  FromBindOwner{iterator: Nat}
  FromConsumeAcquired{node: Nat, result: Nat, deferred: Bool, initialValue: R.Value}
  FromDeferredAcquired{cell: Nat}
  FromFinished{plan: Nat}
  FromReturnPromise{}
  DeferredReturnResult{}
  IteratorReturn{iterator: Nat, argument: R.Slot}
  FromCleanupFinally{saved: List<&2, R.Value>}
  CloseReturnFinally{saved: List<&2, R.Value>}
  DeferredRejected{error: R.Value}
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
  LaneLeakLoop{readers: List<&2, Nat>, index: Nat, leaked: List<&2, Nat>}
  LaneRevealLoop{leaked: List<&2, Nat>, remaining: Nat}
  LaneEnteredLoop{}
  OptimisticResolved{id: Nat, previous: R.Value}
  OptimisticCompared{id: Nat, value: R.Value}
  ApplyGuesses{parent: Nat, lane: Nat, index: Nat}
  ApplyGuessCompared{parent: Nat, lane: Nat, index: Nat, id: Nat, value: R.Value}
  LaneWrite{id: Nat, value: R.Value}
  LaneWriteCompared{id: Nat, lane: Nat, value: R.Value, guess: Bool}
  LaneWriteDone{value: R.Value}
  LaneOutcomeStart{id: Nat, value: R.Value, errored: Bool}
  LaneOutcomeCompared{id: Nat, value: R.Value}
  LaneOutcomeDone{}
  LaneCorrections{live: List<&2, Nat>, judged: Bool}
  LaneCorrectionNodes{lane: Nat, index: Nat}
  LaneCorrectionCompared{id: Nat, truth: R.Value}
  LaneCorrectionEnd{}
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
  EndKept{parent: Nat, remaining: Nat}
  RestoreKept{parent: Nat, entry: R.KeptGuess}
  LaneReadDone{id: Nat, reader: Nat, forced: Bool}
  TruthNode{id: Nat}
  TruthDeps{edge: Nat}
  TruthAfterDep{edge: Nat}
  TruthReadResult{id: Nat}
  HeldNotFinalCompared{}
  SetSignalCompared{id: Nat, value: R.Value}
  PublishCompared{id: Nat, value: R.Value, create: Bool, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, joined: Bool, stagedErr: Bool, lane: Nat}
  PublishOutcome{id: Nat, value: R.Value, create: Bool, oldHeight: Nat, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, joined: Bool, changed: Bool}
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
  RecomputeAfterFlight{id: Nat, lanePass: LanePass}
  RecomputePrepared{id: Nat, create: Bool, released: Nat, lanePass: LanePass}
  RestoreDeferredReleases{id: Nat, previous: Nat, released: Nat, lanePass: LanePass}
  RecomputeAfterTeardown{id: Nat, released: Nat, lanePass: LanePass}
  PassReleases{frame: PassFrame, index: Nat, value: R.Value, joined: Bool, stagedErr: Bool, missed: Bool, prior: R.Fault}
  PassLaneStage{id: Nat, create: Bool, value: R.Value, oldHeight: Nat, wasUninitialized: Bool, outgoing: R.Value, outgoingSources: Nat, wasPendingSource: Bool, joined: Bool, errored: Bool, missed: Bool, previousLane: Nat, seated: Nat}
  FinishPublication{id: Nat, create: Bool, joined: Bool, missed: Bool, lane: Nat, previousLane: Nat}
  QueuePublication{id: Nat, create: Bool, missed: Bool, lane: Nat, previousLane: Nat}
  AfterDeadPass{id: Nat, previousLane: Nat}
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
  OptimisticReady{signal: Nat, computed: Bool, body: R.Expr, previous: R.Value}
  CreateOptimistic{options: R.NodeOptions, body: R.Expr, previous: R.Value}
  OptimisticArgument{signal: Nat}
  OptimisticUpdater{signal: Nat, expr: R.Expr}
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
  AffectsTarget{key: R.Expr, previous: R.Value}
  AffectsApply{target: R.Value}
  LatestEnd{latest: Bool, dispatch: Bool, saved: List<&2, R.Value>}
  ProbeEnd{probing: Bool, found: Bool, dispatch: Bool, saved: List<&2, R.Value>}
  VerdictRaiseHeight{source: Nat, reader: Nat}
  VerdictPulled{node: Nat, reader: Nat, owned: Bool, tracked: Bool}
  VerdictPrepared{node: Nat, reader: Nat, owned: Bool, tracked: Bool}
  VerdictGuessCompared{node: Nat, reader: Nat, lane: Nat}
  VerdictHeldFinal{node: Nat, reader: Nat, tracked: Bool}
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
  ReleaseTransactionQueues{transaction: Nat}
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
  SupersedeFinally{callback: Nat, saved: List<&2, R.Value>}
  SupersedeRestore{prior: R.Fault, saved: List<&2, R.Value>}
  Round{}
  HeapLoop{}
  Seam{}
  ParkIntake{transaction: Nat, index: Nat, count: Nat}
  ParkCompared{node: Nat, transaction: Nat, index: Nat, count: Nat}
  AfterPark{transaction: Nat}
  Settle{}
  SettleCorrectionsDone{}
  HeapCorrections{}
  SettleJoined{}
  SettleApplied{joined: Nat}
  ParkVerdictZombies{transaction: Nat, nodes: List<&2, Nat>}
  AfterLaneSeams{transaction: Nat, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>}
  LandAfterLanes{frame: SeamFrame, transaction: Nat}
  AfterSettle{}
  LandTransactions{frame: SeamFrame, remaining: Nat}
  LandNodes{frame: SeamFrame, transaction: Nat, index: Nat, rerunFrame: Nat}
  LandEnd{frame: SeamFrame, transaction: Nat, rerunFrame: Nat}
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
    case R.NegativeZero{} R.NegativeZero{}:
      B.choose(~R.Value, U32.is_eq(op, 0), _ => R.NegativeZero{}, _ => R.Number{0n})
    case R.NegativeZero{} R.Number{n}:
      B.choose(~R.Value, U32.is_eq(op, 0), _ => R.Number{n}, _ => R.NegativeZero{})
    case R.Number{n} R.NegativeZero{}:
      B.choose(~R.Value, U32.is_eq(op, 0), _ => R.Number{n}, _ => R.NegativeZero{})
    case R.Number{+a} R.Number{+b}:
      B.choose(~R.Value, U32.is_eq(op, 0), _ => R.Number{Nat.add(a, b)}, _ => R.Number{Nat.mul(a, b)})
    case _ _:
      R.Undefined{}

def numeric(v: R.Value) -> Bool:
  match v:
    case R.NegativeZero{}:
      True{}
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

# lanes.ts:laneRead after the outside display-return branches, before enterLane.
# Keep each entered reader in append order; the seam pops them in reverse.
def laneReadEntered(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  +w = B.choose(~R.World, Bool.and(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT()), Nat.is_ne(R.Transaction.verdict(B.transaction(w, R.Transaction.parent(B.transaction(w, lane)))), lane)),
    _ => R.World.with_laneState(w, R.LaneState.with_entered(R.World.laneState(w), B.append(Nat, R.LaneState.entered(R.World.laneState(w)), [reader]))), _ => w)
  laneReadEnter(w, rest, stack, reader, id, lane, guess, status)

def laneReadRenderEnd(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  B.choose(~Machine, Bool.or(R.Transaction.held(B.transaction(w, lane)), Bool.and(Bool.not(guess), B.has(status, K.STATUS_PENDING()))),
    _ =>
      +w = B.choose(~R.World, B.has(R.Node.flags(B.node(w, reader)), K.REACTIVE_SCREEN_READ()), _ => w,
        _ =>
          +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), U32.or(K.REACTIVE_FRAME_READ(), K.REACTIVE_SCREEN_READ()))))
          B.store_transaction(w, lane, R.Transaction.with_reruns(B.transaction(w, lane), B.append(Nat, R.Transaction.reruns(B.transaction(w, lane)), [reader]))))
      B.choose(~Machine, Bool.and(Bool.not(guess), Bool.and(Bool.not(R.Transaction.shown(B.transaction(w, lane))), B.has(status, K.STATUS_UNINITIALIZED()))),
        _ =>
          +pair = P.notReadyError(w, 0n)
          Machine{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), rest, stack},
        _ => Machine{w, rest, Lanes.display(w, id) <> stack}),
    _ => laneReadEntered(w, rest, stack, reader, id, lane, guess, status))

def laneReadOutside(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32, +never: Bool) -> Machine:
  B.choose(~Machine, Bool.and(never, R.Transaction.shown(B.transaction(w, lane))),
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

# lanes.ts:laneRead's tracked render branch. A verdict read may have moved this
# pass into a lane before a later never-shown flight is read (#4275).
def laneReadRender(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  +never = Bool.and(Bool.not(guess), Bool.and(B.has(status, K.STATUS_PENDING()), Bool.not(B.present(R.NodeExtension.lane(B.extension(w, id))))))
  +pass = R.World.passLane(w)
  +w = B.choose(~R.World, Bool.and(Bool.or(never, Nat.is_ne(pass, lane)), Bool.and(Nat.is_ne(pass, 0n), Nat.is_eq(R.Transaction.verdict(B.transaction(w, R.Transaction.parent(B.transaction(w, pass)))), pass))),
    _ => R.World.with_passLane(w, 0n), _ => w)
  B.choose(~Machine, Bool.or(Nat.is_eq(R.World.passLane(w), 0n), Bool.not(Lanes.sameLane(w, R.World.passLane(w), lane))),
    _ => laneReadOutside(w, rest, stack, reader, id, lane, guess, status, never),
    _ => laneReadEnter(w, rest, stack, reader, id, lane, guess, status))

def laneReadReader(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +reader: Nat, +id: Nat, +lane: Nat, +guess: Bool, +status: U32) -> Machine:
  B.choose(~Machine, Nat.is_eq(reader, 0n), _ => Machine{w, rest, Truth.laneValueOf(w, id) <> stack},
    _ => B.choose(~Machine, Bool.or(Bool.not(R.World.tracking(w)), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())),
      _ => B.choose(~Machine, Bool.or(Nat.is_eq(R.World.passLane(w), 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())),
        _ => Machine{w, rest, Lanes.display(w, id) <> stack}, _ => laneReadEnter(w, rest, stack, reader, id, lane, guess, status)),
      _ => B.choose(~Machine, X.isRender(R.Node.kind(B.node(w, reader))),
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
        _ => Machine{A.notifyStatusWith(w, id, K.STATUS_ERROR(), error), rest, R.Boolean{True{}} <> saved})
    case other:
      Machine{w, rest, saved}

# core.ts:setSignal following updater execution. The entry value is never
# reloaded after a user callback. Default/disabled equality keeps its fast path.
def setPlainResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value) -> Machine:
  B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
    _ => Machine{W.setResolved(w, id, current, value), rest, value <> stack},
    _ =>
      +w = W.beforeCompare(w, id)
      B.choose(~Machine, W.skipCompare(w, id),
        _ => Machine{W.stageResolved(w, id, value), rest, value <> stack},
        _ => isSame(w, SetSignalCompared{id, value} <> rest, stack, id, current, value)))

def setResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value) -> Machine:
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()),
    _ => Machine{w, LaneWrite{id, value} <> rest, stack},
    _ => setPlainResolved(w, rest, stack, id, current, value))

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

# signals.ts:createOptimistic function overload, sharing computed construction.
def optimisticCompute(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, compute: R.Expr, +options: R.NodeOptions, +body: R.Expr, +prev: R.Value) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{id})
  +w = N.computed(w, compute, options, R.World.context(w))
  tasks = B.choose(~List<&2, Task>, R.NodeOptions.lazy(options),
    _ => OptimisticReady{id, True{}, body, prev} <> rest,
    _ => Recompute{id, True{}} <> OptimisticReady{id, True{}, body, prev} <> rest)
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

# deferred.ts constructor: create the closure cells/end function before the
# ordinary computed/accessor, retaining eager/lazy initialization in one driver.
def deferredConstruct(+w: R.World, compute: R.Expr, options: R.NodeOptions, parent: Nat) -> R.World:
  +pair = Deferred.allocate(w)
  +w = B.first(R.World, Nat, pair)
  N.computed(w, R.DeferredCompute{B.second(R.World, Nat, pair), compute}, options, parent)

def deferredExpression(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, compute: R.Expr, options: R.NodeOptions, read: Bool) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = B.event(w, R.Constructed{id})
  +pair = Deferred.allocate(w)
  Machine{B.first(R.World, Nat, pair), DeferredCreate{B.second(R.World, Nat, pair), compute, options, read} <> rest, stack}

def deferredCreate(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, cell: Nat, compute: R.Expr, +options: R.NodeOptions, read: Bool) -> Machine:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = N.computed(w, R.DeferredCompute{cell, compute}, options, R.World.context(w))
  +ending = B.choose(~List<&2, Task>, read, _ => ReadNode{id} <> rest, _ => Evaluate{R.Literal{J.accessor(id)}, R.Undefined{}} <> rest)
  +ending = {MemoAccessorReady{id} <> ending : List<&2, Task>}
  Machine{w, B.choose(~List<&2, Task>, R.NodeOptions.lazy(options), _ => ending, _ => Recompute{id, True{}} <> ending), stack}

# getOwner, CONFIG_REDERIVE and cleanup(end) precede the sticky loading window.
def deferredBody(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +cell: Nat, compute: R.Expr, previous: R.Value) -> Machine:
  +node = R.World.context(w)
  Machine{Deferred.setNode(w, cell, node), DeferredConfigure{cell, compute, previous} <> rest, stack}

# The source try/catch now includes result processing (#4248). Its passive
# continuation is consumed at return, with no additional machine dispatch.
def deferredReturned(tasks: List<&2, Task>) -> List<&2, Task>:
  match tasks:
    case DeferredCatch{cell, open, saved} <> rest: rest
    case other: other

# Closed-window streams use the original ordinary Finish/iterator path.
# An answered stream is wrapped before the original engine consumes it.
def deferredResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +open: Bool) -> Machine:
  match stack:
    case R.AsyncValue{+result} <> +tail:
      B.choose(~Machine, open,
        _ => B.choose(~Machine, Nat.is_ne(R.AsyncObject.stream(B.asyncObject(w, result)), 0n),
          _ => Machine{w, DeferredStreamCall{cell, result} <> rest, tail},
          _ => Machine{Deferred.ask(w, cell, R.AsyncValue{result}), DeferredObserve{cell, result} <> rest, tail}),
        _ => Machine{Deferred.land(w, cell, R.DeferredCell.flight(Deferred.cell(w, cell)), False{}), deferredReturned(rest), R.AsyncValue{result} <> tail})
    case +value <> tail:
      Machine{Deferred.land(w, cell, R.DeferredCell.flight(Deferred.cell(w, cell)), False{}), deferredReturned(rest), value <> tail}
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# r.then(done,done) is registered BEFORE serve invokes handleAsync. It does not
# alter the engine's _inFlight slot; that belongs to the later registration.
def deferredObserveState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +result: Nat, +observer: Nat, +immediate: Bool, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      +again = {DeferredRegisterFlight{cell, R.DeferredCell.node(Deferred.cell(w, cell)), result} <> rest : List<&2, Task>}
      Machine{w, again, stack}
    case R.Fulfilled{+value}:
      +again = {DeferredRegisterFlight{cell, R.DeferredCell.node(Deferred.cell(w, cell)), result} <> rest : List<&2, Task>}
      B.choose(~Machine, immediate, _ => Machine{Deferred.land(w, cell, R.AsyncValue{result}, True{}), again, stack}, _ => Machine{F.enqueueDelivery(w, observer, False{}, value), again, stack})
    case R.Rejected{+error}:
      +again = {DeferredRegisterFlight{cell, R.DeferredCell.node(Deferred.cell(w, cell)), result} <> rest : List<&2, Task>}
      B.choose(~Machine, immediate, _ => Machine{Deferred.land(w, cell, R.AsyncValue{result}, True{}), again, stack}, _ => Machine{F.enqueueDelivery(w, observer, True{}, error), again, stack})

# handleAsync's own then subscription, using its existing registration/value
# helpers. This continuation returns into the wrapper and then the original
# Finish frame; it does not bypass recompute's selfRegistered/clear checks.

def deferredSubscribeState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +observer: Nat, +immediate: Bool, state: R.AsyncSettlement) -> Machine:
  match state:
    case R.Unresolved{}:
      +again = {DeferredAfterThen{cell, observer} <> rest : List<&2, Task>}
      Machine{w, again, stack}
    case R.Fulfilled{+value}:
      +again = {DeferredAfterThen{cell, observer} <> rest : List<&2, Task>}
      B.choose(~Machine, immediate, _ => Machine{w, AsyncFulfill{observer, value} <> again, stack}, _ => Machine{F.enqueueDelivery(w, observer, False{}, value), again, stack})
    case R.Rejected{+error}:
      +again = {DeferredAfterThen{cell, observer} <> rest : List<&2, Task>}
      B.choose(~Machine, immediate, _ => Machine{w, AsyncReject{observer, error} <> again, stack}, _ => Machine{F.enqueueDelivery(w, observer, True{}, error), again, stack})

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

def latestWindow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +body: R.Expr, +previous: R.Value) -> Machine:
  +w = Verdict.markVerdictReader(w, 2)
  +state = R.World.verdictState(w)
  +w = Verdict.restoreLatest(w, True{}, True{})
  Machine{w, Evaluate{body, previous} <> LatestEnd{R.VerdictState.latestActive(state), R.VerdictState.dispatch(state), stack} <> rest, stack}

def pendingWindow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +body: R.Expr, +previous: R.Value) -> Machine:
  +w = Verdict.markVerdictReader(w, 1)
  +state = R.World.verdictState(w)
  +w = Verdict.restoreProbe(w, True{}, False{}, True{})
  Machine{w, Evaluate{body, previous} <> ProbeEnd{R.VerdictState.probing(state), R.VerdictState.probeFound(state), R.VerdictState.dispatch(state), stack} <> rest, stack}

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
    case R.OnFlush{body}:
      Machine{OnFlush.register(w,body),rest,R.Undefined{} <> stack}
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
    case R.Affects{target, key}:
      Machine{w, Evaluate{target, prev} <> AffectsTarget{key, prev} <> rest, stack}
    case R.Latest{body}:
      latestWindow(w, rest, stack, body, prev)
    case R.IsPending{body}:
      pendingWindow(w, rest, stack, body, prev)
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
    case R.OptimisticComputeScope{compute, options, body}:
      optimisticCompute(w, rest, stack, compute, options, body, prev)
    case R.OptimisticScope{initial, options, body}:
      Machine{w, Evaluate{initial, prev} <> CreateOptimistic{options, body, prev} <> rest, stack}
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
    case R.DeferredAccessor{compute, options}:
      deferredExpression(w, rest, stack, compute, options, False{})
    case R.DeferredRead{compute, options}:
      deferredExpression(w, rest, stack, compute, options, True{})
    case R.DeferredCompute{cell, compute}:
      deferredBody(w, rest, stack, cell, compute, prev)
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
    case R.FromInput{callee}:
      Machine{w, Evaluate{callee, prev} <> FromInput{} <> rest, stack}
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

# onSupersede's captured prev()/fn() closure; callbacks run through Core.
def supersedeFinally(+w: R.World, rest: List<&2, Task>, callback: Nat, +saved: List<&2, R.Value>) -> Machine:
  +prior = R.World.fault(w)
  Machine{R.World.with_fault(w, R.Healthy{}), Evaluate{R.CallProgram{callback}, R.Undefined{}} <> SupersedeRestore{prior, saved} <> rest, saved}

# from.ts:close's try/catch is local to the unsubscribe callback. Clearing the
# captured unsubscribe precedes the call; future finish calls remain idempotent.
def fromClose(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, plan: Nat) -> Machine:
  +pair = From.close(w, plan)
  +w = B.first(R.World, R.Value, pair)
  +callee = B.second(R.World, R.Value, pair)
  B.choose(~Machine, B.nullish(callee), _ => Machine{w, rest, stack},
    _ => Machine{w, Evaluate{R.Invoke{R.Literal{callee}}, R.Undefined{}} <> FromCleanupFinally{stack} <> rest, stack})

# toCleanup's function arm. Other admitted data values have no unsubscribe
# property and produce the source's fresh empty function.
def fromCleanupValue(+w: R.World, +value: R.Value) -> B.Bundle<R.World, R.Value>:
  B.choose(~B.Bundle<R.World, R.Value>, From.callable(value), _ => B.Bundle{w, value},
    _ =>
      +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
      B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[], False{}, 0n}])), R.ProgramReference{callback}})

# The two source branches capture the same finish identity through binding.
def fromFinish(+w: R.World, +plan: Nat) -> Nat:
  B.choose(~Nat, WrappedFrom.wrappedState(R.StreamPlan.fromState(B.streamPlan(w, plan))),
    _ => R.FromWrapped.finish(WrappedFrom.get(w, plan)), _ => R.FromSubscription.finish(From.subscription(w, plan)))

def fromSetFinish(+w: R.World, +plan: Nat, +callback: Nat) -> R.World:
  B.choose(~R.World, WrappedFrom.wrappedState(R.StreamPlan.fromState(B.streamPlan(w, plan))),
    _ => WrappedFrom.store(w, plan, R.FromWrapped.with_finish(WrappedFrom.get(w, plan), callback)),
    _ => From.store(w, plan, R.FromSubscription.with_finish(From.subscription(w, plan), callback)))

# bindToOwner happens after the subscription and any late assigned teardown.
def fromBind(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +iterator: Nat) -> Machine:
  +plan = R.ExternalIterator.plan(B.iterator(w, iterator))
  +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +action = B.choose(~R.CleanupAction, WrappedFrom.wrappedState(R.StreamPlan.fromState(B.streamPlan(w, plan))), _ => R.FromWrappedFinish{plan}, _ => R.FromFinish{plan})
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[action], False{}, 0n}]))
  +w = fromSetFinish(w, plan, callback)
  +w = Supersede.register(w, callback)
  +owner = R.World.context(w)
  +w = B.choose(~R.World, Bool.and(Nat.is_ne(owner, 0n), Bool.not(B.has(R.Node.config(B.node(w, owner)), K.CONFIG_CHILDREN_FORBIDDEN()))),
    _ => O.cleanup(w, owner, callback), _ => w)
  Machine{w, rest, R.IteratorReference{iterator} <> stack}

def fromSubscribed(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +iterator: Nat) -> Machine:
  match stack:
    case value <> +tail:
      +plan = R.ExternalIterator.plan(B.iterator(w, iterator))
      +pair = fromCleanupValue(w, value)
      +w = B.first(R.World, R.Value, pair)
      +callee = B.second(R.World, R.Value, pair)
      +w = From.store(w, plan, R.FromSubscription.with_unsubscribe(From.subscription(w, plan), callee))
      B.choose(~Machine, R.FromSubscription.closed(From.subscription(w, plan)),
        _ =>
          +w = From.store(w, plan, R.FromSubscription.with_unsubscribe(From.subscription(w, plan), R.Null{}))
          Machine{w, Evaluate{R.Invoke{R.Literal{callee}}, R.Undefined{}} <> FromCleanupFinally{tail} <> FromBindOwner{iterator} <> rest, tail},
        _ => fromBind(w, rest, tail, iterator))
    case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def fromOpened(rest: List<&2, Task>, stack: List<&2, R.Value>, opened: From.Opened) -> Machine:
  match opened:
    case From.Opened{world, iterator, subscribe, next, error, complete}:
      Machine{world, Evaluate{R.InvokeMany{R.Literal{subscribe}, R.CallArgumentsItem{R.Literal{R.ProgramReference{next}}, R.CallArgumentsItem{R.Literal{R.ProgramReference{error}}, R.CallArgumentsItem{R.Literal{R.ProgramReference{complete}}, R.CallArgumentsEnd{}}}}}, R.Undefined{}} <> FromSubscribed{iterator} <> rest, stack}

def fromOpenState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, state: R.FromState) -> Machine:
  match state:
    case R.FromFunction{callee}: fromOpened(rest, stack, From.open(w, callee))
    case R.FromIterable{+source}:
      B.choose(~Machine, From.factory(w, source),
        _ => Machine{w, FromOpen{source} <> FromWrapOpened{} <> rest, stack},
        _ =>
          +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(DeferredStream.planWrapper(w, source), 0n),
            _ => B.Bundle{w, DeferredStream.iterator(w, source)}, _ => IteratorInput.open(w, source))
          Machine{B.first(R.World, Nat, pair), FromWrapOpened{} <> rest, R.IteratorReference{B.second(R.World, Nat, pair)} <> stack})
    case _: Machine{R.World.with_fault(w, R.Unsupported{95n}), rest, stack}

def fromOpen(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, source: Nat) -> Machine:
  fromOpenState(w, rest, stack, From.origin(w, source))

# handleAsync's post-.then verdict, still inside recompute's try/catch.
def iterable(+w: R.World, value: R.Value) -> Nat:
  match value:
    case R.AsyncValue{+id}:
      B.choose(~Nat, Nat.is_ne(R.AsyncObject.stream(B.asyncObject(w, id)), 0n), _ => id, _ => 0n)
    case _:
      0n


def fromInput(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match stack:
    case +callee <> +tail:
      B.choose(~Machine, From.callable(callee),
        _ =>
          +pair = From.create(w, R.FromFunction{callee})
          Machine{B.first(R.World, Nat, pair), rest, R.AsyncValue{B.second(R.World, Nat, pair)} <> tail},
        _ => B.choose(~Machine, Nat.is_ne(iterable(w, callee), 0n),
          _ =>
            +pair = From.create(w, R.FromIterable{iterable(w, callee)})
            Machine{B.first(R.World, Nat, pair), rest, R.AsyncValue{B.second(R.World, Nat, pair)} <> tail},
          _ => Machine{R.World.with_fault(w, R.Unsupported{96n}), rest, tail}))
    case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
# Protocol-bearing closures must return through Core, including nesting.
def fromIterator(w: R.World, iterator: Nat) -> Bool:
  IteratorMethods.needsCore(w, iterator)

# wrapIterable's return catch is local; resource/unsupported faults stay visible.
def fromWrapFinishFinally(w: R.World, rest: List<&2, Task>, +saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{cause}: Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved}
    case R.TypeError{}: Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved}
    case _: Machine{w, rest, saved}

# Iterator.return method calls are user/protocol calls. Core supplies the
# existing catch boundary, including source from's nested close catch.
def iteratorReturned(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, returned: IteratorInput.Returned) -> Machine:
  match returned:
    case IteratorInput.MissingReturn{}: Machine{w, rest, R.Undefined{} <> stack}
    case IteratorInput.RawReturn{value}: Machine{w, rest, value <> stack}
    case IteratorInput.PromiseReturn{result}: Machine{w, rest, R.AsyncValue{result} <> stack}
    case IteratorInput.ThrowReturn{error}: Machine{R.World.with_fault(w, R.CallbackThrown{error}), rest, stack}

def iteratorReturn(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +iterator: Nat, +argument: R.Slot) -> Machine:
  +plan = R.ExternalIterator.plan(B.iterator(w, iterator))
  +wrapper = R.StreamPlan.wrapper(B.streamPlan(w, plan))
  B.choose(~Machine, Bool.or(From.isSubscription(w, iterator), WrappedFrom.isWrapped(w, iterator)),
    _ => Machine{w, Evaluate{R.CallProgram{fromFinish(w, plan)}, R.Undefined{}} <> FromReturnPromise{} <> rest, stack},
    _ => B.choose(~Machine, Nat.is_ne(wrapper, 0n),
      _ => Machine{w, IteratorReturn{R.DeferredIterator.inner(DeferredStream.wrapper(w, wrapper)), R.Present{R.Undefined{}}} <> DeferredReturnResult{} <> rest, stack},
      _ =>
        +pair = IteratorInput.returned(w, iterator, argument)
        iteratorReturned(B.first(R.World, IteratorInput.Returned, pair), rest, stack, B.second(R.World, IteratorInput.Returned, pair))))

def closeStream(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +stream: Nat) -> Machine:
  +s = B.stream(w, stream)
  B.choose(~Machine, R.StreamState.completed(s), _ => Machine{w, rest, stack},
    _ => Machine{B.store_stream(w, stream, R.StreamState.with_completed(s, True{})), IteratorReturn{R.StreamState.iterator(s), R.Empty{}} <> CloseReturnFinally{stack} <> rest, stack})

def ignoredReturn(+w: R.World, value: R.Value) -> R.World:
  match value:
    case R.AsyncValue{+result}:
      B.choose(~R.World, Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w, result)), 0n), _ => I.ignoreThen(w, result), _ => w)
    case _: w

def fromCleanupCatch(w: R.World, rest: List<&2, Task>, saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{cause}: Machine{R.World.with_fault(w, R.Healthy{}), rest, saved}
    case R.TypeError{}: Machine{R.World.with_fault(w, R.Healthy{}), rest, saved}
    case _: Machine{w, rest, saved}

def callbackAction(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +tail: List<&2, R.CleanupAction>, +first: R.Value, +second: R.Value, value: R.CleanupAction) -> Machine:
  match value:
    case R.FromNext{plan}:
      Machine{From.emitted(w, plan, first), Callback{id, tail, first, second} <> rest, stack}
    case R.FromError{+plan}:
      B.choose(~Machine, R.FromSubscription.done(From.subscription(w, plan)),
        _ => Machine{w, Callback{id, tail, first, second} <> rest, stack},
        _ => fromClose(From.failed(w, plan, first), Callback{id, tail, first, second} <> rest, stack, plan))
    case R.FromComplete{+plan}:
      B.choose(~Machine, R.FromSubscription.done(From.subscription(w, plan)),
        _ => Machine{w, Callback{id, tail, first, second} <> rest, stack},
        _ => fromClose(From.completed(w, plan), Callback{id, tail, first, second} <> rest, stack, plan))
    case R.FromFinish{+plan}:
      fromClose(w, FromFinished{plan} <> rest, stack, plan)
    case R.FromWrappedFinish{+plan}:
      B.choose(~Machine, R.FromWrapped.closed(WrappedFrom.get(w, plan)),
        _ => Machine{w, rest, R.StepResult{True{}, R.Undefined{}} <> stack},
        _ => Machine{WrappedFrom.finish(w, plan), IteratorReturn{R.FromWrapped.inner(WrappedFrom.get(w, plan)), R.Empty{}} <> FromWrapFinishFinally{stack} <> rest, stack})
    case R.SupersedeChain{before, after}:
      Machine{w, Evaluate{R.CallProgram{before}, R.Undefined{}} <> SupersedeFinally{after, stack} <> Callback{id, tail, first, second} <> rest, stack}
    case R.OptimisticSetter{signal}:
      Machine{w, OptimisticArgument{signal} <> rest, first <> stack}
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
      +id = J.optimisticTarget(w, callback)
      B.choose(~Machine, Nat.is_ne(id, 0n),
        _ => Machine{w, OptimisticUpdater{id, expr} <> rest, tail},
        _ => Machine{R.World.with_fault(w, R.Unsupported{22n}), rest, tail})
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
def prepareDisposedAt(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +after: Task) -> Machine:
  +n = B.node(w, id)
  +parent = R.Node.parent(n)
  B.choose(~Machine, B.has(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()),
    _ => B.choose(~Machine, Bool.and(Nat.is_ne(parent, 0n), B.has(R.Node.flags(B.node(w, parent)), K.REACTIVE_DISPOSED())),
      _ => Machine{B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), K.CONFIG_AUTO_DISPOSE()))), after <> rest, stack},
      _ =>
        w = B.choose(~R.World, Bool.and(Nat.is_ne(parent, 0n), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE()))),
          _ => O.linkChild(w, parent, id), _ => w)
        Machine{w, Recompute{id, True{}} <> after <> rest, stack}),
    _ => Machine{w, after <> rest, stack})

def prepareDisposed(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat) -> Machine:
  prepareDisposedAt(w, rest, stack, id, ReadPrepared{id})

def prepareComputed(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +after: Task) -> Machine:
  B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_LAZY()),
    _ => Machine{B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), K.REACTIVE_LAZY()))),
      Recompute{id, True{}} <> after <> rest, stack},
    _ => B.choose(~Machine, Bool.and(B.computed(R.Node.kind(B.node(w, id))), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())),
      _ => prepareDisposedAt(w, rest, stack, id, after), _ => Machine{w, after <> rest, stack}))

# core.ts:pullComputed, with the caller's source return point explicit.
def pullComputed(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +after: Task, +carry: Bool) -> Machine:
  +w = B.choose(~R.World, Nat.is_ge(R.Node.height(B.node(w, id)), R.World.minimum(w)),
    _ => H.markHeap(H.markNode(w, reader, 2)), _ => w)
  todo = B.choose(~List<&2, Task>, Nat.is_ge(R.Node.height(B.node(w, id)), R.World.minimum(w)),
    _ => [Update{id}], _ => B.choose(~List<&2, Task>, B.has(R.Node.config(B.node(w, reader)), K.CONFIG_FRESH_READ()), _ => [Update{id}], _ => []))
  Machine{w, B.append(Task, todo, B.choose(~Task, carry, _ => RaiseHeight{id, reader}, _ => VerdictRaiseHeight{id, reader}) <> after <> rest), stack}

def prepareSlow(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +tracked = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, tracked, _ => G.link(w, id, reader), _ => w)
  B.choose(~Machine, Bool.and(tracked, B.computed(R.Node.kind(B.node(w, id)))),
    _ => pullComputed(w, rest, stack, id, reader, ReadStatus{id}, True{}),
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
def readPendingStatus(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool) -> Machine:
  +n = B.node(w, id)
  +foreign = Bool.and(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.and(Bool.not(forced), Bool.and(Bool.not(B.has(R.Node.config(n), K.CONFIG_OVERRIDE())), Bool.not(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())))))
  +forced = Bool.or(forced, Bool.and(foreign, Bool.and(Nat.is_ne(R.World.passLane(w), 0n), Bool.not(B.has(R.Node.status(B.node(w, reader)), K.STATUS_UNINITIALIZED())))))
  +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.and(foreign, Bool.and(Bool.not(forced), Bool.and(Nat.is_ne(reader, 0n), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT())))), _ => Verdict.observeFlight(w, reader, id), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, pair)
  +forced = Bool.or(forced, B.second(R.World, Bool, pair))
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

def readLaneValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool, value: R.Value) -> Machine:
  match value:
    case R.NotPendingToken{}:
      readPendingStatus(w, rest, stack, id, reader, forced)
    case other:
      served(w, rest, stack, reader, id, other)

def readLaneDone(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +forced: Bool) -> Machine:
  match stack:
    case value <> tail:
      readLaneValue(w, rest, tail, id, reader, forced, value)
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def readStatus(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +pair = X.enterRead(w, reader, id, True{})
  +w = B.first(R.World, Bool, pair)
  +forced = B.second(R.World, Bool, pair)
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()),
    _ => laneRead(w, LaneReadDone{id, reader, forced} <> rest, stack, reader, id),
    _ => readPendingStatus(w, rest, stack, id, reader, forced))

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
  +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.not(committed), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT())), _ => X.stagedScreen(w, reader), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, pair)
  +committed = Bool.or(committed, B.second(R.World, Bool, pair))
  +value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
  +w = B.choose(~R.World, committed, _ => w, _ => stagedRead(w, reader, 0n))
  served(w, rest, stack, reader, id, value)

# verdict.ts:verdictValue return points. Snapshot/store-folded protocols and
# DEV strict-read diagnostics remain outside this production non-store grammar.
def verdictBundle(+pair: B.Bundle<R.World, R.Value>, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat) -> Machine:
  +w = B.first(R.World, R.Value, pair)
  B.choose(~Machine, B.ok(w), _ => served(w, rest, stack, reader, id, B.second(R.World, R.Value, pair)), _ => Machine{w, rest, stack})

def verdictTerminal(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +tracked: Bool) -> Machine:
  +n = B.node(w, id)
  B.choose(~Machine, B.has(R.Node.status(n), K.STATUS_PENDING()),
    _ => B.choose(~Machine, Bool.not(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())),
      _ =>
        +w = Verdict.pendingVerdict(w, B.choose(~Nat, tracked, _ => reader, _ => 0n), id)
        served(w, rest, stack, reader, id, R.Node.value(B.node(w, id))),
      _ =>
        # spectating remains false in this admitted grammar, as in plain read.
        +w = B.choose(~R.World, Bool.and(Nat.is_ne(reader, 0n), Bool.and(Bool.not(R.World.tracking(w)), Nat.is_ne(id, reader))), _ => G.link(w, id, reader), _ => w)
        Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.error(B.extension(w, id))}), rest, stack}),
    _ => B.choose(~Machine, Bool.and(B.computed(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_ERROR())),
      _ => Machine{R.World.with_fault(w, R.CallbackThrown{R.NodeExtension.error(B.extension(w, id))}), rest, stack},
      _ => served(w, rest, stack, reader, id, R.Node.value(n))))

def verdictStaging(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +tracked: Bool, +uninitialized: Bool) -> Machine:
  +w = B.choose(~R.World, Bool.and(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()), Bool.not(uninitialized)),
    _ => Verdict.pendingVerdict(w, B.choose(~Nat, tracked, _ => reader, _ => 0n), id),
    _ => B.choose(~R.World, Bool.and(tracked, R.World.running(w)),
      _ => Verdict.provisionalVerdict(w, reader, Bool.and(Bool.not(R.VerdictState.latestActive(R.World.verdictState(w))), Bool.not(uninitialized))),
      _ => B.choose(~R.World, Bool.and(tracked, R.VerdictState.probing(R.World.verdictState(w))), _ => Verdict.watchVerdict(w, reader, False{}), _ => w)))
  B.choose(~Machine, R.VerdictState.latestActive(R.World.verdictState(w)),
    _ => B.choose(~Machine, R.World.running(w),
      _ => verdictBundle(Verdict.staged(w, id), rest, stack, id, reader),
      _ =>
        +w = B.choose(~R.World, Nat.is_ne(reader, 0n), _ => V.markLateLinker(w, reader), _ => w)
        served(w, rest, stack, reader, id, R.Node.value(B.node(w, id)))),
    _ => served(w, rest, stack, reader, id, R.Node.value(B.node(w, id))))

def verdictHeldValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +tracked: Bool) -> Machine:
  B.choose(~Machine, Bool.and(R.VerdictState.latestActive(R.World.verdictState(w)), B.present(R.Node.pending(B.node(w, id)))),
    _ =>
      +w = B.choose(~R.World, Bool.and(Bool.not(tracked), Bool.and(Nat.is_ne(R.World.flushTransaction(w), 0n), Bool.not(R.World.running(w)))),
        _ =>
          +pair = X.txOf(w, id)
          X.joinFuture(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)), _ => w)
      verdictBundle(Verdict.heldLatest(w, id, B.choose(~Nat, tracked, _ => reader, _ => 0n)), rest, stack, id, reader),
    _ => served(w, rest, stack, reader, id, R.Node.value(B.node(w, id))))

def verdictHeld(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +tracked: Bool) -> Machine:
  +pair = X.txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  +verdict = R.Transaction.verdict(B.transaction(w, t))
  +stale = Bool.and(tracked, Bool.and(Bool.not(R.VerdictState.probing(R.World.verdictState(w))), Bool.and(X.isRender(R.Node.kind(B.node(w, reader))), Bool.and(Nat.is_eq(R.World.passLane(w), 0n), Bool.and(Nat.is_ne(verdict, 0n), Bool.and(R.Transaction.held(B.transaction(w, verdict)), Nat.is_ne(R.World.flushTransaction(w), t)))))))
  B.choose(~Machine, stale,
    _ => served(X.staleReader(w, reader, verdict), rest, stack, reader, id, R.Node.value(B.node(w, id))),
    _ =>
      +w = B.choose(~R.World, tracked, _ => Verdict.verdictRead(w, reader, t, False{}), _ => w)
      B.choose(~Machine, R.VerdictState.probing(R.World.verdictState(w)),
        _ => heldNotFinal(w, VerdictHeldFinal{id, reader, tracked} <> rest, stack, id),
        _ => verdictHeldValue(w, rest, stack, id, reader, tracked)))

def verdictPlain(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +owned: Bool, +tracked: Bool) -> Machine:
  +n = B.node(w, id)
  +uninitialized = B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())
  B.choose(~Machine, B.has(R.Node.config(n), K.CONFIG_HELD()),
    _ => B.choose(~Machine, Bool.not(uninitialized),
      _ => verdictHeld(w, rest, stack, id, reader, tracked),
      _ => B.choose(~Machine, Bool.and(B.present(R.Node.pending(n)), Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING()))),
        _ =>
          +w = B.choose(~R.World, Bool.and(R.VerdictState.probing(R.World.verdictState(w)), owned), _ => X.joinPass(w, reader, id), _ => w)
          verdictBundle(Verdict.staged(w, id), rest, stack, id, reader),
        _ => verdictTerminal(w, rest, stack, id, reader, tracked))),
    _ => B.choose(~Machine, B.present(R.Node.pending(n)),
      _ => verdictStaging(w, rest, stack, id, reader, tracked, uninitialized),
      _ => verdictTerminal(w, rest, stack, id, reader, tracked)))

def verdictGuessValue(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +lane: Nat) -> Machine:
  # A folded store lane would invoke its callback here. Such lanes cannot be
  # constructed by this non-store grammar; this is the raw normal-lane slot.
  served(w, rest, stack, reader, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}))

def verdictOverride(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +tracked: Bool) -> Machine:
  +pair = X.txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +lane = B.second(R.World, Nat, pair)
  +parent = R.Transaction.parent(B.transaction(w, lane))
  +w = B.choose(~R.World, tracked, _ => Verdict.verdictRead(w, reader, B.choose(~Nat, Nat.is_ne(parent, 0n), _ => parent, _ => lane), False{}), _ => w)
  +flying = Bool.and(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()), Bool.not(Verdict.quietPending(w, id)))
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()),
    _ => B.choose(~Machine, R.VerdictState.probing(R.World.verdictState(w)),
      _ => B.choose(~Machine, flying,
        _ => verdictGuessValue(Verdict.found(w), rest, stack, id, reader, lane),
        _ => B.choose(~Machine, B.present(R.Node.pending(B.node(w, id))),
          _ => B.choose(~Machine, Bool.not(R.Node.equals(B.node(w, id))),
            _ => verdictGuessValue(Verdict.found(w), rest, stack, id, reader, lane),
            _ => rawEquals(w, VerdictGuessCompared{id, reader, lane} <> rest, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), B.selected(R.Node.pending(B.node(w, id)), R.NotPendingToken{}))),
          _ => verdictGuessValue(w, rest, stack, id, reader, lane))),
      _ => verdictGuessValue(w, rest, stack, id, reader, lane)),
    _ =>
      +w = B.choose(~R.World, Bool.and(R.VerdictState.probing(R.World.verdictState(w)), flying), _ => Verdict.found(w), _ => w)
      served(w, rest, stack, reader, id, B.choose(~R.Value, Bool.and(R.VerdictState.latestActive(R.World.verdictState(w)), Bool.not(flying)), _ => Truth.laneValueOf(w, id), _ => Lanes.display(w, id))))

def verdictAfterPull(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +owned: Bool, +tracked: Bool) -> Machine:
  +pair = B.choose(~B.Bundle<R.World, Bool>, R.VerdictState.probing(R.World.verdictState(w)), _ => Marks.covered(w, id), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, pair)
  +w = B.choose(~R.World, B.second(R.World, Bool, pair),
    _ =>
      +w = Verdict.found(w)
      B.choose(~R.World, Bool.and(tracked, Nat.is_ne(R.World.flushTransaction(w), 0n)), _ => Verdict.verdictRead(w, reader, R.World.flushTransaction(w), False{}), _ => w), _ => w)
  +n = B.node(w, id)
  B.choose(~Machine, Bool.and(B.has(R.Node.config(n), K.CONFIG_OVERRIDE()), Bool.not(Bool.and(B.has(R.Node.status(n), K.STATUS_ERROR()), Bool.not(B.has(R.Node.config(n), K.CONFIG_GUESS()))))),
    _ => verdictOverride(w, rest, stack, id, reader, tracked),
    _ => verdictPlain(w, rest, stack, id, reader, owned, tracked))

# verdict.ts: the owned/tracked locals are captured before waking the memo.
# Both prepareComputed and pullComputed execute outside the verdict window.
def verdictValue(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +reader: Nat) -> Machine:
  +owned = Bool.and(Nat.is_ne(reader, 0n), Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())))
  +tracked = Bool.and(owned, R.World.tracking(w))
  prepareComputed(Verdict.setDispatch(w, False{}), rest, stack, id, VerdictPrepared{id, reader, owned, tracked})

def verdictPrepared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +owned: Bool, +tracked: Bool) -> Machine:
  +links = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, links, _ => G.link(w, id, reader), _ => w)
  B.choose(~Machine, Bool.and(links, B.computed(R.Node.kind(B.node(w, id)))),
    _ => pullComputed(w, rest, stack, id, reader, VerdictPulled{id, reader, owned, tracked}, False{}),
    _ => verdictAfterPull(Verdict.setDispatch(w, True{}), rest, stack, id, reader, owned, tracked))

def readNode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  B.choose(~Machine, B.valid(w, id),
    _ => B.choose(~Machine, R.VerdictState.dispatch(R.World.verdictState(w)),
      _ => verdictValue(w, rest, stack, id, B.parentComputed(w, R.World.context(w))),
      _ => prepareComputed(w, rest, stack, id, ReadPrepared{id})),
    _ => Machine{R.World.with_fault(w, R.BadId{}), [], []})

def readPlainPrepared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  +n = B.node(w, id)
  fast = Bool.and(Bool.not(B.computed(R.Node.kind(n))),
    Bool.and(Bool.or(Bool.not(R.World.unflushedStaged(w)), Bool.not(B.present(R.Node.pending(n)))),
      Bool.not(B.has(R.Node.config(n), K.CONFIG_OVERRIDE()))))
  B.choose(~Machine, fast, _ => readSignalFast(w, rest, stack, id), _ => prepareSlow(w, rest, stack, id))

def readPrepared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat) -> Machine:
  readPlainPrepared(w, rest, stack, id)

def serveSelected(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +reader: Nat, +u: R.Slot) -> Machine:
  B.choose(~Machine, B.present(u),
    _ => served(V.markLateLinker(w, reader), rest, stack, reader, id, B.selected(u, R.Undefined{})),
    _ =>
      +n = B.node(w, id)
      +committed = V.readerSeesCommitted(w, id, reader)
      +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.not(committed), Bool.and(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT()), Bool.not(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED())))), _ => X.stagedScreen(w, reader), _ => B.Bundle{w, False{}})
      +w = B.first(R.World, Bool, pair)
      +committed = Bool.or(committed, B.second(R.World, Bool, pair))
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

def raiseSourceHeight(+w: R.World, +source: Nat, +reader: Nat) -> R.World:
  +height = R.Node.height(B.node(w, source))
  +c = B.node(w, reader)
  +w = B.choose(~R.World, Bool.and(Nat.is_ge(height, R.Node.height(c)), Nat.is_ne(R.Node.parent(B.node(w, source)), reader)),
    _ => B.store_node(w, reader, R.Node.with_height(c, 1n+height)), _ => w)
  w

def raiseHeight(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +source: Nat, +reader: Nat) -> Machine:
  +w = raiseSourceHeight(w, source, reader)
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
  todo = B.choose(~List<&2, Task>, Bool.or(B.has(R.Node.flags(B.node(w, id)), 2), Bool.and(B.truth(R.NodeExtension.error(B.extension(w, id))), Bool.and(Nat.is_lt(R.Node.time(B.node(w, id)), R.World.clock(w)), Nat.is_eq(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), 0n)))), _ => [Recompute{id, False{}}], _ => [])
  Machine{w, B.append(Task, todo, ClearFlags{id} <> rest), stack}

# core.ts:recompute's source lane/mount locals. laneRoot distinguishes unset,
# false and a transaction pointer; it is restored in the body finally.
def previousLane(frame: LanePass) -> Nat:
  match frame:
    case LanePass{lane, mount, current}:
      lane

def previousMount(frame: LanePass) -> R.LaneMount:
  match frame:
    case LanePass{lane, mount, current}:
      mount

def passMount(frame: LanePass) -> R.LaneMount:
  match frame:
    case LanePass{lane, mount, current}:
      current

def hasMount(mount: R.LaneMount) -> Bool:
  match mount:
    case R.MountLane{lane}:
      True{}
    case _:
      False{}

def seatPass(+w: R.World, +id: Nat, +create: Bool) -> B.Bundle<R.World, LanePass>:
  +previous = R.World.passLane(w)
  +oldMount = R.LaneState.root(R.World.laneState(w))
  +mount = B.choose(~R.LaneMount, create,
    _ => B.choose(~R.LaneMount, Nat.is_ne(previous, 0n), _ => R.MountLane{previous}, _ => oldMount), _ => R.MountFalse{})
  +w = R.World.with_laneState(w, R.LaneState.with_root(R.World.laneState(w), mount))
  +n = B.node(w, id)
  +tx = R.NodeExtension.transaction(B.extension(w, id))
  +own = Bool.and(Bool.or(B.has(R.Node.flags(n), K.REACTIVE_LANE_DIRTY()), U32.is_eq(U32.and(R.Node.config(n), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())), K.CONFIG_OVERRIDE())), R.Transaction.lane(B.transaction(w, tx)))
  +inherit = Bool.and(create, Bool.and(Nat.is_ne(previous, 0n), Bool.and(Nat.is_ne(R.Transaction.verdict(B.transaction(w, R.Transaction.parent(B.transaction(w, previous)))), previous), B.has(R.Node.flags(B.node(w, B.parentComputed(w, R.World.context(w)))), K.REACTIVE_RECOMPUTING_DEPS()))))
  +lane = B.choose(~Nat, own, _ => tx, _ => B.choose(~Nat, inherit, _ => previous, _ => 0n))
  B.Bundle{R.World.with_passLane(w, lane), LanePass{previous, oldMount, mount}}

def joinedPass(+w: R.World, +id: Nat, +frame: LanePass) -> Bool:
  +staged = Bool.and(hasMount(passMount(frame)), Bool.or(Nat.is_ne(previousLane(frame), 0n), Bool.or(B.effect(R.Node.kind(B.node(w, id))), Bool.not(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))))
  +mask = B.choose(~U32, hasMount(passMount(frame)),
    _ => B.choose(~U32, staged, _ => U32.or(K.REACTIVE_JOINED(), K.REACTIVE_STAGED_READ()), _ => 0),
    _ => K.REACTIVE_JOINED())
  B.has(R.Node.flags(B.node(w, id)), mask)

def restoreMount(+w: R.World, frame: LanePass) -> R.World:
  R.World.with_laneState(w, R.LaneState.with_root(R.World.laneState(w), previousMount(frame)))

# core.ts's previous/compare slot: pending takes precedence even on a guess.
def passValue(+w: R.World, +id: Nat) -> R.Value:
  +n = B.node(w, id)
  B.choose(~R.Value, B.present(R.Node.pending(n)),
    _ => B.selected(R.Node.pending(n), R.Undefined{}),
    _ => B.choose(~R.Value, Bool.and(B.has(R.Node.config(n), K.CONFIG_OVERRIDE()), B.present(R.NodeExtension.lane(B.extension(w, id)))),
      _ => B.selected(R.NodeExtension.lane(B.extension(w, id)), R.Undefined{}), _ => R.Node.value(n)))

def recomputePrepared(+w: R.World, rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, released: Nat, +lanePass: LanePass) -> Machine:
  +n = B.node(w, id)
  reask = Bool.and(B.has(R.Node.flags(n), K.REACTIVE_REASK()),
    Bool.not(Bool.and(Bool.or(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.and(R.LaneState.guessing(R.World.laneState(w)), B.present(R.Node.pending(n)))), Bool.and(Nat.is_ne(R.Node.x(n), 0n), Bool.not(R.NodeExtension.reask(B.extension(w, id)))))))
  +context = R.World.context(w)
  +w = R.World.with_context(w, id)
  +n = R.Node.with_depsTail(n, 0n)
  +n = R.Node.with_depGen(n, 1n+R.Node.depGen(n))
  +n = R.Node.with_flags(n, B.set(K.REACTIVE_RECOMPUTING_DEPS(), U32.and(R.Node.flags(n), B.set(K.REACTIVE_ZOMBIE(), K.REACTIVE_REASK()))))
  +n = R.Node.with_time(n, R.World.clock(w))
  +w = B.store_node(w, id, n)
  frame = {PassFrame{id, create, context, R.World.tracking(w), R.Node.height(n), reask, passValue(w, id), B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()),
    B.choose(~R.Value, B.has(R.Node.status(n), K.STATUS_ERROR()), _ => R.NodeExtension.error(B.extension(w, id)), _ => R.Undefined{}),
    B.choose(~Nat, B.has(R.Node.status(n), K.STATUS_PENDING()), _ => R.NodeExtension.pendingSources(B.extension(w, id)), _ => 0n),
    P.hasSource(w, id, id), B.flight(w, id), stack, released, R.World.stale(w), lanePass} : PassFrame}
  next = {Evaluate{R.Node.expr(n), passValue(w, id)} <> Finish{frame} <> rest : List<&2, Task>}
  +w = R.World.with_stale(w, Bool.or(R.World.stale(w), Bool.and(B.effect(R.Node.kind(n)), Bool.not(S.is_user(R.Node.kind(n))))))
  w = R.World.with_tracking(B.choose(~R.World, B.tracked(R.Node.kind(n)), _ => w, _ => B.event(w, R.Invoked{id})), True{})
  Machine{w, next, stack}

# core.ts:recompute before its body try: callbacks here unwind the caller.
def recomputeAfterFlight(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lanePass: LanePass) -> Machine:
  +n = B.node(w, id)
  +w = B.choose(~R.World, B.has(R.Node.status(n), K.STATUS_PENDING()),
    _ => B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), K.CONFIG_VERDICT()))), _ => w)
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.reenterHeld(w, id), _ => w)
  B.choose(~Machine, Bool.or(B.tracked(R.Node.kind(B.node(w, id))), B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED())),
    _ =>
      +previous = R.World.deferredReleases(w)
      +pair = GS.beginReleases(w)
      Machine{B.first(R.World, Nat, pair), OwnerTasks{[O.Enter{id, False{}, False{}}]} <> RestoreDeferredReleases{id, previous, B.second(R.World, Nat, pair), lanePass} <> rest, stack},
    _ =>
      w = B.choose(~R.World, Bool.or(Nat.is_ne(R.Node.firstChild(B.node(w, id)), 0n), Bool.not(B.noDisposal(R.Node.disposal(B.node(w, id))))),
        _ => O.parkChildren(w, id), _ => w)
      Machine{w, RecomputeAfterTeardown{id, 0n, lanePass} <> rest, stack})

# core.ts:recompute after frame teardown and deferred-array restoration.
def recomputeAfterTeardown(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, released: Nat, +lanePass: LanePass) -> Machine:
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()),
    _ =>
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{}))
      B.store_node(w, id, R.Node.with_config(B.node(w, id), U32.xor(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()))), _ => w)
  Machine{w, RecomputePrepared{id, False{}, released, lanePass} <> rest, stack}

def recomputeFlight(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lanePass: LanePass) -> Machine:
  +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{}))
  +callback = R.NodeExtension.flightTeardown(B.extension(w, id))
  B.choose(~Machine, Nat.is_ne(callback, 0n),
    _ => Machine{B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), 0n)),
      OwnerTasks{[O.Invoke{callback}]} <> RecomputeAfterFlight{id, lanePass} <> rest, stack},
    _ => Machine{w, RecomputeAfterFlight{id, lanePass} <> rest, stack})

def recompute(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool) -> Machine:
  +w = B.bump(w)
  +seat = seatPass(w, id, create)
  +w = B.first(R.World, LanePass, seat)
  +lanePass = B.second(R.World, LanePass, seat)
  B.choose(~Machine, create, _ => recomputePrepared(w, rest, stack, id, create, 0n, lanePass),
    _ =>
      +w = H.deleteFromHeap(w, id)
      B.choose(~Machine, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => recomputeFlight(w, rest, stack, id, lanePass),
        _ => recomputeAfterFlight(w, rest, stack, id, lanePass)))

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

# core.ts's mainline born-held branch, after a lane has been excluded.
def bornHeld(+w: R.World, joined: Bool) -> Bool:
  Bool.and(Bool.or(Nat.is_ne(R.World.flushTransaction(w), 0n), Nat.is_ne(R.World.passTx(w), 0n)),
    Bool.or(joined, B.has(R.Node.flags(B.node(w, B.parentComputed(w, R.World.context(w)))), K.REACTIVE_JOINED())))

def publicationTx(+w: R.World) -> Nat:
  B.choose(~Nat, Nat.is_ne(R.World.flushTransaction(w), 0n), _ => R.World.flushTransaction(w), _ => R.World.passTx(w))

# core.ts effect-run decision, before the guess-outcome hook. The lane is the
# captured local, not an ambient lane possibly changed by an equality callback.
def markPublishedEffectAs(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +changed: Bool, +lane: Nat, isEffect: Bool) -> R.World:
  +n = B.node(w, id)
  +screenSame = Bool.and(B.has(R.Node.flags(n), K.REACTIVE_SCREEN_READ()), Bool.and(Bool.not(R.Node.modified(n)), B.objectIs(R.Node.prevValue(n), value)))
  B.choose(~R.World, Bool.and(isEffect, Bool.and(changed, Bool.and(Bool.not(screenSame), Bool.not(B.present(R.Node.pending(n)))))),
    _ =>
      +w = B.store_node(w, id, R.Node.with_modified(n, Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id))))))
      B.choose(~R.World, Bool.or(Bool.not(create), Nat.is_ne(lane, 0n)), _ => W.enqueueIn(w, id, lane), _ => w), _ => w)

def markPublishedEffect(+w: R.World, +id: Nat, value: R.Value, create: Bool, changed: Bool, lane: Nat) -> R.World:
  markPublishedEffectAs(w, id, value, create, changed, lane, B.effect(R.Node.kind(B.node(w, id))))

# core.ts publication stores/notification, after any guess outcome returned false.
def publishStoresAs(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, joined: Bool, +changed: Bool, +lane: Nat, +isEffect: Bool, +subs: Nat) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  +w = B.choose(~R.World, changed,
    _ =>
      +w = B.choose(~R.World, Nat.is_ne(lane, 0n),
        _ => B.choose(~R.World, Bool.and(isEffect, Bool.not(B.present(R.Node.pending(n)))),
          _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
          _ => B.choose(~R.World, Bool.or(isEffect, R.Transaction.shown(B.transaction(w, lane))),
            _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})),
            _ => B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{value})))),
        _ =>
          +direct = B.choose(~Bool, create, _ => Bool.not(bornHeld(w, joined)), _ => Bool.and(isEffect, Bool.not(B.present(R.Node.pending(B.node(w, id))))))
          B.choose(~R.World, direct,
            _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
            _ =>
              +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
              B.choose(~R.World, create,
                _ =>
                  +w = X.holdNode(w, id, publicationTx(w))
                  B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))), _ => w)))
      B.choose(~R.World, Nat.is_ne(subs, 0n),
        _ =>
          +w = S.insertSubs(w, id)
          B.choose(~R.World, Nat.is_ne(lane, 0n), _ => Lanes.laneDirty(w, id, lane), _ => w), _ => w),
    _ => B.choose(~R.World, Nat.is_ne(R.Node.height(B.node(w, id)), oldHeight),
      _ => H.height_subs(B.budget(w), w, subs), _ => w))
  B.Bundle{w, changed}

def publishStores(+w: R.World, +id: Nat, value: R.Value, create: Bool, oldHeight: Nat, joined: Bool, changed: Bool, lane: Nat) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  publishStoresAs(w, id, value, create, oldHeight, joined, changed, lane, B.effect(R.Node.kind(n)), R.Node.subs(n))

# Explicit mainline leaf used by the scalar publication helper/proof profile.
def publishValueChanged(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, joined: Bool, +changed: Bool) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  +isEffect = B.effect(R.Node.kind(n))
  publishStoresAs(markPublishedEffectAs(w, id, value, create, changed, 0n, isEffect), id, value, create, oldHeight, joined, changed, 0n, isEffect, R.Node.subs(n))

# core.ts default equality profile of the source valueChanged expression.
def publicationChanged(+w: R.World, +id: Nat, +value: R.Value, wasUninitialized: Bool) -> Bool:
  +n = B.node(w, id)
  Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(n))), wasUninitialized),
    Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.not(EQ.isSame(w, id, passValue(w, id), value))))

def publishValue(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, wasUninitialized: Bool, +joined: Bool) -> B.Bundle<R.World, Bool>:
  publishValueChanged(w, id, value, create, oldHeight, joined, publicationChanged(w, id, value, wasUninitialized))

# recompute's queue decision is after its successful dependency trim callback.
def queuePublicationIn(+w: R.World, +id: Nat, create: Bool, +lane: Nat) -> R.World:
  B.choose(~R.World, B.ok(w),
    _ =>
      +n = B.node(w, id)
      queued = Bool.or(B.present(R.Node.pending(n)), Bool.or(O.parked(w, id),
        Bool.and(B.has(R.Node.status(n), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED())), Bool.or(Bool.not(create), B.has(R.Node.status(n), K.STATUS_PENDING())))))
      B.choose(~R.World, queued, _ =>
        +w = B.store_node(w, id, R.Node.with_config(n, B.set(R.Node.config(n), K.CONFIG_STAGED())))
        B.choose(~R.World, Nat.is_eq(lane, 0n), _ => S.queuePendingNode(w, id), _ => w), _ => w),
    _ => w)

def queuePublication(+w: R.World, +id: Nat, create: Bool) -> R.World:
  queuePublicationIn(w, id, create, 0n)

def finishPublication(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, joined: Bool, +missed: Bool, +lane: Nat, previousLane: Nat) -> Machine:
  +w = B.choose(~R.World, Bool.and(Nat.is_eq(lane, 0n), Bool.and(create, Bool.and(joined, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))),
    _ =>
      +t = publicationTx(w)
      B.choose(~R.World, Bool.and(Nat.is_ne(t, 0n), Bool.not(R.Transaction.lane(B.transaction(w, t)))), _ => X.holdNode(w, id, t), _ => w), _ => w)
  +n = B.node(w, id)
  +ending = {QueuePublication{id, create, missed, lane, previousLane} <> rest : List<&2, Task>}
  B.choose(~Machine, Bool.and(Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))), Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.not(Bool.and(B.effect(R.Node.kind(n)), R.Node.modified(n))))),
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
def publicationOutcome(+w: R.World, +id: Nat, create: Bool, +lane: Nat) -> Bool:
  Bool.and(Bool.not(create), Bool.and(Nat.is_eq(lane, 0n), B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS())))

def publishCompared(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +joined: Bool, +changed: Bool, +lane: Nat) -> Machine:
  +n = B.node(w, id)
  +isEffect = B.effect(R.Node.kind(n))
  +subs = R.Node.subs(n)
  +w = markPublishedEffectAs(w, id, value, create, changed, lane, isEffect)
  B.choose(~Machine, publicationOutcome(w, id, create, lane),
    _ => Machine{w, LaneOutcomeStart{id, value, False{}} <> PublishOutcome{id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, changed} <> rest, stack},
    _ => publicationCompleted(rest, stack, id, outgoing, outgoingSources, wasPendingSource, publishStoresAs(w, id, value, create, oldHeight, joined, changed, lane, isEffect, subs)))

def publishState(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, +wasUninitialized: Bool, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +joined: Bool, +errored: Bool, +lane: Nat) -> Machine:
  B.choose(~Machine, errored, _ => Machine{w, rest, stack},
    _ => B.choose(~Machine, Nat.is_eq(EQ.custom(w, id), 0n),
      _ => publishCompared(w, rest, stack, id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, publicationChanged(w, id, value, wasUninitialized), lane),
      _ => B.choose(~Machine, Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), wasUninitialized), B.truth(R.NodeExtension.shownError(B.extension(w, id)))),
        _ => publishCompared(w, rest, stack, id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, True{}, lane),
        _ => isSame(w, PublishCompared{id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, errored, lane} <> rest, stack, id, passValue(w, id), value))))

# recompute's finally is shared by normal return and exceptional unwind.
def passFinallyBody(+w: R.World, +id: Nat, create: Bool, context: Nat) -> R.World:
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

# core.ts after its body finally, before equality: capture a separate local
# publication lane. A refusal leaves the ambient passLane untouched.
def stagePassAt(+w: R.World, +id: Nat, +create: Bool, +errored: Bool, +seated: Nat) -> B.Bundle<R.World, Nat>:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(seated, 0n),
    _ => Lanes.laneStage(w, id, seated, create, B.choose(~Lanes.StageError, errored, _ => Lanes.StageFailed{}, _ => Lanes.StageAnswered{})), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, pair)
  +lane = B.choose(~Nat, B.second(R.World, Bool, pair), _ => seated, _ => 0n)
  B.Bundle{B.choose(~R.World, Nat.is_ne(lane, 0n), _ => R.World.with_passLane(w, lane), _ => w), lane}

def stagePass(+w: R.World, id: Nat, create: Bool, errored: Bool) -> B.Bundle<R.World, Nat>:
  stagePassAt(w, id, create, errored, R.World.passLane(w))

def afterPass(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +create: Bool, +value: R.Value, +oldHeight: Nat, +wasUninitialized: Bool, +outgoing: R.Value, +outgoingSources: Nat, +wasPendingSource: Bool, +joined: Bool, +stagedErr: Bool, +missed: Bool, +previousLane: Nat) -> Machine:
  B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()),
    _ =>
      Machine{w, OwnerTasks{[O.ClearDeps{id}]} <> AfterDeadPass{id, previousLane} <> rest, stack},
    _ =>
      +errored = Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), stagedErr)
      +seated = R.World.passLane(w)
      B.choose(~Machine, Nat.is_eq(seated, 0n),
        _ => publishState(w, FinishPublication{id, create, joined, missed, 0n, previousLane} <> rest, stack, id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, errored, 0n),
        _ => Machine{w, PassLaneStage{id, create, value, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, errored, missed, previousLane, seated} <> rest, stack}))

# Source finally executes its deferred releases even when unwinding a body
# failure. A release failure replaces that failure and skips the remaining tail.
def startPassFinally(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame, value: R.Value, joined: Bool, stagedErr: Bool, missed: Bool) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      +w = R.World.with_tracking(w, tracking)
      +w = restoreMount(w, lanePass)
      +w = R.World.with_stale(w, stale)
      +joined = joinedPass(w, id, lanePass)
      +w = passFinallyBody(w, id, create, context)
      Machine{R.World.with_fault(w, R.Healthy{}), PassReleases{frame, 0n, value, joined, stagedErr, missed, R.World.fault(w)} <> rest, stack}

def passReleases(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +index: Nat, +value: R.Value, +joined: Bool, +stagedErr: Bool, +missed: Bool, +prior: R.Fault) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      +nodes = B.get(List<&2, Nat>, R.World.releaseLists(w), released, [])
      B.choose(~Machine, Nat.is_ge(index, B.length(Nat, nodes)),
        _ =>
          +w = R.World.with_fault(passFinallyTail(w, id, reask), prior)
          B.choose(~Machine, B.ok(w),
            _ => afterPass(w, rest, stack, id, create, value, height, uninitialized, outgoing, sources, pendingSource, joined, stagedErr, missed, previousLane(lanePass)),
            _ => Machine{w, rest, stack}),
        _ =>
          +node = B.get(Nat, nodes, index, 0n)
          +ending = {PassReleases{frame, 1n+index, value, joined, stagedErr, missed, prior} <> rest : List<&2, Task>}
          Machine{w, B.choose(~List<&2, Task>, Q.releasable(w, node), _ => OwnerTasks{[O.Unobserved{node}]} <> ending, _ => ending), stack})

def finishReady(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame, +keepFlight: Bool) -> Machine:
  match stack frame:
    case value <> +tail PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      +w = B.choose(~R.World, Bool.and(Bool.not(keepFlight), Nat.is_ne(R.Node.x(B.node(w, id)), 0n)),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{})), _ => w)
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
def attachIterator(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, +stream: Nat, deferred: Bool) -> Machine:
  +close = R.StreamState.close(B.stream(w, stream))
  +w = O.cleanup(w, B.choose(~Nat, deferred, _ => id, _ => R.World.context(w)), close)
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_flightTeardown(B.extension(w, id), close))
  Machine{w, IterateStream{stream} <> AfterConsume{stream} <> rest, stack}

def consumeIterator(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +source: Nat, +deferred: Bool, +initialValue: R.Value) -> Machine:
  B.choose(~Machine, From.factory(w, source),
    _ => Machine{w, FromOpen{source} <> FromConsumeAcquired{id, result, deferred, initialValue} <> rest, stack},
    _ =>
      +pair = I.newStream(w, id, result, source, deferred, initialValue)
      +w = B.first(R.World, Nat, pair)
      B.choose(~Machine, B.ok(w),
        _ => attachIterator(w, rest, stack, id, B.second(R.World, Nat, pair), deferred),
        _ => Machine{w, rest, stack}))

def fromConsumed(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +id: Nat, result: Nat, +deferred: Bool, initialValue: R.Value) -> Machine:
  match stack:
    case R.IteratorReference{iterator} <> tail:
      +pair = I.streamForIterator(w, id, result, iterator, deferred, initialValue)
      attachIterator(B.first(R.World, Nat, pair), rest, tail, id, B.second(R.World, Nat, pair), deferred)
    case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

# deferred.ts open-window stream: capture the source iterator, ask(s), then
# serve the distinct iterable through the existing handleAsync engine.
def deferredWrapped(+rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +pair: B.Bundle<R.World, Nat>) -> Machine:
  +w = B.first(R.World, Nat, pair)
  B.choose(~Machine, B.ok(w),
    _ =>
      +result = B.second(R.World, Nat, pair)
      +node = R.DeferredCell.node(Deferred.cell(w, cell))
      +w = Deferred.ask(w, cell, DeferredStream.flight(w, result))
      consumeIterator(F.startFlight(w, node, result), DeferredAfterIterator{cell} <> rest, stack, node, result, result, False{}, R.Undefined{}),
    _ => Machine{w, rest, stack})

def deferredStream(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +source: Nat) -> Machine:
  B.choose(~Machine, From.factory(w, source),
    _ => Machine{w, FromOpen{source} <> FromDeferredAcquired{cell} <> rest, stack},
    _ => deferredWrapped(rest, stack, cell, DeferredStream.wrap(w, cell, source)))

def fromDeferred(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +cell: Nat) -> Machine:
  match stack:
    case R.IteratorReference{iterator} <> tail:
      deferredWrapped(rest, tail, cell, DeferredStream.allocate(w, cell, iterator))
    case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

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

def finishResult(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: PassFrame, +id: Nat, oldFlight: R.Flight) -> Machine:
  +selfRegistered = Bool.not(B.sameFlight(B.flight(w, id), oldFlight))
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SYNC()),
    _ => finishReady(w, rest, stack, frame, False{}),
    _ => B.choose(~Machine, selfRegistered, _ => finishReady(w, rest, stack, frame, True{}),
      _ => finishShape(w, rest, stack, frame, id)))

def finish(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame) -> Machine:
  match frame:
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, +flight, saved, released, stale, lanePass}:
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
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
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
      A.notifyStatusWith(w, id, B.choose(~U32, notReady, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), cause), _ => w)
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
    case PassFrame{+id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      +ending = {CatchRetireSources{frame, Bool.or(notReady, stagedErr)} <> rest : List<&2, Task>}
      B.choose(~Machine, Bool.and(notReady, Bool.and(pendingSource, Nat.is_eq(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), 0n))),
        _ => pendingResume(ending, stack, Q.beginSettlement(w, id, id)),
        _ => Machine{w, ending, stack})

def catchRetireSources(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, frame: PassFrame, +retire: Bool) -> Machine:
  match frame:
    case PassFrame{id, create, context, tracking, height, reask, previous, uninitialized, outgoing, sources, pendingSource, flight, saved, released, stale, lanePass}:
      B.choose(~Machine, retire, _ => retireOutgoing(w, rest, stack, id, sources, True{}), _ => Machine{w, rest, stack})


# The shared LIVE tail: a first yield or empty completion is a real answer;
# no synchronous answer returns the seed or throws NotReady inside the pass.
def afterIterator(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +frame: PassFrame) -> Machine:
  match stack:
    case R.StreamVerdict{+stream, landed, value} <> +tail:
      +pair = F.liveValue(w, R.StreamState.node(B.stream(w, stream)), landed, value)
      +w = B.first(R.World, R.Value, pair)
      B.choose(~Machine, B.ok(w),
        _ => finishReady(w, rest, B.second(R.World, R.Value, pair) <> tail, frame, True{}),
        _ => catchPass(w, rest, frame))
    case _:
      Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

def finishHandleError(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, pending: Bool) -> Machine:
  +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  B.choose(~Machine, pending, _ => Machine{w, rest, stack},
    _ => pendingResume(rest, stack, Q.beginReleaseSettledDependents(w, id)))

def handleErrorNotify(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, error: R.Value, +pending: Bool, staged: Bool) -> Machine:
  +publishes = Bool.or(pending, Bool.not(staged))
  +w = B.choose(~R.World, publishes,
    _ => A.notifyStatusWith(w, id, B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), error), _ => w)
  +ending = B.choose(~List<&2, Task>, pending,
    _ => ErrorSettleSource{id} <> rest,
    _ => ErrorAfterPending{id, pending} <> rest)
  # async.ts:handleError retires the parked frame after publishing an actual
  # error (#4228). Stage-only errors and NotReady transfers retain it.
  Machine{w, B.choose(~List<&2, Task>, Bool.and(publishes, Bool.not(pending)),
    _ => OwnerTasks{[O.Enter{id, False{}, True{}}]} <> ending,
    _ => ending), stack}

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

def deferredAfterThen(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +cell: Nat, +observer: Nat) -> Machine:
  +o = B.asyncObserver(w, observer)
  B.choose(~Machine, R.AsyncObserver.rejected(o),
    _ =>
      +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
      handleError(w, DeferredRejected{R.AsyncObserver.syncError(o)} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), R.AsyncObserver.syncError(o)),
    _ => B.choose(~Machine, Bool.and(R.AsyncObserver.resolved(o), Nat.is_ne(iterable(w, R.AsyncObserver.syncValue(o)), 0n)),
      _ =>
        +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
        consumeIterator(w, DeferredAfterIterator{cell} <> rest, stack, R.AsyncObserver.node(o), R.AsyncObserver.result(o), iterable(w, R.AsyncObserver.syncValue(o)), False{}, R.Undefined{}),
      _ =>
        +pair = F.thenValue(w, observer)
        +w = B.first(R.World, R.Value, pair)
        B.choose(~Machine, B.ok(w), _ => Machine{w, deferredReturned(rest), Deferred.served(w, cell, B.second(R.World, R.Value, pair)) <> stack}, _ => Machine{w, rest, stack})))

# handleAsync's live iterator result returns to serve, then to the original
# Finish frame that detects this body already registered its own flight.
def deferredAfterIterator(+w: R.World, +rest: List<&2, Task>, stack: List<&2, R.Value>, +cell: Nat) -> Machine:
  match stack:
    case R.StreamVerdict{+stream, landed, value} <> +tail:
      +pair = F.liveValue(w, R.StreamState.node(B.stream(w, stream)), landed, value)
      +w = B.first(R.World, R.Value, pair)
      B.choose(~Machine, B.ok(w),
        _ => Machine{w, deferredReturned(rest), Deferred.served(w, cell, B.second(R.World, R.Value, pair)) <> tail},
        _ => Machine{w, rest, tail})
    case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}

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
  B.choose(~Machine, Bool.and(Nat.is_eq(EQ.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))),
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
        _ => B.choose(~Machine, Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), R.StreamState.result(s)), _ => Machine{w, rest, stack},
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
    _ => B.choose(~Machine, Nat.is_eq(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), R.StreamState.result(s)),
      _ =>
        +w = B.store_stream(w, stream, R.StreamState.with_completed(s, True{}))
        handleError(w, SettleAuto{id} <> rest, stack, id, R.StreamState.result(s), error),
      _ => Machine{w, rest, stack}))

def promiseFulfill(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  +o = B.asyncObserver(w, observer)
  +id = R.AsyncObserver.node(o)
  +source = iterable(w, value)
  B.choose(~Machine, R.AsyncObserver.isSync(o), _ => Machine{F.syncFulfilled(w, observer, value), rest, stack},
    _ => B.choose(~Machine, Bool.and(Nat.is_ne(source, 0n), Bool.and(Nat.is_eq(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), R.AsyncObserver.result(o)), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())))),
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

def asyncFulfillOrdinary(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  asyncActionDelivery(w, rest, stack, observer, False{}, value, Action.find(R.World.actionWaits(w), observer))

def asyncRejectOrdinary(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +value: R.Value) -> Machine:
  asyncActionDelivery(w, rest, stack, observer, True{}, value, Action.find(R.World.actionWaits(w), observer))

def deferredDelivery(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +rejected: Bool, +value: R.Value, found: Maybe<&2, R.DeferredWait>) -> Machine:
  match found:
    case Some{wait}: Machine{Deferred.deliver(w, wait), rest, stack}
    case None{}:
      B.choose(~Machine, rejected, _ => asyncRejectOrdinary(w, rest, stack, observer, value), _ => asyncFulfillOrdinary(w, rest, stack, observer, value))

def fromWrapDelivery(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +observer: Nat, +rejected: Bool, +value: R.Value) -> Machine:
  +found = WrappedFrom.find(w, observer)
  +plan = B.first(Nat, Nat, found)
  +output = B.second(Nat, Nat, found)
  B.choose(~Machine, Nat.is_ne(output, 0n),
    _ => Machine{WrappedFrom.deliver(w, plan, output, rejected, value), rest, stack},
    _ => deferredDelivery(w, rest, stack, observer, rejected, value, Deferred.wait(w, observer)))

def asyncFulfill(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +observer: Nat, value: R.Value) -> Machine:
  fromWrapDelivery(w, rest, stack, observer, False{}, value)

def asyncReject(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +observer: Nat, value: R.Value) -> Machine:
  fromWrapDelivery(w, rest, stack, observer, True{}, value)

# effect.ts:runEffect's catch constructs a fresh wrapper and rethrows raw.
def effectCatch(+w: R.World, +id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{+cause}:
      +pair = A.statusError(w, id, cause)
      +w = E.ext(B.first(R.World, R.Value, pair), id)
      +w = B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), B.second(R.World, R.Value, pair)))
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(R.Node.status(B.node(w, id)), K.STATUS_ERROR())))
      A.escalate(w, id, cause, cause)
    case other:
      w

# Error-arm throws escalate without replacing the compute's status error.
def errorArmCatch(+w: R.World, id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{+cause}:
      A.escalate(w, id, cause, cause)
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
    case R.ReleaseQueues{transaction}:
      ReleaseTransactionQueues{transaction}

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

# core.ts:laneFrameMember, nearest non-zombie owner. Fuel refuses malformed
# owner cycles; the admitted owner arena is finite and acyclic.
def laneFrameMemberLoop(fuel: Nat, +w: R.World, +owner: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p:
      +n = B.node(w, owner)
      B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE()),
        _ => laneFrameMemberLoop(p, w, R.Node.parent(n)),
        _ => B.Bundle{w, Bool.or(U32.is_eq(U32.and(R.Node.config(n), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())), K.CONFIG_OVERRIDE()), Bool.and(B.effect(R.Node.kind(n)), R.Transaction.lane(B.transaction(w, R.NodeExtension.transaction(B.extension(w, owner))))))})

def laneFrameMember(+w: R.World, id: Nat) -> B.Bundle<R.World, Bool>:
  laneFrameMemberLoop(1n+B.length(R.Node, R.World.nodes(w)), w, R.Node.parent(B.node(w, id)))

# core.ts:GlobalQueue._update. Tracked effects visit the heap before the seam
# and enqueue their _run in the user phase; their body executes only afterward.
def visitHeapInto(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +next: Task) -> Machine:
  B.choose(~Machine, B.tracked(R.Node.kind(B.node(w, id))),
    _ =>
      +w = H.deleteFromHeap(w, id)
      +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))
      Machine{S.enqueue(w, id), next <> rest, stack},
    _ => B.choose(~Machine, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), Bool.not(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_LANE_DIRTY()))),
      _ => Machine{S.deferZombie(w, id), next <> rest, stack},
      _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()),
        _ =>
          +pair = laneFrameMember(w, id)
          +w = B.first(R.World, Bool, pair)
          B.choose(~Machine, B.second(R.World, Bool, pair),
            _ =>
              +w = H.deleteFromHeap(w, id)
              +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), U32.or(K.REACTIVE_DIRTY(), U32.or(K.REACTIVE_CHECK(), K.REACTIVE_LANE_DIRTY())))))
              Machine{w, next <> rest, stack},
            _ => Machine{w, Recompute{id, False{}} <> next <> rest, stack}),
        _ => Machine{w, Recompute{id, False{}} <> next <> rest, stack})))

def visitHeap(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, id: Nat) -> Machine:
  visitHeapInto(w, rest, stack, id, HeapLoop{})

def heapLoopMode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +corrections: Bool) -> Machine:
  B.choose(~Machine, Nat.is_gt(R.World.minimum(w), R.World.maximum(w)),
    _ => Machine{R.World.with_maximum(w, 0n), B.choose(~Task, corrections, _ => SettleJoined{}, _ => Seam{}) <> rest, stack},
    _ =>
      +id = B.bucket(w, R.World.minimum(w))
      B.choose(~Machine, Nat.is_eq(id, 0n),
        _ => Machine{R.World.with_minimum(w, 1n+R.World.minimum(w)), B.choose(~Task, corrections, _ => HeapCorrections{}, _ => HeapLoop{}) <> rest, stack},
        _ => B.choose(~Machine, B.has(R.Node.flags(B.node(w, id)), 8),
          _ => visitHeapInto(w, rest, stack, id, B.choose(~Task, corrections, _ => HeapCorrections{}, _ => HeapLoop{})),
          _ => Machine{H.adjustHeight(w, id), B.choose(~Task, corrections, _ => HeapCorrections{}, _ => HeapLoop{}) <> rest, stack})))

def heapLoop(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  heapLoopMode(w, rest, stack, False{})

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

def laneCorrections(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  Machine{w, LaneCorrections{R.LaneState.live(R.World.laneState(w)), False{}} <> rest, stack}

def applyGuessesAt(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat) -> Machine:
  +w = R.World.with_laneState(w, R.LaneState.with_judged(R.World.laneState(w), B.length(Nat, R.LaneState.live(R.World.laneState(w)))))
  B.choose(~Machine, List.is_empty(&2, R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w))), _ => Machine{w, rest, stack}, _ => Machine{w, ApplyGuesses{parent, 0n, 0n} <> rest, stack})

# lanes.ts:laneSeams. The source captures leaks but walks the current live lane
# array backwards, bounded by the prefix recorded before applying new guesses.
def laneSeams(w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, leaks: R.OptionalIds) -> Machine:
  match leaks:
    case R.NoIds{}:
      Machine{w, LaneLeakLoop{[], 0n, []} <> rest, stack}
    case R.SomeIds{readers}:
      Machine{w, LaneLeakLoop{readers, 0n, []} <> rest, stack}

# After the lane hook, capture its runs separately, clear its intake, then
# install fresh landing queues. Source own -> lanes -> landings remain distinct.
def afterLaneSeams(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +t: Nat, renders: List<&2, Nat>, users: List<&2, R.QueueEntry>) -> Machine:
  +state = R.World.laneState(w)
  +w = B.choose(~R.World, List.is_empty(&2, Nat, R.LaneState.stagedReaders(state)), _ => w,
    _ => R.World.with_laneState(w, R.LaneState.with_stagedReaders(state, [])))
  +frame = {SeamFrame{t, renders, users, R.World.renderQueue(w), R.World.userQueue(w)} : SeamFrame}
  +w = R.World.with_renderQueue(R.World.with_userQueue(w, []), [])
  Machine{w, LandTransactions{frame, B.length(Nat, R.World.transactions(w))} <> rest, stack}

def finishSettleIntake(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +t: Nat) -> Machine:
  +w = S.clearTrims(w)
  +renders = R.World.renderQueue(w)
  +users = R.World.userQueue(w)
  +w = R.World.with_renderQueue(R.World.with_userQueue(w, []), [])
  # Fused empty hook: no callbacks/reveals or retained reader array exist.
  B.choose(~Machine, Bool.and(List.is_empty(&2, Nat, R.LaneState.live(R.World.laneState(w))), Bool.and(List.is_empty(&2, Nat, R.LaneState.stagedReaders(R.World.laneState(w))), List.is_empty(&2, Nat, R.LaneState.entered(R.World.laneState(w))))),
    _ => afterLaneSeams(w, rest, stack, t, renders, users),
    _ => laneSeams(w, AfterLaneSeams{t, renders, users} <> rest, stack, B.choose(~R.OptionalIds, Nat.is_ne(t, 0n), _ => R.SomeIds{R.LaneState.stagedReaders(R.World.laneState(w))}, _ => R.NoIds{})))

# The park takes this captured zombie array before lane reveals. Newly deferred
# zombies during its reruns remain in World for the final survivor pass.
def afterParkIntake(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +t: Nat) -> Machine:
  +zombies = S.sortHeights(w, R.World.deferredZombies(w))
  +w = R.World.with_deferredZombies(w, [])
  B.choose(~Machine, List.is_empty(&2, Nat, zombies),
    _ => finishSettleIntake(w, rest, stack, t),
    _ => Machine{w, ParkVerdictZombies{t, zombies} <> rest, stack})

def parkVerdictZombies(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +t: Nat, nodes: List<&2, Nat>) -> Machine:
  match nodes:
    case Nil{}:
      finishSettleIntake(w, rest, stack, t)
    case +id <> +tail:
      +eligible = Bool.and(U32.is_eq(U32.and(R.Node.flags(B.node(w, id)), U32.or(K.REACTIVE_DISPOSED(), K.REACTIVE_ZOMBIE())), K.REACTIVE_ZOMBIE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT()))
      Machine{w, B.choose(~List<&2, Task>, eligible,
        _ => Recompute{id, False{}} <> ParkVerdictZombies{t, tail} <> rest,
        _ => ParkVerdictZombies{t, tail} <> rest), stack}

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

def settleApplied(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +joined: Nat) -> Machine:
  +pair = B.choose(~B.Bundle<R.World, Nat>, Bool.and(Nat.is_ne(joined, 0n), Bool.not(R.Transaction.lane(B.transaction(w, joined)))),
    _ => X.resolveTx(w, joined), _ => B.Bundle{w, 0n})
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  B.choose(~Machine, Nat.is_ne(t, 0n),
    _ =>
      B.choose(~Machine, List.is_empty(&2, R.ComparatorBinding, R.World.comparators(w)),
        _ =>
          +w = S.parkPendingNodes(w, t)
          B.choose(~Machine, B.ok(w), _ => afterParkIntake(w, rest, stack, t), _ => Machine{w, rest, stack}),
        _ => Machine{w, ParkIntake{t, 0n, B.length(Nat, R.World.pendingNodes(w))} <> AfterPark{t} <> rest, stack}),
    _ => Machine{w, CommitIntake{0n} <> TrimIntake{0n} <> FinishSettleIntake{t} <> rest, stack})

# Empty hook continuations fuse into the ordinary return point. They call the
# same applyGuessesAt body once and retain the established plain-path budgets.
def settleJoined(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +joined = R.World.flushTransaction(w)
  +w = R.World.with_flushTransaction(w, 0n)
  B.choose(~Machine, List.is_empty(&2, R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w))),
    _ =>
      +m = applyGuessesAt(w, [], [], joined)
      settleApplied(world(m), rest, stack, joined),
    _ => applyGuessesAt(w, SettleApplied{joined} <> rest, stack, joined))

def beginSettle(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  B.choose(~Machine, List.is_empty(&2, Nat, R.LaneState.live(R.World.laneState(w))),
    _ => settleJoined(w, rest, stack),
    _ => laneCorrections(w, SettleCorrectionsDone{} <> rest, stack))

def landPrepared(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: SeamFrame, +t: Nat) -> Machine:
  +pair = S.reruns(w, t)
  +w = B.first(R.World, Nat, pair)
  +rerunFrame = B.second(R.World, Nat, pair)
  +w = B.choose(~R.World, B.ok(w), _ => MarkScope.releaseTransaction(w, t), _ => w)
  Machine{w, LandNodes{frame, t, 0n, rerunFrame} <> rest, stack}

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
          B.choose(~Machine, List.is_empty(&2, Nat, R.LaneState.live(R.World.laneState(w))),
            _ => landPrepared(w, rest, stack, frame, t),
            _ => Machine{w, EndLanes{t} <> LandAfterLanes{frame, t} <> rest, stack}))

def landNodes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +frame: SeamFrame, +t: Nat, +index: Nat, +rerunFrame: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, t)))),
    _ => Machine{w, LandEnd{frame, t, rerunFrame} <> rest, stack},
    _ =>
      +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, t)), index, 0n)
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(R.NodeExtension.transaction(B.extension(w, id)), 0n),
        _ =>
          +pair = X.txOf(w, id)
          B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), t)},
        _ => B.Bundle{w, False{}})
      +w = B.first(R.World, Bool, pair)
      +ending = {LandNodes{frame, t, 1n+index, rerunFrame} <> rest : List<&2, Task>}
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => Machine{B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n)), CommitPending{id} <> ending, stack},
        _ => Machine{w, ending, stack}))

def landEnd(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: SeamFrame, +t: Nat, +rerunFrame: Nat) -> Machine:
  +w = B.choose(~R.World, Nat.is_eq(R.World.flushTransaction(w), t), _ => R.World.with_flushTransaction(w, 0n), _ => w)
  +w = B.choose(~R.World, Nat.is_ne(rerunFrame, 0n),
    _ => R.World.with_userQueue(w, B.append(R.QueueEntry, R.World.userQueue(w), [R.ReleaseQueues{t}])),
    _ => S.releaseQueues(w, t))
  Machine{w, LandTransactions{frame, B.length(Nat, R.World.transactions(w))} <> rest, stack}

def orderedRuns(~A: Data, +parked: Bool, +own: List<&2, A>, +lanes: List<&2, A>, +landing: List<&2, A>) -> List<&2, A>:
  B.choose(~List<&2, A>, Bool.or(parked, Bool.or(Bool.not(List.is_empty(&2, A, lanes)), Bool.not(List.is_empty(&2, A, landing)))),
    _ => B.append(A, lanes, B.choose(~List<&2, A>, parked, _ => landing, _ => B.append(A, own, landing))), _ => own)

def completeSettle(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, frame: SeamFrame) -> Machine:
  match frame:
    case SeamFrame{+t, +renders, +users, laneRenders, laneUsers}:
      +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(t, 0n), _ => X.liveTx(w, t), _ => B.Bundle{w, 0n})
      +w = B.first(R.World, Nat, pair)
      +live = B.second(R.World, Nat, pair)
      +parked = Nat.is_ne(live, 0n)
      +w = MarkScope.releaseAmbient(w, live)
      +w = B.choose(~R.World, parked,
        _ =>
          +w = B.store_transaction(w, live, R.Transaction.with_renderQueue(B.transaction(w, live), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, live)), renders)))
          B.store_transaction(w, live, R.Transaction.with_userQueue(B.transaction(w, live), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, live)), users))), _ => w)
      +w = R.World.with_renderQueue(w, orderedRuns(~Nat, parked, renders, laneRenders, R.World.renderQueue(w)))
      +w = R.World.with_userQueue(w, orderedRuns(~R.QueueEntry, parked, users, laneUsers, R.World.userQueue(w)))
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
    case O.Action{+callback, R.CleanupCloseIterator{+stream}} <> +tail:
      B.choose(~Machine, fromIterator(w, R.StreamState.iterator(B.stream(w, stream))),
        _ => closeStream(w, OwnerTasks{tail} <> rest, stack, stream),
        _ => ownerResume(rest, stack, O.dispatch(w, O.Action{callback, R.CleanupCloseIterator{stream}} <> tail)))
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
  Machine{w, rest, stack}


def supersedeAfter(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lane: Nat, +parent: Nat, +value: R.Value) -> Machine:
  +w = B.choose(~R.World, Bool.and(R.LaneState.guessed(R.World.laneState(w)), R.LaneState.reverting(R.World.laneState(w))), _ => Lanes.markReverted(w, lane), _ => w)
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
        _ => H.enqueueSub(B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{})), id), _ => w))
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
      Machine{B.first(R.World, Nat, S.reruns(w, lane)), LaneSeamNodes{lane, 0n} <> rest, stack})


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
  B.choose(~Machine, R.LaneState.guessed(R.World.laneState(w)),
    _ => Machine{w, EndKept{parent, B.length(R.KeptGuess, R.LaneState.kept(R.World.laneState(w)))} <> rest, stack},
    _ => Machine{w, EndLanesLoop{parent, B.length(Nat, R.LaneState.live(R.World.laneState(w)))} <> rest, stack})


# lanes.ts:endLanes scans the captured reverse prefix of the live kept stack.
# Splice happens before restoration, so cleanup callbacks observe its removal.
def removeKept(items: List<&2, R.KeptGuess>, index: Nat) -> List<&2, R.KeptGuess>:
  match items index:
    case Nil{} _: []
    case head <> tail 0n: tail
    case head <> tail 1n+left: head <> removeKept(tail, left)

def restoreKept(+w: R.World, rest: List<&2, Task>, stack: List<&2, R.Value>, +parent: Nat, +entry: R.KeptGuess) -> Machine:
  +id = R.KeptGuess.node(entry)
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.KeptGuess.value(entry)))
  +w = B.store_extension(w, id, R.NodeExtension.with_q(B.extension(w, id), R.KeptGuess.question(entry)))
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS()))))
  +w = X.list(w, id, R.KeptGuess.transaction(entry))
  Machine{Lanes.rerun(w, id, parent), rest, stack}

def endKeptNode(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +entry: R.KeptGuess) -> Machine:
  +id = R.KeptGuess.node(entry)
  # _slotTake can replace the node; refuse that unported store crossing.
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()),
    _ => Machine{R.World.with_fault(w, R.Unsupported{86n}), rest, stack},
    _ =>
      +w = E.ext(w, id)
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), 0n), _ => B.Bundle{w, True{}},
        _ =>
          +pair = X.txOf(w, id)
          B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), parent)})
      +w = B.first(R.World, Bool, pair)
      B.choose(~Machine, B.second(R.World, Bool, pair),
        _ => Machine{w, CommitPending{id} <> RestoreKept{parent, entry} <> rest, stack},
        _ => Machine{w, rest, stack}))

def endKept(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, remaining: Nat) -> Machine:
  match remaining:
    case 0n:
      Machine{w, EndLanesLoop{parent, B.length(Nat, R.LaneState.live(R.World.laneState(w)))} <> rest, stack}
    case 1n+ +index:
      +entry = B.get(R.KeptGuess, R.LaneState.kept(R.World.laneState(w)), index, R.KeptGuess{0n, R.Empty{}, 0n, R.QuestionZero{}, 0n})
      +pair = X.resolveTx(w, R.Transaction.parent(B.transaction(w, R.KeptGuess.holder(entry))))
      +w = B.first(R.World, Nat, pair)
      +ending = {EndKept{parent, index} <> rest : List<&2, Task>}
      B.choose(~Machine, Nat.is_ne(B.second(R.World, Nat, pair), parent), _ => Machine{w, ending, stack},
        _ =>
          +w = R.World.with_laneState(w, R.LaneState.with_kept(R.World.laneState(w), removeKept(R.LaneState.kept(R.World.laneState(w)), index)))
          B.choose(~Machine, Bool.and(B.contains(R.LaneState.reverted(R.World.laneState(w)), R.KeptGuess.holder(entry)), B.contains(R.LaneState.live(R.World.laneState(w)), R.KeptGuess.transaction(entry))),
            _ => endKeptNode(w, ending, stack, parent, entry), _ => Machine{w, ending, stack}))

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

# lanes.ts:laneWrite and laneOutcome. Folded store rebase remains excluded.
def laneWriteChanged(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +lane: Nat, +value: R.Value) -> Machine:
  +w = B.choose(~R.World, R.Transaction.shown(B.transaction(w, lane)), _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})), _ => B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{value})))
  +w = B.choose(~R.World, B.computed(R.Node.kind(B.node(w, id))), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  +w = S.insertSubs(w, id)
  +w = Lanes.laneDirty(w, id, lane)
  Machine{B.schedule(w), rest, value <> stack}

def laneWrite(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value) -> Machine:
  # The optional _slotTake hook is a no-op for admitted non-store nodes.
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()),
    _ => B.choose(~Machine, Lanes.stale(w, id, R.World.question(w)),
      _ =>
        +w = B.store_node(w, id, R.Node.with_pending(R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_HELD())), R.Present{value}))
        Machine{B.schedule(w), rest, value <> stack},
      _ => rawEquals(w, LaneWriteCompared{id, 0n, value, True{}} <> rest, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), value)),
    _ =>
      +pair = X.txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      +lane = B.second(R.World, Nat, pair)
      rawEquals(w, LaneWriteCompared{id, lane, value, False{}} <> rest, stack, id, Truth.laneValueOf(w, id), value))

def laneOutcome(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value, errored: Bool) -> Machine:
  B.choose(~Machine, errored, _ => Machine{w, rest, R.Boolean{True{}} <> stack},
    _ =>
      +pair = Lanes.answered(w, id)
      +w = B.first(R.World, R.Question, pair)
      B.choose(~Machine, Lanes.stale(w, id, B.second(R.World, R.Question, pair)),
        _ =>
          +w = B.store_node(w, id, R.Node.with_pending(R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_HELD())), R.Present{value}))
          Machine{w, rest, R.Boolean{True{}} <> stack},
        _ => rawEquals(w, LaneOutcomeCompared{id, value} <> rest, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), value)))

# lanes.ts:laneCorrections takes exactly the source lanes.slice snapshot.
# Its member loop remains live and stops once a correction removes the lane.

def laneCorrectionsLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, live: List<&2, Nat>, +judged: Bool) -> Machine:
  match live:
    case Nil{}:
      Machine{w, rest, R.Boolean{judged} <> stack}
    case +lane <> +tail:
      +ending = {LaneCorrections{tail, judged} <> rest : List<&2, Task>}
      B.choose(~Machine, Bool.not(B.contains(R.LaneState.live(R.World.laneState(w)), lane)), _ => Machine{w, ending, stack},
        _ =>
          +pair = X.resolveTx(w, R.Transaction.parent(B.transaction(w, lane)))
          +w = B.first(R.World, Nat, pair)
          +parent = B.second(R.World, Nat, pair)
          +p = B.transaction(w, parent)
          B.choose(~Machine, Bool.or(Bool.not(R.Transaction.acted(p)), Bool.or(Nat.is_ne(R.Transaction.open(p), 0n), R.Transaction.lane(p))), _ => Machine{w, ending, stack},
            _ =>
              +pair = X.ownFlights(w, parent)
              +w = B.first(R.World, Bool, pair)
              B.choose(~Machine, B.second(R.World, Bool, pair), _ => Machine{w, ending, stack},
                _ =>
                  +pair = X.guessFlights(w, lane)
                  +w = B.first(R.World, Bool, pair)
                  B.choose(~Machine, B.second(R.World, Bool, pair), _ => Machine{w, ending, stack},
                    _ => Machine{w, LaneCorrectionNodes{lane, 0n} <> LaneCorrections{tail, True{}} <> rest, stack}))))

def laneCorrectionNodes(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +lane: Nat, +index: Nat) -> Machine:
  B.choose(~Machine, Bool.or(Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), Bool.not(B.contains(R.LaneState.live(R.World.laneState(w)), lane))), _ => Machine{w, rest, stack},
    _ =>
      +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, lane)), index, 0n)
      +ending = {LaneCorrectionNodes{lane, 1n+index} <> rest : List<&2, Task>}
      B.choose(~Machine, Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), lane)),
        _ =>
          +truth = B.selected(R.Node.pending(B.node(w, id)), R.Node.value(B.node(w, id)))
          +w = B.choose(~R.World, R.LaneState.guessed(R.World.laneState(w)),
            _ => R.World.with_laneState(w, R.LaneState.with_reverting(R.World.laneState(w), Bool.not(B.present(R.Node.pending(B.node(w, id)))))), _ => w)
          rawEquals(w, LaneCorrectionCompared{id, truth} <> LaneCorrectionEnd{} <> ending, stack, id, B.selected(R.NodeExtension.lane(B.extension(w, id)), R.NotPendingToken{}), truth),
        _ => Machine{w, ending, stack}))

# lanes.ts:optimisticWrite, preserving updater before raw comparison and
# GUESS re-ask classification after the comparator's user callback returns.
def optimisticResolved(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +previous: R.Value, +value: R.Value) -> Machine:
  rawEquals(w, OptimisticCompared{id, value} <> rest, stack, id, previous, value)

def optimisticWrite(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +id: Nat, +value: R.Value) -> Machine:
  +previous = Lanes.guessedValueOf(w, id)
  B.choose(~Machine, J.isFunction(value),
    _ => Machine{w, Evaluate{R.InvokeWith{R.Literal{value}, R.Literal{previous}, False{}}, R.Undefined{}} <> OptimisticResolved{id, previous} <> rest, stack},
    _ => optimisticResolved(w, rest, stack, id, previous, value))

# lanes.ts:applyGuesses. parent and lane are the source mutable locals. The
# per-node question is reread from the live triple array after user comparison.
def applyGuessEnd(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat, +id: Nat, +holder: Nat, +changed: Bool) -> Machine:
  +w = B.choose(~R.World, Bool.and(Nat.is_ne(parent, 0n), Nat.is_ne(holder, 0n)), _ => X.merge(w, parent, holder), _ => w)
  +guess = B.get(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w)), index, R.Guess{0n, R.Undefined{}, R.QuestionZero{}})
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_q(B.extension(w, id), R.Guess.question(guess)))
  +w = B.choose(~R.World, changed,
    _ =>
      +w = S.insertSubs(w, id)
      +pair = X.txOf(w, id)
      Lanes.laneDirty(B.first(R.World, Nat, pair), id, B.second(R.World, Nat, pair)), _ => w)
  Machine{w, ApplyGuesses{parent, lane, 1n+index} <> rest, stack}

def applyGuessOverride(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat, +id: Nat, +value: R.Value, +changed: Bool) -> Machine:
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), _ => w,
    _ => B.store_node(w, id, R.Node.with_config(R.Node.with_pending(B.node(w, id), R.Empty{}), B.set(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()))))
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{value}))
  +pair = X.txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +holder = R.Transaction.parent(B.transaction(w, B.second(R.World, Nat, pair)))
  applyGuessEnd(w, rest, stack, parent, lane, index, id, holder, changed)

def applyGuessBorn(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat, +id: Nat, +value: R.Value, +l: Nat, +holder: Nat) -> Machine:
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_lane(B.extension(w, id), R.Present{value}))
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS()))))
  applyGuessEnd(X.list(w, id, l), rest, stack, parent, lane, index, id, holder, True{})

def applyGuessFree(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat, +id: Nat, +value: R.Value) -> Machine:
  +flight = B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(parent, 0n), _ => Lanes.inFlight(w, id), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, flight)
  +pair = B.choose(~B.Bundle<R.World, Nat>, B.second(R.World, Bool, flight), _ => X.newTransaction(w, False{}, 0n), _ => B.Bundle{w, parent})
  +w = B.first(R.World, Nat, pair)
  +parent = B.second(R.World, Nat, pair)
  B.choose(~Machine, Nat.is_eq(parent, 0n), _ => Machine{w, ApplyGuesses{parent, lane, 1n+index} <> rest, stack},
    _ =>
      +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_ne(lane, 0n), _ => B.Bundle{w, lane}, _ => Lanes.newLane(w, parent))
      +w = B.first(R.World, Nat, pair)
      +lane = B.second(R.World, Nat, pair)
      applyGuessBorn(w, rest, stack, parent, lane, index, id, value, lane, 0n))

def applyGuessNew(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat, +id: Nat, +value: R.Value) -> Machine:
  B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
    _ =>
      +pair = X.txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      +holder = B.second(R.World, Nat, pair)
      +pair = Lanes.newLane(w, holder)
      applyGuessBorn(B.first(R.World, Nat, pair), rest, stack, parent, lane, index, id, value, B.second(R.World, Nat, pair), holder),
    _ => applyGuessFree(w, rest, stack, parent, lane, index, id, value))

def applyGuesses(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +parent: Nat, +lane: Nat, +index: Nat) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w)))),
    _ => Machine{R.World.with_laneState(w, R.LaneState.with_pendingGuesses(R.World.laneState(w), [])), rest, stack},
    _ =>
      +guess = B.get(R.Guess, R.LaneState.pendingGuesses(R.World.laneState(w)), index, R.Guess{0n, R.Undefined{}, R.QuestionZero{}})
      +id = R.Guess.node(guess)
      +value = R.Guess.value(guess)
      B.choose(~Machine, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()),
        _ => rawEquals(w, ApplyGuessCompared{parent, lane, index, id, value} <> rest, stack, id, Truth.laneValueOf(w, id), value),
        _ => applyGuessNew(w, rest, stack, parent, lane, index, id, value)))


# lanes.ts:laneSeams's final live entered.pop() loop. Pop/store precedes the
# held check, lane-dirty clearing and enqueue. An empty array adds no task.
def laneEnteredPop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +readers: List<&2, Nat>, remaining: Nat) -> Machine:
  match remaining:
    case 0n: Machine{w, rest, stack}
    case 1n+ +index:
      +reader = B.get(Nat, readers, index, 0n)
      +w = R.World.with_laneState(w, R.LaneState.with_entered(R.World.laneState(w), Lanes.enteredPrefix(index, readers)))
      B.choose(~Machine, Nat.is_eq(reader, 0n), _ => Machine{w, rest, stack},
        _ =>
          +w = B.choose(~R.World, R.Transaction.held(B.transaction(w, R.NodeExtension.transaction(B.extension(w, reader)))),
            _ =>
              +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.clear(R.Node.flags(B.node(w, reader)), K.REACTIVE_LANE_DIRTY())))
              H.enqueueSub(w, reader), _ => w)
          Machine{w, LaneEnteredLoop{} <> rest, stack})

def laneEnteredLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>) -> Machine:
  +readers = R.LaneState.entered(R.World.laneState(w))
  laneEnteredPop(w, rest, stack, readers, B.length(Nat, readers))

def laneRevealLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +leaked: List<&2, Nat>, remaining: Nat) -> Machine:
  match remaining:
    case 0n:
      laneEnteredLoop(w, rest, stack)
    case 1n+ +index:
      +lane = B.get(Nat, R.LaneState.live(R.World.laneState(w)), index, 0n)
      laneSeam(w, LaneRevealLoop{leaked, index} <> rest, stack, lane, B.contains(leaked, lane))

def laneLeakAdmit(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +readers: List<&2, Nat>, +index: Nat, +leaked: List<&2, Nat>, +reader: Nat, +lane: Nat) -> Machine:
  +isLane = Bool.and(Nat.is_ne(lane, 0n), R.Transaction.lane(B.transaction(w, lane)))
  +w = B.choose(~R.World, Bool.and(isLane, B.effect(R.Node.kind(B.node(w, reader)))),
    _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_LANE_DIRTY()))), _ => w)
  +w = H.enqueueSub(w, reader)
  +leaked = B.choose(~List<&2, Nat>, Bool.and(isLane, Bool.not(B.contains(leaked, lane))), _ => B.append(Nat, leaked, [lane]), _ => leaked)
  Machine{w, LaneLeakLoop{readers, 1n+index, leaked} <> rest, stack}

def laneLeakLoop(+w: R.World, +rest: List<&2, Task>, +stack: List<&2, R.Value>, +readers: List<&2, Nat>, +index: Nat, +leaked: List<&2, Nat>) -> Machine:
  B.choose(~Machine, Nat.is_ge(index, B.length(Nat, readers)),
    _ => Machine{w, LaneRevealLoop{leaked, Nat.min(R.LaneState.judged(R.World.laneState(w)), B.length(Nat, R.LaneState.live(R.World.laneState(w))))} <> rest, stack},
    _ =>
      +reader = B.get(Nat, readers, index, 0n)
      +ending = {LaneLeakLoop{readers, 1n+index, leaked} <> rest : List<&2, Task>}
      B.choose(~Machine, B.has(R.Node.flags(B.node(w, reader)), K.REACTIVE_DISPOSED()), _ => Machine{w, ending, stack},
        _ =>
          +lane = R.NodeExtension.transaction(B.extension(w, reader))
          +parent = R.Transaction.parent(B.transaction(w, lane))
          +isLane = R.Transaction.lane(B.transaction(w, lane))
          +ordinarySkip = Bool.and(Nat.is_ne(lane, 0n), Bool.and(Bool.not(isLane), Bool.not(B.has(R.Node.flags(B.node(w, reader)), U32.or(K.REACTIVE_STAGED_READ(), K.REACTIVE_PROBE_UNANSWERED())))))
          +verdict = Bool.and(isLane, Bool.and(Nat.is_ne(parent, 0n), Nat.is_eq(R.Transaction.verdict(B.transaction(w, parent)), lane)))
          B.choose(~Machine, ordinarySkip, _ => Machine{w, ending, stack}, _ => B.choose(~Machine, verdict,
            _ => B.choose(~Machine, B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT()),
              _ => B.choose(~Machine, Bool.not(B.has(R.Node.flags(B.node(w, reader)), K.REACTIVE_PROBE_UNANSWERED())), _ => Machine{w, ending, stack}, _ => laneLeakAdmit(w, rest, stack, readers, index, leaked, reader, lane)),
              _ =>
                +pair = X.blocked(w, parent)
                +w = B.first(R.World, Bool, pair)
                B.choose(~Machine, Bool.not(B.second(R.World, Bool, pair)), _ => Machine{w, ending, stack}, _ => laneLeakAdmit(w, rest, stack, readers, index, leaked, reader, lane))),
            _ => laneLeakAdmit(w, rest, stack, readers, index, leaked, reader, lane)))))


# isPending's catch observes the live found flag before restoring its caller.
# Internal refusal faults remain adapter failures rather than user exceptions.
def probeAfterFault(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +answer: Bool, +owned: Bool, +fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{cause}:
      B.choose(~Machine, Bool.and(P.isNotReady(cause), Bool.and(Bool.not(answer), owned)),
        _ => Machine{w, rest, saved},
        _ => Machine{R.World.with_fault(w, R.Healthy{}), rest, R.Boolean{answer} <> saved})
    case _:
      Machine{w, rest, saved}

def probeThrown(+w: R.World, +rest: List<&2, Task>, +saved: List<&2, R.Value>, +probing: Bool, +found: Bool, +dispatch: Bool, +fault: R.Fault) -> Machine:
  +answer = R.VerdictState.probeFound(R.World.verdictState(w))
  +owned = Nat.is_ne(R.World.context(w), 0n)
  +w = Verdict.restoreProbe(w, probing, found, dispatch)
  probeAfterFault(w, rest, saved, answer, owned, fault)

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
        case R.NegativeZero{} <> R.ArrayReference{id} <> tail:
          Machine{w, rest, Arrays.at(w, id, 0n) <> tail}
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
    # Source field/call boundaries remain in one run and callback scope.
    # No host job is delivered between these constructor/wrapper segments.
    case DeferredCreate{cell, compute, options, read} <> rest:
      deferredCreate(w, rest, stack, cell, compute, options, read)
    case DeferredConfigure{+cell, compute, previous} <> rest:
      +node = R.DeferredCell.node(Deferred.cell(w, cell))
      +w = B.store_node(w, node, R.Node.with_config(B.node(w, node), B.set(R.Node.config(B.node(w, node)), K.CONFIG_REDERIVE())))
      Machine{w, DeferredCleanup{cell, compute, previous} <> rest, stack}
    case DeferredCleanup{+cell, compute, previous} <> rest:
      +node = R.DeferredCell.node(Deferred.cell(w, cell))
      Machine{O.cleanup(w, node, R.DeferredBinding.cleanup(Deferred.binding(w, cell))), DeferredOpen{cell, compute, previous} <> rest, stack}
    case DeferredOpen{+cell, compute, previous} <> +rest:
      +w = Deferred.openWindow(w, cell)
      Machine{w, Evaluate{compute, previous} <> DeferredResult{cell, R.DeferredCell.answered(Deferred.cell(w, cell)), stack} <> rest, stack}
    case DeferredResult{+cell, +open, saved} <> rest:
      deferredResult(w, DeferredCatch{cell, open, saved} <> rest, stack, cell, open)
    case DeferredCatch{cell, open, saved} <> rest:
      Machine{w, rest, stack}
    case DeferredObserve{+cell, +result} <> rest:
      +pair = F.newObserver(w, 0n, result)
      +w = B.first(R.World, Nat, pair)
      +observer = B.second(R.World, Nat, pair)
      +w = Deferred.registerWait(w, observer, cell, R.AsyncValue{result})
      +w = F.addObserver(w, result, observer)
      deferredObserveState(w, rest, stack, cell, result, observer, R.AsyncObject.immediate(B.asyncObject(w, result)), R.AsyncObject.state(B.asyncObject(w, result)))
    case DeferredRegisterFlight{cell, +node, +result} <> rest:
      Machine{F.recordFlight(w, node, result), DeferredRegisterQuestion{cell, node, result} <> rest, stack}
    case DeferredRegisterQuestion{cell, +node, result} <> rest:
      Machine{F.recordQuestion(w, node), DeferredRegisterSources{cell, node, result} <> rest, stack}
    case DeferredRegisterSources{cell, +node, result} <> rest:
      Machine{P.clearPendingSources(w, node), DeferredRegisterObserver{cell, node, result} <> rest, stack}
    case DeferredRegisterObserver{cell, node, +result} <> rest:
      +pair = F.newObserver(w, node, result)
      Machine{B.first(R.World, Nat, pair), DeferredSubscribeThen{cell, result, B.second(R.World, Nat, pair)} <> rest, stack}
    case DeferredSubscribeThen{cell, +result, +observer} <> rest:
      +w = F.addObserver(w, result, observer)
      deferredSubscribeState(w, rest, stack, cell, observer, R.AsyncObject.immediate(B.asyncObject(w, result)), R.AsyncObject.state(B.asyncObject(w, result)))
    case DeferredAfterThen{cell, observer} <> rest:
      deferredAfterThen(w, rest, stack, cell, observer)
    case DeferredAfterIterator{cell} <> rest:
      deferredAfterIterator(w, rest, stack, cell)
    case DeferredStreamCall{cell, source} <> rest:
      deferredStream(w, rest, stack, cell, source)
    case FromInput{} <> rest:
      fromInput(w, rest, stack)
    case FromOpen{source} <> rest:
      fromOpen(w, rest, stack, source)
    case FromWrapOpened{} <> rest:
      match stack:
        case R.IteratorReference{inner} <> tail:
          +pair = WrappedFrom.allocate(w, inner)
          fromBind(B.first(R.World, Nat, pair), rest, tail, B.second(R.World, Nat, pair))
        case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FromWrapFinishFinally{saved} <> rest:
      match stack:
        case value <> tail: Machine{ignoredReturn(w, value), rest, R.StepResult{True{}, R.Undefined{}} <> saved}
        case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, saved}
    case FromSubscribed{iterator} <> rest:
      fromSubscribed(w, rest, stack, iterator)
    case FromBindOwner{iterator} <> rest:
      fromBind(w, rest, stack, iterator)
    case FromConsumeAcquired{node, result, deferred, initialValue} <> rest:
      fromConsumed(w, rest, stack, node, result, deferred, initialValue)
    case FromDeferredAcquired{cell} <> rest:
      fromDeferred(w, rest, stack, cell)
    case FromFinished{+plan} <> rest:
      Machine{From.finish(w, plan), rest, R.StepResult{True{}, R.Undefined{}} <> stack}
    case IteratorReturn{iterator, argument} <> rest:
      iteratorReturn(w, rest, stack, iterator, argument)
    case FromReturnPromise{} <> rest:
      match stack:
        case value <> tail:
          +pair = NativePromise.allocate(w, R.Fulfilled{value})
          Machine{B.first(R.World, Nat, pair), rest, R.AsyncValue{B.second(R.World, Nat, pair)} <> tail}
        case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case DeferredReturnResult{} <> +rest:
      match stack:
        case +value <> +tail:
          B.choose(~Machine, B.nullish(value),
            _ =>
              +pair = NativePromise.allocate(w, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}})
              Machine{B.first(R.World, Nat, pair), rest, R.AsyncValue{B.second(R.World, Nat, pair)} <> tail},
            _ => Machine{w, rest, value <> tail})
        case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case FromCleanupFinally{saved} <> rest:
      Machine{w, rest, saved}
    case CloseReturnFinally{saved} <> rest:
      match stack:
        case value <> tail: Machine{ignoredReturn(w, value), rest, saved}
        case _: Machine{R.World.with_fault(w, R.TypeError{}), rest, saved}
    case DeferredRejected{error} <> rest:
      Machine{R.World.with_fault(w, R.CallbackThrown{error}), rest, stack}
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
    case OptimisticArgument{id} <> +rest:
      match stack:
        case value <> tail:
          optimisticWrite(w, rest, tail, id, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case OptimisticUpdater{+id, expr} <> rest:
      +previous = Lanes.guessedValueOf(w, id)
      Machine{w, Evaluate{expr, previous} <> OptimisticResolved{id, previous} <> rest, stack}
    case CreateOptimistic{+options, +body, +previous} <> +rest:
      match stack:
        case +value <> +tail:
          B.choose(~Machine, J.isFunction(value),
            _ => optimisticCompute(w, rest, tail, R.InvokeWith{R.Literal{value}, R.Previous{}, False{}}, options, body, previous),
            _ =>
              +id = B.length(R.Node, R.World.nodes(w))
              +w = B.event(w, R.Constructed{id})
              Machine{N.signal(w, value, options), OptimisticReady{id, False{}, body, previous} <> rest, tail})
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case OptimisticReady{+signal, computed, +body, +previous} <> rest:
      +w = B.choose(~R.World, computed, _ => B.store_node(w, signal, R.Node.with_config(B.node(w, signal), B.clear(R.Node.config(B.node(w, signal)), K.CONFIG_AUTO_DISPOSE()))), _ => w)
      +pair = J.optimisticSetter(w, signal)
      +w = B.event(B.first(R.World, Nat, pair), R.SetterBound{signal})
      Machine{w, Evaluate{Local.bindAs(body, 0n, signal, R.ProgramReference{B.second(R.World, Nat, pair)}), previous} <> rest, stack}
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
    case LaneLeakLoop{readers, index, leaked} <> rest:
      laneLeakLoop(w, rest, stack, readers, index, leaked)
    case LaneRevealLoop{leaked, remaining} <> rest:
      laneRevealLoop(w, rest, stack, leaked, remaining)
    case LaneEnteredLoop{} <> rest:
      laneEnteredLoop(w, rest, stack)
    case OptimisticResolved{+id, +previous} <> +rest:
      match stack:
        case value <> tail:
          optimisticResolved(w, rest, tail, id, previous, value)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case OptimisticCompared{+id, +value} <> rest:
      match stack:
        case verdict <> tail:
          Machine{B.choose(~R.World, Bool.and(B.truth(verdict), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()))), _ => w, _ => Lanes.pushGuess(w, id, value)), rest, value <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case ApplyGuesses{parent, lane, index} <> rest:
      applyGuesses(w, rest, stack, parent, lane, index)
    case ApplyGuessCompared{+parent, +lane, +index, +id, +value} <> +rest:
      match stack:
        case verdict <> tail:
          applyGuessOverride(w, rest, tail, parent, lane, index, id, value, Bool.not(B.truth(verdict)))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case LaneWrite{id, value} <> rest:
      laneWrite(w, rest, stack, id, value)
    case LaneWriteCompared{+id, +lane, +value, guess} <> +rest:
      match stack:
        case verdict <> +tail:
          B.choose(~Machine, guess,
            _ => supersede(w, LaneWriteDone{value} <> rest, tail, id, value, Bool.not(B.truth(verdict))),
            _ => B.choose(~Machine, B.truth(verdict), _ => Machine{w, rest, value <> tail}, _ => laneWriteChanged(w, rest, tail, id, lane, value)))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case LaneWriteDone{value} <> rest:
      Machine{B.schedule(w), rest, value <> stack}
    case LaneOutcomeStart{id, value, errored} <> rest:
      laneOutcome(w, rest, stack, id, value, errored)
    case LaneOutcomeCompared{+id, +value} <> +rest:
      match stack:
        case verdict <> tail:
          supersede(w, LaneOutcomeDone{} <> rest, tail, id, value, Bool.not(B.truth(verdict)))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case LaneOutcomeDone{} <> rest:
      Machine{w, rest, R.Boolean{True{}} <> stack}
    case LaneCorrections{live, judged} <> rest:
      laneCorrectionsLoop(w, rest, stack, live, judged)
    case LaneCorrectionNodes{lane, index} <> rest:
      laneCorrectionNodes(w, rest, stack, lane, index)
    case LaneCorrectionCompared{+id, +truth} <> +rest:
      match stack:
        case verdict <> tail:
          supersede(w, rest, tail, id, truth, Bool.not(B.truth(verdict)))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case LaneCorrectionEnd{} <> rest:
      Machine{B.choose(~R.World, R.LaneState.guessed(R.World.laneState(w)),
        _ => R.World.with_laneState(w, R.LaneState.with_reverting(R.World.laneState(w), False{})), _ => w), rest, stack}
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
    case EndKept{parent, remaining} <> rest:
      endKept(w, rest, stack, parent, remaining)
    case RestoreKept{parent, entry} <> rest:
      restoreKept(w, rest, stack, parent, entry)
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
    case PublishCompared{id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, stagedErr, lane} <> rest:
      match stack:
        case equal <> tail:
          publishCompared(w, rest, tail, id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, Bool.not(B.truth(equal)), lane)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case PublishOutcome{+id, value, create, oldHeight, outgoing, outgoingSources, wasPendingSource, joined, +changed} <> rest:
      match stack:
        case handled <> tail:
          +pair = B.choose(~B.Bundle<R.World, Bool>, B.truth(handled), _ => B.Bundle{w, changed}, _ => publishStores(w, id, value, create, oldHeight, joined, changed, 0n))
          publicationCompleted(rest, tail, id, outgoing, outgoingSources, wasPendingSource, pair)
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
    case PassLaneStage{+id, +create, value, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, +joined, +errored, missed, previousLane, seated} <> rest:
      +pair = stagePassAt(w, id, create, errored, seated)
      +next = B.first(R.World, Nat, pair)
      +lane = B.second(R.World, Nat, pair)
      publishState(next, FinishPublication{id, create, joined, missed, lane, previousLane} <> rest, stack, id, value, create, oldHeight, wasUninitialized, outgoing, outgoingSources, wasPendingSource, joined, errored, lane)
    case FinishPublication{id, create, joined, missed, lane, previousLane} <> rest:
      finishPublication(w, rest, stack, id, create, joined, missed, lane, previousLane)
    case QueuePublication{+id, create, missed, lane, previousLane} <> rest:
      +w = queuePublicationIn(w, id, create, lane)
      +w = R.World.with_passLane(w, previousLane)
      w = B.choose(~R.World, Bool.and(B.ok(w), missed), _ => B.schedule(H.enqueueSub(w, id)), _ => w)
      Machine{w, rest, stack}
    case AfterDeadPass{+id, previousLane} <> rest:
      w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ => B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{})), _ => w)
      Machine{R.World.with_passLane(w, previousLane), rest, stack}
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
    case RecomputeAfterFlight{id, lanePass} <> rest:
      recomputeAfterFlight(w, rest, stack, id, lanePass)
    case RestoreDeferredReleases{id, previous, released, lanePass} <> rest:
      Machine{R.World.with_deferredReleases(w, previous), RecomputeAfterTeardown{id, released, lanePass} <> rest, stack}
    case RecomputeAfterTeardown{id, released, lanePass} <> rest:
      recomputeAfterTeardown(w, rest, stack, id, released, lanePass)
    case RecomputePrepared{id, create, released, lanePass} <> rest:
      recomputePrepared(w, rest, stack, id, create, released, lanePass)
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
    case AffectsTarget{key, previous} <> +rest:
      match stack:
        case target <> tail:
          Machine{w, Evaluate{key, previous} <> AffectsApply{target} <> rest, tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case AffectsApply{target} <> +rest:
      match stack:
        case key <> tail:
          Machine{MarkScope.affects(w, target), rest, R.Undefined{} <> tail}
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case LatestEnd{latest, dispatch, saved} <> rest:
      Machine{Verdict.restoreLatest(w, latest, dispatch), rest, stack}
    case ProbeEnd{probing, found, dispatch, saved} <> rest:
      +answer = R.VerdictState.probeFound(R.World.verdictState(w))
      Machine{Verdict.restoreProbe(w, probing, found, dispatch), rest, R.Boolean{answer} <> saved}
    case VerdictRaiseHeight{source, reader} <> rest:
      Machine{raiseSourceHeight(w, source, reader), rest, stack}
    case VerdictPrepared{id, reader, owned, tracked} <> rest:
      verdictPrepared(w, rest, stack, id, reader, owned, tracked)
    case VerdictPulled{id, reader, owned, tracked} <> rest:
      verdictAfterPull(Verdict.setDispatch(w, True{}), rest, stack, id, reader, owned, tracked)
    case VerdictGuessCompared{id, reader, lane} <> +rest:
      match stack:
        case value <> tail:
          +w = B.choose(~R.World, Bool.not(B.truth(value)), _ => Verdict.found(w), _ => w)
          verdictGuessValue(w, rest, tail, id, reader, lane)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case VerdictHeldFinal{id, reader, tracked} <> +rest:
      match stack:
        case value <> tail:
          +w = B.choose(~R.World, B.truth(value), _ => Verdict.found(w), _ => w)
          verdictHeldValue(w, rest, tail, id, reader, tracked)
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case ReadPrepared{id} <> +rest:
      readPrepared(w, rest, stack, id)
    case LaneReadDone{id, reader, forced} <> rest:
      readLaneDone(w, rest, stack, id, reader, forced)
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
    case ReleaseTransactionQueues{transaction} <> rest:
      Machine{S.releaseQueues(w, transaction), rest, stack}
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
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.callbackEffect(w), R.World.fault(w)), rest, saved}
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
    case SupersedeFinally{callback, saved} <> rest:
      supersedeFinally(w, rest, callback, saved)
    case SupersedeRestore{prior, saved} <> rest:
      Machine{R.World.with_fault(w, prior), rest, saved}
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
      afterParkIntake(R.World.with_pendingNodes(w, []), rest, stack, t)
    case Settle{} <> rest:
      beginSettle(w, rest, stack)
    case SettleCorrectionsDone{} <> +rest:
      match stack:
        case changed <> +tail:
          B.choose(~Machine, B.truth(changed), _ => heapLoopMode(w, rest, tail, True{}), _ => settleJoined(w, rest, tail))
        case _:
          Machine{R.World.with_fault(w, R.TypeError{}), rest, []}
    case HeapCorrections{} <> rest:
      heapLoopMode(w, rest, stack, True{})
    case SettleJoined{} <> rest:
      settleJoined(w, rest, stack)
    case SettleApplied{joined} <> rest:
      settleApplied(w, rest, stack, joined)
    case ParkVerdictZombies{t, nodes} <> rest:
      parkVerdictZombies(w, rest, stack, t, nodes)
    case AfterLaneSeams{t, renders, users} <> rest:
      afterLaneSeams(w, rest, stack, t, renders, users)
    case LandAfterLanes{frame, t} <> rest:
      landPrepared(w, rest, stack, frame, t)
    case AfterSettle{} <> rest:
      afterSettle(w, rest, stack)
    case LandTransactions{frame, remaining} <> rest:
      landTransactions(w, rest, stack, frame, remaining)
    case LandNodes{frame, t, index, rerunFrame} <> rest:
      landNodes(w, rest, stack, frame, t, index, rerunFrame)
    case LandEnd{frame, t, rerunFrame} <> rest:
      landEnd(w, rest, stack, frame, t, rerunFrame)
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

def deferredUnwind(w: R.World, rest: List<&2, Task>, cell: Nat, open: Bool, saved: List<&2, R.Value>, fault: R.Fault) -> Machine:
  match fault:
    case R.CallbackThrown{cause}:
      Machine{Deferred.sourceFailed(R.World.with_fault(w, R.Healthy{}), cell, open, cause), rest, saved}
    case _:
      Machine{w, rest, saved}

def unwind(+w: R.World, tasks: List<&2, Task>, stack: List<&2, R.Value>) -> Machine:
  match tasks:
    case FromCleanupFinally{saved} <> rest:
      fromCleanupCatch(w, rest, saved, R.World.fault(w))
    case CloseReturnFinally{saved} <> rest:
      fromCleanupCatch(w, rest, saved, R.World.fault(w))
    case FromWrapFinishFinally{saved} <> rest:
      fromWrapFinishFinally(w, rest, saved, R.World.fault(w))
    case SupersedeFinally{callback, saved} <> rest:
      supersedeFinally(w, rest, callback, saved)
    case SupersedeRestore{prior, saved} <> rest:
      Machine{w, rest, saved}
    case DeferredResult{cell, open, saved} <> rest:
      deferredUnwind(w, rest, cell, open, saved, R.World.fault(w))
    case DeferredCatch{cell, open, saved} <> rest:
      deferredUnwind(w, rest, cell, open, saved, R.World.fault(w))
    case LatestEnd{latest, dispatch, saved} <> rest:
      Machine{Verdict.restoreLatest(w, latest, dispatch), rest, saved}
    case ProbeEnd{probing, found, dispatch, saved} <> rest:
      probeThrown(w, rest, saved, probing, found, dispatch, R.World.fault(w))
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
      Machine{errorArmCatch(R.World.with_callbackEffect(w, parameter), R.World.callbackEffect(w), R.World.fault(w)), rest, saved}
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
