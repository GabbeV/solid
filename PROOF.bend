import ./proof/held-source-cache-output-queue.bend as JoinedRound20260
import ./proof/action-output-queue-debt.bend as JoinedRound20261
import ./proof/held-pair-constructed-output-queue.bend as JoinedRound20262
import ./proof/held-pair-generic-output-queue.bend as JoinedRound20263
import ./proof/held-pair-generic-round.bend as JoinedRound20264
import ./proof/held-cached-body-control.bend as JoinedRound20265
import ./proof/held-pair-control-flags.bend as JoinedRound20266
import ./proof/held-pair-constructed-round.bend as JoinedRound20267
import ./proof/held-source-input-successor.bend as NextBody20260
import ./proof/held-body-controller-frame.bend as NextBody20261
import ./proof/held-prepared-other-controller.bend as NextBody20262
import ./proof/held-next-controller-body.bend as NextBody20263
import ./proof/held-controller-ready.bend as NextBody20264
import ./proof/held-pair-generic-next.bend as NextBody20265
import ./proof/held-pair-constructed-next.bend as NextBody20266
import ./proof/held-pair-second-body.bend as NextBody20267
import ./proof/held-pair-second-count.bend as NextBody20268
import ./proof/held-cache-virtual-history.bend as CountEvidence20260
import ./proof/held-source-cache-debt.bend as CountEvidence20261
import ./proof/held-count-certificate.bend as CountEvidence20262
import ./proof/held-cache-body-input.bend as CountEvidence20263
import ./proof/held-pair-generic-debt.bend as CountEvidence20264
import ./proof/held-pair-constructed-debt.bend as CountEvidence20265
import ./proof/held-pair-constructed-count.bend as CountEvidence20266
import ./proof/held-count-source-profile.bend as CountEvidence20267
import ./proof/held-retirement-source-profile.bend as CountEvidence20268
import ./proof/held-pair-constructed-profile.bend as CountEvidence20269
import ./proof/held-static-operations.bend as JoinedBody20260
import ./proof/held-source-static.bend as JoinedBody20261
import ./proof/transaction-join.bend as JoinedBody20262
import ./proof/held-pair-join-profile.bend as JoinedBody20263
import ./proof/held-virtual-group-profile.bend as JoinedBody20264
import ./proof/held-pair-generic-body.bend as JoinedBody20265
import ./proof/held-first-ready.bend as JoinedBody20266
import ./proof/held-pair-generic-state.bend as JoinedBody20267
import ./proof/held-pair-generic-context.bend as JoinedBody20268
import ./proof/held-pair-generic-aliases.bend as JoinedBody20269
import ./proof/held-pair-constructed-body.bend as JoinedBody202610
import ./proof/held-first-ready-construction.bend as JoinedBody202611
import ./proof/held-source-cache-view.bend as CacheResume20260
import ./proof/held-source-cache-retirement.bend as CacheResume20261
import ./proof/held-source-cache-resume.bend as CacheResume20262
import ./proof/held-source-cache-preparation.bend as CacheResume20263
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
import ./runtime/core.bend as Core
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
import ./proof/from-wrap-laws.bend as FromWrapLaws
import ./proof/from-iterable-driver.bend as FromIterableDriver
import ./proof/from-iterable-program.bend as FromIterableProgram
import ./proof/from-iterable-outcome.bend as FromIterableOutcome
import ./proof/from-laws.bend as FromLaws
import ./proof/from-driver.bend as FromDriver
import ./proof/from-program.bend as FromProgram
import ./proof/from-outcome.bend as FromOutcome
import ./proof/supersede-laws.bend as SupersedeLaws
import Base
import ./proof/core-run-prefix.bend as CoreRunPrefix
import ./proof/pending-removal-footprint.bend as RemovalFootprint
import ./proof/empty-settlement-completion.bend as EmptySettlement
import ./proof/rendered-observation.bend as RenderedView
import ./proof/rendered-independent-apply.bend as IndependentApply
import ./proof/rendered-async-prefix.bend as RenderedArrival
import ./proof/owner-continuation.bend as OwnerContinuation
import ./proof/pending-continuation.bend as PendingContinuation
import ./proof/pending-stack-history.bend as PendingHistory
import ./proof/async-cleanup-program.bend as CleanupProgram
import ./proof/async-error-retirement.bend as ErrorRetirement
import ./proof/landing-release.bend as LandingRelease
import ./proof/deferred-stream-program.bend as DeferredStreamProgram
import ./proof/deferred-stream-laws.bend as DeferredStreamLaws

import ./proof/deferred-program.bend as DeferredProgram
import ./proof/deferred-payload-program.bend as DeferredPayloadProgram
import ./proof/deferred-lifecycle.bend as DeferredLifeLaws
import ./proof/deferred-error-catch.bend as DeferredCatch
import ./proof/deferred-lag.bend as DeferredLaws
import ./proof/affects-scope.bend as AffectsLaws
import ./proof/affects-program.bend as AffectsProgram
import ./proof/verdict-windows.bend as WindowLaws
import ./proof/verdict-program.bend as VerdictProgram
import ./proof/optimistic-program.bend as OptimisticProgram
import ./proof/lane-flush.bend as FlushLaws
import ./proof/lane-pass.bend as PassLaws
import ./proof/signed-zero.bend as SignedZero
import ./proof/lane-guesses.bend as GuessLaws
import ./proof/lane-answers.bend as LaneAnswers
import ./proof/lane-lifecycle.bend as LaneLifecycle
import ./proof/question-order.bend as QuestionOrder
import ./proof/lane-read-laws.bend as LaneReadLaws
import ./proof/cleanup-policy.bend as CleanupPolicy
import ./proof/lane-group-laws.bend as GroupLaws
import ./proof/lane-stage.bend as StageLaws
import ./proof/lane-blockers.bend as LaneBlockers
import ./proof/verdict-laws.bend as VerdictLaws
import ./proof/lane-laws.bend as LaneLaws
import ./proof/mark-laws.bend as MarkLaws
import ./proof/array-laws.bend as ArrayLaws
import ./proof/array-write.bend as ArrayWrite
import ./proof/flatten-lifecycle.bend as FlattenLifecycle
import ./proof/flatten-natural.bend as NaturalFlatten
import ./proof/map-lifecycle.bend as MapLifecycle
import ./proof/memo-batches.bend as MemoBatches
import ./proof/memo-coalescing.bend as MemoCoalescing
import ./proof/memo-history-public.bend as MemoHistory
import ./proof/memo-repeat-public.bend as MemoRepeat
import ./proof/direct-owner-laws.bend as DirectOwners
import ./proof/argument-vector-laws.bend as ArgumentVectors
import ./proof/chain-setter.bend as ChainSetter
import ./proof/chain-public-program.bend as ChainPublic
import ./proof/chain-staging.bend as ChainStaging
import ./proof/chain-observation.bend as ChainObservation
import ./proof/chain-publication.bend as ChainPublication
import ./proof/chain-constructor.bend as ChainConstructor
import ./runtime/scheduler.bend as PublicationScheduler
import ./representation/base.bend as B
import ./representation/records.bend as R
import ./proof/memo-general-setter.bend as MemoGeneralSetter
import ./proof/memo-general-public.bend as MemoGeneralPublic
import ./proof/action-function-laws.bend as ActionFunctions
import ./proof/memo-initial.bend as MemoInitial
import ./proof/transaction-merge-laws.bend as TxMerge
import ./proof/memo-public-program.bend as MemoPublic
import ./proof/action-laws.bend as ActionLaws
import ./proof/memo-staging.bend as MemoStaging
import ./proof/extension-laws.bend as ExtensionLaws
import ./proof/cleanup-laws.bend as CleanupLaws
import ./LAWS.bend as Laws
import ./proof/flush-callbacks.bend as FlushCallbacks
import ./proof/comparators.bend as Comparators
import ./proof/paths.bend as Paths
import ./proof/publication.bend as Publication
import ./proof/publication-stage.bend as StagePublication
import ./proof/read-policy.bend as ReadPolicy
import ./proof/signal-staging.bend as SignalStaging
import ./proof/question.bend as Question

def Laws.chain_once():
  {==}

def Laws.chain_twice():
  {==}

def Laws.cleanup_reentry():
  {==}

def Laws.error_propagates():
  {==}

def Laws.error_recovers_same_value():
  {==}

def Laws.pending_diamond_retires():
  {==}

def Laws.pending_other_path_remains():
  {==}

def Laws.transaction_parks():
  {==}

def Laws.transaction_lands():
  {==}

def Laws.loading_seed_waits():
  {==}

def Laws.promise_lands():
  {==}

def Laws.stale_promise_is_ignored():
  {==}

def Laws.newest_promise_lands():
  {==}

def Laws.async_diamond_lands():
  {==}

def Laws.staged_error_recovers_before_landing():
  {==}

def Laws.until_false_waits():
  {==}

def Laws.until_truthy_resolves():
  {==}

def Laws.callback_reads_and_returns():
  {==}

def Laws.captured_root_disposes():
  {==}

def Laws.init_disposer_is_bound():
  {==}

def Laws.context_records_are_snapshots():
  {==}

def Laws.context_child_override_is_isolated():
  {==}

def Laws.bound_cleanup_preserves_identity():
  {==}

def Laws.callback_argument_zero(first, second):
  {==}

def Laws.root_binder_shadows_arguments(body, first, second):
  {==}

def Laws.question_increment_meaning(value):
  Question.incrementMeaning(value)

def Laws.question_from_nat_meaning(value):
  Question.fromNatMeaning(value)

def Laws.question_equal_reflexive(value):
  Question.equalReflexive(value)

def Laws.nan_is_not_equal():
  {==}

def Laws.undefined_is_a_staged_value():
  {==}

def Laws.nested_memo_replaces_child():
  {==}

def Laws.nested_effect_first_application_is_queued():
  {==}

def Laws.nested_effect_disposed_before_application():
  {==}

def Laws.local_signal_is_captured():
  {==}

def Laws.lexical_read_binding(signal):
  {==}

def Laws.lexical_scope_shadows(signal):
  {==}

def Laws.escaped_accessor_tracks_after_root_disposal():
  {==}

def Laws.lexical_accessor_binding(signal):
  {==}

def Laws.escaped_setter_writes_after_root_disposal():
  {==}

def Laws.reentrant_setter_uses_entry_value():
  {==}

def Laws.computed_accessor_freezes_on_root_disposal():
  {==}

def Laws.lexical_setter_binding(signal):
  {==}

def Laws.writable_signal_rederives_from_manual_previous():
  {==}

def Laws.held_function_result_stays_data():
  {==}

def Laws.setter_cleanup_preserves_identity_and_clears():
  {==}

def Laws.getter_cleanup_preserves_identity_and_pulls():
  {==}

def Laws.effect_returns_selected_cleanup():
  {==}

def Laws.callable_initializer_tracks_and_freezes():
  {==}

def Laws.callback_values_bind_initialize_and_cleanup():
  {==}

def Laws.direct_owner_cleanup_reads_resume_core():
  {==}

def Laws.trim_error_collection_preserves_application_error():
  {==}

def Laws.commit_publishes_before_parked_cleanup_error():
  {==}

def Laws.flight_release_runs_read_capable_cleanup():
  {==}

def Laws.async_landing_trims_through_cleanup_read():
  {==}

def Laws.pending_dependent_release_runs_cleanup_read():
  {==}

def Laws.rebuilt_lazy_source_runs_once():
  {==}

def Laws.writable_error_is_shown_until_replacement_commit():
  {==}

def Laws.later_iterator_throw_reaches_memo():
  {==}

def Laws.empty_flatten_returns_undefined():
  {==}

def Laws.throwing_teardown_restores_release_collector():
  {==}

def Laws.tracked_effect_runs_after_commit():
  {==}

def Laws.tracked_effect_cleans_before_rerun_and_disposal():
  {==}

def Laws.owned_settled_runs_once_and_cleans_on_disposal():
  {==}

def Laws.unowned_settled_drops_cleanup_without_creating_node():
  {==}

def Laws.callback_settled_binding(first, second):
  {==}

def Laws.lexical_settled_binding(signal):
  {==}

def Laws.reaction_replaces_arms_and_retains_cleanup():
  {==}

def Laws.pending_reaction_arm_is_replaced():
  {==}

def Laws.seeded_reaction_arm_is_replaced():
  {==}

def Laws.callback_reaction_binding(first, second):
  {==}

def Laws.lexical_reaction_tracking_binding(signal):
  {==}

def Laws.pending_value_publication(w, prefix, node, suffix, value):
  Publication.publication(w, prefix, node, suffix, value)

def Laws.unowned_fast_read_committed(w, arena, tasks, stack, id):
  ReadPolicy.committed_fast_read(w, arena, tasks, stack, id)

def Laws.unowned_read_does_not_join(w, id, slow):
  ReadPolicy.unowned_read_does_not_join(w, id, slow)

def Laws.unowned_selected_read(w, tasks, stack, id):
  ReadPolicy.unowned_selected_read(w, tasks, stack, id)

def Laws.unflushed_value_is_selected(w, tasks, stack, id, reader, value):
  ReadPolicy.unflushed_value_is_selected(w, tasks, stack, id, reader, value)

def Laws.empty_pending_publication_is_identity(w, prefix, node, suffix):
  Publication.noPending(w, prefix, node, suffix)

def Laws.publication_is_idempotent(w, prefix, node, suffix):
  Publication.idempotent(w, prefix, node, suffix)

def Laws.signal_reads_committed_before_flush(initial, next):
  SignalStaging.read_before_commit(initial, next)

def Laws.signal_reads_new_value_after_flush(initial, next):
  SignalStaging.read_after_commit(initial, next)

def Laws.signal_completes_for_every_sufficient_budget(initial, next, extra):
  SignalStaging.complete(initial, next, extra)


def Laws.nested_flush_callback_returns_before_outer_drain():
  {==}

def Laws.flush_drain_error_overrides_callback_error():
  {==}

def Laws.flush_callback_entry_preserves_caller(w, rest, saved, body, prev, outside):
  FlushCallbacks.entry(w, rest, saved, body, prev, outside)

def Laws.flush_finally_restores_depth_and_operands(w, depth, rest, saved, fault):
  FlushCallbacks.restores(w, depth, rest, saved, fault)

def Laws.throwing_flush_callback_still_drains(w, rest, partial, saved, error):
  FlushCallbacks.thrown_drains(w, rest, partial, saved, error)


def Laws.custom_comparator_suppresses_publication():
  Comparators.equal_case()

def Laws.custom_comparator_publishes_change():
  Comparators.changed_case()

def Laws.comparator_error_is_node_status():
  Comparators.error_case()

def Laws.pending_comparator_read_means_changed():
  Comparators.pending_case()

def Laws.default_comparator_keeps_fast_path(w, rest, stack, id, a, b, known):
  Comparators.default_fast(w, rest, stack, id, a, b, known)

def Laws.custom_comparator_preserves_call_arguments(w, rest, stack, id, a, b, callback, known):
  Comparators.custom_call(w, rest, stack, id, a, b, callback, known)

def Laws.comparator_not_ready_returns_undefined(w, rest, saved, id, identity, source):
  Comparators.not_ready(w, rest, saved, id, identity, source)

def Laws.comparator_error_routes_status(w, rest, saved, id, error, known):
  Comparators.ordinary_error(w, rest, saved, id, error, known)

def Laws.comparator_registration_preserves_graph(w, id, callback):
  Comparators.registry_preserves_world(w, id, callback)


