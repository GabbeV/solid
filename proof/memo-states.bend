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
  R.StreamPlan{data_50(), False{}, data_2(), 0n}

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

def data_84() -> R.DeferredArena:
  R.DeferredArena{data_82(), data_23(), data_83()}

def data_85() -> R.World:
  R.World{data_18(), data_21(), data_22(), 0n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_49(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_86(+input: Nat) -> R.Value:
  R.Number{input}

def data_87(+input: Nat) -> R.Slot:
  R.Present{data_86(input)}

def data_88() -> R.Stamp:
  R.Stamped{2n}

def data_89(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_87(input), False{}, 0, 0, 0, 0n, data_88(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_90() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 8, 0, 0n, data_3(), 1n, 1n, 1n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_91(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_90()]

def data_92() -> List<&2, Nat>:
  [3n]

def data_93() -> List<&2, Nat>:
  [2n]

def data_94() -> R.HostJob:
  R.FlushJob{}

def data_95() -> List<&2, R.HostJob>:
  [data_94()]

def data_96(+input: Nat) -> R.World:
  R.World{data_91(input), data_21(), data_92(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 0n, False{}, False{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), True{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_97() -> C.Task:
  C.Round{}

def data_98() -> List<&2, C.Task>:
  [data_97()]

def data_99() -> List<&2, R.Value>:
  []

def data_100(+input: Nat) -> C.Machine:
  C.Machine{data_96(input), data_98(), data_99()}

def data_101(+input: Nat) -> R.World:
  R.World{data_91(input), data_21(), data_92(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 2n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_102() -> C.Task:
  C.RoundAfterSweep{}

def data_103() -> C.Task:
  C.FlushFinally{}

def data_104() -> C.Task:
  C.RoundEnd{}

def data_105() -> List<&2, C.Task>:
  [data_102(), data_103(), data_104()]

def data_106(+input: Nat) -> C.Machine:
  C.Machine{data_101(input), data_105(), data_99()}

def data_107() -> C.Task:
  C.HeapLoop{}

def data_108() -> List<&2, C.Task>:
  [data_107(), data_103(), data_104()]

def data_109(+input: Nat) -> C.Machine:
  C.Machine{data_101(input), data_108(), data_99()}

def data_110() -> C.Task:
  C.Recompute{3n, False{}}

def data_111() -> List<&2, C.Task>:
  [data_110(), data_107(), data_103(), data_104()]

def data_112(+input: Nat) -> C.Machine:
  C.Machine{data_101(input), data_111(), data_99()}

def data_113(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_17()]

def data_114() -> R.LaneMount:
  R.MountFalse{}

def data_115() -> R.LaneState:
  R.LaneState{data_23(), data_43(), data_23(), data_75(), 0n, data_114()}

def data_116(+input: Nat) -> R.World:
  R.World{data_113(input), data_21(), data_22(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_30(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_115(), data_78(), data_2(), data_23(), data_84()}

def data_117() -> C.LanePass:
  C.LanePass{0n, data_76(), data_114()}

def data_118() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_117()}

def data_119() -> List<&2, C.Task>:
  [data_118(), data_107(), data_103(), data_104()]

def data_120(+input: Nat) -> C.Machine:
  C.Machine{data_116(input), data_119(), data_99()}

def data_121() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_117()}

def data_122() -> List<&2, C.Task>:
  [data_121(), data_107(), data_103(), data_104()]

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_116(input), data_122(), data_99()}

def data_124() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_125(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_124()]

def data_126() -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27()]

def data_127(+input: Nat) -> R.World:
  R.World{data_125(input), data_21(), data_22(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_126(), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_115(), data_78(), data_2(), data_23(), data_84()}

def data_128() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_129() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_99(), 0n, False{}, data_117()}

def data_130() -> C.Task:
  C.Finish{data_129()}

def data_131() -> List<&2, C.Task>:
  [data_128(), data_130(), data_107(), data_103(), data_104()]

def data_132(+input: Nat) -> C.Machine:
  C.Machine{data_127(input), data_131(), data_99()}

def data_133() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_134() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_135() -> C.Task:
  C.Binary{0}

def data_136() -> List<&2, C.Task>:
  [data_133(), data_134(), data_135(), data_130(), data_107(), data_103(), data_104()]

def data_137(+input: Nat) -> C.Machine:
  C.Machine{data_127(input), data_136(), data_99()}

def data_138() -> C.Task:
  C.ReadNode{2n}

def data_139() -> List<&2, C.Task>:
  [data_138(), data_134(), data_135(), data_130(), data_107(), data_103(), data_104()]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_127(input), data_139(), data_99()}

def data_141() -> C.Task:
  C.ReadPrepared{2n}

def data_142() -> List<&2, C.Task>:
  [data_141(), data_134(), data_135(), data_130(), data_107(), data_103(), data_104()]

def data_143(+input: Nat) -> C.Machine:
  C.Machine{data_127(input), data_142(), data_99()}

def data_144() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_145(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_144()]

def data_146() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_147() -> List<&2, R.Link>:
  [data_19(), data_146()]

def data_148(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_86(input)}

def data_149(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_27(), data_28(), data_29(), data_27(), data_148(input)]

def data_150(+input: Nat) -> R.World:
  R.World{data_145(input), data_147(), data_22(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 3n, True{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_115(), data_78(), data_2(), data_23(), data_84()}

def data_151() -> List<&2, C.Task>:
  [data_134(), data_135(), data_130(), data_107(), data_103(), data_104()]

def data_152(+input: Nat) -> List<&2, R.Value>:
  [data_86(input)]

def data_153(+input: Nat) -> C.Machine:
  C.Machine{data_150(input), data_151(), data_152(input)}

def data_154() -> List<&2, C.Task>:
  [data_135(), data_130(), data_107(), data_103(), data_104()]

def data_155(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_86(input)]

def data_156(+input: Nat) -> C.Machine:
  C.Machine{data_150(input), data_154(), data_155(input)}

def data_157() -> List<&2, C.Task>:
  [data_130(), data_107(), data_103(), data_104()]

def data_158(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_159(+input: Nat) -> List<&2, R.Value>:
  [data_158(input)]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_150(input), data_157(), data_159(input)}

def data_161() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_162(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_161()]

def data_163(+input: Nat) -> R.World:
  R.World{data_162(input), data_147(), data_22(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_164(+input: Nat) -> C.Task:
  C.PassReleases{data_129(), 0n, data_158(input), False{}, False{}, False{}, data_31()}

def data_165(+input: Nat) -> List<&2, C.Task>:
  [data_164(input), data_107(), data_103(), data_104()]

def data_166(+input: Nat) -> C.Machine:
  C.Machine{data_163(input), data_165(input), data_99()}

def data_167(+input: Nat) -> R.Slot:
  R.Present{data_158(input)}

def data_168(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_167(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_169(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_168(input)]

def data_170(+input: Nat) -> R.World:
  R.World{data_169(input), data_147(), data_22(), 0n, 0n, False{}, data_93(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_171() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_172() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_173() -> List<&2, C.Task>:
  [data_171(), data_172(), data_107(), data_103(), data_104()]

def data_174(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_173(), data_99()}

def data_175() -> List<&2, C.Task>:
  [data_172(), data_107(), data_103(), data_104()]

def data_176(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_175(), data_99()}

def data_177() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_178() -> List<&2, C.Task>:
  [data_177(), data_107(), data_103(), data_104()]

def data_179(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_178(), data_99()}

def data_180(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_167(input), False{}, 128, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_181(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_89(input), data_180(input)]

def data_182() -> List<&2, Nat>:
  [2n, 3n]

def data_183(+input: Nat) -> R.World:
  R.World{data_181(input), data_147(), data_22(), 0n, 0n, False{}, data_182(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_184(+input: Nat) -> C.Machine:
  C.Machine{data_183(input), data_108(), data_99()}

def data_185(+input: Nat) -> R.World:
  R.World{data_181(input), data_147(), data_22(), 1n, 0n, False{}, data_182(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_186(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_108(), data_99()}

def data_187() -> C.Task:
  C.Seam{}

def data_188() -> List<&2, C.Task>:
  [data_187(), data_103(), data_104()]

def data_189(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_188(), data_99()}

def data_190() -> C.Task:
  C.Settle{}

def data_191() -> C.Task:
  C.AfterSettle{}

def data_192() -> List<&2, C.Task>:
  [data_190(), data_191(), data_103(), data_104()]

def data_193(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_192(), data_99()}

def data_194() -> C.Task:
  C.CommitIntake{0n}

def data_195() -> C.Task:
  C.TrimIntake{0n}

def data_196() -> C.Task:
  C.FinishSettleIntake{0n}

def data_197() -> List<&2, C.Task>:
  [data_194(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_198(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_197(), data_99()}

def data_199() -> C.Task:
  C.CommitPending{2n}

def data_200() -> C.Task:
  C.CommitIntake{1n}

def data_201() -> List<&2, C.Task>:
  [data_199(), data_200(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_202(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_201(), data_99()}

def data_203(+input: Nat) -> R.Node:
  R.Node{data_9(), data_86(input), data_2(), False{}, 0, 0, 0, 0n, data_88(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_204(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_203(input), data_180(input)]

def data_205(+input: Nat) -> R.World:
  R.World{data_204(input), data_147(), data_22(), 1n, 0n, False{}, data_182(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_206() -> List<&2, C.Task>:
  [data_200(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_207(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_206(), data_99()}

def data_208() -> C.Task:
  C.CommitPending{3n}

def data_209() -> C.Task:
  C.CommitIntake{2n}

def data_210() -> List<&2, C.Task>:
  [data_208(), data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_211(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_210(), data_99()}

def data_212(+input: Nat) -> R.Node:
  R.Node{data_12(), data_158(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_213(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_203(input), data_212(input)]

def data_214(+input: Nat) -> R.World:
  R.World{data_213(input), data_147(), data_22(), 1n, 0n, False{}, data_182(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_215() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_216() -> List<&2, C.Task>:
  [data_215(), data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_217(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_216(), data_99()}

def data_218() -> O.Task:
  O.TrimDeps{3n}

def data_219() -> List<&2, O.Task>:
  [data_218()]

def data_220() -> C.Task:
  C.OwnerTasks{data_219()}

def data_221() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_222() -> List<&2, C.Task>:
  [data_220(), data_221(), data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_223(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_222(), data_99()}

def data_224() -> List<&2, O.Task>:
  []

def data_225() -> C.Task:
  C.OwnerTasks{data_224()}

def data_226() -> List<&2, C.Task>:
  [data_225(), data_221(), data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_226(), data_99()}

def data_228() -> List<&2, C.Task>:
  [data_221(), data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_228(), data_99()}

def data_230() -> List<&2, C.Task>:
  [data_209(), data_195(), data_196(), data_191(), data_103(), data_104()]

def data_231(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_230(), data_99()}

def data_232(+input: Nat) -> R.World:
  R.World{data_213(input), data_147(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, True{}, 0n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_233() -> List<&2, C.Task>:
  [data_195(), data_196(), data_191(), data_103(), data_104()]

def data_234(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_233(), data_99()}

def data_235() -> List<&2, C.Task>:
  [data_196(), data_191(), data_103(), data_104()]

def data_236(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_235(), data_99()}

def data_237() -> C.SeamFrame:
  C.SeamFrame{0n, data_23(), data_24(), data_23(), data_24()}

def data_238() -> C.Task:
  C.LandTransactions{data_237(), 0n}

def data_239() -> List<&2, C.Task>:
  [data_238(), data_191(), data_103(), data_104()]

def data_240(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_239(), data_99()}

def data_241() -> C.Task:
  C.CompleteSettle{data_237()}

def data_242() -> List<&2, C.Task>:
  [data_241(), data_191(), data_103(), data_104()]

def data_243(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_242(), data_99()}

def data_244() -> C.Task:
  C.ZombieLoop{data_23()}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_191(), data_103(), data_104()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_245(), data_99()}

def data_247() -> List<&2, C.Task>:
  [data_191(), data_103(), data_104()]

def data_248(+input: Nat) -> C.Machine:
  C.Machine{data_232(input), data_247(), data_99()}

def data_249(+input: Nat) -> R.World:
  R.World{data_213(input), data_147(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, True{}, False{}, 1n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_250() -> C.Task:
  C.RenderQueue{}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_103(), data_104()]

def data_252(+input: Nat) -> C.Machine:
  C.Machine{data_249(input), data_251(), data_99()}

def data_253() -> C.Task:
  C.UserQueue{}

def data_254() -> List<&2, C.Task>:
  [data_253(), data_103(), data_104()]

def data_255(+input: Nat) -> C.Machine:
  C.Machine{data_249(input), data_254(), data_99()}

def data_256() -> List<&2, C.Task>:
  [data_103(), data_104()]

def data_257(+input: Nat) -> C.Machine:
  C.Machine{data_249(input), data_256(), data_99()}

def data_258(+input: Nat) -> R.World:
  R.World{data_213(input), data_147(), data_22(), 1n, 0n, False{}, data_23(), data_23(), data_23(), data_24(), 0n, False{}, False{}, False{}, 1n, 3n, data_26(), data_149(input), data_31(), False{}, data_23(), data_35(), data_38(), data_23(), 0n, False{}, False{}, data_39(), 0n, data_42(), data_23(), 0n, 0n, 0n, 0n, data_23(), data_33(), data_43(), data_46(), data_48(), data_95(), 0n, data_52(), data_54(), data_56(), data_57(), data_59(), False{}, False{}, data_33(), data_61(), data_63(), data_66(), 0n, data_43(), False{}, data_67(), data_68(), data_69(), 0n, data_70(), data_71(), data_72(), data_73(), data_74(), 0n, data_77(), data_78(), data_2(), data_23(), data_84()}

def data_259() -> List<&2, C.Task>:
  [data_104()]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_259(), data_99()}

def data_261() -> List<&2, C.Task>:
  []

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_261(), data_99()}

def origin() -> R.World:
  data_85()

def state_0(+input: Nat) -> C.Machine:
  data_100(input)

def state_1(+input: Nat) -> C.Machine:
  data_106(input)

def state_2(+input: Nat) -> C.Machine:
  data_109(input)

def state_3(+input: Nat) -> C.Machine:
  data_112(input)

def state_4(+input: Nat) -> C.Machine:
  data_120(input)

def state_5(+input: Nat) -> C.Machine:
  data_123(input)

def state_6(+input: Nat) -> C.Machine:
  data_132(input)

def state_7(+input: Nat) -> C.Machine:
  data_137(input)

def state_8(+input: Nat) -> C.Machine:
  data_140(input)

def state_9(+input: Nat) -> C.Machine:
  data_143(input)

def state_10(+input: Nat) -> C.Machine:
  data_153(input)

def state_11(+input: Nat) -> C.Machine:
  data_156(input)

def state_12(+input: Nat) -> C.Machine:
  data_160(input)

def state_13(+input: Nat) -> C.Machine:
  data_166(input)

def state_14(+input: Nat) -> C.Machine:
  data_174(input)

def state_15(+input: Nat) -> C.Machine:
  data_176(input)

def state_16(+input: Nat) -> C.Machine:
  data_179(input)

def state_17(+input: Nat) -> C.Machine:
  data_184(input)

def state_18(+input: Nat) -> C.Machine:
  data_186(input)

def state_19(+input: Nat) -> C.Machine:
  data_189(input)

def state_20(+input: Nat) -> C.Machine:
  data_193(input)

def state_21(+input: Nat) -> C.Machine:
  data_198(input)

def state_22(+input: Nat) -> C.Machine:
  data_202(input)

def state_23(+input: Nat) -> C.Machine:
  data_207(input)

def state_24(+input: Nat) -> C.Machine:
  data_211(input)

def state_25(+input: Nat) -> C.Machine:
  data_217(input)

def state_26(+input: Nat) -> C.Machine:
  data_223(input)

def state_27(+input: Nat) -> C.Machine:
  data_227(input)

def state_28(+input: Nat) -> C.Machine:
  data_229(input)

def state_29(+input: Nat) -> C.Machine:
  data_231(input)

def state_30(+input: Nat) -> C.Machine:
  data_234(input)

def state_31(+input: Nat) -> C.Machine:
  data_236(input)

def state_32(+input: Nat) -> C.Machine:
  data_240(input)

def state_33(+input: Nat) -> C.Machine:
  data_243(input)

def state_34(+input: Nat) -> C.Machine:
  data_246(input)

def state_35(+input: Nat) -> C.Machine:
  data_248(input)

def state_36(+input: Nat) -> C.Machine:
  data_252(input)

def state_37(+input: Nat) -> C.Machine:
  data_255(input)

def state_38(+input: Nat) -> C.Machine:
  data_257(input)

def state_39(+input: Nat) -> C.Machine:
  data_260(input)

def state_40(+input: Nat) -> C.Machine:
  data_262(input)

def finalWorld(+input: Nat) -> R.World:
  data_258(input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+input: Nat) ->
  {C.publishValue(C.world(state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
