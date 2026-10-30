# Actual scheduler list ownership construction for an existing extension and a
# freshly captured nonzero ordinary group. No source implementation is replaced.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/extension.bend as E
import ../runtime/constants.bend as K
import ./allocated-slots.bend as Slots
import ./arena.bend as Arena
import ./transaction-arena.bend as TxArena
import ./transaction-resolution.bend as Paths
import ./transaction-rendered.bend as Graph
import ./pending-rendered-snapshot.bend as Snapshot
import ./rendered-completion-history.bend as History

def capture(+w: R.World, +id: Nat, tx: Nat) -> R.World:
  B.store_extension(w, id, R.NodeExtension.with_transaction(B.extension(w, id), tx))

def appendOwned(+w: R.World, +id: Nat, +tx: Nat) -> R.World:
  B.store_transaction(w, tx, R.Transaction.with_nodes(B.transaction(w, tx), B.append(Nat, R.Transaction.nodes(B.transaction(w, tx)), [id])))

def raw(w: R.World, +id: Nat, +tx: Nat) -> R.World:
  appendOwned(capture(w, id, tx), id, tx)

def afterExt(+w: R.World, +id: Nat, +tx: Nat, current: Nat) -> R.World:
  B.choose(~R.World, Nat.is_eq(current, tx), _ => w, _ => raw(w, id, tx))

def existing(+w: R.World, +id: Nat, +slot: Nat,
  known: {R.Node.x(B.node(w, id)) == 1n+slot : Nat}) -> {E.ext(w, id) == w : R.World}:
  Equal.cong(Nat, R.World, x => B.choose(~R.World, Nat.is_ne(x, 0n), _ => w,
    _ =>
      +next = B.length(R.NodeExtension, R.World.extensions(w))
      +w = R.World.with_extensions(w, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]))
      B.store_node(w, id, R.Node.with_x(B.node(w, id), next))), R.Node.x(B.node(w, id)), 1n+slot, known)

def fresh(+w: R.World, +id: Nat, +predecessor: Nat, +slot: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+slot : Nat},
  unowned: {R.NodeExtension.transaction(B.extension(w, id)) == 0n : Nat}) ->
  {X.list(w, id, 1n+predecessor) == raw(w, id, 1n+predecessor) : R.World}:
  Equal.trans(R.World, X.list(w, id, 1n+predecessor), afterExt(w, id, 1n+predecessor, R.NodeExtension.transaction(B.extension(w, id))), raw(w, id, 1n+predecessor),
    Equal.cong(R.World, R.World, state => afterExt(state, id, 1n+predecessor, R.NodeExtension.transaction(B.extension(state, id))), E.ext(w, id), w, existing(w, id, slot, allocated)),
    Equal.cong(Nat, R.World, current => afterExt(w, id, 1n+predecessor, current), R.NodeExtension.transaction(B.extension(w, id)), 0n, unowned))


