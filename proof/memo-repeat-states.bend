# Canonical data from the actual emitted core.step. The equations in
# memo-staging check it for arbitrary proposals; generation is not trusted.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-repeat-driver.bend as Driver
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

def data_10(+first: Nat) -> R.Value:
  R.Number{first}

def data_11() -> R.Stamp:
  R.Stamped{2n}

def data_12(+first: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_2(), False{}, 0, 0, 0, 0n, data_11(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_13() -> R.NodeKind:
  R.Memo{}

def data_14(+first: Nat) -> R.Value:
  R.Number{Nat.add(first, 1n)}

def data_15() -> R.Expr:
  R.Read{2n}

def data_16() -> R.Value:
  R.Number{1n}

def data_17() -> R.Expr:
  R.Literal{data_16()}

def data_18() -> R.Expr:
  R.Add{data_15(), data_17()}

def data_19(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_20(+first: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_12(first), data_19(first)]

def data_21() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_22() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_23() -> List<&2, R.Link>:
  [data_21(), data_22()]

def data_24() -> List<&2, Nat>:
  [0n]

def data_25() -> List<&2, Nat>:
  []

def data_26() -> List<&2, R.QueueEntry>:
  []

def data_27() -> R.TreeNode:
  R.TreeNode{0n, data_25(), data_1()}

def data_28() -> List<&2, R.TreeNode>:
  [data_27(), data_27()]

def data_29() -> R.TraceEvent:
  R.Invoked{3n}

def data_30() -> R.Value:
  R.Number{0n}

def data_31() -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_30()}

def data_32() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_33(+first: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10(first)}

def data_34(+first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(), data_32(), data_29(), data_33(first)]

def data_35() -> R.Fault:
  R.Healthy{}

def data_36() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_37() -> R.Question:
  R.QuestionZero{}

def data_38() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_36(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_37(), data_2(), 0n, data_1()}

def data_39() -> List<&2, R.NodeExtension>:
  [data_38()]

def data_40() -> List<&2, R.CleanupAction>:
  []

def data_41() -> R.CleanupProgram:
  R.CleanupProgram{data_40(), False{}}

def data_42() -> List<&2, R.CleanupProgram>:
  [data_41()]

def data_43() -> List<&2, R.Report>:
  []

def data_44() -> R.OptionalIds:
  R.NoIds{}

def data_45() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_44()}

def data_46() -> List<&2, R.Transaction>:
  [data_45()]

def data_47() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_48() -> R.AsyncSettlement:
  R.Unresolved{}

def data_49() -> R.AsyncObject:
  R.AsyncObject{False{}, data_48(), data_25(), 0n}

def data_50() -> List<&2, R.AsyncObject>:
  [data_49()]

def data_51() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_52() -> List<&2, R.AsyncObserver>:
  [data_51()]

def data_53() -> R.HostJob:
  R.FlushJob{}

def data_54() -> List<&2, R.HostJob>:
  [data_53()]

def data_55() -> List<&2, R.NextInput>:
  []

def data_56() -> R.StreamPlan:
  R.StreamPlan{data_55(), False{}, data_2(), 0n}

def data_57() -> List<&2, R.StreamPlan>:
  [data_56()]

def data_58() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_59() -> List<&2, R.ExternalIterator>:
  [data_58()]

def data_60() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_61() -> List<&2, R.StreamState>:
  [data_60()]

def data_62() -> List<&2, R.IteratorEvent>:
  []

def data_63() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_48(), False{}, 0n, False{}, False{}, 0n}

def data_64() -> List<&2, R.Awaiter>:
  [data_63()]

def data_65() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_66() -> List<&2, R.AbortInput>:
  [data_65()]

def data_67() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_68() -> List<&2, R.ContextKey>:
  [data_67()]

def data_69() -> List<&2, R.ContextEntry>:
  []

def data_70() -> R.ContextRecord:
  R.ContextRecord{data_69()}

def data_71() -> List<&2, R.ContextRecord>:
  [data_70()]

def data_72() -> List<&2, R.Expr>:
  [data_4()]

def data_73() -> List<&2, R.ReactionState>:
  []

def data_74() -> List<&2, R.ComparatorBinding>:
  []

