import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as Tx
import ../../runtime/lanes-state.bend as L
import ../../runtime/verdict-state.bend as V

type Spec is Data:
  Spec{op: U32, context: Nat, tracking: Bool, running: Bool, flush: Nat, pass: Nat, probing: Bool, probeFound: Bool, readerFlags: U32, sourceConfig: U32, sourceStatus: U32, readerConfig: U32, readerStatus: U32, readerTx: Nat, sourceTx: Nat, sources: U32, reasks: U32, notFinal: Bool, plain: Bool, sequence: U32, latest: Bool}

def sourceSet(mode: U32) -> R.SourceSet:
  match mode:
    case 1:
      R.Sources{[]}
    case 2:
      R.Sources{[2n]}
    case 3:
      R.Sources{[4n]}
    case 4:
      R.Sources{[2n, 4n]}
    case 5:
      R.Sources{[5n]}
    case _:
      R.NoSources{}

def seed() -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +opts = R.NodeOptions.with_lazy(N.defaults(), True{})
  +w = N.computed(0n, w, R.Literal{R.Number{2n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{3n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{4n}}, opts, 1n)
  +w = N.computed(0n, w, R.Literal{R.Number{5n}}, opts, 1n)
  +w = B.store_node(w, 5n, R.Node.with_kind(B.node(w, 5n), R.Render{}))
  +w = N.createOwner(w, 3n, False{})
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, Tx.newTransaction(w, False{}, 0n))
  B.first(R.World, Nat, L.newLane(w, 1n))

def fixture(spec: Spec) -> B.Bundle<R.World, Bool>:
  match spec:
    case Spec{+op, context, tracking, running, flush, pass, probing, probeFound, readerFlags, sourceConfig, sourceStatus, readerConfig, readerStatus, +readerTx, +sourceTx, +sources, +reasks, +notFinal, +plain, +sequence, latest}:
      +w = seed()
      +w = B.store_node(w, 2n, R.Node.with_status(R.Node.with_config(R.Node.with_flags(B.node(w, 2n), 0), sourceConfig), sourceStatus))
      +w = B.store_node(w, 3n, R.Node.with_status(R.Node.with_config(R.Node.with_flags(B.node(w, 3n), readerFlags), readerConfig), readerStatus))
      +w = B.choose(~R.World, U32.is_eq(sources, 6), _ => w,
        _ =>
          +w = E.ext(w, 2n)
          +w = B.store_extension(w, 2n, R.NodeExtension.with_reask(B.extension(w, 2n), B.has(reasks, 1)))
          B.setPendingSources(w, 2n, sourceSet(sources)))
      +w = E.ext(w, 4n)
      +w = B.store_extension(w, 4n, R.NodeExtension.with_reask(B.extension(w, 4n), B.has(reasks, 2)))
      +w = B.choose(~R.World, Nat.is_eq(sourceTx, 0n), _ => w, _ => Tx.list(w, 2n, sourceTx))
      +w = B.choose(~R.World, Nat.is_eq(readerTx, 0n), _ => w, _ => Tx.list(w, 3n, readerTx))
      +w = R.World.with_syncDepth(w, 1n)
      +w = R.World.with_context(w, context)
      +w = R.World.with_tracking(w, tracking)
      +w = R.World.with_running(w, running)
      +w = R.World.with_flushTransaction(w, flush)
      +w = R.World.with_passLane(w, pass)
      +w = R.World.with_verdictState(w, R.VerdictState{latest, probing, probeFound, False{}, 0n})
      B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 0), _ => B.Bundle{w, V.quietPending(w, 2n)},
        _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 1), _ => B.Bundle{V.markVerdictReader(w, 1), False{}},
          _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 2), _ => B.Bundle{V.watchVerdict(w, 3n, notFinal), False{}},
            _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 3), _ => B.Bundle{V.route(w, 3n, 1n), False{}},
              _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 4),
                _ =>
                  +w = V.verdictRead(w, 3n, 1n, plain)
                  +w = B.choose(~R.World, U32.is_eq(sequence, 2), _ => V.verdictRead(w, 4n, 1n, plain), _ => w)
                  +w = B.choose(~R.World, U32.is_eq(sequence, 0), _ => w, _ => V.verdictRead(w, 3n, 1n, plain))
                  B.Bundle{w, False{}},
                _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 5), _ => B.Bundle{V.provisionalVerdict(w, 3n, notFinal), False{}},
                  _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 6), _ => B.Bundle{V.pendingVerdict(w, B.choose(~Nat, U32.is_eq(sequence, 1), _ => 0n, _ => 3n), 2n), False{}},
                    _ => B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 7), _ => V.observeFlight(w, 3n, 2n),
                      _ => B.Bundle{V.witnessMark(w), False{}}))))))))

def heldLatest(config: U32, running: Bool, +reader: Nat, pending: R.Slot, flushed: R.Slot, stamp: Nat) -> B.Bundle<R.World, R.Value>:
  +w = N.signal(B.empty(), R.Number{7n}, N.defaults())
  +w = N.computed(0n, w, R.Literal{R.Number{2n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), 0))
  +w = E.ext(w, 1n)
  +w = B.store_node(w, 1n, R.Node.with_pending(R.Node.with_config(B.node(w, 1n), config), pending))
  +w = B.store_extension(w, 1n, R.NodeExtension.with_flushedAt(R.NodeExtension.with_flushed(B.extension(w, 1n), flushed), R.Stamped{stamp}))
  +w = R.World.with_clock(w, 9n)
  V.heldLatest(R.World.with_running(w, running), 1n, reader)
