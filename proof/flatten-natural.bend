# Fixed two-payload children tree, arbitrary natural payloads, exact machine.
import Base
import ./paths.bend as P
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R

def expression(+first: Nat, +second: Nat) -> R.Expr:
  +nested = A.arrayLiteral(R.CallArgumentsItem{R.Literal{R.Number{second}}, R.CallArgumentsItem{R.Literal{R.Boolean{False{}}}, R.CallArgumentsEnd{}}})
  A.flatten(A.arrayLiteral(R.CallArgumentsItem{R.Literal{R.Number{first}}, R.CallArgumentsItem{nested, R.CallArgumentsEnd{}}}), True{}, False{})

def program(+first: Nat, +second: Nat) -> C.Machine:
  A.evaluateExpression(128n, A.createWorld(), expression(first, second), R.Undefined{})

def expected(+first: Nat, +second: Nat) -> C.Machine:
  +arrays = {[R.ArrayData{[R.Present{R.Number{second}}, R.Present{R.Boolean{False{}}}]}, R.ArrayData{[R.Present{R.Number{first}}, R.Present{R.ArrayReference{0n}}]}, R.ArrayData{[R.Present{R.Number{first}}, R.Present{R.Number{second}}]}] : List<&2, R.ArrayData>}
  C.Machine{R.World.with_arrays(A.createWorld(), arrays), [], [R.ArrayReference{2n}]}

def complete(+first: Nat, +second: Nat) -> {program(first, second) == expected(first, second) : C.Machine}:
  {==}

# A proof path is a finite iteration of the actual Core.step, never another
# children algorithm. The endpoint witness requires a completed machine.

def steps(amount: Nat, start: C.Machine) -> C.Machine:
  match amount:
    case 0n:
      start
    case 1n+rest:
      steps(rest, C.step(start))

def pathTo(+amount: Nat, +start: C.Machine, +world: R.World, +values: List<&2, R.Value>, witness: {steps(amount, start) == C.Machine{world, [], values} : C.Machine}) -> P.Path<start, C.Machine{world, [], values}>:
  match amount:
    case 0n:
      P.PathEnd{world, values, witness, {==}}
    case 1n+rest:
      P.PathStep{C.step(start), {==}, pathTo(rest, C.step(start), world, values, witness)}

def pathLength(+amount: Nat, +start: C.Machine, +world: R.World, +values: List<&2, R.Value>, +witness: {steps(amount, start) == C.Machine{world, [], values} : C.Machine}) ->
  {P.length(start, C.Machine{world, [], values}, pathTo(amount, start, world, values, witness)) == amount : Nat}:
  match amount:
    case 0n:
      {==}
    case 1n+rest:
      Equal.cong(Nat, Nat, n => 1n+n,
        P.length(C.step(start), C.Machine{world, [], values}, pathTo(rest, C.step(start), world, values, witness)),
        rest, pathLength(rest, C.step(start), world, values, witness))

def origin(+first: Nat, +second: Nat) -> C.Machine:
  C.Machine{A.createWorld(), [C.Evaluate{expression(first, second), R.Undefined{}}], []}

def endpoint_world(+first: Nat, +second: Nat) -> R.World:
  C.world(expected(first, second))

def reached(+first: Nat, +second: Nat) -> {steps(128n, origin(first, second)) == C.Machine{endpoint_world(first, second), [], [R.ArrayReference{2n}]} : C.Machine}:
  {==}

def programWithBudget(+first: Nat, +second: Nat, +extra: Nat) -> C.Machine:
  A.evaluateExpression(Nat.add(128n, extra), A.createWorld(), expression(first, second), R.Undefined{})

def sufficient(+first: Nat, +second: Nat, +extra: Nat) ->
  {A.evaluateExpression(Nat.add(128n, extra), A.createWorld(), expression(first, second), R.Undefined{}) == expected(first, second) : C.Machine}:
  +start = origin(first, second)
  +world = endpoint_world(first, second)
  +values = {[R.ArrayReference{2n}] : List<&2, R.Value>}
  +witness = reached(first, second)
  +path = pathTo(128n, start, world, values, witness)
  Equal.trans(C.Machine,
    C.run(Nat.add(128n, extra), start),
    C.run(Nat.add(P.length(start, C.Machine{world, [], values}, path), extra), start),
    C.Machine{world, [], values},
    Equal.cong(Nat, C.Machine, n => C.run(Nat.add(n, extra), start), 128n,
      P.length(start, C.Machine{world, [], values}, path), Equal.sym(Nat, P.length(start, C.Machine{world, [], values}, path), 128n, pathLength(128n, start, world, values, witness))),
    P.realizes(start, C.Machine{world, [], values}, path, extra, start, {==}))
