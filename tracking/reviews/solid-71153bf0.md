# Solid pin update: d2ad8b28 to 71153bf0

Reviewed 2026-10-20 (Europe/Stockholm). Candidate fetched from solidjs/solid's
`next`: `71153bf0dbd1325cf29f81cb1e7a34e380e694d2`, still declaring rc.15.
Bend remains pinned at e5527d5b (2.0.37). This is a source update, not a claim of
full-package coverage or machine-checked TS/Bend equivalence.

The old baseline is preserved on `baseline/solid-d2ad8b28` at Bend commit
`76361a4`, including its full vendored source, negative laws and sealed checks.
`main` also remains at that checkpoint; the update is isolated on
`integrate/solid-next-fixes`. No remote is configured for this translation repo.

[Source impact](solid-71153bf0-impact.json) records all 14 changed/new source files
and their mapped/unmapped units. [Validation](solid-71153bf0-validation.json)
retains original before/after repro results, PR metadata and successful log hashes.
The two changed vendored documentation files update rule citations, the lane-frame
ruling and the comparator-error mechanism; they are copied verbatim from the pin.
No baseline source file was locally patched to obtain the candidate behavior.

## Tracked fixes

| Report | Landed change | Original repro result after update |
| --- | --- | --- |
| Empty flatten, #4144 | 745e807b | All 18 direct/immediate/native/empty/nonempty controls pass; empty yields undefined. |
| Staged recovery, #4145 | fb6006eb, #4156 | All eight immediate/native recovery/control cases pass. Successful recovery yields 3 or 9 without halting; an unrecovered error still throws 99. |
| Held function result, #4163 | 7014aca4 | All 12 raw function controls pass; the updater runs once and its returned function is never invoked. |

PR #4148 was closed **without merge**, superseded by #4156. The accepted change
clears a previous staged error after frame teardown, before the next pass's body
try. It also covers a replacement flight. #4167 additionally fixes writable memo
error recovery and manual writes over staged errors. We port those source sites,
not #4148's narrower value-publication proposal.

The original source-only repro tests accept `--baseline` with `SOLID_REFERENCE`
pointing at an old bundle. Their default expectations check the new pin. Historical
standalone npm/playground artifacts retain their original versions and evidence;
they are not claimed to be reproductions against the new pin.

## Operation-level review

