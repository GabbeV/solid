import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/extension.bend as E
import ./arena.bend as Lens

# Proof-only decomposition of the actual ext helper's fresh branch.
def grow(+w: R.World, +id: Nat) -> R.World:
  +x = B.length(R.NodeExtension, R.World.extensions(w))
  +w = R.World.with_extensions(w, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]))
  B.store_node(w, id, R.Node.with_x(B.node(w, id), x))

def loaded(+w: R.World, +id: Nat, node: R.Node) -> R.World:
  B.choose(~R.World, Nat.is_ne(R.Node.x(node), 0n), _ => w, _ => grow(w, id))

def loadedEq(+w: R.World, +id: Nat, node: R.Node, known: {B.node(w, id) == node : R.Node}) ->
  {E.ext(w, id) == loaded(w, id, node) : R.World}:
  Equal.cong(R.Node, R.World, n => loaded(w, id, n), B.node(w, id), node, known)

def scope(w: R.World, prefix: List<&2, R.Node>, node: R.Node, suffix: List<&2, R.Node>, extensions: List<&2, R.NodeExtension>) -> R.World:
  Lens.arena(R.World.with_extensions(w, extensions), prefix, node, suffix)

def extended(w: R.World, prefix: List<&2, R.Node>, node: R.Node, suffix: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>) -> R.World:
  scope(w, prefix, R.Node.with_x(node, B.length(R.NodeExtension, extensions)), suffix, B.append(R.NodeExtension, extensions, [B.blank_extension()]))

# Low-level record facts are proved by destructuring the actual generated World.
def extension_fields(+w: R.World, prefix: List<&2, R.Node>, node: R.Node, suffix: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>) ->
  {R.World.extensions(scope(w, prefix, node, suffix, extensions)) == extensions : List<&2, R.NodeExtension>}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits}:
      {==}

def extension_reset(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, old: List<&2, R.NodeExtension>, +extensions: List<&2, R.NodeExtension>) ->
  {R.World.with_extensions(scope(w, prefix, node, suffix, old), extensions) == scope(w, prefix, node, suffix, extensions) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits}:
      {==}

def growWith(+w: R.World, +id: Nat, +extensions: List<&2, R.NodeExtension>) -> R.World:
  +x = B.length(R.NodeExtension, extensions)
  +w = R.World.with_extensions(w, B.append(R.NodeExtension, extensions, [B.blank_extension()]))
  B.store_node(w, id, R.Node.with_x(B.node(w, id), x))

def growEq(+w: R.World, +id: Nat, +extensions: List<&2, R.NodeExtension>, known: {R.World.extensions(w) == extensions : List<&2, R.NodeExtension>}) ->
  {grow(w, id) == growWith(w, id, extensions) : R.World}:
  Equal.cong(List<&2, R.NodeExtension>, R.World, xs => growWith(w, id, xs), R.World.extensions(w), extensions, known)

def setX(+w: R.World, +id: Nat, x: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_x(B.node(w, id), x))

def setXStore(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +x: Nat) ->
  {setX(Lens.arena(w, prefix, node, suffix), B.length(R.Node, prefix), x)
    == Lens.arena(w, prefix, R.Node.with_x(node, x), suffix) : R.World}:
  +id = B.length(R.Node, prefix)
  +start = Lens.arena(w, prefix, node, suffix)
  +end = Lens.arena(w, prefix, R.Node.with_x(node, x), suffix)
  Equal.trans(R.World, setX(start, id, x), B.store_node(start, id, R.Node.with_x(node, x)), end,
    Equal.cong(R.Node, R.World, n => B.store_node(start, id, R.Node.with_x(n, x)), B.node(start, id), node, Lens.peek(w, prefix, node, suffix)),
    Lens.store(w, prefix, node, suffix, R.Node.with_x(node, x)))

