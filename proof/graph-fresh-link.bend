# Connect the actual graph.link guards to its fresh allocation path. Names below
# factor source expressions for proof cuts; no runtime implementation changes.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G

def appendWithTail(+w: R.World, +root: Nat, +leaf: Nat, +previous: Nat, +next: Nat, +recomputing: Bool, +last: Nat) -> R.World:
  +edge = B.link(w, last)
  +duplicate = Bool.and(Nat.is_ne(last, 0n), Bool.and(Nat.is_eq(R.Link.sub(edge), leaf), Bool.or(Bool.not(recomputing), Nat.is_eq(R.Link.gen(edge), R.Node.depGen(B.node(w, leaf))))))
  B.choose(~R.World, duplicate, _ => w, _ => G.allocate(w, root, leaf, previous, next, last))

def appendExact(w: R.World, root: Nat, leaf: Nat, previous: Nat, next: Nat, recomputing: Bool) ->
  {G.append_or_duplicate(w, root, leaf, previous, next, recomputing) == appendWithTail(w, root, leaf, previous, next, recomputing, R.Node.subsTail(B.node(w, root))) : R.World}:
  {==}

def appendEmpty(+w: R.World, +root: Nat, +leaf: Nat, +previous: Nat, +next: Nat, +recomputing: Bool, empty: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) ->
  {G.append_or_duplicate(w, root, leaf, previous, next, recomputing) == G.allocate(w, root, leaf, previous, next, 0n) : R.World}:
  Equal.trans(R.World, G.append_or_duplicate(w, root, leaf, previous, next, recomputing), appendWithTail(w, root, leaf, previous, next, recomputing, R.Node.subsTail(B.node(w, root))), G.allocate(w, root, leaf, previous, next, 0n), appendExact(w, root, leaf, previous, next, recomputing),
    Equal.cong(Nat, R.World, last => appendWithTail(w, root, leaf, previous, next, recomputing, last), R.Node.subsTail(B.node(w, root)), 0n, empty))

def reuseInactive(w: R.World, root: Nat, leaf: Nat, previous: Nat, next: Nat) ->
  {G.reuse_or_append(w, root, leaf, previous, next, False{}) == G.append_or_duplicate(w, root, leaf, previous, next, False{}) : R.World}:
  {==}

def withLocals(+w: R.World, +root: Nat, +leaf: Nat, +previous: Nat, +recomputing: Bool) -> R.World:
  +next = B.choose(~Nat, recomputing, _ => B.choose(~Nat, Nat.is_ne(previous, 0n), _ => R.Link.nextDep(B.link(w, previous)), _ => R.Node.deps(B.node(w, leaf))), _ => 0n)
  B.choose(~R.World, Bool.and(Nat.is_ne(previous, 0n), Nat.is_eq(R.Link.dep(B.link(w, previous)), root)), _ => w, _ => G.reuse_or_append(w, root, leaf, previous, next, recomputing))

def linkExact(w: R.World, root: Nat, leaf: Nat) ->
  {G.link(w, root, leaf) == withLocals(w, root, leaf, R.Node.depsTail(B.node(w, leaf)), B.has(R.Node.flags(B.node(w, leaf)), 4)) : R.World}:
  {==}

def emptyInactive(+w: R.World, +root: Nat, +leaf: Nat, previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, inactive: {B.has(R.Node.flags(B.node(w, leaf)), 4) == False{} : Bool}) ->
  {G.link(w, root, leaf) == G.reuse_or_append(w, root, leaf, 0n, 0n, False{}) : R.World}:
  Equal.trans(R.World, G.link(w, root, leaf), withLocals(w, root, leaf, R.Node.depsTail(B.node(w, leaf)), B.has(R.Node.flags(B.node(w, leaf)), 4)), G.reuse_or_append(w, root, leaf, 0n, 0n, False{}), linkExact(w, root, leaf),
    Equal.trans(R.World, withLocals(w, root, leaf, R.Node.depsTail(B.node(w, leaf)), B.has(R.Node.flags(B.node(w, leaf)), 4)), withLocals(w, root, leaf, 0n, B.has(R.Node.flags(B.node(w, leaf)), 4)), G.reuse_or_append(w, root, leaf, 0n, 0n, False{}),
      Equal.cong(Nat, R.World, previous => withLocals(w, root, leaf, previous, B.has(R.Node.flags(B.node(w, leaf)), 4)), R.Node.depsTail(B.node(w, leaf)), 0n, previous),
      Equal.cong(Bool, R.World, recomputing => withLocals(w, root, leaf, 0n, recomputing), B.has(R.Node.flags(B.node(w, leaf)), 4), False{}, inactive)))

