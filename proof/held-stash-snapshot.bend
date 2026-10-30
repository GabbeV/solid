# Snapshot progress requires a valid allocated extension, in addition to the
# nonzero-pointer premise used by the safety frame. Saving an invalid slot is
# never counted as success. The already-current branch is an exact identity.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/read-state.bend as Read
import ./extension-store-lenses.bend as Store
import ./staging-committed-frame.bend as Stage
import ./held-stash-frame.bend as Frame
import ./transaction-resolution.bend as Arithmetic

def cached(+w: R.World,+id: Nat,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool},ready: {B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)) == True{} : Bool}) -> {Read.stashFlushed(w,id) == w : R.World}:
  +saved = B.choose(~R.World,B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),_=>w,_=>Stage.stashTail(w,id))
  Equal.trans(R.World,Read.stashFlushed(w,id),saved,w,Equal.cong(Bool,R.World,missing=>B.choose(~R.World,missing,_=>R.World.with_fault(w,R.Unsupported{3n}),_=>saved),Nat.is_eq(R.Node.x(B.node(w,id)),0n),False{},existing),Equal.cong(Bool,R.World,current=>B.choose(~R.World,current,_=>w,_=>Stage.stashTail(w,id)),B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),True{},ready))

def unflushedRead(+w: R.World,+id: Nat) -> {B.extension(R.World.with_unflushedStaged(w,True{}),id) == B.extension(w,id) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def unflushedClock(+w: R.World) -> {R.World.clock(R.World.with_unflushedStaged(w,True{})) == R.World.clock(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def updated(+w: R.World,+id: Nat) -> R.NodeExtension:
  R.NodeExtension.with_flushedAt(R.NodeExtension.with_flushed(B.extension(w,id),R.Node.pending(B.node(w,id))),R.Stamped{R.World.clock(w)})

def tailWritten(+w: R.World,+id: Nat,+room: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {B.extension(Stage.stashTail(w,id),id) == updated(w,id) : R.NodeExtension}:
  +firstRecord = R.NodeExtension.with_flushed(B.extension(w,id),R.Node.pending(B.node(w,id)))
  +first = B.store_extension(w,id,firstRecord)
  +nextRecord = R.NodeExtension.with_flushedAt(B.extension(first,id),R.Stamped{R.World.clock(first)})
  +next = B.store_extension(first,id,nextRecord)
  Equal.trans(R.NodeExtension,B.extension(Stage.stashTail(w,id),id),B.extension(next,id),updated(w,id),unflushedRead(next,id),Equal.trans(R.NodeExtension,B.extension(next,id),nextRecord,updated(w,id),Store.read(first,id,nextRecord,Store.room(w,id,firstRecord,room)),Equal.trans(R.NodeExtension,nextRecord,R.NodeExtension.with_flushedAt(firstRecord,R.Stamped{R.World.clock(first)}),updated(w,id),Equal.cong(R.NodeExtension,R.NodeExtension,record=>R.NodeExtension.with_flushedAt(record,R.Stamped{R.World.clock(first)}),B.extension(first,id),firstRecord,Store.read(w,id,firstRecord,room)),Equal.cong(Nat,R.NodeExtension,tick=>R.NodeExtension.with_flushedAt(firstRecord,R.Stamped{tick}),R.World.clock(first),R.World.clock(w),Store.clock(w,id,firstRecord)))))

def tailClock(+w: R.World,+id: Nat) -> {R.World.clock(Stage.stashTail(w,id)) == R.World.clock(w) : Nat}:
  +firstRecord = R.NodeExtension.with_flushed(B.extension(w,id),R.Node.pending(B.node(w,id)))
  +first = B.store_extension(w,id,firstRecord)
  +nextRecord = R.NodeExtension.with_flushedAt(B.extension(first,id),R.Stamped{R.World.clock(first)})
  +next = B.store_extension(first,id,nextRecord)
  Equal.trans(Nat,R.World.clock(Stage.stashTail(w,id)),R.World.clock(next),R.World.clock(w),unflushedClock(next),Equal.trans(Nat,R.World.clock(next),R.World.clock(first),R.World.clock(w),Store.clock(first,id,nextRecord),Store.clock(w,id,firstRecord)))

def stampSetter(+record: R.NodeExtension,+stamp: R.Stamp) -> {R.NodeExtension.flushedAt(R.NodeExtension.with_flushedAt(record,stamp)) == stamp : R.Stamp}:
  match record:
    case R.NodeExtension{inFlight,flightTeardown,error,blocked,pendingSources,unobserved,snapshotValue,pendingFirstChild,pendingDisposal,transaction,reask,flushed,flushedAt,q,lane,marks,shownError, +parkedFlight}: {==}

def tailCurrent(+w: R.World,+id: Nat,room: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {B.stampMatches(R.NodeExtension.flushedAt(B.extension(Stage.stashTail(w,id),id)),R.World.clock(Stage.stashTail(w,id))) == True{} : Bool}:
  +after = Stage.stashTail(w,id)
  +tick = R.World.clock(w)
  +slot = R.NodeExtension.with_flushed(B.extension(w,id),R.Node.pending(B.node(w,id)))
  Equal.trans(Bool,B.stampMatches(R.NodeExtension.flushedAt(B.extension(after,id)),R.World.clock(after)),B.stampMatches(R.Stamped{tick},R.World.clock(after)),True{},Equal.cong(R.Stamp,Bool,stamp=>B.stampMatches(stamp,R.World.clock(after)),R.NodeExtension.flushedAt(B.extension(after,id)),R.Stamped{tick},Equal.trans(R.Stamp,R.NodeExtension.flushedAt(B.extension(after,id)),R.NodeExtension.flushedAt(updated(w,id)),R.Stamped{tick},Equal.cong(R.NodeExtension,R.Stamp,record=>R.NodeExtension.flushedAt(record),B.extension(after,id),updated(w,id),tailWritten(w,id,room)),stampSetter(slot,R.Stamped{tick}))),Equal.trans(Bool,B.stampMatches(R.Stamped{tick},R.World.clock(after)),B.stampMatches(R.Stamped{tick},tick),True{},Equal.cong(Nat,Bool,current=>B.stampMatches(R.Stamped{tick},current),R.World.clock(after),tick,tailClock(w,id)),Arithmetic.sameNat(tick)))
