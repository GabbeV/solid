# Arbitrary represented payload proofs for `from`

The implementation is unchanged from the wrapped-iterable checkpoint 8353373.
Both complete lifecycle families now also quantify over an arbitrary `R.Value`,
without classifying that value as a natural, boolean, string or opaque reference.
This includes function and asynchronous-object tokens **carried as data**. The
original ordinary-data families and their budgets remain independently checked.

`from-value-program.bend` proves all 120 constructor/read/dispose/flush steps
for the direct subscription producer. Its exact result corollary retains the
input value and proves exactly one unsubscribe, with Healthy fault.
`from-iterable-value-program.bend` proves the 84-step buffered-then-pending
wrapped iterator lifecycle. Its result retains that input, calls the inner
return once, closes/clears the wrapper, and cancels its pending pull while the
inner external Promise stays unresolved. Both sufficient budgets admit any
additional fuel. Two definitional bridges show the new drivers start at exactly
the preceding ordinary drivers for every `Payload.Ordinary` input; no staged
constructor precondition or narrower payload substitution is introduced.

These are six additional quantified roots (two complete programmes, their two
result corollaries and two input bridges), not a proof of arbitrary subscriptions,
graphs or async histories. All existing theorem domains/budgets remain intact.
An arbitrary `R.Value` token is not automatically a well-formed external JS
input: arena-backed arrays/accessors/iterators still need a valid allocation
context. The theorem states exact Bend execution/data retention for this fixed
programme; it does not establish a JS encoding theorem or TS equivalence.

36 finite controls compare 3,708 actual step prefixes and exact final Machines
at three budgets, alongside unchanged native Solid. Besides the former ordinary
cases they cover an empty function, the subscribe/unsubscribe functions, the
actual owned root disposer and an iterable that yields itself. They assert
native function/data identity and once-only cleanup without calling a data
function. The current memo's accessor is unavailable during eager construction;
an attempted native fixture emitted undefined before that accessor existed and
is excluded. This is a fixture/allocation boundary, not an upstream bug.

Two isolated selector mutations drop only function-valued or iterable-valued
data. Executable driver controls retain ordinary sample payloads but demonstrate
the lost additional values; the independent kernel rejects the new proof roots.
The old proof terms also need additional case analysis under those altered
selectors, so their rejection is not claimed as an ordinary-domain semantic
counterexample. A first mutation of an unused selection helper was accepted;
it was replaced with changes on the actual execution path and is not credited.

The broader proof does not add runtime data kinds. Negative/fractional IEEE
payload arithmetic, symbols, bigint, mutable JS protocol objects, Observable
interop, object unsubscribe and arbitrary JS function/generator bodies remain
outside the current admitted grammar. There is no new source bug, patch or
semantic deviation.
