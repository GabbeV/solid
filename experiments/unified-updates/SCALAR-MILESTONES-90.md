# Stage 90: scalar migration, fixes, and validation checkpoints complete

Subsequent measurements and optimizations: [performance rounds, stage 92](PERFORMANCE-92.md).
The semantic scope and migration classifications below remain unchanged.

The migration audit is classified, the identified scalar implementation bugs
are fixed in the supported surface, and the current correctness/cost measurements
are complete. The final derived-guess lifetime decision was accepted by the user
on 2026-11-04: a setter belongs to the update executing it. The three scoped
checkpoints are complete; this is not completion of the broader experiment.

These checkpoints do not establish full API coverage or mergeability. Stores,
until, the outside flushed-value exception, tracked/deferred/reveal APIs, renderer
integration, SSR/hydration, and attribution remain outside the scalar entry's
validated scope. Performance and feature bundle size remain acceptance gates.

## Retained implementation

Creating a memo over a held input no longer forces the memo's mounting owner
into that input's update. Its read is scoped through the existing computation
and staging path. If the owner is already computing in an update, its children
inherit that frame. Internal source-owned observation outputs retain their
separate allocation behavior.

A new child that consumes one held update can adopt that existing update; this
cannot entangle independent peers. A child consuming multiple distinct holds
defers those irreversible joins until the enclosing calculation accepts its
context. A retry can dispose the child first. This small temporary list is
allocated only for that multi-hold case and is released when the enclosing
calculation finishes. No ordinary-node fields or result-version maps were added.

The shared `recomputeInUpdate` helper now accepts an initially empty scope. The
first actual held read acquires its update, and the caller's context is restored
after staging. The prior probe's unconditional transaction per child is gone.
Root context discovery retains its existing provisional update: an attempted
further simplification failed the owned late-observation retry case and was
reverted, with its patch and failing report archived.

Adopting an input update exposed a common merge invariant: if the currently
executing transaction is merged into another, later staging must use the
survivor's lists. `merge` now updates the current transaction pointer in that
case. Without this, a child could remain behind fallback after the input had
already committed because its staging was appended to the retired record.
The normal-entry suite also passes with this shared scheduler change.

The stage-89 displayed-dependency fix remains intact: a lower input used only
by an unpublished branch can publish independently; a lower input still used by
the displayed result retains its publication obligation. The production branch
comparisons were rerun after the mount fix.

## Observable mount behavior

An action holds input=1 while the displayed input is 0. An independent update
opens a subtree containing Loading and a new memo reading that input.

Both next and the retained candidate now show:

1. Initially: input=0, open=false, view=closed.
2. While the input is held: input=0, open=true, view=fallback; no child callback.
3. After the input action ends: input=1, open=true, view=content; child displays 1.

The same result holds with the producer inside or outside Loading. With two
pending inputs, a producer consuming both still entangles those peer updates;
Loading catches its publication without holding the independent mount. Closing
the mounted subtree before the answers arrive disposes its owners exactly once
and prevents later child publication.

## Validation

- **456 candidate tests pass, zero fail**, with legacy lanes disabled. The 34
  explicitly named baseline/legacy comparison cases remain excluded.
- **618 reported passes and 36 reported failures** in the unchanged 654-test
  migration corpus. Both the fresh-boundary test and an additional #3800 creation
  case now pass unchanged. Two remaining reported failures are upstream
  expected-failure assertions that now succeed.
- **5,683 normal-entry tests pass, zero fail, two skips.** Most of that suite
  still exercises legacy exports; it is not a replacement for candidate testing.
- **500 seeds × 60 operations = 30,000 overlap steps pass** on the retained
  runtime, including the final merge correction. This is finite evidence.
- Eight new fresh-mount tests cover both producer placements, one/two held
  inputs, early unmounts, scheduled child publication, and owner cleanup.
  Two additional deferred-join cases split the proposal reads across separately
  created children; abandoned attempts still do not merge their actions.
- The stage-89 branch, late-reader, owned-child, and 500-publication bookkeeping
  checks remain green. Five paired GC/memory probes retain zero disposed reader
  payloads in either runtime. The pending-observer probe reclaims all 1,000
  disposed payloads in each runtime.
- Source TypeScript checking, production build, and diff whitespace checks pass.
  The build retains previously documented repository warnings.

The remaining migration classifications are 28 category-2 differences and eight
category-4 deferred outside-read cases. No category-3 decision remains in this
selected corpus.
There are no unclassified or currently identified category-1 failures in this
selected corpus. This is not a claim that every scalar graph is correct or that
the omitted APIs work.

The source and bundle hashes, reports, paired timelines, raw benchmark samples,
incremental patch, and rejected experiments live in `results/scalar-stage90`.
The retained source was restored after the unsuccessful cost experiments and
the focused regression tests were rerun. The measured ordinary benchmark bundle
was checked byte-for-byte against a fresh bundle of that retained implementation.

## Measurements against next

