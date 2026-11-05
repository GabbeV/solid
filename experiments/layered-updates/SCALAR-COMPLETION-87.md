# Stage 87: scalar migration fixes and remaining lifetime decision

This is an implementation checkpoint, not completion of the scalar migration or
acceptance of the experiment. Stores, until, and the outside flushed-read
exception remain deferred. No pending-feedback diagnostic is installed.

## Implemented changes

- The public optimistic constructor accepts plain initial values, no argument,
  synchronous callbacks, and async callbacks. Producer and selector stay
  separate. Equality belongs at the selector; loadingValue belongs at the input.
  Internal synchronous selectors forward literal Promise values without treating
  them as requests. User sync computations retain their existing dev diagnostic.
  Full hydration/attribution option behavior is not claimed.
- Guesses outside actions acquire the update that parks their flush, or their
  own pending input. With no pending update, a guess does not flash. Disposing a
  pending boundary releases its temporary opening hold. An action whose body
  returned still retains guesses while its ordinary observed work is pending,
  using the scheduler's existing ownFlights check.
- Selecting an observation's unchanged proposal can transfer an already computed
  result or pending flight into the output update. This avoids canceling and
  repeating an identical request, including through synchronous intermediate
  memos and wrapped latest callbacks. Changed/pending sibling dependencies and
  owned subtrees conservatively require recomputation. This is not a general
  guarantee of one calculation per source write. No per-ordinary-node field or
  ordinary-read lookup was added.
- Loading's arming version now propagates even when its content becomes pending
  later in the pure phase. This lets a subsequently selected observation update
  carry the fallback. The check uses the installed coordinator hook, not a hook
  temporarily enabled only while updates are active. Legacy behavior is retained
  when the replacement coordinator is absent.
- A still-visible child whose removal is held must receive independent output
  publications. The replacement now marks this work using the scheduler's
  existing retained-child bypass. Previously Value could publish 1 beside a
  retained Details binding still displaying 0. The unchanged #3463 regression
  now passes; new tests cover latest and one through three optimistic depths,
  including final removal and exactly-once cleanup.

## Validation

- Candidate-only layered suite: 430 passes, zero failures, 34 explicitly named
  baseline/legacy comparisons excluded. Legacy lanes are compiled out.
