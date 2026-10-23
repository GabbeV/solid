# Nonempty graph blocker contracts. These are source operations over an
# explicit snapshot; construction/reachability of the snapshot is separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths
import ./transaction-positive.bend as Positive
import ./transaction-empty.bend as Empty
import ./transaction-membership.bend as Membership

def guard(+w: R.World, +id: Nat) -> Bool:
  +n = B.node(w, id)
  Bool.or(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.or(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()), B.has(R.Node.config(n), K.CONFIG_GUESS())))

def eligibleTail(+pair: B.Bundle<R.World, Bool>) -> B.Bundle<R.World, Bool>:
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}}, _ => B.Bundle{w, False{}})

def membership(+w: R.World, +id: Nat, +owner: Nat, captured: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(captured, 0n), _ => B.Bundle{w, True{}},
    _ =>
      +pair = X.txOf(w, id)
      B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), owner)})

def routed(+w: R.World, +id: Nat, +owner: Nat, +captured: Nat,
  active: {guard(w, id) == False{} : Bool},
  capture: {R.NodeExtension.transaction(B.extension(w, id)) == 1n+captured : Nat},
  route: {X.txOf(w, id) == B.Bundle{w, owner} : B.Bundle<R.World, Nat>}) ->
  {X.eligible(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.eligible(w, id, owner, False{}), eligibleTail(membership(w, id, owner, R.NodeExtension.transaction(B.extension(w, id)))), B.Bundle{w, True{}},
    Equal.cong(Bool, B.Bundle<R.World, Bool>, stop => B.choose(~B.Bundle<R.World, Bool>, stop, _ => B.Bundle{w, False{}}, _ => eligibleTail(membership(w, id, owner, R.NodeExtension.transaction(B.extension(w, id))))), guard(w, id), False{}, active),
    Equal.trans(B.Bundle<R.World, Bool>, eligibleTail(membership(w, id, owner, R.NodeExtension.transaction(B.extension(w, id)))), eligibleTail(membership(w, id, owner, 1n+captured)), B.Bundle{w, True{}},
      Equal.cong(Nat, B.Bundle<R.World, Bool>, tx => eligibleTail(membership(w, id, owner, tx)), R.NodeExtension.transaction(B.extension(w, id)), 1n+captured, capture),
      Equal.trans(B.Bundle<R.World, Bool>, eligibleTail(membership(w, id, owner, 1n+captured)), eligibleTail(B.Bundle{w, Nat.is_eq(owner, owner)}), B.Bundle{w, True{}},
        Equal.cong(B.Bundle<R.World, Nat>, B.Bundle<R.World, Bool>, pair => eligibleTail(B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), owner)}), X.txOf(w, id), B.Bundle{w, owner}, route),
        Equal.cong(Bool, B.Bundle<R.World, Bool>, same => eligibleTail(B.Bundle{w, same}), Nat.is_eq(owner, owner), True{}, Paths.sameNat(owner)))))

def skipped(+w: R.World, +id: Nat, +owner: Nat,
  inactive: {guard(w, id) == True{} : Bool}) ->
  {X.blockedOne(w, id, owner, False{}) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  Equal.cong(Bool, B.Bundle<R.World, Bool>, stop =>
    +pair = B.choose(~B.Bundle<R.World, Bool>, stop, _ => B.Bundle{w, False{}}, _ => eligibleTail(membership(w, id, owner, R.NodeExtension.transaction(B.extension(w, id)))))
    +next = B.first(R.World, Bool, pair)
    B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
      _ => B.choose(~B.Bundle<R.World, Bool>, X.isRender(R.Node.kind(B.node(next, id))), _ => X.onScreen(next, id, B.choose(~Nat, Nat.is_eq(R.World.judge(next), 0n), _ => owner, _ => R.World.judge(next))), _ => X.blockedSubs(B.budget(next), next, R.Node.subs(B.node(next, id)), owner)), _ => B.Bundle{next, False{}}), guard(w, id), True{}, inactive)

