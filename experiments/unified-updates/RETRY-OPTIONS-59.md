# Coordination options after allowing some retries

The user is reconsidering the blanket concern about repeated calculations and
asks what remains possible without going far beyond next's repair machinery.
This analysis does not silently withdraw the objection to late unentanglement,
or declare a numeric depth scheme or immutable context implementation accepted.

## What retries buy

A read can discover that a running computation selected earlier inputs under
the wrong context. Abandoning that attempt at the read avoids continuing with
mixed versions. Its uncommitted children can be retired and its value calculated
again. This can happen within synchronous preparation; a pending dependency
instead suspends until there is information to proceed. Ordinary downstream
propagation is still necessary. Requests initiated before a later read throws
cannot generally be undone.

This is compatible with one committed frame and one selected candidate/flight
per node. Retrying sequentially does not require maintaining a graph per layer.
That representation still needs real validation for ownership and cancellation;
it is not a proof of performance or size acceptance.

## Two meanings of uniformity

Uniform value/async/ownership/publication machinery remains the objective.
Ordinary updates can occupy a base context, with optimistic updates introducing
explicit context boundaries; the same selection/holding rules can then operate
within every context.

A stronger rule says any optimistic proposal unrelated to an ordinary proposal
must join it just like two ordinary proposals, while descendants can advance
over the entire entangled input group. Hidden dependencies make those relations
revisable. This is not proved impossible, but it conflicts with simultaneously
requiring immutable joins, maximal child progress and no retrospective discovery
that an existing proposal could have advanced sooner.

Example: c overrides a; q reads c+b; a delayed p eventually reads a+b. If c/b
initially join as unrelated peers, the later a/b join makes b part of c's lower
input group. Recovering c's ability to advance over that whole group requires
revising c/b, including q's selected arguments. Retrying q can make this coherent
going forward; it cannot erase its earlier wait or the request it already issued.
If the rule instead keeps the join, it sacrifices that child progress and may
make outcomes depend on discovery history. Merely renaming all this local repair
does not remove the choice.

## Alternatives

- Stable contexts/relations: learn a reader's context locally; peer joins do not
  change existing producer ordering. The closest next-sized direction, but
  context assignment and lifecycle remain substantial design work.
- Stable numeric strata: ordinary updates at zero, active overrides introduce
  higher strata, peers at a stratum join, higher work uses committed lower
  values. Broader ordering sacrifices the unrelated-peer rule but avoids that
  class of ancestry-induced join reversal. Depth must not mean the continually
  recomputed maximum of all newly discovered speculative paths.
- Revision within synchronous preparation: stabilize runnable affected work
  before publication, accepting repeated attempts. This can reduce order effects
  in visible synchronous graphs. It cannot discover reads blocked by a pending
  accessor, so it does not alone settle later async discovery.
- Revisable relations throughout pending work: can preserve more graph-relative
  symmetry and recover progress, but must cancel/recalculate affected work later.
  Historical revisable experiments exercised some such cases coherently; they
  do not establish general correctness. This explicitly reopens the late
  unentanglement objection and is more than next's demonstrated local repair.

Stable contexts and local retries are complementary, not alternatives. Likewise,
numeric depth is one possible encoding of stable contexts, not a separate claim
that stability is insufficient.

## What next actually supplies

Next has a broad optimistic-versus-ordinary distinction: optimistic work reads
committed held ordinary values. Lane parent ancestry distinguishes descendants;
unrelated lanes meeting in a reader link for publication. `enterLane` can change
a reader's posture and enqueue repair. Parents are transaction/lane relations,
not a longest-path depth computed from every late-discovered input dependency.
This is evidence for explicit contexts plus local repair, not a demonstration
that next has a complete immutable-priority model or correct general layered
semantics. Copying its special storage/publication machinery is not the goal.

## Proposed next target

Try stable proposal contexts and read-time repair in an isolated small model.
An active override must truly cut input context propagation while continuing
accepted observation forwarding and action lifetime behavior. One hypothesis
is to attach it to the input version/context it actually overrides, instead of
retroactively making every hidden future input its parent. This must resolve
initially-unavailable input, inactive transparency, subsequent parent activation,
correction and expiration. Committed-depth freezing in the old engine is not
this design and already over-held in stage 55.

Retain explicit examples for the semantic cost: a high-stratum unrelated
optimistic proposal may advance with committed ordinary input, just as next
does. Do not claim the stronger unrelated-peer equivalence survives that choice.
No final representation selected, runtime changed, performance measured or
acceptance contract relaxed at this checkpoint.
