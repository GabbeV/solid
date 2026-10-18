# Internal-state fixture only. All commit decisions are the active scheduler's.
# Scalars cross the host boundary; no values from another emitted closure enter.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/api.bend as A
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/graph.bend as G
import ../../runtime/scheduler.bend as S

def kind(+k: U32) -> R.NodeKind:
  B.choose(~R.NodeKind, U32.is_eq(k, 0), _ => R.Signal{},
    _ => B.choose(~R.NodeKind, U32.is_eq(k, 1), _ => R.Memo{},
      _ => B.choose(~R.NodeKind, U32.is_eq(k, 2), _ => R.Render{}, _ => R.User{})))

def staging(+stage: U32) -> R.Slot:
  B.choose(~R.Slot, U32.is_eq(stage, 0), _ => R.Empty{},
    _ => R.Present{B.choose(~R.Value, U32.is_eq(stage, 1), _ => R.Number{23n}, _ => R.Undefined{})})

def seed(+k: U32, config: U32, flags: U32, status: U32, stage: U32, loading: Bool, modified: Bool, sweep: Bool) -> R.World:
  +w = A.createWorld()
  +w = B.choose(~R.World, U32.is_eq(k, 0), _ => N.signal(w, R.Number{11n}, N.defaults()),
    _ => B.choose(~R.World, U32.is_eq(k, 1),
      _ => N.computed(0n, w, R.Literal{R.Undefined{}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n),
      _ => N.createEffectNode(w, R.Literal{R.Undefined{}}, kind(k), 0n, N.defaults(), 1n)))
  +w = A.createSignal(w, R.Number{7n}, True{})
  # Computeds have one old dependency, left outside the new pass's prefix.
  +w = B.choose(~R.World, U32.is_ne(k, 0), _ => G.link(w, 3n, 2n), _ => w)
  +n = R.Node.with_value(R.Node.with_depsTail(B.node(w, 2n), 0n), R.Number{11n})
  +n = R.Node.with_config(n, config)
  +n = R.Node.with_flags(n, flags)
  +n = R.Node.with_status(n, status)
  +n = R.Node.with_loading(n, loading)
  +n = R.Node.with_modified(n, modified)
  +n = R.Node.with_pending(n, staging(stage))
  +w = S.queuePendingNode(B.store_node(w, 2n, n), 2n)
  w

def fixture(k: U32, config: U32, flags: U32, status: U32, stage: U32, loading: Bool, modified: Bool, +sweep: Bool) -> R.World:
  +w = seed(k, config, flags, status, stage, loading, modified, sweep)
  B.choose(~R.World, sweep, _ => S.commitPendingNodes(w), _ => S.commitPendingNode(w, 2n))

def metadata(+mode: U32, +x: R.NodeExtension) -> R.NodeExtension:
  +x = B.choose(~R.NodeExtension, U32.is_eq(mode, 2), _ => R.NodeExtension.with_error(x, R.Null{}), _ => x)
  +x = B.choose(~R.NodeExtension, U32.is_eq(mode, 3), _ => R.NodeExtension.with_error(x, R.Boolean{False{}}), _ => x)
  +x = B.choose(~R.NodeExtension, U32.is_eq(mode, 4), _ => R.NodeExtension.with_error(x, R.Number{23n}), _ => x)
  +x = B.choose(~R.NodeExtension, U32.is_eq(mode, 6), _ => R.NodeExtension.with_pendingFirstChild(x, 3n), _ => x)
  B.choose(~R.NodeExtension, U32.is_eq(mode, 5),
    _ => R.NodeExtension.with_shownError(R.NodeExtension.with_flushedAt(R.NodeExtension.with_flushed(R.NodeExtension.with_reask(x, True{}), R.Present{R.Number{19n}}), R.Stamped{0n}), R.Number{29n}),
    _ => x)

def withExtension(k: U32, config: U32, flags: U32, status: U32, stage: U32, loading: Bool, modified: Bool, +sweep: Bool, mode: U32) -> R.World:
  +w = E.ext(seed(k, config, flags, status, stage, loading, modified, sweep), 2n)
  +w = B.store_extension(w, 2n, metadata(mode, B.extension(w, 2n)))
  B.choose(~R.World, sweep, _ => S.commitPendingNodes(w), _ => S.commitPendingNode(w, 2n))
