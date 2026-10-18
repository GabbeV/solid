# Mechanical tree only. Root identity is 1. Rendering writes text; neither
# attachment nor value selection consults reactivity or publication rules.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def get(+w: R.World, id: Nat) -> R.TreeNode:
  B.get(R.TreeNode, R.World.tree(w), id, B.blank_tree())

def store(+w: R.World, id: Nat, n: R.TreeNode) -> R.World:
  R.World.with_tree(w, B.put(R.TreeNode, R.World.tree(w), id, B.blank_tree(), n))

def setText(+w: R.World, +id: Nat, value: R.Value) -> R.World:
  store(w, id, R.TreeNode.with_text(get(w, id), value))

def remove_id(xs: List<&2, Nat>, +id: Nat) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      []
    case +h <> +t:
      B.choose(~List<&2, Nat>, Nat.is_eq(h, id), _ => remove_id(t, id), _ => h <> remove_id(t, id))

def detach(+w: R.World, +id: Nat) -> R.World:
  +parent = R.TreeNode.parent(get(w, id))
  +w = B.choose(~R.World, Nat.is_eq(parent, 0n), _ => w,
    _ => store(w, parent, R.TreeNode.with_children(get(w, parent), remove_id(R.TreeNode.children(get(w, parent)), id))))
  store(w, id, R.TreeNode.with_parent(get(w, id), 0n))

def attach(+w: R.World, +parent: Nat, +id: Nat) -> R.World:
  +w = detach(w, id)
  +w = store(w, id, R.TreeNode.with_parent(get(w, id), parent))
  store(w, parent, R.TreeNode.with_children(get(w, parent), B.append(Nat, R.TreeNode.children(get(w, parent)), [id])))

def visible(fuel: Nat, +w: R.World, +id: Nat) -> Bool:
  match fuel:
    case 0n:
      False{}
    case 1n+p:
      B.choose(~Bool, Nat.is_eq(id, 1n), _ => True{},
        _ => B.choose(~Bool, Nat.is_eq(id, 0n), _ => False{}, _ => visible(p, w, R.TreeNode.parent(get(w, id)))))

def text(+w: R.World, id: Nat) -> R.Value:
  R.TreeNode.text(get(w, id))
