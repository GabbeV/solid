# Candidate diagnostic location and structural predicate

**Stage-84 limitation:** the pending callback implementation itself can add a
normal dependency edge for control-flow reads. `isPending(() => data())` can
therefore satisfy the two-path graph predicate even when the user never reads
data outside the observation. `unified-pending-callback-diagnostic.test.ts`
demonstrates this. The walker is not a sound user-code classifier as it stands.

No runtime guard is installed. This is a narrower investigation following the
user's rejection of effect-write workarounds and the stage-82 latest bug.

The useful interception point is the layer notification/adoption path, after
adoption exclusions are considered but before `holdNode` replaces ownership.
The eventual invalidation is at `recompute`, which clears `_inFlight` and calls
`releaseFlightTeardown`. At that latter point the previous update owner may
already be lost. A diagnostic must not blame every request cleared there.

A candidate structural check is:

1. A pending output's notification is reaching a currently active flight.
2. It would transfer that computation from the observation input's lower update
   into the higher output update.
3. The flight's computation has an ordinary dependency path to the input being
   probed, in addition to its dependency through the pending output.
4. The pending notification is actually scheduling a replacement, rather than
   encountering a blocked adoption or merely accompanying existing invalidation.

Existing links and transaction/request fields support inspection of (1)-(3).
Stage 83 adds a test-only graph walker for (3), stopping at explicit boundaries
and considering current-generation links. It is conservative about inactive
boundaries and does not retain historical read values or request arguments.

The original self-feedback and its intermediate-status-memo variant have both
paths. A status-only delayed indicator has no ordinary path and is excluded,
despite its timer sharing the input update. A secondary fetch reading
isPending(primary) and id has no ordinary path from primary; a secondary fetch
reading isPending(id) and id does. Therefore this is a self-feedback shape check,
not a detector for every duplicate request.

The tested pure latest-key case likewise must not be branded application misuse:
its duplicate request is an implementation bug. General optimistic supersession
can change the question deliberately.

This is **not yet a sound, complete error policy**. An async presentation memo
could intentionally consume both the ordinary value and its pending boolean.
The graph cannot reveal whether a promise represents a request, timer, or worker
calculation, or whether two function calls have the same external request key.
Rejecting the structural shape would be an explicit API restriction, not an
inference that all such user code is erroneous. No such restriction is accepted.

Nor has (4) been implemented: callbacks can encounter already-dirty readers,
deferred owner frames, multiple notifications, or equal intermediary results.
For precise notification-to-cancellation attribution across queued work, a
development-only temporary record of flight identity and cause is an option,
but it is additional bookkeeping and must be described as such. Without that,
a pre-adoption check can report only what that operation demonstrably establishes.

Cost: no extra ordinary node fields. Direct cases use existing fields/maps;
indirect cases need temporary graph traversal and a visited set. A future
development-only implementation could compile out of production, but none is
installed and no runtime performance claim is made here.

Validation: the 12 metadata scenarios plus the delayed-indicator test pass with
the ordinary-path assertions. Files:
`tests/helpers/pending-feedback-audit.ts`,
`tests/unified-pending-feedback-metadata.test.ts`,
`tests/unified-pending-timer-cancellation.test.ts` under `packages/signals`.
