# Fulfillment's callback-free source prefix. Dependent release, owner cleanup,
# the queued flush and final publication are not executed by these contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q
import ../runtime/status.bend as S
import ../runtime/flight.bend as F
import ../runtime/write.bend as W
import ../runtime/constants.bend as K
import ./committed-storage-frame.bend as Frame
import ./pending-source-committed-frame.bend as Pending
import ./status-committed-frame.bend as Status
import ./setter-committed-frame.bend as Setter

def remainingTail(+w: R.World, +id: Nat, +clearUninitialized: Bool, +remaining: Nat) -> R.World:
  +w = B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}}))
  +w = B.choose(~R.World, clearUninitialized, _ => B.store_node(w, id, R.Node.with_status(B.node(w, id), K.STATUS_PENDING())), _ => w)
  P.setPendingError(w, id, remaining, R.Undefined{})

def remainingFrame(+w: R.World, +id: Nat, +clearUninitialized: Bool, +remaining: Nat) ->
  {Frame.observe(remainingTail(w, id, clearUninitialized, remaining)) == Frame.observe(w) : Frame.View}:
  +record = R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})
  +blocked = B.store_extension(w, id, record)
  +next = B.choose(~R.World, clearUninitialized, _ => B.store_node(blocked, id, R.Node.with_status(B.node(blocked, id), K.STATUS_PENDING())), _ => blocked)
  Frame.compose(w, blocked, remainingTail(w, id, clearUninitialized, remaining),
    Frame.compose(blocked, next, remainingTail(w, id, clearUninitialized, remaining), Pending.setError(next, id, remaining, R.Undefined{}), Frame.choice(clearUninitialized, blocked, B.store_node(blocked, id, R.Node.with_status(B.node(blocked, id), K.STATUS_PENDING())), blocked, Frame.status(blocked, id, K.STATUS_PENDING()), {==})), Frame.storeExtension(w, id, record))

def landed(+w: R.World, +id: Nat, +clearUninitialized: Bool) ->
  {Frame.observe(Q.landStatus(w, id, clearUninitialized)) == Frame.observe(w) : Frame.View}:
  +next = B.choose(~R.World, S.hasSources(B.pendingSources(w, id)), _ => B.first(R.World, Bool, P.removePendingSource(w, id, id)), _ => w)
  +remaining = B.get(Nat, P.items(B.pendingSources(next, id)), 0n, 0n)
  Frame.compose(w, next, Q.landStatus(w, id, clearUninitialized),
    Frame.choice(Nat.is_ne(remaining, 0n), next, remainingTail(next, id, clearUninitialized, remaining), S.clearStatus(next, id, clearUninitialized), remainingFrame(next, id, clearUninitialized, remaining), Status.clear(next, id, clearUninitialized)),
    Frame.choice(S.hasSources(B.pendingSources(w, id)), w, B.first(R.World, Bool, P.removePendingSource(w, id, id)), w, Pending.remove(w, id, id), {==}))

def prepare(+w: R.World, +id: Nat, +result: Nat) ->
  {Frame.observe(B.first(R.World, Bool, F.prepareAsyncWrite(w, id, result))) == Frame.observe(w) : Frame.View}:
  +next = Q.landStatus(w, id, False{})
  Frame.firstBoolChoice(Bool.or(Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DIRTY())), w, B.Bundle{w, False{}}, B.Bundle{next, B.ok(next)}, {==}, landed(w, id, False{}))

def write(+w: R.World, +id: Nat, +result: Nat, +value: R.Value) ->
  {Frame.observe(B.first(R.World, Bool, F.beginAsyncWrite(w, id, result, value))) == Frame.observe(w) : Frame.View}:
  +pair = F.prepareAsyncWrite(w, id, result)
  +next = B.first(R.World, Bool, pair)
  +written = B.choose(~R.World, B.second(R.World, Bool, pair), _ => W.setSignal(next, id, value), _ => next)
  Frame.compose(w, next, B.first(R.World, Bool, F.beginAsyncWrite(w, id, result, value)), Frame.choice(B.second(R.World, Bool, pair), next, W.setSignal(next, id, value), next, Setter.setter(next, id, value), {==}), prepare(w, id, result))

# Result identity is kept separate from group identity. A stale fulfillment is
# ignored before status bookkeeping, preserving the exact World, not only View.
def stale(+w: R.World, +id: Nat, +result: Nat,
  obsolete: {Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result) == True{} : Bool}) ->
  {F.prepareAsyncWrite(w, id, result) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  Equal.cong(Bool, B.Bundle<R.World, Bool>, stale => B.choose(~B.Bundle<R.World, Bool>, Bool.or(stale, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DIRTY())), _ => B.Bundle{w, False{}},
    _ =>
      +next = Q.landStatus(w, id, False{})
      B.Bundle{next, B.ok(next)}), Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result), True{}, obsolete)
