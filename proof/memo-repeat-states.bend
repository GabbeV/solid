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

def data_77() -> List<&2, R.ArrayData>:
  []

def data_78() -> List<&2, R.RepeatState>:
  []

def data_79(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_54(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_80(+input: Nat) -> R.Value:
  R.Number{input}

def data_81(+input: Nat) -> R.Slot:
  R.Present{data_80(input)}

def data_82() -> R.Stamp:
  R.Stamped{3n}

def data_83(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_81(input), False{}, 0, 0, 0, 0n, data_82(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_84(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_85(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_84(first)]

def data_86() -> List<&2, Nat>:
  [3n]

def data_87() -> List<&2, Nat>:
  [2n]

def data_88() -> List<&2, R.HostJob>:
  [data_53(), data_53()]

def data_89(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_85(first, input), data_23(), data_86(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_90() -> C.Task:
  C.Round{}

def data_91() -> List<&2, C.Task>:
  [data_90()]

def data_92() -> List<&2, R.Value>:
  []

def data_93(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_89(initial, first, input), data_91(), data_92()}

def data_94(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_85(first, input), data_23(), data_86(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_95() -> C.Task:
  C.RoundAfterSweep{}

def data_96() -> C.Task:
  C.FlushFinally{}

def data_97() -> C.Task:
  C.RoundEnd{}

def data_98() -> List<&2, C.Task>:
  [data_95(), data_96(), data_97()]

def data_99(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_94(initial, first, input), data_98(), data_92()}

def data_100() -> C.Task:
  C.HeapLoop{}

def data_101() -> List<&2, C.Task>:
  [data_100(), data_96(), data_97()]

def data_102(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_94(initial, first, input), data_101(), data_92()}

def data_103() -> C.Task:
  C.Recompute{3n, False{}}

def data_104() -> List<&2, C.Task>:
  [data_103(), data_100(), data_96(), data_97()]

def data_105(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_94(initial, first, input), data_104(), data_92()}

def data_106(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_19(first)]

def data_107(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_106(first, input), data_23(), data_24(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_108() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_100(), data_96(), data_97()]

def data_110(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_107(initial, first, input), data_109(), data_92()}

def data_111() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_112() -> List<&2, C.Task>:
  [data_111(), data_100(), data_96(), data_97()]

def data_113(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_107(initial, first, input), data_112(), data_92()}

def data_114(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_115(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_114(first)]

def data_116(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_117(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_115(first, input), data_23(), data_24(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_116(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_118(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_119(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, 0n, data_92(), 0n, False{}}

def data_120(+first: Nat) -> C.Task:
  C.Finish{data_119(first)}

def data_121(+first: Nat) -> List<&2, C.Task>:
  [data_118(first), data_120(first), data_100(), data_96(), data_97()]

def data_122(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_117(initial, first, input), data_121(first), data_92()}

def data_123(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_124(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_125() -> C.Task:
  C.Binary{0}

def data_126(+first: Nat) -> List<&2, C.Task>:
  [data_123(first), data_124(first), data_125(), data_120(first), data_100(), data_96(), data_97()]

def data_127(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_117(initial, first, input), data_126(first), data_92()}

def data_128() -> C.Task:
  C.ReadNode{2n}

def data_129(+first: Nat) -> List<&2, C.Task>:
  [data_128(), data_124(first), data_125(), data_120(first), data_100(), data_96(), data_97()]

def data_130(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_117(initial, first, input), data_129(first), data_92()}

def data_131() -> C.Task:
  C.ReadPrepared{2n}

def data_132(+first: Nat) -> List<&2, C.Task>:
  [data_131(), data_124(first), data_125(), data_120(first), data_100(), data_96(), data_97()]

def data_133(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_117(initial, first, input), data_132(first), data_92()}

def data_134(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_135(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_134(first)]

def data_136() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_137() -> List<&2, R.Link>:
  [data_21(), data_136()]

def data_138(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_80(input)}

def data_139(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_138(input)]

def data_140(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_135(first, input), data_137(), data_24(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_141(+first: Nat) -> List<&2, C.Task>:
  [data_124(first), data_125(), data_120(first), data_100(), data_96(), data_97()]

def data_142(+input: Nat) -> List<&2, R.Value>:
  [data_80(input)]

def data_143(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_140(initial, first, input), data_141(first), data_142(input)}

def data_144(+first: Nat) -> List<&2, C.Task>:
  [data_125(), data_120(first), data_100(), data_96(), data_97()]

def data_145(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_80(input)]

def data_146(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_140(initial, first, input), data_144(first), data_145(input)}

def data_147(+first: Nat) -> List<&2, C.Task>:
  [data_120(first), data_100(), data_96(), data_97()]

def data_148(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_149(+input: Nat) -> List<&2, R.Value>:
  [data_148(input)]

def data_150(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_140(initial, first, input), data_147(first), data_149(input)}

def data_151(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_152(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_151(first)]

def data_153(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_152(first, input), data_137(), data_24(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_154(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_119(first), 0n, data_148(input), False{}, False{}, False{}, data_35()}

def data_155(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_154(first, input), data_100(), data_96(), data_97()]

def data_156(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_153(initial, first, input), data_155(first, input), data_92()}

def data_157(+input: Nat) -> R.Slot:
  R.Present{data_148(input)}

def data_158(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_157(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_159(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_158(first, input)]

def data_160(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_159(first, input), data_137(), data_24(), 0n, 0n, False{}, data_87(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_161() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_162() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_163() -> List<&2, C.Task>:
  [data_161(), data_162(), data_100(), data_96(), data_97()]

def data_164(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_160(initial, first, input), data_163(), data_92()}

def data_165() -> List<&2, C.Task>:
  [data_162(), data_100(), data_96(), data_97()]

def data_166(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_160(initial, first, input), data_165(), data_92()}

def data_167() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_168() -> List<&2, C.Task>:
  [data_167(), data_100(), data_96(), data_97()]

def data_169(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_160(initial, first, input), data_168(), data_92()}

def data_170(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_157(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_171(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_83(first, input), data_170(first, input)]

def data_172() -> List<&2, Nat>:
  [2n, 3n]

def data_173(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_171(first, input), data_137(), data_24(), 0n, 0n, False{}, data_172(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_174(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(initial, first, input), data_101(), data_92()}

def data_175(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_171(first, input), data_137(), data_24(), 1n, 0n, False{}, data_172(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_176(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, first, input), data_101(), data_92()}

def data_177() -> C.Task:
  C.Seam{}

def data_178() -> List<&2, C.Task>:
  [data_177(), data_96(), data_97()]

def data_179(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, first, input), data_178(), data_92()}

def data_180() -> C.Task:
  C.Settle{}

def data_181() -> C.Task:
  C.AfterSettle{}

def data_182() -> List<&2, C.Task>:
  [data_180(), data_181(), data_96(), data_97()]

def data_183(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, first, input), data_182(), data_92()}

def data_184() -> C.Task:
  C.CommitIntake{0n}

def data_185() -> C.Task:
  C.TrimIntake{0n}

def data_186() -> C.Task:
  C.FinishSettleIntake{0n}

def data_187() -> List<&2, C.Task>:
  [data_184(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_188(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, first, input), data_187(), data_92()}

def data_189() -> C.Task:
  C.CommitPending{2n}

def data_190() -> C.Task:
  C.CommitIntake{1n}

def data_191() -> List<&2, C.Task>:
  [data_189(), data_190(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_192(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, first, input), data_191(), data_92()}

def data_193(+input: Nat) -> R.Node:
  R.Node{data_9(), data_80(input), data_2(), False{}, 0, 0, 0, 0n, data_82(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_194(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_193(input), data_170(first, input)]

def data_195(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_194(first, input), data_137(), data_24(), 1n, 0n, False{}, data_172(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_196() -> List<&2, C.Task>:
  [data_190(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_197(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_195(initial, first, input), data_196(), data_92()}

def data_198() -> C.Task:
  C.CommitPending{3n}

def data_199() -> C.Task:
  C.CommitIntake{2n}

def data_200() -> List<&2, C.Task>:
  [data_198(), data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_201(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_195(initial, first, input), data_200(), data_92()}

def data_202(+input: Nat) -> R.Node:
  R.Node{data_13(), data_148(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_203(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_193(input), data_202(input)]

def data_204(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_203(input), data_137(), data_24(), 1n, 0n, False{}, data_172(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_205() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_206() -> List<&2, C.Task>:
  [data_205(), data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_207(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_204(initial, first, input), data_206(), data_92()}

def data_208() -> O.Task:
  O.TrimDeps{3n}

def data_209() -> List<&2, O.Task>:
  [data_208()]

def data_210() -> C.Task:
  C.OwnerTasks{data_209()}

def data_211() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_212() -> List<&2, C.Task>:
  [data_210(), data_211(), data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_213(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_204(initial, first, input), data_212(), data_92()}

def data_214() -> List<&2, O.Task>:
  []

def data_215() -> C.Task:
  C.OwnerTasks{data_214()}

def data_216() -> List<&2, C.Task>:
  [data_215(), data_211(), data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_217(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_204(initial, first, input), data_216(), data_92()}

def data_218() -> List<&2, C.Task>:
  [data_211(), data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_219(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_204(initial, first, input), data_218(), data_92()}

def data_220() -> List<&2, C.Task>:
  [data_199(), data_185(), data_186(), data_181(), data_96(), data_97()]

def data_221(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_204(initial, first, input), data_220(), data_92()}

def data_222(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_203(input), data_137(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_223() -> List<&2, C.Task>:
  [data_185(), data_186(), data_181(), data_96(), data_97()]

def data_224(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_223(), data_92()}

def data_225() -> List<&2, C.Task>:
  [data_186(), data_181(), data_96(), data_97()]

def data_226(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_225(), data_92()}

def data_227() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26()}

def data_228() -> C.Task:
  C.LandTransactions{data_227(), 0n}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_181(), data_96(), data_97()]

def data_230(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_229(), data_92()}

def data_231() -> C.Task:
  C.CompleteSettle{data_227()}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_181(), data_96(), data_97()]

def data_233(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_232(), data_92()}

def data_234() -> C.Task:
  C.ZombieLoop{data_25()}

def data_235() -> List<&2, C.Task>:
  [data_234(), data_181(), data_96(), data_97()]

def data_236(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_235(), data_92()}

def data_237() -> List<&2, C.Task>:
  [data_181(), data_96(), data_97()]

def data_238(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_237(), data_92()}

def data_239(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_203(input), data_137(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_240() -> C.Task:
  C.RenderQueue{}

def data_241() -> List<&2, C.Task>:
  [data_240(), data_96(), data_97()]

def data_242(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, first, input), data_241(), data_92()}

def data_243() -> C.Task:
  C.UserQueue{}

def data_244() -> List<&2, C.Task>:
  [data_243(), data_96(), data_97()]

def data_245(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, first, input), data_244(), data_92()}

def data_246() -> List<&2, C.Task>:
  [data_96(), data_97()]

def data_247(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, first, input), data_246(), data_92()}

def data_248(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_203(input), data_137(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_139(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_88(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78()}

def data_249() -> List<&2, C.Task>:
  [data_97()]

def data_250(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_248(initial, first, input), data_249(), data_92()}

def data_251() -> List<&2, C.Task>:
  []

def data_252(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_248(initial, first, input), data_251(), data_92()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_79(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_93(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_99(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_102(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_105(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_110(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_113(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_122(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_127(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_130(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_133(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_143(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_146(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_150(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_156(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_164(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_166(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_169(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_174(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_176(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_179(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_183(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_188(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_192(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_197(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_201(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_207(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_213(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_217(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_219(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_221(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_224(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_226(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_230(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_233(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_236(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_238(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_242(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_245(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_247(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_250(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_252(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_248(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
