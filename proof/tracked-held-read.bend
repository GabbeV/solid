# Actual prepared-signal instruction through tracked linking, held entry and
# scalar selection. All intermediate admission and health facts are derived.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/graph-state.bend as G
import ../runtime/read-transaction.bend as ReadTx
import ./read-entry-metadata.bend as M
import ./tracked-read-input.bend as I
import ./heap-render-join.bend as Join
import ./fast-staged-choice.bend as Choice
import ./action-body-return.bend as Step

def finish(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+reader: Nat,healthy: {B.ok(w) == True{} : Bool}) -> {C.readDecision(rest,stack,id,reader,False{},ReadTx.Decision{w,False{},False{}}) == C.readFastEntered(w,rest,stack,id,reader,False{}) : C.Machine}:
  Equal.cong(Bool,C.Machine,ready=>B.choose(~C.Machine,ready,_=>C.readFastEntered(w,rest,stack,id,reader,False{}),_=>C.Machine{w,rest,stack}),B.ok(w),True{},healthy)

def enteredReady(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>,next: I.Input<Join.marked(w,1n+offset),1n+offset,id,root>) -> {C.readDecision(rest,stack,id,1n+offset,False{},ReadTx.enterReadDecision(w,1n+offset,id,False{})) == Choice.output(Join.marked(w,1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))) : C.Machine}:
  match next:
    case I.TrackedReadReady{canonical,terminal,current,ordinary,+notVerdict,held,+children,rendered,initialized,+healthy}:
      +reader = {1n+offset : Nat}
      +after = Join.marked(w,reader)
      +entry = Equal.cong(ReadTx.Decision,C.Machine,decision=>C.readDecision(rest,stack,id,reader,False{},decision),ReadTx.enterReadDecision(w,reader,id,False{}),ReadTx.Decision{after,False{},False{}},I.decision(w,offset,id,root,input))
      +selected = Equal.trans(C.Machine,C.readDecision(rest,stack,id,reader,False{},ReadTx.Decision{after,False{},False{}}),C.readFastEntered(after,rest,stack,id,reader,False{}),Choice.output(after,rest,stack,id,reader,M.node(B.node(after,id))),finish(after,rest,stack,id,reader,healthy),Choice.actual(after,rest,stack,id,offset,children,notVerdict,healthy))
      +same = M.flagsNode(w,reader,B.set(R.Node.flags(B.node(w,reader)),K.REACTIVE_JOINED()),id)
      Equal.trans(C.Machine,C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(w,reader,id,False{})),Choice.output(after,rest,stack,id,reader,M.node(B.node(after,id))),Choice.output(after,rest,stack,id,reader,M.node(B.node(w,id))),Equal.trans(C.Machine,C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(w,reader,id,False{})),C.readDecision(rest,stack,id,reader,False{},ReadTx.Decision{after,False{},False{}}),Choice.output(after,rest,stack,id,reader,M.node(B.node(after,id))),entry,selected),Equal.cong(M.NodeView,C.Machine,meta=>Choice.output(after,rest,stack,id,reader,meta),M.node(B.node(after,id)),M.node(B.node(w,id)),same))

def entered(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>) -> {C.readDecision(rest,stack,id,1n+offset,False{},ReadTx.enterReadDecision(w,1n+offset,id,False{})) == Choice.output(Join.marked(w,1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))) : C.Machine}:
  enteredReady(w,rest,stack,id,offset,root,input,I.marked(w,1n+offset,id,root,input))

def tracking(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+reader: Nat,tracked: Bool) -> C.Machine:
  +next = B.choose(~R.World,Bool.and(Nat.is_ne(reader,0n),tracked),_=>G.link(w,id,reader),_=>w)
  C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(next,reader,id,False{}))

def fastShape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat) -> {C.readSignalFast(w,rest,stack,id) == tracking(w,rest,stack,id,B.parentComputed(w,R.World.context(w)),R.World.tracking(w)) : C.Machine}:
  {==}

