# Bound getters used as cleanup functions

Solid stays pinned at b0ad1df5 (rc.16). The admitted function family now includes
data-signal getters, computed getters and expression-initializer writable-memo
getters as direct `onCleanup` arguments and returned effect cleanup values.
General closures, arbitrary callable initializers, custom comparators and active
boundary/lane/store engines remain unfinished. No semantic deviation is active.

## Source correspondence

`signals.ts:accessor` returns `read.bind(null, node)`. `onCleanup` passes that same
function to `owner.ts:cleanup` and returns it. A null owner causes no registration
or callback allocation. An owner stores the original callable in its existing
absent/single/list form; the source does not wrap or execute the getter then.

The Bend value remains `AccessorReference(node)`. Cleanup slots hold callback
arena IDs, so `callable.encodeAccessor` lazily provides one canonical singleton
`CleanupBoundAccessor(node)` program for each getter. The callback ID is reused
across owners, repeated positions and returned effect-cleanup slots. It is
distinct from a setter/root/program with a different function identity. This is
the existing callable representation extended to getters, not a new source
function allocation or source-node field.

The unchanged owner walk detaches the list and invokes it in reverse order using
`callable.call(callable)`. A bound getter ignores this receiver and all arguments;
it reads the node captured by `bind`. `core.callbackAction` therefore enters the
ordinary `ReadNode(node)` continuation, leaving ambient context/tracking and the
caller's operand stack intact. It returns the actual read result. The existing
`ownerTasks` boundary discards it because cleanup returns are ignored. A returned
function is not invoked again. No cached-value read, new owner, untrack boundary,
scheduler or publication algorithm is introduced.

`core.installReturned` stores the same canonical ID after a successful effect
application return and before its finally. Previous-cleanup errors still skip
application/assignment and follow the existing effect error routing. Getter
NotReady/errors take the same read and owner/core unwind paths as other calls.
World-only owner helper facades remain restricted and reject read-capable action
bodies; active engine callers already suspend through the shared core driver.

## Evidence and limits

`tests/getter-cleanup.mjs` adds **54 public differential histories**:

- Data/eager/lazy targets, repeated registration and independent owners retain
  callable aliases. Native controls verify `onCleanup` returns the original
  getter, the actual source disposal list holds it unchanged, no-owner registration
  allocates no callback, and registration does not activate a lazy target.
- Lazy pulls preserve LIFO ordering, interrupted lists and repeated disposal.
  Direct and returned cleanup calls preserve pending/rejected/fulfilled reads
  across immediate/native settlement and captured writable getters.
- Render/user cleanup slots share aliases with owner slots; replacement by
  undefined removes a prior cleanup. Root reentry and dead-owner registration
  retain the source's partial states.
- Disposal triggered during a compute retains that caller's tracking: dependency
  targets, order and generations are compared after each operation. Returned
  function-valued data stays uncalled; the independent victim root remains alive.

The native cleanup walker calls a bound getter without passing through the host's
read observer. The test registers the native getter unchanged rather than wrapping
it to manufacture a trace. This suite therefore **omits read-event comparison**
and compares every other trace event, ordered dependency targets/generations,
computed state, disposal/effect-slot aliases, return/throw values, native callback
failures, screens, reports and ambient state. It does not claim complete internal
read traces; the older suites retain their own read-event comparisons. This is an
explicit observation limit, not a change to the source runtime or a workaround.

Four added compiled mutations change the bound target to the ambient owner,
discard the registered return identity, allocate duplicate callable identities,
or bind a returned cleanup to its effect instead. Each is rejected by assertions;
the full mutation suite now contains **101** rejected variants.

`getter_cleanup_preserves_identity_and_pulls` is one concrete independent-kernel
regression. Two public registrations share a callable ID and return the getter.
Disposing the root reads an unowned lazy memo whose actual computation adds
3 + 3. A live outer operand survives so the caller returns 42; the ignored cleanup
answer remains 6 in the memo. The detached list, root death, queues/ambient state
and successful completion are checked. This is not a general callback, arbitrary
graph or TS/Bend equivalence proof.

Current totals: **2,169 public histories**, **136 separate direct owner/core
probes**, full helper alignment, **101 mutation rejections**, and **49 concrete
kernel regressions** (48 positive, one preserved upstream collector counterexample),
plus the existing general helper laws. Pins and the empty deviation register are
unchanged. Original #4176 collector behavior is still preserved.
