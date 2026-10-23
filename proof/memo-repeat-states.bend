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

def data_36() -> R.Flight:
  R.FlightEmpty{}

def data_37() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_38() -> R.Question:
  R.QuestionZero{}

def data_39() -> R.NodeExtension:
  R.NodeExtension{data_36(), 0n, data_1(), data_2(), 0n, 0n, data_37(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_38(), data_2(), 0n, data_1()}

def data_40() -> List<&2, R.NodeExtension>:
  [data_39()]

def data_41() -> List<&2, R.CleanupAction>:
  []

def data_42() -> R.CleanupProgram:
  R.CleanupProgram{data_41(), False{}, 0n}

def data_43() -> List<&2, R.CleanupProgram>:
  [data_42()]

def data_44() -> List<&2, R.Report>:
  []

def data_45() -> R.OptionalIds:
  R.NoIds{}

def data_46() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_45()}

def data_47() -> List<&2, R.Transaction>:
  [data_46()]

def data_48() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_49() -> R.AsyncSettlement:
  R.Unresolved{}

def data_50() -> R.AsyncObject:
  R.AsyncObject{False{}, data_49(), data_25(), 0n}

def data_51() -> List<&2, R.AsyncObject>:
  [data_50()]

def data_52() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_53() -> List<&2, R.AsyncObserver>:
  [data_52()]

def data_54() -> R.HostJob:
  R.FlushJob{}

def data_55() -> List<&2, R.HostJob>:
  [data_54()]

def data_56() -> List<&2, R.NextInput>:
  []

def data_57() -> R.StreamPlan:
  R.StreamPlan{data_56(), False{}, data_2(), 0n, 0n, data_2()}

def data_58() -> List<&2, R.StreamPlan>:
  [data_57()]

def data_59() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_60() -> List<&2, R.ExternalIterator>:
  [data_59()]

def data_61() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_62() -> List<&2, R.StreamState>:
  [data_61()]

def data_63() -> List<&2, R.IteratorEvent>:
  []

def data_64() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_49(), False{}, 0n, False{}, False{}, 0n}

def data_65() -> List<&2, R.Awaiter>:
  [data_64()]

def data_66() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_67() -> List<&2, R.AbortInput>:
  [data_66()]

def data_68() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_69() -> List<&2, R.ContextKey>:
  [data_68()]

def data_70() -> List<&2, R.ContextEntry>:
  []

def data_71() -> R.ContextRecord:
  R.ContextRecord{data_70()}

def data_72() -> List<&2, R.ContextRecord>:
  [data_71()]

def data_73() -> List<&2, R.Expr>:
  [data_4()]

def data_74() -> List<&2, R.ReactionState>:
  []

def data_75() -> List<&2, R.ComparatorBinding>:
  []

def data_76() -> List<&2, R.ActionState>:
  []

def data_77() -> List<&2, R.ActionWait>:
  []

def data_78() -> List<&2, R.ArrayData>:
  []

def data_79() -> List<&2, R.RepeatState>:
  []

def data_80() -> List<&2, R.MapState>:
  []

def data_81() -> List<&2, R.Guess>:
  []

def data_82() -> R.LaneMount:
  R.MountUnset{}

def data_83() -> R.LaneState:
  R.LaneState{data_25(), data_48(), data_25(), data_81(), 0n, data_82()}

def data_84() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_85() -> R.Value:
  R.Null{}

def data_86() -> R.DeferredCell:
  R.DeferredCell{0n, data_85(), False{}, False{}}

def data_87() -> R.DeferredBinding:
  R.DeferredBinding{data_86(), 0n}

def data_88() -> List<&2, R.DeferredBinding>:
  [data_87()]

def data_89() -> List<&2, R.DeferredWait>:
  []

def data_90() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_91() -> List<&2, R.DeferredIterator>:
  [data_90()]

def data_92() -> R.DeferredArena:
  R.DeferredArena{data_88(), data_25(), data_89(), data_91()}

