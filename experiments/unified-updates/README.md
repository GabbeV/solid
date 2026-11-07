# Unified updates

This experiment replaces separate optimistic lane machinery with shared
propagation, async holding, and publication for ordinary and optimistic updates.
Nested optimistic boundaries remain part of the model; “layer” describes those
boundaries, not the experiment's name.

The branch is `experiment/unified-updates`. Start with [the current scalar API
and status](SCALAR-API.md) and [the latest implementation and validation](INTEGRATION-174.md).
The [current investigation](INTEGRATION-175.md) confirms a remaining held-branch
DOM consistency defect against unmodified next.
The [adversarial review](INTEGRATION-170.md) exposed an owned-frame calculation
defect. Stage 172 begins retrying creators when their children discover a different
optimistic context. Stage 173 gives those retries the public `NotReadyError` category, with an
internal subtype to distinguish them from async waits. Stage 174 reviews the ownership failures and fixes preparation of children
whose owner is being replaced. There are 25 remaining non-deferred signals
failures; stage 171's private-frame mechanisms have not yet been fully replaced.
The implementation runs through the normal Solid packages and test harnesses.
Experiment-specific scalar tests use the `unified-` filename prefix.

Numbered stage documents describe historical checkpoints, including rejected
approaches. Historical checkout paths and Git refs retain their original names.
The immutable [result archive](checkpoints/README.md) also retains the names
recorded when those measurements were made.
