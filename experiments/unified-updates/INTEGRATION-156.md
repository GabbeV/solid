# Migrate held-branch observation calculations to the common context rule

No runtime change. Ten scalar and six JSX failures in #4544 asserted the old
probe-local posture rather than the whole-calculation rule accepted in stage
141. The original fourteen scalar tests all pass on pinned next `4fe75321`.
These are intentional experiment differences, not newly diagnosed next bugs.

## A branch being prepared

A session update opens a signed-in branch while a sibling request holds the
page. Its params also read a plan signal through isPending/latest. Preparation
must supply that new branch's incoming params; it cannot keep requesting
signed-out content and thereby prevent the signed-in frame from finishing.

The old assertions distinguish probe placement: wrapped pending produces
`{plan:false, signedIn:true}`, while inline pending produces signedIn=false.
The experiment prepares `{plan:true, signedIn:true}` in each form. It still
shows `0 signed out` throughout the hold, then `1 rows` when the gate releases.
Every existing screen assertion and final params assertion is retained.
The stage-130 ordinary profile/reviews JSX controls separately verify that an
async consequence of those params holds the complete incoming frame.

## A previously published reader

The other four scalar failures are intermediate **values**, not run counts:

```ts
const chrome = createMemo(() => (isPending(plan), plan()));
const params = createMemo(() => { chrome(); return x(); });
```

With committed x=1, start a held x=2 update, then change plan. The pending output
selects its own calculation context, so params computes committed x=1. After
release it computes x=2. Next's inherited probe posture instead leaves this
reader in the held x=2 update. The experiment's result is the same whether x
was observed through latest in the preceding update or not. Preserve that
history-independence assertion and add an exact final calculation assertion.

This is the already accepted distinction between preparing a new lower frame
and calculating the published observation's independent output. No global
entanglement or new override lifetime decision is introduced.

## Validation

- Migrated scalar file: **14 passed**, both from development source and the
  rebuilt, property-mangled production package.
- Migrated JSX file: **10 passed** against the built development package.
- Ten previous scalar failures and six previous web failures are closed;
  no publication or request-count assertion was weakened.
- No runtime edits or new full-suite run. Stage 155 remains the full-run
  baseline (5,497/2,033 signals, 1,691/127 web); accounting for this migration
  leaves 2,023 and 121 known failures respectively, including deferred APIs.

Original fixtures, pinned-next comparison, migrated reports and import config
are in `checkpoints/integration-stage156.tar.xz`.
