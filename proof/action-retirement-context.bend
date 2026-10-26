# Terminal retirement context, kept out of primitive callback-table contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./action-wait-history.bend as History
import ./action-first-retirement.bend as Retire
import ./action-helper-context.bend as Context

def zero(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,certificate: Retire.Retired<values,rest,stack,rejected,value>) -> {R.Transaction.open(B.transaction(C.world(Retire.retired(values,rest,stack,rejected,value)),1n)) == 0n : Nat}:
  match certificate:
    case Retire.RetiredAt{open,result,lookup}: open

def afterRetirementZero(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>) -> {R.Transaction.open(B.transaction(C.world(Retire.after(values,rest,stack,rejected,value,events)),1n)) == 0n : Nat}:
  +done = C.world(Retire.retired(values,rest,stack,rejected,value))
  Equal.trans(Nat,R.Transaction.open(B.transaction(C.world(Retire.after(values,rest,stack,rejected,value,events)),1n)),R.Transaction.open(B.transaction(done,1n)),0n,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,1n,B.blank_transaction())),R.World.txArena(History.run(events,done)),R.World.txArena(done),Context.historyArena(events,done)),zero(values,rest,stack,rejected,value,Retire.completed(values,rest,stack,rejected,value)))
