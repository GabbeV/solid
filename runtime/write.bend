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
import ./subscriber-insertion.bend as Insert

def queuePendingNode(+w: R.World, id: Nat) -> R.World:
  +w = R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [id]))
  B.choose(~R.World, Bool.not(R.World.running(w)), _ => V.markUnflushedStaged(w), _ => w)

def is_user(k: R.NodeKind) -> Bool:
  match k:
    case R.User{}:
      True{}
    case _:
      False{}

# Tracked _run closures enter EFFECT_USER, while their node _type stays tracked.
def userQueue(+k: R.NodeKind) -> Bool:
  Bool.or(is_user(k), B.tracked(k))

def enqueueIn(+w: R.World, +id: Nat, +lane: Nat) -> R.World:
  B.choose(~R.World, B.effect(R.Node.kind(B.node(w, id))),
    _ =>
      +w = B.choose(~R.World, Nat.is_ne(lane, 0n),
        _ => B.choose(~R.World, userQueue(R.Node.kind(B.node(w, id))),
          _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(B.transaction(w, lane), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, lane)), [R.NodeRun{id}]))),
          _ => B.store_transaction(w, lane, R.Transaction.with_renderQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, lane)), [id])))),
        _ => B.choose(~R.World, userQueue(R.Node.kind(B.node(w, id))),
        _ => R.World.with_userQueue(w, B.append(R.QueueEntry, R.World.userQueue(w), [R.NodeRun{id}])),
        _ => R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), [id]))))
      B.schedule(w),
    _ => B.schedule(w))

def enqueue(+w: R.World, id: Nat) -> R.World:
  enqueueIn(w, id, R.World.passLane(w))

def insert_subs(fuel: Nat,w: R.World,edge: Nat) -> R.World:
  Insert.insert_subs(fuel,w,edge)

def insertSubs(w: R.World,id: Nat) -> R.World:
  Insert.insertSubs(w,id)

# Called with a value (the expression updater is evaluated by the machine).
# Source returns v even when equality suppresses the write.
# core.ts:setSignal after invoking v(currentValue). currentValue is the
# entry local, not a second slot read after an updater's reentrant writes.
# Source setSignal's held join is before the comparator, after the updater.
def beforeCompare(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.joinNode(w, id), _ => w)

def skipCompare(+w: R.World, +id: Nat) -> Bool:
  Bool.or(B.has(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()), B.truth(R.NodeExtension.shownError(B.extension(w, id))))

# Source stores after the verdict. Reload live fields here: a comparator can
# write reentrantly. currentValue remains the setter's separate entry local.
def stageResolved(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  +n = B.node(w, id)
  +staged = B.present(R.Node.pending(n))
  +w = B.choose(~R.World, staged,
    _ => B.choose(~R.World, Bool.and(B.has(R.Node.config(n), K.CONFIG_HELD()), Bool.not(R.World.running(w))), _ => V.stashFlushed(w, id), _ => w),
    _ => queuePendingNode(w, id))
  +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
  +w = B.choose(~R.World, Nat.is_ne(R.World.context(w), 0n), _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.choose(~R.World, B.computed(R.Node.kind(n)), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  B.choose(~R.World, Bool.and(staged, B.stampMatches(R.Node.notified(n), R.World.epoch(w))), _ => w,
    _ => B.schedule(insertSubs(w, id)))

# Restricted direct facade for World-only probes/proof constructors. Active
# custom functions run in core.setResolved with read-capable continuations.
def setResolved(+w: R.World, +id: Nat, currentValue: R.Value, +value: R.Value) -> R.World:
  +w = beforeCompare(w, id)
  B.choose(~R.World, skipCompare(w, id), _ => stageResolved(w, id, value),
    _ => B.choose(~R.World, Nat.is_ne(EQ.custom(w, id), 0n), _ => R.World.with_fault(w, R.Unsupported{23n}),
      _ => B.choose(~R.World, EQ.isSame(w, id, currentValue, value), _ => w, _ => stageResolved(w, id, value))))


def setSignal(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  setResolved(w, id, B.current(B.node(w, id)), value)


# GlobalQueue.enqueue(EFFECT_USER, fn), including plain callbacks without nodes.
def enqueueUserCallback(+w: R.World, +entry: R.QueueEntry) -> R.World:
  +lane = R.World.passLane(w)
  +w = B.choose(~R.World, Nat.is_ne(lane, 0n),
    _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(B.transaction(w, lane), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, lane)), [entry]))),
    _ => R.World.with_userQueue(w, B.append(R.QueueEntry, R.World.userQueue(w), [entry])))
  B.schedule(w)
