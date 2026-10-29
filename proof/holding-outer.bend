# Exact non-arena World frame for node membership holding. Fault, lane hooks,
# pending intake, captures, queues and caller context are all retained here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../proof/transaction-list-construction.bend as Listed

def observe(w: R.World) -> R.World:
  R.World.with_nodes(R.World.with_extensions(R.World.with_txArena(w,[]),[]),[])

def storeNode(+w: R.World,id: Nat,record: R.Node) -> {observe(B.store_node(w,id,record)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeExtension(+w: R.World,id: Nat,record: R.NodeExtension) -> {observe(B.store_extension(w,id,record)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeTransaction(+w: R.World,id: Nat,record: R.Transaction) -> {observe(B.store_transaction(w,id,record)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensions(+w: R.World,records: List<&2,R.NodeExtension>) -> {observe(R.World.with_extensions(w,records)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def compose(+w: R.World,+middle: R.World,+next: R.World,left: {observe(next) == observe(middle) : R.World},right: {observe(middle) == observe(w) : R.World}) -> {observe(next) == observe(w) : R.World}:
  Equal.trans(R.World,observe(next),observe(middle),observe(w),left,right)

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : R.World},right: {observe(no) == observe(w) : R.World}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no)) == observe(w) : R.World}:
  match flag:
    case True{}: left
    case False{}: right

def extended(+w: R.World,+id: Nat) -> {observe(E.ext(w,id)) == observe(w) : R.World}:
  +grown = R.World.with_extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))
  +next = B.store_node(grown,id,R.Node.with_x(B.node(grown,id),B.length(R.NodeExtension,R.World.extensions(w))))
  choice(Nat.is_ne(R.Node.x(B.node(w,id)),0n),w,w,next,{==},compose(w,grown,next,storeNode(grown,id,R.Node.with_x(B.node(grown,id),B.length(R.NodeExtension,R.World.extensions(w)))),extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))))

def raw(+w: R.World,+id: Nat,+tx: Nat) -> {observe(Listed.raw(w,id,tx)) == observe(w) : R.World}:
  +next = Listed.capture(w,id,tx)
  compose(w,next,Listed.raw(w,id,tx),storeTransaction(next,tx,R.Transaction.with_nodes(B.transaction(next,tx),B.append(Nat,R.Transaction.nodes(B.transaction(next,tx)),[id]))),storeExtension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),tx)))

def list(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.list(w,id,tx)) == observe(w) : R.World}:
  +next = E.ext(w,id)
  compose(w,next,X.list(w,id,tx),choice(Nat.is_eq(R.NodeExtension.transaction(B.extension(next,id)),tx),next,next,Listed.raw(next,id,tx),{==},raw(next,id,tx)),extended(w,id))

def node(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.holdNode(w,id,tx)) == observe(w) : R.World}:
  +record = R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD()))
  +next = B.store_node(w,id,record)
  compose(w,next,X.holdNode(w,id,tx),list(next,id,tx),storeNode(w,id,record))
