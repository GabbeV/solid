# A small branching-history safety theorem. Lookups and repeated joins inside
# one already-established component preserve the actual World and return its
# representative. Certificates describe into fields, not assumed transitions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as P

type Alias<-w: R.World, -root: Nat> is Data:
  Alias{path: P.Route<w>, extra: Nat,
    room: {1n+B.length(R.Transaction, R.World.txArena(w)) == Nat.add(P.depth(w, path), 1n+extra) : Nat},
    atRoot: {P.terminal(w, path) == root : Nat}}

def identity(-w: R.World, -root: Nat, alias: Alias<w, root>) -> Nat:
  match alias:
    case Alias{path, extra, room, atRoot}: P.origin(w, path)

def resolution(+w: R.World, +root: Nat, +alias: Alias<w, root>) ->
  {X.resolveTx(w, identity(w, root, alias)) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}:
  match alias:
    case Alias{+path, extra, room, atRoot}:
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(w, P.origin(w, path)), B.Bundle{w, P.terminal(w, path)}, B.Bundle{w, root}, P.public(w, path, extra, room),
        Equal.cong(Nat, B.Bundle<R.World, Nat>, id => B.Bundle{w, id}, P.terminal(w, path), root, atRoot))

type RejoinEvent<-scope: R.World, -root: Nat> is Data:
  Lookup{alias: Alias<scope, root>}
  Rejoin{source: Alias<scope, root>, target: Alias<scope, root>}

type Audit is Data:
  Audit{world: R.World, representatives: List<&2, Nat>}

def prepend(id: Nat, result: Audit) -> Audit:
  match result:
    case Audit{w, ids}: Audit{w, id <> ids}

# The evolving runtime World, not a reconstructed model, is passed to each op.
def run(-scope: R.World, -root: Nat, events: List<&2, RejoinEvent<scope, root>>, w: R.World) -> Audit:
  match events:
    case Nil{}: Audit{w, []}
    case Lookup{alias} <> rest:
      +pair = X.resolveTx(w, identity(scope, root, alias))
      prepend(B.second(R.World, Nat, pair), run(scope, root, rest, B.first(R.World, Nat, pair)))
    case Rejoin{source, target} <> rest:
      run(scope, root, rest, X.merge(w, identity(scope, root, source), identity(scope, root, target)))

def afterLookup(-scope: R.World, -root: Nat, rest: List<&2, RejoinEvent<scope, root>>, +pair: B.Bundle<R.World, Nat>) -> Audit:
  prepend(B.second(R.World, Nat, pair), run(scope, root, rest, B.first(R.World, Nat, pair)))

def expected(-scope: R.World, +root: Nat, events: List<&2, RejoinEvent<scope, root>>) -> List<&2, Nat>:
  match events:
    case Nil{}: []
    case Lookup{alias} <> rest: root <> expected(scope, root, rest)
    case Rejoin{source, target} <> rest: expected(scope, root, rest)

def preserves(+w: R.World, +root: Nat, events: List<&2, RejoinEvent<w, root>>) ->
  {run(w, root, events, w) == Audit{w, expected(w, root, events)} : Audit}:
  match events:
    case Nil{}: {==}
    case Lookup{+alias} <> +rest:
      Equal.trans(Audit, afterLookup(w, root, rest, X.resolveTx(w, identity(w, root, alias))), afterLookup(w, root, rest, B.Bundle{w, root}), Audit{w, root <> expected(w, root, rest)},
        Equal.cong(B.Bundle<R.World, Nat>, Audit, pair => afterLookup(w, root, rest, pair), X.resolveTx(w, identity(w, root, alias)), B.Bundle{w, root}, resolution(w, root, alias)),
        Equal.cong(Audit, Audit, audit => prepend(root, audit), run(w, root, rest, w), Audit{w, expected(w, root, rest)}, preserves(w, root, rest)))
    case Rejoin{+source, +target} <> +rest:
      Equal.trans(Audit, run(w, root, rest, X.merge(w, identity(w, root, source), identity(w, root, target))), run(w, root, rest, w), Audit{w, expected(w, root, rest)},
        Equal.cong(R.World, Audit, world => run(w, root, rest, world), X.merge(w, identity(w, root, source), identity(w, root, target)), w,
          P.common(w, identity(w, root, source), identity(w, root, target), root, resolution(w, root, source), resolution(w, root, target))), preserves(w, root, rest))
