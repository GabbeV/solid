# Solid next 225014bf (rc.18)

Reviewed six commits after b9b6f333. All 77 recorded Solid inputs match the new
Git commit byte for byte; seven inputs change: package metadata and six signals
source files. The source-impact report is solid-225014bf-impact.json.

#4237 confines effect callback/strict-read diagnostic windows to the DOM event
that opened them. core.ts adds dispatchingEvent, strictReadEvent and
strictReadActive; scheduler.ts adds ANY_EVENT, effectCallbackEvent and queueEvent.
Action/effect callers capture and restore that development-only state. Verdict
and store diagnostics consult the new active-window predicate. The new queue
branch is guarded by __DEV__; production retains the existing queue loop.
The production untrack callback/tracking/finally operations are unchanged; the
extra captured diagnostic variable has no user-observable getter or callback.
This translation's dev/observe diagnostic windows remain explicitly unported.
No production Bend algorithm, task, property or step budget changes for this pin.

Other commits bump seroval/web/compiler packages, add SSR validation and live
web row edits, and release rc.18. They do not add a signals production branch.
from.ts, deferred.ts, core/async.ts and the supersession hook are unchanged.
The full signals package passes 341 files /5,547 tests, two expected failures
and two skips; all JS tiers and source declarations build. The initial pnpm
command attempted an automatic install and stopped at the existing minimum-age
policy for a newly released web dependency. It is excluded from success credit;
the completed signals commands use the already installed dependencies via npm
scripts. No policy, lockfile or source patch was changed.

The three merged user fixes still pass all native tiers (60 cases). The
preserved protocol-error bug010 still reproduces with passing controls (120
cases), including the real one-button JSX/async-next control in Chromium across
all three unchanged source tiers (six browser cases). Nothing is filed or fixed
by this refresh. The semantic deviation register remains empty.

Current Bend public/alignment/kernel results and their sealed hashes are recorded
in solid-225014bf-validation.json and tracking/checked.json. Existing receipts
retain their exact earlier checkpoint; no source-refresh count is credited as
new implementation, new histories or new quantified theorems.
