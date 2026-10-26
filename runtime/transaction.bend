# core/scheduler.ts transaction identity, membership, joins and blocker helpers.
# Lane identity/block judgments execute here to break the source module cycle;
# lane read/stage/write/seam and boundary hooks remain unfinished.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./extension.bend as E
import ./constants.bend as K
import ./pending-state.bend as P

def newTransaction(+w: R.World, +lane: Bool, parent: Nat) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.Transaction, R.World.txArena(w))
  t = {R.Transaction{[], [], [], [], 0n, parent, lane, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}} : R.Transaction}
  +w = R.World.with_txArena(w, B.append(R.Transaction, R.World.txArena(w), [t]))
  w = B.choose(~R.World, lane, _ => w,
    _ => R.World.with_transactions(w, B.append(Nat, R.World.transactions(w), [id])))
  B.Bundle{w, id}

def resolveLoop(fuel: Nat, +w: R.World, +id: Nat) -> B.Bundle<R.World, Nat>:
  match fuel:
    case 0n:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), id}
    case 1n+p:
      +into = R.Transaction.into(B.transaction(w, id))
      B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(into, 0n), _ => B.Bundle{w, id},
        _ => resolveLoop(p, w, into))

def resolveTx(+w: R.World, id: Nat) -> B.Bundle<R.World, Nat>:
  resolveLoop(1n+B.length(R.Transaction, R.World.txArena(w)), w, id)

def txOf(+w: R.World, +id: Nat) -> B.Bundle<R.World, Nat>:
  +pair = resolveTx(w, R.NodeExtension.transaction(B.extension(w, id)))
  +w = B.first(R.World, Nat, pair)
  +tx = B.second(R.World, Nat, pair)
  B.Bundle{B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), tx)), tx}

def liveTx(+w: R.World, id: Nat) -> B.Bundle<R.World, Nat>:
  +pair = resolveTx(w, id)
  +w = B.first(R.World, Nat, pair)
  +tx = B.second(R.World, Nat, pair)
  B.Bundle{w, B.choose(~Nat, B.contains(R.World.transactions(w), tx), _ => tx, _ => 0n)}

# Source splice(indexOf(id), 1), including JS indexOf's -1 behavior.
def dropLast(xs: List<&2, Nat>) -> List<&2, Nat>:
  match xs:
    case Nil{}:
      []
    case id <> Nil{}:
      []
    case id <> tail:
      id <> dropLast(tail)

def removeIdentity(+xs: List<&2, Nat>, +id: Nat) -> List<&2, Nat>:
  B.choose(~List<&2, Nat>, B.contains(xs, id), _ => P.remove(xs, id), _ => dropLast(xs))

def appendMarks(left: R.OptionalIds, right: R.OptionalIds) -> R.OptionalIds:
  match left right:
    case a R.NoIds{}:
      a
    case R.NoIds{} R.SomeIds{xs}:
      R.SomeIds{xs}
    case R.SomeIds{xs} R.SomeIds{ys}:
      R.SomeIds{B.append(Nat, xs, ys)}

def mergeResolved(+w: R.World, +t: Nat, +f: Nat) -> R.World:
  B.choose(~R.World, Bool.or(Nat.is_eq(t, f), Bool.or(R.Transaction.lane(B.transaction(w, t)), R.Transaction.lane(B.transaction(w, f)))),
    _ => w,
    _ =>
      +from = B.transaction(w, t)
      +into = B.transaction(w, f)
      +w = B.store_transaction(w, t, R.Transaction.with_into(from, f))
      +into = R.Transaction.with_open(into, Nat.add(R.Transaction.open(into), R.Transaction.open(from)))
      +into = R.Transaction.with_acted(into, Bool.or(R.Transaction.acted(into), R.Transaction.acted(from)))
      +into = R.Transaction.with_nodes(into, B.append(Nat, R.Transaction.nodes(into), R.Transaction.nodes(from)))
      +into = R.Transaction.with_renderQueue(into, B.append(Nat, R.Transaction.renderQueue(into), R.Transaction.renderQueue(from)))
      +into = R.Transaction.with_userQueue(into, B.append(R.QueueEntry, R.Transaction.userQueue(into), R.Transaction.userQueue(from)))
      +into = R.Transaction.with_reruns(into, B.append(Nat, R.Transaction.reruns(into), R.Transaction.reruns(from)))
      +into = R.Transaction.with_marks(into, appendMarks(R.Transaction.marks(into), R.Transaction.marks(from)))
      +w = B.store_transaction(w, f, into)
      R.World.with_transactions(w, removeIdentity(R.World.transactions(w), t)))

