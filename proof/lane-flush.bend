# Source settle call/queue boundaries. No full-lifecycle or progress theorem.
import Base
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../representation/records.bend as R
import ../representation/base.bend as B

def appendNil(-A: Data, +xs: List<&2, A>) -> {B.append(A, xs, []) == xs : List<&2, A>}:
  match xs:
    case Nil{}: {==}
    case head <> +tail:
      Equal.cong(List<&2, A>, List<&2, A>, rest => head <> rest, B.append(A, tail, []), tail, appendNil(A, tail))

def expected(~A: Data, parked: Bool, +own: List<&2, A>, +lanes: List<&2, A>, +landing: List<&2, A>) -> List<&2, A>:
  B.choose(~List<&2, A>, parked, _ => B.append(A, lanes, landing), _ => B.append(A, lanes, B.append(A, own, landing)))

def renderOrder(+parked: Bool, +own: List<&2, Nat>, +lanes: List<&2, Nat>, +landing: List<&2, Nat>) ->
  {C.orderedRuns(~Nat, parked, own, lanes, landing) == expected(~Nat, parked, own, lanes, landing) : List<&2, Nat>}:
  match parked lanes landing:
    case True{} _ _: {==}
    case False{} Nil{} Nil{}:
      Equal.sym(List<&2, Nat>, B.append(Nat, own, []), own, appendNil(Nat, own))
    case False{} Nil{} head <> tail: {==}
    case False{} head <> tail _: {==}

def userOrder(+parked: Bool, +own: List<&2, R.QueueEntry>, +lanes: List<&2, R.QueueEntry>, +landing: List<&2, R.QueueEntry>) ->
  {C.orderedRuns(~R.QueueEntry, parked, own, lanes, landing) == expected(~R.QueueEntry, parked, own, lanes, landing) : List<&2, R.QueueEntry>}:
  match parked lanes landing:
    case True{} _ _: {==}
    case False{} Nil{} Nil{}:
      Equal.sym(List<&2, R.QueueEntry>, B.append(R.QueueEntry, own, []), own, appendNil(R.QueueEntry, own))
    case False{} Nil{} head <> tail: {==}
    case False{} head <> tail _: {==}

# The source joined local was captured before applying guesses. A hook's later
# join does not turn an originally null joined into this seam's parked frame.
def capturedNoJoin(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>) ->
  {C.settleApplied(w, rest, stack, 0n) == C.Machine{w, C.CommitIntake{0n} <> C.TrimIntake{0n} <> C.FinishSettleIntake{0n} <> rest, stack} : C.Machine}:
  {==}

def landingEntry(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame, +tx: Nat) ->
  {C.dispatch(w, C.LandAfterLanes{frame, tx} <> rest, stack) == C.landPrepared(w, rest, stack, frame, tx) : C.Machine}:
  {==}

def zombieChoice(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tx: Nat, +id: Nat, +tail: List<&2, Nat>, eligible: Bool) -> C.Machine:
  C.Machine{w, B.choose(~List<&2, C.Task>, eligible,
    _ => C.Recompute{id, False{}} <> C.ParkVerdictZombies{tx, tail} <> rest,
    _ => C.ParkVerdictZombies{tx, tail} <> rest), stack}

def skipParkedZombie(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +tx: Nat, +id: Nat, +tail: List<&2, Nat>,
  ineligible: {Bool.and(U32.is_eq(U32.and(R.Node.flags(B.node(w, id)), U32.or(K.REACTIVE_DISPOSED(), K.REACTIVE_ZOMBIE())), K.REACTIVE_ZOMBIE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT())) == False{} : Bool}) ->
  {C.parkVerdictZombies(w, rest, stack, tx, id <> tail) == C.Machine{w, C.ParkVerdictZombies{tx, tail} <> rest, stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, eligible => zombieChoice(w, rest, stack, tx, id, tail, eligible), Bool.and(U32.is_eq(U32.and(R.Node.flags(B.node(w, id)), U32.or(K.REACTIVE_DISPOSED(), K.REACTIVE_ZOMBIE())), K.REACTIVE_ZOMBIE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_VERDICT())), False{}, ineligible)
