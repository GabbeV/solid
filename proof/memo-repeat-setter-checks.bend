import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M
import ./memo-repeat-setter-data.bend as D

def origin(+first: Nat) -> {M.origin(first) == D.origin(first) : R.World}:
  {==}

def queue(+first: Nat) -> {W.queuePendingNode(D.origin(first), 2n) == D.queued(first) : R.World}:
  {==}

def slot(+first: Nat, +input: Nat) -> {B.store_node(D.queued(first), 2n, R.Node.with_pending(B.node(D.queued(first), 2n), R.Present{R.Number{input}})) == D.slotted(first, input) : R.World}:
  {==}

def stamp(+first: Nat, +input: Nat) -> {B.store_node(D.slotted(first, input), 2n, R.Node.with_notified(B.node(D.slotted(first, input), 2n), R.Stamped{R.World.epoch(D.slotted(first, input))})) == D.stamped(first, input) : R.World}:
  {==}

def insert(+first: Nat, +input: Nat) -> {H.enqueueSub(D.stamped(first, input), 3n) == D.inserted(first, input) : R.World}:
  {==}

def schedule(+first: Nat, +input: Nat) -> {B.schedule(D.inserted(first, input)) == D.scheduled(first, input) : R.World}:
  {==}

def prefix(+first: Nat, +input: Nat) -> {Cuts.noSlot(M.origin(first), 2n, R.Number{input}) == D.slotted(first, input) : R.World}:
  {==}

def notify(+first: Nat, +input: Nat) -> {W.insertSubs(D.slotted(first, input), 2n) == D.inserted(first, input) : R.World}:
  {==}
