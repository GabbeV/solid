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

def data_30(+initial: Nat) -> R.Value:
  R.Number{initial}

def data_31(+initial: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_30(initial)}

def data_32() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_33(+first: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10(first)}

def data_34(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first)]

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
  R.CleanupProgram{data_40(), False{}, 0n}

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

def data_77() -> List<&2, R.ArrayData>:
  []

def data_78() -> List<&2, R.RepeatState>:
  []

def data_79() -> List<&2, R.MapState>:
  []

def data_80() -> R.LaneState:
  R.LaneState{data_25(), data_47(), data_25()}

def data_81() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_82(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_54(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_83(+input: Nat) -> R.Value:
  R.Number{input}

def data_84(+input: Nat) -> R.Slot:
  R.Present{data_83(input)}

def data_85() -> R.Stamp:
  R.Stamped{3n}

def data_86(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_84(input), False{}, 0, 0, 0, 0n, data_85(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_87(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_88(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_87(first)]

def data_89() -> List<&2, Nat>:
  [3n]

def data_90() -> List<&2, Nat>:
  [2n]

def data_91() -> List<&2, R.HostJob>:
  [data_53(), data_53()]

def data_92(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_88(first, input), data_23(), data_89(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_93() -> C.Task:
  C.Round{}

def data_94() -> List<&2, C.Task>:
  [data_93()]

def data_95() -> List<&2, R.Value>:
  []

def data_96(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_92(initial, first, input), data_94(), data_95()}

def data_97(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_88(first, input), data_23(), data_89(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_98() -> C.Task:
  C.RoundAfterSweep{}

def data_99() -> C.Task:
  C.FlushFinally{}

def data_100() -> C.Task:
  C.RoundEnd{}

def data_101() -> List<&2, C.Task>:
  [data_98(), data_99(), data_100()]

def data_102(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_97(initial, first, input), data_101(), data_95()}

def data_103() -> C.Task:
  C.HeapLoop{}

def data_104() -> List<&2, C.Task>:
  [data_103(), data_99(), data_100()]

def data_105(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_97(initial, first, input), data_104(), data_95()}

def data_106() -> C.Task:
  C.Recompute{3n, False{}}

def data_107() -> List<&2, C.Task>:
  [data_106(), data_103(), data_99(), data_100()]

def data_108(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_97(initial, first, input), data_107(), data_95()}

def data_109(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_19(first)]

def data_110(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_109(first, input), data_23(), data_24(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_111() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_112() -> List<&2, C.Task>:
  [data_111(), data_103(), data_99(), data_100()]

def data_113(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_110(initial, first, input), data_112(), data_95()}

def data_114() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_115() -> List<&2, C.Task>:
  [data_114(), data_103(), data_99(), data_100()]

def data_116(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_110(initial, first, input), data_115(), data_95()}

def data_117(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_118(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_117(first)]

def data_119(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_120(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_118(first, input), data_23(), data_24(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_119(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_121(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_122(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, 0n, data_95(), 0n, False{}}

def data_123(+first: Nat) -> C.Task:
  C.Finish{data_122(first)}

def data_124(+first: Nat) -> List<&2, C.Task>:
  [data_121(first), data_123(first), data_103(), data_99(), data_100()]

def data_125(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, first, input), data_124(first), data_95()}

def data_126(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_127(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_128() -> C.Task:
  C.Binary{0}

def data_129(+first: Nat) -> List<&2, C.Task>:
  [data_126(first), data_127(first), data_128(), data_123(first), data_103(), data_99(), data_100()]

def data_130(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, first, input), data_129(first), data_95()}

def data_131() -> C.Task:
  C.ReadNode{2n}

def data_132(+first: Nat) -> List<&2, C.Task>:
  [data_131(), data_127(first), data_128(), data_123(first), data_103(), data_99(), data_100()]

def data_133(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, first, input), data_132(first), data_95()}

def data_134() -> C.Task:
  C.ReadPrepared{2n}

def data_135(+first: Nat) -> List<&2, C.Task>:
  [data_134(), data_127(first), data_128(), data_123(first), data_103(), data_99(), data_100()]

def data_136(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, first, input), data_135(first), data_95()}

def data_137(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_138(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_137(first)]

def data_139() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_140() -> List<&2, R.Link>:
  [data_21(), data_139()]

def data_141(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_83(input)}

def data_142(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_141(input)]

def data_143(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_138(first, input), data_140(), data_24(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_144(+first: Nat) -> List<&2, C.Task>:
  [data_127(first), data_128(), data_123(first), data_103(), data_99(), data_100()]

def data_145(+input: Nat) -> List<&2, R.Value>:
  [data_83(input)]

def data_146(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_143(initial, first, input), data_144(first), data_145(input)}

def data_147(+first: Nat) -> List<&2, C.Task>:
  [data_128(), data_123(first), data_103(), data_99(), data_100()]

def data_148(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_83(input)]

def data_149(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_143(initial, first, input), data_147(first), data_148(input)}

def data_150(+first: Nat) -> List<&2, C.Task>:
  [data_123(first), data_103(), data_99(), data_100()]

def data_151(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_152(+input: Nat) -> List<&2, R.Value>:
  [data_151(input)]

def data_153(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_143(initial, first, input), data_150(first), data_152(input)}

def data_154(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_155(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_154(first)]

def data_156(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_155(first, input), data_140(), data_24(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_157(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_122(first), 0n, data_151(input), False{}, False{}, False{}, data_35()}

def data_158(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_157(first, input), data_103(), data_99(), data_100()]

def data_159(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_156(initial, first, input), data_158(first, input), data_95()}

def data_160(+input: Nat) -> R.Slot:
  R.Present{data_151(input)}

def data_161(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_160(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_162(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_161(first, input)]

def data_163(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_162(first, input), data_140(), data_24(), 0n, 0n, False{}, data_90(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_164() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_165() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_166() -> List<&2, C.Task>:
  [data_164(), data_165(), data_103(), data_99(), data_100()]

def data_167(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_163(initial, first, input), data_166(), data_95()}

def data_168() -> List<&2, C.Task>:
  [data_165(), data_103(), data_99(), data_100()]

def data_169(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_163(initial, first, input), data_168(), data_95()}

def data_170() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_171() -> List<&2, C.Task>:
  [data_170(), data_103(), data_99(), data_100()]

def data_172(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_163(initial, first, input), data_171(), data_95()}

def data_173(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_160(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_174(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_86(first, input), data_173(first, input)]

def data_175() -> List<&2, Nat>:
  [2n, 3n]

def data_176(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_174(first, input), data_140(), data_24(), 0n, 0n, False{}, data_175(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_177(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_176(initial, first, input), data_104(), data_95()}

def data_178(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_174(first, input), data_140(), data_24(), 1n, 0n, False{}, data_175(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_179(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_104(), data_95()}

def data_180() -> C.Task:
  C.Seam{}

def data_181() -> List<&2, C.Task>:
  [data_180(), data_99(), data_100()]

def data_182(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_181(), data_95()}

def data_183() -> C.Task:
  C.Settle{}

def data_184() -> C.Task:
  C.AfterSettle{}

def data_185() -> List<&2, C.Task>:
  [data_183(), data_184(), data_99(), data_100()]

def data_186(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_185(), data_95()}

def data_187() -> C.Task:
  C.CommitIntake{0n}

def data_188() -> C.Task:
  C.TrimIntake{0n}

def data_189() -> C.Task:
  C.FinishSettleIntake{0n}

def data_190() -> List<&2, C.Task>:
  [data_187(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_191(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_190(), data_95()}

def data_192() -> C.Task:
  C.CommitPending{2n}

def data_193() -> C.Task:
  C.CommitIntake{1n}

def data_194() -> List<&2, C.Task>:
  [data_192(), data_193(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_195(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_194(), data_95()}

def data_196(+input: Nat) -> R.Node:
  R.Node{data_9(), data_83(input), data_2(), False{}, 0, 0, 0, 0n, data_85(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_197(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_196(input), data_173(first, input)]

def data_198(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_197(first, input), data_140(), data_24(), 1n, 0n, False{}, data_175(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_199() -> List<&2, C.Task>:
  [data_193(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_200(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_198(initial, first, input), data_199(), data_95()}

def data_201() -> C.Task:
  C.CommitPending{3n}

def data_202() -> C.Task:
  C.CommitIntake{2n}

def data_203() -> List<&2, C.Task>:
  [data_201(), data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_204(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_198(initial, first, input), data_203(), data_95()}

def data_205(+input: Nat) -> R.Node:
  R.Node{data_13(), data_151(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_206(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_196(input), data_205(input)]

def data_207(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_206(input), data_140(), data_24(), 1n, 0n, False{}, data_175(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_208() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_209() -> List<&2, C.Task>:
  [data_208(), data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_210(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_207(initial, first, input), data_209(), data_95()}

def data_211() -> O.Task:
  O.TrimDeps{3n}

def data_212() -> List<&2, O.Task>:
  [data_211()]

def data_213() -> C.Task:
  C.OwnerTasks{data_212()}

def data_214() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_215() -> List<&2, C.Task>:
  [data_213(), data_214(), data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_216(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_207(initial, first, input), data_215(), data_95()}

def data_217() -> List<&2, O.Task>:
  []

def data_218() -> C.Task:
  C.OwnerTasks{data_217()}

def data_219() -> List<&2, C.Task>:
  [data_218(), data_214(), data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_220(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_207(initial, first, input), data_219(), data_95()}

def data_221() -> List<&2, C.Task>:
  [data_214(), data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_222(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_207(initial, first, input), data_221(), data_95()}

def data_223() -> List<&2, C.Task>:
  [data_202(), data_188(), data_189(), data_184(), data_99(), data_100()]

def data_224(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_207(initial, first, input), data_223(), data_95()}

def data_225(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_206(input), data_140(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_226() -> List<&2, C.Task>:
  [data_188(), data_189(), data_184(), data_99(), data_100()]

def data_227(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_226(), data_95()}

def data_228() -> List<&2, C.Task>:
  [data_189(), data_184(), data_99(), data_100()]

def data_229(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_228(), data_95()}

def data_230() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26()}

def data_231() -> C.Task:
  C.LandTransactions{data_230(), 0n}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_184(), data_99(), data_100()]

def data_233(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_232(), data_95()}

def data_234() -> C.Task:
  C.CompleteSettle{data_230()}

def data_235() -> List<&2, C.Task>:
  [data_234(), data_184(), data_99(), data_100()]

def data_236(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_235(), data_95()}

def data_237() -> C.Task:
  C.ZombieLoop{data_25()}

def data_238() -> List<&2, C.Task>:
  [data_237(), data_184(), data_99(), data_100()]

def data_239(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_238(), data_95()}

def data_240() -> List<&2, C.Task>:
  [data_184(), data_99(), data_100()]

def data_241(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_240(), data_95()}

def data_242(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_206(input), data_140(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_243() -> C.Task:
  C.RenderQueue{}

def data_244() -> List<&2, C.Task>:
  [data_243(), data_99(), data_100()]

def data_245(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_242(initial, first, input), data_244(), data_95()}

def data_246() -> C.Task:
  C.UserQueue{}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_99(), data_100()]

def data_248(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_242(initial, first, input), data_247(), data_95()}

def data_249() -> List<&2, C.Task>:
  [data_99(), data_100()]

def data_250(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_242(initial, first, input), data_249(), data_95()}

def data_251(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_206(input), data_140(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_142(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_91(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_80(), data_81()}

def data_252() -> List<&2, C.Task>:
  [data_100()]

def data_253(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_251(initial, first, input), data_252(), data_95()}

def data_254() -> List<&2, C.Task>:
  []

def data_255(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_251(initial, first, input), data_254(), data_95()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_82(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_96(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_102(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_105(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_108(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_113(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_116(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_125(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_130(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_133(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_136(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_146(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_149(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_153(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_159(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_167(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_169(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_172(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_177(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_179(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_182(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_186(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_191(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_195(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_200(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_204(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_210(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_216(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_220(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_222(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_224(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_227(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_229(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_233(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_236(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_239(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_241(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_245(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_248(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_250(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_253(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_255(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_251(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
