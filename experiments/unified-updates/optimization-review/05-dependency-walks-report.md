# Dependency walks and committed journal review

Source inspection at review baseline `03628b9084c9da3ba28e0342f46f25898bad8118`;
operation-count model only. No runtime edits, builds, throughput tests or new size
measurements. Recommendation: trial journal partitioning first; keep traversal
semantics and targeted rerun-holder indexing.

## Current mechanism and evidence

- `packages/signals/src/layers/committed-dependencies.ts:15–45` keeps a reusable
  global insertion journal and cold retained-frame WeakMap. Each membership test
  scans the journal; no metadata is added to ordinary links/nodes.
- `committed-dependencies.ts:51–86`: a first initialized park with own insertions
  snapshots old dependencies, then removes own journal entries. Later proposals
  keep that snapshot until publication. With no own insertions, dependencies
  already preserve the committed frame; with no global insertions, scans vanish.
- `committed-dependencies.ts:91–132`: committed iteration excludes inserted links;
  layerPosition walks that frame, reads through inactive boundaries, and respects
  active frozen depths. Its recursion path prevents cycles but permits DAG reuse.
- `packages/signals/src/layers/coordination.ts:108–139`: observed walks subscriber
  demand, checking current generations and, when necessary, committed reads.
  Active override input subscriptions are cuts. This proves visibility, not depth.
- `coordination.ts:275–294,339–407`: committedUsesUpdate searches old dependencies
  for a specific holder before restoring waiting readers. prepareLayers already
  restricts its work to rerunHolders and can revisit after replay/merge.
- `coordination.ts:727–746`: currentPosition walks this attempt's dependency
  generation, with a traversal-wide seen set; evaluationPosition also accounts
  for untracked reads (`:815`). It cannot reuse committed-position answers.
- `coordination.ts:456–470`: unpublishedFrame walks ownership, stopping at parked
  zombie children. It identifies private creator frames rather than graph depth.
- `coordination.ts:1028–1059`: lifetime checks inspect actual pending sources and
  their contexts; canPublish separately scans higher rerun holders for private
  owner attachments. Combining these judgments risks self-sustaining optimism.
- Existing stage-182 attribution, parsed from `results/integration-stage182/size-scalar.json`:
  committed journal/depth contributes 990 minified bytes in optimism and 1,009
  in observed optimism; coordinator contributes 8,962 / 9,390. Neither ships in
  the ordinary-core scenario. These are attribution, not projected savings.
  The receipt's next baseline is `4fe75321`, not current upstream `bcef1041`.

## Concrete repeated work

Let D be this node's linked dependencies, I its inserted links, and J all journal
entries across nodes. First snapshot parking does an own-entry detection scan,
D global membership scans, and a removal scan: O(J + D*J), with early matches.
Example: one initialized memo keeps 127 old links and adds one; 256 unrelated
links remain journaled during a nested/in-progress pass. Its 127 old links each
miss across all 257 entries. The graph hook is called synchronously from parking
(`core/scheduler.ts:771,1195`); concurrent journal entries need not have parked.
This is a legal extracted hook state, not a measured application occurrence.

The owned scratch `journal-model.py` models exact ordered snapshot filtering,
removal, retained/uninitialized cases and reference clearing. Its deterministic
2,012 controls pass with interleaved journals and reordered graph links. This
validates extracted algorithms, not scheduler reachability or runtime correctness.

| D / J / I | Current owner checks / membership probes | Partition | Partition + Set |
| --- | ---: | ---: | ---: |
| 128 / 1 / 1 | 2 / 128 | 1 / 128 | 1 / 128 |
| 128 / 257 / 1 | 514 / 32,896 | 257 / 128 | 257 / 128 |
| 256 / 128 / 128 | 129 / 24,640 | 128 / 24,640 | 128 / 256 |

Set.has calls and reference comparisons are different operations; Set creation,
hashing, swaps, tail clearing and allocation are not included in those counts.

## Two bounded candidates

1. **Partition existing journal storage at park.** Scan once, swapping this
   subscriber's entries into a suffix; keep suffix references until snapshot
   filtering finishes, then null them and shorten count. Filter D links against
   only I suffix entries. Replace the park detection scan and forgetInserted
   invocation; commit/clear may retain their existing removal helper. Complexity
   becomes O(J + D*I), with no new allocation besides the existing snapshot array.
   Retained/uninitialized/no-own-insertion nodes skip snapshot work. Preserve the
   count==0 gate. This reduces unrelated-journal amplification but not I≈D
   quadratic work; reordered journal entries have no semantic ordering today.
   Extra swaps and range plumbing might cost code/operations for tiny journals.
   Falsifier: snapshot order, surviving membership, cleared tail or park return
   value changes; alternatively, realistic J stays near I and added code pays no
   useful cost. Check shipped bytes before claiming a size simplification.
2. **Temporary membership Set, only when actually creating a snapshot.** After
   the same partition detects I>0 on an initialized, previously unsaved node,
   build a work Set from the suffix and filter via Set.has. Drop it immediately.
   Expected O(J+I+D) under normal hashing, O(I) temporary storage; this is not a
   persistent cache or settled-read map. It replaces the suffix's nested scan,
   adds allocation/hash/GC work on branch-changing first parks, and adds nothing
   to ordinary read/insert paths. It may simplify loop source yet increase shipped
   bytes; no byte conclusion without the production pipeline. Falsifier: large-I
   parks are uncommon, cold allocation outweighs comparisons, or bytes increase
   enough to reject it. Prefer partition unless a broad-I workload justifies Set.

## Invariants and smallest runtime experiment

Committed and proposed dependencies cannot collapse: a held branch can drop A
and insert B while A still supplies its displayed value; equal values still
replace subscriptions only at publication. Error publication snapshots only the
validated prefix; trailing recovery subscriptions must remain excluded
(`committed-dependencies.ts:77–80`). Private children belong to unpublished owners;
parked children still serve the visible frame and may publish while removal waits.
Deleting those distinctions would corrupt observedness, context, errors or cleanup.

Do not replace layerPosition's path set with global visited: if a shared source
with depth 2 is first visited directly, a later unfrozen active boundary's
`1 + layerPosition(shared)` must still contribute 3, not 1. Unequal paths and
inactive wrappers need explicit controls before changing any depth algorithm.

Preserve rerunHolders (`core/scheduler.ts:437,586–591,1748–1772`). SIZE-96 rejected
scanning all live updates: repeated create/dispose before flush grew quadratically.
Partitioning does not alter this registry or its disposal/merge maintenance.

Next authorized runtime trial should change only park filtering and add scoped
operation counters in a disposable copy. Vary foreign J at fixed D/I and I at
fixed D/J; exercise interleaved parent/child passes, repeat parks, commit, clear,
and same-source duplicate links. Assert ordered frames and zero retained journal
references after cleanup. Run `unified-committed-dependencies.test.ts`, then
`unified-context-retry-error`, `unified-owned-render-context`,
`unified-retained-publication`, `unified-pending-error-observation`, and
`unified-owner-context-retry` tests. Add one error-recovery-prefix control if the
existing error test does not leave recovery links behind. No timing inference
follows from the counters; full runtime correctness remains untested here.
