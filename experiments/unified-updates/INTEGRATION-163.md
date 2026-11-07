# First held values and a derived store's staged result

No runtime changes retained. Stage 162 remains the implementation checkpoint.

Two #4429 scalar cases still cannot observe a ready first value through latest
while an action holds its input. Allowing that selection and staging the initial
observation through the normal output-update operation repairs both. It also
reproduces six derived-store seed leaks: the producer's status/result follows the
higher update but the properties it wrote remain in the lower update.

A trial uses the existing store family index to transfer held property proposals
with their producer. Matching only the producer's old transaction repairs three
of those six cases. The other three use an async derive with a held sibling. The
trace shows a producer not yet parked when its backing has already been parked
in the ambient update. Matching that ambient owner as well repairs all 24 seed
controls and passes the unified scalar controls, but fails both independent
manual-write guards. A store with an initial derive still pending can already
have an unrelated manual edit held by an action; transferring its backing makes
that edit visible early. Existing per-leaf manual-write flags are insufficient
when that property has no leaf yet.

Reject the transfer, rather than weakening the guards or adding provenance
records speculatively. The result is not a semantic question: a latest read of
one input cannot publish an unrelated held manual edit. The producer's status
and property result need coherent publication, but a whole-family transfer does
not establish that. Store backing ownership needs further work before using this
approach to repair first-value selection. This is ordinary derived-store
integration, separate from the still-deferred optimistic-store API.

Sources are restored exactly to stage 162. The restored focused set has **43
passes and the same two #4429 failures**; all 24 seed guards, both independent
manual-write guards and the 15 latest transparency/flight controls pass. Build
artifacts were never changed in these trials. No size/performance claim and no
additional runtime field or hook is retained.

Receipts, rejected sources, and the async ownership trace:
`checkpoints/integration-stage163.tar.xz`.
