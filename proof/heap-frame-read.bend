# Same-flush ordinary reader entry, from initial cache and posture facts.
# txOf actually runs: the canonical store is proved to be an identity.
# This does not assume an already successful frameRead result.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./held-setter-entry.bend as Cache
import ../runtime/lane-served.bend as Served
import ./transaction-resolution.bend as Routes

def cold(+w: R.World,+reader: Nat,+id: Nat) -> Bool:
  +verdict = B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())
  +lane = Nat.is_ne(R.World.passLane(w),0n)
  Bool.and(Bool.or(Bool.not(lane),Bool.and(B.has(R.Node.status(B.node(w,reader)),K.STATUS_UNINITIALIZED()),B.has(R.Node.status(B.node(w,id)),K.STATUS_PENDING()))),Bool.and(Bool.not(verdict),Bool.or(Bool.not(B.has(R.Node.config(B.node(w,reader)),K.CONFIG_FRAME())),B.has(R.Node.config(B.node(w,id)),K.CONFIG_INPUTS_PUBLISHED()))))

def after(+w: R.World,+reader: Nat,+id: Nat,+pair: B.Bundle<R.World,Nat>,+lane: Bool,+verdict: Bool) -> B.Bundle<R.World,Bool>:
  +w = B.first(R.World,Nat,pair)
  +t = B.second(R.World,Nat,pair)
  B.choose(~B.Bundle<R.World,Bool>,Bool.and(Nat.is_eq(t,R.World.flushTransaction(w)),Bool.and(Bool.not(lane),Bool.not(verdict))),_=>B.Bundle{w,False{}},
    _=>
      +pair = X.bornInto(w,reader,t)
      +w = B.first(R.World,Bool,pair)
      B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,pair),_=>B.Bundle{w,False{}},
        _=>B.Bundle{B.choose(~R.World,Bool.or(lane,verdict),_=>Served.served(X.staleReader(w,reader,t),reader,id),_=>X.staleReader(w,reader,t)),True{}}))

def select(+w: R.World,+reader: Nat,+id: Nat,test: Bool) -> B.Bundle<R.World,Bool>:
  B.choose(~B.Bundle<R.World,Bool>,test,_=>B.Bundle{w,False{}},_=>after(w,reader,id,X.txOf(w,id),Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())))

def shape(+w: R.World,+reader: Nat,+id: Nat) -> {X.frameRead(w,reader,id) == select(w,reader,id,cold(w,reader,id)) : B.Bundle<R.World,Bool>}:
  {==}

def finish(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+lane: Bool,+verdict: Bool,same: Bool) -> B.Bundle<R.World,Bool>:
  B.choose(~B.Bundle<R.World,Bool>,same,_=>B.Bundle{w,False{}},
    _=>
      +pair = X.bornInto(w,reader,root)
      +w = B.first(R.World,Bool,pair)
      B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,pair),_=>B.Bundle{w,False{}},
        _=>B.Bundle{B.choose(~R.World,Bool.or(lane,verdict),_=>Served.served(X.staleReader(w,reader,root),reader,id),_=>X.staleReader(w,reader,root)),True{}}))

def settled(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool}) -> {after(w,reader,id,B.Bundle{w,root},Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())) == B.Bundle{w,False{}} : B.Bundle<R.World,Bool>}:
  +lane = Nat.is_ne(R.World.passLane(w),0n)
  +verdict = B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())
  +noLane = Equal.cong(Nat,Bool,n=>Nat.is_ne(n,0n),R.World.passLane(w),0n,ordinary)
  +laneDone = Equal.cong(Bool,B.Bundle<R.World,Bool>,b=>after(w,reader,id,B.Bundle{w,root},b,verdict),lane,False{},noLane)
  +verdictDone = Equal.cong(Bool,B.Bundle<R.World,Bool>,b=>after(w,reader,id,B.Bundle{w,root},False{},b),verdict,False{},notVerdict)
  +sameRoot = Equal.trans(Bool,Nat.is_eq(root,R.World.flushTransaction(w)),Nat.is_eq(root,root),True{},Equal.cong(Nat,Bool,tx=>Nat.is_eq(root,tx),R.World.flushTransaction(w),root,current),Routes.sameNat(root))
  +gateDone = Equal.cong(Bool,Bool,b=>Bool.and(b,True{}),Nat.is_eq(root,R.World.flushTransaction(w)),True{},sameRoot)
  +rootDone = Equal.cong(Bool,B.Bundle<R.World,Bool>,b=>finish(w,reader,id,root,False{},False{},b),Bool.and(Nat.is_eq(root,R.World.flushTransaction(w)),True{}),True{},gateDone)
  Equal.trans(B.Bundle<R.World,Bool>,after(w,reader,id,B.Bundle{w,root},lane,verdict),after(w,reader,id,B.Bundle{w,root},False{},verdict),B.Bundle{w,False{}},laneDone,Equal.trans(B.Bundle<R.World,Bool>,after(w,reader,id,B.Bundle{w,root},False{},verdict),after(w,reader,id,B.Bundle{w,root},False{},False{}),B.Bundle{w,False{}},verdictDone,rootDone))

def tail(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},+stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool}) -> {after(w,reader,id,X.txOf(w,id),Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())) == B.Bundle{w,False{}} : B.Bundle<R.World,Bool>}:
  Equal.trans(B.Bundle<R.World,Bool>,after(w,reader,id,X.txOf(w,id),Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())),after(w,reader,id,B.Bundle{w,root},Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())),B.Bundle{w,False{}},Equal.cong(B.Bundle<R.World,Nat>,B.Bundle<R.World,Bool>,pair=>after(w,reader,id,pair,Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())),X.txOf(w,id),B.Bundle{w,root},Cache.txOf(w,id,root,canonical,stopped)),settled(w,reader,id,root,current,ordinary,notVerdict))

def branch(+w: R.World,+reader: Nat,+id: Nat,+test: Bool,known: {after(w,reader,id,X.txOf(w,id),Nat.is_ne(R.World.passLane(w),0n),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())) == B.Bundle{w,False{}} : B.Bundle<R.World,Bool>}) -> {select(w,reader,id,test) == B.Bundle{w,False{}} : B.Bundle<R.World,Bool>}:
  match test:
    case True{}: {==}
    case False{}: known

def actual(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},+stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool}) -> {X.frameRead(w,reader,id) == B.Bundle{w,False{}} : B.Bundle<R.World,Bool>}:
  Equal.trans(B.Bundle<R.World,Bool>,X.frameRead(w,reader,id),select(w,reader,id,cold(w,reader,id)),B.Bundle{w,False{}},shape(w,reader,id),branch(w,reader,id,cold(w,reader,id),tail(w,reader,id,root,canonical,stopped,current,ordinary,notVerdict)))
