# Experiment result backup

`results-through-stage127.tar.xz` preserves the accumulated experiment results
through stage 127: test reports, benchmark outputs, executable probes, and
rejected implementation trials. These are historical evidence, not additional
runtime sources. The retained implementation lives in the normal packages.

From the repository root, verify and restore with:

```sh
sha256sum -c experiments/layered-updates/checkpoints/SHA256SUMS
tar -xJf experiments/layered-updates/checkpoints/results-through-stage127.tar.xz -C experiments/layered-updates
```

Restore into a fresh checkout or preserve newer local results first: extraction
recreates the historical `experiments/layered-updates/results/` files.

The source checkpoint is `b8737c8b`. Its latest full signals run had 5,189 passing,
2,125 failing, and 2 skipped tests. It is an implementation experiment, not a
merge-ready release. See `../INTEGRATION-127.md` for the retained changes and
`../SCALAR-API.md` for the current implementation scope.

Keep this archive immutable. Save future large result sets in separate stage
archives, updating `SHA256SUMS`, and commit and push them with the corresponding
implementation or investigation checkpoint.
