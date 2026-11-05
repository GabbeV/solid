# Stage 68: a new reader must not demote an existing update

Current retained scalar checkpoint. This follows
[owned-frame coordination](OWNED-CONTEXT-66.md) and
[synchronous cost refinements](SYNC-COORDINATION-67.md).

## Correctness finding and fix

An optimistic output proposes 1, with an async consequence still pending. A new
root mounts a memo reading that output. A later ordinary action changes another
input of a shared memo. Before the fix, merely mounting that reader made the
ordinary action hold the optimistic publication; without the new reader, the
optimistic update published independently against the ordinary input's committed 0.

The deferred-join calculation had allocated a temporary update at level 0.
Accepting the read merged the higher producer into that temporary record and
lowered its context. This was an implementation bug, not a new entanglement rule.

A fresh calculation now adopts its accepted proposal's context **after dependency
discovery**, before merging the accepted holders. Existing triggering updates
keep their context. An attempted first-read adoption fixed the simplest case but
failed a two-depth reader in one read order. That attempt was corrected: the
temporary context stays provisional during discovery so a later deeper input
can cause a retry before the conflicting read returns.

The new tests compare with/without a late reader, both dependency read orders,
and direct reads versus reads through two levels of owned memos. They verify
that a ready upper guess publishes while lower work stays pending. Publication
is `first=0, second=10, detail=10`, with the late reader showing `0:10` in both
orders. The production build reproduces this result.

Pinned next instead publishes `first=1` in that audit: its selected override
does not forward observedness to the hidden pending input in the way accepted
for this experiment. That is reported as a comparison, not adopted as a target.

## Validation and limits

- Full signals suite: **5,532 pass, 22 existing expected failures, two skips**,
  327 files. The compatibility entry still uses the legacy APIs; this number is
  not 5,532 tests of the new optimistic engine.
- Layered scalar regression set before the final four owned-depth additions:
  355 pass and two expected failures belonging to legacy comparison cases.
  The complete stable-context file now has 20 passing tests.
- Expanded scalar-only campaigns: **120 pass**, seven files, 100 seeds each for
  pending, branching, overlap, and latest, with legacy lanes compiled out.
- Declaration checking and scalar production build complete. Existing unrelated
  test-file build diagnostics remain recorded in the build log.
- Production audits retain the F5b publication checks, request-start check,
  owned first-publication checks, and the new late-reader depth comparison.
- `git diff --check` passes. The pinned baseline's tracked files are unchanged.

There are no expected failures marking candidate behavior in these scalar tests.
This finite matrix is not a universal proof: broader graph shapes, all public API
options, renderer integration, SSR, and stores remain outside the claim. The
[restricted API surface](SCALAR-API.md) is unchanged. `refresh` is still excluded;
its relative-input contract is an [explicit unresolved question](REFRESH-QUESTION.md).

## Measurements against pinned next

The baseline is next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Both runtimes use the
repository production build and separate tree-shaken bundles. This measures the
experimental scalar entry, not a replaced or published package main entry.
Raw runs, worker/bundle hashes and size metadata are in
`results/late-context-stage68/`.

Seven alternating fresh-process pairs cover 13 ordinary synchronous workloads.
Paired candidate/next ratios range from 0.768 for signal creation to 1.027 for
write/flush. Most are near parity or modestly faster; signal creation is the
larger improvement. Memo reads are 0.938; chains 0.960; diamonds 0.965. Equal
writes, fan-out and ordinary write/flush remain near parity, with small measured
regressions in some cases. Sample ranges are recorded; this is not an
application-level speed claim. With optimism imported and an inactive boundary
alive, memo creation/disposal is 1.023 in the 11-pair follow-up.

Active optimism remains substantially slower:

| Workload | Next | Candidate |
| --- | ---: | ---: |
| All 16 overrides active; write top only | 2.96 us | 5.01 us |
| Write through 16 transparent boundaries, direct inputs | 7.02 us | 23.78 us |
| Write through 16 transparent boundaries, callback inputs | 6.88 us | 35.48 us |

Top-only paired ratios at depths 1/4/16 are 2.37/1.97/1.81. Transparent chains
remain a materially different and worse case. This is an open performance
acceptance issue; ordinary-path results do not erase it.

| Bundle scenario | Next minified / Brotli | Candidate minified / Brotli |
| --- | ---: | ---: |
| Ordinary | 21,918 / 8,116 B | 21,454 / 7,961 B |
| Optimistic | 27,250 / 9,864 B | 30,011 / 10,879 B |
| Pending | 28,812 / 10,419 B | 31,527 / 11,325 B |
| Latest | 28,715 / 10,368 B | 31,241 / 11,236 B |

Feature bundles remain larger. No thresholds were raised or waived.

V8 sampled allocations, including collected objects: ordinary writes about
516 vs next's 645 bytes; inactive optimism 515 vs 638; one active boundary 2,220
vs 1,394. These are estimates, not exact counts.

Retained boundary memory is about 1,181 vs 556 bytes for callback inputs and
809 vs 568 for direct accessors. All five candidate and baseline production
memory runs collect every disposed-reader token. The 50-replacement ownership
test separately checks bounded subscriptions and exactly-once cleanup.

The implementation remains a local prototype with promising ordinary-path
results, substantial active-cost limitations, and a pending refresh contract.
Stores are still paused. No mergeability or complete scalar acceptance is claimed.

Final build log after correcting the new fixtures’ generic annotations: `results/late-context-stage68/build-test-types.log`. The new tests add no remaining build diagnostics.
