# Default parentless memo/render constructors. This includes their literal,
# append and setup writes, stopping before eager callback evaluation in Core.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ./default-node-literals.bend as Literal
import ./node-append-construction.bend as Append
import ./node-allocation-validity.bend as Valid
import ./parentless-node-construction.bend as Setup
import ./computed-setup-construction.bend as Parent
import ./pending-committed-history.bend as Logic

type Family is Data:
  Memo{}
  Render{target: Nat, program: Nat, cleanup: Nat}

def index(w: R.World) -> Nat:
  B.length(R.Node, R.World.nodes(w))

def literal(w: R.World, expr: R.Expr, which: Family) -> R.Node:
  match which:
    case Memo{}: Literal.memoRecord(w, expr)
    case Render{target, program, cleanup}: Literal.effectRecord(w, expr, target, program, cleanup)

def record(+w: R.World, expr: R.Expr, which: Family) -> R.Node:
  R.Node.with_prevHeap(literal(w, expr, which), index(w))

def source(w: R.World, expr: R.Expr, which: Family) -> R.World:
  match which:
    case Memo{}: N.computed(w, expr, N.defaults(), 0n)
    case Render{target, program, cleanup}: N.createEffectNode(w, expr, R.Render{}, target, N.defaults(), 0n, program, cleanup)

def prefix(+w: R.World, +expr: R.Expr, +which: Family) ->
  {source(w, expr, which) == N.setupComputedNode(N.append(w, literal(w, expr, which)), index(w)) : R.World}:
  match which:
    case Memo{}: Literal.memo(w, expr)
    case Render{target, program, cleanup}: Literal.effect(w, expr, target, program, cleanup)

def parent(+w: R.World, +expr: R.Expr, +which: Family) -> {R.Node.parent(literal(w, expr, which)) == 0n : Nat}:
  match which:
    case Memo{}: {==}
    case Render{target, program, cleanup}: {==}

