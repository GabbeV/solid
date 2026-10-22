# Synchronously closed from subscriptions leak unsubscribe failures

Confirmed against unchanged next aece1d448b648d6e946d098f565445d30124b8c2.
This is source-only evidence: from is not yet admitted by Bend. No active-runtime
workaround is installed and no issue or PR has been filed.

[The minimal component](../../repros/playground/from-sync-unsubscribe.tsx)
creates an ordinary memo from a subscription that publishes 7, completes, then
returns an unsubscribe function that throws. Expected: Value: 7. Actual: the
unsubscribe error escapes and JSX rendering fails. Changing complete() to
queueMicrotask(complete) is a passing control with the identical unsubscribe.
For source errors, synchronous closure can also replace the original source error
with the unsubscribe error; the candidate preserves the original error identity.

from.close catches unsubscribe errors. A synchronously completing/erroring subscribe
callback closes before subscribe returns its teardown. Afterward the closed branch
invokes that just-returned teardown directly, without the catch used by close.
Both returned functions and { unsubscribe() } objects are affected. This is separate
from the general onCleanup error-policy question: #4218 explicitly includes a review
fix to contain throwing unsubscribes, with tests for both teardown shapes. This
branch misses the same policy.

[The isolated candidate patch](from-sync-unsubscribe.patch) puts the immediate
closed-branch call inside try/catch, matching close's existing behavior. It adds no
state or allocation, preserves clearing-before-call and once-only teardown, and
leaves asynchronous/owner/supersession paths unchanged. The pinned reference is
untouched. Candidate worktree: /workspace/solid-from-sync-unsubscribe-candidate.

Four synchronous cases fail before the patch; four asynchronous controls pass.
All eight pass with it. The candidate passes all three JS builds and declarations,
337 files /5,509 tests (three expected failures, two skips), Prettier and release
invariants. Real JSX baseline/control and candidate/control runs pass across
production/development/observe: twelve browser cases. The standalone Node script
asserts the defect/controls by default and supports --expect-fixed for the candidate.

Rolldown 1.2.11 adds 12 minified /2 Brotli bytes to from and the combined import;
all four standard scenarios remain unchanged and no caps changed. No timing claim
is made. [The validation record](from-sync-unsubscribe-validation.json) retains all
size rows and browser evidence. Hosted sharing is still being investigated because
the released rc.17 runtime lacks from.

Related: [#4218](https://github.com/solidjs/solid/pull/4218), whose review-fix summary
explicitly describes swallowing throwing unsubscribes after iterator closure;
[#4182](https://github.com/solidjs/solid/issues/4182), the helper request by devagrawal09.
Targeted issue/PR searches found no duplicate or landed repair. This report does not
claim that the older cleanup-routing issues establish this subscription policy.
