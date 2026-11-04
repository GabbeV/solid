# Fixed rc.20 rebase to ecf30116

Target: `ecf301169c863579a431b9e7cbb3956c01f40072`, from
`5e68925cc2fd216a9fb06345019e66d5da5c523c`. Both declare rc.20. This
checkpoint deliberately stops at that target; newer next commits are a separate
migration. Selected upstream files are verbatim, and the impact record uses the
old pinned inventory rather than the candidate inventory as its baseline.

## Source changes and admitted translations

- `setSignal` captures whether its equality gate is custom, preserves the entry
  current value, queues/stashes an accepted write, and then compares a staged
  rewrite against the live committed value. The custom path retains its captured
  posture across callbacks. Live kind/notified fields are reread at the source
  locations. Proof-only cached-local forms connect through preservation lemmas;
  the runtime is not reordered to preserve an old proof normal form.
- `read`, verdict staging and read-height propagation recognize netted proposals.
  The target's strict-equality signed-zero behavior is retained, including the
  upstream discrepancy reported in #4538. This pin is not silently patched with
  that later fix. Optional-source `stagedScreen` excludes held non-override sources.
- `servesStaged` permits the source first-answer read/reask, with an optional
  served-clock stamp, missed-wake latch and actual pending-source Set deletion.
  Deleting the last element retains the allocated empty Set; absent and allocated
  empty sets are distinct. Effect readers and staged/held errors keep their gates.
- `stageMark` stages the inherited error and nests the actual pending settlement.
  Each nested call has fresh visited/released/scheduled locals. An explicit return
  task restores the outer locals; the nested call schedules and releases before
  it returns. Folded-store-family notification is excluded with the store grammar.
- `asyncWrite` accepts dirty first answers, captures carried staging before its
  own landing mutates the queue, and preserves the stream-continuation synchronous
  flush. An ordinary landing with carried staging rides the already queued flush.
  The shared preparation posture is carried through default and custom setters.
- `joinFuture` tests the raw captured lane before resolving aliases. The installed
  lane engine returns immediately for that marker. This is intentional upstream
  behavior introduced by c8d6fd2c7 / #4477 for #4440; an alias's raw marker need not
  equal its resolved representative's marker.
- Verdict/lane routing includes born-held-frame gates, source-held exclusion and
  the actual `readsHeld` dependency traversal. Pull preparation temporarily clears
  probing/latest, then restores the saved values on the source normal return.
  Transaction latest metadata and node served metadata are explicit record fields.

The new leaf modules `pending-queue` and `staged-answer` share actual source
segments without introducing a second scheduler. Record constructors, generated
witnesses and observation fixtures are migrated to the new fields.

## Proof contract changes

The new raw-lane early return makes an unconditional scheduling conclusion false
for a generic captured transaction. Current/alias contracts now give the exact
conditional result. Ordinary fresh scheduling/resume corollaries explicitly
require the raw capture to be nonlane. Two unrestricted fresh-join laws cover
both branches. Concrete ordinary constructors derive that fact from allocation
and preserved helper histories; they do not acquire a new poststate assumption.
Metadata, arena, observation and live-list frames continue covering both branches.
The root-contract delta is recorded beside the validation receipt.

Pending traversal may now set CONFIG_STAGED_ERROR. Its topology contracts preserve
node kinds, subscriber/link shape and all other configuration bits using the
staged-subscriber observation. Raw topology contracts remain for operations that
preserve every bit. Nested settlement adds four administrative steps to affected
sufficient return bounds (10 to 14, or 12 to 16); exact simple 9/10-step controls
remain exact. These are runtime completion bounds, not independent-checker fuel.

The actual staging tail now rereads kind/notified. General local-preservation
lemmas connect that tail to existing cached-field algebra without restricting
validity, node kind, extension presence or staging. The action-wait construction
imports shared memo input data without importing unrelated full render theorems;
those render theorems remain independently required by the complete book.

## Exclusions and deviations

No semantic workaround is active. Boundaries, stores/projections/folded families,
snapshot/hydration and development/observation hooks retain their documented
exclusions. The new seat.ts shadow is vendored and inventoried as test-only; it is
not claimed as a translated production operation. General mutable protocols,
arbitrary callback/graph histories and global asynchronous publication safety
remain open. Inventory entries and finite comparisons are not equivalence proofs.

## Evidence

The [validation receipt](solid-ecf30116-validation.json) and final checked.json distinguish executable comparisons,
independent kernel verdicts, mutation rejections and historical frozen receipts.
Frontend diagnostics and interrupted/resource-stopped attempts receive no proof
credit. The compiler, independent same-head-congruence-v1 checker, 400M fuel and
4GiB process-group memory bound are unchanged.

### Netted deferred payloads

The old deferred fixed-program witness assumed an unconditional staged-read flag
at its plain-source read. That is false for a netted proposal at this target.
The regenerated path retains the exact conditional final flag and both suffixes;
no initial/proposal pair is excluded. Numeric results remain the proposed value,
using a separate natural equality lemma. For ordinary payloads, the result states
the actual strict-equality slot choice. Opposite signed zeros can retain the
committed sign in the deferred accessor while the source commits the proposal;
this is the known #4538 discrepancy, not a new implementation workaround.

The untrusted witness builder proposes suffixes using the named read-gate cut.
The kernel must prove the actual step50 equation and every step in both suffixes.
This cut is proof-only, not an executable API replacement or an assumed equation.

### Scalar histories and composed read metadata

A scalar write equal to its committed natural value now skips STAGED_READ. The
40-step scalar pass and 95-step two-memo/render programme retain that conditional
bit in their exact final Worlds. Natural equality transports the read payload in
both the return stack and recorded read event; the runtime read is unchanged.
The old unconditional-bit data were rejected, rather than used as an assumption.

Steady scalar histories admit both prior read flags explicitly. Each actual pass
derives its successor flag from its proposal and committed source. The expected
history World carries it through list induction, while the actual run continues
to carry the real World without a canonical reset. Concrete first updates derive
the seed flag. Three generic root domains therefore quantify a prior Bool; no
initial value, equal write, finite history or nonempty batch is excluded.

The second-update family specializes the general steady-pass contracts and seed
trace data. Its actual constructor/first-completion equality remains checked.
Generic flush transport was split from the chain programme to avoid importing
unrelated executions into the scalar proof. These reorganizations preserve the
semantic claims and leave all independent checker limits unchanged.

### Constructed ordinary-body proof cost

The first full independent run stopped at `ordinary-body-constructed.first` on
the existing 400M fuel limit. It receives no proof credit. Constructor method
lookup now specializes a generic expression lemma, and a generic equality bridge
separates actual resume from its prepared-World conversion. The isolated complete
module then passed independently at the unchanged limit. The original first-step
statement and all domains remain unchanged; no runtime operation or assumption
was added. The final whole-book seal is still required.
