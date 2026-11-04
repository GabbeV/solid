# rc.21 same-flush ordinary frameRead now performs its refused screen branch's
# joinPass itself. Capture/txOf facts still construct the result; no successful
# output or healthy poststate is assumed. Faulted raw states remain explicit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/read-transaction.bend as ReadTx
import ../runtime/constants.bend as K
import ./held-setter-entry.bend as Cache
import ./transaction-resolution.bend as Routes

def cold(+w: R.World,reader: Nat,id: Nat) -> Bool:
  Bool.or(Bool.not(B.has(R.Node.config(B.node(w,reader)),K.CONFIG_FRAME())),B.has(R.Node.config(B.node(w,id)),K.CONFIG_INPUTS_PUBLISHED()))

# Ordinary captured flags make the over/lane-served arms unreachable. The txOf
# result remains live; after it, the same-flush gate precedes bornInto.
def finish(+w: R.World,+reader: Nat,+id: Nat,+t: Nat,same: Bool) -> ReadTx.Decision:
  B.choose(~ReadTx.Decision,same,_=>ReadTx.joined(w,reader,id),
    _=>
      +born = X.bornInto(w,reader,t)
      +w = B.first(R.World,Bool,born)
      B.choose(~ReadTx.Decision,B.second(R.World,Bool,born),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{X.staleReader(w,reader,t),True{},False{}}))

def after(+reader: Nat,+id: Nat,+pair: B.Bundle<R.World,Nat>) -> ReadTx.Decision:
  +w = B.first(R.World,Nat,pair)
  +t = B.second(R.World,Nat,pair)
  finish(w,reader,id,t,Bool.and(Nat.is_eq(t,R.World.flushTransaction(w)),True{}))

def select(+w: R.World,+reader: Nat,+id: Nat,test: Bool) -> ReadTx.Decision:
  B.choose(~ReadTx.Decision,test,_=>ReadTx.joined(w,reader,id),_=>after(reader,id,X.txOf(w,id)))

def ordinaryDecision(+w: R.World,+reader: Nat,+id: Nat,ready: Bool) -> ReadTx.Decision:
  B.choose(~ReadTx.Decision,ready,_=>select(w,reader,id,cold(w,reader,id)),_=>ReadTx.Decision{w,False{},False{}})

def shape(+w: R.World,+reader: Nat,+id: Nat) ->
  {ReadTx.frameReadFlags(w,reader,id,False{},False{}) == ordinaryDecision(w,reader,id,B.ok(w)) : ReadTx.Decision}:
  {==}

def tail(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},current: {R.World.flushTransaction(w) == root : Nat}) ->
  {after(reader,id,X.txOf(w,id)) == ReadTx.joined(w,reader,id) : ReadTx.Decision}:
  +same = Equal.trans(Bool,Nat.is_eq(root,R.World.flushTransaction(w)),Nat.is_eq(root,root),True{},Equal.cong(Nat,Bool,t=>Nat.is_eq(root,t),R.World.flushTransaction(w),root,current),Routes.sameNat(root))
  +gate = Equal.cong(Bool,Bool,test=>Bool.and(test,True{}),Nat.is_eq(root,R.World.flushTransaction(w)),True{},same)
  Equal.trans(ReadTx.Decision,after(reader,id,X.txOf(w,id)),after(reader,id,B.Bundle{w,root}),ReadTx.joined(w,reader,id),Equal.cong(B.Bundle<R.World,Nat>,ReadTx.Decision,pair=>after(reader,id,pair),X.txOf(w,id),B.Bundle{w,root},Cache.txOf(w,id,root,canonical,stopped)),Equal.cong(Bool,ReadTx.Decision,test=>finish(w,reader,id,root,test),Bool.and(Nat.is_eq(root,R.World.flushTransaction(w)),True{}),True{},gate))

def branch(+w: R.World,+reader: Nat,+id: Nat,test: Bool,known: {after(reader,id,X.txOf(w,id)) == ReadTx.joined(w,reader,id) : ReadTx.Decision}) ->
  {select(w,reader,id,test) == ReadTx.joined(w,reader,id) : ReadTx.Decision}:
  match test:
    case True{}: {==}
    case False{}: known

