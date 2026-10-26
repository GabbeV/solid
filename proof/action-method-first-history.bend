# First actual yielded-value delivery after arbitrary finite admitted helpers.
# Construction supplies actor capture and fresh lookup; no final mark premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-method-wait-fixture.bend as Input
import ./action-helper-context.bend as Context
import ./action-first-frame.bend as Frame
import ./observer-write-frame.bend as Observer
import ./action-wait-history.bend as History
import ./action-wait-settlement.bend as Wait
import ./action-wait-allocation.bend as Allocation
import ./action-laws.bend as Guard
import ./action-wait-range.bend as Range
import ./action-wait-construction.bend as Register
import ./committed-storage-frame.bend as Content

def registeredActions(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {R.World.actions(Input.registered(values,method,prefix)) == R.World.actions(Input.initial(values,method)) : List<&2,R.ActionState>}:
  +before = Input.before(values,method,prefix)
  +next = Input.registered(values,method,prefix)
  +same = Context.registered(before,Input.action(values,method),Input.result(values,method),0)
  Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(Context.erase(next)),R.World.actions(Input.initial(values,method)),Equal.sym(List<&2,R.ActionState>,R.World.actions(Context.erase(next)),R.World.actions(next),Context.actionsErased(next)),Equal.trans(List<&2,R.ActionState>,R.World.actions(Context.erase(next)),R.World.actions(Context.erase(before)),R.World.actions(Input.initial(values,method)),Equal.cong(R.World,List<&2,R.ActionState>,w=>R.World.actions(w),Context.erase(next),Context.erase(before),same),Equal.trans(List<&2,R.ActionState>,R.World.actions(Context.erase(before)),R.World.actions(before),R.World.actions(Input.initial(values,method)),Context.actionsErased(before),Context.historyActions(prefix,Input.initial(values,method)))))

def methods(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {R.ActionState.methods(A.get(Input.registered(values,method,prefix),Input.action(values,method))) == Frame.expression(method) : R.Expr}:
  Equal.cong(List<&2,R.ActionState>,R.Expr,rows=>R.ActionState.methods(B.get(R.ActionState,rows,Input.action(values,method),A.blank())),R.World.actions(Input.registered(values,method,prefix)),R.World.actions(Input.initial(values,method)),registeredActions(values,method,prefix))

def first(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> C.Machine:
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  C.asyncActionDelivery(w,rest,stack,observer,rejected,value,A.find(R.World.actionWaits(w),observer))

def frame(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))) == Observer.observe(Frame.marked(Input.registered(values,method,prefix),Input.fresh(values,method,prefix))) : Observer.View}:
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  +entry = {R.ActionWait{observer,Input.action(values,method),0,False{}} : R.ActionWait}
  Equal.trans(Observer.View,Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))),Observer.observe(C.world(C.actionDelivery(w,rest,stack,entry,rejected,value))),Observer.observe(Frame.marked(w,observer)),Equal.cong(Maybe<&2,R.ActionWait>,Observer.View,found=>Observer.observe(C.world(C.asyncActionDelivery(w,rest,stack,observer,rejected,value,found))),A.find(R.World.actionWaits(w),observer),Some{entry},Input.lookup(values,method,prefix)),Frame.delivered(w,rest,stack,observer,Input.action(values,method),rejected,value,method,methods(values,method,prefix)))

def markedFound(+w: R.World,+observer: Nat,+action: Nat,found: {A.find(R.World.actionWaits(w),observer) == Some{R.ActionWait{observer,action,0,False{}}} : Maybe<&2,R.ActionWait>}) -> {A.find(R.World.actionWaits(Frame.marked(w,observer)),observer) == Some{R.ActionWait{observer,action,0,True{}}} : Maybe<&2,R.ActionWait>}:
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(Frame.marked(w,observer)),observer),A.find(A.settleWait(R.World.actionWaits(w),observer),observer),Some{R.ActionWait{observer,action,0,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,observer),R.World.actionWaits(Frame.marked(w,observer)),A.settleWait(R.World.actionWaits(w),observer),Allocation.waitsStored(w,A.settleWait(R.World.actionWaits(w),observer))),Wait.findsSettled(R.World.actionWaits(w),observer,R.ActionWait{observer,action,0,False{}},found))

def firstFound(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {A.find(R.World.actionWaits(C.world(first(values,method,prefix,rest,stack,rejected,value))),Input.fresh(values,method,prefix)) == Some{R.ActionWait{Input.fresh(values,method,prefix),Input.action(values,method),0,True{}}} : Maybe<&2,R.ActionWait>}:
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(C.world(first(values,method,prefix,rest,stack,rejected,value))),observer),A.find(R.World.actionWaits(Frame.marked(w,observer)),observer),Some{R.ActionWait{observer,Input.action(values,method),0,True{}}},Equal.cong(Observer.View,Maybe<&2,R.ActionWait>,view=>A.find(Observer.waitEntries(view),observer),Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))),Observer.observe(Frame.marked(w,observer)),frame(values,method,prefix,rest,stack,rejected,value)),markedFound(w,observer,Input.action(values,method),Input.lookup(values,method,prefix)))


