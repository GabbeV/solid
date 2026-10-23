# A source snapshot, not an initial-program or reachability axiom. The
# transfer functions derive its next facts from actual graph/ownership frames.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as X
import ./transaction-rendered.bend as Graph
import ./completion-graph-frame.bend as Frame
import ./transaction-positive.bend as Positive

type Ownership is Data:
  Ownership{nodes: List<&2, Nat>, into: Nat}

def ownership(+record: R.Transaction) -> Ownership:
  Ownership{R.Transaction.nodes(record), R.Transaction.into(record)}

def owned(value: Ownership) -> List<&2, Nat>:
  match value:
    case Ownership{nodes, into}: nodes

def redirect(value: Ownership) -> Nat:
  match value:
    case Ownership{nodes, into}: into

def guardNode(+n: R.Node) -> Bool:
  Bool.or(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.or(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()), B.has(R.Node.config(n), K.CONFIG_GUESS())))

def guardSame(+w: R.World, +next: R.World, +id: Nat,
  same: {Frame.graph(next) == Frame.graph(w) : Frame.GraphFrame}) ->
  {Graph.guard(next, id) == Graph.guard(w, id) : Bool}:
  Equal.cong(R.Node, Bool, n => guardNode(n), B.node(next, id), B.node(w, id), Frame.node(w, next, id, same))

def skips(+w: R.World, +next: R.World, +owner: Nat, prefix: Graph.Skips<w, owner>,
  +same: {Frame.graph(next) == Frame.graph(w) : Frame.GraphFrame}) -> Graph.Skips<next, owner>:
  match prefix:
    case Graph.NoSkips{}: Graph.NoSkips{}
    case Graph.Skip{+id, inactive, rest}:
      Graph.Skip{id, Equal.trans(Bool, Graph.guard(next, id), Graph.guard(w, id), True{}, guardSame(w, next, id, same), inactive), skips(w, next, owner, rest, same)}

def skipIds(+w: R.World, +next: R.World, +owner: Nat, +prefix: Graph.Skips<w, owner>,
  +same: {Frame.graph(next) == Frame.graph(w) : Frame.GraphFrame}) ->
  {Graph.ids(next, owner, skips(w, next, owner, prefix, same)) == Graph.ids(w, owner, prefix) : List<&2, Nat>}:
  match prefix:
    case Graph.NoSkips{}: {==}
    case Graph.Skip{+id, inactive, +rest}:
      Equal.cong(List<&2, Nat>, List<&2, Nat>, ids => id <> ids, Graph.ids(next, owner, skips(w, next, owner, rest, same)), Graph.ids(w, owner, rest), skipIds(w, next, owner, rest, same))

type Pending<-w: R.World, -owner: Nat> is Data:
  Pending{prefix: Graph.Skips<w, owner>, id: Nat, tail: List<&2, Nat>,
    owns: {R.Transaction.nodes(B.transaction(w, owner)) == B.append(Nat, Graph.ids(w, owner, prefix), id <> tail) : List<&2, Nat>},
    active: {Graph.guard(w, id) == False{} : Bool},
    capture: {R.NodeExtension.transaction(B.extension(w, id)) == owner : Nat},
    stopped: {R.Transaction.into(B.transaction(w, owner)) == 0n : Nat},
    rendered: {X.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool},
    live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}}

