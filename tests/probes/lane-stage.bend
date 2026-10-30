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

def blockSources(mode: Nat) -> R.SourceSet:
  match mode:
    case 0n:
      R.NoSources{}
    case 1n:
      R.Sources{[]}
    case 2n:
      R.Sources{[1n]}
    case _:
      R.Sources{[2n]}

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
    case 14:
      B.Bundle{B.store_transaction(w, left, R.Transaction.with_open(B.transaction(w, left), right)), 0n}
    case 15:
      B.Bundle{B.store_node(w, left, R.Node.with_config(B.node(w, left), bits)), 0n}
    case 16:
      B.Bundle{B.store_transaction(w, left, R.Transaction.with_into(B.transaction(w, left), right)), 0n}
    case 17:
      B.Bundle{R.World.with_judge(w, left), 0n}
    case 18:
      B.Bundle{Tx.list(w, left, right), 0n}
    case 19:
      B.Bundle{B.setPendingSources(E.ext(w, left), left, blockSources(right)), 0n}
    case 20:
      B.Bundle{Tx.merge(w, left, right), 0n}
    case 21:
      +w = E.ext(w, left)
      B.Bundle{B.store_extension(w, left, R.NodeExtension.with_lane(B.extension(w, left), R.Present{R.Number{right}})), 0n}
    case 22:
      B.Bundle{B.store_node(w, left, R.Node.with_pending(B.node(w, left), R.Present{R.Number{right}})), 0n}
    case 23:
      B.Bundle{B.store_node(w, left, R.Node.with_pending(B.node(w, left), R.Present{R.Undefined{}})), 0n}
    case 25:
      B.Bundle{R.World.with_flushTransaction(w, left), 0n}
    case 26:
      B.Bundle{B.store_node(w, left, R.Node.with_value(B.node(w, left), R.Number{right})), 0n}
    case 24:
      B.Bundle{B.store_transaction(w, left, R.Transaction.with_shown(B.transaction(w, left), Nat.is_ne(right, 0n))), 0n}
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
  +w = G.link(w, 2n, 3n)
  +w = G.link(w, 2n, 4n)
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

type Query is Data:
  Query{kind: U32, target: Nat}

type Answer is Data:
  Answer{value: Bool, judge: Nat}

def query(+w: R.World, kind: U32, +target: Nat) -> B.Bundle<R.World, Bool>:
  match kind:
    case 0:
      Tx.blocked(w, target)
    case 1:
      Tx.ownFlights(w, target)
    case 2:
      Tx.lanesBlocked(w, target)
    case 3:
      Tx.linkBlocked(w, target)
    case 4:
      Tx.nestedBlocked(w, target)
    case _:
      Tx.guessFlights(w, target)

def queries(items: List<&2, Query>, w: R.World) -> B.Bundle<R.World, List<&2, Answer>>:
  match items:
    case Nil{}:
      B.Bundle{w, []}
    case Query{kind, target} <> rest:
      +pair = query(w, kind, target)
      +next = B.first(R.World, Bool, pair)
      +answer = {Answer{B.second(R.World, Bool, pair), R.World.judge(next)} : Answer}
      +done = queries(rest, next)
      B.Bundle{B.first(R.World, List<&2, Answer>, done), answer <> B.second(R.World, List<&2, Answer>, done)}

def blockFixture(commands: List<&2, Command>, items: List<&2, Query>) -> B.Bundle<R.World, List<&2, Answer>>:
  +pair = fixture(commands)
  queries(items, B.first(R.World, List<&2, Nat>, pair))

def stageError(mode: U32) -> L.StageError:
  match mode:
    case 0:
      L.StageAnswered{}
    case 1:
      L.StageFailed{}
    case _:
      L.StagePendingFrom{4n}

def stageFixture(commands: List<&2, Command>, effect: Bool, +create: Bool, +error: U32, repeat: Bool, running: Bool) -> B.Bundle<R.World, Bool>:
  +pair = fixture(commands)
  +w = B.first(R.World, List<&2, Nat>, pair)
  +w = R.World.with_running(w, running)
  +w = B.store_node(w, 2n, R.Node.with_kind(B.node(w, 2n), B.choose(~R.NodeKind, effect, _ => R.Render{}, _ => R.Memo{})))
  +pair = L.laneStage(w, 2n, 3n, create, stageError(error))
  B.choose(~B.Bundle<R.World, Bool>, repeat, _ => L.laneStage(B.first(R.World, Bool, pair), 2n, 3n, create, stageError(error)), _ => pair)
