# General graph-link frame: only intrusive dependency/subscriber pointers,
# links and the epoch may change. Every other represented field is retained.
# No validity, no-duplicate, generation or successful post-state premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ./node-observation-lens.bend as Lens

def clean(node: R.Node) -> R.Node:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      R.Node{n_kind, n_value, n_pending, n_equals, n_config, n_flags, n_status, n_time, n_notified, 0n, 0n, n_depGen, 0n, 0n, n_height, n_nextHeap, n_prevHeap, n_parent, n_firstChild, n_nextSibling, n_prevSibling, n_expr, n_modified, n_prevValue, n_target, n_loading, n_x, n_parentComputed, n_scope, n_childCount, n_disposal, n_cleanup, n_effectProgram, n_returnedCleanup, n_errorProgram}

def observe(w: R.World) -> R.World:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      R.World{Lens.map(R.Node,clean,nodes), [], buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, 0n, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, ambientMarks, deferredArena}

def cleanDeps(+node: R.Node,+value: Nat) -> {clean(R.Node.with_deps(node,value)) == clean(node) : R.Node}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def cleanDepsTail(+node: R.Node,+value: Nat) -> {clean(R.Node.with_depsTail(node,value)) == clean(node) : R.Node}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def cleanSubs(+node: R.Node,+value: Nat) -> {clean(R.Node.with_subs(node,value)) == clean(node) : R.Node}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def cleanSubsTail(+node: R.Node,+value: Nat) -> {clean(R.Node.with_subsTail(node,value)) == clean(node) : R.Node}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def store(+w: R.World,+id: Nat,+row: R.Node,same: {clean(row) == clean(B.node(w,id)) : R.Node}) -> {observe(B.store_node(w,id,row)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2,R.Node>,R.World,rows=>R.World.with_nodes(observe(w),rows),Lens.map(R.Node,clean,List.set(&2,R.Node,nodes,id,row)),Lens.map(R.Node,clean,nodes),Lens.set(R.Node,clean,nodes,id,row,same))

def worldLinks(+w: R.World,+value: List<&2,R.Link>) -> {observe(R.World.with_links(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldEpoch(+w: R.World,+value: Nat) -> {observe(R.World.with_epoch(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def compose(+a: R.World,+b: R.World,+c: R.World,last: {observe(c) == observe(b) : R.World},first: {observe(b) == observe(a) : R.World}) -> {observe(c) == observe(a) : R.World}:
  Equal.trans(R.World,observe(c),observe(b),observe(a),last,first)

def choice(+test: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : R.World},right: {observe(no) == observe(w) : R.World}) -> {observe(B.choose(~R.World,test,_=>yes,_=>no)) == observe(w) : R.World}:
  match test:
    case True{}: left
    case False{}: right

def deps(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_deps(B.node(w,id),value))) == observe(w) : R.World}:
  store(w,id,R.Node.with_deps(B.node(w,id),value),cleanDeps(B.node(w,id),value))

def depsTail(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_depsTail(B.node(w,id),value))) == observe(w) : R.World}:
  store(w,id,R.Node.with_depsTail(B.node(w,id),value),cleanDepsTail(B.node(w,id),value))

def subs(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_subs(B.node(w,id),value))) == observe(w) : R.World}:
  store(w,id,R.Node.with_subs(B.node(w,id),value),cleanSubs(B.node(w,id),value))

def subsTail(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_subsTail(B.node(w,id),value))) == observe(w) : R.World}:
  store(w,id,R.Node.with_subsTail(B.node(w,id),value),cleanSubsTail(B.node(w,id),value))

def storeLink(+w: R.World,+id: Nat,+row: R.Link) -> {observe(B.store_link(w,id,row)) == observe(w) : R.World}:
  worldLinks(w,List.set(&2,R.Link,R.World.links(w),id,row))

def bump(+w: R.World) -> {observe(B.bump(w)) == observe(w) : R.World}:
  worldEpoch(w,1n+R.World.epoch(w))