def transfer(+w: R.World, +next: R.World, +owner: Nat, snapshot: Pending<w, owner>,
  +same: {Frame.graph(next) == Frame.graph(w) : Frame.GraphFrame},
  +core: {ownership(B.transaction(next, owner)) == ownership(B.transaction(w, owner)) : Ownership}) -> Pending<next, owner>:
  match snapshot:
    case Pending{+prefix, +id, +tail, owns, active, capture, stopped, rendered, live}:
      +nextPrefix = skips(w, next, owner, prefix, same)
      Pending{nextPrefix, id, tail,
        Equal.trans(List<&2, Nat>, R.Transaction.nodes(B.transaction(next, owner)), R.Transaction.nodes(B.transaction(w, owner)), B.append(Nat, Graph.ids(next, owner, nextPrefix), id <> tail),
          Equal.cong(Ownership, List<&2, Nat>, value => owned(value), ownership(B.transaction(next, owner)), ownership(B.transaction(w, owner)), core),
          Equal.trans(List<&2, Nat>, R.Transaction.nodes(B.transaction(w, owner)), B.append(Nat, Graph.ids(w, owner, prefix), id <> tail), B.append(Nat, Graph.ids(next, owner, nextPrefix), id <> tail), owns,
            Equal.cong(List<&2, Nat>, List<&2, Nat>, ids => B.append(Nat, ids, id <> tail), Graph.ids(w, owner, prefix), Graph.ids(next, owner, nextPrefix), Equal.sym(List<&2, Nat>, Graph.ids(next, owner, nextPrefix), Graph.ids(w, owner, prefix), skipIds(w, next, owner, prefix, same))))),
        Equal.trans(Bool, Graph.guard(next, id), Graph.guard(w, id), False{}, guardSame(w, next, id, same), active),
        Equal.trans(Nat, R.NodeExtension.transaction(B.extension(next, id)), R.NodeExtension.transaction(B.extension(w, id)), owner, Equal.cong(R.NodeExtension, Nat, record => R.NodeExtension.transaction(record), B.extension(next, id), B.extension(w, id), Frame.extension(w, next, id, same)), capture),
        Equal.trans(Nat, R.Transaction.into(B.transaction(next, owner)), R.Transaction.into(B.transaction(w, owner)), 0n, Equal.cong(Ownership, Nat, value => redirect(value), ownership(B.transaction(next, owner)), ownership(B.transaction(w, owner)), core), stopped),
        Equal.trans(Bool, X.isRender(R.Node.kind(B.node(next, id))), X.isRender(R.Node.kind(B.node(w, id))), True{}, Equal.cong(R.Node, Bool, n => X.isRender(R.Node.kind(n)), B.node(next, id), B.node(w, id), Frame.node(w, next, id, same)), rendered),
        Equal.trans(Bool, B.has(R.Node.flags(B.node(next, id)), K.REACTIVE_ZOMBIE()), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), False{}, Equal.cong(R.Node, Bool, n => B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE()), B.node(next, id), B.node(w, id), Frame.node(w, next, id, same)), live)}

def enter(+w: R.World, +owner: Nat, snapshot: Pending<w, owner>) -> Pending<Positive.enter(w, owner), owner>:
  transfer(w, Positive.enter(w, owner), owner, snapshot, Frame.entered(w, owner),
    Equal.cong(R.Transaction, Ownership, record => ownership(record), B.transaction(Positive.enter(w, owner), owner), B.transaction(w, owner), Positive.readEntered(w, owner)))

def zeroEntered(+w: R.World, +predecessor: Nat, snapshot: Pending<Positive.enter(w, 1n+predecessor), 1n+predecessor>,
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat}) ->
  {X.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  match snapshot:
    case Pending{prefix, id, tail, owns, active, capture, stopped, rendered, live}:
      Graph.renderGroup(w, predecessor, prefix, id, tail, healthy, zero, owns, active, capture, stopped, rendered, live)

def zero(+w: R.World, +predecessor: Nat, snapshot: Pending<w, 1n+predecessor>,
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat}) ->
  {X.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  zeroEntered(w, predecessor, enter(w, 1n+predecessor, snapshot), healthy, zero)

def blocked(+w: R.World, +predecessor: Nat, +count: Nat, snapshot: Pending<w, 1n+predecessor>,
  healthy: {B.ok(w) == True{} : Bool},
  current: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == count : Nat}) ->
  {X.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  match count:
    case 0n: zero(w, predecessor, snapshot, healthy, current)
    case 1n+remaining: Positive.public(w, 1n+predecessor, remaining, healthy, current)

def openOwnership(+record: R.Transaction, count: Nat) ->
  {ownership(R.Transaction.with_open(record, count)) == ownership(record) : Ownership}:
  match record:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}
