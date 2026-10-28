import ./proof/held-construction-context.bend as RoundConstruct20260
import ./proof/held-delivery-constructor-state.bend as RoundConstruct20261
import ./proof/action-control-flags.bend as RoundConstruct20262
import ./proof/action-schedule-ready.bend as RoundConstruct20263
import ./proof/held-constructed-round-boundary.bend as RoundConstruct20264
import ./proof/held-constructed-round-state.bend as RoundConstruct20265
import ./proof/action-output-queue-state.bend as RoundConstruct20266
import ./proof/ordinary-outer-entry.bend as RoundConstruct20267
import ./proof/ordinary-constructed-task-round.bend as RoundConstruct20268
import ./proof/held-source-cache-rebase.bend as SourceCache0
import ./proof/held-source-cache-body.bend as SourceCache1
import ./proof/action-output-continuation.bend as ActionOutput0
import ./proof/action-output-delivery-loop.bend as ActionOutput1
import ./proof/held-delivery-output-entry.bend as ActionOutput2
import ./proof/action-retirement-health.bend as ActionOutput3
import ./proof/action-slice-entry.bend as ActionOutput4
import ./proof/held-delivery-constructed.bend as ConstructDelivery0
import ./proof/held-delivery-constructed-input.bend as ConstructDelivery1
import ./proof/held-hold-view.bend as HeldConstruct0
import ./proof/held-hold-control.bend as HeldConstruct1
import ./proof/held-opened-profile.bend as HeldConstruct2
import ./proof/held-opened-state.bend as HeldConstruct3
import ./proof/held-body-opened-normal.bend as HeldConstruct4
import ./proof/action-constructor-state.bend as HeldConstruct5
import ./proof/ordinary-graph-data.bend as HeldConstruct6
import ./proof/held-hold-future.bend as HeldConstruct7
import ./proof/held-opened-retirement.bend as HeldConstruct8
import ./proof/held-action-delivery.bend as HeldDelivery0
import ./proof/action-delivery-input.bend as HeldDelivery1
import ./proof/held-action-delivery-guard.bend as HeldDelivery2
import ./proof/transaction-route-rebase.bend as AliasResume0
import ./proof/held-alias-preparation.bend as AliasResume1
import ./proof/held-alias-body-input.bend as AliasResume2
import ./proof/held-alias-resume-retirement.bend as AliasResume3
import ./proof/lane-pending-display.bend as RebaseLane0
import ./proof/held-preparation-alias-join.bend as HeldAlias0
import ./proof/held-preparation-source.bend as HeldResume0
import ./proof/held-source-view.bend as HeldResume1
import ./proof/held-source-operations.bend as HeldResume2
import ./proof/held-preparation-profile.bend as HeldResume3
import ./proof/held-source-transfer.bend as HeldResume4
import ./proof/held-preparation-control.bend as HeldResume5
import ./proof/action-method-store.bend as HeldResume6
import ./proof/held-resume-retirement.bend as HeldResume7
import ./proof/held-setter-frames.bend as HeldBody0
import ./proof/held-write-profile.bend as HeldBody1
import ./proof/held-transition-frame.bend as HeldBody2
import ./proof/held-write-history.bend as HeldBody3
import ./proof/held-body-evaluation.bend as HeldBody4
import ./proof/held-profile-control.bend as HeldBody5
import ./proof/held-body-return.bend as HeldBody6
import ./proof/held-body-retirement.bend as HeldBody7
import ./proof/held-body-owned-profile.bend as HeldBody8
import ./proof/held-body-constructed-retirement.bend as HeldBody9
import ./proof/held-setter-entry.bend as HeldStage0
import ./proof/list-update-lookup.bend as HeldStage1
import ./proof/held-stash-frame.bend as HeldStage2
import ./proof/held-stash-snapshot.bend as HeldStage3
import ./proof/extension-store-lenses.bend as HeldStage4
import ./proof/held-stage-health.bend as HeldStage5
import ./proof/held-stage-intake.bend as HeldStage6
import ./proof/held-write-outer.bend as HeldStage7
import ./proof/ordinary-stage-tail.bend as HeldStage8
import ./proof/held-stage-topology.bend as HeldStage9
import ./proof/ordinary-stage-topology.bend as HeldStage10
import ./proof/pointer-store-frame.bend as HeldStage11
import ./proof/pointer-notification-frame.bend as HeldStage12
import ./proof/subscriber-walk-health.bend as WriteBody0
import ./proof/subscriber-walk-step.bend as WriteBody1
import ./proof/ordinary-write-outer.bend as WriteBody2
import ./proof/subscriber-notification-health.bend as WriteBody3
import ./proof/ordinary-write-profile.bend as WriteBody4
import ./proof/ordinary-setter-health.bend as WriteBody5
import ./proof/ordinary-setter-topology.bend as WriteBody6
import ./proof/ordinary-shape-facts.bend as WriteBody7
import ./proof/subscriber-path-transport.bend as WriteBody8
import ./proof/ordinary-body-evaluation.bend as WriteBody9
import ./proof/ordinary-profile-control.bend as WriteBody10
import ./proof/ordinary-write-history.bend as WriteBody11
import ./proof/ordinary-updater-evaluation.bend as WriteBody12
import ./proof/core-prefix-compose.bend as WriteBody13
import ./proof/ordinary-write-constructed.bend as WriteBody14
import ./proof/ordinary-body-retirement.bend as WriteBody15
import ./proof/ordinary-body-return.bend as WriteBody16
import ./proof/ordinary-body-constructed.bend as WriteBody17
import ./proof/ordinary-body-construction-normal.bend as WriteBody18
import ./proof/ordinary-profile-transport.bend as WriteBody19
import ./proof/ordinary-body-entry.bend as WriteBody20
import ./proof/ordinary-body-constructed-count.bend as WriteBody21
import ./proof/action-retirement-count.bend as WriteBody22
import ./proof/action-context-reconstruction.bend as BodyImportedReconstruct
import ./proof/action-output-frame.bend as BodyOutput
import ./proof/transaction-resolution.bend as ActionPaths
import ./proof/pending-stack-history.bend as BodySteps
import ./proof/action-body-return.bend as BodyReturn
import ./proof/action-body-entry.bend as BodyEntry
import ./proof/action-first-frame.bend as BodyFirstFrame
import ./proof/action-body-retirement.bend as BodyRetire
import ./proof/action-body-constructed.bend as BodyConstruct
import ./proof/action-method-wait-fixture.bend as BodyInput
import ./proof/action-wait-history.bend as BodyHistory
import ./proof/action-body-guard.bend as BodyGuard
import ./proof/action-method-first-history.bend as BodyFirst
import ./proof/action-body-debt.bend as BodyDebt
import ./proof/transaction-route-transport.bend as RouteTransport
import ./proof/onflush-registration.bend as FlushRegistration
import ./proof/onflush-source-control.bend as FlushControl
import ./runtime/on-flush.bend as FlushOperation
import ./proof/lane-never-pending.bend as NeverPending
import ./proof/heap-status-frame.bend as HeapStatus
import ./proof/pending-tail-status.bend as TailStatus
import ./proof/pending-retirement-controller.bend as RetirementController
import ./proof/pending-notification-retirement.bend as NotificationRetirement
import ./proof/pending-notification-retirement-constructed.bend as ConstructedRetirement
import ./proof/pending-leaf-notification.bend as LeafNotify
import ./proof/notifier-source-control.bend as NotifyCut
import ./proof/pending-last-source.bend as LastSource
import ./proof/pending-last-source-status.bend as LastStatus
import ./proof/pending-settlement-status.bend as StatusPhase
import ./proof/node-status-operations.bend as StatusOperations
import ./proof/subscriber-topology-frame.bend as NotifyTopology
import ./proof/graph-allocation-properties.bend as NotifyStorage
import ./proof/pending-notification-operations.bend as NotifyOperations
import ./runtime/status.bend as NotifyRuntime
import ./proof/action-method-wait-fixture.bend as MethodWaitFixture
import ./proof/action-method-first-history.bend as MethodFirstHistory
import ./proof/action-retirement-context.bend as ActionRetirementContext
import ./proof/action-helper-context.bend as HelperContext
import ./proof/action-output-rejection.bend as ActionOutputRejection
import ./proof/action-first-retirement.bend as FirstRetirement
import ./proof/action-first-constructed.bend as FirstDelivery
import ./proof/action-first-frame.bend as FirstFrame
import ./proof/action-resume-frame.bend as ResumeFrame
import ./proof/action-resume-transaction.bend as ResumeTransaction
import ./runtime/transaction.bend as ActionTransaction
import ./proof/observer-write-frame.bend as ObserverWrites
import ./proof/observer-capture-history.bend as ObserverCapture
import ./runtime/iterator-state.bend as ObserverIterator
import ./proof/pending-notification-footprint.bend as NotificationFootprint
import ./proof/pending-notification-storage.bend as NotificationStorage
import ./proof/status-notification-room.bend as NotificationRoom
import ./proof/pending-notification-status.bend as GeneralStatus
import ./proof/pending-source-status-frame.bend as ErrorStatusFrame
import ./proof/action-wait-allocation.bend as WaitAllocation
import ./proof/action-wait-range.bend as WaitRange
import ./proof/action-wait-construction.bend as WaitConstruction
import ./proof/action-wait-history.bend as WaitHistory
import ./proof/action-wait-legacy-fixture.bend as WaitFixture
import ./proof/action-wait-fixture.bend as AllocatedWaitFixture
import ./proof/node-status-frame.bend as SourceStatusFrame
import ./proof/pending-notification-input.bend as NotificationInput
import ./proof/pending-notification-carrier.bend as PendingNotification
import ./proof/pending-notification-fixture.bend as NotificationFixture
import ./proof/single-carrier-frame.bend as SingleCarrier
import ./proof/idle-disposal-schedule.bend as IdleDisposal
import ./proof/pending-carrier-state.bend as CarrierState
import ./proof/pending-carrier-cycles.bend as CarrierCycles
import ./proof/memo-render-carrier-cycles.bend as ConstructedCarrierCycles
import ./proof/node-pointer-observation.bend as NodePointers
import ./proof/graph-extension-pointers.bend as GraphExtensionPointers
import ./proof/memo-render-pending-context.bend as RegistrationContext
import ./proof/memo-render-registration.bend as ConstructedRegistration
import ./proof/pending-source-history.bend as SourceHistory
import ./proof/pending-command-history.bend as SourceCommands
import ./proof/memo-render-source-history.bend as ConstructedSources
import ./proof/pending-add-preservation.bend as PendingAddPreserved
import ./proof/pending-add-one-edge.bend as PendingRegistration
import ./proof/pending-carrier-existing.bend as CarrierExisting
import ./proof/pending-fresh-set.bend as FreshCarrierSet
import ./proof/pending-fresh-carrier.bend as FreshCarrier
import ./proof/pending-carrier-roundtrip.bend as CarrierRoundTrip
import ./proof/graph-allocation-properties.bend as GraphStorage
import ./runtime/pending-state.bend as RuntimePendingState
import ./proof/default-node-literals.bend as DefaultLiterals
import ./proof/parentless-node-construction.bend as FreshNodeSetup
import ./proof/default-computed-construction.bend as DefaultNode
import ./proof/memo-render-construction.bend as MemoRender
import ./proof/memo-render-fixture.bend as ConstructedFixture
import ./runtime/construct-state.bend as RuntimeConstruct
import ./proof/node-store-lookup.bend as NodeStore
import ./proof/graph-fresh-link.bend as FreshGraph
import ./proof/graph-allocation-construction.bend as GraphAllocated
import ./proof/graph-link-construction.bend as GraphLinked
import ./proof/graph-empty-allocation.bend as GraphAllocation
import ./runtime/graph-state.bend as RuntimeGraph
import ./proof/bounded-core-return.bend as BoundedReturn
import ./proof/pending-leaf-return.bend as LeafReturn
import ./proof/pending-visit-control.bend as VisitControl
import ./proof/one-edge-settlement-return.bend as OneEdgeReturn
import ./proof/one-edge-return-driver.bend as OneEdgeDriver
import ./proof/subscriber-topology-frame.bend as SubscriberShape
import ./proof/pending-topology-frame.bend as PendingTopology
import ./proof/core-pending-topology.bend as CoreTopology
import ./proof/pending-topology-history.bend as TopologyHistory
import ./proof/pending-machine-shape.bend as PendingMachine
import ./proof/pending-settlement-frame.bend as SettlementFrame
import ./proof/core-pending-frame.bend as CoreSettlementFrame
import ./proof/pending-committed-history.bend as SettlementHistory
import ./proof/deferred-protocol-scope.bend as DeferredProtocolScope
import ./proof/completion-live-history.bend as CompletionMembership
import ./proof/completion-history-landing.bend as HistoryLanding
import ./proof/live-membership.bend as LiveMembership
import ./proof/action-live-selection.bend as ActionMembership
import ./proof/constructed-landing-selection.bend as ConstructedScan
import ./proof/flight-committed-frame.bend as FlightStorage
import ./proof/async-write-prefix.bend as AsyncPrefix
import ./runtime/flight.bend as RuntimeFlight
import ./runtime/pending.bend as RuntimePending
import ./runtime/owner.bend as RuntimeOwner
import ./proof/committed-storage-frame.bend as CommittedStorage
import ./proof/heap-committed-frame.bend as HeapStorage
import ./proof/staging-committed-frame.bend as StagedStorage
import ./proof/setter-committed-frame.bend as SetterStorage
import ./proof/ordinary-setter-frame.bend as OrdinaryStorage
import ./proof/staging-write-history.bend as StagingHistory
import ./runtime/write.bend as RuntimeWrites
import ./runtime/heap.bend as RuntimeHeap
import ./proof/transaction-list-construction.bend as ListConstruction
import ./proof/completion-graph-frame.bend as CompletionGraphFrame
import ./proof/pending-rendered-snapshot.bend as PendingRendered
import ./proof/completion-pending-preservation.bend as CompletionPending
import ./proof/rendered-completion-history.bend as RenderedHistory
import ./proof/action-owned-completion.bend as OwnedCompletion
import ./proof/transaction-arena.bend as AllocatedTransactions
import ./proof/transaction-membership.bend as TerminalMembership
import ./proof/transaction-rendered.bend as RenderedGraph
import ./proof/rendered-landing.bend as RenderedLanding
import ./proof/action-landing-scan.bend as LandingScan
import ./proof/transaction-empty.bend as EmptyBlocker
import ./proof/action-pair-eligibility.bend as PairEligibility
import ./proof/transaction-count-pair.bend as CountedPair
import ./proof/action-pair-completion.bend as PairCompletion
import ./proof/action-wait-settlement.bend as WaitSettlement
import ./proof/action-blocker-finish.bend as ActionBlockerFinish
import ./proof/transaction-positive.bend as PositiveBlocker
import ./proof/action-blocker.bend as ActionBlocker
import ./proof/transaction-joined-history.bend as JoinedHistory
import ./proof/action-created.bend as ActionCreated
import ./proof/action-pair.bend as ActionPair
import ./proof/scheduler-frame.bend as ScheduleFrame
import ./runtime/question.bend as OpeningQuestion
import ./proof/transaction-pair.bend as JoinedPair
import ./proof/action-join.bend as JoinedAction
import ./proof/action-opening.bend as ActionOpening
import ./proof/transaction-resolution.bend as RedirectPaths
import ./proof/action-resolution.bend as ActionRouting
import ./proof/transaction-rejoin-history.bend as RejoinHistories
import ./proof/from-promise-frame.bend as FromPromiseFrame
import ./proof/from-value-driver.bend as FromValueDriver
import ./proof/from-value-program.bend as FromValueProgram
import ./proof/from-value-outcome.bend as FromValueOutcome
import ./proof/from-iterable-value-driver.bend as FromIterableValueDriver
import ./proof/from-iterable-value-program.bend as FromIterableValueProgram
import ./proof/from-iterable-value-outcome.bend as FromIterableValueOutcome
import ./proof/from-value-bridges.bend as FromValueBridges
import ./runtime/from-wrap.bend as WrappedFrom
import ./proof/from-wrap-laws.bend as FromWrapLaws
import ./proof/from-iterable-driver.bend as FromIterableDriver
import ./proof/from-iterable-program.bend as FromIterableProgram
import ./proof/from-iterable-outcome.bend as FromIterableOutcome
import ./runtime/from-state.bend as FromState
import ./runtime/promise-input.bend as NativePromise
import ./proof/from-laws.bend as FromLaws
import ./proof/from-driver.bend as FromDriver
import ./proof/from-program.bend as FromProgram
import ./proof/from-outcome.bend as FromOutcome
import ./runtime/supersede.bend as Supersede
import Base
import ./proof/core-run-prefix.bend as CoreRunPrefix
import ./proof/pending-removal-footprint.bend as RemovalFootprint
import ./proof/empty-settlement-completion.bend as EmptySettlement
import ./observation/tree.bend as RenderedTree
import ./proof/rendered-observation.bend as RenderedView
import ./proof/rendered-independent-apply.bend as IndependentApply
import ./proof/rendered-async-prefix.bend as RenderedArrival
import ./proof/owner-continuation.bend as OwnerContinuation
import ./proof/pending-continuation.bend as PendingContinuation
import ./proof/pending-stack-history.bend as PendingHistory
import ./examples/async-cleanup.bend as CleanupExample
import ./proof/async-error-retirement.bend as ErrorRetirement
import ./proof/landing-release.bend as LandingRelease
import ./proof/deferred-stream-program.bend as DeferredStreamProgram
import ./proof/deferred-stream-driver.bend as DeferredStreamDriver
import ./proof/deferred-stream-laws.bend as DeferredStreamLaws
import ./runtime/deferred-stream.bend as DeferredStreamRuntime
import ./runtime/iterator-input.bend as IteratorInput

import ./proof/deferred-program.bend as DeferredProgram
import ./proof/deferred-payload-program.bend as DeferredPayloadProgram
import ./proof/deferred-payload-driver.bend as DeferredPayloadDriver
import ./proof/ordinary-payload.bend as Payload
import ./proof/deferred-driver.bend as DeferredDriver
import ./proof/deferred-lifecycle.bend as DeferredLifeLaws
import ./proof/deferred-error-catch.bend as DeferredCatch
import ./runtime/deferred-runtime.bend as DeferredArena
import ./runtime/deferred-lifecycle.bend as DeferredLife
import ./runtime/pending-state.bend as DeferredPending
import ./proof/deferred-lag.bend as DeferredLaws
import ./runtime/deferred-state.bend as DeferredWalk
import ./proof/affects-scope.bend as AffectsLaws
import ./proof/affects-program.bend as AffectsProgram
import ./proof/affects-driver.bend as AffectsDriver
import ./runtime/affects-scope.bend as AffectScope
import ./proof/verdict-windows.bend as WindowLaws
import ./proof/verdict-program.bend as VerdictProgram
import ./proof/verdict-driver.bend as VerdictDriver
import ./proof/optimistic-program.bend as OptimisticProgram
import ./proof/optimistic-driver.bend as OptimisticDriver
import ./proof/lane-flush.bend as FlushLaws
import ./proof/lane-pass.bend as PassLaws
import ./runtime/error.bend as SignedZeroMessage
import ./proof/signed-zero.bend as SignedZero
import ./proof/lane-guesses.bend as GuessLaws
import ./proof/lane-answers.bend as LaneAnswers
import ./proof/lane-lifecycle.bend as LaneLifecycle
import ./proof/question-order.bend as QuestionOrder
import ./proof/lane-read-laws.bend as LaneReadLaws
import ./proof/cleanup-policy.bend as CleanupPolicy
import ./runtime/cleanup-state.bend as Cleanup
import ./proof/lane-group-laws.bend as GroupLaws
import ./proof/lane-stage.bend as StageLaws
import ./runtime/transaction.bend as LaneJudgment
import ./proof/lane-blockers.bend as LaneBlockers
import ./runtime/verdict-state.bend as Verdict
import ./proof/verdict-laws.bend as VerdictLaws
import ./runtime/lanes-state.bend as Lanes
import ./runtime/truth-state.bend as Truth
import ./proof/lane-laws.bend as LaneLaws
import ./runtime/affects-marks.bend as Marks
import ./proof/mark-laws.bend as MarkLaws
import ./runtime/arrays.bend as Arrays
import ./runtime/flatten.bend as Flatten
import ./proof/array-laws.bend as ArrayLaws
import ./proof/array-write.bend as ArrayWrite
import ./proof/flatten-lifecycle.bend as FlattenLifecycle
import ./proof/flatten-natural.bend as NaturalFlatten
import ./proof/map-lifecycle.bend as MapLifecycle
import ./proof/memo-batches.bend as MemoBatches
import ./proof/memo-coalescing.bend as MemoCoalescing
import ./proof/memo-history-states.bend as MemoHistoryStates
import ./proof/memo-history-public.bend as MemoHistory
import ./proof/memo-repeat-public.bend as MemoRepeat
import ./proof/memo-repeat-states.bend as MemoRepeatStates
import ./runtime/construct-state.bend as OwnerConstruction
import ./runtime/owner-state.bend as OwnerLiteral
import ./proof/direct-owner-laws.bend as DirectOwners
import ./proof/argument-vector-laws.bend as ArgumentVectors
import ./proof/chain-setter.bend as ChainSetter
import ./proof/chain-public-program.bend as ChainPublic
import ./proof/chain-states.bend as ChainStates
import ./proof/chain-staging.bend as ChainStaging
import ./proof/chain-observation.bend as ChainObservation
import ./proof/chain-publication.bend as ChainPublication
import ./runtime/scheduler.bend as PublicationScheduler
import ./proof/memo-general-setter.bend as MemoGeneralSetter
import ./proof/memo-general-public.bend as MemoGeneralPublic
import ./proof/memo-general-states.bend as MemoGeneralStates
import ./proof/memo-general-setter-data.bend as MemoGeneralSetterData
import ./proof/action-function-laws.bend as ActionFunctions
import ./runtime/action-arguments.bend as ActionArgs
import ./proof/memo-initial.bend as MemoInitial
import ./proof/memo-initial-driver.bend as MemoInitialDriver
import ./proof/memo-constructor-cuts.bend as MemoConstructorCuts
import ./proof/transaction-merge-laws.bend as TxMerge
import ./proof/memo-public-program.bend as MemoPublic
import ./proof/action-laws.bend as ActionLaws
import ./runtime/action-state.bend as Action
import ./proof/memo-driver.bend as MemoDriver
import ./proof/memo-states.bend as MemoStates
import ./proof/memo-staging.bend as MemoStaging
import ./proof/extension-laws.bend as ExtensionLaws
import ./proof/cleanup-laws.bend as CleanupLaws
import ./runtime/extension.bend as Extension
import ./runtime/owner.bend as DisposalOwner
import ./proof/upstream-integration.bend as Integrated
import ./representation/base.bend as B
import ./representation/records.bend as R
import ./proof/chain.bend as Chain
import ./proof/ownership.bend as Ownership
import ./proof/errors.bend as Errors
import ./proof/pending.bend as Pending
import ./proof/transaction.bend as Transaction
import ./proof/flight.bend as Flight
import ./proof/held-error.bend as HeldError
import ./proof/until.bend as Until
import ./proof/callbacks.bend as Callbacks
import ./proof/context.bend as Context
import ./proof/disposer.bend as Disposer
import ./proof/context-records.bend as ContextRecords
import ./proof/bound-cleanup.bend as BoundCleanup
import ./proof/nested.bend as Nested
import ./proof/locals.bend as Locals
import ./proof/accessors.bend as Accessors
import ./proof/setters.bend as Setters
import ./proof/writable-signals.bend as WritableSignals
import ./proof/setter-cleanup.bend as SetterCleanup
import ./proof/getter-cleanup.bend as GetterCleanup
import ./proof/tracked-effects.bend as TrackedEffects
import ./proof/flush-callbacks.bend as FlushCallbacks
import ./proof/comparators.bend as Comparators
import ./runtime/equality.bend as Equality
import ./runtime/constants.bend as K
import ./runtime/pending-state.bend as PendingState
import ./runtime/status.bend as Status
import ./proof/settled.bend as Settled
import ./proof/reactions.bend as Reactions
import ./proof/publication.bend as Publication
import ./proof/publication-stage.bend as StagePublication
import ./proof/read-policy.bend as ReadPolicy
import ./proof/signal-staging.bend as SignalStaging
import ./proof/signal-driver.bend as SignalDriver
import ./runtime/api.bend as API
import ./runtime/core.bend as Core
import ./runtime/scheduler.bend as Scheduler
import ./runtime/transaction.bend as Transactions
import ./runtime/read-state.bend as ReadState
import ./proof/arena.bend as Arena
import ./proof/returned-cleanup.bend as ReturnedCleanup
import ./proof/callable-initializers.bend as CallableInitializers
import ./proof/callback-values.bend as CallbackValues
import ./proof/owner-core.bend as OwnerCore
import ./proof/computed-accessors.bend as ComputedAccessors
import ./runtime/lexical.bend as Lexical
import ./runtime/construct.bend as Construct
import ./runtime/callback.bend as Callback
import ./proof/question.bend as Question
import ./runtime/question.bend as Q

# Concrete composed regressions through actual API construction, driver,
# reads, heap, staging/commit and attached text. Generalization stays open.
law chain_once:
  {Chain.view(Chain.once(6n)) == Chain.expected(6n) : Chain.View}

law chain_twice:
  {Chain.view(Chain.twice(6n, 9n)) == Chain.expected(9n) : Chain.View}

law cleanup_reentry:
  {Ownership.view(Ownership.scenario()) == Ownership.expected() : Ownership.View}

law error_propagates:
  {Errors.view(Errors.errored()) == Errors.expectedError() : Errors.View}

law error_recovers_same_value:
  {Errors.view(Errors.recovered()) == Errors.expectedRecovery() : Errors.View}

law pending_diamond_retires:
  {Pending.view(Pending.settle(False{})) == Pending.expectedRetirement() : Pending.View}

law pending_other_path_remains:
  {Pending.view(Pending.settle(True{})) == Pending.expectedOtherPath() : Pending.View}

law transaction_parks:
  {Transaction.view(Transaction.parked()) == Transaction.expectedPark() : Transaction.View}

law transaction_lands:
  {Transaction.view(Transaction.landed()) == Transaction.expectedLand() : Transaction.View}

law loading_seed_waits:
  {Flight.view(Flight.waiting()) == Flight.expectedWait() : Flight.View}

law promise_lands:
  {Flight.view(Flight.landed()) == Flight.expectedLand() : Flight.View}

law stale_promise_is_ignored:
  {Flight.replacementView(Flight.staleCallback()) == Flight.expectedStale() : Flight.View}

law newest_promise_lands:
  {Flight.replacementView(Flight.newestCallback()) == Flight.expectedNewest() : Flight.View}

law async_diamond_lands:
  {Flight.diamondView(Flight.diamondLanded()) == Flight.expectedDiamond() : Flight.DiamondView}

# Upstream #4156 recovery regression; historical counterexample retained in the baseline branch.
law staged_error_recovers_before_landing:
  {HeldError.view(HeldError.delivered()) == HeldError.expectedRecovery() : HeldError.View}

law until_false_waits:
  {Until.falseCase() == Until.expectedFalseCase() : Until.Case}

law until_truthy_resolves:
  {Until.trueCase() == Until.expectedTrueCase() : Until.Case}

law callback_reads_and_returns:
  {Callbacks.view(Callbacks.landed()) == Callbacks.expected() : Callbacks.View}

law captured_root_disposes:
  {Context.view(Context.disposed()) == Context.expected() : Context.View}

law init_disposer_is_bound:
  {Disposer.view(Disposer.invoked()) == Disposer.expected() : Disposer.View}

law context_records_are_snapshots:
  {ContextRecords.view(ContextRecords.initial()) == ContextRecords.expectedInitial() : ContextRecords.View}

law context_child_override_is_isolated:
  {ContextRecords.view(ContextRecords.childOverride()) == ContextRecords.expectedOverride() : ContextRecords.View}

law bound_cleanup_preserves_identity:
  {BoundCleanup.view(BoundCleanup.initial()) == BoundCleanup.expected() : BoundCleanup.View}

law callback_argument_zero:
  for +first: R.Value
  for second: R.Value
  {Callback.bind(R.Argument{0n}, first, second) == R.Literal{first} : R.Expr}

law root_binder_shadows_arguments:
  for +body: R.Expr
  for first: R.Value
  for second: R.Value
  {Callback.bind(R.RootScope{body, False{}}, first, second) == R.RootScope{body, False{}} : R.Expr}

law question_increment_meaning:
  for +value: R.Question
  {Question.meaning(Q.increment(value)) == 1n+Question.meaning(value) : Nat}

law question_from_nat_meaning:
  for +value: Nat
  {Question.meaning(Q.fromNat(value)) == value : Nat}

law question_equal_reflexive:
  for +value: R.Question
  {Q.equal(value, value) == True{} : Bool}

law nan_is_not_equal:
  {B.equal(R.NotANumber{}, R.NotANumber{}) == False{} : Bool}

law undefined_is_a_staged_value:
  {B.selected(R.Present{R.Undefined{}}, R.Null{}) == R.Undefined{} : R.Value}

law nested_memo_replaces_child:
  {Nested.view(Nested.scenario()) == Nested.expected() : Nested.View}

law nested_effect_first_application_is_queued:
  {Nested.effectView(False{}) == Nested.expectedEffect() : Nested.EffectView}

law nested_effect_disposed_before_application:
  {Nested.effectView(True{}) == Nested.expectedEarlyDisposal() : Nested.EffectView}

law local_signal_is_captured:
  {Locals.view(Locals.scenario()) == Locals.expected() : Locals.View}

law lexical_read_binding:
  for +signal: Nat
  {Lexical.bind(R.LocalRead{0n}, 0n, signal) == R.Read{signal} : R.Expr}

law lexical_scope_shadows:
  for +signal: Nat
  {Lexical.bind(R.SignalScope{R.LocalRead{0n}, Construct.defaults(), R.LocalRead{0n}}, 0n, signal)
    == R.SignalScope{R.Read{signal}, Construct.defaults(), R.LocalRead{0n}} : R.Expr}

law escaped_accessor_tracks_after_root_disposal:
  {Accessors.view(Accessors.scenario()) == Accessors.expected() : Accessors.View}

law lexical_accessor_binding:
  for +signal: Nat
  {Lexical.bind(R.LocalAccessor{0n}, 0n, signal) == R.Literal{R.AccessorReference{signal}} : R.Expr}

law escaped_setter_writes_after_root_disposal:
  {Setters.view(Setters.scenario()) == Setters.expected() : Setters.View}

law reentrant_setter_uses_entry_value:
  {Setters.capture() == Setters.expectedCapture() : Setters.CaptureView}

law computed_accessor_freezes_on_root_disposal:
  {ComputedAccessors.view(ComputedAccessors.scenario()) == ComputedAccessors.expected() : ComputedAccessors.View}

law lexical_setter_binding:
  for +signal: Nat
  {Lexical.bind(R.LocalSetter{0n}, 0n, signal) == R.Literal{R.SetterReference{signal}} : R.Expr}

law writable_signal_rederives_from_manual_previous:
  {WritableSignals.view(WritableSignals.writable()) == WritableSignals.expected() : WritableSignals.View}

law held_function_result_stays_data:
  {WritableSignals.heldFunctionResult() == WritableSignals.expectedHeldFunction() : WritableSignals.HeldFunctionView}

law setter_cleanup_preserves_identity_and_clears:
  {SetterCleanup.scenario() == SetterCleanup.expected() : SetterCleanup.View}

law getter_cleanup_preserves_identity_and_pulls:
  {GetterCleanup.scenario() == GetterCleanup.expected() : GetterCleanup.View}

law effect_returns_selected_cleanup:
  {ReturnedCleanup.scenario() == ReturnedCleanup.expected() : ReturnedCleanup.View}

law callable_initializer_tracks_and_freezes:
  {CallableInitializers.scenario() == CallableInitializers.expected() : CallableInitializers.View}

