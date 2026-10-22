# deferred.ts:lagOf and installed GlobalQueue._lagging walk, non-store branch.
# lagging is the module Set's explicit membership view; no public constructor
# or lifetime engine is admitted by this dependency alone.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

type LagTask is Data:
  LagNode{id: Nat}
  LagDeps{edge: Nat, tail: Nat}
  LagNext{edge: Nat, tail: Nat}

# Source lagging membership precedes the seen-cycle guard. Tail zero has
# meaning only during RECOMPUTING_DEPS: no dependency has been validated.
def walk(fuel: Nat, +w: R.World, +lagging: List<&2, Nat>, work: List<&2, LagTask>, +seen: List<&2, Nat>) -> B.Bundle<R.World, Nat>:
  match fuel work:
    case _ Nil{}:
      B.Bundle{w, 0n}
    case 0n _:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), 0n}
    case 1n+ +p LagNode{+id} <> +rest:
      B.choose(~B.Bundle<R.World, Nat>, B.contains(lagging, id),
        _ => B.Bundle{w, id},
        _ => B.choose(~B.Bundle<R.World, Nat>, B.contains(seen, id),
          _ => walk(p, w, lagging, rest, seen),
          _ =>
            +seen = B.append(Nat, seen, [id])
            B.choose(~B.Bundle<R.World, Nat>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()),
              _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), 0n},
              _ => B.choose(~B.Bundle<R.World, Nat>, Bool.and(B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(B.node(w, id)), 0n)),
                _ => walk(p, w, lagging, rest, seen),
                _ => walk(p, w, lagging, LagDeps{R.Node.deps(B.node(w, id)), B.choose(~Nat, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(B.node(w, id)), _ => 0n)} <> rest, seen)))))
    case 1n+ +p LagDeps{+edge, +tail} <> +rest:
      B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(edge, 0n), _ => walk(p, w, lagging, rest, seen),
        _ => walk(p, w, lagging, LagNode{R.Link.dep(B.link(w, edge))} <> LagNext{edge, tail} <> rest, seen))
    case 1n+ +p LagNext{+edge, +tail} <> +rest:
      B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(edge, tail), _ => walk(p, w, lagging, rest, seen),
        _ => walk(p, w, lagging, LagDeps{R.Link.nextDep(B.link(w, edge)), tail} <> rest, seen))

def lagOf(+w: R.World, lagging: List<&2, Nat>, id: Nat, seen: List<&2, Nat>) -> B.Bundle<R.World, Nat>:
  walk(B.budget(w), w, lagging, [LagNode{id}], seen)

def laggingOf(+w: R.World, +lagging: List<&2, Nat>, id: Nat) -> B.Bundle<R.World, Nat>:
  B.choose(~B.Bundle<R.World, Nat>, List.is_empty(&2, Nat, lagging), _ => B.Bundle{w, 0n}, _ => lagOf(w, lagging, id, []))
