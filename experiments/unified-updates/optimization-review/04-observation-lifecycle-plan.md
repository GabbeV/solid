# Plan 4: pending/latest observation lifecycles

Owner: observation-lifecycle agent. Report: `04-observation-lifecycle-report.md`.
Scratch: `/workspace/scratch/optimization-review/observation-lifecycle`.
Read the shared README first.

Map observation.ts dirty/watching sets, prepare/settle phases, and pending/latest
selectors and callback windows. Separate necessary semantic differences from
mechanical duplication. Explain why latest prepares on reads and why source-owned
observations need notifications beyond value changes.

Checkpoint with activation, repeated proposal, retirement and disposal timelines.
Investigate whether existing update notifications/queues could replace broad
watcher scans without additional persistent bookkeeping. Consider latest's
usually unchanged restoration, but do not drop publication coordination for its
own async consequences, errors, first values or hydration snapshots.

Identify the smallest change that deletes work, its counterexample, and a test
selection. Keep pending equality/quiet refresh/affects rules and nested callback
context intact unless a real semantic question is reported to the primary agent.
No runtime edits or broad API redesign at this stage.
