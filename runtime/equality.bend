# core/core.ts:isSame metadata and default fast arm. The core driver invokes
# custom functions and catches at this same source call boundary. A side arena
# stores the function identity of _equals without changing source _x presence.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def isSame(+w: R.World, id: Nat, a: R.Value, b: R.Value) -> Bool:
  Bool.and(R.Node.equals(B.node(w, id)), B.equal(a, b))


def find(items: List<&2, R.ComparatorBinding>, +id: Nat) -> Nat:
  match items:
    case Nil{}:
      0n
    case R.ComparatorBinding{node, callback} <> tail:
      B.choose(~Nat, Nat.is_eq(node, id), _ => callback, _ => find(tail, id))

def custom(w: R.World, id: Nat) -> Nat:
  find(R.World.comparators(w), id)

def register(+w: R.World, +id: Nat, +callback: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(callback, 0n), _ => w,
    _ => R.World.with_comparators(w, B.append(R.ComparatorBinding, R.World.comparators(w), [R.ComparatorBinding{id, callback}])))