law callback_values_bind_initialize_and_cleanup:
  {CallbackValues.scenario() == CallbackValues.expected() : CallbackValues.View}

law direct_owner_cleanup_reads_resume_core:
  {OwnerCore.scenario() == OwnerCore.expected() : OwnerCore.View}

law trim_error_collection_preserves_application_error:
  {OwnerCore.trimScenario() == OwnerCore.expectedTrim() : OwnerCore.TrimView}

law commit_publishes_before_parked_cleanup_error:
  {OwnerCore.commitScenario() == OwnerCore.expectedCommit() : OwnerCore.CommitView}

law flight_release_runs_read_capable_cleanup:
  {OwnerCore.asyncAutodispose() == OwnerCore.expectedAsyncCleanup() : OwnerCore.AsyncCleanupView}

law async_landing_trims_through_cleanup_read:
  {OwnerCore.asyncDependencyTrim() == OwnerCore.expectedAsyncCleanup() : OwnerCore.AsyncCleanupView}

law pending_dependent_release_runs_cleanup_read:
  {OwnerCore.pendingDependentCleanup() == OwnerCore.expectedAsyncCleanup() : OwnerCore.AsyncCleanupView}

# Concrete positive regressions for the reviewed upstream pin update.
law rebuilt_lazy_source_runs_once:
  {Integrated.lazyReader() == Integrated.expectedLazy() : Integrated.LazyView}

law writable_error_is_shown_until_replacement_commit:
  {Integrated.writableRecovery() == Integrated.expectedWritable() : Integrated.WritableView}

law later_iterator_throw_reaches_memo:
  {Integrated.protocolThrow() == Integrated.expectedProtocol() : Integrated.ProtocolView}

law empty_flatten_returns_undefined:
  {Integrated.emptyFlatten() == Integrated.expectedEmpty() : Integrated.EmptyView}

# Positive regression for upstream #4176; the negative remains at baseline/solid-d682022c.
law throwing_teardown_restores_release_collector:
  {Integrated.collectorLeak() == Integrated.expectedCollectorRestored() : Integrated.LeakView}

law tracked_effect_runs_after_commit:
  {TrackedEffects.phase() == TrackedEffects.expectedPhase() : TrackedEffects.View}

law tracked_effect_cleans_before_rerun_and_disposal:
  {TrackedEffects.cleanup() == TrackedEffects.expectedCleanup() : TrackedEffects.View}

law owned_settled_runs_once_and_cleans_on_disposal:
  {Settled.scenario(True{}) == Settled.expectedOwned() : Settled.View}

law unowned_settled_drops_cleanup_without_creating_node:
  {Settled.scenario(False{}) == Settled.expectedUnowned() : Settled.View}

law callback_settled_binding:
  for +first: R.Value
  for second: R.Value
  {Callback.bind(R.OnSettled{R.Argument{0n}}, first, second) == R.OnSettled{R.Literal{first}} : R.Expr}

law lexical_settled_binding:
  for +signal: Nat
  {Lexical.bind(R.OnSettled{R.LocalRead{0n}}, 0n, signal) == R.OnSettled{R.Read{signal}} : R.Expr}

law reaction_replaces_arms_and_retains_cleanup:
  {Reactions.lifecycle() == Reactions.expectedLifecycle() : Reactions.View}

# Positive regression for upstream #4188, including a suspended tracking read.
law pending_reaction_arm_is_replaced:
  {Reactions.pendingReplacement(False{}) == Reactions.expectedSeededControl() : Reactions.PendingView}

law seeded_reaction_arm_is_replaced:
  {Reactions.pendingReplacement(True{}) == Reactions.expectedSeededControl() : Reactions.PendingView}

law callback_reaction_binding:
  for +first: R.Value
  for second: R.Value
  {Callback.bind(R.ReactionCreate{R.Argument{0n}, 0n, Construct.defaults(), False{}}, first, second)
    == R.ReactionCreate{R.Literal{first}, 0n, Construct.defaults(), False{}} : R.Expr}

law lexical_reaction_tracking_binding:
  for +signal: Nat
  {Lexical.bind(R.ReactionArm{R.Literal{R.ProgramReference{1n}}, R.LocalRead{0n}}, 0n, signal)
    == R.ReactionArm{R.Literal{R.ProgramReference{1n}}, R.Read{signal}} : R.Expr}

# General semantic helper properties, with arbitrary payloads, surrounding
# arena entries, World fields, caller tasks and stack. Not closed regressions.
law pending_value_publication:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  {Scheduler.commitValue(Arena.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix), B.length(R.Node, prefix))
    == Arena.arena(w, prefix, R.Node.with_pending(R.Node.with_value(node, value), R.Empty{}), suffix) : R.World}

law unowned_fast_read_committed:
  for +w: R.World
  for +arena: List<&2, R.Node>
  for +tasks: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {Core.readSignalFast(ReadPolicy.scope(w, arena), tasks, stack, id)
    == Core.Machine{B.event(ReadPolicy.scope(w, arena), R.ReadValue{0n, id, R.Node.value(B.node(ReadPolicy.scope(w, arena), id))}),
      tasks, R.Node.value(B.node(ReadPolicy.scope(w, arena), id)) <> stack} : Core.Machine}

law unowned_read_does_not_join:
  for +w: R.World
  for +id: Nat
  for slow: Bool
  {Transactions.enterRead(w, 0n, id, slow) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}

law unowned_selected_read:
  for +w: R.World
  for +tasks: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {Core.serveSelected(w, tasks, stack, id, 0n, R.Empty{})
    == Core.served(w, tasks, stack, 0n, id, R.Node.value(B.node(w, id))) : Core.Machine}

law unflushed_value_is_selected:
  for +w: R.World
  for +tasks: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +reader: Nat
  for +value: R.Value
  {Core.serveSelected(w, tasks, stack, id, reader, R.Present{value})
    == Core.served(ReadState.markLateLinker(w, reader), tasks, stack, reader, id, value) : Core.Machine}

law empty_pending_publication_is_identity:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  {Scheduler.commitValue(Arena.arena(w, prefix, R.Node.with_pending(node, R.Empty{}), suffix), B.length(R.Node, prefix))
    == Arena.arena(w, prefix, R.Node.with_pending(node, R.Empty{}), suffix) : R.World}

law publication_is_idempotent:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  {Scheduler.commitValue(Scheduler.commitValue(Arena.arena(w, prefix, node, suffix), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == Scheduler.commitValue(Arena.arena(w, prefix, node, suffix), B.length(R.Node, prefix)) : R.World}

# Complete fixed data-signal program, parameterized over every numeric initial
# and next value. The comparator is deliberately disabled, as in Chain.
law signal_reads_committed_before_flush:
  for +initial: Nat
  for next: Nat
  {API.resultValue(API.read(64n, SignalStaging.input(initial, next), 2n)) == R.Number{initial} : R.Value}

law signal_reads_new_value_after_flush:
  for initial: Nat
  for +next: Nat
  {API.resultValue(API.read(64n, API.flush(64n, SignalStaging.input(initial, next)), 2n)) == R.Number{next} : R.Value}

law signal_completes_for_every_sufficient_budget:
  for initial: Nat
  for +next: Nat
  for extra: Nat
  {SignalStaging.outcome(API.flush(Nat.add(19n, extra), SignalStaging.input(initial, next)))
    == SignalStaging.expected(next) : SignalStaging.Outcome}


law nested_flush_callback_returns_before_outer_drain:
  {FlushCallbacks.nested() == FlushCallbacks.expectedNested() : FlushCallbacks.View}

law flush_drain_error_overrides_callback_error:
  {FlushCallbacks.override() == FlushCallbacks.expectedOverride() : FlushCallbacks.View}

law flush_callback_entry_preserves_caller:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for body: R.Expr
  for prev: R.Value
  for outside: {Nat.is_ne(R.World.actionDepth(w), 0n) == False{} : Bool}
  {Core.evaluate(w, rest, saved, R.FlushCallback{body}, prev)
    == Core.Machine{R.World.with_syncDepth(w, 1n+R.World.syncDepth(w)), Core.Evaluate{body, prev} <> Core.FlushCallbackFinally{saved} <> rest, saved} : Core.Machine}

law flush_finally_restores_depth_and_operands:
  for +w: R.World
  for depth: Nat
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  for fault: R.Fault
  {Core.flushCallbackRestore(R.World.with_syncDepth(w, 1n+depth), rest, saved, fault)
    == Core.Machine{R.World.with_fault(R.World.with_syncDepth(w, depth), fault), rest, saved} : Core.Machine}

law throwing_flush_callback_still_drains:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for partial: List<&2, R.Value>
  for +saved: List<&2, R.Value>
  for +error: R.Value
  {Core.flushCallbackFinally(R.World.with_fault(w, R.CallbackThrown{error}), rest, partial, saved)
    == Core.publicFlush(R.World.with_fault(w, R.Healthy{}), Core.FlushCallbackRestore{R.CallbackThrown{error}, saved} <> rest, saved) : Core.Machine}


law custom_comparator_suppresses_publication:
  {Comparators.verdict(True{}) == Comparators.expectedVerdict(0n) : Comparators.View}

law custom_comparator_publishes_change:
  {Comparators.verdict(False{}) == Comparators.expectedVerdict(1n) : Comparators.View}

law comparator_error_is_node_status:
  {Comparators.caught_error() == Comparators.expectedError() : Comparators.View}

law pending_comparator_read_means_changed:
  {Comparators.pending_read() == Comparators.expectedVerdict(1n) : Comparators.View}

law default_comparator_keeps_fast_path:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +a: R.Value
  for +b: R.Value
  for known: {Equality.custom(w, id) == 0n : Nat}
  {Core.isSame(w, rest, stack, id, a, b) == Core.Machine{w, rest, R.Boolean{Equality.isSame(w, id, a, b)} <> stack} : Core.Machine}

law custom_comparator_preserves_call_arguments:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +a: R.Value
  for +b: R.Value
  for +callback: Nat
  for known: {Equality.custom(w, id) == 1n+callback : Nat}
  {Core.isSame(w, rest, stack, id, a, b) == Core.Machine{w, Core.Evaluate{R.CallWith{1n+callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> Core.EqualityCatch{id, stack} <> rest, stack} : Core.Machine}

law comparator_not_ready_returns_undefined:
  for +w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  for id: Nat
  for identity: Nat
  for source: Nat
  {Core.equalityCatch(w, rest, saved, id, R.CallbackThrown{R.NotReadyFailure{identity, source}})
    == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.Undefined{} <> saved} : Core.Machine}

law comparator_error_routes_status:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for +id: Nat
  for +error: R.Value
  for known: {PendingState.isNotReady(error) == False{} : Bool}
  {Core.equalityCatch(w, rest, saved, id, R.CallbackThrown{error})
    == Core.Machine{Status.notifyStatusWith(R.World.with_fault(w, R.Healthy{}), id, K.STATUS_ERROR(), error), rest, R.Boolean{True{}} <> saved} : Core.Machine}

law comparator_registration_preserves_graph:
  for +w: R.World
  for id: Nat
  for callback: Nat
  {R.World.with_comparators(Equality.register(w, id, callback), R.World.comparators(w)) == w : R.World}


law changed_memo_stages_then_notifies:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +height: Nat
  for +joined: Bool
  for nonEffect: {B.effect(R.Node.kind(B.node(w, id))) == False{} : Bool}
  {Core.publishValueChanged(w, id, value, False{}, height, joined, True{})
    == StagePublication.stagedAndNotify(w, id, value, R.Node.subs(B.node(w, id))) : B.Bundle<R.World, Bool>}

law pending_stage_preserves_other_fields:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  {StagePublication.staged(Arena.arena(w, prefix, node, suffix), B.length(R.Node, prefix), value)
    == Arena.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix) : R.World}

law changed_unobserved_memo_preserves_committed_world:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  for height: Nat
  for joined: Bool
  {Core.publishValueChanged(Arena.arena(w, prefix, StagePublication.memoShape(node), suffix), B.length(R.Node, prefix), value, False{}, height, joined, True{})
    == B.Bundle{Arena.arena(w, prefix, R.Node.with_pending(StagePublication.memoShape(node), R.Present{value}), suffix), True{}} : B.Bundle<R.World, Bool>}


law existing_extension_preserves_entire_world:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +x: Nat
  {Extension.ext(Arena.arena(w, prefix, R.Node.with_x(node, 1n+x), suffix), B.length(R.Node, prefix))
    == Arena.arena(w, prefix, R.Node.with_x(node, 1n+x), suffix) : R.World}

law extension_allocation_appends_one_record:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  {Extension.ext(ExtensionLaws.scope(w, prefix, R.Node.with_x(node, 0n), suffix, extensions), B.length(R.Node, prefix))
    == ExtensionLaws.extended(w, prefix, R.Node.with_x(node, 0n), suffix, extensions) : R.World}

law extension_allocation_is_idempotent:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +head: R.NodeExtension
  for +tail: List<&2, R.NodeExtension>
  {Extension.ext(Extension.ext(ExtensionLaws.scope(w, prefix, node, suffix, head <> tail), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == Extension.ext(ExtensionLaws.scope(w, prefix, node, suffix, head <> tail), B.length(R.Node, prefix)) : R.World}

law new_extension_has_exact_default_fields:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  {B.extension(Extension.ext(ExtensionLaws.scope(w, prefix, R.Node.with_x(node, 0n), suffix, extensions), B.length(R.Node, prefix)), B.length(R.Node, prefix)) == B.blank_extension() : R.NodeExtension}

law reactive_cleanup_detaches_before_invocation:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +rest: List<&2, DisposalOwner.Task>
  for +self: Bool
  {DisposalOwner.runDisposal(Arena.arena(w, prefix, node, suffix), rest, B.length(R.Node, prefix), self, False{})
    == DisposalOwner.Machine{Arena.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), B.append(DisposalOwner.Task, DisposalOwner.disposalTasks(R.Node.disposal(node)), DisposalOwner.EffectCleanup{B.length(R.Node, prefix), self} <> rest)} : DisposalOwner.Machine}

law detached_cleanup_list_is_not_replayed:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +rest: List<&2, DisposalOwner.Task>
  for +self: Bool
  {DisposalOwner.runDisposal(Arena.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), rest, B.length(R.Node, prefix), self, False{})
    == DisposalOwner.Machine{Arena.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), DisposalOwner.EffectCleanup{B.length(R.Node, prefix), self} <> rest} : DisposalOwner.Machine}

law reactive_cleanup_uses_reverse_registration_order:
  for +w: R.World
  for +prefix: List<&2, Nat>
  for +callback: Nat
  for +rest: List<&2, DisposalOwner.Task>
  {DisposalOwner.dispatch(w, DisposalOwner.DisposalLoop{B.append(Nat, prefix, [callback]), 1n+B.length(Nat, prefix)} <> rest)
    == DisposalOwner.Machine{w, DisposalOwner.RunCleanup{callback} <> DisposalOwner.DisposalLoop{B.append(Nat, prefix, [callback]), B.length(Nat, prefix)} <> rest} : DisposalOwner.Machine}


# Conditional on this exact staged graph family, not the public setter bridge.
law staged_scalar_memo_flush_completes:
  for +next: Nat
  for extra: Nat
  {MemoDriver.view(API.flush(Nat.add(40n, extra), Core.world(MemoStates.state_0(next))))
    == MemoDriver.expected(next) : MemoDriver.View}


law action_depth_entry_exit_preserves_world:
  for +w: R.World
  {Action.exit(Action.enter(w)) == w : R.World}

law action_flush_callback_runs_without_a_drain:
  for +w: R.World
  for +depth: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +body: R.Expr
  for +previous: R.Value
  {Core.flushEntry(R.World.with_actionDepth(w, 1n+depth), rest, stack, body, previous)
    == Core.Machine{R.World.with_actionDepth(w, 1n+depth), Core.Evaluate{body, previous} <> rest, stack} : Core.Machine}

law action_plain_flush_is_a_noop:
  for +fuel: Nat
  for +w: R.World
  for +depth: Nat
  {API.flush(fuel, R.World.with_actionDepth(w, 1n+depth)) == R.World.with_actionDepth(w, 1n+depth) : R.World}

law action_yield_callback_is_once_only:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for observer: Nat
  for action: Nat
  for rejected: Bool
  for value: R.Value
  {Core.actionDelivery(w, rest, stack, R.ActionWait{observer, action, 0, True{}}, rejected, value) == Core.Machine{w, rest, stack} : Core.Machine}

law action_ignores_a_throw_after_yield_settlement:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for error: R.Value
  for observer: Nat
  for action: Nat
  {Core.actionYieldCaught(w, rest, saved, error, Some{R.ActionWait{observer, action, 0, True{}}})
    == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : Core.Machine}

law action_holds_first_slice_write:
  {ActionLaws.view(ActionLaws.parked()) == ActionLaws.View{R.Number{0n}, True{}, 1n, 0n, True{}} : ActionLaws.View}

law action_resumed_slice_lands_reconciled_write:
  {ActionLaws.view(ActionLaws.landed()) == ActionLaws.View{R.Number{3n}, False{}, 0n, 0n, True{}} : ActionLaws.View}


law scalar_memo_public_setter_reaches_staged_arena:
  for +next: Nat
  {API.setSignal(MemoDriver.base(), 2n, R.Number{next}) == Core.world(MemoStates.state_0(next)) : R.World}

law scalar_memo_public_constructor_setter_flush_completes:
  for +next: Nat
  for +extra: Nat
  {MemoDriver.view(API.flush(Nat.add(40n, extra), API.setSignal(MemoDriver.base(), 2n, R.Number{next})))
    == MemoDriver.expected(next) : MemoDriver.View}


law scalar_memo_constructor_all_natural_initial_values:
  for +initial: Nat
  for +extra: Nat
  {MemoDriver.view(API.createMemo(Nat.add(14n, extra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n)) == MemoDriver.expected(initial) : MemoDriver.View}

law merged_transactions_sum_open_counts:
  for +w: R.World
  for +source: R.Transaction
  for +target: R.Transaction
  for +suffix: List<&2, R.Transaction>
  for +reverse: Bool
  {R.Transaction.open(B.transaction(TxMerge.merged(w, source, target, suffix, reverse), TxMerge.targetId(reverse))) == Nat.add(R.Transaction.open(target), R.Transaction.open(source)) : Nat}

law merged_transaction_redirects_to_target:
  for +w: R.World
  for +source: R.Transaction
  for +target: R.Transaction
  for +suffix: List<&2, R.Transaction>
  for +reverse: Bool
  {R.Transaction.into(B.transaction(TxMerge.merged(w, source, target, suffix, reverse), TxMerge.sourceId(reverse))) == TxMerge.targetId(reverse) : Nat}

law merged_transactions_preserve_action_marker:
  for +w: R.World
  for +source: R.Transaction
  for +target: R.Transaction
  for +suffix: List<&2, R.Transaction>
  for +reverse: Bool
  {R.Transaction.acted(B.transaction(TxMerge.merged(w, source, target, suffix, reverse), TxMerge.targetId(reverse))) == Bool.or(R.Transaction.acted(target), R.Transaction.acted(source)) : Bool}

# General reusable-action construction/call and parameter-capture properties.
law action_function_creation_has_no_reactive_effect:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +factory: R.Expr
  for +methods: R.Expr
  for +previous: R.Value
  {Core.evaluate(w, rest, stack, R.ActionCreate{factory, methods}, previous) == Core.Machine{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ActionFunction{factory, methods, previous}], False{}, 0n}])), rest, R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))} <> stack} : Core.Machine}

law action_function_call_uses_shared_invocation:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for id: Nat
  for tail: List<&2, R.CleanupAction>
  for +first: R.Value
  for +second: R.Value
  for +factory: R.Expr
  for +methods: R.Expr
  for +previous: R.Value
  {Core.callbackAction(w, rest, stack, id, tail, first, second, R.ActionFunction{factory, methods, previous}) == Core.Machine{w, Core.Evaluate{R.ActionInvoke{ActionArgs.bind(factory, 0n, first, second), ActionArgs.bind(methods, 0n, first, second)}, previous} <> rest, stack} : Core.Machine}

law action_call_parameter_is_captured:
  for +first: R.Value
  for +second: R.Value
  for +index: Nat
  {ActionArgs.bind(R.ActionParameter{0n, index}, 0n, first, second) == R.Literal{Callback.argument(index, first, second)} : R.Expr}

law action_capture_preserves_resume_binder:
  for +first: R.Value
  for +second: R.Value
  for +depth: Nat
  for +index: Nat
  {ActionArgs.bind(R.Argument{index}, depth, first, second) == R.Argument{index} : R.Expr}

law nested_action_parameter_shadow_and_capture:
  for +first: R.Value
  for +second: R.Value
  {ActionArgs.bind(R.ActionCreate{R.ActionParameter{0n, 0n}, R.ActionMethods{R.ActionParameter{1n, 1n}, False{}, R.Argument{0n}, R.ActionEnd{}}}, 0n, first, second) == R.ActionCreate{R.ActionParameter{0n, 0n}, R.ActionMethods{R.Literal{second}, False{}, R.Argument{0n}, R.ActionEnd{}}} : R.Expr}

law callback_action_factory_capture:
  for +first: R.Value
  for +second: R.Value
  for +methods: R.Expr
  {Callback.bind(R.ActionCreate{R.Argument{0n}, methods}, first, second) == R.ActionCreate{R.Literal{first}, methods} : R.Expr}

law reusable_action_has_distinct_invocations:
  {ActionFunctions.view(ActionFunctions.recalled()) == ActionFunctions.View{R.Fulfilled{R.Number{16n}}, R.Fulfilled{R.Number{28n}}, 2n, 2n, 0n, 0n, R.Healthy{}} : ActionFunctions.View}

# Fixed topology, arbitrary natural initial/proposed values and sufficient budgets.
law scalar_memo_public_setter_all_initial_values:
  for +initial: Nat
  for +input: Nat
  for +constructorExtra: Nat
  {API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}) == MemoGeneralSetterData.scheduled(initial, input) : R.World}

law scalar_memo_public_program_all_initial_values:
  for +initial: Nat
  for +input: Nat
  for +constructorExtra: Nat
  for +drainExtra: Nat
  {MemoDriver.view(API.flush(Nat.add(40n, drainExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}))) == MemoDriver.expected(input) : MemoDriver.View}

# General default-helper publication properties, with explicit field premises.
law changed_memo_publication_stages_then_notifies:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +height: Nat
  for off: {R.Node.equals(B.node(w, id)) == False{} : Bool}
  for nonEffect: {B.effect(R.Node.kind(B.node(w, id))) == False{} : Bool}
  for subs: {Nat.is_ne(R.Node.subs(B.node(w, id)), 0n) == True{} : Bool}
  {Core.publishValue(w, id, value, False{}, height, False{}, False{}) == B.Bundle{PublicationScheduler.insertSubs(StagePublication.staged(w, id, value), id), True{}} : B.Bundle<R.World, Bool>}

law effect_publication_marks_and_queues_before_store:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +height: Nat
  for off: {R.Node.equals(B.node(w, id)) == False{} : Bool}
  for effect: {B.effect(R.Node.kind(B.node(w, id))) == True{} : Bool}
  for subs: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for fresh: {ChainPublication.screenSame(w, id, value) == False{} : Bool}
  for clean: {Bool.not(B.truth(R.NodeExtension.error(B.extension(w, id)))) == True{} : Bool}
  for empty: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool}
  for stillEmpty: {B.present(R.Node.pending(B.node(ChainPublication.effect_prepare(w, id), id))) == False{} : Bool}
  {Core.publishValue(w, id, value, False{}, height, False{}, False{}) == B.Bundle{B.store_node(ChainPublication.effect_prepare(w, id), id, R.Node.with_value(B.node(ChainPublication.effect_prepare(w, id), id), value)), True{}} : B.Bundle<R.World, Bool>}

# Conditional graph-family theorems. The public setter bridge is still open.
law staged_two_memo_render_graph_completes:
  for +input: Nat
  for +extra: Nat
  {Chain.view(API.flush(Nat.add(95n, extra), Core.world(ChainStates.state_0(input)))) == Chain.expected(input) : Chain.View}

law staged_graph_renders_only_its_final_proposal:
  for +input: Nat
  for +extra: Nat
  {ChainObservation.applications(R.World.events(API.flush(Nat.add(95n, extra), Core.world(ChainStates.state_0(input))))) == [R.Number{2n}, Chain.answer(input)] : List<&2, R.Value>}

# Complete constructor/setter/drain family for the actual fixed graph program.
law two_memo_render_public_setter:
  for +input: Nat
  {API.setSignal(Chain.initial(), 2n, R.Number{input}) == Core.world(ChainStates.state_0(input)) : R.World}

law two_memo_render_public_program:
  for +input: Nat
  for +extra: Nat
  {Chain.view(API.flush(Nat.add(95n, extra), API.setSignal(Chain.initial(), 2n, R.Number{input}))) == Chain.expected(input) : Chain.View}

law two_memo_render_public_final_world:
  for +input: Nat
  for +extra: Nat
  {API.flush(Nat.add(95n, extra), API.setSignal(Chain.initial(), 2n, R.Number{input})) == ChainStates.finalWorld(input) : R.World}

law two_memo_render_public_application_trace:
  for +input: Nat
  for +extra: Nat
  {ChainObservation.applications(R.World.events(API.flush(Nat.add(95n, extra), API.setSignal(Chain.initial(), 2n, R.Number{input})))) == [R.Number{2n}, Chain.answer(input)] : List<&2, R.Value>}

# Variable-arity user-call binding; no arbitrary JS execution claim.
law vector_callback_parameter:
  for +index: Nat
  for +values: List<&2, R.Value>
  {Callback.bindMany(R.Argument{index}, values) == R.Literal{B.get(R.Value, values, index, R.Undefined{})} : R.Expr}

law vector_action_parameter:
  for +index: Nat
  for +values: List<&2, R.Value>
  {ActionArgs.bindMany(R.ActionParameter{0n, index}, 0n, values) == R.Literal{B.get(R.Value, values, index, R.Undefined{})} : R.Expr}

law vector_action_preserves_resume_binder:
  for +depth: Nat
  for +index: Nat
  for +values: List<&2, R.Value>
  {ActionArgs.bindMany(R.Argument{index}, depth, values) == R.Argument{index} : R.Expr}

law vector_root_shadows_parameters:
  for +body: R.Expr
  for +values: List<&2, R.Value>
  {Callback.bindMany(R.RootScope{body, False{}}, values) == R.RootScope{body, False{}} : R.Expr}

law vector_callback_captures_action_factory:
  for +index: Nat
  for +methods: R.Expr
  for +values: List<&2, R.Value>
  {Callback.bindMany(R.ActionCreate{R.Argument{index}, methods}, values) == R.ActionCreate{R.Literal{B.get(R.Value, values, index, R.Undefined{})}, methods} : R.Expr}

law vector_nested_action_shadow_and_capture:
  for +inner: Nat
  for +outer: Nat
  for +values: List<&2, R.Value>
  {ActionArgs.bindMany(R.ActionCreate{R.ActionParameter{0n, inner}, R.ActionMethods{R.ActionParameter{1n, outer}, False{}, R.Argument{0n}, R.ActionEnd{}}}, 0n, values) == R.ActionCreate{R.ActionParameter{0n, inner}, R.ActionMethods{R.Literal{B.get(R.Value, values, outer, R.Undefined{})}, False{}, R.Argument{0n}, R.ActionEnd{}}} : R.Expr}

law vector_call_evaluates_callee_first:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +callee: R.Expr
  for +args: R.Expr
  for +previous: R.Value
  {Core.evaluate(w, rest, stack, R.InvokeMany{callee, args}, previous) == Core.Machine{w, Core.Evaluate{callee, previous} <> Core.InvokeManyCallee{args, previous} <> rest, stack} : Core.Machine}

law vector_call_evaluates_next_argument:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +callee: R.Value
  for +head: R.Expr
  for +tail: R.Expr
  for +reversed: List<&2, R.Value>
  for +previous: R.Value
  {Core.invokeManyArguments(w, rest, stack, callee, R.CallArgumentsItem{head, tail}, reversed, previous) == Core.Machine{w, Core.Evaluate{head, previous} <> Core.InvokeManyValue{callee, tail, reversed, previous} <> rest, stack} : Core.Machine}

law nine_argument_callback_returns_its_last_parameter:
  {ArgumentVectors.callback_case() == ArgumentVectors.View{R.Number{9n}, R.Unresolved{}, 0n, 2n, 0n, False{}, 0n, R.Healthy{}} : ArgumentVectors.View}

law nine_argument_action_fulfills_with_its_last_parameter:
  {ArgumentVectors.action_case() == ArgumentVectors.View{R.AsyncValue{1n}, R.Fulfilled{R.Number{9n}}, 1n, 2n, 0n, False{}, 0n, R.Healthy{}} : ArgumentVectors.View}

# Production direct owner creation and the actual root receiver/self entry.
law direct_owner_uses_ambient_parent:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +transparent: Bool
  for +previous: R.Value
  {Core.evaluate(w, rest, stack, R.OwnerCreate{transparent}, previous) == Core.Machine{OwnerConstruction.createOwner(w, R.World.context(w), transparent), rest, R.OwnerReference{B.length(R.Node, R.World.nodes(w))} <> stack} : Core.Machine}

law owner_linking_preserves_ambient_state:
  for +w: R.World
  for +parent: Nat
  for +id: Nat
  {DirectOwners.ambient(DisposalOwner.linkChild(w, parent, id)) == DirectOwners.ambient(w) : DirectOwners.Ambient}

law owner_constructor_preserves_ambient_state:
  for +w: R.World
  for +parent: Nat
  for +transparent: Bool
  {DirectOwners.ambient(OwnerLiteral.createOwner(w, parent, transparent)) == DirectOwners.ambient(w) : DirectOwners.Ambient}

law owner_dispose_method_forwards_self_flag:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +self: Bool
  for root: {B.root(R.Node.kind(B.node(w, id))) == True{} : Bool}
  {Core.disposeRootValue(w, rest, stack, R.OwnerReference{id}, self) == Core.Machine{w, Core.OwnerTasks{[DisposalOwner.Enter{id, self, False{}}, DisposalOwner.RootEnd{}]} <> rest, R.Undefined{} <> stack} : Core.Machine}

law direct_owner_can_clear_reuse_and_dispose:
  {DirectOwners.lifecycle() == DirectOwners.View{True{}, True{}, True{}, True{}, 0n, [R.CleanupObserved{2n, 2n}, R.CleanupObserved{1n, 1n}, R.CleanupObserved{2n, 2n}], 0n, False{}, False{}, R.Healthy{}} : DirectOwners.View}

# Upstream #4213 replaces the exceptional collector finally with per-callback
# error collection. The callback operand stack is discarded; teardown resumes.
law cleanup_catch_resumes_teardown:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +saved: List<&2, R.Value>
  {Core.unwind(w, Core.CleanupFinally{saved} <> rest, stack)
    == Core.Machine{Cleanup.runCleanupCatch(w, R.World.fault(w)), rest, saved} : Core.Machine}

# Upstream #4188 returns the captured node independently of later arm changes.
law reaction_returns_captured_node:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +node: Nat
  {Core.dispatch(w, Core.ReactionReturn{node} <> rest, stack)
    == Core.Machine{w, rest, R.OwnerReference{node} <> stack} : Core.Machine}

