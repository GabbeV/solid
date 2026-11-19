# Independent input and override lifetimes

The user authorized this trial: input and output are separate nodes, so an input
answer need not join the guessing action's lifetime. Overlapping guesses on the
same output remain a separate case and still entangle. Baseline is unmodified
next `4fe75321`. This is a local implementation experiment, not an upstream fix
or a claim of full scalar acceptance.

## Observable rule

```ts
const [id, setId] = createSignal(0);
const [view, guess] = createOptimistic(() => id() ? fetchAnswer() : "A");

const save = action(function* () {
  guess("A + mine");
  yield saveRequest();
  yield refresh(view);
});
```

An independent `setId(1)` while save is open may publish `1 / A + mine`.
Resolving `fetchAnswer()` to B leaves that override selected. After save and
refresh finish, correction publishes `1 / B`, holding the output and its
ordinary downstream derivations together if correction needs async work.
A synchronous B follows the same lifetime rule as a promised B.

For the reduced input-change example in stage 118, next releases id for the
sync answer but holds id for the async answer. The previous experiment did the
opposite. This trial releases id in both. It does not rebase a functional guess
or make the override follow a changed resource identity. That is an observable
boundary policy, not inconsistent publication among readers of its output.

## Implementation

- Removed the incoming-answer join from `selectGuess` and the already-held
  input join from `bindScope`. Selection now only reads the override or input.
- Retained same-output scope merging, ordinary memo coordination, and normal
  correction reads. An input update written by the guessing action itself
  still belongs to that action by ordinary attribution.
- Retained the existing pending-input lifetime hold, including after reader
  disposal (stage 114). Removing input/action merging does not mean expiring an
  override while its own input is still pending.
- Input revision tracking is now attribution-only and absent in production;
  it no longer participates in selection or lifetime coordination.

The deeper nested test found an existing transparency defect: demand tracing
followed an active override's retained input subscription through intervening
inactive boundaries. Two layers released the lower update; four layers held
it. The four-layer test also failed before this trial. Demand tracing now stops
at that override subscription, which receives future notifications without
consuming the input. This change is confined to optional layer demand tracing;
it adds no ordinary node fields or ordinary read checks.

The implementation supports the user's hypothesis that the split permits
independent lifetimes. It does not prove that storage reuse was the sole reason
for next's existing rules.

## Test changes and classifications

Sixteen existing experiment cases asserted input/action lifetime joins. Their
input-publication expectations are revised under the user's authorization;
output/derived consistency assertions remain. These cover functional guesses,
async corrections, parent re-guesses, conditional inputs and pending child
derivations. A source belonging to another still-open action remains held until
that action ends; only its extra wait for the guessing action is removed.

New scalar coverage includes:

- Realistic save-then-refresh actions with sync and async incoming values.
- Shared memo answers and same-call direct refreshes of independent outputs:
  ending one guessing action corrects only its output.
- A lower layer retiring while an upper override remains active, at depths two
  and four; the intermediate input may finish before either action ends.
- Repeated guesses held by async work, unrelated source writes, late readers,
  correction superseding that work, and cleanup of the replaced output frame.
- Inactive-boundary/memo equivalence with a suspended upper derivation and
  with/without a separate observer of the input.
- Sync and async input errors remaining masked until correction, then recovery.

The new error test initially required cleanup of a settled dependent at error
publication. An ordinary-memo control in both runtimes instead retains the
hidden boundary contents without rerunning the dependent. The final test checks
that path: no premature cleanup while the guess shows, hidden retention at the
propagated error, and exactly one cleanup of that retained frame on recovery.
This does not restore next's optimistic-only replay. Next's scalar async-error
case also reveals the error while the guessing action is still open, unlike
the trial's uniform override selection. The ordinary controls and next probe
are retained in the result receipts.

Two JSX tests run against the built package. They show the independent input
advancing while every ordinary output binding keeps the first published guess,
then coherent correction and rejection of the obsolete async answer.

## Validation and remaining scope

Receipts are under `results/integration-stage120/`. The final complete signals
run has 5,137 passes, 2,164 failures and two skips, with the exact same existing
failure set as stage 117 after the authorized test revisions. All fifteen new
scalar cases pass, including the transparency and input-error cases.
The complete web run has 1,584 passes, 139 failures and one skip: only the two new
JSX passes differ from stage 117. Passed counts include expected-failure tests.

Existing migration failures remain visible. Optimistic stores and `until` remain
deferred; the remaining scalar failures still need audit. These finite timelines
and the existing overlap/retention tests are evidence, not a universal proof.
No new semantic ruling is required by the exercised cases so far.

All build tiers, property mangling, pure checks and declarations pass. The
generated mangle map drops the production input-revision property. The two new
JSX cases and retained reader-removal case also pass against the final build.
`git diff --check` passes.

## Costs

The repository's standard size harness measures these production imports:

| Scenario | Next minified / Brotli | Trial minified / Brotli |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 B | 21,153 / 7,904 B |
| Ordinary store | 43,868 / 15,089 B | 45,222 / 15,513 B |
| Pending/latest | 33,615 / 12,239 B | 34,507 / 12,391 B |

A supplementary scenario through the same `scripts/size/bundle.mjs` imports
signal, memo, render effect, root, optimism, action, flush and refresh from the
built production package. It measures 31,722 / 11,561 B in next versus
34,203 / 12,472 B in the trial. Exact imports and runner are saved beside the
receipts. No cap is invented or raised for this supplementary measurement.
The standard core/store sizes are unchanged by this trial; pending/latest also
contains the demand-tracing fix. Existing standard size caps still fail.

No new runtime performance claim is made. The removed joins and production
revision tracking affect optional optimistic machinery; the additional demand
cut check runs in layer visibility tracing. Settled ordinary reads and node
layouts are unchanged. The overall size/performance acceptance gaps remain.
