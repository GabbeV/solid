import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./core.bend as C
import ./scheduler.bend as S
import ./graph.bend as G
import ./heap.bend as H
import ./owner.bend as O

def linkChild(+w: R.World, +parent: Nat, +id: Nat) -> R.World:
  +head = R.Node.firstChild(B.node(w, parent))
  +n = R.Node.with_nextSibling(R.Node.with_prevSibling(B.node(w, id), 0n), head)
  +w = B.store_node(w, id, n)
  +w = B.choose(~R.World, Nat.is_ne(head, 0n),
    _ => B.store_node(w, head, R.Node.with_prevSibling(B.node(w, head), id)), _ => w)
  B.store_node(w, parent, R.Node.with_firstChild(B.node(w, parent), id))

def allocate(+w: R.World, +kind: R.NodeKind, expr: R.Expr, value: R.Value, equals: Bool, +parent: Nat, target: Nat, lazy: Bool) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +n = R.Node.with_kind(B.blank_node(), kind)
  +n = R.Node.with_expr(n, expr)
  +n = R.Node.with_value(n, value)
  +n = R.Node.with_equals(n, equals)
  +n = R.Node.with_parent(n, parent)
  +n = R.Node.with_target(n, target)
  +n = R.Node.with_prevHeap(n, id)
  +n = R.Node.with_flags(n, B.choose(~U32, lazy, _ => 512, _ => 0))
  +n = R.Node.with_status(n, B.choose(~U32, B.computed(kind), _ => 4, _ => 0))
  +n = R.Node.with_config(n, 64)
  +n = R.Node.with_time(n, R.World.clock(w))
  +w = R.World.with_nodes(w, B.append(R.Node, R.World.nodes(w), [n]))
  B.choose(~R.World, Nat.is_ne(parent, 0n), _ => linkChild(w, parent, id), _ => w)

# One explicit lifetime root for the supported grammar. No implicit roots are
# minted per callback. rootId is 1; signal/computed identities start at 2.
def createWorld() -> R.World:
  allocate(B.empty(), R.Root{}, R.Literal{R.Undefined{}}, R.Undefined{}, True{}, 0n, 0n, False{})

def nextId(w: R.World) -> Nat:
  B.length(R.Node, R.World.nodes(w))

def createSignal(w: R.World, value: R.Value, equals: Bool) -> R.World:
  allocate(w, R.Signal{}, R.Literal{R.Undefined{}}, value, equals, 0n, 0n, False{})

def createMemo(fuel: Nat, +w: R.World, expr: R.Expr, equals: Bool, +lazy: Bool, parent: Nat) -> R.World:
  +id = nextId(w)
  +w = allocate(w, R.Memo{}, expr, R.Undefined{}, equals, parent, 0n, lazy)
  B.choose(~R.World, lazy, _ => w,
    _ => C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}], []})))

def createEffect(fuel: Nat, +w: R.World, expr: R.Expr, user: Bool, target: Nat, scheduled: Bool, deferred: Bool, parent: Nat) -> R.World:
  +id = nextId(w)
  kind = B.choose(~R.NodeKind, user, _ => R.User{}, _ => R.Render{})
  w = allocate(w, kind, expr, R.Undefined{}, False{}, parent, target, False{})
  C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}, C.InitialEffect{id, scheduled, deferred}], []}))

def read(fuel: Nat, w: R.World, id: Nat) -> C.Machine:
  C.run(fuel, C.Machine{w, [C.ReadNode{id}], []})

def firstValue(xs: List<&2, R.Value>) -> R.Value:
  match xs:
    case Nil{}:
      R.Undefined{}
    case h <> tail:
      h

def resultValue(m: C.Machine) -> R.Value:
  firstValue(C.values(m))

def resultWorld(m: C.Machine) -> R.World:
  C.world(m)

def flush(fuel: Nat, w: R.World) -> R.World:
  C.flush(fuel, w)

def setSignal(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  B.choose(~R.World, B.valid(w, id), _ => S.setSignal(w, id, value), _ => R.World.with_fault(w, R.BadId{}))

# Updaters see staged composition; setter returns are preserved by the facade.
def setUpdater(fuel: Nat, +w: R.World, +id: Nat, expr: R.Expr) -> R.World:
  +m = C.eval(fuel, w, expr, B.current(B.node(w, id)))
  B.choose(~R.World, C.healthy(R.World.fault(C.world(m))),
    _ => setSignal(C.world(m), id, resultValue(m)), _ => C.world(m))

def refresh(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Bool.and(B.computed(R.Node.kind(B.node(w, id))), Bool.and(B.valid(w, id), Bool.not(B.has(R.Node.flags(B.node(w, id)), 64)))),
    _ => B.schedule(H.enqueueSub(H.markNode(w, id, 2), id)), _ => w)

# Host-boundary constructors: use these exports instead of generated JS tags.
def vUndefined() -> R.Value:
  R.Undefined{}

def vNull() -> R.Value:
  R.Null{}

def vNumber(n: Nat) -> R.Value:
  R.Number{n}

def vReference(id: Nat) -> R.Value:
  R.Reference{id}

def vText(s: String) -> R.Value:
  R.StringValue{s}

def vBoolean(b: Bool) -> R.Value:
  R.Boolean{b}

def vNaN() -> R.Value:
  R.NotANumber{}

def yes() -> Bool:
  True{}

def no() -> Bool:
  False{}

def literal(v: R.Value) -> R.Expr:
  R.Literal{v}

def source(id: Nat) -> R.Expr:
  R.Read{id}

def previous() -> R.Expr:
  R.Previous{}

def add(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Add{a, b}

def multiply(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Multiply{a, b}

def same(a: R.Expr, b: R.Expr) -> R.Expr:
  R.Same{a, b}

def select(condition: R.Expr, yes: R.Expr, no: R.Expr) -> R.Expr:
  R.Select{condition, yes, no}

def untrack(e: R.Expr) -> R.Expr:
  R.Untracked{e}

def unsupportedError(cause: R.Value) -> R.Expr:
  R.Raise{cause}

def attach(w: R.World, parent: Nat, id: Nat) -> R.World:
  T.attach(w, parent, id)

def detach(w: R.World, id: Nat) -> R.World:
  T.detach(w, id)

def displayed(w: R.World, id: Nat) -> R.Value:
  T.text(w, id)

def dispose(w: R.World, id: Nat) -> R.World:
  O.dispose(w, id)

# Constructor for the proof witness generator. It supplies no scheduling or
# answers: each following transition is core.step and is checked in BendTT.
def flushMachine(w: R.World) -> C.Machine:
  C.Machine{w, [C.Round{}], []}