# Arbitrary natural initial value and two proposals, both drain budgets >= 40.
law scalar_memo_second_public_staging:
  for +initial: Nat
  for +first: Nat
  for +input: Nat
  for +constructorExtra: Nat
  for +firstExtra: Nat
  {API.setSignal(API.flush(Nat.add(40n, firstExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}) == Core.world(MemoRepeatStates.state_0(initial, first, input)) : R.World}

law scalar_memo_two_updates_final_world:
  for +initial: Nat
  for +first: Nat
  for +input: Nat
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +secondExtra: Nat
  {API.flush(Nat.add(40n, secondExtra), API.setSignal(API.flush(Nat.add(40n, firstExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input})) == MemoRepeatStates.finalWorld(initial, first, input) : R.World}

law scalar_memo_two_updates_complete:
  for +initial: Nat
  for +first: Nat
  for +input: Nat
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +secondExtra: Nat
  {MemoDriver.view(API.flush(Nat.add(40n, secondExtra), API.setSignal(API.flush(Nat.add(40n, firstExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}))) == MemoDriver.expected(input) : MemoDriver.View}

# Any finite nonempty sequence in the fixed equals:false signal/memo program.
# Each tail element carries its own drain budget 40 + extra.
law scalar_memo_repeatable_public_update:
  for +tick: Nat
  for +previous: Nat
  for +input: Nat
  for +events: List<&2, R.TraceEvent>
  for +jobs: List<&2, R.HostJob>
  for +extra: Nat
  {API.flush(Nat.add(40n, extra), API.setSignal(MemoHistoryStates.origin(tick, previous, events, jobs), 2n, R.Number{input})) == MemoHistoryStates.origin(1n+tick, input, MemoHistory.nextEvents(events, input), MemoHistory.nextJobs(jobs)) : R.World}

law scalar_memo_finite_history_final_world:
  for +initial: Nat
  for +first: Nat
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +updates: List<&2, MemoHistory.Update>
  {MemoHistory.run(updates, API.flush(Nat.add(40n, firstExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))) == MemoHistory.result(updates, 0n, first, MemoHistory.initialEvents(initial, first), [R.FlushJob{}]) : R.World}

law scalar_memo_finite_history_complete:
  for +initial: Nat
  for +first: Nat
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +updates: List<&2, MemoHistory.Update>
  {MemoDriver.view(MemoHistory.run(updates, API.flush(Nat.add(40n, firstExtra), API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))) == MemoDriver.expected(MemoHistory.last(updates, first)) : MemoDriver.View}

# Every pending replacement keeps the existing notification and scheduled job.
law scalar_memo_pending_write_coalesces:
  for +tick: Nat
  for +previous: Nat
  for +pending: Nat
  for +input: Nat
  for +events: List<&2, R.TraceEvent>
  for +jobs: List<&2, R.HostJob>
  {API.setSignal(Core.world(MemoHistoryStates.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input}) == Core.world(MemoHistoryStates.state_0(tick, previous, input, events, jobs)) : R.World}

law scalar_memo_batch_stages_last_proposal:
  for +tick: Nat
  for +previous: Nat
  for +first: Nat
  for +rest: List<&2, Nat>
  for +events: List<&2, R.TraceEvent>
  for +jobs: List<&2, R.HostJob>
  {MemoBatches.writes(rest, API.setSignal(MemoHistoryStates.origin(tick, previous, events, jobs), 2n, R.Number{first})) == Core.world(MemoHistoryStates.state_0(tick, previous, MemoBatches.last(rest, first), events, jobs)) : R.World}

law scalar_memo_batched_history_final_world:
  for +initial: Nat
  for +first: Nat
  for +rest: List<&2, Nat>
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +batches: List<&2, MemoBatches.Batch>
  {MemoBatches.run(batches, API.flush(Nat.add(40n, firstExtra), MemoBatches.writes(rest, API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))) == MemoBatches.result(batches, 0n, MemoBatches.last(rest, first), MemoHistory.initialEvents(initial, MemoBatches.last(rest, first)), [R.FlushJob{}]) : R.World}

law scalar_memo_batched_history_complete:
  for +initial: Nat
  for +first: Nat
  for +rest: List<&2, Nat>
  for +constructorExtra: Nat
  for +firstExtra: Nat
  for +batches: List<&2, MemoBatches.Batch>
  {MemoDriver.view(MemoBatches.run(batches, API.flush(Nat.add(40n, firstExtra), MemoBatches.writes(rest, API.setSignal(API.createMemo(Nat.add(14n, constructorExtra), MemoInitialDriver.signal(initial), MemoConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))))) == MemoDriver.expected(MemoBatches.lastBatch(batches, MemoBatches.last(rest, first))) : MemoDriver.View}

law array_holes_have_exact_length:
  for +size: Nat
  {B.length(R.Slot, Arrays.holes(size)) == size : Nat}

law fresh_array_slots_are_holes:
  for +prefix: Nat
  for +suffix: Nat
  {B.get(R.Slot, Arrays.holes(Nat.add(1n+prefix, suffix)), prefix, R.Present{R.Undefined{}}) == R.Empty{} : R.Slot}

law dense_array_slot_preserves_payload:
  for +prefix: List<&2, R.Value>
  for +value: R.Value
  for +suffix: List<&2, R.Value>
  {B.get(R.Slot, Arrays.slots(B.append(R.Value, prefix, value <> suffix)), B.length(R.Value, prefix), R.Empty{}) == R.Present{value} : R.Slot}

law array_write_retains_present_payload:
  for +prefix: List<&2, R.Slot>
  for +old: R.Slot
  for +suffix: List<&2, R.Slot>
  for +value: R.Value
  {B.get(R.Slot, B.put(R.Slot, B.append(R.Slot, prefix, old <> suffix), B.length(R.Slot, prefix), R.Empty{}, R.Present{value}), B.length(R.Slot, prefix), R.Empty{}) == R.Present{value} : R.Slot}

law array_allocation_contract:
  for +w: R.World
  for +slots: List<&2, R.Slot>
  {ArrayLaws.allocation(w, slots) == ArrayLaws.Allocation{B.length(R.ArrayData, R.World.arrays(w)), slots, B.append(R.ArrayData, R.World.arrays(w), [R.ArrayData{slots}]), w} : ArrayLaws.Allocation}

law plain_keyed_map_lifecycle:
  {MapLifecycle.lifecycle(0n) == MapLifecycle.expected() : MapLifecycle.View}

law positional_map_lifecycle:
  {MapLifecycle.lifecycle(1n) == MapLifecycle.expected() : MapLifecycle.View}

law extracted_key_map_lifecycle:
  {MapLifecycle.lifecycle(2n) == MapLifecycle.expected() : MapLifecycle.View}


law array_existing_slot_write_preserves_world:
  for +w: R.World
  for +arraysBefore: List<&2, R.ArrayData>
  for +slotsBefore: List<&2, R.Slot>
  for +old: R.Slot
  for +slotsAfter: List<&2, R.Slot>
  for +arraysAfter: List<&2, R.ArrayData>
  for +value: R.Value
  {Arrays.put(ArrayWrite.scope(w, arraysBefore, B.append(R.Slot, slotsBefore, old <> slotsAfter), arraysAfter), B.length(R.ArrayData, arraysBefore), B.length(R.Slot, slotsBefore), value) == ArrayWrite.scope(w, arraysBefore, B.append(R.Slot, slotsBefore, R.Present{value} <> slotsAfter), arraysAfter) : R.World}

law flatten_deferred_wrapper_reads_committed_values:
  {FlattenLifecycle.program() == FlattenLifecycle.expected() : FlattenLifecycle.View}

law flatten_wrapper_allocates_function_only:
  for +w: R.World
  for +results: Nat
  for +skip: Bool
  {Flatten.wrapper(w, results, skip) == B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.FlattenChildren{results, skip}], False{}, 0n}])), R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))}} : B.Bundle<R.World, R.Value>}


law array_push_appends_exactly:
  for +w: R.World
  for +arraysBefore: List<&2, R.ArrayData>
  for +slots: List<&2, R.Slot>
  for +arraysAfter: List<&2, R.ArrayData>
  for +value: R.Value
  {Flatten.push(ArrayWrite.scope(w, arraysBefore, slots, arraysAfter), B.length(R.ArrayData, arraysBefore), value) == ArrayWrite.scope(w, arraysBefore, B.append(R.Slot, slots, [R.Present{value}]), arraysAfter) : R.World}


law natural_children_complete_program:
  for +first: Nat
  for +second: Nat
  for +extra: Nat
  {NaturalFlatten.programWithBudget(first, second, extra) == NaturalFlatten.expected(first, second) : Core.Machine}

law direct_live_mark_short_circuits_probe:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +count: Nat
  for +active: Nat
  for +fuel: Nat
  for +seen: List<&2, Nat>
  for +rest: List<&2, Marks.ProbeTask>
  {Marks.probe(1n+fuel, MarkLaws.scope(w, node, extension, nodes, extensions, 1n+count, active), Marks.ProbeNode{1n} <> rest, seen) == B.Bundle{MarkLaws.scope(w, node, extension, nodes, extensions, 1n+count, active), True{}} : B.Bundle<R.World, Bool>}

law mark_increments_only_its_two_counts:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +count: Nat
  for +active: Nat
  {Marks.mark(MarkLaws.scope(w, node, extension, nodes, extensions, count, active), 1n) == MarkLaws.scope(w, node, extension, nodes, extensions, 1n+count, 1n+active) : R.World}

law nonlast_mark_does_not_repoll:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +count: Nat
  for +active: Nat
  {Marks.unmark(MarkLaws.scope(w, node, extension, nodes, extensions, 2n+count, 2n+active), 1n) == B.Bundle{MarkLaws.scope(w, node, extension, nodes, extensions, 1n+count, 1n+active), False{}} : B.Bundle<R.World, Bool>}

law inactive_mark_gate_preserves_world:
  for +w: R.World
  for +id: Nat
  {Marks.covered(R.World.with_activeMarks(w, 0n), id) == B.Bundle{R.World.with_activeMarks(w, 0n), False{}} : B.Bundle<R.World, Bool>}

law new_lane_allocation_preserves_mainline:
  for +w: R.World
  for +parent: Nat
  {Lanes.newLane(w, parent) == LaneLaws.allocation(w, parent) : B.Bundle<R.World, Nat>}

law cached_verdict_lane_does_not_allocate:
  for +w: R.World
  for +tx: R.Transaction
  for +suffix: List<&2, R.Transaction>
  for +cached: Nat
  {Lanes.verdictLane(LaneLaws.cachedWorld(w, tx, suffix, cached), 1n) == B.Bundle{LaneLaws.cachedWorld(w, tx, suffix, cached), 1n+cached} : B.Bundle<R.World, Nat>}

law shared_nonnull_lane_group_is_one_lane:
  for +w: R.World
  for +a: R.Transaction
  for +b: R.Transaction
  for +suffix: List<&2, R.Transaction>
  for +group: Nat
  {Lanes.sameLane(LaneLaws.linkedWorld(w, a, b, suffix, group), 1n, 2n) == True{} : Bool}

law lane_derivation_staging_is_latest:
  for +w: R.World
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  {Truth.laneValueOf(LaneLaws.stagedWorld(w, node, suffix, value), 1n) == value : R.Value}

law lane_guess_slot_precedes_staging:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +pending: R.Slot
  for +value: R.Value
  {Truth.laneValueOf(LaneLaws.guessWorld(w, node, extension, nodes, extensions, pending, value), 1n) == value : R.Value}

law quiet_pending_without_extension_is_false:
  for +w: R.World
  for +node: R.Node
  for +nodes: List<&2, R.Node>
  {Verdict.quietPending(VerdictLaws.nodeScope(w, R.Node.with_x(node, 0n), nodes), 1n) == False{} : Bool}

law empty_pending_sources_are_quiet:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  {Verdict.quietPending(VerdictLaws.emptySources(w, node, extension, nodes, extensions), 1n) == True{} : Bool}

law mark_witness_outside_probe_preserves_world:
  for +w: R.World
  for +state: R.VerdictState
  {Verdict.witnessMark(R.World.with_verdictState(w, R.VerdictState.with_probing(state, False{}))) == R.World.with_verdictState(w, R.VerdictState.with_probing(state, False{})) : R.World}

law provisional_probe_waits_for_the_seam:
  for +w: R.World
  for +node: R.Node
  for +nodes: List<&2, R.Node>
  for +unanswered: Bool
  {Verdict.provisionalVerdict(VerdictLaws.provisionalScope(w, node, nodes), 1n, unanswered) == VerdictLaws.waiting(w, node, nodes, unanswered) : R.World}

law joined_verdict_reader_does_not_open_lane:
  for +w: R.World
  for +node: R.Node
  for +nodes: List<&2, R.Node>
  for +tx: Nat
  {Verdict.route(VerdictLaws.joinedScope(w, node, nodes), 1n, tx) == R.World.with_passLane(VerdictLaws.nodeScope(w, R.Node.with_flags(node, U32.or(K.REACTIVE_JOINED(), K.REACTIVE_LANE_READ())), nodes), 0n) : R.World}

law held_latest_preserves_raw_staged_error:
  for +w: R.World
  for +node: R.Node
  for +nodes: List<&2, R.Node>
  for +error: R.Value
  for +reader: Nat
  {Verdict.heldLatest(VerdictLaws.errorScope(w, node, nodes, error), 1n, reader) == B.Bundle{R.World.with_fault(VerdictLaws.errorScope(w, node, nodes, error), R.CallbackThrown{error}), R.Undefined{}} : B.Bundle<R.World, R.Value>}

law open_transaction_blocks_and_restores_judge:
  for +w: R.World
  for +tx: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +count: Nat
  {LaneJudgment.blocked(LaneBlockers.openScope(w, tx, rest, count), 1n) == B.Bundle{LaneBlockers.openScope(w, tx, rest, count), True{}} : B.Bundle<R.World, Bool>}

law empty_mainline_transaction_is_unblocked:
  for +w: R.World
  for +tx: R.Transaction
  for +rest: List<&2, R.Transaction>
  {LaneJudgment.blocked(LaneBlockers.emptyScope(w, tx, rest), 1n) == B.Bundle{LaneBlockers.emptyScope(w, tx, rest), False{}} : B.Bundle<R.World, Bool>}

law linked_peer_open_count_blocks:
  for +w: R.World
  for +a: R.Transaction
  for +b: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +count: Nat
  {LaneJudgment.linkBlocked(LaneBlockers.groupScope(w, a, b, rest, count), 1n) == B.Bundle{LaneBlockers.groupScope(w, a, b, rest, count), True{}} : B.Bundle<R.World, Bool>}

law lane_guess_own_flight_is_observed:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +tx: R.Transaction
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +rest: List<&2, R.Transaction>
  {LaneJudgment.guessFlights(LaneBlockers.guessScope(w, node, extension, tx, nodes, extensions, rest), 1n) == B.Bundle{LaneBlockers.guessScope(w, node, extension, tx, nodes, extensions, rest), True{}} : B.Bundle<R.World, Bool>}

law lane_unlink_removes_first_and_preserves_world:
  for +w: R.World
  for +tx: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +groupRest: List<&2, List<&2, Nat>>
  for +prefix: List<&2, Nat>
  for +suffix: List<&2, Nat>
  {Lanes.unlink(GroupLaws.frame(w, tx, rest, groupRest, 1n, GroupLaws.before(prefix, suffix)), 1n) == GroupLaws.frame(w, tx, rest, groupRest, 0n, GroupLaws.after(prefix, suffix)) : R.World}

law lane_unlink_absent_member_clears_only_pointer:
  for +w: R.World
  for +tx: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +groupRest: List<&2, List<&2, Nat>>
  for +prefix: List<&2, Nat>
  {Lanes.unlink(GroupLaws.frame(w, tx, rest, groupRest, 1n, GroupLaws.peers(prefix)), 1n) == GroupLaws.frame(w, tx, rest, groupRest, 0n, GroupLaws.peers(prefix)) : R.World}

law lane_link_existing_group_is_exactly_unchanged:
  for +w: R.World
  for +a: R.Transaction
  for +b: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +group: Nat
  {Lanes.linkLanes(GroupLaws.linkedFrame(w, a, b, rest, group), 1n, 2n) == GroupLaws.linkedFrame(w, a, b, rest, group) : R.World}

law lane_self_link_allocates_one_group_and_one_member:
  for +w: R.World
  for +tx: R.Transaction
  for +rest: List<&2, R.Transaction>
  for +groups: List<&2, List<&2, Nat>>
  {Lanes.linkLanes(GroupLaws.selfFrame(w, tx, rest, groups), 1n, 1n) == GroupLaws.selfAllocated(w, tx, rest, groups) : R.World}

law lane_stage_cold_unread_pass_preserves_world:
  for +w: R.World
  for +node: R.Node
  for +nodes: List<&2, R.Node>
  for +lane: Nat
  {Lanes.laneStage(StageLaws.coldScope(w, node, nodes), 1n, lane, False{}, Lanes.StageAnswered{}) == B.Bundle{StageLaws.coldScope(w, node, nodes), False{}} : B.Bundle<R.World, Bool>}

law lane_stage_memo_entry_clears_staging_and_lists:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +tx: R.Transaction
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +txs: List<&2, R.Transaction>
  {Lanes.laneStage(StageLaws.member(w, node, extension, tx, nodes, extensions, txs, R.Memo{}), 1n, 1n, True{}, Lanes.StageAnswered{}) == B.Bundle{StageLaws.entered(w, node, extension, tx, nodes, extensions, txs, False{}), True{}} : B.Bundle<R.World, Bool>}

law lane_stage_failed_effect_marks_and_lists:
  for +w: R.World
  for +node: R.Node
  for +extension: R.NodeExtension
  for +tx: R.Transaction
  for +nodes: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  for +txs: List<&2, R.Transaction>
  {Lanes.laneStage(StageLaws.member(w, node, extension, tx, nodes, extensions, txs, R.Render{}), 1n, 1n, False{}, Lanes.StageFailed{}) == B.Bundle{StageLaws.entered(w, node, extension, tx, nodes, extensions, txs, True{}), True{}} : B.Bundle<R.World, Bool>}

law lane_stage_frame_pending_stays_out_of_lane:
  for +w: R.World
  for +node: R.Node
  for +source: R.Node
  for +nodes: List<&2, R.Node>
  for +lane: Nat
  {Lanes.laneStage(StageLaws.frameScope(w, node, source, nodes), 1n, lane, False{}, Lanes.StagePendingFrom{2n}) == B.Bundle{StageLaws.queued(StageLaws.frameScope(w, node, source, nodes)), False{}} : B.Bundle<R.World, Bool>}

law cleanup_policy_first_error_is_collected:
  for +w: R.World
  for +cause: R.Value
  {Cleanup.collect(R.World.with_cleanupError(w, R.Empty{}), cause) == B.schedule(R.World.with_cleanupError(w, R.Present{cause})) : R.World}

law cleanup_policy_later_error_keeps_first:
  for +w: R.World
  for +first: R.Value
  for +later: R.Value
  {Cleanup.collect(R.World.with_cleanupError(w, R.Present{first}), later) == B.schedule(R.World.with_cleanupError(w, R.Present{first})) : R.World}

law cleanup_policy_rethrow_clears_box_and_keeps_payload:
  for +w: R.World
  for +cause: R.Value
  {Cleanup.rethrowCleanupError(R.World.with_cleanupError(w, R.Present{cause}), False{}) == R.World.with_fault(R.World.with_cleanupError(w, R.Empty{}), R.CallbackThrown{cause}) : R.World}

law cleanup_policy_drop_preserves_fault_and_world:
  for +w: R.World
  for +cause: R.Value
  {Cleanup.rethrowCleanupError(R.World.with_cleanupError(w, R.Present{cause}), True{}) == R.World.with_cleanupError(w, R.Empty{}) : R.World}

law cleanup_policy_root_inside_flush_defers:
  for +w: R.World
  {Cleanup.disposeRootSelfEnd(R.World.with_running(w, True{})) == R.World.with_running(w, True{}) : R.World}

law cleanup_policy_already_halted_keeps_collector:
  for +w: R.World
  for +cause: R.Value
  {Status.haltReactivity(R.World.with_halted(w, True{}), cause) == R.World.with_halted(w, True{}) : R.World}

law cleanup_policy_first_halt_drops_collector:
  for +w: R.World
  for +cause: R.Value
  {Status.haltReactivity(R.World.with_halted(w, False{}), cause) == B.report(R.World.with_cleanupError(R.World.with_halted(w, True{}), R.Empty{}), 0, B.choose(~R.Slot, B.equal(cause, R.Undefined{}), _ => R.Empty{}, _ => R.Present{cause})) : R.World}

# Exact ordering/algebra of question provenance, beyond finite native vectors.
law question_order_reflexive:
  for +q: R.Question
  {Q.compare(q, q) == Q.Same{} : Q.Order}

law question_order_swapped:
  for +a: R.Question
  for +b: R.Question
  {QuestionOrder.inverse(Q.compare(a, b)) == Q.compare(b, a) : Q.Order}

law question_order_equality_coherent:
  for +a: R.Question
  for +b: R.Question
  {QuestionOrder.same(Q.compare(a, b)) == Q.equal(a, b) : Bool}

law question_order_irreflexive:
  for +q: R.Question
  {Q.less(q, q) == False{} : Bool}

law unstamped_answer_is_not_stale:
  for +w: R.World
  for +id: Nat
  {Lanes.stale(w, id, R.QuestionZero{}) == False{} : Bool}

law raw_lane_comparator_has_no_status_catch:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +a: R.Value
  for +b: R.Value
  for known: {Nat.is_eq(Equality.custom(w, id), 0n) == False{} : Bool}
  {Core.rawEquals(w, rest, stack, id, a, b) == Core.Machine{w, Core.Evaluate{R.CallWith{Equality.custom(w, id), R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> rest, stack} : Core.Machine}

law plain_truth_preserves_world_and_operands:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for g: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == False{} : Bool}
  for p: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool}
  for o: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  {Core.truthNode(w, rest, stack, id) == Core.Machine{w, rest, R.Number{1n} <> stack} : Core.Machine}

law pending_lane_read_keeps_fallthrough_token:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +reader: Nat
  for +id: Nat
  for +lane: Nat
  {Core.laneReadEnter(w, rest, stack, reader, id, lane, False{}, K.STATUS_PENDING()) == Core.Machine{Lanes.enterLane(w, lane, reader), rest, R.NotPendingToken{} <> stack} : Core.Machine}

law lane_leaked_seam_holds_without_reveal:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +lane: Nat
  {Core.laneSeam(w, rest, stack, lane, True{}) == Core.Machine{B.store_transaction(w, lane, R.Transaction.with_held(B.transaction(w, lane), True{})), rest, stack} : Core.Machine}

law lane_committed_effect_skips_value_comparison:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +shown: R.Slot
  {Core.dissolveCommitted(w, rest, stack, id, True{}, shown) == Core.Machine{w, rest, stack} : Core.Machine}

law lane_end_starts_live_reverse_scan:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +parent: Nat
  {Core.endLanes(w, rest, stack, parent) == Core.Machine{w, Core.EndLanesLoop{parent, B.length(Nat, R.LaneState.live(R.World.laneState(w)))} <> rest, stack} : Core.Machine}

law lane_confirmation_stages_truth_without_joining_parent:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +parent: Nat
  for +value: R.Value
  {Core.supersedeEnd(w, rest, stack, id, parent, value) == Core.Machine{B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value})), rest, stack} : Core.Machine}

law lane_hidden_correction_clears_frame_flags:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {Core.dispatch(w, Core.DissolveHidden{id} <> rest, stack) == Core.Machine{B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), U32.or(K.CONFIG_STAGED(), U32.or(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME()))))), rest, stack} : Core.Machine}

law lane_answer_errored_outcome_leaves_world:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +value: R.Value
  {Core.laneOutcome(w, rest, stack, id, value, True{}) == Core.Machine{w, rest, R.Boolean{True{}} <> stack} : Core.Machine}

law lane_answer_correction_captures_current_lane_snapshot:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {Core.laneCorrections(w, rest, stack) == Core.Machine{w, Core.LaneCorrections{R.LaneState.live(R.World.laneState(w)), False{}} <> rest, stack} : Core.Machine}

law lane_answer_empty_correction_scan_returns_judgment:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +judged: Bool
  {Core.laneCorrectionsLoop(w, rest, stack, [], judged) == Core.Machine{w, rest, R.Boolean{judged} <> stack} : Core.Machine}

law lane_answer_setter_routes_override_before_mainline_join:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +current: R.Value
  for +value: R.Value
  for known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == True{} : Bool}
  {Core.setResolved(w, rest, stack, id, current, value) == Core.Machine{w, Core.LaneWrite{id, value} <> rest, stack} : Core.Machine}

law lane_answer_read_lane_token_uses_real_pending_tail:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +reader: Nat
  for +forced: Bool
  {Core.readLaneValue(w, rest, stack, id, reader, forced, R.NotPendingToken{}) == Core.readPendingStatus(w, rest, stack, id, reader, forced) : Core.Machine}

law lane_answer_read_lane_undefined_is_a_success:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +reader: Nat
  for +forced: Bool
  {Core.readLaneValue(w, rest, stack, id, reader, forced, R.Undefined{}) == Core.Machine{B.event(w, R.ReadValue{reader, id, R.Undefined{}}), rest, R.Undefined{} <> stack} : Core.Machine}

law lane_guess_newest_queued_value_wins:
  for +w: R.World
  for +prefix: List<&2, R.Guess>
  for +id: Nat
  for +value: R.Value
  for +q: R.Question
  {Lanes.pendingGuessOf(GuessLaws.scope(w, B.append(R.Guess, prefix, [R.Guess{id, value, q}])), id) == R.Present{value} : R.Slot}

law lane_guess_empty_queue_has_no_guess:
  for +w: R.World
  for +id: Nat
  {Lanes.pendingGuessOf(GuessLaws.scope(w, []), id) == R.Empty{} : R.Slot}

law lane_guess_empty_application_records_preexisting_prefix:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +parent: Nat
  {Core.applyGuessesAt(GuessLaws.scope(w, []), rest, stack, parent) == Core.Machine{R.World.with_laneState(GuessLaws.scope(w, []), R.LaneState.with_judged(R.World.laneState(GuessLaws.scope(w, [])), B.length(Nat, R.LaneState.live(R.World.laneState(GuessLaws.scope(w, [])))))), rest, stack} : Core.Machine}

law lane_guess_equal_plain_write_does_not_queue:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +value: R.Value
  for known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == False{} : Bool}
  {Core.dispatch(w, Core.OptimisticCompared{id, value} <> rest, R.Boolean{True{}} <> stack) == Core.Machine{w, rest, value <> stack} : Core.Machine}

law lane_guess_equal_guess_write_renews_question:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +value: R.Value
  for known: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()) == True{} : Bool}
  {Core.dispatch(w, Core.OptimisticCompared{id, value} <> rest, R.Boolean{True{}} <> stack) == Core.Machine{Lanes.pushGuess(w, id, value), rest, value <> stack} : Core.Machine}

law lane_guess_unstamped_write_allocates_exact_question:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  {Lanes.pushGuess(R.World.with_question(w, R.QuestionZero{}), id, value) == B.schedule(GuessLaws.pushed(R.World.with_questions(R.World.with_question(w, R.QuestionZero{}), Q.increment(R.World.questions(w))), id, value, Q.increment(R.World.questions(w)))) : R.World}

law lane_guess_null_leaks_still_reveal_prefix:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {Core.laneSeams(w, rest, stack, R.NoIds{}) == Core.Machine{w, Core.LaneLeakLoop{[], 0n, []} <> rest, stack} : Core.Machine}

law lane_guess_reveals_are_capped_to_current_prefix:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +leaked: List<&2, Nat>
  {Core.laneLeakLoop(w, rest, stack, [], 0n, leaked) == Core.Machine{w, Core.LaneRevealLoop{leaked, Nat.min(R.LaneState.judged(R.World.laneState(w)), B.length(Nat, R.LaneState.live(R.World.laneState(w))))} <> rest, stack} : Core.Machine}

law lane_guess_zero_reveals_continue_entered_reader_drain:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +leaked: List<&2, Nat>
  {Core.laneRevealLoop(w, rest, stack, leaked, 0n) == Core.laneEnteredLoop(w, rest, stack) : Core.Machine}

law scalar_strict_signed_zero:
  for +n: Nat
  {B.equal(R.NegativeZero{}, R.Number{n}) == Nat.is_eq(0n, n) : Bool}

law scalar_strict_reverse_signed_zero:
  for +n: Nat
  {B.equal(R.Number{n}, R.NegativeZero{}) == Nat.is_eq(n, 0n) : Bool}

law scalar_negative_zero_is_falsey:
  {B.truth(R.NegativeZero{}) == False{} : Bool}

law scalar_object_is_distinguishes_sign:
  for +n: Nat
  {B.objectIs(R.NegativeZero{}, R.Number{n}) == False{} : Bool}

law scalar_object_is_identifies_nan:
  {B.objectIs(R.NotANumber{}, R.NotANumber{}) == True{} : Bool}

law scalar_signed_zero_addition:
  for +n: Nat
  {Core.arithmetic(0, R.NegativeZero{}, R.Number{n}) == R.Number{n} : R.Value}

law scalar_signed_zero_multiplication:
  for +n: Nat
  {Core.arithmetic(1, R.NegativeZero{}, R.Number{n}) == R.NegativeZero{} : R.Value}

law scalar_signed_zero_message:
  {SignedZeroMessage.stringify(R.NegativeZero{}) == "0" : String}

law lane_pass_pending_slot_precedes_lane:
  for +w: R.World
  for +id: Nat
  for present: {B.present(R.Node.pending(B.node(w, id))) == True{} : Bool}
  {Core.passValue(w, id) == B.selected(R.Node.pending(B.node(w, id)), R.Undefined{}) : R.Value}

law lane_pass_non_effect_never_queues_run:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +create: Bool
  for +changed: Bool
  for +lane: Nat
  {Core.markPublishedEffectAs(w, id, value, create, changed, lane, False{}) == w : R.World}

law lane_pass_unchanged_never_queues_run:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +create: Bool
  for +effect: Bool
  for +lane: Nat
  {Core.markPublishedEffectAs(w, id, value, create, False{}, lane, effect) == w : R.World}

law lane_pass_without_mount_joins_only_held_reads:
  for +w: R.World
  for +id: Nat
  for +previous: Nat
  for +old: R.LaneMount
  {Core.joinedPass(w, id, Core.LanePass{previous, old, R.MountFalse{}}) == B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_JOINED()) : Bool}

law lane_pass_restores_captured_mount:
  for +w: R.World
  for +previous: Nat
  for +old: R.LaneMount
  for +mount: R.LaneMount
  {Core.restoreMount(w, Core.LanePass{previous, old, mount}) == R.World.with_laneState(w, R.LaneState.with_root(R.World.laneState(w), old)) : R.World}

law lane_pass_accepted_truth_skips_ordinary_store:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +value: R.Value
  for +create: Bool
  for +height: Nat
  for +outgoing: R.Value
  for +sources: Nat
  for +wasSource: Bool
  for +joined: Bool
  for +changed: Bool
  {Core.dispatch(w, Core.PublishOutcome{id, value, create, height, outgoing, sources, wasSource, joined, changed} <> rest, R.Boolean{True{}} <> stack) == Core.publicationCompleted(rest, stack, id, outgoing, sources, wasSource, B.Bundle{w, changed}) : Core.Machine}

law lane_flush_render_queue_order:
  for +parked: Bool
  for +own: List<&2, Nat>
  for +lanes: List<&2, Nat>
  for +landing: List<&2, Nat>
  {Core.orderedRuns(~Nat, parked, own, lanes, landing) == FlushLaws.expected(~Nat, parked, own, lanes, landing) : List<&2, Nat>}

law lane_flush_user_queue_order:
  for +parked: Bool
  for +own: List<&2, R.QueueEntry>
  for +lanes: List<&2, R.QueueEntry>
  for +landing: List<&2, R.QueueEntry>
  {Core.orderedRuns(~R.QueueEntry, parked, own, lanes, landing) == FlushLaws.expected(~R.QueueEntry, parked, own, lanes, landing) : List<&2, R.QueueEntry>}

law lane_flush_captured_null_join_stays_mainline:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {Core.settleApplied(w, rest, stack, 0n) == Core.Machine{w, Core.CommitIntake{0n} <> Core.TrimIntake{0n} <> Core.FinishSettleIntake{0n} <> rest, stack} : Core.Machine}

law lane_flush_landing_follows_lane_end:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +frame: Core.SeamFrame
  for +tx: Nat
  {Core.dispatch(w, Core.LandAfterLanes{frame, tx} <> rest, stack) == Core.landPrepared(w, rest, stack, frame, tx) : Core.Machine}

