# Lifetime readiness before optimistic execution

The user's proposed model is transparent while no override exists:
pending has false as its input value; latest reads its ordinary input. The
retained latest fallback's refusal to consume an unheld proposal violates that
model and permits the stale-latest request 12 from stage 160. Its presence in
an earlier shared-observation checkpoint predates the stage-141 context change.
The stage-160 trial's global transaction-count guard is not the desired model:
an unrelated pending update must not decide whether this boundary is transparent.

The user asks whether request 21 can be avoided by discovering that its lifetime
has already expired. Its own optimistic execution must not define that lifetime.

## Executed probe

Use the transparent latest trial with the stage-160 one-memo program. Instrument
the existing input transaction's `blocked()` check immediately before and after
`stageLayer`, before the queued optimistic computation runs. The trace is:

```
request 22
select latest override 2: input blocked before=true, after=false
request 21
request 22
```

The readiness information therefore exists before request 21. The observation
preparation loop deliberately returns after staging new overrides, draining
their consumers before its later retirement check. That ordering misses this
opportunity; executing 21 is not needed to establish the lifetime in this case.

A tiny trial immediately retires the newly selected override when the input's
existing lifetime check reports ready. Its requests are **22, 22**, and only
the last answer publishes. Request 21 is eliminated. The duplicate 22 remains
because propagation has already marked the consumer for recomputation. This
does not establish safe reuse or general correctness of early retirement.

An open-action control still requests **21**, publishes it when answered, then
requests and publishes **22** when the action ends. The action supplies the
independent lifetime. Both probes assert initial and final displayed values;
their complete request/publication traces are archived.

## Scheduling direction

The next direction to evaluate is to finish an input update's currently runnable
work, prepare boundary ownership and judge input lifetimes, then execute the
surviving optimistic work. This does not wait for input promises or require
optimistic execution to establish its own lifetime. The existing pure-phase /
settlement loop is a starting point; work currently shares a height-ordered heap
and nested reads can synchronously pull computations in other update contexts.
Those pulls, equal-value propagation, and owned frames need investigation before
claiming a small or general scheduling change. No new queue or metadata has
been introduced by this stage.

No runtime changes are retained. Sources compare exactly with stage 159, and
build artifacts were not changed. These two small probes are mechanism evidence,
not a replacement for full-suite validation or a performance measurement.
Receipts: `checkpoints/integration-stage161.tar.xz`.
