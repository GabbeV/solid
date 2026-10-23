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

def data_74() -> R.StreamPlan:
  R.StreamPlan{data_73(), False{}, data_2(), 0n, 0n, data_2()}

def data_75() -> List<&2, R.StreamPlan>:
  [data_74()]

def data_76() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_77() -> List<&2, R.ExternalIterator>:
  [data_76()]

def data_78() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_79() -> List<&2, R.StreamState>:
  [data_78()]

def data_80() -> List<&2, R.IteratorEvent>:
  []

def data_81() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_67(), False{}, 0n, False{}, False{}, 0n}

def data_82() -> List<&2, R.Awaiter>:
  [data_81()]

def data_83() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_84() -> List<&2, R.AbortInput>:
  [data_83()]

def data_85() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_86() -> List<&2, R.ContextKey>:
  [data_85()]

def data_87() -> List<&2, R.ContextEntry>:
  []

def data_88() -> R.ContextRecord:
  R.ContextRecord{data_87()}

def data_89() -> List<&2, R.ContextRecord>:
  [data_88()]

def data_90() -> List<&2, R.Expr>:
  [data_4()]

def data_91() -> List<&2, R.ReactionState>:
  []

def data_92() -> List<&2, R.ComparatorBinding>:
  []

def data_93() -> List<&2, R.ActionState>:
  []

def data_94() -> List<&2, R.ActionWait>:
  []

def data_95() -> List<&2, R.ArrayData>:
  []

def data_96() -> List<&2, R.RepeatState>:
  []

def data_97() -> List<&2, R.MapState>:
  []

def data_98() -> List<&2, R.Guess>:
  []

def data_99() -> R.LaneMount:
  R.MountUnset{}

def data_100() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_98(), 0n, data_99()}

def data_101() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_102() -> R.Value:
  R.Null{}

def data_103() -> R.DeferredCell:
  R.DeferredCell{0n, data_102(), False{}, False{}}

def data_104() -> R.DeferredBinding:
  R.DeferredBinding{data_103(), 0n}

def data_105() -> List<&2, R.DeferredBinding>:
  [data_104()]

def data_106() -> List<&2, R.DeferredWait>:
  []

def data_107() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_108() -> List<&2, R.DeferredIterator>:
  [data_107()]

def data_109() -> R.DeferredArena:
  R.DeferredArena{data_105(), data_35(), data_106(), data_108()}

def data_110() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_111(+input: Nat) -> R.Value:
  R.Number{input}

def data_112(+input: Nat) -> R.Slot:
  R.Present{data_111(input)}

def data_113() -> R.Stamp:
  R.Stamped{7n}

