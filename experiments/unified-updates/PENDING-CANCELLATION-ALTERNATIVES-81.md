# Pending cancellation: useful cases and alternatives

**User correction:** an effect that writes a signal is not an acceptable general
replacement for a derivation. The recommendation of that workaround below is
withdrawn. Its measurements remain useful evidence of different coordination,
but do not disqualify the declarative delayed-indicator example. No acceptable
existing declarative alternative to that example has been demonstrated here.

No runtime changes. User clarified that replacing an async computation with a
synchronous result is not sufficient justification for cancellation: it can
repeat the same expensive request. This stage checks actual request starts,
cleanup, and alternatives rather than only visible values.

## Secondary-request counterexample withdrawn as a semantic justification

The stage-80 inline example can be expressed with separate request and display
computations:

```js
const primary = createMemo(() => loadPrimary(id()));
const secondary = createMemo(() => loadSecondary(id()));
const display = createMemo(() => isPending(id) ? "waiting" : secondary());
```

With an initially synchronous seed and controlled later request gates:

| Runtime | Inline request inside pending branch | Separate request/display |
| --- | --- | --- |
| Pinned next | One secondary request, starts after primary answers | One secondary request, starts alongside primary |
| Candidate | Two identical secondary requests; first cancelled before primary answers | One secondary request, starts alongside primary |

Candidate inline and split versions have identical recorded per-binding
publications under this timeline. The baseline versions have matching checkpoint
values but different callback order. Neither comparison asserts sibling order.
There is no network deduplication or shared request cache in this experiment.

If the goal is displaying a waiting state while requests run concurrently, the
split version is a straightforward better expression. If the goal is starting
secondary work only after primary completes, splitting alone does not preserve
that scheduling policy: express the dependency on primary explicitly, or use an
explicit work scheduler. That is a separate goal from a presentation fallback.

The prior claim that next supports the same cancellation was too strong. Stage
80 established matching displayed states, not matching starts/cancellation. Its
candidate metadata is still accurate, but that is not evidence the cancellation
is worth preserving.

## Strongest tested cancellation case: delayed spinner disappearance

```js
const spinner = createMemo(previous => {
  if (isPending(data)) return true;
  return previous ? delay(false, 300) : false;
});
```

The indicator becomes true when loading starts. After the answer, its false
proposal waits for a hide timer. Another request arriving during that delay
should cancel the hide, so an old timer cannot hide a busy indicator.

Both pinned next and candidate do cancel the old timer and start exactly one
network request per new id. A source-level audit verifies that, in the candidate,
the pending notification reaches a timer flight owned by the same update as its
input. Thus the broad diagnostic criterion can catch this intentional timer
cancellation too.

An effect-managed timer was also tested. This was initially presented as a good
alternative, which the user rejected: it introduces manual state and lifecycle
management in place of a derivation. Retained here as a measured comparison, not
as a recommended solution:

```js
const [spinner, setSpinner] = createSignal(false);
createEffect(() => isPending(data), pending => {
  if (pending) {
    setSpinner(true);
    return;
  }
  const timer = setTimeout(() => setSpinner(false), 300);
  return () => clearTimeout(timer);
});
```

The executable effect variant skips the irrelevant initial false-to-false timer.
It uses controlled timer gates with cancellation to test stale callbacks.

Both variants preserve the intended spinner sequence. The effect alternative
also lets data publish promptly in both runtimes. With the async memo, candidate
keeps data at 0 through the first answer and second request, then publishes 20
only after the final hide timer. Pinned next publishes the answers earlier but
keeps raw `isPending(data)` true through the hide delay. The effect variant
publishes 10 and then 20 as their requests answer and reports raw pending false
at those answers, independently of the still-visible spinner.

So this is not exact equivalence: it prevents spinner timing from delaying data
or its raw status by changing the graph through an effect write. That does not
establish an acceptable expression of the original derivation. A deferred
derivation is another conceptual fit, but `createDeferred`
is a design document rather than an implemented API in this checkout; it was
not used as an executable alternative.

## Other candidates and search evidence

Deliberately pausing expensive background work while foreground work is pending
is the strongest conceptual request-cancellation use. Cancellation is then the
policy, not an accidental effect of displaying a placeholder. An explicit input
dependency can express "wait for this result before starting", and an effect or
resource scheduler can express "abort this independent background job while
foreground work runs". Neither is universally identical to probing pending;
the latter requires explicit lifecycle code and is not accepted as a general
replacement for a derivation. No concrete repository example or
issue inspected here established that feeding pending back into blocking async
work is indispensable for that policy.

Inspected the signals design documents and existing pending/Loading tests,
including `ispending-memo-gate-3766`, `ispending-gated-landing`, pending companion
tests, and the Effect typeahead example. The typeahead separates its async data
producer from pending-dependent UI already.

Relevant public evidence:

- [#3766](https://github.com/solidjs/solid/issues/3766): async derivations of
  pending are exercised for coherent publication. This is not a ruling that
  cancelling the underlying data request is desirable or unavoidable.
- [#3884](https://github.com/solidjs/solid/issues/3884): adding pending/latest
  probes inside a fetch changes unrelated status observations. The probes need
  not even contribute to the result. This supports treating feedback as a
  problem, not as a useful request policy.
- [#3122](https://github.com/solidjs/solid/issues/3122): iterator cancellation
  must be prompt when the search query genuinely changes. It does not justify
  a status read superseding a still-relevant request for the same query.
- [#4222](https://github.com/solidjs/solid/issues/4222): distinguishes frame
  resources from superseded flights. The resolution comment under Ryan's
  account explicitly identifies itself as generated by Claude Code. It concerns
  appropriate teardown timing, not a blanket endorsement of pending feedback.

The searched public issues did not reveal a convincing no-good-alternative
example for the specific same-update request cancellation. This is a bounded
search, not proof none exists. The spinner is real pressure against describing
*all* async cancellation as useless. Its declarative form needs to be considered
on its own merits; no acceptable existing declarative replacement was validated.
It does not justify preserving the earlier duplicate-data-request behavior.

## Artifacts and validation

- `pending-request-alternatives.mjs`: inline/split request counts and rendered
  timelines, against both built runtimes.
- `pending-indicator-cancellation.mjs`: memo/effect spinner variants, stale
  timer completion, two consecutive requests, both runtimes.
- `packages/signals/tests/unified-pending-timer-cancellation.test.ts`: verifies
  actual same-update ownership at notification, prompt cancellation, and that a
  late timer cannot hide the new request's indicator.
- Results: `results/pending-alternatives-stage81/`.
- Next baseline remains `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`; candidate is
  the stage-79 production build. No performance comparison or runtime change
  was made in this investigation.
