# Initial metadata is transported through actual linking/marking; there is no
# successful post-world premise. This is the ordinary same-flush render posture.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/graph-state.bend as G
import ../runtime/transaction.bend as X
import ../runtime/read-transaction.bend as ReadTx
import ./read-entry-metadata.bend as M
import ./heap-frame-read.bend as Frame
import ./heap-held-read.bend as Held
import ./heap-render-join.bend as Join

type Input<-w: R.World,-reader: Nat,-id: Nat,-root: Nat> is Data:
  TrackedReadReady{
    canonical: {R.NodeExtension.transaction(B.extension(w,id)) == root : Nat},
    terminal: {R.Transaction.into(B.transaction(w,root)) == 0n : Nat},
    current: {R.World.flushTransaction(w) == root : Nat},
    ordinary: {R.World.passLane(w) == 0n : Nat},
    notVerdict: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()) == False{} : Bool},
    held: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == True{} : Bool},
    children: {B.has(R.Node.config(B.node(w,reader)),K.CONFIG_CHILDREN_FORBIDDEN()) == False{} : Bool},
    rendered: {R.Node.kind(B.node(w,reader)) == R.Render{} : R.NodeKind},
    initialized: {B.has(R.Node.status(B.node(w,id)),K.STATUS_UNINITIALIZED()) == False{} : Bool},
    healthy: {B.ok(w) == True{} : Bool}}

def transport(+before: R.World,+after: R.World,+reader: Nat,+id: Nat,+root: Nat,
  +sourceSame: {M.node(B.node(after,id)) == M.node(B.node(before,id)) : M.NodeView},
  +readerSame: {M.node(B.node(after,reader)) == M.node(B.node(before,reader)) : M.NodeView},
  +globalSame: {M.globals(after) == M.globals(before) : M.GlobalView},input: Input<before,reader,id,root>) -> Input<after,reader,id,root>:
  match input:
    case TrackedReadReady{canonical,terminal,current,ordinary,notVerdict,held,children,rendered,initialized,healthy}:
      TrackedReadReady{
        Equal.trans(Nat,R.NodeExtension.transaction(B.extension(after,id)),R.NodeExtension.transaction(B.extension(before,id)),root,
          Equal.cong(R.NodeExtension,Nat,R.NodeExtension.transaction,B.extension(after,id),B.extension(before,id),M.sameExtension(after,before,id,globalSame,sourceSame)),canonical),
        Equal.trans(Nat,R.Transaction.into(B.transaction(after,root)),R.Transaction.into(B.transaction(before,root)),0n,
          Equal.cong(R.Transaction,Nat,R.Transaction.into,B.transaction(after,root),B.transaction(before,root),M.sameTransaction(after,before,root,globalSame)),terminal),
        Equal.trans(Nat,R.World.flushTransaction(after),R.World.flushTransaction(before),root,Equal.cong(M.GlobalView,Nat,M.flush,M.globals(after),M.globals(before),globalSame),current),
        Equal.trans(Nat,R.World.passLane(after),R.World.passLane(before),0n,Equal.cong(M.GlobalView,Nat,M.lane,M.globals(after),M.globals(before),globalSame),ordinary),
        Equal.trans(Bool,B.has(R.Node.config(B.node(after,reader)),K.CONFIG_VERDICT()),B.has(R.Node.config(B.node(before,reader)),K.CONFIG_VERDICT()),False{},Equal.cong(M.NodeView,Bool,view=>B.has(M.config(view),K.CONFIG_VERDICT()),M.node(B.node(after,reader)),M.node(B.node(before,reader)),readerSame),notVerdict),
        Equal.trans(Bool,B.has(R.Node.config(B.node(after,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(before,id)),K.CONFIG_HELD()),True{},Equal.cong(M.NodeView,Bool,view=>B.has(M.config(view),K.CONFIG_HELD()),M.node(B.node(after,id)),M.node(B.node(before,id)),sourceSame),held),
        Equal.trans(Bool,B.has(R.Node.config(B.node(after,reader)),K.CONFIG_CHILDREN_FORBIDDEN()),B.has(R.Node.config(B.node(before,reader)),K.CONFIG_CHILDREN_FORBIDDEN()),False{},Equal.cong(M.NodeView,Bool,view=>B.has(M.config(view),K.CONFIG_CHILDREN_FORBIDDEN()),M.node(B.node(after,reader)),M.node(B.node(before,reader)),readerSame),children),
        Equal.trans(R.NodeKind,R.Node.kind(B.node(after,reader)),R.Node.kind(B.node(before,reader)),R.Render{},Equal.cong(M.NodeView,R.NodeKind,M.kind,M.node(B.node(after,reader)),M.node(B.node(before,reader)),readerSame),rendered),
        Equal.trans(Bool,B.has(R.Node.status(B.node(after,id)),K.STATUS_UNINITIALIZED()),B.has(R.Node.status(B.node(before,id)),K.STATUS_UNINITIALIZED()),False{},Equal.cong(M.NodeView,Bool,view=>B.has(M.status(view),K.STATUS_UNINITIALIZED()),M.node(B.node(after,id)),M.node(B.node(before,id)),sourceSame),initialized),
        Equal.trans(Bool,B.ok(after),B.ok(before),True{},M.sameHealthy(after,before,globalSame),healthy)}

def linked(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,input: Input<w,reader,id,root>) -> Input<G.link(w,id,reader),reader,id,root>:
  transport(w,G.link(w,id,reader),reader,id,root,M.linkNode(w,id,reader,id),M.linkNode(w,id,reader,reader),M.linkGlobals(w,id,reader),input)

def marked(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,input: Input<w,reader,id,root>) -> Input<Join.marked(w,reader),reader,id,root>:
  +bits = B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED())
  transport(w,Join.marked(w,reader),reader,id,root,M.flagsNode(w,reader,bits,id),M.flagsNode(w,reader,bits,reader),M.storeGlobals(w,reader,R.Node.with_flags(B.node(w,reader),bits)),input)

