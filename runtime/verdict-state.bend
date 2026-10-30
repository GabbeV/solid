# core/verdict.ts bookkeeping shared by active windows, reads and lane seams.
# Window/read continuations live in core.bend; helpers keep source state order.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as Tx
import ./lanes-state.bend as L
import ./write.bend as W
import ./read-state.bend as Read
import ./creator-reads.bend as Creator

def found(+w: R.World) -> R.World:
  R.World.with_verdictState(w, R.VerdictState.with_probeFound(R.World.verdictState(w), True{}))

def watchVerdict(+w: R.World, +reader: Nat, unanswered: Bool) -> R.World:
  +w = B.choose(~R.World, unanswered,
    _ => B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_PROBE_UNANSWERED()))), _ => w)
  +state = R.World.laneState(w)
  R.World.with_laneState(w, R.LaneState.with_stagedReaders(state, B.append(Nat, R.LaneState.stagedReaders(state), [reader])))

def route(+w: R.World, +reader: Nat, +tx: Nat) -> R.World:
  +w = B.choose(~R.World, Bool.and(Nat.is_eq(R.World.passLane(w), 0n), Bool.not(B.has(R.Node.flags(B.node(w, reader)), U32.or(K.REACTIVE_JOINED(), K.REACTIVE_STAGED_READ())))),
    _ =>
      +pair = L.verdictLane(w, tx)
      R.World.with_passLane(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)), _ => w)
  B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_LANE_READ())))

def verdictRead(+w: R.World, +reader: Nat, +tx: Nat, plain: Bool) -> R.World:
  +w = route(w, reader, tx)
  B.choose(~R.World, plain, _ => Tx.staleReader(w, reader, tx),
    _ => B.choose(~R.World, R.VerdictState.probing(R.World.verdictState(w)),
      _ =>
        +reruns = R.Transaction.reruns(B.transaction(w, tx))
        +last = B.get(Nat, reruns, Nat.sub(B.length(Nat, reruns), 1n), 0n)
        B.choose(~R.World, Nat.is_eq(last, reader), _ => w,
          _ => B.store_transaction(w, tx, R.Transaction.with_reruns(B.transaction(w, tx), B.append(Nat, reruns, [reader])))), _ => w))

def provisionalVerdict(+w: R.World,+reader: Nat,+notFinal: Bool) -> R.World:
  B.choose(~R.World,Nat.is_ne(R.World.flushTransaction(w),0n),
    _=>
      +w = B.choose(~R.World,Bool.and(R.VerdictState.probing(R.World.verdictState(w)),notFinal),_=>found(w),_=>w)
      +w = verdictRead(w,reader,R.World.flushTransaction(w),False{})
      B.choose(~R.World,Bool.and(R.VerdictState.probing(R.World.verdictState(w)),B.has(R.Node.flags(B.node(w,reader)),K.REACTIVE_STAGED_READ())),_=>watchVerdict(w,reader,False{}),_=>w),
    _=>watchVerdict(w,reader,Bool.or(Bool.not(R.VerdictState.probing(R.World.verdictState(w))),notFinal)))

def reasks(sources: List<&2, Nat>, +w: R.World) -> Bool:
  match sources:
    case Nil{}:
      True{}
    case source <> +rest:
      B.choose(~Bool, R.NodeExtension.reask(B.extension(w, source)), _ => reasks(rest, w), _ => False{})

def quietSources(+w: R.World, sources: R.SourceSet, id: Nat) -> Bool:
  match sources:
    case R.NoSources{}:
      R.NodeExtension.reask(B.extension(w, id))
    case R.Sources{items}:
      reasks(items, w)

def quietPending(+w: R.World, +id: Nat) -> Bool:
  B.choose(~Bool, Nat.is_eq(R.Node.x(B.node(w, id)), 0n), _ => False{},
    _ => quietSources(w, B.pendingSources(w, id), id))

def pendingVerdict(+w: R.World, +reader: Nat, +id: Nat) -> R.World:
  B.choose(~R.World, B.has(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()), _ => w,
    _ =>
      +w = B.choose(~R.World, Bool.and(R.VerdictState.probing(R.World.verdictState(w)), Bool.not(quietPending(w, id))), _ => found(w), _ => w)
      B.choose(~R.World, Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w)),
        _ => B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
          _ =>
            +pair = Tx.txOf(w, id)
            verdictRead(B.first(R.World, Nat, pair), reader, B.second(R.World, Nat, pair), False{}),
          _ => B.choose(~R.World, R.World.running(w), _ =>
            +w = B.choose(~R.World, R.VerdictState.probing(R.World.verdictState(w)), _ => w, _ => Tx.joinFuture(w, 0n))
            provisionalVerdict(w, reader, False{}), _ => w)), _ => w))

# creatorPass is the Root._parentComputed forwarding getter in base.bend.
# Walk only ancestors whose pass is still computing; retain all born bits.
def bornNext(fuel: Nat,w: R.World,parent: Nat,born: U32) -> B.Bundle<R.World,U32>:
  Creator.next(fuel,w,parent,born)

