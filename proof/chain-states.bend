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
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 0, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

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

def data_54() -> R.Flight:
  R.FlightEmpty{}

def data_55() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_56() -> R.Question:
  R.QuestionZero{}

def data_57() -> R.NodeExtension:
  R.NodeExtension{data_54(), 0n, data_1(), data_2(), 0n, 0n, data_55(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_56(), data_2(), 0n, data_1()}

def data_58() -> List<&2, R.NodeExtension>:
  [data_57()]

def data_59() -> List<&2, R.CleanupAction>:
  []

def data_60() -> R.CleanupProgram:
  R.CleanupProgram{data_59(), False{}, 0n}

def data_61() -> List<&2, R.CleanupProgram>:
  [data_60()]

def data_62() -> List<&2, R.Report>:
  []

def data_63() -> R.OptionalIds:
  R.NoIds{}

def data_64() -> R.Transaction:
  R.Transaction{data_35(), data_35(), data_36(), data_35(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_63()}

def data_65() -> List<&2, R.Transaction>:
  [data_64()]

def data_66() -> List<&2, List<&2, Nat>>:
  [data_35()]

def data_67() -> R.AsyncSettlement:
  R.Unresolved{}

def data_68() -> R.AsyncObject:
  R.AsyncObject{False{}, data_67(), data_35(), 0n}

def data_69() -> List<&2, R.AsyncObject>:
  [data_68()]

def data_70() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_71() -> List<&2, R.AsyncObserver>:
  [data_70()]

def data_72() -> List<&2, R.HostJob>:
  []

def data_73() -> List<&2, R.NextInput>:
  []

def data_74() -> R.FromState:
  R.FromNone{}

def data_75() -> R.StreamPlan:
  R.StreamPlan{data_73(), False{}, data_2(), 0n, 0n, data_2(), data_74()}

def data_76() -> List<&2, R.StreamPlan>:
  [data_75()]

def data_77() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_78() -> List<&2, R.ExternalIterator>:
  [data_77()]

def data_79() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_80() -> List<&2, R.StreamState>:
  [data_79()]

def data_81() -> List<&2, R.IteratorEvent>:
  []

def data_82() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_67(), False{}, 0n, False{}, False{}, 0n}

def data_83() -> List<&2, R.Awaiter>:
  [data_82()]

def data_84() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_85() -> List<&2, R.AbortInput>:
  [data_84()]

def data_86() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_87() -> List<&2, R.ContextKey>:
  [data_86()]

def data_88() -> List<&2, R.ContextEntry>:
  []

def data_89() -> R.ContextRecord:
  R.ContextRecord{data_88()}

def data_90() -> List<&2, R.ContextRecord>:
  [data_89()]

def data_91() -> List<&2, R.Expr>:
  [data_4()]

def data_92() -> List<&2, R.ReactionState>:
  []

def data_93() -> List<&2, R.ComparatorBinding>:
  []

def data_94() -> List<&2, R.ActionState>:
  []

def data_95() -> List<&2, R.ActionWait>:
  []

def data_96() -> List<&2, R.ArrayData>:
  []

def data_97() -> List<&2, R.RepeatState>:
  []

def data_98() -> List<&2, R.MapState>:
  []

def data_99() -> List<&2, R.Guess>:
  []

def data_100() -> R.LaneMount:
  R.MountUnset{}

def data_101() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_99(), 0n, data_100(), data_35()}

def data_102() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_103() -> R.Value:
  R.Null{}

def data_104() -> R.DeferredCell:
  R.DeferredCell{0n, data_103(), False{}, False{}}

def data_105() -> R.DeferredBinding:
  R.DeferredBinding{data_104(), 0n}

def data_106() -> List<&2, R.DeferredBinding>:
  [data_105()]

def data_107() -> List<&2, R.DeferredWait>:
  []

def data_108() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_109() -> List<&2, R.DeferredIterator>:
  [data_108()]

def data_110() -> R.DeferredArena:
  R.DeferredArena{data_106(), data_35(), data_107(), data_109()}

def data_111() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_112(+input: Nat) -> R.Value:
  R.Number{input}

def data_113(+input: Nat) -> R.Slot:
  R.Present{data_112(input)}

def data_114() -> R.Stamp:
  R.Stamped{7n}

