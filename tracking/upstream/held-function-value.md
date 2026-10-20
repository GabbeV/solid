# SOLID-HELD-FUNCTION-VALUE-003

Current status: accepted upstream fix integrated and validated at Solid 71153bf0.
The evidence below records the original historical pin; see
[the integration review](../reviews/solid-71153bf0.md) for current behavior and
retained baseline branch.


Status: the user selected the wrapper fix. It is pushed to GabbeV/solid on
`fix/held-function-values` at `82c89dab837f1f71f8391dd6323861261147afc8`,
rebased onto next `1ddd68df16b6aec1edc1c87982eb0944d0ea8831`. The user
submitted [PR #4163](https://github.com/solidjs/solid/pull/4163); verified open
with that head on 2026-10-19. See the [publication and validation
record](held-function-wrapper-pr.md). The expression-based writable-memo overload is now in the Bend ABI. Its
selected bound-function counterpart has sixteen paired histories and the negative
`held_function_result_counterexample` law. The original twelve arbitrary function
controls remain source-only. This is preserved baseline evidence, not an active
workaround. The pinned runtime is unchanged and the deviation register is empty.

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

The user selected this approach after comparing the [allocation-free
alternative](held-function-allocation-free.md). The measurements below describe
the original trial against the old pin; current-next validation and its core
size-gate failure are recorded [separately](held-function-wrapper-pr.md).

Local worktree `/workspace/solid-held-function-pr`, branch
`fix/held-function-values`, commit
`9bd896fa1242a7ca769fe19baf858f3f1e94f107` before rebase. At the time of this
original trial nothing had been pushed or filed.
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
identified only `core/core.ts:setMemo`, which was **unported at that original
trial**. The current admitted translation is described above.

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
the repro and both choices was initially preferred. The user subsequently
selected the compact wrapper and authorized a PR; that publication is recorded
above.

The Bend `setMemo` translation retains this baseline behavior; any correction
must follow an audited upstream repin or explicitly register a deviation. The plain-signal WriteResult path must not be
substituted for the held writable-memo updater prefix. A future repin should check
this report's status and port the upstream fix when it lands.
