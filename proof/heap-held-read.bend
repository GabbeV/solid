# Fast held-read entry from initial same-flush cache and renderer facts.
# The actual frameRead and joinPass execute; no result premise is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/read-transaction.bend as ReadTx
import ../runtime/constants.bend as K
import ./heap-frame-read.bend as Frame
import ./heap-render-join.bend as Join

def eligible(+w: R.World,+reader: Nat,+id: Nat) -> Bool:
  Bool.and(Nat.is_ne(reader,0n),Bool.and(B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),Bool.and(Bool.not(B.has(R.Node.config(B.node(w,reader)),K.CONFIG_CHILDREN_FORBIDDEN())),True{})))

def decision(+w: R.World,+reader: Nat,+id: Nat,gate: Bool) -> ReadTx.Decision:
  B.choose(~ReadTx.Decision,gate,_=>ReadTx.frameReadDecision(w,reader,id),_=>ReadTx.Decision{w,False{},False{}})

def select(+w: R.World,+reader: Nat,+id: Nat,gate: Bool) -> B.Bundle<R.World,Bool>:
  B.choose(~B.Bundle<R.World,Bool>,gate,_=>ReadTx.frameRead(w,reader,id),_=>B.Bundle{w,False{}})

def finishChoice(+w: R.World,+reader: Nat,+id: Nat,gate: Bool) ->
  {ReadTx.finishDecision(decision(w,reader,id,gate),reader,id) == select(w,reader,id,gate) : B.Bundle<R.World,Bool>}:
  match gate:
    case True{}: {==}
    case False{}: {==}

def shape(+w: R.World,+reader: Nat,+id: Nat) -> {ReadTx.enterRead(w,reader,id,False{}) == select(w,reader,id,eligible(w,reader,id)) : B.Bundle<R.World,Bool>}:
  finishChoice(w,reader,id,eligible(w,reader,id))

def accepted(+w: R.World,+offset: Nat,+id: Nat,+held: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == True{} : Bool},children: {B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_CHILDREN_FORBIDDEN()) == False{} : Bool}) -> {eligible(w,1n+offset,id) == True{} : Bool}:
  +reader = {1n+offset : Nat}
  Equal.trans(Bool,eligible(w,reader,id),Bool.and(True{},Bool.and(Bool.not(B.has(R.Node.config(B.node(w,reader)),K.CONFIG_CHILDREN_FORBIDDEN())),True{})),True{},Equal.cong(Bool,Bool,flag=>Bool.and(flag,Bool.and(Bool.not(B.has(R.Node.config(B.node(w,reader)),K.CONFIG_CHILDREN_FORBIDDEN())),True{})),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),True{},held),Equal.cong(Bool,Bool,flag=>Bool.and(True{},Bool.and(Bool.not(flag),True{})),B.has(R.Node.config(B.node(w,reader)),K.CONFIG_CHILDREN_FORBIDDEN()),False{},children))

def actual(+w: R.World,+offset: Nat,+id: Nat,+root: Nat,+canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},+stopped: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},+current: {R.World.flushTransaction(w) == root : Nat},+ordinary: {R.World.passLane(w) == 0n : Nat},+notVerdict: {B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_VERDICT()) == False{} : Bool},+held: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == True{} : Bool},+children: {B.has(R.Node.config(B.node(w,1n+offset)),K.CONFIG_CHILDREN_FORBIDDEN()) == False{} : Bool},+rendered: {R.Node.kind(B.node(w,1n+offset)) == R.Render{} : R.NodeKind},initialized: {B.has(R.Node.status(B.node(w,id)),K.STATUS_UNINITIALIZED()) == False{} : Bool}) -> {ReadTx.enterRead(w,1n+offset,id,False{}) == B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{Join.marked(w,1n+offset),False{}},_=>B.Bundle{w,False{}}) : B.Bundle<R.World,Bool>}:
  +reader = {1n+offset : Nat}
  +gate = eligible(w,reader,id)
  +yes = Equal.cong(Bool,B.Bundle<R.World,Bool>,flag=>select(w,reader,id,flag),gate,True{},accepted(w,offset,id,held,children))
  +entry = Equal.trans(B.Bundle<R.World,Bool>,ReadTx.enterRead(w,reader,id,False{}),select(w,reader,id,gate),ReadTx.frameRead(w,reader,id),shape(w,reader,id),yes)
  +frame = Frame.actual(w,reader,id,root,canonical,stopped,current,ordinary,notVerdict)
  +joined = Equal.cong(R.World,B.Bundle<R.World,Bool>,world=>B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{world,False{}},_=>B.Bundle{w,False{}}),X.joinPass(w,reader,id),Join.marked(w,reader),Join.render(w,reader,id,rendered,initialized))
  Equal.trans(B.Bundle<R.World,Bool>,ReadTx.enterRead(w,reader,id,False{}),ReadTx.frameRead(w,reader,id),B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{Join.marked(w,reader),False{}},_=>B.Bundle{w,False{}}),entry,
    Equal.trans(B.Bundle<R.World,Bool>,ReadTx.frameRead(w,reader,id),B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{X.joinPass(w,reader,id),False{}},_=>B.Bundle{w,False{}}),B.choose(~B.Bundle<R.World,Bool>,B.ok(w),_=>B.Bundle{Join.marked(w,reader),False{}},_=>B.Bundle{w,False{}}),frame,joined))
