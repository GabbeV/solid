# Lane confirmation, reveal and dissolution

Solid 5b1b7776 (rc.17); ordinary typed nodes, production. This internal layer
ports supersede, dissolveLane, laneSeam and endLanes through the shared Core
continuation machine. It does not install public optimistic/verdict scopes.
No semantic deviation or source change is active.

## Source return points

supersede captures txOf and resolved parent, dissolves differing guesses before
copying the shown value and clearing override/guess, then holds/notifies, stages
the incoming truth and joins the parent. Confirmation stays silent except for
the installed authoritative truthConfirmed hook.

dissolveLane removes the first live identity and unlinks its shared group,
ends its cached live verdict first, then scans live lane members. It captures
effect/guess/slot/shown/latest before clearing the lane. Landing invokes the real
commitPendingNode continuation, then publishes dirty/pending inputs and uses a
raw comparator before notifying. Correction rehomes guesses; shown derivations
commit their screen value, while hidden derivations dispose only their parked
frame and clear staged/held flags. Pending derivations retire the void flight
and enqueue a new question. Shown unheld corrections retain queued runs; hidden
or held corrections discard them. Parent landing releases them.

laneSeam short-circuits leaked/blocked lanes, otherwise marks shown, reruns stale
readers, handles LEFT_SHOWN before membership tests, promotes only nonguess
noneffect staging, disposes replaced frames, clears staged and releases queues.
endLanes scans the live array backwards with nested lanes first. Core tasks are
source callback return points; they retain the original index and reread current
member length after commit/disposal/comparison. No snapshot walk or second
publication/cleanup engine is introduced.

## Evidence

3,496 actual-source helper programs compare confirmation/correction, commit/
revert, reveal, nested teardown, reversed/stale members, flags, raw slot presence
and effect queues. 22 additional raw-comparator controls check post-commit
arguments/returns/throws/NotReady and absence of isSame error wrapping. 60
cleanup controls use real callback programs to check LIFO continuation, falsey
raw errors, callback reads/writes, final fields and once-only drain rethrow.
Public history and closed-regression counts remain 3,158 / 72; these controls
are separate private helper evidence with metadata primers and unchanged source
function bodies.

Five quantified properties cover leaked-seam held-only mutation, effect commit
without scalar comparison, reverse-scan entry, stage-before-join confirmation
and hidden correction flag clearing. They preserve exact arbitrary surrounding
World, payloads and caller continuations. They do not prove arbitrary recursive
lane lifecycle, callback mutation progress or TS equivalence. Twelve additional
compiled mutations bring the cumulative total to 308 (261 differential and 47
proof assertions).

One synthetic fixture linked a lane to its own nested verdict, forming a
recursive blocker cycle that source enterLane's ancestry checks avoid. That
combination is excluded from reveal probes rather than changing the blocker
algorithm. Arena traversal budget refusal stays explicit. Observation primers
also distinguish successful undefined/null lane values from NOT_PENDING; a
nullish-coalescing observation mistake was repaired before validation.

Store echo/covered hooks, store slot nodes, attribution, folded optimistic
stores, pending guess application, lane correction judgment and public core
read/write/outcome/seam hookups remain unfinished. No upstream bug or source
workaround was required for this layer.