def health(-w: R.World,-reader: Nat,-id: Nat,-root: Nat,input: Input<w,reader,id,root>) -> {B.ok(w) == True{} : Bool}:
  match input:
    case TrackedReadReady{canonical,terminal,current,ordinary,notVerdict,held,children,rendered,initialized,healthy}: healthy

def entryShape(+w: R.World,+reader: Nat,+id: Nat) -> {ReadTx.enterReadDecision(w,reader,id,False{}) == Held.decision(w,reader,id,Held.eligible(w,reader,id)) : ReadTx.Decision}:
  {==}

def decision(+w: R.World,+offset: Nat,+id: Nat,+root: Nat,input: Input<w,1n+offset,id,root>) -> {ReadTx.enterReadDecision(w,1n+offset,id,False{}) == ReadTx.Decision{Join.marked(w,1n+offset),False{},False{}} : ReadTx.Decision}:
  match input:
    case TrackedReadReady{canonical,terminal,current,ordinary,notVerdict,held,children,rendered,initialized,healthy}:
      +reader = {1n+offset : Nat}
      +yes = Equal.cong(Bool,ReadTx.Decision,gate=>Held.decision(w,reader,id,gate),Held.eligible(w,reader,id),True{},Held.accepted(w,offset,id,held,children))
      +entry = Equal.trans(ReadTx.Decision,ReadTx.enterReadDecision(w,reader,id,False{}),Held.decision(w,reader,id,Held.eligible(w,reader,id)),ReadTx.frameReadDecision(w,reader,id),entryShape(w,reader,id),yes)
      +frame = Frame.decisionActual(w,reader,id,root,canonical,terminal,current,ordinary,notVerdict)
      +success = Equal.cong(Bool,ReadTx.Decision,ready=>B.choose(~ReadTx.Decision,ready,_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),B.ok(w),True{},healthy)
      +joined = Equal.trans(ReadTx.Decision,ReadTx.frameReadDecision(w,reader,id),B.choose(~ReadTx.Decision,B.ok(w),_=>ReadTx.joined(w,reader,id),_=>ReadTx.Decision{w,False{},False{}}),ReadTx.joined(w,reader,id),frame,success)
      Equal.trans(ReadTx.Decision,ReadTx.enterReadDecision(w,reader,id,False{}),ReadTx.joined(w,reader,id),ReadTx.Decision{Join.marked(w,reader),False{},False{}},
        Equal.trans(ReadTx.Decision,ReadTx.enterReadDecision(w,reader,id,False{}),ReadTx.frameReadDecision(w,reader,id),ReadTx.joined(w,reader,id),entry,joined),
        Equal.cong(R.World,ReadTx.Decision,next=>ReadTx.Decision{next,False{},False{}},X.joinPass(w,reader,id),Join.marked(w,reader),Join.render(w,reader,id,rendered,initialized)))
