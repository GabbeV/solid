# Source scheduler helpers. GlobalQueue.settle continuations live in core.bend
# to express recursive recomputes without a Bend module cycle. Active lane,
# snapshot, store, boundary and attribution scopes remain unfinished.
import Base
import ./equality.bend as EQ
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph.bend as G
import ./heap.bend as H
import ./constants.bend as K
import ./read-state.bend as V
import ./owner.bend as O
import ./write.bend as W
import ./status.bend as A
import ./transaction.bend as X
import ./rerun-state.bend as Rerun

# Public source-boundary names delegate to the single shared write path.
def queuePendingNode(w: R.World, id: Nat) -> R.World:
  W.queuePendingNode(w, id)

def is_user(k: R.NodeKind) -> Bool:
  W.is_user(k)

def enqueue(w: R.World, id: Nat) -> R.World:
  W.enqueue(w, id)

def insertSubs(w: R.World, id: Nat) -> R.World:
  W.insertSubs(w, id)

def setSignal(w: R.World, id: Nat, value: R.Value) -> R.World:
  W.setSignal(w, id, value)

# Source n._value = n._pendingValue; n._pendingValue = NOT_PENDING.
def commitValue(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.present(R.Node.pending(n)),
    _ =>
      +w = B.store_node(w, id, R.Node.with_value(n, B.current(n)))
      B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{})),
    _ => w)

# commitPendingNode before and after its user-call boundaries. These segments
# serve both the direct restricted helper facade and core's continuation driver.
def finishCommitFields(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
  B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), K.REACTIVE_MANUAL_WRITE())))

def afterCommitTrim(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Bool.not(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING())),
    _ => B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))), _ => w)

def disposeCommittedFrame(+w: R.World, +id: Nat, inFlight: Bool) -> Bool:
  Bool.and(Bool.not(inFlight), Bool.and(Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
    Bool.or(Nat.is_ne(R.NodeExtension.pendingFirstChild(B.extension(w, id)), 0n), Bool.not(B.noDisposal(R.NodeExtension.pendingDisposal(B.extension(w, id)))))))

def finishComputedCommit(+w: R.World, +id: Nat, +inFlight: Bool) -> R.World:
  +w = finishCommitFields(w, id)
  +w = B.choose(~R.World, B.nullish(R.NodeExtension.error(B.extension(w, id))), _ => G.trimStaleDeps(w, id), _ => w)
  B.choose(~R.World, B.ok(w),
    _ =>
      +w = afterCommitTrim(w, id)
      B.choose(~R.World, disposeCommittedFrame(w, id, inFlight), _ => O.disposeChildren(w, id, False{}, True{}), _ => w), _ => w)

def commitAnswerValue(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.present(R.Node.pending(n)),
    _ =>
      +w = commitValue(w, id)
      +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED())))
      +w = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n),
        _ =>
          +w = B.store_extension(w, id, R.NodeExtension.with_reask(B.extension(w, id), False{}))
          B.store_extension(w, id, R.NodeExtension.with_flushed(B.extension(w, id), R.Empty{})), _ => w)
      B.choose(~R.World, Bool.and(B.effect(R.Node.kind(n)), Bool.not(B.tracked(R.Node.kind(n)))),
        _ => enqueue(B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{})), id), _ => w),
    _ => w)

def commitComputedPrefix(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  +inFlight = Bool.and(Bool.not(B.present(R.Node.pending(n))), B.has(R.Node.status(n), K.STATUS_PENDING()))
  +err = B.has(R.Node.config(n), K.CONFIG_STAGED_ERROR())
  +w = B.choose(~R.World, Bool.and(Bool.not(inFlight), Nat.is_ne(R.Node.x(n), 0n)),
    _ => B.store_extension(w, id, R.NodeExtension.with_shownError(B.extension(w, id), R.Null{})), _ => w)
  +config = B.choose(~U32, inFlight,
    _ => B.set(B.clear(R.Node.config(n), B.set(K.CONFIG_HELD(), K.CONFIG_HELD_FRAME())), K.CONFIG_INPUTS_PUBLISHED()),
    _ => B.clear(R.Node.config(n), B.set(K.CONFIG_HELD(), B.set(K.CONFIG_HELD_FRAME(), B.set(K.CONFIG_STAGED(), B.set(K.CONFIG_INPUTS_PUBLISHED(), K.CONFIG_STAGED_ERROR()))))))
  +w = B.store_node(w, id, R.Node.with_config(n, config))
  w = B.choose(~R.World, err,
    _ =>
      +error = B.selected(R.Node.pending(B.node(w, id)), R.NotPendingToken{})
      +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{}))
      +w = B.store_node(w, id, R.Node.with_time(B.node(w, id), 1n+R.World.clock(w)))
      A.notifyStatus(w, id, error),
    _ => commitAnswerValue(w, id))
  B.Bundle{w, inFlight}

def commitComputed(+w: R.World, +id: Nat) -> R.World:
  +pair = commitComputedPrefix(w, id)
  +w = B.first(R.World, Bool, pair)
  B.choose(~R.World, B.ok(w), _ => finishComputedCommit(w, id, B.second(R.World, Bool, pair)), _ => w)

def commitSignal(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +w = B.store_node(w, id, R.Node.with_config(n, B.clear(R.Node.config(n), B.set(K.CONFIG_STAGED(), K.CONFIG_HELD()))))
  commitValue(w, id)

def commitPendingNode(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.computed(R.Node.kind(B.node(w, id))), _ => commitComputed(w, id), _ => commitSignal(w, id))

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
          B.choose(~R.World, B.ok(w), _ => commit_list(p, w, 1n+index), _ => w))

