# Canonical data from the actual emitted core.step. The equations in
# chain-staging check it for arbitrary proposals; generation is not trusted.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./chain-driver.bend as Driver
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
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 5n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10() -> R.Value:
  R.Number{0n}

def data_11() -> R.Node:
  R.Node{data_9(), data_10(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

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
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_18() -> R.Value:
  R.Number{2n}

def data_19() -> R.Expr:
  R.Read{3n}

def data_20() -> R.Expr:
  R.Literal{data_18()}

def data_21() -> R.Expr:
  R.Multiply{data_19(), data_20()}

def data_22() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_23() -> R.NodeKind:
  R.Render{}

def data_24() -> R.Expr:
  R.Read{4n}

def data_25() -> R.Expr:
  R.Add{data_24(), data_14()}

def data_26() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_27() -> List<&2, R.Node>:
  [data_6(), data_8(), data_11(), data_17(), data_22(), data_26()]

def data_28() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_29() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 1n}

def data_30() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 1n}

def data_31() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 1n}

def data_32() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 1n}

def data_33() -> List<&2, R.Link>:
  [data_28(), data_29(), data_30(), data_31(), data_32()]

def data_34() -> List<&2, Nat>:
  [0n]

def data_35() -> List<&2, Nat>:
  []

def data_36() -> List<&2, R.QueueEntry>:
  []

def data_37() -> R.TreeNode:
  R.TreeNode{0n, data_35(), data_1()}

def data_38() -> List<&2, Nat>:
  [2n]

def data_39() -> R.TreeNode:
  R.TreeNode{0n, data_38(), data_1()}

def data_40() -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_18()}

def data_41() -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_40()]

def data_42() -> R.TraceEvent:
  R.Invoked{3n}

def data_43() -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10()}

def data_44() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_45() -> R.TraceEvent:
  R.Invoked{4n}

def data_46() -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_13()}

def data_47() -> R.TraceEvent:
  R.AccessorBound{4n}

def data_48() -> R.TraceEvent:
  R.Invoked{5n}

def data_49() -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_18()}

def data_50() -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_10()}

def data_51() -> R.TraceEvent:
  R.Applied{5n, data_18(), data_1()}

def data_52() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51()]

def data_53() -> R.Fault:
  R.Healthy{}

def data_54() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_55() -> R.Question:
  R.QuestionZero{}

def data_56() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_54(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_55(), data_2(), 0n, data_1()}

def data_57() -> List<&2, R.NodeExtension>:
  [data_56()]

def data_58() -> List<&2, R.CleanupAction>:
  []

def data_59() -> R.CleanupProgram:
  R.CleanupProgram{data_58(), False{}, 0n}

def data_60() -> List<&2, R.CleanupProgram>:
  [data_59()]

def data_61() -> List<&2, R.Report>:
  []

def data_62() -> R.OptionalIds:
  R.NoIds{}

def data_63() -> R.Transaction:
  R.Transaction{data_35(), data_35(), data_36(), data_35(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_62()}

def data_64() -> List<&2, R.Transaction>:
  [data_63()]

def data_65() -> List<&2, List<&2, Nat>>:
  [data_35()]

def data_66() -> R.AsyncSettlement:
  R.Unresolved{}

def data_67() -> R.AsyncObject:
  R.AsyncObject{False{}, data_66(), data_35(), 0n}

def data_68() -> List<&2, R.AsyncObject>:
  [data_67()]

def data_69() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_70() -> List<&2, R.AsyncObserver>:
  [data_69()]

def data_71() -> List<&2, R.HostJob>:
  []

def data_72() -> List<&2, R.NextInput>:
  []

def data_73() -> R.StreamPlan:
  R.StreamPlan{data_72(), False{}, data_2(), 0n}

def data_74() -> List<&2, R.StreamPlan>:
  [data_73()]

def data_75() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_76() -> List<&2, R.ExternalIterator>:
  [data_75()]

def data_77() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_78() -> List<&2, R.StreamState>:
  [data_77()]

def data_79() -> List<&2, R.IteratorEvent>:
  []

def data_80() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_66(), False{}, 0n, False{}, False{}, 0n}

def data_81() -> List<&2, R.Awaiter>:
  [data_80()]

def data_82() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_83() -> List<&2, R.AbortInput>:
  [data_82()]

def data_84() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_85() -> List<&2, R.ContextKey>:
  [data_84()]

def data_86() -> List<&2, R.ContextEntry>:
  []

def data_87() -> R.ContextRecord:
  R.ContextRecord{data_86()}

def data_88() -> List<&2, R.ContextRecord>:
  [data_87()]

def data_89() -> List<&2, R.Expr>:
  [data_4()]

def data_90() -> List<&2, R.ReactionState>:
  []

def data_91() -> List<&2, R.ComparatorBinding>:
  []

def data_92() -> List<&2, R.ActionState>:
  []

def data_93() -> List<&2, R.ActionWait>:
  []

def data_94() -> List<&2, R.ArrayData>:
  []

def data_95() -> List<&2, R.RepeatState>:
  []

def data_96() -> List<&2, R.MapState>:
  []

def data_97() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_98(+input: Nat) -> R.Value:
  R.Number{input}

def data_99(+input: Nat) -> R.Slot:
  R.Present{data_98(input)}

def data_100() -> R.Stamp:
  R.Stamped{7n}

