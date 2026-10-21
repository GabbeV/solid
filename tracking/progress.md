# Progress checkpoints

The working translation is still an incremental port. These checkpoints measure
concrete additions and checked guarantees, not a percentage of the whole package.
The earlier baseline checkpoint is c446418; this session started at e6a17b5; the active source pin
is still b0ad1df5. A read-only upstream check on 2026-10-21 confirmed next remains
at that exact commit. The semantic deviation register remains empty.

| Area | Starting checkpoint | Current checked work |
| --- | --- | --- |
| Public flush callbacks | No callback overload | Inline/original admitted functions, nested drains, return values, ambient scope and finally/error precedence through the shared core |
| Custom comparators | Strict/default and equals:false | Named callback programs at setter, memo publication, async landing and held-seam sites, including NotReady and ordinary errors |
| General local guarantees | Existing publication/read/signal and representation laws | 26 added quantified flush/comparator/staging/allocation/cleanup/action/transaction properties |
| Nontrivial graph drain | Closed graph examples | Complete fixed-initial scalar-memo constructor/setter/flush for every natural proposal and drain budget >= 40; 14-step constructor and two-step setter bridges checked |
| Typed actions | No public action engine | Production typed invocation/resume, held writes, nesting/overlap, lexical capture, errors and return adoption through the existing transaction driver |
| Public comparison corpus | 2,348 histories | 2,621 histories, plus separate native scheduling and finite memo-boundary controls |
| Closed semantic regressions | 56 | 64, including two deliberately preserved upstream bugs |
| Compiled mutation checks | 116 | 154; resource/infrastructure failures are excluded from useful rejections |

Implementation additions and semantic proofs are separate forms of progress.
Differential histories compare behavior with pinned Solid; mutation checks test
whether the oracles notice selected bad changes. They do not establish the
quantified theorems. Every positive formal claim requires the independent kernel.
[Verification](verification.md) records the trust boundary and counts;
[general properties](general-properties.md) states the theorem domains and gaps.

The remaining package work is substantial: full action function identities/arbitrary generator protocols,
active verdict/lane/boundary/mark/deferred engines, stores/array helpers, richer
closures/protocol objects and dev/observe behavior. [The action readiness review](reviews/action-readiness.md)
records the original dependency review; [the action milestone](actions.md) now
records 75 paired histories, seventeen native-generator controls and seven new laws. Production flush(fn) inside an action
invokes its callback without draining; the review explicitly preserves that arm. Arbitrary
graph/history correctness and the larger two-memo/render symbolic theorem remain
open. None of the test counts should be read as that fraction of Solid completed.


The latest proof checkpoint closes the previously explicit scalar-memo boundary:
its constructor and setter are now proved to reach the staged arena, rather than
being supported only by finite controls. Two new quantified public staging/drain
properties compose the real APIs. The runtime is unchanged by this proof work.

The constructor also has a separate theorem for all natural initial values and
budgets >= 14. Three quantified merge bookkeeping properties now check open sums,
redirects and action markers in both arena directions. These extend semantic
coverage without claiming arbitrary graph or active-engine completeness.
