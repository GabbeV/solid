# Pending traversal shape and links

The actual pending traversal now retains a second independent footprint: every
node's kind, configuration and downstream subscriber head, plus every intrusive
link record. Status, time, extension allocation, heap flags/queues, transaction
records and source sets may change. Payloads and Worlds remain arbitrary. This
is not a complete graph-validity or source-Set uniqueness invariant.

`subscriber-topology-frame.bend` supplies field/list lenses. The heap, pending
source and transaction operation proofs instantiate those lenses over the actual
runtime. `pending-topology-frame.bend` then proves the footprint through actual
callback-free settlement, retry and traversal helpers, including faulted inputs.
`core-pending-topology.bend` bridges the actual machine steps. The same permitted
prefix certificates and body classifier used by content safety are retained.
`pending-prefix-frame.bend` factors reusable induction over an observer and a
concrete input-step law; the topology-history entry instantiates that law with
the checked actual core operations. No desired output frame is a root premise.
Selected node and link read corollaries recover their original shape at any
certified body-prefix boundary.

`pending-machine-shape.bend` derives the actual settled node's control fields.
Without auto-disposal, settlement preserves the prior release list. For a leaf
with zero subscriber head and no auto-disposal, it returns an exact machine shape:
the actual computed World, a zero-cursor walk followed by the original tasks,
the node prepended to visited, the previous release list and the actual scheduled
bit. Output World/flags and those task equations are derived, not assumed.
Existing prior releases remain; the theorem does not discard callbacks or promise
that an arbitrary release list is empty. Input health is not required for these
helper/shape laws, and successful whole-traversal health is not claimed.

Seven roots extend the earlier 493. This checkpoint changes proof/support tests
only; the runtime, source pin, host, original theorem domains/step budgets and
checker limits remain unchanged. No semantic deviation is active.

## Evidence and next obligation

The existing 240 paired histories still pass, with 2,280 selected observations.
On their forked snapshots, 1,280 actual pending-body steps retain this footprint
and 80 real leaf visits derive the expected zero walk/visited/release fields.
The source graph/head premises for a future one-edge completion theorem remain
local contracts; full public construction, general finite-graph completion,
owner callbacks and coordinated flush/reveal are not proved by this checkpoint.

All 500 composed roots pass. Three deliberate metadata corruptions are rejected
by the independent kernel: status update drops a subscriber head, heap flag
update clears configuration, and extension allocation changes node kind.
Configured totals are 630 = 483 finite /147 kernel; this is not a complete630
negative sweep. The separate complete619 receipt remains tied to its frozen
4975adf2 source/harness inputs. [Receipt](reviews/pending-topology-validation.json).
