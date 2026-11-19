# Upstream latest-error publication candidate

The experiment runtime is unchanged. Implemented separately on current upstream
next `45648f78` in branch `fix/latest-error-boundary-publication`, pushed to
GabbeV/solid at `6e282e28` (runtime commit `151cc836`). Current next differs from
our `4fe75321` baseline only in documentation.

The fix retains publication context when reading an errored lane memo and when
converting it into an Errored fallback, including repeated errors and recovery.
It reuses the existing boundary lane field and preserves the original error
source for reset. No new node fields or separate error storage were needed.

Five old intermediate assertions change intentionally: ahead errors now reveal
where successful values would. Ordinary readers remain held; final recovery
assertions are preserved. New JSX coverage includes 24 value/error timelines
across synchronous/asynchronous answers, zero to two identity memos, retained or
proposed-removing Show branches, repeated answers, pending recovery, and an
ordinary reader. Another case checks reset, same-value recovery, fallback DOM
identity and cleanup.

## Validation

- Signals: 6,759 passed, 2 skipped.
- Client web: 1,779 passed, 1 skipped, combining a full run (1,772 passed,
  seven artifact-manifest failures) with the complete artifact-manifest rerun
  (54 passed) after supplying missing generated declarations.
- Targeted error/latest/boundary hydration: 176 passed.
- Signals dev/prod/observe builds, declarations, production purity checks,
  formatting, diff checks and generated rules index pass.
- Complete SSR suite and throughput benchmarks were not run.

Web tests used the native JSX compiler and a local config explicitly supplying
jest-dom setup. Dependencies were aligned to required seroval 1.7.0. Unchanged
web artifacts were supplied from baseline/local builds, rather than rebuilding
the full web artifact matrix. Receipts preserve initial environment failures as
well as final results; they are not all green reports.

## Size

Existing Rolldown harness versus next, minified / Brotli changes:

| Scenario | Minified | Brotli |
| --- | ---: | ---: |
| Ordinary core, store, until/refresh, simple render | 0 B | 0 B |
| isPending/latest | +32 B | +5 B |
| Hydrating app without stores | +173 B | +71 B |
| CSR app with boundaries | +177 B | +79 B |

The last two exceed existing Brotli caps by 34 B and 57 B. Caps were not raised.
This is a candidate for review, not a claim that all merge gates pass. No runtime
performance improvement is claimed.

## Publication status

Both connected GitHub and gh CLI PR creation were rejected with
“Resource not accessible by integration”. No PR or issue was created. A prefilled
comparison form was queued in the user browser with the complete description:

https://github.com/solidjs/solid/compare/next...GabbeV:solid:fix/latest-error-boundary-publication?expand=1

The pushed branch and archived pr-body.md preserve the reviewable result.
Stage 136 receipts include reports, local harness setup, trial logs, candidate
patch and regression source. Adapting this fix to the unified update experiment
remains future work; this checkpoint changes no experiment runtime semantics.