def commitPendingNodes(+w: R.World) -> R.World:
  +w = commit_list(Nat.add(B.length(Nat, R.World.pendingNodes(w)), B.budget(w)), w, 0n)
  B.choose(~R.World, B.ok(w), _ => R.World.with_pendingNodes(w, []), _ => w)

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
          B.choose(~R.World, B.ok(w), _ => trim_list(p, w, 1n+index), _ => w))

def clearTrims(+w: R.World) -> R.World:
  B.choose(~R.World, List.is_empty(&2, Nat, R.World.trims(w)), _ => w, _ => R.World.with_trims(w, []))

def settle(+w: R.World) -> R.World:
  +w = commitPendingNodes(w)
  B.choose(~R.World, B.ok(w),
    _ =>
      +w = trim_list(Nat.add(B.length(Nat, R.World.trims(w)), B.budget(w)), w, 0n)
      B.choose(~R.World, B.ok(w), _ => clearTrims(w), _ => w),
    _ => w)

# scheduler.ts:deferZombie, called by GlobalQueue._update in the core machine.
def deferZombie(+w: R.World, +id: Nat) -> R.World:
  +w = H.deleteFromHeap(w, id)
  +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.clear(R.Node.flags(B.node(w, id)), B.set(K.REACTIVE_DIRTY(), K.REACTIVE_CHECK()))))
  R.World.with_deferredZombies(w, B.append(Nat, R.World.deferredZombies(w), [id]))

# scheduler.ts:GlobalQueue.settle, one captured-intake member on the park path.
def parkEligible(+w: R.World, +id: Nat) -> Bool:
  +n = B.node(w, id)
  Bool.and(Bool.not(B.has(R.Node.config(n), B.set(K.CONFIG_HELD(), K.CONFIG_OVERRIDE()))),
    Bool.not(R.Transaction.lane(B.transaction(w, R.NodeExtension.transaction(B.extension(w, id))))))

def parkLoading(+w: R.World, +id: Nat) -> Bool:
  +n = B.node(w, id)
  Bool.and(Bool.not(B.present(R.Node.pending(n))), Bool.and(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()), Bool.not(X.isRender(R.Node.kind(n)))))

def parkCanCompare(+w: R.World, +id: Nat) -> Bool:
  +n = B.node(w, id)
  Bool.and(B.present(R.Node.pending(n)), Bool.and(Bool.not(B.has(R.Node.status(n), B.set(K.STATUS_PENDING(), K.STATUS_UNINITIALIZED()))), Bool.not(O.parked(w, id))))

def parkEqual(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_pending(R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_STAGED())), R.Empty{}))

def parkChanged(+w: R.World, +id: Nat, +t: Nat, eligible: Bool) -> R.World:
  +w = B.choose(~R.World, eligible, _ => X.holdNode(w, id, t), _ => w)
  B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED()), _ => X.holdFrame(w, id, t), _ => w)

# Default-only facade; the active core park loop suspends for custom calls.
def parkPendingNode(+w: R.World, +id: Nat, +t: Nat) -> R.World:
  +eligible = parkEligible(w, id)
  B.choose(~R.World, Bool.and(eligible, parkLoading(w, id)), _ => w,
    _ => B.choose(~R.World, Bool.and(eligible, parkCanCompare(w, id)),
      _ => B.choose(~R.World, Nat.is_ne(EQ.custom(w, id), 0n), _ => R.World.with_fault(w, R.Unsupported{23n}),
        _ => B.choose(~R.World, EQ.isSame(w, id, R.Node.value(B.node(w, id)), B.current(B.node(w, id))),
          _ => parkEqual(w, id), _ => parkChanged(w, id, t, eligible))),
      _ => parkChanged(w, id, t, eligible)))

def park_list(fuel: Nat, +w: R.World, +t: Nat, +index: Nat, +count: Nat) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, count), _ => w,
        _ =>
          +w = parkPendingNode(w, B.get(Nat, R.World.pendingNodes(w), index, 0n), t)
          B.choose(~R.World, B.ok(w), _ => park_list(p, w, t, 1n+index, count), _ => w))

def parkPendingNodes(+w: R.World, t: Nat) -> R.World:
  +w = park_list(1n+Nat.add(B.budget(w), B.length(Nat, R.World.pendingNodes(w))), w, t, 0n, B.length(Nat, R.World.pendingNodes(w)))
  B.choose(~R.World, B.ok(w), _ => R.World.with_pendingNodes(w, []), _ => w)

# scheduler.ts:reruns, direct children of a rerun's old frame lose owed runs.
def clearChildRuns(fuel: Nat,w: R.World,child: Nat) -> R.World:
  Rerun.clearChildRuns(fuel,w,child)

def releaseQueues(+w: R.World, +t: Nat) -> R.World:
  +w = R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), R.Transaction.renderQueue(B.transaction(w, t))))
  +w = B.store_transaction(w, t, R.Transaction.with_renderQueue(B.transaction(w, t), []))
  +w = R.World.with_userQueue(w, B.append(R.QueueEntry, R.World.userQueue(w), R.Transaction.userQueue(B.transaction(w, t))))
  B.store_transaction(w, t, R.Transaction.with_userQueue(B.transaction(w, t), []))

# Stable ascending height order used by the seam's detached zombie array.
def insertHeight(+w: R.World, +id: Nat, xs: List<&2, Nat>) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      [id]
    case +head <> +tail:
      B.choose(~List<&2, Nat>, Nat.is_le(R.Node.height(B.node(w, id)), R.Node.height(B.node(w, head))), _ => id <> head <> tail,
        _ => head <> insertHeight(w, id, tail))

def sortHeights(+w: R.World, xs: List<&2, Nat>) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      []
    case id <> tail:
      insertHeight(w, id, sortHeights(w, tail))
