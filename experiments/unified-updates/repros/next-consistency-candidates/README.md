# Current-next consistency candidates, 2026-11-11

The user submitted these reports as [#4775](https://github.com/solidjs/solid/issues/4775),
[#4776](https://github.com/solidjs/solid/issues/4776),
[#4777](https://github.com/solidjs/solid/issues/4777), and
[#4778](https://github.com/solidjs/solid/issues/4778), respectively for guess,
latest, read-order, and pending. Each directory retains the original draft and
prefilled form as receipts. These repros use upstream next
`bcef1041cb50bf648da5641693b5ebdea1fc5dc2`, served by the playground's
mizulu/solid2 commit build, development mode. They do not import the experiment.
All four hosted URLs were run in Chromium; final DOM assertions passed,
commit-build requests returned 200, and no page errors were observed.
Each repro has one Run button and remains at the interesting state.

## Candidates

1. **Second guess leaks to an ordinary reader.**
   [Repro](https://s.olid.uk/id/vV13_EpDRkmxDyr_SxCX5w).
   Guess 1 publishes. Guess 2 starts an unresolved downstream calculation.
   An independent tick then reruns a JSX binding: it reads 2 while the memo
   combining the same optimistic output with its async copy still shows 1 / 1.
   No latest or deferred boundary is used. This is the original F5b defect.
   A memo around the tick reader holds instead; the ordinary JSX binding is
   sufficient to expose the disagreement.

2. **A latest memo and its ordinary consumer disagree.**
   [Repro](https://s.olid.uk/id/TGWeOejGTtm1iey2r2WBtg).
   The action proposes ID 2 and filter 1, staying open. A memo of latest(id)
   publishes 2 while its ordinary consumer combining it with filter still
   shows 1 / 0. The ordinary ID and filter remain 1 and 0. The question concerns
   consistency downstream of the explicit latest boundary, not latest differing
   from its input. A separate signals probe with latest inlined in the pair
   instead shows 2 / 0. That inline comparison is not an extra hosted variant.

3. **A memo wrapper changes an async pending derivation's result.**
   [Repro](https://s.olid.uk/id/qQD8AdR-Q3SrhaZVOyl0gA).
   Both presentations have previously returned promises. Direct isPending(id)
   stays false; reading createMemo(() => isPending(id)) produces true. Both
   asynchronous presentations finish their 500 ms work during the same open
   action. The live pending binding is true. This should be a focused contract
   question/follow-up to #4677, not an assertion that every direct async
   isPending exception is accidental. The producer clause in the upstream
   optimism-seam-spike-brief explicitly exempts previously async readers from
   that optimistic execution; the wrapper exposes a composition consequence.

4. **One calculation reads an unchanged signal as both 1 and 0.**
   [Repro](https://s.olid.uk/id/htrvK-9uQ2Sg5fYRAndmSA).
   Enable a previously synchronous memo while an ID update remains held.
   It reads id(), latest(id), id() synchronously and starts async work using
   arguments 1, 1, 0. The request log is copied to a signal by the event handler
   after another 500 ms; there are no signal writes in derivations or effects.
   The inconsistent calculation's result remains held, so this is a request
   input consistency issue, not a claim that that result reached the DOM.
   A first attempt using a newly mounted Details component under Show read
   1, 1, 1 instead and is deliberately excluded.

## Existing-report and change checks

Searched Solid issues by accessor, wrapper, repeated/second guess, unrelated
reader, read order, the original playground ID, and F5b. Related closed reports
include #4284 (explicit latest of a held guess / JSX grouping), #3457 (sync
pending wrapper), #4677 (pending and async badge), #4398 (grouped pending
readers), and #4698 (mixed Loading on). None is an exact currently open report
identified for the first, second, or fourth repro. The third belongs in the
context of #4677 rather than being presented as unrelated.

The earlier incoming-error candidate was retested and dropped: next now keeps
an active guess over the rejected input until the action ends (#4753).

If issues are subsequently approved, keep them standalone. Include at most a
short provenance note linking to
https://github.com/GabbeV/solid/tree/experiment/unified-updates.

## Receipts

Each directory contains source, immutable playground payload/URL, save receipt,
and browser DOM samples. No runtime core files changed. The scratch public-API
probes additionally confirmed the repeated-guess failure, the latest wrapper
comparison, the direct/wrapped pending difference, and the discovery read
sequence on the pinned unmodified next checkout. Expectations tied only to
experiment semantics are not counted as upstream bugs.
