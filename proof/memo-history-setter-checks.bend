import Base
import ./memo-setter-cuts.bend as Cuts
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-history-states.bend as M
import ./memo-history-setter-data.bend as D

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {M.origin(tick, previous, events, jobs) == D.origin(tick, previous, events, jobs) : R.World}:
  {==}

def queue(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {W.queuePendingNode(D.origin(tick, previous, events, jobs), 2n) == D.queued(tick, previous, events, jobs) : R.World}:
  {==}

def slot(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.store_node(D.queued(tick, previous, events, jobs), 2n, R.Node.with_pending(B.node(D.queued(tick, previous, events, jobs), 2n), R.Present{R.Number{input}})) == D.slotted(tick, previous, input, events, jobs) : R.World}:
  {==}

def stamp(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.store_node(D.slotted(tick, previous, input, events, jobs), 2n, R.Node.with_notified(B.node(D.slotted(tick, previous, input, events, jobs), 2n), R.Stamped{R.World.epoch(D.slotted(tick, previous, input, events, jobs))})) == D.stamped(tick, previous, input, events, jobs) : R.World}:
  {==}

def insert(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {H.enqueueSub(D.stamped(tick, previous, input, events, jobs), 3n) == D.inserted(tick, previous, input, events, jobs) : R.World}:
  {==}

def schedule(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {B.schedule(D.inserted(tick, previous, input, events, jobs)) == D.scheduled(tick, previous, input, events, jobs) : R.World}:
  {==}

def prefix(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {Cuts.noSlot(M.origin(tick, previous, events, jobs), 2n, R.Number{input}) == D.slotted(tick, previous, input, events, jobs) : R.World}:
  {==}

def notify(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {W.insertSubs(D.slotted(tick, previous, input, events, jobs), 2n) == D.inserted(tick, previous, input, events, jobs) : R.World}:
  {==}
