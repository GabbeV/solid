# Proof-only algebraic form of core.readSignalFast. Its sole extra parameter
# names the source strict-equality result. The generated step50 equation connects
# it to actual core.step; no API read is replaced by this proof-only cut.
import Base
import ../runtime/core.bend as C
import ../runtime/graph.bend as G
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../representation/base.bend as B
import ../representation/records.bend as R

def read(+w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, +id: Nat, +netted: Bool) -> C.Machine:
  +reader = B.parentComputed(w, R.World.context(w))
  +tracked = Bool.and(Nat.is_ne(reader, 0n), R.World.tracking(w))
  +w = B.choose(~R.World, tracked, _ => G.link(w, id, reader), _ => w)
  +pair = X.enterRead(w, reader, id, False{})
  +w = B.first(R.World, Bool, pair)
  +n = B.node(w, id)
  +committed = Bool.or(B.second(R.World, Bool, pair), Bool.or(Nat.is_eq(reader, 0n), Bool.or(Bool.not(B.present(R.Node.pending(n))),
    B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN()))))
  +committed = Bool.or(committed, netted)
  +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.not(committed), B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT())), _ => X.stagedScreenFor(w, reader, id), _ => B.Bundle{w, False{}})
  +w = B.first(R.World, Bool, pair)
  +committed = Bool.or(committed, B.second(R.World, Bool, pair))
  +value = B.choose(~R.Value, committed, _ => R.Node.value(n), _ => B.current(n))
  +w = B.choose(~R.World, committed, _ => w, _ => C.stagedRead(w, reader, 0n))
  C.served(w, rest, stack, reader, id, value)

# Retain the actual World/work/tail when transporting the read's value equation.
def replaceHead(machine: C.Machine,+value: R.Value) -> C.Machine:
  match machine:
    case C.Machine{w,tasks,stack}:
      match stack:
        case Nil{}: C.Machine{w,tasks,[]}
        case first <> tail: C.Machine{w,tasks,value <> tail}