# Source allocation stores, including both nonempty intrusive-list branches.
def begin(+w: R.World,+dep: Nat,+sub: Nat,+prevDep: Nat,+nextDep: Nat,+prevSub: Nat) -> R.World:
  R.World.with_links(w,B.append(R.Link,R.World.links(w),[R.Link{dep,sub,nextDep,prevSub,0n,R.Node.depGen(B.node(w,sub))}]))

def depStore(+w: R.World,+sub: Nat,+previous: Nat,+id: Nat) -> R.World:
  B.choose(~R.World,Nat.is_ne(previous,0n),_=>B.store_link(w,previous,R.Link.with_nextDep(B.link(w,previous),id)),_=>B.store_node(w,sub,R.Node.with_deps(B.node(w,sub),id)))

def subStore(+w: R.World,+dep: Nat,+previous: Nat,+id: Nat) -> R.World:
  B.choose(~R.World,Nat.is_ne(previous,0n),_=>B.store_link(w,previous,R.Link.with_nextSub(B.link(w,previous),id)),_=>B.store_node(w,dep,R.Node.with_subs(B.node(w,dep),id)))

def depStored(+w: R.World,+sub: Nat,+previous: Nat,+id: Nat) -> {observe(depStore(w,sub,previous,id)) == observe(w) : R.World}:
  choice(Nat.is_ne(previous,0n),w,B.store_link(w,previous,R.Link.with_nextDep(B.link(w,previous),id)),B.store_node(w,sub,R.Node.with_deps(B.node(w,sub),id)),storeLink(w,previous,R.Link.with_nextDep(B.link(w,previous),id)),deps(w,sub,id))

def subStored(+w: R.World,+dep: Nat,+previous: Nat,+id: Nat) -> {observe(subStore(w,dep,previous,id)) == observe(w) : R.World}:
  choice(Nat.is_ne(previous,0n),w,B.store_link(w,previous,R.Link.with_nextSub(B.link(w,previous),id)),B.store_node(w,dep,R.Node.with_subs(B.node(w,dep),id)),storeLink(w,previous,R.Link.with_nextSub(B.link(w,previous),id)),subs(w,dep,id))

def allocate(+w: R.World,+dep: Nat,+sub: Nat,+prevDep: Nat,+nextDep: Nat,+prevSub: Nat) -> {observe(G.allocate(w,dep,sub,prevDep,nextDep,prevSub)) == observe(w) : R.World}:
  +id = B.length(R.Link,R.World.links(w))
  +start = begin(w,dep,sub,prevDep,nextDep,prevSub)
  +first = B.store_node(start,sub,R.Node.with_depsTail(B.node(start,sub),id))
  +second = B.store_node(first,dep,R.Node.with_subsTail(B.node(first,dep),id))
  +third = depStore(second,sub,prevDep,id)
  +fourth = subStore(third,dep,prevSub,id)
  compose(w,start,G.allocate(w,dep,sub,prevDep,nextDep,prevSub),compose(start,first,G.allocate(w,dep,sub,prevDep,nextDep,prevSub),compose(first,second,G.allocate(w,dep,sub,prevDep,nextDep,prevSub),compose(second,third,G.allocate(w,dep,sub,prevDep,nextDep,prevSub),compose(third,fourth,G.allocate(w,dep,sub,prevDep,nextDep,prevSub),bump(fourth),subStored(third,dep,prevSub,id)),depStored(second,sub,prevDep,id)),subsTail(first,dep,id)),depsTail(start,sub,id)),worldLinks(w,B.append(R.Link,R.World.links(w),[R.Link{dep,sub,nextDep,prevSub,0n,R.Node.depGen(B.node(w,sub))}])))

