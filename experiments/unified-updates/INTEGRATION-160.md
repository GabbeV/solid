# Inactive latest: synchronous fast path and request lifetime

No runtime or test-expectation changes are retained. Stage 159 is restored,
including its built artifacts. This investigation makes the request-lifetime
tradeoff explicit rather than accepting a lower total failure count.

## Trials

Removing eager latest preparation and allowing its inactive output to read an
unheld proposal repairs 20 existing synchronous calculation assertions. Taken
alone, it still exposes early Loading publication, missed owned-error recovery,
and a missed inline pending update. Preselecting a calculation from its previous
dependencies breaks equivalent wrapped cases and is rejected. Expanding tracked
read-context discovery also breaks existing consistency controls and is rejected.

Registering an already-open action's queued proposals before the first latest
output read repairs the Loading and owned-error cases. This must exclude
unflushed writes: otherwise an imperative observation inside an action exposes
its unflushed proposal. A focused guard using the existing `unflushedValue`
check repairs that regression; its report has 51 passes and 12 deferred
optimistic-store failures.

A narrower trial allows ordinary latest propagation only when no transaction
exists, retaining eager preparation during holds. This passes the focused
786-case set except its four existing detached-first-callback expectations and
seven deferred optimistic-store cases. It adds no node fields or cache. However,
the full suites reject it:

- Signals: **5,523 passed / 2,015 failed / two skipped**. Relative to stage 159,
  20 old failures are fixed and 15 old passes fail; the eight stage-159 controls
  are included now. No collection errors. The 15 are twelve request-uniqueness
  assertions, two keyed-child construction-count assertions, and the unflushed
  read bug addressed by the subsequent focused guard.
- Web: **1,694 passed / 124 failed / one skipped**. Two keyed-child construction
  regressions and one generated final-state regression; no improvements or
  collection errors. Generated seed 3289 case 1383 finishes with value 4 where
  a fresh evaluation errors in m0. This is an implementation bug, not an
  accepted semantic difference. The gate and its baseline remain unchanged.

The full reports describe the pre-unflushed-guard trial exactly, saved as
`latest-idle-fast.ts` and `observation-idle-fast.ts`. The guarded follow-up is
saved separately. No full-suite improvement is claimed for that follow-up.

An additional `packages/solid` suite was run while selecting the web suite:
902 passes and 24 failures. That is a separate suite, not the web comparison;
it has no paired baseline in this stage. Its results are retained separately.

## One memo explains the repeated request

After initially publishing 11:

```ts
const [id, setId] = createSignal(1);
const value = createMemo(() => request(10 * latest(id) + id()));
// A Loading boundary renders value().
setId(2);
```

The executable reduction controls answers independently. Resolve request 21
first, then every request for 22. It checks initial and final publication.

| Runtime | Requests after the write | Publication after 21 answers | Publication after 22 answers |
| --- | --- | --- | --- |
| Pinned next `4fe75321` | 22, 21 | 21 | 22 |
| Retained stage 159 | 12, 21, 22 | Still 11 | 22 |
| Narrow fast-path trial | 22, 21, 22 | Still 11 | 22 |

Next can use the original request 22 after publishing 21: both calculations'
answers remain eligible. The experiment replaces the eligible calculation when
it changes context. It also does not let the optimistic calculation maintain
its input's lifetime; without an independent hold, correction supersedes 21.
The trial therefore starts 22 again. Its original 22 and its 21 never publish.

This is not more requests than the retained implementation in this reduction:
the retained implementation instead starts an unnecessary 12 from stale latest
beside the proposed ordinary input. Request uniqueness misses that work. Neither
trace constitutes a performance measurement or proves these requests unavoidable.

The open question is whether the old once-per-argument assertion is a required
contract across superseded update contexts. Preserving the original request for
reuse would require keeping it eligible alongside the optimistic calculation.
Avoiding unnecessary temporary calculations remains a possible optimization,
but is not a general uniqueness guarantee. No assertion has been changed while
that question is open. In particular the separate final-error and owned-child
regressions are not excused by this request-lifetime analysis.

## Restoration

Runtime files compare byte-for-byte with stage 159. Forty-eight restored source
controls pass, including pending feedback, owned error recovery, new-child frame
coherence, optimistic publication, and derived-store latest seeds. Build and
property-mangling outputs were restored. Rules-index and diff checks pass.
No performance or size claim. Raw trials, reports, traces, and the executable
reduction are in `checkpoints/integration-stage160.tar.xz`.
