import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/transaction.bend as T
import ../../runtime/extension.bend as E
import ../../runtime/graph.bend as G
import ../../runtime/constants.bend as K

type ProbeResult is Data:
  ProbeResult{world: R.World, answer: Nat}

def meta(+w: R.World, +id: Nat, +open: Nat, +acted: Bool, +marks: Bool) -> R.World:
  +tx = B.transaction(w, id)
  tx = R.Transaction.with_marks(R.Transaction.with_acted(R.Transaction.with_open(tx, open), acted), B.choose(~R.OptionalIds, marks, _ => R.SomeIds{[id]}, _ => R.NoIds{}))
  B.store_transaction(w, id, tx)

def initial(+running: Bool, +own: Bool, +config: U32, +status: U32, +extra: Bool) -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(w, R.Number{7n}, N.defaults())
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 1n)
  +w = N.createEffectNode(w, R.Literal{R.Number{7n}}, R.Render{}, 2n, N.defaults(), 1n, 0n, 0n)
  +w = N.createEffectNode(w, R.Literal{R.Number{7n}}, R.User{}, 3n, N.defaults(), 1n, 0n, 0n)
  +w = N.createOwner(w, 3n, False{})
  +w = N.computed(0n, w, R.Literal{R.Number{7n}}, opts, 6n)
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, True{}, 1n))
  +w = T.list(T.list(w, 3n, 1n), 2n, 2n)
  +w = meta(meta(w, 1n, 0n, False{}, own), 2n, 1n, True{}, extra)
  +w = B.store_transaction(w, 1n, R.Transaction.with_userQueue(R.Transaction.with_renderQueue(B.transaction(w, 1n), [4n]), [5n]))
  +w = B.store_transaction(w, 2n, R.Transaction.with_reruns(R.Transaction.with_renderQueue(B.transaction(w, 2n), [4n, 4n]), [3n]))
  +w = B.store_node(w, 3n, R.Node.with_flags(R.Node.with_status(R.Node.with_config(B.node(w, 3n), config), status), 0))
  +w = B.store_node(w, 4n, R.Node.with_status(B.node(w, 4n), status))
  +w = B.store_node(w, 5n, R.Node.with_status(B.node(w, 5n), status))
  +w = B.choose(~R.World, extra, _ => T.list(w, 7n, 3n), _ => w)
  R.World.with_running(w, running)

def boolProbeResult(+pair: B.Bundle<R.World, Bool>) -> ProbeResult:
  ProbeResult{B.first(R.World, Bool, pair), B.choose(~Nat, B.second(R.World, Bool, pair), _ => 1n, _ => 0n)}

def apply(+w: R.World, op: U32, +own: Bool, +extra: Bool) -> ProbeResult:
  match op:
    case 0:
      ProbeResult{T.joinFuture(w, 0n), 0n}
    case 1:
      ProbeResult{T.joinFuture(w, 1n), 0n}
    case 2:
      ProbeResult{T.joinFuture(T.joinFuture(w, 1n), 2n), 0n}
    case 3:
      ProbeResult{T.joinFuture(T.joinFuture(w, 2n), 1n), 0n}
    case 4:
      ProbeResult{T.joinPassTx(w, 1n, own), 0n}
    case 5:
      ProbeResult{T.joinPassTx(R.World.with_passTx(w, 1n), 2n, own), 0n}
    case 6:
      ProbeResult{T.holdNode(T.holdNode(w, 3n, 1n), 3n, 1n), 0n}
    case 7:
      +w = T.merge(T.list(w, 3n, 2n), 1n, 2n)
      +pair = T.txOf(w, 3n)
      ProbeResult{B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)}
    case 8:
      ProbeResult{T.merge(T.merge(w, 1n, 2n), 1n, 2n), 0n}
    case 9:
      ProbeResult{T.merge(T.merge(w, 3n, 1n), 1n, 3n), 0n}
    case 10:
      +w = T.merge(w, 1n, 2n)
      +pair = T.liveTx(w, 1n)
      ProbeResult{B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)}
    case 11:
      ProbeResult{T.unhold(T.holdNode(w, 3n, 1n), 3n), 0n}
    case 12:
      ProbeResult{T.staleReader(T.staleReader(w, 4n, 1n), 4n, 1n), 0n}
    case 13:
      ProbeResult{T.holdFrame(w, 3n, 2n), 0n}
    case 14:
      boolProbeResult(T.bornInto(w, 3n, 1n))
    case 15:
      w = B.choose(~R.World, extra, _ => R.World.with_flushTransaction(w, 1n), _ => w)
      boolProbeResult(T.frameRead(w, B.choose(~Nat, own, _ => 4n, _ => 5n), 3n))
    case 16:
      ProbeResult{T.joinPass(w, B.choose(~Nat, own, _ => 4n, _ => 5n), 3n), 0n}
    case _:
      +w = T.merge(w, 1n, 2n)
      +pair = T.txOf(w, 3n)
      ProbeResult{B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)}

