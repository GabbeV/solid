# Actual pending-body prefixes preserve subscriber kind/config/head and links.
# The same body classifier/certificates are used by committed-content safety.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./subscriber-topology-frame.bend as Frame
import ./core-pending-topology.bend as CoreFrame
import ./pending-stack-history.bend as Steps
import ./pending-committed-history.bend as Domain
import ./pending-prefix-frame.bend as Generic
import ./list-update-lookup.bend as Logic

def once(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +phase: Steps.Phase,
  allowed: {Domain.bodyPhase(phase) == True{} : Bool}) ->
  {Frame.observe(C.world(C.step(Steps.input(w, rest, stack, phase)))) == Frame.observe(w) : Frame.View}:
  match phase:
    case Steps.AfterTrim{id}: CoreFrame.afterTrim(w, rest, stack, id)
    case Steps.Pending{tasks, visited, released, scheduled}: CoreFrame.step(w, rest, stack, tasks, visited, released, scheduled)
    case Steps.Schedule{}: CoreFrame.schedule(w, rest, stack)
    case Steps.OwnerWork{tasks, neutral}:
      Empty.absurd({Frame.observe(C.world(C.step(Steps.input(w, rest, stack, Steps.OwnerWork{tasks, neutral})))) == Frame.observe(w) : Frame.View}, Logic.impossible(Equal.sym(Bool, False{}, True{}, allowed)))


def iterationFrame(-scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {Domain.bodyOnly(scope, programme) == True{} : Bool}) ->
  {Frame.observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))) == Frame.observe(C.world(scope)) : Frame.View}:
  Generic.iteration(Frame.View, state => Frame.observe(state), once, scope, programme, allowed)

def selectedNode(+scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {Domain.bodyOnly(scope, programme) == True{} : Bool}, id: Nat) ->
  {Frame.shape(B.node(C.world(Steps.iterate(Steps.height(scope, programme), scope)), id)) == Frame.shape(B.node(C.world(scope), id)) : Frame.Shape}:
  Frame.read(C.world(scope), C.world(Steps.iterate(Steps.height(scope, programme), scope)), id, iterationFrame(scope, programme, allowed))

def selectedLink(+scope: C.Machine, +programme: Steps.Programme<scope>, allowed: {Domain.bodyOnly(scope, programme) == True{} : Bool}, +edge: Nat) ->
  {B.link(C.world(Steps.iterate(Steps.height(scope, programme), scope)), edge) == B.link(C.world(scope), edge) : R.Link}:
  Equal.cong(Frame.View, R.Link, view => B.get(R.Link, Frame.edges(view), edge, B.blank_link()), Frame.observe(C.world(Steps.iterate(Steps.height(scope, programme), scope))), Frame.observe(C.world(scope)), iterationFrame(scope, programme, allowed))
