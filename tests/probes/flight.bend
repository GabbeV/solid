import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/flight.bend as F
import ../../runtime/extension.bend as E
import ../../runtime/pending-state.bend as P
import ../../runtime/transaction.bend as X
import ../../runtime/graph.bend as G
import ../../runtime/owner.bend as O
import ../../runtime/constants.bend as K

type FlightProbe is Data:
  FlightProbe{world: R.World, result: R.Slot}

def payload(code: U32) -> R.Value:
  match code:
    case 0:
      R.Number{23n}
    case 1:
      R.Undefined{}
    case 2:
      R.Null{}
    case 3:
      R.Boolean{False{}}
    case _:
      R.NotReadyFailure{4n, 2n}

def prepare(+status: U32, +flags: U32, +config: U32, +loading: Bool, subscriber: Bool, +staging: Bool, held: Bool) -> R.World:
  +w = N.createOwner(R.World.with_syncDepth(R.World.with_clock(B.empty(), 5n), 1n), 0n, False{})
  +w = N.signal(w, R.Number{7n}, N.defaults())
  +w = N.computed(0n, w, R.Literal{R.Number{11n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{0n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.store_node(w, 3n, R.Node.with_loading(R.Node.with_value(R.Node.with_status(R.Node.with_flags(R.Node.with_config(B.node(w, 3n), config), flags), status), R.Number{11n}), loading))
  +w = B.store_node(w, 4n, R.Node.with_flags(B.node(w, 4n), 0))
  +w = B.choose(~R.World, staging, _ => B.store_node(w, 3n, R.Node.with_pending(B.node(w, 3n), R.Present{R.Number{17n}})), _ => w)
  +w = G.link(w, 2n, 3n)
  +w = B.choose(~R.World, subscriber, _ => G.link(w, 3n, 4n), _ => w)
  +w = E.ext(w, 3n)
  +w = B.store_extension(w, 3n, R.NodeExtension.with_error(B.extension(w, 3n), B.choose(~R.Value, B.has(status, K.STATUS_ERROR()), _ => R.StatusFailure{1n, 3n, R.Number{99n}, "99"}, _ => B.choose(~R.Value, B.has(status, K.STATUS_PENDING()), _ => R.NotReadyFailure{2n, 2n}, _ => R.Undefined{}))))
  +w = B.setPendingSources(w, 3n, R.Sources{[2n, 3n]})
  +w = R.World.with_errorSerial(w, 4n)
  +w = B.choose(~R.World, held,
    _ =>
      +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
      +w = B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), 1n))
      X.holdNode(w, 3n, 1n), _ => w)
  +w = B.first(R.World, Nat, F.newThenable(w, True{}, R.Unresolved{}))
  R.World.with_context(w, 3n)

def afterCall(+w: R.World, +mode: U32, +value: R.Value) -> B.Bundle<R.World, R.Value>:
  +pair = F.register(w, 3n, 1n)
  +w = B.first(R.World, Nat, pair)
  +w = B.choose(~R.World, U32.is_eq(mode, 1), _ => F.syncFulfilled(w, 1n, value),
    _ => B.choose(~R.World, U32.is_eq(mode, 2), _ => F.syncRejected(w, 1n, value), _ => w))
  F.thenResult(w, 1n)

def fixture(mode: U32, +action: U32, status: U32, flags: U32, config: U32, loading: Bool, subscriber: Bool, staging: Bool, held: Bool, +value: U32) -> FlightProbe:
  +pair = afterCall(prepare(status, flags, config, loading, subscriber, staging, held), mode, payload(value))
  +w = B.first(R.World, R.Value, pair)
  +returned = B.choose(~R.Slot, B.ok(w), _ => R.Present{B.second(R.World, R.Value, pair)}, _ => R.Empty{})
  +w = R.World.with_context(w, 0n)
  B.choose(~FlightProbe, U32.is_eq(action, 0), _ => FlightProbe{w, returned},
    _ =>
      +w = R.World.with_fault(w, R.Healthy{})
      +w = B.choose(~R.World, U32.is_eq(action, 3), _ => B.store_node(w, 3n, R.Node.with_flags(B.node(w, 3n), B.set(R.Node.flags(B.node(w, 3n)), K.REACTIVE_DIRTY()))), _ => w)
      +w = B.choose(~R.World, U32.is_eq(action, 4), _ => B.store_extension(w, 3n, R.NodeExtension.with_inFlight(B.extension(w, 3n), 2n)), _ => w)
      +w = B.choose(~R.World, U32.is_eq(action, 5), _ => O.dispose(w, 1n), _ => w)
      FlightProbe{C.deliver(2048n, w, 1n, U32.is_eq(action, 2), payload(value)), returned})
