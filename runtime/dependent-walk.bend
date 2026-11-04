# core/async.ts:walkDependents. Every arrival calls its body, including seen
# arrivals. Only a non-false, first arrival is marked and descends; its live
# dependent head is read AFTER the body (which may run nested settlement).
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

type After is Data:
  Stopped{visited: List<&2, Nat>}
  Descend{visited: List<&2, Nat>, edge: Nat}

def after(+w: R.World, +visited: List<&2, Nat>, +id: Nat, seen: Bool, returnedFalse: Bool) -> After:
  B.choose(~After, Bool.or(seen, returnedFalse), _ => Stopped{visited},
    _ => Descend{id <> visited, R.Node.subs(B.node(w, id))})

def next(w: R.World, edge: Nat) -> Nat:
  R.Link.nextSub(B.link(w, edge))
