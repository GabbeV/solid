# Escaped data-signal setters and entry-value capture

`LocalSetter{depth}` names createSignal(data)'s actual setter from a lexical
const pair. Binding produces `SetterReference(signal)`, separately from the
accessor and root-disposer function families. `runtime/callable.bend:setter`
corresponds to `setSignal.bind(null,node)`. The host caches one native callable
per selected signal and sends its arguments to Bend; it does not write a slot,
choose an owner or implement a schedule.

`InvokeWith(callee,value,updater)` represents a selected user call. The callee is
evaluated first. A raw argument evaluates next, even when the selected accessor
or disposer ignores it. With updater=true, the argument is a closure: its body
runs only if the callee is a setter and receives that setter's entry previous
value. Existing outer callback/local bindings are captured. A zero-argument
setter call passes undefined. Arbitrary JavaScript functions/argument reflection
remain outside the user-code ABI.

The source typeof-function branch is also retained for a bound setter supplied
as another setter's raw argument. It invokes its own target with the outer
setter's captured previous value, then returns the result to the outer setter.
A setter returned by an updater remains function data and is not called again.
Native returns, aliases and selected bound-function calls are checked separately
from cross-runtime naming; function name/length/prototype/reflection and memory
or performance equivalence are not claimed.

## Repaired translation error: reentrant equality

Pinned TypeScript core.ts:setSignal captures currentValue before invoking an
updater, and uses that local in its later equality gate. The former port reread
the current slot afterward. This was a translation error, not an upstream bug.

Example: start at 1; an updater stages 9 on the same signal and returns 1. Solid
returns 1 but retains the staged 9 because the outer comparison is against its
entry value 1. The old port overwrote 9 with 1. A reduced paired history failed
before the repair and passes now, with equals:false and staged-entry controls.

`SetSignalArgument` captures the entry value for an evaluated raw argument.
`resolveSignalArgument` splits at an admitted callable's invocation.
`SetSignalResolved(signal,current)` resumes the original remainder using that
captured local; it never interprets a returned function as another updater.
Expression updaters capture the same local before evaluating their body. Facade,
callback and escaped-setter updates share these return points. `write.setResolved`
keeps held joins, equality, staging, promotion, time, notify-epoch and scheduling
in their source order. `write.setSignal` is the side-effect-free resolved-value
entry used by existing internal callers. Owner teardown also captures the local
before calling an admitted bound disposer; a later cleanup write does not replace
that local. A throw skips the interrupted setter remainder.

This repair introduces no deviation and changes no vendored source or pin.
Active write/lane/snapshot hooks, arbitrary comparators and general updater
functions remain unfinished. Public Setter returns now come from the machine
result, so an equality-suppressed outer write can return 1 while its nested write
leaves 9 in the slot.

## Evidence and remaining limits

Eleven reentrant-setter histories and forty escaped-setter histories compare the
actual pinned package: entry capture, existing staging, nested writes/throws,
returns, equality options, binding/shadowing, argument order, callbacks, async
function data, lifetime after root disposal and native-function error messages.
Native callable cache/alias checks and unsupported-domain checks are additional
controls. They do not count as extra differential histories.

Two closed Bend laws check the returned setter's surviving unowned target through
two staged updater calls (1 + 2 + 4 = 7), and the reentrant 1/9 example including
its setter return. One general lexical-setter law checks binding. Additional
mutations target reloaded entry values, wrong bound targets, committed-versus-
staged updater values and dropped argument effects. Existing function-result
mutations now target the new source return points.

Expression-capable teardown remains unfinished. Escaped setter registration as
onCleanup and raw setter updater calls in owner teardown are explicitly rejected.
Function-initializer/writable-memo setters use setMemo, a different source function
which is not admitted by this data-signal constructor. No manual-write or held
memo behavior is silently borrowed from the plain setter.
