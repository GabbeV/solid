# Prepare restored bindings before publication

The remaining three #4491 store/memo comparisons exposed a shared core bug,
not a store-specific rule or merely sibling callback order. A forwarding memo
reproduces the same failure as a derived store.

## Observable failure

Start with source 1 and a hidden reader. A memo computes
`latest(source) + source()`; an async memo answers that question. Source 2 can
publish while the reader is hidden. Mounting the reader while answer 4 is still
pending holds its visibility change. Source 3 then supersedes that request.

The direct memo form retained source 2 and the hidden reader until answer 6.
Adding a forwarding memo, or using a derived store, published source 3 while the
reader remained hidden. Unmodified next retains both in all forms. The original
three equality assertions are unchanged and now pass.

During the optimistic context, the binding retried on committed visibility and
closed its branch. At restoration, the binding rejoined the ordinary update,
but its replay remained scheduled after publication. A still-pending forwarding
memo need not propagate the identical pending mark again, so it did not wake
that binding before the readiness check. Next's separate posture mechanism
avoided this particular sequence; the common engine must handle restoration.

Preparation now includes a render binding already held by the exact update being
prepared. Its ordinary reads discover pending work before that update publishes.
Independent bindings and structural outputs retain their existing replay paths;
active higher work is still protected by the surrounding preparation checks.
The change reuses the existing rerun set and held ownership. It adds no fields,
allocations, graph registry, or ordinary settled-read branches.

Twelve controlled-gate tests exercise ordinary and latest-bearing inputs through
direct reads, a memo, a three-memo chain, store properties, key enumeration, and
JSON. They require the same publication timeline after an obsolete answer
arrives and an unrelated write reruns the held reader. The current answer must
publish without waiting for the abandoned optimistic request.

## Reviewed expectations

Three other #4491 assertions now reflect the accepted model:

- A superseded optimistic answer 4 no longer publishes before restored ordinary
  answer 6. The user's existing ruling says optimistic derivations do not define
  their own lifetime. Exact publication logs and all four forms remain pinned.
- The old `CONFIG_VERDICT` flag is removed-lane bookkeeping. The test retains
  pending-state checks and compares actual visible values at landing, re-ask,
  and completion.
- An equal async answer leaves the display at 0 in every form. The direct memo
  binding retries its suspended calculation and invokes its render callback
  again with 0; an equal store leaf write suppresses its notification. Render
  callbacks have no result equality filter. This extra callback is explicitly
  asserted rather than hidden by normalization. Visible snapshots and complete
  callback logs are separate assertions. Avoiding the extra retry remains an
  optimization opportunity; no new bookkeeping or global callback filter was
  introduced to reproduce next's count.

The timeline helpers now dispose their roots. No consistency assertion was
relaxed to admit the early source publication; that defect required the runtime
repair above.

## Validation and remaining work

- Full signals: **5,775 passed, 1,953 failed, 2 skipped**. All failing identities
  are previously classified deferred optimistic-store/`until` cases. All six
  previously non-deferred failures are resolved: three by the runtime repair,
  three by the reviewed assertions. No new failing identities.
- Full web: **1,766 passed, 115 failed, 1 skipped**; the same deferred
  failures as stage 180, with no new failing identities.
- Production public-API selection: **154 passed**, including the twelve new
  controls and ownership/context adversarial cases.
- The eleven migrated #4491 cases and twelve new controls pass together.
- Type generation and production/observe purity checks pass.

The additional full Solid-package run has **901 passed and 25 failed**:
23 deferred optimistic-store cases, plus two newly inventoried non-deferred
failures (`create-deferred-hydration` pending and `show-shown-flag-halt-4354`
close/reopen). These need investigation; no full-API completion claim is made.

Scalar shipped sizes, minified / Brotli bytes, against next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`:

| Imports | Next | Experiment |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,456 / 8,056 |
| Optimism | 30,556 / 11,180 | 37,213 / 13,432 |
| Observed optimism | 35,643 / 12,920 | 43,330 / 15,299 |

The repair adds 27 minified bytes to the optional coordinator. The ordinary
scenario is unchanged. No new throughput or mergeability claim is made.
The archive preserves next timelines, source/status traces, trials, final
reports, and production and size checks.
