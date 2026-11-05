# Rebase onto current next and scalar integration repairs

Baseline: `f6b6737b` (`2.0.0-rc.21`), fetched 2026-11-05. This replaces
`a24e911b` (rc.14) as the comparison point. There were 546 intervening upstream
commits. Historical benchmark percentages and bundle comparisons remain records
of their old baseline; they do not describe performance against current next.

The local rebase is complete. `checkpoint/layered-pre-rebase-110` preserves the
pre-rebase checkpoint (`3b8be080`), and the complete pre-rebase workspace archive
is `/workspace/scratch/rebase-stage110/pre-rebase-worktree.tar.gz`. The rebased
checkpoint is `5df88f50`. Nothing was pushed or posted.

## Reconciled machinery

The rebase retains upstream's optional named hooks, staged errors, held-frame
tracking, iterator cancellation, comparator containment and publication fixes.
The shared engine still uses ordinary transactions for all depths, its intrusive
held-node list, split optimistic input/output selection, and source-owned
observation outputs. Legacy lanes remain disabled for the integrated APIs.

Upstream added config bits that collided with the experiment's bits. Feature
state now occupies unused bits in the existing reactive flags, preserved across
scheduler resets. Ordinary nodes gain no new property. Loading's config bit was
moved to avoid the new frame/error flags.

The stage-109 reveal bug was already fixed upstream by #4217, fixing #4071.
That repair is now incorporated: a landing can defer its callbacks until
replayed frame readers have had a chance to discover their new holds. The six
source reveal tests and the JSX reproduction pass. This is not evidence that
all reveal/Loading combinations are complete.

Follow-up integration repairs:

- `unhold` unlinks the node from the intrusive owner list before clearing its
  owner. Reassigning an otherwise still-linked node could create a list cycle.
- Initial type-zero effect calls route held callbacks through their actual
  effect type instead of a nonexistent queue.
- Fresh/re-armed Loading passes isolate tentative dependency discovery from the
  unrelated flush that triggered them. An output only becomes a committed-frame
  reader after its content has initialized.
- The new upstream `frameRead` owns joining; its uninitialized-input branch must
  also join. Keeping both the old wrapper join and the new internal join was
  redundant; removing both lost mount holds.
- Resolve waiters check their accepted ownership when delivering on a microtask.
  Registering a foreign hold from inside the calculation re-added the waiter to
  the coordinator's live preparation walk without end. A generation check drops
  delivery from a superseded pass.
- Comparator errors cannot commit a previous result from a different update
  context. `latest` recognizes upstream's staged-error representation and
  preserves signed-zero distinctions allowed by its source.

## Error proposals and pending recovery

Upstream's staged-error forwarding was installed by the disabled verdict engine.
The shared engine now installs the forwarding hook with observation outputs.
Plain imports retain ordinary error propagation at publication, without importing
this additional forwarding code.

An ordinary derivation carries an error proposal without rerunning its body or
replacing its owned children. A selector chooses its own output, and higher
layers retain their input-selection rules. A new pending request replaces the
old error proposal. A published error is current input rather than a lower
proposal; it follows normal error propagation. This also avoids delivering the
same accepted error twice when its source commits.

A rejected trial reran all subscribers like value notifications. That repeated
user code and disturbed error handling; it is not retained. The retained path
passes the upstream chain/diamond error tests, staged-error supersession,
async-memo forwarding, and the experiment's existing layered tests.

`isPending` also distinguishes the shown error from the last successful value.
For example, if the screen shows an error and a held recovery produces the old
successful value `1`, pending stays true until that recovery replaces the error.
Equality with an obsolete successful value cannot finish the question.

`layered-staged-errors.test.ts` adds zero-, one-, and three-depth cases. Active
overrides shield their lower error; release publishes the error once; the error
boundary's displayed children clean up at publication; a later input recovers.
These tests do not claim that a memo declared outside the error boundary must
dispose its own children simply because its status was marked errored.

## Validation and remaining work

