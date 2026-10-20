# core/core.ts:isSame. Custom comparator calls and their catch are unfinished;
# the admitted default fast arm and disabled comparator share this entry.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def isSame(+w: R.World, id: Nat, a: R.Value, b: R.Value) -> Bool:
  Bool.and(R.Node.equals(B.node(w, id)), B.equal(a, b))
