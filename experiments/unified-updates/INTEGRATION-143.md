# Landing-observation triage and the latest branch decision

No runtime change is retained. Six #4648 landing expectations now follow the
accepted shared-context rule. A second flight that keeps the ordinary update
open permits the pending observation to publish `{v:0, inner:0, p:true}`;
render and user effects then publish `{v:5, inner:5, p:false}` together.
Both read orders and same-pass/sibling/deep-sibling arrangements agree. The
four completed-update controls remain unchanged. These are test migrations,
not six new runtime fixes.

## Rejected mount trial

Stage 142's diagnosis of the initial callback failures was incomplete. Adding
`type &&` to runEffect's holder guard alone changes none of the failures:
the first answer is already staged and effect creation never calls the runner.
Applying that first staging before an unscheduled render callback runs changes
the born-held rule as well. The broad trial has 72 failures absent from stage
141, including two newly added diagnostic cases and three stale rules-index
checks. Many fixtures use an unscheduled callback as a publication oracle, but
that is not sufficient justification for changing all of their contracts.

The six proposed detached DOM controls pass on next. The trial passes four;
its latest cases initialize detached text to `1/0`, then update to `1/1` at
publication. It does not reproduce next's first calculation. The trial and
diagnostic tests are archived and removed from the source tree. Both runtime
edits were restored exactly. Initial-callback/first-answer classification is
still open; this checkpoint does not silently loosen the born-held rule.

## Independent input audit

Diagnostic copies of #4336 continued through all scalar assertions. Nine
failures follow stage 120's accepted independent input/override lifetimes:
navigation can publish issue 1 while the comments override still contains the
guess made on issue 3; an optimistic navigation's revert leaves that same
override selected; eventual correction uses the current input. This is a
deliberate boundary policy, not disagreement among readers of the output.
The mixed scalar/legacy-store fixture is not migrated yet. Its pending/latest
probe case remains separately untriaged; the lifetime ruling alone does not
classify every assertion in that case.

## Decision needed: leaving a latest branch

The experiment and pinned next 4fe75321 differ on #4661:

```tsx
const [filter, setFilter] = createSignal("open");
const list = createMemo(() =>
  filter() === "open" ? [1, 2, 3] : fetchClosedList()
);
const count = createMemo(() =>
  filter() === "open" ? latest(() => list().length) : -1
);
// Render filter and count outside Loading; list inside Loading on={filter()}.
```

After switching to closed, while fetchClosedList is pending:

| Runtime | Filter | Count | Loading |
| --- | --- | --- | --- |
| Next | closed | 3 | loading closed |
| Experiment | closed | -1 | loading closed |

Both finish with closed / -1 / 9. JSX probes verify the original async-first
shape and the smaller synchronous-initial-value shape, each with and without
an ordinary filter binding. Adding that binding does not change the result.
The comparison uses the same web renderer and compiled JSX with each runtime's
built signals package. No proposed result is asserted as the new contract yet.

PR #4663 explicitly records the maintainer's 2026-11-03 ruling: “It should
read the committed value, we can't reveal early outside of latest. This is
intentional tearing.” The generated description deliberately differs from
#4661's initial expected table. It describes retaining a previous latest
reader's old branch and suppressing its rerun at the input commit; the pending
list's eventual answer wakes it instead. The public issue has no comments and
the fetched PR discussion contains no separate human confirmation of the quote.
The evidence is a recorded ruling in the AI-generated PR, not merely a test.

Recommendation for the shared model: publish -1 with the closed filter. This
branch no longer reads list, so that request should not keep its result stale.
Keeping next's delayed count would preserve an additional legacy observation
rule. Await the user's decision before migrating these four scalar/JSX pins.

## Validation and remaining scope

- Full retained signals run: **5,322 passed, 2,097 failed, two skipped**.
  Compared with stage 141, there are no new failures. Sixteen expectations
  were migrated across stages 142 and 143. All **658 unified tests pass**.
- Focused observation/rules checks: **37 passed**.
- Expanded retained JSX selection: **93 passed, five existing failures**:
  four synchronous latest calculation-count assertions and one deferred
  optimistic-store case. This is not a full web/hydration run.
- Restored runtime built successfully. Property mangling, both purity checks,
  rules index and diff checks pass. No performance or size claim.
- The refreshed signals inventory has 1,953 deferred-API failures, 117
  untriaged, 12 calculation expectations, nine accepted lifetime differences,
  four known implementation bugs and two latest-branch semantic questions.
  The web entries retain the older full-web inventory, with the two #4661
  questions reclassified. These categories do not establish that every other
  failure is already understood or that every calculation difference is safe.

Full reports, rejected trials, diagnostic sources, next/experiment JSX traces,
upstream discussion evidence and the inventory are in integration-stage143's
immutable checkpoint archive. Runtime remains stage 141.
