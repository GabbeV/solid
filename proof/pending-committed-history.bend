# Reuse the certified actual-step prefixes, selecting callback-free settlement
# phases. This is a content frame, not a global termination/publication theorem.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./committed-storage-frame.bend as Frame
import ./core-pending-frame.bend as CoreFrame
import ./pending-stack-history.bend as Steps
import ./empty-settlement-completion.bend as EmptySegment
import ./rendered-observation.bend as Rendered
import ./list-update-lookup.bend as Logic

def bodyPhase(phase: Steps.Phase) -> Bool:
  match phase:
    case Steps.AfterTrim{id}: True{}
    case Steps.Pending{tasks, visited, released, scheduled}: True{}
    case Steps.Schedule{}: True{}
    case Steps.OwnerWork{tasks, allowed}: False{}

def bodyOnly(-scope: C.Machine, programme: Steps.Programme<scope>) -> Bool:
  match programme:
    case Steps.End{}: True{}
    case Steps.Step{world, rest, stack, phase, layout, tail}:
      Bool.and(bodyPhase(phase), bodyOnly(C.step(scope), tail))

def andLeft(+left: Bool, +right: Bool, both: {Bool.and(left, right) == True{} : Bool}) ->
  {left == True{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: Empty.absurd({False{} == True{} : Bool}, Logic.impossible(Equal.sym(Bool, False{}, True{}, both)))

def andRight(+left: Bool, +right: Bool, both: {Bool.and(left, right) == True{} : Bool}) ->
  {right == True{} : Bool}:
  match left:
    case True{}: both
    case False{}: Empty.absurd({right == True{} : Bool}, Logic.impossible(Equal.sym(Bool, False{}, True{}, both)))

def inputWorld(+w: R.World, rest: List<&2, C.Task>, stack: List<&2, R.Value>, phase: Steps.Phase) ->
  {C.world(Steps.input(w, rest, stack, phase)) == w : R.World}:
  match phase:
    case Steps.AfterTrim{id}: {==}
    case Steps.Pending{tasks, visited, released, scheduled}: {==}
    case Steps.Schedule{}: {==}
    case Steps.OwnerWork{tasks, allowed}: {==}

def once(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Steps.Phase,
  allowed: {bodyPhase(phase) == True{} : Bool}) ->
  {Frame.observe(C.world(C.step(Steps.input(w, rest, stack, phase)))) == Frame.observe(w) : Frame.View}:
  match phase:
    case Steps.AfterTrim{id}: CoreFrame.afterTrim(w, rest, stack, id)
    case Steps.Pending{tasks, visited, released, scheduled}: CoreFrame.step(w, rest, stack, tasks, visited, released, scheduled)
    case Steps.Schedule{}: CoreFrame.schedule(w, rest, stack)
    case Steps.OwnerWork{tasks, neutral}:
      Empty.absurd({Frame.observe(C.world(C.step(Steps.input(w, rest, stack, Steps.OwnerWork{tasks, neutral})))) == Frame.observe(w) : Frame.View}, Logic.impossible(Equal.sym(Bool, False{}, True{}, allowed)))

def machineOnce(-machine: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Steps.Phase,
  +layout: {machine == Steps.input(w, rest, stack, phase) : C.Machine}, allowed: {bodyPhase(phase) == True{} : Bool}) ->
  {Frame.observe(C.world(C.step(machine))) == Frame.observe(C.world(machine)) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(C.world(C.step(machine))), Frame.observe(C.world(C.step(Steps.input(w, rest, stack, phase)))), Frame.observe(C.world(machine)),
    Equal.cong(C.Machine, Frame.View, actual => Frame.observe(C.world(C.step(actual))), machine, Steps.input(w, rest, stack, phase), layout),
    Equal.trans(Frame.View, Frame.observe(C.world(C.step(Steps.input(w, rest, stack, phase)))), Frame.observe(w), Frame.observe(C.world(machine)), once(w, rest, stack, phase, allowed),
      Equal.sym(Frame.View, Frame.observe(C.world(machine)), Frame.observe(w),
        Equal.trans(Frame.View, Frame.observe(C.world(machine)), Frame.observe(C.world(Steps.input(w, rest, stack, phase))), Frame.observe(w),
          Equal.cong(C.Machine, Frame.View, actual => Frame.observe(C.world(actual)), machine, Steps.input(w, rest, stack, phase), layout),
          Equal.cong(R.World, Frame.View, actual => Frame.observe(actual), C.world(Steps.input(w, rest, stack, phase)), w, inputWorld(w, rest, stack, phase))))))

def preserves(-scope: C.Machine, +programme: Steps.Programme<scope>, +allowed: {bodyOnly(scope, programme) == True{} : Bool}) ->
  {Frame.observe(C.world(Steps.run(scope, programme, scope))) == Frame.observe(C.world(scope)) : Frame.View}:
  match programme:
    case Steps.End{}: {==}
    case Steps.Step{world, rest, stack, +phase, layout, +tail}:
      Equal.trans(Frame.View, Frame.observe(C.world(Steps.run(C.step(scope), tail, C.step(scope)))), Frame.observe(C.world(C.step(scope))), Frame.observe(C.world(scope)),
        preserves(C.step(scope), tail, andRight(bodyPhase(phase), bodyOnly(C.step(scope), tail), allowed)),
        machineOnce(scope, world, rest, stack, phase, layout, andLeft(bodyPhase(phase), bodyOnly(C.step(scope), tail), allowed)))

def iterationFrame(-scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {bodyOnly(scope, programme) == True{} : Bool}) ->
  {Frame.observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))) == Frame.observe(C.world(scope)) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))), Frame.observe(C.world(Steps.run(scope, programme, scope))), Frame.observe(C.world(scope)),
    Equal.sym(Frame.View, Frame.observe(C.world(Steps.run(scope, programme, scope))), Frame.observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))),
      Equal.cong(C.Machine, Frame.View, machine => Frame.observe(C.world(machine)), Steps.run(scope, programme, scope), Steps.iterate(Steps.height(scope, programme), scope), Steps.actualSteps(scope, programme, scope))), preserves(scope, programme, allowed))

def rendered(+scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {bodyOnly(scope, programme) == True{} : Bool}, renderers: List<&2, Nat>, targets: List<&2, Nat>) ->
  {Rendered.observe(renderers, targets, C.world(Steps.iterate(Steps.height(scope, programme), scope))) == Rendered.observe(renderers, targets, C.world(scope)) : Rendered.View}:
  Rendered.fromCommitted(renderers, targets, C.world(scope), C.world(Steps.iterate(Steps.height(scope, programme), scope)), iterationFrame(scope, programme, allowed))

# The existing successful six-step constructor is in this content-safe domain.
# Input graph/health facts are used by the constructor, not desired transitions.
def constructedBody(w: R.World, id: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, healthy: {B.ok(w) == True{} : Bool}) ->
  {bodyOnly(EmptySegment.start(w, id, rest, stack), EmptySegment.programme(w, id, rest, stack, noSubscribers, healthy)) == True{} : Bool}:
  {==}
