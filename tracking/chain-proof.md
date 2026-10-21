# Complete public two-memo/render program

Source profile: Solid d682022c, ordinary production nodes, no active lane,
boundary, store, action or async scope. The actual `Chain.initial` program starts
with a data signal at zero, memo `a = source + 1`, memo `b = a * 2`, and a render
computation reading both `b` and `source`, displaying `b + source`. Both memos use
equals:false. Constructor budgets are fixed at 256. This is a fixed graph family,
not arbitrary graph/history correctness or a TypeScript equivalence proof.

## Proven

- `chain-constructor.bend` proves the actual fixed constructor reaches the
  canonical origin, using existing public constructors.
- `chain-setter.bend` proves the actual public setter reaches the canonical
  staged arena for **every natural proposal**. It checks the two source
  subscriber-notification iterations, heap intake, scheduling and the two actual
  core setter steps; no starting arena is supplied by the caller.
- `chain-staging.bend` proves the actual public flush completes from that staged
  arena for every natural proposal and every budget `95 + extra`. All 95 actual
  core.step transitions and the composed execution pass the original kernel.
- `chain-public-program.bend` composes those boundaries. Four root properties
  cover actual public staging, the complete final World, committed/displayed
  values and exact render applications. Values are `n`, `n + 1`, `(n + 1) * 2`
  and displayed `(n + 1) * 2 + n`. Pending/render/user queues are empty and
  ambient state is restored. The staged-arena precondition remains only on the
  supporting drain lemma, not on the complete public program theorem.
- `chain-observation.bend` identifies the application trace as the initial 2 and
  the final `3n + 2`. There is exactly one updated application, including `n=0`,
  and no intermediate render in this family.
- Two general local publication laws retain default memo staging/notification
  and effect mark/queue/value-store order under explicit field premises.

`tools/chain-witness.mjs` records actual emitted helpers/core.step and replaces
only selected numeric payloads with the symbolic proposal. It is untrusted;
positive formal evidence comes from the original independent kernel, and --check
rejects stale generated data. No runtime algorithm, source branch, kernel fuel
budget or trusted kernel was modified to obtain these results.

## Proof-checker resource boundary

Earlier direct setter equations and generic notification abstractions ran out of
checker fuel or hit external resource caps. Those attempts remain discarded;
they were not counterexamples, useful mutation rejections or established upstream
bugs. The new proof avoids that expensive conversion by proving a single actual
subscriber iteration with **symbolic remaining loop fuel** and its canonical
arena, then composing two such steps at concrete budgets. Small constructor and
flush equality transports keep their return points abstract as well.

The original independent kernel checks the new proof. Earlier diagnostic-only
copies were outside the repository and are not part of its trust foundation.
No semantic deviation is active. The runtime is unchanged by this milestone.
The complete single-memo theorem for all natural initial/proposed values remains
checked separately.

## Remaining scope

Arbitrary initial values for this larger graph, repeated-update symbolic
histories, arbitrary graph topology, malformed arenas, active scope engines and
JavaScript numeric/TypeScript equivalence remain outside these theorems.

## Finite correspondence controls

Eight controls compare actual public constructors/setters, complete canonical
Worlds, traces, values and render applications with pinned native Solid,
including equal writes and large natural proposals. They support correspondence
separately from the quantified program proof. The existing 80 finite memo
controls remain separate as well.

Two compiled variants discard the staged publication payload or drop the
multiplication's second operand. The finite native/canonical controls reject
both. An initial proof-property negative trial of the first variant was killed
for resource use and excluded. Negative proof subprocesses have external RSS,
time and output limits; such stops are Errors and never count as assertion
rejections. `tests/proof-process.mjs` distinguishes success, ordinary rejection,
missing executable and timeout/output/RSS stops. Positive proofs use the original
kernel.
