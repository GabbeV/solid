import Base
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

# Negative source baseline: this is not the intended recovery guarantee.
law staged_error_recovery_counterexample:
  {HeldError.view(HeldError.delivered()) == HeldError.expectedCounterexample() : HeldError.View}

law until_false_waits:
  {Until.falseCase() == Until.expectedFalseCase() : Until.Case}

law until_truthy_resolves:
  {Until.trueCase() == Until.expectedTrueCase() : Until.Case}

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
