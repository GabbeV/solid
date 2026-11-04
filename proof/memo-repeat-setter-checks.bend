import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M
import ./memo-repeat-setter-data.bend as D

import ./memo-history-setter-checks.bend as History
import ./memo-history-seed-data.bend as Seed

def origin(+initial: Nat, +first: Nat) -> {M.origin(initial, first) == D.origin(initial, first) : R.World}:
  History.origin(Nat.is_eq(first,initial),0n,first,Seed.events(initial,first),Seed.jobs())

def queue(+initial: Nat, +first: Nat) -> {W.queuePendingNode(D.origin(initial, first), 2n) == D.queued(initial, first) : R.World}:
  History.queue(Nat.is_eq(first,initial),0n,first,Seed.events(initial,first),Seed.jobs())

def slot(+initial: Nat, +first: Nat, +input: Nat) -> {B.store_node(D.queued(initial, first), 2n, R.Node.with_pending(B.node(D.queued(initial, first), 2n), R.Present{R.Number{input}})) == D.slotted(initial, first, input) : R.World}:
  History.slot(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def stamp(+initial: Nat, +first: Nat, +input: Nat) -> {B.store_node(D.slotted(initial, first, input), 2n, R.Node.with_notified(B.node(D.slotted(initial, first, input), 2n), R.Stamped{R.World.epoch(D.slotted(initial, first, input))})) == D.stamped(initial, first, input) : R.World}:
  History.stamp(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def insert(+initial: Nat, +first: Nat, +input: Nat) -> {H.enqueueSub(D.stamped(initial, first, input), 3n) == D.inserted(initial, first, input) : R.World}:
  History.insert(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def schedule(+initial: Nat, +first: Nat, +input: Nat) -> {B.schedule(D.inserted(initial, first, input)) == D.scheduled(initial, first, input) : R.World}:
  History.schedule(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def prefix(+initial: Nat, +first: Nat, +input: Nat) -> {Cuts.noSlot(M.origin(initial, first), 2n, R.Number{input}) == D.slotted(initial, first, input) : R.World}:
  History.prefix(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def notify(+initial: Nat, +first: Nat, +input: Nat) -> {W.insertSubs(D.slotted(initial, first, input), 2n) == D.inserted(initial, first, input) : R.World}:
  History.notify(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())
