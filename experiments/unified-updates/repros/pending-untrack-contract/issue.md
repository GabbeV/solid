I'm looking for clarification of the intended semantics here, rather than assuming this is a bug.

[Reproduction](https://s.olid.uk/id/crXRXWwCSyK3ac-Ub6ObEw), using the current `next` commit **45648f78**. Click **Run** once and wait 1.5 seconds.

An ID update is held by an async data memo. After 500 ms, another signal reruns three sample memos during that hold. Their async work finishes, then at 1500 ms the data request resolves and the update publishes.

Each sample reads `id()` normally and reads pending state under `untrack`. All three forms capture the ID read inside the `isPending` callback:

```ts
const direct = createMemo(() => {
  revision();
  const value = id();
  let inside;
  const sampled = untrack(() => isPending(() => (inside = id())));
  return `${value} / ${inside} / ${sampled}`;
});
```

The second form wraps the observation in a memo. It returns both the callback value and the boolean so the comparison can show which input produced the snapshot:

```ts
const pending = createMemo(() => {
  let inside;
  const sampled = isPending(() => (inside = id()));
  return { inside, sampled };
});
const wrapped = createMemo(() => {
  revision();
  const value = id();
  const { inside, sampled } = untrack(pending);
  return `${value} / ${inside} / ${sampled}`;
});
```

The third has the same reads as `direct`, but returns its captured result through `delay(500).then(() => result)` on updates. Those reads still all happen synchronously, before the promise.

After everything settles, the live ID and data are both **1**, and live pending is **false**, but the samples are:

| Reader | Ordinary ID | ID inside callback | Pending sample |
| --- | --- | --- | --- |
| Direct, synchronous memo | 1 | 1 | false |
| Memo-wrapped pending | 1 | 0 | true |
| Direct, async memo | 1 | 0 | false |

The memo-wrapped sample retains both the callback's old ID and its `true` result. The async sample retains the old ID but reports `false`.

The callback value matters beyond displaying it: in `isPending(() => id() === 0 ? first() : second())`, it selects which dependency is probed and can therefore affect the returned boolean. This is also a question about which values the callback should use, not just whether its enclosing memo reruns.

### Why I'm asking

The relevant history seems to pull in different directions:

- #3982, replacing #3946, fixed untracked observations causing a router anchor's enclosing computation to rerun on refetch. It says: **“An untracked `isPending`/`latest` inside a computation is a snapshot, as any untracked read is.”** It also describes a top-level untracked verdict read in a computation as unsupported, so clarification of that scope would help.
- #4648 reported the narrowed Show accessor/property-access problem. [The closing explanation on #4662](https://github.com/solidjs/solid/pull/4662#issuecomment-6610820065) rejected serving proposed values during an established hold, citing the ruling also used in #4663 that reads outside `latest` see committed values while held.
- #4667 replaced that approach. Its description explicitly makes a held reader's probe report `false` and replays synchronous readers at publication to refresh captured callback values, even through `untrack`. It explicitly skips replay for async memos to avoid asking the question again. That explains the implementation, but leaves me unsure of the intended public contract.

I understand why repeating an async request is undesirable. I also don't think an untracked snapshot retaining an earlier value is inherently a bug. What surprises me is that adding a memo wrapper or returning a promise changes which snapshots are refreshed.

Are these differences intentional exceptions to the snapshot rule? Should we preserve this special handling, or should untracked pending reads behave as ordinary snapshots, with tracked reads used when the result needs to stay current? Separately, what guarantee should apply to values captured inside the callback when its enclosing calculation eventually publishes?

The linked PR descriptions are AI-generated and report your rulings. Could you confirm whether these consequences were intended, or whether something got lost in translation between your rulings and the AI's implementation/tests? I'm not proposing to undo the first-value/property-access fix; I'm trying to separate that from the untracked replay semantics.
