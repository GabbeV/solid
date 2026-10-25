# Source graph pointer creation changes dependencies/subscribers, not cached
# data or the visible tree/application trace. No callback is executed here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ./committed-storage-frame.bend as Frame
import ./graph-empty-allocation.bend as Allocation
import ./graph-fresh-link.bend as Fresh


def valueDepsTail(+node: R.Node, +value: Nat) ->
  {R.Node.value(R.Node.with_depsTail(node, value)) == R.Node.value(node) : R.Value}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def valueSubsTail(+node: R.Node, +value: Nat) ->
  {R.Node.value(R.Node.with_subsTail(node, value)) == R.Node.value(node) : R.Value}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def valueDeps(+node: R.Node, +value: Nat) ->
  {R.Node.value(R.Node.with_deps(node, value)) == R.Node.value(node) : R.Value}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def valueSubs(+node: R.Node, +value: Nat) ->
  {R.Node.value(R.Node.with_subs(node, value)) == R.Node.value(node) : R.Value}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def worldLinks(+w: R.World, +value: List<&2, R.Link>) ->
  {Frame.observe(R.World.with_links(w, value)) == Frame.observe(w) : Frame.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldEpoch(+w: R.World, +value: Nat) ->
  {Frame.observe(R.World.with_epoch(w, value)) == Frame.observe(w) : Frame.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def first(+w: R.World, +leaf: Nat, +edge: Nat) -> {Frame.observe(Allocation.first(w, leaf, edge)) == Frame.observe(w) : Frame.View}:
  Frame.store(w, leaf, R.Node.with_depsTail(B.node(w, leaf), edge), valueDepsTail(B.node(w, leaf), edge))

def second(+w: R.World, +root: Nat, +edge: Nat) -> {Frame.observe(Allocation.second(w, root, edge)) == Frame.observe(w) : Frame.View}:
  Frame.store(w, root, R.Node.with_subsTail(B.node(w, root), edge), valueSubsTail(B.node(w, root), edge))

def third(+w: R.World, +leaf: Nat, +edge: Nat) -> {Frame.observe(Allocation.third(w, leaf, edge)) == Frame.observe(w) : Frame.View}:
  Frame.store(w, leaf, R.Node.with_deps(B.node(w, leaf), edge), valueDeps(B.node(w, leaf), edge))

def fourth(+w: R.World, +root: Nat, +edge: Nat) -> {Frame.observe(Allocation.fourth(w, root, edge)) == Frame.observe(w) : Frame.View}:
  Frame.store(w, root, R.Node.with_subs(B.node(w, root), edge), valueSubs(B.node(w, root), edge))

def writes(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) -> {Frame.observe(Allocation.writes(w, root, leaf, edge)) == Frame.observe(w) : Frame.View}:
  +one = Allocation.first(w, leaf, edge)
  +two = Allocation.second(one, root, edge)
  +three = Allocation.third(two, leaf, edge)
  +four = Allocation.fourth(three, root, edge)
  Frame.compose(w, one, Allocation.writes(w, root, leaf, edge), Frame.compose(one, two, Allocation.writes(w, root, leaf, edge), Frame.compose(two, three, Allocation.writes(w, root, leaf, edge), Frame.compose(three, four, Allocation.writes(w, root, leaf, edge), worldEpoch(four, 1n+R.World.epoch(four)), fourth(three, root, edge)), third(two, leaf, edge)), second(one, root, edge)), first(w, leaf, edge))

def allocate(+w: R.World, +root: Nat, +leaf: Nat) -> {Frame.observe(Allocation.source(w, root, leaf)) == Frame.observe(w) : Frame.View}:
  +next = Allocation.appended(w, root, leaf)
  +last = Allocation.writes(next, root, leaf, Allocation.index(w))
  Equal.trans(Frame.View, Frame.observe(Allocation.source(w, root, leaf)), Frame.observe(last), Frame.observe(w), Equal.cong(R.World, Frame.View, state => Frame.observe(state), Allocation.source(w, root, leaf), last, Allocation.exact(w, root, leaf)), Frame.compose(w, next, last, writes(next, root, leaf, Allocation.index(w)), worldLinks(w, B.append(R.Link, R.World.links(w), [Allocation.record(w, root, leaf)]))))

def linked(+w: R.World, +root: Nat, +leaf: Nat, previous: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, empty: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) ->
  {Frame.observe(G.link(w, root, leaf)) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(G.link(w, root, leaf)), Frame.observe(Allocation.source(w, root, leaf)), Frame.observe(w), Equal.cong(R.World, Frame.View, state => Frame.observe(state), G.link(w, root, leaf), Allocation.source(w, root, leaf), Fresh.freshEmptyDependencies(w, root, leaf, previous, deps, empty)), allocate(w, root, leaf))
