# Progress checkpoints

The working translation is still an incremental port. These checkpoints measure
concrete additions and checked guarantees, not a percentage of the whole package.
The earlier baseline checkpoint is c446418; the earlier action/proof session started at e6a17b5; the current continuation started at c4f0bbf; the active source pin
is a2a5b6f8. The latest metadata-only commit preserves all 76 vendored Solid
files byte for byte. Nine earlier upstream commits were reviewed, including merged #4176
and #4188, after preserving the complete d682022c checkpoint at c11277e. The semantic deviation register remains empty.

| Area | Starting checkpoint | Current checked work |
| --- | --- | --- |
| Public flush callbacks | No callback overload | Inline/original admitted functions, nested drains, return values, ambient scope and finally/error precedence through the shared core |
| Custom comparators | Strict/default and equals:false | Named callback programs at setter, memo publication, async landing and held-seam sites, including NotReady and ordinary errors |
| General local guarantees | Existing publication/read/signal and representation laws | 48 added quantified flush/comparator/staging/allocation/cleanup/action/transaction properties |
| Nontrivial graph drain | Closed graph examples | Complete scalar-memo constructor and arbitrary finite nonempty write/flush history for every natural initial/proposed value, constructor budget >= 14 and each drain budget >= 40; 14-step constructor and two-step setter bridges checked; complete two-memo/render constructor/setter/95-step drain and exact final World/application trace for every natural proposal and sufficient drain budget |
| Typed actions | No public action engine | Reusable function identities, finite argument vectors without a fixed arity cap and nested parameter capture, plus typed invocation/resume, held writes, nesting/overlap, lexical capture, errors and return adoption |
| Public comparison corpus | 2,348 histories | 2,773 histories, plus separate native scheduling and finite memo-boundary controls |
| Closed semantic regressions | 56 | 68 positive regressions; two formerly preserved bugs now pass their merged fixes |
| Compiled mutation checks | 116 | 177; resource/infrastructure failures are excluded from useful rejections |

Implementation additions and semantic proofs are separate forms of progress.
Differential histories compare behavior with pinned Solid; mutation checks test
whether the oracles notice selected bad changes. They do not establish the
quantified theorems. Every positive formal claim requires the independent kernel.
[Verification](verification.md) records the trust boundary and counts;
[general properties](general-properties.md) states the theorem domains and gaps.

The remaining package work is substantial: arbitrary action closures/arguments/generator protocols,
active verdict/lane/boundary/mark/deferred engines, stores/array helpers, richer
closures/protocol objects and dev/observe behavior. [The action readiness review](reviews/action-readiness.md)
records the original dependency review; [the action milestone](actions.md) now
records 120 paired histories, 21 native-generator controls, eleven local properties and three closed laws. Production flush(fn) inside an action
invokes its callback without draining; the review explicitly preserves that arm. Arbitrary graph/effect/async-history correctness remains open.
The scalar-memo family now proves any finite nonempty sequence of updates for
every natural initial value and proposal, with constructor/drain budgets >=14/40. None of the test counts should be read as that fraction of Solid completed.


The latest proof checkpoint closes the previously explicit scalar-memo boundary:
its constructor and setter are now proved to reach the staged arena, rather than
being supported only by finite controls. Two new quantified public staging/drain
properties compose the real APIs. The runtime is unchanged by this proof work.

The constructor also has a separate theorem for all natural initial values and
budgets >= 14. Three quantified merge bookkeeping properties now check open sums,
redirects and action markers in both arena directions. These extend semantic
coverage without claiming arbitrary graph or active-engine completeness.

The c4f0bbf continuation closes the reusable action wrapper gap in the typed
profile and removes the scalar-memo complete proof's fixed-initial-value limit.
It adds 45 histories, four independent native-generator controls, eight selected
compiled-mutation rejections, six quantified local action/capture properties and
one closed repeated-call regression. The new two-parameter memo family proves
both the public staging boundary and the full constructor/setter/flush program;
64 additional finite native/canonical controls are separate supporting evidence.

