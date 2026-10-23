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
  R.StreamPlan{data_72(), False{}, data_2(), 0n, 0n, data_2()}

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

def data_101() -> R.Value:
  R.Null{}

def data_102() -> R.DeferredCell:
  R.DeferredCell{0n, data_101(), False{}, False{}}

def data_103() -> R.DeferredBinding:
  R.DeferredBinding{data_102(), 0n}

def data_104() -> List<&2, R.DeferredBinding>:
  [data_103()]

def data_105() -> List<&2, R.DeferredWait>:
  []

def data_106() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_107() -> List<&2, R.DeferredIterator>:
  [data_106()]

def data_108() -> R.DeferredArena:
  R.DeferredArena{data_104(), data_35(), data_105(), data_107()}

def data_109() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_110(+input: Nat) -> R.Value:
  R.Number{input}

def data_111(+input: Nat) -> R.Slot:
  R.Present{data_110(input)}

def data_112() -> R.Stamp:
  R.Stamped{7n}

def data_113(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_111(input), False{}, 0, 0, 0, 0n, data_112(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_114() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_115() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_116() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_117(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_114(), data_115(), data_116()]

def data_118() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_119() -> R.HostJob:
  R.FlushJob{}

def data_120() -> List<&2, R.HostJob>:
  [data_119()]

def data_121(+input: Nat) -> R.World:
  R.World{data_117(input), data_33(), data_118(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_122() -> C.Task:
  C.Round{}

def data_123() -> List<&2, C.Task>:
  [data_122()]

def data_124() -> List<&2, R.Value>:
  []

def data_125(+input: Nat) -> C.Machine:
  C.Machine{data_121(input), data_123(), data_124()}

def data_126(+input: Nat) -> R.World:
  R.World{data_117(input), data_33(), data_118(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_127() -> C.Task:
  C.RoundAfterSweep{}

def data_128() -> C.Task:
  C.FlushFinally{}

def data_129() -> C.Task:
  C.RoundEnd{}

def data_130() -> List<&2, C.Task>:
  [data_127(), data_128(), data_129()]

def data_131(+input: Nat) -> C.Machine:
  C.Machine{data_126(input), data_130(), data_124()}

def data_132(+input: Nat) -> R.World:
  R.World{data_117(input), data_33(), data_118(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_133() -> C.Task:
  C.HeapLoop{}

def data_134() -> List<&2, C.Task>:
  [data_133(), data_128(), data_129()]

def data_135(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_134(), data_124()}

def data_136() -> C.Task:
  C.Recompute{3n, False{}}

def data_137() -> List<&2, C.Task>:
  [data_136(), data_133(), data_128(), data_129()]

def data_138(+input: Nat) -> C.Machine:
  C.Machine{data_132(input), data_137(), data_124()}

def data_139() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_140(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_139(), data_115(), data_116()]

def data_141() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_142() -> R.LaneMount:
  R.MountFalse{}

def data_143() -> R.LaneState:
  R.LaneState{data_35(), data_65(), data_35(), data_97(), 0n, data_142()}

def data_144(+input: Nat) -> R.World:
  R.World{data_140(input), data_33(), data_141(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_145() -> C.LanePass:
  C.LanePass{0n, data_98(), data_142()}

def data_146() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_145()}

def data_147() -> List<&2, C.Task>:
  [data_146(), data_133(), data_128(), data_129()]

def data_148(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_147(), data_124()}

def data_149() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_145()}

def data_150() -> List<&2, C.Task>:
  [data_149(), data_133(), data_128(), data_129()]

def data_151(+input: Nat) -> C.Machine:
  C.Machine{data_144(input), data_150(), data_124()}

def data_152() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_153(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_152(), data_115(), data_116()]

def data_154() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_155(+input: Nat) -> R.World:
  R.World{data_153(input), data_33(), data_141(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_154(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_156() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_157() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_124(), 0n, False{}, data_145()}

def data_158() -> C.Task:
  C.Finish{data_157()}

def data_159() -> List<&2, C.Task>:
  [data_156(), data_158(), data_133(), data_128(), data_129()]

def data_160(+input: Nat) -> C.Machine:
  C.Machine{data_155(input), data_159(), data_124()}

def data_161() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_162() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_163() -> C.Task:
  C.Binary{0}

def data_164() -> List<&2, C.Task>:
  [data_161(), data_162(), data_163(), data_158(), data_133(), data_128(), data_129()]

def data_165(+input: Nat) -> C.Machine:
  C.Machine{data_155(input), data_164(), data_124()}

def data_166() -> C.Task:
  C.ReadNode{2n}

def data_167() -> List<&2, C.Task>:
  [data_166(), data_162(), data_163(), data_158(), data_133(), data_128(), data_129()]

def data_168(+input: Nat) -> C.Machine:
  C.Machine{data_155(input), data_167(), data_124()}

def data_169() -> C.Task:
  C.ReadPrepared{2n}

def data_170() -> List<&2, C.Task>:
  [data_169(), data_162(), data_163(), data_158(), data_133(), data_128(), data_129()]

def data_171(+input: Nat) -> C.Machine:
  C.Machine{data_155(input), data_170(), data_124()}

def data_172() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_173(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_172(), data_115(), data_116()]

def data_174() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_175() -> List<&2, R.Link>:
  [data_28(), data_174(), data_30(), data_31(), data_32()]

def data_176(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_110(input)}

def data_177(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input)]

def data_178(+input: Nat) -> R.World:
  R.World{data_173(input), data_175(), data_141(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_179() -> List<&2, C.Task>:
  [data_162(), data_163(), data_158(), data_133(), data_128(), data_129()]

def data_180(+input: Nat) -> List<&2, R.Value>:
  [data_110(input)]

def data_181(+input: Nat) -> C.Machine:
  C.Machine{data_178(input), data_179(), data_180(input)}

def data_182() -> List<&2, C.Task>:
  [data_163(), data_158(), data_133(), data_128(), data_129()]

def data_183(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_110(input)]

def data_184(+input: Nat) -> C.Machine:
  C.Machine{data_178(input), data_182(), data_183(input)}

def data_185() -> List<&2, C.Task>:
  [data_158(), data_133(), data_128(), data_129()]

def data_186(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_187(+input: Nat) -> List<&2, R.Value>:
  [data_186(input)]

def data_188(+input: Nat) -> C.Machine:
  C.Machine{data_178(input), data_185(), data_187(input)}

def data_189() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_190(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_189(), data_115(), data_116()]

def data_191(+input: Nat) -> R.World:
  R.World{data_190(input), data_175(), data_141(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_192(+input: Nat) -> C.Task:
  C.PassReleases{data_157(), 0n, data_186(input), False{}, False{}, False{}, data_53()}

def data_193(+input: Nat) -> List<&2, C.Task>:
  [data_192(input), data_133(), data_128(), data_129()]

def data_194(+input: Nat) -> C.Machine:
  C.Machine{data_191(input), data_193(input), data_124()}

def data_195(+input: Nat) -> R.Slot:
  R.Present{data_186(input)}

def data_196() -> R.Stamp:
  R.Stamped{8n}

def data_197(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_195(input), False{}, 0, 16384, 0, 0n, data_196(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_198() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_199(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_197(input), data_198(), data_116()]

def data_200() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_201(+input: Nat) -> R.World:
  R.World{data_199(input), data_175(), data_200(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_202() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_203() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_204() -> List<&2, C.Task>:
  [data_202(), data_203(), data_133(), data_128(), data_129()]

def data_205(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_204(), data_124()}

def data_206() -> List<&2, C.Task>:
  [data_203(), data_133(), data_128(), data_129()]

def data_207(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_206(), data_124()}

def data_208() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_209() -> List<&2, C.Task>:
  [data_208(), data_133(), data_128(), data_129()]

def data_210(+input: Nat) -> C.Machine:
  C.Machine{data_201(input), data_209(), data_124()}

def data_211(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_195(input), False{}, 128, 16384, 0, 0n, data_196(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_212(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_198(), data_116()]

def data_213() -> List<&2, Nat>:
  [2n, 3n]

def data_214(+input: Nat) -> R.World:
  R.World{data_212(input), data_175(), data_200(), 0n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_134(), data_124()}

def data_216(+input: Nat) -> R.World:
  R.World{data_212(input), data_175(), data_200(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_217(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_134(), data_124()}

def data_218() -> C.Task:
  C.Recompute{4n, False{}}

def data_219() -> List<&2, C.Task>:
  [data_218(), data_133(), data_128(), data_129()]

def data_220(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_219(), data_124()}

def data_221() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_222(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_221(), data_116()]

def data_223(+input: Nat) -> R.World:
  R.World{data_222(input), data_175(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_224() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_145()}

def data_225() -> List<&2, C.Task>:
  [data_224(), data_133(), data_128(), data_129()]

def data_226(+input: Nat) -> C.Machine:
  C.Machine{data_223(input), data_225(), data_124()}

def data_227() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_145()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_133(), data_128(), data_129()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_223(input), data_228(), data_124()}

def data_230() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_231(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_230(), data_116()]

def data_232(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45()]

def data_233(+input: Nat) -> R.World:
  R.World{data_231(input), data_175(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_232(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_234() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_235() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_124(), 0n, False{}, data_145()}

def data_236() -> C.Task:
  C.Finish{data_235()}

def data_237() -> List<&2, C.Task>:
  [data_234(), data_236(), data_133(), data_128(), data_129()]

def data_238(+input: Nat) -> C.Machine:
  C.Machine{data_233(input), data_237(), data_124()}

def data_239() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_240() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_241() -> C.Task:
  C.Binary{1}

def data_242() -> List<&2, C.Task>:
  [data_239(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_243(+input: Nat) -> C.Machine:
  C.Machine{data_233(input), data_242(), data_124()}

def data_244() -> C.Task:
  C.ReadNode{3n}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_233(input), data_245(), data_124()}

def data_247() -> C.Task:
  C.ReadPrepared{3n}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_233(input), data_248(), data_124()}

def data_250() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_251(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_250(), data_116()]

def data_252() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_253() -> List<&2, R.Link>:
  [data_28(), data_174(), data_252(), data_31(), data_32()]

def data_254(+input: Nat) -> R.World:
  R.World{data_251(input), data_253(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_232(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_255() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_256() -> C.Task:
  C.ReadStatus{3n}

def data_257() -> List<&2, C.Task>:
  [data_255(), data_256(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_258(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_257(), data_124()}

def data_259() -> List<&2, C.Task>:
  [data_256(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_259(), data_124()}

def data_261() -> C.Task:
  C.Serve{3n}

def data_262() -> C.Task:
  C.AfterServe{3n}

def data_263() -> List<&2, C.Task>:
  [data_261(), data_262(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_264(+input: Nat) -> C.Machine:
  C.Machine{data_254(input), data_263(), data_124()}

def data_265() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_266(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_265(), data_116()]

def data_267(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_186(input)}

def data_268(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45(), data_267(input)]

def data_269(+input: Nat) -> R.World:
  R.World{data_266(input), data_253(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_270() -> List<&2, C.Task>:
  [data_262(), data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_271(+input: Nat) -> C.Machine:
  C.Machine{data_269(input), data_270(), data_187(input)}

def data_272() -> List<&2, C.Task>:
  [data_240(), data_241(), data_236(), data_133(), data_128(), data_129()]

def data_273(+input: Nat) -> C.Machine:
  C.Machine{data_269(input), data_272(), data_187(input)}

def data_274() -> List<&2, C.Task>:
  [data_241(), data_236(), data_133(), data_128(), data_129()]

def data_275(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_186(input)]

def data_276(+input: Nat) -> C.Machine:
  C.Machine{data_269(input), data_274(), data_275(input)}

def data_277() -> List<&2, C.Task>:
  [data_236(), data_133(), data_128(), data_129()]

def data_278(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_279(+input: Nat) -> List<&2, R.Value>:
  [data_278(input)]

def data_280(+input: Nat) -> C.Machine:
  C.Machine{data_269(input), data_277(), data_279(input)}

def data_281() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_282(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_281(), data_116()]

def data_283(+input: Nat) -> R.World:
  R.World{data_282(input), data_253(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_284(+input: Nat) -> C.Task:
  C.PassReleases{data_235(), 0n, data_278(input), False{}, False{}, False{}, data_53()}

def data_285(+input: Nat) -> List<&2, C.Task>:
  [data_284(input), data_133(), data_128(), data_129()]

def data_286(+input: Nat) -> C.Machine:
  C.Machine{data_283(input), data_285(input), data_124()}

def data_287(+input: Nat) -> R.Slot:
  R.Present{data_278(input)}

def data_288() -> R.Stamp:
  R.Stamped{9n}

def data_289(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_287(input), False{}, 0, 16384, 0, 0n, data_288(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_290(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_289(input), data_116()]

def data_291(+input: Nat) -> R.World:
  R.World{data_290(input), data_253(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_292() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_293() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_294() -> List<&2, C.Task>:
  [data_292(), data_293(), data_133(), data_128(), data_129()]

def data_295(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_294(), data_124()}

def data_296() -> List<&2, C.Task>:
  [data_293(), data_133(), data_128(), data_129()]

def data_297(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_296(), data_124()}

def data_298() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_299() -> List<&2, C.Task>:
  [data_298(), data_133(), data_128(), data_129()]

def data_300(+input: Nat) -> C.Machine:
  C.Machine{data_291(input), data_299(), data_124()}

def data_301(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_287(input), False{}, 128, 16384, 0, 0n, data_288(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_302(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_116()]

def data_303() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_304(+input: Nat) -> R.World:
  R.World{data_302(input), data_253(), data_141(), 1n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_305(+input: Nat) -> C.Machine:
  C.Machine{data_304(input), data_134(), data_124()}

def data_306(+input: Nat) -> R.World:
  R.World{data_302(input), data_253(), data_141(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_307(+input: Nat) -> C.Machine:
  C.Machine{data_306(input), data_134(), data_124()}

def data_308() -> C.Task:
  C.Recompute{5n, False{}}

def data_309() -> List<&2, C.Task>:
  [data_308(), data_133(), data_128(), data_129()]

def data_310(+input: Nat) -> C.Machine:
  C.Machine{data_306(input), data_309(), data_124()}

def data_311() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_312(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_311()]

def data_313() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_314(+input: Nat) -> R.World:
  R.World{data_312(input), data_253(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_315() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_145()}

def data_316() -> List<&2, C.Task>:
  [data_315(), data_133(), data_128(), data_129()]

def data_317(+input: Nat) -> C.Machine:
  C.Machine{data_314(input), data_316(), data_124()}

def data_318() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_145()}

def data_319() -> List<&2, C.Task>:
  [data_318(), data_133(), data_128(), data_129()]

def data_320(+input: Nat) -> C.Machine:
  C.Machine{data_314(input), data_319(), data_124()}

def data_321() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_322(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_321()]

def data_323(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45(), data_267(input), data_48()]

def data_324(+input: Nat) -> R.World:
  R.World{data_322(input), data_253(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_323(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_325() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_326() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_124(), 0n, False{}, data_145()}

def data_327() -> C.Task:
  C.Finish{data_326()}

def data_328() -> List<&2, C.Task>:
  [data_325(), data_327(), data_133(), data_128(), data_129()]

def data_329(+input: Nat) -> C.Machine:
  C.Machine{data_324(input), data_328(), data_124()}

def data_330() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_331() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_332() -> List<&2, C.Task>:
  [data_330(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_333(+input: Nat) -> C.Machine:
  C.Machine{data_324(input), data_332(), data_124()}

def data_334() -> C.Task:
  C.ReadNode{4n}

def data_335() -> List<&2, C.Task>:
  [data_334(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_336(+input: Nat) -> C.Machine:
  C.Machine{data_324(input), data_335(), data_124()}

def data_337() -> C.Task:
  C.ReadPrepared{4n}

def data_338() -> List<&2, C.Task>:
  [data_337(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_339(+input: Nat) -> C.Machine:
  C.Machine{data_324(input), data_338(), data_124()}

def data_340() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_341(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_340()]

def data_342() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_343() -> List<&2, R.Link>:
  [data_28(), data_174(), data_252(), data_342(), data_32()]

def data_344(+input: Nat) -> R.World:
  R.World{data_341(input), data_343(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_323(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_345() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_346() -> C.Task:
  C.ReadStatus{4n}

def data_347() -> List<&2, C.Task>:
  [data_345(), data_346(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_348(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_347(), data_124()}

def data_349() -> List<&2, C.Task>:
  [data_346(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_350(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_349(), data_124()}

def data_351() -> C.Task:
  C.Serve{4n}

def data_352() -> C.Task:
  C.AfterServe{4n}

def data_353() -> List<&2, C.Task>:
  [data_351(), data_352(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_354(+input: Nat) -> C.Machine:
  C.Machine{data_344(input), data_353(), data_124()}

def data_355() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_356(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_355()]

def data_357(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_278(input)}

def data_358(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45(), data_267(input), data_48(), data_357(input)]

def data_359(+input: Nat) -> R.World:
  R.World{data_356(input), data_343(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_358(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_360() -> List<&2, C.Task>:
  [data_352(), data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_361(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_360(), data_279(input)}

def data_362() -> List<&2, C.Task>:
  [data_331(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_363(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_362(), data_279(input)}

def data_364() -> List<&2, C.Task>:
  [data_166(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_365(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_364(), data_279(input)}

def data_366() -> List<&2, C.Task>:
  [data_169(), data_163(), data_327(), data_133(), data_128(), data_129()]

def data_367(+input: Nat) -> C.Machine:
  C.Machine{data_359(input), data_366(), data_279(input)}

def data_368() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_369(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_368()]

def data_370() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_371() -> List<&2, R.Link>:
  [data_28(), data_174(), data_252(), data_342(), data_370()]

def data_372(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_110(input)}

def data_373(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45(), data_267(input), data_48(), data_357(input), data_372(input)]

def data_374(+input: Nat) -> R.World:
  R.World{data_369(input), data_371(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_143(), data_100(), data_2(), data_35(), data_108()}

def data_375() -> List<&2, C.Task>:
  [data_163(), data_327(), data_133(), data_128(), data_129()]

def data_376(+input: Nat) -> List<&2, R.Value>:
  [data_110(input), data_278(input)]

def data_377(+input: Nat) -> C.Machine:
  C.Machine{data_374(input), data_375(), data_376(input)}

def data_378() -> List<&2, C.Task>:
  [data_327(), data_133(), data_128(), data_129()]

def data_379(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_380(+input: Nat) -> List<&2, R.Value>:
  [data_379(input)]

def data_381(+input: Nat) -> C.Machine:
  C.Machine{data_374(input), data_378(), data_380(input)}

def data_382() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_383(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_382()]

def data_384(+input: Nat) -> R.World:
  R.World{data_383(input), data_371(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_385(+input: Nat) -> C.Task:
  C.PassReleases{data_326(), 0n, data_379(input), False{}, False{}, False{}, data_53()}

def data_386(+input: Nat) -> List<&2, C.Task>:
  [data_385(input), data_133(), data_128(), data_129()]

def data_387(+input: Nat) -> C.Machine:
  C.Machine{data_384(input), data_386(input), data_124()}

def data_388(+input: Nat) -> R.Node:
  R.Node{data_23(), data_379(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_389(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_388(input)]

def data_390() -> List<&2, Nat>:
  [5n]

def data_391(+input: Nat) -> R.World:
  R.World{data_389(input), data_371(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_392() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_393() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_394() -> List<&2, C.Task>:
  [data_392(), data_393(), data_133(), data_128(), data_129()]

def data_395(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_394(), data_124()}

def data_396() -> List<&2, C.Task>:
  [data_393(), data_133(), data_128(), data_129()]

def data_397(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_396(), data_124()}

def data_398() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_399() -> List<&2, C.Task>:
  [data_398(), data_133(), data_128(), data_129()]

def data_400(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_399(), data_124()}

def data_401(+input: Nat) -> C.Machine:
  C.Machine{data_391(input), data_134(), data_124()}

def data_402(+input: Nat) -> R.World:
  R.World{data_389(input), data_371(), data_313(), 3n, 2n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_403(+input: Nat) -> C.Machine:
  C.Machine{data_402(input), data_134(), data_124()}

def data_404(+input: Nat) -> R.World:
  R.World{data_389(input), data_371(), data_313(), 3n, 0n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_405() -> C.Task:
  C.Seam{}

def data_406() -> List<&2, C.Task>:
  [data_405(), data_128(), data_129()]

def data_407(+input: Nat) -> C.Machine:
  C.Machine{data_404(input), data_406(), data_124()}

def data_408() -> C.Task:
  C.Settle{}

def data_409() -> C.Task:
  C.AfterSettle{}

def data_410() -> List<&2, C.Task>:
  [data_408(), data_409(), data_128(), data_129()]

def data_411(+input: Nat) -> C.Machine:
  C.Machine{data_404(input), data_410(), data_124()}

def data_412() -> C.Task:
  C.CommitIntake{0n}

def data_413() -> C.Task:
  C.TrimIntake{0n}

def data_414() -> C.Task:
  C.FinishSettleIntake{0n}

def data_415() -> List<&2, C.Task>:
  [data_412(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_416(+input: Nat) -> C.Machine:
  C.Machine{data_404(input), data_415(), data_124()}

def data_417() -> C.Task:
  C.CommitPending{2n}

def data_418() -> C.Task:
  C.CommitIntake{1n}

def data_419() -> List<&2, C.Task>:
  [data_417(), data_418(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_420(+input: Nat) -> C.Machine:
  C.Machine{data_404(input), data_419(), data_124()}

def data_421(+input: Nat) -> R.Node:
  R.Node{data_9(), data_110(input), data_2(), False{}, 0, 0, 0, 0n, data_112(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_422(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_421(input), data_211(input), data_301(input), data_388(input)]

def data_423(+input: Nat) -> R.World:
  R.World{data_422(input), data_371(), data_313(), 3n, 0n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_424() -> List<&2, C.Task>:
  [data_418(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_425(+input: Nat) -> C.Machine:
  C.Machine{data_423(input), data_424(), data_124()}

def data_426() -> C.Task:
  C.CommitPending{3n}

def data_427() -> C.Task:
  C.CommitIntake{2n}

def data_428() -> List<&2, C.Task>:
  [data_426(), data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_429(+input: Nat) -> C.Machine:
  C.Machine{data_423(input), data_428(), data_124()}

def data_430(+input: Nat) -> R.Node:
  R.Node{data_12(), data_186(input), data_2(), False{}, 0, 16384, 0, 0n, data_196(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_431(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_421(input), data_430(input), data_301(input), data_388(input)]

def data_432(+input: Nat) -> R.World:
  R.World{data_431(input), data_371(), data_313(), 3n, 0n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_433() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_434() -> List<&2, C.Task>:
  [data_433(), data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_435(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_434(), data_124()}

def data_436() -> O.Task:
  O.TrimDeps{3n}

def data_437() -> List<&2, O.Task>:
  [data_436()]

def data_438() -> C.Task:
  C.OwnerTasks{data_437()}

def data_439() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_440() -> List<&2, C.Task>:
  [data_438(), data_439(), data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_441(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_440(), data_124()}

def data_442() -> List<&2, O.Task>:
  []

def data_443() -> C.Task:
  C.OwnerTasks{data_442()}

def data_444() -> List<&2, C.Task>:
  [data_443(), data_439(), data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_445(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_444(), data_124()}

def data_446() -> List<&2, C.Task>:
  [data_439(), data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_447(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_446(), data_124()}

def data_448() -> List<&2, C.Task>:
  [data_427(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_449(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_448(), data_124()}

def data_450() -> C.Task:
  C.CommitPending{4n}

def data_451() -> C.Task:
  C.CommitIntake{3n}

def data_452() -> List<&2, C.Task>:
  [data_450(), data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_453(+input: Nat) -> C.Machine:
  C.Machine{data_432(input), data_452(), data_124()}

def data_454(+input: Nat) -> R.Node:
  R.Node{data_12(), data_278(input), data_2(), False{}, 0, 16384, 0, 0n, data_288(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_455(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_421(input), data_430(input), data_454(input), data_388(input)]

def data_456(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_457() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_458() -> List<&2, C.Task>:
  [data_457(), data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_459(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_458(), data_124()}

def data_460() -> O.Task:
  O.TrimDeps{4n}

def data_461() -> List<&2, O.Task>:
  [data_460()]

def data_462() -> C.Task:
  C.OwnerTasks{data_461()}

def data_463() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_464() -> List<&2, C.Task>:
  [data_462(), data_463(), data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_465(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_464(), data_124()}

def data_466() -> List<&2, C.Task>:
  [data_443(), data_463(), data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_467(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_466(), data_124()}

def data_468() -> List<&2, C.Task>:
  [data_463(), data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_469(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_468(), data_124()}

def data_470() -> List<&2, C.Task>:
  [data_451(), data_413(), data_414(), data_409(), data_128(), data_129()]

def data_471(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_470(), data_124()}

def data_472(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_473() -> List<&2, C.Task>:
  [data_413(), data_414(), data_409(), data_128(), data_129()]

def data_474(+input: Nat) -> C.Machine:
  C.Machine{data_472(input), data_473(), data_124()}

def data_475() -> List<&2, C.Task>:
  [data_414(), data_409(), data_128(), data_129()]

def data_476(+input: Nat) -> C.Machine:
  C.Machine{data_472(input), data_475(), data_124()}

def data_477(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_478() -> C.SeamFrame:
  C.SeamFrame{0n, data_390(), data_36(), data_35(), data_36()}

def data_479() -> C.Task:
  C.LandTransactions{data_478(), 0n}

def data_480() -> List<&2, C.Task>:
  [data_479(), data_409(), data_128(), data_129()]

def data_481(+input: Nat) -> C.Machine:
  C.Machine{data_477(input), data_480(), data_124()}

def data_482() -> C.Task:
  C.CompleteSettle{data_478()}

def data_483() -> List<&2, C.Task>:
  [data_482(), data_409(), data_128(), data_129()]

def data_484(+input: Nat) -> C.Machine:
  C.Machine{data_477(input), data_483(), data_124()}

def data_485() -> C.Task:
  C.ZombieLoop{data_35()}

def data_486() -> List<&2, C.Task>:
  [data_485(), data_409(), data_128(), data_129()]

def data_487(+input: Nat) -> C.Machine:
  C.Machine{data_472(input), data_486(), data_124()}

def data_488() -> List<&2, C.Task>:
  [data_409(), data_128(), data_129()]

def data_489(+input: Nat) -> C.Machine:
  C.Machine{data_472(input), data_488(), data_124()}

def data_490(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_390(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_491() -> C.Task:
  C.RenderQueue{}

def data_492() -> List<&2, C.Task>:
  [data_491(), data_128(), data_129()]

def data_493(+input: Nat) -> C.Machine:
  C.Machine{data_490(input), data_492(), data_124()}

def data_494(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_495() -> C.Task:
  C.RunEffect{5n}

def data_496() -> C.Task:
  C.UserQueue{}

def data_497() -> List<&2, C.Task>:
  [data_495(), data_496(), data_128(), data_129()]

def data_498(+input: Nat) -> C.Machine:
  C.Machine{data_494(input), data_497(), data_124()}

def data_499() -> C.Task:
  C.ApplyEffect{5n}

def data_500() -> C.Task:
  C.EffectFinally{5n, True{}, data_124()}

def data_501() -> List<&2, C.Task>:
  [data_499(), data_500(), data_496(), data_128(), data_129()]

def data_502(+input: Nat) -> C.Machine:
  C.Machine{data_494(input), data_501(), data_124()}

def data_503(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_379(input)}

def data_504(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_503(input)]

def data_505(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_379(input), data_18()}

def data_506(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_176(input), data_45(), data_267(input), data_48(), data_357(input), data_372(input), data_505(input)]

def data_507(+input: Nat) -> R.World:
  R.World{data_455(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_504(input), data_506(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_508() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_509() -> List<&2, C.Task>:
  [data_508(), data_500(), data_496(), data_128(), data_129()]

def data_510(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_509(), data_124()}

def data_511() -> List<&2, C.Task>:
  [data_500(), data_496(), data_128(), data_129()]

def data_512(+input: Nat) -> C.Machine:
  C.Machine{data_507(input), data_511(), data_124()}

def data_513(+input: Nat) -> R.Node:
  R.Node{data_23(), data_379(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_379(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_514(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_421(input), data_430(input), data_454(input), data_513(input)]

def data_515(+input: Nat) -> R.World:
  R.World{data_514(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_504(input), data_506(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_516() -> O.Task:
  O.TrimDeps{5n}

def data_517() -> List<&2, O.Task>:
  [data_516()]

def data_518() -> C.Task:
  C.OwnerTasks{data_517()}

def data_519() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_124()}

def data_520() -> List<&2, C.Task>:
  [data_518(), data_519(), data_496(), data_128(), data_129()]

def data_521(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_520(), data_124()}

def data_522() -> List<&2, C.Task>:
  [data_443(), data_519(), data_496(), data_128(), data_129()]

def data_523(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_522(), data_124()}

def data_524() -> List<&2, C.Task>:
  [data_519(), data_496(), data_128(), data_129()]

def data_525(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_524(), data_124()}

def data_526() -> List<&2, C.Task>:
  [data_496(), data_128(), data_129()]

def data_527(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_526(), data_124()}

def data_528() -> List<&2, C.Task>:
  [data_128(), data_129()]

def data_529(+input: Nat) -> C.Machine:
  C.Machine{data_515(input), data_528(), data_124()}

def data_530(+input: Nat) -> R.World:
  R.World{data_514(input), data_371(), data_313(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_504(input), data_506(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_531() -> List<&2, C.Task>:
  [data_129()]

def data_532(+input: Nat) -> C.Machine:
  C.Machine{data_530(input), data_531(), data_124()}

def data_533() -> List<&2, C.Task>:
  []

def data_534(+input: Nat) -> C.Machine:
  C.Machine{data_530(input), data_533(), data_124()}

def data_535(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_195(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_536(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_535(input), data_115(), data_116()]

def data_537(+input: Nat) -> R.World:
  R.World{data_536(input), data_175(), data_141(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_177(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_538(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_287(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_539(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_538(input), data_116()]

def data_540(+input: Nat) -> R.World:
  R.World{data_539(input), data_253(), data_141(), 1n, 2n, False{}, data_213(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_268(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_541() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_542(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_211(input), data_301(input), data_541()]

def data_543(+input: Nat) -> R.World:
  R.World{data_542(input), data_371(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_544(+input: Nat) -> R.World:
  R.World{data_542(input), data_371(), data_313(), 2n, 2n, False{}, data_303(), data_35(), data_390(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_373(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_120(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_545() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_546(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_111(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_547(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_546(input), data_17(), data_22(), data_26()]

def data_548(+input: Nat) -> R.World:
  R.World{data_547(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_549(+input: Nat) -> R.World:
  R.World{data_117(input), data_33(), data_118(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_550(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_17(), data_22(), data_26()]

def data_551(+input: Nat) -> R.World:
  R.World{data_550(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def data_552() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_553(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_113(input), data_114(), data_115(), data_552()]

def data_554() -> List<&2, Nat>:
  [3n]

def data_555(+input: Nat) -> R.World:
  R.World{data_553(input), data_33(), data_554(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_108()}

def origin() -> R.World:
  data_109()

def state_0(+input: Nat) -> C.Machine:
  data_125(input)

def state_1(+input: Nat) -> C.Machine:
  data_131(input)

def state_2(+input: Nat) -> C.Machine:
  data_135(input)

def state_3(+input: Nat) -> C.Machine:
  data_138(input)

def state_4(+input: Nat) -> C.Machine:
  data_148(input)

def state_5(+input: Nat) -> C.Machine:
  data_151(input)

def state_6(+input: Nat) -> C.Machine:
  data_160(input)

def state_7(+input: Nat) -> C.Machine:
  data_165(input)

def state_8(+input: Nat) -> C.Machine:
  data_168(input)

def state_9(+input: Nat) -> C.Machine:
  data_171(input)

def state_10(+input: Nat) -> C.Machine:
  data_181(input)

def state_11(+input: Nat) -> C.Machine:
  data_184(input)

def state_12(+input: Nat) -> C.Machine:
  data_188(input)

def state_13(+input: Nat) -> C.Machine:
  data_194(input)

def state_14(+input: Nat) -> C.Machine:
  data_205(input)

def state_15(+input: Nat) -> C.Machine:
  data_207(input)

def state_16(+input: Nat) -> C.Machine:
  data_210(input)

def state_17(+input: Nat) -> C.Machine:
  data_215(input)

def state_18(+input: Nat) -> C.Machine:
  data_217(input)

def state_19(+input: Nat) -> C.Machine:
  data_220(input)

def state_20(+input: Nat) -> C.Machine:
  data_226(input)

def state_21(+input: Nat) -> C.Machine:
  data_229(input)

def state_22(+input: Nat) -> C.Machine:
  data_238(input)

def state_23(+input: Nat) -> C.Machine:
  data_243(input)

def state_24(+input: Nat) -> C.Machine:
  data_246(input)

def state_25(+input: Nat) -> C.Machine:
  data_249(input)

def state_26(+input: Nat) -> C.Machine:
  data_258(input)

def state_27(+input: Nat) -> C.Machine:
  data_260(input)

def state_28(+input: Nat) -> C.Machine:
  data_264(input)

def state_29(+input: Nat) -> C.Machine:
  data_271(input)

def state_30(+input: Nat) -> C.Machine:
  data_273(input)

def state_31(+input: Nat) -> C.Machine:
  data_276(input)

def state_32(+input: Nat) -> C.Machine:
  data_280(input)

def state_33(+input: Nat) -> C.Machine:
  data_286(input)

def state_34(+input: Nat) -> C.Machine:
  data_295(input)

def state_35(+input: Nat) -> C.Machine:
  data_297(input)

def state_36(+input: Nat) -> C.Machine:
  data_300(input)

def state_37(+input: Nat) -> C.Machine:
  data_305(input)

def state_38(+input: Nat) -> C.Machine:
  data_307(input)

def state_39(+input: Nat) -> C.Machine:
  data_310(input)

def state_40(+input: Nat) -> C.Machine:
  data_317(input)

def state_41(+input: Nat) -> C.Machine:
  data_320(input)

def state_42(+input: Nat) -> C.Machine:
  data_329(input)

def state_43(+input: Nat) -> C.Machine:
  data_333(input)

def state_44(+input: Nat) -> C.Machine:
  data_336(input)

def state_45(+input: Nat) -> C.Machine:
  data_339(input)

def state_46(+input: Nat) -> C.Machine:
  data_348(input)

def state_47(+input: Nat) -> C.Machine:
  data_350(input)

def state_48(+input: Nat) -> C.Machine:
  data_354(input)

def state_49(+input: Nat) -> C.Machine:
  data_361(input)

def state_50(+input: Nat) -> C.Machine:
  data_363(input)

def state_51(+input: Nat) -> C.Machine:
  data_365(input)

def state_52(+input: Nat) -> C.Machine:
  data_367(input)

def state_53(+input: Nat) -> C.Machine:
  data_377(input)

def state_54(+input: Nat) -> C.Machine:
  data_381(input)

def state_55(+input: Nat) -> C.Machine:
  data_387(input)

def state_56(+input: Nat) -> C.Machine:
  data_395(input)

def state_57(+input: Nat) -> C.Machine:
  data_397(input)

def state_58(+input: Nat) -> C.Machine:
  data_400(input)

def state_59(+input: Nat) -> C.Machine:
  data_401(input)

def state_60(+input: Nat) -> C.Machine:
  data_403(input)

def state_61(+input: Nat) -> C.Machine:
  data_407(input)

def state_62(+input: Nat) -> C.Machine:
  data_411(input)

def state_63(+input: Nat) -> C.Machine:
  data_416(input)

def state_64(+input: Nat) -> C.Machine:
  data_420(input)

def state_65(+input: Nat) -> C.Machine:
  data_425(input)

def state_66(+input: Nat) -> C.Machine:
  data_429(input)

def state_67(+input: Nat) -> C.Machine:
  data_435(input)

def state_68(+input: Nat) -> C.Machine:
  data_441(input)

def state_69(+input: Nat) -> C.Machine:
  data_445(input)

def state_70(+input: Nat) -> C.Machine:
  data_447(input)

def state_71(+input: Nat) -> C.Machine:
  data_449(input)

def state_72(+input: Nat) -> C.Machine:
  data_453(input)

def state_73(+input: Nat) -> C.Machine:
  data_459(input)

def state_74(+input: Nat) -> C.Machine:
  data_465(input)

def state_75(+input: Nat) -> C.Machine:
  data_467(input)

def state_76(+input: Nat) -> C.Machine:
  data_469(input)

def state_77(+input: Nat) -> C.Machine:
  data_471(input)

def state_78(+input: Nat) -> C.Machine:
  data_474(input)

def state_79(+input: Nat) -> C.Machine:
  data_476(input)

def state_80(+input: Nat) -> C.Machine:
  data_481(input)

def state_81(+input: Nat) -> C.Machine:
  data_484(input)

def state_82(+input: Nat) -> C.Machine:
  data_487(input)

def state_83(+input: Nat) -> C.Machine:
  data_489(input)

def state_84(+input: Nat) -> C.Machine:
  data_493(input)

def state_85(+input: Nat) -> C.Machine:
  data_498(input)

def state_86(+input: Nat) -> C.Machine:
  data_502(input)

def state_87(+input: Nat) -> C.Machine:
  data_510(input)

def state_88(+input: Nat) -> C.Machine:
  data_512(input)

def state_89(+input: Nat) -> C.Machine:
  data_521(input)

def state_90(+input: Nat) -> C.Machine:
  data_523(input)

def state_91(+input: Nat) -> C.Machine:
  data_525(input)

def state_92(+input: Nat) -> C.Machine:
  data_527(input)

def state_93(+input: Nat) -> C.Machine:
  data_529(input)

def state_94(+input: Nat) -> C.Machine:
  data_532(input)

def state_95(+input: Nat) -> C.Machine:
  data_534(input)

def finalWorld(+input: Nat) -> R.World:
  data_530(input)

def slot_13(+input: Nat) -> R.World:
  data_537(input)

def notify_13(+input: Nat) -> R.World:
  data_201(input)

def slot_33(+input: Nat) -> R.World:
  data_540(input)

def notify_33(+input: Nat) -> R.World:
  data_291(input)

def modified_55(+input: Nat) -> R.World:
  data_543(input)

def queued_55(+input: Nat) -> R.World:
  data_544(input)

def value_55(+input: Nat) -> R.World:
  data_391(input)

def setter_queued(+input: Nat) -> R.World:
  data_545()

def setter_slot(+input: Nat) -> R.World:
  data_548(input)

def setter_inserted(+input: Nat) -> R.World:
  data_549(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_121(input)

def setter_stamped(+input: Nat) -> R.World:
  data_551(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_555(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_549(input)

