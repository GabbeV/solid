import Base
import ./lane-guesses.bend as Commands
import ../../runtime/core.bend as C
import ../../runtime/construct.bend as N
import ../../runtime/transaction.bend as Tx
import ../../runtime/lanes-state.bend as L
import ../../runtime/extension.bend as E
import ../../runtime/graph-state.bend as G
import ../../runtime/constants.bend as K
import ../../runtime/owner.bend as O
import ../../runtime/scheduler.bend as S
import ../../runtime/equality.bend as EQ
import ../../representation/records.bend as R
import ../../representation/base.bend as B

def valueNode(+w: R.World, +id: Nat, value: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_modified(R.Node.with_status(R.Node.with_flags(R.Node.with_pending(R.Node.with_value(B.node(w, id), R.Number{value}), R.Empty{}), 0), 0), False{}))

def initial() -> R.World:
  +w = N.createOwner(R.World.with_clock(B.empty(), 5n), 0n, False{})
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.createEffectNode(w, R.Literal{R.Number{23n}}, R.Render{}, 0n, opts, 2n, 0n, 0n)
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, opts, 1n)
  +w = N.createEffectNode(w, R.Literal{R.Number{13n}}, R.User{}, 0n, opts, 1n, 0n, 0n)
  +w = N.createEffectNode(w, R.Literal{R.Number{17n}}, R.Render{}, 0n, opts, 1n, 0n, 0n)
  +w = N.createEffectNode(w, R.Literal{R.Number{19n}}, R.User{}, 0n, opts, 1n, 0n, 0n)
  +w = N.signal(w, R.Number{11n}, N.defaults())
  +w = valueNode(valueNode(valueNode(valueNode(valueNode(valueNode(w, 2n, 7n), 3n, 23n), 4n, 11n), 5n, 13n), 6n, 17n), 7n, 19n)
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, L.newLane(w, 1n))
  +w = B.first(R.World, Nat, L.newLane(w, 1n))
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  +w = E.ext(w, 2n)
  R.World.with_running(R.World.with_syncDepth(G.link(G.link(w, 2n, 3n), 4n, 5n), 1n), True{})

def queue(+w: R.World, +lane: Nat, +alternate: Bool) -> R.World:
  +render = B.choose(~Nat, alternate, _ => 6n, _ => 3n)
  +user = B.choose(~Nat, alternate, _ => 7n, _ => 5n)
  B.choose(~R.World, Nat.is_eq(lane, 0n),
    _ => R.World.with_userQueue(R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), [render])), B.append(R.QueueEntry, R.World.userQueue(w), [R.NodeRun{user}])),
    _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(R.Transaction.with_renderQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, lane)), [render])), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, lane)), [R.NodeRun{user}]))))

def cleanupActions(+bits: U32, value: R.Value) -> List<&2, R.CleanupAction>:
  +actions = B.choose(~List<&2, R.CleanupAction>, B.has(bits, 1), _ => [R.CallbackEvaluate{R.OnSettled{R.Literal{R.Undefined{}}}}], _ => [])
  +actions = B.append(R.CleanupAction, actions, B.choose(~List<&2, R.CleanupAction>, B.has(bits, 2), _ => [R.CallbackWrite{8n, R.Literal{R.Number{19n}}}], _ => []))
  B.append(R.CleanupAction, actions, B.choose(~List<&2, R.CleanupAction>, B.has(bits, 4), _ => [R.CallbackThrow{R.Literal{value}}], _ => []))

def command(c: Commands.Command, +w: R.World) -> C.Machine:
  match c:
    case Commands.Command{op, +node, value, +tx, +bits, q}:
      match op:
        case 17:
          C.run(32768n, C.beginSettle(w, [C.Evaluate{R.Literal{R.Undefined{}}, R.Undefined{}}], [R.Number{71n}]))
        case 18:
          Commands.valueMachine(R.World.with_flushTransaction(w, tx), R.Undefined{})
        case 19:
          Commands.valueMachine(B.store_transaction(w, tx, R.Transaction.with_acted(R.Transaction.with_open(B.transaction(w, tx), node), B.has(bits, 1))), R.Undefined{})
        case 20:
          Commands.valueMachine(queue(w, 0n, B.has(bits, 1)), R.Undefined{})
        case 21:
          Commands.valueMachine(queue(w, tx, B.has(bits, 1)), R.Undefined{})
        case 22:
          Commands.valueMachine(R.World.with_laneState(w, R.LaneState.with_stagedReaders(R.World.laneState(w), B.append(Nat, R.LaneState.stagedReaders(R.World.laneState(w)), [node]))), R.Undefined{})
        case 23:
          Commands.valueMachine(R.World.with_deferredZombies(w, B.append(Nat, R.World.deferredZombies(w), [node])), R.Undefined{})
        case 24:
          Commands.valueMachine(B.store_node(w, node, R.Node.with_flags(B.node(w, node), bits)), R.Undefined{})
        case 25:
          Commands.valueMachine(R.World.with_pendingNodes(w, B.append(Nat, R.World.pendingNodes(w), [node])), R.Undefined{})
        case 26:
          Commands.valueMachine(Tx.list(w, node, tx), R.Undefined{})
        case 27:
          Commands.valueMachine(O.parkChildren(w, node), R.Undefined{})
        case 28:
          Commands.valueMachine(S.deferZombie(w, node), R.Undefined{})
        case 29:
          +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
          +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.CallbackWrite{8n, R.Literal{R.Number{19n}}}, R.CallbackReturn{R.Literal{R.Boolean{False{}}}}], False{}, 0n}]))
          Commands.valueMachine(EQ.register(w, node, callback), R.Undefined{})
        case 30:
          +callback = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
          +w = R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{cleanupActions(bits, value), False{}, 0n}]))
          Commands.valueMachine(O.cleanup(w, node, callback), R.Undefined{})
        case _:
          Commands.command(c, w)

def execute(items: List<&2, Commands.Command>, +w: R.World) -> B.Bundle<R.World, List<&2, R.Value>>:
  match items:
    case Nil{}: B.Bundle{w, []}
    case c <> tail:
      +m = command(c, w)
      +done = execute(tail, C.world(m))
      B.Bundle{B.first(R.World, List<&2, R.Value>, done), B.get(R.Value, C.values(m), 0n, R.Undefined{}) <> B.second(R.World, List<&2, R.Value>, done)}

def fixture(items: List<&2, Commands.Command>) -> B.Bundle<R.World, List<&2, R.Value>>:
  execute(items, initial())
