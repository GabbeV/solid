# Order audit of the pending snapshot reproduction

Run `node check.mjs` in the investigation workspace. The script imports the
unchanged next development build at 4fe75321; next 45648f78 has identical
runtime source. The absolute import is deliberately explicit about that
baseline. No experiment runtime is used.

This runs the repro's scalar graph with scheduled render effects as publication
observers and controlled completion of the data request. Separate event-loop
turns replace the example's 500/1500 ms delays while retaining the sequence:
initialization, id write, revision write during the hold, data completion.
The async reader uses only the async keyword, with no await in its body.

The 11,520 combinations comprise:

- All 60 valid orders of the five memo declarations. The pending wrapper must
  exist before its reader is constructed.
- All 24 orders of the live bindings and three sample-reader bindings. Within
  the live group the id, data, and pending bindings retain their order.
- All eight independent before/after choices for the untracked probe versus
  the ordinary id read in each of the three sample readers.

All cases produce the same phase snapshots and the same value-change sequence
for each publication observer, including the final direct=1/1/false,
wrapped=1/0/true, async=1/0/false results. Consecutive identical callbacks are
collapsed for this comparison: this is a value/publication audit, not a claim
of equal computation counts or sibling callback order. Earlier browser traces
show differing intermediate calculations and counts for reordered declarations.

This finite matrix does not establish order independence for other graph
shapes, conditional dependencies, late mounts, or different update timelines.
`results.json` records the single observed publication variant and one complete
calculation trace, plus its frequency across the matrix. It does not contain
all 11,520 calculation traces.
