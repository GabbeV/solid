# Actual settledStatus changes all node status words only at the selected node,
# and only after the final source. Transaction joins and errors keep this frame.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./pending-topology-frame.bend as Source
import ./node-status-operations.bend as Frame
import ./pending-source-status-frame.bend as Pending
import ./transaction-status-frame.bend as Transaction


def statused(+w: R.World,+id: Nat) -> R.World:
  B.store_node(w,id,R.Node.with_status(B.node(w,id),B.clear(R.Node.status(B.node(w,id)),K.STATUS_PENDING())))

def clear(+w: R.World,+id: Nat,+errored: Bool) -> {Frame.observe(Source.clear(w,id,errored)) == Frame.observe(statused(w,id)) : List<&2,U32>}:
  +first = statused(w,id)
  +second = B.choose(~R.World,errored,_=>first,_=>P.setPendingError(first,id,0n,R.Undefined{}))
  Frame.compose(first,second,Source.clear(w,id,errored),Frame.choice(B.has(R.Node.config(B.node(second,id)),K.CONFIG_HELD()),second,X.joinNode(second,id),second,Transaction.joinNode(second,id),{==}),Frame.choice(errored,first,first,P.setPendingError(first,id,0n,R.Undefined{}),{==},Pending.setError(first,id,0n,R.Undefined{})))


def expected(+w: R.World,+id: Nat,remaining: Nat) -> List<&2,U32>:
  B.choose(~List<&2,U32>,Nat.is_ne(remaining,0n),_=>Frame.observe(w),_=>Frame.observe(statused(w,id)))

def choiceObserved(+flag: Bool,+left: R.World,+right: R.World,+leftView: List<&2,U32>,+rightView: List<&2,U32>,yes: {Frame.observe(left) == leftView : List<&2,U32>},no: {Frame.observe(right) == rightView : List<&2,U32>}) -> {Frame.observe(B.choose(~R.World,flag,_=>left,_=>right)) == B.choose(~List<&2,U32>,flag,_=>leftView,_=>rightView) : List<&2,U32>}:
  match flag:
    case True{}: yes
    case False{}: no

def sourceStatus(+w: R.World,+id: Nat,+remaining: Nat,+errored: Bool) -> {Frame.observe(Source.status(w,id,remaining,errored)) == expected(w,id,remaining) : List<&2,U32>}:
  +pending = B.choose(~R.World,errored,_=>w,_=>P.setPendingError(w,id,remaining,R.Undefined{}))
  choiceObserved(Nat.is_ne(remaining,0n),pending,Source.clear(w,id,errored),Frame.observe(w),Frame.observe(statused(w,id)),Frame.choice(errored,w,w,P.setPendingError(w,id,remaining,R.Undefined{}),{==},Pending.setError(w,id,remaining,R.Undefined{})),clear(w,id,errored))

def observed(+w: R.World,+id: Nat,+remaining: Nat,+errored: Bool) -> {Frame.observe(Q.settledStatus(w,id,remaining,errored)) == expected(w,id,remaining) : List<&2,U32>}:
  Equal.trans(List<&2,U32>,Frame.observe(Q.settledStatus(w,id,remaining,errored)),Frame.observe(Source.status(w,id,remaining,errored)),expected(w,id,remaining),Equal.cong(R.World,List<&2,U32>,state=>Frame.observe(state),Q.settledStatus(w,id,remaining,errored),Source.status(w,id,remaining,errored),Source.statusExact(w,id,remaining,errored)),sourceStatus(w,id,remaining,errored))
