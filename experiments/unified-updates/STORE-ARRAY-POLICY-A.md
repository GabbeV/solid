# Array policy A implementation checkpoint — 2026-11-13

User approved: value-only existing-index edits stay granular; structural changes
coordinate active direct edits and subsequent edits, including incoming structure.
This checkpoint is work in progress, not a completion or mergeability claim.

## Implementation

- Replaced per-action array length floors with one selected length and an ownership
  marker for structural changes. No array snapshot is treated as an override.
- Coordinate structural incoming answers through direct and chained inputs, with
  an opt-in input watcher only while selected array edits are alive.
- Separate parent pending authority from published descendant value accessibility.
  This repairs regressions in the preceding pending checkpoint without weakening
  error, late-reader, or parent-pending assertions.
- Discard initial writes while coordinating their update with the first-answer
  producer. Temporary ordinary drafts preserve producer staging, failed callbacks
  clean up, and a held first answer retains its uninitialized status until commit.

## Validation so far

- Array setter, incoming, rearrangement, and lifecycle focused group: 60 passing.
- Parent pending/late reader/error group: 81 passing.
- Structural migration groups: 68 and 67 passing; array dependencies: 15 passing.
- New initial integration group: 20 passing; development/production earlier group:
  18 passing each. Source typecheck passed. These receipts are separate snapshots,
  not a deduplicated total or a final frozen acceptance run.
- Test migrations retain full array and ordinary sibling publication assertions.
  They remove old sparse-output expectations only where the selected rule changes
  coordination, and keep independent value-edit controls.

## Known failures / outstanding work

- `unified-array-latest-structure`: latest of the selected store can expose a hole
  during incoming shrink. Ordinary output stays coherent. This is a real bug to
  fix, not latitude granted by latest. Unsuccessful context-read trials are saved
  separately and are not accepted runtime changes.
- The migrated initial guessed-leaf regression exposes different imperative reads
  after an answer arrives while the writing action is open. Investigate actual
  late-rendered readers before claiming initial integration complete.
- Remaining store migrations and a fresh full suite are pending. `until` remains
  deliberately deferred; historical baseline has 135 exact dependent failures.
- No current shipped-size or performance claim. Initial integration adds cold
  draft handling; structural guard cost is opt-in. These costs still require
  measurement against actual upstream next.

Initial full discovery run: 7,882 pass / 227 fail / 5 skip, before subsequent fixes
and migrations. A comparison checkout had missing built imports, so its 192
failures are not a valid semantic baseline count. Receipt identities remain useful;
no failure is waived merely because that baseline also failed.

## Follow-up checkpoint

The initial-write integration now passes 33 tests in both development and production,
including actual unattached DOM preparation and late binding publication. The old
preinitial guess expectations have been migrated; scalar first guesses remain
supported. An unanswered chained array method that reads length before mutating
still throws, just as next does; callbacks are not replayed.

The late-reader hang was a scheduler invariant violation: a saved transaction had
merged during computation, but the reader was appended to its obsolete list. The
list insertion now resolves the surviving owner. This affects the held path only.
A separate first-answer control-value staging fix and first-screen read gate prevent
seed/answer leaks. Source typecheck and focused first-mount/error checks pass.

Frozen source full run after those fixes: 8,006 passed, 174 failed, five skipped.
Exactly 135 failures match the previously inspected deferred-until identities;
39 need migration or repair. Test-only migrations afterward do not rewrite that
receipt. The source hashes remained unchanged throughout the full run, and the
package was rebuilt before it.

The first latest repair passes nine every-publication fixtures, but is NOT final:
true active chains (inner existing-index override plus outer append) still expose
holes on incoming shrink, and the structural context dependency regresses a repeated
error boundary case. Further review is checking whether structural context is
established too late or too broadly. A proposed migration that makes the internal
shape watcher retain an otherwise unobserved input flight is not accepted merely
because the implementation does it; existing observedness rules remain in force.

A passing initial group or a same-length append chain is not store completion.
No final size/performance claim is made while these correctness gaps remain.
