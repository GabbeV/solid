# Derived live occurrence supplies the scan position for the actually opened,
# joined two-action group after either first completion. No lookup premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./action-pair.bend as Actions
import ./transaction-joined-history.bend as History
import ./action-blocker-finish.bend as Held
import ./action-landing-scan.bend as Scan
import ./action-live-selection.bend as Membership
import ./live-membership.bend as Live

type Selected<-w: R.World, -root: Nat, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -frame: C.SeamFrame> is Data:
  Selected{index: Nat,
    lookup: {B.get(Nat, R.World.transactions(w), index, 0n) == root : Nat},
    retained: Scan.Retained<w, rest, stack, frame, index>}

def fromMember(+w: R.World, +root: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame,
  +location: Live.Located<R.World.transactions(w), root>,
  blocked: {X.blocked(w, root) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) -> Selected<w, root, rest, stack, frame>:
  +index = Live.index(R.World.transactions(w), root, location)
  +lookup = Live.lookup(R.World.transactions(w), root, location)
  Selected{index, lookup, Scan.certify(w, rest, stack, frame, index, root, lookup, blocked)}

def constructed(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool, +events: List<&2, History.JoinEvent>,
  +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame,
  healthy: {B.ok(w) == True{} : Bool}) ->
  Selected<A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), Pair.targetId(before, [], reverse), rest, stack, frame>:
  fromMember(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), Pair.targetId(before, [], reverse), rest, stack, frame,
    Membership.afterOne(w, before, cells, first, other, reverse, finishSecond, events), Held.afterHistory(w, before, cells, first, other, reverse, finishSecond, events, healthy))

def position(-w: R.World, -root: Nat, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -frame: C.SeamFrame, selection: Selected<w, root, rest, stack, frame>) -> Nat:
  match selection:
    case Selected{index, lookup, retained}: index
