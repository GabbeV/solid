# Compose exact prefixes of the real step relation, retaining all caller work.
import Base
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def compose(+first: Nat,+second: Nat,+before: C.Machine,+middle: C.Machine,+after: C.Machine,prefix: {Steps.iterate(first,before) == middle : C.Machine},suffix: {Steps.iterate(second,middle) == after : C.Machine}) -> {Steps.iterate(Nat.add(first,second),before) == after : C.Machine}:
  Equal.trans(C.Machine,Steps.iterate(Nat.add(first,second),before),Steps.iterate(second,Steps.iterate(first,before)),after,Driver.iterationsCompose(first,second,before),Equal.trans(C.Machine,Steps.iterate(second,Steps.iterate(first,before)),Steps.iterate(second,middle),after,Equal.cong(C.Machine,C.Machine,state=>Steps.iterate(second,state),Steps.iterate(first,before),middle,prefix),suffix))
