# Array override lifetime and sparse For rows

Hosted next reproduction: https://s.olid.uk/id/a9de4318-fb5f-4555-8ace-19e539cc024d

Pinned runtime: mizulu/solid2@bcef1041. One button; B guesses index 1,
A guesses index 0 after 500 ms; each action waits 1000 ms. Initial array is
empty. Completion flags are set only after each action promise resolves.
The button is disabled directly in its event handler so an ordinary running
flag does not become held with the action and permit accidental duplicate runs.

Browser-verified rows: empty → undefined,2 → 1,2 → 1,2 (B finished,
A open) → empty. Length stays 2 until both finish. No page errors.
Ordinary signal/store sparse controls also render undefined,2, so the first
hole is normal sparse-array behavior, not evidence of a revert bug. Neither
next checkout produces a new undefined row when B finishes. This does not
establish erroneous length reset or loss of A's override.

Source-only controls cover initial [], [0], [0,0] with B first, A second,
B ending first, on bcef1041 and 4fe75321. Newer next publishes B's independent
ordinary write at B completion but retains its array entry in A's snapshot;
older next holds B's ordinary write too. The separate fixed-shape per-index
lifetime question remains pending with the user; these probes choose no new
implementation semantics.

Full executable source/DOM controls and hosted browser receipts are preserved
in ../../checkpoints/array-override-for-review-20261112.tar.xz, restoring
results/array-override-for-review/.
