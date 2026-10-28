# Source-only and full storage facts across the actual settleWait store.
# The observer lookup/cell guard is proved separately; no callback result is
# assumed to obtain an input profile or captured alias after this mutation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-first-frame.bend as First
import ./held-source-view.bend as View
import ./held-source-transfer.bend as Transfer
import ./held-write-profile.bend as P
import ./held-preparation-source.bend as Source
import ./transaction-rejoin-history.bend as Alias
import ./transaction-route-rebase.bend as Move

def marked(+w: R.World,observer: Nat) -> R.World:
  First.marked(w,observer)

def source(+w: R.World,+observer: Nat) -> {View.observe(marked(w,observer)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def arena(+w: R.World,+observer: Nat) -> {R.World.txArena(marked(w,observer)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def future(+w: R.World,+observer: Nat) -> {R.World.flushTransaction(marked(w,observer)) == R.World.flushTransaction(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def question(+w: R.World,+observer: Nat) -> {R.World.question(marked(w,observer)) == R.World.question(w) : R.Question}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def selectedSource(+w: R.World,+observer: Nat,+offset: Nat) -> {View.observe(Source.flush(marked(w,observer),1n+offset)) == View.observe(Source.flush(w,1n+offset)) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def profile(+w: R.World,+observer: Nat,+id: Nat,+offset: Nat,initial: P.Profile<w,id,offset>) -> P.Profile<marked(w,observer),id,offset>:
  Transfer.transfer(w,marked(w,observer),id,offset,initial,source(w,observer))

def freshProfile(+w: R.World,+observer: Nat,+id: Nat,+offset: Nat,initial: P.Profile<Source.flush(w,1n+offset),id,offset>) -> P.Profile<Source.flush(marked(w,observer),1n+offset),id,offset>:
  Transfer.transfer(Source.flush(w,1n+offset),Source.flush(marked(w,observer),1n+offset),id,offset,initial,selectedSource(w,observer,offset))

def aliasMoved(+w: R.World,+observer: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> Move.AliasRebased<w,marked(w,observer),1n+offset,alias>:
  Move.moveAlias(w,marked(w,observer),1n+offset,alias,Move.fullArena(w,marked(w,observer),arena(w,observer)))

def markedAlias(+w: R.World,+observer: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> Alias.Alias<marked(w,observer),1n+offset>:
  Move.aliasValue(w,marked(w,observer),1n+offset,alias,aliasMoved(w,observer,offset,alias))

def aliasIdentity(+w: R.World,+observer: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> {Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)) == Alias.identity(w,1n+offset,alias) : Nat}:
  Move.aliasIdentity(w,marked(w,observer),1n+offset,alias,aliasMoved(w,observer,offset,alias))

def positive(+w: R.World,+observer: Nat,+offset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+offset>,known: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}) -> {Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)) == 1n+captureOffset : Nat}:
  Equal.trans(Nat,Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)),Alias.identity(w,1n+offset,alias),1n+captureOffset,aliasIdentity(w,observer,offset,alias),known)

def capture(+w: R.World,+observer: Nat,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,known: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat}) -> {R.ActionState.transaction(A.get(marked(w,observer),actor)) == Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)) : Nat}:
  +sameActor = Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,actor,A.blank())),R.World.actions(marked(w,observer)),R.World.actions(w),First.markedActions(w,observer))
  Equal.trans(Nat,R.ActionState.transaction(A.get(marked(w,observer),actor)),R.ActionState.transaction(A.get(w,actor)),Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)),sameActor,Equal.trans(Nat,R.ActionState.transaction(A.get(w,actor)),Alias.identity(w,1n+offset,alias),Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)),known,Equal.sym(Nat,Alias.identity(marked(w,observer),1n+offset,markedAlias(w,observer,offset,alias)),Alias.identity(w,1n+offset,alias),aliasIdentity(w,observer,offset,alias))))

def methods(+w: R.World,+observer: Nat,+actor: Nat,+method: R.Expr,known: {R.ActionState.methods(A.get(w,actor)) == method : R.Expr}) -> {R.ActionState.methods(A.get(marked(w,observer),actor)) == method : R.Expr}:
  Equal.trans(R.Expr,R.ActionState.methods(A.get(marked(w,observer),actor)),R.ActionState.methods(A.get(w,actor)),method,Equal.cong(List<&2,R.ActionState>,R.Expr,rows=>R.ActionState.methods(B.get(R.ActionState,rows,actor,A.blank())),R.World.actions(marked(w,observer)),R.World.actions(w),First.markedActions(w,observer)),known)

def open(+w: R.World,+observer: Nat,+offset: Nat,+remaining: Nat,known: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {R.Transaction.open(B.transaction(marked(w,observer),1n+offset)) == 1n+remaining : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(marked(w,observer),1n+offset)),R.Transaction.open(B.transaction(w,1n+offset)),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,1n+offset,B.blank_transaction())),R.World.txArena(marked(w,observer)),R.World.txArena(w),arena(w,observer)),known)
