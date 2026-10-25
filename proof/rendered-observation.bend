# Selected text/application observation for the mounted fixed-graph milestone.
# Mount visibility and arbitrary callback effects require separate contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../observation/tree.bend as T
import ./committed-storage-frame.bend as Committed
import ./list-update-lookup.bend as Lookup

type View is Data:
  View{texts: List<&2, R.Value>, applications: List<&2, R.TraceEvent>}

def shownTexts(view: View) -> List<&2, R.Value>:
  match view:
    case View{texts, applications}: texts

def shownApplications(view: View) -> List<&2, R.TraceEvent>:
  match view:
    case View{texts, applications}: applications

def texts(+targets: List<&2, Nat>, +tree: List<&2, R.TreeNode>) -> List<&2, R.Value>:
  match targets:
    case Nil{}: []
    case target <> rest: R.TreeNode.text(B.get(R.TreeNode, tree, target, B.blank_tree())) <> texts(rest, tree)

def selectedHead(+renderers: List<&2, Nat>, event: R.TraceEvent, +tail: List<&2, R.TraceEvent>) -> List<&2, R.TraceEvent>:
  match event:
    case R.Applied{+id, value, previous}:
      B.choose(~List<&2, R.TraceEvent>, B.contains(renderers, id), _ => R.Applied{id, value, previous} <> tail, _ => tail)
    case other: tail

def applications(+renderers: List<&2, Nat>, events: List<&2, R.TraceEvent>) -> List<&2, R.TraceEvent>:
  match events:
    case Nil{}: []
    case event <> rest: selectedHead(renderers, event, applications(renderers, rest))

def project(renderers: List<&2, Nat>, targets: List<&2, Nat>, view: Committed.View) -> View:
  match view:
    case Committed.View{values, tree, events}: View{texts(targets, tree), applications(renderers, events)}

def observe(renderers: List<&2, Nat>, targets: List<&2, Nat>, w: R.World) -> View:
  project(renderers, targets, Committed.observe(w))

def fromCommitted(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +next: R.World,
  same: {Committed.observe(next) == Committed.observe(w) : Committed.View}) ->
  {observe(renderers, targets, next) == observe(renderers, targets, w) : View}:
  Equal.cong(Committed.View, View, value => project(renderers, targets, value), Committed.observe(next), Committed.observe(w), same)

def compose(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +a: R.World, +b: R.World, +c: R.World,
  second: {observe(renderers, targets, c) == observe(renderers, targets, b) : View},
  first: {observe(renderers, targets, b) == observe(renderers, targets, a) : View}) ->
  {observe(renderers, targets, c) == observe(renderers, targets, a) : View}:
  Equal.trans(View, observe(renderers, targets, c), observe(renderers, targets, b), observe(renderers, targets, a), second, first)