def Laws.changed_memo_stages_then_notifies(w, id, value, height, joined, nonEffect):
  StagePublication.memo_change(w, id, value, height, joined, nonEffect)

def Laws.pending_stage_preserves_other_fields(w, prefix, node, suffix, value):
  StagePublication.stage_store(w, prefix, node, suffix, value)

def Laws.changed_unobserved_memo_preserves_committed_world(w, prefix, node, suffix, value, height, joined):
  StagePublication.unobserved_memo_stages_without_committing(w, prefix, node, suffix, value, height, joined)


def Laws.existing_extension_preserves_entire_world(w, prefix, node, suffix, x):
  ExtensionLaws.existing_extension_is_exact_identity(w, prefix, node, suffix, x)

def Laws.extension_allocation_appends_one_record(w, prefix, node, suffix, extensions):
  ExtensionLaws.fresh_extension_appends_exactly_once(w, prefix, node, suffix, extensions)

def Laws.extension_allocation_is_idempotent(w, prefix, node, suffix, head, tail):
  ExtensionLaws.extension_allocation_is_idempotent(w, prefix, node, suffix, head, tail)

def Laws.new_extension_has_exact_default_fields(w, prefix, node, suffix, extensions):
  ExtensionLaws.fresh_extension_points_to_default_record(w, prefix, node, suffix, extensions)

def Laws.reactive_cleanup_detaches_before_invocation(w, prefix, node, suffix, rest, self):
  CleanupLaws.normal_disposal_detaches_before_callbacks(w, prefix, node, suffix, rest, self)

def Laws.detached_cleanup_list_is_not_replayed(w, prefix, node, suffix, rest, self):
  CleanupLaws.detached_list_is_not_replayed(w, prefix, node, suffix, rest, self)

def Laws.reactive_cleanup_uses_reverse_registration_order(w, prefix, callback, rest):
  CleanupLaws.last_registered_cleanup_is_first(w, prefix, callback, rest)


def Laws.staged_scalar_memo_flush_completes(next, extra):
  MemoStaging.every_staged_input(next, extra)


def Laws.action_depth_entry_exit_preserves_world(w):
  ActionLaws.balanced(w)

def Laws.action_flush_callback_runs_without_a_drain(w, depth, rest, stack, body, previous):
  ActionLaws.guarded_callback(w, depth, rest, stack, body, previous)

def Laws.action_plain_flush_is_a_noop(fuel, w, depth):
  ActionLaws.guarded_flush(fuel, w, depth)

def Laws.action_yield_callback_is_once_only(w, rest, stack, observer, action, rejected, value):
  ActionLaws.duplicate_yield(w, rest, stack, observer, action, rejected, value)

def Laws.action_ignores_a_throw_after_yield_settlement(w, rest, saved, error, observer, action):
  ActionLaws.throw_after_settlement(w, rest, saved, error, observer, action)

def Laws.action_holds_first_slice_write():
  ActionLaws.holds()

def Laws.action_resumed_slice_lands_reconciled_write():
  ActionLaws.lands()


def Laws.scalar_memo_public_setter_reaches_staged_arena(next):
  MemoPublic.constructed_setter(next)

def Laws.scalar_memo_public_constructor_setter_flush_completes(next, extra):
  MemoPublic.public_program(next, extra)


def Laws.scalar_memo_constructor_all_natural_initial_values(initial, extra):
  MemoInitial.all_initials(initial, extra)

def Laws.merged_transactions_sum_open_counts(w, source, target, suffix, reverse):
  TxMerge.open_sum(w, source, target, suffix, reverse)

def Laws.merged_transaction_redirects_to_target(w, source, target, suffix, reverse):
  TxMerge.redirects(w, source, target, suffix, reverse)

def Laws.merged_transactions_preserve_action_marker(w, source, target, suffix, reverse):
  TxMerge.acted_union(w, source, target, suffix, reverse)

def Laws.action_function_creation_has_no_reactive_effect(w, rest, stack, factory, methods, previous):
  ActionFunctions.entry(w, rest, stack, factory, methods, previous)

def Laws.action_function_call_uses_shared_invocation(w, rest, stack, id, tail, first, second, factory, methods, previous):
  ActionFunctions.invocation(w, rest, stack, id, tail, first, second, factory, methods, previous)

def Laws.action_call_parameter_is_captured(first, second, index):
  ActionFunctions.parameter(first, second, index)

def Laws.action_capture_preserves_resume_binder(first, second, depth, index):
  ActionFunctions.resume(first, second, depth, index)

def Laws.nested_action_parameter_shadow_and_capture(first, second):
  ActionFunctions.nested(first, second)

def Laws.callback_action_factory_capture(first, second, methods):
  ActionFunctions.callback_capture(first, second, methods)

def Laws.reusable_action_has_distinct_invocations():
  ActionFunctions.repeated()

def Laws.scalar_memo_public_setter_all_initial_values(initial, input, constructorExtra):
  MemoGeneralSetter.public_program(initial, input, constructorExtra)

def Laws.scalar_memo_public_program_all_initial_values(initial, input, constructorExtra, drainExtra):
  MemoGeneralPublic.complete(initial, input, constructorExtra, drainExtra)

def Laws.changed_memo_publication_stages_then_notifies(w, id, value, height, off, nonEffect, subs):
  ChainPublication.memo_complete(w, id, value, height, StagePublication.staged(w, id, value), PublicationScheduler.insertSubs(StagePublication.staged(w, id, value), id), off, nonEffect, subs, {==}, {==})

def Laws.effect_publication_marks_and_queues_before_store(w, id, value, height, off, effect, subs, fresh, clean, empty, stillEmpty):
  ChainPublication.effect_complete(w, id, value, height, ChainPublication.effect_prepare(w, id), B.store_node(ChainPublication.effect_prepare(w, id), id, R.Node.with_value(B.node(ChainPublication.effect_prepare(w, id), id), value)), off, effect, subs, fresh, clean, empty, {==}, stillEmpty, {==})

def Laws.staged_two_memo_render_graph_completes(input, extra):
  ChainStaging.completed(input, extra)

def Laws.staged_graph_renders_only_its_final_proposal(input, extra):
  ChainObservation.completes(input, extra)

def Laws.two_memo_render_public_setter(input):
  ChainSetter.constructed(input)

def Laws.two_memo_render_public_program(input, extra):
  ChainPublic.complete(input, extra)

def Laws.two_memo_render_public_final_world(input, extra):
  ChainPublic.world(input, extra)

def Laws.two_memo_render_public_application_trace(input, extra):
  ChainPublic.applications(input, extra)

def Laws.vector_callback_parameter(index, values):
  ArgumentVectors.callback_lookup(index, values)

def Laws.vector_action_parameter(index, values):
  ArgumentVectors.action_lookup(index, values)

def Laws.vector_action_preserves_resume_binder(depth, index, values):
  ArgumentVectors.resume(depth, index, values)

def Laws.vector_root_shadows_parameters(body, values):
  ArgumentVectors.root_shadow(body, values)

def Laws.vector_callback_captures_action_factory(index, methods, values):
  ArgumentVectors.callback_factory(index, methods, values)

def Laws.vector_nested_action_shadow_and_capture(inner, outer, values):
  ArgumentVectors.nested_capture(inner, outer, values)

def Laws.vector_call_evaluates_callee_first(w, rest, stack, callee, args, previous):
  ArgumentVectors.callee_first(w, rest, stack, callee, args, previous)

def Laws.vector_call_evaluates_next_argument(w, rest, stack, callee, head, tail, reversed, previous):
  ArgumentVectors.next_argument(w, rest, stack, callee, head, tail, reversed, previous)

def Laws.nine_argument_callback_returns_its_last_parameter():
  ArgumentVectors.callback_complete()

def Laws.nine_argument_action_fulfills_with_its_last_parameter():
  ArgumentVectors.action_complete()

def Laws.direct_owner_uses_ambient_parent(w, rest, stack, transparent, previous):
  DirectOwners.entry(w, rest, stack, transparent, previous)

def Laws.owner_linking_preserves_ambient_state(w, parent, id):
  DirectOwners.link_ambient(w, parent, id)

def Laws.owner_constructor_preserves_ambient_state(w, parent, transparent):
  DirectOwners.creation_ambient(w, parent, transparent)

def Laws.owner_dispose_method_forwards_self_flag(w, rest, stack, id, self, root):
  DirectOwners.disposal(w, rest, stack, id, self, root)

def Laws.direct_owner_can_clear_reuse_and_dispose():
  DirectOwners.lifecycle_complete()

def Laws.cleanup_catch_resumes_teardown(w, rest, stack, saved):
  {==}

def Laws.reaction_returns_captured_node(w, rest, stack, node):
  {==}

def Laws.scalar_memo_second_public_staging(initial, first, input, constructorExtra, firstExtra):
  MemoRepeat.public_staged(initial, first, input, constructorExtra, firstExtra)

def Laws.scalar_memo_two_updates_final_world(initial, first, input, constructorExtra, firstExtra, secondExtra):
  MemoRepeat.world(initial, first, input, constructorExtra, firstExtra, secondExtra)

def Laws.scalar_memo_two_updates_complete(initial, first, input, constructorExtra, firstExtra, secondExtra):
  MemoRepeat.complete(initial, first, input, constructorExtra, firstExtra, secondExtra)

def Laws.scalar_memo_repeatable_public_update(tick, previous, input, events, jobs, extra):
  MemoHistory.update(tick, previous, input, events, jobs, extra)

def Laws.scalar_memo_finite_history_final_world(initial, first, constructorExtra, firstExtra, updates):
  MemoHistory.world(initial, first, constructorExtra, firstExtra, updates)

def Laws.scalar_memo_finite_history_complete(initial, first, constructorExtra, firstExtra, updates):
  MemoHistory.complete(initial, first, constructorExtra, firstExtra, updates)

def Laws.scalar_memo_pending_write_coalesces(tick, previous, pending, input, events, jobs):
  MemoCoalescing.public_setter(tick, previous, pending, input, events, jobs)

def Laws.scalar_memo_batch_stages_last_proposal(tick, previous, first, rest, events, jobs):
  MemoBatches.staged(tick, previous, first, rest, events, jobs)

def Laws.scalar_memo_batched_history_final_world(initial, first, rest, constructorExtra, firstExtra, batches):
  MemoBatches.world(initial, first, rest, constructorExtra, firstExtra, batches)

def Laws.scalar_memo_batched_history_complete(initial, first, rest, constructorExtra, firstExtra, batches):
  MemoBatches.complete(initial, first, rest, constructorExtra, firstExtra, batches)

def Laws.array_holes_have_exact_length(size):
  ArrayLaws.holes_length(size)

def Laws.fresh_array_slots_are_holes(prefix, suffix):
  ArrayLaws.hole_slot(prefix, suffix)

def Laws.dense_array_slot_preserves_payload(prefix, value, suffix):
  ArrayLaws.dense_read(prefix, value, suffix)

def Laws.array_write_retains_present_payload(prefix, old, suffix, value):
  ArrayLaws.slot_put_read(prefix, old, suffix, value)

def Laws.array_allocation_contract(w, slots):
  ArrayLaws.allocation_contract(w, slots)

def Laws.plain_keyed_map_lifecycle():
  MapLifecycle.plain_complete()

def Laws.positional_map_lifecycle():
  MapLifecycle.index_complete()

def Laws.extracted_key_map_lifecycle():
  MapLifecycle.extracted_complete()


def Laws.array_existing_slot_write_preserves_world(w, arraysBefore, slotsBefore, old, slotsAfter, arraysAfter, value):
  ArrayWrite.write(w, arraysBefore, slotsBefore, old, slotsAfter, arraysAfter, value)

def Laws.flatten_deferred_wrapper_reads_committed_values():
  FlattenLifecycle.complete()

def Laws.flatten_wrapper_allocates_function_only(w, results, skip):
  FlattenLifecycle.wrapper(w, results, skip)


def Laws.array_push_appends_exactly(w, arraysBefore, slots, arraysAfter, value):
  ArrayWrite.push(w, arraysBefore, slots, arraysAfter, value)


def Laws.natural_children_complete_program(first, second, extra):
  NaturalFlatten.sufficient(first, second, extra)

def Laws.direct_live_mark_short_circuits_probe(w, node, extension, nodes, extensions, count, active, fuel, seen, rest):
  MarkLaws.direct(w, node, extension, nodes, extensions, count, active, fuel, seen, rest)

def Laws.mark_increments_only_its_two_counts(w, node, extension, nodes, extensions, count, active):
  MarkLaws.increment(w, node, extension, nodes, extensions, count, active)

def Laws.nonlast_mark_does_not_repoll(w, node, extension, nodes, extensions, count, active):
  MarkLaws.nonlast(w, node, extension, nodes, extensions, count, active)

def Laws.inactive_mark_gate_preserves_world(w, id):
  MarkLaws.inactive(w, id)

def Laws.new_lane_allocation_preserves_mainline(w, parent):
  LaneLaws.new_contract(w, parent)

def Laws.cached_verdict_lane_does_not_allocate(w, tx, suffix, cached):
  LaneLaws.cached(w, tx, suffix, cached)

def Laws.shared_nonnull_lane_group_is_one_lane(w, a, b, suffix, group):
  LaneLaws.shared(w, a, b, suffix, group)

def Laws.lane_derivation_staging_is_latest(w, node, suffix, value):
  LaneLaws.staged(w, node, suffix, value)

def Laws.lane_guess_slot_precedes_staging(w, node, extension, nodes, extensions, pending, value):
  LaneLaws.guess(w, node, extension, nodes, extensions, pending, value)

def Laws.quiet_pending_without_extension_is_false(w, node, nodes):
  VerdictLaws.noExtension(w, node, nodes)

def Laws.empty_pending_sources_are_quiet(w, node, extension, nodes, extensions):
  VerdictLaws.emptyIsQuiet(w, node, extension, nodes, extensions)

def Laws.mark_witness_outside_probe_preserves_world(w, state):
  VerdictLaws.witnessInactive(w, state)

def Laws.provisional_probe_waits_for_the_seam(w, node, nodes, unanswered):
  VerdictLaws.provisionalWaits(w, node, nodes, unanswered)

def Laws.joined_verdict_reader_does_not_open_lane(w, node, nodes, tx):
  VerdictLaws.joinedStays(w, node, nodes, tx)

def Laws.held_latest_preserves_raw_staged_error(w, node, nodes, error, reader):
  VerdictLaws.stagedError(w, node, nodes, error, reader)

def Laws.open_transaction_blocks_and_restores_judge(w, tx, rest, count):
  LaneBlockers.openRestoresJudge(w, tx, rest, count)

def Laws.empty_mainline_transaction_is_unblocked(w, tx, rest):
  LaneBlockers.emptyUnblocked(w, tx, rest)

def Laws.linked_peer_open_count_blocks(w, a, b, rest, count):
  LaneBlockers.peerOpenBlocks(w, a, b, rest, count)

def Laws.lane_guess_own_flight_is_observed(w, node, extension, tx, nodes, extensions, rest):
  LaneBlockers.ownGuessFlight(w, node, extension, tx, nodes, extensions, rest)

def Laws.lane_unlink_removes_first_and_preserves_world(w, tx, rest, groupRest, prefix, suffix):
  GroupLaws.unlinkPresent(w, tx, rest, groupRest, prefix, suffix)

def Laws.lane_unlink_absent_member_clears_only_pointer(w, tx, rest, groupRest, prefix):
  GroupLaws.unlinkAbsent(w, tx, rest, groupRest, prefix)

