import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/scheduler.bend as S
import ../../runtime/write.bend as W
import ../../runtime/pending.bend as Q
import ../../runtime/pending-state.bend as P
import ../../runtime/transaction.bend as X
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K

type HeldProbe is Data:
  HeldProbe{world: R.World, result: R.Slot}

def value(code: U32) -> R.Value:
  match code:
    case 0:
      R.Undefined{}
    case 1:
      R.Number{11n}
    case 2:
      R.Number{23n}
    case _:
      R.Number{77n}

def stage(code: U32) -> R.Slot:
  match code:
    case 0:
      R.Empty{}
    case 1:
      R.Present{R.Number{23n}}
    case _:
      R.Present{R.Undefined{}}

def initial(+status: U32, +config: U32, +staging: U32, +reader: U32, +readerConfig: U32, readerStatus: U32, +tracking: Bool, +running: Bool, +joined: Bool, +unflushed: Bool) -> R.World:
  +w = N.createOwner(R.World.with_clock(B.empty(), 5n), 0n, False{})
  +w = N.signal(w, R.Number{11n}, N.defaults())
  +w = N.computed(0n, w, R.Raise{R.Number{99n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.choose(~R.World, U32.is_le(reader, 1), _ => N.computed(0n, w, R.Literal{R.Number{0n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n),
    _ => N.createEffectNode(w, R.Literal{R.Number{0n}}, B.choose(~R.NodeKind, U32.is_eq(reader, 2), _ => R.Render{}, _ => R.User{}), 2n, N.defaults(), 1n, 0n, 0n))
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = X.holdNode(X.holdNode(w, 3n, 1n), 2n, 1n)
  +w = B.store_node(w, 2n, R.Node.with_config(R.Node.with_pending(B.node(w, 2n), stage(staging)), B.set(K.CONFIG_HELD(), config)))
  +w = B.store_node(w, 3n, R.Node.with_flags(R.Node.with_status(R.Node.with_config(R.Node.with_pending(R.Node.with_value(B.node(w, 3n), R.Number{11n}), stage(staging)), B.set(K.CONFIG_HELD(), config)), status), 0))
  +w = B.store_node(w, 4n, R.Node.with_flags(R.Node.with_status(R.Node.with_config(B.node(w, 4n), readerConfig), readerStatus), 0))
  +w = B.choose(~R.World, B.has(readerConfig, K.CONFIG_HELD()), _ => X.holdNode(w, 4n, 1n), _ => w)
  +w = B.choose(~R.World, B.has(status, K.STATUS_ERROR()),
    _ => B.store_extension(w, 3n, R.NodeExtension.with_error(B.extension(w, 3n), R.StatusFailure{2n, 3n, R.Number{99n}})),
    _ => B.choose(~R.World, B.has(status, K.STATUS_PENDING()),
      _ => B.store_extension(w, 3n, R.NodeExtension.with_error(B.extension(w, 3n), R.NotReadyFailure{1n, 3n})), _ => w))
  +w = B.choose(~R.World, B.has(status, K.STATUS_PENDING()), _ => B.first(R.World, Bool, P.addPendingSource(w, 3n, 3n)), _ => w)
  +w = R.World.with_errorSerial(w, 2n)
  +w = R.World.with_minimum(w, 1n)
  +w = R.World.with_running(w, running)
  +w = R.World.with_flushTransaction(w, B.choose(~Nat, joined, _ => 1n, _ => 0n))
  +w = R.World.with_unflushedStaged(w, unflushed)
  R.World.with_tracking(R.World.with_context(w, B.choose(~Nat, U32.is_eq(reader, 0), _ => 0n, _ => 4n)), tracking)

def first(xs: List<&2, R.Value>) -> R.Slot:
  match xs:
    case Nil{}:
      R.Empty{}
    case value <> rest:
      R.Present{value}

def fromMachine(+m: C.Machine) -> HeldProbe:
  HeldProbe{C.world(m), first(C.values(m))}

def apply(+w: R.World, op: U32, +v: R.Value) -> HeldProbe:
  match op:
    case 0:
      fromMachine(C.run(2048n, C.Machine{w, [C.ReadNode{2n}], []}))
    case 1:
      fromMachine(C.run(2048n, C.Machine{w, [C.ReadNode{3n}], []}))
    case 2:
      HeldProbe{W.setSignal(w, 2n, v), R.Present{v}}
    case 3:
      HeldProbe{W.setSignal(w, 3n, v), R.Present{v}}
    case 4:
      HeldProbe{C.world(C.run(2048n, C.Machine{w, [C.Recompute{3n, False{}}], []})), R.Empty{}}
    case 5:
      +tracking = R.World.tracking(w)
      +pair = Q.stageError(w, 3n, R.Number{99n}, tracking)
      HeldProbe{B.first(R.World, Bool, pair), R.Present{R.Boolean{B.second(R.World, Bool, pair)}}}
    case _:
      HeldProbe{S.commitPendingNode(w, 3n), R.Empty{}}

def fixture(op: U32, status: U32, config: U32, staging: U32, reader: U32, readerConfig: U32, readerStatus: U32, tracking: Bool, running: Bool, joined: Bool, unflushed: Bool, v: U32) -> HeldProbe:
  apply(initial(status, config, staging, reader, readerConfig, readerStatus, tracking, running, joined, unflushed), op, value(v))
