# Production literals from core/core.ts and owner.ts, in separate constructors.
# The arena Node is a tagged union of source shapes: fields absent on a source
# kind have inert representation defaults, not extra runtime semantics.
# Host callbacks/options are typed data, not JS getters. inheritId/hydration
# strings, snapshot capture, external-source and dev/observe hooks remain open.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./equality.bend as EQ
import ./extension.bend as E
import ./owner.bend as O
import ./owner-state.bend as V

def defaults() -> R.NodeOptions:
  R.NodeOptions{True{}, False{}, False{}, False{}, False{}, False{}, 0, R.Empty{}, 0n, 0n}

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
  installUnobserved(EQ.register(append(w, n), id, R.NodeOptions.comparator(options)), id, R.NodeOptions.unobserved(options))

# Shared literal; callback-based roots also allocate through this definition.
def createOwner(w: R.World, parent: Nat, transparent: Bool) -> R.World:
  V.createOwner(w, parent, transparent)

# core/core.ts:setupComputedNode prefix, before its eager recompute.
# Both public construction and nested callbacks resume in the same core machine.
def setupComputedNode(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), id))
  +parent = R.Node.parent(B.node(w, id))
  +computed = B.parentComputed(w, parent)
  +w = B.choose(~R.World, Nat.is_ne(parent, 0n), _ => O.linkChild(w, parent, id), _ => w)
  +w = B.choose(~R.World, Nat.is_ne(computed, 0n),
    _ => B.store_node(w, id, R.Node.with_height(B.node(w, id), 1n+R.Node.height(B.node(w, computed)))), _ => w)
  w

# core/core.ts:computed production literal (options.loading is presence-aware).
def computed(+w: R.World, expr: R.Expr, +options: R.NodeOptions, +parent: Nat) -> R.World:
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
  +w = installUnobserved(EQ.register(append(w, n), id, R.NodeOptions.comparator(options)), id, R.NodeOptions.unobserved(options))
  setupComputedNode(w, id)

# core/core.ts:createEffectNode production literal. Loading, equals, lazy,
# _noSnapshot and auto-dispose options are deliberately NOT borrowed from memo.
# core.ts:createEffectNode's type << 23 configuration prefix, including the
# unused user-effect bit. Tracked public effects use their separate constructor.
def effectType(kind: R.NodeKind) -> U32:
  match kind:
    case R.Render{}: K.EFFECT_RENDER()
    case R.User{}: K.EFFECT_USER()
    case R.Tracked{}: K.EFFECT_TRACKED()
    case _: K.EFFECT_PURE()

def createEffectNode(+w: R.World, expr: R.Expr, +kind: R.NodeKind, target: Nat, +options: R.NodeOptions, +parent: Nat, program: Nat, returnedCleanup: Nat) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +config = U32.shln(effectType(kind),23n)
  +config = B.set(config,bit(R.NodeOptions.transparent(options), K.CONFIG_TRANSPARENT()))
  +config = B.set(config, bit(R.NodeOptions.ownedWrite(options), K.CONFIG_OWNED_WRITE()))
  +config = B.set(config, bit(R.NodeOptions.sync(options), K.CONFIG_SYNC()))
  config = B.set(config, R.NodeOptions.extraConfig(options))
  n = {R.Node{kind, R.Undefined{}, R.Empty{}, False{}, config,
    K.REACTIVE_LAZY(), K.STATUS_UNINITIALIZED(), R.World.clock(w), R.Unstamped{},
    0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, parent, 0n, 0n, 0n,
    expr, False{}, R.Undefined{}, target, False{},
    0n, 0n, R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, program, returnedCleanup, 0n} : R.Node}
  +w = installUnobserved(append(w, n), id, R.NodeOptions.unobserved(options))
  setupComputedNode(w, id)
