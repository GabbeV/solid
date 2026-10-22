# mapArray extracted keys and reactive indexes

Source: Solid next `a2a5b6f8` (rc.16), production `src/map.ts`.
This extends [positional mapping](map-index.md) and [plain keyed matching](map-keyed.md)
through the same core machine. It does not replace their algorithms. All three
keying modes now execute within the typed array/callable profile. JSX/compiler,
stores/proxies/$TRACK hooks, active lanes/boundaries and dev/observe attribution
remain outside that profile, as do arbitrary JavaScript closures, function
property mutation and array protocols/coercion.

## Callback shape and representation

The constructor reads the original mapper's formal length once. CleanupProgram
stores that immutable metadata; functionLength gives bound core callables their
source lengths. The actual argument vector is independent of declared arity.
MapState.hasIndexes represents `_indexes !== undefined` even for an empty vector.
MapState.key is the admitted original callable or Undefined. `hasRows` represents
`keyFn || options.keyed === false`; it is independent of the current row count.

| Mode | Mapper arguments | Index signal | Matching |
| --- | --- | --- | --- |
| true/default, formal length <= 1 | raw item, one actual argument | absent | strict item identity |
| true/default, formal length > 1 | raw item, index accessor | present | strict item identity |
| false, any formal length | item accessor, numeric index | absent | retain by position |
| extracted key, formal length <= 1 | item accessor, explicit undefined | absent | strict raw identity or extracted key comparison |
| extracted key, formal length > 1 | item accessor, index accessor | present | strict raw identity or extracted key comparison |

Item and index accessors bind actual core signals created with ownedWrite:true.
They retain canonical function identity and update through the shared setter,
subscriber and scheduler code. Optional stages are allocated only when present.

## Source operation / return-point review

| Source segment | Bend segment and preserved order |
| --- | --- |
| Capture mapper/keyed option, `typeof keyed`, `map.length > 1`, then owner/data | Evaluate/MapMapper/MapInput, callable.functionLength, keyed-map.mapArray; mapper then keyed expression evaluate once before owner allocation |
| Prefix's captured `Math.min(len,newLen)` | MapPrefix/PrefixMatch.limit survives callbacks; suffix initializes from the live source len afterward |
| Raw identity before `compare(key,old,new)` | mapCompare/mapMatched; strict raw equality skips both callbacks; otherwise invoke captured key on old then new and compare strict results; no key with row mode matches position |
| Prefix retained item write | mapMatched calls actual setSignal before advancing; later callback failure does not undo that write |
| Suffix comparisons | mapSuffix shares compare return points; bound counters are exclusive source end+1 |
| Small-move gate | mapAfterTrim requires no rows and no indexes before the existing source gate/probe; indexed/extracted modes follow the general path |
| `stageRemoval`: new key once, scan old keys | mapRemovalMatch/MapRemovalNewKey captures newKey; mapRemovalOld/OldKey reuse it through mismatches, stage retained mapping/node/optional row/index, append removed owners in source order |
| Failed pure-removal probe | mapRemovalFailed clears node scratch and discards the local removal ledger before general preparation; row/index scratch survives as in source |
| Descending new-window key map | mapPrepareStart/mapPrepare/mapPrepared invoke one key at a time, then store next-chain and key-map entries before descending; no-key mode keeps prepareIndices |
| Forward old-window keys | mapOld/MapOldKey/mapOldPosition call the key before lookup, stage retained mapping/node/row/index and consume the duplicate chain |
| New row owner and signal creation | mapRows/mapInvokeRow/mapInvokeIndex store owner first, then raw item signal if present, then raw index signal if present, then original mapper with source arguments |
| Mapper catch | MapMapped/mapAbort dispose created rows only; key calls in comparison/preparation/removal remain outside this catch and reach the outer computed handler |
| `commitWindow` | mapWindow/GrowShift/ShrinkShift/Rows resize and copy suffix in the source direction; changed slots store node, optional row and item write, then optional index and index write |
| Retained suffix after a length change | mapWindowSuffix writes suffix item signals and then indexes; unchanged length skips this loop |
| Publication/removal | publishWindow stores mapped result, len and saved items before mapRemoved; cleanup errors preserve partial publication |
| Empty/fallback/create-all | clear/publishInitial include optional index stores at the source positions; the pinned `!_mappings[0]` guard is unchanged |

MapFrame.keyIndices is the key dictionary; MapFrame.indexes is the distinct index
signal vector. Dictionary keys use SameValueZero, while compare uses strict
identity, including its different NaN behavior. Typed ordered entry lists express
Map storage and do not claim native Map performance. No alternate reconciler,
rollback, scheduling policy or semantic workaround was introduced.

## Native observation

The native adapter invokes actual S.mapArray. Its mapper wrapper has the original
formal length so Solid itself chooses optional index signals. It observes actual
item/index getters, and its key wrapper observes reads made by the original key
callback. MapRowBound/MapIndexBound identify Bend's actual allocated signals;
these metadata events are excluded from public traces. Neither adapter chooses
retained rows, performs row writes, allocates emulated signals or schedules work.
Raw getter calls outside expression observation retain the existing read-trace
observation limit.

## Evidence and proof boundary

`tests/map-indices.mjs`: 27 paired histories cover arities 0/1/2/9, bound function
length, passed argument values, positional controls, stable getter identity,
nested memo updates, staged/pending changes, cleanup errors, broad changed
windows and once-only option/mapper expression evaluation.

`tests/map-keys.mjs`: 53 paired histories cover actual key-call order/count,
duplicate/NaN/reference/falsy keys, same-key fresh item updates, cached removal
keys, failed removal resets, prefix/suffix/reverse/old-walk errors, pending key
reads/retry, partial prefix writes, stateful keys and callback/action capture.
Ten new compiled finite variants target selected missing/wrong operations.
The prior 90 synthetic private-helper/return-point probes and seven packing
admission checks remain separate from these public histories.

Five quantified properties in proof/array-laws.bend check exact hole length and
content, dense slot presence, existing-slot payload retention and exact append-only
allocation preserving arbitrary surrounding state. Two compiled proof mutations
check that the assertions reject lost slots. Three closed map-lifecycle programs
use arity-two mappers, change [1,2] to [2,1,3], and check pre-flush committed reads,
post-flush item/index values, retained mapped-row identity, final row/map disposal,
three cleanup calls and restored ambient/fault state. They project a View rather
than asserting the whole final World. These are not a general mapArray theorem,
proof of arbitrary histories, formal TS equivalence or compiler verification.

Map-extension checkpoint totals: 3,048 paired histories, 213 rejected compiled mutations
(201 finite differential, 12 quantified proof-property) and 71 positive closed
regressions. The source/toolchain pins, kernel and proof budgets are unchanged.
All translated modes preserve SOLID-EMPTY-FALLBACK-006 while unmerged #4211 stays
outside the pin. The semantic deviation register remains empty.
