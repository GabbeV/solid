# Plan 3: calculation attempts, retries, and proposal transfer

Owner: attempt-transfer agent. Report: `03-attempt-transfer-report.md`.
Scratch: `/workspace/scratch/optimization-review/attempt-transfer`.
Read the shared README first.

Map computeLayer/retryCalculation/acceptCalculation/adoptOutput and their core
counterparts. Identify duplicated normalization, error/retry handling, disposal,
prev selection, flight ownership and callback transfer. Explain which transfer
paths preserve work that would otherwise restart a request.

Checkpoint with one normal attempt, one context retry, and one transferred
proposal, showing where each performs the same work. Recommend one bounded
consolidation and one larger ownership simplification; distinguish duplication
that may help JIT inlining from accidental duplication.

Preserve committed prev selection, async rejection handling, equality with
lifecycle changes, exactly-once cleanup, and creator retries crossing async
functions/user catches. Coordinate with agent 1 via the primary agent; do not
redefine publication readiness or modify shared runtime source.
