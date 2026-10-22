# Direct owner entry, owner-only mutations and disposal receiver/self forwarding.
# Production profile without hydration IDs or dev/observe hooks.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/construct-state.bend as N
import ../runtime/owner-state.bend as Owner
import ../runtime/owner.bend as O
import ../runtime/constants.bend as K
import ../runtime/ambient.bend as L
import ./context.bend as Existing

type Ambient is Data:
  Ambient{context: Nat, tracking: Bool, running: Bool, scheduled: Bool, depth: Nat, question: R.Question, lane: Nat, pass: Nat}

def ambient(+w: R.World) -> Ambient:
  Ambient{R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.actionDepth(w), R.World.question(w), R.World.passLane(w), R.World.passTx(w)}

# The source's captured head and conditional store are explicit proof-only cuts.
def link_selected(+w: R.World, +parent: Nat, +id: Nat, +head: Nat, nonempty: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_prevSibling(B.node(w, id), 0n))
  +w = B.store_node(w, id, R.Node.with_nextSibling(B.node(w, id), head))
  +w = B.choose(~R.World, nonempty,
    _ => B.store_node(w, head, R.Node.with_prevSibling(B.node(w, head), id)), _ => w)
  B.store_node(w, parent, R.Node.with_firstChild(B.node(w, parent), id))

def link_shape(+w: R.World, +parent: Nat, +id: Nat) ->
  {O.linkChild(w, parent, id) == link_selected(w, parent, id, R.Node.firstChild(B.node(w, parent)), Nat.is_ne(R.Node.firstChild(B.node(w, parent)), 0n)) : R.World}:
  {==}

def selected_link_ambient(+w: R.World, +parent: Nat, +id: Nat, +head: Nat, nonempty: Bool) ->
  {ambient(link_selected(w, parent, id, head, nonempty)) == ambient(w) : Ambient}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState}:
      match nonempty:
        case True{}:
          {==}
        case False{}:
          {==}

def link_ambient(+w: R.World, +parent: Nat, +id: Nat) ->
  {ambient(O.linkChild(w, parent, id)) == ambient(w) : Ambient}:
  Equal.trans(Ambient, ambient(O.linkChild(w, parent, id)), ambient(link_selected(w, parent, id, R.Node.firstChild(B.node(w, parent)), Nat.is_ne(R.Node.firstChild(B.node(w, parent)), 0n))), ambient(w),
    Equal.cong(R.World, Ambient, state => ambient(state), O.linkChild(w, parent, id), link_selected(w, parent, id, R.Node.firstChild(B.node(w, parent)), Nat.is_ne(R.Node.firstChild(B.node(w, parent)), 0n)), link_shape(w, parent, id)),
    selected_link_ambient(w, parent, id, R.Node.firstChild(B.node(w, parent)), Nat.is_ne(R.Node.firstChild(B.node(w, parent)), 0n)))

def allocated(+w: R.World, +parent: Nat, transparent: Bool) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  n = {R.Node{R.Root{}, R.Undefined{}, R.Empty{}, True{}, B.choose(~U32, transparent, _ => K.CONFIG_TRANSPARENT(), _ => 0),
    K.REACTIVE_NONE(), 0, 0n, R.Unstamped{}, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n,
    parent, 0n, 0n, 0n, R.Literal{R.Undefined{}}, False{}, R.Undefined{}, 0n, False{},
    0n, B.parentComputed(w, parent), R.Node.scope(B.node(w, parent)), 0n, R.NoDisposal{}, 0n, 0n, 0n, 0n} : R.Node}
  R.World.with_nodes(w, B.append(R.Node, R.World.nodes(w), [n]))

def owner_selected(+w: R.World, +parent: Nat, transparent: Bool, attached: Bool) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = allocated(w, parent, transparent)
  B.choose(~R.World, attached, _ => O.linkChild(w, parent, id), _ => w)

def owner_shape(+w: R.World, +parent: Nat, transparent: Bool) ->
  {Owner.createOwner(w, parent, transparent) == owner_selected(w, parent, transparent, Nat.is_ne(parent, 0n)) : R.World}:
  {==}

def allocated_ambient(+w: R.World, +parent: Nat, transparent: Bool) ->
  {ambient(allocated(w, parent, transparent)) == ambient(w) : Ambient}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState}:
      {==}

