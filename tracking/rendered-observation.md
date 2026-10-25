# Selected renderer text and application observations

This extends `ce91eb27` with eight roots, retaining all earlier 470 roots and
their domains. The runtime, source pin, representation, kernel and limits are
unchanged. A separate [list ABI correction](list-abi.md) repairs private controls.

## Observation and positive laws

`rendered-observation.bend` observes the text values of named mechanical tree
slots and the application events of named renderer IDs, retaining arbitrary
represented values and previous values. It does not observe all cache slots,
other renderer events or independent targets. The fixed-graph milestone assumes
its targets remain mounted; mount visibility/removal and arbitrary callback
side effects require separate contracts. This is not a complete DOM observation.

Two positive laws tie the observation to actual operations: writing a selected
text target exposes exactly the supplied value, and recording a selected renderer
application appends that exact event and payload. Preservation cannot pass merely
by returning an empty or constant observation. Generic actual sparse/existing-list
lookup lemmas support these results; sparse extension is not treated as allocation.

Other-target text writes and other-renderer application events retain the selected
observation, given actual ID disjointness. Arbitrary node-record storage alone also
retains it: storing computation data is distinct from applying rendered content.
The prior stronger committed-storage/tree/trace frame implies this projection.
Its premise is discharged in the actual ordinary/default async-arrival bridge;
no custom comparator or override is admitted by that existing prefix theorem.

## Actual independent application

`rendered-independent-apply.bend` checks actual `Core.step` at `ApplyEffect(id)`.
If both its renderer ID and its mechanical target are outside the selected IDs,
that step retains the selected observation. It covers both healthy dispatch and
fault unwinding. The real event and text stores run in source order. A configured
callback is queued by the step and is not executed by this law. The theorem does
not prove that the scheduler eventually reaches the step, or that arbitrary
callback bodies remain independent.

Disjoint IDs are input graph facts; construction and preservation of those facts
through the full joined-action history remain separate. These operation contracts
therefore enable independent publication in the larger proof without claiming
that the complete publication invariant is established.

## Executed evidence and harness repair

The existing 240 paired native-generator/Bend scenarios still pass in all six
completion/flight arrival orders. Their 2,280 observed public prefixes now check
both mechanical text targets against the native renderer results. The independent
fixture explicitly uses target 3, separate from the selected target 2.
On 80 zero-debt pending snapshots, a forked actual independent application records
an application, applies the committed independent value, preserves a canonical
nonempty caller stack and leaves the selected text/application observation intact.
The private fork is not installed in the public history and is not claimed to be
native private-step equivalence. All 160 accepted fulfillment forks still execute
1,360 actual steps, including all 40 no-stale owner trims, to their queued flushes.

That independent-application check exposed `HARNESS-LIST-ABI-001`: handwritten
Cons lookalikes passed the lenient decoder but were not emitted Con lists. The
host now derives encoding from actual constructors and strictly checks list tags.
All four affected private-control files use it. The complete public and alignment
commands pass again. Seven finite variants in the older frozen608 sweep depended
on those files; the historical receipt now carries that exact caveat. Typed proofs
and its 128 kernel negatives are unaffected. A fresh corrected sweep supersedes
the affected finite evidence; no complete current sweep is claimed before it ends.

Four new kernel negatives drop or misdirect a text write, misdirect an independent
application, or misattribute its event. All are rejected. Current configuration is
619 = 480 finite /139 kernel variants. Resource failures are never credited.
No new upstream Solid bug or semantic workaround was found.

See [the validation receipt](reviews/rendered-observation-validation.json).
