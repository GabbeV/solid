# Stage 77: retain the common optimistic explanation

The user prefers explaining `isPending` as optimistic state and avoiding
differences unless their necessity is understood. This stage retains stage 76's
input-demand forwarding. It does not add a pending-specific exemption, a
Loading-arming exemption, or an error for reading pending inside an async memo.
Runtime source is unchanged from the stage-76 retained checkpoint.

## Explicit comparison

The production audit compares the automatic pending output with this explicit
optimistic boolean:

```ts
const [pending, guessPending] = createOptimistic(() => {
  data();
  return false;
});

const change = action(function* () {
  setId(1);
  guessPending(true);
});
```

Initially data has a committed value. The new data request remains unresolved.
The action body returns without awaiting an external promise, so its unresolved
input is significant to its remaining lifetime. The automatic version instead
writes id directly and reads `isPending(data)`.

The following actual publications were checked in both production builds:

| During the request | next automatic | next explicit | candidate automatic | candidate explicit |
| --- | --- | --- | --- | --- |
| Guard only | id=1, true | id=0, true | id=0, true | id=0, true |
| Loading rearmed by the boolean, no outside guard | id=1, fallback | id=0, fallback | id=0, fallback | id=0, fallback |

All settle to id=1, false, and the new content if rendered. This establishes a
concrete common behavior in the candidate; it does not prove the automatic
primitive and user actions are equivalent under every lifetime or API option.

Three new tests compare both forms with a guard, Loading alone, and Loading plus
an outside guard. They check initial publication, the pending interval, an
unrelated write, late readers where a guard is present, and resolution. They
compare each binding's full sequence of distinct published values, not sibling
callback order. They also pin the combined binding's sequence:

```
unrelated:id:pending
0:0:false -> 0:0:true -> 1:0:true -> 1:1:false
```

## Loading expectations

Under the common forwarding rule, Loading's `on` condition remains a live
observer outside its content. Showing the fallback does not remove that
observer, so it does not release the data input's hold. This is the same result
as an explicit optimistic boolean in that position.

The four stage-76 failures in `layered-loading.test.ts` now explicitly require
the retained input hold. They are classified as an intentional semantic change
relative to next for the working common model, supported by the new equivalence
tests. No assertion was weakened to allow tearing or multiple alternative
results. A plain `on={id()}` retains its existing publication behavior; an
independent outside pending guard retains demand regardless of Loading.

If this common behavior proves undesirable, reconsider the observation/publication
rule against both pending and ordinary optimistic boundaries. Do not silently
restore next's pending-only exception or exempt Loading's arming reader merely
to restore a green compatibility result.

## Feedback: lifetime comparison is not yet equivalent

The audit separately makes the request-producing memo read the pending/optimistic
boolean for its **count input**. This is the original feedback shape, not the
guard-over-data example above.

In the candidate:

- Automatic pending: displayed boolean remains false. Calculations run with
  `(count,pending)` values `(0,false), (1,false), (0,true), (1,false)`.
- Explicit override with an immediately returning action: displayed boolean
  also remains false, but calculations only run `(0,false), (1,false)`.
  Its input producer is already ready; the action expires before that override
  performs the automatic pending case's feedback calculation. Equal final
  displays do **not** establish lifecycle equivalence.
- Explicit override whose action yields the request's promise: displayed boolean
  becomes true. Calculations run `(0,false), (1,false), (0,true)`. The externally
  open action remains alive even when the lower calculation is superseded.

Therefore, a request lifetime independently kept open is materially different
from a pending override retired according to the lower update's current work.
Choosing the override and its lifetime is legitimately part of the primitive's
contract; the common propagation/publication machinery has not been shown to
need different rules. The automatic lifetime's suppressed indicator remains an
open question. Neither these tests nor matching one visible checkpoint establish
that it is correct, and no error-on-probe or in-flight read-posture exception has
been implemented.

The audit records all calculations and render callbacks for 18 scenarios across
candidate and pinned next. It uses an initially ready data result and a single
controlled request. Errors, multiple requests, nested automatic lifetimes and
first-load behavior are not proven equivalent by this small comparison.

## Validation and reproducibility

- Focused tests with legacy lanes disabled: 56 passed in seven files.
- The new test file typechecks with the existing repository settings.
- Full normal-entry validation: 5,598 passed, 22 existing expected failures,
  two skipped, 335 files. The log is in `results/pending-model-stage77/final`.
- The runtime and production module hashes match stage 76. Its size and ordinary
  synchronous measurements remain applicable; no new performance result is
  claimed. Active throughput and feature bundle size remain acceptance issues.
- The last unchanged upstream migration run remains 572 passed / 80 failed;
  the normal-entry green result must not be substituted for that migration count.

```sh
node experiments/layered-updates/pending-optimistic-equivalence.mjs packages/signals/dist/scalar/index.js loading pending
node experiments/layered-updates/pending-optimistic-equivalence.mjs packages/signals/dist/scalar/index.js loading explicit-work
node experiments/layered-updates/pending-optimistic-equivalence.mjs packages/signals/dist/scalar/index.js feedback explicit-external
cd packages/signals
node node_modules/vitest/vitest.mjs run --config vite.scalar76.config.ts
```

Raw production comparisons are in `results/pending-model-stage77/`, with the
script, tests, source hashes and validation logs in `final/`. All work is local.
