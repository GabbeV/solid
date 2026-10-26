# Runtime-only closed controls for held joins, allocated snapshot storage and
# extension-pointer retention. Every mutant compiles; the unchanged probe must
# pass before any rejection receives credit. No generic proof is imported here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/transaction.bend as X
import ../runtime/read-state.bend as Read
import ../runtime/write.bend as W
import ../runtime/heap.bend as H

def signal() -> R.World:
  N.signal(B.empty(),R.Number{0n},N.defaults())

def source() -> R.World:
  +pair = X.newTransaction(signal(),False{},0n)
  +w = B.first(R.World,Nat,pair)
  +w = B.store_transaction(w,1n,R.Transaction.with_open(B.transaction(w,1n),2n))
  +w = R.World.with_clock(R.World.with_flushTransaction(w,1n),5n)
  +w = X.holdNode(W.stageResolved(w,1n,R.Number{7n}),1n,1n)
  +record = R.NodeExtension.with_error(R.NodeExtension.with_inFlight(B.extension(w,1n),R.FlightActive{99n}),R.StringValue{"kept"})
  R.World.with_scheduled(B.store_extension(w,1n,record),False{})

def saved() -> R.World:
  Read.stashFlushed(source(),1n)

def flushed() -> {R.NodeExtension.flushed(B.extension(saved(),1n)) == R.Present{R.Number{7n}} : R.Slot}:
  {==}

def currentClock() -> {R.NodeExtension.flushedAt(B.extension(saved(),1n)) == R.Stamped{5n} : R.Stamp}:
  {==}

def flight() -> {R.NodeExtension.inFlight(B.extension(saved(),1n)) == R.FlightActive{99n} : R.Flight}:
  {==}

def debt() -> {R.Transaction.open(B.transaction(saved(),1n)) == 2n : Nat}:
  {==}

def joinedSchedule() -> {R.World.scheduled(X.joinNode(source(),1n)) == True{} : Bool}:
  {==}

def canonicalCache() -> {R.NodeExtension.transaction(B.extension(X.joinNode(source(),1n),1n)) == 1n : Nat}:
  {==}

def reader() -> R.World:
  +w = N.createEffectNode(source(),R.Read{1n},R.Render{},0n,N.defaults(),0n,0n,0n)
  X.holdNode(w,2n,1n)

def heapPointer() -> {R.Node.x(B.node(H.actualInsertIntoHeap(reader(),2n),2n)) == 2n : Nat}:
  {==}

# With equality suppressing staging, the held-entry join must still schedule.
def suppressedSetterSchedules() -> {R.World.scheduled(W.setSignal(source(),1n,R.Number{7n})) == True{} : Bool}:
  {==}
