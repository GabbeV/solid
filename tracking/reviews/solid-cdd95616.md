# Solid next cdd95616 integration review

Source cdd95616857ef1d54f3e2ec88a87ba6ca40de765, still declaring rc.17, follows
aece1d44 by two commits: #4219 changes examples/router versions; #4217 changes
the signals landing barrier and performs related core size refactors.
All 77 recorded Solid inputs are compared byte for byte with Git at the new
commit. Ten vendored files change: six core source modules and four documents.
The Bend toolchain stays at 2.0.37. The semantic deviation register stays empty.

## Changed operations

scheduler.reruns now returns the first truthy effect type among live non-error
frame/verdict readers it actually re-derives. The type is captured before
clearing flags/modified children and enqueueing, retaining source order.
The Bend reruns/rerunsLoop helpers return World plus this local value; zero
represents the source's absent/falsy frame, render=1 and user=2. Lane seam callers
ignore the value as the source does. Mainline land carries it through its node
commits, clears flushTransaction at the original point, and either releases
queues immediately or appends one callback to global queue index 1 (the user
effect phase). That callback later calls the actual releaseQueues. It neither
schedules separately nor runs eagerly at registration. QueueEntry.ReleaseQueues
stores its captured transaction identity; no new World field or alternate
scheduler was added.

The callback releases held runs for the re-derivation's next round. If that pass
finds another flight, its round parks together with those runs. The held node
commits are not postponed. Eight public histories exercise native/immediate
promises, direct/derived readers and supersession/no-supersession controls,
checking full fields/traces and the application screen. The preceding runtime
fails against the new reference; against the old reference the explicit rule
fails too: gate=true while the panel is still hidden. The rebased runtime keeps
gate=false until the new flight resolves, then reveals both. This is the #4071 /
#4217 fix, not a new defect found in Solid.

The new queued-callback theorem covers arbitrary healthy typed Worlds,
transaction IDs, remaining tasks and value stacks: one actual core.step executes
releaseQueues and preserves that continuation/stack exactly. It supplements the
existing program proofs; it does not prove arbitrary async graphs.

async.notifyStatus/propagateStatus drop blockStatus and its forwarding branches.
No production caller supplied it. Bend task records and callers drop the same
argument, and notifyEffectStatus reads its own node status/error. Obsolete
blocked-forward synthetic cases are retired, leaving 3,072 status and 2,304
pending controls; pending tests retain their independent throwing-cleanup cases.
No formal theorem domain or public comparison family is removed. The private
status oracle now compiles copied mutated source when requested, so it can test
its new notifier/escalation mutants rather than accidentally checking baseline.

The three effect error sites use the new shared escalate helper; the callback
error path captures the effect ID before restoring the caller's ambient ID.
The admitted production root boundary-or-halt behavior is retained. Active error
boundary hooks, dev diagnostics and observability remain explicit exclusions.

handleAsync's unresolved promise uses the shared not-landed tail. Bend
flight.liveValue now supplies that same loading/suspension/landing segment to
thenValue and afterIterator, preserving field writes, NotReady allocation and
original Finish/catch continuations. The redundant blocked null check was
already represented by the field-presence-safe branch. NewSet is the exact Set
constructor under a binding; the existing ordered membership representation
needs no new algorithm. File-level imports and initialization are reviewed in
addition to named-function fingerprints.

## Validation and remaining scope

The existing public suite (3,572 histories), eight new barrier histories, 32 multiple-deferred histories,
complete private alignment suite, all preceding kernel properties and the new
callback property pass on the isolated integration. All old quantified payload
and finite-history domains and sufficient step budgets remain unchanged,
including the deferred 103-step family. There is no proof of TS/Bend equivalence.

Unmodified native signals source passes all three JavaScript build tiers, source
declaration generation and its full suite: 336 files / 5,502 tests, two expected
failures and two skips. A preliminary suite overlapped the build and saw missing
artifacts; it is excluded. The clean complete suite was run after building.

All three new upstream repros and passing controls still reproduce on the new
source build: buffered from/deferred p.then, synchronous unsubscribe throws, and
ordinary deferred errors waiting for an obsolete flight. Their candidate patches
stay isolated and unfiled. The admitted deferred error case stays at baseline.
Streams/from/store/boundary/snapshot profiles remain unfinished. See the
validation JSON for byte receipts and native repro results; final mutation and
sealed-input results are recorded there once the complete runs finish.
