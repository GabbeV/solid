import Base
import ./LAWS.bend as Laws
import ./proof/paths.bend as Paths
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

def Laws.staged_error_recovery_counterexample():
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