def fixture(op: U32, running: Bool, +own: Bool, config: U32, status: U32, +extra: Bool) -> ProbeResult:
  apply(initial(running, own, config, status, extra), op, own, extra)

type BlockProbe is Data:
  BlockProbe{world: R.World, answer: Nat, blockers: List<&2, Nat>}

def probeKind(code: U32) -> R.NodeKind:
  match code:
    case 0:
      R.Memo{}
    case 1:
      R.Render{}
    case _:
      R.User{}

def blockApply(+w: R.World, op: U32) -> BlockProbe:
  match op:
    case 0:
      +pair = T.blocked(w, 1n)
      BlockProbe{B.first(R.World, Bool, pair), B.choose(~Nat, B.second(R.World, Bool, pair), _ => 1n, _ => 0n), []}
    case 1:
      +pair = T.ownFlights(w, 1n)
      BlockProbe{B.first(R.World, Bool, pair), B.choose(~Nat, B.second(R.World, Bool, pair), _ => 1n, _ => 0n), []}
    case 2:
      +pair = T.blockedBy(w, [3n], 1n, False{})
      BlockProbe{B.first(R.World, Bool, pair), B.choose(~Nat, B.second(R.World, Bool, pair), _ => 1n, _ => 0n), []}
    case _:
      +pair = T.blockersOf(w, 1n)
      BlockProbe{B.first(R.World, List<&2, Nat>, pair), 0n, B.second(R.World, List<&2, Nat>, pair)}

def blockFixture(op: U32, status: U32, flags: U32, +config: U32, kind: U32, readerStatus: U32, readerFlags: U32, readerConfig: U32, readerKind: U32, +stale: Bool, +error: U32, +foreign: Bool, +merged: Bool, +ancestor: Bool, +sources: U32, +open: Bool) -> BlockProbe:
  +w = initial(False{}, False{}, config, status, False{})
  +w = B.store_node(w, 3n, R.Node.with_kind(R.Node.with_flags(B.node(w, 3n), flags), probeKind(kind)))
  +w = B.store_node(w, 4n, R.Node.with_parent(R.Node.with_kind(R.Node.with_config(R.Node.with_flags(R.Node.with_status(B.node(w, 4n), readerStatus), readerFlags), readerConfig), probeKind(readerKind)), 3n))
  +w = G.link(w, 3n, 4n)
  +w = B.choose(~R.World, stale, _ => B.store_link(w, 1n, R.Link.with_gen(B.link(w, 1n), 1n)), _ => w)
  +w = B.choose(~R.World, U32.is_ne(error, 0),
    _ =>
      +w = E.ext(w, 4n)
      B.store_extension(w, 4n, R.NodeExtension.with_error(B.extension(w, 4n), B.choose(~R.Value, U32.is_eq(error, 1), _ => R.Null{},
        _ => B.choose(~R.Value, U32.is_eq(error, 2), _ => R.Boolean{False{}}, _ => R.Number{42n})))), _ => w)
  +w = B.choose(~R.World, foreign, _ => T.list(w, 3n, 2n), _ => w)
  +w = B.choose(~R.World, merged, _ => T.merge(w, 2n, 1n), _ => w)
  +w = B.choose(~R.World, ancestor, _ => T.holdNode(w, 1n, 1n), _ => w)
  +set = B.choose(~R.SourceSet, U32.is_eq(sources, 0), _ => R.NoSources{},
    _ => R.Sources{B.choose(~List<&2, Nat>, U32.is_eq(sources, 1), _ => [],
      _ => B.choose(~List<&2, Nat>, U32.is_eq(sources, 2), _ => [2n], _ => [2n, 3n]))})
  +w = B.setPendingSources(w, 3n, set)
  +w = B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), B.choose(~Nat, open, _ => 1n, _ => 0n)))
  blockApply(w, op)
