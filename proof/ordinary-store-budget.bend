# Actual existing-slot stores preserve budget and membership; pending writes
# additionally preserve the source subscriber head. No new graph is fabricated.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./node-store-lookup.bend as Lens
import ./ordinary-write-outer.bend as Frame

def budget(+w: R.World,+id: Nat,+record: R.Node) -> {B.budget(B.store_node(w,id,record)) == B.budget(w) : Nat}:
  +next = B.store_node(w,id,record)
  Equal.trans(Nat,B.budget(next),Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,R.World.links(next)))),B.budget(w),Equal.cong(Nat,Nat,n=>Nat.mul(4n,Nat.add(n,B.length(R.Link,R.World.links(next)))),B.length(R.Node,R.World.nodes(next)),B.length(R.Node,R.World.nodes(w)),Lens.nodeLength(w,id,record)),Equal.cong(List<&2,R.Link>,Nat,links=>Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,links))),R.World.links(next),R.World.links(w),Frame.sameLinks(w,next,Frame.storeNode(w,id,record))))

def valid(+w: R.World,+id: Nat,+record: R.Node,known: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {Nat.is_lt(id,B.length(R.Node,R.World.nodes(B.store_node(w,id,record)))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(B.store_node(w,id,record)))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(id,n),B.length(R.Node,R.World.nodes(B.store_node(w,id,record))),B.length(R.Node,R.World.nodes(w)),Lens.nodeLength(w,id,record)),known)

def pendingSubs(+node: R.Node,+slot: R.Slot) -> {R.Node.subs(R.Node.with_pending(node,slot)) == R.Node.subs(node) : Nat}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}: {==}

def head(+w: R.World,+id: Nat,+value: R.Value,+edge: Nat,room: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},known: {R.Node.subs(B.node(w,id)) == edge : Nat}) -> {R.Node.subs(B.node(B.store_node(w,id,R.Node.with_pending(B.node(w,id),R.Present{value})),id)) == edge : Nat}:
  +record = R.Node.with_pending(B.node(w,id),R.Present{value})
  Equal.trans(Nat,R.Node.subs(B.node(B.store_node(w,id,record),id)),R.Node.subs(record),edge,Equal.cong(R.Node,Nat,node=>R.Node.subs(node),B.node(B.store_node(w,id,record),id),record,Lens.nodeSame(w,id,record,room)),Equal.trans(Nat,R.Node.subs(record),R.Node.subs(B.node(w,id)),edge,pendingSubs(B.node(w,id),R.Present{value}),known))
