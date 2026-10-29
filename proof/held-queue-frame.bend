# Parking queue stores retain every group field except captured callback arrays,
# and every World field except those arrays' bookkeeping footprint.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../proof/committed-storage-frame.bend as Content
import ./arena-observation-lens.bend as Arena
import ./held-queue-parking.bend as Park

def mask(entry: R.Transaction) -> R.Transaction:
  R.Transaction.with_userQueue(R.Transaction.with_renderQueue(entry,[]),[])

def groups(w: R.World) -> List<&2,R.Transaction>:
  Arena.map(R.Transaction,R.Transaction,mask,R.World.txArena(w))

def fields(w: R.World) -> R.World:
  R.World.with_deferredZombies(R.World.with_userQueue(R.World.with_renderQueue(R.World.with_txArena(w,[]),[]),[]),[])

def store(+w: R.World,+id: Nat,+record: R.Transaction,same: {mask(record) == mask(B.transaction(w,id)) : R.Transaction}) -> {groups(B.store_transaction(w,id,record)) == groups(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.set(R.Transaction,R.Transaction,mask,txArena,id,record,B.blank_transaction(),same)

def render(+entry: R.Transaction,values: List<&2,Nat>) -> {mask(R.Transaction.with_renderQueue(entry,values)) == mask(entry) : R.Transaction}:
  match entry:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def user(+entry: R.Transaction,values: List<&2,R.QueueEntry>) -> {mask(R.Transaction.with_userQueue(entry,values)) == mask(entry) : R.Transaction}:
  match entry:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def stored(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {groups(Park.stored(w,tx,renders,users)) == groups(w) : List<&2,R.Transaction>}:
  +first = B.store_transaction(w,tx,R.Transaction.with_renderQueue(B.transaction(w,tx),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,tx)),renders)))
  Equal.trans(List<&2,R.Transaction>,groups(Park.stored(w,tx,renders,users)),groups(first),groups(w),store(first,tx,R.Transaction.with_userQueue(B.transaction(first,tx),B.append(R.QueueEntry,R.Transaction.userQueue(B.transaction(first,tx)),users)),user(B.transaction(first,tx),B.append(R.QueueEntry,R.Transaction.userQueue(B.transaction(first,tx)),users))),store(w,tx,R.Transaction.with_renderQueue(B.transaction(w,tx),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,tx)),renders)),render(B.transaction(w,tx),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,tx)),renders))))

def world(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {groups(Park.world(w,tx,renders,users)) == groups(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      stored(w,tx,renders,users)

def outer(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {fields(Park.world(w,tx,renders,users)) == fields(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def committed(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {Content.observe(Park.world(w,tx,renders,users)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def read(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,+id: Nat) -> {mask(B.transaction(Park.world(w,tx,renders,users),id)) == mask(B.transaction(w,id)) : R.Transaction}:
  +next = Park.world(w,tx,renders,users)
  Equal.trans(R.Transaction,mask(B.transaction(next,id)),B.get(R.Transaction,groups(next),id,mask(B.blank_transaction())),mask(B.transaction(w,id)),Equal.sym(R.Transaction,B.get(R.Transaction,groups(next),id,mask(B.blank_transaction())),mask(B.transaction(next,id)),Arena.read(R.Transaction,R.Transaction,mask,R.World.txArena(next),id,B.blank_transaction())),Equal.trans(R.Transaction,B.get(R.Transaction,groups(next),id,mask(B.blank_transaction())),B.get(R.Transaction,groups(w),id,mask(B.blank_transaction())),mask(B.transaction(w,id)),Equal.cong(List<&2,R.Transaction>,R.Transaction,rows=>B.get(R.Transaction,rows,id,mask(B.blank_transaction())),groups(next),groups(w),world(w,tx,renders,users)),Arena.read(R.Transaction,R.Transaction,mask,R.World.txArena(w),id,B.blank_transaction())))

def open(+entry: R.Transaction) -> {R.Transaction.open(mask(entry)) == R.Transaction.open(entry) : Nat}:
  match entry:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def count(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,+id: Nat) -> {R.Transaction.open(B.transaction(Park.world(w,tx,renders,users),id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  +next = Park.world(w,tx,renders,users)
  Equal.trans(Nat,R.Transaction.open(B.transaction(next,id)),R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(B.transaction(w,id)),Equal.sym(Nat,R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(B.transaction(next,id)),open(B.transaction(next,id))),Equal.trans(Nat,R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(mask(B.transaction(w,id))),R.Transaction.open(B.transaction(w,id)),Equal.cong(R.Transaction,Nat,entry=>R.Transaction.open(entry),mask(B.transaction(next,id)),mask(B.transaction(w,id)),read(w,tx,renders,users,id)),open(B.transaction(w,id))))
