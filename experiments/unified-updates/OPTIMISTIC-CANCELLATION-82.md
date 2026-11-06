# The same cancellation mechanism across optimistic primitives

Investigation only; production core remains stage 79. Five controlled timelines
were executed against that build and pinned next
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

## Explicit status-like guess before an async producer

```js
const [busy, guessBusy] = createOptimistic(() => false);
const data = createMemo(() => {
  const key = id();
  return busy() ? "waiting" : load(key);
});
const change = action(function* () {
  setId(1);
  guessBusy(true);
  yield actionEnd;
});
```

After a settled initial 0, both next and candidate start load(1), cancel it when
the guessed flag propagates, then start load(1) again as the override retires.
This does not require automatic pending feedback. A shared memo is downstream
of both an ordinary proposal and the guessed flag and replaces its single active
calculation when the flag takes over.

The automatic isPending case has the additional feedback relationship: replacing
the work can remove the reason its own input was pending, causing the status
proposal to retire and the work to restart. An explicit guess's lifetime is
instead tied to the action; in this timeline it remains selected until the
action ends.

## Override the producer's output instead

```js
const [view, guessView] = createOptimistic(() => load(id()));
const change = action(function* () {
  setId(1);
  guessView("waiting");
  yield actionEnd;
});
```

Both runtimes start load(1) once. It survives the output override and supplies
the eventual answer. Candidate separates the input producer and selected output;
overriding the output does not notify the producer to rerun. Consumers of that
output can still be superseded. The same relative distinction matters at each
boundary in a nested graph; this audit does not claim exhaustive nested coverage.

## Guess a request key

```js
const [key, guessKey] = createOptimistic(id);
const details = createMemo(() => load(key()));
// Guess key 1, then receive actual key 2 when the action ends.
```

Both runtimes start load(1), then load(2). Here the async question actually changes.
Candidate calls the first flight's cleanup before its answer; pinned next does
not call that cleanup until after the answer in this timeline. The cleanup
record must not be confused with flight-result validity: these audits record
request starts, onCleanup timing, and visible answers, not every internal flight
slot of next. Neither runtime publishes the late key-1 answer as the final result.

## Additional candidate bug: latest repeats an unchanged question

```js
const details = createMemo(() => load(latest(id)));
// Ordinary setId(1), with no action or explicit guess.
```

Pinned next starts load(1) once. Candidate starts it, calls cleanup, and starts
load(1) again during the same update. This occurs with latest as the actual key,
not only an incidental unused latest read. The latter was tested too and also
repeats in candidate; pinned next starts once.

This is classified as an **implementation bug in the candidate**, not misuse of
latest or an approved semantic difference. A correct shared mechanism must avoid
that redundant start. No fix has been applied here, and no precise internal
root cause beyond context/propagation replacement has been established by this
public audit. It is a reason to inspect the common mechanism before treating
all cancellation as an application error specific to isPending.

## Consequence for the pending discussion

Intentional async consequences of an optimistic output can legitimately be
superseded, including a delayed indicator derived from pending. An effect that
writes a signal is not an accepted general replacement for that derivation (user
correction to stage 81). A deferred primitive may eventually express independent
timing, but remains unimplemented in this checkout.

The useful distinction is the location and purpose of the async work: a
boundary's input producer, a consumer computing for a different selected value,
or work restarted because of an incidental observation/context change. Same-update
membership alone does not establish which case applies. No warning/error policy
or new bookkeeping has been installed.

## Evidence

- Public audit: `optimistic-cancellation-shapes.mjs`.
- Results: `results/optimistic-cancellation-stage82/{baseline,candidate}.json`.
- Source regression file:
  `packages/signals/tests/unified-optimistic-cancellation.test.ts`.
- Source check: two ordinary passing cases and **one explicitly expected
  failure** for latest's duplicate request. This is not three working cases.
- Request gates allow stale answers to arrive; cleanup only records cancellation
  intent, and no request cache hides duplicate starts.
- No runtime changes or new performance/size measurements.
