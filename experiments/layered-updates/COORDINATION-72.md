# Stage 72: producer-local previous values and inactive coordination cost

The user accepted the stage-71 recommendation: an optimistic input callback
receives its own producer's previous result. Its output override is not fed back
into that callback. Functional guess setters continue using the selected output.
This is an intentional difference from pinned next, not a compatibility bug.
The baseline remains `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

## Retained implementation and validation

The callback parameter is now exposed in the experimental scalar and internal
layer types. It is initially undefined. As with the memo API, an explicit type
such as `createOptimistic<number>(previous => ...)` supplies context for stateful
arithmetic. No callback-feedback runtime mechanism was added: the split producer
already has the selected behavior.

Two regression tests exercise dependency changes and repeated refreshes while an
output override remains active. They check actual render publications, functional
guess setter arguments, initial undefined, and reuse of the producer's own staged
result on a subsequent calculation within the same update. An isolated typecheck
also verifies the callback parameter and result types.

Observation lifecycle registration now uses module bindings and a setter instead
of a mutable hook object. Optimism-only bundles can drop unused observation hook
calls when pending/latest are absent. The runtime callback ordering is unchanged.

Dependency-journal commit/disposal still removes every inserted link. It now
skips snapshot WeakMap work when the node has no extension. Parking and errors
allocate that extension and never clear it; consequently such a node cannot have
a saved dependency frame. This extends the existing initial-commit shortcut to
ordinary synchronous branch changes without adding node fields or a cache.

The retained source passes 5,571 tests in 330 files, with the existing 22 expected
failures and two skips unchanged. The expanded retained-frame campaign passes
92 tests in six files, including 500-seed branch and layer timelines. Source
and focused callback typechecks pass; the production build passes with its
existing unrelated diagnostics. No runtime consistency assertion was weakened.

## Measurements against next

An initial seven-pair campaign retained optimism in both bundles but performed
ordinary synchronous work. Several cases were roughly 5–6% slower. An eleven-pair
follow-up still measured branch switching at 1.100 candidate/next. That motivated
the snapshot-lookup refinement above. The final eleven-pair measurements of the
retained runtime are:

| Workload with optimism imported but inactive | Paired time ratio to next |
| --- | ---: |
| Signal read | 0.947 |
| Branch switching | 1.021 |
| Memo write | 0.983 |
| Chain | 0.987 |
| Memo creation/disposal | 1.078 |

All raw samples are retained. The initial follow-up's signal-read measurements
began while a typecheck was finishing; use the final independent signal-read
campaign instead. The other final measurements ran without tests/builds in
parallel. The creation result remains a concern, with overlapping ranges and
variation across prior campaigns. These results do not establish acceptance or
justify dismissing all ordinary-path overhead as noise.

Active-stack top-write ratios at depths 1/4/16 are 2.238/1.872/1.523 (three
alternating pairs). The expensive transparent-chain measurement from stage 71
has not been rerun for this minor refinement; it remains a reason to keep active
throughput acceptance open, not a timing claim for this exact source.

| Import scenario | Next minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| ordinary | 21918 / 8116 | 21529 / 7988 |
| optimistic | 27250 / 9864 | 30138 / 10920 |
| pending | 28812 / 10419 | 31860 / 11426 |
| latest | 28715 / 10368 | 31412 / 11307 |
| refresh | 27892 / 10117 | 22216 / 8244 |
| optimistic + refresh | 28322 / 10208 | 30816 / 11146 |

Ordinary-only Brotli remains 1.6% smaller and optimism is 10.7% larger than next.
The hook change is a small opt-in size refinement, not a solution to that gap.
Stores and the full upstream API remain outside the validated scalar entry.

## New semantic question: previous results across update contexts

The accepted producer-local ruling answers which computation owns the previous
value. It does not decide whether a higher calculation may inherit an unpublished
result produced by a lower calculation of that same computation.

```ts
const [base, setBase] = createSignal(0);
const [preview, guess] = createOptimistic(() => 0);
const total = createMemo<number>(
  (previous = 0) => previous + base() + preview()
);
```

Materialize and render all three. Action A sets base=1 and remains open. The memo
calculates 1 but nothing publishes: the displayed values are still 0/0/0.
Action B then guesses preview=10 and remains open.

Production observations, with both actions still open:

| Runtime | Calculation(s) for the optimistic update | Display base / preview / total |
| --- | --- | --- |
| next | 1 + 1 + 10 = 12, then 12 + 0 + 10 = 22 | 0 / 10 / 22 |
| prototype | 1 + 0 + 10 = 11 | 0 / 10 / 11 |
| proposed ruling | 0 + 0 + 10 = 10 | 0 / 10 / 10 |

The prototype correctly reads committed base=0, but supplies the lower held
result 1 as previous. Next additionally reruns, accumulating a rejected attempt's
12. The same contrast occurs when the stateful function is the input producer
of a transparent optimistic boundary rather than an ordinary memo.

This is a stateful-callback contract question, not by itself a demonstration of
DOM tearing: the expression explicitly carries history. The initial recommendation
was that switching to a higher context starts from the computation's committed
result; repeated calculations in the same context may use its staged result.
That would align the implicit argument with ordinary reads, but is not a complete
answer for a reducer whose only record of separately processed writes is its held
result. Discarding that result can lose history. The subsequent reducer audit
in `REDUCERS-73.md` qualifies this recommendation: ordinary synchronous reduction
and downstream optimistic presentation already compose; reduction inside a
context-switching computation remains unresolved. No cross-context previous-value
change, per-layer value history, or authoritative duplicate graph is implemented.

Classification: unresolved semantic question (category 3). The portable
`previous-context-audit.mjs` records the behavior without asserting a preferred
outcome. Its next/candidate JSON outputs are retained under the stage-72 results.
No previous-value context change has been implemented.

## Reevaluation

The scalar value/publication model remains viable in the exercised cases, and
the new producer-local ruling fits the split representation directly. Stateful
callbacks expose another implicit input that must be specified before claiming
uniform context selection. Small cold-path and tree-shaking refinements have
not demonstrated that the active-cost goal is reachable; that remains open.
The current checkpoint and exact source are saved before further coordination
changes, and stores remain paused.
