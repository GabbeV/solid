# Actual arena/x/range facts needed by repeated single-carrier cycles.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./pending-fresh-set.bend as Fresh
import ./pending-carrier-retirement.bend as Retire
import ./pending-carrier-existing.bend as Existing
import ./pending-auxiliary-lookup.bend as Aux
import ./node-store-lookup.bend as Store
import ./arena.bend as Arena

def extensionStorage(+w: R.World, +id: Nat, +record: R.NodeExtension) ->
  {R.World.pendingSets(B.store_extension(w, id, record)) == R.World.pendingSets(w) : List<&2, List<&2, Nat>>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def pendingStorage(+w: R.World, +set: Nat, +items: List<&2, Nat>) ->
  {R.World.pendingSets(B.store_pendingSet(w, set, items)) == List.set(&2, List<&2, Nat>, R.World.pendingSets(w), set, items) : List<&2, List<&2, Nat>>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def grownStorage(+w: R.World) ->
  {R.World.pendingSets(Fresh.grown(w)) == B.append(List<&2, Nat>, R.World.pendingSets(w), [[]]) : List<&2, List<&2, Nat>>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storedRoom(+w: R.World, +set: Nat, +items: List<&2, Nat>, +read: Nat) ->
  {Nat.is_lt(read, B.length(List<&2, Nat>, R.World.pendingSets(B.store_pendingSet(w, set, items)))) == Nat.is_lt(read, B.length(List<&2, Nat>, R.World.pendingSets(w))) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(Nat, Bool, size => Nat.is_lt(read, size), B.length(List<&2, Nat>, List.set(&2, List<&2, Nat>, pendingSets, set, items)), B.length(List<&2, Nat>, pendingSets), Store.lengthSet(List<&2, Nat>, pendingSets, set, items))

def createdArena(+w: R.World, +id: Nat, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.World.pendingSets(Fresh.created(w, id)) == [] <> B.append(List<&2, Nat>, sets, [[]]) : List<&2, List<&2, Nat>>}:
  Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(Fresh.created(w, id)), R.World.pendingSets(Fresh.grown(w)), [] <> B.append(List<&2, Nat>, sets, [[]]), extensionStorage(Fresh.grown(w), id, Fresh.record(w, id)), Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(Fresh.grown(w)), B.append(List<&2, Nat>, R.World.pendingSets(w), [[]]), [] <> B.append(List<&2, Nat>, sets, [[]]), grownStorage(w), Equal.cong(List<&2, List<&2, Nat>>, List<&2, List<&2, Nat>>, values => B.append(List<&2, Nat>, values, [[]]), R.World.pendingSets(w), [] <> sets, known)))

def canonicalArena(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.World.pendingSets(Fresh.canonical(w, id, source, sets)) == [] <> B.append(List<&2, Nat>, sets, [[source]]) : List<&2, List<&2, Nat>>}:
  +next = Fresh.created(w, id)
  Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(Fresh.canonical(w, id, source, sets)), List.set(&2, List<&2, Nat>, R.World.pendingSets(next), 1n+B.length(List<&2, Nat>, sets), [source]), [] <> B.append(List<&2, Nat>, sets, [[source]]), pendingStorage(next, 1n+B.length(List<&2, Nat>, sets), [source]),
    Equal.trans(List<&2, List<&2, Nat>>, List.set(&2, List<&2, Nat>, R.World.pendingSets(next), 1n+B.length(List<&2, Nat>, sets), [source]), [] <> List.set(&2, List<&2, Nat>, B.append(List<&2, Nat>, sets, [[]]), B.length(List<&2, Nat>, sets), [source]), [] <> B.append(List<&2, Nat>, sets, [[source]]), Equal.cong(List<&2, List<&2, Nat>>, List<&2, List<&2, Nat>>, values => List.set(&2, List<&2, Nat>, values, 1n+B.length(List<&2, Nat>, sets), [source]), R.World.pendingSets(next), [] <> B.append(List<&2, Nat>, sets, [[]]), createdArena(w, id, sets, known)), Equal.cong(List<&2, List<&2, Nat>>, List<&2, List<&2, Nat>>, values => [] <> values, List.set(&2, List<&2, Nat>, B.append(List<&2, Nat>, sets, [[]]), B.length(List<&2, Nat>, sets), [source]), B.append(List<&2, Nat>, sets, [[source]]), Arena.setPrefix(List<&2, Nat>, sets, [], [], [source]))))

def createdX(+w: R.World, +id: Nat) -> {R.Node.x(B.node(Fresh.created(w, id), id)) == R.Node.x(B.node(w, id)) : Nat}:
  Equal.trans(Nat, R.Node.x(B.node(Fresh.created(w, id), id)), R.Node.x(B.node(Fresh.grown(w), id)), R.Node.x(B.node(w, id)), Aux.extensionX(Fresh.grown(w), id, Fresh.record(w, id), id), Aux.pendingX(w, B.append(List<&2, Nat>, R.World.pendingSets(w), [[]]), id))

def canonicalX(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>) -> {R.Node.x(B.node(Fresh.canonical(w, id, source, sets), id)) == R.Node.x(B.node(w, id)) : Nat}:
  Equal.trans(Nat, R.Node.x(B.node(Fresh.canonical(w, id, source, sets), id)), R.Node.x(B.node(Fresh.created(w, id), id)), R.Node.x(B.node(w, id)), Existing.storedX(Fresh.created(w, id), 1n+B.length(List<&2, Nat>, sets), [source], id), createdX(w, id))

def canonicalRoom(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {Nat.is_lt(1n+B.length(List<&2, Nat>, sets), B.length(List<&2, Nat>, R.World.pendingSets(Fresh.canonical(w, id, source, sets)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(1n+B.length(List<&2, Nat>, sets), B.length(List<&2, Nat>, R.World.pendingSets(Fresh.canonical(w, id, source, sets)))), Nat.is_lt(1n+B.length(List<&2, Nat>, sets), B.length(List<&2, Nat>, R.World.pendingSets(Fresh.created(w, id)))), True{}, storedRoom(Fresh.created(w, id), 1n+B.length(List<&2, Nat>, sets), [source], 1n+B.length(List<&2, Nat>, sets)), Fresh.createdRoom(w, id, sets, known))

def retiredArena(+w: R.World, +id: Nat, +set: Nat, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.World.pendingSets(Retire.retired(w, id, 1n+set)) == [] <> List.set(&2, List<&2, Nat>, sets, set, [0n]) : List<&2, List<&2, Nat>>}:
  +next = B.store_pendingSet(w, 1n+set, [0n])
  Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(Retire.retired(w, id, 1n+set)), R.World.pendingSets(next), [] <> List.set(&2, List<&2, Nat>, sets, set, [0n]), extensionStorage(next, id, R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)), Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(next), List.set(&2, List<&2, Nat>, R.World.pendingSets(w), 1n+set, [0n]), [] <> List.set(&2, List<&2, Nat>, sets, set, [0n]), pendingStorage(w, 1n+set, [0n]), Equal.cong(List<&2, List<&2, Nat>>, List<&2, List<&2, Nat>>, values => List.set(&2, List<&2, Nat>, values, 1n+set, [0n]), R.World.pendingSets(w), [] <> sets, known)))

def retiredX(+w: R.World, +id: Nat, +set: Nat) -> {R.Node.x(B.node(Retire.retired(w, id, 1n+set), id)) == R.Node.x(B.node(w, id)) : Nat}:
  +next = B.store_pendingSet(w, 1n+set, [0n])
  Equal.trans(Nat, R.Node.x(B.node(Retire.retired(w, id, 1n+set), id)), R.Node.x(B.node(next, id)), R.Node.x(B.node(w, id)), Aux.extensionX(next, id, R.NodeExtension.with_pendingSources(B.extension(next, id), 0n), id), Existing.storedX(w, 1n+set, [0n], id))

def retiredExtRoom(+w: R.World, +id: Nat, +set: Nat, fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {Nat.is_lt(R.Node.x(B.node(Retire.retired(w, id, 1n+set), id)), B.length(R.NodeExtension, R.World.extensions(Retire.retired(w, id, 1n+set)))) == True{} : Bool}:
  +next = B.store_pendingSet(w, 1n+set, [0n])
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(Retire.retired(w, id, 1n+set), id)), B.length(R.NodeExtension, R.World.extensions(Retire.retired(w, id, 1n+set)))), Nat.is_lt(R.Node.x(B.node(next, id)), B.length(R.NodeExtension, R.World.extensions(next))), True{}, Aux.extensionRoom(next, id, R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)), Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(next, id)), B.length(R.NodeExtension, R.World.extensions(next))), Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))), True{}, Aux.pendingRoom(w, List.set(&2, List<&2, Nat>, R.World.pendingSets(w), 1n+set, [0n]), id), fits))
