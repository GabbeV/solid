# Lane-aware transaction judgments

At Solid a2a5b6f8 (rc.16), scheduler `blocked` now includes the actual lane hook
judgments. `runtime/transaction.bend` retains scheduler/lanes function names and
uses explicit call/return tasks for their mutual recursion, avoiding a Bend module
cycle. Public lane/verdict constructors/windows and lane stage/read/write/reveal/
correction/dissolution/boundary paths remain unfinished.

## Source operations and return points

| Source | Bend | Correspondence |
| --- | --- | --- |
| scheduler.blocked | blocked / JudgeTx, RestoreJudge | Save the ambient judge, install this transaction only when null, test open count then actual blockedBy then lane hook, restore the original judge on normal return. |
| lanes.lanesBlocked | lanesBlocked / JudgeLanes, AfterLinked | A lane's linked peers first; then its nested lanes. Ordinary transactions only consult nested lanes. |
| lanes.linkBlocked | linkBlocked / LinkedMembers, ContinueLinked | Capture the shared array identity, walk live indices, exclude self, then peer open count / actual ownFlights / nestedBlocked in order. A peer's full blocked result is deliberately not substituted for ownFlights. |
| lanes.nestedBlocked | nestedBlocked / NestedMembers, ContinueNested | Walk live lanes, resolve each raw parent with actual resolveTx, then a child's full blocked result followed by guessFlights. Child judgments restore the enclosing judge before the continuation. |
| lanes.guessFlights | guessFlights / guessFlightLoop | Walk the live node list, require GUESS and exact current transaction membership, then inFlight. Stale list entries left by rehoming do not count. |
| lanes.inFlight | laneInFlight | Pending status wins immediately; a needed store slot resolver refuses (88); otherwise false. |

The source distinction is retained: a lane's derived flight blocks its own lane
and linked reveal group; a written guess's own refetch blocks its parent while
the guess can show. Foreign-source pending is not automatically a peer's own
flight. Mainline transactions with no live lanes retain their previous outcome.
The source hidden-boundary and store hooks remain outside the admitted profile.
No alternate scheduler or wait-for-all-promises rule is introduced.

## Representation and execution bound

One BlockFrame carries World, explicit return tasks and the current boolean.
The same driver serves the public-internal blocked helper and lane queries;
existing blockedBy/ownFlights/resolveTx and source group/live arenas are reused.
The driver has a finite explicit execution budget (constant prefix plus a
transaction/graph-size allowance), and stops on a fault. It is not a proven
arbitrary-graph progress bound. Exhaustion/refused store work never counts as a
successful blocked/unblocked answer. Structurally valid transaction/parent/group
identities and finite supported executions remain profile requirements.

## Evidence and proof boundary

1,190 explicit native helper programs contain 29,700 judgments against unchanged
source function bodies. They cover nested and linked topologies, open actions,
own/foreign sources, present-empty source Sets, pending/settled/error guesses,
render/stale-frame/no observers, real transaction merging and parent redirects,
rehomed nodes and stale list entries. Every query checks its result and restored
judge. Final checks compare transaction/node flags and identities, live/group/
ordinary membership, source queues and pass state. Synthetic helper states are
not public histories. Only private observation/priming exports are added in memory.

Four quantified properties in `proof/lane-blockers.bend`, rooted in LAWS/PROOF,
check with the original independent kernel:

- Any positive open count blocks and restores the exact surrounding healthy World,
  including an initially null or nonnull ambient judge.
- An empty ordinary transaction with no live child lanes is unblocked and restores
  the exact surrounding healthy World.
- An open peer in the captured shared group blocks, preserving the World.
- An owned pending guess is found by the actual guessFlights walk, preserving World.

They use designated existing arena slots and quantify other records, tails/counts
and surrounding state under their declared scopes. They are not a general lane
lifecycle, arbitrary-graph, progress or TS/Bend equivalence theorem. The empty
transaction property uses a separate any-budget empty blockedList lemma and
checked first-step/return-point transports; no runtime rule or kernel budget was
changed to make it pass. The preceding complete proof root also passes against
the new driver before adding these four properties.

Twelve added compiled variants target open/self/group/own/child judgments, saved
judge restoration, stale guess ownership and pending/guess guards. Four are
rejected by quantified proof assertions and eight by native helper assertions.
The complete 263-variant sweep and existing public/history/proof suites are
rechecked. Public histories / composed closed regressions stay 3114 / 72; the
source pin and empty semantic deviation register stay unchanged.
