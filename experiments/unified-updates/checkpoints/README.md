# Experiment result backup

`results-through-stage127.tar.xz` preserves the accumulated experiment results
through stage 127: test reports, benchmark outputs, executable probes, and
rejected implementation trials. These are historical evidence, not additional
runtime sources. The retained implementation lives in the normal packages.
The archive is immutable: its reports and probes retain the original paths and
test names from before the experiment was renamed to unified updates.

`naming-checkpoint.tar.xz` records validation after the rename: all 69
experiment-specific test files are byte-identical to their predecessors, and
the renamed suite plus rules-index and #4677 checks passes all 589 tests.

From the repository root, verify and restore with:

```sh
sha256sum -c experiments/unified-updates/checkpoints/SHA256SUMS
tar -xJf experiments/unified-updates/checkpoints/results-through-stage127.tar.xz -C experiments/unified-updates
tar -xJf experiments/unified-updates/checkpoints/naming-checkpoint.tar.xz -C experiments/unified-updates
```

Restore into a fresh checkout or preserve newer local results first: extraction
recreates the historical `experiments/unified-updates/results/` files.

The source checkpoint is `b8737c8b`. Its latest full signals run had 5,189 passing,
2,125 failing, and 2 skipped tests. It is an implementation experiment, not a
merge-ready release. See `../INTEGRATION-127.md` for the retained changes and
`../SCALAR-API.md` for the current implementation scope.

Keep this archive immutable. Save future large result sets in separate stage
archives, updating `SHA256SUMS`, and commit and push them with the corresponding
implementation or investigation checkpoint.

`correctness-review.tar.xz` preserves the supervised post-stage182 correctness
pass: source commit `d49bcd3f6`, full signals/Solid/DOM comparisons (no new failure
identities), 180 production controls, 61 artifact checks, size receipts, rejected
cleanup trials and instrumented lifecycle probes. It restores
`results/correctness-review/` under `experiments/unified-updates`. The accepted fixes
and unresolved producer-reclamation scope are summarized in
`../optimization-review/CORRECTNESS-FIXES.md`.

`optimization-trials-20261111.tar.xz` preserves the supervised optimization
trials following that checkpoint. It restores `results/optimization-trials/`:
isolated candidate patches and agent reviews, full signals failure-identity
comparison, production controls, artifact hashes, size reports, native benchmark
rounds and separate CPU profiles. `MANIFEST.json` identifies the retained cold-reset
variant and the final `pinned-*` timing phase; the initial `screen-*` fixtures were
invalid and supply no timing evidence. The shared native fixtures are committed
at `e7776925f`. See `../optimization-review/IMPLEMENTATION-TRIALS.md` for retention
decisions, limitations and the next investigation targets. This checkpoint does
not assert that the broader experiment meets its performance or size goals.

`store-integration-start-20261111.tar.xz` restores
`results/store-integration-start/`. It preserves the verified remaining failure
inventory, ordinary API audit, clean next/scalar comparisons, and the first
isolated static-store candidate. That candidate is **not integrated**: an
adversarial check exposes missing single-setter publication grouping, and the
deep-observation lifetime decision is pending with the user. The main runtime
still rejects optimistic stores at this checkpoint. See
`../STORE-INTEGRATION.md` for the implementation plan and exact status.