def visible(+w: R.World, +id: Nat, +owner: Nat,
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {X.onScreen(w, id, owner) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.cong(Bool, B.Bundle<R.World, Bool>, zombie => B.choose(~B.Bundle<R.World, Bool>, zombie,
    _ =>
      +pair = X.removalStagedBy(w, id, owner)
      B.Bundle{B.first(R.World, Bool, pair), Bool.not(B.second(R.World, Bool, pair))}, _ => B.Bundle{w, True{}}), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), False{}, live)

def afterEligible(+pair: B.Bundle<R.World, Bool>, +id: Nat, +owner: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
    _ => B.choose(~B.Bundle<R.World, Bool>, X.isRender(R.Node.kind(B.node(w, id))),
      _ => X.onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))),
      _ => X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner)), _ => B.Bundle{w, False{}})

def render(+w: R.World, +id: Nat, +owner: Nat,
  eligible: {X.eligible(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>},
  rendered: {X.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {X.blockedOne(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blockedOne(w, id, owner, False{}), afterEligible(B.Bundle{w, True{}}, id, owner), B.Bundle{w, True{}},
    Equal.cong(B.Bundle<R.World, Bool>, B.Bundle<R.World, Bool>, pair => afterEligible(pair, id, owner), X.eligible(w, id, owner, False{}), B.Bundle{w, True{}}, eligible),
    Equal.trans(B.Bundle<R.World, Bool>, afterEligible(B.Bundle{w, True{}}, id, owner), X.onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))), B.Bundle{w, True{}},
      Equal.cong(Bool, B.Bundle<R.World, Bool>, isRender => B.choose(~B.Bundle<R.World, Bool>, isRender,
        _ => X.onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))), _ => X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner)), X.isRender(R.Node.kind(B.node(w, id))), True{}, rendered),
      visible(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w)), live)))

type Skips<-w: R.World, -owner: Nat> is Data:
  NoSkips{}
  Skip{id: Nat, inactive: {guard(w, id) == True{} : Bool}, rest: Skips<w, owner>}

def ids(-w: R.World, -owner: Nat, prefix: Skips<w, owner>) -> List<&2, Nat>:
  match prefix:
    case NoSkips{}: []
    case Skip{id, inactive, rest}: id <> ids(w, owner, rest)

def afterOne(+pair: B.Bundle<R.World, Bool>, fuel: Nat, rest: List<&2, Nat>, owner: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}}, _ => X.blockedList(fuel, w, rest, owner, False{}))

