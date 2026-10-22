# Quantified lane-group mutation frames

Four quantified properties now check the actual existing linkLanes/unlink helpers
in `proof/lane-group-laws.bend`, rooted in LAWS/PROOF, with the original independent
kernel. No runtime implementation changes were needed for these properties.

- Unlink removes the first matching target from the existing shared group and
  clears its transaction's group pointer. Every other World field, transaction
  record and group is preserved.
- If the target is absent, unlink still clears its pointer and preserves the
  whole group/world around it.
- Linking two transactions already sharing a nonnull identity leaves the entire
  World unchanged, with no allocation.
- Linking a previously unlinked transaction to itself appends one fresh group
  containing itself once. The second pointer read sees the first pointer store;
  it does not append a duplicate member.

The unlink properties use target transaction/group slot one, arbitrary prefix
length/natural peer offsets (IDs >=2), arbitrary suffix data, record/arena tails
and surrounding World. First-match behavior includes synthetic repeated targets
in the suffix and the explicit absent-member guard. The linked-property group
identity is any positive natural; callers supply a well-formed allocated group.
Self allocation keeps the reserved zero group and quantifies all earlier arrays.
These local raw-arena facts do not prove global group construction invariants,
lane lifetime/reveal/correction, arbitrary graph progress or TS/Bend equivalence.

List induction checks membership/removal through any finite peer prefix. Checked
entry/branch equations transport those results through the real World/group/tx
stores; no generated final result or alternate unlink implementation supplies the
outcome. Seventy-one separate canonical/native controls compare actual helper
execution with complete Bend expected Worlds and native source pointer/array
aliasing, including long prefixes, absent/repeated entries, cached groups and
fresh self-linking. They do not add public histories or closed-program counts.
Four new compiled proof mutations target stale pointers, two-occurrence removal,
shared-group refusal and a self pointer read before initialization.

Together with laneStage this checkpoint has eight new quantified properties and
twelve new variants: cumulative mutations 275 (236 finite assertion rejections,
39 quantified proof assertion rejections). The complete mutation/public/helper
suites and combined root are rechecked; the runtime/compiler/source pins and
empty semantic deviation register stay unchanged.
