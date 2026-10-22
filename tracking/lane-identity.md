# Lane identities, groups and routing

At Solid a2a5b6f8 (rc.16), `runtime/lanes-state.bend` now ports lane allocation,
group identity/mutation, ancestry and entry routing. `runtime/truth-state.bend`
ports the separate `truth.ts:laneValueOf` helper. Public verdict/optimistic APIs,
lane read/write/stage hooks, blockers, correction/reveal/dissolution and boundary
mounts remain unfinished. These helpers are connected dependencies, not a working
replacement for the full lane engine.

## Source operations

| Source | Bend | Preserved operations |
| --- | --- | --- |
| `lanes` | `World.laneState.live` | Stable live-lane identity list, independent of ordinary `World.transactions`. |
| `newLane` | `newLane` | Actual newTransaction(true,parent), then append to live lanes; ordinary transactions are untouched. |
| `verdictLane` | `verdictLane` | Read raw parent's cache; return it unchanged or allocate and assign once. No redirect resolution is inserted. |
| `sameLane` (scheduler) | `sameLane` | Raw transaction identity or identical nonnull group identity; content equality is not used. |
| `under` | `underLoop` | Begin at parent, walk raw parents while lanes, stop at first non-lane; no redirect resolution. |
| `linkLanes` | `linkLanes / groupLoop` | Initialize a's group before reading b's group. Shared identity returns early. Null b group appends b before pointing it at a's group. Distinct groups append and repoint each b member in order. |
| `unlink` | `unlink` | Mutate the shared array by removing the first matching member, then clear this lane's pointer. Peers retain their original array identity, even when it becomes empty. |
| `enterLane` | `enterLane` | Set LANE_READ first, capture passLane, then handle first/same/ancestor/descendant/unrelated cases. Joined plus staged first entry records the reader after installing the pass lane. |
| `stagedRead` (core) | `read-state.stagedRead` | One shared body retains uninitialized guard, pass flag, then staged-reader append when passLane is nonnull. Both existing core reads and lane entry call it. |
| `laneDirty` (scheduler) | `dirtyLoop` | Walk actual subscriber links; select same-group lane members or effects outside lanes, and set the flag without enqueuing. |
| `display` | `display` | Read the raw transaction's shown bit and lane slot; otherwise committed value. |
| `laneValueOf` (truth) | `truth-state.laneValueOf` | Non-guess staging wins; otherwise lane slot, else committed. Present undefined/false/null/zero/NaN differ from absent. |

The source's shared mutable group arrays are stable handles into
`LaneState.groups`, with reserved null handle zero. Retired group arrays remain
in the arena, like other persistent representation records. Merging repoints all
members but does not erase an old array; unlink updates the one shared array.
`stagedReaders` is a separate source vector inside the same aggregate. The
aggregate groups module globals/representation storage; it makes no lane verdict
or scheduling decision. Walks carry explicit fuel and surface exhaustion, with
structurally valid finite parent/group/subscriber structures as the profile.

The package reference starts at the real full index, which installs the lane
seam hook. The shared stagedRead body follows that package profile; a mainline
pass with null passLane skips collection. No public API admits an active lane
before its remaining read/seam/owner return points are ported. There is no second
staged-read algorithm or a synthetic pending boolean.

## Verification and limits

1,367 private helper-program comparisons invoke the actual pinned TS functions.
They cover all ordered ancestry pairs in the fixture, self/group links, merging
pre-existing groups, repeated unlink/relink and retained aliases, cached verdict
allocation, first/same/nested/unrelated pass routing, staged-reader intake and
lane-dirty flags. Checks include every allocated transaction, live/mainline
membership, original group identity/order and retired arrays, node flags/status/
extension identities, answers, pass lane and staged-reader vector. Private
observation/reset exports are added in memory; no source helper body is replaced.
392 separate native controls cover display and latest lane value with four
configuration masks, shown/unshown and seven slot states (absent, present
undefined/zero/false/null/eleven/NaN). These are synthetic helper controls, not
public histories or a native Promise timing result.

Five quantified properties in `proof/lane-laws.bend`, rooted in LAWS/PROOF,
check with the unchanged independent kernel:

- Fresh lane allocation appends the exact transaction/live membership while
  preserving the complete ordinary/mainline World.
- A cached nonnull verdict identity returns without allocating or changing World.
- Two distinct transactions sharing one nonnull group are one lane regardless
  of other transaction fields or group contents.
- A non-guess derivation's staging is its latest value.
- A guess's lane slot takes precedence over any staging below it.

The cache/group/value properties use designated existing arena slots and
quantify surrounding World/record fields, tails and payloads. They do not prove
general lane-group construction invariants, reveal/dissolution correctness or
TS/Bend equivalence. Nine added compiled mutations target selected allocation,
cache, identity, guess-value, repoint/unlink, staged intake and dirty operations;
four fail quantified proof assertions and five fail native helper assertions.
The complete 240-variant mutation sweep, existing histories and previous proofs
are rechecked. Public history/closed-regression totals stay 3114 / 72. The pin
and empty semantic deviation register are unchanged.
