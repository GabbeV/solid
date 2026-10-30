# Empty source member list consumes no blockers; independent of lane engines.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X

def emptyList(+fuel: Nat, +w: R.World, +owner: Nat) ->
  {X.blockedList(fuel, w, [], owner, False{}) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  match fuel:
    case 0n:
      {==}
    case 1n+p:
      {==}

# Proof decomposition of the exact blocked-head return point.
