# Automatic coordination checkpoint — stage 40

This is a separate executable model in `scheduler.mjs`; the Solid runtime is
unchanged. Preparation and publication are now selected by the scheduler, not
by test calls to `prepare(groups)` or `commit(group)`.

## Subsequent user ruling: entanglement carries lower position

The user explicitly ruled that if c is above a, and a entangles with b, c must
also be able to publish using committed b. Replacing a and b with ordinary
signals must not change that relationship. The proposed next-like alternative
where publication coordination does not extend the lower position is rejected
for this case.

The order-dependent example below is now an implementation/model defect to
resolve, not permission for either intermediate frame. The expected held frame
is a=0, b=0, c=10, enabled=false, p=0, q=10. The current scheduler already handles
this when the a/b join is established first. Its unresolved problem is making
that relationship prevail when the child's apparent peer join is processed
before the lower conditional dependency is discovered. This ruling does not
require predicting dependencies in branches that have not become relevant.

The discussion below is historical evidence; its semantic question is answered.
No implementation fix or new correctness claim accompanies this documentation
update.

## Implemented protocol

- Each node has one committed frame and at most one eligible candidate.
- Writes invalidate subscribers; those outstanding obligations remain when a
  higher update supersedes a candidate. Lower work resumes automatically.
- Peer groups join when a computation consumes both. A child observes its
  ancestors' committed frames. Joined groups carry ancestor relationships.
- Boundary input relationships exist even when an intermediate layer has no
  current update. New lower updates are discovered through these relationships.
- A group publishes when its scopes are closed and all non-retiring obligations
  have ready candidates belonging to that group. Disjoint groups can publish.
- Every participating frame installs before cleanup and observable delivery.
  Retired owned subtrees do not hold replacement publication or deliver callbacks.
- Independent synchronous mounts can publish committed values. Suspended mounts
  are unfinished ordinary work, and pending input proposals may supersede their
  initial calculation. They are not artificial optimistic boundaries.
- Children created during preparation inherit that preparation's reads and
  publication group. Candidate disposal runs actual cleanup callbacks. The old
  committed subtree stays alive until replacement publication.

The model uses real promises. Only the selected candidate can accept an answer;
old physical requests may still run. Initial async mounting can start a request
against committed inputs and then replace it with a request against a proposal.
This cost is recorded, not solved by pretending rejected work never started.

Run:

```sh
node --test experiments/layered-updates/reference/scheduler.test.mjs
node experiments/layered-updates/reference/join-order-search.mjs
```

## Evidence and limits

21 scheduler tests pass. They cover peer joins, disjoint publication, second
proposals, late readers, shared async results, three nested updates, nested and
sibling joins, reversed traversal, dynamic dependencies, missing initial values,
errors/recovery, equal values with ownership replacement, and actual owned-node
creation, replacement and disposal. A finite campaign checks every captured
publication across 300 generated writes in an async diamond. A separate 200-cycle
owned replacement check finds no growing live-node/subscriber/update counts.
These are not heap measurements or a progress proof.

The earlier reference probes add 35 passing tests, but do not expand this
scheduler's capabilities. It scans nodes/groups and traverses boundary inputs;
its cost is unsuitable as a production implementation. No performance or size
acceptance claim follows. Do not port the scans into ordinary signal reads.

Source endpoints can declare `inputs`, and writes can declare `above` inputs.
The scheduler discovers the pending groups through those inputs automatically.
It does NOT yet implement a full optimistic input/override selector, action-owned
override expiry, rebasing, source-owned lazy isPending/latest, or full error
boundaries. Source updates and open scopes are the model's explicit event API.
Stores and production integration remain paused.

## Reevaluation: eager joining leaves a consequential choice

`join-order-search.mjs` exercises a previously unvisited conditional branch:

```js
p = enabled ? delayed(a + b) : 0;
q = delayed(c + b);
```

c is a child of a. All committed values start at zero; enabled starts false.
a=1 is held by independent async work; b=2 is pending too. Then c=10 and
enabled=true are proposed before the scheduler runs. Finish everything except
a's independent work. The exact same event sequence gives these two frames:

| Traversal | a | b | c | enabled | p | q |
| --- | --- | --- | --- | --- | --- | --- |
| p's join discovered first | 0 | 0 | 10 | false | 0 | 10 |
| q's join discovered first | 0 | 2 | 10 | false | 0 | 12 |

Both are coherent according to their published graph. Both eventually reach
1,2,10,true,3,12. In the first, a and b join before c excludes that joined lower
update. In the second, b joins c first; the combined child update excludes a
and the pending enabled update. The still-hidden p branch then remains deferred.
This is about update membership and eligibility, not sibling callback ordering.

**Original classification: unresolved semantic question.** The subsequent user
ruling above resolves it; the traversal-dependent outcome is now a model defect.
It was not a demonstrated tear. A unique intermediate answer would
require specifying how competing joins are chosen, possibly a preparation
ordering rule or tentative joins. It is not justified to add such machinery
without deciding whether this consistency-preserving freedom is acceptable.
Conversely, the fact that both frames are coherent does not establish that
traversal-dependent entanglement is the intended contract.

Comparison with real runtimes is in `../late-join-audit.mjs`, using open optimistic
actions, an initial c=0 override, and separate async holds for a and b. Current
next waits for all guesses; the existing prototype publishes c=10,q=10 with
b=0. Creation-order reversal and adding identity memos on the condition did not
change these real-runtime snapshots. Their scheduling differs from deliberately
reversing the reference model's entire traversal, so this is not evidence that
next would exhibit both choices. The baseline also replaces the initial c=0
override when a changes, unlike the accepted prototype lifetime; that comparison
is not an equivalence oracle. The model omits those action/override lifetimes.

Baseline after all guesses finish also shows enabled=false with p=3; the scalar
prototype keeps that work held until the actions end. These are recorded current
behaviors, not contracts copied into the reference model.

## Other findings, explicitly classified

1. **Model implementation bug corrected:** treating an async mount as a child
   boundary could block a newer ordinary input behind obsolete mount work.
   Suspended mounting now participates in ordinary coordination.
2. **Model representation omission corrected:** ancestry captured only from
   currently pending inputs loses an inactive intermediate boundary. A reduced
   generated case writes x, then grandchild z, then middle child y. Without the
   declared y-input-x relationship, x and z wrongly join before y's update and
   create a cycle. Boundary input ancestry now exists before updates and is
   followed transitively. The retained `ancestry-cycle-audit.mjs` intentionally
   omits that declaration to preserve the diagnostic; it is not a valid declared
   hierarchy that the current scheduler claims to support.
3. **Inherited unsupported pattern, deferred:** creating and immediately reading
   a fresh async owned memo on every retry recreates it forever. A guarded real
   next audit reaches 21 creations without publication, as did the first model
   ownership probe. `../owned-async-read-audit.mjs` preserves the baseline case.
   Ordinary owned render work and synchronous child memos under an async parent
   are tested without weakening their lifecycle/publication assertions. No claim
   is made that the fresh-async-child recreation problem is solved.

Keep the boundary representation and common frames. Before integrating this
scheduler into Solid, implement the accepted join rule and add actual boundary lifetime
and lazy pending-output events. More passing value examples are not sufficient.
