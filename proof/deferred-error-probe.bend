# Small diagnostic projection for the compiled catch-boundary negative control.
# The arbitrary-World theorem lives in deferred-error-catch.bend. Keeping this
# assertion Boolean avoids expanding an entire symbolic World on a rejection.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/construct-state.bend as N
import ../runtime/deferred-runtime.bend as D

def marked() -> R.World:
  +w = N.computed(B.empty(), R.Literal{R.Undefined{}}, N.defaults(), 0n)
  +pair = D.allocate(w)
  +w = B.first(R.World, Nat, pair)
  D.ask(D.setNode(w, 1n, 1n), 1n, R.Reference{3n})

def after() -> R.World:
  C.world(C.deferredUnwind(R.World.with_fault(marked(), R.CallbackThrown{R.Reference{9n}}), [], 1n, True{}, [], R.CallbackThrown{R.Reference{9n}}))

def released() -> {R.DeferredCell.marked(D.cell(after(), 1n)) == False{} : Bool}:
  {==}
