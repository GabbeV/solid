# Derive output-prefix boundary flags from actual raw construction and body
# execution. No healthy/ready/depth/running/halted result is assumed afterward.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./ordinary-graph-data.bend as Graph
import ./held-delivery-constructor-state.bend as State
import ./held-delivery-constructed-input.bend as Input
import ./held-construction-context.bend as Context
import ./held-delivery-constructed.bend as Constructed
import ./held-delivery-output-entry.bend as Entry
import ./held-action-delivery.bend as Delivery
import ./held-resume-retirement.bend as Resume
import ./action-delivery-input.bend as Mark
import ./action-first-frame.bend as First
import ./action-body-entry.bend as Prepared
import ./held-preparation-profile.bend as Prep
import ./held-preparation-source.bend as Source
import ./held-write-profile.bend as P
import ./held-write-history.bend as Writes
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-output-continuation.bend as Queue
import ./action-output-delivery-loop.bend as Loop
import ./action-control-flags.bend as Flags
import ./action-schedule-ready.bend as Ready
import ./action-wait-history.bend as History

def preparedFlags(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Flags.observe(Prepared.prepared(Mark.marked(State.registered(value,methods,prefix),State.observer(value,methods,prefix)),0n,R.ActionEnd{})) == Flags.Flags{1n,False{},False{}} : Flags.View}:
  +w = State.registered(value,methods,prefix)
  +observer = State.observer(value,methods,prefix)
  +marked = Mark.marked(w,observer)
  +capture = Equal.trans(Nat,R.ActionState.transaction(A.get(marked,0n)),R.ActionState.transaction(A.get(w,0n)),1n,Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,0n,A.blank())),R.World.actions(marked),R.World.actions(w),First.markedActions(w,observer)),Input.capture(value,methods,prefix))
  +empty = Equal.trans(Nat,R.World.flushTransaction(marked),R.World.flushTransaction(w),0n,Mark.future(w,observer),Input.empty(value,methods,prefix))
  +selected = Source.flush(marked,1n)
  +terminal = Equal.trans(Nat,R.Transaction.into(B.transaction(marked,1n)),R.Transaction.into(B.transaction(selected,1n)),0n,Equal.sym(Nat,R.Transaction.into(B.transaction(selected,1n)),R.Transaction.into(B.transaction(marked,1n)),Prep.originalTerminal(marked,1n)),P.terminal(selected,Graph.source(value),0n,Mark.freshProfile(w,observer,Graph.source(value),0n,Input.profile(value,methods,prefix))))
  +before = Equal.trans(Flags.View,Flags.observe(marked),Flags.observe(w),Flags.Flags{0n,False{},False{}},Flags.marked(w,observer),Context.flags(value,methods,prefix))
  Equal.trans(Flags.View,Flags.observe(Prepared.prepared(marked,0n,R.ActionEnd{})),Flags.enter(Flags.observe(marked)),Flags.Flags{1n,False{},False{}},Flags.prepared(marked,0n,0n,R.ActionEnd{},capture,empty,terminal),Equal.cong(Flags.View,Flags.View,view=>Flags.enter(view),Flags.observe(marked),Flags.Flags{0n,False{},False{}},before))

def written(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>) -> R.World:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = State.registered(value,method,prefix)
  Writes.run(values,Prepared.prepared(Mark.marked(w,State.observer(value,method,prefix)),0n,R.ActionEnd{}),Graph.source(value))

def writtenFlags(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>) -> {Flags.observe(written(value,values,answer,prefix)) == Flags.Flags{1n,False{},False{}} : Flags.View}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = State.registered(value,method,prefix)
  +observer = State.observer(value,method,prefix)
  +next = Prepared.prepared(Mark.marked(w,observer),0n,R.ActionEnd{})
  +profile = Entry.preparedProfile(w,observer,0n,Graph.source(value),0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix))
  Equal.trans(Flags.View,Flags.observe(written(value,values,answer,prefix)),Flags.observe(next),Flags.Flags{1n,False{},False{}},Flags.fromWrites(next,written(value,values,answer,prefix),R.Node.x(B.node(next,Graph.source(value))),Writes.outer(values,next,Graph.source(value),0n,profile)),preparedFlags(value,method,prefix))