def merge(+w: R.World, t: Nat, f: Nat) -> R.World:
  +pair = resolveTx(w, t)
  +w = B.first(R.World, Nat, pair)
  t = B.second(R.World, Nat, pair)
  +pair = resolveTx(w, f)
  mergeResolved(B.first(R.World, Nat, pair), t, B.second(R.World, Nat, pair))

def joinFuture(+w: R.World, +t: Nat) -> R.World:
  +f = R.World.flushTransaction(w)
  +w = B.choose(~R.World, Nat.is_eq(f, 0n),
    _ =>
      +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(t, 0n), _ => newTransaction(w, False{}, 0n), _ => resolveTx(w, t))
      R.World.with_flushTransaction(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair)),
    _ => B.choose(~R.World, Nat.is_eq(t, 0n), _ => w, _ => merge(w, t, f)))
  B.choose(~R.World, R.World.running(w), _ => w, _ => B.schedule(w))

def joinPassTx(+w: R.World, +t: Nat, own: Bool) -> R.World:
  B.choose(~R.World, Bool.or(Bool.and(R.World.running(w), Bool.not(own)), Nat.is_ne(R.World.flushTransaction(w), 0n)),
    _ => joinFuture(w, t),
    _ =>
      +pair = resolveTx(w, t)
      +w = B.first(R.World, Nat, pair)
      +t = B.second(R.World, Nat, pair)
      +w = B.choose(~R.World, Nat.is_eq(R.World.passTx(w), 0n),
        _ => R.World.with_passTx(w, t), _ => merge(w, t, R.World.passTx(w)))
      B.schedule(w))

def list(+w: R.World, +id: Nat, +t: Nat) -> R.World:
  +w = E.ext(w, id)
  B.choose(~R.World, Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), t), _ => w,
    _ =>
      +w = B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), t))
      B.store_transaction(w, t, R.Transaction.with_nodes(B.transaction(w, t), B.append(Nat, R.Transaction.nodes(B.transaction(w, t)), [id]))))

def holdNode(+w: R.World, +id: Nat, t: Nat) -> R.World:
  list(B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_HELD()))), id, t)

def unhold(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), 0n))
  B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_HELD())))

def staleReader(+w: R.World, +id: Nat, +t: Nat) -> R.World:
  B.choose(~R.World, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_FRAME_READ()), _ => w,
    _ =>
      +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), K.REACTIVE_FRAME_READ())))
      B.store_transaction(w, t, R.Transaction.with_reruns(B.transaction(w, t), B.append(Nat, R.Transaction.reruns(B.transaction(w, t)), [id]))))

def bornInto(+w: R.World, +id: Nat, +t: Nat) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.or(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()), B.has(R.Node.config(n), K.CONFIG_HELD_FRAME())), B.has(R.Node.config(n), K.CONFIG_HELD())),
    _ =>
      +pair = txOf(w, id)
      B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), t)},
    _ => B.Bundle{w, False{}})

def isRender(kind: R.NodeKind) -> Bool:
  match kind:
    case R.Render{}:
      True{}
    case _:
      False{}

