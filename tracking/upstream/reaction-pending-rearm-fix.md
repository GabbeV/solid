# Local candidate: capture reaction arms before tracking

Candidate `5c6f441144ab34b8e0b8645bca5c4a748e7e1f84` is committed on
`fix/reaction-pending-arm` in `/workspace/solid-reaction-pending-fix`, based on
unchanged next `b0ad1df505b835058a4b3750ab37d6576bb18c01` (rc.16).
The [portable patch](reaction-pending-rearm.patch) includes source, tests and a
patch changeset. At the user’s request, this exact commit was pushed to
`GabbeV/solid:fix/reaction-pending-arm` and a filled-out comparison form prepared
for review. The user has now submitted [PR #4188](https://github.com/solidjs/solid/pull/4188);
its head is the tested candidate commit, and it is open. The active Bend runtime,
source pin and negative law continue to preserve the upstream bug.

The [source report](reaction-pending-rearm.md) links the minimal JSX repro and
Ryan's existing #2861 replacement ruling. This candidate addresses an uncovered
case of that fix: initial pending or throwing tracking exits before the arm is
recorded, so a later track cannot dispose the superseded effect.

The filled-out PR form now links the [hosted JSX repro](https://s.olid.uk/id/iZOM74C9Sda3qJWUKNHJLw),
pinned to npm 2.0.0-rc.16, with verified failing and loading-value control counts.
It retains the separate source-built b0ad1df5 and patched-source validation.

## Source change

The existing compute wrapper now reads its current owner into a local `node`,
assigns `arm = node`, calls `tracking()`, and returns `node`. This records the
actual subscription even when tracking throws. Returning the local node also
avoids consulting a mutable arm after user code, which may re-arm the reaction.
There is still one compute wrapper, one getOwner call per execution, and no new
wrapper or node allocation. Existing callback cleanup/disposal order is unchanged.

## Validation

- Two new regressions fail before the fix: superseding an initially pending read
  and superseding an initially throwing read. A loadingValue control passes both
  versions. All eight createReaction tests pass after the fix, retaining ordinary
  replacement and re-arming from the callback.
- Built signals suite: 327 files and 5,414 tests pass, with three expected failures
  and two skips. All three new cases also pass in production and observe builds.
- Signals JavaScript builds and source declarations pass. Prettier checks on the
  three changed files and release-invariant checks pass.
- The unchanged minimal JSX component shows the desired old/current counts 0/1
  in production, development and observe, with and without a loading seed. All
  six cases have no page/console errors. [Candidate browser record](reaction-pending-rearm-fixed-browser.json)
  is separate from the unchanged-source baseline record.
- Four standard Rolldown 1.2.11 size scenarios are byte-for-byte unchanged and all
  existing gates pass. A focused createReaction import changes from 16,562 to
  16,579 minified bytes (+17), with Brotli unchanged at 6,301 bytes.
  [Size record](reaction-pending-rearm-size.json).
- Longer alternating production timings show no apparent slowdown across
  replacement, fire, callback re-arm and derived tracking. Patched/base medians
  were 0.961, 0.981, 0.966 and 0.949. These local microbenchmarks establish neither
  a speedup nor an application-performance guarantee. Tiny initial batches were
  too noisy and were superseded by the longer measurements.
  [Raw measurements and method](reaction-pending-rearm-benchmark.json).

The benchmark uses Node 24.19.0 and esbuild 0.25.12 over built production artifacts.
It checks callback counts, warms each version with five batches, then alternates
eleven measured rounds, each containing forty 4,000-cycle batches. Scheduled host
no-op microtasks drain outside the timed batches. Reproduce from this repository:

```sh
node repros/solid-signals/benchmark-reaction-fix.mjs \
  /path/to/built-baseline /path/to/built-candidate /tmp/reaction-timings.json
```

The source checkout is clean at the candidate commit. Before/after focused logs,
build/type/format/release logs, full suite, tier controls and browser harness output
remain under `/workspace/scratch/reaction-fix-*` and
`/workspace/scratch/reaction-fixed-browser.log`. The patch and checked records here
retain the reviewable result independently of that scratch directory. This is a
tested candidate, not a claim about every possible reentrant tracking program.
