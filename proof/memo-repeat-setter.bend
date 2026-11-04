import Base
import ../runtime/write.bend as W
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M
import ./memo-setter-cuts.bend as Cuts
import ./memo-repeat-setter-data.bend as D
import ./memo-repeat-setter-checks.bend as Checks
import ../runtime/api.bend as A
import ./paths.bend as P
import ./memo-staging.bend as Existing

import ./memo-history-setter.bend as History
import ./memo-history-seed-data.bend as Seed

def staging(+initial: Nat, +first: Nat, +input: Nat) ->
  {W.stageResolved(M.origin(initial, first), 2n, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  History.staging(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def resolved(+initial: Nat, +first: Nat, +input: Nat) ->
  {W.setResolved(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  History.resolved(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def start(+initial: Nat, +first: Nat, input: Nat) -> C.Machine:
  History.start(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def middle(+initial: Nat, +first: Nat, input: Nat) -> C.Machine:
  History.middle(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def end(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  History.end(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_0(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(start(initial, first, input)) == middle(initial, first, input) : C.Machine}:
  History.step_0(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def step_1(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(middle(initial, first, input)) == end(initial, first, input) : C.Machine}:
  History.step_1(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def path(+initial: Nat, +first: Nat, +input: Nat) -> P.Path<start(initial, first, input), end(initial, first, input)>:
  History.path(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def completes(+initial: Nat, +first: Nat, +input: Nat) -> {C.run(24n, start(initial, first, input)) == end(initial, first, input) : C.Machine}:
  History.completes(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())

def public_setter(+initial: Nat, +first: Nat, +input: Nat) -> {A.setSignal(M.origin(initial, first), 2n, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  History.public_setter(Nat.is_eq(first,initial),0n,first,input,Seed.events(initial,first),Seed.jobs())
