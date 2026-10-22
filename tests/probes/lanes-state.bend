import Base
import ../../runtime/read-state.bend as V
import ../../runtime/truth-state.bend as Truth
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/lanes-state.bend as L
import ../../runtime/transaction.bend as Tx

type Command is Data:
  Command{op: U32, left: Nat, right: Nat, bits: U32}

def boolResult(+w: R.World, value: Bool) -> B.Bundle<R.World, Nat>:
  B.Bundle{w, B.choose(~Nat, value, _ => 1n, _ => 0n)}

def command(+w: R.World, op: U32, +left: Nat, +right: Nat, +bits: U32) -> B.Bundle<R.World, Nat>:
  match op:
    case 0:
      L.newLane(w, left)
    case 1:
      L.verdictLane(w, left)
    case 2:
      B.Bundle{L.linkLanes(w, left, right), 0n}
    case 3:
      B.Bundle{L.unlink(w, left), 0n}
    case 4:
      boolResult(w, L.sameLane(w, left, right))
    case 5:
      +pair = L.under(w, left, right)
      boolResult(B.first(R.World, Bool, pair), B.second(R.World, Bool, pair))
    case 6:
      B.Bundle{L.enterLane(w, left, right), 0n}
    case 7:
      B.Bundle{R.World.with_passLane(w, left), 0n}
    case 8:
      B.Bundle{B.store_node(w, left, R.Node.with_flags(B.node(w, left), bits)), 0n}
    case 9:
      +w = E.ext(w, left)
      B.Bundle{B.store_extension(w, left, R.NodeExtension.with_transaction(B.extension(w, left), right)), 0n}
    case 10:
      B.Bundle{L.laneDirty(w, left, right), 0n}
    case 11:
      Tx.newTransaction(w, False{}, 0n)
    case 12:
      B.Bundle{V.stagedRead(w, left, right), 0n}
    case _:
      B.Bundle{B.store_node(w, left, R.Node.with_status(B.node(w, left), bits)), 0n}

def execute(commands: List<&2, Command>, w: R.World) -> B.Bundle<R.World, List<&2, Nat>>:
  match commands:
    case Nil{}:
      B.Bundle{w, []}
    case Command{op, left, right, bits} <> rest:
      +pair = command(w, op, left, right, bits)
      +done = execute(rest, B.first(R.World, Nat, pair))
      B.Bundle{B.first(R.World, List<&2, Nat>, done), B.second(R.World, Nat, pair) <> B.second(R.World, List<&2, Nat>, done)}

def fixture(commands: List<&2, Command>) -> B.Bundle<R.World, List<&2, Nat>>:
  +w = N.signal(B.empty(), R.Number{1n}, N.defaults())
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{2n}}, opts, 0n)
  +w = N.computed(0n, w, R.Literal{R.Number{3n}}, opts, 0n)
  +w = B.store_node(w, 3n, R.Node.with_kind(B.node(w, 3n), R.Render{}))
  +w = N.computed(0n, w, R.Literal{R.Number{4n}}, opts, 0n)
  +w = G.link(w, 1n, 2n)
  +w = G.link(w, 1n, 3n)
  +w = G.link(w, 1n, 4n)
  execute(commands, w)

def values(+config: U32, +pending: R.Slot, lane: R.Slot, shown: Bool) -> B.Bundle<R.Value, R.Value>:
  +w = N.signal(B.empty(), R.Number{7n}, N.defaults())
  +pair = Tx.newTransaction(w, True{}, 0n)
  +w = B.first(R.World, Nat, pair)
  +w = B.store_transaction(w, 1n, R.Transaction.with_shown(B.transaction(w, 1n), shown))
  +w = E.ext(w, 1n)
  +w = B.store_node(w, 1n, R.Node.with_pending(R.Node.with_config(B.node(w, 1n), config), pending))
  +w = B.store_extension(w, 1n, R.NodeExtension.with_lane(R.NodeExtension.with_transaction(B.extension(w, 1n), 1n), lane))
  B.Bundle{L.display(w, 1n), Truth.laneValueOf(w, 1n)}
