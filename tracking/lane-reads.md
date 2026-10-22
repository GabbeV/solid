# Lane reads, truth and provenance

This restricted dependency ports seven actual source functions at Solid
5b1b7776 (rc.17). It does not yet install the active lane read engine in public
programs or admit public latest/isPending scopes. No source pin or semantic
deviation changes.

## Operation correspondence

- lanes.ts laneRead follows txOf before authoritative/error/null-reader gates,
  direct lane values, untracked display, render-screen/held-reader branches,
  once-only rerun marking and enterLane before pending-token propagation.
  Core.laneRead* splits only at source branches and callback return points.
- lanes.ts stale uses a nonzero question and exact question ordering; answered
  walks live dependencies and selects only newer questions answered at this clock.
- truth.ts truth recursively checks live dependencies. A guess compares its lane
  slot with staging through the raw user comparator. Nonguess staging is not
  confirmed truth. truthRead retains actual comparator truthiness, raw throws,
  guess fallback and NotReadyError(null). truthConfirmed enqueues only
  authoritative subscribers in source member/subscriber order.
- verdict.ts heldNotFinal retains quiet-pending, latest/reask/uninitialized and
  staged-error gates, and compares committed against staging with the raw
  comparator when the source does.

Core.rawEquals is a representation continuation for direct _equals calls. It
has no isSame catch: falsey values, arbitrary truthy values and raw thrown
payloads stay observable. Depth-first truth recursion uses the shared callback
machine. Live link cursors are reread after callbacks. Finite traversal fuel
refusal is explicit; no cycle repair or general progress theorem is introduced.

The bijective binary question comparator runs by bit width without expanding
large question identifiers into unary naturals. Native controls include the
source counter boundary and MAX_SAFE_INTEGER. Five algebraic properties prove
reflexivity, swap/inverse, equality coherence, less irreflexivity and unstamped
staleness; these do not prove numerical-order interpretation for all naturals.

## Evidence and limits

2,618 native helper programs compare actual source functions with the Bend
helpers, including return/error/token, exact flags, queues, lane/group routing,
reruns and caller preservation. 720 separate question/provenance controls cover
ordering, staleness and answered-clock selection. 66 raw-comparator controls
exercise exact arguments, arbitrary return truthiness and raw thrown payloads.
These are private helper/branch controls, not added public histories. Source
function bodies remain unchanged; test-only exports/reset/metadata primers are
added in memory. Fixtures retain constructor time and valid held-reader owners.

Three further quantified properties check the actual uncaught custom-comparator
call frame, plain truth answer and pending lane-entry result with exact World and
caller continuation. Together with the question laws, eight new properties pass
the independent kernel. Fourteen additional compiled mutations target these
boundaries; the cumulative total is 296 (250 differential and 46 proof checks).
Public-history count remains 3,158 and closed regressions remain 72.

Folded optimistic-store callbacks, store slot nodes, public window entry/exit,
core read/write hook installation, lane application/reveal/correction/dissolution
and boundary mounts remain unfinished. Synthetic metadata branch probes do not
establish arbitrary well-formed public graphs. Recursive truth progress and
arbitrary callback-driven graph mutation are not proved. No upstream bug or
semantic workaround was needed for this layer.
