# Actual raw construction and first callback reach the scheduled Round entry.
# Every body/prefix/slice fact is derived; Round execution/publication are open.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./ordinary-graph-data.bend as Graph
import ./held-delivery-constructed-input.bend as Input
import ./held-resume-retirement.bend as Resume
import ./held-action-delivery.bend as Delivery
import ./held-delivery-output-entry.bend as Entry
import ./held-constructed-round-state.bend as State
import ./action-output-continuation.bend as Queue
import ./action-output-queue-state.bend as Frame
import ./action-control-flags.bend as Flags
import ./action-slice-entry.bend as Slice
import ./action-delivery-input.bend as Mark
import ./held-body-evaluation.bend as Eval
import ./action-wait-history.bend as History
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./core-prefix-compose.bend as Prefix

def flags(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Flags.observe(State.world(value,values,answer,prefix,rest,stack,incoming,rejected)) == Flags.Flags{0n,False{},False{}} : Flags.View}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Equal.trans(Flags.View,Flags.observe(State.world(value,values,answer,prefix,rest,stack,incoming,rejected)),Flags.observe(C.world(State.body(value,values,answer,prefix,rest,stack,incoming,rejected))),Flags.Flags{0n,False{},False{}},Frame.flags(State.body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(w,observer,rest),stack,State.form(value,values,answer,prefix,rest,stack,incoming,rejected)),State.bodyFlags(value,values,answer,prefix,rest,stack,incoming,rejected))

def ready(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {R.World.scheduled(State.world(value,values,answer,prefix,rest,stack,incoming,rejected)) == True{} : Bool}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Equal.trans(Bool,R.World.scheduled(State.world(value,values,answer,prefix,rest,stack,incoming,rejected)),R.World.scheduled(C.world(State.body(value,values,answer,prefix,rest,stack,incoming,rejected))),True{},Frame.scheduled(State.body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(w,observer,rest),stack,State.form(value,values,answer,prefix,rest,stack,incoming,rejected)),State.bodyReady(value,values,answer,prefix,rest,stack,incoming,rejected))

def healthy(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {R.World.fault(State.world(value,values,answer,prefix,rest,stack,incoming,rejected)) == R.Healthy{} : R.Fault}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Frame.healthy(State.body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(w,observer,rest),stack,State.form(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.healthy(w,observer,0n,values,Graph.source(value),answer,rest,stack,incoming,rejected,0n,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.openCount(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix)))

def cost(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> Nat:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Queue.cost(State.body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(w,observer,rest),stack,State.form(value,values,answer,prefix,rest,stack,incoming,rejected))

def drain(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(cost(value,values,answer,prefix,rest,stack,incoming,rejected),State.body(value,values,answer,prefix,rest,stack,incoming,rejected)) == C.Machine{State.world(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rest),stack} : C.Machine}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Entry.drain(w,observer,0n,values,Graph.source(value),answer,rest,stack,incoming,rejected,0n,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.openCount(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix))

def target(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> C.Machine:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  C.Machine{State.world(value,values,answer,prefix,rest,stack,incoming,rejected),C.Round{} <> C.ActionRestoreQuestion{R.World.question(Mark.marked(w,observer))} <> rest,stack}

def round(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(1n+cost(value,values,answer,prefix,rest,stack,incoming,rejected),State.body(value,values,answer,prefix,rest,stack,incoming,rejected)) == target(value,values,answer,prefix,rest,stack,incoming,rejected) : C.Machine}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  +after = State.world(value,values,answer,prefix,rest,stack,incoming,rejected)
  +question = R.World.question(Mark.marked(w,observer))
  +facts = flags(value,values,answer,prefix,rest,stack,incoming,rejected)
  +depth = Equal.cong(Flags.View,Nat,view=>Flags.depth(view),Flags.observe(after),Flags.Flags{0n,False{},False{}},facts)
  +running = Equal.cong(Flags.View,Bool,view=>Flags.running(view),Flags.observe(after),Flags.Flags{0n,False{},False{}},facts)
  +halted = Equal.cong(Flags.View,Bool,view=>Flags.halted(view),Flags.observe(after),Flags.Flags{0n,False{},False{}},facts)
  Driver.appendStep(cost(value,values,answer,prefix,rest,stack,incoming,rejected),State.body(value,values,answer,prefix,rest,stack,incoming,rejected),Slice.start(after,question,rest,stack),target(value,values,answer,prefix,rest,stack,incoming,rejected),drain(value,values,answer,prefix,rest,stack,incoming,rejected),Slice.scheduled(after,question,rest,stack,healthy(value,values,answer,prefix,rest,stack,incoming,rejected),depth,running,halted,ready(value,values,answer,prefix,rest,stack,incoming,rejected)))

def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(Nat.add(1n+Eval.cost(values),1n+cost(value,values,answer,prefix,rest,stack,incoming,rejected)),Delivery.start(Input.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,Input.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rejected,incoming)) == target(value,values,answer,prefix,rest,stack,incoming,rejected) : C.Machine}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = Input.registered(value,method,prefix)
  +observer = Input.observer(value,method,prefix)
  Prefix.compose(1n+Eval.cost(values),1n+cost(value,values,answer,prefix,rest,stack,incoming,rejected),Delivery.start(w,rest,stack,observer,rejected,incoming),State.body(value,values,answer,prefix,rest,stack,incoming,rejected),target(value,values,answer,prefix,rest,stack,incoming,rejected),{==},round(value,values,answer,prefix,rest,stack,incoming,rejected))
