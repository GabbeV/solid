# Source review: next@ac28157a, 2026-10-28

The reviewed baseline0847122e advances to
ac28157aba6d03b806f0043bce70a87d515e953e (2.0.0-rc.19). All77 recorded Solid
inputs remain verbatim Git bytes;14 changed, including docs/version/store files.
The [structured impact](solid-ac28157a-impact.json) retains the old baseline
fingerprints. The Bend frontend, Lean-checked kernel/profile and400M fuel are
unchanged. No semantic workaround is active.

## Shared changes implemented

#4304/#4284 changes `laneRead` and the final `laneSeams` stage. A render verdict
seat exits before entering a different lane as well as before a never-valued
pending read. That pending read returns the fast token only when the lane has
shown. After the outside-display return branches, a verdict reader entering an
unjudged non-verdict lane appends to the new module-global `entered` array.
After judging the recorded reverse lane prefix, source pops this array in reverse
order and requeues each still-held reader, clearing `REACTIVE_LANE_DIRTY` first.

The port stores `entered` as a distinct final `LaneState` field. It does not reuse
`stagedReaders`, deduplicate the array or clear it before processing. The explicit
pop/store/held-check/flag-clear/enqueue order is retained. `enteredPrefix` is the
persistent-list encoding of array pop, not a different scheduling policy. Empty
drains take no extra machine task, retaining prior fixed step bounds; the existing
empty-hook optimization also requires this array to be empty.

#4330 removes the trailing `joinFuture(parent)` from shared `supersede`. Node
ownership/confirmation and pending-value stores retain their order. The parent
takes the node without merging the tick that delivered a truth for another action.
The source-backed lifecycle comparisons observe complete group and queue state.
Store row pairing remains excluded, as described below.

## Source-driven theorem changes

Three former contracts are replaced explicitly, not retained as unsupported
claims. Their initial World/task/stack/value domains remain visible.

- `never_shown_render_read_exits_existing_verdict_lane` previously promised a
  pending token for every empty lane-value slot, even an unshown lane. Upstream
  changed that behavior. Its replacement proves the exact outside-read dispatch
  from the cleared verdict seat on the original initial domain. Separate shown
  and unshown lemmas state the new token/display split.
- `lane_guess_zero_reveals_preserve_world` now continues into the actual entered
  drain; an empty recorded reveal prefix does not imply an empty entered stack.
  The replacement retains arbitrary entered state and names that continuation.
- `lane_confirmation_stages_before_join` becomes
  `lane_confirmation_stages_truth_without_joining_parent`: the actual helper
  now stages only. No parent-join guarantee is asserted for the new source.

The previous equations remain in Git at4f3bc519a. These changes follow source
semantics; proof convenience did not change the runtime or impose a new blanket
empty-stack premise. All other roots and admitted payload domains are retained.
Source-backed witnesses are regenerated with the new empty array field. Existing
19/40/51/53/56/84/95/103/118/120-step domains/bounds are not enlarged to hide a
failed transition. The independent whole-book verdict must revalidate them.

## Reviewed excluded changes

#4314 moves snapshot-scope serving ahead of ordinary pending/held reads, keeps
error throws, factors `takeSnapshot`, and accepts hydration's served answer in
`markSnapshotScope`. Active snapshot capture/scopes, mounted hydration boundaries
and their constructors remain explicitly unported. The admitted non-snapshot
profile takes none of those branches; no approximate snapshot behavior is added.
The new internal public `clock` export is hydration support; the existing World
clock stays the runtime clock, without claiming a new JS hydration facade.

#4307 changes family wake-up identity to the family derive and removes the error
argument from the optional `fam.st` call. Store families and their callbacks are
not constructible in the admitted grammar. #4310's owner stamp, #4330's store
pairing/guess reconciliation and changed store hooks remain excluded. Shared
`supersede`'s removal above is implemented even though the motivating report is
about stores. Other compiler/web/SSR commits do not change the selected runtime.

## Validation boundaries

Source-built upstream passes355 files/5,646 tests, with two expected failures and
two skips; all three JS builds and source declarations pass. Expanded private
read/seam controls observe the new array separately from leaked/staged readers,
including duplicates and held/drained states. Nine independently checked public
histories cover held writes, direct guesses and pending guess derivations across
combined/split/reversed reads. Existing native helper and public suites remain
separate from the fresh mathematical book and configured negative variants.
Exact scopes and completed verdicts belong in the companion validation receipt
and `tracking/checked.json`; older full713 evidence is not relabeled for this pin.
