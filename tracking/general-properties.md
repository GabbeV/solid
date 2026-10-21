# General semantic properties

These are quantified properties of the actual Bend runtime, separately from the
62 concrete end-to-end regressions and separately from TS/Bend correspondence.
No source operation or runtime representation changed to make these proofs pass.

## Publication at any existing slot

[publication.bend](../proof/publication.bend) quantifies over every World, every
finite arena prefix/suffix, every node and every admitted Value. The target index
is the prefix length, so it exists by construction; no unchecked index or graph
invariant is assumed.

- commitValue publishes the exact pending value and clears its pending slot.
- All other node fields, all surrounding nodes and all other World fields remain
  identical. This includes dependencies, queues, owner links, callbacks and IO.
- An empty pending slot makes commitValue exact identity.
- Repeating commitValue is idempotent, for either pending-slot shape.

The proof uses general list get/set lenses in [arena.bend](../proof/arena.bend).
Its loaded/clear expressions are proof-only algebraic forms of the two actual
stores; loadedEq checks them against scheduler.commitValue. They are not another
scheduler or an assumed reference algorithm. This does not prove computed-node
commit, effect execution, or completion of the whole transaction machinery.

## Read policy

[read-policy.bend](../proof/read-policy.bend) quantifies over Worlds, node arenas,
target IDs, caller task continuations, stacks and payloads:

- The plain-signal fast-read helper, with a normal zero sentinel and no owner,
  serves the committed value, records its read event and preserves tasks/stack.
- enterRead with no reactive reader leaves the World unchanged and joins no hold.
- At serveSelected after status/unflushed selection, no reader selects the
  committed value when no unflushed value was supplied.
- A supplied unflushed value takes precedence and marks the late linker.

These are properties at the named source helper return points. They do not say
every read reaches those points: eligibility, missing/error status, pulling and
active scope policies still matter at the callers.

## Complete numeric data-signal program

[signal-staging.bend](../proof/signal-staging.bend) proves a whole program for all
numeric initial and next values, with equals:false:

1. Construct the normal root and a data signal using the actual API.
2. Set its next value. A public read before flush returns the initial value.
3. Flush. A public read returns the next value.
4. The flush completes in 19 core steps. For every additional fuel allowance,
   the same final state has an empty pending/render/user queue, cleared pending
   slot, restored context/tracking/stale/running state and a healthy fault slot.

The ordinary host-job queue is not claimed empty: a manual flush leaves the
already-requested external flush job for the host to consume.

[signal-driver.bend](../proof/signal-driver.bend) supplies actual API inputs and
core.step. [The generator](../tools/signal-witness.mjs) records canonical states
from one emitted execution, replaces the two payloads with variables, and emits
19 step equations plus a finite Path. Every equation is checked by the independent
kernel for all numeric inputs; the generator and its sampled execution are not
trusted to establish the result. Existing generic Path.realizes composes those
steps, and checked equality transports connect them to the original API program.
Regeneration is deterministic and tools/check verifies the artifact is current.

This is a general payload/progress result for one fixed graph and comparator
setting, not arbitrary graph/history correctness or TS equivalence. Directly
unfolding even this symbolic flush exceeded the pinned kernel's reduction fuel;
canonical transitions and small equality transports avoid that expansion without
changing the runtime, raising the kernel budget or adding an axiom. The larger
arbitrary-payload memo-chain proof is still a separate unfinished step. A scratch
95-transition chain witness passed its individual symbolic steps and typed Path,
but the setter-to-staged bridge and composed flush proof exceeded the available
16 GiB memory. That experiment is outside the active proof roots and is not
counted as a completed semantic theorem.

## Flush callback scope and finally

[flush-callbacks.bend](../proof/flush-callbacks.bend) adds three quantified local
properties: entry changes only syncDepth and installs the body/finally tasks;
restoration keeps the drain's World while restoring the immediately enclosing
depth and saved operands; and a callback throw still enters the public drain
with its original error retained in a finally task. They quantify over arbitrary
Worlds, continuations, operands, callback syntax and fault/value inputs as stated.
Two separate closed executions check nested return/commit order and error
precedence. These do not prove arbitrary callback completion or a global drain
progress bound. [The source review](flush-callbacks.md) records the action/dev
exclusions and original-function read-observation boundary.

