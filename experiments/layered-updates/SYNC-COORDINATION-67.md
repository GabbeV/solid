# Stage 67: reduce synchronous coordination cost

This is a measured real-core refinement against pinned next, not an isolated
prototype comparison. It is retained, with the later correctness adjustment
in [LATE-CONTEXT-68.md](LATE-CONTEXT-68.md).

The transparent-chain benchmark exposed substantially higher cost than the
all-overrides-active benchmark. The latter repeatedly writes only the top
boundary; the former writes the first boundary and propagates through the whole
chain. Both workloads matter and are reported separately.

## Retained changes

- Transactions have a conservative `_mayPend` latch. Enlisting a pending node,
  receiving a pending notification, or merging a possibly-pending transaction
  sets it. It is not cleared within a transaction's lifetime. An update that has
  never contained pending work skips readiness scans. No fields are added to
  signals or memos, and ordinary synchronous writes create no transaction.
- Stable layer position moved from a WeakMap to an optional field on the update
  record. Ordinary signal and memo records remain unchanged.
- A calculation already routed by `recomputeInUpdate` skips the second context
  routing call when it enters `recompute`. Unpublished owned effects still take
  their creator's context before this shortcut.

The first-pass insertion guard added to committed-dependencies.ts was redundant:
core graph insertion already checks UNINITIALIZED. It was removed. No performance
improvement is attributed to that attempted change. The inactive-creation
measurement remains a concern at roughly 4% over next in the final stage-67 run,
with substantial sample ranges; no claim of zero overhead is made.

## Measurements of this checkpoint

Artifacts: `results/sync-coordination-stage67/final-features/` and `final-sync/`.
Every baseline is unmodified tracked source at next
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Later measurements supersede these if
source changes; they are not claims about an unmeasured later build.

Seven alternating fresh-process pairs cover ordinary reads/writes, chains,
diamonds, fan-out, branching, and creation. Most paired ratios are below 1;
equal writes (1.006) and diamonds (1.017) are near parity. Signal creation is
0.843, memo writes 0.920, and memo creation/disposal 0.949. These are microbenchmarks,
not an application-wide speed claim.

All-overrides-active, top-only writes: candidate/next paired ratios are
2.52, 2.11, and 1.67 at depths 1, 4, and 16. Writing through a chain of transparent
boundaries remains worse: direct-accessor depth 16 is 22.4 microseconds against
next's 6.69 microseconds (medians of five runs). Callback inputs add a producer
node at each boundary and cost more. Active cost is not accepted as finished.

Brotli bundles: ordinary 7,961 bytes against next's 8,116; optimism 10,857 against
9,864. The ordinary bundle is smaller, but importing optimism adds a larger
feature cost than next. Thresholds have not been raised.

Sampled allocated bytes/write: ordinary about 510 vs 648; inactive optimism about
508 vs 633; one active boundary about 2,221 vs 1,389. These are V8 allocation
samples including collected objects, not exact allocation counts.

Boundary retained memory: callback input about 1,181 vs 555 bytes; direct accessor
about 808 vs 568. All five candidate and baseline production memory runs retained
zero disposed-reader tokens after collection. This is a finite retention check,
not a proof against every leak.

The full suite passed 5,522 tests (22 existing expected failures, two skips).
The scalar-only expanded campaign and final routing regressions also passed.
These results do not authorize store expansion or declare the scalar core complete.
