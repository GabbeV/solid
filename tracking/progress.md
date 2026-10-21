# Progress checkpoints

The working translation is still an incremental port. These checkpoints measure
concrete additions and checked guarantees, not a percentage of the whole package.
The starting checkpoint for this work session is c446418; the active source pin
is still b0ad1df5. A read-only upstream check on 2026-10-21 confirmed next remains
at that exact commit. The semantic deviation register remains empty.

| Area | Starting checkpoint | Current checked work |
| --- | --- | --- |
| Public flush callbacks | No callback overload | Inline/original admitted functions, nested drains, return values, ambient scope and finally/error precedence through the shared core |
| Custom comparators | Strict/default and equals:false | Named callback programs at setter, memo publication, async landing and held-seam sites, including NotReady and ordinary errors |
| General local guarantees | Existing publication/read/signal and representation laws | 18 added quantified flush/comparator/staging/allocation/cleanup properties |
| Nontrivial graph drain | Closed graph examples | A quantified conditional scalar-memo drain for every natural proposal and budget >= 40; constructor/setter bridge still unproved |
| Public comparison corpus | 2,348 histories | 2,546 histories, plus separate native scheduling and finite memo-boundary controls |
| Closed semantic regressions | 56 | 62, including two deliberately preserved upstream bugs |
| Compiled mutation checks | 116 | 139; resource/infrastructure failures are excluded from useful rejections |

Implementation additions and semantic proofs are separate forms of progress.
Differential histories compare behavior with pinned Solid; mutation checks test
whether the oracles notice selected bad changes. They do not establish the
quantified theorems. Every positive formal claim requires the independent kernel.
[Verification](verification.md) records the trust boundary and counts;
[general properties](general-properties.md) states the theorem domains and gaps.

The remaining package work is substantial: actions and their generator ABI,
active verdict/lane/boundary/mark/deferred engines, stores/array helpers, richer
closures/protocol objects and dev/observe behavior. [The action readiness review](reviews/action-readiness.md)
records concrete source ordering and dependencies for the next engine, backed
by four source-only public controls. Production flush(fn) inside an action
invokes its callback without draining; the review explicitly preserves that arm. Arbitrary
graph/history correctness and the larger two-memo/render symbolic theorem remain
open. None of the test counts should be read as that fraction of Solid completed.
