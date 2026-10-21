import Base
import ./arena.bend as Lens
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/constants.bend as K

# Proof-only loaded form; these two values were read before any stores.
def loaded(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, joined: Bool, +changed: Bool, +isEffect: Bool, +subs: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.choose(~R.World, Bool.and(isEffect, Bool.and(changed, Bool.not(B.present(R.Node.pending(B.node(w, id)))))),
    _ =>
      +w = B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{}))
      B.choose(~R.World, create, _ => w, _ => S.enqueue(w, id)), _ => w)
  +w = B.choose(~R.World, changed,
    _ =>
      +direct = B.choose(~Bool, create, _ => Bool.not(C.bornHeld(w, joined)), _ => Bool.and(isEffect, Bool.not(B.present(R.Node.pending(B.node(w, id))))))
      +w = B.choose(~R.World, direct,
        _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
        _ =>
          +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
          B.choose(~R.World, create,
            _ =>
              +w = X.holdNode(w, id, C.publicationTx(w))
              B.store_node(w, id, R.Node.with_status(B.node(w, id), B.set(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()))), _ => w))
      B.choose(~R.World, Nat.is_ne(subs, 0n), _ => S.insertSubs(w, id), _ => w),
    _ => B.choose(~R.World, Nat.is_ne(R.Node.height(B.node(w, id)), oldHeight),
      _ => H.height_subs(B.budget(w), w, subs), _ => w))
  B.Bundle{w, changed}

def loadedEq(+w: R.World, +id: Nat, +value: R.Value, +create: Bool, +oldHeight: Nat, +joined: Bool, +changed: Bool) ->
  {C.publishValueChanged(w, id, value, create, oldHeight, joined, changed)
    == loaded(w, id, value, create, oldHeight, joined, changed, B.effect(R.Node.kind(B.node(w, id))), R.Node.subs(B.node(w, id))) : B.Bundle<R.World, Bool>}:
  {==}

def staged(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))

def stagedAndNotify(+w: R.World, +id: Nat, value: R.Value, subs: Nat) -> B.Bundle<R.World, Bool>:
  +w = staged(w, id, value)
  B.Bundle{B.choose(~R.World, Nat.is_ne(subs, 0n), _ => S.insertSubs(w, id), _ => w), True{}}

def memo_change(+w: R.World, +id: Nat, +value: R.Value, +oldHeight: Nat, +joined: Bool,
  nonEffect: {B.effect(R.Node.kind(B.node(w, id))) == False{} : Bool}) ->
  {C.publishValueChanged(w, id, value, False{}, oldHeight, joined, True{})
    == stagedAndNotify(w, id, value, R.Node.subs(B.node(w, id))) : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>,
    C.publishValueChanged(w, id, value, False{}, oldHeight, joined, True{}),
    loaded(w, id, value, False{}, oldHeight, joined, True{}, B.effect(R.Node.kind(B.node(w, id))), R.Node.subs(B.node(w, id))),
    stagedAndNotify(w, id, value, R.Node.subs(B.node(w, id))),
    loadedEq(w, id, value, False{}, oldHeight, joined, True{}),
    Equal.cong(Bool, B.Bundle<R.World, Bool>, e => loaded(w, id, value, False{}, oldHeight, joined, True{}, e, R.Node.subs(B.node(w, id))),
      B.effect(R.Node.kind(B.node(w, id))), False{}, nonEffect))

# The exact store, at any existing arena position, preserves every other field.
def stage_store(+w: R.World, +prefix: List<&2, R.Node>, +old: R.Node, +suffix: List<&2, R.Node>, +value: R.Value) ->
  {staged(Lens.arena(w, prefix, old, suffix), B.length(R.Node, prefix), value)
    == Lens.arena(w, prefix, R.Node.with_pending(old, R.Present{value}), suffix) : R.World}:
  +id = B.length(R.Node, prefix)
  +start = Lens.arena(w, prefix, old, suffix)
  Equal.trans(R.World, staged(start, id, value), B.store_node(start, id, R.Node.with_pending(old, R.Present{value})),
    Lens.arena(w, prefix, R.Node.with_pending(old, R.Present{value}), suffix),
    Equal.cong(R.Node, R.World, n => B.store_node(start, id, R.Node.with_pending(n, R.Present{value})), B.node(start, id), old, Lens.peek(w, prefix, old, suffix)),
    Lens.store(w, prefix, old, suffix, R.Node.with_pending(old, R.Present{value})))

def memoShape(node: R.Node) -> R.Node:
  R.Node.with_subs(R.Node.with_kind(node, R.Memo{}), 0n)

law unobserved_memo_stages_without_committing:
  for +w: R.World
  for +prefix: List<&2, R.Node>
  for +node: R.Node
  for +suffix: List<&2, R.Node>
  for +value: R.Value
  for height: Nat
  for joined: Bool
  {C.publishValueChanged(Lens.arena(w, prefix, memoShape(node), suffix), B.length(R.Node, prefix), value, False{}, height, joined, True{})
    == B.Bundle{Lens.arena(w, prefix, R.Node.with_pending(memoShape(node), R.Present{value}), suffix), True{}} : B.Bundle<R.World, Bool>}

def unobserved_memo_stages_without_committing(w, prefix, node, suffix, value, height, joined):
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      +old = memoShape(R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, n_deps, n_depsTail, n_depGen, n_subs, n_subsTail, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram})
      +id = B.length(R.Node, prefix)
      +start = Lens.arena(w, prefix, old, suffix)
      +end = Lens.arena(w, prefix, R.Node.with_pending(old, R.Present{value}), suffix)
      +effectKnown = Equal.cong(R.Node, Bool, n => B.effect(R.Node.kind(n)), B.node(start, id), old, Lens.peek(w, prefix, old, suffix))
      Equal.trans(B.Bundle<R.World, Bool>, C.publishValueChanged(start, id, value, False{}, height, joined, True{}), stagedAndNotify(start, id, value, R.Node.subs(B.node(start, id))), B.Bundle{end, True{}},
        memo_change(start, id, value, height, joined, effectKnown),
        Equal.trans(B.Bundle<R.World, Bool>, stagedAndNotify(start, id, value, R.Node.subs(B.node(start, id))), B.Bundle{staged(start, id, value), True{}}, B.Bundle{end, True{}},
          Equal.cong(R.Node, B.Bundle<R.World, Bool>, n => stagedAndNotify(start, id, value, R.Node.subs(n)), B.node(start, id), old, Lens.peek(w, prefix, old, suffix)),
          Equal.cong(R.World, B.Bundle<R.World, Bool>, state => B.Bundle{state, True{}}, staged(start, id, value), end, stage_store(w, prefix, old, suffix, value))))
