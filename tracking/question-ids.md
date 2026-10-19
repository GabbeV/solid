# Exact binary question IDs and concrete async proofs

Source question IDs are numbers: scheduler `question`/`questions` begin at zero,
nextQuestion returns ++questions without installing it, and a new flight records
question || MAINLINE_QUESTION (0x7fffffff). These fields and operations are retained.

The original representation used Bend's unary Nat for these IDs. The pinned
independent kernel normalizes closed copied Data values. A world holding the
mainline ID therefore needed over two billion successor constructors. This caused
the earlier async proof fuel failure; it was not evidence of a Solid bug or an
incorrect theorem. Assignment-sized continuation checkpoints isolated the failure
to copying the newly stored question, making the cause concrete.

Question now represents the same natural numeric IDs using canonical bijective
binary constructors:

- QuestionZero = 0
- QuestionOdd(q) = 2*q + 1
- QuestionEven(q) = 2*q + 2

Every finite constructor chain has a unique natural meaning, including zero.
MAINLINE_QUESTION is 31 Odd bits. It is the ordinary numeric identity at that value,
not a disjoint special tag: incrementing 0x7ffffffe compares equal to mainline,
preserving a possible source counter collision. The encoding introduces neither
wraparound nor a new limit. General JS Number precision outside the admitted
integer range remains outside the execution claim, as before.

World.question and NodeExtension.q use this encoding; World.questions is the
separate source sequence counter. Source setQuestion/nextQuestion and the flight
assignment remain distinct. The helpers live in runtime/question.bend. Small-Nat
conversion exists for fixtures; large IDs use the binary constructor boundary.
Source arithmetic/branch decisions were not replaced with a different algorithm.
This is an exact representation repair, not an active semantic deviation.

Evidence includes 4,096 source counter steps, five counter starts near large
boundaries, 69 source flight-provenance cases, and 4,103 exact integer
increment/equality vectors. Source comparisons stay within admitted safe integers;
the larger BigInt vectors test the mathematical representation only. Independent
kernel proofs establish for every Question that increment increases its natural
meaning by one and equality is reflexive, and for every Nat that the fixture
conversion preserves its meaning. These do not claim formal TS equivalence.

The registration continuation now exposes the source assignments as explicit
RegisterFlight / RegisterQuestion / RegisterSources / RegisterObserver /
SubscribeThen return points. They share recordFlight, recordQuestion, addObserver
and the existing source-set helper with the direct registration path. No host job
runs between them: the same core run continues to the then call before returning.
Body throws still unwind the enclosing compute frame. This is finer control-flow
representation of the same source operations, not another scheduler or a proof
runtime. Both paths are compared to the pinned source.

With binary IDs the kernel checks the new composed laws directly through actual
API construction and the driver; generated endpoint/witness prototypes are not
needed and were removed. Five new closed regressions establish:

- loading_seed_waits: unresolved first work keeps seed/text 0 and loading open;
- promise_lands: a later explicit fulfillment commits value/text 6 and closes it;
- stale_promise_is_ignored: the old object's answer 99 cannot replace object 2's
  loading seed/text;
- newest_promise_lands: object 2's answer then publishes value/text 6;
- async_diamond_lands: an unseeded pending diamond settles to values 6,7,8,15 and
  text 15, with all five statuses clear and no live transaction/effect/intake queues.

The first four check staging, loading, status, retained result identity, text,
queues, successful completion and restored ambient state. The diamond checks
those observation/status/queue fields over a larger graph. Settlement is an
explicit external thenable input. Native Promise reaction timing, arbitrary graphs,
iterator pumping and public watcher semantics are tested rather than proved.
That milestone brought the count to fourteen closed composed regressions, alongside
two payload laws, three general question-representation laws and generic path
lemmas. The current frontier also includes the later until cases and the explicitly
negative staged-error recovery counterexample. No
unsafe code, generated answer, axiom, runtime fork or kernel modification supplies
these results. The executable/proof frontends and independent checker remain pinned.
