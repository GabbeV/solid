# Two successive scalar-memo updates

The regular roots now prove a fixed public program with two successive updates:

```text
const [value, setValue] = createSignal(0, { equals: false });
const derived = createMemo(() => value() + 1, { equals: false });
setValue(first);  flush();
setValue(second); flush();
```

Three root properties quantify **every natural first/second proposal**, including
equal writes, and each drain budget `40 + extra` independently. The actual eager
constructor uses the existing fixed budget 256. They establish the second public
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
are untrusted and --check rejects stale data. Sixty-four finite controls compare
actual Bend public programs, complete canonical Worlds and native pinned Solid
values, including equal/repeated proposals and large integers. They support
correspondence separately from the quantified proof; they are not 64 extra
formal theorems or new public-history credit.

## Checker boundary

Initial composition trials reached the unchanged kernel's fuel limit. They were
resource stops, not counterexamples or successful proof checks. Generic equality
cuts and spelling the public expressions directly in theorem statements avoid
normalizing a whole program merely to unfold a result wrapper. No checker cap,
runtime budget, source operation or trusted kernel changed. The completed proof
passes the original independent kernel and regular roots.

## Remaining scope

This family starts at zero, has one memo and exactly two writes/flushes. The
separate existing one-update theorem covers arbitrary natural initial values.
Arbitrary initial values for this two-update family, arbitrary-length histories,
branching/effectful graphs, arbitrary graph topology and general progress remain
open. JavaScript numeric behavior outside the supported finite host range and
formal TS equivalence are not claimed. Source/toolchain pins and the empty
semantic deviation register are unchanged.
