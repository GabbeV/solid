# Owner/core continuation migration

This milestone records its original pin and totals. The current pin is b0ad1df5;
[getter cleanup](../getter-cleanup.md) supersedes the direct getter exclusion below.

Solid remains pinned at 71153bf0; no semantic deviation is active. PR
[#4176](https://github.com/solidjs/solid/pull/4176) is recorded separately. Its
finally restoration is not applied to the pinned runtime.

## Source operations

The remaining async/error/pending callers now suspend the existing core driver
at owner callbacks. No executor, cached-read path or scheduling implementation
was added to the JavaScript adapter. No World or source-node field was added.

| Source operation | Bend segments and retained order |
| --- | --- |
| `handleAsync:asyncWrite` | `flight.beginAsyncWrite` retains flight-identity/dirty guards, landStatus and setSignal. `core.asyncWrite` closes loading and resumes `OwnerTasks(TrimDeps)` only when there is no pending value. `AsyncWriteAfterTrim` runs pending-source settlement; schedule, synchronous flush and the optional iterator continuation follow successful completion. A stale result skips that continuation. |
| `settleAutodispose` | `flight.shouldSettleAutodispose` retains AUTO_DISPOSE, no-subs and non-pending guards, including the source's absence of a zombie guard. Core resumes the shared Unobserved task. Iterator pulling resumes only when release was unnecessary. |
| `settlePendingSource` / `releaseSettledDependents` | `pending.beginSettlement`, `beginReleaseSettledDependents` and callback-free `advance` share the original live edge walk, visited set, deferred release array and scheduling decision. Core `PendingTasks` captures those locals and intercepts each Release for OwnerTasks. Release eligibility is checked again after earlier callbacks. A throw aborts the remaining walk. |
| `stageError` | `beginStageError` retains guards, source-set clearing, status/error preservation, wrapper creation and staging. Settlement completes before schedule and successful return. The restricted direct facade composes the same segments. |
| `handleAsync:handleError` | `beginHandleError` retains stale-flight and loading-window returns. Core notification, pending-source transfer, time assignment and the real-error dependent release remain in source order, with explicit return points around deferred callbacks. |
| synchronous thenable/iterator rejection | Observer sync state changes before error handling. The original rejection is rethrown only after handleError succeeds; a cleanup failure replaces it. `ThenRejected` still routes to the enclosing compute catch/finally on either return or unwind. |
| recompute's outgoing-source retirement | `RetireSources` retains the captured Set handle and live cursor, skips tombstones/self, and checks current membership for dropped-source-only retirement. Callback changes are visible to the next iteration. |
| recompute's catch/finally | Catch notification, self retirement and outgoing-source retirement precede finally. CatchStageFinish commits the local staged-error result only after stageError's release walk returns. Its unwind uses false, as an interrupted assignment does. Throws within the catch execute the existing pass finally and may replace the original body error. |
| recompute's publication tail | Equal-value recovery retains error-dependent wakeup, outgoing-source retirement and then self-source retirement. These operations remain after the compute finally; their throws do not re-enter that computation's body catch. Publication queueing and dependency trim still follow successful settlement. |

The module-local World-only facades remain for restricted direct helper probes.
They reuse the same mutation segments. They are not the public callback driver
and do not acquire support for arbitrary expression callbacks.

## Public callback domain

The harness now admits the existing expression-program grammar as onCleanup,
unobserved and returned effect callbacks. Those functions perform ordinary lazy
reads, writes/updaters, nested calls/construction, early returns and throws through
the active core machine. Void cleanup calls discard their returned value.
Getter/setter functions used as raw setter updaters within cleanup also use the
normal shared setter/read policy. Function IDs remain canonical.

Directly registering/returning a bound getter as the cleanup is still outside the
callable representation. The error-arm-only previousCleanup helper is unavailable
in ordinary callback function values, including indirect named calls. Arbitrary
JavaScript closures, custom comparators/protocol getters, active boundaries,
lanes and store APIs retain their existing exclusions.

## Evidence and limits

- 74 new public API histories, with no fixture admission, cover direct disposal,
  ignored returns, selected updaters, returned effect callbacks, equal/changed
  async landings, pending dependents, promise/iterator completion and rejection,
  silent recovery and error partial states. Together with prior suites there are
  2,103 public differential histories.
- Direct owner/core probes increase from 88 to 136. The 48 additions retain
  native assertions and compare node fields, callback aliases/order, iterator IO,
  async failures, rendering and ambient restoration.
- Equal-valued and changed-valued async results are separate controls. A changed
  result may defer trimming to commit, so it alone did not detect an omitted
  asyncWrite trim. The equal-valued control rejects that mutation.
- Four additional compiled mutations target async trim, a skipped captured
  release candidate, omitted flight autodisposal and omitted error-path release.
  The full suite now has 97 rejected variants. A proposed catch-only-unwind
  mutation was accepted by the chosen oracles and is not counted: that precise
  exceptional site lacks a separate mutation witness. Source ordering there is
  reviewed, not certified by the call inventory.
- Three additional closed laws construct public onCleanup registration and
  perform explicit thenable settlement through the active runtime: flight
  autodisposal, equal-valued async trim and pending-dependent release. They check
  the lazy cleanup read/write, released dependency state, live owner, queues and
  ambient state. The roots total 48 concrete regressions, including the existing
  negative upstream collector-leak law. These are not general callback or native
  promise timing theorems.
- The conservative owner-boundary report now finds zero core calls into
  restricted World-only owner helpers. It ignores task constructors and branch
  predicates; it is a call-site review aid, not proof of complete package support.

The source pin, toolchain pin, represented arithmetic domain and finite execution
budget are unchanged. No formal TypeScript/Bend equivalence is claimed.
