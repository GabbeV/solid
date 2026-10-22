# Lane answers and core read/write crossings

Solid 5b1b7776 (rc.17), production ordinary-node profile. laneWrite, laneOutcome
and laneCorrections now execute through the shared Core driver. Core setter and
read dispatch call the real lane helpers; frameRead and stagedScreen retain the
lane/verdict reader branches. Public optimistic construction, verdict windows,
flush lane application and mounting remain unfinished, so these helper results
do not expand public admission. No semantic deviation is active.

## Correspondence

laneWrite tests ambient answer provenance before comparing a guess. An older
answer stages beneath it, marks held and schedules without correction. Current
guess answers call supersede with the raw comparator verdict. Derivations compare
against laneValueOf, then stage in the shown lane or replace its lane slot,
stamp computed time, notify and mark lane work. Equal derivations do not schedule.
laneOutcome preserves errored-pass refusal and answered-source/current-clock
provenance; its stale arm does not schedule. Raw comparisons do not acquire an
isSame catch.

laneCorrections snapshots the live lanes array exactly where source uses slice;
its node scan stays live and stops when a correction removes the lane. Resolved
parent action/open/lane, own-flight and guess-flight guards precede judgment.
Each guessed member compares its lane slot against staged truth or covered
committed truth and resumes after actual supersede/teardown. Folded store rebase,
echo and covered hooks and attribution remain excluded.

Core setSignal's override dispatch follows argument/updater evaluation and
precedes its ordinary held join/equality block. Core read dispatch follows pull
and held-entry, retains NOT_PENDING fall-through to the real pending/error tail,
and treats successful undefined as an early value return. Pending foreign-flight
reads retain lane/verdict committed-view rules. frameRead now includes lane work,
verdict readers, born-into and published-input distinctions; stagedScreen retains
flush-null and born-into gates before registering the stale reader. Existing
World-only facades remain restricted; they are not a second active lane engine.

## Evidence and proof boundary

1,704 native answer/correction programs, 66 raw comparator controls, 5,048 actual
core-read/helper programs and 28 getter/setter programs with explicit lane
metadata pass. The last group uses real public getters/setters after private
fixture setup, including updater entry values, reentrant correction, reads and
raw updater throws. It is not an admitted public optimistic history family.
The 720 existing question/provenance vectors are rechecked separately. Source
function bodies stay unchanged; private exports/reset/metadata primers are added
only in memory. Public histories and closed regressions remain 3,158 and 72.

Six quantified actual helper boundaries check errored-outcome World preservation,
correction snapshot/empty-scan judgment, setter override dispatch before mainline
work, real token fall-through and successful undefined early return. No global
lane progress or arbitrary callback mutation theorem is claimed.

The scalar/chain setter gate lemma now explicitly assumes no lane override;
its seven complete-program callers discharge that condition from their actual
arenas. This narrows a formerly inactive-engine helper statement to its valid
source domain as the missing source branch is implemented. The complete memo
constructor/update/history domains and sufficient budgets are unchanged.
Fourteen additional compiled differential variants bring the cumulative total
to 322 (275 differential and 47 proof assertions). No resource failure counts as
a semantic rejection.

Folded stores, boundary freshHook, recompute seating/mounting/publication and
lane flush application/seams remain unfinished. This layer required no upstream
bug workaround.
