# Plain identity-keyed mapArray

At Solid `a2a5b6f8` (rc.16), default/`keyed:true` mapArray now executes the plain
identity-keyed mode without index accessors. This extends the separate
[keyed:false profile](map-index.md); it does not substitute one for the other.
The admitted callable metadata has native arity zero or one. Extracted keys and
index-accessor mapper modes remain unfinished. Stores/proxies, dev/observe names,
active lanes and arbitrary array/closure protocols remain outside the profile.
The JSX `<For>` component/compiler is not itself a Bend translation.

## Source operations

`mapArray` still constructs its internal owner/data before its eager computed,
clears AUTO_DISPOSE afterward and returns the existing bound accessor. MapState
now tags the by-index versus plain mode: rows are absent for the latter, and
indexes/key callbacks remain absent in both. Empty/fallback/create-all and
exception continuations retain their distinct source commit/store order.

| Pinned `src/map.ts` operation | Bend return points / helpers |
| --- | --- |
| ParentComputed, tracked list, `|| []`, length, internal owner | Existing `mapRead/mapListValue/mapBegin`; the `$TRACK` read is inert only for admitted plain arrays |
| Strict prefix/suffix matching | `keyed-map.matches`, `core.mapPrefix/mapSuffix`; row writes occur only in by-index mode; exclusive end counters encode source inclusive end plus one |
| Stable length/content | `mapAfterTrim` saves an items slice and returns the original mappings array |
| Small-move gate and ±32 probe | `mapAfterTrim/mapSmallMove`, `small-move.probe`; source large trimmed-window/newLen/rows/indexes conditions remain |
| General stage allocation | MapFrame/new mapped array plus window-sized node stage; the absent rows/indexes allocate no signal stage |
| Pure-removal attempt | `mapRemovalMatch/mapRemoval`: forward comparison, staged retained values/owners, ordered removed ledger; failed attempt clears node scratch before key-map matching |
| Backwards key-map and duplicate-chain construction | `keyed-map.prepareIndices/indexGet/indexSet/nextIndex`; MapIndex distinguishes undefined, -1 and a real position; Map keys use SameValueZero |
| Walk old changed window | `mapOld/mapOldPosition`: stage retained mapping/owner at first remaining duplicate position, consume that chain, otherwise append removed owner |
| Create absent new rows | `mapRows/mapInvokeRow/mapMapped`: create and record owner before calling the original mapper with the raw item and no index argument; retained stage slots skip construction |
| Mapper catch | `mapAbort` disposes the created ledger only; cleanup exceptions override and interrupt; no exiting old row disposes before mapper success |
| Final mapped prefix/suffix | `mapCommitPrefix/mapCommitSuffix` copy from the original mappings into the fresh result before live vector changes |
| In-place bookkeeping | `mapWindow/mapWindowGrowShift/mapWindowShrinkShift/mapWindowRows`: grow before descending suffix copies, or ascending copies before shrink, then land changed window nodes |
| Publication/removal | `publishWindow` stores mappings, len, items slice, then `mapRemoved` disposes removed owners in order; errors preserve the source partial publication |

The source Map representation is an ordered typed entry list, not a different
reconciliation algorithm. Internal list/array representation costs are not a
claim of native JS Map/array performance. Captured bounds and original arrays
stay captured; source live state lookups remain live at their return points.
No alternate engine, eager old-row destruction or rollback is introduced.

## Small-move optimization

`runtime/small-move.bend` follows the two source functions and keeps their split:

- `trySmallMove` scans two cursors with a budget of 256 comparisons, bounded
  lookahead of at most 32 per side, flat aligned-run triples and ordered source/
  destination position ledgers. Equal/mismatch, deletion/insertion preference,
  exhausted-budget/capacity bailout and tail-loop guards remain in source order.
- `commitSmallMove` first pairs displaced destinations with unconsumed source
  positions by strict identity. An unmatched destination bails before any live
  allocation/store. It then builds the SameValueZero displaced set and declines
  ambiguous duplicate identities appearing in retained runs, preserving the
  general matcher's occurrence ownership.
- On success it slices mapped/node arrays, copies moved runs, patches displaced
  pairs, stores mappings/nodes/len/items, and finally disposes unmatched captured
  source owners. `SmallPlan` carries that last cleanup return point to the shared
  core owner driver; a cleanup error escapes before the source call can return.

The scan has structural fuel oldLen+newLen+1; each iteration advances a cursor.
Exhaustion is an explicit Unsupported(85), never a successful negative probe.
The bounded lookahead and 32-entry ledgers stay source controls, not a replacement
algorithm chosen to make a proof easier.

Packing keeps source `p << 6 | found`, `>> 6` and `& 63` within their nonnegative
signed-32 domain. A 25-bit position check refuses overflow with Unsupported(84),
rather than silently using unbounded arithmetic for negative JS packed results.
General overflow/negative array properties remain unfinished. Source positions
in the tested public cases are far inside this domain. Consumed scratch slots
are represented by false for unassigned/falsy entries; an empty vector is the
source undefined ledger, and cleanup preserves its source guard and order.

## Evidence and limits

`tests/map-keyed.mjs` adds 62 paired histories covering prefix/suffix trimming,
stable mapped identity, mixed edits, reversals, duplicate items, NaN/reference
keys, pure removals, grow/shrink commits, empty/fallback transitions, mapper
throws, pending retry and cleanup errors. Large cases cover rotations, swaps,
replacements, interleaved removals, duplicate ambiguity and exact 32/33-entry
capacity transitions. Returned row owners/arrays retain their native aliases.

`tests/map-alignment.mjs` uses the actual pinned private function bodies exported
only in an in-memory bundle. Thirty-four trySmallMove states, 25 engine fast-path
return points, 24 stageRemoval states and seven commitWindow states compare
verdicts, mapped/node/item state, scratch holes/reset, publication and removal
order. These synthetic root labels are not complete public graphs. Seven
packing-admission checks are separate. The probe recompiles a mutation's copied
runtime when BEND_EMIT_FILE is supplied, rather than testing unchanged sources.

Nine new compiled mutations target SameValueZero, duplicate-chain consumption,
retained-owner matching, suffix copies, live shifts, small-move run copying,
duplicate safeguards, matched-owner disposal and silently bypassing the fast
path. They are assertion oracles, not formal proofs. The full comparison and
alignment suites and original kernel claims are rechecked on this runtime.
No new general mapArray theorem, source pin, proof budget or semantic workaround
is introduced. Both mapArray profiles retain the pinned falsy-fallback remount
bug while submitted #4211 remains outside the baseline.
