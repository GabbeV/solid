# Pure names for the existing local storeStatus source segments. These helpers
# carry no invariant proofs; the public operation remains actual storeStatus.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K

def error(serial: Nat, source: Nat) -> R.Value:
  R.NotReadyFailure{serial,1n+source}

def carried(+w: R.World,+node: Nat) -> U32:
  B.choose(~U32,B.has(R.Node.status(B.node(w,node)),K.STATUS_NO_VALUE()),_=>K.STATUS_UNINITIALIZED(),_=>U32.and(R.Node.status(B.node(w,node)),K.STATUS_UNINITIALIZED()))

def flags(w: R.World,node: Nat) -> U32:
  B.set(K.STATUS_PENDING(),carried(w,node))

def statused(+w: R.World,+node: Nat) -> R.World:
  B.store_node(w,node,R.Node.with_status(B.node(w,node),flags(w,node)))

def finish(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> R.World:
  P.setPendingError(statused(w,node),node,1n+source,error(serial,source))

def choice(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,show: Bool) -> R.World:
  +w = B.choose(~R.World,show,_=>B.store_extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),_=>w)
  finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial)

def notified(w: R.World,node: Nat,source: Nat,serial: Nat) -> R.World:
  A.storeStatus(w,node,K.STATUS_PENDING(),error(serial,source))

def statusField(+record: R.Node,+flags: U32) -> {R.Node.status(R.Node.with_status(record,flags)) == flags : U32}:
  match record:
    case R.Node{kind,value,pending,equals,config,flags,status,time,notified,deps,depsTail,depGen,subs,subsTail,height,nextHeap,prevHeap,parent,firstChild,nextSibling,prevSibling,expr,modified,prevValue,target,loading,x,parentComputed,scope,childCount,disposal,cleanup,effectProgram,returnedCleanup,errorProgram}: {==}
