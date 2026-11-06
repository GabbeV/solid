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
