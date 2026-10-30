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

def data_36() -> R.Value:
  R.Null{}

def data_37() -> R.Flight:
  R.FlightUndefined{}

def data_38() -> R.NodeExtension:
  R.NodeExtension{data_33(), 0n, data_1(), data_2(), 0n, 0n, data_34(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_35(), data_2(), 0n, data_36(), data_37()}

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
  R.Transaction{data_24(), data_24(), data_25(), data_24(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_44()}

def data_46() -> List<&2, R.Transaction>:
  [data_45()]

def data_47() -> List<&2, List<&2, Nat>>:
  [data_24()]

def data_48() -> R.AsyncSettlement:
  R.Unresolved{}

def data_49() -> R.AsyncObject:
  R.AsyncObject{False{}, data_48(), data_24(), 0n}

def data_50() -> List<&2, R.AsyncObject>:
  [data_49()]

def data_51() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_52() -> List<&2, R.AsyncObserver>:
  [data_51()]

def data_53() -> List<&2, R.HostJob>:
  []

def data_54() -> List<&2, R.NextInput>:
  []

def data_55() -> R.FromState:
  R.FromNone{}

def data_56() -> R.StreamPlan:
  R.StreamPlan{data_54(), False{}, data_2(), 0n, 0n, data_2(), data_55()}

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

def data_80() -> List<&2, R.Guess>:
  []

def data_81() -> R.LaneMount:
  R.MountUnset{}

def data_82() -> List<&2, R.KeptGuess>:
  []

def data_83() -> R.LaneState:
  R.LaneState{data_24(), data_47(), data_24(), data_80(), 0n, data_81(), data_24(), False{}, False{}, data_82(), data_24(), False{}, data_24()}

def data_84() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_85() -> R.DeferredCell:
  R.DeferredCell{0n, data_36(), False{}, False{}}

def data_86() -> R.DeferredBinding:
  R.DeferredBinding{data_85(), 0n}

def data_87() -> List<&2, R.DeferredBinding>:
  [data_86()]

def data_88() -> List<&2, R.DeferredWait>:
  []

def data_89() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_90() -> List<&2, R.DeferredIterator>:
  [data_89()]

def data_91() -> R.DeferredArena:
  R.DeferredArena{data_87(), data_24(), data_88(), data_90()}

def data_92(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_53(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_93(+input: Nat) -> R.Value:
  R.Number{input}

def data_94(+input: Nat) -> R.Slot:
  R.Present{data_93(input)}

def data_95() -> R.Stamp:
  R.Stamped{2n}

def data_96(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_94(input), False{}, 0, 0, 0, 0n, data_95(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_97(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_98(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_97(initial)]

def data_99() -> List<&2, Nat>:
  [3n]

def data_100() -> List<&2, Nat>:
  [2n]

def data_101() -> R.HostJob:
  R.FlushJob{}

def data_102() -> List<&2, R.HostJob>:
  [data_101()]

def data_103(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_98(initial, input), data_22(), data_99(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_104() -> C.Task:
  C.Round{}

def data_105() -> List<&2, C.Task>:
  [data_104()]

def data_106() -> List<&2, R.Value>:
  []

def data_107(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_103(initial, input), data_105(), data_106()}

def data_108(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_98(initial, input), data_22(), data_99(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_109() -> C.Task:
  C.RoundAfterSweep{}

def data_110() -> C.Task:
  C.FlushFinally{}

def data_111() -> C.Task:
  C.RoundEnd{}

def data_112() -> List<&2, C.Task>:
  [data_109(), data_110(), data_111()]

def data_113(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, input), data_112(), data_106()}

def data_114() -> C.Task:
  C.HeapLoop{}

def data_115() -> List<&2, C.Task>:
  [data_114(), data_110(), data_111()]

def data_116(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, input), data_115(), data_106()}

def data_117() -> C.Task:
  C.Recompute{3n, False{}}

def data_118() -> List<&2, C.Task>:
  [data_117(), data_114(), data_110(), data_111()]

def data_119(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, input), data_118(), data_106()}

def data_120(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_18(initial)]

def data_121() -> R.LaneMount:
  R.MountFalse{}

def data_122() -> R.LaneState:
  R.LaneState{data_24(), data_47(), data_24(), data_80(), 0n, data_121(), data_24(), False{}, False{}, data_82(), data_24(), False{}, data_24()}

def data_123(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_120(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_24(), data_91()}

def data_124() -> C.LanePass:
  C.LanePass{0n, data_81(), data_121(), False{}}

def data_125() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_124()}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_114(), data_110(), data_111()]

def data_127(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_123(initial, input), data_126(), data_106()}

def data_128() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_124()}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_114(), data_110(), data_111()]

def data_130(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_123(initial, input), data_129(), data_106()}

def data_131(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_132(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_131(initial)]

def data_133(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_134(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_132(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_133(initial), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_24(), data_91()}

def data_135(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_136() -> R.Value:
  R.Number{0n}

def data_137(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_136(), 0n, False{}, data_37(), data_106(), 0n, False{}, data_124()}

def data_138(+initial: Nat) -> C.Task:
  C.Finish{data_137(initial)}

def data_139(+initial: Nat) -> List<&2, C.Task>:
  [data_135(initial), data_138(initial), data_114(), data_110(), data_111()]

def data_140(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, input), data_139(initial), data_106()}

def data_141(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_142(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_143() -> C.Task:
  C.Binary{0}

def data_144(+initial: Nat) -> List<&2, C.Task>:
  [data_141(initial), data_142(initial), data_143(), data_138(initial), data_114(), data_110(), data_111()]

def data_145(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, input), data_144(initial), data_106()}

def data_146() -> C.Task:
  C.ReadNode{2n}

def data_147(+initial: Nat) -> List<&2, C.Task>:
  [data_146(), data_142(initial), data_143(), data_138(initial), data_114(), data_110(), data_111()]

def data_148(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, input), data_147(initial), data_106()}

def data_149() -> C.Task:
  C.ReadPrepared{2n}

def data_150(+initial: Nat) -> List<&2, C.Task>:
  [data_149(), data_142(initial), data_143(), data_138(initial), data_114(), data_110(), data_111()]

def data_151(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, input), data_150(initial), data_106()}

def data_152(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_153(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_152(initial)]

def data_154() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_155() -> List<&2, R.Link>:
  [data_20(), data_154()]

def data_156(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_93(input)}

def data_157(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_156(input)]

def data_158(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_153(initial, input), data_155(), data_23(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_24(), data_91()}

def data_159(+initial: Nat) -> List<&2, C.Task>:
  [data_142(initial), data_143(), data_138(initial), data_114(), data_110(), data_111()]

def data_160(+input: Nat) -> List<&2, R.Value>:
  [data_93(input)]

def data_161(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, input), data_159(initial), data_160(input)}

def data_162(+initial: Nat) -> List<&2, C.Task>:
  [data_143(), data_138(initial), data_114(), data_110(), data_111()]

def data_163(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_93(input)]

def data_164(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, input), data_162(initial), data_163(input)}

def data_165(+initial: Nat) -> List<&2, C.Task>:
  [data_138(initial), data_114(), data_110(), data_111()]

def data_166(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_167(+input: Nat) -> List<&2, R.Value>:
  [data_166(input)]

def data_168(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, input), data_165(initial), data_167(input)}

def data_169(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_170(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_169(initial)]

def data_171(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_170(initial, input), data_155(), data_23(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_172(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_137(initial), 0n, data_166(input), False{}, False{}, False{}, data_32()}

def data_173(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_172(initial, input), data_114(), data_110(), data_111()]

def data_174(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_171(initial, input), data_173(initial, input), data_106()}

def data_175(+input: Nat) -> R.Slot:
  R.Present{data_166(input)}

def data_176(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_175(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_177(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_176(initial, input)]

def data_178(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_177(initial, input), data_155(), data_23(), 0n, 0n, False{}, data_100(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_179() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_180() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_181() -> List<&2, C.Task>:
  [data_179(), data_180(), data_114(), data_110(), data_111()]

def data_182(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, input), data_181(), data_106()}

def data_183() -> List<&2, C.Task>:
  [data_180(), data_114(), data_110(), data_111()]

def data_184(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, input), data_183(), data_106()}

def data_185() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_186() -> List<&2, C.Task>:
  [data_185(), data_114(), data_110(), data_111()]

def data_187(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, input), data_186(), data_106()}

def data_188(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_175(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_189(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(initial, input), data_188(initial, input)]

def data_190() -> List<&2, Nat>:
  [2n, 3n]

def data_191(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_189(initial, input), data_155(), data_23(), 0n, 0n, False{}, data_190(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_192(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, input), data_115(), data_106()}

def data_193(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_189(initial, input), data_155(), data_23(), 1n, 0n, False{}, data_190(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_194(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, input), data_115(), data_106()}

def data_195() -> C.Task:
  C.Seam{}

def data_196() -> List<&2, C.Task>:
  [data_195(), data_110(), data_111()]

def data_197(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, input), data_196(), data_106()}

def data_198() -> C.Task:
  C.Settle{}

def data_199() -> C.Task:
  C.AfterSettle{}

def data_200() -> List<&2, C.Task>:
  [data_198(), data_199(), data_110(), data_111()]

def data_201(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, input), data_200(), data_106()}

def data_202() -> C.Task:
  C.CommitIntake{0n}

def data_203() -> C.Task:
  C.TrimIntake{0n}

def data_204() -> C.Task:
  C.FinishSettleIntake{0n}

def data_205() -> List<&2, C.Task>:
  [data_202(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_206(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, input), data_205(), data_106()}

def data_207() -> C.Task:
  C.CommitPending{2n}

def data_208() -> C.Task:
  C.CommitIntake{1n}

def data_209() -> List<&2, C.Task>:
  [data_207(), data_208(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_210(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, input), data_209(), data_106()}

def data_211(+input: Nat) -> R.Node:
  R.Node{data_9(), data_93(input), data_2(), False{}, 0, 0, 0, 0n, data_95(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_212(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_211(input), data_188(initial, input)]

def data_213(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_212(initial, input), data_155(), data_23(), 1n, 0n, False{}, data_190(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_214() -> List<&2, C.Task>:
  [data_208(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_215(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_213(initial, input), data_214(), data_106()}

def data_216() -> C.Task:
  C.CommitPending{3n}

def data_217() -> C.Task:
  C.CommitIntake{2n}

def data_218() -> List<&2, C.Task>:
  [data_216(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_219(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_213(initial, input), data_218(), data_106()}

def data_220(+input: Nat) -> R.Node:
  R.Node{data_12(), data_166(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_221(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_211(input), data_220(input)]

def data_222(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_23(), 1n, 0n, False{}, data_190(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_223() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_224() -> List<&2, C.Task>:
  [data_223(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_225(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, input), data_224(), data_106()}

def data_226() -> O.Task:
  O.TrimDeps{3n}

def data_227() -> List<&2, O.Task>:
  [data_226()]

def data_228() -> C.Task:
  C.OwnerTasks{data_227()}

def data_229() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_230() -> List<&2, C.Task>:
  [data_228(), data_229(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_231(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, input), data_230(), data_106()}

def data_232() -> List<&2, O.Task>:
  []

def data_233() -> C.Task:
  C.OwnerTasks{data_232()}

def data_234() -> List<&2, C.Task>:
  [data_233(), data_229(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_235(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, input), data_234(), data_106()}

def data_236() -> List<&2, C.Task>:
  [data_229(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_237(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, input), data_236(), data_106()}

def data_238() -> List<&2, C.Task>:
  [data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_239(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, input), data_238(), data_106()}

def data_240(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_241() -> List<&2, C.Task>:
  [data_203(), data_204(), data_199(), data_110(), data_111()]

def data_242(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_241(), data_106()}

def data_243() -> List<&2, C.Task>:
  [data_204(), data_199(), data_110(), data_111()]

def data_244(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_243(), data_106()}

def data_245() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_246() -> C.Task:
  C.LandTransactions{data_245(), 0n}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_199(), data_110(), data_111()]

def data_248(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_247(), data_106()}

def data_249() -> C.Task:
  C.CompleteSettle{data_245()}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_199(), data_110(), data_111()]

def data_251(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_250(), data_106()}

def data_252() -> C.Task:
  C.ZombieLoop{data_24()}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_199(), data_110(), data_111()]

def data_254(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_253(), data_106()}

def data_255() -> List<&2, C.Task>:
  [data_199(), data_110(), data_111()]

def data_256(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, input), data_255(), data_106()}

def data_257(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_258() -> C.Task:
  C.RenderQueue{}

def data_259() -> List<&2, C.Task>:
  [data_258(), data_110(), data_111()]

def data_260(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, input), data_259(), data_106()}

def data_261() -> C.Task:
  C.UserQueue{}

def data_262() -> List<&2, C.Task>:
  [data_261(), data_110(), data_111()]

def data_263(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, input), data_262(), data_106()}

def data_264() -> List<&2, C.Task>:
  [data_110(), data_111()]

def data_265(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, input), data_264(), data_106()}

def data_266(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_157(initial, input), data_32(), False{}, data_24(), data_39(), data_42(), data_24(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_35(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_24(), data_91()}

def data_267() -> List<&2, C.Task>:
  [data_111()]

def data_268(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_266(initial, input), data_267(), data_106()}

def data_269() -> List<&2, C.Task>:
  []

def data_270(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_266(initial, input), data_269(), data_106()}

def origin(+initial: Nat) -> R.World:
  data_92(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_107(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_113(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_116(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_119(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_127(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_130(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_140(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_145(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_148(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_151(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_161(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_164(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_168(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_174(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_182(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_184(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_187(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_192(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_194(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_197(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_201(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_206(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_210(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_215(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_219(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_225(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_231(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_235(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_237(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_239(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_242(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_244(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_248(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_251(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_254(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_256(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_260(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_263(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_265(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_268(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_270(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_266(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