law lane_flush_ineligible_parked_zombie_is_skipped:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +tx: Nat
  for +id: Nat
  for +tail: List<&2, Nat>
  for ineligible: {Bool.and(U32.is_eq(U32.and(R.Node.flags(B.node(w, id)), U32.or(K.REACTIVE_DISPOSED(), K.REACTIVE_ZOMBIE())), K.REACTIVE_ZOMBIE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT())) == False{} : Bool}
  {Core.parkVerdictZombies(w, rest, stack, tx, id <> tail) == Core.Machine{w, Core.ParkVerdictZombies{tx, tail} <> rest, stack} : Core.Machine}

law optimistic_free_data_complete_program:
  for +initial: Nat
  for +next: Nat
  for +last: Nat
  for +extra: Nat
  {Core.run(Nat.add(56n, extra), OptimisticDriver.before(initial, next, last)) == OptimisticProgram.state_56(initial, next, last) : Core.Machine}

law optimistic_free_data_keeps_authoritative_value:
  for +initial: Nat
  for +next: Nat
  for +last: Nat
  for extra: Nat
  {Core.values(Core.run(Nat.add(56n, extra), OptimisticDriver.before(initial, next, last))) == [R.Number{initial}] : List<&2, R.Value>}

law verdict_window_latestReturn:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +saved: List<&2, R.Value>
  for +latest: Bool
  for +dispatch: Bool
  {Core.dispatch(w, Core.LatestEnd{latest, dispatch, saved} <> rest, stack) == Core.Machine{WindowLaws.expectedLatest(w, latest, dispatch), rest, stack} : Core.Machine}

law verdict_window_latestThrow:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for +saved: List<&2, R.Value>
  for +latest: Bool
  for +dispatch: Bool
  {Core.unwind(w, Core.LatestEnd{latest, dispatch, saved} <> rest, stack) == Core.Machine{WindowLaws.expectedLatest(w, latest, dispatch), rest, saved} : Core.Machine}

law verdict_window_probeReturn:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for +saved: List<&2, R.Value>
  for +probing: Bool
  for +found: Bool
  for +dispatch: Bool
  {Core.dispatch(w, Core.ProbeEnd{probing, found, dispatch, saved} <> rest, stack) == Core.Machine{WindowLaws.expectedProbe(w, probing, found, dispatch), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : Core.Machine}

law verdict_window_probeNumeric:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for +probing: Bool
  for +found: Bool
  for +dispatch: Bool
  for +cause: Nat
  {Core.probeThrown(R.World.with_fault(w, R.CallbackThrown{R.Number{cause}}), rest, saved, probing, found, dispatch, R.CallbackThrown{R.Number{cause}}) == Core.Machine{R.World.with_fault(WindowLaws.expectedProbe(w, probing, found, dispatch), R.Healthy{}), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : Core.Machine}

law verdict_window_probeLoadingOwned:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for +probing: Bool
  for +found: Bool
  for +dispatch: Bool
  for +identity: Nat
  for +source: Nat
  {Core.probeThrown(R.World.with_context(WindowLaws.loading(w, identity, source, False{}), 1n), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == Core.Machine{WindowLaws.expectedProbe(R.World.with_context(WindowLaws.loading(w, identity, source, False{}), 1n), probing, found, dispatch), rest, saved} : Core.Machine}

law verdict_window_probeLoadingFound:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for +probing: Bool
  for +found: Bool
  for +dispatch: Bool
  for +identity: Nat
  for +source: Nat
  {Core.probeThrown(WindowLaws.loading(w, identity, source, True{}), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == Core.Machine{R.World.with_fault(WindowLaws.expectedProbe(WindowLaws.loading(w, identity, source, True{}), probing, found, dispatch), R.Healthy{}), rest, R.Boolean{True{}} <> saved} : Core.Machine}

law verdict_window_probeLoadingOutside:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +saved: List<&2, R.Value>
  for +probing: Bool
  for +found: Bool
  for +dispatch: Bool
  for +identity: Nat
  for +source: Nat
  {Core.probeThrown(R.World.with_context(w, 0n), rest, saved, probing, found, dispatch, R.CallbackThrown{R.NotReadyFailure{identity, source}}) == Core.Machine{R.World.with_fault(WindowLaws.expectedProbe(R.World.with_context(w, 0n), probing, found, dispatch), R.Healthy{}), rest, R.Boolean{R.VerdictState.probeFound(R.World.verdictState(w))} <> saved} : Core.Machine}

law verdict_window_complete_program:
  for +initial: Nat
  for +next: Nat
  for +extra: Nat
  {Core.run(Nat.add(53n, extra), VerdictDriver.before(initial, next)) == VerdictProgram.state_53(initial, next) : Core.Machine}

law verdict_window_read_value:
  for +initial: Nat
  for +next: Nat
  for +extra: Nat
  {Core.values(Core.run(Nat.add(53n, extra), VerdictDriver.before(initial, next))) == [R.Number{next}] : List<&2, R.Value>}

law affects_scope_invalidNumber:
  for +w: R.World
  for value: Nat
  {AffectScope.affects(w, R.Number{value}) == w : R.World}

law affects_scope_pushNone:
  for +node: Nat
  {AffectScope.push(R.NoIds{}, node) == R.SomeIds{[node]} : R.OptionalIds}

law affects_scope_pushSome:
  for +items: List<&2, Nat>
  for +node: Nat
  {AffectScope.push(R.SomeIds{items}, node) == R.SomeIds{B.append(Nat, items, [node])} : R.OptionalIds}

law affects_scope_releaseEmpty:
  for +w: R.World
  {AffectScope.release(w, []) == w : R.World}

law affects_scope_releaseAbsent:
  for +w: R.World
  for t: Nat
  {AffectScope.releaseTransactionValue(w, t, R.NoIds{}) == w : R.World}

law affects_scope_pendingShortCircuit:
  for +w: R.World
  for +node: Nat
  for pending: {B.has(R.Node.status(B.node(w, node)), K.STATUS_PENDING()) == True{} : Bool}
  {AffectScope.inFlight(w, node) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}

law affects_scope_ambientEmpty:
  for +w: R.World
  for +parked: Nat
  {AffectScope.releaseAmbient(R.World.with_ambientMarks(w, []), parked) == R.World.with_ambientMarks(w, []) : R.World}

law affects_complete_program:
  for initial: Nat
  for extra: Nat
  {Core.run(Nat.add(51n, extra), AffectsDriver.before(initial)) == AffectsProgram.state_51(initial) : Core.Machine}

law affects_pending_before_after:
  for initial: Nat
  for extra: Nat
  {R.World.arrays(Core.world(Core.run(Nat.add(51n, extra), AffectsDriver.before(initial)))) == AffectsProgram.outputs(initial) : List<&2, R.ArrayData>}

law deferred_lag_noWork:
  for w: R.World
  for fuel: Nat
  for lagging: List<&2, Nat>
  for seen: List<&2, Nat>
  {DeferredWalk.walk(fuel, w, lagging, [], seen) == B.Bundle{w, 0n} : B.Bundle<R.World, Nat>}

law deferred_lag_noLagging:
  for w: R.World
  for node: Nat
  {DeferredWalk.laggingOf(w, [], node) == B.Bundle{w, 0n} : B.Bundle<R.World, Nat>}

law deferred_lag_exhausted:
  for w: R.World
  for lagging: List<&2, Nat>
  for task: DeferredWalk.LagTask
  for rest: List<&2, DeferredWalk.LagTask>
  for seen: List<&2, Nat>
  {DeferredWalk.walk(0n, w, lagging, task <> rest, seen) == B.Bundle{R.World.with_fault(w, R.Exhausted{}), 0n} : B.Bundle<R.World, Nat>}

law deferred_lag_direct:
  for w: R.World
  for tail: List<&2, Nat>
  for rest: List<&2, DeferredWalk.LagTask>
  for seen: List<&2, Nat>
  for fuel: Nat
  {DeferredWalk.walk(1n+fuel, w, 1n <> tail, DeferredWalk.LagNode{1n} <> rest, seen) == B.Bundle{w, 1n} : B.Bundle<R.World, Nat>}

law deferred_lag_membershipBeforeSeen:
  for w: R.World
  for tail: List<&2, Nat>
  for rest: List<&2, DeferredWalk.LagTask>
  for seen: List<&2, Nat>
  for fuel: Nat
  {DeferredWalk.walk(1n+fuel, w, 1n <> tail, DeferredWalk.LagNode{1n} <> rest, 1n <> seen) == B.Bundle{w, 1n} : B.Bundle<R.World, Nat>}

law deferred_lag_nextAtTail:
  for +w: R.World
  for +lagging: List<&2, Nat>
  for +rest: List<&2, DeferredWalk.LagTask>
  for +seen: List<&2, Nat>
  for +fuel: Nat
  {DeferredWalk.walk(1n+fuel, w, lagging, DeferredWalk.LagNext{1n, 1n} <> rest, seen) == DeferredWalk.walk(fuel, w, lagging, rest, seen) : B.Bundle<R.World, Nat>}

law deferred_lag_emptyDeps:
  for +w: R.World
  for +lagging: List<&2, Nat>
  for +rest: List<&2, DeferredWalk.LagTask>
  for +seen: List<&2, Nat>
  for +fuel: Nat
  for +tail: Nat
  {DeferredWalk.walk(1n+fuel, w, lagging, DeferredWalk.LagDeps{0n, tail} <> rest, seen) == DeferredWalk.walk(fuel, w, lagging, rest, seen) : B.Bundle<R.World, Nat>}

law deferred_lag_worldFrame:
  for +fuel: Nat
  for +w: R.World
  for +lagging: List<&2, Nat>
  for +work: List<&2, DeferredWalk.LagTask>
  for +seen: List<&2, Nat>
  {DeferredLaws.eraseFault(B.first(R.World, Nat, DeferredWalk.walk(fuel, w, lagging, work, seen))) == DeferredLaws.eraseFault(w) : R.World}

law deferred_life_nullLand:
  for w: R.World
  for state: R.DeferredState
  for held: Bool
  {DeferredLife.land(w, state, R.Null{}, held) == B.Bundle{w, state} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_staleLand:
  for w: R.World
  for node: Nat
  for marked: Bool
  for answered: Bool
  for lagging: List<&2, Nat>
  for held: Bool
  {DeferredLife.land(w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, marked, answered}, lagging}, R.Reference{2n}, held) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, marked, answered}, lagging}} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_unmarkedLand:
  for w: R.World
  for node: Nat
  for answered: Bool
  for lagging: List<&2, Nat>
  {DeferredLife.land(w, R.DeferredState{R.DeferredCell{node, R.Reference{1n}, False{}, answered}, lagging}, R.Reference{1n}, False{}) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, answered}, DeferredPending.remove(lagging, node)}} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_markedAsk:
  for w: R.World
  for node: Nat
  for prior: R.Value
  for flight: R.Value
  for answered: Bool
  for lagging: List<&2, Nat>
  {DeferredLife.ask(w, R.DeferredState{R.DeferredCell{node, prior, True{}, answered}, lagging}, flight) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, flight, True{}, answered}, B.choose(~List<&2, Nat>, B.contains(lagging, node), _ => lagging, _ => B.append(Nat, lagging, [node]))}} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_idleEnd:
  for +w: R.World
  for +node: Nat
  for marked: Bool
  for answered: Bool
  for lagging: List<&2, Nat>
  {DeferredLife.end(w, R.DeferredState{R.DeferredCell{node, R.Null{}, marked, answered}, lagging}) == B.Bundle{w, R.DeferredState{R.DeferredCell{node, R.Null{}, marked, answered}, lagging}} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_emptyHeld:
  for +fuel: Nat
  for w: R.World
  for node: Nat
  {DeferredLife.landHeld(fuel, w, node, 0n) == w : R.World}

law deferred_caught_fault:
  for w: R.World
  for cell: Nat
  for open: Bool
  for error: R.Value
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  {Core.deferredUnwind(w, rest, cell, open, saved, R.CallbackThrown{error}) == Core.Machine{DeferredArena.sourceFailed(R.World.with_fault(w, R.Healthy{}), cell, open, error), rest, saved} : Core.Machine}

law deferred_life_closedFailure:
  for w: R.World
  for state: R.DeferredState
  for error: R.Value
  {DeferredLife.sourceFailed(w, state, False{}, error) == DeferredLifeLaws.failed(DeferredLife.land(w, state, R.DeferredCell.flight(R.DeferredState.cell(state)), False{}), error) : B.Bundle<R.World, R.DeferredState>}

law deferred_life_plainUnmarkedFailure:
  for w: R.World
  for node: Nat
  for flight: Nat
  for error: Nat
  for answered: Bool
  for lagging: List<&2, Nat>
  {DeferredLife.sourceFailed(w, R.DeferredState{R.DeferredCell{node, R.Reference{flight}, False{}, answered}, lagging}, True{}, R.Reference{error}) == B.Bundle{R.World.with_fault(w, R.CallbackThrown{R.Reference{error}}), R.DeferredState{R.DeferredCell{node, R.Null{}, False{}, answered}, DeferredPending.remove(lagging, node)}} : B.Bundle<R.World, R.DeferredState>}

law deferred_life_unreadyFailure:
  for w: R.World
  for state: R.DeferredState
  for identity: Nat
  for source: Nat
  {DeferredLife.sourceFailed(w, state, True{}, R.NotReadyFailure{identity, source}) == DeferredLifeLaws.failed(DeferredLife.ask(w, state, R.NotReadyFailure{identity, source}), R.NotReadyFailure{identity, source}) : B.Bundle<R.World, R.DeferredState>}

law deferred_life_answeredSticky:
  for w: R.World
  for node: Nat
  for flight: R.Value
  for marked: Bool
  for lagging: List<&2, Nat>
  {R.DeferredCell.answered(R.DeferredState.cell(B.second(R.World, R.DeferredState, DeferredLife.openWindow(w, R.DeferredState{R.DeferredCell{node, flight, marked, True{}}, lagging})))) == True{} : Bool}

# Owned data constructor, outside-owner event write, flush and accessor read.
# All natural initial/proposal pairs; no claim for arbitrary graphs or flights.
law deferred_data_complete:
  for initial: Nat
  for next: Nat
  for extra: Nat
  {Core.run(Nat.add(103n, extra), DeferredDriver.before(initial, next)) == DeferredProgram.state_103(initial, next) : Core.Machine}

law deferred_data_result:
  for initial: Nat
  for next: Nat
  for extra: Nat
  {Core.values(Core.run(Nat.add(103n, extra), DeferredDriver.before(initial, next))) == [R.Number{next}] : List<&2, R.Value>}

# The same public data lifecycle for arbitrary ordinary represented payloads.
# Each side may select a different constructor; contents and identities are free.
law deferred_stream_complete:
  for initial: Payload.Ordinary
  for next: Payload.Ordinary
  for extra: Nat
  {Core.run(Nat.add(118n, extra), DeferredStreamDriver.before(initial, next)) == DeferredStreamProgram.state_118(initial, next) : Core.Machine}

law deferred_stream_result:
  for initial: Payload.Ordinary
  for next: Payload.Ordinary
  for extra: Nat
  {Core.values(Core.run(Nat.add(118n, extra), DeferredStreamDriver.before(initial, next))) == [Payload.value(next)] : List<&2, R.Value>}

law deferred_stream_first_throw:
  for w: R.World
  for id: Nat
  for error: R.Value
  {DeferredStreamRuntime.firstInput(w, id, R.ThrowNext{error}) == B.Bundle{w, R.ThrowNext{error}} : B.Bundle<R.World, R.NextInput>}

law deferred_stream_unresolved:
  for w: R.World
  for id: Nat
  for observer: Nat
  for immediate: Bool
  {DeferredStreamRuntime.observeState(w, id, observer, immediate, R.Unresolved{}) == w : R.World}

law deferred_stream_missing_return:
  for w: R.World
  {DeferredStreamRuntime.returnInput(w, IteratorInput.MissingReturn{}) == DeferredStreamRuntime.resolvedDone(w) : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_undefined_return:
  for w: R.World
  {DeferredStreamRuntime.returnInput(w, IteratorInput.RawReturn{R.Undefined{}}) == DeferredStreamRuntime.resolvedDone(w) : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_null_return:
  for w: R.World
  {DeferredStreamRuntime.returnInput(w, IteratorInput.RawReturn{R.Null{}}) == DeferredStreamRuntime.resolvedDone(w) : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_nonnull_return:
  for w: R.World
  for value: R.Value
  for plain: {B.nullish(value) == False{} : Bool}
  {DeferredStreamRuntime.returnInput(w, IteratorInput.RawReturn{value}) == B.Bundle{w, IteratorInput.RawReturn{value}} : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_promise_return:
  for w: R.World
  for result: Nat
  {DeferredStreamRuntime.returnInput(w, IteratorInput.PromiseReturn{result}) == B.Bundle{w, IteratorInput.PromiseReturn{result}} : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_throw_return:
  for w: R.World
  for error: R.Value
  {DeferredStreamRuntime.returnInput(w, IteratorInput.ThrowReturn{error}) == B.Bundle{w, IteratorInput.ThrowReturn{error}} : B.Bundle<R.World, IteratorInput.Returned>}

law deferred_stream_done_world:
  for w: R.World
  {B.first(R.World, IteratorInput.Returned, DeferredStreamRuntime.resolvedDone(w)) == R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, [], 0n}])) : R.World}

law deferred_stream_done_value:
  for w: R.World
  {B.second(R.World, IteratorInput.Returned, DeferredStreamRuntime.resolvedDone(w)) == IteratorInput.PromiseReturn{B.length(R.AsyncObject, R.World.asyncObjects(w))} : IteratorInput.Returned}

law deferred_stream_serve_unwind:
  for w: R.World
  for cell: Nat
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  {Core.unwind(w, Core.DeferredAfterIterator{cell} <> rest, stack) == Core.Machine{w, rest, stack} : Core.Machine}

law deferred_payload_complete:
  for initial: Payload.Ordinary
  for next: Payload.Ordinary
  for extra: Nat
  {Core.run(Nat.add(103n, extra), DeferredPayloadDriver.before(initial, next)) == DeferredPayloadProgram.state_103(initial, next) : Core.Machine}

law deferred_payload_result:
  for initial: Payload.Ordinary
  for next: Payload.Ordinary
  for extra: Nat
  {Core.values(Core.run(Nat.add(103n, extra), DeferredPayloadDriver.before(initial, next))) == [Payload.value(next)] : List<&2, R.Value>}

law deferred_payload_numeric_specialization:
  for initial: Nat
  for next: Nat
  {DeferredPayloadDriver.before(Payload.DataNatural{initial}, Payload.DataNatural{next}) == DeferredDriver.before(initial, next) : Core.Machine}

law landing_release_callback:
  for w: R.World
  for transaction: Nat
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for ready: {B.ok(w) == True{} : Bool}
  {Core.step(Core.Machine{w, Core.ReleaseTransactionQueues{transaction} <> rest, stack}) == Core.Machine{Scheduler.releaseQueues(w, transaction), rest, stack} : Core.Machine}

law landing_release_world_frame:
  for w: R.World
  for transaction: Nat
  {LandingRelease.eraseQueueState(Scheduler.releaseQueues(w, transaction)) == LandingRelease.eraseQueueState(w) : R.World}

law async_error_retires_parked_frame_after_notify:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for id: Nat
  for error: R.Value
  {Core.handleErrorNotify(w, rest, stack, id, error, False{}, False{}) == Core.Machine{Status.notifyStatusWith(w, id, K.STATUS_ERROR(), error), Core.OwnerTasks{[DisposalOwner.Enter{id, False{}, True{}}]} <> Core.ErrorAfterPending{id, False{}} <> rest, stack} : Core.Machine}

law async_staged_error_preserves_parked_frame:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for id: Nat
  for error: R.Value
  {Core.handleErrorNotify(w, rest, stack, id, error, False{}, True{}) == Core.Machine{w, Core.ErrorAfterPending{id, False{}} <> rest, stack} : Core.Machine}

law async_pending_transfer_preserves_parked_frame:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for id: Nat
  for error: R.Value
  for staged: Bool
  {Core.handleErrorNotify(w, rest, stack, id, error, True{}, staged) == Core.Machine{Status.notifyStatusWith(w, id, K.STATUS_PENDING(), error), Core.ErrorSettleSource{id} <> rest, stack} : Core.Machine}

law async_rejected_replacement_releases_displayed_frame:
  {CleanupExample.main() == CleanupExample.CleanupTiming{0n, 0n, 1n, R.Healthy{}} : CleanupExample.CleanupTiming}

law supersede_reflexive:
  for slot: R.Flight
  {B.sameFlight(slot, slot) == True{} : Bool}

law supersede_undefined_not_null:
  {B.sameFlight(R.FlightUndefined{}, R.FlightEmpty{}) == False{} : Bool}

law supersede_null_not_undefined:
  {B.sameFlight(R.FlightEmpty{}, R.FlightUndefined{}) == False{} : Bool}

law supersede_active_identity:
  for result: Nat
  {B.flightId(R.FlightActive{result}) == result : Nat}

law supersede_absent:
  for w: R.World
  for id: Nat
  for known: {R.Node.x(B.node(w, id)) == 0n : Nat}
  {B.flight(w, id) == R.FlightUndefined{} : R.Flight}

law supersede_ineligible:
  for w: R.World
  for callback: Nat
  for known: {Supersede.eligible(w) == False{} : Bool}
  {Supersede.register(w, callback) == w : R.World}

law supersede_unowned:
  for w: R.World
  for callback: Nat
  for known: {R.World.context(w) == 0n : Nat}
  {Supersede.register(w, callback) == w : R.World}

law supersede_chain_world:
  for w: R.World
  for before: Nat
  for after: Nat
  {B.first(R.World, Nat, Supersede.chain(w, before, after)) == R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.SupersedeChain{before, after}], False{}, 0n}])) : R.World}

law supersede_chain_identity:
  for w: R.World
  for before: Nat
  for after: Nat
  {B.second(R.World, Nat, Supersede.chain(w, before, after)) == B.length(R.CleanupProgram, R.World.cleanupPrograms(w)) : Nat}

law supersede_finally_entry:
  for w: R.World
  for rest: List<&2, Core.Task>
  for callback: Nat
  for saved: List<&2, R.Value>
  {Core.supersedeFinally(w, rest, callback, saved) == Core.Machine{R.World.with_fault(w, R.Healthy{}), Core.Evaluate{R.CallProgram{callback}, R.Undefined{}} <> Core.SupersedeRestore{R.World.fault(w), saved} <> rest, saved} : Core.Machine}

law supersede_finally_return:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for callback: Nat
  for saved: List<&2, R.Value>
  {Core.dispatch(w, Core.SupersedeFinally{callback, saved} <> rest, stack) == Core.supersedeFinally(w, rest, callback, saved) : Core.Machine}

law supersede_finally_throw:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for callback: Nat
  for saved: List<&2, R.Value>
  {Core.unwind(w, Core.SupersedeFinally{callback, saved} <> rest, stack) == Core.supersedeFinally(w, rest, callback, saved) : Core.Machine}

law supersede_restore_success:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for prior: R.Fault
  for saved: List<&2, R.Value>
  {Core.dispatch(w, Core.SupersedeRestore{prior, saved} <> rest, stack) == Core.Machine{R.World.with_fault(w, prior), rest, saved} : Core.Machine}

law supersede_override_failure:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for prior: R.Fault
  for saved: List<&2, R.Value>
  {Core.unwind(w, Core.SupersedeRestore{prior, saved} <> rest, stack) == Core.Machine{w, rest, saved} : Core.Machine}

law supersede_chain_continuation:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for id: Nat
  for tail: List<&2, R.CleanupAction>
  for first: R.Value
  for second: R.Value
  for before: Nat
  for after: Nat
  {Core.callbackAction(w, rest, stack, id, tail, first, second, R.SupersedeChain{before, after}) == Core.Machine{w, Core.Evaluate{R.CallProgram{before}, R.Undefined{}} <> Core.SupersedeFinally{after, stack} <> Core.Callback{id, tail, first, second} <> rest, stack} : Core.Machine}

law from_settle_no_wait:
  for w: R.World
  for plan: Nat
  for known: {R.FromSubscription.waiting(FromState.subscription(w, plan)) == 0n : Nat}
  {FromState.settle(w, plan) == w : R.World}

law from_emitted_done:
  for w: R.World
  for plan: Nat
  for value: R.Value
  for known: {R.FromSubscription.done(FromState.subscription(w, plan)) == True{} : Bool}
  {FromState.emitted(w, plan, value) == w : R.World}

law from_closed_noop:
  for w: R.World
  for plan: Nat
  for known: {R.FromSubscription.closed(FromState.subscription(w, plan)) == True{} : Bool}
  {FromState.close(w, plan) == B.Bundle{w, R.Null{}} : B.Bundle<R.World, R.Value>}

law from_close_open:
  for w: R.World
  for plan: Nat
  for known: {R.FromSubscription.closed(FromState.subscription(w, plan)) == False{} : Bool}
  {FromState.close(w, plan) == B.Bundle{FromState.store(w, plan, R.FromSubscription.with_unsubscribe(R.FromSubscription.with_done(R.FromSubscription.with_closed(FromState.subscription(w, plan), True{}), True{}), R.Null{})), R.FromSubscription.unsubscribe(FromState.subscription(w, plan))} : B.Bundle<R.World, R.Value>}

law from_finish_no_wait:
  for w: R.World
  for plan: Nat
  for known: {R.FromSubscription.waiting(FromState.subscription(w, plan)) == 0n : Nat}
  {FromState.finish(w, plan) == FromState.store(w, plan, R.FromSubscription.with_has(FromState.subscription(w, plan), False{})) : R.World}

law from_allocate_world:
  for w: R.World
  for state: R.AsyncSettlement
  {B.first(R.World, Nat, NativePromise.allocate(w, state)) == R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, state, [], 0n}])) : R.World}

law from_allocate_identity:
  for w: R.World
  for state: R.AsyncSettlement
  {B.second(R.World, Nat, NativePromise.allocate(w, state)) == B.length(R.AsyncObject, R.World.asyncObjects(w)) : Nat}

law from_fulfilled:
  for w: R.World
  for id: Nat
  for rejected: Bool
  for value: R.Value
  for object: R.AsyncObject
  for prior: R.Value
  {NativePromise.settleState(w, id, rejected, value, object, R.Fulfilled{prior}) == w : R.World}

law from_rejected:
  for w: R.World
  for id: Nat
  for rejected: Bool
  for value: R.Value
  for object: R.AsyncObject
  for prior: R.Value
  {NativePromise.settleState(w, id, rejected, value, object, R.Rejected{prior}) == w : R.World}

law from_no_observers:
  for w: R.World
  for rejected: Bool
  for value: R.Value
  {NativePromise.deliveries([], w, rejected, value) == w : R.World}

law from_cleanup_throw:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  for cause: R.Value
  {Core.fromCleanupCatch(w, rest, saved, R.CallbackThrown{cause}) == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : Core.Machine}

law from_cleanup_type_error:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  {Core.fromCleanupCatch(w, rest, saved, R.TypeError{}) == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : Core.Machine}

law from_preserve_exhaustion:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  {Core.fromCleanupCatch(w, rest, saved, R.Exhausted{}) == Core.Machine{w, rest, saved} : Core.Machine}

law from_finished:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for plan: Nat
  {Core.dispatch(w, Core.FromFinished{plan} <> rest, stack) == Core.Machine{FromState.finish(w, plan), rest, R.StepResult{True{}, R.Undefined{}} <> stack} : Core.Machine}

law from_program_complete:
  for input: Payload.Ordinary
  for extra: Nat
  {Core.run(Nat.add(120n, extra), FromDriver.before(input)) == FromProgram.state_120(input) : Core.Machine}

law from_program_value_cleanup:
  for input: Payload.Ordinary
  for extra: Nat
  {FromOutcome.outcome(Core.run(Nat.add(120n, extra), FromDriver.before(input))) == FromOutcome.Outcome{R.Present{Payload.value(input)}, 1n, R.Healthy{}} : FromOutcome.Outcome}

law from_wrap_bare:
  for w: R.World
  for plan: Nat
  for done: Bool
  for value: R.Value
  {WrappedFrom.wrapInput(w, plan, R.BareNext{done, value}) == B.Bundle{w, R.BareNext{done, value}} : B.Bundle<R.World, R.NextInput>}

law from_wrap_thrown:
  for w: R.World
  for plan: Nat
  for error: R.Value
  {WrappedFrom.wrapInput(w, plan, R.ThrowNext{error}) == B.Bundle{w, R.ThrowNext{error}} : B.Bundle<R.World, R.NextInput>}

law from_wrap_unresolved:
  for w: R.World
  for plan: Nat
  for output: Nat
  for observer: Nat
  for immediate: Bool
  {WrappedFrom.observerState(w, plan, output, observer, immediate, R.Unresolved{}) == w : R.World}

law from_wrap_canceled_delivery:
  for w: R.World
  for plan: Nat
  for output: Nat
  for rejected: Bool
  for value: R.Value
  for known: {WrappedFrom.has(R.FromWrapped.pending(WrappedFrom.get(w, plan)), output) == False{} : Bool}
  {WrappedFrom.deliver(w, plan, output, rejected, value) == w : R.World}

law from_wrap_no_pending:
  for w: R.World
  {WrappedFrom.resolvePending([], w) == w : R.World}

law from_wrap_no_waits:
  for observer: Nat
  {WrappedFrom.findWait([], observer) == 0n : Nat}

law from_wrap_no_plans:
  for observer: Nat
  for id: Nat
  {WrappedFrom.findPlans([], observer, id) == B.Bundle{0n, 0n} : B.Bundle<Nat, Nat>}

law from_wrap_remove_empty:
  for id: Nat
  {WrappedFrom.remove([], id) == [] : List<&2, Nat>}

law from_wrap_return_throw:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  for cause: R.Value
  {Core.fromWrapFinishFinally(w, rest, saved, R.CallbackThrown{cause}) == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved} : Core.Machine}

law from_wrap_return_type_error:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  {Core.fromWrapFinishFinally(w, rest, saved, R.TypeError{}) == Core.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved} : Core.Machine}

law from_wrap_preserve_exhaustion:
  for w: R.World
  for rest: List<&2, Core.Task>
  for saved: List<&2, R.Value>
  {Core.fromWrapFinishFinally(w, rest, saved, R.Exhausted{}) == Core.Machine{w, rest, saved} : Core.Machine}

law from_wrap_already_closed:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for id: Nat
  for tail: List<&2, R.CleanupAction>
  for first: R.Value
  for second: R.Value
  for plan: Nat
  for known: {R.FromWrapped.closed(WrappedFrom.get(w, plan)) == True{} : Bool}
  {Core.callbackAction(w, rest, stack, id, tail, first, second, R.FromWrappedFinish{plan}) == Core.Machine{w, rest, R.StepResult{True{}, R.Undefined{}} <> stack} : Core.Machine}

law from_iterable_program_complete:
  for input: Payload.Ordinary
  for extra: Nat
  {Core.run(Nat.add(84n, extra), FromIterableDriver.before(input)) == FromIterableProgram.state_84(input) : Core.Machine}

