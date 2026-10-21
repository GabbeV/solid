# Concrete owner execution through the SAME active teardown/callback machine.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct.bend as N
import ../runtime/owner.bend as O

def scenario() -> R.World:
  +w = N.createOwner(N.createOwner(B.empty(), 0n, False{}), 1n, False{})
  +programs = {[R.CleanupProgram{[], False{}, 0n}, R.CleanupProgram{[R.CleanupEmit{11n}], False{}, 0n},
    R.CleanupProgram{[R.CleanupEmit{22n}, R.CleanupDispose{1n}], False{}, 0n},
    R.CleanupProgram{[R.CleanupEmit{33n}], False{}, 0n}, R.CleanupProgram{[R.CleanupEmit{44n}], False{}, 0n}] : List<&2, R.CleanupProgram>}
  +w = R.World.with_cleanupPrograms(w, programs)
  +w = O.cleanup(O.cleanup(O.cleanup(w, 1n, 3n), 2n, 1n), 2n, 2n)
  +w = B.store_node(w, 2n, R.Node.with_cleanup(B.node(w, 2n), 4n))
  # The owner's detached disposal list is mid-drain when its second callback
  # disposes the root and re-enters it. Teardown executes the stored programs;
  # the resulting callback trace is not supplied to the machine.
  O.disposeChildren(w, 2n, False{}, False{})

type View is Data:
  View{rootFlags: U32, childFlags: U32, rootHead: Nat, childHead: Nat,
    rootDisposal: R.Disposal, childDisposal: R.Disposal, effectCleanup: Nat,
    events: List<&2, R.TraceEvent>, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.flags(B.node(w, 1n)), R.Node.flags(B.node(w, 2n)),
    R.Node.firstChild(B.node(w, 1n)), R.Node.firstChild(B.node(w, 2n)),
    R.Node.disposal(B.node(w, 1n)), R.Node.disposal(B.node(w, 2n)),
    R.Node.cleanup(B.node(w, 2n)), R.World.events(w), R.World.fault(w)}

def expected() -> View:
  View{64, 64, 0n, 0n, R.NoDisposal{}, R.NoDisposal{}, 0n,
    [R.CleanupObserved{2n, 22n}, R.CleanupObserved{4n, 44n},
     R.CleanupObserved{3n, 33n}, R.CleanupObserved{1n, 11n}], R.Healthy{}}