def selected_owner_ambient(+w: R.World, +parent: Nat, +transparent: Bool, attached: Bool) ->
  {ambient(owner_selected(w, parent, transparent, attached)) == ambient(w) : Ambient}:
  match attached:
    case True{}:
      Equal.trans(Ambient, ambient(O.linkChild(allocated(w, parent, transparent), parent, B.length(R.Node, R.World.nodes(w)))), ambient(allocated(w, parent, transparent)), ambient(w), link_ambient(allocated(w, parent, transparent), parent, B.length(R.Node, R.World.nodes(w))), allocated_ambient(w, parent, transparent))
    case False{}:
      allocated_ambient(w, parent, transparent)

def creation_ambient(+w: R.World, +parent: Nat, +transparent: Bool) ->
  {ambient(Owner.createOwner(w, parent, transparent)) == ambient(w) : Ambient}:
  Equal.trans(Ambient, ambient(Owner.createOwner(w, parent, transparent)), ambient(owner_selected(w, parent, transparent, Nat.is_ne(parent, 0n))), ambient(w),
    Equal.cong(R.World, Ambient, state => ambient(state), Owner.createOwner(w, parent, transparent), owner_selected(w, parent, transparent, Nat.is_ne(parent, 0n)), owner_shape(w, parent, transparent)),
    selected_owner_ambient(w, parent, transparent, Nat.is_ne(parent, 0n)))

def entry(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +transparent: Bool, +previous: R.Value) ->
  {C.evaluate(w, rest, stack, R.OwnerCreate{transparent}, previous) == C.Machine{N.createOwner(w, R.World.context(w), transparent), rest, R.OwnerReference{B.length(R.Node, R.World.nodes(w))} <> stack} : C.Machine}:
  {==}

def dispose_selected(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +self: Bool, valid: Bool) -> C.Machine:
  B.choose(~C.Machine, valid,
    _ => C.Machine{w, C.OwnerTasks{[O.Enter{id, self, False{}}]} <> rest, R.Undefined{} <> stack},
    _ => C.Machine{R.World.with_fault(w, R.TypeError{}), rest, stack})

def disposal(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +self: Bool,
  root: {B.root(R.Node.kind(B.node(w, id))) == True{} : Bool}) ->
  {C.disposeRootValue(w, rest, stack, R.OwnerReference{id}, self) == C.Machine{w, C.OwnerTasks{[O.Enter{id, self, False{}}]} <> rest, R.Undefined{} <> stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, valid => dispose_selected(w, rest, stack, id, self, valid), B.root(R.Node.kind(B.node(w, id))), True{}, root)

# Actual public entry/lifecycle execution: detached owner, attached child,
# children-only teardown, reuse, then final death. Existing cleanup driver.
def create_child(+w: R.World) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w, R.WithOwner{R.Literal{R.OwnerReference{2n}}, R.OwnerCreate{True{}}}, R.Undefined{}))

def register(+w: R.World, owner: Nat, callback: Nat) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w, R.WithOwner{R.Literal{R.OwnerReference{owner}}, R.OnCleanup{R.Literal{R.ProgramReference{callback}}}}, R.Undefined{}))

def dispose(+w: R.World, self: Bool) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w, R.DisposeRoot{R.Literal{R.OwnerReference{2n}}, self}, R.Undefined{}))

def prepared() -> R.World:
  w = A.resultWorld(A.evaluateExpression(512n, A.createWorld(), R.OwnerCreate{False{}}, R.Undefined{}))
  w = A.registerProgram(w, A.programEmit(1n, A.emptyProgram()))
  w = A.registerProgram(w, A.programEmit(2n, A.emptyProgram()))
  register(register(create_child(w), 2n, 1n), 3n, 2n)

def cleared() -> R.World:
  dispose(prepared(), False{})

def completed() -> R.World:
  dispose(register(create_child(cleared()), 4n, 2n), True{})

type View is Data:
  View{keptAlive: Bool, oldChildDead: Bool, finalDead: Bool, newChildDead: Bool, children: Nat, cleanups: List<&2, R.TraceEvent>, context: Nat, tracking: Bool, scheduled: Bool, fault: R.Fault}

def lifecycle() -> View:
  +middle = cleared()
  +end = completed()
  View{Bool.not(L.isDisposed(middle, 2n)), L.isDisposed(middle, 3n), L.isDisposed(end, 2n), L.isDisposed(end, 4n), R.Node.firstChild(B.node(end, 2n)), Existing.cleanupEvents(R.World.events(end)), R.World.context(end), R.World.tracking(end), R.World.scheduled(end), R.World.fault(end)}

def lifecycle_complete() -> {lifecycle() == View{True{}, True{}, True{}, True{}, 0n, [R.CleanupObserved{2n, 2n}, R.CleanupObserved{1n, 1n}, R.CleanupObserved{2n, 2n}], 0n, False{}, False{}, R.Healthy{}} : View}:
  {==}
