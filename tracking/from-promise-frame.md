# Promise and iterator cancellation preservation

Six additional quantified roots prove that Promise delivery/settlement and the
wrapped iterator's pending-list cancellation, finish and callback delivery leave
all 68 other World fields unchanged. Promise objects, host jobs and stream closure
plans form the explicit three-field mask. The proofs use list induction and
settlement case analysis over arbitrary represented Worlds, values and finite
observer/pending lists. They do not assume one pending resolver or one observer.

These are preservation guarantees, not arbitrary asynchronous progress or
well-formedness of every arena token. Runtime and host remain unchanged from
e41a86f. All previous complete lifecycle domains and budgets remain checked.
Two compiled source mutations corrupt ambient context or tracking; the focused
independent kernel checks reject both. 568 variants are now configured (469
finite, 99 kernel); this is not a fresh complete 568 sweep. The separately frozen
wrapped-runtime checkpoint's complete 564-variant sweep is recorded in
[its receipt](reviews/from-wrapped-complete-negative.json).

The longer 170-step seeded late-push lifecycle has passing finite native controls
but does not pass the independent kernel, which reports `out of fuel`. Its source,
failed candidate terms and evidence are retained in the explicitly unverified
[experiment archive](../experiments/from-async/README.md). It is excluded from
active proof roots and default property checks. No runtime workaround, kernel
limit change, new source bug or semantic deviation was introduced.
