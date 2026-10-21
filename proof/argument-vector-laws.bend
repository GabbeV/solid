# Quantified parameter/call-order properties of the user-code ABI. These are
# separate from Solid's reactive algorithms and from arbitrary JS equivalence.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/callback.bend as Z
import ../runtime/action-arguments.bend as Args
import ../runtime/core.bend as C
import ../runtime/api.bend as A

def callback_lookup(+index: Nat, +values: List<&2, R.Value>) ->
  {Z.bindMany(R.Argument{index}, values) == R.Literal{B.get(R.Value, values, index, R.Undefined{})} : R.Expr}:
  {==}

def action_lookup(+index: Nat, +values: List<&2, R.Value>) ->
  {Args.bindMany(R.ActionParameter{0n, index}, 0n, values) == R.Literal{B.get(R.Value, values, index, R.Undefined{})} : R.Expr}:
  {==}

def resume(+depth: Nat, +index: Nat, +values: List<&2, R.Value>) ->
  {Args.bindMany(R.Argument{index}, depth, values) == R.Argument{index} : R.Expr}:
  {==}

def root_shadow(+body: R.Expr, +values: List<&2, R.Value>) ->
  {Z.bindMany(R.RootScope{body, False{}}, values) == R.RootScope{body, False{}} : R.Expr}:
  {==}

def callback_factory(+index: Nat, +methods: R.Expr, +values: List<&2, R.Value>) ->
  {Z.bindMany(R.ActionCreate{R.Argument{index}, methods}, values) == R.ActionCreate{R.Literal{B.get(R.Value, values, index, R.Undefined{})}, methods} : R.Expr}:
  {==}

def nested_capture(+inner: Nat, +outer: Nat, +values: List<&2, R.Value>) ->
  {Args.bindMany(R.ActionCreate{R.ActionParameter{0n, inner}, R.ActionMethods{R.ActionParameter{1n, outer}, False{}, R.Argument{0n}, R.ActionEnd{}}}, 0n, values) == R.ActionCreate{R.ActionParameter{0n, inner}, R.ActionMethods{R.Literal{B.get(R.Value, values, outer, R.Undefined{})}, False{}, R.Argument{0n}, R.ActionEnd{}}} : R.Expr}:
  {==}

def callee_first(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +callee: R.Expr, +args: R.Expr, +previous: R.Value) ->
  {C.evaluate(w, rest, stack, R.InvokeMany{callee, args}, previous) == C.Machine{w, C.Evaluate{callee, previous} <> C.InvokeManyCallee{args, previous} <> rest, stack} : C.Machine}:
  {==}

def next_argument(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +callee: R.Value, +head: R.Expr, +tail: R.Expr, +reversed: List<&2, R.Value>, +previous: R.Value) ->
  {C.invokeManyArguments(w, rest, stack, callee, R.CallArgumentsItem{head, tail}, reversed, previous) == C.Machine{w, C.Evaluate{head, previous} <> C.InvokeManyValue{callee, tail, reversed, previous} <> rest, stack} : C.Machine}:
  {==}

# Two complete closed executions use the actual public call evaluator. They do
# not claim a general termination theorem for arbitrary callback/generator code.
def arguments() -> R.Expr:
  R.CallArgumentsItem{R.Literal{R.Number{1n}}, R.CallArgumentsItem{R.Literal{R.Number{2n}}, R.CallArgumentsItem{R.Literal{R.Number{3n}}, R.CallArgumentsItem{R.Literal{R.Number{4n}}, R.CallArgumentsItem{R.Literal{R.Number{5n}}, R.CallArgumentsItem{R.Literal{R.Number{6n}}, R.CallArgumentsItem{R.Literal{R.Number{7n}}, R.CallArgumentsItem{R.Literal{R.Number{8n}}, R.CallArgumentsItem{R.Literal{R.Number{9n}}, R.CallArgumentsEnd{}}}}}}}}}}

type View is Data:
  View{value: R.Value, outcome: R.AsyncSettlement, calls: Nat, nodes: Nat, context: Nat, tracking: Bool, depth: Nat, fault: R.Fault}

def callback_case() -> View:
  w = A.registerProgram(A.createWorld(), A.programReturn(R.Argument{8n}, A.emptyProgram()))
  +m = A.evaluateExpression(256n, w, R.InvokeMany{R.Literal{R.ProgramReference{1n}}, arguments()}, R.Undefined{})
  +w = A.resultWorld(m)
  View{A.resultValue(m), R.Unresolved{}, B.length(R.ActionState, R.World.actions(w)), B.length(R.Node, R.World.nodes(w)), R.World.context(w), R.World.tracking(w), R.World.actionDepth(w), R.World.fault(w)}

def action_case() -> View:
  +made = A.evaluateExpression(256n, A.createWorld(), R.ActionCreate{R.Literal{R.Undefined{}}, R.ActionMethods{R.IteratorResult{True{}, R.ActionParameter{0n, 8n}}, False{}, R.Literal{R.Undefined{}}, R.ActionEnd{}}}, R.Undefined{})
  +m = A.evaluateExpression(256n, A.resultWorld(made), R.InvokeMany{R.Literal{A.resultValue(made)}, arguments()}, R.Undefined{})
  +w = A.resultWorld(m)
  View{A.resultValue(m), R.AsyncObject.state(B.asyncObject(w, 1n)), B.length(R.ActionState, R.World.actions(w)), B.length(R.Node, R.World.nodes(w)), R.World.context(w), R.World.tracking(w), R.World.actionDepth(w), R.World.fault(w)}

def callback_complete() -> {callback_case() == View{R.Number{9n}, R.Unresolved{}, 0n, 2n, 0n, False{}, 0n, R.Healthy{}} : View}:
  {==}

def action_complete() -> {action_case() == View{R.AsyncValue{1n}, R.Fulfilled{R.Number{9n}}, 1n, 2n, 0n, False{}, 0n, R.Healthy{}} : View}:
  {==}
