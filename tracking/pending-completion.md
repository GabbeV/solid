# Pending notification completion and final-source status

These contracts use the actual production runtime at Solid4ea2f498, with the
explicit Lean-checked `same-head-congruence-v1` profile and unchanged400M fuel.
They recover previously resource-stopped compositions; they do not assume those
old attempts or change runtime behavior.

`pending-leaf-notification.bend` proves actual `status.dispatch` for a pending
NotReadyError notification to a memo with no subscribers and no CONFIG_GUESS.
The local stores preserve subscriber topology and storage/health for every input
status word, including the shown-error branch. Dispatch preserves its incoming
continuation, visited list and scheduled flag, and queues the real zero-edge
Propagate task. With an initially healthy World it completes in two steps. Valid
node identity derives enough room in the existing public `notifyStatusWith`
budget, so that public runtime helper returns exactly the local-store World.
No final Machine, successful run, or extra budget is an input premise.

This is an operation contract, not full public callback reachability or arbitrary
subscriber propagation. The generic full-World equation is relative to the real
local stores; native controls also check old shown-error identity. For native
incoming ERROR states, those controls allocate and populate the corresponding
extension before setting status, preserving Solid's private-state invariant.

`pending-last-source.bend` constructs an empty-carrier certificate from actual
singleton removal. Its pointer, extension range and retained/tombstoned arena
come from the removal proof, not an assumed final source count. The actual read
of remaining sources therefore gives zero. With valid identity and no held
configuration, the successful no-error status phase has an exact whole-World
form. Held joins are deliberately retained by the broader projection contract.

`pending-settlement-status.bend` proves the actual status phase's all-node status
vector: when a source remains it is unchanged; at zero it equals exactly one
selected-node pending-bit clear. This includes actual transaction resolution,
merges, held joins and error branches; it is not a claim that those operations
preserve health or all other fields. `pending-last-source-status.bend` composes
actual singleton removal, derived validity/zero count and that phase to prove
PENDING is false for the selected node, including held/error cases. It also
proves the actual removal reported success.

The source's `settled` controller additionally stamps time, queues work and
clears blocked state, then traverses dependents and performs deferred owner
release. The last-source status theorem does not yet include those stages,
full action/flight accounting, successful flush or eventual rendered reveal.
These remain dependencies of the joined held-action milestone.

Nine composed roots extend630 to639. Existing root domains are retained. The162
native/Bend leaf controls cover all16 low status words and two high-bit controls,
three arena sizes and fresh/allocated/duplicate membership, with actual two-step
completion and explicit one-step exhaustion. Three compact actual-operation
kernel counterexamples reject loss of the continuation, an undersized public
budget and failure to clear the last pending bit. Test counts support these
contracts; they are not an overall completion percentage.
