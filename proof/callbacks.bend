# Closed regression through callback statements, real reads, heap and effects.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

# Body returns source+2; the later throw must never execute. An outer operand
# stays live across the call. The application body writes source+3 to a second
# signal without subscribing the effect to that source.
def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createSignal(w, R.Number{0n}, True{})
  w = A.registerProgram(w, A.programReturn(R.Add{R.Read{2n}, R.Literal{R.Number{2n}}},
    A.programThrow(R.Number{99n}, A.emptyProgram())))
  w = A.registerProgram(w, A.programWriteExpr(3n, R.Add{R.Read{2n}, R.Literal{R.Number{3n}}}, A.emptyProgram()))
  w = A.createMemo(512n, w, R.Add{R.Literal{R.Number{5n}}, R.CallProgram{1n}}, True{}, False{}, 1n)
  A.flush(512n, A.createEffectWithHandlers(512n, w, R.Read{4n}, True{}, 0n,
    False{}, False{}, N.defaults(), 1n, 2n, 0n, 0n))

def landed() -> R.World:
  A.flush(512n, A.setSignal(initial(), 2n, R.Number{4n}))

type View is Data:
  View{source: R.Value, output: R.Value, memo: R.Value, effect: R.Value,
    previous: R.Value, deps: Nat, tail: Nat, modified: Bool,
    pending: List<&2, Nat>, users: List<&2, Nat>, context: Nat,
    tracking: Bool, running: Bool, scheduled: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)),
    R.Node.value(B.node(w, 4n)), R.Node.value(B.node(w, 5n)),
    R.Node.prevValue(B.node(w, 5n)), R.Node.deps(B.node(w, 5n)),
    R.Node.depsTail(B.node(w, 5n)), R.Node.modified(B.node(w, 5n)),
    R.World.pendingNodes(w), R.World.userQueue(w), R.World.context(w),
    R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}

def expected() -> View:
  View{R.Number{4n}, R.Number{7n}, R.Number{11n}, R.Number{11n}, R.Number{11n},
    2n, 2n, False{}, [], [], 0n, False{}, False{}, False{}, R.Healthy{}}
