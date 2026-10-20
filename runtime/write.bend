# core/core.ts:setSignal and scheduler notify/intake helpers, extracted as a
# leaf to express the TS core/owner/scheduler call cycle without duplicating it.
import Base
import ./equality.bend as EQ
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./heap.bend as H
import ./constants.bend as K
import ./read-state.bend as V
import ./transaction.bend as X

def queuePendingNode(+w: R.World, id: Nat) -> R.World:
  +w = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  B.choose(~R.World, Bool.not(R.World.running(w)), _ => V.markUnflushedStaged(w), _ => w)

def is_user(k: R.NodeKind) -> Bool:
  match k:
    case R.User{}:
      True{}
    case _:
      False{}

def enqueueIn(+w: R.World, +id: Nat, +lane: Nat) -> R.World:
  B.choose(~R.World, B.effect(R.Node.kind(B.node(w, id))),
    _ =>
      +w = B.choose(~R.World, Nat.is_ne(lane, 0n),
        _ => B.choose(~R.World, is_user(R.Node.kind(B.node(w, id))),
          _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.userQueue(B.transaction(w, lane)), [id]))),
          _ => B.store_transaction(w, lane, R.Transaction.with_renderQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, lane)), [id])))),
        _ => B.choose(~R.World, is_user(R.Node.kind(B.node(w, id))),
        _ => R.World.with_userQueue(w, B.append(Nat, R.World.userQueue(w), [id])),
        _ => R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), [id]))))
      B.schedule(w),
    _ => B.schedule(w))

def enqueue(+w: R.World, id: Nat) -> R.World:
  enqueueIn(w, id, R.World.passLane(w))

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
# core.ts:setSignal after invoking v(currentValue). currentValue is the
# entry local, not a second slot read after an updater's reentrant writes.
def setResolved(+w: R.World, +id: Nat, currentValue: R.Value, +value: R.Value) -> R.World:
  +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.joinNode(w, id), _ => w)
  +n = B.node(w, id)
  changed = Bool.or(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()), Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))),
    Bool.not(EQ.isSame(w, id, currentValue, value))))
  B.choose(~R.World, changed,
    _ =>
      +staged = B.present(R.Node.pending(n))
      +w = B.choose(~R.World, staged,
        _ => B.choose(~R.World, Bool.and(B.has(R.Node.config(n), K.CONFIG_HELD()), Bool.not(R.World.running(w))), _ => V.stashFlushed(w, id), _ => w),
        _ => queuePendingNode(w, id))
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
      +w = B.choose(~R.World, Nat.is_ne(R.World.context(w), 0n), _ => V.notePromotedWrite(w, id), _ => w)
      +w = B.choose(~R.World, B.computed(R.Node.kind(n)), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
      B.choose(~R.World, Bool.and(staged, B.stampMatches(R.Node.notified(n), R.World.epoch(w))), _ => w,
        _ => B.schedule(insertSubs(w, id))),
    _ => w)


def setSignal(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  setResolved(w, id, B.current(B.node(w, id)), value)

