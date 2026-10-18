# No-transaction production path of src/core/scheduler.ts. No lane, snapshot,
# store, boundary, external-source or attribution hooks are installed here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph.bend as G
import ./heap.bend as H
import ./constants.bend as K
import ./read-state.bend as V

def queuePendingNode(+w: R.World, id: Nat) -> R.World:
  +w = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  B.choose(~R.World, Bool.not(R.World.running(w)), _ => V.markUnflushedStaged(w), _ => w)

def is_user(k: R.NodeKind) -> Bool:
  match k:
    case R.User{}:
      True{}
    case _:
      False{}

def enqueue(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.effect(R.Node.kind(B.node(w, id))),
    _ =>
      +w = B.choose(~R.World, is_user(R.Node.kind(B.node(w, id))),
        _ => R.World.with_userQueue(w, B.append(Nat, R.World.userQueue(w), [id])),
        _ => R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), [id])))
      B.schedule(w),
    _ => B.schedule(w))

def insert_subs(fuel: Nat, +w: R.World, +edge: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +e = B.link(w, edge)
          +id = R.Link.sub(e)
          +sub = B.node(w, id)
          missed = Bool.and(B.has(R.Node.flags(sub), 4), Bool.and(Nat.is_eq(R.Link.gen(e), R.Node.depGen(sub)), Nat.is_ne(edge, R.Node.depsTail(sub))))
          +w = B.choose(~R.World, missed,
            _ => B.store_node(w, id, R.Node.with_flags(sub, B.set(R.Node.flags(sub), 4096))), _ => w)
          insert_subs(p, H.enqueueSub(w, id), R.Link.nextSub(e)))

def insertSubs(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.Stamped{R.World.epoch(w)}))
  insert_subs(B.budget(w), w, R.Node.subs(B.node(w, id)))

# Called with a value (the expression updater is evaluated by the machine).
# Source returns v even when equality suppresses the write.
def setSignal(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  +n = B.node(w, id)
  changed = Bool.or(Bool.not(R.Node.equals(n)), Bool.not(B.equal(B.current(n), value)))
  B.choose(~R.World, changed,
    _ =>
      +staged = B.present(R.Node.pending(n))
      +w = B.choose(~R.World, staged, _ => w, _ => queuePendingNode(w, id))
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
      B.choose(~R.World, Bool.and(staged, B.stampMatches(R.Node.notified(n), R.World.epoch(w))), _ => w,
        _ => B.schedule(insertSubs(w, id))),
    _ => w)

# Source n._value = n._pendingValue; n._pendingValue = NOT_PENDING.
def commitValue(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.present(R.Node.pending(n)),
    _ =>
      +w = B.store_node(w, id, R.Node.with_value(n, B.current(n)))
      B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{})),
    _ => w)

def commitComputedAnswer(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +inFlight = Bool.and(Bool.not(B.present(R.Node.pending(n))), B.has(R.Node.status(n), K.STATUS_PENDING()))
  +w = B.choose(~R.World, B.present(R.Node.pending(n)),
    _ =>
      +w = commitValue(w, id)
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED())))
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ =>
          +w = B.store_extension(w, id, R.NodeExtension.with_reask(B.extension(w, id), False{}))
          B.store_extension(w, id, R.NodeExtension.with_flushed(B.extension(w, id), R.Empty{})),
        _ => w)
      # A staged effect is born held: its first application belongs to this
      # commit. EFFECT_TRACKED is outside the current NodeKind grammar.
      B.choose(~R.World, B.effect(R.Node.kind(n)),
        _ => enqueue(B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{})), id),
        _ => w),
    _ => w)
  +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
  +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE())))
  +w = B.choose(~R.World, B.nullish(R.NodeExtension.error(B.extension(w, id))),
    _ => G.trimStaleDeps(w, id), _ => w)
  +w = B.choose(~R.World, Bool.not(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())),
    _ => B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))),
    _ => w)
  # Source GlobalQueue._dispose(c, false, true): parked teardown is not yet
  # translated. Refuse if that source call would be needed.
  parked = Bool.and(Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    Bool.or(Nat.is_ne(R.NodeExtension.pendingFirstChild(B.extension(w, id)), 0n), Bool.not(B.noDisposal(R.NodeExtension.pendingDisposal(B.extension(w, id))))))
  B.choose(~R.World, Bool.and(Bool.not(inFlight), parked),
    _ => R.World.with_fault(w, R.Unsupported{5n}), _ => w)

