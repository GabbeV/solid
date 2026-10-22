# Direct owner creation and children-only disposal

Current rc.17 policy is documented in [the integration review](reviews/solid-5b1b7776.md):
cleanup errors are collected while teardown continues, then rethrown at the
public root/flush boundary. Map/repeat fallback retry uses output length and
retains successful falsy values. Older pin-specific implementation notes below
are superseded at those operations; other profile restrictions remain.

Source: Solid d682022c, production `core/owner.ts:createOwner` and
`disposeRootSelf`. The existing production owner literal/linking implementation
now has a direct user-call entry: `{createOwner: {transparent}}` returns the fresh
owner without entering it. Root callback construction still uses the same
constructor and retains its own context/initializer continuations.

## Operation correspondence

- `OwnerCreate` captures the ambient parent, uses the existing
  `construct-state.createOwner` / `owner-state.createOwner` literal and child-link
  stores, and returns its stable owner reference. It installs no owner or tracking
  scope, bound callback, computed, transaction, heap entry or scheduling operation.
- Parent-computed forwarding, inherited context-record identity, transparent
  configuration, sibling links and fresh allocation remain in the original
  constructor helper. No alternate owner tree or lifetime implementation exists.
- `DisposeRoot` now carries a boolean `self`, default true in the public grammar.
  The actual root receiver is evaluated once and the same `owner.Enter` teardown
  driver receives that flag. `self=false` disposes children and registered cleanup
  while keeping the owner live; it may be populated again and later disposed.
- `createRoot`'s initializer disposer is a separate bound function. The source
  binds **both the receiver and true** (`disposeRootSelf.bind(owner, true)`), so
  additional call arguments remain ignored. That entry is unchanged.
- The owner method does not install its receiver as the ambient owner. Cleanup
  runs with the existing caller context, through the shared callback driver.
  Detachment/reentrancy, ignored cleanup returns, original exceptions and partial
  teardown are retained. No catch, halt policy or cleanup recovery was added.
- Production construction under an explicitly re-entered dead parent has no
  dead-parent guard in the pinned source. The control preserves that behavior;
  it does not promise safe use of dead scopes or classify it as an upstream bug.

The self flag is the represented boolean argument, not an arbitrary expression or
JavaScript property invocation. Owner handles remain opaque identities in the
host codec. Hydration IDs/child-ID counters, arbitrary owner properties or method
reflection, dev/observe hooks, active boundaries/lanes and arbitrary JavaScript
closures remain unfinished. Constructor source mapping remains partial.

## Evidence and proof boundary

Twenty-five paired histories compare the actual native constructor/method with
the translated driver: detached/root/computed parents, transparent owners,
unchanged ambient owner/observer, precise root links/flags, inherited context
snapshots and copy-on-write identities, child-only disposal/reuse, dead child
accessor freezing, cleanup registered during teardown, cleanup throws and an
explicit dead-parent scope. Two controls additionally observe native microtask
scheduling and the Bend queue's idle flag. Getter reads use the existing explicit
observation entry; no native read event is fabricated for a raw function call.

`proof/direct-owner-laws.bend` has four quantified properties:

1. The actual expression entry forwards the ambient parent and returns the newly
   allocated owner reference while preserving its caller continuation/operands.
2. Child linking preserves the ambient snapshot.
3. The constructor preserves that snapshot: context, tracking, running, scheduled,
   action depth, current question, pass lane and pass transaction.
4. The actual root method forwards its boolean self flag to the shared teardown
   continuation, under a root-kind premise.

These are frame/entry properties for arbitrary represented surrounding state,
not arbitrary owner-tree validity or progress theorems. Proof-only cuts expose
captured heads/branch booleans and the actual literal; their equations are checked
against the original helpers. The original independent kernel checks every
property. No runtime algorithm or kernel budget was changed for the proof.

One closed actual-public-entry execution constructs a detached owner and child,
runs child-only teardown, reuses the live owner, then finally disposes it. Its
checked observation includes owner/child death flags, the exact cleanup sequence,
empty child list and restored ambient/queue state.

Four compiled variants discard the ambient parent, install the new owner as
caller context, ignore `self=false`, or schedule work during construction. They
are rejected by finite assertion controls. An initial proof-property negative
trial of the scheduling variant hit the output cap while displaying a mismatch;
it is excluded from the rejection count. The same variant's finite native-IO /
queue control supplies its counted rejection. Positive formal evidence remains
separate from mutation-oracle evidence. No semantic deviation is active.