def Laws.lane_link_existing_group_is_exactly_unchanged(w, a, b, rest, group):
  GroupLaws.alreadyLinked(w, a, b, rest, group)

def Laws.lane_self_link_allocates_one_group_and_one_member(w, tx, rest, groups):
  GroupLaws.selfLink(w, tx, rest, groups)

def Laws.lane_stage_cold_unread_pass_preserves_world(w, node, nodes, lane):
  StageLaws.coldLeave(w, node, nodes, lane)

def Laws.lane_stage_memo_entry_clears_staging_and_lists(w, node, extension, tx, nodes, extensions, txs):
  StageLaws.memoEnters(w, node, extension, tx, nodes, extensions, txs)

def Laws.lane_stage_failed_effect_marks_and_lists(w, node, extension, tx, nodes, extensions, txs):
  StageLaws.failedEffectEnters(w, node, extension, tx, nodes, extensions, txs)

def Laws.lane_stage_frame_pending_stays_out_of_lane(w, node, source, nodes, lane):
  StageLaws.pendingEffectStays(w, node, source, nodes, lane)

def Laws.cleanup_policy_first_error_is_collected(w, cause):
  CleanupPolicy.first_error_is_collected(w, cause)

def Laws.cleanup_policy_later_error_keeps_first(w, first, later):
  CleanupPolicy.later_error_keeps_first(w, first, later)

def Laws.cleanup_policy_rethrow_clears_box_and_keeps_payload(w, cause):
  CleanupPolicy.rethrow_clears_box_and_keeps_payload(w, cause)

def Laws.cleanup_policy_drop_preserves_fault_and_world(w, cause):
  CleanupPolicy.drop_preserves_fault_and_world(w, cause)

def Laws.cleanup_policy_root_inside_flush_defers(w):
  CleanupPolicy.root_inside_flush_defers(w)

def Laws.cleanup_policy_already_halted_keeps_collector(w, cause):
  CleanupPolicy.already_halted_keeps_collector(w, cause)

def Laws.cleanup_policy_first_halt_drops_collector(w, cause):
  CleanupPolicy.first_halt_drops_collector(w, cause)

def Laws.question_order_reflexive(q):
  QuestionOrder.reflexive(q)

def Laws.question_order_swapped(a, b):
  QuestionOrder.swapped(a, b)

def Laws.question_order_equality_coherent(a, b):
  QuestionOrder.equality(a, b)

def Laws.question_order_irreflexive(q):
  QuestionOrder.irreflexive(q)

def Laws.unstamped_answer_is_not_stale(w, id):
  QuestionOrder.unstamped(w, id)

def Laws.raw_lane_comparator_has_no_status_catch(w, rest, stack, id, a, b, known):
  LaneReadLaws.rawCustom(w, rest, stack, id, a, b, known)

def Laws.plain_truth_preserves_world_and_operands(w, rest, stack, id, g, p, o):
  LaneReadLaws.plainTruth(w, rest, stack, id, g, p, o)

def Laws.pending_lane_read_keeps_fallthrough_token(w, rest, stack, reader, id, lane):
  LaneReadLaws.pendingLanePass(w, rest, stack, reader, id, lane)

def Laws.lane_leaked_seam_holds_without_reveal(w, rest, stack, lane):
  LaneLifecycle.leakedSeam(w, rest, stack, lane)

def Laws.lane_committed_effect_skips_value_comparison(w, rest, stack, id, shown):
  LaneLifecycle.effectCommit(w, rest, stack, id, shown)

def Laws.lane_end_starts_live_reverse_scan(w, rest, stack, parent):
  LaneLifecycle.reverseEndEntry(w, rest, stack, parent)

def Laws.lane_confirmation_stages_truth_without_joining_parent(w, rest, stack, id, parent, value):
  LaneLifecycle.confirmationEnd(w, rest, stack, id, parent, value)

def Laws.lane_hidden_correction_clears_frame_flags(w, rest, stack, id):
  LaneLifecycle.hiddenCorrection(w, rest, stack, id)

def Laws.lane_answer_errored_outcome_leaves_world(w, rest, stack, id, value):
  LaneAnswers.erroredOutcome(w, rest, stack, id, value)

def Laws.lane_answer_correction_captures_current_lane_snapshot(w, rest, stack):
  LaneAnswers.snapshotEntry(w, rest, stack)

def Laws.lane_answer_empty_correction_scan_returns_judgment(w, rest, stack, judged):
  LaneAnswers.emptyCorrections(w, rest, stack, judged)

def Laws.lane_answer_setter_routes_override_before_mainline_join(w, rest, stack, id, current, value, known):
  LaneAnswers.writeDispatch(w, rest, stack, id, current, value, known)

def Laws.lane_answer_read_lane_token_uses_real_pending_tail(w, rest, stack, id, reader, forced):
  LaneAnswers.fallthrough(w, rest, stack, id, reader, forced)

def Laws.lane_answer_read_lane_undefined_is_a_success(w, rest, stack, id, reader, forced):
  LaneAnswers.undefinedRead(w, rest, stack, id, reader, forced)

def Laws.lane_guess_newest_queued_value_wins(w, prefix, id, value, q):
  GuessLaws.newestWins(w, prefix, id, value, q)

def Laws.lane_guess_empty_queue_has_no_guess(w, id):
  GuessLaws.emptyLookup(w, id)

def Laws.lane_guess_empty_application_records_preexisting_prefix(w, rest, stack, parent):
  GuessLaws.judgedEmpty(w, rest, stack, parent)

def Laws.lane_guess_equal_plain_write_does_not_queue(w, rest, stack, id, value, known):
  GuessLaws.equalOrdinary(w, rest, stack, id, value, known)

def Laws.lane_guess_equal_guess_write_renews_question(w, rest, stack, id, value, known):
  GuessLaws.equalGuessReasks(w, rest, stack, id, value, known)

def Laws.lane_guess_unstamped_write_allocates_exact_question(w, id, value):
  GuessLaws.unstampedPush(w, id, value)

def Laws.lane_guess_null_leaks_still_reveal_prefix(w, rest, stack):
  GuessLaws.nullSeams(w, rest, stack)

def Laws.lane_guess_reveals_are_capped_to_current_prefix(w, rest, stack, leaked):
  GuessLaws.emptyLeaks(w, rest, stack, leaked)

def Laws.lane_guess_zero_reveals_continue_entered_reader_drain(w, rest, stack, leaked):
  GuessLaws.zeroReveal(w, rest, stack, leaked)

def Laws.scalar_strict_signed_zero(n):
  SignedZero.strictZero(n)

def Laws.scalar_strict_reverse_signed_zero(n):
  SignedZero.reverseStrictZero(n)

def Laws.scalar_negative_zero_is_falsey():
  SignedZero.falseyZero()

def Laws.scalar_object_is_distinguishes_sign(n):
  SignedZero.objectZero(n)

def Laws.scalar_object_is_identifies_nan():
  SignedZero.objectNaN()

def Laws.scalar_signed_zero_addition(n):
  SignedZero.addition(n)

def Laws.scalar_signed_zero_multiplication(n):
  SignedZero.multiplication(n)

def Laws.scalar_signed_zero_message():
  SignedZero.zeroMessage()

def Laws.lane_pass_pending_slot_precedes_lane(w, id, present):
  PassLaws.pendingFirst(w, id, present)

def Laws.lane_pass_non_effect_never_queues_run(w, id, value, create, changed, lane):
  PassLaws.nonEffectNoRun(w, id, value, create, changed, lane)

def Laws.lane_pass_unchanged_never_queues_run(w, id, value, create, effect, lane):
  PassLaws.unchangedNoRun(w, id, value, create, effect, lane)

def Laws.lane_pass_without_mount_joins_only_held_reads(w, id, previous, old):
  PassLaws.noMountJoin(w, id, previous, old)

def Laws.lane_pass_restores_captured_mount(w, previous, old, mount):
  PassLaws.restoreCapturedMount(w, previous, old, mount)

def Laws.lane_pass_accepted_truth_skips_ordinary_store(w, rest, stack, id, value, create, height, outgoing, sources, wasSource, joined, changed):
  PassLaws.handledOutcome(w, rest, stack, id, value, create, height, outgoing, sources, wasSource, joined, changed)

def Laws.lane_flush_render_queue_order(parked, own, lanes, landing):
  FlushLaws.renderOrder(parked, own, lanes, landing)

def Laws.lane_flush_user_queue_order(parked, own, lanes, landing):
  FlushLaws.userOrder(parked, own, lanes, landing)

def Laws.lane_flush_captured_null_join_stays_mainline(w, rest, stack):
  FlushLaws.capturedNoJoin(w, rest, stack)

def Laws.lane_flush_landing_follows_lane_end(w, rest, stack, frame, tx):
  FlushLaws.landingEntry(w, rest, stack, frame, tx)

def Laws.lane_flush_ineligible_parked_zombie_is_skipped(w, rest, stack, tx, id, tail, ineligible):
  FlushLaws.skipParkedZombie(w, rest, stack, tx, id, tail, ineligible)

def Laws.optimistic_free_data_complete_program(initial, next, last, extra):
  OptimisticProgram.complete(initial, next, last, extra)

def Laws.optimistic_free_data_keeps_authoritative_value(initial, next, last, extra):
  OptimisticProgram.result(initial, next, last, extra)

def Laws.verdict_window_latestReturn(w, rest, stack, saved, latest, dispatch):
  WindowLaws.latestReturn(w, rest, stack, saved, latest, dispatch)

def Laws.verdict_window_latestThrow(w, rest, stack, saved, latest, dispatch):
  WindowLaws.latestThrow(w, rest, stack, saved, latest, dispatch)

def Laws.verdict_window_probeReturn(w, rest, stack, saved, probing, found, dispatch):
  WindowLaws.probeReturn(w, rest, stack, saved, probing, found, dispatch)

def Laws.verdict_window_probeNumeric(w, rest, saved, probing, found, dispatch, cause):
  WindowLaws.probeNumeric(w, rest, saved, probing, found, dispatch, cause)

def Laws.verdict_window_probeLoadingOwned(w, rest, saved, probing, found, dispatch, identity, source):
  WindowLaws.probeLoadingOwned(w, rest, saved, probing, found, dispatch, identity, source)

def Laws.verdict_window_probeLoadingFound(w, rest, saved, probing, found, dispatch, identity, source):
  WindowLaws.probeLoadingFound(w, rest, saved, probing, found, dispatch, identity, source)

def Laws.verdict_window_probeLoadingOutside(w, rest, saved, probing, found, dispatch, identity, source):
  WindowLaws.probeLoadingOutside(w, rest, saved, probing, found, dispatch, identity, source)

def Laws.verdict_window_complete_program(initial, next, extra):
  VerdictProgram.complete(initial, next, extra)

def Laws.verdict_window_read_value(initial, next, extra):
  VerdictProgram.result(initial, next, extra)

def Laws.affects_scope_invalidNumber(w, value):
  AffectsLaws.invalidNumber(w, value)

def Laws.affects_scope_pushNone(node):
  AffectsLaws.pushNone(node)

def Laws.affects_scope_pushSome(items, node):
  AffectsLaws.pushSome(items, node)

def Laws.affects_scope_releaseEmpty(w):
  AffectsLaws.releaseEmpty(w)

def Laws.affects_scope_releaseAbsent(w, t):
  AffectsLaws.releaseAbsent(w, t)

def Laws.affects_scope_pendingShortCircuit(w, node, pending):
  AffectsLaws.pendingShortCircuit(w, node, pending)

def Laws.affects_scope_ambientEmpty(w, parked):
  AffectsLaws.ambientEmpty(w, parked)

def Laws.affects_complete_program(initial, extra):
  AffectsProgram.complete(initial, extra)

def Laws.affects_pending_before_after(initial, extra):
  AffectsProgram.result(initial, extra)

def Laws.deferred_lag_noWork(w, fuel, lagging, seen):
  DeferredLaws.noWork(w, fuel, lagging, seen)

def Laws.deferred_lag_noLagging(w, node):
  DeferredLaws.noLagging(w, node)

def Laws.deferred_lag_exhausted(w, lagging, task, rest, seen):
  DeferredLaws.exhausted(w, lagging, task, rest, seen)

def Laws.deferred_lag_direct(w, tail, rest, seen, fuel):
  DeferredLaws.direct(w, tail, rest, seen, fuel)

def Laws.deferred_lag_membershipBeforeSeen(w, tail, rest, seen, fuel):
  DeferredLaws.membershipBeforeSeen(w, tail, rest, seen, fuel)

def Laws.deferred_lag_nextAtTail(w, lagging, rest, seen, fuel):
  DeferredLaws.nextAtTail(w, lagging, rest, seen, fuel)

def Laws.deferred_lag_emptyDeps(w, lagging, rest, seen, fuel, tail):
  DeferredLaws.emptyDeps(w, lagging, rest, seen, fuel, tail)

def Laws.deferred_lag_worldFrame(fuel, w, lagging, work, seen):
  DeferredLaws.worldFrame(fuel, w, lagging, work, seen)

def Laws.deferred_life_nullLand(w, state, held):
  DeferredLifeLaws.nullLand(w, state, held)

def Laws.deferred_life_staleLand(w, node, marked, answered, lagging, held):
  DeferredLifeLaws.staleLand(w, node, marked, answered, lagging, held)

def Laws.deferred_life_unmarkedLand(w, node, answered, lagging):
  DeferredLifeLaws.unmarkedLand(w, node, answered, lagging)

def Laws.deferred_life_markedAsk(w, node, prior, flight, answered, lagging):
  DeferredLifeLaws.markedAsk(w, node, prior, flight, answered, lagging)

def Laws.deferred_life_idleEnd(w, node, marked, answered, lagging):
  DeferredLifeLaws.idleEnd(w, node, marked, answered, lagging)

def Laws.deferred_life_emptyHeld(fuel, w, node):
  DeferredLifeLaws.emptyHeld(fuel, w, node)

def Laws.deferred_caught_fault(w, cell, open, error, rest, saved):
  DeferredCatch.caught(w, cell, open, error, rest, saved)

def Laws.deferred_life_closedFailure(w, state, error):
  DeferredLifeLaws.closedFailure(w, state, error)

def Laws.deferred_life_plainUnmarkedFailure(w, node, flight, error, answered, lagging):
  DeferredLifeLaws.plainUnmarkedFailure(w, node, flight, error, answered, lagging)

def Laws.deferred_life_unreadyFailure(w, state, identity, source):
  DeferredLifeLaws.unreadyFailure(w, state, identity, source)

def Laws.deferred_life_answeredSticky(w, node, flight, marked, lagging):
  DeferredLifeLaws.answeredSticky(w, node, flight, marked, lagging)

def Laws.deferred_data_complete(initial, next, extra):
  DeferredProgram.complete(initial, next, extra)

def Laws.deferred_data_result(initial, next, extra):
  DeferredProgram.result(initial, next, extra)

def Laws.deferred_stream_complete(initial, next, extra):
  DeferredStreamProgram.complete(initial, next, extra)

def Laws.deferred_stream_result(initial, next, extra):
  DeferredStreamProgram.result(initial, next, extra)

def Laws.deferred_stream_first_throw(w, id, error):
  DeferredStreamLaws.firstThrow(w, id, error)

def Laws.deferred_stream_unresolved(w, id, observer, immediate):
  DeferredStreamLaws.unresolved(w, id, observer, immediate)

def Laws.deferred_stream_missing_return(w):
  DeferredStreamLaws.missing(w)

def Laws.deferred_stream_undefined_return(w):
  DeferredStreamLaws.undefinedReturn(w)

