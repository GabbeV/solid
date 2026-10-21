# Two actual source subscriber iterations, with helper checkpoints kept opaque.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ./chain-states.bend as M
import ./chain-subscriber-step.bend as Step

def stamp(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.Stamped{R.World.epoch(w)}))

def intake(+w: R.World, +id: Nat, +stamped: R.World, +fuel: Nat, +edge: Nat,
  stampEq: {stamp(w, id) == stamped : R.World},
  fuelEq: {B.budget(stamped) == fuel : Nat},
  edgeEq: {R.Node.subs(B.node(stamped, id)) == edge : Nat}) ->
  {W.insertSubs(w, id) == W.insert_subs(fuel, stamped, edge) : R.World}:
  Equal.trans(R.World, W.insertSubs(w, id), W.insert_subs(B.budget(stamped), stamped, R.Node.subs(B.node(stamped, id))), W.insert_subs(fuel, stamped, edge),
    Equal.cong(R.World, R.World, world => W.insert_subs(B.budget(world), world, R.Node.subs(B.node(world, id))), stamp(w, id), stamped, stampEq),
    Equal.trans(R.World, W.insert_subs(B.budget(stamped), stamped, R.Node.subs(B.node(stamped, id))), W.insert_subs(fuel, stamped, R.Node.subs(B.node(stamped, id))), W.insert_subs(fuel, stamped, edge),
      Equal.cong(Nat, R.World, budget => W.insert_subs(budget, stamped, R.Node.subs(B.node(stamped, id))), B.budget(stamped), fuel, fuelEq),
      Equal.cong(Nat, R.World, pointer => W.insert_subs(fuel, stamped, pointer), R.Node.subs(B.node(stamped, id)), edge, edgeEq)))

def link1() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 1n}

def link4() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 1n}

def stamp_known(+input: Nat) -> {stamp(M.setter_slot(input), 2n) == M.setter_stamped(input) : R.World}:
  {==}

def first_heap(+input: Nat) -> {H.enqueueSub(M.setter_stamped(input), 3n) == M.setter_enqueued3(input) : R.World}:
  {==}

def second_heap(+input: Nat) -> {H.enqueueSub(M.setter_enqueued3(input), 5n) == M.setter_enqueued5(input) : R.World}:
  {==}

def final(+input: Nat) -> {M.setter_enqueued5(input) == M.setter_inserted(input) : R.World}:
  {==}

def at(+fuel: Nat, +a: R.World, +b: R.World, +edge: Nat, known: {a == b : R.World}) ->
  {W.insert_subs(fuel, a, edge) == W.insert_subs(fuel, b, edge) : R.World}:
  Equal.cong(R.World, R.World, world => W.insert_subs(fuel, world, edge), a, b, known)

def zero(+fuel: Nat, +w: R.World) -> {W.insert_subs(1n+fuel, w, 0n) == w : R.World}:
  {==}

# Actual first/second loop transitions, with successor Worlds kept opaque.
def first_edge(+input: Nat) -> {W.insert_subs(44n, M.setter_stamped(input), 1n) == W.insert_subs(43n, H.enqueueSub(M.setter_stamped(input), 3n), 4n) : R.World}:
  Step.first(43n, input)

def second_edge(+input: Nat) -> {W.insert_subs(43n, M.setter_enqueued3(input), 4n) == W.insert_subs(42n, H.enqueueSub(M.setter_enqueued3(input), 5n), 0n) : R.World}:
  Step.second(42n, input)

def both(+w: R.World, +first: R.World, +second: R.World,
  firstStep: {W.insert_subs(44n, w, 1n) == W.insert_subs(43n, H.enqueueSub(w, 3n), 4n) : R.World},
  firstHeap: {H.enqueueSub(w, 3n) == first : R.World},
  secondStep: {W.insert_subs(43n, first, 4n) == W.insert_subs(42n, H.enqueueSub(first, 5n), 0n) : R.World},
  secondHeap: {H.enqueueSub(first, 5n) == second : R.World}) ->
  {W.insert_subs(44n, w, 1n) == second : R.World}:
  Equal.trans(R.World, W.insert_subs(44n, w, 1n), W.insert_subs(43n, H.enqueueSub(w, 3n), 4n), second, firstStep,
    Equal.trans(R.World, W.insert_subs(43n, H.enqueueSub(w, 3n), 4n), W.insert_subs(43n, first, 4n), second,
      at(43n, H.enqueueSub(w, 3n), first, 4n, firstHeap),
      Equal.trans(R.World, W.insert_subs(43n, first, 4n), W.insert_subs(42n, H.enqueueSub(first, 5n), 0n), second, secondStep,
        Equal.trans(R.World, W.insert_subs(42n, H.enqueueSub(first, 5n), 0n), W.insert_subs(42n, second, 0n), second,
          at(42n, H.enqueueSub(first, 5n), second, 0n, secondHeap), zero(41n, second)))))

def ending(+w: R.World, +stamped: R.World, +first: R.World, +second: R.World, +end: R.World,
  initial: {W.insertSubs(w, 2n) == W.insert_subs(44n, stamped, 1n) : R.World},
  links: {W.insert_subs(44n, stamped, 1n) == second : R.World}, last: {second == end : R.World}) ->
  {W.insertSubs(w, 2n) == end : R.World}:
  Equal.trans(R.World, W.insertSubs(w, 2n), W.insert_subs(44n, stamped, 1n), end, initial,
    Equal.trans(R.World, W.insert_subs(44n, stamped, 1n), second, end, links, last))

def complete(+input: Nat) -> {W.insertSubs(M.setter_slot(input), 2n) == M.setter_inserted(input) : R.World}:
  ending(M.setter_slot(input), M.setter_stamped(input), M.setter_enqueued3(input), M.setter_enqueued5(input), M.setter_inserted(input),
    intake(M.setter_slot(input), 2n, M.setter_stamped(input), 44n, 1n, stamp_known(input), {==}, {==}),
    both(M.setter_stamped(input), M.setter_enqueued3(input), M.setter_enqueued5(input), first_edge(input), first_heap(input), second_edge(input), second_heap(input)), final(input))
