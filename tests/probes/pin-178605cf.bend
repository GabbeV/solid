# Focused source-change controls; constructed private states, not reachability claims.
import Base
import ./lane-stage.bend as Seed
import ../../runtime/construct.bend as N
import ../../runtime/constants.bend as K
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as Tx
import ../../runtime/affects-marks.bend as Marks
import ../../runtime/affects-scope.bend as Scope
import ../../runtime/status.bend as Status
import ../../runtime/verdict-state.bend as Verdict
import ../../representation/records.bend as R
import ../../representation/base.bend as B

def slot(mode: U32) -> R.Slot:
  match mode:
    case 0: R.Empty{}
    case 1: R.Present{R.Undefined{}}
    case 2: R.Present{R.Number{0n}}
    case 3: R.Present{R.Boolean{False{}}}
    case _: R.Present{R.Number{7n}}

def seed(+value: U32) -> R.World:
  +w = B.first(R.World, List<&2, Nat>, Seed.fixture([Seed.Command{11, 0n, 0n, 0}, Seed.Command{11, 0n, 0n, 0}, Seed.Command{0, 1n, 0n, 0}, Seed.Command{0, 1n, 0n, 0}, Seed.Command{0, 2n, 0n, 0}]))
  +w = B.store_node(w, 2n, R.Node.with_value(R.Node.with_flags(B.node(w, 2n), 0), R.Number{2n}))
  +w = B.store_node(w, 3n, R.Node.with_value(R.Node.with_flags(B.node(w, 3n), 0), R.Number{3n}))
  +w = B.store_node(w, 4n, R.Node.with_value(R.Node.with_flags(B.node(w, 4n), 0), R.Number{4n}))
  +w = R.World.with_laneState(w, R.LaneState.with_guessing(R.LaneState.with_guessed(R.World.laneState(w), True{}), True{}))
  +w = R.World.with_syncDepth(R.World.with_running(w, True{}), 1n)
  +w = Tx.list(E.ext(w, 2n), 2n, 3n)
  +w = B.store_node(w, 2n, R.Node.with_config(B.node(w, 2n), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())))
  +w = B.store_extension(w, 2n, R.NodeExtension.with_q(R.NodeExtension.with_lane(B.extension(w, 2n), slot(value)), R.QuestionOdd{R.QuestionOdd{R.QuestionOdd{R.QuestionZero{}}}}))
  +w = Tx.list(E.ext(w, 1n), 1n, 5n)
  +w = B.store_node(w, 1n, R.Node.with_config(B.node(w, 1n), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())))
  B.store_extension(w, 1n, R.NodeExtension.with_lane(B.extension(w, 1n), R.Present{R.Number{9n}}))

# mode0: stage only; mode1: take; mode2: correction; mode3: correction+landing.
def borrow(+mode: U32, value: U32, error: U32, detach: Bool, +move: Bool, +confirmed: Bool) -> C.Machine:
  +w = seed(value)
  +w = B.choose(~R.World, U32.is_eq(mode, 4), _ => Tx.merge(w, 1n, 2n),
    _ => B.choose(~R.World, U32.is_eq(mode, 5), _ => Tx.merge(w, 2n, 1n), _ => w))
  +w = B.choose(~R.World, U32.is_eq(mode, 1), _ => L.take(w, 2n, 5n, detach),
    _ => B.first(R.World, Bool, L.laneStage(w, 2n, 5n, False{}, Seed.stageError(error))))
  +w = B.choose(~R.World, move, _ => Tx.list(w, 2n, 4n), _ => w)
  +w = B.store_transaction(w, 2n, R.Transaction.with_acted(B.transaction(w, 2n), True{}))
  +w = B.choose(~R.World, confirmed, _ => B.store_node(w, 1n, R.Node.with_pending(B.node(w, 1n), R.Present{R.Number{9n}})), _ => w)
  +tasks = B.choose(~List<&2, C.Task>, Bool.or(U32.is_eq(mode, 2), U32.is_eq(mode, 3)),
    _ => B.choose(~List<&2, C.Task>, U32.is_eq(mode, 3),
      _ => [C.LaneCorrections{R.LaneState.live(R.World.laneState(w)), False{}}, C.Discard{}, C.EndLanes{2n}],
      _ => [C.LaneCorrections{R.LaneState.live(R.World.laneState(w)), False{}}]), _ => [])
  C.run(8192n, C.Machine{w, tasks, [R.Number{71n}]})

def markCopies(copies: Nat, w: R.World) -> R.World:
  match copies:
    case 0n: w
    case 1n+p: markCopies(p, Scope.register(w, 1n))

# A transaction mark stays ambient until the marked node's own flight is down.
def markRelease(+pending: Bool, +copies: Nat, +settle: Bool) -> R.World:
  +w = N.computed(0n, B.empty(), R.Literal{R.Number{1n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  +w = R.World.with_flushTransaction(w, 1n)
  +w = markCopies(copies, w)
  +w = B.store_node(w, 1n, R.Node.with_status(B.node(w, 1n), B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => 0)))
  +w = Scope.releaseTransaction(w, 1n)
  B.choose(~R.World, settle,
    _ => Scope.releaseAmbient(B.store_node(w, 1n, R.Node.with_status(B.node(w, 1n), 0)), 0n), _ => w)


# A new question joins the written guess's hold; REASK opens its own hold.
def pendingGuess(+armed: Bool, +reask: Bool, pass: Nat) -> R.World:
  +w = seed(4)
  +w = R.World.with_laneState(w, R.LaneState.with_guessing(R.World.laneState(w), armed))
  +w = R.World.with_passLane(w, pass)
  +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), B.choose(~U32, reask, _ => K.REACTIVE_REASK(), _ => 0)))
  Status.notifyStatusWith(w, 2n, K.STATUS_PENDING(), R.NotReadyFailure{1n, 2n})

# New ancestors carry the world they were born in into their verdict reader.
def born(+parentFlags: U32, grandFlags: U32, +throughRoot: Bool, tracking: Bool) -> R.World:
  +w = seed(4)
  +w = B.store_node(w, 2n, R.Node.with_parent(R.Node.with_config(B.node(w, 2n), 0), 4n))
  +w = B.store_node(w, 4n, R.Node.with_parent(R.Node.with_flags(B.node(w, 4n), parentFlags), 3n))
  +w = B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), grandFlags))
  +w = B.choose(~R.World, throughRoot,
    _ =>
      +w = N.createOwner(w, 4n, False{})
      B.store_node(w, 2n, R.Node.with_parent(B.node(w, 2n), 5n)), _ => w)
  Verdict.markVerdictReader(R.World.with_context(R.World.with_tracking(w, tracking), 2n), 1)
