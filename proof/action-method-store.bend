# Actual selected actor store. A positive captured group proves actor membership,
# including actor0; identities from the node/group/result arenas are not reused.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./node-store-lookup.bend as Lens
import ./held-source-view.bend as View
import ./held-source-operations.bend as Source

def zeroType(value: Nat) -> Data:
  match value:
    case 0n: Unit
    case 1n+p: Empty

def impossible(-offset: Nat,same: {0n == 1n+offset : Nat}) -> Empty:
  %same : zeroType(_)
  Unit{}

def captureMember(+rows: List<&2,R.ActionState>,+id: Nat,+offset: Nat,known: {R.ActionState.transaction(B.get(R.ActionState,rows,id,A.blank())) == 1n+offset : Nat}) -> {Nat.is_lt(id,B.length(R.ActionState,rows)) == True{} : Bool}:
  match rows id:
    case Nil{} 0n: Empty.absurd({False{} == True{} : Bool},impossible(offset,known))
    case Nil{} 1n+p: Empty.absurd({False{} == True{} : Bool},impossible(offset,known))
    case head <> tail 0n: {==}
    case head <> tail 1n+p: captureMember(tail,p,offset,known)

def valid(+w: R.World,+id: Nat,+offset: Nat,known: {R.ActionState.transaction(A.get(w,id)) == 1n+offset : Nat}) -> {Nat.is_lt(id,B.length(R.ActionState,R.World.actions(w))) == True{} : Bool}:
  captureMember(R.World.actions(w),id,offset,known)

def set(+w: R.World,+actor: Nat,methods: R.Expr) -> R.World:
  A.store(w,actor,R.ActionState.with_methods(A.get(w,actor),methods))

def transactionSetter(+state: R.ActionState,methods: R.Expr) -> {R.ActionState.transaction(R.ActionState.with_methods(state,methods)) == R.ActionState.transaction(state) : Nat}:
  match state:
    case R.ActionState{transaction,question,old,result}: {==}

def methodsSetter(+state: R.ActionState,+methods: R.Expr) -> {R.ActionState.methods(R.ActionState.with_methods(state,methods)) == methods : R.Expr}:
  match state:
    case R.ActionState{transaction,question,old,result}: {==}

def read(+w: R.World,+actor: Nat,+methods: R.Expr,room: {Nat.is_lt(actor,B.length(R.ActionState,R.World.actions(w))) == True{} : Bool}) -> {A.get(set(w,actor,methods),actor) == R.ActionState.with_methods(A.get(w,actor),methods) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.setSame(R.ActionState,actions,actor,R.ActionState.with_methods(A.get(w,actor),methods),A.blank(),room)

def capture(+w: R.World,+actor: Nat,+methods: R.Expr,room: {Nat.is_lt(actor,B.length(R.ActionState,R.World.actions(w))) == True{} : Bool}) -> {R.ActionState.transaction(A.get(set(w,actor,methods),actor)) == R.ActionState.transaction(A.get(w,actor)) : Nat}:
  Equal.trans(Nat,R.ActionState.transaction(A.get(set(w,actor,methods),actor)),R.ActionState.transaction(R.ActionState.with_methods(A.get(w,actor),methods)),R.ActionState.transaction(A.get(w,actor)),Equal.cong(R.ActionState,Nat,state=>R.ActionState.transaction(state),A.get(set(w,actor,methods),actor),R.ActionState.with_methods(A.get(w,actor),methods),read(w,actor,methods,room)),transactionSetter(A.get(w,actor),methods))

def methods(+w: R.World,+actor: Nat,+expr: R.Expr,room: {Nat.is_lt(actor,B.length(R.ActionState,R.World.actions(w))) == True{} : Bool}) -> {R.ActionState.methods(A.get(set(w,actor,expr),actor)) == expr : R.Expr}:
  Equal.trans(R.Expr,R.ActionState.methods(A.get(set(w,actor,expr),actor)),R.ActionState.methods(R.ActionState.with_methods(A.get(w,actor),expr)),expr,Equal.cong(R.ActionState,R.Expr,state=>R.ActionState.methods(state),A.get(set(w,actor,expr),actor),R.ActionState.with_methods(A.get(w,actor),expr),read(w,actor,expr,room)),methodsSetter(A.get(w,actor),expr))

def source(+w: R.World,+actor: Nat,+methods: R.Expr) -> {View.observe(set(w,actor,methods)) == View.observe(w) : View.View}:
  Source.stored(w,actor,R.ActionState.with_methods(A.get(w,actor),methods))

def arena(+w: R.World,actor: Nat,methods: R.Expr) -> {R.World.txArena(set(w,actor,methods)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
