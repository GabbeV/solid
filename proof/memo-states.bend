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

def data_32() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_33() -> R.Question:
  R.QuestionZero{}

def data_34() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_32(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_33(), data_2(), 0n, data_1()}

def data_35() -> List<&2, R.NodeExtension>:
  [data_34()]

def data_36() -> List<&2, R.CleanupAction>:
  []

def data_37() -> R.CleanupProgram:
  R.CleanupProgram{data_36(), False{}, 0n}

def data_38() -> List<&2, R.CleanupProgram>:
  [data_37()]

def data_39() -> List<&2, R.Report>:
  []

def data_40() -> R.OptionalIds:
  R.NoIds{}

def data_41() -> R.Transaction:
  R.Transaction{data_23(), data_23(), data_24(), data_23(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_40()}

def data_42() -> List<&2, R.Transaction>:
  [data_41()]

def data_43() -> List<&2, List<&2, Nat>>:
  [data_23()]

def data_44() -> R.AsyncSettlement:
  R.Unresolved{}

def data_45() -> R.AsyncObject:
  R.AsyncObject{False{}, data_44(), data_23(), 0n}

def data_46() -> List<&2, R.AsyncObject>:
  [data_45()]

def data_47() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_48() -> List<&2, R.AsyncObserver>:
  [data_47()]

def data_49() -> List<&2, R.HostJob>:
  []

def data_50() -> List<&2, R.NextInput>:
  []

def data_51() -> R.StreamPlan:
  R.StreamPlan{data_50(), False{}, data_2(), 0n, 0n, data_2()}

def data_52() -> List<&2, R.StreamPlan>:
  [data_51()]

def data_53() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_54() -> List<&2, R.ExternalIterator>:
  [data_53()]

def data_55() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_56() -> List<&2, R.StreamState>:
  [data_55()]

def data_57() -> List<&2, R.IteratorEvent>:
  []

def data_58() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_44(), False{}, 0n, False{}, False{}, 0n}

def data_59() -> List<&2, R.Awaiter>:
  [data_58()]

def data_60() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_61() -> List<&2, R.AbortInput>:
  [data_60()]

def data_62() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_63() -> List<&2, R.ContextKey>:
  [data_62()]

def data_64() -> List<&2, R.ContextEntry>:
  []

def data_65() -> R.ContextRecord:
  R.ContextRecord{data_64()}

def data_66() -> List<&2, R.ContextRecord>:
  [data_65()]

def data_67() -> List<&2, R.Expr>:
  [data_4()]

def data_68() -> List<&2, R.ReactionState>:
  []

def data_69() -> List<&2, R.ComparatorBinding>:
  []

def data_70() -> List<&2, R.ActionState>:
  []

def data_71() -> List<&2, R.ActionWait>:
  []

def data_72() -> List<&2, R.ArrayData>:
  []

def data_73() -> List<&2, R.RepeatState>:
  []

def data_74() -> List<&2, R.MapState>:
  []

def data_75() -> List<&2, R.Guess>:
  []

def data_76() -> R.LaneMount:
  R.MountUnset{}

def data_77() -> R.LaneState:
  R.LaneState{data_23(), data_43(), data_23(), data_75(), 0n, data_76()}

def data_78() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_79() -> R.Value:
  R.Null{}

def data_80() -> R.DeferredCell:
  R.DeferredCell{0n, data_79(), False{}, False{}}

def data_81() -> R.DeferredBinding:
  R.DeferredBinding{data_80(), 0n}

def data_82() -> List<&2, R.DeferredBinding>:
  [data_81()]

def data_83() -> List<&2, R.DeferredWait>:
  []

def data_84() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_85() -> List<&2, R.DeferredIterator>:
  [data_84()]

def data_86() -> R.DeferredArena:
  R.DeferredArena{data_82(), data_23(), data_83(), data_85()}

