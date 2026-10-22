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

def data_97() -> List<&2, R.Guess>:
  []

def data_98() -> R.LaneMount:
  R.MountUnset{}

def data_99() -> R.LaneState:
  R.LaneState{data_35(), data_65(), data_35(), data_97(), 0n, data_98()}

def data_100() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_101() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_102(+input: Nat) -> R.Value:
  R.Number{input}

def data_103(+input: Nat) -> R.Slot:
  R.Present{data_102(input)}

def data_104() -> R.Stamp:
  R.Stamped{7n}

def data_105(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_103(input), False{}, 0, 0, 0, 0n, data_104(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_106() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_107() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_108() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_109(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_106(), data_107(), data_108()]

def data_110() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_111() -> R.HostJob:
  R.FlushJob{}

def data_112() -> List<&2, R.HostJob>:
  [data_111()]

def data_113(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_114() -> C.Task:
  C.Round{}

def data_115() -> List<&2, C.Task>:
  [data_114()]

def data_116() -> List<&2, R.Value>:
  []

def data_117(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_115(), data_116()}

def data_118(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_119() -> C.Task:
  C.RoundAfterSweep{}

def data_120() -> C.Task:
  C.FlushFinally{}

def data_121() -> C.Task:
  C.RoundEnd{}

def data_122() -> List<&2, C.Task>:
  [data_119(), data_120(), data_121()]

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_118(input), data_122(), data_116()}

def data_124(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_125() -> C.Task:
  C.HeapLoop{}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_120(), data_121()]

def data_127(+input: Nat) -> C.Machine:
  C.Machine{data_124(input), data_126(), data_116()}

def data_128() -> C.Task:
  C.Recompute{3n, False{}}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_125(), data_120(), data_121()]

def data_130(+input: Nat) -> C.Machine:
  C.Machine{data_124(input), data_129(), data_116()}

def data_131() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_132(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_131(), data_107(), data_108()]

def data_133() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_134() -> R.LaneMount:
  R.MountFalse{}

def data_135() -> R.LaneState:
  R.LaneState{data_35(), data_65(), data_35(), data_97(), 0n, data_134()}

def data_136(+input: Nat) -> R.World:
  R.World{data_132(input), data_33(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_137() -> C.LanePass:
  C.LanePass{0n, data_98(), data_134()}

def data_138() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_137()}

def data_139() -> List<&2, C.Task>:
  [data_138(), data_125(), data_120(), data_121()]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_136(input), data_139(), data_116()}

def data_141() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_137()}

def data_142() -> List<&2, C.Task>:
  [data_141(), data_125(), data_120(), data_121()]

def data_143(+input: Nat) -> C.Machine:
  C.Machine{data_136(input), data_142(), data_116()}

def data_144() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_145(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_144(), data_107(), data_108()]

def data_146() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_147(+input: Nat) -> R.World:
  R.World{data_145(input), data_33(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_146(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_148() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_149() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}, data_137()}

def data_150() -> C.Task:
  C.Finish{data_149()}

def data_151() -> List<&2, C.Task>:
  [data_148(), data_150(), data_125(), data_120(), data_121()]

def data_152(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_151(), data_116()}

def data_153() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_154() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_155() -> C.Task:
  C.Binary{0}

def data_156() -> List<&2, C.Task>:
  [data_153(), data_154(), data_155(), data_150(), data_125(), data_120(), data_121()]

def data_157(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_156(), data_116()}

def data_158() -> C.Task:
  C.ReadNode{2n}

def data_159() -> List<&2, C.Task>:
  [data_158(), data_154(), data_155(), data_150(), data_125(), data_120(), data_121()]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_159(), data_116()}

def data_161() -> C.Task:
  C.ReadPrepared{2n}

def data_162() -> List<&2, C.Task>:
  [data_161(), data_154(), data_155(), data_150(), data_125(), data_120(), data_121()]

def data_163(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_162(), data_116()}

def data_164() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_165(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_164(), data_107(), data_108()]

def data_166() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_167() -> List<&2, R.Link>:
  [data_28(), data_166(), data_30(), data_31(), data_32()]

def data_168(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_102(input)}

def data_169(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input)]

