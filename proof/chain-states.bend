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

def data_106() -> R.DeferredArena:
  R.DeferredArena{data_104(), data_35(), data_105()}

def data_107() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_108(+input: Nat) -> R.Value:
  R.Number{input}

def data_109(+input: Nat) -> R.Slot:
  R.Present{data_108(input)}

def data_110() -> R.Stamp:
  R.Stamped{7n}

def data_111(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_109(input), False{}, 0, 0, 0, 0n, data_110(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_112() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_113() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_114() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_115(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_112(), data_113(), data_114()]

def data_116() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_117() -> R.HostJob:
  R.FlushJob{}

def data_118() -> List<&2, R.HostJob>:
  [data_117()]

def data_119(+input: Nat) -> R.World:
  R.World{data_115(input), data_33(), data_116(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_120() -> C.Task:
  C.Round{}

def data_121() -> List<&2, C.Task>:
  [data_120()]

def data_122() -> List<&2, R.Value>:
  []

def data_123(+input: Nat) -> C.Machine:
  C.Machine{data_119(input), data_121(), data_122()}

def data_124(+input: Nat) -> R.World:
  R.World{data_115(input), data_33(), data_116(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_125() -> C.Task:
  C.RoundAfterSweep{}

def data_126() -> C.Task:
  C.FlushFinally{}

def data_127() -> C.Task:
  C.RoundEnd{}

def data_128() -> List<&2, C.Task>:
  [data_125(), data_126(), data_127()]

def data_129(+input: Nat) -> C.Machine:
  C.Machine{data_124(input), data_128(), data_122()}

def data_130(+input: Nat) -> R.World:
  R.World{data_115(input), data_33(), data_116(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_131() -> C.Task:
  C.HeapLoop{}

def data_132() -> List<&2, C.Task>:
  [data_131(), data_126(), data_127()]

def data_133(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_132(), data_122()}

def data_134() -> C.Task:
  C.Recompute{3n, False{}}

def data_135() -> List<&2, C.Task>:
  [data_134(), data_131(), data_126(), data_127()]

def data_136(+input: Nat) -> C.Machine:
  C.Machine{data_130(input), data_135(), data_122()}

def data_137() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_138(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_137(), data_113(), data_114()]

def data_139() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_140() -> R.LaneMount:
  R.MountFalse{}

def data_141() -> R.LaneState:
  R.LaneState{data_35(), data_65(), data_35(), data_97(), 0n, data_140()}

def data_142(+input: Nat) -> R.World:
  R.World{data_138(input), data_33(), data_139(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_143() -> C.LanePass:
  C.LanePass{0n, data_98(), data_140()}

def data_144() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_143()}

def data_145() -> List<&2, C.Task>:
  [data_144(), data_131(), data_126(), data_127()]

def data_146(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_145(), data_122()}

def data_147() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_143()}

def data_148() -> List<&2, C.Task>:
  [data_147(), data_131(), data_126(), data_127()]

def data_149(+input: Nat) -> C.Machine:
  C.Machine{data_142(input), data_148(), data_122()}

def data_150() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_151(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_150(), data_113(), data_114()]

def data_152() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_153(+input: Nat) -> R.World:
  R.World{data_151(input), data_33(), data_139(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_152(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_154() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_155() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_122(), 0n, False{}, data_143()}

def data_156() -> C.Task:
  C.Finish{data_155()}

def data_157() -> List<&2, C.Task>:
  [data_154(), data_156(), data_131(), data_126(), data_127()]

def data_158(+input: Nat) -> C.Machine:
  C.Machine{data_153(input), data_157(), data_122()}

def data_159() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_160() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_161() -> C.Task:
  C.Binary{0}

def data_162() -> List<&2, C.Task>:
  [data_159(), data_160(), data_161(), data_156(), data_131(), data_126(), data_127()]

def data_163(+input: Nat) -> C.Machine:
  C.Machine{data_153(input), data_162(), data_122()}

def data_164() -> C.Task:
  C.ReadNode{2n}

def data_165() -> List<&2, C.Task>:
  [data_164(), data_160(), data_161(), data_156(), data_131(), data_126(), data_127()]

def data_166(+input: Nat) -> C.Machine:
  C.Machine{data_153(input), data_165(), data_122()}

def data_167() -> C.Task:
  C.ReadPrepared{2n}

def data_168() -> List<&2, C.Task>:
  [data_167(), data_160(), data_161(), data_156(), data_131(), data_126(), data_127()]

def data_169(+input: Nat) -> C.Machine:
  C.Machine{data_153(input), data_168(), data_122()}

def data_170() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_171(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_170(), data_113(), data_114()]

def data_172() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_173() -> List<&2, R.Link>:
  [data_28(), data_172(), data_30(), data_31(), data_32()]

def data_174(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_108(input)}

def data_175(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input)]

def data_176(+input: Nat) -> R.World:
  R.World{data_171(input), data_173(), data_139(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_177() -> List<&2, C.Task>:
  [data_160(), data_161(), data_156(), data_131(), data_126(), data_127()]

def data_178(+input: Nat) -> List<&2, R.Value>:
  [data_108(input)]

def data_179(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_177(), data_178(input)}

def data_180() -> List<&2, C.Task>:
  [data_161(), data_156(), data_131(), data_126(), data_127()]

def data_181(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_108(input)]

def data_182(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_180(), data_181(input)}

def data_183() -> List<&2, C.Task>:
  [data_156(), data_131(), data_126(), data_127()]

def data_184(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_185(+input: Nat) -> List<&2, R.Value>:
  [data_184(input)]

def data_186(+input: Nat) -> C.Machine:
  C.Machine{data_176(input), data_183(), data_185(input)}

def data_187() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_188(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_187(), data_113(), data_114()]

def data_189(+input: Nat) -> R.World:
  R.World{data_188(input), data_173(), data_139(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_190(+input: Nat) -> C.Task:
  C.PassReleases{data_155(), 0n, data_184(input), False{}, False{}, False{}, data_53()}

def data_191(+input: Nat) -> List<&2, C.Task>:
  [data_190(input), data_131(), data_126(), data_127()]

def data_192(+input: Nat) -> C.Machine:
  C.Machine{data_189(input), data_191(input), data_122()}

def data_193(+input: Nat) -> R.Slot:
  R.Present{data_184(input)}

def data_194() -> R.Stamp:
  R.Stamped{8n}

def data_195(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_193(input), False{}, 0, 16384, 0, 0n, data_194(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_196() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_197(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_195(input), data_196(), data_114()]

def data_198() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_199(+input: Nat) -> R.World:
  R.World{data_197(input), data_173(), data_198(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_200() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_201() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_202() -> List<&2, C.Task>:
  [data_200(), data_201(), data_131(), data_126(), data_127()]

def data_203(+input: Nat) -> C.Machine:
  C.Machine{data_199(input), data_202(), data_122()}

def data_204() -> List<&2, C.Task>:
  [data_201(), data_131(), data_126(), data_127()]

def data_205(+input: Nat) -> C.Machine:
  C.Machine{data_199(input), data_204(), data_122()}

def data_206() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_207() -> List<&2, C.Task>:
  [data_206(), data_131(), data_126(), data_127()]

def data_208(+input: Nat) -> C.Machine:
  C.Machine{data_199(input), data_207(), data_122()}

def data_209(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_193(input), False{}, 128, 16384, 0, 0n, data_194(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_210(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_196(), data_114()]

def data_211() -> List<&2, Nat>:
  [2n, 3n]

def data_212(+input: Nat) -> R.World:
  R.World{data_210(input), data_173(), data_198(), 0n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_212(input), data_132(), data_122()}

def data_214(+input: Nat) -> R.World:
  R.World{data_210(input), data_173(), data_198(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_132(), data_122()}

def data_216() -> C.Task:
  C.Recompute{4n, False{}}

def data_217() -> List<&2, C.Task>:
  [data_216(), data_131(), data_126(), data_127()]

def data_218(+input: Nat) -> C.Machine:
  C.Machine{data_214(input), data_217(), data_122()}

def data_219() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_220(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_219(), data_114()]

def data_221(+input: Nat) -> R.World:
  R.World{data_220(input), data_173(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_222() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_143()}

def data_223() -> List<&2, C.Task>:
  [data_222(), data_131(), data_126(), data_127()]

def data_224(+input: Nat) -> C.Machine:
  C.Machine{data_221(input), data_223(), data_122()}

def data_225() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_143()}

def data_226() -> List<&2, C.Task>:
  [data_225(), data_131(), data_126(), data_127()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_221(input), data_226(), data_122()}

def data_228() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_229(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_228(), data_114()]

def data_230(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45()]

def data_231(+input: Nat) -> R.World:
  R.World{data_229(input), data_173(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_230(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_232() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_233() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_122(), 0n, False{}, data_143()}

def data_234() -> C.Task:
  C.Finish{data_233()}

def data_235() -> List<&2, C.Task>:
  [data_232(), data_234(), data_131(), data_126(), data_127()]

def data_236(+input: Nat) -> C.Machine:
  C.Machine{data_231(input), data_235(), data_122()}

def data_237() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_238() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_239() -> C.Task:
  C.Binary{1}

def data_240() -> List<&2, C.Task>:
  [data_237(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_241(+input: Nat) -> C.Machine:
  C.Machine{data_231(input), data_240(), data_122()}

def data_242() -> C.Task:
  C.ReadNode{3n}

def data_243() -> List<&2, C.Task>:
  [data_242(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_244(+input: Nat) -> C.Machine:
  C.Machine{data_231(input), data_243(), data_122()}

def data_245() -> C.Task:
  C.ReadPrepared{3n}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_231(input), data_246(), data_122()}

def data_248() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_249(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_248(), data_114()]

def data_250() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_251() -> List<&2, R.Link>:
  [data_28(), data_172(), data_250(), data_31(), data_32()]

def data_252(+input: Nat) -> R.World:
  R.World{data_249(input), data_251(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_230(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_253() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_254() -> C.Task:
  C.ReadStatus{3n}

def data_255() -> List<&2, C.Task>:
  [data_253(), data_254(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_256(+input: Nat) -> C.Machine:
  C.Machine{data_252(input), data_255(), data_122()}

def data_257() -> List<&2, C.Task>:
  [data_254(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_258(+input: Nat) -> C.Machine:
  C.Machine{data_252(input), data_257(), data_122()}

def data_259() -> C.Task:
  C.Serve{3n}

def data_260() -> C.Task:
  C.AfterServe{3n}

def data_261() -> List<&2, C.Task>:
  [data_259(), data_260(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_252(input), data_261(), data_122()}

def data_263() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_264(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_263(), data_114()]

def data_265(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_184(input)}

def data_266(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45(), data_265(input)]

def data_267(+input: Nat) -> R.World:
  R.World{data_264(input), data_251(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_268() -> List<&2, C.Task>:
  [data_260(), data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_269(+input: Nat) -> C.Machine:
  C.Machine{data_267(input), data_268(), data_185(input)}

def data_270() -> List<&2, C.Task>:
  [data_238(), data_239(), data_234(), data_131(), data_126(), data_127()]

def data_271(+input: Nat) -> C.Machine:
  C.Machine{data_267(input), data_270(), data_185(input)}

def data_272() -> List<&2, C.Task>:
  [data_239(), data_234(), data_131(), data_126(), data_127()]

def data_273(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_184(input)]

def data_274(+input: Nat) -> C.Machine:
  C.Machine{data_267(input), data_272(), data_273(input)}

def data_275() -> List<&2, C.Task>:
  [data_234(), data_131(), data_126(), data_127()]

def data_276(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_277(+input: Nat) -> List<&2, R.Value>:
  [data_276(input)]

def data_278(+input: Nat) -> C.Machine:
  C.Machine{data_267(input), data_275(), data_277(input)}

def data_279() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_280(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_279(), data_114()]

def data_281(+input: Nat) -> R.World:
  R.World{data_280(input), data_251(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_282(+input: Nat) -> C.Task:
  C.PassReleases{data_233(), 0n, data_276(input), False{}, False{}, False{}, data_53()}

def data_283(+input: Nat) -> List<&2, C.Task>:
  [data_282(input), data_131(), data_126(), data_127()]

def data_284(+input: Nat) -> C.Machine:
  C.Machine{data_281(input), data_283(input), data_122()}

def data_285(+input: Nat) -> R.Slot:
  R.Present{data_276(input)}

def data_286() -> R.Stamp:
  R.Stamped{9n}

def data_287(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_285(input), False{}, 0, 16384, 0, 0n, data_286(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_288(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_287(input), data_114()]

def data_289(+input: Nat) -> R.World:
  R.World{data_288(input), data_251(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_290() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_291() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_292() -> List<&2, C.Task>:
  [data_290(), data_291(), data_131(), data_126(), data_127()]

def data_293(+input: Nat) -> C.Machine:
  C.Machine{data_289(input), data_292(), data_122()}

def data_294() -> List<&2, C.Task>:
  [data_291(), data_131(), data_126(), data_127()]

def data_295(+input: Nat) -> C.Machine:
  C.Machine{data_289(input), data_294(), data_122()}

def data_296() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_297() -> List<&2, C.Task>:
  [data_296(), data_131(), data_126(), data_127()]

def data_298(+input: Nat) -> C.Machine:
  C.Machine{data_289(input), data_297(), data_122()}

def data_299(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_285(input), False{}, 128, 16384, 0, 0n, data_286(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_300(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_114()]

def data_301() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_302(+input: Nat) -> R.World:
  R.World{data_300(input), data_251(), data_139(), 1n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_303(+input: Nat) -> C.Machine:
  C.Machine{data_302(input), data_132(), data_122()}

def data_304(+input: Nat) -> R.World:
  R.World{data_300(input), data_251(), data_139(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_305(+input: Nat) -> C.Machine:
  C.Machine{data_304(input), data_132(), data_122()}

def data_306() -> C.Task:
  C.Recompute{5n, False{}}

def data_307() -> List<&2, C.Task>:
  [data_306(), data_131(), data_126(), data_127()]

def data_308(+input: Nat) -> C.Machine:
  C.Machine{data_304(input), data_307(), data_122()}

def data_309() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_310(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_309()]

def data_311() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_312(+input: Nat) -> R.World:
  R.World{data_310(input), data_251(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_313() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_143()}

def data_314() -> List<&2, C.Task>:
  [data_313(), data_131(), data_126(), data_127()]

def data_315(+input: Nat) -> C.Machine:
  C.Machine{data_312(input), data_314(), data_122()}

def data_316() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_143()}

def data_317() -> List<&2, C.Task>:
  [data_316(), data_131(), data_126(), data_127()]

def data_318(+input: Nat) -> C.Machine:
  C.Machine{data_312(input), data_317(), data_122()}

def data_319() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_320(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_319()]

def data_321(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45(), data_265(input), data_48()]

def data_322(+input: Nat) -> R.World:
  R.World{data_320(input), data_251(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_321(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_323() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_324() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_122(), 0n, False{}, data_143()}

def data_325() -> C.Task:
  C.Finish{data_324()}

def data_326() -> List<&2, C.Task>:
  [data_323(), data_325(), data_131(), data_126(), data_127()]

def data_327(+input: Nat) -> C.Machine:
  C.Machine{data_322(input), data_326(), data_122()}

def data_328() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_329() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_330() -> List<&2, C.Task>:
  [data_328(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_331(+input: Nat) -> C.Machine:
  C.Machine{data_322(input), data_330(), data_122()}

def data_332() -> C.Task:
  C.ReadNode{4n}

def data_333() -> List<&2, C.Task>:
  [data_332(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_334(+input: Nat) -> C.Machine:
  C.Machine{data_322(input), data_333(), data_122()}

def data_335() -> C.Task:
  C.ReadPrepared{4n}

def data_336() -> List<&2, C.Task>:
  [data_335(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_337(+input: Nat) -> C.Machine:
  C.Machine{data_322(input), data_336(), data_122()}

def data_338() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_339(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_338()]

def data_340() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_341() -> List<&2, R.Link>:
  [data_28(), data_172(), data_250(), data_340(), data_32()]

def data_342(+input: Nat) -> R.World:
  R.World{data_339(input), data_341(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_321(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_343() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_344() -> C.Task:
  C.ReadStatus{4n}

def data_345() -> List<&2, C.Task>:
  [data_343(), data_344(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_346(+input: Nat) -> C.Machine:
  C.Machine{data_342(input), data_345(), data_122()}

def data_347() -> List<&2, C.Task>:
  [data_344(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_348(+input: Nat) -> C.Machine:
  C.Machine{data_342(input), data_347(), data_122()}

def data_349() -> C.Task:
  C.Serve{4n}

def data_350() -> C.Task:
  C.AfterServe{4n}

def data_351() -> List<&2, C.Task>:
  [data_349(), data_350(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_342(input), data_351(), data_122()}

def data_353() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_354(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_353()]

def data_355(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_276(input)}

def data_356(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45(), data_265(input), data_48(), data_355(input)]

def data_357(+input: Nat) -> R.World:
  R.World{data_354(input), data_341(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_356(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_358() -> List<&2, C.Task>:
  [data_350(), data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_359(+input: Nat) -> C.Machine:
  C.Machine{data_357(input), data_358(), data_277(input)}

def data_360() -> List<&2, C.Task>:
  [data_329(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_361(+input: Nat) -> C.Machine:
  C.Machine{data_357(input), data_360(), data_277(input)}

def data_362() -> List<&2, C.Task>:
  [data_164(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_363(+input: Nat) -> C.Machine:
  C.Machine{data_357(input), data_362(), data_277(input)}

def data_364() -> List<&2, C.Task>:
  [data_167(), data_161(), data_325(), data_131(), data_126(), data_127()]

def data_365(+input: Nat) -> C.Machine:
  C.Machine{data_357(input), data_364(), data_277(input)}

def data_366() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_367(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_366()]

def data_368() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_369() -> List<&2, R.Link>:
  [data_28(), data_172(), data_250(), data_340(), data_368()]

def data_370(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_108(input)}

def data_371(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45(), data_265(input), data_48(), data_355(input), data_370(input)]

def data_372(+input: Nat) -> R.World:
  R.World{data_367(input), data_369(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_141(), data_100(), data_2(), data_35(), data_106()}

def data_373() -> List<&2, C.Task>:
  [data_161(), data_325(), data_131(), data_126(), data_127()]

def data_374(+input: Nat) -> List<&2, R.Value>:
  [data_108(input), data_276(input)]

def data_375(+input: Nat) -> C.Machine:
  C.Machine{data_372(input), data_373(), data_374(input)}

def data_376() -> List<&2, C.Task>:
  [data_325(), data_131(), data_126(), data_127()]

def data_377(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_378(+input: Nat) -> List<&2, R.Value>:
  [data_377(input)]

def data_379(+input: Nat) -> C.Machine:
  C.Machine{data_372(input), data_376(), data_378(input)}

def data_380() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_381(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_380()]

def data_382(+input: Nat) -> R.World:
  R.World{data_381(input), data_369(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_383(+input: Nat) -> C.Task:
  C.PassReleases{data_324(), 0n, data_377(input), False{}, False{}, False{}, data_53()}

def data_384(+input: Nat) -> List<&2, C.Task>:
  [data_383(input), data_131(), data_126(), data_127()]

def data_385(+input: Nat) -> C.Machine:
  C.Machine{data_382(input), data_384(input), data_122()}

def data_386(+input: Nat) -> R.Node:
  R.Node{data_23(), data_377(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_387(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_386(input)]

def data_388() -> List<&2, Nat>:
  [5n]

def data_389(+input: Nat) -> R.World:
  R.World{data_387(input), data_369(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_390() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_391() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_392() -> List<&2, C.Task>:
  [data_390(), data_391(), data_131(), data_126(), data_127()]

def data_393(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_392(), data_122()}

def data_394() -> List<&2, C.Task>:
  [data_391(), data_131(), data_126(), data_127()]

def data_395(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_394(), data_122()}

def data_396() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_397() -> List<&2, C.Task>:
  [data_396(), data_131(), data_126(), data_127()]

def data_398(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_397(), data_122()}

def data_399(+input: Nat) -> C.Machine:
  C.Machine{data_389(input), data_132(), data_122()}

def data_400(+input: Nat) -> R.World:
  R.World{data_387(input), data_369(), data_311(), 3n, 2n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_401(+input: Nat) -> C.Machine:
  C.Machine{data_400(input), data_132(), data_122()}

def data_402(+input: Nat) -> R.World:
  R.World{data_387(input), data_369(), data_311(), 3n, 0n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_403() -> C.Task:
  C.Seam{}

def data_404() -> List<&2, C.Task>:
  [data_403(), data_126(), data_127()]

def data_405(+input: Nat) -> C.Machine:
  C.Machine{data_402(input), data_404(), data_122()}

def data_406() -> C.Task:
  C.Settle{}

def data_407() -> C.Task:
  C.AfterSettle{}

def data_408() -> List<&2, C.Task>:
  [data_406(), data_407(), data_126(), data_127()]

def data_409(+input: Nat) -> C.Machine:
  C.Machine{data_402(input), data_408(), data_122()}

def data_410() -> C.Task:
  C.CommitIntake{0n}

def data_411() -> C.Task:
  C.TrimIntake{0n}

def data_412() -> C.Task:
  C.FinishSettleIntake{0n}

def data_413() -> List<&2, C.Task>:
  [data_410(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_414(+input: Nat) -> C.Machine:
  C.Machine{data_402(input), data_413(), data_122()}

def data_415() -> C.Task:
  C.CommitPending{2n}

def data_416() -> C.Task:
  C.CommitIntake{1n}

def data_417() -> List<&2, C.Task>:
  [data_415(), data_416(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_418(+input: Nat) -> C.Machine:
  C.Machine{data_402(input), data_417(), data_122()}

def data_419(+input: Nat) -> R.Node:
  R.Node{data_9(), data_108(input), data_2(), False{}, 0, 0, 0, 0n, data_110(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_420(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_419(input), data_209(input), data_299(input), data_386(input)]

def data_421(+input: Nat) -> R.World:
  R.World{data_420(input), data_369(), data_311(), 3n, 0n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_422() -> List<&2, C.Task>:
  [data_416(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_423(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_422(), data_122()}

def data_424() -> C.Task:
  C.CommitPending{3n}

def data_425() -> C.Task:
  C.CommitIntake{2n}

def data_426() -> List<&2, C.Task>:
  [data_424(), data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_427(+input: Nat) -> C.Machine:
  C.Machine{data_421(input), data_426(), data_122()}

def data_428(+input: Nat) -> R.Node:
  R.Node{data_12(), data_184(input), data_2(), False{}, 0, 16384, 0, 0n, data_194(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_429(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_419(input), data_428(input), data_299(input), data_386(input)]

def data_430(+input: Nat) -> R.World:
  R.World{data_429(input), data_369(), data_311(), 3n, 0n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_431() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_432() -> List<&2, C.Task>:
  [data_431(), data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_433(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_432(), data_122()}

def data_434() -> O.Task:
  O.TrimDeps{3n}

def data_435() -> List<&2, O.Task>:
  [data_434()]

def data_436() -> C.Task:
  C.OwnerTasks{data_435()}

def data_437() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_438() -> List<&2, C.Task>:
  [data_436(), data_437(), data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_439(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_438(), data_122()}

def data_440() -> List<&2, O.Task>:
  []

def data_441() -> C.Task:
  C.OwnerTasks{data_440()}

def data_442() -> List<&2, C.Task>:
  [data_441(), data_437(), data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_443(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_442(), data_122()}

def data_444() -> List<&2, C.Task>:
  [data_437(), data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_445(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_444(), data_122()}

def data_446() -> List<&2, C.Task>:
  [data_425(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_447(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_446(), data_122()}

def data_448() -> C.Task:
  C.CommitPending{4n}

def data_449() -> C.Task:
  C.CommitIntake{3n}

def data_450() -> List<&2, C.Task>:
  [data_448(), data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_430(input), data_450(), data_122()}

def data_452(+input: Nat) -> R.Node:
  R.Node{data_12(), data_276(input), data_2(), False{}, 0, 16384, 0, 0n, data_286(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_453(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_419(input), data_428(input), data_452(input), data_386(input)]

def data_454(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_455() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_456() -> List<&2, C.Task>:
  [data_455(), data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_457(+input: Nat) -> C.Machine:
  C.Machine{data_454(input), data_456(), data_122()}

def data_458() -> O.Task:
  O.TrimDeps{4n}

def data_459() -> List<&2, O.Task>:
  [data_458()]

def data_460() -> C.Task:
  C.OwnerTasks{data_459()}

def data_461() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_462() -> List<&2, C.Task>:
  [data_460(), data_461(), data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_463(+input: Nat) -> C.Machine:
  C.Machine{data_454(input), data_462(), data_122()}

def data_464() -> List<&2, C.Task>:
  [data_441(), data_461(), data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_465(+input: Nat) -> C.Machine:
  C.Machine{data_454(input), data_464(), data_122()}

def data_466() -> List<&2, C.Task>:
  [data_461(), data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_467(+input: Nat) -> C.Machine:
  C.Machine{data_454(input), data_466(), data_122()}

def data_468() -> List<&2, C.Task>:
  [data_449(), data_411(), data_412(), data_407(), data_126(), data_127()]

def data_469(+input: Nat) -> C.Machine:
  C.Machine{data_454(input), data_468(), data_122()}

def data_470(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_471() -> List<&2, C.Task>:
  [data_411(), data_412(), data_407(), data_126(), data_127()]

def data_472(+input: Nat) -> C.Machine:
  C.Machine{data_470(input), data_471(), data_122()}

def data_473() -> List<&2, C.Task>:
  [data_412(), data_407(), data_126(), data_127()]

def data_474(+input: Nat) -> C.Machine:
  C.Machine{data_470(input), data_473(), data_122()}

def data_475(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_476() -> C.SeamFrame:
  C.SeamFrame{0n, data_388(), data_36(), data_35(), data_36()}

def data_477() -> C.Task:
  C.LandTransactions{data_476(), 0n}

def data_478() -> List<&2, C.Task>:
  [data_477(), data_407(), data_126(), data_127()]

def data_479(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_478(), data_122()}

def data_480() -> C.Task:
  C.CompleteSettle{data_476()}

def data_481() -> List<&2, C.Task>:
  [data_480(), data_407(), data_126(), data_127()]

def data_482(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_481(), data_122()}

def data_483() -> C.Task:
  C.ZombieLoop{data_35()}

def data_484() -> List<&2, C.Task>:
  [data_483(), data_407(), data_126(), data_127()]

def data_485(+input: Nat) -> C.Machine:
  C.Machine{data_470(input), data_484(), data_122()}

def data_486() -> List<&2, C.Task>:
  [data_407(), data_126(), data_127()]

def data_487(+input: Nat) -> C.Machine:
  C.Machine{data_470(input), data_486(), data_122()}

def data_488(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_388(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_489() -> C.Task:
  C.RenderQueue{}

def data_490() -> List<&2, C.Task>:
  [data_489(), data_126(), data_127()]

def data_491(+input: Nat) -> C.Machine:
  C.Machine{data_488(input), data_490(), data_122()}

def data_492(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_493() -> C.Task:
  C.RunEffect{5n}

def data_494() -> C.Task:
  C.UserQueue{}

def data_495() -> List<&2, C.Task>:
  [data_493(), data_494(), data_126(), data_127()]

def data_496(+input: Nat) -> C.Machine:
  C.Machine{data_492(input), data_495(), data_122()}

def data_497() -> C.Task:
  C.ApplyEffect{5n}

def data_498() -> C.Task:
  C.EffectFinally{5n, True{}, data_122()}

def data_499() -> List<&2, C.Task>:
  [data_497(), data_498(), data_494(), data_126(), data_127()]

def data_500(+input: Nat) -> C.Machine:
  C.Machine{data_492(input), data_499(), data_122()}

def data_501(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_377(input)}

def data_502(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_501(input)]

def data_503(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_377(input), data_18()}

def data_504(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_174(input), data_45(), data_265(input), data_48(), data_355(input), data_370(input), data_503(input)]

def data_505(+input: Nat) -> R.World:
  R.World{data_453(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_502(input), data_504(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_506() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_507() -> List<&2, C.Task>:
  [data_506(), data_498(), data_494(), data_126(), data_127()]

def data_508(+input: Nat) -> C.Machine:
  C.Machine{data_505(input), data_507(), data_122()}

def data_509() -> List<&2, C.Task>:
  [data_498(), data_494(), data_126(), data_127()]

def data_510(+input: Nat) -> C.Machine:
  C.Machine{data_505(input), data_509(), data_122()}

def data_511(+input: Nat) -> R.Node:
  R.Node{data_23(), data_377(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_377(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_512(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_419(input), data_428(input), data_452(input), data_511(input)]

def data_513(+input: Nat) -> R.World:
  R.World{data_512(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_502(input), data_504(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_514() -> O.Task:
  O.TrimDeps{5n}

def data_515() -> List<&2, O.Task>:
  [data_514()]

def data_516() -> C.Task:
  C.OwnerTasks{data_515()}

def data_517() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_122()}

def data_518() -> List<&2, C.Task>:
  [data_516(), data_517(), data_494(), data_126(), data_127()]

def data_519(+input: Nat) -> C.Machine:
  C.Machine{data_513(input), data_518(), data_122()}

def data_520() -> List<&2, C.Task>:
  [data_441(), data_517(), data_494(), data_126(), data_127()]

def data_521(+input: Nat) -> C.Machine:
  C.Machine{data_513(input), data_520(), data_122()}

def data_522() -> List<&2, C.Task>:
  [data_517(), data_494(), data_126(), data_127()]

def data_523(+input: Nat) -> C.Machine:
  C.Machine{data_513(input), data_522(), data_122()}

def data_524() -> List<&2, C.Task>:
  [data_494(), data_126(), data_127()]

def data_525(+input: Nat) -> C.Machine:
  C.Machine{data_513(input), data_524(), data_122()}

def data_526() -> List<&2, C.Task>:
  [data_126(), data_127()]

def data_527(+input: Nat) -> C.Machine:
  C.Machine{data_513(input), data_526(), data_122()}

def data_528(+input: Nat) -> R.World:
  R.World{data_512(input), data_369(), data_311(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_502(input), data_504(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_529() -> List<&2, C.Task>:
  [data_127()]

def data_530(+input: Nat) -> C.Machine:
  C.Machine{data_528(input), data_529(), data_122()}

def data_531() -> List<&2, C.Task>:
  []

def data_532(+input: Nat) -> C.Machine:
  C.Machine{data_528(input), data_531(), data_122()}

def data_533(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_193(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_534(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_533(input), data_113(), data_114()]

def data_535(+input: Nat) -> R.World:
  R.World{data_534(input), data_173(), data_139(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_175(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_536(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_285(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_537(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_536(input), data_114()]

def data_538(+input: Nat) -> R.World:
  R.World{data_537(input), data_251(), data_139(), 1n, 2n, False{}, data_211(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_266(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_539() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_540(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_209(input), data_299(input), data_539()]

def data_541(+input: Nat) -> R.World:
  R.World{data_540(input), data_369(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_542(+input: Nat) -> R.World:
  R.World{data_540(input), data_369(), data_311(), 2n, 2n, False{}, data_301(), data_35(), data_388(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_371(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_118(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_543() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_544(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_109(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_545(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_544(input), data_17(), data_22(), data_26()]

def data_546(+input: Nat) -> R.World:
  R.World{data_545(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_547(+input: Nat) -> R.World:
  R.World{data_115(input), data_33(), data_116(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_548(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_17(), data_22(), data_26()]

def data_549(+input: Nat) -> R.World:
  R.World{data_548(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def data_550() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_551(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_111(input), data_112(), data_113(), data_550()]

def data_552() -> List<&2, Nat>:
  [3n]

def data_553(+input: Nat) -> R.World:
  R.World{data_551(input), data_33(), data_552(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_99(), data_100(), data_2(), data_35(), data_106()}

def origin() -> R.World:
  data_107()

def state_0(+input: Nat) -> C.Machine:
  data_123(input)

def state_1(+input: Nat) -> C.Machine:
  data_129(input)

def state_2(+input: Nat) -> C.Machine:
  data_133(input)

def state_3(+input: Nat) -> C.Machine:
  data_136(input)

def state_4(+input: Nat) -> C.Machine:
  data_146(input)

def state_5(+input: Nat) -> C.Machine:
  data_149(input)

def state_6(+input: Nat) -> C.Machine:
  data_158(input)

def state_7(+input: Nat) -> C.Machine:
  data_163(input)

def state_8(+input: Nat) -> C.Machine:
  data_166(input)

def state_9(+input: Nat) -> C.Machine:
  data_169(input)

def state_10(+input: Nat) -> C.Machine:
  data_179(input)

def state_11(+input: Nat) -> C.Machine:
  data_182(input)

def state_12(+input: Nat) -> C.Machine:
  data_186(input)

def state_13(+input: Nat) -> C.Machine:
  data_192(input)

def state_14(+input: Nat) -> C.Machine:
  data_203(input)

def state_15(+input: Nat) -> C.Machine:
  data_205(input)

def state_16(+input: Nat) -> C.Machine:
  data_208(input)

def state_17(+input: Nat) -> C.Machine:
  data_213(input)

def state_18(+input: Nat) -> C.Machine:
  data_215(input)

def state_19(+input: Nat) -> C.Machine:
  data_218(input)

def state_20(+input: Nat) -> C.Machine:
  data_224(input)

def state_21(+input: Nat) -> C.Machine:
  data_227(input)

def state_22(+input: Nat) -> C.Machine:
  data_236(input)

def state_23(+input: Nat) -> C.Machine:
  data_241(input)

def state_24(+input: Nat) -> C.Machine:
  data_244(input)

def state_25(+input: Nat) -> C.Machine:
  data_247(input)

def state_26(+input: Nat) -> C.Machine:
  data_256(input)

def state_27(+input: Nat) -> C.Machine:
  data_258(input)

def state_28(+input: Nat) -> C.Machine:
  data_262(input)

def state_29(+input: Nat) -> C.Machine:
  data_269(input)

def state_30(+input: Nat) -> C.Machine:
  data_271(input)

def state_31(+input: Nat) -> C.Machine:
  data_274(input)

def state_32(+input: Nat) -> C.Machine:
  data_278(input)

def state_33(+input: Nat) -> C.Machine:
  data_284(input)

def state_34(+input: Nat) -> C.Machine:
  data_293(input)

def state_35(+input: Nat) -> C.Machine:
  data_295(input)

def state_36(+input: Nat) -> C.Machine:
  data_298(input)

def state_37(+input: Nat) -> C.Machine:
  data_303(input)

def state_38(+input: Nat) -> C.Machine:
  data_305(input)

def state_39(+input: Nat) -> C.Machine:
  data_308(input)

def state_40(+input: Nat) -> C.Machine:
  data_315(input)

def state_41(+input: Nat) -> C.Machine:
  data_318(input)

def state_42(+input: Nat) -> C.Machine:
  data_327(input)

def state_43(+input: Nat) -> C.Machine:
  data_331(input)

def state_44(+input: Nat) -> C.Machine:
  data_334(input)

def state_45(+input: Nat) -> C.Machine:
  data_337(input)

def state_46(+input: Nat) -> C.Machine:
  data_346(input)

def state_47(+input: Nat) -> C.Machine:
  data_348(input)

def state_48(+input: Nat) -> C.Machine:
  data_352(input)

def state_49(+input: Nat) -> C.Machine:
  data_359(input)

def state_50(+input: Nat) -> C.Machine:
  data_361(input)

def state_51(+input: Nat) -> C.Machine:
  data_363(input)

def state_52(+input: Nat) -> C.Machine:
  data_365(input)

def state_53(+input: Nat) -> C.Machine:
  data_375(input)

def state_54(+input: Nat) -> C.Machine:
  data_379(input)

def state_55(+input: Nat) -> C.Machine:
  data_385(input)

def state_56(+input: Nat) -> C.Machine:
  data_393(input)

def state_57(+input: Nat) -> C.Machine:
  data_395(input)

def state_58(+input: Nat) -> C.Machine:
  data_398(input)

def state_59(+input: Nat) -> C.Machine:
  data_399(input)

def state_60(+input: Nat) -> C.Machine:
  data_401(input)

def state_61(+input: Nat) -> C.Machine:
  data_405(input)

def state_62(+input: Nat) -> C.Machine:
  data_409(input)

def state_63(+input: Nat) -> C.Machine:
  data_414(input)

def state_64(+input: Nat) -> C.Machine:
  data_418(input)

def state_65(+input: Nat) -> C.Machine:
  data_423(input)

def state_66(+input: Nat) -> C.Machine:
  data_427(input)

def state_67(+input: Nat) -> C.Machine:
  data_433(input)

def state_68(+input: Nat) -> C.Machine:
  data_439(input)

def state_69(+input: Nat) -> C.Machine:
  data_443(input)

def state_70(+input: Nat) -> C.Machine:
  data_445(input)

def state_71(+input: Nat) -> C.Machine:
  data_447(input)

def state_72(+input: Nat) -> C.Machine:
  data_451(input)

def state_73(+input: Nat) -> C.Machine:
  data_457(input)

def state_74(+input: Nat) -> C.Machine:
  data_463(input)

def state_75(+input: Nat) -> C.Machine:
  data_465(input)

def state_76(+input: Nat) -> C.Machine:
  data_467(input)

def state_77(+input: Nat) -> C.Machine:
  data_469(input)

def state_78(+input: Nat) -> C.Machine:
  data_472(input)

def state_79(+input: Nat) -> C.Machine:
  data_474(input)

def state_80(+input: Nat) -> C.Machine:
  data_479(input)

def state_81(+input: Nat) -> C.Machine:
  data_482(input)

def state_82(+input: Nat) -> C.Machine:
  data_485(input)

def state_83(+input: Nat) -> C.Machine:
  data_487(input)

def state_84(+input: Nat) -> C.Machine:
  data_491(input)

def state_85(+input: Nat) -> C.Machine:
  data_496(input)

def state_86(+input: Nat) -> C.Machine:
  data_500(input)

def state_87(+input: Nat) -> C.Machine:
  data_508(input)

def state_88(+input: Nat) -> C.Machine:
  data_510(input)

def state_89(+input: Nat) -> C.Machine:
  data_519(input)

def state_90(+input: Nat) -> C.Machine:
  data_521(input)

def state_91(+input: Nat) -> C.Machine:
  data_523(input)

def state_92(+input: Nat) -> C.Machine:
  data_525(input)

def state_93(+input: Nat) -> C.Machine:
  data_527(input)

def state_94(+input: Nat) -> C.Machine:
  data_530(input)

def state_95(+input: Nat) -> C.Machine:
  data_532(input)

def finalWorld(+input: Nat) -> R.World:
  data_528(input)

def slot_13(+input: Nat) -> R.World:
  data_535(input)

def notify_13(+input: Nat) -> R.World:
  data_199(input)

def slot_33(+input: Nat) -> R.World:
  data_538(input)

def notify_33(+input: Nat) -> R.World:
  data_289(input)

def modified_55(+input: Nat) -> R.World:
  data_541(input)

def queued_55(+input: Nat) -> R.World:
  data_542(input)

def value_55(+input: Nat) -> R.World:
  data_389(input)

def setter_queued(+input: Nat) -> R.World:
  data_543()

def setter_slot(+input: Nat) -> R.World:
  data_546(input)

def setter_inserted(+input: Nat) -> R.World:
  data_547(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_119(input)

def setter_stamped(+input: Nat) -> R.World:
  data_549(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_553(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_547(input)