# core/core.ts:frameRead; the full-index source installs verdict/lane hooks.
# Folded stores and mounted freshHook remain separate unfinished crossings.
def frameRead(+w: R.World, +reader: Nat, +id: Nat) -> B.Bundle<R.World, Bool>:
  +verdict = B.has(R.Node.config(B.node(w, reader)), K.CONFIG_VERDICT())
  +lane = Nat.is_ne(R.World.passLane(w), 0n)
  +cold = Bool.and(Bool.or(Bool.not(lane), Bool.and(B.has(R.Node.status(B.node(w, reader)), K.STATUS_UNINITIALIZED()), B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()))), Bool.and(Bool.not(verdict), Bool.or(Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_FRAME())), B.has(R.Node.config(B.node(w, id)), K.CONFIG_INPUTS_PUBLISHED()))))
  B.choose(~B.Bundle<R.World, Bool>, cold, _ => B.Bundle{w, False{}},
    _ =>
      +pair = txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      +t = B.second(R.World, Nat, pair)
      B.choose(~B.Bundle<R.World, Bool>, Bool.and(Nat.is_eq(t, R.World.flushTransaction(w)), Bool.and(Bool.not(lane), Bool.not(verdict))), _ => B.Bundle{w, False{}},
        _ =>
          +pair = bornInto(w, reader, t)
          +w = B.first(R.World, Bool, pair)
          B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, False{}},
            _ => B.Bundle{staleReader(w, reader, t), True{}})))

def stagedScreen(+w: R.World, +reader: Nat) -> B.Bundle<R.World, Bool>:
  +t = R.World.flushTransaction(w)
  B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(t, 0n), _ => B.Bundle{w, False{}},
    _ =>
      +pair = bornInto(w, reader, t)
      +w = B.first(R.World, Bool, pair)
      B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, False{}}, _ => B.Bundle{staleReader(w, reader, t), True{}}))

# core/core.ts:joinPass (freshHook is not installed in the admitted profile).
def joinPass(+w: R.World, +reader: Nat, +id: Nat) -> R.World:
  +w = B.store_node(w, reader, R.Node.with_flags(B.node(w, reader), B.set(R.Node.flags(B.node(w, reader)), K.REACTIVE_JOINED())))
  +n = B.node(w, reader)
  B.choose(~R.World, Bool.or(B.has(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED()),
    Bool.not(isRender(R.Node.kind(n)))),
    _ =>
      +pair = txOf(w, id)
      +w = B.first(R.World, Nat, pair)
      own = Bool.and(Bool.not(B.effect(R.Node.kind(n))), B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()))
      joinPassTx(w, B.second(R.World, Nat, pair), own),
    _ => w)

# The nearest non-zombie ancestor's held transaction stages this removal.
def removalOwner(fuel: Nat, +w: R.World, +id: Nat) -> B.Bundle<R.World, Nat>:
  match fuel:
    case 0n:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), id}
    case 1n+p:
      B.choose(~B.Bundle<R.World, Nat>, Bool.and(Nat.is_ne(id, 0n), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE())),
        _ => removalOwner(p, w, R.Node.parent(B.node(w, id))), _ => B.Bundle{w, id})

def removalStagedBy(+w: R.World, +id: Nat, t: Nat) -> B.Bundle<R.World, Bool>:
  +pair = removalOwner(B.budget(w), w, id)
  +w = B.first(R.World, Nat, pair)
  +owner = B.second(R.World, Nat, pair)
  B.choose(~B.Bundle<R.World, Bool>, Bool.and(B.has(R.Node.config(B.node(w, owner)), K.CONFIG_HELD()), Nat.is_ne(R.NodeExtension.transaction(B.extension(w, owner)), 0n)),
    _ =>
      +pair = txOf(w, owner)
      +w = B.first(R.World, Nat, pair)
      +held = B.second(R.World, Nat, pair)
      +pair = resolveTx(w, t)
      B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(held, B.second(R.World, Nat, pair))},
    _ => B.Bundle{w, False{}})

def onScreen(+w: R.World, +id: Nat, t: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()),
    _ =>
      +pair = removalStagedBy(w, id, t)
      B.Bundle{B.first(R.World, Bool, pair), Bool.not(B.second(R.World, Bool, pair))},
    _ => B.Bundle{w, True{}})

def ownSourceLoop(fuel: Nat, +w: R.World, sources: List<&2, Nat>, +t: Nat) -> B.Bundle<R.World, Bool>:
  match fuel sources:
    case _ Nil{}:
      B.Bundle{w, False{}}
    case 0n xs:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p source <> +rest:
      +tx = R.NodeExtension.transaction(B.extension(w, source))
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(tx, 0n), _ => B.Bundle{w, True{}},
        _ =>
          +pair = resolveTx(w, tx)
          +w = B.first(R.World, Nat, pair)
          B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(B.second(R.World, Nat, pair), t), _ => B.Bundle{w, True{}},
            _ => ownSourceLoop(p, w, rest, t)))

