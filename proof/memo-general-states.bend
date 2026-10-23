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

def data_33() -> R.Flight:
  R.FlightEmpty{}

def data_34() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_35() -> R.Question:
  R.QuestionZero{}

def data_36() -> R.NodeExtension:
  R.NodeExtension{data_33(), 0n, data_1(), data_2(), 0n, 0n, data_34(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_35(), data_2(), 0n, data_1()}

def data_37() -> List<&2, R.NodeExtension>:
  [data_36()]

def data_38() -> List<&2, R.CleanupAction>:
  []

def data_39() -> R.CleanupProgram:
  R.CleanupProgram{data_38(), False{}, 0n}

def data_40() -> List<&2, R.CleanupProgram>:
  [data_39()]

def data_41() -> List<&2, R.Report>:
  []

def data_42() -> R.OptionalIds:
  R.NoIds{}

def data_43() -> R.Transaction:
  R.Transaction{data_24(), data_24(), data_25(), data_24(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_42()}

def data_44() -> List<&2, R.Transaction>:
  [data_43()]

def data_45() -> List<&2, List<&2, Nat>>:
  [data_24()]

def data_46() -> R.AsyncSettlement:
  R.Unresolved{}

def data_47() -> R.AsyncObject:
  R.AsyncObject{False{}, data_46(), data_24(), 0n}

def data_48() -> List<&2, R.AsyncObject>:
  [data_47()]

def data_49() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_50() -> List<&2, R.AsyncObserver>:
  [data_49()]

def data_51() -> List<&2, R.HostJob>:
  []

def data_52() -> List<&2, R.NextInput>:
  []

def data_53() -> R.StreamPlan:
  R.StreamPlan{data_52(), False{}, data_2(), 0n, 0n, data_2()}

def data_54() -> List<&2, R.StreamPlan>:
  [data_53()]

def data_55() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_56() -> List<&2, R.ExternalIterator>:
  [data_55()]

def data_57() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_58() -> List<&2, R.StreamState>:
  [data_57()]

def data_59() -> List<&2, R.IteratorEvent>:
  []

def data_60() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_46(), False{}, 0n, False{}, False{}, 0n}

def data_61() -> List<&2, R.Awaiter>:
  [data_60()]

def data_62() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_63() -> List<&2, R.AbortInput>:
  [data_62()]

def data_64() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_65() -> List<&2, R.ContextKey>:
  [data_64()]

def data_66() -> List<&2, R.ContextEntry>:
  []

def data_67() -> R.ContextRecord:
  R.ContextRecord{data_66()}

def data_68() -> List<&2, R.ContextRecord>:
  [data_67()]

def data_69() -> List<&2, R.Expr>:
  [data_4()]

def data_70() -> List<&2, R.ReactionState>:
  []

def data_71() -> List<&2, R.ComparatorBinding>:
  []

def data_72() -> List<&2, R.ActionState>:
  []

def data_73() -> List<&2, R.ActionWait>:
  []

def data_74() -> List<&2, R.ArrayData>:
  []

def data_75() -> List<&2, R.RepeatState>:
  []

def data_76() -> List<&2, R.MapState>:
  []

def data_77() -> List<&2, R.Guess>:
  []

def data_78() -> R.LaneMount:
  R.MountUnset{}

def data_79() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_77(), 0n, data_78()}

def data_80() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_81() -> R.Value:
  R.Null{}

def data_82() -> R.DeferredCell:
  R.DeferredCell{0n, data_81(), False{}, False{}}

def data_83() -> R.DeferredBinding:
  R.DeferredBinding{data_82(), 0n}

def data_84() -> List<&2, R.DeferredBinding>:
  [data_83()]

def data_85() -> List<&2, R.DeferredWait>:
  []

def data_86() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_87() -> List<&2, R.DeferredIterator>:
  [data_86()]

def data_88() -> R.DeferredArena:
  R.DeferredArena{data_84(), data_24(), data_85(), data_87()}