def readyChoice(+w: R.World,+reader: Nat,+id: Nat,+ready: Bool,known: {select(w,reader,id,cold(w,reader,id)) == ReadTx.joined(w,reader,id) : ReadTx.Decision}) ->
  {ordinaryDecision(w,reader,id,ready) == B.choose(~ReadTx.Decision,ready,_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}) : ReadTx.Decision}:
  Equal.cong(ReadTx.Decision,ReadTx.Decision,d=>B.choose(~ReadTx.Decision,ready,_=>d,_=>ReadTx.Decision{w,False{},False{}}),select(w,reader,id,cold(w,reader,id)),ReadTx.joined(w,reader,id),known)

def finishChoice(+w: R.World,+reader: Nat,+id: Nat,ready: Bool) ->
  {ReadTx.finishDecision(B.choose(~ReadTx.Decision,ready,_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),reader,id) == B.choose(~B.Bundle<R.World,Bool>,ready,_=>B.Bundle{X.joinPass(w,reader,id),False{}},_=>B.Bundle{w,False{}}) : B.Bundle<R.World,Bool>}:
  match ready:
    case True{}: {==}
    case False{}: {==}

def decisionActual(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},+stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool}) ->
  {ReadTx.frameReadDecision(w,reader,id) == B.choose(~ReadTx.Decision,B.ok(w),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}) : ReadTx.Decision}:
  +verdict = B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT())
  +lane = Nat.is_ne(R.World.passLane(w),0n)
  +noLane = Equal.cong(Nat,Bool,t=>Nat.is_ne(t,0n),R.World.passLane(w),0n,ordinary)
  +v = Equal.cong(Bool,ReadTx.Decision,flag=>ReadTx.frameReadFlags(w,reader,id,flag,lane),verdict,False{},notVerdict)
  +l = Equal.cong(Bool,ReadTx.Decision,flag=>ReadTx.frameReadFlags(w,reader,id,False{},flag),lane,False{},noLane)
  +flags = Equal.trans(ReadTx.Decision,ReadTx.frameReadDecision(w,reader,id),ReadTx.frameReadFlags(w,reader,id,False{},lane),ReadTx.frameReadFlags(w,reader,id,False{},False{}),v,l)
  +known = branch(w,reader,id,cold(w,reader,id),tail(w,reader,id,root,canonical,stopped,current))
  Equal.trans(ReadTx.Decision,ReadTx.frameReadDecision(w,reader,id),ordinaryDecision(w,reader,id,B.ok(w)),B.choose(~ReadTx.Decision,B.ok(w),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),Equal.trans(ReadTx.Decision,ReadTx.frameReadDecision(w,reader,id),ReadTx.frameReadFlags(w,reader,id,False{},False{}),ordinaryDecision(w,reader,id,B.ok(w)),flags,shape(w,reader,id)),readyChoice(w,reader,id,B.ok(w),known))

def actual(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},+stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool}) ->
  {ReadTx.frameRead(w,reader,id) == B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{X.joinPass(w,reader,id),False{}},_=>B.Bundle{w,False{}}) : B.Bundle<R.World,Bool>}:
  +decision = decisionActual(w,reader,id,root,canonical,stopped,current,ordinary,notVerdict)
  Equal.trans(B.Bundle<R.World,Bool>,ReadTx.frameRead(w,reader,id),ReadTx.finishDecision(B.choose(~ReadTx.Decision,B.ok(w),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),reader,id),B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{X.joinPass(w,reader,id),False{}},_=>B.Bundle{w,False{}}),Equal.cong(ReadTx.Decision,B.Bundle<R.World,Bool>,d=>ReadTx.finishDecision(d,reader,id),ReadTx.frameReadDecision(w,reader,id),B.choose(~ReadTx.Decision,B.ok(w),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),decision),finishChoice(w,reader,id,B.ok(w)))
