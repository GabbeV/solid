import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-states.bend as M
import ./memo-setter-data.bend as D

def origin() -> {M.origin() == D.origin() : R.World}:
  {==}

def queue() -> {W.queuePendingNode(D.origin(), 2n) == D.queued() : R.World}:
  {==}

def slot(+input: Nat) -> {B.store_node(D.queued(), 2n, R.Node.with_pending(B.node(D.queued(), 2n), R.Present{R.Number{input}})) == D.slotted(input) : R.World}:
  {==}

def stamp(+input: Nat) -> {B.store_node(D.slotted(input), 2n, R.Node.with_notified(B.node(D.slotted(input), 2n), R.Stamped{R.World.epoch(D.slotted(input))})) == D.stamped(input) : R.World}:
  {==}

def insert(+input: Nat) -> {H.enqueueSub(D.stamped(input), 3n) == D.inserted(input) : R.World}:
  {==}

def schedule(+input: Nat) -> {B.schedule(D.inserted(input)) == D.scheduled(input) : R.World}:
  {==}

def matches(+input: Nat) -> {D.scheduled(input) == C.world(M.state_0(input)) : R.World}:
  {==}


def prefix(+input: Nat) -> {Cuts.noSlot(M.origin(), 2n, R.Number{input}) == D.slotted(input) : R.World}:
  {==}

def notify(+input: Nat) -> {W.insertSubs(D.slotted(input), 2n) == D.inserted(input) : R.World}:
  {==}