def list(+w: R.World, +owner: Nat, prefix: Skips<w, owner>, +id: Nat, +tail: List<&2, Nat>, +extra: Nat,
  blocked: {X.blockedOne(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blockedList(Nat.add(B.length(Nat, ids(w, owner, prefix)), 1n+extra), w, B.append(Nat, ids(w, owner, prefix), id <> tail), owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  match prefix:
    case NoSkips{}:
      Equal.cong(B.Bundle<R.World, Bool>, B.Bundle<R.World, Bool>, pair => afterOne(pair, extra, tail, owner), X.blockedOne(w, id, owner, False{}), B.Bundle{w, True{}}, blocked)
    case Skip{+first, inactive, +rest}:
      +fuel = Nat.add(B.length(Nat, ids(w, owner, rest)), 1n+extra)
      +nodes = B.append(Nat, ids(w, owner, rest), id <> tail)
      Equal.trans(B.Bundle<R.World, Bool>, X.blockedList(1n+fuel, w, first <> nodes, owner, False{}), X.blockedList(fuel, w, nodes, owner, False{}), B.Bundle{w, True{}},
        Equal.cong(B.Bundle<R.World, Bool>, B.Bundle<R.World, Bool>, pair => afterOne(pair, fuel, nodes, owner), X.blockedOne(w, first, owner, False{}), B.Bundle{w, False{}}, skipped(w, first, owner, inactive)), list(w, owner, rest, id, tail, extra, blocked))

# The subscriber guard keeps generation/error/disposal tests in source order.
def reader(+w: R.World, +edge: Nat) -> Bool:
  +n = B.node(w, R.Link.sub(B.link(w, edge)))
  Bool.or(Bool.and(X.isRender(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.or(B.has(R.Node.flags(n), K.REACTIVE_FRAME_READ()), Bool.and(B.has(R.Node.config(n), K.CONFIG_REDERIVE()), U32.is_eq(R.Node.status(n), K.STATUS_PENDING()))))

def validReader(+w: R.World, +edge: Nat) -> Bool:
  +e = B.link(w, edge)
  +id = R.Link.sub(e)
  +n = B.node(w, id)
  Bool.and(reader(w, edge), Bool.and(Bool.or(Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))))

def subscriberTail(+pair: B.Bundle<R.World, Bool>, fuel: Nat, +edge: Nat, owner: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}}, _ => X.blockedSubs(fuel, w, R.Link.nextSub(B.link(w, edge)), owner))

def subscriber(+w: R.World, +edge: Nat, +owner: Nat, +extra: Nat,
  valid: {validReader(w, 1n+edge) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, R.Link.sub(B.link(w, 1n+edge)))), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {X.blockedSubs(1n+extra, w, 1n+edge, owner) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  +id = R.Link.sub(B.link(w, 1n+edge))
  +judge = B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))
  Equal.trans(B.Bundle<R.World, Bool>, X.blockedSubs(1n+extra, w, 1n+edge, owner), subscriberTail(X.onScreen(w, id, judge), extra, 1n+edge, owner), B.Bundle{w, True{}},
    Equal.cong(Bool, B.Bundle<R.World, Bool>, valid => subscriberTail(B.choose(~B.Bundle<R.World, Bool>, valid, _ => X.onScreen(w, id, judge), _ => B.Bundle{w, False{}}), extra, 1n+edge, owner), validReader(w, 1n+edge), True{}, valid),
    Equal.cong(B.Bundle<R.World, Bool>, B.Bundle<R.World, Bool>, pair => subscriberTail(pair, extra, 1n+edge, owner), X.onScreen(w, id, judge), B.Bundle{w, True{}}, visible(w, id, judge, live)))

def memo(+w: R.World, +id: Nat, +owner: Nat, +edge: Nat, +extra: Nat,
  eligible: {X.eligible(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>},
  notRender: {X.isRender(R.Node.kind(B.node(w, id))) == False{} : Bool},
  subs: {R.Node.subs(B.node(w, id)) == 1n+edge : Nat},
  room: {B.budget(w) == 1n+extra : Nat},
  valid: {validReader(w, 1n+edge) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, R.Link.sub(B.link(w, 1n+edge)))), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {X.blockedOne(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blockedOne(w, id, owner, False{}), afterEligible(B.Bundle{w, True{}}, id, owner), B.Bundle{w, True{}},
    Equal.cong(B.Bundle<R.World, Bool>, B.Bundle<R.World, Bool>, pair => afterEligible(pair, id, owner), X.eligible(w, id, owner, False{}), B.Bundle{w, True{}}, eligible),
    Equal.trans(B.Bundle<R.World, Bool>, afterEligible(B.Bundle{w, True{}}, id, owner), X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner), B.Bundle{w, True{}},
      Equal.cong(Bool, B.Bundle<R.World, Bool>, rendered => B.choose(~B.Bundle<R.World, Bool>, rendered, _ => X.onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))), _ => X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner)), X.isRender(R.Node.kind(B.node(w, id))), False{}, notRender),
      Equal.trans(B.Bundle<R.World, Bool>, X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner), X.blockedSubs(1n+extra, w, 1n+edge, owner), B.Bundle{w, True{}},
        Equal.trans(B.Bundle<R.World, Bool>, X.blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner), X.blockedSubs(B.budget(w), w, 1n+edge, owner), X.blockedSubs(1n+extra, w, 1n+edge, owner),
          Equal.cong(Nat, B.Bundle<R.World, Bool>, edge => X.blockedSubs(B.budget(w), w, edge, owner), R.Node.subs(B.node(w, id)), 1n+edge, subs), Equal.cong(Nat, B.Bundle<R.World, Bool>, fuel => X.blockedSubs(fuel, w, 1n+edge, owner), B.budget(w), 1n+extra, room)), subscriber(w, edge, owner, extra, valid, live))))

