# Latest preparation trials: synchronous progress, incomplete ownership

No runtime changes or test expectation changes are retained. Stage 148 remains
the implementation checkpoint.

A trace of a plain synchronous write to `s`, read as `[latest(s), s()]`, shows
why the current implementation calculates repeatedly: it first computes with
old latest / new ordinary proposal, then with new latest / committed ordinary,
then with both new. Only the final coherent pair publishes. These extra passes
are not a desired contract.

Two small trials test a simpler rule: while no override is needed, latest
propagates ordinarily; establish its optimistic boundary when the input is held.

- Letting the inactive output consume an unheld synchronous proposal alone
  fixes none of the existing assertions. The later preparation still creates
  the temporary override, producing the extra contexts.
- Also removing latest's request to prepare overrides for unheld values makes
  all six #4402 synchronous one-pass cases and twelve memo/inline parity cases
  pass unchanged. The full trial additionally repairs both #4365 calculation
  traces. All unified tests and the 26 store seed/manual-write guards pass.

The broader trial is still rejected: store recovery can remain behind its
error, a Loading fallback appears early in an action-held navigation, and an
owned content chain returns `show:undefined`. These are real publication or
ownership problems, not acceptable changes to get smaller code. Other new
failures are callback/calculation traces, twelve unique-question assertions,
and three generated-index checks (the index was not regenerated for this
rejected runtime). The full delta is archived; no new expectation was waived.

## Repeated arguments do not measure total work

The two-reader request fixture has distinct numeric encodings for its inputs.
For its pair/zero-gap case:

```
next:      m0:23, m0:22, m0b:1100, m0b:1000, m1:1022, m1:1123
retained:  m0:13, m0:22, m0:23, m0b:100, m0b:1000, m1:1023, m0b:1100, m1:1123
trial:     m0:23, m0:22, m0:23, m0b:1100, m0b:1100, m1:1123
```

The trial fails uniqueness while asking fewer total questions than the retained
implementation. That is not grounds to accept it: repeated requests, cancelled
work, and latency all matter. It does show that uniqueness alone misses the
retained implementation's unnecessary questions over stale latest values.
Next and the retained runtime were executed from their built dev artifacts;
trial evidence uses normal source tests. This is a functional request trace,
not a timing or performance comparison.

A small controlled feedback probe over `10 * latest(s) + s()` gives the trial's
questions `22 -> 21 -> 22` after s changes 1 to 2. The first two answers are
superseded and do not publish. Only the final answer publishes, with s=2.
This resembles the already accepted pending-feedback cancellation/reversal
case; it is not by itself proof of tearing or of a newly required ruling.

## What to carry forward

The one-pass result demonstrates an opportunity, not a retained optimization.
Moving a calculation between update contexts must also correctly move its
owned frame and store writes. Read-level shortcuts are insufficient. Further
work should address that ownership operation before adding more latest-specific
conditions. No value-only success overrides the structural counterexamples.

All trial runtime edits and temporary test/config files were removed. An exact
file comparison restores latest.ts to stage 148; 50 focused restored tests have
the same 21 passes and 29 known failures as that baseline. Rules-index and diff
checks pass. The built runtime was not replaced, so no artifact rebuild is
needed for this rollback. Full retained counts remain stage 148: signals
5,384/2,047/two skipped; web 1,689/128/one skipped.

Receipts and rejected sources: `checkpoints/integration-stage149.tar.xz`.
