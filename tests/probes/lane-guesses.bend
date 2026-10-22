import Base
import ./lane-read.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Command is Data:
  Command{op: U32, node: Nat, value: R.Value, tx: Nat, bits: U32, q: R.Question}

def initial() -> R.World:
  +w = Seed.seed()
  +w = B.store_extension(w, 2n, R.NodeExtension.with_transaction(B.extension(w, 2n), 0n))
  +w = B.store_transaction(w, 2n, R.Transaction.with_nodes(B.transaction(w, 2n), []))
  +w = R.World.with_running(R.World.with_syncDepth(w, 1n), True{})
  +w = B.store_node(w, 3n, R.Node.with_kind(B.node(w, 3n), R.Render{}))
  G.link(G.link(w, 2n, 3n), 4n, 5n)

def valueMachine(+w: R.World, value: R.Value) -> C.Machine:
  C.Machine{w, [], [value, R.Number{71n}]}

def command(c: Command, +w: R.World) -> C.Machine:
  match c:
    case Command{op, +node, +value, +tx, +bits, +q}:
      match op:
        case 0:
          C.run(8192n, C.optimisticWrite(w, [], [R.Number{71n}], node, value))
        case 1:
          valueMachine(w, L.guessedValueOf(w, node))
        case 2:
          valueMachine(w, B.selected(L.pendingGuessOf(w, node), R.NotPendingToken{}))
        case 3:
          C.run(8192n, C.applyGuessesAt(w, [C.Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}}], [R.Number{71n}], tx))
        case 4:
          valueMachine(B.store_node(w, node, R.Node.with_config(B.node(w, node), bits)), R.Undefined{})
        case 5:
          +w = Tx.holdNode(w, node, tx)
          valueMachine(B.store_node(w, node, R.Node.with_pending(B.node(w, node), R.Present{value})), R.Undefined{})
        case 6:
          +w = Tx.list(w, node, tx)
          +w = B.store_node(w, node, R.Node.with_config(B.node(w, node), B.set(R.Node.config(B.node(w, node)), B.choose(~U32, B.has(bits, 1), _ => U32.or(K.CONFIG_OVERRIDE(), K.CONFIG_GUESS()), _ => K.CONFIG_OVERRIDE()))))
          valueMachine(B.store_extension(w, node, R.NodeExtension.with_lane(B.extension(w, node), R.Present{value})), R.Undefined{})
        case 7:
          valueMachine(B.store_node(w, node, R.Node.with_pending(B.node(w, node), R.Present{value})), R.Undefined{})
        case 8:
          valueMachine(B.store_node(w, node, R.Node.with_status(B.node(w, node), bits)), R.Undefined{})
        case 10:
          valueMachine(B.store_node(w, node, R.Node.with_equals(B.node(w, node), U32.is_ne(bits, 0))), R.Undefined{})
        case 11:
          valueMachine(R.World.with_question(w, q), R.Undefined{})
        case 12:
          valueMachine(B.store_transaction(w, tx, R.Transaction.with_held(R.Transaction.with_shown(B.transaction(w, tx), B.has(bits, 1)), B.has(bits, 2))), R.Undefined{})
        case 13:
          +w = E.ext(w, node)
          valueMachine(B.store_extension(w, node, R.NodeExtension.with_q(B.extension(w, node), q)), R.Undefined{})
        case 14:
          valueMachine(Tx.merge(w, tx, node), R.Undefined{})
        case 15:
          +pair = Tx.newTransaction(w, False{}, 0n)
          valueMachine(B.first(R.World, Nat, pair), R.Number{B.second(R.World, Nat, pair)})
        case _:
          valueMachine(L.linkLanes(w, tx, node), R.Undefined{})

def execute(items: List<&2, Command>, +w: R.World) -> B.Bundle<R.World, List<&2, R.Value>>:
  match items:
    case Nil{}:
      B.Bundle{w, []}
    case c <> tail:
      +m = command(c, w)
      +done = execute(tail, C.world(m))
      B.Bundle{B.first(R.World, List<&2, R.Value>, done), B.get(R.Value, C.values(m), 0n, R.Undefined{}) <> B.second(R.World, List<&2, R.Value>, done)}

def fixture(items: List<&2, Command>) -> B.Bundle<R.World, List<&2, R.Value>>:
  execute(items, initial())
