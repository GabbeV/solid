# Canonical data from the actual emitted core.step. The equations in
# memo-staging check it for arbitrary proposals; generation is not trusted.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-repeat-driver.bend as Driver
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
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10(+first: Nat) -> R.Value:
  R.Number{first}

def data_11() -> R.Stamp:
  R.Stamped{2n}

def data_12(+first: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_2(), False{}, 0, 0, 0, 0n, data_11(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_13() -> R.NodeKind:
  R.Memo{}

def data_14(+first: Nat) -> R.Value:
  R.Number{Nat.add(first, 1n)}

def data_15() -> R.Expr:
  R.Read{2n}

def data_16() -> R.Value:
  R.Number{1n}

def data_17() -> R.Expr:
  R.Literal{data_16()}

def data_18() -> R.Expr:
  R.Add{data_15(), data_17()}

def data_19(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_20(+first: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_12(first), data_19(first)]

def data_21() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_22() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 2n}

def data_23() -> List<&2, R.Link>:
  [data_21(), data_22()]

def data_24() -> List<&2, Nat>:
  [0n]

def data_25() -> List<&2, Nat>:
  []

def data_26() -> List<&2, R.QueueEntry>:
  []

def data_27() -> R.TreeNode:
  R.TreeNode{0n, data_25(), data_1()}

def data_28() -> List<&2, R.TreeNode>:
  [data_27(), data_27()]

def data_29() -> R.TraceEvent:
  R.Invoked{3n}

def data_30(+initial: Nat) -> R.Value:
  R.Number{initial}

def data_31(+initial: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_30(initial)}

def data_32() -> R.TraceEvent:
  R.AccessorBound{3n}

def data_33(+first: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_10(first)}

def data_34(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first)]

def data_35() -> R.Fault:
  R.Healthy{}

def data_36() -> R.Flight:
  R.FlightEmpty{}

def data_37() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_38() -> R.Question:
  R.QuestionZero{}

def data_39() -> R.Value:
  R.Null{}

def data_40() -> R.Flight:
  R.FlightUndefined{}

def data_41() -> R.NodeExtension:
  R.NodeExtension{data_36(), 0n, data_1(), data_2(), 0n, 0n, data_37(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_38(), data_2(), 0n, data_39(), data_40()}

def data_42() -> List<&2, R.NodeExtension>:
  [data_41()]

def data_43() -> List<&2, R.CleanupAction>:
  []

def data_44() -> R.CleanupProgram:
  R.CleanupProgram{data_43(), False{}, 0n}

def data_45() -> List<&2, R.CleanupProgram>:
  [data_44()]

def data_46() -> List<&2, R.Report>:
  []

def data_47() -> R.OptionalIds:
  R.NoIds{}

def data_48() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_47()}

def data_49() -> List<&2, R.Transaction>:
  [data_48()]

def data_50() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_51() -> R.AsyncSettlement:
  R.Unresolved{}

def data_52() -> R.AsyncObject:
  R.AsyncObject{False{}, data_51(), data_25(), 0n}

def data_53() -> List<&2, R.AsyncObject>:
  [data_52()]

def data_54() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_55() -> List<&2, R.AsyncObserver>:
  [data_54()]

def data_56() -> R.HostJob:
  R.FlushJob{}

def data_57() -> List<&2, R.HostJob>:
  [data_56()]

def data_58() -> List<&2, R.NextInput>:
  []

def data_59() -> R.FromState:
  R.FromNone{}

def data_60() -> R.StreamPlan:
  R.StreamPlan{data_58(), False{}, data_2(), 0n, 0n, data_2(), data_59()}

def data_61() -> List<&2, R.StreamPlan>:
  [data_60()]

def data_62() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_63() -> List<&2, R.ExternalIterator>:
  [data_62()]

def data_64() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_65() -> List<&2, R.StreamState>:
  [data_64()]

def data_66() -> List<&2, R.IteratorEvent>:
  []

def data_67() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_51(), False{}, 0n, False{}, False{}, 0n}

def data_68() -> List<&2, R.Awaiter>:
  [data_67()]

def data_69() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_70() -> List<&2, R.AbortInput>:
  [data_69()]

def data_71() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_72() -> List<&2, R.ContextKey>:
  [data_71()]

def data_73() -> List<&2, R.ContextEntry>:
  []

def data_74() -> R.ContextRecord:
  R.ContextRecord{data_73()}

def data_75() -> List<&2, R.ContextRecord>:
  [data_74()]

def data_76() -> List<&2, R.Expr>:
  [data_4()]

def data_77() -> List<&2, R.ReactionState>:
  []

def data_78() -> List<&2, R.ComparatorBinding>:
  []

def data_79() -> List<&2, R.ActionState>:
  []

def data_80() -> List<&2, R.ActionWait>:
  []