# core/scheduler.ts:commitPendingNode, computed segment. The current Node
# extension is nullable and lazily allocated. Parked-child disposal and staged
# error propagation remain unfinished and explicitly refuse their paths.
def commitComputed(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +inFlight = Bool.and(Bool.not(B.present(R.Node.pending(n))), B.has(R.Node.status(n), K.STATUS_PENDING()))
  +err = B.has(R.Node.config(n), K.CONFIG_STAGED_ERROR())
  +w = B.choose(~R.World, Bool.and(Bool.not(inFlight), Nat.is_ne(R.Node.x(n), 0n)),
    _ => B.store_extension(w, id, R.NodeExtension.with_shownError(B.extension(w, id), R.Undefined{})), _ => w)
  +config = B.choose(~U32, inFlight,
    _ => B.set(B.clear(R.Node.config(n), B.set(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME())), K.CONFIG_INPUTS_PUBLISHED()),
    _ => B.clear(R.Node.config(n), B.set(K.CONFIG_HELD(), B.set(K.CONFIG_HELD_FRAME(), B.set(K.CONFIG_STAGED(), B.set(K.CONFIG_INPUTS_PUBLISHED(), K.CONFIG_STAGED_ERROR()))))))
  +w = B.store_node(w, id, R.Node.with_config(n, config))
  B.choose(~R.World, err,
    _ => R.World.with_fault(w, R.Unsupported{2n}),
    _ => commitComputedAnswer(w, id))

def commitPendingNode(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, Bool.not(B.computed(R.Node.kind(n))),
    _ =>
      # Source !c._fn branch: clear config BEFORE publishing; do not touch
      # computed-only status, loading, manual-write flags or dependency lists.
      +w = B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), B.set(K.CONFIG_STAGED(), K.CONFIG_HELD()))))
      commitValue(w, id),
    _ => commitComputed(w, id))

# The source bound is LIVE pendingNodes.length, not a pre-cleared snapshot.
# Explicit fuel accounts for future callbacks that append during this walk.
def commit_list(fuel: Nat, +w: R.World, +index: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.pendingNodes(w))), _ => w,
        _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.pendingNodes(w))), _ => w,
        _ =>
          +id = B.get(Nat, R.World.pendingNodes(w), index, 0n)
          +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), B.set(K.CONFIG_OVERRIDE(), K.CONFIG_HELD())),
            _ => w, _ => commitPendingNode(w, id))
          commit_list(p, w, 1n+index))

def commitPendingNodes(+w: R.World) -> R.World:
  +w = commit_list(Nat.add(B.length(Nat, R.World.pendingNodes(w)), B.budget(w)), w, 0n)
  R.World.with_pendingNodes(w, [])

def trim_list(fuel: Nat, +w: R.World, +index: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.trims(w))), _ => w,
        _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.trims(w))), _ => w,
        _ =>
          +id = B.get(Nat, R.World.trims(w), index, 0n)
          +w = B.choose(~R.World, Bool.and(B.nullish(R.NodeExtension.error(B.extension(w, id))), Bool.not(R.Node.modified(B.node(w, id)))),
            _ => G.trimStaleDeps(w, id), _ => w)
          trim_list(p, w, 1n+index))

def settle(+w: R.World) -> R.World:
  +w = commitPendingNodes(w)
  +w = trim_list(Nat.add(B.length(Nat, R.World.trims(w)), B.budget(w)), w, 0n)
  B.choose(~R.World, List.is_empty(&2, Nat, R.World.trims(w)), _ => w,
    _ => R.World.with_trims(w, []))
