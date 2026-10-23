# The actual landing scan retains a selected positive-debt group. The lookup
# premise is explicit: a global live-list membership invariant is still open.
import Base
import ../runtime/core.bend as C
import ../runtime/transaction.bend as X
import ../runtime/action-state.bend as A
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./transaction-positive.bend as Positive
import ./action-blocker-finish.bend as Held
import ./action-pair.bend as Actions
import ./transaction-pair.bend as Pair
import ./transaction-joined-history.bend as History

def checked(+pair: B.Bundle<R.World, Bool>, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat, +tx: Nat) -> C.Machine:
  +w = B.first(R.World, Bool, pair)
  B.choose(~C.Machine, B.second(R.World, Bool, pair),
    _ => C.Machine{w, C.LandTransactions{frame, index} <> rest, stack},
    _ =>
      +w = R.World.with_transactions(w, X.removeIdentity(R.World.transactions(w), tx))
      B.choose(~C.Machine, List.is_empty(&2, Nat, R.LaneState.live(R.World.laneState(w))),
        _ => C.landPrepared(w, rest, stack, frame, tx),
        _ => C.Machine{w, C.EndLanes{tx} <> C.LandAfterLanes{frame, tx} <> rest, stack}))

def scan(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat, +tx: Nat,
  lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == tx : Nat},
  blocked: {X.blocked(w, tx) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) ->
  {C.landTransactions(w, rest, stack, frame, 1n+index) == C.Machine{w, C.LandTransactions{frame, index} <> rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.landTransactions(w, rest, stack, frame, 1n+index), checked(X.blocked(w, tx), rest, stack, frame, index, tx), C.Machine{w, C.LandTransactions{frame, index} <> rest, stack},
    Equal.cong(Nat, C.Machine, selected => checked(X.blocked(w, selected), rest, stack, frame, index, selected), B.get(Nat, R.World.transactions(w), index, 0n), tx, lookup),
    Equal.cong(B.Bundle<R.World, Bool>, C.Machine, result => checked(result, rest, stack, frame, index, tx), X.blocked(w, tx), B.Bundle{w, True{}}, blocked))

def positive(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat, +tx: Nat, +remaining: Nat,
  lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == tx : Nat},
  healthy: {B.ok(w) == True{} : Bool},
  open: {R.Transaction.open(B.transaction(w, tx)) == 1n+remaining : Nat}) ->
  {C.landTransactions(w, rest, stack, frame, 1n+index) == C.Machine{w, C.LandTransactions{frame, index} <> rest, stack} : C.Machine}:
  scan(w, rest, stack, frame, index, tx, lookup, Positive.public(w, tx, remaining, healthy, open))

type Retained<-w: R.World, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -frame: C.SeamFrame, -index: Nat> is Data:
  HeldScan{equation: {C.landTransactions(w, rest, stack, frame, 1n+index) == C.Machine{w, C.LandTransactions{frame, index} <> rest, stack} : C.Machine}}

def certify(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat, +tx: Nat,
  lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == tx : Nat},
  blocked: {X.blocked(w, tx) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) -> Retained<w, rest, stack, frame, index>:
  HeldScan{scan(w, rest, stack, frame, index, tx, lookup, blocked)}

def afterOne(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool, +events: List<&2, History.JoinEvent>,
  +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +index: Nat,
  healthy: {B.ok(w) == True{} : Bool},
  lookup: {B.get(Nat, R.World.transactions(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond))), index, 0n) == Pair.targetId(before, [], reverse) : Nat}) ->
  Retained<A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), rest, stack, frame, index>:
  certify(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), rest, stack, frame, index, Pair.targetId(before, [], reverse), lookup,
    Held.afterHistory(w, before, cells, first, other, reverse, finishSecond, events, healthy))
