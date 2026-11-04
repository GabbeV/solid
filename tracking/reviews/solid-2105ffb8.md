# Fixed rc.21 rebase to 2105ffb8

Target: `2105ffb8ca2fced55f5fac0763177fc93f97c2c2`, from
`ecf301169c863579a431b9e7cbb3956c01f40072`: 98 commits, ending at the rc.21
release. The selected files are vendored verbatim. This pass freezes that target;
subsequent next commits require a separate impact review.

## Source operations

- Verdict reads retain `_askedIn` as absence, clock (including zero), or raw
  transaction identity. `holdStaging` compares the corresponding clock or resolved
  transaction only in its source branch. It can leave a verdict lane; entry-local
  verdict/lane booleans remain captured across that operation. `frameRead` now
  joins on refusal itself. Accepted lane reads run `laneServed` synchronously,
  retaining a live Set handle/cursor across nested settlement and cleanup.
- Fast signal and verdict staging netting require both strict equality and
  SameValue. Opposite signed zeros stay distinct; accepted NaN writes remain
  proposals. This integrates the upstream #4538 fix rather than preserving the
  earlier pin's reported bug.
- Recompute captures superseded staging and RELEASE_AFTER before clearing flags.
  Its final config renews verdict, own-probe and ahead metadata from the actual
  flags. Outgoing source retirement tests current membership and pending/retry
  reachability. `keepReaders` retains qualifying dependent readers, removes queued
  heap work and stages the source-prescribed release at the pass tail.
- Publication captures whether staging was absent before calling a comparator.
  That local controls first-answer forcing and effect marking; later source
  pending reads remain live. The initial effect factory owns first-run queueing;
  recompute no longer additionally queues a creating lane effect. Deferred first
  effects apply staging using the shared assignment/reset segment.
- Tracked effects retain a stable owed/landing closure per node. Held changed
  dependencies enqueue that closure once; a landing clears the debt only when
  its real run passes the live gates. Ordinary changed dependencies retain the
  notified-epoch/computed guard and source traversal order.
- The dependent walker runs its body before marking/descending and reads the
  live subscriber head after the body. Nested settlement owns fresh local lists
  and restores its caller's lists on return. `stageMark` scans actual dependencies
  before forwarding staged errors. Clearing dependencies clears the tail before
  trimming. Release of queued unobserved work sets RELEASE_AFTER.
- AHEAD render readers bypass ordinary blocking, while lane groups still block.
  Lane dirtiness inserts subscribers before its held-source reseating tests;
  pending-source reask uses source absent-versus-allocated-empty semantics.
  Lane seams detach the ahead list before processing it and remove the first
  matching rerun. Notify's LEFT_SHOWN marker is now the distinct -2 stamp.
- `setPendingError` selects the supplied/current matching identity, obtains the
  extension before allocating a replacement, then writes even a retained error.
  Queue routing uses raw lane groups; ordinary transaction ownership does not
  redirect effect queues. Context reads without an owner use the default or the
  missing-context error in production. Retained map rows skip writes only when
  their committed value is strictly equal and no proposal exists.

The new leaf modules name shared source segments, rather than introducing an
alternate scheduler. `attachWaits` translates the structural owner/dependency and
recursive typed-array paths. Admitted Reference atoms have no DOM nodeType:
actual DOM, hidden mounted boundaries, snapshots and store/folded families remain
outside the grammar. Store-only omitted-source stagedScreen calls are not silently
made into successful non-store reads.

## Proof contract migration

Contracts are updated to source behavior; the runtime is not simplified to retain
an old proof normal form. The general frame-read refusal law now describes the
actual join, with the raw helper's existing fault branch explicit. The held
render corollary still derives no extra group charge. There is no new healthy
input premise to hide the raw fault case.

