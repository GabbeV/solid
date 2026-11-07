# Remaining async waits and request assertion migrations

Retain one runtime repair: when an async source settles but a dependent still
has another pending source, ask the existing context coordinator whether that
remaining wait belongs to the dependent's current update. Adoption into an
optimistic update can otherwise leave an inherited lower wait attached forever.
The existing status hook schedules reevaluation; no fields or synchronous-read
branches are added.

Six public controls cover value, paired-pending and split readers, with and
without refreshing while a downstream request remains open. A separate ordinary
observer keeps the input update alive. All six pass in dev and production. Pinned
next `4fe75321` fails the two refreshed value/split controls, as did this experiment
before the repair: the ready optimistic answer remains invisible until the
independent hold ends.

## Assertion migrations

Nineteen old failures now pass after adapting their exact request/publication
assertions to the already accepted single-flight and independent-lifetime rules:
five in `latest-two-readers-one-ask-4393`, fourteen in
`verdict-memo-flight-no-reask`. Context correction can restart an earlier request;
expired optimistic work cannot keep its input alive. The migrations retain
publication assertions and explicitly exclude obsolete intermediate results.
They are not nineteen runtime fixes. Four additional variants retain a separate
input observer and pass their original intermediate-publication expectations.

Four original grouped/split cases remain failing, with their assertions intact.
A normal JSX reduction confirms a substantive defect: while the paired binding
still shows result 103, imperative result reads and a late-mounted ordinary
binding see 104. Removing the pending read avoids this disagreement; pinned next
also shows 104 in the paired binding. This is an implementation bug, not a
justification to waive grouping assertions. Input-lifetime timing alone does not
explain or permit inconsistent observations of the result's published output.
The reduction and both next/experiment traces are archived for the next repair.

## Validation

- Full signals: **5,582 passed / 1,983 failed / two skipped**. Remaining failures:
  **1,953 deferred API cases and 30 non-deferred cases**. Nineteen assertion
  migrations and ten added controls account for the pass-count increase.
- Full web: **1,701 passed / 119 failed / one skipped**, unchanged failure set.
- Built, mangled production public set: **442 passed / four failed**; the four
  are the unchanged grouping cases. All 393 standalone controls pass.
- Build tiers, property mangling, purity, declarations, rules index and diff
  checks pass. No performance or bundle-size claim.

The first-held-value/store failures and private first-callback/ownership cases
remain unresolved. The new JSX trace is a diagnostic receipt, not an additional
passing test or proof of scalar correctness. Receipts and the complete inventory:
`checkpoints/integration-stage164.tar.xz`.
