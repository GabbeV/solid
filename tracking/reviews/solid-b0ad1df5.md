# Solid pin update: 71153bf0 to b0ad1df5

Reviewed 2026-10-21 (Europe/Stockholm). Fetched `solidjs/solid:next` at
`b0ad1df505b835058a4b3750ab37d6576bb18c01`, declaring rc.16. The previous
checkpoint remains at `baseline/solid-71153bf0` (`075455c`); the original
d2ad8b28 baseline remains separately preserved. Work continues on
`integrate/solid-next-fixes`; `main` and the Bend/Lean toolchain pins are unchanged.

[Impact](solid-b0ad1df5-impact.json) was generated before replacing the snapshot.
[Validation](solid-b0ad1df5-validation.json) records exact revisions, independent
before/after controls and log hashes. All 76 vendored Solid files were compared
with the clean candidate checkout and copied verbatim where different. Three
changed: the package manifest and two source files. No local patch was applied
to obtain the new reference behavior. The deviation register remains empty.

## Operation review

| Source change | Translation treatment and limits |
| --- | --- |
| #4168 / a2743fa2 adds `!disposalDepth` to the owned-scope write guards in `setSignal`, `markRefresh` and `devGuardStoreSetterWrite`. | All three guards are development-only. Production setter/refresh behavior stays unchanged; the store import adds no initializer or hook installation. Dev cleanup-depth bookkeeping, diagnostics and store APIs remain unported. Existing cleanup expression reads/writes and helper probes are revalidated in the production profile. |
| #4169 / 5a4b2e85 explains untrack and unresolved async reads. | The executable `untrack` function is unchanged. Twelve public histories on both pins check the first missing-value retry, subsequent snapshot behavior, explicit undefined/zero loading seeds, eager/lazy readers and immediate/native delivery. The source itself advances to 9 while the untracked snapshot remains its initial value. No new runtime behavior or theorem is claimed. |
| #4171 / dc063a65 adds module-local `laneRoot` and recompute locals `prevMount`/`mount`. A creation pass inherits `prevLane || prevMount`; an update breaks that creation chain. The body finally restores the previous mount. | Active lanes/actions/verdicts/boundaries remain unported. The admitted profile enters with no lane scope or lane-bearing node: `prevLane` stays null, and inherited mount stays falsy through nested first passes and updates. Bend therefore has no new lane state yet. The source locations and missing state/continuations are recorded at `PassFrame` and in correspondence. Implementing lanes must add the real local capture/restoration rather than reuse the current reduced state. |
| Recompute's `joined` now accepts `REACTIVE_STAGED_READ` for a lane mount; the former `prevLane && STAGED_READ` tests are removed from initial value publication and the final pending hold. `freshHook` receives `!mount && flushTransaction`. | With no active lane, mount is falsy and joined still tests only `REACTIVE_JOINED`. `bornHeld`, `publishValue`, both finally-entry joined captures, and `finishPublication` retain their existing production operations. The active mount, freshHook and boundary behavior is verified by upstream's tests, not attributed to the Bend port. |
| Full-index module initialization. | The actual reference index installs lane hooks through `core/lanes.ts`; hook presence alone does not create a lane. This is distinct from Bend, which has no lane installer. The reduction above depends on inactive lane scopes and node state, not an assertion that the full-index reference lacks hooks. Store hook initialization stays intact. No changed source file adds a hook installer. |
| Other commits: server-function client send #4170, example router updates #4172, rc.16 release metadata, compiler WASI path fix #4173. | Outside the signals engine translation. The signals manifest version updates to rc.16. No flags, record fields, constants or scheduler/graph/pending modules change. No compiler/browser or web-package validation is claimed by this repin. |

The source inventory captures the changed file hash and shifted function/branch
ranges. The module-level laneRoot declaration was reviewed separately: declarations
are not indexed function units. Changed function fingerprints are recompute, setSignal,
markRefresh and the unported store guard. All unreviewed branch obligations remain
open; the impact review does not grant package completeness or TS/Bend equivalence.

## Before/after evidence

Upstream regression files were copied without edits into the previous clean
71153bf0 checkout, run there, then removed. The cleanup-write tests were also run
one at a time in fresh processes because the first error halts that module's
reactivity and would otherwise contaminate later controls.

| Upstream test | 71153bf0 | b0ad1df5 |
| --- | --- | --- |
| Removed row cleanup writes a signal | Owned-scope error / halt | Pass |
| Removed row cleanup writes a store | Owned-scope error / halt | Pass |
| Branch cleanup writes a signal (isolated) | Pass | Pass |
| Removed row cleanup retains owner/context (isolated) | Pass | Pass |
| Verdict-mounted Loading, nested render effect | Publishes future value during the hold; fails | Pass |
| Same render effect inside another memo | Same premature publication; fails | Pass |

The new pin's unchanged signals build (all three tiers and source declarations)
passes. Its full signals suite passes **327 files / 5,411 tests**, with three
expected failures and two skips. The two new regression files also pass all six
tests under the production and observe source profiles. The first package-manager invocation attempted
an unnecessary dependency refresh and rejected a newly released example router;
the build/test checks instead invoke the already installed tools directly.
No dependency-age policy was changed. The signals tool dependencies are reused
from the preceding validated checkout; this is not a fresh rc.16 lockfile install.

Bend validation: **2,115 public differential histories**, **136 direct owner/core
probes** and the full helper alignment suites pass; **97 compiled mutations** are
rejected. The independent kernel rechecks the same **48 concrete regressions**
(47 positive and one preserved upstream counterexample), plus the existing
general helper laws. This update adds tests, not a new proof or supported engine.
The final source/output seal is `tracking/checked.json`.

The original three fixed bugs still pass their source-only controls and supported
Bend counterparts. The throwing-cleanup collector regression still reproduces;
its negative law and paired histories remain. PR #4176 is open and its finally
change is not applied locally. An eventual merge must be reviewed and integrated
as its own source update.
