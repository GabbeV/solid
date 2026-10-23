# Operation contracts for distinct ordinary transaction joins. These specify
# actual captured records, ordered transfer and full surrounding World; they
# neither resolve a replacement forest nor schedule a second runtime.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths

# Expected surviving record. Target-local metadata stays on the target; source
# arrays are appended after target arrays, including absent/present mark state.
def transfer(+source: R.Transaction, +target: R.Transaction) -> R.Transaction:
  +target = R.Transaction.with_open(target, Nat.add(R.Transaction.open(target), R.Transaction.open(source)))
  +target = R.Transaction.with_acted(target, Bool.or(R.Transaction.acted(target), R.Transaction.acted(source)))
  +target = R.Transaction.with_nodes(target, B.append(Nat, R.Transaction.nodes(target), R.Transaction.nodes(source)))
  +target = R.Transaction.with_renderQueue(target, B.append(Nat, R.Transaction.renderQueue(target), R.Transaction.renderQueue(source)))
  +target = R.Transaction.with_userQueue(target, B.append(R.QueueEntry, R.Transaction.userQueue(target), R.Transaction.userQueue(source)))
  +target = R.Transaction.with_reruns(target, B.append(Nat, R.Transaction.reruns(target), R.Transaction.reruns(source)))
  R.Transaction.with_marks(target, X.appendMarks(R.Transaction.marks(target), R.Transaction.marks(source)))

def joined(+w: R.World, +t: Nat, +f: Nat, +source: R.Transaction, target: R.Transaction) -> R.World:
  +next = B.store_transaction(B.store_transaction(w, t, R.Transaction.with_into(source, f)), f, transfer(source, target))
  R.World.with_transactions(next, X.removeIdentity(R.World.transactions(next), t))

# Captured lookups are explicit, as in scheduler.mergeResolved. This form exists
# only to state congruence of those operands against the actual helper.
def guarded(+w: R.World, +t: Nat, +f: Nat, +source: R.Transaction, +target: R.Transaction) -> R.World:
  B.choose(~R.World, Bool.or(Nat.is_eq(t, f), Bool.or(R.Transaction.lane(source), R.Transaction.lane(target))),
    _ => w, _ => joined(w, t, f, source, target))

def expand(+w: R.World, +t: Nat, +f: Nat) ->
  {X.mergeResolved(w, t, f) == guarded(w, t, f, B.transaction(w, t), B.transaction(w, f)) : R.World}:
  {==}

def records(+w: R.World, +t: Nat, +f: Nat, +source: R.Transaction, +target: R.Transaction,
  first: {B.transaction(w, t) == source : R.Transaction},
  second: {B.transaction(w, f) == target : R.Transaction},
  distinct: {Nat.is_eq(t, f) == False{} : Bool},
  ordinarySource: {R.Transaction.lane(source) == False{} : Bool},
  ordinaryTarget: {R.Transaction.lane(target) == False{} : Bool}) ->
  {X.mergeResolved(w, t, f) == joined(w, t, f, source, target) : R.World}:
  Equal.trans(R.World, X.mergeResolved(w, t, f), guarded(w, t, f, B.transaction(w, t), B.transaction(w, f)), joined(w, t, f, source, target), expand(w, t, f),
    Equal.trans(R.World, guarded(w, t, f, B.transaction(w, t), B.transaction(w, f)), guarded(w, t, f, source, B.transaction(w, f)), joined(w, t, f, source, target),
      Equal.cong(R.Transaction, R.World, record => guarded(w, t, f, record, B.transaction(w, f)), B.transaction(w, t), source, first),
      Equal.trans(R.World, guarded(w, t, f, source, B.transaction(w, f)), guarded(w, t, f, source, target), joined(w, t, f, source, target),
        Equal.cong(R.Transaction, R.World, record => guarded(w, t, f, source, record), B.transaction(w, f), target, second),
        Equal.trans(R.World, guarded(w, t, f, source, target), B.choose(~R.World, Bool.or(False{}, Bool.or(R.Transaction.lane(source), R.Transaction.lane(target))), _ => w, _ => joined(w, t, f, source, target)), joined(w, t, f, source, target),
          Equal.cong(Bool, R.World, same => B.choose(~R.World, Bool.or(same, Bool.or(R.Transaction.lane(source), R.Transaction.lane(target))), _ => w, _ => joined(w, t, f, source, target)), Nat.is_eq(t, f), False{}, distinct),
          Equal.trans(R.World, B.choose(~R.World, Bool.or(R.Transaction.lane(source), R.Transaction.lane(target)), _ => w, _ => joined(w, t, f, source, target)), B.choose(~R.World, R.Transaction.lane(target), _ => w, _ => joined(w, t, f, source, target)), joined(w, t, f, source, target),
            Equal.cong(Bool, R.World, lane => B.choose(~R.World, Bool.or(lane, R.Transaction.lane(target)), _ => w, _ => joined(w, t, f, source, target)), R.Transaction.lane(source), False{}, ordinarySource),
            Equal.cong(Bool, R.World, lane => B.choose(~R.World, lane, _ => w, _ => joined(w, t, f, source, target)), R.Transaction.lane(target), False{}, ordinaryTarget))))))

# Public merge composes both actual resolutions with the captured-record law.
def public(+w: R.World, +sourceId: Nat, +targetId: Nat, +t: Nat, +f: Nat, +source: R.Transaction, +target: R.Transaction,
  sourceResolution: {X.resolveTx(w, sourceId) == B.Bundle{w, t} : B.Bundle<R.World, Nat>},
  targetResolution: {X.resolveTx(w, targetId) == B.Bundle{w, f} : B.Bundle<R.World, Nat>},
  first: {B.transaction(w, t) == source : R.Transaction},
  second: {B.transaction(w, f) == target : R.Transaction},
  distinct: {Nat.is_eq(t, f) == False{} : Bool},
  ordinarySource: {R.Transaction.lane(source) == False{} : Bool},
  ordinaryTarget: {R.Transaction.lane(target) == False{} : Bool}) ->
  {X.merge(w, sourceId, targetId) == joined(w, t, f, source, target) : R.World}:
  Equal.trans(R.World, X.merge(w, sourceId, targetId), Paths.mergeFirst(B.Bundle{w, t}, targetId), joined(w, t, f, source, target),
    Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => Paths.mergeFirst(pair, targetId), X.resolveTx(w, sourceId), B.Bundle{w, t}, sourceResolution),
    Equal.trans(R.World, Paths.mergeSecond(X.resolveTx(w, targetId), t), X.mergeResolved(w, t, f), joined(w, t, f, source, target),
      Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => Paths.mergeSecond(pair, t), X.resolveTx(w, targetId), B.Bundle{w, f}, targetResolution), records(w, t, f, source, target, first, second, distinct, ordinarySource, ordinaryTarget)))
