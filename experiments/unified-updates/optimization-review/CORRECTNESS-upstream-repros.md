# Upstream public repro verification

Starting checkpoint: `cf6f20b00`. All four filed public repros were exercised on
the retained experiment source with controlled promise gates and scheduled render
effects. Assertions compare published screens after flush/turn and completed
request arguments, without prescribing sibling callback order. No runtime defect
or unexpected semantic difference was found; no runtime changes are justified.

| Filed repro | Retained behavior |
| --- | --- |
| #4775 repeated guess | Guess 2 and its unresolved async copy stay held at 1 together through an unrelated tick; both publish 2 after the answer. |
| #4776 latest memo consumer | Latest memo publishes 2 and its ordinary pair publishes `2 / 0` while ordinary id/filter remain 1/0. On action completion the pair publishes `2 / 1`. |
| #4777 repeated ordinary read | Late enable starts requests only with completed arguments `[0, 1, 0]` for `id(), latest(id), id()`; the answer publishes with ordinary id still 0. |
| #4778 async pending wrapper | Previously async direct and memo-wrapped presentations hold the common pending output until both answer, then publish true together while ordinary id stays 0. |

Two missing exact public controls remain in
`packages/signals/tests/unified-review-upstream-repros.test.ts`: #4776 and #4778.
The duplicate #4775/#4777 controls were removed after passing: existing
`unified-experiment.test.ts:70` covers repeated proposals/tick/late mount through
the explicit layer adapter; `unified-read-retry` and `unified-stable-context`
cover coherent completed bodies across broader async/iterator/ownership cases.

Initial exact controls: **4 passed**. Final bounded source verification:

```sh
cd packages/signals
./node_modules/.bin/vitest run tests/unified-review-upstream-repros.test.ts tests/unified-read-retry.test.ts tests/unified-pending-async-feedback.test.ts tests/unified-latest.test.ts --maxWorkers=1
```

**58 passed, four files passed**, duration 3.19 seconds. No builds, production
checks, broad suites, or benchmarks were run by this agent. Scratch receipt:
`/workspace/scratch/correctness-review/upstream-repros/README.md`.

An initial `pnpm exec` invocation triggered automatic dependency checking and
refused an unsafe existing symlink target before running tests; the existing
Vitest executable was then invoked directly. No dependency install was requested.
