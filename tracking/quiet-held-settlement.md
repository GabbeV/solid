# Quiet held intake through the actual landing scan

The settlement segment now constructs its own scanner task. On its admitted
initial state, one actual `Core.step` executes `SettleApplied` through positive
non-lane resolution, the captured pending intake, deferred-zombie handling,
trim-list clearing and the fused empty lane hook. A second actual step skips the
single live group with positive action debt. Caller work and the complete value
stack survive both steps. The group arena, live list and action records survive;
committed node values, rendered tree and application trace are unchanged.

This is a general operation contract, not yet a closed raw-constructor theorem.
`held-settle-scan.Ready` contains only initial facts:

- A healthy World, an actual positive terminal non-lane group, no custom
  comparator bindings and no deferred zombies.
- No live lanes, staged lane readers or entered lane readers at this boundary.
- A finite certificate naming each actual pending-list entry's node flags:
  already held or overridden, with no staged child frame. Consecutive indices
  and the exact terminal cursor are certified, starting at zero.

The two-step positive-group theorem additionally requires the initial live list
to contain exactly that group and its initial open count to be positive. It
quantifies over the World, group identity, arbitrary finite admitted intake,
remaining debt, task suffix and value stack. No post-settlement count, health,
live-list lookup, blocker answer, scanner task or resulting World is supplied.

`held-park-intake` proves that the actual `parkPendingNode` is unchanged for each
admitted entry. `held-park-loop` inducts over the certificate. Its cursor/height
equation derives the source's actual arena/intake traversal budget; there is no
extra loop-fuel assumption. `held-park-construction` provides empty and singleton
initial-intake factories from actual list/flag facts. The general loop is not
restricted to those two factories.

`settle-lane-empty` retains Solid's detached own queues, separately empty lane
queues and fresh landing queues. `held-settle-intake` composes real resolver,
parking, zombie and lane-hook operations. `held-settle-frame` proves their exact
footprint. `held-settle-scan` uses the initial positive count and retained arena
to derive the real unchanged blocker at the resulting scan World.

The remaining connection is substantial: execute the earlier queued Round,
including heap work and newly produced pending writes, and construct the above
initial certificate there. The current source/render graph can enqueue reader
work; empty heap or all-quiet pending intake must not be assumed after arbitrary
setters. Computed work with a staged child frame is outside this segment's
domain. Full restoration, next host delivery, observed-flight accounting and
publication across branching histories remain open.

Five composed roots extend the prior 778-root book. Compact independent verdicts
use the unchanged checker/fuel and explicit 4 GiB RSS / 90 s guards. The first
unsplit loop and large inline composition drafts reached that memory guard;
they receive no proof credit. Factoring single-entry/branch contracts permits
the same statements to check without increasing limits. The full book and exact
tracked inputs are recorded by the normal verification seal. The source/runtime
and checker are unchanged; this work introduces no deviation or upstream bug.

Three focused compiler-valid source faults are rejected using reduced checks
whose unchanged independent verdict passes first: reholding an ineligible node,
dropping the detached render queue and omitting the captured park intake. The
initial generic failure diagnostic exceeded the output guard and receives zero
rejection credit. Reducing the diagnostic projections required no larger guard.
These three checks are separate from the earlier frozen complete sweep; see the
[receipt](reviews/quiet-held-settlement-validation.json).
