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

def data_53() -> R.FromState:
  R.FromNone{}

def data_54() -> R.StreamPlan:
  R.StreamPlan{data_52(), False{}, data_2(), 0n, 0n, data_2(), data_53()}

def data_55() -> List<&2, R.StreamPlan>:
  [data_54()]

def data_56() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_57() -> List<&2, R.ExternalIterator>:
  [data_56()]

def data_58() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_59() -> List<&2, R.StreamState>:
  [data_58()]

def data_60() -> List<&2, R.IteratorEvent>:
  []

def data_61() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_46(), False{}, 0n, False{}, False{}, 0n}

def data_62() -> List<&2, R.Awaiter>:
  [data_61()]

def data_63() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_64() -> List<&2, R.AbortInput>:
  [data_63()]

def data_65() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_66() -> List<&2, R.ContextKey>:
  [data_65()]

def data_67() -> List<&2, R.ContextEntry>:
  []

def data_68() -> R.ContextRecord:
  R.ContextRecord{data_67()}

def data_69() -> List<&2, R.ContextRecord>:
  [data_68()]

def data_70() -> List<&2, R.Expr>:
  [data_4()]

def data_71() -> List<&2, R.ReactionState>:
  []

def data_72() -> List<&2, R.ComparatorBinding>:
  []

def data_73() -> List<&2, R.ActionState>:
  []

def data_74() -> List<&2, R.ActionWait>:
  []

def data_75() -> List<&2, R.ArrayData>:
  []

def data_76() -> List<&2, R.RepeatState>:
  []

def data_77() -> List<&2, R.MapState>:
  []

def data_78() -> List<&2, R.Guess>:
  []

def data_79() -> R.LaneMount:
  R.MountUnset{}

def data_80() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_78(), 0n, data_79(), data_24()}

def data_81() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_82() -> R.Value:
  R.Null{}

def data_83() -> R.DeferredCell:
  R.DeferredCell{0n, data_82(), False{}, False{}}

def data_84() -> R.DeferredBinding:
  R.DeferredBinding{data_83(), 0n}

def data_85() -> List<&2, R.DeferredBinding>:
  [data_84()]

def data_86() -> List<&2, R.DeferredWait>:
  []

def data_87() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_88() -> List<&2, R.DeferredIterator>:
  [data_87()]

def data_89() -> R.DeferredArena:
  R.DeferredArena{data_85(), data_24(), data_86(), data_88()}

