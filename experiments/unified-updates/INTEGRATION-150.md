# Error observations and ordinary recovery publication

This checkpoint applies the existing error-as-answer and observation-boundary
rules. It introduces no new override lifetime, observedness forwarding, or
pending-feedback diagnostic.

## Error observations

A callback query must read values to choose its dependencies:

```ts
isPending(() => chooseLeft() ? left() : right())
```

Those value links must not automatically turn the boolean query's reader into
an errored node when a source fails. The callback catches that error and the
source's pending output supplies its boolean. Ordinary reads outside the
callback still throw.

The repair re-derives a reader that currently consumes the source's pending
output instead of copying the source's error onto it. It uses existing graph
edges and their pass generation, not a reader flag or extra node property.
Only current-pass edges count: links retained for a previous frame must not
reclassify a replacement that threw before reaching the query. Scanning the
reader's current inputs avoids quadratic work across a source's subscriber list.
The hook is installed lazily by the pending feature and called on error paths.
An initially errored source also initializes its pending output as false rather
than throwing from the pending output's own producer.

A store's explicit observation previously installed an unconditional direct
link to its staged-error producer. That bypassed the selected observation
output. Ordinary throwing reads retain that wake link; observation windows
obtain their dependencies through the observation read.

## Recovery uses the normal changed-answer path

```ts
const value = createMemo(() => {
  if (failed()) throw new Error("failed");
  return undefined;
});
```

While an action holds `setFailed(false)`, an already displayed error stays
visible and `isPending(value)` is true. At the action's completion the value
and its ordinary consequences publish together and pending becomes false.

The old equality gate could compare undefined with the last successful
undefined and miss that the outgoing answer was an error. Including that
already-captured error in the changed-answer decision repairs this case and
allows deletion of the separate `settleErroredDependents` recovery walk.
A derived store has the same issue because its producer returns undefined;
recovering to seed-equal data is still recovery from an error.

This exposed a real boundary defect. An error boundary keeping its fallback
while recovered content remained pending could return before re-linking its
content tree. The next error then never reached the fallback. Keeping that
subscription repairs the existing #2701 test with unchanged assertions. Merely
restoring the separate recovery walk did not repair it.

The recovery equality and boundary-subscription repairs also apply to next's
existing machinery; they are not evidence of an experiment-specific performance
advantage. No new timing or bundle-size advantage is claimed here.

## Derived errors use ordinary staging

A projection producer had an exemption from staging an error after consuming
this flush's proposed input. It could replace its initial error immediately
while the equivalent memo kept the previous error and reported pending=true.
Removing that exemption lets the family's already-queued readers consume the
same staged answer as ordinary memo readers. The existing web E3 equivalence
assertion passes without changing its timeline or expected values.

## Validation

Seventeen new signals checks cover direct and callback pending reads, errors
on first computation and later updates, held and immediate changes, memo
wrapping, ordinary reads outside a pending callback, recovery to undefined,
and replacement of one error by another. A JSX test verifies the complete
memo/store recovery timeline: error/false -> error/true -> value/false.
Pinned next 4fe75321 passes 13 of the 17 signals checks and fails four recovery
checks; its rendered recovery trace likewise leaves the store's pending flag
false while the old error remains displayed. The existing #2701 test remains
unchanged. Its failure during the intermediate recovery trial was resolved,
not waived. Earlier trial receipts also include an invalid full-web source
alias run (eight attribution-import failures); it is not a retained-suite result.

Full retained validation against the rebuilt package:

- Signals: **5,401 passed / 2,047 failed / two skipped**; seventeen new passes,
  no changed outcome among previously collected tests.
- Web: **1,691 passed / 127 failed / one skipped**; the new DOM case and the
  existing E3 case pass, with no new failures.
- Production scalar focus: **671 passed**, including all unified tests and
  the new store observation controls.
- Build, property mangling, both purity checks, declarations, rules-index and
  diff checks pass.

The signals run additionally has a pre-existing collection failure in
`loading-fallback-in-flush-3540.test.ts` (a syntax error at line 890). It has no
collected cases and is not included in the case totals above. Stage 148 had the
same collection failure. Restoring this fixture is the next audit task; the
reported case counts must not be read as complete execution of every file.

Remaining collected-case inventory: signals 1,953 deferred API, 78 untriaged,
twelve calculation expectations and four implementation-bug cases; web 115
deferred API, six untriaged and six calculation expectations. The known
store duplicate-error callback test still fails with its previous duplicate
on recovery; no assertion was relaxed. Scalar correctness and performance/size
acceptance remain open.

Receipts: `checkpoints/integration-stage150.tar.xz`.
