# Prepared render recomputation through a held read

The actual `RecomputePrepared` task now composes through its source body setup,
expression evaluation, `ReadNode` admission and the tracked held-signal read. Four
real `Core.step` calls reach the original `Finish` frame with the served value
on the operand stack. Every transaction record is retained, including its action
obligations. This is a local recomputation prefix, not publication or a completed
heap/flush theorem.

## Input and result

The initial World, source slots, other arenas, caller tasks/stack, captured lane
frame, create flag and released-list identity remain arbitrary represented data.
The initial certificate states:

- The ordinary same-flush held-read facts from `tracked-read-input`: canonical
  terminal source cache, initialized held source, healthy state, no active lane,
  and a non-verdict render reader that allows children.
- The source is a valid, non-lazy, non-override signal, distinct from the reader.
- Verdict dispatch is off and unflushed staging is false.
- The render's body is `Read(source)`.

The caller's context and tracking flag are unrestricted. The theorem derives the
body's computed reader and enabled tracking from actual setup; it does not assume
those values in the starting World. There is no successful intermediate World,
post-read certificate, numeric payload restriction, early reader extension or
pending-slot allocation premise. Distinct IDs permit preservation of all source
flags while the reader's flags/generation change; the two node-kind premises
already describe different kinds of node.

The source's original slots determine the answer using the existing strict and
SameValue netting rule, including signed zero and NaN. The target World includes
all setup stores, `Invoked`, actual graph linking, JOINED marking, conditional
`stagedRead` and the ReadValue diagnostic. The exact source `PassFrame` retains
saved caller context/tracking, previous value, status, flight, operand stack,
released list, stale state and lane locals. That `Finish` task and the untouched
caller suffix remain queued. Internal computation is distinct from releasing the
application callback or displaying output.

## Proof structure

`recompute-read-setup.bend` names a proof-only loaded form of the prepared-body
source segment. Its exact Machine equality is checked against the one runtime.
This includes dependency-tail reset, generation increment, recomputing flags,
time, current context, stale state, Invoked and tracking enablement. The runtime
is unchanged.

`recompute-read-metadata.bend` proves the setup's metadata frames using the
existing node-storage lens and lookup laws. It constructs the held-read
certificate afterward and preserves source validity, dispatch and staging facts.
The full source record is preserved for distinct IDs. `signal-read-admission`
then proves actual expression evaluation and non-lazy signal admission into
ReadPrepared. `recomputed-held-read` composes these with the previously proved
tracked read. All intermediate premises follow from the input certificate.

## Evidence and remaining connection

The constructor/write fixture starts with caller context zero and tracking
**disabled**, so setup must actually install both. Its initial certificate is
checked in Bend and the general theorem is instantiated with a nonempty caller
stack and task suffix. This is a non-vacuity example, not arbitrary public
reachability. Runtime-only closed oracles separately discriminate wrong context,
disabled tracking and a dropped Finish frame. Unchanged oracles pass; the three
compiled source-changing variants are rejected. An authoring error that referred
to nonexistent generated getters receives no proof or rejection credit.

The [receipt](reviews/recomputed-held-read-validation.json) records focused
checks. Only a matching completed independent whole-book seal in `checked.json`
establishes the composed checkpoint; resource failures receive no credit.

Construction of this starting instruction/certificate from the body-produced
HeapLoop through visitation, lane seating and teardown remains open. After this
prefix, Finish/recompute return and construction of the existing parking/landing
certificate are still required. Global group forests, live lists, once-only
settlement, arbitrary callback/async histories, publication safety and eventual
reveal remain separate goals. No source workaround or checker change is used.
