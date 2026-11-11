# Store integration — implementation resumed

Entry: `743bfbd11`. Performance and size investigations are paused. The goal is
the complete upstream API and test surface except `until`: remaining tests must
pass or be explicitly migrated under the user's rulings. An old test is evidence
of behavior, not permission to preserve inconsistent publication. Semantic
decisions stay with the user.

## Verified inventory

| Suite receipt | Optimistic-store constructor rejection | Until-dependent | Other observed failures |
| --- | ---: | ---: | ---: |
| Signals | 1,861 | 92 | 0 |
| Solid | 23 | 0 | 0 |
| Web | 115 | 0 | 0 |

These are entry failures, not a forecast of failures after integration. The
constructor rejection masks the rest of each test. Some constructor failures
also later depend on `until`. Mixed files contain substantial passing ordinary
store/observation coverage and must not be excluded wholesale. The accepted
signals receipt is the final optimization trial; Solid/web receipts are the
previous full runs. Inspect helpers as well as error messages when classifying.

## Work sequence

1. Integrate per-property optimistic outputs with the scalar proposal, holding,
   context and publication machinery. Retain store-owned input slots.
2. Extend presence, descriptors, container membership, arrays/length/holes and
   deep reads. A coherent setter publication must not rely on consumers
   accidentally reading all changed properties together.
3. Integrate input projections, async/error forwarding, own-input holds,
   refresh, nested/chained stores and observation outputs.
4. Integrate keyed reconciliation, row identity and structural override
   policies. Compare next and accepted scalar rules before choosing behavior.
5. Run the complete suites and classify every remaining case individually.
   Replace helper-only uses of `until` only where an equivalent setup preserves
   the behavior actually under test; genuinely `until`-dependent cases remain
   explicitly deferred. Never weaken consistency assertions.

Each implementation slice must use the real source/public API and ordinary
test harness. No new standalone reactive model or legacy-lane reactivation.
Temporary unsupported surfaces are milestones, not additional final exclusions.

## First candidate (not integrated)

An isolated candidate at `/workspace/scratch/unified-store-slots` implements
static flat plain records with existing primitive data properties. Input slots
stay in the store; source-owned output companions reuse scalar selection and
action-lifetime machinery. Function and Promise property values stay raw.
Setters validate an isolated draft before submitting proposals, so rejected
structural changes do not partly apply. Remaining shapes reject explicitly.

The initial selection passes 20 new/scalar controls and three unchanged flat
store scope controls. This is a limited implementation milestone, not complete
store support. Full source and patch receipts are preserved separately; the
main runtime remains at the entry while the first semantic decision is pending.

An additional primary-requested adversary fails in this candidate: one setter
changes both `a` and `b`, but an async consequence of `a` holds only `a`; `b`
publishes early. Separate scheduled bindings establish this without an
accidentally coordinating combined reader. Both next revisions and the ordinary
store control hold both properties. The candidate therefore needs explicit
writer-publication grouping before integration. This is an implementation gap,
not an intentional semantic change or a defect in the current main runtime.

A subsequent isolated candidate at `/workspace/scratch/unified-store-groups`
adds that grouping using the existing output transactions, without merging
independent action lifetimes. It passes 25 targeted cases, three unchanged
flat-store controls and two standalone publication controls. It remains
unintegrated; these results do not establish complete store support.

Primary review corrected an ownership assumption: static stores in next survive
disposal of their creator and first reader. A direct next probe verifies that;
output companions therefore must not inherit either reader's lifetime.

Open implementation review: enumeration must preserve the presence/key-set
tracking contract while descriptors report selected values. `Object.keys` and
`Object.getOwnPropertyDescriptors` use the same proxy-trap sequence. Untracked
reads suppress subscriptions but still discover calculation context. The
candidate currently preserves selected descriptor values; this needs further
contract/behavior validation before acceptance.

A same-tick multi-action probe matches the scalar runtime too. Its proposed
independence expectation is unestablished; ordinary batching is a plausible
explanation. It is **not** a diagnosed existing runtime bug.

## First semantic decision: deep observation and override lifetime

Two actions separately guess existing properties `a = 1` and `b = 2`. Their
guesses have both published. A's request finishes while B's remains open.

On both next `4fe75321` and `bcef1041`:

| Readers | After A finishes |
| --- | --- |
| Ordinary reads of `store.a` and `store.b` | `0 / 2` |
| Same readers plus a `deep(store)` display | `1 / 2` |
| Scalar optimistic equivalents plus a combined memo/display | `0 / 2` |

A's returned action promise has completed in both store cases. The additional
deep display keeps A's override selected until B finishes. The store engine
writes each mutation to the same deep-notification slot; once that slot exists,
the actions also overlap there. The scalar counterpart has no such additional
guessed source.

Clean comparison tests use only scheduled publications, separate user events,
controlled request gates and a real timer turn. They contain no `latest`,
untracked diagnostic reads, snapshots, `until`, or manual microtask loops.
Both next revisions pass the two store cases and scalar control; the current
experiment passes the scalar control. No repository expectations were changed.

The follow-up investigation confirms that the witness merges the underlying
action transactions, not merely override lifetimes: ordinary signal writes in
A also wait for B. The additional executable control passes on both next pins.

History does not establish an explicit deep-specific maintainer decision.
The witness was introduced as a notification optimization in #3019, and was
already armed as an optimistic source before the L2 rewrite (#3774). The
behavior must not be called a new L2 regression. #2899/#2912 and D-33 explicitly
preserve disjoint-key ownership and distinguish shared readers from shared
writes, but do not classify the synthetic deep witness. Older store-wide
entanglement statements predate those per-key rules.

Revised recommendation after the user's requested cost review: preserve next
initially to limit scope. Reusing the existing witness with an action-owner
association can use ordinary scope merging; it need not add a full computed
node or a parallel coordination system. It still needs ambient-scope handoff
and witness retention until its owner settles. This is a source-level design,
not an implemented or measured size win. Independence omits those policy hooks,
but both choices still need complete deep invalidation and coherent snapshots.
No clear total size advantage has been established that warrants overruling
next on implementation cost alone. Revisit with the user if integration makes
preserving this behavior materially more complex. Neither behavior has yet
been integrated into main.

## Other findings, not additional rulings

Next's keyed ordinary memo can calculate an incoming input while its render
callback stays held. That alone is not visible tearing. `latest` can genuinely
publish that hidden input; the accepted scalar latest rule differs and must be
applied deliberately to store outputs.

Keyed arrangement rebasing depends on whether a new question or a quiet refresh
was already pending when the guess was made. It needs a separate review when
that surface is implemented. Unkeyed behavior differs between the two next
pins; do not infer a requirement from the older implementation's residue.

Ordinary single-setter/same-flush multi-property updates hold together when an
observed async consequence suspends. Separate-flush updates may publish
independently. Matched ordinary controls agree between next and the experiment.

## Evidence

The `store-integration-start-20261111.tar.xz` checkpoint restores
`results/store-integration-start/`: exact per-test inventory, API/source audit,
next comparison programs and results, and the frozen candidate's complete patch,
source files and targeted test receipts. Candidate findings must not be described
as defects in the integrated main runtime, where optimistic stores still reject.
