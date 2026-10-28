# Actual captured question/join/method preparation with a positive redirected
# action identity. The source cache already names the canonical group; no
# distinct-component merge or post-preparation profile/capture is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./action-body-entry.bend as Entry
import ./held-preparation-source.bend as Prepare
import ./held-preparation-control.bend as Control
import ./held-setter-entry.bend as Join
import ./held-source-view.bend as View
import ./held-source-operations.bend as Frame
import ./transaction-rejoin-history.bend as Alias
import ./transaction-route-rebase.bend as Move
import ./held-preparation-alias-join.bend as AliasJoin

def moved(+w: R.World,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> Move.AliasRebased<w,Entry.asked(w,actor),1n+offset,alias>:
  Move.moveAlias(w,Entry.asked(w,actor),1n+offset,alias,Move.fullArena(w,Entry.asked(w,actor),Control.questionArena(w,R.ActionState.question(A.get(w,actor)))))

def askedAlias(+w: R.World,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> Alias.Alias<Entry.asked(w,actor),1n+offset>:
  Move.aliasValue(w,Entry.asked(w,actor),1n+offset,alias,moved(w,actor,offset,alias))

def askedIdentity(+w: R.World,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>) -> {Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)) == Alias.identity(w,1n+offset,alias) : Nat}:
  Move.aliasIdentity(w,Entry.asked(w,actor),1n+offset,alias,moved(w,actor,offset,alias))

def askedCapture(+w: R.World,+actor: Nat,+offset: Nat,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat}) -> {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)) : Nat}:
  Equal.trans(Nat,R.ActionState.transaction(A.get(w,actor)),Alias.identity(w,1n+offset,alias),Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)),captured,Equal.sym(Nat,Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)),Alias.identity(w,1n+offset,alias),askedIdentity(w,actor,offset,alias)))

def positiveAfterQuestion(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+offset>,positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat}) -> {Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)) == 1n+captureOffset : Nat}:
  Equal.trans(Nat,Alias.identity(Entry.asked(w,actor),1n+offset,askedAlias(w,actor,offset,alias)),Alias.identity(w,1n+offset,alias),1n+captureOffset,askedIdentity(w,actor,offset,alias),positive)

