# Construct the two-entry source/reader admission from initial list/flag/slot
# facts. The first real park is identity; the second rule is transported there.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../proof/held-park-intake.bend as Quiet
import ./parkable-leaf.bend as Leaf
import ./park-admission.bend as A
import ./park-admitted-loop.bend as Loop

def entryAt(-w: R.World,-old: Nat,-new: Nat,-offset: Nat,same: {old == new : Nat},entry: A.Entry<w,old,offset>) -> A.Entry<w,new,offset>:
  %same : A.Entry<w,_,offset>
  entry

def leafAt(-w: R.World,-old: Nat,-new: Nat,-offset: Nat,same: {old == new : Nat},ready: Leaf.Ready<w,old,offset>) -> Leaf.Ready<w,new,offset>:
  %same : Leaf.Ready<w,_,offset>
  ready

def atWorld(-amount: Nat,-old: R.World,-new: R.World,-offset: Nat,-index: Nat,-count: Nat,same: {old == new : R.World},admitted: A.Admitted(amount,old,offset,index,count)) -> A.Admitted(amount,new,offset,index,count):
  %same : A.Admitted(amount,_,offset,index,count)
  admitted

def atCount(-amount: Nat,-w: R.World,-offset: Nat,-index: Nat,-old: Nat,-new: Nat,same: {old == new : Nat},admitted: A.Admitted(amount,w,offset,index,old)) -> A.Admitted(amount,w,offset,index,new):
  %same : A.Admitted(amount,w,offset,index,_)
  admitted

def firstIdentity(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,known: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool}) -> {A.next(w,offset,0n) == w : R.World}:
  +lookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,0n,0n),R.World.pendingNodes(w),[source,reader],known)
  Equal.trans(R.World,A.next(w,offset,0n),S.parkPendingNode(w,source,1n+offset),w,Equal.cong(Nat,R.World,id=>S.parkPendingNode(w,id,1n+offset),B.get(Nat,R.World.pendingNodes(w),0n,0n),source,lookup),Quiet.node(w,source,1n+offset,held,unstaged))

def mixed(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+known: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},+held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},+unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},ready: Leaf.Ready<w,reader,offset>) -> A.Admitted(2n,w,offset,0n,2n):
  +sourceLookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,0n,0n),R.World.pendingNodes(w),[source,reader],known)
  +readerLookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,1n,0n),R.World.pendingNodes(w),[source,reader],known)
  +first = entryAt(w,source,B.get(Nat,R.World.pendingNodes(w),0n,0n),offset,Equal.sym(Nat,B.get(Nat,R.World.pendingNodes(w),0n,0n),source,sourceLookup),A.AlreadyHeld{held,unstaged})
  +second = leafAt(w,reader,B.get(Nat,R.World.pendingNodes(w),1n,0n),offset,Equal.sym(Nat,B.get(Nat,R.World.pendingNodes(w),1n,0n),reader,readerLookup),ready)
  +tail = {B.Bundle{{==},B.Bundle{A.Childless{second},{==}}} : A.Admitted(1n,w,offset,1n,2n)}
  +moved = atWorld(1n,w,A.next(w,offset,0n),offset,1n,2n,Equal.sym(R.World,A.next(w,offset,0n),w,firstIdentity(w,source,reader,offset,known,held,unstaged)),tail)
  B.Bundle{{==},B.Bundle{first,moved}}

def captured(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+known: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},+held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},+unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},ready: Leaf.Ready<w,reader,offset>) -> A.Admitted(2n,w,offset,0n,B.length(Nat,R.World.pendingNodes(w))):
  +size = Equal.cong(List<&2,Nat>,Nat,rows=>B.length(Nat,rows),R.World.pendingNodes(w),[source,reader],known)
  atCount(2n,w,offset,0n,2n,B.length(Nat,R.World.pendingNodes(w)),Equal.sym(Nat,B.length(Nat,R.World.pendingNodes(w)),2n,size),mixed(w,source,reader,offset,known,held,unstaged,ready))

def walked(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+known: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},ready: Leaf.Ready<w,reader,offset>) -> {A.walk(2n,w,offset,0n) == X.holdNode(w,reader,1n+offset) : R.World}:
  +first = Equal.cong(R.World,R.World,state=>A.walk(1n,state,offset,1n),A.next(w,offset,0n),w,firstIdentity(w,source,reader,offset,known,held,unstaged))
  +lookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,1n,0n),R.World.pendingNodes(w),[source,reader],known)
  +second = Equal.cong(Nat,R.World,id=>S.parkPendingNode(w,id,1n+offset),B.get(Nat,R.World.pendingNodes(w),1n,0n),reader,lookup)
  Equal.trans(R.World,A.walk(2n,w,offset,0n),A.walk(1n,w,offset,1n),X.holdNode(w,reader,1n+offset),first,Equal.trans(R.World,A.walk(1n,w,offset,1n),S.parkPendingNode(w,reader,1n+offset),X.holdNode(w,reader,1n+offset),second,Leaf.actual(w,reader,offset,ready)))

def complete(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+known: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},+held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},+unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},+ready: Leaf.Ready<w,reader,offset>,healthy: {B.ok(w) == True{} : Bool}) -> {S.parkPendingNodes(w,1n+offset) == R.World.with_pendingNodes(X.holdNode(w,reader,1n+offset),[]) : R.World}:
  Equal.trans(R.World,S.parkPendingNodes(w,1n+offset),R.World.with_pendingNodes(A.walk(2n,w,offset,0n),[]),R.World.with_pendingNodes(X.holdNode(w,reader,1n+offset),[]),Loop.captured(2n,w,offset,captured(w,source,reader,offset,known,held,unstaged,ready),healthy),Equal.cong(R.World,R.World,state=>R.World.with_pendingNodes(state,[]),A.walk(2n,w,offset,0n),X.holdNode(w,reader,1n+offset),walked(w,source,reader,offset,known,held,unstaged,ready)))
