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
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10() -> R.Value:
  R.Number{0n}

def data_11() -> R.Node:
  R.Node{data_9(), data_10(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

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
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

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

def data_35() -> R.NodeExtension:
  R.NodeExtension{data_32(), 0n, data_1(), data_2(), 0n, 0n, data_33(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_34(), data_2(), 0n, data_1()}

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
  R.Transaction{data_23(), data_23(), data_24(), data_23(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_41()}

def data_43() -> List<&2, R.Transaction>:
  [data_42()]

def data_44() -> List<&2, List<&2, Nat>>:
  [data_23()]

def data_45() -> R.AsyncSettlement:
  R.Unresolved{}

def data_46() -> R.AsyncObject:
  R.AsyncObject{False{}, data_45(), data_23(), 0n}

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
  R.LaneState{data_23(), data_44(), data_23(), data_76(), 0n, data_77()}

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
  R.DeferredArena{data_83(), data_23(), data_84(), data_86()}

def data_88() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_50(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_89(+input: Nat) -> R.Value:
  R.Number{input}

def data_90(+input: Nat) -> R.Slot:
  R.Present{data_89(input)}

def data_91() -> R.Stamp:
  R.Stamped{2n}

def data_92(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_90(input), False{}, 0, 0, 0, 0n, data_91(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_93() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_94(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_93()]

def data_95() -> List<&2, Nat>:
  [3n]

def data_96() -> List<&2, Nat>:
  [2n]

def data_97() -> R.HostJob:
  R.FlushJob{}

def data_98() -> List<&2, R.HostJob>:
  [data_97()]

def data_99(+input: Nat) -> R.World:
  R.World{data_94(input), data_21(), data_95(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_100() -> C.Task:
  C.Round{}

def data_101() -> List<&2, C.Task>:
  [data_100()]

def data_102() -> List<&2, R.Value>:
  []

def data_103(+input: Nat) -> C.Machine:
  C.Machine{data_99(input), data_101(), data_102()}

def data_104(+input: Nat) -> R.World:
  R.World{data_94(input), data_21(), data_95(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_105() -> C.Task:
  C.RoundAfterSweep{}

def data_106() -> C.Task:
  C.FlushFinally{}

def data_107() -> C.Task:
  C.RoundEnd{}

def data_108() -> List<&2, C.Task>:
  [data_105(), data_106(), data_107()]

def data_109(+input: Nat) -> C.Machine:
  C.Machine{data_104(input), data_108(), data_102()}

def data_110() -> C.Task:
  C.HeapLoop{}

def data_111() -> List<&2, C.Task>:
  [data_110(), data_106(), data_107()]

def data_112(+input: Nat) -> C.Machine:
  C.Machine{data_104(input), data_111(), data_102()}

def data_113() -> C.Task:
  C.Recompute{3n, False{}}

def data_114() -> List<&2, C.Task>:
  [data_113(), data_110(), data_106(), data_107()]

def data_115(+input: Nat) -> C.Machine:
  C.Machine{data_104(input), data_114(), data_102()}

def data_116(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_17()]

def data_117() -> R.LaneMount:
  R.MountFalse{}

def data_118() -> R.LaneState:
  R.LaneState{data_23(), data_44(), data_23(), data_76(), 0n, data_117()}

def data_119(+input: Nat) -> R.World:
  R.World{data_116(input), data_21(), data_22(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_23(), data_87()}

def data_120() -> C.LanePass:
  C.LanePass{0n, data_77(), data_117()}

def data_121() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_120()}

def data_122() -> List<&2, C.Task>:
  [data_121(), data_110(), data_106(), data_107()]

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_119(input), data_122(), data_102()}

def data_124() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_120()}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_110(), data_106(), data_107()]

def data_126(+input: Nat) -> C.Machine:
  C.Machine{data_119(input), data_125(), data_102()}

def data_127() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_128(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_127()]

def data_129() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_130(+input: Nat) -> R.World:
  R.World{data_128(input), data_21(), data_22(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_129(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_23(), data_87()}

def data_131() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_132() -> R.Flight:
  R.FlightUndefined{}

def data_133() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, data_132(), data_102(), 0n, False{}, data_120()}

def data_134() -> C.Task:
  C.Finish{data_133()}

def data_135() -> List<&2, C.Task>:
  [data_131(), data_134(), data_110(), data_106(), data_107()]

def data_136(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_135(), data_102()}

def data_137() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_138() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_139() -> C.Task:
  C.Binary{0}

def data_140() -> List<&2, C.Task>:
  [data_137(), data_138(), data_139(), data_134(), data_110(), data_106(), data_107()]

def data_141(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_140(), data_102()}

def data_142() -> C.Task:
  C.ReadNode{2n}

def data_143() -> List<&2, C.Task>:
  [data_142(), data_138(), data_139(), data_134(), data_110(), data_106(), data_107()]

def data_144(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_143(), data_102()}

def data_145() -> C.Task:
  C.ReadPrepared{2n}

def data_146() -> List<&2, C.Task>:
  [data_145(), data_138(), data_139(), data_134(), data_110(), data_106(), data_107()]

def data_147(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_146(), data_102()}

def data_148() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_149(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_148()]

def data_150() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_151() -> List<&2, R.Link>:
  [data_19(), data_150()]

def data_152(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_89(input)}

def data_153(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_152(input)]

def data_154(+input: Nat) -> R.World:
  R.World{data_149(input), data_151(), data_22(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_118(), data_79(), data_2(), data_23(), data_87()}

def data_155() -> List<&2, C.Task>:
  [data_138(), data_139(), data_134(), data_110(), data_106(), data_107()]

def data_156(+input: Nat) -> List<&2, R.Value>:
  [data_89(input)]

def data_157(+input: Nat) -> C.Machine:
  C.Machine{data_154(input), data_155(), data_156(input)}

def data_158() -> List<&2, C.Task>:
  [data_139(), data_134(), data_110(), data_106(), data_107()]

def data_159(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_89(input)]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_154(input), data_158(), data_159(input)}

def data_161() -> List<&2, C.Task>:
  [data_134(), data_110(), data_106(), data_107()]

def data_162(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_163(+input: Nat) -> List<&2, R.Value>:
  [data_162(input)]

def data_164(+input: Nat) -> C.Machine:
  C.Machine{data_154(input), data_161(), data_163(input)}

def data_165() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_166(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_165()]

def data_167(+input: Nat) -> R.World:
  R.World{data_166(input), data_151(), data_22(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_168(+input: Nat) -> C.Task:
  C.PassReleases{data_133(), 0n, data_162(input), False{}, False{}, False{}, data_31()}

def data_169(+input: Nat) -> List<&2, C.Task>:
  [data_168(input), data_110(), data_106(), data_107()]

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_167(input), data_169(input), data_102()}

def data_171(+input: Nat) -> R.Slot:
  R.Present{data_162(input)}

def data_172(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_171(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_173(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_172(input)]

def data_174(+input: Nat) -> R.World:
  R.World{data_173(input), data_151(), data_22(), 0n, 0n, False{}, data_96(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_175() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_176() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_177() -> List<&2, C.Task>:
  [data_175(), data_176(), data_110(), data_106(), data_107()]

def data_178(+input: Nat) -> C.Machine:
  C.Machine{data_174(input), data_177(), data_102()}

def data_179() -> List<&2, C.Task>:
  [data_176(), data_110(), data_106(), data_107()]

def data_180(+input: Nat) -> C.Machine:
  C.Machine{data_174(input), data_179(), data_102()}

def data_181() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_182() -> List<&2, C.Task>:
  [data_181(), data_110(), data_106(), data_107()]

def data_183(+input: Nat) -> C.Machine:
  C.Machine{data_174(input), data_182(), data_102()}

def data_184(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_171(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_185(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(input), data_184(input)]

def data_186() -> List<&2, Nat>:
  [2n, 3n]

def data_187(+input: Nat) -> R.World:
  R.World{data_185(input), data_151(), data_22(), 0n, 0n, False{}, data_186(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_188(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_111(), data_102()}

def data_189(+input: Nat) -> R.World:
  R.World{data_185(input), data_151(), data_22(), 1n, 0n, False{}, data_186(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_190(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_111(), data_102()}

def data_191() -> C.Task:
  C.Seam{}

def data_192() -> List<&2, C.Task>:
  [data_191(), data_106(), data_107()]

def data_193(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_192(), data_102()}

def data_194() -> C.Task:
  C.Settle{}

def data_195() -> C.Task:
  C.AfterSettle{}

def data_196() -> List<&2, C.Task>:
  [data_194(), data_195(), data_106(), data_107()]

def data_197(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_196(), data_102()}

def data_198() -> C.Task:
  C.CommitIntake{0n}

def data_199() -> C.Task:
  C.TrimIntake{0n}

def data_200() -> C.Task:
  C.FinishSettleIntake{0n}

def data_201() -> List<&2, C.Task>:
  [data_198(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_202(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_201(), data_102()}

def data_203() -> C.Task:
  C.CommitPending{2n}

def data_204() -> C.Task:
  C.CommitIntake{1n}

def data_205() -> List<&2, C.Task>:
  [data_203(), data_204(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_206(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_205(), data_102()}

def data_207(+input: Nat) -> R.Node:
  R.Node{data_9(), data_89(input), data_2(), False{}, 0, 0, 0, 0n, data_91(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_208(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_207(input), data_184(input)]

def data_209(+input: Nat) -> R.World:
  R.World{data_208(input), data_151(), data_22(), 1n, 0n, False{}, data_186(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_210() -> List<&2, C.Task>:
  [data_204(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_211(+input: Nat) -> C.Machine:
  C.Machine{data_209(input), data_210(), data_102()}

def data_212() -> C.Task:
  C.CommitPending{3n}

def data_213() -> C.Task:
  C.CommitIntake{2n}

def data_214() -> List<&2, C.Task>:
  [data_212(), data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_209(input), data_214(), data_102()}

def data_216(+input: Nat) -> R.Node:
  R.Node{data_12(), data_162(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_217(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_207(input), data_216(input)]

def data_218(+input: Nat) -> R.World:
  R.World{data_217(input), data_151(), data_22(), 1n, 0n, False{}, data_186(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_219() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_220() -> List<&2, C.Task>:
  [data_219(), data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_221(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_220(), data_102()}

def data_222() -> O.Task:
  O.TrimDeps{3n}

def data_223() -> List<&2, O.Task>:
  [data_222()]

def data_224() -> C.Task:
  C.OwnerTasks{data_223()}

def data_225() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_226() -> List<&2, C.Task>:
  [data_224(), data_225(), data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_226(), data_102()}

def data_228() -> List<&2, O.Task>:
  []

def data_229() -> C.Task:
  C.OwnerTasks{data_228()}

def data_230() -> List<&2, C.Task>:
  [data_229(), data_225(), data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_231(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_230(), data_102()}

def data_232() -> List<&2, C.Task>:
  [data_225(), data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_232(), data_102()}

def data_234() -> List<&2, C.Task>:
  [data_213(), data_199(), data_200(), data_195(), data_106(), data_107()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_234(), data_102()}

def data_236(+input: Nat) -> R.World:
  R.World{data_217(input), data_151(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_237() -> List<&2, C.Task>:
  [data_199(), data_200(), data_195(), data_106(), data_107()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_237(), data_102()}

def data_239() -> List<&2, C.Task>:
  [data_200(), data_195(), data_106(), data_107()]

def data_240(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_239(), data_102()}

def data_241() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24(), data_23(), data_24()}

def data_242() -> C.Task:
  C.LandTransactions{data_241(), 0n}

def data_243() -> List<&2, C.Task>:
  [data_242(), data_195(), data_106(), data_107()]

def data_244(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_243(), data_102()}

def data_245() -> C.Task:
  C.CompleteSettle{data_241()}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_195(), data_106(), data_107()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_246(), data_102()}

def data_248() -> C.Task:
  C.ZombieLoop{data_23()}

def data_249() -> List<&2, C.Task>:
  [data_248(), data_195(), data_106(), data_107()]

def data_250(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_249(), data_102()}

def data_251() -> List<&2, C.Task>:
  [data_195(), data_106(), data_107()]

def data_252(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_251(), data_102()}

def data_253(+input: Nat) -> R.World:
  R.World{data_217(input), data_151(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_254() -> C.Task:
  C.RenderQueue{}

def data_255() -> List<&2, C.Task>:
  [data_254(), data_106(), data_107()]

def data_256(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_255(), data_102()}

def data_257() -> C.Task:
  C.UserQueue{}

def data_258() -> List<&2, C.Task>:
  [data_257(), data_106(), data_107()]

def data_259(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_258(), data_102()}

def data_260() -> List<&2, C.Task>:
  [data_106(), data_107()]

def data_261(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_260(), data_102()}

def data_262(+input: Nat) -> R.World:
  R.World{data_217(input), data_151(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_153(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_98(), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_34(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_78(), data_79(), data_2(), data_23(), data_87()}

def data_263() -> List<&2, C.Task>:
  [data_107()]

def data_264(+input: Nat) -> C.Machine:
  C.Machine{data_262(input), data_263(), data_102()}

def data_265() -> List<&2, C.Task>:
  []

def data_266(+input: Nat) -> C.Machine:
  C.Machine{data_262(input), data_265(), data_102()}

def origin() -> R.World:
  data_88()

def state_0(+input: Nat) -> C.Machine:
  data_103(input)

def state_1(+input: Nat) -> C.Machine:
  data_109(input)

def state_2(+input: Nat) -> C.Machine:
  data_112(input)

def state_3(+input: Nat) -> C.Machine:
  data_115(input)

def state_4(+input: Nat) -> C.Machine:
  data_123(input)

def state_5(+input: Nat) -> C.Machine:
  data_126(input)

def state_6(+input: Nat) -> C.Machine:
  data_136(input)

def state_7(+input: Nat) -> C.Machine:
  data_141(input)

def state_8(+input: Nat) -> C.Machine:
  data_144(input)

def state_9(+input: Nat) -> C.Machine:
  data_147(input)

def state_10(+input: Nat) -> C.Machine:
  data_157(input)

def state_11(+input: Nat) -> C.Machine:
  data_160(input)

def state_12(+input: Nat) -> C.Machine:
  data_164(input)

def state_13(+input: Nat) -> C.Machine:
  data_170(input)

def state_14(+input: Nat) -> C.Machine:
  data_178(input)

def state_15(+input: Nat) -> C.Machine:
  data_180(input)

def state_16(+input: Nat) -> C.Machine:
  data_183(input)

def state_17(+input: Nat) -> C.Machine:
  data_188(input)

def state_18(+input: Nat) -> C.Machine:
  data_190(input)

def state_19(+input: Nat) -> C.Machine:
  data_193(input)

def state_20(+input: Nat) -> C.Machine:
  data_197(input)

def state_21(+input: Nat) -> C.Machine:
  data_202(input)

def state_22(+input: Nat) -> C.Machine:
  data_206(input)

def state_23(+input: Nat) -> C.Machine:
  data_211(input)

def state_24(+input: Nat) -> C.Machine:
  data_215(input)

def state_25(+input: Nat) -> C.Machine:
  data_221(input)

def state_26(+input: Nat) -> C.Machine:
  data_227(input)

def state_27(+input: Nat) -> C.Machine:
  data_231(input)

def state_28(+input: Nat) -> C.Machine:
  data_233(input)

def state_29(+input: Nat) -> C.Machine:
  data_235(input)

def state_30(+input: Nat) -> C.Machine:
  data_238(input)

def state_31(+input: Nat) -> C.Machine:
  data_240(input)

def state_32(+input: Nat) -> C.Machine:
  data_244(input)

def state_33(+input: Nat) -> C.Machine:
  data_247(input)

def state_34(+input: Nat) -> C.Machine:
  data_250(input)

def state_35(+input: Nat) -> C.Machine:
  data_252(input)

def state_36(+input: Nat) -> C.Machine:
  data_256(input)

def state_37(+input: Nat) -> C.Machine:
  data_259(input)

def state_38(+input: Nat) -> C.Machine:
  data_261(input)

def state_39(+input: Nat) -> C.Machine:
  data_264(input)

def state_40(+input: Nat) -> C.Machine:
  data_266(input)

def finalWorld(+input: Nat) -> R.World:
  data_262(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