def data_101(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_99(input), False{}, 0, 0, 0, 0n, data_100(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_102() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_103() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_104() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_105(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_102(), data_103(), data_104()]

def data_106() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_107() -> R.HostJob:
  R.FlushJob{}

def data_108() -> List<&2, R.HostJob>:
  [data_107()]

def data_109(+input: Nat) -> R.World:
  R.World{data_105(input), data_33(), data_106(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_110() -> C.Task:
  C.Round{}

def data_111() -> List<&2, C.Task>:
  [data_110()]

def data_112() -> List<&2, R.Value>:
  []

def data_113(+input: Nat) -> C.Machine:
  C.Machine{data_109(input), data_111(), data_112()}

def data_114(+input: Nat) -> R.World:
  R.World{data_105(input), data_33(), data_106(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_115() -> C.Task:
  C.RoundAfterSweep{}

def data_116() -> C.Task:
  C.FlushFinally{}

def data_117() -> C.Task:
  C.RoundEnd{}

def data_118() -> List<&2, C.Task>:
  [data_115(), data_116(), data_117()]

def data_119(+input: Nat) -> C.Machine:
  C.Machine{data_114(input), data_118(), data_112()}

def data_120(+input: Nat) -> R.World:
  R.World{data_105(input), data_33(), data_106(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_121() -> C.Task:
  C.HeapLoop{}

def data_122() -> List<&2, C.Task>:
  [data_121(), data_116(), data_117()]

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_120(input), data_122(), data_112()}

def data_124() -> C.Task:
  C.Recompute{3n, False{}}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_121(), data_116(), data_117()]

def data_126(+input: Nat) -> C.Machine:
  C.Machine{data_120(input), data_125(), data_112()}

def data_127() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_128(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_127(), data_103(), data_104()]

def data_129() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_130(+input: Nat) -> R.World:
  R.World{data_128(input), data_33(), data_129(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_131() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_132() -> List<&2, C.Task>:
  [data_131(), data_121(), data_116(), data_117()]

def data_133(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_132(), data_112()}

def data_134() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_135() -> List<&2, C.Task>:
  [data_134(), data_121(), data_116(), data_117()]

def data_136(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_135(), data_112()}

def data_137() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_138(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_137(), data_103(), data_104()]

def data_139() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_140(+input: Nat) -> R.World:
  R.World{data_138(input), data_33(), data_129(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_139(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_141() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_142() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_112(), 0n, False{}}

def data_143() -> C.Task:
  C.Finish{data_142()}

def data_144() -> List<&2, C.Task>:
  [data_141(), data_143(), data_121(), data_116(), data_117()]

def data_145(+input: Nat) -> C.Machine:
  C.Machine{data_140(input), data_144(), data_112()}

def data_146() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_147() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_148() -> C.Task:
  C.Binary{0}

def data_149() -> List<&2, C.Task>:
  [data_146(), data_147(), data_148(), data_143(), data_121(), data_116(), data_117()]

def data_150(+input: Nat) -> C.Machine:
  C.Machine{data_140(input), data_149(), data_112()}

def data_151() -> C.Task:
  C.ReadNode{2n}

def data_152() -> List<&2, C.Task>:
  [data_151(), data_147(), data_148(), data_143(), data_121(), data_116(), data_117()]

def data_153(+input: Nat) -> C.Machine:
  C.Machine{data_140(input), data_152(), data_112()}

def data_154() -> C.Task:
  C.ReadPrepared{2n}

def data_155() -> List<&2, C.Task>:
  [data_154(), data_147(), data_148(), data_143(), data_121(), data_116(), data_117()]

def data_156(+input: Nat) -> C.Machine:
  C.Machine{data_140(input), data_155(), data_112()}

def data_157() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_158(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_157(), data_103(), data_104()]

def data_159() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_160() -> List<&2, R.Link>:
  [data_28(), data_159(), data_30(), data_31(), data_32()]

def data_161(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_98(input)}

def data_162(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input)]

def data_163(+input: Nat) -> R.World:
  R.World{data_158(input), data_160(), data_129(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_164() -> List<&2, C.Task>:
  [data_147(), data_148(), data_143(), data_121(), data_116(), data_117()]

def data_165(+input: Nat) -> List<&2, R.Value>:
  [data_98(input)]

def data_166(+input: Nat) -> C.Machine:
  C.Machine{data_163(input), data_164(), data_165(input)}

def data_167() -> List<&2, C.Task>:
  [data_148(), data_143(), data_121(), data_116(), data_117()]

def data_168(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_98(input)]

def data_169(+input: Nat) -> C.Machine:
  C.Machine{data_163(input), data_167(), data_168(input)}

def data_170() -> List<&2, C.Task>:
  [data_143(), data_121(), data_116(), data_117()]

def data_171(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_172(+input: Nat) -> List<&2, R.Value>:
  [data_171(input)]

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_163(input), data_170(), data_172(input)}

def data_174() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_175(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_174(), data_103(), data_104()]

def data_176(+input: Nat) -> R.World:
  R.World{data_175(input), data_160(), data_129(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_177(+input: Nat) -> C.Task:
  C.PassReleases{data_142(), 0n, data_171(input), False{}, False{}, False{}, data_53()}

def data_178(+input: Nat) -> List<&2, C.Task>:
  [data_177(input), data_121(), data_116(), data_117()]

def data_179(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_178(input), data_112()}

def data_180(+input: Nat) -> R.Slot:
  R.Present{data_171(input)}

def data_181() -> R.Stamp:
  R.Stamped{8n}

def data_182(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_180(input), False{}, 0, 16384, 0, 0n, data_181(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_183() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_184(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_182(input), data_183(), data_104()]

def data_185() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_186(+input: Nat) -> R.World:
  R.World{data_184(input), data_160(), data_185(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_187() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_188() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_189() -> List<&2, C.Task>:
  [data_187(), data_188(), data_121(), data_116(), data_117()]

def data_190(+input: Nat) -> C.Machine:
  C.Machine{data_186(input), data_189(), data_112()}

def data_191() -> List<&2, C.Task>:
  [data_188(), data_121(), data_116(), data_117()]

def data_192(+input: Nat) -> C.Machine:
  C.Machine{data_186(input), data_191(), data_112()}

def data_193() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_194() -> List<&2, C.Task>:
  [data_193(), data_121(), data_116(), data_117()]

def data_195(+input: Nat) -> C.Machine:
  C.Machine{data_186(input), data_194(), data_112()}

def data_196(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_180(input), False{}, 128, 16384, 0, 0n, data_181(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_197(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_183(), data_104()]

def data_198() -> List<&2, Nat>:
  [2n, 3n]

def data_199(+input: Nat) -> R.World:
  R.World{data_197(input), data_160(), data_185(), 0n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_200(+input: Nat) -> C.Machine:
  C.Machine{data_199(input), data_122(), data_112()}

def data_201(+input: Nat) -> R.World:
  R.World{data_197(input), data_160(), data_185(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_202(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_122(), data_112()}

def data_203() -> C.Task:
  C.Recompute{4n, False{}}

def data_204() -> List<&2, C.Task>:
  [data_203(), data_121(), data_116(), data_117()]

def data_205(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_204(), data_112()}

def data_206() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_207(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_206(), data_104()]

def data_208(+input: Nat) -> R.World:
  R.World{data_207(input), data_160(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_209() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n}

def data_210() -> List<&2, C.Task>:
  [data_209(), data_121(), data_116(), data_117()]

def data_211(+input: Nat) -> C.Machine:
  C.Machine{data_208(input), data_210(), data_112()}

def data_212() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n}

def data_213() -> List<&2, C.Task>:
  [data_212(), data_121(), data_116(), data_117()]

def data_214(+input: Nat) -> C.Machine:
  C.Machine{data_208(input), data_213(), data_112()}

def data_215() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_216(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_215(), data_104()]

def data_217(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45()]

def data_218(+input: Nat) -> R.World:
  R.World{data_216(input), data_160(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_217(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_219() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_220() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_112(), 0n, False{}}

def data_221() -> C.Task:
  C.Finish{data_220()}

def data_222() -> List<&2, C.Task>:
  [data_219(), data_221(), data_121(), data_116(), data_117()]

def data_223(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_222(), data_112()}

def data_224() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_225() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_226() -> C.Task:
  C.Binary{1}

def data_227() -> List<&2, C.Task>:
  [data_224(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_228(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_227(), data_112()}

def data_229() -> C.Task:
  C.ReadNode{3n}

def data_230() -> List<&2, C.Task>:
  [data_229(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_231(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_230(), data_112()}

def data_232() -> C.Task:
  C.ReadPrepared{3n}

def data_233() -> List<&2, C.Task>:
  [data_232(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_234(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_233(), data_112()}

def data_235() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_236(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_235(), data_104()]

def data_237() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_238() -> List<&2, R.Link>:
  [data_28(), data_159(), data_237(), data_31(), data_32()]

def data_239(+input: Nat) -> R.World:
  R.World{data_236(input), data_238(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_217(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_240() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_241() -> C.Task:
  C.ReadStatus{3n}

def data_242() -> List<&2, C.Task>:
  [data_240(), data_241(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_243(+input: Nat) -> C.Machine:
  C.Machine{data_239(input), data_242(), data_112()}

def data_244() -> List<&2, C.Task>:
  [data_241(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_245(+input: Nat) -> C.Machine:
  C.Machine{data_239(input), data_244(), data_112()}

def data_246() -> C.Task:
  C.Serve{3n}

def data_247() -> C.Task:
  C.AfterServe{3n}

def data_248() -> List<&2, C.Task>:
  [data_246(), data_247(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_239(input), data_248(), data_112()}

def data_250() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_251(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_250(), data_104()]

def data_252(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_171(input)}

def data_253(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45(), data_252(input)]

def data_254(+input: Nat) -> R.World:
  R.World{data_251(input), data_238(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_255() -> List<&2, C.Task>:
  [data_247(), data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_256(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_255(), data_172(input)}

def data_257() -> List<&2, C.Task>:
  [data_225(), data_226(), data_221(), data_121(), data_116(), data_117()]

def data_258(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_257(), data_172(input)}

def data_259() -> List<&2, C.Task>:
  [data_226(), data_221(), data_121(), data_116(), data_117()]

def data_260(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_171(input)]

def data_261(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_259(), data_260(input)}

def data_262() -> List<&2, C.Task>:
  [data_221(), data_121(), data_116(), data_117()]

def data_263(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_264(+input: Nat) -> List<&2, R.Value>:
  [data_263(input)]

def data_265(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_262(), data_264(input)}

def data_266() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_267(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_266(), data_104()]

def data_268(+input: Nat) -> R.World:
  R.World{data_267(input), data_238(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_269(+input: Nat) -> C.Task:
  C.PassReleases{data_220(), 0n, data_263(input), False{}, False{}, False{}, data_53()}

def data_270(+input: Nat) -> List<&2, C.Task>:
  [data_269(input), data_121(), data_116(), data_117()]

def data_271(+input: Nat) -> C.Machine:
  C.Machine{data_268(input), data_270(input), data_112()}

def data_272(+input: Nat) -> R.Slot:
  R.Present{data_263(input)}

def data_273() -> R.Stamp:
  R.Stamped{9n}

def data_274(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_272(input), False{}, 0, 16384, 0, 0n, data_273(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_275(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_274(input), data_104()]

def data_276(+input: Nat) -> R.World:
  R.World{data_275(input), data_238(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_277() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_278() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}}

def data_279() -> List<&2, C.Task>:
  [data_277(), data_278(), data_121(), data_116(), data_117()]

def data_280(+input: Nat) -> C.Machine:
  C.Machine{data_276(input), data_279(), data_112()}

def data_281() -> List<&2, C.Task>:
  [data_278(), data_121(), data_116(), data_117()]

def data_282(+input: Nat) -> C.Machine:
  C.Machine{data_276(input), data_281(), data_112()}

def data_283() -> C.Task:
  C.QueuePublication{4n, False{}, False{}}

def data_284() -> List<&2, C.Task>:
  [data_283(), data_121(), data_116(), data_117()]

def data_285(+input: Nat) -> C.Machine:
  C.Machine{data_276(input), data_284(), data_112()}

def data_286(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_272(input), False{}, 128, 16384, 0, 0n, data_273(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_287(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_104()]

def data_288() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_289(+input: Nat) -> R.World:
  R.World{data_287(input), data_238(), data_129(), 1n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_290(+input: Nat) -> C.Machine:
  C.Machine{data_289(input), data_122(), data_112()}

def data_291(+input: Nat) -> R.World:
  R.World{data_287(input), data_238(), data_129(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_292(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_122(), data_112()}

def data_293() -> C.Task:
  C.Recompute{5n, False{}}

def data_294() -> List<&2, C.Task>:
  [data_293(), data_121(), data_116(), data_117()]

def data_295(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_294(), data_112()}

def data_296() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_297(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_296()]

def data_298() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_299(+input: Nat) -> R.World:
  R.World{data_297(input), data_238(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_300() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n}

def data_301() -> List<&2, C.Task>:
  [data_300(), data_121(), data_116(), data_117()]

def data_302(+input: Nat) -> C.Machine:
  C.Machine{data_299(input), data_301(), data_112()}

def data_303() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n}

def data_304() -> List<&2, C.Task>:
  [data_303(), data_121(), data_116(), data_117()]

def data_305(+input: Nat) -> C.Machine:
  C.Machine{data_299(input), data_304(), data_112()}

def data_306() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_307(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_306()]

def data_308(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45(), data_252(input), data_48()]

def data_309(+input: Nat) -> R.World:
  R.World{data_307(input), data_238(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_308(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_310() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_311() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_112(), 0n, False{}}

def data_312() -> C.Task:
  C.Finish{data_311()}

def data_313() -> List<&2, C.Task>:
  [data_310(), data_312(), data_121(), data_116(), data_117()]

def data_314(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_313(), data_112()}

def data_315() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_316() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_317() -> List<&2, C.Task>:
  [data_315(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_318(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_317(), data_112()}

def data_319() -> C.Task:
  C.ReadNode{4n}

def data_320() -> List<&2, C.Task>:
  [data_319(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_321(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_320(), data_112()}

def data_322() -> C.Task:
  C.ReadPrepared{4n}

def data_323() -> List<&2, C.Task>:
  [data_322(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_324(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_323(), data_112()}

def data_325() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_326(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_325()]

def data_327() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_328() -> List<&2, R.Link>:
  [data_28(), data_159(), data_237(), data_327(), data_32()]

def data_329(+input: Nat) -> R.World:
  R.World{data_326(input), data_328(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_308(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_330() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_331() -> C.Task:
  C.ReadStatus{4n}

def data_332() -> List<&2, C.Task>:
  [data_330(), data_331(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_333(+input: Nat) -> C.Machine:
  C.Machine{data_329(input), data_332(), data_112()}

def data_334() -> List<&2, C.Task>:
  [data_331(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_335(+input: Nat) -> C.Machine:
  C.Machine{data_329(input), data_334(), data_112()}

def data_336() -> C.Task:
  C.Serve{4n}

def data_337() -> C.Task:
  C.AfterServe{4n}

def data_338() -> List<&2, C.Task>:
  [data_336(), data_337(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_339(+input: Nat) -> C.Machine:
  C.Machine{data_329(input), data_338(), data_112()}

def data_340() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_341(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_340()]

def data_342(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_263(input)}

def data_343(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45(), data_252(input), data_48(), data_342(input)]

def data_344(+input: Nat) -> R.World:
  R.World{data_341(input), data_328(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_343(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_345() -> List<&2, C.Task>:
  [data_337(), data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_346(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_345(), data_264(input)}

def data_347() -> List<&2, C.Task>:
  [data_316(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_348(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_347(), data_264(input)}

def data_349() -> List<&2, C.Task>:
  [data_151(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_350(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_349(), data_264(input)}

def data_351() -> List<&2, C.Task>:
  [data_154(), data_148(), data_312(), data_121(), data_116(), data_117()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_351(), data_264(input)}

def data_353() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_354(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_353()]

def data_355() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_356() -> List<&2, R.Link>:
  [data_28(), data_159(), data_237(), data_327(), data_355()]

def data_357(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_98(input)}

def data_358(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45(), data_252(input), data_48(), data_342(input), data_357(input)]

def data_359(+input: Nat) -> R.World:
  R.World{data_354(input), data_356(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_360() -> List<&2, C.Task>:
  [data_148(), data_312(), data_121(), data_116(), data_117()]

def data_361(+input: Nat) -> List<&2, R.Value>:
  [data_98(input), data_263(input)]

def data_362(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_360(), data_361(input)}

def data_363() -> List<&2, C.Task>:
  [data_312(), data_121(), data_116(), data_117()]

def data_364(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_365(+input: Nat) -> List<&2, R.Value>:
  [data_364(input)]

def data_366(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_363(), data_365(input)}

def data_367() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_368(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_367()]

def data_369(+input: Nat) -> R.World:
  R.World{data_368(input), data_356(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_370(+input: Nat) -> C.Task:
  C.PassReleases{data_311(), 0n, data_364(input), False{}, False{}, False{}, data_53()}

def data_371(+input: Nat) -> List<&2, C.Task>:
  [data_370(input), data_121(), data_116(), data_117()]

def data_372(+input: Nat) -> C.Machine:
  C.Machine{data_369(input), data_371(input), data_112()}

def data_373(+input: Nat) -> R.Node:
  R.Node{data_23(), data_364(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_374(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_373(input)]

def data_375() -> List<&2, Nat>:
  [5n]

def data_376(+input: Nat) -> R.World:
  R.World{data_374(input), data_356(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_377() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_378() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}}

def data_379() -> List<&2, C.Task>:
  [data_377(), data_378(), data_121(), data_116(), data_117()]

def data_380(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_379(), data_112()}

def data_381() -> List<&2, C.Task>:
  [data_378(), data_121(), data_116(), data_117()]

def data_382(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_381(), data_112()}

def data_383() -> C.Task:
  C.QueuePublication{5n, False{}, False{}}

def data_384() -> List<&2, C.Task>:
  [data_383(), data_121(), data_116(), data_117()]

def data_385(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_384(), data_112()}

def data_386(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_122(), data_112()}

def data_387(+input: Nat) -> R.World:
  R.World{data_374(input), data_356(), data_298(), 3n, 2n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_388(+input: Nat) -> C.Machine:
  C.Machine{data_387(input), data_122(), data_112()}

def data_389(+input: Nat) -> R.World:
  R.World{data_374(input), data_356(), data_298(), 3n, 0n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_390() -> C.Task:
  C.Seam{}

def data_391() -> List<&2, C.Task>:
  [data_390(), data_116(), data_117()]

def data_392(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_391(), data_112()}

def data_393() -> C.Task:
  C.Settle{}

def data_394() -> C.Task:
  C.AfterSettle{}

def data_395() -> List<&2, C.Task>:
  [data_393(), data_394(), data_116(), data_117()]

def data_396(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_395(), data_112()}

def data_397() -> C.Task:
  C.CommitIntake{0n}

def data_398() -> C.Task:
  C.TrimIntake{0n}

def data_399() -> C.Task:
  C.FinishSettleIntake{0n}

def data_400() -> List<&2, C.Task>:
  [data_397(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_401(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_400(), data_112()}

def data_402() -> C.Task:
  C.CommitPending{2n}

def data_403() -> C.Task:
  C.CommitIntake{1n}

def data_404() -> List<&2, C.Task>:
  [data_402(), data_403(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_405(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_404(), data_112()}

def data_406(+input: Nat) -> R.Node:
  R.Node{data_9(), data_98(input), data_2(), False{}, 0, 0, 0, 0n, data_100(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_407(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_406(input), data_196(input), data_286(input), data_373(input)]

def data_408(+input: Nat) -> R.World:
  R.World{data_407(input), data_356(), data_298(), 3n, 0n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_409() -> List<&2, C.Task>:
  [data_403(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_410(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_409(), data_112()}

def data_411() -> C.Task:
  C.CommitPending{3n}

def data_412() -> C.Task:
  C.CommitIntake{2n}

def data_413() -> List<&2, C.Task>:
  [data_411(), data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_414(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_413(), data_112()}

def data_415(+input: Nat) -> R.Node:
  R.Node{data_12(), data_171(input), data_2(), False{}, 0, 16384, 0, 0n, data_181(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_416(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_406(input), data_415(input), data_286(input), data_373(input)]

def data_417(+input: Nat) -> R.World:
  R.World{data_416(input), data_356(), data_298(), 3n, 0n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_418() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_419() -> List<&2, C.Task>:
  [data_418(), data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_420(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_419(), data_112()}

def data_421() -> O.Task:
  O.TrimDeps{3n}

def data_422() -> List<&2, O.Task>:
  [data_421()]

def data_423() -> C.Task:
  C.OwnerTasks{data_422()}

def data_424() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_425() -> List<&2, C.Task>:
  [data_423(), data_424(), data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_426(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_425(), data_112()}

def data_427() -> List<&2, O.Task>:
  []

def data_428() -> C.Task:
  C.OwnerTasks{data_427()}

def data_429() -> List<&2, C.Task>:
  [data_428(), data_424(), data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_430(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_429(), data_112()}

def data_431() -> List<&2, C.Task>:
  [data_424(), data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_432(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_431(), data_112()}

def data_433() -> List<&2, C.Task>:
  [data_412(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_434(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_433(), data_112()}

def data_435() -> C.Task:
  C.CommitPending{4n}

def data_436() -> C.Task:
  C.CommitIntake{3n}

def data_437() -> List<&2, C.Task>:
  [data_435(), data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_438(+input: Nat) -> C.Machine:
  C.Machine{data_417(input), data_437(), data_112()}

def data_439(+input: Nat) -> R.Node:
  R.Node{data_12(), data_263(input), data_2(), False{}, 0, 16384, 0, 0n, data_273(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_440(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_406(input), data_415(input), data_439(input), data_373(input)]

def data_441(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_442() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_443() -> List<&2, C.Task>:
  [data_442(), data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_444(+input: Nat) -> C.Machine:
  C.Machine{data_441(input), data_443(), data_112()}

def data_445() -> O.Task:
  O.TrimDeps{4n}

def data_446() -> List<&2, O.Task>:
  [data_445()]

def data_447() -> C.Task:
  C.OwnerTasks{data_446()}

def data_448() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_449() -> List<&2, C.Task>:
  [data_447(), data_448(), data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_450(+input: Nat) -> C.Machine:
  C.Machine{data_441(input), data_449(), data_112()}

def data_451() -> List<&2, C.Task>:
  [data_428(), data_448(), data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_452(+input: Nat) -> C.Machine:
  C.Machine{data_441(input), data_451(), data_112()}

def data_453() -> List<&2, C.Task>:
  [data_448(), data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_454(+input: Nat) -> C.Machine:
  C.Machine{data_441(input), data_453(), data_112()}

def data_455() -> List<&2, C.Task>:
  [data_436(), data_398(), data_399(), data_394(), data_116(), data_117()]

def data_456(+input: Nat) -> C.Machine:
  C.Machine{data_441(input), data_455(), data_112()}

def data_457(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_458() -> List<&2, C.Task>:
  [data_398(), data_399(), data_394(), data_116(), data_117()]

def data_459(+input: Nat) -> C.Machine:
  C.Machine{data_457(input), data_458(), data_112()}

def data_460() -> List<&2, C.Task>:
  [data_399(), data_394(), data_116(), data_117()]

def data_461(+input: Nat) -> C.Machine:
  C.Machine{data_457(input), data_460(), data_112()}

def data_462(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_463() -> C.SeamFrame:
  C.SeamFrame{0n, data_375(), data_36()}

def data_464() -> C.Task:
  C.LandTransactions{data_463(), 0n}

def data_465() -> List<&2, C.Task>:
  [data_464(), data_394(), data_116(), data_117()]

def data_466(+input: Nat) -> C.Machine:
  C.Machine{data_462(input), data_465(), data_112()}

def data_467() -> C.Task:
  C.CompleteSettle{data_463()}

def data_468() -> List<&2, C.Task>:
  [data_467(), data_394(), data_116(), data_117()]

def data_469(+input: Nat) -> C.Machine:
  C.Machine{data_462(input), data_468(), data_112()}

def data_470() -> C.Task:
  C.ZombieLoop{data_35()}

def data_471() -> List<&2, C.Task>:
  [data_470(), data_394(), data_116(), data_117()]

def data_472(+input: Nat) -> C.Machine:
  C.Machine{data_457(input), data_471(), data_112()}

def data_473() -> List<&2, C.Task>:
  [data_394(), data_116(), data_117()]

def data_474(+input: Nat) -> C.Machine:
  C.Machine{data_457(input), data_473(), data_112()}

def data_475(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_375(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_476() -> C.Task:
  C.RenderQueue{}

def data_477() -> List<&2, C.Task>:
  [data_476(), data_116(), data_117()]

def data_478(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_477(), data_112()}

def data_479(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_480() -> C.Task:
  C.RunEffect{5n}

def data_481() -> C.Task:
  C.UserQueue{}

def data_482() -> List<&2, C.Task>:
  [data_480(), data_481(), data_116(), data_117()]

def data_483(+input: Nat) -> C.Machine:
  C.Machine{data_479(input), data_482(), data_112()}

def data_484() -> C.Task:
  C.ApplyEffect{5n}

def data_485() -> C.Task:
  C.EffectFinally{5n, True{}, data_112()}

def data_486() -> List<&2, C.Task>:
  [data_484(), data_485(), data_481(), data_116(), data_117()]

def data_487(+input: Nat) -> C.Machine:
  C.Machine{data_479(input), data_486(), data_112()}

def data_488(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_364(input)}

def data_489(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_488(input)]

def data_490(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_364(input), data_18()}

def data_491(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_161(input), data_45(), data_252(input), data_48(), data_342(input), data_357(input), data_490(input)]

def data_492(+input: Nat) -> R.World:
  R.World{data_440(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_489(input), data_491(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_493() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_494() -> List<&2, C.Task>:
  [data_493(), data_485(), data_481(), data_116(), data_117()]

def data_495(+input: Nat) -> C.Machine:
  C.Machine{data_492(input), data_494(), data_112()}

def data_496() -> List<&2, C.Task>:
  [data_485(), data_481(), data_116(), data_117()]

def data_497(+input: Nat) -> C.Machine:
  C.Machine{data_492(input), data_496(), data_112()}

def data_498(+input: Nat) -> R.Node:
  R.Node{data_23(), data_364(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_364(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_499(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_406(input), data_415(input), data_439(input), data_498(input)]

def data_500(+input: Nat) -> R.World:
  R.World{data_499(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_489(input), data_491(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_501() -> O.Task:
  O.TrimDeps{5n}

def data_502() -> List<&2, O.Task>:
  [data_501()]

def data_503() -> C.Task:
  C.OwnerTasks{data_502()}

def data_504() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_112()}

def data_505() -> List<&2, C.Task>:
  [data_503(), data_504(), data_481(), data_116(), data_117()]

def data_506(+input: Nat) -> C.Machine:
  C.Machine{data_500(input), data_505(), data_112()}

def data_507() -> List<&2, C.Task>:
  [data_428(), data_504(), data_481(), data_116(), data_117()]

def data_508(+input: Nat) -> C.Machine:
  C.Machine{data_500(input), data_507(), data_112()}

def data_509() -> List<&2, C.Task>:
  [data_504(), data_481(), data_116(), data_117()]

def data_510(+input: Nat) -> C.Machine:
  C.Machine{data_500(input), data_509(), data_112()}

def data_511() -> List<&2, C.Task>:
  [data_481(), data_116(), data_117()]

def data_512(+input: Nat) -> C.Machine:
  C.Machine{data_500(input), data_511(), data_112()}

def data_513() -> List<&2, C.Task>:
  [data_116(), data_117()]

def data_514(+input: Nat) -> C.Machine:
  C.Machine{data_500(input), data_513(), data_112()}

def data_515(+input: Nat) -> R.World:
  R.World{data_499(input), data_356(), data_298(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_489(input), data_491(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_516() -> List<&2, C.Task>:
  [data_117()]

def data_517(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_516(), data_112()}

def data_518() -> List<&2, C.Task>:
  []

def data_519(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_518(), data_112()}

def data_520(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_180(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_521(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_520(input), data_103(), data_104()]

def data_522(+input: Nat) -> R.World:
  R.World{data_521(input), data_160(), data_129(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_162(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_523(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_272(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_524(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_523(input), data_104()]

def data_525(+input: Nat) -> R.World:
  R.World{data_524(input), data_238(), data_129(), 1n, 2n, False{}, data_198(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_253(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_526() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_527(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_196(input), data_286(input), data_526()]

def data_528(+input: Nat) -> R.World:
  R.World{data_527(input), data_356(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_529(+input: Nat) -> R.World:
  R.World{data_527(input), data_356(), data_298(), 2n, 2n, False{}, data_288(), data_35(), data_375(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_108(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_530() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_531(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_99(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_532(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_531(input), data_17(), data_22(), data_26()]

def data_533(+input: Nat) -> R.World:
  R.World{data_532(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_534(+input: Nat) -> R.World:
  R.World{data_105(input), data_33(), data_106(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_535(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_17(), data_22(), data_26()]

def data_536(+input: Nat) -> R.World:
  R.World{data_535(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def data_537() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_538(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_101(input), data_102(), data_103(), data_537()]

def data_539() -> List<&2, Nat>:
  [3n]

def data_540(+input: Nat) -> R.World:
  R.World{data_538(input), data_33(), data_539(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96()}

def origin() -> R.World:
  data_97()

def state_0(+input: Nat) -> C.Machine:
  data_113(input)

def state_1(+input: Nat) -> C.Machine:
  data_119(input)

def state_2(+input: Nat) -> C.Machine:
  data_123(input)

def state_3(+input: Nat) -> C.Machine:
  data_126(input)

def state_4(+input: Nat) -> C.Machine:
  data_133(input)

def state_5(+input: Nat) -> C.Machine:
  data_136(input)

def state_6(+input: Nat) -> C.Machine:
  data_145(input)

def state_7(+input: Nat) -> C.Machine:
  data_150(input)

def state_8(+input: Nat) -> C.Machine:
  data_153(input)

def state_9(+input: Nat) -> C.Machine:
  data_156(input)

def state_10(+input: Nat) -> C.Machine:
  data_166(input)

def state_11(+input: Nat) -> C.Machine:
  data_169(input)

def state_12(+input: Nat) -> C.Machine:
  data_173(input)

def state_13(+input: Nat) -> C.Machine:
  data_179(input)

def state_14(+input: Nat) -> C.Machine:
  data_190(input)

def state_15(+input: Nat) -> C.Machine:
  data_192(input)

def state_16(+input: Nat) -> C.Machine:
  data_195(input)

def state_17(+input: Nat) -> C.Machine:
  data_200(input)

def state_18(+input: Nat) -> C.Machine:
  data_202(input)

def state_19(+input: Nat) -> C.Machine:
  data_205(input)

def state_20(+input: Nat) -> C.Machine:
  data_211(input)

def state_21(+input: Nat) -> C.Machine:
  data_214(input)

def state_22(+input: Nat) -> C.Machine:
  data_223(input)

def state_23(+input: Nat) -> C.Machine:
  data_228(input)

def state_24(+input: Nat) -> C.Machine:
  data_231(input)

def state_25(+input: Nat) -> C.Machine:
  data_234(input)

def state_26(+input: Nat) -> C.Machine:
  data_243(input)

def state_27(+input: Nat) -> C.Machine:
  data_245(input)

def state_28(+input: Nat) -> C.Machine:
  data_249(input)

def state_29(+input: Nat) -> C.Machine:
  data_256(input)

def state_30(+input: Nat) -> C.Machine:
  data_258(input)

def state_31(+input: Nat) -> C.Machine:
  data_261(input)

def state_32(+input: Nat) -> C.Machine:
  data_265(input)

def state_33(+input: Nat) -> C.Machine:
  data_271(input)

def state_34(+input: Nat) -> C.Machine:
  data_280(input)

def state_35(+input: Nat) -> C.Machine:
  data_282(input)

def state_36(+input: Nat) -> C.Machine:
  data_285(input)

def state_37(+input: Nat) -> C.Machine:
  data_290(input)

def state_38(+input: Nat) -> C.Machine:
  data_292(input)

def state_39(+input: Nat) -> C.Machine:
  data_295(input)

def state_40(+input: Nat) -> C.Machine:
  data_302(input)

def state_41(+input: Nat) -> C.Machine:
  data_305(input)

def state_42(+input: Nat) -> C.Machine:
  data_314(input)

def state_43(+input: Nat) -> C.Machine:
  data_318(input)

def state_44(+input: Nat) -> C.Machine:
  data_321(input)

def state_45(+input: Nat) -> C.Machine:
  data_324(input)

def state_46(+input: Nat) -> C.Machine:
  data_333(input)

def state_47(+input: Nat) -> C.Machine:
  data_335(input)

def state_48(+input: Nat) -> C.Machine:
  data_339(input)

def state_49(+input: Nat) -> C.Machine:
  data_346(input)

def state_50(+input: Nat) -> C.Machine:
  data_348(input)

def state_51(+input: Nat) -> C.Machine:
  data_350(input)

def state_52(+input: Nat) -> C.Machine:
  data_352(input)

def state_53(+input: Nat) -> C.Machine:
  data_362(input)

def state_54(+input: Nat) -> C.Machine:
  data_366(input)

def state_55(+input: Nat) -> C.Machine:
  data_372(input)

def state_56(+input: Nat) -> C.Machine:
  data_380(input)

def state_57(+input: Nat) -> C.Machine:
  data_382(input)

def state_58(+input: Nat) -> C.Machine:
  data_385(input)

def state_59(+input: Nat) -> C.Machine:
  data_386(input)

def state_60(+input: Nat) -> C.Machine:
  data_388(input)

def state_61(+input: Nat) -> C.Machine:
  data_392(input)

def state_62(+input: Nat) -> C.Machine:
  data_396(input)

def state_63(+input: Nat) -> C.Machine:
  data_401(input)

def state_64(+input: Nat) -> C.Machine:
  data_405(input)

def state_65(+input: Nat) -> C.Machine:
  data_410(input)

def state_66(+input: Nat) -> C.Machine:
  data_414(input)

def state_67(+input: Nat) -> C.Machine:
  data_420(input)

def state_68(+input: Nat) -> C.Machine:
  data_426(input)

def state_69(+input: Nat) -> C.Machine:
  data_430(input)

def state_70(+input: Nat) -> C.Machine:
  data_432(input)

def state_71(+input: Nat) -> C.Machine:
  data_434(input)

def state_72(+input: Nat) -> C.Machine:
  data_438(input)

def state_73(+input: Nat) -> C.Machine:
  data_444(input)

def state_74(+input: Nat) -> C.Machine:
  data_450(input)

def state_75(+input: Nat) -> C.Machine:
  data_452(input)

def state_76(+input: Nat) -> C.Machine:
  data_454(input)

def state_77(+input: Nat) -> C.Machine:
  data_456(input)

def state_78(+input: Nat) -> C.Machine:
  data_459(input)

def state_79(+input: Nat) -> C.Machine:
  data_461(input)

def state_80(+input: Nat) -> C.Machine:
  data_466(input)

def state_81(+input: Nat) -> C.Machine:
  data_469(input)

def state_82(+input: Nat) -> C.Machine:
  data_472(input)

def state_83(+input: Nat) -> C.Machine:
  data_474(input)

def state_84(+input: Nat) -> C.Machine:
  data_478(input)

def state_85(+input: Nat) -> C.Machine:
  data_483(input)

def state_86(+input: Nat) -> C.Machine:
  data_487(input)

def state_87(+input: Nat) -> C.Machine:
  data_495(input)

def state_88(+input: Nat) -> C.Machine:
  data_497(input)

def state_89(+input: Nat) -> C.Machine:
  data_506(input)

def state_90(+input: Nat) -> C.Machine:
  data_508(input)

def state_91(+input: Nat) -> C.Machine:
  data_510(input)

def state_92(+input: Nat) -> C.Machine:
  data_512(input)

def state_93(+input: Nat) -> C.Machine:
  data_514(input)

def state_94(+input: Nat) -> C.Machine:
  data_517(input)

def state_95(+input: Nat) -> C.Machine:
  data_519(input)

def finalWorld(+input: Nat) -> R.World:
  data_515(input)

def slot_13(+input: Nat) -> R.World:
  data_522(input)

def notify_13(+input: Nat) -> R.World:
  data_186(input)

def slot_33(+input: Nat) -> R.World:
  data_525(input)

def notify_33(+input: Nat) -> R.World:
  data_276(input)

def modified_55(+input: Nat) -> R.World:
  data_528(input)

def queued_55(+input: Nat) -> R.World:
  data_529(input)

def value_55(+input: Nat) -> R.World:
  data_376(input)

def setter_queued(+input: Nat) -> R.World:
  data_530()

def setter_slot(+input: Nat) -> R.World:
  data_533(input)

def setter_inserted(+input: Nat) -> R.World:
  data_534(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_109(input)

def setter_stamped(+input: Nat) -> R.World:
  data_536(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_540(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_534(input)

