# Scalar guesses before the first input answer

The user accepted allowing scalar optimistic guesses before the input's first
answer when the split representation supports them naturally. The stage 123
proposal to retain next's dev-only `OPTIMISTIC_WRITE_BEFORE_LOAD` error is
therefore rejected for scalar optimism. Optimistic stores remain deferred;
this decision does not specify how an unloaded store draft should be composed
with its first incoming list.

No runtime change was necessary. The input keeps its pending calculation and
the output can publish a complete guess, subject to ordinary downstream
holding. A function-form first setter receives `undefined`, since the output
has no prior value. A guessing action still waits for its own input as well as
its action lifetime. An unscoped guess can revert when the input answers.

## Tests

- `createOptimistic.test.ts` retains #2694's refresh checks and now accepts the
  initial guess. The setter-error expectation was the only failing assertion.
- `superseded-before-first-commit.test.ts` accepts the guess while retaining
  the checks that held downstream work prevents publishing the first output.
- `uninitialized-visibility.test.ts` tests the first setter's `undefined`
  argument and the complete render history `[99, 1]`. Its scalar reader now
  suspends normally instead of catching a reactive read error.
- `visibility-oracle.states.ts` removes the obsolete catch for the scalar
  diagnostic. Its observation assertions are unchanged.
- `optimistic-before-first-answer.spec.tsx` adds four normal JSX/Loading tests:
  sync or async consequences of a repeated guess, crossed with input-first or
  action-first completion. They show `loading`, then `0:1 / 1/1`; while the
  second guess's async consequence is held, an unrelated update shows
  `1:1 / 1/1`, never `1:2 / 1/1`. Once ready they show `1:2 / 2/2`, then
  `1:0 / 0/0` after the input and action complete.

The focused signals selection passes all 96 tests, including all 27 existing
owned-context cases. The additional first-setter test passes. The expanded
web selection passes all 7 tests, including independent input publication and
input-reader removal. Reports are in `results/integration-stage124/`.

The full signals run recorded 5,166 passed, 2,142 failed, and 2 skipped. Against
stage 122, four old failures disappeared (three first-write expectations and
stage 123's obsolete pending expected-failure marker); the only new failures
were three rules-index freshness checks caused by changed test citations.
Regenerating `docs/RULES-INDEX.md` and rerunning its test file passes all three.
The full suite was not repeated for that generated-document-only change. No
additional runtime regression was found. Remaining failures are not declared
intentional merely because the runtime was unchanged.

This is a semantic/test migration with no new node fields, branches, runtime
allocations, or shipped bytes. Stage 122 remains the runtime checkpoint; no
new performance claim is made. General scalar compatibility, optimistic
stores, `until`, performance and size acceptance are still incomplete.
