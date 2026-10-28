# Successful parking of an allocated, unowned, childless node whose equals
# option is false. All premises name initial fields/guards, not a later result.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/equality.bend as EQ
import ../runtime/constants.bend as K
import ./held-node-listing.bend as Listing
import ./held-frame-leaf.bend as Leaf
import ./list-update-lookup.bend as Logic
import ./park-transaction-frame.bend as Parking

type Ready<-w: R.World,-id: Nat,-offset: Nat> is Data:
  LeafAt{slot: Nat,valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},extensionRoom: {Nat.is_lt(1n+slot,B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool},groupRoom: {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool},unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat},child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat},eligible: {S.parkEligible(w,id) == True{} : Bool},pending: {B.present(R.Node.pending(B.node(w,id))) == True{} : Bool},custom: {EQ.custom(w,id) == 0n : Nat},equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}}

def nonempty(+nodes: List<&2,R.Node>,+id: Nat,valid: {Nat.is_lt(id,B.length(R.Node,nodes)) == True{} : Bool}) -> {List.is_empty(&2,R.Node,nodes) == False{} : Bool}:
  match nodes id:
    case Nil{} 0n: Empty.absurd({True{} == False{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},valid)))
    case Nil{} 1n+p: Empty.absurd({True{} == False{} : Bool},Logic.impossible(Equal.sym(Bool,False{},True{},valid)))
    case head <> tail n: {==}

def heldChild(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat},child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {R.Node.firstChild(B.node(X.holdNode(w,id,1n+offset),id)) == 0n : Nat}:
  Equal.trans(Nat,R.Node.firstChild(B.node(X.holdNode(w,id,1n+offset),id)),R.Node.firstChild(Listing.record(w,id)),0n,Equal.cong(R.Node,Nat,entry=>R.Node.firstChild(entry),B.node(X.holdNode(w,id,1n+offset),id),Listing.record(w,id),Listing.read(w,id,offset,slot,valid,allocated,unowned)),Equal.trans(Nat,R.Node.firstChild(Listing.record(w,id)),R.Node.firstChild(B.node(w,id)),0n,Listing.configChild(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD())),child))

def heldFrame(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat},+child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {X.holdFrame(X.holdNode(w,id,1n+offset),id,1n+offset) == X.holdNode(w,id,1n+offset) : R.World}:
  +next = X.holdNode(w,id,1n+offset)
  +notEmpty = Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(next)),List.is_empty(&2,R.Node,R.World.nodes(w)),False{},Listing.heldEmpty(w,id,offset,slot,valid,allocated,unowned),nonempty(R.World.nodes(w),id,valid))
  Leaf.leaf(next,id,1n+offset,heldChild(w,id,offset,slot,valid,allocated,unowned,child),notEmpty)

def conditionalFrame(+flag: Bool,+w: R.World,+id: Nat,+tx: Nat,same: {X.holdFrame(w,id,tx) == w : R.World}) -> {B.choose(~R.World,flag,_=>X.holdFrame(w,id,tx),_=>w) == w : R.World}:
  match flag:
    case True{}: same
    case False{}: {==}

def changed(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat},+child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {S.parkChanged(w,id,1n+offset,True{}) == X.holdNode(w,id,1n+offset) : R.World}:
  +next = X.holdNode(w,id,1n+offset)
  conditionalFrame(B.has(R.Node.config(B.node(next,id)),K.CONFIG_STAGED()),next,id,1n+offset,heldFrame(w,id,offset,slot,valid,allocated,unowned,child))

def loading(+w: R.World,+id: Nat,pending: {B.present(R.Node.pending(B.node(w,id))) == True{} : Bool}) -> {S.parkLoading(w,id) == False{} : Bool}:
  Equal.cong(Bool,Bool,present=>Bool.and(Bool.not(present),Bool.and(B.has(R.Node.status(B.node(w,id)),K.STATUS_UNINITIALIZED()),Bool.not(X.isRender(R.Node.kind(B.node(w,id)))))),B.present(R.Node.pending(B.node(w,id))),True{},pending)

def different(+w: R.World,+id: Nat,equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}) -> {EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))) == False{} : Bool}:
  Equal.cong(Bool,Bool,enabled=>Bool.and(enabled,B.equal(R.Node.value(B.node(w,id)),B.current(B.node(w,id)))),R.Node.equals(B.node(w,id)),False{},equals)