def data_90(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_51(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_91(+input: Nat) -> R.Value:
  R.Number{input}

def data_92(+input: Nat) -> R.Slot:
  R.Present{data_91(input)}

def data_93() -> R.Stamp:
  R.Stamped{2n}

def data_94(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_92(input), False{}, 0, 0, 0, 0n, data_93(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_95(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_96(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_95(initial)]

def data_97() -> List<&2, Nat>:
  [3n]

def data_98() -> List<&2, Nat>:
  [2n]

def data_99() -> R.HostJob:
  R.FlushJob{}

def data_100() -> List<&2, R.HostJob>:
  [data_99()]

def data_101(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_96(initial, input), data_22(), data_97(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_102() -> C.Task:
  C.Round{}

def data_103() -> List<&2, C.Task>:
  [data_102()]

def data_104() -> List<&2, R.Value>:
  []

def data_105(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_101(initial, input), data_103(), data_104()}

def data_106(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_96(initial, input), data_22(), data_97(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_107() -> C.Task:
  C.RoundAfterSweep{}

def data_108() -> C.Task:
  C.FlushFinally{}

def data_109() -> C.Task:
  C.RoundEnd{}

def data_110() -> List<&2, C.Task>:
  [data_107(), data_108(), data_109()]

def data_111(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_106(initial, input), data_110(), data_104()}

def data_112() -> C.Task:
  C.HeapLoop{}

def data_113() -> List<&2, C.Task>:
  [data_112(), data_108(), data_109()]

def data_114(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_106(initial, input), data_113(), data_104()}

def data_115() -> C.Task:
  C.Recompute{3n, False{}}

def data_116() -> List<&2, C.Task>:
  [data_115(), data_112(), data_108(), data_109()]

def data_117(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_106(initial, input), data_116(), data_104()}

def data_118(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_18(initial)]

def data_119() -> R.LaneMount:
  R.MountFalse{}

def data_120() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_78(), 0n, data_119(), data_24()}

def data_121(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_118(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_120(), data_81(), data_2(), data_24(), data_89()}

def data_122() -> C.LanePass:
  C.LanePass{0n, data_79(), data_119()}

def data_123() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_122()}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_112(), data_108(), data_109()]

def data_125(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_121(initial, input), data_124(), data_104()}

def data_126() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_122()}

def data_127() -> List<&2, C.Task>:
  [data_126(), data_112(), data_108(), data_109()]

def data_128(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_121(initial, input), data_127(), data_104()}

def data_129(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_130(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_129(initial)]

def data_131(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_132(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_130(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_131(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_120(), data_81(), data_2(), data_24(), data_89()}

def data_133(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_134() -> R.Flight:
  R.FlightUndefined{}

def data_135(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_1(), 0n, False{}, data_134(), data_104(), 0n, False{}, data_122()}

def data_136(+initial: Nat) -> C.Task:
  C.Finish{data_135(initial)}

def data_137(+initial: Nat) -> List<&2, C.Task>:
  [data_133(initial), data_136(initial), data_112(), data_108(), data_109()]

def data_138(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_132(initial, input), data_137(initial), data_104()}

def data_139(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_140(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_141() -> C.Task:
  C.Binary{0}

def data_142(+initial: Nat) -> List<&2, C.Task>:
  [data_139(initial), data_140(initial), data_141(), data_136(initial), data_112(), data_108(), data_109()]

def data_143(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_132(initial, input), data_142(initial), data_104()}

def data_144() -> C.Task:
  C.ReadNode{2n}

def data_145(+initial: Nat) -> List<&2, C.Task>:
  [data_144(), data_140(initial), data_141(), data_136(initial), data_112(), data_108(), data_109()]

def data_146(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_132(initial, input), data_145(initial), data_104()}

def data_147() -> C.Task:
  C.ReadPrepared{2n}

def data_148(+initial: Nat) -> List<&2, C.Task>:
  [data_147(), data_140(initial), data_141(), data_136(initial), data_112(), data_108(), data_109()]

def data_149(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_132(initial, input), data_148(initial), data_104()}

def data_150(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_151(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_150(initial)]

def data_152() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_153() -> List<&2, R.Link>:
  [data_20(), data_152()]

def data_154(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_91(input)}

def data_155(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_154(input)]

def data_156(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_151(initial, input), data_153(), data_23(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_120(), data_81(), data_2(), data_24(), data_89()}

def data_157(+initial: Nat) -> List<&2, C.Task>:
  [data_140(initial), data_141(), data_136(initial), data_112(), data_108(), data_109()]

def data_158(+input: Nat) -> List<&2, R.Value>:
  [data_91(input)]

def data_159(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_156(initial, input), data_157(initial), data_158(input)}

def data_160(+initial: Nat) -> List<&2, C.Task>:
  [data_141(), data_136(initial), data_112(), data_108(), data_109()]

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_91(input)]

def data_162(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_156(initial, input), data_160(initial), data_161(input)}

def data_163(+initial: Nat) -> List<&2, C.Task>:
  [data_136(initial), data_112(), data_108(), data_109()]

def data_164(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_165(+input: Nat) -> List<&2, R.Value>:
  [data_164(input)]

def data_166(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_156(initial, input), data_163(initial), data_165(input)}

def data_167(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_168(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_167(initial)]

def data_169(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_168(initial, input), data_153(), data_23(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_170(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_135(initial), 0n, data_164(input), False{}, False{}, False{}, data_32()}

def data_171(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_170(initial, input), data_112(), data_108(), data_109()]

def data_172(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_169(initial, input), data_171(initial, input), data_104()}

def data_173(+input: Nat) -> R.Slot:
  R.Present{data_164(input)}

def data_174(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_173(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_175(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_174(initial, input)]

def data_176(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_175(initial, input), data_153(), data_23(), 0n, 0n, False{}, data_98(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_177() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_178() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_179() -> List<&2, C.Task>:
  [data_177(), data_178(), data_112(), data_108(), data_109()]

def data_180(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_176(initial, input), data_179(), data_104()}

def data_181() -> List<&2, C.Task>:
  [data_178(), data_112(), data_108(), data_109()]

def data_182(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_176(initial, input), data_181(), data_104()}

def data_183() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_184() -> List<&2, C.Task>:
  [data_183(), data_112(), data_108(), data_109()]

def data_185(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_176(initial, input), data_184(), data_104()}

def data_186(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_173(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_187(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(initial, input), data_186(initial, input)]

def data_188() -> List<&2, Nat>:
  [2n, 3n]

def data_189(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_187(initial, input), data_153(), data_23(), 0n, 0n, False{}, data_188(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_190(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_189(initial, input), data_113(), data_104()}

def data_191(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_187(initial, input), data_153(), data_23(), 1n, 0n, False{}, data_188(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_192(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_113(), data_104()}

def data_193() -> C.Task:
  C.Seam{}

def data_194() -> List<&2, C.Task>:
  [data_193(), data_108(), data_109()]

def data_195(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_194(), data_104()}

def data_196() -> C.Task:
  C.Settle{}

def data_197() -> C.Task:
  C.AfterSettle{}

def data_198() -> List<&2, C.Task>:
  [data_196(), data_197(), data_108(), data_109()]

def data_199(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_198(), data_104()}

def data_200() -> C.Task:
  C.CommitIntake{0n}

def data_201() -> C.Task:
  C.TrimIntake{0n}

def data_202() -> C.Task:
  C.FinishSettleIntake{0n}

def data_203() -> List<&2, C.Task>:
  [data_200(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_204(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_203(), data_104()}

def data_205() -> C.Task:
  C.CommitPending{2n}

def data_206() -> C.Task:
  C.CommitIntake{1n}

def data_207() -> List<&2, C.Task>:
  [data_205(), data_206(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_208(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_207(), data_104()}

def data_209(+input: Nat) -> R.Node:
  R.Node{data_9(), data_91(input), data_2(), False{}, 0, 0, 0, 0n, data_93(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_210(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_209(input), data_186(initial, input)]

def data_211(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_210(initial, input), data_153(), data_23(), 1n, 0n, False{}, data_188(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_212() -> List<&2, C.Task>:
  [data_206(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_213(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_211(initial, input), data_212(), data_104()}

def data_214() -> C.Task:
  C.CommitPending{3n}

def data_215() -> C.Task:
  C.CommitIntake{2n}

def data_216() -> List<&2, C.Task>:
  [data_214(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_217(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_211(initial, input), data_216(), data_104()}

def data_218(+input: Nat) -> R.Node:
  R.Node{data_12(), data_164(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_219(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_209(input), data_218(input)]

def data_220(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_23(), 1n, 0n, False{}, data_188(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_221() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_222() -> List<&2, C.Task>:
  [data_221(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_223(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(initial, input), data_222(), data_104()}

def data_224() -> O.Task:
  O.TrimDeps{3n}

def data_225() -> List<&2, O.Task>:
  [data_224()]

def data_226() -> C.Task:
  C.OwnerTasks{data_225()}

def data_227() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_228() -> List<&2, C.Task>:
  [data_226(), data_227(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_229(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(initial, input), data_228(), data_104()}

def data_230() -> List<&2, O.Task>:
  []

def data_231() -> C.Task:
  C.OwnerTasks{data_230()}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_227(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_233(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(initial, input), data_232(), data_104()}

def data_234() -> List<&2, C.Task>:
  [data_227(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_235(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(initial, input), data_234(), data_104()}

def data_236() -> List<&2, C.Task>:
  [data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_237(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_220(initial, input), data_236(), data_104()}

def data_238(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_239() -> List<&2, C.Task>:
  [data_201(), data_202(), data_197(), data_108(), data_109()]

def data_240(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_239(), data_104()}

def data_241() -> List<&2, C.Task>:
  [data_202(), data_197(), data_108(), data_109()]

def data_242(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_241(), data_104()}

def data_243() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_244() -> C.Task:
  C.LandTransactions{data_243(), 0n}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_197(), data_108(), data_109()]

def data_246(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_245(), data_104()}

def data_247() -> C.Task:
  C.CompleteSettle{data_243()}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_197(), data_108(), data_109()]

def data_249(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_248(), data_104()}

def data_250() -> C.Task:
  C.ZombieLoop{data_24()}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_197(), data_108(), data_109()]

def data_252(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_251(), data_104()}

def data_253() -> List<&2, C.Task>:
  [data_197(), data_108(), data_109()]

def data_254(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_238(initial, input), data_253(), data_104()}

def data_255(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_256() -> C.Task:
  C.RenderQueue{}

def data_257() -> List<&2, C.Task>:
  [data_256(), data_108(), data_109()]

def data_258(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_255(initial, input), data_257(), data_104()}

def data_259() -> C.Task:
  C.UserQueue{}

def data_260() -> List<&2, C.Task>:
  [data_259(), data_108(), data_109()]

def data_261(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_255(initial, input), data_260(), data_104()}

def data_262() -> List<&2, C.Task>:
  [data_108(), data_109()]

def data_263(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_255(initial, input), data_262(), data_104()}

def data_264(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_155(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_100(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_80(), data_81(), data_2(), data_24(), data_89()}

def data_265() -> List<&2, C.Task>:
  [data_109()]

def data_266(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_264(initial, input), data_265(), data_104()}

def data_267() -> List<&2, C.Task>:
  []

def data_268(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_264(initial, input), data_267(), data_104()}

def origin(+initial: Nat) -> R.World:
  data_90(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_105(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_111(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_114(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_117(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_125(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_128(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_138(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_143(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_146(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_149(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_159(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_162(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_166(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_172(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_180(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_182(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_185(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_190(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_192(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_195(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_199(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_204(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_208(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_213(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_217(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_223(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_229(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_233(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_235(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_237(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_240(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_242(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_246(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_249(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_252(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_254(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_258(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_261(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_263(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_266(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_268(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_264(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
