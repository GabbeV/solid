# The raw owned-source constructor supplies the entire input certificate and
# original captured debt. Real body evaluation/return then reaches zero debt.
# This starts at the body task; the held-opened -> captured-resume reachability
# equation is explicitly outside this result, as are slice-end and publication.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-body-owned-profile.bend as Owned
import ./ordinary-write-constructed.bend as Graph
import ./held-write-profile.bend as P
import ./held-write-history.bend as History
import ./held-body-evaluation.bend as Eval
import ./held-body-return.bend as Body
import ./held-body-retirement.bend as Retire
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-retirement-count.bend as Count
import ./transaction-resolution.bend as Routes
import ./pending-stack-history.bend as Steps

def captured(+initial: R.Value) -> {R.ActionState.transaction(A.get(Owned.normalized(initial),0n)) == 1n : Nat}:
  {==}

def room(+initial: R.Value) -> {1n+B.length(R.Transaction,R.World.txArena(Owned.normalized(initial))) == 3n : Nat}:
  {==}

def openCount(+initial: R.Value) -> {R.Transaction.open(B.transaction(Owned.normalized(initial),1n)) == 1n : Nat}:
  {==}

def complete(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(Owned.normalized(initial),values,Graph.source(initial),answer,0n,rest,stack)))) == Output.outer(Exit.target(History.run(values,Owned.normalized(initial),Graph.source(initial)),1n,0n)) : R.World}:
  +w = Owned.normalized(initial)
  +id = Graph.source(initial)
  +profile = Owned.profile(initial)
  +route = {Routes.Root{1n,P.terminal(w,id,0n,profile)} : Routes.Route<w>}
  Retire.complete(values,w,id,answer,0n,rest,stack,0n,profile,route,2n,0n,captured(initial),room(initial),openCount(initial))

def afterValid(+initial: R.Value,+values: List<&2,R.Value>) -> {Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(History.run(values,Owned.normalized(initial),Graph.source(initial))))) == True{} : Bool}:
  P.groupValid(History.run(values,Owned.normalized(initial),Graph.source(initial)),Graph.source(initial),0n,History.invariant(values,Owned.normalized(initial),Graph.source(initial),0n,Owned.profile(initial)))

def zero(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> {Count.count(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(Owned.normalized(initial),values,Graph.source(initial),answer,0n,rest,stack))),1n) == 0n : Nat}:
  +actual = C.world(Steps.iterate(1n+Eval.cost(values),Body.start(Owned.normalized(initial),values,Graph.source(initial),answer,0n,rest,stack)))
  +written = History.run(values,Owned.normalized(initial),Graph.source(initial))
  +target = Exit.target(written,1n,0n)
  Equal.trans(Nat,Count.count(actual,1n),Count.count(Output.outer(actual),1n),0n,Equal.sym(Nat,Count.count(Output.outer(actual),1n),Count.count(actual,1n),Count.output(actual,1n)),Equal.trans(Nat,Count.count(Output.outer(actual),1n),Count.count(Output.outer(target),1n),0n,Equal.cong(R.World,Nat,state=>Count.count(state,1n),Output.outer(actual),Output.outer(target),complete(initial,values,answer,rest,stack)),Equal.trans(Nat,Count.count(Output.outer(target),1n),Count.count(target,1n),0n,Count.output(target,1n),Count.target(written,1n,0n,afterValid(initial,values)))))
