# Finite actual held setter bodies retain the two sweep-input lists. Heap and
# pending intake may change; their values are intentionally not observed here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../proof/held-write-outer.bend as Outer
import ../proof/held-write-history.bend as History
import ../proof/held-cache-body-input.bend as Input
import ../proof/held-source-cache-rebase.bend as Cache
import ../proof/action-output-frame.bend as Output
import ../proof/action-output-delivery-loop.bend as Loop
import ../proof/action-output-continuation.bend as Queue
import ../proof/action-body-retirement.bend as Exit
import ../runtime/core.bend as C
import ./heap-entry-view.bend as Heap
import ./action-heap-entry.bend as Action
import ./masked-projection.bend as Projection

type View is Data:
  Lists{promoted: List<&2,Nat>,dormant: List<&2,Nat>}

def observe(w: R.World) -> View:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lists{promotedWrites,dormantNodes}

def ofHeap(view: Heap.View) -> View:
  match view:
    case Heap.HeapEntry{promoted,dormant,buckets,minimum,maximum,pending}: Lists{promoted,dormant}

def heapRead(+w: R.World) -> {ofHeap(Heap.observe(w)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromHeap(+before: R.World,+after: R.World,same: {Heap.observe(after) == Heap.observe(before) : Heap.View}) -> {observe(after) == observe(before) : View}:
  Equal.trans(View,observe(after),ofHeap(Heap.observe(after)),observe(before),Equal.sym(View,ofHeap(Heap.observe(after)),observe(after),heapRead(after)),Equal.trans(View,ofHeap(Heap.observe(after)),ofHeap(Heap.observe(before)),observe(before),Equal.cong(Heap.View,View,view=>ofHeap(view),Heap.observe(after),Heap.observe(before),same),heapRead(before)))

def writeMasked(+w: R.World,slot: Nat) -> {observe(Outer.observe(w,slot)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromWrites(+before: R.World,+after: R.World,+slot: Nat,same: {Outer.observe(after,slot) == Outer.observe(before,slot) : R.World}) -> {observe(after) == observe(before) : View}:
  Projection.transportAt(View,Nat,observe,Outer.observe,slot,before,after,same,writeMasked(before,slot),writeMasked(after,slot))

def virtual(+w: R.World,id: Nat,root: Nat) -> {observe(Cache.canonical(w,id,root)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def written(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,input: Input.Input<w,id,offset>) -> {observe(History.run(values,w,id)) == observe(w) : View}:
  match values:
    case Nil{}: {==}
    case +head <> +tail:
      match input:
        case Input.Prepared{source,cached,+profile}:
          +canonical = Cache.canonical(w,id,1n+offset)
          +actual = History.run(head <> tail,w,id)
          +other = History.run(head <> tail,canonical,id)
          Equal.trans(View,observe(actual),observe(other),observe(w),Equal.cong(R.World,View,state=>observe(state),actual,other,Cache.history(w,id,offset,head,tail,source,cached,profile)),Equal.trans(View,observe(other),observe(canonical),observe(w),fromWrites(canonical,other,R.Node.x(B.node(canonical,id)),History.outer(head <> tail,canonical,id,offset,profile)),virtual(w,id,1n+offset)))

def outputMasked(+w: R.World) -> {observe(Output.outer(w)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def jobsMasked(+w: R.World) -> {observe(Loop.outer(w)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def body(+before: R.World,+prepared: R.World,+after: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,+remaining: Nat,input: Input.Input<prepared,id,offset>,initial: {observe(prepared) == observe(before) : View},same: {Output.outer(after) == Output.outer(Exit.target(History.run(values,prepared,id),1n+offset,remaining)) : R.World}) -> {observe(after) == observe(before) : View}:
  +writtenWorld = History.run(values,prepared,id)
  +target = Exit.target(writtenWorld,1n+offset,remaining)
  +actual = Projection.transport(View,observe,Output.outer,target,after,same,outputMasked(target),outputMasked(after))
  Equal.trans(View,observe(after),observe(target),observe(before),actual,Equal.trans(View,observe(target),observe(writtenWorld),observe(before),fromHeap(writtenWorld,target,Action.target(writtenWorld,1n+offset,remaining)),Equal.trans(View,observe(writtenWorld),observe(prepared),observe(before),written(values,prepared,id,offset,input),initial)))

def queued(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>) -> {observe(Queue.world(machine,rest,stack,form)) == observe(C.world(machine)) : View}:
  +next = Queue.world(machine,rest,stack,form)
  Projection.transport(View,observe,Loop.outer,C.world(machine),next,Queue.frame(machine,rest,stack,form),jobsMasked(C.world(machine)),jobsMasked(next))
