# Quantified local source wrapIterable boundaries, separate from complete
# programme/progress claims. All World conclusions retain the actual helpers.
import Base
import ../runtime/from-state.bend as From
import ../runtime/deferred-stream.bend as DeferredStream
import ../runtime/iterator-input.bend as Input
import ../runtime/promise-input.bend as Promise
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/from-wrap.bend as W
import ../runtime/core.bend as C

def bare(w: R.World, plan: Nat, done: Bool, value: R.Value) ->
  {W.wrapInput(w, plan, R.BareNext{done, value}) == B.Bundle{w, R.BareNext{done, value}} : B.Bundle<R.World, R.NextInput>}:
  {==}

def thrown(w: R.World, plan: Nat, error: R.Value) ->
  {W.wrapInput(w, plan, R.ThrowNext{error}) == B.Bundle{w, R.ThrowNext{error}} : B.Bundle<R.World, R.NextInput>}:
  {==}

def unresolved(w: R.World, plan: Nat, output: Nat, observer: Nat, immediate: Bool) ->
  {W.observerState(w, plan, output, observer, immediate, R.Unresolved{}) == w : R.World}:
  {==}

def canceledDelivery(+w: R.World, +plan: Nat, +output: Nat, +rejected: Bool, +value: R.Value, known: {W.has(R.FromWrapped.pending(W.get(w, plan)), output) == False{} : Bool}) ->
  {W.deliver(w, plan, output, rejected, value) == w : R.World}:
  Equal.cong(Bool, R.World, present => B.choose(~R.World, present,
    _ =>
      +s = W.get(w, plan)
      +w = W.store(w, plan, R.FromWrapped.with_pending(s, W.remove(R.FromWrapped.pending(s), output)))
      # This is the actual once-only native Promise resolver boundary.
      # The qualified helper is imported below, not a replacement operation.
      Promise.settle(w, output, rejected, value),
    _ => w), W.has(R.FromWrapped.pending(W.get(w, plan)), output), False{}, known)

def noPending(w: R.World) ->
  {W.resolvePending([], w) == w : R.World}:
  {==}

def noWaits(observer: Nat) ->
  {W.findWait([], observer) == 0n : Nat}:
  {==}

def noPlans(observer: Nat, id: Nat) ->
  {W.findPlans([], observer, id) == B.Bundle{0n, 0n} : B.Bundle<Nat, Nat>}:
  {==}

def removeEmpty(id: Nat) ->
  {W.remove([], id) == [] : List<&2, Nat>}:
  {==}

def returnThrow(+w: R.World, rest: List<&2, C.Task>, +saved: List<&2, R.Value>, cause: R.Value) ->
  {C.fromWrapFinishFinally(w, rest, saved, R.CallbackThrown{cause}) == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved} : C.Machine}:
  {==}

def returnTypeError(+w: R.World, rest: List<&2, C.Task>, +saved: List<&2, R.Value>) ->
  {C.fromWrapFinishFinally(w, rest, saved, R.TypeError{}) == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.StepResult{True{}, R.Undefined{}} <> saved} : C.Machine}:
  {==}

def preserveExhaustion(w: R.World, rest: List<&2, C.Task>, saved: List<&2, R.Value>) ->
  {C.fromWrapFinishFinally(w, rest, saved, R.Exhausted{}) == C.Machine{w, rest, saved} : C.Machine}:
  {==}

def finishSelected(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +plan: Nat, closed: Bool) -> C.Machine:
  B.choose(~C.Machine, closed,
    _ => C.Machine{w, rest, R.StepResult{True{}, R.Undefined{}} <> stack},
    _ => C.Machine{W.finish(w, plan), C.IteratorReturn{R.FromWrapped.inner(W.get(w, plan)), R.Empty{}} <> C.FromWrapFinishFinally{stack} <> rest, stack})

def alreadyClosed(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, id: Nat, tail: List<&2, R.CleanupAction>, first: R.Value, second: R.Value, +plan: Nat, known: {R.FromWrapped.closed(W.get(w, plan)) == True{} : Bool}) ->
  {C.callbackAction(w, rest, stack, id, tail, first, second, R.FromWrappedFinish{plan}) == C.Machine{w, rest, R.StepResult{True{}, R.Undefined{}} <> stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, closed => finishSelected(w, rest, stack, plan, closed), R.FromWrapped.closed(W.get(w, plan)), True{}, known)

# A deferred result's iterable factory returns its captured iterator s. Opening
# it from another wrapper must preserve that identity instead of inventing a
# second external factory call.
def cachedOpen(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +source: Nat, cached: Bool) -> C.Machine:
  +pair = B.choose(~B.Bundle<R.World, Nat>, cached,
    _ => B.Bundle{w, DeferredStream.iterator(w, source)}, _ => Input.open(w, source))
  C.Machine{B.first(R.World, Nat, pair), C.FromWrapOpened{} <> rest, R.IteratorReference{B.second(R.World, Nat, pair)} <> stack}

def factoryOpen(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +source: Nat, factory: Bool) -> C.Machine:
  B.choose(~C.Machine, factory,
    _ => C.Machine{w, C.FromOpen{source} <> C.FromWrapOpened{} <> rest, stack},
    _ => cachedOpen(w, rest, stack, source, Nat.is_ne(DeferredStream.planWrapper(w, source), 0n)))

def cachedIterator(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +source: Nat, ordinary: {From.factory(w, source) == False{} : Bool}, cached: {Nat.is_ne(DeferredStream.planWrapper(w, source), 0n) == True{} : Bool}) ->
  {C.fromOpenState(w, rest, stack, R.FromIterable{source}) == C.Machine{w, C.FromWrapOpened{} <> rest, R.IteratorReference{DeferredStream.iterator(w, source)} <> stack} : C.Machine}:
  Equal.trans(C.Machine, C.fromOpenState(w, rest, stack, R.FromIterable{source}), cachedOpen(w, rest, stack, source, Nat.is_ne(DeferredStream.planWrapper(w, source), 0n)), C.Machine{w, C.FromWrapOpened{} <> rest, R.IteratorReference{DeferredStream.iterator(w, source)} <> stack},
    Equal.cong(Bool, C.Machine, factory => factoryOpen(w, rest, stack, source, factory), From.factory(w, source), False{}, ordinary),
    Equal.cong(Bool, C.Machine, yes => cachedOpen(w, rest, stack, source, yes), Nat.is_ne(DeferredStream.planWrapper(w, source), 0n), True{}, cached))
