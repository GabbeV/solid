# The hold observation does not read the ambient flush selector. Prove the
# projection commutation by data lenses, without expanding a constructed graph.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./held-source-view.bend as V
import ./held-hold-view.bend as H

def future(view: V.View,root: Nat) -> V.View:
  match view:
    case V.Source{nodes,links,extensions,comparators,fault,marked,context,old,intos}:
      V.Source{nodes,links,extensions,comparators,fault,marked,context,root,intos}

def observed(+w: R.World,+root: Nat) -> {V.observe(R.World.with_flushTransaction(w,root)) == future(V.observe(w),root) : V.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def node(+view: V.View,+root: Nat,+id: Nat) -> {H.node(future(view,root),id) == H.node(view,id) : R.Node}:
  match view:
    case V.Source{+nodes,+links,+extensions,+comparators,+fault,+marked,+context,+old,+intos}:
      {==}

def extension(+view: V.View,+root: Nat,+id: Nat) -> {H.extension(future(view,root),id) == H.extension(view,id) : R.NodeExtension}:
  match view:
    case V.Source{+nodes,+links,+extensions,+comparators,+fault,+marked,+context,+old,+intos}:
      {==}

def storeNode(+view: V.View,+root: Nat,+id: Nat,+record: R.Node) -> {H.storeNode(future(view,root),id,record) == future(H.storeNode(view,id,record),root) : V.View}:
  match view:
    case V.Source{+nodes,+links,+extensions,+comparators,+fault,+marked,+context,+old,+intos}:
      {==}

def storeExtension(+view: V.View,+root: Nat,+id: Nat,+record: R.NodeExtension) -> {H.storeExtension(future(view,root),id,record) == future(H.storeExtension(view,id,record),root) : V.View}:
  match view:
    case V.Source{+nodes,+links,+extensions,+comparators,+fault,+marked,+context,+old,+intos}:
      {==}

def allocate(+view: V.View,+root: Nat,+id: Nat) -> {H.allocate(future(view,root),id) == future(H.allocate(view,id),root) : V.View}:
  match view:
    case V.Source{+nodes,+links,+extensions,+comparators,+fault,+marked,+context,+old,+intos}:
      {==}

def choice(+flag: Bool,+yes: V.View,+no: V.View,+root: Nat) -> {future(B.choose(~V.View,flag,_=>yes,_=>no),root) == B.choose(~V.View,flag,_=>future(yes,root),_=>future(no,root)) : V.View}:
  match flag:
    case True{}: {==}
    case False{}: {==}

def choices(+flag: Bool,+left: V.View,+right: V.View,+leftNext: V.View,+rightNext: V.View,first: {left == leftNext : V.View},last: {right == rightNext : V.View}) -> {B.choose(~V.View,flag,_=>left,_=>right) == B.choose(~V.View,flag,_=>leftNext,_=>rightNext) : V.View}:
  match flag:
    case True{}: first
    case False{}: last

def ext(+view: V.View,+root: Nat,+id: Nat) -> {H.ext(future(view,root),id) == future(H.ext(view,id),root) : V.View}:
  +flag = Nat.is_ne(R.Node.x(H.node(view,id)),0n)
  +oldFlag = Nat.is_ne(R.Node.x(H.node(future(view,root),id)),0n)
  +left = H.ext(future(view,root),id)
  +middle = B.choose(~V.View,flag,_=>future(view,root),_=>H.allocate(future(view,root),id))
  Equal.trans(V.View,left,middle,future(H.ext(view,id),root),Equal.cong(R.Node,V.View,n=>B.choose(~V.View,Nat.is_ne(R.Node.x(n),0n),_=>future(view,root),_=>H.allocate(future(view,root),id)),H.node(future(view,root),id),H.node(view,id),node(view,root,id)),Equal.trans(V.View,middle,B.choose(~V.View,flag,_=>future(view,root),_=>future(H.allocate(view,id),root)),future(H.ext(view,id),root),choices(flag,future(view,root),H.allocate(future(view,root),id),future(view,root),future(H.allocate(view,id),root),{==},allocate(view,root,id)),Equal.sym(V.View,future(H.ext(view,id),root),B.choose(~V.View,flag,_=>future(view,root),_=>future(H.allocate(view,id),root)),choice(flag,view,H.allocate(view,id),root))))

def listed(+view: V.View,+root: Nat,+id: Nat,+t: Nat) -> {H.listed(future(view,root),id,t) == future(H.listed(view,id,t),root) : V.View}:
  +record = H.extension(view,id)
  +next = H.storeExtension(view,id,R.NodeExtension.with_transaction(record,t))
  +flag = Nat.is_eq(R.NodeExtension.transaction(record),t)
  +middle = B.choose(~V.View,flag,_=>future(view,root),_=>H.storeExtension(future(view,root),id,R.NodeExtension.with_transaction(record,t)))
  Equal.trans(V.View,H.listed(future(view,root),id,t),middle,future(H.listed(view,id,t),root),Equal.cong(R.NodeExtension,V.View,e=>B.choose(~V.View,Nat.is_eq(R.NodeExtension.transaction(e),t),_=>future(view,root),_=>H.storeExtension(future(view,root),id,R.NodeExtension.with_transaction(e,t))),H.extension(future(view,root),id),record,extension(view,root,id)),Equal.trans(V.View,middle,B.choose(~V.View,flag,_=>future(view,root),_=>future(next,root)),future(H.listed(view,id,t),root),choices(flag,future(view,root),H.storeExtension(future(view,root),id,R.NodeExtension.with_transaction(record,t)),future(view,root),future(next,root),{==},storeExtension(view,root,id,R.NodeExtension.with_transaction(record,t))),Equal.sym(V.View,future(H.listed(view,id,t),root),B.choose(~V.View,flag,_=>future(view,root),_=>future(next,root)),choice(flag,view,next,root))))

def list(+view: V.View,+root: Nat,+id: Nat,+t: Nat) -> {H.list(future(view,root),id,t) == future(H.list(view,id,t),root) : V.View}:
  Equal.trans(V.View,H.list(future(view,root),id,t),H.listed(future(H.ext(view,id),root),id,t),future(H.list(view,id,t),root),Equal.cong(V.View,V.View,v=>H.listed(v,id,t),H.ext(future(view,root),id),future(H.ext(view,id),root),ext(view,root,id)),listed(H.ext(view,id),root,id,t))

def hold(+view: V.View,+root: Nat,+id: Nat,+t: Nat) -> {H.hold(future(view,root),id,t) == future(H.hold(view,id,t),root) : V.View}:
  +record = R.Node.with_config(H.node(view,id),B.set(R.Node.config(H.node(view,id)),K.CONFIG_HELD()))
  +middle = H.list(H.storeNode(future(view,root),id,record),id,t)
  Equal.trans(V.View,H.hold(future(view,root),id,t),middle,future(H.hold(view,id,t),root),Equal.cong(R.Node,V.View,n=>H.list(H.storeNode(future(view,root),id,R.Node.with_config(n,B.set(R.Node.config(n),K.CONFIG_HELD()))),id,t),H.node(future(view,root),id),H.node(view,id),node(view,root,id)),Equal.trans(V.View,middle,H.list(future(H.storeNode(view,id,record),root),id,t),future(H.hold(view,id,t),root),Equal.cong(V.View,V.View,v=>H.list(v,id,t),H.storeNode(future(view,root),id,record),future(H.storeNode(view,id,record),root),storeNode(view,root,id,record)),list(H.storeNode(view,id,record),root,id,t)))
