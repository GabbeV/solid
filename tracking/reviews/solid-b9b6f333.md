# Solid next b9b6f333 integration

The reference advances from 3cbfaf1a to b9b6f333, still declaring rc.17.
All 77 recorded Solid files match Git at the new commit. Only deferred.ts and
from.ts change in that snapshot. The complete upstream range additionally
changes web/compiler broadcast support and synchronous serialization failure
handling; those operations are outside the signals package profile. The impact
report was taken before copying source. Bend 2.0.37, Lean and dependencies remain
pinned. The historical baseline remains on local baseline/solid-3cbfaf1a at
6ed4732, including the ordinary-payload proof added before this refresh.

## Merged fixes and admitted runtime

#4231 adds `else land(flight)` after the open-NotReady catch arm. This is an else
of the complete condition, including closed-window throws. The Bend lifecycle
helper now takes that exact branch, then rethrows the original value. The core
catch boundary clears the translated active fault before executing the catch;
without this, land's continuation guards skip unmarking. This repairs a port
boundary omission, using the same caught-error posture as the other core catches.
There is no new scheduler, alternative algorithm or semantic deviation.

The previous Bend runtime against the new reference fails the existing public
history because its deferred mark is 1 instead of 0. Four former preserved-bug
histories now assert no leftover lag membership and immediate current-error
settlement. Thirty-two additional paired histories vary native/immediate old
promises, seeds, until/refresh, absent/unresolved/resolved/rejected old work, effect
error handling and later recovery. Current error identity is explicitly checked;
an obsolete flight cannot publish or postpone that answer.

#4232 tolerates a bare first result in the open-window stream wrapper; #4233
contains a teardown throw after synchronous subscribe completion. These changes
are copied verbatim into the reference and validated against the saved repros.
Their affected Bend runtime operations remain unfinished at this checkpoint;
no candidate patch is substituted for them. Source-built development, production
and observe repros all pass, 60 cases across the three bugs and tiers. The native
package builds all tiers, emits source declarations and passes 341 files /5,547
tests, with two expected failures and two skips.

## Proof changes and controls

The old closedFailure theorem's all-World/state/error domain remains. Its old
state-preserving conclusion is retired with the source branch: it now proves
exact landing followed by rethrow. Two new arbitrary-World properties prove
unmarked ordinary-error flight/membership removal and the retained open-NotReady
ask branch. A third property checks the actual core caught-error continuation
for arbitrary World, cell, cause, open flag, caller tasks and saved stack.

All complete-program proof domains and sufficient budgets remain unchanged,
including the generalized ordinary-payload deferred program at >=103. No
arbitrary async-graph theorem is claimed. The concrete composed-regression count
stays 73; the catch diagnostic is a scoped helper control, not a new composed
public program proof.

Three new compiled negative variants omit landing at the public crossing,
omit it in the lifecycle proof, or leave the caught fault active at the core
boundary. The first broad catch rejection produced an overlarge symbolic-World
diagnostic and earned no credit. A small Boolean projection now tests that same
compiled change, with the general positive theorem retained separately. An
initial incorrectly typed diagnostic fixture also earns no credit; the corrected
fixture must pass the independent kernel before its negative result is accepted.
Neither kernel limits nor budgets are raised.

The private openWindow observation used to stop by throwing from fn. That now
executes the newly changed catch, so its instrumentation stops immediately after
the original window prefix instead. The source prefix is unchanged; full catch
controls still execute the original catch. This keeps prefix and whole-function
evidence distinct. All 1,664 lifecycle/window and 120 serve controls pass.

The validation receipt records public/alignment/native/kernel results and the
focused negative run. A complete negative-corpus refresh will run from a fixed
checkout while subsequent implementation continues, and will receive its own
receipt. The preceding 521-variant evidence is historical, not a claim of a fresh
524-variant sweep at this checkpoint.
