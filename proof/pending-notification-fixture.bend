# Typed integration control: actual raw memo/render allocation/link, then an
# explicit incoming-status setup and the real notification local store helper.
# This does not evaluate public callbacks or execute propagation/flush.
import Base
import ../runtime/pending-state.bend as P
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./pending-notification-carrier.bend as Notify
import ./pending-carrier-cycle-fixture.bend as Input
import ./memo-render-registration-fixture.bend as Initial
import ./memo-render-fixture.bend as Values
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./pending-command-history.bend as Commands
import ./pending-carrier-state.bend as State
import ./single-carrier-frame.bend as Single
import ./carrier-status-writes.bend as Writes
import ./pending-one-edge-transport.bend as Transport
import ./graph-allocation-properties.bend as Storage
import ./node-store-lookup.bend as Store
import ./pending-fresh-carrier.bend as Fresh


type Incoming is Data:
  IncomingReady{}
  IncomingUninitialized{}
  IncomingNeverValued{}
  IncomingPending{}
  IncomingPendingUninitialized{}

def flags(incoming: Incoming) -> U32:
  match incoming:
    case IncomingReady{}: 0
    case IncomingUninitialized{}: K.STATUS_UNINITIALIZED()
    case IncomingNeverValued{}: K.STATUS_NO_VALUE()
    case IncomingPending{}: K.STATUS_PENDING()
    case IncomingPendingUninitialized{}: B.set(K.STATUS_PENDING(),K.STATUS_UNINITIALIZED())

def sourceExpr(value: R.Value) -> R.Expr:
  R.Literal{value}

def effectExpr() -> R.Expr:
  R.Literal{R.Undefined{}}

def root(values: List<&2,R.Value>) -> Nat:
  1n+B.length(R.Node,Values.nodes(values))

def leaf(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>) -> Nat:
  N.index(Pair.memo(Initial.input(values,extensions,sets),sourceExpr(value)))

def before(values: List<&2,R.Value>,value: R.Value,extensions: List<&2,R.NodeExtension>,sets: List<&2,List<&2,Nat>>) -> R.World:
  Input.initial(values,sourceExpr(value),effectExpr(),extensions,sets)

def initial(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,incoming: Incoming) -> R.World:
  +w = before(values,value,extensions,sets)
  +node = leaf(values,value,extensions,sets)
  B.store_node(w,node,R.Node.with_status(B.node(w,node),flags(incoming)))

def seed(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming) -> State.CarrierSnapshot<initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values))>:
  Writes.snapshotStatus(before(values,value,extensions,sets),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),flags(incoming),Input.seed(values,sourceExpr(value),effectExpr(),extensions,sets))

def validBefore(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>) -> {B.valid(before(values,value,extensions,sets),leaf(values,value,extensions,sets)) == True{} : Bool}:
  Commands.leafValid(before(values,value,extensions,sets),N.index(Initial.input(values,extensions,sets)),leaf(values,value,extensions,sets),0n,Pair.build(Initial.input(values,extensions,sets),sourceExpr(value),effectExpr(),7n,0n,0n,B.blank_node(),Values.nodes(values),B.blank_link(),[],{==},{==},{==},{==}))

def valid(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming) -> {B.valid(initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets)) == True{} : Bool}:
  +w = before(values,value,extensions,sets)
  +node = leaf(values,value,extensions,sets)
  Transport.valid(w,initial(values,value,extensions,sets,incoming),node,Storage.nodeStorage(w,node,R.Node.with_status(B.node(w,node),flags(incoming))),validBefore(values,value,extensions,sets))

def noErrorFlags(+incoming: Incoming) -> {B.has(flags(incoming),K.STATUS_ERROR()) == False{} : Bool}:
  match incoming:
    case IncomingReady{}: {==}
    case IncomingUninitialized{}: {==}
    case IncomingNeverValued{}: {==}
    case IncomingPending{}: {==}
    case IncomingPendingUninitialized{}: {==}

def noError(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming) -> {B.has(R.Node.status(B.node(initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets))),K.STATUS_ERROR()) == False{} : Bool}:
  +w = before(values,value,extensions,sets)
  +node = leaf(values,value,extensions,sets)
  +record = R.Node.with_status(B.node(w,node),flags(incoming))
  Equal.trans(Bool,B.has(R.Node.status(B.node(initial(values,value,extensions,sets,incoming),node)),K.STATUS_ERROR()),B.has(flags(incoming),K.STATUS_ERROR()),False{},Equal.cong(U32,Bool,status=>B.has(status,K.STATUS_ERROR()),R.Node.status(B.node(initial(values,value,extensions,sets,incoming),node)),flags(incoming),Equal.trans(U32,R.Node.status(B.node(initial(values,value,extensions,sets,incoming),node)),R.Node.status(record),flags(incoming),Equal.cong(R.Node,U32,n=>R.Node.status(n),B.node(initial(values,value,extensions,sets,incoming),node),record,Store.nodeSame(w,node,record,Fresh.nodeRoom(w,node,validBefore(values,value,extensions,sets)))),Notify.statusField(B.node(w,node),flags(incoming)))),noErrorFlags(incoming))

def after(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming,serial: Nat) -> R.World:
  Notify.notified(initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),serial)

def ready(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming,+serial: Nat) -> Single.Single<after(values,value,extensions,sets,incoming,serial),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values))>:
  Notify.single(initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),serial,seed(values,value,extensions,sets,incoming),noError(values,value,extensions,sets,incoming))

def member(+values: List<&2,R.Value>,+value: R.Value,+extensions: List<&2,R.NodeExtension>,+sets: List<&2,List<&2,Nat>>,+incoming: Incoming,+serial: Nat) -> {P.hasSource(after(values,value,extensions,sets,incoming,serial),leaf(values,value,extensions,sets),root(values)) == True{} : Bool}:
  Notify.member(initial(values,value,extensions,sets,incoming),leaf(values,value,extensions,sets),B.length(R.Node,Values.nodes(values)),serial,seed(values,value,extensions,sets,incoming),noError(values,value,extensions,sets,incoming))