def growArena(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>) ->
  {grow(scope(w, prefix, node, suffix, extensions), B.length(R.Node, prefix)) == extended(w, prefix, node, suffix, extensions) : R.World}:
  +id = B.length(R.Node, prefix)
  +start = scope(w, prefix, node, suffix, extensions)
  +xs = B.append(R.NodeExtension, extensions, [B.blank_extension()])
  +x = B.length(R.NodeExtension, extensions)
  +resized = R.World.with_extensions(start, xs)
  +canonical = scope(w, prefix, node, suffix, xs)
  Equal.trans(R.World, grow(start, id), growWith(start, id, extensions), extended(w, prefix, node, suffix, extensions),
    growEq(start, id, extensions, extension_fields(w, prefix, node, suffix, extensions)),
    Equal.trans(R.World, setX(resized, id, x), setX(canonical, id, x), extended(w, prefix, node, suffix, extensions),
      Equal.cong(R.World, R.World, state => setX(state, id, x), resized, canonical, extension_reset(w, prefix, node, suffix, extensions, xs)),
      setXStore(R.World.with_extensions(w, xs), prefix, node, suffix, x)))

law existing_extension_is_exact_identity:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +x: Nat
  {E.ext(Lens.arena(w, prefix, R.Node.with_x(node, 1n+x), suffix), B.length(R.Node, prefix))
    == Lens.arena(w, prefix, R.Node.with_x(node, 1n+x), suffix) : R.World}

def existing_extension_is_exact_identity(w, prefix, node, suffix, x):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +old = R.Node.with_x(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, 1n+x)
      loadedEq(Lens.arena(w, prefix, old, suffix), B.length(R.Node, prefix), old, Lens.peek(w, prefix, old, suffix))

law fresh_extension_appends_exactly_once:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  {E.ext(scope(w, prefix, R.Node.with_x(node, 0n), suffix, extensions), B.length(R.Node, prefix))
    == extended(w, prefix, R.Node.with_x(node, 0n), suffix, extensions) : R.World}

def fresh_extension_appends_exactly_once(w, prefix, node, suffix, extensions):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +old = R.Node.with_x(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, 0n)
      +start = scope(w, prefix, old, suffix, extensions)
      +id = B.length(R.Node, prefix)
      Equal.trans(R.World, E.ext(start, id), grow(start, id), extended(w, prefix, old, suffix, extensions),
        loadedEq(start, id, old, Lens.peek(R.World.with_extensions(w, extensions), prefix, old, suffix)),
        growArena(w, prefix, old, suffix, extensions))