def data_170(+input: Nat) -> R.World:
  R.World{data_165(input), data_167(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_171() -> List<&2, C.Task>:
  [data_154(), data_155(), data_150(), data_125(), data_120(), data_121()]

def data_172(+input: Nat) -> List<&2, R.Value>:
  [data_102(input)]

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_171(), data_172(input)}

def data_174() -> List<&2, C.Task>:
  [data_155(), data_150(), data_125(), data_120(), data_121()]

def data_175(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_102(input)]

def data_176(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_174(), data_175(input)}

def data_177() -> List<&2, C.Task>:
  [data_150(), data_125(), data_120(), data_121()]

def data_178(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_179(+input: Nat) -> List<&2, R.Value>:
  [data_178(input)]

def data_180(+input: Nat) -> C.Machine:
  C.Machine{data_170(input), data_177(), data_179(input)}

def data_181() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_182(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_181(), data_107(), data_108()]

def data_183(+input: Nat) -> R.World:
  R.World{data_182(input), data_167(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_184(+input: Nat) -> C.Task:
  C.PassReleases{data_149(), 0n, data_178(input), False{}, False{}, False{}, data_53()}

def data_185(+input: Nat) -> List<&2, C.Task>:
  [data_184(input), data_125(), data_120(), data_121()]

def data_186(+input: Nat) -> C.Machine:
  C.Machine{data_183(input), data_185(input), data_116()}

def data_187(+input: Nat) -> R.Slot:
  R.Present{data_178(input)}

def data_188() -> R.Stamp:
  R.Stamped{8n}

def data_189(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_187(input), False{}, 0, 16384, 0, 0n, data_188(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_190() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_191(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_189(input), data_190(), data_108()]

def data_192() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_193(+input: Nat) -> R.World:
  R.World{data_191(input), data_167(), data_192(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_194() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_195() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_196() -> List<&2, C.Task>:
  [data_194(), data_195(), data_125(), data_120(), data_121()]

def data_197(+input: Nat) -> C.Machine:
  C.Machine{data_193(input), data_196(), data_116()}

def data_198() -> List<&2, C.Task>:
  [data_195(), data_125(), data_120(), data_121()]

def data_199(+input: Nat) -> C.Machine:
  C.Machine{data_193(input), data_198(), data_116()}

def data_200() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_201() -> List<&2, C.Task>:
  [data_200(), data_125(), data_120(), data_121()]

def data_202(+input: Nat) -> C.Machine:
  C.Machine{data_193(input), data_201(), data_116()}

def data_203(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_187(input), False{}, 128, 16384, 0, 0n, data_188(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_204(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_190(), data_108()]

def data_205() -> List<&2, Nat>:
  [2n, 3n]

def data_206(+input: Nat) -> R.World:
  R.World{data_204(input), data_167(), data_192(), 0n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_207(+input: Nat) -> C.Machine:
  C.Machine{data_206(input), data_126(), data_116()}

def data_208(+input: Nat) -> R.World:
  R.World{data_204(input), data_167(), data_192(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_208(input), data_126(), data_116()}

def data_210() -> C.Task:
  C.Recompute{4n, False{}}

def data_211() -> List<&2, C.Task>:
  [data_210(), data_125(), data_120(), data_121()]

def data_212(+input: Nat) -> C.Machine:
  C.Machine{data_208(input), data_211(), data_116()}

def data_213() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_214(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_213(), data_108()]

def data_215(+input: Nat) -> R.World:
  R.World{data_214(input), data_167(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_216() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_137()}

def data_217() -> List<&2, C.Task>:
  [data_216(), data_125(), data_120(), data_121()]

def data_218(+input: Nat) -> C.Machine:
  C.Machine{data_215(input), data_217(), data_116()}

def data_219() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_137()}

def data_220() -> List<&2, C.Task>:
  [data_219(), data_125(), data_120(), data_121()]

def data_221(+input: Nat) -> C.Machine:
  C.Machine{data_215(input), data_220(), data_116()}

def data_222() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_223(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_222(), data_108()]

def data_224(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45()]

def data_225(+input: Nat) -> R.World:
  R.World{data_223(input), data_167(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_224(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_226() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_227() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}, data_137()}

def data_228() -> C.Task:
  C.Finish{data_227()}

def data_229() -> List<&2, C.Task>:
  [data_226(), data_228(), data_125(), data_120(), data_121()]

def data_230(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_229(), data_116()}

def data_231() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_232() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_233() -> C.Task:
  C.Binary{1}

def data_234() -> List<&2, C.Task>:
  [data_231(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_234(), data_116()}

def data_236() -> C.Task:
  C.ReadNode{3n}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_237(), data_116()}

def data_239() -> C.Task:
  C.ReadPrepared{3n}

def data_240() -> List<&2, C.Task>:
  [data_239(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_241(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_240(), data_116()}

def data_242() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_243(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_242(), data_108()]

def data_244() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_245() -> List<&2, R.Link>:
  [data_28(), data_166(), data_244(), data_31(), data_32()]

def data_246(+input: Nat) -> R.World:
  R.World{data_243(input), data_245(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_224(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_247() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_248() -> C.Task:
  C.ReadStatus{3n}

def data_249() -> List<&2, C.Task>:
  [data_247(), data_248(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_250(+input: Nat) -> C.Machine:
  C.Machine{data_246(input), data_249(), data_116()}

def data_251() -> List<&2, C.Task>:
  [data_248(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_252(+input: Nat) -> C.Machine:
  C.Machine{data_246(input), data_251(), data_116()}

def data_253() -> C.Task:
  C.Serve{3n}

def data_254() -> C.Task:
  C.AfterServe{3n}

def data_255() -> List<&2, C.Task>:
  [data_253(), data_254(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_256(+input: Nat) -> C.Machine:
  C.Machine{data_246(input), data_255(), data_116()}

def data_257() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_258(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_257(), data_108()]

def data_259(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_178(input)}

def data_260(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45(), data_259(input)]

def data_261(+input: Nat) -> R.World:
  R.World{data_258(input), data_245(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_262() -> List<&2, C.Task>:
  [data_254(), data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_263(+input: Nat) -> C.Machine:
  C.Machine{data_261(input), data_262(), data_179(input)}

def data_264() -> List<&2, C.Task>:
  [data_232(), data_233(), data_228(), data_125(), data_120(), data_121()]

def data_265(+input: Nat) -> C.Machine:
  C.Machine{data_261(input), data_264(), data_179(input)}

def data_266() -> List<&2, C.Task>:
  [data_233(), data_228(), data_125(), data_120(), data_121()]

def data_267(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_178(input)]

def data_268(+input: Nat) -> C.Machine:
  C.Machine{data_261(input), data_266(), data_267(input)}

def data_269() -> List<&2, C.Task>:
  [data_228(), data_125(), data_120(), data_121()]

def data_270(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_271(+input: Nat) -> List<&2, R.Value>:
  [data_270(input)]

def data_272(+input: Nat) -> C.Machine:
  C.Machine{data_261(input), data_269(), data_271(input)}

def data_273() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_274(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_273(), data_108()]

def data_275(+input: Nat) -> R.World:
  R.World{data_274(input), data_245(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_276(+input: Nat) -> C.Task:
  C.PassReleases{data_227(), 0n, data_270(input), False{}, False{}, False{}, data_53()}

def data_277(+input: Nat) -> List<&2, C.Task>:
  [data_276(input), data_125(), data_120(), data_121()]

def data_278(+input: Nat) -> C.Machine:
  C.Machine{data_275(input), data_277(input), data_116()}

def data_279(+input: Nat) -> R.Slot:
  R.Present{data_270(input)}

def data_280() -> R.Stamp:
  R.Stamped{9n}

def data_281(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_279(input), False{}, 0, 16384, 0, 0n, data_280(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_282(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_281(input), data_108()]

def data_283(+input: Nat) -> R.World:
  R.World{data_282(input), data_245(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_284() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_285() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_286() -> List<&2, C.Task>:
  [data_284(), data_285(), data_125(), data_120(), data_121()]

def data_287(+input: Nat) -> C.Machine:
  C.Machine{data_283(input), data_286(), data_116()}

def data_288() -> List<&2, C.Task>:
  [data_285(), data_125(), data_120(), data_121()]

def data_289(+input: Nat) -> C.Machine:
  C.Machine{data_283(input), data_288(), data_116()}

def data_290() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_291() -> List<&2, C.Task>:
  [data_290(), data_125(), data_120(), data_121()]

def data_292(+input: Nat) -> C.Machine:
  C.Machine{data_283(input), data_291(), data_116()}

def data_293(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_279(input), False{}, 128, 16384, 0, 0n, data_280(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_294(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_108()]

def data_295() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_296(+input: Nat) -> R.World:
  R.World{data_294(input), data_245(), data_133(), 1n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_297(+input: Nat) -> C.Machine:
  C.Machine{data_296(input), data_126(), data_116()}

def data_298(+input: Nat) -> R.World:
  R.World{data_294(input), data_245(), data_133(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_299(+input: Nat) -> C.Machine:
  C.Machine{data_298(input), data_126(), data_116()}

def data_300() -> C.Task:
  C.Recompute{5n, False{}}

def data_301() -> List<&2, C.Task>:
  [data_300(), data_125(), data_120(), data_121()]

def data_302(+input: Nat) -> C.Machine:
  C.Machine{data_298(input), data_301(), data_116()}

def data_303() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_304(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_303()]

def data_305() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_306(+input: Nat) -> R.World:
  R.World{data_304(input), data_245(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_307() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_137()}

def data_308() -> List<&2, C.Task>:
  [data_307(), data_125(), data_120(), data_121()]

def data_309(+input: Nat) -> C.Machine:
  C.Machine{data_306(input), data_308(), data_116()}

def data_310() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_137()}

def data_311() -> List<&2, C.Task>:
  [data_310(), data_125(), data_120(), data_121()]

def data_312(+input: Nat) -> C.Machine:
  C.Machine{data_306(input), data_311(), data_116()}

def data_313() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_314(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_313()]

def data_315(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45(), data_259(input), data_48()]

def data_316(+input: Nat) -> R.World:
  R.World{data_314(input), data_245(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_315(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_317() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_318() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}, data_137()}

def data_319() -> C.Task:
  C.Finish{data_318()}

def data_320() -> List<&2, C.Task>:
  [data_317(), data_319(), data_125(), data_120(), data_121()]

def data_321(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_320(), data_116()}

def data_322() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_323() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_324() -> List<&2, C.Task>:
  [data_322(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_325(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_324(), data_116()}

def data_326() -> C.Task:
  C.ReadNode{4n}

def data_327() -> List<&2, C.Task>:
  [data_326(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_328(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_327(), data_116()}

def data_329() -> C.Task:
  C.ReadPrepared{4n}

def data_330() -> List<&2, C.Task>:
  [data_329(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_331(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_330(), data_116()}

def data_332() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_333(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_332()]

def data_334() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_335() -> List<&2, R.Link>:
  [data_28(), data_166(), data_244(), data_334(), data_32()]

def data_336(+input: Nat) -> R.World:
  R.World{data_333(input), data_335(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_315(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_337() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_338() -> C.Task:
  C.ReadStatus{4n}

def data_339() -> List<&2, C.Task>:
  [data_337(), data_338(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_340(+input: Nat) -> C.Machine:
  C.Machine{data_336(input), data_339(), data_116()}

def data_341() -> List<&2, C.Task>:
  [data_338(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_342(+input: Nat) -> C.Machine:
  C.Machine{data_336(input), data_341(), data_116()}

def data_343() -> C.Task:
  C.Serve{4n}

def data_344() -> C.Task:
  C.AfterServe{4n}

def data_345() -> List<&2, C.Task>:
  [data_343(), data_344(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_346(+input: Nat) -> C.Machine:
  C.Machine{data_336(input), data_345(), data_116()}

def data_347() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_348(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_347()]

def data_349(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_270(input)}

def data_350(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45(), data_259(input), data_48(), data_349(input)]

def data_351(+input: Nat) -> R.World:
  R.World{data_348(input), data_335(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_350(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_352() -> List<&2, C.Task>:
  [data_344(), data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_353(+input: Nat) -> C.Machine:
  C.Machine{data_351(input), data_352(), data_271(input)}

def data_354() -> List<&2, C.Task>:
  [data_323(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_355(+input: Nat) -> C.Machine:
  C.Machine{data_351(input), data_354(), data_271(input)}

def data_356() -> List<&2, C.Task>:
  [data_158(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_357(+input: Nat) -> C.Machine:
  C.Machine{data_351(input), data_356(), data_271(input)}

def data_358() -> List<&2, C.Task>:
  [data_161(), data_155(), data_319(), data_125(), data_120(), data_121()]

def data_359(+input: Nat) -> C.Machine:
  C.Machine{data_351(input), data_358(), data_271(input)}

def data_360() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_361(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_360()]

def data_362() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_363() -> List<&2, R.Link>:
  [data_28(), data_166(), data_244(), data_334(), data_362()]

def data_364(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_102(input)}

def data_365(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45(), data_259(input), data_48(), data_349(input), data_364(input)]

def data_366(+input: Nat) -> R.World:
  R.World{data_361(input), data_363(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_135(), data_100(), data_2(), data_35()}

def data_367() -> List<&2, C.Task>:
  [data_155(), data_319(), data_125(), data_120(), data_121()]

def data_368(+input: Nat) -> List<&2, R.Value>:
  [data_102(input), data_270(input)]

def data_369(+input: Nat) -> C.Machine:
  C.Machine{data_366(input), data_367(), data_368(input)}

def data_370() -> List<&2, C.Task>:
  [data_319(), data_125(), data_120(), data_121()]

def data_371(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_372(+input: Nat) -> List<&2, R.Value>:
  [data_371(input)]

def data_373(+input: Nat) -> C.Machine:
  C.Machine{data_366(input), data_370(), data_372(input)}

def data_374() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_375(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_374()]

def data_376(+input: Nat) -> R.World:
  R.World{data_375(input), data_363(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_377(+input: Nat) -> C.Task:
  C.PassReleases{data_318(), 0n, data_371(input), False{}, False{}, False{}, data_53()}

def data_378(+input: Nat) -> List<&2, C.Task>:
  [data_377(input), data_125(), data_120(), data_121()]

def data_379(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_378(input), data_116()}

def data_380(+input: Nat) -> R.Node:
  R.Node{data_23(), data_371(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_381(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_380(input)]

def data_382() -> List<&2, Nat>:
  [5n]

def data_383(+input: Nat) -> R.World:
  R.World{data_381(input), data_363(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_384() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_385() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_386() -> List<&2, C.Task>:
  [data_384(), data_385(), data_125(), data_120(), data_121()]

def data_387(+input: Nat) -> C.Machine:
  C.Machine{data_383(input), data_386(), data_116()}

def data_388() -> List<&2, C.Task>:
  [data_385(), data_125(), data_120(), data_121()]

def data_389(+input: Nat) -> C.Machine:
  C.Machine{data_383(input), data_388(), data_116()}

def data_390() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_391() -> List<&2, C.Task>:
  [data_390(), data_125(), data_120(), data_121()]

def data_392(+input: Nat) -> C.Machine:
  C.Machine{data_383(input), data_391(), data_116()}

def data_393(+input: Nat) -> C.Machine:
  C.Machine{data_383(input), data_126(), data_116()}

def data_394(+input: Nat) -> R.World:
  R.World{data_381(input), data_363(), data_305(), 3n, 2n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_395(+input: Nat) -> C.Machine:
  C.Machine{data_394(input), data_126(), data_116()}

def data_396(+input: Nat) -> R.World:
  R.World{data_381(input), data_363(), data_305(), 3n, 0n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_397() -> C.Task:
  C.Seam{}

def data_398() -> List<&2, C.Task>:
  [data_397(), data_120(), data_121()]

def data_399(+input: Nat) -> C.Machine:
  C.Machine{data_396(input), data_398(), data_116()}

def data_400() -> C.Task:
  C.Settle{}

def data_401() -> C.Task:
  C.AfterSettle{}

def data_402() -> List<&2, C.Task>:
  [data_400(), data_401(), data_120(), data_121()]

def data_403(+input: Nat) -> C.Machine:
  C.Machine{data_396(input), data_402(), data_116()}

def data_404() -> C.Task:
  C.CommitIntake{0n}

def data_405() -> C.Task:
  C.TrimIntake{0n}

def data_406() -> C.Task:
  C.FinishSettleIntake{0n}

def data_407() -> List<&2, C.Task>:
  [data_404(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_408(+input: Nat) -> C.Machine:
  C.Machine{data_396(input), data_407(), data_116()}

def data_409() -> C.Task:
  C.CommitPending{2n}

def data_410() -> C.Task:
  C.CommitIntake{1n}

def data_411() -> List<&2, C.Task>:
  [data_409(), data_410(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_412(+input: Nat) -> C.Machine:
  C.Machine{data_396(input), data_411(), data_116()}

def data_413(+input: Nat) -> R.Node:
  R.Node{data_9(), data_102(input), data_2(), False{}, 0, 0, 0, 0n, data_104(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_414(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_413(input), data_203(input), data_293(input), data_380(input)]

def data_415(+input: Nat) -> R.World:
  R.World{data_414(input), data_363(), data_305(), 3n, 0n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_416() -> List<&2, C.Task>:
  [data_410(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_417(+input: Nat) -> C.Machine:
  C.Machine{data_415(input), data_416(), data_116()}

def data_418() -> C.Task:
  C.CommitPending{3n}

def data_419() -> C.Task:
  C.CommitIntake{2n}

def data_420() -> List<&2, C.Task>:
  [data_418(), data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_421(+input: Nat) -> C.Machine:
  C.Machine{data_415(input), data_420(), data_116()}

def data_422(+input: Nat) -> R.Node:
  R.Node{data_12(), data_178(input), data_2(), False{}, 0, 16384, 0, 0n, data_188(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_423(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_413(input), data_422(input), data_293(input), data_380(input)]

def data_424(+input: Nat) -> R.World:
  R.World{data_423(input), data_363(), data_305(), 3n, 0n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_425() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_426() -> List<&2, C.Task>:
  [data_425(), data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_427(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_426(), data_116()}

def data_428() -> O.Task:
  O.TrimDeps{3n}

def data_429() -> List<&2, O.Task>:
  [data_428()]

def data_430() -> C.Task:
  C.OwnerTasks{data_429()}

def data_431() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_432() -> List<&2, C.Task>:
  [data_430(), data_431(), data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_433(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_432(), data_116()}

def data_434() -> List<&2, O.Task>:
  []

def data_435() -> C.Task:
  C.OwnerTasks{data_434()}

def data_436() -> List<&2, C.Task>:
  [data_435(), data_431(), data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_437(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_436(), data_116()}

def data_438() -> List<&2, C.Task>:
  [data_431(), data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_439(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_438(), data_116()}

def data_440() -> List<&2, C.Task>:
  [data_419(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_441(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_440(), data_116()}

def data_442() -> C.Task:
  C.CommitPending{4n}

def data_443() -> C.Task:
  C.CommitIntake{3n}

def data_444() -> List<&2, C.Task>:
  [data_442(), data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_445(+input: Nat) -> C.Machine:
  C.Machine{data_424(input), data_444(), data_116()}

def data_446(+input: Nat) -> R.Node:
  R.Node{data_12(), data_270(input), data_2(), False{}, 0, 16384, 0, 0n, data_280(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_447(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_413(input), data_422(input), data_446(input), data_380(input)]

def data_448(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_449() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_450() -> List<&2, C.Task>:
  [data_449(), data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_448(input), data_450(), data_116()}

def data_452() -> O.Task:
  O.TrimDeps{4n}

def data_453() -> List<&2, O.Task>:
  [data_452()]

def data_454() -> C.Task:
  C.OwnerTasks{data_453()}

def data_455() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_456() -> List<&2, C.Task>:
  [data_454(), data_455(), data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_457(+input: Nat) -> C.Machine:
  C.Machine{data_448(input), data_456(), data_116()}

def data_458() -> List<&2, C.Task>:
  [data_435(), data_455(), data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_459(+input: Nat) -> C.Machine:
  C.Machine{data_448(input), data_458(), data_116()}

def data_460() -> List<&2, C.Task>:
  [data_455(), data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_461(+input: Nat) -> C.Machine:
  C.Machine{data_448(input), data_460(), data_116()}

def data_462() -> List<&2, C.Task>:
  [data_443(), data_405(), data_406(), data_401(), data_120(), data_121()]

def data_463(+input: Nat) -> C.Machine:
  C.Machine{data_448(input), data_462(), data_116()}

def data_464(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_465() -> List<&2, C.Task>:
  [data_405(), data_406(), data_401(), data_120(), data_121()]

def data_466(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_465(), data_116()}

def data_467() -> List<&2, C.Task>:
  [data_406(), data_401(), data_120(), data_121()]

def data_468(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_467(), data_116()}

def data_469(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_470() -> C.SeamFrame:
  C.SeamFrame{0n, data_382(), data_36(), data_35(), data_36()}

def data_471() -> C.Task:
  C.LandTransactions{data_470(), 0n}

def data_472() -> List<&2, C.Task>:
  [data_471(), data_401(), data_120(), data_121()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_469(input), data_472(), data_116()}

def data_474() -> C.Task:
  C.CompleteSettle{data_470()}

def data_475() -> List<&2, C.Task>:
  [data_474(), data_401(), data_120(), data_121()]

def data_476(+input: Nat) -> C.Machine:
  C.Machine{data_469(input), data_475(), data_116()}

def data_477() -> C.Task:
  C.ZombieLoop{data_35()}

def data_478() -> List<&2, C.Task>:
  [data_477(), data_401(), data_120(), data_121()]

def data_479(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_478(), data_116()}

def data_480() -> List<&2, C.Task>:
  [data_401(), data_120(), data_121()]

def data_481(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_480(), data_116()}

def data_482(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_382(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_483() -> C.Task:
  C.RenderQueue{}

def data_484() -> List<&2, C.Task>:
  [data_483(), data_120(), data_121()]

def data_485(+input: Nat) -> C.Machine:
  C.Machine{data_482(input), data_484(), data_116()}

def data_486(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_487() -> C.Task:
  C.RunEffect{5n}

def data_488() -> C.Task:
  C.UserQueue{}

def data_489() -> List<&2, C.Task>:
  [data_487(), data_488(), data_120(), data_121()]

def data_490(+input: Nat) -> C.Machine:
  C.Machine{data_486(input), data_489(), data_116()}

def data_491() -> C.Task:
  C.ApplyEffect{5n}

def data_492() -> C.Task:
  C.EffectFinally{5n, True{}, data_116()}

def data_493() -> List<&2, C.Task>:
  [data_491(), data_492(), data_488(), data_120(), data_121()]

def data_494(+input: Nat) -> C.Machine:
  C.Machine{data_486(input), data_493(), data_116()}

def data_495(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_371(input)}

def data_496(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_495(input)]

def data_497(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_371(input), data_18()}

def data_498(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_168(input), data_45(), data_259(input), data_48(), data_349(input), data_364(input), data_497(input)]

def data_499(+input: Nat) -> R.World:
  R.World{data_447(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_496(input), data_498(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_500() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_501() -> List<&2, C.Task>:
  [data_500(), data_492(), data_488(), data_120(), data_121()]

def data_502(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_501(), data_116()}

def data_503() -> List<&2, C.Task>:
  [data_492(), data_488(), data_120(), data_121()]

def data_504(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_503(), data_116()}

def data_505(+input: Nat) -> R.Node:
  R.Node{data_23(), data_371(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_371(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_506(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_413(input), data_422(input), data_446(input), data_505(input)]

def data_507(+input: Nat) -> R.World:
  R.World{data_506(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_496(input), data_498(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_508() -> O.Task:
  O.TrimDeps{5n}

def data_509() -> List<&2, O.Task>:
  [data_508()]

def data_510() -> C.Task:
  C.OwnerTasks{data_509()}

def data_511() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_116()}

def data_512() -> List<&2, C.Task>:
  [data_510(), data_511(), data_488(), data_120(), data_121()]

def data_513(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_512(), data_116()}

def data_514() -> List<&2, C.Task>:
  [data_435(), data_511(), data_488(), data_120(), data_121()]

def data_515(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_514(), data_116()}

def data_516() -> List<&2, C.Task>:
  [data_511(), data_488(), data_120(), data_121()]

def data_517(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_516(), data_116()}

def data_518() -> List<&2, C.Task>:
  [data_488(), data_120(), data_121()]

def data_519(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_518(), data_116()}

def data_520() -> List<&2, C.Task>:
  [data_120(), data_121()]

def data_521(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_520(), data_116()}

def data_522(+input: Nat) -> R.World:
  R.World{data_506(input), data_363(), data_305(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_496(input), data_498(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_523() -> List<&2, C.Task>:
  [data_121()]

def data_524(+input: Nat) -> C.Machine:
  C.Machine{data_522(input), data_523(), data_116()}

def data_525() -> List<&2, C.Task>:
  []

def data_526(+input: Nat) -> C.Machine:
  C.Machine{data_522(input), data_525(), data_116()}

def data_527(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_187(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_528(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_527(input), data_107(), data_108()]

def data_529(+input: Nat) -> R.World:
  R.World{data_528(input), data_167(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_169(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_530(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_279(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_531(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_530(input), data_108()]

def data_532(+input: Nat) -> R.World:
  R.World{data_531(input), data_245(), data_133(), 1n, 2n, False{}, data_205(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_260(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_533() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_534(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_203(input), data_293(input), data_533()]

def data_535(+input: Nat) -> R.World:
  R.World{data_534(input), data_363(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_536(+input: Nat) -> R.World:
  R.World{data_534(input), data_363(), data_305(), 2n, 2n, False{}, data_295(), data_35(), data_382(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_365(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_537() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_538(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_103(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_539(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_538(input), data_17(), data_22(), data_26()]

def data_540(+input: Nat) -> R.World:
  R.World{data_539(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_541(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_542(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_17(), data_22(), data_26()]

def data_543(+input: Nat) -> R.World:
  R.World{data_542(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def data_544() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_545(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_106(), data_107(), data_544()]

def data_546() -> List<&2, Nat>:
  [3n]

def data_547(+input: Nat) -> R.World:
  R.World{data_545(input), data_33(), data_546(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35()}

def origin() -> R.World:
  data_101()

def state_0(+input: Nat) -> C.Machine:
  data_117(input)

def state_1(+input: Nat) -> C.Machine:
  data_123(input)

def state_2(+input: Nat) -> C.Machine:
  data_127(input)

def state_3(+input: Nat) -> C.Machine:
  data_130(input)

def state_4(+input: Nat) -> C.Machine:
  data_140(input)

def state_5(+input: Nat) -> C.Machine:
  data_143(input)

def state_6(+input: Nat) -> C.Machine:
  data_152(input)

def state_7(+input: Nat) -> C.Machine:
  data_157(input)

def state_8(+input: Nat) -> C.Machine:
  data_160(input)

def state_9(+input: Nat) -> C.Machine:
  data_163(input)

def state_10(+input: Nat) -> C.Machine:
  data_173(input)

def state_11(+input: Nat) -> C.Machine:
  data_176(input)

def state_12(+input: Nat) -> C.Machine:
  data_180(input)

def state_13(+input: Nat) -> C.Machine:
  data_186(input)

def state_14(+input: Nat) -> C.Machine:
  data_197(input)

def state_15(+input: Nat) -> C.Machine:
  data_199(input)

def state_16(+input: Nat) -> C.Machine:
  data_202(input)

def state_17(+input: Nat) -> C.Machine:
  data_207(input)

def state_18(+input: Nat) -> C.Machine:
  data_209(input)

def state_19(+input: Nat) -> C.Machine:
  data_212(input)

def state_20(+input: Nat) -> C.Machine:
  data_218(input)

def state_21(+input: Nat) -> C.Machine:
  data_221(input)

def state_22(+input: Nat) -> C.Machine:
  data_230(input)

def state_23(+input: Nat) -> C.Machine:
  data_235(input)

def state_24(+input: Nat) -> C.Machine:
  data_238(input)

def state_25(+input: Nat) -> C.Machine:
  data_241(input)

def state_26(+input: Nat) -> C.Machine:
  data_250(input)

def state_27(+input: Nat) -> C.Machine:
  data_252(input)

def state_28(+input: Nat) -> C.Machine:
  data_256(input)

def state_29(+input: Nat) -> C.Machine:
  data_263(input)

def state_30(+input: Nat) -> C.Machine:
  data_265(input)

def state_31(+input: Nat) -> C.Machine:
  data_268(input)

def state_32(+input: Nat) -> C.Machine:
  data_272(input)

def state_33(+input: Nat) -> C.Machine:
  data_278(input)

def state_34(+input: Nat) -> C.Machine:
  data_287(input)

def state_35(+input: Nat) -> C.Machine:
  data_289(input)

def state_36(+input: Nat) -> C.Machine:
  data_292(input)

def state_37(+input: Nat) -> C.Machine:
  data_297(input)

def state_38(+input: Nat) -> C.Machine:
  data_299(input)

def state_39(+input: Nat) -> C.Machine:
  data_302(input)

def state_40(+input: Nat) -> C.Machine:
  data_309(input)

def state_41(+input: Nat) -> C.Machine:
  data_312(input)

def state_42(+input: Nat) -> C.Machine:
  data_321(input)

def state_43(+input: Nat) -> C.Machine:
  data_325(input)

def state_44(+input: Nat) -> C.Machine:
  data_328(input)

def state_45(+input: Nat) -> C.Machine:
  data_331(input)

def state_46(+input: Nat) -> C.Machine:
  data_340(input)

def state_47(+input: Nat) -> C.Machine:
  data_342(input)

def state_48(+input: Nat) -> C.Machine:
  data_346(input)

def state_49(+input: Nat) -> C.Machine:
  data_353(input)

def state_50(+input: Nat) -> C.Machine:
  data_355(input)

def state_51(+input: Nat) -> C.Machine:
  data_357(input)

def state_52(+input: Nat) -> C.Machine:
  data_359(input)

def state_53(+input: Nat) -> C.Machine:
  data_369(input)

def state_54(+input: Nat) -> C.Machine:
  data_373(input)

def state_55(+input: Nat) -> C.Machine:
  data_379(input)

def state_56(+input: Nat) -> C.Machine:
  data_387(input)

def state_57(+input: Nat) -> C.Machine:
  data_389(input)

def state_58(+input: Nat) -> C.Machine:
  data_392(input)

def state_59(+input: Nat) -> C.Machine:
  data_393(input)

def state_60(+input: Nat) -> C.Machine:
  data_395(input)

def state_61(+input: Nat) -> C.Machine:
  data_399(input)

def state_62(+input: Nat) -> C.Machine:
  data_403(input)

def state_63(+input: Nat) -> C.Machine:
  data_408(input)

def state_64(+input: Nat) -> C.Machine:
  data_412(input)

def state_65(+input: Nat) -> C.Machine:
  data_417(input)

def state_66(+input: Nat) -> C.Machine:
  data_421(input)

def state_67(+input: Nat) -> C.Machine:
  data_427(input)

def state_68(+input: Nat) -> C.Machine:
  data_433(input)

def state_69(+input: Nat) -> C.Machine:
  data_437(input)

def state_70(+input: Nat) -> C.Machine:
  data_439(input)

def state_71(+input: Nat) -> C.Machine:
  data_441(input)

def state_72(+input: Nat) -> C.Machine:
  data_445(input)

def state_73(+input: Nat) -> C.Machine:
  data_451(input)

def state_74(+input: Nat) -> C.Machine:
  data_457(input)

def state_75(+input: Nat) -> C.Machine:
  data_459(input)

def state_76(+input: Nat) -> C.Machine:
  data_461(input)

def state_77(+input: Nat) -> C.Machine:
  data_463(input)

def state_78(+input: Nat) -> C.Machine:
  data_466(input)

def state_79(+input: Nat) -> C.Machine:
  data_468(input)

def state_80(+input: Nat) -> C.Machine:
  data_473(input)

def state_81(+input: Nat) -> C.Machine:
  data_476(input)

def state_82(+input: Nat) -> C.Machine:
  data_479(input)

def state_83(+input: Nat) -> C.Machine:
  data_481(input)

def state_84(+input: Nat) -> C.Machine:
  data_485(input)

def state_85(+input: Nat) -> C.Machine:
  data_490(input)

def state_86(+input: Nat) -> C.Machine:
  data_494(input)

def state_87(+input: Nat) -> C.Machine:
  data_502(input)

def state_88(+input: Nat) -> C.Machine:
  data_504(input)

def state_89(+input: Nat) -> C.Machine:
  data_513(input)

def state_90(+input: Nat) -> C.Machine:
  data_515(input)

def state_91(+input: Nat) -> C.Machine:
  data_517(input)

def state_92(+input: Nat) -> C.Machine:
  data_519(input)

def state_93(+input: Nat) -> C.Machine:
  data_521(input)

def state_94(+input: Nat) -> C.Machine:
  data_524(input)

def state_95(+input: Nat) -> C.Machine:
  data_526(input)

def finalWorld(+input: Nat) -> R.World:
  data_522(input)

def slot_13(+input: Nat) -> R.World:
  data_529(input)

def notify_13(+input: Nat) -> R.World:
  data_193(input)

def slot_33(+input: Nat) -> R.World:
  data_532(input)

def notify_33(+input: Nat) -> R.World:
  data_283(input)

def modified_55(+input: Nat) -> R.World:
  data_535(input)

def queued_55(+input: Nat) -> R.World:
  data_536(input)

def value_55(+input: Nat) -> R.World:
  data_383(input)

def setter_queued(+input: Nat) -> R.World:
  data_537()

def setter_slot(+input: Nat) -> R.World:
  data_540(input)

def setter_inserted(+input: Nat) -> R.World:
  data_541(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_113(input)

def setter_stamped(+input: Nat) -> R.World:
  data_543(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_547(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_541(input)

