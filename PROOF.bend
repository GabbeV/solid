import Base
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

def Laws.trim_error_overrides_application_error():
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

def Laws.throwing_teardown_leaks_release_collector():
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

def Laws.pending_reaction_arm_survives_replacement():
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
