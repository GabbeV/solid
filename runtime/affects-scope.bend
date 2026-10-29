# affects.ts non-store mark scopes. Counts/repolls are the shared mark core;
# declarations never list a marked node as held work in their transaction.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./affects-marks.bend as M
import ./transaction.bend as T
import ./constants.bend as K

# JS (scope ??= []).push(node), preserving null versus an empty present list.
def push(scope: R.OptionalIds, node: Nat) -> R.OptionalIds:
  match scope:
    case R.NoIds{}:
      R.SomeIds{[node]}
    case R.SomeIds{items}:
      R.SomeIds{B.append(Nat, items, [node])}

def register(+w: R.World, +node: Nat) -> R.World:
  +w = M.mark(w, node)
  +t = R.World.flushTransaction(w)
  +w = B.choose(~R.World, Nat.is_eq(t, 0n),
    _ => R.World.with_ambientMarks(w, B.append(Nat, R.World.ambientMarks(w), [node])),
    _ =>
      +pair = T.resolveTx(w, t)
      +w = B.first(R.World, Nat, pair)
      +u = B.second(R.World, Nat, pair)
      B.store_transaction(w, u, R.Transaction.with_marks(B.transaction(w, u), push(R.Transaction.marks(B.transaction(w, u)), node))))
  M.repoll(w, node)

# Accessor metadata is the typed callback protocol's node identity. Opaque
# objects/functions carry no $REFRESH property in this admitted grammar.
def affects(w: R.World, value: R.Value) -> R.World:
  match value:
    case R.AccessorReference{node}:
      B.schedule(register(w, node))
    case _:
      w

# The store releaseMarkScope lookup has no entry for a non-store source.
# There is no user callback in this profile; retain the source indexed bound.
def releaseLoop(fuel: Nat, +w: R.World, +nodes: List<&2, Nat>, +index: Nat) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, nodes)), _ => w,
        _ =>
          +node = B.get(Nat, nodes, index, 0n)
          +pair = M.unmark(w, node)
          +w = B.first(R.World, Bool, pair)
          B.choose(~R.World, B.ok(w), _ => releaseLoop(p, w, nodes, 1n+index), _ => w))

def release(+w: R.World, +nodes: List<&2, Nat>) -> R.World:
  releaseLoop(1n+B.length(Nat, nodes), w, nodes, 0n)

# STATUS_PENDING short-circuits the unported store slot-flight hook.
def inFlight(+w: R.World, +node: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.status(B.node(w, node)), K.STATUS_PENDING()), _ => B.Bundle{w, True{}},
    _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, node)), K.CONFIG_SLOT_NODE()),
      _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), False{}}, _ => B.Bundle{w, False{}}))

# Transaction release retains a marked node whose own flight is still up.
# The original scope is cleared before unmark/repoll begins.
def transactionReleaseLoop(fuel: Nat, +w: R.World, +t: Nat, +nodes: List<&2, Nat>, +index: Nat, +done: List<&2, Nat>) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, nodes)),
        _ => release(B.store_transaction(w, t, R.Transaction.with_marks(B.transaction(w, t), R.SomeIds{[]})), done),
        _ =>
          +node = B.get(Nat, nodes, index, 0n)
          +pair = inFlight(w, node)
          +w = B.first(R.World, Bool, pair)
          B.choose(~R.World, B.ok(w),
            _ => B.choose(~R.World, B.second(R.World, Bool, pair),
              _ => transactionReleaseLoop(p, R.World.with_ambientMarks(w, B.append(Nat, R.World.ambientMarks(w), [node])), t, nodes, 1n+index, done),
              _ => transactionReleaseLoop(p, w, t, nodes, 1n+index, B.append(Nat, done, [node]))), _ => w))

def releaseTransactionValue(+w: R.World, +t: Nat, scope: R.OptionalIds) -> R.World:
  match scope:
    case R.NoIds{}:
      w
    case R.SomeIds{+nodes}:
      transactionReleaseLoop(1n+B.length(Nat, nodes), w, t, nodes, 0n, [])

def releaseTransaction(+w: R.World, +t: Nat) -> R.World:
  releaseTransactionValue(w, t, R.Transaction.marks(B.transaction(w, t)))

def take(count: Nat, items: List<&2, Nat>) -> List<&2, Nat>:
  match count items:
    case 0n _: []
    case _ Nil{}: []
    case 1n+p head <> tail: head <> take(p, tail)

# Ambient compaction is live and writes each retained node at the source slot.
def ambientLoop(fuel: Nat, +w: R.World, +index: Nat, +kept: Nat, +done: List<&2, Nat>) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.ambientMarks(w))),
        _ =>
          +w = R.World.with_ambientMarks(w, take(kept, R.World.ambientMarks(w)))
          B.choose(~R.World, List.is_empty(&2, Nat, done), _ => w, _ => release(w, done)),
        _ =>
          +node = B.get(Nat, R.World.ambientMarks(w), index, 0n)
          +pair = inFlight(w, node)
          +w = B.first(R.World, Bool, pair)
          B.choose(~R.World, B.ok(w),
            _ => B.choose(~R.World, B.second(R.World, Bool, pair),
              _ => ambientLoop(p, R.World.with_ambientMarks(w, B.put(Nat, R.World.ambientMarks(w), kept, 0n, node)), 1n+index, 1n+kept, done),
              _ => ambientLoop(p, w, 1n+index, kept, B.append(Nat, done, [node]))), _ => w))

def parkAmbient(fuel: Nat, +w: R.World, +t: Nat, +index: Nat) -> R.World:
  match fuel:
    case 0n:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.World.ambientMarks(w))),
        _ => R.World.with_ambientMarks(w, []),
        _ =>
          +node = B.get(Nat, R.World.ambientMarks(w), index, 0n)
          +w = B.store_transaction(w, t, R.Transaction.with_marks(B.transaction(w, t), push(R.Transaction.marks(B.transaction(w, t)), node)))
          parkAmbient(p, w, t, 1n+index))

def releaseAmbient(+w: R.World, +parked: Nat) -> R.World:
  B.choose(~R.World, List.is_empty(&2, Nat, R.World.ambientMarks(w)), _ => w,
    _ => B.choose(~R.World, Nat.is_ne(parked, 0n),
      _ => parkAmbient(1n+B.length(Nat, R.World.ambientMarks(w)), w, parked, 0n), _ => ambientLoop(1n+B.length(Nat, R.World.ambientMarks(w)), w, 0n, 0n, [])))
