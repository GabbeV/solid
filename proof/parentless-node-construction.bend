# Real default createEffectNode, including setup, on a parentless scope. Source
# callbacks are not executed by this constructor helper.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ./node-append-construction.bend as Append
import ./computed-setup-construction.bend as Setup

def index(w: R.World) -> Nat:
  B.length(R.Node, R.World.nodes(w))

def record(+w: R.World, node: R.Node) -> R.Node:
  R.Node.with_prevHeap(node, index(w))

def written(+w: R.World, +node: R.Node) ->
  {Setup.previous(N.append(w, node), index(w)) == N.append(w, record(w, node)) : R.World}:
  +next = N.append(w, node)
  Equal.trans(R.World, Setup.previous(next, index(w)), B.store_node(next, index(w), record(w, node)), N.append(w, record(w, node)),
    Equal.cong(R.Node, R.World, value => B.store_node(next, index(w), R.Node.with_prevHeap(value, index(w))), B.node(next, index(w)), node, Append.fresh(w, node)),
    Append.stored(w, node, record(w, node)))

def parentPrevious(+node: R.Node, +id: Nat) -> {R.Node.parent(R.Node.with_prevHeap(node, id)) == R.Node.parent(node) : Nat}:
  match node:
    case R.Node{kind, value, pending, equals, config, flags, status, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      {==}

def parent(+w: R.World, +node: R.Node, known: {R.Node.parent(node) == 0n : Nat}) ->
  {R.Node.parent(B.node(N.append(w, record(w, node)), index(w))) == 0n : Nat}:
  Equal.trans(Nat, R.Node.parent(B.node(N.append(w, record(w, node)), index(w))), R.Node.parent(node), 0n, Equal.trans(Nat, R.Node.parent(B.node(N.append(w, record(w, node)), index(w))), R.Node.parent(record(w, node)), R.Node.parent(node), Equal.cong(R.Node, Nat, value => R.Node.parent(value), B.node(N.append(w, record(w, node)), index(w)), record(w, node), Append.fresh(w, record(w, node))), parentPrevious(node, index(w))), known)



def exact(+w: R.World, +node: R.Node,
  parentZero: {R.Node.parent(node) == 0n : Nat},
  room: {Nat.is_lt(0n, B.length(R.Node, R.World.nodes(w))) == True{} : Bool},
  nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {N.setupComputedNode(N.append(w, node), index(w)) == N.append(w, record(w, node)) : R.World}:
  +next = N.append(w, record(w, node))
  +computed = Equal.trans(Nat, B.parentComputed(next, 0n), B.parentComputed(w, 0n), 0n, Setup.computedFromNode(w, next, Append.oldNode(w, record(w, node), 0n, room)), nullComputed)
  Setup.cut(N.append(w, node), index(w), next, written(w, node), parent(w, node, parentZero), computed)
