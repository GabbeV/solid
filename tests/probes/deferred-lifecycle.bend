import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct-state.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as T
import ../../runtime/affects-marks.bend as M
import ../../runtime/deferred-lifecycle.bend as D
import ./affects-marks.bend as Seed

def marks(count: Nat, w: R.World, +node: Nat) -> R.World:
  match count:
    case 0n: w
    case 1n+p: marks(p, M.mark(w, node), node)

def txs(items: List<&2, Nat>, +w: R.World, +node: Nat) -> R.World:
  match items:
    case Nil{}: w
    case +tx <> rest:
      +w = B.choose(~R.World, Nat.is_eq(tx, 0n), _ => w,
        _ =>
          +w = E.ext(w, node)
          B.store_extension(w, node, R.NodeExtension.with_transaction(B.extension(w, node), tx)))
      txs(rest, w, 1n+node)

def fixture(+op: U32, links: List<&2, R.Link>, configs: List<&2, U32>, flags: List<&2, U32>, statuses: List<&2, U32>, +node: Nat, flight: R.Value, +marked: Bool, answered: Bool, lagging: List<&2, Nat>, +incoming: R.Value, held: Bool, pending: R.Slot, loading: Bool, transactions: List<&2, Nat>, redirect: Bool, extraMarks: Nat) -> B.Bundle<R.World, R.DeferredState>:
  +w = B.first(R.World, Bool, Seed.fixture(0, links, configs, flags, statuses, node, 0n, 0n, 0n, [], 0, 0, False{}))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.choose(~R.World, redirect, _ => T.merge(w, 1n, 3n), _ => w)
  +w = txs(transactions, w, 1n)
  +n = B.node(w, node)
  +w = B.store_node(w, node, R.Node.with_pending(R.Node.with_loading(n, loading), pending))
  +w = marks(extraMarks, w, node)
  +w = B.choose(~R.World, marked, _ => M.mark(w, node), _ => w)
  +w = R.World.with_minimum(R.World.with_scheduled(w, False{}), 0n)
  +state: R.DeferredState = R.DeferredState{R.DeferredCell{node, flight, marked, answered}, lagging}
  B.choose(~B.Bundle<R.World, R.DeferredState>, U32.is_eq(op, 0), _ => D.ask(w, state, incoming),
    _ => B.choose(~B.Bundle<R.World, R.DeferredState>, U32.is_eq(op, 1), _ => D.land(w, state, incoming, held),
      _ => B.choose(~B.Bundle<R.World, R.DeferredState>, U32.is_eq(op, 2), _ => D.end(w, state),
        _ => B.choose(~B.Bundle<R.World, R.DeferredState>, U32.is_eq(op, 3), _ => D.openWindow(w, state),
          _ => B.choose(~B.Bundle<R.World, R.DeferredState>, U32.is_eq(op, 4),
            _ =>
              +pair = D.openWindow(w, state)
              +w = B.first(R.World, R.DeferredState, pair)
              +state = B.second(R.World, R.DeferredState, pair)
              D.sourceFailed(w, state, R.DeferredCell.answered(R.DeferredState.cell(state)), incoming), _ => B.Bundle{w, state})))))

def serveFixture(config: U32, pending: R.Slot, value: R.Value) -> R.Value:
  +w = N.signal(B.empty(), R.Number{7n}, N.defaults())
  +n = B.node(w, 1n)
  D.served(B.store_node(w, 1n, R.Node.with_pending(R.Node.with_config(n, config), pending)), 1n, value)
