# Canonical data from the actual emitted core.step. The equations in
# memo-staging check it for arbitrary proposals; generation is not trusted.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-driver.bend as Driver
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q

def data_0() -> R.NodeKind:
  R.Invalid{}

def data_1() -> R.Value:
  R.Undefined{}

def data_2() -> R.Slot:
  R.Empty{}

def data_3() -> R.Stamp:
  R.Unstamped{}

def data_4() -> R.Expr:
  R.Literal{data_1()}

def data_5() -> R.Disposal:
  R.NoDisposal{}

def data_6() -> R.Node:
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10() -> R.Value:
  R.Number{0n}

def data_11() -> R.Node:
  R.Node{data_9(), data_10(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_12() -> R.NodeKind:
  R.Memo{}

def data_13() -> R.Value:
  R.Number{1n}

def data_14() -> R.Expr:
  R.Read{2n}

def data_15() -> R.Expr:
  R.Literal{data_13()}

def data_16() -> R.Expr:
  R.Add{data_14(), data_15()}

def data_17() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_18() -> List<&2, R.Node>:
  [data_6(), data_8(), data_11(), data_17()]

def data_19() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_20() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 1n}

def data_21() -> List<&2, R.Link>:
  [data_19(), data_20()]

def data_22() -> List<&2, Nat>:
  [0n]

def data_23() -> List<&2, Nat>:
  []

def data_24() -> List<&2, R.QueueEntry>:
  []

def data_25() -> R.TreeNode:
  R.TreeNode{0n, data_23(), data_1()}

def data_26() -> List<&2, R.TreeNode>:
  [data_25(), data_25()]

def data_27() -> R.TraceEvent:
  R.Invoked{3n}

def data_28() -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10()}

def data_29() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_30() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29()]

def data_31() -> R.Fault:
  R.Healthy{}

def data_32() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_33() -> R.Question:
  R.QuestionZero{}

def data_34() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_32(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_33(), data_2(), 0n, data_1()}

def data_35() -> List<&2, R.NodeExtension>:
  [data_34()]

def data_36() -> List<&2, R.CleanupAction>:
  []

def data_37() -> R.CleanupProgram:
  R.CleanupProgram{data_36(), False{}}

def data_38() -> List<&2, R.CleanupProgram>:
  [data_37()]

def data_39() -> List<&2, R.Report>:
  []

def data_40() -> R.OptionalIds:
  R.NoIds{}

def data_41() -> R.Transaction:
  R.Transaction{data_23(), data_23(), data_24(), data_23(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_40()}

def data_42() -> List<&2, R.Transaction>:
  [data_41()]

def data_43() -> List<&2, List<&2, Nat>>:
  [data_23()]

def data_44() -> R.AsyncSettlement:
  R.Unresolved{}

def data_45() -> R.AsyncObject:
  R.AsyncObject{False{}, data_44(), data_23(), 0n}

def data_46() -> List<&2, R.AsyncObject>:
  [data_45()]

def data_47() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_48() -> List<&2, R.AsyncObserver>:
  [data_47()]

def data_49() -> List<&2, R.HostJob>:
  []

def data_50() -> List<&2, R.NextInput>:
  []

def data_51() -> R.StreamPlan:
  R.StreamPlan{data_50(), False{}, data_2(), 0n}

def data_52() -> List<&2, R.StreamPlan>:
  [data_51()]

def data_53() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_54() -> List<&2, R.ExternalIterator>:
  [data_53()]

def data_55() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_56() -> List<&2, R.StreamState>:
  [data_55()]

def data_57() -> List<&2, R.IteratorEvent>:
  []

def data_58() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_44(), False{}, 0n, False{}, False{}, 0n}

def data_59() -> List<&2, R.Awaiter>:
  [data_58()]

def data_60() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_61() -> List<&2, R.AbortInput>:
  [data_60()]

def data_62() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_63() -> List<&2, R.ContextKey>:
  [data_62()]

