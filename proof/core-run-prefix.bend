# Exact driver decomposition. This preserves the real run/exhaustion semantics;
# repeated steps do not imply completion or a sufficient runtime budget.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps

def iterateEmpty(+length: Nat, +w: R.World, +stack: List<&2, R.Value>) ->
  {Steps.iterate(length, C.Machine{w, [], stack}) == C.Machine{w, [], stack} : C.Machine}:
  match length:
    case 0n: {==}
    case 1n+p: iterateEmpty(p, w, stack)

def runEmpty(fuel: Nat, w: R.World, stack: List<&2, R.Value>) ->
  {C.run(fuel, C.Machine{w, [], stack}) == C.Machine{w, [], stack} : C.Machine}:
  match fuel:
    case 0n: {==}
    case 1n+p: {==}

def split(+length: Nat, +remaining: Nat, +machine: C.Machine) ->
  {C.run(Nat.add(length, remaining), machine) == C.run(remaining, Steps.iterate(length, machine)) : C.Machine}:
  match length machine:
    case 0n m: {==}
    case 1n+p C.Machine{+w, Nil{}, +stack}:
      +empty = {C.Machine{w, [], stack} : C.Machine}
      Equal.sym(C.Machine, C.run(remaining, Steps.iterate(p, empty)), empty,
        Equal.trans(C.Machine, C.run(remaining, Steps.iterate(p, empty)), C.run(remaining, empty), empty,
          Equal.cong(C.Machine, C.Machine, after => C.run(remaining, after), Steps.iterate(p, empty), empty, iterateEmpty(p, w, stack)), runEmpty(remaining, w, stack)))
    case 1n+p C.Machine{w, head <> tail, stack}:
      split(p, remaining, C.step(C.Machine{w, head <> tail, stack}))

def iterateSuccessor(+length: Nat, +machine: C.Machine) ->
  {Steps.iterate(1n+length, machine) == C.step(Steps.iterate(length, machine)) : C.Machine}:
  match length:
    case 0n: {==}
    case 1n+p: iterateSuccessor(p, C.step(machine))

def appendStep(+length: Nat, +before: C.Machine, +middle: C.Machine, +after: C.Machine,
  prefix: {Steps.iterate(length, before) == middle : C.Machine}, next: {C.step(middle) == after : C.Machine}) ->
  {Steps.iterate(1n+length, before) == after : C.Machine}:
  Equal.trans(C.Machine, Steps.iterate(1n+length, before), C.step(Steps.iterate(length, before)), after, iterateSuccessor(length, before),
    Equal.trans(C.Machine, C.step(Steps.iterate(length, before)), C.step(middle), after, Equal.cong(C.Machine, C.Machine, machine => C.step(machine), Steps.iterate(length, before), middle, prefix), next))

def iterationsCompose(+length: Nat, +remaining: Nat, +machine: C.Machine) ->
  {Steps.iterate(Nat.add(length, remaining), machine) == Steps.iterate(remaining, Steps.iterate(length, machine)) : C.Machine}:
  match length:
    case 0n: {==}
    case 1n+p: iterationsCompose(p, remaining, C.step(machine))

# Resource exhaustion is explicit and drops unfinished work/stack exactly as
# the current driver does. This is not successful reactive completion.
def exhausts(+w: R.World, head: C.Task, tail: List<&2, C.Task>, stack: List<&2, R.Value>) ->
  {C.run(0n, C.Machine{w, head <> tail, stack}) == C.Machine{R.World.with_fault(w, R.Exhausted{}), [], []} : C.Machine}:
  {==}
