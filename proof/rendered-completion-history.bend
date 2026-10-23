# Arbitrary finite permitted completion-prefix/blocker-check histories while a
# rendered flight stays pending. No intervening writes/delivery are admitted.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/action-state.bend as A
import ./pending-rendered-snapshot.bend as Snapshot
import ./completion-pending-preservation.bend as Preserve
import ./completion-graph-frame.bend as Frame

type Programme<-w: R.World, -root: Nat> is Data:
  CompletionEnd{}
  CompletionStep{id: Nat, remaining: Nat,
    resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
    positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat},
    tail: Programme<A.done(w, id), root>}
  BlockCheck{tail: Programme<w, root>}

type Audit is Data:
  Audit{world: R.World, answers: List<&2, Bool>}

def world(value: Audit) -> R.World:
  match value:
    case Audit{w, answers}: w

def answers(value: Audit) -> List<&2, Bool>:
  match value:
    case Audit{w, answers}: answers

def prepend(answer: Bool, audit: Audit) -> Audit:
  match audit:
    case Audit{w, answers}: Audit{w, answer <> answers}

def run(-scope: R.World, +root: Nat, programme: Programme<scope, root>, w: R.World) -> Audit:
  match programme:
    case CompletionEnd{}: Audit{w, []}
    case CompletionStep{id, remaining, resolution, positive, tail}: run(A.done(scope, id), root, tail, A.done(w, id))
    case BlockCheck{tail}:
      +pair = X.blocked(w, root)
      prepend(B.second(R.World, Bool, pair), run(scope, root, tail, B.first(R.World, Bool, pair)))

def checked(-scope: R.World, +root: Nat, tail: Programme<scope, root>, +pair: B.Bundle<R.World, Bool>) -> Audit:
  prepend(B.second(R.World, Bool, pair), run(scope, root, tail, B.first(R.World, Bool, pair)))

# The expected World keeps every actual completion's scheduling changes. Only
# successful blocker checks are erased, using the proof below, not an oracle.
def finish(-scope: R.World, +root: Nat, programme: Programme<scope, root>, w: R.World) -> R.World:
  match programme:
    case CompletionEnd{}: w
    case CompletionStep{id, remaining, resolution, positive, tail}: finish(A.done(scope, id), root, tail, A.done(w, id))
    case BlockCheck{tail}: finish(scope, root, tail, w)

def expected(-scope: R.World, +root: Nat, programme: Programme<scope, root>) -> List<&2, Bool>:
  match programme:
    case CompletionEnd{}: []
    case CompletionStep{id, remaining, resolution, positive, tail}: expected(A.done(scope, id), root, tail)
    case BlockCheck{tail}: True{} <> expected(scope, root, tail)

type Certified<-w: R.World, -root: Nat, -programme: Programme<w, root>> is Data:
  HeldHistory{
    equation: {run(w, root, programme, w) == Audit{finish(w, root, programme, w), expected(w, root, programme)} : Audit},
    pending: Snapshot.Pending<finish(w, root, programme, w), root>,
    healthy: {B.ok(finish(w, root, programme, w)) == True{} : Bool},
    graph: {Frame.graph(finish(w, root, programme, w)) == Frame.graph(w) : Frame.GraphFrame}}

def step(+w: R.World, +root: Nat, +id: Nat, +remaining: Nat,
  +resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  +positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat},
  +tail: Programme<A.done(w, id), root>, certificate: Certified<A.done(w, id), root, tail>) ->
  Certified<w, root, CompletionStep{id, remaining, resolution, positive, tail}>:
  match certificate:
    case HeldHistory{equation, pending, healthy, graph}:
      HeldHistory{equation, pending, healthy,
        Equal.trans(Frame.GraphFrame, Frame.graph(finish(A.done(w, id), root, tail, A.done(w, id))), Frame.graph(A.done(w, id)), Frame.graph(w), graph, Frame.completion(w, id, root, remaining, resolution, positive))}

