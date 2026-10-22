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

def data_97() -> R.LaneState:
  R.LaneState{data_35(), data_65(), data_35()}

def data_98() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_99() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_100(+input: Nat) -> R.Value:
  R.Number{input}

def data_101(+input: Nat) -> R.Slot:
  R.Present{data_100(input)}

def data_102() -> R.Stamp:
  R.Stamped{7n}

def data_103(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_101(input), False{}, 0, 0, 0, 0n, data_102(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_104() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_105() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_106() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_107(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_104(), data_105(), data_106()]

def data_108() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_109() -> R.HostJob:
  R.FlushJob{}

def data_110() -> List<&2, R.HostJob>:
  [data_109()]

def data_111(+input: Nat) -> R.World:
  R.World{data_107(input), data_33(), data_108(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_112() -> C.Task:
  C.Round{}

def data_113() -> List<&2, C.Task>:
  [data_112()]

def data_114() -> List<&2, R.Value>:
  []

def data_115(+input: Nat) -> C.Machine:
  C.Machine{data_111(input), data_113(), data_114()}

def data_116(+input: Nat) -> R.World:
  R.World{data_107(input), data_33(), data_108(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_117() -> C.Task:
  C.RoundAfterSweep{}

def data_118() -> C.Task:
  C.FlushFinally{}

def data_119() -> C.Task:
  C.RoundEnd{}

def data_120() -> List<&2, C.Task>:
  [data_117(), data_118(), data_119()]

def data_121(+input: Nat) -> C.Machine:
  C.Machine{data_116(input), data_120(), data_114()}

def data_122(+input: Nat) -> R.World:
  R.World{data_107(input), data_33(), data_108(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_123() -> C.Task:
  C.HeapLoop{}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_118(), data_119()]

def data_125(+input: Nat) -> C.Machine:
  C.Machine{data_122(input), data_124(), data_114()}

def data_126() -> C.Task:
  C.Recompute{3n, False{}}

def data_127() -> List<&2, C.Task>:
  [data_126(), data_123(), data_118(), data_119()]

def data_128(+input: Nat) -> C.Machine:
  C.Machine{data_122(input), data_127(), data_114()}

def data_129() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_130(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_129(), data_105(), data_106()]

def data_131() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_132(+input: Nat) -> R.World:
  R.World{data_130(input), data_33(), data_131(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_133() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_134() -> List<&2, C.Task>:
  [data_133(), data_123(), data_118(), data_119()]

def data_135(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_134(), data_114()}

def data_136() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_137() -> List<&2, C.Task>:
  [data_136(), data_123(), data_118(), data_119()]

def data_138(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_137(), data_114()}

def data_139() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_140(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_139(), data_105(), data_106()]

def data_141() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_142(+input: Nat) -> R.World:
  R.World{data_140(input), data_33(), data_131(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_141(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_143() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_144() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_114(), 0n, False{}}

def data_145() -> C.Task:
  C.Finish{data_144()}

def data_146() -> List<&2, C.Task>:
  [data_143(), data_145(), data_123(), data_118(), data_119()]

def data_147(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_146(), data_114()}

def data_148() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_149() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_150() -> C.Task:
  C.Binary{0}

def data_151() -> List<&2, C.Task>:
  [data_148(), data_149(), data_150(), data_145(), data_123(), data_118(), data_119()]

def data_152(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_151(), data_114()}

def data_153() -> C.Task:
  C.ReadNode{2n}

def data_154() -> List<&2, C.Task>:
  [data_153(), data_149(), data_150(), data_145(), data_123(), data_118(), data_119()]

def data_155(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_154(), data_114()}

def data_156() -> C.Task:
  C.ReadPrepared{2n}

def data_157() -> List<&2, C.Task>:
  [data_156(), data_149(), data_150(), data_145(), data_123(), data_118(), data_119()]

def data_158(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_157(), data_114()}

def data_159() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_160(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_159(), data_105(), data_106()]

def data_161() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_162() -> List<&2, R.Link>:
  [data_28(), data_161(), data_30(), data_31(), data_32()]

def data_163(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_100(input)}

def data_164(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input)]

def data_165(+input: Nat) -> R.World:
  R.World{data_160(input), data_162(), data_131(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_166() -> List<&2, C.Task>:
  [data_149(), data_150(), data_145(), data_123(), data_118(), data_119()]

def data_167(+input: Nat) -> List<&2, R.Value>:
  [data_100(input)]

def data_168(+input: Nat) -> C.Machine:
  C.Machine{data_165(input), data_166(), data_167(input)}

def data_169() -> List<&2, C.Task>:
  [data_150(), data_145(), data_123(), data_118(), data_119()]

def data_170(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_100(input)]

def data_171(+input: Nat) -> C.Machine:
  C.Machine{data_165(input), data_169(), data_170(input)}

def data_172() -> List<&2, C.Task>:
  [data_145(), data_123(), data_118(), data_119()]

def data_173(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_174(+input: Nat) -> List<&2, R.Value>:
  [data_173(input)]

def data_175(+input: Nat) -> C.Machine:
  C.Machine{data_165(input), data_172(), data_174(input)}

def data_176() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_177(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_176(), data_105(), data_106()]

def data_178(+input: Nat) -> R.World:
  R.World{data_177(input), data_162(), data_131(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_179(+input: Nat) -> C.Task:
  C.PassReleases{data_144(), 0n, data_173(input), False{}, False{}, False{}, data_53()}

def data_180(+input: Nat) -> List<&2, C.Task>:
  [data_179(input), data_123(), data_118(), data_119()]

def data_181(+input: Nat) -> C.Machine:
  C.Machine{data_178(input), data_180(input), data_114()}

def data_182(+input: Nat) -> R.Slot:
  R.Present{data_173(input)}

def data_183() -> R.Stamp:
  R.Stamped{8n}

def data_184(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_182(input), False{}, 0, 16384, 0, 0n, data_183(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_185() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_186(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_184(input), data_185(), data_106()]

def data_187() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_188(+input: Nat) -> R.World:
  R.World{data_186(input), data_162(), data_187(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_189() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_190() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_191() -> List<&2, C.Task>:
  [data_189(), data_190(), data_123(), data_118(), data_119()]

def data_192(+input: Nat) -> C.Machine:
  C.Machine{data_188(input), data_191(), data_114()}

def data_193() -> List<&2, C.Task>:
  [data_190(), data_123(), data_118(), data_119()]

def data_194(+input: Nat) -> C.Machine:
  C.Machine{data_188(input), data_193(), data_114()}

def data_195() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_196() -> List<&2, C.Task>:
  [data_195(), data_123(), data_118(), data_119()]

def data_197(+input: Nat) -> C.Machine:
  C.Machine{data_188(input), data_196(), data_114()}

def data_198(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_182(input), False{}, 128, 16384, 0, 0n, data_183(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_199(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_185(), data_106()]

def data_200() -> List<&2, Nat>:
  [2n, 3n]

def data_201(+input: Nat) -> R.World:
  R.World{data_199(input), data_162(), data_187(), 0n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_202(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_124(), data_114()}

def data_203(+input: Nat) -> R.World:
  R.World{data_199(input), data_162(), data_187(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_124(), data_114()}

def data_205() -> C.Task:
  C.Recompute{4n, False{}}

def data_206() -> List<&2, C.Task>:
  [data_205(), data_123(), data_118(), data_119()]

def data_207(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_206(), data_114()}

def data_208() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_209(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_208(), data_106()]

def data_210(+input: Nat) -> R.World:
  R.World{data_209(input), data_162(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_211() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n}

def data_212() -> List<&2, C.Task>:
  [data_211(), data_123(), data_118(), data_119()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_210(input), data_212(), data_114()}

def data_214() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n}

def data_215() -> List<&2, C.Task>:
  [data_214(), data_123(), data_118(), data_119()]

def data_216(+input: Nat) -> C.Machine:
  C.Machine{data_210(input), data_215(), data_114()}

def data_217() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_218(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_217(), data_106()]

def data_219(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45()]

def data_220(+input: Nat) -> R.World:
  R.World{data_218(input), data_162(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_219(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_221() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_222() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_114(), 0n, False{}}

def data_223() -> C.Task:
  C.Finish{data_222()}

def data_224() -> List<&2, C.Task>:
  [data_221(), data_223(), data_123(), data_118(), data_119()]

def data_225(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_224(), data_114()}

def data_226() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_227() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_228() -> C.Task:
  C.Binary{1}

def data_229() -> List<&2, C.Task>:
  [data_226(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_230(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_229(), data_114()}

def data_231() -> C.Task:
  C.ReadNode{3n}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_232(), data_114()}

def data_234() -> C.Task:
  C.ReadPrepared{3n}

def data_235() -> List<&2, C.Task>:
  [data_234(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_236(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_235(), data_114()}

def data_237() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_238(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_237(), data_106()]

def data_239() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_240() -> List<&2, R.Link>:
  [data_28(), data_161(), data_239(), data_31(), data_32()]

def data_241(+input: Nat) -> R.World:
  R.World{data_238(input), data_240(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_219(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_242() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_243() -> C.Task:
  C.ReadStatus{3n}

def data_244() -> List<&2, C.Task>:
  [data_242(), data_243(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_245(+input: Nat) -> C.Machine:
  C.Machine{data_241(input), data_244(), data_114()}

def data_246() -> List<&2, C.Task>:
  [data_243(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_241(input), data_246(), data_114()}

def data_248() -> C.Task:
  C.Serve{3n}

def data_249() -> C.Task:
  C.AfterServe{3n}

def data_250() -> List<&2, C.Task>:
  [data_248(), data_249(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_251(+input: Nat) -> C.Machine:
  C.Machine{data_241(input), data_250(), data_114()}

def data_252() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_253(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_252(), data_106()]

def data_254(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_173(input)}

def data_255(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45(), data_254(input)]

def data_256(+input: Nat) -> R.World:
  R.World{data_253(input), data_240(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_257() -> List<&2, C.Task>:
  [data_249(), data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_258(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_257(), data_174(input)}

def data_259() -> List<&2, C.Task>:
  [data_227(), data_228(), data_223(), data_123(), data_118(), data_119()]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_259(), data_174(input)}

def data_261() -> List<&2, C.Task>:
  [data_228(), data_223(), data_123(), data_118(), data_119()]

def data_262(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_173(input)]

def data_263(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_261(), data_262(input)}

def data_264() -> List<&2, C.Task>:
  [data_223(), data_123(), data_118(), data_119()]

def data_265(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_266(+input: Nat) -> List<&2, R.Value>:
  [data_265(input)]

def data_267(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_264(), data_266(input)}

def data_268() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_269(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_268(), data_106()]

def data_270(+input: Nat) -> R.World:
  R.World{data_269(input), data_240(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_271(+input: Nat) -> C.Task:
  C.PassReleases{data_222(), 0n, data_265(input), False{}, False{}, False{}, data_53()}

def data_272(+input: Nat) -> List<&2, C.Task>:
  [data_271(input), data_123(), data_118(), data_119()]

def data_273(+input: Nat) -> C.Machine:
  C.Machine{data_270(input), data_272(input), data_114()}

def data_274(+input: Nat) -> R.Slot:
  R.Present{data_265(input)}

def data_275() -> R.Stamp:
  R.Stamped{9n}

def data_276(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_274(input), False{}, 0, 16384, 0, 0n, data_275(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_277(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_276(input), data_106()]

def data_278(+input: Nat) -> R.World:
  R.World{data_277(input), data_240(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_279() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_280() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}}

def data_281() -> List<&2, C.Task>:
  [data_279(), data_280(), data_123(), data_118(), data_119()]

def data_282(+input: Nat) -> C.Machine:
  C.Machine{data_278(input), data_281(), data_114()}

def data_283() -> List<&2, C.Task>:
  [data_280(), data_123(), data_118(), data_119()]

def data_284(+input: Nat) -> C.Machine:
  C.Machine{data_278(input), data_283(), data_114()}

def data_285() -> C.Task:
  C.QueuePublication{4n, False{}, False{}}

def data_286() -> List<&2, C.Task>:
  [data_285(), data_123(), data_118(), data_119()]

def data_287(+input: Nat) -> C.Machine:
  C.Machine{data_278(input), data_286(), data_114()}

def data_288(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_274(input), False{}, 128, 16384, 0, 0n, data_275(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_289(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_106()]

def data_290() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_291(+input: Nat) -> R.World:
  R.World{data_289(input), data_240(), data_131(), 1n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_292(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_124(), data_114()}

def data_293(+input: Nat) -> R.World:
  R.World{data_289(input), data_240(), data_131(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_294(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_124(), data_114()}

def data_295() -> C.Task:
  C.Recompute{5n, False{}}

def data_296() -> List<&2, C.Task>:
  [data_295(), data_123(), data_118(), data_119()]

def data_297(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_296(), data_114()}

def data_298() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_299(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_298()]

def data_300() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_301(+input: Nat) -> R.World:
  R.World{data_299(input), data_240(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_302() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n}

def data_303() -> List<&2, C.Task>:
  [data_302(), data_123(), data_118(), data_119()]

def data_304(+input: Nat) -> C.Machine:
  C.Machine{data_301(input), data_303(), data_114()}

def data_305() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n}

def data_306() -> List<&2, C.Task>:
  [data_305(), data_123(), data_118(), data_119()]

def data_307(+input: Nat) -> C.Machine:
  C.Machine{data_301(input), data_306(), data_114()}

def data_308() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_309(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_308()]

def data_310(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45(), data_254(input), data_48()]

def data_311(+input: Nat) -> R.World:
  R.World{data_309(input), data_240(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_310(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_312() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_313() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_114(), 0n, False{}}

def data_314() -> C.Task:
  C.Finish{data_313()}

def data_315() -> List<&2, C.Task>:
  [data_312(), data_314(), data_123(), data_118(), data_119()]

def data_316(+input: Nat) -> C.Machine:
  C.Machine{data_311(input), data_315(), data_114()}

def data_317() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_318() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_319() -> List<&2, C.Task>:
  [data_317(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_320(+input: Nat) -> C.Machine:
  C.Machine{data_311(input), data_319(), data_114()}

def data_321() -> C.Task:
  C.ReadNode{4n}

def data_322() -> List<&2, C.Task>:
  [data_321(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_323(+input: Nat) -> C.Machine:
  C.Machine{data_311(input), data_322(), data_114()}

def data_324() -> C.Task:
  C.ReadPrepared{4n}

def data_325() -> List<&2, C.Task>:
  [data_324(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_326(+input: Nat) -> C.Machine:
  C.Machine{data_311(input), data_325(), data_114()}

def data_327() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_328(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_327()]

def data_329() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_330() -> List<&2, R.Link>:
  [data_28(), data_161(), data_239(), data_329(), data_32()]

def data_331(+input: Nat) -> R.World:
  R.World{data_328(input), data_330(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_310(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_332() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_333() -> C.Task:
  C.ReadStatus{4n}

def data_334() -> List<&2, C.Task>:
  [data_332(), data_333(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_335(+input: Nat) -> C.Machine:
  C.Machine{data_331(input), data_334(), data_114()}

def data_336() -> List<&2, C.Task>:
  [data_333(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_337(+input: Nat) -> C.Machine:
  C.Machine{data_331(input), data_336(), data_114()}

def data_338() -> C.Task:
  C.Serve{4n}

def data_339() -> C.Task:
  C.AfterServe{4n}

def data_340() -> List<&2, C.Task>:
  [data_338(), data_339(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_341(+input: Nat) -> C.Machine:
  C.Machine{data_331(input), data_340(), data_114()}

def data_342() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_343(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_342()]

def data_344(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_265(input)}

def data_345(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45(), data_254(input), data_48(), data_344(input)]

def data_346(+input: Nat) -> R.World:
  R.World{data_343(input), data_330(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_345(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_347() -> List<&2, C.Task>:
  [data_339(), data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_348(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_347(), data_266(input)}

def data_349() -> List<&2, C.Task>:
  [data_318(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_350(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_349(), data_266(input)}

def data_351() -> List<&2, C.Task>:
  [data_153(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_351(), data_266(input)}

def data_353() -> List<&2, C.Task>:
  [data_156(), data_150(), data_314(), data_123(), data_118(), data_119()]

def data_354(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_353(), data_266(input)}

def data_355() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_356(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_355()]

def data_357() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_358() -> List<&2, R.Link>:
  [data_28(), data_161(), data_239(), data_329(), data_357()]

def data_359(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_100(input)}

def data_360(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45(), data_254(input), data_48(), data_344(input), data_359(input)]

def data_361(+input: Nat) -> R.World:
  R.World{data_356(input), data_358(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_362() -> List<&2, C.Task>:
  [data_150(), data_314(), data_123(), data_118(), data_119()]

def data_363(+input: Nat) -> List<&2, R.Value>:
  [data_100(input), data_265(input)]

def data_364(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_362(), data_363(input)}

def data_365() -> List<&2, C.Task>:
  [data_314(), data_123(), data_118(), data_119()]

def data_366(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_367(+input: Nat) -> List<&2, R.Value>:
  [data_366(input)]

def data_368(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_365(), data_367(input)}

def data_369() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_370(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_369()]

def data_371(+input: Nat) -> R.World:
  R.World{data_370(input), data_358(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_372(+input: Nat) -> C.Task:
  C.PassReleases{data_313(), 0n, data_366(input), False{}, False{}, False{}, data_53()}

def data_373(+input: Nat) -> List<&2, C.Task>:
  [data_372(input), data_123(), data_118(), data_119()]

def data_374(+input: Nat) -> C.Machine:
  C.Machine{data_371(input), data_373(input), data_114()}

def data_375(+input: Nat) -> R.Node:
  R.Node{data_23(), data_366(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_376(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_375(input)]

def data_377() -> List<&2, Nat>:
  [5n]

def data_378(+input: Nat) -> R.World:
  R.World{data_376(input), data_358(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_379() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_380() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}}

def data_381() -> List<&2, C.Task>:
  [data_379(), data_380(), data_123(), data_118(), data_119()]

def data_382(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_381(), data_114()}

def data_383() -> List<&2, C.Task>:
  [data_380(), data_123(), data_118(), data_119()]

def data_384(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_383(), data_114()}

def data_385() -> C.Task:
  C.QueuePublication{5n, False{}, False{}}

def data_386() -> List<&2, C.Task>:
  [data_385(), data_123(), data_118(), data_119()]

def data_387(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_386(), data_114()}

def data_388(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_124(), data_114()}

def data_389(+input: Nat) -> R.World:
  R.World{data_376(input), data_358(), data_300(), 3n, 2n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_390(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_124(), data_114()}

def data_391(+input: Nat) -> R.World:
  R.World{data_376(input), data_358(), data_300(), 3n, 0n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_392() -> C.Task:
  C.Seam{}

def data_393() -> List<&2, C.Task>:
  [data_392(), data_118(), data_119()]

def data_394(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_393(), data_114()}

def data_395() -> C.Task:
  C.Settle{}

def data_396() -> C.Task:
  C.AfterSettle{}

def data_397() -> List<&2, C.Task>:
  [data_395(), data_396(), data_118(), data_119()]

def data_398(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_397(), data_114()}

def data_399() -> C.Task:
  C.CommitIntake{0n}

def data_400() -> C.Task:
  C.TrimIntake{0n}

def data_401() -> C.Task:
  C.FinishSettleIntake{0n}

def data_402() -> List<&2, C.Task>:
  [data_399(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_403(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_402(), data_114()}

def data_404() -> C.Task:
  C.CommitPending{2n}

def data_405() -> C.Task:
  C.CommitIntake{1n}

def data_406() -> List<&2, C.Task>:
  [data_404(), data_405(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_407(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_406(), data_114()}

def data_408(+input: Nat) -> R.Node:
  R.Node{data_9(), data_100(input), data_2(), False{}, 0, 0, 0, 0n, data_102(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_409(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_408(input), data_198(input), data_288(input), data_375(input)]

def data_410(+input: Nat) -> R.World:
  R.World{data_409(input), data_358(), data_300(), 3n, 0n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_411() -> List<&2, C.Task>:
  [data_405(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_412(+input: Nat) -> C.Machine:
  C.Machine{data_410(input), data_411(), data_114()}

def data_413() -> C.Task:
  C.CommitPending{3n}

def data_414() -> C.Task:
  C.CommitIntake{2n}

def data_415() -> List<&2, C.Task>:
  [data_413(), data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_416(+input: Nat) -> C.Machine:
  C.Machine{data_410(input), data_415(), data_114()}

def data_417(+input: Nat) -> R.Node:
  R.Node{data_12(), data_173(input), data_2(), False{}, 0, 16384, 0, 0n, data_183(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_418(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_408(input), data_417(input), data_288(input), data_375(input)]

def data_419(+input: Nat) -> R.World:
  R.World{data_418(input), data_358(), data_300(), 3n, 0n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_420() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_421() -> List<&2, C.Task>:
  [data_420(), data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_422(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_421(), data_114()}

def data_423() -> O.Task:
  O.TrimDeps{3n}

def data_424() -> List<&2, O.Task>:
  [data_423()]

def data_425() -> C.Task:
  C.OwnerTasks{data_424()}

def data_426() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_427() -> List<&2, C.Task>:
  [data_425(), data_426(), data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_428(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_427(), data_114()}

def data_429() -> List<&2, O.Task>:
  []

def data_430() -> C.Task:
  C.OwnerTasks{data_429()}

def data_431() -> List<&2, C.Task>:
  [data_430(), data_426(), data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_432(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_431(), data_114()}

def data_433() -> List<&2, C.Task>:
  [data_426(), data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_434(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_433(), data_114()}

def data_435() -> List<&2, C.Task>:
  [data_414(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_436(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_435(), data_114()}

def data_437() -> C.Task:
  C.CommitPending{4n}

def data_438() -> C.Task:
  C.CommitIntake{3n}

def data_439() -> List<&2, C.Task>:
  [data_437(), data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_440(+input: Nat) -> C.Machine:
  C.Machine{data_419(input), data_439(), data_114()}

def data_441(+input: Nat) -> R.Node:
  R.Node{data_12(), data_265(input), data_2(), False{}, 0, 16384, 0, 0n, data_275(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_442(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_408(input), data_417(input), data_441(input), data_375(input)]

def data_443(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_444() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_445() -> List<&2, C.Task>:
  [data_444(), data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_446(+input: Nat) -> C.Machine:
  C.Machine{data_443(input), data_445(), data_114()}

def data_447() -> O.Task:
  O.TrimDeps{4n}

def data_448() -> List<&2, O.Task>:
  [data_447()]

def data_449() -> C.Task:
  C.OwnerTasks{data_448()}

def data_450() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_451() -> List<&2, C.Task>:
  [data_449(), data_450(), data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_452(+input: Nat) -> C.Machine:
  C.Machine{data_443(input), data_451(), data_114()}

def data_453() -> List<&2, C.Task>:
  [data_430(), data_450(), data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_454(+input: Nat) -> C.Machine:
  C.Machine{data_443(input), data_453(), data_114()}

def data_455() -> List<&2, C.Task>:
  [data_450(), data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_456(+input: Nat) -> C.Machine:
  C.Machine{data_443(input), data_455(), data_114()}

def data_457() -> List<&2, C.Task>:
  [data_438(), data_400(), data_401(), data_396(), data_118(), data_119()]

def data_458(+input: Nat) -> C.Machine:
  C.Machine{data_443(input), data_457(), data_114()}

def data_459(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_460() -> List<&2, C.Task>:
  [data_400(), data_401(), data_396(), data_118(), data_119()]

def data_461(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_460(), data_114()}

def data_462() -> List<&2, C.Task>:
  [data_401(), data_396(), data_118(), data_119()]

def data_463(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_462(), data_114()}

def data_464(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_465() -> C.SeamFrame:
  C.SeamFrame{0n, data_377(), data_36()}

def data_466() -> C.Task:
  C.LandTransactions{data_465(), 0n}

def data_467() -> List<&2, C.Task>:
  [data_466(), data_396(), data_118(), data_119()]

def data_468(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_467(), data_114()}

def data_469() -> C.Task:
  C.CompleteSettle{data_465()}

def data_470() -> List<&2, C.Task>:
  [data_469(), data_396(), data_118(), data_119()]

def data_471(+input: Nat) -> C.Machine:
  C.Machine{data_464(input), data_470(), data_114()}

def data_472() -> C.Task:
  C.ZombieLoop{data_35()}

def data_473() -> List<&2, C.Task>:
  [data_472(), data_396(), data_118(), data_119()]

def data_474(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_473(), data_114()}

def data_475() -> List<&2, C.Task>:
  [data_396(), data_118(), data_119()]

def data_476(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_475(), data_114()}

def data_477(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_377(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_478() -> C.Task:
  C.RenderQueue{}

def data_479() -> List<&2, C.Task>:
  [data_478(), data_118(), data_119()]

def data_480(+input: Nat) -> C.Machine:
  C.Machine{data_477(input), data_479(), data_114()}

def data_481(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_482() -> C.Task:
  C.RunEffect{5n}

def data_483() -> C.Task:
  C.UserQueue{}

def data_484() -> List<&2, C.Task>:
  [data_482(), data_483(), data_118(), data_119()]

def data_485(+input: Nat) -> C.Machine:
  C.Machine{data_481(input), data_484(), data_114()}

def data_486() -> C.Task:
  C.ApplyEffect{5n}

def data_487() -> C.Task:
  C.EffectFinally{5n, True{}, data_114()}

def data_488() -> List<&2, C.Task>:
  [data_486(), data_487(), data_483(), data_118(), data_119()]

def data_489(+input: Nat) -> C.Machine:
  C.Machine{data_481(input), data_488(), data_114()}

def data_490(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_366(input)}

def data_491(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_490(input)]

def data_492(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_366(input), data_18()}

def data_493(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_163(input), data_45(), data_254(input), data_48(), data_344(input), data_359(input), data_492(input)]

def data_494(+input: Nat) -> R.World:
  R.World{data_442(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_491(input), data_493(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_495() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_496() -> List<&2, C.Task>:
  [data_495(), data_487(), data_483(), data_118(), data_119()]

def data_497(+input: Nat) -> C.Machine:
  C.Machine{data_494(input), data_496(), data_114()}

def data_498() -> List<&2, C.Task>:
  [data_487(), data_483(), data_118(), data_119()]

def data_499(+input: Nat) -> C.Machine:
  C.Machine{data_494(input), data_498(), data_114()}

def data_500(+input: Nat) -> R.Node:
  R.Node{data_23(), data_366(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_366(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_501(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_408(input), data_417(input), data_441(input), data_500(input)]

def data_502(+input: Nat) -> R.World:
  R.World{data_501(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_491(input), data_493(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_503() -> O.Task:
  O.TrimDeps{5n}

def data_504() -> List<&2, O.Task>:
  [data_503()]

def data_505() -> C.Task:
  C.OwnerTasks{data_504()}

def data_506() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_114()}

def data_507() -> List<&2, C.Task>:
  [data_505(), data_506(), data_483(), data_118(), data_119()]

def data_508(+input: Nat) -> C.Machine:
  C.Machine{data_502(input), data_507(), data_114()}

def data_509() -> List<&2, C.Task>:
  [data_430(), data_506(), data_483(), data_118(), data_119()]

def data_510(+input: Nat) -> C.Machine:
  C.Machine{data_502(input), data_509(), data_114()}

def data_511() -> List<&2, C.Task>:
  [data_506(), data_483(), data_118(), data_119()]

def data_512(+input: Nat) -> C.Machine:
  C.Machine{data_502(input), data_511(), data_114()}

def data_513() -> List<&2, C.Task>:
  [data_483(), data_118(), data_119()]

def data_514(+input: Nat) -> C.Machine:
  C.Machine{data_502(input), data_513(), data_114()}

def data_515() -> List<&2, C.Task>:
  [data_118(), data_119()]

def data_516(+input: Nat) -> C.Machine:
  C.Machine{data_502(input), data_515(), data_114()}

def data_517(+input: Nat) -> R.World:
  R.World{data_501(input), data_358(), data_300(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_491(input), data_493(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_518() -> List<&2, C.Task>:
  [data_119()]

def data_519(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_518(), data_114()}

def data_520() -> List<&2, C.Task>:
  []

def data_521(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_520(), data_114()}

def data_522(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_182(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_523(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_522(input), data_105(), data_106()]

def data_524(+input: Nat) -> R.World:
  R.World{data_523(input), data_162(), data_131(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_164(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_525(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_274(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_526(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_525(input), data_106()]

def data_527(+input: Nat) -> R.World:
  R.World{data_526(input), data_240(), data_131(), 1n, 2n, False{}, data_200(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_255(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_528() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_529(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_198(input), data_288(input), data_528()]

def data_530(+input: Nat) -> R.World:
  R.World{data_529(input), data_358(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_531(+input: Nat) -> R.World:
  R.World{data_529(input), data_358(), data_300(), 2n, 2n, False{}, data_290(), data_35(), data_377(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_110(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_532() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_533(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_101(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_534(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_533(input), data_17(), data_22(), data_26()]

def data_535(+input: Nat) -> R.World:
  R.World{data_534(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_536(+input: Nat) -> R.World:
  R.World{data_107(input), data_33(), data_108(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_537(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_17(), data_22(), data_26()]

def data_538(+input: Nat) -> R.World:
  R.World{data_537(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def data_539() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_540(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_103(input), data_104(), data_105(), data_539()]

def data_541() -> List<&2, Nat>:
  [3n]

def data_542(+input: Nat) -> R.World:
  R.World{data_540(input), data_33(), data_541(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97(), data_98()}

def origin() -> R.World:
  data_99()

def state_0(+input: Nat) -> C.Machine:
  data_115(input)

def state_1(+input: Nat) -> C.Machine:
  data_121(input)

def state_2(+input: Nat) -> C.Machine:
  data_125(input)

def state_3(+input: Nat) -> C.Machine:
  data_128(input)

def state_4(+input: Nat) -> C.Machine:
  data_135(input)

def state_5(+input: Nat) -> C.Machine:
  data_138(input)

def state_6(+input: Nat) -> C.Machine:
  data_147(input)

def state_7(+input: Nat) -> C.Machine:
  data_152(input)

def state_8(+input: Nat) -> C.Machine:
  data_155(input)

def state_9(+input: Nat) -> C.Machine:
  data_158(input)

def state_10(+input: Nat) -> C.Machine:
  data_168(input)

def state_11(+input: Nat) -> C.Machine:
  data_171(input)

def state_12(+input: Nat) -> C.Machine:
  data_175(input)

def state_13(+input: Nat) -> C.Machine:
  data_181(input)

def state_14(+input: Nat) -> C.Machine:
  data_192(input)

def state_15(+input: Nat) -> C.Machine:
  data_194(input)

def state_16(+input: Nat) -> C.Machine:
  data_197(input)

def state_17(+input: Nat) -> C.Machine:
  data_202(input)

def state_18(+input: Nat) -> C.Machine:
  data_204(input)

def state_19(+input: Nat) -> C.Machine:
  data_207(input)

def state_20(+input: Nat) -> C.Machine:
  data_213(input)

def state_21(+input: Nat) -> C.Machine:
  data_216(input)

def state_22(+input: Nat) -> C.Machine:
  data_225(input)

def state_23(+input: Nat) -> C.Machine:
  data_230(input)

def state_24(+input: Nat) -> C.Machine:
  data_233(input)

def state_25(+input: Nat) -> C.Machine:
  data_236(input)

def state_26(+input: Nat) -> C.Machine:
  data_245(input)

def state_27(+input: Nat) -> C.Machine:
  data_247(input)

def state_28(+input: Nat) -> C.Machine:
  data_251(input)

def state_29(+input: Nat) -> C.Machine:
  data_258(input)

def state_30(+input: Nat) -> C.Machine:
  data_260(input)

def state_31(+input: Nat) -> C.Machine:
  data_263(input)

def state_32(+input: Nat) -> C.Machine:
  data_267(input)

def state_33(+input: Nat) -> C.Machine:
  data_273(input)

def state_34(+input: Nat) -> C.Machine:
  data_282(input)

def state_35(+input: Nat) -> C.Machine:
  data_284(input)

def state_36(+input: Nat) -> C.Machine:
  data_287(input)

def state_37(+input: Nat) -> C.Machine:
  data_292(input)

def state_38(+input: Nat) -> C.Machine:
  data_294(input)

def state_39(+input: Nat) -> C.Machine:
  data_297(input)

def state_40(+input: Nat) -> C.Machine:
  data_304(input)

def state_41(+input: Nat) -> C.Machine:
  data_307(input)

def state_42(+input: Nat) -> C.Machine:
  data_316(input)

def state_43(+input: Nat) -> C.Machine:
  data_320(input)

def state_44(+input: Nat) -> C.Machine:
  data_323(input)

def state_45(+input: Nat) -> C.Machine:
  data_326(input)

def state_46(+input: Nat) -> C.Machine:
  data_335(input)

def state_47(+input: Nat) -> C.Machine:
  data_337(input)

def state_48(+input: Nat) -> C.Machine:
  data_341(input)

def state_49(+input: Nat) -> C.Machine:
  data_348(input)

def state_50(+input: Nat) -> C.Machine:
  data_350(input)

def state_51(+input: Nat) -> C.Machine:
  data_352(input)

def state_52(+input: Nat) -> C.Machine:
  data_354(input)

def state_53(+input: Nat) -> C.Machine:
  data_364(input)

def state_54(+input: Nat) -> C.Machine:
  data_368(input)

def state_55(+input: Nat) -> C.Machine:
  data_374(input)

def state_56(+input: Nat) -> C.Machine:
  data_382(input)

def state_57(+input: Nat) -> C.Machine:
  data_384(input)

def state_58(+input: Nat) -> C.Machine:
  data_387(input)

def state_59(+input: Nat) -> C.Machine:
  data_388(input)

def state_60(+input: Nat) -> C.Machine:
  data_390(input)

def state_61(+input: Nat) -> C.Machine:
  data_394(input)

def state_62(+input: Nat) -> C.Machine:
  data_398(input)

def state_63(+input: Nat) -> C.Machine:
  data_403(input)

def state_64(+input: Nat) -> C.Machine:
  data_407(input)

def state_65(+input: Nat) -> C.Machine:
  data_412(input)

def state_66(+input: Nat) -> C.Machine:
  data_416(input)

def state_67(+input: Nat) -> C.Machine:
  data_422(input)

def state_68(+input: Nat) -> C.Machine:
  data_428(input)

def state_69(+input: Nat) -> C.Machine:
  data_432(input)

def state_70(+input: Nat) -> C.Machine:
  data_434(input)

def state_71(+input: Nat) -> C.Machine:
  data_436(input)

def state_72(+input: Nat) -> C.Machine:
  data_440(input)

def state_73(+input: Nat) -> C.Machine:
  data_446(input)

def state_74(+input: Nat) -> C.Machine:
  data_452(input)

def state_75(+input: Nat) -> C.Machine:
  data_454(input)

def state_76(+input: Nat) -> C.Machine:
  data_456(input)

def state_77(+input: Nat) -> C.Machine:
  data_458(input)

def state_78(+input: Nat) -> C.Machine:
  data_461(input)

def state_79(+input: Nat) -> C.Machine:
  data_463(input)

def state_80(+input: Nat) -> C.Machine:
  data_468(input)

def state_81(+input: Nat) -> C.Machine:
  data_471(input)

def state_82(+input: Nat) -> C.Machine:
  data_474(input)

def state_83(+input: Nat) -> C.Machine:
  data_476(input)

def state_84(+input: Nat) -> C.Machine:
  data_480(input)

def state_85(+input: Nat) -> C.Machine:
  data_485(input)

def state_86(+input: Nat) -> C.Machine:
  data_489(input)

def state_87(+input: Nat) -> C.Machine:
  data_497(input)

def state_88(+input: Nat) -> C.Machine:
  data_499(input)

def state_89(+input: Nat) -> C.Machine:
  data_508(input)

def state_90(+input: Nat) -> C.Machine:
  data_510(input)

def state_91(+input: Nat) -> C.Machine:
  data_512(input)

def state_92(+input: Nat) -> C.Machine:
  data_514(input)

def state_93(+input: Nat) -> C.Machine:
  data_516(input)

def state_94(+input: Nat) -> C.Machine:
  data_519(input)

def state_95(+input: Nat) -> C.Machine:
  data_521(input)

def finalWorld(+input: Nat) -> R.World:
  data_517(input)

def slot_13(+input: Nat) -> R.World:
  data_524(input)

def notify_13(+input: Nat) -> R.World:
  data_188(input)

def slot_33(+input: Nat) -> R.World:
  data_527(input)

def notify_33(+input: Nat) -> R.World:
  data_278(input)

def modified_55(+input: Nat) -> R.World:
  data_530(input)

def queued_55(+input: Nat) -> R.World:
  data_531(input)

def value_55(+input: Nat) -> R.World:
  data_378(input)

def setter_queued(+input: Nat) -> R.World:
  data_532()

def setter_slot(+input: Nat) -> R.World:
  data_535(input)

def setter_inserted(+input: Nat) -> R.World:
  data_536(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_111(input)

def setter_stamped(+input: Nat) -> R.World:
  data_538(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_542(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_536(input)

