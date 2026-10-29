# Source review: next@178605cf, 2026-10-29

The baseline ac28157aba6d03b806f0043bce70a87d515e953e advances to
178605cfcbfaf4243d157600095a63111047b164, still 2.0.0-rc.19.
All 78 selected Solid inputs are exact Git bytes; 26 changed, including the new
core/copies.ts. The saved impact report retains the previous source inventory;
it is not regenerated against the new baseline to erase the review obligation.
There were 32 nonmerge commits and 20 changed signals source files. No semantic
workaround is active. Frontend, Lean-checked checker, profile and fuel are unchanged.

## Changes in the admitted production non-store runtime

- #4336 introduces borrowed optimistic guesses. `take` appends the exact ordered
  tuple (node, old lane Slot, raw old owner, question, borrowing lane), marks its
  current subscribers stale, then clears guess/config or lists the new owner.
  A source stage compares the two resolved action parents, not raw lane IDs.
  `endLanes` first scans the captured reverse prefix of the live tuple stack.
  It removes an eligible tuple before callbacks, checks the original borrowing
  lane's raw reverted identity and old guess lane's live identity, and commits
  the current pending node before restoring its saved guess/question/config/
  owner and subscriber reruns. The existing nested-lane reverse teardown follows.
  A later owner keeps the node. The store slot-replacement arm remains refused.
- Scheduler `guessing` and lanes `guessed` are distinct persistent flags. They
  arm after a successful pending-guess append, before scheduling; an equal
  unguessed write does not arm them. They are never inferred from an empty/live
  guess array. Production `reverting` now records a dissolved raw lane after
  teardown and before screen/config stores. Its reset is a return continuation
  after `supersede`, not a new finally around comparator/cleanup exceptions.
- A pending written guess asking a new question outside a lane joins its old
  hold's parent; a `refresh` REASK opens its own hold. The former performs the
  real `txOf` cache resolution/store first. Recompute's reask exception also
  includes a held pending value when guessing is armed. First lane entry now
  collects a STAGED_READ reader when guessed or JOINED.
- #4338 records FRAME_READ/SCREEN_READ and the lane's rerun before throwing for
  an unshown never-valued pending lane; reveal can therefore wake the leaf.
  #4349 skips an ordinary transaction-held leak reader that read neither staging
  nor an unanswered probe. Lane verdict-parent gating remains separate.
- #4340 gives an unread pending nested mount a zero joined mask. #4341 walks
  currently computing creator ancestors (including Root.parentComputed forwarding),
  propagates their JOINED/STAGED_READ bits, and marks VERDICT only if there are
  no born bits. The port uses an explicit structural walk budget and faults on
  exhaustion; it does not quietly claim a successful cyclic walk.
- #4366 dispatches a verdict read before `prepareComputed`; verdict captures its
  reader posture, disables the window, wakes lazy/dormant memos, then links/pulls
  and restores the window. Plain reads retain their existing preparation order.
- #4367 leaving a shown lane sets LEFT_SHOWN outside a flush or when its resolved
  parent is unblocked. While that parent's frame remains blocked, it first saves
  the visible display into the committed value, then clears the old lane.
- The `affects` transaction-release hook carries marks whose own flight is still
  pending into ambient, preserving order and duplicates, clears the transaction
  scope, then releases the completed marks. Ambient release later drops them
  when the flight is down. This is distinct from making marks hold a transaction.

LaneState groups the five new globals for representation only: `guessing`,
`guessed`, `kept`, `reverted`, `reverting`. KeptGuess is a typed five-tuple and
its value is a Slot, so absent differs from a successful undefined. Reverted
models WeakSet membership by stable identity; GC/finalization observability is
outside the grammar. Existing fields and source branches were not conflated.

## Explicitly excluded changes and shared-hook review

The new copies module, extracted devRead diagnostics and owner/effect copy
enter/exit are development instrumentation, outside this production profile.
The public internal cross-copy exports do not imply a Bend implementation.
The immediate first render now calls runEffect with type=0, bypassing heldRunHook;
active boundary held-run interception remains excluded, so admitted runs do not
observe that distinction. No false-valued substitute was added for the hook.

Boundary pruning now retains staged errors, fallback folding no longer requires
an armed boundary, and fallback reads restore previous lane and selected output
flags. Loading-on-accessor warnings and the full boundary APIs remain unported.
The source tests cover these changes; their success is not Bend boundary coverage.

Store changes include new ask/park/stands hooks and family question stamps,
slotTake (including detaching other target slots and replacement on restoration),
first derived-store staging/verdict reads, chained proxy notifications, optimistic
row/arrangement identity, projection/reconcile and raw array cloning. These remain
outside the store-free grammar. The shared scalar slotTake hook is a no-op for
non-store nodes; restoration of an actual CONFIG_SLOT_NODE explicitly refuses
unsupported86 rather than using the old node. Map's new $TARGET/shallowView
optimization is after $TRACK and before length; ordinary typed arrays lack a
store target and retain the original list path.

The six changed selected docs and 25 new source test files were inventoried;
relevant non-store regression scenarios were reviewed as source contracts/examples.
Package/build metadata and constants did not change.
The standalone upstream worktree was installed normally with the frozen lockfile.
All three JS tiers, source declarations and the upstream signals suite pass
(380 files, 5,858 passes, two expected failures, two skips).

## Proof migration and validation boundary

The ordered field migration regenerates concrete witness data from the shared
runtime. Generator output itself is untrusted; every transition still needs the
independent checker. Existing programmes retain their graph/value domains.
The source-driven lane-end equation now starts the kept prefix when guessed,
then the live reverse scan. The pending-guess push equation includes both flag
stores. A proof-side notifier control alias includes the new guessing gate and
parent choice; the existing nonguess leaf theorem retains its original premises
and conclusion through a Boolean lemma, without weakening its domain.

Two preliminary whole-book attempts were stopped during excessive frontend
error rendering; neither receives credit. A diagnostic identified memoEnters: its
nonguess result remains true for both values of the new module flag, but the old
reflexivity proof needed explicit cases. That theorem retains its old domain and
conclusion; the runtime is unchanged by this proof repair. Focused lifecycle, guess and notifier
modules passed independently after the source-driven updates. The final complete
verdict and exact input seal, not this preliminary observation, authorize a
checked checkpoint. Native controls are execution evidence, not TS/Bend equivalence.
See the validation receipt for completed command identities and negative checks.
