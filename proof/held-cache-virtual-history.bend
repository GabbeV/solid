# Proof-only virtualization of the actual finite written source state. Empty
# histories retain the input cache; virtualizing its certificate does no store.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-write-profile.bend as P
import ./held-source-cache-rebase.bend as Cache
import ./held-source-cache-body.bend as First
import ./held-write-history.bend as History
import ./transaction-rejoin-history.bend as Alias

def setCurrent(-A: Data,+rows: List<&2,A>,+id: Nat,+fallback: A) -> {List.set(&2,A,rows,id,B.get(A,rows,id,fallback)) == rows : List<&2,A>}:
  match rows id:
    case Nil{} at: {==}
    case head <> tail 0n: {==}
    case +head <> +tail 1n+at:
      Equal.cong(List<&2,A>,List<&2,A>,rest=>head <> rest,List.set(&2,A,tail,at,B.get(A,tail,at,fallback)),tail,setCurrent(A,tail,at,fallback))

def storeSelf(+w: R.World,+id: Nat) -> {B.store_extension(w,id,B.extension(w,id)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,R.NodeExtension>,R.World,rows=>R.World{nodes,links,buckets,minimum,maximum,marked,pendingNodes,trims,renderQueue,userQueue,context,tracking,running,scheduled,clock,epoch,tree,events,fault,unflushedStaged,promotedWrites,rows,cleanupPrograms,dormantNodes,errorSerial,halted,haltNotified,reports,callbackEffect,txArena,transactions,flushTransaction,passTx,passLane,judge,deferredZombies,question,pendingSets,asyncObjects,asyncObservers,hostJobs,syncDepth,streamPlans,iterators,streams,iteratorEvents,awaiters,truthReadHook,truthConfirmedHook,questions,abortInputs,contextKeys,contextRecords,deferredReleases,releaseLists,stale,settledCallbacks,reactions,comparators,actionDepth,actions,actionWaits,arrays,repeats,maps,activeMarks,laneState,verdictState,cleanupError,ambientMarks,deferredArena},List.set(&2,R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),B.get(R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),B.blank_extension())),extensions,setCurrent(R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),B.blank_extension()))

def recordSelf(+record: R.NodeExtension) -> {R.NodeExtension.with_transaction(record,R.NodeExtension.transaction(record)) == record : R.NodeExtension}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError}: {==}

def cached(-w: R.World,-id: Nat,-offset: Nat,profile: P.Profile<w,id,offset>) -> {R.NodeExtension.transaction(B.extension(w,id)) == 1n+offset : Nat}:
  match profile:
    case P.HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: canonical

def identity(+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<w,id,offset>) -> {Cache.canonical(w,id,1n+offset) == w : R.World}:
  +record = B.extension(w,id)
  +same = Equal.trans(R.NodeExtension,R.NodeExtension.with_transaction(record,1n+offset),R.NodeExtension.with_transaction(record,R.NodeExtension.transaction(record)),record,Equal.cong(Nat,R.NodeExtension,n=>R.NodeExtension.with_transaction(record,n),1n+offset,R.NodeExtension.transaction(record),Equal.sym(Nat,R.NodeExtension.transaction(record),1n+offset,cached(w,id,offset,profile))),recordSelf(record))
  Equal.trans(R.World,Cache.canonical(w,id,1n+offset),B.store_extension(w,id,record),w,Equal.cong(R.NodeExtension,R.World,value=>B.store_extension(w,id,value),R.NodeExtension.with_transaction(record,1n+offset),record,same),storeSelf(w,id))

def virtualize(+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> P.Profile<Cache.canonical(w,id,1n+offset),id,offset>:
  Cache.substitute(w,Cache.canonical(w,id,1n+offset),id,offset,Equal.sym(R.World,Cache.canonical(w,id,1n+offset),w,identity(w,id,offset,profile)),profile)

def after(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,+cached: {R.NodeExtension.transaction(B.extension(w,id)) == Alias.identity(w,1n+offset,alias) : Nat},+profile: P.Profile<Cache.canonical(w,id,1n+offset),id,offset>) -> P.Profile<Cache.canonical(History.run(values,w,id),id,1n+offset),id,offset>:
  match values:
    case Nil{}: profile
    case +head <> +tail:
      virtualize(History.run(head <> tail,w,id),id,offset,First.afterProfile(w,head,tail,id,offset,alias,cached,profile))
