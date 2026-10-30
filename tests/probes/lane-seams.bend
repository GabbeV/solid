import Base
import ./lane-lifecycle.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/lanes-state.bend as L
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as Tx
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{base: Seed.Spec, leaks: U32, fresh: Bool, readerLane: Nat, readerFlags: U32, readerConfig: U32, parentOpen: Nat, verdict: Bool, entered: U32}

def leaks(mode: U32) -> R.OptionalIds:
  match mode:
    case 0: R.NoIds{}
    case 1: R.SomeIds{[]}
    case 2: R.SomeIds{[2n]}
    case 3: R.SomeIds{[3n]}
    case 4: R.SomeIds{[4n]}
    case 5: R.SomeIds{[2n, 3n]}
    case 6: R.SomeIds{[3n, 3n]}
    case _: R.SomeIds{[2n, 3n, 4n, 5n]}

def enteredReaders(mode: U32) -> List<&2, Nat>:
  match mode:
    case 0: []
    case 1: [3n]
    case 2: [3n, 4n]
    case 3: [3n, 3n]
    case _: [4n, 3n]

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{base, mode, +fresh, +readerLane, +readerFlags, +readerConfig, +parentOpen, +verdict, +entered}:
      +w = Seed.initial(base)
      +w = C.world(C.applyGuessesAt(w, [], [], 0n))
      +w = B.choose(~R.World, fresh, _ => B.first(R.World, Nat, L.newLane(w, 1n)), _ => w)
      +w = B.choose(~R.World, Nat.is_ne(readerLane, 0n), _ => Tx.list(w, 3n, readerLane), _ => w)
      +w = B.store_node(w, 3n, R.Node.with_kind(R.Node.with_config(R.Node.with_flags(B.node(w, 3n), readerFlags), readerConfig), R.Render{}))
      +w = R.World.with_laneState(w, R.LaneState.with_entered(R.World.laneState(w), enteredReaders(entered)))
      +w = B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), parentOpen))
      B.choose(~R.World, verdict, _ => B.store_transaction(w, 1n, R.Transaction.with_verdict(B.transaction(w, 1n), readerLane)), _ => w)

def staged(+w: R.World,rows: R.OptionalIds) -> R.World:
  match rows:
    case R.NoIds{}: R.World.with_laneState(w,R.LaneState.with_stagedReaders(R.World.laneState(w),[]))
    case R.SomeIds{readers}: R.World.with_laneState(w,R.LaneState.with_stagedReaders(R.World.laneState(w),readers))

def execute(spec: Spec, w: R.World) -> C.Machine:
  match spec:
    case Spec{base, +mode, fresh, readerLane, readerFlags, readerConfig, parentOpen, verdict, entered}:
      C.run(8192n,C.laneSeams(staged(w,leaks(mode)),[],[R.Number{71n}],B.choose(~Nat,U32.is_eq(mode,0),_=>0n,_=>1n)))

def fixture(+spec: Spec) -> C.Machine:
  execute(spec, initial(spec))
