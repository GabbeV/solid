# The allocated singleton alternative is constructed from the prior actual
# add/remove invariant, then transported through checked carrier-field frames.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-carrier-state.bend as State
import ./pending-carrier-retirement.bend as Retire
import ./carrier-field-frame.bend as Field
import ./list-update-lookup.bend as Logic

type Single<-w: R.World, -node: Nat, -source: Nat> is Data:
  Single{extension: Nat, set: Nat, sets: List<&2, List<&2, Nat>>, allocated: {R.Node.x(B.node(w,node)) == 1n+extension : Nat}, room: {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}, pointer: {R.NodeExtension.pendingSources(B.extension(w,node)) == 1n+set : Nat}, slots: {B.pendingSlots(w,1n+set) == [1n+source] : List<&2,Nat>}, setRoom: {Nat.is_lt(1n+set,B.length(List<&2,Nat>,R.World.pendingSets(w))) == True{} : Bool}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2,List<&2,Nat>>}}

def fromSnapshot(-w: R.World, -node: Nat, -source: Nat, +snapshot: State.CarrierSnapshot<w,node,source>, present: {State.present(w,node,source,snapshot) == True{} : Bool}) -> Single<w,node,source>:
  match snapshot:
    case State.CarrierFresh{extensions,sets,valid,empty,extensionArena,setArena}: Empty.absurd(Single<w,node,source>,Logic.impossible(Equal.sym(Bool,False{},True{},present)))
    case State.CarrierEmpty{extension,sets,allocated,room,empty,setArena}: Empty.absurd(Single<w,node,source>,Logic.impossible(Equal.sym(Bool,False{},True{},present)))
    case State.CarrierSingle{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}

def snapshot(-w: R.World,-node: Nat,-source: Nat,single: Single<w,node,source>) -> State.CarrierSnapshot<w,node,source>:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: State.CarrierSingle{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}

def member(+w: R.World,+node: Nat,+source: Nat,single: Single<w,node,source>) -> {P.hasSource(w,node,1n+source) == True{} : Bool}:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: Retire.singletonPresent(w,node,source,set,pointer,slots)

def move(+a: R.World,+b: R.World,+node: Nat,+source: Nat,frame: Field.Frame<a,b,node>,single: Single<a,node,source>) -> Single<b,node,source>:
  match frame single:
    case Field.Frame{x,count,range,pending,+storage} Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}:
      Single{extension,set,sets,
        Equal.trans(Nat,R.Node.x(B.node(b,node)),R.Node.x(B.node(a,node)),1n+extension,x,allocated),
        Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(b,node)),B.length(R.NodeExtension,R.World.extensions(b))),Nat.is_lt(R.Node.x(B.node(a,node)),B.length(R.NodeExtension,R.World.extensions(a))),True{},range,room),
        Equal.trans(Nat,R.NodeExtension.pendingSources(B.extension(b,node)),R.NodeExtension.pendingSources(B.extension(a,node)),1n+set,pending,pointer),
        Equal.trans(List<&2,Nat>,B.pendingSlots(b,1n+set),B.pendingSlots(a,1n+set),[1n+source],Equal.cong(List<&2,List<&2,Nat>>,List<&2,Nat>,xs=>B.get(List<&2,Nat>,xs,1n+set,[]),R.World.pendingSets(b),R.World.pendingSets(a),storage),slots),
        Equal.trans(Bool,Nat.is_lt(1n+set,B.length(List<&2,Nat>,R.World.pendingSets(b))),Nat.is_lt(1n+set,B.length(List<&2,Nat>,R.World.pendingSets(a))),True{},Equal.cong(List<&2,List<&2,Nat>>,Bool,xs=>Nat.is_lt(1n+set,B.length(List<&2,Nat>,xs)),R.World.pendingSets(b),R.World.pendingSets(a),storage),setRoom),
        Equal.trans(List<&2,List<&2,Nat>>,R.World.pendingSets(b),R.World.pendingSets(a),[] <> sets,storage,setArena)}

def allocated(-w: R.World,-node: Nat,-source: Nat,single: Single<w,node,source>) -> Nat:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: extension

def pointer(+w: R.World,+node: Nat,+source: Nat,+single: Single<w,node,source>) -> {R.Node.x(B.node(w,node)) == 1n+allocated(w,node,source,single) : Nat}:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: allocated

def room(+w: R.World,+node: Nat,+source: Nat,single: Single<w,node,source>) -> {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}: room


def shift(-a: R.World,-b: R.World,-node: Nat,-source: Nat,+same: {a == b : R.World},single: Single<a,node,source>) -> Single<b,node,source>:
  match single:
    case Single{extension,set,sets,allocated,room,pointer,slots,setRoom,setArena}:
      Single{extension,set,sets,State.shift_allocated(a,b,node,extension,same,allocated),State.shift_room(a,b,node,same,room),State.shift_pointer(a,b,node,set,same,pointer),State.shift_slots(a,b,node,source,set,same,slots),State.shift_setRoom(a,b,set,same,setRoom),State.shift_setArena(a,b,sets,same,setArena)}
