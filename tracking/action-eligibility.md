# Empty completed groups reach actual blocker eligibility

This follows the [both-completion checkpoint](action-completion.md), published at
`c0d0ac2973a0d4cd62fdd5b222ffa797b8342515`. It changes no runtime, source pin,
representation, host adapter, kernel or semantic deviation.

`transaction-empty.bend` proves a general contract for actual `blocked`: a healthy
World's selected transaction with zero open actions, an empty owned-node list,
ordinary (non-lane) identity and no live lanes returns false. The **entire World**
and saved judge are preserved. The source path takes four blocker tasks and fits
the public helper's existing constant budget prefix; no extra budget premise is
assumed. The selected identity need not be index one, and the saved judge may
already be nonzero. This is a conditional helper law, not global reachability.

`action-pair-eligibility.bend` supplies the selected record's zero count, empty
nodes and ordinary identity from the checked actual construction, join and both
completion prefixes. Initial health and an empty live-lane list remain explicit.
Construction, count writes, retirement and scheduling preserve that ambient
condition. The resulting `Eligibility` certificate contains both the complete
completion certificate and the actual false blocker result with exact World
preservation, for either join/completion direction and arbitrary finite pair
lookups/rejoins before, between and after completion. It does not require a
supplied count, capture, resolver bound or final blocker result.

This closes the no-owned-node/no-live-lane eligibility branch. Actual generator
slices and signal writes can add owned nodes, flights and lanes; those branches
are still open in the joined-action publication theorem. This does not say that
zero action debt suffices in general, nor that eligibility itself publishes a
rendered value. Callback completion admission, global forest/live-list validity
and fairness retain the limits stated in the preceding checkpoint.

Validation adds 48 paired private empty-group judgments at different allocated
positions/join directions/previous judges, preserving every World field. The
48 native-generator/public graph controls also verify final native eligibility.
The existing 320 positive judgments remain passing. One focused source mutation
that invents a nested blocker is rejected by the independent kernel; configuration
is 588 (469 finite /119 kernel), without a new complete-sweep claim.

See [the receipt](reviews/action-eligibility-validation.json). No new Solid bug
or runtime workaround was introduced; #4248 remains separate and open.
