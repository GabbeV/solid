# Stage 175 — confirm the remaining held-branch mismatch in JSX

No runtime change is retained in this checkpoint. Stage 174 remains the latest
runtime. This investigation confirms that the remaining #4010-shaped mismatch
is actual DOM tearing, rather than merely an unscheduled callback mutating a
test variable while its DOM is detached.

## Reproduction

```jsx
const [key, setKey] = createSignal("a");
const [count, setCount] = createSignal(0);
const data = createMemo(() => (key() === "a" ? 0 : answer.promise));

return (
  <>
    <b>{count()}</b>
    <Show when={key()} keyed>
      {captured => <span>{`${captured}:${key()}:${count()}:${isPending(data)}:${data()}`}</span>}
    </Show>
  </>
);
```

Set `key` to `"b"` and `count` to `1`, then flush. The experiment's `<b>` displays
`1` while the retained branch displays count `0`. The added regression compares
those two actual DOM bindings. It also checks captured/current key agreement and
the final values after a second count update and data resolution.

Unmodified next `4fe75321` passes the same test. Its timeline is:

| Point             | Outside count | Branch: captured key, direct key, count, pending, data |
| ----------------- | ------------: | ------------------------------------------------------ |
| Initial           |             0 | a, a, 0, false, 0                                      |
| key=b and count=1 |             0 | a, a, 0, true, 0                                       |
| count=2           |             0 | a, a, 0, true, 0                                       |
| answer=5          |             2 | b, b, 2, false, 5                                      |

The experiment fails the first post-write consistency assertion. No proposed
semantic change permits this disagreement.

## Investigation limits

A trial retained deferred parked-child work across a flush that had joined an
update. This tested the scheduler's legacy assumption that the whole flush's
writes are held together. It did not repair the failure and is reverted.

Traces show both the previously published binding and a newly created binding
running on committed inputs, followed by another proposed owner replacement.
The displayed child remains parked while the independent count publishes.
The dependency links still exist. The next investigation must explain how
publication/replay obligations are lost or misassigned across those replacements;
there is not yet sufficient evidence to retain another runtime patch.

## Validation and status

- New JSX regression: **fails in the experiment, passes on unmodified next**.
- Stage 174's full-suite totals remain the last full runs. With the new failing
  regression, the web inventory has 126 failures, including 11 non-deferred
  cases. This is another test of an already-known bug, not a newly introduced
  runtime regression. Signals retains 25 non-deferred failures.
- No full-suite or performance rerun is claimed for this investigation-only
  checkpoint. Production code and measured size are unchanged from stage 174.

The baseline's initial test attempts failed collection because the shared
jest-dom dependency resolved through an unusable `/@fs/` path. The final run
uses the experiment's explicit jest-dom bootstrap and a separate Vite cache,
with next's unchanged runtime and renderer. The final report has one executed,
passing test; earlier zero-test reports are harness failures, not behavior.
Temporary tests and config are removed from the baseline checkout.

`checkpoints/integration-stage175.tar.xz` preserves the failed scheduling trial,
diagnostic traces, experiment regression report, baseline config/bootstrap,
passing next report, and next's actual DOM timeline. All temporary runtime and
source-test logging/soft assertions are removed.
