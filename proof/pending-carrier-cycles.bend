# Induction over arbitrary finite single-source add/remove choices. Every output
# snapshot is constructed from the actual next World, including re-registration.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-command-history.bend as Commands
import ./pending-carrier-state.bend as State

type CarrierOutcome<-node: Nat, -source: Nat> is Data:
  CarrierOutcome{world: R.World, snapshot: State.CarrierSnapshot<world, node, source>}

def run(+node: Nat, +source: Nat, commands: List<&2, Commands.Command>, +w: R.World, snapshot: State.CarrierSnapshot<w, node, source>) -> CarrierOutcome<node, source>:
  match commands:
    case Nil{}: CarrierOutcome{w, snapshot}
    case +command <> tail: run(node, source, tail, State.next(w, node, source, command), State.step(w, node, source, snapshot, command))

def world(-node: Nat, -source: Nat, result: CarrierOutcome<node, source>) -> R.World:
  match result:
    case CarrierOutcome{world, snapshot}: world

def snapshot(-node: Nat, -source: Nat, +result: CarrierOutcome<node, source>) -> State.CarrierSnapshot<world(node, source, result), node, source>:
  match result:
    case CarrierOutcome{world, snapshot}: snapshot

def expected(commands: List<&2, Commands.Command>, initial: Bool) -> Bool:
  match commands:
    case Nil{}: initial
    case command <> tail: expected(tail, State.isAdd(command))

def runPresent(+node: Nat, +source: Nat, +commands: List<&2, Commands.Command>, +w: R.World, +initial: State.CarrierSnapshot<w, node, source>) ->
  {State.present(world(node, source, run(node, source, commands, w, initial)), node, source, snapshot(node, source, run(node, source, commands, w, initial))) == expected(commands, State.present(w, node, source, initial)) : Bool}:
  match commands:
    case Nil{}: {==}
    case +command <> +tail:
      +next = State.next(w, node, source, command)
      +nextState = State.step(w, node, source, initial, command)
      +result = run(node, source, tail, next, nextState)
      Equal.trans(Bool, State.present(world(node, source, result), node, source, snapshot(node, source, result)), expected(tail, State.present(next, node, source, nextState)), expected(tail, State.isAdd(command)), runPresent(node, source, tail, next, nextState), Equal.cong(Bool, Bool, active => expected(tail, active), State.present(next, node, source, nextState), State.isAdd(command), State.stepPresent(w, node, source, initial, command)))

def membership(+node: Nat, +source: Nat, +commands: List<&2, Commands.Command>, +w: R.World, +initial: State.CarrierSnapshot<w, node, source>) ->
  {P.hasSource(world(node, source, run(node, source, commands, w, initial)), node, 1n+source) == expected(commands, State.present(w, node, source, initial)) : Bool}:
  +result = run(node, source, commands, w, initial)
  Equal.trans(Bool, P.hasSource(world(node, source, result), node, 1n+source), State.present(world(node, source, result), node, source, snapshot(node, source, result)), expected(commands, State.present(w, node, source, initial)), State.sound(world(node, source, result), node, source, snapshot(node, source, result)), runPresent(node, source, commands, w, initial))

def fresh(+w: R.World, +node: Nat, +source: Nat, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  valid: {B.valid(w, node) == True{} : Bool}, empty: {R.Node.x(B.node(w, node)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> State.CarrierSnapshot<w, node, source>:
  State.CarrierFresh{extensions, sets, valid, empty, extensionArena, setArena}

def freshMembership(+node: Nat, +source: Nat, +commands: List<&2, Commands.Command>, +w: R.World, +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +valid: {B.valid(w, node) == True{} : Bool}, +empty: {R.Node.x(B.node(w, node)) == 0n : Nat}, +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(world(node, source, run(node, source, commands, w, fresh(w, node, source, extensions, sets, valid, empty, extensionArena, setArena))), node, 1n+source) == expected(commands, False{}) : Bool}:
  membership(node, source, commands, w, fresh(w, node, source, extensions, sets, valid, empty, extensionArena, setArena))


def executeWorld(+node: Nat, +source: Nat, commands: List<&2, Commands.Command>, w: R.World) -> R.World:
  match commands:
    case Nil{}: w
    case command <> tail: executeWorld(node, source, tail, State.next(w, node, source, command))

def worldAgreement(+node: Nat, +source: Nat, +commands: List<&2, Commands.Command>, +w: R.World, +initial: State.CarrierSnapshot<w, node, source>) ->
  {world(node, source, run(node, source, commands, w, initial)) == executeWorld(node, source, commands, w) : R.World}:
  match commands:
    case Nil{}: {==}
    case +command <> tail: worldAgreement(node, source, tail, State.next(w, node, source, command), State.step(w, node, source, initial, command))

def worldMembership(+node: Nat, +source: Nat, +commands: List<&2, Commands.Command>, +w: R.World, +initial: State.CarrierSnapshot<w, node, source>) ->
  {P.hasSource(executeWorld(node, source, commands, w), node, 1n+source) == expected(commands, State.present(w, node, source, initial)) : Bool}:
  +result = run(node, source, commands, w, initial)
  Equal.trans(Bool, P.hasSource(executeWorld(node, source, commands, w), node, 1n+source), P.hasSource(world(node, source, result), node, 1n+source), expected(commands, State.present(w, node, source, initial)), Equal.cong(R.World, Bool, actual => P.hasSource(actual, node, 1n+source), executeWorld(node, source, commands, w), world(node, source, result), Equal.sym(R.World, world(node, source, result), executeWorld(node, source, commands, w), worldAgreement(node, source, commands, w, initial))), membership(node, source, commands, w, initial))
