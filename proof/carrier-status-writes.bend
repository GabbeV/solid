# Checked actual status/time/error/blocked writes used by pending notification
# and settlement. The allocated carrier Set is preserved, not re-created.
import Base
import ../runtime/extension.bend as E
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./carrier-field-frame.bend as Field
import ./single-carrier-frame.bend as Single
import ./pending-carrier-state.bend as State
import ./graph-allocation-properties.bend as Storage
import ./pending-one-edge-transport.bend as Transport
import ./pending-carrier-existing.bend as Existing
import ./transaction-list-construction.bend as Extension

def statusX(+node: R.Node,+flags: U32) -> {R.Node.x(R.Node.with_status(node,flags)) == R.Node.x(node) : Nat}:
  match node:
    case R.Node{kind, value, pending, equals, config, flags, status, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      {==}

def timeX(+node: R.Node,+time: Nat) -> {R.Node.x(R.Node.with_time(node,time)) == R.Node.x(node) : Nat}:
  match node:
    case R.Node{kind, value, pending, equals, config, flags, status, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      {==}

def errorPointer(+record: R.NodeExtension,+error: R.Value) -> {R.NodeExtension.pendingSources(R.NodeExtension.with_error(record,error)) == R.NodeExtension.pendingSources(record) : Nat}:
  match record:
    case R.NodeExtension{inFlight, flightTeardown, error, blocked, pendingSources, unobserved, snapshotValue, pendingFirstChild, pendingDisposal, transaction, reask, flushed, flushedAt, q, lane, marks, shownError}:
      {==}

def blockedPointer(+record: R.NodeExtension,+blocked: R.Slot) -> {R.NodeExtension.pendingSources(R.NodeExtension.with_blocked(record,blocked)) == R.NodeExtension.pendingSources(record) : Nat}:
  match record:
    case R.NodeExtension{inFlight, flightTeardown, error, blocked, pendingSources, unobserved, snapshotValue, pendingFirstChild, pendingDisposal, transaction, reask, flushed, flushedAt, q, lane, marks, shownError}:
      {==}

def shownPointer(+record: R.NodeExtension,+error: R.Value) -> {R.NodeExtension.pendingSources(R.NodeExtension.with_shownError(record,error)) == R.NodeExtension.pendingSources(record) : Nat}:
  match record:
    case R.NodeExtension{inFlight, flightTeardown, error, blocked, pendingSources, unobserved, snapshotValue, pendingFirstChild, pendingDisposal, transaction, reask, flushed, flushedAt, q, lane, marks, shownError}:
      {==}

def status(+w: R.World,+node: Nat,+flags: U32) -> Field.Frame<w,B.store_node(w,node,R.Node.with_status(B.node(w,node),flags)),node>:
  Field.node(w,node,R.Node.with_status(B.node(w,node),flags),statusX(B.node(w,node),flags))

def time(+w: R.World,+node: Nat,+time: Nat) -> Field.Frame<w,B.store_node(w,node,R.Node.with_time(B.node(w,node),time)),node>:
  Field.node(w,node,R.Node.with_time(B.node(w,node),time),timeX(B.node(w,node),time))

def error(+w: R.World,+node: Nat,+error: R.Value,fits: {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> Field.Frame<w,B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),error)),node>:
  Field.extension(w,node,R.NodeExtension.with_error(B.extension(w,node),error),errorPointer(B.extension(w,node),error),fits)

def blocked(+w: R.World,+node: Nat,+blocked: R.Slot,fits: {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> Field.Frame<w,B.store_extension(w,node,R.NodeExtension.with_blocked(B.extension(w,node),blocked)),node>:
  Field.extension(w,node,R.NodeExtension.with_blocked(B.extension(w,node),blocked),blockedPointer(B.extension(w,node),blocked),fits)

def providedBranch(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+same: Bool) -> R.World:
  B.choose(~R.World,same,
    _ =>
      +w = E.ext(w,node)
      B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.NotReadyFailure{serial,1n+source})),
    _ => P.preserveOrCreate(w,node,1n+source,R.NodeExtension.error(B.extension(w,node))))

def provided(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+single: Single.Single<w,node,source>) ->
  {P.setPendingError(w,node,1n+source,R.NotReadyFailure{serial,1n+source}) == B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.NotReadyFailure{serial,1n+source})) : R.World}:
  Equal.trans(R.World,P.setPendingError(w,node,1n+source,R.NotReadyFailure{serial,1n+source}),providedBranch(w,node,source,serial,True{}),B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.NotReadyFailure{serial,1n+source})),
    Equal.cong(Bool,R.World,same=>providedBranch(w,node,source,serial,same),Nat.is_eq(1n+source,1n+source),True{},Existing.self(1n+source)),
    Equal.cong(R.World,R.World,next=>B.store_extension(next,node,R.NodeExtension.with_error(B.extension(next,node),R.NotReadyFailure{serial,1n+source})),E.ext(w,node),w,Extension.existing(w,node,Single.allocated(w,node,source,single),Single.pointer(w,node,source,single))))


