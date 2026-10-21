# Reaction source review

Pin: Solid 0222d684, production. `signals.ts:createReaction` now executes through
the ordinary effect constructor, core driver and owner continuations. It adds no
alternative scheduler, reaction graph or subscription replacement algorithm.

The ReactionState arena represents the source closure's `cl`, `owner` and `arm`
cells plus its captured callback/options. Construction initializes cl, registers
a cleanup closing over the live cell, then captures the current owner. The
returned original track function is an existing ProgramReference whose one action
enters the source track body. It uses the same callable codec as named functions;
there is no new function-value kind with incomplete equality or updater handling.
The lifecycle closure and track closure have distinct identities. Neither creates
a reactive node until track is called.

Track captures the old arm, disposes it through owner.ts:dispose, and clears the
cell only after successful disposal. It then enters the captured owner and calls
the existing effect constructor with user and defer set true, overriding those
options exactly as source does. The compute wrapper captures getOwner(), assigns
arm before tracking, ignores tracking's return, then returns the captured node.
A pending/error read therefore leaves arm available for later replacement.
The fire wrapper clears arm before invoking the previous cl. It leaves cl installed
until the reaction callback returns successfully, then stores that exact value and
disposes the firing node. A throw skips later assignments/disposal. Re-arming from
the callback is retained. Bundle errors use the existing user-effect error arm;
that arm's previous-cleanup helper addresses the effect node's cleanup, not cl.

The 66 expression-ABI histories cover ownerless/owned construction, schedule/sync
options, normal and already-queued replacement, re-arming, callback cleanup types,
pending/loading/rejection, error bundles and helper arguments, thrown callbacks or
cleanups, zero-dependency reruns, owner capture, returned callable identity and the
pending-replacement source bug described below. Complete arm states, ordered edges,
owner/child/sibling links and root cleanup counts are compared with actual Solid.
Expression compute/read and user cleanup traces are compared. Internal application
markers are omitted: native createReaction does not expose its internal effect
callback as an observation point. For direct getter cleanup, the established read
observer limit also applies. No private source callback slot is replaced to create
an observation hook.

Twelve additional histories call the original native returned tracker with an
original native getter or named function, including a tracking function returning
another function as ignored data. Source trackers/getters remain unwrapped. These
compare returns, stable identities, complete arm state, ordered dependencies and
cleanup emits. They omit compute/read/application traces because those direct
calls bypass the expression observer. After actual calls, nodes receive labels
by reading the captured owner's first child; labels make no reactive decision.

Five compiled mutations target lost old-arm disposal, premature cl clearing,
partial rather than full disposal, wrong captured owner and missing initial defer.
Three positive concrete laws cover replacement/cleanup and seeded/unseeded pending
replacement after merged #4188. The former negative law remains at c11277e. Two additional general binding laws
cover reaction callback and tracking-expression capture. These are not general
reactive graph theorems or a machine-checked equivalence proof.

## Integrated upstream pending-arm fix

At the earlier pin, assigning after tracking meant a missing async read threw
before arm was assigned. Re-arming could not dispose the obsolete subscription.
Merged #4188 captures the current effect node, assigns arm, runs tracking, then
returns that captured node. The translation preserves this order through
ReactionReturn, including pending/error unwinding and reentrant changes to arm.
The original pending repro now reports 0 then 1 calls, with the seeded control
unchanged. Both positive closed laws pass; the old negative is retained at c11277e.
See [the original report](upstream/reaction-pending-rearm.md).

Arbitrary JavaScript closures, dev/observe validation in Bend, installed boundary,
lane/mark hooks, stores and broad graph invariants remain outside this profile.
