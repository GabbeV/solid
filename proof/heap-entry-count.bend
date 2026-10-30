# Compose real joined body execution and Round entry for a certified initial
# seed. Empty sweep input is an initial premise; all later premises are derived.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/held-pair-generic-body.bend as Generic
import ../proof/held-pair-generic-context.bend as Context
import ../proof/held-resume-retirement.bend as Resume
import ../proof/held-pair-generic-round.bend as Round
import ../proof/held-first-ready.bend as Ready
import ../proof/action-control-flags.bend as Flags
import ../proof/ordinary-graph-data.bend as Graph
import ../proof/action-body-return.bend as Step
import ../proof/core-prefix-compose.bend as Prefix
import ../proof/pending-stack-history.bend as Steps
import ../proof/joined-round-sweep-input.bend as Data
import ../proof/sweep-input-frame.bend as Sweep
import ../proof/round-entry.bend as Entry

import ../proof/joined-round-heap-entry.bend as Joined
import ../proof/action-retirement-count.bend as Count
import ../proof/transaction-pair.bend as Pair
import ../proof/held-first-ready-construction.bend as Constructed
def generic(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View},initial: {Sweep.observe(seed) == Sweep.Lists{[],[]} : Sweep.View}) -> {Count.count(C.world(Steps.iterate(Joined.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),1n+Pair.targetPred([],[],reverse)) == 1n : Nat}:
  +root = {1n+Pair.targetPred([],[],reverse) : Nat}
  +w = Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)
  +older = Steps.iterate(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))
  +oldTarget = {C.Machine{w,C.Round{} <> C.ActionRestoreQuestion{R.World.question(Generic.world(seed,id,values,answer,other,reverse,second))} <> rest,stack} : C.Machine}
  +readOld = Equal.cong(C.Machine,Nat,m=>Count.count(C.world(m),root),older,oldTarget,Round.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  +atWorld = Equal.trans(Nat,Count.count(w,root),Count.count(C.world(older),root),1n,Equal.sym(Nat,Count.count(C.world(older),root),Count.count(w,root),readOld),Round.count(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  +after = Steps.iterate(Joined.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))
  +readNew = Equal.cong(C.Machine,Nat,m=>Count.count(C.world(m),root),after,Joined.target(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Joined.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known,initial))
  Equal.trans(Nat,Count.count(C.world(after),root),Count.count(Entry.entered(w),root),1n,readNew,Equal.trans(Nat,Count.count(Entry.entered(w),root),Count.count(w,root),1n,Entry.count(w,root),atWorld))

def constructed(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Count.count(C.world(Steps.iterate(Joined.cost(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Constructed.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))),Resume.start(Generic.world(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))),1n+Pair.targetPred([],[],reverse)) == 1n : Nat}:
  generic(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Constructed.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Data.initial(value,values,answer,other,second))
