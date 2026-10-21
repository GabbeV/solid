# Checked: actual chain transitions and proof-only publication transports.
import Base
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

def step_0(+input: Nat) -> {C.step(M.state_0(input)) == M.state_1(input) : C.Machine}:
  {==}

def step_1(+input: Nat) -> {C.step(M.state_1(input)) == M.state_2(input) : C.Machine}:
  {==}

def step_2(+input: Nat) -> {C.step(M.state_2(input)) == M.state_3(input) : C.Machine}:
  {==}

def step_3(+input: Nat) -> {C.step(M.state_3(input)) == M.state_4(input) : C.Machine}:
  {==}

def step_4(+input: Nat) -> {C.step(M.state_4(input)) == M.state_5(input) : C.Machine}:
  {==}

def step_5(+input: Nat) -> {C.step(M.state_5(input)) == M.state_6(input) : C.Machine}:
  {==}

def step_6(+input: Nat) -> {C.step(M.state_6(input)) == M.state_7(input) : C.Machine}:
  {==}

def step_7(+input: Nat) -> {C.step(M.state_7(input)) == M.state_8(input) : C.Machine}:
  {==}

def step_8(+input: Nat) -> {C.step(M.state_8(input)) == M.state_9(input) : C.Machine}:
  {==}

def step_9(+input: Nat) -> {C.step(M.state_9(input)) == M.state_10(input) : C.Machine}:
  {==}

def step_10(+input: Nat) -> {C.step(M.state_10(input)) == M.state_11(input) : C.Machine}:
  {==}

def step_11(+input: Nat) -> {C.step(M.state_11(input)) == M.state_12(input) : C.Machine}:
  {==}

def step_12(+input: Nat) -> {C.step(M.state_12(input)) == M.state_13(input) : C.Machine}:
  {==}

