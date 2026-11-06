# Pending badge retirement: supersession accepted

No runtime or existing test expectations changed during this investigation. Stage
125 remains the retained checkpoint. Four failures in
`ispending-async-derivation-4677.test.ts` prompted this comparison. All four
original tests pass on pinned next `4fe75321`.

The program has an ordinary `id`, an async details memo over it, and an async
badge over `[id(), isPending(id)]`. The initial `0:false` badge is synchronous.
Four independent JSX bindings render id, details, pending and badge. The
ordinary details request finishes before the pending badge request.

A real JSX probe, using a normal button and controlled promise gates, gives:

| Event | next | Experiment |
| --- | --- | --- |
| Initial | `0 / Item 0 / false / 0:false` | same |
| Navigate to 1 | unchanged | unchanged |
| Details answer Item 1 | unchanged; waiting for pending badge | unchanged; starts correction badge |
| Pending badge answers 0:true | `0 / Item 0 / true / 0:true`; starts correction badge | unchanged; the answer is superseded |
| Correction answers 1:false | `1 / Item 1 / false / 1:false` | same |

Next asks `0:true`, then `1:false`. The experiment asks `1:false`, supersedes it
with `0:true`, then asks `1:false` again when details finish. The first extra
request is a separate cost/discovery issue: it is observed, not hidden by
resolving only the latest promise or claiming request-count parity.

The scalar controlled timelines also exercised the reverse order. When the
pending badge answers first, the experiment publishes pending and its badge
together while keeping id/details at 0. After details answer, correction holds
the whole ordinary publication until the final badge answers. Resolving the
superseded initial ordinary badge does not publish it. Both orders finish with
the coherent final frame, and the request count is three in the tested shape.

This appears to follow the accepted rule that an active override cuts input
value demand, and that unfinished optimistic work need not finish before its
restoration starts. However, upstream's #4677 regression explicitly pins the
parent waiting for the pending badge, and this changes which intermediate
frame is observable. The scope of that earlier ruling is therefore being
confirmed before migrating these four expectations. Recommendation: keep the
experiment's supersession behavior; do not hold the input merely to finish an
obsolete pending badge. Preserve the independent requirement that pending and
its badge never publish inconsistently.

**Decision:** the user accepted this recommendation: optimistic derivations
must not define their own lifetime. Stage 127 migrates the regression to
coherent publication and immediate correction, including leaving the obsolete
pending request unresolved through the final commit. The historical analysis
below explains why next's intermediate-frame assertion was not retained.

## Intent audit: the regression test is not itself a ruling

The user challenged treating #4677's intermediate frame as a requirement.
The issue asks for consistency, not for that intermediate frame to occur.
The following evidence must be distinguished:

- The wait **predates** #4677's fix. The issue's rc.20 timeline already waits
  for the pending-true badge before starting correction. The fix in
  `6b7474b2` restores a voided pending binding alongside the badge and holds
  ordinary landing effects for correction; it does not introduce the
  `lanesBlocked`/`nestedBlocked` parent-waits-for-child rule.
- [PR #4687](https://github.com/solidjs/solid/pull/4687) expressly says
  "Ruled screen (reading A, confirmed with the maintainer)" and lists the
  intermediate pending-true frame. This is the strongest evidence for this
  exact behavior, but it is a Tembo-generated report of confirmation. The
  public PR discussion contains no direct Ryan explanation establishing
  that obsolete work must finish before correction starts.
- F-6 was amended by `d1b938d3` on October 28 to say the parent waits for
  lane flights, citing an October 1 maintainer ruling and older tests.
  That documentation commit is co-authored by Claude/Cursor. Its cited
  `lane-contract.test.ts` case is explicitly a **matching confirmation**.
  The original "pending source does not leak" test (`402f87e0`, February 7,
  co-authored by Cursor) likewise receives a matching answer. These cases
  justify retaining useful work, not waiting for a superseded answer.
- The very next lane-contract test abandons an unfinished guess when the
  input answers differently, then holds for the correction. The reported
  Ryan ruling in [#3331's resolution](https://github.com/solidjs/solid/issues/3331#issuecomment-5632493645)
  likewise says a new differing source value removes optimism immediately.
  That quote is relayed by Claude, not independently available as a direct
  public Ryan statement in the retrieved discussion.
- [#3427's resolution](https://github.com/solidjs/solid/issues/3427#issuecomment-5669896555)
  is closer to the lifetime question: when the action bodies and input work
  finish, start correction without waiting for obsolete optimistic work;
  retain the displayed frame until correction commits. This is also
  explicitly signed "Claude via Cursor". It supports the experiment's
  direction, but does not independently settle how pending companions
  should behave.

No direct public Ryan statement specifically requiring an obsolete
pending-true derivation to finish was found in the issue/PR discussions
searched. The secondary sources conflict in scope; neither tests nor an AI
summary should silently settle that scope. This audit does not change runtime
or test expectations. The proposed migration would preserve no-tearing
assertions in both completion orders and separately test supersession; it
would not require a never-shown pending frame to finish just to be discarded.

Receipts are under `results/integration-stage126/`. `badge-jsx-probe.tsx` is the
shared executable comparison; to run it, copy it under `packages/web/test/`
and use the normal web configuration, or the archived next-alias config copied
under `packages/web/`. The native compiler path is the same as stage 125. The
probe imports render and compiler helpers from the same packaged web runtime.
An initial attempt mixed source render with packaged delegation helpers, so
its button did not dispatch; those failed setup runs are not comparison evidence.
No source changes to next or external changes were made.
