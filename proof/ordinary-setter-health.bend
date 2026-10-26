# Default-comparison ordinary setter: a comparison may suppress staging, but
# every branch preserves the same outer World, including fault and live debt.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/transaction.bend as X
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./setter-committed-frame.bend as Source
import ./ordinary-stage-health.bend as Stage
import ./ordinary-write-outer.bend as Frame
import ./subscriber-walk-step.bend as Path

def comparedDefault(+w: R.World,+id: Nat,+current: R.Value,+value: R.Value,custom: {Equality.custom(w,id) == 0n : Nat}) -> {Source.compared(w,id,current,value) == B.choose(~R.World,W.skipCompare(w,id),_=>W.stageResolved(w,id,value),_=>B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value))) : R.World}:
  Equal.cong(Nat,R.World,comparator=>B.choose(~R.World,W.skipCompare(w,id),_=>W.stageResolved(w,id,value),_=>B.choose(~R.World,Nat.is_ne(comparator,0n),_=>R.World.with_fault(w,R.Unsupported{23n}),_=>B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value)))),Equality.custom(w,id),0n,custom)

def before(+w: R.World,+id: Nat,ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool}) -> {W.beforeCompare(w,id) == w : R.World}:
  Equal.cong(Bool,R.World,held=>B.choose(~R.World,held,_=>X.joinNode(w,id),_=>w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),False{},ordinary)

def actual(+w: R.World,+path: Path.Path<w>,+id: Nat,+current: R.Value,+value: R.Value,+extra: Nat,unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},+ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}) -> {Frame.observe(W.setResolved(w,id,current,value)) == Frame.observe(w) : R.World}:
  +staged = Stage.actual(w,path,id,value,extra,unmarked,valid,head,room,context,signal,ordinary)
  +default = B.choose(~R.World,W.skipCompare(w,id),_=>W.stageResolved(w,id,value),_=>B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value)))
  +unchanged = Frame.choice(W.skipCompare(w,id),w,W.stageResolved(w,id,value),B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value)),staged,Frame.choice(Equality.isSame(w,id,current,value),w,w,W.stageResolved(w,id,value),{==},staged))
  Equal.trans(R.World,Frame.observe(W.setResolved(w,id,current,value)),Frame.observe(Source.compared(w,id,current,value)),Frame.observe(w),Equal.cong(R.World,R.World,state=>Frame.observe(Source.compared(state,id,current,value)),W.beforeCompare(w,id),w,before(w,id,ordinary)),Equal.trans(R.World,Frame.observe(Source.compared(w,id,current,value)),Frame.observe(default),Frame.observe(w),Equal.cong(R.World,R.World,state=>Frame.observe(state),Source.compared(w,id,current,value),default,comparedDefault(w,id,current,value,custom)),unchanged))