def ownSourceState(+w: R.World, sources: R.SourceSet, +t: Nat) -> B.Bundle<R.World, Bool>:
  match sources:
    case R.NoSources{}:
      B.Bundle{w, True{}}
    case R.Sources{sources}:
      ownSourceLoop(B.budget(w), w, sources, t)

def ownSource(+w: R.World, id: Nat, t: Nat) -> B.Bundle<R.World, Bool>:
  ownSourceState(w, B.pendingSources(w, id), t)

def blockedSubs(fuel: Nat, +w: R.World, +edge: Nat, +owner: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n:
      B.Bundle{B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{})), False{}}
    case 1n+p:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(edge, 0n), _ => B.Bundle{w, False{}},
        _ =>
          +e = B.link(w, edge)
          +id = R.Link.sub(e)
          +n = B.node(w, id)
          +reader = Bool.or(Bool.and(isRender(R.Node.kind(n)), B.has(R.Node.status(n), K.STATUS_PENDING())),
            Bool.or(B.has(R.Node.flags(n), K.REACTIVE_FRAME_READ()), Bool.and(B.has(R.Node.config(n), K.CONFIG_REDERIVE()), U32.is_eq(R.Node.status(n), K.STATUS_PENDING()))))
          valid = Bool.and(reader, Bool.and(Bool.or(Nat.is_eq(R.Link.gen(e), R.Node.depGen(n)), Bool.not(B.nullish(R.NodeExtension.error(B.extension(w, id))))),
            Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()))))
          +pair = B.choose(~B.Bundle<R.World, Bool>, valid,
            _ => onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))),
            _ => B.Bundle{w, False{}})
          +w = B.first(R.World, Bool, pair)
          B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}},
            _ => blockedSubs(p, w, R.Link.nextSub(B.link(w, edge)), owner)))

# Source guard is sequenced: txOf compresses only after the earlier bit tests.
def eligible(+w: R.World, +id: Nat, +owner: Nat, +own: Bool) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  B.choose(~B.Bundle<R.World, Bool>, Bool.or(Bool.not(B.has(R.Node.status(n), K.STATUS_PENDING())),
      Bool.or(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED()), B.has(R.Node.config(n), K.CONFIG_GUESS()))),
    _ => B.Bundle{w, False{}},
    _ =>
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), 0n),
        _ => B.Bundle{w, True{}},
        _ =>
          +pair = txOf(w, id)
          B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), owner)})
      +w = B.first(R.World, Bool, pair)
      B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
        _ => B.choose(~B.Bundle<R.World, Bool>, own, _ => ownSource(w, id, owner), _ => B.Bundle{w, True{}}),
        _ => B.Bundle{w, False{}}))

def blockedOne(+w: R.World, +id: Nat, +owner: Nat, own: Bool) -> B.Bundle<R.World, Bool>:
  +pair = eligible(w, id, owner, own)
  +w = B.first(R.World, Bool, pair)
  B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
    _ => B.choose(~B.Bundle<R.World, Bool>, isRender(R.Node.kind(B.node(w, id))),
      _ => onScreen(w, id, B.choose(~Nat, Nat.is_eq(R.World.judge(w), 0n), _ => owner, _ => R.World.judge(w))),
      _ => blockedSubs(B.budget(w), w, R.Node.subs(B.node(w, id)), owner)),
    _ => B.Bundle{w, False{}})

def blockedList(fuel: Nat, +w: R.World, nodes: List<&2, Nat>, +owner: Nat, +own: Bool) -> B.Bundle<R.World, Bool>:
  match fuel nodes:
    case _ Nil{}:
      B.Bundle{w, False{}}
    case 0n xs:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p id <> +rest:
      +pair = blockedOne(w, id, owner, own)
      +w = B.first(R.World, Bool, pair)
      B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}},
        _ => blockedList(p, w, rest, owner, own))

