# Bound disposer cleanup registration

The admitted init-bound function family can now be passed to the real production
onCleanup/cleanup path. OnCleanup evaluates its argument first, registers under
the ambient owner, and returns that same function value. With no owner it returns
without adding a disposal slot or encoding a callback. The existing static named
cleanup-program API remains available for imperative callbacks.

A RootDisposerReference uses its root ID as function-data identity. Disposal slots
already use callable IDs in the callback arena. runtime/callable.bend provides the
canonical relation: one hidden CleanupBoundRoot program per admitted bound
function, reused across repeated and separate-owner registrations. It is a lazy
encoding of an existing function, not a fresh source callback. The hidden action
invokes disposeRootSelf(root,true) through the existing owner Enter continuation.
No scheduler, child walk, exception or teardown-order algorithm is replaced.

The source absent/single/array forms, array registration order, detach-before-call,
reverse invocation, bound receiver, early disposed guard and exceptional partial
state are retained. Reentrant self, mutual and child-to-parent disposal run on
the same owner machine as earlier cleanup proofs. A callback's current ambient
context is not replaced with its bound receiver.

24 differential histories compare public source calls, actual returned/thrown
values, callable alias relations in every observed disposal list, LIFO trace,
no-owner and dead-owner behavior, pending argument delivery, self/mutual/ancestor
reentry and throwing teardown. Native callable-return identity and canonical
arena identity are independently asserted. Three compiled mutations exercise
lost returns, duplicate callable identities and incorrect bound receivers.

The closed bound_cleanup_preserves_identity law registers one detached-root
bound function twice, checks the same ID occupies both array entries, disposes
the registering root and checks that the detached target's cleanup runs exactly
once, both roots die and ambient state restores. This concrete law does not prove
a general lifetime, termination, arbitrary function or TS-equivalence theorem.

Arbitrary function input/capture, function properties, general returned effect
cleanup selection, expression-bearing teardown callbacks, nested primitive
construction and active boundary/lane/high-level provider scopes remain open.
No semantic deviation or pinned-source edit is active.