- Unchanged upstream corpus: 616 reported passes and 38 reported failures out of
  654. Two failures are existing expected-failure tests whose assertions now
  succeed (F5b and #3800); the corpus and those modifiers remain unchanged.
- A larger seeded run passes 300 seeds x 60 operations = 18,000 publication
  steps. It ran before the final ownFlights lifetime fix; the complete layered
  suite was rerun after that fix. An initial run exceeded Vitest's default
  five-second timeout; the larger run completed in about 23 seconds with an
  explicitly supplied 60-second timeout. No assertion was changed.
- All eight production navigation snapshots match pinned next: on=id, data,
  isPending, and latest, with product-first and reviews-first completion.
- Source-only TypeScript check and production build pass. Rollup still reports
  the repository's test-type and circular-import warnings.
- The final normal-entry suite reports 5,657 passes (including existing expected
  failures), two skips, zero failures. This mostly exercises legacy behavior and is
  not a substitute for candidate-only coverage.

Reports and paired production timelines are in results/scalar-stage87. Raw test
reports are gzip-compressed. Performance/size measurements use only pinned next
a24e911ba5e571e7adb1c9b5e5151261f9cf101c as the baseline. They do not establish
full API equivalence or acceptance while the exclusions below remain.

## Current cost against pinned next

Seven alternating fresh-process pairs per synchronous scenario, using identical
retained exports, give these median paired time ratios (below 1 is faster):

| Workload | Candidate / next |
| --- | ---: |
| Signal read | 1.024 |
| Memo read | 0.920 |
| Write and flush | 0.997 |
| Equal write | 0.951 |
| Memo write | 1.006 |
| Ten writes per batch | 0.973 |
| Memo chain | 0.883 |
| Diamond | 0.935 |
| Memo fan-out | 0.950 |
| Effect fan-out | 1.017 |
| Branch switch | 0.968 |
| Signal creation | 0.816 |
| Memo creation and disposal | 1.015 |

Run ranges overlap in several cases; small differences are not established
regressions or improvements. This is one machine's microbenchmark evidence.

| Application imports | next Brotli bytes | Candidate Brotli bytes |
| --- | ---: | ---: |
| Ordinary/action | 8,116 | 8,057 |
| Optimistic | 9,864 | 11,326 |
| Pending | 10,419 | 11,976 |
| Latest | 10,368 | 11,824 |
| Scalar refresh | 10,117 | 8,284 |
| Optimistic and refresh | 10,208 | 11,539 |

Optimistic/observation bundle sizes are still 14–15% above next, so this does not
meet size acceptance. In the separate active-context benchmark (three alternating
pairs), rewriting the deepest of 1/4/16 active overrides costs 2.48/2.16/1.85 times
next. In the five-pair propagation benchmark, rewriting the first override through
1/4/16 downstream boundaries costs roughly 2.2/3.2/4.5 times next (callback inputs;
direct inputs roughly 1.9/3.0/4.4). These are different workloads, both comparing
the candidate against next. Active propagation remains a significant optimization
gate, especially across inactive intermediate boundaries.

Five paired GC probes retain zero disposed reader payloads in either runtime.
The optimistic callback boundary occupies about 1,114 bytes versus next's 556;
the direct-accessor form about 1,073 versus 568. Two full nodes account for much
of this expected boundary-local cost; this does not measure ordinary-node memory
or establish a universal absence of leaks.

## Audit still to finish

The remaining failures include already accepted differences: committed-only
outside reads, output-based observation composition/equality, unspecified sibling
callback order, selected-override lifetime, and coherent pending-feedback
supersession. The owned-condition example's `show:undefined` failure is sibling
callback ordering, not an undefined-value leak: separate complete binding
histories pass in layered-optimistic-api.test.ts.

failure-review.json records the current review: 26 category-2 differences
(including the two improved expected failures and one removed internal-layout
assertion), eight category-4 outside-read exceptions, one category-3 lifetime
question, and three explicitly unclassified cases awaiting investigation. They
are not silently counted as intentional changes or passing tests.

Not every remaining failure has been fully classified. In particular, fresh
ordinary mounts over pending work and one extra owned-frame recomputation still
need complete timeline/lifetime checks. A long-lived-lane assertion inspects the
removed `_transaction._lane` representation and must be paired with equivalent
retention evidence, rather than declared semantically passed. Existing scalar
retention coverage does not replace that specific investigation.

The public non-store surface, real renderer integration, deferred/tracked
helpers, and SSR/hydration are not complete. The conservative unchanged-flight
transfer does not eliminate redundant owned-subtree work. Active optimism costs
and feature bundle size remain acceptance gates.

## Pending semantic decision: a guess written by an optimistic derivation

ambient-nested-lifetime.mjs compares the same program against both production
runtimes. An ordinary source change starts a pending input; an override over that
input starts a second async calculation. When that calculation answers, its
derivation writes another optimistic value using ownedWrite.

| Phase | next badge | candidate badge |
| --- | --- | --- |
| Initial | base | base |
| Both requests pending | base | base |
| Optimistic details ready; input still pending | guess | base |
| Input ready | base | base |

Next parents that write to a persistent lane, whose lifetime continues until the
input update ends. The candidate parents it to the publication update executing
the derivation; that update is already ready, so the new guess never reveals.
Both publish first/details coherently. Inheriting the original override lifetime
would require specifying which lifetime(s) to inherit when the derivation also
combines sibling overrides with different lifetimes. This has not been silently
restored from the old lane implementation.

The script's `action` control instead keeps a constant-input override alive with
an open action body. In that version next and the candidate both keep badge=base
when details answers. Thus next itself does not uniformly inherit any enclosing
override's longer lifetime. Both controls and complete event histories are saved
under nested-lifetime-{input,action}-{next,scalar}.json.
