# Membership across arbitrary carrier cycles

The previous source histories proved frames and bounded return but only checked
final membership on finite controls. The new single-source invariant proves the
membership result for arbitrary finite add/remove lists, including duplicates,
missing removals and repeated re-registration.

`CarrierSnapshot` describes the actual selected node in three cases: no extension
yet, an allocated extension with no source pointer, or an allocated extension/Set
containing exactly the selected nonzero source. It records actual range and
reserved-arena facts. Every actual add/remove transition constructs the next
snapshot from checked source equations. New Sets append; retirement leaves a
tombstone and retains the extension. Proof transport moves individual field
facts so the case tag remains observable; runtime operations are unchanged.

Induction carries that invariant through every finite command list. Membership
in the resulting actual World equals the command-list result: an empty list
retains the initial membership; otherwise the last add/remove decides it. A
separate whole-World equation shows that carrying the proof record executes the
same direct actual-helper programme. The memo/render constructor context supplies
the initial invariant without final-state assumptions, and the source identity
is the real allocated memo ID. Natural-number parameters here encode stable node
identities; cached data remains arbitrary represented `R.Value` data.

Nine roots extend 553 to 562. The emitted backend passes 131 constructed cycle
histories, covering every order through length six and cycles up to 64 commands,
with 449 exact duplicate no-op checks. The selected auxiliary sizes and node IDs
vary. Two kernel faults reject an epoch-changing duplicate and reuse of a retired
captured Set. [Validation](reviews/carrier-cycles-validation.json).

This is one source's Set-membership/representation protocol, before Core
settlement. It is not a status/readiness or once-only Promise/action/flight
accounting theorem. The generalized membership result is separate from the
earlier generalized frame/bounded-settlement result; a single combined full public
callback/controller/reveal theorem is still open. Global source-ID liveness,
arbitrary dependency topology and host fairness are not inferred.

Runtime/source/host and all prior domains/task budgets/kernel limits are unchanged.
No semantic deviation is active. Current mutations: 652 = 484 finite /168 kernel;
frozen633 completed on its recorded source pin, with nineteen later focused kernel
variants. A complete652 sweep is not claimed.
