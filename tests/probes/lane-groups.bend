import Base
import ../../representation/base.bend as B
import ../../representation/records.bend as R
import ../../proof/lane-group-laws.bend as G
import ../../runtime/lanes-state.bend as L

def peerRecords(count: Nat, +id: Nat, +items: List<&2, Nat>) -> List<&2, R.Transaction>:
  match count:
    case 0n:
      [B.blank_transaction()]
    case 1n+p:
      R.Transaction.with_parent(R.Transaction.with_links(R.Transaction.with_lane(B.blank_transaction(), True{}), B.choose(~Nat, B.contains(items, id), _ => 1n, _ => 0n)), 16n) <> peerRecords(p, 1n+id, items)

def base() -> R.World:
  R.World.with_transactions(B.empty(), [16n])

def fixture(+prefix: List<&2, Nat>, +suffix: List<&2, Nat>, +present: Bool) -> B.Bundle<R.World, R.World>:
  +items = B.choose(~List<&2, Nat>, present, _ => G.before(prefix, suffix), _ => G.peers(prefix))
  +next = B.choose(~List<&2, Nat>, present, _ => G.after(prefix, suffix), _ => items)
  +tx = R.Transaction.with_parent(B.blank_transaction(), 16n)
  +rest = peerRecords(14n, 2n, items)
  +groups = {[[3n, 2n], [4n]] : List<&2, List<&2, Nat>>}
  B.Bundle{L.unlink(G.frame(base(), tx, rest, groups, 1n, items), 1n), G.frame(base(), tx, rest, groups, 0n, next)}

def linked(+group: Nat) -> B.Bundle<R.World, R.World>:
  +tx = R.Transaction.with_parent(R.Transaction.with_lane(B.blank_transaction(), True{}), 16n)
  +w = R.World.with_laneState(base(), R.LaneState{[], [[], [1n, 2n], [2n, 1n], [1n, 2n]], [], [], 0n, R.MountUnset{}, []})
  +start = G.linkedFrame(w, tx, tx, peerRecords(13n, 3n, [1n, 2n]), group)
  B.Bundle{L.linkLanes(start, 1n, 2n), start}

def self(+groups: List<&2, List<&2, Nat>>) -> B.Bundle<R.World, R.World>:
  +tx = R.Transaction.with_parent(R.Transaction.with_lane(B.blank_transaction(), True{}), 16n)
  +rest = peerRecords(14n, 2n, [])
  B.Bundle{L.linkLanes(G.selfFrame(base(), tx, rest, groups), 1n, 1n), G.selfAllocated(base(), tx, rest, groups)}
