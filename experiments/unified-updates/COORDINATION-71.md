# Stage 71: held-read shortcuts and the previous-input contract

This is the current local scalar checkpoint, following the notification-based
coordination in [stage 70](COORDINATION-70.md). It is not scalar acceptance.
Stores remain paused. The baseline is unchanged next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

## Runtime changes

A held read of this exact update's proposal does not need to discover another
context. `joinPass` now resolves the holder before asking the optional discovery
hook and skips that hook when it already matches the current update. The layer
frame-read hook has the corresponding identity shortcut; merged holders still
use the full resolving path. Parking a proposed frame with no owned children
skips the empty recursive walk. No node fields, context cache or publication
exception was added.

These are narrow refinements in the real core, not evidence that active-update
cost is solved. The profile in `results/coordination-stage71/profile/` uses an
unminified bundle of the stage-70 production build to preserve function names;
its source is retained there. It showed recomputation, context routing, reads
and parking spread across the expensive transparent-chain case. It is diagnostic,
not a performance comparison against a reference prototype.

The final runtime passed 5,569 tests in 329 files, with the existing 22 expected
failures and two skips unchanged. Source typechecking and the production build
pass. The 396 scalar tests are included in that full run. Production audits
recheck F5b, equality/publication, and refresh. The stage-70 500-seed campaign is
additional evidence for the notification mechanism; it predates these three
shortcuts and is not labelled as a stage-71 campaign.

## Performance and size versus next

All timings use actual compiled core builds in alternating fresh processes.
The ordinary campaign has seven paired samples per workload. The observed
candidate/next paired ratios are:

| Ordinary workload | Ratio |
| --- | ---: |
| Signal / memo reads | 0.918 / 0.926 |
| Write and flush / memo write | 0.975 / 0.948 |
| Equal writes / ten-write batch | 0.993 / 0.850 |
| Chain / diamond | 0.934 / 0.981 |
| Memo / effect fan-out | 0.917 / 0.966 |
| Branch switching | 1.028 |
| Signal creation / memo creation-disposal | 0.857 / 1.037 |

Several sample ranges overlap. The small branch/creation differences do not
establish a persistent regression; neither do the improvements establish a
portable percentage gain. Ordinary synchronous cost remains near parity or
better in this campaign. All raw samples are retained, including stage 70's
noisy follow-ups, rather than selecting only favorable runs.

Active-stack top writes at depths 1/4/16 have median paired ratios of
1.996/1.899/1.471 (three pairs). The 16-boundary transparent chain takes median
31.57 microseconds versus next's 7.70 for callbacks, and 33.04 versus 7.30 for
direct inputs (five-sample medians). Active throughput remains an acceptance gap.

Retained boundary memory is approximately 1,155 versus 556 bytes for callbacks,
and 1,113 versus 568 for direct inputs. Two full nodes remain in use; no new
ordinary-node allocation was introduced by these shortcuts.

| Import scenario | Next minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| ordinary | 21918 / 8116 | 21529 / 7988 |
| optimistic | 27250 / 9864 | 30193 / 10934 |
| pending | 28812 / 10419 | 31896 / 11433 |
| latest | 28715 / 10368 | 31448 / 11301 |
| refresh | 27892 / 10117 | 22216 / 8244 |
| optimistic + refresh | 28322 / 10208 | 30871 / 11154 |

Ordinary-only Brotli is 1.6% smaller; optimism is 10.8% larger. Size acceptance
has not been declared and no thresholds were raised. The feature surface remains
that listed in `SCALAR-API.md`, not the complete upstream package.

## Previous input result: question resolved after this checkpoint

The input/output split gives the callback's previous argument a different
meaning from next's fused optimistic node. This callback contract is explicitly
outside the previously validated API surface, but JavaScript can already pass
such a callback to the experimental entry.

```ts
const [step, setStep] = createSignal(0);
const [value, guess] = createOptimistic((previous = 0) => previous + step());
```

Start at 0. In an action publish guess(10), then setStep(1), then finish the
action. A production comparison records:

| Observation | Pinned next | Split prototype |
| --- | ---: | ---: |
| Callback's previous argument on the second run | 10 | 0 |
| Rendered while the action remains open | 10 | 10 |
| Rendered after the action ends | 11 | 1 |

Next's recompute selects the lane slot as the function's previous value.
The prototype's producer uses its own previous result. Refresh exhibits the
same distinction: with input `previous => previous + 1`, starting from 1 and
guessing 10, next's refresh resolves 11; the prototype resolves 2. Both retain
the displayed guess until the action ends in this example.

This does not itself tear. It decides whether an override is also feedback into
its input computation. The recommendation is to keep the producer's own previous
result: overriding an output should not implicitly change the state of the
function producing its input. Next's behavior can be useful when a stateful
callback deliberately folds the optimistic output into the next result, but
preserving it would explicitly couple the two roles again. Functional setters
`guess(previous => ...)` remain a separate contract: they use the selected
output, as already implemented.

The user accepted the producer-local previous result after this checkpoint.
Stage 72 adds normative coverage and types for that contract. This is an
intentional semantic change from next, with the rationale above. The
portable script `optimistic-previous-input-audit.mjs` records both behaviors;
its outputs are in `results/coordination-stage71/previous-input-{next,candidate}.json`.
No callback-feedback mechanism or compatibility exception has been added.
