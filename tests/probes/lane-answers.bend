import Base
import ./lane-lifecycle.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{base: Seed.Spec, operation: U32, question: R.Question, ownQ: R.Question, sourceQ: R.Question, now: Bool, acted: Bool, parentLane: Bool, sourcePending: Bool, value: R.Value}

def parentOpen(base: Seed.Spec) -> Nat:
  match base:
    case Seed.Spec{op, kind, guess, shown, held, laneSlot, pending, flags, config, status, equals, except, second, staleMember, nested, linked, leaked, open, hook, reverse}:
      open

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{+base, operation, +question, +ownQ, +sourceQ, +now, +acted, +parentLane, +sourcePending, value}:
      +w = Seed.initial(base)
      +w = R.World.with_question(w, question)
      +w = B.store_extension(w, 2n, R.NodeExtension.with_q(B.extension(w, 2n), ownQ))
      +w = E.ext(w, 4n)
      +w = B.store_extension(w, 4n, R.NodeExtension.with_q(B.extension(w, 4n), sourceQ))
      +w = B.store_node(w, 4n, R.Node.with_time(B.node(w, 4n), B.choose(~Nat, now, _ => 5n, _ => 4n)))
      +w = G.link(w, 4n, 2n)
      +w = B.store_transaction(w, 1n, R.Transaction.with_open(R.Transaction.with_lane(R.Transaction.with_acted(B.transaction(w, 1n), acted), parentLane), parentOpen(base)))
      B.choose(~R.World, sourcePending,
        _ =>
          +w = Tx.list(w, 5n, 1n)
          B.store_node(w, 5n, R.Node.with_status(R.Node.with_kind(B.node(w, 5n), R.Render{}), K.STATUS_PENDING())), _ => w)

def execute(spec: Spec, +w: R.World) -> C.Machine:
  match spec:
    case Spec{base, +operation, question, ownQ, sourceQ, now, acted, parentLane, sourcePending, +value}:
      +stack = {[R.Number{71n}] : List<&2, R.Value>}
      +m = B.choose(~C.Machine, U32.is_eq(operation, 0), _ => C.laneWrite(w, [], stack, 2n, value),
        _ => B.choose(~C.Machine, U32.is_eq(operation, 1), _ => C.laneOutcome(w, [], stack, 2n, value, False{}),
          _ => B.choose(~C.Machine, U32.is_eq(operation, 2), _ => C.laneOutcome(w, [], stack, 2n, value, True{}), _ => C.laneCorrections(w, [], stack))))
      C.run(8192n, m)

def fixture(+spec: Spec) -> C.Machine:
  execute(spec, initial(spec))
