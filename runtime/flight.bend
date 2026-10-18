# core/async.ts:handleAsync's thenable registration and callback bodies.
# AsyncObject/Observer encode external PromiseLike values and their callback
# closures. Core continuations provide the source flush() call/return point.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./pending-state.bend as P
import ./pending.bend as Q
import ./status.bend as A
import ./write.bend as W
import ./graph.bend as G
import ./owner.bend as O

def newThenable(+w: R.World, immediate: Bool, state: R.AsyncSettlement) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObject, R.World.asyncObjects(w))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{immediate, state, []}])), id}

def newObserver(+w: R.World, +node: Nat, +result: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{node, result, True{}, False{}, False{}, R.Undefined{}, R.Undefined{}}]))
  B.Bundle{w, id}

# Before .then(): result identity, question provenance and fresh own-flight set.
def register(+w: R.World, +id: Nat, +result: Nat) -> B.Bundle<R.World, Nat>:
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), result))
  +w = B.store_extension(w, id, R.NodeExtension.with_q(B.extension(w, id), B.choose(~Nat, Nat.is_ne(R.World.question(w), 0n), _ => R.World.question(w), _ => 2147483647n)))
  +w = P.clearPendingSources(w, id)
  +pair = newObserver(w, id, result)
  +w = B.first(R.World, Nat, pair)
  +observer = B.second(R.World, Nat, pair)
  +w = B.store_asyncObject(w, result, R.AsyncObject.with_observers(B.asyncObject(w, result), B.append(Nat, R.AsyncObject.observers(B.asyncObject(w, result)), [observer])))
  B.Bundle{w, observer}

def enqueueDelivery(+w: R.World, observer: Nat, rejected: Bool, value: R.Value) -> R.World:
  R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{observer, rejected, value}]))

# A synchronous callback only stashes its result; handleAsync chooses the
# verdict after .then() returns and isSync has become false.
def syncFulfilled(+w: R.World, +observer: Nat, value: R.Value) -> R.World:
  B.store_asyncObserver(w, observer, R.AsyncObserver.with_resolved(R.AsyncObserver.with_syncValue(B.asyncObserver(w, observer), value), True{}))

def syncRejected(+w: R.World, +observer: Nat, error: R.Value) -> R.World:
  B.store_asyncObserver(w, observer, R.AsyncObserver.with_rejected(R.AsyncObserver.with_syncError(B.asyncObserver(w, observer), error), True{}))

# The rejection is this flight's only while _inFlight is its RESULT object,
# not its registration. Re-registering the same thenable preserves that rule.
def handleError(+w: R.World, +id: Nat, +result: Nat, +error: R.Value) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), result), _ => w,
    _ =>
      +pending = P.isNotReady(error)
      B.choose(~R.World, Bool.and(pending, R.Node.loading(B.node(w, id))),
        _ =>
          +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), 0n))
          +w = P.parkLoadingWindow(w, id, error)
          B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))),
        _ =>
          +pair = B.choose(~B.Bundle<R.World, Bool>, pending, _ => B.Bundle{w, False{}}, _ => Q.stageError(w, id, error, False{}))
          +w = B.first(R.World, Bool, pair)
          +staged = B.second(R.World, Bool, pair)
          +w = B.choose(~R.World, Bool.and(B.ok(w), Bool.or(pending, Bool.not(staged))),
            _ => A.notifyStatusWith(w, id, B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), error, False{}), _ => w)
          +w = B.choose(~R.World, Bool.and(B.ok(w), pending), _ => Q.settlePendingSource(w, id, id), _ => w)
          +w = B.choose(~R.World, B.ok(w), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
          B.choose(~R.World, Bool.and(B.ok(w), Bool.not(pending)), _ => Q.releaseSettledDependents(w, id), _ => w)))

# setSignal's user-comparator exception belongs to the source status path.
def writeCatch(+w: R.World, +id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{error}:
      A.notifyStatus(R.World.with_fault(w, R.Healthy{}), id, error)
    case other:
      w

# asyncWrite up to its flush() call. Bool says the call was reached; ignored
# stale/dirty results perform no write or flush. Callback continuation is core's.
def asyncWrite(+w: R.World, +id: Nat, +result: Nat, value: R.Value) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_ne(R.NodeExtension.inFlight(B.extension(w, id)), result), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DIRTY())),
    _ => B.Bundle{w, False{}},
    _ =>
      +w = Q.landStatus(w, id, False{})
      +w = B.choose(~R.World, B.ok(w),
        _ =>
          +w = W.setSignal(w, id, value)
          writeCatch(w, id, R.World.fault(w)), _ => w)
      +w = B.choose(~R.World, Bool.and(B.ok(w), Bool.not(B.present(R.Node.pending(B.node(w, id))))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
          G.trimStaleDeps(w, id), _ => w)
      +w = B.choose(~R.World, B.ok(w), _ => Q.settlePendingSource(w, id, id), _ => w)
      B.Bundle{B.choose(~R.World, B.ok(w), _ => B.schedule(w), _ => w), B.ok(w)})

# Unlike releaseIfSettledUnobserved, this closure has no zombie guard in TS.
def settleAutodispose(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  release = Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), Bool.not(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))))
  B.choose(~B.Bundle<R.World, Bool>, release, _ => B.Bundle{O.unobserved(w, id), True{}}, _ => B.Bundle{w, False{}})

# handleAsync after .then has returned. Iterator flattening is a separate,
# unfinished branch; admitted settlements here are non-async payloads.
def thenResult(+w: R.World, +observer: Nat) -> B.Bundle<R.World, R.Value>:
  +o = B.asyncObserver(w, observer)
  +id = R.AsyncObserver.node(o)
  +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
  B.choose(~B.Bundle<R.World, R.Value>, R.AsyncObserver.rejected(o),
    _ =>
      +w = handleError(w, id, R.AsyncObserver.result(o), R.AsyncObserver.syncError(o))
      B.Bundle{B.choose(~R.World, B.ok(w), _ => R.World.with_fault(w, R.CallbackThrown{R.AsyncObserver.syncError(o)}), _ => w), R.Undefined{}},
    _ => B.choose(~B.Bundle<R.World, R.Value>, Bool.not(R.AsyncObserver.resolved(o)),
      _ => B.choose(~B.Bundle<R.World, R.Value>, R.Node.loading(B.node(w, id)),
        _ => B.Bundle{w, R.Node.value(B.node(w, id))},
        _ =>
          +pair = P.notReadyError(w, R.World.context(w))
          B.Bundle{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), R.Undefined{}}),
      _ => B.Bundle{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), R.AsyncObserver.syncValue(o)}))
