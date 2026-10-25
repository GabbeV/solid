
> solid-signals-bend@0.1.0 upstream:impact
> node tools/upstream-impact.mjs /workspace/solid-next-4ea2f498

Baseline: Solid 2.0.0-rc.18 (2a0da2fc5c53d97f655b6b713bdbb95c5aec1eb5).
Candidate: /workspace/solid-next-4ea2f498/packages/signals/src
Scope: signals src/**/*.ts; separately review tests, documentation, build conditions and initialization reachability
Correspondence and TS parity require review/revalidation. Existing Bend proofs remain about their pinned program, not this candidate.

changed: core/attribution.ts
  changed: core/attribution.ts:checkUnstableOutput -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/constants.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/owner.ts
  changed: core/owner.ts:disposeChildren -> runtime/owner.bend:enter, afterPark, walk, PrepareChild, AfterChild, finish, runDisposal, effectCleanup; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/scheduler.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/utils.ts [store excluded; shared-hook review still required]
  changed: store/utils.ts:merge -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
