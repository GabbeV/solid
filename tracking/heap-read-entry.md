# Heap render read entry

These operation contracts support the changed reader's crossing after the joined
body reaches `HeapLoop`. They do not yet compose that whole crossing or construct
the post-render settlement certificate from arbitrary body histories.

`graph-link-frame.bend` proves that actual `graph.link` preserves every represented
field except the four dependency/subscriber pointers in node records, the link
arena and the epoch. The proof includes fresh allocation, both intrusive-list
branches, duplicate suppression and generation-stamped reuse. It quantifies over
arbitrary Worlds and IDs, including aliases; it requires no successful result,
acyclic graph or allocated-slot premise. This is a frame property, not a claim
that invalid IDs form a meaningful public graph.

`heap-frame-read.bend` proves that actual `frameRead` returns the input World and
`false` when the input cache already names a terminal current flush group, no lane
pass is active, and the reader is not a verdict. Both the cold shortcut and the
transaction lookup branch are covered. `txOf`'s real lookup/store executes; its
canonical store is proved to be an identity. No post-read equality is assumed.

`heap-render-join.bend` proves that `joinPass` on a render and an initialized source
only adds `REACTIVE_JOINED` to the reader. It performs no transaction join/adoption
or obligation change. Flags retain the initial source status and reader kind even
when IDs alias. `heap-held-read.bend` composes these contracts for actual
`enterRead(..., false)`: a positive render reader, held initialized source, allowed
children, ordinary same-flush posture and canonical terminal cache yield exactly
the marked World and `false`. Arbitrary payloads and ambient arenas are retained;
this contract introduces no natural-number payload restriction.

The four roots in `LAWS.bend` expose these input facts explicitly. The next caller
composition must derive the graph/cache/posture facts, execute tracked linking,
select/serve the staged value and complete recompute before deriving parking.
These helper roots do not establish the full `readSignalFast` result, public graph
reachability, global group accounting, or eventual reveal.

A crucial observation boundary remains: pure render computation can update an
internal node's proposed value and append `Invoked`/`ReadValue` diagnostics before
its application callback is released. Use the selected rendered text and `Applied`
observation from `rendered-observation.bend` for the publication goal. An all-node
value or all-event equality would assert more than the source promises.

Three runtime-only negative probes cover reuse erasing a pending value, render
joining another group, and forcing committed output after a successful held join.
The unchanged probes pass and all three compiled mutations are rejected. The first
attempt imported the broad generic graph book and exceeded diagnostic output on
the failing term; that attempt receives no rejection credit. Small closed oracles
keep diagnostics bounded without changing the checker budget or generic theorem.
