# Keep error callbacks tied to changed publication

A user effect reading an errored source beside isPending can re-run during a
retry. It still selects the previously published error, so its error callback
must not run again merely because that old answer was selected again.

The existing `_shownError` already identifies that answer. Error commit used
to clear it before notifying the effect, losing the distinction. Preserve it
through error notification, then clear it. The user-effect notifier restores
status normally but queues its error arm only when the selected error differs
from the shown error. Successful commits keep their existing cleanup order.
There is no new node field, retained history, cache, or additional subscription.

This repairs the existing derived-store duplicate-error test without changing
its assertions. Six scalar/ordinary-store controls check direct async memos,
async memo wrappers and async stores, each with and without a pending probe.
They require one callback for each new error, none for retaining the old error
through a retry, successful recovery, and delivery when the same user Error
object is thrown again after that recovery. Before the change three controls
fail; after it all six pass. Pinned next 4fe75321 passes all six.

The full signals run passes **5,480 cases**, fails **2,046**, and skips two.
It has **no collection failures**. Compared with stage 150 this adds the 72
restored Loading cases, six new controls, and repairs one existing failure;
there are no new failures. The four separate error-staged-recovery failures
remain: two extra calculation traces and two repeated fallback callbacks. This
change does not claim to repair those different mechanisms.

Two additional Loading controls supersede a queued error before reveal and
require only the replacement error to be delivered. All eight new controls
pass against the candidate and pinned next. The full signals run above
predates those two controls; they also pass separately and in production.

The normal rebuilt web suite remains **1,691 passed / 127 failed / 1 skipped**,
with no new failures. The production scalar/ordinary-store control set passes
**679 tests**. Build, property mangling, purity, types, rule-index and whitespace
checks pass. This is a correctness checkpoint, not a new performance result.
