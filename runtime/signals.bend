# signals.ts:watch, resolve and refresh (production, typed expression/accessor
# targets). Callback delivery is host IO; watcher execution uses core's machine.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./construct.bend as N
import ./core.bend as C
import ./owner.bend as O
import ./constants.bend as K
import ./watch-state.bend as U

# A Promise executor catches an escaping creation error. Successful queued
# watch answers still deliver on their own microtask; resource faults stay faults.
def creationCatch(+w: R.World, id: Nat, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{error}:
      U.settle(R.World.with_fault(w, R.Healthy{}), id, True{}, error)
    case _:
      w

def watchConfig(+awaiter: R.Awaiter) -> U32:
  B.choose(~U32, R.Awaiter.refresh(awaiter), _ => B.set(K.CONFIG_FRESH_READ(), K.CONFIG_AUTHORITATIVE()),
    _ => B.choose(~U32, R.Awaiter.until(awaiter), _ => K.CONFIG_AUTHORITATIVE(), _ => 0))

def makeWatch(fuel: Nat, +w: R.World, +id: Nat) -> R.World:
  +context = R.World.context(w)
  +tracking = R.World.tracking(w)
  +root = B.length(R.Node, R.World.nodes(w))
  +w = N.createOwner(w, context, False{})
  +w = B.store_awaiter(w, id, R.Awaiter.with_root(B.awaiter(w, id), root))
  +w = R.World.with_tracking(R.World.with_context(w, root), False{})
  +w = B.choose(~R.World, R.Awaiter.refresh(B.awaiter(w, id)), _ => w,
    _ => B.store_awaiter(w, id, R.Awaiter.with_own(B.awaiter(w, id), R.World.flushTransaction(w))))
  +config = watchConfig(B.awaiter(w, id))
  +w = B.choose(~R.World, B.has(config, K.CONFIG_AUTHORITATIVE()),
    _ => R.World.with_truthConfirmedHook(R.World.with_truthReadHook(w, True{}), True{}), _ => w)
  +options = R.NodeOptions.with_extraConfig(N.defaults(), config)
  +w = N.computed(fuel, w, R.WatchExpr{id, R.Awaiter.expr(B.awaiter(w, id))}, options, root)
  +node = R.Awaiter.node(B.awaiter(w, id))
  +w = B.choose(~R.World, B.ok(w), _ => B.store_node(w, node, R.Node.with_config(B.node(w, node), B.set(R.Node.config(B.node(w, node)), K.CONFIG_REDERIVE()))), _ => w)
  R.World.with_tracking(R.World.with_context(w, context), tracking)

def resolve(fuel: Nat, +w: R.World, expr: R.Expr) -> R.World:
  +id = B.length(R.Awaiter, R.World.awaiters(w))
  +w = makeWatch(fuel, U.newAwaiter(w, expr, False{}, 0n), id)
  creationCatch(w, id, R.World.fault(w))

# until(fn) with no timer/AbortSignal options. Falsy values are delivered to
# the callback but do not settle it; error and truthy answers use the same root.
def until(fuel: Nat, +w: R.World, expr: R.Expr) -> R.World:
  +id = B.length(R.Awaiter, R.World.awaiters(w))
  +w = makeWatch(fuel, U.newUntil(w, expr), id)
  creationCatch(w, id, R.World.fault(w))

# markRefresh happens synchronously, before creating the promise. All calls
# in one tick mark before a watcher pulls; the WatchStart is a microtask.
def refresh(+w: R.World, +target: Nat) -> R.World:
  +id = B.length(R.Awaiter, R.World.awaiters(w))
  +w = B.choose(~R.World, B.valid(w, target), _ => C.markRefresh(w, target), _ => w)
  +w = U.newAwaiter(w, R.Read{target}, True{}, target)
  B.choose(~R.World, B.valid(w, target),
    _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.WatchStart{id}])),
    _ => U.settle(w, id, False{}, R.Undefined{}))

# This call is outside the Promise executor: a creation throw from the queued
# callback escapes as host IO; it is not caught and used to reject the promise.
def startRefresh(fuel: Nat, w: R.World, id: Nat) -> R.World:
  makeWatch(fuel, w, id)

def deliver(+w: R.World, +id: Nat, +rejected: Bool, +value: R.Value) -> R.World:
  B.choose(~R.World, Bool.and(R.Awaiter.until(B.awaiter(w, id)), Bool.and(Bool.not(rejected), Bool.not(B.truth(value)))),
    _ => w,
    _ =>
      +w = U.settle(w, id, rejected, value)
      +awaiter = B.awaiter(w, id)
      O.dispose(w, B.choose(~Nat, R.Awaiter.refresh(awaiter), _ => R.Awaiter.node(awaiter), _ => R.Awaiter.root(awaiter))))
