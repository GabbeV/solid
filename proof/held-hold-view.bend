# Projection of the real hold/list operations. These are proof-only data
# observations, checked against actual stores; no scheduler is substituted.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./held-source-view.bend as V

def node(view: V.View,id: Nat) -> R.Node:
  B.get(R.Node,V.nodes(view),id,B.blank_node())

def extension(+view: V.View,id: Nat) -> R.NodeExtension:
  B.get(R.NodeExtension,V.extensions(view),R.Node.x(node(view,id)),B.blank_extension())

def storeNode(view: V.View,id: Nat,record: R.Node) -> V.View:
  match view:
    case V.Source{+nodes,links,extensions,comparators,fault,marked,context,future,intos}:
      V.Source{List.set(&2,R.Node,nodes,id,record),links,extensions,comparators,fault,marked,context,future,intos}

def storeExtension(view: V.View,id: Nat,record: R.NodeExtension) -> V.View:
  match view:
    case V.Source{+nodes,links,+extensions,comparators,fault,marked,context,future,intos}:
      V.Source{nodes,links,List.set(&2,R.NodeExtension,extensions,R.Node.x(B.get(R.Node,nodes,id,B.blank_node())),record),comparators,fault,marked,context,future,intos}

def allocate(view: V.View,+id: Nat) -> V.View:
  match view:
    case V.Source{+nodes,links,+extensions,comparators,fault,marked,context,future,intos}:
      V.Source{List.set(&2,R.Node,nodes,id,R.Node.with_x(B.get(R.Node,nodes,id,B.blank_node()),B.length(R.NodeExtension,extensions))),links,B.append(R.NodeExtension,extensions,[B.blank_extension()]),comparators,fault,marked,context,future,intos}

def ext(+view: V.View,+id: Nat) -> V.View:
  B.choose(~V.View,Nat.is_ne(R.Node.x(node(view,id)),0n),_=>view,_=>allocate(view,id))

def listed(+view: V.View,+id: Nat,+t: Nat) -> V.View:
  B.choose(~V.View,Nat.is_eq(R.NodeExtension.transaction(extension(view,id)),t),_=>view,_=>storeExtension(view,id,R.NodeExtension.with_transaction(extension(view,id),t)))

def list(view: V.View,+id: Nat,t: Nat) -> V.View:
  listed(ext(view,id),id,t)

def hold(+view: V.View,+id: Nat,t: Nat) -> V.View:
  list(storeNode(view,id,R.Node.with_config(node(view,id),B.set(R.Node.config(node(view,id)),K.CONFIG_HELD()))),id,t)

def nodeObserved(+w: R.World,+id: Nat) -> {B.node(w,id) == node(V.observe(w),id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensionObserved(+w: R.World,+id: Nat) -> {B.extension(w,id) == extension(V.observe(w),id) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def nodeStoreObserved(+w: R.World,+id: Nat,+record: R.Node) -> {V.observe(B.store_node(w,id,record)) == storeNode(V.observe(w),id,record) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensionStoreObserved(+w: R.World,+id: Nat,+record: R.NodeExtension) -> {V.observe(B.store_extension(w,id,record)) == storeExtension(V.observe(w),id,record) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def allocateWorld(+w: R.World,+id: Nat) -> R.World:
  +x = B.length(R.NodeExtension,R.World.extensions(w))
  +next = R.World.with_extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))
  B.store_node(next,id,R.Node.with_x(B.node(next,id),x))

def allocateObserved(+w: R.World,+id: Nat) -> {V.observe(allocateWorld(w,id)) == allocate(V.observe(w),id) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def choice(+flag: Bool,+yes: R.World,+no: R.World,+yv: V.View,+nv: V.View,left: {V.observe(yes) == yv : V.View},right: {V.observe(no) == nv : V.View}) -> {V.observe(B.choose(~R.World,flag,_=>yes,_=>no)) == B.choose(~V.View,flag,_=>yv,_=>nv) : V.View}:
  match flag:
    case True{}: left
    case False{}: right

def extObserved(+w: R.World,+id: Nat) -> {V.observe(E.ext(w,id)) == ext(V.observe(w),id) : V.View}:
  +view = V.observe(w)
  +flag = Nat.is_ne(R.Node.x(B.node(w,id)),0n)
  +added = allocateWorld(w,id)
  Equal.trans(V.View,V.observe(E.ext(w,id)),B.choose(~V.View,flag,_=>view,_=>allocate(view,id)),ext(view,id),choice(flag,w,added,view,allocate(view,id),{==},allocateObserved(w,id)),Equal.cong(R.Node,V.View,n=>B.choose(~V.View,Nat.is_ne(R.Node.x(n),0n),_=>view,_=>allocate(view,id)),B.node(w,id),node(view,id),nodeObserved(w,id)))

def intoNodes(record: R.Transaction,members: List<&2,Nat>) -> {R.Transaction.into(R.Transaction.with_nodes(record,members)) == R.Transaction.into(record) : Nat}:
  match record:
    case R.Transaction{nodes,reruns,renderQueue,userQueue,into,parent,lane,blocked,open,acted,fork,shown,held,marks}: {==}

def intoStore(+rows: List<&2,R.Transaction>,+id: Nat,+nodes: List<&2,Nat>) -> {V.intos(List.set(&2,R.Transaction,rows,id,R.Transaction.with_nodes(B.get(R.Transaction,rows,id,B.blank_transaction()),nodes))) == V.intos(rows) : List<&2,Nat>}:
  match rows id:
    case Nil{} at: {==}
    case +head <> +tail 0n:
      Equal.cong(Nat,List<&2,Nat>,value=>value <> V.intos(tail),R.Transaction.into(R.Transaction.with_nodes(head,nodes)),R.Transaction.into(head),intoNodes(head,nodes))
    case +head <> +tail 1n+at:
      Equal.cong(List<&2,Nat>,List<&2,Nat>,rest=>R.Transaction.into(head) <> rest,V.intos(List.set(&2,R.Transaction,tail,at,R.Transaction.with_nodes(B.get(R.Transaction,tail,at,B.blank_transaction()),nodes))),V.intos(tail),intoStore(tail,at,nodes))

def transactionNodesObserved(+w: R.World,+t: Nat,+members: List<&2,Nat>) -> {V.observe(B.store_transaction(w,t,R.Transaction.with_nodes(B.transaction(w,t),members))) == V.observe(w) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,Nat>,V.View,rows=>V.Source{nodes,links,extensions,comparators,fault,marked,context,flushTransaction,rows},V.intos(List.set(&2,R.Transaction,txArena,t,R.Transaction.with_nodes(B.get(R.Transaction,txArena,t,B.blank_transaction()),members))),V.intos(txArena),intoStore(txArena,t,members))

def branchWorld(+w: R.World,+id: Nat,+t: Nat) -> R.World:
  +next = B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),t))
  B.store_transaction(next,t,R.Transaction.with_nodes(B.transaction(next,t),B.append(Nat,R.Transaction.nodes(B.transaction(next,t)),[id])))

def rawWorld(+w: R.World,+id: Nat,+t: Nat) -> R.World:
  B.choose(~R.World,Nat.is_eq(R.NodeExtension.transaction(B.extension(w,id)),t),_=>w,_=>branchWorld(w,id,t))

def branchObserved(+w: R.World,+id: Nat,+t: Nat) -> {V.observe(branchWorld(w,id,t)) == storeExtension(V.observe(w),id,R.NodeExtension.with_transaction(B.extension(w,id),t)) : V.View}:
  +next = B.store_extension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),t))
  Equal.trans(V.View,V.observe(branchWorld(w,id,t)),V.observe(next),storeExtension(V.observe(w),id,R.NodeExtension.with_transaction(B.extension(w,id),t)),transactionNodesObserved(next,t,B.append(Nat,R.Transaction.nodes(B.transaction(next,t)),[id])),extensionStoreObserved(w,id,R.NodeExtension.with_transaction(B.extension(w,id),t)))