def data_81() -> List<&2, R.ArrayData>:
  []

def data_82() -> List<&2, R.RepeatState>:
  []

def data_83() -> List<&2, R.MapState>:
  []

def data_84() -> List<&2, R.Guess>:
  []

def data_85() -> R.LaneMount:
  R.MountUnset{}

def data_86() -> List<&2, R.KeptGuess>:
  []

def data_87() -> R.LaneState:
  R.LaneState{data_25(), data_50(), data_25(), data_84(), 0n, data_85(), data_25(), False{}, False{}, data_86(), data_25(), False{}, data_25()}

def data_88() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_89() -> R.DeferredCell:
  R.DeferredCell{0n, data_39(), False{}, False{}}

def data_90() -> R.DeferredBinding:
  R.DeferredBinding{data_89(), 0n}

def data_91() -> List<&2, R.DeferredBinding>:
  [data_90()]

def data_92() -> List<&2, R.DeferredWait>:
  []

def data_93() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_94() -> List<&2, R.DeferredIterator>:
  [data_93()]

def data_95() -> R.DeferredArena:
  R.DeferredArena{data_91(), data_25(), data_92(), data_94()}

def data_96(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_57(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_97(+input: Nat) -> R.Value:
  R.Number{input}

def data_98(+input: Nat) -> R.Slot:
  R.Present{data_97(input)}

def data_99() -> R.Stamp:
  R.Stamped{3n}

def data_100(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_98(input), False{}, 0, 0, 0, 0n, data_99(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_101(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_102(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_101(first)]

def data_103() -> List<&2, Nat>:
  [3n]

def data_104() -> List<&2, Nat>:
  [2n]

def data_105() -> List<&2, R.HostJob>:
  [data_56(), data_56()]

def data_106(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_102(first, input), data_23(), data_103(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_107() -> C.Task:
  C.Round{}

def data_108() -> List<&2, C.Task>:
  [data_107()]

def data_109() -> List<&2, R.Value>:
  []

def data_110(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_106(initial, first, input), data_108(), data_109()}

def data_111(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_102(first, input), data_23(), data_103(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_112() -> C.Task:
  C.RoundAfterSweep{}

def data_113() -> C.Task:
  C.FlushFinally{}

def data_114() -> C.Task:
  C.RoundEnd{}

def data_115() -> List<&2, C.Task>:
  [data_112(), data_113(), data_114()]

def data_116(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_111(initial, first, input), data_115(), data_109()}

def data_117() -> C.Task:
  C.HeapLoop{}

def data_118() -> List<&2, C.Task>:
  [data_117(), data_113(), data_114()]

def data_119(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_111(initial, first, input), data_118(), data_109()}

def data_120() -> C.Task:
  C.Recompute{3n, False{}}

def data_121() -> List<&2, C.Task>:
  [data_120(), data_117(), data_113(), data_114()]

def data_122(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_111(initial, first, input), data_121(), data_109()}

def data_123(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_19(first)]

def data_124() -> R.LaneMount:
  R.MountFalse{}

def data_125() -> R.LaneState:
  R.LaneState{data_25(), data_50(), data_25(), data_84(), 0n, data_124(), data_25(), False{}, False{}, data_86(), data_25(), False{}, data_25()}

def data_126(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_123(first, input), data_23(), data_24(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_125(), data_88(), data_2(), data_25(), data_95()}

def data_127() -> C.LanePass:
  C.LanePass{0n, data_85(), data_124(), False{}}

def data_128() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_127()}

def data_129() -> List<&2, C.Task>:
  [data_128(), data_117(), data_113(), data_114()]

def data_130(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_126(initial, first, input), data_129(), data_109()}

def data_131() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_127()}

def data_132() -> List<&2, C.Task>:
  [data_131(), data_117(), data_113(), data_114()]

def data_133(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_126(initial, first, input), data_132(), data_109()}

def data_134(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_135(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_134(first)]

def data_136(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_137(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_135(first, input), data_23(), data_24(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_136(initial, first), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_125(), data_88(), data_2(), data_25(), data_95()}

def data_138(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_139() -> R.Value:
  R.Number{0n}

def data_140(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_139(), 0n, False{}, data_40(), data_109(), 0n, False{}, data_127()}

def data_141(+first: Nat) -> C.Task:
  C.Finish{data_140(first)}

def data_142(+first: Nat) -> List<&2, C.Task>:
  [data_138(first), data_141(first), data_117(), data_113(), data_114()]

def data_143(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_137(initial, first, input), data_142(first), data_109()}

def data_144(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_145(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_146() -> C.Task:
  C.Binary{0}

def data_147(+first: Nat) -> List<&2, C.Task>:
  [data_144(first), data_145(first), data_146(), data_141(first), data_117(), data_113(), data_114()]

def data_148(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_137(initial, first, input), data_147(first), data_109()}

def data_149() -> C.Task:
  C.ReadNode{2n}

def data_150(+first: Nat) -> List<&2, C.Task>:
  [data_149(), data_145(first), data_146(), data_141(first), data_117(), data_113(), data_114()]

def data_151(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_137(initial, first, input), data_150(first), data_109()}

def data_152() -> C.Task:
  C.ReadPrepared{2n}

def data_153(+first: Nat) -> List<&2, C.Task>:
  [data_152(), data_145(first), data_146(), data_141(first), data_117(), data_113(), data_114()]

def data_154(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_137(initial, first, input), data_153(first), data_109()}

def data_155(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_156(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_155(first)]

def data_157() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_158() -> List<&2, R.Link>:
  [data_21(), data_157()]

def data_159(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_97(input)}

def data_160(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_159(input)]

def data_161(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_156(first, input), data_158(), data_24(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_125(), data_88(), data_2(), data_25(), data_95()}

def data_162(+first: Nat) -> List<&2, C.Task>:
  [data_145(first), data_146(), data_141(first), data_117(), data_113(), data_114()]

def data_163(+input: Nat) -> List<&2, R.Value>:
  [data_97(input)]

def data_164(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_161(initial, first, input), data_162(first), data_163(input)}

def data_165(+first: Nat) -> List<&2, C.Task>:
  [data_146(), data_141(first), data_117(), data_113(), data_114()]

def data_166(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_97(input)]

def data_167(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_161(initial, first, input), data_165(first), data_166(input)}

def data_168(+first: Nat) -> List<&2, C.Task>:
  [data_141(first), data_117(), data_113(), data_114()]

def data_169(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_170(+input: Nat) -> List<&2, R.Value>:
  [data_169(input)]

def data_171(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_161(initial, first, input), data_168(first), data_170(input)}

def data_172(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_173(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_172(first)]

def data_174(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_173(first, input), data_158(), data_24(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_175(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_140(first), 0n, data_169(input), False{}, False{}, False{}, data_35()}

def data_176(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_175(first, input), data_117(), data_113(), data_114()]

def data_177(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_174(initial, first, input), data_176(first, input), data_109()}

def data_178(+input: Nat) -> R.Slot:
  R.Present{data_169(input)}

def data_179(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_178(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_180(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_179(first, input)]

def data_181(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_180(first, input), data_158(), data_24(), 0n, 0n, False{}, data_104(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_182() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_183() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_184() -> List<&2, C.Task>:
  [data_182(), data_183(), data_117(), data_113(), data_114()]

def data_185(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_181(initial, first, input), data_184(), data_109()}

def data_186() -> List<&2, C.Task>:
  [data_183(), data_117(), data_113(), data_114()]

def data_187(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_181(initial, first, input), data_186(), data_109()}

def data_188() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_189() -> List<&2, C.Task>:
  [data_188(), data_117(), data_113(), data_114()]

def data_190(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_181(initial, first, input), data_189(), data_109()}

def data_191(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_178(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_192(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_100(first, input), data_191(first, input)]

def data_193() -> List<&2, Nat>:
  [2n, 3n]

def data_194(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_192(first, input), data_158(), data_24(), 0n, 0n, False{}, data_193(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_195(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_118(), data_109()}

def data_196(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_192(first, input), data_158(), data_24(), 1n, 0n, False{}, data_193(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_197(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_196(initial, first, input), data_118(), data_109()}

def data_198() -> C.Task:
  C.Seam{}

def data_199() -> List<&2, C.Task>:
  [data_198(), data_113(), data_114()]

def data_200(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_196(initial, first, input), data_199(), data_109()}

def data_201() -> C.Task:
  C.Settle{}

def data_202() -> C.Task:
  C.AfterSettle{}

def data_203() -> List<&2, C.Task>:
  [data_201(), data_202(), data_113(), data_114()]

def data_204(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_196(initial, first, input), data_203(), data_109()}

def data_205() -> C.Task:
  C.CommitIntake{0n}

def data_206() -> C.Task:
  C.TrimIntake{0n}

def data_207() -> C.Task:
  C.FinishSettleIntake{0n}

def data_208() -> List<&2, C.Task>:
  [data_205(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_209(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_196(initial, first, input), data_208(), data_109()}

def data_210() -> C.Task:
  C.CommitPending{2n}

def data_211() -> C.Task:
  C.CommitIntake{1n}

def data_212() -> List<&2, C.Task>:
  [data_210(), data_211(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_213(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_196(initial, first, input), data_212(), data_109()}

def data_214(+input: Nat) -> R.Node:
  R.Node{data_9(), data_97(input), data_2(), False{}, 0, 0, 0, 0n, data_99(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_215(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_214(input), data_191(first, input)]

def data_216(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_215(first, input), data_158(), data_24(), 1n, 0n, False{}, data_193(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_217() -> List<&2, C.Task>:
  [data_211(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_218(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_216(initial, first, input), data_217(), data_109()}

def data_219() -> C.Task:
  C.CommitPending{3n}

def data_220() -> C.Task:
  C.CommitIntake{2n}

def data_221() -> List<&2, C.Task>:
  [data_219(), data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_222(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_216(initial, first, input), data_221(), data_109()}

def data_223(+input: Nat) -> R.Node:
  R.Node{data_13(), data_169(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_224(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_214(input), data_223(input)]

def data_225(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_224(input), data_158(), data_24(), 1n, 0n, False{}, data_193(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_226() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_227() -> List<&2, C.Task>:
  [data_226(), data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_228(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_227(), data_109()}

def data_229() -> O.Task:
  O.TrimDeps{3n}

def data_230() -> List<&2, O.Task>:
  [data_229()]

def data_231() -> C.Task:
  C.OwnerTasks{data_230()}

def data_232() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_233() -> List<&2, C.Task>:
  [data_231(), data_232(), data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_234(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_233(), data_109()}

def data_235() -> List<&2, O.Task>:
  []

def data_236() -> C.Task:
  C.OwnerTasks{data_235()}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_232(), data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_238(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_237(), data_109()}

def data_239() -> List<&2, C.Task>:
  [data_232(), data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_240(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_239(), data_109()}

def data_241() -> List<&2, C.Task>:
  [data_220(), data_206(), data_207(), data_202(), data_113(), data_114()]

def data_242(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_225(initial, first, input), data_241(), data_109()}

def data_243(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_224(input), data_158(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_244() -> List<&2, C.Task>:
  [data_206(), data_207(), data_202(), data_113(), data_114()]

def data_245(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_244(), data_109()}

def data_246() -> List<&2, C.Task>:
  [data_207(), data_202(), data_113(), data_114()]

def data_247(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_246(), data_109()}

def data_248() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_249() -> C.Task:
  C.LandTransactions{data_248(), 0n}

def data_250() -> List<&2, C.Task>:
  [data_249(), data_202(), data_113(), data_114()]

def data_251(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_250(), data_109()}

def data_252() -> C.Task:
  C.CompleteSettle{data_248()}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_202(), data_113(), data_114()]

def data_254(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_253(), data_109()}

def data_255() -> C.Task:
  C.ZombieLoop{data_25()}

def data_256() -> List<&2, C.Task>:
  [data_255(), data_202(), data_113(), data_114()]

def data_257(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_256(), data_109()}

def data_258() -> List<&2, C.Task>:
  [data_202(), data_113(), data_114()]

def data_259(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_243(initial, first, input), data_258(), data_109()}

def data_260(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_224(input), data_158(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_261() -> C.Task:
  C.RenderQueue{}

def data_262() -> List<&2, C.Task>:
  [data_261(), data_113(), data_114()]

def data_263(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_260(initial, first, input), data_262(), data_109()}

def data_264() -> C.Task:
  C.UserQueue{}

def data_265() -> List<&2, C.Task>:
  [data_264(), data_113(), data_114()]

def data_266(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_260(initial, first, input), data_265(), data_109()}

def data_267() -> List<&2, C.Task>:
  [data_113(), data_114()]

def data_268(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_260(initial, first, input), data_267(), data_109()}

def data_269(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_224(input), data_158(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_160(initial, first, input), data_35(), False{}, data_25(), data_42(), data_45(), data_25(), 0n, False{}, False{}, data_46(), 0n, data_49(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_50(), data_53(), data_55(), data_105(), 0n, data_61(), data_63(), data_65(), data_66(), data_68(), False{}, False{}, data_38(), data_70(), data_72(), data_75(), 0n, data_50(), False{}, data_76(), data_77(), data_78(), 0n, data_79(), data_80(), data_81(), data_82(), data_83(), 0n, data_87(), data_88(), data_2(), data_25(), data_95()}

def data_270() -> List<&2, C.Task>:
  [data_114()]

def data_271(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_269(initial, first, input), data_270(), data_109()}

def data_272() -> List<&2, C.Task>:
  []

def data_273(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_269(initial, first, input), data_272(), data_109()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_96(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_110(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_116(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_119(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_122(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_130(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_133(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_143(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_148(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_151(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_154(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_164(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_167(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_171(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_177(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_185(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_187(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_190(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_195(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_197(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_200(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_204(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_209(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_213(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_218(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_222(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_228(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_234(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_238(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_240(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_242(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_245(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_247(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_251(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_254(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_257(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_259(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_263(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_266(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_268(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_271(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_273(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_269(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
