# Stage 173 — context retries use NotReadyError

The user approved reusing `NotReadyError` for context retries, with a different
error if reuse proved complicated. The retained implementation uses an internal
`ContextRetry extends NotReadyError`. Application code recognizes the existing
public category; runtime catches distinguish synchronous unwinding from waiting
for an async source. The subtype is not exported by the public entry point.

## Behavior and implementation

A read of `latest`, `isPending`, or an active optimistic output can discover
that earlier reads used an incompatible update context. Stage 172 already
aborted/retried that calculation and, when necessary, its still-private creator.
This checkpoint changes the thrown control-flow token from a symbol to the
NotReadyError subtype. It does not change the context-selection rule.

```js
try {
  return [id(), latest(id)];
} catch (error) {
  if (error instanceof NotReadyError) throw error;
  return reportFailure(error);
}
```

That catch now recognizes context retry as reactive control flow. If an
application catches it and returns a substitute instead, the existing retry
flags still discard that attempt. Async functions converting the throw into a
rejected promise are covered by the same coordinator checks.

The existing suspension handlers in Loading, deferred values, flattening,
projection propagation, comparators, and observation windows rethrow the subtype
before treating it as an async wait. In particular, flattening must stop visiting
children immediately; it cannot continue as it does after ordinary suspension.
No extra retry registry, node property, or public error API was added.

The #3378 `latest-shadow-owned-write` regression now excludes `NotReadyError`
from its collection of genuine internal-write errors while still rethrowing it.
Its value/publication assertions are unchanged. This is the application-facing
control-flow consequence approved by the user, not a weakening of consistency.

## Validation

The 20 new cases cover all three optimistic primitives, local reads, synchronous
and async owned children, application catches that rethrow or return a substitute,
error-boundary exclusion, and immediate stopping of flattened child traversal.
They assert visible results and reject the substitute answer from an aborted
attempt. The previous 72 creator-retry cases also remain passing.

- Full source signals: **5,679 passed, 2,019 failed, 2 skipped**.
- Full web: **1,708 passed, 131 failed, 1 skipped**.
- Selected production public-API tests: **125 passed, 0 failed**.
- Type checking, builds, production/observation purity checks, and diff checks pass.

Failure-identity comparisons with stage 172 show no new failures. The signals
count improves by the one #3378 catch assertion described above; the 20 added
tests pass. Web failure identities are unchanged. The other 47 newly failing
signals tests from stage 172 and its 12 newly failing web tests remain under
review. They are not classified as intentional merely because their assertions
pre-date creator retries. The experiment's broader failures remain unresolved.

## Size and cost

Measured shipped scalar scenarios against unmodified next `4fe75321`:

| Imports                    | next minified / Brotli | experiment minified / Brotli |
| -------------------------- | ---------------------: | ---------------------------: |
| Ordinary core              |         19,825 / 7,421 |               21,429 / 8,035 |
| Scalar optimism            |        30,556 / 11,180 |              36,641 / 13,227 |
| Optimism with observations |        35,643 / 12,920 |              42,735 / 15,090 |

There is no new ordinary-read check or per-node field. Each actual retry now
allocates an error instead of throwing the shared symbol. It inherits the
existing NotReadyError constructor's production suppression of eager V8 stack
capture. No fresh throughput/allocation benchmark was run, so this is not a
claim that retries are equally cheap. The experiment's size and performance
acceptance gaps remain open.

## Receipts and next work

`checkpoints/integration-stage173.tar.xz` preserves reports, failure-identity
comparisons, build logs, the production test alias, and bundle measurements under
`results/integration-stage173/`. See its `validation.md` for reproduction commands.

The public control-flow question is resolved. Continue reviewing the existing
ownership and held-branch failures, then remove private-frame mechanisms only
where coherent creator retries demonstrably replace them. Stage 172's rejected
broad publication bypass remains rejected. Re-measure throughput against next
when that implementation is stable.
