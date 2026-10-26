# Compact actual-boundary oracles. Every mutation must compile independently;
# these closed checks are controls for the separate quantified body contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F


def method(+value: R.Value) -> R.Expr:
  R.ActionMethods{R.Literal{R.StepResult{True{},value}},True{},R.Literal{R.StepResult{True{},value}},R.ActionEnd{}}

def initial(value: R.Value) -> R.World:
  +actor = A.create(B.empty(),method(value))
  +opened = A.open(B.first(R.World,Nat,actor),B.second(R.World,Nat,actor))
  +input = F.newThenable(opened,False{},R.Unresolved{})
  B.first(R.World,Nat,A.wait(B.first(R.World,Nat,input),0n,B.second(R.World,Nat,input),0))

def returned(+value: R.Value) -> C.Machine:
  +first = C.asyncFulfillOrdinary(initial(value),[],[R.Number{1n},R.Number{2n}],1n,R.Number{3n})
  C.step(C.step(first))

def depth() -> {R.World.actionDepth(C.world(returned(R.Number{7n}))) == 0n : Nat}:
  {==}

def advanced() -> {R.ActionState.methods(A.get(C.world(returned(R.Number{7n})),0n)) == R.ActionEnd{} : R.Expr}:
  {==}

def debt() -> {R.Transaction.open(B.transaction(C.world(returned(R.Number{7n})),1n)) == 0n : Nat}:
  {==}

def ordinaryGuard() -> {A.find(R.World.actionWaits(C.world(returned(R.Number{7n}))),1n) == Some{R.ActionWait{1n,0n,0,True{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def adoptingGuard() -> {A.find(R.World.actionWaits(C.world(returned(R.AsyncValue{2n}))),1n) == Some{R.ActionWait{1n,0n,0,True{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def callerStack() -> {C.values(returned(R.Number{7n})) == [R.Number{1n},R.Number{2n}] : List<&2,R.Value>}:
  {==}
