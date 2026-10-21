# Three closed programs through the actual array/constructor/setter/flush/read/
# owner machinery. These are concrete regressions, not a general map theorem.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/arrays.bend as Arrays
import ../runtime/keyed-map.bend as KM
import ../runtime/ambient.bend as Ambient
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./context.bend as Existing

type Prepared is Data:
  Prepared{world: R.World, beforeRows: R.Value, accessor: R.Value, beforeFlush: List<&2, R.Value>}

type View is Data:
  View{items: List<&2, R.Value>, indexes: List<&2, R.Value>, beforeFlush: List<&2, R.Value>, retained: Bool, deadRows: Bool, deadMap: Bool, cleanups: List<&2, R.TraceEvent>, context: Nat, tracking: Bool, running: Bool, fault: R.Fault}

def pairExpression() -> R.Expr:
  R.ArrayLiteral{R.CallArgumentsItem{R.Argument{0n}, R.CallArgumentsItem{R.Argument{1n}, R.CallArgumentsEnd{}}}}

def mode(+input: Nat) -> R.Value:
  match input:
    case 0n:
      R.Boolean{True{}}
    case 1n:
      R.Boolean{False{}}
    case other:
      R.ProgramReference{1n}

def valueAt(+w: R.World, +value: R.Value, +index: Nat) -> R.Value:
  match value:
    case R.ArrayReference{id}:
      Arrays.at(w, id, index)
    case other:
      R.Undefined{}

def values(+w: R.World, +value: R.Value) -> List<&2, R.Value>:
  match value:
    case R.ArrayReference{id}:
      B.mapWith(R.Slot, R.Value, R.Value, selected => slot => B.selected(slot, selected), R.Undefined{}, Arrays.get(w, id))
    case other:
      [other]

def prepare(+input: Nat) -> Prepared:
  +pair = Arrays.allocate(A.createWorld(), Arrays.slots([R.Number{1n}, R.Number{2n}]))
  +w = A.createSignal(B.first(R.World, Nat, pair), R.ArrayReference{B.second(R.World, Nat, pair)}, True{})
  +w = A.registerProgram(w, A.programArity(A.programReturn(R.Argument{0n}, A.emptyProgram()), 1n))
  +w = A.registerProgram(w, A.programEmit(9n, A.emptyProgram()))
  +body = {R.Then{R.OnCleanup{R.Literal{R.ProgramReference{2n}}}, pairExpression()} : R.Expr}
  +w = A.registerProgram(w, A.programArity(A.programReturn(body, A.emptyProgram()), 2n))
  +created = A.evaluateExpression(1024n, w, R.WithOwner{R.Literal{R.OwnerReference{1n}}, A.mapArrayInput(R.Read{2n}, R.Literal{R.ProgramReference{3n}}, R.NoInlineBody{}, R.Literal{mode(input)})}, R.Undefined{})
  +get = A.resultValue(created)
  +initial = A.evaluateExpression(512n, A.resultWorld(created), A.invoke(R.Literal{get}), R.Undefined{})
  +pair = Arrays.allocate(A.resultWorld(initial), Arrays.slots([R.Number{2n}, R.Number{1n}, R.Number{3n}]))
  +w = A.setSignal(B.first(R.World, Nat, pair), 2n, R.ArrayReference{B.second(R.World, Nat, pair)})
  +old = A.read(512n, w, 2n)
  Prepared{A.flush(2048n, A.resultWorld(old)), A.resultValue(initial), get, values(A.resultWorld(old), A.resultValue(old))}

# Interpret the admitted public mapper shape: raw items/index numbers, or actual
# bound item/index accessors. Callable fields read through the same core engine.
def readField(+w: R.World, +value: R.Value) -> C.Machine:
  match value:
    case R.AccessorReference{id}:
      A.evaluateExpression(512n, w, A.invoke(R.Literal{R.AccessorReference{id}}), R.Undefined{})
    case other:
      C.Machine{w, [], [other]}

def deadRows(+w: R.World, +owners: List<&2, Nat>) -> Bool:
  match owners:
    case Nil{}:
      True{}
    case owner <> tail:
      Bool.and(Ambient.isDisposed(w, owner), deadRows(w, tail))

def finish(+input: Nat, +prepared: Prepared) -> View:
  match prepared:
    case Prepared{+w, +beforeRows, accessor, beforeFlush}:
      +read = A.evaluateExpression(512n, w, A.invoke(R.Literal{accessor}), R.Undefined{})
      +rows = A.resultValue(read)
      +w = A.resultWorld(read)
      +r0 = valueAt(w, rows, 0n)
      +r1 = valueAt(w, rows, 1n)
      +r2 = valueAt(w, rows, 2n)
      +item0 = readField(w, valueAt(w, r0, 0n))
      +item1 = readField(A.resultWorld(item0), valueAt(A.resultWorld(item0), r1, 0n))
      +item2 = readField(A.resultWorld(item1), valueAt(A.resultWorld(item1), r2, 0n))
      +index0 = readField(A.resultWorld(item2), valueAt(A.resultWorld(item2), r0, 1n))
      +index1 = readField(A.resultWorld(index0), valueAt(A.resultWorld(index0), r1, 1n))
      +index2 = readField(A.resultWorld(index1), valueAt(A.resultWorld(index1), r2, 1n))
      +w = A.resultWorld(index2)
      +retained = B.equal(valueAt(w, beforeRows, 0n), valueAt(w, rows, B.choose(~Nat, Nat.is_eq(input, 1n), _ => 0n, _ => 1n)))
      +end = A.resultWorld(A.evaluateExpression(2048n, w, R.DisposeRoot{R.Literal{R.OwnerReference{1n}}, True{}}, R.Undefined{}))
      View{[A.resultValue(item0), A.resultValue(item1), A.resultValue(item2)], [A.resultValue(index0), A.resultValue(index1), A.resultValue(index2)], beforeFlush, retained, deadRows(end, R.MapState.nodes(KM.get(end, 0n))), Ambient.isDisposed(end, 4n), Existing.cleanupEvents(R.World.events(end)), R.World.context(end), R.World.tracking(end), R.World.running(end), R.World.fault(end)}

def lifecycle(+input: Nat) -> View:
  finish(input, prepare(input))

def expected() -> View:
  View{[R.Number{2n}, R.Number{1n}, R.Number{3n}], [R.Number{0n}, R.Number{1n}, R.Number{2n}], [R.Number{1n}, R.Number{2n}], True{}, True{}, True{}, [R.CleanupObserved{2n, 9n}, R.CleanupObserved{2n, 9n}, R.CleanupObserved{2n, 9n}], 0n, False{}, False{}, R.Healthy{}}

def plain_complete() -> {lifecycle(0n) == expected() : View}:
  {==}

def index_complete() -> {lifecycle(1n) == expected() : View}:
  {==}

def extracted_complete() -> {lifecycle(2n) == expected() : View}:
  {==}
