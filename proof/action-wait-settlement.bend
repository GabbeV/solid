# The source yielded-thenable settled cell, over arbitrary finite wait lists.
# This connects marking to actual lookup/guard code, without assuming an
# already-settled entry or global freshness/validity of all observer identities.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/core.bend as C
import ./action-laws.bend as Existing

def mark(found: Maybe<&2, R.ActionWait>) -> Maybe<&2, R.ActionWait>:
  match found:
    case None{}: None{}
    case Some{entry}: Some{R.ActionWait.with_settled(entry, True{})}

def look(same: Bool, entry: R.ActionWait, tail: Maybe<&2, R.ActionWait>) -> Maybe<&2, R.ActionWait>:
  B.choose(~Maybe<&2, R.ActionWait>, same, _ => Some{entry}, _ => tail)

def change(same: Bool, +entry: R.ActionWait) -> R.ActionWait:
  B.choose(~R.ActionWait, same, _ => R.ActionWait.with_settled(entry, True{}), _ => entry)

def observer(+entry: R.ActionWait, +same: Bool) ->
  {R.ActionWait.observer(change(same, entry)) == R.ActionWait.observer(entry) : Nat}:
  match entry:
    case R.ActionWait{observer, action, kind, settled}:
      match same:
        case False{}: {==}
        case True{}: {==}

def markedLook(+same: Bool, +entry: R.ActionWait, +tail: Maybe<&2, R.ActionWait>) ->
  {look(same, change(same, entry), mark(tail)) == mark(look(same, entry, tail)) : Maybe<&2, R.ActionWait>}:
  match same:
    case False{}: {==}
    case True{}: {==}

# No uniqueness premise is needed: settleWait marks every matching identity,
# preserves order/other fields and find returns the same first matching entry.
def findMarked(waits: List<&2, R.ActionWait>, +id: Nat) ->
  {A.find(A.settleWait(waits, id), id) == mark(A.find(waits, id)) : Maybe<&2, R.ActionWait>}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +same = Nat.is_eq(R.ActionWait.observer(head), id)
      +changed = change(same, head)
      Equal.trans(Maybe<&2, R.ActionWait>, A.find(A.settleWait(head <> tail, id), id), look(same, changed, A.find(A.settleWait(tail, id), id)), mark(A.find(head <> tail, id)),
        Equal.cong(Nat, Maybe<&2, R.ActionWait>, observer => look(Nat.is_eq(observer, id), changed, A.find(A.settleWait(tail, id), id)), R.ActionWait.observer(changed), R.ActionWait.observer(head), observer(head, same)),
        Equal.trans(Maybe<&2, R.ActionWait>, look(same, changed, A.find(A.settleWait(tail, id), id)), look(same, changed, mark(A.find(tail, id))), mark(A.find(head <> tail, id)),
          Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, found => look(same, changed, found), A.find(A.settleWait(tail, id), id), mark(A.find(tail, id)), findMarked(tail, id)), markedLook(same, head, A.find(tail, id))))

def findsSettled(+waits: List<&2, R.ActionWait>, +id: Nat, +entry: R.ActionWait,
  found: {A.find(waits, id) == Some{entry} : Maybe<&2, R.ActionWait>}) ->
  {A.find(A.settleWait(waits, id), id) == Some{R.ActionWait.with_settled(entry, True{})} : Maybe<&2, R.ActionWait>}:
  Equal.trans(Maybe<&2, R.ActionWait>, A.find(A.settleWait(waits, id), id), mark(A.find(waits, id)), Some{R.ActionWait.with_settled(entry, True{})}, findMarked(waits, id),
    Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, result => mark(result), A.find(waits, id), Some{entry}, found))

