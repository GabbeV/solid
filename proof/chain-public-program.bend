# Complete fixed two-memo/render program, arbitrary natural proposals and drain
# budgets >= 95. The constructor is the actual fixed program in chain.bend.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./chain.bend as Chain
import ./chain-states.bend as M
import ./chain-setter.bend as Setter
import ./chain-staging.bend as Drain
import ./chain-observation.bend as Observation

def complete(+input: Nat, +extra: Nat) ->
  {Chain.view(A.flush(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input}))) == Chain.expected(input) : Chain.View}:
  Equal.trans(Chain.View,
    Chain.view(A.flush(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input}))),
    Chain.view(A.flush(Nat.add(95n, extra), C.world(M.state_0(input)))), Chain.expected(input),
    Equal.cong(R.World, Chain.View, w => Chain.view(A.flush(Nat.add(95n, extra), w)),
      A.setSignal(Chain.initial(), 2n, R.Number{input}), C.world(M.state_0(input)), Setter.constructed(input)),
    Drain.completed(input, extra))

def flush_completed(+fuel: Nat, +a: R.World, +b: R.World, +end: R.World,
  staged: {a == b : R.World}, reached: {A.flush(fuel, b) == end : R.World}) ->
  {A.flush(fuel, a) == end : R.World}:
  Equal.trans(R.World, A.flush(fuel, a), A.flush(fuel, b), end,
    Equal.cong(R.World, R.World, w => A.flush(fuel, w), a, b, staged), reached)

def world(+input: Nat, +extra: Nat) ->
  {A.flush(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input})) == M.finalWorld(input) : R.World}:
  flush_completed(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input}), C.world(M.state_0(input)), M.finalWorld(input), Setter.constructed(input), Drain.flush_eq(input, extra))


def applications(+input: Nat, +extra: Nat) ->
  {Observation.applications(R.World.events(A.flush(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input})))) == [R.Number{2n}, Chain.answer(input)] : List<&2, R.Value>}:
  Observation.observed(Nat.add(95n, extra), A.setSignal(Chain.initial(), 2n, R.Number{input}), M.finalWorld(input), [R.Number{2n}, Chain.answer(input)], world(input, extra), Observation.final(input))
