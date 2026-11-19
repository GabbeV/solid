# Scalar migration audit and pending restoration

This continues [stage 107](INTEGRATION-107.md). The 32 accepted scalar semantic
changes and nine imperative-read exceptions in that checkpoint's failure
inventory have now been migrated and run through their remaining assertions.
Two corresponding DOM Loading tests were migrated too. No test was skipped or
converted to an expected failure in this pass.

The migrations cover committed ordinary reads during held guesses, selected
output visibility through latest, incoming-answer retirement, executing-update
ownership of setters, higher-layer mounts reading committed lower content,
unspecified sibling callback order, tracked observation feedback, and deferred
imperative flushed-value exceptions. Per-binding histories, mount counts,
cleanup counts and coherent final values remain asserted. Owned-frame tests
check every created generation is disposed exactly once, including speculative
retries; a held published generation survives until replacement publication.

`results/integration-stage108/migrated-cases.json` records the prior first-failure
classification of every migrated signals case. The original test locations are
retained. Comments distinguish changed semantics from historical next rulings.

## A real bug exposed by migration

The verdict-contract test initially failed beyond its migrated first assertion:

```text
input=0, guess=0, detail=0, pending=false
start input request; guess 5; detail(5) suspends -> pending=true
detail(5) answers 50, input still unresolved
  before fix: pending=false, then pending=true
  after fix:  pending=true
```

That extra false publication was not accepted. Pending restoration selected the
ready optimistic output's update rather than the unresolved input question
which kept pending true. Pending already follows explicit optimistic/latest
input boundaries; restoration now uses that same chain to select its parent.
The common observation lifecycle honors that selection during retirement.

For a ready incoming answer, selection compares against the output value about
to publish. Comparing only against the old committed output incorrectly joined
a ready latest output back into lower held work; that trial failed two existing
createMemo cases and was discarded. Matching incoming answers may still clear
pending early, while differing unpublished answers remain pending.

The retained change touches only `layers/pending.ts` and `layers/observation.ts`.
It adds no node fields, caches, ordinary-read branches or scheduler phases.
`pending-output-publication.test.ts` adds six complete render-history tests:
zero, one or three latest wrappers, with matching or differing input answers.
All six fail against the stage-107 implementation and pass with the fix.
The broader 180-test focused observation/optimistic run passes too.

## Normal suite results

The retained full signals run used the final built/mangled artifacts. Solid and
web use the normal package entry; web uses the same published rc.14 compiler as
the pinned-next comparison in stage 105.

| Package | Ordinary passes | Expected failures | Failures | Skips |
| --- | ---: | ---: | ---: | ---: |
| signals | 4,098 | 18 | 1,636 | 2 |
| solid | 833 | 0 | 23 | 0 |
| web | 1,227 | 1 | 103 | 0 |

All remaining signals failures classify as deferred APIs: 1,572 optimistic-store
cases and 64 until-dependent cases. All 23 Solid failures use optimistic stores.
Web has 73 optimistic-store failures and 30 compiler-dependent failures also
reproduced on pinned next in stage 105. No new failure names remain.
Classification is of the first failure, not a claim about unreachable assertions.

The 18 expected failures are reported separately and **still require audit**:
some concern scalar Loading/reveal behavior. This checkpoint does not declare
scalar correctness complete merely because the unexpected scalar failures are
cleared. Full build, declarations, property mangling and pure checks pass.
Nothing was pushed or posted.

## Size and remaining acceptance

| Scenario | Pinned next Brotli | Candidate Brotli | Existing cap |
| --- | ---: | ---: | ---: |
| Core floor | 7,439 | 7,433 | 7,450 |
| + ordinary store | 14,706 | 14,694 | 14,710 |
| + isPending/latest | 9,692 | 11,657 | 9,730 |

Core/store minified sizes remain 20,372/44,758 bytes; observations are 32,865.
The observation scenario is 1,965 Brotli bytes larger than next and exceeds its
unchanged cap by 1,927 bytes. This remains an acceptance failure. No fresh
performance claim is made; normal benchmark comparisons remain in stage 105.

Next: inspect expected scalar failures, then complete the store/API migration.
Feature size and active-optimism performance remain independent acceptance work.
