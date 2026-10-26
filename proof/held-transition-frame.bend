# Product of the three established actual-write observations. Composing this
# product does not assume a successful next profile; pointer transport aligns
# the selected extension observation across the changing World.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./held-write-outer.bend as Outer
import ./subscriber-topology-frame.bend as Shape
import ./node-pointer-observation.bend as Pointer

type Transition<-w: R.World,-next: R.World,-id: Nat> is Data:
  Retained{outer: {Outer.observe(next,R.Node.x(B.node(w,id))) == Outer.observe(w,R.Node.x(B.node(w,id))) : R.World},shape: {Shape.observe(next) == Shape.observe(w) : Shape.View},pointers: {Pointer.observe(next) == Pointer.observe(w) : List<&2,Nat>}}

def moveOuter(+w: R.World,+next: R.World,+a: Nat,+b: Nat,+same: {a == b : Nat},outer: {Outer.observe(next,a) == Outer.observe(w,a) : R.World}) -> {Outer.observe(next,b) == Outer.observe(w,b) : R.World}:
  Equal.trans(R.World,Outer.observe(next,b),Outer.observe(next,a),Outer.observe(w,b),Equal.cong(Nat,R.World,slot=>Outer.observe(next,slot),b,a,Equal.sym(Nat,a,b,same)),Equal.trans(R.World,Outer.observe(next,a),Outer.observe(w,a),Outer.observe(w,b),outer,Equal.cong(Nat,R.World,slot=>Outer.observe(w,slot),a,b,same)))

def identity(+w: R.World,+id: Nat) -> Transition<w,w,id>:
  Retained{{==},{==},{==}}

def compose(+w: R.World,+middle: R.World,+next: R.World,+id: Nat,first: Transition<w,middle,id>,last: Transition<middle,next,id>) -> Transition<w,next,id>:
  match first:
    case Retained{outer,shape,+pointers}:
      match last:
        case Retained{outerLast,shapeLast,pointersLast}:
          Retained{Outer.compose(w,middle,next,R.Node.x(B.node(w,id)),moveOuter(middle,next,R.Node.x(B.node(middle,id)),R.Node.x(B.node(w,id)),Pointer.read(w,middle,id,pointers),outerLast),outer),Shape.compose(w,middle,next,shapeLast,shape),Pointer.compose(w,middle,next,pointersLast,pointers)}

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,+id: Nat,left: Transition<w,yes,id>,right: Transition<w,no,id>) -> Transition<w,B.choose(~R.World,flag,_=>yes,_=>no),id>:
  match flag:
    case True{}: left
    case False{}: right

def target(-w: R.World,-next: R.World,-to: R.World,-id: Nat,same: {next == to : R.World},frame: Transition<w,next,id>) -> Transition<w,to,id>:
  %same : Transition<w,_,id>
  frame
