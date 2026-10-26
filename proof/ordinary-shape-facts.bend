# Source-shape observation entails the ordinary profile's current node facts
# and actual budget room. These are consequences of the retained full lists.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./subscriber-topology-frame.bend as Frame

def kind(shape: Frame.Shape) -> R.NodeKind:
  match shape:
    case Frame.Shape{kind,config,subscribers}: kind

def config(shape: Frame.Shape) -> U32:
  match shape:
    case Frame.Shape{kind,config,subscribers}: config

def subscribers(shape: Frame.Shape) -> Nat:
  match shape:
    case Frame.Shape{kind,config,subscribers}: subscribers

def count(+nodes: List<&2,R.Node>) -> {B.length(Frame.Shape,Frame.shapes(nodes)) == B.length(R.Node,nodes) : Nat}:
  match nodes:
    case Nil{}: {==}
    case head <> +tail:
      Equal.cong(Nat,Nat,n=>1n+n,B.length(Frame.Shape,Frame.shapes(tail)),B.length(R.Node,tail),count(tail))

def nodeCount(+w: R.World,+next: R.World,same: {Frame.observe(next) == Frame.observe(w) : Frame.View}) -> {B.length(R.Node,R.World.nodes(next)) == B.length(R.Node,R.World.nodes(w)) : Nat}:
  Equal.trans(Nat,B.length(R.Node,R.World.nodes(next)),B.length(Frame.Shape,Frame.shapes(R.World.nodes(next))),B.length(R.Node,R.World.nodes(w)),Equal.sym(Nat,B.length(Frame.Shape,Frame.shapes(R.World.nodes(next))),B.length(R.Node,R.World.nodes(next)),count(R.World.nodes(next))),Equal.trans(Nat,B.length(Frame.Shape,Frame.shapes(R.World.nodes(next))),B.length(Frame.Shape,Frame.shapes(R.World.nodes(w))),B.length(R.Node,R.World.nodes(w)),Equal.cong(Frame.View,Nat,view=>B.length(Frame.Shape,Frame.nodes(view)),Frame.observe(next),Frame.observe(w),same),count(R.World.nodes(w))))

def budget(+w: R.World,+next: R.World,+same: {Frame.observe(next) == Frame.observe(w) : Frame.View}) -> {B.budget(next) == B.budget(w) : Nat}:
  Equal.trans(Nat,B.budget(next),Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,R.World.links(next)))),B.budget(w),Equal.cong(Nat,Nat,n=>Nat.mul(4n,Nat.add(n,B.length(R.Link,R.World.links(next)))),B.length(R.Node,R.World.nodes(next)),B.length(R.Node,R.World.nodes(w)),nodeCount(w,next,same)),Equal.cong(Frame.View,Nat,view=>Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,Frame.edges(view)))),Frame.observe(next),Frame.observe(w),same))

def valid(+w: R.World,+next: R.World,+id: Nat,same: {Frame.observe(next) == Frame.observe(w) : Frame.View},known: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(id,n),B.length(R.Node,R.World.nodes(next)),B.length(R.Node,R.World.nodes(w)),nodeCount(w,next,same)),known)
