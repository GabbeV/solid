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

def data_39() -> R.NodeExtension:
  R.NodeExtension{data_36(), 0n, data_1(), data_2(), 0n, 0n, data_37(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_38(), data_2(), 0n, data_1()}

def data_40() -> List<&2, R.NodeExtension>:
  [data_39()]

def data_41() -> List<&2, R.CleanupAction>:
  []

def data_42() -> R.CleanupProgram:
  R.CleanupProgram{data_41(), False{}, 0n}

def data_43() -> List<&2, R.CleanupProgram>:
  [data_42()]

def data_44() -> List<&2, R.Report>:
  []

def data_45() -> R.OptionalIds:
  R.NoIds{}

def data_46() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_45()}

def data_47() -> List<&2, R.Transaction>:
  [data_46()]

def data_48() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_49() -> R.AsyncSettlement:
  R.Unresolved{}

def data_50() -> R.AsyncObject:
  R.AsyncObject{False{}, data_49(), data_25(), 0n}

def data_51() -> List<&2, R.AsyncObject>:
  [data_50()]

def data_52() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_53() -> List<&2, R.AsyncObserver>:
  [data_52()]

def data_54() -> R.HostJob:
  R.FlushJob{}

def data_55() -> List<&2, R.HostJob>:
  [data_54()]

def data_56() -> List<&2, R.NextInput>:
  []

def data_57() -> R.FromState:
  R.FromNone{}

def data_58() -> R.StreamPlan:
  R.StreamPlan{data_56(), False{}, data_2(), 0n, 0n, data_2(), data_57()}

def data_59() -> List<&2, R.StreamPlan>:
  [data_58()]

def data_60() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_61() -> List<&2, R.ExternalIterator>:
  [data_60()]

def data_62() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_63() -> List<&2, R.StreamState>:
  [data_62()]

def data_64() -> List<&2, R.IteratorEvent>:
  []

def data_65() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_49(), False{}, 0n, False{}, False{}, 0n}

def data_66() -> List<&2, R.Awaiter>:
  [data_65()]

def data_67() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_68() -> List<&2, R.AbortInput>:
  [data_67()]

def data_69() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_70() -> List<&2, R.ContextKey>:
  [data_69()]

def data_71() -> List<&2, R.ContextEntry>:
  []

def data_72() -> R.ContextRecord:
  R.ContextRecord{data_71()}

def data_73() -> List<&2, R.ContextRecord>:
  [data_72()]

def data_74() -> List<&2, R.Expr>:
  [data_4()]

def data_75() -> List<&2, R.ReactionState>:
  []

def data_76() -> List<&2, R.ComparatorBinding>:
  []

def data_77() -> List<&2, R.ActionState>:
  []

def data_78() -> List<&2, R.ActionWait>:
  []

def data_79() -> List<&2, R.ArrayData>:
  []

def data_80() -> List<&2, R.RepeatState>:
  []

def data_81() -> List<&2, R.MapState>:
  []

def data_82() -> List<&2, R.Guess>:
  []

def data_83() -> R.LaneMount:
  R.MountUnset{}

def data_84() -> R.LaneState:
  R.LaneState{data_25(), data_48(), data_25(), data_82(), 0n, data_83(), data_25()}

def data_85() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_86() -> R.Value:
  R.Null{}

def data_87() -> R.DeferredCell:
  R.DeferredCell{0n, data_86(), False{}, False{}}

def data_88() -> R.DeferredBinding:
  R.DeferredBinding{data_87(), 0n}

def data_89() -> List<&2, R.DeferredBinding>:
  [data_88()]

def data_90() -> List<&2, R.DeferredWait>:
  []

def data_91() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_92() -> List<&2, R.DeferredIterator>:
  [data_91()]

def data_93() -> R.DeferredArena:
  R.DeferredArena{data_89(), data_25(), data_90(), data_92()}

