# Canonical data from the actual emitted core.step. The equations in
# memo-staging check it for arbitrary proposals; generation is not trusted.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-general-driver.bend as Driver
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

def data_10(+initial: Nat) -> R.Value:
  R.Number{initial}

def data_11(+initial: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_12() -> R.NodeKind:
  R.Memo{}

def data_13(+initial: Nat) -> R.Value:
  R.Number{Nat.add(initial, 1n)}

def data_14() -> R.Expr:
  R.Read{2n}

def data_15() -> R.Value:
  R.Number{1n}

def data_16() -> R.Expr:
  R.Literal{data_15()}

def data_17() -> R.Expr:
  R.Add{data_14(), data_16()}

def data_18(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_19(+initial: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_11(initial), data_18(initial)]

def data_20() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_21() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 1n}

def data_22() -> List<&2, R.Link>:
  [data_20(), data_21()]

def data_23() -> List<&2, Nat>:
  [0n]

def data_24() -> List<&2, Nat>:
  []

def data_25() -> List<&2, R.QueueEntry>:
  []

def data_26() -> R.TreeNode:
  R.TreeNode{0n, data_24(), data_1()}

def data_27() -> List<&2, R.TreeNode>:
  [data_26(), data_26()]

def data_28() -> R.TraceEvent:
  R.Invoked{3n}

def data_29(+initial: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10(initial)}

def data_30() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_31(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30()]

def data_32() -> R.Fault:
  R.Healthy{}

def data_33() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_34() -> R.Question:
  R.QuestionZero{}

def data_35() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_33(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_34(), data_2(), 0n, data_1()}

def data_36() -> List<&2, R.NodeExtension>:
  [data_35()]

def data_37() -> List<&2, R.CleanupAction>:
  []

def data_38() -> R.CleanupProgram:
  R.CleanupProgram{data_37(), False{}, 0n}

def data_39() -> List<&2, R.CleanupProgram>:
  [data_38()]

def data_40() -> List<&2, R.Report>:
  []

def data_41() -> R.OptionalIds:
  R.NoIds{}

def data_42() -> R.Transaction:
  R.Transaction{data_24(), data_24(), data_25(), data_24(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_41()}

def data_43() -> List<&2, R.Transaction>:
  [data_42()]

def data_44() -> List<&2, List<&2, Nat>>:
  [data_24()]

def data_45() -> R.AsyncSettlement:
  R.Unresolved{}

def data_46() -> R.AsyncObject:
  R.AsyncObject{False{}, data_45(), data_24(), 0n}

def data_47() -> List<&2, R.AsyncObject>:
  [data_46()]

def data_48() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_49() -> List<&2, R.AsyncObserver>:
  [data_48()]

def data_50() -> List<&2, R.HostJob>:
  []

def data_51() -> List<&2, R.NextInput>:
  []

def data_52() -> R.StreamPlan:
  R.StreamPlan{data_51(), False{}, data_2(), 0n}

def data_53() -> List<&2, R.StreamPlan>:
  [data_52()]

def data_54() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_55() -> List<&2, R.ExternalIterator>:
  [data_54()]

def data_56() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_57() -> List<&2, R.StreamState>:
  [data_56()]

def data_58() -> List<&2, R.IteratorEvent>:
  []

def data_59() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_45(), False{}, 0n, False{}, False{}, 0n}

def data_60() -> List<&2, R.Awaiter>:
  [data_59()]

def data_61() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_62() -> List<&2, R.AbortInput>:
  [data_61()]

def data_63() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_64() -> List<&2, R.ContextKey>:
  [data_63()]

def data_65() -> List<&2, R.ContextEntry>:
  []

def data_66() -> R.ContextRecord:
  R.ContextRecord{data_65()}

def data_67() -> List<&2, R.ContextRecord>:
  [data_66()]

def data_68() -> List<&2, R.Expr>:
  [data_4()]

def data_69() -> List<&2, R.ReactionState>:
  []

def data_70() -> List<&2, R.ComparatorBinding>:
  []

def data_71() -> List<&2, R.ActionState>:
  []

def data_72() -> List<&2, R.ActionWait>:
  []

def data_73() -> List<&2, R.ArrayData>:
  []

def data_74() -> List<&2, R.RepeatState>:
  []

def data_75() -> List<&2, R.MapState>:
  []

def data_76() -> List<&2, R.Guess>:
  []

def data_77() -> R.LaneMount:
  R.MountUnset{}

def data_78() -> R.LaneState:
  R.LaneState{data_24(), data_44(), data_24(), data_76(), 0n, data_77()}

def data_79() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_80(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_50(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_81(+input: Nat) -> R.Value:
  R.Number{input}

def data_82(+input: Nat) -> R.Slot:
  R.Present{data_81(input)}

def data_83() -> R.Stamp:
  R.Stamped{2n}

def data_84(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_82(input), False{}, 0, 0, 0, 0n, data_83(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_85(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_86(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_85(initial)]

def data_87() -> List<&2, Nat>:
  [3n]

def data_88() -> List<&2, Nat>:
  [2n]

def data_89() -> R.HostJob:
  R.FlushJob{}

def data_90() -> List<&2, R.HostJob>:
  [data_89()]

def data_91(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_86(initial, input), data_22(), data_87(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_92() -> C.Task:
  C.Round{}

def data_93() -> List<&2, C.Task>:
  [data_92()]

def data_94() -> List<&2, R.Value>:
  []

def data_95(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_91(initial, input), data_93(), data_94()}

def data_96(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_86(initial, input), data_22(), data_87(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_97() -> C.Task:
  C.RoundAfterSweep{}

def data_98() -> C.Task:
  C.FlushFinally{}

def data_99() -> C.Task:
  C.RoundEnd{}

def data_100() -> List<&2, C.Task>:
  [data_97(), data_98(), data_99()]

def data_101(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_96(initial, input), data_100(), data_94()}

def data_102() -> C.Task:
  C.HeapLoop{}

def data_103() -> List<&2, C.Task>:
  [data_102(), data_98(), data_99()]

def data_104(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_96(initial, input), data_103(), data_94()}

def data_105() -> C.Task:
  C.Recompute{3n, False{}}

def data_106() -> List<&2, C.Task>:
  [data_105(), data_102(), data_98(), data_99()]

def data_107(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_96(initial, input), data_106(), data_94()}

def data_108(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_18(initial)]

def data_109(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_108(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_110() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_111() -> List<&2, C.Task>:
  [data_110(), data_102(), data_98(), data_99()]

def data_112(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, input), data_111(), data_94()}

def data_113() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_114() -> List<&2, C.Task>:
  [data_113(), data_102(), data_98(), data_99()]

def data_115(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, input), data_114(), data_94()}

def data_116(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_117(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_116(initial)]

def data_118(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_119(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_117(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_118(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_120(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_121(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_1(), 0n, False{}, 0n, data_94(), 0n, False{}}

def data_122(+initial: Nat) -> C.Task:
  C.Finish{data_121(initial)}

def data_123(+initial: Nat) -> List<&2, C.Task>:
  [data_120(initial), data_122(initial), data_102(), data_98(), data_99()]

def data_124(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_123(initial), data_94()}

def data_125(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_126(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_127() -> C.Task:
  C.Binary{0}

def data_128(+initial: Nat) -> List<&2, C.Task>:
  [data_125(initial), data_126(initial), data_127(), data_122(initial), data_102(), data_98(), data_99()]

def data_129(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_128(initial), data_94()}

def data_130() -> C.Task:
  C.ReadNode{2n}

def data_131(+initial: Nat) -> List<&2, C.Task>:
  [data_130(), data_126(initial), data_127(), data_122(initial), data_102(), data_98(), data_99()]

def data_132(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_131(initial), data_94()}

def data_133() -> C.Task:
  C.ReadPrepared{2n}

def data_134(+initial: Nat) -> List<&2, C.Task>:
  [data_133(), data_126(initial), data_127(), data_122(initial), data_102(), data_98(), data_99()]

def data_135(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_134(initial), data_94()}

def data_136(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_137(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_136(initial)]

def data_138() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_139() -> List<&2, R.Link>:
  [data_20(), data_138()]

def data_140(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_81(input)}

def data_141(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_140(input)]

def data_142(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_137(initial, input), data_139(), data_23(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_143(+initial: Nat) -> List<&2, C.Task>:
  [data_126(initial), data_127(), data_122(initial), data_102(), data_98(), data_99()]

def data_144(+input: Nat) -> List<&2, R.Value>:
  [data_81(input)]

def data_145(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_142(initial, input), data_143(initial), data_144(input)}

def data_146(+initial: Nat) -> List<&2, C.Task>:
  [data_127(), data_122(initial), data_102(), data_98(), data_99()]

def data_147(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_81(input)]

def data_148(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_142(initial, input), data_146(initial), data_147(input)}

def data_149(+initial: Nat) -> List<&2, C.Task>:
  [data_122(initial), data_102(), data_98(), data_99()]

def data_150(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_151(+input: Nat) -> List<&2, R.Value>:
  [data_150(input)]

def data_152(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_142(initial, input), data_149(initial), data_151(input)}

def data_153(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_154(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_153(initial)]

def data_155(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_154(initial, input), data_139(), data_23(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_156(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_121(initial), 0n, data_150(input), False{}, False{}, False{}, data_32()}

def data_157(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_156(initial, input), data_102(), data_98(), data_99()]

def data_158(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_155(initial, input), data_157(initial, input), data_94()}

def data_159(+input: Nat) -> R.Slot:
  R.Present{data_150(input)}

def data_160(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_159(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_161(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_160(initial, input)]

def data_162(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_161(initial, input), data_139(), data_23(), 0n, 0n, False{}, data_88(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_163() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_164() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_165() -> List<&2, C.Task>:
  [data_163(), data_164(), data_102(), data_98(), data_99()]

def data_166(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_162(initial, input), data_165(), data_94()}

def data_167() -> List<&2, C.Task>:
  [data_164(), data_102(), data_98(), data_99()]

def data_168(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_162(initial, input), data_167(), data_94()}

def data_169() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_170() -> List<&2, C.Task>:
  [data_169(), data_102(), data_98(), data_99()]

def data_171(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_162(initial, input), data_170(), data_94()}

def data_172(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_159(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_173(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_84(initial, input), data_172(initial, input)]

def data_174() -> List<&2, Nat>:
  [2n, 3n]

def data_175(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_173(initial, input), data_139(), data_23(), 0n, 0n, False{}, data_174(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_176(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, input), data_103(), data_94()}

def data_177(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_173(initial, input), data_139(), data_23(), 1n, 0n, False{}, data_174(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_178(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_103(), data_94()}

def data_179() -> C.Task:
  C.Seam{}

def data_180() -> List<&2, C.Task>:
  [data_179(), data_98(), data_99()]

def data_181(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_180(), data_94()}

def data_182() -> C.Task:
  C.Settle{}

def data_183() -> C.Task:
  C.AfterSettle{}

def data_184() -> List<&2, C.Task>:
  [data_182(), data_183(), data_98(), data_99()]

def data_185(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_184(), data_94()}

def data_186() -> C.Task:
  C.CommitIntake{0n}

def data_187() -> C.Task:
  C.TrimIntake{0n}

def data_188() -> C.Task:
  C.FinishSettleIntake{0n}

def data_189() -> List<&2, C.Task>:
  [data_186(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_190(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_189(), data_94()}

def data_191() -> C.Task:
  C.CommitPending{2n}

def data_192() -> C.Task:
  C.CommitIntake{1n}

def data_193() -> List<&2, C.Task>:
  [data_191(), data_192(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_194(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_193(), data_94()}

def data_195(+input: Nat) -> R.Node:
  R.Node{data_9(), data_81(input), data_2(), False{}, 0, 0, 0, 0n, data_83(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_196(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_195(input), data_172(initial, input)]

def data_197(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_196(initial, input), data_139(), data_23(), 1n, 0n, False{}, data_174(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_198() -> List<&2, C.Task>:
  [data_192(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_199(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_197(initial, input), data_198(), data_94()}

def data_200() -> C.Task:
  C.CommitPending{3n}

def data_201() -> C.Task:
  C.CommitIntake{2n}

def data_202() -> List<&2, C.Task>:
  [data_200(), data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_203(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_197(initial, input), data_202(), data_94()}

def data_204(+input: Nat) -> R.Node:
  R.Node{data_12(), data_150(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_205(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_195(input), data_204(input)]

def data_206(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_205(input), data_139(), data_23(), 1n, 0n, False{}, data_174(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_207() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_208() -> List<&2, C.Task>:
  [data_207(), data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_209(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_206(initial, input), data_208(), data_94()}

def data_210() -> O.Task:
  O.TrimDeps{3n}

def data_211() -> List<&2, O.Task>:
  [data_210()]

def data_212() -> C.Task:
  C.OwnerTasks{data_211()}

def data_213() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_214() -> List<&2, C.Task>:
  [data_212(), data_213(), data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_215(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_206(initial, input), data_214(), data_94()}

def data_216() -> List<&2, O.Task>:
  []

def data_217() -> C.Task:
  C.OwnerTasks{data_216()}

def data_218() -> List<&2, C.Task>:
  [data_217(), data_213(), data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_219(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_206(initial, input), data_218(), data_94()}

def data_220() -> List<&2, C.Task>:
  [data_213(), data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_221(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_206(initial, input), data_220(), data_94()}

def data_222() -> List<&2, C.Task>:
  [data_201(), data_187(), data_188(), data_183(), data_98(), data_99()]

def data_223(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_206(initial, input), data_222(), data_94()}

def data_224(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_205(input), data_139(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_225() -> List<&2, C.Task>:
  [data_187(), data_188(), data_183(), data_98(), data_99()]

def data_226(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_225(), data_94()}

def data_227() -> List<&2, C.Task>:
  [data_188(), data_183(), data_98(), data_99()]

def data_228(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_227(), data_94()}

def data_229() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25()}

def data_230() -> C.Task:
  C.LandTransactions{data_229(), 0n}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_183(), data_98(), data_99()]

def data_232(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_231(), data_94()}

def data_233() -> C.Task:
  C.CompleteSettle{data_229()}

def data_234() -> List<&2, C.Task>:
  [data_233(), data_183(), data_98(), data_99()]

def data_235(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_234(), data_94()}

def data_236() -> C.Task:
  C.ZombieLoop{data_24()}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_183(), data_98(), data_99()]

def data_238(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_237(), data_94()}

def data_239() -> List<&2, C.Task>:
  [data_183(), data_98(), data_99()]

def data_240(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_224(initial, input), data_239(), data_94()}

def data_241(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_205(input), data_139(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_242() -> C.Task:
  C.RenderQueue{}

def data_243() -> List<&2, C.Task>:
  [data_242(), data_98(), data_99()]

def data_244(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, input), data_243(), data_94()}

def data_245() -> C.Task:
  C.UserQueue{}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_98(), data_99()]

def data_247(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, input), data_246(), data_94()}

def data_248() -> List<&2, C.Task>:
  [data_98(), data_99()]

def data_249(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, input), data_248(), data_94()}

def data_250(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_205(input), data_139(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_141(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_90(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2()}

def data_251() -> List<&2, C.Task>:
  [data_99()]

def data_252(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_250(initial, input), data_251(), data_94()}

def data_253() -> List<&2, C.Task>:
  []

def data_254(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_250(initial, input), data_253(), data_94()}

def origin(+initial: Nat) -> R.World:
  data_80(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_95(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_101(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_104(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_107(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_112(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_115(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_124(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_129(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_132(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_135(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_145(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_148(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_152(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_158(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_166(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_168(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_171(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_176(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_178(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_181(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_185(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_190(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_194(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_199(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_203(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_209(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_215(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_219(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_221(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_223(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_226(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_228(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_232(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_235(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_238(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_240(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_244(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_247(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_249(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_252(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_254(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_250(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
