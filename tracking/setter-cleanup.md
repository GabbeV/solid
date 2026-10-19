# Selected setters registered with onCleanup

The admitted onCleanup value family now includes actual data-signal and
expression-initializer writable-memo setters. Registration returns the same
function. A null ambient owner returns immediately without allocating a callback
encoding; other owners use the existing cleanup slot/list and detached LIFO walk.
No new disposal order or owner scope is introduced.

`callable.encodeSetter` supplies one canonical callback-arena identity per bound
setter. It is a distinct action tag from root disposal and uses the original
function's captured node. The source calls disposal functions with
`callable.call(callable)` and no arguments. Bound setters ignore that call
receiver and receive undefined as their value; registration does not execute them.
The user ABI can express this use for setters whose value type includes undefined.

`owner.CleanupBoundSetter` resumes the existing owner machine. A data setter enters
the shared resolved-value setter with undefined. A memo setter runs exactly
setMemo(undefined): the original held decision, setSignal, then the held
rederivation/manual-proposal remainder. Since undefined has no callable arm, that
specific call needs no expression/read suspension. The leaf helper skips its
remainder on a resource/unsupported fault. This is a source-specific no-argument
call path, not permission to handle arbitrary callbacks with a cached value.

The same callback identity can appear in multiple owners and multiple positions
in one disposal array. Later registration does not create a new callable. A throw
from an earlier LIFO callback stops the walk with its source partial state;
reentrant disposal encounters the already detached list. Dead-owner registration,
pending function delivery and subsequent repeated disposal follow production
source behavior, including its inactive/dead cases.

42 complete histories compare the actual package: canonical aliases across all
owner slots, no-argument writes, data/eager/lazy writable targets, repeated calls,
LIFO with named writes (including writes to the same data target), interrupted
lists, pending delivery, held writable derivations and reentrant root cycles.
Native identity/no-owner allocation controls are additional checks. Four mutations
target the bound receiver, missing undefined argument, returned identity and
canonical callback reuse.

One closed kernel law registers the same bound setter twice, checks the original
return and shared callback identity, disposes its root, and commits the resulting
undefined write while the unowned signal survives. It checks slots, disposal,
queues and ambient state through the actual runtime. This is one concrete law,
not a proof of arbitrary callbacks or TS/Bend equivalence.

Raw setter functions used as another setter's updater during owner teardown are
still rejected: their arguments can themselves be functions and require the
unfinished owner/core read boundary. Getter cleanup and arbitrary expression
teardown remain unfinished. Dynamic effect-returned cleanup selection and general
callable inputs also remain open. The source pin and empty deviation register
are unchanged.