def Laws.deferred_stream_null_return(w):
  DeferredStreamLaws.nullReturn(w)

def Laws.deferred_stream_nonnull_return(w, value, plain):
  DeferredStreamLaws.nonnullReturn(w, value, plain)

def Laws.deferred_stream_promise_return(w, result):
  DeferredStreamLaws.promiseReturn(w, result)

def Laws.deferred_stream_throw_return(w, error):
  DeferredStreamLaws.throwReturn(w, error)

def Laws.deferred_stream_done_world(w):
  DeferredStreamLaws.doneWorld(w)

def Laws.deferred_stream_done_value(w):
  DeferredStreamLaws.doneValue(w)

def Laws.deferred_stream_serve_unwind(w, cell, rest, stack):
  DeferredStreamLaws.serveUnwind(w, cell, rest, stack)

def Laws.deferred_payload_complete(initial, next, extra):
  DeferredPayloadProgram.complete(initial, next, extra)

def Laws.deferred_payload_result(initial, next, extra):
  DeferredPayloadProgram.result(initial, next, extra)

def Laws.deferred_payload_numeric_specialization(initial, next):
  DeferredPayloadProgram.specializesNumeric(initial, next)

def Laws.landing_release_callback(w, transaction, rest, stack, ready):
  LandingRelease.callback(w, transaction, rest, stack, ready)

def Laws.landing_release_world_frame(w, transaction):
  LandingRelease.frame(w, transaction)

def Laws.async_error_retires_parked_frame_after_notify(w, rest, stack, id, error):
  ErrorRetirement.published(w, rest, stack, id, error)

def Laws.async_staged_error_preserves_parked_frame(w, rest, stack, id, error):
  ErrorRetirement.staged(w, rest, stack, id, error)

def Laws.async_pending_transfer_preserves_parked_frame(w, rest, stack, id, error, staged):
  ErrorRetirement.pending(w, rest, stack, id, error, staged)

def Laws.async_rejected_replacement_releases_displayed_frame():
  CleanupProgram.replacement_error_releases_displayed_frame()

def Laws.supersede_reflexive(slot):
  SupersedeLaws.reflexive(slot)

def Laws.supersede_undefined_not_null():
  SupersedeLaws.undefinedNotNull()

def Laws.supersede_null_not_undefined():
  SupersedeLaws.nullNotUndefined()

def Laws.supersede_active_identity(result):
  SupersedeLaws.activeIdentity(result)

def Laws.supersede_absent(w, id, known):
  SupersedeLaws.absent(w, id, known)

def Laws.supersede_ineligible(w, callback, known):
  SupersedeLaws.ineligible(w, callback, known)

def Laws.supersede_unowned(w, callback, known):
  SupersedeLaws.unowned(w, callback, known)

def Laws.supersede_chain_world(w, before, after):
  SupersedeLaws.chainWorld(w, before, after)

def Laws.supersede_chain_identity(w, before, after):
  SupersedeLaws.chainIdentity(w, before, after)

def Laws.supersede_finally_entry(w, rest, callback, saved):
  SupersedeLaws.finallyEntry(w, rest, callback, saved)

def Laws.supersede_finally_return(w, rest, stack, callback, saved):
  SupersedeLaws.finallyReturn(w, rest, stack, callback, saved)

def Laws.supersede_finally_throw(w, rest, stack, callback, saved):
  SupersedeLaws.finallyThrow(w, rest, stack, callback, saved)

def Laws.supersede_restore_success(w, rest, stack, prior, saved):
  SupersedeLaws.restoreSuccess(w, rest, stack, prior, saved)

def Laws.supersede_override_failure(w, rest, stack, prior, saved):
  SupersedeLaws.overrideFailure(w, rest, stack, prior, saved)

def Laws.supersede_chain_continuation(w, rest, stack, id, tail, first, second, before, after):
  SupersedeLaws.chainContinuation(w, rest, stack, id, tail, first, second, before, after)

def Laws.from_settle_no_wait(w, plan, known):
  FromLaws.settleNoWait(w, plan, known)

def Laws.from_emitted_done(w, plan, value, known):
  FromLaws.emittedDone(w, plan, value, known)

def Laws.from_closed_noop(w, plan, known):
  FromLaws.closedNoop(w, plan, known)

def Laws.from_close_open(w, plan, known):
  FromLaws.closeOpen(w, plan, known)

def Laws.from_finish_no_wait(w, plan, known):
  FromLaws.finishNoWait(w, plan, known)

def Laws.from_allocate_world(w, state):
  FromLaws.allocateWorld(w, state)

def Laws.from_allocate_identity(w, state):
  FromLaws.allocateIdentity(w, state)

def Laws.from_fulfilled(w, id, rejected, value, object, prior):
  FromLaws.fulfilled(w, id, rejected, value, object, prior)

def Laws.from_rejected(w, id, rejected, value, object, prior):
  FromLaws.rejected(w, id, rejected, value, object, prior)

def Laws.from_no_observers(w, rejected, value):
  FromLaws.noObservers(w, rejected, value)

def Laws.from_cleanup_throw(w, rest, saved, cause):
  FromLaws.cleanupThrow(w, rest, saved, cause)

def Laws.from_cleanup_type_error(w, rest, saved):
  FromLaws.cleanupTypeError(w, rest, saved)

def Laws.from_preserve_exhaustion(w, rest, saved):
  FromLaws.preserveExhaustion(w, rest, saved)

def Laws.from_finished(w, rest, stack, plan):
  FromLaws.finished(w, rest, stack, plan)

def Laws.from_program_complete(input, extra):
  FromProgram.complete(input, extra)

def Laws.from_program_value_cleanup(input, extra):
  FromOutcome.result(input, extra)

def Laws.from_wrap_bare(w, plan, done, value):
  FromWrapLaws.bare(w, plan, done, value)

def Laws.from_wrap_thrown(w, plan, error):
  FromWrapLaws.thrown(w, plan, error)

def Laws.from_wrap_unresolved(w, plan, output, observer, immediate):
  FromWrapLaws.unresolved(w, plan, output, observer, immediate)

def Laws.from_wrap_canceled_delivery(w, plan, output, rejected, value, known):
  FromWrapLaws.canceledDelivery(w, plan, output, rejected, value, known)

def Laws.from_wrap_no_pending(w):
  FromWrapLaws.noPending(w)

def Laws.from_wrap_no_waits(observer):
  FromWrapLaws.noWaits(observer)

def Laws.from_wrap_no_plans(observer, id):
  FromWrapLaws.noPlans(observer, id)

def Laws.from_wrap_remove_empty(id):
  FromWrapLaws.removeEmpty(id)

def Laws.from_wrap_return_throw(w, rest, saved, cause):
  FromWrapLaws.returnThrow(w, rest, saved, cause)

def Laws.from_wrap_return_type_error(w, rest, saved):
  FromWrapLaws.returnTypeError(w, rest, saved)

def Laws.from_wrap_preserve_exhaustion(w, rest, saved):
  FromWrapLaws.preserveExhaustion(w, rest, saved)

def Laws.from_wrap_already_closed(w, rest, stack, id, tail, first, second, plan, known):
  FromWrapLaws.alreadyClosed(w, rest, stack, id, tail, first, second, plan, known)

def Laws.from_iterable_program_complete(input, extra):
  FromIterableProgram.complete(input, extra)

def Laws.from_iterable_program_cancels_pull(input, extra):
  FromIterableOutcome.result(input, extra)

def Laws.from_wrap_cached_iterator(w, rest, stack, source, ordinary, cached):
  FromWrapLaws.cachedIterator(w, rest, stack, source, ordinary, cached)

def Laws.from_value_program_complete(input, extra):
  FromValueProgram.complete(input, extra)

def Laws.from_value_program_result(input, extra):
  FromValueOutcome.result(input, extra)

def Laws.from_iterable_value_program_complete(input, extra):
  FromIterableValueProgram.complete(input, extra)

def Laws.from_iterable_value_program_result(input, extra):
  FromIterableValueOutcome.result(input, extra)

def Laws.from_value_ordinary_bridge(input):
  FromValueBridges.subscription(input)

def Laws.from_iterable_value_ordinary_bridge(input):
  FromValueBridges.iterable(input)

def Laws.from_promise_deliveries_frame(observers, w, rejected, value):
  FromPromiseFrame.deliveries(observers, w, rejected, value)

def Laws.from_promise_settlement_frame(w, id, rejected, value, object, state):
  FromPromiseFrame.settlement(w, id, rejected, value, object, state)

def Laws.from_promise_settle_frame(w, id, rejected, value):
  FromPromiseFrame.settle(w, id, rejected, value)

def Laws.from_pending_frame(items, w):
  FromPromiseFrame.pending(items, w)

def Laws.from_finish_frame(w, plan):
  FromPromiseFrame.finish(w, plan)

def Laws.from_callback_delivery_frame(w, plan, output, rejected, value):
  FromPromiseFrame.deliver(w, plan, output, rejected, value)

def Laws.redirect_path_resolves(w, path, extra):
  RedirectPaths.resolves(w, path, extra)

def Laws.redirect_public_resolves(w, path, extra, room):
  RedirectPaths.public(w, path, extra, room)

def Laws.new_transaction_root(w, lane, parent):
  RedirectPaths.freshInto(w, lane, parent)

def Laws.same_representative_merge(w, source, target, root, first, second):
  RedirectPaths.common(w, source, target, root, first, second)

def Laws.action_completion_representative(w, id, root, remaining, resolution, open):
  ActionRouting.decreases(w, id, root, remaining, resolution, open)

def Laws.action_completion_route(w, id, path, extra, remaining, captured, room, open):
  ActionRouting.fromRoute(w, id, path, extra, remaining, captured, room, open)

def Laws.transaction_rejoin_histories(w, root, events):
  RejoinHistories.preserves(w, root, events)

def Laws.distinct_transaction_join_world(w, prefix, left, gap, right, suffix, reverse):
  JoinedPair.merge(w, prefix, left, gap, right, suffix, reverse)

def Laws.joined_source_resolves(w, prefix, left, gap, right, suffix, reverse):
  JoinedPair.sourceResolves(w, prefix, left, gap, right, suffix, reverse)

def Laws.joined_target_resolves(w, prefix, left, gap, right, suffix, reverse):
  JoinedPair.targetResolves(w, prefix, left, gap, right, suffix, reverse)

def Laws.joined_obligations(w, prefix, left, gap, right, suffix, reverse):
  JoinedPair.count(w, prefix, left, gap, right, suffix, reverse)

def Laws.joined_action_completion(w, prefix, left, gap, right, suffix, reverse, retired, id, remaining, captured, positive):
  JoinedAction.completion(w, prefix, left, gap, right, suffix, reverse, retired, id, remaining, captured, positive)

def Laws.action_open_allocated(w, arena, before, entry, after):
  ActionOpening.allocated(w, arena, before, entry, after)

def Laws.action_open_captured(w, arena, before, entry, after):
  ActionOpening.captured(w, arena, before, entry, after)

def Laws.action_open_obligation(w, arena, before, entry, after):
  ActionOpening.obligation(w, arena, before, entry, after)


def Laws.distinct_join_rejoin_histories(w, prefix, left, gap, right, suffix, reverse, events):
  JoinedHistory.joined(w, prefix, left, gap, right, suffix, reverse, events)

def Laws.constructed_action_opens(w, arena, cells, methods):
  ActionCreated.opens(w, arena, cells, methods)

def Laws.constructed_action_captured(w, arena, cells, methods):
  ActionCreated.captures(w, arena, cells, methods)

def Laws.constructed_action_obligation(w, arena, cells, methods):
  ActionCreated.obligation(w, arena, cells, methods)

def Laws.action_pair_allocated_slots(w, before, cells, first, other):
  ActionPair.arena(w, before, cells, first, other)

def Laws.action_pair_joined_open_count(w, before, cells, first, other, reverse):
  ActionPair.two(w, before, cells, first, other, reverse)

def Laws.action_pair_first_completion(w, before, cells, first, other, reverse, finishSecond):
  ActionPair.completeFirst(w, before, cells, first, other, reverse, finishSecond)

def Laws.action_pair_rejoin_history(w, before, cells, first, other, reverse, events):
  ActionPair.history(w, before, cells, first, other, reverse, events)

def Laws.action_pair_first_completion_after_history(w, before, cells, first, other, reverse, finishSecond, events):
  ActionPair.completeAfterHistory(w, before, cells, first, other, reverse, finishSecond, events)

def Laws.scheduling_preserves_action_ledger(w):
  ScheduleFrame.preserves(w)

def Laws.positive_transaction_blocks_exact_world(w, tx, remaining, healthy, positive):
  PositiveBlocker.public(w, tx, remaining, healthy, positive)

def Laws.constructed_action_pair_blocks(w, before, cells, first, other, reverse, healthy):
  ActionBlocker.blocked(w, before, cells, first, other, reverse, healthy)

def Laws.constructed_action_pair_history_blocks(w, before, cells, first, other, reverse, events, healthy):
  ActionBlocker.afterHistory(w, before, cells, first, other, reverse, events, healthy)

def Laws.first_action_completion_still_blocks(w, before, cells, first, other, reverse, finishSecond, healthy):
  ActionBlockerFinish.afterOne(w, before, cells, first, other, reverse, finishSecond, healthy)

def Laws.first_action_completion_after_history_still_blocks(w, before, cells, first, other, reverse, finishSecond, events, healthy):
  ActionBlockerFinish.afterHistory(w, before, cells, first, other, reverse, finishSecond, events, healthy)


def Laws.counted_pair_update_preserves_world(w, before, reverse, old, next):
  CountedPair.update(w, before, reverse, old, next)

def Laws.counted_pair_original_source_resolves(w, before, reverse, count):
  CountedPair.sourceResolves(w, before, reverse, count)

def Laws.constructed_pair_both_completion_histories(w, before, cells, first, other, reverse, second, initial, middle, final):
  PairCompletion.constructed(w, before, cells, first, other, reverse, second, initial, middle, final)

def Laws.completed_pair_certificate_has_zero_debt(w, before, reverse, firstId, otherId, initial, middle, final, certificate):
  PairCompletion.zeroCertified(w, before, reverse, firstId, otherId, initial, middle, final, certificate)

def Laws.action_wait_marking_reaches_lookup(waits, id):
  WaitSettlement.findMarked(waits, id)

def Laws.settled_action_wait_stays_settled(events, waits, id, action, settled, found):
  WaitSettlement.markedHistory(events, waits, id, action, settled, found)

def Laws.settled_action_wait_history_rejects_duplicate(w, rest, stack, events, waits, id, action, settled, rejected, value, found):
  WaitSettlement.duplicateHistory(w, rest, stack, events, waits, id, action, settled, rejected, value, found)


def Laws.empty_ordinary_transaction_is_eligible(w, tx, healthy, zero, empty, ordinary, noLanes):
  EmptyBlocker.public(w, tx, healthy, zero, empty, ordinary, noLanes)

def Laws.constructed_completed_pair_is_eligible(w, before, cells, first, other, reverse, second, initial, middle, final, healthy, noLanes):
  PairEligibility.constructed(w, before, cells, first, other, reverse, second, initial, middle, final, healthy, noLanes)


def Laws.landing_scan_retains_positive_group(w, rest, stack, frame, index, predecessor, remaining, lookup, healthy, open):
  LandingScan.positive(w, rest, stack, frame, index, 1n+predecessor, remaining, lookup, healthy, open)

