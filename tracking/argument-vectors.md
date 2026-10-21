# Variable-arity user calls

Source: Solid d682022c. `core/action.ts` returns `(...args)` and invokes
`genFn(...args)` inside the Promise executor. JavaScript evaluates the callee and
all arguments before entering that wrapper. The prior typed call ABI admitted
only two arguments. This extension removes that admission limit for the existing
callback/action function values; it does not introduce a new reactive primitive.

## Representation and operation order

- Existing source calls with fixed argument pairs retain their `CallWith` /
  `InvokeArguments` continuations and callback driver. Internal compute/effect,
  comparator, updater, cleanup and generator-resume parameter rules are unchanged.
- Longer user calls enter `InvokeMany`: evaluate the callee once, then each
  argument expression once from left to right, then call. `InvokeManyCallee` and
  `InvokeManyValue` carry the explicit return points. A throw stops the argument
  walk before function entry, retaining earlier argument side effects. In
  particular no action Promise/transaction is allocated until argument evaluation
  finishes and the original action entry begins.
- Argument syntax uses linked `CallArgumentsItem` / `CallArgumentsEnd` expressions,
  like the existing linked `ActionMethods` syntax. The same callback, action and
  lexical capture walkers traverse its children. Evaluated values accumulate in
  reverse and reverse once at the call boundary, avoiding quadratic list copying.
- `callback.Arguments.Pair` preserves the old two-slot binding. `Many` holds an
  immutable list: index lookup returns its value or undefined when absent.
  `bindMany` captures user syntax; it performs no read, write, callback invocation,
  node allocation or scheduling operation.
- `core.bindCallActions` captures the admitted callback expressions or action
  factory/method parameters, then enters the same `callback` / `callbackAction`
  code and the same callable arena ID. Existing resume parameters remain their
  own binder. Root initializers shadow an enclosing callback, and nested action
  functions shadow their own parameters while capturing outer ones.
- Bound getters, setters and disposers ignore surplus values as their source
  signatures do; every surplus argument expression still executes before entry.
- The Bend host's cached callable proxy now forwards `...args`. The Solid host
  continues to return the actual `S.action` function unchanged. Native calls are
  observed after returning, preserving the original function and Promise identity.

The new `mapWith` helper passes immutable binding data separately from closed code
when transforming callback action lists. This is user-code representation, not a
replacement for a Solid traversal, scheduler, callback policy or transaction.
Malformed internal argument syntax refuses with Unsupported 60; the public grammar
always constructs a well-formed linked argument sequence. No semantic deviation
or pinned source/toolchain change is active.

## Evidence

- 70 paired histories cover static, first-class and raw calls; arities 3/4/9;
  high/missing argument indices; callee/argument side-effect order and throws;
  lexical/callback/action capture; ignored extras; function/reference aliases;
  updater/throw bodies; root shadowing and overlapping suspended invocations.
  These comprise 48 callback/entry controls and 22 action-related cases.
- Six separately authored native generators/factories validate five-argument
  invocation, held writes, fulfillment/rejection, resume values and a factory
  failure before transaction allocation. They do not use the source adapter's
  parameter substitution or typed method descriptors.
- Eight quantified local properties cover arbitrary admitted parameter lists,
  indices and payloads, shadow/capture rules, callee-first entry and next-argument
  continuation order. Two closed kernel executions call a callback and an action
  with nine arguments and obtain the actual ninth value / fulfilled result.
- Eight new compiled mutation variants exercise vector reversal, dropped argument
  evaluation, callback/action/factory capture, linked-syntax capture and lookup.
  Seven use finite assertion oracles; one uses a proof-property assertion oracle, which can reject a false equation
  in the frontend before the independent kernel starts.
  Resource/infrastructure failures remain excluded from useful rejections.

The existing two-argument rejection controls now assert successful source behavior
when an extra argument is supplied. Older call and action tests remain intact.

## Limits

Argument lists are finite, and executions still require sufficient explicit fuel.
There is no theorem of termination for arbitrary callbacks/generators, formal
JavaScript equivalence or full action API completion. Callables remain the admitted
bound accessors/setters/disposers, named callback programs, reactions and typed
action wrappers. Arbitrary JavaScript functions, closure reflection, `arguments`
objects/rest-array manipulation, protocol getters, internal async-generator awaits,
full native Promise cycles and active lane/boundary/optimistic/store engines remain
unfinished. See actions.md and callback-values.md for their retained boundaries.