def choice(+condition: Bool, +renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +left: R.World, +right: R.World,
  leftFrame: {observe(renderers, targets, left) == observe(renderers, targets, w) : View},
  rightFrame: {observe(renderers, targets, right) == observe(renderers, targets, w) : View}) ->
  {observe(renderers, targets, B.choose(~R.World, condition, _ => left, _ => right)) == observe(renderers, targets, w) : View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

# Other slots remain unchanged even if a sparse property/tree write grows its
# arena. This needs real target disjointness, not an assumed observation equation.
def textsOther(+targets: List<&2, Nat>, +tree: List<&2, R.TreeNode>, +id: Nat, +node: R.TreeNode,
  +absent: {B.contains(targets, id) == False{} : Bool}) ->
  {texts(targets, B.put(R.TreeNode, tree, id, B.blank_tree(), node)) == texts(targets, tree) : List<&2, R.Value>}:
  match targets:
    case Nil{}: {==}
    case +target <> +rest:
      +different = Lookup.noOrLeft(Nat.is_eq(target, id), B.contains(rest, id), absent)
      +tailAbsent = Lookup.noOrRight(Nat.is_eq(target, id), B.contains(rest, id), absent)
      +updated = B.put(R.TreeNode, tree, id, B.blank_tree(), node)
      Equal.trans(List<&2, R.Value>, R.TreeNode.text(B.get(R.TreeNode, updated, target, B.blank_tree())) <> texts(rest, updated), R.TreeNode.text(B.get(R.TreeNode, tree, target, B.blank_tree())) <> texts(rest, updated), R.TreeNode.text(B.get(R.TreeNode, tree, target, B.blank_tree())) <> texts(rest, tree),
        Equal.cong(R.TreeNode, List<&2, R.Value>, head => R.TreeNode.text(head) <> texts(rest, updated), B.get(R.TreeNode, updated, target, B.blank_tree()), B.get(R.TreeNode, tree, target, B.blank_tree()), Lookup.putOther(R.TreeNode, tree, id, target, B.blank_tree(), node, different)),
        Equal.cong(List<&2, R.Value>, List<&2, R.Value>, tail => R.TreeNode.text(B.get(R.TreeNode, tree, target, B.blank_tree())) <> tail, texts(rest, updated), texts(rest, tree), textsOther(rest, tree, id, node, tailAbsent)))

def applicationOther(+renderers: List<&2, Nat>, +events: List<&2, R.TraceEvent>, +id: Nat, +value: R.Value, +previous: R.Value,
  +absent: {B.contains(renderers, id) == False{} : Bool}) ->
  {applications(renderers, B.append(R.TraceEvent, events, [R.Applied{id, value, previous}])) == applications(renderers, events) : List<&2, R.TraceEvent>}:
  match events:
    case Nil{}:
      Equal.cong(Bool, List<&2, R.TraceEvent>, included => B.choose(~List<&2, R.TraceEvent>, included, _ => [R.Applied{id, value, previous}], _ => []), B.contains(renderers, id), False{}, absent)
    case +event <> +rest:
      Equal.cong(List<&2, R.TraceEvent>, List<&2, R.TraceEvent>, tail => selectedHead(renderers, event, tail), applications(renderers, B.append(R.TraceEvent, rest, [R.Applied{id, value, previous}])), applications(renderers, rest), applicationOther(renderers, rest, id, value, previous, absent))

def storeNode(renderers: List<&2, Nat>, targets: List<&2, Nat>, w: R.World, id: Nat, node: R.Node) ->
  {observe(renderers, targets, B.store_node(w, id, node)) == observe(renderers, targets, w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def textOther(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +id: Nat, +value: R.Value,
  +absent: {B.contains(targets, id) == False{} : Bool}) ->
  {observe(renderers, targets, T.setText(w, id, value)) == observe(renderers, targets, w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Value>, View, values => View{values, applications(renderers, events)}, texts(targets, B.put(R.TreeNode, tree, id, B.blank_tree(), R.TreeNode.with_text(B.get(R.TreeNode, tree, id, B.blank_tree()), value))), texts(targets, tree), textsOther(targets, tree, id, R.TreeNode.with_text(B.get(R.TreeNode, tree, id, B.blank_tree()), value), absent))

def eventOther(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +id: Nat, +value: R.Value, +previous: R.Value,
  +absent: {B.contains(renderers, id) == False{} : Bool}) ->
  {observe(renderers, targets, B.event(w, R.Applied{id, value, previous})) == observe(renderers, targets, w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.TraceEvent>, View, events => View{texts(targets, tree), events}, applications(renderers, B.append(R.TraceEvent, events, [R.Applied{id, value, previous}])), applications(renderers, events), applicationOther(renderers, events, id, value, previous, absent))

def sameNat(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: sameNat(p)

def selfIncluded(+id: Nat) -> {B.contains([id], id) == True{} : Bool}:
  Equal.cong(Bool, Bool, same => Bool.or(same, False{}), Nat.is_eq(id, id), True{}, sameNat(id))

def choiceAppend(+included: Bool, +event: R.TraceEvent, +before: List<&2, R.TraceEvent>, +after: List<&2, R.TraceEvent>) ->
  {B.choose(~List<&2, R.TraceEvent>, included, _ => event <> B.append(R.TraceEvent, before, after), _ => B.append(R.TraceEvent, before, after)) == B.append(R.TraceEvent, B.choose(~List<&2, R.TraceEvent>, included, _ => event <> before, _ => before), after) : List<&2, R.TraceEvent>}:
  match included:
    case True{}: {==}
    case False{}: {==}

def headAppend(+renderers: List<&2, Nat>, event: R.TraceEvent, +before: List<&2, R.TraceEvent>, +after: List<&2, R.TraceEvent>) ->
  {selectedHead(renderers, event, B.append(R.TraceEvent, before, after)) == B.append(R.TraceEvent, selectedHead(renderers, event, before), after) : List<&2, R.TraceEvent>}:
  match event:
    case R.Applied{+id, value, previous}: choiceAppend(B.contains(renderers, id), R.Applied{id, value, previous}, before, after)
    case R.Constructed{created}: {==}
    case R.SetterBound{boundSetter}: {==}
    case R.AccessorBound{boundAccessor}: {==}
    case R.MapRowBound{rowBound}: {==}
    case R.MapIndexBound{indexBound}: {==}
    case R.Invoked{id}: {==}
    case R.ReadValue{reader, source, value}: {==}
    case R.Wrote{id, value}: {==}
    case R.Disposed{id}: {==}
    case R.CleanupObserved{callback, code}: {==}

# This positive contract prevents the application observation from being empty
# or forgetting selected payloads while its frame contracts pass vacuously.
def applicationSelected(+events: List<&2, R.TraceEvent>, +id: Nat, +value: R.Value, +previous: R.Value) ->
  {applications([id], B.append(R.TraceEvent, events, [R.Applied{id, value, previous}])) == B.append(R.TraceEvent, applications([id], events), [R.Applied{id, value, previous}]) : List<&2, R.TraceEvent>}:
  match events:
    case Nil{}:
      Equal.cong(Bool, List<&2, R.TraceEvent>, included => B.choose(~List<&2, R.TraceEvent>, included, _ => [R.Applied{id, value, previous}], _ => []), B.contains([id], id), True{}, selfIncluded(id))
    case +event <> +rest:
      Equal.trans(List<&2, R.TraceEvent>, selectedHead([id], event, applications([id], B.append(R.TraceEvent, rest, [R.Applied{id, value, previous}]))), selectedHead([id], event, B.append(R.TraceEvent, applications([id], rest), [R.Applied{id, value, previous}])), B.append(R.TraceEvent, applications([id], event <> rest), [R.Applied{id, value, previous}]), Equal.cong(List<&2, R.TraceEvent>, List<&2, R.TraceEvent>, tail => selectedHead([id], event, tail), applications([id], B.append(R.TraceEvent, rest, [R.Applied{id, value, previous}])), B.append(R.TraceEvent, applications([id], rest), [R.Applied{id, value, previous}]), applicationSelected(rest, id, value, previous)), headAppend([id], event, applications([id], rest), [R.Applied{id, value, previous}]))

def assignedText(node: R.TreeNode, +value: R.Value) ->
  {R.TreeNode.text(R.TreeNode.with_text(node, value)) == value : R.Value}:
  match node:
    case R.TreeNode{parent, children, old}: {==}

# Actual same-target text storage is visible for every represented payload.
# B.put supplies the real sparse extension; no allocation is fabricated.
def textPresent(renderers: List<&2, Nat>, +w: R.World, +id: Nat, +value: R.Value) ->
  {shownTexts(observe(renderers, [id], T.setText(w, id, value))) == [value] : List<&2, R.Value>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +node = R.TreeNode.with_text(B.get(R.TreeNode, tree, id, B.blank_tree()), value)
      Equal.trans(List<&2, R.Value>, texts([id], B.put(R.TreeNode, tree, id, B.blank_tree(), node)), [R.TreeNode.text(node)], [value], Equal.cong(R.TreeNode, List<&2, R.Value>, found => [R.TreeNode.text(found)], B.get(R.TreeNode, B.put(R.TreeNode, tree, id, B.blank_tree(), node), id, B.blank_tree()), node, Lookup.putSame(R.TreeNode, tree, id, B.blank_tree(), node)), Equal.cong(R.Value, List<&2, R.Value>, text => [text], R.TreeNode.text(node), value, assignedText(B.get(R.TreeNode, tree, id, B.blank_tree()), value)))

def eventPresent(targets: List<&2, Nat>, w: R.World, +id: Nat, +value: R.Value, +previous: R.Value) ->
  {shownApplications(observe([id], targets, B.event(w, R.Applied{id, value, previous}))) == B.append(R.TraceEvent, shownApplications(observe([id], targets, w)), [R.Applied{id, value, previous}]) : List<&2, R.TraceEvent>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      applicationSelected(events, id, value, previous)
