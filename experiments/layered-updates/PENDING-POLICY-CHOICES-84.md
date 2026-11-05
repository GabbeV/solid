# Pending feedback: coherent programs, restrictions, implementation costs

This is a semantic investigation, not a newly accepted restriction. Production
core remains unchanged. The user explicitly rejected treating an effect which
writes a signal as a generally acceptable replacement for a derivation.

## A coherent mixed async derivation exists

```js
const [id, setId] = createSignal(0);
const details = createMemo(() => fetchDetails(id()));
const badge = createMemo(() => renderBadgeAsync({
  id: id(),
  pending: isPending(id)
}));
// Render id, details, badge and isPending(id) independently.
```

`renderBadgeAsync` stands for an async producer of the composite presentation,
such as a worker rendering a bitmap. Both fields affect the actual answer.
Merely extracting the object into a synchronous memo does not remove the
transitive mixture of value and status dependencies.

The executable audit uses strings instead of bitmaps and an already-answered
initial frame. It varies whether another request, an open action, or nothing
else holds the input update. It also varies whether the pending presentation
finishes before or after the independent cause ends.

Candidate, independent cause ends after pending presentation:

```
id=0, pending=false, badge=0:false
id=0, pending=true,  badge=0:true
id=1, pending=false, badge=1:false
```

The correction waits for its async badge before publishing id=1. If the
independent cause ends first, the pending presentation is discarded and the
candidate goes directly from the first frame to the last. These are coherent
visible sequences; the latter resembles an optimistic proposal expiring before
its downstream work can reveal.

Without an independent cause, candidate also goes directly to the final frame.
It starts badge(1,false), cancels it for badge(0,true), cancels that pending
presentation, and restarts badge(1,false). That is wasted work and gives no
visible pending indication, but it is **not a demonstrated value tear or proof
that no coherent semantics exist**. Whether the observation's lifecycle and
absence of a visible pending state are desirable remains a semantic question.
These finite timelines are not a general convergence proof for feedback graphs.

Pinned next is not a coherent reference for every frame here. With an independent
cause, it can publish id=1 while badge still contains 0:true; in the early-ending
variant the independently rendered pending boolean is already false too. With
no independent cause its first pending boolean can publish ahead of the badge.
All variants eventually settle, but that does not satisfy the consistency target.

## What this means for restrictions

The question is not whether every mixed async program is inherently impossible.
Some produce coherent and useful speculative presentations. A restriction could
still deliberately reject them to simplify the supported contract, but it must
say so rather than calling every occurrence a mistaken program.

Possible contracts:

1. **Support mixed derivations under ordinary optimistic supersession.** Accept
   that obsolete calculations can be discarded and repeated. Preserve coherent
   publication and bounded lifecycle behavior; fix unnecessary context churn
   such as the stage-82 pure-latest duplicate independently. No blanket error
   solely because pending caused cancellation. Requires further adversarial
   validation of self-feedback, especially convergence and observation lifetime.
2. **Explicitly prohibit an async derivation from mixing an ordinary input with
   that input's pending output.** Reject the badge program even when a sibling
   or action makes its timeline coherent. Preserve status-only async derivations
   such as delayed indicators. A stable structural contract is more explainable
   than allowing it only while another blocker happens to exist. It is a real
   expressiveness restriction, including transitive mixtures through memos.
3. **Suppress selected notifications or exclude a reader from its own status.**
   This creates a read/propagation exception. It does not follow from ordinary
   layer publication and could make ordinary descendants disagree with the shared
   pending output. It is not a harmless warning implementation. An explicit
   defer/snapshot API could express a boundary; silently inserting one cannot.

Keeping multiple simultaneous versions of an arbitrary async computation is
another architectural option, but neither necessary to obtain the coherent
tested sequences nor a cheap diagnostic change. Current nodes have one active
flight, and values, errors, dependencies, and owned children would all matter.

## Implementation reality

The pre-adoption notification path has the current flight, source, lower owner,
and incoming context. At actual recomputation the old owner may already be
overwritten. Same-update membership does not identify an invalid pattern;
historical notification-to-cancellation attribution is not stored.

A structural prohibition could instead be checked at async acceptance, when the
computation has collected its synchronous dependencies. That avoids needing a
history of cancellation reasons and can use the normal computation-error path.
It can be placed after the async-shape check, leaving ordinary synchronous reads,
writes, and calculations untouched. But it is not a complete implementation yet:

- **Callback observations defeat the current graph-only predicate.** The
  pending callback machinery uses an ordinary read for settled control flow.
  Thus `isPending(() => data())` leaves a value edge where direct `isPending(data)`
  does not. The status-only delayed indicator test sees this edge when it starts
  its hide timer. Without distinguishing its origin, the check would reject one
  spelling of an otherwise equivalent status-only program.
- Distinguishing those reads requires either extra attribution or a different
  representation of callback observation. A cold observation-owned computation
  is a possibility, not a implemented or measured solution. Simply untracking
  the control-flow read would lose necessary dependency tracking.
- Indirect mixtures require graph traversal; there are no cached flags on
  ordinary nodes. Existing committed/proposed dependency distinctions must also
  be respected. Temporary traversal allocation is not free, even in development.
- A returned async iterator collects initial dependencies during its first
  tracked step, not when its iterable object is first returned. A promise can
  already have started external work before a return-time guard runs.
- A production throw must route through computation error handling and correctly
  retire resources/consume abandoned promise rejections. Throwing directly from
  scheduler notification is not an established safe implementation.

If a pattern is declared unsupported to prevent instability, enforcing the same
error in dev and production is a reasonable direction to measure. Rich diagnostic
messages can remain dev-only. This does not require ordinary-node fields in
principle, but the callback representation, graph scan, shipped size, async cost,
and cleanup behavior must be established rather than assumed. No guard, extra
bookkeeping, or silent production behavior change has been installed.

## Evidence

- `pending-feedback-coherence.mjs`: five controlled timelines per runtime.
- `results/pending-coherence-stage84/{baseline,candidate}.json`.
- `packages/signals/tests/layered-pending-callback-diagnostic.test.ts`: both
  callback/direct forms tested at timer creation, proving their graph difference.
- Pinned next remains `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`; candidate is
  the existing stage-79 production build. No performance measurements claimed.
