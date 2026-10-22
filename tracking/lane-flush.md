# Lane crossings in the flush seam

Solid 5b1b7776 (rc.17). GlobalQueue.settle now invokes correction, guess,
reveal and lane-ending bodies through the same core driver. The source pin is
unchanged. No semantic workaround is active. Public optimistic construction
and verdict read windows remain the next admission boundary.

## Order and captured state

The installed source correction hook first tests whether lanes exist. A true
correction drains one more pure heap round before the joined transaction is
captured. This shares the existing heap visitor, including tracked-effect and
zombie precedence; its continuation returns to settle rather than a second seam.
The joined local is captured, then the global is cleared, then applyGuessesAt
runs once. Later comparator/cleanup writes may join another transaction without
replacing that local. Empty helper calls fuse their return points while retaining
the judged-prefix store and the existing plain-program step budgets.

The park/commit and trim paths retain their source guards. The parked path takes
and sorts its deferred-zombie snapshot, clears the collector, and reruns eligible
non-disposed zombie verdict readers before lane seams. New deferrals stay live
for the final survivor pass. Typed verdict-engine installation is assumed here;
storePark, folded stores and boundary mounting are still excluded.

The seam captures own render/user queues, installs empty lane queues, calls
laneSeams with staged readers only for a parked frame, clears those readers,
captures the lane queues separately, and installs fresh landing queues. The
five-field SeamFrame carries these locals across real callbacks. A transaction
is removed before endLanes and land; reverse scanning restarts after each
landing. The final queue is lanes, then own unless parked, then landing runs.
Parked own runs are appended to the live holder instead. The plain empty arm
retains its original list. No alternate scheduler or sorted effect order is used.

## Evidence and proof limits

538 complete-settle programs compare actual pinned GlobalQueue.settle state:
corrections, guesses, parent joins, held/free frames, shown/hidden lanes, staged
readers, parked verdict zombies, landing and queue layers. Comparators write a
held signal during application; real onCleanup callbacks register onSettled,
write a held signal and throw undefined or a number during reveal or landing.
Raw cleanup-error presence, node/transaction fields, heap and queues are checked.
These are private-engine fixture programs, not new public histories. Queue
identities use actual source effect runners; they do not claim complete effect
phase coverage. Existing 2,304 mainline seam and 48 deferred-zombie controls also
remain valid.

Five quantified properties cover arbitrary finite render/user queue ordering,
the captured-null-join branch, the landing continuation and ineligible parked
zombie skipping. They are scoped return boundaries, not arbitrary lane-history
or progress theorems. Existing complete signal/memo/history/chain guarantees
and budgets are unchanged. Canonical witnesses are regenerated from the actual
runtime. A kernel memory spike in the signal proof was resolved by transporting
its fuel equality on an abstract execution path before instantiation, using the
existing path-composition technique. The unchanged independent kernel passes;
no runtime, proof domain, fuel guarantee or kernel rule was relaxed.

Eighteen new mutations target these boundaries. Resource failures are not
credited as useful mutation rejection. Public-history and composed closed-law
counts remain 3,169 and 72. Public optimistic/verdict APIs, freshHook/boundary,
store/folded, ambient mark release, snapshot and general host protocols remain
unfinished. There is no new upstream Solid bug or temporary semantic deviation
in this checkpoint.
