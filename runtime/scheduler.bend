# No-transaction production path of src/core/scheduler.ts. No lane, snapshot,
# store, boundary, external-source or attribution hooks are installed here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph.bend as G
import ./heap.bend as H

def queuePendingNode(+w: R.World, id: Nat) -> R.World:
  R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))

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
  +w = B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.World.epoch(w)))
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
      B.choose(~R.World, Bool.and(staged, Nat.is_eq(R.Node.notified(n), R.World.epoch(w))), _ => w,
        _ => B.schedule(insertSubs(w, id))),
    _ => w)

def commitPendingNode(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +w = B.choose(~R.World, B.present(R.Node.pending(n)),
    _ => B.store_node(w, id, R.Node.with_pending(R.Node.with_value(n, B.current(n)), R.Empty{})), _ => w)
  +w = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(n), 128)))
  B.choose(~R.World, B.computed(R.Node.kind(n)),
    _ => G.trimStaleDeps(B.store_node(w, id, R.Node.with_status(R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), 1024)), 0)), id),
    _ => w)

def commit_list(ids: List<&2, Nat>, w: R.World) -> R.World:
  match ids:
    case Nil{}:
      w
    case id <> rest:
      commit_list(rest, commitPendingNode(w, id))

def commitPendingNodes(+w: R.World) -> R.World:
  commit_list(R.World.pendingNodes(w), R.World.with_pendingNodes(w, []))

def trim_list(ids: List<&2, Nat>, +w: R.World) -> R.World:
  match ids:
    case Nil{}:
      w
    case +id <> rest:
      trim_list(rest, B.choose(~R.World, R.Node.modified(B.node(w, id)), _ => w, _ => G.trimStaleDeps(w, id)))

def settle(+w: R.World) -> R.World:
  +w = commitPendingNodes(w)
  trim_list(R.World.trims(w), R.World.with_trims(w, []))
