# Unified updates

This experiment replaces separate optimistic lane machinery with shared
propagation, async holding, and publication for ordinary and optimistic updates.
Nested optimistic boundaries remain part of the model; “layer” describes those
boundaries, not the experiment's name.

The branch is `experiment/unified-updates`. Start with [the current scalar API
and status](SCALAR-API.md) and [the latest implementation and validation](INTEGRATION-171.md).
The [adversarial review](INTEGRATION-170.md) exposed an owned-frame calculation
defect. Stage 171 separates private calculation, publication holds and override
lifetime, and records the new validation and measurements against next.
The implementation runs through the normal Solid packages and test harnesses.
Experiment-specific scalar tests use the `unified-` filename prefix.

Numbered stage documents describe historical checkpoints, including rejected
approaches. Historical checkout paths and Git refs retain their original names.
The immutable [result archive](checkpoints/README.md) also retains the names
recorded when those measurements were made.