# Actual lookup followed by the actual duplicate-delivery guard. Callback body,
# task continuation, value stack, complete post-mark World are retained exactly.
def duplicate(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +action: Nat, +settled: Bool, +rejected: Bool, +value: R.Value,
  found: {A.find(R.World.actionWaits(w), id) == Some{R.ActionWait{id, action, 0, settled}} : Maybe<&2, R.ActionWait>}) ->
  {C.asyncActionDelivery(R.World.with_actionWaits(w, A.settleWait(R.World.actionWaits(w), id)), rest, stack, id, rejected, value, A.find(A.settleWait(R.World.actionWaits(w), id), id)) == C.Machine{R.World.with_actionWaits(w, A.settleWait(R.World.actionWaits(w), id)), rest, stack} : C.Machine}:
  +next = R.World.with_actionWaits(w, A.settleWait(R.World.actionWaits(w), id))
  Equal.trans(C.Machine, C.asyncActionDelivery(next, rest, stack, id, rejected, value, A.find(A.settleWait(R.World.actionWaits(w), id), id)), C.asyncActionDelivery(next, rest, stack, id, rejected, value, Some{R.ActionWait{id, action, 0, True{}}}), C.Machine{next, rest, stack},
    Equal.cong(Maybe<&2, R.ActionWait>, C.Machine, result => C.asyncActionDelivery(next, rest, stack, id, rejected, value, result), A.find(A.settleWait(R.World.actionWaits(w), id), id), Some{R.ActionWait{id, action, 0, True{}}}, findsSettled(R.World.actionWaits(w), id, R.ActionWait{id, action, 0, settled}, found)), Existing.duplicate_yield(next, rest, stack, id, action, rejected, value))

# The only two source writers of actionWaits are append (Action.wait) and
# settleWait (actionDelivery). Neither may reopen an existing settled cell.
def mapFound(+other: Nat, found: Maybe<&2, R.ActionWait>) -> Maybe<&2, R.ActionWait>:
  match found:
    case None{}: None{}
    case Some{+entry}: Some{change(Nat.is_eq(R.ActionWait.observer(entry), other), entry)}

def transformedLook(+same: Bool, +other: Nat, +entry: R.ActionWait, +tail: Maybe<&2, R.ActionWait>) ->
  {look(same, change(Nat.is_eq(R.ActionWait.observer(entry), other), entry), mapFound(other, tail)) == mapFound(other, look(same, entry, tail)) : Maybe<&2, R.ActionWait>}:
  match same:
    case False{}: {==}
    case True{}: {==}

def findOther(waits: List<&2, R.ActionWait>, +id: Nat, +other: Nat) ->
  {A.find(A.settleWait(waits, other), id) == mapFound(other, A.find(waits, id)) : Maybe<&2, R.ActionWait>}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +same = Nat.is_eq(R.ActionWait.observer(head), id)
      +changed = change(Nat.is_eq(R.ActionWait.observer(head), other), head)
      Equal.trans(Maybe<&2, R.ActionWait>, A.find(A.settleWait(head <> tail, other), id), look(same, changed, A.find(A.settleWait(tail, other), id)), mapFound(other, A.find(head <> tail, id)),
        Equal.cong(Nat, Maybe<&2, R.ActionWait>, observer => look(Nat.is_eq(observer, id), changed, A.find(A.settleWait(tail, other), id)), R.ActionWait.observer(changed), R.ActionWait.observer(head), observer(head, Nat.is_eq(R.ActionWait.observer(head), other))),
        Equal.trans(Maybe<&2, R.ActionWait>, look(same, changed, A.find(A.settleWait(tail, other), id)), look(same, changed, mapFound(other, A.find(tail, id))), mapFound(other, A.find(head <> tail, id)),
          Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, found => look(same, changed, found), A.find(A.settleWait(tail, other), id), mapFound(other, A.find(tail, id)), findOther(tail, id, other)), transformedLook(same, other, head, A.find(tail, id))))

def keep(observer: Nat, action: Nat, kind: U32, +same: Bool) ->
  {change(same, R.ActionWait{observer, action, kind, True{}}) == R.ActionWait{observer, action, kind, True{}} : R.ActionWait}:
  match same:
    case False{}: {==}
    case True{}: {==}