law from_iterable_program_cancels_pull:
  for input: Payload.Ordinary
  for extra: Nat
  {FromIterableOutcome.outcome(Core.run(Nat.add(84n, extra), FromIterableDriver.before(input))) == FromIterableOutcome.Outcome{R.Present{Payload.value(input)}, 1n, True{}, [], R.Unresolved{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, R.Healthy{}} : FromIterableOutcome.Outcome}

law from_wrap_cached_iterator:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for source: Nat
  for ordinary: {FromState.factory(w, source) == False{} : Bool}
  for cached: {Nat.is_ne(DeferredStreamRuntime.planWrapper(w, source), 0n) == True{} : Bool}
  {Core.fromOpenState(w, rest, stack, R.FromIterable{source}) == Core.Machine{w, Core.FromWrapOpened{} <> rest, R.IteratorReference{DeferredStreamRuntime.iterator(w, source)} <> stack} : Core.Machine}

law from_value_program_complete:
  for input: R.Value
  for extra: Nat
  {Core.run(Nat.add(120n, extra), FromValueDriver.before(input)) == FromValueProgram.state_120(input) : Core.Machine}

law from_value_program_result:
  for input: R.Value
  for extra: Nat
  {FromOutcome.outcome(Core.run(Nat.add(120n, extra), FromValueDriver.before(input))) == FromOutcome.Outcome{R.Present{input}, 1n, R.Healthy{}} : FromOutcome.Outcome}

law from_iterable_value_program_complete:
  for input: R.Value
  for extra: Nat
  {Core.run(Nat.add(84n, extra), FromIterableValueDriver.before(input)) == FromIterableValueProgram.state_84(input) : Core.Machine}

law from_iterable_value_program_result:
  for input: R.Value
  for extra: Nat
  {FromIterableOutcome.outcome(Core.run(Nat.add(84n, extra), FromIterableValueDriver.before(input))) == FromIterableOutcome.Outcome{R.Present{input}, 1n, True{}, [], R.Unresolved{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, R.Healthy{}} : FromIterableOutcome.Outcome}

law from_value_ordinary_bridge:
  for input: Payload.Ordinary
  {FromValueDriver.before(Payload.value(input)) == FromDriver.before(input) : Core.Machine}

law from_iterable_value_ordinary_bridge:
  for input: Payload.Ordinary
  {FromIterableValueDriver.before(Payload.value(input)) == FromIterableDriver.before(input) : Core.Machine}

law from_promise_deliveries_frame:
  for observers: List<&2, Nat>
  for w: R.World
  for rejected: Bool
  for value: R.Value
  {FromPromiseFrame.erase(NativePromise.deliveries(observers, w, rejected, value)) == FromPromiseFrame.erase(w) : R.World}

law from_promise_settlement_frame:
  for w: R.World
  for id: Nat
  for rejected: Bool
  for value: R.Value
  for object: R.AsyncObject
  for state: R.AsyncSettlement
  {FromPromiseFrame.erase(NativePromise.settleState(w, id, rejected, value, object, state)) == FromPromiseFrame.erase(w) : R.World}

law from_promise_settle_frame:
  for w: R.World
  for id: Nat
  for rejected: Bool
  for value: R.Value
  {FromPromiseFrame.erase(NativePromise.settle(w, id, rejected, value)) == FromPromiseFrame.erase(w) : R.World}

law from_pending_frame:
  for items: List<&2, Nat>
  for w: R.World
  {FromPromiseFrame.erase(WrappedFrom.resolvePending(items, w)) == FromPromiseFrame.erase(w) : R.World}

law from_finish_frame:
  for w: R.World
  for plan: Nat
  {FromPromiseFrame.erase(WrappedFrom.finish(w, plan)) == FromPromiseFrame.erase(w) : R.World}

law from_callback_delivery_frame:
  for w: R.World
  for plan: Nat
  for output: Nat
  for rejected: Bool
  for value: R.Value
  {FromPromiseFrame.erase(WrappedFrom.deliver(w, plan, output, rejected, value)) == FromPromiseFrame.erase(w) : R.World}

law redirect_path_resolves:
  for w: R.World
  for path: RedirectPaths.Route<w>
  for extra: Nat
  {Transactions.resolveLoop(Nat.add(RedirectPaths.depth(w, path), 1n+extra), w, RedirectPaths.origin(w, path)) == B.Bundle{w, RedirectPaths.terminal(w, path)} : B.Bundle<R.World, Nat>}

law redirect_public_resolves:
  for w: R.World
  for path: RedirectPaths.Route<w>
  for extra: Nat
  for room: {1n+B.length(R.Transaction, R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w, path), 1n+extra) : Nat}
  {Transactions.resolveTx(w, RedirectPaths.origin(w, path)) == B.Bundle{w, RedirectPaths.terminal(w, path)} : B.Bundle<R.World, Nat>}

law new_transaction_root:
  for w: R.World
  for lane: Bool
  for parent: Nat
  {R.Transaction.into(B.transaction(B.first(R.World, Nat, Transactions.newTransaction(w, lane, parent)), B.second(R.World, Nat, Transactions.newTransaction(w, lane, parent)))) == 0n : Nat}

law same_representative_merge:
  for w: R.World
  for source: Nat
  for target: Nat
  for root: Nat
  for first: {Transactions.resolveTx(w, source) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}
  for second: {Transactions.resolveTx(w, target) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}
  {Transactions.merge(w, source, target) == w : R.World}

law action_completion_representative:
  for w: R.World
  for id: Nat
  for root: Nat
  for remaining: Nat
  for resolution: {Transactions.resolveTx(w, R.ActionState.transaction(Action.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}
  for open: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}
  {Action.done(w, id) == B.schedule(B.store_transaction(w, root, R.Transaction.with_open(B.transaction(w, root), remaining))) : R.World}

law action_completion_route:
  for w: R.World
  for id: Nat
  for path: RedirectPaths.Route<w>
  for extra: Nat
  for remaining: Nat
  for captured: {R.ActionState.transaction(Action.get(w, id)) == RedirectPaths.origin(w, path) : Nat}
  for room: {1n+B.length(R.Transaction, R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w, path), 1n+extra) : Nat}
  for open: {R.Transaction.open(B.transaction(w, RedirectPaths.terminal(w, path))) == 1n+remaining : Nat}
  {Action.done(w, id) == B.schedule(B.store_transaction(w, RedirectPaths.terminal(w, path), R.Transaction.with_open(B.transaction(w, RedirectPaths.terminal(w, path)), remaining))) : R.World}

law transaction_rejoin_histories:
  for w: R.World
  for root: Nat
  for events: List<&2, RejoinHistories.RejoinEvent<w, root>>
  {RejoinHistories.run(w, root, events, w) == RejoinHistories.Audit{w, RejoinHistories.expected(w, root, events)} : RejoinHistories.Audit}

law distinct_transaction_join_world:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  {JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse) == JoinedPair.after(w, prefix, left, gap, right, suffix, reverse) : R.World}

law joined_source_resolves:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  {Transactions.resolveTx(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.sourceId(prefix, gap, reverse)) == B.Bundle{JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse)} : B.Bundle<R.World, Nat>}

law joined_target_resolves:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  {Transactions.resolveTx(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse)) == B.Bundle{JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse)} : B.Bundle<R.World, Nat>}

law joined_obligations:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  {R.Transaction.open(B.transaction(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse))) == JoinedPair.obligations(left, right, reverse) : Nat}

law joined_action_completion:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  for retired: Bool
  for id: Nat
  for remaining: Nat
  for captured: {R.ActionState.transaction(Action.get(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), id)) == JoinedAction.capturedId(prefix, gap, reverse, retired) : Nat}
  for positive: {JoinedPair.obligations(left, right, reverse) == 1n+remaining : Nat}
  {Action.done(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), id) == B.schedule(B.store_transaction(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse), R.Transaction.with_open(B.transaction(JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse), JoinedPair.targetId(prefix, gap, reverse)), remaining))) : R.World}

law action_open_allocated:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for before: List<&2, R.ActionState>
  for entry: R.ActionState
  for after: List<&2, R.ActionState>
  {Action.open(ActionOpening.scope(w, arena, before, entry, after), B.length(R.ActionState, before)) == ActionOpening.expected(w, arena, before, entry, after) : R.World}

law action_open_captured:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for before: List<&2, R.ActionState>
  for entry: R.ActionState
  for after: List<&2, R.ActionState>
  {Action.get(Action.open(ActionOpening.scope(w, arena, before, entry, after), B.length(R.ActionState, before)), B.length(R.ActionState, before)) == ActionOpening.updated(entry, 1n+B.length(R.Transaction, arena), OpeningQuestion.increment(R.World.questions(w))) : R.ActionState}

law action_open_obligation:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for before: List<&2, R.ActionState>
  for entry: R.ActionState
  for after: List<&2, R.ActionState>
  {B.transaction(Action.open(ActionOpening.scope(w, arena, before, entry, after), B.length(R.ActionState, before)), 1n+B.length(R.Transaction, arena)) == ActionOpening.record(1n, True{}) : R.Transaction}


law distinct_join_rejoin_histories:
  for w: R.World
  for prefix: List<&2, R.Transaction>
  for left: R.Transaction
  for gap: List<&2, R.Transaction>
  for right: R.Transaction
  for suffix: List<&2, R.Transaction>
  for reverse: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  {JoinedHistory.run(JoinedPair.sourceId(prefix, gap, reverse), JoinedPair.targetId(prefix, gap, reverse), events, JoinedPair.merged(w, prefix, left, gap, right, suffix, reverse)) == JoinedHistory.Audit{JoinedPair.after(w, prefix, left, gap, right, suffix, reverse), JoinedHistory.expected(JoinedPair.targetId(prefix, gap, reverse), events)} : JoinedHistory.Audit}

law constructed_action_opens:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for methods: R.Expr
  {ActionCreated.run(w, arena, cells, methods) == ActionCreated.expected(w, arena, cells, methods) : R.World}

law constructed_action_captured:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for methods: R.Expr
  {Action.get(ActionCreated.run(w, arena, cells, methods), 1n+B.length(R.ActionState, cells)) == ActionOpening.updated(ActionCreated.cell(w, methods), 1n+B.length(R.Transaction, arena), OpeningQuestion.increment(R.World.questions(w))) : R.ActionState}

law constructed_action_obligation:
  for w: R.World
  for arena: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for methods: R.Expr
  {B.transaction(ActionCreated.run(w, arena, cells, methods), 1n+B.length(R.Transaction, arena)) == ActionOpening.record(1n, True{}) : R.Transaction}

law action_pair_allocated_slots:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  {R.World.txArena(ActionPair.second(w, before, cells, first, other)) == B.blank_transaction() <> B.append(R.Transaction, before, [ActionOpening.record(1n, True{}), ActionOpening.record(1n, True{})]) : List<&2, R.Transaction>}

law action_pair_joined_open_count:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  {R.Transaction.open(B.transaction(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse))) == 2n : Nat}

law action_pair_first_completion:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for finishSecond: Bool
  {Action.done(ActionPair.joined(w, before, cells, first, other, reverse), ActionPair.idFor(w, before, cells, first, finishSecond)) == B.schedule(B.store_transaction(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse)), 1n))) : R.World}

law action_pair_rejoin_history:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  {JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse)) == JoinedHistory.Audit{ActionPair.joined(w, before, cells, first, other, reverse), JoinedHistory.expected(JoinedPair.targetId(before, [], reverse), events)} : JoinedHistory.Audit}

law action_pair_first_completion_after_history:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for finishSecond: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  {Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond)) == B.schedule(B.store_transaction(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse)), 1n))) : R.World}

law scheduling_preserves_action_ledger:
  for w: R.World
  {ScheduleFrame.ledger(B.schedule(w)) == ScheduleFrame.ledger(w) : ScheduleFrame.LedgerFrame}

law positive_transaction_blocks_exact_world:
  for w: R.World
  for tx: Nat
  for remaining: Nat
  for healthy: {B.ok(w) == True{} : Bool}
  for positive: {R.Transaction.open(B.transaction(w, tx)) == 1n+remaining : Nat}
  {Transactions.blocked(w, tx) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}

law constructed_action_pair_blocks:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for healthy: {B.ok(w) == True{} : Bool}
  {Transactions.blocked(ActionPair.joined(w, before, cells, first, other, reverse), JoinedPair.targetId(before, [], reverse)) == B.Bundle{ActionPair.joined(w, before, cells, first, other, reverse), True{}} : B.Bundle<R.World, Bool>}

law constructed_action_pair_history_blocks:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  for healthy: {B.ok(w) == True{} : Bool}
  {Transactions.blocked(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), JoinedPair.targetId(before, [], reverse)) == B.Bundle{ActionPair.joined(w, before, cells, first, other, reverse), True{}} : B.Bundle<R.World, Bool>}

law first_action_completion_still_blocks:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for finishSecond: Bool
  for healthy: {B.ok(w) == True{} : Bool}
  {Transactions.blocked(Action.done(ActionPair.joined(w, before, cells, first, other, reverse), ActionPair.idFor(w, before, cells, first, finishSecond)), JoinedPair.targetId(before, [], reverse)) == B.Bundle{Action.done(ActionPair.joined(w, before, cells, first, other, reverse), ActionPair.idFor(w, before, cells, first, finishSecond)), True{}} : B.Bundle<R.World, Bool>}

law first_action_completion_after_history_still_blocks:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for finishSecond: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  for healthy: {B.ok(w) == True{} : Bool}
  {Transactions.blocked(Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond)), JoinedPair.targetId(before, [], reverse)) == B.Bundle{Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond)), True{}} : B.Bundle<R.World, Bool>}


# Representative updates preserve the actual pair shape, routes and schedule.
law counted_pair_update_preserves_world:
  for w: R.World
  for before: List<&2, R.Transaction>
  for reverse: Bool
  for old: Nat
  for next: Nat
  {B.schedule(B.store_transaction(CountedPair.state(w, before, reverse, old), JoinedPair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(CountedPair.state(w, before, reverse, old), JoinedPair.targetId(before, [], reverse)), next))) == CountedPair.state(B.schedule(w), before, reverse, next) : R.World}

law counted_pair_original_source_resolves:
  for w: R.World
  for before: List<&2, R.Transaction>
  for reverse: Bool
  for count: Nat
  {Transactions.resolveTx(CountedPair.state(w, before, reverse, count), JoinedPair.sourceId(before, [], reverse)) == B.Bundle{CountedPair.state(w, before, reverse, count), JoinedPair.targetId(before, [], reverse)} : B.Bundle<R.World, Nat>}

# The certificate contains a complete World equality, rather than a supplied
# transition premise. Real constructors fill it for both completion orders.
law constructed_pair_both_completion_histories:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for second: Bool
  for initial: List<&2, JoinedHistory.JoinEvent>
  for middle: List<&2, JoinedHistory.JoinEvent>
  for final: List<&2, JoinedHistory.JoinEvent>
  PairCompletion.Completion<ActionPair.second(w, before, cells, first, other), before, reverse, PairCompletion.selectedId(cells, second), PairCompletion.selectedId(cells, Bool.not(second)), initial, middle, final>

law completed_pair_certificate_has_zero_debt:
  for w: R.World
  for before: List<&2, R.Transaction>
  for reverse: Bool
  for firstId: Nat
  for otherId: Nat
  for initial: List<&2, JoinedHistory.JoinEvent>
  for middle: List<&2, JoinedHistory.JoinEvent>
  for final: List<&2, JoinedHistory.JoinEvent>
  for certificate: PairCompletion.Completion<w, before, reverse, firstId, otherId, initial, middle, final>
  {R.Transaction.open(B.transaction(PairCompletion.run(Transactions.merge(w, JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final), JoinedPair.targetId(before, [], reverse))) == 0n : Nat}

law action_wait_marking_reaches_lookup:
  for waits: List<&2, R.ActionWait>
  for id: Nat
  {Action.find(Action.settleWait(waits, id), id) == WaitSettlement.mark(Action.find(waits, id)) : Maybe<&2, R.ActionWait>}

law settled_action_wait_stays_settled:
  for events: List<&2, WaitSettlement.WaitEdit>
  for waits: List<&2, R.ActionWait>
  for id: Nat
  for action: Nat
  for settled: Bool
  for found: {Action.find(waits, id) == Some{R.ActionWait{id, action, 0, settled}} : Maybe<&2, R.ActionWait>}
  {Action.find(WaitSettlement.run(events, Action.settleWait(waits, id)), id) == Some{R.ActionWait{id, action, 0, True{}}} : Maybe<&2, R.ActionWait>}

law settled_action_wait_history_rejects_duplicate:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for events: List<&2, WaitSettlement.WaitEdit>
  for waits: List<&2, R.ActionWait>
  for id: Nat
  for action: Nat
  for settled: Bool
  for rejected: Bool
  for value: R.Value
  for found: {Action.find(waits, id) == Some{R.ActionWait{id, action, 0, settled}} : Maybe<&2, R.ActionWait>}
  {Core.asyncActionDelivery(R.World.with_actionWaits(w, WaitSettlement.run(events, Action.settleWait(waits, id))), rest, stack, id, rejected, value, Action.find(WaitSettlement.run(events, Action.settleWait(waits, id)), id)) == Core.Machine{R.World.with_actionWaits(w, WaitSettlement.run(events, Action.settleWait(waits, id))), rest, stack} : Core.Machine}


law empty_ordinary_transaction_is_eligible:
  for w: R.World
  for tx: Nat
  for healthy: {B.ok(w) == True{} : Bool}
  for zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat}
  for empty: {R.Transaction.nodes(B.transaction(w, tx)) == [] : List<&2, Nat>}
  for ordinary: {R.Transaction.lane(B.transaction(w, tx)) == False{} : Bool}
  for noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}
  {Transactions.blocked(w, tx) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}

# Successful prefixes do not execute generator slices or create owned flights.
# The no-live-lanes and healthy initial state premises remain explicit.
law constructed_completed_pair_is_eligible:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for second: Bool
  for initial: List<&2, JoinedHistory.JoinEvent>
  for middle: List<&2, JoinedHistory.JoinEvent>
  for final: List<&2, JoinedHistory.JoinEvent>
  for healthy: {B.ok(w) == True{} : Bool}
  for noLanes: {R.LaneState.live(R.World.laneState(w)) == [] : List<&2, Nat>}
  PairEligibility.Eligibility<ActionPair.second(w, before, cells, first, other), before, reverse, PairCompletion.selectedId(cells, second), PairCompletion.selectedId(cells, Bool.not(second)), initial, middle, final>


law landing_scan_retains_positive_group:
  for w: R.World
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for frame: Core.SeamFrame
  for index: Nat
  for predecessor: Nat
  for remaining: Nat
  for lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == 1n+predecessor : Nat}
  for healthy: {B.ok(w) == True{} : Bool}
  for open: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 1n+remaining : Nat}
  {Core.landTransactions(w, rest, stack, frame, 1n+index) == Core.Machine{w, Core.LandTransactions{frame, index} <> rest, stack} : Core.Machine}

law first_action_completion_is_retained_by_landing_scan:
  for w: R.World
  for before: List<&2, R.Transaction>
  for cells: List<&2, R.ActionState>
  for first: R.Expr
  for other: R.Expr
  for reverse: Bool
  for finishSecond: Bool
  for events: List<&2, JoinedHistory.JoinEvent>
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  for frame: Core.SeamFrame
  for index: Nat
  for healthy: {B.ok(w) == True{} : Bool}
  for lookup: {B.get(Nat, R.World.transactions(Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond))), index, 0n) == JoinedPair.targetId(before, [], reverse) : Nat}
  LandingScan.Retained<Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond)), rest, stack, frame, index>


law terminal_node_membership_preserves_world:
  for +w: R.World
  for +id: Nat
  for +owner: Nat
  for +captured: {R.NodeExtension.transaction(B.extension(w, id)) == owner : Nat}
  for stopped: {R.Transaction.into(B.transaction(w, owner)) == 0n : Nat}
  {Transactions.txOf(w, id) == B.Bundle{w, owner} : B.Bundle<R.World, Nat>}


law zero_action_rendered_group_still_blocks:
  for +w: R.World
  for +predecessor: Nat
  for +prefix: RenderedGraph.Skips<PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor>
  for +id: Nat
  for +tail: List<&2, Nat>
  for healthy: {B.ok(w) == True{} : Bool}
  for zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat}
  for nodes: {R.Transaction.nodes(B.transaction(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor)) == B.append(Nat, RenderedGraph.ids(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor, prefix), id <> tail) : List<&2, Nat>}
  for active: {RenderedGraph.guard(PositiveBlocker.enter(w, 1n+predecessor), id) == False{} : Bool}
  for +capture: {R.NodeExtension.transaction(B.extension(PositiveBlocker.enter(w, 1n+predecessor), id)) == 1n+predecessor : Nat}
  for stopped: {R.Transaction.into(B.transaction(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor)) == 0n : Nat}
  for rendered: {Transactions.isRender(R.Node.kind(B.node(PositiveBlocker.enter(w, 1n+predecessor), id))) == True{} : Bool}
  for live: {B.has(R.Node.flags(B.node(PositiveBlocker.enter(w, 1n+predecessor), id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}
  {Transactions.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}


law live_pending_subscriber_blocks:
  for +w: R.World
  for +edge: Nat
  for +owner: Nat
  for +extra: Nat
  for valid: {RenderedGraph.validReader(w, 1n+edge) == True{} : Bool}
  for live: {B.has(R.Node.flags(B.node(w, R.Link.sub(B.link(w, 1n+edge)))), K.REACTIVE_ZOMBIE()) == False{} : Bool}
  {Transactions.blockedSubs(1n+extra, w, 1n+edge, owner) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}


law current_generation_pending_reader_is_valid:
  for +w: R.World
  for +edge: Nat
  for reads: {RenderedGraph.reader(w, edge) == True{} : Bool}
  for generation: {R.Link.gen(B.link(w, edge)) == R.Node.depGen(B.node(w, R.Link.sub(B.link(w, edge)))) : Nat}
  for alive: {B.has(R.Node.flags(B.node(w, R.Link.sub(B.link(w, edge)))), K.REACTIVE_DISPOSED()) == False{} : Bool}
  {RenderedGraph.validReader(w, edge) == True{} : Bool}


law rendered_flight_is_retained_by_landing_scan:
  for +w: R.World
  for +predecessor: Nat
  for +prefix: RenderedGraph.Skips<PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor>
  for +id: Nat
  for +tail: List<&2, Nat>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +frame: Core.SeamFrame
  for +index: Nat
  for lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == 1n+predecessor : Nat}
  for healthy: {B.ok(w) == True{} : Bool}
  for zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat}
  for nodes: {R.Transaction.nodes(B.transaction(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor)) == B.append(Nat, RenderedGraph.ids(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor, prefix), id <> tail) : List<&2, Nat>}
  for active: {RenderedGraph.guard(PositiveBlocker.enter(w, 1n+predecessor), id) == False{} : Bool}
  for capture: {R.NodeExtension.transaction(B.extension(PositiveBlocker.enter(w, 1n+predecessor), id)) == 1n+predecessor : Nat}
  for stopped: {R.Transaction.into(B.transaction(PositiveBlocker.enter(w, 1n+predecessor), 1n+predecessor)) == 0n : Nat}
  for rendered: {Transactions.isRender(R.Node.kind(B.node(PositiveBlocker.enter(w, 1n+predecessor), id))) == True{} : Bool}
  for live: {B.has(R.Node.flags(B.node(PositiveBlocker.enter(w, 1n+predecessor), id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}
  {Core.landTransactions(w, rest, stack, frame, 1n+index) == Core.Machine{w, Core.LandTransactions{frame, index} <> rest, stack} : Core.Machine}


law completion_prefix_preserves_graph:
  for +w: R.World
  for +id: Nat
  for +root: Nat
  for +remaining: Nat
  for resolution: {Transactions.resolveTx(w, R.ActionState.transaction(Action.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}
  for positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}
  {CompletionGraphFrame.graph(Action.done(w, id)) == CompletionGraphFrame.graph(w) : CompletionGraphFrame.GraphFrame}


law allocated_completion_retains_owned_work:
  for +w: R.World
  for +before: List<&2, R.Transaction>
  for +record: R.Transaction
  for +after: List<&2, R.Transaction>
  for +id: Nat
  for +remaining: Nat
  for captured: {R.ActionState.transaction(Action.get(AllocatedTransactions.scope(w, before, record, after), id)) == B.length(R.Transaction, before) : Nat}
  for stopped: {R.Transaction.into(record) == 0n : Nat}
  for positive: {R.Transaction.open(record) == 1n+remaining : Nat}
  {Action.done(AllocatedTransactions.scope(w, before, record, after), id) == OwnedCompletion.expected(w, before, record, after, remaining) : R.World}


law completion_preserves_pending_rendered_snapshot:
  for +w: R.World
  for +id: Nat
  for +root: Nat
  for +remaining: Nat
  for snapshot: PendingRendered.Pending<w, root>
  for +resolution: {Transactions.resolveTx(w, R.ActionState.transaction(Action.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}
  for +positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}
  PendingRendered.Pending<Action.done(w, id), root>


law pending_rendered_completion_history:
  for +w: R.World
  for +predecessor: Nat
  for +programme: RenderedHistory.Programme<w, 1n+predecessor>
  for snapshot: PendingRendered.Pending<w, 1n+predecessor>
  for healthy: {B.ok(w) == True{} : Bool}
  RenderedHistory.Certified<w, 1n+predecessor, programme>


law rendered_completion_history_preserves_graph:
  for +w: R.World
  for +root: Nat
  for +programme: RenderedHistory.Programme<w, root>
  for certificate: RenderedHistory.Certified<w, root, programme>
  {CompletionGraphFrame.graph(RenderedHistory.world(RenderedHistory.run(w, root, programme, w))) == CompletionGraphFrame.graph(w) : CompletionGraphFrame.GraphFrame}


law rendered_completion_history_checks_hold:
  for +w: R.World
  for +root: Nat
  for +programme: RenderedHistory.Programme<w, root>
  for certificate: RenderedHistory.Certified<w, root, programme>
  {RenderedHistory.all(RenderedHistory.answers(RenderedHistory.run(w, root, programme, w))) == True{} : Bool}


law fresh_list_captures_and_appends:
  for +w: R.World
  for +id: Nat
  for +predecessor: Nat
  for +slot: Nat
  for allocated: {R.Node.x(B.node(w, id)) == 1n+slot : Nat}
  for unowned: {R.NodeExtension.transaction(B.extension(w, id)) == 0n : Nat}
  {Transactions.list(w, id, 1n+predecessor) == ListConstruction.raw(w, id, 1n+predecessor) : R.World}


law fresh_list_constructs_pending_rendered_snapshot:
  for +w: R.World
  for +id: Nat
  for +before: List<&2, R.Transaction>
  for +record: R.Transaction
  for +after: List<&2, R.Transaction>
  for +extBefore: List<&2, R.NodeExtension>
  for +extRecord: R.NodeExtension
  for +extAfter: List<&2, R.NodeExtension>
  for +prefix: RenderedGraph.Skips<w, 1n+B.length(R.Transaction, before)>
  for storage: {R.World.txArena(w) == B.blank_transaction() <> B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}
  for +index: {R.Node.x(B.node(w, id)) == 1n+B.length(R.NodeExtension, extBefore) : Nat}
  for +extStorage: {R.World.extensions(w) == B.blank_extension() <> B.append(R.NodeExtension, extBefore, extRecord <> extAfter) : List<&2, R.NodeExtension>}
  for unowned: {R.NodeExtension.transaction(extRecord) == 0n : Nat}
  for owns: {R.Transaction.nodes(record) == RenderedGraph.ids(w, 1n+B.length(R.Transaction, before), prefix) : List<&2, Nat>}
  for active: {RenderedGraph.guard(w, id) == False{} : Bool}
  for stopped: {R.Transaction.into(record) == 0n : Nat}
  for rendered: {Transactions.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool}
  for live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}
  PendingRendered.Pending<Transactions.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before)>


law fresh_list_enters_pending_rendered_history:
  for +w: R.World
  for +id: Nat
  for +before: List<&2, R.Transaction>
  for +record: R.Transaction
  for +after: List<&2, R.Transaction>
  for +extBefore: List<&2, R.NodeExtension>
  for +extRecord: R.NodeExtension
  for +extAfter: List<&2, R.NodeExtension>
  for +prefix: RenderedGraph.Skips<w, 1n+B.length(R.Transaction, before)>
  for storage: {R.World.txArena(w) == B.blank_transaction() <> B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}
  for +index: {R.Node.x(B.node(w, id)) == 1n+B.length(R.NodeExtension, extBefore) : Nat}
  for +extStorage: {R.World.extensions(w) == B.blank_extension() <> B.append(R.NodeExtension, extBefore, extRecord <> extAfter) : List<&2, R.NodeExtension>}
  for +unowned: {R.NodeExtension.transaction(extRecord) == 0n : Nat}
  for owns: {R.Transaction.nodes(record) == RenderedGraph.ids(w, 1n+B.length(R.Transaction, before), prefix) : List<&2, Nat>}
  for active: {RenderedGraph.guard(w, id) == False{} : Bool}
  for stopped: {R.Transaction.into(record) == 0n : Nat}
  for rendered: {Transactions.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool}
  for live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}
  for +healthy: {B.ok(w) == True{} : Bool}
  for +programme: RenderedHistory.Programme<Transactions.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before)>
  RenderedHistory.Certified<Transactions.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before), programme>


law same_capture_list_is_exact_identity:
  for +w: R.World
  for +id: Nat
  for +tx: Nat
  for +slot: Nat
  for allocated: {R.Node.x(B.node(w, id)) == 1n+slot : Nat}
  for capture: {R.NodeExtension.transaction(B.extension(w, id)) == tx : Nat}
  {Transactions.list(w, id, tx) == w : R.World}


law heap_marking_preserves_committed_observation:
  for +fuel: Nat
  for +w: R.World
  for +work: List<&2, RuntimeHeap.Mark>
  {CommittedStorage.observe(RuntimeHeap.mark_work(fuel, w, work)) == CommittedStorage.observe(w) : CommittedStorage.View}


law staging_preserves_committed_observation:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  {CommittedStorage.observe(RuntimeWrites.stageResolved(w, id, value)) == CommittedStorage.observe(w) : CommittedStorage.View}


law resolved_setter_preserves_committed_observation:
  for +w: R.World
  for +id: Nat
  for +current: R.Value
  for +value: R.Value
  {CommittedStorage.observe(RuntimeWrites.setResolved(w, id, current, value)) == CommittedStorage.observe(w) : CommittedStorage.View}


law ordinary_core_setter_preserves_committed_observation:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +current: R.Value
  for +value: R.Value
  for override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  for custom: {Equality.custom(w, id) == 0n : Nat}
  {CommittedStorage.observe(Core.world(Core.setResolved(w, rest, stack, id, current, value))) == CommittedStorage.observe(w) : CommittedStorage.View}


law ordinary_core_setter_returns_resolved_argument:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +current: R.Value
  for +value: R.Value
  for override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  for custom: {Equality.custom(w, id) == 0n : Nat}
  {Core.values(Core.setResolved(w, rest, stack, id, current, value)) == value <> stack : List<&2, R.Value>}


law staging_write_history_preserves_committed_observation:
  for +writes: List<&2, StagingHistory.Write>
  for +w: R.World
  {CommittedStorage.observe(StagingHistory.run(writes, w)) == CommittedStorage.observe(w) : CommittedStorage.View}


law flight_status_landing_preserves_committed_observation:
  for +w: R.World
  for +id: Nat
  for +clearUninitialized: Bool
  {CommittedStorage.observe(RuntimePending.landStatus(w, id, clearUninitialized)) == CommittedStorage.observe(w) : CommittedStorage.View}


law flight_write_prefix_preserves_committed_observation:
  for +w: R.World
  for +id: Nat
  for +result: Nat
  for +value: R.Value
  {CommittedStorage.observe(B.first(R.World, Bool, RuntimeFlight.beginAsyncWrite(w, id, result, value))) == CommittedStorage.observe(w) : CommittedStorage.View}


law stale_flight_prefix_is_exact_identity:
  for +w: R.World
  for +id: Nat
  for +result: Nat
  for obsolete: {Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result) == True{} : Bool}
  {RuntimeFlight.prepareAsyncWrite(w, id, result) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}


law ordinary_async_prefix_keeps_source_branch:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +result: Nat
  for +value: R.Value
  for +then: List<&2, Core.Task>
  for custom: {Equality.custom(w, id) == 0n : Nat}
  for override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  {Core.asyncWrite(w, rest, stack, id, result, value, then) == AsyncPrefix.fast(w, rest, stack, id, result, value, then) : Core.Machine}


