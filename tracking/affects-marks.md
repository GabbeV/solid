# Not-final marks: verdict dependency

Source: `src/affects-marks.ts` at Solid a2a5b6f8 (rc.16). The module now has a
restricted operation-following translation in `runtime/affects-marks.bend`.
Public `isPending`/`latest`, `affects` and `createDeferred` are not connected yet.
This is a dependency of their engines, not public API completion.

## Source operations

| Source | Bend | Correspondence |
| --- | --- | --- |
| `active` | `World.activeMarks` | A separate global count, initialized to zero; not the dirty heap's `World.marked` bit. Every mark/unmark updates this count at the source statement. |
| `mark` | `mark` | Call actual `ext`, increment the node extension's marks, then increment global active. No notification or transaction hold is added. |
| `unmark` | `unmark` | Decrement global active, decrement node count, return false if marks remain; otherwise run actual `repoll` and return true. |
| `marked` entry | `probe / ProbeNode` | A direct mark returns true before checking status or seen. An error or repeated node returns false; otherwise add the node to the shared seen set. |
| current dependencies | `ProbeDeps / ProbeNext` | During recompute, a null validated tail means no dependencies; a non-null tail stops the walk after that edge. Outside recompute the full list is current. Depth-first children share seen across siblings and short-circuit on success. |
| `repoll` | `repollWith / repollWork` | Visit actual subscriber links in order, skip seen nodes, add before enqueue, call actual heap enqueueSub for the selected reader mask, and descend only through non-effects. Next-link continuation retains the source return point. |
| `GlobalQueue._marked` | `covered` | Check the active counter before allocating/starting a fresh seen walk. |

Lists of stable node IDs represent the source Set identities. The explicit task
stack expresses recursive return points; it does not supply another scheduler.
`B.budget` bounds pointer walks, and exhaustion produces a fault. It is not a
successful false answer. Store-slot coverage explicitly refuses (86); derived
store family metadata/hops remain outside this constructor profile. Invalid
private unmark underflow refuses (87), rather than silently clamping source
negative counts with natural subtraction. Supported declarers must balance marks.

## Evidence and scope

`tests/marks-alignment.mjs` has 2,682 comparisons against the actual pinned
source helpers, with private observation/reset exports added only in memory.
Six graph shapes include chains, shared diamonds, cycles and isolated nodes.
The matrix covers direct/inherited marks, errors, recomputing empty/partial/full
prefixes, initial seen sets, active/inactive gating, reader masks, effect cutoffs,
heap refusal flags, marked-heap insertion, fresh extension allocation and nested
mark removal. It compares exact node counts/flags/heap pointers, bucket order,
min/max/marked globals, pending/scheduled state and returned answers. Synthetic
helper states are not public histories. No native function body is replaced.

Four quantified properties in `proof/mark-laws.bend`, also rooted in LAWS/PROOF,
check with the original independent kernel:

- Incrementing an existing node mark changes exactly the node/global counts.
- Removing a non-last mark decrements both counts without repolling or changing
  any other World field.
- A direct live mark short-circuits a probe, preserving the exact World, for any
  node fields, remaining arenas, seen/work vectors and sufficient first step.
- A zero global count makes covered return false without touching the World.

The first three use a designated existing node and extension at slot one; every
other field/record and the natural counts are quantified. This is not an
arbitrary-graph coverage, repoll-progress, or TS/Bend equivalence theorem.
Eight compiled mutations target counts, non-last result, error precedence,
validated prefixes, effect cutoff and depth-first enqueue order. Three are
rejected by quantified proof assertions and five by native helper assertions.
Existing public-history and composed-closed-regression counts do not increase.
The source pin and empty deviation register are unchanged.
