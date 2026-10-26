# Real setter updater evaluation, including its resolved write, remains healthy
# under a constructed/admissible ordinary signal and subscriber path profile.
# This preserves action cells/waits/group storage, not only committed content.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./pending-stack-history.bend as Steps
import ./ordinary-updater-evaluation.bend as Eval
import ./ordinary-setter-health.bend as Setter
import ./ordinary-write-outer.bend as Frame
import ./subscriber-walk-step.bend as Path

def nonmemo(+w: R.World,+id: Nat,signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind}) -> {C.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool}:
  Equal.cong(R.NodeKind,Bool,kind=>C.memoNode(kind),R.Node.kind(B.node(w,id)),R.Signal{},signal)

def frame(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+previous: R.Value,+extra: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,health: {R.World.fault(w) == R.Healthy{} : R.Fault},unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},+signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},+custom: {Equality.custom(w,id) == 0n : Nat}) -> {Frame.observe(C.world(Steps.iterate(3n,Eval.start(w,rest,stack,id,value,previous)))) == Frame.observe(w) : R.World}:
  Equal.trans(R.World,Frame.observe(C.world(Steps.iterate(3n,Eval.start(w,rest,stack,id,value,previous)))),Frame.observe(W.setSignal(w,id,value)),Frame.observe(w),Equal.cong(C.Machine,R.World,m=>Frame.observe(C.world(m)),Steps.iterate(3n,Eval.start(w,rest,stack,id,value,previous)),Eval.updated(w,rest,stack,id,value),Eval.complete(w,rest,stack,id,value,previous,health,nonmemo(w,id,signal),override,custom)),Setter.actual(w,path,id,B.current(B.node(w,id)),value,extra,unmarked,valid,head,room,context,signal,ordinary,custom))