| Source change | Bend correspondence and limits |
| --- | --- |
| `recompute` collects last-reader releases while disposing an unfinished frame (#4164/#4142). | `graph-state.beginReleases/deferRelease`, `RestoreDeferredReleases`, `RecomputeAfterTeardown` and `PassReleases`. A nullable array becomes a nonzero stable arena handle; nested passes retain the captured array, append order, duplicates and live iteration bounds. The source's pre-body restoration is not a finally: a teardown throw leaves the active pointer as Source does. |
| `recompute` releases those still unobserved after context restoration, before reask classification. | `startPassFinally`, `passFinally`, `PassReleases`, `passFinallyTail`. Releases use the shared owner/core driver. A release throw skips the remaining loop and reask tail, overrides a prior fault and restores the caller operand stack; it does not re-enter this node's body catch. |
| `stageError` stages an in-pass error on staged reads during a running flush, even before a hold joins (#4156). | Same predicate in `pending.stageError`; no early hold test is retained. New-pass STAGED_ERROR/pending clear stays at the source prelude site. |
| Held setMemo wraps its updater result (#4163). | `memoDelegate(wrapped=True)` represents the constant-return closure. Error recovery precedes setSignal's currentValue capture; the closure returns the existing stack value without re-invoking callable data. Active write hooks remain unadmitted. |
| setMemo recovers ERROR before setSignal, retaining shownError until commit; after success it clears STAGED_ERROR (#4167). | `memo-write.recover/finish`, core updater/raw entries and restricted owner setter facades share these source segments. A held user-call throw precedes recovery; an ordinary user-call throw follows recovery. Neither runs the success remainder. |
| Shared `isSame` (#4157); comparator moved after parked-frame checks in settle. | `equality.isSame` retains strict-equality and disabled-comparator arms, shared by recompute, setter and seam. Custom comparator execution, its NotReady catch and other comparator exceptions remain unfinished. Those fixes are checked by upstream's own tests, not claimed as supported Bend callbacks. |
| LIVE flattened stream resets syncValue (#4144). | `afterThen` supplies undefined to the new stream's sync local; a yielded value replaces it and empty completion retains it. No object can leak from the outer fulfillment local. |
| Later iterator pulls and deferred flatten setup have protocol catches (#4158). | `ProtocolCatch/catchProtocol` retain node/result identity, source flush boundaries and success/error autodisposal differences. Typed later-next throws now reach their memo. Arbitrary iterator factory/then/property getter throws remain unadmitted. |
| Deferred iterator close registers through cleanup(fn, owner) (#4158). | Existing explicit-owner `owner.cleanup` matches the new shared Source helper. LIVE passes supply ambient owner; deferred flatten supplies the computed node. No separate disposal-list implementation is added. |
| asyncWrite drops its comparator catch (#4157). | Removed `flight.writeCatch`; guarded comparator behavior belongs to `isSame`. The admitted comparator subset cannot throw. |
| StatusError message formatting becomes best-effort (#4158). | Existing admitted immutable payloads format successfully; native message/cause identity remains checked. Hostile coercion and throwing message getters remain unfinished. Source's actual new constructor passes the dedicated upstream regressions. |
| `readerSeesCommitted` and `removalStagedBy` omit boolean coercions. | Bend Bool represents internal truthiness; their callers' branches retain behavior. Actual read/transaction/seam helper comparisons pass. No raw numeric truthy result is exported by the admitted public ABI. |
| `_update` adds laneFrameMember (#4153). | Active lane engine remains unported; its installer is absent in the admitted profile. Mainline zombie behavior is unchanged and revalidated. |
| New identities module, signalHook, node-aware writeHook, dev onRead and index exports. | Default hooks remain null; no identity installer is enabled by this harness. Active hydration/identity/write hooks and dev hooks remain unfinished. New WeakMap allocation does not install reactive scheduling behavior. |
| Attribution relay diagnostics change (#4121). | Development/observe attribution remains outside the production profile. |
| Store slotKept, held unread-key leaf creation (#4159) and new store/edges exports. | Store APIs and CONFIG_SLOT_NODE remain explicitly unsupported. Reviewed module initialization: the slot-unobserved installer is still the shared store hook, new identity hooks are inactive, and the store's private deferred-release Set is separate from graph's new array. The actual full package index remains the reference entry. |

All added/unmapped units stay visible in the source inventory. Reviewing this
update does not close arbitrary unreviewed branch obligations or enable excluded
APIs. The semantic deviation register remains empty.

## Validation and proof boundaries

- Solid's unmodified signals suite: 325 files passed; 5,405 tests passed,
  three expected failures and two skips. Signals JS build and source declarations
  passed. The first pre-build suite run failed artifact-loading tests because the
  fresh checkout had no dist; rebuilding and rerunning the complete suite passed.
- Bend: 2,029 public differential histories, including 50 new integration histories,
  plus 88 separately counted direct owner/core probes and the full helper alignment
  suites (including 10,752 constructors). Existing identity and native controls pass.
- All 93 compiled source-changing mutations are rejected. The former "workaround"
  mutations are replaced by regressions that reintroduce the now-fixed bugs.
- Independent BendTT kernel checks 45 concrete regressions plus existing generic
  laws. The two previous negative laws become positive held-recovery/function-data
  regressions. Four new laws cover lazy reuse, writable-error display until commit,
  a later iterator throw reaching the memo, and empty flatten returning undefined.
  These are closed executions, not TS/Bend equivalence or arbitrary-program laws.

Remaining read-capable teardown admission is still gated on async/error/pending
World-helper crossings. The conservative call-site inventory now lists 13 core
crossings: the new protocol catch legitimately adds a handleError caller. This is
an inventory of potential call chains, not a count of failures or upstream bugs.

## New regression found during review

The ordinary #4142 case is fixed, but a cleanup throw in its new pre-body teardown
leaves the deferred collector installed. A later unrelated lazy memo then misses
its cleanup. This reproduces on current next in all three tiers and passes on
#4164's direct parent. Two new paired histories and one **negative** kernel law
preserve this current-pin behavior. No local repair is active. The review adds
50 public histories and five concrete laws in total: four positive, one negative.

[Reduced repro, source explanation and issue draft](../upstream/deferred-release-throw.md).
The candidate remains on the integration branch; main retains the original pin.
This known regression should be reviewed before adopting the candidate as main.
