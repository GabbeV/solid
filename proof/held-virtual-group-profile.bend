# Derive the new virtual held-source certificate from static preservation and
# the actual selected representative's allocation/terminal facts. No cache store
# is performed in the runtime by this proof-only state.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-source-static.bend as V
import ./held-static-operations.bend as Frame
import ./held-profile-retarget.bend as Retarget
import ./held-write-profile.bend as P
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-resume.bend as Resume
import ./held-preparation-source.bend as Source
import ./held-preparation-profile.bend as Selected
import ./extension-store-lenses.bend as Lens

def state(+w: R.World,+id: Nat,+offset: Nat) -> R.World:
  Source.flush(Cache.canonical(w,id,1n+offset),1n+offset)

def extensionRoom(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: extensionRoom

def future(+w: R.World,+root: Nat) -> {R.World.flushTransaction(Source.flush(w,root)) == root : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def arena(+w: R.World,+root: Nat) -> {R.World.txArena(Source.flush(w,root)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def static(+w: R.World,+id: Nat,+offset: Nat) -> {V.observe(state(w,id,offset)) == V.observe(w) : V.View}:
  +middle = Cache.canonical(w,id,1n+offset)
  Frame.compose(w,middle,state(w,id,offset),Frame.flush(middle,1n+offset),Frame.canonical(w,id,1n+offset))

def transactionSet(+record: R.NodeExtension,+root: Nat) -> {R.NodeExtension.transaction(R.NodeExtension.with_transaction(record,root)) == root : Nat}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError, +parkedFlight}:
      {==}

def canonical(+w: R.World,+id: Nat,+offset: Nat,room: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {R.NodeExtension.transaction(B.extension(state(w,id,offset),id)) == 1n+offset : Nat}:
  +root = {1n+offset : Nat}
  +middle = Cache.canonical(w,id,root)
  +record = R.NodeExtension.with_transaction(B.extension(w,id),root)
  Equal.trans(Nat,R.NodeExtension.transaction(B.extension(state(w,id,offset),id)),R.NodeExtension.transaction(B.extension(middle,id)),root,Equal.cong(R.NodeExtension,Nat,value=>R.NodeExtension.transaction(value),B.extension(state(w,id,offset),id),B.extension(middle,id),Resume.flushExtension(middle,root,id)),Equal.trans(Nat,R.NodeExtension.transaction(B.extension(middle,id)),R.NodeExtension.transaction(record),root,Equal.cong(R.NodeExtension,Nat,value=>R.NodeExtension.transaction(value),B.extension(middle,id),record,Lens.read(w,id,record,room)),transactionSet(B.extension(w,id),root)))

def terminal(+w: R.World,+id: Nat,+offset: Nat,stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {R.Transaction.into(B.transaction(state(w,id,offset),1n+offset)) == 0n : Nat}:
  +root = {1n+offset : Nat}
  +middle = Cache.canonical(w,id,root)
  Equal.trans(Nat,R.Transaction.into(B.transaction(state(w,id,offset),root)),R.Transaction.into(B.transaction(middle,root)),0n,Selected.originalTerminal(middle,root),Equal.trans(Nat,R.Transaction.into(B.transaction(middle,root)),R.Transaction.into(B.transaction(w,root)),0n,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.into(B.get(R.Transaction,rows,root,B.blank_transaction())),R.World.txArena(middle),R.World.txArena(w),Cache.arena(w,id,root)),stopped))

def allocated(+w: R.World,+id: Nat,+offset: Nat,room: {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}) -> {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(state(w,id,offset)))) == True{} : Bool}:
  +root = {1n+offset : Nat}
  +middle = Cache.canonical(w,id,root)
  +same = Equal.trans(List<&2,R.Transaction>,R.World.txArena(state(w,id,offset)),R.World.txArena(middle),R.World.txArena(w),arena(middle,root),Cache.arena(w,id,root))
  Equal.trans(Bool,Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(state(w,id,offset)))),Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(w))),True{},Equal.cong(List<&2,R.Transaction>,Bool,rows=>Nat.is_lt(root,B.length(R.Transaction,rows)),R.World.txArena(state(w,id,offset)),R.World.txArena(w),same),room)

def retarget(+w: R.World,+next: R.World,+id: Nat,+oldOffset: Nat,+offset: Nat,+profile: P.Profile<w,id,oldOffset>,+same: {V.observe(next) == V.observe(w) : V.View},stopped: {R.Transaction.into(B.transaction(next,1n+offset)) == 0n : Nat},room: {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(next))) == True{} : Bool}) -> P.Profile<state(next,id,offset),id,offset>:
  +virtual = state(next,id,offset)
  +view = Equal.trans(V.View,V.observe(virtual),V.observe(next),V.observe(w),static(next,id,offset),same)
  +extRoom = Retarget.allocatedRoom(w,next,id,same,extensionRoom(w,id,oldOffset,profile))
  Retarget.retarget(w,virtual,id,oldOffset,offset,profile,view,canonical(next,id,offset,extRoom),future(Cache.canonical(next,id,1n+offset),1n+offset),terminal(next,id,offset,stopped),allocated(next,id,offset,room))
