# Solid rc.20 source migration, 2026-10-30

Candidate: `5e68925cc2fd216a9fb06345019e66d5da5c523c` (rc.20), from
`178605cfcbfaf4243d157600095a63111047b164` (rc.19). The source checkout is a
normal detached Git worktree. The selected vendored inputs are verbatim; the
impact snapshot was taken before updating the pin: ten source files and fifty
changed units, plus selected package/version metadata. No semantic deviation is
active. This review does not extend the production non-store callback grammar
into boundaries, mutable protocols, stores, hydration or observation hooks.

## Changed shared segments

- `core.ts`: shown errors, serving posture, staged/frame read origin cleanup,
  creator ancestry and verdict-effect staging. Recompute captures a replaced
  staged error before clearing it, bypasses equality on recovery, and maintains
  ASYNC/window and parked-flight state. Optional hook guards select installed
  engines in this profile; no engine-free build claim is made.
- `async.ts`: maintain the ASYNC classification of a flight with no verdict
  window of its own; holdWork gates pending propagation and verdict wakes.
  The source `&&` expression's false/undefined intermediates select the same
  represented pending-source identity; no data value is manufactured from it.
  Its shown-error null change inside a store `setValue` branch remains excluded.
- `effect.ts`: escalation reports and rethrows the raw cause. Boundary routing
  remains an excluded constructor domain; the admitted no-boundary halt path
  follows the changed source signature and payload.
- `lanes.ts`: heldBy's live membership and sole-origin renderer checks; serving
  drops already-served pending origins; staged-reader holder fallback; parking
  a frame flight and adopting it at rerun. Teardown precedes the adoption catch.
  A native-style no-handler `then` creates a fresh Promise identity, represented
  by a fresh AsyncObject and ordered mirror observer, followed by the existing
  registration path. A represented synchronous thenable facade has its existing
  undefined return. Arbitrary custom no-handler methods remain outside scope.
- Lane seams receive the captured parent, clear revealing at entry, inspect the
  current reverse lane list with the judged/current-verdict gate and delay a
  parent whose reveal has queued a re-derivation. Dissolution preserves first
  loads, including dependent loads retained earlier in member order; NOT_PENDING
  maps to absent Slot. Own errors re-derive from the new landing.
- `scheduler.ts`: callback-capable reruns through the same Core machine, including
  own/recovered inherited errors, mainline-only FRAME_READ clearing, child-run
  cancellation and parked adoption. First effect/own-error frame capture still
  controls held-run release. latestOpened is cleared with flushTransaction and
  passed through stagedScreen. openedByLatest is represented although the source
  has no production caller at this pin; no caller is invented.
- `truth.ts`: an uninitialized absent lane is NOT_PENDING. Shared record/constants
  changes preserve parked versus active flight and latest/reveal identities.

New Bend leaf modules name their source operations. Subscriber insertion is
shared in a leaf module so reenterHeld can invalidate subscribers before clearing
superseded staging without replacing the write algorithm or creating a cycle.
The previous pure reruns facade was removed; actual callbacks use Core tasks.

## Exclusions

The changed boundary arm/seam/catch/reset/prune/record operations remain open.
Development warnings and observation census are not admitted production effects.
Store/projection/family callers and custom mutable iterator/thenable protocols
remain excluded. Updating the inventory is source accounting, not completion of
those branches or formal TypeScript/Bend equivalence.

## Proof migration

The old zero-action/empty-node/no-live-lane theorem unconditionally returned
unblocked. rc.20 can delay such a parent during revelation. Its generic World
domain is retained: blocking now returns the exact revealing-membership flag.
The constructed completed-pair result transports that exact judgment. We do not
assume newly allocated IDs absent from arbitrary ambient revealing lists without
a global well-formedness construction proof. Settlement entry now explicitly
clears latestOpened instead of claiming the previous metadata is preserved.

The first combined-book attempt was killed without a verdict. An isolated
frontend diagnostic identified the obsolete settlement-entry equality; a stopped
attempt never receives proof credit. Final independent whole-book evidence is
recorded separately when completed.

## Validation status

The unchanged candidate upstream passed all three signals JS tiers, declarations,
and 393 files / 5,994 tests (seven expected failures and two skips). New focused
native/Bend private controls cover holdWork, computing ancestors, rerun error
postures and parked Promise adoption/refusal. They do not prove public reachability.
The frozen public/alignment/checker suites passed with all 916 captured inputs
unchanged. The combined 816-root candidate book passed independently after the
proof-only resource refactor below. Ten new targeted variants are rejected;
a fresh complete 764 sweep remains separate. See the [validation receipt](solid-5e68925c-validation.json).
The complete 754-variant sweep receipt in this checkpoint refers explicitly to
frozen `275c89e8` / rc.19, not this migrated runtime.


Rebase corrections identified by the paired checks: preserve NOT_PENDING as
absence during dissolution; retain the lane-seam revelation reset in the fused
empty hook; observe successful enclosing reads instead of an internal serve
that precedes a throw; and distinguish an absent extension from allocated null
shown-error metadata in test observations. These are port/fixture corrections,
not new upstream bug claims. The reset setter canonicalizes an already-empty
immutable list; source array identity is not an identity in the World encoding.


## Proof efficiency

The initial whole-book kernel check exhausted the unchanged 400M budget on the
existing deferred-stream step58. That attempt receives no proof credit. The
refactor checks the actual wrapping, registration, iterator creation and cleanup
attachment equations separately, then composes them using generic source-operation
transports. The root receives no new premise; the 118-step execution, ordinary
payload domain and runtime remain unchanged. The helper module passed in 2.49s,
the entire deferred-stream module in 30.67s, and the combined candidate book in
655.71s. This maintains existing fixed-program coverage; it is not a new arbitrary
async-history theorem. The official checkpoint seal additionally checks tracked
inputs and emitted output hashes.
