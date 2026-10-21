import Base
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-initial-data.bend as M

def origin(initial: Nat) -> R.World:
  M.finished(initial)

def queued(+initial: Nat) -> R.World:
  W.queuePendingNode(origin(initial), 2n)

def slotted(+initial: Nat, +input: Nat) -> R.World:
  B.store_node(queued(initial), 2n, R.Node.with_pending(B.node(queued(initial), 2n), R.Present{R.Number{input}}))

def stamped(initial: Nat, +input: Nat) -> R.World:
  +w = slotted(initial, input)
  B.store_node(w, 2n, R.Node.with_notified(B.node(w, 2n), R.Stamped{R.World.epoch(w)}))

def inserted(initial: Nat, input: Nat) -> R.World:
  H.enqueueSub(stamped(initial, input), 3n)

def scheduled(initial: Nat, input: Nat) -> R.World:
  B.schedule(inserted(initial, input))
