# The checked graph drain renders exactly its final proposal once, in addition
# to its constructor's initial application. It starts at the staged arena.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./chain.bend as Chain
import ./chain-states.bend as M
import ./chain-staging.bend as Drain

def applications(events: List<&2, R.TraceEvent>) -> List<&2, R.Value>:
  match events:
    case Nil{}:
      []
    case event <> +tail:
      match event:
        case R.Applied{id, value, previous}:
          B.choose(~List<&2, R.Value>, Nat.is_eq(id, 5n), _ => value <> applications(tail), _ => applications(tail))
        case _:
          applications(tail)

def final(+input: Nat) -> {applications(R.World.events(M.finalWorld(input))) == [R.Number{2n}, Chain.answer(input)] : List<&2, R.Value>}:
  {==}

def observed(+fuel: Nat, +a: R.World, +b: R.World, +expected: List<&2, R.Value>,
  same: {A.flush(fuel, a) == b : R.World}, right: {applications(R.World.events(b)) == expected : List<&2, R.Value>}) ->
  {applications(R.World.events(A.flush(fuel, a))) == expected : List<&2, R.Value>}:
  Equal.trans(List<&2, R.Value>, applications(R.World.events(A.flush(fuel, a))), applications(R.World.events(b)), expected,
    Equal.cong(R.World, List<&2, R.Value>, world => applications(R.World.events(world)), A.flush(fuel, a), b, same), right)

def completes(+input: Nat, +extra: Nat) -> {applications(R.World.events(A.flush(Nat.add(95n, extra), C.world(M.state_0(input))))) == [R.Number{2n}, Chain.answer(input)] : List<&2, R.Value>}:
  observed(Nat.add(95n, extra), C.world(M.state_0(input)), C.world(M.state_95(input)), [R.Number{2n}, Chain.answer(input)], Drain.flush_eq(input, extra), final(input))
