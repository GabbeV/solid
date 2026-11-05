# Structural caching and boundary construction refinement

Historical stage-five results. See [FOREIGN-INPUT-RESULTS.md](FOREIGN-INPUT-RESULTS.md)
for the subsequent accepted foreign-input behavior and measurements.

This is still a local scalar prototype, not a mergeable replacement. Held-chain
performance improved substantially; inactive overhead, boundary memory, public
API integration and semantic scope still prevent acceptance. No size or timing
threshold has been relaxed.

## Changes

The context-discovery cache now survives flushes whose dependencies do not
change. It validates the dependency structure and boundary ownership rather
than invalidating merely because another flush ran. A new transitive branch
regression found that retained links from a memo's previous computation could
incorrectly authorize a committed-input read; traversal now checks the current
dependency generation at every hop. Ordinary node shapes and settled read paths
remain unchanged.

Pending observation of a source accessor uses the accessor's existing node
metadata instead of creating another producer memo. It preserves the input
memo's own disposal/revival behavior. Arbitrary callbacks still use a producer.
Boundary construction is separate from guess-setter construction, allowing the
pending-only bundle to omit setters and their action-lifetime implementation.

Legacy lane entry, lane-specific staging and pending-flight selection moved
behind optional scheduler hooks. This removes those branches from the common
implementation and allows unused lane code to be omitted from ordinary bundles.
Existing legacy behavioral tests pass; the generated rule index was refreshed
for moved source citations. The legacy APIs themselves remain available.

## Validation

- Full signals suite with the expanded seeds: 301 files, 5,237 passed,
  22 existing expected failures, two skipped.
- 300 scalar seeds, 200 pending seeds and 100 branch seeds: 30,000 operation
  checkpoints, including asynchronous supersession and publication coherence.
- Two new deterministic checks cover transitive removal of observation context
  after warming the cache, and direct-input memo disposal/revival.
- TypeScript reports the same 26 existing diagnostics. The baseline log also
  contains a diagnostic in our separately copied F5b reproduction; excluding
  that added reproduction, diagnostic text is identical.
- Production DOM replays exercise F5b, late mounting, async pending observation,
  supersession and imperative reads matching the displayed frame.
- Five memory samples collect all 30 disposed reader payloads while the action
  remains open. Baseline retains all 30 until completion; both collect them after.

The finite tests do not prove the model. General dynamic discovery, overlapping
answer provenance, stores, SSR, public observation APIs and other boundaries
remain incomplete. The old public API's F5b expected failure is still present;
the experimental scalar path is the one whose reproduction passes.

## Measurements

Baseline is `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Node 24.19.0, production
Rollup and repository property mangling, identical application bundling. Each
reported timing uses five alternating fresh processes without concurrent tests
or builds. Raw current data is in `results/`; stage-four data is archived under
`results/discovery-stage4/`.

| Ordinary workload | Baseline median ns | Candidate median ns |
| ----------------- | -----------------: | ------------------: |
| Settled read      |               6.77 |                7.01 |
| Write and flush   |              228.8 |               236.4 |
| Signal creation   |               59.4 |                65.5 |
| Memo chain write  |             2674.3 |              2761.7 |
| Diamond write     |              997.4 |               918.0 |
| Fan-out write     |            16182.3 |             15952.9 |
| Memo creation     |              586.8 |               594.2 |

Small differences are not reliable speedup or acceptance claims. Creation and
some other samples have wide ranges. These measurements follow lane extraction;
the later boundary-factory split does not change the ordinary bundle.

| Pending workload         | Baseline median ns | Candidate median ns |
| ------------------------ | -----------------: | ------------------: |
| Inactive, ordinary read  |               6.63 |                6.66 |
| Inactive, ordinary write |              222.2 |               243.5 |
| Held input, depth 1      |             1487.5 |              1363.9 |
| Held input, depth 4      |             2396.0 |              2207.2 |
| Held input, depth 16     |             5230.7 |              4825.8 |

The earlier depth-16 regression (approximately 34%) no longer appears in three
successive structural-cache runs. The latest ranges overlap: baseline 4611.8–
5429.5 ns; candidate 4621.3–5215.1 ns. One preceding run had a large candidate
outlier. This supports the refinement, not a universal performance claim.

Inactive write overhead remains approximately 10% at the median, with separated
ranges in the latest run. That is an unresolved performance problem. Idle hooks
still execute for an imported observation implementation even without live holds.

| Retained bytes per boundary | Baseline | Candidate |
| --------------------------- | -------: | --------: |
| Callback input              |    516.0 |    1349.7 |
| Direct source accessor      |    529.1 |     940.3 |

Avoiding the producer helps direct accessors but does not establish acceptable
boundary cost. Callback memory remains high. These are retained-heap estimates,
not exact allocation counts; sampled transient allocations from the previous
stage have not yet been rerun for this refinement.

| Application        | Baseline minified / Brotli bytes | Candidate minified / Brotli bytes |
| ------------------ | -------------------------------: | --------------------------------: |
| Ordinary imports   |                     21918 / 8116 |                      22233 / 8234 |
| Optimistic imports |                     27250 / 9864 |                      25970 / 9622 |
| Pending imports    |                    28812 / 10419 |                      26555 / 9765 |

The ordinary bundle is still 315 minified / 118 Brotli bytes larger. The other
bundles have incomplete feature parity, so their smaller size is not acceptance
evidence. The constructor split alone removes 411 minified bytes from the
pending scenario by allowing unused guess APIs to disappear.

## Explicit semantic and API gaps

Run `node experiments/layered-updates/independent-pending.mjs`:

```ts
const [x, setX] = createSignal(0);
const [y, setY] = createSignal(0);
const status = createMemo(() => isPending(x));
const label = createMemo(() => `${status()}:${y()}`);
```

The script uses the private accessor helper for the candidate and the public
`isPending` wrapper for baseline. An action holds y=10; then another holds x=1.

| Moment            | Legacy label / y | Prototype label / y | Proposed broader rule |
| ----------------- | ---------------- | ------------------- | --------------------- |
| Both actions open | true:0 / 0       | false:0 / 0         | true:0 / 0            |
| y action ends     | true:0 / 0       | true:10 / 10        | true:10 / 10          |
| x action ends     | false:10 / 10    | false:10 / 10       | false:10 / 10         |

The prototype's boundary relation covers its input update, so the y proposal
holds the pending-true update. Legacy displays pending-true but links the lower
updates' lifetimes. The proposed behavior uses committed y for the optimistic
status update without linking the two lower actions. This broader scope needs a
user decision; the existing narrow test is a characterization, not an accepted
semantic constraint. All alternatives must keep status and label coherent.

Run `node experiments/layered-updates/callback-observation.mjs`:

```ts
isPending(() => {
  x();
  return 0;
});
```

When x=1 is held, legacy reports true. The private helper reports false because
it observes a producer whose result remains 0. This is a deferred API gap: it
cannot be advertised as a replacement for the public callback window. The
public name should remain `isPending`; the helper is experimental scaffolding.

## Reproduce

Use the commands in `DISCOVERY-RESULTS.md`, with the new characterization scripts
above. `measure-pending.mjs` now reports both callback and direct-source retained
memory. No remote publication or PR was created.
