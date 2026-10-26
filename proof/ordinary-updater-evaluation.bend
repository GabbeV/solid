# Execute a real setter(() => value) expression through the shared core. The
# updater's literal result is data, including callable values. Comparator/override
# callbacks remain explicit exclusions. This is safety, not whole flush progress.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./action-body-return.bend as Body
import ./ordinary-setter-frame.bend as Setter
import ./committed-storage-frame.bend as Frame
import ./setter-committed-frame.bend as Storage
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def start(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,id: Nat,value: R.Value,previous: R.Value) -> C.Machine:
  C.Machine{w,C.Evaluate{R.WriteExpr{id,R.Literal{value},True{}},previous} <> rest,stack}

def entered(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+id: Nat,value: R.Value) -> C.Machine:
  C.Machine{w,C.Evaluate{R.Literal{value},B.current(B.node(w,id))} <> C.SetSignalResolved{id,B.current(B.node(w,id))} <> rest,stack}

def resolved(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+id: Nat,value: R.Value) -> C.Machine:
  C.Machine{w,C.SetSignalResolved{id,B.current(B.node(w,id))} <> rest,value <> stack}

def updated(+w: R.World,rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value) -> C.Machine:
  C.Machine{W.setSignal(w,id,value),rest,value <> stack}

def entry(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+previous: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},ordinary: {C.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool}) -> {C.step(start(w,rest,stack,id,value,previous)) == entered(w,rest,stack,id,value) : C.Machine}:
  Equal.trans(C.Machine,C.step(start(w,rest,stack,id,value,previous)),C.evaluate(w,rest,stack,R.WriteExpr{id,R.Literal{value},True{}},previous),entered(w,rest,stack,id,value),Body.healthyStep(w,C.Evaluate{R.WriteExpr{id,R.Literal{value},True{}},previous},rest,stack,Body.health(w,healthy)),Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.memoUpdater(w,rest,stack,id,R.Literal{value}),_=>C.signalUpdater(w,rest,stack,id,R.Literal{value})),C.memoNode(R.Node.kind(B.node(w,id))),False{},ordinary))

def literal(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(entered(w,rest,stack,id,value)) == resolved(w,rest,stack,id,value) : C.Machine}:
  Body.healthyStep(w,C.Evaluate{R.Literal{value},B.current(B.node(w,id))},C.SetSignalResolved{id,B.current(B.node(w,id))} <> rest,stack,Body.health(w,healthy))

def setter(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}) -> {C.step(resolved(w,rest,stack,id,value)) == updated(w,rest,stack,id,value) : C.Machine}:
  Equal.trans(C.Machine,C.step(resolved(w,rest,stack,id,value)),C.setResolved(w,rest,stack,id,B.current(B.node(w,id)),value),updated(w,rest,stack,id,value),Body.healthyStep(w,C.SetSignalResolved{id,B.current(B.node(w,id))},rest,value <> stack,Body.health(w,healthy)),Setter.ordinaryExact(w,rest,stack,id,B.current(B.node(w,id)),value,override,custom))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+previous: R.Value,+healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},ordinary: {C.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}) -> {Steps.iterate(3n,start(w,rest,stack,id,value,previous)) == updated(w,rest,stack,id,value) : C.Machine}:
  Driver.appendStep(2n,start(w,rest,stack,id,value,previous),resolved(w,rest,stack,id,value),updated(w,rest,stack,id,value),Driver.appendStep(1n,start(w,rest,stack,id,value,previous),entered(w,rest,stack,id,value),resolved(w,rest,stack,id,value),entry(w,rest,stack,id,value,previous,healthy,ordinary),literal(w,rest,stack,id,value,healthy)),setter(w,rest,stack,id,value,healthy,override,custom))


def committed(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+previous: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault},ordinary: {C.memoNode(R.Node.kind(B.node(w,id))) == False{} : Bool},override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}) -> {Frame.observe(C.world(Steps.iterate(3n,start(w,rest,stack,id,value,previous)))) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View,Frame.observe(C.world(Steps.iterate(3n,start(w,rest,stack,id,value,previous)))),Frame.observe(W.setSignal(w,id,value)),Frame.observe(w),Equal.cong(C.Machine,Frame.View,m=>Frame.observe(C.world(m)),Steps.iterate(3n,start(w,rest,stack,id,value,previous)),updated(w,rest,stack,id,value),complete(w,rest,stack,id,value,previous,healthy,ordinary,override,custom)),Storage.setter(w,id,value))
