# Prepared recomputation installs context/tracking, evaluates the reader body,
# admits the actual signal read, and returns its value to the real Finish frame.
# Public premises describe only the input World, never a successful read state.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/graph-state.bend as G
import ./read-entry-metadata.bend as M
import ./recompute-read-setup.bend as Setup
import ./recompute-read-metadata.bend as Meta
import ./tracked-read-input.bend as I
import ./tracked-held-read.bend as Read
import ./fast-staged-choice.bend as Choice
import ./heap-render-join.bend as Join
import ./signal-read-admission.bend as Admission
import ./action-body-return.bend as Step
import ./pending-stack-history.bend as Steps
import ./core-prefix-compose.bend as Prefix
import ./core-run-prefix.bend as Driver

type Input<-w: R.World,-reader: Nat,-id: Nat,-root: Nat> is Data:
  PreparedRenderRead{held: I.Input<w,reader,id,root>,
    different: {Nat.is_eq(id,reader) == False{} : Bool},
    valid: {B.valid(w,id) == True{} : Bool},
    signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},
    eager: {B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()) == False{} : Bool},
    plain: {R.VerdictState.dispatch(R.World.verdictState(w)) == False{} : Bool},
    flushed: {R.World.unflushedStaged(w) == False{} : Bool},
    noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},
    expression: {R.Node.expr(B.node(w,reader)) == R.Read{id} : R.Expr}}

type Ready<-w: R.World,-reader: Nat,-id: Nat,-root: Nat> is Data:
  ReadAdmitted{held: I.Input<w,reader,id,root>,
    context: {B.parentComputed(w,R.World.context(w)) == reader : Nat},
    tracked: {R.World.tracking(w) == True{} : Bool},
    valid: {B.valid(w,id) == True{} : Bool},
    signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},
    eager: {B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()) == False{} : Bool},
    plain: {R.VerdictState.dispatch(R.World.verdictState(w)) == False{} : Bool},
    flushed: {R.World.unflushedStaged(w) == False{} : Bool},
    noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}}

def observer(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,input: I.Input<w,reader,id,root>,context: {R.World.context(w) == reader : Nat}) -> {B.parentComputed(w,R.World.context(w)) == reader : Nat}:
  match input:
    case I.TrackedReadReady{canonical,terminal,current,ordinary,notVerdict,held,children,rendered,initialized,healthy}:
      Equal.trans(Nat,B.parentComputed(w,R.World.context(w)),B.parentComputed(w,reader),reader,Equal.cong(Nat,Nat,owner=>B.parentComputed(w,owner),R.World.context(w),reader,context),Equal.cong(R.NodeKind,Nat,kind=>B.choose(~Nat,B.root(kind),_=>R.Node.parentComputed(B.node(w,reader)),_=>reader),R.Node.kind(B.node(w,reader)),R.Render{},rendered))

def ready(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,input: Input<w,reader,id,root>) -> Ready<Setup.world(w,reader),reader,id,root>:
  match input:
    case PreparedRenderRead{+held,different,valid,signal,eager,plain,flushed,noOverride,expression}:
      +next = Setup.world(w,reader)
      +source = Meta.source(w,reader,id,different)
      +admitted = Meta.input(w,reader,id,root,held)
      ReadAdmitted{admitted,observer(next,reader,id,root,admitted,Meta.current(w,reader)),Meta.tracked(w,reader),
        Equal.trans(Bool,B.valid(next,id),B.valid(w,id),True{},Equal.cong(Nat,Bool,size=>Bool.and(Nat.is_ne(id,0n),Nat.is_lt(id,size)),B.length(R.Node,R.World.nodes(next)),B.length(R.Node,R.World.nodes(w)),Meta.length(w,reader)),valid),
        Equal.trans(R.NodeKind,R.Node.kind(B.node(next,id)),R.Node.kind(B.node(w,id)),R.Signal{},Equal.cong(R.Node,R.NodeKind,R.Node.kind,B.node(next,id),B.node(w,id),source),signal),
        Equal.trans(Bool,B.has(R.Node.flags(B.node(next,id)),K.REACTIVE_LAZY()),B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_LAZY()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.flags(n),K.REACTIVE_LAZY()),B.node(next,id),B.node(w,id),source),eager),
        Equal.trans(Bool,R.VerdictState.dispatch(R.World.verdictState(next)),R.VerdictState.dispatch(R.World.verdictState(w)),False{},Meta.dispatchSame(w,reader),plain),
        Equal.trans(Bool,R.World.unflushedStaged(next),R.World.unflushedStaged(w),False{},Meta.unflushedSame(w,reader),flushed),
        Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_OVERRIDE()),B.node(next,id),B.node(w,id),source),noOverride)}

