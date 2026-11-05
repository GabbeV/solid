# Stage 46: committed dependency frames; peer-gate port rejected

The production core now has a sparse record of committed dependency structure.
The attempted peer-group replacement is **not** retained: it failed observable
consistency tests. The main runtime still uses the preceding layer coordinator,
including its unresolved stage-38 discovery defect. This checkpoint is neither
a finished scalar implementation nor performance/size acceptance.

## Retained production change

An ordinary node keeps `_value` and `_pendingValue`. Its subscription list,
however, contains both the proposed pass and retained dependencies of the
committed pass. Reading that whole list as a committed graph is incorrect.

The graph only inserts new links or reuses old links in order until publication;
it does not move the old links. The optional `committed-dependencies.ts` module
therefore journals inserted links in a reusable buffer. On parking, it retains
the pre-proposal dependencies in a WeakMap. Subsequent proposals retain that
same snapshot until publication. Dropping a dependency needs no snapshot because
the graph already retains the old tail. There are no new signal, memo or link
fields and no journal lookup on a settled value read.

The module installs its structural hooks before application computations run.
Installing only when the first guess arrives would lose dependency changes in
an already-pending input. Ordinary-only application bundles remove the module.
Initial uninitialized nodes bypass insertion tracking. Initial synchronous
commit/disposal avoids WeakMap work when no journal exists.

For example:

```js
const value = createMemo(() => chooseB() ? b() : a());
createRenderEffect(value, show);
// Begin an action that proposes chooseB = true and remains open.
```

While the action holds, the committed dependency frame still contains `a`.
After publication it contains `b`. This also holds if `a()` and `b()` are equal:
the scalar remains unchanged, but the dependency frame still has a publication
obligation. Such an equal structural replacement is now listed with its ordinary
update when the optional coordinator tracks committed structure. The code does
not indiscriminately hold every equal computation.

A thrown error also carries a dependency-publication obligation. Recovery
subscriptions retained after the throw are distinguished from the reads that
produced the published error. These obligations use ordinary parking and commit;
they do not add a separate optimistic value/error slot.

The cold `layerPosition` query follows this committed structure. Inactive
boundaries are transparent. A recursion stack is per path, so a shared ancestor
does not truncate a longer path. This query is infrastructure for the replacement
coordinator; it does not replace the current coordinator's discovery rules yet.

## Rejected coordination attempt

The attempted port kept each optimistic proposal's ordinary transaction record
and linked equal-position peers through a shared publication gate. Ordinary
transactions and lifecycle coupling retained permanent `_into` merging. This
avoided reconstructing original identities after a destructive merge.

It initially passed the existing scalar suite and the new sibling gate test.
Porting the reference's parent-activation timeline exposed a tear:

```js
const [a, guessA] = createLayer(() => 0);
const [b, guessB] = createLayer(() => 0);
const [c, guessC] = createLayer(a);
const holdB = createMemo(() => delayed(b()));
const q = createMemo(() => delayed(c() + b()));
// Render b, c, holdB, and q independently.

guessB(2); // holdB remains pending
guessC(10); // q proposes 12, joining the two peers
guessA(1); // c's context changes relative to b
```

Simply separating the peers lets an old `q = 12` answer release `c = 10`
beside committed `b = 0`. Re-evaluating affected work corrected that specific
tear by calculating `q = 10` with committed `b = 0`. It also exposed a remaining
timing difference: this port released `a = 1` earlier than the reference. That
difference was not declared an approved semantic change.

The broader suite then failed 15 tests, including actual inconsistent
publications in nested and pending campaigns. One short pending trace was:
start `x = 0`, begin an action proposing `x = 2`, finish the action before its
pending-derived work finishes, then settle an older label calculation. Separate
bindings showed `x = 2`, pending false, and label `false:0`.

These are implementation failures, not assertions to relax. The failed code,
the unchanged failing assertions and several traces are retained under
`results/production-stage46/rejected-peer-gate/` and the adjacent `group-*.log`
files. The archived tree includes the corresponding pre-journal core/graph
files; use a disposable checkout if replaying it. The unsafe coordinator was
removed from the working runtime.

