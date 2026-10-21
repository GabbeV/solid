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
  R.CleanupProgram{data_36(), False{}, 0n}

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

def data_74() -> List<&2, R.MapState>:
  []

def data_75() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_49(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_76(+input: Nat) -> R.Value:
  R.Number{input}

def data_77(+input: Nat) -> R.Slot:
  R.Present{data_76(input)}

def data_78() -> R.Stamp:
  R.Stamped{2n}

def data_79(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_77(input), False{}, 0, 0, 0, 0n, data_78(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_80() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_81(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_80()]

def data_82() -> List<&2, Nat>:
  [3n]

def data_83() -> List<&2, Nat>:
  [2n]

def data_84() -> R.HostJob:
  R.FlushJob{}

def data_85() -> List<&2, R.HostJob>:
  [data_84()]

def data_86(+input: Nat) -> R.World:
  R.World{data_81(input), data_21(), data_82(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_87() -> C.Task:
  C.Round{}

def data_88() -> List<&2, C.Task>:
  [data_87()]

def data_89() -> List<&2, R.Value>:
  []

def data_90(+input: Nat) -> C.Machine:
  C.Machine{data_86(input), data_88(), data_89()}

def data_91(+input: Nat) -> R.World:
  R.World{data_81(input), data_21(), data_82(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_92() -> C.Task:
  C.RoundAfterSweep{}

def data_93() -> C.Task:
  C.FlushFinally{}

def data_94() -> C.Task:
  C.RoundEnd{}

def data_95() -> List<&2, C.Task>:
  [data_92(), data_93(), data_94()]

def data_96(+input: Nat) -> C.Machine:
  C.Machine{data_91(input), data_95(), data_89()}

def data_97() -> C.Task:
  C.HeapLoop{}

def data_98() -> List<&2, C.Task>:
  [data_97(), data_93(), data_94()]

def data_99(+input: Nat) -> C.Machine:
  C.Machine{data_91(input), data_98(), data_89()}

def data_100() -> C.Task:
  C.Recompute{3n, False{}}

def data_101() -> List<&2, C.Task>:
  [data_100(), data_97(), data_93(), data_94()]

def data_102(+input: Nat) -> C.Machine:
  C.Machine{data_91(input), data_101(), data_89()}

def data_103(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_17()]

def data_104(+input: Nat) -> R.World:
  R.World{data_103(input), data_21(), data_22(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_105() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_106() -> List<&2, C.Task>:
  [data_105(), data_97(), data_93(), data_94()]

def data_107(+input: Nat) -> C.Machine:
  C.Machine{data_104(input), data_106(), data_89()}

def data_108() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_97(), data_93(), data_94()]

def data_110(+input: Nat) -> C.Machine:
  C.Machine{data_104(input), data_109(), data_89()}

def data_111() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_112(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_111()]

def data_113() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_114(+input: Nat) -> R.World:
  R.World{data_112(input), data_21(), data_22(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_113(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_115() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_116() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_89(), 0n, False{}}

def data_117() -> C.Task:
  C.Finish{data_116()}

def data_118() -> List<&2, C.Task>:
  [data_115(), data_117(), data_97(), data_93(), data_94()]

def data_119(+input: Nat) -> C.Machine:
  C.Machine{data_114(input), data_118(), data_89()}

def data_120() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_121() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_122() -> C.Task:
  C.Binary{0}

def data_123() -> List<&2, C.Task>:
  [data_120(), data_121(), data_122(), data_117(), data_97(), data_93(), data_94()]

def data_124(+input: Nat) -> C.Machine:
  C.Machine{data_114(input), data_123(), data_89()}

def data_125() -> C.Task:
  C.ReadNode{2n}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_121(), data_122(), data_117(), data_97(), data_93(), data_94()]

def data_127(+input: Nat) -> C.Machine:
  C.Machine{data_114(input), data_126(), data_89()}

def data_128() -> C.Task:
  C.ReadPrepared{2n}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_121(), data_122(), data_117(), data_97(), data_93(), data_94()]

def data_130(+input: Nat) -> C.Machine:
  C.Machine{data_114(input), data_129(), data_89()}

def data_131() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_132(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_131()]

def data_133() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_134() -> List<&2, R.Link>:
  [data_19(), data_133()]

def data_135(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_76(input)}

def data_136(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_135(input)]

def data_137(+input: Nat) -> R.World:
  R.World{data_132(input), data_134(), data_22(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_138() -> List<&2, C.Task>:
  [data_121(), data_122(), data_117(), data_97(), data_93(), data_94()]

def data_139(+input: Nat) -> List<&2, R.Value>:
  [data_76(input)]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_137(input), data_138(), data_139(input)}

def data_141() -> List<&2, C.Task>:
  [data_122(), data_117(), data_97(), data_93(), data_94()]

def data_142(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_76(input)]

def data_143(+input: Nat) -> C.Machine:
  C.Machine{data_137(input), data_141(), data_142(input)}

def data_144() -> List<&2, C.Task>:
  [data_117(), data_97(), data_93(), data_94()]

def data_145(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_146(+input: Nat) -> List<&2, R.Value>:
  [data_145(input)]

def data_147(+input: Nat) -> C.Machine:
  C.Machine{data_137(input), data_144(), data_146(input)}

def data_148() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_149(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_148()]

def data_150(+input: Nat) -> R.World:
  R.World{data_149(input), data_134(), data_22(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_151(+input: Nat) -> C.Task:
  C.PassReleases{data_116(), 0n, data_145(input), False{}, False{}, False{}, data_31()}

def data_152(+input: Nat) -> List<&2, C.Task>:
  [data_151(input), data_97(), data_93(), data_94()]

def data_153(+input: Nat) -> C.Machine:
  C.Machine{data_150(input), data_152(input), data_89()}

def data_154(+input: Nat) -> R.Slot:
  R.Present{data_145(input)}

def data_155(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_154(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_156(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_155(input)]

def data_157(+input: Nat) -> R.World:
  R.World{data_156(input), data_134(), data_22(), 0n, 0n, False{}, data_83(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_158() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_159() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_160() -> List<&2, C.Task>:
  [data_158(), data_159(), data_97(), data_93(), data_94()]

def data_161(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_160(), data_89()}

def data_162() -> List<&2, C.Task>:
  [data_159(), data_97(), data_93(), data_94()]

def data_163(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_162(), data_89()}

def data_164() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_165() -> List<&2, C.Task>:
  [data_164(), data_97(), data_93(), data_94()]

def data_166(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_165(), data_89()}

def data_167(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_154(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_168(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_79(input), data_167(input)]

def data_169() -> List<&2, Nat>:
  [2n, 3n]

def data_170(+input: Nat) -> R.World:
  R.World{data_168(input), data_134(), data_22(), 0n, 0n, False{}, data_169(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_171(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_98(), data_89()}

def data_172(+input: Nat) -> R.World:
  R.World{data_168(input), data_134(), data_22(), 1n, 0n, False{}, data_169(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_98(), data_89()}

def data_174() -> C.Task:
  C.Seam{}

def data_175() -> List<&2, C.Task>:
  [data_174(), data_93(), data_94()]

def data_176(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_175(), data_89()}

def data_177() -> C.Task:
  C.Settle{}

def data_178() -> C.Task:
  C.AfterSettle{}

def data_179() -> List<&2, C.Task>:
  [data_177(), data_178(), data_93(), data_94()]

def data_180(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_179(), data_89()}

def data_181() -> C.Task:
  C.CommitIntake{0n}

def data_182() -> C.Task:
  C.TrimIntake{0n}

def data_183() -> C.Task:
  C.FinishSettleIntake{0n}

def data_184() -> List<&2, C.Task>:
  [data_181(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_185(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_184(), data_89()}

def data_186() -> C.Task:
  C.CommitPending{2n}

def data_187() -> C.Task:
  C.CommitIntake{1n}

def data_188() -> List<&2, C.Task>:
  [data_186(), data_187(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_189(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_188(), data_89()}

def data_190(+input: Nat) -> R.Node:
  R.Node{data_9(), data_76(input), data_2(), False{}, 0, 0, 0, 0n, data_78(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_191(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_190(input), data_167(input)]

def data_192(+input: Nat) -> R.World:
  R.World{data_191(input), data_134(), data_22(), 1n, 0n, False{}, data_169(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_193() -> List<&2, C.Task>:
  [data_187(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_194(+input: Nat) -> C.Machine:
  C.Machine{data_192(input), data_193(), data_89()}

def data_195() -> C.Task:
  C.CommitPending{3n}

def data_196() -> C.Task:
  C.CommitIntake{2n}

def data_197() -> List<&2, C.Task>:
  [data_195(), data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_198(+input: Nat) -> C.Machine:
  C.Machine{data_192(input), data_197(), data_89()}

def data_199(+input: Nat) -> R.Node:
  R.Node{data_12(), data_145(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_200(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_190(input), data_199(input)]

def data_201(+input: Nat) -> R.World:
  R.World{data_200(input), data_134(), data_22(), 1n, 0n, False{}, data_169(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_202() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_203() -> List<&2, C.Task>:
  [data_202(), data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_203(), data_89()}

def data_205() -> O.Task:
  O.TrimDeps{3n}

def data_206() -> List<&2, O.Task>:
  [data_205()]

def data_207() -> C.Task:
  C.OwnerTasks{data_206()}

def data_208() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_209() -> List<&2, C.Task>:
  [data_207(), data_208(), data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_210(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_209(), data_89()}

def data_211() -> List<&2, O.Task>:
  []

def data_212() -> C.Task:
  C.OwnerTasks{data_211()}

def data_213() -> List<&2, C.Task>:
  [data_212(), data_208(), data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_214(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_213(), data_89()}

def data_215() -> List<&2, C.Task>:
  [data_208(), data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_216(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_215(), data_89()}

def data_217() -> List<&2, C.Task>:
  [data_196(), data_182(), data_183(), data_178(), data_93(), data_94()]

def data_218(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_217(), data_89()}

def data_219(+input: Nat) -> R.World:
  R.World{data_200(input), data_134(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_220() -> List<&2, C.Task>:
  [data_182(), data_183(), data_178(), data_93(), data_94()]

def data_221(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_220(), data_89()}

def data_222() -> List<&2, C.Task>:
  [data_183(), data_178(), data_93(), data_94()]

def data_223(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_222(), data_89()}

def data_224() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24()}

def data_225() -> C.Task:
  C.LandTransactions{data_224(), 0n}

def data_226() -> List<&2, C.Task>:
  [data_225(), data_178(), data_93(), data_94()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_226(), data_89()}

def data_228() -> C.Task:
  C.CompleteSettle{data_224()}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_178(), data_93(), data_94()]

def data_230(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_229(), data_89()}

def data_231() -> C.Task:
  C.ZombieLoop{data_23()}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_178(), data_93(), data_94()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_232(), data_89()}

def data_234() -> List<&2, C.Task>:
  [data_178(), data_93(), data_94()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_234(), data_89()}

def data_236(+input: Nat) -> R.World:
  R.World{data_200(input), data_134(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_237() -> C.Task:
  C.RenderQueue{}

def data_238() -> List<&2, C.Task>:
  [data_237(), data_93(), data_94()]

def data_239(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_238(), data_89()}

def data_240() -> C.Task:
  C.UserQueue{}

def data_241() -> List<&2, C.Task>:
  [data_240(), data_93(), data_94()]

def data_242(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_241(), data_89()}

def data_243() -> List<&2, C.Task>:
  [data_93(), data_94()]

def data_244(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_243(), data_89()}

def data_245(+input: Nat) -> R.World:
  R.World{data_200(input), data_134(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_136(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_85(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74()}

def data_246() -> List<&2, C.Task>:
  [data_94()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_245(input), data_246(), data_89()}

def data_248() -> List<&2, C.Task>:
  []

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_245(input), data_248(), data_89()}

def origin() -> R.World:
  data_75()

def state_0(+input: Nat) -> C.Machine:
  data_90(input)

def state_1(+input: Nat) -> C.Machine:
  data_96(input)

def state_2(+input: Nat) -> C.Machine:
  data_99(input)

def state_3(+input: Nat) -> C.Machine:
  data_102(input)

def state_4(+input: Nat) -> C.Machine:
  data_107(input)

def state_5(+input: Nat) -> C.Machine:
  data_110(input)

def state_6(+input: Nat) -> C.Machine:
  data_119(input)

def state_7(+input: Nat) -> C.Machine:
  data_124(input)

def state_8(+input: Nat) -> C.Machine:
  data_127(input)

def state_9(+input: Nat) -> C.Machine:
  data_130(input)

def state_10(+input: Nat) -> C.Machine:
  data_140(input)

def state_11(+input: Nat) -> C.Machine:
  data_143(input)

def state_12(+input: Nat) -> C.Machine:
  data_147(input)

def state_13(+input: Nat) -> C.Machine:
  data_153(input)

def state_14(+input: Nat) -> C.Machine:
  data_161(input)

def state_15(+input: Nat) -> C.Machine:
  data_163(input)

def state_16(+input: Nat) -> C.Machine:
  data_166(input)

def state_17(+input: Nat) -> C.Machine:
  data_171(input)

def state_18(+input: Nat) -> C.Machine:
  data_173(input)

def state_19(+input: Nat) -> C.Machine:
  data_176(input)

def state_20(+input: Nat) -> C.Machine:
  data_180(input)

def state_21(+input: Nat) -> C.Machine:
  data_185(input)

def state_22(+input: Nat) -> C.Machine:
  data_189(input)

def state_23(+input: Nat) -> C.Machine:
  data_194(input)

def state_24(+input: Nat) -> C.Machine:
  data_198(input)

def state_25(+input: Nat) -> C.Machine:
  data_204(input)

def state_26(+input: Nat) -> C.Machine:
  data_210(input)

def state_27(+input: Nat) -> C.Machine:
  data_214(input)

def state_28(+input: Nat) -> C.Machine:
  data_216(input)

def state_29(+input: Nat) -> C.Machine:
  data_218(input)

def state_30(+input: Nat) -> C.Machine:
  data_221(input)

def state_31(+input: Nat) -> C.Machine:
  data_223(input)

def state_32(+input: Nat) -> C.Machine:
  data_227(input)

def state_33(+input: Nat) -> C.Machine:
  data_230(input)

def state_34(+input: Nat) -> C.Machine:
  data_233(input)

def state_35(+input: Nat) -> C.Machine:
  data_235(input)

def state_36(+input: Nat) -> C.Machine:
  data_239(input)

def state_37(+input: Nat) -> C.Machine:
  data_242(input)

def state_38(+input: Nat) -> C.Machine:
  data_244(input)

def state_39(+input: Nat) -> C.Machine:
  data_247(input)

def state_40(+input: Nat) -> C.Machine:
  data_249(input)

def finalWorld(+input: Nat) -> R.World:
  data_245(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
