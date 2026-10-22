# Signed-zero representation repair

At c608b3a, the public payload codec accepted JavaScript `-0` but encoded it as
`Number{0}`. `signal("n", -0); read("n")` therefore returned positive zero;
`Object.is(read("n"), -0)` was false in Bend and true in pinned Solid. This was a
port representation bug, not an upstream bug or a semantic workaround.

A distinct `NegativeZero` value now preserves that payload through the one
runtime. Strict equality still equates both zeros, truthiness remains false,
String(-0) remains "0", and admitted addition/multiplication retain IEEE signs.
Negative zero is also a valid array index zero. The separate Object.is helper
keeps both zeros distinct and equates NaN with itself, for the source stale-effect
publication check. It does not replace source strict equality or custom calls.

Eleven public histories compare storage/returns, default and equals:false writes,
memos/render, callback arguments/updater returns, async data, StatusError causes
and cleanup throws against the unchanged rc.17 source. Fifty-two primitive
controls compare addition, multiplication, strict equality, truthiness and array
indexing. Eight kernel facts cover strict equality in both orders, Object.is,
arithmetic, truthiness and String conversion: five quantify over every admitted
natural counterpart, three are closed scalar helper facts. They do not add to
the 72 composed program regressions or establish general JavaScript numerics.
Seven compiled mutations are rejected (three finite assertions, four kernel
properties). The full corpus now has 3,169 public histories and 344 mutations.

Natural-valued numbers, NaN and signed zero remain an explicitly restricted
scalar profile. General negatives, floating point, Infinity and arbitrary
coercions remain unimplemented. Repeat count/from admission still requires
natural values: normalizing a negative-zero offset would lose an observable
mapper index. This repair does not widen that constructor profile or silently
normalize it. No source pin changed and no semantic deviation is active.
