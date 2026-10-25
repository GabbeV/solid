# Actual held join/default-comparison setter helpers preserve the committed
# observation. Custom callback invocation and lane/override writes are separate
# active-core paths and are not replaced by this callback-free theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as X
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ./action-resume-frame.bend as Frame
import ./observer-write-frame.bend as Observer

def resolveChoice(+condition: Bool, +w: R.World, +id: Nat, +other: B.Bundle<R.World, Nat>,
  otherFrame: {Frame.observe(B.first(R.World, Nat, other)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(B.first(R.World, Nat, B.choose(~B.Bundle<R.World, Nat>, condition, _ => B.Bundle{w, id}, _ => other))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: {==}
    case False{}: otherFrame

def resolveLoop(+fuel: Nat, +w: R.World, +id: Nat) ->
  {Frame.observe(B.first(R.World, Nat, X.resolveLoop(fuel, w, id))) == Frame.observe(w) : Frame.View}:
  match fuel:
    case 0n: Frame.worldFault(w, R.Exhausted{})
    case 1n+p:
      +into = R.Transaction.into(B.transaction(w, id))
      resolveChoice(Nat.is_eq(into, 0n), w, id, X.resolveLoop(p, w, into), resolveLoop(p, w, into))

def resolve(+w: R.World, +id: Nat) ->
  {Frame.observe(B.first(R.World, Nat, X.resolveTx(w, id))) == Frame.observe(w) : Frame.View}:
  resolveLoop(1n+B.length(R.Transaction, R.World.txArena(w)), w, id)

def mergeStores(+w: R.World, +t: Nat, +f: Nat) -> R.World:
  +from = B.transaction(w, t)
  +into = B.transaction(w, f)
  +w = B.store_transaction(w, t, R.Transaction.with_into(from, f))
  +into = R.Transaction.with_open(into, Nat.add(R.Transaction.open(into), R.Transaction.open(from)))
  +into = R.Transaction.with_acted(into, Bool.or(R.Transaction.acted(into), R.Transaction.acted(from)))
  +into = R.Transaction.with_nodes(into, B.append(Nat, R.Transaction.nodes(into), R.Transaction.nodes(from)))
  +into = R.Transaction.with_renderQueue(into, B.append(Nat, R.Transaction.renderQueue(into), R.Transaction.renderQueue(from)))
  +into = R.Transaction.with_userQueue(into, B.append(R.QueueEntry, R.Transaction.userQueue(into), R.Transaction.userQueue(from)))
  +into = R.Transaction.with_reruns(into, B.append(Nat, R.Transaction.reruns(into), R.Transaction.reruns(from)))
  +into = R.Transaction.with_marks(into, X.appendMarks(R.Transaction.marks(into), R.Transaction.marks(from)))
  +w = B.store_transaction(w, f, into)
  R.World.with_transactions(w, X.removeIdentity(R.World.transactions(w), t))

def transferred(+from: R.Transaction, +into: R.Transaction) -> R.Transaction:
  +into = R.Transaction.with_open(into, Nat.add(R.Transaction.open(into), R.Transaction.open(from)))
  +into = R.Transaction.with_acted(into, Bool.or(R.Transaction.acted(into), R.Transaction.acted(from)))
  +into = R.Transaction.with_nodes(into, B.append(Nat, R.Transaction.nodes(into), R.Transaction.nodes(from)))
  +into = R.Transaction.with_renderQueue(into, B.append(Nat, R.Transaction.renderQueue(into), R.Transaction.renderQueue(from)))
  +into = R.Transaction.with_userQueue(into, B.append(R.QueueEntry, R.Transaction.userQueue(into), R.Transaction.userQueue(from)))
  +into = R.Transaction.with_reruns(into, B.append(Nat, R.Transaction.reruns(into), R.Transaction.reruns(from)))
  R.Transaction.with_marks(into, X.appendMarks(R.Transaction.marks(into), R.Transaction.marks(from)))

def mergeStoresFrame(+w: R.World, +t: Nat, +f: Nat) ->
  {Frame.observe(mergeStores(w, t, f)) == Frame.observe(w) : Frame.View}:
  +from = B.transaction(w, t)
  +into = B.transaction(w, f)
  +first = B.store_transaction(w, t, R.Transaction.with_into(from, f))
  +nextRecord = transferred(from, into)
  +second = B.store_transaction(first, f, nextRecord)
  Frame.compose(w, first, mergeStores(w, t, f),
    Frame.compose(first, second, mergeStores(w, t, f), Frame.worldTransactions(second, X.removeIdentity(R.World.transactions(second), t)), Frame.storeTransaction(first, f, nextRecord)), Frame.storeTransaction(w, t, R.Transaction.with_into(from, f)))

def mergeResolved(+w: R.World, +t: Nat, +f: Nat) ->
  {Frame.observe(X.mergeResolved(w, t, f)) == Frame.observe(w) : Frame.View}:
  Frame.choice(Bool.or(Nat.is_eq(t, f), Bool.or(R.Transaction.lane(B.transaction(w, t)), R.Transaction.lane(B.transaction(w, f)))), w, w, mergeStores(w, t, f), {==}, mergeStoresFrame(w, t, f))

def merge(+w: R.World, +t: Nat, +f: Nat) ->
  {Frame.observe(X.merge(w, t, f)) == Frame.observe(w) : Frame.View}:
  +first = X.resolveTx(w, t)
  +afterFirst = B.first(R.World, Nat, first)
  +second = X.resolveTx(afterFirst, f)
  +afterSecond = B.first(R.World, Nat, second)
  Frame.compose(w, afterFirst, X.merge(w, t, f),
    Frame.compose(afterFirst, afterSecond, X.merge(w, t, f), mergeResolved(afterSecond, B.second(R.World, Nat, first), B.second(R.World, Nat, second)), resolve(afterFirst, f)), resolve(w, t))

def newTransaction(+w: R.World, +lane: Bool, +parent: Nat) ->
  {Frame.observe(B.first(R.World, Nat, X.newTransaction(w, lane, parent))) == Frame.observe(w) : Frame.View}:
  +id = B.length(R.Transaction, R.World.txArena(w))
  +record = {R.Transaction{[], [], [], [], 0n, parent, lane, 0n, 0n, False{}, 0n, False{}, False{}, R.NoIds{}} : R.Transaction}
  +arena = B.append(R.Transaction, R.World.txArena(w), [record])
  +next = R.World.with_txArena(w, arena)
  +listed = R.World.with_transactions(next, B.append(Nat, R.World.transactions(next), [id]))
  Frame.compose(w, next, B.first(R.World, Nat, X.newTransaction(w, lane, parent)), Frame.choice(lane, next, next, listed, {==}, Frame.worldTransactions(next, B.append(Nat, R.World.transactions(next), [id]))), Frame.worldTxArena(w, arena))

def bundleChoice(+condition: Bool, +w: R.World, +left: B.Bundle<R.World, Nat>, +right: B.Bundle<R.World, Nat>,
  leftFrame: {Frame.observe(B.first(R.World, Nat, left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(B.first(R.World, Nat, right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(B.first(R.World, Nat, B.choose(~B.Bundle<R.World, Nat>, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def freshFuture(+w: R.World, +t: Nat) -> R.World:
  +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(t, 0n), _ => X.newTransaction(w, False{}, 0n), _ => X.resolveTx(w, t))
  R.World.with_flushTransaction(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair))

def freshFutureFrame(+w: R.World, +t: Nat) ->
  {Frame.observe(freshFuture(w, t)) == Frame.observe(w) : Frame.View}:
  +pair = B.choose(~B.Bundle<R.World, Nat>, Nat.is_eq(t, 0n), _ => X.newTransaction(w, False{}, 0n), _ => X.resolveTx(w, t))
  +next = B.first(R.World, Nat, pair)
  Frame.compose(w, next, freshFuture(w, t), Frame.worldFlushTransaction(next, B.second(R.World, Nat, pair)),
    bundleChoice(Nat.is_eq(t, 0n), w, X.newTransaction(w, False{}, 0n), X.resolveTx(w, t), newTransaction(w, False{}, 0n), resolve(w, t)))

def joinFuture(+w: R.World, +t: Nat) ->
  {Frame.observe(X.joinFuture(w, t)) == Frame.observe(w) : Frame.View}:
  +f = R.World.flushTransaction(w)
  +joined = B.choose(~R.World, Nat.is_eq(t, 0n), _ => w, _ => X.merge(w, t, f))
  +next = B.choose(~R.World, Nat.is_eq(f, 0n), _ => freshFuture(w, t), _ => joined)
  Frame.compose(w, next, X.joinFuture(w, t), Frame.choice(R.World.running(next), next, next, B.schedule(next), {==}, Frame.schedule(next)),
    Frame.choice(Nat.is_eq(f, 0n), w, freshFuture(w, t), joined, freshFutureFrame(w, t), Frame.choice(Nat.is_eq(t, 0n), w, w, X.merge(w, t, f), {==}, merge(w, t, f))))