def append(+w: R.World,+dep: Nat,+sub: Nat,+prevDep: Nat,+nextDep: Nat,+recomputing: Bool) -> {observe(G.append_or_duplicate(w,dep,sub,prevDep,nextDep,recomputing)) == observe(w) : R.World}:
  +tail = R.Node.subsTail(B.node(w,dep))
  +edge = B.link(w,tail)
  +duplicate = Bool.and(Nat.is_ne(tail,0n),Bool.and(Nat.is_eq(R.Link.sub(edge),sub),Bool.or(Bool.not(recomputing),Nat.is_eq(R.Link.gen(edge),R.Node.depGen(B.node(w,sub))))))
  choice(duplicate,w,w,G.allocate(w,dep,sub,prevDep,nextDep,tail),{==},allocate(w,dep,sub,prevDep,nextDep,tail))

def nodeLinks(+w: R.World,+id: Nat,+links: List<&2,R.Link>) -> {B.node(R.World.with_links(w,links),id) == B.node(w,id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def reused(+w: R.World,+sub: Nat,+nextDep: Nat) -> {observe(B.store_node(B.store_link(w,nextDep,R.Link.with_gen(B.link(w,nextDep),R.Node.depGen(B.node(w,sub)))),sub,R.Node.with_depsTail(B.node(w,sub),nextDep))) == observe(w) : R.World}:
  +links = List.set(&2,R.Link,R.World.links(w),nextDep,R.Link.with_gen(B.link(w,nextDep),R.Node.depGen(B.node(w,sub))))
  +first = B.store_link(w,nextDep,R.Link.with_gen(B.link(w,nextDep),R.Node.depGen(B.node(w,sub))))
  +known = Equal.trans(R.Node,clean(R.Node.with_depsTail(B.node(w,sub),nextDep)),clean(B.node(w,sub)),clean(B.node(first,sub)),cleanDepsTail(B.node(w,sub),nextDep),Equal.cong(R.Node,R.Node,row=>clean(row),B.node(w,sub),B.node(first,sub),Equal.sym(R.Node,B.node(first,sub),B.node(w,sub),nodeLinks(w,sub,links))))
  compose(w,first,B.store_node(first,sub,R.Node.with_depsTail(B.node(w,sub),nextDep)),store(first,sub,R.Node.with_depsTail(B.node(w,sub),nextDep),known),storeLink(w,nextDep,R.Link.with_gen(B.link(w,nextDep),R.Node.depGen(B.node(w,sub)))))

def reuse(+w: R.World,+dep: Nat,+sub: Nat,+prevDep: Nat,+nextDep: Nat,+recomputing: Bool) -> {observe(G.reuse_or_append(w,dep,sub,prevDep,nextDep,recomputing)) == observe(w) : R.World}:
  +same = Bool.and(recomputing,Bool.and(Nat.is_ne(nextDep,0n),Nat.is_eq(R.Link.dep(B.link(w,nextDep)),dep)))
  +first = B.store_link(w,nextDep,R.Link.with_gen(B.link(w,nextDep),R.Node.depGen(B.node(w,sub))))
  choice(same,w,B.store_node(first,sub,R.Node.with_depsTail(B.node(w,sub),nextDep)),G.append_or_duplicate(w,dep,sub,prevDep,nextDep,recomputing),reused(w,sub,nextDep),append(w,dep,sub,prevDep,nextDep,recomputing))

def link(+w: R.World,+dep: Nat,+sub: Nat) -> {observe(G.link(w,dep,sub)) == observe(w) : R.World}:
  +prev = R.Node.depsTail(B.node(w,sub))
  +recomputing = B.has(R.Node.flags(B.node(w,sub)),4)
  +next = B.choose(~Nat,recomputing,_=>B.choose(~Nat,Nat.is_ne(prev,0n),_=>R.Link.nextDep(B.link(w,prev)),_=>R.Node.deps(B.node(w,sub))),_=>0n)
  choice(Bool.and(Nat.is_ne(prev,0n),Nat.is_eq(R.Link.dep(B.link(w,prev)),dep)),w,w,G.reuse_or_append(w,dep,sub,prev,next,recomputing),{==},reuse(w,dep,sub,prev,next,recomputing))