The final complete source run is recorded in
`results/integration-stage110/signals-complete.json`. Both the optional-hook
relocation and the published-error routing simplification preserve every test
result from `signals-retained.json`; the focused error matrix has 773 cases.

| Package | Passed results | Failed results | Skips |
| --- | ---: | ---: | ---: |
| signals | 5,042 | 2,161 | 2 |
| solid | 902 | 24 | 0 |
| web | 1,570 | 144 | 1 |

Passed results include upstream expected-failure tests; the counts are not all
successful correctness assertions. No existing assertions were weakened and no
new expected-failure markers were added. Failure inventories classify only the
first observed failure, not assertions that were never reached:

| Package | Explicit optimistic-store deferral | Explicit until deferral | Requires audit |
| --- | ---: | ---: | ---: |
| signals | 1,831 | 57 | 273 |
| solid | 23 | 0 | 1 |
| web | 115 | 0 | 29 |

Some audit cases use `until` indirectly; others assert upstream's inherited
observation posture or exact intermediate callback counts. They have not all
been accepted as intentional changes. Concrete remaining failures include
initial pending guards, latest/error behavior under a pending structural change,
first-answer supersession, and deferred refresh behavior. The one remaining
non-store Solid failure concerns deferred hydration's intermediate callbacks.
Store-dependent cases remain deferred, not validated.

All signals tiers build; production and observe property mangling and pure
checks pass. Signals, Solid, and web declaration builds pass. The normal web
suite uses the published rc.21 native compiler via `SOLID_COMPILER_NATIVE`.
The duplicate web `setupFiles` property from the rebase was merged so both
Jest DOM and upstream frame setup run.

The initial pending-guard trial suppressed promotion of an initial false
observation. It passed the focused source matrix without fixing either failing
JSX guard case. It was removed; the mount issue is not reported as fixed.

## Bundle size against current next

The repository's unchanged size harness measures both builds using the same
scenario definitions. Results are in `size-next.json` and `size-final.json`.

| Scenario | Next minified / Brotli | Experiment minified / Brotli | Brotli delta | Cap |
| --- | ---: | ---: | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,153 / 7,904 | +483 | 7,430 |
| + ordinary store | 43,868 / 15,089 | 45,222 / 15,513 | +424 | 15,100 |
| + isPending/latest | 33,088 / 12,061 | 34,014 / 12,231 | +170 | 12,070 |

All three fail their existing caps. The until/refresh scenario also fails,
but its size is not a feature-parity comparison because until is deferred.
No thresholds were changed. Moving staged-error forwarding behind the existing
optional hook saved 200 minified / 73 Brotli bytes from ordinary core. The
remaining ordinary-core growth still needs attribution and reduction.

No fresh runtime performance claim is made. Current-next measurements must be
re-established using the repository's built-package benchmarks after the next
correctness checkpoint. Initial bundle-size measurements already fail the
unchanged caps; this is not a mergeable acceptance result.

Next priority remains scalar integration: classify the new upstream failures,
fix concrete observable inconsistencies, and review consequential differences
against the agreed layered semantics. Optimistic stores and `until` remain
explicitly deferred. A green focused matrix does not close this work.

## Reproduction commands

Use the normal package runners, not an isolated engine entry:

```sh
# packages/signals
node node_modules/rollup/dist/bin/rollup -c
node scripts/mangle-props.mjs dist/prod dist/observe
node scripts/check-pure.mjs dist/prod
node scripts/check-pure.mjs dist/observe
node node_modules/typescript/bin/tsc -p tsconfig.build.json --emitDeclarationOnly
node node_modules/vitest/vitest.mjs run --maxWorkers=4 --reporter=json --outputFile=signals.json

# scripts/size (after building both checkouts)
node size.mjs 'signals:' --json candidate.json
SIZE_PACKAGES_ROOT=/workspace/layered-next-f6b6737b node size.mjs 'signals:' --json next.json
```

Size commands intentionally return failure on the candidate's unchanged caps.
The final normal-suite receipts use `signals-complete.json`,
`solid-complete.json`, and `web-complete.json` in this stage's results directory.