def data_89(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_51(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_90(+input: Nat) -> R.Value:
  R.Number{input}

def data_91(+input: Nat) -> R.Slot:
  R.Present{data_90(input)}

def data_92() -> R.Stamp:
  R.Stamped{2n}

def data_93(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_91(input), False{}, 0, 0, 0, 0n, data_92(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_94(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_95(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_94(initial)]

def data_96() -> List<&2, Nat>:
  [3n]

def data_97() -> List<&2, Nat>:
  [2n]

def data_98() -> R.HostJob:
  R.FlushJob{}

def data_99() -> List<&2, R.HostJob>:
  [data_98()]

def data_100(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_95(initial, input), data_22(), data_96(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_101() -> C.Task:
  C.Round{}

def data_102() -> List<&2, C.Task>:
  [data_101()]

def data_103() -> List<&2, R.Value>:
  []

def data_104(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_100(initial, input), data_102(), data_103()}

def data_105(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_95(initial, input), data_22(), data_96(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_106() -> C.Task:
  C.RoundAfterSweep{}

def data_107() -> C.Task:
  C.FlushFinally{}

def data_108() -> C.Task:
  C.RoundEnd{}

def data_109() -> List<&2, C.Task>:
  [data_106(), data_107(), data_108()]

def data_110(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_105(initial, input), data_109(), data_103()}

def data_111() -> C.Task:
  C.HeapLoop{}

def data_112() -> List<&2, C.Task>:
  [data_111(), data_107(), data_108()]

def data_113(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_105(initial, input), data_112(), data_103()}

def data_114() -> C.Task:
  C.Recompute{3n, False{}}

def data_115() -> List<&2, C.Task>:
  [data_114(), data_111(), data_107(), data_108()]

def data_116(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_105(initial, input), data_115(), data_103()}

def data_117(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_18(initial)]

def data_118() -> R.LaneMount:
  R.MountFalse{}

def data_119() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_77(), 0n, data_118()}

def data_120(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_117(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_119(), data_80(), data_2(), data_24(), data_88()}

def data_121() -> C.LanePass:
  C.LanePass{0n, data_78(), data_118()}

def data_122() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_121()}

def data_123() -> List<&2, C.Task>:
  [data_122(), data_111(), data_107(), data_108()]

def data_124(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, input), data_123(), data_103()}

def data_125() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_121()}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_111(), data_107(), data_108()]

def data_127(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_120(initial, input), data_126(), data_103()}

def data_128(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_129(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_128(initial)]

def data_130(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_131(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_129(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_130(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_119(), data_80(), data_2(), data_24(), data_88()}

def data_132(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_133() -> R.Flight:
  R.FlightUndefined{}

def data_134(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_1(), 0n, False{}, data_133(), data_103(), 0n, False{}, data_121()}

def data_135(+initial: Nat) -> C.Task:
  C.Finish{data_134(initial)}

def data_136(+initial: Nat) -> List<&2, C.Task>:
  [data_132(initial), data_135(initial), data_111(), data_107(), data_108()]

def data_137(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_131(initial, input), data_136(initial), data_103()}

def data_138(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_139(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_140() -> C.Task:
  C.Binary{0}

def data_141(+initial: Nat) -> List<&2, C.Task>:
  [data_138(initial), data_139(initial), data_140(), data_135(initial), data_111(), data_107(), data_108()]

def data_142(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_131(initial, input), data_141(initial), data_103()}

def data_143() -> C.Task:
  C.ReadNode{2n}

def data_144(+initial: Nat) -> List<&2, C.Task>:
  [data_143(), data_139(initial), data_140(), data_135(initial), data_111(), data_107(), data_108()]

def data_145(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_131(initial, input), data_144(initial), data_103()}

def data_146() -> C.Task:
  C.ReadPrepared{2n}

def data_147(+initial: Nat) -> List<&2, C.Task>:
  [data_146(), data_139(initial), data_140(), data_135(initial), data_111(), data_107(), data_108()]

def data_148(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_131(initial, input), data_147(initial), data_103()}

def data_149(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_150(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_149(initial)]

def data_151() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_152() -> List<&2, R.Link>:
  [data_20(), data_151()]

def data_153(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_90(input)}

def data_154(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_153(input)]

def data_155(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_150(initial, input), data_152(), data_23(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_119(), data_80(), data_2(), data_24(), data_88()}

def data_156(+initial: Nat) -> List<&2, C.Task>:
  [data_139(initial), data_140(), data_135(initial), data_111(), data_107(), data_108()]

def data_157(+input: Nat) -> List<&2, R.Value>:
  [data_90(input)]

def data_158(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_155(initial, input), data_156(initial), data_157(input)}

def data_159(+initial: Nat) -> List<&2, C.Task>:
  [data_140(), data_135(initial), data_111(), data_107(), data_108()]

def data_160(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_90(input)]

def data_161(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_155(initial, input), data_159(initial), data_160(input)}

def data_162(+initial: Nat) -> List<&2, C.Task>:
  [data_135(initial), data_111(), data_107(), data_108()]

def data_163(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_164(+input: Nat) -> List<&2, R.Value>:
  [data_163(input)]

def data_165(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_155(initial, input), data_162(initial), data_164(input)}

def data_166(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_167(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_166(initial)]

def data_168(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_167(initial, input), data_152(), data_23(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_169(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_134(initial), 0n, data_163(input), False{}, False{}, False{}, data_32()}

def data_170(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_169(initial, input), data_111(), data_107(), data_108()]

def data_171(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_168(initial, input), data_170(initial, input), data_103()}

def data_172(+input: Nat) -> R.Slot:
  R.Present{data_163(input)}

def data_173(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_172(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_174(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_173(initial, input)]

def data_175(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_174(initial, input), data_152(), data_23(), 0n, 0n, False{}, data_97(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_176() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_177() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_178() -> List<&2, C.Task>:
  [data_176(), data_177(), data_111(), data_107(), data_108()]

def data_179(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, input), data_178(), data_103()}

def data_180() -> List<&2, C.Task>:
  [data_177(), data_111(), data_107(), data_108()]

def data_181(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, input), data_180(), data_103()}

def data_182() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_183() -> List<&2, C.Task>:
  [data_182(), data_111(), data_107(), data_108()]

def data_184(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_175(initial, input), data_183(), data_103()}

def data_185(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_172(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_186(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(initial, input), data_185(initial, input)]

def data_187() -> List<&2, Nat>:
  [2n, 3n]

def data_188(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_186(initial, input), data_152(), data_23(), 0n, 0n, False{}, data_187(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_189(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_188(initial, input), data_112(), data_103()}

def data_190(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_186(initial, input), data_152(), data_23(), 1n, 0n, False{}, data_187(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_191(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_112(), data_103()}

def data_192() -> C.Task:
  C.Seam{}

def data_193() -> List<&2, C.Task>:
  [data_192(), data_107(), data_108()]

def data_194(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_193(), data_103()}

def data_195() -> C.Task:
  C.Settle{}

def data_196() -> C.Task:
  C.AfterSettle{}

def data_197() -> List<&2, C.Task>:
  [data_195(), data_196(), data_107(), data_108()]

def data_198(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_197(), data_103()}

def data_199() -> C.Task:
  C.CommitIntake{0n}

def data_200() -> C.Task:
  C.TrimIntake{0n}

def data_201() -> C.Task:
  C.FinishSettleIntake{0n}

def data_202() -> List<&2, C.Task>:
  [data_199(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_203(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_202(), data_103()}

def data_204() -> C.Task:
  C.CommitPending{2n}

def data_205() -> C.Task:
  C.CommitIntake{1n}

def data_206() -> List<&2, C.Task>:
  [data_204(), data_205(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_207(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_206(), data_103()}

def data_208(+input: Nat) -> R.Node:
  R.Node{data_9(), data_90(input), data_2(), False{}, 0, 0, 0, 0n, data_92(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_209(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_208(input), data_185(initial, input)]

def data_210(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_209(initial, input), data_152(), data_23(), 1n, 0n, False{}, data_187(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_211() -> List<&2, C.Task>:
  [data_205(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_212(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_210(initial, input), data_211(), data_103()}

def data_213() -> C.Task:
  C.CommitPending{3n}

def data_214() -> C.Task:
  C.CommitIntake{2n}

def data_215() -> List<&2, C.Task>:
  [data_213(), data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_216(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_210(initial, input), data_215(), data_103()}

def data_217(+input: Nat) -> R.Node:
  R.Node{data_12(), data_163(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_218(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_208(input), data_217(input)]

def data_219(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_218(input), data_152(), data_23(), 1n, 0n, False{}, data_187(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_220() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_221() -> List<&2, C.Task>:
  [data_220(), data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_222(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_219(initial, input), data_221(), data_103()}

def data_223() -> O.Task:
  O.TrimDeps{3n}

def data_224() -> List<&2, O.Task>:
  [data_223()]

def data_225() -> C.Task:
  C.OwnerTasks{data_224()}

def data_226() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_227() -> List<&2, C.Task>:
  [data_225(), data_226(), data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_228(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_219(initial, input), data_227(), data_103()}

def data_229() -> List<&2, O.Task>:
  []

def data_230() -> C.Task:
  C.OwnerTasks{data_229()}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_226(), data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_232(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_219(initial, input), data_231(), data_103()}

def data_233() -> List<&2, C.Task>:
  [data_226(), data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_234(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_219(initial, input), data_233(), data_103()}

def data_235() -> List<&2, C.Task>:
  [data_214(), data_200(), data_201(), data_196(), data_107(), data_108()]

def data_236(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_219(initial, input), data_235(), data_103()}

def data_237(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_218(input), data_152(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_238() -> List<&2, C.Task>:
  [data_200(), data_201(), data_196(), data_107(), data_108()]

def data_239(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_238(), data_103()}

def data_240() -> List<&2, C.Task>:
  [data_201(), data_196(), data_107(), data_108()]

def data_241(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_240(), data_103()}

def data_242() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_243() -> C.Task:
  C.LandTransactions{data_242(), 0n}

def data_244() -> List<&2, C.Task>:
  [data_243(), data_196(), data_107(), data_108()]

def data_245(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_244(), data_103()}

def data_246() -> C.Task:
  C.CompleteSettle{data_242()}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_196(), data_107(), data_108()]

def data_248(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_247(), data_103()}

def data_249() -> C.Task:
  C.ZombieLoop{data_24()}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_196(), data_107(), data_108()]

def data_251(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_250(), data_103()}

def data_252() -> List<&2, C.Task>:
  [data_196(), data_107(), data_108()]

def data_253(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_237(initial, input), data_252(), data_103()}

def data_254(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_218(input), data_152(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_255() -> C.Task:
  C.RenderQueue{}

def data_256() -> List<&2, C.Task>:
  [data_255(), data_107(), data_108()]

def data_257(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_254(initial, input), data_256(), data_103()}

def data_258() -> C.Task:
  C.UserQueue{}

def data_259() -> List<&2, C.Task>:
  [data_258(), data_107(), data_108()]

def data_260(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_254(initial, input), data_259(), data_103()}

def data_261() -> List<&2, C.Task>:
  [data_107(), data_108()]

def data_262(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_254(initial, input), data_261(), data_103()}

def data_263(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_218(input), data_152(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_154(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_99(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_35(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_79(), data_80(), data_2(), data_24(), data_88()}

def data_264() -> List<&2, C.Task>:
  [data_108()]

def data_265(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_263(initial, input), data_264(), data_103()}

def data_266() -> List<&2, C.Task>:
  []

def data_267(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_263(initial, input), data_266(), data_103()}

def origin(+initial: Nat) -> R.World:
  data_89(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_104(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_110(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_113(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_116(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_124(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_127(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_137(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_142(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_145(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_148(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_158(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_161(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_165(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_171(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_179(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_181(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_184(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_189(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_191(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_194(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_198(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_203(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_207(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_212(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_216(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_222(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_228(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_232(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_234(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_236(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_239(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_241(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_245(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_248(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_251(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_253(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_257(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_260(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_262(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_265(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_267(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_263(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
