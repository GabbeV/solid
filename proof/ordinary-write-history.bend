# Arbitrary finite ordinary setter histories preserve their constructed profile.
# The language calls real W.setSignal; the next certificate is derived each time.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ./ordinary-write-profile.bend as P
import ./ordinary-write-outer.bend as Frame
import ./committed-storage-frame.bend as Content
import ./setter-committed-frame.bend as Storage
import ./ordinary-write-constructed.bend as Fixture

def run(values: List<&2,R.Value>,w: R.World,+id: Nat) -> R.World:
  match values:
    case Nil{}: w
    case value <> tail: run(tail,W.setSignal(w,id,value),id)

def invariant(values: List<&2,R.Value>,+w: R.World,+id: Nat,profile: P.Profile<w,id>) -> P.Profile<run(values,w,id),id>:
  match values:
    case Nil{}: profile
    case +value <> tail:
      invariant(tail,W.setSignal(w,id,value),id,P.next(w,id,value,profile))

def outer(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+profile: P.Profile<w,id>) -> {Frame.observe(run(values,w,id)) == Frame.observe(w) : R.World}:
  match values:
    case Nil{}: {==}
    case +value <> +tail:
      Frame.compose(w,W.setSignal(w,id,value),run(tail,W.setSignal(w,id,value),id),outer(tail,W.setSignal(w,id,value),id,P.next(w,id,value,profile)),P.outer(w,id,value,profile))

def committed(+values: List<&2,R.Value>,+w: R.World,+id: Nat) -> {Content.observe(run(values,w,id)) == Content.observe(w) : Content.View}:
  match values:
    case Nil{}: {==}
    case +value <> +tail:
      Content.compose(w,W.setSignal(w,id,value),run(tail,W.setSignal(w,id,value),id),committed(tail,W.setSignal(w,id,value),id),Storage.setter(w,id,value))

def constructed(+initial: R.Value) -> P.Profile<Fixture.linked(initial),Fixture.source(initial)>:
  P.ProfileAt{Fixture.path(initial),19n,{==},{==},{==},{==},{==},{==},{==},{==},{==},{==}}

def constructedHistory(+values: List<&2,R.Value>,+initial: R.Value) -> P.Profile<run(values,Fixture.linked(initial),Fixture.source(initial)),Fixture.source(initial)>:
  invariant(values,Fixture.linked(initial),Fixture.source(initial),constructed(initial))
