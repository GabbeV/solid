# Actual callback-free source settlement traversal. This observation is committed
# storage/tree/trace, not a promise that source status, lists, or queues are fixed.
# Owner release/callback execution is an explicit separate boundary.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q
import ../runtime/heap.bend as H
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./committed-storage-frame.bend as Frame
import ./pending-source-committed-frame.bend as Source
import ./heap-committed-frame.bend as Heap
import ./setter-committed-frame.bend as Setter

def world(machine: Q.Machine) -> R.World:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: w

def choice(+condition: Bool, +w: R.World, +left: Q.Machine, +right: Q.Machine,
  leftFrame: {Frame.observe(world(left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(world(right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(world(B.choose(~Q.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def retry(+fuel: Nat, +w: R.World, +edge: Nat, +source: Nat) ->
  {Frame.observe(B.first(R.World, Bool, P.retryLoop(fuel, w, edge, source))) == Frame.observe(w) : Frame.View}:
  match fuel:
    case 0n:
      Frame.choice(Nat.is_eq(edge, 0n), w, w, R.World.with_fault(w, R.Exhausted{}), {==}, Frame.worldFault(w, R.Exhausted{}))
    case 1n+p:
      +dep = R.Link.dep(B.link(w, edge))
      +pair = B.choose(~B.Bundle<R.World, Bool>, Bool.or(Nat.is_eq(dep, source), P.hasSource(w, dep, source)), _ => B.Bundle{w, True{}}, _ => P.retryLoop(p, w, R.Link.nextDep(B.link(w, edge)), source))
      Frame.firstBoolChoice(Nat.is_eq(edge, 0n), w, B.Bundle{w, False{}}, pair, {==},
        Frame.firstBoolChoice(Bool.or(Nat.is_eq(dep, source), P.hasSource(w, dep, source)), w, B.Bundle{w, True{}}, P.retryLoop(p, w, R.Link.nextDep(B.link(w, edge)), source), {==}, retry(p, w, R.Link.nextDep(B.link(w, edge)), source)))

def skip(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat) ->
  {Frame.observe(world(Q.skip(w, tasks, visited, released, scheduled, id))) == Frame.observe(w) : Frame.View}:
  Frame.choice(B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT()), w, H.enqueueSub(w, id), w, Heap.enqueue(w, id), {==})

# Source settled(): clear the status only for the last carrier, then possibly
# join the existing transaction. Joining is bookkeeping; it does not publish.
def clear(+w: R.World, +id: Nat, +errored: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_status(B.node(w, id), B.clear(R.Node.status(B.node(w, id)), K.STATUS_PENDING())))
  +w = B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, 0n, R.Undefined{}))
  B.choose(~R.World, B.has(R.Node.config(B.node(w, id)), K.CONFIG_HELD()), _ => X.joinNode(w, id), _ => w)

def clearFrame(+w: R.World, +id: Nat, +errored: Bool) ->
  {Frame.observe(clear(w, id, errored)) == Frame.observe(w) : Frame.View}:
  +status = B.clear(R.Node.status(B.node(w, id)), K.STATUS_PENDING())
  +first = B.store_node(w, id, R.Node.with_status(B.node(w, id), status))
  +second = B.choose(~R.World, errored, _ => first, _ => P.setPendingError(first, id, 0n, R.Undefined{}))
  Frame.compose(w, first, clear(w, id, errored),
    Frame.compose(first, second, clear(w, id, errored),
      Frame.choice(B.has(R.Node.config(B.node(second, id)), K.CONFIG_HELD()), second, X.joinNode(second, id), second, Setter.joinNode(second, id), {==}),
      Frame.choice(errored, first, first, P.setPendingError(first, id, 0n, R.Undefined{}), {==}, Source.setError(first, id, 0n, R.Undefined{}))), Frame.status(w, id, status))

def status(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) -> R.World:
  B.choose(~R.World, Nat.is_ne(remaining, 0n), _ => B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, remaining, R.Undefined{})), _ => clear(w, id, errored))

def statusFrame(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) ->
  {Frame.observe(status(w, id, remaining, errored)) == Frame.observe(w) : Frame.View}:
  Frame.choice(Nat.is_ne(remaining, 0n), w, B.choose(~R.World, errored, _ => w, _ => P.setPendingError(w, id, remaining, R.Undefined{})), clear(w, id, errored),
    Frame.choice(errored, w, w, P.setPendingError(w, id, remaining, R.Undefined{}), {==}, Source.setError(w, id, remaining, R.Undefined{})), clearFrame(w, id, errored))

def unblock(+w: R.World, +id: Nat, +last: Bool) -> R.World:
  B.choose(~R.World, Bool.and(B.ok(w), Bool.and(last, Nat.is_ne(R.Node.x(B.node(w, id)), 0n))),
    _ => B.store_extension(w, id, R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})), _ => w)

def unblockFrame(+w: R.World, +id: Nat, +last: Bool) ->
  {Frame.observe(unblock(w, id, last)) == Frame.observe(w) : Frame.View}:
  +record = R.NodeExtension.with_blocked(B.extension(w, id), R.Present{R.Boolean{False{}}})
  Frame.choice(Bool.and(B.ok(w), Bool.and(last, Nat.is_ne(R.Node.x(B.node(w, id)), 0n))), w, B.store_extension(w, id, record), w, Frame.storeExtension(w, id, record), {==})

def statusExact(w: R.World, id: Nat, remaining: Nat, errored: Bool) ->
  {Q.settledStatus(w, id, remaining, errored) == status(w, id, remaining, errored) : R.World}:
  {==}

def actualStatus(+w: R.World, +id: Nat, +remaining: Nat, +errored: Bool) ->
  {Frame.observe(Q.settledStatus(w, id, remaining, errored)) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(Q.settledStatus(w, id, remaining, errored)), Frame.observe(status(w, id, remaining, errored)), Frame.observe(w), Equal.cong(R.World, Frame.View, next => Frame.observe(next), Q.settledStatus(w, id, remaining, errored), status(w, id, remaining, errored), statusExact(w, id, remaining, errored)), statusFrame(w, id, remaining, errored))

def tail(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat, +last: Bool) ->
  {Frame.observe(world(Q.settledTail(w, tasks, visited, released, scheduled, id, root, source, last))) == Frame.observe(w) : Frame.View}:
  +blocked = Bool.and(last, B.truth(B.selected(R.NodeExtension.blocked(B.extension(w, id)), R.Undefined{})))
  +next = B.choose(~R.World, Bool.and(B.ok(w), blocked), _ => H.enqueueSub(w, id), _ => w)
  Frame.compose(w, next, world(Q.settledTail(w, tasks, visited, released, scheduled, id, root, source, last)), unblockFrame(next, id, last), Frame.choice(Bool.and(B.ok(w), blocked), w, H.enqueueSub(w, id), w, Heap.enqueue(w, id), {==}))

def settled(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.settled(w, tasks, visited, released, scheduled, id, root, source))) == Frame.observe(w) : Frame.View}:
  +timed = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  +remaining = B.get(Nat, P.items(B.pendingSources(timed, id)), 0n, 0n)
  +errored = B.has(R.Node.status(B.node(timed, id)), K.STATUS_ERROR())
  +statused = Q.settledStatus(timed, id, remaining, errored)
  Frame.compose(w, timed, world(Q.settled(w, tasks, visited, released, scheduled, id, root, source)),
    Frame.compose(timed, statused, world(Q.settled(w, tasks, visited, released, scheduled, id, root, source)), tail(statused, tasks, id <> visited, released, scheduled, id, root, source, Nat.is_eq(remaining, 0n)), actualStatus(timed, id, remaining, errored)), Frame.time(w, id, R.World.clock(w)))

