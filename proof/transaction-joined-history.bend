# A distinct join followed by arbitrary finite lookups/rejoins through either
# original identity. The evolving real World is carried between operations.
# No callback completion or rendered publication is asserted by this history.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths
import ./transaction-pair.bend as Pair

type JoinEvent is Data:
  Lookup{retired: Bool}
  Rejoin{source: Bool, target: Bool}

type Audit is Data:
  Audit{world: R.World, representatives: List<&2, Nat>}

def select(+source: Nat, +target: Nat, retired: Bool) -> Nat:
  B.choose(~Nat, retired, _ => source, _ => target)

def prepend(id: Nat, result: Audit) -> Audit:
  match result:
    case Audit{w, ids}: Audit{w, id <> ids}

def run(+source: Nat, +target: Nat, events: List<&2, JoinEvent>, w: R.World) -> Audit:
  match events:
    case Nil{}: Audit{w, []}
    case Lookup{retired} <> rest:
      +pair = X.resolveTx(w, select(source, target, retired))
      prepend(B.second(R.World, Nat, pair), run(source, target, rest, B.first(R.World, Nat, pair)))
    case Rejoin{left, right} <> rest:
      run(source, target, rest, X.merge(w, select(source, target, left), select(source, target, right)))

def expected(+root: Nat, events: List<&2, JoinEvent>) -> List<&2, Nat>:
  match events:
    case Nil{}: []
    case Lookup{retired} <> rest: root <> expected(root, rest)
    case Rejoin{left, right} <> rest: expected(root, rest)

def choice(+w: R.World, +source: Nat, +target: Nat, +root: Nat, +retired: Bool,
  first: {X.resolveTx(w, source) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  second: {X.resolveTx(w, target) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}) ->
  {X.resolveTx(w, select(source, target, retired)) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}:
  match retired:
    case False{}: second
    case True{}: first

def afterLookup(+source: Nat, +target: Nat, rest: List<&2, JoinEvent>, +pair: B.Bundle<R.World, Nat>) -> Audit:
  prepend(B.second(R.World, Nat, pair), run(source, target, rest, B.first(R.World, Nat, pair)))

# General safety within a resolved component; the concrete theorem below
# establishes its resolution premises by performing a real distinct-root join.
def preserves(+w: R.World, +source: Nat, +target: Nat, +root: Nat, events: List<&2, JoinEvent>,
  +first: {X.resolveTx(w, source) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  +second: {X.resolveTx(w, target) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}) ->
  {run(source, target, events, w) == Audit{w, expected(root, events)} : Audit}:
  match events:
    case Nil{}: {==}
    case Lookup{+retired} <> +rest:
      Equal.trans(Audit, run(source, target, Lookup{retired} <> rest, w), afterLookup(source, target, rest, B.Bundle{w, root}), Audit{w, root <> expected(root, rest)},
        Equal.cong(B.Bundle<R.World, Nat>, Audit, pair => afterLookup(source, target, rest, pair), X.resolveTx(w, select(source, target, retired)), B.Bundle{w, root}, choice(w, source, target, root, retired, first, second)),
        Equal.cong(Audit, Audit, result => prepend(root, result), run(source, target, rest, w), Audit{w, expected(root, rest)}, preserves(w, source, target, root, rest, first, second)))
    case Rejoin{+left, +right} <> +rest:
      Equal.trans(Audit, run(source, target, Rejoin{left, right} <> rest, w), run(source, target, rest, w), Audit{w, expected(root, rest)},
        Equal.cong(R.World, Audit, world => run(source, target, rest, world), X.merge(w, select(source, target, left), select(source, target, right)), w,
          Paths.common(w, select(source, target, left), select(source, target, right), root, choice(w, source, target, root, left, first, second), choice(w, source, target, root, right, first, second))), preserves(w, source, target, root, rest, first, second))

def joined(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool, +events: List<&2, JoinEvent>) ->
  {run(Pair.sourceId(prefix, gap, reverse), Pair.targetId(prefix, gap, reverse), events, Pair.merged(w, prefix, left, gap, right, suffix, reverse)) == Audit{Pair.after(w, prefix, left, gap, right, suffix, reverse), expected(Pair.targetId(prefix, gap, reverse), events)} : Audit}:
  +next = Pair.merged(w, prefix, left, gap, right, suffix, reverse)
  +root = Pair.targetId(prefix, gap, reverse)
  Equal.trans(Audit, run(Pair.sourceId(prefix, gap, reverse), root, events, next), Audit{next, expected(root, events)}, Audit{Pair.after(w, prefix, left, gap, right, suffix, reverse), expected(root, events)},
    preserves(next, Pair.sourceId(prefix, gap, reverse), root, root, events, Pair.sourceResolves(w, prefix, left, gap, right, suffix, reverse), Pair.targetResolves(w, prefix, left, gap, right, suffix, reverse)),
    Equal.cong(R.World, Audit, world => Audit{world, expected(root, events)}, next, Pair.after(w, prefix, left, gap, right, suffix, reverse), Pair.merge(w, prefix, left, gap, right, suffix, reverse)))

def world(result: Audit) -> R.World:
  match result:
    case Audit{w, ids}: w