def data_87() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_49(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_88(+input: Nat) -> R.Value:
  R.Number{input}

def data_89(+input: Nat) -> R.Slot:
  R.Present{data_88(input)}

def data_90() -> R.Stamp:
  R.Stamped{2n}

def data_91(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_89(input), False{}, 0, 0, 0, 0n, data_90(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_92() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_93(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_92()]

def data_94() -> List<&2, Nat>:
  [3n]

def data_95() -> List<&2, Nat>:
  [2n]

def data_96() -> R.HostJob:
  R.FlushJob{}

def data_97() -> List<&2, R.HostJob>:
  [data_96()]

def data_98(+input: Nat) -> R.World:
  R.World{data_93(input), data_21(), data_94(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_99() -> C.Task:
  C.Round{}

def data_100() -> List<&2, C.Task>:
  [data_99()]

def data_101() -> List<&2, R.Value>:
  []

def data_102(+input: Nat) -> C.Machine:
  C.Machine{data_98(input), data_100(), data_101()}

def data_103(+input: Nat) -> R.World:
  R.World{data_93(input), data_21(), data_94(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_104() -> C.Task:
  C.RoundAfterSweep{}

def data_105() -> C.Task:
  C.FlushFinally{}

def data_106() -> C.Task:
  C.RoundEnd{}

def data_107() -> List<&2, C.Task>:
  [data_104(), data_105(), data_106()]

def data_108(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_107(), data_101()}

def data_109() -> C.Task:
  C.HeapLoop{}

def data_110() -> List<&2, C.Task>:
  [data_109(), data_105(), data_106()]

def data_111(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_110(), data_101()}

def data_112() -> C.Task:
  C.Recompute{3n, False{}}

def data_113() -> List<&2, C.Task>:
  [data_112(), data_109(), data_105(), data_106()]

def data_114(+input: Nat) -> C.Machine:
  C.Machine{data_103(input), data_113(), data_101()}

def data_115(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_17()]

def data_116() -> R.LaneMount:
  R.MountFalse{}

def data_117() -> R.LaneState:
  R.LaneState{data_23(), data_43(), data_23(), data_75(), 0n, data_116()}

def data_118(+input: Nat) -> R.World:
  R.World{data_115(input), data_21(), data_22(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_117(), data_78(), data_2(), data_23(), data_86()}

def data_119() -> C.LanePass:
  C.LanePass{0n, data_76(), data_116()}

def data_120() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_119()}

def data_121() -> List<&2, C.Task>:
  [data_120(), data_109(), data_105(), data_106()]

def data_122(+input: Nat) -> C.Machine:
  C.Machine{data_118(input), data_121(), data_101()}

def data_123() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_119()}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_109(), data_105(), data_106()]

def data_125(+input: Nat) -> C.Machine:
  C.Machine{data_118(input), data_124(), data_101()}

def data_126() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_127(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_126()]

def data_128() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_129(+input: Nat) -> R.World:
  R.World{data_127(input), data_21(), data_22(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_128(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_117(), data_78(), data_2(), data_23(), data_86()}

def data_130() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_131() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_101(), 0n, False{}, data_119()}

def data_132() -> C.Task:
  C.Finish{data_131()}

def data_133() -> List<&2, C.Task>:
  [data_130(), data_132(), data_109(), data_105(), data_106()]

def data_134(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_133(), data_101()}

def data_135() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_136() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_137() -> C.Task:
  C.Binary{0}

def data_138() -> List<&2, C.Task>:
  [data_135(), data_136(), data_137(), data_132(), data_109(), data_105(), data_106()]

def data_139(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_138(), data_101()}

def data_140() -> C.Task:
  C.ReadNode{2n}

def data_141() -> List<&2, C.Task>:
  [data_140(), data_136(), data_137(), data_132(), data_109(), data_105(), data_106()]

def data_142(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_141(), data_101()}

def data_143() -> C.Task:
  C.ReadPrepared{2n}

def data_144() -> List<&2, C.Task>:
  [data_143(), data_136(), data_137(), data_132(), data_109(), data_105(), data_106()]

def data_145(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_144(), data_101()}

def data_146() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_147(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_146()]

def data_148() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_149() -> List<&2, R.Link>:
  [data_19(), data_148()]

def data_150(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_88(input)}

def data_151(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_150(input)]

def data_152(+input: Nat) -> R.World:
  R.World{data_147(input), data_149(), data_22(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_117(), data_78(), data_2(), data_23(), data_86()}

def data_153() -> List<&2, C.Task>:
  [data_136(), data_137(), data_132(), data_109(), data_105(), data_106()]

def data_154(+input: Nat) -> List<&2, R.Value>:
  [data_88(input)]

def data_155(+input: Nat) -> C.Machine:
  C.Machine{data_152(input), data_153(), data_154(input)}

def data_156() -> List<&2, C.Task>:
  [data_137(), data_132(), data_109(), data_105(), data_106()]

def data_157(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_88(input)]

def data_158(+input: Nat) -> C.Machine:
  C.Machine{data_152(input), data_156(), data_157(input)}

def data_159() -> List<&2, C.Task>:
  [data_132(), data_109(), data_105(), data_106()]

def data_160(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_160(input)]

def data_162(+input: Nat) -> C.Machine:
  C.Machine{data_152(input), data_159(), data_161(input)}

def data_163() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_164(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_163()]

def data_165(+input: Nat) -> R.World:
  R.World{data_164(input), data_149(), data_22(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_166(+input: Nat) -> C.Task:
  C.PassReleases{data_131(), 0n, data_160(input), False{}, False{}, False{}, data_31()}

def data_167(+input: Nat) -> List<&2, C.Task>:
  [data_166(input), data_109(), data_105(), data_106()]

def data_168(+input: Nat) -> C.Machine:
  C.Machine{data_165(input), data_167(input), data_101()}

def data_169(+input: Nat) -> R.Slot:
  R.Present{data_160(input)}

def data_170(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_169(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_171(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_170(input)]

def data_172(+input: Nat) -> R.World:
  R.World{data_171(input), data_149(), data_22(), 0n, 0n, False{}, data_95(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_173() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_174() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_175() -> List<&2, C.Task>:
  [data_173(), data_174(), data_109(), data_105(), data_106()]

def data_176(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_175(), data_101()}

def data_177() -> List<&2, C.Task>:
  [data_174(), data_109(), data_105(), data_106()]

def data_178(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_177(), data_101()}

def data_179() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_180() -> List<&2, C.Task>:
  [data_179(), data_109(), data_105(), data_106()]

def data_181(+input: Nat) -> C.Machine:
  C.Machine{data_172(input), data_180(), data_101()}

def data_182(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_169(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_183(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(input), data_182(input)]

def data_184() -> List<&2, Nat>:
  [2n, 3n]

def data_185(+input: Nat) -> R.World:
  R.World{data_183(input), data_149(), data_22(), 0n, 0n, False{}, data_184(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_186(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_110(), data_101()}

def data_187(+input: Nat) -> R.World:
  R.World{data_183(input), data_149(), data_22(), 1n, 0n, False{}, data_184(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_188(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_110(), data_101()}

def data_189() -> C.Task:
  C.Seam{}

def data_190() -> List<&2, C.Task>:
  [data_189(), data_105(), data_106()]

def data_191(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_190(), data_101()}

def data_192() -> C.Task:
  C.Settle{}

def data_193() -> C.Task:
  C.AfterSettle{}

def data_194() -> List<&2, C.Task>:
  [data_192(), data_193(), data_105(), data_106()]

def data_195(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_194(), data_101()}

def data_196() -> C.Task:
  C.CommitIntake{0n}

def data_197() -> C.Task:
  C.TrimIntake{0n}

def data_198() -> C.Task:
  C.FinishSettleIntake{0n}

def data_199() -> List<&2, C.Task>:
  [data_196(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_200(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_199(), data_101()}

def data_201() -> C.Task:
  C.CommitPending{2n}

def data_202() -> C.Task:
  C.CommitIntake{1n}

def data_203() -> List<&2, C.Task>:
  [data_201(), data_202(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_203(), data_101()}

def data_205(+input: Nat) -> R.Node:
  R.Node{data_9(), data_88(input), data_2(), False{}, 0, 0, 0, 0n, data_90(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_206(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_205(input), data_182(input)]

def data_207(+input: Nat) -> R.World:
  R.World{data_206(input), data_149(), data_22(), 1n, 0n, False{}, data_184(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_208() -> List<&2, C.Task>:
  [data_202(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_207(input), data_208(), data_101()}

def data_210() -> C.Task:
  C.CommitPending{3n}

def data_211() -> C.Task:
  C.CommitIntake{2n}

def data_212() -> List<&2, C.Task>:
  [data_210(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_207(input), data_212(), data_101()}

def data_214(+input: Nat) -> R.Node:
  R.Node{data_12(), data_160(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_215(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_205(input), data_214(input)]

def data_216(+input: Nat) -> R.World:
  R.World{data_215(input), data_149(), data_22(), 1n, 0n, False{}, data_184(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_217() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_218() -> List<&2, C.Task>:
  [data_217(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_219(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_218(), data_101()}

def data_220() -> O.Task:
  O.TrimDeps{3n}

def data_221() -> List<&2, O.Task>:
  [data_220()]

def data_222() -> C.Task:
  C.OwnerTasks{data_221()}

def data_223() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_224() -> List<&2, C.Task>:
  [data_222(), data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_225(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_224(), data_101()}

def data_226() -> List<&2, O.Task>:
  []

def data_227() -> C.Task:
  C.OwnerTasks{data_226()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_228(), data_101()}

def data_230() -> List<&2, C.Task>:
  [data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_231(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_230(), data_101()}

def data_232() -> List<&2, C.Task>:
  [data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_232(), data_101()}

def data_234(+input: Nat) -> R.World:
  R.World{data_215(input), data_149(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_235() -> List<&2, C.Task>:
  [data_197(), data_198(), data_193(), data_105(), data_106()]

def data_236(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_235(), data_101()}

def data_237() -> List<&2, C.Task>:
  [data_198(), data_193(), data_105(), data_106()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_237(), data_101()}

def data_239() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24(), data_23(), data_24()}

def data_240() -> C.Task:
  C.LandTransactions{data_239(), 0n}

def data_241() -> List<&2, C.Task>:
  [data_240(), data_193(), data_105(), data_106()]

def data_242(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_241(), data_101()}

def data_243() -> C.Task:
  C.CompleteSettle{data_239()}

def data_244() -> List<&2, C.Task>:
  [data_243(), data_193(), data_105(), data_106()]

def data_245(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_244(), data_101()}

def data_246() -> C.Task:
  C.ZombieLoop{data_23()}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_193(), data_105(), data_106()]

def data_248(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_247(), data_101()}

def data_249() -> List<&2, C.Task>:
  [data_193(), data_105(), data_106()]

def data_250(+input: Nat) -> C.Machine:
  C.Machine{data_234(input), data_249(), data_101()}

def data_251(+input: Nat) -> R.World:
  R.World{data_215(input), data_149(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_252() -> C.Task:
  C.RenderQueue{}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_105(), data_106()]

def data_254(+input: Nat) -> C.Machine:
  C.Machine{data_251(input), data_253(), data_101()}

def data_255() -> C.Task:
  C.UserQueue{}

def data_256() -> List<&2, C.Task>:
  [data_255(), data_105(), data_106()]

def data_257(+input: Nat) -> C.Machine:
  C.Machine{data_251(input), data_256(), data_101()}

def data_258() -> List<&2, C.Task>:
  [data_105(), data_106()]

def data_259(+input: Nat) -> C.Machine:
  C.Machine{data_251(input), data_258(), data_101()}

def data_260(+input: Nat) -> R.World:
  R.World{data_215(input), data_149(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_151(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_97(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_86()}

def data_261() -> List<&2, C.Task>:
  [data_106()]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_260(input), data_261(), data_101()}

def data_263() -> List<&2, C.Task>:
  []

def data_264(+input: Nat) -> C.Machine:
  C.Machine{data_260(input), data_263(), data_101()}

def origin() -> R.World:
  data_87()

def state_0(+input: Nat) -> C.Machine:
  data_102(input)

def state_1(+input: Nat) -> C.Machine:
  data_108(input)

def state_2(+input: Nat) -> C.Machine:
  data_111(input)

def state_3(+input: Nat) -> C.Machine:
  data_114(input)

def state_4(+input: Nat) -> C.Machine:
  data_122(input)

def state_5(+input: Nat) -> C.Machine:
  data_125(input)

def state_6(+input: Nat) -> C.Machine:
  data_134(input)

def state_7(+input: Nat) -> C.Machine:
  data_139(input)

def state_8(+input: Nat) -> C.Machine:
  data_142(input)

def state_9(+input: Nat) -> C.Machine:
  data_145(input)

def state_10(+input: Nat) -> C.Machine:
  data_155(input)

def state_11(+input: Nat) -> C.Machine:
  data_158(input)

def state_12(+input: Nat) -> C.Machine:
  data_162(input)

def state_13(+input: Nat) -> C.Machine:
  data_168(input)

def state_14(+input: Nat) -> C.Machine:
  data_176(input)

def state_15(+input: Nat) -> C.Machine:
  data_178(input)

def state_16(+input: Nat) -> C.Machine:
  data_181(input)

def state_17(+input: Nat) -> C.Machine:
  data_186(input)

def state_18(+input: Nat) -> C.Machine:
  data_188(input)

def state_19(+input: Nat) -> C.Machine:
  data_191(input)

def state_20(+input: Nat) -> C.Machine:
  data_195(input)

def state_21(+input: Nat) -> C.Machine:
  data_200(input)

def state_22(+input: Nat) -> C.Machine:
  data_204(input)

def state_23(+input: Nat) -> C.Machine:
  data_209(input)

def state_24(+input: Nat) -> C.Machine:
  data_213(input)

def state_25(+input: Nat) -> C.Machine:
  data_219(input)

def state_26(+input: Nat) -> C.Machine:
  data_225(input)

def state_27(+input: Nat) -> C.Machine:
  data_229(input)

def state_28(+input: Nat) -> C.Machine:
  data_231(input)

def state_29(+input: Nat) -> C.Machine:
  data_233(input)

def state_30(+input: Nat) -> C.Machine:
  data_236(input)

def state_31(+input: Nat) -> C.Machine:
  data_238(input)

def state_32(+input: Nat) -> C.Machine:
  data_242(input)

def state_33(+input: Nat) -> C.Machine:
  data_245(input)

def state_34(+input: Nat) -> C.Machine:
  data_248(input)

def state_35(+input: Nat) -> C.Machine:
  data_250(input)

def state_36(+input: Nat) -> C.Machine:
  data_254(input)

def state_37(+input: Nat) -> C.Machine:
  data_257(input)

def state_38(+input: Nat) -> C.Machine:
  data_259(input)

def state_39(+input: Nat) -> C.Machine:
  data_262(input)

def state_40(+input: Nat) -> C.Machine:
  data_264(input)

def finalWorld(+input: Nat) -> R.World:
  data_260(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