def blockedBy(+w: R.World, +nodes: List<&2, Nat>, owner: Nat, own: Bool) -> B.Bundle<R.World, Bool>:
  blockedList(Nat.add(B.budget(w), B.length(Nat, nodes)), w, nodes, owner, own)

def ownFlights(+w: R.World, +t: Nat) -> B.Bundle<R.World, Bool>:
  blockedBy(w, R.Transaction.nodes(B.transaction(w, t)), t, True{})

# core/lanes.ts:inFlight / guessFlights. Store flight resolvers are outside
# the typed non-store profile, so a needed slot hook refuses explicitly.
def laneInFlight(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.status(B.node(w, id)), K.STATUS_PENDING()), _ => B.Bundle{w, True{}},
    _ => B.choose(~B.Bundle<R.World, Bool>, B.has(R.Node.config(B.node(w, id)), K.CONFIG_SLOT_NODE()),
      _ => B.Bundle{R.World.with_fault(w, R.Unsupported{88n}), False{}}, _ => B.Bundle{w, False{}}))

def guessFlightLoop(fuel: Nat, +w: R.World, +lane: Nat, +index: Nat) -> B.Bundle<R.World, Bool>:
  match fuel:
    case 0n:
      B.Bundle{B.choose(~R.World, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), _ => w, _ => R.World.with_fault(w, R.Exhausted{})), False{}}
    case 1n+ +p:
      B.choose(~B.Bundle<R.World, Bool>, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, lane)))), _ => B.Bundle{w, False{}},
        _ =>
          +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, lane)), index, 0n)
          B.choose(~B.Bundle<R.World, Bool>, Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_GUESS()), Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), lane)),
            _ =>
              +pair = laneInFlight(w, id)
              +w = B.first(R.World, Bool, pair)
              B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}},
                _ => guessFlightLoop(p, w, lane, 1n+index)),
            _ => guessFlightLoop(p, w, lane, 1n+index)))

def guessFlights(+w: R.World, +lane: Nat) -> B.Bundle<R.World, Bool>:
  guessFlightLoop(1n+B.length(Nat, R.Transaction.nodes(B.transaction(w, lane))), w, lane, 0n)

# scheduler.ts:blocked and lanes.ts:lanesBlocked/linkBlocked/nestedBlocked
# mutually recurse in TS. Explicit call/return tasks keep one judgment and its
# saved judge. Groups retain their captured array identity and live bounds.
type BlockTask is Data:
  JudgeTx{tx: Nat}
  RestoreJudge{previous: Nat}
  JudgeLanes{tx: Nat}
  LinkedMembers{lane: Nat, group: Nat, index: Nat}
  AfterLinked{tx: Nat}
  ContinueLinked{lane: Nat, group: Nat, index: Nat}
  NestedMembers{tx: Nat, index: Nat}
  ContinueNested{tx: Nat, index: Nat, lane: Nat}

type BlockFrame is Data:
  BlockFrame{world: R.World, tasks: List<&2, BlockTask>, result: Bool}

def blockGroup(+w: R.World, group: Nat) -> List<&2, Nat>:
  B.get(List<&2, Nat>, R.LaneState.groups(R.World.laneState(w)), group, [])

