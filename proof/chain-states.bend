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
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

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
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_114() -> C.Task:
  C.Round{}

def data_115() -> List<&2, C.Task>:
  [data_114()]

def data_116() -> List<&2, R.Value>:
  []

def data_117(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_115(), data_116()}

def data_118(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

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
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

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

def data_134(+input: Nat) -> R.World:
  R.World{data_132(input), data_33(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_135() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_136() -> List<&2, C.Task>:
  [data_135(), data_125(), data_120(), data_121()]

def data_137(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_136(), data_116()}

def data_138() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_139() -> List<&2, C.Task>:
  [data_138(), data_125(), data_120(), data_121()]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_139(), data_116()}

def data_141() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_142(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_141(), data_107(), data_108()]

def data_143() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_144(+input: Nat) -> R.World:
  R.World{data_142(input), data_33(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_143(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_145() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_146() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}}

def data_147() -> C.Task:
  C.Finish{data_146()}

def data_148() -> List<&2, C.Task>:
  [data_145(), data_147(), data_125(), data_120(), data_121()]

def data_149(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_148(), data_116()}

def data_150() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_151() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_152() -> C.Task:
  C.Binary{0}

def data_153() -> List<&2, C.Task>:
  [data_150(), data_151(), data_152(), data_147(), data_125(), data_120(), data_121()]

def data_154(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_153(), data_116()}

def data_155() -> C.Task:
  C.ReadNode{2n}

def data_156() -> List<&2, C.Task>:
  [data_155(), data_151(), data_152(), data_147(), data_125(), data_120(), data_121()]

def data_157(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_156(), data_116()}

def data_158() -> C.Task:
  C.ReadPrepared{2n}

def data_159() -> List<&2, C.Task>:
  [data_158(), data_151(), data_152(), data_147(), data_125(), data_120(), data_121()]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_159(), data_116()}

def data_161() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_162(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_161(), data_107(), data_108()]

def data_163() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_164() -> List<&2, R.Link>:
  [data_28(), data_163(), data_30(), data_31(), data_32()]

def data_165(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_102(input)}

def data_166(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input)]

def data_167(+input: Nat) -> R.World:
  R.World{data_162(input), data_164(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_168() -> List<&2, C.Task>:
  [data_151(), data_152(), data_147(), data_125(), data_120(), data_121()]

def data_169(+input: Nat) -> List<&2, R.Value>:
  [data_102(input)]

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_167(input), data_168(), data_169(input)}

def data_171() -> List<&2, C.Task>:
  [data_152(), data_147(), data_125(), data_120(), data_121()]

def data_172(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_102(input)]

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_167(input), data_171(), data_172(input)}

def data_174() -> List<&2, C.Task>:
  [data_147(), data_125(), data_120(), data_121()]

def data_175(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_176(+input: Nat) -> List<&2, R.Value>:
  [data_175(input)]

def data_177(+input: Nat) -> C.Machine:
  C.Machine{data_167(input), data_174(), data_176(input)}

def data_178() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_179(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_178(), data_107(), data_108()]

def data_180(+input: Nat) -> R.World:
  R.World{data_179(input), data_164(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_181(+input: Nat) -> C.Task:
  C.PassReleases{data_146(), 0n, data_175(input), False{}, False{}, False{}, data_53()}

def data_182(+input: Nat) -> List<&2, C.Task>:
  [data_181(input), data_125(), data_120(), data_121()]

def data_183(+input: Nat) -> C.Machine:
  C.Machine{data_180(input), data_182(input), data_116()}

def data_184(+input: Nat) -> R.Slot:
  R.Present{data_175(input)}

def data_185() -> R.Stamp:
  R.Stamped{8n}

def data_186(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_184(input), False{}, 0, 16384, 0, 0n, data_185(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_187() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_188(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_186(input), data_187(), data_108()]

def data_189() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_190(+input: Nat) -> R.World:
  R.World{data_188(input), data_164(), data_189(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_191() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_192() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_193() -> List<&2, C.Task>:
  [data_191(), data_192(), data_125(), data_120(), data_121()]

def data_194(+input: Nat) -> C.Machine:
  C.Machine{data_190(input), data_193(), data_116()}

def data_195() -> List<&2, C.Task>:
  [data_192(), data_125(), data_120(), data_121()]

def data_196(+input: Nat) -> C.Machine:
  C.Machine{data_190(input), data_195(), data_116()}

def data_197() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_198() -> List<&2, C.Task>:
  [data_197(), data_125(), data_120(), data_121()]

def data_199(+input: Nat) -> C.Machine:
  C.Machine{data_190(input), data_198(), data_116()}

def data_200(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_184(input), False{}, 128, 16384, 0, 0n, data_185(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_201(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_187(), data_108()]

def data_202() -> List<&2, Nat>:
  [2n, 3n]

def data_203(+input: Nat) -> R.World:
  R.World{data_201(input), data_164(), data_189(), 0n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_126(), data_116()}

def data_205(+input: Nat) -> R.World:
  R.World{data_201(input), data_164(), data_189(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_206(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_126(), data_116()}

def data_207() -> C.Task:
  C.Recompute{4n, False{}}

def data_208() -> List<&2, C.Task>:
  [data_207(), data_125(), data_120(), data_121()]

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_208(), data_116()}

def data_210() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_211(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_210(), data_108()]

def data_212(+input: Nat) -> R.World:
  R.World{data_211(input), data_164(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_213() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n}

def data_214() -> List<&2, C.Task>:
  [data_213(), data_125(), data_120(), data_121()]

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_212(input), data_214(), data_116()}

def data_216() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n}

def data_217() -> List<&2, C.Task>:
  [data_216(), data_125(), data_120(), data_121()]

def data_218(+input: Nat) -> C.Machine:
  C.Machine{data_212(input), data_217(), data_116()}

def data_219() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_220(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_219(), data_108()]

def data_221(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45()]

def data_222(+input: Nat) -> R.World:
  R.World{data_220(input), data_164(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_221(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_223() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_224() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}}

def data_225() -> C.Task:
  C.Finish{data_224()}

def data_226() -> List<&2, C.Task>:
  [data_223(), data_225(), data_125(), data_120(), data_121()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_222(input), data_226(), data_116()}

def data_228() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_229() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_230() -> C.Task:
  C.Binary{1}

def data_231() -> List<&2, C.Task>:
  [data_228(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_232(+input: Nat) -> C.Machine:
  C.Machine{data_222(input), data_231(), data_116()}

def data_233() -> C.Task:
  C.ReadNode{3n}

def data_234() -> List<&2, C.Task>:
  [data_233(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_222(input), data_234(), data_116()}

def data_236() -> C.Task:
  C.ReadPrepared{3n}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_222(input), data_237(), data_116()}

def data_239() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_240(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_239(), data_108()]

def data_241() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_242() -> List<&2, R.Link>:
  [data_28(), data_163(), data_241(), data_31(), data_32()]

def data_243(+input: Nat) -> R.World:
  R.World{data_240(input), data_242(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_221(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_244() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_245() -> C.Task:
  C.ReadStatus{3n}

def data_246() -> List<&2, C.Task>:
  [data_244(), data_245(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_243(input), data_246(), data_116()}

def data_248() -> List<&2, C.Task>:
  [data_245(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_243(input), data_248(), data_116()}

def data_250() -> C.Task:
  C.Serve{3n}

def data_251() -> C.Task:
  C.AfterServe{3n}

def data_252() -> List<&2, C.Task>:
  [data_250(), data_251(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_253(+input: Nat) -> C.Machine:
  C.Machine{data_243(input), data_252(), data_116()}

def data_254() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_255(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_254(), data_108()]

def data_256(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_175(input)}

def data_257(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45(), data_256(input)]

def data_258(+input: Nat) -> R.World:
  R.World{data_255(input), data_242(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_259() -> List<&2, C.Task>:
  [data_251(), data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_259(), data_176(input)}

def data_261() -> List<&2, C.Task>:
  [data_229(), data_230(), data_225(), data_125(), data_120(), data_121()]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_261(), data_176(input)}

def data_263() -> List<&2, C.Task>:
  [data_230(), data_225(), data_125(), data_120(), data_121()]

def data_264(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_175(input)]

def data_265(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_263(), data_264(input)}

def data_266() -> List<&2, C.Task>:
  [data_225(), data_125(), data_120(), data_121()]

def data_267(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_268(+input: Nat) -> List<&2, R.Value>:
  [data_267(input)]

def data_269(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_266(), data_268(input)}

def data_270() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_271(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_270(), data_108()]

def data_272(+input: Nat) -> R.World:
  R.World{data_271(input), data_242(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_273(+input: Nat) -> C.Task:
  C.PassReleases{data_224(), 0n, data_267(input), False{}, False{}, False{}, data_53()}

def data_274(+input: Nat) -> List<&2, C.Task>:
  [data_273(input), data_125(), data_120(), data_121()]

def data_275(+input: Nat) -> C.Machine:
  C.Machine{data_272(input), data_274(input), data_116()}

def data_276(+input: Nat) -> R.Slot:
  R.Present{data_267(input)}

def data_277() -> R.Stamp:
  R.Stamped{9n}

def data_278(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_276(input), False{}, 0, 16384, 0, 0n, data_277(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_279(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_278(input), data_108()]

def data_280(+input: Nat) -> R.World:
  R.World{data_279(input), data_242(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_281() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_282() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}}

def data_283() -> List<&2, C.Task>:
  [data_281(), data_282(), data_125(), data_120(), data_121()]

def data_284(+input: Nat) -> C.Machine:
  C.Machine{data_280(input), data_283(), data_116()}

def data_285() -> List<&2, C.Task>:
  [data_282(), data_125(), data_120(), data_121()]

def data_286(+input: Nat) -> C.Machine:
  C.Machine{data_280(input), data_285(), data_116()}

def data_287() -> C.Task:
  C.QueuePublication{4n, False{}, False{}}

def data_288() -> List<&2, C.Task>:
  [data_287(), data_125(), data_120(), data_121()]

def data_289(+input: Nat) -> C.Machine:
  C.Machine{data_280(input), data_288(), data_116()}

def data_290(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_276(input), False{}, 128, 16384, 0, 0n, data_277(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_291(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_108()]

def data_292() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_293(+input: Nat) -> R.World:
  R.World{data_291(input), data_242(), data_133(), 1n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_294(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_126(), data_116()}

def data_295(+input: Nat) -> R.World:
  R.World{data_291(input), data_242(), data_133(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_296(+input: Nat) -> C.Machine:
  C.Machine{data_295(input), data_126(), data_116()}

def data_297() -> C.Task:
  C.Recompute{5n, False{}}

def data_298() -> List<&2, C.Task>:
  [data_297(), data_125(), data_120(), data_121()]

def data_299(+input: Nat) -> C.Machine:
  C.Machine{data_295(input), data_298(), data_116()}

def data_300() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_301(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_300()]

def data_302() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_303(+input: Nat) -> R.World:
  R.World{data_301(input), data_242(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_304() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n}

def data_305() -> List<&2, C.Task>:
  [data_304(), data_125(), data_120(), data_121()]

def data_306(+input: Nat) -> C.Machine:
  C.Machine{data_303(input), data_305(), data_116()}

def data_307() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n}

def data_308() -> List<&2, C.Task>:
  [data_307(), data_125(), data_120(), data_121()]

def data_309(+input: Nat) -> C.Machine:
  C.Machine{data_303(input), data_308(), data_116()}

def data_310() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_311(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_310()]

def data_312(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45(), data_256(input), data_48()]

def data_313(+input: Nat) -> R.World:
  R.World{data_311(input), data_242(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_312(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_314() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_315() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_116(), 0n, False{}}

def data_316() -> C.Task:
  C.Finish{data_315()}

def data_317() -> List<&2, C.Task>:
  [data_314(), data_316(), data_125(), data_120(), data_121()]

def data_318(+input: Nat) -> C.Machine:
  C.Machine{data_313(input), data_317(), data_116()}

def data_319() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_320() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_321() -> List<&2, C.Task>:
  [data_319(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_322(+input: Nat) -> C.Machine:
  C.Machine{data_313(input), data_321(), data_116()}

def data_323() -> C.Task:
  C.ReadNode{4n}

def data_324() -> List<&2, C.Task>:
  [data_323(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_325(+input: Nat) -> C.Machine:
  C.Machine{data_313(input), data_324(), data_116()}

def data_326() -> C.Task:
  C.ReadPrepared{4n}

def data_327() -> List<&2, C.Task>:
  [data_326(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_328(+input: Nat) -> C.Machine:
  C.Machine{data_313(input), data_327(), data_116()}

def data_329() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_330(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_329()]

def data_331() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_332() -> List<&2, R.Link>:
  [data_28(), data_163(), data_241(), data_331(), data_32()]

def data_333(+input: Nat) -> R.World:
  R.World{data_330(input), data_332(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_312(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_334() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_335() -> C.Task:
  C.ReadStatus{4n}

def data_336() -> List<&2, C.Task>:
  [data_334(), data_335(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_337(+input: Nat) -> C.Machine:
  C.Machine{data_333(input), data_336(), data_116()}

def data_338() -> List<&2, C.Task>:
  [data_335(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_339(+input: Nat) -> C.Machine:
  C.Machine{data_333(input), data_338(), data_116()}

def data_340() -> C.Task:
  C.Serve{4n}

def data_341() -> C.Task:
  C.AfterServe{4n}

def data_342() -> List<&2, C.Task>:
  [data_340(), data_341(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_343(+input: Nat) -> C.Machine:
  C.Machine{data_333(input), data_342(), data_116()}

def data_344() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_345(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_344()]

def data_346(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_267(input)}

def data_347(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45(), data_256(input), data_48(), data_346(input)]

def data_348(+input: Nat) -> R.World:
  R.World{data_345(input), data_332(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_347(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_349() -> List<&2, C.Task>:
  [data_341(), data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_350(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_349(), data_268(input)}

def data_351() -> List<&2, C.Task>:
  [data_320(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_351(), data_268(input)}

def data_353() -> List<&2, C.Task>:
  [data_155(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_354(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_353(), data_268(input)}

def data_355() -> List<&2, C.Task>:
  [data_158(), data_152(), data_316(), data_125(), data_120(), data_121()]

def data_356(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_355(), data_268(input)}

def data_357() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_358(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_357()]

def data_359() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_360() -> List<&2, R.Link>:
  [data_28(), data_163(), data_241(), data_331(), data_359()]

def data_361(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_102(input)}

def data_362(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45(), data_256(input), data_48(), data_346(input), data_361(input)]

def data_363(+input: Nat) -> R.World:
  R.World{data_358(input), data_360(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_364() -> List<&2, C.Task>:
  [data_152(), data_316(), data_125(), data_120(), data_121()]

def data_365(+input: Nat) -> List<&2, R.Value>:
  [data_102(input), data_267(input)]

def data_366(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_364(), data_365(input)}

def data_367() -> List<&2, C.Task>:
  [data_316(), data_125(), data_120(), data_121()]

def data_368(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_369(+input: Nat) -> List<&2, R.Value>:
  [data_368(input)]

def data_370(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_367(), data_369(input)}

def data_371() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_372(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_371()]

def data_373(+input: Nat) -> R.World:
  R.World{data_372(input), data_360(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_374(+input: Nat) -> C.Task:
  C.PassReleases{data_315(), 0n, data_368(input), False{}, False{}, False{}, data_53()}

def data_375(+input: Nat) -> List<&2, C.Task>:
  [data_374(input), data_125(), data_120(), data_121()]

def data_376(+input: Nat) -> C.Machine:
  C.Machine{data_373(input), data_375(input), data_116()}

def data_377(+input: Nat) -> R.Node:
  R.Node{data_23(), data_368(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_378(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_377(input)]

def data_379() -> List<&2, Nat>:
  [5n]

def data_380(+input: Nat) -> R.World:
  R.World{data_378(input), data_360(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_381() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_382() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}}

def data_383() -> List<&2, C.Task>:
  [data_381(), data_382(), data_125(), data_120(), data_121()]

def data_384(+input: Nat) -> C.Machine:
  C.Machine{data_380(input), data_383(), data_116()}

def data_385() -> List<&2, C.Task>:
  [data_382(), data_125(), data_120(), data_121()]

def data_386(+input: Nat) -> C.Machine:
  C.Machine{data_380(input), data_385(), data_116()}

def data_387() -> C.Task:
  C.QueuePublication{5n, False{}, False{}}

def data_388() -> List<&2, C.Task>:
  [data_387(), data_125(), data_120(), data_121()]

def data_389(+input: Nat) -> C.Machine:
  C.Machine{data_380(input), data_388(), data_116()}

def data_390(+input: Nat) -> C.Machine:
  C.Machine{data_380(input), data_126(), data_116()}

def data_391(+input: Nat) -> R.World:
  R.World{data_378(input), data_360(), data_302(), 3n, 2n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_392(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_126(), data_116()}

def data_393(+input: Nat) -> R.World:
  R.World{data_378(input), data_360(), data_302(), 3n, 0n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_394() -> C.Task:
  C.Seam{}

def data_395() -> List<&2, C.Task>:
  [data_394(), data_120(), data_121()]

def data_396(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_395(), data_116()}

def data_397() -> C.Task:
  C.Settle{}

def data_398() -> C.Task:
  C.AfterSettle{}

def data_399() -> List<&2, C.Task>:
  [data_397(), data_398(), data_120(), data_121()]

def data_400(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_399(), data_116()}

def data_401() -> C.Task:
  C.CommitIntake{0n}

def data_402() -> C.Task:
  C.TrimIntake{0n}

def data_403() -> C.Task:
  C.FinishSettleIntake{0n}

def data_404() -> List<&2, C.Task>:
  [data_401(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_405(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_404(), data_116()}

def data_406() -> C.Task:
  C.CommitPending{2n}

def data_407() -> C.Task:
  C.CommitIntake{1n}

def data_408() -> List<&2, C.Task>:
  [data_406(), data_407(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_409(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_408(), data_116()}

def data_410(+input: Nat) -> R.Node:
  R.Node{data_9(), data_102(input), data_2(), False{}, 0, 0, 0, 0n, data_104(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_411(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_410(input), data_200(input), data_290(input), data_377(input)]

def data_412(+input: Nat) -> R.World:
  R.World{data_411(input), data_360(), data_302(), 3n, 0n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_413() -> List<&2, C.Task>:
  [data_407(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_414(+input: Nat) -> C.Machine:
  C.Machine{data_412(input), data_413(), data_116()}

def data_415() -> C.Task:
  C.CommitPending{3n}

def data_416() -> C.Task:
  C.CommitIntake{2n}

def data_417() -> List<&2, C.Task>:
  [data_415(), data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_418(+input: Nat) -> C.Machine:
  C.Machine{data_412(input), data_417(), data_116()}

def data_419(+input: Nat) -> R.Node:
  R.Node{data_12(), data_175(input), data_2(), False{}, 0, 16384, 0, 0n, data_185(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_420(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_410(input), data_419(input), data_290(input), data_377(input)]

def data_421(+input: Nat) -> R.World:
  R.World{data_420(input), data_360(), data_302(), 3n, 0n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_422() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_423() -> List<&2, C.Task>:
  [data_422(), data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_424(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_423(), data_116()}

def data_425() -> O.Task:
  O.TrimDeps{3n}

def data_426() -> List<&2, O.Task>:
  [data_425()]

def data_427() -> C.Task:
  C.OwnerTasks{data_426()}

def data_428() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_429() -> List<&2, C.Task>:
  [data_427(), data_428(), data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_430(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_429(), data_116()}

def data_431() -> List<&2, O.Task>:
  []

def data_432() -> C.Task:
  C.OwnerTasks{data_431()}

def data_433() -> List<&2, C.Task>:
  [data_432(), data_428(), data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_434(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_433(), data_116()}

def data_435() -> List<&2, C.Task>:
  [data_428(), data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_436(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_435(), data_116()}

def data_437() -> List<&2, C.Task>:
  [data_416(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_438(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_437(), data_116()}

def data_439() -> C.Task:
  C.CommitPending{4n}

def data_440() -> C.Task:
  C.CommitIntake{3n}

def data_441() -> List<&2, C.Task>:
  [data_439(), data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_442(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_441(), data_116()}

def data_443(+input: Nat) -> R.Node:
  R.Node{data_12(), data_267(input), data_2(), False{}, 0, 16384, 0, 0n, data_277(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_444(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_410(input), data_419(input), data_443(input), data_377(input)]

def data_445(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_446() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_447() -> List<&2, C.Task>:
  [data_446(), data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_448(+input: Nat) -> C.Machine:
  C.Machine{data_445(input), data_447(), data_116()}

def data_449() -> O.Task:
  O.TrimDeps{4n}

def data_450() -> List<&2, O.Task>:
  [data_449()]

def data_451() -> C.Task:
  C.OwnerTasks{data_450()}

def data_452() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_453() -> List<&2, C.Task>:
  [data_451(), data_452(), data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_454(+input: Nat) -> C.Machine:
  C.Machine{data_445(input), data_453(), data_116()}

def data_455() -> List<&2, C.Task>:
  [data_432(), data_452(), data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_456(+input: Nat) -> C.Machine:
  C.Machine{data_445(input), data_455(), data_116()}

def data_457() -> List<&2, C.Task>:
  [data_452(), data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_458(+input: Nat) -> C.Machine:
  C.Machine{data_445(input), data_457(), data_116()}

def data_459() -> List<&2, C.Task>:
  [data_440(), data_402(), data_403(), data_398(), data_120(), data_121()]

def data_460(+input: Nat) -> C.Machine:
  C.Machine{data_445(input), data_459(), data_116()}

def data_461(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_462() -> List<&2, C.Task>:
  [data_402(), data_403(), data_398(), data_120(), data_121()]

def data_463(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_462(), data_116()}

def data_464() -> List<&2, C.Task>:
  [data_403(), data_398(), data_120(), data_121()]

def data_465(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_464(), data_116()}

def data_466(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_467() -> C.SeamFrame:
  C.SeamFrame{0n, data_379(), data_36()}

def data_468() -> C.Task:
  C.LandTransactions{data_467(), 0n}

def data_469() -> List<&2, C.Task>:
  [data_468(), data_398(), data_120(), data_121()]

def data_470(+input: Nat) -> C.Machine:
  C.Machine{data_466(input), data_469(), data_116()}

def data_471() -> C.Task:
  C.CompleteSettle{data_467()}

def data_472() -> List<&2, C.Task>:
  [data_471(), data_398(), data_120(), data_121()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_466(input), data_472(), data_116()}

def data_474() -> C.Task:
  C.ZombieLoop{data_35()}

def data_475() -> List<&2, C.Task>:
  [data_474(), data_398(), data_120(), data_121()]

def data_476(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_475(), data_116()}

def data_477() -> List<&2, C.Task>:
  [data_398(), data_120(), data_121()]

def data_478(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_477(), data_116()}

def data_479(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_379(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_480() -> C.Task:
  C.RenderQueue{}

def data_481() -> List<&2, C.Task>:
  [data_480(), data_120(), data_121()]

def data_482(+input: Nat) -> C.Machine:
  C.Machine{data_479(input), data_481(), data_116()}

def data_483(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_484() -> C.Task:
  C.RunEffect{5n}

def data_485() -> C.Task:
  C.UserQueue{}

def data_486() -> List<&2, C.Task>:
  [data_484(), data_485(), data_120(), data_121()]

def data_487(+input: Nat) -> C.Machine:
  C.Machine{data_483(input), data_486(), data_116()}

def data_488() -> C.Task:
  C.ApplyEffect{5n}

def data_489() -> C.Task:
  C.EffectFinally{5n, True{}, data_116()}

def data_490() -> List<&2, C.Task>:
  [data_488(), data_489(), data_485(), data_120(), data_121()]

def data_491(+input: Nat) -> C.Machine:
  C.Machine{data_483(input), data_490(), data_116()}

def data_492(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_368(input)}

def data_493(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_492(input)]

def data_494(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_368(input), data_18()}

def data_495(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_165(input), data_45(), data_256(input), data_48(), data_346(input), data_361(input), data_494(input)]

def data_496(+input: Nat) -> R.World:
  R.World{data_444(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_493(input), data_495(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_497() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_498() -> List<&2, C.Task>:
  [data_497(), data_489(), data_485(), data_120(), data_121()]

def data_499(+input: Nat) -> C.Machine:
  C.Machine{data_496(input), data_498(), data_116()}

def data_500() -> List<&2, C.Task>:
  [data_489(), data_485(), data_120(), data_121()]

def data_501(+input: Nat) -> C.Machine:
  C.Machine{data_496(input), data_500(), data_116()}

def data_502(+input: Nat) -> R.Node:
  R.Node{data_23(), data_368(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_368(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_503(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_410(input), data_419(input), data_443(input), data_502(input)]

def data_504(+input: Nat) -> R.World:
  R.World{data_503(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_493(input), data_495(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_505() -> O.Task:
  O.TrimDeps{5n}

def data_506() -> List<&2, O.Task>:
  [data_505()]

def data_507() -> C.Task:
  C.OwnerTasks{data_506()}

def data_508() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_116()}

def data_509() -> List<&2, C.Task>:
  [data_507(), data_508(), data_485(), data_120(), data_121()]

def data_510(+input: Nat) -> C.Machine:
  C.Machine{data_504(input), data_509(), data_116()}

def data_511() -> List<&2, C.Task>:
  [data_432(), data_508(), data_485(), data_120(), data_121()]

def data_512(+input: Nat) -> C.Machine:
  C.Machine{data_504(input), data_511(), data_116()}

def data_513() -> List<&2, C.Task>:
  [data_508(), data_485(), data_120(), data_121()]

def data_514(+input: Nat) -> C.Machine:
  C.Machine{data_504(input), data_513(), data_116()}

def data_515() -> List<&2, C.Task>:
  [data_485(), data_120(), data_121()]

def data_516(+input: Nat) -> C.Machine:
  C.Machine{data_504(input), data_515(), data_116()}

def data_517() -> List<&2, C.Task>:
  [data_120(), data_121()]

def data_518(+input: Nat) -> C.Machine:
  C.Machine{data_504(input), data_517(), data_116()}

def data_519(+input: Nat) -> R.World:
  R.World{data_503(input), data_360(), data_302(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_493(input), data_495(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_520() -> List<&2, C.Task>:
  [data_121()]

def data_521(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_520(), data_116()}

def data_522() -> List<&2, C.Task>:
  []

def data_523(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_522(), data_116()}

def data_524(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_184(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_525(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_524(input), data_107(), data_108()]

def data_526(+input: Nat) -> R.World:
  R.World{data_525(input), data_164(), data_133(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_166(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_527(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_276(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_528(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_527(input), data_108()]

def data_529(+input: Nat) -> R.World:
  R.World{data_528(input), data_242(), data_133(), 1n, 2n, False{}, data_202(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_257(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_530() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_531(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_200(input), data_290(input), data_530()]

def data_532(+input: Nat) -> R.World:
  R.World{data_531(input), data_360(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_533(+input: Nat) -> R.World:
  R.World{data_531(input), data_360(), data_302(), 2n, 2n, False{}, data_292(), data_35(), data_379(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_112(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_534() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_535(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_103(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_536(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_535(input), data_17(), data_22(), data_26()]

def data_537(+input: Nat) -> R.World:
  R.World{data_536(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_538(+input: Nat) -> R.World:
  R.World{data_109(input), data_33(), data_110(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_539(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_17(), data_22(), data_26()]

def data_540(+input: Nat) -> R.World:
  R.World{data_539(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

def data_541() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_542(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_105(input), data_106(), data_107(), data_541()]

def data_543() -> List<&2, Nat>:
  [3n]

def data_544(+input: Nat) -> R.World:
  R.World{data_542(input), data_33(), data_543(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2()}

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
  data_137(input)

def state_5(+input: Nat) -> C.Machine:
  data_140(input)

def state_6(+input: Nat) -> C.Machine:
  data_149(input)

def state_7(+input: Nat) -> C.Machine:
  data_154(input)

def state_8(+input: Nat) -> C.Machine:
  data_157(input)

def state_9(+input: Nat) -> C.Machine:
  data_160(input)

def state_10(+input: Nat) -> C.Machine:
  data_170(input)

def state_11(+input: Nat) -> C.Machine:
  data_173(input)

def state_12(+input: Nat) -> C.Machine:
  data_177(input)

def state_13(+input: Nat) -> C.Machine:
  data_183(input)

def state_14(+input: Nat) -> C.Machine:
  data_194(input)

def state_15(+input: Nat) -> C.Machine:
  data_196(input)

def state_16(+input: Nat) -> C.Machine:
  data_199(input)

def state_17(+input: Nat) -> C.Machine:
  data_204(input)

def state_18(+input: Nat) -> C.Machine:
  data_206(input)

def state_19(+input: Nat) -> C.Machine:
  data_209(input)

def state_20(+input: Nat) -> C.Machine:
  data_215(input)

def state_21(+input: Nat) -> C.Machine:
  data_218(input)

def state_22(+input: Nat) -> C.Machine:
  data_227(input)

def state_23(+input: Nat) -> C.Machine:
  data_232(input)

def state_24(+input: Nat) -> C.Machine:
  data_235(input)

def state_25(+input: Nat) -> C.Machine:
  data_238(input)

def state_26(+input: Nat) -> C.Machine:
  data_247(input)

def state_27(+input: Nat) -> C.Machine:
  data_249(input)

def state_28(+input: Nat) -> C.Machine:
  data_253(input)

def state_29(+input: Nat) -> C.Machine:
  data_260(input)

def state_30(+input: Nat) -> C.Machine:
  data_262(input)

def state_31(+input: Nat) -> C.Machine:
  data_265(input)

def state_32(+input: Nat) -> C.Machine:
  data_269(input)

def state_33(+input: Nat) -> C.Machine:
  data_275(input)

def state_34(+input: Nat) -> C.Machine:
  data_284(input)

def state_35(+input: Nat) -> C.Machine:
  data_286(input)

def state_36(+input: Nat) -> C.Machine:
  data_289(input)

def state_37(+input: Nat) -> C.Machine:
  data_294(input)

def state_38(+input: Nat) -> C.Machine:
  data_296(input)

def state_39(+input: Nat) -> C.Machine:
  data_299(input)

def state_40(+input: Nat) -> C.Machine:
  data_306(input)

def state_41(+input: Nat) -> C.Machine:
  data_309(input)

def state_42(+input: Nat) -> C.Machine:
  data_318(input)

def state_43(+input: Nat) -> C.Machine:
  data_322(input)

def state_44(+input: Nat) -> C.Machine:
  data_325(input)

def state_45(+input: Nat) -> C.Machine:
  data_328(input)

def state_46(+input: Nat) -> C.Machine:
  data_337(input)

def state_47(+input: Nat) -> C.Machine:
  data_339(input)

def state_48(+input: Nat) -> C.Machine:
  data_343(input)

def state_49(+input: Nat) -> C.Machine:
  data_350(input)

def state_50(+input: Nat) -> C.Machine:
  data_352(input)

def state_51(+input: Nat) -> C.Machine:
  data_354(input)

def state_52(+input: Nat) -> C.Machine:
  data_356(input)

def state_53(+input: Nat) -> C.Machine:
  data_366(input)

def state_54(+input: Nat) -> C.Machine:
  data_370(input)

def state_55(+input: Nat) -> C.Machine:
  data_376(input)

def state_56(+input: Nat) -> C.Machine:
  data_384(input)

def state_57(+input: Nat) -> C.Machine:
  data_386(input)

def state_58(+input: Nat) -> C.Machine:
  data_389(input)

def state_59(+input: Nat) -> C.Machine:
  data_390(input)

def state_60(+input: Nat) -> C.Machine:
  data_392(input)

def state_61(+input: Nat) -> C.Machine:
  data_396(input)

def state_62(+input: Nat) -> C.Machine:
  data_400(input)

def state_63(+input: Nat) -> C.Machine:
  data_405(input)

def state_64(+input: Nat) -> C.Machine:
  data_409(input)

def state_65(+input: Nat) -> C.Machine:
  data_414(input)

def state_66(+input: Nat) -> C.Machine:
  data_418(input)

def state_67(+input: Nat) -> C.Machine:
  data_424(input)

def state_68(+input: Nat) -> C.Machine:
  data_430(input)

def state_69(+input: Nat) -> C.Machine:
  data_434(input)

def state_70(+input: Nat) -> C.Machine:
  data_436(input)

def state_71(+input: Nat) -> C.Machine:
  data_438(input)

def state_72(+input: Nat) -> C.Machine:
  data_442(input)

def state_73(+input: Nat) -> C.Machine:
  data_448(input)

def state_74(+input: Nat) -> C.Machine:
  data_454(input)

def state_75(+input: Nat) -> C.Machine:
  data_456(input)

def state_76(+input: Nat) -> C.Machine:
  data_458(input)

def state_77(+input: Nat) -> C.Machine:
  data_460(input)

def state_78(+input: Nat) -> C.Machine:
  data_463(input)

def state_79(+input: Nat) -> C.Machine:
  data_465(input)

def state_80(+input: Nat) -> C.Machine:
  data_470(input)

def state_81(+input: Nat) -> C.Machine:
  data_473(input)

def state_82(+input: Nat) -> C.Machine:
  data_476(input)

def state_83(+input: Nat) -> C.Machine:
  data_478(input)

def state_84(+input: Nat) -> C.Machine:
  data_482(input)

def state_85(+input: Nat) -> C.Machine:
  data_487(input)

def state_86(+input: Nat) -> C.Machine:
  data_491(input)

def state_87(+input: Nat) -> C.Machine:
  data_499(input)

def state_88(+input: Nat) -> C.Machine:
  data_501(input)

def state_89(+input: Nat) -> C.Machine:
  data_510(input)

def state_90(+input: Nat) -> C.Machine:
  data_512(input)

def state_91(+input: Nat) -> C.Machine:
  data_514(input)

def state_92(+input: Nat) -> C.Machine:
  data_516(input)

def state_93(+input: Nat) -> C.Machine:
  data_518(input)

def state_94(+input: Nat) -> C.Machine:
  data_521(input)

def state_95(+input: Nat) -> C.Machine:
  data_523(input)

def finalWorld(+input: Nat) -> R.World:
  data_519(input)

def slot_13(+input: Nat) -> R.World:
  data_526(input)

def notify_13(+input: Nat) -> R.World:
  data_190(input)

def slot_33(+input: Nat) -> R.World:
  data_529(input)

def notify_33(+input: Nat) -> R.World:
  data_280(input)

def modified_55(+input: Nat) -> R.World:
  data_532(input)

def queued_55(+input: Nat) -> R.World:
  data_533(input)

def value_55(+input: Nat) -> R.World:
  data_380(input)

def setter_queued(+input: Nat) -> R.World:
  data_534()

def setter_slot(+input: Nat) -> R.World:
  data_537(input)

def setter_inserted(+input: Nat) -> R.World:
  data_538(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_113(input)

def setter_stamped(+input: Nat) -> R.World:
  data_540(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_544(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_538(input)

