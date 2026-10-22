# Queued optimistic guesses and seam prefix

At Solid 5b1b7776 (rc.17), pendingGuessOf, guessedValueOf, optimisticWrite,
inFlight, applyGuesses and the installed applyGuessesAt/laneSeams closures now
execute internally. Core flush/seating and public optimistic/verdict creation
are still unfinished. No semantic deviation is active.

## Source operations

pendingGuessOf scans the source triple array backwards; guessedValueOf prefers
the newest unflushed guess, then lane value or committed truth. optimisticWrite
captures that value before invoking a callable updater once, compares directly
through the raw comparator, and checks the current GUESS bit after it returns.
Equal plain writes stop; equal re-asks still queue a question and entangle their
frames. Unstamped writes allocate nextQuestion at the source push point.

applyGuesses keeps the source mutable parent/shared-lane locals and live array
bound across raw comparator callbacks. Existing overrides replace their slot
and retire nonguess staging. Held nodes open a lane under their actual holder;
otherwise an own flight can open the parent, or no parent drops the guess.
Holder merges, live question stamp, notification and laneDirty stay in order.
The ordinary/store-flight decision shares transaction.laneInFlight's one body;
unsupported store resolvers remain an explicit refusal rather than a second
approximate implementation.

applyGuessesAt records the old live-lane prefix before applying guesses.
laneSeams retains null versus list leaks, disposed/answered-verdict exclusions,
parent blocking, leaked-effect seating, heap enqueue and strict-identity leaked
lane deduplication. It reveals the current lane array backwards, capped by the
recorded prefix; newly born lanes await their first work round.

LaneState stores typed Guess(node,value,question) triples, the judged prefix and
an explicit mount union for the source core laneRoot's unset/false/lane values.
The mount slot is reserved data at this checkpoint, not active seating support.
All record rebuilders and World-frame proofs preserve these fields. Canonical
signal/memo/history/chain witnesses were regenerated from the actual runtime;
independent kernel checking remains necessary and separate from generation.

## Evidence

1,425 native queued-guess programs, 1,824 native seam programs and 58 comparator/
updater controls pass. They check reverse lookup, raw falsey slots, questions,
re-asks, held/own-flight parents, mutable parent propagation, old-lane prefix,
leak gates and real user callback returns/throws. Updater cases include previous
unflushed guesses, function/thenable results as data, reads/writes and pending.
Native source function bodies stay unchanged. A test-only wrapper around the
original newTransaction binding records allocations solely to name identities;
it delegates the original body and changes no reactive decision.

Nine quantified properties cover newest lookup over any finite prior queue,
empty lookup, empty application/prefix capture, equal plain-write suppression,
equal re-ask, exact unstamped question allocation, null seam entry, capped reveal
entry and zero-reveal preservation. The newest-lookup proof uses list induction
and the existing general arena lens, not a second lookup implementation.
No full lane lifecycle/progress or TS-equivalence theorem is claimed.

Fifteen new compiled variants bring the total to 337: 288 differential and 49
proof assertions. Public histories and closed regressions remain 3,158 / 72;
these are private helper/closure controls. Store/folded hooks, attribution,
boundary freshHook, core seating/publication/flush and public constructors/windows
remain unfinished. No upstream bug workaround was required for this layer.
