# Comparator suppression and the actual ordinary write both preserve the
# subscriber/source profile, without claiming successful progress by themselves.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./setter-committed-frame.bend as Source
import ./ordinary-setter-health.bend as Setter
import ./ordinary-stage-topology.bend as Stage
import ./subscriber-topology-frame.bend as Frame

def actual(+w: R.World,+id: Nat,+current: R.Value,+value: R.Value,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},+ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool},custom: {Equality.custom(w,id) == 0n : Nat}) -> {Frame.observe(W.setResolved(w,id,current,value)) == Frame.observe(w) : Frame.View}:
  +staged = Stage.actual(w,id,value,context,signal,ordinary)
  +default = B.choose(~R.World,W.skipCompare(w,id),_=>W.stageResolved(w,id,value),_=>B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value)))
  +unchanged = Frame.choice(W.skipCompare(w,id),w,W.stageResolved(w,id,value),B.choose(~R.World,Equality.isSame(w,id,current,value),_=>w,_=>W.stageResolved(w,id,value)),staged,Frame.choice(Equality.isSame(w,id,current,value),w,w,W.stageResolved(w,id,value),{==},staged))
  Equal.trans(Frame.View,Frame.observe(W.setResolved(w,id,current,value)),Frame.observe(Source.compared(w,id,current,value)),Frame.observe(w),Equal.cong(R.World,Frame.View,state=>Frame.observe(Source.compared(state,id,current,value)),W.beforeCompare(w,id),w,Setter.before(w,id,ordinary)),Equal.trans(Frame.View,Frame.observe(Source.compared(w,id,current,value)),Frame.observe(default),Frame.observe(w),Equal.cong(R.World,Frame.View,state=>Frame.observe(state),Source.compared(w,id,current,value),default,Setter.comparedDefault(w,id,current,value,custom)),unchanged))
