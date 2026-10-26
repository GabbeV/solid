# Compact checked oracles for the real updater/profile boundaries. These
# controls support the separate quantified contracts; every mutant must compile
# and the unchanged oracle must pass before any rejection is credited.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/action-state.bend as A
import ../runtime/constants.bend as K
import ../runtime/construct-state.bend as N
import ../runtime/transaction.bend as X

def signal() -> R.World:
  N.signal(B.empty(),R.Number{0n},N.defaults())

def initial() -> R.World:
  +pair = X.newTransaction(signal(),False{},0n)
  +w = B.first(R.World,Nat,pair)
  +id = B.second(R.World,Nat,pair)
  B.store_transaction(w,id,R.Transaction.with_open(B.transaction(w,id),1n))

def staged(value: R.Value) -> R.World:
  W.stageResolved(signal(),1n,value)

def written(value: R.Value) -> R.World:
  C.world(C.step(C.step(C.step(C.Machine{signal(),[C.Evaluate{R.WriteExpr{1n,R.Literal{value},True{}},R.Undefined{}}],[]}))))

def healthy() -> {R.World.fault(staged(R.Number{7n})) == R.Healthy{} : R.Fault}:
  {==}

def debt() -> {R.Transaction.open(B.transaction(W.stageResolved(initial(),1n,R.Number{7n}),1n)) == 1n : Nat}:
  {==}

def ordinary() -> {B.has(R.Node.config(B.node(staged(R.Number{7n}),1n)),K.CONFIG_HELD()) == False{} : Bool}:
  {==}

def pending() -> {R.Node.pending(B.node(staged(R.Number{7n}),1n)) == R.Present{R.Number{7n}} : R.Slot}:
  {==}

def returnedFunctionIsData() -> {R.Node.pending(B.node(written(R.ProgramReference{0n}),1n)) == R.Present{R.ProgramReference{0n}} : R.Slot}:
  {==}

def emptyWalkHealthy() -> {R.World.fault(W.insert_subs(0n,initial(),0n)) == R.Healthy{} : R.Fault}:
  {==}

def discardCaller() -> {C.values(C.dispatch(initial(),[C.Discard{}],[R.Number{7n},R.Number{8n}])) == [R.Number{8n}] : List<&2,R.Value>}:
  {==}
