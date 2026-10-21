import Base
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M

def origin(+initial: Nat, first: Nat) -> R.World:
  M.origin(initial, first)

def queued(+initial: Nat, +first: Nat) -> R.World:
  W.queuePendingNode(origin(initial, first), 2n)

def slotted(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  B.store_node(queued(initial, first), 2n, R.Node.with_pending(B.node(queued(initial, first), 2n), R.Present{R.Number{input}}))

def stamped(+initial: Nat, first: Nat, +input: Nat) -> R.World:
  +w = slotted(initial, first, input)
  B.store_node(w, 2n, R.Node.with_notified(B.node(w, 2n), R.Stamped{R.World.epoch(w)}))

def inserted(+initial: Nat, first: Nat, input: Nat) -> R.World:
  H.enqueueSub(stamped(initial, first, input), 3n)

def scheduled(+initial: Nat, first: Nat, input: Nat) -> R.World:
  B.schedule(inserted(initial, first, input))
