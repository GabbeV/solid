# Stage 42: direct ordering of scalar layers

## Accepted crossed-child rule

For c over a, d over b, p=c+b and q=d+a, both child overrides can publish using
committed parent values even without any memo entangling a and b. With pending
a=1,b=2, then guesses c=10,d=20, finishing child work while holding parent work
must permit a=0,b=0,c=10,d=20,p=10,q=20. The user explicitly approved this.

## Implementation experiment

`layer-order-scheduler.mjs` implements a deliberately simple fixed-position
hypothesis: ordinary inputs start at position zero; an optimistic output is one
position above its declared input; derivations carry the highest position of
the inputs they combine. These are derived positions, not user-assigned numeric
priorities. Whether this suffices for dynamic layered graphs remains unproved.

Publication still uses the same committed/candidate frame and the same one-job
supersession mechanism. Updates at a shared position join when they meet.
A higher update uses committed lower values. Initially suspended mounting has
no competing position and can adopt the producing update's context.

This removes the provisional join history, origin reconstruction, ancestry
replay, fresh/deferred discovery passes and associated context receipts from
the revisable model. There are 317 lines in this reference scheduler versus
453 in the revisable version at this checkpoint. This is a raw research-code
comparison, NOT a shipped bundle-size result or production acceptance evidence.

Tests:

```sh
LAYER_ORDER=1 node --test experiments/unified-updates/reference/scheduler*.test.mjs experiments/unified-updates/reference/layer-order-scheduler.test.mjs
LAYER_ORDER=1 node --test experiments/unified-updates/reference/*.test.mjs
```

28 relevant operational tests pass, including both crossed-child traversal
orders, both parent representations, the earlier join/permutation cases, real
async supersession, scopes, errors, owned children and the finite async-diamond
campaign. The complete reference command reports 73 passing tests, but that also
runs older snapshot/protocol probes and tests explicitly tied to the revisable
implementation; it is not 73 independent validations of this new scheduler.

The original model still omits full input/override selection, override expiry,
lazy pending/latest, store operations and complete ambient read contexts.
Production code and its performance/size acceptance status are unchanged.

## Falsification: inactive input boundaries

Counting declared wrappers gives an unused boundary semantic weight:

```js
const [source] = createSignal(0);
const [a] = createOptimistic(source); // Never overridden.
const [b, guessB] = createOptimistic(source);
const [c, guessC] = createOptimistic(a);
const holdB = createMemo(() => delayB(b()));
const q = createMemo(() => delayQ(c() + b()));
```

Keep the guessing actions open. Propose b=2, then c=10. Finish q's work but keep
holdB unfinished. Count declared boundaries and c is position 2 while b is 1:
the model publishes c=10,q=10 with b=0. Replace c's input a with source, and c
becomes a peer of b: both remain held. The unused wrapper changes publication.

Measured next and existing-prototype results are the same with either input:
a=0,b=0,c=0,q=0 until holdB finishes, then b=2,c=10,q=12. The production audit is
`../inactive-parent-layer-audit.mjs`; the model audit is
`inactive-parent-layer-model.mjs`. Exact outputs are under
`../results/reference-stage42/`.

**Resolved by the user in stage 43:** an optimistic boundary must be completely
transparent whenever it has no active override, including after an override
expires. The fixed-declaration hypothesis is rejected. Context must account for
selected input/override state, and changes to that state must be tested before
choosing a representation. See [the active selector experiment](COORDINATION-43.md).
Do not treat fixed numeric positions as a general solution on the strength of
the passing static-layer tests.

## Other limits exposed by this experiment

The previous endpoint-equivalence fixture added an inactive base beneath a and b
but left its ordinary conditional flag at the original base. Under a positional
model, that changes the flag's relation to a/b. The delayed-condition timeline
then differs even though every published frame remains coherent. This has not
been silently relabeled as an accepted semantic change or had its old assertions
weakened: the old test remains with its original model. Explicit ordinary updates
within a layer, and the interaction between conditional discovery and ambient
read context, still need an executable contract in the new model.

The next implementation should make input/override selection and its lifetime
explicit, then test both a never-active parent and a parent that starts or ends
an override while its child is pending. Those cases determine whether the
position can be stable, needs adjustment, or needs a richer relationship.
