# Children resolver: flatten

Source: `src/flatten.ts` at Solid next `a2a5b6f8` (rc.16), production.
The actual helper now executes in the shared expression/callback/read machine.
This is children-tree flattening, separate from promise-to-async-iterable
flattening in handleAsync. Both option branches execute for typed booleans.

| Source operation | Bend segment |
| --- | --- |
| Top-level zero-formal-arity function check | flatten.zeroArgument, core.flattenValue; actual callable identity plus immutable source formal length |
| Top-level doNotUnwrap return | flattenValue returns the original callable unchanged before filtering/traversal |
| do/while function chain | invokeMany and FlattenValue/FlattenChildValue return points, preserving caller owner/tracking and original callback arguments |
| skipNonRendered | flatten.nonRendered skips only null/undefined/booleans/empty string; zero and NaN remain |
| Array result allocation | flattenResolved and Arrays.fresh; even an already flat array gets a fresh result identity |
| Element loop | FlattenFrame/flattenLoop read the source array length live, then read each slot in order; holes read as undefined |
| Per-element try/catch | FlattenElementEnd/flattenCatch preserve partial pushes, record the last NotReady error and continue siblings; other errors escape immediately |
| Nested fragment | flattenChildResolved enters another loop sharing the same result array; its needsUnwrap result ORs with the parent's prior result |
| Deferred function child | flattenChild pushes the original function unchanged and reports needsUnwrap; it does not invoke the function |
| Final pending throw | flattenEnd rethrows the saved last NotReady exception after all siblings; nested exceptions pass through their parent's element catch |
| Resolving wrapper creation | flatten.wrapper appends one zero-arity function descriptor capturing results/skip; no reactive node or scheduling work |
| Resolving wrapper invocation | core.callbackAction/FlattenChildren allocate a fresh output and traverse captured results with doNotUnwrap=false; FlattenReturn returns that array |

Function descriptors, explicit tasks and array IDs represent closures, stack
frames and mutable array identity. No recursive traversal, catch, pending policy,
owner entry or scheduling algorithm is supplied by the host. The native adapter
calls actual S.flatten and labels only newly returned resolving functions with
stable observation identities. Callback/local/action syntax binders recurse the
children expression. Generated wrappers remain ordinary callable/cleanup values
in the existing shared core; the restricted standalone owner helper refuses
expression-capable wrappers rather than pretending to execute them.

The admitted profile uses existing typed values, callables and stable array
arenas. Arbitrary JavaScript function/property/prototype protocols, external
array mutation and cyclic observations remain unfinished. Nonterminating
accessor cycles are not claimed to terminate; runtime budget exhaustion is an
explicit stop, not a successful flattened result. JSX/compiler/renderers are not
translated by adding this helper.

## Evidence

`tests/flatten.mjs` adds 66 public paired histories: scalar filtering, nested
arrays, all option combinations, formal arities 0/1/2/9, function chains,
#3133's earlier-deferred-sibling OR case, fresh wrapper/result identity,
reactive reads and memo updates, deferred retry, multiple pending sources,
ordinary errors stopping later siblings, wrapper cleanup, and lexical/callback/
action parameter capture. Five histories involving direct bound native getters
exclude read events: those internal source calls bypass the host read observer.
Their other traces/returns/errors/identities are compared; ordinary callback
reads and all prior suites retain their existing trace checks. Native Solid is
not modified or replaced with expected results.

Seven compiled finite mutations target wrong formal-arity checks, dropping zero,
losing earlier deferred siblings, swallowing ordinary errors, keeping the first
pending exception, retaining deferred mode in a resolving wrapper, and losing
nested filtering. They are assertion-oracle checks, not proofs or fuzzing.

`proof/flatten-lifecycle.bend` proves one concrete public program: create the
wrapper, read [1,0], stage a source update, still read [1,0] before flush, flush,
then read [3,0] through the same wrapper into a fresh output. Its View checks
arity and ambient/fault state too. A separate quantified construction law proves
exact single function allocation/capture and preservation of every reactive
World field for arbitrary worlds/results/options. These do not prove arbitrary
children trees, histories, termination or formal TS equivalence.

The same checkpoint adds general full-World existing-slot write and append laws
in proof/array-write.bend: both surrounding slot vectors, every other array and
every non-array World field survive unchanged, for arbitrary worlds and payloads.
The actual push helper appends exactly one Present slot, preserving its entire
existing prefix.
The positive kernel check and two compiled proof mutations are separate evidence.
The larger attempted five-payload reorder-family proof, and a smaller one-row
payload family, exhausted the original kernel fuel in direct normalization.
Neither is credited as proved or diagnosed as an upstream Solid bug. Their next
step is proof decomposition, not changing runtime behavior or kernel limits.

Checkpoint totals: 3,114 public paired histories, 223 rejected compiled variants
(208 finite differential and 15 proof-property), and 72 closed positive
regressions, alongside the quantified families. Source/toolchain/kernel pins and
the empty semantic deviation register are unchanged. The list fallback bug and
its unmerged #4211 fix remain separate from this children resolver.


The subsequent `proof/flatten-natural.bend` family removes fixed payloads and
fixed fuel for one small tree: [first,[second,false]], with arbitrary natural
payloads and any budget >=128. It proves the full exact machine/World, not only
a projected View. Real Core.step paths and existing composition lemmas provide
the sufficient-budget result. Sixty-four independent finite canonical/public/
native controls and a reversed-child-order proof mutation accompany it; these
controls do not add to public-history totals. Arbitrary tree shapes and accessor/
async histories remain open. See [general-properties.md](general-properties.md).