def data_64() -> List<&2, R.ContextEntry>:
  []

def data_65() -> R.ContextRecord:
  R.ContextRecord{data_64()}

def data_66() -> List<&2, R.ContextRecord>:
  [data_65()]

def data_67() -> List<&2, R.Expr>:
  [data_4()]

def data_68() -> List<&2, R.ReactionState>:
  []

def data_69() -> List<&2, R.ComparatorBinding>:
  []

def data_70() -> List<&2, R.ActionState>:
  []

def data_71() -> List<&2, R.ActionWait>:
  []

def data_72() -> List<&2, R.ArrayData>:
  []

def data_73() -> List<&2, R.RepeatState>:
  []

def data_74() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_49(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_75(+input: Nat) -> R.Value:
  R.Number{input}

def data_76(+input: Nat) -> R.Slot:
  R.Present{data_75(input)}

def data_77() -> R.Stamp:
  R.Stamped{2n}

def data_78(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_76(input), False{}, 0, 0, 0, 0n, data_77(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_79() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_80(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_79()]

def data_81() -> List<&2, Nat>:
  [3n]

def data_82() -> List<&2, Nat>:
  [2n]

def data_83() -> R.HostJob:
  R.FlushJob{}

def data_84() -> List<&2, R.HostJob>:
  [data_83()]

def data_85(+input: Nat) -> R.World:
  R.World{data_80(input), data_21(), data_81(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_86() -> C.Task:
  C.Round{}

def data_87() -> List<&2, C.Task>:
  [data_86()]

def data_88() -> List<&2, R.Value>:
  []

def data_89(+input: Nat) -> C.Machine:
  C.Machine{data_85(input), data_87(), data_88()}

def data_90(+input: Nat) -> R.World:
  R.World{data_80(input), data_21(), data_81(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_91() -> C.Task:
  C.RoundAfterSweep{}

def data_92() -> C.Task:
  C.FlushFinally{}

def data_93() -> C.Task:
  C.RoundEnd{}

def data_94() -> List<&2, C.Task>:
  [data_91(), data_92(), data_93()]

def data_95(+input: Nat) -> C.Machine:
  C.Machine{data_90(input), data_94(), data_88()}

def data_96() -> C.Task:
  C.HeapLoop{}

def data_97() -> List<&2, C.Task>:
  [data_96(), data_92(), data_93()]

def data_98(+input: Nat) -> C.Machine:
  C.Machine{data_90(input), data_97(), data_88()}

def data_99() -> C.Task:
  C.Recompute{3n, False{}}

def data_100() -> List<&2, C.Task>:
  [data_99(), data_96(), data_92(), data_93()]

def data_101(+input: Nat) -> C.Machine:
  C.Machine{data_90(input), data_100(), data_88()}

def data_102(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_17()]

def data_103(+input: Nat) -> R.World:
  R.World{data_102(input), data_21(), data_22(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_104() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_105() -> List<&2, C.Task>:
  [data_104(), data_96(), data_92(), data_93()]

def data_106(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_105(), data_88()}

def data_107() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_108() -> List<&2, C.Task>:
  [data_107(), data_96(), data_92(), data_93()]

def data_109(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_108(), data_88()}

def data_110() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_111(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_110()]

def data_112() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_113(+input: Nat) -> R.World:
  R.World{data_111(input), data_21(), data_22(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_112(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_114() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_115() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_88(), 0n, False{}}

def data_116() -> C.Task:
  C.Finish{data_115()}

def data_117() -> List<&2, C.Task>:
  [data_114(), data_116(), data_96(), data_92(), data_93()]

def data_118(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_117(), data_88()}

def data_119() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_120() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_121() -> C.Task:
  C.Binary{0}

def data_122() -> List<&2, C.Task>:
  [data_119(), data_120(), data_121(), data_116(), data_96(), data_92(), data_93()]

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_122(), data_88()}

def data_124() -> C.Task:
  C.ReadNode{2n}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_120(), data_121(), data_116(), data_96(), data_92(), data_93()]

def data_126(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_125(), data_88()}

def data_127() -> C.Task:
  C.ReadPrepared{2n}

def data_128() -> List<&2, C.Task>:
  [data_127(), data_120(), data_121(), data_116(), data_96(), data_92(), data_93()]

def data_129(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_128(), data_88()}

def data_130() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_131(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_130()]

def data_132() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_133() -> List<&2, R.Link>:
  [data_19(), data_132()]

def data_134(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_75(input)}

def data_135(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_134(input)]

def data_136(+input: Nat) -> R.World:
  R.World{data_131(input), data_133(), data_22(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_137() -> List<&2, C.Task>:
  [data_120(), data_121(), data_116(), data_96(), data_92(), data_93()]

def data_138(+input: Nat) -> List<&2, R.Value>:
  [data_75(input)]

def data_139(+input: Nat) -> C.Machine:
  C.Machine{data_136(input), data_137(), data_138(input)}

def data_140() -> List<&2, C.Task>:
  [data_121(), data_116(), data_96(), data_92(), data_93()]

def data_141(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_75(input)]

def data_142(+input: Nat) -> C.Machine:
  C.Machine{data_136(input), data_140(), data_141(input)}

def data_143() -> List<&2, C.Task>:
  [data_116(), data_96(), data_92(), data_93()]

def data_144(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_145(+input: Nat) -> List<&2, R.Value>:
  [data_144(input)]

def data_146(+input: Nat) -> C.Machine:
  C.Machine{data_136(input), data_143(), data_145(input)}

def data_147() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_148(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_147()]

def data_149(+input: Nat) -> R.World:
  R.World{data_148(input), data_133(), data_22(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_150(+input: Nat) -> C.Task:
  C.PassReleases{data_115(), 0n, data_144(input), False{}, False{}, False{}, data_31()}

def data_151(+input: Nat) -> List<&2, C.Task>:
  [data_150(input), data_96(), data_92(), data_93()]

def data_152(+input: Nat) -> C.Machine:
  C.Machine{data_149(input), data_151(input), data_88()}

def data_153(+input: Nat) -> R.Slot:
  R.Present{data_144(input)}

def data_154(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_153(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_155(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_154(input)]

def data_156(+input: Nat) -> R.World:
  R.World{data_155(input), data_133(), data_22(), 0n, 0n, False{}, data_82(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_157() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_158() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_159() -> List<&2, C.Task>:
  [data_157(), data_158(), data_96(), data_92(), data_93()]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_159(), data_88()}

def data_161() -> List<&2, C.Task>:
  [data_158(), data_96(), data_92(), data_93()]

def data_162(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_161(), data_88()}

def data_163() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_164() -> List<&2, C.Task>:
  [data_163(), data_96(), data_92(), data_93()]

def data_165(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_164(), data_88()}

def data_166(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_153(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_167(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_78(input), data_166(input)]

def data_168() -> List<&2, Nat>:
  [2n, 3n]

def data_169(+input: Nat) -> R.World:
  R.World{data_167(input), data_133(), data_22(), 0n, 0n, False{}, data_168(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_169(input), data_97(), data_88()}

def data_171(+input: Nat) -> R.World:
  R.World{data_167(input), data_133(), data_22(), 1n, 0n, False{}, data_168(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_172(+input: Nat) -> C.Machine:
  C.Machine{data_171(input), data_97(), data_88()}

def data_173() -> C.Task:
  C.Seam{}

def data_174() -> List<&2, C.Task>:
  [data_173(), data_92(), data_93()]

def data_175(+input: Nat) -> C.Machine:
  C.Machine{data_171(input), data_174(), data_88()}

def data_176() -> C.Task:
  C.Settle{}

def data_177() -> C.Task:
  C.AfterSettle{}

def data_178() -> List<&2, C.Task>:
  [data_176(), data_177(), data_92(), data_93()]

def data_179(+input: Nat) -> C.Machine:
  C.Machine{data_171(input), data_178(), data_88()}

def data_180() -> C.Task:
  C.CommitIntake{0n}

def data_181() -> C.Task:
  C.TrimIntake{0n}

def data_182() -> C.Task:
  C.FinishSettleIntake{0n}

def data_183() -> List<&2, C.Task>:
  [data_180(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_184(+input: Nat) -> C.Machine:
  C.Machine{data_171(input), data_183(), data_88()}

def data_185() -> C.Task:
  C.CommitPending{2n}

def data_186() -> C.Task:
  C.CommitIntake{1n}

def data_187() -> List<&2, C.Task>:
  [data_185(), data_186(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_188(+input: Nat) -> C.Machine:
  C.Machine{data_171(input), data_187(), data_88()}

def data_189(+input: Nat) -> R.Node:
  R.Node{data_9(), data_75(input), data_2(), False{}, 0, 0, 0, 0n, data_77(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_190(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_189(input), data_166(input)]

def data_191(+input: Nat) -> R.World:
  R.World{data_190(input), data_133(), data_22(), 1n, 0n, False{}, data_168(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_192() -> List<&2, C.Task>:
  [data_186(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_193(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_192(), data_88()}

def data_194() -> C.Task:
  C.CommitPending{3n}

def data_195() -> C.Task:
  C.CommitIntake{2n}

def data_196() -> List<&2, C.Task>:
  [data_194(), data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_197(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_196(), data_88()}

def data_198(+input: Nat) -> R.Node:
  R.Node{data_12(), data_144(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_199(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_189(input), data_198(input)]

def data_200(+input: Nat) -> R.World:
  R.World{data_199(input), data_133(), data_22(), 1n, 0n, False{}, data_168(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_201() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_202() -> List<&2, C.Task>:
  [data_201(), data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_203(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_202(), data_88()}

def data_204() -> O.Task:
  O.TrimDeps{3n}

def data_205() -> List<&2, O.Task>:
  [data_204()]

def data_206() -> C.Task:
  C.OwnerTasks{data_205()}

def data_207() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_208(), data_88()}

def data_210() -> List<&2, O.Task>:
  []

def data_211() -> C.Task:
  C.OwnerTasks{data_210()}

def data_212() -> List<&2, C.Task>:
  [data_211(), data_207(), data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_212(), data_88()}

def data_214() -> List<&2, C.Task>:
  [data_207(), data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_214(), data_88()}

def data_216() -> List<&2, C.Task>:
  [data_195(), data_181(), data_182(), data_177(), data_92(), data_93()]

def data_217(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_216(), data_88()}

def data_218(+input: Nat) -> R.World:
  R.World{data_199(input), data_133(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_219() -> List<&2, C.Task>:
  [data_181(), data_182(), data_177(), data_92(), data_93()]

def data_220(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_219(), data_88()}

def data_221() -> List<&2, C.Task>:
  [data_182(), data_177(), data_92(), data_93()]

def data_222(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_221(), data_88()}

def data_223() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24()}

def data_224() -> C.Task:
  C.LandTransactions{data_223(), 0n}

def data_225() -> List<&2, C.Task>:
  [data_224(), data_177(), data_92(), data_93()]

def data_226(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_225(), data_88()}

def data_227() -> C.Task:
  C.CompleteSettle{data_223()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_177(), data_92(), data_93()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_228(), data_88()}

def data_230() -> C.Task:
  C.ZombieLoop{data_23()}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_177(), data_92(), data_93()]

def data_232(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_231(), data_88()}

def data_233() -> List<&2, C.Task>:
  [data_177(), data_92(), data_93()]

def data_234(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_233(), data_88()}

def data_235(+input: Nat) -> R.World:
  R.World{data_199(input), data_133(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_236() -> C.Task:
  C.RenderQueue{}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_92(), data_93()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_237(), data_88()}

def data_239() -> C.Task:
  C.UserQueue{}

def data_240() -> List<&2, C.Task>:
  [data_239(), data_92(), data_93()]

def data_241(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_240(), data_88()}

def data_242() -> List<&2, C.Task>:
  [data_92(), data_93()]

def data_243(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_242(), data_88()}

def data_244(+input: Nat) -> R.World:
  R.World{data_199(input), data_133(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_135(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_84(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73()}

def data_245() -> List<&2, C.Task>:
  [data_93()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_244(input), data_245(), data_88()}

def data_247() -> List<&2, C.Task>:
  []

def data_248(+input: Nat) -> C.Machine:
  C.Machine{data_244(input), data_247(), data_88()}

def origin() -> R.World:
  data_74()

def state_0(+input: Nat) -> C.Machine:
  data_89(input)

def state_1(+input: Nat) -> C.Machine:
  data_95(input)

def state_2(+input: Nat) -> C.Machine:
  data_98(input)

def state_3(+input: Nat) -> C.Machine:
  data_101(input)

def state_4(+input: Nat) -> C.Machine:
  data_106(input)

def state_5(+input: Nat) -> C.Machine:
  data_109(input)

def state_6(+input: Nat) -> C.Machine:
  data_118(input)

def state_7(+input: Nat) -> C.Machine:
  data_123(input)

def state_8(+input: Nat) -> C.Machine:
  data_126(input)

def state_9(+input: Nat) -> C.Machine:
  data_129(input)

def state_10(+input: Nat) -> C.Machine:
  data_139(input)

def state_11(+input: Nat) -> C.Machine:
  data_142(input)

def state_12(+input: Nat) -> C.Machine:
  data_146(input)

def state_13(+input: Nat) -> C.Machine:
  data_152(input)

def state_14(+input: Nat) -> C.Machine:
  data_160(input)

def state_15(+input: Nat) -> C.Machine:
  data_162(input)

def state_16(+input: Nat) -> C.Machine:
  data_165(input)

def state_17(+input: Nat) -> C.Machine:
  data_170(input)

def state_18(+input: Nat) -> C.Machine:
  data_172(input)

def state_19(+input: Nat) -> C.Machine:
  data_175(input)

def state_20(+input: Nat) -> C.Machine:
  data_179(input)

def state_21(+input: Nat) -> C.Machine:
  data_184(input)

def state_22(+input: Nat) -> C.Machine:
  data_188(input)

def state_23(+input: Nat) -> C.Machine:
  data_193(input)

def state_24(+input: Nat) -> C.Machine:
  data_197(input)

def state_25(+input: Nat) -> C.Machine:
  data_203(input)

def state_26(+input: Nat) -> C.Machine:
  data_209(input)

def state_27(+input: Nat) -> C.Machine:
  data_213(input)

def state_28(+input: Nat) -> C.Machine:
  data_215(input)

def state_29(+input: Nat) -> C.Machine:
  data_217(input)

def state_30(+input: Nat) -> C.Machine:
  data_220(input)

def state_31(+input: Nat) -> C.Machine:
  data_222(input)

def state_32(+input: Nat) -> C.Machine:
  data_226(input)

def state_33(+input: Nat) -> C.Machine:
  data_229(input)

def state_34(+input: Nat) -> C.Machine:
  data_232(input)

def state_35(+input: Nat) -> C.Machine:
  data_234(input)

def state_36(+input: Nat) -> C.Machine:
  data_238(input)

def state_37(+input: Nat) -> C.Machine:
  data_241(input)

def state_38(+input: Nat) -> C.Machine:
  data_243(input)

def state_39(+input: Nat) -> C.Machine:
  data_246(input)

def state_40(+input: Nat) -> C.Machine:
  data_248(input)

def finalWorld(+input: Nat) -> R.World:
  data_244(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
