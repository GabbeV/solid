# Publication audit and untracked pending samples

No runtime changes are retained. Stage 137 remains the runtime checkpoint.
No benchmark or size measurement was run: this pass follows the request to
establish test confidence first.

## Error recovery audit

The four original `error-staged-recovery` assertions remain unchanged. Two
reach the correct published error and final recovery but calculate an extra
unpublished `X01` before the final `Y11`. Two deliver the unchanged error
fallback to the render callback twice. The trace shows an unpublished recovery
being calculated, then replaced when latest prepares its separate output.
The duplicate callback is still an implementation issue, not an accepted
semantic change. The original #4396 commit describes retaining the displayed
error, which both shapes do; that does not justify dismissing extra work.

An early-preparation trial selected latest's proposal before reading its
output. It removed the duplicate fallback callbacks but also suppressed
previously working ahead publications. The broad unified run stalled and was
terminated; a bounded repeat also timed out. Forcing the output current did
not restore the expected ahead publications. Both trials were rejected and
the exact stage-137 source restored. These are not retained fixes.

The #4244 isolated boundary control passes, confirming stage 118's diagnosis:
the earlier unsupported catch of a reactive-read throw halts the graph and
contaminates the following tests. This was already known, not a newly fixed
error-recovery defect. The supported Error/Loading regressions still pass.

## Pending sample question

Twelve failures in the two #4648 probe files have a consequential distinction
beyond their first intermediate assertion. Diagnostic copies with soft
assertions ran the complete timelines; original tests were never softened.
The experiment can finish with a captured pending `true`, while next expects
`false`. A minimal scalar program and real JSX reproduce the difference:

```ts
const sample = createMemo(() => {
  revision();
  const value = id();
  return `${value}:${untrack(() => isPending(id))}`;
});
```

An async memo of id is independently rendered. Start at id 0, write id 1,
then change revision while the request remains pending, then resolve it.
The second calculation samples the already published pending=true while
calculating proposed id=1. The sample's publication waits for the request.

| Final output | Experiment | Next 4fe75321 |
| --- | --- | --- |
| Rendered id / data / live pending | 1 / 1 / false | 1 / 1 / false |
| Direct untracked pending sample | 1:true | 1:false |
| Callback untracked pending sample | 1:true | 1:false |
| Untracked memo of pending | 1:true | 1:true |
| Tracked pending, all three forms | 1:false | 1:false |

The memo form is `const pending = createMemo(() => isPending(id))`, followed
by `untrack(pending)`. Its result shows that preserving next's direct-call
behavior is not equivalent to preserving its ordinary memo behavior.
The experiment's recommendation is ordinary snapshot behavior for untrack,
and a tracked read for a live status. A ruling is pending: none of the twelve
original assertions has been changed or skipped, and no special tracking or
anticipatory false result was added.

## Retained validation

- Four scalar controls assert every frame for tracked direct/callback/memo
  reads and an untracked memo sample. All four pass on the experiment and next.
- Three JSX controls assert the full DOM sequence for tracked direct/memo
  reads and the untracked memo. All three pass on both runtimes. The direct
  untracked comparison remains an archived probe, not a settled contract test.
- All unified scalar tests: **586 passed, zero failed** (four added here).
- New JSX controls plus latest error publication: **31 passed, zero failed**.
- Rules index, targeted formatting and diff checks pass. No new build was
  necessary: runtime sources are unchanged and the stage-137 artifacts were
  used for JSX. No full signals, web or hydration suite was rerun.

The last full signals result remains stage 137's **5,232 passed, 2,111 failed,
two skipped**, before these four additional controls. No old failure has
been repaired or migrated in this checkpoint. Reclassification of that same
inventory now records 128 untriaged, 1,953 deferred API, four implementation
bugs, fourteen calculation expectations and twelve semantic questions.
The full web inventory remains 134 failures. These counts do not claim the
remaining implementation issues have all been found.

Scalar and JSX probe sources, next/experiment traces, rejected-trial receipts,
complete focused reports and the updated inventory are archived in
`checkpoints/integration-stage138.tar.xz`. Temporary test configs are included
there; none is left in package directories. Next runtime sources were unchanged.
