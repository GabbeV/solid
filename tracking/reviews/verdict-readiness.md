# Verdict/lane readiness review

Reviewed against unchanged Solid `a2a5b6f8` (rc.16), following the mapArray and
children-flatten implementation checkpoints. This is a dependency review for the
next implementation work, not newly implemented behavior or proof coverage.

## Why this is the next connected engine

The translated mainline signal/memo/effect/owner/async/action machinery and list
helpers now execute within the typed production profile. `isPending`, `latest`,
`createOptimistic`, `createDeferred`, boundaries and reveal ordering remain major
public gaps. The first two are not small wrappers around the existing committed
read: source verdict.ts routes their readers into the holder's verdict lane.
Porting only the function entry/finally would leave the central read and seam
operations missing. Returning a synthetic pending boolean would substitute an
algorithm and is not an acceptable implementation.

## Reviewed source dependencies

| Source segment | Existing Bend pieces | Missing active work |
| --- | --- | --- |
| verdict.ts latest/isPending entry/finally | Context, tracking, original typed callback driver and exceptional return-point pattern | Scoped latestActive/probing/probeFound/verdict dispatch, markVerdictReader, nested restoration and source loading-versus-pending catch |
| verdictValue link/pull/read | Actual link/pull, committed/staged reads, NotReady and error propagation | Dispatch while window open; temporarily suspend verdict dispatch for a pulled memo; heldLatest, pendingVerdict, observeFlight and provisional verdict routing |
| route/verdictRead | passLane identity field, joinFuture, txOf, staleReader and transaction reruns | verdictLane allocation and lifecycle, REACTIVE_LANE_READ routing, probe rerun membership and stagedReaders seam intake |
| lanes.ts verdictLane/newLane/enterLane | Transaction has parent/lane/verdict/shown/held fields; mainline joins and queues execute | Active lane arena relationships, shared lane-link groups, lane node membership and activation; fields alone are not an engine |
| laneStage/laneRead/laneWrite/laneOutcome | Node extension has a lane payload slot; mainline setter/publication return points and custom callbacks execute | Source installed hook return points, override/guess/display selection, lane publication, corrections/supersession and own-flight judgment |
| laneSeam/dissolveLane/endLanes | Mainline park/land/blocker/rerun and owner continuations | Source verdict-lane reveal/hold decisions, staged-reader reruns, lane dissolution and exceptional owner callbacks at their live return points |
| affects-marks.ts mark/unmark/marked/repoll | Extension marks default, actual dependency/subscriber chains and enqueueSub | Active count, declared marks, current-prefix traversal, cycle/duplicate guards, error precedence and verdict/truth-reader repoll; store-family branches remain outside the non-store profile |
| deferred.ts ask/serve/land/lagOf | Actual ordinary async registration, loading values, pending sources, transaction landing and watcher truth gates | Lagging set, committed-value loading window, mark lifetime, held-input landing, quiet refresh and GlobalQueue lagging hook |
| Boundaries/reveal | Mainline ownership/cleanup and ordinary async settlement | Boundary mounting/reveal state, callbacks and lane-root inheritance; no public support is inferred from existing context fields |

World currently has no live verdict-window state or stagedReaders vector.
Transaction.verdict/lane fields and NodeExtension.marks/lane defaults express
storage only. Core.stagedRead explicitly lacks the stagedReaders hook, and
transaction.frameRead states its no-installed-verdict/lane/boundary restriction.
The source full-index native bundle installs these hooks, but the currently
admitted programs do not activate them. Activating a window invalidates that
inactive-path argument and requires its downstream return points to be ported.

## Source contracts to preserve first

- A held input's plain read remains the screen while latest(input) serves its
  proposal and isPending(input) reports whether that screen is final. These can
  coexist in one memo/effect in either read order.
- A plain synchronous write does not flash pending=true. Unheld staging may need
  a provisional seam answer; latest outside the flush does not simply return an
  unflushed proposal.
- A verdict reader with its own asynchronous work holds its verdict frame rather
  than forcing that result to wait on the parent's unrelated flight.
- Loading before a first answer is distinct from a pending update. isPending's
  catch rethrows an uninitialized NotReady inside an owner when no pending answer
  has been found, but ordinary errors return the probe's verdict.
- Nested windows, untrack and a memo pulled by a probe preserve source dispatch
  and tracking rules; window restoration must run on exceptions.
- Quiet refreshes and affects/deferred marks affect finality without changing
  the underlying value. Mark coverage stops through an ordinary error except for
  a direct mark, and mid-recompute traversal uses the validated dependency prefix.

The initial end-to-end targets should be the held-input spinner and
latest/plain/pending same-pass programs, followed by read-order symmetry,
unflushed writes, first loading, rejection, nested windows, quiet refresh,
verdict-frame asynchronous work, then deferred lagging behavior. Native fixtures
must retain the original source queues and lane hooks. Helper comparisons can
exercise isolated branches, but do not close these public engine crossings.

## Evidence boundary

Source inspection used the vendored pin. The existing separate upstream checkout
`/workspace/solid-falsy-fallback-pr` is based on the same pin; the verdict, lane,
mark, deferred and selected test files have no diff from it. Its fallback PR
changes are unrelated to this review and remain excluded from the translation
baseline. Selected native verdict/deferred tests are recorded in checks.log as
source-only validation; they add no Bend history, mutation or proof counts.
No verdict/lane implementation, kernel modification, source repin or semantic
deviation is introduced by this review.
