# Lane recomputation and propagation crossings

Solid 5b1b7776 (rc.17). The actual core driver now seats passes, preserves mount
posture, stages the result and routes publication/queues by the captured lane.
The source pin is unchanged and no semantic deviation is active. Public
optimistic/verdict construction/windows and the flush engine are still next.

## Source order

seatPass runs before noncreation teardown, as in recompute. It distinguishes a
lane's dirty/derived override from a written guess, inherits a creator's lane
except its verdict lane, and retains unset/false/lane mount identity. The body
argument and publication comparison both prefer pending then override lane slot
then committed value. They do not use guessedValueOf's different precedence.

The body finally restores tracking, inherited root and stale posture, captures
mount-aware joining (#4171/#4207), then config/flags/context, deferred releases
and reask. A nested pending derivation does not join merely because its mount
read a staging. Pre-body failures do not acquire an invented finally.

After dead-pass handling, the lane-stage call captures a separate publication
lane. A refusal sets that local to null while the ambient lane stays installed.
The call uses an explicit core continuation, preserving default constructor and
drain step budgets. Comparators can read another lane; the original publication
lane remains captured. isSame contains equality throws; guess outcome still
uses the raw lane comparator. Effects use source Object.is stale suppression and
explicit local-lane queueing, including first lane runs. Private effect values,
hidden lane slots and shown pending values keep their distinct stores. Subscriber
notifications precede laneDirty. Accepted guess outcomes skip ordinary stores
and height propagation. Tail staging avoids the mainline pending queue for lane
work, restores the caller lane, then handles missed wakes.

GlobalQueue._update retains tracked-effect and ordinary-zombie precedence. Its
nearest live-owner walk now cancels obsolete lane-frame work, excluding written
guesses and recognizing effect-owner raw lane membership. Finite traversal fuel
refuses malformed cycles; no alternate scheduler or cycle repair is used.

The graph/error controls exposed a previously untranslated crossing in
async.ts:propagateStatus. It now calls laneStage for active nonblocked propagation
with the propagating source object, preserving held/recomputing frame refusal.
Passing literal true or the underlying NotReady source would change that rule.
Only mainline work queues/joins held frames; pending root observers and repeated
pending-source joins also respect the active-lane guard. This fixes a port gap,
not an upstream failure or semantic workaround.

## Evidence and limits

5,354 actual-source entry/full-pass programs include 2,304 captured entry probes
and 3,050 complete recomputes. Source recompute itself executes; the head probes
compare its body-entry capture only, including synthetic branches whose later
postlude need not be valid. Complete programs use the appropriate memo/render/
user path. Tracked effects are tested through their dedicated heap runner, not
a fabricated direct recompute. The Bend pause at Evaluate injects exactly the
native fixture callback's flag changes, without changing either engine body.
Custom comparators return raw truthy/falsey data, read another lane, write, throw
or suspend. Graph cases check live subscriber routing, held/running frames and
the source-object distinction; a plain dependency read covers confirmation with
changed graph height. 1,728 further native nearest-owner/heap programs check
cancellation, deferral and tracked-run precedence.

Six quantified properties cover pending-slot precedence, non-effect and
unchanged run suppression, no-mount joined masking, exact captured-root restore
and accepted-outcome return. Existing complete scalar/history/chain claims and
budgets remain unchanged. Their canonical actual-runtime witnesses were
regenerated for LanePass/task fields and rechecked independently. The generic
effect-publication theorem now explicitly requires the source stale-suppression
and clean-error conditions; it describes the mainline leaf with captured null
lane. It was too broad for the newly active SCREEN_READ path without them.

An attempted direct-normalization proof refactor exhausted kernel resources;
smaller source call/return lemmas remain in use. The negative accepted-outcome
proof mutation also exceeded its resource cap and is tested with the concrete
confirmation/height control instead. Neither resource stop is counted as proof
or useful mutation rejection. The kernel and runtime semantics were not relaxed.

Twenty-one new mutations bring the cumulative count to 365 (311 finite, 54
proof assertions). Public-history and composed closed-regression counts remain
3,169 and 72: these new active-lane controls use explicit internal metadata.
No full lane progress, arbitrary graph/history, TS-equivalence or public
optimistic/verdict API theorem is claimed. freshHook/boundary, folded/store,
snapshot and general host protocol paths remain unfinished. Flush corrections,
guess application, lane seams/end and public windows are the next crossings.
