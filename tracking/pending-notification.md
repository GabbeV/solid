# Source notification establishes carrier, status and error together

The prior carrier-cycle invariant described source Set membership. It did not
connect membership to a pending flag or NotReadyError. The new local notification
contract follows actual status.storeStatus (notifyStatus's local-node stores):
for an admitted carrier snapshot, a nonzero source and an incoming node without
STATUS_ERROR, pending notification constructs an allocated singleton carrier,
records the exact incoming NotReadyError identity/source, and selects Solid's
pending/uninitialized status bits. No final membership/status/error equation is
an input. Initially valid node identity is required for the status readback.

The existing reserved extension/Set facts are representation prerequisites.
Carrier-field frames show that the actual status and error writes retain the
source pointer, extension range and Set storage. The post-add singleton comes
from the existing checked actual add invariant. Pending status retains the
source's NO_VALUE versus UNINITIALIZED carry rule. Incoming shown errors remain
outside this first contract; their source branch is not changed or deleted.

The full committed-value array, tree and event trace are retained. The singleton
certificate remains usable after notification; this is more than a membership
check on an unrelated replay, but it stops before effect notification and
dependent propagation. It does not prove callback/controller reachability,
readiness of later plain reads, queued flush or eventual rendered reveal.

Six composed roots extend 564 to 570. The typed control starts with actual raw
default memo/render allocation/setup/link and explicit incoming-status setup;
Bend constructs all validity/arena/carrier evidence. It checks 120 cases with
varying IDs, auxiliary sizes, incoming status, error identity and arbitrary
represented cached values. Direct actual-helper Worlds agree, and paired native
leaf-memo notifications agree on status, exact error-object retention and source
membership. These private/native controls are separate from the public corpus.

Four deliberate source faults are rejected by compact independent kernel probes:
missing registration, dropped pending bit, lost error identity and lost NO_VALUE
carry. An initial large-probe mutation hit the unchanged process-group RSS limit;
it is recorded as a resource stop, not a rejection. The smaller probe addresses
the same mutation without changing source/runtime semantics or checker limits.
Current configuration is 657 = 484 finite /173 kernel; this is not a complete
657 sweep. Frozen633 remains historical evidence on its recorded checkpoint.

Runtime, source pin, host ABI, kernel/toolchain, old theorem domains and old
103/118-step programme bounds are unchanged. No semantic deviation or new
upstream bug. next@d786bcf6 was reviewed: its only change after the production
pin4ea2f498 is documentation/performance-experiments.md.
