# Consequences of the precise held outer frame: extension membership and the
# canonical group cache remain available after staging. The source pointer is
# transported separately by the all-node pointer invariant.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-write-outer.bend as Frame
import ./held-stash-frame.bend as Stash

# Erasing a snapshot does not erase its allocated slot or any other record.
def eraseLength(+rows: List<&2,R.NodeExtension>,slot: Nat) -> {B.length(R.NodeExtension,Stash.erase(rows,slot)) == B.length(R.NodeExtension,rows) : Nat}:
  match rows slot:
    case Nil{} at: {==}
    case head <> tail 0n: {==}
    case head <> +tail 1n+at:
      Equal.cong(Nat,Nat,n=>1n+n,B.length(R.NodeExtension,Stash.erase(tail,at)),B.length(R.NodeExtension,tail),eraseLength(tail,at))

def eraseRead(+rows: List<&2,R.NodeExtension>,+slot: Nat) -> {B.get(R.NodeExtension,Stash.erase(rows,slot),slot,B.blank_extension()) == Stash.clean(B.get(R.NodeExtension,rows,slot,B.blank_extension())) : R.NodeExtension}:
  match rows slot:
    case Nil{} at: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+at: eraseRead(tail,at)

def transactionClean(+record: R.NodeExtension) -> {R.NodeExtension.transaction(Stash.clean(record)) == R.NodeExtension.transaction(record) : Nat}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError, +parkedFlight}: {==}

def at(+w: R.World,slot: Nat) -> R.NodeExtension:
  B.get(R.NodeExtension,R.World.extensions(w),slot,B.blank_extension())

def readLength(+w: R.World,+slot: Nat) -> {B.length(R.NodeExtension,R.World.extensions(Frame.observe(w,slot))) == B.length(R.NodeExtension,R.World.extensions(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      eraseLength(extensions,slot)

def readRecord(+w: R.World,+slot: Nat) -> {at(Frame.observe(w,slot),slot) == Stash.clean(at(w,slot)) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      eraseRead(extensions,slot)

def sameLength(+w: R.World,+next: R.World,+slot: Nat,same: {Frame.observe(next,slot) == Frame.observe(w,slot) : R.World}) -> {B.length(R.NodeExtension,R.World.extensions(next)) == B.length(R.NodeExtension,R.World.extensions(w)) : Nat}:
  Equal.trans(Nat,B.length(R.NodeExtension,R.World.extensions(next)),B.length(R.NodeExtension,R.World.extensions(Frame.observe(next,slot))),B.length(R.NodeExtension,R.World.extensions(w)),Equal.sym(Nat,B.length(R.NodeExtension,R.World.extensions(Frame.observe(next,slot))),B.length(R.NodeExtension,R.World.extensions(next)),readLength(next,slot)),Equal.trans(Nat,B.length(R.NodeExtension,R.World.extensions(Frame.observe(next,slot))),B.length(R.NodeExtension,R.World.extensions(Frame.observe(w,slot))),B.length(R.NodeExtension,R.World.extensions(w)),Equal.cong(R.World,Nat,state=>B.length(R.NodeExtension,R.World.extensions(state)),Frame.observe(next,slot),Frame.observe(w,slot),same),readLength(w,slot)))

def sameRecord(+w: R.World,+next: R.World,+slot: Nat,same: {Frame.observe(next,slot) == Frame.observe(w,slot) : R.World}) -> {Stash.clean(at(next,slot)) == Stash.clean(at(w,slot)) : R.NodeExtension}:
  Equal.trans(R.NodeExtension,Stash.clean(at(next,slot)),at(Frame.observe(next,slot),slot),Stash.clean(at(w,slot)),Equal.sym(R.NodeExtension,at(Frame.observe(next,slot),slot),Stash.clean(at(next,slot)),readRecord(next,slot)),Equal.trans(R.NodeExtension,at(Frame.observe(next,slot),slot),at(Frame.observe(w,slot),slot),Stash.clean(at(w,slot)),Equal.cong(R.World,R.NodeExtension,state=>at(state,slot),Frame.observe(next,slot),Frame.observe(w,slot),same),readRecord(w,slot)))

def sameTransactionAt(+w: R.World,+next: R.World,+slot: Nat,same: {Frame.observe(next,slot) == Frame.observe(w,slot) : R.World}) -> {R.NodeExtension.transaction(at(next,slot)) == R.NodeExtension.transaction(at(w,slot)) : Nat}:
  Equal.trans(Nat,R.NodeExtension.transaction(at(next,slot)),R.NodeExtension.transaction(Stash.clean(at(next,slot))),R.NodeExtension.transaction(at(w,slot)),Equal.sym(Nat,R.NodeExtension.transaction(Stash.clean(at(next,slot))),R.NodeExtension.transaction(at(next,slot)),transactionClean(at(next,slot))),Equal.trans(Nat,R.NodeExtension.transaction(Stash.clean(at(next,slot))),R.NodeExtension.transaction(Stash.clean(at(w,slot))),R.NodeExtension.transaction(at(w,slot)),Equal.cong(R.NodeExtension,Nat,record=>R.NodeExtension.transaction(record),Stash.clean(at(next,slot)),Stash.clean(at(w,slot)),sameRecord(w,next,slot,same)),transactionClean(at(w,slot))))

def sameTransaction(+w: R.World,+next: R.World,+id: Nat,pointer: {R.Node.x(B.node(next,id)) == R.Node.x(B.node(w,id)) : Nat},same: {Frame.observe(next,R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}) -> {R.NodeExtension.transaction(B.extension(next,id)) == R.NodeExtension.transaction(B.extension(w,id)) : Nat}:
  +slot = R.Node.x(B.node(w,id))
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(next,id)),R.NodeExtension.transaction(at(next,slot)),R.NodeExtension.transaction(B.extension(w,id)),Equal.cong(Nat,Nat,at=>R.NodeExtension.transaction(B.get(R.NodeExtension,R.World.extensions(next),at,B.blank_extension())),R.Node.x(B.node(next,id)),slot,pointer),sameTransactionAt(w,next,slot,same))

def room(+w: R.World,+next: R.World,+id: Nat,pointer: {R.Node.x(B.node(next,id)) == R.Node.x(B.node(w,id)) : Nat},same: {Frame.observe(next,R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World},valid: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {Nat.is_lt(R.Node.x(B.node(next,id)),B.length(R.NodeExtension,R.World.extensions(next))) == True{} : Bool}:
  +slot = R.Node.x(B.node(w,id))
  Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(next,id)),B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),True{},Equal.cong(Nat,Bool,at=>Nat.is_lt(at,B.length(R.NodeExtension,R.World.extensions(next))),R.Node.x(B.node(next,id)),slot,pointer),Equal.trans(Bool,Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(slot,n),B.length(R.NodeExtension,R.World.extensions(next)),B.length(R.NodeExtension,R.World.extensions(w)),sameLength(w,next,slot,same)),valid))