def fast(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>,context: {B.parentComputed(w,R.World.context(w)) == 1n+offset : Nat},tracked: {R.World.tracking(w) == True{} : Bool}) -> {C.readSignalFast(w,rest,stack,id) == Choice.output(Join.marked(G.link(w,id,1n+offset),1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))) : C.Machine}:
  +reader = {1n+offset : Nat}
  +linked = G.link(w,id,reader)
  +caller = B.parentComputed(w,R.World.context(w))
  +observer = Equal.cong(Nat,C.Machine,who=>tracking(w,rest,stack,id,who,R.World.tracking(w)),caller,reader,context)
  +enabled = Equal.cong(Bool,C.Machine,flag=>tracking(w,rest,stack,id,reader,flag),R.World.tracking(w),True{},tracked)
  +entry = Equal.trans(C.Machine,C.readSignalFast(w,rest,stack,id),tracking(w,rest,stack,id,caller,R.World.tracking(w)),tracking(w,rest,stack,id,reader,R.World.tracking(w)),fastShape(w,rest,stack,id),observer)
  +start = Equal.trans(C.Machine,C.readSignalFast(w,rest,stack,id),tracking(w,rest,stack,id,reader,R.World.tracking(w)),C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(linked,reader,id,False{})),entry,enabled)
  +selected = entered(linked,rest,stack,id,offset,root,I.linked(w,reader,id,root,input))
  +same = M.linkNode(w,id,reader,id)
  Equal.trans(C.Machine,C.readSignalFast(w,rest,stack,id),C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(linked,reader,id,False{})),Choice.output(Join.marked(linked,reader),rest,stack,id,reader,M.node(B.node(w,id))),start,
    Equal.trans(C.Machine,C.readDecision(rest,stack,id,reader,False{},ReadTx.enterReadDecision(linked,reader,id,False{})),Choice.output(Join.marked(linked,reader),rest,stack,id,reader,M.node(B.node(linked,id))),Choice.output(Join.marked(linked,reader),rest,stack,id,reader,M.node(B.node(w,id))),selected,Equal.cong(M.NodeView,C.Machine,meta=>Choice.output(Join.marked(linked,reader),rest,stack,id,reader,meta),M.node(B.node(linked,id)),M.node(B.node(w,id)),same)))

def plainLoaded(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,kind: R.NodeKind,unflushed: Bool,override: Bool) -> C.Machine:
  B.choose(~C.Machine,Bool.and(Bool.not(B.computed(kind)),Bool.and(Bool.or(Bool.not(unflushed),Bool.not(B.present(R.Node.pending(B.node(w,id))))),Bool.not(override))),_=>C.readSignalFast(w,rest,stack,id),_=>C.prepareSlow(w,rest,stack,id))

def plainShape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat) -> {C.readPrepared(w,rest,stack,id) == plainLoaded(w,rest,stack,id,R.Node.kind(B.node(w,id)),R.World.unflushedStaged(w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE())) : C.Machine}:
  {==}