def data_114(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_112(input), False{}, 0, 0, 0, 0n, data_113(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_115() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_116() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_117() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_118(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_115(), data_116(), data_117()]

def data_119() -> List<&2, Nat>:
  [3n, 0n, 5n]

def data_120() -> R.HostJob:
  R.FlushJob{}

def data_121() -> List<&2, R.HostJob>:
  [data_120()]

def data_122(+input: Nat) -> R.World:
  R.World{data_118(input), data_33(), data_119(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_123() -> C.Task:
  C.Round{}

def data_124() -> List<&2, C.Task>:
  [data_123()]

def data_125() -> List<&2, R.Value>:
  []

def data_126(+input: Nat) -> C.Machine:
  C.Machine{data_122(input), data_124(), data_125()}

def data_127(+input: Nat) -> R.World:
  R.World{data_118(input), data_33(), data_119(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_128() -> C.Task:
  C.RoundAfterSweep{}

def data_129() -> C.Task:
  C.FlushFinally{}

def data_130() -> C.Task:
  C.RoundEnd{}

def data_131() -> List<&2, C.Task>:
  [data_128(), data_129(), data_130()]

def data_132(+input: Nat) -> C.Machine:
  C.Machine{data_127(input), data_131(), data_125()}

def data_133(+input: Nat) -> R.World:
  R.World{data_118(input), data_33(), data_119(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 7n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_134() -> C.Task:
  C.HeapLoop{}

def data_135() -> List<&2, C.Task>:
  [data_134(), data_129(), data_130()]

def data_136(+input: Nat) -> C.Machine:
  C.Machine{data_133(input), data_135(), data_125()}

def data_137() -> C.Task:
  C.Recompute{3n, False{}}

def data_138() -> List<&2, C.Task>:
  [data_137(), data_134(), data_129(), data_130()]

def data_139(+input: Nat) -> C.Machine:
  C.Machine{data_133(input), data_138(), data_125()}

def data_140() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 1n, 1n, 1n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_141(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_140(), data_116(), data_117()]

def data_142() -> List<&2, Nat>:
  [0n, 0n, 5n]

def data_143() -> R.LaneMount:
  R.MountFalse{}

def data_144() -> R.LaneState:
  R.LaneState{data_35(), data_66(), data_35(), data_98(), 0n, data_143()}

def data_145(+input: Nat) -> R.World:
  R.World{data_141(input), data_33(), data_142(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_52(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_146() -> C.LanePass:
  C.LanePass{0n, data_99(), data_143()}

def data_147() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_146()}

def data_148() -> List<&2, C.Task>:
  [data_147(), data_134(), data_129(), data_130()]

def data_149(+input: Nat) -> C.Machine:
  C.Machine{data_145(input), data_148(), data_125()}

def data_150() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_146()}

def data_151() -> List<&2, C.Task>:
  [data_150(), data_134(), data_129(), data_130()]

def data_152(+input: Nat) -> C.Machine:
  C.Machine{data_145(input), data_151(), data_125()}

def data_153() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 1n, 0n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_154(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_153(), data_116(), data_117()]

def data_155() -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42()]

def data_156(+input: Nat) -> R.World:
  R.World{data_154(input), data_33(), data_142(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_155(), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_157() -> C.Task:
  C.Evaluate{data_16(), data_13()}

def data_158() -> R.Flight:
  R.FlightUndefined{}

def data_159() -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_13(), False{}, data_1(), 0n, False{}, data_158(), data_125(), 0n, False{}, data_146()}

def data_160() -> C.Task:
  C.Finish{data_159()}

def data_161() -> List<&2, C.Task>:
  [data_157(), data_160(), data_134(), data_129(), data_130()]

def data_162(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_161(), data_125()}

def data_163() -> C.Task:
  C.Evaluate{data_14(), data_13()}

def data_164() -> C.Task:
  C.Evaluate{data_15(), data_13()}

def data_165() -> C.Task:
  C.Binary{0}

def data_166() -> List<&2, C.Task>:
  [data_163(), data_164(), data_165(), data_160(), data_134(), data_129(), data_130()]

def data_167(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_166(), data_125()}

def data_168() -> C.Task:
  C.ReadNode{2n}

def data_169() -> List<&2, C.Task>:
  [data_168(), data_164(), data_165(), data_160(), data_134(), data_129(), data_130()]

def data_170(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_169(), data_125()}

def data_171() -> C.Task:
  C.ReadPrepared{2n}

def data_172() -> List<&2, C.Task>:
  [data_171(), data_164(), data_165(), data_160(), data_134(), data_129(), data_130()]

def data_173(+input: Nat) -> C.Machine:
  C.Machine{data_156(input), data_172(), data_125()}

def data_174() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_175(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_174(), data_116(), data_117()]

def data_176() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 4n, 2n}

def data_177() -> List<&2, R.Link>:
  [data_28(), data_176(), data_30(), data_31(), data_32()]

def data_178(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_111(input)}

def data_179(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input)]

def data_180(+input: Nat) -> R.World:
  R.World{data_175(input), data_177(), data_142(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 3n, True{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_181() -> List<&2, C.Task>:
  [data_164(), data_165(), data_160(), data_134(), data_129(), data_130()]

def data_182(+input: Nat) -> List<&2, R.Value>:
  [data_111(input)]

def data_183(+input: Nat) -> C.Machine:
  C.Machine{data_180(input), data_181(), data_182(input)}

def data_184() -> List<&2, C.Task>:
  [data_165(), data_160(), data_134(), data_129(), data_130()]

def data_185(+input: Nat) -> List<&2, R.Value>:
  [data_13(), data_111(input)]

def data_186(+input: Nat) -> C.Machine:
  C.Machine{data_180(input), data_184(), data_185(input)}

def data_187() -> List<&2, C.Task>:
  [data_160(), data_134(), data_129(), data_130()]

def data_188(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_189(+input: Nat) -> List<&2, R.Value>:
  [data_188(input)]

def data_190(+input: Nat) -> C.Machine:
  C.Machine{data_180(input), data_187(), data_189(input)}

def data_191() -> R.Node:
  R.Node{data_12(), data_13(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_192(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_191(), data_116(), data_117()]

def data_193(+input: Nat) -> R.World:
  R.World{data_192(input), data_177(), data_142(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_194(+input: Nat) -> C.Task:
  C.PassReleases{data_159(), 0n, data_188(input), False{}, False{}, False{}, data_53()}

def data_195(+input: Nat) -> List<&2, C.Task>:
  [data_194(input), data_134(), data_129(), data_130()]

def data_196(+input: Nat) -> C.Machine:
  C.Machine{data_193(input), data_195(input), data_125()}

def data_197(+input: Nat) -> R.Slot:
  R.Present{data_188(input)}

def data_198() -> R.Stamp:
  R.Stamped{8n}

def data_199(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_197(input), False{}, 0, 16384, 0, 0n, data_198(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_200() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 10, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_201(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_199(input), data_200(), data_117()]

def data_202() -> List<&2, Nat>:
  [0n, 4n, 5n]

def data_203(+input: Nat) -> R.World:
  R.World{data_201(input), data_177(), data_202(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_204() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_205() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_206() -> List<&2, C.Task>:
  [data_204(), data_205(), data_134(), data_129(), data_130()]

def data_207(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_206(), data_125()}

def data_208() -> List<&2, C.Task>:
  [data_205(), data_134(), data_129(), data_130()]

def data_209(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_208(), data_125()}

def data_210() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_211() -> List<&2, C.Task>:
  [data_210(), data_134(), data_129(), data_130()]

def data_212(+input: Nat) -> C.Machine:
  C.Machine{data_203(input), data_211(), data_125()}

def data_213(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_197(input), False{}, 128, 16384, 0, 0n, data_198(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_214(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_200(), data_117()]

def data_215() -> List<&2, Nat>:
  [2n, 3n]

def data_216(+input: Nat) -> R.World:
  R.World{data_214(input), data_177(), data_202(), 0n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_217(+input: Nat) -> C.Machine:
  C.Machine{data_216(input), data_135(), data_125()}

def data_218(+input: Nat) -> R.World:
  R.World{data_214(input), data_177(), data_202(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_219(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_135(), data_125()}

def data_220() -> C.Task:
  C.Recompute{4n, False{}}

def data_221() -> List<&2, C.Task>:
  [data_220(), data_134(), data_129(), data_130()]

def data_222(+input: Nat) -> C.Machine:
  C.Machine{data_218(input), data_221(), data_125()}

def data_223() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 2n, 2n, 1n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_224(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_223(), data_117()]

def data_225(+input: Nat) -> R.World:
  R.World{data_224(input), data_177(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_226() -> C.Task:
  C.RecomputeAfterTeardown{4n, 0n, data_146()}

def data_227() -> List<&2, C.Task>:
  [data_226(), data_134(), data_129(), data_130()]

def data_228(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_227(), data_125()}

def data_229() -> C.Task:
  C.RecomputePrepared{4n, False{}, 0n, data_146()}

def data_230() -> List<&2, C.Task>:
  [data_229(), data_134(), data_129(), data_130()]

def data_231(+input: Nat) -> C.Machine:
  C.Machine{data_225(input), data_230(), data_125()}

def data_232() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 0n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_233(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_232(), data_117()]

def data_234(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45()]

def data_235(+input: Nat) -> R.World:
  R.World{data_233(input), data_177(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_234(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_236() -> C.Task:
  C.Evaluate{data_21(), data_18()}

def data_237() -> C.PassFrame:
  C.PassFrame{4n, False{}, 0n, False{}, 1n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_158(), data_125(), 0n, False{}, data_146()}

def data_238() -> C.Task:
  C.Finish{data_237()}

def data_239() -> List<&2, C.Task>:
  [data_236(), data_238(), data_134(), data_129(), data_130()]

def data_240(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_239(), data_125()}

def data_241() -> C.Task:
  C.Evaluate{data_19(), data_18()}

def data_242() -> C.Task:
  C.Evaluate{data_20(), data_18()}

def data_243() -> C.Task:
  C.Binary{1}

def data_244() -> List<&2, C.Task>:
  [data_241(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_245(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_244(), data_125()}

def data_246() -> C.Task:
  C.ReadNode{3n}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_248(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_247(), data_125()}

def data_249() -> C.Task:
  C.ReadPrepared{3n}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_251(+input: Nat) -> C.Machine:
  C.Machine{data_235(input), data_250(), data_125()}

def data_252() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_253(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_252(), data_117()]

def data_254() -> R.Link:
  R.Link{3n, 4n, 0n, 0n, 0n, 2n}

def data_255() -> List<&2, R.Link>:
  [data_28(), data_176(), data_254(), data_31(), data_32()]

def data_256(+input: Nat) -> R.World:
  R.World{data_253(input), data_255(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_234(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_257() -> C.Task:
  C.RaiseHeight{3n, 4n}

def data_258() -> C.Task:
  C.ReadStatus{3n}

def data_259() -> List<&2, C.Task>:
  [data_257(), data_258(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_260(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_259(), data_125()}

def data_261() -> List<&2, C.Task>:
  [data_258(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_262(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_261(), data_125()}

def data_263() -> C.Task:
  C.Serve{3n}

def data_264() -> C.Task:
  C.AfterServe{3n}

def data_265() -> List<&2, C.Task>:
  [data_263(), data_264(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_266(+input: Nat) -> C.Machine:
  C.Machine{data_256(input), data_265(), data_125()}

def data_267() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_268(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_267(), data_117()]

def data_269(+input: Nat) -> R.TraceEvent:
  R.ReadValue{4n, 3n, data_188(input)}

def data_270(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45(), data_269(input)]

def data_271(+input: Nat) -> R.World:
  R.World{data_268(input), data_255(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 4n, True{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_272() -> List<&2, C.Task>:
  [data_264(), data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_273(+input: Nat) -> C.Machine:
  C.Machine{data_271(input), data_272(), data_189(input)}

def data_274() -> List<&2, C.Task>:
  [data_242(), data_243(), data_238(), data_134(), data_129(), data_130()]

def data_275(+input: Nat) -> C.Machine:
  C.Machine{data_271(input), data_274(), data_189(input)}

def data_276() -> List<&2, C.Task>:
  [data_243(), data_238(), data_134(), data_129(), data_130()]

def data_277(+input: Nat) -> List<&2, R.Value>:
  [data_18(), data_188(input)]

def data_278(+input: Nat) -> C.Machine:
  C.Machine{data_271(input), data_276(), data_277(input)}

def data_279() -> List<&2, C.Task>:
  [data_238(), data_134(), data_129(), data_130()]

def data_280(+input: Nat) -> R.Value:
  R.Number{Nat.mul(Nat.add(input, 1n), 2n)}

def data_281(+input: Nat) -> List<&2, R.Value>:
  [data_280(input)]

def data_282(+input: Nat) -> C.Machine:
  C.Machine{data_271(input), data_279(), data_281(input)}

def data_283() -> R.Node:
  R.Node{data_12(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_284(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_283(), data_117()]

def data_285(+input: Nat) -> R.World:
  R.World{data_284(input), data_255(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_286(+input: Nat) -> C.Task:
  C.PassReleases{data_237(), 0n, data_280(input), False{}, False{}, False{}, data_53()}

def data_287(+input: Nat) -> List<&2, C.Task>:
  [data_286(input), data_134(), data_129(), data_130()]

def data_288(+input: Nat) -> C.Machine:
  C.Machine{data_285(input), data_287(input), data_125()}

def data_289(+input: Nat) -> R.Slot:
  R.Present{data_280(input)}

def data_290() -> R.Stamp:
  R.Stamped{9n}

def data_291(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_289(input), False{}, 0, 16384, 0, 0n, data_290(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_292(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_291(input), data_117()]

def data_293(+input: Nat) -> R.World:
  R.World{data_292(input), data_255(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_294() -> C.Task:
  C.PublishSettleSelf{4n, False{}}

def data_295() -> C.Task:
  C.FinishPublication{4n, False{}, False{}, False{}, 0n, 0n}

def data_296() -> List<&2, C.Task>:
  [data_294(), data_295(), data_134(), data_129(), data_130()]

def data_297(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_296(), data_125()}

def data_298() -> List<&2, C.Task>:
  [data_295(), data_134(), data_129(), data_130()]

def data_299(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_298(), data_125()}

def data_300() -> C.Task:
  C.QueuePublication{4n, False{}, False{}, 0n, 0n}

def data_301() -> List<&2, C.Task>:
  [data_300(), data_134(), data_129(), data_130()]

def data_302(+input: Nat) -> C.Machine:
  C.Machine{data_293(input), data_301(), data_125()}

def data_303(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_289(input), False{}, 128, 16384, 0, 0n, data_290(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_304(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_117()]

def data_305() -> List<&2, Nat>:
  [2n, 3n, 4n]

def data_306(+input: Nat) -> R.World:
  R.World{data_304(input), data_255(), data_142(), 1n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_307(+input: Nat) -> C.Machine:
  C.Machine{data_306(input), data_135(), data_125()}

def data_308(+input: Nat) -> R.World:
  R.World{data_304(input), data_255(), data_142(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_309(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_135(), data_125()}

def data_310() -> C.Task:
  C.Recompute{5n, False{}}

def data_311() -> List<&2, C.Task>:
  [data_310(), data_134(), data_129(), data_130()]

def data_312(+input: Nat) -> C.Machine:
  C.Machine{data_308(input), data_311(), data_125()}

def data_313() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 2, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_314(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_313()]

def data_315() -> List<&2, Nat>:
  [0n, 0n, 0n]

def data_316(+input: Nat) -> R.World:
  R.World{data_314(input), data_255(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_317() -> C.Task:
  C.RecomputeAfterTeardown{5n, 0n, data_146()}

def data_318() -> List<&2, C.Task>:
  [data_317(), data_134(), data_129(), data_130()]

def data_319(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_318(), data_125()}

def data_320() -> C.Task:
  C.RecomputePrepared{5n, False{}, 0n, data_146()}

def data_321() -> List<&2, C.Task>:
  [data_320(), data_134(), data_129(), data_130()]

def data_322(+input: Nat) -> C.Machine:
  C.Machine{data_316(input), data_321(), data_125()}

def data_323() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 0n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_324(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_323()]

def data_325(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45(), data_269(input), data_48()]

def data_326(+input: Nat) -> R.World:
  R.World{data_324(input), data_255(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_325(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), True{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_327() -> C.Task:
  C.Evaluate{data_25(), data_18()}

def data_328() -> C.PassFrame:
  C.PassFrame{5n, False{}, 0n, False{}, 2n, False{}, data_18(), False{}, data_1(), 0n, False{}, data_158(), data_125(), 0n, False{}, data_146()}

def data_329() -> C.Task:
  C.Finish{data_328()}

def data_330() -> List<&2, C.Task>:
  [data_327(), data_329(), data_134(), data_129(), data_130()]

def data_331(+input: Nat) -> C.Machine:
  C.Machine{data_326(input), data_330(), data_125()}

def data_332() -> C.Task:
  C.Evaluate{data_24(), data_18()}

def data_333() -> C.Task:
  C.Evaluate{data_14(), data_18()}

def data_334() -> List<&2, C.Task>:
  [data_332(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_335(+input: Nat) -> C.Machine:
  C.Machine{data_326(input), data_334(), data_125()}

def data_336() -> C.Task:
  C.ReadNode{4n}

def data_337() -> List<&2, C.Task>:
  [data_336(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_338(+input: Nat) -> C.Machine:
  C.Machine{data_326(input), data_337(), data_125()}

def data_339() -> C.Task:
  C.ReadPrepared{4n}

def data_340() -> List<&2, C.Task>:
  [data_339(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_341(+input: Nat) -> C.Machine:
  C.Machine{data_326(input), data_340(), data_125()}

def data_342() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 4, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_343(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_342()]

def data_344() -> R.Link:
  R.Link{4n, 5n, 4n, 0n, 0n, 2n}

def data_345() -> List<&2, R.Link>:
  [data_28(), data_176(), data_254(), data_344(), data_32()]

def data_346(+input: Nat) -> R.World:
  R.World{data_343(input), data_345(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_325(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), True{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_347() -> C.Task:
  C.RaiseHeight{4n, 5n}

def data_348() -> C.Task:
  C.ReadStatus{4n}

def data_349() -> List<&2, C.Task>:
  [data_347(), data_348(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_350(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_349(), data_125()}

def data_351() -> List<&2, C.Task>:
  [data_348(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_352(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_351(), data_125()}

def data_353() -> C.Task:
  C.Serve{4n}

def data_354() -> C.Task:
  C.AfterServe{4n}

def data_355() -> List<&2, C.Task>:
  [data_353(), data_354(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_356(+input: Nat) -> C.Machine:
  C.Machine{data_346(input), data_355(), data_125()}

def data_357() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 3n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_358(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_357()]

def data_359(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 4n, data_280(input)}

def data_360(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45(), data_269(input), data_48(), data_359(input)]

def data_361(+input: Nat) -> R.World:
  R.World{data_358(input), data_345(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_360(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), True{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_362() -> List<&2, C.Task>:
  [data_354(), data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_363(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_362(), data_281(input)}

def data_364() -> List<&2, C.Task>:
  [data_333(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_365(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_364(), data_281(input)}

def data_366() -> List<&2, C.Task>:
  [data_168(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_367(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_366(), data_281(input)}

def data_368() -> List<&2, C.Task>:
  [data_171(), data_165(), data_329(), data_134(), data_129(), data_130()]

def data_369(+input: Nat) -> C.Machine:
  C.Machine{data_361(input), data_368(), data_281(input)}

def data_370() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16388, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_371(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_370()]

def data_372() -> R.Link:
  R.Link{2n, 5n, 0n, 1n, 0n, 2n}

def data_373() -> List<&2, R.Link>:
  [data_28(), data_176(), data_254(), data_344(), data_372()]

def data_374(+input: Nat) -> R.TraceEvent:
  R.ReadValue{5n, 2n, data_111(input)}

def data_375(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45(), data_269(input), data_48(), data_359(input), data_374(input)]

def data_376(+input: Nat) -> R.World:
  R.World{data_371(input), data_373(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 5n, True{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), True{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_144(), data_101(), data_2(), data_35(), data_109()}

def data_377() -> List<&2, C.Task>:
  [data_165(), data_329(), data_134(), data_129(), data_130()]

def data_378(+input: Nat) -> List<&2, R.Value>:
  [data_111(input), data_280(input)]

def data_379(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_377(), data_378(input)}

def data_380() -> List<&2, C.Task>:
  [data_329(), data_134(), data_129(), data_130()]

def data_381(+input: Nat) -> R.Value:
  R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}

def data_382(+input: Nat) -> List<&2, R.Value>:
  [data_381(input)]

def data_383(+input: Nat) -> C.Machine:
  C.Machine{data_376(input), data_380(), data_382(input)}

def data_384() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_385(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_384()]

def data_386(+input: Nat) -> R.World:
  R.World{data_385(input), data_373(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_387(+input: Nat) -> C.Task:
  C.PassReleases{data_328(), 0n, data_381(input), False{}, False{}, False{}, data_53()}

def data_388(+input: Nat) -> List<&2, C.Task>:
  [data_387(input), data_134(), data_129(), data_130()]

def data_389(+input: Nat) -> C.Machine:
  C.Machine{data_386(input), data_388(input), data_125()}

def data_390(+input: Nat) -> R.Node:
  R.Node{data_23(), data_381(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_391(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_390(input)]

def data_392() -> List<&2, Nat>:
  [5n]

def data_393(+input: Nat) -> R.World:
  R.World{data_391(input), data_373(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_394() -> C.Task:
  C.PublishSettleSelf{5n, False{}}

def data_395() -> C.Task:
  C.FinishPublication{5n, False{}, False{}, False{}, 0n, 0n}

def data_396() -> List<&2, C.Task>:
  [data_394(), data_395(), data_134(), data_129(), data_130()]

def data_397(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_396(), data_125()}

def data_398() -> List<&2, C.Task>:
  [data_395(), data_134(), data_129(), data_130()]

def data_399(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_398(), data_125()}

def data_400() -> C.Task:
  C.QueuePublication{5n, False{}, False{}, 0n, 0n}

def data_401() -> List<&2, C.Task>:
  [data_400(), data_134(), data_129(), data_130()]

def data_402(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_401(), data_125()}

def data_403(+input: Nat) -> C.Machine:
  C.Machine{data_393(input), data_135(), data_125()}

def data_404(+input: Nat) -> R.World:
  R.World{data_391(input), data_373(), data_315(), 3n, 2n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_405(+input: Nat) -> C.Machine:
  C.Machine{data_404(input), data_135(), data_125()}

def data_406(+input: Nat) -> R.World:
  R.World{data_391(input), data_373(), data_315(), 3n, 0n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_407() -> C.Task:
  C.Seam{}

def data_408() -> List<&2, C.Task>:
  [data_407(), data_129(), data_130()]

def data_409(+input: Nat) -> C.Machine:
  C.Machine{data_406(input), data_408(), data_125()}

def data_410() -> C.Task:
  C.Settle{}

def data_411() -> C.Task:
  C.AfterSettle{}

def data_412() -> List<&2, C.Task>:
  [data_410(), data_411(), data_129(), data_130()]

def data_413(+input: Nat) -> C.Machine:
  C.Machine{data_406(input), data_412(), data_125()}

def data_414() -> C.Task:
  C.CommitIntake{0n}

def data_415() -> C.Task:
  C.TrimIntake{0n}

def data_416() -> C.Task:
  C.FinishSettleIntake{0n}

def data_417() -> List<&2, C.Task>:
  [data_414(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_418(+input: Nat) -> C.Machine:
  C.Machine{data_406(input), data_417(), data_125()}

def data_419() -> C.Task:
  C.CommitPending{2n}

def data_420() -> C.Task:
  C.CommitIntake{1n}

def data_421() -> List<&2, C.Task>:
  [data_419(), data_420(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_422(+input: Nat) -> C.Machine:
  C.Machine{data_406(input), data_421(), data_125()}

def data_423(+input: Nat) -> R.Node:
  R.Node{data_9(), data_111(input), data_2(), False{}, 0, 0, 0, 0n, data_113(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_424(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_423(input), data_213(input), data_303(input), data_390(input)]

def data_425(+input: Nat) -> R.World:
  R.World{data_424(input), data_373(), data_315(), 3n, 0n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_426() -> List<&2, C.Task>:
  [data_420(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_427(+input: Nat) -> C.Machine:
  C.Machine{data_425(input), data_426(), data_125()}

def data_428() -> C.Task:
  C.CommitPending{3n}

def data_429() -> C.Task:
  C.CommitIntake{2n}

def data_430() -> List<&2, C.Task>:
  [data_428(), data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_431(+input: Nat) -> C.Machine:
  C.Machine{data_425(input), data_430(), data_125()}

def data_432(+input: Nat) -> R.Node:
  R.Node{data_12(), data_188(input), data_2(), False{}, 0, 16384, 0, 0n, data_198(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_433(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_423(input), data_432(input), data_303(input), data_390(input)]

def data_434(+input: Nat) -> R.World:
  R.World{data_433(input), data_373(), data_315(), 3n, 0n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_435() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_436() -> List<&2, C.Task>:
  [data_435(), data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_437(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_436(), data_125()}

def data_438() -> O.Task:
  O.TrimDeps{3n}

def data_439() -> List<&2, O.Task>:
  [data_438()]

def data_440() -> C.Task:
  C.OwnerTasks{data_439()}

def data_441() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_442() -> List<&2, C.Task>:
  [data_440(), data_441(), data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_443(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_442(), data_125()}

def data_444() -> List<&2, O.Task>:
  []

def data_445() -> C.Task:
  C.OwnerTasks{data_444()}

def data_446() -> List<&2, C.Task>:
  [data_445(), data_441(), data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_447(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_446(), data_125()}

def data_448() -> List<&2, C.Task>:
  [data_441(), data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_449(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_448(), data_125()}

def data_450() -> List<&2, C.Task>:
  [data_429(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_451(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_450(), data_125()}

def data_452() -> C.Task:
  C.CommitPending{4n}

def data_453() -> C.Task:
  C.CommitIntake{3n}

def data_454() -> List<&2, C.Task>:
  [data_452(), data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_455(+input: Nat) -> C.Machine:
  C.Machine{data_434(input), data_454(), data_125()}

def data_456(+input: Nat) -> R.Node:
  R.Node{data_12(), data_280(input), data_2(), False{}, 0, 16384, 0, 0n, data_290(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_457(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_423(input), data_432(input), data_456(input), data_390(input)]

def data_458(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_459() -> C.Task:
  C.CommitFinish{4n, False{}}

def data_460() -> List<&2, C.Task>:
  [data_459(), data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_461(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_460(), data_125()}

def data_462() -> O.Task:
  O.TrimDeps{4n}

def data_463() -> List<&2, O.Task>:
  [data_462()]

def data_464() -> C.Task:
  C.OwnerTasks{data_463()}

def data_465() -> C.Task:
  C.CommitAfterTrim{4n, False{}}

def data_466() -> List<&2, C.Task>:
  [data_464(), data_465(), data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_467(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_466(), data_125()}

def data_468() -> List<&2, C.Task>:
  [data_445(), data_465(), data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_469(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_468(), data_125()}

def data_470() -> List<&2, C.Task>:
  [data_465(), data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_471(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_470(), data_125()}

def data_472() -> List<&2, C.Task>:
  [data_453(), data_415(), data_416(), data_411(), data_129(), data_130()]

def data_473(+input: Nat) -> C.Machine:
  C.Machine{data_458(input), data_472(), data_125()}

def data_474(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_475() -> List<&2, C.Task>:
  [data_415(), data_416(), data_411(), data_129(), data_130()]

def data_476(+input: Nat) -> C.Machine:
  C.Machine{data_474(input), data_475(), data_125()}

def data_477() -> List<&2, C.Task>:
  [data_416(), data_411(), data_129(), data_130()]

def data_478(+input: Nat) -> C.Machine:
  C.Machine{data_474(input), data_477(), data_125()}

def data_479(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_480() -> C.SeamFrame:
  C.SeamFrame{0n, data_392(), data_36(), data_35(), data_36()}

def data_481() -> C.Task:
  C.LandTransactions{data_480(), 0n}

def data_482() -> List<&2, C.Task>:
  [data_481(), data_411(), data_129(), data_130()]

def data_483(+input: Nat) -> C.Machine:
  C.Machine{data_479(input), data_482(), data_125()}

def data_484() -> C.Task:
  C.CompleteSettle{data_480()}

def data_485() -> List<&2, C.Task>:
  [data_484(), data_411(), data_129(), data_130()]

def data_486(+input: Nat) -> C.Machine:
  C.Machine{data_479(input), data_485(), data_125()}

def data_487() -> C.Task:
  C.ZombieLoop{data_35()}

def data_488() -> List<&2, C.Task>:
  [data_487(), data_411(), data_129(), data_130()]

def data_489(+input: Nat) -> C.Machine:
  C.Machine{data_474(input), data_488(), data_125()}

def data_490() -> List<&2, C.Task>:
  [data_411(), data_129(), data_130()]

def data_491(+input: Nat) -> C.Machine:
  C.Machine{data_474(input), data_490(), data_125()}

def data_492(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_392(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_493() -> C.Task:
  C.RenderQueue{}

def data_494() -> List<&2, C.Task>:
  [data_493(), data_129(), data_130()]

def data_495(+input: Nat) -> C.Machine:
  C.Machine{data_492(input), data_494(), data_125()}

def data_496(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_497() -> C.Task:
  C.RunEffect{5n}

def data_498() -> C.Task:
  C.UserQueue{}

def data_499() -> List<&2, C.Task>:
  [data_497(), data_498(), data_129(), data_130()]

def data_500(+input: Nat) -> C.Machine:
  C.Machine{data_496(input), data_499(), data_125()}

def data_501() -> C.Task:
  C.ApplyEffect{5n}

def data_502() -> C.Task:
  C.EffectFinally{5n, True{}, data_125()}

def data_503() -> List<&2, C.Task>:
  [data_501(), data_502(), data_498(), data_129(), data_130()]

def data_504(+input: Nat) -> C.Machine:
  C.Machine{data_496(input), data_503(), data_125()}

def data_505(+input: Nat) -> R.TreeNode:
  R.TreeNode{1n, data_35(), data_381(input)}

def data_506(+input: Nat) -> List<&2, R.TreeNode>:
  [data_37(), data_39(), data_505(input)]

def data_507(+input: Nat) -> R.TraceEvent:
  R.Applied{5n, data_381(input), data_18()}

def data_508(+input: Nat) -> List<&2, R.TraceEvent>:
  [data_42(), data_43(), data_44(), data_45(), data_46(), data_47(), data_48(), data_49(), data_50(), data_51(), data_42(), data_178(input), data_45(), data_269(input), data_48(), data_359(input), data_374(input), data_507(input)]

def data_509(+input: Nat) -> R.World:
  R.World{data_457(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_506(input), data_508(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_510() -> C.Task:
  C.InstallEffectCleanup{5n}

def data_511() -> List<&2, C.Task>:
  [data_510(), data_502(), data_498(), data_129(), data_130()]

def data_512(+input: Nat) -> C.Machine:
  C.Machine{data_509(input), data_511(), data_125()}

def data_513() -> List<&2, C.Task>:
  [data_502(), data_498(), data_129(), data_130()]

def data_514(+input: Nat) -> C.Machine:
  C.Machine{data_509(input), data_513(), data_125()}

def data_515(+input: Nat) -> R.Node:
  R.Node{data_23(), data_381(input), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_381(input), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_516(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_423(input), data_432(input), data_456(input), data_515(input)]

def data_517(+input: Nat) -> R.World:
  R.World{data_516(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, True{}, False{}, 1n, 10n, data_506(input), data_508(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_518() -> O.Task:
  O.TrimDeps{5n}

def data_519() -> List<&2, O.Task>:
  [data_518()]

def data_520() -> C.Task:
  C.OwnerTasks{data_519()}

def data_521() -> C.Task:
  C.TrimFinallyRestore{data_53(), data_125()}

def data_522() -> List<&2, C.Task>:
  [data_520(), data_521(), data_498(), data_129(), data_130()]

def data_523(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_522(), data_125()}

def data_524() -> List<&2, C.Task>:
  [data_445(), data_521(), data_498(), data_129(), data_130()]

def data_525(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_524(), data_125()}

def data_526() -> List<&2, C.Task>:
  [data_521(), data_498(), data_129(), data_130()]

def data_527(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_526(), data_125()}

def data_528() -> List<&2, C.Task>:
  [data_498(), data_129(), data_130()]

def data_529(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_528(), data_125()}

def data_530() -> List<&2, C.Task>:
  [data_129(), data_130()]

def data_531(+input: Nat) -> C.Machine:
  C.Machine{data_517(input), data_530(), data_125()}

def data_532(+input: Nat) -> R.World:
  R.World{data_516(input), data_373(), data_315(), 3n, 0n, False{}, data_35(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 1n, 10n, data_506(input), data_508(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_533() -> List<&2, C.Task>:
  [data_130()]

def data_534(+input: Nat) -> C.Machine:
  C.Machine{data_532(input), data_533(), data_125()}

def data_535() -> List<&2, C.Task>:
  []

def data_536(+input: Nat) -> C.Machine:
  C.Machine{data_532(input), data_535(), data_125()}

def data_537(+input: Nat) -> R.Node:
  R.Node{data_12(), data_13(), data_197(input), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 2n, 2n, 0n, 0n, 3n, 1n, 0n, 0n, 4n, data_16(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_538(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_537(input), data_116(), data_117()]

def data_539(+input: Nat) -> R.World:
  R.World{data_538(input), data_177(), data_142(), 0n, 2n, False{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 8n, data_41(), data_179(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_540(+input: Nat) -> R.Node:
  R.Node{data_12(), data_18(), data_289(input), False{}, 0, 16384, 0, 0n, data_3(), 2n, 2n, 2n, 3n, 3n, 1n, 0n, 4n, 1n, 0n, 3n, 5n, data_21(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_541(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_540(input), data_117()]

def data_542(+input: Nat) -> R.World:
  R.World{data_541(input), data_255(), data_142(), 1n, 2n, False{}, data_215(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 9n, data_41(), data_270(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_543() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 3n, 4n, 2n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), True{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_544(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_213(input), data_303(input), data_543()]

def data_545(+input: Nat) -> R.World:
  R.World{data_544(input), data_373(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_35(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_546(+input: Nat) -> R.World:
  R.World{data_544(input), data_373(), data_315(), 2n, 2n, False{}, data_305(), data_35(), data_392(), data_36(), 0n, False{}, True{}, True{}, 0n, 10n, data_41(), data_375(input), data_53(), False{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_121(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_547() -> R.World:
  R.World{data_27(), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_548(+input: Nat) -> R.Node:
  R.Node{data_9(), data_10(), data_112(input), False{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 1n, 4n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_549(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_548(input), data_17(), data_22(), data_26()]

def data_550(+input: Nat) -> R.World:
  R.World{data_549(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_551(+input: Nat) -> R.World:
  R.World{data_118(input), data_33(), data_119(), 0n, 2n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_552(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_17(), data_22(), data_26()]

def data_553(+input: Nat) -> R.World:
  R.World{data_552(input), data_33(), data_34(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def data_554() -> R.Node:
  R.Node{data_23(), data_18(), data_2(), False{}, 0, 1, 0, 0n, data_3(), 3n, 4n, 1n, 0n, 0n, 2n, 0n, 5n, 1n, 0n, 4n, 0n, data_25(), False{}, data_18(), 2n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_555(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_114(input), data_115(), data_116(), data_554()]

def data_556() -> List<&2, Nat>:
  [3n]

def data_557(+input: Nat) -> R.World:
  R.World{data_555(input), data_33(), data_556(), 0n, 0n, True{}, data_38(), data_35(), data_35(), data_36(), 0n, False{}, False{}, False{}, 0n, 7n, data_41(), data_52(), data_53(), True{}, data_35(), data_58(), data_61(), data_35(), 0n, False{}, False{}, data_62(), 0n, data_65(), data_35(), 0n, 0n, 0n, 0n, data_35(), data_56(), data_66(), data_69(), data_71(), data_72(), 0n, data_75(), data_77(), data_79(), data_80(), data_82(), False{}, False{}, data_56(), data_84(), data_86(), data_89(), 0n, data_66(), False{}, data_90(), data_91(), data_92(), 0n, data_93(), data_94(), data_95(), data_96(), data_97(), 0n, data_100(), data_101(), data_2(), data_35(), data_109()}

def origin() -> R.World:
  data_110()

def state_0(+input: Nat) -> C.Machine:
  data_126(input)

def state_1(+input: Nat) -> C.Machine:
  data_132(input)

def state_2(+input: Nat) -> C.Machine:
  data_136(input)

def state_3(+input: Nat) -> C.Machine:
  data_139(input)

def state_4(+input: Nat) -> C.Machine:
  data_149(input)

def state_5(+input: Nat) -> C.Machine:
  data_152(input)

def state_6(+input: Nat) -> C.Machine:
  data_162(input)

def state_7(+input: Nat) -> C.Machine:
  data_167(input)

def state_8(+input: Nat) -> C.Machine:
  data_170(input)

def state_9(+input: Nat) -> C.Machine:
  data_173(input)

def state_10(+input: Nat) -> C.Machine:
  data_183(input)

def state_11(+input: Nat) -> C.Machine:
  data_186(input)

def state_12(+input: Nat) -> C.Machine:
  data_190(input)

def state_13(+input: Nat) -> C.Machine:
  data_196(input)

def state_14(+input: Nat) -> C.Machine:
  data_207(input)

def state_15(+input: Nat) -> C.Machine:
  data_209(input)

def state_16(+input: Nat) -> C.Machine:
  data_212(input)

def state_17(+input: Nat) -> C.Machine:
  data_217(input)

def state_18(+input: Nat) -> C.Machine:
  data_219(input)

def state_19(+input: Nat) -> C.Machine:
  data_222(input)

def state_20(+input: Nat) -> C.Machine:
  data_228(input)

def state_21(+input: Nat) -> C.Machine:
  data_231(input)

def state_22(+input: Nat) -> C.Machine:
  data_240(input)

def state_23(+input: Nat) -> C.Machine:
  data_245(input)

def state_24(+input: Nat) -> C.Machine:
  data_248(input)

def state_25(+input: Nat) -> C.Machine:
  data_251(input)

def state_26(+input: Nat) -> C.Machine:
  data_260(input)

def state_27(+input: Nat) -> C.Machine:
  data_262(input)

def state_28(+input: Nat) -> C.Machine:
  data_266(input)

def state_29(+input: Nat) -> C.Machine:
  data_273(input)

def state_30(+input: Nat) -> C.Machine:
  data_275(input)

def state_31(+input: Nat) -> C.Machine:
  data_278(input)

def state_32(+input: Nat) -> C.Machine:
  data_282(input)

def state_33(+input: Nat) -> C.Machine:
  data_288(input)

def state_34(+input: Nat) -> C.Machine:
  data_297(input)

def state_35(+input: Nat) -> C.Machine:
  data_299(input)

def state_36(+input: Nat) -> C.Machine:
  data_302(input)

def state_37(+input: Nat) -> C.Machine:
  data_307(input)

def state_38(+input: Nat) -> C.Machine:
  data_309(input)

def state_39(+input: Nat) -> C.Machine:
  data_312(input)

def state_40(+input: Nat) -> C.Machine:
  data_319(input)

def state_41(+input: Nat) -> C.Machine:
  data_322(input)

def state_42(+input: Nat) -> C.Machine:
  data_331(input)

def state_43(+input: Nat) -> C.Machine:
  data_335(input)

def state_44(+input: Nat) -> C.Machine:
  data_338(input)

def state_45(+input: Nat) -> C.Machine:
  data_341(input)

def state_46(+input: Nat) -> C.Machine:
  data_350(input)

def state_47(+input: Nat) -> C.Machine:
  data_352(input)

def state_48(+input: Nat) -> C.Machine:
  data_356(input)

def state_49(+input: Nat) -> C.Machine:
  data_363(input)

def state_50(+input: Nat) -> C.Machine:
  data_365(input)

def state_51(+input: Nat) -> C.Machine:
  data_367(input)

def state_52(+input: Nat) -> C.Machine:
  data_369(input)

def state_53(+input: Nat) -> C.Machine:
  data_379(input)

def state_54(+input: Nat) -> C.Machine:
  data_383(input)

def state_55(+input: Nat) -> C.Machine:
  data_389(input)

def state_56(+input: Nat) -> C.Machine:
  data_397(input)

def state_57(+input: Nat) -> C.Machine:
  data_399(input)

def state_58(+input: Nat) -> C.Machine:
  data_402(input)

def state_59(+input: Nat) -> C.Machine:
  data_403(input)

def state_60(+input: Nat) -> C.Machine:
  data_405(input)

def state_61(+input: Nat) -> C.Machine:
  data_409(input)

def state_62(+input: Nat) -> C.Machine:
  data_413(input)

def state_63(+input: Nat) -> C.Machine:
  data_418(input)

def state_64(+input: Nat) -> C.Machine:
  data_422(input)

def state_65(+input: Nat) -> C.Machine:
  data_427(input)

def state_66(+input: Nat) -> C.Machine:
  data_431(input)

def state_67(+input: Nat) -> C.Machine:
  data_437(input)

def state_68(+input: Nat) -> C.Machine:
  data_443(input)

def state_69(+input: Nat) -> C.Machine:
  data_447(input)

def state_70(+input: Nat) -> C.Machine:
  data_449(input)

def state_71(+input: Nat) -> C.Machine:
  data_451(input)

def state_72(+input: Nat) -> C.Machine:
  data_455(input)

def state_73(+input: Nat) -> C.Machine:
  data_461(input)

def state_74(+input: Nat) -> C.Machine:
  data_467(input)

def state_75(+input: Nat) -> C.Machine:
  data_469(input)

def state_76(+input: Nat) -> C.Machine:
  data_471(input)

def state_77(+input: Nat) -> C.Machine:
  data_473(input)

def state_78(+input: Nat) -> C.Machine:
  data_476(input)

def state_79(+input: Nat) -> C.Machine:
  data_478(input)

def state_80(+input: Nat) -> C.Machine:
  data_483(input)

def state_81(+input: Nat) -> C.Machine:
  data_486(input)

def state_82(+input: Nat) -> C.Machine:
  data_489(input)

def state_83(+input: Nat) -> C.Machine:
  data_491(input)

def state_84(+input: Nat) -> C.Machine:
  data_495(input)

def state_85(+input: Nat) -> C.Machine:
  data_500(input)

def state_86(+input: Nat) -> C.Machine:
  data_504(input)

def state_87(+input: Nat) -> C.Machine:
  data_512(input)

def state_88(+input: Nat) -> C.Machine:
  data_514(input)

def state_89(+input: Nat) -> C.Machine:
  data_523(input)

def state_90(+input: Nat) -> C.Machine:
  data_525(input)

def state_91(+input: Nat) -> C.Machine:
  data_527(input)

def state_92(+input: Nat) -> C.Machine:
  data_529(input)

def state_93(+input: Nat) -> C.Machine:
  data_531(input)

def state_94(+input: Nat) -> C.Machine:
  data_534(input)

def state_95(+input: Nat) -> C.Machine:
  data_536(input)

def finalWorld(+input: Nat) -> R.World:
  data_532(input)

def slot_13(+input: Nat) -> R.World:
  data_539(input)

def notify_13(+input: Nat) -> R.World:
  data_203(input)

def slot_33(+input: Nat) -> R.World:
  data_542(input)

def notify_33(+input: Nat) -> R.World:
  data_293(input)

def modified_55(+input: Nat) -> R.World:
  data_545(input)

def queued_55(+input: Nat) -> R.World:
  data_546(input)

def value_55(+input: Nat) -> R.World:
  data_393(input)

def setter_queued(+input: Nat) -> R.World:
  data_547()

def setter_slot(+input: Nat) -> R.World:
  data_550(input)

def setter_inserted(+input: Nat) -> R.World:
  data_551(input)

def setter_scheduled(+input: Nat) -> R.World:
  data_122(input)

def setter_stamped(+input: Nat) -> R.World:
  data_553(input)

def setter_enqueued3(+input: Nat) -> R.World:
  data_557(input)

def setter_enqueued5(+input: Nat) -> R.World:
  data_551(input)

