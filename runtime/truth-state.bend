# core/truth.ts:laneValueOf, apart from the active lane engine like the source.
import Base
import ./heap.bend as H
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def laneValueOf(+w: R.World, +id: Nat) -> R.Value:
  +n = B.node(w, id)
  B.choose(~R.Value, Bool.and(Bool.not(B.has(R.Node.config(n), K.CONFIG_GUESS())), B.present(R.Node.pending(n))),
    _ => B.selected(R.Node.pending(n), R.Undefined{}),
    _ => B.selected(R.NodeExtension.lane(B.extension(w, id)), B.choose(~R.Value, B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()), _ => R.NotPendingToken{}, _ => R.Node.value(n))))

# truth.ts:truthConfirmed. The source walks live lane members/subscriber links
# and enqueues authoritative readers only; it invokes no user callback.
def confirmedSubs(fuel: Nat, +w: R.World, +edge: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +reader = R.Link.sub(B.link(w, edge))
          +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, reader)), K.CONFIG_AUTHORITATIVE()), _ => H.enqueueSub(w, reader), _ => w)
          confirmedSubs(p, w, R.Link.nextSub(B.link(w, edge))))

def confirmedNodes(fuel: Nat, +w: R.World, +lane: Nat, +index: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), _ => w,
        _ =>
          +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, lane)), index, 0n)
          +w = confirmedSubs(1n+B.length(R.Link, R.World.links(w)), w, R.Node.subs(B.node(w, id)))
          B.choose(~R.World, B.ok(w), _ => confirmedNodes(p, w, lane, 1n+index), _ => w))

def truthConfirmed(+w: R.World, +lane: Nat) -> R.World:
  confirmedNodes(1n+B.length(Nat, R.Transaction.nodes(B.transaction(w, lane))), w, lane, 0n)