def compared(+w: R.World,+id: Nat,+tx: Nat,custom: {EQ.custom(w,id) == 0n : Nat},equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}) -> {Parking.compare(w,id,tx,True{}) == S.parkChanged(w,id,tx,True{}) : R.World}:
  +noCustom = Equal.cong(Nat,R.World,method=>B.choose(~R.World,Nat.is_ne(method,0n),_=>R.World.with_fault(w,R.Unsupported{23n}),_=>B.choose(~R.World,EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,True{}))),EQ.custom(w,id),0n,custom)
  +unequal = Equal.cong(Bool,R.World,same=>B.choose(~R.World,same,_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,True{})),EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),False{},different(w,id,equals))
  Equal.trans(R.World,Parking.compare(w,id,tx,True{}),B.choose(~R.World,EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,True{})),S.parkChanged(w,id,tx,True{}),noCustom,unequal)

def maybeCompare(+flag: Bool,+w: R.World,+id: Nat,+tx: Nat,custom: {EQ.custom(w,id) == 0n : Nat},equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}) -> {B.choose(~R.World,flag,_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{})) == S.parkChanged(w,id,tx,True{}) : R.World}:
  match flag:
    case True{}: compared(w,id,tx,custom,equals)
    case False{}: {==}

def select(+w: R.World,+id: Nat,+tx: Nat,pending: {B.present(R.Node.pending(B.node(w,id))) == True{} : Bool},custom: {EQ.custom(w,id) == 0n : Nat},equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}) -> {Parking.select(w,id,tx,True{}) == S.parkChanged(w,id,tx,True{}) : R.World}:
  +skip = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>w,_=>B.choose(~R.World,S.parkCanCompare(w,id),_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{}))),S.parkLoading(w,id),False{},loading(w,id,pending))
  Equal.trans(R.World,Parking.select(w,id,tx,True{}),B.choose(~R.World,S.parkCanCompare(w,id),_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{})),S.parkChanged(w,id,tx,True{}),skip,maybeCompare(S.parkCanCompare(w,id),w,id,tx,custom,equals))

def normal(+w: R.World,+id: Nat,+tx: Nat,eligible: {S.parkEligible(w,id) == True{} : Bool},pending: {B.present(R.Node.pending(B.node(w,id))) == True{} : Bool},custom: {EQ.custom(w,id) == 0n : Nat},equals: {R.Node.equals(B.node(w,id)) == False{} : Bool}) -> {S.parkPendingNode(w,id,tx) == S.parkChanged(w,id,tx,True{}) : R.World}:
  Equal.trans(R.World,S.parkPendingNode(w,id,tx),Parking.select(w,id,tx,True{}),S.parkChanged(w,id,tx,True{}),Equal.cong(Bool,R.World,flag=>Parking.select(w,id,tx,flag),S.parkEligible(w,id),True{},eligible),select(w,id,tx,pending,custom,equals))

def actual(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id,offset>) -> {S.parkPendingNode(w,id,1n+offset) == X.holdNode(w,id,1n+offset) : R.World}:
  match ready:
    case LeafAt{slot,valid,allocated,extensionRoom,groupRoom,unowned,child,eligible,pending,custom,equals}:
      Equal.trans(R.World,S.parkPendingNode(w,id,1n+offset),S.parkChanged(w,id,1n+offset,True{}),X.holdNode(w,id,1n+offset),normal(w,id,1n+offset,eligible,pending,custom,equals),changed(w,id,offset,slot,valid,allocated,unowned,child))

def health(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id,offset>) -> {B.ok(S.parkPendingNode(w,id,1n+offset)) == B.ok(w) : Bool}:
  match ready:
    case LeafAt{+slot,+valid,+allocated,+extensionRoom,+groupRoom,+unowned,+child,+eligible,+pending,+custom,+equals}:
      +initial = {LeafAt{slot,valid,allocated,extensionRoom,groupRoom,unowned,child,eligible,pending,custom,equals} : Ready<w,id,offset>}
      Equal.trans(Bool,B.ok(S.parkPendingNode(w,id,1n+offset)),B.ok(X.holdNode(w,id,1n+offset)),B.ok(w),Equal.cong(R.World,Bool,state=>B.ok(state),S.parkPendingNode(w,id,1n+offset),X.holdNode(w,id,1n+offset),actual(w,id,offset,initial)),Listing.heldHealth(w,id,offset,slot,valid,allocated,unowned))
