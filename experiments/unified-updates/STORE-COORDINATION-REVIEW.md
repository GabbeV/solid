# Store coordination follow-up — 2026-11-12

Follow-up ruling, 2026-11-13: initial writes should discard but entangle; immediate
discard allowing early input publication is rejected. The unresolved-producer
pending rule is now aligned with next. See STORE-ARRAY-ENTANGLEMENT.md for the
implementation status and a more precise audit of next's actual whole-action
array joins versus retained snapshots.

Runtime remains unchanged at the prior checkpoint. This records exploration,
not an implemented coordination policy or new user approval.

## User rulings

- Preserving a complete array behind a partial optimistic store edit is rejected.
  It implicitly vouches for unguessed properties. Scalar whole-value optimism is
  not justification: its call site explicitly chooses the whole value.
- Explore entangling incoming structural conflicts and whether rederivations
  require a broader rule. Arbitrary setter replay/rebasing is out of scope.
- The nested seed setter issue was filed as #4808. Leave the experiment's behavior
  as is for now. Upstream subsequently merged #4810; this investigation does not
  port it or rebase the runtime.
- Determine why next retains parent-reference pending, including intent evidence.
- Consider dropping unpublished initial guesses. The user's #4810 comparison is
  evidence for this direction, not blanket approval of every initial-write policy.

## Array coordination findings

Compared experiment 502b337f2 with next dfb18120a and actual latest next
edeb5db09f86d1fd558567069cbba6f489a13cbe. All 36 recorded structural timelines are
unchanged between those two upstream revisions. These recording probes inspect
render-effect publications; they do not assert that existing behavior is correct.

1. Next joins direct index guesses with incoming array changes even when length
   and index presence are unchanged: input [A,B], guess index1=M, incoming [X,B].
   Both actions' ordinary saved flags remain held until both bodies finish.
2. Next keeps nested row-field edits granular: guessing rows[1].value does not
   have the same effect as replacing rows[1]. Comparable disjoint object-property
   input changes also remain independent. No evidence here requires blanket
   store-family entanglement.
3. Checking only an incoming array for holes is insufficient. Starting [A,B], A
   guesses index1=M and B guesses index0=N. Incoming [] produces [N,M] in the
   experiment, but B finishing then produces [hole,M]. Next holds the input until
   both guesses finish. Structural support can disappear when a guess expires.
4. Next's current joining is reader-driven. With no output subscriber it permits
   the input to commit; later mounting cannot undo that publication. A chained
   optimistic array also lets input [] publish while retaining [A,M] outside.
   Therefore copying the observed-next seam hook is not a robust intrinsic rule
   satisfying the user's requirement across mounting and nested boundaries.

Proposed first trial: coordinate changed incoming array input with all live direct
index/arrangement override owners on that array, including guesses that did not
originally change length. Keep nested row-field edits and unrelated object-key
edits granular. This deliberately also delays the same-shape [X,B] update above.
It needs publication-time protection independent of mounted consumers, including
chained inputs. No size or implementation-completeness claim is made for it.

A narrower rule would track which underlying positions/membership each surviving
guess relies on, including support supplied by other guesses and its withdrawal.
Length-only checks miss holes; key-count checks miss membership/order; raw object
identity checks overconstrain keyed rows. This is more than a landing shape check.
Equal/same-question refresh behavior and pre-answer writes remain distinct cases;
do not silently broaden the scalar input/output lifetime rule.

## Parent-reference pending: actual cause

The experiment's optimistic-static.ts descendant bypass (line 162 at checkpoint)
returns the parent property without pulling the unfinished store producer whenever
a descendant has a live override. It drops the pending producer dependency and
makes the parent input/output appear settled. Proxy identity is not itself the
reason pending becomes false.

The bypass executes in both ambient and open-action cases. In both it computes a
false pending proposal. The open action's context selects the previously committed
true boolean instead, hiding the difference. Separate parent-only status effects
confirm this is not an artifact of combining all status queries in one effect.

Next explicitly preserves the producer read during a pending query. A9 and A22
explain the distinction: a known plain-store write has a known changed-key set;
an unresolved derived store answer has an unknown changed-key set. A24 says an
optimistic write does not silence that new-question pending. Deep remains useful
for descendant work when the producer itself is settled.

The divergence was intentionally added to the experiment in ec3ae1c98 and called
a choice for review in STORE-OVERNIGHT-DECISIONS.md, not approved upstream behavior.
A scratch ablation removing that one bypass restores true AND keeps guessed99
published in four ambient/action controls, repeated with independent status effects.
Recommendation: restore the producer dependency, then run the affected parent/
child suites before treating the one-line ablation as a complete fix. No main
runtime edit has been made.

## Initial guesses: joining versus dropping

Default initial loading, seed [], push M, first answer [A,B]:

| Policy | Answer ready while action stays open | Once action ends |
| --- | --- | --- |
| Current experiment | [M,B] | [A,B] |
| Latest next production | [M] | [A,B] |
| Scratch joined-input trial | Still loading | [A,B] |
| Proposed discarded guess | [A,B] immediately | [A,B] |

Joining works in the isolated trial, but requires holding the actual initial input
node in the update, not merely merging the pending render's transaction. The latter
still reveals the guess. Action-first order also publishes only [A,B]. Setter
callback executes once; raw-promise action results remain independent of publication.
An action awaiting its own committed render creates a circular wait, as expected.
These are explicit harness interventions, not integrated production mechanics.

Dropping the unpublished guess is the simpler candidate if the first answer should
publish without waiting for the unrelated guessing action. Execute the callback
once; do not retain an optimistic override from those initial writes. This is a
proposed optimistic-store policy, not already what next does. Explicit
seedLoadingValue:true is separate: [] is commit #0 and [M] can already be visible.

Latest next still rejects default pre-answer optimistic writes in development
before invoking the callback, and still shows [M] in production if the answer beats
the action end. Eight baseline comparisons on edeb confirm #4810 did not change it.

## #4810 and other new upstream changes

#4810 merged as edeb5db09. Its actual ordinary nested write runs the callback,
drops only the write through the unanswered chained child, permits other writes
in that setter, and keeps following the child. Production matches without the dev
warning. A whole-child replacement remains supported. It adds no entanglement.
Both upstream assertion tests pass in the independently pinned latest checkout.
This supports the direction of discarding unusable initial writes but is narrower
than the proposed optimistic-store rule above.

#4793/#4802/#4803 have now merged. #4814 (38b6f850d) additionally disables borrowed
key fallthrough when a guess changes key presence or length. It fixes an existing
structural guess's retention, not incoming-input coordination; its regression test
passes. None of the 36 structural comparisons changed on actual latest next.

## Receipts

The store-coordination-review checkpoint archive preserves the structural matrix,
exact next comparison, pending ablations/traces and scratch source, initial-load
trial matrices, and independent #4810 assertion test. Source paths and commands
are in each investigation's README/REPORT. No full-suite acceptance or new
performance claim follows from this investigation.