def rawObserved(+w: R.World,+id: Nat,+t: Nat) -> {V.observe(rawWorld(w,id,t)) == listed(V.observe(w),id,t) : V.View}:
  +view = V.observe(w)
  +flag = Nat.is_eq(R.NodeExtension.transaction(B.extension(w,id)),t)
  +changed = storeExtension(view,id,R.NodeExtension.with_transaction(B.extension(w,id),t))
  Equal.trans(V.View,V.observe(rawWorld(w,id,t)),B.choose(~V.View,flag,_=>view,_=>changed),listed(view,id,t),choice(flag,w,branchWorld(w,id,t),view,changed,{==},branchObserved(w,id,t)),Equal.cong(R.NodeExtension,V.View,record=>B.choose(~V.View,Nat.is_eq(R.NodeExtension.transaction(record),t),_=>view,_=>storeExtension(view,id,R.NodeExtension.with_transaction(record,t))),B.extension(w,id),extension(view,id),extensionObserved(w,id)))

def listObserved(+w: R.World,+id: Nat,+t: Nat) -> {V.observe(X.list(w,id,t)) == list(V.observe(w),id,t) : V.View}:
  Equal.trans(V.View,V.observe(X.list(w,id,t)),listed(V.observe(E.ext(w,id)),id,t),list(V.observe(w),id,t),rawObserved(E.ext(w,id),id,t),Equal.cong(V.View,V.View,view=>listed(view,id,t),V.observe(E.ext(w,id)),ext(V.observe(w),id),extObserved(w,id)))

def holdObserved(+w: R.World,+id: Nat,+t: Nat) -> {V.observe(X.holdNode(w,id,t)) == hold(V.observe(w),id,t) : V.View}:
  +record = R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD()))
  +next = B.store_node(w,id,record)
  +view = V.observe(w)
  Equal.trans(V.View,V.observe(X.holdNode(w,id,t)),list(V.observe(next),id,t),hold(view,id,t),listObserved(next,id,t),Equal.trans(V.View,list(V.observe(next),id,t),list(storeNode(view,id,record),id,t),hold(view,id,t),Equal.cong(V.View,V.View,v=>list(v,id,t),V.observe(next),storeNode(view,id,record),nodeStoreObserved(w,id,record)),Equal.cong(R.Node,V.View,n=>list(storeNode(view,id,R.Node.with_config(n,B.set(R.Node.config(n),K.CONFIG_HELD()))),id,t),B.node(w,id),node(view,id),nodeObserved(w,id))))

def congruent(+w: R.World,+next: R.World,+id: Nat,+t: Nat,same: {V.observe(next) == V.observe(w) : V.View}) -> {V.observe(X.holdNode(next,id,t)) == V.observe(X.holdNode(w,id,t)) : V.View}:
  Equal.trans(V.View,V.observe(X.holdNode(next,id,t)),hold(V.observe(next),id,t),V.observe(X.holdNode(w,id,t)),holdObserved(next,id,t),Equal.trans(V.View,hold(V.observe(next),id,t),hold(V.observe(w),id,t),V.observe(X.holdNode(w,id,t)),Equal.cong(V.View,V.View,view=>hold(view,id,t),V.observe(next),V.observe(w),same),Equal.sym(V.View,V.observe(X.holdNode(w,id,t)),hold(V.observe(w),id,t),holdObserved(w,id,t))))
