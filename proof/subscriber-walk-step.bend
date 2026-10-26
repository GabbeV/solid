# Finite certificates name actual subscriber nextSub fields. Heap insertion
# cannot change these links; outside recursive marking it also retains fault.
# The structural path supplies walk fuel. General arena-size coverage is separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ./ordinary-write-outer.bend as Frame
import ./ordinary-heap-health-frame.bend as Heap

type Path<-w: R.World> is Data:
  End{}
  Edge{index: Nat,tail: Path<w>,linked: {R.Link.nextSub(B.link(w,1n+index)) == origin(w,tail) : Nat}}

def origin(-w: R.World,path: Path<w>) -> Nat:
  match path:
    case End{}: 0n
    case Edge{index,tail,linked}: 1n+index

def depth(-w: R.World,path: Path<w>) -> Nat:
  match path:
    case End{}: 0n
    case Edge{index,tail,linked}: 1n+depth(w,tail)

def empty(+fuel: Nat,+w: R.World) -> {W.insert_subs(fuel,w,0n) == w : R.World}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def nextLink(+w: R.World,+current: R.World,+edge: Nat,same: {Frame.observe(current) == Frame.observe(w) : R.World}) -> {R.Link.nextSub(B.link(current,edge)) == R.Link.nextSub(B.link(w,edge)) : Nat}:
  Equal.cong(List<&2,R.Link>,Nat,rows=>R.Link.nextSub(B.get(R.Link,rows,edge,B.blank_link())),R.World.links(current),R.World.links(w),Frame.sameLinks(w,current,same))

def flagged(+w: R.World,+edge: Nat) -> R.World:
  +link = B.link(w,edge)
  +id = R.Link.sub(link)
  +node = B.node(w,id)
  +missed = Bool.and(B.has(R.Node.flags(node),4),Bool.and(Nat.is_eq(R.Link.gen(link),R.Node.depGen(node)),Nat.is_ne(edge,R.Node.depsTail(node))))
  B.choose(~R.World,missed,_=>B.store_node(w,id,R.Node.with_flags(node,B.set(R.Node.flags(node),4096))),_=>w)

def flagsFrame(+w: R.World,+edge: Nat) -> {Frame.observe(flagged(w,edge)) == Frame.observe(w) : R.World}:
  +link = B.link(w,edge)
  +id = R.Link.sub(link)
  +node = B.node(w,id)
  +missed = Bool.and(B.has(R.Node.flags(node),4),Bool.and(Nat.is_eq(R.Link.gen(link),R.Node.depGen(node)),Nat.is_ne(edge,R.Node.depsTail(node))))
  Frame.choice(missed,w,B.store_node(w,id,R.Node.with_flags(node,B.set(R.Node.flags(node),4096))),w,Frame.flags(w,id,B.set(R.Node.flags(node),4096)),{==})

def enqueued(+w: R.World,+edge: Nat) -> R.World:
  H.enqueueSub(flagged(w,edge),R.Link.sub(B.link(w,edge)))

def enqueueFrame(+w: R.World,+edge: Nat,known: {R.World.marked(w) == False{} : Bool}) -> {Frame.observe(enqueued(w,edge)) == Frame.observe(w) : R.World}:
  Frame.compose(w,flagged(w,edge),enqueued(w,edge),Heap.enqueue(flagged(w,edge),R.Link.sub(B.link(w,edge)),Frame.unmarked(w,flagged(w,edge),flagsFrame(w,edge),known)),flagsFrame(w,edge))

def step(+w: R.World,+index: Nat,+fuel: Nat) -> {W.insert_subs(1n+fuel,w,1n+index) == W.insert_subs(fuel,enqueued(w,1n+index),R.Link.nextSub(B.link(w,1n+index))) : R.World}:
  {==}
