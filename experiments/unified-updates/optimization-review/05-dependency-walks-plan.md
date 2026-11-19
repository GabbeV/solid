# Plan 5: repeated graph walks and committed-dependency bookkeeping

Owner: dependency-walks agent. Report: `05-dependency-walks-report.md`.
Scratch: `/workspace/scratch/optimization-review/dependency-walks`.
Read the shared README first.

Map committed-dependencies.ts and coordinator calls to observed, layerPosition,
currentPosition, committedUsesUpdate, unpublishedFrame and lifetime checks.
Determine when walks repeat, what each proves, and whether they examine the same
or different graph snapshots. Inspect insertion journal scans and existing
rerun-holder indexing; preserve the asymptotic protection documented in SIZE-96.

Checkpoint with a concrete graph/workload producing avoidable repeated work.
Then propose at most two improvements using existing traversal/queue/flag state,
without persistent caches, extra ordinary-node fields or per-settled-read maps.
Quantify complexity from the algorithm only; do not turn operation counts into
throughput claims. Explain why committed and proposed dependency sets cannot
simply be collapsed, including errors and private/retained child cases.

Recommend a small adversarial operation-count experiment and relevant tests.
Do not run timing benchmarks or edit shared runtime source without review.
