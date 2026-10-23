# Nonempty rendered graph blockers

This checkpoint extends `085bc0470c80682e91a32ec83be6965dbb226a0a` without
changing the runtime, host, representation, upstream pin, toolchain or limits.

The previous completed-action eligibility theorem required an empty owned-node
list. The new `transaction-rendered.bend` contract covers a different source
branch: zero action debt can still leave a group blocked by an owned, pending,
non-guess, non-disposed render node that remains on screen. The node's captured
transaction already names the terminal group. An arbitrary finite prefix of
nodes excluded by the real eligibility guard may precede it, and any tail may
follow. The public `blocked()` result is true and the **complete current World**
is preserved, including restoration of the previous judge. The list proof uses
its existing public budget, derived structurally from the prefix/tail lengths.

`transaction-membership.bend` proves the actual `txOf` lookup/compression is an
exact World identity when the captured group is already terminal. This is proved
through the actual extension store and generic list readback/store identity; the
blocker contract does not simply assume its membership lookup has no state effect.
The list identity also holds out of range because Bend's List.set is a no-op
there. **That algebraic fact is not an arena-validity certificate.** The rendered
snapshot and nonzero group conditions must still be established by construction.

The subscriber helpers additionally retain the source generation/error/disposal
predicate and show an on-screen valid pending reader blocks its memo. Current
generation plus a live reader supplies validity; an error-marked older generation
is a separate source-permitted case. The direct-render group root does not need
to traverse subscribers, but the memo contracts prepare that next crossing.

`rendered-landing.bend` composes this nonempty graph judgment with the real
landing scan. At the selected live-list entry, the scan retains the exact World,
caller continuation/stack and frame and advances to the next scan position. The
live-list lookup is still explicit. This is one source boundary, not a complete
flush or rendered-publication theorem.

## Snapshot premises and remaining reachability work

These are reusable operation contracts over an explicit snapshot. They require
health, zero action debt, the owned-node layout, actual pending/disposed/guess
bits, current terminal membership, render kind and non-zombie posture. They do
not assume the final blocked/eligible/txOf judgment. Construction of the graph
snapshot from the actual callback body, preservation through intervening writes,
completion, supersession, settlement and disposal, and eventual reveal are still
separate proof obligations. The earlier constructed empty-action family has not
silently become a nonempty rendered family.

## Supporting controls

`tests/joined-action-flight-history.mjs` uses independently authored native Solid
generators and the translated public action protocol. Two real actions write one
signal; its observed memo transitions from a committed baseline to a pending
Promise result. All six orders of the two action completions and flight
settlement, both creation orders, text/nullable/opaque identities and independent
work, with direct-render and memo-backed-render variants, give 144 histories /1,368 checked prefixes. The old view remains until all
three obligations clear, and independent work may publish while it is held.
These are finite differential controls, not the quantified history theorem.

Two focused kernel negatives and one finite direct-render negative are rejected.
The attempted render-node kernel negative hit the existing RSS limit and is not
credited. The first memo-only control accepted it because memo subscriber
blockage is redundant with direct render blockage; adding direct renders made
that finite control sensitive. No resource limits were raised. Configuration is
592 (470 finite /122 kernel), with no fresh complete sweep.
