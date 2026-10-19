# Internal read-state fixture; executes core.read / serve and the active helpers.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/api.bend as A
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/read-state.bend as V
import ../../runtime/scheduler.bend as S
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

def slot(+stage: U32) -> R.Slot:
  B.choose(~R.Slot, U32.is_eq(stage, 0), _ => R.Empty{},
    _ => R.Present{B.choose(~R.Value, U32.is_eq(stage, 1), _ => R.Number{23n}, _ => R.Undefined{})})

def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{11n}, True{})
  w = N.computed(0n, w, R.Literal{R.Number{11n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  N.computed(0n, w, R.Literal{R.Undefined{}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)

def fixture(memo: Bool, reader: Bool, tracking: Bool, running: Bool, marked: Bool, stage: U32, forbidden: Bool, promoted: Bool, slow: Bool) -> C.Machine:
  +w = initial()
  +id = B.choose(~Nat, memo, _ => 3n, _ => 2n)
  +n = R.Node.with_value(R.Node.with_flags(R.Node.with_status(B.node(w, id), 0), 0), R.Number{11n})
  +n = R.Node.with_config(n, 0)
  +n = R.Node.with_pending(n, slot(stage))
  +w = B.store_node(w, id, n)
  +w = B.choose(~R.World, promoted, _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.store_node(w, 4n, R.Node.with_config(R.Node.with_flags(B.node(w, 4n), 0), B.choose(~U32, forbidden, _ => 16, _ => 0)))
  +w = R.World.with_minimum(w, 1n)
  +w = R.World.with_context(w, B.choose(~Nat, reader, _ => 4n, _ => 0n))
  +w = R.World.with_tracking(w, tracking)
  +w = R.World.with_running(w, running)
  +w = R.World.with_unflushedStaged(w, marked)
  B.choose(~C.Machine, slow,
    _ => C.serve(w, [], [], id),
    _ => C.run(128n, C.Machine{w, [C.ReadNode{id}], []}))

type Promotion is Data:
  Promotion{before: R.World, after: R.World}

def promotion(running: Bool) -> Promotion:
  +w = R.World.with_running(initial(), running)
  +w = S.queuePendingNode(w, 2n)
  +w = V.notePromotedWrite(w, 2n)
  +w = V.notePromotedWrite(w, 2n)
  Promotion{w, V.resyncUnflushedCompanions(w)}

# Held stash bookkeeping only; this fixture does not create a transaction.
def held(stage: U32, advance: Bool, running: Bool, promoted: Bool) -> B.Bundle<R.World, R.Slot>:
  +w = E.ext(initial(), 2n)
  +w = B.store_node(w, 2n, R.Node.with_config(B.node(w, 2n), K.CONFIG_HELD()))
  +w = B.store_node(w, 2n, R.Node.with_pending(B.node(w, 2n), slot(stage)))
  +w = V.stashFlushed(w, 2n)
  +w = B.store_node(w, 2n, R.Node.with_pending(B.node(w, 2n), R.Present{R.Number{42n}}))
  +w = V.stashFlushed(w, 2n)
  +w = B.choose(~R.World, promoted, _ => V.notePromotedWrite(w, 2n), _ => w)
  +w = R.World.with_clock(w, B.choose(~Nat, advance, _ => 1n, _ => 0n))
  +w = R.World.with_running(w, running)
  V.unflushedValue(w, 2n)

# core.read carries a computed source's CONFIG_VERDICT bit into a memo
# reader's FLAGS after pullComputed; effects do not inherit it.
def carry(config: U32, +kind: U32, tracking: Bool) -> C.Machine:
  +w = initial()
  +w = B.store_node(w, 3n, R.Node.with_value(R.Node.with_config(R.Node.with_flags(R.Node.with_status(B.node(w, 3n), 0), 0), config), R.Number{11n}))
  +w = B.store_node(w, 4n, R.Node.with_kind(R.Node.with_flags(B.node(w, 4n), 0), B.choose(~R.NodeKind, U32.is_eq(kind, 0), _ => R.Memo{}, _ => B.choose(~R.NodeKind, U32.is_eq(kind, 1), _ => R.Render{}, _ => R.User{}))))
  +w = R.World.with_minimum(R.World.with_context(R.World.with_tracking(w, tracking), 4n), 1n)
  C.run(128n, C.Machine{w, [C.ReadNode{3n}], []})
