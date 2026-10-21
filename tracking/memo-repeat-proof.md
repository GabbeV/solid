# Two successive scalar-memo updates

The regular roots now prove a fixed public program with two successive updates:

```text
const [value, setValue] = createSignal(initial, { equals: false });
const derived = createMemo(() => value() + 1, { equals: false });
setValue(first);  flush();
setValue(second); flush();
```

Three root properties quantify **every natural initial value and first/second proposal**, including
equal writes, and each drain budget `40 + extra` independently. The actual eager
constructor budget is independently `14 + constructorExtra`. They establish the second public
setter's complete staged World, the exact final World after both updates, and
committed values `second`/`second + 1` with empty pending intake and restored
context/tracking/running/scheduled/fault fields. The first update and constructor
are included; the caller supplies no canonical intermediate state.

`proof/memo-repeat-public.bend` composes the existing constructor/first-update
proof with a new second-setter bridge and forty actual second-drain transitions.
`memo-repeat-staging.bend` proves those transitions against core.step. The generated
canonical data retain the second pass's clocks, edge generations, old value,
accumulated trace and scheduling jobs; the second pass is not reset to a fresh
world. Both setters, commits and memo reevaluations use the unchanged runtime.

The independent kernel is the formal evidence. The witness/boundary generators
are untrusted and --check rejects stale data. 512 finite controls compare
actual Bend public programs, complete canonical Worlds and native pinned Solid
values, including equal/repeated proposals and large integers. They support
correspondence separately from the quantified proof; they are not 512 extra
formal theorems or new public-history credit.

## Checker boundary

Initial composition trials reached the unchanged kernel's fuel limit. They were
resource stops, not counterexamples or successful proof checks. Generic equality
cuts and spelling the public expressions directly in theorem statements avoid
normalizing a whole program merely to unfold a result wrapper. The initial-value lift also exposed a fuel stop while comparing fixed 256 with
14 + 242; retaining the already-proven symbolic constructor bound avoids that
normalization and strengthens the result. No checker cap, runtime budget, source
operation or trusted kernel changed. The completed proof
passes the original independent kernel and regular roots.

## Superseding history theorem

[The arbitrary finite history family](memo-history-proof.md) now removes the
two-update limit for this same fixed scalar graph using a repeatable pass and
list induction. These earlier two-update laws remain checked as supporting
milestones. The remaining scope below describes their original boundary.

## Remaining scope

This family has one memo and exactly two writes/flushes. The initial value and
both proposals are arbitrary natural numbers, with all constructor budgets >=14
and both drain budgets >=40. Arbitrary-length histories,
branching/effectful graphs, arbitrary graph topology and general progress remain
open. JavaScript numeric behavior outside the supported finite host range and
formal TS equivalence are not claimed. Source/toolchain pins and the empty
semantic deviation register are unchanged.