def Laws.first_action_completion_is_retained_by_landing_scan(w, before, cells, first, other, reverse, finishSecond, events, rest, stack, frame, index, healthy, lookup):
  LandingScan.afterOne(w, before, cells, first, other, reverse, finishSecond, events, rest, stack, frame, index, healthy, lookup)


def Laws.terminal_node_membership_preserves_world(w, id, owner, captured, stopped):
  TerminalMembership.terminal(w, id, owner, captured, stopped)


def Laws.zero_action_rendered_group_still_blocks(w, predecessor, prefix, id, tail, healthy, zero, nodes, active, capture, stopped, rendered, live):
  RenderedGraph.renderGroup(w, predecessor, prefix, id, tail, healthy, zero, nodes, active, capture, stopped, rendered, live)


def Laws.live_pending_subscriber_blocks(w, edge, owner, extra, valid, live):
  RenderedGraph.subscriber(w, edge, owner, extra, valid, live)


def Laws.current_generation_pending_reader_is_valid(w, edge, reads, generation, alive):
  RenderedGraph.currentReader(w, edge, reads, generation, alive)


def Laws.rendered_flight_is_retained_by_landing_scan(w, predecessor, prefix, id, tail, rest, stack, frame, index, lookup, healthy, zero, nodes, active, capture, stopped, rendered, live):
  RenderedLanding.retained(w, predecessor, prefix, id, tail, rest, stack, frame, index, lookup, healthy, zero, nodes, active, capture, stopped, rendered, live)


def Laws.completion_prefix_preserves_graph(w, id, root, remaining, resolution, positive):
  CompletionGraphFrame.completion(w, id, root, remaining, resolution, positive)


def Laws.allocated_completion_retains_owned_work(w, before, record, after, id, remaining, captured, stopped, positive):
  OwnedCompletion.allocated(w, before, record, after, id, remaining, captured, stopped, positive)


def Laws.completion_preserves_pending_rendered_snapshot(w, id, root, remaining, snapshot, resolution, positive):
  CompletionPending.completed(w, id, root, remaining, snapshot, resolution, positive)


def Laws.pending_rendered_completion_history(w, predecessor, programme, snapshot, healthy):
  RenderedHistory.certify(w, predecessor, programme, snapshot, healthy)


def Laws.rendered_completion_history_preserves_graph(w, root, programme, certificate):
  RenderedHistory.graphResult(w, root, programme, certificate)


def Laws.rendered_completion_history_checks_hold(w, root, programme, certificate):
  RenderedHistory.checksResult(w, root, programme, certificate)


def Laws.fresh_list_captures_and_appends(w, id, predecessor, slot, allocated, unowned):
  ListConstruction.fresh(w, id, predecessor, slot, allocated, unowned)


def Laws.fresh_list_constructs_pending_rendered_snapshot(w, id, before, record, after, extBefore, extRecord, extAfter, prefix, storage, index, extStorage, unowned, owns, active, stopped, rendered, live):
  ListConstruction.pending(w, id, before, record, after, extBefore, extRecord, extAfter, prefix, storage, index, extStorage, unowned, owns, active, stopped, rendered, live)


def Laws.fresh_list_enters_pending_rendered_history(w, id, before, record, after, extBefore, extRecord, extAfter, prefix, storage, index, extStorage, unowned, owns, active, stopped, rendered, live, healthy, programme):
  ListConstruction.beginHistory(w, id, before, record, after, extBefore, extRecord, extAfter, prefix, storage, index, extStorage, unowned, owns, active, stopped, rendered, live, healthy, programme)


def Laws.same_capture_list_is_exact_identity(w, id, tx, slot, allocated, capture):
  ListConstruction.repeated(w, id, tx, slot, allocated, capture)


def Laws.heap_marking_preserves_committed_observation(fuel, w, work):
  HeapStorage.markWork(fuel, w, work)


def Laws.staging_preserves_committed_observation(w, id, value):
  StagedStorage.stages(w, id, value)


def Laws.resolved_setter_preserves_committed_observation(w, id, current, value):
  SetterStorage.resolved(w, id, current, value)


def Laws.ordinary_core_setter_preserves_committed_observation(w, rest, stack, id, current, value, override, custom):
  OrdinaryStorage.ordinary(w, rest, stack, id, current, value, override, custom)


def Laws.ordinary_core_setter_returns_resolved_argument(w, rest, stack, id, current, value, override, custom):
  OrdinaryStorage.result(w, rest, stack, id, current, value, override, custom)


def Laws.staging_write_history_preserves_committed_observation(writes, w):
  StagingHistory.preserves(writes, w)


def Laws.flight_status_landing_preserves_committed_observation(w, id, clearUninitialized):
  FlightStorage.landed(w, id, clearUninitialized)


def Laws.flight_write_prefix_preserves_committed_observation(w, id, result, value):
  FlightStorage.write(w, id, result, value)


def Laws.stale_flight_prefix_is_exact_identity(w, id, result, obsolete):
  FlightStorage.stale(w, id, result, obsolete)


def Laws.ordinary_async_prefix_keeps_source_branch(w, rest, stack, id, result, value, then, custom, override):
  AsyncPrefix.exact(w, rest, stack, id, result, value, then, custom, override)


def Laws.ordinary_async_prefix_preserves_committed_observation(w, rest, stack, id, result, value, then, custom, override):
  AsyncPrefix.observed(w, rest, stack, id, result, value, then, custom, override)


def Laws.ordinary_async_prefix_preserves_caller_stack(w, rest, values, id, result, value, then, custom, override):
  AsyncPrefix.stack(w, rest, values, id, result, value, then, custom, override)


def Laws.async_prefix_queues_exact_followup_order(w, rest, stack, id, then):
  AsyncPrefix.afterExact(w, rest, stack, id, then)


def Laws.present_source_removal_retains_distinct_target(xs, removed, kept, removedLocation, keptLocation, different):
  LiveMembership.retained(xs, removed, kept, removedLocation, keptLocation, different)


def Laws.constructed_joined_representative_is_live(w, before, cells, first, other, reverse):
  ActionMembership.joined(w, before, cells, first, other, reverse)


def Laws.completion_prefix_preserves_live_list(w, id):
  ActionMembership.doneLive(w, id)


def Laws.constructed_first_completion_derives_scan_selection(w, before, cells, first, other, reverse, finishSecond, events, rest, stack, frame, healthy):
  ConstructedScan.constructed(w, before, cells, first, other, reverse, finishSecond, events, rest, stack, frame, healthy)


def Laws.rendered_completion_history_preserves_live_list(w, root, programme, certificate):
  CompletionMembership.observed(w, root, programme, certificate)


def Laws.rendered_completion_history_retains_live_occurrence(w, root, programme, certificate, location):
  CompletionMembership.retained(w, root, programme, certificate, location)


def Laws.rendered_completion_history_derives_held_scan(w, predecessor, programme, certificate, location, rest, stack, frame):
  HistoryLanding.after(w, predecessor, programme, certificate, location, rest, stack, frame)


def Laws.deferred_result_return_closes_protocol_catch(cell, open, saved, rest):
  DeferredProtocolScope.closes(cell, open, saved, rest)

def Laws.deferred_protocol_throw_uses_shared_source_catch(w, cell, open, saved, rest, stack):
  DeferredProtocolScope.catches(w, cell, open, saved, rest, stack)


def Laws.pending_step_preserves_arbitrary_caller_stack(w, rest, stack, tasks, visited, released, scheduled):
  PendingContinuation.pendingStack(w, rest, stack, tasks, visited, released, scheduled)


def Laws.async_settlement_step_preserves_caller_stack(w, rest, stack, id):
  PendingContinuation.afterTrimStepStack(w, rest, stack, id)


def Laws.async_schedule_step_preserves_caller_stack(w, rest, stack):
  PendingContinuation.scheduleStepStack(w, rest, stack)


def Laws.async_after_trim_uses_exact_self_settlement(w, rest, stack, id):
  PendingContinuation.afterTrimExact(w, rest, stack, id)


def Laws.empty_pending_queue_returns_exact_caller(w, rest, stack, visited, released, scheduled):
  PendingContinuation.emptyExact(w, rest, stack, visited, released, scheduled)


def Laws.pending_release_keeps_its_captured_continuation(w, rest, stack, index, tail, visited, released, scheduled):
  PendingContinuation.releaseExact(w, rest, stack, index, tail, visited, released, scheduled)


def Laws.settlement_prefix_is_actual_core_iteration(scope, programme, actual):
  PendingHistory.actualSteps(scope, programme, actual)


def Laws.settlement_prefix_preserves_caller_stack_by_induction(scope, programme):
  PendingHistory.iterationStack(scope, programme)


def Laws.nonempty_settlement_schedule_prefix_is_constructed(w, rest, stack, visited, released, scheduled):
  PendingHistory.emptyThenSchedule(w, rest, stack, visited, released, scheduled)


def Laws.constructed_settlement_schedule_prefix_has_two_actual_steps(w, rest, stack, visited, released, scheduled):
  PendingHistory.emptyThenScheduleHeight(w, rest, stack, visited, released, scheduled)


def Laws.owner_bookkeeping_step_preserves_caller_stack(w, rest, stack, tasks, allowed):
  OwnerContinuation.stepStack(w, rest, stack, tasks, allowed)


def Laws.no_stale_owner_trim_completes_in_two_core_steps(w, rest, stack, id, edge, healthy):
  OwnerContinuation.trimComplete(w, rest, stack, id, edge, healthy)


def Laws.no_stale_owner_trim_prefix_is_constructed(w, rest, stack, id, edge, healthy):
  PendingHistory.ownerTrimPrefix(w, rest, stack, id, edge, healthy)


def Laws.constructed_owner_trim_prefix_has_two_actual_steps(w, rest, stack, id, edge, healthy):
  PendingHistory.ownerTrimHeight(w, rest, stack, id, edge, healthy)


def Laws.selected_text_update_exposes_the_actual_payload(renderers, w, id, value):
  RenderedView.textPresent(renderers, w, id, value)


def Laws.selected_application_event_is_retained(targets, w, id, value, previous):
  RenderedView.eventPresent(targets, w, id, value, previous)


def Laws.foreign_text_target_retains_selected_observation(renderers, targets, w, id, value, absent):
  RenderedView.textOther(renderers, targets, w, id, value, absent)


def Laws.foreign_application_retains_selected_observation(renderers, targets, w, id, value, previous, absent):
  RenderedView.eventOther(renderers, targets, w, id, value, previous, absent)


def Laws.node_storage_alone_does_not_publish_selected_text(renderers, targets, w, id, node):
  RenderedView.storeNode(renderers, targets, w, id, node)


def Laws.committed_storage_frame_implies_selected_frame(renderers, targets, w, next, same):
  RenderedView.fromCommitted(renderers, targets, w, next, same)


def Laws.independent_actual_apply_step_retains_selected_observation(renderers, targets, w, rest, stack, id, absentRenderer, absentTarget):
  IndependentApply.stepFrame(renderers, targets, w, rest, stack, id, absentRenderer, absentTarget)


def Laws.ordinary_async_arrival_retains_selected_observation(renderers, targets, w, rest, stack, id, result, value, then, custom, override):
  RenderedArrival.preserves(renderers, targets, w, rest, stack, id, result, value, then, custom, override)


def Laws.actual_core_run_splits_at_step_prefix(length, remaining, machine):
  CoreRunPrefix.split(length, remaining, machine)


def Laws.actual_core_zero_fuel_exhaustion_is_explicit(w, head, tail, stack):
  CoreRunPrefix.exhausts(w, head, tail, stack)


def Laws.pending_source_removal_retains_nodes_links_fault(w, id, source):
  RemovalFootprint.removed(w, id, source)


def Laws.empty_subscriber_settlement_returns_caller_in_six_steps(w, id, rest, stack, noSubscribers, healthy):
  EmptySettlement.exact(w, id, rest, stack, noSubscribers, healthy)


def Laws.empty_subscriber_settlement_composes_with_actual_run(w, id, rest, stack, remaining, noSubscribers, healthy):
  EmptySettlement.runBoundary(w, id, rest, stack, remaining, noSubscribers, healthy)


def Laws.empty_subscriber_settlement_preserves_committed_observation(w, id, rest, stack, noSubscribers, healthy):
  EmptySettlement.committed(w, id, rest, stack, noSubscribers, healthy)


def Laws.empty_subscriber_settlement_remains_healthy(w, id, rest, stack, noSubscribers, healthy):
  EmptySettlement.healthyResult(w, id, rest, stack, noSubscribers, healthy)


def Laws.empty_subscriber_settlement_prefix_is_constructed(w, id, rest, stack, noSubscribers, healthy):
  EmptySettlement.programme(w, id, rest, stack, noSubscribers, healthy)


def Laws.constructed_empty_subscriber_prefix_has_six_steps(w, id, rest, stack, noSubscribers, healthy):
  EmptySettlement.programmeHeight(w, id, rest, stack, noSubscribers, healthy)


def Laws.actual_settled_node_retains_committed_observation(w, tasks, visited, released, scheduled, id, root, source):
  SettlementFrame.settled(w, tasks, visited, released, scheduled, id, root, source)


def Laws.actual_pending_traversal_retains_committed_observation(w, tasks, visited, released, scheduled):
  SettlementFrame.advance(w, tasks, visited, released, scheduled)


def Laws.actual_core_pending_step_retains_committed_observation(w, rest, stack, tasks, visited, released, scheduled):
  CoreSettlementFrame.step(w, rest, stack, tasks, visited, released, scheduled)


def Laws.callback_free_settlement_history_retains_committed_observation(scope, programme, allowed):
  SettlementHistory.iterationFrame(scope, programme, allowed)


def Laws.callback_free_settlement_history_retains_selected_observation(scope, programme, allowed, renderers, targets):
  SettlementHistory.rendered(scope, programme, allowed, renderers, targets)


def Laws.constructed_empty_subscriber_prefix_is_content_safe(w, id, rest, stack, noSubscribers, healthy):
  SettlementHistory.constructedBody(w, id, rest, stack, noSubscribers, healthy)


def Laws.actual_pending_traversal_retains_subscriber_topology(w, tasks, visited, released, scheduled):
  PendingTopology.advance(w, tasks, visited, released, scheduled)


def Laws.actual_core_pending_step_retains_subscriber_topology(w, rest, stack, tasks, visited, released, scheduled):
  CoreTopology.step(w, rest, stack, tasks, visited, released, scheduled)


def Laws.callback_free_settlement_history_retains_subscriber_topology(scope, programme, allowed):
  TopologyHistory.iterationFrame(scope, programme, allowed)


def Laws.callback_free_settlement_history_retains_selected_subscriber_shape(scope, programme, allowed, id):
  TopologyHistory.selectedNode(scope, programme, allowed, id)


def Laws.callback_free_settlement_history_retains_selected_link(scope, programme, allowed, edge):
  TopologyHistory.selectedLink(scope, programme, allowed, edge)


def Laws.settled_non_autodisposed_node_retains_prior_release_list(w, tasks, visited, released, scheduled, id, root, source, noAuto):
  PendingMachine.settledNoReleases(w, tasks, visited, released, scheduled, id, root, source, noAuto)


def Laws.settled_leaf_derives_its_actual_pending_machine_shape(w, tasks, visited, released, scheduled, id, root, source, noSubscribers, noAuto):
  PendingMachine.settledLeaf(w, tasks, visited, released, scheduled, id, root, source, noSubscribers, noAuto)


def Laws.actual_leaf_visit_next_control_is_constructed(w, tasks, visited, released, scheduled, id, root, source, noSubscribers, noAuto):
  VisitControl.visit(w, tasks, visited, released, scheduled, id, root, source, noSubscribers, noAuto)