# Nonempty extension storage is the actual representation invariant: index zero
# is the sentinel, so a fresh appended extension has a nonzero identity.
def fresh_idempotent(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +head: R.NodeExtension, +tail: List<&2, R.NodeExtension>) ->
  {E.ext(E.ext(scope(w, prefix, R.Node.with_x(node, 0n), suffix, head <> tail), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == E.ext(scope(w, prefix, R.Node.with_x(node, 0n), suffix, head <> tail), B.length(R.Node, prefix)) : R.World}:
  +id = B.length(R.Node, prefix)
  +old = R.Node.with_x(node, 0n)
  +xs = {head <> tail : List<&2, R.NodeExtension>}
  +start = scope(w, prefix, old, suffix, xs)
  +once = E.ext(start, id)
  +end = extended(w, prefix, old, suffix, xs)
  Equal.trans(R.World, E.ext(once, id), E.ext(end, id), once,
    Equal.cong(R.World, R.World, state => E.ext(state, id), once, end, fresh_extension_appends_exactly_once(w, prefix, node, suffix, xs)),
    Equal.trans(R.World, E.ext(end, id), end, once,
      existing_extension_is_exact_identity(R.World.with_extensions(w, B.append(R.NodeExtension, xs, [B.blank_extension()])), prefix, old, suffix, B.length(R.NodeExtension, tail)),
      Equal.sym(R.World, once, end, fresh_extension_appends_exactly_once(w, prefix, node, suffix, xs))))

def get_set_x(+node: R.Node, x: Nat) -> {R.Node.x(R.Node.with_x(node, x)) == x : Nat}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def readKnown(+w: R.World, +id: Nat, +x: Nat, +extensions: List<&2, R.NodeExtension>,
  nodeX: {R.Node.x(B.node(w, id)) == x : Nat},
  field: {R.World.extensions(w) == extensions : List<&2, R.NodeExtension>}) ->
  {B.extension(w, id) == B.get(R.NodeExtension, extensions, x, B.blank_extension()) : R.NodeExtension}:
  Equal.trans(R.NodeExtension, B.extension(w, id), B.get(R.NodeExtension, R.World.extensions(w), x, B.blank_extension()), B.get(R.NodeExtension, extensions, x, B.blank_extension()),
    Equal.cong(Nat, R.NodeExtension, index => B.get(R.NodeExtension, R.World.extensions(w), index, B.blank_extension()), R.Node.x(B.node(w, id)), x, nodeX),
    Equal.cong(List<&2, R.NodeExtension>, R.NodeExtension, xs => B.get(R.NodeExtension, xs, x, B.blank_extension()), R.World.extensions(w), extensions, field))

def extended_default(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +extensions: List<&2, R.NodeExtension>) ->
  {B.extension(extended(w, prefix, node, suffix, extensions), B.length(R.Node, prefix)) == B.blank_extension() : R.NodeExtension}:
  +id = B.length(R.Node, prefix)
  +x = B.length(R.NodeExtension, extensions)
  +xs = B.append(R.NodeExtension, extensions, [B.blank_extension()])
  +nextNode = R.Node.with_x(node, x)
  +end = extended(w, prefix, node, suffix, extensions)
  +nodeX = Equal.trans(Nat, R.Node.x(B.node(end, id)), R.Node.x(nextNode), x,
    Equal.cong(R.Node, Nat, n => R.Node.x(n), B.node(end, id), nextNode, Lens.peek(R.World.with_extensions(w, xs), prefix, nextNode, suffix)), get_set_x(node, x))
  Equal.trans(R.NodeExtension, B.extension(end, id), B.get(R.NodeExtension, xs, x, B.blank_extension()), B.blank_extension(),
    readKnown(end, id, x, xs, nodeX, extension_fields(w, prefix, nextNode, suffix, xs)),
    Lens.getPrefix(R.NodeExtension, extensions, B.blank_extension(), [], B.blank_extension()))

law fresh_extension_points_to_default_record:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +extensions: List<&2, R.NodeExtension>
  {B.extension(E.ext(scope(w, prefix, R.Node.with_x(node, 0n), suffix, extensions), B.length(R.Node, prefix)), B.length(R.Node, prefix)) == B.blank_extension() : R.NodeExtension}

def fresh_extension_points_to_default_record(w, prefix, node, suffix, extensions):
  +id = B.length(R.Node, prefix)
  +start = scope(w, prefix, R.Node.with_x(node, 0n), suffix, extensions)
  +end = extended(w, prefix, R.Node.with_x(node, 0n), suffix, extensions)
  Equal.trans(R.NodeExtension, B.extension(E.ext(start, id), id), B.extension(end, id), B.blank_extension(),
    Equal.cong(R.World, R.NodeExtension, state => B.extension(state, id), E.ext(start, id), end, fresh_extension_appends_exactly_once(w, prefix, node, suffix, extensions)),
    extended_default(w, prefix, R.Node.with_x(node, 0n), suffix, extensions))

def repeatIdentity(-w: R.World, -id: Nat, same: {E.ext(w, id) == w : R.World}) ->
  {E.ext(E.ext(w, id), id) == E.ext(w, id) : R.World}:
  Equal.cong(R.World, R.World, state => E.ext(state, id), E.ext(w, id), w, same)

law extension_allocation_is_idempotent:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +head: R.NodeExtension
  for +tail: List<&2, R.NodeExtension>
  {E.ext(E.ext(scope(w, prefix, node, suffix, head <> tail), B.length(R.Node, prefix)), B.length(R.Node, prefix))
    == E.ext(scope(w, prefix, node, suffix, head <> tail), B.length(R.Node, prefix)) : R.World}

def extension_allocation_is_idempotent(w, prefix, node, suffix, head, tail):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      match n_x:
        case 0n:
          fresh_idempotent(w, prefix, R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, head, tail)
        case 1n+p:
          repeatIdentity(scope(w, prefix, R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, head <> tail), B.length(R.Node, prefix),
            existing_extension_is_exact_identity(R.World.with_extensions(w, head <> tail), prefix, R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, p))
