# Store structure and initial-answer review — 2026-11-12

Follow-up: the user rejected the complete-array preservation recommendation below
because it implicitly vouches for unguessed properties. See
[STORE-COORDINATION-REVIEW.md](./STORE-COORDINATION-REVIEW.md) for the subsequent
entanglement exploration, pending diagnosis, and upstream #4810 comparison.
The original comparisons below remain historical evidence, not current approval.

The user rejected sparse array composition as an acceptable general result:
ordinary consumers of a dense typed array may not handle newly introduced holes.
This reopens array semantics. The previous green upstream-test checkpoint does
not establish acceptance under this ruling. Runtime implementation is unchanged
while the alternatives below are reviewed.

## Revisions and evidence

- Experiment: `8c35af093` (runtime remains the b69738dd2 checkpoint).
- Previous next baseline: `bcef1041cb50bf648da5641693b5ebdea1fc5dc2`.
- Current next: `dfb18120a407f7b505bfd7cde25c745d8d965932`, rechecked against the
  upstream branch after the comparisons.
- Also tested current next with open #4793, and with #4793 + #4802 + #4803 applied
  together. This is a local combined trial, not a published upstream revision.
- Source probes use explicit absolute aliases, controlled gates, and render-effect
  publication callbacks. Development and production flags were compared for
  the initial-answer case. Browser reproductions use a single embedded bundle
  of unmodified current-next sources with development flags, since that commit's
  usual playground CDN package was unavailable. The browser's actual import map
  was checked against the saved bundle URLs; both programs' DOM timelines pass.

## 1. Structural changes versus an active index override

```ts
const [input, setInput] = createSignal(["A"]);
const [rows, guess] = createOptimisticStore(() => input(), ["A"]);

// An action kept open by a gate:
guess(draft => { draft.push("M"); });
// Independent update while that action remains open:
setInput([]);
```

| After `setInput([])`, before the action ends | Published input | Published rows |
| --- | --- | --- |
| Previous next | `["A"]` | `["A", "M"]` |
| Current next | `["A"]` | `["A", "M"]` |
| Current next + #4793 | `["A"]` | `["A", "M"]` |
| Current next + #4793/#4802/#4803 | `["A"]` | `["A", "M"]` |
| Experiment | `[]` | `[hole, "M"]` |

All settle to `[]` when the action ends. Next holds the incoming update too; it
is not merely retaining an old list while publishing its new input. The experiment
publishes the independent input and keeps index 1, but no longer supplies index 0.
`for...of`/`Array.from`/For-like readers can encounter undefined. Native `.map`
skipping holes does not make the result a safe dense array.

