# First-proposal experiments: reject incomplete store transfers

No runtime changes from this stage are retained. The branch still uses stage
132's runtime. Both #4429 scalar failures remain open.

## What the trials established

Allowing latest to select a ready held first proposal repairs #4429 and the
scalar replacement timelines. An optimization then preserves already-computed
consumers when an observation selects the identical value in its new update.
That optimization cannot treat a derived store's producer value as its whole
proposal: its property and structural writes are separate nodes/backings.

Several approaches were tested and rejected:

1. Recompute store producers instead of preserving their old calculation. This
   fixes the synchronous seed leak but still exposes the seed with an async
   store producer and a sibling holding the input. It is insufficient even as
   a conservative fallback. The stronger async tests were not weakened.
2. Transfer the producer's existing family nodes with it. This permits early
   coherent synchronous publication. A replacement also needs its notifications
   to carry the newly assigned holder: store writes currently notify before
   `holdWithDerive`, which can make a consumer join the lower flush accidentally.
   Re-notification fixes that replacement timeline.
3. Include backings that used node-less staging, using the existing fold list.
   Without this, an async derive can have written its draft but have no nodes
   in the family's live-node index: transferring that index misses the data.
   Materializing ownership for those backings makes the synchronous/async
   structural timelines pass. The focused run reached 602 passing cases.
4. Reject that transfer nevertheless: it also moves an independent manual
   store write belonging to an open action. The screen publishes `1:true`
   while the action's ordinary signal remains 0. Current next and the retained
   experiment hold that manual write correctly. A family's pending backing
   is not necessarily all authored by the producer being moved.
5. Earlier selection inside the observation calculation, or immediately before
   it, did not establish ownership before all relevant work. These trials
   still leaked seeds; the latter also looped in scalar cases and was stopped.

The central missing model is ownership of a store producer's writes when its
calculation changes update contexts. Moving the producer alone, moving every
family write, and replaying the producer are each insufficient. This needs to
be solved at store publication, including manual writes and node-less staging,
not hidden behind an input-readiness condition. Optimistic stores remain
unimplemented; these probes use ordinary derived stores.

## Retained regression coverage

- #4355's twelve cases now also run with an async producer: **24 tests**, with
  unchanged no-seed and exact final-publication assertions.
- Two new manual-write tests cover an existing property and a newly added key.
  Latest of the async input must not publish the action's separate manual
  write before that action ends. Final publication is also required.
- All **26 guards pass on pinned next `4fe75321`** and the restored experiment.
- All unified suites plus the guards: **608 passed, no failures**. Rules index
  passes. Source diff confirms all trial runtime changes were removed.

The stricter early-publication and replacement timelines are archived as
unresolved probes; they are not relabeled passing or made less strict. Next
passes the first-store early-publication guards but differs on the scalar
first-proposal replacement timeline (it retains the earlier value longer).
The broad transfer trial had no new old-suite failures and repaired #4429,
but the new counterexamples invalidate it. That run is not final validation.

The last full signals inventory is still stage 132: 5,214 passed, 2,114 failed,
2 skipped, before these fourteen added guards. The last full web inventory is
stage 130. No full-suite count, size reduction, or performance improvement is
claimed for this investigation. Shipped runtime, size and performance remain
unchanged. Results and rejected implementations are archived separately in
`checkpoints/integration-stage133.tar.xz`.
