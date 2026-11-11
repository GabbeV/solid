# Plan 1: creator retries versus private publication machinery

Owner: creator-publication agent. Report: `01-creator-publication-report.md`.
Scratch: `/workspace/scratch/optimization-review/creator-publication`.
Read the shared README first.

Map `prepareLayers`, `unpublishedFrame`, `frameRead`, `scopedCalculation`,
`retryCreator`, `readContext`, and `canPublish` in coordination.ts. Read stages
171/172/174/176 selectively to identify which pre-retry obligations still have
independent counterexamples. Identify duplicated decisions, not just similar names.

Form a concrete attempt -> acceptance -> publication state model. For each
candidate deletion, give the old responsibility and the new place guaranteeing
it. Distinguish a creator being rebuilt from a published creator whose old
children still serve another update. Preserve eager private construction.

Checkpoint with a small ownership timeline and your strongest deletion hypothesis.
Then inspect the counterexample to the earlier broad private-frame deletion.
Propose a narrow refactoring boundary and discriminating tests. Do not implement
or delete guards until the primary agent has reviewed the model.
