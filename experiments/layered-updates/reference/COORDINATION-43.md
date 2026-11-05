# Stage 43: inactive transparency and changing active layers

## Accepted rule

The user ruled: "optimistic should be completely transparent if it doesn't
currently have a active override". This applies to coordination as well as
values, and to previously overridden boundaries as well as unused ones.
The fixed declared-layer hypothesis from stage 42 does not meet this rule.

## Implemented research model

`active-layer-scheduler.mjs` adds actual input/override selectors to the common
one-committed-frame/one-candidate scheduler. An inactive selector reads its input
in the ordinary update context; it introduces no extra layer. An active selector
is provisionally placed one layer above its input. Ordinary derivations inherit
the maximum position of their dependencies. The dependency traversal considers
each complete path, so shared ancestors do not make positions read-order dependent.

`guess(output, value)` selects an override and proposes its control value.
`clear(output)` explicitly chooses reversion, cancels obsolete guessed work,
and proposes selection of the input. Both propagate through ordinary memos and
the same shared publication protocol. A function guess runs once; there is no
rebasing. These are model operations, not a proposed replacement public API.

The model distinguishes requested selection from the retained committed frame.
When clear starts an async correction, the old output remains visible until its
replacement and ordinary consequences can publish. Inactive transparency does
not permit revealing an unready replacement. Old async answers cannot publish.

Peer groups retain their original producer identities. If activating or ending
a parent override changes a pending child's position, peer grouping is rebuilt:
compatible peers remain joined, newly unequal positions separate. Original scope
identities survive this process. Source writes and ordinary memo propagation
continue using the same group, preparation and commit operations.

This is substantially less static than stage 42. It retains peer join records,
though it does not restore stage 41's lower-discovery passes or ancestry replay.
This added bookkeeping is a cost to evaluate, not evidence that a production
representation must use reversible union-find or numeric depth.

## Observable lifecycle cases

For these examples, q has controlled async work and b also has an independent
async consequence that remains held:

```js
const [a, guessA] = createOptimistic(() => source());
const [b, guessB] = createOptimistic(() => source());
const [c, guessC] = createOptimistic(a);
const q = createMemo(() => delayed(c() + b()));
```

With a inactive, guesses b=2 and c=10 are peers. Finishing q=12 alone keeps
visible b=0,c=0,q=0. Finishing b's consequence publishes b=2,c=10,q=12.
Substituting source directly for c's input produces the same publications.

Start from that held peer proposal, then activate a=1. The child c moves above
b; q=10 replaces q=12. Finishing q=10 allows a=0,b=0,c=10,q=10. The obsolete
q=12 answer cannot publish. Later parent work can publish a=1,b=2 with q=12.

Conversely, start with a active, c's higher proposal suspended, and b held.
Ending a's override makes c and b peers again. The old q=10 answer cannot
release c. Their combined q=12 and b's consequence must finish. The tested
final visible state is a=0,b=2,c=10,q=12.

These last two cases are consequences explored under the active-position
hypothesis, not separately requested semantic rulings. They preserve coherent
frames in both tested traversal orders. More complex context behavior remains
subject to falsification.

Three active overrides separated by inactive wrappers also unwind correctly:
the top can publish 3 while the lower two remain 0, then the middle can publish
2, then the bottom 1. Clearing them in reverse order returns their outputs to
their respective inputs, with each async consequence holding its replacement.

## Shared stale checking

The deeper test exposed unnecessary work after a child had published: an old
lower notification could rerun the child's unchanged output and start the same
async consequence again. This delayed the parent for no changed dependency.

The model now checks committed dependency frame identities before reevaluating
any memo. An unchanged frame retains its identity and owned children while
discharging its update obligation. This is shared ordinary stale checking, not
an optimistic-only bailout or a value equality check. An equal source write
still creates a new dependency frame and can replace owned children; that
existing lifecycle test continues to pass.

Disposing an owned optimistic output also disposes its private selector control
and removes its boundary record. The replacement campaign checks these counts.

## Validation

```sh
ACTIVE_LAYER=1 node --test experiments/layered-updates/reference/*.test.mjs
```

98 reference tests pass. Of these, 49 execute this scheduler: 25 selector and
lifecycle tests plus 24 shared scheduler/join tests. The others are explicitly
tied to earlier models and are not evidence for this implementation.

Coverage includes inactive/direct equivalence, repeated guesses, unrelated
reruns, late readers, crossed children, parent activation/expiry during a child
hold, cancellation of one joined peer, three active layers, errors and recovery,
owned replacement, equal-value lifecycle changes, stale answers and scopes.
Four deterministic lifecycle campaigns exercise 640 operations plus 60 ordinary
conditional-branch writes, interleaving answers and reversing traversal. Every
recorded publication checks its ordinary derivations. Final update/join/candidate
records are drained. A separate 100-cycle owned-selector test checks stable node,
boundary and subscriber counts. These are bounded tests, not a proof or a heap
profile. The shared suite also retains its earlier finite campaigns.

The actual next baseline and existing production prototype were rerun with both
direct and wrapped inputs, for both unused and previously active/expired wrappers.
All eight runs keep b,c,q at zero until b's hold ends, then publish 2,10,12. Their
internal request traces differ between implementations, but inserting the wrapper
does not change either trace within an implementation. Exact output is under
`../results/reference-stage43/`. The prior override in the expired comparison is
equal-valued; this audit is not a full runtime test of nontrivial parent expiry.

## Architectural checkpoint and limits

This hypothesis survives the added selector and lifecycle tests. It still has
one eligible calculation per memo; group revision revalidates or supersedes it
rather than retaining alternative graphs. Inactive wrappers carry no intrinsic
priority. These are useful results, not grounds to declare the scalar work done.

The research implementation is 427 lines / 17,661 bytes, versus 317 / 12,848 for
the inadequate fixed-position model and 453 / 18,801 for the previous revisable
model. These raw figures do not establish shipped size, allocation cost, or
acceptable performance. It still scans the graph and traverses dependencies;
none of this belongs on settled ordinary reads in a production implementation.

Explicit clear is not a complete action lifetime model. Joining incoming answers
to open guessing actions, same-boundary overlapping action lifetimes, lazy
source-owned isPending, latest, ambient contexts and conditional discovery still
need integration. In particular, the old endpoint-equivalence fixture remains
with its original implementation; active selectors do not yet resolve its full
ordinary-within-a-layer question. Refresh and until remain outside this model;
stores remain paused.

The production runtime was not changed. Its stage-38 context-discovery defect
remains open, and its existing performance/size evidence is unchanged. Before a
runtime rewrite, the next gate is integrating lifetime and lazy observation
boundaries into this scheduler without another context-selection exception.
