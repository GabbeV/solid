# Action capture/method, ambient question/depth/future and all open counts
# survive the real hold/list stores. Source and topology use separate views.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./held-hold-view.bend as H

def opens(rows: List<&2,R.Transaction>) -> List<&2,Nat>:
  match rows:
    case Nil{}: []
    case head <> tail: R.Transaction.open(head) <> opens(tail)

type View is Data:
  Control{actions: List<&2,R.ActionState>,future: Nat,question: R.Question,depth: Nat,counts: List<&2,Nat>}

def observe(+w: R.World) -> View:
  Control{R.World.actions(w),R.World.flushTransaction(w),R.World.question(w),R.World.actionDepth(w),opens(R.World.txArena(w))}

def actions(view: View) -> List<&2,R.ActionState>:
  match view:
    case Control{actions,future,question,depth,counts}: actions

def future(view: View) -> Nat:
  match view:
    case Control{actions,future,question,depth,counts}: future

def counts(view: View) -> List<&2,Nat>:
  match view:
    case Control{actions,future,question,depth,counts}: counts

def choose(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : View},right: {observe(no) == observe(w) : View}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no)) == observe(w) : View}:
  match flag:
    case True{}: left
    case False{}: right

def compose(+w: R.World,+middle: R.World,+next: R.World,last: {observe(next) == observe(middle) : View},first: {observe(middle) == observe(w) : View}) -> {observe(next) == observe(w) : View}:
  Equal.trans(View,observe(next),observe(middle),observe(w),last,first)

def storeNode(+w: R.World,+id: Nat,+record: R.Node) -> {observe(B.store_node(w,id,record)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensions(+w: R.World,+records: List<&2,R.NodeExtension>) -> {observe(R.World.with_extensions(w,records)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeExtension(+w: R.World,+id: Nat,+record: R.NodeExtension) -> {observe(B.store_extension(w,id,record)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def recordOpen(record: R.Transaction,members: List<&2,Nat>) -> {R.Transaction.open(R.Transaction.with_nodes(record,members)) == R.Transaction.open(record) : Nat}:
  match record:
    case R.Transaction{nodes,reruns,renderQueue,userQueue,into,parent,lane,blocked,open,acted,fork,shown,held,marks}: {==}

def storeOpens(+rows: List<&2,R.Transaction>,+id: Nat,+members: List<&2,Nat>) -> {opens(List.set(&2,R.Transaction,rows,id,R.Transaction.with_nodes(B.get(R.Transaction,rows,id,B.blank_transaction()),members))) == opens(rows) : List<&2,Nat>}:
  match rows id:
    case Nil{} at: {==}
    case +head <> +tail 0n:
      Equal.cong(Nat,List<&2,Nat>,n=>n <> opens(tail),R.Transaction.open(R.Transaction.with_nodes(head,members)),R.Transaction.open(head),recordOpen(head,members))
    case +head <> +tail 1n+at:
      Equal.cong(List<&2,Nat>,List<&2,Nat>,ns=>R.Transaction.open(head) <> ns,opens(List.set(&2,R.Transaction,tail,at,R.Transaction.with_nodes(B.get(R.Transaction,tail,at,B.blank_transaction()),members))),opens(tail),storeOpens(tail,at,members))

def transactionNodes(+w: R.World,+t: Nat,+members: List<&2,Nat>) -> {observe(B.store_transaction(w,t,R.Transaction.with_nodes(B.transaction(w,t),members))) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,Nat>,View,ns=>Control{actions,flushTransaction,question,actionDepth,ns},opens(List.set(&2,R.Transaction,txArena,t,R.Transaction.with_nodes(B.get(R.Transaction,txArena,t,B.blank_transaction()),members))),opens(txArena),storeOpens(txArena,t,members))

def allocate(+w: R.World,+id: Nat) -> {observe(H.allocateWorld(w,id)) == observe(w) : View}:
  +next = R.World.with_extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))
  +record = R.Node.with_x(B.node(next,id),B.length(R.NodeExtension,R.World.extensions(w)))
  compose(w,next,H.allocateWorld(w,id),storeNode(next,id,record),extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()])))

def ext(+w: R.World,+id: Nat) -> {observe(E.ext(w,id)) == observe(w) : View}:
  choose(Nat.is_ne(R.Node.x(B.node(w,id)),0n),w,w,H.allocateWorld(w,id),{==},allocate(w,id))

def branch(+w: R.World,+id: Nat,+t: Nat) -> {observe(H.branchWorld(w,id,t)) == observe(w) : View}:
  +record = R.NodeExtension.with_transaction(B.extension(w,id),t)
  +next = B.store_extension(w,id,record)
  compose(w,next,H.branchWorld(w,id,t),transactionNodes(next,t,B.append(Nat,R.Transaction.nodes(B.transaction(next,t)),[id])),storeExtension(w,id,record))

def list(+w: R.World,+id: Nat,+t: Nat) -> {observe(X.list(w,id,t)) == observe(w) : View}:
  +next = E.ext(w,id)
  compose(w,next,X.list(w,id,t),choose(Nat.is_eq(R.NodeExtension.transaction(B.extension(next,id)),t),next,next,H.branchWorld(next,id,t),{==},branch(next,id,t)),ext(w,id))

def hold(+w: R.World,+id: Nat,+t: Nat) -> {observe(X.holdNode(w,id,t)) == observe(w) : View}:
  +record = R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD()))
  +next = B.store_node(w,id,record)
  compose(w,next,X.holdNode(w,id,t),list(next,id,t),storeNode(w,id,record))

def openRead(+rows: List<&2,R.Transaction>,+id: Nat) -> {B.get(Nat,opens(rows),id,0n) == R.Transaction.open(B.get(R.Transaction,rows,id,B.blank_transaction())) : Nat}:
  match rows id:
    case Nil{} at: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+at: openRead(tail,at)

def openCount(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : View}) -> {R.Transaction.open(B.transaction(next,id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(next,id)),B.get(Nat,opens(R.World.txArena(next)),id,0n),R.Transaction.open(B.transaction(w,id)),Equal.sym(Nat,B.get(Nat,opens(R.World.txArena(next)),id,0n),R.Transaction.open(B.transaction(next,id)),openRead(R.World.txArena(next),id)),Equal.trans(Nat,B.get(Nat,opens(R.World.txArena(next)),id,0n),B.get(Nat,opens(R.World.txArena(w)),id,0n),R.Transaction.open(B.transaction(w,id)),Equal.cong(View,Nat,view=>B.get(Nat,counts(view),id,0n),observe(next),observe(w),same),openRead(R.World.txArena(w),id)))
