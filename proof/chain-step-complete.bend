# Complete a successful source PassReleases/publication return point, with the
# arena/machines abstract so conversion does not execute a whole concrete graph.
import Base
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../runtime/equality.bend as EQ
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/memo-cuts.bend as Existing
import ./chain-cuts.bend as Cuts

def complete(+m: C.Machine, +w: R.World, +rest: List<&2, C.Task>, +id: Nat, +height: Nat, +previous: R.Value, +value: R.Value, +endWorld: R.World, +end: C.Machine,
  shape: {m == C.Machine{w, C.PassReleases{Cuts.frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{}} <> rest, []} : C.Machine},
  +ready: {B.ok(w) == True{} : Bool},
  empty: {B.get(List<&2, Nat>, R.World.releaseLists(w), 0n, []) == [] : List<&2, Nat>},
  tail: {R.World.with_fault(C.passFinallyTail(w, id, False{}), R.Healthy{}) == w : R.World},
  live: {B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED()) == False{} : Bool},
  clean: {Bool.or(B.truth(R.NodeExtension.error(B.extension(w, id))), False{}) == False{} : Bool},
  seat: {R.World.passLane(w) == 0n : Nat},
  ordinary: {C.publicationOutcome(C.markPublishedEffect(w, id, value, False{}, C.publicationChanged(w, id, value, False{}), 0n), id, False{}, 0n) == False{} : Bool},
  defaultEq: {EQ.custom(w, id) == 0n : Nat},
  published: {C.publishValue(w, id, value, False{}, height, False{}, False{}) == B.Bundle{endWorld, True{}} : B.Bundle<R.World, Bool>},
  finished: {C.publicationCompleted(C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest, [], id, R.Number{0n}, 0n, False{}, B.Bundle{endWorld, True{}}) == end : C.Machine}) ->
  {C.step(m) == end : C.Machine}:
  +ending = {C.FinishPublication{id, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
  +a = C.passReleases(w, rest, [], Cuts.frame(id, height, previous), 0n, value, False{}, False{}, False{}, R.Healthy{})
  +b = Cuts.afterRelease(id, height, previous, w, rest, [], value)
  +c = C.afterPass(w, rest, [], id, False{}, value, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
  +d = C.publishState(w, ending, [], id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
  +e = C.publicationCompleted(ending, [], id, R.Number{0n}, 0n, False{}, B.Bundle{endWorld, True{}})
  Equal.trans(C.Machine, C.step(m), a, end,
    Cuts.step_from_shape(id, height, previous, m, w, rest, [], value, shape, ready),
    Equal.trans(C.Machine, a, b, end, Cuts.release_empty(id, height, previous, w, rest, [], value, empty),
      Equal.trans(C.Machine, b, c, end, Cuts.after_release_identity(id, height, previous, w, rest, [], value, tail, ready),
        Equal.trans(C.Machine, c, d, end, Cuts.after_pass_live(id, height, previous, w, rest, [], value, live, clean, seat),
          Equal.trans(C.Machine, d, e, end,
            Existing.default_publish(w, ending, [], id, value, False{}, height, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{endWorld, True{}}, {==}, defaultEq, ordinary, published), finished)))))