def plain(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},flushed: {R.World.unflushedStaged(w) == False{} : Bool},noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {C.readPrepared(w,rest,stack,id) == C.readSignalFast(w,rest,stack,id) : C.Machine}:
  +kind = R.Node.kind(B.node(w,id))
  +unflushed = R.World.unflushedStaged(w)
  +override = B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE())
  +first = Equal.trans(C.Machine,C.readPrepared(w,rest,stack,id),plainLoaded(w,rest,stack,id,kind,unflushed,override),plainLoaded(w,rest,stack,id,R.Signal{},unflushed,override),plainShape(w,rest,stack,id),Equal.cong(R.NodeKind,C.Machine,which=>plainLoaded(w,rest,stack,id,which,unflushed,override),kind,R.Signal{},signal))
  +second = Equal.trans(C.Machine,C.readPrepared(w,rest,stack,id),plainLoaded(w,rest,stack,id,R.Signal{},unflushed,override),plainLoaded(w,rest,stack,id,R.Signal{},False{},override),first,Equal.cong(Bool,C.Machine,flag=>plainLoaded(w,rest,stack,id,R.Signal{},flag,override),unflushed,False{},flushed))
  Equal.trans(C.Machine,C.readPrepared(w,rest,stack,id),plainLoaded(w,rest,stack,id,R.Signal{},False{},override),C.readSignalFast(w,rest,stack,id),second,Equal.cong(Bool,C.Machine,flag=>plainLoaded(w,rest,stack,id,R.Signal{},False{},flag),override,False{},noOverride))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>,context: {B.parentComputed(w,R.World.context(w)) == 1n+offset : Nat},tracked: {R.World.tracking(w) == True{} : Bool},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},flushed: {R.World.unflushedStaged(w) == False{} : Bool},noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}) == Choice.output(Join.marked(G.link(w,id,1n+offset),1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))) : C.Machine}:
  +prepared = Step.healthyStep(w,C.ReadPrepared{id},rest,stack,I.health(w,1n+offset,id,root,input))
  Equal.trans(C.Machine,C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}),C.readPrepared(w,rest,stack,id),Choice.output(Join.marked(G.link(w,id,1n+offset),1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))),prepared,
    Equal.trans(C.Machine,C.readPrepared(w,rest,stack,id),C.readSignalFast(w,rest,stack,id),Choice.output(Join.marked(G.link(w,id,1n+offset),1n+offset),rest,stack,id,1n+offset,M.node(B.node(w,id))),plain(w,rest,stack,id,signal,flushed,noOverride),fast(w,rest,stack,id,offset,root,input,context,tracked)))


def globals(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>,context: {B.parentComputed(w,R.World.context(w)) == 1n+offset : Nat},tracked: {R.World.tracking(w) == True{} : Bool},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},flushed: {R.World.unflushedStaged(w) == False{} : Bool},noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {M.globals(C.world(C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}))) == M.globals(w) : M.GlobalView}:
  +reader = {1n+offset : Nat}
  +linked = G.link(w,id,reader)
  +after = Join.marked(linked,reader)
  +actual = C.world(C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}))
  +expected = Choice.output(after,rest,stack,id,reader,M.node(B.node(w,id)))
  +result = Equal.cong(C.Machine,M.GlobalView,machine=>M.globals(C.world(machine)),C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}),expected,complete(w,rest,stack,id,offset,root,input,context,tracked,signal,flushed,noOverride))
  +chosen = Choice.outputGlobals(after,rest,stack,id,reader,M.node(B.node(w,id)))
  +marked = M.storeGlobals(linked,reader,R.Node.with_flags(B.node(linked,reader),B.set(R.Node.flags(B.node(linked,reader)),K.REACTIVE_JOINED())))
  Equal.trans(M.GlobalView,M.globals(actual),M.globals(C.world(expected)),M.globals(w),result,
    Equal.trans(M.GlobalView,M.globals(C.world(expected)),M.globals(after),M.globals(w),chosen,
      Equal.trans(M.GlobalView,M.globals(after),M.globals(linked),M.globals(w),marked,M.linkGlobals(w,id,reader))))

def groups(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+offset: Nat,+root: Nat,+input: I.Input<w,1n+offset,id,root>,context: {B.parentComputed(w,R.World.context(w)) == 1n+offset : Nat},tracked: {R.World.tracking(w) == True{} : Bool},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},flushed: {R.World.unflushedStaged(w) == False{} : Bool},noOverride: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool}) -> {R.World.txArena(C.world(C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}))) == R.World.txArena(w) : List<&2,R.Transaction>}:
  Equal.cong(M.GlobalView,List<&2,R.Transaction>,M.groups,M.globals(C.world(C.step(C.Machine{w,C.ReadPrepared{id} <> rest,stack}))),M.globals(w),globals(w,rest,stack,id,offset,root,input,context,tracked,signal,flushed,noOverride))
