# signals.ts:watch and public promise delivery state, independent of constructors.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X

def newAwaiter(+w: R.World, expr: R.Expr, refresh: Bool, target: Nat) -> R.World:
  R.World.with_awaiters(w, B.append(R.Awaiter, R.World.awaiters(w), [R.Awaiter{expr, refresh, target, R.World.flushTransaction(w), 0n, 0n, R.Unresolved{}, False{}, 0n}]))

def newUntil(+w: R.World, expr: R.Expr) -> R.World:
  +id = B.length(R.Awaiter, R.World.awaiters(w))
  +w = newAwaiter(w, expr, False{}, 0n)
  B.store_awaiter(w, id, R.Awaiter.with_confirmation(R.Awaiter.with_until(B.awaiter(w, id), True{}), R.World.flushTransaction(w)))

def capture(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(R.Awaiter.node(B.awaiter(w, id)), 0n),
    _ => B.store_awaiter(w, id, R.Awaiter.with_node(B.awaiter(w, id), R.World.context(w))), _ => w)

def unwrap(value: R.Value) -> R.Value:
  match value:
    case R.StatusFailure{identity, source, cause}:
      cause
    case other:
      other

def ownJoined(+w: R.World, own: Nat, joined: Nat) -> B.Bundle<R.World, Bool>:
  match own:
    case 0n:
      B.Bundle{w, False{}}
    case 1n+pred:
      +left = X.resolveTx(w, 1n+pred)
      +right = X.resolveTx(B.first(R.World, Nat, left), joined)
      B.Bundle{B.first(R.World, Nat, right), Nat.is_eq(B.second(R.World, Nat, left), B.second(R.World, Nat, right))}

# until's inPass callback. It runs after watch's foreign-frame delivery gate,
# and only for a successful truthy predicate. Own is the original captured t.
def untilInPass(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  +own = R.Awaiter.confirmation(B.awaiter(w, id))
  B.choose(~R.World, Bool.and(B.truth(value), Bool.and(Nat.is_ne(own, 0n), R.World.running(w))),
    _ =>
      +pair = X.resolveTx(w, own)
      +w = B.first(R.World, Nat, pair)
      B.choose(~R.World, Bool.and(B.ok(w), Nat.is_ne(R.Transaction.open(B.transaction(w, B.second(R.World, Nat, pair))), 0n)),
        _ => X.joinFuture(w, own), _ => w), _ => w)

def postAnswer(+w: R.World, +id: Nat, +failed: Bool, +value: R.Value) -> R.World:
  +w = B.choose(~R.World, Bool.and(Bool.not(failed), R.Awaiter.until(B.awaiter(w, id))), _ => untilInPass(w, id, value), _ => w)
  B.choose(~R.World, B.ok(w),
    _ => R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.WatchDelivery{id, failed, value}])), _ => w)

# watch's post-expression frame rule precedes both success and error jobs.
# Active lagging/truth lane hooks remain an explicit unfinished scope.
def queueAnswer(+w: R.World, +id: Nat, +failed: Bool, +value: R.Value) -> R.World:
  +node = R.World.context(w)
  +joined = B.choose(~Nat, Nat.is_ne(R.World.flushTransaction(w), 0n), _ => R.World.flushTransaction(w), _ => R.World.passTx(w))
  B.choose(~R.World, Bool.and(B.has(R.Node.flags(B.node(w, node)), K.REACTIVE_JOINED()), Nat.is_ne(joined, 0n)),
    _ =>
      +pair = ownJoined(w, R.Awaiter.own(B.awaiter(w, id)), joined)
      +w = B.first(R.World, Bool, pair)
      B.choose(~R.World, B.ok(w),
        _ => B.choose(~R.World, B.second(R.World, Bool, pair), _ => postAnswer(w, id, failed, value),
          _ =>
            +pair = X.resolveTx(w, joined)
            X.staleReader(B.first(R.World, Nat, pair), node, B.second(R.World, Nat, pair))), _ => w),
    _ => postAnswer(w, id, failed, value))

# Native Promise resolve/reject is synchronous IO, BEFORE callback disposal.
# Its user's .then runs later in the host queue; duplicate delivery is ignored.
def settleState(+w: R.World, +id: Nat, +rejected: Bool, +value: R.Value, state: R.AsyncSettlement) -> R.World:
  match state:
    case R.Unresolved{}:
      +w = B.store_awaiter(w, id, R.Awaiter.with_state(B.awaiter(w, id), B.choose(~R.AsyncSettlement, rejected, _ => R.Rejected{value}, _ => R.Fulfilled{value})))
      R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.PromiseOutcome{id, rejected, value}]))
    case _:
      w

def settle(+w: R.World, +id: Nat, rejected: Bool, value: R.Value) -> R.World:
  settleState(w, id, rejected, value, R.Awaiter.state(B.awaiter(w, id)))
