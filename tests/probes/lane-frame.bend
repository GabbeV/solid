import Base
import ./lane-read.bend as Seed
import ../../runtime/core.bend as C
import ../../runtime/transaction.bend as Tx
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K
import ../../representation/records.bend as R
import ../../representation/base.bend as B

type Spec is Data:
  Spec{op: U32, kind: U32, flags: U32, ownerKind: U32, ownerConfig: U32, ownerTx: Nat, nested: Bool, rootOwner: Bool}

def initial(spec: Spec) -> R.World:
  match spec:
    case Spec{op, +kind, flags, ownerKind, ownerConfig, +ownerTx, +nested, rootOwner}:
      +w = Seed.seed()
      +w = B.store_node(w, 2n, R.Node.with_parent(R.Node.with_expr(R.Node.with_equals(R.Node.with_kind(R.Node.with_config(R.Node.with_flags(B.node(w, 2n), flags), 0), Seed.kind(kind)), U32.is_eq(kind, 1)), R.Literal{R.Number{9n}}), 3n))
      +w = B.store_extension(w, 2n, R.NodeExtension.with_transaction(B.extension(w, 2n), 0n))
      +w = B.store_transaction(w, 2n, R.Transaction.with_nodes(B.transaction(w, 2n), []))
      +nearest = B.choose(~Nat, nested, _ => 4n, _ => 3n)
      +w = B.store_node(w, 3n, R.Node.with_parent(R.Node.with_flags(B.node(w, 3n), B.choose(~U32, nested, _ => K.REACTIVE_ZOMBIE(), _ => 0)), B.choose(~Nat, nested, _ => 4n, _ => 1n)))
      +w = B.store_node(w, nearest, R.Node.with_kind(R.Node.with_config(B.node(w, nearest), ownerConfig), B.choose(~R.NodeKind, rootOwner, _ => R.Root{}, _ => Seed.kind(ownerKind))))
      +w = E.ext(w, nearest)
      +w = B.store_extension(w, nearest, R.NodeExtension.with_transaction(B.extension(w, nearest), ownerTx))
      R.World.with_syncDepth(w, 1n)

def dropLoop(tasks: List<&2, C.Task>) -> List<&2, C.Task>:
  match tasks:
    case Nil{}: []
    case C.HeapLoop{} <> tail: dropLoop(tail)
    case head <> tail: head <> dropLoop(tail)

def finish(m: C.Machine) -> C.Machine:
  match m:
    case C.Machine{w, tasks, stack}:
      C.run(8192n, C.Machine{w, dropLoop(tasks), stack})

def fixture(+spec: Spec) -> B.Bundle<R.World, Bool>:
  match spec:
    case Spec{op, kind, flags, ownerKind, ownerConfig, ownerTx, nested, rootOwner}:
      +w = initial(spec)
      B.choose(~B.Bundle<R.World, Bool>, U32.is_eq(op, 0),
        _ => C.laneFrameMember(w, 2n),
        _ =>
          +m = C.visitHeap(w, [], [], 2n)
          +m = finish(m)
          B.Bundle{C.world(m), False{}})