# Align the existing public list budget with the structural prefix, without
# increasing a runtime bound or supplying a guessed fuel premise.
def addSuccessor(+a: Nat, +b: Nat) -> {Nat.add(a, 1n+b) == 1n+Nat.add(a, b) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p:
      Equal.cong(Nat, Nat, n => 1n+n, Nat.add(p, 1n+b), 1n+Nat.add(p, b), addSuccessor(p, b))

def listRoom(+base: Nat, +prefix: List<&2, Nat>, +id: Nat, +tail: List<&2, Nat>) ->
  {Nat.add(base, B.length(Nat, B.append(Nat, prefix, id <> tail))) == Nat.add(B.length(Nat, prefix), 1n+Nat.add(base, B.length(Nat, tail))) : Nat}:
  match prefix:
    case Nil{}: addSuccessor(base, B.length(Nat, tail))
    case first <> +rest:
      Equal.trans(Nat, Nat.add(base, 1n+B.length(Nat, B.append(Nat, rest, id <> tail))), 1n+Nat.add(base, B.length(Nat, B.append(Nat, rest, id <> tail))), 1n+Nat.add(B.length(Nat, rest), 1n+Nat.add(base, B.length(Nat, tail))),
        addSuccessor(base, B.length(Nat, B.append(Nat, rest, id <> tail))),
        Equal.cong(Nat, Nat, n => 1n+n, Nat.add(base, B.length(Nat, B.append(Nat, rest, id <> tail))), Nat.add(B.length(Nat, rest), 1n+Nat.add(base, B.length(Nat, tail))), listRoom(base, rest, id, tail)))

def by(+w: R.World, +owner: Nat, +prefix: Skips<w, owner>, +id: Nat, +tail: List<&2, Nat>,
  blocked: {X.blockedOne(w, id, owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blockedBy(w, B.append(Nat, ids(w, owner, prefix), id <> tail), owner, False{}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  +nodes = B.append(Nat, ids(w, owner, prefix), id <> tail)
  Equal.trans(B.Bundle<R.World, Bool>, X.blockedBy(w, nodes, owner, False{}), X.blockedList(Nat.add(B.length(Nat, ids(w, owner, prefix)), 1n+Nat.add(B.budget(w), B.length(Nat, tail))), w, nodes, owner, False{}), B.Bundle{w, True{}},
    Equal.cong(Nat, B.Bundle<R.World, Bool>, fuel => X.blockedList(fuel, w, nodes, owner, False{}), Nat.add(B.budget(w), B.length(Nat, nodes)), Nat.add(B.length(Nat, ids(w, owner, prefix)), 1n+Nat.add(B.budget(w), B.length(Nat, tail))), listRoom(B.budget(w), ids(w, owner, prefix), id, tail)),
    list(w, owner, prefix, id, tail, Nat.add(B.budget(w), B.length(Nat, tail)), blocked))

def head(+w: R.World, +tx: Nat,
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  graph: {X.blockedBy(Positive.enter(w, tx), R.Transaction.nodes(B.transaction(Positive.enter(w, tx), tx)), tx, False{}) == B.Bundle{Positive.enter(w, tx), True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blockStep(w, [X.JudgeTx{tx}], False{}) == X.BlockFrame{Positive.enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}} : X.BlockFrame}:
  +entered = Positive.enter(w, tx)
  +previous = R.World.judge(w)
  Equal.trans(X.BlockFrame, X.blockStep(w, [X.JudgeTx{tx}], False{}), Positive.decide(entered, tx, previous, R.Transaction.open(B.transaction(entered, tx))), X.BlockFrame{entered, [X.RestoreJudge{previous}], True{}}, Positive.expand(w, tx),
    Equal.trans(X.BlockFrame, Positive.decide(entered, tx, previous, R.Transaction.open(B.transaction(entered, tx))), Positive.decide(entered, tx, previous, 0n), X.BlockFrame{entered, [X.RestoreJudge{previous}], True{}},
      Equal.cong(Nat, X.BlockFrame, count => Positive.decide(entered, tx, previous, count), R.Transaction.open(B.transaction(entered, tx)), 0n,
        Equal.trans(Nat, R.Transaction.open(B.transaction(entered, tx)), R.Transaction.open(B.transaction(w, tx)), 0n,
          Equal.cong(R.Transaction, Nat, record => R.Transaction.open(record), B.transaction(entered, tx), B.transaction(w, tx), Positive.readEntered(w, tx)), zero)),
      Equal.cong(B.Bundle<R.World, Bool>, X.BlockFrame, pair => Empty.afterOwn(pair, tx, previous), X.blockedBy(entered, R.Transaction.nodes(B.transaction(entered, tx)), tx, False{}), B.Bundle{entered, True{}}, graph)))

def run(+w: R.World, +tx: Nat, +extra: Nat,
  +healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  graph: {X.blockedBy(Positive.enter(w, tx), R.Transaction.nodes(B.transaction(Positive.enter(w, tx), tx)), tx, False{}) == B.Bundle{Positive.enter(w, tx), True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blockRun(2n+extra, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Empty.lift(1n+extra, w, X.JudgeTx{tx}, [], False{}, X.BlockFrame{Positive.enter(w, tx), [X.RestoreJudge{R.World.judge(w)}], True{}}, B.Bundle{w, True{}}, healthy, head(w, tx, zero, graph),
    Empty.lift(extra, Positive.enter(w, tx), X.RestoreJudge{R.World.judge(w)}, [], True{}, X.BlockFrame{w, [], True{}}, B.Bundle{w, True{}},
      Equal.trans(Bool, B.ok(Positive.enter(w, tx)), B.ok(w), True{}, Positive.healthyEntered(w, tx), healthy), Positive.restore(w, tx), Positive.empty(extra, w, True{})))

def public(+w: R.World, +tx: Nat,
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, tx)) == 0n : Nat},
  graph: {X.blockedBy(Positive.enter(w, tx), R.Transaction.nodes(B.transaction(Positive.enter(w, tx), tx)), tx, False{}) == B.Bundle{Positive.enter(w, tx), True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blocked(w, tx) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(w, tx), X.blockRun(2n+Nat.sub(X.blockBudget(w), 2n), X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), B.Bundle{w, True{}},
    Equal.cong(Nat, B.Bundle<R.World, Bool>, fuel => X.blockRun(fuel, X.BlockFrame{w, [X.JudgeTx{tx}], False{}}), X.blockBudget(w), 2n+Nat.sub(X.blockBudget(w), 2n), Positive.bound(w)), run(w, tx, Nat.sub(X.blockBudget(w), 2n), healthy, zero, graph))

# This public theorem supplies the internal membership and graph judgments from
# snapshot facts. It does not assume blocked/eligible/txOf results as premises.
def renderGroup(+w: R.World, +predecessor: Nat, +prefix: Skips<Positive.enter(w, 1n+predecessor), 1n+predecessor>, +id: Nat, +tail: List<&2, Nat>,
  healthy: {B.ok(w) == True{} : Bool},
  zero: {R.Transaction.open(B.transaction(w, 1n+predecessor)) == 0n : Nat},
  nodes: {R.Transaction.nodes(B.transaction(Positive.enter(w, 1n+predecessor), 1n+predecessor)) == B.append(Nat, ids(Positive.enter(w, 1n+predecessor), 1n+predecessor, prefix), id <> tail) : List<&2, Nat>},
  active: {guard(Positive.enter(w, 1n+predecessor), id) == False{} : Bool},
  +capture: {R.NodeExtension.transaction(B.extension(Positive.enter(w, 1n+predecessor), id)) == 1n+predecessor : Nat},
  stopped: {R.Transaction.into(B.transaction(Positive.enter(w, 1n+predecessor), 1n+predecessor)) == 0n : Nat},
  rendered: {X.isRender(R.Node.kind(B.node(Positive.enter(w, 1n+predecessor), id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(Positive.enter(w, 1n+predecessor), id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  {X.blocked(w, 1n+predecessor) == B.Bundle{w, True{}} : B.Bundle<R.World, Bool>}:
  +tx = {1n+predecessor : Nat}
  +entered = Positive.enter(w, tx)
  public(w, tx, healthy, zero,
    Equal.trans(B.Bundle<R.World, Bool>, X.blockedBy(entered, R.Transaction.nodes(B.transaction(entered, tx)), tx, False{}), X.blockedBy(entered, B.append(Nat, ids(entered, tx, prefix), id <> tail), tx, False{}), B.Bundle{entered, True{}},
      Equal.cong(List<&2, Nat>, B.Bundle<R.World, Bool>, owned => X.blockedBy(entered, owned, tx, False{}), R.Transaction.nodes(B.transaction(entered, tx)), B.append(Nat, ids(entered, tx, prefix), id <> tail), nodes),
      by(entered, tx, prefix, id, tail, render(entered, id, tx,
        routed(entered, id, tx, predecessor, active, capture, Membership.terminal(entered, id, tx, capture, stopped)), rendered, live))))

def pendingReader(+w: R.World, +edge: Nat,
  rendered: {X.isRender(R.Node.kind(B.node(w, R.Link.sub(B.link(w, edge))))) == True{} : Bool},
  pending: {B.has(R.Node.status(B.node(w, R.Link.sub(B.link(w, edge)))), K.STATUS_PENDING()) == True{} : Bool}) ->
  {reader(w, edge) == True{} : Bool}:
  +n = B.node(w, R.Link.sub(B.link(w, edge)))
  Equal.trans(Bool, reader(w, edge), Bool.or(Bool.and(True{}, B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.or(B.has(R.Node.flags(n), K.REACTIVE_FRAME_READ()), Bool.and(B.has(R.Node.config(n), K.CONFIG_REDERIVE()), U32.is_eq(R.Node.status(n), K.STATUS_PENDING())))), True{},
    Equal.cong(Bool, Bool, rendered => Bool.or(Bool.and(rendered, B.has(R.Node.status(n), K.STATUS_PENDING())), Bool.or(B.has(R.Node.flags(n), K.REACTIVE_FRAME_READ()), Bool.and(B.has(R.Node.config(n), K.CONFIG_REDERIVE()), U32.is_eq(R.Node.status(n), K.STATUS_PENDING())))), X.isRender(R.Node.kind(n)), True{}, rendered),
    Equal.cong(Bool, Bool, pending => Bool.or(pending, Bool.or(B.has(R.Node.flags(n), K.REACTIVE_FRAME_READ()), Bool.and(B.has(R.Node.config(n), K.CONFIG_REDERIVE()), U32.is_eq(R.Node.status(n), K.STATUS_PENDING())))), B.has(R.Node.status(n), K.STATUS_PENDING()), True{}, pending))

def currentReader(+w: R.World, +edge: Nat,
  reads: {reader(w, edge) == True{} : Bool},
  generation: {R.Link.gen(B.link(w, edge)) == R.Node.depGen(B.node(w, R.Link.sub(B.link(w, edge)))) : Nat},
  alive: {B.has(R.Node.flags(B.node(w, R.Link.sub(B.link(w, edge)))), K.REACTIVE_DISPOSED()) == False{} : Bool}) ->
  {validReader(w, edge) == True{} : Bool}:
  +e = B.link(w, edge)
  +id = R.Link.sub(e)
  +n = B.node(w, id)
  Equal.trans(Bool, validReader(w, edge), Bool.and(Bool.or(Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))), True{},
    Equal.cong(Bool, Bool, reader => Bool.and(reader, Bool.and(Bool.or(Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED())))), reader(w, edge), True{}, reads),
    Equal.trans(Bool, Bool.and(Bool.or(Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED())), True{},
      Equal.cong(Bool, Bool, same => Bool.and(Bool.or(same, Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))), Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), True{},
        Equal.trans(Bool, Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Nat.is_eq(R.Node.depGen(n), R.Node.depGen(n)), True{}, Equal.cong(Nat, Bool, gen => Nat.is_eq(gen, R.Node.depGen(n)), R.Link.gen(e), R.Node.depGen(n), generation), Paths.sameNat(R.Node.depGen(n)))),
      Equal.cong(Bool, Bool, disposed => Bool.not(disposed), B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()), False{}, alive)))
