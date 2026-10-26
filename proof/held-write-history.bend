# Arbitrary finite real held-setter histories, with the next canonical group/
# extension/path certificate constructed after each write. The existing shared
# runtime/history operation is used; no second staging algorithm is introduced.
import Base
import ../representation/records.bend as R
import ../runtime/write.bend as W
import ./ordinary-write-history.bend as Actual
import ./held-write-profile.bend as P
import ./held-setter-frames.bend as Setter
import ./held-transition-frame.bend as T
import ./held-write-outer.bend as Frame
import ../representation/base.bend as B
import ./committed-storage-frame.bend as Content

def run(values: List<&2,R.Value>,w: R.World,id: Nat) -> R.World:
  Actual.run(values,w,id)

def invariant(values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<w,id,offset>) -> P.Profile<run(values,w,id),id,offset>:
  match values:
    case Nil{}: profile
    case +value <> tail:
      invariant(tail,W.setSignal(w,id,value),id,offset,Setter.next(w,id,value,offset,profile))

def retained(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,+profile: P.Profile<w,id,offset>) -> T.Transition<w,run(values,w,id),id>:
  match values:
    case Nil{}: T.identity(w,id)
    case +value <> +tail:
      +next = W.setSignal(w,id,value)
      +frame = Setter.actual(w,id,value,offset,profile)
      T.compose(w,next,run(values,w,id),id,frame,retained(tail,next,id,offset,P.transport(w,next,id,offset,profile,frame)))

def committed(+values: List<&2,R.Value>,+w: R.World,+id: Nat) -> {Content.observe(run(values,w,id)) == Content.observe(w) : Content.View}:
  Actual.committed(values,w,id)

def outerFrame(-w: R.World,-next: R.World,-id: Nat,frame: T.Transition<w,next,id>) -> {Frame.observe(next,R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  match frame:
    case T.Retained{outer,shape,pointers}: outer

def outer(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+offset: Nat,profile: P.Profile<w,id,offset>) -> {Frame.observe(run(values,w,id),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  outerFrame(w,run(values,w,id),id,retained(values,w,id,offset,profile))