The unrestricted eligible-render law states the new AHEAD exception on its old
domain. The positive blocker/snapshot/landing corollaries require that the source
posture actually waits: either no AHEAD bit or a lane owner. Snapshot ownership
transport retains the lane field, and actual listing derives the new posture
from the input config and transaction record, which list does not modify. These
are necessary source-policy conditions, not arbitrary proof convenience.
Subscriber validity is now explicitly owner-relative for the same reason.

Pending-machine contracts describe the actual pre-stage cut and the direct,
leaf and nested return alternatives. Nested calls temporarily use a fresh release
list; the outer list survives in RestoreSettlement, rather than being falsely
claimed as the current local list. Moving descent after the body adds one actual
administrative step to affected return certificates: sufficient one-edge bounds
15 (trimmed 17), with exact simple returns still measured separately. These are
runtime bounds, not checker fuel. Status/committed/topology preservation includes
the real stage scan even when that scan exhausts its resource bound.

The source-followable settlement extraction audit keeps its historical specimen
and adds a separately reviewed rc.21 specimen. Generated execution data remain
untrusted candidates until their symbolic transitions pass the independent
checker. Frontend diagnostics, finite controls and independent verdicts are
reported separately in the migration receipt.

## Scope

No semantic workaround is active. This remains an incremental production
non-store translation; formal TS/Bend equivalence, arbitrary JS callbacks,
mutable object protocols, arbitrary topology/async event histories and a general
held-publication theorem are not claimed. The checker profile, fuel and 4GiB
process-group RSS limit remain unchanged. No resource-stopped proof is credited.

### Boundary-only private fixture correction

The old transaction random fixture could mark a leaf memo CONFIG_REDERIVE, the
boundary-output marker. rc.21 `hiddenBy` now follows such an output's subscribers;
a leaf reaches no shown render, so it is hidden even without a concrete boundary
object. This is an excluded boundary visibility crossing, not an upstream bug or
a port fix. That non-boundary fixture now varies CONFIG_FRAME instead. No native
hook is disabled and no vendored source is edited. The raw Bend blocking laws
remain laws of the scoped runtime; they do not prove mounted-boundary visibility.

### Empty seam intake

The pre-existing Bend empty-lane shortcut must now require an empty ahead list,
otherwise it would skip the new source prefix. Six paired source/Core controls
exercise that intake with repeated readers and frame-read flags. The complete
empty-hook certificate therefore includes ahead emptiness; constructed empty
lane states derive it from their actual record. The general null-parent seam law
still admits a nonempty ahead list and describes its flag cleanup explicitly.
This repairs a migration omission, not an upstream bug or a semantic workaround.

The signed-zero public suite also replaces an invalid `render` harness command
with the actual `effect` command and adds direct assertions of the proposed sign
on the observed derived value. Earlier equal harness errors did not exercise an
observed render; they are not credited as that regression coverage.

The pending-release root now states the source's queued-release split explicitly:
an eligible queued node receives RELEASE_AFTER and keeps its captured continuation;
an eligible unqueued node schedules owner cleanup. The prior immediate-owner
statement is not retained for queued nodes. Its arbitrary input domain is unchanged.

### Matching-over early return

The new 72 raw frameRead controls exposed an extra join in the port. Source
frameRead returns false immediately when the lane's resolved over matches the
source owner and the reader is not a verdict. It bypasses joinPass entirely
(source #4643). The port now preserves that early return; the controls compare
reader flags and pass/flush/lane identities as well as the Boolean result. A
separate mutation reintroduces the erroneous join. This is a translation repair,
not an upstream bug or workaround; store creation of over remains excluded.

### Source-only store regression

The optional-source stagedScreen question is now reduced against unchanged
Solid: latest of an async memo followed by an untracked read of a staged store
can pass undefined into holdStaging. It regressed at #4625 and still reproduces
on current next in all three browser tiers; the direct parent and paired
controls pass. See [the report record](../upstream/store-staged-screen.md).
This excluded store path needs no Bend workaround; baseline source is unchanged.
