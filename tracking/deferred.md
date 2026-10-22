# Public deferred data and thenable profile

Update: [first-load streams](deferred-first-stream.md) are now admitted through
the original ordinary iterator engine. Stream wrapping after a real committed
answer remains Unsupported88. The data/thenable milestone description below is
retained; the total deferred corpus is now 302 histories.


The public createDeferred constructor now executes in the same core as memos,
optimistic writes, verdict windows and affects. This is a restricted production
profile, not a complete deferred.ts port. Direct streams, promise-to-stream
flattening inside the wrapper, from(), store slot/family hooks, boundaries,
snapshots and arbitrary JavaScript protocol/factory objects remain unfinished.
A reached stream branch returns Unsupported88 rather than substituting a memo or
silently repairing the source's buffered-stream bug.

## Source correspondence

runtime/deferred-runtime.bend allocates the closure identity and its persistent
end callback before computed/accessor construction. DeferredCell keeps node,
flight, marked and answered; DeferredBinding keeps cleanup function identity.
World.deferredArena carries all cells and one shared lagging membership list,
plus observer-to-closure bindings. No cell owns a private replacement Set.
The generated World now has 71 fields; existing whole-World frame proofs carry
this additional field unchanged, and old program domains/budgets are unchanged.

core.deferredBody and its continuations follow getOwner, CONFIG_REDERIVE,
cleanup(end), sticky answered/window opening, fn(prev), and the source catch in
that order. The new continuation boundaries are source call/field boundaries;
they do not drain host jobs, switch callback scope or invent intermediate
publication. Constructor eager/lazy behavior and options use ordinary computed
and accessor paths. Lexical, callback and action parameter capture recurse under
the new compute expressions just as under memo expressions.

On an open thenable window, ask precedes r.then(done, done), which precedes
serve/handleAsync. The done observer lands the closure with held=true; the later
engine observer still owns _inFlight/question/pending-source registration and
value/error processing. They are distinct subscriptions in source order, not a
combined callback. Immediate and queued settlement use existing flight helpers.
The wrapper returns through the original Finish frame, retaining its
selfRegistered/clear checks, including reuse of an already settled thenable.
A successful data return lands the current flight. Before the first real answer,
an async return uses the ordinary memo engine. Quiet refresh, stale callback
identity, held dependency landing and disposal use the original lifecycle rules.

watch-state.queueAnswer now calls the installed lagging hook for authoritative
truth readers before either success or error delivery. The full dependency walk
is unchanged. Ordinary resolve remains on its ordinary answer path.

## Evidence and limits

162 public histories compare actual pinned Solid construction, complete traces,
node state, marks, callback/cleanup identity and ordering, screens, reports and
promise observers. They cover data and callable payloads, loading seeds, lazy
initialization, disposal, previous arguments, captured parameters, native and
immediate thenables, resolution/rejection, replaced flights, unready wrapping,
until/refresh and held/refetch crossings. The existing 1,784 lifecycle/serve and
4,210 lagging-walk controls remain separate private segment evidence.

The independent kernel proves the complete owned constructor, outside-owner
(event-style) signal write, flush and accessor read for every natural initial
value and proposal, equals:false, at every budget >=103. Its conclusion is the
exact final Machine/World, with a value corollary. The execution has 103 actual
core.step transitions, not a substitute evaluator. Thirty-two finite/native
controls check every canonical prefix and exact final Machines at budgets
103/104/128. Proof-only setter/heap equations cut source helper boundaries;
the runtime algorithm is unchanged. The first monolithic proof exhausted kernel
resources; those attempts received no proof credit. The final composed proof
passes the pinned independent kernel. The quantified theorem does not cover
arbitrary graphs, async histories, disposal, or writes inside the owning root;
eight public owning-root write histories provide finite evidence for the latter.

Twenty new finite mutation variants and two kernel variants target this public
crossing. A proposed held-boolean variant survived the selected public cases and
was not credited: private lifecycle controls already test held landing, but the
public cases do not independently isolate that callback flag from downstream
engine holding. This is a coverage limit, not evidence of an upstream defect.

The original catch behavior is preserved, including the confirmed synchronous
error/obsolete-flight defect (SOLID-DEFERRED-SYNC-ERROR-009). Four public baseline
cases retain its until/refresh behavior. The three reported source defects have
isolated repros and candidate patches; none is installed and no issue/PR has
been filed. The semantic deviation register remains empty.


## Multiple deferred values

A further 32 public histories exercise two independently refreshing deferred
values, mixed eager/lazy construction, both promise styles and landing orders,
combined truth readers, and disposal before/after either request settles. Their
complete native state/traces/ports match. Three compiled variants separately
erase the shared lagging Set, route every done callback to cell one, or overwrite
the first sibling binding; all are rejected. This extends the deferred corpus to
194 histories and the project total to 3,612. It supplies finite concurrency
coverage, not a theorem for arbitrary overlapping async histories.


examples/deferred.bend is an executable consumer of the public constructor and
typed external thenable facade. It prints [10,false], [10,true], [21,false] and
Healthy before refetch, while refreshing and after the landing. This example's
external settlement callbacks are synchronous; native Promise microtask IO stays
in the host adapter. It uses the actual runtime, not a proof fixture.


## Ordinary-payload theorem extension

The original numeric program remains registered. Its complete 103-step lifecycle
now also has a [generalized ordinary-payload proof](deferred-payload-proof.md)
covering arbitrary represented booleans, strings and opaque reference identities,
as well as naturals, null, undefined, negative zero and NaN. Initial/proposed
types may differ. Every budget >=103 reaches the exact canonical final Machine
and proposed value. No runtime code or sufficient budget changed. Native/mixed
controls and payload-specific proof mutants are recorded separately; arbitrary
async histories/callable values/graph shapes remain outside this theorem.
