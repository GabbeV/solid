# Constructing nodes before settlement

The [graph construction](graph-construction.md) family now receives its node
identity and metadata premises from the actual default constructors. This is
construction through `construct-state.signal`, `computed`, `createEffectNode`
and `setupComputedNode`, stopping before Core evaluates their callbacks. These
are the real shared constructor helpers, not a replacement scheduler or a claim
about complete public memo/effect execution.

Generic append laws derive the fresh record, arena length, nonzero valid fresh
identity, preserved earlier valid identities and unchanged older node records.
The same-slot lookup requires actual membership. Parentless setup follows the
source's self heap-pointer write, parent linking guard and computed-parent height
guard; a reusable equation relates its actual result to the appended updated
record. The null-parent computed identity remains an explicit initial-context
invariant. Exact literal equations keep the proof-side record descriptions tied
to the active default signal/memo/render implementations.

`memo-render-construction.bend` allocates a memo and a render node in succession,
using their actual arena lengths as identities. Initial nonempty nodes/link
arenas, healthy fault and null computed-parent identity are its context premises.
It derives valid distinct IDs, empty dependency/subscriber fields, the render
node's absent auto-dispose flag, and preserved link storage and health. Actual
`graph.link` then supplies the one-edge certificate. No final node, edge, head,
health or caller-return equation is assumed. The result composes to the existing
ten-step-room settlement return and retains every committed cached value,
complete tree and full event trace from the post-allocation state through graph
creation and that return, including the early/fault alternatives.

Nine roots extend 516 to 525, with arbitrary Worlds, represented callback
expressions, render targets/program/cleanup IDs, caller work and value stacks.
The typed integration fixture begins with a reserved healthy arena plus an
arbitrary finite list of cached values; it proves the initial context facts in
Bend. Forty-eight executable cases vary the prefix size, payload and caller,
with 144 actual-driver splits. They do not evaluate callbacks or register a
pending flight, so they exercise the nine-step absent-carrier alternative.
JavaScript supplies data, never equality evidence. Three focused kernel faults
check memo/render auto-dispose policy and heap-pointer initialization.

Configured negative checks are 639 = 484 finite / 155 kernel; complete frozen
sweeps are accounted separately. Runtime, host, source pin, kernel, task budgets
and previous theorem domains are unchanged; no semantic deviation is active.
[Receipt](reviews/node-construction-validation.json).

Default parentless helpers are the current domain: owned construction/options,
eager callback execution, pending carrier/flight registration, arbitrary graph
histories, full action/flight accounting and coordinated reveal remain open.
The bounds prove local internal return and content safety, not eventual delivery
or publication of the computed expression's value.
