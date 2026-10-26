# Subscriber-path certificates depend on actual link storage alone. Transport
# constructs the next certificate and preserves origin/depth; no new path or
# successful traversal answer is assumed after a write.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./subscriber-walk-step.bend as Path

type Rebased<-w: R.World,-next: R.World,-path: Path.Path<w>> is Data:
  RebasedAt{value: Path.Path<next>,origin: {Path.origin(next,value) == Path.origin(w,path) : Nat},depth: {Path.depth(next,value) == Path.depth(w,path) : Nat}}

def nextLink(+w: R.World,+next: R.World,+index: Nat,same: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}) -> {R.Link.nextSub(B.link(next,1n+index)) == R.Link.nextSub(B.link(w,1n+index)) : Nat}:
  Equal.cong(List<&2,R.Link>,Nat,links=>R.Link.nextSub(B.get(R.Link,links,1n+index,B.blank_link())),R.World.links(next),R.World.links(w),same)

def edge(+w: R.World,+next: R.World,+index: Nat,+tail: Path.Path<w>,+linked: {R.Link.nextSub(B.link(w,1n+index)) == Path.origin(w,tail) : Nat},same: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>},moved: Rebased<w,next,tail>) -> Rebased<w,next,Path.Edge{index,tail,linked}>:
  match moved:
    case RebasedAt{+value,origin,depth}:
      +follow = Equal.trans(Nat,R.Link.nextSub(B.link(next,1n+index)),R.Link.nextSub(B.link(w,1n+index)),Path.origin(next,value),nextLink(w,next,index,same),Equal.trans(Nat,R.Link.nextSub(B.link(w,1n+index)),Path.origin(w,tail),Path.origin(next,value),linked,Equal.sym(Nat,Path.origin(next,value),Path.origin(w,tail),origin)))
      RebasedAt{Path.Edge{index,value,follow},{==},Equal.cong(Nat,Nat,n=>1n+n,Path.depth(next,value),Path.depth(w,tail),depth)}

def move(+w: R.World,+next: R.World,path: Path.Path<w>,+same: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}) -> Rebased<w,next,path>:
  match path:
    case Path.End{}: RebasedAt{Path.End{},{==},{==}}
    case Path.Edge{+index,+tail,+linked}:
      edge(w,next,index,tail,linked,same,move(w,next,tail,same))
