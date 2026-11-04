# Generic public flush equality transport, independent of fixed programs.
import Base
import ../runtime/api.bend as A
import ../representation/records.bend as R

def flush_completed(+fuel: Nat, +a: R.World, +b: R.World, +end: R.World,
  staged: {a == b : R.World}, reached: {A.flush(fuel, b) == end : R.World}) ->
  {A.flush(fuel, a) == end : R.World}:
  Equal.trans(R.World, A.flush(fuel, a), A.flush(fuel, b), end,
    Equal.cong(R.World, R.World, w => A.flush(fuel, w), a, b, staged), reached)
