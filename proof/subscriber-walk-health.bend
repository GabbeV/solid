# Finite actual subscriber paths supply loop fuel. The shrinking path precedes
# the changing current World in the recursion order; all operation laws are real.
import Base
import ./subscriber-walk-step.bend as Step
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ./ordinary-write-outer.bend as Frame

def walk(+w: R.World,path: Step.Path<w>,+current: R.World,+extra: Nat,+same: {Frame.observe(current) == Frame.observe(w) : R.World},+known: {R.World.marked(w) == False{} : Bool}) -> {Frame.observe(W.insert_subs(Nat.add(Step.depth(w,path),extra),current,Step.origin(w,path))) == Frame.observe(w) : R.World}:
  match path:
    case Step.End{}:
      Equal.trans(R.World,Frame.observe(W.insert_subs(extra,current,0n)),Frame.observe(current),Frame.observe(w),Equal.cong(R.World,R.World,state=>Frame.observe(state),W.insert_subs(extra,current,0n),current,Step.empty(extra,current)),same)
    case Step.Edge{+index,+tail,linked}:
      +edge = {1n+index : Nat}
      +next = Step.enqueued(current,edge)
      +nextFrame = Frame.compose(w,current,next,Step.enqueueFrame(current,edge,Frame.unmarked(w,current,same,known)),same)
      +follow = Equal.trans(Nat,R.Link.nextSub(B.link(current,edge)),R.Link.nextSub(B.link(w,edge)),Step.origin(w,tail),Step.nextLink(w,current,edge,same),linked)
      +fuel = Nat.add(Step.depth(w,tail),extra)
      +advanced = Equal.cong(R.World,R.World,state=>Frame.observe(state),W.insert_subs(1n+fuel,current,edge),W.insert_subs(fuel,next,R.Link.nextSub(B.link(current,edge))),Step.step(current,index,fuel))
      Equal.trans(R.World,Frame.observe(W.insert_subs(1n+fuel,current,edge)),Frame.observe(W.insert_subs(fuel,next,R.Link.nextSub(B.link(current,edge)))),Frame.observe(w),advanced,Equal.trans(R.World,Frame.observe(W.insert_subs(fuel,next,R.Link.nextSub(B.link(current,edge)))),Frame.observe(W.insert_subs(fuel,next,Step.origin(w,tail))),Frame.observe(w),Equal.cong(Nat,R.World,id=>Frame.observe(W.insert_subs(fuel,next,id)),R.Link.nextSub(B.link(current,edge)),Step.origin(w,tail),follow),walk(w,tail,next,extra,nextFrame,known)))