All baseline measurements use next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, on Node 24.19.0. Baseline tracked
source is unchanged; existing untracked comparison tests were preserved.
No earlier experiment is used as a performance baseline.

Seven alternating fresh-process pairs per ordinary synchronous workload:

| Workload | Candidate / next time |
| --- | ---: |
| Signal read | 0.949 |
| Memo read | 0.965 |
| Write and flush | 0.983 |
| Equal write | 0.968 |
| Memo write | 1.016 |
| Ten writes per batch | 0.963 |
| Chain | 0.964 |
| Diamond | 1.051 |
| Memo fan-out | 0.962 |
| Effect fan-out | 1.042 |
| Branch switch | 0.950 |
| Signal creation | 0.875 |
| Memo creation/disposal | 0.987 |

Below 1 is faster. Many ranges overlap; small differences are not established
portable improvements or regressions. These measurements do not support a claim
that the candidate is either faster or slower across the board.

With an unused optimistic primitive present, seven paired samples give memo
reads 0.933, chains 1.005, diamonds 0.998, and memo creation/disposal 1.115.
That last case remains a cost concern. A journal-callback guard was tested in a
nine-pair follow-up, but the measurements were inconclusive (paired median 1.019,
raw medians about 119 ns candidate and 106 ns next). It added a flag and bundle
bytes without a reliable demonstrated benefit, so it was removed. Neither that
follow-up nor its bundle is presented as the retained implementation's result.

Writes to the deepest of 1/4/16 active overrides cost 2.440/2.087/1.916 times
next in three alternating pairs. A separate five-pair workload propagating a
write to the first override through 1/4/16 boundaries costs roughly
2.1/3.1/4.6 times next for callback inputs; direct inputs cost roughly
2.1/3.1/4.7 times next. These are distinct workloads.

The callback optimistic boundary occupies about 1,114 bytes versus next's 556;
the direct-accessor form about 1,073 versus 568. This is approximately the
expected two-node cost. It does not justify the whole active propagation gap.

| Import scenario | Next Brotli bytes | Candidate Brotli bytes |
| --- | ---: | ---: |
| Ordinary/action | 8,116 | 8,064 |
| Optimistic | 9,864 | 11,579 |
| Pending | 10,419 | 12,226 |
| Latest | 10,368 | 12,091 |
| Refresh | 10,117 | 8,299 |
| Optimistic and refresh | 10,208 | 11,788 |

The ordinary bundle remains slightly smaller. Optimistic and pending imports
are approximately 17% larger. No thresholds have been increased, and these
checkpoints do not establish performance/size acceptance. Active propagation,
feature size, and the inactive creation concern need further optimization.

## Accepted ruling: a derived guess belongs to its executing update

The separate ordinary nesting and derived-write assertions remain unchanged.
The derived-write test now names the accepted rule rather than a provisional
characterization. The production comparison was rerun after all retained
runtime changes:

- An ordinary source update starts a pending input. A guess over it starts
  downstream async work. When that work answers, its memo writes another guess
  using `ownedWrite`. Next displays the second guess until the original input
  answers; the candidate keeps the second output at its base value because the
  executing publication update is already finishing.
- In the control where an explicit action body holds the outer guess over a
  constant input, next and the candidate both keep the second output at base.

The candidate therefore does not uniformly inherit the longer lifetime of an
optimistic input merely because a computation reads it. It uses the update
executing the setter. Both variants keep ordinary readers coherent; this is a
lifetime question, not a consistency exception. Normal event/action nesting is
covered separately and is not changed by this choice.

The user accepted the executing-update rule on 2026-11-04, conditional on checking
explicit maintainer reasoning. The provenance check does not establish that
next's expectation was accidental: [the maintainer ruling, section 16.1](../../documentation/plans/size-reduction-carve-step1.md#161-the-rulings-maintainer-2026-10-01)
explicitly says a lane opens in the frame in which the write is made, "ends when
the parent ends," and applies recursively. Section 17.2 explicitly includes the
owned write during a lane's landing round. The test arrived in commit
`143c530beaf3d0a9df305c81b315a1862ec2ef30`, incorporated through PR #3774.

Our model retains the principle that a guess belongs to its executing update and
ends with that parent. It changes the identification of that parent: a completing
publication update rather than next's persistent input lane. Thus this is an
intentional observable semantic change, not a claim that next's test was wrong
or incidental. The audited reasoning supplies no separate requirement to inherit
an input override's longer lifetime independently of that lane representation.
Such inheritance would also need a rule for derivations combining sibling
overrides. The explicit-action control already agrees with next.

No runtime field, branch, allocation, or performance measurement changed for
this ruling. The original upstream test and raw failure report remain unchanged;
its audit classification is now category 2. Separate tests continue to cover
ordinary nested action lifetimes and the absence of transient badge publication.
After recording the decision, all six derived-guess, nested-lifetime, and
lifetime-retention tests passed. The retained runtime hashes still match the
measured source, the upstream lane-contract test byte-matches the baseline, and
the whitespace check passes.
