import Base
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

law trim_error_overrides_application_error:
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

# Negative upstream regression at 71153bf0, not a desired cleanup guarantee.
law throwing_teardown_leaks_release_collector:
  {Integrated.collectorLeak() == Integrated.expectedCollectorLeak() : Integrated.LeakView}

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

# Negative upstream counterexample: this claims the observed bug, not the
# desired replacement guarantee. Kept separate from positive capability laws.
law pending_reaction_arm_survives_replacement:
  {Reactions.pendingReplacement(False{}) == Reactions.expectedPendingBug() : Reactions.PendingView}

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
    == Core.Machine{Status.notifyStatusWith(R.World.with_fault(w, R.Healthy{}), id, K.STATUS_ERROR(), error, False{}), rest, R.Boolean{True{}} <> saved} : Core.Machine}

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
    == DisposalOwner.Machine{w, DisposalOwner.Invoke{callback} <> DisposalOwner.DisposalLoop{B.append(Nat, prefix, [callback]), B.length(Nat, prefix)} <> rest} : DisposalOwner.Machine}


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
  {Core.evaluate(w, rest, stack, R.ActionCreate{factory, methods}, previous) == Core.Machine{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ActionFunction{factory, methods, previous}], False{}}])), rest, R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))} <> stack} : Core.Machine}

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