def caller(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,reader: Nat,+create: Bool,+released: Nat,lanePass: C.LanePass) -> List<&2,C.Task>:
  C.Finish{Setup.frame(w,reader,create,released,lanePass,stack)} <> rest

def start(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,reader: Nat,+create: Bool,+released: Nat,lanePass: C.LanePass) -> C.Machine:
  C.Machine{w,C.RecomputePrepared{reader,create,released,lanePass} <> rest,stack}

def prepared(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+create: Bool,+released: Nat,lanePass: C.LanePass) -> C.Machine:
  C.Machine{Setup.world(w,reader),C.ReadPrepared{id} <> caller(w,rest,stack,reader,create,released,lanePass),stack}

def target(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+create: Bool,+released: Nat,lanePass: C.LanePass) -> C.Machine:
  Choice.output(Join.marked(G.link(Setup.world(w,reader),id,reader),reader),caller(w,rest,stack,reader,create,released,lanePass),stack,id,reader,M.node(B.node(w,id)))

def entered(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+create: Bool,+released: Nat,lanePass: C.LanePass) -> C.Machine:
  Admission.start(Setup.world(w,reader),caller(w,rest,stack,reader,create,released,lanePass),stack,id,C.passValue(Setup.stored(w,reader),reader))

def entry(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,input: Input<w,reader,id,root>) -> {C.step(start(w,rest,stack,reader,create,released,lanePass)) == entered(w,rest,stack,reader,id,create,released,lanePass) : C.Machine}:
  match input:
    case PreparedRenderRead{held,different,valid,signal,eager,plain,flushed,noOverride,expression}:
      +body = Equal.trans(R.Expr,R.Node.expr(Setup.row(w,reader)),R.Node.expr(B.node(w,reader)),R.Read{id},Meta.expression(B.node(w,reader),R.World.clock(R.World.with_context(w,reader))),expression)
      Equal.trans(C.Machine,C.step(start(w,rest,stack,reader,create,released,lanePass)),C.recomputePrepared(w,rest,stack,reader,create,released,lanePass),entered(w,rest,stack,reader,id,create,released,lanePass),Step.healthyStep(w,C.RecomputePrepared{reader,create,released,lanePass},rest,stack,I.health(w,reader,id,root,held)),Equal.trans(C.Machine,C.recomputePrepared(w,rest,stack,reader,create,released,lanePass),Setup.entered(w,rest,stack,reader,create,released,lanePass),entered(w,rest,stack,reader,id,create,released,lanePass),Setup.actual(w,rest,stack,reader,create,released,lanePass),Equal.cong(R.Expr,C.Machine,expr=>C.Machine{Setup.world(w,reader),C.Evaluate{expr,C.passValue(Setup.stored(w,reader),reader)} <> caller(w,rest,stack,reader,create,released,lanePass),stack},R.Node.expr(Setup.row(w,reader)),R.Read{id},body)))

def admission(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+reader: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,input: Ready<Setup.world(w,reader),reader,id,root>) -> {Steps.iterate(2n,entered(w,rest,stack,reader,id,create,released,lanePass)) == prepared(w,rest,stack,reader,id,create,released,lanePass) : C.Machine}:
  match input:
    case ReadAdmitted{held,context,tracked,valid,signal,eager,plain,flushed,noOverride}:
      Admission.complete(Setup.world(w,reader),caller(w,rest,stack,reader,create,released,lanePass),stack,id,C.passValue(Setup.stored(w,reader),reader),I.health(Setup.world(w,reader),reader,id,root,held),valid,plain,signal,eager)

