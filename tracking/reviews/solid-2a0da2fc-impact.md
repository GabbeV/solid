
> solid-signals-bend@0.1.0 upstream:impact
> node tools/upstream-impact.mjs /workspace/solid-next-2a0da2fc

Baseline: Solid 2.0.0-rc.18 (225014bf8757421a2ea0a9c6ddc148b965eed000).
Candidate: /workspace/solid-next-2a0da2fc/packages/signals/src
Scope: signals src/**/*.ts; separately review tests, documentation, build conditions and initialization reachability
Correspondence and TS parity require review/revalidation. Existing Bend proofs remain about their pinned program, not this candidate.

changed: core/async.ts
  changed: core/async.ts:notifyStatus -> runtime/status.bend:notifyStatus, notifyStatusWith, storeStatus, Notify, wrapped; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/constants.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/dev.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: deferred.ts
  changed: deferred.ts:createDeferred -> runtime/core.bend:deferredConstruct, deferredCreate, deferredBody, deferredResult, deferredObserveState, deferredAfterThen; runtime/deferred-runtime.bend; runtime/deferred-lifecycle.bend; runtime/api.bend:createDeferred; runtime/deferred-stream.bend; runtime/iterator-input.bend; runtime/core.bend:deferredStream, deferredAfterIterator; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
