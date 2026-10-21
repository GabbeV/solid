# Arbitrarily many writes per flush, and arbitrarily many flushes.
# The setter/drain engines and source bookkeeping are unchanged.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./memo-initial-driver.bend as Constructor
import ./memo-constructor-cuts.bend as ConstructorCuts
import ./memo-general-public.bend as FirstPublic
import ./memo-general-states.bend as FirstStates
import ./memo-general-staging.bend as FirstDrain
import ./memo-repeat-public.bend as First
import ./memo-repeat-states.bend as RepeatStates
import ./memo-history-public.bend as H
import ./memo-history-states.bend as M
import ./memo-history-staging.bend as Drain
import ./memo-coalescing.bend as Replace
import ./memo-first-coalescing.bend as FirstReplace

type Batch is Data:
  Batch{first: Nat, rest: List<&2, Nat>, extra: Nat}

def last(values: List<&2, Nat>, previous: Nat) -> Nat:
  match values:
    case Nil{}:
      previous
    case input <> rest:
      last(rest, input)

# Actual setter calls in order, with no intervening flush or canonical reset.
def writes(values: List<&2, Nat>, w: R.World) -> R.World:
  match values:
    case Nil{}:
      w
    case input <> rest:
      writes(rest, A.setSignal(w, 2n, R.Number{input}))

def writes_transport(+values: List<&2, Nat>, +a: R.World, +b: R.World, same: {a == b : R.World}) ->
  {writes(values, a) == writes(values, b) : R.World}:
  %same : {writes(values, a) == writes(values, _) : R.World}
  {==}

def many_staged(values: List<&2, Nat>, +tick: Nat, +previous: Nat, +pending: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {writes(values, C.world(M.state_0(tick, previous, pending, events, jobs))) == C.world(M.state_0(tick, previous, last(values, pending), events, jobs)) : R.World}:
  match values:
    case Nil{}:
      {==}
    case +input <> +rest:
      Equal.trans(R.World, writes(rest, A.setSignal(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input})), writes(rest, C.world(M.state_0(tick, previous, input, events, jobs))), C.world(M.state_0(tick, previous, last(rest, input), events, jobs)),
        writes_transport(rest, A.setSignal(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input}), C.world(M.state_0(tick, previous, input, events, jobs)), Replace.public_setter(tick, previous, pending, input, events, jobs)),
        many_staged(rest, tick, previous, input, events, jobs))

def first_many_staged(values: List<&2, Nat>, +initial: Nat, +pending: Nat) ->
  {writes(values, C.world(FirstStates.state_0(initial, pending))) == C.world(FirstStates.state_0(initial, last(values, pending))) : R.World}:
  match values:
    case Nil{}:
      {==}
    case +input <> +rest:
      Equal.trans(R.World, writes(rest, A.setSignal(C.world(FirstStates.state_0(initial, pending)), 2n, R.Number{input})), writes(rest, C.world(FirstStates.state_0(initial, input))), C.world(FirstStates.state_0(initial, last(rest, input))),
        writes_transport(rest, A.setSignal(C.world(FirstStates.state_0(initial, pending)), 2n, R.Number{input}), C.world(FirstStates.state_0(initial, input)), FirstReplace.public_setter(initial, pending, input)),
        first_many_staged(rest, initial, input))

def staged(+tick: Nat, +previous: Nat, +first: Nat, +rest: List<&2, Nat>, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first})) == C.world(M.state_0(tick, previous, last(rest, first), events, jobs)) : R.World}:
  Equal.trans(R.World, writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first})), writes(rest, C.world(M.state_0(tick, previous, first, events, jobs))), C.world(M.state_0(tick, previous, last(rest, first), events, jobs)),
    writes_transport(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first}), C.world(M.state_0(tick, previous, first, events, jobs)), H.staged(tick, previous, first, events, jobs)),
    many_staged(rest, tick, previous, first, events, jobs))

def batch(+tick: Nat, +previous: Nat, +first: Nat, +rest: List<&2, Nat>, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) ->
  {A.flush(Nat.add(40n, extra), writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first}))) == M.origin(1n+tick, last(rest, first), H.nextEvents(events, last(rest, first)), H.nextJobs(jobs)) : R.World}:
  +input = last(rest, first)
  First.flush_identified(Nat.add(40n, extra), writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first})), C.world(M.state_0(tick, previous, input, events, jobs)), M.finalWorld(tick, previous, input, events, jobs), M.origin(1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs)), staged(tick, previous, first, rest, events, jobs), Drain.flush_eq(tick, previous, input, events, jobs, extra), H.final_shape(tick, previous, input, events, jobs))

def first_staged(+initial: Nat, +first: Nat, +rest: List<&2, Nat>, +constructorExtra: Nat) ->
  {writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})) == C.world(FirstStates.state_0(initial, last(rest, first))) : R.World}:
  Equal.trans(R.World, writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), writes(rest, C.world(FirstStates.state_0(initial, first))), C.world(FirstStates.state_0(initial, last(rest, first))),
    writes_transport(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}), C.world(FirstStates.state_0(initial, first)), FirstPublic.staged(initial, first, constructorExtra)),
    first_many_staged(rest, initial, first))