The lesson is narrower than rejecting shared publication gates: keeping origin
identities and changing their gate is insufficient. The coordinator must also
retain which pending updates a shared computation still owes work to, and must
revalidate a proposal before a changed context can release it. The reference
has those obligations in its per-node dirty-origin sets. The production attempt
omitted them while retaining the old coordinator's speculative read discovery.
That hybrid is not a valid implementation of the reference protocol.

## Performance and size

The first retained-dependency implementation allocated a snapshot at the first
new edge. With optimism present but inactive, branch switching measured about
1.26 times baseline. The journal refinement removed those synchronous snapshot
allocations. A subsequent creation regression prompted the initial-node and
empty-journal bypasses described above.

The final five-pair focused run, keeping optimism in both application bundles,
reported median paired candidate/baseline ratios:

| Synchronous workload | Ratio |
| --- | ---: |
| Branch switching | 0.988 |
| Memo creation/disposal | 1.031 |
| 20-memo chain | 0.999 |

The full three-pair ordinary-only run ranged from 0.838 to 1.015 across the 13
unchanged benchmark workloads. Both runs use fresh processes, alternating
runtime order, and the existing worker assertions. `measure-sync.mjs` adds an
optional `SYNC_KEEP_OPTIMISM=1` export retention mode; its default exports and
worker are unchanged. Raw results, worker/bundle hashes and machine metadata
are saved. These noisy small campaigns are not final acceptance.

Two retained-heap samples with optimism included but inactive measured signals
at approximately 315–345 bytes versus baseline 353, and materialized memos at
502–522 versus baseline 507–508. These are diagnostic samples after GC, not
precise allocation counts or a long-term leak proof.

The shipped scalar application scenarios currently measure:

| Imports | Baseline minified / Brotli | Candidate minified / Brotli |
| --- | ---: | ---: |
| Ordinary | 21,918 / 8,116 | 20,957 / 7,781 |
| Optimistic | 27,250 / 9,864 | 27,422 / 10,094 |
| Pending | 28,812 / 10,419 | 29,039 / 10,538 |
| Latest | 28,715 / 10,368 | 28,753 / 10,446 |

The feature bundles have exceeded baseline. No threshold was raised, and this
is not a size-passing implementation. Replacing and deleting the existing
coordinator remains necessary; retaining both mechanisms is not a mergeable
endpoint. The journal's linear scans also need adversarial wide structural
batch measurements: repeated per-node scans can be quadratic. No claim about
that workload is implied by the branch microbenchmark.

## Validation and remaining work

Nine new tests cover held dependency replacement, superseded branches, equal
values with and without owned cleanup, dependency dropping, reordered reads,
async supersession, inactive/nested context calculation, and errors/recovery.
They check visible output as well as the structural information needed by the
coordinator.

The retained implementation passes 5,452 tests across 321 files, with the
existing 22 expected failures and two skips unchanged. The layered subset has
279 passes and two existing expected failures. A focused legacy-disabled run
passes 18 tests; seven explicitly baseline-lane rows are excluded because that
run disables their implementation. The initial unfiltered invocation and its
seven baseline-only failures are retained for clarity. The source build type
check passes; the test-inclusive type check has exactly the same 26 normalized
diagnostics as stage 36. Build checks and `git diff --check` pass.

Representative commands from `packages/signals`:

```sh
node node_modules/vitest/vitest.mjs run
SIGNALS_SCALAR_ONLY=1 node node_modules/vitest/vitest.mjs run \
  tests/layered-committed-dependencies.test.ts \
  tests/layered-scalar-entry.test.ts tests/layered-action.test.ts \
  -t '^(?!.*baseline:)'
```

From the checkout root:

```sh
node experiments/layered-updates/build.mjs --scalar
SYNC_KEEP_OPTIMISM=1 SYNC_SAMPLES=5 \
SYNC_CASES=branch-switch,memo-create-dispose,chain \
node experiments/layered-updates/measure-sync.mjs /tmp/solid-inactive-cost
```

Next implementation step: replace speculative discovery and ancestry replay
as one coherent change with sparse pending-origin obligations, while reusing
ordinary value slots, async cancellation, owned frames, and commit queues.
Start with the failed parent-activation and observation-retirement traces;
require coherent observable publications before restoring the wider API surface.
The old stage-38 mount defect, full scalar acceptance, and stores remain open.
No new user ruling is needed to reject the inconsistent publications above.
