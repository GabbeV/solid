# Internal-state fixture only. All commit decisions are the active scheduler's.
# Scalars cross the host boundary; no values from another emitted closure enter.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/api.bend as A
import ../../runtime/graph.bend as G
import ../../runtime/scheduler.bend as S

def kind(+k: U32) -> R.NodeKind:
  B.choose(~R.NodeKind, U32.is_eq(k, 0), _ => R.Signal{},
    _ => B.choose(~R.NodeKind, U32.is_eq(k, 1), _ => R.Memo{},
      _ => B.choose(~R.NodeKind, U32.is_eq(k, 2), _ => R.Render{}, _ => R.User{})))

def staging(+stage: U32) -> R.Slot:
  B.choose(~R.Slot, U32.is_eq(stage, 0), _ => R.Empty{},
    _ => R.Present{B.choose(~R.Value, U32.is_eq(stage, 1), _ => R.Number{23n}, _ => R.Undefined{})})

def fixture(+k: U32, config: U32, flags: U32, status: U32, stage: U32, loading: Bool, modified: Bool, sweep: Bool) -> R.World:
  +w = A.allocate(A.createWorld(), kind(k), R.Literal{R.Undefined{}}, R.Number{11n}, True{}, 1n, 0n, False{})
  +w = A.createSignal(w, R.Number{7n}, True{})
  # Computeds have one old dependency, left outside the new pass's prefix.
  +w = B.choose(~R.World, U32.is_ne(k, 0), _ => G.link(w, 3n, 2n), _ => w)
  +n = R.Node.with_depsTail(B.node(w, 2n), 0n)
  +n = R.Node.with_config(n, config)
  +n = R.Node.with_flags(n, flags)
  +n = R.Node.with_status(n, status)
  +n = R.Node.with_loading(n, loading)
  +n = R.Node.with_modified(n, modified)
  +n = R.Node.with_pending(n, staging(stage))
  +w = S.queuePendingNode(B.store_node(w, 2n, n), 2n)
  B.choose(~R.World, sweep, _ => S.commitPendingNodes(w), _ => S.commitPendingNode(w, 2n))
