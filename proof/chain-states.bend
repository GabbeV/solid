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
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 5n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10() -> R.Value:
  R.Number{0n}

def data_11() -> R.Node:
  R.Node{data_9(), data_10(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_18() -> R.Value:
  R.Number{2n}

def data_19() -> R.Expr:
  R.Read{3n}

def data_20() -> R.Expr:
  R.Literal{data_18()}

def data_21() -> R.Expr:
  R.Multiply{data_19(), data_20()}

def data_22() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 0, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_23() -> R.NodeKind:
  R.Render{}

def data_24() -> R.Expr:
  R.Read{4n}

def data_25() -> R.Expr:
  R.Add{data_24(), data_14()}

def data_26() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 0, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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

def data_57() -> R.Value:
  R.Null{}

def data_58() -> R.Flight:
  R.FlightUndefined{}

def data_59() -> R.AskedIn:
  R.Unasked{}

def data_60() -> R.NodeExtension:
  R.NodeExtension{data_54(), 0n, data_1(), data_2(), 0n, 0n, data_55(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_56(), data_2(), 0n, data_57(), data_58(), data_3(), data_59()}

def data_61() -> List<&2, R.NodeExtension>:
  [data_60()]

def data_62() -> List<&2, R.CleanupAction>:
  []

def data_63() -> R.CleanupProgram:
  R.CleanupProgram{data_62(), False{}, 0n}

def data_64() -> List<&2, R.CleanupProgram>:
  [data_63()]

def data_65() -> List<&2, R.Report>:
  []

def data_66() -> R.OptionalIds:
  R.NoIds{}

def data_67() -> R.Transaction:
  R.Transaction{data_35(), data_35(), data_36(), data_35(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_66(), False{}, 0n}

def data_68() -> List<&2, R.Transaction>:
  [data_67()]

def data_69() -> List<&2, List<&2, Nat>>:
  [data_35()]

def data_70() -> R.AsyncSettlement:
  R.Unresolved{}

def data_71() -> R.AsyncObject:
  R.AsyncObject{False{}, data_70(), data_35(), 0n}

def data_72() -> List<&2, R.AsyncObject>:
  [data_71()]

def data_73() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_74() -> List<&2, R.AsyncObserver>:
  [data_73()]

def data_75() -> List<&2, R.HostJob>:
  []

def data_76() -> List<&2, R.NextInput>:
  []

def data_77() -> R.FromState:
  R.FromNone{}

def data_78() -> R.StreamPlan:
  R.StreamPlan{data_76(), False{}, data_2(), 0n, 0n, data_2(), data_77()}

def data_79() -> List<&2, R.StreamPlan>:
  [data_78()]

def data_80() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_81() -> List<&2, R.ExternalIterator>:
  [data_80()]

def data_82() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_83() -> List<&2, R.StreamState>:
  [data_82()]

def data_84() -> List<&2, R.IteratorEvent>:
  []

def data_85() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_70(), False{}, 0n, False{}, False{}, 0n}

def data_86() -> List<&2, R.Awaiter>:
  [data_85()]

def data_87() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_88() -> List<&2, R.AbortInput>:
  [data_87()]

def data_89() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_90() -> List<&2, R.ContextKey>:
  [data_89()]

def data_91() -> List<&2, R.ContextEntry>:
  []

def data_92() -> R.ContextRecord:
  R.ContextRecord{data_91()}

def data_93() -> List<&2, R.ContextRecord>:
  [data_92()]

def data_94() -> List<&2, R.Expr>:
  [data_4()]

def data_95() -> List<&2, R.ReactionState>:
  []

def data_96() -> List<&2, R.ComparatorBinding>:
  []

def data_97() -> List<&2, R.ActionState>:
  []

def data_98() -> List<&2, R.ActionWait>:
  []

def data_99() -> List<&2, R.ArrayData>:
  []

def data_100() -> List<&2, R.RepeatState>:
  []

def data_101() -> List<&2, R.MapState>:
  []

def data_102() -> List<&2, R.Guess>:
  []

def data_103() -> R.LaneMount:
  R.MountUnset{}

def data_104() -> List<&2, R.KeptGuess>:
  []

def data_105() -> R.LaneState:
  R.LaneState{data_35(), data_69(), data_35(), data_102(), 0n, data_103(), data_35(), False{}, False{}, data_104(), data_35(), False{}, data_35(), data_35()}

def data_106() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_107() -> R.DeferredCell:
  R.DeferredCell{0n, data_57(), False{}, False{}}

def data_108() -> R.DeferredBinding:
  R.DeferredBinding{data_107(), 0n}

def data_109() -> List<&2, R.DeferredBinding>:
  [data_108()]

def data_110() -> List<&2, R.DeferredWait>:
  []

def data_111() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_112() -> List<&2, R.DeferredIterator>:
  [data_111()]

def data_113() -> R.DeferredArena:
  R.DeferredArena{data_109(), data_35(), data_110(), data_112()}

def data_114() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_115(+input: Nat) -> R.Value:
  R.Number{input}

def data_116(+input: Nat) -> R.Slot:
  R.Present{data_115(input)}

def data_117() -> R.Stamp:
  R.Stamped{7n}

def data_118(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_116(input), False{}, 0, 0, 0, 0n, data_117(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_119() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_120() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_121() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_122(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_119(), data_120(), data_121()]

def data_123() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_124() -> R.HostJob:
  R.FlushJob{}

def data_125() -> List<&2, R.HostJob>:
  [data_124()]

def data_126(+input: Nat) -> R.World:
  R.World{data_122(input), data_33(), data_123(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_127() -> C.Task:
  C.Round{}

def data_128() -> List<&2, C.Task>:
  [data_127()]

def data_129() -> List<&2, R.Value>:
  []

def data_130(+input: Nat) -> C.Machine:
  C.Machine{data_126(input), data_128(), data_129()}

def data_131(+input: Nat) -> R.World:
  R.World{data_122(input), data_33(), data_123(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_132() -> C.Task:
  C.RoundAfterSweep{}

def data_133() -> C.Task:
  C.FlushFinally{}

def data_134() -> C.Task:
  C.RoundEnd{}

def data_135() -> List<&2, C.Task>:
  [data_132(), data_133(), data_134()]

def data_136(+input: Nat) -> C.Machine:
  C.Machine{data_131(input), data_135(), data_129()}

def data_137(+input: Nat) -> R.World:
  R.World{data_122(input), data_33(), data_123(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_138() -> C.Task:
  C.HeapLoop{}

def data_139() -> List<&2, C.Task>:
  [data_138(), data_133(), data_134()]

def data_140(+input: Nat) -> C.Machine:
  C.Machine{data_137(input), data_139(), data_129()}

def data_141() -> C.Task:
  C.Recompute{3n, False{}}

def data_142() -> List<&2, C.Task>:
  [data_141(), data_138(), data_133(), data_134()]

def data_143(+input: Nat) -> C.Machine:
  C.Machine{data_137(input), data_142(), data_129()}

def data_144() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_145(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_144(), data_120(), data_121()]

def data_146() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_147() -> R.LaneMount:
  R.MountFalse{}

def data_148() -> R.LaneState:
  R.LaneState{data_35(), data_69(), data_35(), data_102(), 0n, data_147(), data_35(), False{}, False{}, data_104(), data_35(), False{}, data_35(), data_35()}

def data_149(+input: Nat) -> R.World:
  R.World{data_145(input), data_33(), data_146(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_150() -> C.LanePass:
  C.LanePass{0n, data_103(), data_147(), False{}, data_2(), False{}}

def data_151() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_150()}

def data_152() -> List<&2, C.Task>:
  [data_151(), data_138(), data_133(), data_134()]

def data_153(+input: Nat) -> C.Machine:
  C.Machine{data_149(input), data_152(), data_129()}

def data_154() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_150()}

def data_155() -> List<&2, C.Task>:
  [data_154(), data_138(), data_133(), data_134()]

def data_156(+input: Nat) -> C.Machine:
  C.Machine{data_149(input), data_155(), data_129()}

def data_157() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_158(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_157(), data_120(), data_121()]

def data_159() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_160(+input: Nat) -> R.World:
  R.World{data_158(input), data_33(), data_146(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_159(), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_161() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_162() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_10(), 0n, False{}, data_58(), data_129(), 0n, False{}, data_150()}

def data_163() -> C.Task:
  C.Finish{data_162()}

def data_164() -> List<&2, C.Task>:
  [data_161(), data_163(), data_138(), data_133(), data_134()]

def data_165(+input: Nat) -> C.Machine:
  C.Machine{data_160(input), data_164(), data_129()}

def data_166() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_167() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_168() -> C.Task:
  C.Binary{0}

def data_169() -> List<&2, C.Task>:
  [data_166(), data_167(), data_168(), data_163(), data_138(), data_133(), data_134()]

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_160(input), data_169(), data_129()}

def data_171() -> C.Task:
  C.ReadNode{2n}

def data_172() -> List<&2, C.Task>:
  [data_171(), data_167(), data_168(), data_163(), data_138(), data_133(), data_134()]

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_160(input), data_172(), data_129()}

def data_174() -> C.Task:
  C.ReadPrepared{2n}

def data_175() -> List<&2, C.Task>:
  [data_174(), data_167(), data_168(), data_163(), data_138(), data_133(), data_134()]

def data_176(+input: Nat) -> C.Machine:
  C.Machine{data_160(input), data_175(), data_129()}

def data_177(+netted: Bool) -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, B.choose(~U32,netted,_=>4,_=>16388), 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_178(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_177(netted), data_120(), data_121()]

def data_179() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_180() -> List<&2, R.Link>:
  [data_28(), data_179(), data_30(), data_31(), data_32()]

def data_181(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_115(input)}

def data_182(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input)]

def data_183(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_178(netted, input), data_180(), data_146(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_184() -> List<&2, C.Task>:
  [data_167(), data_168(), data_163(), data_138(), data_133(), data_134()]

def data_185(+input: Nat) -> List<&2, R.Value>:
  [data_115(input)]

def data_186(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_183(netted, input), data_184(), data_185(input)}

def data_187() -> List<&2, C.Task>:
  [data_168(), data_163(), data_138(), data_133(), data_134()]

def data_188(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_115(input)]

def data_189(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_183(netted, input), data_187(), data_188(input)}

def data_190() -> List<&2, C.Task>:
  [data_163(), data_138(), data_133(), data_134()]

def data_191(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_192(+input: Nat) -> List<&2, R.Value>:
  [data_191(input)]

def data_193(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_183(netted, input), data_190(), data_192(input)}

def data_194(+netted: Bool) -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_195(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_194(netted), data_120(), data_121()]

def data_196(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_195(netted, input), data_180(), data_146(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_197(+input: Nat) -> C.Task:
  C.PassReleases{data_162(), 0n, data_191(input), False{}, False{}, False{}, data_53()}

def data_198(+input: Nat) -> List<&2, C.Task>:
  [data_197(input), data_138(), data_133(), data_134()]

def data_199(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_196(netted, input), data_198(input), data_129()}

def data_200(+input: Nat) -> R.Slot:
  R.Present{data_191(input)}

def data_201() -> R.Stamp:
  R.Stamped{8n}

def data_202(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_200(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_201(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_203() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_204(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_202(netted, input), data_203(), data_121()]

def data_205() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_206(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_204(netted, input), data_180(), data_205(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_207() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_208() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_209() -> List<&2, C.Task>:
  [data_207(), data_208(), data_138(), data_133(), data_134()]

def data_210(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_206(netted, input), data_209(), data_129()}

def data_211() -> List<&2, C.Task>:
  [data_208(), data_138(), data_133(), data_134()]

def data_212(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_206(netted, input), data_211(), data_129()}

def data_213() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_214() -> List<&2, C.Task>:
  [data_213(), data_138(), data_133(), data_134()]

def data_215(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_206(netted, input), data_214(), data_129()}

def data_216(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_200(input), False{}, 128, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_201(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_217(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_203(), data_121()]

def data_218() -> List<&2, Nat>:
  [2n, 3n]

def data_219(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_217(netted, input), data_180(), data_205(), 0n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_220(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_219(netted, input), data_139(), data_129()}

def data_221(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_217(netted, input), data_180(), data_205(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_222(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_139(), data_129()}

def data_223() -> C.Task:
  C.Recompute{4n, False{}}

def data_224() -> List<&2, C.Task>:
  [data_223(), data_138(), data_133(), data_134()]

def data_225(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_221(netted, input), data_224(), data_129()}

def data_226() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_227(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_226(), data_121()]

def data_228(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_227(netted, input), data_180(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_229() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_150()}

def data_230() -> List<&2, C.Task>:
  [data_229(), data_138(), data_133(), data_134()]

def data_231(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_228(netted, input), data_230(), data_129()}

def data_232() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_150()}

def data_233() -> List<&2, C.Task>:
  [data_232(), data_138(), data_133(), data_134()]

def data_234(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_228(netted, input), data_233(), data_129()}

def data_235() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_236(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_235(), data_121()]

def data_237(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45()]

def data_238(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_236(netted, input), data_180(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_237(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_239() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_240() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_10(), 0n, False{}, data_58(), data_129(), 0n, False{}, data_150()}

def data_241() -> C.Task:
  C.Finish{data_240()}

def data_242() -> List<&2, C.Task>:
  [data_239(), data_241(), data_138(), data_133(), data_134()]

def data_243(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_238(netted, input), data_242(), data_129()}

def data_244() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_245() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_246() -> C.Task:
  C.Binary{1}

def data_247() -> List<&2, C.Task>:
  [data_244(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_248(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_238(netted, input), data_247(), data_129()}

def data_249() -> C.Task:
  C.ReadNode{3n}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_251(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_238(netted, input), data_250(), data_129()}

def data_252() -> C.Task:
  C.ReadPrepared{3n}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_254(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_238(netted, input), data_253(), data_129()}

def data_255() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_256(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_255(), data_121()]

def data_257() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_258() -> List<&2, R.Link>:
  [data_28(), data_179(), data_257(), data_31(), data_32()]

def data_259(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_256(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_237(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_260() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_261() -> C.Task:
  C.ReadStatus{3n}

def data_262() -> List<&2, C.Task>:
  [data_260(), data_261(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_263(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_259(netted, input), data_262(), data_129()}

def data_264() -> List<&2, C.Task>:
  [data_261(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_265(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_259(netted, input), data_264(), data_129()}

def data_266() -> C.Task:
  C.ServeFor{3n, 4n}

def data_267() -> C.Task:
  C.AfterServe{3n}

def data_268() -> List<&2, C.Task>:
  [data_266(), data_267(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_269(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_259(netted, input), data_268(), data_129()}

def data_270() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_271(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_270(), data_121()]

def data_272(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_191(input)}

def data_273(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45(), data_272(input)]

def data_274(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_271(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_275() -> List<&2, C.Task>:
  [data_267(), data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_276(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_274(netted, input), data_275(), data_192(input)}

def data_277() -> List<&2, C.Task>:
  [data_245(), data_246(), data_241(), data_138(), data_133(), data_134()]

def data_278(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_274(netted, input), data_277(), data_192(input)}

def data_279() -> List<&2, C.Task>:
  [data_246(), data_241(), data_138(), data_133(), data_134()]

def data_280(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_191(input)]

def data_281(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_274(netted, input), data_279(), data_280(input)}

def data_282() -> List<&2, C.Task>:
  [data_241(), data_138(), data_133(), data_134()]

def data_283(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_284(+input: Nat) -> List<&2, R.Value>:
  [data_283(input)]

def data_285(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_274(netted, input), data_282(), data_284(input)}

def data_286() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_287(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_286(), data_121()]

def data_288(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_287(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_289(+input: Nat) -> C.Task:
  C.PassReleases{data_240(), 0n, data_283(input), False{}, False{}, False{}, data_53()}

def data_290(+input: Nat) -> List<&2, C.Task>:
  [data_289(input), data_138(), data_133(), data_134()]

def data_291(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_288(netted, input), data_290(input), data_129()}

def data_292(+input: Nat) -> R.Slot:
  R.Present{data_283(input)}

def data_293() -> R.Stamp:
  R.Stamped{9n}

def data_294(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_292(input), False{}, 0, 16384, 0, 0n, data_293(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_295(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_294(input), data_121()]

def data_296(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_295(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_297() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_298() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_299() -> List<&2, C.Task>:
  [data_297(), data_298(), data_138(), data_133(), data_134()]

def data_300(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_296(netted, input), data_299(), data_129()}

def data_301() -> List<&2, C.Task>:
  [data_298(), data_138(), data_133(), data_134()]

def data_302(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_296(netted, input), data_301(), data_129()}

def data_303() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_304() -> List<&2, C.Task>:
  [data_303(), data_138(), data_133(), data_134()]

def data_305(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_296(netted, input), data_304(), data_129()}

def data_306(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_292(input), False{}, 128, 16384, 0, 0n, data_293(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_307(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_121()]

def data_308() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_309(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_307(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_310(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_309(netted, input), data_139(), data_129()}

def data_311(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_307(netted, input), data_258(), data_146(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_312(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_311(netted, input), data_139(), data_129()}

def data_313() -> C.Task:
  C.Recompute{5n, False{}}

def data_314() -> List<&2, C.Task>:
  [data_313(), data_138(), data_133(), data_134()]

def data_315(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_311(netted, input), data_314(), data_129()}

def data_316() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_317(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_316()]

def data_318() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_319(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_317(netted, input), data_258(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_320() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_150()}

def data_321() -> List<&2, C.Task>:
  [data_320(), data_138(), data_133(), data_134()]

def data_322(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_319(netted, input), data_321(), data_129()}

def data_323() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_150()}

def data_324() -> List<&2, C.Task>:
  [data_323(), data_138(), data_133(), data_134()]

def data_325(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_319(netted, input), data_324(), data_129()}

def data_326() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_327(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_326()]

def data_328(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45(), data_272(input), data_48()]

def data_329(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_327(netted, input), data_258(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_328(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), True{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_330() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_331() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_10(), 0n, False{}, data_58(), data_129(), 0n, False{}, data_150()}

def data_332() -> C.Task:
  C.Finish{data_331()}

def data_333() -> List<&2, C.Task>:
  [data_330(), data_332(), data_138(), data_133(), data_134()]

def data_334(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_329(netted, input), data_333(), data_129()}

def data_335() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_336() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_337() -> List<&2, C.Task>:
  [data_335(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_338(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_329(netted, input), data_337(), data_129()}

def data_339() -> C.Task:
  C.ReadNode{4n}

def data_340() -> List<&2, C.Task>:
  [data_339(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_341(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_329(netted, input), data_340(), data_129()}

def data_342() -> C.Task:
  C.ReadPrepared{4n}

def data_343() -> List<&2, C.Task>:
  [data_342(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_344(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_329(netted, input), data_343(), data_129()}

def data_345() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_346(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_345()]

def data_347() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_348() -> List<&2, R.Link>:
  [data_28(), data_179(), data_257(), data_347(), data_32()]

def data_349(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_346(netted, input), data_348(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_328(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), True{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_350() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_351() -> C.Task:
  C.ReadStatus{4n}

def data_352() -> List<&2, C.Task>:
  [data_350(), data_351(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_353(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_349(netted, input), data_352(), data_129()}

def data_354() -> List<&2, C.Task>:
  [data_351(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_355(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_349(netted, input), data_354(), data_129()}

def data_356() -> C.Task:
  C.ServeFor{4n, 5n}

def data_357() -> C.Task:
  C.AfterServe{4n}

def data_358() -> List<&2, C.Task>:
  [data_356(), data_357(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_359(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_349(netted, input), data_358(), data_129()}

def data_360() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_361(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_360()]

def data_362(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_283(input)}

def data_363(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45(), data_272(input), data_48(), data_362(input)]

def data_364(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_361(netted, input), data_348(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_363(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), True{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_365() -> List<&2, C.Task>:
  [data_357(), data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_366(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_364(netted, input), data_365(), data_284(input)}

def data_367() -> List<&2, C.Task>:
  [data_336(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_368(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_364(netted, input), data_367(), data_284(input)}

def data_369() -> List<&2, C.Task>:
  [data_171(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_370(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_364(netted, input), data_369(), data_284(input)}

def data_371() -> List<&2, C.Task>:
  [data_174(), data_168(), data_332(), data_138(), data_133(), data_134()]

def data_372(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_364(netted, input), data_371(), data_284(input)}

def data_373() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_374(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_373()]

def data_375() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_376() -> List<&2, R.Link>:
  [data_28(), data_179(), data_257(), data_347(), data_375()]

def data_377(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_115(input)}

def data_378(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45(), data_272(input), data_48(), data_362(input), data_377(input)]

def data_379(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_374(netted, input), data_376(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), True{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_148(), data_106(), data_2(), data_35(), data_113()}

def data_380() -> List<&2, C.Task>:
  [data_168(), data_332(), data_138(), data_133(), data_134()]

def data_381(+input: Nat) -> List<&2, R.Value>:
  [data_115(input), data_283(input)]

def data_382(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_379(netted, input), data_380(), data_381(input)}

def data_383() -> List<&2, C.Task>:
  [data_332(), data_138(), data_133(), data_134()]

def data_384(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_385(+input: Nat) -> List<&2, R.Value>:
  [data_384(input)]

def data_386(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_379(netted, input), data_383(), data_385(input)}

def data_387() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_388(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_387()]

def data_389(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_388(netted, input), data_376(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_390(+input: Nat) -> C.Task:
  C.PassReleases{data_331(), 0n, data_384(input), False{}, False{}, False{}, data_53()}

def data_391(+input: Nat) -> List<&2, C.Task>:
  [data_390(input), data_138(), data_133(), data_134()]

def data_392(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_389(netted, input), data_391(input), data_129()}

def data_393(+input: Nat) -> R.Node:
  R.Node{data_23(), data_384(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_394(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_393(input)]

def data_395() -> List<&2, Nat>:
  [5n]

def data_396(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_394(netted, input), data_376(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_397() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_398() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_399() -> List<&2, C.Task>:
  [data_397(), data_398(), data_138(), data_133(), data_134()]

def data_400(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_396(netted, input), data_399(), data_129()}

def data_401() -> List<&2, C.Task>:
  [data_398(), data_138(), data_133(), data_134()]

def data_402(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_396(netted, input), data_401(), data_129()}

def data_403() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_404() -> List<&2, C.Task>:
  [data_403(), data_138(), data_133(), data_134()]

def data_405(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_396(netted, input), data_404(), data_129()}

def data_406(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_396(netted, input), data_139(), data_129()}

def data_407(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_394(netted, input), data_376(), data_318(), 3n, 2n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_408(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_407(netted, input), data_139(), data_129()}

def data_409(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_394(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_410() -> C.Task:
  C.Seam{}

def data_411() -> List<&2, C.Task>:
  [data_410(), data_133(), data_134()]

def data_412(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_409(netted, input), data_411(), data_129()}

def data_413() -> C.Task:
  C.Settle{}

def data_414() -> C.Task:
  C.AfterSettle{}

def data_415() -> List<&2, C.Task>:
  [data_413(), data_414(), data_133(), data_134()]

def data_416(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_409(netted, input), data_415(), data_129()}

def data_417() -> C.Task:
  C.CommitIntake{0n}

def data_418() -> C.Task:
  C.TrimIntake{0n}

def data_419() -> C.Task:
  C.FinishSettleIntake{0n}

def data_420() -> List<&2, C.Task>:
  [data_417(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_421(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_409(netted, input), data_420(), data_129()}

def data_422() -> C.Task:
  C.CommitPending{2n}

def data_423() -> C.Task:
  C.CommitIntake{1n}

def data_424() -> List<&2, C.Task>:
  [data_422(), data_423(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_425(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_409(netted, input), data_424(), data_129()}

def data_426(+input: Nat) -> R.Node:
  R.Node{data_9(), data_115(input), data_2(), False{}, 0, 0, 0, 0n, data_117(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_427(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_426(input), data_216(netted, input), data_306(input), data_393(input)]

def data_428(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_427(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_429() -> List<&2, C.Task>:
  [data_423(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_430(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_428(netted, input), data_429(), data_129()}

def data_431() -> C.Task:
  C.CommitPending{3n}

def data_432() -> C.Task:
  C.CommitIntake{2n}

def data_433() -> List<&2, C.Task>:
  [data_431(), data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_434(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_428(netted, input), data_433(), data_129()}

def data_435(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_191(input), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_201(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_436(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_426(input), data_435(netted, input), data_306(input), data_393(input)]

def data_437(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_436(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_438() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_439() -> List<&2, C.Task>:
  [data_438(), data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_440(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_439(), data_129()}

def data_441() -> O.Task:
  O.TrimDeps{3n}

def data_442() -> List<&2, O.Task>:
  [data_441()]

def data_443() -> C.Task:
  C.OwnerTasks{data_442()}

def data_444() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_445() -> List<&2, C.Task>:
  [data_443(), data_444(), data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_446(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_445(), data_129()}

def data_447() -> List<&2, O.Task>:
  []

def data_448() -> C.Task:
  C.OwnerTasks{data_447()}

def data_449() -> List<&2, C.Task>:
  [data_448(), data_444(), data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_450(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_449(), data_129()}

def data_451() -> List<&2, C.Task>:
  [data_444(), data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_452(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_451(), data_129()}

def data_453() -> List<&2, C.Task>:
  [data_432(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_454(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_453(), data_129()}

def data_455() -> C.Task:
  C.CommitPending{4n}

def data_456() -> C.Task:
  C.CommitIntake{3n}

def data_457() -> List<&2, C.Task>:
  [data_455(), data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_458(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_437(netted, input), data_457(), data_129()}

def data_459(+input: Nat) -> R.Node:
  R.Node{data_12(), data_283(input), data_2(), False{}, 0, 16384, 0, 0n, data_293(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_460(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_426(input), data_435(netted, input), data_459(input), data_393(input)]

def data_461(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_462() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_463() -> List<&2, C.Task>:
  [data_462(), data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_464(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_461(netted, input), data_463(), data_129()}

def data_465() -> O.Task:
  O.TrimDeps{4n}

def data_466() -> List<&2, O.Task>:
  [data_465()]

def data_467() -> C.Task:
  C.OwnerTasks{data_466()}

def data_468() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_469() -> List<&2, C.Task>:
  [data_467(), data_468(), data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_470(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_461(netted, input), data_469(), data_129()}

def data_471() -> List<&2, C.Task>:
  [data_448(), data_468(), data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_472(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_461(netted, input), data_471(), data_129()}

def data_473() -> List<&2, C.Task>:
  [data_468(), data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_474(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_461(netted, input), data_473(), data_129()}

def data_475() -> List<&2, C.Task>:
  [data_456(), data_418(), data_419(), data_414(), data_133(), data_134()]

def data_476(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_461(netted, input), data_475(), data_129()}

def data_477(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_478() -> List<&2, C.Task>:
  [data_418(), data_419(), data_414(), data_133(), data_134()]

def data_479(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_477(netted, input), data_478(), data_129()}

def data_480() -> List<&2, C.Task>:
  [data_419(), data_414(), data_133(), data_134()]

def data_481(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_477(netted, input), data_480(), data_129()}

def data_482(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_483() -> C.SeamFrame:
  C.SeamFrame{0n, data_395(), data_36(), data_35(), data_36()}

def data_484() -> C.Task:
  C.LandTransactions{data_483(), 0n}

def data_485() -> List<&2, C.Task>:
  [data_484(), data_414(), data_133(), data_134()]

def data_486(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_482(netted, input), data_485(), data_129()}

def data_487() -> C.Task:
  C.CompleteSettle{data_483()}

def data_488() -> List<&2, C.Task>:
  [data_487(), data_414(), data_133(), data_134()]

def data_489(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_482(netted, input), data_488(), data_129()}

def data_490() -> C.Task:
  C.ZombieLoop{data_35()}

def data_491() -> List<&2, C.Task>:
  [data_490(), data_414(), data_133(), data_134()]

def data_492(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_477(netted, input), data_491(), data_129()}

def data_493() -> List<&2, C.Task>:
  [data_414(), data_133(), data_134()]

def data_494(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_477(netted, input), data_493(), data_129()}

def data_495(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_395(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_496() -> C.Task:
  C.RenderQueue{}

def data_497() -> List<&2, C.Task>:
  [data_496(), data_133(), data_134()]

def data_498(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_495(netted, input), data_497(), data_129()}

def data_499(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_500() -> C.Task:
  C.RunEffect{5n}

def data_501() -> C.Task:
  C.UserQueue{}

def data_502() -> List<&2, C.Task>:
  [data_500(), data_501(), data_133(), data_134()]

def data_503(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_499(netted, input), data_502(), data_129()}

def data_504() -> C.Task:
  C.ApplyEffect{5n}

def data_505() -> C.Task:
  C.EffectFinally{5n, True{}, data_129()}

def data_506() -> List<&2, C.Task>:
  [data_504(), data_505(), data_501(), data_133(), data_134()]

def data_507(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_499(netted, input), data_506(), data_129()}

def data_508(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_384(input)}

def data_509(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_508(input)]

def data_510(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_384(input), data_18()}

def data_511(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_181(input), data_45(), data_272(input), data_48(), data_362(input), data_377(input), data_510(input)]

def data_512(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_460(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_509(input), data_511(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_513() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_514() -> List<&2, C.Task>:
  [data_513(), data_505(), data_501(), data_133(), data_134()]

def data_515(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_512(netted, input), data_514(), data_129()}

def data_516() -> List<&2, C.Task>:
  [data_505(), data_501(), data_133(), data_134()]

def data_517(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_512(netted, input), data_516(), data_129()}

def data_518(+input: Nat) -> R.Node:
  R.Node{data_23(), data_384(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_384(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_519(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_426(input), data_435(netted, input), data_459(input), data_518(input)]

def data_520(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_519(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_509(input), data_511(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_521() -> O.Task:
  O.TrimDeps{5n}

def data_522() -> List<&2, O.Task>:
  [data_521()]

def data_523() -> C.Task:
  C.OwnerTasks{data_522()}

def data_524() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_129()}

def data_525() -> List<&2, C.Task>:
  [data_523(), data_524(), data_501(), data_133(), data_134()]

def data_526(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_520(netted, input), data_525(), data_129()}

def data_527() -> List<&2, C.Task>:
  [data_448(), data_524(), data_501(), data_133(), data_134()]

def data_528(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_520(netted, input), data_527(), data_129()}

def data_529() -> List<&2, C.Task>:
  [data_524(), data_501(), data_133(), data_134()]

def data_530(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_520(netted, input), data_529(), data_129()}

def data_531() -> List<&2, C.Task>:
  [data_501(), data_133(), data_134()]

def data_532(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_520(netted, input), data_531(), data_129()}

def data_533() -> List<&2, C.Task>:
  [data_133(), data_134()]

def data_534(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_520(netted, input), data_533(), data_129()}

def data_535(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_519(netted, input), data_376(), data_318(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_509(input), data_511(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_536() -> List<&2, C.Task>:
  [data_134()]

def data_537(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_535(netted, input), data_536(), data_129()}

def data_538() -> List<&2, C.Task>:
  []

def data_539(+netted: Bool, +input: Nat) -> C.Machine:
  C.Machine{data_535(netted, input), data_538(), data_129()}

def data_540(+netted: Bool, +input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_200(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_541(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_540(netted, input), data_120(), data_121()]

def data_542(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_541(netted, input), data_180(), data_146(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_182(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_543(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_292(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_544(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_543(input), data_121()]

def data_545(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_544(netted, input), data_258(), data_146(), 1n, 2n, False{}, data_218(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_273(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_546() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_547(+netted: Bool, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_216(netted, input), data_306(input), data_546()]

def data_548(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_547(netted, input), data_376(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_549(+netted: Bool, +input: Nat) -> R.World:
  R.World{data_547(netted, input), data_376(), data_318(), 2n, 2n, False{}, data_308(), data_35(), data_395(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_378(input), data_53(), False{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_125(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_550() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_551(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_116(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_552(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_551(input), data_17(), data_22(), data_26()]

def data_553(+input: Nat) -> R.World:
  R.World{data_552(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_554(+input: Nat) -> R.World:
  R.World{data_122(input), data_33(), data_123(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_555(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_17(), data_22(), data_26()]

def data_556(+input: Nat) -> R.World:
  R.World{data_555(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def data_557() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_558(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_118(input), data_119(), data_120(), data_557()]

def data_559() -> List<&2, Nat>:
  [3n]

def data_560(+input: Nat) -> R.World:
  R.World{data_558(input), data_33(), data_559(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_61(), data_64(), data_35(), 0n, False{}, False{}, data_65(), 0n, data_68(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_69(), data_72(), data_74(), data_75(), 0n, data_79(), data_81(), data_83(), data_84(), data_86(), False{}, False{}, data_56(), data_88(), data_90(), data_93(), 0n, data_69(), False{}, data_94(), data_95(), data_96(), 0n, data_97(), data_98(), data_99(), data_100(), data_101(), 0n, data_105(), data_106(), data_2(), data_35(), data_113()}

def origin() -> R.World:
  data_114()

def at_0(+netted: Bool,+input: Nat) -> C.Machine:
  data_130(input)

def state_0(+input: Nat) -> C.Machine:
  at_0(Nat.is_eq(input,0n),input)

def at_1(+netted: Bool,+input: Nat) -> C.Machine:
  data_136(input)

def state_1(+input: Nat) -> C.Machine:
  at_1(Nat.is_eq(input,0n),input)

def at_2(+netted: Bool,+input: Nat) -> C.Machine:
  data_140(input)

def state_2(+input: Nat) -> C.Machine:
  at_2(Nat.is_eq(input,0n),input)

def at_3(+netted: Bool,+input: Nat) -> C.Machine:
  data_143(input)

def state_3(+input: Nat) -> C.Machine:
  at_3(Nat.is_eq(input,0n),input)

def at_4(+netted: Bool,+input: Nat) -> C.Machine:
  data_153(input)

def state_4(+input: Nat) -> C.Machine:
  at_4(Nat.is_eq(input,0n),input)

def at_5(+netted: Bool,+input: Nat) -> C.Machine:
  data_156(input)

def state_5(+input: Nat) -> C.Machine:
  at_5(Nat.is_eq(input,0n),input)

def at_6(+netted: Bool,+input: Nat) -> C.Machine:
  data_165(input)

def state_6(+input: Nat) -> C.Machine:
  at_6(Nat.is_eq(input,0n),input)

def at_7(+netted: Bool,+input: Nat) -> C.Machine:
  data_170(input)

def state_7(+input: Nat) -> C.Machine:
  at_7(Nat.is_eq(input,0n),input)

def at_8(+netted: Bool,+input: Nat) -> C.Machine:
  data_173(input)

def state_8(+input: Nat) -> C.Machine:
  at_8(Nat.is_eq(input,0n),input)

def at_9(+netted: Bool,+input: Nat) -> C.Machine:
  data_176(input)

def state_9(+input: Nat) -> C.Machine:
  at_9(Nat.is_eq(input,0n),input)

def at_10(+netted: Bool,+input: Nat) -> C.Machine:
  data_186(netted, input)

def state_10(+input: Nat) -> C.Machine:
  at_10(Nat.is_eq(input,0n),input)

def at_11(+netted: Bool,+input: Nat) -> C.Machine:
  data_189(netted, input)

def state_11(+input: Nat) -> C.Machine:
  at_11(Nat.is_eq(input,0n),input)

def at_12(+netted: Bool,+input: Nat) -> C.Machine:
  data_193(netted, input)

def state_12(+input: Nat) -> C.Machine:
  at_12(Nat.is_eq(input,0n),input)

def at_13(+netted: Bool,+input: Nat) -> C.Machine:
  data_199(netted, input)

def state_13(+input: Nat) -> C.Machine:
  at_13(Nat.is_eq(input,0n),input)

def at_14(+netted: Bool,+input: Nat) -> C.Machine:
  data_210(netted, input)

def state_14(+input: Nat) -> C.Machine:
  at_14(Nat.is_eq(input,0n),input)

def at_15(+netted: Bool,+input: Nat) -> C.Machine:
  data_212(netted, input)

def state_15(+input: Nat) -> C.Machine:
  at_15(Nat.is_eq(input,0n),input)

def at_16(+netted: Bool,+input: Nat) -> C.Machine:
  data_215(netted, input)

def state_16(+input: Nat) -> C.Machine:
  at_16(Nat.is_eq(input,0n),input)

def at_17(+netted: Bool,+input: Nat) -> C.Machine:
  data_220(netted, input)

def state_17(+input: Nat) -> C.Machine:
  at_17(Nat.is_eq(input,0n),input)

def at_18(+netted: Bool,+input: Nat) -> C.Machine:
  data_222(netted, input)

def state_18(+input: Nat) -> C.Machine:
  at_18(Nat.is_eq(input,0n),input)

def at_19(+netted: Bool,+input: Nat) -> C.Machine:
  data_225(netted, input)

def state_19(+input: Nat) -> C.Machine:
  at_19(Nat.is_eq(input,0n),input)

def at_20(+netted: Bool,+input: Nat) -> C.Machine:
  data_231(netted, input)

def state_20(+input: Nat) -> C.Machine:
  at_20(Nat.is_eq(input,0n),input)

def at_21(+netted: Bool,+input: Nat) -> C.Machine:
  data_234(netted, input)

def state_21(+input: Nat) -> C.Machine:
  at_21(Nat.is_eq(input,0n),input)

def at_22(+netted: Bool,+input: Nat) -> C.Machine:
  data_243(netted, input)

def state_22(+input: Nat) -> C.Machine:
  at_22(Nat.is_eq(input,0n),input)

def at_23(+netted: Bool,+input: Nat) -> C.Machine:
  data_248(netted, input)

def state_23(+input: Nat) -> C.Machine:
  at_23(Nat.is_eq(input,0n),input)

def at_24(+netted: Bool,+input: Nat) -> C.Machine:
  data_251(netted, input)

def state_24(+input: Nat) -> C.Machine:
  at_24(Nat.is_eq(input,0n),input)

def at_25(+netted: Bool,+input: Nat) -> C.Machine:
  data_254(netted, input)

def state_25(+input: Nat) -> C.Machine:
  at_25(Nat.is_eq(input,0n),input)

def at_26(+netted: Bool,+input: Nat) -> C.Machine:
  data_263(netted, input)

def state_26(+input: Nat) -> C.Machine:
  at_26(Nat.is_eq(input,0n),input)

def at_27(+netted: Bool,+input: Nat) -> C.Machine:
  data_265(netted, input)

def state_27(+input: Nat) -> C.Machine:
  at_27(Nat.is_eq(input,0n),input)

def at_28(+netted: Bool,+input: Nat) -> C.Machine:
  data_269(netted, input)

def state_28(+input: Nat) -> C.Machine:
  at_28(Nat.is_eq(input,0n),input)

def at_29(+netted: Bool,+input: Nat) -> C.Machine:
  data_276(netted, input)

def state_29(+input: Nat) -> C.Machine:
  at_29(Nat.is_eq(input,0n),input)

def at_30(+netted: Bool,+input: Nat) -> C.Machine:
  data_278(netted, input)

def state_30(+input: Nat) -> C.Machine:
  at_30(Nat.is_eq(input,0n),input)

def at_31(+netted: Bool,+input: Nat) -> C.Machine:
  data_281(netted, input)

def state_31(+input: Nat) -> C.Machine:
  at_31(Nat.is_eq(input,0n),input)

def at_32(+netted: Bool,+input: Nat) -> C.Machine:
  data_285(netted, input)

def state_32(+input: Nat) -> C.Machine:
  at_32(Nat.is_eq(input,0n),input)

def at_33(+netted: Bool,+input: Nat) -> C.Machine:
  data_291(netted, input)

def state_33(+input: Nat) -> C.Machine:
  at_33(Nat.is_eq(input,0n),input)

def at_34(+netted: Bool,+input: Nat) -> C.Machine:
  data_300(netted, input)

def state_34(+input: Nat) -> C.Machine:
  at_34(Nat.is_eq(input,0n),input)

def at_35(+netted: Bool,+input: Nat) -> C.Machine:
  data_302(netted, input)

def state_35(+input: Nat) -> C.Machine:
  at_35(Nat.is_eq(input,0n),input)

def at_36(+netted: Bool,+input: Nat) -> C.Machine:
  data_305(netted, input)

def state_36(+input: Nat) -> C.Machine:
  at_36(Nat.is_eq(input,0n),input)

def at_37(+netted: Bool,+input: Nat) -> C.Machine:
  data_310(netted, input)

def state_37(+input: Nat) -> C.Machine:
  at_37(Nat.is_eq(input,0n),input)

def at_38(+netted: Bool,+input: Nat) -> C.Machine:
  data_312(netted, input)

def state_38(+input: Nat) -> C.Machine:
  at_38(Nat.is_eq(input,0n),input)

def at_39(+netted: Bool,+input: Nat) -> C.Machine:
  data_315(netted, input)

def state_39(+input: Nat) -> C.Machine:
  at_39(Nat.is_eq(input,0n),input)

def at_40(+netted: Bool,+input: Nat) -> C.Machine:
  data_322(netted, input)

def state_40(+input: Nat) -> C.Machine:
  at_40(Nat.is_eq(input,0n),input)

def at_41(+netted: Bool,+input: Nat) -> C.Machine:
  data_325(netted, input)

def state_41(+input: Nat) -> C.Machine:
  at_41(Nat.is_eq(input,0n),input)

def at_42(+netted: Bool,+input: Nat) -> C.Machine:
  data_334(netted, input)

def state_42(+input: Nat) -> C.Machine:
  at_42(Nat.is_eq(input,0n),input)

def at_43(+netted: Bool,+input: Nat) -> C.Machine:
  data_338(netted, input)

def state_43(+input: Nat) -> C.Machine:
  at_43(Nat.is_eq(input,0n),input)

def at_44(+netted: Bool,+input: Nat) -> C.Machine:
  data_341(netted, input)

def state_44(+input: Nat) -> C.Machine:
  at_44(Nat.is_eq(input,0n),input)

def at_45(+netted: Bool,+input: Nat) -> C.Machine:
  data_344(netted, input)

def state_45(+input: Nat) -> C.Machine:
  at_45(Nat.is_eq(input,0n),input)

def at_46(+netted: Bool,+input: Nat) -> C.Machine:
  data_353(netted, input)

def state_46(+input: Nat) -> C.Machine:
  at_46(Nat.is_eq(input,0n),input)

def at_47(+netted: Bool,+input: Nat) -> C.Machine:
  data_355(netted, input)

def state_47(+input: Nat) -> C.Machine:
  at_47(Nat.is_eq(input,0n),input)

def at_48(+netted: Bool,+input: Nat) -> C.Machine:
  data_359(netted, input)

def state_48(+input: Nat) -> C.Machine:
  at_48(Nat.is_eq(input,0n),input)

def at_49(+netted: Bool,+input: Nat) -> C.Machine:
  data_366(netted, input)

def state_49(+input: Nat) -> C.Machine:
  at_49(Nat.is_eq(input,0n),input)

def at_50(+netted: Bool,+input: Nat) -> C.Machine:
  data_368(netted, input)

def state_50(+input: Nat) -> C.Machine:
  at_50(Nat.is_eq(input,0n),input)

def at_51(+netted: Bool,+input: Nat) -> C.Machine:
  data_370(netted, input)

def state_51(+input: Nat) -> C.Machine:
  at_51(Nat.is_eq(input,0n),input)

def at_52(+netted: Bool,+input: Nat) -> C.Machine:
  data_372(netted, input)

def state_52(+input: Nat) -> C.Machine:
  at_52(Nat.is_eq(input,0n),input)

def at_53(+netted: Bool,+input: Nat) -> C.Machine:
  data_382(netted, input)

def state_53(+input: Nat) -> C.Machine:
  at_53(Nat.is_eq(input,0n),input)

def at_54(+netted: Bool,+input: Nat) -> C.Machine:
  data_386(netted, input)

def state_54(+input: Nat) -> C.Machine:
  at_54(Nat.is_eq(input,0n),input)

def at_55(+netted: Bool,+input: Nat) -> C.Machine:
  data_392(netted, input)

def state_55(+input: Nat) -> C.Machine:
  at_55(Nat.is_eq(input,0n),input)

def at_56(+netted: Bool,+input: Nat) -> C.Machine:
  data_400(netted, input)

def state_56(+input: Nat) -> C.Machine:
  at_56(Nat.is_eq(input,0n),input)

def at_57(+netted: Bool,+input: Nat) -> C.Machine:
  data_402(netted, input)

def state_57(+input: Nat) -> C.Machine:
  at_57(Nat.is_eq(input,0n),input)

def at_58(+netted: Bool,+input: Nat) -> C.Machine:
  data_405(netted, input)

def state_58(+input: Nat) -> C.Machine:
  at_58(Nat.is_eq(input,0n),input)

def at_59(+netted: Bool,+input: Nat) -> C.Machine:
  data_406(netted, input)

def state_59(+input: Nat) -> C.Machine:
  at_59(Nat.is_eq(input,0n),input)

def at_60(+netted: Bool,+input: Nat) -> C.Machine:
  data_408(netted, input)

def state_60(+input: Nat) -> C.Machine:
  at_60(Nat.is_eq(input,0n),input)

def at_61(+netted: Bool,+input: Nat) -> C.Machine:
  data_412(netted, input)

def state_61(+input: Nat) -> C.Machine:
  at_61(Nat.is_eq(input,0n),input)

def at_62(+netted: Bool,+input: Nat) -> C.Machine:
  data_416(netted, input)

def state_62(+input: Nat) -> C.Machine:
  at_62(Nat.is_eq(input,0n),input)

def at_63(+netted: Bool,+input: Nat) -> C.Machine:
  data_421(netted, input)

def state_63(+input: Nat) -> C.Machine:
  at_63(Nat.is_eq(input,0n),input)

def at_64(+netted: Bool,+input: Nat) -> C.Machine:
  data_425(netted, input)

def state_64(+input: Nat) -> C.Machine:
  at_64(Nat.is_eq(input,0n),input)

def at_65(+netted: Bool,+input: Nat) -> C.Machine:
  data_430(netted, input)

def state_65(+input: Nat) -> C.Machine:
  at_65(Nat.is_eq(input,0n),input)

def at_66(+netted: Bool,+input: Nat) -> C.Machine:
  data_434(netted, input)

def state_66(+input: Nat) -> C.Machine:
  at_66(Nat.is_eq(input,0n),input)

def at_67(+netted: Bool,+input: Nat) -> C.Machine:
  data_440(netted, input)

def state_67(+input: Nat) -> C.Machine:
  at_67(Nat.is_eq(input,0n),input)

def at_68(+netted: Bool,+input: Nat) -> C.Machine:
  data_446(netted, input)

def state_68(+input: Nat) -> C.Machine:
  at_68(Nat.is_eq(input,0n),input)

def at_69(+netted: Bool,+input: Nat) -> C.Machine:
  data_450(netted, input)

def state_69(+input: Nat) -> C.Machine:
  at_69(Nat.is_eq(input,0n),input)

def at_70(+netted: Bool,+input: Nat) -> C.Machine:
  data_452(netted, input)

def state_70(+input: Nat) -> C.Machine:
  at_70(Nat.is_eq(input,0n),input)

def at_71(+netted: Bool,+input: Nat) -> C.Machine:
  data_454(netted, input)

def state_71(+input: Nat) -> C.Machine:
  at_71(Nat.is_eq(input,0n),input)

def at_72(+netted: Bool,+input: Nat) -> C.Machine:
  data_458(netted, input)

def state_72(+input: Nat) -> C.Machine:
  at_72(Nat.is_eq(input,0n),input)

def at_73(+netted: Bool,+input: Nat) -> C.Machine:
  data_464(netted, input)

def state_73(+input: Nat) -> C.Machine:
  at_73(Nat.is_eq(input,0n),input)

def at_74(+netted: Bool,+input: Nat) -> C.Machine:
  data_470(netted, input)

def state_74(+input: Nat) -> C.Machine:
  at_74(Nat.is_eq(input,0n),input)

def at_75(+netted: Bool,+input: Nat) -> C.Machine:
  data_472(netted, input)

def state_75(+input: Nat) -> C.Machine:
  at_75(Nat.is_eq(input,0n),input)

def at_76(+netted: Bool,+input: Nat) -> C.Machine:
  data_474(netted, input)

def state_76(+input: Nat) -> C.Machine:
  at_76(Nat.is_eq(input,0n),input)

def at_77(+netted: Bool,+input: Nat) -> C.Machine:
  data_476(netted, input)

def state_77(+input: Nat) -> C.Machine:
  at_77(Nat.is_eq(input,0n),input)

def at_78(+netted: Bool,+input: Nat) -> C.Machine:
  data_479(netted, input)

def state_78(+input: Nat) -> C.Machine:
  at_78(Nat.is_eq(input,0n),input)

def at_79(+netted: Bool,+input: Nat) -> C.Machine:
  data_481(netted, input)

def state_79(+input: Nat) -> C.Machine:
  at_79(Nat.is_eq(input,0n),input)

def at_80(+netted: Bool,+input: Nat) -> C.Machine:
  data_486(netted, input)

def state_80(+input: Nat) -> C.Machine:
  at_80(Nat.is_eq(input,0n),input)

def at_81(+netted: Bool,+input: Nat) -> C.Machine:
  data_489(netted, input)

def state_81(+input: Nat) -> C.Machine:
  at_81(Nat.is_eq(input,0n),input)

def at_82(+netted: Bool,+input: Nat) -> C.Machine:
  data_492(netted, input)

def state_82(+input: Nat) -> C.Machine:
  at_82(Nat.is_eq(input,0n),input)

def at_83(+netted: Bool,+input: Nat) -> C.Machine:
  data_494(netted, input)

def state_83(+input: Nat) -> C.Machine:
  at_83(Nat.is_eq(input,0n),input)

def at_84(+netted: Bool,+input: Nat) -> C.Machine:
  data_498(netted, input)

def state_84(+input: Nat) -> C.Machine:
  at_84(Nat.is_eq(input,0n),input)

def at_85(+netted: Bool,+input: Nat) -> C.Machine:
  data_503(netted, input)

def state_85(+input: Nat) -> C.Machine:
  at_85(Nat.is_eq(input,0n),input)

def at_86(+netted: Bool,+input: Nat) -> C.Machine:
  data_507(netted, input)

def state_86(+input: Nat) -> C.Machine:
  at_86(Nat.is_eq(input,0n),input)

def at_87(+netted: Bool,+input: Nat) -> C.Machine:
  data_515(netted, input)

def state_87(+input: Nat) -> C.Machine:
  at_87(Nat.is_eq(input,0n),input)

def at_88(+netted: Bool,+input: Nat) -> C.Machine:
  data_517(netted, input)

def state_88(+input: Nat) -> C.Machine:
  at_88(Nat.is_eq(input,0n),input)

def at_89(+netted: Bool,+input: Nat) -> C.Machine:
  data_526(netted, input)

def state_89(+input: Nat) -> C.Machine:
  at_89(Nat.is_eq(input,0n),input)

def at_90(+netted: Bool,+input: Nat) -> C.Machine:
  data_528(netted, input)

def state_90(+input: Nat) -> C.Machine:
  at_90(Nat.is_eq(input,0n),input)

def at_91(+netted: Bool,+input: Nat) -> C.Machine:
  data_530(netted, input)

def state_91(+input: Nat) -> C.Machine:
  at_91(Nat.is_eq(input,0n),input)

def at_92(+netted: Bool,+input: Nat) -> C.Machine:
  data_532(netted, input)

def state_92(+input: Nat) -> C.Machine:
  at_92(Nat.is_eq(input,0n),input)

def at_93(+netted: Bool,+input: Nat) -> C.Machine:
  data_534(netted, input)

def state_93(+input: Nat) -> C.Machine:
  at_93(Nat.is_eq(input,0n),input)

def at_94(+netted: Bool,+input: Nat) -> C.Machine:
  data_537(netted, input)

def state_94(+input: Nat) -> C.Machine:
  at_94(Nat.is_eq(input,0n),input)

def at_95(+netted: Bool,+input: Nat) -> C.Machine:
  data_539(netted, input)

def state_95(+input: Nat) -> C.Machine:
  at_95(Nat.is_eq(input,0n),input)

def finalAt(+netted: Bool,+input: Nat) -> R.World:
  data_535(netted, input)

def finalWorld(+input: Nat) -> R.World:
  finalAt(Nat.is_eq(input,0n),input)

def slotAt_13(+netted: Bool,+input: Nat) -> R.World:
  data_542(netted, input)

def slot_13(+input: Nat) -> R.World:
  slotAt_13(Nat.is_eq(input,0n),input)

def notifyAt_13(+netted: Bool,+input: Nat) -> R.World:
  data_206(netted, input)

def notify_13(+input: Nat) -> R.World:
  notifyAt_13(Nat.is_eq(input,0n),input)

def slotAt_33(+netted: Bool,+input: Nat) -> R.World:
  data_545(netted, input)

def slot_33(+input: Nat) -> R.World:
  slotAt_33(Nat.is_eq(input,0n),input)

def notifyAt_33(+netted: Bool,+input: Nat) -> R.World:
  data_296(netted, input)

def notify_33(+input: Nat) -> R.World:
  notifyAt_33(Nat.is_eq(input,0n),input)

def at_modified_55(+netted: Bool,+input: Nat) -> R.World:
  data_548(netted, input)

def modified_55(+input: Nat) -> R.World:
  at_modified_55(Nat.is_eq(input,0n),input)

def at_queued_55(+netted: Bool,+input: Nat) -> R.World:
  data_549(netted, input)

def queued_55(+input: Nat) -> R.World:
  at_queued_55(Nat.is_eq(input,0n),input)

def at_value_55(+netted: Bool,+input: Nat) -> R.World:
  data_396(netted, input)

def value_55(+input: Nat) -> R.World:
  at_value_55(Nat.is_eq(input,0n),input)

def at_setter_queued(+netted: Bool,+input: Nat) -> R.World:
  data_550()

def setter_queued(+input: Nat) -> R.World:
  at_setter_queued(Nat.is_eq(input,0n),input)

def at_setter_slot(+netted: Bool,+input: Nat) -> R.World:
  data_553(input)

def setter_slot(+input: Nat) -> R.World:
  at_setter_slot(Nat.is_eq(input,0n),input)

def at_setter_inserted(+netted: Bool,+input: Nat) -> R.World:
  data_554(input)

def setter_inserted(+input: Nat) -> R.World:
  at_setter_inserted(Nat.is_eq(input,0n),input)

def at_setter_scheduled(+netted: Bool,+input: Nat) -> R.World:
  data_126(input)

def setter_scheduled(+input: Nat) -> R.World:
  at_setter_scheduled(Nat.is_eq(input,0n),input)

def at_setter_stamped(+netted: Bool,+input: Nat) -> R.World:
  data_556(input)

def setter_stamped(+input: Nat) -> R.World:
  at_setter_stamped(Nat.is_eq(input,0n),input)

def at_setter_enqueued3(+netted: Bool,+input: Nat) -> R.World:
  data_560(input)

def setter_enqueued3(+input: Nat) -> R.World:
  at_setter_enqueued3(Nat.is_eq(input,0n),input)

def at_setter_enqueued5(+netted: Bool,+input: Nat) -> R.World:
  data_554(input)

def setter_enqueued5(+input: Nat) -> R.World:
  at_setter_enqueued5(Nat.is_eq(input,0n),input)

