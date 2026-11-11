# Plan 2: ordinary scheduler cost and optional coordination interface

Owner: ordinary-scheduler agent. Report: `02-ordinary-scheduler-report.md`.
Scratch: `/workspace/scratch/optimization-review/ordinary-scheduler`.
Read the shared README first.

Use stage 182 module attribution and the diff against next 4fe75321 to explain
the ordinary-only scheduler growth (~953 minified bytes), and distinguish it
from code retained only when optimism/observations are imported. Inspect the
calculation, read, ownership, merge, readiness, ordering and commit hooks.

Map which hooks disappear in ordinary-only bundles, which remain when imported
but inactive, and which are active during ordinary async holds. Find candidates
for fewer decisions/dispatches or colder placement that do not pull optional
machinery into ordinary bundles. Identify disabled legacy scaffolding, but give
it zero shipped savings when the build already removes it.

Checkpoint with an attributed shortlist and one ordinary write execution path.
Then recommend a minimal interface change or algorithm simplification with both
size and performance rationale. Do not replace direct hooks with a generic
callback registry merely to shorten source. Do not run benchmarks or rebuild
shared artifacts without primary-agent direction.
