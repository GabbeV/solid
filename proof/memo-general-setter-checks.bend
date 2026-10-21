import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-initial-data.bend as M
import ./memo-general-setter-data.bend as D

def origin(+initial: Nat) -> {M.finished(initial) == D.origin(initial) : R.World}:
  {==}

def queue(+initial: Nat) -> {W.queuePendingNode(D.origin(initial), 2n) == D.queued(initial) : R.World}:
  {==}

def slot(+initial: Nat, +input: Nat) -> {B.store_node(D.queued(initial), 2n, R.Node.with_pending(B.node(D.queued(initial), 2n), R.Present{R.Number{input}})) == D.slotted(initial, input) : R.World}:
  {==}

def stamp(+initial: Nat, +input: Nat) -> {B.store_node(D.slotted(initial, input), 2n, R.Node.with_notified(B.node(D.slotted(initial, input), 2n), R.Stamped{R.World.epoch(D.slotted(initial, input))})) == D.stamped(initial, input) : R.World}:
  {==}

def insert(+initial: Nat, +input: Nat) -> {H.enqueueSub(D.stamped(initial, input), 3n) == D.inserted(initial, input) : R.World}:
  {==}

def schedule(+initial: Nat, +input: Nat) -> {B.schedule(D.inserted(initial, input)) == D.scheduled(initial, input) : R.World}:
  {==}

def prefix(+initial: Nat, +input: Nat) -> {Cuts.noSlot(M.finished(initial), 2n, R.Number{input}) == D.slotted(initial, input) : R.World}:
  {==}

def notify(+initial: Nat, +input: Nat) -> {W.insertSubs(D.slotted(initial, input), 2n) == D.inserted(initial, input) : R.World}:
  {==}