def extensionNode(+w: R.World,+node: Nat,+record: R.NodeExtension,+read: Nat) -> {B.node(B.store_extension(w,node,record),read) == B.node(w,read) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def emptySnapshot(+w: R.World,+next: R.World,+node: Nat,+source: Nat,+extension: Nat,+sets: List<&2,List<&2,Nat>>,frame: Field.Frame<w,next,node>,allocated: {R.Node.x(B.node(w,node)) == 1n+extension : Nat},room: {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool},empty: {R.NodeExtension.pendingSources(B.extension(w,node)) == 0n : Nat},setArena: {R.World.pendingSets(w) == [] <> sets : List<&2,List<&2,Nat>>}) -> State.CarrierSnapshot<next,node,source>:
  match frame:
    case Field.Frame{x,count,range,pointer,storage}:
      State.CarrierEmpty{extension,sets,Equal.trans(Nat,R.Node.x(B.node(next,node)),R.Node.x(B.node(w,node)),1n+extension,x,allocated),Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(next,node)),B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))),True{},range,room),Equal.trans(Nat,R.NodeExtension.pendingSources(B.extension(next,node)),R.NodeExtension.pendingSources(B.extension(w,node)),0n,pointer,empty),Equal.trans(List<&2,List<&2,Nat>>,R.World.pendingSets(next),R.World.pendingSets(w),[] <> sets,storage,setArena)}

def snapshotStatus(+w: R.World,+node: Nat,+source: Nat,+flags: U32,snapshot: State.CarrierSnapshot<w,node,source>) -> State.CarrierSnapshot<B.store_node(w,node,R.Node.with_status(B.node(w,node),flags)),node,source>:
  match snapshot:
    case State.CarrierFresh{extensions,sets,valid,empty,extensionArena,setArena}:
      +record = R.Node.with_status(B.node(w,node),flags)
      +next = B.store_node(w,node,record)
      State.CarrierFresh{extensions,sets,Transport.valid(w,next,node,Storage.nodeStorage(w,node,record),valid),Equal.trans(Nat,R.Node.x(B.node(next,node)),R.Node.x(B.node(w,node)),0n,Field.nodeX(w,node,record,statusX(B.node(w,node),flags)),empty),Equal.trans(List<&2,R.NodeExtension>,R.World.extensions(next),R.World.extensions(w),B.blank_extension() <> extensions,Field.nodeExtensions(w,node,record),extensionArena),Equal.trans(List<&2,List<&2,Nat>>,R.World.pendingSets(next),R.World.pendingSets(w),[] <> sets,Field.nodeSets(w,node,record),setArena)}
    case State.CarrierEmpty{extension,sets,allocated,room,empty,setArena}:
      +record = R.Node.with_status(B.node(w,node),flags)
      +next = B.store_node(w,node,record)
      emptySnapshot(w,next,node,source,extension,sets,status(w,node,flags),allocated,room,empty,setArena)
    case State.CarrierSingle{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}:
      +record = R.Node.with_status(B.node(w,node),flags)
      +next = B.store_node(w,node,record)
      Single.snapshot(next,node,source,Single.move(w,next,node,source,status(w,node,flags),Single.Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}))
