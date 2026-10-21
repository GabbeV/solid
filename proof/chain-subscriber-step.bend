# One actual subscriber iteration. Fuel stays symbolic so conversion stops at
# its return point instead of unfolding the following heap/observer iterations.
import Base
import ../representation/records.bend as R
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ../proof/chain-states.bend as M

def first(+fuel: Nat, +input: Nat) -> {W.insert_subs(1n+fuel, M.setter_stamped(input), 1n) == W.insert_subs(fuel, H.enqueueSub(M.setter_stamped(input), 3n), 4n) : R.World}:
  {==}

def second(+fuel: Nat, +input: Nat) -> {W.insert_subs(1n+fuel, M.setter_enqueued3(input), 4n) == W.insert_subs(fuel, H.enqueueSub(M.setter_enqueued3(input), 5n), 0n) : R.World}:
  {==}
