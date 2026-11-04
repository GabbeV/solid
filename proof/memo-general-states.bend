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
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10(+initial: Nat) -> R.Value:
  R.Number{initial}

def data_11(+initial: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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

def data_38() -> R.AskedIn:
  R.Unasked{}

def data_39() -> R.NodeExtension:
  R.NodeExtension{data_33(), 0n, data_1(), data_2(), 0n, 0n, data_34(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_35(), data_2(), 0n, data_36(), data_37(), data_3(), data_38()}

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
  R.Transaction{data_24(), data_24(), data_25(), data_24(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_45(), False{}, 0n}

def data_47() -> List<&2, R.Transaction>:
  [data_46()]

def data_48() -> List<&2, List<&2, Nat>>:
  [data_24()]

def data_49() -> R.AsyncSettlement:
  R.Unresolved{}

def data_50() -> R.AsyncObject:
  R.AsyncObject{False{}, data_49(), data_24(), 0n}

def data_51() -> List<&2, R.AsyncObject>:
  [data_50()]

def data_52() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_53() -> List<&2, R.AsyncObserver>:
  [data_52()]

def data_54() -> List<&2, R.HostJob>:
  []

def data_55() -> List<&2, R.NextInput>:
  []

def data_56() -> R.FromState:
  R.FromNone{}

def data_57() -> R.StreamPlan:
  R.StreamPlan{data_55(), False{}, data_2(), 0n, 0n, data_2(), data_56()}

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

def data_83() -> List<&2, R.KeptGuess>:
  []

def data_84() -> R.LaneState:
  R.LaneState{data_24(), data_48(), data_24(), data_81(), 0n, data_82(), data_24(), False{}, False{}, data_83(), data_24(), False{}, data_24(), data_24()}

def data_85() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_86() -> R.DeferredCell:
  R.DeferredCell{0n, data_36(), False{}, False{}}

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
  R.DeferredArena{data_88(), data_24(), data_89(), data_91()}

def data_93(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_54(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_94(+input: Nat) -> R.Value:
  R.Number{input}

def data_95(+input: Nat) -> R.Slot:
  R.Present{data_94(input)}

def data_96() -> R.Stamp:
  R.Stamped{2n}

def data_97(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_95(input), False{}, 0, 0, 0, 0n, data_96(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_98(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_99(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_98(initial)]

def data_100() -> List<&2, Nat>:
  [3n]

def data_101() -> List<&2, Nat>:
  [2n]

def data_102() -> R.HostJob:
  R.FlushJob{}

def data_103() -> List<&2, R.HostJob>:
  [data_102()]

def data_104(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_99(initial, input), data_22(), data_100(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_105() -> C.Task:
  C.Round{}

def data_106() -> List<&2, C.Task>:
  [data_105()]

def data_107() -> List<&2, R.Value>:
  []

def data_108(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_104(initial, input), data_106(), data_107()}

def data_109(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_99(initial, input), data_22(), data_100(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_110() -> C.Task:
  C.RoundAfterSweep{}

def data_111() -> C.Task:
  C.FlushFinally{}

def data_112() -> C.Task:
  C.RoundEnd{}

def data_113() -> List<&2, C.Task>:
  [data_110(), data_111(), data_112()]

def data_114(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, input), data_113(), data_107()}

def data_115() -> C.Task:
  C.HeapLoop{}

def data_116() -> List<&2, C.Task>:
  [data_115(), data_111(), data_112()]

def data_117(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, input), data_116(), data_107()}

def data_118() -> C.Task:
  C.Recompute{3n, False{}}

def data_119() -> List<&2, C.Task>:
  [data_118(), data_115(), data_111(), data_112()]

def data_120(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, input), data_119(), data_107()}

def data_121(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_18(initial)]

def data_122() -> R.LaneMount:
  R.MountFalse{}

def data_123() -> R.LaneState:
  R.LaneState{data_24(), data_48(), data_24(), data_81(), 0n, data_122(), data_24(), False{}, False{}, data_83(), data_24(), False{}, data_24(), data_24()}

def data_124(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_121(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_123(), data_85(), data_2(), data_24(), data_92()}

def data_125() -> C.LanePass:
  C.LanePass{0n, data_82(), data_122(), False{}, data_2(), False{}}

def data_126() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_125()}

def data_127() -> List<&2, C.Task>:
  [data_126(), data_115(), data_111(), data_112()]

def data_128(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_124(initial, input), data_127(), data_107()}

def data_129() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_125()}

def data_130() -> List<&2, C.Task>:
  [data_129(), data_115(), data_111(), data_112()]

def data_131(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_124(initial, input), data_130(), data_107()}

def data_132(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_133(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_132(initial)]

def data_134(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_135(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_133(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_134(initial), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_123(), data_85(), data_2(), data_24(), data_92()}

def data_136(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_137() -> R.Value:
  R.Number{0n}

def data_138(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_137(), 0n, False{}, data_37(), data_107(), 0n, False{}, data_125()}

def data_139(+initial: Nat) -> C.Task:
  C.Finish{data_138(initial)}

def data_140(+initial: Nat) -> List<&2, C.Task>:
  [data_136(initial), data_139(initial), data_115(), data_111(), data_112()]

def data_141(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, input), data_140(initial), data_107()}

def data_142(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_143(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_144() -> C.Task:
  C.Binary{0}

def data_145(+initial: Nat) -> List<&2, C.Task>:
  [data_142(initial), data_143(initial), data_144(), data_139(initial), data_115(), data_111(), data_112()]

def data_146(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, input), data_145(initial), data_107()}

def data_147() -> C.Task:
  C.ReadNode{2n}

def data_148(+initial: Nat) -> List<&2, C.Task>:
  [data_147(), data_143(initial), data_144(), data_139(initial), data_115(), data_111(), data_112()]

def data_149(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, input), data_148(initial), data_107()}

def data_150() -> C.Task:
  C.ReadPrepared{2n}

def data_151(+initial: Nat) -> List<&2, C.Task>:
  [data_150(), data_143(initial), data_144(), data_139(initial), data_115(), data_111(), data_112()]

def data_152(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, input), data_151(initial), data_107()}

def data_153(+netted: Bool, +initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, B.choose(~U32,netted,_=>4,_=>16388), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_154(+netted: Bool, +initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_153(netted, initial)]

def data_155() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_156() -> List<&2, R.Link>:
  [data_20(), data_155()]

def data_157(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_94(input)}

def data_158(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_157(input)]

def data_159(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_154(netted, initial, input), data_156(), data_23(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_123(), data_85(), data_2(), data_24(), data_92()}

def data_160(+initial: Nat) -> List<&2, C.Task>:
  [data_143(initial), data_144(), data_139(initial), data_115(), data_111(), data_112()]

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_94(input)]

def data_162(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(netted, initial, input), data_160(initial), data_161(input)}

def data_163(+initial: Nat) -> List<&2, C.Task>:
  [data_144(), data_139(initial), data_115(), data_111(), data_112()]

def data_164(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_94(input)]

def data_165(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(netted, initial, input), data_163(initial), data_164(input)}

def data_166(+initial: Nat) -> List<&2, C.Task>:
  [data_139(initial), data_115(), data_111(), data_112()]

def data_167(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_168(+input: Nat) -> List<&2, R.Value>:
  [data_167(input)]

def data_169(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(netted, initial, input), data_166(initial), data_168(input)}

def data_170(+netted: Bool, +initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_171(+netted: Bool, +initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_170(netted, initial)]

def data_172(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_171(netted, initial, input), data_156(), data_23(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_173(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_138(initial), 0n, data_167(input), False{}, False{}, False{}, data_32()}

def data_174(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_173(initial, input), data_115(), data_111(), data_112()]

def data_175(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_172(netted, initial, input), data_174(initial, input), data_107()}

def data_176(+input: Nat) -> R.Slot:
  R.Present{data_167(input)}

def data_177(+netted: Bool, +initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_176(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_178(+netted: Bool, +initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_177(netted, initial, input)]

def data_179(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_178(netted, initial, input), data_156(), data_23(), 0n, 0n, False{}, data_101(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_180() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_181() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_182() -> List<&2, C.Task>:
  [data_180(), data_181(), data_115(), data_111(), data_112()]

def data_183(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(netted, initial, input), data_182(), data_107()}

def data_184() -> List<&2, C.Task>:
  [data_181(), data_115(), data_111(), data_112()]

def data_185(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(netted, initial, input), data_184(), data_107()}

def data_186() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_187() -> List<&2, C.Task>:
  [data_186(), data_115(), data_111(), data_112()]

def data_188(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(netted, initial, input), data_187(), data_107()}

def data_189(+netted: Bool, +initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_176(input), False{}, 128, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_190(+netted: Bool, +initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_97(initial, input), data_189(netted, initial, input)]

def data_191() -> List<&2, Nat>:
  [2n, 3n]

def data_192(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_190(netted, initial, input), data_156(), data_23(), 0n, 0n, False{}, data_191(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_193(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(netted, initial, input), data_116(), data_107()}

def data_194(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_190(netted, initial, input), data_156(), data_23(), 1n, 0n, False{}, data_191(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_195(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(netted, initial, input), data_116(), data_107()}

def data_196() -> C.Task:
  C.Seam{}

def data_197() -> List<&2, C.Task>:
  [data_196(), data_111(), data_112()]

def data_198(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(netted, initial, input), data_197(), data_107()}

def data_199() -> C.Task:
  C.Settle{}

def data_200() -> C.Task:
  C.AfterSettle{}

def data_201() -> List<&2, C.Task>:
  [data_199(), data_200(), data_111(), data_112()]

def data_202(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(netted, initial, input), data_201(), data_107()}

def data_203() -> C.Task:
  C.CommitIntake{0n}

def data_204() -> C.Task:
  C.TrimIntake{0n}

def data_205() -> C.Task:
  C.FinishSettleIntake{0n}

def data_206() -> List<&2, C.Task>:
  [data_203(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_207(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(netted, initial, input), data_206(), data_107()}

def data_208() -> C.Task:
  C.CommitPending{2n}

def data_209() -> C.Task:
  C.CommitIntake{1n}

def data_210() -> List<&2, C.Task>:
  [data_208(), data_209(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_211(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(netted, initial, input), data_210(), data_107()}

def data_212(+input: Nat) -> R.Node:
  R.Node{data_9(), data_94(input), data_2(), False{}, 0, 0, 0, 0n, data_96(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_213(+netted: Bool, +initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_212(input), data_189(netted, initial, input)]

def data_214(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_213(netted, initial, input), data_156(), data_23(), 1n, 0n, False{}, data_191(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_215() -> List<&2, C.Task>:
  [data_209(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_216(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_214(netted, initial, input), data_215(), data_107()}

def data_217() -> C.Task:
  C.CommitPending{3n}

def data_218() -> C.Task:
  C.CommitIntake{2n}

def data_219() -> List<&2, C.Task>:
  [data_217(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_220(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_214(netted, initial, input), data_219(), data_107()}

def data_221(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_167(input), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_222(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_212(input), data_221(netted, input)]

def data_223(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_222(netted, input), data_156(), data_23(), 1n, 0n, False{}, data_191(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_224() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_225() -> List<&2, C.Task>:
  [data_224(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_226(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(netted, initial, input), data_225(), data_107()}

def data_227() -> O.Task:
  O.TrimDeps{3n}

def data_228() -> List<&2, O.Task>:
  [data_227()]

def data_229() -> C.Task:
  C.OwnerTasks{data_228()}

def data_230() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_231() -> List<&2, C.Task>:
  [data_229(), data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_232(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(netted, initial, input), data_231(), data_107()}

def data_233() -> List<&2, O.Task>:
  []

def data_234() -> C.Task:
  C.OwnerTasks{data_233()}

def data_235() -> List<&2, C.Task>:
  [data_234(), data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_236(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(netted, initial, input), data_235(), data_107()}

def data_237() -> List<&2, C.Task>:
  [data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_238(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(netted, initial, input), data_237(), data_107()}

def data_239() -> List<&2, C.Task>:
  [data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_240(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(netted, initial, input), data_239(), data_107()}

def data_241(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_222(netted, input), data_156(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_242() -> List<&2, C.Task>:
  [data_204(), data_205(), data_200(), data_111(), data_112()]

def data_243(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_242(), data_107()}

def data_244() -> List<&2, C.Task>:
  [data_205(), data_200(), data_111(), data_112()]

def data_245(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_244(), data_107()}

def data_246() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_247() -> C.Task:
  C.LandTransactions{data_246(), 0n}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_200(), data_111(), data_112()]

def data_249(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_248(), data_107()}

def data_250() -> C.Task:
  C.CompleteSettle{data_246()}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_200(), data_111(), data_112()]

def data_252(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_251(), data_107()}

def data_253() -> C.Task:
  C.ZombieLoop{data_24()}

def data_254() -> List<&2, C.Task>:
  [data_253(), data_200(), data_111(), data_112()]

def data_255(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_254(), data_107()}

def data_256() -> List<&2, C.Task>:
  [data_200(), data_111(), data_112()]

def data_257(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(netted, initial, input), data_256(), data_107()}

def data_258(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_222(netted, input), data_156(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_259() -> C.Task:
  C.RenderQueue{}

def data_260() -> List<&2, C.Task>:
  [data_259(), data_111(), data_112()]

def data_261(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(netted, initial, input), data_260(), data_107()}

def data_262() -> C.Task:
  C.UserQueue{}

def data_263() -> List<&2, C.Task>:
  [data_262(), data_111(), data_112()]

def data_264(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(netted, initial, input), data_263(), data_107()}

def data_265() -> List<&2, C.Task>:
  [data_111(), data_112()]

def data_266(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(netted, initial, input), data_265(), data_107()}

def data_267(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  R.World{data_222(netted, input), data_156(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_158(initial, input), data_32(), False{}, data_24(), data_40(), data_43(), data_24(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_48(), data_51(), data_53(), data_103(), 0n, data_58(), data_60(), data_62(), data_63(), data_65(), False{}, False{}, data_35(), data_67(), data_69(), data_72(), 0n, data_48(), False{}, data_73(), data_74(), data_75(), 0n, data_76(), data_77(), data_78(), data_79(), data_80(), 0n, data_84(), data_85(), data_2(), data_24(), data_92()}

def data_268() -> List<&2, C.Task>:
  [data_112()]

def data_269(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_267(netted, initial, input), data_268(), data_107()}

def data_270() -> List<&2, C.Task>:
  []

def data_271(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_267(netted, initial, input), data_270(), data_107()}

def origin(+initial: Nat) -> R.World:
  data_93(initial)

def at_0(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_108(initial, input)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  at_0(Nat.is_eq(input, initial), initial, input)

def at_1(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_114(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  at_1(Nat.is_eq(input, initial), initial, input)

def at_2(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_117(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  at_2(Nat.is_eq(input, initial), initial, input)

def at_3(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_120(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  at_3(Nat.is_eq(input, initial), initial, input)

def at_4(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_128(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  at_4(Nat.is_eq(input, initial), initial, input)

def at_5(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_131(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  at_5(Nat.is_eq(input, initial), initial, input)

def at_6(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_141(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  at_6(Nat.is_eq(input, initial), initial, input)

def at_7(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_146(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  at_7(Nat.is_eq(input, initial), initial, input)

def at_8(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_149(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  at_8(Nat.is_eq(input, initial), initial, input)

def at_9(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_152(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  at_9(Nat.is_eq(input, initial), initial, input)

def at_10(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_162(netted, initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  at_10(Nat.is_eq(input, initial), initial, input)

def at_11(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_165(netted, initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  at_11(Nat.is_eq(input, initial), initial, input)

def at_12(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_169(netted, initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  at_12(Nat.is_eq(input, initial), initial, input)

def at_13(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_175(netted, initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  at_13(Nat.is_eq(input, initial), initial, input)

def at_14(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_183(netted, initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  at_14(Nat.is_eq(input, initial), initial, input)

def at_15(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_185(netted, initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  at_15(Nat.is_eq(input, initial), initial, input)

def at_16(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_188(netted, initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  at_16(Nat.is_eq(input, initial), initial, input)

def at_17(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_193(netted, initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  at_17(Nat.is_eq(input, initial), initial, input)

def at_18(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_195(netted, initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  at_18(Nat.is_eq(input, initial), initial, input)

def at_19(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_198(netted, initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  at_19(Nat.is_eq(input, initial), initial, input)

def at_20(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_202(netted, initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  at_20(Nat.is_eq(input, initial), initial, input)

def at_21(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_207(netted, initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  at_21(Nat.is_eq(input, initial), initial, input)

def at_22(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_211(netted, initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  at_22(Nat.is_eq(input, initial), initial, input)

def at_23(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_216(netted, initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  at_23(Nat.is_eq(input, initial), initial, input)

def at_24(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_220(netted, initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  at_24(Nat.is_eq(input, initial), initial, input)

def at_25(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_226(netted, initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  at_25(Nat.is_eq(input, initial), initial, input)

def at_26(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_232(netted, initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  at_26(Nat.is_eq(input, initial), initial, input)

def at_27(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_236(netted, initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  at_27(Nat.is_eq(input, initial), initial, input)

def at_28(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_238(netted, initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  at_28(Nat.is_eq(input, initial), initial, input)

def at_29(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_240(netted, initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  at_29(Nat.is_eq(input, initial), initial, input)

def at_30(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_243(netted, initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  at_30(Nat.is_eq(input, initial), initial, input)

def at_31(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_245(netted, initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  at_31(Nat.is_eq(input, initial), initial, input)

def at_32(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_249(netted, initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  at_32(Nat.is_eq(input, initial), initial, input)

def at_33(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_252(netted, initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  at_33(Nat.is_eq(input, initial), initial, input)

def at_34(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_255(netted, initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  at_34(Nat.is_eq(input, initial), initial, input)

def at_35(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_257(netted, initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  at_35(Nat.is_eq(input, initial), initial, input)

def at_36(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_261(netted, initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  at_36(Nat.is_eq(input, initial), initial, input)

def at_37(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_264(netted, initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  at_37(Nat.is_eq(input, initial), initial, input)

def at_38(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_266(netted, initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  at_38(Nat.is_eq(input, initial), initial, input)

def at_39(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_269(netted, initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  at_39(Nat.is_eq(input, initial), initial, input)

def at_40(+netted: Bool, +initial: Nat, +input: Nat) -> C.Machine:
  data_271(netted, initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  at_40(Nat.is_eq(input, initial), initial, input)

def finalAt(+netted: Bool, +initial: Nat, +input: Nat) -> R.World:
  data_267(netted, initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  finalAt(Nat.is_eq(input, initial), initial, input)

# Algebraic publication cut over both source netted-read postures.
def publicationAt_13(+netted: Bool, +initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(at_13(netted, initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(at_14(netted, initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  match netted:
    case True{}: {==}
    case False{}: {==}

def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  publicationAt_13(Nat.is_eq(input, initial), initial, input)
