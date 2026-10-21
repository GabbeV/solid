import Base
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-states.bend as M

def origin() -> R.World:
  M.origin()

def queued() -> R.World:
  W.queuePendingNode(origin(), 2n)

def slotted(+input: Nat) -> R.World:
  B.store_node(queued(), 2n, R.Node.with_pending(B.node(queued(), 2n), R.Present{R.Number{input}}))

def stamped(+input: Nat) -> R.World:
  +w = slotted(input)
  B.store_node(w, 2n, R.Node.with_notified(B.node(w, 2n), R.Stamped{R.World.epoch(w)}))

def inserted(input: Nat) -> R.World:
  H.enqueueSub(stamped(input), 3n)

def scheduled(input: Nat) -> R.World:
  B.schedule(inserted(input))
