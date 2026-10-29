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

def data_101() -> List<&2, R.KeptGuess>:
  []

def data_102() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_99(), 0n, data_100(), data_35(), False{}, False{}, data_101(), data_35(), False{}}

def data_103() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_104() -> R.Value:
  R.Null{}

def data_105() -> R.DeferredCell:
  R.DeferredCell{0n, data_104(), False{}, False{}}

def data_106() -> R.DeferredBinding:
  R.DeferredBinding{data_105(), 0n}

def data_107() -> List<&2, R.DeferredBinding>:
  [data_106()]

def data_108() -> List<&2, R.DeferredWait>:
  []

def data_109() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_110() -> List<&2, R.DeferredIterator>:
  [data_109()]

def data_111() -> R.DeferredArena:
  R.DeferredArena{data_107(), data_35(), data_108(), data_110()}

def data_112() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_113(+input: Nat) -> R.Value:
  R.Number{input}

def data_114(+input: Nat) -> R.Slot:
  R.Present{data_113(input)}

def data_115() -> R.Stamp:
  R.Stamped{7n}

def data_116(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_114(input), False{}, 0, 0, 0, 0n, data_115(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_117() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_118() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_119() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_120(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_117(), data_118(), data_119()]

def data_121() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_122() -> R.HostJob:
  R.FlushJob{}

def data_123() -> List<&2, R.HostJob>:
  [data_122()]

def data_124(+input: Nat) -> R.World:
  R.World{data_120(input), data_33(), data_121(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_125() -> C.Task:
  C.Round{}

def data_126() -> List<&2, C.Task>:
  [data_125()]

def data_127() -> List<&2, R.Value>:
  []

def data_128(+input: Nat) -> C.Machine:
  C.Machine{data_124(input), data_126(), data_127()}

def data_129(+input: Nat) -> R.World:
  R.World{data_120(input), data_33(), data_121(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_130() -> C.Task:
  C.RoundAfterSweep{}

def data_131() -> C.Task:
  C.FlushFinally{}

def data_132() -> C.Task:
  C.RoundEnd{}

def data_133() -> List<&2, C.Task>:
  [data_130(), data_131(), data_132()]

def data_134(+input: Nat) -> C.Machine:
  C.Machine{data_129(input), data_133(), data_127()}

def data_135(+input: Nat) -> R.World:
  R.World{data_120(input), data_33(), data_121(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_136() -> C.Task:
  C.HeapLoop{}

def data_137() -> List<&2, C.Task>:
  [data_136(), data_131(), data_132()]

def data_138(+input: Nat) -> C.Machine:
  C.Machine{data_135(input), data_137(), data_127()}

def data_139() -> C.Task:
  C.Recompute{3n, False{}}

def data_140() -> List<&2, C.Task>:
  [data_139(), data_136(), data_131(), data_132()]

def data_141(+input: Nat) -> C.Machine:
  C.Machine{data_135(input), data_140(), data_127()}

def data_142() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_143(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_142(), data_118(), data_119()]

def data_144() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_145() -> R.LaneMount:
  R.MountFalse{}

def data_146() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_99(), 0n, data_145(), data_35(), False{}, False{}, data_101(), data_35(), False{}}

def data_147(+input: Nat) -> R.World:
  R.World{data_143(input), data_33(), data_144(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_148() -> C.LanePass:
  C.LanePass{0n, data_100(), data_145()}

def data_149() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_148()}

def data_150() -> List<&2, C.Task>:
  [data_149(), data_136(), data_131(), data_132()]

def data_151(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_150(), data_127()}

def data_152() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_148()}

def data_153() -> List<&2, C.Task>:
  [data_152(), data_136(), data_131(), data_132()]

def data_154(+input: Nat) -> C.Machine:
  C.Machine{data_147(input), data_153(), data_127()}

def data_155() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_156(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_155(), data_118(), data_119()]

def data_157() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_158(+input: Nat) -> R.World:
  R.World{data_156(input), data_33(), data_144(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_157(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_159() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_160() -> R.Flight:
  R.FlightUndefined{}

def data_161() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, data_160(), data_127(), 0n, False{}, data_148()}

def data_162() -> C.Task:
  C.Finish{data_161()}

def data_163() -> List<&2, C.Task>:
  [data_159(), data_162(), data_136(), data_131(), data_132()]

def data_164(+input: Nat) -> C.Machine:
  C.Machine{data_158(input), data_163(), data_127()}

def data_165() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_166() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_167() -> C.Task:
  C.Binary{0}

def data_168() -> List<&2, C.Task>:
  [data_165(), data_166(), data_167(), data_162(), data_136(), data_131(), data_132()]

def data_169(+input: Nat) -> C.Machine:
  C.Machine{data_158(input), data_168(), data_127()}

def data_170() -> C.Task:
  C.ReadNode{2n}

def data_171() -> List<&2, C.Task>:
  [data_170(), data_166(), data_167(), data_162(), data_136(), data_131(), data_132()]

def data_172(+input: Nat) -> C.Machine:
  C.Machine{data_158(input), data_171(), data_127()}

def data_173() -> C.Task:
  C.ReadPrepared{2n}

def data_174() -> List<&2, C.Task>:
  [data_173(), data_166(), data_167(), data_162(), data_136(), data_131(), data_132()]

def data_175(+input: Nat) -> C.Machine:
  C.Machine{data_158(input), data_174(), data_127()}

def data_176() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_177(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_176(), data_118(), data_119()]

def data_178() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_179() -> List<&2, R.Link>:
  [data_28(), data_178(), data_30(), data_31(), data_32()]

def data_180(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_113(input)}

def data_181(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input)]

def data_182(+input: Nat) -> R.World:
  R.World{data_177(input), data_179(), data_144(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_183() -> List<&2, C.Task>:
  [data_166(), data_167(), data_162(), data_136(), data_131(), data_132()]

def data_184(+input: Nat) -> List<&2, R.Value>:
  [data_113(input)]

def data_185(+input: Nat) -> C.Machine:
  C.Machine{data_182(input), data_183(), data_184(input)}

def data_186() -> List<&2, C.Task>:
  [data_167(), data_162(), data_136(), data_131(), data_132()]

def data_187(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_113(input)]

def data_188(+input: Nat) -> C.Machine:
  C.Machine{data_182(input), data_186(), data_187(input)}

def data_189() -> List<&2, C.Task>:
  [data_162(), data_136(), data_131(), data_132()]

def data_190(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_191(+input: Nat) -> List<&2, R.Value>:
  [data_190(input)]

def data_192(+input: Nat) -> C.Machine:
  C.Machine{data_182(input), data_189(), data_191(input)}

def data_193() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_194(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_193(), data_118(), data_119()]

def data_195(+input: Nat) -> R.World:
  R.World{data_194(input), data_179(), data_144(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_196(+input: Nat) -> C.Task:
  C.PassReleases{data_161(), 0n, data_190(input), False{}, False{}, False{}, data_53()}

def data_197(+input: Nat) -> List<&2, C.Task>:
  [data_196(input), data_136(), data_131(), data_132()]

def data_198(+input: Nat) -> C.Machine:
  C.Machine{data_195(input), data_197(input), data_127()}

def data_199(+input: Nat) -> R.Slot:
  R.Present{data_190(input)}

def data_200() -> R.Stamp:
  R.Stamped{8n}

def data_201(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_199(input), False{}, 0, 16384, 0, 0n, data_200(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_202() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_203(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_201(input), data_202(), data_119()]

def data_204() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_205(+input: Nat) -> R.World:
  R.World{data_203(input), data_179(), data_204(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_206() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_207() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_136(), data_131(), data_132()]

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_208(), data_127()}

def data_210() -> List<&2, C.Task>:
  [data_207(), data_136(), data_131(), data_132()]

def data_211(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_210(), data_127()}

def data_212() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_213() -> List<&2, C.Task>:
  [data_212(), data_136(), data_131(), data_132()]

def data_214(+input: Nat) -> C.Machine:
  C.Machine{data_205(input), data_213(), data_127()}

def data_215(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_199(input), False{}, 128, 16384, 0, 0n, data_200(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_216(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_202(), data_119()]

def data_217() -> List<&2, Nat>:
  [2n, 3n]

def data_218(+input: Nat) -> R.World:
  R.World{data_216(input), data_179(), data_204(), 0n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_219(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_137(), data_127()}

def data_220(+input: Nat) -> R.World:
  R.World{data_216(input), data_179(), data_204(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_221(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_137(), data_127()}

def data_222() -> C.Task:
  C.Recompute{4n, False{}}

def data_223() -> List<&2, C.Task>:
  [data_222(), data_136(), data_131(), data_132()]

def data_224(+input: Nat) -> C.Machine:
  C.Machine{data_220(input), data_223(), data_127()}

def data_225() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_226(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_225(), data_119()]

def data_227(+input: Nat) -> R.World:
  R.World{data_226(input), data_179(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_228() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_148()}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_136(), data_131(), data_132()]

def data_230(+input: Nat) -> C.Machine:
  C.Machine{data_227(input), data_229(), data_127()}

def data_231() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_148()}

def data_232() -> List<&2, C.Task>:
  [data_231(), data_136(), data_131(), data_132()]

def data_233(+input: Nat) -> C.Machine:
  C.Machine{data_227(input), data_232(), data_127()}

def data_234() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_235(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_234(), data_119()]

def data_236(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45()]

def data_237(+input: Nat) -> R.World:
  R.World{data_235(input), data_179(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_236(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_238() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_239() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_160(), data_127(), 0n, False{}, data_148()}

def data_240() -> C.Task:
  C.Finish{data_239()}

def data_241() -> List<&2, C.Task>:
  [data_238(), data_240(), data_136(), data_131(), data_132()]

def data_242(+input: Nat) -> C.Machine:
  C.Machine{data_237(input), data_241(), data_127()}

def data_243() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_244() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_245() -> C.Task:
  C.Binary{1}

def data_246() -> List<&2, C.Task>:
  [data_243(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_247(+input: Nat) -> C.Machine:
  C.Machine{data_237(input), data_246(), data_127()}

def data_248() -> C.Task:
  C.ReadNode{3n}

def data_249() -> List<&2, C.Task>:
  [data_248(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_250(+input: Nat) -> C.Machine:
  C.Machine{data_237(input), data_249(), data_127()}

def data_251() -> C.Task:
  C.ReadPrepared{3n}

def data_252() -> List<&2, C.Task>:
  [data_251(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_253(+input: Nat) -> C.Machine:
  C.Machine{data_237(input), data_252(), data_127()}

def data_254() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_255(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_254(), data_119()]

def data_256() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_257() -> List<&2, R.Link>:
  [data_28(), data_178(), data_256(), data_31(), data_32()]

def data_258(+input: Nat) -> R.World:
  R.World{data_255(input), data_257(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_236(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_259() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_260() -> C.Task:
  C.ReadStatus{3n}

def data_261() -> List<&2, C.Task>:
  [data_259(), data_260(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_261(), data_127()}

def data_263() -> List<&2, C.Task>:
  [data_260(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_264(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_263(), data_127()}

def data_265() -> C.Task:
  C.Serve{3n}

def data_266() -> C.Task:
  C.AfterServe{3n}

def data_267() -> List<&2, C.Task>:
  [data_265(), data_266(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_268(+input: Nat) -> C.Machine:
  C.Machine{data_258(input), data_267(), data_127()}

def data_269() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_270(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_269(), data_119()]

def data_271(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_190(input)}

def data_272(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45(), data_271(input)]

def data_273(+input: Nat) -> R.World:
  R.World{data_270(input), data_257(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_274() -> List<&2, C.Task>:
  [data_266(), data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_275(+input: Nat) -> C.Machine:
  C.Machine{data_273(input), data_274(), data_191(input)}

def data_276() -> List<&2, C.Task>:
  [data_244(), data_245(), data_240(), data_136(), data_131(), data_132()]

def data_277(+input: Nat) -> C.Machine:
  C.Machine{data_273(input), data_276(), data_191(input)}

def data_278() -> List<&2, C.Task>:
  [data_245(), data_240(), data_136(), data_131(), data_132()]

def data_279(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_190(input)]

def data_280(+input: Nat) -> C.Machine:
  C.Machine{data_273(input), data_278(), data_279(input)}

def data_281() -> List<&2, C.Task>:
  [data_240(), data_136(), data_131(), data_132()]

def data_282(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_283(+input: Nat) -> List<&2, R.Value>:
  [data_282(input)]

def data_284(+input: Nat) -> C.Machine:
  C.Machine{data_273(input), data_281(), data_283(input)}

def data_285() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_286(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_285(), data_119()]

def data_287(+input: Nat) -> R.World:
  R.World{data_286(input), data_257(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_288(+input: Nat) -> C.Task:
  C.PassReleases{data_239(), 0n, data_282(input), False{}, False{}, False{}, data_53()}

def data_289(+input: Nat) -> List<&2, C.Task>:
  [data_288(input), data_136(), data_131(), data_132()]

def data_290(+input: Nat) -> C.Machine:
  C.Machine{data_287(input), data_289(input), data_127()}

def data_291(+input: Nat) -> R.Slot:
  R.Present{data_282(input)}

def data_292() -> R.Stamp:
  R.Stamped{9n}

def data_293(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_291(input), False{}, 0, 16384, 0, 0n, data_292(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_294(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_293(input), data_119()]

def data_295(+input: Nat) -> R.World:
  R.World{data_294(input), data_257(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_296() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_297() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_298() -> List<&2, C.Task>:
  [data_296(), data_297(), data_136(), data_131(), data_132()]

def data_299(+input: Nat) -> C.Machine:
  C.Machine{data_295(input), data_298(), data_127()}

def data_300() -> List<&2, C.Task>:
  [data_297(), data_136(), data_131(), data_132()]

def data_301(+input: Nat) -> C.Machine:
  C.Machine{data_295(input), data_300(), data_127()}

def data_302() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_303() -> List<&2, C.Task>:
  [data_302(), data_136(), data_131(), data_132()]

def data_304(+input: Nat) -> C.Machine:
  C.Machine{data_295(input), data_303(), data_127()}

def data_305(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_291(input), False{}, 128, 16384, 0, 0n, data_292(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_306(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_119()]

def data_307() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_308(+input: Nat) -> R.World:
  R.World{data_306(input), data_257(), data_144(), 1n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_309(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_137(), data_127()}

def data_310(+input: Nat) -> R.World:
  R.World{data_306(input), data_257(), data_144(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_311(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_137(), data_127()}

def data_312() -> C.Task:
  C.Recompute{5n, False{}}

def data_313() -> List<&2, C.Task>:
  [data_312(), data_136(), data_131(), data_132()]

def data_314(+input: Nat) -> C.Machine:
  C.Machine{data_310(input), data_313(), data_127()}

def data_315() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_316(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_315()]

def data_317() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_318(+input: Nat) -> R.World:
  R.World{data_316(input), data_257(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_319() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_148()}

def data_320() -> List<&2, C.Task>:
  [data_319(), data_136(), data_131(), data_132()]

def data_321(+input: Nat) -> C.Machine:
  C.Machine{data_318(input), data_320(), data_127()}

def data_322() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_148()}

def data_323() -> List<&2, C.Task>:
  [data_322(), data_136(), data_131(), data_132()]

def data_324(+input: Nat) -> C.Machine:
  C.Machine{data_318(input), data_323(), data_127()}

def data_325() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_326(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_325()]

def data_327(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45(), data_271(input), data_48()]

def data_328(+input: Nat) -> R.World:
  R.World{data_326(input), data_257(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_327(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_329() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_330() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_160(), data_127(), 0n, False{}, data_148()}

def data_331() -> C.Task:
  C.Finish{data_330()}

def data_332() -> List<&2, C.Task>:
  [data_329(), data_331(), data_136(), data_131(), data_132()]

def data_333(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_332(), data_127()}

def data_334() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_335() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_336() -> List<&2, C.Task>:
  [data_334(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_337(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_336(), data_127()}

def data_338() -> C.Task:
  C.ReadNode{4n}

def data_339() -> List<&2, C.Task>:
  [data_338(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_340(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_339(), data_127()}

def data_341() -> C.Task:
  C.ReadPrepared{4n}

def data_342() -> List<&2, C.Task>:
  [data_341(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_343(+input: Nat) -> C.Machine:
  C.Machine{data_328(input), data_342(), data_127()}

def data_344() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_345(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_344()]

def data_346() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_347() -> List<&2, R.Link>:
  [data_28(), data_178(), data_256(), data_346(), data_32()]

def data_348(+input: Nat) -> R.World:
  R.World{data_345(input), data_347(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_327(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_349() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_350() -> C.Task:
  C.ReadStatus{4n}

def data_351() -> List<&2, C.Task>:
  [data_349(), data_350(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_351(), data_127()}

def data_353() -> List<&2, C.Task>:
  [data_350(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_354(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_353(), data_127()}

def data_355() -> C.Task:
  C.Serve{4n}

def data_356() -> C.Task:
  C.AfterServe{4n}

def data_357() -> List<&2, C.Task>:
  [data_355(), data_356(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_358(+input: Nat) -> C.Machine:
  C.Machine{data_348(input), data_357(), data_127()}

def data_359() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_360(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_359()]

def data_361(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_282(input)}

def data_362(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45(), data_271(input), data_48(), data_361(input)]

def data_363(+input: Nat) -> R.World:
  R.World{data_360(input), data_347(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_362(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_364() -> List<&2, C.Task>:
  [data_356(), data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_365(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_364(), data_283(input)}

def data_366() -> List<&2, C.Task>:
  [data_335(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_367(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_366(), data_283(input)}

def data_368() -> List<&2, C.Task>:
  [data_170(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_369(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_368(), data_283(input)}

def data_370() -> List<&2, C.Task>:
  [data_173(), data_167(), data_331(), data_136(), data_131(), data_132()]

def data_371(+input: Nat) -> C.Machine:
  C.Machine{data_363(input), data_370(), data_283(input)}

def data_372() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_373(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_372()]

def data_374() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_375() -> List<&2, R.Link>:
  [data_28(), data_178(), data_256(), data_346(), data_374()]

def data_376(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_113(input)}

def data_377(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45(), data_271(input), data_48(), data_361(input), data_376(input)]

def data_378(+input: Nat) -> R.World:
  R.World{data_373(input), data_375(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), True{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_146(), data_103(), data_2(), data_35(), data_111()}

def data_379() -> List<&2, C.Task>:
  [data_167(), data_331(), data_136(), data_131(), data_132()]

def data_380(+input: Nat) -> List<&2, R.Value>:
  [data_113(input), data_282(input)]

def data_381(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_379(), data_380(input)}

def data_382() -> List<&2, C.Task>:
  [data_331(), data_136(), data_131(), data_132()]

def data_383(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_384(+input: Nat) -> List<&2, R.Value>:
  [data_383(input)]

def data_385(+input: Nat) -> C.Machine:
  C.Machine{data_378(input), data_382(), data_384(input)}

def data_386() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_387(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_386()]

def data_388(+input: Nat) -> R.World:
  R.World{data_387(input), data_375(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_389(+input: Nat) -> C.Task:
  C.PassReleases{data_330(), 0n, data_383(input), False{}, False{}, False{}, data_53()}

def data_390(+input: Nat) -> List<&2, C.Task>:
  [data_389(input), data_136(), data_131(), data_132()]

def data_391(+input: Nat) -> C.Machine:
  C.Machine{data_388(input), data_390(input), data_127()}

def data_392(+input: Nat) -> R.Node:
  R.Node{data_23(), data_383(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_393(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_392(input)]

def data_394() -> List<&2, Nat>:
  [5n]

def data_395(+input: Nat) -> R.World:
  R.World{data_393(input), data_375(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_396() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_397() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_398() -> List<&2, C.Task>:
  [data_396(), data_397(), data_136(), data_131(), data_132()]

def data_399(+input: Nat) -> C.Machine:
  C.Machine{data_395(input), data_398(), data_127()}

def data_400() -> List<&2, C.Task>:
  [data_397(), data_136(), data_131(), data_132()]

def data_401(+input: Nat) -> C.Machine:
  C.Machine{data_395(input), data_400(), data_127()}

def data_402() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_403() -> List<&2, C.Task>:
  [data_402(), data_136(), data_131(), data_132()]

def data_404(+input: Nat) -> C.Machine:
  C.Machine{data_395(input), data_403(), data_127()}

def data_405(+input: Nat) -> C.Machine:
  C.Machine{data_395(input), data_137(), data_127()}

def data_406(+input: Nat) -> R.World:
  R.World{data_393(input), data_375(), data_317(), 3n, 2n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_407(+input: Nat) -> C.Machine:
  C.Machine{data_406(input), data_137(), data_127()}

def data_408(+input: Nat) -> R.World:
  R.World{data_393(input), data_375(), data_317(), 3n, 0n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_409() -> C.Task:
  C.Seam{}

def data_410() -> List<&2, C.Task>:
  [data_409(), data_131(), data_132()]

def data_411(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_410(), data_127()}

def data_412() -> C.Task:
  C.Settle{}

def data_413() -> C.Task:
  C.AfterSettle{}

def data_414() -> List<&2, C.Task>:
  [data_412(), data_413(), data_131(), data_132()]

def data_415(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_414(), data_127()}

def data_416() -> C.Task:
  C.CommitIntake{0n}

def data_417() -> C.Task:
  C.TrimIntake{0n}

def data_418() -> C.Task:
  C.FinishSettleIntake{0n}

def data_419() -> List<&2, C.Task>:
  [data_416(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_420(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_419(), data_127()}

def data_421() -> C.Task:
  C.CommitPending{2n}

def data_422() -> C.Task:
  C.CommitIntake{1n}

def data_423() -> List<&2, C.Task>:
  [data_421(), data_422(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_424(+input: Nat) -> C.Machine:
  C.Machine{data_408(input), data_423(), data_127()}

def data_425(+input: Nat) -> R.Node:
  R.Node{data_9(), data_113(input), data_2(), False{}, 0, 0, 0, 0n, data_115(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_426(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_425(input), data_215(input), data_305(input), data_392(input)]

def data_427(+input: Nat) -> R.World:
  R.World{data_426(input), data_375(), data_317(), 3n, 0n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_428() -> List<&2, C.Task>:
  [data_422(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_429(+input: Nat) -> C.Machine:
  C.Machine{data_427(input), data_428(), data_127()}

def data_430() -> C.Task:
  C.CommitPending{3n}

def data_431() -> C.Task:
  C.CommitIntake{2n}

def data_432() -> List<&2, C.Task>:
  [data_430(), data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_433(+input: Nat) -> C.Machine:
  C.Machine{data_427(input), data_432(), data_127()}

def data_434(+input: Nat) -> R.Node:
  R.Node{data_12(), data_190(input), data_2(), False{}, 0, 16384, 0, 0n, data_200(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_435(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_425(input), data_434(input), data_305(input), data_392(input)]

def data_436(+input: Nat) -> R.World:
  R.World{data_435(input), data_375(), data_317(), 3n, 0n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_437() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_438() -> List<&2, C.Task>:
  [data_437(), data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_439(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_438(), data_127()}

def data_440() -> O.Task:
  O.TrimDeps{3n}

def data_441() -> List<&2, O.Task>:
  [data_440()]

def data_442() -> C.Task:
  C.OwnerTasks{data_441()}

def data_443() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_444() -> List<&2, C.Task>:
  [data_442(), data_443(), data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_445(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_444(), data_127()}

def data_446() -> List<&2, O.Task>:
  []

def data_447() -> C.Task:
  C.OwnerTasks{data_446()}

def data_448() -> List<&2, C.Task>:
  [data_447(), data_443(), data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_449(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_448(), data_127()}

def data_450() -> List<&2, C.Task>:
  [data_443(), data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_450(), data_127()}

def data_452() -> List<&2, C.Task>:
  [data_431(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_453(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_452(), data_127()}

def data_454() -> C.Task:
  C.CommitPending{4n}

def data_455() -> C.Task:
  C.CommitIntake{3n}

def data_456() -> List<&2, C.Task>:
  [data_454(), data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_457(+input: Nat) -> C.Machine:
  C.Machine{data_436(input), data_456(), data_127()}

def data_458(+input: Nat) -> R.Node:
  R.Node{data_12(), data_282(input), data_2(), False{}, 0, 16384, 0, 0n, data_292(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_459(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_425(input), data_434(input), data_458(input), data_392(input)]

def data_460(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_461() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_462() -> List<&2, C.Task>:
  [data_461(), data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_463(+input: Nat) -> C.Machine:
  C.Machine{data_460(input), data_462(), data_127()}

def data_464() -> O.Task:
  O.TrimDeps{4n}

def data_465() -> List<&2, O.Task>:
  [data_464()]

def data_466() -> C.Task:
  C.OwnerTasks{data_465()}

def data_467() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_468() -> List<&2, C.Task>:
  [data_466(), data_467(), data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_469(+input: Nat) -> C.Machine:
  C.Machine{data_460(input), data_468(), data_127()}

def data_470() -> List<&2, C.Task>:
  [data_447(), data_467(), data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_471(+input: Nat) -> C.Machine:
  C.Machine{data_460(input), data_470(), data_127()}

def data_472() -> List<&2, C.Task>:
  [data_467(), data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_460(input), data_472(), data_127()}

def data_474() -> List<&2, C.Task>:
  [data_455(), data_417(), data_418(), data_413(), data_131(), data_132()]

def data_475(+input: Nat) -> C.Machine:
  C.Machine{data_460(input), data_474(), data_127()}

def data_476(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_477() -> List<&2, C.Task>:
  [data_417(), data_418(), data_413(), data_131(), data_132()]

def data_478(+input: Nat) -> C.Machine:
  C.Machine{data_476(input), data_477(), data_127()}

def data_479() -> List<&2, C.Task>:
  [data_418(), data_413(), data_131(), data_132()]

def data_480(+input: Nat) -> C.Machine:
  C.Machine{data_476(input), data_479(), data_127()}

def data_481(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_482() -> C.SeamFrame:
  C.SeamFrame{0n, data_394(), data_36(), data_35(), data_36()}

def data_483() -> C.Task:
  C.LandTransactions{data_482(), 0n}

def data_484() -> List<&2, C.Task>:
  [data_483(), data_413(), data_131(), data_132()]

def data_485(+input: Nat) -> C.Machine:
  C.Machine{data_481(input), data_484(), data_127()}

def data_486() -> C.Task:
  C.CompleteSettle{data_482()}

def data_487() -> List<&2, C.Task>:
  [data_486(), data_413(), data_131(), data_132()]

def data_488(+input: Nat) -> C.Machine:
  C.Machine{data_481(input), data_487(), data_127()}

def data_489() -> C.Task:
  C.ZombieLoop{data_35()}

def data_490() -> List<&2, C.Task>:
  [data_489(), data_413(), data_131(), data_132()]

def data_491(+input: Nat) -> C.Machine:
  C.Machine{data_476(input), data_490(), data_127()}

def data_492() -> List<&2, C.Task>:
  [data_413(), data_131(), data_132()]

def data_493(+input: Nat) -> C.Machine:
  C.Machine{data_476(input), data_492(), data_127()}

def data_494(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_394(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_495() -> C.Task:
  C.RenderQueue{}

def data_496() -> List<&2, C.Task>:
  [data_495(), data_131(), data_132()]

def data_497(+input: Nat) -> C.Machine:
  C.Machine{data_494(input), data_496(), data_127()}

def data_498(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_499() -> C.Task:
  C.RunEffect{5n}

def data_500() -> C.Task:
  C.UserQueue{}

def data_501() -> List<&2, C.Task>:
  [data_499(), data_500(), data_131(), data_132()]

def data_502(+input: Nat) -> C.Machine:
  C.Machine{data_498(input), data_501(), data_127()}

def data_503() -> C.Task:
  C.ApplyEffect{5n}

def data_504() -> C.Task:
  C.EffectFinally{5n, True{}, data_127()}

def data_505() -> List<&2, C.Task>:
  [data_503(), data_504(), data_500(), data_131(), data_132()]

def data_506(+input: Nat) -> C.Machine:
  C.Machine{data_498(input), data_505(), data_127()}

def data_507(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_383(input)}

def data_508(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_507(input)]

def data_509(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_383(input), data_18()}

def data_510(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_180(input), data_45(), data_271(input), data_48(), data_361(input), data_376(input), data_509(input)]

def data_511(+input: Nat) -> R.World:
  R.World{data_459(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_508(input), data_510(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_512() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_513() -> List<&2, C.Task>:
  [data_512(), data_504(), data_500(), data_131(), data_132()]

def data_514(+input: Nat) -> C.Machine:
  C.Machine{data_511(input), data_513(), data_127()}

def data_515() -> List<&2, C.Task>:
  [data_504(), data_500(), data_131(), data_132()]

def data_516(+input: Nat) -> C.Machine:
  C.Machine{data_511(input), data_515(), data_127()}

def data_517(+input: Nat) -> R.Node:
  R.Node{data_23(), data_383(input), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_383(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_518(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_425(input), data_434(input), data_458(input), data_517(input)]

def data_519(+input: Nat) -> R.World:
  R.World{data_518(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_508(input), data_510(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_520() -> O.Task:
  O.TrimDeps{5n}

def data_521() -> List<&2, O.Task>:
  [data_520()]

def data_522() -> C.Task:
  C.OwnerTasks{data_521()}

def data_523() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_127()}

def data_524() -> List<&2, C.Task>:
  [data_522(), data_523(), data_500(), data_131(), data_132()]

def data_525(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_524(), data_127()}

def data_526() -> List<&2, C.Task>:
  [data_447(), data_523(), data_500(), data_131(), data_132()]

def data_527(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_526(), data_127()}

def data_528() -> List<&2, C.Task>:
  [data_523(), data_500(), data_131(), data_132()]

def data_529(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_528(), data_127()}

def data_530() -> List<&2, C.Task>:
  [data_500(), data_131(), data_132()]

def data_531(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_530(), data_127()}

def data_532() -> List<&2, C.Task>:
  [data_131(), data_132()]

def data_533(+input: Nat) -> C.Machine:
  C.Machine{data_519(input), data_532(), data_127()}

def data_534(+input: Nat) -> R.World:
  R.World{data_518(input), data_375(), data_317(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_508(input), data_510(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_535() -> List<&2, C.Task>:
  [data_132()]

def data_536(+input: Nat) -> C.Machine:
  C.Machine{data_534(input), data_535(), data_127()}

def data_537() -> List<&2, C.Task>:
  []

def data_538(+input: Nat) -> C.Machine:
  C.Machine{data_534(input), data_537(), data_127()}

def data_539(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_199(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_540(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_539(input), data_118(), data_119()]

def data_541(+input: Nat) -> R.World:
  R.World{data_540(input), data_179(), data_144(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_181(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_542(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_291(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_543(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_542(input), data_119()]

def data_544(+input: Nat) -> R.World:
  R.World{data_543(input), data_257(), data_144(), 1n, 2n, False{}, data_217(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_272(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_545() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_546(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_215(input), data_305(input), data_545()]

def data_547(+input: Nat) -> R.World:
  R.World{data_546(input), data_375(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_548(+input: Nat) -> R.World:
  R.World{data_546(input), data_375(), data_317(), 2n, 2n, False{}, data_307(), data_35(), data_394(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_377(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_123(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_549() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_550(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_114(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_551(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_550(input), data_17(), data_22(), data_26()]

def data_552(+input: Nat) -> R.World:
  R.World{data_551(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_553(+input: Nat) -> R.World:
  R.World{data_120(input), data_33(), data_121(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_554(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_17(), data_22(), data_26()]

def data_555(+input: Nat) -> R.World:
  R.World{data_554(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def data_556() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 8388608, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_557(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_116(input), data_117(), data_118(), data_556()]

def data_558() -> List<&2, Nat>:
  [3n]

def data_559(+input: Nat) -> R.World:
  R.World{data_557(input), data_33(), data_558(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_76(), data_78(), data_80(), data_81(), data_83(), False{}, False{}, data_56(), data_85(), data_87(), data_90(), 0n, data_66(), False{}, data_91(), data_92(), data_93(), 0n, data_94(), data_95(), data_96(), data_97(), data_98(), 0n, data_102(), data_103(), data_2(), data_35(), data_111()}

def origin() -> R.World:
  data_112()

def state_0(+input: Nat) -> C.Machine:
  data_128(input)

def state_1(+input: Nat) -> C.Machine:
  data_134(input)

def state_2(+input: Nat) -> C.Machine:
  data_138(input)

def state_3(+input: Nat) -> C.Machine:
  data_141(input)

def state_4(+input: Nat) -> C.Machine:
  data_151(input)

def state_5(+input: Nat) -> C.Machine:
  data_154(input)

def state_6(+input: Nat) -> C.Machine:
  data_164(input)

def state_7(+input: Nat) -> C.Machine:
  data_169(input)

def state_8(+input: Nat) -> C.Machine:
  data_172(input)

def state_9(+input: Nat) -> C.Machine:
  data_175(input)

def state_10(+input: Nat) -> C.Machine:
  data_185(input)

def state_11(+input: Nat) -> C.Machine:
  data_188(input)

def state_12(+input: Nat) -> C.Machine:
  data_192(input)

def state_13(+input: Nat) -> C.Machine:
  data_198(input)

def state_14(+input: Nat) -> C.Machine:
  data_209(input)

def state_15(+input: Nat) -> C.Machine:
  data_211(input)

def state_16(+input: Nat) -> C.Machine:
  data_214(input)

def state_17(+input: Nat) -> C.Machine:
  data_219(input)

def state_18(+input: Nat) -> C.Machine:
  data_221(input)

def state_19(+input: Nat) -> C.Machine:
  data_224(input)

def state_20(+input: Nat) -> C.Machine:
  data_230(input)

def state_21(+input: Nat) -> C.Machine:
  data_233(input)

def state_22(+input: Nat) -> C.Machine:
  data_242(input)

def state_23(+input: Nat) -> C.Machine:
  data_247(input)

def state_24(+input: Nat) -> C.Machine:
  data_250(input)

def state_25(+input: Nat) -> C.Machine:
  data_253(input)

def state_26(+input: Nat) -> C.Machine:
  data_262(input)

def state_27(+input: Nat) -> C.Machine:
  data_264(input)

def state_28(+input: Nat) -> C.Machine:
  data_268(input)

def state_29(+input: Nat) -> C.Machine:
  data_275(input)

def state_30(+input: Nat) -> C.Machine:
  data_277(input)

def state_31(+input: Nat) -> C.Machine:
  data_280(input)

def state_32(+input: Nat) -> C.Machine:
  data_284(input)

def state_33(+input: Nat) -> C.Machine:
  data_290(input)

def state_34(+input: Nat) -> C.Machine:
  data_299(input)

def state_35(+input: Nat) -> C.Machine:
  data_301(input)

def state_36(+input: Nat) -> C.Machine:
  data_304(input)

def state_37(+input: Nat) -> C.Machine:
  data_309(input)

def state_38(+input: Nat) -> C.Machine:
  data_311(input)

def state_39(+input: Nat) -> C.Machine:
  data_314(input)

def state_40(+input: Nat) -> C.Machine:
  data_321(input)

def state_41(+input: Nat) -> C.Machine:
  data_324(input)

def state_42(+input: Nat) -> C.Machine:
  data_333(input)

def state_43(+input: Nat) -> C.Machine:
  data_337(input)

def state_44(+input: Nat) -> C.Machine:
  data_340(input)

def state_45(+input: Nat) -> C.Machine:
  data_343(input)

def state_46(+input: Nat) -> C.Machine:
  data_352(input)

def state_47(+input: Nat) -> C.Machine:
  data_354(input)

def state_48(+input: Nat) -> C.Machine:
  data_358(input)

def state_49(+input: Nat) -> C.Machine:
  data_365(input)

def state_50(+input: Nat) -> C.Machine:
  data_367(input)

def state_51(+input: Nat) -> C.Machine:
  data_369(input)

def state_52(+input: Nat) -> C.Machine:
  data_371(input)

def state_53(+input: Nat) -> C.Machine:
  data_381(input)

def state_54(+input: Nat) -> C.Machine:
  data_385(input)

def state_55(+input: Nat) -> C.Machine:
  data_391(input)

def state_56(+input: Nat) -> C.Machine:
  data_399(input)

def state_57(+input: Nat) -> C.Machine:
  data_401(input)

def state_58(+input: Nat) -> C.Machine:
  data_404(input)

def state_59(+input: Nat) -> C.Machine:
  data_405(input)

def state_60(+input: Nat) -> C.Machine:
  data_407(input)

def state_61(+input: Nat) -> C.Machine:
  data_411(input)

def state_62(+input: Nat) -> C.Machine:
  data_415(input)

def state_63(+input: Nat) -> C.Machine:
  data_420(input)

def state_64(+input: Nat) -> C.Machine:
  data_424(input)

def state_65(+input: Nat) -> C.Machine:
  data_429(input)

def state_66(+input: Nat) -> C.Machine:
  data_433(input)

def state_67(+input: Nat) -> C.Machine:
  data_439(input)

def state_68(+input: Nat) -> C.Machine:
  data_445(input)

def state_69(+input: Nat) -> C.Machine:
  data_449(input)

def state_70(+input: Nat) -> C.Machine:
  data_451(input)

def state_71(+input: Nat) -> C.Machine:
  data_453(input)

def state_72(+input: Nat) -> C.Machine:
  data_457(input)

def state_73(+input: Nat) -> C.Machine:
  data_463(input)

def state_74(+input: Nat) -> C.Machine:
  data_469(input)

def state_75(+input: Nat) -> C.Machine:
  data_471(input)

def state_76(+input: Nat) -> C.Machine:
  data_473(input)

def state_77(+input: Nat) -> C.Machine:
  data_475(input)

def state_78(+input: Nat) -> C.Machine:
  data_478(input)

def state_79(+input: Nat) -> C.Machine:
  data_480(input)

def state_80(+input: Nat) -> C.Machine:
  data_485(input)

def state_81(+input: Nat) -> C.Machine:
  data_488(input)

def state_82(+input: Nat) -> C.Machine:
  data_491(input)

def state_83(+input: Nat) -> C.Machine:
  data_493(input)

def state_84(+input: Nat) -> C.Machine:
  data_497(input)

def state_85(+input: Nat) -> C.Machine:
  data_502(input)

def state_86(+input: Nat) -> C.Machine:
  data_506(input)

def state_87(+input: Nat) -> C.Machine:
  data_514(input)

def state_88(+input: Nat) -> C.Machine:
  data_516(input)

def state_89(+input: Nat) -> C.Machine:
  data_525(input)

def state_90(+input: Nat) -> C.Machine:
  data_527(input)

def state_91(+input: Nat) -> C.Machine:
  data_529(input)

def state_92(+input: Nat) -> C.Machine:
  data_531(input)

def state_93(+input: Nat) -> C.Machine:
  data_533(input)

def state_94(+input: Nat) -> C.Machine:
  data_536(input)

def state_95(+input: Nat) -> C.Machine:
  data_538(input)

def finalWorld(+input: Nat) -> R.World:
  data_534(input)

def slot_13(+input: Nat) -> R.World:
  data_541(input)

def notify_13(+input: Nat) -> R.World:
  data_205(input)

def slot_33(+input: Nat) -> R.World:
  data_544(input)

def notify_33(+input: Nat) -> R.World:
  data_295(input)

def modified_55(+input: Nat) -> R.World:
  data_547(input)

def queued_55(+input: Nat) -> R.World:
  data_548(input)

def value_55(+input: Nat) -> R.World:
  data_395(input)

def setter_queued(+input: Nat) -> R.World:
  data_549()

def setter_slot(+input: Nat) -> R.World:
  data_552(input)

def setter_inserted(+input: Nat) -> R.World:
  data_553(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_124(input)

def setter_stamped(+input: Nat) -> R.World:
  data_555(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_559(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_553(input)