def read(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,input: Ready<Setup.world(w,1n+offset),1n+offset,id,root>) -> {C.step(prepared(w,rest,stack,1n+offset,id,create,released,lanePass)) == target(w,rest,stack,1n+offset,id,create,released,lanePass) : C.Machine}:
  match input:
    case ReadAdmitted{held,context,tracked,valid,signal,eager,plain,flushed,noOverride}:
      +reader = {1n+offset : Nat}
      +next = Setup.world(w,reader)
      +ending = caller(w,rest,stack,reader,create,released,lanePass)
      +after = Join.marked(G.link(next,id,reader),reader)
      Equal.trans(C.Machine,C.step(prepared(w,rest,stack,reader,id,create,released,lanePass)),Choice.output(after,ending,stack,id,reader,M.node(B.node(next,id))),target(w,rest,stack,reader,id,create,released,lanePass),Read.complete(next,ending,stack,id,offset,root,held,context,tracked,signal,flushed,noOverride),Equal.cong(M.NodeView,C.Machine,meta=>Choice.output(after,ending,stack,id,reader,meta),M.node(B.node(next,id)),M.node(B.node(w,id)),Meta.node(w,reader,id)))

def prefix(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,+input: Input<w,1n+offset,id,root>) -> {Steps.iterate(3n,start(w,rest,stack,1n+offset,create,released,lanePass)) == prepared(w,rest,stack,1n+offset,id,create,released,lanePass) : C.Machine}:
  Prefix.compose(1n,2n,start(w,rest,stack,1n+offset,create,released,lanePass),entered(w,rest,stack,1n+offset,id,create,released,lanePass),prepared(w,rest,stack,1n+offset,id,create,released,lanePass),entry(w,rest,stack,1n+offset,id,root,create,released,lanePass,input),admission(w,rest,stack,1n+offset,id,root,create,released,lanePass,ready(w,1n+offset,id,root,input)))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,+input: Input<w,1n+offset,id,root>) -> {Steps.iterate(4n,start(w,rest,stack,1n+offset,create,released,lanePass)) == target(w,rest,stack,1n+offset,id,create,released,lanePass) : C.Machine}:
  Driver.appendStep(3n,start(w,rest,stack,1n+offset,create,released,lanePass),prepared(w,rest,stack,1n+offset,id,create,released,lanePass),target(w,rest,stack,1n+offset,id,create,released,lanePass),prefix(w,rest,stack,offset,id,root,create,released,lanePass,input),read(w,rest,stack,offset,id,root,create,released,lanePass,ready(w,1n+offset,id,root,input)))

def readGroups(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,input: Ready<Setup.world(w,1n+offset),1n+offset,id,root>) -> {R.World.txArena(C.world(C.step(prepared(w,rest,stack,1n+offset,id,create,released,lanePass)))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match input:
    case ReadAdmitted{held,context,tracked,valid,signal,eager,plain,flushed,noOverride}:
      +reader = {1n+offset : Nat}
      +next = Setup.world(w,reader)
      Equal.trans(List<&2,R.Transaction>,R.World.txArena(C.world(C.step(prepared(w,rest,stack,reader,id,create,released,lanePass)))),R.World.txArena(next),R.World.txArena(w),Read.groups(next,caller(w,rest,stack,reader,create,released,lanePass),stack,id,offset,root,held,context,tracked,signal,flushed,noOverride),Equal.cong(M.GlobalView,List<&2,R.Transaction>,M.groups,M.globals(next),M.globals(w),Meta.globals(w,reader)))

def groups(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+id: Nat,+root: Nat,+create: Bool,+released: Nat,+lanePass: C.LanePass,+input: Input<w,1n+offset,id,root>) -> {R.World.txArena(C.world(Steps.iterate(4n,start(w,rest,stack,1n+offset,create,released,lanePass)))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +before = start(w,rest,stack,1n+offset,create,released,lanePass)
  +prepared = prepared(w,rest,stack,1n+offset,id,create,released,lanePass)
  +iterate = Equal.trans(C.Machine,Steps.iterate(4n,before),C.step(Steps.iterate(3n,before)),C.step(prepared),Driver.iterateSuccessor(3n,before),Equal.cong(C.Machine,C.Machine,C.step,Steps.iterate(3n,before),prepared,prefix(w,rest,stack,offset,id,root,create,released,lanePass,input)))
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(C.world(Steps.iterate(4n,before))),R.World.txArena(C.world(C.step(prepared))),R.World.txArena(w),Equal.cong(C.Machine,List<&2,R.Transaction>,machine=>R.World.txArena(C.world(machine)),Steps.iterate(4n,before),C.step(prepared),iterate),readGroups(w,rest,stack,offset,id,root,create,released,lanePass,ready(w,1n+offset,id,root,input)))
