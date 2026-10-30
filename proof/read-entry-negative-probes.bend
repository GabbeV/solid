# Small runtime-only negative oracles. The general graph/read contracts live
# separately; importing them here would expand a failing error beyond the
# diagnostic output bound. No resource failure counts as a rejected mutation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ../runtime/transaction.bend as X

def graph() -> R.World:
  +source = R.Node.with_subsTail(R.Node.with_subs(R.Node.with_kind(B.blank_node(),R.Signal{}),1n),1n)
  +reader = R.Node.with_pending(R.Node.with_deps(R.Node.with_flags(R.Node.with_kind(B.blank_node(),R.Render{}),4),1n),R.Present{R.Number{7n}})
  R.World.with_links(R.World.with_nodes(B.empty(),[B.blank_node(),source,reader]),[B.blank_link(),R.Link{1n,2n,0n,0n,0n,0n}])

def reused_pending() -> {R.Node.pending(B.node(G.link(graph(),1n,2n),2n)) == R.Present{R.Number{7n}} : R.Slot}:
  {==}

def held() -> R.World:
  +pair = X.newTransaction(graph(),False{},0n)
  X.holdNode(B.first(R.World,Nat,pair),1n,B.second(R.World,Nat,pair))

def render_join_does_not_open_pass_group() -> {R.World.passTx(X.joinPass(held(),2n,1n)) == 0n : Nat}:
  {==}

def same_flush_read_is_not_forced() -> {B.second(R.World,Bool,X.enterRead(R.World.with_flushTransaction(held(),1n),2n,1n,False{})) == False{} : Bool}:
  {==}
