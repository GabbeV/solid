# First held values through latest

The reference remains unmodified next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`. This checkpoint repairs first-value
selection in `latest`; scalar correctness and size/performance acceptance are
still incomplete.

## Observable case

```ts
const [id, setId] = createSignal(0);
// An existing binding displays id().
const save = action(function* () {
  setId(1);
  yield actionEnd.promise;
});
save();
// After the held update has flushed, mount another root:
const born = createMemo(() => id());
const preview = createMemo(() => latest(born));
```

The existing binding stays at 0. `born` has calculated 1 but has never published
it, so an ordinary read still waits. A reactive binding of `preview` can display
1 while the action stays open: this is the explicit `latest` boundary. The
experiment previously waited for the action to end. Unmodified next already
exposes this synchronous first proposal. Two existing #4429 tests cover the
same failure when another memo pulls the first value.

The repair also selects an async first answer once it exists. Next still waits
in the minimal async variant, despite D-22 describing produced first answers as
available through `latest`. The shared model uses the same selection path for
both. This does not let an optimistic consequence extend the input's lifetime.

## Mechanism

Three initialization shortcuts suppressed the selection: a source with no
committed value bypassed preparation even with a ready proposal; an output
waiting for its first answer bypassed selection; and fallback treated a ready
first answer as if no answer existed. `latest` now sends these proposals
through its existing `stageLayer` path. A genuinely new output still uses its
normal first initialization, while an output already held with the input
transfers into the selected output update. Superseding an unpublished first
proposal uses that same path.

A first imperative read must not create a published observation from an
unpublished input as a side effect. With no existing observation and no
reactive context, it reads the input normally. Existing observation outputs
continue to use their ordinary published reads. This preserves the accepted
deferral of next's outside flushed-value exception.

No shared readiness rule, node field, or transaction representation changed.
`isPending` keeps its distinct first-load contract. An earlier trial broadened
the shared observation preparation and changed that contract, including
premature derived-store seeds; it was rejected. Another trial transferred first
observations in the common initializer. The retained change instead uses
`latest`'s existing selection mechanism.

## Validation

- Full signals: **5,742 passed, 1,974 failed, 2 skipped**. The two existing
  #4429 failures are fixed and all ten new tests pass. No new failing identities.
- Full web: **1,731 passed, 125 failed, 1 skipped**. Unchanged failing identities.
- Mangled production selection: **185 passed**, with one private subscriber
  inspection case excluded from the built-package invocation.
- Builds, types, production/observation purity, and diff checks pass.

There are **21 non-deferred signals failures and 10 non-deferred web failures**.
The other 1,953 signals and 115 web failures remain the deferred optimistic-store
and `until` inventory.

The new ten-case file covers sync/async first inputs, inline/memo-wrapped
`latest`, downstream async holding, unrelated reruns, late readers, and
supersession before the first publication. The superseded consequence's answer
cannot publish the old proposal. The existing #4429 tests keep their original
expected values.

One test is an ordinary-propagation control: an already initialized output can
serve a later independent reader while a newly created async consequence has
no first value. The synchronous `latest` initialization matches that behavior;
an async first proposal still holds its output readers together. The initial
trial incorrectly assumed both situations had an unpublished output. The
control demonstrates the distinction; no inconsistent pair is allowed.

On next, five of the ten new cases pass. The five async-first-value cases fail
at different intermediate/publication assertions, including inline versus
wrapped behavior. These comparison receipts are retained rather than treating
next as a universal oracle for this repair.

## Size and performance

Shipped scalar import scenarios, bytes:

| Imports                    | next minified / Brotli | experiment minified / Brotli |
| -------------------------- | ---------------------: | ---------------------------: |
| Ordinary core              |         19,825 / 7,421 |               21,456 / 8,056 |
| Scalar optimism            |        30,556 / 11,180 |              37,114 / 13,417 |
| Optimism with observations |        35,643 / 12,920 |              43,233 / 15,261 |

No new throughput claim is made. All changes are in the opt-in `latest` module;
ordinary node creation, reads, writes and coordinator representation are
unchanged. The overall size and performance gap against next remains an
acceptance issue.

`checkpoints/integration-stage178.tar.xz` preserves the broad rejected trial,
focused probes, next comparisons, full-suite reports and build/size receipts.
