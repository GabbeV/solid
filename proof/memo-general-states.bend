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
  R.StreamPlan{data_51(), False{}, data_2(), 0n, 0n, data_2()}

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

def data_80() -> R.Value:
  R.Null{}

def data_81() -> R.DeferredCell:
  R.DeferredCell{0n, data_80(), False{}, False{}}

def data_82() -> R.DeferredBinding:
  R.DeferredBinding{data_81(), 0n}

def data_83() -> List<&2, R.DeferredBinding>:
  [data_82()]

def data_84() -> List<&2, R.DeferredWait>:
  []

def data_85() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_86() -> List<&2, R.DeferredIterator>:
  [data_85()]

def data_87() -> R.DeferredArena:
  R.DeferredArena{data_83(), data_24(), data_84(), data_86()}

def data_88(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_50(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_89(+input: Nat) -> R.Value:
  R.Number{input}

def data_90(+input: Nat) -> R.Slot:
  R.Present{data_89(input)}

def data_91() -> R.Stamp:
  R.Stamped{2n}

def data_92(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_90(input), False{}, 0, 0, 0, 0n, data_91(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_93(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_94(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_93(initial)]

def data_95() -> List<&2, Nat>:
  [3n]

def data_96() -> List<&2, Nat>:
  [2n]

def data_97() -> R.HostJob:
  R.FlushJob{}

def data_98() -> List<&2, R.HostJob>:
  [data_97()]

def data_99(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_94(initial, input), data_22(), data_95(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_100() -> C.Task:
  C.Round{}

def data_101() -> List<&2, C.Task>:
  [data_100()]

def data_102() -> List<&2, R.Value>:
  []

def data_103(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_99(initial, input), data_101(), data_102()}

def data_104(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_94(initial, input), data_22(), data_95(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_105() -> C.Task:
  C.RoundAfterSweep{}

def data_106() -> C.Task:
  C.FlushFinally{}

def data_107() -> C.Task:
  C.RoundEnd{}

def data_108() -> List<&2, C.Task>:
  [data_105(), data_106(), data_107()]

def data_109(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_104(initial, input), data_108(), data_102()}

def data_110() -> C.Task:
  C.HeapLoop{}

def data_111() -> List<&2, C.Task>:
  [data_110(), data_106(), data_107()]

def data_112(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_104(initial, input), data_111(), data_102()}

def data_113() -> C.Task:
  C.Recompute{3n, False{}}

def data_114() -> List<&2, C.Task>:
  [data_113(), data_110(), data_106(), data_107()]

def data_115(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_104(initial, input), data_114(), data_102()}

def data_116(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_18(initial)]

def data_117() -> R.LaneMount:
  R.MountFalse{}

def data_118() -> R.LaneState:
  R.LaneState{data_24(), data_44(), data_24(), data_76(), 0n, data_117()}

def data_119(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_116(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_24(), data_87()}

def data_120() -> C.LanePass:
  C.LanePass{0n, data_77(), data_117()}

def data_121() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_120()}

def data_122() -> List<&2, C.Task>:
  [data_121(), data_110(), data_106(), data_107()]

def data_123(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_122(), data_102()}

def data_124() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_120()}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_110(), data_106(), data_107()]

def data_126(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_119(initial, input), data_125(), data_102()}

def data_127(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_128(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_127(initial)]

def data_129(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_130(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_128(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_129(initial), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_24(), data_87()}

def data_131(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_132(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_1(), 0n, False{}, 0n, data_102(), 0n, False{}, data_120()}

def data_133(+initial: Nat) -> C.Task:
  C.Finish{data_132(initial)}

def data_134(+initial: Nat) -> List<&2, C.Task>:
  [data_131(initial), data_133(initial), data_110(), data_106(), data_107()]

def data_135(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_130(initial, input), data_134(initial), data_102()}

def data_136(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_137(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_138() -> C.Task:
  C.Binary{0}

def data_139(+initial: Nat) -> List<&2, C.Task>:
  [data_136(initial), data_137(initial), data_138(), data_133(initial), data_110(), data_106(), data_107()]

def data_140(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_130(initial, input), data_139(initial), data_102()}

def data_141() -> C.Task:
  C.ReadNode{2n}

def data_142(+initial: Nat) -> List<&2, C.Task>:
  [data_141(), data_137(initial), data_138(), data_133(initial), data_110(), data_106(), data_107()]

def data_143(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_130(initial, input), data_142(initial), data_102()}

def data_144() -> C.Task:
  C.ReadPrepared{2n}

def data_145(+initial: Nat) -> List<&2, C.Task>:
  [data_144(), data_137(initial), data_138(), data_133(initial), data_110(), data_106(), data_107()]

def data_146(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_130(initial, input), data_145(initial), data_102()}

def data_147(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_148(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_147(initial)]

def data_149() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_150() -> List<&2, R.Link>:
  [data_20(), data_149()]

def data_151(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_89(input)}

def data_152(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_151(input)]

def data_153(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_148(initial, input), data_150(), data_23(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_24(), data_87()}

def data_154(+initial: Nat) -> List<&2, C.Task>:
  [data_137(initial), data_138(), data_133(initial), data_110(), data_106(), data_107()]

def data_155(+input: Nat) -> List<&2, R.Value>:
  [data_89(input)]

def data_156(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_153(initial, input), data_154(initial), data_155(input)}

def data_157(+initial: Nat) -> List<&2, C.Task>:
  [data_138(), data_133(initial), data_110(), data_106(), data_107()]

def data_158(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_89(input)]

def data_159(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_153(initial, input), data_157(initial), data_158(input)}

def data_160(+initial: Nat) -> List<&2, C.Task>:
  [data_133(initial), data_110(), data_106(), data_107()]

def data_161(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_162(+input: Nat) -> List<&2, R.Value>:
  [data_161(input)]

def data_163(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_153(initial, input), data_160(initial), data_162(input)}

def data_164(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_165(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_164(initial)]

def data_166(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_165(initial, input), data_150(), data_23(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_167(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_132(initial), 0n, data_161(input), False{}, False{}, False{}, data_32()}

def data_168(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_167(initial, input), data_110(), data_106(), data_107()]

def data_169(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_166(initial, input), data_168(initial, input), data_102()}

def data_170(+input: Nat) -> R.Slot:
  R.Present{data_161(input)}

def data_171(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_170(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_172(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_171(initial, input)]

def data_173(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_172(initial, input), data_150(), data_23(), 0n, 0n, False{}, data_96(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_174() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_175() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_176() -> List<&2, C.Task>:
  [data_174(), data_175(), data_110(), data_106(), data_107()]

def data_177(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(initial, input), data_176(), data_102()}

def data_178() -> List<&2, C.Task>:
  [data_175(), data_110(), data_106(), data_107()]

def data_179(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(initial, input), data_178(), data_102()}

def data_180() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_181() -> List<&2, C.Task>:
  [data_180(), data_110(), data_106(), data_107()]

def data_182(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_173(initial, input), data_181(), data_102()}

def data_183(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_170(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_184(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(initial, input), data_183(initial, input)]

def data_185() -> List<&2, Nat>:
  [2n, 3n]

def data_186(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_184(initial, input), data_150(), data_23(), 0n, 0n, False{}, data_185(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_187(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_186(initial, input), data_111(), data_102()}

def data_188(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_184(initial, input), data_150(), data_23(), 1n, 0n, False{}, data_185(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_189(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_111(), data_102()}

def data_190() -> C.Task:
  C.Seam{}

def data_191() -> List<&2, C.Task>:
  [data_190(), data_106(), data_107()]

def data_192(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_191(), data_102()}

def data_193() -> C.Task:
  C.Settle{}

def data_194() -> C.Task:
  C.AfterSettle{}

def data_195() -> List<&2, C.Task>:
  [data_193(), data_194(), data_106(), data_107()]

def data_196(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_195(), data_102()}

def data_197() -> C.Task:
  C.CommitIntake{0n}

def data_198() -> C.Task:
  C.TrimIntake{0n}

def data_199() -> C.Task:
  C.FinishSettleIntake{0n}

def data_200() -> List<&2, C.Task>:
  [data_197(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_201(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_200(), data_102()}

def data_202() -> C.Task:
  C.CommitPending{2n}

def data_203() -> C.Task:
  C.CommitIntake{1n}

def data_204() -> List<&2, C.Task>:
  [data_202(), data_203(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_205(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_204(), data_102()}

def data_206(+input: Nat) -> R.Node:
  R.Node{data_9(), data_89(input), data_2(), False{}, 0, 0, 0, 0n, data_91(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_207(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_206(input), data_183(initial, input)]

def data_208(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_207(initial, input), data_150(), data_23(), 1n, 0n, False{}, data_185(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_209() -> List<&2, C.Task>:
  [data_203(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_210(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_208(initial, input), data_209(), data_102()}

def data_211() -> C.Task:
  C.CommitPending{3n}

def data_212() -> C.Task:
  C.CommitIntake{2n}

def data_213() -> List<&2, C.Task>:
  [data_211(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_214(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_208(initial, input), data_213(), data_102()}

def data_215(+input: Nat) -> R.Node:
  R.Node{data_12(), data_161(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_216(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_206(input), data_215(input)]

def data_217(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_216(input), data_150(), data_23(), 1n, 0n, False{}, data_185(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_218() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_219() -> List<&2, C.Task>:
  [data_218(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_220(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_217(initial, input), data_219(), data_102()}

def data_221() -> O.Task:
  O.TrimDeps{3n}

def data_222() -> List<&2, O.Task>:
  [data_221()]

def data_223() -> C.Task:
  C.OwnerTasks{data_222()}

def data_224() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_225() -> List<&2, C.Task>:
  [data_223(), data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_226(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_217(initial, input), data_225(), data_102()}

def data_227() -> List<&2, O.Task>:
  []

def data_228() -> C.Task:
  C.OwnerTasks{data_227()}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_230(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_217(initial, input), data_229(), data_102()}

def data_231() -> List<&2, C.Task>:
  [data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_232(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_217(initial, input), data_231(), data_102()}

def data_233() -> List<&2, C.Task>:
  [data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_234(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_217(initial, input), data_233(), data_102()}

def data_235(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_216(input), data_150(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_236() -> List<&2, C.Task>:
  [data_198(), data_199(), data_194(), data_106(), data_107()]

def data_237(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_236(), data_102()}

def data_238() -> List<&2, C.Task>:
  [data_199(), data_194(), data_106(), data_107()]

def data_239(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_238(), data_102()}

def data_240() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_241() -> C.Task:
  C.LandTransactions{data_240(), 0n}

def data_242() -> List<&2, C.Task>:
  [data_241(), data_194(), data_106(), data_107()]

def data_243(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_242(), data_102()}

def data_244() -> C.Task:
  C.CompleteSettle{data_240()}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_194(), data_106(), data_107()]

def data_246(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_245(), data_102()}

def data_247() -> C.Task:
  C.ZombieLoop{data_24()}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_194(), data_106(), data_107()]

def data_249(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_248(), data_102()}

def data_250() -> List<&2, C.Task>:
  [data_194(), data_106(), data_107()]

def data_251(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_235(initial, input), data_250(), data_102()}

def data_252(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_216(input), data_150(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_253() -> C.Task:
  C.RenderQueue{}

def data_254() -> List<&2, C.Task>:
  [data_253(), data_106(), data_107()]

def data_255(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_252(initial, input), data_254(), data_102()}

def data_256() -> C.Task:
  C.UserQueue{}

def data_257() -> List<&2, C.Task>:
  [data_256(), data_106(), data_107()]

def data_258(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_252(initial, input), data_257(), data_102()}

def data_259() -> List<&2, C.Task>:
  [data_106(), data_107()]

def data_260(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_252(initial, input), data_259(), data_102()}

def data_261(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_216(input), data_150(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_152(initial, input), data_32(), False{}, data_24(), data_36(), data_39(), data_24(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_24(), data_87()}

def data_262() -> List<&2, C.Task>:
  [data_107()]

def data_263(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_261(initial, input), data_262(), data_102()}

def data_264() -> List<&2, C.Task>:
  []

def data_265(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_261(initial, input), data_264(), data_102()}

def origin(+initial: Nat) -> R.World:
  data_88(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_103(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_109(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_112(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_115(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_123(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_126(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_135(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_140(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_143(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_146(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_156(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_159(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_163(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_169(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_177(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_179(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_182(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_187(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_189(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_192(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_196(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_201(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_205(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_210(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_214(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_220(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_226(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_230(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_232(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_234(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_237(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_239(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_243(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_246(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_249(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_251(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_255(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_258(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_260(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_263(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_265(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_261(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
