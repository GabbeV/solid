# Exact update membership — stage 104

The scalar core now represents current held membership with links on nodes’ cold extensions. It no longer allocates a separate membership array for every publication. There is no cache, pool, spare-capacity policy, or revived completed update.

This is retained locally as an isolated storage optimization. It reduces transient allocation substantially, with modest and uneven timing changes. It does not establish acceptance: active optimism remains materially slower and the feature bundles remain larger than unchanged next.

## Representation and correctness

Each node has one current holder. Previously, arrays could retain stale entries after a node moved to another holder; publication and readiness walks filtered them by checking ownership again. Two links now express the existing ownership directly. Moving a node unlinks it from the previous owner and appends it to the new one. Merging membership splices the two lists without copying entries. Callback queues and other merge work are unchanged, so the entire merge is not claimed to be constant-time.

Publication removes the head before committing it. Cleanup can then append, transfer, or merge work without invalidating an array cursor. Finished and merged-away records have empty membership. The transaction identity still finishes normally; observation and action references continue to distinguish that completed update from a later proposal.

The common scalar representation applies to ordinary and optimistic updates. Legacy lanes retain their existing representation. Normal signal/memo objects gain no fields. Every allocated cold extension gains two pointer fields; this includes extensions allocated for non-async ownership or other cold features, not only optimism. Settled reads do not traverse the ownership list.

This does not preserve a context across successive published proposals. Nodes still join each new update, but there is no separately allocated membership container to rebuild. Persistent contexts and their completion identities remain a separate design question; this result does not prove that fresh transaction records are fundamental.

The linked-list technique is generally applicable. This pass is kept in `membership-only.patch`, separate from the preceding model changes, and is not presented as an intrinsic advantage over an equally optimized next. Next’s optimistic lane already retains its array across proposals, so it does not have the repeated array-growth cost eliminated here. A full port of exact membership to next’s persistent lane walks has not been implemented or measured.

## Allocation

All measurements compare real minified, property-mangled production bundles with the same pinned unchanged next. Three rotated heap-sampling runs per case measure 5,000 operations after warmup and include collected objects. These are sampled estimates, not exact counters. Before/current columns both use next as their baseline.

| Workload | Next bytes/op | Before bytes/op | Current bytes/op | Before / next | Current / next |
|---|---:|---:|---:|---:|---:|
| 16-boundary repeated proposal | 1,427 | 2,750 | 1,549 | 1.927 | 1.086 |
| 128-boundary action cycle | 29,492 | 121,858 | 96,882 | 4.132 | 3.285 |

The membership allocation previously attributed to adoption disappears. The chain still performs 48 enlistments and 32 computations per proposal, and creates one transaction. Next performs 32 membership checks, the same 32 computations (its function is named `recompute`), and reuses its existing lane. This pass removes storage allocation, not all of that work. The candidate also still makes 17 merge calls in this workload, including same-context calls which return without merging. Those are a separate remaining-work target.

## Retained memory

An additional fixture mounts 5,000 boundary-and-render-reader pairs, measures them before use, while an action’s guesses are published, and after correction. Medians from three rotated process runs, bytes per pair:

| Phase | Next | Before | Current |
|---|---:|---:|---:|
| Mounted before guesses | 997.0 | 1,497.5 | 1,497.6 |
| Guesses published, action open | 1,448.9 | 2,119.5 | 2,151.3 |
| Action completed and corrected | 1,442.8 | 2,069.1 | 2,102.9 |

The approximately 32-byte increase after use corresponds to two participating cold extensions gaining two links each. Unused boundaries are unchanged: callback-input boundaries measure approximately 1,063 bytes versus next’s 556; direct-accessor boundaries approximately 1,049 versus 568. The paired-node creation cost is not solved by this pass. All three production WeakRef runs retain zero disposed-reader payloads.

## Timing

Seven rotated process triples per case, CPU 4, Node v24.19.0, AMD EPYC 9V74. Each entry is the median paired elapsed-time ratio to unchanged next = 1.000; lower is better. No comparison uses an unvalidated prototype as the baseline.