def otherKeeps(+waits: List<&2, R.ActionWait>, +id: Nat, +other: Nat, +observer: Nat, +action: Nat, +kind: U32,
  found: {A.find(waits, id) == Some{R.ActionWait{observer, action, kind, True{}}} : Maybe<&2, R.ActionWait>}) ->
  {A.find(A.settleWait(waits, other), id) == Some{R.ActionWait{observer, action, kind, True{}}} : Maybe<&2, R.ActionWait>}:
  +entry = {R.ActionWait{observer, action, kind, True{}} : R.ActionWait}
  Equal.trans(Maybe<&2, R.ActionWait>, A.find(A.settleWait(waits, other), id), mapFound(other, A.find(waits, id)), Some{entry}, findOther(waits, id, other),
    Equal.trans(Maybe<&2, R.ActionWait>, mapFound(other, A.find(waits, id)), mapFound(other, Some{entry}), Some{entry},
      Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, result => mapFound(other, result), A.find(waits, id), Some{entry}, found),
      Equal.cong(R.ActionWait, Maybe<&2, R.ActionWait>, value => Some{value}, change(Nat.is_eq(observer, other), entry), entry, keep(observer, action, kind, Nat.is_eq(observer, other)))))

def prefer(found: Maybe<&2, R.ActionWait>, tail: Maybe<&2, R.ActionWait>) -> Maybe<&2, R.ActionWait>:
  match found:
    case None{}: tail
    case Some{entry}: Some{entry}

def appendedLook(+same: Bool, +entry: R.ActionWait, +tail: Maybe<&2, R.ActionWait>, +suffix: Maybe<&2, R.ActionWait>) ->
  {look(same, entry, prefer(tail, suffix)) == prefer(look(same, entry, tail), suffix) : Maybe<&2, R.ActionWait>}:
  match same:
    case False{}: {==}
    case True{}: {==}

def findAppend(waits: List<&2, R.ActionWait>, +suffix: List<&2, R.ActionWait>, +id: Nat) ->
  {A.find(B.append(R.ActionWait, waits, suffix), id) == prefer(A.find(waits, id), A.find(suffix, id)) : Maybe<&2, R.ActionWait>}:
  match waits:
    case Nil{}: {==}
    case +head <> +tail:
      +same = Nat.is_eq(R.ActionWait.observer(head), id)
      Equal.trans(Maybe<&2, R.ActionWait>, A.find(B.append(R.ActionWait, head <> tail, suffix), id), look(same, head, prefer(A.find(tail, id), A.find(suffix, id))), prefer(A.find(head <> tail, id), A.find(suffix, id)),
        Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, result => look(same, head, result), A.find(B.append(R.ActionWait, tail, suffix), id), prefer(A.find(tail, id), A.find(suffix, id)), findAppend(tail, suffix, id)), appendedLook(same, head, A.find(tail, id), A.find(suffix, id)))

def appendKeeps(+waits: List<&2, R.ActionWait>, +suffix: List<&2, R.ActionWait>, +id: Nat, +entry: R.ActionWait,
  found: {A.find(waits, id) == Some{entry} : Maybe<&2, R.ActionWait>}) ->
  {A.find(B.append(R.ActionWait, waits, suffix), id) == Some{entry} : Maybe<&2, R.ActionWait>}:
  Equal.trans(Maybe<&2, R.ActionWait>, A.find(B.append(R.ActionWait, waits, suffix), id), prefer(A.find(waits, id), A.find(suffix, id)), Some{entry}, findAppend(waits, suffix, id),
    Equal.cong(Maybe<&2, R.ActionWait>, Maybe<&2, R.ActionWait>, result => prefer(result, A.find(suffix, id)), A.find(waits, id), Some{entry}, found))

type WaitEdit is Data:
  Append{entries: List<&2, R.ActionWait>}
  Settle{observer: Nat}

