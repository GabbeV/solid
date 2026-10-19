# Candidate: a successful held recovery is later thrown as an error

Status: reduced current-head upstream bug candidate. No report or workaround is
active. Both pinned TS and Bend preserve this baseline. This does not block work.

Minimal JSX playground, created at the user's request:
[held-recovery repro](https://s.olid.uk/id/df_wYAiPRlmgfLmezgxTag).
It reduces the graph to one signal and two memos; JSX supplies the combined
rendered read. Three manual clicks start the pending/failed update, recover,
then resolve the native Promise. The final click throws the successful value 1
and leaves `Sum: 2` instead of showing 3. Removing the throw is a passing
one-line control. No explicit effects, flushes or timers remain in the component.
The share pins `mizulu/solid2@d2ad8b28`, with Tailwind and SSR disabled. Source,
local development/production and hosted browser evidence are in
[`repros/playground`](../../repros/playground/README.md).

A standalone native-Promise repro is now in
[`repros/solid-signals`](../../repros/solid-signals/README.md), using only public
imports from `@solidjs/signals`. On the exact next source below, it renders `[2]`
and throws the successful value 1 (or 7); its no-error control renders `[2,3]`.
Unlike the older matrix below, it uses the native Promise directly; a Node
`unhandledRejection` listener observes Solid's failing callback without wrapping
the Promise or its handlers. Each repro asserts intended recovery and fails.

**Version distinction:** the published npm `@solidjs/signals@2.0.0-rc.15` has
gitHead 4937f0a2bfddd45a65738c189075aff577530073, not the next commit below.
It halts on the original error 99 before recovery is reached; it does not
reproduce the specific successful-value-as-error schedule. Use the standalone
project's `npm run use:next` to install the unchanged current-next public index.
Do not identify the affected source solely by the shared rc.15 version string.

Source: Solid next d2ad8b288886a5c7171e6746ccc019ad1d08d8ab,
@solidjs/signals 2.0.0-rc.15, production full-index bundle. A read-only remote-head
check on 2026-10-19 returned the same commit.

## Observable program

A render initially sees b()+a() = 1+1 = 2. One flush makes b pending and a throw 99;
the frame is held. Before b settles, a recomputes successfully, returning 1 (or 7).
When b later returns 2, the tracked reader throws a's successful value as an error.
The renderer halts and stays at 2 instead of showing 3 (or 9).

```js
import { createRoot, createSignal, createMemo, createRenderEffect,
         flush } from '@solidjs/signals';

let finish;
const request = new Promise(resolve => { finish = resolve; });
const seen = [], escaped = [];
// Observe the engine callback's otherwise-unhandled rejected continuation.
const pending = { then(yes, no) {
  return request.then(yes, no).catch(error => { escaped.push(error); });
}};

const app = createRoot(() => {
  const [mode, setMode] = createSignal(false);
  const [stage, setStage] = createSignal(0);
  const b = createMemo(() => mode() ? pending : 1);
  const a = createMemo(() => {
    const s = stage();
    if (s === 1) throw 99;
    return s === 2 ? 7 : 1;
  });
  const c = createMemo(() => b() + a());
  createRenderEffect(c, value => void seen.push(value));
  return { setMode, setStage, c };
});
flush();
app.setMode(true); app.setStage(1); flush();
app.setStage(0); flush(); // successful recovery to 1, before the hold lands
finish(2);
// After current microtasks: seen is [2], c() throws a status wrapper whose
// cause is 1, and [REACTIVITY_HALTED] reports 1. Expected seen [2,3].
// Using setStage(2) for the recovery instead throws 7; expected [2,9].
```

Mutations occur outside root construction, avoiding promoted creation-time writes.
The callback returns void; no invalid effect cleanup value confounds the case.
No boundaries, stores, guesses, actions or private-source rewrites are involved.

## Paired evidence

Run `node tests/upstream/staged-error-recovery.mjs --json` after building. Eight
source-only controls run the same graph with immediate and native delivery:

| Scenario | Source result after b resolves 2 | Render values |
| --- | --- | --- |
| No error during the hold | returns 3 | [2,3] |
| Error 99, no recovery | throws cause 99 | [2] |
| Error 99, then successful 1 before landing | throws cause 1 | [2] |
| Error 99, then successful 7 before landing | throws cause 7 | [2] |

16 differential histories also compare exact node state, flags/proposals, wrapper
identity/cause, callbacks, text/reports and halts. They include user-effect controls
without the render-held frame. The Bend law staged_error_recovery_counterexample
checks the actual constructed same-value case: proposal/value 1, stale error bit,
consumer ERROR with cause 1, escaping cause 1, retained text 2 and halted runtime.
This is negative baseline evidence, not a desired recovery guarantee or TS-equivalence
proof. It must not be counted as a successful coherence theorem.

## Source operations / likely cause

- async.ts:stageError puts a StatusError in pendingValue and sets CONFIG_STAGED |
  CONFIG_STAGED_ERROR (line 203).
- A later successful core recompute replaces the pending proposal with 1/7 while
  the node is still held. Inspection of both runtime states shows the error bit
  remains set; the recovered node has status 0 and no error in its extension.
- core.ts:serve (line 1957) tests CONFIG_STAGED_ERROR and throws pendingValue, now
  the successful value. The dependent wraps it as an error and the render halts.
- The flag's clearing store is in scheduler.ts:commitPendingNode (around 1254–1265),
  which is too late to prevent that tracked read in this schedule.

This points to a stale proposal-kind bit when a normal answer replaces a staged
error. Any candidate fix must review every non-error overwrite, including async
landings, shown-error preservation and the held-frame rules. No candidate delta is
active, and the pinned reference is unchanged.

## Intent and history checks

[PR #4085](https://github.com/solidjs/solid/pull/4085), merged 2026-10-15, introduced
held error proposals for D-41 and explicitly states that recovery to the last good
value remains a new answer. The pinned tests error-is-an-answer.test.ts cover
recovery AFTER the old error's frame committed. They do not cover replacing an
uncommitted error proposal while the original frame is still held. The related
createLoadingBoundary test also recovers after an error has shown.

Searches for staged-error recovery, CONFIG_STAGED_ERROR, and held/value/error
recovery found #4085 and older related error recovery reports, including closed
[#2949](https://github.com/solidjs/solid/issues/2949); returned results did not identify
this exact schedule. This is a bounded duplicate search, not proof of absence.
The source-only current-head repro and paired controls make this a strong upstream
bug candidate; maintainer confirmation remains outstanding.

## Tracking / retirement

ID: SOLID-STAGED-ERROR-RECOVERY-002. Source units: async.ts:stageError,
core.ts:recompute/serve, scheduler.ts:commitPendingNode. Bend counterparts:
pending.stageError, core.finishValue/publish/serveSelected, scheduler.commitPendingNode.
Baseline parity and this negative law must remain visible. On an upstream fix,
review the precise flag/overwrite changes, port them, update these controls and
retire the counterexample expectation with its report/fix link. Keep the history.
No semantic deviation, package publication or external issue filing has occurred.
