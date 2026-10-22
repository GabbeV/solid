# Source-only refresh to next 1c0ff9f8

This is #4216 / #4001's eager-store-adoption identity fix and store size work.
It follows cdd95616 and still declares rc.17. Four recorded inputs change:
store/store.ts, store/reconcile.ts, INTERNALS-STORE-STATE.md and RULES-INDEX.md.
All 77 recorded Solid inputs match Git byte for byte. Every non-store source
file is identical to cdd95616. No Bend runtime, representation or observation
operation changes from the verified first-load-stream checkpoint 84ae521.

The descend fix retains raw/proxy row identity across swaps, shifts, reorders and
keyless keyed rows, with each row's parent-key following its occupied slot. The
other store edits share overlay application, simplify guarded reads/write traps
and gate test-only mutation assertions. These store operations remain unported;
no Bend store correctness is claimed.

Full-index initialization is retained. The changed installed _slotFlight arrow
returns false for a non-store node with no _host/family/node: the optional-chain
undefined becomes zero under the bitwise mask. _slotCovered's guarded store
branches retain their no-target early return. Other changes run with actual
store targets/families. The admitted non-store profile does not install such
targets; reached slot/family branches retain their explicit refusals. The opaque
payload, array-helper and signal paths are not substituted for store behavior.

The unmodified native package builds all three JS tiers, generates source
declarations and passes 337 files /5,521 tests, with two expected failures and two
skips. The prior full 514-variant negative run checks exactly the same Bend code
against cdd95616's native reference; its receipt retains that pin. The latest-pin
public/alignment/kernel validation is separate, so those source snapshots are
not silently conflated. The three deferred/from repro paths are unchanged and
the candidate patches stay isolated/unfiled. No workaround is active.


Latest-pin revalidation passes the complete 3,720-history public suite and full
private alignment suite. All registered proof claims and input hashes are sealed
in the final checked.json. No old sufficient budget or quantified domain changed.
The unchanged baseline/native repros and all three patch applicability checks
also pass on this latest source.
