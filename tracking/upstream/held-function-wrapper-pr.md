# Selected wrapper fix for SOLID-HELD-FUNCTION-VALUE-003

The user selected the existing wrapper approach and authorized publication on
2026-10-19. Branch `GabbeV:fix/held-function-values` is pushed to GabbeV/solid.

- Head: `82c89dab837f1f71f8391dd6323861261147afc8`.
- Base (current Solid next): `1ddd68df16b6aec1edc1c87982eb0944d0ea8831`.
- [Review and submit](https://github.com/solidjs/solid/compare/next...GabbeV:fix/held-function-values?expand=1).
- Worktree: `/workspace/solid-held-function-pr`.
- Exactly three changed files: `packages/signals/src/core/core.ts`,
  `packages/signals/tests/held-function-value.test.ts`, and
  `.changeset/quiet-functions-rest.md`.

PR submission is blocked by GitHub permissions. The connected GitHub REST tool
returned 403 “Resource not accessible by integration”; `gh pr create` returned
“Resource not accessible by integration (createPullRequest)”. No PR was created.
The filled-out compare form was queued in the Codex browser panel for the user to
read and submit. This is a prepared submission, not an open PR.

The wrapper follows existing async-result and store-write patterns. The original
updater still runs against the committed value before writeHook, and its result
is protected from a second invocation by `setSignal`. It allocates a closure on
held functional writes. Earlier microbenchmarks and alternatives remain in the
[original record](held-function-value.md) and
[allocation-free comparison](held-function-allocation-free.md); those measurements
use the older pin, not this rebase.

On the fresh base the three regressions fail while nine controls pass; the patch
passes all twelve. Signals builds, declarations, purity, formatting, release
invariants and the full signals suite pass (318 files, 5,375 tests, three expected
failures, two skips). The repository-wide build/test matrix was not run.

[Size results](held-function-wrapper-size.json) use the current-next size harness
and Rolldown 1.2.11. Each scenario grows by 9 minified bytes. Three comparison
gates pass; the core floor exceeds its 20-byte minified allowance by 6 bytes.
Frozen caps and recorded sizes have not been raised. This needs maintainer review;
no size exception or maintainer acceptance is claimed.

The Bend source pin, runtime, and active-deviation register are unchanged. The
allocation-free branch is retained locally as an alternative. The selected branch
contains no constructor refactor or private resolved-value writer.

## Prepared PR title

fix(signals): preserve function-valued held updater results

## Prepared PR body

## Summary

During a held derivation, `setCallback(() => replacement)` invokes `replacement` as a second updater and returns its result. Ordinary signals and non-held writable memos return the function without calling it.

Wrap the held updater's resolved answer before passing it to `setSignal`, following the existing async-result and store-write pattern. The updater still runs against the committed frame at its original point, before the write hook; the held re-derivation policy is unchanged.

[Minimal JSX reproduction](https://s.olid.uk/id/eQKgYi1oQrazp_lcVSOgpA), pinned to `d2ad8b28`: click “1. Start update”, then “2. Store callback”. Expected `Returned: function` and no callback invocation; actual `Returned: string` and “Replacement invoked” in the console.

## How did you test this change?

- On current `next` (`1ddd68df`), the three held-writable-memo regressions fail before the fix; the nine ordinary-signal/non-held controls pass. All twelve pass with the fix, including callbacks that return undefined or throw if invoked.
- Signals development, production and observe builds, property mangling, purity checks and source declarations pass.
- Full signals suite: 318 test files pass; 5,375 tests pass, 3 expected failures and 2 skips.
- Prettier and release-invariant checks pass. Validation covers the signals package; the repository-wide build/test matrix was not run.

Size: +9 minified bytes in each of the four measured signals scenarios. Three comparison gates pass. The core-floor gate fails: 19,799 B is 26 B above its frozen recorded minified size, exceeding the 20 B allowance by 6 B. The base is already 17 B above that record. Core brotli grows from 7,260 B to 7,262 B. Frozen caps and recorded sizes are unchanged; accepting this cost needs a maintainer decision.
