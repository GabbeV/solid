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

# User-code list traversal with an explicit immutable environment. The callback
# is closed code; captured data is passed at runtime, not hidden in a template.
def mapWith(~A: Data, ~C: Data, ~E: Data, ~f: E -> A -> C, +env: E, xs: List<&2, A>) -> List<&2, C>:
  match xs:
    case Nil{}:
      []
    case head <> tail:
      f(env, head) <> mapWith(A, C, E, f, env, tail)

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
    case R.NotPendingToken{} R.NotPendingToken{}:
      True{}
    case R.Null{} R.Null{}:
      True{}
    case R.Boolean{x} R.Boolean{y}:
      Bool.xor(Bool.xor(x, y), True{})
    case R.NegativeZero{} R.NegativeZero{}:
      True{}
    case R.NegativeZero{} R.Number{y}:
      Nat.is_eq(0n, y)
    case R.Number{x} R.NegativeZero{}:
      Nat.is_eq(x, 0n)
    case R.Number{x} R.Number{y}:
      Nat.is_eq(x, y)
    case R.AsyncValue{x} R.AsyncValue{y}:
      Nat.is_eq(x, y)
    case R.IteratorReference{x} R.IteratorReference{y}:
      Nat.is_eq(x, y)
    case R.ArrayReference{x} R.ArrayReference{y}:
      Nat.is_eq(x, y)
    case R.Reference{x} R.Reference{y}:
      Nat.is_eq(x, y)
    case R.OwnerReference{x} R.OwnerReference{y}:
      Nat.is_eq(x, y)
    case R.RootDisposerReference{x} R.RootDisposerReference{y}:
      Nat.is_eq(x, y)
    case R.ProgramReference{x} R.ProgramReference{y}:
      Nat.is_eq(x, y)
    case R.SetterReference{x} R.SetterReference{y}:
      Nat.is_eq(x, y)
    case R.AccessorReference{x} R.AccessorReference{y}:
      Nat.is_eq(x, y)
    case R.ContextFailure{x, kindA} R.ContextFailure{y, kindB}:
      Nat.is_eq(x, y)
    case R.NotReadyFailure{x, sourceA} R.NotReadyFailure{y, sourceB}:
      Nat.is_eq(x, y)
    case R.StatusFailure{x, sourceA, causeA, messageA} R.StatusFailure{y, sourceB, causeB, messageB}:
      Nat.is_eq(x, y)
    case R.TimeoutFailure{x} R.TimeoutFailure{y}:
      Nat.is_eq(x, y)
    case R.ExternalError{x, explicitA, kindA, nameA, messageA, nativeA, codeA} R.ExternalError{y, explicitB, kindB, nameB, messageB, nativeB, codeB}:
      Bool.and(Nat.is_eq(x, y), Bool.xor(Bool.xor(explicitA, explicitB), True{}))
    case R.StringValue{x} R.StringValue{y}:
      String.eq(x, y)
    case _ _:
      False{}

# Object.is differs from strict equality for NaN and the two signed zeros.
def objectIs(a: R.Value, b: R.Value) -> Bool:
  match a b:
    case R.NotANumber{} R.NotANumber{}:
      True{}
    case R.NegativeZero{} R.Number{n}:
      False{}
    case R.Number{n} R.NegativeZero{}:
      False{}
    case left right:
      equal(left, right)

def truth(v: R.Value) -> Bool:
  match v:
    case R.Boolean{b}:
      b
    case R.Number{n}:
      Nat.is_ne(n, 0n)
    case R.ArrayReference{id}:
      True{}
    case R.Reference{id}:
      True{}
    case R.OwnerReference{id}:
      True{}
    case R.RootDisposerReference{owner}:
      True{}
    case R.AccessorReference{signal}:
      True{}
    case R.ProgramReference{callback}:
      True{}
    case R.SetterReference{signal}:
      True{}
    case R.ContextFailure{identity, kind}:
      True{}
    case R.StatusFailure{identity, source, cause, message}:
      True{}
    case R.TimeoutFailure{identity}:
      True{}
    case R.ExternalError{id, explicit, kind, name, message, native, code}:
      True{}
    case R.NotReadyFailure{identity, source}:
      True{}
    case R.NotPendingToken{}:
      True{}
    case R.AsyncValue{identity}:
      True{}
    case R.IteratorReference{iterator}:
      True{}
    case R.StepResult{done, value}:
      True{}
    case R.StreamVerdict{stream, landed, value}:
      True{}
    case R.StringValue{s}:
      Bool.not(String.is_empty(s))
    case _:
      False{}

