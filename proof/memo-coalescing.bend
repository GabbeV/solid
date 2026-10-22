# Replacing a pending proposal without another notification or schedule.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/read-state.bend as V
import ../runtime/constants.bend as K
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/memo-history-states.bend as M
import ../proof/memo-setter-cuts.bend as Cuts
import ../proof/paths.bend as P
import ../proof/memo-staging.bend as Timing

def self_equal(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      self_equal(p)

def scoped_tail(+w: R.World, +id: Nat, +node: R.Node, promote: Bool, +computed: Bool) -> R.World:
  +w = B.choose(~R.World, promote, _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.choose(~R.World, computed, _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  B.choose(~R.World, B.stampMatches(R.Node.notified(node), R.World.epoch(w)), _ => w, _ => B.schedule(W.insertSubs(w, id)))

def tail_suppressed(+w: R.World, +id: Nat, +node: R.Node,
  contextEq: {Nat.is_ne(R.World.context(w), 0n) == False{} : Bool},
  kindEq: {B.computed(R.Node.kind(node)) == False{} : Bool},
  stampEq: {B.stampMatches(R.Node.notified(node), R.World.epoch(w)) == True{} : Bool}) ->
  {Cuts.tail(w, id, node, True{}) == w : R.World}:
  %Equal.sym(Bool, Nat.is_ne(R.World.context(w), 0n), False{}, contextEq) : {scoped_tail(w, id, node, _, B.computed(R.Node.kind(node))) == w : R.World}
  %Equal.sym(Bool, B.computed(R.Node.kind(node)), False{}, kindEq) : {scoped_tail(w, id, node, False{}, _) == w : R.World}
  Equal.cong(Bool, R.World, gate => B.choose(~R.World, gate, _ => w, _ => B.schedule(W.insertSubs(w, id))), B.stampMatches(R.Node.notified(node), R.World.epoch(w)), True{}, stampEq)

def staging(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.stageResolved(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input}) == C.world(M.state_0(tick, previous, input, events, jobs)) : R.World}:
  +before = C.world(M.state_0(tick, previous, pending, events, jobs))
  +after = C.world(M.state_0(tick, previous, input, events, jobs))
  +node = B.node(before, 2n)
  Equal.trans(R.World, W.stageResolved(before, 2n, R.Number{input}), Cuts.tail(after, 2n, node, True{}), after,
    {==}, tail_suppressed(after, 2n, node, {==}, {==}, self_equal(tick)))

def resolved(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.setResolved(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{pending}, R.Number{input}) == C.world(M.state_0(tick, previous, input, events, jobs)) : R.World}:
  +before = C.world(M.state_0(tick, previous, pending, events, jobs))
  Equal.trans(R.World, W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), W.stageResolved(before, 2n, R.Number{input}), C.world(M.state_0(tick, previous, input, events, jobs)), Cuts.entry(before, 2n, R.Number{pending}, R.Number{input}, {==}, {==}, {==}, {==}), staging(tick, previous, pending, input, events, jobs))

def start(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{C.world(M.state_0(tick, previous, pending, events, jobs)), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{C.world(M.state_0(tick, previous, pending, events, jobs)), [C.SetSignalResolved{2n, R.Number{pending}}], [R.Number{input}]}

def end(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{C.world(M.state_0(tick, previous, input, events, jobs)), [], [R.Number{input}]}

def step_0(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.step(start(tick, previous, pending, input, events, jobs)) == middle(tick, previous, pending, input, events, jobs) : C.Machine}:
  Cuts.step_head(C.world(M.state_0(tick, previous, pending, events, jobs)), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.step(middle(tick, previous, pending, input, events, jobs)) == end(tick, previous, input, events, jobs) : C.Machine}:
  +before = C.world(M.state_0(tick, previous, pending, events, jobs))
  Equal.trans(C.Machine, C.step(middle(tick, previous, pending, input, events, jobs)), C.setResolved(before, [], [], 2n, R.Number{pending}, R.Number{input}), end(tick, previous, input, events, jobs),
    Cuts.step_head(before, C.SetSignalResolved{2n, R.Number{pending}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(before, [], [], 2n, R.Number{pending}, R.Number{input}), C.Machine{W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), [], [R.Number{input}]}, end(tick, previous, input, events, jobs),
      Cuts.core_default(before, [], [], 2n, R.Number{pending}, R.Number{input}, {==}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), C.world(M.state_0(tick, previous, input, events, jobs)), resolved(tick, previous, pending, input, events, jobs))))

def path(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> P.Path<start(tick, previous, pending, input, events, jobs), end(tick, previous, input, events, jobs)>:
  P.PathStep{middle(tick, previous, pending, input, events, jobs), step_0(tick, previous, pending, input, events, jobs), P.PathStep{end(tick, previous, input, events, jobs), step_1(tick, previous, pending, input, events, jobs), P.PathEnd{C.world(M.state_0(tick, previous, input, events, jobs)), [R.Number{input}], {==}, {==}}}}

def completes(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.run(24n, start(tick, previous, pending, input, events, jobs)) == end(tick, previous, input, events, jobs) : C.Machine}:
  Timing.retimed(start(tick, previous, pending, input, events, jobs), end(tick, previous, input, events, jobs), path(tick, previous, pending, input, events, jobs), 22n, 24n, {==})

def public_setter(+tick: Nat, +previous: Nat, +pending: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {A.setSignal(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input}) == C.world(M.state_0(tick, previous, input, events, jobs)) : R.World}:
  Cuts.api_set_completed(C.world(M.state_0(tick, previous, pending, events, jobs)), 2n, R.Number{input}, 24n, start(tick, previous, pending, input, events, jobs), end(tick, previous, input, events, jobs), C.world(M.state_0(tick, previous, input, events, jobs)), {==}, {==}, {==}, {==}, completes(tick, previous, pending, input, events, jobs), {==})
