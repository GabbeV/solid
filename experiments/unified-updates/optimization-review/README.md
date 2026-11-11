# Size and performance simplification review

Five focused investigations on `experiment/unified-updates`, starting at
`03628b9084c9da3ba28e0342f46f25898bad8118`. The user requested Sol agents at medium
reasoning, supervised by the primary agent. This is a staged investigation,
not authorization to merge speculative rewrites or change semantics silently.

## Shared instructions

- Read the root AGENTS.md. Work in `/workspace/layered-solid`.
- Each agent owns only its named report and scratch directory. Runtime source
  is shared: do not modify it, install dependencies, build shared artifacts,
  commit, push, rebase, or run timing benchmarks without primary-agent direction.
- Do not spawn other agents. Summarize findings to the primary agent instead
  of forwarding source dumps or long logs. Send an initial checkpoint after
  mapping the relevant mechanism, before expanding the investigation.
- Distinguish measured attribution, source observations, and hypotheses.
  Every candidate needs a falsifier and the smallest meaningful validation.
  Dead source removed by tree-shaking is not a shipped-byte saving.
- Preserve current correctness: explicit observation/deferred boundaries may
  differ from their inputs; ordinary consumers of their output must agree.
  Same-depth ordinary peer updates still entangle. Active optimistic boundaries
  establish deeper contexts; inactive boundaries read through. Context discovery
  aborts/retries incompatible calculations, including private creators when
  needed. Already accepted entanglements are not undone by late discovery.
- Optimistic consequences never establish their own override lifetime. Keep
  lifetime readiness distinct from publication readiness. Do not restore the
  abandoned observedness-forwarding rule. Pending/latest are source-owned
  optimistic outputs, with common context selection. Errors publish coherently.
- Eager detached DOM construction is desired; scheduled publication must remain
  coherent. Preserve owned-child cleanup and obsolete async cancellation.
  Stores and until remain deferred. No new persistent cache or overhead on
  ordinary nodes simply to simplify a cold path.
- Performance claims compare only to unmodified next. Existing receipts pin
  next `4fe75321`; current upstream inspected separately is `bcef1041`. Do not
  mix revisions or call an old measurement a current result. Do not run timing
  workloads concurrently with agents/builds/tests; request exclusive scheduling.
- The installed Git hook is stale and runs a repository-wide formatter. The
  primary agent handles checkpoints and avoids that hook; do not invoke it.

## Evidence entry points

- `INTEGRATION-182.md`: latest suite classification and size measurements.
- `results/integration-stage182/size-scalar.json`: per-module minified attribution.
  Parse and summarize it; do not dump it wholesale.
- `INTEGRATION-171.md` through `INTEGRATION-178.md`: recent ownership/context work.
- `SIZE-96.md`: historical size mechanism and rejected quadratic disposal trial.
- `SCALAR-API.md` and relevant `packages/signals/tests/unified-*` tests.
- `packages/signals/src/layers/` and `packages/signals/src/core/`.
- Root README/status links identify history. Read selectively, not all stages.

## Deliverables

Each report should be compact (target <= 150 lines):
1. Current mechanism and where work/bytes accumulate, with file:line references.
2. Best one or two simplifications, separating safe cleanup from redesign.
3. Which existing mechanism would be deleted or replaced, not merely augmented.
4. Likely performance direction and which paths pay any new cost.
5. Counterexample / rejected historical trial / invariants at risk.
6. Minimal next experiment and tests; unresolved semantic questions if any.

Send a <= 300-word checkpoint/final summary. Keep supporting detail in the owned
report or scratch directory. The primary agent reviews and directs follow-ups,
then writes the combined prioritization. No savings are claimed until measured.

## Completed review

See [primary decisions and experiment order](DECISIONS.md) and the five numbered
reports beside the plans. Extracted probes and their receipts are in `probes/`.
No runtime change or new throughput claim is included in this review.