def exact(+w: R.World, +expr: R.Expr, +which: Family,
  room: {Nat.is_lt(0n, index(w)) == True{} : Bool},
  nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {source(w, expr, which) == N.append(w, record(w, expr, which)) : R.World}:
  Equal.trans(R.World, source(w, expr, which), N.setupComputedNode(N.append(w, literal(w, expr, which)), index(w)), N.append(w, record(w, expr, which)), prefix(w, expr, which), Setup.exact(w, literal(w, expr, which), parent(w, expr, which), room, nullComputed))


def node(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {B.node(source(w, expr, which), index(w)) == record(w, expr, which) : R.Node}:
  Equal.trans(R.Node, B.node(source(w, expr, which), index(w)), B.node(N.append(w, record(w, expr, which)), index(w)), record(w, expr, which), Equal.cong(R.World, R.Node, state => B.node(state, index(w)), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.fresh(w, record(w, expr, which)))


def health(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {B.ok(source(w, expr, which)) == B.ok(w) : Bool}:
  Equal.trans(Bool, B.ok(source(w, expr, which)), B.ok(N.append(w, record(w, expr, which))), B.ok(w), Equal.cong(R.World, Bool, state => B.ok(state), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.health(w, record(w, expr, which)))


def links(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {R.World.links(source(w, expr, which)) == R.World.links(w) : List<&2, R.Link>}:
  Equal.trans(List<&2, R.Link>, R.World.links(source(w, expr, which)), R.World.links(N.append(w, record(w, expr, which))), R.World.links(w), Equal.cong(R.World, List<&2, R.Link>, state => R.World.links(state), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.links(w, record(w, expr, which)))


def count(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {B.length(R.Node, R.World.nodes(source(w, expr, which))) == Nat.add(index(w), 1n) : Nat}:
  Equal.trans(Nat, B.length(R.Node, R.World.nodes(source(w, expr, which))), B.length(R.Node, R.World.nodes(N.append(w, record(w, expr, which)))), Nat.add(index(w), 1n), Equal.cong(R.World, Nat, state => B.length(R.Node, R.World.nodes(state)), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.count(w, record(w, expr, which)))


def fresh(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}, +first: R.Node, +tail: List<&2, R.Node>, known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}) ->
  {B.valid(source(w, expr, which), index(w)) == True{} : Bool}:
  Equal.trans(Bool, B.valid(source(w, expr, which), index(w)), B.valid(N.append(w, record(w, expr, which)), index(w)), True{}, Equal.cong(R.World, Bool, state => B.valid(state, index(w)), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Valid.fresh(w, record(w, expr, which), first, tail, known))


def oldNode(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}, +read: Nat, fits: {Nat.is_lt(read, index(w)) == True{} : Bool}) ->
  {B.node(source(w, expr, which), read) == B.node(w, read) : R.Node}:
  Equal.trans(R.Node, B.node(source(w, expr, which), read), B.node(N.append(w, record(w, expr, which)), read), B.node(w, read), Equal.cong(R.World, R.Node, state => B.node(state, read), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.oldNode(w, record(w, expr, which), read, fits))


def oldValid(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}, +read: Nat, known: {B.valid(w, read) == True{} : Bool}) ->
  {B.valid(source(w, expr, which), read) == True{} : Bool}:
  Equal.trans(Bool, B.valid(source(w, expr, which), read), B.valid(N.append(w, record(w, expr, which)), read), True{}, Equal.cong(R.World, Bool, state => B.valid(state, read), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Valid.old(w, record(w, expr, which), read, known))


def nullComputed(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {B.parentComputed(source(w, expr, which), 0n) == 0n : Nat}:
  Equal.trans(Nat, B.parentComputed(source(w, expr, which), 0n), B.parentComputed(N.append(w, record(w, expr, which)), 0n), 0n, Equal.cong(R.World, Nat, state => B.parentComputed(state, 0n), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Equal.trans(Nat, B.parentComputed(N.append(w, record(w, expr, which)), 0n), B.parentComputed(w, 0n), 0n, Parent.computedFromNode(w, N.append(w, record(w, expr, which)), Append.oldNode(w, record(w, expr, which), 0n, room)), nullComputed))


def arena(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +first: R.Node, +tail: List<&2, R.Node>, known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}) ->
  {R.World.nodes(source(w, expr, which)) == first <> B.append(R.Node, tail, [record(w, expr, which)]) : List<&2, R.Node>}:
  Equal.trans(List<&2, R.Node>, R.World.nodes(source(w, expr, which)), B.append(R.Node, R.World.nodes(w), [record(w, expr, which)]), first <> B.append(R.Node, tail, [record(w, expr, which)]),
    Equal.trans(List<&2, R.Node>, R.World.nodes(source(w, expr, which)), R.World.nodes(N.append(w, record(w, expr, which))), B.append(R.Node, R.World.nodes(w), [record(w, expr, which)]), Equal.cong(R.World, List<&2, R.Node>, state => R.World.nodes(state), source(w, expr, which), N.append(w, record(w, expr, which)), exact(w, expr, which, room, nullComputed)), Append.nodes(w, record(w, expr, which))), Equal.cong(List<&2, R.Node>, List<&2, R.Node>, xs => B.append(R.Node, xs, [record(w, expr, which)]), R.World.nodes(w), first <> tail, known))

def zeroRoom(+w: R.World, +expr: R.Expr, +which: Family, +room: {Nat.is_lt(0n, index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {Nat.is_lt(0n, B.length(R.Node, R.World.nodes(source(w, expr, which)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(0n, B.length(R.Node, R.World.nodes(source(w, expr, which)))), Nat.is_lt(0n, Nat.add(index(w), 1n)), True{}, Equal.cong(Nat, Bool, size => Nat.is_lt(0n, size), B.length(R.Node, R.World.nodes(source(w, expr, which))), Nat.add(index(w), 1n), count(w, expr, which, room, nullComputed)), Valid.extend(0n, index(w), room))