def bornLoop(fuel: Nat,+w: R.World,parent: Nat,born: U32) -> B.Bundle<R.World,U32>:
  Creator.next(fuel,w,B.parentComputed(w,parent),born)

def markVerdictReader(+w: R.World, window: U32) -> R.World:
  # window 1/2 is observe-only attribution, outside this production profile.
  +reader = B.parentComputed(w,R.World.context(w))
  B.choose(~R.World,Bool.and(Nat.is_ne(reader,0n),R.World.tracking(w)),
    _=>
      +w = B.store_node(w,reader,R.Node.with_config(B.node(w,reader),B.clear(R.Node.config(B.node(w,reader)),K.CONFIG_ASYNC())))
      +pair = Creator.creatorReads(w,reader,0)
      +w = B.first(R.World,U32,pair)
      +born = B.second(R.World,U32,pair)
      +w = B.choose(~R.World,U32.is_eq(born,0),_=>B.store_node(w,reader,R.Node.with_config(B.node(w,reader),B.set(R.Node.config(B.node(w,reader)),K.CONFIG_VERDICT()))),_=>w)
      B.store_node(w,reader,R.Node.with_flags(B.node(w,reader),B.set(R.Node.flags(B.node(w,reader)),U32.or(K.REACTIVE_PROBED(),U32.or(K.REACTIVE_WINDOW(),born))))),_=>w)

def observeAfterBirth(+w: R.World, +reader: Nat, +id: Nat, born: Bool) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, born, _ => B.Bundle{w, False{}},
    _ => B.Bundle{B.choose(~R.World, R.World.running(w),
      _ =>
        +w = Tx.joinFuture(w, 0n)
        +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => w, _ => W.queuePendingNode(w, id))
        verdictRead(w, reader, R.World.flushTransaction(w), True{}), _ => w), True{}})

def observeFlight(+w: R.World, +reader: Nat, +id: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_INPUTS_PUBLISHED()), _ => B.Bundle{w, False{}},
    _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
      _ =>
        +pair = Tx.txOf(w, id)
        +pair = Tx.bornInto(B.first(R.World, Nat, pair), reader, B.second(R.World, Nat, pair))
        observeAfterBirth(B.first(R.World, Bool, pair), reader, id, B.second(R.World, Bool, pair)),
      _ => observeAfterBirth(w, reader, id, False{})))

# staged/heldLatest carry a real throw as the common driver's Fault. The
# caller does not receive an invented value on that exceptional path.
def staged(+w: R.World, +id: Nat) -> B.Bundle<R.World, R.Value>:
  +value = B.selected(R.Node.pending(B.node(w, id)), R.NotPendingToken{})
  B.choose(~B.Bundle<R.World, R.Value>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_STAGED_ERROR()),
    _ => B.Bundle{R.World.with_fault(w, R.CallbackThrown{value}), R.Undefined{}}, _ => B.Bundle{w, value})

def heldLatest(+w: R.World, +id: Nat, +reader: Nat) -> B.Bundle<R.World, R.Value>:
  +pair = Read.unflushedValue(w, id)
  +w = B.first(R.World, R.Slot, pair)
  +u = B.second(R.World, R.Slot, pair)
  B.choose(~B.Bundle<R.World, R.Value>, B.present(u),
    _ => B.Bundle{B.choose(~R.World, Nat.is_ne(reader, 0n), _ => Read.markLateLinker(w, reader), _ => w), B.selected(u, R.Undefined{})},
    _ => staged(w, id))

def witnessMark(+w: R.World) -> R.World:
  B.choose(~R.World, R.VerdictState.probing(R.World.verdictState(w)), _ => found(w), _ => w)

# verdict.ts window finally stores only the globals captured by that window.
def setDispatch(+w: R.World, dispatch: Bool) -> R.World:
  R.World.with_verdictState(w, R.VerdictState.with_dispatch(R.World.verdictState(w), dispatch))

def restoreLatest(+w: R.World, latest: Bool, dispatch: Bool) -> R.World:
  +state = R.VerdictState.with_latestActive(R.World.verdictState(w), latest)
  R.World.with_verdictState(w, R.VerdictState.with_dispatch(state, dispatch))

def restoreProbe(+w: R.World, probing: Bool, found: Bool, dispatch: Bool) -> R.World:
  +state = R.VerdictState.with_probeFound(R.VerdictState.with_probing(R.World.verdictState(w), probing), found)
  R.World.with_verdictState(w, R.VerdictState.with_dispatch(state, dispatch))

# scheduler.ts:openedByLatest (currently no production call site at this pin).
def openedByLatest(+w: R.World) -> R.World:
  R.World.with_verdictState(w,R.VerdictState.with_latestOpened(R.World.verdictState(w),R.World.flushTransaction(w)))
