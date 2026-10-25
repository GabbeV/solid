# All-node status-word observer instantiated with actual state-only operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./node-status-frame.bend as Status
import ./pending-add-frame.bend as Generic


def observe(w: R.World) -> List<&2,U32>:
  Status.observe(w)

def compose(+a: R.World,+b: R.World,+c: R.World,last: {observe(c) == observe(b) : List<&2,U32>},first: {observe(b) == observe(a) : List<&2,U32>}) -> {observe(c) == observe(a) : List<&2,U32>}:
  Equal.trans(List<&2,U32>,observe(c),observe(b),observe(a),last,first)

def choice(+flag: Bool,+w: R.World,+left: R.World,+right: R.World,yes: {observe(left) == observe(w) : List<&2,U32>},no: {observe(right) == observe(w) : List<&2,U32>}) -> {observe(B.choose(~R.World,flag,_=>left,_=>right)) == observe(w) : List<&2,U32>}:
  Generic.choice(List<&2,U32>,state=>observe(state),flag,w,left,right,yes,no)

def firstBoolChoice(+flag: Bool,+w: R.World,+left: B.Bundle<R.World,Bool>,+right: B.Bundle<R.World,Bool>,yes: {observe(B.first(R.World,Bool,left)) == observe(w) : List<&2,U32>},no: {observe(B.first(R.World,Bool,right)) == observe(w) : List<&2,U32>}) -> {observe(B.first(R.World,Bool,B.choose(~B.Bundle<R.World,Bool>,flag,_=>left,_=>right))) == observe(w) : List<&2,U32>}:
  Generic.pairChoice(List<&2,U32>,state=>observe(state),flag,w,left,right,yes,no)

def storeExtension(+w: R.World,+id: Nat,+record: R.NodeExtension) -> {observe(B.store_extension(w,id,record)) == observe(w) : List<&2,U32>}:
  Status.extension(w,id,record)

def storePendingSet(+w: R.World,+set: Nat,+items: List<&2,Nat>) -> {observe(B.store_pendingSet(w,set,items)) == observe(w) : List<&2,U32>}:
  Status.set(w,set,items)

def worldExtensions(+w: R.World,extensions: List<&2,R.NodeExtension>) -> {observe(R.World.with_extensions(w,extensions)) == observe(w) : List<&2,U32>}:
  Status.extensions(w,extensions)

def x(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_x(B.node(w,id),value))) == observe(w) : List<&2,U32>}:
  Status.store(w,id,R.Node.with_x(B.node(w,id),value),Status.statusX(B.node(w,id),value))

def worldErrorSerial(+w: R.World,serial: Nat) -> {observe(R.World.with_errorSerial(w,serial)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldFault(+w: R.World,fault: R.Fault) -> {observe(R.World.with_fault(w,fault)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldTransactions(+w: R.World,transactions: List<&2,Nat>) -> {observe(R.World.with_transactions(w,transactions)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldTxArena(+w: R.World,arena: List<&2,R.Transaction>) -> {observe(R.World.with_txArena(w,arena)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldFlushTransaction(+w: R.World,tx: Nat) -> {observe(R.World.with_flushTransaction(w,tx)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeTransaction(+w: R.World,+tx: Nat,+record: R.Transaction) -> {observe(B.store_transaction(w,tx,record)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def schedule(+w: R.World) -> {observe(B.schedule(w)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running scheduled halted haltNotified syncDepth:
        case _ _ True{} True{} _: {==}
        case _ _ True{} False{} _: {==}
        case _ True{} False{} _ _: {==}
        case True{} False{} False{} _ 0n: {==}
        case True{} False{} False{} _ 1n+p: {==}
        case False{} False{} False{} _ 0n: {==}
        case False{} False{} False{} _ 1n+p: {==}
