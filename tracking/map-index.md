# mapArray by index

Solid `a2a5b6f8` (rc.16), production `mapArray(list, map, { keyed: false })`,
now executes through Bend's existing core. Rows stay at their positions; each
mapper receives a stable item accessor and a numeric index. Reading that accessor
later observes the row signal through the ordinary core read machine.

This is a deliberately restricted constructor profile. Identity-keyed mapping,
extracted keys, index accessors, the small-move optimization and general keyed
window matching remain unfinished. They are refused at entry rather than
replaced with position mapping. Active stores/lanes/dev/observe and arbitrary
array protocols/closure environments remain outside the existing typed profile.

## Correspondence

| Source `src/map.ts` segment | Bend segment |
| --- | --- |
| `mapArray` data: internal owner, empty items/mappings/nodes/rows, list/map/fallback | `keyed-map.mapArray`, MapState arena; `_byIndex=true`, `_key/_indexes=undefined` are this profile's invariant |
| Eager computed, AUTO_DISPOSE clear, bound accessor | `core.mapCreate`, existing recompute machine, shared RepeatReady continuation |
| Set `_owner._parentComputed`, tracked list, `|| []`, length | `keyed-map.updateParent`, `core.mapRead/mapListValue/mapBegin`; falsy list allocates fresh empty array |
| Top-level `$TRACK` read | Inert for admitted plain arrays; store/proxy arrays/getters are unported, not simulated |
| Internal `runWithOwner` | Existing owner entry, saved RestoreContext and MapReturn through normal/exceptional unwind |
| Empty transition and fallback attempt | `keyed-map.clear`, `core.mapEmptyBody/mapFallbackCreate/mapFallbackBody`; source disposal/store/callback order and pinned truthy guard |
| Create-all staged arrays and mapper | MapFrame, `core.mapRows/mapMapped`; create/store owner first, allocate raw core `signal(item, { ownedWrite:true })`, then call map(accessor, index) |
| Create-all mapper catch and fallback commit | `core.mapAbort/mapInitialCommit`, then `keyed-map.publishInitial`; cleanup throws override and interrupt exactly as in source |
| Common prefix | `core.mapPrefix`; strict identity or `compare(undefined,...)` matches, then actual setSignal on the live row signal |
| Common suffix and stable-length return | `core.mapSuffix`; prefix always exhausts one side in this profile, so the suffix is empty; equal lengths save an items slice and retain mappings identity |
| Growing changed tail: backwards key-map preparation | `keyed-map.prepareIndices/indexGet/indexSet`, distinct missing/-1/index representations and SameValueZero key equality, before new-row creation |
| Shrinking changed tail: `stageRemoval` | `core.mapRemoval`; destination window is empty in this profile, so the source final loop collects old tail owners in order |
| General mapper catch | MapFrame.created ledger and `core.mapAbort`; only freshly created rows are disposed, prior rows/arrays remain |
| Prefix/suffix mapped values at commit | `core.mapCommitPrefix`; the suffix is empty in this profile |
| `commitWindow` | `core.mapWindow/mapWindowRows`; pre-size growing live vectors or shrink after the empty suffix loop, assign node then row then setSignal at each changed slot |
| Final general publication and removal | `keyed-map.publishWindow`, then `core.mapRemoved`; mappings/len/items land before removed-row cleanup |

Source inclusive end counters use exclusive bounds (source value plus one), so
zero represents source -1 without saturating a decrement at an array index.
The invariant is stated at the helpers and all applicable guards use the encoded
bounds. Internal node/row vectors are finite lists in MapState/MapFrame; their
contents change at the source stores and the state ID retains the data receiver.
Mapped results and saved items use the existing stable, hole-aware array arena.
The JS Map representation is an ordered typed entry list: it implements key
lookup/set, retaining distinct undefined/-1/index states and SameValueZero.
Its representation cost is not a native JavaScript Map performance claim.

No alternative list reconciliation, scheduler or rollback is introduced. Prefix
row-signal writes occur before the later mapper try/catch. A failed later mapper
does not undo those earlier writes. The source's stable-array identity arm and
the difference between create-all and general publication/disposal order remain.

## Native observations and evidence

The Solid adapter calls the actual public `S.mapArray(..., { keyed:false })`.
A mapper observation wrapper records the native item-accessor identity/metadata,
then calls the original admitted callback with the original two arguments. This
profile forces `_indexes` absent regardless of wrapper arity; the wrapper does
not choose any row, make a write, schedule work or emulate a signal. Bend's
MapRowBound event labels its actual allocated signals at the corresponding
point. Native row reads through expression invocation are observed normally;
raw JS calls outside that expression observer retain the existing read-trace
observation limit.

`tests/map-index.mjs` adds 57 paired finite histories covering values, item
accessor identity, equal-length result retention, growth/shrink/empty transitions,
raw signal state/configuration, owner trees, mapper errors, pending retries,
cleanup-error partial commits and abort-error precedence. Callback/local/action
captures include variable arity and nested action parameter scopes. Scalar
results deliberately remain the initial mapper result; reactive nested memos or
returned accessors observe subsequent item values through the row signal.

Eight compiled mutations target lost parentComputed, missing ownedWrite, skipped
prefix updates, raw item arguments, omitted fallback/removal/abort cleanup and
silently applying the unmerged fallback fix. They are assertion-oracle checks,
not proofs or fuzzing. The independent kernel rechecks existing 68 closed
regressions and all quantified properties after adding World.maps; concrete
witnesses have an empty maps arena and generic World laws preserve any arena.
There is no new general mapArray theorem in this checkpoint.

Both translated list profiles preserve `SOLID-EMPTY-FALLBACK-006` and the pinned
`!_mappings[0]` guard until upstream PR #4211 lands and is reviewed. No semantic
workaround, source pin, kernel or proof-budget change is active.