# Explicit exception/result control for state-threaded source calls. These
# checks stop at source throw edges; they are not publication conditions.
def healthy(fault: R.Fault) -> Bool:
  match fault:
    case R.Healthy{}:
      True{}
    case _:
      False{}

def ok(w: R.World) -> Bool:
  healthy(R.World.fault(w))

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
    case R.Tracked{}:
      True{}
    case _:
      False{}

def effect(k: R.NodeKind) -> Bool:
  match k:
    case R.Render{}:
      True{}
    case R.User{}:
      True{}
    case R.Tracked{}:
      True{}
    case _:
      False{}

def tracked(k: R.NodeKind) -> Bool:
  match k:
    case R.Tracked{}:
      True{}
    case _:
      False{}

def blank_node() -> R.Node:
  R.Node{R.Invalid{}, R.Undefined{}, R.Empty{}, True{}, 0, 0, 0, 0n, R.Unstamped{},
    0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, 0n, 0n, 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n}

def blank_link() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def blank_tree() -> R.TreeNode:
  R.TreeNode{0n, [], R.Undefined{}}

def blank_extension() -> R.NodeExtension:
  R.NodeExtension{R.FlightEmpty{}, 0n, R.Undefined{}, R.Empty{}, 0n, 0n,
    R.NoSnapshotValue{}, 0n, R.NoDisposal{}, 0n, False{}, R.Empty{},
    R.Unstamped{}, R.QuestionZero{}, R.Empty{}, 0n, R.Null{}, R.FlightUndefined{}}

def stampMatches(stamp: R.Stamp, value: Nat) -> Bool:
  match stamp:
    case R.Unstamped{}:
      False{}
    case R.Stamped{x}:
      Nat.is_eq(x, value)

def root(k: R.NodeKind) -> Bool:
  match k:
    case R.Root{}:
      True{}
    case _:
      False{}

def nullish(v: R.Value) -> Bool:
  match v:
    case R.Undefined{}:
      True{}
    case R.Null{}:
      True{}
    case _:
      False{}

def noDisposal(d: R.Disposal) -> Bool:
  match d:
    case R.NoDisposal{}:
      True{}
    case _:
      False{}

def blank_transaction() -> R.Transaction:
  R.Transaction{[], [], [], [], 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}}

def blank_asyncObject() -> R.AsyncObject:
  R.AsyncObject{False{}, R.Unresolved{}, [], 0n}

def blank_asyncObserver() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n, 0n}

def empty() -> R.World:
  R.World{[blank_node()], [blank_link()], [0n], 0n, 0n, False{},
    [], [], [], [], 0n, False{}, False{}, False{}, 0n, 0n,
    [blank_tree(), blank_tree()], [], R.Healthy{}, False{}, [], [blank_extension()], [R.CleanupProgram{[], False{}, 0n}], [], 0n, False{}, False{}, [], 0n, [blank_transaction()], [], 0n, 0n, 0n, 0n, [], R.QuestionZero{}, [[]], [blank_asyncObject()], [blank_asyncObserver()], [], 0n, [R.StreamPlan{[], False{}, R.Empty{}, 0n, 0n, R.Empty{}, R.FromNone{}}], [R.ExternalIterator{0n, 0n, 0n}], [R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, R.Undefined{}, 0n}], [], [R.Awaiter{R.Literal{R.Undefined{}}, False{}, 0n, 0n, 0n, 0n, R.Unresolved{}, False{}, 0n, False{}, False{}, 0n}], False{}, False{}, R.QuestionZero{}, [R.AbortInput{False{}, R.Undefined{}}], [R.ContextKey{R.Undefined{}, R.Empty{}}], [R.ContextRecord{[]}], 0n, [[]], False{}, [R.Literal{R.Undefined{}}], [], [], 0n, [], [], [], [], [], 0n, R.LaneState{[], [[]], [], [], 0n, R.MountUnset{}, [], False{}, False{}, [], [], False{}, []}, R.VerdictState{False{}, False{}, False{}, False{}, 0n}, R.Empty{}, [], R.DeferredArena{[R.DeferredBinding{R.DeferredCell{0n, R.Null{}, False{}, False{}}, 0n}], [], [], [R.DeferredIterator{0n, 0n, 0n, False{}}]}}

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