[Current-next browser reproduction](https://s.olid.uk/id/13a5c949-d084-457c-8c35-5b7b45bce115).
One button: push immediately, independent input at 500 ms, action ends at 1500 ms.
It includes a normal For and ordinary input/list bindings.

### Alternatives to explore

1. **Coordinate conflicting structural input with the guesses.** Preserve a
   coherent old array and hold the incoming update, as next does in this example.
   This can also delay independent consequences of that input and requires a
   deliberate structural exception to the separate input/guess lifetime policy.
2. **Override a complete array version across a structural conflict.** Retain
   `["A", "M"]` at the output while allowing input `[]` to publish. This is
   already the behavior of a scalar `createOptimistic(input)` whose guess is
   `previous => [...previous, "M"]`, on both next and the experiment. It shows
   that the existing common boundary can express the desired publication without
   joining the lower update. Applying it to mutable stores still needs a policy
   for overlapping edits, retained rows, and expiration. It can hide otherwise
   independent incoming array changes while active.
3. **Rebase explicit operation intent.** Treat the edit as append M, producing
   `["M"]` over input `[]`. Arbitrary setter callbacks cannot safely be replayed:
   they may perform side effects, read other state, or capture references. A pure
   updater/operation representation or an explicit separate pending-item list is
   a more defensible route; automatic arbitrary-setter replay is not implemented.

The second is the candidate worth exploring with the split-boundary model. This
is not yet a complete store rule: an index-only guess can also meet a *later*
structural input change. Checking only whether the original setter changed
length/keys is insufficient. Structural conflicts must preserve a complete valid
array version, whether they originate in the setter or the incoming input.
Index-only edits with unchanged structure can remain granular; preserving that
independence while a whole-array override is active needs an explicit overlap
rule, not an assumption that copied guessed values can outlive their owners.

## 2. Nested setter before an incoming child's first answer

This reproduces on current next even with **ordinary createStore**:

```ts
const [inner] = createStore(() => first.promise, { x: 0 });
const [outer, setOuter] = createStore(() => ({ child: inner }), { child: { x: 0 } });
setOuter(draft => { draft.child.x = 9; });
```

The child reference read succeeds; the blind assignment throws NotReadyError
while internal cloning scans the unresolved foreign store. The view stays loading
and later displays the first answer 2. There is no optimistic action in this
smaller reproduction.

[#3274's recorded seed rule](https://github.com/solidjs/solid/issues/3274#issuecomment-6188894000)
says function setters run against the raw seed/base, and throwing would contradict
that rule. A25 retains the write-path exemption. The later #4656 narrowing excludes
initial *optimistic* writes; it does not explain this ordinary-store case. The
same-account comment is AI-marked, so the current normative A25 text and executable
ordinary control are included rather than treating authorship as proof of intent.

[Browser reproduction](https://s.olid.uk/id/6dfe2fc6-e78f-4c39-b13e-caa29592f82f).
A freestanding issue and prefilled form are in `repros/store-structure-review/`.
No issue has been submitted by the agent. No matching duplicate was found in the
searched issues. The original optimistic version remains additional context.

## 3. Object pending versus deep pending

The difference is narrower than a general identity-versus-content rule. The
confirmed case first resolves an async store, starts a second pending request,
then makes an **ambient** descendant guess outside an open action:

```ts
guess(draft => { draft.object.guessed = 99; });
isPending(() => store.object);
isPending(() => store.object.unguessed);
isPending(() => deep(store.object));
```

The published guessed value is 99 on all three revisions. Both next revisions
report `true / true / true` for these queries; the experiment reports
`false / true / true`. The guessed leaf's own pending query also remains true.
The object handle can be independently available while its contents await an
answer; deep is the broader query. This is not evidence that parent pending must
recursively include every descendant, nor that next violates consistency by
retaining a more conservative pending question.

With the leaf guess inside an open action, or with a whole-object/scalar guess,
all tested flags remain true on all three revisions. The active leaf guess keeps
the same proxy identity on all three. Thus proxy mutability supports the user's
interpretation, but does not by itself explain every active/retiring query rule.
No new ruling is inferred from this comparison. Exact published status frames,
initial-loading controls and source hashes are retained in the receipt archive.

## 4. Push against seed [] before first answer [A,B]

The setter executes once. There is no replay on any tested revision.

| Mode | Next after first answer while action stays open | Experiment |
| --- | --- | --- |
| Default initial loading, development | Setter rejected before callback; `[A,B]` | `[M,B]` |
| Default initial loading, production | `[M]` | `[M,B]` |
| `seedLoadingValue:true`, development or production | `[M]` | `[M,B]` |

With default loading, no list has published before the answer. With
`seedLoadingValue:true`, seed `[]` is explicitly published, and the push can show
`[M]` immediately. Every successful case eventually corrects to `[A,B]` when the
action ends. The development rejection is OPTIMISTIC_WRITE_BEFORE_LOAD; it is not
a production guard. Current S-56 says the store restriction remains because that
engine cannot yet show such a guess, while scalar optimistic memos are allowed.

Simply postponing the experiment's publication is insufficient: the callback
already wrote index 0 against seed [], and that index later replaces A while B
appears. Safe options include waiting for the first answer before permitting the
edit; using an explicit complete-array override (which hides incoming rows while
active); or keeping pending additions in a separate list and composing them with
the loaded input. The latter expresses append intent without replaying an arbitrary
setter. There is no need to add a deferred-setter queue or generic rebasing merely
to make this uncommon initial case work. Choosing development/production rejection
or suppression behavior for the experiment would still need a ruling.

## Relevant recent upstream changes

- Merged #4798 / #4788: consuming another action's guess now joins the action
  updates. Verified with the ordinary `saved` flag as well as values: A remains
  held while B, which read A's guess, is open. Literal independent B remains
  independent. This matches the experiment's existing setter-read ruling.
- Open #4793 / #4784 (`4024aaad9`): releases borrowed primitive indices when their
  lending guess ends; keyed rows carried verbatim remain protected. Its three
  regressions pass on current next plus the patch. It does not alter the single
  push/shrinking-input or first-answer timelines above.
- Merged #4797 / #4795: preserves a shown guess during correction and adds the
  while-loading development warning. It does not replay setter callbacks or
  replace the separate initial-load guard. The old/current timelines above agree.
- Open #4802 (`1113768ce`) and #4803 (`c0068c36e`): repair observation/lifetime of
  same-question refreshes and recognition of refresh through sources. Neither
  targets the structural examples here; the combined patch trial confirms those
  timelines stay the same. Their changes should not be treated as a new blanket
  rule entangling independent structural input with guesses.

The comparison includes next's other recently merged consistency changes too.
Only the behavior explicitly exercised here is claimed verified. The detailed
PR metadata, discussion excerpts, patch diffs, browser snapshots, production/dev
source traces and exact revision hashes are archived alongside this review.
