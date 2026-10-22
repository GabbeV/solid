# Solid pin update: a2a5b6f8 to 5b1b7776 (rc.17)

Reviewed on 2026-10-22 against fetched next. The new pin is
`5b1b777648a89b6e207e8bb78514d5c03420e08b`, six commits after rc.16. The complete
previous translation is `bb82345ff350bcceaa534a1345c018b3d2281f43`, retained in
feature-branch history and locally named baseline/solid-a2a5b6f8. Work remains
on feat/solid-signals-bend; no published history is rewritten. Bend 2.0.37 / Lean
4.34.0 and the empty semantic deviation register are unchanged.

All 76 vendored Solid inputs were compared with the clean detached candidate;
13 changed and were copied verbatim, including ten source files, two rule docs
and the package version. There is no local TypeScript patch. The
[preflight impact](solid-5b1b7776-preflight-impact.json) predates replacement of
the baseline. [Validation](solid-5b1b7776-validation.json) records exact checks
and source hashes.

## Operation review

| Change | Port and scope |
| --- | --- |
| #4213: module-global cleanupError box and runCleanup/rethrowCleanupError | One World Slot represents the optional box without conflating missing with thrown undefined. cleanup-state preserves first payload, schedule-on-each-catch, clear-before-rethrow and drop. A callback remainder aborts; subsequent callbacks/tree teardown continue. |
| owner.runDisposal / disposeChildren and graph.unlinkSubs ordinary unobserved | RunCleanup tasks enter the existing callback/core driver and retain a CleanupFinally return point. Both normal and exceptional returns discard callback operands; only actual supported user throws are collected. Raw callbacks, effect pre-rerun cleanup and error-handler previous-cleanup helper remain unguarded where source does. The native callback receiver changes to a plain call; bound/lexical callable identities remain intact. Store slot hooks remain refused. |
| disposeRootSelf | RootEnd follows public bound/root-method disposal outside disposeChildren. Outside a running flush it consumes/rethrows the collected error after teardown; during a flush it defers. Typed bound disposers used by init, updater and cleanup paths share this entry. Raw internal owner disposal does not acquire a root rethrow check. |
| scheduler.flush / haltReactivity | The complete scheduled drain finishes before rethrowCleanupError(false), including the no-work return after running/halted/action guards. First halt drops an existing collected error before reporting; the already-halted guard still returns first. A cleanup collected after a halt retains the source schedule warning and later error behavior. Dev loop-guard and observe attribution branches remain outside the production profile. |
| core.recompute | Remove #4176's exceptional collector-restoration unwind arm. The successful restore remains after disposeChildren because runCleanup now contains supported user throws. The original collector-leak regression still passes; its earlier finally-specific quantified law is replaced with a cleanup-catch continuation law. |
| #4211: updateKeyedMap/updateRepeat fallback guards | Port the two output-length tests. Completed falsy values stay mounted, while interrupted fallback attempts still retry. Existing repeat and all map-mode retention histories now assert this policy; the two mutation variants are reversed into regressions of the merged fix. |
| #4210: optimistic folded stores | Transaction.folded callback, joinPassAt, core.read screening, laneRead/verdictValue folded checks and laneWrite rebase-before-staleness are inventoried and remain unfinished with their surrounding active read/write engine. Store APIs/sink-slot bookkeeping remain excluded. Shared module initialization is retained in the full reference index. On admitted ordinary nodes, the store callback's _host/$TRACK/family gates exclude store folding. No constant false hook or pretend folded implementation is introduced. |
| #4214 / release commits | Compiler WASI CI and release versions/docs do not add admitted production signals operations. Dev disposal-depth comments and diagnostics are reviewed as nonproduction scope. |

The restricted mark, lane identity/group, verdict bookkeeping, blocker and
laneStage source bodies added in the preceding continuation are unchanged. Their
native helper comparisons pass against the new source. Public latest/isPending,
lane read/write/reveal/correction/dissolution, stores and boundary engines remain
unfinished; repinning is not a claim that those scopes have been implemented.

## Evidence and updated guarantees

Thirty-six new paired public histories cover falsy and undefined first errors,
child/sibling/LIFO completion, aborted callback remainders, cleanup writes,
disposal inside/outside a flush, once-only rethrow and continued reactivity. Six
of these histories check a nested root disposer consuming/rethrowing a previously
collected error outside a flush, and deferring it during a flush.
Eight additional public rejected-flight histories cover the actual error-path
stranded-reader release, which the previous cleanup-fault cases no longer reach.
Existing owner/core, unobserved, mapper-abort, iterator, until, callback and error
histories retain actual native comparisons. Existing closed trim/commit
regressions now expect the application error to remain while trim errors are
collected, and cleanup writes to finish before a collected error escapes.

Seven new quantified helper properties check first-error collection, preservation
against later errors, exact raw rethrow and clearing, drop with all other World
fields intact, disposal during a flush, already-halted identity and first-halt
drop. The existing quantified cleanup-catch continuation now checks restored
operands and resumed teardown. General World properties quantify the added
cleanup slot rather than assuming it empty. Existing scalar-memo program proofs
retain their public scopes and budgets. A proof-only Boolean decomposition
adapts their flush-entry lemma; runtime branches and kernel sources were not
changed for the proof. A rejected polymorphic proof expression exceeded the
pinned kernel's template scope; specializing the algebra to actual World values
checks without a toolchain change. That trial is not counted as proof evidence.

The native package build/types and full suite pass: 335 files, 5,476 tests,
three expected failures, two skips. The initial unbuilt checkout lacked packaged
artifacts and failed 35 artifact checks; after the ordinary package build all
pass. This is recorded as setup evidence, not hidden as a source regression.
Bend public/helper suites and the independent combined root are checked too.
Mutation compilation failures and stale/now-unreachable old error-path variants
are not counted as successful semantic rejections; validation records the final
accepted sweep and any replacements.

Two old mutations on exceptional commit/trim unwind paths became unreachable
for supported user cleanup throws under #4213. They are retired and replaced by
mutations that rethrow the collected error before commit continuation, and that
replace the application's prior fault with a collected trim error. The first
flight-release mutant initially survived because its old oracle relied on a
cleanup escaping; the new rejected-flight controls reject it directly. No source
behavior or proof was changed to suppress these oracle findings.
