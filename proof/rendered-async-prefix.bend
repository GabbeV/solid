# The existing actual fulfillment-frame contract implies the selected renderer
# observation. This does not execute its queued trim, settlement or flush.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./async-write-prefix.bend as Prefix
import ./rendered-observation.bend as View

def preserves(+renderers: List<&2, Nat>, +targets: List<&2, Nat>, +w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {View.observe(renderers, targets, C.world(C.asyncWrite(w, rest, stack, id, result, value, then))) == View.observe(renderers, targets, w) : View.View}:
  View.fromCommitted(renderers, targets, w, C.world(C.asyncWrite(w, rest, stack, id, result, value, then)), Prefix.observed(w, rest, stack, id, result, value, then, custom, override))
