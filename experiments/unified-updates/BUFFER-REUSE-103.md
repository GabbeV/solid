# Rejected cache experiment — stage 103

The user rejected cache-based reuse as the wrong direction. All runtime changes
and the cache-specific test changes have been removed. The active implementation
matches all 57 source hashes of stage 102; stage 102 remains the current checkpoint.

The trial reduced allocation by pooling cleared transaction-node arrays while
keeping update identities fresh. It did not remove membership rebuilding or the
coordination work, added size and retained spare capacity, and showed no consistent
runtime improvement. Those results do not justify continuing this approach.

The artifacts in `results/buffer-reuse-stage103/` are rejected experiments only.
In particular, its `retained/` directory is a historical trial label, not active
code. `rejected-source/` preserves the removed changes. No cache is retained.

Further work should examine whether the lifetime and membership representation
can avoid rebuilding work in the first place, while keeping proposals separate
from published state and preserving completed-update identity semantics.