# Production scheduler IO is an explicit host report, not a callback.
# kind 0 = halt, 1 = first ignored scheduling after halt, 2 = user error log.
def report(+w: R.World, kind: U32, cause: R.Slot) -> R.World:
  R.World.with_reports(w, append(R.Report, R.World.reports(w), [R.RuntimeReport{kind, cause}]))

def schedule(+w: R.World) -> R.World:
  choose(~R.World, R.World.halted(w),
    _ => choose(~R.World, R.World.haltNotified(w), _ => w,
      _ => report(R.World.with_haltNotified(w, True{}), 1, R.Empty{})),
    _ => choose(~R.World, R.World.scheduled(w), _ => w,
      _ =>
        +w = R.World.with_scheduled(w, True{})
        choose(~R.World, Bool.and(Nat.is_eq(R.World.syncDepth(w), 0n), Bool.not(R.World.running(w))),
          _ => R.World.with_hostJobs(w, append(R.HostJob, R.World.hostJobs(w), [R.FlushJob{}])), _ => w)))

def current(+n: R.Node) -> R.Value:
  selected(R.Node.pending(n), R.Node.value(n))

def extension(+w: R.World, id: Nat) -> R.NodeExtension:
  get(R.NodeExtension, R.World.extensions(w), R.Node.x(node(w, id)), blank_extension())

def store_extension(+w: R.World, id: Nat, x: R.NodeExtension) -> R.World:
  R.World.with_extensions(w, List.set(&2, R.NodeExtension, R.World.extensions(w), R.Node.x(node(w, id)), x))

# Nearest computed for source Root._parentComputed forwarding. Zero is null.
def parentComputed(+w: R.World, +parent: Nat) -> Nat:
  choose(~Nat, root(R.Node.kind(node(w, parent))), _ => R.Node.parentComputed(node(w, parent)), _ => parent)

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

def contains(xs: List<&2, Nat>, +id: Nat) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case x <> rest:
      Bool.or(Nat.is_eq(x, id), contains(rest, id))

def transaction(w: R.World, id: Nat) -> R.Transaction:
  get(R.Transaction, R.World.txArena(w), id, blank_transaction())

def store_transaction(+w: R.World, id: Nat, t: R.Transaction) -> R.World:
  R.World.with_txArena(w, List.set(&2, R.Transaction, R.World.txArena(w), id, t))

# Source Set identity is a nullable arena handle. Dropping the node's handle
# does not mutate a Set captured in a recompute local; add/delete do mutate it.
# Deleted Set entries keep their position for a live JS-style iterator. Node
# IDs are nonzero, so zero is an internal tombstone, never a member.
def pendingSlots(w: R.World, set: Nat) -> List<&2, Nat>:
  get(List<&2, Nat>, R.World.pendingSets(w), set, [])

def liveIds(xs: List<&2, Nat>) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      []
    case 0n <> rest:
      liveIds(rest)
    case id <> rest:
      id <> liveIds(rest)

def pendingItems(+w: R.World, set: Nat) -> List<&2, Nat>:
  liveIds(pendingSlots(w, set))

def store_pendingSet(+w: R.World, set: Nat, items: List<&2, Nat>) -> R.World:
  R.World.with_pendingSets(w, List.set(&2, List<&2, Nat>, R.World.pendingSets(w), set, items))

def pendingSources(+w: R.World, id: Nat) -> R.SourceSet:
  +set = R.NodeExtension.pendingSources(extension(w, id))
  choose(~R.SourceSet, Nat.is_eq(set, 0n), _ => R.NoSources{}, _ => R.Sources{pendingItems(w, set)})

def newPendingSet(+w: R.World, items: List<&2, Nat>) -> Bundle<R.World, Nat>:
  +set = length(List<&2, Nat>, R.World.pendingSets(w))
  Bundle{R.World.with_pendingSets(w, append(List<&2, Nat>, R.World.pendingSets(w), [items])), set}

