# Actor capture and full transaction storage across actual current-group
# preparation. The source-only profile observation is not used to infer debt.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-body-entry.bend as Entry
import ./held-preparation-source.bend as Prepare
import ./held-setter-entry.bend as Join
import ./action-method-store.bend as Method
import ./ordinary-write-outer.bend as Outer

def enterRead(+w: R.World,+actor: Nat) -> {A.get(A.enter(w),actor) == A.get(w,actor) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def preparedStore(+w: R.World,+actor: Nat,+tail: R.Expr) -> {A.store(A.enter(w),actor,R.ActionState.with_methods(A.get(w,actor),tail)) == Method.set(A.enter(w),actor,tail) : R.World}:
  Equal.cong(R.ActionState,R.World,state=>A.store(A.enter(w),actor,R.ActionState.with_methods(state,tail)),A.get(w,actor),A.get(A.enter(w),actor),Equal.sym(R.ActionState,A.get(A.enter(w),actor),A.get(w,actor),enterRead(w,actor)))

def capture(+w: R.World,+actor: Nat,+offset: Nat,+tail: R.Expr,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat}) -> {R.ActionState.transaction(A.get(Entry.prepared(w,actor,tail),actor)) == 1n+offset : Nat}:
  +joined = Entry.joined(w,actor)
  +entered = A.enter(joined)
  +nextCapture = Equal.trans(Nat,R.ActionState.transaction(A.get(joined,actor)),R.ActionState.transaction(A.get(w,actor)),1n+offset,Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,actor,A.blank())),R.World.actions(joined),R.World.actions(w),Entry.actions(w,actor)),captured)
  +enteredCapture = Equal.trans(Nat,R.ActionState.transaction(A.get(entered,actor)),R.ActionState.transaction(A.get(joined,actor)),1n+offset,Equal.cong(R.ActionState,Nat,state=>R.ActionState.transaction(state),A.get(entered,actor),A.get(joined,actor),enterRead(joined,actor)),nextCapture)
  Equal.trans(Nat,R.ActionState.transaction(A.get(Entry.prepared(w,actor,tail),actor)),R.ActionState.transaction(A.get(Method.set(entered,actor,tail),actor)),1n+offset,Equal.cong(R.World,Nat,state=>R.ActionState.transaction(A.get(state,actor)),Entry.prepared(w,actor,tail),Method.set(entered,actor,tail),preparedStore(joined,actor,tail)),Equal.trans(Nat,R.ActionState.transaction(A.get(Method.set(entered,actor,tail),actor)),R.ActionState.transaction(A.get(entered,actor)),1n+offset,Method.capture(entered,actor,tail,Method.valid(entered,actor,offset,enteredCapture)),enteredCapture))

def tailArena(+w: R.World,actor: Nat,tail: R.Expr) -> {R.World.txArena(A.store(A.enter(w),actor,R.ActionState.with_methods(A.get(w,actor),tail))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def questionArena(+w: R.World,question: R.Question) -> {R.World.txArena(R.World.with_question(w,question)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def scheduledArena(+w: R.World) -> {R.World.txArena(Join.scheduled(w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running:
        case True{}: {==}
        case False{}: Outer.sameTxArena(w,B.schedule(w),Outer.schedule(w))

def arena(+w: R.World,+actor: Nat,+offset: Nat,+tail: R.Expr,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {R.World.txArena(Entry.prepared(w,actor,tail)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +joined = Entry.joined(w,actor)
  +asked = Entry.asked(w,actor)
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(Entry.prepared(w,actor,tail)),R.World.txArena(joined),R.World.txArena(w),tailArena(joined,actor,tail),Equal.trans(List<&2,R.Transaction>,R.World.txArena(joined),R.World.txArena(Join.scheduled(asked)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),joined,Join.scheduled(asked),Prepare.joinedCurrent(w,actor,offset,captured,future,terminal)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(Join.scheduled(asked)),R.World.txArena(asked),R.World.txArena(w),scheduledArena(asked),questionArena(w,R.ActionState.question(A.get(w,actor))))))

def flushArena(+w: R.World,root: Nat) -> {R.World.txArena(Prepare.flush(w,root)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def freshArena(+w: R.World,+actor: Nat,+offset: Nat,+tail: R.Expr,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {R.World.txArena(Entry.prepared(w,actor,tail)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +joined = Entry.joined(w,actor)
  +asked = Entry.asked(w,actor)
  +selected = Prepare.flush(asked,1n+offset)
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(Entry.prepared(w,actor,tail)),R.World.txArena(joined),R.World.txArena(w),tailArena(joined,actor,tail),Equal.trans(List<&2,R.Transaction>,R.World.txArena(joined),R.World.txArena(Join.scheduled(selected)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),joined,Join.scheduled(selected),Prepare.joined(w,actor,offset,captured,empty,terminal)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(Join.scheduled(selected)),R.World.txArena(selected),R.World.txArena(w),scheduledArena(selected),Equal.trans(List<&2,R.Transaction>,R.World.txArena(selected),R.World.txArena(asked),R.World.txArena(w),flushArena(asked,1n+offset),questionArena(w,R.ActionState.question(A.get(w,actor)))))))
