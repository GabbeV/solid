# Internal read-state fixture; executes core.read / serve and the active helpers.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/api.bend as A
import ../../runtime/core.bend as C
import ../../runtime/read-state.bend as V
import ../../runtime/scheduler.bend as S

def slot(+stage: U32) -> R.Slot:
  B.choose(~R.Slot, U32.is_eq(stage, 0), _ => R.Empty{},
    _ => R.Present{B.choose(~R.Value, U32.is_eq(stage, 1), _ => R.Number{23n}, _ => R.Undefined{})})

def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{11n}, True{})
  w = A.allocate(w, R.Memo{}, R.Literal{R.Number{11n}}, R.Number{11n}, True{}, 1n, 0n, False{})
  A.allocate(w, R.Memo{}, R.Literal{R.Undefined{}}, R.Undefined{}, True{}, 1n, 0n, False{})

def fixture(memo: Bool, reader: Bool, tracking: Bool, running: Bool, marked: Bool, stage: U32, forbidden: Bool, promoted: Bool, slow: Bool) -> C.Machine:
  +w = initial()
  +id = B.choose(~Nat, memo, _ => 3n, _ => 2n)
  +n = R.Node.with_status(B.node(w, id), 0)
  +n = R.Node.with_config(n, 0)
  +n = R.Node.with_pending(n, slot(stage))
  +w = B.store_node(w, id, n)
  +w = B.choose(~R.World, promoted, _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.store_node(w, 4n, R.Node.with_config(B.node(w, 4n), B.choose(~U32, forbidden, _ => 16, _ => 0)))
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
