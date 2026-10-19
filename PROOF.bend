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
