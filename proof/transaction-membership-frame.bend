# Removing membership arrays retains action counts and scheduling identities.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../proof/transaction-list-construction.bend as Listed

def mask(record: R.Transaction) -> R.Transaction:
  R.Transaction.with_nodes(record,[])

def rows(arena: List<&2,R.Transaction>) -> List<&2,R.Transaction>:
  match arena:
    case Nil{}: []
    case head <> tail: mask(head) <> rows(tail)

def observe(w: R.World) -> List<&2,R.Transaction>:
  rows(R.World.txArena(w))

def setRows(+arena: List<&2,R.Transaction>,+id: Nat,+record: R.Transaction,same: {mask(record) == mask(B.get(R.Transaction,arena,id,B.blank_transaction())) : R.Transaction}) -> {rows(List.set(&2,R.Transaction,arena,id,record)) == rows(arena) : List<&2,R.Transaction>}:
  match arena id:
    case Nil{} n: {==}
    case head <> +tail 0n:
      Equal.cong(R.Transaction,List<&2,R.Transaction>,entry=>entry <> rows(tail),mask(record),mask(head),same)
    case +head <> +tail 1n+p:
      Equal.cong(List<&2,R.Transaction>,List<&2,R.Transaction>,rest=>mask(head) <> rest,rows(List.set(&2,R.Transaction,tail,p,record)),rows(tail),setRows(tail,p,record,same))

def maskNodes(+record: R.Transaction,nodes: List<&2,Nat>) -> {mask(R.Transaction.with_nodes(record,nodes)) == mask(record) : R.Transaction}:
  match record:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def storeNode(+w: R.World,id: Nat,record: R.Node) -> {observe(B.store_node(w,id,record)) == observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeExtension(+w: R.World,id: Nat,record: R.NodeExtension) -> {observe(B.store_extension(w,id,record)) == observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensions(+w: R.World,records: List<&2,R.NodeExtension>) -> {observe(R.World.with_extensions(w,records)) == observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fault(+w: R.World,cause: R.Fault) -> {observe(R.World.with_fault(w,cause)) == observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeTransaction(+w: R.World,+id: Nat,+record: R.Transaction,same: {mask(record) == mask(B.transaction(w,id)) : R.Transaction}) -> {observe(B.store_transaction(w,id,record)) == observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setRows(txArena,id,record,same)

def compose(+w: R.World,+middle: R.World,+next: R.World,left: {observe(next) == observe(middle) : List<&2,R.Transaction>},right: {observe(middle) == observe(w) : List<&2,R.Transaction>}) -> {observe(next) == observe(w) : List<&2,R.Transaction>}:
  Equal.trans(List<&2,R.Transaction>,observe(next),observe(middle),observe(w),left,right)

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : List<&2,R.Transaction>},right: {observe(no) == observe(w) : List<&2,R.Transaction>}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no)) == observe(w) : List<&2,R.Transaction>}:
  match flag:
    case True{}: left
    case False{}: right

def extended(+w: R.World,+id: Nat) -> {observe(E.ext(w,id)) == observe(w) : List<&2,R.Transaction>}:
  +grown = R.World.with_extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))
  +next = B.store_node(grown,id,R.Node.with_x(B.node(grown,id),B.length(R.NodeExtension,R.World.extensions(w))))
  choice(Nat.is_ne(R.Node.x(B.node(w,id)),0n),w,w,next,{==},compose(w,grown,next,storeNode(grown,id,R.Node.with_x(B.node(grown,id),B.length(R.NodeExtension,R.World.extensions(w)))),extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))))

