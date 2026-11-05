# Stage 74: previous values stay within their calculation context

The user accepted the recommendation: preserve staged history inside a coordinated
update context, including entangled peers. When a calculation moves into another
context, use its committed previous result. Do not retain or replay abandoned
lower histories. This is an experimental semantic choice, not full support for
signals as events.

The implementation is in the real scalar core. The comparison baseline remains
unmodified next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`; its tracked worktree is
clean. All performance numbers below compare this candidate directly to that
baseline. They do not isolate a timing surcharge attributable to this policy.

## Storage and execution mechanism

One spare bit in the existing `_config` word marks a previous result as belonging
to a replaced context. There are **no new node fields, maps, history arrays,
closures, or retained versions** for this policy. It adds zero structural bytes
per signal, memo, or optimistic boundary. No node allocation path was changed.

- Recomputing a node with a staged value checks the bit before selecting `previous`.
  A successful comparator clears it; async acceptance clears it too. Commit folds
  clearing into its existing flag mask.
- Ordinary settled signal reads and the setter's hot path gain no new operations.
  Ordinary successful memo calculations do gain a flag-clear operation. There is
  no layer traversal or lookup added to their reads.
- Optional coordination marks transferred proposals and resets the argument on
  a retry that changes context. A merge across levels scans the higher update's
  existing node list. This is O(number of nodes in that update), with no new
  collection. Same-level peer merges do not reset history.
- A failed replacement discards the foreign staged value before its status can
  publish through a fallback. This matters for recovery: an error commit must
  not silently install the abandoned lower result as committed history.

An initially broader discard at every marked commit failed 23 existing scalar
assertions: coordination can also move a ready value without replacing it. That
attempt was rejected. The retained implementation discards on failed replacement
calculations, preserving those valid ready proposals. No publication assertion
was weakened.

## Observable checks

Final full suite: **5,580 passed, 22 existing expected failures, two existing
skips, 331 files**. The scalar-only define also passes the 39-test context suite
and all nine final previous-value tests. Source and focused test typechecks pass;
production build and diff whitespace checks pass. The production build retains
its pre-existing diagnostics, archived in the log.

The new tests exercise ordinary memos and optimistic input producers, a second
proposal after publication, landed-but-held versus canceled async answers, peer
history, and recovery from body/comparator errors and async rejection/comparator
errors. The production audit starts with base=0, preview=0, total=0; holds base=1;
then publishes preview=10. Both ordinary memo and input producer now publish
`base=0, preview=10, total=10`. Next publishes total=22 in that timeline. This is
the accepted prevention of foreign history entering the upper calculation.

Other production audits still match next exactly for published optimistic
accumulation, superseded async calculation versus async downstream placement,
and the identity/trend examples. Ordinary reduction and a separate optimistic
presentation also match. The mixed reducer intentionally differs: dropping the
lower draft history produces 10, then 22 and 24 as the lower update and override
release; next produces 25, 37, 39. See the phase-by-phase outputs in `audits/`.

Finite tests are regression evidence, not proof for every discovery and ownership
graph. The accepted contract does not promise delivery of every setter call,
undo already-published accumulation, or retain canceled reducer branches.

## Production timing against next

Node 24.19.0; fresh worker per runtime/workload/sample; alternating paired order;
eleven pairs for synchronous workloads, with optimism imported but inactive.
Ratios below are medians of paired candidate/next times; lower is faster. These
are microbenchmarks on a shared host, so small percentage differences are noisy.

| Synchronous workload | Candidate / next time |
| --- | ---: |
| signal-read | 0.985 |
| memo-read | 0.942 |
| write-flush | 0.909 |
| equal-write | 0.994 |
| memo-write | 0.960 |
| batch-10-writes | 0.973 |
| chain | 0.958 |
| diamond | 0.998 |
| fanout-memos | 1.013 |
| fanout-effects | 1.045 |
| branch-switch | 1.003 |
| signal-create | 0.813 |
| memo-create-dispose | 1.118 |

There is no broad synchronous regression in this run. Memo creation/disposal
(~12% slower) and effect fan-out (~5% slower) remain open performance gates.
Do not attribute these whole-prototype differences solely to the previous-value
policy, or claim the faster cases establish a universal speedup.

Three paired samples with every boundary actively overridden:

| Write to top layer | Candidate / next time |
| --- | ---: |
| depth-1-top | 2.123 |
| depth-4-top | 2.116 |
| depth-16-top | 1.677 |

The separate five-sample workload writes the first boundary and propagates through
otherwise inactive boundaries. Candidate/next ratios of median times are about
2.0–2.2 at depth 1, 2.9–3.1 at depth 4, and 4.0–4.2 at depth 16. Both direct
accessor and callback inputs are exercised. These publication workloads agree
with next; lifecycle differences are not used to excuse the throughput gap.

## Retained memory against next

Five fresh-process samples per runtime, forced collections. Ordinary measurements
keep 30,000 primitives and their public handles; memos each read one shared source.
The numbers include handles and container entries, not just private node objects.

| Retained object | Next bytes | Candidate bytes |
| --- | ---: | ---: |
| signalBytes | 352.8 | 344.8 |
| memoBytes | 432.9 | 424.8 |
| Optimistic boundary, callback input | 555.7 | 1154.9 |
| Optimistic boundary, direct accessor input | 567.9 | 1112.5 |

Boundary measurements retain 20,000 boundaries. The approximately doubled cost
belongs to the existing split input/output representation; this previous-value
rule adds no fields to either node. All five samples of both runtimes retained
zero of the 30 disposed-reader payloads while the source boundary remained alive.
That test does not establish leak freedom for every possible lifetime pattern.

## Import-bundle size against next

Real Rollup scalar build, then minified application bundles with production
property mangling and Brotli quality 11. These are matching import scenarios,
not a claim of full API parity with next.

| Imports | Next Brotli bytes | Candidate Brotli bytes |
| --- | ---: | ---: |
| ordinary | 8116 | 8005 |
| optimistic | 9864 | 11042 |
| pending | 10419 | 11533 |
| latest | 10368 | 11417 |
| refresh | 10117 | 8264 |
| optimistic-refresh | 10208 | 11239 |

Ordinary imports remain slightly smaller; optimism adds 1,178 Brotli bytes
(~12%) relative to next's matching import bundle. Active throughput, creation
cost, feature size, and deferred APIs keep the overall experiment unaccepted.
Stores remain paused. Keeping this cheap storage policy does not resolve those
gates or establish scalar completeness.

## Reproduction and artifacts

Runtime snapshot and SHA-256 manifest: `results/previous-stage74/final/`.
Raw distributions, bundle metadata, workers and audits:
`results/previous-stage74/{inactive-sync,features,audits}/`.

From the checkout root, build with:

```sh
node --input-type=module -e 'process.argv.push("--scalar"); await import("./experiments/layered-updates/build.mjs"); process.exit(0)'
MEASURE_OUT=experiments/layered-updates/results/previous-stage74/features node experiments/layered-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
SYNC_KEEP_OPTIMISM=1 SYNC_SAMPLES=11 node experiments/layered-updates/measure-sync.mjs experiments/layered-updates/results/previous-stage74/inactive-sync
node experiments/layered-updates/measure-active-contexts.mjs experiments/layered-updates/results/previous-stage74/features
node experiments/layered-updates/measure-optimistic.mjs experiments/layered-updates/results/previous-stage74/features
node experiments/layered-updates/measure-ordinary-memory.mjs experiments/layered-updates/results/previous-stage74/features
```

Run measurements sequentially, with no tests or builds running concurrently.
The added heap worker and driver are reproducible experiment tools, not shipped
runtime additions. Source checks, test logs and the production build log are
archived with the final checkpoint.
