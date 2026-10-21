# Public action wrapper entry and user-code parameter capture. These are general
# local laws; they do not prove arbitrary generators or their termination.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/action-state.bend as Action
import ../runtime/action-arguments.bend as Args
import ../runtime/callback.bend as Z
import ../representation/records.bend as R
import ../representation/base.bend as B

# Complete World preservation except the representation's callable arena.
# In particular creating action(genFn) allocates no Promise/transaction/node,
# changes no question/depth and schedules no reactive work.
def creation(+w: R.World, +factory: R.Expr, +methods: R.Expr, +previous: R.Value) ->
  {Action.function(w, factory, methods, previous)
    == B.Bundle{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ActionFunction{factory, methods, previous}], False{}, 0n}])), R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))}} : B.Bundle<R.World, R.Value>}:
  {==}

# The actual expression constructor forwards its current previous payload into
# the function environment, preserving the caller's continuation and operands.
def entry(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +factory: R.Expr, +methods: R.Expr, +previous: R.Value) ->
  {C.evaluate(w, rest, stack, R.ActionCreate{factory, methods}, previous)
    == C.Machine{R.World.with_cleanupPrograms(w, B.append(R.CleanupProgram, R.World.cleanupPrograms(w), [R.CleanupProgram{[R.ActionFunction{factory, methods, previous}], False{}, 0n}])), rest, R.ProgramReference{B.length(R.CleanupProgram, R.World.cleanupPrograms(w))} <> stack} : C.Machine}:
  {==}

# The callable's return enters the same ActionInvoke engine on every call;
# no saved invocation/transaction is kept on the reusable function itself.
def invocation(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, id: Nat, tail: List<&2, R.CleanupAction>, +first: R.Value, +second: R.Value, +factory: R.Expr, +methods: R.Expr, +previous: R.Value) ->
  {C.callbackAction(w, rest, stack, id, tail, first, second, R.ActionFunction{factory, methods, previous})
    == C.Machine{w, C.Evaluate{R.ActionInvoke{Args.bind(factory, 0n, first, second), Args.bind(methods, 0n, first, second)}, previous} <> rest, stack} : C.Machine}:
  {==}

# Matching parameter depth captures arbitrary admitted payloads; resume
# Argument occurrences are a separate binder and remain untouched.
def parameter(+first: R.Value, +second: R.Value, +index: Nat) ->
  {Args.bind(R.ActionParameter{0n, index}, 0n, first, second)
    == R.Literal{Z.argument(index, first, second)} : R.Expr}:
  {==}

def resume(+first: R.Value, +second: R.Value, +depth: Nat, +index: Nat) ->
  {Args.bind(R.Argument{index}, depth, first, second) == R.Argument{index} : R.Expr}:
  {==}

# Inner depth-zero parameters shadow this invocation. Outer depth-one
# parameters are captured when the enclosing function is invoked.
def nested(+first: R.Value, +second: R.Value) ->
  {Args.bind(R.ActionCreate{R.ActionParameter{0n, 0n}, R.ActionMethods{R.ActionParameter{1n, 1n}, False{}, R.Argument{0n}, R.ActionEnd{}}}, 0n, first, second)
    == R.ActionCreate{R.ActionParameter{0n, 0n}, R.ActionMethods{R.Literal{second}, False{}, R.Argument{0n}, R.ActionEnd{}}} : R.Expr}:
  {==}

# An enclosing callback captures the factory parameter. The methods' Argument
# binder belongs to each generator resume and must remain available then.
def callback_capture(+first: R.Value, +second: R.Value, +methods: R.Expr) ->
  {Z.bind(R.ActionCreate{R.Argument{0n}, methods}, first, second)
    == R.ActionCreate{R.Literal{first}, methods} : R.Expr}:
  {==}

# Two actual calls of one constructor result use fresh invocation state and
# distinct argument captures. This closed execution is separate from local laws.
def plan() -> R.Expr:
  R.ActionCreate{R.Literal{R.Undefined{}}, R.ActionMethods{R.IteratorResult{True{}, R.Add{R.ActionParameter{0n, 0n}, R.ActionParameter{0n, 1n}}}, False{}, R.Literal{R.Undefined{}}, R.ActionEnd{}}}

def constructed() -> R.World:
  A.resultWorld(A.evaluateExpression(64n, A.createWorld(), plan(), R.Undefined{}))

def called() -> R.World:
  A.resultWorld(A.evaluateExpression(256n, constructed(), R.InvokeArguments{R.Literal{R.ProgramReference{1n}}, R.Literal{R.Number{7n}}, R.Literal{R.Number{9n}}}, R.Undefined{}))

def recalled() -> R.World:
  A.resultWorld(A.evaluateExpression(256n, called(), R.InvokeArguments{R.Literal{R.ProgramReference{1n}}, R.Literal{R.Number{23n}}, R.Literal{R.Number{5n}}}, R.Undefined{}))

type View is Data:
  View{first: R.AsyncSettlement, second: R.AsyncSettlement, callables: Nat, invocations: Nat, depth: Nat, context: Nat, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.AsyncObject.state(B.asyncObject(w, 1n)), R.AsyncObject.state(B.asyncObject(w, 2n)), B.length(R.CleanupProgram, R.World.cleanupPrograms(w)), B.length(R.ActionState, R.World.actions(w)), R.World.actionDepth(w), R.World.context(w), R.World.fault(w)}

def repeated() ->
  {view(recalled()) == View{R.Fulfilled{R.Number{16n}}, R.Fulfilled{R.Number{28n}}, 2n, 2n, 0n, 0n, R.Healthy{}} : View}:
  {==}