def viewRange(+view: Observer.View) -> Bool:
  Range.below(Observer.waitEntries(view),B.length(R.AsyncObserver,Observer.observerEntries(view)))

def firstRange(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Range.below(R.World.actionWaits(C.world(first(values,method,prefix,rest,stack,rejected,value))),Allocation.index(C.world(first(values,method,prefix,rest,stack,rejected,value)))) == True{} : Bool}:
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  Equal.trans(Bool,viewRange(Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value)))),viewRange(Observer.observe(Frame.marked(w,observer))),True{},Equal.cong(Observer.View,Bool,view=>viewRange(view),Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))),Observer.observe(Frame.marked(w,observer)),frame(values,method,prefix,rest,stack,rejected,value)),History.markedRange(w,observer,Register.bounded(Input.before(values,method,prefix),Input.action(values,method),Input.result(values,method),0,Input.beforeRange(values,method,prefix))))

def firstContent(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Content.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))) == Content.observe(Input.initial(values,method)) : Content.View}:
  +before = Input.before(values,method,prefix)
  +w = Input.registered(values,method,prefix)
  +observer = Input.fresh(values,method,prefix)
  Equal.trans(Content.View,Content.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))),Content.observe(Frame.marked(w,observer)),Content.observe(Input.initial(values,method)),Equal.cong(Observer.View,Content.View,view=>Observer.committed(view),Observer.observe(C.world(first(values,method,prefix,rest,stack,rejected,value))),Observer.observe(Frame.marked(w,observer)),frame(values,method,prefix,rest,stack,rejected,value)),Equal.trans(Content.View,Content.observe(Frame.marked(w,observer)),Content.observe(w),Content.observe(Input.initial(values,method)),History.markContent(w,observer),Equal.trans(Content.View,Content.observe(w),Content.observe(before),Content.observe(Input.initial(values,method)),Allocation.content(before,Input.action(values,method),Input.result(values,method),0),History.historyContent(prefix,Input.initial(values,method)))))

def tasks(machine: C.Machine) -> List<&2,C.Task>:
  match machine:
    case C.Machine{world,tasks,values}: tasks

def after(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,events: List<&2,History.WaitEvent>) -> C.Machine:
  +arrived = first(values,method,prefix,rest,stack,rejected,value)
  C.Machine{History.run(events,C.world(arrived)),tasks(arrived),C.values(arrived)}

def afterFound(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(C.world(after(values,method,prefix,rest,stack,rejected,value,events))),Input.fresh(values,method,prefix)) == Some{R.ActionWait{Input.fresh(values,method,prefix),Input.action(values,method),0,True{}}} : Maybe<&2,R.ActionWait>}:
  History.historyFound(events,C.world(first(values,method,prefix,rest,stack,rejected,value)),Input.fresh(values,method,prefix),Input.fresh(values,method,prefix),Input.action(values,method),0,firstFound(values,method,prefix,rest,stack,rejected,value))

def duplicate(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(after(values,method,prefix,rest,stack,rejected,value,events)),tasks(after(values,method,prefix,rest,stack,rejected,value,events)),C.values(after(values,method,prefix,rest,stack,rejected,value,events)),Input.fresh(values,method,prefix),lateRejected,lateValue,A.find(R.World.actionWaits(C.world(after(values,method,prefix,rest,stack,rejected,value,events))),Input.fresh(values,method,prefix))) == after(values,method,prefix,rest,stack,rejected,value,events) : C.Machine}:
  +machine = after(values,method,prefix,rest,stack,rejected,value,events)
  +w = C.world(machine)
  +work = tasks(machine)
  +saved = C.values(machine)
  +observer = Input.fresh(values,method,prefix)
  +entry = {R.ActionWait{observer,Input.action(values,method),0,True{}} : R.ActionWait}
  Equal.trans(C.Machine,C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,A.find(R.World.actionWaits(w),observer)),C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,Some{entry}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,found=>C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,found),A.find(R.World.actionWaits(w),observer),Some{entry},afterFound(values,method,prefix,rest,stack,rejected,value,events)),Guard.duplicate_yield(w,work,saved,observer,Input.action(values,method),lateRejected,lateValue))


def allocated(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {Nat.is_lt(Input.action(values,method),B.length(R.ActionState,R.World.actions(Input.registered(values,method,prefix)))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(Input.action(values,method),B.length(R.ActionState,R.World.actions(Input.registered(values,method,prefix)))),Nat.is_lt(Input.action(values,method),B.length(R.ActionState,R.World.actions(Input.initial(values,method)))),True{},Equal.cong(List<&2,R.ActionState>,Bool,rows=>Nat.is_lt(Input.action(values,method),B.length(R.ActionState,rows)),R.World.actions(Input.registered(values,method,prefix)),R.World.actions(Input.initial(values,method)),registeredActions(values,method,prefix)),Input.allocated(values,method))
