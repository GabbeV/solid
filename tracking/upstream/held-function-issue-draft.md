# [2.0 / next] A held writable-memo setter invokes a function returned by its updater

## description

During a held update, `setCallback(() => replacement)` calls `replacement` as another updater and returns its result. Without the hold, or with an ordinary signal, it returns the function without calling it.

The repro uses a writable function-valued signal, a native Promise and normal JSX. It logs “Replacement invoked” and the setter returns a string even though its TypeScript return type is `() => string`. A replacement that returns void is called and returns undefined instead; a throwing replacement unexpectedly throws from the setter.

## link

https://s.olid.uk/id/eQKgYi1oQrazp_lcVSOgpA

## steps

1. Open the pinned playground and click “1. Start update”.
2. While the request is pending, click “2. Store callback”.
3. The second button says `Returned: string` and the console logs `Replacement invoked`.
4. “3. Finish request” releases the frame.

Controls: replace the writable `createSignal<() => string>(() => { version(); return () => "derived"; })` with `createSignal<() => string>()`, or change the slow memo body to `version()`. Both return the function and never call the replacement.

## expected

An updater's returned function should be used as data and returned unchanged, without invoking it. The updater should still receive the frame selected by the existing held-write rule; this does not request a change to re-derivation precedence.

## platform

- Solid next d2ad8b288886a5c7171e6746ccc019ad1d08d8ab (source manifest 2.0.0-rc.15)
- Reproduced in development and production with the unchanged runtime and JSX compiler
- Linux x64, Chromium 154.0.8037.57, Node 24.19.0

## additional

`setMemo` pre-evaluates a held updater against the committed `_value`, then passes the result to `setSignal`. A function result is consequently interpreted as another updater.

The committed-frame behavior comes from #3612 / #3630; #3733 concerns the re-derivation policy. This case has no compute error and is separate from #4110 / #4143 and #4145 / #4148.

I checked a local candidate wrapping the pre-evaluated answer and preserving evaluation order: the three new regressions fail before it; all twelve regression/control cases and the signals suite pass after it. A compact version adds 9 minified bytes and passes the signals size comparison gate, but creates a wrapper for held numeric updaters too. One targeted Node microbenchmark measured ~9% overhead on that cold path. Wrapping only function-valued answers avoids that allocation but adds 30 minified bytes and fails three signals size gates. Which approach fits the intended performance/size tradeoff? No runtime fix is included in this report.
