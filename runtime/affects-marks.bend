# src/affects-marks.ts. Counts live marks, probes current dependencies and
# repolls verdict/truth readers. This module does not hold transactions.
# Store family hops are unfinished; no admitted constructor installs a family.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./extension.bend as E
import ./heap.bend as H

type ProbeTask is Data:
  ProbeNode{id: Nat}
  ProbeDeps{edge: Nat, tail: Nat}
  ProbeNext{edge: Nat, tail: Nat}

type RepollTask is Data:
  RepollSubs{edge: Nat}
  RepollNext{edge: Nat}

# marked: undefined tail means no cutoff; zero means the recomputing prefix
# is empty. Outside recompute, links terminate the walk themselves.
def probe(fuel: Nat, +w: R.World, work: List<&2, ProbeTask>, +seen: List<&2, Nat>) -> B.Bundle<R.World, Bool>:
  match fuel work:
    case _ Nil{}:
      B.Bundle{w, False{}}
    case 0n _:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+ +p ProbeNode{+id} <> +rest:
      +n = B.node(w, id)
      B.choose(~B.Bundle<R.World, Bool>, Bool.and(Nat.is_ne(R.Node.x(n), 0n), Nat.is_ne(R.NodeExtension.marks(B.extension(w, id)), 0n)),
        _ => B.Bundle{w, True{}},
        _ => B.choose(~B.Bundle<R.World, Bool>, Bool.or(B.has(R.Node.status(n), K.STATUS_ERROR()), B.contains(seen, id)),
          _ => probe(p, w, rest, seen),
          _ =>
            +seen = B.append(Nat, seen, [id])
            B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(n), K.CONFIG_SLOT_NODE()),
              _ => B.Bundle{R.World.with_fault(w, R.Unsupported{86n}), False{}},
              _ => B.choose(~B.Bundle<R.World, Bool>, Bool.and(B.has(R.Node.flags(n), K.REACTIVE_RECOMPUTING_DEPS()), Nat.is_eq(R.Node.depsTail(n), 0n)),
                _ => probe(p, w, rest, seen),
                _ => probe(p, w, ProbeDeps{R.Node.deps(n), B.choose(~Nat, B.has(R.Node.flags(n), K.REACTIVE_RECOMPUTING_DEPS()), _ => R.Node.depsTail(n), _ => 0n)} <> rest, seen)))))
    case 1n+ +p ProbeDeps{+edge, +tail} <> +rest:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(edge, 0n), _ => probe(p, w, rest, seen),
        _ => probe(p, w, ProbeNode{R.Link.dep(B.link(w, edge))} <> ProbeNext{edge, tail} <> rest, seen))
    case 1n+ +p ProbeNext{+edge, +tail} <> +rest:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(edge, tail), _ => probe(p, w, rest, seen),
        _ => probe(p, w, ProbeDeps{R.Link.nextDep(B.link(w, edge)), tail} <> rest, seen))

def marked(+w: R.World, id: Nat, seen: List<&2, Nat>) -> B.Bundle<R.World, Bool>:
  probe(B.budget(w), w, [ProbeNode{id}], seen)

# GlobalQueue._marked: the active count gates even starting the walk.
def covered(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(R.World.activeMarks(w), 0n),
    _ => marked(w, id, []), _ => B.Bundle{w, False{}})

# repoll: add to the shared seen set before enqueue; descend only through
# non-effects. RepollNext retains the source next-subscriber return point.
def repollWork(fuel: Nat, +w: R.World, work: List<&2, RepollTask>, +seen: List<&2, Nat>, +readers: U32) -> R.World:
  match fuel work:
    case _ Nil{}:
      w
    case 0n _:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p RepollNext{edge} <> +rest:
      repollWork(p, w, RepollSubs{R.Link.nextSub(B.link(w, edge))} <> rest, seen, readers)
    case 1n+ +p RepollSubs{+edge} <> +rest:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => repollWork(p, w, rest, seen, readers),
        _ =>
          +id = R.Link.sub(B.link(w, edge))
          B.choose(~R.World, B.contains(seen, id),
            _ => repollWork(p, w, RepollNext{edge} <> rest, seen, readers),
            _ =>
              +seen = B.append(Nat, seen, [id])
              +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), readers), _ => H.enqueueSub(w, id), _ => w)
              B.choose(~R.World, B.effect(R.Node.kind(B.node(w, id))),
                _ => repollWork(p, w, RepollNext{edge} <> rest, seen, readers),
                _ => repollWork(p, w, RepollSubs{R.Node.subs(B.node(w, id))} <> RepollNext{edge} <> rest, seen, readers))))

def repollWith(+w: R.World, +id: Nat, seen: List<&2, Nat>, readers: U32) -> R.World:
  repollWork(B.budget(w), w, [RepollSubs{R.Node.subs(B.node(w, id))}], seen, readers)

def repoll(w: R.World, id: Nat) -> R.World:
  repollWith(w, id, [], U32.or(K.CONFIG_VERDICT(), K.CONFIG_AUTHORITATIVE()))

def mark(+w: R.World, +id: Nat) -> R.World:
  +w = E.ext(w, id)
  +w = B.store_extension(w, id, R.NodeExtension.with_marks(B.extension(w, id), 1n+R.NodeExtension.marks(B.extension(w, id))))
  R.World.with_activeMarks(w, 1n+R.World.activeMarks(w))

def unmark(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  # Private caller contract: a live mark must exist. Refuse an invalid state
  # rather than letting natural subtraction silently clamp a source negative.
  B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_eq(R.World.activeMarks(w), 0n), Nat.is_eq(R.NodeExtension.marks(B.extension(w, id)), 0n)),
    _ => B.Bundle{R.World.with_fault(w, R.Unsupported{87n}), False{}},
    _ =>
      +w = R.World.with_activeMarks(w, Nat.sub(R.World.activeMarks(w), 1n))
      +remaining = Nat.sub(R.NodeExtension.marks(B.extension(w, id)), 1n)
      +w = B.store_extension(w, id, R.NodeExtension.with_marks(B.extension(w, id), remaining))
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(remaining, 0n), _ => B.Bundle{w, False{}},
        _ => B.Bundle{repoll(w, id), True{}}))
