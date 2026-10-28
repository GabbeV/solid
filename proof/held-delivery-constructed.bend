# Constructed ordinary callback entry: actual graph/create/open/hold/input
# allocation, arbitrary finite admitted helper prefix, actual wait registration,
# real first lookup/mark, actual body/retirement and duplicate current lookup.
# The host delivery and full public generator invocation/parking remain separate.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./ordinary-graph-data.bend as Graph
import ./held-resume-retirement.bend as Resume
import ./held-delivery-constructed-input.bend as Input
import ./held-action-delivery.bend as Delivery
import ./held-action-delivery-guard.bend as Guard
import ./action-delivery-input.bend as Mark
import ./action-body-entry.bend as Prepared
import ./held-write-history.bend as Writes
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-wait-history.bend as History


def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Output.outer(C.world(Delivery.after(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rejected,incoming,values))) == Output.outer(Exit.target(Writes.run(values,Prepared.prepared(Mark.marked(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix)),0n,R.ActionEnd{}),Graph.source(value)),1n,0n)) : R.World}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Delivery.fresh(w,observer,0n,values,Graph.source(value),answer,rest,stack,incoming,rejected,0n,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.openCount(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix))

def stack(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+saved: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {C.values(Delivery.after(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,saved,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rejected,incoming,values)) == saved : List<&2,R.Value>}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Delivery.freshStack(w,observer,0n,values,Graph.source(value),answer,rest,saved,incoming,rejected,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix))

def duplicate(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+suffix: List<&2,History.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(Guard.afterEvents(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),incoming,rejected,values,suffix)),Guard.tasks(Guard.afterEvents(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),incoming,rejected,values,suffix)),C.values(Guard.afterEvents(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),incoming,rejected,values,suffix)),Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),lateRejected,lateValue,A.find(R.World.actionWaits(C.world(Guard.afterEvents(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),incoming,rejected,values,suffix))),Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix))) == Guard.afterEvents(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),incoming,rejected,values,suffix) : C.Machine}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Guard.freshDuplicate(w,observer,0n,values,Graph.source(value),answer,rest,stack,incoming,rejected,0n,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.openCount(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix),suffix,lateRejected,lateValue)
