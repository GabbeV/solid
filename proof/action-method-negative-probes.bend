# Compact real-constructor counterexamples for callback entry and body staging.
# Avoid importing a now-false generic law when deliberately corrupting runtime.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/core.bend as C


def method(body: Bool) -> R.Expr:
  match body:
    case False{}: R.ActionEnd{}
    case True{}: R.ActionMethods{R.Literal{R.Undefined{}},False{},R.Literal{R.Undefined{}},R.ActionEnd{}}

def created(body: Bool) -> B.Bundle<R.World,Nat>:
  A.create(B.empty(),method(body))

def actor(body: Bool) -> Nat:
  B.second(R.World,Nat,created(body))

def registered(+body: Bool) -> B.Bundle<R.World,Nat>:
  +made = created(body)
  +id = B.second(R.World,Nat,made)
  +w = A.open(B.first(R.World,Nat,made),id)
  +promise = F.newThenable(w,False{},R.Unresolved{})
  A.wait(B.first(R.World,Nat,promise),id,B.second(R.World,Nat,promise),0)

def first(+body: Bool) -> C.Machine:
  +pair = registered(body)
  +w = B.first(R.World,Nat,pair)
  +observer = B.second(R.World,Nat,pair)
  C.asyncActionDelivery(w,[],[],observer,False{},R.Undefined{},A.find(R.World.actionWaits(w),observer))

def entry_retains_committed_node_arena() -> {B.length(R.Node,R.World.nodes(C.world(first(False{})))) == 1n : Nat}:
  {==}

def entry_retains_observer_arena() -> {B.length(R.AsyncObserver,R.World.asyncObservers(C.world(first(False{})))) == 2n : Nat}:
  {==}

def body_entry_establishes_settled_wait() -> {A.find(R.World.actionWaits(C.world(first(True{}))),B.second(R.World,Nat,registered(True{}))) == Some{R.ActionWait{B.second(R.World,Nat,registered(True{})),actor(True{}),0,True{}}} : Maybe<&2,R.ActionWait>}:
  {==}
