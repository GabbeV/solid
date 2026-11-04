# Checked: actual chain transitions and proof-only publication transports.
import Base
import ./deferred-read-cut.bend as ReadCut
import ./natural-netted-value.bend as Natural
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/memo-cuts.bend as Existing
import ./chain-cuts.bend as Cuts
import ./chain-publication.bend as Publish
import ./chain-step-complete.bend as Complete
import ./chain-states.bend as M

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def stepAt_0(+netted: Bool,+input: Nat) -> {C.step(M.at_0(netted,input)) == M.at_1(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_0(+input: Nat) -> {C.step(M.state_0(input)) == M.state_1(input) : C.Machine}:
  stepAt_0(Nat.is_eq(input,0n),input)

def stepAt_1(+netted: Bool,+input: Nat) -> {C.step(M.at_1(netted,input)) == M.at_2(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_1(+input: Nat) -> {C.step(M.state_1(input)) == M.state_2(input) : C.Machine}:
  stepAt_1(Nat.is_eq(input,0n),input)

def stepAt_2(+netted: Bool,+input: Nat) -> {C.step(M.at_2(netted,input)) == M.at_3(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_2(+input: Nat) -> {C.step(M.state_2(input)) == M.state_3(input) : C.Machine}:
  stepAt_2(Nat.is_eq(input,0n),input)

def stepAt_3(+netted: Bool,+input: Nat) -> {C.step(M.at_3(netted,input)) == M.at_4(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_3(+input: Nat) -> {C.step(M.state_3(input)) == M.state_4(input) : C.Machine}:
  stepAt_3(Nat.is_eq(input,0n),input)

def stepAt_4(+netted: Bool,+input: Nat) -> {C.step(M.at_4(netted,input)) == M.at_5(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_4(+input: Nat) -> {C.step(M.state_4(input)) == M.state_5(input) : C.Machine}:
  stepAt_4(Nat.is_eq(input,0n),input)

def stepAt_5(+netted: Bool,+input: Nat) -> {C.step(M.at_5(netted,input)) == M.at_6(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_5(+input: Nat) -> {C.step(M.state_5(input)) == M.state_6(input) : C.Machine}:
  stepAt_5(Nat.is_eq(input,0n),input)

def stepAt_6(+netted: Bool,+input: Nat) -> {C.step(M.at_6(netted,input)) == M.at_7(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_6(+input: Nat) -> {C.step(M.state_6(input)) == M.state_7(input) : C.Machine}:
  stepAt_6(Nat.is_eq(input,0n),input)

def stepAt_7(+netted: Bool,+input: Nat) -> {C.step(M.at_7(netted,input)) == M.at_8(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_7(+input: Nat) -> {C.step(M.state_7(input)) == M.state_8(input) : C.Machine}:
  stepAt_7(Nat.is_eq(input,0n),input)

def stepAt_8(+netted: Bool,+input: Nat) -> {C.step(M.at_8(netted,input)) == M.at_9(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_8(+input: Nat) -> {C.step(M.state_8(input)) == M.state_9(input) : C.Machine}:
  stepAt_8(Nat.is_eq(input,0n),input)

def readAt_9(+netted: Bool,+input: Nat) -> C.Machine:
  ReadCut.read(C.world(M.at_9(netted,input)),remainder(M.at_9(netted,input)),C.values(M.at_9(netted,input)),2n,netted)

def readExpected_9(+netted: Bool,+input: Nat,value: R.Value) -> C.Machine:
  +w = R.World.with_events(C.world(M.at_10(netted,input)),R.World.events(C.world(M.at_9(netted,input))))
  C.served(w,remainder(M.at_9(netted,input)),C.values(M.at_9(netted,input)),3n,2n,value)

def readCase_9(+netted: Bool,+input: Nat) -> {readAt_9(netted,input) == readExpected_9(netted,input,B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})) : C.Machine}:
  match netted:
    case True{}: {==}
    case False{}: {==}

def step_9(+input: Nat) -> {C.step(M.state_9(input)) == M.state_10(input) : C.Machine}:
  +netted = Nat.is_eq(input,0n)
  +answer = B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})
  Equal.trans(C.Machine,C.step(M.state_9(input)),readExpected_9(netted,input,answer),M.state_10(input),Equal.trans(C.Machine,C.step(M.state_9(input)),readAt_9(netted,input),readExpected_9(netted,input,answer),{==},readCase_9(netted,input)),Equal.cong(R.Value,C.Machine,value=>readExpected_9(netted,input,value),answer,R.Number{input},Natural.pick(0n,input)))

def stepAt_10(+netted: Bool,+input: Nat) -> {C.step(M.at_10(netted,input)) == M.at_11(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_10(+input: Nat) -> {C.step(M.state_10(input)) == M.state_11(input) : C.Machine}:
  stepAt_10(Nat.is_eq(input,0n),input)

def stepAt_11(+netted: Bool,+input: Nat) -> {C.step(M.at_11(netted,input)) == M.at_12(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_11(+input: Nat) -> {C.step(M.state_11(input)) == M.state_12(input) : C.Machine}:
  stepAt_11(Nat.is_eq(input,0n),input)

def stepAt_12(+netted: Bool,+input: Nat) -> {C.step(M.at_12(netted,input)) == M.at_13(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_12(+input: Nat) -> {C.step(M.state_12(input)) == M.state_13(input) : C.Machine}:
  stepAt_12(Nat.is_eq(input,0n),input)

def publish_13(+input: Nat) -> {C.publishValue(C.world(M.state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{}) == B.Bundle{C.world(M.state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_13(input)

def stepAt_13(+netted: Bool,+input: Nat) -> {C.step(M.at_13(netted,input)) == M.at_14(netted,input) : C.Machine}:
  match netted:
    case True{}:
      Complete.complete(M.at_13(True{},input), C.world(M.at_13(True{},input)), remainder(M.at_13(True{},input)), 3n, 0n, R.Number{1n}, R.Number{Nat.add(input, 1n)}, C.world(M.at_14(True{},input)), M.at_14(True{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_13(True{},input), {==})
    case False{}:
      Complete.complete(M.at_13(False{},input), C.world(M.at_13(False{},input)), remainder(M.at_13(False{},input)), 3n, 0n, R.Number{1n}, R.Number{Nat.add(input, 1n)}, C.world(M.at_14(False{},input)), M.at_14(False{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_13(False{},input), {==})

def step_13(+input: Nat) -> {C.step(M.state_13(input)) == M.state_14(input) : C.Machine}:
  stepAt_13(Nat.is_eq(input,0n),input)

def stepAt_14(+netted: Bool,+input: Nat) -> {C.step(M.at_14(netted,input)) == M.at_15(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_14(+input: Nat) -> {C.step(M.state_14(input)) == M.state_15(input) : C.Machine}:
  stepAt_14(Nat.is_eq(input,0n),input)

def stepAt_15(+netted: Bool,+input: Nat) -> {C.step(M.at_15(netted,input)) == M.at_16(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_15(+input: Nat) -> {C.step(M.state_15(input)) == M.state_16(input) : C.Machine}:
  stepAt_15(Nat.is_eq(input,0n),input)

def stepAt_16(+netted: Bool,+input: Nat) -> {C.step(M.at_16(netted,input)) == M.at_17(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_16(+input: Nat) -> {C.step(M.state_16(input)) == M.state_17(input) : C.Machine}:
  stepAt_16(Nat.is_eq(input,0n),input)

def stepAt_17(+netted: Bool,+input: Nat) -> {C.step(M.at_17(netted,input)) == M.at_18(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_17(+input: Nat) -> {C.step(M.state_17(input)) == M.state_18(input) : C.Machine}:
  stepAt_17(Nat.is_eq(input,0n),input)

def stepAt_18(+netted: Bool,+input: Nat) -> {C.step(M.at_18(netted,input)) == M.at_19(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_18(+input: Nat) -> {C.step(M.state_18(input)) == M.state_19(input) : C.Machine}:
  stepAt_18(Nat.is_eq(input,0n),input)

def stepAt_19(+netted: Bool,+input: Nat) -> {C.step(M.at_19(netted,input)) == M.at_20(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_19(+input: Nat) -> {C.step(M.state_19(input)) == M.state_20(input) : C.Machine}:
  stepAt_19(Nat.is_eq(input,0n),input)

def stepAt_20(+netted: Bool,+input: Nat) -> {C.step(M.at_20(netted,input)) == M.at_21(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_20(+input: Nat) -> {C.step(M.state_20(input)) == M.state_21(input) : C.Machine}:
  stepAt_20(Nat.is_eq(input,0n),input)

def stepAt_21(+netted: Bool,+input: Nat) -> {C.step(M.at_21(netted,input)) == M.at_22(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_21(+input: Nat) -> {C.step(M.state_21(input)) == M.state_22(input) : C.Machine}:
  stepAt_21(Nat.is_eq(input,0n),input)

def stepAt_22(+netted: Bool,+input: Nat) -> {C.step(M.at_22(netted,input)) == M.at_23(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_22(+input: Nat) -> {C.step(M.state_22(input)) == M.state_23(input) : C.Machine}:
  stepAt_22(Nat.is_eq(input,0n),input)

def stepAt_23(+netted: Bool,+input: Nat) -> {C.step(M.at_23(netted,input)) == M.at_24(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_23(+input: Nat) -> {C.step(M.state_23(input)) == M.state_24(input) : C.Machine}:
  stepAt_23(Nat.is_eq(input,0n),input)

def stepAt_24(+netted: Bool,+input: Nat) -> {C.step(M.at_24(netted,input)) == M.at_25(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_24(+input: Nat) -> {C.step(M.state_24(input)) == M.state_25(input) : C.Machine}:
  stepAt_24(Nat.is_eq(input,0n),input)

def stepAt_25(+netted: Bool,+input: Nat) -> {C.step(M.at_25(netted,input)) == M.at_26(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_25(+input: Nat) -> {C.step(M.state_25(input)) == M.state_26(input) : C.Machine}:
  stepAt_25(Nat.is_eq(input,0n),input)

def stepAt_26(+netted: Bool,+input: Nat) -> {C.step(M.at_26(netted,input)) == M.at_27(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_26(+input: Nat) -> {C.step(M.state_26(input)) == M.state_27(input) : C.Machine}:
  stepAt_26(Nat.is_eq(input,0n),input)

def stepAt_27(+netted: Bool,+input: Nat) -> {C.step(M.at_27(netted,input)) == M.at_28(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_27(+input: Nat) -> {C.step(M.state_27(input)) == M.state_28(input) : C.Machine}:
  stepAt_27(Nat.is_eq(input,0n),input)

def stepAt_28(+netted: Bool,+input: Nat) -> {C.step(M.at_28(netted,input)) == M.at_29(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_28(+input: Nat) -> {C.step(M.state_28(input)) == M.state_29(input) : C.Machine}:
  stepAt_28(Nat.is_eq(input,0n),input)

def stepAt_29(+netted: Bool,+input: Nat) -> {C.step(M.at_29(netted,input)) == M.at_30(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_29(+input: Nat) -> {C.step(M.state_29(input)) == M.state_30(input) : C.Machine}:
  stepAt_29(Nat.is_eq(input,0n),input)

def stepAt_30(+netted: Bool,+input: Nat) -> {C.step(M.at_30(netted,input)) == M.at_31(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_30(+input: Nat) -> {C.step(M.state_30(input)) == M.state_31(input) : C.Machine}:
  stepAt_30(Nat.is_eq(input,0n),input)

def stepAt_31(+netted: Bool,+input: Nat) -> {C.step(M.at_31(netted,input)) == M.at_32(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_31(+input: Nat) -> {C.step(M.state_31(input)) == M.state_32(input) : C.Machine}:
  stepAt_31(Nat.is_eq(input,0n),input)

def stepAt_32(+netted: Bool,+input: Nat) -> {C.step(M.at_32(netted,input)) == M.at_33(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_32(+input: Nat) -> {C.step(M.state_32(input)) == M.state_33(input) : C.Machine}:
  stepAt_32(Nat.is_eq(input,0n),input)

def publish_33(+input: Nat) -> {C.publishValue(C.world(M.state_33(input)), 4n, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, False{}, 1n, False{}, False{}) == B.Bundle{C.world(M.state_34(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_33(input)

def stepAt_33(+netted: Bool,+input: Nat) -> {C.step(M.at_33(netted,input)) == M.at_34(netted,input) : C.Machine}:
  match netted:
    case True{}:
      Complete.complete(M.at_33(True{},input), C.world(M.at_33(True{},input)), remainder(M.at_33(True{},input)), 4n, 1n, R.Number{2n}, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, C.world(M.at_34(True{},input)), M.at_34(True{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_33(True{},input), {==})
    case False{}:
      Complete.complete(M.at_33(False{},input), C.world(M.at_33(False{},input)), remainder(M.at_33(False{},input)), 4n, 1n, R.Number{2n}, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, C.world(M.at_34(False{},input)), M.at_34(False{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_33(False{},input), {==})

def step_33(+input: Nat) -> {C.step(M.state_33(input)) == M.state_34(input) : C.Machine}:
  stepAt_33(Nat.is_eq(input,0n),input)

def stepAt_34(+netted: Bool,+input: Nat) -> {C.step(M.at_34(netted,input)) == M.at_35(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_34(+input: Nat) -> {C.step(M.state_34(input)) == M.state_35(input) : C.Machine}:
  stepAt_34(Nat.is_eq(input,0n),input)

def stepAt_35(+netted: Bool,+input: Nat) -> {C.step(M.at_35(netted,input)) == M.at_36(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_35(+input: Nat) -> {C.step(M.state_35(input)) == M.state_36(input) : C.Machine}:
  stepAt_35(Nat.is_eq(input,0n),input)

def stepAt_36(+netted: Bool,+input: Nat) -> {C.step(M.at_36(netted,input)) == M.at_37(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_36(+input: Nat) -> {C.step(M.state_36(input)) == M.state_37(input) : C.Machine}:
  stepAt_36(Nat.is_eq(input,0n),input)

def stepAt_37(+netted: Bool,+input: Nat) -> {C.step(M.at_37(netted,input)) == M.at_38(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_37(+input: Nat) -> {C.step(M.state_37(input)) == M.state_38(input) : C.Machine}:
  stepAt_37(Nat.is_eq(input,0n),input)

def stepAt_38(+netted: Bool,+input: Nat) -> {C.step(M.at_38(netted,input)) == M.at_39(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_38(+input: Nat) -> {C.step(M.state_38(input)) == M.state_39(input) : C.Machine}:
  stepAt_38(Nat.is_eq(input,0n),input)

def stepAt_39(+netted: Bool,+input: Nat) -> {C.step(M.at_39(netted,input)) == M.at_40(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_39(+input: Nat) -> {C.step(M.state_39(input)) == M.state_40(input) : C.Machine}:
  stepAt_39(Nat.is_eq(input,0n),input)

def stepAt_40(+netted: Bool,+input: Nat) -> {C.step(M.at_40(netted,input)) == M.at_41(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_40(+input: Nat) -> {C.step(M.state_40(input)) == M.state_41(input) : C.Machine}:
  stepAt_40(Nat.is_eq(input,0n),input)

def stepAt_41(+netted: Bool,+input: Nat) -> {C.step(M.at_41(netted,input)) == M.at_42(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_41(+input: Nat) -> {C.step(M.state_41(input)) == M.state_42(input) : C.Machine}:
  stepAt_41(Nat.is_eq(input,0n),input)

def stepAt_42(+netted: Bool,+input: Nat) -> {C.step(M.at_42(netted,input)) == M.at_43(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_42(+input: Nat) -> {C.step(M.state_42(input)) == M.state_43(input) : C.Machine}:
  stepAt_42(Nat.is_eq(input,0n),input)

def stepAt_43(+netted: Bool,+input: Nat) -> {C.step(M.at_43(netted,input)) == M.at_44(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_43(+input: Nat) -> {C.step(M.state_43(input)) == M.state_44(input) : C.Machine}:
  stepAt_43(Nat.is_eq(input,0n),input)

def stepAt_44(+netted: Bool,+input: Nat) -> {C.step(M.at_44(netted,input)) == M.at_45(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_44(+input: Nat) -> {C.step(M.state_44(input)) == M.state_45(input) : C.Machine}:
  stepAt_44(Nat.is_eq(input,0n),input)

def stepAt_45(+netted: Bool,+input: Nat) -> {C.step(M.at_45(netted,input)) == M.at_46(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_45(+input: Nat) -> {C.step(M.state_45(input)) == M.state_46(input) : C.Machine}:
  stepAt_45(Nat.is_eq(input,0n),input)

def stepAt_46(+netted: Bool,+input: Nat) -> {C.step(M.at_46(netted,input)) == M.at_47(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_46(+input: Nat) -> {C.step(M.state_46(input)) == M.state_47(input) : C.Machine}:
  stepAt_46(Nat.is_eq(input,0n),input)

def stepAt_47(+netted: Bool,+input: Nat) -> {C.step(M.at_47(netted,input)) == M.at_48(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_47(+input: Nat) -> {C.step(M.state_47(input)) == M.state_48(input) : C.Machine}:
  stepAt_47(Nat.is_eq(input,0n),input)

def stepAt_48(+netted: Bool,+input: Nat) -> {C.step(M.at_48(netted,input)) == M.at_49(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_48(+input: Nat) -> {C.step(M.state_48(input)) == M.state_49(input) : C.Machine}:
  stepAt_48(Nat.is_eq(input,0n),input)

def stepAt_49(+netted: Bool,+input: Nat) -> {C.step(M.at_49(netted,input)) == M.at_50(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_49(+input: Nat) -> {C.step(M.state_49(input)) == M.state_50(input) : C.Machine}:
  stepAt_49(Nat.is_eq(input,0n),input)

def stepAt_50(+netted: Bool,+input: Nat) -> {C.step(M.at_50(netted,input)) == M.at_51(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_50(+input: Nat) -> {C.step(M.state_50(input)) == M.state_51(input) : C.Machine}:
  stepAt_50(Nat.is_eq(input,0n),input)

def stepAt_51(+netted: Bool,+input: Nat) -> {C.step(M.at_51(netted,input)) == M.at_52(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_51(+input: Nat) -> {C.step(M.state_51(input)) == M.state_52(input) : C.Machine}:
  stepAt_51(Nat.is_eq(input,0n),input)

def readAt_52(+netted: Bool,+input: Nat) -> C.Machine:
  ReadCut.read(C.world(M.at_52(netted,input)),remainder(M.at_52(netted,input)),C.values(M.at_52(netted,input)),2n,netted)

def readExpected_52(+netted: Bool,+input: Nat,value: R.Value) -> C.Machine:
  +w = R.World.with_events(C.world(M.at_53(netted,input)),R.World.events(C.world(M.at_52(netted,input))))
  C.served(w,remainder(M.at_52(netted,input)),C.values(M.at_52(netted,input)),5n,2n,value)

def readCase_52(+netted: Bool,+input: Nat) -> {readAt_52(netted,input) == readExpected_52(netted,input,B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})) : C.Machine}:
  match netted:
    case True{}: {==}
    case False{}: {==}

def step_52(+input: Nat) -> {C.step(M.state_52(input)) == M.state_53(input) : C.Machine}:
  +netted = Nat.is_eq(input,0n)
  +answer = B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})
  Equal.trans(C.Machine,C.step(M.state_52(input)),readExpected_52(netted,input,answer),M.state_53(input),Equal.trans(C.Machine,C.step(M.state_52(input)),readAt_52(netted,input),readExpected_52(netted,input,answer),{==},readCase_52(netted,input)),Equal.cong(R.Value,C.Machine,value=>readExpected_52(netted,input,value),answer,R.Number{input},Natural.pick(0n,input)))

def stepAt_53(+netted: Bool,+input: Nat) -> {C.step(M.at_53(netted,input)) == M.at_54(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_53(+input: Nat) -> {C.step(M.state_53(input)) == M.state_54(input) : C.Machine}:
  stepAt_53(Nat.is_eq(input,0n),input)

def stepAt_54(+netted: Bool,+input: Nat) -> {C.step(M.at_54(netted,input)) == M.at_55(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_54(+input: Nat) -> {C.step(M.state_54(input)) == M.state_55(input) : C.Machine}:
  stepAt_54(Nat.is_eq(input,0n),input)

def publish_55(+input: Nat) -> {C.publishValue(C.world(M.state_55(input)), 5n, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, False{}, 2n, False{}, False{}) == B.Bundle{C.world(M.state_56(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_55(input)

def stepAt_55(+netted: Bool,+input: Nat) -> {C.step(M.at_55(netted,input)) == M.at_56(netted,input) : C.Machine}:
  match netted:
    case True{}:
      Complete.complete(M.at_55(True{},input), C.world(M.at_55(True{},input)), remainder(M.at_55(True{},input)), 5n, 2n, R.Number{2n}, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, C.world(M.at_56(True{},input)), M.at_56(True{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_55(True{},input), {==})
    case False{}:
      Complete.complete(M.at_55(False{},input), C.world(M.at_55(False{},input)), remainder(M.at_55(False{},input)), 5n, 2n, R.Number{2n}, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, C.world(M.at_56(False{},input)), M.at_56(False{},input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.at_complete_55(False{},input), {==})

def step_55(+input: Nat) -> {C.step(M.state_55(input)) == M.state_56(input) : C.Machine}:
  stepAt_55(Nat.is_eq(input,0n),input)

def stepAt_56(+netted: Bool,+input: Nat) -> {C.step(M.at_56(netted,input)) == M.at_57(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_56(+input: Nat) -> {C.step(M.state_56(input)) == M.state_57(input) : C.Machine}:
  stepAt_56(Nat.is_eq(input,0n),input)

def stepAt_57(+netted: Bool,+input: Nat) -> {C.step(M.at_57(netted,input)) == M.at_58(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_57(+input: Nat) -> {C.step(M.state_57(input)) == M.state_58(input) : C.Machine}:
  stepAt_57(Nat.is_eq(input,0n),input)

def stepAt_58(+netted: Bool,+input: Nat) -> {C.step(M.at_58(netted,input)) == M.at_59(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_58(+input: Nat) -> {C.step(M.state_58(input)) == M.state_59(input) : C.Machine}:
  stepAt_58(Nat.is_eq(input,0n),input)

def stepAt_59(+netted: Bool,+input: Nat) -> {C.step(M.at_59(netted,input)) == M.at_60(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_59(+input: Nat) -> {C.step(M.state_59(input)) == M.state_60(input) : C.Machine}:
  stepAt_59(Nat.is_eq(input,0n),input)

def stepAt_60(+netted: Bool,+input: Nat) -> {C.step(M.at_60(netted,input)) == M.at_61(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_60(+input: Nat) -> {C.step(M.state_60(input)) == M.state_61(input) : C.Machine}:
  stepAt_60(Nat.is_eq(input,0n),input)

def stepAt_61(+netted: Bool,+input: Nat) -> {C.step(M.at_61(netted,input)) == M.at_62(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_61(+input: Nat) -> {C.step(M.state_61(input)) == M.state_62(input) : C.Machine}:
  stepAt_61(Nat.is_eq(input,0n),input)

def stepAt_62(+netted: Bool,+input: Nat) -> {C.step(M.at_62(netted,input)) == M.at_63(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_62(+input: Nat) -> {C.step(M.state_62(input)) == M.state_63(input) : C.Machine}:
  stepAt_62(Nat.is_eq(input,0n),input)

def stepAt_63(+netted: Bool,+input: Nat) -> {C.step(M.at_63(netted,input)) == M.at_64(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_63(+input: Nat) -> {C.step(M.state_63(input)) == M.state_64(input) : C.Machine}:
  stepAt_63(Nat.is_eq(input,0n),input)

def stepAt_64(+netted: Bool,+input: Nat) -> {C.step(M.at_64(netted,input)) == M.at_65(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_64(+input: Nat) -> {C.step(M.state_64(input)) == M.state_65(input) : C.Machine}:
  stepAt_64(Nat.is_eq(input,0n),input)

def stepAt_65(+netted: Bool,+input: Nat) -> {C.step(M.at_65(netted,input)) == M.at_66(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_65(+input: Nat) -> {C.step(M.state_65(input)) == M.state_66(input) : C.Machine}:
  stepAt_65(Nat.is_eq(input,0n),input)

def stepAt_66(+netted: Bool,+input: Nat) -> {C.step(M.at_66(netted,input)) == M.at_67(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_66(+input: Nat) -> {C.step(M.state_66(input)) == M.state_67(input) : C.Machine}:
  stepAt_66(Nat.is_eq(input,0n),input)

def stepAt_67(+netted: Bool,+input: Nat) -> {C.step(M.at_67(netted,input)) == M.at_68(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_67(+input: Nat) -> {C.step(M.state_67(input)) == M.state_68(input) : C.Machine}:
  stepAt_67(Nat.is_eq(input,0n),input)

def stepAt_68(+netted: Bool,+input: Nat) -> {C.step(M.at_68(netted,input)) == M.at_69(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_68(+input: Nat) -> {C.step(M.state_68(input)) == M.state_69(input) : C.Machine}:
  stepAt_68(Nat.is_eq(input,0n),input)

def stepAt_69(+netted: Bool,+input: Nat) -> {C.step(M.at_69(netted,input)) == M.at_70(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_69(+input: Nat) -> {C.step(M.state_69(input)) == M.state_70(input) : C.Machine}:
  stepAt_69(Nat.is_eq(input,0n),input)

def stepAt_70(+netted: Bool,+input: Nat) -> {C.step(M.at_70(netted,input)) == M.at_71(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_70(+input: Nat) -> {C.step(M.state_70(input)) == M.state_71(input) : C.Machine}:
  stepAt_70(Nat.is_eq(input,0n),input)

def stepAt_71(+netted: Bool,+input: Nat) -> {C.step(M.at_71(netted,input)) == M.at_72(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_71(+input: Nat) -> {C.step(M.state_71(input)) == M.state_72(input) : C.Machine}:
  stepAt_71(Nat.is_eq(input,0n),input)

def stepAt_72(+netted: Bool,+input: Nat) -> {C.step(M.at_72(netted,input)) == M.at_73(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_72(+input: Nat) -> {C.step(M.state_72(input)) == M.state_73(input) : C.Machine}:
  stepAt_72(Nat.is_eq(input,0n),input)

def stepAt_73(+netted: Bool,+input: Nat) -> {C.step(M.at_73(netted,input)) == M.at_74(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_73(+input: Nat) -> {C.step(M.state_73(input)) == M.state_74(input) : C.Machine}:
  stepAt_73(Nat.is_eq(input,0n),input)

def stepAt_74(+netted: Bool,+input: Nat) -> {C.step(M.at_74(netted,input)) == M.at_75(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_74(+input: Nat) -> {C.step(M.state_74(input)) == M.state_75(input) : C.Machine}:
  stepAt_74(Nat.is_eq(input,0n),input)

def stepAt_75(+netted: Bool,+input: Nat) -> {C.step(M.at_75(netted,input)) == M.at_76(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_75(+input: Nat) -> {C.step(M.state_75(input)) == M.state_76(input) : C.Machine}:
  stepAt_75(Nat.is_eq(input,0n),input)

def stepAt_76(+netted: Bool,+input: Nat) -> {C.step(M.at_76(netted,input)) == M.at_77(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_76(+input: Nat) -> {C.step(M.state_76(input)) == M.state_77(input) : C.Machine}:
  stepAt_76(Nat.is_eq(input,0n),input)

def stepAt_77(+netted: Bool,+input: Nat) -> {C.step(M.at_77(netted,input)) == M.at_78(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_77(+input: Nat) -> {C.step(M.state_77(input)) == M.state_78(input) : C.Machine}:
  stepAt_77(Nat.is_eq(input,0n),input)

def stepAt_78(+netted: Bool,+input: Nat) -> {C.step(M.at_78(netted,input)) == M.at_79(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_78(+input: Nat) -> {C.step(M.state_78(input)) == M.state_79(input) : C.Machine}:
  stepAt_78(Nat.is_eq(input,0n),input)

def stepAt_79(+netted: Bool,+input: Nat) -> {C.step(M.at_79(netted,input)) == M.at_80(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_79(+input: Nat) -> {C.step(M.state_79(input)) == M.state_80(input) : C.Machine}:
  stepAt_79(Nat.is_eq(input,0n),input)

def stepAt_80(+netted: Bool,+input: Nat) -> {C.step(M.at_80(netted,input)) == M.at_81(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_80(+input: Nat) -> {C.step(M.state_80(input)) == M.state_81(input) : C.Machine}:
  stepAt_80(Nat.is_eq(input,0n),input)

def stepAt_81(+netted: Bool,+input: Nat) -> {C.step(M.at_81(netted,input)) == M.at_82(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_81(+input: Nat) -> {C.step(M.state_81(input)) == M.state_82(input) : C.Machine}:
  stepAt_81(Nat.is_eq(input,0n),input)

def stepAt_82(+netted: Bool,+input: Nat) -> {C.step(M.at_82(netted,input)) == M.at_83(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_82(+input: Nat) -> {C.step(M.state_82(input)) == M.state_83(input) : C.Machine}:
  stepAt_82(Nat.is_eq(input,0n),input)

def stepAt_83(+netted: Bool,+input: Nat) -> {C.step(M.at_83(netted,input)) == M.at_84(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_83(+input: Nat) -> {C.step(M.state_83(input)) == M.state_84(input) : C.Machine}:
  stepAt_83(Nat.is_eq(input,0n),input)

def stepAt_84(+netted: Bool,+input: Nat) -> {C.step(M.at_84(netted,input)) == M.at_85(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_84(+input: Nat) -> {C.step(M.state_84(input)) == M.state_85(input) : C.Machine}:
  stepAt_84(Nat.is_eq(input,0n),input)

def stepAt_85(+netted: Bool,+input: Nat) -> {C.step(M.at_85(netted,input)) == M.at_86(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_85(+input: Nat) -> {C.step(M.state_85(input)) == M.state_86(input) : C.Machine}:
  stepAt_85(Nat.is_eq(input,0n),input)

def stepAt_86(+netted: Bool,+input: Nat) -> {C.step(M.at_86(netted,input)) == M.at_87(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_86(+input: Nat) -> {C.step(M.state_86(input)) == M.state_87(input) : C.Machine}:
  stepAt_86(Nat.is_eq(input,0n),input)

def stepAt_87(+netted: Bool,+input: Nat) -> {C.step(M.at_87(netted,input)) == M.at_88(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_87(+input: Nat) -> {C.step(M.state_87(input)) == M.state_88(input) : C.Machine}:
  stepAt_87(Nat.is_eq(input,0n),input)

def stepAt_88(+netted: Bool,+input: Nat) -> {C.step(M.at_88(netted,input)) == M.at_89(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_88(+input: Nat) -> {C.step(M.state_88(input)) == M.state_89(input) : C.Machine}:
  stepAt_88(Nat.is_eq(input,0n),input)

def stepAt_89(+netted: Bool,+input: Nat) -> {C.step(M.at_89(netted,input)) == M.at_90(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_89(+input: Nat) -> {C.step(M.state_89(input)) == M.state_90(input) : C.Machine}:
  stepAt_89(Nat.is_eq(input,0n),input)

def stepAt_90(+netted: Bool,+input: Nat) -> {C.step(M.at_90(netted,input)) == M.at_91(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_90(+input: Nat) -> {C.step(M.state_90(input)) == M.state_91(input) : C.Machine}:
  stepAt_90(Nat.is_eq(input,0n),input)

def stepAt_91(+netted: Bool,+input: Nat) -> {C.step(M.at_91(netted,input)) == M.at_92(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_91(+input: Nat) -> {C.step(M.state_91(input)) == M.state_92(input) : C.Machine}:
  stepAt_91(Nat.is_eq(input,0n),input)

def stepAt_92(+netted: Bool,+input: Nat) -> {C.step(M.at_92(netted,input)) == M.at_93(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_92(+input: Nat) -> {C.step(M.state_92(input)) == M.state_93(input) : C.Machine}:
  stepAt_92(Nat.is_eq(input,0n),input)

def stepAt_93(+netted: Bool,+input: Nat) -> {C.step(M.at_93(netted,input)) == M.at_94(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_93(+input: Nat) -> {C.step(M.state_93(input)) == M.state_94(input) : C.Machine}:
  stepAt_93(Nat.is_eq(input,0n),input)

def stepAt_94(+netted: Bool,+input: Nat) -> {C.step(M.at_94(netted,input)) == M.at_95(netted,input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_94(+input: Nat) -> {C.step(M.state_94(input)) == M.state_95(input) : C.Machine}:
  stepAt_94(Nat.is_eq(input,0n),input)