# Test/internal construction boundary for a newly allocated source Set.
def setPendingSources(+w: R.World, +id: Nat, sources: R.SourceSet) -> R.World:
  match sources:
    case R.NoSources{}:
      store_extension(w, id, R.NodeExtension.with_pendingSources(extension(w, id), 0n))
    case R.Sources{items}:
      +pair = newPendingSet(w, items)
      +w = first(R.World, Nat, pair)
      store_extension(w, id, R.NodeExtension.with_pendingSources(extension(w, id), second(R.World, Nat, pair)))

def asyncObject(w: R.World, id: Nat) -> R.AsyncObject:
  get(R.AsyncObject, R.World.asyncObjects(w), id, blank_asyncObject())

def store_asyncObject(+w: R.World, id: Nat, object: R.AsyncObject) -> R.World:
  R.World.with_asyncObjects(w, List.set(&2, R.AsyncObject, R.World.asyncObjects(w), id, object))

def asyncObserver(w: R.World, id: Nat) -> R.AsyncObserver:
  get(R.AsyncObserver, R.World.asyncObservers(w), id, blank_asyncObserver())

def store_asyncObserver(+w: R.World, id: Nat, observer: R.AsyncObserver) -> R.World:
  R.World.with_asyncObservers(w, List.set(&2, R.AsyncObserver, R.World.asyncObservers(w), id, observer))

def streamPlan(w: R.World, id: Nat) -> R.StreamPlan:
  get(R.StreamPlan, R.World.streamPlans(w), id, R.StreamPlan{[], False{}, R.Empty{}, 0n, 0n, R.Empty{}, R.FromNone{}})

def iterator(w: R.World, id: Nat) -> R.ExternalIterator:
  get(R.ExternalIterator, R.World.iterators(w), id, R.ExternalIterator{0n, 0n, 0n})

def store_iterator(+w: R.World, id: Nat, value: R.ExternalIterator) -> R.World:
  R.World.with_iterators(w, List.set(&2, R.ExternalIterator, R.World.iterators(w), id, value))

def stream(w: R.World, id: Nat) -> R.StreamState:
  get(R.StreamState, R.World.streams(w), id, R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, R.Undefined{}, 0n})

def store_stream(+w: R.World, id: Nat, value: R.StreamState) -> R.World:
  R.World.with_streams(w, List.set(&2, R.StreamState, R.World.streams(w), id, value))

def iteratorEvent(+w: R.World, event: R.IteratorEvent) -> R.World:
  R.World.with_iteratorEvents(w, append(R.IteratorEvent, R.World.iteratorEvents(w), [event]))

def awaiter(w: R.World, id: Nat) -> R.Awaiter:
  get(R.Awaiter, R.World.awaiters(w), id, R.Awaiter{R.Literal{R.Undefined{}}, False{}, 0n, 0n, 0n, 0n, R.Unresolved{}, False{}, 0n, False{}, False{}, 0n})

def store_awaiter(+w: R.World, id: Nat, value: R.Awaiter) -> R.World:
  R.World.with_awaiters(w, List.set(&2, R.Awaiter, R.World.awaiters(w), id, value))

# Exact source `_x?._inFlight`: undefined, null and an active result are
# different even though only the active result is truthy.
def flightId(flight: R.Flight) -> Nat:
  match flight:
    case R.FlightActive{result}: result
    case _: 0n

def sameFlight(left: R.Flight, right: R.Flight) -> Bool:
  match left:
    case R.FlightUndefined{}:
      match right:
        case R.FlightUndefined{}: True{}
        case _: False{}
    case R.FlightEmpty{}:
      match right:
        case R.FlightEmpty{}: True{}
        case _: False{}
    case R.FlightActive{result}:
      match right:
        case R.FlightActive{other}: Nat.is_eq(result, other)
        case _: False{}

def flight(+w: R.World, +id: Nat) -> R.Flight:
  choose(~R.Flight, Nat.is_eq(R.Node.x(node(w, id)), 0n),
    _ => R.FlightUndefined{}, _ => R.NodeExtension.inFlight(extension(w, id)))