def body(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,incoming: R.Value,rejected: Bool) -> C.Machine:
  +method = Resume.methods(values,Graph.source(value),answer)
  Delivery.after(State.registered(value,method,prefix),rest,stack,State.observer(value,method,prefix),rejected,incoming,values)

def bodyFlags(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Flags.observe(C.world(body(value,values,answer,prefix,rest,stack,incoming,rejected))) == Flags.Flags{0n,False{},False{}} : Flags.View}:
  +actual = C.world(body(value,values,answer,prefix,rest,stack,incoming,rejected))
  +source = written(value,values,answer,prefix)
  +target = Exit.target(source,1n,0n)
  +same = Equal.trans(Flags.View,Flags.observe(Output.outer(actual)),Flags.observe(Output.outer(target)),Flags.observe(target),Equal.cong(R.World,Flags.View,w=>Flags.observe(w),Output.outer(actual),Output.outer(target),Constructed.complete(value,values,answer,prefix,rest,stack,incoming,rejected)),Flags.output(target))
  Equal.trans(Flags.View,Flags.observe(actual),Flags.observe(target),Flags.Flags{0n,False{},False{}},Equal.trans(Flags.View,Flags.observe(actual),Flags.observe(Output.outer(actual)),Flags.observe(target),Equal.sym(Flags.View,Flags.observe(Output.outer(actual)),Flags.observe(actual),Flags.output(actual)),same),Equal.trans(Flags.View,Flags.observe(target),Flags.exit(Flags.observe(source)),Flags.Flags{0n,False{},False{}},Flags.target(source,1n,0n),Equal.cong(Flags.View,Flags.View,v=>Flags.exit(v),Flags.observe(source),Flags.Flags{1n,False{},False{}},writtenFlags(value,values,answer,prefix))))

def bodyReady(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {R.World.scheduled(C.world(body(value,values,answer,prefix,rest,stack,incoming,rejected))) == True{} : Bool}:
  +actual = C.world(body(value,values,answer,prefix,rest,stack,incoming,rejected))
  +source = written(value,values,answer,prefix)
  +target = Exit.target(source,1n,0n)
  +unhalted = Equal.cong(Flags.View,Bool,view=>Flags.halted(view),Flags.observe(source),Flags.Flags{1n,False{},False{}},writtenFlags(value,values,answer,prefix))
  Equal.trans(Bool,R.World.scheduled(actual),R.World.scheduled(Output.outer(actual)),True{},Equal.sym(Bool,R.World.scheduled(Output.outer(actual)),R.World.scheduled(actual),Flags.scheduledOutput(actual)),Equal.trans(Bool,R.World.scheduled(Output.outer(actual)),R.World.scheduled(Output.outer(target)),True{},Equal.cong(R.World,Bool,w=>R.World.scheduled(w),Output.outer(actual),Output.outer(target),Constructed.complete(value,values,answer,prefix,rest,stack,incoming,rejected)),Equal.trans(Bool,R.World.scheduled(Output.outer(target)),R.World.scheduled(target),True{},Flags.scheduledOutput(target),Ready.target(source,1n,0n,unhalted))))

def form(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> Queue.Queue<body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(State.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),State.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rest),stack>:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = State.registered(value,method,prefix)
  +observer = State.observer(value,method,prefix)
  Entry.queue(w,observer,0n,values,Graph.source(value),answer,rest,stack,incoming,rejected,0n,0n,Input.profile(value,method,prefix),Input.alias(value,method,prefix),Input.capture(value,method,prefix),{==},Input.empty(value,method,prefix),Input.method(value,method,prefix),Input.found(value,method,prefix))

def world(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> R.World:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = State.registered(value,method,prefix)
  Queue.world(body(value,values,answer,prefix,rest,stack,incoming,rejected),Entry.work(w,State.observer(value,method,prefix),rest),stack,form(value,values,answer,prefix,rest,stack,incoming,rejected))
