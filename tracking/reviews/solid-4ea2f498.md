# Solid next 4ea2f498 (rc.18)

Reviewed the four commits after 2a0da2fc. All 77 recorded Solid inputs match
4ea2f49862a53c8cc405f4b746525d5d78bf434f byte for byte. Five recorded
source files change; see the impact report.

## Production integration

#4254 (2d9c9aac) makes computed self-disposal request a future flush when the
module pendingNodes queue still contains nodes. The previous pending/transaction
and frame-read conditions remain in their original order, followed by the new
pendingNodes.length condition. Bend owner.afterPark uses the existing World's
pendingNodes list and constant-time emptiness check. scheduler.ts now exports the
same existing queue. No queue algorithm, cleanup policy or machine budget changes.

The native build/declaration checks and full signals suite pass: 344 files,
5,579 tests, two expected failures and two skips. This includes upstream's real
GC/inspector regressions. Bend uses stable arena identities and does not model
JavaScript physical garbage collection; the port checks scheduling/state only.
64 native/Bend guard cases cover queue presence, computed versus root disposal,
self, pending/transaction and frame-read conditions. Two kernel roots establish
scheduled=true on an actual computed-self-disposal family with an arbitrary
nonempty queue and the empty/unheld control. Removing the new guard is rejected.
Neither root claims queue draining or global cleanup/reveal progress.

## Reviewed exclusions and retained scope

#4256/#4260 exempts observe-only merge key-bag memos from an unstable-output
diagnostic. CONFIG_KEY_BAG is generated without changing existing constants;
attribution.ts and store/utils.ts diagnostic behavior is outside this production,
non-store profile. #4253 select handling and #4258 HTML entities touch web/compiler
layers outside the signals translation. No semantic deviation is active.

All earlier theorem domains remain, including the 103-step deferred data and
118-step stream families. Bend 2.0.37, independent kernel, resource limits and
source statement ordering remain unchanged. The current seal records the full
input/kernel result. The completed 633-variant sweep is historical evidence on
frozen 73eda482 at 2a0da2fc; the current 653 configuration has not had a complete
sweep. Twenty later focused kernel variants passed at their individual checkpoints,
including this new scheduling variant; that is not a fresh complete sweep.
