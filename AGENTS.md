# Unified update experiment

The working branch is `experiment/unified-updates` on the `GabbeV/solid` fork.

## Semantic acceptance requirement

The user's standing goal is strict, coherent observable update semantics.
Identify and report any case falling below that bar so it can be fixed, including
cases inherited from upstream. Existing implementation behavior, tests,
specifications, or earlier rulings are evidence to investigate, not permission to
introduce or retain inconsistency. Implementation details such as discarding an
unpublished write must not determine its observable coordination or lifetime.

Explicit observation boundaries such as latest and createDeferred retain only
their deliberately authorized scope; they do not excuse downstream tearing.
Do not weaken consistency assertions to make tests pass or silently broaden an
exception. Distinguish exploratory questions from semantic rulings.

Size and performance remain strict acceptance constraints. A pragmatic deviation
from coherent semantics may be considered only after exhausting consistent
alternatives, presenting concrete observable consequences and measured tradeoffs,
and obtaining an explicit, clear ruling from the user. Never infer that approval
from upstream compatibility, implementation convenience, or a performance target.

The user explicitly requests regular commits and pushes to protect this work
against loss of the cloud environment. Commit and push meaningful checkpoints,
including before risky trials or rebases. Do not leave multiple completed
stages uncommitted. Record known failing tests honestly in checkpoint notes;
a checkpoint is not a claim that the experiment is ready to merge.

The large generated experiment results are backed up in
`experiments/unified-updates/checkpoints/`; see its README for restoration.
Include new investigation receipts in subsequent checkpoints, using separate
per-stage archives for large results rather than replacing the historical one.

Keep unrelated local changes intact. This authorization covers commits and
pushes to the experiment branch, not opening PRs, posting comments, or merging.
