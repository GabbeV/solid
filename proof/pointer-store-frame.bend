# All actual extension identities survive heap/stage bookkeeping. This
# strengthens neither the older shape observer nor its allocation domains.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./node-pointer-observation.bend as Pointer

def observe(w: R.World) -> List<&2,Nat>:
  Pointer.observe(w)

def compose(+a: R.World,+b: R.World,+c: R.World,last: {observe(c) == observe(b) : List<&2,Nat>},first: {observe(b) == observe(a) : List<&2,Nat>}) -> {observe(c) == observe(a) : List<&2,Nat>}:
  Pointer.compose(a,b,c,last,first)

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : List<&2,Nat>},right: {observe(no) == observe(w) : List<&2,Nat>}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no)) == observe(w) : List<&2,Nat>}:
  match flag:
    case True{}: left
    case False{}: right

def nodeFlags(+record: R.Node,value: U32) -> {R.Node.x(R.Node.with_flags(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def flags(+w: R.World,+id: Nat,+value: U32) -> {observe(B.store_node(w,id,R.Node.with_flags(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_flags(B.node(w,id),value),nodeFlags(B.node(w,id),value))

def nodeHeight(+record: R.Node,value: Nat) -> {R.Node.x(R.Node.with_height(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def height(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_height(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_height(B.node(w,id),value),nodeHeight(B.node(w,id),value))

def nodeNextHeap(+record: R.Node,value: Nat) -> {R.Node.x(R.Node.with_nextHeap(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def nextHeap(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_nextHeap(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_nextHeap(B.node(w,id),value),nodeNextHeap(B.node(w,id),value))

def nodePrevHeap(+record: R.Node,value: Nat) -> {R.Node.x(R.Node.with_prevHeap(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def prevHeap(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_prevHeap(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_prevHeap(B.node(w,id),value),nodePrevHeap(B.node(w,id),value))

def nodePending(+record: R.Node,value: R.Slot) -> {R.Node.x(R.Node.with_pending(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def pending(+w: R.World,+id: Nat,+value: R.Slot) -> {observe(B.store_node(w,id,R.Node.with_pending(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_pending(B.node(w,id),value),nodePending(B.node(w,id),value))

def nodeNotified(+record: R.Node,value: R.Stamp) -> {R.Node.x(R.Node.with_notified(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def notified(+w: R.World,+id: Nat,+value: R.Stamp) -> {observe(B.store_node(w,id,R.Node.with_notified(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_notified(B.node(w,id),value),nodeNotified(B.node(w,id),value))

def nodeTime(+record: R.Node,value: Nat) -> {R.Node.x(R.Node.with_time(record,value)) == R.Node.x(record) : Nat}:
  match record:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      {==}

def time(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_time(B.node(w,id),value))) == observe(w) : List<&2,Nat>}:
  Pointer.store(w,id,R.Node.with_time(B.node(w,id),value),nodeTime(B.node(w,id),value))

def worldFault(+w: R.World,value: R.Fault) -> {observe(R.World.with_fault(w,value)) == observe(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldMinimum(+w: R.World,value: Nat) -> {observe(R.World.with_minimum(w,value)) == observe(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldMaximum(+w: R.World,value: Nat) -> {observe(R.World.with_maximum(w,value)) == observe(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldBuckets(+w: R.World,value: List<&2,Nat>) -> {observe(R.World.with_buckets(w,value)) == observe(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def schedule(+w: R.World) -> {observe(B.schedule(w)) == observe(w) : List<&2,Nat>}:
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


def storeBucket(+w: R.World,+height: Nat,+id: Nat) -> {observe(B.store_bucket(w,height,id)) == observe(w) : List<&2,Nat>}:
  worldBuckets(w,B.put(Nat,R.World.buckets(w),height,0n,id))
