# Actual recompute driver; atBody supplies the native fixture callback's flags.
import Base
import ./lane-read.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../runtime/equality.bend as EQ
import ../../runtime/graph-state.bend as G
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{op: U32, kind: U32, create: Bool, previousLane: Nat, mount: U32, config: U32, flags: U32, bodyFlags: U32, pending: U32, laneSlot: U32, value: U32, shown: Bool, creatorRunning: Bool, creatorConfig: U32, tx: Nat, flush: Nat, status: U32, modified: Bool, previous: U32, graph: Bool, subscriberMode: U32, verdict: Bool}

def mount(mode: U32) -> R.LaneMount:
  match mode:
    case 0: R.MountUnset{}
    case 1: R.MountFalse{}
    case 2: R.MountLane{2n}
    case _: R.MountLane{3n}

def fixtureValue(mode: U32) -> R.Value:
  match mode:
    case 7: R.NegativeZero{}
    case 8: R.NotANumber{}
    case 12: R.Number{11n}
    case _: Seed.value(mode)

def expr(mode: U32) -> R.Expr:
  match mode:
    case 0: R.Previous{}
    case 9: R.Raise{R.NotReadyFailure{1n, 4n}}
    case 10: R.Raise{R.Number{99n}}
    case 11: R.Read{4n}
    case _: R.Literal{fixtureValue(mode)}

def fixtureSlot(+mode: U32) -> R.Slot:
  B.choose(~R.Slot, U32.is_eq(mode, 0), _ => R.Empty{}, _ => R.Present{fixtureValue(mode)})

def comparator(mode: U32) -> List<&2, R.CleanupAction>:
  match mode:
    case 3: [R.CallbackReturn{R.Literal{R.Boolean{True{}}}}]
    case 4: [R.CallbackEvaluate{R.Read{4n}}, R.CallbackReturn{R.Literal{R.Boolean{False{}}}}]
    case 5: [R.CallbackWrite{4n, R.Literal{R.Number{19n}}}, R.CallbackReturn{R.Literal{R.Boolean{False{}}}}]
    case 6: [R.CallbackThrow{R.Literal{R.Number{99n}}}]
    case 7: [R.CallbackThrow{R.Literal{R.NotReadyFailure{1n, 4n}}}]
    case 8: [R.CallbackReturn{R.Argument{0n}}]
    case _: [R.CallbackReturn{R.Literal{R.Boolean{False{}}}}]

def compareSetup(+w: R.World, +mode: U32) -> R.World:
  +id = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{comparator(mode), False{}, 0n}]))
  +w = EQ.register(w, 2n, id)
  +w = Tx.list(w, 4n, 3n)
  +w = B.store_node(w, 4n, R.Node.with_config(B.node(w, 4n), U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())))
  +w = B.store_extension(w, 4n, R.NodeExtension.with_lane(B.extension(w, 4n), R.Present{R.Number{23n}}))
  B.store_transaction(w, 3n, R.Transaction.with_shown(B.transaction(w, 3n), True{}))