law ordinary_async_prefix_preserves_committed_observation:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +result: Nat
  for +value: R.Value
  for +then: List<&2, Core.Task>
  for custom: {Equality.custom(w, id) == 0n : Nat}
  for override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  {CommittedStorage.observe(Core.world(Core.asyncWrite(w, rest, stack, id, result, value, then))) == CommittedStorage.observe(w) : CommittedStorage.View}


law ordinary_async_prefix_preserves_caller_stack:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +values: List<&2, R.Value>
  for +id: Nat
  for +result: Nat
  for +value: R.Value
  for +then: List<&2, Core.Task>
  for custom: {Equality.custom(w, id) == 0n : Nat}
  for override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  {Core.values(Core.asyncWrite(w, rest, values, id, result, value, then)) == values : List<&2, R.Value>}


law async_prefix_queues_exact_followup_order:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +then: List<&2, Core.Task>
  {Core.asyncWriteAfterValue(w, rest, stack, id, then) == B.choose(~Core.Machine, Bool.not(B.present(R.Node.pending(B.node(w, id)))),
    _ => Core.Machine{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), Core.OwnerTasks{[RuntimeOwner.TrimDeps{id}]} <> AsyncPrefix.ending(id, then, rest), stack},
    _ => Core.Machine{w, AsyncPrefix.ending(id, then, rest), stack}) : Core.Machine}


law present_source_removal_retains_distinct_target:
  for +xs: List<&2, Nat>
  for +removed: Nat
  for +kept: Nat
  for removedLocation: LiveMembership.Located<xs, removed>
  for keptLocation: LiveMembership.Located<xs, kept>
  for different: {Nat.is_eq(kept, removed) == False{} : Bool}
  LiveMembership.Located<Transactions.removeIdentity(xs, removed), kept>


law constructed_joined_representative_is_live:
  for +w: R.World
  for +before: List<&2, R.Transaction>
  for +cells: List<&2, R.ActionState>
  for +first: R.Expr
  for +other: R.Expr
  for +reverse: Bool
  LiveMembership.Located<R.World.transactions(ActionPair.joined(w, before, cells, first, other, reverse)), JoinedPair.targetId(before, [], reverse)>


law completion_prefix_preserves_live_list:
  for +w: R.World
  for +id: Nat
  {R.World.transactions(Action.done(w, id)) == R.World.transactions(w) : List<&2, Nat>}


law constructed_first_completion_derives_scan_selection:
  for +w: R.World
  for +before: List<&2, R.Transaction>
  for +cells: List<&2, R.ActionState>
  for +first: R.Expr
  for +other: R.Expr
  for +reverse: Bool
  for +finishSecond: Bool
  for +events: List<&2, JoinedHistory.JoinEvent>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +frame: Core.SeamFrame
  for healthy: {B.ok(w) == True{} : Bool}
  ConstructedScan.Selected<Action.done(JoinedHistory.world(JoinedHistory.run(JoinedPair.sourceId(before, [], reverse), JoinedPair.targetId(before, [], reverse), events, ActionPair.joined(w, before, cells, first, other, reverse))), ActionPair.idFor(w, before, cells, first, finishSecond)), JoinedPair.targetId(before, [], reverse), rest, stack, frame>


law rendered_completion_history_preserves_live_list:
  for +w: R.World
  for +root: Nat
  for +programme: RenderedHistory.Programme<w, root>
  for certificate: RenderedHistory.Certified<w, root, programme>
  {R.World.transactions(RenderedHistory.world(RenderedHistory.run(w, root, programme, w))) == R.World.transactions(w) : List<&2, Nat>}


law rendered_completion_history_retains_live_occurrence:
  for +w: R.World
  for +root: Nat
  for +programme: RenderedHistory.Programme<w, root>
  for certificate: RenderedHistory.Certified<w, root, programme>
  for location: LiveMembership.Located<R.World.transactions(w), root>
  LiveMembership.Located<R.World.transactions(RenderedHistory.world(RenderedHistory.run(w, root, programme, w))), root>


law rendered_completion_history_derives_held_scan:
  for +w: R.World
  for +predecessor: Nat
  for +programme: RenderedHistory.Programme<w, 1n+predecessor>
  for +certificate: RenderedHistory.Certified<w, 1n+predecessor, programme>
  for location: LiveMembership.Located<R.World.transactions(w), 1n+predecessor>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +frame: Core.SeamFrame
  ConstructedScan.Selected<RenderedHistory.world(RenderedHistory.run(w, 1n+predecessor, programme, w)), 1n+predecessor, rest, stack, frame>


law deferred_result_return_closes_protocol_catch:
  for cell: Nat
  for open: Bool
  for saved: List<&2, R.Value>
  for rest: List<&2, Core.Task>
  {Core.deferredReturned(Core.DeferredCatch{cell, open, saved} <> rest) == rest : List<&2, Core.Task>}

law deferred_protocol_throw_uses_shared_source_catch:
  for w: R.World
  for cell: Nat
  for open: Bool
  for saved: List<&2, R.Value>
  for rest: List<&2, Core.Task>
  for stack: List<&2, R.Value>
  {Core.unwind(w, Core.DeferredCatch{cell, open, saved} <> rest, stack) == Core.deferredUnwind(w, rest, cell, open, saved, R.World.fault(w)) : Core.Machine}


law pending_step_preserves_arbitrary_caller_stack:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {Core.values(Core.step(Core.Machine{w, Core.PendingTasks{tasks, visited, released, scheduled} <> rest, stack})) == stack : List<&2, R.Value>}


law async_settlement_step_preserves_caller_stack:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {Core.values(Core.step(Core.Machine{w, Core.AsyncWriteAfterTrim{id} <> rest, stack})) == stack : List<&2, R.Value>}


law async_schedule_step_preserves_caller_stack:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {Core.values(Core.step(Core.Machine{w, Core.AsyncWriteSchedule{} <> rest, stack})) == stack : List<&2, R.Value>}


law async_after_trim_uses_exact_self_settlement:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  {Core.dispatch(w, Core.AsyncWriteAfterTrim{id} <> rest, stack) == Core.pendingResume(rest, stack, RuntimePending.beginSettlement(w, id, id)) : Core.Machine}


law empty_pending_queue_returns_exact_caller:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {Core.step(Core.Machine{w, Core.PendingTasks{[], visited, released, scheduled} <> rest, stack}) == Core.Machine{w, rest, stack} : Core.Machine}


law pending_release_keeps_its_captured_continuation:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +index: Nat
  for +tail: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {Core.pendingTasks(w, rest, stack, RuntimePending.Release{index} <> tail, visited, released, scheduled) ==
    B.choose(~Core.Machine, Nat.is_ge(index, B.length(Nat, released)),
      _ => Core.Machine{w, Core.PendingTasks{tail, visited, released, scheduled} <> rest, stack},
      _ =>
        +id = B.get(Nat, released, index, 0n)
        +again = {Core.PendingTasks{RuntimePending.Release{1n+index} <> tail, visited, released, scheduled} <> rest : List<&2, Core.Task>}
        Core.Machine{w, B.choose(~List<&2, Core.Task>, RuntimePending.releasable(w, id), _ => Core.OwnerTasks{[RuntimeOwner.Unobserved{id}]} <> again, _ => again), stack}) : Core.Machine}


law settlement_prefix_is_actual_core_iteration:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +actual: Core.Machine
  {PendingHistory.run(scope, programme, actual) == PendingHistory.iterate(PendingHistory.height(scope, programme), actual) : Core.Machine}


law settlement_prefix_preserves_caller_stack_by_induction:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  {Core.values(PendingHistory.iterate(PendingHistory.height(scope, programme), scope)) == Core.values(scope) : List<&2, R.Value>}


law nonempty_settlement_schedule_prefix_is_constructed:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  PendingHistory.Programme<PendingHistory.input(w, Core.AsyncWriteSchedule{} <> rest, stack, PendingHistory.Pending{[], visited, released, scheduled})>


law constructed_settlement_schedule_prefix_has_two_actual_steps:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {PendingHistory.height(PendingHistory.input(w, Core.AsyncWriteSchedule{} <> rest, stack, PendingHistory.Pending{[], visited, released, scheduled}), PendingHistory.emptyThenSchedule(w, rest, stack, visited, released, scheduled)) == 2n : Nat}


law owner_bookkeeping_step_preserves_caller_stack:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +tasks: List<&2, RuntimeOwner.Task>
  for +allowed: {OwnerContinuation.neutralHead(tasks) == True{} : Bool}
  {Core.values(Core.step(Core.Machine{w, Core.OwnerTasks{tasks} <> rest, stack})) == stack : List<&2, R.Value>}


law no_stale_owner_trim_completes_in_two_core_steps:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +edge: {OwnerContinuation.staleEdge(w, id) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {Core.step(Core.step(Core.Machine{w, Core.OwnerTasks{[RuntimeOwner.TrimDeps{id}]} <> rest, stack})) == Core.Machine{w, rest, stack} : Core.Machine}


law no_stale_owner_trim_prefix_is_constructed:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +edge: {OwnerContinuation.staleEdge(w, id) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  PendingHistory.Programme<PendingHistory.input(w, rest, stack, PendingHistory.OwnerWork{[RuntimeOwner.TrimDeps{id}], {==}})>


law constructed_owner_trim_prefix_has_two_actual_steps:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +edge: {OwnerContinuation.staleEdge(w, id) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {PendingHistory.height(PendingHistory.input(w, rest, stack, PendingHistory.OwnerWork{[RuntimeOwner.TrimDeps{id}], {==}}), PendingHistory.ownerTrimPrefix(w, rest, stack, id, edge, healthy)) == 2n : Nat}


law selected_text_update_exposes_the_actual_payload:
  for +renderers: List<&2, Nat>
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  {RenderedView.shownTexts(RenderedView.observe(renderers, [id], RenderedTree.setText(w, id, value))) == [value] : List<&2, R.Value>}


law selected_application_event_is_retained:
  for +targets: List<&2, Nat>
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +previous: R.Value
  {RenderedView.shownApplications(RenderedView.observe([id], targets, B.event(w, R.Applied{id, value, previous}))) == B.append(R.TraceEvent, RenderedView.shownApplications(RenderedView.observe([id], targets, w)), [R.Applied{id, value, previous}]) : List<&2, R.TraceEvent>}


law foreign_text_target_retains_selected_observation:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +absent: {B.contains(targets, id) == False{} : Bool}
  {RenderedView.observe(renderers, targets, RenderedTree.setText(w, id, value)) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law foreign_application_retains_selected_observation:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +previous: R.Value
  for +absent: {B.contains(renderers, id) == False{} : Bool}
  {RenderedView.observe(renderers, targets, B.event(w, R.Applied{id, value, previous})) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law node_storage_alone_does_not_publish_selected_text:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +id: Nat
  for +node: R.Node
  {RenderedView.observe(renderers, targets, B.store_node(w, id, node)) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law committed_storage_frame_implies_selected_frame:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +next: R.World
  for +same: {CommittedStorage.observe(next) == CommittedStorage.observe(w) : CommittedStorage.View}
  {RenderedView.observe(renderers, targets, next) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law independent_actual_apply_step_retains_selected_observation:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +absentRenderer: {B.contains(renderers, id) == False{} : Bool}
  for +absentTarget: {B.contains(targets, R.Node.target(B.node(w, id))) == False{} : Bool}
  {RenderedView.observe(renderers, targets, Core.world(Core.step(Core.Machine{w, Core.ApplyEffect{id} <> rest, stack}))) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law ordinary_async_arrival_retains_selected_observation:
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +id: Nat
  for +result: Nat
  for +value: R.Value
  for +then: List<&2, Core.Task>
  for +custom: {Equality.custom(w, id) == 0n : Nat}
  for +override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}
  {RenderedView.observe(renderers, targets, Core.world(Core.asyncWrite(w, rest, stack, id, result, value, then))) == RenderedView.observe(renderers, targets, w) : RenderedView.View}


law actual_core_run_splits_at_step_prefix:
  for +length: Nat
  for +remaining: Nat
  for +machine: Core.Machine
  {Core.run(Nat.add(length, remaining), machine) == Core.run(remaining, PendingHistory.iterate(length, machine)) : Core.Machine}


law actual_core_zero_fuel_exhaustion_is_explicit:
  for +w: R.World
  for +head: Core.Task
  for +tail: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {Core.run(0n, Core.Machine{w, head <> tail, stack}) == Core.Machine{R.World.with_fault(w, R.Exhausted{}), [], []} : Core.Machine}


law pending_source_removal_retains_nodes_links_fault:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  {RemovalFootprint.observe(B.first(R.World, Bool, PendingState.removePendingSource(w, id, source))) == RemovalFootprint.observe(w) : RemovalFootprint.View}


law empty_subscriber_settlement_returns_caller_in_six_steps:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {PendingHistory.iterate(6n, EmptySettlement.start(w, id, rest, stack)) == Core.Machine{B.schedule(EmptySettlement.after(w, id)), rest, stack} : Core.Machine}


law empty_subscriber_settlement_composes_with_actual_run:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +remaining: Nat
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {Core.run(Nat.add(6n, remaining), EmptySettlement.start(w, id, rest, stack)) == Core.run(remaining, Core.Machine{B.schedule(EmptySettlement.after(w, id)), rest, stack}) : Core.Machine}


law empty_subscriber_settlement_preserves_committed_observation:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {CommittedStorage.observe(Core.world(PendingHistory.iterate(6n, EmptySettlement.start(w, id, rest, stack)))) == CommittedStorage.observe(w) : CommittedStorage.View}


law empty_subscriber_settlement_remains_healthy:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {B.ok(Core.world(PendingHistory.iterate(6n, EmptySettlement.start(w, id, rest, stack)))) == True{} : Bool}


law empty_subscriber_settlement_prefix_is_constructed:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  PendingHistory.Programme<EmptySettlement.start(w, id, rest, stack)>


law constructed_empty_subscriber_prefix_has_six_steps:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {PendingHistory.height(EmptySettlement.start(w, id, rest, stack), EmptySettlement.programme(w, id, rest, stack, noSubscribers, healthy)) == 6n : Nat}


law actual_settled_node_retains_committed_observation:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  for +id: Nat
  for +root: Nat
  for +source: Nat
  {CommittedStorage.observe(SettlementFrame.world(RuntimePending.settled(w, tasks, visited, released, scheduled, id, root, source))) == CommittedStorage.observe(w) : CommittedStorage.View}


law actual_pending_traversal_retains_committed_observation:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {CommittedStorage.observe(SettlementFrame.world(RuntimePending.advance(w, tasks, visited, released, scheduled))) == CommittedStorage.observe(w) : CommittedStorage.View}


law actual_core_pending_step_retains_committed_observation:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {CommittedStorage.observe(Core.world(Core.step(Core.Machine{w, Core.PendingTasks{tasks, visited, released, scheduled} <> rest, stack}))) == CommittedStorage.observe(w) : CommittedStorage.View}


law callback_free_settlement_history_retains_committed_observation:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +allowed: {SettlementHistory.bodyOnly(scope, programme) == True{} : Bool}
  {CommittedStorage.observe(Core.world(PendingHistory.iterate(PendingHistory.height(scope, programme), scope))) == CommittedStorage.observe(Core.world(scope)) : CommittedStorage.View}


law callback_free_settlement_history_retains_selected_observation:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +allowed: {SettlementHistory.bodyOnly(scope, programme) == True{} : Bool}
  for +renderers: List<&2, Nat>
  for +targets: List<&2, Nat>
  {RenderedView.observe(renderers, targets, Core.world(PendingHistory.iterate(PendingHistory.height(scope, programme), scope))) == RenderedView.observe(renderers, targets, Core.world(scope)) : RenderedView.View}


law constructed_empty_subscriber_prefix_is_content_safe:
  for +w: R.World
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +healthy: {B.ok(w) == True{} : Bool}
  {SettlementHistory.bodyOnly(EmptySettlement.start(w, id, rest, stack), EmptySettlement.programme(w, id, rest, stack, noSubscribers, healthy)) == True{} : Bool}


law actual_pending_traversal_retains_subscriber_topology:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {SubscriberShape.observe(PendingTopology.world(RuntimePending.advance(w, tasks, visited, released, scheduled))) == SubscriberShape.observe(w) : SubscriberShape.View}


law actual_core_pending_step_retains_subscriber_topology:
  for +w: R.World
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  {SubscriberShape.observe(Core.world(Core.step(Core.Machine{w, Core.PendingTasks{tasks, visited, released, scheduled} <> rest, stack}))) == SubscriberShape.observe(w) : SubscriberShape.View}


law callback_free_settlement_history_retains_subscriber_topology:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +allowed: {SettlementHistory.bodyOnly(scope, programme) == True{} : Bool}
  {SubscriberShape.observe(Core.world(PendingHistory.iterate(PendingHistory.height(scope, programme), scope))) == SubscriberShape.observe(Core.world(scope)) : SubscriberShape.View}


law callback_free_settlement_history_retains_selected_subscriber_shape:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +allowed: {SettlementHistory.bodyOnly(scope, programme) == True{} : Bool}
  for +id: Nat
  {SubscriberShape.shape(B.node(Core.world(PendingHistory.iterate(PendingHistory.height(scope, programme), scope)), id)) == SubscriberShape.shape(B.node(Core.world(scope), id)) : SubscriberShape.Shape}


law callback_free_settlement_history_retains_selected_link:
  for +scope: Core.Machine
  for +programme: PendingHistory.Programme<scope>
  for +allowed: {SettlementHistory.bodyOnly(scope, programme) == True{} : Bool}
  for +edge: Nat
  {B.link(Core.world(PendingHistory.iterate(PendingHistory.height(scope, programme), scope)), edge) == B.link(Core.world(scope), edge) : R.Link}


law settled_non_autodisposed_node_retains_prior_release_list:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  for +id: Nat
  for +root: Nat
  for +source: Nat
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  {PendingMachine.releases(RuntimePending.settled(w, tasks, visited, released, scheduled, id, root, source)) == released : List<&2, Nat>}


law settled_leaf_derives_its_actual_pending_machine_shape:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  for +id: Nat
  for +root: Nat
  for +source: Nat
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  {RuntimePending.settled(w, tasks, visited, released, scheduled, id, root, source) == RuntimePending.Machine{PendingMachine.world(RuntimePending.settled(w, tasks, visited, released, scheduled, id, root, source)), RuntimePending.Walk{0n, root, source} <> tasks, id <> visited, released, PendingMachine.scheduled(RuntimePending.settled(w, tasks, visited, released, scheduled, id, root, source))} : RuntimePending.Machine}


law actual_leaf_visit_next_control_is_constructed:
  for +w: R.World
  for +tasks: List<&2, RuntimePending.Task>
  for +visited: List<&2, Nat>
  for +released: List<&2, Nat>
  for +scheduled: Bool
  for +id: Nat
  for +root: Nat
  for +source: Nat
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  VisitControl.Next<VisitControl.observe(RuntimePending.advance(w, RuntimePending.Visit{id, root, source} <> tasks, visited, released, scheduled)), tasks, released, root, source>


law one_edge_settlement_bounded_return_is_constructed:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}
  for +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}
  for +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  BoundedReturn.Returned<OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n>


law one_edge_settlement_retains_committed_observation:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}
  for +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}
  for +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n, OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))) == CommittedStorage.observe(w) : CommittedStorage.View}


law one_edge_settlement_uses_remaining_actual_driver_fuel:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}
  for +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}
  for +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  for +remaining: Nat
  {Core.run(Nat.add(BoundedReturn.steps(OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n, OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), remaining), OneEdgeReturn.start(w, root, rest, stack)) == Core.run(remaining, Core.Machine{BoundedReturn.world(OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n, OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), rest, stack}) : Core.Machine}


law no_stale_trimmed_one_edge_return_is_constructed:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}
  for +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}
  for +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  for +noStale: {OwnerContinuation.staleEdge(w, root) == 0n : Nat}
  BoundedReturn.Returned<OneEdgeReturn.trimmed(w, root, rest, stack), rest, stack, 12n>


law one_edge_leaf_suffix_completes_in_seven_healthy_steps:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +visited: List<&2, Nat>
  for +scheduled: Bool
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +ready: {B.ok(w) == True{} : Bool}
  for +end: {R.Link.nextSub(B.link(w, edge)) == 0n : Nat}
  {PendingHistory.iterate(7n, LeafReturn.start(w, edge, root, visited, scheduled, rest, stack)) == Core.Machine{B.schedule(LeafReturn.endWorld(w, scheduled)), rest, stack} : Core.Machine}


law one_edge_leaf_suffix_fault_unwinds_in_two_steps:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +visited: List<&2, Nat>
  for +scheduled: Bool
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +broken: {B.ok(w) == False{} : Bool}
  {PendingHistory.iterate(2n, LeafReturn.start(w, edge, root, visited, scheduled, rest, stack)) == Core.Machine{w, rest, stack} : Core.Machine}


law one_edge_return_room_is_derived:
  for +w: R.World
  for +edge: Nat
  for +root: Nat
  for +id: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat}
  for +selected: {R.Link.sub(B.link(w, 1n+edge)) == id : Nat}
  for +end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  {Nat.add(BoundedReturn.steps(OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n, OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)), BoundedReturn.slack(OneEdgeReturn.start(w, root, rest, stack), rest, stack, 10n, OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto))) == 10n : Nat}


law existing_slot_node_update_reads_written_record:
  for +w: R.World
  for +id: Nat
  for +value: R.Node
  for +room: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}
  {B.node(B.store_node(w, id, value), id) == value : R.Node}


law different_node_update_retains_other_record:
  for +w: R.World
  for +write: Nat
  for +read: Nat
  for +value: R.Node
  for +different: {Nat.is_eq(read, write) == False{} : Bool}
  {B.node(B.store_node(w, write, value), read) == B.node(w, read) : R.Node}


law fresh_graph_link_uses_actual_empty_tail_allocation:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}
  for +deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}
  for +empty: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}
  {RuntimeGraph.link(w, root, leaf) == RuntimeGraph.allocate(w, root, leaf, 0n, 0n, 0n) : R.World}


law fresh_graph_allocation_constructs_one_edge_shape:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +healthy: {B.ok(w) == True{} : Bool}
  for +validRoot: {B.valid(w, root) == True{} : Bool}
  for +validLeaf: {B.valid(w, leaf) == True{} : Bool}
  for +different: {Nat.is_eq(leaf, root) == False{} : Bool}
  for +positive: {GraphAllocation.index(w) == 1n+edge : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  GraphAllocated.OneEdge<GraphAllocation.source(w, root, leaf), root, leaf, edge>


law fresh_graph_link_constructs_one_edge_shape:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +first: R.Link
  for +links: List<&2, R.Link>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +validRoot: {B.valid(w, root) == True{} : Bool}
  for +validLeaf: {B.valid(w, leaf) == True{} : Bool}
  for +different: {Nat.is_eq(leaf, root) == False{} : Bool}
  for +rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}
  for +rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}
  for +deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}
  for +depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  for +arena: {R.World.links(w) == first <> links : List<&2, R.Link>}
  GraphAllocated.OneEdge<RuntimeGraph.link(w, root, leaf), root, leaf, B.length(R.Link, links)>


law constructed_graph_starts_bounded_settlement_return:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +first: R.Link
  for +links: List<&2, R.Link>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +validRoot: {B.valid(w, root) == True{} : Bool}
  for +validLeaf: {B.valid(w, leaf) == True{} : Bool}
  for +different: {Nat.is_eq(leaf, root) == False{} : Bool}
  for +rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}
  for +rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}
  for +deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}
  for +depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  for +arena: {R.World.links(w) == first <> links : List<&2, R.Link>}
  BoundedReturn.Returned<OneEdgeReturn.start(RuntimeGraph.link(w, root, leaf), root, rest, stack), rest, stack, 10n>


law graph_construction_and_settlement_retain_committed_observation:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +first: R.Link
  for +links: List<&2, R.Link>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +validRoot: {B.valid(w, root) == True{} : Bool}
  for +validLeaf: {B.valid(w, leaf) == True{} : Bool}
  for +different: {Nat.is_eq(leaf, root) == False{} : Bool}
  for +rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}
  for +rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}
  for +deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}
  for +depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}
  for +noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}
  for +noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}
  for +arena: {R.World.links(w) == first <> links : List<&2, R.Link>}
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(RuntimeGraph.link(w, root, leaf), root, rest, stack), rest, stack, 10n, GraphLinked.startReturn(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena))) == CommittedStorage.observe(w) : CommittedStorage.View}


law fresh_graph_allocation_keeps_allocated_node_ids_valid:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +read: Nat
  for +known: {B.valid(w, read) == True{} : Bool}
  {B.valid(GraphAllocation.source(w, root, leaf), read) == True{} : Bool}


law default_signal_allocation_is_actual_literal_append:
  for +w: R.World
  for +value: R.Value
  {RuntimeConstruct.signal(w, value, RuntimeConstruct.defaults()) == RuntimeConstruct.append(w, DefaultLiterals.signalRecord(w, value)) : R.World}


law parentless_computed_setup_installs_fresh_heap_slot:
  for +w: R.World
  for +node: R.Node
  for +parentZero: {R.Node.parent(node) == 0n : Nat}
  for +room: {Nat.is_lt(0n, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  {RuntimeConstruct.setupComputedNode(RuntimeConstruct.append(w, node), FreshNodeSetup.index(w)) == RuntimeConstruct.append(w, FreshNodeSetup.record(w, node)) : R.World}


law default_computed_allocation_derives_its_node_record:
  for +w: R.World
  for +expr: R.Expr
  for +which: DefaultNode.Family
  for +room: {Nat.is_lt(0n, DefaultNode.index(w)) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  {B.node(DefaultNode.source(w, expr, which), DefaultNode.index(w)) == DefaultNode.record(w, expr, which) : R.Node}


law default_computed_allocation_derives_valid_identity:
  for +w: R.World
  for +expr: R.Expr
  for +which: DefaultNode.Family
  for +room: {Nat.is_lt(0n, DefaultNode.index(w)) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +first: R.Node
  for +tail: List<&2, R.Node>
  for +known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}
  {B.valid(DefaultNode.source(w, expr, which), DefaultNode.index(w)) == True{} : Bool}


law default_computed_allocation_retains_existing_node:
  for +w: R.World
  for +expr: R.Expr
  for +which: DefaultNode.Family
  for +room: {Nat.is_lt(0n, DefaultNode.index(w)) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +read: Nat
  for +fits: {Nat.is_lt(read, DefaultNode.index(w)) == True{} : Bool}
  {B.node(DefaultNode.source(w, expr, which), read) == B.node(w, read) : R.Node}


law actual_memo_render_graph_is_constructed:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  GraphAllocated.OneEdge<MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), DefaultNode.index(MemoRender.memo(w, sourceExpr)), B.length(R.Link, links)>


law actual_memo_render_graph_starts_bounded_settlement_return:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  BoundedReturn.Returned<OneEdgeReturn.start(MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), rest, stack), rest, stack, 10n>


law actual_memo_render_graph_settlement_retains_committed_observation:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), rest, stack), rest, stack, 10n, MemoRender.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena))) == CommittedStorage.observe(MemoRender.allocated(w, sourceExpr, effectExpr, target, program, cleanup)) : CommittedStorage.View}


law reserved_arena_memo_render_return_requires_no_final_state_premises:
  for +values: List<&2, R.Value>
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  BoundedReturn.Returned<OneEdgeReturn.start(MemoRender.linked(ConstructedFixture.input(values), sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(ConstructedFixture.input(values)), rest, stack), rest, stack, 10n>


law actual_source_registration_retains_committed_observation:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  {CommittedStorage.observe(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, source))) == CommittedStorage.observe(w) : CommittedStorage.View}


law actual_source_registration_retains_subscriber_topology:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  {SubscriberShape.observe(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, source))) == SubscriberShape.observe(w) : SubscriberShape.View}


law actual_source_registration_retains_graph_storage_and_fault:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  {GraphStorage.storage(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, source))) == GraphStorage.storage(w) : GraphStorage.Storage}


law actual_source_registration_retains_constructed_one_edge_certificate:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  GraphAllocated.OneEdge<PendingRegistration.result(w, id, source), root, leaf, edge>


law registered_one_edge_graph_constructs_bounded_settlement_return:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  BoundedReturn.Returned<OneEdgeReturn.start(PendingRegistration.result(w, id, source), root, rest, stack), rest, stack, 10n>


law registration_and_settlement_retain_committed_observation:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(PendingRegistration.result(w, id, source), root, rest, stack), rest, stack, 10n, PendingRegistration.startReturn(w, id, source, root, leaf, edge, rest, stack, shape))) == CommittedStorage.observe(w) : CommittedStorage.View}


law allocated_empty_source_set_add_constructs_membership:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extension: Nat
  for +set: Nat
  for +allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}
  for +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat}
  for +slots: {B.pendingSlots(w, 1n+set) == [] : List<&2, Nat>}
  for +room: {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(w))) == True{} : Bool}
  {RuntimePendingState.hasSource(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}


law fresh_source_set_add_constructs_membership:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extension: Nat
  for +sets: List<&2, List<&2, Nat>>
  for +allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}
  for +empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat}
  for +fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}
  for +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.hasSource(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}


law fresh_node_add_constructs_extension_set_and_membership:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, id) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.hasSource(B.first(R.World, Bool, RuntimePendingState.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}


law fresh_node_add_then_remove_retires_its_source:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, id) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.hasSource(CarrierRoundTrip.removed(w, id, 1n+source), id, 1n+source) == False{} : Bool}


law fresh_node_duplicate_source_add_retains_entire_world:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, id) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.addPendingSource(CarrierRoundTrip.added(w, id, 1n+source), id, 1n+source) == B.Bundle{CarrierRoundTrip.added(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}


law fresh_node_duplicate_source_removal_retains_entire_world:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, id) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.removePendingSource(CarrierRoundTrip.removed(w, id, 1n+source), id, 1n+source) == B.Bundle{CarrierRoundTrip.removed(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}


law fresh_node_source_retirement_clears_pending_pointer:
  for +w: R.World
  for +id: Nat
  for +source: Nat
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, id) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, id)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setsArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {R.NodeExtension.pendingSources(B.extension(CarrierRoundTrip.removed(w, id, 1n+source), id)) == 0n : Nat}


law permitted_source_histories_retain_committed_observation:
  for +w: R.World
  for +history: SourceHistory.History<w>
  {CommittedStorage.observe(SourceHistory.run(w, history)) == CommittedStorage.observe(w) : CommittedStorage.View}


law permitted_source_histories_retain_subscriber_topology:
  for +w: R.World
  for +history: SourceHistory.History<w>
  {SubscriberShape.observe(SourceHistory.run(w, history)) == SubscriberShape.observe(w) : SubscriberShape.View}


law permitted_source_histories_retain_graph_storage_and_fault:
  for +w: R.World
  for +history: SourceHistory.History<w>
  {GraphStorage.storage(SourceHistory.run(w, history)) == GraphStorage.storage(w) : GraphStorage.Storage}


law permitted_source_histories_retain_constructed_one_edge_certificate:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +history: SourceHistory.History<w>
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  GraphAllocated.OneEdge<SourceHistory.run(w, history), root, leaf, edge>


law permitted_source_histories_construct_bounded_settlement_return:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +history: SourceHistory.History<w>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  BoundedReturn.Returned<OneEdgeReturn.start(SourceHistory.run(w, history), root, rest, stack), rest, stack, 10n>


law permitted_source_histories_and_settlement_retain_committed_observation:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +history: SourceHistory.History<w>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(SourceHistory.run(w, history), root, rest, stack), rest, stack, 10n, SourceHistory.startReturn(w, root, leaf, edge, history, rest, stack, shape))) == CommittedStorage.observe(w) : CommittedStorage.View}


law selected_source_command_history_validity_is_constructed:
  for +w: R.World
  for +commands: List<&2, SourceCommands.Command>
  for +root: Nat
  for +leaf: Nat
  for +edge: Nat
  for +shape: GraphAllocated.OneEdge<w, root, leaf, edge>
  SourceHistory.History<w>


law actual_memo_render_source_commands_construct_bounded_settlement_return:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +commands: List<&2, SourceCommands.Command>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  BoundedReturn.Returned<OneEdgeReturn.start(ConstructedSources.after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands), DefaultNode.index(w), rest, stack), rest, stack, 10n>