def run(events: List<&2, WaitEdit>, waits: List<&2, R.ActionWait>) -> List<&2, R.ActionWait>:
  match events:
    case Nil{}: waits
    case Append{entries} <> rest: run(rest, B.append(R.ActionWait, waits, entries))
    case Settle{observer} <> rest: run(rest, A.settleWait(waits, observer))

# Arbitrary finite interleavings of the source list writes preserve the first
# settled lookup, even if other waits are appended or unrelated callbacks fire.
# This is a wait-list invariant; it is not arbitrary-generator termination.
def history(events: List<&2, WaitEdit>, +waits: List<&2, R.ActionWait>, +id: Nat, +observer: Nat, +action: Nat, +kind: U32,
  found: {A.find(waits, id) == Some{R.ActionWait{observer, action, kind, True{}}} : Maybe<&2, R.ActionWait>}) ->
  {A.find(run(events, waits), id) == Some{R.ActionWait{observer, action, kind, True{}}} : Maybe<&2, R.ActionWait>}:
  match events:
    case Nil{}: found
    case Append{+entries} <> rest:
      history(rest, B.append(R.ActionWait, waits, entries), id, observer, action, kind, appendKeeps(waits, entries, id, R.ActionWait{observer, action, kind, True{}}, found))
    case Settle{+other} <> rest:
      history(rest, A.settleWait(waits, other), id, observer, action, kind, otherKeeps(waits, id, other, observer, action, kind, found))

# First marking establishes the history premise. This includes both fulfillment
# and rejection of the same yielded thenable; neither can reopen that yield.
def markedHistory(+events: List<&2, WaitEdit>, +waits: List<&2, R.ActionWait>, +id: Nat, +action: Nat, +settled: Bool,
  found: {A.find(waits, id) == Some{R.ActionWait{id, action, 0, settled}} : Maybe<&2, R.ActionWait>}) ->
  {A.find(run(events, A.settleWait(waits, id)), id) == Some{R.ActionWait{id, action, 0, True{}}} : Maybe<&2, R.ActionWait>}:
  history(events, A.settleWait(waits, id), id, id, action, 0, findsSettled(waits, id, R.ActionWait{id, action, 0, settled}, found))

# The current World may contain unrelated later work. Install only the wait
# field produced by the admitted list edits, then use its real lookup/guard.
def duplicateHistory(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +events: List<&2, WaitEdit>, +waits: List<&2, R.ActionWait>, +id: Nat, +action: Nat, +settled: Bool, +rejected: Bool, +value: R.Value,
  found: {A.find(waits, id) == Some{R.ActionWait{id, action, 0, settled}} : Maybe<&2, R.ActionWait>}) ->
  {C.asyncActionDelivery(R.World.with_actionWaits(w, run(events, A.settleWait(waits, id))), rest, stack, id, rejected, value, A.find(run(events, A.settleWait(waits, id)), id)) == C.Machine{R.World.with_actionWaits(w, run(events, A.settleWait(waits, id))), rest, stack} : C.Machine}:
  +next = R.World.with_actionWaits(w, run(events, A.settleWait(waits, id)))
  Equal.trans(C.Machine, C.asyncActionDelivery(next, rest, stack, id, rejected, value, A.find(run(events, A.settleWait(waits, id)), id)), C.asyncActionDelivery(next, rest, stack, id, rejected, value, Some{R.ActionWait{id, action, 0, True{}}}), C.Machine{next, rest, stack},
    Equal.cong(Maybe<&2, R.ActionWait>, C.Machine, result => C.asyncActionDelivery(next, rest, stack, id, rejected, value, result), A.find(run(events, A.settleWait(waits, id)), id), Some{R.ActionWait{id, action, 0, True{}}}, markedHistory(events, waits, id, action, settled, found)), Existing.duplicate_yield(next, rest, stack, id, action, rejected, value))
