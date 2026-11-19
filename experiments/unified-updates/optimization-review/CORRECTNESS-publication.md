# Retained creator/publication verification

Current retained source, 2026-11-11. No runtime or test edits. Existing coverage
already exercises the requested invariants, so no duplicate regression file added.

Two focused source runs, installed Vitest directly, `--maxWorkers=1`:

| File | Passed |
| --- | ---: |
| unified-owned-context | 27 |
| unified-owner-context-retry | 72 |
| unified-owned-removal-preparation | 8 |
| unified-retained-publication | 4 |
| unified-owned-lifetime | 5 |
| unified-publication-adversarial | 12 |
| released-memo-retry-runs-4474 | 3 |
| latest-unread-identity-memo-4474 | 9 |
| unified-context-retry-error | 20 |
| unified-input-reuse | 15 |
| unified-owned-adversarial | 16 |
| unified-read-retry | 36 |
| **Total** | **227** |

All passed. Receipts: source.json/source.log and
retry-request-counts.json/retry-request-counts.log in this directory.

- Accepted private work: owned-context completion orders and owned-lifetime
  dependency removal preserve attachment/pending coherence and one-way waits.
- Completed private creator discovering context later: owner-context-retry's
  delayed cases suspend before observation; already-accepted action entanglement
  remains until action closure. All complete captured/direct reads agree.
- Retained published children: owned-removal-preparation checks request-argument
  coherence even for bodies that never publish, through roots, async children,
  and supersession. Retained-publication checks old visible children can still
  publish independent optimistic consequences before held removal.
- Request reuse: latest-unread-identity-memo-4474 explicitly forbids extra asks
  and compares unread/read controls; input-reuse and released-memo controls
  assert run/cleanup/request counts.
- Cleanup/control flow: owner-context-retry, owned-removal-preparation and
  read-retry assert exactly-once owned cleanup; read-retry also asserts iterator
  closure. Context-retry-error covers application catch/async normalization.

No current public-API defect or consequential semantic ambiguity found in this
bounded verification. Historical broad-deletion trials are counterexamples to
those rejected changes, not current runtime failures. This is finite focused
coverage, not a claim that all graphs or deferred stores/until are correct.

Invocation note: initial `pnpm exec` unexpectedly entered automatic dependency
verification/install and failed with PNPM_UNSAFE_MODULES_DIR before tests. No
dependency operation was intended; successful runs used existing
node_modules/.bin/vitest directly. Do not use pnpm/npx for further invocations.