def blockStep(+w: R.World, work: List<&2, BlockTask>, +result: Bool) -> BlockFrame:
  match work:
    case Nil{}:
      BlockFrame{w, [], result}
    case JudgeTx{+tx} <> +rest:
      +previous = R.World.judge(w)
      +w = B.choose(~R.World, Nat.is_eq(previous, 0n), _ => R.World.with_judge(w, tx), _ => w)
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(R.Transaction.open(B.transaction(w, tx)), 0n), _ => B.Bundle{w, True{}},
        _ => blockedBy(w, R.Transaction.nodes(B.transaction(w, tx)), tx, False{}))
      +w = B.first(R.World, Bool, pair)
      B.choose(~BlockFrame, B.second(R.World, Bool, pair),
        _ => BlockFrame{w, RestoreJudge{previous} <> rest, True{}},
        _ => BlockFrame{w, JudgeLanes{tx} <> RestoreJudge{previous} <> rest, False{}})
    case RestoreJudge{previous} <> rest:
      BlockFrame{R.World.with_judge(w, previous), rest, result}
    case JudgeLanes{+tx} <> +rest:
      B.choose(~BlockFrame, R.Transaction.lane(B.transaction(w, tx)),
        _ => BlockFrame{w, LinkedMembers{tx, R.Transaction.links(B.transaction(w, tx)), 0n} <> AfterLinked{tx} <> rest, False{}},
        _ => BlockFrame{w, NestedMembers{tx, 0n} <> rest, False{}})
    case AfterLinked{tx} <> +rest:
      B.choose(~BlockFrame, result, _ => BlockFrame{w, rest, True{}}, _ => BlockFrame{w, NestedMembers{tx, 0n} <> rest, False{}})
    case LinkedMembers{+lane, +group, +index} <> +rest:
      B.choose(~BlockFrame, Bool.or(Nat.is_eq(group, 0n), Nat.is_ge(index, B.length(Nat, blockGroup(w, group)))), _ => BlockFrame{w, rest, False{}},
        _ =>
          +peer = B.get(Nat, blockGroup(w, group), index, 0n)
          B.choose(~BlockFrame, Nat.is_eq(peer, lane),
            _ => BlockFrame{w, LinkedMembers{lane, group, 1n+index} <> rest, False{}},
            _ => B.choose(~BlockFrame, Nat.is_ne(R.Transaction.open(B.transaction(w, peer)), 0n), _ => BlockFrame{w, rest, True{}},
              _ =>
                +pair = ownFlights(w, peer)
                +w = B.first(R.World, Bool, pair)
                B.choose(~BlockFrame, B.second(R.World, Bool, pair), _ => BlockFrame{w, rest, True{}},
                  _ => BlockFrame{w, NestedMembers{peer, 0n} <> ContinueLinked{lane, group, index} <> rest, False{}}))))
    case ContinueLinked{lane, group, index} <> +rest:
      B.choose(~BlockFrame, result, _ => BlockFrame{w, rest, True{}}, _ => BlockFrame{w, LinkedMembers{lane, group, 1n+index} <> rest, False{}})
    case NestedMembers{+tx, +index} <> +rest:
      B.choose(~BlockFrame, Nat.is_ge(index, B.length(Nat, R.LaneState.live(R.World.laneState(w)))), _ => BlockFrame{w, rest, False{}},
        _ =>
          +lane = B.get(Nat, R.LaneState.live(R.World.laneState(w)), index, 0n)
          +pair = resolveTx(w, R.Transaction.parent(B.transaction(w, lane)))
          +w = B.first(R.World, Nat, pair)
          B.choose(~BlockFrame, Nat.is_ne(B.second(R.World, Nat, pair), tx),
            _ => BlockFrame{w, NestedMembers{tx, 1n+index} <> rest, False{}},
            _ => BlockFrame{w, JudgeTx{lane} <> ContinueNested{tx, index, lane} <> rest, False{}}))
    case ContinueNested{tx, index, lane} <> +rest:
      B.choose(~BlockFrame, result, _ => BlockFrame{w, rest, True{}},
        _ =>
          +pair = guessFlights(w, lane)
          +w = B.first(R.World, Bool, pair)
          B.choose(~BlockFrame, B.second(R.World, Bool, pair), _ => BlockFrame{w, rest, True{}},
            _ => BlockFrame{w, NestedMembers{tx, 1n+index} <> rest, False{}}))

def blockRun(fuel: Nat, frame: BlockFrame) -> B.Bundle<R.World, Bool>:
  match fuel frame:
    case _ BlockFrame{w, Nil{}, result}:
      B.Bundle{w, result}
    case 0n BlockFrame{w, tasks, result}:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), False{}}
    case 1n+p BlockFrame{+w, tasks, +result}:
      B.choose(~B.Bundle<R.World, Bool>, B.ok(w), _ => blockRun(p, blockStep(w, tasks, result)), _ => B.Bundle{w, result})

