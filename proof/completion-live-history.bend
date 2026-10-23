# Actual completion/check histories preserve live-list occurrences. Completeness
# of the initial live list and once-only completion remain external obligations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./rendered-completion-history.bend as History
import ./action-live-selection.bend as Action
import ./live-membership.bend as Live

def finishLength(+length: Nat, +scope: R.World, +root: Nat, +programme: History.Programme<scope, root>, +w: R.World,
  room: {History.height(scope, root, programme) == length : Nat}) ->
  {R.World.transactions(History.finish(scope, root, programme, w)) == R.World.transactions(w) : List<&2, Nat>}:
  match length programme:
    case 0n History.CompletionEnd{}: {==}
    case 1n+n History.CompletionEnd{}: {==}
    case 0n History.CompletionStep{+id, +remaining, +resolution, +positive, +tail}:
      Empty.absurd({R.World.transactions(History.finish(scope, root, History.CompletionStep{id, remaining, resolution, positive, tail}, w)) == R.World.transactions(w) : List<&2, Nat>}, History.nonzero(History.height(A.done(scope, id), root, tail), room))
    case 0n History.BlockCheck{+tail}:
      Empty.absurd({R.World.transactions(History.finish(scope, root, History.BlockCheck{tail}, w)) == R.World.transactions(w) : List<&2, Nat>}, History.nonzero(History.height(scope, root, tail), room))
    case 1n+n History.CompletionStep{+id, +remaining, +resolution, +positive, +tail}:
      Equal.trans(List<&2, Nat>, R.World.transactions(History.finish(A.done(scope, id), root, tail, A.done(w, id))), R.World.transactions(A.done(w, id)), R.World.transactions(w),
        finishLength(n, A.done(scope, id), root, tail, A.done(w, id), History.predecessorEqual(History.height(A.done(scope, id), root, tail), n, room)), Action.doneLive(w, id))
    case 1n+n History.BlockCheck{+tail}:
      finishLength(n, scope, root, tail, w, History.predecessorEqual(History.height(scope, root, tail), n, room))

def finish(+scope: R.World, +root: Nat, +programme: History.Programme<scope, root>, +w: R.World) ->
  {R.World.transactions(History.finish(scope, root, programme, w)) == R.World.transactions(w) : List<&2, Nat>}:
  finishLength(History.height(scope, root, programme), scope, root, programme, w, {==})

def observed(+w: R.World, +root: Nat, +programme: History.Programme<w, root>, certificate: History.Certified<w, root, programme>) ->
  {R.World.transactions(History.world(History.run(w, root, programme, w))) == R.World.transactions(w) : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, R.World.transactions(History.world(History.run(w, root, programme, w))), R.World.transactions(History.finish(w, root, programme, w)), R.World.transactions(w),
    Equal.cong(History.Audit, List<&2, Nat>, result => R.World.transactions(History.world(result)), History.run(w, root, programme, w), History.Audit{History.finish(w, root, programme, w), History.expected(w, root, programme)}, History.equation(w, root, programme, certificate)), finish(w, root, programme, w))

def retained(+w: R.World, +root: Nat, +programme: History.Programme<w, root>, certificate: History.Certified<w, root, programme>, location: Live.Located<R.World.transactions(w), root>) ->
  Live.Located<R.World.transactions(History.world(History.run(w, root, programme, w))), root>:
  Live.cast(R.World.transactions(w), R.World.transactions(History.world(History.run(w, root, programme, w))), root,
    Equal.sym(List<&2, Nat>, R.World.transactions(History.world(History.run(w, root, programme, w))), R.World.transactions(w), observed(w, root, programme, certificate)), location)