def graphSetup(+w: R.World, +mode: U32) -> R.World:
  +w = B.store_node(w, 5n, R.Node.with_kind(B.node(w, 5n), B.choose(~R.NodeKind, U32.is_eq(mode, 4), _ => R.Memo{}, _ => R.Render{})))
  +w = B.choose(~R.World, Bool.or(U32.is_eq(mode, 1), Bool.or(U32.is_eq(mode, 3), U32.is_eq(mode, 4))), _ => B.store_node(w, 5n, R.Node.with_status(B.node(w, 5n), 0)), _ => w)
  +w = B.choose(~R.World, Bool.or(U32.is_eq(mode, 1), Bool.or(U32.is_eq(mode, 2), U32.is_eq(mode, 4))), _ => Tx.holdNode(w, 5n, 1n), _ => w)
  +w = B.choose(~R.World, U32.is_eq(mode, 3), _ => B.store_node(w, 5n, R.Node.with_flags(B.node(w, 5n), K.REACTIVE_RECOMPUTING_DEPS())), _ => w)
  G.link(w, 2n, 5n)

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{+op, +kind, create, +previousLane, m, +config, +flags, bodyFlags, pending, laneSlot, +value, shown, creatorRunning, creatorConfig, +tx, flush, +status, modified, previous, +graph, subscriberMode, verdict}:
      +w = Seed.seed()
      +w = B.choose(~R.World, U32.is_eq(value, 11), _ => B.store_node(w, 4n, R.Node.with_status(B.node(w, 4n), 0)), _ => w)
      +w = B.store_extension(w, 2n, R.NodeExtension.with_lane(R.NodeExtension.with_transaction(B.extension(w, 2n), tx), fixtureSlot(laneSlot)))
      +w = B.store_node(w, 2n, R.Node.with_equals(R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_status(R.Node.with_pending(B.node(w, 2n), fixtureSlot(pending)), status), flags), config), Seed.kind(kind)), U32.is_eq(kind, 1)))
      +w = B.store_node(w, 2n, R.Node.with_expr(R.Node.with_modified(R.Node.with_prevValue(B.node(w, 2n), fixtureValue(previous)), modified), expr(value)))
      +w = B.store_transaction(w, 2n, R.Transaction.with_nodes(R.Transaction.with_shown(B.transaction(w, 2n), shown), B.choose(~List<&2, Nat>, Nat.is_eq(tx, 2n), _ => [2n], _ => [])))
      +w = B.store_node(w, 3n, R.Node.with_config(R.Node.with_flags(B.node(w, 3n), B.choose(~U32, creatorRunning, _ => K.REACTIVE_RECOMPUTING_DEPS(), _ => 0)), creatorConfig))
      +w = B.store_transaction(w, 1n, R.Transaction.with_verdict(B.transaction(w, 1n), B.choose(~Nat, verdict, _ => previousLane, _ => 0n)))
      +w = R.World.with_context(w, 3n)
      +w = R.World.with_laneState(w, R.LaneState.with_root(R.World.laneState(w), mount(m)))
      +w = R.World.with_flushTransaction(R.World.with_passLane(R.World.with_syncDepth(w, 1n), previousLane), flush)
      +w = B.choose(~R.World, U32.is_ge(op, 2), _ => compareSetup(w, op), _ => w)
      B.choose(~R.World, graph,
        _ => graphSetup(w, subscriberMode), _ => w)

def atBody(fuel: Nat, +m: C.Machine, +bodyFlags: U32) -> C.Machine:
  match fuel m:
    case 0n C.Machine{w, tasks, stack}:
      C.Machine{R.World.with_fault(w, R.Exhausted{}), tasks, stack}
    case 1n+f C.Machine{+w, +tasks, +stack}:
      match tasks:
        case C.Evaluate{expr, previous} <> tail:
          C.Machine{B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), B.set(R.Node.flags(B.node(w, 2n)), bodyFlags))), C.Evaluate{expr, previous} <> tail, stack}
        case _:
          atBody(f, C.step(C.Machine{w, tasks, stack}), bodyFlags)

def fixture(+spec: Spec) -> B.Bundle<R.World, C.LanePass>:
  match spec:
    case Spec{op, kind, +create, previousLane, m, config, flags, +bodyFlags, pending, laneSlot, value, shown, creatorRunning, creatorConfig, tx, flush, status, modified, previous, +graph, subscriberMode, verdict}:
      +w = initial(spec)
      B.choose(~B.Bundle<R.World, C.LanePass>, U32.is_eq(op, 0),
        _ => C.seatPass(w, 2n, create),
        _ =>
          +result = C.run(8192n, atBody(64n, C.recompute(w, [], [], 2n, create), bodyFlags))
          B.Bundle{C.world(result), C.LanePass{0n, R.MountUnset{}, R.MountUnset{}, False{}}})
