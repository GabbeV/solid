# Deferred data proof over ordinary represented payloads

This checkpoint generalizes the existing complete data program without changing
any runtime, representation, host adapter, source pin, compiler or kernel file.
The old numeric theorem and its sufficient budget remain intact.

## Quantified domain

`proof/ordinary-payload.bend` is a proof-only classification of existing
`R.Value` constructors. Each initial and proposed value independently ranges over:

- undefined and null;
- either boolean;
- any natural-number payload;
- negative zero and NaN;
- any represented string;
- an opaque object reference with any natural identity.

Contents and identities are variables, not enumerated fixtures. Mixed types,
equal and unequal references, successful undefined values, empty strings, NaN and
negative zero are included. The proof uses the actual value constructors; it does
not replace the runtime with a provenance evaluator or encode all values as numbers.
Natural fields in `DataNatural` and `DataReference` respectively represent the
existing numeric payload and opaque identity. No object contents are inspected.

This admitted domain is deliberately explicit. Negative and fractional numbers,
bigints, symbols and arbitrary JavaScript objects with protocols are not thereby
represented. Callables and asynchronous protocol objects take distinct source
branches and require separate theorems. Arena-dependent array/internal handles
and internal tokens are excluded. This is not a claim about every JavaScript value.

## Complete program and guarantee

`proof/deferred-payload-driver.bend` uses the existing public Expr program:
create an owned source signal and deferred accessor, leave the owner, perform an
event-style source write, flush, and read the deferred accessor. Source and
accessor both use `equals:false`. The graph shape and event order are fixed.

The independent kernel checks all 103 actual `Core.step` transitions and proves,
for every admitted initial/proposal pair and every extra natural budget:

- `Core.run(103 + extra, before(initial, next))` equals the exact final Machine,
  including its complete World, empty task list and value stack;
- the returned value is exactly `Payload.value(next)`;
- choosing natural payloads gives exactly the original numeric initial Machine.

The last bridge establishes that this is an extension of the same program.
The old numeric theorem remains registered. No closed regression is added to the
73-count concrete regression total just for widening a theorem's domain.

`tools/deferred-witness.mjs --payload` builds untrusted canonical states from the
actual driver. The independent kernel verifies their universal step equations;
the generator and sample run are not trusted proof engines. Six proof-only case
splits discharge actual initializer/updater overload and async classification
branches. They add no runtime task or step. Existing setter/heap equations are
reused with symbolic ordinary payloads. Deterministic regeneration is checked by
`npm run check`, alongside the unchanged default numeric generator.

This does not prove arbitrary graphs, arbitrary derivation functions, default
comparator policy, disposal or overlapping async histories. A future arbitrary
function theorem will need assumptions describing the function's semantics and
purity. No numeric assumption has silently been advertised as such a theorem.

## Independent controls and negative experiments

`tests/deferred-payload-controls.mjs` compares 196 mixed programs against native
source-built Solid and compares every canonical prefix against the actual Bend
runtime. Fourteen representatives exercise undefined, null, both booleans, three
naturals, negative zero, NaN, three strings and two opaque object identities.
Exact final Machines are also compared at budgets 103/104/128. These finite
controls supplement the universal proof; they are not new public-history counts.

Two isolated, compiled negative variants corrupt only empty strings or opaque
object references in the actual deferred return continuation. The original
universal numeric proof must still pass before the broader proof is allowed to
reject each variant. This checks that the stronger domain matters. Runtime
compilation, proof resource failures and failed numeric preconditions earn no
rejection credit. See `tracking/deferred-payload-validation.json` for receipts.

The pre-existing complete 519-variant receipt remains applicable to the identical
runtime/source. Only these two additional variants are run at this checkpoint;
there is no claim of a fresh complete 521-variant run.
