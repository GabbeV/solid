# Actual yielded-value callback entry, before queued user evaluation. Action
# captures/joins/ambient changes remain real; waits/observer arena/content survive.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/question.bend as Question
import ../runtime/transaction.bend as X
import ./action-resume-frame.bend as Frame
import ./action-resume-transaction.bend as Transaction
import ./observer-write-frame.bend as Observer


type Method is Data:
  End{}
  Body{next: R.Expr,catches: Bool,thrown: R.Expr,tail: R.Expr}

def expression(method: Method) -> R.Expr:
  match method:
    case End{}: R.ActionEnd{}
    case Body{next,catches,thrown,tail}: R.ActionMethods{next,catches,thrown,tail}

def observe(w: R.World) -> Observer.View:
  Observer.observe(w)

def compose(+a: R.World,+b: R.World,+c: R.World,last: {observe(c) == observe(b) : Observer.View},first: {observe(b) == observe(a) : Observer.View}) -> {observe(c) == observe(a) : Observer.View}:
  Equal.trans(Observer.View,observe(c),observe(b),observe(a),last,first)

def post(+w: R.World,+next: R.World,known: {Frame.observe(next) == Frame.observe(w) : Frame.View}) -> {observe(next) == observe(w) : Observer.View}:
  Equal.cong(Frame.View,Observer.View,view=>Frame.observer(view),Frame.observe(next),Frame.observe(w),known)

def postFault(+w: R.World,+fault: R.Fault) -> {observe(R.World.with_fault(w,fault)) == observe(w) : Observer.View}:
  post(w,R.World.with_fault(w,fault),Frame.worldFault(w,fault))

def enter(+w: R.World) -> {observe(A.enter(w)) == observe(w) : Observer.View}:
  post(w,A.enter(w),Frame.worldDepth(w,1n+R.World.actionDepth(w)))

def actionsPost(+w: R.World,actions: List<&2,R.ActionState>) -> {observe(R.World.with_actions(w,actions)) == observe(w) : Observer.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def methods(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+rejected: Bool,+state: R.ActionState,+method: Method) -> {observe(C.world(C.actionStepMethods(w,rest,stack,id,value,rejected,state,expression(method)))) == observe(w) : Observer.View}:
  match method:
    case End{}:
      +entered = A.enter(w)
      +next = B.choose(~R.World,rejected,_=>R.World.with_fault(entered,R.CallbackThrown{value}),_=>entered)
      +chosen = Frame.choice(rejected,entered,R.World.with_fault(entered,R.CallbackThrown{value}),entered,Frame.worldFault(entered,R.CallbackThrown{value}),{==})
      compose(w,entered,next,post(entered,next,chosen),enter(w))
    case Body{next,catches,thrown,+tail}:
      +entered = A.enter(w)
      +record = R.ActionState.with_methods(state,tail)
      compose(w,entered,A.store(entered,id,record),actionsPost(entered,List.set(&2,R.ActionState,R.World.actions(entered),id,record)),enter(w))

def step(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+rejected: Bool,+method: Method,known: {R.ActionState.methods(A.get(w,id)) == expression(method) : R.Expr}) -> {observe(C.world(C.actionStep(w,rest,stack,id,value,rejected))) == observe(w) : Observer.View}:
  Equal.trans(Observer.View,observe(C.world(C.actionStep(w,rest,stack,id,value,rejected))),observe(C.world(C.actionStepMethods(w,rest,stack,id,value,rejected,A.get(w,id),expression(method)))),observe(w),Equal.cong(R.Expr,Observer.View,expr=>observe(C.world(C.actionStepMethods(w,rest,stack,id,value,rejected,A.get(w,id),expr))),R.ActionState.methods(A.get(w,id)),expression(method),known),methods(w,rest,stack,id,value,rejected,A.get(w,id),method))

def methodTransport(+w: R.World,+next: R.World,+id: Nat,+method: Method,same: {R.World.actions(next) == R.World.actions(w) : List<&2,R.ActionState>},known: {R.ActionState.methods(A.get(w,id)) == expression(method) : R.Expr}) -> {R.ActionState.methods(A.get(next,id)) == expression(method) : R.Expr}:
  Equal.trans(R.Expr,R.ActionState.methods(A.get(next,id)),R.ActionState.methods(A.get(w,id)),expression(method),Equal.cong(List<&2,R.ActionState>,R.Expr,rows=>R.ActionState.methods(B.get(R.ActionState,rows,id,A.blank())),R.World.actions(next),R.World.actions(w),same),known)

def resume(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+rejected: Bool,+method: Method,known: {R.ActionState.methods(A.get(w,id)) == expression(method) : R.Expr}) -> {observe(C.world(C.actionResume(w,rest,stack,id,value,rejected))) == observe(w) : Observer.View}:
  +state = A.get(w,id)
  +asked = Question.setQuestion(w,R.ActionState.question(state))
  +joined = X.joinFuture(asked,R.ActionState.transaction(state))
  +before = Frame.compose(w,asked,joined,Transaction.joinFuture(asked,R.ActionState.transaction(state)),Frame.worldQuestion(w,R.ActionState.question(state)))
  +actions = Equal.cong(Frame.View,List<&2,R.ActionState>,view=>Frame.actions(view),Frame.observe(joined),Frame.observe(w),before)
  compose(w,joined,C.world(C.actionResume(w,rest,stack,id,value,rejected)),step(joined,C.ActionSliceEnd{R.World.question(w)} <> rest,stack,id,value,rejected,method,methodTransport(w,joined,id,method,actions,known)),post(w,joined,before))

def marked(+w: R.World,observer: Nat) -> R.World:
  R.World.with_actionWaits(w,A.settleWait(R.World.actionWaits(w),observer))

def markedActions(+w: R.World,+observer: Nat) -> {R.World.actions(marked(w,observer)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