def data_93(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_55(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_94(+input: Nat) -> R.Value:
  R.Number{input}

def data_95(+input: Nat) -> R.Slot:
  R.Present{data_94(input)}

def data_96() -> R.Stamp:
  R.Stamped{3n}

def data_97(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_95(input), False{}, 0, 0, 0, 0n, data_96(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_98(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_99(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_98(first)]

def data_100() -> List<&2, Nat>:
  [3n]

def data_101() -> List<&2, Nat>:
  [2n]

def data_102() -> List<&2, R.HostJob>:
  [data_54(), data_54()]

def data_103(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_99(first, input), data_23(), data_100(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_104() -> C.Task:
  C.Round{}

def data_105() -> List<&2, C.Task>:
  [data_104()]

def data_106() -> List<&2, R.Value>:
  []

def data_107(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_103(initial, first, input), data_105(), data_106()}

def data_108(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_99(first, input), data_23(), data_100(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_109() -> C.Task:
  C.RoundAfterSweep{}

def data_110() -> C.Task:
  C.FlushFinally{}

def data_111() -> C.Task:
  C.RoundEnd{}

def data_112() -> List<&2, C.Task>:
  [data_109(), data_110(), data_111()]

def data_113(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, first, input), data_112(), data_106()}

def data_114() -> C.Task:
  C.HeapLoop{}

def data_115() -> List<&2, C.Task>:
  [data_114(), data_110(), data_111()]

def data_116(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, first, input), data_115(), data_106()}

def data_117() -> C.Task:
  C.Recompute{3n, False{}}

def data_118() -> List<&2, C.Task>:
  [data_117(), data_114(), data_110(), data_111()]

def data_119(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_108(initial, first, input), data_118(), data_106()}

def data_120(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_19(first)]

def data_121() -> R.LaneMount:
  R.MountFalse{}

def data_122() -> R.LaneState:
  R.LaneState{data_25(), data_48(), data_25(), data_81(), 0n, data_121()}

def data_123(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_120(first, input), data_23(), data_24(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_122(), data_84(), data_2(), data_25(), data_92()}

def data_124() -> C.LanePass:
  C.LanePass{0n, data_82(), data_121()}

def data_125() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_124()}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_114(), data_110(), data_111()]

def data_127(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_123(initial, first, input), data_126(), data_106()}

def data_128() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_124()}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_114(), data_110(), data_111()]

def data_130(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_123(initial, first, input), data_129(), data_106()}

def data_131(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_132(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_131(first)]

def data_133(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_134(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_132(first, input), data_23(), data_24(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_133(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_122(), data_84(), data_2(), data_25(), data_92()}

def data_135(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_136() -> R.Flight:
  R.FlightUndefined{}

def data_137(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, data_136(), data_106(), 0n, False{}, data_124()}

def data_138(+first: Nat) -> C.Task:
  C.Finish{data_137(first)}

def data_139(+first: Nat) -> List<&2, C.Task>:
  [data_135(first), data_138(first), data_114(), data_110(), data_111()]

def data_140(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, first, input), data_139(first), data_106()}

def data_141(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_142(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_143() -> C.Task:
  C.Binary{0}

def data_144(+first: Nat) -> List<&2, C.Task>:
  [data_141(first), data_142(first), data_143(), data_138(first), data_114(), data_110(), data_111()]

def data_145(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, first, input), data_144(first), data_106()}

def data_146() -> C.Task:
  C.ReadNode{2n}

def data_147(+first: Nat) -> List<&2, C.Task>:
  [data_146(), data_142(first), data_143(), data_138(first), data_114(), data_110(), data_111()]

def data_148(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, first, input), data_147(first), data_106()}

def data_149() -> C.Task:
  C.ReadPrepared{2n}

def data_150(+first: Nat) -> List<&2, C.Task>:
  [data_149(), data_142(first), data_143(), data_138(first), data_114(), data_110(), data_111()]

def data_151(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_134(initial, first, input), data_150(first), data_106()}

def data_152(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_153(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_152(first)]

def data_154() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_155() -> List<&2, R.Link>:
  [data_21(), data_154()]

def data_156(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_94(input)}

def data_157(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_156(input)]

def data_158(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_153(first, input), data_155(), data_24(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_122(), data_84(), data_2(), data_25(), data_92()}

def data_159(+first: Nat) -> List<&2, C.Task>:
  [data_142(first), data_143(), data_138(first), data_114(), data_110(), data_111()]

def data_160(+input: Nat) -> List<&2, R.Value>:
  [data_94(input)]

def data_161(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, first, input), data_159(first), data_160(input)}

def data_162(+first: Nat) -> List<&2, C.Task>:
  [data_143(), data_138(first), data_114(), data_110(), data_111()]

def data_163(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_94(input)]

def data_164(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, first, input), data_162(first), data_163(input)}

def data_165(+first: Nat) -> List<&2, C.Task>:
  [data_138(first), data_114(), data_110(), data_111()]

def data_166(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_167(+input: Nat) -> List<&2, R.Value>:
  [data_166(input)]

def data_168(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_158(initial, first, input), data_165(first), data_167(input)}

def data_169(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_170(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_169(first)]

def data_171(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_170(first, input), data_155(), data_24(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_172(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_137(first), 0n, data_166(input), False{}, False{}, False{}, data_35()}

def data_173(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_172(first, input), data_114(), data_110(), data_111()]

def data_174(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_171(initial, first, input), data_173(first, input), data_106()}

def data_175(+input: Nat) -> R.Slot:
  R.Present{data_166(input)}

def data_176(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_175(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_177(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_176(first, input)]

def data_178(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_177(first, input), data_155(), data_24(), 0n, 0n, False{}, data_101(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_179() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_180() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_181() -> List<&2, C.Task>:
  [data_179(), data_180(), data_114(), data_110(), data_111()]

def data_182(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_181(), data_106()}

def data_183() -> List<&2, C.Task>:
  [data_180(), data_114(), data_110(), data_111()]

def data_184(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_183(), data_106()}

def data_185() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_186() -> List<&2, C.Task>:
  [data_185(), data_114(), data_110(), data_111()]

def data_187(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_178(initial, first, input), data_186(), data_106()}

def data_188(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_175(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_189(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(first, input), data_188(first, input)]

def data_190() -> List<&2, Nat>:
  [2n, 3n]

def data_191(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_189(first, input), data_155(), data_24(), 0n, 0n, False{}, data_190(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_192(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_191(initial, first, input), data_115(), data_106()}

def data_193(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_189(first, input), data_155(), data_24(), 1n, 0n, False{}, data_190(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_194(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, first, input), data_115(), data_106()}

def data_195() -> C.Task:
  C.Seam{}

def data_196() -> List<&2, C.Task>:
  [data_195(), data_110(), data_111()]

def data_197(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, first, input), data_196(), data_106()}

def data_198() -> C.Task:
  C.Settle{}

def data_199() -> C.Task:
  C.AfterSettle{}

def data_200() -> List<&2, C.Task>:
  [data_198(), data_199(), data_110(), data_111()]

def data_201(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, first, input), data_200(), data_106()}

def data_202() -> C.Task:
  C.CommitIntake{0n}

def data_203() -> C.Task:
  C.TrimIntake{0n}

def data_204() -> C.Task:
  C.FinishSettleIntake{0n}

def data_205() -> List<&2, C.Task>:
  [data_202(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_206(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, first, input), data_205(), data_106()}

def data_207() -> C.Task:
  C.CommitPending{2n}

def data_208() -> C.Task:
  C.CommitIntake{1n}

def data_209() -> List<&2, C.Task>:
  [data_207(), data_208(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_210(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_193(initial, first, input), data_209(), data_106()}

def data_211(+input: Nat) -> R.Node:
  R.Node{data_9(), data_94(input), data_2(), False{}, 0, 0, 0, 0n, data_96(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_212(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_211(input), data_188(first, input)]

def data_213(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_212(first, input), data_155(), data_24(), 1n, 0n, False{}, data_190(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_214() -> List<&2, C.Task>:
  [data_208(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_215(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_213(initial, first, input), data_214(), data_106()}

def data_216() -> C.Task:
  C.CommitPending{3n}

def data_217() -> C.Task:
  C.CommitIntake{2n}

def data_218() -> List<&2, C.Task>:
  [data_216(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_219(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_213(initial, first, input), data_218(), data_106()}

def data_220(+input: Nat) -> R.Node:
  R.Node{data_13(), data_166(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_221(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_211(input), data_220(input)]

def data_222(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_24(), 1n, 0n, False{}, data_190(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_223() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_224() -> List<&2, C.Task>:
  [data_223(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_225(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_224(), data_106()}

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

def data_231(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_230(), data_106()}

def data_232() -> List<&2, O.Task>:
  []

def data_233() -> C.Task:
  C.OwnerTasks{data_232()}

def data_234() -> List<&2, C.Task>:
  [data_233(), data_229(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_235(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_234(), data_106()}

def data_236() -> List<&2, C.Task>:
  [data_229(), data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_237(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_236(), data_106()}

def data_238() -> List<&2, C.Task>:
  [data_217(), data_203(), data_204(), data_199(), data_110(), data_111()]

def data_239(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_222(initial, first, input), data_238(), data_106()}

def data_240(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_241() -> List<&2, C.Task>:
  [data_203(), data_204(), data_199(), data_110(), data_111()]

def data_242(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_241(), data_106()}

def data_243() -> List<&2, C.Task>:
  [data_204(), data_199(), data_110(), data_111()]

def data_244(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_243(), data_106()}

def data_245() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_246() -> C.Task:
  C.LandTransactions{data_245(), 0n}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_199(), data_110(), data_111()]

def data_248(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_247(), data_106()}

def data_249() -> C.Task:
  C.CompleteSettle{data_245()}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_199(), data_110(), data_111()]

def data_251(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_250(), data_106()}

def data_252() -> C.Task:
  C.ZombieLoop{data_25()}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_199(), data_110(), data_111()]

def data_254(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_253(), data_106()}

def data_255() -> List<&2, C.Task>:
  [data_199(), data_110(), data_111()]

def data_256(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_240(initial, first, input), data_255(), data_106()}

def data_257(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_258() -> C.Task:
  C.RenderQueue{}

def data_259() -> List<&2, C.Task>:
  [data_258(), data_110(), data_111()]

def data_260(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, first, input), data_259(), data_106()}

def data_261() -> C.Task:
  C.UserQueue{}

def data_262() -> List<&2, C.Task>:
  [data_261(), data_110(), data_111()]

def data_263(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, first, input), data_262(), data_106()}

def data_264() -> List<&2, C.Task>:
  [data_110(), data_111()]

def data_265(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_257(initial, first, input), data_264(), data_106()}

def data_266(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_221(input), data_155(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_157(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_102(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_38(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_83(), data_84(), data_2(), data_25(), data_92()}

def data_267() -> List<&2, C.Task>:
  [data_111()]

def data_268(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_266(initial, first, input), data_267(), data_106()}

def data_269() -> List<&2, C.Task>:
  []

def data_270(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_266(initial, first, input), data_269(), data_106()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_93(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_107(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_113(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_116(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_119(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_127(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_130(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_140(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_145(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_148(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_151(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_161(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_164(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_168(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_174(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_182(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_184(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_187(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_192(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_194(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_197(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_201(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_206(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_210(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_215(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_219(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_225(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_231(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_235(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_237(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_239(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_242(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_244(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_248(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_251(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_254(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_256(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_260(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_263(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_265(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_268(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_270(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_266(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
