# A constructed finite return of actual Core.step calls. Slack records room in
# a structural upper bound; it does not increase the runtime's chosen budget.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

type Returned<-before: C.Machine, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -maximum: Nat> is Data:
  ReturnedAt{steps: Nat, slack: Nat, world: R.World,
    room: {Nat.add(steps, slack) == maximum : Nat},
    exact: {Steps.iterate(steps, before) == C.Machine{world, rest, stack} : C.Machine}}

def steps(-before: C.Machine, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -maximum: Nat, result: Returned<before, rest, stack, maximum>) -> Nat:
  match result:
    case ReturnedAt{steps, slack, world, room, exact}: steps

def slack(-before: C.Machine, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -maximum: Nat, result: Returned<before, rest, stack, maximum>) -> Nat:
  match result:
    case ReturnedAt{steps, slack, world, room, exact}: slack

def world(-before: C.Machine, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -maximum: Nat, result: Returned<before, rest, stack, maximum>) -> R.World:
  match result:
    case ReturnedAt{steps, slack, world, room, exact}: world

def driver(+before: C.Machine, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +maximum: Nat, +result: Returned<before, rest, stack, maximum>, +remaining: Nat) ->
  {C.run(Nat.add(steps(before, rest, stack, maximum, result), remaining), before) == C.run(remaining, C.Machine{world(before, rest, stack, maximum, result), rest, stack}) : C.Machine}:
  match result:
    case ReturnedAt{+used, slack, +after, room, exact}:
      Equal.trans(C.Machine, C.run(Nat.add(used, remaining), before), C.run(remaining, Steps.iterate(used, before)), C.run(remaining, C.Machine{after, rest, stack}), Driver.split(used, remaining, before), Equal.cong(C.Machine, C.Machine, machine => C.run(remaining, machine), Steps.iterate(used, before), C.Machine{after, rest, stack}, exact))

def addAssociate(+a: Nat, +b: Nat, +c: Nat) ->
  {Nat.add(Nat.add(a, b), c) == Nat.add(a, Nat.add(b, c)) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.cong(Nat, Nat, value => 1n+value, Nat.add(Nat.add(p, b), c), Nat.add(p, Nat.add(b, c)), addAssociate(p, b, c))

# A proved actual prefix composes with a constructed bounded return. The caller
# is not executed by either side of the certificate.
def prepend(+before: C.Machine, +middle: C.Machine, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +length: Nat, +maximum: Nat,
  prefix: {Steps.iterate(length, before) == middle : C.Machine}, result: Returned<middle, rest, stack, maximum>) ->
  Returned<before, rest, stack, Nat.add(length, maximum)>:
  match result:
    case ReturnedAt{+used, +left, +after, room, exact}:
      +space = Equal.trans(Nat, Nat.add(Nat.add(length, used), left), Nat.add(length, Nat.add(used, left)), Nat.add(length, maximum), addAssociate(length, used, left), Equal.cong(Nat, Nat, value => Nat.add(length, value), Nat.add(used, left), maximum, room))
      +done = Equal.trans(C.Machine, Steps.iterate(Nat.add(length, used), before), Steps.iterate(used, Steps.iterate(length, before)), C.Machine{after, rest, stack}, Driver.iterationsCompose(length, used, before),
        Equal.trans(C.Machine, Steps.iterate(used, Steps.iterate(length, before)), Steps.iterate(used, middle), C.Machine{after, rest, stack}, Equal.cong(C.Machine, C.Machine, machine => Steps.iterate(used, machine), Steps.iterate(length, before), middle, prefix), exact))
      ReturnedAt{Nat.add(length, used), left, after, space, done}

# Prepending actual work retains the completed suffix's exact returned World.
def prependWorld(+before: C.Machine, +middle: C.Machine, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +length: Nat, +maximum: Nat,
  +prefix: {Steps.iterate(length, before) == middle : C.Machine}, +result: Returned<middle, rest, stack, maximum>) ->
  {world(before, rest, stack, Nat.add(length, maximum), prepend(before, middle, rest, stack, length, maximum, prefix, result)) == world(middle, rest, stack, maximum, result) : R.World}:
  match result:
    case ReturnedAt{used, left, after, room, exact}: {==}

def bounded(-before: C.Machine, -rest: List<&2, C.Task>, -stack: List<&2, R.Value>, -maximum: Nat, +result: Returned<before, rest, stack, maximum>) ->
  {Nat.add(steps(before, rest, stack, maximum, result), slack(before, rest, stack, maximum, result)) == maximum : Nat}:
  match result:
    case ReturnedAt{used, left, after, room, exact}: room
