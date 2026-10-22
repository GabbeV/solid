# Refresh to next aece1d44

Previous source 5b1b777648a89b6e207e8bb78514d5c03420e08b; new source aece1d448b648d6e946d098f565445d30124b8c2, still declaring rc.17.
The complete pre-refresh translation is retained at a3d30b47be0addc87bf8b351533b5383f31ee40c. No source
file was patched: 77 vendored inputs were compared with Git bytes, with two
existing files changed and one added.

## Source review

The one new commit is #4218's from() adapter. index.ts gains its export; from.ts
adds subscription/Observable/AsyncIterable conversion, ownership binding and
buffering/closure protocols. These are unported, explicitly outside the admitted
host grammar. The module has no installed global hook: its bodies run only on
actual calls. Exporting it does not activate a new path in prior programs.

core/async.ts adds internal onSupersede. Only from.bindToOwner calls it. It guards
for a computed owner in its own pass; a fresh extension stores _inFlight as
undefined to preserve recompute's body-registration test, then chains teardown
with try/finally. This branch is unported. The current numeric inFlight handle
must not silently represent that new undefined state as null when this hook is
implemented. Callback composition must preserve both throws and finalizer order.
No existing async function statement changes; consumeIterator gains a comment
confirming that its slot assignment replaces earlier onSupersede registrations.
The existing typed stream/owner-death cleanup paths remain unchanged.

The new function/module and all their branches stay open in the inventory.
No from or onSupersede support is claimed. The non-store deferred lookup added
at the prior checkpoint maps unchanged source and retains its proof domains.
No active deviation needed reconciliation; the register remains empty.

## Validation

The clean native checkout builds production/development/observe JS and source
declarations. All 336 native signals files pass: 5,501 passing tests, three
expected failures and two skips. The first pnpm-filter attempt refused a
symlinked task-state directory; direct npm scripts and vitest completed using
the same installed dependencies. This environment issue is not a Solid bug.

The existing Bend runtime is unchanged. The full comparison and independent
proof passes are rerun against the refreshed source. The additional public
mark/error/loading/cleanup/capture cases and binding mutations strengthen prior
coverage; they do not translate the new from API. See the validation JSON and
[verification](../verification.md) for the final evidence boundary.

Two new source-only integration defects were reduced during this audit:
[deferred buffered subscriptions](../upstream/deferred-buffered-from.md) and
[synchronous subscription teardown](../upstream/from-sync-unsubscribe.md).
Both have isolated, fully tested candidate patches; neither is patched into the
baseline or active Bend runtime. They are confirmed and unfiled. All 3,410 public
histories, private alignment suites and 455 assertion-based mutation rejections
pass against the unchanged refreshed source. The independent kernel seal is in
tracking/checked.json. Existing quantified program domains/budgets are unchanged.
