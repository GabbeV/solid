# Held proposals, observation preparation and first publication

This continues the scalar audit on top of the independent input/override
lifetimes in [stage 120](INTEGRATION-120.md). No input/action lifetime join was
restored. The comparison checkout remains unmodified next `4fe75321`.

## Retained changes

**Netted custom equality.** The setter's existing normalization of a repeated
write back to an equal committed value was gated on the removed verdict-lane
hook. Gate it on the shared observation hook instead. A custom comparator's
equal replacement no longer manufactures pending work. This repairs the
existing #4483 assertion without adding fields or another setter hook.

**Prepare observations of held synchronous values together.** A synchronous
proposal can be held without carrying `STATUS_PENDING`. Previously latest
prepared that proposal before publication while pending waited for the later
settle phase. For an action changing a signal from -0 to +0 with `Object.is`,
a binding of `[isPending(value), 1 / latest(value)]` published:

```
[false, -Infinity] -> [false, Infinity] -> [true, Infinity]
```

It now publishes `[true, Infinity]` directly, then `[false, Infinity] when the
action finishes. All sixteen existing held signed-zero variants pass. This
does not make unheld synchronous writes pending. Latest retains its explicit
ability to prepare an unheld staged value; pending describes an actual hold
or pending status.

**Wait for a missing published input.** A higher calculation reading a lower
held node that had never published used to consume the lower proposal. The
depth check then restarted that calculation, which consumed the same proposal
again without making progress. Now the existing stale-reader registration and
`NotReadyError` suspend that read until the lower node publishes. No retry
counter, new field, or saved diagnostic is added.

The scalar regression starts an input behind Loading, stages its first answer
42 in an open lower action, then guesses 1 on an independent optimistic output.
Its label reads that input only when the guess is selected. While the lower
action is open, the visible output stays `0 / idle`; after it ends, the upper
output and label publish `1 / 42`. Ending the upper action restores `0 / idle`.
Removing the first-publication wait makes the test stall. The earlier derived
store rejection/pending-probe retry case also passes. Next instead publishes
the upper guess while the lower input is still unpublished; this is an
intentional consequence of enforcing the selected higher context's input rule.

## One revised experiment expectation

An existing #3884 feedback test combines pending and latest through a memo.
Preparing their held proposals together means this memo joins them as ordinary
same-depth proposals. When latest's own async consequence is held, pending's
true proposal waits too. The published pending output remains false, and the
memo keeps its previous result. A direct render binding reads the published
outputs independently and can show `true:0`.

The new `unified-observation-peer-publication` tests isolate this from feedback:

```ts
const pending = () => isPending(source);
const ahead = () => latest(source);
const details = createMemo(() => ahead() ? request.promise : 0);
const combined = createMemo(() => `${pending()}:${pending() ? ahead() : 0}`);
```

With source 1 held by an open action and details waiting, combined stays
`false:0`; resolving details publishes `true:1`. Replacing the two observation
outputs with explicit optimistic boundaries has the same history. Omitting
the combining memo lets each version publish `true:0` before `true:1`.
All four cases assert complete combined-output histories and separate bindings.
Next agrees with both memo cases; its direct-render cases hold both outputs.

The #3884 expectation is revised to match the already retained memo coordination
rule. This is not an exception allowing different readers of a pending output
to disagree. The test still asserts both the displayed result and external
observations at every checkpoint. No consistency assertion is removed.

## Rejected trials and remaining work

Sampling every synchronous staging as a pending candidate was incorrect.
One variant briefly selected false before a landing had been registered as
held, then true again, duplicating a Loading fallback publication. Treating
every staging as pending instead caused pulses on entirely synchronous writes
and exposed unflushed changes. Neither change is retained. The final guard
prepares staged pending observations only when the input is held.

The first variant happened to pass three deferred-arrival assertions. Those
were not sound fixes: their failures remain in the final result. Deferred
landings can still publish `new value / true` before `new value / false`.
Resolving that lifecycle timing is further scalar work. Optimistic stores and
`until` remain deliberately deferred; other scalar and integration failures
also remain. This stage is not scalar acceptance.

Follow-up: [stage 122](INTEGRATION-122.md) repairs the deferred-arrival timing
through the shared restoration path and adds async reversal/supersession tests.

## Validation

Receipts are in `results/integration-stage121/`.

- Complete signals suite: **5,159 passed, 2,147 failed, 2 skipped**. Compared
  with stage 120, seventeen existing assertions now pass and five new tests
  pass. The only changed passing expectation is the classified #3884 case;
  there are no new remaining failures.
- Built web suite: **1,584 passed, 139 failed, 1 skipped**, with the exact same
  existing failure set as stage 120.
- Final focused scalar selection: **41 passed**.
- All build tiers, property mangling, pure-annotation checks and declaration
  build pass. No size cap or test timeout was raised.
- Next controls run the same five new scalar tests. Two memo-composition cases
  pass; the direct-render and missing-first-publication cases differ as above.

These are finite test results, not a proof for arbitrary dependency graphs.

## Size and performance

The repository's production size harness reports:

| Import scenario | Next minified / Brotli | Experiment minified / Brotli |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 B | 21,153 / 7,904 B |
| Ordinary store | 43,868 / 15,089 B | 45,222 / 15,513 B |
| Pending/latest | 33,615 / 12,239 B | 34,629 / 12,427 B |
| Scalar optimism, supplementary | 31,722 / 11,561 B | 34,229 / 12,471 B |

The supplementary scenario uses the existing bundle harness and the same
imports as stage 120. Ordinary core/store sizes are unchanged by this pass.
Existing size caps still fail; thresholds are unchanged.

Runtime measurements use the repository's `tests/core/reactivity.bench.ts`
and `tests/core/creation.bench.ts` against the built production entries. Runs
alternate with pinned next on CPU 4, with no concurrent builds or test suites.
Raw results and exact commands are in `bench-metadata.json`. The creation
samples have substantial GC variance; they cannot certify a small change.
An additional five-pair update-only series excludes the allocation benchmarks
and records its commands in `updates-metadata.json`. Median invocation times
from that series are:

| Repository benchmark | Next | Experiment | Experiment time vs next |
| --- | ---: | ---: | ---: |
| updateSignals:update1to1 | 2.1492 ms | 2.3132 ms | +7.6% |
| updateSignals:update1to1000 | 0.06510 ms | 0.06890 ms | +5.9% |
| propagation:diamond | 0.03530 ms | 0.03395 ms | -3.8% |
| propagation:avoidable | 0.03266 ms | 0.03408 ms | +4.4% |

Negative means less elapsed time. These are whole-current-implementation
comparisons to next, not attribution of cost to the three changes in this pass.
In particular, the update1to1 result is a regression to investigate, not an
acceptable parity claim. The fan-out run ranges overlap (next 0.05661–0.07068 ms,
experiment 0.05959–0.08041 ms), so its exact percentage needs more precision.
The diamond improvement is retained in the report despite its small size.

The three-pair creation series measured these median changes against next:
render-effect creation -17.6%, owners -4.7%, signal creation -5.2%, unconnected
memos -5.0%, one-input memos -9.5%, and memo-tree creation/disposal +7.2%.
These creation figures are preliminary: for example, experiment one-input memo
creation ranged from 1.752 to 13.279 ms, and signal creation from 0.143 to
0.667 ms. They do not establish the claimed magnitudes as stable wins or losses.
The mixed allocation/update series also gave a different update1to1 result;
the isolated update series above is the more useful checkpoint for that path.
All individual samples and medians are preserved in `bench-summary.json`.

No allocation or retained-memory measurement was added in this pass. Ordinary
node layouts are unchanged. Neither runtime performance nor size is accepted
as complete.
