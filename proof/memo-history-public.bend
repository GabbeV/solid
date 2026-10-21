# One repeatable scalar-memo pass and induction over any finite tail of writes.
# All operations use the unchanged public setter and flush implementation.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./memo-initial-driver.bend as Constructor
import ./memo-constructor-cuts.bend as ConstructorCuts
import ./memo-repeat-public.bend as First
import ./memo-repeat-states.bend as FirstStates
import ./memo-history-states.bend as M
import ./memo-history-setter.bend as Setter
import ./memo-history-setter-data.bend as SetData
import ./memo-history-staging.bend as Drain

type Update is Data:
  Update{value: Nat, extra: Nat}

def nextEvents(events: List<&2, R.TraceEvent>, input: Nat) -> List<&2, R.TraceEvent>:
  B.append(R.TraceEvent, B.append(R.TraceEvent, events, [R.Invoked{3n}]), [R.ReadValue{3n, 2n, R.Number{input}}])

def nextJobs(jobs: List<&2, R.HostJob>) -> List<&2, R.HostJob>:
  B.append(R.HostJob, jobs, [R.FlushJob{}])

def initialEvents(initial: Nat, first: Nat) -> List<&2, R.TraceEvent>:
  [R.Invoked{3n}, R.ReadValue{3n, 2n, R.Number{initial}}, R.AccessorBound{3n}, R.Invoked{3n}, R.ReadValue{3n, 2n, R.Number{first}}]

def final_shape(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {M.finalWorld(tick, previous, input, events, jobs) == M.origin(1n+tick, input, nextEvents(events, input), nextJobs(jobs)) : R.World}:
  {==}

def staged_shape(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {SetData.scheduled(tick, previous, input, events, jobs) == C.world(M.state_0(tick, previous, input, events, jobs)) : R.World}:
  {==}

def staged(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}) == C.world(M.state_0(tick, previous, input, events, jobs)) : R.World}:
  Equal.trans(R.World, A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}), SetData.scheduled(tick, previous, input, events, jobs), C.world(M.state_0(tick, previous, input, events, jobs)), Setter.public_setter(tick, previous, input, events, jobs), staged_shape(tick, previous, input, events, jobs))

def update(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) ->
  {A.flush(Nat.add(40n, extra), A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input})) == M.origin(1n+tick, input, nextEvents(events, input), nextJobs(jobs)) : R.World}:
  First.flush_identified(Nat.add(40n, extra), A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}), C.world(M.state_0(tick, previous, input, events, jobs)), M.finalWorld(tick, previous, input, events, jobs), M.origin(1n+tick, input, nextEvents(events, input), nextJobs(jobs)), staged(tick, previous, input, events, jobs), Drain.flush_eq(tick, previous, input, events, jobs, extra), final_shape(tick, previous, input, events, jobs))

def seed_shape(+initial: Nat, +first: Nat) ->
  {FirstStates.origin(initial, first) == M.origin(0n, first, initialEvents(initial, first), [R.FlushJob{}]) : R.World}:
  {==}

def seed(+initial: Nat, +first: Nat, +constructorExtra: Nat, +firstExtra: Nat) ->
  {A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})) == M.origin(0n, first, initialEvents(initial, first), [R.FlushJob{}]) : R.World}:
  Equal.trans(R.World, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), FirstStates.origin(initial, first), M.origin(0n, first, initialEvents(initial, first), [R.FlushJob{}]), First.first_completed(initial, first, constructorExtra, firstExtra), seed_shape(initial, first))

# Actual execution: each element supplies a public setter argument and its own
# sufficient drain budget. No canonical intermediate World enters this runner.
def run(updates: List<&2, Update>, w: R.World) -> R.World:
  match updates:
    case Nil{}:
      w
    case Update{input, extra} <> rest:
      run(rest, A.flush(Nat.add(40n, extra), A.setSignal(w, 2n, R.Number{input})))

# Expected complete World: advance only the changing scalar bookkeeping fields,
# keep all runtime data, and retain every actual trace/job append.
def result(updates: List<&2, Update>, tick: Nat, previous: Nat, events: List<&2, R.TraceEvent>, jobs: List<&2, R.HostJob>) -> R.World:
  match updates:
    case Nil{}:
      M.origin(tick, previous, events, jobs)
    case Update{+input, extra} <> rest:
      result(rest, 1n+tick, input, nextEvents(events, input), nextJobs(jobs))

def last(updates: List<&2, Update>, previous: Nat) -> Nat:
  match updates:
    case Nil{}:
      previous
    case Update{input, extra} <> rest:
      last(rest, input)

def run_transport(+a: R.World, +b: R.World, +updates: List<&2, Update>, same: {a == b : R.World}) ->
  {run(updates, a) == run(updates, b) : R.World}:
  %same : {run(updates, a) == run(updates, _) : R.World}
  {==}

def all_updates(updates: List<&2, Update>, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {run(updates, M.origin(tick, previous, events, jobs)) == result(updates, tick, previous, events, jobs) : R.World}:
  match updates:
    case Nil{}:
      {==}
    case Update{+input, +extra} <> +rest:
      Equal.trans(R.World, run(rest, A.flush(Nat.add(40n, extra), A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}))), run(rest, M.origin(1n+tick, input, nextEvents(events, input), nextJobs(jobs))), result(rest, 1n+tick, input, nextEvents(events, input), nextJobs(jobs)),
        run_transport(A.flush(Nat.add(40n, extra), A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input})), M.origin(1n+tick, input, nextEvents(events, input), nextJobs(jobs)), rest, update(tick, previous, input, events, jobs, extra)),
        all_updates(rest, 1n+tick, input, nextEvents(events, input), nextJobs(jobs)))

def result_view(updates: List<&2, Update>, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {Driver.view(result(updates, tick, previous, events, jobs)) == Driver.expected(last(updates, previous)) : Driver.View}:
  match updates:
    case Nil{}:
      {==}
    case Update{+input, extra} <> rest:
      result_view(rest, 1n+tick, input, nextEvents(events, input), nextJobs(jobs))

def world(+initial: Nat, +first: Nat, +constructorExtra: Nat, +firstExtra: Nat, +updates: List<&2, Update>) ->
  {run(updates, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))) == result(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}]) : R.World}:
  Equal.trans(R.World, run(updates, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))), run(updates, M.origin(0n, first, initialEvents(initial, first), [R.FlushJob{}])), result(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}]),
    run_transport(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), M.origin(0n, first, initialEvents(initial, first), [R.FlushJob{}]), updates, seed(initial, first, constructorExtra, firstExtra)),
    all_updates(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}]))

def complete(+initial: Nat, +first: Nat, +constructorExtra: Nat, +firstExtra: Nat, +updates: List<&2, Update>) ->
  {Driver.view(run(updates, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))) == Driver.expected(last(updates, first)) : Driver.View}:
  Equal.trans(Driver.View, Driver.view(run(updates, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})))), Driver.view(result(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}])), Driver.expected(last(updates, first)),
    Equal.cong(R.World, Driver.View, w => Driver.view(w), run(updates, A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}))), result(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}]), world(initial, first, constructorExtra, firstExtra, updates)),
    result_view(updates, 0n, first, initialEvents(initial, first), [R.FlushJob{}]))
