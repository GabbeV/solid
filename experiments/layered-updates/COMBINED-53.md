# Stage 53: combined preparation without merging action lifetimes

The user accepted immediate combined preparation when a ready ordinary proposal
arrives while optimistic work is suspended. The result must hold both proposals
until their consequences are ready; it must not join the guessing action's open
lifetime. This ruling resolves the stage-52 `ready-lower-audit.mjs` question.

Implemented in the operational reference only. Main production sources and the
isolated `/workspace/layered-origin` adapter are unchanged in this stage. The
production port remains incorrect and must not be promoted. Stores remain out
of scope. No new performance, allocation, retained-heap, or bundle-size results
are claimed: the preceding reference representation failed performance against
pinned next, and these semantic changes do not establish acceptance.

## Mechanism and observable result

The reference keeps native layer contexts and action scopes. Separate edges
coordinate publication of proposals that now need a combined consequence.
An upper computation can consume a lower proposal admitted through those edges.
Every frame in the resulting publication group installs before cleanup and
callbacks; the guessing action can remain open after publication.

For `label = loadLabel(view(), ordinary())`, starting at `0, 0, "0:0"`:

1. Guess 1 starts label(1,0), holding the displayed values.
2. Write ordinary=10 starts label(1,10) immediately, still holding all three.
3. An old label(1,0) answer is ignored.
4. Label(1,10) publishes `1, 10, "1:10"` while the action remains open.

The public accessor audit confirms this result. Pinned next starts the combined
request too, but prematurely publishes ordinary=10 while label remains "0:0".
Its trace is evidence of the inconsistency, not an allowed outcome.

## Readiness includes displaced work

The first implementation incorrectly treated canceling an unfinished lower
calculation as making its update ready. That suppressed legitimate independent
optimistic progress. A sparse displaced-obligation record now preserves that
unfinished work after its candidate is canceled. It retains no second value,
owner frame, or live answer token. Preparing the lower work again replaces the
obligation; completing/disposal removes the record. Unobserved work does not
hold admission solely because a displaced record exists.

A same-handler audit found a second defect: if both updates were fresh, choosing
the upper context before preparing the lower one could skip the lower async
calculation and misclassify it as ready. New contexts are now introduced from
lower to higher layers before publication. Previously active contexts stay
eligible when later updates arrive, preserving the approved immediate-combined
case. This discovery phase does not publish intermediate results. An already
canceled lower answer cannot revive its old frame.

`combined-start-audit.mjs` compares same-handler writes with an explicitly
prepared lower update. The final reference preserves independent optimistic
progress in both cases and then resumes lower work. The audit records actual
next and prior-production behavior too; neither is a general correctness oracle.

## Validation and difference classification

`UNIFIED=1 node --test experiments/layered-updates/reference/*.test.mjs` passes
205 tests, including historical research tests. The new 21-case file checks:

- Immediate combined preparation for ordinary and optimistic lower proposals,
  reversed traversal, and both tracing/affected-node enumeration strategies.
- Committed snapshots in every publication callback and late-mounted readers.
- A lower open action closing independently of the guessing action.
- A separate lower async consequence delaying admission until it is ready.
- Expiration replacing combined work, stale answers, error/recovery, owner
  cleanup, and 30 repeated combined supersession cycles with drained records.
- Same-handler lower/upper arrivals versus an already-prepared lower update.

Four mixed-graph campaigns also compare current-model callback/snapshot traces
across enumeration strategies. These are finite checks, not a universal proof.

The old test requiring a later ready lower update to wait for optimistic work
was intentionally changed under the user's ruling; its historical-runtime
branch still checks the old sequential behavior. Stage-51 optimization replay
now explicitly compares the two archived stage-51 implementations. Those old
schedulers are not a semantic oracle for the newly approved arbitration. No
consistency assertion was relaxed to admit tearing. Initial lower-progress
failures were implementation bugs fixed by preserving displaced obligations
and preparing fresh lower work before fresh upper contexts.

## Unresolved: a joined lower proposal becomes pending again

The implemented publication edges persist until publication or correction.
That exposes a consequential question beyond the accepted two-update timeline.
`combined-rehold-audit.mjs` executes this public-API program against all three
runtimes:

```js
const [revision, setRevision] = createSignal(0);
const input = createMemo(() => revision() === 20 ? loadInput20() : revision());
const [view, guess] = createOptimistic(() => 0);
const label = createMemo(() => loadLabel(view(), input()));
// Initial label(0,0) is synchronous. Later labels use controlled requests.
```

The action stays open. Guess 1 starts label(1,0). Revision=10 causes the approved
combined label(1,10) preparation; it remains unresolved. Revision=20 then makes
input itself suspend, and the action makes a new guess of 2.

- Current reference and prior production retain the publication join. Neither
  starts label(2,0). They wait for input=20, start label(2,20), then publish
  `[2,20,"2:20"]` together.
- A revisable publication join could instead let the new guess calculate using
  committed input=0, publish `[2,0,"2:0"]`, and later coherently advance to
  `[2,20,"2:20"]`. It may require another calculation, but restores independent
  optimistic progress after the lower proposal becomes pending again.
- Actual pinned next already tore by publishing input=10 earlier. It starts
  label(2,10) and can publish `[2,10,"2:10"]` while input=20 is pending. It then
  tears again when input=20 arrives before label(2,20). Its mechanism allows
  optimistic progress, but its exact visible sequence is unacceptable here.

Recommendation presented: let a fresh guess regain independent publication when
that lower proposal becomes pending again, using the genuinely committed input.
This would make proposal-publication links revisable, separately from permanent
same-boundary action-lifetime coupling and ordinary peer entanglement. Await the
user's ruling before implementing that change. It is not silently classified
as an intentional semantic difference or a production-port failure.

## Artifacts

`results/combined-preparation-stage53/` preserves the before/after reference,
intermediate/final test logs, ready-input audit, same-handler audits, and renewed
lower-suspension audits. The main working reference has the stage-53 behavior,
including the documented unresolved persistent-publication-edge case.
