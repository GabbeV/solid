# Queued creator retries and lazy-node disposal

The reference is unmodified next `4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`.
This is a scalar correctness checkpoint, not acceptance of the full experiment.

## Defect and repair

An optimistic output can have a ready first value while a separate action is
mounting a child that derives from it asynchronously. The child discovers the
higher context and retries its creator. That retry must not merge the whole
optimistic publication into the mounting update and make unrelated existing
readers wait for the new child's async work.

Immediate creator retries already marked their execution. Queued creator
retries did not. Without that information, publication preparation restored
the creator to the lower update too early and merged both updates. A queued
retry now carries a one-shot bit in the existing flags word into its execution,
where it becomes the same per-execution marker as an immediate retry. Later
unrelated executions clear that marker normally. No per-node field was added.

This exposed a second bug in the existing retry-disposal deferral. A public
flush can perform several internal rounds; the dormancy sweep at the start of
each round prematurely ended the deferral. A lazy async source temporarily
losing all readers during a retry could be disposed before its replacement
subscribed, causing a duplicate request. Retry deferral now lasts until its
already-queued microtask. The microtask clears the deferral and rechecks actual
subscribers before disposal. Explicit owned disposal remains immediate.
There is no retained-value cache or new observation-forwarding rule.

The nine #4474 unread-identity cases now produce next's original sequence:
`latest=2, pending=true`, then `latest=3, pending=false`. The earlier experiment
expectation requiring an intermediate `latest=3, pending=true` was removed.
The added assertion forbidding duplicate requests and the comparison with a
prior reader both remain.

## Rejected trials

Moving every prepared higher reader directly into the incoming lower update
fixed the motivating case but failed three existing publication-consistency
tests. It was removed. Keeping the retry marker indefinitely was replaced with
a one-shot queued marker. Marking queued retries without fixing disposal
exposed duplicate requests in #4474; those failures were not dismissed as
intentional timing differences.

## Validation

- Full signals: **5,730 passed, 1,976 failed, 2 skipped**. One existing
  first-publication ownership failure is fixed; no new failing identities.
- Full web: **1,731 passed, 125 failed, 1 skipped**. Unchanged failing identities.
- Mangled production public-API selection: **179 passed**, with one private
  subscriber-inspection case excluded from this production invocation.
- Builds, types, production/observation purity, and diff checks pass.

There are **23 non-deferred signals failures and 10 non-deferred web failures**.
The remaining 1,953 signals and 115 web failures are the deferred optimistic-store
and `until` inventory. Existing coverage includes repeated ownership cycles,
subscriber counts, overlapping updates, and superseded answers; this is not a
universal proof or a complete retained-memory measurement.

The first production invocation mixed tests that import internal source
modules with the built package. Its failures are retained as an invalid test
configuration, not attributed to the shipped runtime. The corrected invocation
uses public-package tests and excludes the subscriber-inspection case that
requires unmangled private properties. The source suite still runs that case.

## Size and performance

Shipped scalar import scenarios, bytes:

| Imports                    | next minified / Brotli | experiment minified / Brotli |
| -------------------------- | ---------------------: | ---------------------------: |
| Ordinary core              |         19,825 / 7,421 |               21,456 / 8,056 |
| Scalar optimism            |        30,556 / 11,180 |              37,114 / 13,417 |
| Optimism with observations |        35,643 / 12,920 |              43,211 / 15,250 |

The size gap remains an acceptance issue. This checkpoint does not make a new
throughput claim. The ordinary node flags mask incorporates one more constant
bit; the retry branch runs in the optional coordinator. The deferral change
uses the existing dormancy set and one microtask for a retry sequence. A future
performance pass must measure the accumulated changes against next.

## Remaining work

The separate first-held-value `latest` failure is still open. A minimal probe
confirms that next can expose a newly created synchronous memo's ready held
value through `latest`, while the experiment waits for the input action to end.
The analogous async probe also waits in next; that distinction still needs
analysis. These investigation fixtures are archived, not counted as passing
regressions. Optimistic stores and `until` remain deferred.

`checkpoints/integration-stage177.tar.xz` preserves traces, rejected trials,
full-suite reports, production checks, and size receipts.
