import Base
import ../runtime/owner.bend as O
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./arena.bend as Lens

# Proof-only loaded normal-frame disposal. Zombie-frame disposal is separate.
def loaded(+w: R.World, +rest: List<&2, O.Task>, +id: Nat, +self: Bool, +disposal: R.Disposal) -> O.Machine:
  +w = B.choose(~R.World, B.noDisposal(disposal), _ => w,
    _ => B.store_node(w, id, R.Node.with_disposal(B.node(w, id), R.NoDisposal{})))
  O.Machine{w, B.append(O.Task, O.disposalTasks(disposal), O.EffectCleanup{id, self} <> rest)}

def loadedEq(+w: R.World, +rest: List<&2, O.Task>, +id: Nat, +self: Bool, +disposal: R.Disposal,
  captured: {R.Node.disposal(B.node(w, id)) == disposal : R.Disposal}) ->
  {O.runDisposal(w, rest, id, self, False{}) == loaded(w, rest, id, self, disposal) : O.Machine}:
  Equal.cong(R.Disposal, O.Machine, saved => loaded(w, rest, id, self, saved), R.Node.disposal(B.node(w, id)), disposal, captured)

def cleared(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_disposal(B.node(w, id), R.NoDisposal{}))

def clearedStore(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>) ->
  {cleared(Lens.arena(w, prefix, node, suffix), B.length(R.Node, prefix))
    == Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix) : R.World}:
  +id = B.length(R.Node, prefix)
  +start = Lens.arena(w, prefix, node, suffix)
  Equal.trans(R.World, cleared(start, id), B.store_node(start, id, R.Node.with_disposal(node, R.NoDisposal{})), Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix),
    Equal.cong(R.Node, R.World, n => B.store_node(start, id, R.Node.with_disposal(n, R.NoDisposal{})), B.node(start, id), node, Lens.peek(w, prefix, node, suffix)),
    Lens.store(w, prefix, node, suffix, R.Node.with_disposal(node, R.NoDisposal{})))

def nonempty(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>, +rest: List<&2, O.Task>, +self: Bool,
  hasCallbacks: {B.noDisposal(R.Node.disposal(node)) == False{} : Bool}) ->
  {O.runDisposal(Lens.arena(w, prefix, node, suffix), rest, B.length(R.Node, prefix), self, False{})
    == O.Machine{Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), B.append(O.Task, O.disposalTasks(R.Node.disposal(node)), O.EffectCleanup{B.length(R.Node, prefix), self} <> rest)} : O.Machine}:
  +id = B.length(R.Node, prefix)
  +start = Lens.arena(w, prefix, node, suffix)
  +disposal = R.Node.disposal(node)
  +ending = B.append(O.Task, O.disposalTasks(disposal), O.EffectCleanup{id, self} <> rest)
  +captured = Equal.cong(R.Node, R.Disposal, n => R.Node.disposal(n), B.node(start, id), node, Lens.peek(w, prefix, node, suffix))
  Equal.trans(O.Machine, O.runDisposal(start, rest, id, self, False{}), loaded(start, rest, id, self, disposal), O.Machine{Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), ending},
    loadedEq(start, rest, id, self, disposal, captured),
    Equal.trans(O.Machine, loaded(start, rest, id, self, disposal), O.Machine{cleared(start, id), ending}, O.Machine{Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), ending},
      Equal.cong(Bool, O.Machine, empty => O.Machine{B.choose(~R.World, empty, _ => start, _ => cleared(start, id)), ending}, B.noDisposal(disposal), False{}, hasCallbacks),
      Equal.cong(R.World, O.Machine, state => O.Machine{state, ending}, cleared(start, id), Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), clearedStore(w, prefix, node, suffix))))

law normal_disposal_detaches_before_callbacks:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +rest: List<&2, O.Task>
  for +self: Bool
  {O.runDisposal(Lens.arena(w, prefix, node, suffix), rest, B.length(R.Node, prefix), self, False{})
    == O.Machine{Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), B.append(O.Task, O.disposalTasks(R.Node.disposal(node)), O.EffectCleanup{B.length(R.Node, prefix), self} <> rest)} : O.Machine}

def normal_disposal_detaches_before_callbacks(w, prefix, node, suffix, rest, self):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      match n_disposal:
        case R.NoDisposal{}:
          +old = {R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, R.NoDisposal{}, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram} : R.Node}
          +start = Lens.arena(w, prefix, old, suffix)
          +id = B.length(R.Node, prefix)
          loadedEq(start, rest, id, self, R.NoDisposal{}, Equal.cong(R.Node, R.Disposal, n => R.Node.disposal(n), B.node(start, id), old, Lens.peek(w, prefix, old, suffix)))
        case R.OneDisposal{callback}:
          nonempty(w, prefix, R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, R.OneDisposal{callback}, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, rest, self, {==})
        case R.ManyDisposals{callbacks}:
          nonempty(w, prefix, R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, R.ManyDisposals{callbacks}, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, suffix, rest, self, {==})

law detached_list_is_not_replayed:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +rest: List<&2, O.Task>
  for +self: Bool
  {O.runDisposal(Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), rest, B.length(R.Node, prefix), self, False{})
    == O.Machine{Lens.arena(w, prefix, R.Node.with_disposal(node, R.NoDisposal{}), suffix), O.EffectCleanup{B.length(R.Node, prefix), self} <> rest} : O.Machine}

def detached_list_is_not_replayed(w, prefix, node, suffix, rest, self):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +old = R.Node.with_disposal(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}, R.NoDisposal{})
      +start = Lens.arena(w, prefix, old, suffix)
      +id = B.length(R.Node, prefix)
      loadedEq(start, rest, id, self, R.NoDisposal{}, Equal.cong(R.Node, R.Disposal, n => R.Node.disposal(n), B.node(start, id), old, Lens.peek(w, prefix, old, suffix)))

law last_registered_cleanup_is_first:
  for +w: R.World
  for +prefix: List<&2, Nat>
  for +callback: Nat
  for +rest: List<&2, O.Task>
  {O.dispatch(w, O.DisposalLoop{B.append(Nat, prefix, [callback]), 1n+B.length(Nat, prefix)} <> rest)
    == O.Machine{w, O.Invoke{callback} <> O.DisposalLoop{B.append(Nat, prefix, [callback]), B.length(Nat, prefix)} <> rest} : O.Machine}

def last_registered_cleanup_is_first(w, prefix, callback, rest):
  Equal.cong(Nat, O.Machine,
    saved => O.Machine{w, O.Invoke{saved} <> O.DisposalLoop{B.append(Nat, prefix, [callback]), B.length(Nat, prefix)} <> rest},
    B.get(Nat, B.append(Nat, prefix, [callback]), B.length(Nat, prefix), 0n), callback,
    Lens.getPrefix(Nat, prefix, callback, [], 0n))
