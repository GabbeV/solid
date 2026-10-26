# Source notify/insertSubs prefix uses its actual arena budget and stored head.
# A path certificate and input identity/room facts supply successful traversal.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ./node-store-lookup.bend as Lens
import ./subscriber-walk-step.bend as Step
import ./subscriber-walk-health.bend as Walk
import ./ordinary-write-outer.bend as Frame

def record(+w: R.World,id: Nat) -> R.Node:
  R.Node.with_notified(B.node(w,id),R.Stamped{R.World.epoch(w)})

def notified(+w: R.World,+id: Nat) -> R.World:
  B.store_node(w,id,record(w,id))

def storedFrame(+w: R.World,+id: Nat) -> {Frame.observe(notified(w,id)) == Frame.observe(w) : R.World}:
  Frame.storeNode(w,id,record(w,id))

def budget(+w: R.World,+id: Nat) -> {B.budget(notified(w,id)) == B.budget(w) : Nat}:
  Equal.trans(Nat,B.budget(notified(w,id)),Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,R.World.links(notified(w,id))))),B.budget(w),Equal.cong(Nat,Nat,n=>Nat.mul(4n,Nat.add(n,B.length(R.Link,R.World.links(notified(w,id))))),B.length(R.Node,R.World.nodes(notified(w,id))),B.length(R.Node,R.World.nodes(w)),Lens.nodeLength(w,id,record(w,id))),Equal.cong(List<&2,R.Link>,Nat,links=>Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,links))),R.World.links(notified(w,id)),R.World.links(w),Frame.sameLinks(w,notified(w,id),storedFrame(w,id))))

def subsStamp(+node: R.Node,+stamp: R.Stamp) -> {R.Node.subs(R.Node.with_notified(node,stamp)) == R.Node.subs(node) : Nat}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}: {==}

def head(+w: R.World,+id: Nat,+edge: Nat,valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},known: {R.Node.subs(B.node(w,id)) == edge : Nat}) -> {R.Node.subs(B.node(notified(w,id),id)) == edge : Nat}:
  Equal.trans(Nat,R.Node.subs(B.node(notified(w,id),id)),R.Node.subs(record(w,id)),edge,Equal.cong(R.Node,Nat,node=>R.Node.subs(node),B.node(notified(w,id),id),record(w,id),Lens.nodeSame(w,id,record(w,id),valid)),Equal.trans(Nat,R.Node.subs(record(w,id)),R.Node.subs(B.node(w,id)),edge,subsStamp(B.node(w,id),R.Stamped{R.World.epoch(w)}),known))

def publicFrom(+base: R.World,+path: Step.Path<base>,+w: R.World,+id: Nat,+extra: Nat,same: {Frame.observe(w) == Frame.observe(base) : R.World},unmarked: {R.World.marked(base) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},matches: {R.Node.subs(B.node(w,id)) == Step.origin(base,path) : Nat},room: {B.budget(w) == Nat.add(Step.depth(base,path),extra) : Nat}) -> {Frame.observe(W.insertSubs(w,id)) == Frame.observe(base) : R.World}:
  +next = notified(w,id)
  +fuel = Nat.add(Step.depth(base,path),extra)
  +edge = Step.origin(base,path)
  +fits = Equal.trans(Nat,B.budget(next),B.budget(w),fuel,budget(w,id),room)
  +shift = Equal.cong(Nat,R.World,n=>Frame.observe(W.insert_subs(n,next,R.Node.subs(B.node(next,id)))),B.budget(next),fuel,fits)
  +selected = Equal.cong(Nat,R.World,e=>Frame.observe(W.insert_subs(fuel,next,e)),R.Node.subs(B.node(next,id)),edge,head(w,id,edge,valid,matches))
  Equal.trans(R.World,Frame.observe(W.insertSubs(w,id)),Frame.observe(W.insert_subs(fuel,next,R.Node.subs(B.node(next,id)))),Frame.observe(base),shift,Equal.trans(R.World,Frame.observe(W.insert_subs(fuel,next,R.Node.subs(B.node(next,id)))),Frame.observe(W.insert_subs(fuel,next,edge)),Frame.observe(base),selected,Walk.walk(base,path,next,extra,Frame.compose(base,w,next,storedFrame(w,id),same),unmarked)))