# Explicit execution bound, not a general graph progress theorem. Exhaustion
# is a fault. The constant prefix also gives early exits a symbolic budget.
def blockBudget(+w: R.World) -> Nat:
  +transactions = B.length(R.Transaction, R.World.txArena(w))
  16n+Nat.mul(1n+Nat.mul(transactions, transactions), Nat.add(B.budget(w), Nat.mul(4n, 1n+B.length(Nat, R.LaneState.live(R.World.laneState(w))))))

def blocked(+w: R.World, tx: Nat) -> B.Bundle<R.World, Bool>:
  blockRun(blockBudget(w), BlockFrame{w, [JudgeTx{tx}], False{}})

def lanesBlocked(+w: R.World, tx: Nat) -> B.Bundle<R.World, Bool>:
  blockRun(blockBudget(w), BlockFrame{w, [JudgeLanes{tx}], False{}})

def linkBlocked(+w: R.World, +lane: Nat) -> B.Bundle<R.World, Bool>:
  blockRun(blockBudget(w), BlockFrame{w, [LinkedMembers{lane, R.Transaction.links(B.transaction(w, lane)), 0n}], False{}})

def nestedBlocked(+w: R.World, tx: Nat) -> B.Bundle<R.World, Bool>:
  blockRun(blockBudget(w), BlockFrame{w, [NestedMembers{tx, 0n}], False{}})

# Frame walk is source DFS; read nextSibling after returning from each child.
type Task is Data:
  HoldChild{id: Nat, tx: Nat}
  HoldNext{id: Nat, tx: Nat}

def holdStep(+w: R.World, tasks: List<&2, Task>) -> B.Bundle<R.World, List<&2, Task>>:
  match tasks:
    case Nil{}:
      B.Bundle{w, []}
    case HoldChild{+id, +tx} <> +rest:
      B.choose(~B.Bundle<R.World, List<&2, Task>>, Nat.is_eq(id, 0n), _ => B.Bundle{w, rest},
        _ => B.choose(~B.Bundle<R.World, List<&2, Task>>, R.Transaction.lane(B.transaction(w, R.NodeExtension.transaction(B.extension(w, id)))),
          _ => B.Bundle{w, HoldNext{id, tx} <> rest},
          _ =>
            +w = B.choose(~R.World, B.computed(R.Node.kind(B.node(w, id))),
              _ =>
                +w = B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => w, _ => holdNode(w, id, tx))
                B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_HELD_FRAME()))), _ => w)
            B.Bundle{w, HoldChild{R.Node.firstChild(B.node(w, id)), tx} <> HoldNext{id, tx} <> rest}))
    case HoldNext{+id, tx} <> rest:
      B.Bundle{w, HoldChild{R.Node.nextSibling(B.node(w, id)), tx} <> rest}

def holdRun(fuel: Nat, +w: R.World, tasks: List<&2, Task>) -> R.World:
  match fuel tasks:
    case _ Nil{}:
      w
    case 0n rest:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+p rest:
      +pair = holdStep(w, rest)
      holdRun(p, B.first(R.World, List<&2, Task>, pair), B.second(R.World, List<&2, Task>, pair))

def holdFrame(+w: R.World, +id: Nat, t: Nat) -> R.World:
  holdRun(Nat.mul(4n, B.budget(w)), w, [HoldChild{R.Node.firstChild(B.node(w, id)), t}])

def blockerCandidate(+w: R.World, +id: Nat, +t: Nat) -> B.Bundle<R.World, Bool>:
  +n = B.node(w, id)
  B.choose(~B.Bundle<R.World, Bool>, Bool.and(Bool.not(B.effect(R.Node.kind(n))), Bool.and(B.has(R.Node.status(n), K.STATUS_PENDING()), Bool.not(B.has(R.Node.flags(n), K.REACTIVE_DISPOSED())))),
    _ =>
      +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_eq(R.NodeExtension.transaction(B.extension(w, id)), 0n), _ => B.Bundle{w, True{}},
        _ =>
          +pair = txOf(w, id)
          B.Bundle{B.first(R.World, Nat, pair), Nat.is_eq(B.second(R.World, Nat, pair), t)})
      +w = B.first(R.World, Bool, pair)
      B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair),
        _ => blockedBy(w, [id], t, False{}), _ => B.Bundle{w, False{}}),
    _ => B.Bundle{w, False{}})

