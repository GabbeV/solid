# Reusable induction on the existing actual Core.step prefix certificates.
# The observer and input-step law are instantiated by concrete runtime proofs;
# no final observation or transition result is supplied to the induction.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./pending-committed-history.bend as Domain

def inputStep(~A: Data, ~observe: R.World -> A,
  ~once: @+w: R.World -> @+rest: List<&2, C.Task> -> @+stack: List<&2, R.Value> -> @+phase: Steps.Phase -> @allowed: {Domain.bodyPhase(phase) == True{} : Bool} -> {observe(C.world(C.step(Steps.input(w, rest, stack, phase)))) == observe(w) : A},
  -machine: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Steps.Phase,
  +layout: {machine == Steps.input(w, rest, stack, phase) : C.Machine}, allowed: {Domain.bodyPhase(phase) == True{} : Bool}) ->
  {observe(C.world(C.step(machine))) == observe(C.world(machine)) : A}:
  Equal.trans(A, observe(C.world(C.step(machine))), observe(C.world(C.step(Steps.input(w, rest, stack, phase)))), observe(C.world(machine)),
    Equal.cong(C.Machine, A, actual => observe(C.world(C.step(actual))), machine, Steps.input(w, rest, stack, phase), layout),
    Equal.trans(A, observe(C.world(C.step(Steps.input(w, rest, stack, phase)))), observe(w), observe(C.world(machine)), once(w, rest, stack, phase, allowed),
      Equal.sym(A, observe(C.world(machine)), observe(w),
        Equal.trans(A, observe(C.world(machine)), observe(C.world(Steps.input(w, rest, stack, phase))), observe(w),
          Equal.cong(C.Machine, A, actual => observe(C.world(actual)), machine, Steps.input(w, rest, stack, phase), layout),
          Equal.cong(R.World, A, actual => observe(actual), C.world(Steps.input(w, rest, stack, phase)), w, Domain.inputWorld(w, rest, stack, phase))))))

def preserves(~A: Data, ~observe: R.World -> A,
  ~once: @+w: R.World -> @+rest: List<&2, C.Task> -> @+stack: List<&2, R.Value> -> @+phase: Steps.Phase -> @allowed: {Domain.bodyPhase(phase) == True{} : Bool} -> {observe(C.world(C.step(Steps.input(w, rest, stack, phase)))) == observe(w) : A},
  -scope: C.Machine, +programme: Steps.Programme<scope>, +allowed: {Domain.bodyOnly(scope, programme) == True{} : Bool}) ->
  {observe(C.world(Steps.run(scope, programme, scope))) == observe(C.world(scope)) : A}:
  match programme:
    case Steps.End{}: {==}
    case Steps.Step{world, rest, stack, +phase, layout, +tail}:
      Equal.trans(A, observe(C.world(Steps.run(C.step(scope), tail, C.step(scope)))), observe(C.world(C.step(scope))), observe(C.world(scope)),
        preserves(A, observe, once, C.step(scope), tail, Domain.andRight(Domain.bodyPhase(phase), Domain.bodyOnly(C.step(scope), tail), allowed)),
        inputStep(A, observe, once, scope, world, rest, stack, phase, layout, Domain.andLeft(Domain.bodyPhase(phase), Domain.bodyOnly(C.step(scope), tail), allowed)))

def iteration(~A: Data, ~observe: R.World -> A,
  ~once: @+w: R.World -> @+rest: List<&2, C.Task> -> @+stack: List<&2, R.Value> -> @+phase: Steps.Phase -> @allowed: {Domain.bodyPhase(phase) == True{} : Bool} -> {observe(C.world(C.step(Steps.input(w, rest, stack, phase)))) == observe(w) : A},
  -scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {Domain.bodyOnly(scope, programme) == True{} : Bool}) ->
  {observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))) == observe(C.world(scope)) : A}:
  Equal.trans(A, observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))), observe(C.world(Steps.run(scope, programme, scope))), observe(C.world(scope)),
    Equal.sym(A, observe(C.world(Steps.run(scope, programme, scope))), observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))),
      Equal.cong(C.Machine, A, machine => observe(C.world(machine)), Steps.run(scope, programme, scope), Steps.iterate(Steps.height(scope, programme), scope), Steps.actualSteps(scope, programme, scope))), preserves(A, observe, once, scope, programme, allowed))
