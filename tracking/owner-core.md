# Direct owner/core continuation bridge

Owner tasks now enter the existing core continuation machine at direct disposal,
bound root invocation, callback imperative actions, the previous-effect-cleanup
call and recompute's pre-body flight/current-frame teardown. `OwnerTasks` retains
the actual owner task list. Ordinary steps call the same owner.dispatch helper;
an Invoke pauses that walk, executes the program through core's existing callback
and read continuations, discards its result, then resumes the saved owner tasks.
No new ambient owner/tracking scope or node/world field is introduced.

The source owner traversal and pointer stores remain in owner.bend. Child lists
are still detached before descent; next siblings are read after callbacks; cleanup
lists are still detached and walked in LIFO order. A callback throw skips the saved
owner tail and reaches the caller's existing catch/finally. Nested computed reads
retain the caller operand stack. Returned promises/functions are ignored at this
void cleanup call point, as in the source.

Recompute preparation now has explicit return points after flight teardown and
current-frame disposal. Its old duplicate World helper was removed. Epoch bump,
heap deletion, in-flight clearing, detached flight teardown, pending/verdict clear,
held reentry, staged disposal versus parking, then compute-frame capture retain
the source order. A preparation callback failure still unwinds the caller before
this node's compute try; it is not caught as a new body error of this node.
The effect's old cleanup is cleared before its call and before the application
callback, with its existing finally frame still waiting below both.

Public native root-disposer and disposal facades use the same core step relation.
Their implicit budget includes an eightfold bookkeeping allowance for the extra
callback/owner continuation steps. Without that allowance, a previously admitted
96-statement imperative cleanup emitted all its events then reported Exhausted
before returning. A paired public history and native function control retain its
successful completion. Explicit exhaustion is still a fault; no truncated walk is
presented as success and no general progress/fuel bound theorem is claimed.

35 direct owner/core probes install actual programs using a small fixture export
of owner.cleanup, and compare with native Solid onCleanup/createEffect calls. They
bypass the harness's global teardown-admission restriction only at those fixture
entries. Results, all observed node fields, owner/effect aliases, read/apply/cleanup
order, reports, native pending delivery and ambient restoration are compared. Cases
include lazy pulls, pending/error throws, partial teardown, live caller operands,
child cleanup, ignored returns, nested construction/registration and caller observer
identity. An imperative static-owner helper control separately retains the old
restricted helper path's held-setter callback entry behavior. These probes are
separate from the 1,963 public-ABI histories.

One concrete kernel law installs an expression cleanup, calls its bound root
disposer with a live outer operand, pulls a lazy unowned memo, writes/commits its
result and checks root death, slots, queues and ambient state. The generic path
lemmas still describe the active core.step relation. Three additional mutation
checks cover lost caller tracking, a cleanup return corrupting the operand stack,
and the restricted owner helper's early capture; the existing held-capture mutation
now targets the active core continuation.

This is a foundation, not full read-capable teardown admission. Scheduler commit
and held trims, core publication/finally trim callers, asyncWrite/settlement,
pending-source deferred release and watch/until disposal still need corresponding
return points. Their restricted owner helper paths remain in use. Public admission
continues to reject general teardown expressions so the same installed callback
cannot accidentally fail through one of those unmigrated callers. No cached-read
shortcut, higher-order executor prototype, semantic workaround or source repin is
active. See [the boundary review](reviews/teardown-boundary.md).
