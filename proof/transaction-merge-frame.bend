# A real distinct-root merge only changes arena records and the live group list.
# Full surrounding World is retained. Redirect/count/owned-list semantics are
# separate exact transaction-pair contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./transaction-pair.bend as Pair
import ./held-source-static.bend as V

def observe(w: R.World) -> R.World:
  R.World.with_transactions(R.World.with_txArena(w,[]),[])

def after(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool) -> {observe(Pair.after(w,prefix,left,gap,right,suffix,reverse)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def merged(+w: R.World,+prefix: List<&2,R.Transaction>,+left: R.Transaction,+gap: List<&2,R.Transaction>,+right: R.Transaction,+suffix: List<&2,R.Transaction>,+reverse: Bool) -> {observe(Pair.merged(w,prefix,left,gap,right,suffix,reverse)) == observe(w) : R.World}:
  Equal.trans(R.World,observe(Pair.merged(w,prefix,left,gap,right,suffix,reverse)),observe(Pair.after(w,prefix,left,gap,right,suffix,reverse)),observe(w),Equal.cong(R.World,R.World,state=>observe(state),Pair.merged(w,prefix,left,gap,right,suffix,reverse),Pair.after(w,prefix,left,gap,right,suffix,reverse),Pair.merge(w,prefix,left,gap,right,suffix,reverse)),after(w,prefix,left,gap,right,suffix,reverse))

def actionObserved(+w: R.World,+id: Nat) -> {A.get(observe(w),id) == A.get(w,id) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def action(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : R.World}) -> {A.get(next,id) == A.get(w,id) : R.ActionState}:
  Equal.trans(R.ActionState,A.get(next,id),A.get(observe(next),id),A.get(w,id),Equal.sym(R.ActionState,A.get(observe(next),id),A.get(next,id),actionObserved(next,id)),Equal.trans(R.ActionState,A.get(observe(next),id),A.get(observe(w),id),A.get(w,id),Equal.cong(R.World,R.ActionState,state=>A.get(state,id),observe(next),observe(w),same),actionObserved(w,id)))

def extensionObserved(+w: R.World,+id: Nat) -> {B.extension(observe(w),id) == B.extension(w,id) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extension(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : R.World}) -> {B.extension(next,id) == B.extension(w,id) : R.NodeExtension}:
  Equal.trans(R.NodeExtension,B.extension(next,id),B.extension(observe(next),id),B.extension(w,id),Equal.sym(R.NodeExtension,B.extension(observe(next),id),B.extension(next,id),extensionObserved(next,id)),Equal.trans(R.NodeExtension,B.extension(observe(next),id),B.extension(observe(w),id),B.extension(w,id),Equal.cong(R.World,R.NodeExtension,state=>B.extension(state,id),observe(next),observe(w),same),extensionObserved(w,id)))

def futureObserved(+w: R.World) -> {R.World.flushTransaction(observe(w)) == R.World.flushTransaction(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def future(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.flushTransaction(next) == R.World.flushTransaction(w) : Nat}:
  Equal.trans(Nat,R.World.flushTransaction(next),R.World.flushTransaction(observe(next)),R.World.flushTransaction(w),Equal.sym(Nat,R.World.flushTransaction(observe(next)),R.World.flushTransaction(next),futureObserved(next)),Equal.trans(Nat,R.World.flushTransaction(observe(next)),R.World.flushTransaction(observe(w)),R.World.flushTransaction(w),Equal.cong(R.World,Nat,state=>R.World.flushTransaction(state),observe(next),observe(w),same),futureObserved(w)))

def staticObserved(+w: R.World) -> {V.observe(observe(w)) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def static(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {V.observe(next) == V.observe(w) : V.View}:
  Equal.trans(V.View,V.observe(next),V.observe(observe(next)),V.observe(w),Equal.sym(V.View,V.observe(observe(next)),V.observe(next),staticObserved(next)),Equal.trans(V.View,V.observe(observe(next)),V.observe(observe(w)),V.observe(w),Equal.cong(R.World,V.View,state=>V.observe(state),observe(next),observe(w),same),staticObserved(w)))

def captureValue(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : R.World}) -> {R.ActionState.transaction(A.get(next,id)) == R.ActionState.transaction(A.get(w,id)) : Nat}:
  Equal.cong(R.ActionState,Nat,state=>R.ActionState.transaction(state),A.get(next,id),A.get(w,id),action(w,next,id,same))

def methodsValue(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : R.World}) -> {R.ActionState.methods(A.get(next,id)) == R.ActionState.methods(A.get(w,id)) : R.Expr}:
  Equal.cong(R.ActionState,R.Expr,state=>R.ActionState.methods(state),A.get(next,id),A.get(w,id),action(w,next,id,same))