def Laws.one_edge_settlement_bounded_return_is_constructed(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto):
  OneEdgeReturn.complete(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)


def Laws.one_edge_settlement_retains_committed_observation(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto):
  OneEdgeReturn.frame(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)


def Laws.one_edge_settlement_uses_remaining_actual_driver_fuel(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto, remaining):
  OneEdgeDriver.driver(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto, remaining)


def Laws.no_stale_trimmed_one_edge_return_is_constructed(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto, noStale):
  OneEdgeReturn.completeTrimmed(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto, noStale)


def Laws.one_edge_leaf_suffix_completes_in_seven_healthy_steps(w, edge, root, visited, scheduled, rest, stack, ready, end):
  LeafReturn.healthy(w, edge, root, visited, scheduled, rest, stack, ready, end)


def Laws.one_edge_leaf_suffix_fault_unwinds_in_two_steps(w, edge, root, visited, scheduled, rest, stack, broken):
  LeafReturn.fault(w, edge, root, visited, scheduled, rest, stack, broken)


def Laws.one_edge_return_room_is_derived(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto):
  OneEdgeDriver.room(w, edge, root, id, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)


def Laws.existing_slot_node_update_reads_written_record(w, id, value, room):
  NodeStore.nodeSame(w, id, value, room)


def Laws.different_node_update_retains_other_record(w, write, read, value, different):
  NodeStore.nodeOther(w, write, read, value, different)


def Laws.fresh_graph_link_uses_actual_empty_tail_allocation(w, root, leaf, previous, deps, empty):
  FreshGraph.freshEmptyDependencies(w, root, leaf, previous, deps, empty)


def Laws.fresh_graph_allocation_constructs_one_edge_shape(w, root, leaf, edge, healthy, validRoot, validLeaf, different, positive, noSubscribers, noAuto):
  GraphAllocated.build(w, root, leaf, edge, healthy, validRoot, validLeaf, different, positive, noSubscribers, noAuto)


def Laws.fresh_graph_link_constructs_one_edge_shape(w, root, leaf, first, links, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena):
  GraphLinked.build(w, root, leaf, first, links, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena)


def Laws.constructed_graph_starts_bounded_settlement_return(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena):
  GraphLinked.startReturn(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena)


def Laws.graph_construction_and_settlement_retain_committed_observation(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena):
  GraphLinked.frame(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena)


def Laws.fresh_graph_allocation_keeps_allocated_node_ids_valid(w, root, leaf, read, known):
  GraphAllocated.valid(w, root, leaf, read, known)


def Laws.default_signal_allocation_is_actual_literal_append(w, value):
  DefaultLiterals.signal(w, value)


def Laws.parentless_computed_setup_installs_fresh_heap_slot(w, node, parentZero, room, nullComputed):
  FreshNodeSetup.exact(w, node, parentZero, room, nullComputed)


def Laws.default_computed_allocation_derives_its_node_record(w, expr, which, room, nullComputed):
  DefaultNode.node(w, expr, which, room, nullComputed)


def Laws.default_computed_allocation_derives_valid_identity(w, expr, which, room, nullComputed, first, tail, known):
  DefaultNode.fresh(w, expr, which, room, nullComputed, first, tail, known)


def Laws.default_computed_allocation_retains_existing_node(w, expr, which, room, nullComputed, read, fits):
  DefaultNode.oldNode(w, expr, which, room, nullComputed, read, fits)


def Laws.actual_memo_render_graph_is_constructed(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena):
  MemoRender.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)


def Laws.actual_memo_render_graph_starts_bounded_settlement_return(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena):
  MemoRender.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena)


def Laws.actual_memo_render_graph_settlement_retains_committed_observation(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena):
  MemoRender.frame(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena)


def Laws.reserved_arena_memo_render_return_requires_no_final_state_premises(values, sourceExpr, effectExpr, target, program, cleanup, rest, stack):
  ConstructedFixture.complete(values, sourceExpr, effectExpr, target, program, cleanup, rest, stack)


def Laws.actual_source_registration_retains_committed_observation(w, id, source):
  PendingAddPreserved.content(w, id, source)


def Laws.actual_source_registration_retains_subscriber_topology(w, id, source):
  PendingAddPreserved.topology(w, id, source)


def Laws.actual_source_registration_retains_graph_storage_and_fault(w, id, source):
  PendingAddPreserved.storage(w, id, source)


def Laws.actual_source_registration_retains_constructed_one_edge_certificate(w, id, source, root, leaf, edge, shape):
  PendingRegistration.build(w, id, source, root, leaf, edge, shape)


def Laws.registered_one_edge_graph_constructs_bounded_settlement_return(w, id, source, root, leaf, edge, rest, stack, shape):
  PendingRegistration.startReturn(w, id, source, root, leaf, edge, rest, stack, shape)


def Laws.registration_and_settlement_retain_committed_observation(w, id, source, root, leaf, edge, rest, stack, shape):
  PendingRegistration.frame(w, id, source, root, leaf, edge, rest, stack, shape)


def Laws.allocated_empty_source_set_add_constructs_membership(w, id, source, extension, set, allocated, known, slots, room):
  CarrierExisting.addedContains(w, id, source, extension, set, allocated, known, slots, room)


def Laws.fresh_source_set_add_constructs_membership(w, id, source, extension, sets, allocated, empty, fits, arena):
  FreshCarrierSet.contains(w, id, source, extension, sets, allocated, empty, fits, arena)


def Laws.fresh_node_add_constructs_extension_set_and_membership(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena):
  FreshCarrier.contains(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)


def Laws.fresh_node_add_then_remove_retires_its_source(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena):
  FreshCarrier.retired(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)


def Laws.fresh_node_duplicate_source_add_retains_entire_world(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena):
  FreshCarrier.duplicateAdd(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)


def Laws.fresh_node_duplicate_source_removal_retains_entire_world(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena):
  FreshCarrier.duplicateRemove(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)


def Laws.fresh_node_source_retirement_clears_pending_pointer(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena):
  FreshCarrier.retiredPointer(w, id, source, extensions, sets, valid, empty, extensionArena, setsArena)


def Laws.permitted_source_histories_retain_committed_observation(w, history):
  SourceHistory.content(w, history)


def Laws.permitted_source_histories_retain_subscriber_topology(w, history):
  SourceHistory.topology(w, history)


def Laws.permitted_source_histories_retain_graph_storage_and_fault(w, history):
  SourceHistory.storage(w, history)


def Laws.permitted_source_histories_retain_constructed_one_edge_certificate(w, root, leaf, edge, history, shape):
  SourceHistory.graph(w, root, leaf, edge, history, shape)


def Laws.permitted_source_histories_construct_bounded_settlement_return(w, root, leaf, edge, history, rest, stack, shape):
  SourceHistory.startReturn(w, root, leaf, edge, history, rest, stack, shape)


def Laws.permitted_source_histories_and_settlement_retain_committed_observation(w, root, leaf, edge, history, rest, stack, shape):
  SourceHistory.returnedFrame(w, root, leaf, edge, history, rest, stack, shape)


def Laws.selected_source_command_history_validity_is_constructed(w, commands, root, leaf, edge, shape):
  SourceCommands.build(w, commands, root, leaf, edge, shape)


def Laws.actual_memo_render_source_commands_construct_bounded_settlement_return(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack):
  ConstructedSources.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack)


def Laws.actual_memo_render_source_commands_retain_committed_observation(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack):
  ConstructedSources.frame(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack)


def Laws.fresh_graph_allocation_retains_extension_pointers(w, root, leaf):
  GraphExtensionPointers.allocated(w, root, leaf)


def Laws.actual_memo_render_construction_supplies_pending_registration_context(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena):
  RegistrationContext.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)


def Laws.actual_memo_render_source_registration_is_constructed(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena):
  ConstructedRegistration.prepare(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena)


def Laws.actual_memo_render_registration_constructs_bounded_settlement_return(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack):
  ConstructedRegistration.startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack)


def Laws.actual_memo_render_registration_retains_committed_observation(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack):
  ConstructedRegistration.frame(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack)


def Laws.actual_memo_render_registration_then_removal_retires_source(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena):
  ConstructedRegistration.retired(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena)


def Laws.carrier_snapshot_represents_actual_source_membership(w, node, source, snapshot):
  CarrierState.sound(w, node, source, snapshot)


def Laws.carrier_snapshot_survives_actual_next_source_command(w, node, source, snapshot, command):
  CarrierState.step(w, node, source, snapshot, command)


def Laws.carrier_snapshot_after_command_matches_add_remove_choice(w, node, source, snapshot, command):
  CarrierState.stepPresent(w, node, source, snapshot, command)


def Laws.carrier_cycle_proof_state_executes_actual_helper_worlds(node, source, commands, w, initial):
  CarrierCycles.worldAgreement(node, source, commands, w, initial)


def Laws.single_source_cycles_membership_matches_last_command(node, source, commands, w, initial):
  CarrierCycles.worldMembership(node, source, commands, w, initial)


def Laws.fresh_source_cycles_membership_matches_last_command(node, source, commands, w, extensions, sets, valid, empty, extensionArena, setArena):
  CarrierCycles.freshMembership(node, source, commands, w, extensions, sets, valid, empty, extensionArena, setArena)


def Laws.actual_memo_render_carrier_cycle_invariant_is_constructed(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena):
  ConstructedCarrierCycles.seed(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena)


def Laws.actual_memo_render_carrier_cycles_membership_matches_last_command(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, commands):
  ConstructedCarrierCycles.membership(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, commands)


def Laws.constructed_carrier_cycle_source_is_the_allocated_memo(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena):
  ConstructedCarrierCycles.sourceIdentity(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena)


def Laws.queued_computed_disposal_requests_future_flush(value, head, tail):
  IdleDisposal.queued(value, head, tail)


def Laws.empty_unheld_computed_disposal_does_not_request_flush(value):
  IdleDisposal.empty(value)


def Laws.actual_pending_notification_constructs_single_carrier(w, node, source, serial, snapshot, noError):
  PendingNotification.single(w, node, source, serial, snapshot, noError)


def Laws.actual_pending_notification_records_source_membership(w, node, source, serial, snapshot, noError):
  PendingNotification.member(w, node, source, serial, snapshot, noError)


def Laws.actual_pending_notification_retains_incoming_error_identity(w, node, source, serial, snapshot, noError):
  PendingNotification.errorResult(w, node, source, serial, snapshot, noError)


def Laws.actual_pending_notification_selects_source_status_bits(w, node, source, serial, snapshot, noError, valid):
  PendingNotification.statusResult(w, node, source, serial, snapshot, noError, valid)


def Laws.actual_pending_notification_preserves_committed_content(w, node, source, serial, noError):
  PendingNotification.content(w, node, source, serial, noError)


def Laws.constructed_notification_control_supplies_all_carrier_premises(values, value, extensions, sets, incoming, serial):
  NotificationFixture.ready(values, value, extensions, sets, incoming, serial)


def Laws.source_registration_preserves_all_node_status_words(w, node, source):
  SourceStatusFrame.added(w, node, 1n+source)


def Laws.pending_notification_selects_actual_incoming_status(w, node, source, serial, snapshot, noError, valid):
  NotificationInput.inputStatus(w, node, source, serial, snapshot, noError, valid)


def Laws.actual_action_wait_returns_observer_allocation_identity(w, action, result, kind):
  WaitAllocation.identity(w, action, result, kind)


def Laws.actual_action_wait_constructs_observer_capture(w, action, result, kind):
  WaitAllocation.observerRecord(w, action, result, kind)


def Laws.actual_action_wait_subscribes_existing_result(w, action, result, kind, validResult):
  WaitAllocation.subscribedObject(w, action, result, kind, validResult)


def Laws.actual_action_wait_constructs_fresh_unsettled_lookup(w, action, result, kind, valid):
  WaitConstruction.found(w, action, result, kind, valid)


def Laws.actual_action_wait_preserves_observer_range(w, action, result, kind, valid):
  WaitConstruction.bounded(w, action, result, kind, valid)


def Laws.actual_wait_allocation_mark_histories_preserve_range(events, w, valid):
  WaitHistory.historyRange(events, w, valid)


def Laws.constructed_wait_remains_duplicate_guarded_after_actual_histories(w, action, result, events, rest, stack, rejected, value, valid):
  WaitHistory.constructedDuplicate(w, action, result, events, rest, stack, rejected, value, valid)


def Laws.actual_wait_allocation_mark_histories_retain_committed_content(events, w):
  WaitHistory.historyContent(events, w)


def Laws.legacy_unallocated_alias_created_action_supplies_wait_range_after_actual_prefix(values, prefix):
  WaitFixture.beforeRange(values, prefix)


def Laws.legacy_unallocated_alias_created_action_wait_has_nonzero_fresh_observer(values, prefix):
  WaitFixture.freshPositive(values, prefix)


def Laws.legacy_unallocated_alias_created_action_wait_retains_settled_lookup_after_actual_suffix(values, prefix, suffix):
  WaitFixture.settled(values, prefix, suffix)


def Laws.legacy_unallocated_alias_created_action_wait_duplicate_retains_actual_current_machine(values, prefix, suffix, rest, stack, rejected, value):
  WaitFixture.duplicate(values, prefix, suffix, rest, stack, rejected, value)


def Laws.constructed_wait_ignores_then_throw_after_settlement(w, action, result, events, rest, stack, error, valid):
  WaitHistory.constructedThrow(w, action, result, events, rest, stack, error, valid)

def Laws.valid_pending_notification_selects_every_incoming_status_word(w,node,source,serial,valid):
  GeneralStatus.selected(w,node,source,serial,valid)

def Laws.valid_pending_notification_sets_pending_bit(w,node,source,serial,valid):
  GeneralStatus.pending(w,node,source,serial,valid)

def Laws.valid_pending_notification_clears_error_bit(w,node,source,serial,valid):
  GeneralStatus.errorCleared(w,node,source,serial,valid)

def Laws.pending_error_bookkeeping_preserves_all_status_words(w,node,source,error):
  ErrorStatusFrame.setError(w,node,source,error)

def Laws.pending_selected_status_always_pending(flags):
  GeneralStatus.selectedPending(flags)

def Laws.pending_selected_status_never_error(flags):
  GeneralStatus.selectedError(flags)

def Laws.no_error_pending_store_preserves_subscriber_topology(w,node,source,serial,noError):
  NotificationFootprint.topology(w,node,source,serial,noError)

def Laws.no_error_pending_store_preserves_graph_size_links_fault(w,node,source,serial,noError):
  NotificationStorage.stored(w,node,source,serial,noError)

def Laws.no_error_pending_store_retains_initial_health(w,node,source,serial,noError,healthy):
  NotificationStorage.healthy(w,node,source,serial,noError,healthy)

def Laws.valid_node_supplies_two_steps_in_actual_notifier_budget(w,node,valid):
  NotificationRoom.room(w,node,valid)

def Laws.observer_record_writes_retain_wait_entries(w,observer,record):
  ObserverWrites.storeWaits(w,observer,record)

def Laws.observer_record_writes_retain_arena_size(w,observer,record):
  ObserverWrites.storeSize(w,observer,record)

def Laws.actual_observer_capture_has_source_counter_result(w,operation):
  ObserverCapture.size(w,operation)

def Laws.actual_observer_capture_retains_committed_content(w,operation):
  ObserverCapture.content(w,operation)

def Laws.actual_observer_capture_preserves_wait_range(w,operation,valid):
  ObserverCapture.range(w,operation,valid)

