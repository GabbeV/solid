import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/graph-state.bend as G
import ../../runtime/extension.bend as E
import ../../runtime/affects-marks.bend as Marks

def edges(links: List<&2, R.Link>, w: R.World) -> R.World:
  match links:
    case Nil{}:
      w
    case R.Link{dep, sub, nextDep, prevSub, nextSub, gen} <> rest:
      edges(rest, G.link(w, dep, sub))

def properties(configs: List<&2, U32>, flags: List<&2, U32>, statuses: List<&2, U32>, +w: R.World, +id: Nat) -> R.World:
  match configs flags statuses:
    case config <> cs flag <> fs status <> ss:
      +n = B.node(w, id)
      +n = R.Node.with_config(n, config)
      +n = R.Node.with_flags(n, flag)
      +n = R.Node.with_status(n, status)
      properties(cs, fs, ss, B.store_node(w, id, n), 1n+id)
    case _ _ _:
      w

def fixture(+op: U32, links: List<&2, R.Link>, configs: List<&2, U32>, flags: List<&2, U32>, statuses: List<&2, U32>, +target: Nat, +markedAt: Nat, marks: Nat, active: Nat, +seen: List<&2, Nat>, +readers: U32, +tailMode: U32, +heapMarked: Bool) -> B.Bundle<R.World, Bool>:
  +w = N.signal(B.empty(), R.Number{1n}, N.defaults())
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{2n}}, opts, 0n)
  +w = N.computed(0n, w, R.Literal{R.Number{3n}}, opts, 0n)
  +w = N.computed(0n, w, R.Literal{R.Number{4n}}, opts, 0n)
  +w = B.store_node(w, 4n, R.Node.with_kind(B.node(w, 4n), R.Render{}))
  +w = N.computed(0n, w, R.Literal{R.Number{5n}}, opts, 0n)
  +w = N.computed(0n, w, R.Literal{R.Number{6n}}, opts, 0n)
  +w = properties(configs, flags, statuses, w, 1n)
  +w = edges(links, w)
  +n = B.node(w, target)
  +w = B.store_node(w, target, R.Node.with_depsTail(n, B.choose(~Nat, U32.is_eq(tailMode, 0), _ => R.Node.depsTail(n), _ => B.choose(~Nat, U32.is_eq(tailMode, 1), _ => R.Node.deps(n), _ => 0n))))
  +w = B.choose(~R.World, Nat.is_eq(markedAt, 0n), _ => w, _ =>
    +w = E.ext(w, markedAt)
    B.store_extension(w, markedAt, R.NodeExtension.with_marks(B.extension(w, markedAt), marks)))
  +w = R.World.with_activeMarks(w, active)
  +w = R.World.with_minimum(w, 9n)
  +w = R.World.with_marked(w, heapMarked)
  B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 0), _ => Marks.marked(w, target, seen),
    _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 1), _ => Marks.covered(w, target),
      _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 2), _ => B.Bundle{Marks.repollWith(w, target, seen, readers), False{}},
        _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 3), _ => B.Bundle{Marks.mark(w, target), False{}},
          _ => Marks.unmark(w, target)))))
