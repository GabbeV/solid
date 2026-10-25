# Small actual graph.link consequences for negative-oracle discrimination.
# The general construction laws live in graph-link-construction, not here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G

def input(value: R.Value, recomputing: Bool) -> R.World:
  +source = R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Memo{})
  +leaf = R.Node.with_flags(R.Node.with_kind(B.blank_node(), R.Render{}), B.choose(~U32, recomputing, _ => 4, _ => 0))
  R.World.with_nodes(B.empty(), [B.blank_node(), source, leaf])

def linked(value: R.Value, recomputing: Bool) -> R.World:
  G.link(input(value, recomputing), 1n, 2n)

def head(+value: R.Value, recomputing: Bool) -> {R.Node.subs(B.node(linked(value, recomputing), 1n)) == 1n : Nat}:
  match recomputing:
    case True{}: {==}
    case False{}: {==}

def selected(+value: R.Value, recomputing: Bool) -> {R.Link.sub(B.link(linked(value, recomputing), 1n)) == 2n : Nat}:
  match recomputing:
    case True{}: {==}
    case False{}: {==}

def end(+value: R.Value, recomputing: Bool) -> {R.Link.nextSub(B.link(linked(value, recomputing), 1n)) == 0n : Nat}:
  match recomputing:
    case True{}: {==}
    case False{}: {==}

def config(+value: R.Value, recomputing: Bool) -> {R.Node.config(B.node(linked(value, recomputing), 2n)) == 0 : U32}:
  match recomputing:
    case True{}: {==}
    case False{}: {==}
