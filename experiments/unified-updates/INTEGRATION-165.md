# Pending calculations after their input update publishes

Fix the grouping bug identified in stage 164. An initialized async calculation
can remain pending after its update publishes because its ordinary observer
moved into an optimistic context. The higher reader must still use the lower
calculation's published value. Losing the transaction record must not make that
same flight become the higher reader's own work.

Previously, the existing binding calculated 104 but its callback was suspended
again on that unheld flight. The result memo published 104 while the binding
still displayed 103. A newly mounted ordinary binding then displayed 104 beside
103. This violated consistency; the four original grouping assertions remain
unchanged and now pass.

Use the existing context read hook on unheld pending inputs. An uninitialized
input still suspends. A higher reader sees the published value only if the
source's context is lower. Existing context discovery supplies that comparison;
no flight history, cache, node field, or new hook is introduced. Settled
synchronous reads do not enter this new pending path. No measured performance
claim is made.

A first trial assumed every unheld flight was ordinary. It passed the grouping
cases but failed the existing three-optimistic-node checkout: shipping can also
remain pending after its optimistic input publishes. A peer tax update must
still wait for shipping when calculating the total. Comparing the source's
existing context repairs that regression. It is retained as a required control,
not reclassified or relaxed.

Earlier trials that prepared direct bindings before publication or retained an
extra adoption obligation did not repair the bug. Preparing all direct bindings
also failed to converge in the focused run. None of those changes is retained.

## Observable checks

Two JSX tests use normal Loading and Show, with and without pending in the same
binding. Controlled requests exercise each publication. The existing binding
must agree with the memo's committed accessor, pending must agree with its
published boolean, and a late-mounted binding must agree with the existing one.
Both also pass on pinned next `4fe75321`. No special effect API or manual DOM
publication is needed to reproduce the defect.

The original four held-frame grouping cases cover ordinary completion, equal
answers, refresh after completion and refresh while work is suspended. All now
pass without changing their expected visible sequences. Separate-observer
variants and the six stage-164 refresh controls continue to pass.

## Validation

- Full signals: **5,586 passed / 1,979 failed / two skipped**. Four old failures
  fixed, no new failures. **1,953 deferred API cases and 26 non-deferred cases**
  remain.
- Built, mangled production public set: **514 passed**, including the existing
  checkout suite; no failures.
- Full web: **1,703 passed / 119 failed / one skipped**. The two new JSX
  controls pass; the old failure set is unchanged. Both new controls also pass
  on next.
- Build tiers, property mangling, purity checks, declarations, rules index and
  diff checks pass. No bundle-size or performance measurement in this pass.

The scalar audit remains incomplete. Remaining failures concern first held
values/ordinary derived stores, first callbacks in unpublished owned frames,
extra subtree construction and repeated render computations. Receipts, rejected
trials and the complete inventory: `checkpoints/integration-stage165.tar.xz`.
