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

# Negative source baseline: this is not the intended recovery guarantee.
law staged_error_recovery_counterexample:
  {HeldError.view(HeldError.delivered()) == HeldError.expectedCounterexample() : HeldError.View}

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

law held_function_result_counterexample:
  {WritableSignals.counterexample() == WritableSignals.expectedCounterexample() : WritableSignals.Counterexample}

law setter_cleanup_preserves_identity_and_clears:
  {SetterCleanup.scenario() == SetterCleanup.expected() : SetterCleanup.View}
