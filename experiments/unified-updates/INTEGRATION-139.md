# Pending callback value-selection audit

No runtime changes. This investigation qualifies stage 138's snapshot
recommendation: outer subscription and the values used by the callback are
separate questions. An untracked snapshot does not justify arbitrary callback
value selection.

## Confirmed gap

The executable probe runs eight timelines on the experiment and next
4fe75321: synchronous/asynchronous replacement, each with an imperative,
tracked, untracked, or held-untracked reader. A render effect independently
records the published object. The callback reads its key and selects a left
or right signal accordingly. An open action holds the replacement after its
answer is ready; unrelated revision writes rerun the reader during that hold.

For an untracked callback inside a computation:

| Phase | Published key | Experiment callback key | Next callback key |
| --- | --- | --- | --- |
| Initial | 0 | 0 | 0 |
| Async replacement unresolved | 0 | 0 | 0 |
| Replacement ready, action still open | 0 | 1 | 0 |
| Action completed | 1 | No rerun in plain untracked case | No rerun in plain untracked case |

Thus the callback changes branches before publication in the experiment.
With a synchronous replacement, it already selects key 1 on the first
unrelated rerun during the established hold. This is not merely the question
of a captured pending boolean remaining stale after publication.

The current `layers/pending.ts` probe explicitly selects the previous value
while STATUS_PENDING is set. Once the answer is ready but remains held, it
falls through to an ordinary read, which can consume the proposal in the
enclosing computation. The remedy must also preserve first-answer handling;
unconditionally reading an empty committed slot would break property access.

Tracked and imperative readers select the committed key during established
holds in these probes. The tracked synchronous experiment additionally calls
the callback with key 1 during the initial staging flush, before calling it
again with key 0. Next does not do so in that case. This extra speculative
calculation remains to be assessed; the probe does not claim every scope is
fully correct. Next's held-untracked reader also has its separate special
boolean and commit-rerun behavior described in stage 138.

## Validation and limitations

- Eight comparison probes pass their publication assertions on each runtime;
  callback traces expose the differences. They are diagnostic probes, not
  passing regression assertions for the desired callback contract.
- Ten focused scalar controls pass (first load, pending samples, snapshot and
  first-answer errors).
- Seven JSX controls pass, including the four narrowed first-value Show/Match
  cases and the three retained pending-sample publication controls.
- No full suite, benchmark, size measurement, or new runtime build was run.
  Full-suite failure counts remain those reported in stage 138; this audit
  discovers an additional implementation gap rather than fixing an old test.

Sources, configs, callback traces and reports are preserved in
`checkpoints/integration-stage139.tar.xz`. Temporary package files were removed.
No semantic ruling about untracked completion reruns is inferred from this
audit. Correct callback value selection needs addressing before that decision.
