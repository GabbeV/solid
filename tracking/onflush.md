# onFlush: source operation, host boundary and registration contracts

The production source at next@1d6c40fb is two operations in order: schedule(), then
queueMicrotask(callback). `runtime/on-flush.bend:register` uses the same schedule
helper and appends a MicrotaskCallback to the existing host outbox. The host
queues it in that order and invokes the body through the common evaluator when
its microtask runs. Registration creates no reactive node and does not capture an
owner. The callback's return is ignored. Ordinary host exceptions are observed
by the adapter without inventing a reactivity halt or effect cleanup policy.

The expression/API/host entries share this one operation. The new expression is
included in ordinary callback, action-argument and lexical-signal binding walks;
those captures precede enqueueing. The callback body is an admitted zero-argument
closure represented by Expr. Arbitrary JS closure/reflection semantics and dev
ON_FLUSH_IN_OWNED_SCOPE diagnostics remain outside this production profile.

## Checked registration properties

`onflush-registration.bend` proves a frame over arbitrary finite synchronous
registration lists and arbitrary Worlds: every field except scheduled,
haltNotified, reports and hostJobs is retained. This includes all node data,
committed tree/trace, owners, ambient tracking, actions, waits, flights and
transaction accounting. The four excluded fields are exactly scheduling's
existing request/report changes and the new queue submission. Separate content
and ledger corollaries are also checked.

For a nonempty list beginning from the canonical idle/unhalted/outside-sync-depth
ambient fields, the full final World is exactly the scheduled World with one
initial FlushJob followed by one MicrotaskCallback per body in call order.
Existing outbox jobs remain ahead of those additions. The base World's other
fields and every body are arbitrary. This initial constructor fixes scheduler
posture; it does not assume the final queue/World. The tail induction uses actual
registration calls, establishes that later registrations add no extra flush job,
and retains all other state exactly. An empty list performs no registration.

`onflush-source-control.bend` connects the actual evaluator branch to registration,
its unchanged continuation/stack and undefined return, before body execution.
Three composed roots extend646 to649 without narrowing older domains.

These are registration safety/order contracts. They do not prove arbitrary
callback termination, browser delivery fairness, successful draining or global
action/flight publication. An unrelated write made in the callback can publish
independently, while overlapping computations/user effects can join a hold;
render readers have their own source posture. The port preserves those rules.

## Native and adverse evidence

22 public programs match real Solid: deferred registration, callback order and
batching, nested/manual/flush(fn) cases, tracked-effect entry, disposal, owner
context, all three binding paths, ignored returned function data, callback throws
and writes before throws, and pending route updates with independent, memo,
user-effect and render readers. They check observations at each stage and include
explicit expected outcomes, not just agreement. A first sequence-only overlap
fixture returned only the page value; its presumed hold was not an appropriate
oracle. The replacement result actually depends on both inputs. Source and Bend
agree. No upstream bug is claimed from that fixture correction.

The positive compact kernel oracle passes. Four compiled kernel variants reject
missing scheduling, reversed outbox order, a spurious callback and starting the
body in the evaluator. Three compiled finite variants reject lost ordinary,
action and lexical captures. A first duplicate-body variant failed the linear
usage checker and receives no rejection credit; it was replaced by a compiling
extra-callback corruption. All695 mutation anchors are current. The older lane
loading mutation is retargeted to its moved laneReadOutside segment and rejected.
A full current695 sweep remains separate from these focused checks.

The 646-root repin's public test command completed as an interrupted prefix plus
an exact resumed suffix; source alignment passed. Those logs remain separate.
The API additionally reruns relevant existing callback/argument/local/action
programs. Runtime and reference are rebuilt before using the new expression ABI.
No semantic workaround or source pin change is introduced by this API addition.