def data_94(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_55(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_95(+input: Nat) -> R.Value:
  R.Number{input}

def data_96(+input: Nat) -> R.Slot:
  R.Present{data_95(input)}

def data_97() -> R.Stamp:
  R.Stamped{3n}

def data_98(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_96(input), False{}, 0, 0, 0, 0n, data_97(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_99(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_100(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_99(first)]

def data_101() -> List<&2, Nat>:
  [3n]

def data_102() -> List<&2, Nat>:
  [2n]

def data_103() -> List<&2, R.HostJob>:
  [data_54(), data_54()]

def data_104(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_100(first, input), data_23(), data_101(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_105() -> C.Task:
  C.Round{}

def data_106() -> List<&2, C.Task>:
  [data_105()]

def data_107() -> List<&2, R.Value>:
  []

def data_108(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_104(initial, first, input), data_106(), data_107()}

def data_109(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_100(first, input), data_23(), data_101(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_110() -> C.Task:
  C.RoundAfterSweep{}

def data_111() -> C.Task:
  C.FlushFinally{}

def data_112() -> C.Task:
  C.RoundEnd{}

def data_113() -> List<&2, C.Task>:
  [data_110(), data_111(), data_112()]

def data_114(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, first, input), data_113(), data_107()}

def data_115() -> C.Task:
  C.HeapLoop{}

def data_116() -> List<&2, C.Task>:
  [data_115(), data_111(), data_112()]

def data_117(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, first, input), data_116(), data_107()}

def data_118() -> C.Task:
  C.Recompute{3n, False{}}

def data_119() -> List<&2, C.Task>:
  [data_118(), data_115(), data_111(), data_112()]

def data_120(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_109(initial, first, input), data_119(), data_107()}

def data_121(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_19(first)]

def data_122() -> R.LaneMount:
  R.MountFalse{}

def data_123() -> R.LaneState:
  R.LaneState{data_25(), data_48(), data_25(), data_82(), 0n, data_122(), data_25()}

def data_124(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_121(first, input), data_23(), data_24(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_123(), data_85(), data_2(), data_25(), data_93()}

def data_125() -> C.LanePass:
  C.LanePass{0n, data_83(), data_122()}

def data_126() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_125()}

def data_127() -> List<&2, C.Task>:
  [data_126(), data_115(), data_111(), data_112()]

def data_128(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_124(initial, first, input), data_127(), data_107()}

def data_129() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_125()}

def data_130() -> List<&2, C.Task>:
  [data_129(), data_115(), data_111(), data_112()]

def data_131(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_124(initial, first, input), data_130(), data_107()}

def data_132(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_133(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_132(first)]

def data_134(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_135(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_133(first, input), data_23(), data_24(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_134(initial, first), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_123(), data_85(), data_2(), data_25(), data_93()}

def data_136(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_137() -> R.Flight:
  R.FlightUndefined{}

def data_138(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, data_137(), data_107(), 0n, False{}, data_125()}

def data_139(+first: Nat) -> C.Task:
  C.Finish{data_138(first)}

def data_140(+first: Nat) -> List<&2, C.Task>:
  [data_136(first), data_139(first), data_115(), data_111(), data_112()]

def data_141(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, first, input), data_140(first), data_107()}

def data_142(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_143(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_144() -> C.Task:
  C.Binary{0}

def data_145(+first: Nat) -> List<&2, C.Task>:
  [data_142(first), data_143(first), data_144(), data_139(first), data_115(), data_111(), data_112()]

def data_146(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, first, input), data_145(first), data_107()}

def data_147() -> C.Task:
  C.ReadNode{2n}

def data_148(+first: Nat) -> List<&2, C.Task>:
  [data_147(), data_143(first), data_144(), data_139(first), data_115(), data_111(), data_112()]

def data_149(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, first, input), data_148(first), data_107()}

def data_150() -> C.Task:
  C.ReadPrepared{2n}

def data_151(+first: Nat) -> List<&2, C.Task>:
  [data_150(), data_143(first), data_144(), data_139(first), data_115(), data_111(), data_112()]

def data_152(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_135(initial, first, input), data_151(first), data_107()}

def data_153(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_154(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_153(first)]

def data_155() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_156() -> List<&2, R.Link>:
  [data_21(), data_155()]

def data_157(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_95(input)}

def data_158(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_157(input)]

def data_159(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_154(first, input), data_156(), data_24(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_123(), data_85(), data_2(), data_25(), data_93()}

def data_160(+first: Nat) -> List<&2, C.Task>:
  [data_143(first), data_144(), data_139(first), data_115(), data_111(), data_112()]

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_95(input)]

def data_162(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(initial, first, input), data_160(first), data_161(input)}

def data_163(+first: Nat) -> List<&2, C.Task>:
  [data_144(), data_139(first), data_115(), data_111(), data_112()]

def data_164(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_95(input)]

def data_165(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(initial, first, input), data_163(first), data_164(input)}

def data_166(+first: Nat) -> List<&2, C.Task>:
  [data_139(first), data_115(), data_111(), data_112()]

def data_167(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_168(+input: Nat) -> List<&2, R.Value>:
  [data_167(input)]

def data_169(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_159(initial, first, input), data_166(first), data_168(input)}

def data_170(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_171(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_170(first)]

def data_172(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_171(first, input), data_156(), data_24(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_173(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_138(first), 0n, data_167(input), False{}, False{}, False{}, data_35()}

def data_174(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_173(first, input), data_115(), data_111(), data_112()]

def data_175(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_172(initial, first, input), data_174(first, input), data_107()}

def data_176(+input: Nat) -> R.Slot:
  R.Present{data_167(input)}

def data_177(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_176(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_178(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_177(first, input)]

def data_179(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_178(first, input), data_156(), data_24(), 0n, 0n, False{}, data_102(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_180() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_181() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_182() -> List<&2, C.Task>:
  [data_180(), data_181(), data_115(), data_111(), data_112()]

def data_183(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(initial, first, input), data_182(), data_107()}

def data_184() -> List<&2, C.Task>:
  [data_181(), data_115(), data_111(), data_112()]

def data_185(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(initial, first, input), data_184(), data_107()}

def data_186() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_187() -> List<&2, C.Task>:
  [data_186(), data_115(), data_111(), data_112()]

def data_188(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_179(initial, first, input), data_187(), data_107()}

def data_189(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_176(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_190(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_98(first, input), data_189(first, input)]

def data_191() -> List<&2, Nat>:
  [2n, 3n]

def data_192(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_190(first, input), data_156(), data_24(), 0n, 0n, False{}, data_191(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_193(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_192(initial, first, input), data_116(), data_107()}

def data_194(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_190(first, input), data_156(), data_24(), 1n, 0n, False{}, data_191(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_195(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_116(), data_107()}

def data_196() -> C.Task:
  C.Seam{}

def data_197() -> List<&2, C.Task>:
  [data_196(), data_111(), data_112()]

def data_198(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_197(), data_107()}

def data_199() -> C.Task:
  C.Settle{}

def data_200() -> C.Task:
  C.AfterSettle{}

def data_201() -> List<&2, C.Task>:
  [data_199(), data_200(), data_111(), data_112()]

def data_202(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_201(), data_107()}

def data_203() -> C.Task:
  C.CommitIntake{0n}

def data_204() -> C.Task:
  C.TrimIntake{0n}

def data_205() -> C.Task:
  C.FinishSettleIntake{0n}

def data_206() -> List<&2, C.Task>:
  [data_203(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_207(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_206(), data_107()}

def data_208() -> C.Task:
  C.CommitPending{2n}

def data_209() -> C.Task:
  C.CommitIntake{1n}

def data_210() -> List<&2, C.Task>:
  [data_208(), data_209(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_211(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_194(initial, first, input), data_210(), data_107()}

def data_212(+input: Nat) -> R.Node:
  R.Node{data_9(), data_95(input), data_2(), False{}, 0, 0, 0, 0n, data_97(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_213(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_212(input), data_189(first, input)]

def data_214(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_213(first, input), data_156(), data_24(), 1n, 0n, False{}, data_191(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_215() -> List<&2, C.Task>:
  [data_209(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_216(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_214(initial, first, input), data_215(), data_107()}

def data_217() -> C.Task:
  C.CommitPending{3n}

def data_218() -> C.Task:
  C.CommitIntake{2n}

def data_219() -> List<&2, C.Task>:
  [data_217(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_220(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_214(initial, first, input), data_219(), data_107()}

def data_221(+input: Nat) -> R.Node:
  R.Node{data_13(), data_167(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_222(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_212(input), data_221(input)]

def data_223(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_222(input), data_156(), data_24(), 1n, 0n, False{}, data_191(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_224() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_225() -> List<&2, C.Task>:
  [data_224(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_226(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(initial, first, input), data_225(), data_107()}

def data_227() -> O.Task:
  O.TrimDeps{3n}

def data_228() -> List<&2, O.Task>:
  [data_227()]

def data_229() -> C.Task:
  C.OwnerTasks{data_228()}

def data_230() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_231() -> List<&2, C.Task>:
  [data_229(), data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_232(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(initial, first, input), data_231(), data_107()}

def data_233() -> List<&2, O.Task>:
  []

def data_234() -> C.Task:
  C.OwnerTasks{data_233()}

def data_235() -> List<&2, C.Task>:
  [data_234(), data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_236(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(initial, first, input), data_235(), data_107()}

def data_237() -> List<&2, C.Task>:
  [data_230(), data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_238(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(initial, first, input), data_237(), data_107()}

def data_239() -> List<&2, C.Task>:
  [data_218(), data_204(), data_205(), data_200(), data_111(), data_112()]

def data_240(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_223(initial, first, input), data_239(), data_107()}

def data_241(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_222(input), data_156(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_242() -> List<&2, C.Task>:
  [data_204(), data_205(), data_200(), data_111(), data_112()]

def data_243(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_242(), data_107()}

def data_244() -> List<&2, C.Task>:
  [data_205(), data_200(), data_111(), data_112()]

def data_245(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_244(), data_107()}

def data_246() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_247() -> C.Task:
  C.LandTransactions{data_246(), 0n}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_200(), data_111(), data_112()]

def data_249(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_248(), data_107()}

def data_250() -> C.Task:
  C.CompleteSettle{data_246()}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_200(), data_111(), data_112()]

def data_252(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_251(), data_107()}

def data_253() -> C.Task:
  C.ZombieLoop{data_25()}

def data_254() -> List<&2, C.Task>:
  [data_253(), data_200(), data_111(), data_112()]

def data_255(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_254(), data_107()}

def data_256() -> List<&2, C.Task>:
  [data_200(), data_111(), data_112()]

def data_257(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_241(initial, first, input), data_256(), data_107()}

def data_258(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_222(input), data_156(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_259() -> C.Task:
  C.RenderQueue{}

def data_260() -> List<&2, C.Task>:
  [data_259(), data_111(), data_112()]

def data_261(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(initial, first, input), data_260(), data_107()}

def data_262() -> C.Task:
  C.UserQueue{}

def data_263() -> List<&2, C.Task>:
  [data_262(), data_111(), data_112()]

def data_264(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(initial, first, input), data_263(), data_107()}

def data_265() -> List<&2, C.Task>:
  [data_111(), data_112()]

def data_266(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_258(initial, first, input), data_265(), data_107()}

def data_267(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_222(input), data_156(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_158(initial, first, input), data_35(), False{}, data_25(), data_40(), data_43(), data_25(), 0n, False{}, False{}, data_44(), 0n, data_47(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_38(), data_48(), data_51(), data_53(), data_103(), 0n, data_59(), data_61(), data_63(), data_64(), data_66(), False{}, False{}, data_38(), data_68(), data_70(), data_73(), 0n, data_48(), False{}, data_74(), data_75(), data_76(), 0n, data_77(), data_78(), data_79(), data_80(), data_81(), 0n, data_84(), data_85(), data_2(), data_25(), data_93()}

def data_268() -> List<&2, C.Task>:
  [data_112()]

def data_269(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_267(initial, first, input), data_268(), data_107()}

def data_270() -> List<&2, C.Task>:
  []

def data_271(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_267(initial, first, input), data_270(), data_107()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_94(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_108(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_114(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_117(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_120(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_128(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_131(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_141(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_146(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_149(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_152(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_162(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_165(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_169(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_175(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_183(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_185(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_188(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_193(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_195(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_198(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_202(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_207(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_211(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_216(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_220(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_226(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_232(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_236(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_238(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_240(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_243(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_245(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_249(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_252(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_255(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_257(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_261(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_264(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_266(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_269(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_271(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_267(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