def Laws.stream_step_observer_returns_fresh_identity(w,stream):
  ObserverWrites.streamIdentity(w,stream)

def Laws.stream_step_observer_captures_current_stream_record(w,stream):
  ObserverWrites.streamRecord(w,stream)

def Laws.created_action_identity_is_actually_allocated(values):
  AllocatedWaitFixture.allocated(values)

def Laws.registered_wait_captures_allocated_action_identity(values,prefix):
  AllocatedWaitFixture.lookup(values,prefix)

def Laws.allocated_action_supplies_wait_range_after_helper_prefix(values,prefix):
  AllocatedWaitFixture.beforeRange(values,prefix)

def Laws.allocated_action_wait_has_nonzero_observer(values,prefix):
  AllocatedWaitFixture.freshPositive(values,prefix)

def Laws.allocated_action_wait_retains_settled_lookup(values,prefix,suffix):
  AllocatedWaitFixture.settled(values,prefix,suffix)

def Laws.allocated_action_wait_retains_current_machine(values,prefix,suffix,rest,stack,rejected,value):
  AllocatedWaitFixture.duplicate(values,prefix,suffix,rest,stack,rejected,value)

def Laws.actual_action_join_retains_pre_entry_captures(w,transaction):
  ResumeTransaction.joinFuture(w,transaction)

def Laws.admitted_action_method_staging_retains_observer_context(w,rest,stack,action,value,rejected,state,method):
  FirstFrame.methods(w,rest,stack,action,value,rejected,state,method)

def Laws.actual_action_resume_retains_observer_context(w,rest,stack,action,value,rejected,method,known):
  FirstFrame.resume(w,rest,stack,action,value,rejected,method,known)

def Laws.constructed_first_delivery_sets_its_settled_wait(values,rest,stack,rejected,value):
  FirstDelivery.lookup(values,rest,stack,rejected,value)

def Laws.constructed_first_delivery_retains_wait_range(values,rest,stack,rejected,value):
  FirstDelivery.range(values,rest,stack,rejected,value)

def Laws.constructed_first_delivery_retains_committed_content(values,rest,stack,rejected,value):
  FirstDelivery.content(values,rest,stack,rejected,value)

def Laws.constructed_first_delivery_guards_its_actual_machine(values,rest,stack,rejected,value,events,lateRejected,lateValue):
  FirstDelivery.duplicate(values,rest,stack,rejected,value,events,lateRejected,lateValue)

def Laws.action_rejection_reason_is_not_adopted(w,rest,stack,action,result,value):
  ActionOutputRejection.raw(w,rest,stack,action,result,value)

def Laws.constructed_terminal_delivery_retires_single_obligation_and_output(values,rest,stack,rejected,value):
  FirstRetirement.completed(values,rest,stack,rejected,value)

def Laws.retired_delivery_retains_exact_machine_on_later_duplicates(values,rest,stack,rejected,value,events,lateRejected,lateValue):
  FirstRetirement.duplicate(values,rest,stack,rejected,value,events,lateRejected,lateValue)

def Laws.callback_table_helper_histories_retain_outer_world(events,w):
  HelperContext.history(events,w)

def Laws.allocated_actor_stays_valid_through_helper_prefix(values,prefix):
  HelperContext.beforeAllocated(values,prefix)

def Laws.allocated_actor_full_cell_survives_helper_prefix(values,prefix):
  HelperContext.beforeCell(values,prefix)

def Laws.retired_action_stays_zero_through_helper_suffix(values,rest,stack,rejected,value,events):
  ActionRetirementContext.afterRetirementZero(values,rest,stack,rejected,value,events)

def Laws.admitted_yielded_callback_enters_with_observer_frame(w,rest,stack,observer,action,rejected,value,method,known):
  FirstFrame.delivered(w,rest,stack,observer,action,rejected,value,method,known)


def Laws.method_action_actor_allocated_after_helper_prefix(values,method,prefix):
  MethodFirstHistory.allocated(values,method,prefix)


def Laws.method_action_capture_survives_real_wait_registration(values,method,prefix):
  MethodFirstHistory.methods(values,method,prefix)


def Laws.first_method_callback_after_helpers_retains_observer_context(values,method,prefix,rest,stack,rejected,value):
  MethodFirstHistory.frame(values,method,prefix,rest,stack,rejected,value)


def Laws.first_method_callback_after_helpers_establishes_settled_lookup(values,method,prefix,rest,stack,rejected,value):
  MethodFirstHistory.firstFound(values,method,prefix,rest,stack,rejected,value)


def Laws.first_method_callback_after_helpers_retains_wait_range(values,method,prefix,rest,stack,rejected,value):
  MethodFirstHistory.firstRange(values,method,prefix,rest,stack,rejected,value)


def Laws.first_method_callback_after_helpers_retains_committed_content(values,method,prefix,rest,stack,rejected,value):
  MethodFirstHistory.firstContent(values,method,prefix,rest,stack,rejected,value)


def Laws.first_method_callback_and_helper_suffix_guard_current_machine(values,method,prefix,rest,stack,rejected,value,events,lateRejected,lateValue):
  MethodFirstHistory.duplicate(values,method,prefix,rest,stack,rejected,value,events,lateRejected,lateValue)


def Laws.pending_notification_retains_topology_for_any_input_status(w,node,source,serial):
  NotificationFootprint.allTopology(w,node,source,serial)


def Laws.pending_notification_retains_storage_for_any_input_status(w,node,source,serial):
  NotificationStorage.allStored(w,node,source,serial)


def Laws.pending_leaf_notification_preserves_machine_continuation(w,node,source,serial,rest,visited,scheduled,config,shape,noGuess):
  LeafNotify.leaf(w,node,source,serial,rest,visited,scheduled,config,shape,noGuess)


def Laws.pending_leaf_notification_completes_with_existing_public_budget(w,node,source,serial,config,shape,noGuess,healthy,valid):
  LeafNotify.public(w,node,source,serial,config,shape,noGuess,healthy,valid)


def Laws.settled_status_has_exact_all_node_status_projection(w,node,remaining,errored):
  StatusPhase.observed(w,node,remaining,errored)


def Laws.sole_pending_source_removal_constructs_empty_carrier(w,node,source,single):
  LastSource.retired(w,node,source,single)


def Laws.sole_pending_source_removal_reports_success(w,node,source,single):
  LastStatus.removalReported(w,node,source,single)


def Laws.sole_pending_source_removal_and_status_clear_pending(w,node,source,single,valid):
  LastStatus.retiredCleared(w,node,source,single,valid)


def Laws.unheld_empty_carrier_has_exact_settled_status_world(w,node,empty,valid,noHeld):
  LastSource.exact(w,node,empty,valid,noHeld)


def Laws.heap_enqueue_preserves_all_node_status_words(w,node):
  HeapStatus.enqueue(w,node)


def Laws.settlement_tail_preserves_all_node_status_words(w,tasks,visited,released,scheduled,node,root,source,last):
  TailStatus.tail(w,tasks,visited,released,scheduled,node,root,source,last)


def Laws.actual_empty_carrier_settled_controller_clears_pending(w,tasks,visited,released,scheduled,node,root,source,empty,valid):
  RetirementController.settledCleared(w,tasks,visited,released,scheduled,node,root,source,empty,valid)


def Laws.actual_single_source_removed_controller_clears_pending(w,tasks,visited,released,scheduled,node,root,source,single,valid):
  RetirementController.removedCleared(w,tasks,visited,released,scheduled,node,root,source,single,valid)


def Laws.local_notification_constructs_actual_controller_pending_clear(w,node,source,serial,tasks,visited,released,scheduled,root,snapshot,noError,valid):
  NotificationRetirement.cleared(w,node,source,serial,tasks,visited,released,scheduled,root,snapshot,noError,valid)


def Laws.constructed_memo_render_notification_and_controller_clear_pending(values,value,extensions,sets,incoming,serial,tasks,visited,released,scheduled):
  ConstructedRetirement.constructedCleared(values,value,extensions,sets,incoming,serial,tasks,visited,released,scheduled)


def Laws.never_valued_render_read_routes_from_cleared_verdict_seat(w,rest,stack,reader,node,lane,empty,present,same):
  NeverPending.exits(w,rest,stack,reader,node,lane,empty,present,same)


def Laws.finite_onflush_registrations_retain_every_non_scheduling_field(bodies,w):
  FlushRegistration.outerHistory(bodies,w)

def Laws.nonempty_idle_onflush_registrations_have_exact_ordered_outbox(w,body,rest):
  FlushRegistration.nonempty(w,body,rest)

def Laws.actual_onflush_expression_queues_without_running_body(w,rest,stack,body,previous):
  FlushControl.source(w,rest,stack,body,previous)


def Laws.action_output_retains_every_field_except_promise_storage_and_host_requests(w,rest,stack,id,rejected,answer):
  BodyOutput.output(w,rest,stack,id,rejected,answer)


def Laws.certified_group_routes_survive_transaction_arena_frames(w,next,path,extra,same,room):
  RouteTransport.public(w,next,path,extra,same,room)


def Laws.literal_action_result_executes_two_real_steps_to_completion(w,rest,stack,id,value,healthy):
  BodyReturn.complete(w,rest,stack,id,value,healthy)


def Laws.actual_action_resume_enters_terminating_literal_method(w,rest,stack,id,incoming,rejected,value,tail,known):
  BodyEntry.resume(w,rest,stack,id,incoming,rejected,value,tail,known)


def Laws.actual_terminating_body_retires_captured_live_group_obligation(w,rest,stack,id,value,path,extra,remaining,healthy,captured,room,open):
  BodyRetire.complete(w,rest,stack,id,value,path,extra,remaining,healthy,captured,room,open)


def Laws.constructed_body_return_retires_debt_after_arbitrary_helper_prefix(values,value,tail,prefix,rest,stack,incoming,rejected):
  BodyConstruct.completedOuter(values,value,tail,prefix,rest,stack,incoming,rejected)


def Laws.stale_yield_after_body_return_preserves_current_machine(values,value,tail,prefix,rest,stack,incoming,rejected,events,lateRejected,lateValue):
  BodyGuard.duplicate(values,value,tail,prefix,rest,stack,incoming,rejected,events,lateRejected,lateValue)


def Laws.constructed_body_retirement_zero_debt_survives_helper_suffix(values,value,tail,prefix,rest,stack,incoming,rejected,events):
  BodyDebt.suffixZero(values,value,tail,prefix,rest,stack,incoming,rejected,events)


def Laws.action_output_preserves_arbitrary_caller_stack(w,rest,stack,id,rejected,value):
  BodyOutput.outputStack(w,rest,stack,id,rejected,value)


def Laws.certified_subscriber_walk_retains_full_outer_world_and_fault(w,path,current,extra,same,known):
  WriteBody0.walk(w,path,current,extra,same,known)


def Laws.actual_subscriber_notification_uses_certified_arena_budget(base,path,w,id,extra,same,unmarked,valid,matches,room):
  WriteBody3.publicFrom(base,path,w,id,extra,same,unmarked,valid,matches,room)


def Laws.actual_ordinary_setter_preserves_constructed_source_profile(w,id,value,profile):
  WriteBody4.next(w,id,value,profile)


def Laws.finite_actual_setter_body_evaluates_with_structural_bound(values,w,id,answer,rest,stack,profile):
  WriteBody9.complete(values,w,id,answer,rest,stack,profile)


def Laws.raw_signal_render_constructor_supplies_finite_write_history_profile(values,initial):
  WriteBody11.constructedHistory(values,initial)


def Laws.finite_ordinary_body_retires_original_captured_live_obligation(values,w,id,answer,actor,rest,stack,profile,route,extra,remaining,captured,room,open):
  WriteBody15.complete(values,w,id,answer,actor,rest,stack,profile,route,extra,remaining,captured,room,open)


def Laws.finite_ordinary_body_return_retains_arbitrary_caller_stack(values,w,id,answer,actor,rest,stack,profile):
  WriteBody16.savedStack(values,w,id,answer,actor,rest,stack,profile)


def Laws.constructed_actual_method_body_and_group_retirement(initial,values,answer,rest,stack,incoming,rejected):
  WriteBody17.complete(initial,values,answer,rest,stack,incoming,rejected)


def Laws.constructed_finite_setter_body_has_zero_live_action_debt(initial,values,answer,rest,stack,incoming,rejected):
  WriteBody21.zero(initial,values,answer,rest,stack,incoming,rejected)


def Laws.actual_constant_updater_expression_keeps_committed_storage(w,rest,stack,id,value,previous,healthy,ordinary,override,custom):
  WriteBody12.committed(w,rest,stack,id,value,previous,healthy,ordinary,override,custom)


def Laws.canonical_held_source_join_preserves_group_and_only_schedules(w,id,offset,canonical,current,stopped):
  HeldStage0.actual(w,id,offset,canonical,current,stopped)


def Laws.held_snapshot_stash_retains_error_flight_and_control_fields(w,id,existing):
  HeldStage2.actual(w,id,existing)


def Laws.allocated_held_extension_records_the_actual_flushed_snapshot(w,id,room):
  HeldStage3.tailWritten(w,id,room)


def Laws.held_staging_with_certified_subscribers_preserves_health(w,path,id,value,extra,health,unmarked,valid,head,room,context,signal,existing):
  HeldStage5.healthy(w,path,id,value,extra,health,unmarked,valid,head,room,context,signal,existing)


def Laws.held_staging_retains_source_shape_and_link_storage(w,id,value,context,signal,existing):
  HeldStage9.shape(w,id,value,context,signal,existing)


def Laws.held_staging_retains_every_allocated_extension_identity(w,id,value,context,signal,existing):
  HeldStage9.pointers(w,id,value,context,signal,existing)


def Laws.actual_held_setter_constructs_next_group_extension_and_path_profile(w,id,value,offset,profile):
  HeldBody0.next(w,id,value,offset,profile)


def Laws.finite_held_setter_history_constructs_its_preserved_profile(values,w,id,offset,profile):
  HeldBody3.invariant(values,w,id,offset,profile)


def Laws.finite_held_setter_history_retains_precise_outer_and_graph_frames(values,w,id,offset,profile):
  HeldBody3.retained(values,w,id,offset,profile)


def Laws.finite_actual_held_setter_body_has_structurally_bounded_evaluation(values,w,id,answer,rest,stack,offset,profile):
  HeldBody4.complete(values,w,id,answer,rest,stack,offset,profile)


def Laws.finite_held_body_return_preserves_the_arbitrary_caller_stack(values,w,id,answer,actor,rest,stack,offset,profile):
  HeldBody6.savedStack(values,w,id,answer,actor,rest,stack,offset,profile)


def Laws.finite_held_body_retires_the_original_captured_live_obligation(values,w,id,answer,actor,rest,stack,offset,profile,route,extra,remaining,captured,room,open):
  HeldBody7.complete(values,w,id,answer,actor,rest,stack,offset,profile,route,extra,remaining,captured,room,open)


def Laws.actual_owned_source_constructor_supplies_the_held_body_profile(initial):
  HeldBody8.profile(initial)


def Laws.constructed_owned_source_body_reaches_zero_live_action_debt(initial,values,answer,rest,stack):
  HeldBody9.zero(initial,values,answer,rest,stack)


def Laws.captured_fresh_preparation_retains_the_held_source_observation(w,actor,offset,tail,captured,empty,stopped):
  HeldResume0.actual(w,actor,offset,tail,captured,empty,stopped)


