# Existing extension-slot lens. Successful storage requires actual membership;
# no out-of-range List.set is presented as an allocation or a saved snapshot.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./node-store-lookup.bend as Store

def node(+w: R.World,+id: Nat,record: R.NodeExtension) -> {B.node(B.store_extension(w,id,record),id) == B.node(w,id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def clock(+w: R.World,+id: Nat,record: R.NodeExtension) -> {R.World.clock(B.store_extension(w,id,record)) == R.World.clock(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def length(+w: R.World,+id: Nat,+record: R.NodeExtension) -> {B.length(R.NodeExtension,R.World.extensions(B.store_extension(w,id,record))) == B.length(R.NodeExtension,R.World.extensions(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Store.lengthSet(R.NodeExtension,extensions,R.Node.x(B.node(w,id)),record)

def read(+w: R.World,+id: Nat,+record: R.NodeExtension,room: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {B.extension(B.store_extension(w,id,record),id) == record : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Store.setSame(R.NodeExtension,extensions,R.Node.x(B.node(w,id)),record,B.blank_extension(),room)

def room(+w: R.World,+id: Nat,+record: R.NodeExtension,valid: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {Nat.is_lt(R.Node.x(B.node(B.store_extension(w,id,record),id)),B.length(R.NodeExtension,R.World.extensions(B.store_extension(w,id,record)))) == True{} : Bool}:
  +next = B.store_extension(w,id,record)
  +slot = R.Node.x(B.node(w,id))
  Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(next,id)),B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),True{},Equal.cong(R.Node,Bool,n=>Nat.is_lt(R.Node.x(n),B.length(R.NodeExtension,R.World.extensions(next))),B.node(next,id),B.node(w,id),node(w,id,record)),Equal.trans(Bool,Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(slot,n),B.length(R.NodeExtension,R.World.extensions(next)),B.length(R.NodeExtension,R.World.extensions(w)),length(w,id,record)),valid))
