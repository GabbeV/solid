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
import ./question.bend as J

def newThenable(+w: R.World, immediate: Bool, state: R.AsyncSettlement) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObject, R.World.asyncObjects(w))
  B.Bundle{R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{immediate, state, [], 0n}])), id}

def newObserver(+w: R.World, +node: Nat, +result: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.AsyncObserver, R.World.asyncObservers(w))
  +w = R.World.with_asyncObservers(w, B.append(R.AsyncObserver, R.World.asyncObservers(w), [R.AsyncObserver{node, result, True{}, False{}, False{}, R.Undefined{}, R.Undefined{}, 0n, 0n}]))
  B.Bundle{w, id}

# Before .then(): result identity, question provenance and fresh own-flight set.
def recordFlight(+w: R.World, +id: Nat, result: Nat) -> R.World:
  +w = E.ext(w, id)
  +w = B.store_extension(w,id,R.NodeExtension.with_inFlight(B.extension(w,id),R.FlightActive{result}))
  B.choose(~R.World,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_WINDOW()),_=>w,_=>B.store_node(w,id,R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_ASYNC()))))

def recordQuestion(+w: R.World, +id: Nat) -> R.World:
  B.store_extension(w, id, R.NodeExtension.with_q(B.extension(w, id), B.choose(~R.Question, J.isZero(R.World.question(w)), _ => J.mainline(), _ => R.World.question(w))))

def startFlight(w: R.World, +id: Nat, result: Nat) -> R.World:
  P.clearPendingSources(recordQuestion(recordFlight(w, id, result), id), id)

# The admitted synchronous no-handler .then returns undefined. Keep a no-op
# receipt in the existing observer arena, as for other logical registrations.
def calledThen(+w: R.World,+result: Nat) -> R.World:
  +pair = newObserver(w,0n,result)
  +w = B.first(R.World,Nat,pair)
  +object = B.asyncObject(w,result)
  B.store_asyncObject(w,result,R.AsyncObject.with_observers(object,B.append(Nat,R.AsyncObject.observers(object),[B.second(R.World,Nat,pair)])))

def addObserver(+w: R.World, +result: Nat, observer: Nat) -> R.World:
  +object = B.asyncObject(w, result)
  B.store_asyncObject(w, result, R.AsyncObject.with_observers(object, B.append(Nat, R.AsyncObject.observers(object), [observer])))

def register(+w: R.World, +id: Nat, +result: Nat) -> B.Bundle<R.World, Nat>:
  +w = startFlight(w, id, result)
  +pair = newObserver(w, id, result)
  +w = B.first(R.World, Nat, pair)
  +observer = B.second(R.World, Nat, pair)
  B.Bundle{addObserver(w, result, observer), observer}

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
type ErrorPosture is Data:
  ErrorDone{}
  ErrorPending{}
  ErrorActual{}

def pendingPosture(posture: ErrorPosture) -> Bool:
  match posture:
    case ErrorPending{}:
      True{}
    case _:
      False{}

def beginHandleError(+w: R.World, +id: Nat, result: Nat, +error: R.Value) -> B.Bundle<R.World, ErrorPosture>:
  B.choose(~B.Bundle<R.World, ErrorPosture>, Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result), _ => B.Bundle{w, ErrorDone{}},
    _ =>
      +pending = P.isNotReady(error)
      B.choose(~B.Bundle<R.World, ErrorPosture>, Bool.and(pending, R.Node.loading(B.node(w, id))),
        _ =>
          +w = B.store_extension(w, id, R.NodeExtension.with_inFlight(B.extension(w, id), R.FlightEmpty{}))
          +w = P.parkLoadingWindow(w, id, error)
          B.Bundle{B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), ErrorDone{}},
        _ => B.Bundle{w, B.choose(~ErrorPosture, pending, _ => ErrorPending{}, _ => ErrorActual{})}))

# Restricted direct facade composes the same guard/loading segment. The
# active core driver supplies continuations around stage/settlement releases.
def handleErrorStarted(+id: Nat, +error: R.Value, pair: B.Bundle<R.World, ErrorPosture>) -> R.World:
  match pair:
    case B.Bundle{world, ErrorDone{}}:
      world
    case B.Bundle{+w, +posture}:
          +pending = pendingPosture(posture)
          +pair = B.choose(~B.Bundle<R.World, Bool>, pending, _ => B.Bundle{w, False{}}, _ => Q.stageError(w, id, error, False{}))
          +w = B.first(R.World, Bool, pair)
          +staged = B.second(R.World, Bool, pair)
          +w = B.choose(~R.World, Bool.and(B.ok(w), Bool.or(pending, Bool.not(staged))),
            _ => A.notifyStatusWith(w, id, B.choose(~U32, pending, _ => K.STATUS_PENDING(), _ => K.STATUS_ERROR()), error), _ => w)
          +w = B.choose(~R.World, Bool.and(B.ok(w), pending), _ => Q.settlePendingSource(w, id, id), _ => w)
          +w = B.choose(~R.World, B.ok(w), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
          B.choose(~R.World, Bool.and(B.ok(w), Bool.not(pending)), _ => Q.releaseSettledDependents(w, id), _ => w)

def handleError(w: R.World, +id: Nat, result: Nat, +error: R.Value) -> R.World:
  handleErrorStarted(id, error, beginHandleError(w, id, result, error))

# asyncWrite before the dependency-tail trim. The active core driver retains
# the return points after trim and pending-source release; the direct helper
# below composes the same segments for restricted World-only probes.
def prepareAsyncWrite(+w: R.World, +id: Nat, +result: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_ne(B.flightId(R.NodeExtension.inFlight(B.extension(w, id))), result), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DIRTY())),
    _ => B.Bundle{w, False{}},
    _ =>
      +w = Q.landStatus(w, id, False{})
      B.Bundle{w, B.ok(w)})

