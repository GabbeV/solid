# Setter reads and optimistic lifetime

Playground: https://s.olid.uk/id/8bc8f6d1-4897-4149-8c19-621db513e852

Upstream next bcef1041, browser-verified with no errors. One button starts
A (a = 1), then B (b = a + 1) 500 ms later; both actions wait 1000 ms.
Visible sequence: 0,0 → 1,0 → 1,2 → 0,2 → 0,0.

Controlled source probes on next and the experiment agree: B reads 1;
A's ordinary signal write commits when A finishes; B's guessed 2 remains.
A literal b = 2 control behaves identically. Writing a = a + 1 instead
entangles both action lifetimes and holds A's ordinary write until B ends.

The issue form proposes entanglement for a setter consuming another action's
active override and asks whether the current distinction is intentional.
Prepared for user review, not submitted by the agent. No runtime semantic
change has been implemented. Receipts are in
../../checkpoints/setter-read-report-20261112.tar.xz.