def check(+w: R.World, +predecessor: Nat, +tail: Programme<w, 1n+predecessor>,
  certificate: Certified<w, 1n+predecessor, tail>,
  blocked: {X.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) -> Certified<w, 1n+predecessor, BlockCheck{tail}>:
  match certificate:
    case HeldHistory{equation, pending, healthy, graph}:
      HeldHistory{
        Equal.trans(Audit, run(w, 1n+predecessor, BlockCheck{tail}, w), prepend(True{}, run(w, 1n+predecessor, tail, w)), Audit{finish(w, 1n+predecessor, tail, w), True{} <> expected(w, 1n+predecessor, tail)},
          Equal.cong(B.Bundle<R.World, Bool>, Audit, pair => checked(w, 1n+predecessor, tail, pair), X.blocked(w, 1n+predecessor), B.Bundle{w, True{}}, blocked),
          Equal.cong(Audit, Audit, result => prepend(True{}, result), run(w, 1n+predecessor, tail, w), Audit{finish(w, 1n+predecessor, tail, w), expected(w, 1n+predecessor, tail)}, equation)), pending, healthy, graph}

# Structural induction measure only; this does not change any runtime budget.
def height(-w: R.World, -root: Nat, programme: Programme<w, root>) -> Nat:
  match programme:
    case CompletionEnd{}: 0n
    case CompletionStep{id, remaining, resolution, positive, tail}: 1n+height(A.done(w, id), root, tail)
    case BlockCheck{tail}: 1n+height(w, root, tail)

def predecessor(n: Nat) -> Nat:
  match n:
    case 0n: 0n
    case 1n+p: p

def predecessorEqual(+a: Nat, +b: Nat, same: {1n+a == 1n+b : Nat}) -> {a == b : Nat}:
  Equal.cong(Nat, Nat, n => predecessor(n), 1n+a, 1n+b, same)

def isZero(n: Nat) -> Bool:
  match n:
    case 0n: True{}
    case 1n+p: False{}

def falseType(b: Bool) -> Data:
  match b:
    case False{}: Unit
    case True{}: Empty

def impossible(e: {False{} == True{} : Bool}) -> Empty:
  %e : falseType(_)
  Unit{}

def nonzero(+n: Nat, same: {1n+n == 0n : Nat}) -> Empty:
  impossible(Equal.cong(Nat, Bool, n => isZero(n), 1n+n, 0n, same))

def certifyLength(+length: Nat, +w: R.World, +predecessor: Nat, +programme: Programme<w, 1n+predecessor>, +snapshot: Snapshot.Pending<w, 1n+predecessor>,
  +healthy: {B.ok(w) == True{} : Bool},
  room: {height(w, 1n+predecessor, programme) == length : Nat}) -> Certified<w, 1n+predecessor, programme>:
  match length programme:
    case 0n CompletionEnd{}: HeldHistory{{==}, snapshot, healthy, {==}}
    case 1n+n CompletionEnd{}: HeldHistory{{==}, snapshot, healthy, {==}}
    case 0n CompletionStep{+id, +remaining, +resolution, +positive, +tail}:
      Empty.absurd(Certified<w, 1n+predecessor, CompletionStep{id, remaining, resolution, positive, tail}>, nonzero(height(A.done(w, id), 1n+predecessor, tail), room))
    case 0n BlockCheck{+tail}:
      Empty.absurd(Certified<w, 1n+predecessor, BlockCheck{tail}>, nonzero(height(w, 1n+predecessor, tail), room))
    case 1n+n CompletionStep{+id, +remaining, +resolution, +positive, +tail}:
      step(w, 1n+predecessor, id, remaining, resolution, positive, tail,
        certifyLength(n, A.done(w, id), predecessor, tail, Preserve.completed(w, id, 1n+predecessor, remaining, snapshot, resolution, positive),
          Equal.trans(Bool, B.ok(A.done(w, id)), B.ok(w), True{}, Preserve.healthy(w, id, 1n+predecessor, remaining, resolution, positive), healthy),
          predecessorEqual(height(A.done(w, id), 1n+predecessor, tail), n, room)))
    case 1n+n BlockCheck{+tail}:
      check(w, predecessor, tail, certifyLength(n, w, predecessor, tail, snapshot, healthy, predecessorEqual(height(w, 1n+predecessor, tail), n, room)), Snapshot.blocked(w, predecessor, R.Transaction.open(B.transaction(w, 1n+predecessor)), snapshot, healthy, {==}))

def certify(+w: R.World, +predecessor: Nat, +programme: Programme<w, 1n+predecessor>, snapshot: Snapshot.Pending<w, 1n+predecessor>,
  healthy: {B.ok(w) == True{} : Bool}) -> Certified<w, 1n+predecessor, programme>:
  certifyLength(height(w, 1n+predecessor, programme), w, predecessor, programme, snapshot, healthy, {==})

# Projection corollaries use the constructed certificate's exact Audit, not a
# snapshot of an unrelated expected runtime.
def equation(+w: R.World, +root: Nat, +programme: Programme<w, root>, certificate: Certified<w, root, programme>) ->
  {run(w, root, programme, w) == Audit{finish(w, root, programme, w), expected(w, root, programme)} : Audit}:
  match certificate:
    case HeldHistory{equation, pending, healthy, graph}: equation

def graphResult(+w: R.World, +root: Nat, +programme: Programme<w, root>, certificate: Certified<w, root, programme>) ->
  {Frame.graph(world(run(w, root, programme, w))) == Frame.graph(w) : Frame.GraphFrame}:
  match certificate:
    case HeldHistory{equation, pending, healthy, graph}:
      Equal.trans(Frame.GraphFrame, Frame.graph(world(run(w, root, programme, w))), Frame.graph(finish(w, root, programme, w)), Frame.graph(w),
        Equal.cong(Audit, Frame.GraphFrame, result => Frame.graph(world(result)), run(w, root, programme, w), Audit{finish(w, root, programme, w), expected(w, root, programme)}, equation), graph)

def all(values: List<&2, Bool>) -> Bool:
  match values:
    case Nil{}: True{}
    case first <> rest: Bool.and(first, all(rest))

def allExpected(-w: R.World, -root: Nat, programme: Programme<w, root>) ->
  {all(expected(w, root, programme)) == True{} : Bool}:
  match programme:
    case CompletionEnd{}: {==}
    case CompletionStep{id, remaining, resolution, positive, tail}: allExpected(A.done(w, id), root, tail)
    case BlockCheck{tail}: allExpected(w, root, tail)

def checksResult(+w: R.World, +root: Nat, +programme: Programme<w, root>, certificate: Certified<w, root, programme>) ->
  {all(answers(run(w, root, programme, w))) == True{} : Bool}:
  Equal.trans(Bool, all(answers(run(w, root, programme, w))), all(expected(w, root, programme)), True{},
    Equal.cong(Audit, Bool, result => all(answers(result)), run(w, root, programme, w), Audit{finish(w, root, programme, w), expected(w, root, programme)}, equation(w, root, programme, certificate)), allExpected(w, root, programme))
