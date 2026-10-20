# First-class named callback functions

`{callback: name}` now denotes a stable callable Value, rather than an instruction
to call a program immediately. Named callback programs remain the user-code ABI.
This extends the function-value domain; it does not add a Solid API or a reactive
node field. Definitions have immutable names within a runtime. General lexical
closures, reflection and arbitrary JavaScript functions remain unfinished.

A `ProgramReference` retains the program ID. Zero/one-argument calls and
`invokeArgs(callee, args)` enter the same core callback machine as named calls;
the latter admits up to two arguments and evaluates callee, first and second in
that order. Extra arguments to a getter/setter/disposer are evaluated even though
its bound entry ignores them. Callback argument substitution and lexical signal
binding traverse this expression, so higher-order calls retain both environments.
Named bodies see their two argument slots; their `prev` expression remains
undefined. Updater closure arguments to a general callback value are still outside
the represented function family and report an explicit domain fault.

Raw setter function inputs invoke this callback with the captured entry value.
Its returned function is data at setSignal's resolved return point. Held setMemo
still invokes an updater's returned function again on the pinned implementation;
that upstream counterexample is preserved, including a named callback counterpart.
Passing a callback value as createSignal's initial argument uses the existing
writable-computed function overload. Returned thenables enter its ordinary async
path; callback functions delivered by a native promise remain callable data.

The Source adapter represents this function as the original named program wrapper
bound to an undefined error-helper parameter. The bound function has a separate
identity from the existing static cleanup wrapper. Native materialization in the
Bend host uses a per-runtime cache and re-enters the same emitted callback machine.
Opaque function source/name/length/prototype reflection is outside the ABI; the
captured StatusError message for this native bound-function family is retained.
Helper-dependent programs, including helper use through named calls, are excluded
from public function values. Their explicit error-arm entry remains available.

At onCleanup or an effect's returned-cleanup assignment, `encodeProgram` creates
one canonical callback-arena wrapper for the bound function. Repeated registrations
and multiple effects/owners reuse it. The original static cleanup ID stays distinct.
The owner walk invokes the original program with no user arguments, preserving
its detached LIFO traversal, bound receiver behavior and partial states on throws.
Only the existing imperative teardown program domain is admitted here. Expression
teardown still needs the unfinished owner/core continuation boundary. No-owner
onCleanup returns the same function without inspecting or allocating a cleanup.

63 complete histories compare actual pinned Solid results, node fields, owner and
effect cleanup identities, traces, reports, ambient restoration and native promise
observations. They cover values/aliases, tracked and imperative calls, ordered and
throwing arguments, higher-order dispatch, callee capture before argument effects,
function initialization, pending initialization, raw/held setters, function results,
promise-delivered registration and runtime-selected cleanup. Native cache/two-argument
calls and domain checks are additional controls. Four new mutation variants target
missing raw invocation, wrong positional binding, a wrong constructor branch and
lost canonical cleanup aliases.

One closed kernel law calls with two arguments, constructs a writable computed
from the same function family, registers another function twice with shared cleanup
identity, then disposes and commits its writes through the active runtime. It checks
that the unowned derived signal remains live. This is one concrete composed law,
not a theorem for arbitrary functions or TypeScript equivalence. The pin and empty
deviation register are unchanged.
