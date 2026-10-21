import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-states.bend as M
import ./memo-driver.bend as Driver
import ./paths.bend as P
import ./memo-staging.bend as Existing
import ./memo-constructor-data.bend as D
import ./memo-constructor-steps.bend as Steps
import ./memo-constructor-cuts.bend as Cuts
import ./memo-constructor-driver.bend as CD

def initial_shape() -> {Cuts.prepare(CD.signal()) == D.state_0() : C.Machine}:
  {==}

def final_shape() -> {Cuts.restore(CD.signal(), C.world(D.state_14())) == M.origin() : R.World}:
  {==}

def witness() -> P.Path<D.state_0(), D.state_14()>:
  P.PathStep{D.state_1(), Steps.step_0(), P.PathStep{D.state_2(), Steps.step_1(), P.PathStep{D.state_3(), Steps.step_2(), P.PathStep{D.state_4(), Steps.step_3(), P.PathStep{D.state_5(), Steps.step_4(), P.PathStep{D.state_6(), Steps.step_5(), P.PathStep{D.state_7(), Steps.step_6(), P.PathStep{D.state_8(), Steps.step_7(), P.PathStep{D.state_9(), Steps.step_8(), P.PathStep{D.state_10(), Steps.step_9(), P.PathStep{D.state_11(), Steps.step_10(), P.PathStep{D.state_12(), Steps.step_11(), P.PathStep{D.state_13(), Steps.step_12(), P.PathStep{D.state_14(), Steps.step_13(), P.PathEnd{C.world(D.state_14()), [], {==}, {==}}}}}}}}}}}}}}}}


def completed() -> {C.run(256n, D.state_0()) == D.state_14() : C.Machine}:
  Existing.retimed(D.state_0(), D.state_14(), witness(), 242n, 256n, {==})

def constructor_eq() -> {Driver.base() == M.origin() : R.World}:
  Equal.trans(R.World, Driver.base(), Cuts.restore(CD.signal(), C.world(C.run(256n, D.state_0()))), M.origin(), Cuts.from_shape(256n, CD.signal(), D.state_0(), initial_shape()),
    Equal.trans(R.World, Cuts.restore(CD.signal(), C.world(C.run(256n, D.state_0()))), Cuts.restore(CD.signal(), C.world(D.state_14())), M.origin(),
      Equal.cong(C.Machine, R.World, machine => Cuts.restore(CD.signal(), C.world(machine)), C.run(256n, D.state_0()), D.state_14(), completed()), final_shape()))