def first_shape(+initial: Nat, +input: Nat) ->
  {C.world(FirstStates.state_40(initial, input)) == M.origin(0n, input, H.initialEvents(initial, input), [R.FlushJob{}]) : R.World}:
  Equal.trans(R.World, C.world(FirstStates.state_40(initial, input)), RepeatStates.origin(initial, input), M.origin(0n, input, H.initialEvents(initial, input), [R.FlushJob{}]), First.first_shape(initial, input), H.seed_shape(initial, input))

def seed(+initial: Nat, +first: Nat, +rest: List<&2, Nat>, +constructorExtra: Nat, +extra: Nat) ->
  {A.flush(Nat.add(40n, extra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))) == M.origin(0n, last(rest, first), H.initialEvents(initial, last(rest, first)), [R.FlushJob{}]) : R.World}:
  +input = last(rest, first)
  First.flush_identified(Nat.add(40n, extra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), C.world(FirstStates.state_0(initial, input)), C.world(FirstStates.state_40(initial, input)), M.origin(0n, input, H.initialEvents(initial, input), [R.FlushJob{}]), first_staged(initial, first, rest, constructorExtra), FirstDrain.flush_eq(initial, input, extra), first_shape(initial, input))

def run(batches: List<&2, Batch>, w: R.World) -> R.World:
  match batches:
    case Nil{}:
      w
    case Batch{first, rest, extra} <> tail:
      run(tail, A.flush(Nat.add(40n, extra), writes(rest, A.setSignal(w, 2n, R.Number{first}))))

def result(batches: List<&2, Batch>, tick: Nat, previous: Nat, events: List<&2, R.TraceEvent>, jobs: List<&2, R.HostJob>) -> R.World:
  match batches:
    case Nil{}:
      M.origin(tick, previous, events, jobs)
    case Batch{first, rest, extra} <> tail:
      +input = last(rest, first)
      result(tail, 1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs))

def lastBatch(batches: List<&2, Batch>, previous: Nat) -> Nat:
  match batches:
    case Nil{}:
      previous
    case Batch{first, rest, extra} <> tail:
      lastBatch(tail, last(rest, first))

def run_transport(+batches: List<&2, Batch>, +a: R.World, +b: R.World, same: {a == b : R.World}) ->
  {run(batches, a) == run(batches, b) : R.World}:
  %same : {run(batches, a) == run(batches, _) : R.World}
  {==}

def all_batches(batches: List<&2, Batch>, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {run(batches, M.origin(tick, previous, events, jobs)) == result(batches, tick, previous, events, jobs) : R.World}:
  match batches:
    case Nil{}:
      {==}
    case Batch{+first, +rest, +extra} <> +tail:
      +input = last(rest, first)
      Equal.trans(R.World, run(tail, A.flush(Nat.add(40n, extra), writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first})))), run(tail, M.origin(1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs))), result(tail, 1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs)),
        run_transport(tail, A.flush(Nat.add(40n, extra), writes(rest, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{first}))), M.origin(1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs)), batch(tick, previous, first, rest, events, jobs, extra)),
        all_batches(tail, 1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs)))

def result_view(batches: List<&2, Batch>, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {Driver.view(result(batches, tick, previous, events, jobs)) == Driver.expected(lastBatch(batches, previous)) : Driver.View}:
  match batches:
    case Nil{}:
      {==}
    case Batch{first, rest, extra} <> tail:
      +input = last(rest, first)
      result_view(tail, 1n+tick, input, H.nextEvents(events, input), H.nextJobs(jobs))

def world(+initial: Nat, +first: Nat, +rest: List<&2, Nat>, +constructorExtra: Nat, +firstExtra: Nat, +batches: List<&2, Batch>) ->
  {run(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))) == result(batches, 0n, last(rest, first), H.initialEvents(initial, last(rest, first)), [R.FlushJob{}]) : R.World}:
  +input = last(rest, first)
  Equal.trans(R.World, run(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))), run(batches, M.origin(0n, input, H.initialEvents(initial, input), [R.FlushJob{}])), result(batches, 0n, input, H.initialEvents(initial, input), [R.FlushJob{}]),
    run_transport(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))), M.origin(0n, input, H.initialEvents(initial, input), [R.FlushJob{}]), seed(initial, first, rest, constructorExtra, firstExtra)),
    all_batches(batches, 0n, input, H.initialEvents(initial, input), [R.FlushJob{}]))

def complete(+initial: Nat, +first: Nat, +rest: List<&2, Nat>, +constructorExtra: Nat, +firstExtra: Nat, +batches: List<&2, Batch>) ->
  {Driver.view(run(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))))) == Driver.expected(lastBatch(batches, last(rest, first))) : Driver.View}:
  +input = last(rest, first)
  Equal.trans(Driver.View, Driver.view(run(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))))), Driver.view(result(batches, 0n, input, H.initialEvents(initial, input), [R.FlushJob{}])), Driver.expected(lastBatch(batches, input)),
    Equal.cong(R.World, Driver.View, w => Driver.view(w), run(batches, A.flush(Nat.add(40n, firstExtra), writes(rest, A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))), result(batches, 0n, input, H.initialEvents(initial, input), [R.FlushJob{}]), world(initial, first, rest, constructorExtra, firstExtra, batches)),
    result_view(batches, 0n, input, H.initialEvents(initial, input), [R.FlushJob{}]))