law actual_memo_render_source_commands_retain_committed_observation:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +commands: List<&2, SourceCommands.Command>
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(ConstructedSources.after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands), DefaultNode.index(w), rest, stack), rest, stack, 10n, ConstructedSources.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack))) == CommittedStorage.observe(MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup)) : CommittedStorage.View}


law fresh_graph_allocation_retains_extension_pointers:
  for +w: R.World
  for +root: Nat
  for +leaf: Nat
  {NodePointers.observe(GraphAllocation.source(w, root, leaf)) == NodePointers.observe(w) : List<&2, Nat>}


law actual_memo_render_construction_supplies_pending_registration_context:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  RegistrationContext.Context<w, MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), DefaultNode.index(MemoRender.memo(w, sourceExpr)), B.length(R.Link, links)>


law actual_memo_render_source_registration_is_constructed:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  ConstructedRegistration.Registered<ConstructedRegistration.registered(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), DefaultNode.index(MemoRender.memo(w, sourceExpr)), B.length(R.Link, links)>


law actual_memo_render_registration_constructs_bounded_settlement_return:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  BoundedReturn.Returned<OneEdgeReturn.start(ConstructedRegistration.registered(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), rest, stack), rest, stack, 10n>


law actual_memo_render_registration_retains_committed_observation:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  for +rest: List<&2, Core.Task>
  for +stack: List<&2, R.Value>
  {CommittedStorage.observe(BoundedReturn.world(OneEdgeReturn.start(ConstructedRegistration.registered(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(w), rest, stack), rest, stack, 10n, ConstructedRegistration.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack))) == CommittedStorage.observe(MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup)) : CommittedStorage.View}


law actual_memo_render_registration_then_removal_retires_source:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.hasSource(CarrierRoundTrip.removed(MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(MemoRender.memo(w, sourceExpr)), DefaultNode.index(w)), DefaultNode.index(MemoRender.memo(w, sourceExpr)), DefaultNode.index(w)) == False{} : Bool}


law carrier_snapshot_represents_actual_source_membership:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w, node, source>
  {RuntimePendingState.hasSource(w, node, 1n+source) == CarrierState.present(w, node, source, snapshot) : Bool}


law carrier_snapshot_survives_actual_next_source_command:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w, node, source>
  for +command: SourceCommands.Command
  CarrierState.CarrierSnapshot<CarrierState.next(w, node, source, command), node, source>


law carrier_snapshot_after_command_matches_add_remove_choice:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w, node, source>
  for +command: SourceCommands.Command
  {CarrierState.present(CarrierState.next(w, node, source, command), node, source, CarrierState.step(w, node, source, snapshot, command)) == CarrierState.isAdd(command) : Bool}


law carrier_cycle_proof_state_executes_actual_helper_worlds:
  for +node: Nat
  for +source: Nat
  for +commands: List<&2, SourceCommands.Command>
  for +w: R.World
  for +initial: CarrierState.CarrierSnapshot<w, node, source>
  {CarrierCycles.world(node, source, CarrierCycles.run(node, source, commands, w, initial)) == CarrierCycles.executeWorld(node, source, commands, w) : R.World}


law single_source_cycles_membership_matches_last_command:
  for +node: Nat
  for +source: Nat
  for +commands: List<&2, SourceCommands.Command>
  for +w: R.World
  for +initial: CarrierState.CarrierSnapshot<w, node, source>
  {RuntimePendingState.hasSource(CarrierCycles.executeWorld(node, source, commands, w), node, 1n+source) == CarrierCycles.expected(commands, CarrierState.present(w, node, source, initial)) : Bool}


law fresh_source_cycles_membership_matches_last_command:
  for +node: Nat
  for +source: Nat
  for +commands: List<&2, SourceCommands.Command>
  for +w: R.World
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +valid: {B.valid(w, node) == True{} : Bool}
  for +empty: {R.Node.x(B.node(w, node)) == 0n : Nat}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {RuntimePendingState.hasSource(CarrierCycles.world(node, source, CarrierCycles.run(node, source, commands, w, CarrierCycles.fresh(w, node, source, extensions, sets, valid, empty, extensionArena, setArena))), node, 1n+source) == CarrierCycles.expected(commands, False{}) : Bool}


law actual_memo_render_carrier_cycle_invariant_is_constructed:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  CarrierState.CarrierSnapshot<MemoRender.linked(w, sourceExpr, effectExpr, target, program, cleanup), DefaultNode.index(MemoRender.memo(w, sourceExpr)), B.length(R.Node, nodes)>


law actual_memo_render_carrier_cycles_membership_matches_last_command:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  for +commands: List<&2, SourceCommands.Command>
  {RuntimePendingState.hasSource(ConstructedCarrierCycles.after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, commands), DefaultNode.index(MemoRender.memo(w, sourceExpr)), 1n+B.length(R.Node, nodes)) == CarrierCycles.expected(commands, False{}) : Bool}


law constructed_carrier_cycle_source_is_the_allocated_memo:
  for +w: R.World
  for +sourceExpr: R.Expr
  for +effectExpr: R.Expr
  for +target: Nat
  for +program: Nat
  for +cleanup: Nat
  for +first: R.Node
  for +nodes: List<&2, R.Node>
  for +firstLink: R.Link
  for +links: List<&2, R.Link>
  for +extensions: List<&2, R.NodeExtension>
  for +sets: List<&2, List<&2, Nat>>
  for +healthy: {B.ok(w) == True{} : Bool}
  for +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}
  for +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}
  for +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}
  for +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  for +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}
  {DefaultNode.index(w) == 1n+B.length(R.Node, nodes) : Nat}


law queued_computed_disposal_requests_future_flush:
  for +value: R.Value
  for +head: Nat
  for +tail: List<&2, Nat>
  {R.World.scheduled(IdleDisposal.dispose(value, head <> tail)) == True{} : Bool}

law empty_unheld_computed_disposal_does_not_request_flush:
  for +value: R.Value
  {R.World.scheduled(IdleDisposal.dispose(value, [])) == False{} : Bool}


law actual_pending_notification_constructs_single_carrier:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  SingleCarrier.Single<PendingNotification.notified(w,node,source,serial),node,source>


law actual_pending_notification_records_source_membership:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  {RuntimePendingState.hasSource(PendingNotification.notified(w,node,source,serial),node,1n+source) == True{} : Bool}


law actual_pending_notification_retains_incoming_error_identity:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  {R.NodeExtension.error(B.extension(PendingNotification.notified(w,node,source,serial),node)) == PendingNotification.error(serial,source) : R.Value}


law actual_pending_notification_selects_source_status_bits:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  for +valid: {B.valid(w,node) == True{} : Bool}
  {R.Node.status(B.node(PendingNotification.notified(w,node,source,serial),node)) == PendingNotification.flags(CarrierState.addWorld(w,node,source),node) : U32}


law actual_pending_notification_preserves_committed_content:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  {CommittedStorage.observe(PendingNotification.notified(w,node,source,serial)) == CommittedStorage.observe(w) : CommittedStorage.View}


law constructed_notification_control_supplies_all_carrier_premises:
  for +values: List<&2,R.Value>
  for +value: R.Value
  for +extensions: List<&2,R.NodeExtension>
  for +sets: List<&2,List<&2,Nat>>
  for +incoming: NotificationFixture.Incoming
  for +serial: Nat
  SingleCarrier.Single<NotificationFixture.after(values,value,extensions,sets,incoming,serial),NotificationFixture.leaf(values,value,extensions,sets),B.length(R.Node,ConstructedFixture.nodes(values))>


law source_registration_preserves_all_node_status_words:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  {SourceStatusFrame.observe(CarrierState.addWorld(w,node,source)) == SourceStatusFrame.observe(w) : List<&2,U32>}


law pending_notification_selects_actual_incoming_status:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  for +valid: {B.valid(w,node) == True{} : Bool}
  {R.Node.status(B.node(PendingNotification.notified(w,node,source,serial),node)) == SourceStatusFrame.select(R.Node.status(B.node(w,node))) : U32}


law actual_action_wait_returns_observer_allocation_identity:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +kind: U32
  {B.second(R.World,Nat,Action.wait(w,action,result,kind)) == WaitAllocation.index(w) : Nat}


law actual_action_wait_constructs_observer_capture:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +kind: U32
  {B.asyncObserver(WaitAllocation.after(w,action,result,kind),WaitAllocation.index(w)) == R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n} : R.AsyncObserver}


law actual_action_wait_subscribes_existing_result:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +kind: U32
  for +validResult: {Nat.is_lt(result,B.length(R.AsyncObject,R.World.asyncObjects(w))) == True{} : Bool}
  {B.asyncObject(WaitAllocation.after(w,action,result,kind),result) == WaitAllocation.updated(w,result,WaitAllocation.index(w)) : R.AsyncObject}


law actual_action_wait_constructs_fresh_unsettled_lookup:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +kind: U32
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {Action.find(R.World.actionWaits(WaitAllocation.after(w,action,result,kind)),WaitAllocation.index(w)) == Some{R.ActionWait{WaitAllocation.index(w),action,kind,False{}}} : Maybe<&2,R.ActionWait>}


law actual_action_wait_preserves_observer_range:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +kind: U32
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {WaitRange.below(R.World.actionWaits(WaitAllocation.after(w,action,result,kind)),WaitAllocation.index(WaitAllocation.after(w,action,result,kind))) == True{} : Bool}


law actual_wait_allocation_mark_histories_preserve_range:
  for +events: List<&2,WaitHistory.WaitEvent>
  for +w: R.World
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {WaitRange.below(R.World.actionWaits(WaitHistory.run(events,w)),WaitAllocation.index(WaitHistory.run(events,w))) == True{} : Bool}


law constructed_wait_remains_duplicate_guarded_after_actual_histories:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +events: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {Core.asyncActionDelivery(WaitHistory.afterRegistered(w,action,result,events),rest,stack,WaitAllocation.index(w),rejected,value,Action.find(R.World.actionWaits(WaitHistory.afterRegistered(w,action,result,events)),WaitAllocation.index(w))) == Core.Machine{WaitHistory.afterRegistered(w,action,result,events),rest,stack} : Core.Machine}


law actual_wait_allocation_mark_histories_retain_committed_content:
  for +events: List<&2,WaitHistory.WaitEvent>
  for +w: R.World
  {CommittedStorage.observe(WaitHistory.run(events,w)) == CommittedStorage.observe(w) : CommittedStorage.View}


law legacy_unallocated_alias_created_action_supplies_wait_range_after_actual_prefix:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {WaitRange.below(R.World.actionWaits(WaitFixture.before(values,prefix)),WaitAllocation.index(WaitFixture.before(values,prefix))) == True{} : Bool}


law legacy_unallocated_alias_created_action_wait_has_nonzero_fresh_observer:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Nat.is_ne(WaitFixture.fresh(values,prefix),0n) == True{} : Bool}


law legacy_unallocated_alias_created_action_wait_retains_settled_lookup_after_actual_suffix:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +suffix: List<&2,WaitHistory.WaitEvent>
  {Action.find(R.World.actionWaits(WaitFixture.final(values,prefix,suffix)),WaitFixture.fresh(values,prefix)) == Some{R.ActionWait{WaitFixture.fresh(values,prefix),1n,0,True{}}} : Maybe<&2,R.ActionWait>}


law legacy_unallocated_alias_created_action_wait_duplicate_retains_actual_current_machine:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +suffix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {Core.asyncActionDelivery(WaitFixture.final(values,prefix,suffix),rest,stack,WaitFixture.fresh(values,prefix),rejected,value,Action.find(R.World.actionWaits(WaitFixture.final(values,prefix,suffix)),WaitFixture.fresh(values,prefix))) == Core.Machine{WaitFixture.final(values,prefix,suffix),rest,stack} : Core.Machine}


law constructed_wait_ignores_then_throw_after_settlement:
  for +w: R.World
  for +action: Nat
  for +result: Nat
  for +events: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +error: R.Value
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {Core.actionYieldThrow(WaitHistory.afterRegistered(w,action,result,events),rest,stack,WaitAllocation.index(w),R.CallbackThrown{error}) == Core.Machine{R.World.with_fault(WaitHistory.afterRegistered(w,action,result,events),R.Healthy{}),rest,stack} : Core.Machine}

law valid_pending_notification_selects_every_incoming_status_word:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +valid: {B.valid(w,node) == True{} : Bool}
  {R.Node.status(B.node(PendingNotification.notified(w,node,source,serial),node)) == SourceStatusFrame.select(R.Node.status(B.node(w,node))) : U32}

law valid_pending_notification_sets_pending_bit:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(PendingNotification.notified(w,node,source,serial),node)),K.STATUS_PENDING()) == True{} : Bool}

law valid_pending_notification_clears_error_bit:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(PendingNotification.notified(w,node,source,serial),node)),K.STATUS_ERROR()) == False{} : Bool}

law pending_error_bookkeeping_preserves_all_status_words:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +error: R.Value
  {SourceStatusFrame.observe(RuntimePendingState.setPendingError(w,node,source,error)) == SourceStatusFrame.observe(w) : List<&2,U32>}

law pending_selected_status_always_pending:
  for +flags: U32
  {B.has(SourceStatusFrame.select(flags),K.STATUS_PENDING()) == True{} : Bool}

law pending_selected_status_never_error:
  for +flags: U32
  {B.has(SourceStatusFrame.select(flags),K.STATUS_ERROR()) == False{} : Bool}

law no_error_pending_store_preserves_subscriber_topology:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  {SubscriberShape.observe(PendingNotification.notified(w,node,source,serial)) == SubscriberShape.observe(w) : SubscriberShape.View}

law no_error_pending_store_preserves_graph_size_links_fault:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  {GraphStorage.storage(PendingNotification.notified(w,node,source,serial)) == GraphStorage.storage(w) : GraphStorage.Storage}

law no_error_pending_store_retains_initial_health:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  for +healthy: {B.ok(w) == True{} : Bool}
  {B.ok(PendingNotification.notified(w,node,source,serial)) == True{} : Bool}

law valid_node_supplies_two_steps_in_actual_notifier_budget:
  for +w: R.World
  for +node: Nat
  for +valid: {B.valid(w,node) == True{} : Bool}
  {Nat.mul(4n,B.budget(w)) == 2n+NotificationRoom.remaining(R.World.nodes(w),R.World.links(w)) : Nat}

law observer_record_writes_retain_wait_entries:
  for +w: R.World
  for +observer: Nat
  for +record: R.AsyncObserver
  {R.World.actionWaits(B.store_asyncObserver(w,observer,record)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}

law observer_record_writes_retain_arena_size:
  for +w: R.World
  for +observer: Nat
  for +record: R.AsyncObserver
  {WaitAllocation.index(B.store_asyncObserver(w,observer,record)) == WaitAllocation.index(w) : Nat}

law actual_observer_capture_has_source_counter_result:
  for +w: R.World
  for +operation: ObserverCapture.Operation
  {WaitAllocation.index(ObserverCapture.after(w,operation)) == ObserverCapture.bound(w,operation) : Nat}

law actual_observer_capture_retains_committed_content:
  for +w: R.World
  for +operation: ObserverCapture.Operation
  {CommittedStorage.observe(ObserverCapture.after(w,operation)) == CommittedStorage.observe(w) : CommittedStorage.View}

law actual_observer_capture_preserves_wait_range:
  for +w: R.World
  for +operation: ObserverCapture.Operation
  for +valid: {WaitRange.below(R.World.actionWaits(w),WaitAllocation.index(w)) == True{} : Bool}
  {WaitRange.below(R.World.actionWaits(ObserverCapture.after(w,operation)),WaitAllocation.index(ObserverCapture.after(w,operation))) == True{} : Bool}

law stream_step_observer_returns_fresh_identity:
  for +w: R.World
  for +stream: Nat
  {B.second(R.World,Nat,ObserverIterator.newStepObserver(w,stream)) == WaitAllocation.index(w) : Nat}

law stream_step_observer_captures_current_stream_record:
  for +w: R.World
  for +stream: Nat
  {B.asyncObserver(ObserverWrites.stepWorld(w,stream),WaitAllocation.index(w)) == ObserverWrites.stepRecord(w,stream) : R.AsyncObserver}

law created_action_identity_is_actually_allocated:
  for +values: List<&2,R.Value>
  {Nat.is_lt(AllocatedWaitFixture.action(values),B.length(R.ActionState,R.World.actions(AllocatedWaitFixture.initial(values)))) == True{} : Bool}

law registered_wait_captures_allocated_action_identity:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Action.find(R.World.actionWaits(AllocatedWaitFixture.registered(values,prefix)),AllocatedWaitFixture.fresh(values,prefix)) == Some{R.ActionWait{AllocatedWaitFixture.fresh(values,prefix),AllocatedWaitFixture.action(values),0,False{}}} : Maybe<&2,R.ActionWait>}

law allocated_action_supplies_wait_range_after_helper_prefix:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {WaitRange.below(R.World.actionWaits(AllocatedWaitFixture.before(values,prefix)),WaitAllocation.index(AllocatedWaitFixture.before(values,prefix))) == True{} : Bool}

law allocated_action_wait_has_nonzero_observer:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Nat.is_ne(AllocatedWaitFixture.fresh(values,prefix),0n) == True{} : Bool}

law allocated_action_wait_retains_settled_lookup:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +suffix: List<&2,WaitHistory.WaitEvent>
  {Action.find(R.World.actionWaits(AllocatedWaitFixture.final(values,prefix,suffix)),AllocatedWaitFixture.fresh(values,prefix)) == Some{R.ActionWait{AllocatedWaitFixture.fresh(values,prefix),AllocatedWaitFixture.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}

law allocated_action_wait_retains_current_machine:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +suffix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {Core.asyncActionDelivery(AllocatedWaitFixture.final(values,prefix,suffix),rest,stack,AllocatedWaitFixture.fresh(values,prefix),rejected,value,Action.find(R.World.actionWaits(AllocatedWaitFixture.final(values,prefix,suffix)),AllocatedWaitFixture.fresh(values,prefix))) == Core.Machine{AllocatedWaitFixture.final(values,prefix,suffix),rest,stack} : Core.Machine}

law actual_action_join_retains_pre_entry_captures:
  for +w: R.World
  for +transaction: Nat
  {ResumeFrame.observe(ActionTransaction.joinFuture(w,transaction)) == ResumeFrame.observe(w) : ResumeFrame.View}

law admitted_action_method_staging_retains_observer_context:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +action: Nat
  for +value: R.Value
  for +rejected: Bool
  for +state: R.ActionState
  for +method: FirstFrame.Method
  {ObserverWrites.observe(Core.world(Core.actionStepMethods(w,rest,stack,action,value,rejected,state,FirstFrame.expression(method)))) == ObserverWrites.observe(w) : ObserverWrites.View}

law actual_action_resume_retains_observer_context:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +action: Nat
  for +value: R.Value
  for +rejected: Bool
  for +method: FirstFrame.Method
  for +known: {R.ActionState.methods(Action.get(w,action)) == FirstFrame.expression(method) : R.Expr}
  {ObserverWrites.observe(Core.world(Core.actionResume(w,rest,stack,action,value,rejected))) == ObserverWrites.observe(w) : ObserverWrites.View}

law constructed_first_delivery_sets_its_settled_wait:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {Action.find(R.World.actionWaits(Core.world(FirstDelivery.first(values,rest,stack,rejected,value))),1n) == Some{R.ActionWait{1n,AllocatedWaitFixture.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}

law constructed_first_delivery_retains_wait_range:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {WaitRange.below(R.World.actionWaits(Core.world(FirstDelivery.first(values,rest,stack,rejected,value))),WaitAllocation.index(Core.world(FirstDelivery.first(values,rest,stack,rejected,value)))) == True{} : Bool}

law constructed_first_delivery_retains_committed_content:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {CommittedStorage.observe(Core.world(FirstDelivery.first(values,rest,stack,rejected,value))) == CommittedStorage.observe(FirstDelivery.initial(values)) : CommittedStorage.View}

law constructed_first_delivery_guards_its_actual_machine:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(FirstDelivery.after(values,rest,stack,rejected,value,events)),FirstDelivery.tasks(FirstDelivery.after(values,rest,stack,rejected,value,events)),Core.values(FirstDelivery.after(values,rest,stack,rejected,value,events)),1n,lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(FirstDelivery.after(values,rest,stack,rejected,value,events))),1n)) == FirstDelivery.after(values,rest,stack,rejected,value,events) : Core.Machine}

law action_rejection_reason_is_not_adopted:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +action: Nat
  for +result: Nat
  for +value: R.Value
  {Core.actionOutputValue(w,rest,stack,action,result,True{},value) == Core.actionSettled(w,rest,stack,result,True{},value) : Core.Machine}

law constructed_terminal_delivery_retires_single_obligation_and_output:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  FirstRetirement.Retired<values,rest,stack,rejected,value>

law retired_delivery_retains_exact_machine_on_later_duplicates:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(FirstRetirement.after(values,rest,stack,rejected,value,events)),FirstDelivery.tasks(FirstRetirement.after(values,rest,stack,rejected,value,events)),Core.values(FirstRetirement.after(values,rest,stack,rejected,value,events)),1n,lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(FirstRetirement.after(values,rest,stack,rejected,value,events))),1n)) == FirstRetirement.after(values,rest,stack,rejected,value,events) : Core.Machine}

law callback_table_helper_histories_retain_outer_world:
  for +events: List<&2,WaitHistory.WaitEvent>
  for +w: R.World
  {HelperContext.erase(WaitHistory.run(events,w)) == HelperContext.erase(w) : R.World}

law allocated_actor_stays_valid_through_helper_prefix:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Nat.is_lt(AllocatedWaitFixture.action(values),B.length(R.ActionState,R.World.actions(AllocatedWaitFixture.before(values,prefix)))) == True{} : Bool}

law allocated_actor_full_cell_survives_helper_prefix:
  for +values: List<&2,R.Value>
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Action.get(AllocatedWaitFixture.before(values,prefix),AllocatedWaitFixture.action(values)) == Action.get(AllocatedWaitFixture.initial(values),AllocatedWaitFixture.action(values)) : R.ActionState}

law retired_action_stays_zero_through_helper_suffix:
  for +values: List<&2,R.Value>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  for +events: List<&2,WaitHistory.WaitEvent>
  {R.Transaction.open(B.transaction(Core.world(FirstRetirement.after(values,rest,stack,rejected,value,events)),1n)) == 0n : Nat}

law admitted_yielded_callback_enters_with_observer_frame:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +observer: Nat
  for +action: Nat
  for +rejected: Bool
  for +value: R.Value
  for +method: FirstFrame.Method
  for known: {R.ActionState.methods(Action.get(w,action)) == FirstFrame.expression(method) : R.Expr}
  {FirstFrame.observe(Core.world(Core.actionDelivery(w,rest,stack,R.ActionWait{observer,action,0,False{}},rejected,value))) == FirstFrame.observe(FirstFrame.marked(w,observer)) : ObserverWrites.View}


law method_action_actor_allocated_after_helper_prefix:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {Nat.is_lt(MethodWaitFixture.action(values,method),B.length(R.ActionState,R.World.actions(MethodWaitFixture.registered(values,method,prefix)))) == True{} : Bool}


law method_action_capture_survives_real_wait_registration:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {R.ActionState.methods(Action.get(MethodWaitFixture.registered(values,method,prefix),MethodWaitFixture.action(values,method))) == FirstFrame.expression(method) : R.Expr}


law first_method_callback_after_helpers_retains_observer_context:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {ObserverWrites.observe(Core.world(MethodFirstHistory.first(values,method,prefix,rest,stack,rejected,value))) == ObserverWrites.observe(FirstFrame.marked(MethodWaitFixture.registered(values,method,prefix),MethodWaitFixture.fresh(values,method,prefix))) : ObserverWrites.View}


law first_method_callback_after_helpers_establishes_settled_lookup:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {Action.find(R.World.actionWaits(Core.world(MethodFirstHistory.first(values,method,prefix,rest,stack,rejected,value))),MethodWaitFixture.fresh(values,method,prefix)) == Some{R.ActionWait{MethodWaitFixture.fresh(values,method,prefix),MethodWaitFixture.action(values,method),0,True{}}} : Maybe<&2,R.ActionWait>}


law first_method_callback_after_helpers_retains_wait_range:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {WaitRange.below(R.World.actionWaits(Core.world(MethodFirstHistory.first(values,method,prefix,rest,stack,rejected,value))),WaitAllocation.index(Core.world(MethodFirstHistory.first(values,method,prefix,rest,stack,rejected,value)))) == True{} : Bool}


law first_method_callback_after_helpers_retains_committed_content:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {CommittedStorage.observe(Core.world(MethodFirstHistory.first(values,method,prefix,rest,stack,rejected,value))) == CommittedStorage.observe(MethodWaitFixture.initial(values,method)) : CommittedStorage.View}


law first_method_callback_and_helper_suffix_guard_current_machine:
  for +values: List<&2,R.Value>
  for +method: FirstFrame.Method
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(MethodFirstHistory.after(values,method,prefix,rest,stack,rejected,value,events)),MethodFirstHistory.tasks(MethodFirstHistory.after(values,method,prefix,rest,stack,rejected,value,events)),Core.values(MethodFirstHistory.after(values,method,prefix,rest,stack,rejected,value,events)),MethodWaitFixture.fresh(values,method,prefix),lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(MethodFirstHistory.after(values,method,prefix,rest,stack,rejected,value,events))),MethodWaitFixture.fresh(values,method,prefix))) == MethodFirstHistory.after(values,method,prefix,rest,stack,rejected,value,events) : Core.Machine}


law pending_notification_retains_topology_for_any_input_status:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  {NotifyTopology.observe(NotifyOperations.notified(w,node,source,serial)) == NotifyTopology.observe(w) : NotifyTopology.View}


law pending_notification_retains_storage_for_any_input_status:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  {NotifyStorage.storage(NotifyOperations.notified(w,node,source,serial)) == NotifyStorage.storage(w) : NotifyStorage.Storage}


law pending_leaf_notification_preserves_machine_continuation:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +rest: List<&2,NotifyRuntime.Task>
  for +visited: List<&2,Nat>
  for +scheduled: Bool
  for +config: U32
  for +shape: {NotifyTopology.shape(B.node(w,node)) == NotifyTopology.Shape{R.Memo{},config,0n} : NotifyTopology.Shape}
  for +noGuess: {B.has(config,K.CONFIG_GUESS()) == False{} : Bool}
  {NotifyRuntime.dispatch(w,NotifyRuntime.Notify{node,K.STATUS_PENDING(),NotifyOperations.error(serial,source)} <> rest,visited,scheduled) == NotifyRuntime.Machine{NotifyOperations.notified(w,node,source,serial),NotifyRuntime.Propagate{0n,K.STATUS_PENDING(),NotifyOperations.error(serial,source)} <> rest,visited,scheduled} : NotifyRuntime.Machine}


law pending_leaf_notification_completes_with_existing_public_budget:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +config: U32
  for +shape: {NotifyTopology.shape(B.node(w,node)) == NotifyTopology.Shape{R.Memo{},config,0n} : NotifyTopology.Shape}
  for +noGuess: {B.has(config,K.CONFIG_GUESS()) == False{} : Bool}
  for +healthy: {B.ok(w) == True{} : Bool}
  for +valid: {B.valid(w,node) == True{} : Bool}
  {NotifyRuntime.notifyStatusWith(w,node,K.STATUS_PENDING(),NotifyOperations.error(serial,source)) == NotifyOperations.notified(w,node,source,serial) : R.World}


law settled_status_has_exact_all_node_status_projection:
  for +w: R.World
  for +node: Nat
  for +remaining: Nat
  for +errored: Bool
  {StatusOperations.observe(RuntimePending.settledStatus(w,node,remaining,errored)) == StatusPhase.expected(w,node,remaining) : List<&2,U32>}


law sole_pending_source_removal_constructs_empty_carrier:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +single: SingleCarrier.Single<w,node,source>
  LastSource.EmptyCarrier<CarrierState.removeWorld(w,node,source),node>


law sole_pending_source_removal_reports_success:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +single: SingleCarrier.Single<w,node,source>
  {B.second(R.World,Bool,PendingState.removePendingSource(w,node,1n+source)) == True{} : Bool}


law sole_pending_source_removal_and_status_clear_pending:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +single: SingleCarrier.Single<w,node,source>
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(LastStatus.afterRemoval(w,node,source),node)),K.STATUS_PENDING()) == False{} : Bool}


law unheld_empty_carrier_has_exact_settled_status_world:
  for +w: R.World
  for +node: Nat
  for +empty: LastSource.EmptyCarrier<w,node>
  for +valid: {B.valid(w,node) == True{} : Bool}
  for +noHeld: {B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()) == False{} : Bool}
  {RuntimePending.settledStatus(w,node,0n,False{}) == LastSource.cleared(w,node) : R.World}


law heap_enqueue_preserves_all_node_status_words:
  for +w: R.World
  for +node: Nat
  {StatusOperations.observe(RuntimeHeap.enqueueSub(w,node)) == StatusOperations.observe(w) : List<&2,U32>}


law settlement_tail_preserves_all_node_status_words:
  for +w: R.World
  for +tasks: List<&2,RuntimePending.Task>
  for +visited: List<&2,Nat>
  for +released: List<&2,Nat>
  for +scheduled: Bool
  for +node: Nat
  for +root: Nat
  for +source: Nat
  for +last: Bool
  {StatusOperations.observe(TailStatus.world(RuntimePending.settledTail(w,tasks,visited,released,scheduled,node,root,source,last))) == StatusOperations.observe(w) : List<&2,U32>}


law actual_empty_carrier_settled_controller_clears_pending:
  for +w: R.World
  for +tasks: List<&2,RuntimePending.Task>
  for +visited: List<&2,Nat>
  for +released: List<&2,Nat>
  for +scheduled: Bool
  for +node: Nat
  for +root: Nat
  for +source: Nat
  for +empty: LastSource.EmptyCarrier<w,node>
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(TailStatus.world(RuntimePending.settled(w,tasks,visited,released,scheduled,node,root,source)),node)),K.STATUS_PENDING()) == False{} : Bool}


law actual_single_source_removed_controller_clears_pending:
  for +w: R.World
  for +tasks: List<&2,RuntimePending.Task>
  for +visited: List<&2,Nat>
  for +released: List<&2,Nat>
  for +scheduled: Bool
  for +node: Nat
  for +root: Nat
  for +source: Nat
  for +single: SingleCarrier.Single<w,node,source>
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(TailStatus.world(RuntimePending.visitRemoved(w,tasks,visited,released,scheduled,node,root,1n+source)),node)),K.STATUS_PENDING()) == False{} : Bool}


law local_notification_constructs_actual_controller_pending_clear:
  for +w: R.World
  for +node: Nat
  for +source: Nat
  for +serial: Nat
  for +tasks: List<&2,RuntimePending.Task>
  for +visited: List<&2,Nat>
  for +released: List<&2,Nat>
  for +scheduled: Bool
  for +root: Nat
  for +snapshot: CarrierState.CarrierSnapshot<w,node,source>
  for +noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}
  for +valid: {B.valid(w,node) == True{} : Bool}
  {B.has(R.Node.status(B.node(TailStatus.world(NotificationRetirement.after(w,node,source,serial,tasks,visited,released,scheduled,root)),node)),K.STATUS_PENDING()) == False{} : Bool}


law constructed_memo_render_notification_and_controller_clear_pending:
  for +values: List<&2,R.Value>
  for +value: R.Value
  for +extensions: List<&2,R.NodeExtension>
  for +sets: List<&2,List<&2,Nat>>
  for +incoming: NotificationFixture.Incoming
  for +serial: Nat
  for +tasks: List<&2,RuntimePending.Task>
  for +visited: List<&2,Nat>
  for +released: List<&2,Nat>
  for +scheduled: Bool
  {B.has(R.Node.status(B.node(TailStatus.world(ConstructedRetirement.constructed(values,value,extensions,sets,incoming,serial,tasks,visited,released,scheduled)),NotificationFixture.leaf(values,value,extensions,sets))),K.STATUS_PENDING()) == False{} : Bool}