def Laws.current_group_preparation_constructs_the_held_body_profile(w,id,actor,offset,tail,initial,captured):
  HeldResume3.current(w,id,actor,offset,tail,initial,captured)


def Laws.actual_action_preparation_preserves_the_original_positive_capture(w,actor,offset,tail,captured):
  HeldResume5.capture(w,actor,offset,tail,captured)


def Laws.current_group_actual_resume_runs_held_body_and_retires_one_obligation(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,initial,captured,open,known):
  HeldResume7.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,initial,captured,open,known)


def Laws.fresh_group_actual_resume_runs_held_body_and_retires_one_obligation(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,initial,captured,empty,open,known):
  HeldResume7.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,remaining,initial,captured,empty,open,known)


def Laws.certified_captured_alias_joins_its_already_current_canonical_group(w,rootOffset,captureOffset,alias,positive,future,stopped):
  HeldAlias0.current(w,rootOffset,captureOffset,alias,positive,future,stopped)


def Laws.certified_captured_alias_selects_its_canonical_group_in_a_fresh_flush_slot(w,rootOffset,captureOffset,alias,positive,empty):
  HeldAlias0.fresh(w,rootOffset,captureOffset,alias,positive,empty)


def Laws.never_valued_pending_read_returns_token_from_a_shown_lane(w,rest,stack,reader,id,lane,known):
  RebaseLane0.shown(w,rest,stack,reader,id,lane,known)


def Laws.never_valued_pending_read_retains_outside_display_when_lane_unshown(w,rest,stack,reader,id,lane,known):
  RebaseLane0.unshown(w,rest,stack,reader,id,lane,known)


def Laws.retained_redirect_vector_constructs_next_route_with_origin_terminal_and_depth(w,next,path,same):
  AliasResume0.move(w,next,path,same)


def Laws.retained_redirect_vector_constructs_next_alias_and_arena_room(w,next,root,alias,same):
  AliasResume0.moveAlias(w,next,root,alias,same)


def Laws.captured_alias_current_preparation_retains_source_profile_observation(w,actor,offset,captureOffset,tail,alias,captured,positive,future,stopped):
  AliasResume1.current(w,actor,offset,captureOffset,tail,alias,captured,positive,future,stopped)


def Laws.captured_alias_fresh_preparation_retains_selected_source_observation(w,actor,offset,captureOffset,tail,alias,captured,positive,empty):
  AliasResume1.fresh(w,actor,offset,captureOffset,tail,alias,captured,positive,empty)


def Laws.actual_preparation_retains_the_original_positive_captured_alias(w,actor,offset,captureOffset,tail,alias,captured,positive):
  AliasResume2.capture(w,actor,offset,captureOffset,tail,alias,captured,positive)


def Laws.captured_alias_current_resume_runs_finite_held_body_and_retires_one_obligation(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known):
  AliasResume3.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known)


def Laws.captured_alias_fresh_resume_runs_finite_held_body_and_retires_one_obligation(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known):
  AliasResume3.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known)


def Laws.captured_alias_current_resume_restores_arbitrary_caller_stack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,known):
  AliasResume3.currentStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,known)


def Laws.captured_alias_fresh_resume_restores_arbitrary_caller_stack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known):
  AliasResume3.freshStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known)


def Laws.ordinary_current_observer_delivery_runs_aliased_held_body_and_retires_once(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found):
  HeldDelivery0.current(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found)


def Laws.ordinary_current_observer_delivery_restores_caller_stack(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,known,found):
  HeldDelivery0.currentStack(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,known,found)


def Laws.ordinary_current_observer_delivery_cannot_repeat_after_body_and_wait_history(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found,events,lateRejected,lateValue):
  HeldDelivery2.currentDuplicate(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,open,known,found,events,lateRejected,lateValue)


def Laws.ordinary_fresh_observer_delivery_runs_aliased_held_body_and_retires_once(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found):
  HeldDelivery0.fresh(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found)


def Laws.ordinary_fresh_observer_delivery_restores_caller_stack(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found):
  HeldDelivery0.freshStack(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,initial,alias,captured,positive,empty,known,found)


def Laws.ordinary_fresh_observer_delivery_cannot_repeat_after_body_and_wait_history(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found,events,lateRejected,lateValue):
  HeldDelivery2.freshDuplicate(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found,events,lateRejected,lateValue)


def Laws.actual_hold_source_view_is_computed_from_its_initial_source_view(w,id,t):
  HeldConstruct0.holdObserved(w,id,t)


def Laws.holding_a_source_preserves_action_capture_and_all_group_open_counts(w,id,t):
  HeldConstruct1.hold(w,id,t)


def Laws.actual_create_open_hold_constructs_the_fresh_resume_source_profile(initial,methods):
  HeldConstruct2.profile(initial,methods)


def Laws.constructed_held_resume_body_retires_its_only_live_action_obligation(initial,values,answer,rest,stack,incoming,rejected):
  HeldConstruct8.zero(initial,values,answer,rest,stack,incoming,rejected)


def Laws.constructed_ordinary_observer_delivery_runs_a_finite_held_body_and_retires(value,values,answer,prefix,rest,stack,incoming,rejected):
  ConstructDelivery0.complete(value,values,answer,prefix,rest,stack,incoming,rejected)


def Laws.constructed_ordinary_observer_delivery_preserves_arbitrary_caller_stack(value,values,answer,prefix,rest,saved,incoming,rejected):
  ConstructDelivery0.stack(value,values,answer,prefix,rest,saved,incoming,rejected)


def Laws.constructed_ordinary_observer_delivery_is_a_noop_after_its_first_body(value,values,answer,prefix,rest,stack,incoming,rejected,suffix,lateRejected,lateValue):
  ConstructDelivery0.duplicate(value,values,answer,prefix,rest,stack,incoming,rejected,suffix,lateRejected,lateValue)


def Laws.actual_action_output_retains_an_exact_caller_task_suffix(w,rest,stack,id,rejected,answer):
  ActionOutput0.done(w,rest,stack,id,rejected,answer)


def Laws.classified_action_output_prefix_has_a_finite_exact_core_drain(machine,rest,stack,form,healthy):
  ActionOutput0.drain(machine,rest,stack,form,healthy)


def Laws.ordinary_fresh_callback_output_prefix_reaches_its_queued_slice_end(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found):
  ActionOutput2.drain(w,observer,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,alias,captured,positive,empty,open,known,found)


def Laws.nested_action_slice_restores_the_saved_caller_question(w,question,rest,stack,offset,healthy,depth):
  ActionOutput4.nested(w,question,rest,stack,offset,healthy,depth)


def Laws.scheduled_outer_action_slice_queues_round_before_question_restore(w,question,rest,stack,healthy,depth,running,halted,ready):
  ActionOutput4.scheduled(w,question,rest,stack,healthy,depth,running,halted,ready)


def Laws.certified_source_cache_redirect_is_resolved_and_stored_by_actual_txof(w,id,root,alias,cached):
  SourceCache0.txOf(w,id,root,alias,cached)


def Laws.first_real_setter_constructs_the_canonical_source_cache_successor(w,id,offset,value,alias,cached,profile):
  SourceCache0.successor(w,id,offset,value,alias,cached,profile)


def Laws.nonempty_source_cache_alias_body_has_a_structural_exact_core_bound(w,head,tail,id,answer,rest,stack,offset,alias,cached,profile):
  SourceCache1.complete(w,head,tail,id,answer,rest,stack,offset,alias,cached,profile)


def Laws.nonempty_source_cache_alias_body_constructs_its_final_held_profile(w,head,tail,id,offset,alias,cached,profile):
  SourceCache1.afterProfile(w,head,tail,id,offset,alias,cached,profile)


def Laws.constructed_held_delivery_preserves_initial_action_control_flags(value,methods,prefix):
  RoundConstruct20260.flags(value,methods,prefix)


def Laws.unhalted_action_retirement_schedules_work(w,root,remaining,known):
  RoundConstruct20263.target(w,root,remaining,known)


def Laws.constructed_ordinary_delivery_reaches_queued_round_after_finite_body(value,values,answer,prefix,rest,stack,incoming,rejected):
  RoundConstruct20264.complete(value,values,answer,prefix,rest,stack,incoming,rejected)


def Laws.constructed_ordinary_outer_interception_selects_action_delivery(initial,methods,prefix,rest,stack,rejected,value):
  RoundConstruct20267.constructed(initial,methods,prefix,rest,stack,rejected,value)


def Laws.constructed_fulfillment_or_rejection_task_reaches_queued_round(value,values,answer,prefix,rest,stack,incoming,rejected):
  RoundConstruct20268.complete(value,values,answer,prefix,rest,stack,incoming,rejected)


def Laws.virtual_source_cache_view_transports_across_equal_source_observations(w,next,id,root,equal):
  CacheResume20260.same(w,next,id,root,equal)


def Laws.redirected_source_cache_body_retires_original_captured_obligation(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile,route,extra,remaining,captured,room,open):
  CacheResume20261.retire(values,w,id,answer,actor,rest,stack,offset,alias,cached,profile,route,extra,remaining,captured,room,open)


def Laws.current_group_resume_handles_independent_source_and_capture_aliases(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known):
  CacheResume20262.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)


def Laws.fresh_group_resume_handles_independent_source_and_capture_aliases(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known):
  CacheResume20262.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)


def Laws.current_group_source_cache_alias_resume_restores_caller_stack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known):
  CacheResume20262.currentStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)


def Laws.fresh_group_source_cache_alias_resume_restores_caller_stack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known):
  CacheResume20262.freshStack(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)


def Laws.certified_transaction_merge_preserves_held_source_heap_facts(w,left,right,source,target):
  JoinedBody20260.merge(w,left,right,source,target)


def Laws.actual_distinct_root_merge_constructs_surviving_group_membership(w,prefix,left,gap,right,suffix,reverse):
  JoinedBody20263.allocated(w,prefix,left,gap,right,suffix,reverse)


def Laws.certified_first_controller_constructs_joined_body_retirement(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready):
  JoinedBody20265.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)


def Laws.raw_two_controller_join_runs_either_finite_body_and_retires_one_obligation(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedBody202610.complete(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_two_controller_join_body_restores_arbitrary_caller_stack(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedBody202610.savedStack(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.finite_cached_alias_body_constructs_a_virtual_final_source_profile(values,w,id,offset,alias,cached,profile):
  CountEvidence20260.after(values,w,id,offset,alias,cached,profile)


def Laws.current_cached_alias_resume_constructs_its_count_evidence(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known):
  CountEvidence20261.current(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)


def Laws.fresh_cached_alias_resume_constructs_its_count_evidence(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known):
  CountEvidence20261.fresh(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)


def Laws.constructed_body_evidence_proves_actual_remaining_count(before,steps,id,offset,remaining,outcome):
  CountEvidence20262.count(before,steps,id,offset,remaining,outcome)


def Laws.constructed_body_evidence_proves_actual_post_body_health(before,steps,id,offset,remaining,outcome):
  CountEvidence20262.healthy(before,steps,id,offset,remaining,outcome)


def Laws.one_remaining_body_obligation_is_an_actual_unchanged_blocker(before,steps,id,offset,outcome):
  CountEvidence20262.blocked(before,steps,id,offset,outcome)


def Laws.certified_first_controller_constructs_joined_body_count_evidence(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready):
  CountEvidence20264.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)


def Laws.raw_two_controller_join_constructs_finite_body_count_evidence(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  CountEvidence20265.complete(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_two_controller_join_first_body_leaves_exactly_one_obligation(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  CountEvidence20266.count(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_two_controller_join_first_body_keeps_the_live_group_blocked(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  CountEvidence20266.blocked(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.constructed_body_evidence_constructs_the_actual_successor_source_profile(before,steps,id,offset,remaining,proof):
  CountEvidence20267.outcome(before,steps,id,offset,remaining,proof)


def Laws.raw_two_controller_join_first_body_constructs_the_successor_source_profile(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  CountEvidence20269.profile(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.finite_cached_alias_setters_construct_the_actual_next_cache_route(values,w,id,offset,input):
  NextBody20260.written(values,w,id,offset,input)


def Laws.actual_retirement_preserves_the_constructed_source_cache_route(written,next,id,offset,remaining,input,same):
  NextBody20260.retired(written,next,id,offset,remaining,input,same)


def Laws.finite_body_retirement_preserves_controller_records_and_redirects(values,w,next,id,offset,remaining,input,same):
  NextBody20261.frame(values,w,next,id,offset,remaining,input,same)


def Laws.preparing_one_controller_preserves_a_different_controllers_record(w,actor,other,tail,different):
  NextBody20262.preparedOther(w,actor,other,tail,different)


def Laws.finite_body_proof_constructs_the_next_controller_handoff(before,steps,body,values,id,offset,other,captureOffset,methods,input,controller,same):
  NextBody20263.fromBody(before,steps,body,values,id,offset,other,captureOffset,methods,input,controller,same)


def Laws.constructed_handoff_second_body_retires_the_last_obligation(before,steps,id,offset,other,captureOffset,values,answer,rest,stack,incoming,rejected,ready):
  NextBody20263.complete(before,steps,id,offset,other,captureOffset,values,answer,rest,stack,incoming,rejected,ready)


def Laws.constructed_handoff_second_body_restores_the_caller_value_stack(before,steps,id,offset,other,captureOffset,values,answer,rest,stack,incoming,rejected,ready):
  NextBody20263.savedStack(before,steps,id,offset,other,captureOffset,values,answer,rest,stack,incoming,rejected,ready)


def Laws.certified_first_controller_constructs_both_body_handoff(seed,id,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,ready):
  NextBody20265.complete(seed,id,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,ready)


def Laws.raw_joined_controllers_construct_the_second_body_handoff(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected):
  NextBody20266.complete(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_joined_controllers_second_resume_retires_the_last_obligation(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected):
  NextBody20267.complete(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected)


def Laws.raw_joined_controllers_second_resume_has_exactly_zero_live_debt(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected):
  NextBody20268.count(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected)


def Laws.raw_joined_controllers_second_resume_restores_its_caller_stack(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected):
  NextBody20268.savedStack(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected)


def Laws.current_cached_alias_resume_has_the_exact_post_body_output_machine(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known):
  JoinedRound20260.currentExact(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)


def Laws.fresh_cached_alias_resume_has_the_exact_post_body_output_machine(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known):
  JoinedRound20260.freshExact(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)


def Laws.current_cached_alias_resume_constructs_a_finite_exact_output_drain(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known):
  JoinedRound20260.currentDrain(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,open,known)


def Laws.fresh_cached_alias_resume_constructs_a_finite_exact_output_drain(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known):
  JoinedRound20260.freshDrain(w,actor,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,remaining,initial,sourceAlias,cached,alias,captured,positive,empty,open,known)


def Laws.actual_output_observer_drain_preserves_derived_body_obligation_count(before,steps,id,offset,remaining,outcome,rest,stack,form):
  JoinedRound20261.remaining(before,steps,id,offset,remaining,outcome,rest,stack,form)


def Laws.raw_joined_controller_body_has_a_finite_exact_output_drain(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedRound20262.drain(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.certified_joined_controller_body_reaches_queued_round_with_derived_guards(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known):
  JoinedRound20264.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)


def Laws.raw_joined_controller_body_reaches_round_before_saved_question_restore(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedRound20267.complete(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_joined_controller_round_boundary_retains_one_obligation(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedRound20267.count(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)


def Laws.raw_joined_controller_round_boundary_remains_an_unchanged_blocker(value,values,answer,other,reverse,second,rest,stack,incoming,rejected):
  JoinedRound20267.blocked(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)
