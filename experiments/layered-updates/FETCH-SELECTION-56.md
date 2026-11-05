# Stage 56: dependency discovery must not change an already selected request

The user added a second constraint: learning dependencies must not reveal that
an already-started calculation should have fetched different inputs. Coherent
publication and ignoring obsolete answers are insufficient. The selection of
input versions for the calculation itself must not be revised solely because
another suspended derivation reaches additional reads.

Actual input changes, new source updates, and override expiration remain distinct
causes of recalculation. This contract does not forbid all recalculation, nor
does it settle every equal-value ownership or same-argument rerun case.

## Reproduction

The stage-55 dependency-discovery fixture now optionally renders an async label
of the pair `[view, peer]`. It records every invocation, before any returned
promise resolves. The view proposal is 10 and peer proposal is 20. An input
beneath the view's active override is suspended before it can read a deeper
optimistic dependency. Resolving that internal gate discovers the deeper read;
no action ends, no external setter runs, and neither the view nor peer receives
a new proposal. The label itself reads only the pair.

The current depth reference issues:

- Explicit-clear lifetime: `0:20`, `10:20`, then **`10:0`** after discovery.
- Action lifetime: `0:20`, `10:20`, then **`10:0`, `10:20`** after discovery.

Both traversal orders reproduce these results. The action lifetime masked the
publication-eligibility defect in stage 55, but does not prevent the wrong fetch.
The display remains `[0,0]` while requests are pending. Every eventual observed
pair/label publication remains coherent, and all update records drain. That is
why publication-only tests missed this violation.

`reference/fetch-selection.contract.mjs` is a new acceptance contract. All four
variants currently fail. It asserts that discovery alone cannot issue a request
with different arguments from the already selected proposal. It does not weaken
value consistency checks or demand invented compatibility bookkeeping.

## Public-API comparison against pinned next

`fetch-selection-audit.mjs` runs the same action-lifetime program against actual
entries, using controlled gates and render callbacks. Before/after discovery:

| Runtime | Before | After |
| --- | --- | --- |
| Pinned next | `0:20, 10:20` | unchanged |
| Earlier production prototype | `0:20, 10:0` | unchanged |
| Current reference accessor adapter | `0:20, 10:20` | `0:20, 10:20, 10:0, 10:20` |

This verifies the discovery regression in the reference with public accessors,
not only internal group inspection. The production prototype selects a different
initial context and is not evidence that the broader model works. There is no
new performance or size claim, and production sources remain unchanged.

## Consequences for prior experiments

The stage-41 `revisable-scheduler.test.mjs` case "an async answer revises an
unpublished upper join" explicitly expects q=12 work to be discarded and q=10
prepared after another computation discovers an a/b dependency. That historical
behavior is no longer an acceptable target under the new rule. Its assertions
are preserved as evidence of the old model, with an explicit historical warning.
Do not count a pass there as validation of a new implementation.

The production experiment also has speculative context validation in
`computeLayer`: it can invoke a function, inspect the completed body's reads,
dispose that attempt's children, and retry under a different context. Returned
promises may already represent initiated requests. That path needs request-level
validation; discarding the token does not undo the request. This stage does not
claim every such replay is the exact discovered regression or remove the path
without a replacement.

Stable context selection is now a design gate for both starting work and
publishing it. Simply retaining an old candidate while letting its inputs commit
would tear. Simply freezing a number was not proven correct by the stage-55
committed-depth shortcut. No replacement coordinator is accepted yet.

## Reproduction

```sh
node --test experiments/layered-updates/reference/fetch-selection.contract.mjs
node experiments/layered-updates/reference/fetch-selection-audit.mjs
node experiments/layered-updates/fetch-selection-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/layered-updates/fetch-selection-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/scalar-runtime.mjs
```

Artifacts under `results/fetch-selection-stage56/` retain the previous audit,
reference variants, three public-API traces, and the failing contract log. The
older default test command does not include `.contract.mjs`; its historical pass
count must not be used to claim this new acceptance requirement passes.
