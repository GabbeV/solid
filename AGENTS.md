# Unified update experiment

The working branch is `experiment/unified-updates` on the `GabbeV/solid` fork.

The user explicitly requests regular commits and pushes to protect this work
against loss of the cloud environment. Commit and push meaningful checkpoints,
including before risky trials or rebases. Do not leave multiple completed
stages uncommitted. Record known failing tests honestly in checkpoint notes;
a checkpoint is not a claim that the experiment is ready to merge.

The large generated experiment results are backed up in
`experiments/layered-updates/checkpoints/`; see its README for restoration.
Include new investigation receipts in subsequent checkpoints, using separate
per-stage archives for large results rather than replacing the historical one.

Keep unrelated local changes intact. This authorization covers commits and
pushes to the experiment branch, not opening PRs, posting comments, or merging.
