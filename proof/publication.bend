import Base
import ./arena.bend as Lens
import ../runtime/scheduler.bend as S
import ../representation/base.bend as B
import ../representation/records.bend as R

# Proof-only algebraic normal forms of commitValue's two stores. The loaded
# equation below checks them against the actual runtime helper, not a premise.
def clear(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{}))

def loaded(+w: R.World, +id: Nat, +node: R.Node) -> R.World:
  B.choose(~R.World, B.present(R.Node.pending(node)),
    _ => clear(B.store_node(w, id, R.Node.with_value(node, B.current(node))), id),
    _ => w)

def loadedEq(+w: R.World, +id: Nat, +node: R.Node, known: {B.node(w, id) == node : R.Node}) ->
  {S.commitValue(w, id) == loaded(w, id, node) : R.World}:
  Equal.cong(R.Node, R.World, n => loaded(w, id, n), B.node(w, id), node, known)

def stores(+w: R.World, +prefix: List<&2, R.Node>, +old: R.Node, +suffix: List<&2, R.Node>, +first: R.Node) ->
  {clear(B.store_node(Lens.arena(w, prefix, old, suffix), B.length(R.Node, prefix), first), B.length(R.Node, prefix))
    == Lens.arena(w, prefix, R.Node.with_pending(first, R.Empty{}), suffix) : R.World}:
  +id = B.length(R.Node, prefix)
  +start = Lens.arena(w, prefix, old, suffix)
  +canonical = Lens.arena(w, prefix, first, suffix)
  +stored = B.store_node(start, id, first)
  +ending = Lens.arena(w, prefix, R.Node.with_pending(first, R.Empty{}), suffix)
  Equal.trans(R.World, clear(stored, id), clear(canonical, id), ending,
    Equal.cong(R.World, R.World, state => clear(state, id), stored, canonical, Lens.store(w, prefix, old, suffix, first)),
    Equal.trans(R.World, clear(canonical, id), B.store_node(canonical, id, R.Node.with_pending(first, R.Empty{})), ending,
      Equal.cong(R.Node, R.World, n => B.store_node(canonical, id, R.Node.with_pending(n, R.Empty{})), B.node(canonical, id), first, Lens.peek(w, prefix, first, suffix)),
      Lens.store(w, prefix, first, suffix, R.Node.with_pending(first, R.Empty{}))))

law publication:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  {S.commitValue(Lens.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix), B.length(R.Node, prefix))
    == Lens.arena(w, prefix, R.Node.with_pending(R.Node.with_value(node, value), R.Empty{}), suffix) : R.World}

def publication(w, prefix, node, suffix, value):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +old = R.Node.with_pending(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, R.Present{value})
      +first = R.Node.with_value(old, value)
      +start = Lens.arena(w, prefix, old, suffix)
      +id = B.length(R.Node, prefix)
      +ending = Lens.arena(w, prefix, R.Node.with_pending(first, R.Empty{}), suffix)
      Equal.trans(R.World, S.commitValue(start, id), loaded(start, id, old), ending,
        loadedEq(start, id, old, Lens.peek(w, prefix, old, suffix)),
        stores(w, prefix, old, suffix, first))

# No pending slot means exact identity, including all queues and metadata.
def noPending(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>) ->
  {S.commitValue(Lens.arena(w, prefix, R.Node.with_pending(node, R.Empty{}), suffix), B.length(R.Node, prefix))
    == Lens.arena(w, prefix, R.Node.with_pending(node, R.Empty{}), suffix) : R.World}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +empty = R.Node.with_pending(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, R.Empty{})
      loadedEq(Lens.arena(w, prefix, empty, suffix), B.length(R.Node, prefix), empty, Lens.peek(w, prefix, empty, suffix))

def repeatPresent(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +value: R.Value) ->
  {S.commitValue(S.commitValue(Lens.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == S.commitValue(Lens.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix), B.length(R.Node, prefix)) : R.World}:
  +start = Lens.arena(w, prefix, R.Node.with_pending(node, R.Present{value}), suffix)
  +end = Lens.arena(w, prefix, R.Node.with_pending(R.Node.with_value(node, value), R.Empty{}), suffix)
  +id = B.length(R.Node, prefix)
  +once = S.commitValue(start, id)
  Equal.trans(R.World, S.commitValue(once, id), S.commitValue(end, id), once,
    Equal.cong(R.World, R.World, world => S.commitValue(world, id), once, end, publication(w, prefix, node, suffix, value)),
    Equal.trans(R.World, S.commitValue(end, id), end, once,
      noPending(w, prefix, R.Node.with_value(node, value), suffix),
      Equal.sym(R.World, once, end, publication(w, prefix, node, suffix, value))))

law idempotent:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  {S.commitValue(S.commitValue(Lens.arena(w, prefix, node, suffix), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == S.commitValue(Lens.arena(w, prefix, node, suffix), B.length(R.Node, prefix)) : R.World}

def idempotent(w, prefix, node, suffix):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      match n_pending:
        case R.Empty{}:
          +empty = R.Node.with_pending(R.Node{n_kind, n_value, R.Empty{}, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, R.Empty{})
          +start = Lens.arena(w, prefix, empty, suffix)
          +id = B.length(R.Node, prefix)
          Equal.cong(R.World, R.World, world => S.commitValue(world, id), S.commitValue(start, id), start,
            noPending(w, prefix, empty, suffix))
        case R.Present{value}:
          repeatPresent(w, prefix, R.Node{n_kind, n_value, R.Present{value}, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, value)
