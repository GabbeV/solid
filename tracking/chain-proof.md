# Two memos and a render: checked drain, open setter bridge

Source profile: Solid d682022c, ordinary production nodes, no active lane,
boundary, store, action or async scope. The graph starts with a data signal at
zero, memo `a = source + 1`, memo `b = a * 2`, and a render computation reading
both `b` and `source`, displaying `b + source`. Both memos use equals:false.
This is a fixed graph family, not arbitrary graph/history correctness.

## Proven

- `chain-staging.bend` proves the actual public flush completes from the exact
  staged arena in `chain-states.bend` for every natural proposal and every budget
  `95 + extra`. All 95 actual core.step transitions and the composed execution
  pass the original independent kernel. The complete final World is identified,
  with committed values `n`, `n + 1`, `(n + 1) * 2`, displayed value
  `(n + 1) * 2 + n`, empty pending/render/user queues and restored ambient state.
- `chain-observation.bend` proves the exact render-application values are the
  initial 2 and the final proposal. There is one updated application, including
  an equal-value write, and no intermediate displayed proposal in this family.
- `chain-constructor.bend` proves the actual fixed constructor program reaches
  the canonical origin. It uses the existing public constructors and fixed
  construction budgets. It is a supporting closed boundary lemma, not an
  additional arbitrary-initial-value result.
- Two general local publication laws connect the actual default publication
  helper to memo staging/notification and effect mark/queue/value-store order.
  They quantify arbitrary admitted state/payloads under explicit field premises;
  they are not progress theorems for malformed or arbitrary graphs.

`tools/chain-witness.mjs` records actual emitted helpers/core.step and replaces
only selected numeric payloads with the symbolic proposal. It is untrusted;
positive formal evidence comes from the original independent kernel, and --check
rejects stale generated data. No runtime algorithm, source branch, kernel fuel
budget or trusted kernel was modified to obtain the result. Diagnostic-only
copies were used outside the repository to locate expensive conversion steps;
the promoted proof uses the unchanged toolchain.

## Still open

The public setter-to-staged-arena bridge is **not proved** for this larger graph.
Its two subscribers are the first memo and the render that also reads the source
directly. The remaining expensive conversion is `write.insertSubs` / its two
`insert_subs` iterations. Complete constructor/setter/flush equations were not
promoted, and the checked drain retains its staged-arena precondition.

Bounded scratch trials of the full setter bridge, a generic one-iteration lemma
and the first concrete notification equation did not obtain a positive verdict:
they reached the original checker's fuel limit or the external memory/time cap.
These are discarded proof attempts, not counterexamples, useful mutation
rejections or established upstream bugs. No semantic deviation is active. The
runtime is unchanged by this milestone. The complete single-memo theorem for all
natural initial/proposed values remains checked independently.

## Finite correspondence controls

Eight separate controls compare actual public constructors/setters, complete
canonical Worlds, traces, values and render applications with pinned native Solid,
including zero/equal writes and large natural proposals. They pass and support
source correspondence. They do not establish the missing quantified setter
bridge or turn this conditional theorem into a complete public program proof.
The existing 80 finite memo controls remain separate as well.

Two new compiled variants discard the staged publication payload or drop the
multiplication's second operand. The native/canonical controls reject both. An
initial proof-property negative trial of the first variant was killed for resource
use and excluded. Negative proof subprocesses now have an external process-group
RSS cap in addition to time/output limits; such stops are Errors and never count
as assertion rejections. `tests/proof-process.mjs` checks success, ordinary
rejection, missing executable and timeout/output/RSS stops separately. Positive
proofs still use the original kernel.