def data_115(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_113(input), False{}, 0, 0, 0, 0n, data_114(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_116() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_117() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_118() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_119(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_116(), data_117(), data_118()]

def data_120() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_121() -> R.HostJob:
  R.FlushJob{}

def data_122() -> List<&2, R.HostJob>:
  [data_121()]

def data_123(+input: Nat) -> R.World:
  R.World{data_119(input), data_33(), data_120(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_124() -> C.Task:
  C.Round{}

def data_125() -> List<&2, C.Task>:
  [data_124()]

def data_126() -> List<&2, R.Value>:
  []

def data_127(+input: Nat) -> C.Machine:
  C.Machine{data_123(input), data_125(), data_126()}

def data_128(+input: Nat) -> R.World:
  R.World{data_119(input), data_33(), data_120(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_129() -> C.Task:
  C.RoundAfterSweep{}

def data_130() -> C.Task:
  C.FlushFinally{}

def data_131() -> C.Task:
  C.RoundEnd{}

def data_132() -> List<&2, C.Task>:
  [data_129(), data_130(), data_131()]

def data_133(+input: Nat) -> C.Machine:
  C.Machine{data_128(input), data_132(), data_126()}

def data_134(+input: Nat) -> R.World:
  R.World{data_119(input), data_33(), data_120(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_135() -> C.Task:
  C.HeapLoop{}

def data_136() -> List<&2, C.Task>:
  [data_135(), data_130(), data_131()]

def data_137(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_136(), data_126()}

def data_138() -> C.Task:
  C.Recompute{3n, False{}}

def data_139() -> List<&2, C.Task>:
  [data_138(), data_135(), data_130(), data_131()]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_134(input), data_139(), data_126()}

def data_141() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_142(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_141(), data_117(), data_118()]

def data_143() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_144() -> R.LaneMount:
  R.MountFalse{}

def data_145() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_99(), 0n, data_144(), data_35()}

def data_146(+input: Nat) -> R.World:
  R.World{data_142(input), data_33(), data_143(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_147() -> C.LanePass:
  C.LanePass{0n, data_100(), data_144()}

def data_148() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_147()}

def data_149() -> List<&2, C.Task>:
  [data_148(), data_135(), data_130(), data_131()]

def data_150(+input: Nat) -> C.Machine:
  C.Machine{data_146(input), data_149(), data_126()}

def data_151() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_147()}

def data_152() -> List<&2, C.Task>:
  [data_151(), data_135(), data_130(), data_131()]

def data_153(+input: Nat) -> C.Machine:
  C.Machine{data_146(input), data_152(), data_126()}

def data_154() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_155(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_154(), data_117(), data_118()]

def data_156() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_157(+input: Nat) -> R.World:
  R.World{data_155(input), data_33(), data_143(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_156(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_158() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_159() -> R.Flight:
  R.FlightUndefined{}

def data_160() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, data_159(), data_126(), 0n, False{}, data_147()}

def data_161() -> C.Task:
  C.Finish{data_160()}

def data_162() -> List<&2, C.Task>:
  [data_158(), data_161(), data_135(), data_130(), data_131()]

def data_163(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_162(), data_126()}

def data_164() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_165() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_166() -> C.Task:
  C.Binary{0}

def data_167() -> List<&2, C.Task>:
  [data_164(), data_165(), data_166(), data_161(), data_135(), data_130(), data_131()]

def data_168(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_167(), data_126()}

def data_169() -> C.Task:
  C.ReadNode{2n}

def data_170() -> List<&2, C.Task>:
  [data_169(), data_165(), data_166(), data_161(), data_135(), data_130(), data_131()]

def data_171(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_170(), data_126()}

def data_172() -> C.Task:
  C.ReadPrepared{2n}

def data_173() -> List<&2, C.Task>:
  [data_172(), data_165(), data_166(), data_161(), data_135(), data_130(), data_131()]

def data_174(+input: Nat) -> C.Machine:
  C.Machine{data_157(input), data_173(), data_126()}

def data_175() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_176(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_175(), data_117(), data_118()]

def data_177() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_178() -> List<&2, R.Link>:
  [data_28(), data_177(), data_30(), data_31(), data_32()]

def data_179(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_112(input)}

def data_180(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input)]

def data_181(+input: Nat) -> R.World:
  R.World{data_176(input), data_178(), data_143(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_182() -> List<&2, C.Task>:
  [data_165(), data_166(), data_161(), data_135(), data_130(), data_131()]

def data_183(+input: Nat) -> List<&2, R.Value>:
  [data_112(input)]

def data_184(+input: Nat) -> C.Machine:
  C.Machine{data_181(input), data_182(), data_183(input)}

def data_185() -> List<&2, C.Task>:
  [data_166(), data_161(), data_135(), data_130(), data_131()]

def data_186(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_112(input)]

def data_187(+input: Nat) -> C.Machine:
  C.Machine{data_181(input), data_185(), data_186(input)}

def data_188() -> List<&2, C.Task>:
  [data_161(), data_135(), data_130(), data_131()]

def data_189(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_190(+input: Nat) -> List<&2, R.Value>:
  [data_189(input)]

def data_191(+input: Nat) -> C.Machine:
  C.Machine{data_181(input), data_188(), data_190(input)}

def data_192() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_193(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_192(), data_117(), data_118()]

def data_194(+input: Nat) -> R.World:
  R.World{data_193(input), data_178(), data_143(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_195(+input: Nat) -> C.Task:
  C.PassReleases{data_160(), 0n, data_189(input), False{}, False{}, False{}, data_53()}

def data_196(+input: Nat) -> List<&2, C.Task>:
  [data_195(input), data_135(), data_130(), data_131()]

def data_197(+input: Nat) -> C.Machine:
  C.Machine{data_194(input), data_196(input), data_126()}

def data_198(+input: Nat) -> R.Slot:
  R.Present{data_189(input)}

def data_199() -> R.Stamp:
  R.Stamped{8n}

def data_200(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_198(input), False{}, 0, 16384, 0, 0n, data_199(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_201() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_202(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_200(input), data_201(), data_118()]

def data_203() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_204(+input: Nat) -> R.World:
  R.World{data_202(input), data_178(), data_203(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_205() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_206() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_207() -> List<&2, C.Task>:
  [data_205(), data_206(), data_135(), data_130(), data_131()]

def data_208(+input: Nat) -> C.Machine:
  C.Machine{data_204(input), data_207(), data_126()}

def data_209() -> List<&2, C.Task>:
  [data_206(), data_135(), data_130(), data_131()]

def data_210(+input: Nat) -> C.Machine:
  C.Machine{data_204(input), data_209(), data_126()}

def data_211() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_212() -> List<&2, C.Task>:
  [data_211(), data_135(), data_130(), data_131()]

def data_213(+input: Nat) -> C.Machine:
  C.Machine{data_204(input), data_212(), data_126()}

def data_214(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_198(input), False{}, 128, 16384, 0, 0n, data_199(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_215(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_201(), data_118()]

def data_216() -> List<&2, Nat>:
  [2n, 3n]

def data_217(+input: Nat) -> R.World:
  R.World{data_215(input), data_178(), data_203(), 0n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_218(+input: Nat) -> C.Machine:
  C.Machine{data_217(input), data_136(), data_126()}

def data_219(+input: Nat) -> R.World:
  R.World{data_215(input), data_178(), data_203(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_220(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_136(), data_126()}

def data_221() -> C.Task:
  C.Recompute{4n, False{}}

def data_222() -> List<&2, C.Task>:
  [data_221(), data_135(), data_130(), data_131()]

def data_223(+input: Nat) -> C.Machine:
  C.Machine{data_219(input), data_222(), data_126()}

def data_224() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_225(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_224(), data_118()]

def data_226(+input: Nat) -> R.World:
  R.World{data_225(input), data_178(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_227() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_147()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_135(), data_130(), data_131()]

def data_229(+input: Nat) -> C.Machine:
  C.Machine{data_226(input), data_228(), data_126()}

def data_230() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_147()}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_135(), data_130(), data_131()]

def data_232(+input: Nat) -> C.Machine:
  C.Machine{data_226(input), data_231(), data_126()}

def data_233() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_234(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_233(), data_118()]

def data_235(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45()]

def data_236(+input: Nat) -> R.World:
  R.World{data_234(input), data_178(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_235(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_237() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_238() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_159(), data_126(), 0n, False{}, data_147()}

def data_239() -> C.Task:
  C.Finish{data_238()}

def data_240() -> List<&2, C.Task>:
  [data_237(), data_239(), data_135(), data_130(), data_131()]

def data_241(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_240(), data_126()}

def data_242() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_243() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_244() -> C.Task:
  C.Binary{1}

def data_245() -> List<&2, C.Task>:
  [data_242(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_246(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_245(), data_126()}

def data_247() -> C.Task:
  C.ReadNode{3n}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_249(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_248(), data_126()}

def data_250() -> C.Task:
  C.ReadPrepared{3n}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_252(+input: Nat) -> C.Machine:
  C.Machine{data_236(input), data_251(), data_126()}

def data_253() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_254(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_253(), data_118()]

def data_255() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_256() -> List<&2, R.Link>:
  [data_28(), data_177(), data_255(), data_31(), data_32()]

def data_257(+input: Nat) -> R.World:
  R.World{data_254(input), data_256(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_235(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_258() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_259() -> C.Task:
  C.ReadStatus{3n}

def data_260() -> List<&2, C.Task>:
  [data_258(), data_259(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_261(+input: Nat) -> C.Machine:
  C.Machine{data_257(input), data_260(), data_126()}

def data_262() -> List<&2, C.Task>:
  [data_259(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_263(+input: Nat) -> C.Machine:
  C.Machine{data_257(input), data_262(), data_126()}

def data_264() -> C.Task:
  C.Serve{3n}

def data_265() -> C.Task:
  C.AfterServe{3n}

def data_266() -> List<&2, C.Task>:
  [data_264(), data_265(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_267(+input: Nat) -> C.Machine:
  C.Machine{data_257(input), data_266(), data_126()}

def data_268() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_269(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_268(), data_118()]

def data_270(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_189(input)}

def data_271(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45(), data_270(input)]

def data_272(+input: Nat) -> R.World:
  R.World{data_269(input), data_256(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_273() -> List<&2, C.Task>:
  [data_265(), data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_274(+input: Nat) -> C.Machine:
  C.Machine{data_272(input), data_273(), data_190(input)}

def data_275() -> List<&2, C.Task>:
  [data_243(), data_244(), data_239(), data_135(), data_130(), data_131()]

def data_276(+input: Nat) -> C.Machine:
  C.Machine{data_272(input), data_275(), data_190(input)}

def data_277() -> List<&2, C.Task>:
  [data_244(), data_239(), data_135(), data_130(), data_131()]

def data_278(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_189(input)]

def data_279(+input: Nat) -> C.Machine:
  C.Machine{data_272(input), data_277(), data_278(input)}

def data_280() -> List<&2, C.Task>:
  [data_239(), data_135(), data_130(), data_131()]

def data_281(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_282(+input: Nat) -> List<&2, R.Value>:
  [data_281(input)]

def data_283(+input: Nat) -> C.Machine:
  C.Machine{data_272(input), data_280(), data_282(input)}

def data_284() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_285(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_284(), data_118()]

def data_286(+input: Nat) -> R.World:
  R.World{data_285(input), data_256(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_287(+input: Nat) -> C.Task:
  C.PassReleases{data_238(), 0n, data_281(input), False{}, False{}, False{}, data_53()}

def data_288(+input: Nat) -> List<&2, C.Task>:
  [data_287(input), data_135(), data_130(), data_131()]

def data_289(+input: Nat) -> C.Machine:
  C.Machine{data_286(input), data_288(input), data_126()}

def data_290(+input: Nat) -> R.Slot:
  R.Present{data_281(input)}

def data_291() -> R.Stamp:
  R.Stamped{9n}

def data_292(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_290(input), False{}, 0, 16384, 0, 0n, data_291(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_293(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_292(input), data_118()]

def data_294(+input: Nat) -> R.World:
  R.World{data_293(input), data_256(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_295() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_296() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_297() -> List<&2, C.Task>:
  [data_295(), data_296(), data_135(), data_130(), data_131()]

def data_298(+input: Nat) -> C.Machine:
  C.Machine{data_294(input), data_297(), data_126()}

def data_299() -> List<&2, C.Task>:
  [data_296(), data_135(), data_130(), data_131()]

def data_300(+input: Nat) -> C.Machine:
  C.Machine{data_294(input), data_299(), data_126()}

def data_301() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_302() -> List<&2, C.Task>:
  [data_301(), data_135(), data_130(), data_131()]

def data_303(+input: Nat) -> C.Machine:
  C.Machine{data_294(input), data_302(), data_126()}

def data_304(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_290(input), False{}, 128, 16384, 0, 0n, data_291(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_305(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_118()]

def data_306() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_307(+input: Nat) -> R.World:
  R.World{data_305(input), data_256(), data_143(), 1n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_308(+input: Nat) -> C.Machine:
  C.Machine{data_307(input), data_136(), data_126()}

def data_309(+input: Nat) -> R.World:
  R.World{data_305(input), data_256(), data_143(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_310(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_136(), data_126()}

def data_311() -> C.Task:
  C.Recompute{5n, False{}}

def data_312() -> List<&2, C.Task>:
  [data_311(), data_135(), data_130(), data_131()]

def data_313(+input: Nat) -> C.Machine:
  C.Machine{data_309(input), data_312(), data_126()}

def data_314() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_315(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_314()]

def data_316() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_317(+input: Nat) -> R.World:
  R.World{data_315(input), data_256(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_318() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_147()}

def data_319() -> List<&2, C.Task>:
  [data_318(), data_135(), data_130(), data_131()]

def data_320(+input: Nat) -> C.Machine:
  C.Machine{data_317(input), data_319(), data_126()}

def data_321() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_147()}

def data_322() -> List<&2, C.Task>:
  [data_321(), data_135(), data_130(), data_131()]

def data_323(+input: Nat) -> C.Machine:
  C.Machine{data_317(input), data_322(), data_126()}

def data_324() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_325(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_324()]

def data_326(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45(), data_270(input), data_48()]

def data_327(+input: Nat) -> R.World:
  R.World{data_325(input), data_256(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_326(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_328() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_329() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_159(), data_126(), 0n, False{}, data_147()}

def data_330() -> C.Task:
  C.Finish{data_329()}

def data_331() -> List<&2, C.Task>:
  [data_328(), data_330(), data_135(), data_130(), data_131()]

def data_332(+input: Nat) -> C.Machine:
  C.Machine{data_327(input), data_331(), data_126()}

def data_333() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_334() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_335() -> List<&2, C.Task>:
  [data_333(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_336(+input: Nat) -> C.Machine:
  C.Machine{data_327(input), data_335(), data_126()}

def data_337() -> C.Task:
  C.ReadNode{4n}

def data_338() -> List<&2, C.Task>:
  [data_337(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_339(+input: Nat) -> C.Machine:
  C.Machine{data_327(input), data_338(), data_126()}

def data_340() -> C.Task:
  C.ReadPrepared{4n}

def data_341() -> List<&2, C.Task>:
  [data_340(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_342(+input: Nat) -> C.Machine:
  C.Machine{data_327(input), data_341(), data_126()}

def data_343() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_344(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_343()]

def data_345() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_346() -> List<&2, R.Link>:
  [data_28(), data_177(), data_255(), data_345(), data_32()]

def data_347(+input: Nat) -> R.World:
  R.World{data_344(input), data_346(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_326(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_348() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_349() -> C.Task:
  C.ReadStatus{4n}

def data_350() -> List<&2, C.Task>:
  [data_348(), data_349(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_351(+input: Nat) -> C.Machine:
  C.Machine{data_347(input), data_350(), data_126()}

def data_352() -> List<&2, C.Task>:
  [data_349(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_353(+input: Nat) -> C.Machine:
  C.Machine{data_347(input), data_352(), data_126()}

def data_354() -> C.Task:
  C.Serve{4n}

def data_355() -> C.Task:
  C.AfterServe{4n}

def data_356() -> List<&2, C.Task>:
  [data_354(), data_355(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_357(+input: Nat) -> C.Machine:
  C.Machine{data_347(input), data_356(), data_126()}

def data_358() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_359(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_358()]

def data_360(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_281(input)}

def data_361(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45(), data_270(input), data_48(), data_360(input)]

def data_362(+input: Nat) -> R.World:
  R.World{data_359(input), data_346(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_361(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_363() -> List<&2, C.Task>:
  [data_355(), data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_364(+input: Nat) -> C.Machine:
  C.Machine{data_362(input), data_363(), data_282(input)}

def data_365() -> List<&2, C.Task>:
  [data_334(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_366(+input: Nat) -> C.Machine:
  C.Machine{data_362(input), data_365(), data_282(input)}

def data_367() -> List<&2, C.Task>:
  [data_169(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_368(+input: Nat) -> C.Machine:
  C.Machine{data_362(input), data_367(), data_282(input)}

def data_369() -> List<&2, C.Task>:
  [data_172(), data_166(), data_330(), data_135(), data_130(), data_131()]

def data_370(+input: Nat) -> C.Machine:
  C.Machine{data_362(input), data_369(), data_282(input)}

def data_371() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_372(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_371()]

def data_373() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_374() -> List<&2, R.Link>:
  [data_28(), data_177(), data_255(), data_345(), data_373()]

def data_375(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_112(input)}

def data_376(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45(), data_270(input), data_48(), data_360(input), data_375(input)]

def data_377(+input: Nat) -> R.World:
  R.World{data_372(input), data_374(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_145(), data_102(), data_2(), data_35(), data_110()}

def data_378() -> List<&2, C.Task>:
  [data_166(), data_330(), data_135(), data_130(), data_131()]

def data_379(+input: Nat) -> List<&2, R.Value>:
  [data_112(input), data_281(input)]

def data_380(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_378(), data_379(input)}

def data_381() -> List<&2, C.Task>:
  [data_330(), data_135(), data_130(), data_131()]

def data_382(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_383(+input: Nat) -> List<&2, R.Value>:
  [data_382(input)]

def data_384(+input: Nat) -> C.Machine:
  C.Machine{data_377(input), data_381(), data_383(input)}

def data_385() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_386(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_385()]

def data_387(+input: Nat) -> R.World:
  R.World{data_386(input), data_374(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_388(+input: Nat) -> C.Task:
  C.PassReleases{data_329(), 0n, data_382(input), False{}, False{}, False{}, data_53()}

def data_389(+input: Nat) -> List<&2, C.Task>:
  [data_388(input), data_135(), data_130(), data_131()]

def data_390(+input: Nat) -> C.Machine:
  C.Machine{data_387(input), data_389(input), data_126()}

def data_391(+input: Nat) -> R.Node:
  R.Node{data_23(), data_382(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_392(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_391(input)]

def data_393() -> List<&2, Nat>:
  [5n]

def data_394(+input: Nat) -> R.World:
  R.World{data_392(input), data_374(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_395() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_396() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_397() -> List<&2, C.Task>:
  [data_395(), data_396(), data_135(), data_130(), data_131()]

def data_398(+input: Nat) -> C.Machine:
  C.Machine{data_394(input), data_397(), data_126()}

def data_399() -> List<&2, C.Task>:
  [data_396(), data_135(), data_130(), data_131()]

def data_400(+input: Nat) -> C.Machine:
  C.Machine{data_394(input), data_399(), data_126()}

def data_401() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_402() -> List<&2, C.Task>:
  [data_401(), data_135(), data_130(), data_131()]

def data_403(+input: Nat) -> C.Machine:
  C.Machine{data_394(input), data_402(), data_126()}

def data_404(+input: Nat) -> C.Machine:
  C.Machine{data_394(input), data_136(), data_126()}

def data_405(+input: Nat) -> R.World:
  R.World{data_392(input), data_374(), data_316(), 3n, 2n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_406(+input: Nat) -> C.Machine:
  C.Machine{data_405(input), data_136(), data_126()}

def data_407(+input: Nat) -> R.World:
  R.World{data_392(input), data_374(), data_316(), 3n, 0n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_408() -> C.Task:
  C.Seam{}

def data_409() -> List<&2, C.Task>:
  [data_408(), data_130(), data_131()]

def data_410(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_409(), data_126()}

def data_411() -> C.Task:
  C.Settle{}

def data_412() -> C.Task:
  C.AfterSettle{}

def data_413() -> List<&2, C.Task>:
  [data_411(), data_412(), data_130(), data_131()]

def data_414(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_413(), data_126()}

def data_415() -> C.Task:
  C.CommitIntake{0n}

def data_416() -> C.Task:
  C.TrimIntake{0n}

def data_417() -> C.Task:
  C.FinishSettleIntake{0n}

def data_418() -> List<&2, C.Task>:
  [data_415(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_419(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_418(), data_126()}

def data_420() -> C.Task:
  C.CommitPending{2n}

def data_421() -> C.Task:
  C.CommitIntake{1n}

def data_422() -> List<&2, C.Task>:
  [data_420(), data_421(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_423(+input: Nat) -> C.Machine:
  C.Machine{data_407(input), data_422(), data_126()}

def data_424(+input: Nat) -> R.Node:
  R.Node{data_9(), data_112(input), data_2(), False{}, 0, 0, 0, 0n, data_114(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_425(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_424(input), data_214(input), data_304(input), data_391(input)]

def data_426(+input: Nat) -> R.World:
  R.World{data_425(input), data_374(), data_316(), 3n, 0n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_427() -> List<&2, C.Task>:
  [data_421(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_428(+input: Nat) -> C.Machine:
  C.Machine{data_426(input), data_427(), data_126()}

def data_429() -> C.Task:
  C.CommitPending{3n}

def data_430() -> C.Task:
  C.CommitIntake{2n}

def data_431() -> List<&2, C.Task>:
  [data_429(), data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_432(+input: Nat) -> C.Machine:
  C.Machine{data_426(input), data_431(), data_126()}

def data_433(+input: Nat) -> R.Node:
  R.Node{data_12(), data_189(input), data_2(), False{}, 0, 16384, 0, 0n, data_199(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_434(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_424(input), data_433(input), data_304(input), data_391(input)]

def data_435(+input: Nat) -> R.World:
  R.World{data_434(input), data_374(), data_316(), 3n, 0n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_436() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_437() -> List<&2, C.Task>:
  [data_436(), data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_438(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_437(), data_126()}

def data_439() -> O.Task:
  O.TrimDeps{3n}

def data_440() -> List<&2, O.Task>:
  [data_439()]

def data_441() -> C.Task:
  C.OwnerTasks{data_440()}

def data_442() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_443() -> List<&2, C.Task>:
  [data_441(), data_442(), data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_444(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_443(), data_126()}

def data_445() -> List<&2, O.Task>:
  []

def data_446() -> C.Task:
  C.OwnerTasks{data_445()}

def data_447() -> List<&2, C.Task>:
  [data_446(), data_442(), data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_448(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_447(), data_126()}

def data_449() -> List<&2, C.Task>:
  [data_442(), data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_450(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_449(), data_126()}

def data_451() -> List<&2, C.Task>:
  [data_430(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_452(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_451(), data_126()}

def data_453() -> C.Task:
  C.CommitPending{4n}

def data_454() -> C.Task:
  C.CommitIntake{3n}

def data_455() -> List<&2, C.Task>:
  [data_453(), data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_456(+input: Nat) -> C.Machine:
  C.Machine{data_435(input), data_455(), data_126()}

def data_457(+input: Nat) -> R.Node:
  R.Node{data_12(), data_281(input), data_2(), False{}, 0, 16384, 0, 0n, data_291(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_458(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_424(input), data_433(input), data_457(input), data_391(input)]

def data_459(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_460() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_461() -> List<&2, C.Task>:
  [data_460(), data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_462(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_461(), data_126()}

def data_463() -> O.Task:
  O.TrimDeps{4n}

def data_464() -> List<&2, O.Task>:
  [data_463()]

def data_465() -> C.Task:
  C.OwnerTasks{data_464()}

def data_466() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_467() -> List<&2, C.Task>:
  [data_465(), data_466(), data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_468(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_467(), data_126()}

def data_469() -> List<&2, C.Task>:
  [data_446(), data_466(), data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_470(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_469(), data_126()}

def data_471() -> List<&2, C.Task>:
  [data_466(), data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_472(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_471(), data_126()}

def data_473() -> List<&2, C.Task>:
  [data_454(), data_416(), data_417(), data_412(), data_130(), data_131()]

def data_474(+input: Nat) -> C.Machine:
  C.Machine{data_459(input), data_473(), data_126()}

def data_475(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_476() -> List<&2, C.Task>:
  [data_416(), data_417(), data_412(), data_130(), data_131()]

def data_477(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_476(), data_126()}

def data_478() -> List<&2, C.Task>:
  [data_417(), data_412(), data_130(), data_131()]

def data_479(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_478(), data_126()}

def data_480(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_481() -> C.SeamFrame:
  C.SeamFrame{0n, data_393(), data_36(), data_35(), data_36()}

def data_482() -> C.Task:
  C.LandTransactions{data_481(), 0n}

def data_483() -> List<&2, C.Task>:
  [data_482(), data_412(), data_130(), data_131()]

def data_484(+input: Nat) -> C.Machine:
  C.Machine{data_480(input), data_483(), data_126()}

def data_485() -> C.Task:
  C.CompleteSettle{data_481()}

def data_486() -> List<&2, C.Task>:
  [data_485(), data_412(), data_130(), data_131()]

def data_487(+input: Nat) -> C.Machine:
  C.Machine{data_480(input), data_486(), data_126()}

def data_488() -> C.Task:
  C.ZombieLoop{data_35()}

def data_489() -> List<&2, C.Task>:
  [data_488(), data_412(), data_130(), data_131()]

def data_490(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_489(), data_126()}

def data_491() -> List<&2, C.Task>:
  [data_412(), data_130(), data_131()]

def data_492(+input: Nat) -> C.Machine:
  C.Machine{data_475(input), data_491(), data_126()}

def data_493(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_393(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_494() -> C.Task:
  C.RenderQueue{}

def data_495() -> List<&2, C.Task>:
  [data_494(), data_130(), data_131()]

def data_496(+input: Nat) -> C.Machine:
  C.Machine{data_493(input), data_495(), data_126()}

def data_497(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_498() -> C.Task:
  C.RunEffect{5n}

def data_499() -> C.Task:
  C.UserQueue{}

def data_500() -> List<&2, C.Task>:
  [data_498(), data_499(), data_130(), data_131()]

def data_501(+input: Nat) -> C.Machine:
  C.Machine{data_497(input), data_500(), data_126()}

def data_502() -> C.Task:
  C.ApplyEffect{5n}

def data_503() -> C.Task:
  C.EffectFinally{5n, True{}, data_126()}

def data_504() -> List<&2, C.Task>:
  [data_502(), data_503(), data_499(), data_130(), data_131()]

def data_505(+input: Nat) -> C.Machine:
  C.Machine{data_497(input), data_504(), data_126()}

def data_506(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_382(input)}

def data_507(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_506(input)]

def data_508(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_382(input), data_18()}

def data_509(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_179(input), data_45(), data_270(input), data_48(), data_360(input), data_375(input), data_508(input)]

def data_510(+input: Nat) -> R.World:
  R.World{data_458(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_507(input), data_509(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_511() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_512() -> List<&2, C.Task>:
  [data_511(), data_503(), data_499(), data_130(), data_131()]

def data_513(+input: Nat) -> C.Machine:
  C.Machine{data_510(input), data_512(), data_126()}

def data_514() -> List<&2, C.Task>:
  [data_503(), data_499(), data_130(), data_131()]

def data_515(+input: Nat) -> C.Machine:
  C.Machine{data_510(input), data_514(), data_126()}

def data_516(+input: Nat) -> R.Node:
  R.Node{data_23(), data_382(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_382(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_517(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_424(input), data_433(input), data_457(input), data_516(input)]

def data_518(+input: Nat) -> R.World:
  R.World{data_517(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_507(input), data_509(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_519() -> O.Task:
  O.TrimDeps{5n}

def data_520() -> List<&2, O.Task>:
  [data_519()]

def data_521() -> C.Task:
  C.OwnerTasks{data_520()}

def data_522() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_126()}

def data_523() -> List<&2, C.Task>:
  [data_521(), data_522(), data_499(), data_130(), data_131()]

def data_524(+input: Nat) -> C.Machine:
  C.Machine{data_518(input), data_523(), data_126()}

def data_525() -> List<&2, C.Task>:
  [data_446(), data_522(), data_499(), data_130(), data_131()]

def data_526(+input: Nat) -> C.Machine:
  C.Machine{data_518(input), data_525(), data_126()}

def data_527() -> List<&2, C.Task>:
  [data_522(), data_499(), data_130(), data_131()]

def data_528(+input: Nat) -> C.Machine:
  C.Machine{data_518(input), data_527(), data_126()}

def data_529() -> List<&2, C.Task>:
  [data_499(), data_130(), data_131()]

def data_530(+input: Nat) -> C.Machine:
  C.Machine{data_518(input), data_529(), data_126()}

def data_531() -> List<&2, C.Task>:
  [data_130(), data_131()]

def data_532(+input: Nat) -> C.Machine:
  C.Machine{data_518(input), data_531(), data_126()}

def data_533(+input: Nat) -> R.World:
  R.World{data_517(input), data_374(), data_316(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_507(input), data_509(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_534() -> List<&2, C.Task>:
  [data_131()]

def data_535(+input: Nat) -> C.Machine:
  C.Machine{data_533(input), data_534(), data_126()}

def data_536() -> List<&2, C.Task>:
  []

def data_537(+input: Nat) -> C.Machine:
  C.Machine{data_533(input), data_536(), data_126()}

def data_538(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_198(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_539(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_538(input), data_117(), data_118()]

def data_540(+input: Nat) -> R.World:
  R.World{data_539(input), data_178(), data_143(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_180(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_541(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_290(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_542(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_541(input), data_118()]

def data_543(+input: Nat) -> R.World:
  R.World{data_542(input), data_256(), data_143(), 1n, 2n, False{}, data_216(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_271(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_544() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_545(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_214(input), data_304(input), data_544()]

def data_546(+input: Nat) -> R.World:
  R.World{data_545(input), data_374(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_547(+input: Nat) -> R.World:
  R.World{data_545(input), data_374(), data_316(), 2n, 2n, False{}, data_306(), data_35(), data_393(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_376(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_122(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_548() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_549(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_113(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_550(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_549(input), data_17(), data_22(), data_26()]

def data_551(+input: Nat) -> R.World:
  R.World{data_550(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_552(+input: Nat) -> R.World:
  R.World{data_119(input), data_33(), data_120(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_553(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_17(), data_22(), data_26()]

def data_554(+input: Nat) -> R.World:
  R.World{data_553(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def data_555() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_556(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_115(input), data_116(), data_117(), data_555()]

def data_557() -> List<&2, Nat>:
  [3n]

def data_558(+input: Nat) -> R.World:
  R.World{data_556(input), data_33(), data_557(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_101(), data_102(), data_2(), data_35(), data_110()}

def origin() -> R.World:
  data_111()

def state_0(+input: Nat) -> C.Machine:
  data_127(input)

def state_1(+input: Nat) -> C.Machine:
  data_133(input)

def state_2(+input: Nat) -> C.Machine:
  data_137(input)

def state_3(+input: Nat) -> C.Machine:
  data_140(input)

def state_4(+input: Nat) -> C.Machine:
  data_150(input)

def state_5(+input: Nat) -> C.Machine:
  data_153(input)

def state_6(+input: Nat) -> C.Machine:
  data_163(input)

def state_7(+input: Nat) -> C.Machine:
  data_168(input)

def state_8(+input: Nat) -> C.Machine:
  data_171(input)

def state_9(+input: Nat) -> C.Machine:
  data_174(input)

def state_10(+input: Nat) -> C.Machine:
  data_184(input)

def state_11(+input: Nat) -> C.Machine:
  data_187(input)

def state_12(+input: Nat) -> C.Machine:
  data_191(input)

def state_13(+input: Nat) -> C.Machine:
  data_197(input)

def state_14(+input: Nat) -> C.Machine:
  data_208(input)

def state_15(+input: Nat) -> C.Machine:
  data_210(input)

def state_16(+input: Nat) -> C.Machine:
  data_213(input)

def state_17(+input: Nat) -> C.Machine:
  data_218(input)

def state_18(+input: Nat) -> C.Machine:
  data_220(input)

def state_19(+input: Nat) -> C.Machine:
  data_223(input)

def state_20(+input: Nat) -> C.Machine:
  data_229(input)

def state_21(+input: Nat) -> C.Machine:
  data_232(input)

def state_22(+input: Nat) -> C.Machine:
  data_241(input)

def state_23(+input: Nat) -> C.Machine:
  data_246(input)

def state_24(+input: Nat) -> C.Machine:
  data_249(input)

def state_25(+input: Nat) -> C.Machine:
  data_252(input)

def state_26(+input: Nat) -> C.Machine:
  data_261(input)

def state_27(+input: Nat) -> C.Machine:
  data_263(input)

def state_28(+input: Nat) -> C.Machine:
  data_267(input)

def state_29(+input: Nat) -> C.Machine:
  data_274(input)

def state_30(+input: Nat) -> C.Machine:
  data_276(input)

def state_31(+input: Nat) -> C.Machine:
  data_279(input)

def state_32(+input: Nat) -> C.Machine:
  data_283(input)

def state_33(+input: Nat) -> C.Machine:
  data_289(input)

def state_34(+input: Nat) -> C.Machine:
  data_298(input)

def state_35(+input: Nat) -> C.Machine:
  data_300(input)

def state_36(+input: Nat) -> C.Machine:
  data_303(input)

def state_37(+input: Nat) -> C.Machine:
  data_308(input)

def state_38(+input: Nat) -> C.Machine:
  data_310(input)

def state_39(+input: Nat) -> C.Machine:
  data_313(input)

def state_40(+input: Nat) -> C.Machine:
  data_320(input)

def state_41(+input: Nat) -> C.Machine:
  data_323(input)

def state_42(+input: Nat) -> C.Machine:
  data_332(input)

def state_43(+input: Nat) -> C.Machine:
  data_336(input)

def state_44(+input: Nat) -> C.Machine:
  data_339(input)

def state_45(+input: Nat) -> C.Machine:
  data_342(input)

def state_46(+input: Nat) -> C.Machine:
  data_351(input)

def state_47(+input: Nat) -> C.Machine:
  data_353(input)

def state_48(+input: Nat) -> C.Machine:
  data_357(input)

def state_49(+input: Nat) -> C.Machine:
  data_364(input)

def state_50(+input: Nat) -> C.Machine:
  data_366(input)

def state_51(+input: Nat) -> C.Machine:
  data_368(input)

def state_52(+input: Nat) -> C.Machine:
  data_370(input)

def state_53(+input: Nat) -> C.Machine:
  data_380(input)

def state_54(+input: Nat) -> C.Machine:
  data_384(input)

def state_55(+input: Nat) -> C.Machine:
  data_390(input)

def state_56(+input: Nat) -> C.Machine:
  data_398(input)

def state_57(+input: Nat) -> C.Machine:
  data_400(input)

def state_58(+input: Nat) -> C.Machine:
  data_403(input)

def state_59(+input: Nat) -> C.Machine:
  data_404(input)

def state_60(+input: Nat) -> C.Machine:
  data_406(input)

def state_61(+input: Nat) -> C.Machine:
  data_410(input)

def state_62(+input: Nat) -> C.Machine:
  data_414(input)

def state_63(+input: Nat) -> C.Machine:
  data_419(input)

def state_64(+input: Nat) -> C.Machine:
  data_423(input)

def state_65(+input: Nat) -> C.Machine:
  data_428(input)

def state_66(+input: Nat) -> C.Machine:
  data_432(input)

def state_67(+input: Nat) -> C.Machine:
  data_438(input)

def state_68(+input: Nat) -> C.Machine:
  data_444(input)

def state_69(+input: Nat) -> C.Machine:
  data_448(input)

def state_70(+input: Nat) -> C.Machine:
  data_450(input)

def state_71(+input: Nat) -> C.Machine:
  data_452(input)

def state_72(+input: Nat) -> C.Machine:
  data_456(input)

def state_73(+input: Nat) -> C.Machine:
  data_462(input)

def state_74(+input: Nat) -> C.Machine:
  data_468(input)

def state_75(+input: Nat) -> C.Machine:
  data_470(input)

def state_76(+input: Nat) -> C.Machine:
  data_472(input)

def state_77(+input: Nat) -> C.Machine:
  data_474(input)

def state_78(+input: Nat) -> C.Machine:
  data_477(input)

def state_79(+input: Nat) -> C.Machine:
  data_479(input)

def state_80(+input: Nat) -> C.Machine:
  data_484(input)

def state_81(+input: Nat) -> C.Machine:
  data_487(input)

def state_82(+input: Nat) -> C.Machine:
  data_490(input)

def state_83(+input: Nat) -> C.Machine:
  data_492(input)

def state_84(+input: Nat) -> C.Machine:
  data_496(input)

def state_85(+input: Nat) -> C.Machine:
  data_501(input)

def state_86(+input: Nat) -> C.Machine:
  data_505(input)

def state_87(+input: Nat) -> C.Machine:
  data_513(input)

def state_88(+input: Nat) -> C.Machine:
  data_515(input)

def state_89(+input: Nat) -> C.Machine:
  data_524(input)

def state_90(+input: Nat) -> C.Machine:
  data_526(input)

def state_91(+input: Nat) -> C.Machine:
  data_528(input)

def state_92(+input: Nat) -> C.Machine:
  data_530(input)

def state_93(+input: Nat) -> C.Machine:
  data_532(input)

def state_94(+input: Nat) -> C.Machine:
  data_535(input)

def state_95(+input: Nat) -> C.Machine:
  data_537(input)

def finalWorld(+input: Nat) -> R.World:
  data_533(input)

def slot_13(+input: Nat) -> R.World:
  data_540(input)

def notify_13(+input: Nat) -> R.World:
  data_204(input)

def slot_33(+input: Nat) -> R.World:
  data_543(input)

def notify_33(+input: Nat) -> R.World:
  data_294(input)

def modified_55(+input: Nat) -> R.World:
  data_546(input)

def queued_55(+input: Nat) -> R.World:
  data_547(input)

def value_55(+input: Nat) -> R.World:
  data_394(input)

def setter_queued(+input: Nat) -> R.World:
  data_548()

def setter_slot(+input: Nat) -> R.World:
  data_551(input)

def setter_inserted(+input: Nat) -> R.World:
  data_552(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_123(input)

def setter_stamped(+input: Nat) -> R.World:
  data_554(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_558(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_552(input)

