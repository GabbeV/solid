# Store completion checkpoint

## Reopened array semantics

The user has rejected the sparse-array composition described below. The runtime
is unchanged pending a replacement policy; the green test checkpoint does not
establish acceptance for this newly clarified requirement. See
[STORE-STRUCTURE-REVIEW.md](STORE-STRUCTURE-REVIEW.md) for current-next comparisons,
reproductions and alternatives.

## Scope and status

Store implementation is integrated into the real signals core. This checkpoint
covers records, per-property values/presence/descriptors, nested and chained views,
arrays and length, keyed/positional mapping, async producers, errors, owned rows,
observation APIs, and setter-read coordination. `until` remains deliberately
unsupported. The frozen full signals run has no non-`until` failures. The main framework
suites also pass. This establishes the upstream-test milestone; it does not
assert that every valid store program is bug-free. An inherited limitation is
called out below.

This is a correctness checkpoint, not performance/size acceptance. Full API
integration changed the implementation since the earlier measurements; those
measurements must not be presented as current. Benchmarks and bundle comparisons
against next remain the next phase.

## Choices to review

The overnight authorization allowed reasonable choices without stopping. These
are the ones to revisit if their observable behavior is not what you want:

1. **Structural setter reads consume overrides.** `key in draft` and
   `Object.keys(draft)` join the owners whose optimistic presence/key edits they
   actually consume, just as `draft.a` does. Internal copying remains exempt.
2. **Different added object keys can retire independently.** If A adds `a` and B
   independently adds `b`, completing A can publish `{b}`. The previous flat
   container snapshot accidentally joined those additions.
3. **Returned array replacements with a changed length count as an explicit
   resize.** Same-length replacements do not automatically make every property
   share an action lifetime. This handles setters that bypass index-write traps.
4. **A setter's outputs form one publication group.** Setting a parent and one
   of its fields in the same setter does not introduce an extra optimistic depth
   between those outputs. Overlapping groups and dependency cycles coordinate;
   this does not join the independent input producer to the action.
5. **An implicit length floor is not a complete first answer.** Before an async
   array producer has ever answered, guessing an index is allowed, but mapping
   still waits for the unknown input length. Explicitly guessed properties can
   be read independently; untouched initialization seeds are not published.
6. **An object reference is distinct from its contents.** A selected descendant
   can keep its ancestor reference available. `isPending(() => store.object)`
   can be false while `isPending(() => store.object.unguessedField)` is true.
   It is not an automatic deep pending query.
7. **Fixed-index overrides can compose into a genuinely sparse array.** Starting
   with `["A"]`, `push("M")` selects index 1 and minimum length 2. If an independent
   input becomes `[]`, the selected result can be `[hole, "M"]` until correction.
   Every reader must agree on that array. Next retains the old dense rows in the
   comparison. No rebasing or retention of unguessed index 0 was added. A second
   push consuming the first push's length still joins its action.
8. **Untracked sampling uses the calculation's selected value.** A memo that
   samples guess 3 inside `untrack` can retain 3 when an independent input later
   answers 2; it does not resample solely because of that untracked input. The
   tracked counterpart corrects to 2. Ordinary reads outside the graph still
   return the committed value during a hold. This replaces an old store-specific
   expectation that the untracked callback sampled hidden input 2 instead.

Setter exceptions retain preceding draft work, matching next. Getter receiver
behavior and first-input/error propagation remain supported. The existing rulings
on separate input/override lifetimes, unspecified sibling callback order, and no
blanket observation forwarding remain in effect.

## Inherited limitation retained for review

A blind nested write through a *different, still-unanswered store* rejects on
both this experiment and next. For example, before `answer` resolves:

```ts
const [inner] = createOptimisticStore(() => answer.promise, { x: 0 });
const [outer, guess] = createOptimisticStore(
  () => ({ child: inner }),
  { child: { x: 0 } }
);

// Inside an action kept open by another gate:
guess(draft => { draft.child.x = 9; });
```

Reading `draft.child` succeeds, but assigning `x` encounters `NotReadyError`
during an internal descriptor scan of the unresolved child. The guessing action
fails; no guessed value or initialization seed publishes. This is a limitation,
not evidence that the user explicitly read `x`, and not a newly required semantic
rule. I retained the safe next behavior rather than broaden this edge case during
completion. It is the remaining known limitation to reconsider if you want blind
nested writes before any incoming answer to work in every chained form.

Two ordinary alternatives work and have positive publication/correction controls:
replace the complete child with `guess(draft => { draft.child = { x: 9 }; })`
before the first answer, or mutate `child.x` after that first answer. Whole-child
replacement does not expose untouched initialization fields. Next supports both
alternatives too.

A trial that only scanned the prepared draft got past assignment but still failed
at setter exit and then leaked an initialization value. It was rejected and is
not in the branch. Supporting the nested blind write needs a coherent treatment
of unknown chained inputs during allocation, not that one-line bypass. No test
was added that makes rejection a permanent required contract.

## Evidence and limits

The runtime source tested is `b69738dd2`, against the upstream test baseline
`bcef1041cb50bf648da5641693b5ebdea1fc5dc2`. Subsequent `fb66cae0c` changes only
the #4275 JSX regression to a type-correct child expression; both runtime cases
and the Web type program pass with all assertions unchanged.

| Validation | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: |
| Signals, including built artifacts and explicit GC | 7,930 | 135 (`until` only) | 5 |
| Solid | 927 | 0 | 0 |
| Web client | 1,883 | 0 | 1 |
| Web server | 2,010 | 0 | 3 |
| Web hydration | 768 | 0 | 3 |
| Diagnostics and h/html/universal/element adapters | 385 | 0 | 0 |
| Additional nested-first-answer controls after the full run | 2 | 0 | 0 |

All four public TypeScript programs, source declarations, production/observation
builds, purity checks, generated rule citations, and package import smoke pass.
The signals skips are three explicitly deferred `until` controls and two tests
already skipped upstream. The seven framework skips were already present too.
No supported failure was converted into a skip during final validation.

The 135 failures were classified by exact file/test identity and inspected `until`
call paths, including shared helpers; whole files were not excluded. Their later
assertions may reveal additional problems when `until` is implemented. Test
migrations preserve coherent whole-publication checks, action completion,
corrections and cleanup; they do not allow arbitrary intermediate values.

The environment required local jest-dom setup paths for hydration/element and
one shared current signals module for server diagnostics. Adapter artifacts were
built locally. The import-smoke script ran unchanged with scratch package links
to this checkout, because the installed workspace links otherwise resolve to an
older checkout. The receipts retain the original environment failures, exact
qualifications and hashes. The install-driven packaged-types integration suite
was not run; the four public type programs were run.

Receipts are committed in
[checkpoints/README.md](checkpoints/README.md), specifically
`store-completion-b69738dd2-20261112.tar.xz` and
`framework-final-b69738dd2.tar.xz`. Source and primary artifact hashes stayed
unchanged throughout the frozen full runs. A finite suite is not a proof for
every dependency graph.

The chronological investigation, including rejected approaches, is retained in
[STORE-OVERNIGHT-DECISIONS.md](STORE-OVERNIGHT-DECISIONS.md).
