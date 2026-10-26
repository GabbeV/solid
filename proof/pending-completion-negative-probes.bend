# Small actual-operation counterexamples supporting the general completion laws.
# These are kernel-negative oracles; they do not replace the quantified domains.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K


def initial() -> R.World:
  R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_kind(B.blank_node(),R.Memo{})])

def error() -> R.Value:
  R.NotReadyFailure{1n,1n}

def notified() -> R.World:
  A.notifyStatusWith(initial(),1n,K.STATUS_PENDING(),error())

def notification_finishes() -> {B.ok(notified()) == True{} : Bool}:
  {==}

def preserves_visited_and_continuation() -> {A.dispatch(initial(),[A.Notify{1n,K.STATUS_PENDING(),error()},A.Propagate{0n,0,R.Undefined{}}],[9n],True{}) == A.Machine{A.storeStatus(initial(),1n,K.STATUS_PENDING(),error()),[A.Propagate{0n,K.STATUS_PENDING(),error()},A.Propagate{0n,0,R.Undefined{}}],[9n],True{}} : A.Machine}:
  {==}

def retired() -> R.World:
  B.first(R.World,Bool,P.removePendingSource(notified(),1n,1n))

def clears_last_pending_bit() -> {B.has(R.Node.status(B.node(Q.settledStatus(retired(),1n,0n,False{}),1n)),K.STATUS_PENDING()) == False{} : Bool}:
  {==}
