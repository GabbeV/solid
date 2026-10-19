# SOLID-HELD-FUNCTION-VALUE-003

Status: reproduced in the pinned source; no upstream report filed. Writable-memo
setters are not yet in the Bend input ABI. This is source-only evidence, not a
Bend parity claim or active workaround. The deviation register remains empty.

[Minimal JSX playground](https://s.olid.uk/id/eQKgYi1oQrazp_lcVSOgpA), pinned to
Solid d2ad8b288886a5c7171e6746ccc019ad1d08d8ab. Source:
[held-function.tsx](../../repros/playground/held-function.tsx).

1. Click **1. Start update**. A writable memo derives a fresh callback while its
   sibling request holds the rendered frame.
2. Click **2. Store callback**. `setCallback(() => replacement)` should return
   `replacement` without calling it. Actual: the button says `Returned: string`
   and the console logs `Replacement invoked`.
3. Finish the request with the third button. The derivation still follows the
   existing held-write/re-derivation policy; the report concerns the unintended
   callback invocation and incorrect setter return value.

The component has two signals, one memo, a native Promise and a combined JSX
binding. There are no explicit effects, timers, error boundaries, private field
accesses or custom promise protocols in it. The ordinary data-signal control and
removing the hold both return the function without calling it.

## Source mechanism and evidence

`core/core.ts:setMemo` detects a held derivation and pre-evaluates its updater
against `_value`, the committed frame. It passes that answer to `setSignal`.
When the answer is itself a function, `setSignal` treats it as another updater
and invokes it against its current slot. Returning undefined overwrites the
proposed callback with undefined; returning a string produces that string; a
throwing replacement unexpectedly throws from the setter. The public Setter
signature and documented function-storage pattern admit this input. A strict
check against the generated public declarations accepts `const result: () =>
string = setCallback(() => replacement)`.

- `tests/upstream/held-function-value.mjs`: twelve source-only baseline/control
  cases, including replacement callbacks returning strings, undefined or throwing.
- Local JSX: baseline and both controls in development and production, compiled
  with the unchanged pinned runtime/compiler in connected Chromium 154.0.8037.57.
  [Results](../../repros/playground/held-function-verification.json).
- Hosted: source/build round-trip and actual three-button sequence verified in
  the saved share. [Record](../../repros/playground/held-function-hosted.json).
- Standalone Node repro: `repros/solid-signals/held-function-value.mjs`; its intended
  assertion fails on pinned next, while `no-hold` and `plain` controls pass.

On 2026-10-19 the remote `next` function still contained the same pre-evaluation.
Issue searches for setMemo, function-valued results and held updaters found no
matching report. Relevant history: #3612 / merged #3630 introduced the committed-
frame handling; #3733 discusses re-derivation policy. Open #4143 touches setMemo's
error recovery, a distinct problem; this reproduction throws no compute error.
The previously filed staged-error issue #4145 has open fix PR #4148, also distinct.
Search results cannot establish that no related report exists.

## Original wrapper candidate and tradeoff

Superseded by the [allocation-free candidate and comparison record](held-function-allocation-free.md). The measurements below describe the original wrapper trial, retained for history.

Local worktree `/workspace/solid-held-function-pr`, branch
`fix/held-function-values`, commit
`9bd896fa1242a7ca769fe19baf858f3f1e94f107`. Nothing was pushed or filed.
[Candidate patch](held-function-value.patch) includes twelve regressions and a
patch changeset. The patch keeps the updater evaluation before setSignal, wraps
its resolved answer as data, and reuses `v` for the setter result. The source
constructor, committed-frame selection, held flags, heap and scheduling order stay
as they were. No candidate patch was applied to the translation/reference.

The three regressions fail and nine controls pass before the patch. All twelve
pass afterward. The final candidate builds all signals artifacts and declarations;
all 315 test files pass (5,359 tests, three expected failures, two skips). Formatting,
release invariants and the strict public-type snippet pass. The full test-tree
TypeScript check has 30 existing diagnostics, verified identical on the base and
patched checkouts; the new regression file has none. Source-impact inspection
identifies only `core/core.ts:setMemo`, explicitly **unported** in Bend.

The compact patch adds nine minified bytes to each of the four measured signals
size scenarios. The upstream comparison gate passes: core floor and until/refresh
are each five brotli bytes above their cap, inside the existing minified allowance
with three bytes remaining. Caps were not raised. [Measurements](held-function-size.json).
This is the signals subset of the size suite, not every compiled app scenario.

Wrapping the answer adds a small closure for held functional updaters, including
numeric ones. A targeted production microbenchmark of 200,000 held writes has
median numeric-updater times 7.22 ms baseline / 7.87 ms patched (~9% slower);
raw numeric writes are within noise (7.10 / 6.91 ms). This is one Node 24 Linux/x64
microbenchmark, not an application performance claim. [Samples](held-function-benchmark.json).
The rerunnable script is `repros/solid-signals/bench-held-function.mjs`.

An [alternative](held-function-value-function-only.patch) wraps only function-valued
answers and avoids that numeric wrapper allocation. It passes the source tests but
adds 30 minified bytes and fails three signals size gates. The compact candidate is
reviewable, but this allocation/size choice merits maintainer input; an issue with
the repro and both choices is preferable to silently selecting an optimization.

Future Bend `setMemo` work must retain this baseline behavior or explicitly
register an authorized deviation. The plain-signal WriteResult path must not be
substituted for the held writable-memo updater prefix. A future repin should check
this report's status and port the upstream fix when it lands.
