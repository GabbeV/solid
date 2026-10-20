# SOLID-DEFERRED-RELEASE-THROW-004

Classification: reproduced suspected upstream regression; not filed. Discovered
while validating the pin update, 2026-10-20 (Europe/Stockholm).

A cleanup throw during the pre-body teardown of an unfinished pass leaves graph's
module-global `deferredReleases` pointing at that pass's array. Catching the throw
and continuing does not repair the pointer. A later, unrelated lazy memo loses its
last observer but is queued into the abandoned array, so its cleanup never runs
while its own owner remains alive.

The problem is the subsequent unrelated release, not a demand that the interrupted
owner walk continue after a callback throws.

## Evidence

The actual full package index is bundled without rewriting Source. The reduced
public-API repro is [tests/upstream/deferred-release-throw.mjs](../../tests/upstream/deferred-release-throw.mjs).
It needs no private exports, adapter, DOM, action, timer or pending-read exception
interception. One unresolved promise makes the first pass unfinished. The unrelated
lazy value is synchronous.

| Source/build | First cleanup returns | First cleanup throws 99, caught by caller |
| --- | --- | --- |
| d2ad8b28, original production baseline | later cleanup 1 | later cleanup 1 |
| a9b9f9e4, direct parent of #4164, production | 1 | 1 |
| 71153bf0, production | 1 | **0** |
| 71153bf0, development / observe | 1 | **0** |
| 71153bf0 with only restoration in finally, local source experiment | 1 | 1 |

Node 24.19.0, esbuild 0.25.12, __TEST__=false. Tier flags match production,
development or observe as named. `git ls-remote` confirmed remote next was still
71153bf0 when checked. The committed validation record includes the raw rows.
The local fix experiment used an esbuild onLoad replacement in a separate bundle;
it is not in the vendored Source or active Bend runtime and has not had the full
upstream suite run against it. No performance or code-size claim is made.

The complete unmodified upstream suite passes despite this uncovered case. The
normal #4142 rebuilt-reader case is fixed and its new tests pass; this is a distinct
exception-path regression in the newly introduced collector.

## Source mechanism

#4164 / 6371b910 adds this pre-body segment in `core/core.ts:recompute`:

```ts
const prev = deferredReleases;
deferReleases((released = []));
disposeChildren(el);
deferReleases(prev);
```

A throw in disposeChildren skips restoration and also precedes this pass's body
try/finally. Subsequent graph.unlinkSubs calls append eligible last-reader nodes
to the abandoned array. No pass later iterates it. A local experiment changes only
the disposal/restoration pair to try/finally and makes both repro controls pass.
The pending pass can still abort exactly as it did; restoration does not require
swallowing the original error or completing the interrupted owner walk.

## Port and proof treatment

Bend preserves this behavior. `RestoreDeferredReleases` runs on successful prelude
return and is skipped on unwind, matching Source. Two complete public integration
histories compare returning/throwing controls. The concrete **negative** law
`throwing_teardown_leaks_release_collector` checks the caught 99, active collector,
queued unrelated node, missing cleanup, retained lazy node and restored ordinary
ambient fields. It does not prove desired cleanup behavior.

The mutation suite rejects an unregistered finally-restoration workaround. The
semantic deviation register is empty. A future upstream fix must change the
corresponding unwind rule, flip these regression expectations, and retire this
active counterexample at an audited repin.

## Related reports and search limits

Reviewed #4164's description/discussion and searched open/closed Solid issues for
`deferredReleases`, `cleanup throw` and `lazy memo release`. No exact duplicate was
found in the returned results. Related but different:

- #4142 / #4164: ordinary rebuilt-reader lifetime, the change introducing this collection.
- #4089: cleanup writes resurrecting a landed transaction; its partial-throw note
  concerns that landing, not a leaked global graph collector.
- #4111: comparator/pending handling and a lazy dependent's missed release.
- #2813: repeated throwing effect cleanup; this repro's later victim is unrelated.

These searches are evidence of the review performed, not proof that no duplicate
exists. [Prepared issue text](deferred-release-throw-issue.md); nothing was posted.
