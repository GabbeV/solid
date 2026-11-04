# core/verdict.ts:holdStaging. AskedIn distinguishes absence, clock zero, and
# transaction identity; the source resolves transaction marks only in that arm.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X

def sameClock(mark: R.AskedIn, clock: Nat) -> Bool:
  match mark:
    case R.AskedClock{at}: Nat.is_eq(at, clock)
    case _: False{}

def sameHold(+w: R.World, +id: Nat, mark: R.AskedIn) -> B.Bundle<R.World, Bool>:
  match mark:
    case R.AskedTransaction{at}:
      +left = X.resolveTx(w, at)
      +w = B.first(R.World, Nat, left)
      +current = B.choose(~Nat, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
        _ => R.NodeExtension.transaction(B.extension(w, id)), _ => R.World.flushTransaction(w))
      +right = X.resolveTx(w, current)
      B.Bundle{B.first(R.World, Nat, right), Nat.is_eq(B.second(R.World, Nat, left), B.second(R.World, Nat, right))}
    case _: B.Bundle{w, False{}}

def leaveVerdictLane(+w: R.World) -> B.Bundle<R.World, Bool>:
  +lane = R.World.passLane(w)
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(lane, 0n), _ => B.Bundle{w, True{}},
    _ => B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(R.Transaction.verdict(B.transaction(w, R.Transaction.parent(B.transaction(w, lane)))), lane),
      _ => B.Bundle{R.World.with_passLane(w, 0n), True{}}, _ => B.Bundle{w, False{}}))

# The non-store read callers always pass a source. A zero optional argument is
# the omitted store-only stagedScreen argument, whose new source dereference
# throws. Store crossings remain outside the admitted profile.
def holdStaging(+w: R.World, +reader: Nat, +id: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(id, 0n),
    _ => B.Bundle{R.World.with_fault(w, R.TypeError{}), False{}},
    _ =>
      +mark = R.NodeExtension.askedIn(B.extension(w, id))
      +eligible = Bool.and(Bool.not(Bool.or(B.has(R.Node.config(B.node(w, reader)), B.set(K.CONFIG_OWN_PROBE(), K.CONFIG_FRAME())), B.has(R.Node.flags(B.node(w, reader)), B.set(K.REACTIVE_WINDOW(), K.REACTIVE_PROBE_UNANSWERED())))), Bool.and(B.present(R.Node.pending(B.node(w, id))), Bool.and(Bool.not(B.has(R.Node.config(B.node(w, id)), B.set(K.CONFIG_ASYNC(), K.CONFIG_OVERRIDE()))), Bool.not(sameClock(mark, R.World.clock(w))))))
      B.choose(~B.Bundle<R.World, Bool>, eligible,
        _ =>
          +pair = sameHold(w, id, mark)
          +w = B.first(R.World, Bool, pair)
          B.choose(~B.Bundle<R.World, Bool>, Bool.or(Bool.not(B.ok(w)), B.second(R.World, Bool, pair)), _ => B.Bundle{w, False{}}, _ => leaveVerdictLane(w)),
        _ => B.Bundle{w, False{}}))
