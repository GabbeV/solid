# Actual raw graph/create/open/hold/input allocation/wait registration. Finite
# admitted helper prefixes are permitted; this does not model the host loop or
# claim the full public generator invocation/parking prefix.
import Base
import ./held-delivery-constructor-state.bend as State
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./ordinary-graph-data.bend as Graph
import ./held-opened-profile.bend as Input
import ./held-opened-facts.bend as Construct
import ./held-action-registration-frame.bend as Frame
import ./held-hold-control.bend as Control
import ./held-preparation-source.bend as Source
import ./held-write-profile.bend as P
import ./action-wait-history.bend as History
import ./action-wait-range.bend as Range
import ./action-wait-allocation.bend as Allocation
import ./action-wait-construction.bend as Register
import ./transaction-resolution.bend as Paths
import ./transaction-rejoin-history.bend as Alias
import ./held-preparation-profile.bend as Prep

def initial(+value: R.Value,methods: R.Expr) -> R.World:
  State.initial(value,methods)

def result(value: R.Value,methods: R.Expr) -> Nat:
  State.result(value,methods)

def before(value: R.Value,methods: R.Expr,prefix: List<&2,History.WaitEvent>) -> R.World:
  State.before(value,methods,prefix)

def registered(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> R.World:
  State.registered(value,methods,prefix)

def observer(value: R.Value,methods: R.Expr,prefix: List<&2,History.WaitEvent>) -> Nat:
  State.observer(value,methods,prefix)

def profile(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> P.Profile<Source.flush(registered(value,methods,prefix),1n),Graph.source(value),0n>:
  +w = Input.opened(value,methods)
  +next = before(value,methods,prefix)
  Frame.registeredProfile(next,0n,result(value,methods),0,Graph.source(value),0n,Frame.historyProfile(prefix,initial(value,methods),Graph.source(value),0n,Frame.futureProfile(w,Graph.source(value),0n,Input.profile(value,methods))))

def control(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Control.observe(registered(value,methods,prefix)) == Control.observe(Input.opened(value,methods)) : Control.View}:
  +w = Input.opened(value,methods)
  +fresh = initial(value,methods)
  +next = before(value,methods,prefix)
  Equal.trans(Control.View,Control.observe(registered(value,methods,prefix)),Control.observe(next),Control.observe(w),Frame.registerControl(next,0n,result(value,methods),0),Equal.trans(Control.View,Control.observe(next),Control.observe(fresh),Control.observe(w),Frame.historyControl(prefix,fresh),Frame.futureControl(w)))

def capture(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.ActionState.transaction(A.get(registered(value,methods,prefix),0n)) == 1n : Nat}:
  +w = Input.opened(value,methods)
  +next = registered(value,methods,prefix)
  Equal.trans(Nat,R.ActionState.transaction(A.get(next,0n)),R.ActionState.transaction(A.get(w,0n)),1n,Equal.cong(Control.View,Nat,view=>R.ActionState.transaction(B.get(R.ActionState,Control.actions(view),0n,A.blank())),Control.observe(next),Control.observe(w),control(value,methods,prefix)),Construct.capture(value,methods))

def method(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.ActionState.methods(A.get(registered(value,methods,prefix),0n)) == methods : R.Expr}:
  +w = Input.opened(value,methods)
  +next = registered(value,methods,prefix)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(next,0n)),R.ActionState.methods(A.get(w,0n)),methods,Equal.cong(Control.View,R.Expr,view=>R.ActionState.methods(B.get(R.ActionState,Control.actions(view),0n,A.blank())),Control.observe(next),Control.observe(w),control(value,methods,prefix)),Construct.methods(value,methods))

def empty(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.World.flushTransaction(registered(value,methods,prefix)) == 0n : Nat}:
  Equal.trans(Nat,R.World.flushTransaction(registered(value,methods,prefix)),R.World.flushTransaction(Input.opened(value,methods)),0n,Equal.cong(Control.View,Nat,view=>Control.future(view),Control.observe(registered(value,methods,prefix)),Control.observe(Input.opened(value,methods)),control(value,methods,prefix)),Construct.empty(value,methods))

def openCount(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.Transaction.open(B.transaction(registered(value,methods,prefix),1n)) == 1n : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(registered(value,methods,prefix),1n)),R.Transaction.open(B.transaction(Input.opened(value,methods),1n)),1n,Control.openCount(Input.opened(value,methods),registered(value,methods,prefix),1n,control(value,methods,prefix)),Construct.openCount(value,methods))

def initialRange(+value: R.Value,+methods: R.Expr) -> {Range.below(R.World.actionWaits(initial(value,methods)),Allocation.index(initial(value,methods))) == True{} : Bool}:
  {==}

def beforeRange(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {Range.below(R.World.actionWaits(before(value,methods,prefix)),Allocation.index(before(value,methods,prefix))) == True{} : Bool}:
  History.historyRange(prefix,initial(value,methods),initialRange(value,methods))

def found(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(registered(value,methods,prefix)),observer(value,methods,prefix)) == Some{R.ActionWait{observer(value,methods,prefix),0n,0,False{}}} : Maybe<&2,R.ActionWait>}:
  Register.found(before(value,methods,prefix),0n,result(value,methods),0,beforeRange(value,methods,prefix))

def alias(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> Alias.Alias<registered(value,methods,prefix),1n>:
  +w = registered(value,methods,prefix)
  +selected = Source.flush(w,1n)
  +terminal = Equal.trans(Nat,R.Transaction.into(B.transaction(w,1n)),R.Transaction.into(B.transaction(selected,1n)),0n,Equal.sym(Nat,R.Transaction.into(B.transaction(selected,1n)),R.Transaction.into(B.transaction(w,1n)),Prep.originalTerminal(w,1n)),P.terminal(selected,Graph.source(value),0n,profile(value,methods,prefix)))
  Alias.Alias{Paths.Root{1n,terminal},B.length(R.Transaction,R.World.txArena(w)),{==},{==}}
