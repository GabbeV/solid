# First-load deferred streams

This extends createDeferred's admitted callback protocol to a returned typed
AsyncIterable while the loading window is closed. It completes the source
wrapper's final land(flight); return r branch for these values. The original
Finish frame and ordinary handleAsync/iterator engine perform the first drain,
next calls, asynchronous gaps, completion/rejection and cleanup. There is no
new stream scheduler, wrapper, callback registry, World field or resource budget.

The guard now follows source order: test the answered/open window first, then
classify the stream that needs refetch wrapping. Direct streams before the first
real answer proceed through the ordinary path. This includes loadingValue's
still-loading window, eager/lazy construction and an ongoing first stream's
later yields. Promise-to-stream flattening before the first answer also uses
the existing ordinary engine. A later compute pass that has a real committed
answer and returns a stream still explicitly refuses Unsupported88. Its
first-yield wrapper and promise-to-stream flattening inside that open wrapper
remain unfinished. from/onSupersede, store/family, boundary and snapshot paths
remain outside the admitted profile. The buffered-from bug is not repaired.

108 public histories compare full node state, source/compute/cleanup traces,
iterator next/return calls and results, promise observers, marks and reports.
They cover bare drains, empty completion (including undefined), native/immediate
steps before/after registration, rejection, loading seeds, laziness, cancellation
and first-load flattening. No warning or alternate empty-stream value is added.
One additional compiled negative variant discards the ordinary async return;
the new stream suite rejects it after compilation. The complete preceding
corpus is rerun against this runtime in two disjoint, explicitly counted shards.
The default mutation command still runs every variant.

The existing 103-step all-natural deferred data theorem and every preceding
kernel property retain their domains and budgets. There is no new quantified
async-history theorem. The full public count becomes 3,720, including 302
deferred histories; the configured mutation count becomes 514 (437 finite,
77 kernel). The semantic deviation register remains empty.
