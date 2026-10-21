import Base
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M

def origin(first: Nat) -> R.World:
  M.origin(first)

def queued(+first: Nat) -> R.World:
  W.queuePendingNode(origin(first), 2n)

def slotted(+first: Nat, +input: Nat) -> R.World:
  B.store_node(queued(first), 2n, R.Node.with_pending(B.node(queued(first), 2n), R.Present{R.Number{input}}))

def stamped(first: Nat, +input: Nat) -> R.World:
  +w = slotted(first, input)
  B.store_node(w, 2n, R.Node.with_notified(B.node(w, 2n), R.Stamped{R.World.epoch(w)}))

def inserted(first: Nat, input: Nat) -> R.World:
  H.enqueueSub(stamped(first, input), 3n)

def scheduled(first: Nat, input: Nat) -> R.World:
  B.schedule(inserted(first, input))