## Sensitivity and limits

Two additional compiled source variants are rejected by the quantified kernel
properties themselves: losing the new value during publication, and serving a
staged value from an unowned fast read. The other 122 mutation variants remain
differential/observation checks. These evidence families are not conflated.

General structural validity of all graphs, arbitrary callback/async/lane scopes,
full progress bounds for variable graphs and arbitrary-length histories remain
open. Numeric theorem parameters are Bend terms; this is not a new claim about
unbounded JavaScript integer execution or the compiler's correctness.

## Comparator call and catch properties

[comparators.bend](../proof/comparators.bend) proves five quantified local
properties over arbitrary Worlds, caller continuations, operand stacks and
relevant values: default selection retains the old fast helper; custom selection
calls the original identity with exact old/new arguments; NotReady returns raw
undefined and clears the control throw; ordinary errors route through the node
status notifier and return true, retaining any notifier failure; registering
metadata preserves the entire remaining World. Explicit lookup/classification
premises select the source arm. Four additional closed public executions cover
suppression, changed publication, ordinary errors and pending reads. These are
local semantic guarantees and fixed-program regressions, not general comparator
termination or graph correctness.

## Staging a changed memo

[publication-stage.bend](../proof/publication-stage.bend) adds three quantified
properties at recompute's actual publishValueChanged helper, complementing the
commitValue properties. After a successful equality gate, an existing non-effect
stages its proposal and then conditionally calls the actual subscriber notifier;
it does not use the direct creation/effect arm. The isolated pending-slot store
preserves every other World/node field at any existing arena position. For a
memo with no subscribers, the complete helper therefore updates exactly that
pending slot, preserving the old committed value and the entire remaining World.

Worlds, arena prefixes/suffixes, payloads, old heights and joined flags are
quantified. memoShape explicitly fixes Memo kind and a null subscriber head;
it does not claim arbitrary well-formedness. The changed flag is the caller's
successful gate, and create is false: this is not a proof of comparator policy,
all recompute paths, notification correctness or eventual commit. The proof-only
loaded form names the original effect/subscriber locals and is checked against
the actual runtime helper. No runtime operation was changed to obtain this proof.
A compiled mutation that overwrites the committed value instead of staging is
rejected by the quantified kernel checks.

## Lazy extension allocation

[extension-laws.bend](../proof/extension-laws.bend) proves four properties of the
actual ext helper for every existing node position and surrounding arena:
an already nonzero extension ID leaves the entire World exactly unchanged;
a first allocation appends exactly one blank extension and changes exactly the
node's x field; the new pointer retrieves the exact default record; and repeated
allocation is idempotent. Worlds, node fields and extension lists are quantified.
Idempotence requires a nonempty extension list, the runtime's sentinel-storage
invariant. Without that premise, an empty arena would allocate index zero, which
still means absent; no theorem silently assumes arbitrary records are valid.
Existing nonzero IDs are not asserted valid merely because ext returns early.

## Reactive cleanup capture

[cleanup-laws.bend](../proof/cleanup-laws.bend) proves three local properties of
the actual normal-frame runDisposal/dispatch return points. Every admitted list
representation (none, one callback, an array) is detached from its owner before
any invocation, with the exact captured callback tasks followed by EffectCleanup.
A detached list is not replayed, and the loop selects the last registered callback
before the preceding prefix. World/node fields, callback IDs, arrays, caller tasks
and the self flag are quantified; unrelated World fields remain unchanged.

These are reactive onCleanup list properties, not an error-policy ruling or a
claim that teardown continues after a throw. They do not say an effect-returned
cleanup cannot still run, that reentrant registration is discarded, or that a
zombie-frame disposal uses the normal field. The module-global collector leak
remains preserved at its source prelude. Existing public teardown/reentry/error
histories remain the behavioral evidence for interactions outside these helpers.

All seven properties use proof-only loaded locals checked against actual source
helpers; no runtime refactor or alternative evaluator was introduced. Three more
compiled mutations are rejected by proof-property assertions (the checker may
reject a corrupted theorem before reaching the independent kernel). Positive
proof claims always require the independent verdict.
