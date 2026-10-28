# A controller's captured-route/method certificate, separate from source heap
# and live debt. Actual preparation/body frames construct its successor.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./transaction-rejoin-history.bend as Alias
import ./transaction-route-rebase.bend as Move
import ./held-body-controller-frame.bend as Frame
import ./held-prepared-other-controller.bend as Prepared
import ./action-body-entry.bend as Entry

type Ready<-w: R.World,-actor: Nat,-root: Nat,-captureOffset: Nat,-methods: R.Expr> is Data:
  Captured{alias: Alias.Alias<w,root>,capture: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,root,alias) : Nat},positive: {Alias.identity(w,root,alias) == 1n+captureOffset : Nat},known: {R.ActionState.methods(A.get(w,actor)) == methods : R.Expr}}

def parents(-before: R.World,-next: R.World,frame: Frame.Kept<before,next>) -> {Move.parents(next) == Move.parents(before) : List<&2,Nat>}:
  match frame:
    case Frame.Retained{parents,actions}: parents

def actions(-before: R.World,-next: R.World,frame: Frame.Kept<before,next>) -> {R.World.actions(next) == R.World.actions(before) : List<&2,R.ActionState>}:
  match frame:
    case Frame.Retained{parents,actions}: actions

def read(+before: R.World,+next: R.World,+actor: Nat,frame: Frame.Kept<before,next>) -> {A.get(next,actor) == A.get(before,actor) : R.ActionState}:
  Equal.cong(List<&2,R.ActionState>,R.ActionState,rows=>B.get(R.ActionState,rows,actor,A.blank()),R.World.actions(next),R.World.actions(before),actions(before,next,frame))

def across(+before: R.World,+next: R.World,+actor: Nat,+root: Nat,+captureOffset: Nat,+methods: R.Expr,ready: Ready<before,actor,root,captureOffset,methods>,+links: {Move.parents(next) == Move.parents(before) : List<&2,Nat>},+same: {A.get(next,actor) == A.get(before,actor) : R.ActionState}) -> Ready<next,actor,root,captureOffset,methods>:
  match ready:
    case Captured{+alias,capture,positive,known}:
      +moved = Move.moveAlias(before,next,root,alias,links)
      +value = Move.aliasValue(before,next,root,alias,moved)
      +identity = Move.aliasIdentity(before,next,root,alias,moved)
      Captured{value,Equal.trans(Nat,R.ActionState.transaction(A.get(next,actor)),R.ActionState.transaction(A.get(before,actor)),Alias.identity(next,root,value),Equal.cong(R.ActionState,Nat,state=>R.ActionState.transaction(state),A.get(next,actor),A.get(before,actor),same),Equal.trans(Nat,R.ActionState.transaction(A.get(before,actor)),Alias.identity(before,root,alias),Alias.identity(next,root,value),capture,Equal.sym(Nat,Alias.identity(next,root,value),Alias.identity(before,root,alias),identity))),Equal.trans(Nat,Alias.identity(next,root,value),Alias.identity(before,root,alias),1n+captureOffset,identity,positive),Equal.trans(R.Expr,R.ActionState.methods(A.get(next,actor)),R.ActionState.methods(A.get(before,actor)),methods,Equal.cong(R.ActionState,R.Expr,state=>R.ActionState.methods(state),A.get(next,actor),A.get(before,actor),same),known)}

def body(+before: R.World,+next: R.World,+actor: Nat,+root: Nat,+captureOffset: Nat,+methods: R.Expr,ready: Ready<before,actor,root,captureOffset,methods>,+frame: Frame.Kept<before,next>) -> Ready<next,actor,root,captureOffset,methods>:
  across(before,next,actor,root,captureOffset,methods,ready,parents(before,next,frame),read(before,next,actor,frame))

def prepared(+w: R.World,+selected: Nat,+other: Nat,+root: Nat,+captureOffset: Nat,+tail: R.Expr,+methods: R.Expr,ready: Ready<w,other,root,captureOffset,methods>,arena: {R.World.txArena(Entry.prepared(w,selected,tail)) == R.World.txArena(w) : List<&2,R.Transaction>},different: {Nat.is_eq(other,selected) == False{} : Bool}) -> Ready<Entry.prepared(w,selected,tail),other,root,captureOffset,methods>:
  across(w,Entry.prepared(w,selected,tail),other,root,captureOffset,methods,ready,Move.fullArena(w,Entry.prepared(w,selected,tail),arena),Prepared.preparedOther(w,selected,other,tail,different))
