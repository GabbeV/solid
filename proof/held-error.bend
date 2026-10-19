# Negative regression: the pinned source's successful-value-as-error behavior.
# This is preserved baseline evidence, not the desired recovery guarantee.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/constants.bend as K

def initial() -> R.World:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createSignal(w, R.Boolean{False{}}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.createMemoWithOptions(1024n, w, R.Select{R.Read{2n}, R.Literal{R.AsyncValue{1n}}, R.Literal{R.Number{1n}}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(1024n, w, R.Select{R.Same{R.Read{3n}, R.Literal{R.Number{1n}}}, R.Raise{R.Number{99n}}, R.Literal{R.Number{1n}}}, N.defaults(), 1n)
  w = A.createMemoWithOptions(1024n, w, R.Add{R.Read{4n}, R.Read{5n}}, N.defaults(), 1n)
  w = A.attach(w, 1n, 2n)
  A.flush(1024n, A.createEffect(1024n, w, R.Read{6n}, False{}, 2n, False{}, False{}, 1n))

def stagedFailure() -> R.World:
  w = A.setSignal(initial(), 2n, R.Boolean{True{}})
  A.flush(1024n, A.setSignal(w, 3n, R.Number{1n}))

def recoveredBeforeLanding() -> R.World:
  A.flush(1024n, A.setSignal(stagedFailure(), 3n, R.Number{0n}))

def delivered() -> R.World:
  A.resolveThenable(2048n, recoveredBeforeLanding(), 1n, False{}, R.Number{2n})

def userCause(value: R.Value) -> R.Value:
  match value:
    case R.StatusFailure{identity, source, cause, message}:
      cause
    case other:
      other

def faultCause(fault: R.Fault) -> R.Value:
  match fault:
    case R.CallbackThrown{value}:
      userCause(value)
    case _:
      R.Undefined{}

type View is Data:
  View{recoveredValue: R.Value, proposal: R.Slot, staleErrorBit: Bool,
    consumerStatus: U32, consumerError: R.Value, escaped: R.Value,
    text: R.Value, halted: Bool, healthy: Bool, context: Nat, tracking: Bool,
    running: Bool}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 5n)), R.Node.pending(B.node(w, 5n)), B.has(R.Node.config(B.node(w, 5n)), K.CONFIG_STAGED_ERROR()),
    R.Node.status(B.node(w, 6n)), userCause(R.NodeExtension.error(B.extension(w, 6n))), faultCause(R.World.fault(w)),
    A.displayed(w, 2n), R.World.halted(w), B.ok(w), R.World.context(w), R.World.tracking(w), R.World.running(w)}

def expectedCounterexample() -> View:
  View{R.Number{1n}, R.Present{R.Number{1n}}, True{}, K.STATUS_ERROR(), R.Number{1n}, R.Number{1n}, R.Number{2n}, True{}, False{}, 0n, False{}, False{}}
