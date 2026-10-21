# onSettled source review

Pin: Solid b0ad1df5, production, inactive boundary/lane hooks. This adds the public
`onSettled` API to the same runtime used by existing tests and kernel checks.

`signals.ts:onSettled` reads the actual current owner and checks
`CONFIG_CHILDREN_FORBIDDEN`. An eligible owner constructs the existing
`trackedEffect` wrapper with `untrack(callback)`. The body therefore uses the
tracked leaf's commit-phase timing and cleanup lifecycle without subscribing to
ordinary successful signal reads. Pending initial reads still use the source's
retry mechanism. Owner disposal prevents an unstarted owned callback from firing.

The other branch allocates a plain function identity, enqueues it in EFFECT_USER,
and creates no reactive node or artificial owner. `fire` checks the heap's live
minimum/maximum. While work remains it enqueues the same identity, through the
ordinary default passLane routing. Otherwise it calls the callback once and drops
its result, as production Solid does. The existing queue snapshot detachment and
exception unwind are retained: a callback throw can interrupt that detached list.
No new catch, error policy, dev diagnostic or cleanup execution is added.

World and Transaction user queues now contain QueueEntry values. NodeRun carries
the node-bound runner identity already used by ordinary and tracked effects;
SettledFire carries the identity of the captured plain callback. The expression
arena represents those fire closures without altering source node allocation.
Render queues remain node-bound. Queue joins, transaction release, seam save and
restore preserve entry order and duplicates. The direct queue fixtures normalize
NodeRun to its target only for comparison with native bound function identities.
Neither adapter schedules a callback, waits for derivations, or invents an owner.
Nested callback expressions capture existing lexical signals and callback inputs.

The 54 public histories compare actual native onSettled calls with the Bend API:
owned/unowned one-shot reads, eager/lazy derived reads, returned cleanup families,
pending/loading/error delivery, disposal, nested and children-forbidden creation,
lexical captures, render writes, queue ordering and interruption by throws. The
existing direct-getter cleanup observation limitation applies: read events from a
native getter invoked directly as cleanup are excluded only in that family;
other traces, states, ordered dependencies, reports and results are compared.

Forty-eight direct native fire-closure cases check equal/inverted/spread heap
bounds, repeated calls, closure identity, no reactive allocation and live lane
queue routing. Synthetic routing cases do not claim public active-lane support.
The full pre-existing alignment suite also checks user queue merges and commits.
Four compiled mutations target missing untrack, heap gating, identity and lane
routing. Two concrete kernel regressions cover the owned cleanup lifecycle and
unowned dropped return; two general binding laws cover captured callback/lexical
inputs. None is a TS equivalence proof or a general reactive graph theorem.

A render-write control deliberately preserves the different source timing:
owned onSettled can observe the currently committed coherent frame before a
render callback's new write lands, while unowned fire defers until remaining
heap derivations finish. This is existing source behavior, not a port repair or
a newly established upstream bug.

Active development/observe diagnostics, arbitrary JavaScript closures, installed
boundary/lane/mark hooks, stores, and broad graph invariants remain unfinished.