def appendOwned(+w: R.World,+id: Nat,+tx: Nat) -> {observe(Listed.appendOwned(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  storeTransaction(w,tx,R.Transaction.with_nodes(B.transaction(w,tx),B.append(Nat,R.Transaction.nodes(B.transaction(w,tx)),[id])),maskNodes(B.transaction(w,tx),B.append(Nat,R.Transaction.nodes(B.transaction(w,tx)),[id])))

def raw(+w: R.World,+id: Nat,+tx: Nat) -> {observe(Listed.raw(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  +next = Listed.capture(w,id,tx)
  compose(w,next,Listed.raw(w,id,tx),appendOwned(next,id,tx),storeExtension(w,id,R.NodeExtension.with_transaction(B.extension(w,id),tx)))

def list(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.list(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  +next = E.ext(w,id)
  compose(w,next,X.list(w,id,tx),choice(Nat.is_eq(R.NodeExtension.transaction(B.extension(next,id)),tx),next,next,Listed.raw(next,id,tx),{==},raw(next,id,tx)),extended(w,id))

def node(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.holdNode(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  +record = R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD()))
  +next = B.store_node(w,id,record)
  compose(w,next,X.holdNode(w,id,tx),list(next,id,tx),storeNode(w,id,record))

def bundleChoice(+flag: Bool,+w: R.World,+yes: B.Bundle<R.World,List<&2,X.Task>>,+no: B.Bundle<R.World,List<&2,X.Task>>,left: {observe(B.first(R.World,List<&2,X.Task>,yes)) == observe(w) : List<&2,R.Transaction>},right: {observe(B.first(R.World,List<&2,X.Task>,no)) == observe(w) : List<&2,R.Transaction>}) -> {observe(B.first(R.World,List<&2,X.Task>,B.choose(~B.Bundle<R.World,List<&2,X.Task>>,flag,_=>yes,_=>no))) == observe(w) : List<&2,R.Transaction>}:
  match flag:
    case True{}: left
    case False{}: right

def heldComputed(+w: R.World,+id: Nat,+tx: Nat) -> R.World:
  +w = B.choose(~R.World,B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),_=>w,_=>X.holdNode(w,id,tx))
  B.store_node(w,id,R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD_FRAME())))

def heldComputedFrame(+w: R.World,+id: Nat,+tx: Nat) -> {observe(heldComputed(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  +next = B.choose(~R.World,B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),_=>w,_=>X.holdNode(w,id,tx))
  +record = R.Node.with_config(B.node(next,id),B.set(R.Node.config(B.node(next,id)),K.CONFIG_HELD_FRAME()))
  compose(w,next,heldComputed(w,id,tx),storeNode(next,id,record),choice(B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),w,w,X.holdNode(w,id,tx),{==},node(w,id,tx)))

def holdStep(+w: R.World,+work: List<&2,X.Task>) -> {observe(B.first(R.World,List<&2,X.Task>,X.holdStep(w,work))) == observe(w) : List<&2,R.Transaction>}:
  match work:
    case Nil{}: {==}
    case X.HoldNext{id,tx} <> rest: {==}
    case X.HoldChild{+id,+tx} <> +rest:
      +next = B.choose(~R.World,B.computed(R.Node.kind(B.node(w,id))),_=>heldComputed(w,id,tx),_=>w)
      +body = {B.Bundle{next,X.HoldChild{R.Node.firstChild(B.node(next,id)),tx} <> X.HoldNext{id,tx} <> rest} : B.Bundle<R.World,List<&2,X.Task>>}
      +nextFrame = choice(B.computed(R.Node.kind(B.node(w,id))),w,heldComputed(w,id,tx),w,heldComputedFrame(w,id,tx),{==})
      +lane = R.Transaction.lane(B.transaction(w,R.NodeExtension.transaction(B.extension(w,id))))
      +branch = B.choose(~B.Bundle<R.World,List<&2,X.Task>>,lane,_=>B.Bundle{w,X.HoldNext{id,tx} <> rest},_=>body)
      bundleChoice(Nat.is_eq(id,0n),w,B.Bundle{w,rest},branch,{==},bundleChoice(lane,w,B.Bundle{w,X.HoldNext{id,tx} <> rest},body,{==},nextFrame))

def holdRun(+fuel: Nat,+w: R.World,+work: List<&2,X.Task>) -> {observe(X.holdRun(fuel,w,work)) == observe(w) : List<&2,R.Transaction>}:
  match fuel work:
    case _ Nil{}: {==}
    case 0n head <> tail: fault(w,R.Exhausted{})
    case 1n+p +head <> +tail:
      +pair = X.holdStep(w,head <> tail)
      +next = B.first(R.World,List<&2,X.Task>,pair)
      compose(w,next,X.holdRun(1n+p,w,head <> tail),holdRun(p,next,B.second(R.World,List<&2,X.Task>,pair)),holdStep(w,head <> tail))

def frame(+w: R.World,+id: Nat,+tx: Nat) -> {observe(X.holdFrame(w,id,tx)) == observe(w) : List<&2,R.Transaction>}:
  holdRun(Nat.mul(4n,B.budget(w)),w,[X.HoldChild{R.Node.firstChild(B.node(w,id)),tx}])

def rowRead(+arena: List<&2,R.Transaction>,+id: Nat) -> {mask(B.get(R.Transaction,arena,id,B.blank_transaction())) == B.get(R.Transaction,rows(arena),id,B.blank_transaction()) : R.Transaction}:
  match arena id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> +tail 1n+p: rowRead(tail,p)

def read(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : List<&2,R.Transaction>}) -> {mask(B.transaction(next,id)) == mask(B.transaction(w,id)) : R.Transaction}:
  Equal.trans(R.Transaction,mask(B.transaction(next,id)),B.get(R.Transaction,observe(next),id,B.blank_transaction()),mask(B.transaction(w,id)),rowRead(R.World.txArena(next),id),Equal.trans(R.Transaction,B.get(R.Transaction,observe(next),id,B.blank_transaction()),B.get(R.Transaction,observe(w),id,B.blank_transaction()),mask(B.transaction(w,id)),Equal.cong(List<&2,R.Transaction>,R.Transaction,arena=>B.get(R.Transaction,arena,id,B.blank_transaction()),observe(next),observe(w),same),Equal.sym(R.Transaction,mask(B.transaction(w,id)),B.get(R.Transaction,observe(w),id,B.blank_transaction()),rowRead(R.World.txArena(w),id))))

def openMasked(+record: R.Transaction) -> {R.Transaction.open(mask(record)) == R.Transaction.open(record) : Nat}:
  match record:
    case R.Transaction{nodes,renders,users,reruns,into,parent,lane,links,open,acted,frame,shown,held,marks}: {==}

def count(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : List<&2,R.Transaction>}) -> {R.Transaction.open(B.transaction(next,id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(next,id)),R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(B.transaction(w,id)),Equal.sym(Nat,R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(B.transaction(next,id)),openMasked(B.transaction(next,id))),Equal.trans(Nat,R.Transaction.open(mask(B.transaction(next,id))),R.Transaction.open(mask(B.transaction(w,id))),R.Transaction.open(B.transaction(w,id)),Equal.cong(R.Transaction,Nat,record=>R.Transaction.open(record),mask(B.transaction(next,id)),mask(B.transaction(w,id)),read(w,next,id,same)),openMasked(B.transaction(w,id))))
