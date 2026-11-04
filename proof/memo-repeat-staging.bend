# Actual second-update transitions, quantified over first and second proposals.
# Algebraic helper cuts avoid kernel expansion; the public constructor/setter
# bridge is deliberately excluded from the conditional theorem below.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-driver.bend as Driver
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q

import ./memo-repeat-states.bend as M
import ./memo-cuts.bend as Cuts
import ./memo-general-cuts.bend as GeneralCuts

import ./memo-history-staging.bend as History
import ./memo-history-seed-data.bend as Seed

def step_0(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_0(initial, first, input)) == M.state_1(initial, first, input) : C.Machine}:
  History.step_0(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_1(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_1(initial, first, input)) == M.state_2(initial, first, input) : C.Machine}:
  History.step_1(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_2(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_2(initial, first, input)) == M.state_3(initial, first, input) : C.Machine}:
  History.step_2(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_3(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_3(initial, first, input)) == M.state_4(initial, first, input) : C.Machine}:
  History.step_3(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_4(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_4(initial, first, input)) == M.state_5(initial, first, input) : C.Machine}:
  History.step_4(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_5(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_5(initial, first, input)) == M.state_6(initial, first, input) : C.Machine}:
  History.step_5(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_6(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_6(initial, first, input)) == M.state_7(initial, first, input) : C.Machine}:
  History.step_6(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_7(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_7(initial, first, input)) == M.state_8(initial, first, input) : C.Machine}:
  History.step_7(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_8(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_8(initial, first, input)) == M.state_9(initial, first, input) : C.Machine}:
  History.step_8(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_9(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_9(initial, first, input)) == M.state_10(initial, first, input) : C.Machine}:
  History.step_9(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_10(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_10(initial, first, input)) == M.state_11(initial, first, input) : C.Machine}:
  History.step_10(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_11(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_11(initial, first, input)) == M.state_12(initial, first, input) : C.Machine}:
  History.step_11(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_12(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_12(initial, first, input)) == M.state_13(initial, first, input) : C.Machine}:
  History.step_12(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def step_13(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_13(initial, first, input)) == M.state_14(initial, first, input) : C.Machine}:
  History.step_13(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_14(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_14(initial, first, input)) == M.state_15(initial, first, input) : C.Machine}:
  History.step_14(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_15(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_15(initial, first, input)) == M.state_16(initial, first, input) : C.Machine}:
  History.step_15(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_16(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_16(initial, first, input)) == M.state_17(initial, first, input) : C.Machine}:
  History.step_16(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_17(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_17(initial, first, input)) == M.state_18(initial, first, input) : C.Machine}:
  History.step_17(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_18(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_18(initial, first, input)) == M.state_19(initial, first, input) : C.Machine}:
  History.step_18(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_19(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_19(initial, first, input)) == M.state_20(initial, first, input) : C.Machine}:
  History.step_19(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_20(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_20(initial, first, input)) == M.state_21(initial, first, input) : C.Machine}:
  History.step_20(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_21(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_21(initial, first, input)) == M.state_22(initial, first, input) : C.Machine}:
  History.step_21(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_22(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_22(initial, first, input)) == M.state_23(initial, first, input) : C.Machine}:
  History.step_22(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_23(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_23(initial, first, input)) == M.state_24(initial, first, input) : C.Machine}:
  History.step_23(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_24(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_24(initial, first, input)) == M.state_25(initial, first, input) : C.Machine}:
  History.step_24(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_25(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_25(initial, first, input)) == M.state_26(initial, first, input) : C.Machine}:
  History.step_25(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_26(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_26(initial, first, input)) == M.state_27(initial, first, input) : C.Machine}:
  History.step_26(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_27(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_27(initial, first, input)) == M.state_28(initial, first, input) : C.Machine}:
  History.step_27(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_28(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_28(initial, first, input)) == M.state_29(initial, first, input) : C.Machine}:
  History.step_28(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_29(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_29(initial, first, input)) == M.state_30(initial, first, input) : C.Machine}:
  History.step_29(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_30(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_30(initial, first, input)) == M.state_31(initial, first, input) : C.Machine}:
  History.step_30(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_31(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_31(initial, first, input)) == M.state_32(initial, first, input) : C.Machine}:
  History.step_31(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_32(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_32(initial, first, input)) == M.state_33(initial, first, input) : C.Machine}:
  History.step_32(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_33(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_33(initial, first, input)) == M.state_34(initial, first, input) : C.Machine}:
  History.step_33(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_34(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_34(initial, first, input)) == M.state_35(initial, first, input) : C.Machine}:
  History.step_34(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_35(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_35(initial, first, input)) == M.state_36(initial, first, input) : C.Machine}:
  History.step_35(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_36(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_36(initial, first, input)) == M.state_37(initial, first, input) : C.Machine}:
  History.step_36(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_37(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_37(initial, first, input)) == M.state_38(initial, first, input) : C.Machine}:
  History.step_37(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_38(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_38(initial, first, input)) == M.state_39(initial, first, input) : C.Machine}:
  History.step_38(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_39(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_39(initial, first, input)) == M.state_40(initial, first, input) : C.Machine}:
  History.step_39(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def witness(+initial: Nat, +first: Nat, +input: Nat) -> P.Path<M.state_0(initial, first, input), M.state_40(initial, first, input)>:
  History.witness(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def retimed(+start: C.Machine, -end: C.Machine, +path: P.Path<start, end>, +extra: Nat, +fuel: Nat,
  lengthEq: {Nat.add(P.length(start, end, path), extra) == fuel : Nat}) ->
  {C.run(fuel, start) == end : C.Machine}:
  Equal.trans(C.Machine, C.run(fuel, start), C.run(Nat.add(P.length(start, end, path), extra), start), end,
    P.fuel_transport(fuel, Nat.add(P.length(start, end, path), extra), start,
      Equal.sym(Nat, Nat.add(P.length(start, end, path), extra), fuel, lengthEq)),
    P.realizes(start, end, path, extra, start, {==}))

def flush_eq(+initial: Nat, +first: Nat, +input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, first, input))) == C.world(M.state_40(initial, first, input)) : R.World}:
  History.flush_eq(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs(),extra)

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+initial: Nat, +first: Nat, +input: Nat, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, first, input)))) == Driver.expected(input) : Driver.View}:
  History.every_staged_input(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs(),extra)