def removed(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.visitRemoved(w, tasks, visited, released, scheduled, id, root, source))) == Frame.observe(w) : Frame.View}:
  +pair = P.removePendingSource(w, id, source)
  +next = B.first(R.World, Bool, pair)
  Frame.compose(w, next, world(Q.visitRemoved(w, tasks, visited, released, scheduled, id, root, source)),
    choice(B.second(R.World, Bool, pair), next, Q.settled(next, tasks, visited, released, scheduled, id, root, source), Q.skip(next, tasks, visited, released, scheduled, id), settled(next, tasks, visited, released, scheduled, id, root, source), skip(next, tasks, visited, released, scheduled, id)), Source.remove(w, id, source))

# The real dependency retry scan can fault on a malformed/exhausted graph. The
# observation frame still holds; this root does not assert successful traversal.
def visit(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {Frame.observe(world(Q.advance(w, Q.Visit{id, root, source} <> tasks, visited, released, scheduled))) == Frame.observe(w) : Frame.View}:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(source, root), _ => P.retryReaches(w, id, source), _ => B.Bundle{w, False{}})
  +next = B.first(R.World, Bool, pair)
  +reached = B.choose(~Q.Machine, B.second(R.World, Bool, pair), _ => Q.skip(next, tasks, visited, released, scheduled, id), _ => Q.visitRemoved(next, tasks, visited, released, scheduled, id, root, source))
  choice(B.contains(visited, id), w, Q.skip(w, tasks, visited, released, scheduled, id), reached, skip(w, tasks, visited, released, scheduled, id),
    Frame.compose(w, next, world(reached), choice(B.second(R.World, Bool, pair), next, Q.skip(next, tasks, visited, released, scheduled, id), Q.visitRemoved(next, tasks, visited, released, scheduled, id, root, source), skip(next, tasks, visited, released, scheduled, id), removed(next, tasks, visited, released, scheduled, id, root, source)),
      Frame.firstBoolChoice(Nat.is_ne(source, root), w, P.retryReaches(w, id, source), B.Bundle{w, False{}}, retry(B.budget(w), w, R.Node.deps(B.node(w, id)), source), {==})))

