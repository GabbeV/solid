# Any finite callback-free source-helper staging history. A new scheduled flush
# or host callback is not silently executed inside these event boundaries.
import Base
import ../representation/records.bend as R
import ../runtime/write.bend as W
import ./committed-storage-frame.bend as Frame
import ./staging-committed-frame.bend as Stage
import ./setter-committed-frame.bend as Setter

type Write is Data:
  StageWrite{id: Nat, value: R.Value}
  ResolvedWrite{id: Nat, current: R.Value, value: R.Value}

def run(writes: List<&2, Write>, w: R.World) -> R.World:
  match writes:
    case Nil{}: w
    case StageWrite{id, value} <> rest: run(rest, W.stageResolved(w, id, value))
    case ResolvedWrite{id, current, value} <> rest: run(rest, W.setResolved(w, id, current, value))

def preserves(+writes: List<&2, Write>, +w: R.World) ->
  {Frame.observe(run(writes, w)) == Frame.observe(w) : Frame.View}:
  match writes:
    case Nil{}: {==}
    case StageWrite{+id, +value} <> +rest:
      Frame.compose(w, W.stageResolved(w, id, value), run(rest, W.stageResolved(w, id, value)), preserves(rest, W.stageResolved(w, id, value)), Stage.stages(w, id, value))
    case ResolvedWrite{+id, +current, +value} <> +rest:
      Frame.compose(w, W.setResolved(w, id, current, value), run(rest, W.setResolved(w, id, current, value)), preserves(rest, W.setResolved(w, id, current, value)), Setter.resolved(w, id, current, value))
