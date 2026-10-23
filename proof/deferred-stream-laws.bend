# Scoped source-wrapper/producer-boundary properties. These do not establish
# arbitrary stream or graph progress. All World conclusions retain the actual
# runtime helpers, not a replacement iterator evaluator.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/deferred-stream.bend as D
import ../runtime/iterator-input.bend as Input
import ../runtime/core.bend as C

def firstThrow(w: R.World, id: Nat, error: R.Value) ->
  {D.firstInput(w, id, R.ThrowNext{error}) == B.Bundle{w, R.ThrowNext{error}} : B.Bundle<R.World, R.NextInput>}:
  {==}

def unresolved(w: R.World, id: Nat, observer: Nat, immediate: Bool) ->
  {D.observeState(w, id, observer, immediate, R.Unresolved{}) == w : R.World}:
  {==}

def missing(w: R.World) ->
  {D.returnInput(w, Input.MissingReturn{}) == D.resolvedDone(w) : B.Bundle<R.World, Input.Returned>}:
  {==}

def undefinedReturn(w: R.World) ->
  {D.returnInput(w, Input.RawReturn{R.Undefined{}}) == D.resolvedDone(w) : B.Bundle<R.World, Input.Returned>}:
  {==}

def nullReturn(w: R.World) ->
  {D.returnInput(w, Input.RawReturn{R.Null{}}) == D.resolvedDone(w) : B.Bundle<R.World, Input.Returned>}:
  {==}

def nonnullReturn(+w: R.World, +value: R.Value, plain: {B.nullish(value) == False{} : Bool}) ->
  {D.returnInput(w, Input.RawReturn{value}) == B.Bundle{w, Input.RawReturn{value}} : B.Bundle<R.World, Input.Returned>}:
  Equal.cong(Bool, B.Bundle<R.World, Input.Returned>, absent => B.choose(~B.Bundle<R.World, Input.Returned>, absent,
    _ => D.resolvedDone(w), _ => B.Bundle{w, Input.RawReturn{value}}), B.nullish(value), False{}, plain)

def promiseReturn(w: R.World, result: Nat) ->
  {D.returnInput(w, Input.PromiseReturn{result}) == B.Bundle{w, Input.PromiseReturn{result}} : B.Bundle<R.World, Input.Returned>}:
  {==}

def throwReturn(w: R.World, error: R.Value) ->
  {D.returnInput(w, Input.ThrowReturn{error}) == B.Bundle{w, Input.ThrowReturn{error}} : B.Bundle<R.World, Input.Returned>}:
  {==}

def doneWorld(+w: R.World) ->
  {B.first(R.World, Input.Returned, D.resolvedDone(w)) == R.World.with_asyncObjects(w, B.append(R.AsyncObject, R.World.asyncObjects(w), [R.AsyncObject{False{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, [], 0n}])) : R.World}:
  {==}

def doneValue(w: R.World) ->
  {B.second(R.World, Input.Returned, D.resolvedDone(w)) == Input.PromiseReturn{B.length(R.AsyncObject, R.World.asyncObjects(w))} : Input.Returned}:
  {==}

# Protocol throws occur after fn's catch, so this continuation does not turn
# them into source-function throws or silently repair the upstream flight bug.
def serveUnwind(w: R.World, cell: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>) ->
  {C.unwind(w, C.DeferredAfterIterator{cell} <> rest, stack) == C.Machine{w, rest, stack} : C.Machine}:
  {==}
