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
import ./joined-round-sweep-input.bend as Data
import ./sweep-input-frame.bend as Sweep
import ./round-entry.bend as Entry

def cost(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View}) -> Nat:
  Nat.add(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),2n)

def target(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View}) -> C.Machine:
  C.Machine{Entry.entered(Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)),C.HeapLoop{} <> C.FlushFinally{} <> C.RoundEnd{} <> C.ActionRestoreQuestion{R.World.question(Generic.world(seed,id,values,answer,other,reverse,second))} <> rest,stack}

def complete(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,+known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View},initial: {Sweep.observe(seed) == Sweep.Lists{[],[]} : Sweep.View}) -> {Steps.iterate(cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)) == target(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known) : C.Machine}:
  +before = Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)
  +w = Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)
  +ending = {C.ActionRestoreQuestion{R.World.question(Generic.world(seed,id,values,answer,other,reverse,second))} <> rest : List<&2,C.Task>}
  +atRound = {C.Machine{w,C.Round{} <> ending,stack} : C.Machine}
  +same = Data.generic(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)
  +empty = Equal.trans(Sweep.View,Sweep.observe(w),Sweep.observe(seed),Sweep.Lists{[],[]},same,initial)
  +good = Step.health(w,Round.healthy(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known))
  Prefix.compose(Round.cost(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),2n,before,atRound,target(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Round.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known),Entry.fromSweep(w,ending,stack,empty,good))
