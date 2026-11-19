# Stage 44: action lifetimes, retirement and lazy pending

This is an operational reference experiment. Production code, production bundle
measurements and production performance evidence have not changed. Stores remain
paused. The stage-38 runtime defect remains open in the production prototype.

## Why active depth was insufficient

The previous model did not promptly supersede peer work when an override expired:

```js
const [a, guessA] = createOptimistic(() => 4);
const [b, guessB] = createOptimistic(() => 0);
const label = createMemo(() => delayed(`${a()}/${b()}`));
```

Publish guesses a=6,b=2. While their separate actions remain open, B proposes 1,
starting label=6/1. Then A's action ends. The required correction is label=4/1;
it must not wait for obsolete 6/1 work. The previous depth model instead finished
and published 6/1 first, then started 4/1. Its frames were coherent, but its
supersession behavior failed the previously accepted correction requirement.

The production comparison in `../expiry-peer-audit.mjs` confirms:

- Current next starts 4/1 immediately, but exposes a=4 while label remains 6/2.
- The existing prototype starts 4/1 immediately and retains visible 6,2,6/2
  until it can publish 4,1,4/1 coherently.
- The stage-43 reference waits for 6/1, then starts 4/1.

The actions must start in separate flushes for this comparison: batching both
starts shares their lifetime and changes when A can expire. Both comparison
scripts and exact results are retained under `../results/reference-stage44/`.

## Extended model

`LifetimeScheduler` extends the active selector model. Compatible peer joins
remain revisable when active layers change. A second relation, publication
coupling, persists through those position changes. It is used when an incoming
answer joins an open guessing action and when retirement replaces pending work
of the former output layer. A coupled group computes in its lowest participating
context. This is an implementation hypothesis, not a proof that numeric
positions plus these edges are sufficient for all graphs.

`begin`, `guess(..., { action })`, ordinary writes into the action group and
`close` exercise action scopes without adding a generator runner. Guesses have
their own publishable update; they do not wait for their owning action to close.
Incoming input proposals join that action's hold. Same-boundary overlapping
guesses share lifetimes, including equal guesses. Ready input and closed scopes
permit correction, which immediately supersedes obsolete guessed consequences.
A parent optimistic proposal is treated as an input to a child boundary in the
same way as an ordinary proposal. Functional guesses run once; there is no rebase.

Adding coupling exposed an actual convergence failure: speculative conditional
dependencies could alternate a pending correction's position between 0 and 1.
Each position selected the branch that implied the other position. The failed
campaign and trace are retained. The new model derives an existing memo's layer
from its committed dependencies; publication can change that structure. Initial
nodes without a committed frame still require further adversarial coverage.
This rule passes the current conditional campaigns, but is not a general
termination argument or an independently approved new observable contract.

## Value identity and ownership

Retirement now transfers publication obligations rather than eagerly destroying
every calculation in the replaced update. Ordinary dependency validation decides
whether a calculation is obsolete. A memo's equal proposed value retains its read
identity; its owner identity remains the frame object. Thus an equal output can
replace its owned children without forcing its consumers to recalculate.

This matters for early pending release. If confirmation has already started an
async pending-false consequence, ending the action preserves that same calculation
and its owned child. A true-to-false change still cancels obsolete true work.
Explicit equal source writes still replace owned frames in the shared tests.

## Lazy isPending

`PendingScheduler` adds one lazily initialized, source-owned output per observed
node. Calling readers share its publication. Removing the first reader does not
destroy the output used by another reader. Outside reads see the same committed
boolean. Direct-accessor observations are implemented; callback probing and
latest are not yet implemented in this model.

Pending true is a proposal above its input and uses ordinary downstream holding.
For an open action holding x=1 over committed x=0, a memo combining pending with x
publishes true:0. Matching input can propose false before the guessing action
ends, preserving the accepted early-release behavior. Retiring the observation
couples its restoration to the input update. Obsolete observation consequences
cannot prevent retirement; replacement consequences can hold publication.

The source's pending sample, the observation's committed boolean, and retirement
are distinct. The model explicitly tracks retirement until the input generation
finishes; otherwise an unpublished true proposal can repeatedly be recreated
while its false replacement is held. This lifecycle bookkeeping lives on
observations, not ordinary nodes. It still needs broader interaction testing.

The stage-38 late conditional-reader shape is invariant under disjoint observation
activity in this model. A fresh synchronous reader initializes from committed
inputs and can show true:0. This follows the model's existing committed mount
policy; it does not claim complete compatibility with next's mount entanglement.

## Validation after workspace recovery

```sh
OBSERVATION=1 node --test experiments/unified-updates/reference/*.test.mjs
```

120 tests pass; 71 execute the newest scheduler. The other 49 are tied to older
models. The newest scheduler passes the 49 selector/common tests, 12 action and
retirement tests, and 10 observation tests. This includes four 100-operation
overlapping-action campaigns, the earlier four 160-operation selector campaigns,
async supersession, errors, conditional branches, owned children, and stable
record counts across 100 observed action cycles. The two tests interrupted by
the workspace outage—pending-false reuse and observation cleanup—both pass.

These are bounded model tests. They are not production tests, browser validation,
heap profiles, a universal consistency proof or a convergence proof.

## Architectural reassessment

The useful common foundation remains one committed frame and one eligible
candidate, with one preparation/publication protocol. Both values and pending
outputs use it. Value identity is separate from ownership; obligation transfer
can preserve valid work while cancelling obsolete calculations.

However, active depth alone has failed as the coordination model. The extension
needs revisable peer joins, persistent publication coupling, committed dependency
structure and boundary retirement. Those costs must be confronted before a port.
The inherited research files total 755 lines / 30,868 bytes, including overridden
methods. That is not a shipped-size measurement and does not establish acceptable
performance. Graph scans, repeated reconstruction and dependency traversal in
these files are research conveniences, not an acceptable ordinary hot path.

Next gates: initial/unpublished dependency discovery, observation/lifetime
interaction under more adversarial schedules, and a compact account of which
relations actually need to persist. Then consolidate and test a production
representation with ordinary reads unchanged. Callback observations, latest,
refresh, until, complete action APIs and remaining scalar integration stay open.
No production rewrite should be justified by these green tests alone.