law never_valued_render_read_routes_from_cleared_verdict_seat:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +reader: Nat
  for +node: Nat
  for +lane: Nat
  for +empty: {B.present(R.NodeExtension.lane(B.extension(w,node))) == False{} : Bool}
  for +present: {Nat.is_ne(R.World.passLane(w),0n) == True{} : Bool}
  for +same: {Nat.is_eq(R.Transaction.verdict(B.transaction(w,R.Transaction.parent(B.transaction(w,R.World.passLane(w))))),R.World.passLane(w)) == True{} : Bool}
  {Core.laneReadRender(w,rest,stack,reader,node,lane,False{},K.STATUS_PENDING()) == Core.laneReadOutside(R.World.with_passLane(w,0n),rest,stack,reader,node,lane,False{},K.STATUS_PENDING(),True{}) : Core.Machine}


law finite_onflush_registrations_retain_every_non_scheduling_field:
  for +bodies: List<&2,R.Expr>
  for +w: R.World
  {FlushRegistration.outer(FlushRegistration.history(bodies,w)) == FlushRegistration.outer(w) : R.World}

law nonempty_idle_onflush_registrations_have_exact_ordered_outbox:
  for +w: R.World
  for +body: R.Expr
  for +rest: List<&2,R.Expr>
  {FlushRegistration.history(body <> rest,FlushRegistration.idle(w)) == FlushRegistration.queued(w,FlushRegistration.expectedJobs(w,body,rest)) : R.World}

law actual_onflush_expression_queues_without_running_body:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +body: R.Expr
  for +previous: R.Value
  {Core.evaluate(w,rest,stack,R.OnFlush{body},previous) == Core.Machine{FlushOperation.register(w,body),rest,R.Undefined{} <> stack} : Core.Machine}


law action_output_retains_every_field_except_promise_storage_and_host_requests:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +rejected: Bool
  for +answer: R.Value
  {BodyOutput.outer(Core.world(Core.actionOutput(w,rest,stack,id,rejected,answer))) == BodyOutput.outer(w) : R.World}


law certified_group_routes_survive_transaction_arena_frames:
  for +w: R.World
  for +next: R.World
  for +path: RedirectPaths.Route<w>
  for +extra: Nat
  for +same: {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}
  for room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w,path),1n+extra) : Nat}
  {Transactions.resolveTx(next,RedirectPaths.origin(w,path)) == B.Bundle{next,RedirectPaths.terminal(w,path)} : B.Bundle<R.World,Nat>}


law literal_action_result_executes_two_real_steps_to_completion:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +value: R.Value
  for +healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}
  {PendingHistory.iterate(2n,BodyReturn.start(w,rest,stack,id,value)) == Core.actionDone(Action.exit(w),rest,stack,id,False{},value) : Core.Machine}


law actual_action_resume_enters_terminating_literal_method:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +incoming: R.Value
  for +rejected: Bool
  for +value: R.Value
  for +tail: R.Expr
  for known: {R.ActionState.methods(Action.get(w,id)) == FirstFrame.expression(BodyEntry.method(value,tail)) : R.Expr}
  {Core.actionResume(w,rest,stack,id,incoming,rejected) == BodyReturn.start(BodyEntry.prepared(w,id,tail),Core.ActionSliceEnd{R.World.question(w)} <> rest,stack,id,value) : Core.Machine}


law actual_terminating_body_retires_captured_live_group_obligation:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +value: R.Value
  for +path: RedirectPaths.Route<w>
  for +extra: Nat
  for +remaining: Nat
  for healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}
  for captured: {R.ActionState.transaction(Action.get(w,id)) == RedirectPaths.origin(w,path) : Nat}
  for room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w,path),1n+extra) : Nat}
  for open: {R.Transaction.open(B.transaction(w,RedirectPaths.terminal(w,path))) == 1n+remaining : Nat}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(2n,BodyReturn.start(w,rest,stack,id,value)))) == BodyOutput.outer(BodyRetire.target(w,RedirectPaths.terminal(w,path),remaining)) : R.World}


law constructed_body_return_retires_debt_after_arbitrary_helper_prefix:
  for +values: List<&2,R.Value>
  for +value: R.Value
  for +tail: R.Expr
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {BodyOutput.outer(Core.world(BodyConstruct.returned(values,value,tail,prefix,rest,stack,incoming,rejected))) == BodyOutput.outer(BodyRetire.target(BodyConstruct.ready(values,value,tail,prefix),1n,0n)) : R.World}


law stale_yield_after_body_return_preserves_current_machine:
  for +values: List<&2,R.Value>
  for +value: R.Value
  for +tail: R.Expr
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),MethodFirstHistory.tasks(BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),Core.values(BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),MethodWaitFixture.fresh(values,BodyEntry.method(value,tail),prefix),lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events))),MethodWaitFixture.fresh(values,BodyEntry.method(value,tail),prefix))) == BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events) : Core.Machine}


law constructed_body_retirement_zero_debt_survives_helper_suffix:
  for +values: List<&2,R.Value>
  for +value: R.Value
  for +tail: R.Expr
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +events: List<&2,WaitHistory.WaitEvent>
  {BodyDebt.count(Core.world(BodyGuard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events))) == 0n : Nat}


law action_output_preserves_arbitrary_caller_stack:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +rejected: Bool
  for +value: R.Value
  {Core.values(Core.actionOutput(w,rest,stack,id,rejected,value)) == stack : List<&2,R.Value>}


law certified_subscriber_walk_retains_full_outer_world_and_fault:
  for +w: R.World
  for path: WriteBody1.Path<w>
  for +current: R.World
  for +extra: Nat
  for +same: {WriteBody2.observe(current) == WriteBody2.observe(w) : R.World}
  for +known: {R.World.marked(w) == False{} : Bool}
  {WriteBody2.observe(RuntimeWrites.insert_subs(Nat.add(WriteBody1.depth(w,path),extra),current,WriteBody1.origin(w,path))) == WriteBody2.observe(w) : R.World}


law actual_subscriber_notification_uses_certified_arena_budget:
  for +base: R.World
  for +path: WriteBody1.Path<base>
  for +w: R.World
  for +id: Nat
  for +extra: Nat
  for same: {WriteBody2.observe(w) == WriteBody2.observe(base) : R.World}
  for unmarked: {R.World.marked(base) == False{} : Bool}
  for valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}
  for matches: {R.Node.subs(B.node(w,id)) == WriteBody1.origin(base,path) : Nat}
  for room: {B.budget(w) == Nat.add(WriteBody1.depth(base,path),extra) : Nat}
  {WriteBody2.observe(RuntimeWrites.insertSubs(w,id)) == WriteBody2.observe(base) : R.World}


law actual_ordinary_setter_preserves_constructed_source_profile:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +profile: WriteBody4.Profile<w,id>
  WriteBody4.Profile<RuntimeWrites.setSignal(w,id,value),id>


law finite_actual_setter_body_evaluates_with_structural_bound:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +profile: WriteBody4.Profile<w,id>
  {PendingHistory.iterate(WriteBody9.cost(values),WriteBody9.start(w,values,id,answer,rest,stack)) == WriteBody9.finished(w,values,id,answer,rest,stack) : Core.Machine}


law raw_signal_render_constructor_supplies_finite_write_history_profile:
  for +values: List<&2,R.Value>
  for +initial: R.Value
  WriteBody4.Profile<WriteBody11.run(values,WriteBody14.linked(initial),WriteBody14.source(initial)),WriteBody14.source(initial)>


law finite_ordinary_body_retires_original_captured_live_obligation:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +actor: Nat
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +profile: WriteBody4.Profile<w,id>
  for +route: RedirectPaths.Route<w>
  for +extra: Nat
  for +remaining: Nat
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RedirectPaths.origin(w,route) : Nat}
  for room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w,route),1n+extra) : Nat}
  for open: {R.Transaction.open(B.transaction(w,RedirectPaths.terminal(w,route))) == 1n+remaining : Nat}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+WriteBody9.cost(values),WriteBody16.start(w,values,id,answer,actor,rest,stack)))) == BodyOutput.outer(BodyRetire.target(WriteBody11.run(values,w,id),RedirectPaths.terminal(w,route),remaining)) : R.World}


law finite_ordinary_body_return_retains_arbitrary_caller_stack:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +actor: Nat
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for profile: WriteBody4.Profile<w,id>
  {Core.values(PendingHistory.iterate(1n+WriteBody9.cost(values),WriteBody16.start(w,values,id,answer,actor,rest,stack))) == stack : List<&2,R.Value>}


law constructed_actual_method_body_and_group_retirement:
  for +initial: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+WriteBody9.cost(values),WriteBody17.start(initial,values,answer,rest,stack,incoming,rejected)))) == BodyOutput.outer(BodyRetire.target(WriteBody11.run(values,WriteBody17.ready(initial,values,answer),WriteBody14.source(initial)),1n,0n)) : R.World}


law constructed_finite_setter_body_has_zero_live_action_debt:
  for +initial: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {WriteBody22.count(Core.world(PendingHistory.iterate(1n+WriteBody9.cost(values),WriteBody17.start(initial,values,answer,rest,stack,incoming,rejected))),1n) == 0n : Nat}


law actual_constant_updater_expression_keeps_committed_storage:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +value: R.Value
  for +previous: R.Value
  for healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}
  for ordinary: {Core.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool}
  for override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}
  for custom: {Equality.custom(w,id) == 0n : Nat}
  {CommittedStorage.observe(Core.world(PendingHistory.iterate(3n,WriteBody12.start(w,rest,stack,id,value,previous)))) == CommittedStorage.observe(w) : CommittedStorage.View}


law canonical_held_source_join_preserves_group_and_only_schedules:
  for +w: R.World
  for +id: Nat
  for +offset: Nat
  for canonical: {R.NodeExtension.transaction(B.extension(w,id)) == 1n+offset : Nat}
  for current: {R.World.flushTransaction(w) == 1n+offset : Nat}
  for +stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}
  {Transactions.joinNode(w,id) == HeldStage0.scheduled(w) : R.World}


law held_snapshot_stash_retains_error_flight_and_control_fields:
  for +w: R.World
  for +id: Nat
  for existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}
  {HeldStage2.observe(ReadState.stashFlushed(w,id),R.Node.x(B.node(w,id))) == HeldStage2.observe(w,R.Node.x(B.node(w,id))) : R.World}


law allocated_held_extension_records_the_actual_flushed_snapshot:
  for +w: R.World
  for +id: Nat
  for +room: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}
  {B.extension(StagedStorage.stashTail(w,id),id) == HeldStage3.updated(w,id) : R.NodeExtension}


law held_staging_with_certified_subscribers_preserves_health:
  for +w: R.World
  for +path: WriteBody1.Path<w>
  for +id: Nat
  for +value: R.Value
  for +extra: Nat
  for health: {R.World.fault(w) == R.Healthy{} : R.Fault}
  for unmarked: {R.World.marked(w) == False{} : Bool}
  for valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}
  for head: {R.Node.subs(B.node(w,id)) == WriteBody1.origin(w,path) : Nat}
  for room: {B.budget(w) == Nat.add(WriteBody1.depth(w,path),extra) : Nat}
  for context: {R.World.context(w) == 0n : Nat}
  for signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind}
  for existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}
  {R.World.fault(RuntimeWrites.stageResolved(w,id,value)) == R.Healthy{} : R.Fault}


law held_staging_retains_source_shape_and_link_storage:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for context: {R.World.context(w) == 0n : Nat}
  for signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind}
  for +existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}
  {SubscriberShape.observe(RuntimeWrites.stageResolved(w,id,value)) == SubscriberShape.observe(w) : SubscriberShape.View}


law held_staging_retains_every_allocated_extension_identity:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for context: {R.World.context(w) == 0n : Nat}
  for signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind}
  for +existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}
  {NodePointers.observe(RuntimeWrites.stageResolved(w,id,value)) == NodePointers.observe(w) : List<&2,Nat>}


law actual_held_setter_constructs_next_group_extension_and_path_profile:
  for +w: R.World
  for +id: Nat
  for +value: R.Value
  for +offset: Nat
  for +profile: HeldBody1.Profile<w,id,offset>
  HeldBody1.Profile<RuntimeWrites.setSignal(w,id,value),id,offset>


law finite_held_setter_history_constructs_its_preserved_profile:
  for values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +offset: Nat
  for profile: HeldBody1.Profile<w,id,offset>
  HeldBody1.Profile<HeldBody3.run(values,w,id),id,offset>


law finite_held_setter_history_retains_precise_outer_and_graph_frames:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +offset: Nat
  for +profile: HeldBody1.Profile<w,id,offset>
  HeldBody2.Transition<w,HeldBody3.run(values,w,id),id>


law finite_actual_held_setter_body_has_structurally_bounded_evaluation:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +offset: Nat
  for +profile: HeldBody1.Profile<w,id,offset>
  {PendingHistory.iterate(HeldBody4.cost(values),HeldBody4.start(w,values,id,answer,rest,stack)) == HeldBody4.finished(w,values,id,answer,rest,stack) : Core.Machine}


law finite_held_body_return_preserves_the_arbitrary_caller_stack:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +actor: Nat
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +offset: Nat
  for profile: HeldBody1.Profile<w,id,offset>
  {Core.values(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldBody6.start(w,values,id,answer,actor,rest,stack))) == stack : List<&2,R.Value>}


law finite_held_body_retires_the_original_captured_live_obligation:
  for +values: List<&2,R.Value>
  for +w: R.World
  for +id: Nat
  for +answer: R.Value
  for +actor: Nat
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +offset: Nat
  for +profile: HeldBody1.Profile<w,id,offset>
  for +route: RedirectPaths.Route<w>
  for +extra: Nat
  for +remaining: Nat
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RedirectPaths.origin(w,route) : Nat}
  for room: {1n+B.length(R.Transaction,R.World.txArena(w)) == Nat.add(RedirectPaths.depth(w,route),1n+extra) : Nat}
  for open: {R.Transaction.open(B.transaction(w,RedirectPaths.terminal(w,route))) == 1n+remaining : Nat}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldBody6.start(w,values,id,answer,actor,rest,stack)))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,w,id),RedirectPaths.terminal(w,route),remaining)) : R.World}


law actual_owned_source_constructor_supplies_the_held_body_profile:
  for +initial: R.Value
  HeldBody1.Profile<HeldBody8.normalized(initial),WriteBody14.source(initial),0n>


law constructed_owned_source_body_reaches_zero_live_action_debt:
  for +initial: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  {WriteBody22.count(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldBody6.start(HeldBody8.normalized(initial),values,WriteBody14.source(initial),answer,0n,rest,stack))),1n) == 0n : Nat}


law captured_fresh_preparation_retains_the_held_source_observation:
  for +w: R.World
  for +actor: Nat
  for +offset: Nat
  for +tail: R.Expr
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == 1n+offset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  for stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}
  {HeldResume1.observe(BodyEntry.prepared(w,actor,tail)) == HeldResume1.observe(HeldResume0.flush(w,1n+offset)) : HeldResume1.View}


law current_group_preparation_constructs_the_held_body_profile:
  for +w: R.World
  for +id: Nat
  for +actor: Nat
  for +offset: Nat
  for +tail: R.Expr
  for +initial: HeldBody1.Profile<w,id,offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == 1n+offset : Nat}
  HeldBody1.Profile<BodyEntry.prepared(w,actor,tail),id,offset>


law actual_action_preparation_preserves_the_original_positive_capture:
  for +w: R.World
  for +actor: Nat
  for +offset: Nat
  for +tail: R.Expr
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == 1n+offset : Nat}
  {R.ActionState.transaction(Action.get(BodyEntry.prepared(w,actor,tail),actor)) == 1n+offset : Nat}


law current_group_actual_resume_runs_held_body_and_retires_one_obligation:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == 1n+offset : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected)))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law fresh_group_actual_resume_runs_held_body_and_retires_one_obligation:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == 1n+offset : Nat}
  for +empty: {R.World.flushTransaction(w) == 0n : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected)))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law certified_captured_alias_joins_its_already_current_canonical_group:
  for +w: R.World
  for +rootOffset: Nat
  for +captureOffset: Nat
  for +alias: RejoinHistories.Alias<w,1n+rootOffset>
  for +positive: {RejoinHistories.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat}
  for future: {R.World.flushTransaction(w) == 1n+rootOffset : Nat}
  for stopped: {R.Transaction.into(B.transaction(w,1n+rootOffset)) == 0n : Nat}
  {Transactions.joinFuture(w,RejoinHistories.identity(w,1n+rootOffset,alias)) == HeldStage0.scheduled(w) : R.World}


law certified_captured_alias_selects_its_canonical_group_in_a_fresh_flush_slot:
  for +w: R.World
  for +rootOffset: Nat
  for +captureOffset: Nat
  for +alias: RejoinHistories.Alias<w,1n+rootOffset>
  for +positive: {RejoinHistories.identity(w,1n+rootOffset,alias) == 1n+captureOffset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  {Transactions.joinFuture(w,RejoinHistories.identity(w,1n+rootOffset,alias)) == HeldStage0.scheduled(HeldResume0.flush(w,1n+rootOffset)) : R.World}


law never_valued_pending_read_returns_token_from_a_shown_lane:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +reader: Nat
  for +id: Nat
  for +lane: Nat
  for known: {R.Transaction.shown(B.transaction(w,lane)) == True{} : Bool}
  {Core.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) == Core.Machine{w,rest,R.NotPendingToken{} <> stack} : Core.Machine}


law never_valued_pending_read_retains_outside_display_when_lane_unshown:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +reader: Nat
  for +id: Nat
  for +lane: Nat
  for known: {R.Transaction.shown(B.transaction(w,lane)) == False{} : Bool}
  {Core.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),True{}) == Core.laneReadOutside(w,rest,stack,reader,id,lane,False{},K.STATUS_PENDING(),False{}) : Core.Machine}


law retained_redirect_vector_constructs_next_route_with_origin_terminal_and_depth:
  for +w: R.World
  for +next: R.World
  for path: RedirectPaths.Route<w>
  for +same: {AliasResume0.parents(next) == AliasResume0.parents(w) : List<&2,Nat>}
  AliasResume0.Rebased<w,next,path>


law retained_redirect_vector_constructs_next_alias_and_arena_room:
  for +w: R.World
  for +next: R.World
  for +root: Nat
  for alias: RejoinHistories.Alias<w,root>
  for +same: {AliasResume0.parents(next) == AliasResume0.parents(w) : List<&2,Nat>}
  AliasResume0.AliasRebased<w,next,root,alias>


law captured_alias_current_preparation_retains_source_profile_observation:
  for +w: R.World
  for +actor: Nat
  for +offset: Nat
  for +captureOffset: Nat
  for +tail: R.Expr
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for future: {R.World.flushTransaction(w) == 1n+offset : Nat}
  for stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}
  {HeldResume1.observe(BodyEntry.prepared(w,actor,tail)) == HeldResume1.observe(w) : HeldResume1.View}


law captured_alias_fresh_preparation_retains_selected_source_observation:
  for +w: R.World
  for +actor: Nat
  for +offset: Nat
  for +captureOffset: Nat
  for +tail: R.Expr
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  {HeldResume1.observe(BodyEntry.prepared(w,actor,tail)) == HeldResume1.observe(HeldResume0.flush(w,1n+offset)) : HeldResume1.View}


law actual_preparation_retains_the_original_positive_captured_alias:
  for +w: R.World
  for +actor: Nat
  for +offset: Nat
  for +captureOffset: Nat
  for +tail: R.Expr
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  {R.ActionState.transaction(Action.get(BodyEntry.prepared(w,actor,tail),actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}


law captured_alias_current_resume_runs_finite_held_body_and_retires_one_obligation:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected)))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law captured_alias_fresh_resume_runs_finite_held_body_and_retires_one_obligation:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for +empty: {R.World.flushTransaction(w) == 0n : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {BodyOutput.outer(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected)))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(w,actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law captured_alias_current_resume_restores_arbitrary_caller_stack:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {Core.values(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}


law captured_alias_fresh_resume_restores_arbitrary_caller_stack:
  for +w: R.World
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  {Core.values(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(w,actor,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}


law ordinary_current_observer_delivery_runs_aliased_held_body_and_retires_once:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  {BodyOutput.outer(Core.world(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(HeldDelivery1.marked(w,observer),actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law ordinary_current_observer_delivery_restores_caller_stack:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  {Core.values(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values)) == stack : List<&2,R.Value>}


law ordinary_current_observer_delivery_cannot_repeat_after_body_and_wait_history:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<w,id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for +known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for +found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),HeldDelivery2.tasks(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),Core.values(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),observer,lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events))),observer)) == HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events) : Core.Machine}


law ordinary_fresh_observer_delivery_runs_aliased_held_body_and_retires_once:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  {BodyOutput.outer(Core.world(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(HeldDelivery1.marked(w,observer),actor,R.ActionEnd{}),id),1n+offset,remaining)) : R.World}


law ordinary_fresh_observer_delivery_restores_caller_stack:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for empty: {R.World.flushTransaction(w) == 0n : Nat}
  for known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  {Core.values(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values)) == stack : List<&2,R.Value>}


law ordinary_fresh_observer_delivery_cannot_repeat_after_body_and_wait_history:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for +empty: {R.World.flushTransaction(w) == 0n : Nat}
  for open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for +known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for +found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  for +events: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),HeldDelivery2.tasks(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),Core.values(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events)),observer,lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events))),observer)) == HeldDelivery2.afterEvents(w,rest,stack,observer,incoming,rejected,values,events) : Core.Machine}


law actual_hold_source_view_is_computed_from_its_initial_source_view:
  for +w: R.World
  for +id: Nat
  for +t: Nat
  {HeldResume1.observe(Transactions.holdNode(w,id,t)) == HeldConstruct0.hold(HeldResume1.observe(w),id,t) : HeldResume1.View}


law holding_a_source_preserves_action_capture_and_all_group_open_counts:
  for +w: R.World
  for +id: Nat
  for +t: Nat
  {HeldConstruct1.observe(Transactions.holdNode(w,id,t)) == HeldConstruct1.observe(w) : HeldConstruct1.View}


law actual_create_open_hold_constructs_the_fresh_resume_source_profile:
  for +initial: R.Value
  for +methods: R.Expr
  HeldBody1.Profile<HeldResume0.flush(HeldConstruct2.opened(initial,methods),1n),HeldConstruct6.source(initial),0n>


law constructed_held_resume_body_retires_its_only_live_action_obligation:
  for +initial: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {WriteBody22.count(Core.world(PendingHistory.iterate(1n+HeldBody4.cost(values),HeldResume7.start(HeldConstruct2.opened(initial,HeldResume7.methods(values,HeldConstruct6.source(initial),answer)),0n,rest,stack,incoming,rejected))),1n) == 0n : Nat}


law constructed_ordinary_observer_delivery_runs_a_finite_held_body_and_retires:
  for +value: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {BodyOutput.outer(Core.world(HeldDelivery0.after(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rejected,incoming,values))) == BodyOutput.outer(BodyRetire.target(HeldBody3.run(values,BodyEntry.prepared(HeldDelivery1.marked(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix)),0n,R.ActionEnd{}),HeldConstruct6.source(value)),1n,0n)) : R.World}


law constructed_ordinary_observer_delivery_preserves_arbitrary_caller_stack:
  for +value: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +saved: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {Core.values(HeldDelivery0.after(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,saved,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rejected,incoming,values)) == saved : List<&2,R.Value>}


law constructed_ordinary_observer_delivery_is_a_noop_after_its_first_body:
  for +value: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +suffix: List<&2,WaitHistory.WaitEvent>
  for +lateRejected: Bool
  for +lateValue: R.Value
  {Core.asyncActionDelivery(Core.world(HeldDelivery2.afterEvents(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),incoming,rejected,values,suffix)),HeldDelivery2.tasks(HeldDelivery2.afterEvents(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),incoming,rejected,values,suffix)),Core.values(HeldDelivery2.afterEvents(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),incoming,rejected,values,suffix)),ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),lateRejected,lateValue,Action.find(R.World.actionWaits(Core.world(HeldDelivery2.afterEvents(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),incoming,rejected,values,suffix))),ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix))) == HeldDelivery2.afterEvents(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),incoming,rejected,values,suffix) : Core.Machine}


law actual_action_output_retains_an_exact_caller_task_suffix:
  for +w: R.World
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +id: Nat
  for +rejected: Bool
  for +answer: R.Value
  ActionOutput0.Queue<Core.actionDone(w,rest,stack,id,rejected,answer),rest,stack>


law classified_action_output_prefix_has_a_finite_exact_core_drain:
  for +machine: Core.Machine
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +form: ActionOutput0.Queue<machine,rest,stack>
  for healthy: {R.World.fault(Core.world(machine)) == R.Healthy{} : R.Fault}
  {PendingHistory.iterate(ActionOutput0.cost(machine,rest,stack,form),machine) == Core.Machine{ActionOutput0.world(machine,rest,stack,form),rest,stack} : Core.Machine}


law ordinary_fresh_callback_output_prefix_reaches_its_queued_slice_end:
  for +w: R.World
  for +observer: Nat
  for +actor: Nat
  for +values: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  for +offset: Nat
  for +captureOffset: Nat
  for +remaining: Nat
  for +initial: HeldBody1.Profile<HeldResume0.flush(w,1n+offset),id,offset>
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +captured: {R.ActionState.transaction(Action.get(w,actor)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +positive: {RejoinHistories.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}
  for +empty: {R.World.flushTransaction(w) == 0n : Nat}
  for +open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}
  for +known: {R.ActionState.methods(Action.get(w,actor)) == HeldResume7.methods(values,id,answer) : R.Expr}
  for +found: {Action.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,actor,0,False{}}} : Maybe<&2,R.ActionWait>}
  {PendingHistory.iterate(ActionOutput0.cost(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values),ActionOutput2.work(w,observer,rest),stack,ActionOutput2.queue(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)),HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values)) == Core.Machine{ActionOutput0.world(HeldDelivery0.after(w,rest,stack,observer,rejected,incoming,values),ActionOutput2.work(w,observer,rest),stack,ActionOutput2.queue(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)),ActionOutput2.work(w,observer,rest),stack} : Core.Machine}


law nested_action_slice_restores_the_saved_caller_question:
  for +w: R.World
  for +question: R.Question
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +offset: Nat
  for +healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}
  for depth: {R.World.actionDepth(w) == 1n+offset : Nat}
  {PendingHistory.iterate(2n,ActionOutput4.start(w,question,rest,stack)) == Core.Machine{Q.setQuestion(w,question),rest,stack} : Core.Machine}


law scheduled_outer_action_slice_queues_round_before_question_restore:
  for +w: R.World
  for +question: R.Question
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}
  for +depth: {R.World.actionDepth(w) == 0n : Nat}
  for running: {R.World.running(w) == False{} : Bool}
  for halted: {R.World.halted(w) == False{} : Bool}
  for ready: {R.World.scheduled(w) == True{} : Bool}
  {Core.step(ActionOutput4.start(w,question,rest,stack)) == Core.Machine{w,Core.Round{} <> Core.ActionRestoreQuestion{question} <> rest,stack} : Core.Machine}


law certified_source_cache_redirect_is_resolved_and_stored_by_actual_txof:
  for +w: R.World
  for +id: Nat
  for +root: Nat
  for +alias: RejoinHistories.Alias<w,root>
  for cached: {R.NodeExtension.transaction(B.extension(w,id)) == RejoinHistories.identity(w,root,alias) : Nat}
  {Transactions.txOf(w,id) == B.Bundle{SourceCache0.canonical(w,id,root),root} : B.Bundle<R.World,Nat>}


law first_real_setter_constructs_the_canonical_source_cache_successor:
  for +w: R.World
  for +id: Nat
  for +offset: Nat
  for +value: R.Value
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for cached: {R.NodeExtension.transaction(B.extension(w,id)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +profile: HeldBody1.Profile<SourceCache0.canonical(w,id,1n+offset),id,offset>
  HeldBody1.Profile<RuntimeWrites.setSignal(w,id,value),id,offset>


law nonempty_source_cache_alias_body_has_a_structural_exact_core_bound:
  for +w: R.World
  for +head: R.Value
  for +tail: List<&2,R.Value>
  for +id: Nat
  for +answer: R.Value
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +offset: Nat
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for +cached: {R.NodeExtension.transaction(B.extension(w,id)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for +profile: HeldBody1.Profile<SourceCache0.canonical(w,id,1n+offset),id,offset>
  {PendingHistory.iterate(HeldBody4.cost(head <> tail),HeldBody4.start(w,head <> tail,id,answer,rest,stack)) == HeldBody4.finished(w,head <> tail,id,answer,rest,stack) : Core.Machine}


law nonempty_source_cache_alias_body_constructs_its_final_held_profile:
  for +w: R.World
  for +head: R.Value
  for +tail: List<&2,R.Value>
  for +id: Nat
  for +offset: Nat
  for +alias: RejoinHistories.Alias<w,1n+offset>
  for cached: {R.NodeExtension.transaction(B.extension(w,id)) == RejoinHistories.identity(w,1n+offset,alias) : Nat}
  for profile: HeldBody1.Profile<SourceCache0.canonical(w,id,1n+offset),id,offset>
  HeldBody1.Profile<HeldBody3.run(head <> tail,w,id),id,offset>


law constructed_held_delivery_preserves_initial_action_control_flags:
  for +value: R.Value
  for +methods: R.Expr
  for +prefix: List<&2,WaitHistory.WaitEvent>
  {RoundConstruct20262.observe(RoundConstruct20261.registered(value,methods,prefix)) == RoundConstruct20262.Flags{0n,False{},False{}} : RoundConstruct20262.View}


law unhalted_action_retirement_schedules_work:
  for +w: R.World
  for +root: Nat
  for +remaining: Nat
  for known: {R.World.halted(w) == False{} : Bool}
  {R.World.scheduled(BodyRetire.target(w,root,remaining)) == True{} : Bool}


law constructed_ordinary_delivery_reaches_queued_round_after_finite_body:
  for +value: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {PendingHistory.iterate(Nat.add(1n+HeldBody4.cost(values),1n+RoundConstruct20264.cost(value,values,answer,prefix,rest,stack,incoming,rejected)),HeldDelivery0.start(ConstructDelivery1.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,ConstructDelivery1.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rejected,incoming)) == RoundConstruct20264.target(value,values,answer,prefix,rest,stack,incoming,rejected) : Core.Machine}


law constructed_ordinary_outer_interception_selects_action_delivery:
  for +initial: R.Value
  for +methods: R.Expr
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +rejected: Bool
  for +value: R.Value
  {Core.fromWrapDelivery(RoundConstruct20261.registered(initial,methods,prefix),rest,stack,RoundConstruct20261.observer(initial,methods,prefix),rejected,value) == HeldDelivery0.start(RoundConstruct20261.registered(initial,methods,prefix),rest,stack,RoundConstruct20261.observer(initial,methods,prefix),rejected,value) : Core.Machine}


law constructed_fulfillment_or_rejection_task_reaches_queued_round:
  for +value: R.Value
  for +values: List<&2,R.Value>
  for +answer: R.Value
  for +prefix: List<&2,WaitHistory.WaitEvent>
  for +rest: List<&2,Core.Task>
  for +stack: List<&2,R.Value>
  for +incoming: R.Value
  for +rejected: Bool
  {PendingHistory.iterate(Nat.add(1n,Nat.add(1n+HeldBody4.cost(values),1n+RoundConstruct20264.cost(value,values,answer,prefix,rest,stack,incoming,rejected))),RoundConstruct20268.start(RoundConstruct20261.registered(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rest,stack,RoundConstruct20261.observer(value,HeldResume7.methods(values,HeldConstruct6.source(value),answer),prefix),rejected,incoming)) == RoundConstruct20264.target(value,values,answer,prefix,rest,stack,incoming,rejected) : Core.Machine}
