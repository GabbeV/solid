# Capture async request inputs in the publication fixtures

Three #4284/inline-parity fixtures reread `x()` inside their manually invoked
promise resolver. That imperative read observes the committed output in the
experiment; while the new request is held, it still returns the old value.
The fixture consequently answered the request for 5 with `"x1"` and reported
that manufactured mismatch as a propagation failure.

The fixtures now capture `x()` during derivation and resolve that request with
its captured value. All publication and consistency assertions are unchanged.
This is a fixture correction for the already accepted committed outside-read
behavior, not a runtime change or a relaxation of consistency.

The selected scalar run passes nine tests and fails one separate no-async
run-count assertion (five calculations instead of two). Its publication
assertion passes; the additional calculations remain an optimization issue.
Both selected JSX async cases pass. The complete two scalar files pass all
42 tests on pinned next `4fe75321`, and the complete JSX file passes all 15.
The corrected cases account for seven previously failing scalar tests and
two previously failing JSX tests. Full-suite totals have not been refreshed.

Receipts are in `results/integration-stage128/` and its separate checkpoint
archive. No runtime, performance, allocation, or bundle-size claim is made.
The other scalar failure groups remain under investigation before stores.