def nodeRaw(+w: R.World, +id: Nat, +tx: Nat, +reader: Nat) ->
  {B.node(raw(w, id, tx), reader) == B.node(w, reader) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def nodesRaw(+w: R.World, +id: Nat, +tx: Nat) ->
  {R.World.nodes(raw(w, id, tx)) == R.World.nodes(w) : List<&2, R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def healthyRaw(+w: R.World, +id: Nat, +tx: Nat) ->
  {B.ok(raw(w, id, tx)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def transactionCapture(+w: R.World, +id: Nat, +tx: Nat, +reader: Nat) ->
  {B.transaction(capture(w, id, tx), reader) == B.transaction(w, reader) : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def arenaCapture(+w: R.World, +id: Nat, +tx: Nat) ->
  {R.World.txArena(capture(w, id, tx)) == R.World.txArena(w) : List<&2, R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def extensionAppend(+w: R.World, +id: Nat, +tx: Nat, +reader: Nat) ->
  {B.extension(appendOwned(w, id, tx), reader) == B.extension(w, reader) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def nodeExtensions(+w: R.World, +id: Nat, +values: List<&2, R.NodeExtension>) ->
  {B.node(R.World.with_extensions(w, values), id) == B.node(w, id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def fieldExtensions(+w: R.World, +values: List<&2, R.NodeExtension>) ->
  {R.World.extensions(R.World.with_extensions(w, values)) == values : List<&2, R.NodeExtension>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def putReadTransaction(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>, +next: R.Transaction,
  storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}) ->
  {B.transaction(B.store_transaction(w, B.length(R.Transaction, before), next), B.length(R.Transaction, before)) == next : R.Transaction}:
  Equal.trans(R.Transaction, B.transaction(B.store_transaction(w, B.length(R.Transaction, before), next), B.length(R.Transaction, before)), B.transaction(R.World.with_txArena(w, B.append(R.Transaction, before, next <> after)), B.length(R.Transaction, before)), next,
    Equal.cong(R.World, R.Transaction, state => B.transaction(state, B.length(R.Transaction, before)), B.store_transaction(w, B.length(R.Transaction, before), next), R.World.with_txArena(w, B.append(R.Transaction, before, next <> after)), Slots.putTransaction(w, before, record, after, next, storage)), TxArena.peek(w, before, next, after))

def appendedRecord(+w: R.World, +id: Nat, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  +storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}) ->
  {B.transaction(appendOwned(w, id, B.length(R.Transaction, before)), B.length(R.Transaction, before)) == R.Transaction.with_nodes(record, B.append(Nat, R.Transaction.nodes(record), [id])) : R.Transaction}:
  +tx = B.length(R.Transaction, before)
  +next = R.Transaction.with_nodes(record, B.append(Nat, R.Transaction.nodes(record), [id]))
  Equal.trans(R.Transaction, B.transaction(appendOwned(w, id, tx), tx), B.transaction(B.store_transaction(w, tx, next), tx), next,
    Equal.cong(R.Transaction, R.Transaction, old => B.transaction(B.store_transaction(w, tx, R.Transaction.with_nodes(old, B.append(Nat, R.Transaction.nodes(old), [id]))), tx), B.transaction(w, tx), record, Slots.transaction(w, before, record, after, storage)), putReadTransaction(w, before, record, after, next, storage))

def rawRecord(+w: R.World, +id: Nat, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>}) ->
  {B.transaction(raw(w, id, B.length(R.Transaction, before)), B.length(R.Transaction, before)) == R.Transaction.with_nodes(record, B.append(Nat, R.Transaction.nodes(record), [id])) : R.Transaction}:
  appendedRecord(capture(w, id, B.length(R.Transaction, before)), id, before, record, after,
    Equal.trans(List<&2, R.Transaction>, R.World.txArena(capture(w, id, B.length(R.Transaction, before))), R.World.txArena(w), B.append(R.Transaction, before, record <> after), arenaCapture(w, id, B.length(R.Transaction, before)), storage))

def extensionSetArena(+w: R.World, +id: Nat, +before: List<&2, R.NodeExtension>, +record: R.NodeExtension, +after: List<&2, R.NodeExtension>,
  index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, before) : Nat}) ->
  {B.extension(R.World.with_extensions(w, B.append(R.NodeExtension, before, record <> after)), id) == record : R.NodeExtension}:
  +values = B.append(R.NodeExtension, before, record <> after)
  Slots.extension(R.World.with_extensions(w, values), id, before, record, after,
    Equal.trans(Nat, R.Node.x(B.node(R.World.with_extensions(w, values), id)), R.Node.x(B.node(w, id)), B.length(R.NodeExtension, before), Equal.cong(R.Node, Nat, n => R.Node.x(n), B.node(R.World.with_extensions(w, values), id), B.node(w, id), nodeExtensions(w, id, values)), index), fieldExtensions(w, values))

def capturedRecord(+w: R.World, +id: Nat, +tx: Nat, +before: List<&2, R.NodeExtension>, +record: R.NodeExtension, +after: List<&2, R.NodeExtension>,
  +index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, before) : Nat},
  +storage: {R.World.extensions(w) == B.append(R.NodeExtension, before, record <> after) : List<&2, R.NodeExtension>}) ->
  {B.extension(capture(w, id, tx), id) == R.NodeExtension.with_transaction(record, tx) : R.NodeExtension}:
  +next = R.NodeExtension.with_transaction(record, tx)
  Equal.trans(R.NodeExtension, B.extension(capture(w, id, tx), id), B.extension(B.store_extension(w, id, next), id), next,
    Equal.cong(R.NodeExtension, R.NodeExtension, old => B.extension(B.store_extension(w, id, R.NodeExtension.with_transaction(old, tx)), id), B.extension(w, id), record, Slots.extension(w, id, before, record, after, index, storage)),
    Equal.trans(R.NodeExtension, B.extension(B.store_extension(w, id, next), id), B.extension(R.World.with_extensions(w, B.append(R.NodeExtension, before, next <> after)), id), next,
      Equal.cong(R.World, R.NodeExtension, state => B.extension(state, id), B.store_extension(w, id, next), R.World.with_extensions(w, B.append(R.NodeExtension, before, next <> after)), Slots.putExtension(w, id, before, record, after, next, index, storage)), extensionSetArena(w, id, before, next, after, index)))

def rawExtension(+w: R.World, +id: Nat, +tx: Nat, +before: List<&2, R.NodeExtension>, +record: R.NodeExtension, +after: List<&2, R.NodeExtension>,
  index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, before) : Nat},
  storage: {R.World.extensions(w) == B.append(R.NodeExtension, before, record <> after) : List<&2, R.NodeExtension>}) ->
  {B.extension(raw(w, id, tx), id) == R.NodeExtension.with_transaction(record, tx) : R.NodeExtension}:
  Equal.trans(R.NodeExtension, B.extension(raw(w, id, tx), id), B.extension(capture(w, id, tx), id), R.NodeExtension.with_transaction(record, tx), extensionAppend(capture(w, id, tx), id, tx, id), capturedRecord(w, id, tx, before, record, after, index, storage))

def ownerSet(+record: R.NodeExtension, +tx: Nat) ->
  {R.NodeExtension.transaction(R.NodeExtension.with_transaction(record, tx)) == tx : Nat}:
  match record:
    case R.NodeExtension{inFlight, flightTeardown, error, blocked, pendingSources, unobserved, snapshotValue, pendingFirstChild, pendingDisposal, transaction, reask, flushed, flushedAt, q, lane, marks, shownError, +parkedFlight}: {==}

def nodesSet(+record: R.Transaction, +nodes: List<&2, Nat>) ->
  {R.Transaction.nodes(R.Transaction.with_nodes(record, nodes)) == nodes : List<&2, Nat>}:
  match record:
    case R.Transaction{old, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def intoSet(+record: R.Transaction, +nodes: List<&2, Nat>) ->
  {R.Transaction.into(R.Transaction.with_nodes(record, nodes)) == R.Transaction.into(record) : Nat}:
  match record:
    case R.Transaction{old, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

# Only node storage is needed to transport the excluded prefix. Capturing a
# transaction intentionally changes an extension, so a whole graph identity
# would be the wrong premise here.
def guardArray(+w: R.World, +next: R.World, +id: Nat,
  same: {R.World.nodes(next) == R.World.nodes(w) : List<&2, R.Node>}) ->
  {Graph.guard(next, id) == Graph.guard(w, id) : Bool}:
  Equal.cong(List<&2, R.Node>, Bool, nodes => Snapshot.guardNode(B.get(R.Node, nodes, id, B.blank_node())), R.World.nodes(next), R.World.nodes(w), same)

def prefixArray(+w: R.World, +next: R.World, +owner: Nat, prefix: Graph.Skips<w, owner>,
  +same: {R.World.nodes(next) == R.World.nodes(w) : List<&2, R.Node>}) -> Graph.Skips<next, owner>:
  match prefix:
    case Graph.NoSkips{}: Graph.NoSkips{}
    case Graph.Skip{+id, inactive, rest}:
      Graph.Skip{id, Equal.trans(Bool, Graph.guard(next, id), Graph.guard(w, id), True{}, guardArray(w, next, id, same), inactive), prefixArray(w, next, owner, rest, same)}

def prefixIds(+w: R.World, +next: R.World, +owner: Nat, +prefix: Graph.Skips<w, owner>,
  +same: {R.World.nodes(next) == R.World.nodes(w) : List<&2, R.Node>}) ->
  {Graph.ids(next, owner, prefixArray(w, next, owner, prefix, same)) == Graph.ids(w, owner, prefix) : List<&2, Nat>}:
  match prefix:
    case Graph.NoSkips{}: {==}
    case Graph.Skip{+id, inactive, +rest}:
      Equal.cong(List<&2, Nat>, List<&2, Nat>, ids => id <> ids, Graph.ids(next, owner, prefixArray(w, next, owner, rest, same)), Graph.ids(w, owner, rest), prefixIds(w, next, owner, rest, same))

def rawSnapshot(+w: R.World, +id: Nat, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  +extBefore: List<&2, R.NodeExtension>, +extRecord: R.NodeExtension, +extAfter: List<&2, R.NodeExtension>,
  +prefix: Graph.Skips<w, B.length(R.Transaction, before)>,
  storage: {R.World.txArena(w) == B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>},
  index: {R.Node.x(B.node(w, id)) == B.length(R.NodeExtension, extBefore) : Nat},
  extStorage: {R.World.extensions(w) == B.append(R.NodeExtension, extBefore, extRecord <> extAfter) : List<&2, R.NodeExtension>},
  owns: {R.Transaction.nodes(record) == Graph.ids(w, B.length(R.Transaction, before), prefix) : List<&2, Nat>},
  active: {Graph.guard(w, id) == False{} : Bool},
  stopped: {R.Transaction.into(record) == 0n : Nat},
  rendered: {X.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  Snapshot.Pending<raw(w, id, B.length(R.Transaction, before)), B.length(R.Transaction, before)>:
  +tx = B.length(R.Transaction, before)
  +next = raw(w, id, tx)
  +nextPrefix = prefixArray(w, next, tx, prefix, nodesRaw(w, id, tx))
  +nextRecord = R.Transaction.with_nodes(record, B.append(Nat, R.Transaction.nodes(record), [id]))
  +group = rawRecord(w, id, before, record, after, storage)
  Snapshot.Pending{nextPrefix, id, [],
    Equal.trans(List<&2, Nat>, R.Transaction.nodes(B.transaction(next, tx)), B.append(Nat, R.Transaction.nodes(record), [id]), B.append(Nat, Graph.ids(next, tx, nextPrefix), [id]),
      Equal.trans(List<&2, Nat>, R.Transaction.nodes(B.transaction(next, tx)), R.Transaction.nodes(nextRecord), B.append(Nat, R.Transaction.nodes(record), [id]), Equal.cong(R.Transaction, List<&2, Nat>, entry => R.Transaction.nodes(entry), B.transaction(next, tx), nextRecord, group), nodesSet(record, B.append(Nat, R.Transaction.nodes(record), [id]))),
      Equal.trans(List<&2, Nat>, B.append(Nat, R.Transaction.nodes(record), [id]), B.append(Nat, Graph.ids(w, tx, prefix), [id]), B.append(Nat, Graph.ids(next, tx, nextPrefix), [id]),
        Equal.cong(List<&2, Nat>, List<&2, Nat>, nodes => B.append(Nat, nodes, [id]), R.Transaction.nodes(record), Graph.ids(w, tx, prefix), owns),
        Equal.cong(List<&2, Nat>, List<&2, Nat>, nodes => B.append(Nat, nodes, [id]), Graph.ids(w, tx, prefix), Graph.ids(next, tx, nextPrefix), Equal.sym(List<&2, Nat>, Graph.ids(next, tx, nextPrefix), Graph.ids(w, tx, prefix), prefixIds(w, next, tx, prefix, nodesRaw(w, id, tx)))))),
    Equal.trans(Bool, Graph.guard(next, id), Graph.guard(w, id), False{}, guardArray(w, next, id, nodesRaw(w, id, tx)), active),
    Equal.trans(Nat, R.NodeExtension.transaction(B.extension(next, id)), R.NodeExtension.transaction(R.NodeExtension.with_transaction(extRecord, tx)), tx, Equal.cong(R.NodeExtension, Nat, entry => R.NodeExtension.transaction(entry), B.extension(next, id), R.NodeExtension.with_transaction(extRecord, tx), rawExtension(w, id, tx, extBefore, extRecord, extAfter, index, extStorage)), ownerSet(extRecord, tx)),
    Equal.trans(Nat, R.Transaction.into(B.transaction(next, tx)), R.Transaction.into(record), 0n,
      Equal.trans(Nat, R.Transaction.into(B.transaction(next, tx)), R.Transaction.into(nextRecord), R.Transaction.into(record), Equal.cong(R.Transaction, Nat, entry => R.Transaction.into(entry), B.transaction(next, tx), nextRecord, group), intoSet(record, B.append(Nat, R.Transaction.nodes(record), [id]))), stopped),
    Equal.trans(Bool, X.isRender(R.Node.kind(B.node(next, id))), X.isRender(R.Node.kind(B.node(w, id))), True{}, Equal.cong(R.Node, Bool, n => X.isRender(R.Node.kind(n)), B.node(next, id), B.node(w, id), nodeRaw(w, id, tx, id)), rendered),
    Equal.trans(Bool, B.has(R.Node.flags(B.node(next, id)), K.REACTIVE_ZOMBIE()), B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()), False{}, Equal.cong(R.Node, Bool, n => B.has(R.Node.flags(n), K.REACTIVE_ZOMBIE()), B.node(next, id), B.node(w, id), nodeRaw(w, id, tx, id)), live)}

def substitute(-a: R.World, -b: R.World, -owner: Nat, same: {a == b : R.World}, snapshot: Snapshot.Pending<a, owner>) -> Snapshot.Pending<b, owner>:
  %same : Snapshot.Pending<_, owner>
  snapshot

# Reserved sentinel heads make both real allocated identities nonzero. The
# constructor supplies final membership/owned layout; callers supply the earlier
# pending-render/status snapshot and valid physical storage positions.
def pending(+w: R.World, +id: Nat, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  +extBefore: List<&2, R.NodeExtension>, +extRecord: R.NodeExtension, +extAfter: List<&2, R.NodeExtension>,
  +prefix: Graph.Skips<w, 1n+B.length(R.Transaction, before)>,
  storage: {R.World.txArena(w) == B.blank_transaction() <> B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>},
  +index: {R.Node.x(B.node(w, id)) == 1n+B.length(R.NodeExtension, extBefore) : Nat},
  +extStorage: {R.World.extensions(w) == B.blank_extension() <> B.append(R.NodeExtension, extBefore, extRecord <> extAfter) : List<&2, R.NodeExtension>},
  unowned: {R.NodeExtension.transaction(extRecord) == 0n : Nat},
  owns: {R.Transaction.nodes(record) == Graph.ids(w, 1n+B.length(R.Transaction, before), prefix) : List<&2, Nat>},
  active: {Graph.guard(w, id) == False{} : Bool},
  stopped: {R.Transaction.into(record) == 0n : Nat},
  rendered: {X.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool}) ->
  Snapshot.Pending<X.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before)>:
  +tx = {1n+B.length(R.Transaction, before) : Nat}
  substitute(raw(w, id, tx), X.list(w, id, tx), tx,
    Equal.sym(R.World, X.list(w, id, tx), raw(w, id, tx), fresh(w, id, B.length(R.Transaction, before), B.length(R.NodeExtension, extBefore), index,
      Equal.trans(Nat, R.NodeExtension.transaction(B.extension(w, id)), R.NodeExtension.transaction(extRecord), 0n, Equal.cong(R.NodeExtension, Nat, entry => R.NodeExtension.transaction(entry), B.extension(w, id), extRecord, Slots.extension(w, id, B.blank_extension() <> extBefore, extRecord, extAfter, index, extStorage)), unowned))),
    rawSnapshot(w, id, B.blank_transaction() <> before, record, after, B.blank_extension() <> extBefore, extRecord, extAfter, prefix, storage, index, extStorage, owns, active, stopped, rendered, live))

def listedHealthy(+w: R.World, +id: Nat, +predecessor: Nat, +slot: Nat,
  index: {R.Node.x(B.node(w, id)) == 1n+slot : Nat},
  unowned: {R.NodeExtension.transaction(B.extension(w, id)) == 0n : Nat}) ->
  {B.ok(X.list(w, id, 1n+predecessor)) == B.ok(w) : Bool}:
  Equal.trans(Bool, B.ok(X.list(w, id, 1n+predecessor)), B.ok(raw(w, id, 1n+predecessor)), B.ok(w),
    Equal.cong(R.World, Bool, state => B.ok(state), X.list(w, id, 1n+predecessor), raw(w, id, 1n+predecessor), fresh(w, id, predecessor, slot, index, unowned)), healthyRaw(w, id, 1n+predecessor))


def beginHistory(+w: R.World, +id: Nat, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>,
  +extBefore: List<&2, R.NodeExtension>, +extRecord: R.NodeExtension, +extAfter: List<&2, R.NodeExtension>,
  +prefix: Graph.Skips<w, 1n+B.length(R.Transaction, before)>,
  storage: {R.World.txArena(w) == B.blank_transaction() <> B.append(R.Transaction, before, record <> after) : List<&2, R.Transaction>},
  +index: {R.Node.x(B.node(w, id)) == 1n+B.length(R.NodeExtension, extBefore) : Nat},
  +extStorage: {R.World.extensions(w) == B.blank_extension() <> B.append(R.NodeExtension, extBefore, extRecord <> extAfter) : List<&2, R.NodeExtension>},
  +unowned: {R.NodeExtension.transaction(extRecord) == 0n : Nat},
  owns: {R.Transaction.nodes(record) == Graph.ids(w, 1n+B.length(R.Transaction, before), prefix) : List<&2, Nat>},
  active: {Graph.guard(w, id) == False{} : Bool},
  stopped: {R.Transaction.into(record) == 0n : Nat},
  rendered: {X.isRender(R.Node.kind(B.node(w, id))) == True{} : Bool},
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_ZOMBIE()) == False{} : Bool},
  +healthy: {B.ok(w) == True{} : Bool},
  +programme: History.Programme<X.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before)>) ->
  History.Certified<X.list(w, id, 1n+B.length(R.Transaction, before)), 1n+B.length(R.Transaction, before), programme>:
  History.certify(X.list(w, id, 1n+B.length(R.Transaction, before)), B.length(R.Transaction, before), programme,
    pending(w, id, before, record, after, extBefore, extRecord, extAfter, prefix, storage, index, extStorage, unowned, owns, active, stopped, rendered, live),
    Equal.trans(Bool, B.ok(X.list(w, id, 1n+B.length(R.Transaction, before))), B.ok(w), True{},
      listedHealthy(w, id, B.length(R.Transaction, before), B.length(R.NodeExtension, extBefore), index,
        Equal.trans(Nat, R.NodeExtension.transaction(B.extension(w, id)), R.NodeExtension.transaction(extRecord), 0n,
          Equal.cong(R.NodeExtension, Nat, entry => R.NodeExtension.transaction(entry), B.extension(w, id), extRecord, Slots.extension(w, id, B.blank_extension() <> extBefore, extRecord, extAfter, index, extStorage)), unowned)), healthy))

# A repeated list call is the source's exact no-op. This local identity does
# not infer reachable list membership merely from an arbitrary captured field.
def repeated(+w: R.World, +id: Nat, +tx: Nat, +slot: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+slot : Nat},
  capture: {R.NodeExtension.transaction(B.extension(w, id)) == tx : Nat}) ->
  {X.list(w, id, tx) == w : R.World}:
  Equal.trans(R.World, X.list(w, id, tx), afterExt(w, id, tx, R.NodeExtension.transaction(B.extension(w, id))), w,
    Equal.cong(R.World, R.World, state => afterExt(state, id, tx, R.NodeExtension.transaction(B.extension(state, id))), E.ext(w, id), w, existing(w, id, slot, allocated)),
    Equal.trans(R.World, afterExt(w, id, tx, R.NodeExtension.transaction(B.extension(w, id))), afterExt(w, id, tx, tx), w,
      Equal.cong(Nat, R.World, current => afterExt(w, id, tx, current), R.NodeExtension.transaction(B.extension(w, id)), tx, capture),
      Equal.cong(Bool, R.World, same => B.choose(~R.World, same, _ => w, _ => raw(w, id, tx)), Nat.is_eq(tx, tx), True{}, Paths.sameNat(tx))))