| Workload | Before / next | Current / next |
|---|---:|---:|
| chain-16 | 2.279 | 2.233 |
| sync-chain-16 | 1.512 | 1.535 |
| cycle-1 | 1.313 | 1.313 |
| cycle-128 | 1.876 | 1.896 |
| cycle-512 | 1.625 | 1.575 |
| owned-chain-16 | 2.860 | 2.826 |
| owned-cycle-128 | 2.261 | 2.137 |
| signal-read | 1.011 | 0.997 |
| write-flush | 1.028 | 0.981 |
| memo-write | 0.919 | 0.966 |
| diamond | 0.887 | 0.889 |
| signal-create | 0.509 | 0.673 |
| sync-owned-create-update-dispose | 1.110 | 0.967 |

A 13-triple signal-creation repeat reports before/next 0.749 and current/next 0.674. The first run’s much larger before/current difference did not reproduce. The current result remains about 33% faster than next. These ordinary creation paths have no membership operations; this is not a new algorithmic creation win from the pass.

The wholly synchronous owned-subtree control repeatedly creates a tree, updates it, and disposes it. It exercises cold extensions without async or optimism and checks publication and cleanup counts. Its process ranges are wide, as are several other small controls. Raw absolute timings and ranges are retained; small differences are not treated as proof of a general gain or regression. Neither the unchanged chain computation count nor the allocation reduction explains away the remaining >2× chain runtime.

## Bundle size

Brotli bytes for shipped import scenarios:

| Import scenario | Next | Before | Current |
|---|---:|---:|---:|
| ordinary | 8116 | 7987 | 8082 |
| optimistic | 9864 | 11931 | 12047 |
| pending | 10419 | 11714 | 11803 |
| latest | 10368 | 11564 | 11651 |
| refresh | 10117 | 8256 | 8326 |
| optimistic-refresh | 10208 | 12163 | 12258 |

The optimistic import adds 116 Brotli bytes over the preceding checkpoint; the ordinary import adds 95. This is a storage tradeoff, not a size win. Ordinary code remains slightly smaller than next, while optional feature code remains materially larger. No thresholds were changed.

## Validation and boundaries

472 selected scalar tests pass, with 34 baseline/legacy exclusions. The normal suite reports 5,699 passes including 22 expected-failure tests, with two skips. The compatibility corpus remains 618 passes and the same 36 classified failures. The 500-seed overlap run passes 30,000 operations; it now checks uniqueness, bidirectional links, and owner identity in addition to actual displayed values. The focused production suite passes 19 checks with two exclusions. Source and touched-test typechecks pass. Test process exits and unhandled errors were checked.

The retention test’s internal count now enumerates actual membership instead of reading array length; its boundedness assertions are unchanged. No consistency assertion was weakened, no new semantic exception was introduced, and no diagnostic or warning was added. Transfer order follows current ownership rather than retaining old stale positions; sibling callback order remains unspecified, as previously ruled. Existing parent/child cleanup and reentrant overlap cases pass. A finite campaign is not a universal proof.

The actual production comparison still demonstrates next’s repeated-guess tear (one reader sees 2 while the async pair remains 1/1), while the candidate holds both at 1. It also preserves independent sibling publication when only one sibling’s consequences suspend.

## Artifacts and reproduction

`results/owned-membership-stage104/` contains the standalone patch, source fingerprints, validation output, allocation/CPU profiles, memory checks, size results, and timing samples. `next/` is unchanged next; `entry/` is stage 102; `linked-initial/` is the first linked-list trial; `retained/` is the tested final implementation. Stage 103’s cache remains rejected and absent.

```sh
node experiments/unified-updates/build.mjs --scalar
TRACE_VARIANT=retained node experiments/unified-updates/results/owned-membership-stage104/build-traces.mjs
MEASURE_OUT=experiments/unified-updates/results/owned-membership-stage104/retained node experiments/unified-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
python experiments/unified-updates/results/owned-membership-stage104/validate.py
python experiments/unified-updates/results/owned-membership-stage104/check-allocation.py
python experiments/unified-updates/results/owned-membership-stage104/check-memory.py
python experiments/unified-updates/results/owned-membership-stage104/check-active-memory.py
PERF_CASES=chain:16,sync-chain:16,cycle:1,cycle:128,cycle:512,owned-chain:16,owned-cycle:128,signal-read,write-flush,memo-write,diamond,signal-create python experiments/unified-updates/results/owned-membership-stage104/run-performance.py
```

Run heavy checks serially. The additional pure ownership workload is `sync-owned.mjs`, used with the same comparison runner. The pinned next commit remains `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, with no tracked modifications.
