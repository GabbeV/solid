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
  R.CleanupProgram{data_58(), False{}}

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

def data_96() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_97(+input: Nat) -> R.Value:
  R.Number{input}

def data_98(+input: Nat) -> R.Slot:
  R.Present{data_97(input)}

def data_99() -> R.Stamp:
  R.Stamped{7n}

def data_100(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_98(input), False{}, 0, 0, 0, 0n, data_99(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_101() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_102() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_103() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_104(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_101(), data_102(), data_103()]

def data_105() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_106() -> R.HostJob:
  R.FlushJob{}

def data_107() -> List<&2, R.HostJob>:
  [data_106()]

def data_108(+input: Nat) -> R.World:
  R.World{data_104(input), data_33(), data_105(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_109() -> C.Task:
  C.Round{}

def data_110() -> List<&2, C.Task>:
  [data_109()]

def data_111() -> List<&2, R.Value>:
  []

def data_112(+input: Nat) -> C.Machine:
  C.Machine{data_108(input), data_110(), data_111()}

def data_113(+input: Nat) -> R.World:
  R.World{data_104(input), data_33(), data_105(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_114() -> C.Task:
  C.RoundAfterSweep{}

def data_115() -> C.Task:
  C.FlushFinally{}

def data_116() -> C.Task:
  C.RoundEnd{}

def data_117() -> List<&2, C.Task>:
  [data_114(), data_115(), data_116()]

def data_118(+input: Nat) -> C.Machine:
  C.Machine{data_113(input), data_117(), data_111()}

def data_119(+input: Nat) -> R.World:
  R.World{data_104(input), data_33(), data_105(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_120() -> C.Task:
  C.HeapLoop{}

def data_121() -> List<&2, C.Task>:
  [data_120(), data_115(), data_116()]

def data_122(+input: Nat) -> C.Machine:
  C.Machine{data_119(input), data_121(), data_111()}

def data_123() -> C.Task:
  C.Recompute{3n, False{}}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_120(), data_115(), data_116()]

def data_125(+input: Nat) -> C.Machine:
  C.Machine{data_119(input), data_124(), data_111()}

def data_126() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_127(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_126(), data_102(), data_103()]

def data_128() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_129(+input: Nat) -> R.World:
  R.World{data_127(input), data_33(), data_128(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_130() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_131() -> List<&2, C.Task>:
  [data_130(), data_120(), data_115(), data_116()]

def data_132(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_131(), data_111()}

def data_133() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_134() -> List<&2, C.Task>:
  [data_133(), data_120(), data_115(), data_116()]

def data_135(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_134(), data_111()}

def data_136() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_137(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_136(), data_102(), data_103()]

def data_138() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_139(+input: Nat) -> R.World:
  R.World{data_137(input), data_33(), data_128(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_138(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_140() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_141() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_111(), 0n, False{}}

def data_142() -> C.Task:
  C.Finish{data_141()}

def data_143() -> List<&2, C.Task>:
  [data_140(), data_142(), data_120(), data_115(), data_116()]

def data_144(+input: Nat) -> C.Machine:
  C.Machine{data_139(input), data_143(), data_111()}

def data_145() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_146() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_147() -> C.Task:
  C.Binary{0}

def data_148() -> List<&2, C.Task>:
  [data_145(), data_146(), data_147(), data_142(), data_120(), data_115(), data_116()]

def data_149(+input: Nat) -> C.Machine:
  C.Machine{data_139(input), data_148(), data_111()}

def data_150() -> C.Task:
  C.ReadNode{2n}

def data_151() -> List<&2, C.Task>:
  [data_150(), data_146(), data_147(), data_142(), data_120(), data_115(), data_116()]

def data_152(+input: Nat) -> C.Machine:
  C.Machine{data_139(input), data_151(), data_111()}

def data_153() -> C.Task:
  C.ReadPrepared{2n}

def data_154() -> List<&2, C.Task>:
  [data_153(), data_146(), data_147(), data_142(), data_120(), data_115(), data_116()]

def data_155(+input: Nat) -> C.Machine:
  C.Machine{data_139(input), data_154(), data_111()}

def data_156() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_157(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_156(), data_102(), data_103()]

def data_158() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_159() -> List<&2, R.Link>:
  [data_28(), data_158(), data_30(), data_31(), data_32()]

def data_160(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_97(input)}

def data_161(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input)]

def data_162(+input: Nat) -> R.World:
  R.World{data_157(input), data_159(), data_128(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_163() -> List<&2, C.Task>:
  [data_146(), data_147(), data_142(), data_120(), data_115(), data_116()]

def data_164(+input: Nat) -> List<&2, R.Value>:
  [data_97(input)]

def data_165(+input: Nat) -> C.Machine:
  C.Machine{data_162(input), data_163(), data_164(input)}

def data_166() -> List<&2, C.Task>:
  [data_147(), data_142(), data_120(), data_115(), data_116()]

def data_167(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_97(input)]

def data_168(+input: Nat) -> C.Machine:
  C.Machine{data_162(input), data_166(), data_167(input)}

def data_169() -> List<&2, C.Task>:
  [data_142(), data_120(), data_115(), data_116()]

def data_170(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_171(+input: Nat) -> List<&2, R.Value>:
  [data_170(input)]

def data_172(+input: Nat) -> C.Machine:
  C.Machine{data_162(input), data_169(), data_171(input)}

def data_173() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_174(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_173(), data_102(), data_103()]

def data_175(+input: Nat) -> R.World:
  R.World{data_174(input), data_159(), data_128(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_176(+input: Nat) -> C.Task:
  C.PassReleases{data_141(), 0n, data_170(input), False{}, False{}, False{}, data_53()}

def data_177(+input: Nat) -> List<&2, C.Task>:
  [data_176(input), data_120(), data_115(), data_116()]

def data_178(+input: Nat) -> C.Machine:
  C.Machine{data_175(input), data_177(input), data_111()}

def data_179(+input: Nat) -> R.Slot:
  R.Present{data_170(input)}

def data_180() -> R.Stamp:
  R.Stamped{8n}

def data_181(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_179(input), False{}, 0, 16384, 0, 0n, data_180(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_182() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_183(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_181(input), data_182(), data_103()]

def data_184() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_185(+input: Nat) -> R.World:
  R.World{data_183(input), data_159(), data_184(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_186() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_187() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_188() -> List<&2, C.Task>:
  [data_186(), data_187(), data_120(), data_115(), data_116()]

def data_189(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_188(), data_111()}

def data_190() -> List<&2, C.Task>:
  [data_187(), data_120(), data_115(), data_116()]

def data_191(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_190(), data_111()}

def data_192() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_193() -> List<&2, C.Task>:
  [data_192(), data_120(), data_115(), data_116()]

def data_194(+input: Nat) -> C.Machine:
  C.Machine{data_185(input), data_193(), data_111()}

def data_195(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_179(input), False{}, 128, 16384, 0, 0n, data_180(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_196(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_182(), data_103()]

def data_197() -> List<&2, Nat>:
  [2n, 3n]

def data_198(+input: Nat) -> R.World:
  R.World{data_196(input), data_159(), data_184(), 0n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_199(+input: Nat) -> C.Machine:
  C.Machine{data_198(input), data_121(), data_111()}

def data_200(+input: Nat) -> R.World:
  R.World{data_196(input), data_159(), data_184(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_201(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_121(), data_111()}

def data_202() -> C.Task:
  C.Recompute{4n, False{}}

def data_203() -> List<&2, C.Task>:
  [data_202(), data_120(), data_115(), data_116()]

def data_204(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_203(), data_111()}

def data_205() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_206(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_205(), data_103()]

def data_207(+input: Nat) -> R.World:
  R.World{data_206(input), data_159(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_208() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n}

def data_209() -> List<&2, C.Task>:
  [data_208(), data_120(), data_115(), data_116()]

def data_210(+input: Nat) -> C.Machine:
  C.Machine{data_207(input), data_209(), data_111()}

def data_211() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n}

def data_212() -> List<&2, C.Task>:
  [data_211(), data_120(), data_115(), data_116()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_207(input), data_212(), data_111()}

def data_214() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_215(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_214(), data_103()]

def data_216(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45()]

def data_217(+input: Nat) -> R.World:
  R.World{data_215(input), data_159(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_216(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_218() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_219() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_111(), 0n, False{}}

def data_220() -> C.Task:
  C.Finish{data_219()}

def data_221() -> List<&2, C.Task>:
  [data_218(), data_220(), data_120(), data_115(), data_116()]

def data_222(+input: Nat) -> C.Machine:
  C.Machine{data_217(input), data_221(), data_111()}

def data_223() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_224() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_225() -> C.Task:
  C.Binary{1}

def data_226() -> List<&2, C.Task>:
  [data_223(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_227(+input: Nat) -> C.Machine:
  C.Machine{data_217(input), data_226(), data_111()}

def data_228() -> C.Task:
  C.ReadNode{3n}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_230(+input: Nat) -> C.Machine:
  C.Machine{data_217(input), data_229(), data_111()}

def data_231() -> C.Task:
  C.ReadPrepared{3n}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_217(input), data_232(), data_111()}

def data_234() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_235(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_234(), data_103()]

def data_236() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_237() -> List<&2, R.Link>:
  [data_28(), data_158(), data_236(), data_31(), data_32()]

def data_238(+input: Nat) -> R.World:
  R.World{data_235(input), data_237(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_216(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_239() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_240() -> C.Task:
  C.ReadStatus{3n}

def data_241() -> List<&2, C.Task>:
  [data_239(), data_240(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_242(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_241(), data_111()}

def data_243() -> List<&2, C.Task>:
  [data_240(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_244(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_243(), data_111()}

def data_245() -> C.Task:
  C.Serve{3n}

def data_246() -> C.Task:
  C.AfterServe{3n}

def data_247() -> List<&2, C.Task>:
  [data_245(), data_246(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_248(+input: Nat) -> C.Machine:
  C.Machine{data_238(input), data_247(), data_111()}

def data_249() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_250(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_249(), data_103()]

def data_251(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_170(input)}

def data_252(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45(), data_251(input)]

def data_253(+input: Nat) -> R.World:
  R.World{data_250(input), data_237(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_254() -> List<&2, C.Task>:
  [data_246(), data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_255(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_254(), data_171(input)}

def data_256() -> List<&2, C.Task>:
  [data_224(), data_225(), data_220(), data_120(), data_115(), data_116()]

def data_257(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_256(), data_171(input)}

def data_258() -> List<&2, C.Task>:
  [data_225(), data_220(), data_120(), data_115(), data_116()]

def data_259(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_170(input)]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_258(), data_259(input)}

def data_261() -> List<&2, C.Task>:
  [data_220(), data_120(), data_115(), data_116()]

def data_262(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_263(+input: Nat) -> List<&2, R.Value>:
  [data_262(input)]

def data_264(+input: Nat) -> C.Machine:
  C.Machine{data_253(input), data_261(), data_263(input)}

def data_265() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_266(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_265(), data_103()]

def data_267(+input: Nat) -> R.World:
  R.World{data_266(input), data_237(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_268(+input: Nat) -> C.Task:
  C.PassReleases{data_219(), 0n, data_262(input), False{}, False{}, False{}, data_53()}

def data_269(+input: Nat) -> List<&2, C.Task>:
  [data_268(input), data_120(), data_115(), data_116()]

def data_270(+input: Nat) -> C.Machine:
  C.Machine{data_267(input), data_269(input), data_111()}

def data_271(+input: Nat) -> R.Slot:
  R.Present{data_262(input)}

def data_272() -> R.Stamp:
  R.Stamped{9n}

def data_273(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_271(input), False{}, 0, 16384, 0, 0n, data_272(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_274(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_273(input), data_103()]

def data_275(+input: Nat) -> R.World:
  R.World{data_274(input), data_237(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_276() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_277() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}}

def data_278() -> List<&2, C.Task>:
  [data_276(), data_277(), data_120(), data_115(), data_116()]

def data_279(+input: Nat) -> C.Machine:
  C.Machine{data_275(input), data_278(), data_111()}

def data_280() -> List<&2, C.Task>:
  [data_277(), data_120(), data_115(), data_116()]

def data_281(+input: Nat) -> C.Machine:
  C.Machine{data_275(input), data_280(), data_111()}

def data_282() -> C.Task:
  C.QueuePublication{4n, False{}, False{}}

def data_283() -> List<&2, C.Task>:
  [data_282(), data_120(), data_115(), data_116()]

def data_284(+input: Nat) -> C.Machine:
  C.Machine{data_275(input), data_283(), data_111()}

def data_285(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_271(input), False{}, 128, 16384, 0, 0n, data_272(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_286(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_103()]

def data_287() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_288(+input: Nat) -> R.World:
  R.World{data_286(input), data_237(), data_128(), 1n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_289(+input: Nat) -> C.Machine:
  C.Machine{data_288(input), data_121(), data_111()}

def data_290(+input: Nat) -> R.World:
  R.World{data_286(input), data_237(), data_128(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_291(+input: Nat) -> C.Machine:
  C.Machine{data_290(input), data_121(), data_111()}

def data_292() -> C.Task:
  C.Recompute{5n, False{}}

def data_293() -> List<&2, C.Task>:
  [data_292(), data_120(), data_115(), data_116()]

def data_294(+input: Nat) -> C.Machine:
  C.Machine{data_290(input), data_293(), data_111()}

def data_295() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_296(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_295()]

def data_297() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_298(+input: Nat) -> R.World:
  R.World{data_296(input), data_237(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_299() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n}

def data_300() -> List<&2, C.Task>:
  [data_299(), data_120(), data_115(), data_116()]

def data_301(+input: Nat) -> C.Machine:
  C.Machine{data_298(input), data_300(), data_111()}

def data_302() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n}

def data_303() -> List<&2, C.Task>:
  [data_302(), data_120(), data_115(), data_116()]

def data_304(+input: Nat) -> C.Machine:
  C.Machine{data_298(input), data_303(), data_111()}

def data_305() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_306(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_305()]

def data_307(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45(), data_251(input), data_48()]

def data_308(+input: Nat) -> R.World:
  R.World{data_306(input), data_237(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_307(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_309() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_310() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_111(), 0n, False{}}

def data_311() -> C.Task:
  C.Finish{data_310()}

def data_312() -> List<&2, C.Task>:
  [data_309(), data_311(), data_120(), data_115(), data_116()]

def data_313(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_312(), data_111()}

def data_314() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_315() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_316() -> List<&2, C.Task>:
  [data_314(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_317(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_316(), data_111()}

def data_318() -> C.Task:
  C.ReadNode{4n}

def data_319() -> List<&2, C.Task>:
  [data_318(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_320(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_319(), data_111()}

def data_321() -> C.Task:
  C.ReadPrepared{4n}

def data_322() -> List<&2, C.Task>:
  [data_321(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_323(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_322(), data_111()}

def data_324() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_325(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_324()]

def data_326() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_327() -> List<&2, R.Link>:
  [data_28(), data_158(), data_236(), data_326(), data_32()]

def data_328(+input: Nat) -> R.World:
  R.World{data_325(input), data_327(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_307(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_329() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_330() -> C.Task:
  C.ReadStatus{4n}

def data_331() -> List<&2, C.Task>:
  [data_329(), data_330(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_332(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_331(), data_111()}

def data_333() -> List<&2, C.Task>:
  [data_330(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_334(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_333(), data_111()}

def data_335() -> C.Task:
  C.Serve{4n}

def data_336() -> C.Task:
  C.AfterServe{4n}

def data_337() -> List<&2, C.Task>:
  [data_335(), data_336(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_338(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_337(), data_111()}

def data_339() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_340(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_339()]

def data_341(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_262(input)}

def data_342(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45(), data_251(input), data_48(), data_341(input)]

def data_343(+input: Nat) -> R.World:
  R.World{data_340(input), data_327(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_342(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_344() -> List<&2, C.Task>:
  [data_336(), data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_345(+input: Nat) -> C.Machine:
  C.Machine{data_343(input), data_344(), data_263(input)}

def data_346() -> List<&2, C.Task>:
  [data_315(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_347(+input: Nat) -> C.Machine:
  C.Machine{data_343(input), data_346(), data_263(input)}

def data_348() -> List<&2, C.Task>:
  [data_150(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_349(+input: Nat) -> C.Machine:
  C.Machine{data_343(input), data_348(), data_263(input)}

def data_350() -> List<&2, C.Task>:
  [data_153(), data_147(), data_311(), data_120(), data_115(), data_116()]

def data_351(+input: Nat) -> C.Machine:
  C.Machine{data_343(input), data_350(), data_263(input)}

def data_352() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_353(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_352()]

def data_354() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_355() -> List<&2, R.Link>:
  [data_28(), data_158(), data_236(), data_326(), data_354()]

def data_356(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_97(input)}

def data_357(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45(), data_251(input), data_48(), data_341(input), data_356(input)]

def data_358(+input: Nat) -> R.World:
  R.World{data_353(input), data_355(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_359() -> List<&2, C.Task>:
  [data_147(), data_311(), data_120(), data_115(), data_116()]

def data_360(+input: Nat) -> List<&2, R.Value>:
  [data_97(input), data_262(input)]

def data_361(+input: Nat) -> C.Machine:
  C.Machine{data_358(input), data_359(), data_360(input)}

def data_362() -> List<&2, C.Task>:
  [data_311(), data_120(), data_115(), data_116()]

def data_363(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_364(+input: Nat) -> List<&2, R.Value>:
  [data_363(input)]

def data_365(+input: Nat) -> C.Machine:
  C.Machine{data_358(input), data_362(), data_364(input)}

def data_366() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_367(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_366()]

def data_368(+input: Nat) -> R.World:
  R.World{data_367(input), data_355(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_369(+input: Nat) -> C.Task:
  C.PassReleases{data_310(), 0n, data_363(input), False{}, False{}, False{}, data_53()}

def data_370(+input: Nat) -> List<&2, C.Task>:
  [data_369(input), data_120(), data_115(), data_116()]

def data_371(+input: Nat) -> C.Machine:
  C.Machine{data_368(input), data_370(input), data_111()}

def data_372(+input: Nat) -> R.Node:
  R.Node{data_23(), data_363(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_373(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_372(input)]

def data_374() -> List<&2, Nat>:
  [5n]

def data_375(+input: Nat) -> R.World:
  R.World{data_373(input), data_355(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_376() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_377() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}}

def data_378() -> List<&2, C.Task>:
  [data_376(), data_377(), data_120(), data_115(), data_116()]

def data_379(+input: Nat) -> C.Machine:
  C.Machine{data_375(input), data_378(), data_111()}

def data_380() -> List<&2, C.Task>:
  [data_377(), data_120(), data_115(), data_116()]

def data_381(+input: Nat) -> C.Machine:
  C.Machine{data_375(input), data_380(), data_111()}

def data_382() -> C.Task:
  C.QueuePublication{5n, False{}, False{}}

def data_383() -> List<&2, C.Task>:
  [data_382(), data_120(), data_115(), data_116()]

def data_384(+input: Nat) -> C.Machine:
  C.Machine{data_375(input), data_383(), data_111()}

def data_385(+input: Nat) -> C.Machine:
  C.Machine{data_375(input), data_121(), data_111()}

def data_386(+input: Nat) -> R.World:
  R.World{data_373(input), data_355(), data_297(), 3n, 2n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_387(+input: Nat) -> C.Machine:
  C.Machine{data_386(input), data_121(), data_111()}

def data_388(+input: Nat) -> R.World:
  R.World{data_373(input), data_355(), data_297(), 3n, 0n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_389() -> C.Task:
  C.Seam{}

def data_390() -> List<&2, C.Task>:
  [data_389(), data_115(), data_116()]

def data_391(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_390(), data_111()}

def data_392() -> C.Task:
  C.Settle{}

def data_393() -> C.Task:
  C.AfterSettle{}

def data_394() -> List<&2, C.Task>:
  [data_392(), data_393(), data_115(), data_116()]

def data_395(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_394(), data_111()}

def data_396() -> C.Task:
  C.CommitIntake{0n}

def data_397() -> C.Task:
  C.TrimIntake{0n}

def data_398() -> C.Task:
  C.FinishSettleIntake{0n}

def data_399() -> List<&2, C.Task>:
  [data_396(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_400(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_399(), data_111()}

def data_401() -> C.Task:
  C.CommitPending{2n}

def data_402() -> C.Task:
  C.CommitIntake{1n}

def data_403() -> List<&2, C.Task>:
  [data_401(), data_402(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_404(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_403(), data_111()}

def data_405(+input: Nat) -> R.Node:
  R.Node{data_9(), data_97(input), data_2(), False{}, 0, 0, 0, 0n, data_99(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_406(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_405(input), data_195(input), data_285(input), data_372(input)]

def data_407(+input: Nat) -> R.World:
  R.World{data_406(input), data_355(), data_297(), 3n, 0n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_408() -> List<&2, C.Task>:
  [data_402(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_409(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_408(), data_111()}

def data_410() -> C.Task:
  C.CommitPending{3n}

def data_411() -> C.Task:
  C.CommitIntake{2n}

def data_412() -> List<&2, C.Task>:
  [data_410(), data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_413(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_412(), data_111()}

def data_414(+input: Nat) -> R.Node:
  R.Node{data_12(), data_170(input), data_2(), False{}, 0, 16384, 0, 0n, data_180(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_415(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_405(input), data_414(input), data_285(input), data_372(input)]

def data_416(+input: Nat) -> R.World:
  R.World{data_415(input), data_355(), data_297(), 3n, 0n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_417() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_418() -> List<&2, C.Task>:
  [data_417(), data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_419(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_418(), data_111()}

def data_420() -> O.Task:
  O.TrimDeps{3n}

def data_421() -> List<&2, O.Task>:
  [data_420()]

def data_422() -> C.Task:
  C.OwnerTasks{data_421()}

def data_423() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_424() -> List<&2, C.Task>:
  [data_422(), data_423(), data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_425(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_424(), data_111()}

def data_426() -> List<&2, O.Task>:
  []

def data_427() -> C.Task:
  C.OwnerTasks{data_426()}

def data_428() -> List<&2, C.Task>:
  [data_427(), data_423(), data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_429(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_428(), data_111()}

def data_430() -> List<&2, C.Task>:
  [data_423(), data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_431(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_430(), data_111()}

def data_432() -> List<&2, C.Task>:
  [data_411(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_433(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_432(), data_111()}

def data_434() -> C.Task:
  C.CommitPending{4n}

def data_435() -> C.Task:
  C.CommitIntake{3n}

def data_436() -> List<&2, C.Task>:
  [data_434(), data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_437(+input: Nat) -> C.Machine:
  C.Machine{data_416(input), data_436(), data_111()}

def data_438(+input: Nat) -> R.Node:
  R.Node{data_12(), data_262(input), data_2(), False{}, 0, 16384, 0, 0n, data_272(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_439(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_405(input), data_414(input), data_438(input), data_372(input)]

def data_440(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_441() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_442() -> List<&2, C.Task>:
  [data_441(), data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_443(+input: Nat) -> C.Machine:
  C.Machine{data_440(input), data_442(), data_111()}

def data_444() -> O.Task:
  O.TrimDeps{4n}

def data_445() -> List<&2, O.Task>:
  [data_444()]

def data_446() -> C.Task:
  C.OwnerTasks{data_445()}

def data_447() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_448() -> List<&2, C.Task>:
  [data_446(), data_447(), data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_449(+input: Nat) -> C.Machine:
  C.Machine{data_440(input), data_448(), data_111()}

def data_450() -> List<&2, C.Task>:
  [data_427(), data_447(), data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_440(input), data_450(), data_111()}

def data_452() -> List<&2, C.Task>:
  [data_447(), data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_453(+input: Nat) -> C.Machine:
  C.Machine{data_440(input), data_452(), data_111()}

def data_454() -> List<&2, C.Task>:
  [data_435(), data_397(), data_398(), data_393(), data_115(), data_116()]

def data_455(+input: Nat) -> C.Machine:
  C.Machine{data_440(input), data_454(), data_111()}

def data_456(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_457() -> List<&2, C.Task>:
  [data_397(), data_398(), data_393(), data_115(), data_116()]

def data_458(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_457(), data_111()}

def data_459() -> List<&2, C.Task>:
  [data_398(), data_393(), data_115(), data_116()]

def data_460(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_459(), data_111()}

def data_461(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_462() -> C.SeamFrame:
  C.SeamFrame{0n, data_374(), data_36()}

def data_463() -> C.Task:
  C.LandTransactions{data_462(), 0n}

def data_464() -> List<&2, C.Task>:
  [data_463(), data_393(), data_115(), data_116()]

def data_465(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_464(), data_111()}

def data_466() -> C.Task:
  C.CompleteSettle{data_462()}

def data_467() -> List<&2, C.Task>:
  [data_466(), data_393(), data_115(), data_116()]

def data_468(+input: Nat) -> C.Machine:
  C.Machine{data_461(input), data_467(), data_111()}

def data_469() -> C.Task:
  C.ZombieLoop{data_35()}

def data_470() -> List<&2, C.Task>:
  [data_469(), data_393(), data_115(), data_116()]

def data_471(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_470(), data_111()}

def data_472() -> List<&2, C.Task>:
  [data_393(), data_115(), data_116()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_456(input), data_472(), data_111()}

def data_474(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_374(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_475() -> C.Task:
  C.RenderQueue{}

def data_476() -> List<&2, C.Task>:
  [data_475(), data_115(), data_116()]

def data_477(+input: Nat) -> C.Machine:
  C.Machine{data_474(input), data_476(), data_111()}

def data_478(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_479() -> C.Task:
  C.RunEffect{5n}

def data_480() -> C.Task:
  C.UserQueue{}

def data_481() -> List<&2, C.Task>:
  [data_479(), data_480(), data_115(), data_116()]

def data_482(+input: Nat) -> C.Machine:
  C.Machine{data_478(input), data_481(), data_111()}

def data_483() -> C.Task:
  C.ApplyEffect{5n}

def data_484() -> C.Task:
  C.EffectFinally{5n, True{}, data_111()}

def data_485() -> List<&2, C.Task>:
  [data_483(), data_484(), data_480(), data_115(), data_116()]

def data_486(+input: Nat) -> C.Machine:
  C.Machine{data_478(input), data_485(), data_111()}

def data_487(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_363(input)}

def data_488(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_487(input)]

def data_489(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_363(input), data_18()}

def data_490(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_160(input), data_45(), data_251(input), data_48(), data_341(input), data_356(input), data_489(input)]

def data_491(+input: Nat) -> R.World:
  R.World{data_439(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_488(input), data_490(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_492() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_493() -> List<&2, C.Task>:
  [data_492(), data_484(), data_480(), data_115(), data_116()]

def data_494(+input: Nat) -> C.Machine:
  C.Machine{data_491(input), data_493(), data_111()}

def data_495() -> List<&2, C.Task>:
  [data_484(), data_480(), data_115(), data_116()]

def data_496(+input: Nat) -> C.Machine:
  C.Machine{data_491(input), data_495(), data_111()}

def data_497(+input: Nat) -> R.Node:
  R.Node{data_23(), data_363(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_363(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_498(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_405(input), data_414(input), data_438(input), data_497(input)]

def data_499(+input: Nat) -> R.World:
  R.World{data_498(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_488(input), data_490(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_500() -> O.Task:
  O.TrimDeps{5n}

def data_501() -> List<&2, O.Task>:
  [data_500()]

def data_502() -> C.Task:
  C.OwnerTasks{data_501()}

def data_503() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_111()}

def data_504() -> List<&2, C.Task>:
  [data_502(), data_503(), data_480(), data_115(), data_116()]

def data_505(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_504(), data_111()}

def data_506() -> List<&2, C.Task>:
  [data_427(), data_503(), data_480(), data_115(), data_116()]

def data_507(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_506(), data_111()}

def data_508() -> List<&2, C.Task>:
  [data_503(), data_480(), data_115(), data_116()]

def data_509(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_508(), data_111()}

def data_510() -> List<&2, C.Task>:
  [data_480(), data_115(), data_116()]

def data_511(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_510(), data_111()}

def data_512() -> List<&2, C.Task>:
  [data_115(), data_116()]

def data_513(+input: Nat) -> C.Machine:
  C.Machine{data_499(input), data_512(), data_111()}

def data_514(+input: Nat) -> R.World:
  R.World{data_498(input), data_355(), data_297(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_488(input), data_490(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_515() -> List<&2, C.Task>:
  [data_116()]

def data_516(+input: Nat) -> C.Machine:
  C.Machine{data_514(input), data_515(), data_111()}

def data_517() -> List<&2, C.Task>:
  []

def data_518(+input: Nat) -> C.Machine:
  C.Machine{data_514(input), data_517(), data_111()}

def data_519(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_179(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_520(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_519(input), data_102(), data_103()]

def data_521(+input: Nat) -> R.World:
  R.World{data_520(input), data_159(), data_128(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_161(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_522(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_271(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_523(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_522(input), data_103()]

def data_524(+input: Nat) -> R.World:
  R.World{data_523(input), data_237(), data_128(), 1n, 2n, False{}, data_197(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_252(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_525() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_526(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_195(input), data_285(input), data_525()]

def data_527(+input: Nat) -> R.World:
  R.World{data_526(input), data_355(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_528(+input: Nat) -> R.World:
  R.World{data_526(input), data_355(), data_297(), 2n, 2n, False{}, data_287(), data_35(), data_374(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_357(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_107(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_529() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_530(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_98(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_531(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_530(input), data_17(), data_22(), data_26()]

def data_532(+input: Nat) -> R.World:
  R.World{data_531(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_533(+input: Nat) -> R.World:
  R.World{data_104(input), data_33(), data_105(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_534(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_17(), data_22(), data_26()]

def data_535(+input: Nat) -> R.World:
  R.World{data_534(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def data_536() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_537(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(input), data_101(), data_102(), data_536()]

def data_538() -> List<&2, Nat>:
  [3n]

def data_539(+input: Nat) -> R.World:
  R.World{data_537(input), data_33(), data_538(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95()}

def origin() -> R.World:
  data_96()

def state_0(+input: Nat) -> C.Machine:
  data_112(input)

def state_1(+input: Nat) -> C.Machine:
  data_118(input)

def state_2(+input: Nat) -> C.Machine:
  data_122(input)

def state_3(+input: Nat) -> C.Machine:
  data_125(input)

def state_4(+input: Nat) -> C.Machine:
  data_132(input)

def state_5(+input: Nat) -> C.Machine:
  data_135(input)

def state_6(+input: Nat) -> C.Machine:
  data_144(input)

def state_7(+input: Nat) -> C.Machine:
  data_149(input)

def state_8(+input: Nat) -> C.Machine:
  data_152(input)

def state_9(+input: Nat) -> C.Machine:
  data_155(input)

def state_10(+input: Nat) -> C.Machine:
  data_165(input)

def state_11(+input: Nat) -> C.Machine:
  data_168(input)

def state_12(+input: Nat) -> C.Machine:
  data_172(input)

def state_13(+input: Nat) -> C.Machine:
  data_178(input)

def state_14(+input: Nat) -> C.Machine:
  data_189(input)

def state_15(+input: Nat) -> C.Machine:
  data_191(input)

def state_16(+input: Nat) -> C.Machine:
  data_194(input)

def state_17(+input: Nat) -> C.Machine:
  data_199(input)

def state_18(+input: Nat) -> C.Machine:
  data_201(input)

def state_19(+input: Nat) -> C.Machine:
  data_204(input)

def state_20(+input: Nat) -> C.Machine:
  data_210(input)

def state_21(+input: Nat) -> C.Machine:
  data_213(input)

def state_22(+input: Nat) -> C.Machine:
  data_222(input)

def state_23(+input: Nat) -> C.Machine:
  data_227(input)

def state_24(+input: Nat) -> C.Machine:
  data_230(input)

def state_25(+input: Nat) -> C.Machine:
  data_233(input)

def state_26(+input: Nat) -> C.Machine:
  data_242(input)

def state_27(+input: Nat) -> C.Machine:
  data_244(input)

def state_28(+input: Nat) -> C.Machine:
  data_248(input)

def state_29(+input: Nat) -> C.Machine:
  data_255(input)

def state_30(+input: Nat) -> C.Machine:
  data_257(input)

def state_31(+input: Nat) -> C.Machine:
  data_260(input)

def state_32(+input: Nat) -> C.Machine:
  data_264(input)

def state_33(+input: Nat) -> C.Machine:
  data_270(input)

def state_34(+input: Nat) -> C.Machine:
  data_279(input)

def state_35(+input: Nat) -> C.Machine:
  data_281(input)

def state_36(+input: Nat) -> C.Machine:
  data_284(input)

def state_37(+input: Nat) -> C.Machine:
  data_289(input)

def state_38(+input: Nat) -> C.Machine:
  data_291(input)

def state_39(+input: Nat) -> C.Machine:
  data_294(input)

def state_40(+input: Nat) -> C.Machine:
  data_301(input)

def state_41(+input: Nat) -> C.Machine:
  data_304(input)

def state_42(+input: Nat) -> C.Machine:
  data_313(input)

def state_43(+input: Nat) -> C.Machine:
  data_317(input)

def state_44(+input: Nat) -> C.Machine:
  data_320(input)

def state_45(+input: Nat) -> C.Machine:
  data_323(input)

def state_46(+input: Nat) -> C.Machine:
  data_332(input)

def state_47(+input: Nat) -> C.Machine:
  data_334(input)

def state_48(+input: Nat) -> C.Machine:
  data_338(input)

def state_49(+input: Nat) -> C.Machine:
  data_345(input)

def state_50(+input: Nat) -> C.Machine:
  data_347(input)

def state_51(+input: Nat) -> C.Machine:
  data_349(input)

def state_52(+input: Nat) -> C.Machine:
  data_351(input)

def state_53(+input: Nat) -> C.Machine:
  data_361(input)

def state_54(+input: Nat) -> C.Machine:
  data_365(input)

def state_55(+input: Nat) -> C.Machine:
  data_371(input)

def state_56(+input: Nat) -> C.Machine:
  data_379(input)

def state_57(+input: Nat) -> C.Machine:
  data_381(input)

def state_58(+input: Nat) -> C.Machine:
  data_384(input)

def state_59(+input: Nat) -> C.Machine:
  data_385(input)

def state_60(+input: Nat) -> C.Machine:
  data_387(input)

def state_61(+input: Nat) -> C.Machine:
  data_391(input)

def state_62(+input: Nat) -> C.Machine:
  data_395(input)

def state_63(+input: Nat) -> C.Machine:
  data_400(input)

def state_64(+input: Nat) -> C.Machine:
  data_404(input)

def state_65(+input: Nat) -> C.Machine:
  data_409(input)

def state_66(+input: Nat) -> C.Machine:
  data_413(input)

def state_67(+input: Nat) -> C.Machine:
  data_419(input)

def state_68(+input: Nat) -> C.Machine:
  data_425(input)

def state_69(+input: Nat) -> C.Machine:
  data_429(input)

def state_70(+input: Nat) -> C.Machine:
  data_431(input)

def state_71(+input: Nat) -> C.Machine:
  data_433(input)

def state_72(+input: Nat) -> C.Machine:
  data_437(input)

def state_73(+input: Nat) -> C.Machine:
  data_443(input)

def state_74(+input: Nat) -> C.Machine:
  data_449(input)

def state_75(+input: Nat) -> C.Machine:
  data_451(input)

def state_76(+input: Nat) -> C.Machine:
  data_453(input)

def state_77(+input: Nat) -> C.Machine:
  data_455(input)

def state_78(+input: Nat) -> C.Machine:
  data_458(input)

def state_79(+input: Nat) -> C.Machine:
  data_460(input)

def state_80(+input: Nat) -> C.Machine:
  data_465(input)

def state_81(+input: Nat) -> C.Machine:
  data_468(input)

def state_82(+input: Nat) -> C.Machine:
  data_471(input)

def state_83(+input: Nat) -> C.Machine:
  data_473(input)

def state_84(+input: Nat) -> C.Machine:
  data_477(input)

def state_85(+input: Nat) -> C.Machine:
  data_482(input)

def state_86(+input: Nat) -> C.Machine:
  data_486(input)

def state_87(+input: Nat) -> C.Machine:
  data_494(input)

def state_88(+input: Nat) -> C.Machine:
  data_496(input)

def state_89(+input: Nat) -> C.Machine:
  data_505(input)

def state_90(+input: Nat) -> C.Machine:
  data_507(input)

def state_91(+input: Nat) -> C.Machine:
  data_509(input)

def state_92(+input: Nat) -> C.Machine:
  data_511(input)

def state_93(+input: Nat) -> C.Machine:
  data_513(input)

def state_94(+input: Nat) -> C.Machine:
  data_516(input)

def state_95(+input: Nat) -> C.Machine:
  data_518(input)

def finalWorld(+input: Nat) -> R.World:
  data_514(input)

def slot_13(+input: Nat) -> R.World:
  data_521(input)

def notify_13(+input: Nat) -> R.World:
  data_185(input)

def slot_33(+input: Nat) -> R.World:
  data_524(input)

def notify_33(+input: Nat) -> R.World:
  data_275(input)

def modified_55(+input: Nat) -> R.World:
  data_527(input)

def queued_55(+input: Nat) -> R.World:
  data_528(input)

def value_55(+input: Nat) -> R.World:
  data_375(input)

def setter_queued(+input: Nat) -> R.World:
  data_529()

def setter_slot(+input: Nat) -> R.World:
  data_532(input)

def setter_inserted(+input: Nat) -> R.World:
  data_533(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_108(input)

def setter_stamped(+input: Nat) -> R.World:
  data_535(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_539(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_533(input)