def advance(+w: R.World, +tasks: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +scheduled: Bool) ->
  {Frame.observe(world(Q.advance(w, tasks, visited, released, scheduled))) == Frame.observe(w) : Frame.View}:
  match tasks:
    case Nil{}: {==}
    case Q.Visit{+id, +root, +source} <> +rest: visit(w, rest, visited, released, scheduled, id, root, source)
    case Q.Walk{+edge, +root, +source} <> +rest:
      choice(Nat.is_eq(edge, 0n), w, Q.Machine{w, rest, visited, released, scheduled}, Q.Machine{w, Q.Visit{R.Link.sub(B.link(w, edge)), root, source} <> Q.Next{edge, root, source} <> rest, visited, released, scheduled}, {==}, {==})
    case Q.Next{edge, root, source} <> rest: {==}
    case Q.Collect{+id} <> +rest:
      choice(B.contains(visited, id), w, Q.Machine{w, rest, visited, released, scheduled},
        Q.Machine{w, Q.CollectWalk{R.Node.subs(B.node(w, id))} <> rest, id <> visited, B.choose(~List<&2, Nat>, Bool.and(Nat.is_eq(R.Node.subs(B.node(w, id)), 0n), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE())), _ => B.append(Nat, released, [id]), _ => released), scheduled}, {==}, {==})
    case Q.CollectWalk{+edge} <> +rest:
      choice(Nat.is_eq(edge, 0n), w, Q.Machine{w, rest, visited, released, scheduled}, Q.Machine{w, Q.Collect{R.Link.sub(B.link(w, edge))} <> Q.CollectNext{edge} <> rest, visited, released, scheduled}, {==}, {==})
    case Q.CollectNext{edge} <> rest: {==}
    case Q.End{} <> rest: Frame.choice(scheduled, w, B.schedule(w), w, Frame.schedule(w), {==})
    case Q.Release{index} <> rest: Frame.worldFault(w, R.TypeError{})

def begin(+w: R.World, +id: Nat, +source: Nat) ->
  {Frame.observe(world(Q.beginSettlement(w, id, source))) == Frame.observe(w) : Frame.View}:
  Source.remove(w, id, source)
