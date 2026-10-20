# Selected first-class createSignal initializers

A bound getter, setter or root disposer passed as createSignal's first argument
now takes the source typeof-function branch. It is called by a writable computed
node, not stored as data in an unowned data signal. `SignalScope` evaluates its
initial argument once before this dispatch. `SignalComputeScope` and the selected
function branch share `core.signalCompute`: allocate computed, eagerly recompute
unless lazy, clear CONFIG_AUTO_DISPOSE, bind the actual getter/setMemo pair, then
continue the caller. The initial compute's previous argument is independent of
that caller's previous value.

The function is represented by its existing canonical Value and a compute thunk
that invokes it with the computed node's previous value. Accessors enter normal
read/tracking; setters enter their captured setSignal/setMemo target; disposers
enter their captured root's disposal. A function returned by the initializer is
ordinary computed data, not another initializer call. Eager/lazy option behavior,
loading and stored pending/error state follow the shared computed implementation.
Nested instances are owned computed nodes. A top-level host signal call has no
ambient owner and therefore creates an unowned computed node for this overload.

Named setters now retain that selected entry too. Host set/update, imperative
program set, expression set/update and the admitted imperative owner teardown
path route to setMemo for writable memo targets. The previous data-only facade
would omit REACTIVE_MANUAL_WRITE and held rederivation. This was a port/adapter
limit, not an upstream bug. Source setMemo's captured held local and its preserved
returned-function invocation bug remain unchanged.

Owner teardown's selected memo setter has separate return points for a raw bound
disposer: held setMemo invokes it before setSignal captures its entry value;
non-held setSignal captures before the call. A reentrant cleanup write therefore
can affect these branches differently. Throws skip the setter and memo remainder.
Getter/setter updater functions in teardown still require the unfinished read
boundary and remain rejected. No cached-read shortcut was introduced.

66 complete differential histories compare overload choice, fields/flags, tracked
and imperative reads, returned pair identity, manual writes, held/non-held updater
arguments, named application and teardown calls, eager/lazy initialization,
pending/error getter initialization, real root cleanup/throws and disposal/freezing.
Twelve additional controls pass the original native bound function directly to
Solid's createSignal and compare values, node fields and lifetime. They do not
claim complete internal traces. The traced reference wrapper calls that original
function once with the actual previous argument; reflection on _fn identity,
function source/name/length and performance is outside the admitted ABI.

Constructor alignment adds 1,536 unwrapped native getter-initializer cases across
all existing option/loading/parent/unobserved combinations (10,752 total). The
probe compares the dependency's node identity rather than a JS link object to a
Bend arena index. Four new mutations target wrong callable dispatch, the wrong
previous argument, missing memo setter policy and capturing a held entry too early.
One new closed kernel law constructs from an escaped getter, checks the writable
computed's ownership/configuration, commits a manual write, rederives after an
input change, then freezes at owner disposal while the data input remains live.

Arbitrary host functions, general closure values and custom comparator functions
remain unfinished. This extends the selected function domain; it is not a claim
that all JavaScript function initializers or the complete public package execute.
The source pin and empty semantic deviation register are unchanged.

First-class named callback values now retain canonical function identity and
enter the same core call/argument, initializer and updater paths. Their imperative
teardown subset can be selected dynamically; see [callback-values.md](callback-values.md).
Read-capable teardown remains unfinished; the boundary investigation and explicit
next return points are in [the teardown review](reviews/teardown-boundary.md).
