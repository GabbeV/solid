# Observation lifecycle simplification investigation

Status: source review plus an isolated collection-semantics fixture. No runtime
changes, runtime tests, builds, benchmarks, or new size measurements.

## Mechanism and evidence

- `layers/observation.ts:46–50`: `dirty` is the live selection/settle worklist;
  `watching` retains active source questions between flushes. `selected` makes
  pull-time selection receive a propagation round before retirement.
- Activation: selector → `markObservation` (`observation.ts:228`) marks dirty,
  installs release cleanup, wakes coordination; prepare samples held/pending
  proposals (`:63–85`); settle records the parent and adds active watches
  (`:152–160`). Both observations of a held synchronous answer prepare before
  consumers run, avoiding latest-new/pending-old publication.
- Repeated proposal: prepare cancels an obsolete restoration if inputTime
  changes (`:66`); latest additionally selects at direct and memo-wrapper reads
  (`latest.ts:43–80,214–218`). Without pull preparation, a calculation can cache
  an old latest value alongside a newly held input proposal before the global
  preparation phase. These call sites cover different entry paths.
- Retirement: prepare inspects all watches only after new selections propagate
  (`observation.ts:89–125`). It chooses the still-owning input question, checks
  lifetime readiness, and calls `resumeInput` before publication. New ordinary
  consequences can then hold restoration and input together. A retiring record
  stays until its parent finishes or the input revision changes (`:147–150`).
- Disposal/dormancy: release removes both memberships and clears parent,
  retirement and override (`:211–225`). Auto-disposed outputs also discard a
  staged first value and restore uninitialized status for revival.
- Settle first unions watching into dirty (`:132`), then samples that live Set.
  Thus active watches pay Set-add attempts every settle, plus sampling/parent
  selection except while a same-revision retirement remains live. Prepare's
  separate scan pays readiness work; these phases have different obligations.
- Pending equality/quiet refresh/declared marks are in `pending.ts:53–119`;
  source input equality is called from sampling and parent selection. Pending
  can follow explicit input boundaries beyond its immediate ready input.
- Latest sampling (`latest.ts:87–118`) preserves selected errors during re-asks
  and repairs output/input publication mismatch after an input commits. An equal
  restoration is not proof that its publication context/owned async work is done.
- Callback windows (`window.ts:52–102`) dispatch only the owning computation's
  reads through the observation, restoring the parent window around each read.
  Nested computations retain ordinary read/context rules; this is semantic work,
  not duplicate selection. Pending's second value read drives control flow,
  while its first output read selects the shared context (`pending.ts:256–308`).

Historical measured attribution: stage182 `size-scalar.json`, observed-optimism
scenario, has observation 1,272, pending 1,521, latest 1,384, window 530 and
coordination 9,390 minified module bytes. Bundle total 43,434 min / 15,330 Brotli;
next `4fe75321` is 35,643 / 12,920. Module bytes are attribution, not independent
compressed savings. No proposed deletion has measured savings.

## Candidate 1: delete settle's watcher-to-dirty Set union (conditional)

The smallest apparent change traverses dirty, then watches absent from dirty,
using one shared settlement body. It deletes `watching.size` Set-add attempts
per settle, not the readiness scan, parent resolution, sample, or stage work.
No ordinary node pays; watched observations exchange those additions for
membership checks and possibly a helper call. Complexity remains linear in the
same records. Minified-byte direction is unknown and could be worse.

**Naive form rejected.** The current iteration is live: sampling watcher B can
append previously clean C to dirty, and C is sampled before the final clear.
Deleting/readding visited A can put A at the tail and run it again. Two-pass
iteration instead misses these tail entries, then clears them. Sampling cannot
simply be assumed pure: pending sampling/parent selection calls a user comparator
(`pending.ts:61,80,116`), which can query another observation or release readers.
A write-free public-API sketch is an input comparator that first queries
`isPending(c)` for an initialized, never-before-observed C. `pendingOutput`
creates its companion; its first read enters `selectObservation` and immediately
calls `dirty.add(C)`. Untracked auto-disposal is deferred, not inline
(`core/graph.ts:138–160`). This is a source-verified synchronous append route,
not an executed runtime reproducer. Arranging the first query specifically in
watcher-only settlement rather than an earlier comparator call remains unproven.
The delete/re-add example below is collection-only; its runtime reachability
was not established. Preserve current ordering conservatively.

