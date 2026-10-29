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

def data_52() -> R.FromState:
  R.FromNone{}

def data_53() -> R.StreamPlan:
  R.StreamPlan{data_51(), False{}, data_2(), 0n, 0n, data_2(), data_52()}

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
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_45(), False{}, 0n, False{}, False{}, 0n}

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

def data_79() -> List<&2, R.KeptGuess>:
  []

def data_80() -> R.LaneState:
  R.LaneState{data_23(), data_44(), data_23(), data_77(), 0n, data_78(), data_23(), False{}, False{}, data_79(), data_23(), False{}}

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
  R.DeferredArena{data_85(), data_23(), data_86(), data_88()}

def data_90() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_50(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_91(+input: Nat) -> R.Value:
  R.Number{input}

def data_92(+input: Nat) -> R.Slot:
  R.Present{data_91(input)}

def data_93() -> R.Stamp:
  R.Stamped{2n}

def data_94(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_92(input), False{}, 0, 0, 0, 0n, data_93(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_95() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_96(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_95()]

def data_97() -> List<&2, Nat>:
  [3n]

def data_98() -> List<&2, Nat>:
  [2n]

def data_99() -> R.HostJob:
  R.FlushJob{}

def data_100() -> List<&2, R.HostJob>:
  [data_99()]

def data_101(+input: Nat) -> R.World:
  R.World{data_96(input), data_21(), data_97(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_102() -> C.Task:
  C.Round{}

def data_103() -> List<&2, C.Task>:
  [data_102()]

def data_104() -> List<&2, R.Value>:
  []

def data_105(+input: Nat) -> C.Machine:
  C.Machine{data_101(input), data_103(), data_104()}

def data_106(+input: Nat) -> R.World:
  R.World{data_96(input), data_21(), data_97(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_107() -> C.Task:
  C.RoundAfterSweep{}

def data_108() -> C.Task:
  C.FlushFinally{}

def data_109() -> C.Task:
  C.RoundEnd{}

def data_110() -> List<&2, C.Task>:
  [data_107(), data_108(), data_109()]

def data_111(+input: Nat) -> C.Machine:
  C.Machine{data_106(input), data_110(), data_104()}

def data_112() -> C.Task:
  C.HeapLoop{}

def data_113() -> List<&2, C.Task>:
  [data_112(), data_108(), data_109()]

def data_114(+input: Nat) -> C.Machine:
  C.Machine{data_106(input), data_113(), data_104()}

def data_115() -> C.Task:
  C.Recompute{3n, False{}}

def data_116() -> List<&2, C.Task>:
  [data_115(), data_112(), data_108(), data_109()]

def data_117(+input: Nat) -> C.Machine:
  C.Machine{data_106(input), data_116(), data_104()}

def data_118(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_17()]

def data_119() -> R.LaneMount:
  R.MountFalse{}

def data_120() -> R.LaneState:
  R.LaneState{data_23(), data_44(), data_23(), data_77(), 0n, data_119(), data_23(), False{}, False{}, data_79(), data_23(), False{}}

def data_121(+input: Nat) -> R.World:
  R.World{data_118(input), data_21(), data_22(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_120(), data_81(), data_2(), data_23(), data_89()}

def data_122() -> C.LanePass:
  C.LanePass{0n, data_78(), data_119()}

def data_123() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_122()}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_112(), data_108(), data_109()]

def data_125(+input: Nat) -> C.Machine:
  C.Machine{data_121(input), data_124(), data_104()}

def data_126() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_122()}

def data_127() -> List<&2, C.Task>:
  [data_126(), data_112(), data_108(), data_109()]

def data_128(+input: Nat) -> C.Machine:
  C.Machine{data_121(input), data_127(), data_104()}

def data_129() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_130(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_129()]

def data_131() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_132(+input: Nat) -> R.World:
  R.World{data_130(input), data_21(), data_22(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_131(), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_120(), data_81(), data_2(), data_23(), data_89()}

def data_133() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_134() -> R.Flight:
  R.FlightUndefined{}

def data_135() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, data_134(), data_104(), 0n, False{}, data_122()}

def data_136() -> C.Task:
  C.Finish{data_135()}

def data_137() -> List<&2, C.Task>:
  [data_133(), data_136(), data_112(), data_108(), data_109()]

def data_138(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_137(), data_104()}

def data_139() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_140() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_141() -> C.Task:
  C.Binary{0}

def data_142() -> List<&2, C.Task>:
  [data_139(), data_140(), data_141(), data_136(), data_112(), data_108(), data_109()]

def data_143(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_142(), data_104()}

def data_144() -> C.Task:
  C.ReadNode{2n}

def data_145() -> List<&2, C.Task>:
  [data_144(), data_140(), data_141(), data_136(), data_112(), data_108(), data_109()]

def data_146(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_145(), data_104()}

def data_147() -> C.Task:
  C.ReadPrepared{2n}

def data_148() -> List<&2, C.Task>:
  [data_147(), data_140(), data_141(), data_136(), data_112(), data_108(), data_109()]

def data_149(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_148(), data_104()}

def data_150() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_151(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_150()]

def data_152() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_153() -> List<&2, R.Link>:
  [data_19(), data_152()]

def data_154(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_91(input)}

def data_155(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_154(input)]

def data_156(+input: Nat) -> R.World:
  R.World{data_151(input), data_153(), data_22(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_120(), data_81(), data_2(), data_23(), data_89()}

def data_157() -> List<&2, C.Task>:
  [data_140(), data_141(), data_136(), data_112(), data_108(), data_109()]

def data_158(+input: Nat) -> List<&2, R.Value>:
  [data_91(input)]

def data_159(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_157(), data_158(input)}

def data_160() -> List<&2, C.Task>:
  [data_141(), data_136(), data_112(), data_108(), data_109()]

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_91(input)]

def data_162(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_160(), data_161(input)}

def data_163() -> List<&2, C.Task>:
  [data_136(), data_112(), data_108(), data_109()]

def data_164(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_165(+input: Nat) -> List<&2, R.Value>:
  [data_164(input)]

def data_166(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_163(), data_165(input)}

def data_167() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_168(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_167()]

def data_169(+input: Nat) -> R.World:
  R.World{data_168(input), data_153(), data_22(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_170(+input: Nat) -> C.Task:
  C.PassReleases{data_135(), 0n, data_164(input), False{}, False{}, False{}, data_31()}

def data_171(+input: Nat) -> List<&2, C.Task>:
  [data_170(input), data_112(), data_108(), data_109()]

def data_172(+input: Nat) -> C.Machine:
  C.Machine{data_169(input), data_171(input), data_104()}

def data_173(+input: Nat) -> R.Slot:
  R.Present{data_164(input)}

def data_174(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_173(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_175(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_174(input)]

def data_176(+input: Nat) -> R.World:
  R.World{data_175(input), data_153(), data_22(), 0n, 0n, False{}, data_98(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_177() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_178() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_179() -> List<&2, C.Task>:
  [data_177(), data_178(), data_112(), data_108(), data_109()]

def data_180(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_179(), data_104()}

def data_181() -> List<&2, C.Task>:
  [data_178(), data_112(), data_108(), data_109()]

def data_182(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_181(), data_104()}

def data_183() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_184() -> List<&2, C.Task>:
  [data_183(), data_112(), data_108(), data_109()]

def data_185(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_184(), data_104()}

def data_186(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_173(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_187(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(input), data_186(input)]

def data_188() -> List<&2, Nat>:
  [2n, 3n]

def data_189(+input: Nat) -> R.World:
  R.World{data_187(input), data_153(), data_22(), 0n, 0n, False{}, data_188(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_190(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_113(), data_104()}

def data_191(+input: Nat) -> R.World:
  R.World{data_187(input), data_153(), data_22(), 1n, 0n, False{}, data_188(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_192(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_113(), data_104()}

def data_193() -> C.Task:
  C.Seam{}

def data_194() -> List<&2, C.Task>:
  [data_193(), data_108(), data_109()]

def data_195(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_194(), data_104()}

def data_196() -> C.Task:
  C.Settle{}

def data_197() -> C.Task:
  C.AfterSettle{}

def data_198() -> List<&2, C.Task>:
  [data_196(), data_197(), data_108(), data_109()]

def data_199(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_198(), data_104()}

def data_200() -> C.Task:
  C.CommitIntake{0n}

def data_201() -> C.Task:
  C.TrimIntake{0n}

def data_202() -> C.Task:
  C.FinishSettleIntake{0n}

def data_203() -> List<&2, C.Task>:
  [data_200(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_203(), data_104()}

def data_205() -> C.Task:
  C.CommitPending{2n}

def data_206() -> C.Task:
  C.CommitIntake{1n}

def data_207() -> List<&2, C.Task>:
  [data_205(), data_206(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_208(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_207(), data_104()}

def data_209(+input: Nat) -> R.Node:
  R.Node{data_9(), data_91(input), data_2(), False{}, 0, 0, 0, 0n, data_93(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_210(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_209(input), data_186(input)]

def data_211(+input: Nat) -> R.World:
  R.World{data_210(input), data_153(), data_22(), 1n, 0n, False{}, data_188(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_212() -> List<&2, C.Task>:
  [data_206(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_211(input), data_212(), data_104()}

def data_214() -> C.Task:
  C.CommitPending{3n}

def data_215() -> C.Task:
  C.CommitIntake{2n}

def data_216() -> List<&2, C.Task>:
  [data_214(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_217(+input: Nat) -> C.Machine:
  C.Machine{data_211(input), data_216(), data_104()}

def data_218(+input: Nat) -> R.Node:
  R.Node{data_12(), data_164(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_219(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_209(input), data_218(input)]

def data_220(+input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_22(), 1n, 0n, False{}, data_188(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_221() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_222() -> List<&2, C.Task>:
  [data_221(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_223(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_222(), data_104()}

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

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_228(), data_104()}

def data_230() -> List<&2, O.Task>:
  []

def data_231() -> C.Task:
  C.OwnerTasks{data_230()}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_227(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_232(), data_104()}

def data_234() -> List<&2, C.Task>:
  [data_227(), data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_234(), data_104()}

def data_236() -> List<&2, C.Task>:
  [data_215(), data_201(), data_202(), data_197(), data_108(), data_109()]

def data_237(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_236(), data_104()}

def data_238(+input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_239() -> List<&2, C.Task>:
  [data_201(), data_202(), data_197(), data_108(), data_109()]

def data_240(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_239(), data_104()}

def data_241() -> List<&2, C.Task>:
  [data_202(), data_197(), data_108(), data_109()]

def data_242(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_241(), data_104()}

def data_243() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24(), data_23(), data_24()}

def data_244() -> C.Task:
  C.LandTransactions{data_243(), 0n}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_197(), data_108(), data_109()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_245(), data_104()}

def data_247() -> C.Task:
  C.CompleteSettle{data_243()}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_197(), data_108(), data_109()]

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_248(), data_104()}

def data_250() -> C.Task:
  C.ZombieLoop{data_23()}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_197(), data_108(), data_109()]

def data_252(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_251(), data_104()}

def data_253() -> List<&2, C.Task>:
  [data_197(), data_108(), data_109()]

def data_254(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_253(), data_104()}

def data_255(+input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_256() -> C.Task:
  C.RenderQueue{}

def data_257() -> List<&2, C.Task>:
  [data_256(), data_108(), data_109()]

def data_258(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_257(), data_104()}

def data_259() -> C.Task:
  C.UserQueue{}

def data_260() -> List<&2, C.Task>:
  [data_259(), data_108(), data_109()]

def data_261(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_260(), data_104()}

def data_262() -> List<&2, C.Task>:
  [data_108(), data_109()]

def data_263(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_262(), data_104()}

def data_264(+input: Nat) -> R.World:
  R.World{data_219(input), data_153(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_155(input), data_31(), False{}, data_23(), data_36(), data_39(), data_23(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_34(), data_44(), data_47(), data_49(), data_100(), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_34(), data_63(), data_65(), data_68(), 0n, data_44(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_23(), data_89()}

def data_265() -> List<&2, C.Task>:
  [data_109()]

def data_266(+input: Nat) -> C.Machine:
  C.Machine{data_264(input), data_265(), data_104()}

def data_267() -> List<&2, C.Task>:
  []

def data_268(+input: Nat) -> C.Machine:
  C.Machine{data_264(input), data_267(), data_104()}

def origin() -> R.World:
  data_90()

def state_0(+input: Nat) -> C.Machine:
  data_105(input)

def state_1(+input: Nat) -> C.Machine:
  data_111(input)

def state_2(+input: Nat) -> C.Machine:
  data_114(input)

def state_3(+input: Nat) -> C.Machine:
  data_117(input)

def state_4(+input: Nat) -> C.Machine:
  data_125(input)

def state_5(+input: Nat) -> C.Machine:
  data_128(input)

def state_6(+input: Nat) -> C.Machine:
  data_138(input)

def state_7(+input: Nat) -> C.Machine:
  data_143(input)

def state_8(+input: Nat) -> C.Machine:
  data_146(input)

def state_9(+input: Nat) -> C.Machine:
  data_149(input)

def state_10(+input: Nat) -> C.Machine:
  data_159(input)

def state_11(+input: Nat) -> C.Machine:
  data_162(input)

def state_12(+input: Nat) -> C.Machine:
  data_166(input)

def state_13(+input: Nat) -> C.Machine:
  data_172(input)

def state_14(+input: Nat) -> C.Machine:
  data_180(input)

def state_15(+input: Nat) -> C.Machine:
  data_182(input)

def state_16(+input: Nat) -> C.Machine:
  data_185(input)

def state_17(+input: Nat) -> C.Machine:
  data_190(input)

def state_18(+input: Nat) -> C.Machine:
  data_192(input)

def state_19(+input: Nat) -> C.Machine:
  data_195(input)

def state_20(+input: Nat) -> C.Machine:
  data_199(input)

def state_21(+input: Nat) -> C.Machine:
  data_204(input)

def state_22(+input: Nat) -> C.Machine:
  data_208(input)

def state_23(+input: Nat) -> C.Machine:
  data_213(input)

def state_24(+input: Nat) -> C.Machine:
  data_217(input)

def state_25(+input: Nat) -> C.Machine:
  data_223(input)

def state_26(+input: Nat) -> C.Machine:
  data_229(input)

def state_27(+input: Nat) -> C.Machine:
  data_233(input)

def state_28(+input: Nat) -> C.Machine:
  data_235(input)

def state_29(+input: Nat) -> C.Machine:
  data_237(input)

def state_30(+input: Nat) -> C.Machine:
  data_240(input)

def state_31(+input: Nat) -> C.Machine:
  data_242(input)

def state_32(+input: Nat) -> C.Machine:
  data_246(input)

def state_33(+input: Nat) -> C.Machine:
  data_249(input)

def state_34(+input: Nat) -> C.Machine:
  data_252(input)

def state_35(+input: Nat) -> C.Machine:
  data_254(input)

def state_36(+input: Nat) -> C.Machine:
  data_258(input)

def state_37(+input: Nat) -> C.Machine:
  data_261(input)

def state_38(+input: Nat) -> C.Machine:
  data_263(input)

def state_39(+input: Nat) -> C.Machine:
  data_266(input)

def state_40(+input: Nat) -> C.Machine:
  data_268(input)

def finalWorld(+input: Nat) -> R.World:
  data_264(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
