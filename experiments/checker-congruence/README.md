# Independent checker composition experiment

Copy `repro.bend.txt` to a `.bend` path and run the pinned CLI with `--verdict`.
The baseline kernel exhausts fuel. The explicit `same-head-congruence-v1` profile
checks the same equation without changing its statement or the reduction budget.
The profile's full Lean development, including its updated conversion soundness
proof, must compile before its executable is used. See
[the profile and validation notes](../../tracking/kernel-congruence.md).

The reproduction is a checker efficiency case, not a Solid bug or a replacement
reactivity model. The source runtime, pinned frontend and vendored kernel remain
unchanged. The optimized profile is now the recorded default for repository verification.
The baseline622-root seal and the full678 optimized negative sweep retain separate
provenance; the native executables used by the sweep and managed build are identical.
