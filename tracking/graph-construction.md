# Constructing the settlement graph

The earlier [one-edge return](one-edge-return.md) theorem required a nonzero
source subscriber head, its selected leaf and a zero next-subscriber cursor.
The new constructor family derives those facts from the actual translated
`Graph.link` and `Graph.allocate`, including the recomputing branch. No runtime
helper, mutation order, task, budget, source pin or checker limit changes here.

The input is an arbitrary healthy World containing two distinct valid node IDs.
The source's subscriber head/tail and the leaf's dependency head/tail are empty;
the link arena contains its reserved entry. The leaf has no subscribers and no
auto-dispose configuration. These are input facts about the initial state,
not assumed equations about the graph operation's result. They still require
construction from public primitive allocation and preservation across broader
histories.

`node-store-lookup.bend` establishes actual existing-slot lookup after writes and
preservation at distinct indices. A successful same-slot write requires an
in-range index; an out-of-range list update is not silently treated as allocation.
`graph-empty-allocation.bend` follows the exact append, leaf dependency-tail,
source subscriber-tail, leaf dependency-head, source subscriber-head and epoch
writes. Separate storage/shape observations avoid comparing unrelated full Worlds
while retaining the actual computed World.

The general `GraphLinked.build` certificate derives the new nonzero head, selected
leaf, end cursor, health and validity of both node IDs, and retains the leaf's
subscriber/configuration facts. Both flag branches go through actual `Graph.link`;
no non-recomputing premise is imposed. `startReturn` composes directly to the
existing ten-step-room actual settlement return, including its early/fault
alternatives and exact caller work/stack. `frame` retains every committed node
value, complete tree and full event trace across graph creation and settlement.
It does not assert a healthy final result, full readiness or publication.

Eight roots extend 508 to 516. The compact executable fixture supplies all
initial equality evidence inside Bend, then exercises 64 private constructor and
return cases and 192 actual-driver splits with undefined/null/booleans/numbers,
NaN, signed zero, strings and reference payloads. JavaScript supplies data only.
These controls are not public reachability or compiler-correctness proofs.
Native graph alignment retains 144 matching operation cases. Three targeted
kernel mutations distinguish a self-linked tail, wrong leaf and missing head.
Configured mutations: 636 (484 finite / 152 kernel); frozen complete sweeps are
reported separately in [verification.md](verification.md).

Public allocation of the initial nodes, arbitrary graph shape, general
callback/owner work, complete action/flight accounting and coordinated reveal
remain open. [Validation receipt](reviews/graph-construction-validation.json).
