import Base
import ./lane-read.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{op: U32, kind: U32, guess: Bool, shown: Bool, held: Bool, laneSlot: U32, pending: U32, flags: U32, config: U32, status: U32, equals: Bool, except: Bool, second: Bool, staleMember: Bool, nested: Bool, linked: Bool, leaked: Bool, open: Nat, hook: Bool, reverse: Bool}

def kind(mode: U32) -> R.NodeKind:
  match mode:
    case 0: R.Signal{}
    case 2: R.Render{}
    case 3: R.User{}
    case 4: R.Tracked{}
    case _: R.Memo{}

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{+op, +nodeKind, +guess, +shown, +held, +laneSlot, +pending, +flags, +config, +status, +equals, +except, +second, +staleMember, +nested, +linked, +leaked, +open, +hook, +reverse}:
      +w = Seed.seed()
      +w = R.World.with_running(R.World.with_syncDepth(w, 1n), True{})
      +w = B.store_node(w, 2n, R.Node.with_kind(R.Node.with_equals(R.Node.with_status(R.Node.with_flags(R.Node.with_config(R.Node.with_pending(B.node(w, 2n), Seed.slot(pending)), B.choose(~U32, guess, _ => U32.or(config, U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS())), _ => U32.or(config, K.CONFIG_OVERRIDE()))), flags), status), equals), kind(nodeKind)))
      +w = B.store_extension(w, 2n, R.NodeExtension.with_lane(B.extension(w, 2n), Seed.slot(laneSlot)))
      +w = B.store_transaction(w, 2n, R.Transaction.with_open(R.Transaction.with_held(R.Transaction.with_shown(B.transaction(w, 2n), shown), held), open))
      +w = E.ext(w, 3n)
      +w = B.store_node(w, 3n, R.Node.with_config(B.node(w, 3n), K.CONFIG_AUTHORITATIVE()))
      +w = G.link(w, 2n, 3n)
      +w = B.choose(~R.World, second,
        _ =>
          +w = Tx.list(w, 4n, 2n)
          +w = B.store_extension(w, 4n, R.NodeExtension.with_lane(B.extension(w, 4n), R.Present{R.Number{13n}}))
          B.store_node(w, 4n, R.Node.with_config(R.Node.with_pending(B.node(w, 4n), R.Present{R.Number{17n}}), K.CONFIG_OVERRIDE())), _ => w)
      +w = B.choose(~R.World, staleMember, _ => B.store_extension(E.ext(w, 4n), 4n, R.NodeExtension.with_transaction(B.extension(w, 4n), 1n)), _ => w)
      +w = B.choose(~R.World, nested,
        _ =>
          +w = B.store_transaction(w, 2n, R.Transaction.with_verdict(B.transaction(w, 2n), 3n))
          +w = B.store_transaction(w, 3n, R.Transaction.with_parent(B.transaction(w, 3n), 2n))
          Tx.list(w, 5n, 3n), _ => w)
      +w = B.choose(~R.World, linked, _ => L.linkLanes(w, 2n, 3n), _ => w)
      +w = B.store_transaction(w, 2n, R.Transaction.with_reruns(R.Transaction.with_renderQueue(R.Transaction.with_userQueue(B.transaction(w, 2n), [R.NodeRun{5n}]), [3n]), [3n]))
      +w = R.World.with_truthConfirmedHook(w, hook)
      B.choose(~R.World, reverse, _ => B.store_transaction(w, 2n, R.Transaction.with_nodes(B.transaction(w, 2n), List.reverse(&2, Nat, R.Transaction.nodes(B.transaction(w, 2n))))), _ => w)

def execute(spec: Spec, +w: R.World) -> C.Machine:
  match spec:
    case Spec{+op, nodeKind, guess, shown, held, laneSlot, pending, flags, config, status, equals, +except, second, staleMember, nested, linked, leaked, open, hook, reverse}:
      +rest = {[] : List<&2, C.Task>}
      +stack = {[R.Number{71n}] : List<&2, R.Value>}
      +m = B.choose(~C.Machine, U32.is_eq(op, 0), _ => C.supersede(w, rest, stack, 2n, R.Number{19n}, False{}),
        _ => B.choose(~C.Machine, U32.is_eq(op, 1), _ => C.supersede(w, rest, stack, 2n, R.Number{19n}, True{}),
          _ => B.choose(~C.Machine, U32.is_eq(op, 2), _ => C.dissolveLane(w, rest, stack, 2n, 0n, B.choose(~Nat, except, _ => 2n, _ => 0n)),
            _ => B.choose(~C.Machine, U32.is_eq(op, 3), _ => C.dissolveLane(w, rest, stack, 2n, 1n, B.choose(~Nat, except, _ => 2n, _ => 0n)),
              _ => B.choose(~C.Machine, U32.is_eq(op, 4), _ => C.laneSeam(w, rest, stack, 2n, leaked),
                _ => C.endLanes(w, rest, stack, 1n))))))
      C.run(8192n, m)

def fixture(+spec: Spec) -> C.Machine:
  execute(spec, initial(spec))
