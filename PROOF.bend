import Base
import ./proof/deferred-program.bend as DeferredProgram
import ./proof/deferred-lifecycle.bend as DeferredLifeLaws
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

def Laws.lane_confirmation_stages_before_join(w, rest, stack, id, parent, value):
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

def Laws.lane_guess_zero_reveals_preserve_world(w, rest, stack, leaked):
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

def Laws.deferred_life_closedFailure(w, state, error):
  DeferredLifeLaws.closedFailure(w, state, error)

def Laws.deferred_life_answeredSticky(w, node, flight, marked, lagging):
  DeferredLifeLaws.answeredSticky(w, node, flight, marked, lagging)

def Laws.deferred_data_complete(initial, next, extra):
  DeferredProgram.complete(initial, next, extra)

def Laws.deferred_data_result(initial, next, extra):
  DeferredProgram.result(initial, next, extra)
