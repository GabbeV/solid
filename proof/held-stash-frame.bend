# Full World frame for the source stashFlushed helper. Only this source's
# flushed/flushedAt fields and the unflushedStaged bit are hidden. Other
# extensions, flight/provenance/error/group fields, nodes, queues and fault
# remain visible. A nonzero real extension pointer is required for health.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/read-state.bend as Read
import ./list-update-lookup.bend as ListLens
import ./staging-committed-frame.bend as Stage

def clean(record: R.NodeExtension) -> R.NodeExtension:
  R.NodeExtension.with_flushedAt(R.NodeExtension.with_flushed(record,R.Empty{}),R.Unstamped{})

def flushed(+record: R.NodeExtension,value: R.Slot) -> {clean(R.NodeExtension.with_flushed(record,value)) == clean(record) : R.NodeExtension}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError, +parkedFlight}:
      {==}

def stamp(+record: R.NodeExtension,value: R.Stamp) -> {clean(R.NodeExtension.with_flushedAt(record,value)) == clean(record) : R.NodeExtension}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError, +parkedFlight}:
      {==}

def erase(rows: List<&2,R.NodeExtension>,slot: Nat) -> List<&2,R.NodeExtension>:
  match rows slot:
    case Nil{} at: []
    case head <> tail 0n: clean(head) <> tail
    case head <> tail 1n+at: head <> erase(tail,at)

def eraseSet(+rows: List<&2,R.NodeExtension>,+slot: Nat,+record: R.NodeExtension,known: {clean(record) == clean(B.get(R.NodeExtension,rows,slot,B.blank_extension())) : R.NodeExtension}) -> {erase(List.set(&2,R.NodeExtension,rows,slot,record),slot) == erase(rows,slot) : List<&2,R.NodeExtension>}:
  match rows slot:
    case Nil{} at: {==}
    case +head <> +tail 0n:
      Equal.cong(R.NodeExtension,List<&2,R.NodeExtension>,x=>x <> tail,clean(record),clean(head),known)
    case +head <> +tail 1n+at:
      Equal.cong(List<&2,R.NodeExtension>,List<&2,R.NodeExtension>,xs=>head <> xs,erase(List.set(&2,R.NodeExtension,tail,at,record),at),erase(tail,at),eraseSet(tail,at,record,known))

def observe(+w: R.World,slot: Nat) -> R.World:
  R.World.with_extensions(R.World.with_unflushedStaged(w,False{}),erase(R.World.extensions(w),slot))

def unflushed(+w: R.World,+slot: Nat,value: Bool) -> {observe(R.World.with_unflushedStaged(w,value),slot) == observe(w,slot) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensionPointer(+w: R.World,+id: Nat,record: R.NodeExtension) -> {R.Node.x(B.node(B.store_extension(w,id,record),id)) == R.Node.x(B.node(w,id)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def store(+w: R.World,+id: Nat,+record: R.NodeExtension,known: {clean(record) == clean(B.extension(w,id)) : R.NodeExtension}) -> {observe(B.store_extension(w,id,record),R.Node.x(B.node(w,id))) == observe(w,R.Node.x(B.node(w,id))) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,R.NodeExtension>,R.World,rows=>R.World.with_extensions(R.World.with_unflushedStaged(w,False{}),rows),erase(List.set(&2,R.NodeExtension,extensions,R.Node.x(B.node(w,id)),record),R.Node.x(B.node(w,id))),erase(extensions,R.Node.x(B.node(w,id))),eraseSet(extensions,R.Node.x(B.node(w,id)),record,known))

def movedStore(+w: R.World,+id: Nat,+record: R.NodeExtension,+slot: Nat,+pointer: {R.Node.x(B.node(w,id)) == slot : Nat},known: {clean(record) == clean(B.extension(w,id)) : R.NodeExtension}) -> {observe(B.store_extension(w,id,record),slot) == observe(w,slot) : R.World}:
  +next = B.store_extension(w,id,record)
  +actual = R.Node.x(B.node(w,id))
  Equal.trans(R.World,observe(next,slot),observe(next,actual),observe(w,slot),Equal.cong(Nat,R.World,at=>observe(next,at),slot,actual,Equal.sym(Nat,actual,slot,pointer)),Equal.trans(R.World,observe(next,actual),observe(w,actual),observe(w,slot),store(w,id,record,known),Equal.cong(Nat,R.World,at=>observe(w,at),actual,slot,pointer)))

def tail(+w: R.World,+id: Nat) -> {observe(Stage.stashTail(w,id),R.Node.x(B.node(w,id))) == observe(w,R.Node.x(B.node(w,id))) : R.World}:
  +slot = R.Node.x(B.node(w,id))
  +firstRecord = R.NodeExtension.with_flushed(B.extension(w,id),R.Node.pending(B.node(w,id)))
  +first = B.store_extension(w,id,firstRecord)
  +nextRecord = R.NodeExtension.with_flushedAt(B.extension(first,id),R.Stamped{R.World.clock(first)})
  +next = B.store_extension(first,id,nextRecord)
  Equal.trans(R.World,observe(Stage.stashTail(w,id),slot),observe(next,slot),observe(w,slot),unflushed(next,slot,True{}),Equal.trans(R.World,observe(next,slot),observe(first,slot),observe(w,slot),movedStore(first,id,nextRecord,slot,extensionPointer(w,id,firstRecord),stamp(B.extension(first,id),R.Stamped{R.World.clock(first)})),store(w,id,firstRecord,flushed(B.extension(w,id),R.Node.pending(B.node(w,id))))))

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,+slot: Nat,left: {observe(yes,slot) == observe(w,slot) : R.World},right: {observe(no,slot) == observe(w,slot) : R.World}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no),slot) == observe(w,slot) : R.World}:
  match flag:
    case True{}: left
    case False{}: right

def actual(+w: R.World,+id: Nat,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {observe(Read.stashFlushed(w,id),R.Node.x(B.node(w,id))) == observe(w,R.Node.x(B.node(w,id))) : R.World}:
  +slot = R.Node.x(B.node(w,id))
  +saved = B.choose(~R.World,B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),_=>w,_=>Stage.stashTail(w,id))
  Equal.trans(R.World,observe(Read.stashFlushed(w,id),slot),observe(saved,slot),observe(w,slot),Equal.cong(Bool,R.World,missing=>observe(B.choose(~R.World,missing,_=>R.World.with_fault(w,R.Unsupported{3n}),_=>saved),slot),Nat.is_eq(slot,0n),False{},existing),choice(B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),w,w,Stage.stashTail(w,id),slot,{==},tail(w,id)))
