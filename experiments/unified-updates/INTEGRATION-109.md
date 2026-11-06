# Audit of expected scalar failures: incomplete reveal coordination

> Upstream status checked after this audit: #4071 was fixed by #4217 on
> 2026-10-22. Published 2.0.0-rc.21 passes the JSX timeline in Chromium.
> The failing next comparison below is the older pinned rc.14 checkout, not
> current next. Our experiment has not yet incorporated that upstream repair.

This follows [stage 108](INTEGRATION-108.md). No runtime change from stage 108
is retained in this checkpoint. It exposes a scalar correctness hole rather
than declaring the scalar migration finished.

## What was audited

Temporary copies of four existing test files ran with their expected-failure
markers removed. The resulting 126 tests produced 111 passes and 15 failures.
The copies were removed; the report is
`results/integration-stage109/expected-failure-audit.json`.

The failing cases include:

- F2: a superseded reveal publishes its control before its content can reveal.
- F1: nested re-armed Loading boundaries keep the outer fallback after its own
  work is ready, rather than revealing it beside the inner fallback.
- #3800: an async memo created inside a fresh Loading boundary can reveal its
  held input before that input's existing outside reader publishes.
- Twelve pre-existing Loading re-arm expectations. Their comments explicitly
  describe behavior deferred upstream; this audit records their failures, not
  a new ruling accepting or rejecting those expectations.

The other three signals expected failures exercise optimistic stores. The
runtime still explicitly rejects that API, so an expected-failure result there
is not useful evidence for the assertion the original test intended to reach.

## F2 reproduced against next

The ordinary graph is:

```ts
const [visible, setVisible] = createSignal(true);
const [id, setId] = createSignal(0);
const data = createMemo(() => request(id()));
const copy = createMemo(() => data());

createRenderEffect(visible, showControl);
createRenderEffect(
  () => visible() ? [id(), copy()] : null,
  showPanel
);
```

Controlled requests establish this sequence:

| Step | Correct control / panel | Current result |
| --- | --- | --- |
| Initial request 0 answers | true / [0, 0] | same |
| Hide; request id 1 | false / hidden | same |
| Reopen while request 1 waits | false / hidden | same |
| Set id back to 0; replacement request waits | false / hidden | **true / hidden** |
| Replacement request 0 answers | true / [0, 0] | eventually coherent |

An old request answering must not release the replacement reveal.
`stale-render-publication.test.ts` pins the complete render histories with
zero, one or three intervening synchronous memos, under scheduled and
unscheduled render effects. Pinned next passes the two direct-read cases and
fails all four memo cases. The candidate has the same result after removing
unsafe trials. Baseline test copies were removed after the comparison.

F2's existing expected-failure marker is removed. The four newly exposed
failing variants also remain ordinary failures. These assertions have not been
relaxed or hidden to preserve a green scalar count.

## Trials rejected

The current shared preparation pass revisits stale memo readers before a ready
input publishes, but leaves render readers for the post-publication replay.
Including render readers fixes F2 in the focused repro. It also exposes a
coordination problem: a reader combining separate ready outputs can alternate
between one proposal and the other output's committed value, repeatedly queuing
itself against the other update.

Forcing peer proposal consumption during preparation stopped those loops in
one trial but broke existing nested optimistic publication tests. Respecting
higher/lower contexts during that preparation still failed to converge. These
trials are not retained. Some early trials accidentally widened a separate
notification predicate as well; the isolated preparation-only and scoped-peer
reruns reproduce the relevant failures, and supersede those early results.
Temporary loop diagnostics, preparation read-rule changes and notification
changes have all been removed. `core/core.ts` and `layers/coordination.ts` are
byte-identical to the stage-108 checkpoint.

The useful conclusion is narrower than a proposed fix: a pending reveal's
publication obligation can be lost when a render computation returns to the
committed branch during replacement propagation. Replaying every render reader
as a proposal computation is not a validated solution. The next investigation
should follow that particular obligation through supersession and stale-frame
replay, including the same shape inside optimistic layers. Ordinary bundles
also need the fix; locating it only in an optional observation coordinator would
leave the ordinary-only import scenario incorrect.

No new semantic ruling is needed to reject `true / hidden`. Existing render
read posture and layer cuts must be understood before choosing the repair.

## Retained validation and acceptance

The retained source uses stage 108's pending restoration fix. Build, declaration,
Solid, DOM and bundle-size evidence therefore remains that checkpoint's. The
final full signals run is `results/integration-stage109/signals-retained.json`.
It reports 4,100 ordinary passes, 17 expected failures, 1,641 failures and two
skips (5,760 total). The failures are exactly the 1,636 deferred optimistic-store/
until cases plus F2 and four new variants of that same bug. The two new direct-
read controls pass. There are no other newly failing names. The generated rules
index is refreshed, and `failure-review-retained.json` records that separation.

Size is still 7,433 / 14,694 / 11,657 Brotli bytes for core / ordinary stores /
observations. The last is 1,965 bytes above pinned next and 1,927 above its cap.
There is no new performance claim. Stores remain unimplemented; scalar expected
failures and the newly exposed tearing must be addressed before treating the
non-store work as complete. Nothing was pushed or posted.

### JSX reproduction

`packages/web/test/stale-render-publication.spec.tsx` reproduces the same tear
using ordinary JSX, a button handler, 500ms sequence steps and 1500ms requests.
There are no manual render effects. The candidate's DOM is `Visible: true`
beside `hidden` one second after the click. The test retains the correct
`Visible: false / hidden` assertion and fails there. Its report is
`jsx-reveal-candidate.json`; the prior full web count predates this additional pin.
The JSX comparison attempt in the baseline could not load its test module in
this linked Vitest workspace; only the earlier primitive comparison establishes
next's behavior. Temporary baseline files/configs were removed.

### Confirmed loss of the reveal hold

`reveal-cause-trace.log` records a temporary instrumented run of the reduced
scalar graph. At replacement: data computes 0; the initialized render reader
releases its old hold; its read of visible serves committed false despite the
held proposal true; it computes hidden and clears pending. Update 3 then judges
ready and lands visible=true. Only afterward does the reader replay with true,
suspend on the replacement, and enter update 4. The old answer publishes nothing;
the replacement eventually releases update 4. This confirms loss of the old
reveal obligation, rather than an obsolete answer publishing. All instrumentation
and the temporary trace test were removed after the run.


### Current upstream verification

The exact defect is already [issue #4071](https://github.com/solidjs/solid/issues/4071),
closed after [PR #4217](https://github.com/solidjs/solid/pull/4217) merged on
2026-10-22 (merge cdd95616857ef1d54f3e2ec88a87ba6ca40de765).
The pinned baseline a24e911b predates it. Registry `next` currently resolves to
2.0.0-rc.21. An isolated build using published rc.21 signals, Solid, web and
compiler packages, run in Chromium with real timers, gives:

| Time after click | Visible | Panel |
| --- | --- | --- |
| 50 ms | false | hidden |
| 600 ms | false | hidden |
| 1100 ms | false | hidden |
| 1700 ms | false | hidden |
| 2700 ms | true | 0 / 0 |

No browser errors were recorded. Source and observations are retained as
`results/integration-stage109/jsx-reveal-rc21.tsx` and
`jsx-reveal-rc21-browser.json`. No duplicate issue or PR was filed.

The upstream fix commits values at landing, but defers the held effect queues
until the round where stale readers recalculate. A new suspension parks those
callbacks with that round. Its compatibility with this experiment's unified update
publication and outside-read semantics still needs validation; no runtime fix
was applied during this upstream-report investigation.
