# Verdict bookkeeping dependency

Source `core/verdict.ts`, Solid a2a5b6f8 (rc.16). The restricted helpers now run
in `runtime/verdict-state.bend`. Public latest/isPending callback windows,
verdictValue read dispatch, heldNotFinal's raw comparator continuation and active
lane stage/read/write/block/seam/correction/dissolution remain unfinished. No
synthetic verdict is exposed through the public expression grammar.

## Source operations

| Source | Bend | Correspondence |
| --- | --- | --- |
| latestActive/probing/probeFound and nullable dispatch | World.verdictState | Explicit ambient fields. This stage primes private helper inputs only; public windows are not yet admitted. |
| watchVerdict | watchVerdict | Set UNANSWERED when requested, then append the actual reader to stagedReaders. |
| route | route | Check captured pass lane and JOINED/STAGED_READ before allocating the actual cached verdict lane; set LANE_READ afterwards in every case. |
| verdictRead | verdictRead | Route first, then plain staleReader or probe rerun append. Only the last reader is deduplicated: [a,b,a] stays [a,b,a]. |
| provisionalVerdict | provisionalVerdict | Non-probe joins the future and routes. Existing-transaction probe records found when needed, routes and watches staged reads. Before any transaction it watches unanswered without prematurely setting found. |
| quietPending | quietPending/quietSources/reasks | Missing extension is false. A present source Set checks every source's own reask, including true for an empty Set; absent Set uses the node's own reask. |
| pendingVerdict | pendingVerdict | Initial loading returns before updating found or routing. Otherwise preserve probing, tracking, held/transaction and running-flush gates in order. |
| markVerdictReader | markVerdictReader | Root forwards to its parentComputed; tracked owner config is updated before PROBED. Observe-only window attribution is unfinished. |
| observeFlight | observeFlight/observeAfterBirth | Published inputs refuse before txOf; born-held reader refuses after actual txOf/bornInto. A running observation joins a future, queues an unheld flight, then makes the plain stale verdict read. |
| staged | staged | CONFIG_STAGED_ERROR throws the original pending payload through the existing Fault channel; no local catch, coercion or wrapper is added. |
| heldLatest | heldLatest | Actual unflushedValue first, staged/error fallback when absent, then late-linker flag for a nonnull reader before returning the unflushed value. |
| GlobalQueue._witnessMark | witnessMark | Set found only while probing. |

Source module globals are grouped in one record, without replacing decisions.
Source Sets retain their existing stable arena handles/tombstones. The read and
throw helpers use the same Value/Slot/Fault representation as the current core;
NOT_PENDING remains distinct from present undefined/falsy values. Helpers that
need joins, holds, birth checks, cached lanes and staged readers call those actual
translated implementations. Private held metadata must have a valid transaction;
constructor invariants are not replaced by defensive guesses. The tests exclude
impossible held-reader metadata with no live transaction.

## Verification scope

2,356 native private-helper comparisons cover missing/empty/multiple quiet
sources, reask combinations, root forwarding, untrack, original ambient flags,
route guards, plain/probe reruns, same-reader versus interleaved rerun entries,
before/after transaction provisional judgments, initial loading, held membership,
input publication, born-held observation, running/outside-flush work and mark
witnesses. They compare source transaction allocation/membership/cache/reruns,
node flags/config/status/extension identities, pending/staged/live vectors,
pass/flush/scheduled state, answers and all verdict ambient fields.
960 separate heldLatest controls cover running state, tracked reader presence,
flushed stamp matches, promotion, staged-error throws, absent versus present
undefined/false/numeric staging and snapshots. Raw falsy throw payloads are
observed with a separate did-throw flag. In-memory private exports/priming only
expose existing state; source function bodies and vendored files are unchanged.
These synthetic helper comparisons add no public histories or closed programs.

Six quantified properties, rooted in LAWS/PROOF and checked by the unchanged
independent kernel, cover:

- Missing-extension quietPending is false.
- An explicitly empty source Set is quiet, regardless of the node's own reask.
- A mark witness outside a probe preserves the exact World.
- A provisional probe before a transaction records the seam reader/UNANSWERED
  flag while preserving the exact rest of World, including found and transactions.
- A joined reader receives LANE_READ without opening or joining a verdict lane.
- Held latest during a flush throws the exact raw staged error without marking
  a late linker or changing other World fields.

They quantify surrounding World/records/arenas/payloads, using designated existing
arena slots and the stated branch conditions. They are not a general verdict
window, arbitrary graph/history or TS/Bend equivalence theorem. Eleven added
compiled variants target missing/empty sources, out-of-probe witness, premature
pending, raw errors, routing, rerun order, root forwarding, published inputs,
late linking and loading. Five fail proof assertions, six native helper assertions.
The full 251-variant mutation sweep, prior public histories and proofs are
rechecked. The source pin and empty semantic deviation register stay unchanged.
