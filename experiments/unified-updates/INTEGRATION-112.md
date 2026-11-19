# First answers delivered before a replacement flush

Baseline remains unmodified next `4fe75321`. The user chose next's first-answer
behavior: when an initial promise resolves and an input write queues its
replacement before the promise reaction runs, preserve the answer and allow
ordinary derivations to calculate from it. `latest` can publish that result
while the replacement remains pending. An identity memo must not lose an answer
that a direct observation can see.

For a memo initially awaiting `10`, with `doubled = data() * 2`:

```ts
first.resolve(10);
setVersion(1);
```

`latest(doubled)` can show `20` before the replacement answers. A 500 ms gap
between these calls has the same displayed value while the replacement is
pending, but the first result has already published normally before the write.

This does not resurrect cancelled requests. A synchronous flush can supersede
the request before its reaction delivers the value. In particular, a generator
action flushes when it yields. Resolving the promise and replacing its input
inside that action segment can therefore discard the answer. The depth-one
control is verified against next; the experiment also exercises depth three.

## Implementation

The shared engine enables next's existing first-answer replay through its
optional observation hook instead of the disabled verdict engine's hook. It
reuses the missed-wake flag and the extension's existing `_served` stamp: a memo
gets one complete pass over the answer, including repeated reads, then waits on
the replacement. The stamp is written only when this replay occurs. No property
is added to every node, and settled synchronous reads gain no branch.

Shared updates may already hold a staged first answer when a sibling source is
read. Its read has already selected and joined the appropriate update, so that
hold does not forbid calculating the proposal. Publication remains held;
`latest` and `isPending` expose their separately published outputs.

Observation selectors distinguish an unpublished answer from no answer. This
also applies to callback `isPending` control flow: after observing the pending
output, its callback can use the staged first answer without joining the input
hold again. No general outside-read exception is restored.

An initial trial selected every staged first value during observation
preparation. It caused nontermination in Loading/first-publication cases. The
retained preparation and selector rules permit this before initialization only
while the input is still pending and has a staged answer. A ready first answer follows
normal initialization instead of opening a competing observation update. Both
previously stalled test files pass with this restriction.

An existing pending watch must survive the interval between that first answer
becoming ready and its initialization commit. Dropping it at readiness left
pending stuck true when the landing compared equal. The fixed 1,500-case
async generator found two instances; retaining the existing watch until the
commit fixes both without adding a field or another tracking collection.

## Validation

All 25 existing tests across the first-answer/reask, released-reader,
two-source resolution-order, and first-load supersession files pass. Controls
include an obsolete answer delivered after its replacement, repeated reads,
and a derivation that also waits on an unrelated source.

The sibling-effect assertion in `answered-then-reasked-same-tick.test.ts` now
allows either ordering of the two final callbacks, following the user's prior
unspecified-sibling-order ruling. Exact values, counts, and the preceding
publication remain asserted. No expected-failure markers were added.

`unified-first-answer.test.ts` adds four active-layer cases at depths one and
three, with and without an action flush preceding promise delivery. It checks
observable publications and delivery of an abandoned older request.
`web/test/answered-then-reasked.spec.tsx` adds six DOM cases: same-turn and delayed
writes, through zero, one, and three inactive optimistic boundaries, with an
ordinary consequence of the `latest` output. The earlier stale-render JSX
regression remains part of validation.

Receipts are in `results/integration-stage112/`. Intermediate trial reports
are retained as rejected evidence, not acceptance results.

The final complete signals run (`signals-complete.json`) has 5,077 passing
results, 2,181 failures, and two skips. Sixteen formerly failing tests now pass,
all four new active-layer cases pass, and no previously passing test fails.
Passed results include expected-failure tests. The existing unsupported APIs
and scalar audit failures are still failures, not silently accepted differences.

The complete web run (`web-complete.json`) has 1,578 passing results, 142 failures,
and one skip. Compared with stage 110's last complete web run, two existing
first-answer tests now pass, all six new DOM cases pass, and no previously
passing test fails. The existing 1,500-case generated regression gate passes
without editing its baseline. The final test comparisons are recorded in
`signals-complete-changes.json` and `web-complete-changes.json`.

All signals tiers build; property mangling, pure checks, declarations, and the
generated rules-index check pass. `_served` was already an optional extension
property in the source; its newly reachable shared implementation requires the
generated mangling map entries now recorded with the change.

## Size and scope

The repository's size harness measures the built packages against next
`4fe75321` with identical scenario definitions:

| Scenario | Next minified / Brotli | Experiment minified / Brotli |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,153 / 7,904 |
| + ordinary store | 43,868 / 15,089 | 45,222 / 15,513 |
| + isPending/latest | 33,615 / 12,239 | 34,449 / 12,380 |

The ordinary core and store measurements are unchanged by this patch. The
observation bundle is 141 Brotli bytes larger than current next. All three
experiment scenarios still fail their current absolute caps; thresholds were
not raised. No new runtime-performance claim is made. Store optimism and
`until` remain deferred, and this change does not complete the scalar audit.