Minimal collection fixture: scratch `settle-iteration.mjs` produces
`new: original=A,B,C two-pass=A,B` and
`readd: original=A,B,A two-pass=A,B`. It tests JavaScript Set behavior only.
A snapshot allocation alone also drops live additions. Preserving order and
revisits requires a live union worklist or additional queue/membership state;
that cost can erase this candidate's benefit. Do not implement pending a real
purity contract or a demonstrably equivalent iteration algorithm. Falsifier:
any differing sampling/publication order under supported reentrant operations.

## Candidate 2: replace watches with transaction-local lifecycle delivery

Existing queues do **not** currently suffice; that does not prove global scans
inherently necessary. `notifyLayer` (`coordination.ts:1197`) propagates held child
contexts on value/status edges. `pendingNodes` (`scheduler.ts:1566`) indexes
staged nodes; `rerunHolders` (`:437,1756`) indexes waiting readers. Neither indexes
an observation whose source question becomes ready because a sibling completes,
a hold is disposed, or an equal answer commits without notifying its value edge.
Declared affects and snapshot readiness are further value-independent events.

A replacement design could attach observation subscribers only to transactions
that own their lifetime, and enqueue their records when those transactions'
lifetime readiness changes. Reparenting on new questions moves membership;
merge transfers/splices lists and aliases; disposal unlinks; completion detaches
and queues subscribers. Queue draining replaces `watching` readiness iteration,
not supplements it. Parentless active pending (declared marks, unheld async
questions) still needs source-status/declared-mark delivery, including incoming
explicit boundaries. Retiring records need a completion/revision event too.
Readiness must use `blocked(parent)` lifetime rules, never publication readiness,
and notifications must precede ordinary-reader replay/publication.

This could remove idle watch sampling and readiness checks during unrelated
flushes, at the price of feature-local membership links, queue deduplication,
merge/disposal operations and readiness-transition detection. It is a redesign,
not a bounded cleanup, and adds persistent bookkeeping absent today. No ordinary
node should gain fields/notification work. Falsifier: any readiness transition
that changes selection without delivering its record; proving that event set
complete is the main task before an implementation would be justified.

## Smallest meaningful next experiment and controls

1. First isolate a supported runtime comparator/query or disposal fixture for
   live dirty mutation; compare complete publication logs, not just final values.
   If mutation is intentionally unsupported, document that semantic ruling before
   considering the two-pass candidate. Avoid a snapshot as an unexplained fix.
2. For a transaction-local design, first enumerate and trace existing readiness
   transitions (merge, hold release/disposal, equal landing, action close,
   declared mark clear, incoming-boundary replacement); do not add a second index
   while retaining the global watch scan as the purported optimization.
3. Minimum existing controls: `unified-latest.test.ts` first-value/error recovery,
   equal-owned-child and repeated-proposal cases; `unified-owned-latest-repeat`;
   `unified-pending.test.ts` completion supersession/new action during false;
   `unified-unheld-observation-reversal`; `unified-observation-dormancy`;
   `unified-refresh` quiet/equal cases; `unified-pending-error-observation`;
   `unified-observation-context` and `unified-pending-callback-values`; all thirteen
   stage182 hydration snapshot controls. Include disposal and incoming-boundary
   cases before broader validation. No checks were run against runtime here.

The hydration repair in `INTEGRATION-182.md:7–27` is a concrete counterexample to
value-only notification: a refetch changes readiness while preserving value.
`SIZE-96.md` also warns against quadratic disposal scans; avoid replacing indexed
release with whole-graph searches. No pending/latest semantic change is proposed.
