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

def data_98() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_99(+input: Nat) -> R.Value:
  R.Number{input}

def data_100(+input: Nat) -> R.Slot:
  R.Present{data_99(input)}

def data_101() -> R.Stamp:
  R.Stamped{7n}

def data_102(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_100(input), False{}, 0, 0, 0, 0n, data_101(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_103() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_104() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_105() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_106(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_103(), data_104(), data_105()]

def data_107() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_108() -> R.HostJob:
  R.FlushJob{}

def data_109() -> List<&2, R.HostJob>:
  [data_108()]

def data_110(+input: Nat) -> R.World:
  R.World{data_106(input), data_33(), data_107(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_111() -> C.Task:
  C.Round{}

def data_112() -> List<&2, C.Task>:
  [data_111()]

def data_113() -> List<&2, R.Value>:
  []

def data_114(+input: Nat) -> C.Machine:
  C.Machine{data_110(input), data_112(), data_113()}

def data_115(+input: Nat) -> R.World:
  R.World{data_106(input), data_33(), data_107(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_116() -> C.Task:
  C.RoundAfterSweep{}

def data_117() -> C.Task:
  C.FlushFinally{}

def data_118() -> C.Task:
  C.RoundEnd{}

def data_119() -> List<&2, C.Task>:
  [data_116(), data_117(), data_118()]

def data_120(+input: Nat) -> C.Machine:
  C.Machine{data_115(input), data_119(), data_113()}

def data_121(+input: Nat) -> R.World:
  R.World{data_106(input), data_33(), data_107(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_122() -> C.Task:
  C.HeapLoop{}

def data_123() -> List<&2, C.Task>:
  [data_122(), data_117(), data_118()]

def data_124(+input: Nat) -> C.Machine:
  C.Machine{data_121(input), data_123(), data_113()}

def data_125() -> C.Task:
  C.Recompute{3n, False{}}

def data_126() -> List<&2, C.Task>:
  [data_125(), data_122(), data_117(), data_118()]

def data_127(+input: Nat) -> C.Machine:
  C.Machine{data_121(input), data_126(), data_113()}

def data_128() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_129(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_128(), data_104(), data_105()]

def data_130() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_131(+input: Nat) -> R.World:
  R.World{data_129(input), data_33(), data_130(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_132() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_133() -> List<&2, C.Task>:
  [data_132(), data_122(), data_117(), data_118()]

def data_134(+input: Nat) -> C.Machine:
  C.Machine{data_131(input), data_133(), data_113()}

def data_135() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_136() -> List<&2, C.Task>:
  [data_135(), data_122(), data_117(), data_118()]

def data_137(+input: Nat) -> C.Machine:
  C.Machine{data_131(input), data_136(), data_113()}

def data_138() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_139(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_138(), data_104(), data_105()]

def data_140() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_141(+input: Nat) -> R.World:
  R.World{data_139(input), data_33(), data_130(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_140(), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_142() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_143() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, 0n, data_113(), 0n, False{}}

def data_144() -> C.Task:
  C.Finish{data_143()}

def data_145() -> List<&2, C.Task>:
  [data_142(), data_144(), data_122(), data_117(), data_118()]

def data_146(+input: Nat) -> C.Machine:
  C.Machine{data_141(input), data_145(), data_113()}

def data_147() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_148() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_149() -> C.Task:
  C.Binary{0}

def data_150() -> List<&2, C.Task>:
  [data_147(), data_148(), data_149(), data_144(), data_122(), data_117(), data_118()]

def data_151(+input: Nat) -> C.Machine:
  C.Machine{data_141(input), data_150(), data_113()}

def data_152() -> C.Task:
  C.ReadNode{2n}

def data_153() -> List<&2, C.Task>:
  [data_152(), data_148(), data_149(), data_144(), data_122(), data_117(), data_118()]

def data_154(+input: Nat) -> C.Machine:
  C.Machine{data_141(input), data_153(), data_113()}

def data_155() -> C.Task:
  C.ReadPrepared{2n}

def data_156() -> List<&2, C.Task>:
  [data_155(), data_148(), data_149(), data_144(), data_122(), data_117(), data_118()]

def data_157(+input: Nat) -> C.Machine:
  C.Machine{data_141(input), data_156(), data_113()}

def data_158() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_159(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_158(), data_104(), data_105()]

def data_160() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_161() -> List<&2, R.Link>:
  [data_28(), data_160(), data_30(), data_31(), data_32()]

def data_162(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_99(input)}

def data_163(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input)]

def data_164(+input: Nat) -> R.World:
  R.World{data_159(input), data_161(), data_130(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_165() -> List<&2, C.Task>:
  [data_148(), data_149(), data_144(), data_122(), data_117(), data_118()]

def data_166(+input: Nat) -> List<&2, R.Value>:
  [data_99(input)]

def data_167(+input: Nat) -> C.Machine:
  C.Machine{data_164(input), data_165(), data_166(input)}

def data_168() -> List<&2, C.Task>:
  [data_149(), data_144(), data_122(), data_117(), data_118()]

def data_169(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_99(input)]

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_164(input), data_168(), data_169(input)}

def data_171() -> List<&2, C.Task>:
  [data_144(), data_122(), data_117(), data_118()]

def data_172(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_173(+input: Nat) -> List<&2, R.Value>:
  [data_172(input)]

def data_174(+input: Nat) -> C.Machine:
  C.Machine{data_164(input), data_171(), data_173(input)}

def data_175() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_176(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_175(), data_104(), data_105()]

def data_177(+input: Nat) -> R.World:
  R.World{data_176(input), data_161(), data_130(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_178(+input: Nat) -> C.Task:
  C.PassReleases{data_143(), 0n, data_172(input), False{}, False{}, False{}, data_53()}

def data_179(+input: Nat) -> List<&2, C.Task>:
  [data_178(input), data_122(), data_117(), data_118()]

def data_180(+input: Nat) -> C.Machine:
  C.Machine{data_177(input), data_179(input), data_113()}

def data_181(+input: Nat) -> R.Slot:
  R.Present{data_172(input)}

def data_182() -> R.Stamp:
  R.Stamped{8n}

def data_183(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_181(input), False{}, 0, 16384, 0, 0n, data_182(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_184() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_185(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_183(input), data_184(), data_105()]

def data_186() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_187(+input: Nat) -> R.World:
  R.World{data_185(input), data_161(), data_186(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_188() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_189() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_190() -> List<&2, C.Task>:
  [data_188(), data_189(), data_122(), data_117(), data_118()]

def data_191(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_190(), data_113()}

def data_192() -> List<&2, C.Task>:
  [data_189(), data_122(), data_117(), data_118()]

def data_193(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_192(), data_113()}

def data_194() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_195() -> List<&2, C.Task>:
  [data_194(), data_122(), data_117(), data_118()]

def data_196(+input: Nat) -> C.Machine:
  C.Machine{data_187(input), data_195(), data_113()}

def data_197(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_181(input), False{}, 128, 16384, 0, 0n, data_182(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_198(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_184(), data_105()]

def data_199() -> List<&2, Nat>:
  [2n, 3n]

def data_200(+input: Nat) -> R.World:
  R.World{data_198(input), data_161(), data_186(), 0n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_201(+input: Nat) -> C.Machine:
  C.Machine{data_200(input), data_123(), data_113()}

def data_202(+input: Nat) -> R.World:
  R.World{data_198(input), data_161(), data_186(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_203(+input: Nat) -> C.Machine:
  C.Machine{data_202(input), data_123(), data_113()}

def data_204() -> C.Task:
  C.Recompute{4n, False{}}

def data_205() -> List<&2, C.Task>:
  [data_204(), data_122(), data_117(), data_118()]

def data_206(+input: Nat) -> C.Machine:
  C.Machine{data_202(input), data_205(), data_113()}

def data_207() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_208(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_207(), data_105()]

def data_209(+input: Nat) -> R.World:
  R.World{data_208(input), data_161(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_210() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n}

def data_211() -> List<&2, C.Task>:
  [data_210(), data_122(), data_117(), data_118()]

def data_212(+input: Nat) -> C.Machine:
  C.Machine{data_209(input), data_211(), data_113()}

def data_213() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n}

def data_214() -> List<&2, C.Task>:
  [data_213(), data_122(), data_117(), data_118()]

def data_215(+input: Nat) -> C.Machine:
  C.Machine{data_209(input), data_214(), data_113()}

def data_216() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_217(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_216(), data_105()]

def data_218(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45()]

def data_219(+input: Nat) -> R.World:
  R.World{data_217(input), data_161(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_218(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_220() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_221() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_113(), 0n, False{}}

def data_222() -> C.Task:
  C.Finish{data_221()}

def data_223() -> List<&2, C.Task>:
  [data_220(), data_222(), data_122(), data_117(), data_118()]

def data_224(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_223(), data_113()}

def data_225() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_226() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_227() -> C.Task:
  C.Binary{1}

def data_228() -> List<&2, C.Task>:
  [data_225(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_228(), data_113()}

def data_230() -> C.Task:
  C.ReadNode{3n}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_232(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_231(), data_113()}

def data_233() -> C.Task:
  C.ReadPrepared{3n}

def data_234() -> List<&2, C.Task>:
  [data_233(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_235(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_234(), data_113()}

def data_236() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_237(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_236(), data_105()]

def data_238() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_239() -> List<&2, R.Link>:
  [data_28(), data_160(), data_238(), data_31(), data_32()]

def data_240(+input: Nat) -> R.World:
  R.World{data_237(input), data_239(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_218(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_241() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_242() -> C.Task:
  C.ReadStatus{3n}

def data_243() -> List<&2, C.Task>:
  [data_241(), data_242(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_244(+input: Nat) -> C.Machine:
  C.Machine{data_240(input), data_243(), data_113()}

def data_245() -> List<&2, C.Task>:
  [data_242(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_240(input), data_245(), data_113()}

def data_247() -> C.Task:
  C.Serve{3n}

def data_248() -> C.Task:
  C.AfterServe{3n}

def data_249() -> List<&2, C.Task>:
  [data_247(), data_248(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_250(+input: Nat) -> C.Machine:
  C.Machine{data_240(input), data_249(), data_113()}

def data_251() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_252(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_251(), data_105()]

def data_253(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_172(input)}

def data_254(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45(), data_253(input)]

def data_255(+input: Nat) -> R.World:
  R.World{data_252(input), data_239(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_256() -> List<&2, C.Task>:
  [data_248(), data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_257(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_256(), data_173(input)}

def data_258() -> List<&2, C.Task>:
  [data_226(), data_227(), data_222(), data_122(), data_117(), data_118()]

def data_259(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_258(), data_173(input)}

def data_260() -> List<&2, C.Task>:
  [data_227(), data_222(), data_122(), data_117(), data_118()]

def data_261(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_172(input)]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_260(), data_261(input)}

def data_263() -> List<&2, C.Task>:
  [data_222(), data_122(), data_117(), data_118()]

def data_264(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_265(+input: Nat) -> List<&2, R.Value>:
  [data_264(input)]

def data_266(+input: Nat) -> C.Machine:
  C.Machine{data_255(input), data_263(), data_265(input)}

def data_267() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_268(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_267(), data_105()]

def data_269(+input: Nat) -> R.World:
  R.World{data_268(input), data_239(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_270(+input: Nat) -> C.Task:
  C.PassReleases{data_221(), 0n, data_264(input), False{}, False{}, False{}, data_53()}

def data_271(+input: Nat) -> List<&2, C.Task>:
  [data_270(input), data_122(), data_117(), data_118()]

def data_272(+input: Nat) -> C.Machine:
  C.Machine{data_269(input), data_271(input), data_113()}

def data_273(+input: Nat) -> R.Slot:
  R.Present{data_264(input)}

def data_274() -> R.Stamp:
  R.Stamped{9n}

def data_275(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_273(input), False{}, 0, 16384, 0, 0n, data_274(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_276(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_275(input), data_105()]

def data_277(+input: Nat) -> R.World:
  R.World{data_276(input), data_239(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_278() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_279() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}}

def data_280() -> List<&2, C.Task>:
  [data_278(), data_279(), data_122(), data_117(), data_118()]

def data_281(+input: Nat) -> C.Machine:
  C.Machine{data_277(input), data_280(), data_113()}

def data_282() -> List<&2, C.Task>:
  [data_279(), data_122(), data_117(), data_118()]

def data_283(+input: Nat) -> C.Machine:
  C.Machine{data_277(input), data_282(), data_113()}

def data_284() -> C.Task:
  C.QueuePublication{4n, False{}, False{}}

def data_285() -> List<&2, C.Task>:
  [data_284(), data_122(), data_117(), data_118()]

def data_286(+input: Nat) -> C.Machine:
  C.Machine{data_277(input), data_285(), data_113()}

def data_287(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_273(input), False{}, 128, 16384, 0, 0n, data_274(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_288(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_105()]

def data_289() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_290(+input: Nat) -> R.World:
  R.World{data_288(input), data_239(), data_130(), 1n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_291(+input: Nat) -> C.Machine:
  C.Machine{data_290(input), data_123(), data_113()}

def data_292(+input: Nat) -> R.World:
  R.World{data_288(input), data_239(), data_130(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_293(+input: Nat) -> C.Machine:
  C.Machine{data_292(input), data_123(), data_113()}

def data_294() -> C.Task:
  C.Recompute{5n, False{}}

def data_295() -> List<&2, C.Task>:
  [data_294(), data_122(), data_117(), data_118()]

def data_296(+input: Nat) -> C.Machine:
  C.Machine{data_292(input), data_295(), data_113()}

def data_297() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_298(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_297()]

def data_299() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_300(+input: Nat) -> R.World:
  R.World{data_298(input), data_239(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_301() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n}

def data_302() -> List<&2, C.Task>:
  [data_301(), data_122(), data_117(), data_118()]

def data_303(+input: Nat) -> C.Machine:
  C.Machine{data_300(input), data_302(), data_113()}

def data_304() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n}

def data_305() -> List<&2, C.Task>:
  [data_304(), data_122(), data_117(), data_118()]

def data_306(+input: Nat) -> C.Machine:
  C.Machine{data_300(input), data_305(), data_113()}

def data_307() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_308(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_307()]

def data_309(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45(), data_253(input), data_48()]

def data_310(+input: Nat) -> R.World:
  R.World{data_308(input), data_239(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_309(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_311() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_312() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, 0n, data_113(), 0n, False{}}

def data_313() -> C.Task:
  C.Finish{data_312()}

def data_314() -> List<&2, C.Task>:
  [data_311(), data_313(), data_122(), data_117(), data_118()]

def data_315(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_314(), data_113()}

def data_316() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_317() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_318() -> List<&2, C.Task>:
  [data_316(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_319(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_318(), data_113()}

def data_320() -> C.Task:
  C.ReadNode{4n}

def data_321() -> List<&2, C.Task>:
  [data_320(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_322(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_321(), data_113()}

def data_323() -> C.Task:
  C.ReadPrepared{4n}

def data_324() -> List<&2, C.Task>:
  [data_323(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_325(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_324(), data_113()}

def data_326() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_327(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_326()]

def data_328() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_329() -> List<&2, R.Link>:
  [data_28(), data_160(), data_238(), data_328(), data_32()]

def data_330(+input: Nat) -> R.World:
  R.World{data_327(input), data_329(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_309(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_331() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_332() -> C.Task:
  C.ReadStatus{4n}

def data_333() -> List<&2, C.Task>:
  [data_331(), data_332(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_334(+input: Nat) -> C.Machine:
  C.Machine{data_330(input), data_333(), data_113()}

def data_335() -> List<&2, C.Task>:
  [data_332(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_336(+input: Nat) -> C.Machine:
  C.Machine{data_330(input), data_335(), data_113()}

def data_337() -> C.Task:
  C.Serve{4n}

def data_338() -> C.Task:
  C.AfterServe{4n}

def data_339() -> List<&2, C.Task>:
  [data_337(), data_338(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_340(+input: Nat) -> C.Machine:
  C.Machine{data_330(input), data_339(), data_113()}

def data_341() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_342(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_341()]

def data_343(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_264(input)}

def data_344(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45(), data_253(input), data_48(), data_343(input)]

def data_345(+input: Nat) -> R.World:
  R.World{data_342(input), data_329(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_344(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_346() -> List<&2, C.Task>:
  [data_338(), data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_347(+input: Nat) -> C.Machine:
  C.Machine{data_345(input), data_346(), data_265(input)}

def data_348() -> List<&2, C.Task>:
  [data_317(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_349(+input: Nat) -> C.Machine:
  C.Machine{data_345(input), data_348(), data_265(input)}

def data_350() -> List<&2, C.Task>:
  [data_152(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_351(+input: Nat) -> C.Machine:
  C.Machine{data_345(input), data_350(), data_265(input)}

def data_352() -> List<&2, C.Task>:
  [data_155(), data_149(), data_313(), data_122(), data_117(), data_118()]

def data_353(+input: Nat) -> C.Machine:
  C.Machine{data_345(input), data_352(), data_265(input)}

def data_354() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_355(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_354()]

def data_356() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_357() -> List<&2, R.Link>:
  [data_28(), data_160(), data_238(), data_328(), data_356()]

def data_358(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_99(input)}

def data_359(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45(), data_253(input), data_48(), data_343(input), data_358(input)]

def data_360(+input: Nat) -> R.World:
  R.World{data_355(input), data_357(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), True{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_361() -> List<&2, C.Task>:
  [data_149(), data_313(), data_122(), data_117(), data_118()]

def data_362(+input: Nat) -> List<&2, R.Value>:
  [data_99(input), data_264(input)]

def data_363(+input: Nat) -> C.Machine:
  C.Machine{data_360(input), data_361(), data_362(input)}

def data_364() -> List<&2, C.Task>:
  [data_313(), data_122(), data_117(), data_118()]

def data_365(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_366(+input: Nat) -> List<&2, R.Value>:
  [data_365(input)]

def data_367(+input: Nat) -> C.Machine:
  C.Machine{data_360(input), data_364(), data_366(input)}

def data_368() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_369(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_368()]

def data_370(+input: Nat) -> R.World:
  R.World{data_369(input), data_357(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_371(+input: Nat) -> C.Task:
  C.PassReleases{data_312(), 0n, data_365(input), False{}, False{}, False{}, data_53()}

def data_372(+input: Nat) -> List<&2, C.Task>:
  [data_371(input), data_122(), data_117(), data_118()]

def data_373(+input: Nat) -> C.Machine:
  C.Machine{data_370(input), data_372(input), data_113()}

def data_374(+input: Nat) -> R.Node:
  R.Node{data_23(), data_365(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_375(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_374(input)]

def data_376() -> List<&2, Nat>:
  [5n]

def data_377(+input: Nat) -> R.World:
  R.World{data_375(input), data_357(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_378() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_379() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}}

def data_380() -> List<&2, C.Task>:
  [data_378(), data_379(), data_122(), data_117(), data_118()]

def data_381(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_380(), data_113()}

def data_382() -> List<&2, C.Task>:
  [data_379(), data_122(), data_117(), data_118()]

def data_383(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_382(), data_113()}

def data_384() -> C.Task:
  C.QueuePublication{5n, False{}, False{}}

def data_385() -> List<&2, C.Task>:
  [data_384(), data_122(), data_117(), data_118()]

def data_386(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_385(), data_113()}

def data_387(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_123(), data_113()}

def data_388(+input: Nat) -> R.World:
  R.World{data_375(input), data_357(), data_299(), 3n, 2n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_389(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_123(), data_113()}

def data_390(+input: Nat) -> R.World:
  R.World{data_375(input), data_357(), data_299(), 3n, 0n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_391() -> C.Task:
  C.Seam{}

def data_392() -> List<&2, C.Task>:
  [data_391(), data_117(), data_118()]

def data_393(+input: Nat) -> C.Machine:
  C.Machine{data_390(input), data_392(), data_113()}

def data_394() -> C.Task:
  C.Settle{}

def data_395() -> C.Task:
  C.AfterSettle{}

def data_396() -> List<&2, C.Task>:
  [data_394(), data_395(), data_117(), data_118()]

def data_397(+input: Nat) -> C.Machine:
  C.Machine{data_390(input), data_396(), data_113()}

def data_398() -> C.Task:
  C.CommitIntake{0n}

def data_399() -> C.Task:
  C.TrimIntake{0n}

def data_400() -> C.Task:
  C.FinishSettleIntake{0n}

def data_401() -> List<&2, C.Task>:
  [data_398(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_402(+input: Nat) -> C.Machine:
  C.Machine{data_390(input), data_401(), data_113()}

def data_403() -> C.Task:
  C.CommitPending{2n}

def data_404() -> C.Task:
  C.CommitIntake{1n}

def data_405() -> List<&2, C.Task>:
  [data_403(), data_404(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_406(+input: Nat) -> C.Machine:
  C.Machine{data_390(input), data_405(), data_113()}

def data_407(+input: Nat) -> R.Node:
  R.Node{data_9(), data_99(input), data_2(), False{}, 0, 0, 0, 0n, data_101(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_408(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_407(input), data_197(input), data_287(input), data_374(input)]

def data_409(+input: Nat) -> R.World:
  R.World{data_408(input), data_357(), data_299(), 3n, 0n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_410() -> List<&2, C.Task>:
  [data_404(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_411(+input: Nat) -> C.Machine:
  C.Machine{data_409(input), data_410(), data_113()}

def data_412() -> C.Task:
  C.CommitPending{3n}

def data_413() -> C.Task:
  C.CommitIntake{2n}

def data_414() -> List<&2, C.Task>:
  [data_412(), data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_415(+input: Nat) -> C.Machine:
  C.Machine{data_409(input), data_414(), data_113()}

def data_416(+input: Nat) -> R.Node:
  R.Node{data_12(), data_172(input), data_2(), False{}, 0, 16384, 0, 0n, data_182(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_417(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_407(input), data_416(input), data_287(input), data_374(input)]

def data_418(+input: Nat) -> R.World:
  R.World{data_417(input), data_357(), data_299(), 3n, 0n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_419() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_420() -> List<&2, C.Task>:
  [data_419(), data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_421(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_420(), data_113()}

def data_422() -> O.Task:
  O.TrimDeps{3n}

def data_423() -> List<&2, O.Task>:
  [data_422()]

def data_424() -> C.Task:
  C.OwnerTasks{data_423()}

def data_425() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_426() -> List<&2, C.Task>:
  [data_424(), data_425(), data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_427(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_426(), data_113()}

def data_428() -> List<&2, O.Task>:
  []

def data_429() -> C.Task:
  C.OwnerTasks{data_428()}

def data_430() -> List<&2, C.Task>:
  [data_429(), data_425(), data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_431(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_430(), data_113()}

def data_432() -> List<&2, C.Task>:
  [data_425(), data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_433(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_432(), data_113()}

def data_434() -> List<&2, C.Task>:
  [data_413(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_435(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_434(), data_113()}

def data_436() -> C.Task:
  C.CommitPending{4n}

def data_437() -> C.Task:
  C.CommitIntake{3n}

def data_438() -> List<&2, C.Task>:
  [data_436(), data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_439(+input: Nat) -> C.Machine:
  C.Machine{data_418(input), data_438(), data_113()}

def data_440(+input: Nat) -> R.Node:
  R.Node{data_12(), data_264(input), data_2(), False{}, 0, 16384, 0, 0n, data_274(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_441(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_407(input), data_416(input), data_440(input), data_374(input)]

def data_442(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_443() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_444() -> List<&2, C.Task>:
  [data_443(), data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_445(+input: Nat) -> C.Machine:
  C.Machine{data_442(input), data_444(), data_113()}

def data_446() -> O.Task:
  O.TrimDeps{4n}

def data_447() -> List<&2, O.Task>:
  [data_446()]

def data_448() -> C.Task:
  C.OwnerTasks{data_447()}

def data_449() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_450() -> List<&2, C.Task>:
  [data_448(), data_449(), data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_442(input), data_450(), data_113()}

def data_452() -> List<&2, C.Task>:
  [data_429(), data_449(), data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_453(+input: Nat) -> C.Machine:
  C.Machine{data_442(input), data_452(), data_113()}

def data_454() -> List<&2, C.Task>:
  [data_449(), data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_455(+input: Nat) -> C.Machine:
  C.Machine{data_442(input), data_454(), data_113()}

def data_456() -> List<&2, C.Task>:
  [data_437(), data_399(), data_400(), data_395(), data_117(), data_118()]

def data_457(+input: Nat) -> C.Machine:
  C.Machine{data_442(input), data_456(), data_113()}

def data_458(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_459() -> List<&2, C.Task>:
  [data_399(), data_400(), data_395(), data_117(), data_118()]

def data_460(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_459(), data_113()}

def data_461() -> List<&2, C.Task>:
  [data_400(), data_395(), data_117(), data_118()]

def data_462(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_461(), data_113()}

def data_463(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_464() -> C.SeamFrame:
  C.SeamFrame{0n, data_376(), data_36()}

def data_465() -> C.Task:
  C.LandTransactions{data_464(), 0n}

def data_466() -> List<&2, C.Task>:
  [data_465(), data_395(), data_117(), data_118()]

def data_467(+input: Nat) -> C.Machine:
  C.Machine{data_463(input), data_466(), data_113()}

def data_468() -> C.Task:
  C.CompleteSettle{data_464()}

def data_469() -> List<&2, C.Task>:
  [data_468(), data_395(), data_117(), data_118()]

def data_470(+input: Nat) -> C.Machine:
  C.Machine{data_463(input), data_469(), data_113()}

def data_471() -> C.Task:
  C.ZombieLoop{data_35()}

def data_472() -> List<&2, C.Task>:
  [data_471(), data_395(), data_117(), data_118()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_472(), data_113()}

def data_474() -> List<&2, C.Task>:
  [data_395(), data_117(), data_118()]

def data_475(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_474(), data_113()}

def data_476(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_376(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_477() -> C.Task:
  C.RenderQueue{}

def data_478() -> List<&2, C.Task>:
  [data_477(), data_117(), data_118()]

def data_479(+input: Nat) -> C.Machine:
  C.Machine{data_476(input), data_478(), data_113()}

def data_480(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_481() -> C.Task:
  C.RunEffect{5n}

def data_482() -> C.Task:
  C.UserQueue{}

def data_483() -> List<&2, C.Task>:
  [data_481(), data_482(), data_117(), data_118()]

def data_484(+input: Nat) -> C.Machine:
  C.Machine{data_480(input), data_483(), data_113()}

def data_485() -> C.Task:
  C.ApplyEffect{5n}

def data_486() -> C.Task:
  C.EffectFinally{5n, True{}, data_113()}

def data_487() -> List<&2, C.Task>:
  [data_485(), data_486(), data_482(), data_117(), data_118()]

def data_488(+input: Nat) -> C.Machine:
  C.Machine{data_480(input), data_487(), data_113()}

def data_489(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_365(input)}

def data_490(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_489(input)]

def data_491(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_365(input), data_18()}

def data_492(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_162(input), data_45(), data_253(input), data_48(), data_343(input), data_358(input), data_491(input)]

def data_493(+input: Nat) -> R.World:
  R.World{data_441(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_490(input), data_492(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_494() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_495() -> List<&2, C.Task>:
  [data_494(), data_486(), data_482(), data_117(), data_118()]

def data_496(+input: Nat) -> C.Machine:
  C.Machine{data_493(input), data_495(), data_113()}

def data_497() -> List<&2, C.Task>:
  [data_486(), data_482(), data_117(), data_118()]

def data_498(+input: Nat) -> C.Machine:
  C.Machine{data_493(input), data_497(), data_113()}

def data_499(+input: Nat) -> R.Node:
  R.Node{data_23(), data_365(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_365(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_500(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_407(input), data_416(input), data_440(input), data_499(input)]

def data_501(+input: Nat) -> R.World:
  R.World{data_500(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_490(input), data_492(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_502() -> O.Task:
  O.TrimDeps{5n}

def data_503() -> List<&2, O.Task>:
  [data_502()]

def data_504() -> C.Task:
  C.OwnerTasks{data_503()}

def data_505() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_113()}

def data_506() -> List<&2, C.Task>:
  [data_504(), data_505(), data_482(), data_117(), data_118()]

def data_507(+input: Nat) -> C.Machine:
  C.Machine{data_501(input), data_506(), data_113()}

def data_508() -> List<&2, C.Task>:
  [data_429(), data_505(), data_482(), data_117(), data_118()]

def data_509(+input: Nat) -> C.Machine:
  C.Machine{data_501(input), data_508(), data_113()}

def data_510() -> List<&2, C.Task>:
  [data_505(), data_482(), data_117(), data_118()]

def data_511(+input: Nat) -> C.Machine:
  C.Machine{data_501(input), data_510(), data_113()}

def data_512() -> List<&2, C.Task>:
  [data_482(), data_117(), data_118()]

def data_513(+input: Nat) -> C.Machine:
  C.Machine{data_501(input), data_512(), data_113()}

def data_514() -> List<&2, C.Task>:
  [data_117(), data_118()]

def data_515(+input: Nat) -> C.Machine:
  C.Machine{data_501(input), data_514(), data_113()}

def data_516(+input: Nat) -> R.World:
  R.World{data_500(input), data_357(), data_299(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_490(input), data_492(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_517() -> List<&2, C.Task>:
  [data_118()]

def data_518(+input: Nat) -> C.Machine:
  C.Machine{data_516(input), data_517(), data_113()}

def data_519() -> List<&2, C.Task>:
  []

def data_520(+input: Nat) -> C.Machine:
  C.Machine{data_516(input), data_519(), data_113()}

def data_521(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_181(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_522(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_521(input), data_104(), data_105()]

def data_523(+input: Nat) -> R.World:
  R.World{data_522(input), data_161(), data_130(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_163(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_524(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_273(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_525(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_524(input), data_105()]

def data_526(+input: Nat) -> R.World:
  R.World{data_525(input), data_239(), data_130(), 1n, 2n, False{}, data_199(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_254(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_527() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_528(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_197(input), data_287(input), data_527()]

def data_529(+input: Nat) -> R.World:
  R.World{data_528(input), data_357(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_530(+input: Nat) -> R.World:
  R.World{data_528(input), data_357(), data_299(), 2n, 2n, False{}, data_289(), data_35(), data_376(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_359(input), data_53(), False{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_109(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_531() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_532(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_100(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_533(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_532(input), data_17(), data_22(), data_26()]

def data_534(+input: Nat) -> R.World:
  R.World{data_533(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_535(+input: Nat) -> R.World:
  R.World{data_106(input), data_33(), data_107(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_536(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_17(), data_22(), data_26()]

def data_537(+input: Nat) -> R.World:
  R.World{data_536(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def data_538() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_539(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_102(input), data_103(), data_104(), data_538()]

def data_540() -> List<&2, Nat>:
  [3n]

def data_541(+input: Nat) -> R.World:
  R.World{data_539(input), data_33(), data_540(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_57(), data_60(), data_35(), 0n, False{}, False{}, data_61(), 0n, data_64(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_55(), data_65(), data_68(), data_70(), data_71(), 0n, data_74(), data_76(), data_78(), data_79(), data_81(), False{}, False{}, data_55(), data_83(), data_85(), data_88(), 0n, data_65(), False{}, data_89(), data_90(), data_91(), 0n, data_92(), data_93(), data_94(), data_95(), data_96(), 0n, data_97()}

def origin() -> R.World:
  data_98()

def state_0(+input: Nat) -> C.Machine:
  data_114(input)

def state_1(+input: Nat) -> C.Machine:
  data_120(input)

def state_2(+input: Nat) -> C.Machine:
  data_124(input)

def state_3(+input: Nat) -> C.Machine:
  data_127(input)

def state_4(+input: Nat) -> C.Machine:
  data_134(input)

def state_5(+input: Nat) -> C.Machine:
  data_137(input)

def state_6(+input: Nat) -> C.Machine:
  data_146(input)

def state_7(+input: Nat) -> C.Machine:
  data_151(input)

def state_8(+input: Nat) -> C.Machine:
  data_154(input)

def state_9(+input: Nat) -> C.Machine:
  data_157(input)

def state_10(+input: Nat) -> C.Machine:
  data_167(input)

def state_11(+input: Nat) -> C.Machine:
  data_170(input)

def state_12(+input: Nat) -> C.Machine:
  data_174(input)

def state_13(+input: Nat) -> C.Machine:
  data_180(input)

def state_14(+input: Nat) -> C.Machine:
  data_191(input)

def state_15(+input: Nat) -> C.Machine:
  data_193(input)

def state_16(+input: Nat) -> C.Machine:
  data_196(input)

def state_17(+input: Nat) -> C.Machine:
  data_201(input)

def state_18(+input: Nat) -> C.Machine:
  data_203(input)

def state_19(+input: Nat) -> C.Machine:
  data_206(input)

def state_20(+input: Nat) -> C.Machine:
  data_212(input)

def state_21(+input: Nat) -> C.Machine:
  data_215(input)

def state_22(+input: Nat) -> C.Machine:
  data_224(input)

def state_23(+input: Nat) -> C.Machine:
  data_229(input)

def state_24(+input: Nat) -> C.Machine:
  data_232(input)

def state_25(+input: Nat) -> C.Machine:
  data_235(input)

def state_26(+input: Nat) -> C.Machine:
  data_244(input)

def state_27(+input: Nat) -> C.Machine:
  data_246(input)

def state_28(+input: Nat) -> C.Machine:
  data_250(input)

def state_29(+input: Nat) -> C.Machine:
  data_257(input)

def state_30(+input: Nat) -> C.Machine:
  data_259(input)

def state_31(+input: Nat) -> C.Machine:
  data_262(input)

def state_32(+input: Nat) -> C.Machine:
  data_266(input)

def state_33(+input: Nat) -> C.Machine:
  data_272(input)

def state_34(+input: Nat) -> C.Machine:
  data_281(input)

def state_35(+input: Nat) -> C.Machine:
  data_283(input)

def state_36(+input: Nat) -> C.Machine:
  data_286(input)

def state_37(+input: Nat) -> C.Machine:
  data_291(input)

def state_38(+input: Nat) -> C.Machine:
  data_293(input)

def state_39(+input: Nat) -> C.Machine:
  data_296(input)

def state_40(+input: Nat) -> C.Machine:
  data_303(input)

def state_41(+input: Nat) -> C.Machine:
  data_306(input)

def state_42(+input: Nat) -> C.Machine:
  data_315(input)

def state_43(+input: Nat) -> C.Machine:
  data_319(input)

def state_44(+input: Nat) -> C.Machine:
  data_322(input)

def state_45(+input: Nat) -> C.Machine:
  data_325(input)

def state_46(+input: Nat) -> C.Machine:
  data_334(input)

def state_47(+input: Nat) -> C.Machine:
  data_336(input)

def state_48(+input: Nat) -> C.Machine:
  data_340(input)

def state_49(+input: Nat) -> C.Machine:
  data_347(input)

def state_50(+input: Nat) -> C.Machine:
  data_349(input)

def state_51(+input: Nat) -> C.Machine:
  data_351(input)

def state_52(+input: Nat) -> C.Machine:
  data_353(input)

def state_53(+input: Nat) -> C.Machine:
  data_363(input)

def state_54(+input: Nat) -> C.Machine:
  data_367(input)

def state_55(+input: Nat) -> C.Machine:
  data_373(input)

def state_56(+input: Nat) -> C.Machine:
  data_381(input)

def state_57(+input: Nat) -> C.Machine:
  data_383(input)

def state_58(+input: Nat) -> C.Machine:
  data_386(input)

def state_59(+input: Nat) -> C.Machine:
  data_387(input)

def state_60(+input: Nat) -> C.Machine:
  data_389(input)

def state_61(+input: Nat) -> C.Machine:
  data_393(input)

def state_62(+input: Nat) -> C.Machine:
  data_397(input)

def state_63(+input: Nat) -> C.Machine:
  data_402(input)

def state_64(+input: Nat) -> C.Machine:
  data_406(input)

def state_65(+input: Nat) -> C.Machine:
  data_411(input)

def state_66(+input: Nat) -> C.Machine:
  data_415(input)

def state_67(+input: Nat) -> C.Machine:
  data_421(input)

def state_68(+input: Nat) -> C.Machine:
  data_427(input)

def state_69(+input: Nat) -> C.Machine:
  data_431(input)

def state_70(+input: Nat) -> C.Machine:
  data_433(input)

def state_71(+input: Nat) -> C.Machine:
  data_435(input)

def state_72(+input: Nat) -> C.Machine:
  data_439(input)

def state_73(+input: Nat) -> C.Machine:
  data_445(input)

def state_74(+input: Nat) -> C.Machine:
  data_451(input)

def state_75(+input: Nat) -> C.Machine:
  data_453(input)

def state_76(+input: Nat) -> C.Machine:
  data_455(input)

def state_77(+input: Nat) -> C.Machine:
  data_457(input)

def state_78(+input: Nat) -> C.Machine:
  data_460(input)

def state_79(+input: Nat) -> C.Machine:
  data_462(input)

def state_80(+input: Nat) -> C.Machine:
  data_467(input)

def state_81(+input: Nat) -> C.Machine:
  data_470(input)

def state_82(+input: Nat) -> C.Machine:
  data_473(input)

def state_83(+input: Nat) -> C.Machine:
  data_475(input)

def state_84(+input: Nat) -> C.Machine:
  data_479(input)

def state_85(+input: Nat) -> C.Machine:
  data_484(input)

def state_86(+input: Nat) -> C.Machine:
  data_488(input)

def state_87(+input: Nat) -> C.Machine:
  data_496(input)

def state_88(+input: Nat) -> C.Machine:
  data_498(input)

def state_89(+input: Nat) -> C.Machine:
  data_507(input)

def state_90(+input: Nat) -> C.Machine:
  data_509(input)

def state_91(+input: Nat) -> C.Machine:
  data_511(input)

def state_92(+input: Nat) -> C.Machine:
  data_513(input)

def state_93(+input: Nat) -> C.Machine:
  data_515(input)

def state_94(+input: Nat) -> C.Machine:
  data_518(input)

def state_95(+input: Nat) -> C.Machine:
  data_520(input)

def finalWorld(+input: Nat) -> R.World:
  data_516(input)

def slot_13(+input: Nat) -> R.World:
  data_523(input)

def notify_13(+input: Nat) -> R.World:
  data_187(input)

def slot_33(+input: Nat) -> R.World:
  data_526(input)

def notify_33(+input: Nat) -> R.World:
  data_277(input)

def modified_55(+input: Nat) -> R.World:
  data_529(input)

def queued_55(+input: Nat) -> R.World:
  data_530(input)

def value_55(+input: Nat) -> R.World:
  data_377(input)

def setter_queued(+input: Nat) -> R.World:
  data_531()

def setter_slot(+input: Nat) -> R.World:
  data_534(input)

def setter_inserted(+input: Nat) -> R.World:
  data_535(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_110(input)

def setter_stamped(+input: Nat) -> R.World:
  data_537(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_541(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_535(input)

