# Small proof-only record data shared by constructor boundary contracts.
import Base
import ../representation/records.bend as R

def group(id: Nat) -> R.Transaction:
  R.Transaction{[id],[],[],[],0n,0n,False{},0n,1n,True{},0n,False{},False{},R.NoIds{}}

def first(methods: R.Expr) -> R.ActionState:
  R.ActionState{1n,R.QuestionOdd{R.QuestionZero{}},methods,1n}
