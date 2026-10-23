# Derive a real held scan position after the actual completion/check audit.
# Initial pending snapshot and live occurrence remain explicit inputs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./rendered-completion-history.bend as History
import ./pending-rendered-snapshot.bend as Snapshot
import ./completion-live-history.bend as LiveHistory
import ./live-membership.bend as Live
import ./constructed-landing-selection.bend as Selection

def move(-a: R.World, -b: R.World, -root: Nat, same: {a == b : R.World}, snapshot: Snapshot.Pending<a, root>) -> Snapshot.Pending<b, root>:
  %same : Snapshot.Pending<_, root>
  snapshot

def after(+w: R.World, +predecessor: Nat, +programme: History.Programme<w, 1n+predecessor>, +certificate: History.Certified<w, 1n+predecessor, programme>, location: Live.Located<R.World.transactions(w), 1n+predecessor>,
  +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +frame: C.SeamFrame) ->
  Selection.Selected<History.world(History.run(w, 1n+predecessor, programme, w)), 1n+predecessor, rest, stack, frame>:
  match certificate:
    case History.HeldHistory{+equation, +pending, +healthy, +graph}:
      +root = {1n+predecessor : Nat}
      +observed = History.world(History.run(w, root, programme, w))
      +final = History.finish(w, root, programme, w)
      +membership = LiveHistory.retained(w, root, programme, History.HeldHistory{equation, pending, healthy, graph}, location)
      +same = Equal.cong(History.Audit, R.World, result => History.world(result), History.run(w, root, programme, w), History.Audit{final, History.expected(w, root, programme)}, equation)
      Selection.fromMember(observed, root, rest, stack, frame, membership,
        Snapshot.blocked(observed, predecessor, R.Transaction.open(B.transaction(observed, root)),
          move(final, observed, root, Equal.sym(R.World, observed, final, same), pending),
          Equal.trans(Bool, B.ok(observed), B.ok(final), True{}, Equal.cong(R.World, Bool, state => B.ok(state), observed, final, same), healthy), {==}))
