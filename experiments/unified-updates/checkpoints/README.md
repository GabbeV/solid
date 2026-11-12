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

`deep-entanglement-review.tar.xz` restores `results/deep-entanglement-review/`: local and remote history, an independently verified ordinary-write control on two next pins, the unimplemented cost comparison, and the complete isolated static-store candidate with setter publication grouping and its test receipts. Main runtime remains unchanged. See `../STORE-INTEGRATION.md` for the compatibility recommendation and limits.

`store-flat-integration-20261112.tar.xz` restores `results/store-flat-integration/`: two full signals receipts and exact failure classifications, source snapshots, structural/reclamation implementation trials, adversarial controls and the next array-lifetime comparison. The flat-record runtime is integrated; nested/array/derived store forms remain unfinished. See `../STORE-INTEGRATION.md` for the accepted deep ruling, validation limits and pending array decision.

`array-override-for-review-20261112.tar.xz` restores `results/array-override-for-review/`: two next revisions of reverse-order array retirement probes, actual JSX For DOM tests with ordinary sparse controls, and the browser-verified hosted reproduction. No erroneous length reset or new hole on retirement was observed. See `../repros/array-override-lifetime/README.md`.

`array-retirement-report-20261112.tar.xz` restores `results/array-retirement-report/`: rc.20/rc.21 and exact #4729 boundary results, object-versus-array retirement controls, the simplified browser-verified reproduction, and the unsubmitted issue form. Archived runtime dependencies are omitted; exact versions/commits are recorded in metadata.

`setter-read-report-20261112.tar.xz` restores `results/setter-read-report/`: controlled read/write ownership probes on next and the experiment, the browser-verified hosted reproduction, and the unsubmitted issue form. Both runtimes currently keep read-a/write-b action lifetimes independent; write-a/write-a controls entangle.

`store-expanded-20261112.tar.xz` restores `results/store-expanded/`: store draft/array/chained/accessor integration receipts, diagnostic full signals failures, focused 70-test checkpoint, and array mutation investigations. The full run was concurrent with edits and is not acceptance evidence; until remains deferred and derived/keyed integration continues.

`store-keyed-20261112.tar.xz` restores `results/store-keyed/`: frozen full-suite classification, direct-key/refetch and keyed-pairing checks, source patch, and before-first-answer probes. Whole-row preservation and derived status integration remain incomplete; see `STORE-OVERNIGHT-DECISIONS.md`.

`store-framework-54a-20261112.tar.gz` restores `framework-54a/` in the extraction
directory. It preserves framework validation against source `54a7c3aa7`, built
artifact hashes, compiler provenance, exact failures and baseline controls.
Solid passes 927/927. Client has 20 newly unmasked store failures; hydrate has
10 preexisting failure identities. Server has two duplicate-signals-bus failures
resolved by a scratch resolution fix and one load-sensitive iterator count which
passes isolated reruns. Raw failures are retained; targeted passes do not rewrite
the full-suite result. No `until` failures occur in these framework runs.

`store-progress-20261112.tar.xz` restores `store-progress-20261112/` in the extraction directory. It preserves the pre-combination full signals run at `4d891e564`, focused integration checks, and unmerged parent/derived/error trial sources. Trials include known gaps and are not merge candidates without their later review. Built artifacts were still `54a7c3aa7`; the full run is source failure-discovery evidence.

`store-framework-668-20261112.tar.xz` restores `framework-668/`. It preserves
all four framework suites on source `668d48061`, frozen signals dist and hashes,
exact failure identities, the shared-signals-bus server qualification, and reviewed
client/hydration migrations. Solid passes 927/927; original client has 18 failures,
hydrate 10, server two dependency-resolution failures. All affected client migration
cases (19 including control) and hydration cases (12) pass targeted checks. These
receipts are intermediate, not a final rebuilt acceptance run.

`store-integration-review-20261112.tar.xz` restores `store-integration-review/`.
It preserves full source runs at 668 and 481 plus reviewed test migrations,
the exact deferred-until classification, root 993-case property/list verification,
cold/pending investigation receipts, the 23-case list migration root run and the
11-case explicit-GC run. The latter full run has 7,819 passes, 163 failures and five
skips; 135 failures depend on deferred until. Cold initialization, pending and array
correction work remains in progress.

`store-completion-b69738dd2-20261112.tar.xz` restores
`store-completion-b69738dd2/`: frozen full signals results (7,930 pass, 135 exact
until-dependent failures, five skips), source/artifact hashes, explicit-GC and
cold/quiet/native-method controls, the earlier add90 framework receipts, and
rejected publication-order trials. There are zero other failures in the frozen
signals run; this is finite validation, not a universal correctness proof.

`framework-final-b69738dd2.tar.xz` restores the final framework and supplementary
receipt directories. Solid 927, client 1,883, server 2,010 and hydrate 768 pass;
seven preexisting framework skips remain. Diagnostics/adapters add 385 passing
tests. All four public type programs and the qualified package import smoke pass.
Exact commands, environment qualifications and artifact hashes are preserved.
The #4275 fixture subsequently received a type-correct JSX expression, with its
two runtime cases and Web type program rerun unchanged. The install-driven
packaged-types integration suite was not run.
