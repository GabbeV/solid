# Production literals from core/core.ts and owner.ts, in separate constructors.
# The arena Node is a tagged union of source shapes: fields absent on a source
# kind have inert representation defaults, not extra runtime semantics.
# Host callbacks/options are typed data, not JS getters. inheritId/hydration
# strings, snapshot capture, external-source and dev/observe hooks remain open.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./owner.bend as O
import ./core.bend as C

def defaults() -> R.NodeOptions:
  R.NodeOptions{True{}, False{}, False{}, False{}, False{}, False{}, 0, R.Empty{}, 0n}

def bit(enabled: Bool, value: U32) -> U32:
  B.choose(~U32, enabled, _ => value, _ => 0)

def append(+w: R.World, n: R.Node) -> R.World:
  R.World.with_nodes(w, B.append(R.Node, R.World.nodes(w), [n]))

def installUnobserved(+w: R.World, +id: Nat, +callback: Nat) -> R.World:
  B.choose(~R.World, Nat.is_ne(callback, 0n),
    _ =>
      +w = E.ext(w, id)
      B.store_extension(w, id, R.NodeExtension.with_unobserved(B.extension(w, id), callback)),
    _ => w)

# core/core.ts:signal. Signals have no owner/heap/dependency slots in JS.
def signal(+w: R.World, value: R.Value, +options: R.NodeOptions) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  config = B.set(bit(R.NodeOptions.ownedWrite(options), K.CONFIG_OWNED_WRITE()), bit(R.NodeOptions.noSnapshot(options), K.CONFIG_NO_SNAPSHOT()))
  n = {R.Node{R.Signal{}, value, R.Empty{}, R.NodeOptions.equals(options), config,
    0, 0, R.World.clock(w), R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    0n, 0n, 0n, 0n, R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, 0n, 0n, 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}
  installUnobserved(append(w, n), id, R.NodeOptions.unobserved(options))

# core/owner.ts:createOwner; callback-based createRoot remains a facade concern.
def createOwner(+w: R.World, +parent: Nat, transparent: Bool) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  n = {R.Node{R.Root{}, R.Undefined{}, R.Empty{}, True{}, bit(transparent, K.CONFIG_TRANSPARENT()),
    K.REACTIVE_NONE(), 0, 0n, R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    parent, 0n, 0n, 0n, R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, B.parentComputed(w, parent), R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}
  +w = append(w, n)
  B.choose(~R.World, Nat.is_ne(parent, 0n), _ => O.linkChild(w, parent, id), _ => w)

# core/core.ts:setupComputedNode; the final eager recompute is source-owned.
def setupComputedNode(fuel: Nat, +w: R.World, +id: Nat, lazy: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), id))
  +parent = R.Node.parent(B.node(w, id))
  +computed = B.parentComputed(w, parent)
  +w = B.choose(~R.World, Nat.is_ne(parent, 0n), _ => O.linkChild(w, parent, id), _ => w)
  +w = B.choose(~R.World, Nat.is_ne(computed, 0n),
    _ => B.store_node(w, id, R.Node.with_height(B.node(w, id), 1n+R.Node.height(B.node(w, computed)))), _ => w)
  B.choose(~R.World, lazy, _ => w,
    _ => C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}], []})))

# core/core.ts:computed production literal (options.loading is presence-aware).
def computed(fuel: Nat, +w: R.World, expr: R.Expr, +options: R.NodeOptions, +parent: Nat) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +loading = B.present(R.NodeOptions.loading(options))
  +config = bit(R.NodeOptions.transparent(options), K.CONFIG_TRANSPARENT())
  +config = B.set(config, bit(R.NodeOptions.ownedWrite(options), K.CONFIG_OWNED_WRITE()))
  +config = B.set(config, bit(Bool.or(Nat.is_eq(parent, 0n), R.NodeOptions.lazy(options)), K.CONFIG_AUTO_DISPOSE()))
  +config = B.set(config, bit(R.NodeOptions.sync(options), K.CONFIG_SYNC()))
  +config = B.set(config, bit(R.NodeOptions.noSnapshot(options), K.CONFIG_NO_SNAPSHOT()))
  config = B.set(config, R.NodeOptions.extraConfig(options))
  n = {R.Node{R.Memo{}, B.selected(R.NodeOptions.loading(options), R.Undefined{}), R.Empty{}, R.NodeOptions.equals(options), config,
    bit(R.NodeOptions.lazy(options), K.REACTIVE_LAZY()), B.choose(~U32, loading, _ => 0, _ => K.STATUS_UNINITIALIZED()),
    R.World.clock(w), R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    parent, 0n, 0n, 0n, expr, False{}, R.Undefined{}, 0n, loading,
    0n, 0n, R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}
  +w = installUnobserved(append(w, n), id, R.NodeOptions.unobserved(options))
  setupComputedNode(fuel, w, id, R.NodeOptions.lazy(options))

# core/core.ts:createEffectNode production literal. Loading, equals, lazy,
# _noSnapshot and auto-dispose options are deliberately NOT borrowed from memo.
def createEffectNode(+w: R.World, expr: R.Expr, kind: R.NodeKind, target: Nat, +options: R.NodeOptions, +parent: Nat, program: Nat, returnedCleanup: Nat) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +config = bit(R.NodeOptions.transparent(options), K.CONFIG_TRANSPARENT())
  +config = B.set(config, bit(R.NodeOptions.ownedWrite(options), K.CONFIG_OWNED_WRITE()))
  +config = B.set(config, bit(R.NodeOptions.sync(options), K.CONFIG_SYNC()))
  config = B.set(config, R.NodeOptions.extraConfig(options))
  n = {R.Node{kind, R.Undefined{}, R.Empty{}, False{}, config,
    K.REACTIVE_LAZY(), K.STATUS_UNINITIALIZED(), R.World.clock(w), R.Unstamped{},
    0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, parent, 0n, 0n, 0n,
    expr, False{}, R.Undefined{}, target, False{},
    0n, 0n, R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, program, returnedCleanup, 0n} : R.Node}
  +w = installUnobserved(append(w, n), id, R.NodeOptions.unobserved(options))
  setupComputedNode(0n, w, id, True{})
