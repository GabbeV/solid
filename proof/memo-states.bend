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
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10() -> R.Value:
  R.Number{0n}

def data_11() -> R.Node:
  R.Node{data_9(), data_10(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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

def data_32() -> R.Flight:
  R.FlightEmpty{}

def data_33() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_34() -> R.Question:
  R.QuestionZero{}

def data_35() -> R.Value:
  R.Null{}

def data_36() -> R.Flight:
  R.FlightUndefined{}

def data_37() -> R.AskedIn:
  R.Unasked{}

def data_38() -> R.NodeExtension:
  R.NodeExtension{data_32(), 0n, data_1(), data_2(), 0n, 0n, data_33(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_34(), data_2(), 0n, data_35(), data_36(), data_3(), data_37()}

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
  R.Transaction{data_23(), data_23(), data_24(), data_23(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_44(), False{}, 0n}

def data_46() -> List<&2, R.Transaction>:
  [data_45()]

def data_47() -> List<&2, List<&2, Nat>>:
  [data_23()]

def data_48() -> R.AsyncSettlement:
  R.Unresolved{}

def data_49() -> R.AsyncObject:
  R.AsyncObject{False{}, data_48(), data_23(), 0n}

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
  R.LaneState{data_23(), data_47(), data_23(), data_80(), 0n, data_81(), data_23(), False{}, False{}, data_82(), data_23(), False{}, data_23(), data_23()}

def data_84() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_85() -> R.DeferredCell:
  R.DeferredCell{0n, data_35(), False{}, False{}}

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
  R.DeferredArena{data_87(), data_23(), data_88(), data_90()}

def data_92() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_53(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_93(+input: Nat) -> R.Value:
  R.Number{input}

def data_94(+input: Nat) -> R.Slot:
  R.Present{data_93(input)}

def data_95() -> R.Stamp:
  R.Stamped{2n}

def data_96(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_94(input), False{}, 0, 0, 0, 0n, data_95(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_97() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_98(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_97()]

def data_99() -> List<&2, Nat>:
  [3n]

def data_100() -> List<&2, Nat>:
  [2n]

def data_101() -> R.HostJob:
  R.FlushJob{}

def data_102() -> List<&2, R.HostJob>:
  [data_101()]

def data_103(+input: Nat) -> R.World:
  R.World{data_98(input), data_21(), data_99(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_104() -> C.Task:
  C.Round{}

def data_105() -> List<&2, C.Task>:
  [data_104()]

def data_106() -> List<&2, R.Value>:
  []

def data_107(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_105(), data_106()}

def data_108(+input: Nat) -> R.World:
  R.World{data_98(input), data_21(), data_99(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_109() -> C.Task:
  C.RoundAfterSweep{}

def data_110() -> C.Task:
  C.FlushFinally{}

def data_111() -> C.Task:
  C.RoundEnd{}

def data_112() -> List<&2, C.Task>:
  [data_109(), data_110(), data_111()]

def data_113(+input: Nat) -> C.Machine:
  C.Machine{data_108(input), data_112(), data_106()}

def data_114() -> C.Task:
  C.HeapLoop{}

def data_115() -> List<&2, C.Task>:
  [data_114(), data_110(), data_111()]

def data_116(+input: Nat) -> C.Machine:
  C.Machine{data_108(input), data_115(), data_106()}

def data_117() -> C.Task:
  C.Recompute{3n, False{}}

def data_118() -> List<&2, C.Task>:
  [data_117(), data_114(), data_110(), data_111()]

def data_119(+input: Nat) -> C.Machine:
  C.Machine{data_108(input), data_118(), data_106()}

def data_120(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_17()]

def data_121() -> R.LaneMount:
  R.MountFalse{}

def data_122() -> R.LaneState:
  R.LaneState{data_23(), data_47(), data_23(), data_80(), 0n, data_121(), data_23(), False{}, False{}, data_82(), data_23(), False{}, data_23(), data_23()}

def data_123(+input: Nat) -> R.World:
  R.World{data_120(input), data_21(), data_22(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_23(), data_91()}

def data_124() -> C.LanePass:
  C.LanePass{0n, data_81(), data_121(), False{}, data_2(), False{}}

def data_125() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_124()}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_114(), data_110(), data_111()]

def data_127(+input: Nat) -> C.Machine:
  C.Machine{data_123(input), data_126(), data_106()}

def data_128() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_124()}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_114(), data_110(), data_111()]

def data_130(+input: Nat) -> C.Machine:
  C.Machine{data_123(input), data_129(), data_106()}

def data_131() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_132(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_131()]

def data_133() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_134(+input: Nat) -> R.World:
  R.World{data_132(input), data_21(), data_22(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_133(), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_23(), data_91()}

def data_135() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_136() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_10(), 0n, False{}, data_36(), data_106(), 0n, False{}, data_124()}

def data_137() -> C.Task:
  C.Finish{data_136()}

def data_138() -> List<&2, C.Task>:
  [data_135(), data_137(), data_114(), data_110(), data_111()]

def data_139(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_138(), data_106()}

def data_140() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_141() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_142() -> C.Task:
  C.Binary{0}

def data_143() -> List<&2, C.Task>:
  [data_140(), data_141(), data_142(), data_137(), data_114(), data_110(), data_111()]

def data_144(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_143(), data_106()}

def data_145() -> C.Task:
  C.ReadNode{2n}

def data_146() -> List<&2, C.Task>:
  [data_145(), data_141(), data_142(), data_137(), data_114(), data_110(), data_111()]

def data_147(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_146(), data_106()}

def data_148() -> C.Task:
  C.ReadPrepared{2n}

def data_149() -> List<&2, C.Task>:
  [data_148(), data_141(), data_142(), data_137(), data_114(), data_110(), data_111()]

def data_150(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_149(), data_106()}

def data_151(+netted: Bool) -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, B.choose(~U32,netted,_=>4,_=>16388), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_152(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_151(netted)]

def data_153() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_154() -> List<&2, R.Link>:
  [data_19(), data_153()]

def data_155(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_93(input)}

def data_156(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_155(input)]

def data_157(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_152(netted, input), data_154(), data_22(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_122(), data_84(), data_2(), data_23(), data_91()}

def data_158() -> List<&2, C.Task>:
  [data_141(), data_142(), data_137(), data_114(), data_110(), data_111()]

def data_159(+input: Nat) -> List<&2, R.Value>:
  [data_93(input)]

def data_160(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_157(netted, input), data_158(), data_159(input)}

def data_161() -> List<&2, C.Task>:
  [data_142(), data_137(), data_114(), data_110(), data_111()]

def data_162(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_93(input)]

def data_163(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_157(netted, input), data_161(), data_162(input)}

def data_164() -> List<&2, C.Task>:
  [data_137(), data_114(), data_110(), data_111()]

def data_165(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_166(+input: Nat) -> List<&2, R.Value>:
  [data_165(input)]

def data_167(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_157(netted, input), data_164(), data_166(input)}

def data_168(+netted: Bool) -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_169(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_168(netted)]

def data_170(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_169(netted, input), data_154(), data_22(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_171(+input: Nat) -> C.Task:
  C.PassReleases{data_136(), 0n, data_165(input), False{}, False{}, False{}, data_31()}

def data_172(+input: Nat) -> List<&2, C.Task>:
  [data_171(input), data_114(), data_110(), data_111()]

def data_173(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_170(netted, input), data_172(input), data_106()}

def data_174(+input: Nat) -> R.Slot:
  R.Present{data_165(input)}

def data_175(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_174(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_176(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_175(netted, input)]

def data_177(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_176(netted, input), data_154(), data_22(), 0n, 0n, False{}, data_100(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_178() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_179() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_180() -> List<&2, C.Task>:
  [data_178(), data_179(), data_114(), data_110(), data_111()]

def data_181(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_177(netted, input), data_180(), data_106()}

def data_182() -> List<&2, C.Task>:
  [data_179(), data_114(), data_110(), data_111()]

def data_183(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_177(netted, input), data_182(), data_106()}

def data_184() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_185() -> List<&2, C.Task>:
  [data_184(), data_114(), data_110(), data_111()]

def data_186(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_177(netted, input), data_185(), data_106()}

def data_187(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_174(input), False{}, 128, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_188(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_96(input), data_187(netted, input)]

def data_189() -> List<&2, Nat>:
  [2n, 3n]

def data_190(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_188(netted, input), data_154(), data_22(), 0n, 0n, False{}, data_189(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_191(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_190(netted, input), data_115(), data_106()}

def data_192(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_188(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_189(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_193(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, input), data_115(), data_106()}

def data_194() -> C.Task:
  C.Seam{}

def data_195() -> List<&2, C.Task>:
  [data_194(), data_110(), data_111()]

def data_196(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, input), data_195(), data_106()}

def data_197() -> C.Task:
  C.Settle{}

def data_198() -> C.Task:
  C.AfterSettle{}

def data_199() -> List<&2, C.Task>:
  [data_197(), data_198(), data_110(), data_111()]

def data_200(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, input), data_199(), data_106()}

def data_201() -> C.Task:
  C.CommitIntake{0n}

def data_202() -> C.Task:
  C.TrimIntake{0n}

def data_203() -> C.Task:
  C.FinishSettleIntake{0n}

def data_204() -> List<&2, C.Task>:
  [data_201(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_205(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, input), data_204(), data_106()}

def data_206() -> C.Task:
  C.CommitPending{2n}

def data_207() -> C.Task:
  C.CommitIntake{1n}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_209(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, input), data_208(), data_106()}

def data_210(+input: Nat) -> R.Node:
  R.Node{data_9(), data_93(input), data_2(), False{}, 0, 0, 0, 0n, data_95(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_211(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_210(input), data_187(netted, input)]

def data_212(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_211(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_189(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_213() -> List<&2, C.Task>:
  [data_207(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_214(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_212(netted, input), data_213(), data_106()}

def data_215() -> C.Task:
  C.CommitPending{3n}

def data_216() -> C.Task:
  C.CommitIntake{2n}

def data_217() -> List<&2, C.Task>:
  [data_215(), data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_218(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_212(netted, input), data_217(), data_106()}

def data_219(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_165(input), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_220(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_210(input), data_219(netted, input)]

def data_221(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_220(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_189(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_222() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_223() -> List<&2, C.Task>:
  [data_222(), data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_224(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_223(), data_106()}

def data_225() -> O.Task:
  O.TrimDeps{3n}

def data_226() -> List<&2, O.Task>:
  [data_225()]

def data_227() -> C.Task:
  C.OwnerTasks{data_226()}

def data_228() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_229() -> List<&2, C.Task>:
  [data_227(), data_228(), data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_230(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_229(), data_106()}

def data_231() -> List<&2, O.Task>:
  []

def data_232() -> C.Task:
  C.OwnerTasks{data_231()}

def data_233() -> List<&2, C.Task>:
  [data_232(), data_228(), data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_234(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_233(), data_106()}

def data_235() -> List<&2, C.Task>:
  [data_228(), data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_236(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_235(), data_106()}

def data_237() -> List<&2, C.Task>:
  [data_216(), data_202(), data_203(), data_198(), data_110(), data_111()]

def data_238(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_237(), data_106()}

def data_239(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_220(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_240() -> List<&2, C.Task>:
  [data_202(), data_203(), data_198(), data_110(), data_111()]

def data_241(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_240(), data_106()}

def data_242() -> List<&2, C.Task>:
  [data_203(), data_198(), data_110(), data_111()]

def data_243(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_242(), data_106()}

def data_244() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24(), data_23(), data_24()}

def data_245() -> C.Task:
  C.LandTransactions{data_244(), 0n}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_198(), data_110(), data_111()]

def data_247(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_246(), data_106()}

def data_248() -> C.Task:
  C.CompleteSettle{data_244()}

def data_249() -> List<&2, C.Task>:
  [data_248(), data_198(), data_110(), data_111()]

def data_250(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_249(), data_106()}

def data_251() -> C.Task:
  C.ZombieLoop{data_23()}

def data_252() -> List<&2, C.Task>:
  [data_251(), data_198(), data_110(), data_111()]

def data_253(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_252(), data_106()}

def data_254() -> List<&2, C.Task>:
  [data_198(), data_110(), data_111()]

def data_255(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_239(netted, input), data_254(), data_106()}

def data_256(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_220(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_257() -> C.Task:
  C.RenderQueue{}

def data_258() -> List<&2, C.Task>:
  [data_257(), data_110(), data_111()]

def data_259(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_256(netted, input), data_258(), data_106()}

def data_260() -> C.Task:
  C.UserQueue{}

def data_261() -> List<&2, C.Task>:
  [data_260(), data_110(), data_111()]

def data_262(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_256(netted, input), data_261(), data_106()}

def data_263() -> List<&2, C.Task>:
  [data_110(), data_111()]

def data_264(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_256(netted, input), data_263(), data_106()}

def data_265(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_220(netted, input), data_154(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_156(input), data_31(), False{}, data_23(), data_39(), data_42(), data_23(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_47(), data_50(), data_52(), data_102(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_34(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_83(), data_84(), data_2(), data_23(), data_91()}

def data_266() -> List<&2, C.Task>:
  [data_111()]

def data_267(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_265(netted, input), data_266(), data_106()}

def data_268() -> List<&2, C.Task>:
  []

def data_269(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_265(netted, input), data_268(), data_106()}

def origin() -> R.World:
  data_92()

def at_0(+netted: Bool, +input: Nat) -> C.Machine:
  data_107(input)

def state_0(+input: Nat) -> C.Machine:
  at_0(Nat.is_eq(input, 0n), input)

def at_1(+netted: Bool, +input: Nat) -> C.Machine:
  data_113(input)

def state_1(+input: Nat) -> C.Machine:
  at_1(Nat.is_eq(input, 0n), input)

def at_2(+netted: Bool, +input: Nat) -> C.Machine:
  data_116(input)

def state_2(+input: Nat) -> C.Machine:
  at_2(Nat.is_eq(input, 0n), input)

def at_3(+netted: Bool, +input: Nat) -> C.Machine:
  data_119(input)

def state_3(+input: Nat) -> C.Machine:
  at_3(Nat.is_eq(input, 0n), input)

def at_4(+netted: Bool, +input: Nat) -> C.Machine:
  data_127(input)

def state_4(+input: Nat) -> C.Machine:
  at_4(Nat.is_eq(input, 0n), input)

def at_5(+netted: Bool, +input: Nat) -> C.Machine:
  data_130(input)

def state_5(+input: Nat) -> C.Machine:
  at_5(Nat.is_eq(input, 0n), input)

def at_6(+netted: Bool, +input: Nat) -> C.Machine:
  data_139(input)

def state_6(+input: Nat) -> C.Machine:
  at_6(Nat.is_eq(input, 0n), input)

def at_7(+netted: Bool, +input: Nat) -> C.Machine:
  data_144(input)

def state_7(+input: Nat) -> C.Machine:
  at_7(Nat.is_eq(input, 0n), input)

def at_8(+netted: Bool, +input: Nat) -> C.Machine:
  data_147(input)

def state_8(+input: Nat) -> C.Machine:
  at_8(Nat.is_eq(input, 0n), input)

def at_9(+netted: Bool, +input: Nat) -> C.Machine:
  data_150(input)

def state_9(+input: Nat) -> C.Machine:
  at_9(Nat.is_eq(input, 0n), input)

def at_10(+netted: Bool, +input: Nat) -> C.Machine:
  data_160(netted, input)

def state_10(+input: Nat) -> C.Machine:
  at_10(Nat.is_eq(input, 0n), input)

def at_11(+netted: Bool, +input: Nat) -> C.Machine:
  data_163(netted, input)

def state_11(+input: Nat) -> C.Machine:
  at_11(Nat.is_eq(input, 0n), input)

def at_12(+netted: Bool, +input: Nat) -> C.Machine:
  data_167(netted, input)

def state_12(+input: Nat) -> C.Machine:
  at_12(Nat.is_eq(input, 0n), input)

def at_13(+netted: Bool, +input: Nat) -> C.Machine:
  data_173(netted, input)

def state_13(+input: Nat) -> C.Machine:
  at_13(Nat.is_eq(input, 0n), input)

def at_14(+netted: Bool, +input: Nat) -> C.Machine:
  data_181(netted, input)

def state_14(+input: Nat) -> C.Machine:
  at_14(Nat.is_eq(input, 0n), input)

def at_15(+netted: Bool, +input: Nat) -> C.Machine:
  data_183(netted, input)

def state_15(+input: Nat) -> C.Machine:
  at_15(Nat.is_eq(input, 0n), input)

def at_16(+netted: Bool, +input: Nat) -> C.Machine:
  data_186(netted, input)

def state_16(+input: Nat) -> C.Machine:
  at_16(Nat.is_eq(input, 0n), input)

def at_17(+netted: Bool, +input: Nat) -> C.Machine:
  data_191(netted, input)

def state_17(+input: Nat) -> C.Machine:
  at_17(Nat.is_eq(input, 0n), input)

def at_18(+netted: Bool, +input: Nat) -> C.Machine:
  data_193(netted, input)

def state_18(+input: Nat) -> C.Machine:
  at_18(Nat.is_eq(input, 0n), input)

def at_19(+netted: Bool, +input: Nat) -> C.Machine:
  data_196(netted, input)

def state_19(+input: Nat) -> C.Machine:
  at_19(Nat.is_eq(input, 0n), input)

def at_20(+netted: Bool, +input: Nat) -> C.Machine:
  data_200(netted, input)

def state_20(+input: Nat) -> C.Machine:
  at_20(Nat.is_eq(input, 0n), input)

def at_21(+netted: Bool, +input: Nat) -> C.Machine:
  data_205(netted, input)

def state_21(+input: Nat) -> C.Machine:
  at_21(Nat.is_eq(input, 0n), input)

def at_22(+netted: Bool, +input: Nat) -> C.Machine:
  data_209(netted, input)

def state_22(+input: Nat) -> C.Machine:
  at_22(Nat.is_eq(input, 0n), input)

def at_23(+netted: Bool, +input: Nat) -> C.Machine:
  data_214(netted, input)

def state_23(+input: Nat) -> C.Machine:
  at_23(Nat.is_eq(input, 0n), input)

def at_24(+netted: Bool, +input: Nat) -> C.Machine:
  data_218(netted, input)

def state_24(+input: Nat) -> C.Machine:
  at_24(Nat.is_eq(input, 0n), input)

def at_25(+netted: Bool, +input: Nat) -> C.Machine:
  data_224(netted, input)

def state_25(+input: Nat) -> C.Machine:
  at_25(Nat.is_eq(input, 0n), input)

def at_26(+netted: Bool, +input: Nat) -> C.Machine:
  data_230(netted, input)

def state_26(+input: Nat) -> C.Machine:
  at_26(Nat.is_eq(input, 0n), input)

def at_27(+netted: Bool, +input: Nat) -> C.Machine:
  data_234(netted, input)

def state_27(+input: Nat) -> C.Machine:
  at_27(Nat.is_eq(input, 0n), input)

def at_28(+netted: Bool, +input: Nat) -> C.Machine:
  data_236(netted, input)

def state_28(+input: Nat) -> C.Machine:
  at_28(Nat.is_eq(input, 0n), input)

def at_29(+netted: Bool, +input: Nat) -> C.Machine:
  data_238(netted, input)

def state_29(+input: Nat) -> C.Machine:
  at_29(Nat.is_eq(input, 0n), input)

def at_30(+netted: Bool, +input: Nat) -> C.Machine:
  data_241(netted, input)

def state_30(+input: Nat) -> C.Machine:
  at_30(Nat.is_eq(input, 0n), input)

def at_31(+netted: Bool, +input: Nat) -> C.Machine:
  data_243(netted, input)

def state_31(+input: Nat) -> C.Machine:
  at_31(Nat.is_eq(input, 0n), input)

def at_32(+netted: Bool, +input: Nat) -> C.Machine:
  data_247(netted, input)

def state_32(+input: Nat) -> C.Machine:
  at_32(Nat.is_eq(input, 0n), input)

def at_33(+netted: Bool, +input: Nat) -> C.Machine:
  data_250(netted, input)

def state_33(+input: Nat) -> C.Machine:
  at_33(Nat.is_eq(input, 0n), input)

def at_34(+netted: Bool, +input: Nat) -> C.Machine:
  data_253(netted, input)

def state_34(+input: Nat) -> C.Machine:
  at_34(Nat.is_eq(input, 0n), input)

def at_35(+netted: Bool, +input: Nat) -> C.Machine:
  data_255(netted, input)

def state_35(+input: Nat) -> C.Machine:
  at_35(Nat.is_eq(input, 0n), input)

def at_36(+netted: Bool, +input: Nat) -> C.Machine:
  data_259(netted, input)

def state_36(+input: Nat) -> C.Machine:
  at_36(Nat.is_eq(input, 0n), input)

def at_37(+netted: Bool, +input: Nat) -> C.Machine:
  data_262(netted, input)

def state_37(+input: Nat) -> C.Machine:
  at_37(Nat.is_eq(input, 0n), input)

def at_38(+netted: Bool, +input: Nat) -> C.Machine:
  data_264(netted, input)

def state_38(+input: Nat) -> C.Machine:
  at_38(Nat.is_eq(input, 0n), input)

def at_39(+netted: Bool, +input: Nat) -> C.Machine:
  data_267(netted, input)

def state_39(+input: Nat) -> C.Machine:
  at_39(Nat.is_eq(input, 0n), input)

def at_40(+netted: Bool, +input: Nat) -> C.Machine:
  data_269(netted, input)

def state_40(+input: Nat) -> C.Machine:
  at_40(Nat.is_eq(input, 0n), input)

def finalAt(+netted: Bool, +input: Nat) -> R.World:
  data_265(netted, input)

def finalWorld(+input: Nat) -> R.World:
  finalAt(Nat.is_eq(input, 0n), input)

# Algebraic publication cut over both source netted-read postures.
def publicationAt_13(+netted: Bool, +input: Nat) ->
  {C.publishValue(C.world(at_13(netted, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(at_14(netted, input)), True{}} : B.Bundle<R.World, Bool>}:
  match netted:
    case True{}: {==}
    case False{}: {==}

def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  publicationAt_13(Nat.is_eq(input, 0n), input)
