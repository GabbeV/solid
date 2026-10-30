import Base
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/truth-state.bend as T
import ../../runtime/question.bend as Q
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{op: U32, readerKind: U32, tracking: Bool, pass: Nat, flush: Nat, readerTx: Nat, flags: U32, readerConfig: U32, config: U32, status: U32, shown: Bool, held: Bool, slot: U32, pending: U32, equals: Bool, reask: Bool, shownError: Bool, graph: U32, linked: Bool, redirect: Bool, latest: Bool, query: R.Question, sourceQ: R.Question, firstQ: R.Question, secondQ: R.Question, firstNow: Bool, secondNow: Bool}

def value(mode: U32) -> R.Value:
  match mode:
    case 1: R.Undefined{}
    case 2: R.Null{}
    case 3: R.Boolean{False{}}
    case 4: R.Number{0n}
    case 5: R.Number{7n}
    case _: R.Number{9n}

def slot(mode: U32) -> R.Slot:
  match mode:
    case 0: R.Empty{}
    case other: R.Present{value(other)}

def kind(mode: U32) -> R.NodeKind:
  match mode:
    case 2: R.Render{}
    case 3: R.User{}
    case 4: R.Tracked{}
    case _: R.Memo{}

def node(+w: R.World, +id: Nat, +v: R.Value) -> R.World:
  B.store_node(w, id, R.Node.with_pending(R.Node.with_value(R.Node.with_flags(B.node(w, id), 0), v), R.Empty{}))

def seed() -> R.World:
  +w = N.createOwner(R.World.with_clock(B.empty(), 5n), 0n, False{})
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{23n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{13n}}, opts, 1n)
  +w = node(node(node(node(w, 2n, R.Number{7n}), 3n, R.Number{23n}), 4n, R.Number{11n}), 5n, R.Number{13n})
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, L.newLane(w, 1n))
  +w = B.first(R.World, Nat, L.newLane(w, 1n))
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  Tx.list(w, 2n, 2n)

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{+op, +readerKind, +tracking, +pass, +flush, +readerTx, +flags, +readerConfig, +config, +status, +shown, +held, +laneSlot, +pending, +equals, +reask, +shownError, +graph, +linked, +redirect, +latest, +query, +sourceQ, +firstQ, +secondQ, +firstNow, +secondNow}:
      +w = seed()
      +w = B.store_node(w, 2n, R.Node.with_equals(R.Node.with_status(R.Node.with_config(R.Node.with_pending(B.node(w, 2n), slot(pending)), config), status), equals))
      +w = B.store_extension(w, 2n, R.NodeExtension.with_q(R.NodeExtension.with_lane(R.NodeExtension.with_reask(R.NodeExtension.with_shownError(B.extension(w, 2n), B.choose(~R.Value, shownError, _ => R.Number{99n}, _ => R.Undefined{})), reask), slot(laneSlot)), sourceQ))
      +w = B.store_node(w, 3n, R.Node.with_kind(R.Node.with_flags(R.Node.with_config(B.node(w, 3n), readerConfig), flags), kind(readerKind)))
      +w = B.choose(~R.World, Nat.is_eq(readerTx, 0n), _ => w, _ => Tx.list(w, 3n, readerTx))
      +w = B.store_transaction(w, 2n, R.Transaction.with_held(R.Transaction.with_shown(B.transaction(w, 2n), shown), held))
      +w = B.choose(~R.World, linked, _ => L.linkLanes(w, 2n, 3n), _ => w)
      +w = B.choose(~R.World, redirect, _ => B.store_transaction(w, 4n, R.Transaction.with_into(B.transaction(w, 4n), 1n)), _ => w)
      +w = E.ext(E.ext(w, 4n), 5n)
      +w = B.store_extension(w, 4n, R.NodeExtension.with_q(B.extension(w, 4n), firstQ))
      +w = B.store_extension(w, 5n, R.NodeExtension.with_q(B.extension(w, 5n), secondQ))
      +w = B.store_node(w, 4n, R.Node.with_time(B.node(w, 4n), B.choose(~Nat, firstNow, _ => 5n, _ => 4n)))
      +w = B.store_node(w, 5n, R.Node.with_time(B.node(w, 5n), B.choose(~Nat, secondNow, _ => 5n, _ => 4n)))
      +w = B.choose(~R.World, U32.is_ge(graph, 1), _ => G.link(w, 4n, 2n), _ => w)
      +w = B.choose(~R.World, U32.is_ge(graph, 2), _ => G.link(w, 5n, 2n), _ => w)
      +w = B.choose(~R.World, U32.is_ge(graph, 3), _ => G.link(w, 2n, 3n), _ => w)
      +w = R.World.with_verdictState(w, R.VerdictState{latest, False{}, False{}, False{}, 0n})
      +w = R.World.with_question(w, query)
      +w = R.World.with_truthReadHook(w, True{})
      +w = R.World.with_clock(w, 5n)
      +w = R.World.with_syncDepth(w, 1n)
      +w = R.World.with_passLane(w, pass)
      +w = R.World.with_flushTransaction(w, flush)
      +w = R.World.with_context(w, B.choose(~Nat, U32.is_eq(readerKind, 0), _ => 0n, _ => 3n))
      R.World.with_tracking(w, tracking)

def fixtureOp(spec: Spec) -> U32:
  match spec:
    case Spec{+op, +readerKind, +tracking, +pass, +flush, +readerTx, +flags, +readerConfig, +config, +status, +shown, +held, +laneSlot, +pending, +equals, +reask, +shownError, +graph, +linked, +redirect, +latest, +query, +sourceQ, +firstQ, +secondQ, +firstNow, +secondNow}:
      op

def execute(op: U32, +w: R.World) -> C.Machine:
  match op:
    case 0: C.run(4096n, C.Machine{w, [C.ReadNode{2n}], [R.Number{71n}]})
    case 1: C.run(4096n, C.truthRead(w, [], [R.Number{71n}], 2n))
    case 2: C.run(4096n, C.heldNotFinal(w, [], [R.Number{71n}], 2n))
    case 3: C.run(4096n, C.Machine{w, [C.TruthNode{2n}], [R.Number{71n}]})
    case 6: C.Machine{T.truthConfirmed(w, 2n), [], [R.Undefined{}, R.Number{71n}]}
    case _: C.Machine{w, [], [R.Number{71n}]}

def fixture(+spec: Spec) -> C.Machine:
  execute(fixtureOp(spec), initial(spec))

def stale(+spec: Spec) -> Bool:
  L.stale(initial(spec), 2n, R.World.question(initial(spec)))

def answered(spec: Spec) -> B.Bundle<R.World, R.Question>:
  L.answered(initial(spec), 2n)

def compare(a: R.Question, b: R.Question) -> Q.Order:
  Q.compare(a, b)
