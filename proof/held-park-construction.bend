# Small initial-intake factories for the constructed one-source graph. They
# use the actual pending list and node flags, never a post-parking equation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./held-park-intake.bend as I

def empty(+w: R.World) -> I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>:
  I.End{}

def emptyStarts(+w: R.World,known: {R.World.pendingNodes(w) == [] : List<&2,Nat>}) -> {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),empty(w)) == 0n : Nat}:
  Equal.cong(List<&2,Nat>,Nat,rows=>B.length(Nat,rows),R.World.pendingNodes(w),[],known)

def single(+w: R.World,+id: Nat,+known: {R.World.pendingNodes(w) == [id] : List<&2,Nat>},held: {B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()) == False{} : Bool}) -> I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>:
  +count = B.length(Nat,R.World.pendingNodes(w))
  +countEq = Equal.cong(List<&2,Nat>,Nat,rows=>B.length(Nat,rows),R.World.pendingNodes(w),[id],known)
  +lookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,0n,0n),R.World.pendingNodes(w),[id],known)
  +heldAt = Equal.trans(Bool,B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),0n,0n))),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())),B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())),True{},Equal.cong(Nat,Bool,at=>B.has(R.Node.config(B.node(w,at)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())),B.get(Nat,R.World.pendingNodes(w),0n,0n),id,lookup),held)
  +unstagedAt = Equal.trans(Bool,B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),0n,0n))),K.CONFIG_STAGED()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()),False{},Equal.cong(Nat,Bool,at=>B.has(R.Node.config(B.node(w,at)),K.CONFIG_STAGED()),B.get(Nat,R.World.pendingNodes(w),0n,0n),id,lookup),unstaged)
  I.Next{0n,Equal.cong(Nat,Bool,n=>Nat.is_ge(0n,n),count,1n,countEq),heldAt,unstagedAt,I.End{},countEq}

def singleStarts(+w: R.World,+id: Nat,+known: {R.World.pendingNodes(w) == [id] : List<&2,Nat>},+held: {B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},+unstaged: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()) == False{} : Bool}) -> {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),single(w,id,known,held,unstaged)) == 0n : Nat}:
  {==}
