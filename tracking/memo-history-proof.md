# Arbitrary finite scalar-memo update histories

The regular roots now prove this fixed public program for every natural initial
value and every finite nonempty list of natural proposals:

```text
const [value, setValue] = createSignal(initial, { equals: false });
const derived = createMemo(() => value() + 1, { equals: false });
for (const proposal of proposals) {
  setValue(proposal);
  flush();
}
```

The actual constructor has budget `14 + constructorExtra`. Each flush has its
own independent budget `40 + extra`, including the first update. The public
statement supplies the first proposal and an arbitrary finite tail of
`Update{value, extra}` records, so there is no fixed bound on history length.
The constructor-only family separately covers the zero-write program.

Three new root laws check a repeatable public update, the complete final World
of the public program, and its committed view. The final source/memo values are
`lastProposal` and `lastProposal + 1`; pending intake is empty, ambient
context/tracking/running/scheduled/fault fields are restored. The exact World
law also retains every clock/epoch advance, dependency-generation update,
trace event and queued native flush job. This is a proof by list induction,
not a collection of longer closed examples.

## Composition and source correspondence

`proof/memo-history-states.bend` generalizes the already checked second-pass
shape. Its free `tick` is the number of completed updates after the first;
current clock, epoch, notified stamp and dependency generations retain their
source offsets. Existing trace and host-job prefixes are arbitrary lists. Each
pass appends its actual invocation/read events and its scheduled flush job.
The generic fields are not reset between iterations.

`memo-history-setter.bend` checks the actual public setter through its shared
write/heap/schedule helpers. `memo-history-staging.bend` checks all forty actual
core transitions and sufficient-budget completion. The final shape is the same
steady shape with the next value, successor tick and appended prefixes.
`memo-history-public.bend` composes the existing real constructor/first-update
proof, then inducts over the remaining actual setter/flush calls. The caller
supplies no canonical World to the complete public theorem.

The witness generator is untrusted. It extracts the actual second-update
snapshots and generalizes only the changing numeric fields and event/job
prefixes. `tools/memo-history-witness.mjs --check` rejects stale generated data;
every resulting transition/helper equation and the induction must pass the
original independent kernel. Generated output alone establishes nothing.
No runtime operation, upstream pin, semantic deviation, checker cap or trusted
kernel changed.

## Separate executable evidence

`tests/memo-history-controls.mjs` compares 49 actual public programs with lengths
from one through 128 writes, checking all 1,260 selected prefixes against the
complete canonical World and pinned native Solid values. It includes equal and
repeated proposals, large supported integers, and varied sufficient budgets.
Another 36 synthetic steady-state controls vary counters and existing
trace/job prefixes. These are finite correspondence controls, not additional
quantified proofs or paired-history credit. The existing 600 finite memo/graph
controls and 2,773 public comparison histories remain separate counts.

## Remaining limits

The theorem's topology stays one data signal and one eager scalar memo with
`equals:false`. It does not quantify arbitrary graphs, changing dependencies,
effects, errors, async inputs, active scopes or native scheduling. The later
batching extension below removes the original one-write-per-flush limit. It is a mathematical result over natural payloads;
JavaScript numbers outside the supported exact host range and formal TS/Bend
equivalence are not claimed. Whole-package progress and consistency remain
unfinished. This supersedes only the earlier two-update history-length limit.

## Arbitrary batches before each flush

Four further root properties now allow **any finite nonempty batch of writes
before each flush**, including the first batch after the actual constructor.
Both the batch sizes and the number of batches are arbitrary, as are all natural
payloads and the independent sufficient constructor/drain budgets.

`proof/memo-coalescing.bend` proves that a second public setter replaces only
the already-staged value: the source's notified-stamp/epoch gate suppresses
another subscriber notification and scheduled native flush job. Its small
natural-reflexivity lemma justifies that gate for symbolic counters.
`memo-first-coalescing.bend` checks the corresponding constructor/first-pass
shape. `memo-batches.bend` inducts over each batch's actual setters, then over
all actual setter/flush batches. The first proposal is explicit in each Batch
record, so no empty batch is silently treated as a changed pass.

The exact staged World retains the old committed values and the final pending
proposal. The exact completed World contains one memo evaluation and one queued
flush job per nonempty batch, rather than one per write. Intermediate proposals
are not read by that memo. Equal and net-zero batches retain equals:false
behavior; no equality suppression is invented. This adds no runtime operation,
API substitution, source patch or semantic deviation.

Thirty-five separate native/canonical programs compare 182 completed prefixes
and 791 individual writes. Every intermediate native read stays committed;
only a flush computes, once per batch. Whole canonical Worlds, exact invocation
counts and queued-job counts are checked separately from the quantified kernel
proof. These do not increase the 2,773 paired-history or 68 closed-regression
counts. The graph is still the same fixed scalar signal/memo pair with
equals:false: default-equality branches, empty flushes, errors/effects/async and
arbitrary graphs remain outside this family.
