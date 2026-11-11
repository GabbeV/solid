# Correctness pass before optimization

Primary supervised Sol medium agents for discovery, implementation, differential
checks and independent review. Starting retained runtime: `13e09bef7`. No size or
performance simplification from the earlier five investigation plans was applied.

## Confirmed failures

1. A signal equality comparator reading `latest` can reenter the observation
   while it registers open-action proposals. The maintenance read attaches the
   output to itself; disposal then overflows the stack. Run that registration
   through `untrack`, retaining the calculation's read context and actual source
   dependencies outside that narrow maintenance window.
2. A comparator querying an unrelated unobserved pending output can prevent
   flush from quiescing. Its equal settled selector schedules work which revives
   it after each dormancy sweep. Skip that enqueue only for subscriberless
   auto-dispose outputs with no pending, error, initialization or owned work.
   Equal writes with lifecycle obligations still take the original path.
3. A standalone `isPending` query can change a later rendered result: an update
   finishes with `{value: 5, pending: true}` instead of false. This reproduces on
   clean experiment HEAD, without any cleanup trial. Dormancy had discarded the
   observation's input question; revival selected a new true override during
   restoration. Preserve the active question through dormancy, restore it in
   the original update, and make pending respect restoration as latest does.
   A superseding input revision ends the earlier restoration. Explicitly dead
   owners are distinguished from dormant outputs using existing disposal flags.

The fixes add no node fields, queues, caches or ordinary-core/scheduler changes.
Question bookkeeping is cleared when the update finishes. Disposal of a parent
of an already-detached lazy input is recognized at the next actual reactive
flush; no autonomous disposal wakeup was introduced.

## Rejected and deferred work

The broader cleanup candidate passed a focused selection but introduced 14
failures in the full signals suite. It was retracted, not accommodated by editing
existing assertions. The generic `!tracking` change repeated ordinary memo work;
the synchronous final sweep changed owned-child cleanup timing. It also exposed
the independent pending revival defect fixed above. See CORRECTNESS-quiescence.md.

Proactive reclamation of source-owned observation outputs remains deferred.
The current-next `bcef1041c` control retains an otherwise unobserved producer
through multiple turns, action completion and consumer disposal. Guaranteed
next-turn reclamation changes user cleanup/recomputation behavior and needs a
lifetime ruling; it is not an established compatibility requirement. The trial
WeakSet, microtask sweeper and generic dormancy changes are not retained.
New experimental reclamation probes are archived separately from accepted tests.
No old test assertion or consistency assertion was weakened.

The apparent disposed-edge reattachment was a diagnostic artifact: Vitest
formatted a mutable object after `finally` had disposed it. Direct tracing found
live companion retention, not a dependency journal corruption bug. No graph
replay change was made.

## Validation

Primary validation of the frozen candidate:

- Complete signals suite: **5,802 passed, 1,953 failed, 2 skipped**, 588 files.
  Failing test identities exactly match stage182: no new or resolved failures.
  Existing failed suites remain failed; this is not a green full API claim.
- Fresh mangled production build: **180 passed** across public observation,
  ownership, error, first-value and retry controls, including the new regressions.
- Fresh dist artifacts and tree shaking: **61 passed**.
- Rollup, declaration/type build, property mangling and both purity checks pass.
- No throughput or allocation benchmark was run in this correctness pass.

Instrumented scratch controls additionally exercise
20 real dormant-question cycles with no later reads, 20 standalone query/action
cycles, initial pending work, explicit owner death and detached-source death.
These are finite controls, not a proof for every graph or lifetime.


## Shipped size

Same scalar-import bundling harness as stage182. `next` is the reproducible
baseline **4fe75321d61f9e4f1e1c63edc2087d099a36e9e1**, not an unspecified
previous experiment. Current-next **bcef1041c** was used separately for semantic
comparisons. Values are minified / Brotli bytes.

| Import scenario | next baseline | Entry experiment | Corrected experiment |
| --- | ---: | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,456 / 8,056 | 21,456 / 8,056 |
| Optimism | 30,556 / 11,180 | 37,213 / 13,432 | 37,279 / 13,462 |
| Optimism + observations | 35,643 / 12,920 | 43,434 / 15,330 | 43,741 / 15,426 |

Ordinary imports do not retain these repairs. The correction costs 66 minified
bytes for optimism and 307 for the observed scenario. This does not solve the
experiment's existing size gap and is not a mergeability or performance claim.