def publish_13(+input: Nat) -> {C.publishValue(C.world(M.state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{}) == B.Bundle{C.world(M.state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_13(input)

def step_13(+input: Nat) -> {C.step(M.state_13(input)) == M.state_14(input) : C.Machine}:
  Complete.complete(M.state_13(input), C.world(M.state_13(input)), remainder(M.state_13(input)), 3n, 0n, R.Number{1n}, R.Number{Nat.add(input, 1n)}, C.world(M.state_14(input)), M.state_14(input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.complete_13(input), {==})

def step_14(+input: Nat) -> {C.step(M.state_14(input)) == M.state_15(input) : C.Machine}:
  {==}

def step_15(+input: Nat) -> {C.step(M.state_15(input)) == M.state_16(input) : C.Machine}:
  {==}

def step_16(+input: Nat) -> {C.step(M.state_16(input)) == M.state_17(input) : C.Machine}:
  {==}

def step_17(+input: Nat) -> {C.step(M.state_17(input)) == M.state_18(input) : C.Machine}:
  {==}

def step_18(+input: Nat) -> {C.step(M.state_18(input)) == M.state_19(input) : C.Machine}:
  {==}

def step_19(+input: Nat) -> {C.step(M.state_19(input)) == M.state_20(input) : C.Machine}:
  {==}

def step_20(+input: Nat) -> {C.step(M.state_20(input)) == M.state_21(input) : C.Machine}:
  {==}

def step_21(+input: Nat) -> {C.step(M.state_21(input)) == M.state_22(input) : C.Machine}:
  {==}

def step_22(+input: Nat) -> {C.step(M.state_22(input)) == M.state_23(input) : C.Machine}:
  {==}

def step_23(+input: Nat) -> {C.step(M.state_23(input)) == M.state_24(input) : C.Machine}:
  {==}

def step_24(+input: Nat) -> {C.step(M.state_24(input)) == M.state_25(input) : C.Machine}:
  {==}

def step_25(+input: Nat) -> {C.step(M.state_25(input)) == M.state_26(input) : C.Machine}:
  {==}

def step_26(+input: Nat) -> {C.step(M.state_26(input)) == M.state_27(input) : C.Machine}:
  {==}

def step_27(+input: Nat) -> {C.step(M.state_27(input)) == M.state_28(input) : C.Machine}:
  {==}

def step_28(+input: Nat) -> {C.step(M.state_28(input)) == M.state_29(input) : C.Machine}:
  {==}

def step_29(+input: Nat) -> {C.step(M.state_29(input)) == M.state_30(input) : C.Machine}:
  {==}

def step_30(+input: Nat) -> {C.step(M.state_30(input)) == M.state_31(input) : C.Machine}:
  {==}

def step_31(+input: Nat) -> {C.step(M.state_31(input)) == M.state_32(input) : C.Machine}:
  {==}

def step_32(+input: Nat) -> {C.step(M.state_32(input)) == M.state_33(input) : C.Machine}:
  {==}

def publish_33(+input: Nat) -> {C.publishValue(C.world(M.state_33(input)), 4n, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, False{}, 1n, False{}, False{}) == B.Bundle{C.world(M.state_34(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_33(input)

def step_33(+input: Nat) -> {C.step(M.state_33(input)) == M.state_34(input) : C.Machine}:
  Complete.complete(M.state_33(input), C.world(M.state_33(input)), remainder(M.state_33(input)), 4n, 1n, R.Number{2n}, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, C.world(M.state_34(input)), M.state_34(input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.complete_33(input), {==})

def step_34(+input: Nat) -> {C.step(M.state_34(input)) == M.state_35(input) : C.Machine}:
  {==}

def step_35(+input: Nat) -> {C.step(M.state_35(input)) == M.state_36(input) : C.Machine}:
  {==}

def step_36(+input: Nat) -> {C.step(M.state_36(input)) == M.state_37(input) : C.Machine}:
  {==}

def step_37(+input: Nat) -> {C.step(M.state_37(input)) == M.state_38(input) : C.Machine}:
  {==}

def step_38(+input: Nat) -> {C.step(M.state_38(input)) == M.state_39(input) : C.Machine}:
  {==}

def step_39(+input: Nat) -> {C.step(M.state_39(input)) == M.state_40(input) : C.Machine}:
  {==}

def step_40(+input: Nat) -> {C.step(M.state_40(input)) == M.state_41(input) : C.Machine}:
  {==}

def step_41(+input: Nat) -> {C.step(M.state_41(input)) == M.state_42(input) : C.Machine}:
  {==}

def step_42(+input: Nat) -> {C.step(M.state_42(input)) == M.state_43(input) : C.Machine}:
  {==}

def step_43(+input: Nat) -> {C.step(M.state_43(input)) == M.state_44(input) : C.Machine}:
  {==}

def step_44(+input: Nat) -> {C.step(M.state_44(input)) == M.state_45(input) : C.Machine}:
  {==}

def step_45(+input: Nat) -> {C.step(M.state_45(input)) == M.state_46(input) : C.Machine}:
  {==}

def step_46(+input: Nat) -> {C.step(M.state_46(input)) == M.state_47(input) : C.Machine}:
  {==}

def step_47(+input: Nat) -> {C.step(M.state_47(input)) == M.state_48(input) : C.Machine}:
  {==}

def step_48(+input: Nat) -> {C.step(M.state_48(input)) == M.state_49(input) : C.Machine}:
  {==}

def step_49(+input: Nat) -> {C.step(M.state_49(input)) == M.state_50(input) : C.Machine}:
  {==}

def step_50(+input: Nat) -> {C.step(M.state_50(input)) == M.state_51(input) : C.Machine}:
  {==}

def step_51(+input: Nat) -> {C.step(M.state_51(input)) == M.state_52(input) : C.Machine}:
  {==}

def step_52(+input: Nat) -> {C.step(M.state_52(input)) == M.state_53(input) : C.Machine}:
  {==}

def step_53(+input: Nat) -> {C.step(M.state_53(input)) == M.state_54(input) : C.Machine}:
  {==}

def step_54(+input: Nat) -> {C.step(M.state_54(input)) == M.state_55(input) : C.Machine}:
  {==}

def publish_55(+input: Nat) -> {C.publishValue(C.world(M.state_55(input)), 5n, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, False{}, 2n, False{}, False{}) == B.Bundle{C.world(M.state_56(input)), True{}} : B.Bundle<R.World, Bool>}:
  Publish.complete_55(input)

def step_55(+input: Nat) -> {C.step(M.state_55(input)) == M.state_56(input) : C.Machine}:
  Complete.complete(M.state_55(input), C.world(M.state_55(input)), remainder(M.state_55(input)), 5n, 2n, R.Number{2n}, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, C.world(M.state_56(input)), M.state_56(input), {==}, {==}, {==}, {==}, {==}, {==}, {==}, Publish.complete_55(input), {==})

def step_56(+input: Nat) -> {C.step(M.state_56(input)) == M.state_57(input) : C.Machine}:
  {==}

def step_57(+input: Nat) -> {C.step(M.state_57(input)) == M.state_58(input) : C.Machine}:
  {==}

def step_58(+input: Nat) -> {C.step(M.state_58(input)) == M.state_59(input) : C.Machine}:
  {==}

def step_59(+input: Nat) -> {C.step(M.state_59(input)) == M.state_60(input) : C.Machine}:
  {==}

def step_60(+input: Nat) -> {C.step(M.state_60(input)) == M.state_61(input) : C.Machine}:
  {==}

def step_61(+input: Nat) -> {C.step(M.state_61(input)) == M.state_62(input) : C.Machine}:
  {==}

def step_62(+input: Nat) -> {C.step(M.state_62(input)) == M.state_63(input) : C.Machine}:
  {==}

def step_63(+input: Nat) -> {C.step(M.state_63(input)) == M.state_64(input) : C.Machine}:
  {==}

def step_64(+input: Nat) -> {C.step(M.state_64(input)) == M.state_65(input) : C.Machine}:
  {==}

def step_65(+input: Nat) -> {C.step(M.state_65(input)) == M.state_66(input) : C.Machine}:
  {==}

def step_66(+input: Nat) -> {C.step(M.state_66(input)) == M.state_67(input) : C.Machine}:
  {==}

def step_67(+input: Nat) -> {C.step(M.state_67(input)) == M.state_68(input) : C.Machine}:
  {==}

def step_68(+input: Nat) -> {C.step(M.state_68(input)) == M.state_69(input) : C.Machine}:
  {==}

def step_69(+input: Nat) -> {C.step(M.state_69(input)) == M.state_70(input) : C.Machine}:
  {==}

def step_70(+input: Nat) -> {C.step(M.state_70(input)) == M.state_71(input) : C.Machine}:
  {==}

def step_71(+input: Nat) -> {C.step(M.state_71(input)) == M.state_72(input) : C.Machine}:
  {==}

def step_72(+input: Nat) -> {C.step(M.state_72(input)) == M.state_73(input) : C.Machine}:
  {==}

def step_73(+input: Nat) -> {C.step(M.state_73(input)) == M.state_74(input) : C.Machine}:
  {==}

def step_74(+input: Nat) -> {C.step(M.state_74(input)) == M.state_75(input) : C.Machine}:
  {==}

def step_75(+input: Nat) -> {C.step(M.state_75(input)) == M.state_76(input) : C.Machine}:
  {==}

def step_76(+input: Nat) -> {C.step(M.state_76(input)) == M.state_77(input) : C.Machine}:
  {==}

def step_77(+input: Nat) -> {C.step(M.state_77(input)) == M.state_78(input) : C.Machine}:
  {==}

def step_78(+input: Nat) -> {C.step(M.state_78(input)) == M.state_79(input) : C.Machine}:
  {==}

def step_79(+input: Nat) -> {C.step(M.state_79(input)) == M.state_80(input) : C.Machine}:
  {==}

def step_80(+input: Nat) -> {C.step(M.state_80(input)) == M.state_81(input) : C.Machine}:
  {==}

def step_81(+input: Nat) -> {C.step(M.state_81(input)) == M.state_82(input) : C.Machine}:
  {==}

def step_82(+input: Nat) -> {C.step(M.state_82(input)) == M.state_83(input) : C.Machine}:
  {==}

def step_83(+input: Nat) -> {C.step(M.state_83(input)) == M.state_84(input) : C.Machine}:
  {==}

def step_84(+input: Nat) -> {C.step(M.state_84(input)) == M.state_85(input) : C.Machine}:
  {==}

def step_85(+input: Nat) -> {C.step(M.state_85(input)) == M.state_86(input) : C.Machine}:
  {==}

def step_86(+input: Nat) -> {C.step(M.state_86(input)) == M.state_87(input) : C.Machine}:
  {==}

def step_87(+input: Nat) -> {C.step(M.state_87(input)) == M.state_88(input) : C.Machine}:
  {==}

def step_88(+input: Nat) -> {C.step(M.state_88(input)) == M.state_89(input) : C.Machine}:
  {==}

def step_89(+input: Nat) -> {C.step(M.state_89(input)) == M.state_90(input) : C.Machine}:
  {==}

def step_90(+input: Nat) -> {C.step(M.state_90(input)) == M.state_91(input) : C.Machine}:
  {==}

def step_91(+input: Nat) -> {C.step(M.state_91(input)) == M.state_92(input) : C.Machine}:
  {==}

def step_92(+input: Nat) -> {C.step(M.state_92(input)) == M.state_93(input) : C.Machine}:
  {==}

def step_93(+input: Nat) -> {C.step(M.state_93(input)) == M.state_94(input) : C.Machine}:
  {==}

def step_94(+input: Nat) -> {C.step(M.state_94(input)) == M.state_95(input) : C.Machine}:
  {==}