def fresh(+w: R.World, +root: Nat, +leaf: Nat,
  previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, inactive: {B.has(R.Node.flags(B.node(w, leaf)), 4) == False{} : Bool}, empty: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) ->
  {G.link(w, root, leaf) == G.allocate(w, root, leaf, 0n, 0n, 0n) : R.World}:
  Equal.trans(R.World, G.link(w, root, leaf), G.reuse_or_append(w, root, leaf, 0n, 0n, False{}), G.allocate(w, root, leaf, 0n, 0n, 0n), emptyInactive(w, root, leaf, previous, inactive),
    Equal.trans(R.World, G.reuse_or_append(w, root, leaf, 0n, 0n, False{}), G.append_or_duplicate(w, root, leaf, 0n, 0n, False{}), G.allocate(w, root, leaf, 0n, 0n, 0n), reuseInactive(w, root, leaf, 0n, 0n), appendEmpty(w, root, leaf, 0n, 0n, False{}, empty)))

# A freshly allocated reader has no dependencies. This path remains fresh even
# while recomputing; its flags do not need an artificial inactive restriction.
def emptyPrevious(+w: R.World, +root: Nat, +leaf: Nat, recomputing: Bool, empty: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}) ->
  {withLocals(w, root, leaf, 0n, recomputing) == G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing) : R.World}:
  match recomputing:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, R.World, next => G.reuse_or_append(w, root, leaf, 0n, next, True{}), R.Node.deps(B.node(w, leaf)), 0n, empty)

def emptyDependencies(+w: R.World, +root: Nat, +leaf: Nat, previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, empty: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}) ->
  {G.link(w, root, leaf) == G.reuse_or_append(w, root, leaf, 0n, 0n, B.has(R.Node.flags(B.node(w, leaf)), 4)) : R.World}:
  +recomputing = B.has(R.Node.flags(B.node(w, leaf)), 4)
  Equal.trans(R.World, G.link(w, root, leaf), withLocals(w, root, leaf, R.Node.depsTail(B.node(w, leaf)), recomputing), G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing), linkExact(w, root, leaf),
    Equal.trans(R.World, withLocals(w, root, leaf, R.Node.depsTail(B.node(w, leaf)), recomputing), withLocals(w, root, leaf, 0n, recomputing), G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing),
      Equal.cong(Nat, R.World, previous => withLocals(w, root, leaf, previous, recomputing), R.Node.depsTail(B.node(w, leaf)), 0n, previous), emptyPrevious(w, root, leaf, recomputing, empty)))

def reuseZeroNext(w: R.World, root: Nat, leaf: Nat, recomputing: Bool) ->
  {G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing) == G.append_or_duplicate(w, root, leaf, 0n, 0n, recomputing) : R.World}:
  match recomputing:
    case True{}: {==}
    case False{}: {==}

def freshEmptyDependencies(+w: R.World, +root: Nat, +leaf: Nat,
  previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, empty: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) ->
  {G.link(w, root, leaf) == G.allocate(w, root, leaf, 0n, 0n, 0n) : R.World}:
  +recomputing = B.has(R.Node.flags(B.node(w, leaf)), 4)
  Equal.trans(R.World, G.link(w, root, leaf), G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing), G.allocate(w, root, leaf, 0n, 0n, 0n), emptyDependencies(w, root, leaf, previous, deps),
    Equal.trans(R.World, G.reuse_or_append(w, root, leaf, 0n, 0n, recomputing), G.append_or_duplicate(w, root, leaf, 0n, 0n, recomputing), G.allocate(w, root, leaf, 0n, 0n, 0n), reuseZeroNext(w, root, leaf, recomputing), appendEmpty(w, root, leaf, 0n, 0n, recomputing, empty)))
