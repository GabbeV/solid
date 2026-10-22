import Base
import ./lane-core-read.bend as Read
import ../../runtime/core.bend as C
import ../../runtime/transaction.bend as Tx
import ../../runtime/extension.bend as E
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{base: Read.Spec, probing: Bool, found: Bool, running: Bool, targetTx: Nat, verdict: Nat, error: U32, mark: Nat, active: Nat, targetFlags: U32}

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{base, probing, found, running, +targetTx, verdict, error, +mark, active, targetFlags}:
      +w = Read.initial(base)
      +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), targetFlags))
      +w = B.choose(~R.World, Nat.is_eq(targetTx, 0n), _ => B.store_extension(w, 2n, R.NodeExtension.with_transaction(B.extension(w, 2n), 0n)), _ => Tx.list(w, 2n, targetTx))
      +w = B.store_transaction(w, 1n, R.Transaction.with_verdict(B.transaction(w, 1n), verdict))
      +w = B.store_extension(w, 2n, R.NodeExtension.with_error(B.extension(w, 2n), Read.value(error)))
      +w = B.choose(~R.World, Nat.is_ne(mark, 0n),
        _ =>
          +w = E.ext(w, mark)
          B.store_extension(w, mark, R.NodeExtension.with_marks(B.extension(w, mark), 1n)), _ => w)
      +state = R.World.verdictState(w)
      +w = R.World.with_verdictState(w, R.VerdictState.with_dispatch(R.VerdictState.with_probeFound(R.VerdictState.with_probing(state, probing), found), True{}))
      R.World.with_activeMarks(R.World.with_running(w, running), active)

def fixture(spec: Spec) -> C.Machine:
  +w = initial(spec)
  C.run(16384n, C.verdictValue(w, [], [R.Number{71n}], 2n, B.parentComputed(w, R.World.context(w))))

type Entry is Data:
  Entry{found: Bool, dispatch: Bool}

def isBody(w: R.World, task: C.Task) -> Bool:
  match task:
    case C.Evaluate{expr, prev}:
      Nat.is_eq(R.World.context(w), 2n)
    case _:
      False{}

def entryLoop(fuel: Nat, m: C.Machine) -> Entry:
  match fuel m:
    case 0n _:
      Entry{False{}, False{}}
    case 1n+ +p C.Machine{+w, tasks, +values}:
      match tasks:
        case Nil{}:
          Entry{False{}, False{}}
        case +head <> +tail:
          B.choose(~Entry, isBody(w, head),
            _ => Entry{True{}, R.VerdictState.dispatch(R.World.verdictState(w))},
            _ => entryLoop(p, C.step(C.Machine{w, head <> tail, values})))

def entry(spec: Spec) -> Entry:
  +w = initial(spec)
  entryLoop(16384n, C.verdictValue(w, [], [R.Number{71n}], 2n, B.parentComputed(w, R.World.context(w))))