The reviewed d682022c update adds twelve paired effect-equality histories and
keeps two native projection rejection controls explicitly source-only. Its full
signals suite passes 330 files / 5,432 tests. Active dev diagnostics and projection
families remain outside the Bend implementation; prior integrated fixes and the
two then-preserved bugs were revalidated at that historical pin. Both are fixed
at the current pin.

The preceding checkpoint established the two-memo/render conditional 95-step
drain, exact application trace and fixed constructor boundary for every natural
proposal and sufficient budget. Its public setter bridge was still open then.
Eight finite native/canonical controls supported it without proving it. Two general
publication composition laws and two additional rejected compiled variants were
added; the runtime did not change. See [the proof boundary](chain-proof.md).

The next continuation closes that larger graph's public setter bridge. A single
subscriber iteration is checked with symbolic remaining fuel and the actual
canonical arena, then the two iterations compose at the real setter's return
points. Four public properties now connect the fixed constructor, actual setter,
complete final World, values and exact render applications for every natural
proposal and drain budget >= 95. The runtime and original kernel are unchanged.
The earlier staged-arena condition remains only on the supporting drain lemma.

The argument-vector extension removes the callable ABI's two-argument cap while
keeping internal source pair calls and the existing callback/action engines.
It adds 70 paired histories, six independent native generators/factories, eight
quantified binding/order laws and two complete nine-argument executions. Eight
additional compiled variants are rejected separately. No source pin, trusted
kernel or semantic deviation changed. See [the call boundary](argument-vectors.md).

The owner entry now exposes the already translated constructor directly, keeping
the caller scope unchanged. Boolean self=false reaches the same teardown driver
for child-only clear/reuse; the source-bound createRoot disposer remains true.
Twenty-five new histories, four quantified frame/entry laws and a complete
lifecycle execution extend coverage. Four finite mutation assertions pass. The
runtime continues to preserve the source's production dead-parent behavior.

The 0222d684 source update integrates both user-submitted fixes #4176/#4188.
Original repros and controls distinguish old/new pins; both former negative laws
now state passing behavior. Two new quantified continuation properties preserve
the exact exceptional machine and captured node. Active verdict-mount fix #4207
is checked only in native Solid because those engines remain outside Bend.

[Two successive memo updates](memo-repeat-proof.md) now compose the real
constructor, both public setters and both drains for every natural initial value
and proposal pair, every constructor budget >=14 and independent drain budgets >=40. Three new public staging/final-World/view laws
close the second-update boundary. 512 finite native/canonical controls are
separate evidence; no runtime, source pin or deviation changed.

The next list-helper audit found a source-only successful-falsy-fallback remount
case, with 14 native controls and twelve real For/Repeat JSX browser cases. It
is tracked separately from implemented capabilities and formal proofs; no issue,
PR, source patch or active semantic deviation was introduced.

The next proof checkpoint removes that fixed two-update limit. Three new root
laws establish the repeatable public update, exact final World and committed
view for any finite nonempty list of scalar-memo writes/flushes. The proof
inducts on the list while keeping clocks, generations and accumulated trace/jobs.
Forty-nine finite public programs / 1,260 prefixes and 36 synthetic pass controls
support correspondence separately. Runtime, source pin, existing history/mutation
counts and the empty deviation register are unchanged. The user also submitted
source-only fallback fix PR #4211; it remains separate from the pinned baseline.

The coalescing extension removes the one-write-per-flush restriction too. Four
further quantified roots cover pending replacement, arbitrary batch staging,
complete public final World and committed view. Both batch sizes and history
length are arbitrary finite nonempty lists, from the actual constructor.
Thirty-five native/canonical programs compare 182 prefixes and 791 writes,
including equal and net-zero batches. The runtime, source pin and prior
history/mutation/closed-regression counts stay unchanged.

The final a2a5b6f8 repin catches up with the fetched next tip. Its one additional
commit changes only release/size metadata; all 76 vendored Solid files and the
runtime are unchanged. No proof/test count is credited for a metadata-only pin.