def beginAsyncWrite(w: R.World, +id: Nat, result: Nat, value: R.Value) -> B.Bundle<R.World, Bool>:
  +pair = prepareAsyncWrite(w, id, result)
  +w = B.first(R.World, Bool, pair)
  +w = B.choose(~R.World, B.second(R.World, Bool, pair), _ => W.setSignal(w, id, value), _ => w)
  B.Bundle{w, Bool.and(B.second(R.World, Bool, pair), B.ok(w))}

def asyncWrite(+w: R.World, +id: Nat, result: Nat, value: R.Value) -> B.Bundle<R.World, Bool>:
  +pair = beginAsyncWrite(w, id, result, value)
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
    _ =>
      +w = B.choose(~R.World, Bool.not(B.present(R.Node.pending(B.node(w, id)))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{}))
          G.trimStaleDeps(w, id), _ => w)
      +w = B.choose(~R.World, B.ok(w), _ => Q.settlePendingSource(w, id, id), _ => w)
      B.Bundle{B.choose(~R.World, B.ok(w), _ => B.schedule(w), _ => w), B.ok(w)},
    _ => B.Bundle{w, False{}})

# Unlike releaseIfSettledUnobserved, this closure has no zombie guard in TS.
def shouldSettleAutodispose(+w: R.World, +id: Nat) -> Bool:
  Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), Bool.not(B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))))

def settleAutodispose(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  release = shouldSettleAutodispose(w, id)
  B.choose(~B.Bundle<R.World, Bool>, release, _ => B.Bundle{O.unobserved(w, id), True{}}, _ => B.Bundle{w, False{}})

# handleAsync's shared liveLanded tail now serves both promise and iterator
# registration. A pending promise has no iterator work before this segment.
def liveValue(+w: R.World, +id: Nat, landed: Bool, value: R.Value) -> B.Bundle<R.World, R.Value>:
  B.choose(~B.Bundle<R.World, R.Value>, landed,
    _ => B.Bundle{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), value},
    _ => B.choose(~B.Bundle<R.World, R.Value>, R.Node.loading(B.node(w, id)),
      _ => B.Bundle{w, R.Node.value(B.node(w, id))},
      _ =>
        +pair = P.notReadyError(w, R.World.context(w))
        B.Bundle{R.World.with_fault(B.first(R.World, R.Value, pair), R.CallbackThrown{B.second(R.World, R.Value, pair)}), R.Undefined{}}))

def thenValue(+w: R.World, +observer: Nat) -> B.Bundle<R.World, R.Value>:
  +o = B.asyncObserver(w, observer)
  +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
  liveValue(w, R.AsyncObserver.node(o), R.AsyncObserver.resolved(o), R.AsyncObserver.syncValue(o))

def thenResult(+w: R.World, +observer: Nat) -> B.Bundle<R.World, R.Value>:
  +o = B.asyncObserver(w, observer)
  B.choose(~B.Bundle<R.World, R.Value>, R.AsyncObserver.rejected(o),
    _ =>
      +w = B.store_asyncObserver(w, observer, R.AsyncObserver.with_isSync(o, False{}))
      +id = R.AsyncObserver.node(o)
      +w = handleError(w, id, R.AsyncObserver.result(o), R.AsyncObserver.syncError(o))
      B.Bundle{B.choose(~R.World, B.ok(w), _ => R.World.with_fault(w, R.CallbackThrown{R.AsyncObserver.syncError(o)}), _ => w), R.Undefined{}},
    _ => thenValue(w, observer))

# Native no-handler .then(): fresh identity plus an ordered external reaction.
# Its delivery uses the ordinary callback outbox, so later subscriptions cannot
# overtake this mirror. Source/target values remain external Promise IO.
def mirrorState(w: R.World,observer: Nat,state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}: w
    case R.Fulfilled{value}: enqueueDelivery(w,observer,False{},value)
    case R.Rejected{error}: enqueueDelivery(w,observer,True{},error)

def mirror(+w: R.World,+source: Nat) -> B.Bundle<R.World,Nat>:
  +pair = newThenable(w,False{},R.Unresolved{})
  +w = B.first(R.World,Nat,pair)
  +target = B.second(R.World,Nat,pair)
  +pair = newObserver(w,0n,source)
  +w = B.first(R.World,Nat,pair)
  +observer = B.second(R.World,Nat,pair)
  +w = B.store_asyncObserver(w,observer,R.AsyncObserver.with_mirrorTarget(R.AsyncObserver.with_isSync(B.asyncObserver(w,observer),False{}),target))
  +w = addObserver(w,source,observer)
  B.Bundle{mirrorState(w,observer,R.AsyncObject.state(B.asyncObject(w,source))),target}