def data_75() -> List<&2, R.ActionState>:
  []

def data_76() -> List<&2, R.ActionWait>:
  []

def data_77(+first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_54(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_78(+input: Nat) -> R.Value:
  R.Number{input}

def data_79(+input: Nat) -> R.Slot:
  R.Present{data_78(input)}

def data_80() -> R.Stamp:
  R.Stamped{3n}

def data_81(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_79(input), False{}, 0, 0, 0, 0n, data_80(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_82(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_83(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_82(first)]

def data_84() -> List<&2, Nat>:
  [3n]

def data_85() -> List<&2, Nat>:
  [2n]

def data_86() -> List<&2, R.HostJob>:
  [data_53(), data_53()]

def data_87(+first: Nat, +input: Nat) -> R.World:
  R.World{data_83(first, input), data_23(), data_84(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(first), data_35(), True{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_88() -> C.Task:
  C.Round{}

def data_89() -> List<&2, C.Task>:
  [data_88()]

def data_90() -> List<&2, R.Value>:
  []

def data_91(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_87(first, input), data_89(), data_90()}

def data_92(+first: Nat, +input: Nat) -> R.World:
  R.World{data_83(first, input), data_23(), data_84(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_93() -> C.Task:
  C.RoundAfterSweep{}

def data_94() -> C.Task:
  C.FlushFinally{}

def data_95() -> C.Task:
  C.RoundEnd{}

def data_96() -> List<&2, C.Task>:
  [data_93(), data_94(), data_95()]

def data_97(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_92(first, input), data_96(), data_90()}

def data_98() -> C.Task:
  C.HeapLoop{}

def data_99() -> List<&2, C.Task>:
  [data_98(), data_94(), data_95()]

def data_100(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_92(first, input), data_99(), data_90()}

def data_101() -> C.Task:
  C.Recompute{3n, False{}}

def data_102() -> List<&2, C.Task>:
  [data_101(), data_98(), data_94(), data_95()]

def data_103(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_92(first, input), data_102(), data_90()}

def data_104(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_19(first)]

def data_105(+first: Nat, +input: Nat) -> R.World:
  R.World{data_104(first, input), data_23(), data_24(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_106() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_107() -> List<&2, C.Task>:
  [data_106(), data_98(), data_94(), data_95()]

def data_108(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_105(first, input), data_107(), data_90()}

def data_109() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_110() -> List<&2, C.Task>:
  [data_109(), data_98(), data_94(), data_95()]

def data_111(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_105(first, input), data_110(), data_90()}

def data_112(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_113(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_112(first)]

def data_114(+first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(), data_32(), data_29(), data_33(first), data_29()]

def data_115(+first: Nat, +input: Nat) -> R.World:
  R.World{data_113(first, input), data_23(), data_24(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_114(first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_116(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_117(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, 0n, data_90(), 0n, False{}}

def data_118(+first: Nat) -> C.Task:
  C.Finish{data_117(first)}

def data_119(+first: Nat) -> List<&2, C.Task>:
  [data_116(first), data_118(first), data_98(), data_94(), data_95()]

def data_120(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_115(first, input), data_119(first), data_90()}

def data_121(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_122(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_123() -> C.Task:
  C.Binary{0}

def data_124(+first: Nat) -> List<&2, C.Task>:
  [data_121(first), data_122(first), data_123(), data_118(first), data_98(), data_94(), data_95()]

def data_125(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_115(first, input), data_124(first), data_90()}

def data_126() -> C.Task:
  C.ReadNode{2n}

def data_127(+first: Nat) -> List<&2, C.Task>:
  [data_126(), data_122(first), data_123(), data_118(first), data_98(), data_94(), data_95()]

def data_128(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_115(first, input), data_127(first), data_90()}

def data_129() -> C.Task:
  C.ReadPrepared{2n}

def data_130(+first: Nat) -> List<&2, C.Task>:
  [data_129(), data_122(first), data_123(), data_118(first), data_98(), data_94(), data_95()]

def data_131(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_115(first, input), data_130(first), data_90()}

def data_132(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_133(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_132(first)]

def data_134() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_135() -> List<&2, R.Link>:
  [data_21(), data_134()]

def data_136(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_78(input)}

def data_137(+first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(), data_32(), data_29(), data_33(first), data_29(), data_136(input)]

def data_138(+first: Nat, +input: Nat) -> R.World:
  R.World{data_133(first, input), data_135(), data_24(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_139(+first: Nat) -> List<&2, C.Task>:
  [data_122(first), data_123(), data_118(first), data_98(), data_94(), data_95()]

def data_140(+input: Nat) -> List<&2, R.Value>:
  [data_78(input)]

def data_141(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_138(first, input), data_139(first), data_140(input)}

def data_142(+first: Nat) -> List<&2, C.Task>:
  [data_123(), data_118(first), data_98(), data_94(), data_95()]

def data_143(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_78(input)]

def data_144(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_138(first, input), data_142(first), data_143(input)}

def data_145(+first: Nat) -> List<&2, C.Task>:
  [data_118(first), data_98(), data_94(), data_95()]

def data_146(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_147(+input: Nat) -> List<&2, R.Value>:
  [data_146(input)]

def data_148(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_138(first, input), data_145(first), data_147(input)}

def data_149(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_150(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_149(first)]

def data_151(+first: Nat, +input: Nat) -> R.World:
  R.World{data_150(first, input), data_135(), data_24(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_152(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_117(first), 0n, data_146(input), False{}, False{}, False{}, data_35()}

def data_153(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_152(first, input), data_98(), data_94(), data_95()]

def data_154(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_151(first, input), data_153(first, input), data_90()}

def data_155(+input: Nat) -> R.Slot:
  R.Present{data_146(input)}

def data_156(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_155(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_157(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_156(first, input)]

def data_158(+first: Nat, +input: Nat) -> R.World:
  R.World{data_157(first, input), data_135(), data_24(), 0n, 0n, False{}, data_85(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_159() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_160() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_161() -> List<&2, C.Task>:
  [data_159(), data_160(), data_98(), data_94(), data_95()]

def data_162(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(first, input), data_161(), data_90()}

def data_163() -> List<&2, C.Task>:
  [data_160(), data_98(), data_94(), data_95()]

def data_164(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(first, input), data_163(), data_90()}

def data_165() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_166() -> List<&2, C.Task>:
  [data_165(), data_98(), data_94(), data_95()]

def data_167(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(first, input), data_166(), data_90()}

def data_168(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_155(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_169(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(first, input), data_168(first, input)]

def data_170() -> List<&2, Nat>:
  [2n, 3n]

def data_171(+first: Nat, +input: Nat) -> R.World:
  R.World{data_169(first, input), data_135(), data_24(), 0n, 0n, False{}, data_170(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_172(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_171(first, input), data_99(), data_90()}

def data_173(+first: Nat, +input: Nat) -> R.World:
  R.World{data_169(first, input), data_135(), data_24(), 1n, 0n, False{}, data_170(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_174(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(first, input), data_99(), data_90()}

def data_175() -> C.Task:
  C.Seam{}

def data_176() -> List<&2, C.Task>:
  [data_175(), data_94(), data_95()]

def data_177(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(first, input), data_176(), data_90()}

def data_178() -> C.Task:
  C.Settle{}

def data_179() -> C.Task:
  C.AfterSettle{}

def data_180() -> List<&2, C.Task>:
  [data_178(), data_179(), data_94(), data_95()]

def data_181(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(first, input), data_180(), data_90()}

def data_182() -> C.Task:
  C.CommitIntake{0n}

def data_183() -> C.Task:
  C.TrimIntake{0n}

def data_184() -> C.Task:
  C.FinishSettleIntake{0n}

def data_185() -> List<&2, C.Task>:
  [data_182(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_186(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(first, input), data_185(), data_90()}

def data_187() -> C.Task:
  C.CommitPending{2n}

def data_188() -> C.Task:
  C.CommitIntake{1n}

def data_189() -> List<&2, C.Task>:
  [data_187(), data_188(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_190(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(first, input), data_189(), data_90()}

def data_191(+input: Nat) -> R.Node:
  R.Node{data_9(), data_78(input), data_2(), False{}, 0, 0, 0, 0n, data_80(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_192(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_191(input), data_168(first, input)]

def data_193(+first: Nat, +input: Nat) -> R.World:
  R.World{data_192(first, input), data_135(), data_24(), 1n, 0n, False{}, data_170(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_194() -> List<&2, C.Task>:
  [data_188(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_195(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(first, input), data_194(), data_90()}

def data_196() -> C.Task:
  C.CommitPending{3n}

def data_197() -> C.Task:
  C.CommitIntake{2n}

def data_198() -> List<&2, C.Task>:
  [data_196(), data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_199(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(first, input), data_198(), data_90()}

def data_200(+input: Nat) -> R.Node:
  R.Node{data_13(), data_146(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_201(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_191(input), data_200(input)]

def data_202(+first: Nat, +input: Nat) -> R.World:
  R.World{data_201(input), data_135(), data_24(), 1n, 0n, False{}, data_170(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_203() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_204() -> List<&2, C.Task>:
  [data_203(), data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_205(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_202(first, input), data_204(), data_90()}

def data_206() -> O.Task:
  O.TrimDeps{3n}

def data_207() -> List<&2, O.Task>:
  [data_206()]

def data_208() -> C.Task:
  C.OwnerTasks{data_207()}

def data_209() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_210() -> List<&2, C.Task>:
  [data_208(), data_209(), data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_211(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_202(first, input), data_210(), data_90()}

def data_212() -> List<&2, O.Task>:
  []

def data_213() -> C.Task:
  C.OwnerTasks{data_212()}

def data_214() -> List<&2, C.Task>:
  [data_213(), data_209(), data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_215(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_202(first, input), data_214(), data_90()}

def data_216() -> List<&2, C.Task>:
  [data_209(), data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_217(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_202(first, input), data_216(), data_90()}

def data_218() -> List<&2, C.Task>:
  [data_197(), data_183(), data_184(), data_179(), data_94(), data_95()]

def data_219(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_202(first, input), data_218(), data_90()}

def data_220(+first: Nat, +input: Nat) -> R.World:
  R.World{data_201(input), data_135(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_221() -> List<&2, C.Task>:
  [data_183(), data_184(), data_179(), data_94(), data_95()]

def data_222(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_221(), data_90()}

def data_223() -> List<&2, C.Task>:
  [data_184(), data_179(), data_94(), data_95()]

def data_224(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_223(), data_90()}

def data_225() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26()}

def data_226() -> C.Task:
  C.LandTransactions{data_225(), 0n}

def data_227() -> List<&2, C.Task>:
  [data_226(), data_179(), data_94(), data_95()]

def data_228(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_227(), data_90()}

def data_229() -> C.Task:
  C.CompleteSettle{data_225()}

def data_230() -> List<&2, C.Task>:
  [data_229(), data_179(), data_94(), data_95()]

def data_231(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_230(), data_90()}

def data_232() -> C.Task:
  C.ZombieLoop{data_25()}

def data_233() -> List<&2, C.Task>:
  [data_232(), data_179(), data_94(), data_95()]

def data_234(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_233(), data_90()}

def data_235() -> List<&2, C.Task>:
  [data_179(), data_94(), data_95()]

def data_236(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(first, input), data_235(), data_90()}

def data_237(+first: Nat, +input: Nat) -> R.World:
  R.World{data_201(input), data_135(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_238() -> C.Task:
  C.RenderQueue{}

def data_239() -> List<&2, C.Task>:
  [data_238(), data_94(), data_95()]

def data_240(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(first, input), data_239(), data_90()}

def data_241() -> C.Task:
  C.UserQueue{}

def data_242() -> List<&2, C.Task>:
  [data_241(), data_94(), data_95()]

def data_243(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(first, input), data_242(), data_90()}

def data_244() -> List<&2, C.Task>:
  [data_94(), data_95()]

def data_245(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(first, input), data_244(), data_90()}

def data_246(+first: Nat, +input: Nat) -> R.World:
  R.World{data_201(input), data_135(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_137(first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_86(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76()}

def data_247() -> List<&2, C.Task>:
  [data_95()]

def data_248(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_246(first, input), data_247(), data_90()}

def data_249() -> List<&2, C.Task>:
  []

def data_250(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_246(first, input), data_249(), data_90()}

def origin(+first: Nat) -> R.World:
  data_77(first)

def state_0(+first: Nat, +input: Nat) -> C.Machine:
  data_91(first, input)

def state_1(+first: Nat, +input: Nat) -> C.Machine:
  data_97(first, input)

def state_2(+first: Nat, +input: Nat) -> C.Machine:
  data_100(first, input)

def state_3(+first: Nat, +input: Nat) -> C.Machine:
  data_103(first, input)

def state_4(+first: Nat, +input: Nat) -> C.Machine:
  data_108(first, input)

def state_5(+first: Nat, +input: Nat) -> C.Machine:
  data_111(first, input)

def state_6(+first: Nat, +input: Nat) -> C.Machine:
  data_120(first, input)

def state_7(+first: Nat, +input: Nat) -> C.Machine:
  data_125(first, input)

def state_8(+first: Nat, +input: Nat) -> C.Machine:
  data_128(first, input)

def state_9(+first: Nat, +input: Nat) -> C.Machine:
  data_131(first, input)

def state_10(+first: Nat, +input: Nat) -> C.Machine:
  data_141(first, input)

def state_11(+first: Nat, +input: Nat) -> C.Machine:
  data_144(first, input)

def state_12(+first: Nat, +input: Nat) -> C.Machine:
  data_148(first, input)

def state_13(+first: Nat, +input: Nat) -> C.Machine:
  data_154(first, input)

def state_14(+first: Nat, +input: Nat) -> C.Machine:
  data_162(first, input)

def state_15(+first: Nat, +input: Nat) -> C.Machine:
  data_164(first, input)

def state_16(+first: Nat, +input: Nat) -> C.Machine:
  data_167(first, input)

def state_17(+first: Nat, +input: Nat) -> C.Machine:
  data_172(first, input)

def state_18(+first: Nat, +input: Nat) -> C.Machine:
  data_174(first, input)

def state_19(+first: Nat, +input: Nat) -> C.Machine:
  data_177(first, input)

def state_20(+first: Nat, +input: Nat) -> C.Machine:
  data_181(first, input)

def state_21(+first: Nat, +input: Nat) -> C.Machine:
  data_186(first, input)

def state_22(+first: Nat, +input: Nat) -> C.Machine:
  data_190(first, input)

def state_23(+first: Nat, +input: Nat) -> C.Machine:
  data_195(first, input)

def state_24(+first: Nat, +input: Nat) -> C.Machine:
  data_199(first, input)

def state_25(+first: Nat, +input: Nat) -> C.Machine:
  data_205(first, input)

def state_26(+first: Nat, +input: Nat) -> C.Machine:
  data_211(first, input)

def state_27(+first: Nat, +input: Nat) -> C.Machine:
  data_215(first, input)

def state_28(+first: Nat, +input: Nat) -> C.Machine:
  data_217(first, input)

def state_29(+first: Nat, +input: Nat) -> C.Machine:
  data_219(first, input)

def state_30(+first: Nat, +input: Nat) -> C.Machine:
  data_222(first, input)

def state_31(+first: Nat, +input: Nat) -> C.Machine:
  data_224(first, input)

def state_32(+first: Nat, +input: Nat) -> C.Machine:
  data_228(first, input)

def state_33(+first: Nat, +input: Nat) -> C.Machine:
  data_231(first, input)

def state_34(+first: Nat, +input: Nat) -> C.Machine:
  data_234(first, input)

def state_35(+first: Nat, +input: Nat) -> C.Machine:
  data_236(first, input)

def state_36(+first: Nat, +input: Nat) -> C.Machine:
  data_240(first, input)

def state_37(+first: Nat, +input: Nat) -> C.Machine:
  data_243(first, input)

def state_38(+first: Nat, +input: Nat) -> C.Machine:
  data_245(first, input)

def state_39(+first: Nat, +input: Nat) -> C.Machine:
  data_248(first, input)

def state_40(+first: Nat, +input: Nat) -> C.Machine:
  data_250(first, input)

def finalWorld(+first: Nat, +input: Nat) -> R.World:
  data_246(first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
