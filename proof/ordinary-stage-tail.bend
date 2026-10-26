# Source stageResolved tail for a plain signal in imperative context. Promotion
# and computed-node time updates are excluded by derived input facts, not skipped
# in the runtime. The actual notification/scheduling branches remain present.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/read-state.bend as Read
import ./staging-committed-frame.bend as Stage
import ./ordinary-write-outer.bend as Frame
import ./ordinary-store-budget.bend as Store
import ./subscriber-walk-step.bend as Path
import ./subscriber-notification-health.bend as Notify

def put(+w: R.World,+id: Nat,value: R.Value) -> R.World:
  B.store_node(w,id,R.Node.with_pending(B.node(w,id),R.Present{value}))

def last(+w: R.World,+id: Nat,+node: R.Node,+staged: Bool) -> R.World:
  B.choose(~R.World,Bool.and(staged,B.stampMatches(R.Node.notified(node),R.World.epoch(w))),_=>w,_=>B.schedule(W.insertSubs(w,id)))

def timed(+w: R.World,+id: Nat,+node: R.Node,+staged: Bool) -> R.World:
  +next = B.choose(~R.World,B.computed(R.Node.kind(node)),_=>B.store_node(w,id,R.Node.with_time(B.node(w,id),R.World.clock(w))),_=>w)
  last(next,id,node,staged)

def plainTime(+w: R.World,+id: Nat,+node: R.Node,+staged: Bool,signal: {R.Node.kind(node) == R.Signal{} : R.NodeKind}) -> {timed(w,id,node,staged) == last(w,id,node,staged) : R.World}:
  Equal.cong(R.NodeKind,R.World,kind=>last(B.choose(~R.World,B.computed(kind),_=>B.store_node(w,id,R.Node.with_time(B.node(w,id),R.World.clock(w))),_=>w),id,node,staged),R.Node.kind(node),R.Signal{},signal)

def plain(+w: R.World,+id: Nat,+value: R.Value,+node: R.Node,+staged: Bool,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(node) == R.Signal{} : R.NodeKind}) -> {Stage.tail(w,id,value,node,staged) == last(put(w,id,value),id,node,staged) : R.World}:
  +next = put(w,id,value)
  +outside = Frame.context(w,next,Frame.storeNode(w,id,R.Node.with_pending(B.node(w,id),R.Present{value})),context)
  Equal.trans(R.World,Stage.tail(w,id,value,node,staged),timed(next,id,node,staged),last(next,id,node,staged),Equal.cong(Nat,R.World,owner=>timed(B.choose(~R.World,Nat.is_ne(owner,0n),_=>Read.notePromotedWrite(next,id),_=>next),id,node,staged),R.World.context(next),0n,outside),plainTime(next,id,node,staged,signal))

def lastFrame(+base: R.World,+path: Path.Path<base>,+w: R.World,+id: Nat,+node: R.Node,+staged: Bool,+extra: Nat,+same: {Frame.observe(w) == Frame.observe(base) : R.World},unmarked: {R.World.marked(base) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(base,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(base,path),extra) : Nat}) -> {Frame.observe(last(w,id,node,staged)) == Frame.observe(base) : R.World}:
  +notified = W.insertSubs(w,id)
  +scheduled = B.schedule(notified)
  Frame.choice(Bool.and(staged,B.stampMatches(R.Node.notified(node),R.World.epoch(w))),base,w,scheduled,same,Frame.compose(base,notified,scheduled,Frame.schedule(notified),Notify.publicFrom(base,path,w,id,extra,same,unmarked,valid,head,room)))

def frame(+base: R.World,+path: Path.Path<base>,+w: R.World,+id: Nat,+value: R.Value,+node: R.Node,+staged: Bool,+extra: Nat,+same: {Frame.observe(w) == Frame.observe(base) : R.World},unmarked: {R.World.marked(base) == False{} : Bool},+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(base,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(base,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(node) == R.Signal{} : R.NodeKind}) -> {Frame.observe(Stage.tail(w,id,value,node,staged)) == Frame.observe(base) : R.World}:
  +next = put(w,id,value)
  +record = R.Node.with_pending(B.node(w,id),R.Present{value})
  +nextFrame = Frame.compose(base,w,next,Frame.storeNode(w,id,record),same)
  +nextRoom = Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(base,path),extra),Store.budget(w,id,record),room)
  Equal.trans(R.World,Frame.observe(Stage.tail(w,id,value,node,staged)),Frame.observe(last(next,id,node,staged)),Frame.observe(base),Equal.cong(R.World,R.World,state=>Frame.observe(state),Stage.tail(w,id,value,node,staged),last(next,id,node,staged),plain(w,id,value,node,staged,context,signal)),lastFrame(base,path,next,id,node,staged,extra,nextFrame,unmarked,Store.valid(w,id,record,valid),Store.head(w,id,value,Path.origin(base,path),valid,head),nextRoom))
