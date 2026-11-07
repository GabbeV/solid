# Committed-frame mounts and real DOM coverage

No runtime code changes. This pass applies the user's existing latitude to use
the model's natural mount behavior when all needed lower values have committed
frames. It does not remove the hold on a subtree created from an unpublished
ordinary parent, or make a missing first value available.

## Complete committed values can mount

```tsx
<>
  <i>{n()}</i>
  <Show when={latest(n) > 0}>
    <Loading fallback="pending"><p>{n()}</p></Loading>
  </Show>
</>
```

Start at n=0, then an action holds n=1. The explicit latest boundary opens the
branch. Its ordinary binding and the outside binding both show 0. On release,
both show 1. Next 4fe75321 instead shows `<i>0</i>pending` during the hold.
For the corresponding plain-write async hold without Loading, next retains
the Show fallback; the experiment mounts `selected: 0` beside ordinary 0.
Both are consistent publication choices. Retaining next's extra mount hold is
not required by the accepted natural-mount direction.

Migrate five scalar and three JSX expectations in #4166, #4203 and S-46 to
that existing behavior. Keep their exact complete intermediate and final
frames. Explicit latest inside the branch still sees the proposal. The
unread-pending-memo control still holds nothing. These are intentional semantic
migrations, not runtime fixes or claims that next tears in these programs.

Two new JSX controls establish limits:

- Another proposal, n=2, during the same open hold leaves both ordinary
  bindings at 0; ending the action publishes 2 in both.
- A branch with an independent async value that has never answered shows
  Loading. Resolving that value permits the complete `0:ready` frame beside
  outside 0. Ending the action then publishes `1:ready` beside outside 1.

Original next fixtures were run separately against pinned next: all four
pass with their original fallback expectations. The older S-46 comment about
an empty text slot is stale for this pinned runtime; the comparison here uses
the observed passing expectations, not that historical comment.

## Detached callback traces remain separate

Expand the existing #4341 JSX fixture to open Show/Match after an unrelated
gate update while the input is already held, in addition to its original
same-update opening. Use a controlled request gate, check that the old complete
DOM remains during the hold, then check the final DOM and absence of errors.
This adds 24 cases across branch forms, read order and memo/binding placement.
All 49 cases pass on both the experiment and pinned next.

The six failing scalar #4341 assertions record callbacks inside speculative
subtrees. The new DOM coverage does not settle their calculation/initialization
requirements. Those assertions, and the other held-frame callback-timing tests,
remain unchanged and open. No runtime guard or scheduled-effect substitution
was used to make them pass. The complete-committed-frame cases above are
distinct from those unpublished ordinary-parent cases.

## Validation

- Full signals: **5,344 passed, 2,075 failed, two skipped**; five migrated
  failures and no new failures.
- Fresh full web: **1,680 passed, 129 failed, one skipped**. All 55 focused
  mount cases pass. No failure absent from the previously recorded web
  inventory; three old mount failures are removed. This also exercises the
  accepted #4661 branch rule against the retained runtime.
- Signals inventory: 1,953 deferred API failures, 106 untriaged, twelve
  calculation expectations, four known implementation bugs. Web inventory:
  115 deferred API, eight untriaged, six calculation expectations.
- Rules index, targeted formatting and diff checks pass. Runtime files match
  stage 145, whose restored artifacts were used. No additional build required;
  no performance, bundle-size, Solid-package or hydration claim.

Receipts, original comparison fixtures and updated inventories are preserved
in `checkpoints/integration-stage146.tar.xz`. Temporary next configurations and
comparison files were removed from package directories. The broader scalar
audit and the error/latest preparation problem from stage 145 remain open.
