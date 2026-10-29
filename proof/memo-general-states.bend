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

def data_80() -> List<&2, R.KeptGuess>:
  []

def data_81() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_78(), 0n, data_79(), data_24(), False{}, False{}, data_80(), data_24(), False{}}

def data_82() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_83() -> R.Value:
  R.Null{}

def data_84() -> R.DeferredCell:
  R.DeferredCell{0n, data_83(), False{}, False{}}

def data_85() -> R.DeferredBinding:
  R.DeferredBinding{data_84(), 0n}

def data_86() -> List<&2, R.DeferredBinding>:
  [data_85()]

def data_87() -> List<&2, R.DeferredWait>:
  []

def data_88() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_89() -> List<&2, R.DeferredIterator>:
  [data_88()]

def data_90() -> R.DeferredArena:
  R.DeferredArena{data_86(), data_24(), data_87(), data_89()}

def data_91(+initial: Nat) -> R.World:
  R.World{data_19(initial), data_22(), data_23(), 0n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_51(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_92(+input: Nat) -> R.Value:
  R.Number{input}

def data_93(+input: Nat) -> R.Slot:
  R.Present{data_92(input)}

def data_94() -> R.Stamp:
  R.Stamped{2n}

def data_95(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(initial), data_93(input), False{}, 0, 0, 0, 0n, data_94(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_96(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_97(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_96(initial)]

def data_98() -> List<&2, Nat>:
  [3n]

def data_99() -> List<&2, Nat>:
  [2n]

def data_100() -> R.HostJob:
  R.FlushJob{}

def data_101() -> List<&2, R.HostJob>:
  [data_100()]

def data_102(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_97(initial, input), data_22(), data_98(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 0n, False{}, False{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), True{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_103() -> C.Task:
  C.Round{}

def data_104() -> List<&2, C.Task>:
  [data_103()]

def data_105() -> List<&2, R.Value>:
  []

def data_106(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_102(initial, input), data_104(), data_105()}

def data_107(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_97(initial, input), data_22(), data_98(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 2n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_108() -> C.Task:
  C.RoundAfterSweep{}

def data_109() -> C.Task:
  C.FlushFinally{}

def data_110() -> C.Task:
  C.RoundEnd{}

def data_111() -> List<&2, C.Task>:
  [data_108(), data_109(), data_110()]

def data_112(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_107(initial, input), data_111(), data_105()}

def data_113() -> C.Task:
  C.HeapLoop{}

def data_114() -> List<&2, C.Task>:
  [data_113(), data_109(), data_110()]

def data_115(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_107(initial, input), data_114(), data_105()}

def data_116() -> C.Task:
  C.Recompute{3n, False{}}

def data_117() -> List<&2, C.Task>:
  [data_116(), data_113(), data_109(), data_110()]

def data_118(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_107(initial, input), data_117(), data_105()}

def data_119(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_18(initial)]

def data_120() -> R.LaneMount:
  R.MountFalse{}

def data_121() -> R.LaneState:
  R.LaneState{data_24(), data_45(), data_24(), data_78(), 0n, data_120(), data_24(), False{}, False{}, data_80(), data_24(), False{}}

def data_122(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_119(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_31(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_121(), data_82(), data_2(), data_24(), data_90()}

def data_123() -> C.LanePass:
  C.LanePass{0n, data_79(), data_120()}

def data_124() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_123()}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_113(), data_109(), data_110()]

def data_126(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_122(initial, input), data_125(), data_105()}

def data_127() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_123()}

def data_128() -> List<&2, C.Task>:
  [data_127(), data_113(), data_109(), data_110()]

def data_129(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_122(initial, input), data_128(), data_105()}

def data_130(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_131(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_130(initial)]

def data_132(+initial: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28()]

def data_133(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_131(initial, input), data_22(), data_23(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_132(initial), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_121(), data_82(), data_2(), data_24(), data_90()}

def data_134(+initial: Nat) -> C.Task:
  C.Evaluate{data_17(), data_13(initial)}

def data_135() -> R.Flight:
  R.FlightUndefined{}

def data_136(+initial: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(initial), False{}, data_1(), 0n, False{}, data_135(), data_105(), 0n, False{}, data_123()}

def data_137(+initial: Nat) -> C.Task:
  C.Finish{data_136(initial)}

def data_138(+initial: Nat) -> List<&2, C.Task>:
  [data_134(initial), data_137(initial), data_113(), data_109(), data_110()]

def data_139(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_133(initial, input), data_138(initial), data_105()}

def data_140(+initial: Nat) -> C.Task:
  C.Evaluate{data_14(), data_13(initial)}

def data_141(+initial: Nat) -> C.Task:
  C.Evaluate{data_16(), data_13(initial)}

def data_142() -> C.Task:
  C.Binary{0}

def data_143(+initial: Nat) -> List<&2, C.Task>:
  [data_140(initial), data_141(initial), data_142(), data_137(initial), data_113(), data_109(), data_110()]

def data_144(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_133(initial, input), data_143(initial), data_105()}

def data_145() -> C.Task:
  C.ReadNode{2n}

def data_146(+initial: Nat) -> List<&2, C.Task>:
  [data_145(), data_141(initial), data_142(), data_137(initial), data_113(), data_109(), data_110()]

def data_147(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_133(initial, input), data_146(initial), data_105()}

def data_148() -> C.Task:
  C.ReadPrepared{2n}

def data_149(+initial: Nat) -> List<&2, C.Task>:
  [data_148(), data_141(initial), data_142(), data_137(initial), data_113(), data_109(), data_110()]

def data_150(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_133(initial, input), data_149(initial), data_105()}

def data_151(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_152(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_151(initial)]

def data_153() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_154() -> List<&2, R.Link>:
  [data_20(), data_153()]

def data_155(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_92(input)}

def data_156(+initial: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_28(), data_29(initial), data_30(), data_28(), data_155(input)]

def data_157(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_152(initial, input), data_154(), data_23(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 3n, True{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_121(), data_82(), data_2(), data_24(), data_90()}

def data_158(+initial: Nat) -> List<&2, C.Task>:
  [data_141(initial), data_142(), data_137(initial), data_113(), data_109(), data_110()]

def data_159(+input: Nat) -> List<&2, R.Value>:
  [data_92(input)]

def data_160(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_157(initial, input), data_158(initial), data_159(input)}

def data_161(+initial: Nat) -> List<&2, C.Task>:
  [data_142(), data_137(initial), data_113(), data_109(), data_110()]

def data_162(+input: Nat) -> List<&2, R.Value>:
  [data_15(), data_92(input)]

def data_163(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_157(initial, input), data_161(initial), data_162(input)}

def data_164(+initial: Nat) -> List<&2, C.Task>:
  [data_137(initial), data_113(), data_109(), data_110()]

def data_165(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_166(+input: Nat) -> List<&2, R.Value>:
  [data_165(input)]

def data_167(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_157(initial, input), data_164(initial), data_166(input)}

def data_168(+initial: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_169(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_168(initial)]

def data_170(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_169(initial, input), data_154(), data_23(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_171(+initial: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_136(initial), 0n, data_165(input), False{}, False{}, False{}, data_32()}

def data_172(+initial: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_171(initial, input), data_113(), data_109(), data_110()]

def data_173(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_170(initial, input), data_172(initial, input), data_105()}

def data_174(+input: Nat) -> R.Slot:
  R.Present{data_165(input)}

def data_175(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_174(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_176(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_175(initial, input)]

def data_177(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_176(initial, input), data_154(), data_23(), 0n, 0n, False{}, data_99(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_178() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_179() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_180() -> List<&2, C.Task>:
  [data_178(), data_179(), data_113(), data_109(), data_110()]

def data_181(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_180(), data_105()}

def data_182() -> List<&2, C.Task>:
  [data_179(), data_113(), data_109(), data_110()]

def data_183(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_182(), data_105()}

def data_184() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_185() -> List<&2, C.Task>:
  [data_184(), data_113(), data_109(), data_110()]

def data_186(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_177(initial, input), data_185(), data_105()}

def data_187(+initial: Nat, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(initial), data_174(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_188(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_95(initial, input), data_187(initial, input)]

def data_189() -> List<&2, Nat>:
  [2n, 3n]

def data_190(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_188(initial, input), data_154(), data_23(), 0n, 0n, False{}, data_189(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_191(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_190(initial, input), data_114(), data_105()}

def data_192(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_188(initial, input), data_154(), data_23(), 1n, 0n, False{}, data_189(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_193(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, input), data_114(), data_105()}

def data_194() -> C.Task:
  C.Seam{}

def data_195() -> List<&2, C.Task>:
  [data_194(), data_109(), data_110()]

def data_196(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, input), data_195(), data_105()}

def data_197() -> C.Task:
  C.Settle{}

def data_198() -> C.Task:
  C.AfterSettle{}

def data_199() -> List<&2, C.Task>:
  [data_197(), data_198(), data_109(), data_110()]

def data_200(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, input), data_199(), data_105()}

def data_201() -> C.Task:
  C.CommitIntake{0n}

def data_202() -> C.Task:
  C.TrimIntake{0n}

def data_203() -> C.Task:
  C.FinishSettleIntake{0n}

def data_204() -> List<&2, C.Task>:
  [data_201(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_205(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, input), data_204(), data_105()}

def data_206() -> C.Task:
  C.CommitPending{2n}

def data_207() -> C.Task:
  C.CommitIntake{1n}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_209(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, input), data_208(), data_105()}

def data_210(+input: Nat) -> R.Node:
  R.Node{data_9(), data_92(input), data_2(), False{}, 0, 0, 0, 0n, data_94(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_211(+initial: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_210(input), data_187(initial, input)]

def data_212(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_211(initial, input), data_154(), data_23(), 1n, 0n, False{}, data_189(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_213() -> List<&2, C.Task>:
  [data_207(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_214(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, input), data_213(), data_105()}

def data_215() -> C.Task:
  C.CommitPending{3n}

def data_216() -> C.Task:
  C.CommitIntake{2n}

def data_217() -> List<&2, C.Task>:
  [data_215(), data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_218(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, input), data_217(), data_105()}

def data_219(+input: Nat) -> R.Node:
  R.Node{data_12(), data_165(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_17(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_220(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_210(input), data_219(input)]

def data_221(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_220(input), data_154(), data_23(), 1n, 0n, False{}, data_189(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_222() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_223() -> List<&2, C.Task>:
  [data_222(), data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_224(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_221(initial, input), data_223(), data_105()}

def data_225() -> O.Task:
  O.TrimDeps{3n}

def data_226() -> List<&2, O.Task>:
  [data_225()]

def data_227() -> C.Task:
  C.OwnerTasks{data_226()}

def data_228() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_229() -> List<&2, C.Task>:
  [data_227(), data_228(), data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_230(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_221(initial, input), data_229(), data_105()}

def data_231() -> List<&2, O.Task>:
  []

def data_232() -> C.Task:
  C.OwnerTasks{data_231()}

def data_233() -> List<&2, C.Task>:
  [data_232(), data_228(), data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_234(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_221(initial, input), data_233(), data_105()}

def data_235() -> List<&2, C.Task>:
  [data_228(), data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_236(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_221(initial, input), data_235(), data_105()}

def data_237() -> List<&2, C.Task>:
  [data_216(), data_202(), data_203(), data_198(), data_109(), data_110()]

def data_238(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_221(initial, input), data_237(), data_105()}

def data_239(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_220(input), data_154(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, True{}, 0n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_240() -> List<&2, C.Task>:
  [data_202(), data_203(), data_198(), data_109(), data_110()]

def data_241(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_240(), data_105()}

def data_242() -> List<&2, C.Task>:
  [data_203(), data_198(), data_109(), data_110()]

def data_243(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_242(), data_105()}

def data_244() -> C.SeamFrame:
  C.SeamFrame{0n, data_24(), data_25(), data_24(), data_25()}

def data_245() -> C.Task:
  C.LandTransactions{data_244(), 0n}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_198(), data_109(), data_110()]

def data_247(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_246(), data_105()}

def data_248() -> C.Task:
  C.CompleteSettle{data_244()}

def data_249() -> List<&2, C.Task>:
  [data_248(), data_198(), data_109(), data_110()]

def data_250(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_249(), data_105()}

def data_251() -> C.Task:
  C.ZombieLoop{data_24()}

def data_252() -> List<&2, C.Task>:
  [data_251(), data_198(), data_109(), data_110()]

def data_253(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_252(), data_105()}

def data_254() -> List<&2, C.Task>:
  [data_198(), data_109(), data_110()]

def data_255(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_239(initial, input), data_254(), data_105()}

def data_256(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_220(input), data_154(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, True{}, False{}, 1n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_257() -> C.Task:
  C.RenderQueue{}

def data_258() -> List<&2, C.Task>:
  [data_257(), data_109(), data_110()]

def data_259(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_256(initial, input), data_258(), data_105()}

def data_260() -> C.Task:
  C.UserQueue{}

def data_261() -> List<&2, C.Task>:
  [data_260(), data_109(), data_110()]

def data_262(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_256(initial, input), data_261(), data_105()}

def data_263() -> List<&2, C.Task>:
  [data_109(), data_110()]

def data_264(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_256(initial, input), data_263(), data_105()}

def data_265(+initial: Nat, +input: Nat) -> R.World:
  R.World{data_220(input), data_154(), data_23(), 1n, 0n, False{}, data_24(), data_24(), data_24(), data_25(), 0n, False{}, False{}, False{}, 1n, 3n, data_27(), data_156(initial, input), data_32(), False{}, data_24(), data_37(), data_40(), data_24(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_24(), 0n, 0n, 0n, 0n, data_24(), data_35(), data_45(), data_48(), data_50(), data_101(), 0n, data_55(), data_57(), data_59(), data_60(), data_62(), False{}, False{}, data_35(), data_64(), data_66(), data_69(), 0n, data_45(), False{}, data_70(), data_71(), data_72(), 0n, data_73(), data_74(), data_75(), data_76(), data_77(), 0n, data_81(), data_82(), data_2(), data_24(), data_90()}

def data_266() -> List<&2, C.Task>:
  [data_110()]

def data_267(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_265(initial, input), data_266(), data_105()}

def data_268() -> List<&2, C.Task>:
  []

def data_269(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_265(initial, input), data_268(), data_105()}

def origin(+initial: Nat) -> R.World:
  data_91(initial)

def state_0(+initial: Nat, +input: Nat) -> C.Machine:
  data_106(initial, input)

def state_1(+initial: Nat, +input: Nat) -> C.Machine:
  data_112(initial, input)

def state_2(+initial: Nat, +input: Nat) -> C.Machine:
  data_115(initial, input)

def state_3(+initial: Nat, +input: Nat) -> C.Machine:
  data_118(initial, input)

def state_4(+initial: Nat, +input: Nat) -> C.Machine:
  data_126(initial, input)

def state_5(+initial: Nat, +input: Nat) -> C.Machine:
  data_129(initial, input)

def state_6(+initial: Nat, +input: Nat) -> C.Machine:
  data_139(initial, input)

def state_7(+initial: Nat, +input: Nat) -> C.Machine:
  data_144(initial, input)

def state_8(+initial: Nat, +input: Nat) -> C.Machine:
  data_147(initial, input)

def state_9(+initial: Nat, +input: Nat) -> C.Machine:
  data_150(initial, input)

def state_10(+initial: Nat, +input: Nat) -> C.Machine:
  data_160(initial, input)

def state_11(+initial: Nat, +input: Nat) -> C.Machine:
  data_163(initial, input)

def state_12(+initial: Nat, +input: Nat) -> C.Machine:
  data_167(initial, input)

def state_13(+initial: Nat, +input: Nat) -> C.Machine:
  data_173(initial, input)

def state_14(+initial: Nat, +input: Nat) -> C.Machine:
  data_181(initial, input)

def state_15(+initial: Nat, +input: Nat) -> C.Machine:
  data_183(initial, input)

def state_16(+initial: Nat, +input: Nat) -> C.Machine:
  data_186(initial, input)

def state_17(+initial: Nat, +input: Nat) -> C.Machine:
  data_191(initial, input)

def state_18(+initial: Nat, +input: Nat) -> C.Machine:
  data_193(initial, input)

def state_19(+initial: Nat, +input: Nat) -> C.Machine:
  data_196(initial, input)

def state_20(+initial: Nat, +input: Nat) -> C.Machine:
  data_200(initial, input)

def state_21(+initial: Nat, +input: Nat) -> C.Machine:
  data_205(initial, input)

def state_22(+initial: Nat, +input: Nat) -> C.Machine:
  data_209(initial, input)

def state_23(+initial: Nat, +input: Nat) -> C.Machine:
  data_214(initial, input)

def state_24(+initial: Nat, +input: Nat) -> C.Machine:
  data_218(initial, input)

def state_25(+initial: Nat, +input: Nat) -> C.Machine:
  data_224(initial, input)

def state_26(+initial: Nat, +input: Nat) -> C.Machine:
  data_230(initial, input)

def state_27(+initial: Nat, +input: Nat) -> C.Machine:
  data_234(initial, input)

def state_28(+initial: Nat, +input: Nat) -> C.Machine:
  data_236(initial, input)

def state_29(+initial: Nat, +input: Nat) -> C.Machine:
  data_238(initial, input)

def state_30(+initial: Nat, +input: Nat) -> C.Machine:
  data_241(initial, input)

def state_31(+initial: Nat, +input: Nat) -> C.Machine:
  data_243(initial, input)

def state_32(+initial: Nat, +input: Nat) -> C.Machine:
  data_247(initial, input)

def state_33(+initial: Nat, +input: Nat) -> C.Machine:
  data_250(initial, input)

def state_34(+initial: Nat, +input: Nat) -> C.Machine:
  data_253(initial, input)

def state_35(+initial: Nat, +input: Nat) -> C.Machine:
  data_255(initial, input)

def state_36(+initial: Nat, +input: Nat) -> C.Machine:
  data_259(initial, input)

def state_37(+initial: Nat, +input: Nat) -> C.Machine:
  data_262(initial, input)

def state_38(+initial: Nat, +input: Nat) -> C.Machine:
  data_264(initial, input)

def state_39(+initial: Nat, +input: Nat) -> C.Machine:
  data_267(initial, input)

def state_40(+initial: Nat, +input: Nat) -> C.Machine:
  data_269(initial, input)

def finalWorld(+initial: Nat, +input: Nat) -> R.World:
  data_265(initial, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
