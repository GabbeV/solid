import Base
import ./records.bend as R

# Lazy conditional; the inactive state transformation is never executed.
def choose(~A: Type, b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

def append(-A: Data, xs: List<&2, A>, ys: List<&2, A>) -> List<&2, A>:
  List.append(&2, A, xs, ys)

def length(-A: Data, xs: List<&2, A>) -> Nat:
  List.length(&2, A, xs)

def fallback(-A: Data, m: Maybe<&2, A>, d: A) -> A:
  match m:
    case None{}:
      d
    case Some{x}:
      x

def get(-A: Data, xs: List<&2, A>, i: Nat, d: A) -> A:
  fallback(A, List.get(&2, A, xs, i), d)

# Unlike Base.List.set, extends sparse bucket/property arenas with a default.
def put(-A: Data, xs: List<&2, A>, i: Nat, +d: A, v: A) -> List<&2, A>:
  match xs i:
    case Nil{} 0n:
      [v]
    case Nil{} 1n+p:
      d <> put(A, Nil{}, p, d, v)
    case h <> t 0n:
      v <> t
    case h <> t 1n+p:
      h <> put(A, t, p, d, v)

def has(+flags: U32, bit: U32) -> Bool:
  U32.is_ne(U32.and(flags, bit), 0)

def set(flags: U32, bit: U32) -> U32:
  U32.or(flags, bit)

def clear(flags: U32, bit: U32) -> U32:
  U32.and(flags, U32.not(bit))

# Payload subset: naturals (not F32 approximations), identity tokens, text,
# undefined, null, booleans, and NaN. Identity tokens are allocated by the host.
def equal(a: R.Value, b: R.Value) -> Bool:
  match a b:
    case R.Undefined{} R.Undefined{}:
      True{}
    case R.Null{} R.Null{}:
      True{}
    case R.Boolean{x} R.Boolean{y}:
      Bool.xor(Bool.xor(x, y), True{})
    case R.Number{x} R.Number{y}:
      Nat.is_eq(x, y)
    case R.Reference{x} R.Reference{y}:
      Nat.is_eq(x, y)
    case R.StringValue{x} R.StringValue{y}:
      String.eq(x, y)
    case _ _:
      False{}

def present(s: R.Slot) -> Bool:
  match s:
    case R.Empty{}:
      False{}
    case R.Present{v}:
      True{}

def selected(s: R.Slot, d: R.Value) -> R.Value:
  match s:
    case R.Empty{}:
      d
    case R.Present{v}:
      v

def computed(k: R.NodeKind) -> Bool:
  match k:
    case R.Memo{}:
      True{}
    case R.Render{}:
      True{}
    case R.User{}:
      True{}
    case _:
      False{}

def effect(k: R.NodeKind) -> Bool:
  match k:
    case R.Render{}:
      True{}
    case R.User{}:
      True{}
    case _:
      False{}

def blank_node() -> R.Node:
  R.Node{R.Invalid{}, R.Undefined{}, R.Empty{}, True{}, 0, 0, 0, 0n, 0n,
    0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n}

def blank_link() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def blank_tree() -> R.TreeNode:
  R.TreeNode{0n, [], R.Undefined{}}

def empty() -> R.World:
  R.World{[blank_node()], [blank_link()], [0n], 0n, 0n, False{},
    [], [], [], [], 0n, False{}, False{}, False{}, 0n, 1n,
    [blank_tree(), blank_tree()], [], R.Healthy{}}

def node(w: R.World, id: Nat) -> R.Node:
  get(R.Node, R.World.nodes(w), id, blank_node())

def link(w: R.World, id: Nat) -> R.Link:
  get(R.Link, R.World.links(w), id, blank_link())

def store_node(+w: R.World, id: Nat, n: R.Node) -> R.World:
  R.World.with_nodes(w, List.set(&2, R.Node, R.World.nodes(w), id, n))

def store_link(+w: R.World, id: Nat, n: R.Link) -> R.World:
  R.World.with_links(w, List.set(&2, R.Link, R.World.links(w), id, n))

def bucket(w: R.World, height: Nat) -> Nat:
  get(Nat, R.World.buckets(w), height, 0n)

def store_bucket(+w: R.World, height: Nat, n: Nat) -> R.World:
  R.World.with_buckets(w, put(Nat, R.World.buckets(w), height, 0n, n))

def bump(+w: R.World) -> R.World:
  R.World.with_epoch(w, 1n+R.World.epoch(w))

def event(+w: R.World, e: R.TraceEvent) -> R.World:
  R.World.with_events(w, append(R.TraceEvent, R.World.events(w), [e]))

def schedule(w: R.World) -> R.World:
  R.World.with_scheduled(w, True{})

def current(n: R.Node) -> R.Value:
  R.Node{kind, value, pending, equals, config, flags, status, time, notified,
    deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap,
    parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target} = n
  selected(pending, value)

def valid(+w: R.World, +id: Nat) -> Bool:
  Bool.and(Nat.is_ne(id, 0n), Nat.is_lt(id, length(R.Node, R.World.nodes(w))))

# Each pointer loop consumes fuel and surfaces exhaustion. No partial state
# with exhaustion is presented as a successful flush.
def budget(+w: R.World) -> Nat:
  Nat.mul(4n, Nat.add(length(R.Node, R.World.nodes(w)), length(R.Link, R.World.links(w))))

type Bundle<-A: Data, -C: Data> is Data:
  Bundle{left: A, right: C}

def first(-A: Data, -C: Data, p: Bundle<A, C>) -> A:
  match p:
    case Bundle{a, c}:
      a

def second(-A: Data, -C: Data, p: Bundle<A, C>) -> C:
  match p:
    case Bundle{a, c}:
      c