def blockersLoop(fuel: Nat, +w: R.World, +t: Nat, +index: Nat, +out: List<&2, Nat>) -> B.Bundle<R.World, List<&2, Nat>>:
  match fuel:
    case 0n:
      B.Bundle{R.World.with_fault(w, R.Exhausted{}), out}
    case 1n+p:
      B.choose(~B.Bundle<R.World, List<&2, Nat>>, Nat.is_ge(index, B.length(Nat, R.Transaction.nodes(B.transaction(w, t)))), _ => B.Bundle{w, out},
        _ =>
          +id = B.get(Nat, R.Transaction.nodes(B.transaction(w, t)), index, 0n)
          +pair = blockerCandidate(w, id, t)
          +w = B.first(R.World, Bool, pair)
          out = B.choose(~List<&2, Nat>, B.second(R.World, Bool, pair), _ => B.append(Nat, out, [id]), _ => out)
          blockersLoop(p, w, t, 1n+index, out))

def blockersOf(+w: R.World, +t: Nat) -> B.Bundle<R.World, List<&2, Nat>>:
  blockersLoop(1n+Nat.add(B.budget(w), B.length(Nat, R.Transaction.nodes(B.transaction(w, t)))), w, t, 0n, [])

# Shared source composition joinFuture(txOf(n)); txOf's compression precedes join.
def joinNode(+w: R.World, id: Nat) -> R.World:
  +pair = txOf(w, id)
  joinFuture(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair))

def noMarks(marks: R.OptionalIds) -> Bool:
  match marks:
    case R.NoIds{}:
      True{}
    case R.SomeIds{items}:
      False{}

# core.ts read's held-entry block. Slow read excludes overrides and directly
# joins an uninitialized source; a plain-signal fast read calls frameRead first.
def enterRead(+w: R.World, +reader: Nat, +id: Nat, +slow: Bool) -> B.Bundle<R.World, Bool>:
  eligible = Bool.and(Nat.is_ne(reader, 0n), Bool.and(B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()),
    Bool.and(Bool.not(B.has(R.Node.config(B.node(w, reader)), K.CONFIG_CHILDREN_FORBIDDEN())),
      Bool.not(Bool.and(slow, B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))))))
  B.choose(~B.Bundle<R.World, Bool>, eligible,
    _ =>
      +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.and(slow, B.has(R.Node.status(B.node(w, id)), K.STATUS_UNINITIALIZED())),
        _ => B.Bundle{w, False{}}, _ => frameRead(w, reader, id))
      +w = B.first(R.World, Bool, pair)
      B.choose(~B.Bundle<R.World, Bool>, B.second(R.World, Bool, pair), _ => B.Bundle{w, True{}},
        _ => B.Bundle{joinPass(w, reader, id), False{}}),
    _ => B.Bundle{w, False{}})

# core.ts:recompute's held re-entry before frame disposal/parking.
def reenterHeld(+w: R.World, +id: Nat) -> R.World:
  +pair = txOf(w, id)
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  +n = B.node(w, id)
  B.choose(~R.World, Bool.or(R.Transaction.lane(B.transaction(w, t)), B.has(R.Node.config(n), K.CONFIG_LAGS())), _ => w,
    _ => B.choose(~R.World, Bool.not(B.has(R.Node.config(n), B.set(K.CONFIG_VERDICT(), K.CONFIG_FRAME()))),
      _ => joinPassTx(w, t, False{}),
      _ => B.choose(~R.World, Bool.and(Nat.is_ne(t, R.World.flushTransaction(w)), Bool.not(Bool.or(B.has(R.Node.status(n), K.STATUS_UNINITIALIZED()), B.has(R.Node.config(n), K.CONFIG_HELD_FRAME())))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_pending(n, R.Empty{}))
          B.store_node(w, id, R.Node.with_config(B.node(w, id), B.clear(R.Node.config(B.node(w, id)), K.CONFIG_HELD()))),
        _ => w)))
