# Stage 54: peers and actual boundary relationships

## Correction to the previous hypothesis

The user pointed out that the stage-53 optimistic output over a constant has no
input relationship to the independent ordinary signal. They should coordinate
as ordinary peers when their derivations meet. The assistant agreed; the user
instructed us to investigate this direction.

Global numerical depth incorrectly places every optimistic proposal above every
ordinary proposal, including unrelated ones. Immediate combined preparation in
the motivating example is explained by ordinary peer entanglement. A later
suspension and another guess should not automatically escape that join. No
special stage-53 admission mechanism is needed to explain that example.

The main stage-53 reference remains unchanged as a research checkpoint, **not**
a semantic oracle for the latest peer clarification. Both production checkouts
are unchanged. No stores, publication, or external communication were attempted.

## Isolated implementation

`reference/relation-plan.mjs` is a bounded planner over update origins, actual
boundary ancestry, shared-reader meetings, and fixed lifetime couplings. It
joins unrelated proposals regardless of their global depths. A child inherits
the whole joined input group.

The archived stage-41/42 documents record an additional accepted requirement:
for c over a, d over b, p=c+b and q=d+a, both children can advance using committed
parents even without an a/b join. Naively joining every unrelated pair can make
that result depend on discovery order. The planner therefore examines conflicting
peer joins together. It finds strongly connected components in native ancestry
plus proposed peer links, and uses native ancestry within each conflicting
component to orient incompatible peer links. Its rank is local to a conflict;
there is no global optimistic-versus-ordinary priority. This is an implementation
hypothesis, not a generally approved rule for arbitrary conflict graphs.

`reference/directed-scheduler.mjs` reuses the archived stage-51 scalar
value/ownership/publication engine and supplies the alternative relation plan.
It does not use stage-53 publication-admission edges, displaced-flight readiness
records, or the fresh-layer discovery phase. `directed-runtime.mjs` exposes the
same limited public accessor adapter for actual cross-runtime audits. The adapter
still lacks real DOM scheduling, latest, Loading, deferred, full actions, stores,
and the other limitations documented for the reference runtime.

## Exercised behavior and limits

Nine focused tests pass:

- Unrelated ordinary/optimistic proposals remain peers through renewed lower
  suspension, in both enumeration modes. Old answers cannot publish; actual
  publication callbacks observe coherent committed values. The open guessing
  action remains independent, and groups drain on disposal/closure.
- A child publishes over the whole entangled input group in both traversal orders.
- Planner-only permutations cover inherited lower joins and both crossed
  children, unrelated deep optimism, disjoint updates, and fixed scope coupling.

The existing broad suite was also run through `directed-loader.mjs` without
changing its assertions: **169 pass, 41 fail out of 210** at that checkpoint.
This includes historical tests and is not a production acceptance run. The
later focused four runtime tests were not in that broad run. The normal command
now reports 214 passing tests, but most exercise the unchanged older model;
that number must not be represented as a directed-model correctness pass.

Classification of the broad failures:

- Missing `.advances`/`.displaced` fields are stage-53-specific bookkeeping
  assertions; the alternative deliberately has no such records. Their observable
  portions need independent tests, not fabricated compatibility fields.
- Several stage-53 timelines treat an unrelated input as a lower update. Those
  expectations conflict with the user's latest peer clarification. The archived
  assertions remain intact for the archived model.
- Parent activation/expiration tests that order unrelated b solely by a's depth
  were explicitly hypotheses in stage 43, not individually accepted rulings.
  They require classification under actual relationships; they were not weakened.
- Native ancestry cycles during lifetime/correction campaigns and lost crossed
  exclusions after partial publication are implementation failures. They are not
  excused as semantic changes. The broad failure logs preserve their stacks and
  operation traces. The port must not be promoted.
- The synthetic explicit-parent ready-lower test actually has native ancestry;
  unlike the constant-input motivating example, its arbitration is not resolved
  merely by declaring the participants peers.

There are no new performance, allocation, heap, or shipped-size measurements.
The planner scans pending work and is not a production representation. The older
reference already failed performance against pinned next; no improvement or
acceptance follows from these results.

## A consequential timing question

The new peer ruling and the earlier crossed-child requirement need an explicit
sequential timeline before deciding whether publication joins may be revised.

```js
const [a, setA] = createSignal(0);
const [b, setB] = createSignal(0);
const [c, guessC] = createOptimistic(a);
const [d, guessD] = createOptimistic(b);
const p = createMemo(() => c() + b());
const q = createMemo(() => d() + a());
```

Render these values and async consequences of a/b. Initially guesses c=10,d=20
have published; their actions remain open. Ordinary proposals a=1,b=2 are held.

In one event, guess c=11. Under the peer clarification, p combines this with b=2
and c remains held by the b update. In a later event, guess d=21. Since d is above
b, the inherited-input-group rule puts it above the already joined b/c update.
It can derive q=21 using committed a=0.

Two coherent outcomes for that later event:

- Preserve the earlier b/c join: visible c=10,d=21,p=10,q=21, with a=b=0.
- Revise that earlier join to recover both-child progress: derive p=11 from
  committed b=0 and publish c=11,d=21,p=11,q=21, with a=b=0.

Recommendation to discuss: preserve the established peer join in this sequential
case, applying ordinary entanglement plus inherited input ancestry. Simultaneous
proposal discovery must still have a deterministic policy; it cannot inherit an
accidental sibling traversal order. Do not silently extend this recommendation
to override the earlier crossed-child ruling without the user's clarification.

`peer-crossing-audit.mjs` verifies the same program using synchronous p/q, async
parent consequences, held generator actions, and real published callbacks.
Pinned next publishes both guesses, in both one-event and sequential variants;
it already permits c=11,p=11 while b is held in the first event. The isolated
alternative preserves the b/c join in the sequential case. Its one-event result
releases only c instead, exposing the unresolved partial-publication/discovery
problem, not a third semantic choice to accept.

## Reproduction and artifacts

```sh
node --test experiments/layered-updates/reference/{relation-plan,directed-coordination}.test.mjs
UNIFIED=1 node --import ./experiments/layered-updates/reference/directed-loader.mjs \
  --test experiments/layered-updates/reference/*.test.mjs
node experiments/layered-updates/peer-crossing-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js signals split
node experiments/layered-updates/peer-crossing-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/directed-runtime.mjs signals split
```

`results/directed-coordination-stage54/` retains the untouched stage-53 reference,
focused/broad/main test logs, the original renewed-suspension result, and both
crossed-child timing variants against next and the alternative. A source
checkpoint preserves the alternative as evaluated here.

## Clarification: synchronous dependency tracking

The user correctly challenged the later conversational suggestion that async
work inherently prevents synchronous coordination. `core/async.ts` explicitly
states that reads register as dependencies only before the first `await`.
The static crossed graph above has synchronously discoverable dependencies;
its ordering problem is not an information-theoretic reason to delay optimism
or remove memo entanglement. A deterministic stabilization of the currently
runnable derivations and their update relationships remains a valid direction.

The actual delayed-join fixture (`reference/delayed-join-audit.mjs`) is different:
`enabled` returns an async boolean, and a separate synchronous `p` reads a/b only
when enabled becomes true. Its later reads happen in a later synchronous run,
not after an await in a tracked async body. This is a later dependency-discovery
event. It may require revising outstanding proposals, but it does not imply that
an earlier coherent publication must predict or be retroactively judged against
future graph changes. The assistant's stronger impossibility claim conflated
these cases and should not guide the implementation.