def joinedCurrent(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {Entry.joined(w,actor) == Join.scheduled(Entry.asked(w,actor)) : R.World}:
  +asked = Entry.asked(w,actor)
  +question = R.ActionState.question(A.get(w,actor))
  +nextFuture = Equal.trans(Nat,R.World.flushTransaction(asked),R.World.flushTransaction(w),1n+offset,Frame.questionFuture(w,question),future)
  +nextStopped = Equal.trans(Nat,R.Transaction.into(B.transaction(asked,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),0n,Frame.questionInto(w,question,1n+offset),stopped)
  Equal.trans(R.World,Entry.joined(w,actor),X.joinFuture(asked,Alias.identity(asked,1n+offset,askedAlias(w,actor,offset,alias))),Join.scheduled(asked),Equal.cong(Nat,R.World,id=>X.joinFuture(asked,id),R.ActionState.transaction(A.get(w,actor)),Alias.identity(asked,1n+offset,askedAlias(w,actor,offset,alias)),askedCapture(w,actor,offset,alias,captured)),AliasJoin.current(asked,offset,captureOffset,askedAlias(w,actor,offset,alias),positiveAfterQuestion(w,actor,offset,captureOffset,alias,positive),nextFuture,nextStopped))

def joinedFresh(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {Entry.joined(w,actor) == Join.scheduled(Prepare.flush(Entry.asked(w,actor),1n+offset)) : R.World}:
  +asked = Entry.asked(w,actor)
  +nextEmpty = Equal.trans(Nat,R.World.flushTransaction(asked),R.World.flushTransaction(w),0n,Frame.questionFuture(w,R.ActionState.question(A.get(w,actor))),empty)
  Equal.trans(R.World,Entry.joined(w,actor),X.joinFuture(asked,Alias.identity(asked,1n+offset,askedAlias(w,actor,offset,alias))),Join.scheduled(Prepare.flush(asked,1n+offset)),Equal.cong(Nat,R.World,id=>X.joinFuture(asked,id),R.ActionState.transaction(A.get(w,actor)),Alias.identity(asked,1n+offset,askedAlias(w,actor,offset,alias)),askedCapture(w,actor,offset,alias,captured)),AliasJoin.fresh(asked,offset,captureOffset,askedAlias(w,actor,offset,alias),positiveAfterQuestion(w,actor,offset,captureOffset,alias,positive),nextEmpty))

def current(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {View.observe(Entry.prepared(w,actor,tail)) == View.observe(w) : View.View}:
  +next = Entry.joined(w,actor)
  +entered = A.enter(next)
  +record = R.ActionState.with_methods(A.get(next,actor),tail)
  +asked = Entry.asked(w,actor)
  Equal.trans(View.View,View.observe(Entry.prepared(w,actor,tail)),View.observe(next),View.observe(w),Frame.compose(next,entered,Entry.prepared(w,actor,tail),Frame.stored(entered,actor,record),Frame.enter(next)),Equal.trans(View.View,View.observe(next),View.observe(Join.scheduled(asked)),View.observe(w),Equal.cong(R.World,View.View,state=>View.observe(state),next,Join.scheduled(asked),joinedCurrent(w,actor,offset,captureOffset,alias,captured,positive,future,stopped)),Frame.compose(w,asked,Join.scheduled(asked),Prepare.scheduled(asked),Frame.worldQuestion(w,R.ActionState.question(A.get(w,actor))))))

def fresh(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {View.observe(Entry.prepared(w,actor,tail)) == View.observe(Prepare.flush(w,1n+offset)) : View.View}:
  +next = Entry.joined(w,actor)
  +entered = A.enter(next)
  +record = R.ActionState.with_methods(A.get(next,actor),tail)
  +asked = Entry.asked(w,actor)
  +selected = Prepare.flush(asked,1n+offset)
  +target = Prepare.flush(w,1n+offset)
  Equal.trans(View.View,View.observe(Entry.prepared(w,actor,tail)),View.observe(next),View.observe(target),Frame.compose(next,entered,Entry.prepared(w,actor,tail),Frame.stored(entered,actor,record),Frame.enter(next)),Equal.trans(View.View,View.observe(next),View.observe(Join.scheduled(selected)),View.observe(target),Equal.cong(R.World,View.View,state=>View.observe(state),next,Join.scheduled(selected),joinedFresh(w,actor,offset,captureOffset,alias,captured,positive,empty)),Equal.trans(View.View,View.observe(Join.scheduled(selected)),View.observe(selected),View.observe(target),Prepare.scheduled(selected),Frame.questionFlush(w,R.ActionState.question(A.get(w,actor)),1n+offset))))

def currentArena(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},future: {R.World.flushTransaction(w) == 1n+offset : Nat},stopped: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}) -> {R.World.txArena(Entry.prepared(w,actor,tail)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +joined = Entry.joined(w,actor)
  +asked = Entry.asked(w,actor)
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(Entry.prepared(w,actor,tail)),R.World.txArena(joined),R.World.txArena(w),Control.tailArena(joined,actor,tail),Equal.trans(List<&2,R.Transaction>,R.World.txArena(joined),R.World.txArena(Join.scheduled(asked)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),joined,Join.scheduled(asked),joinedCurrent(w,actor,offset,captureOffset,alias,captured,positive,future,stopped)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(Join.scheduled(asked)),R.World.txArena(asked),R.World.txArena(w),Control.scheduledArena(asked),Control.questionArena(w,R.ActionState.question(A.get(w,actor))))))

def freshArena(+w: R.World,+actor: Nat,+offset: Nat,+captureOffset: Nat,+tail: R.Expr,+alias: Alias.Alias<w,1n+offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == Alias.identity(w,1n+offset,alias) : Nat},positive: {Alias.identity(w,1n+offset,alias) == 1n+captureOffset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> {R.World.txArena(Entry.prepared(w,actor,tail)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +joined = Entry.joined(w,actor)
  +asked = Entry.asked(w,actor)
  +selected = Prepare.flush(asked,1n+offset)
  +selectedArena = Equal.trans(List<&2,R.Transaction>,R.World.txArena(selected),R.World.txArena(asked),R.World.txArena(w),Control.flushArena(asked,1n+offset),Control.questionArena(w,R.ActionState.question(A.get(w,actor))))
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(Entry.prepared(w,actor,tail)),R.World.txArena(joined),R.World.txArena(w),Control.tailArena(joined,actor,tail),Equal.trans(List<&2,R.Transaction>,R.World.txArena(joined),R.World.txArena(Join.scheduled(selected)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),joined,Join.scheduled(selected),joinedFresh(w,actor,offset,captureOffset,alias,captured,positive,empty)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(Join.scheduled(selected)),R.World.txArena(selected),R.World.txArena(w),Control.scheduledArena(selected),selectedArena)))
