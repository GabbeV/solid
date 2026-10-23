# Generalized steady-pass data from actual core.step. Untrusted generation;
# equations must pass the original independent kernel before use.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
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

def data_10(+previous: Nat) -> R.Value:
  R.Number{previous}

def data_11(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(2n, tick)}

def data_12(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_2(), False{}, 0, 0, 0, 0n, data_11(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_13() -> R.NodeKind:
  R.Memo{}

def data_14(+previous: Nat) -> R.Value:
  R.Number{Nat.add(previous, 1n)}

def data_15() -> R.Expr:
  R.Read{2n}

def data_16() -> R.Value:
  R.Number{1n}

def data_17() -> R.Expr:
  R.Literal{data_16()}

def data_18() -> R.Expr:
  R.Add{data_15(), data_17()}

def data_19(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16384, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_20(+tick: Nat, +previous: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_12(tick, previous), data_19(tick, previous)]

def data_21() -> R.Link:
  R.Link{0n, 0n, 0n, 0n, 0n, 0n}

def data_22(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(2n, tick)}

def data_23(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_22(tick)]

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

def data_29() -> R.Fault:
  R.Healthy{}

def data_30() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_31() -> R.Question:
  R.QuestionZero{}

def data_32() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_30(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_31(), data_2(), 0n, data_1()}

def data_33() -> List<&2, R.NodeExtension>:
  [data_32()]

def data_34() -> List<&2, R.CleanupAction>:
  []

def data_35() -> R.CleanupProgram:
  R.CleanupProgram{data_34(), False{}, 0n}

def data_36() -> List<&2, R.CleanupProgram>:
  [data_35()]

def data_37() -> List<&2, R.Report>:
  []

def data_38() -> R.OptionalIds:
  R.NoIds{}

def data_39() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_38()}

def data_40() -> List<&2, R.Transaction>:
  [data_39()]

def data_41() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_42() -> R.AsyncSettlement:
  R.Unresolved{}

def data_43() -> R.AsyncObject:
  R.AsyncObject{False{}, data_42(), data_25(), 0n}

def data_44() -> List<&2, R.AsyncObject>:
  [data_43()]

def data_45() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_46() -> List<&2, R.AsyncObserver>:
  [data_45()]

def data_47() -> List<&2, R.NextInput>:
  []

def data_48() -> R.StreamPlan:
  R.StreamPlan{data_47(), False{}, data_2(), 0n, 0n, data_2()}

def data_49() -> List<&2, R.StreamPlan>:
  [data_48()]

def data_50() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_51() -> List<&2, R.ExternalIterator>:
  [data_50()]

def data_52() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_53() -> List<&2, R.StreamState>:
  [data_52()]

def data_54() -> List<&2, R.IteratorEvent>:
  []

def data_55() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_42(), False{}, 0n, False{}, False{}, 0n}

def data_56() -> List<&2, R.Awaiter>:
  [data_55()]

def data_57() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_58() -> List<&2, R.AbortInput>:
  [data_57()]

def data_59() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_60() -> List<&2, R.ContextKey>:
  [data_59()]

def data_61() -> List<&2, R.ContextEntry>:
  []

def data_62() -> R.ContextRecord:
  R.ContextRecord{data_61()}

def data_63() -> List<&2, R.ContextRecord>:
  [data_62()]

def data_64() -> List<&2, R.Expr>:
  [data_4()]

def data_65() -> List<&2, R.ReactionState>:
  []

def data_66() -> List<&2, R.ComparatorBinding>:
  []

def data_67() -> List<&2, R.ActionState>:
  []

def data_68() -> List<&2, R.ActionWait>:
  []

def data_69() -> List<&2, R.ArrayData>:
  []

def data_70() -> List<&2, R.RepeatState>:
  []

def data_71() -> List<&2, R.MapState>:
  []

def data_72() -> List<&2, R.Guess>:
  []

def data_73() -> R.LaneMount:
  R.MountUnset{}

def data_74() -> R.LaneState:
  R.LaneState{data_25(), data_41(), data_25(), data_72(), 0n, data_73()}

def data_75() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_76() -> R.Value:
  R.Null{}

def data_77() -> R.DeferredCell:
  R.DeferredCell{0n, data_76(), False{}, False{}}

def data_78() -> R.DeferredBinding:
  R.DeferredBinding{data_77(), 0n}

def data_79() -> List<&2, R.DeferredBinding>:
  [data_78()]

def data_80() -> List<&2, R.DeferredWait>:
  []

def data_81() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_82() -> List<&2, R.DeferredIterator>:
  [data_81()]

def data_83() -> R.DeferredArena:
  R.DeferredArena{data_79(), data_25(), data_80(), data_82()}

def data_84(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_85(+input: Nat) -> R.Value:
  R.Number{input}

def data_86(+input: Nat) -> R.Slot:
  R.Present{data_85(input)}

def data_87(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_88(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_86(input), False{}, 0, 0, 0, 0n, data_87(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_89(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16392, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_90(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_89(tick, previous)]

def data_91() -> List<&2, Nat>:
  [3n]

def data_92() -> List<&2, Nat>:
  [2n]

def data_93() -> R.HostJob:
  R.FlushJob{}

def data_94(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_90(tick, previous, input), data_23(tick), data_91(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_95() -> C.Task:
  C.Round{}

def data_96() -> List<&2, C.Task>:
  [data_95()]

def data_97() -> List<&2, R.Value>:
  []

def data_98(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_94(tick, previous, input, events, jobs), data_96(), data_97()}

def data_99(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_90(tick, previous, input), data_23(tick), data_91(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_100() -> C.Task:
  C.RoundAfterSweep{}

def data_101() -> C.Task:
  C.FlushFinally{}

def data_102() -> C.Task:
  C.RoundEnd{}

def data_103() -> List<&2, C.Task>:
  [data_100(), data_101(), data_102()]

def data_104(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_99(tick, previous, input, events, jobs), data_103(), data_97()}

def data_105() -> C.Task:
  C.HeapLoop{}

def data_106() -> List<&2, C.Task>:
  [data_105(), data_101(), data_102()]

def data_107(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_99(tick, previous, input, events, jobs), data_106(), data_97()}

def data_108() -> C.Task:
  C.Recompute{3n, False{}}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_105(), data_101(), data_102()]

def data_110(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_99(tick, previous, input, events, jobs), data_109(), data_97()}

def data_111(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_19(tick, previous)]

def data_112() -> R.LaneMount:
  R.MountFalse{}

def data_113() -> R.LaneState:
  R.LaneState{data_25(), data_41(), data_25(), data_72(), 0n, data_112()}

def data_114(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_111(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_113(), data_75(), data_2(), data_25(), data_83()}

def data_115() -> C.LanePass:
  C.LanePass{0n, data_73(), data_112()}

def data_116() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_115()}

def data_117() -> List<&2, C.Task>:
  [data_116(), data_105(), data_101(), data_102()]

def data_118(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_117(), data_97()}

def data_119() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_115()}

def data_120() -> List<&2, C.Task>:
  [data_119(), data_105(), data_101(), data_102()]

def data_121(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_120(), data_97()}

def data_122(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 4, 0, Nat.add(1n, tick), data_3(), 1n, 0n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_123(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_122(tick, previous)]

def data_124() -> R.TraceEvent:
  R.Invoked{3n}

def data_125(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_123(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, events, [data_124()]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_113(), data_75(), data_2(), data_25(), data_83()}

def data_126(+previous: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(previous)}

def data_127(+previous: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(previous), False{}, data_1(), 0n, False{}, 0n, data_97(), 0n, False{}, data_115()}

def data_128(+previous: Nat) -> C.Task:
  C.Finish{data_127(previous)}

def data_129(+previous: Nat) -> List<&2, C.Task>:
  [data_126(previous), data_128(previous), data_105(), data_101(), data_102()]

def data_130(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_125(tick, previous, input, events, jobs), data_129(previous), data_97()}

def data_131(+previous: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(previous)}

def data_132(+previous: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(previous)}

def data_133() -> C.Task:
  C.Binary{0}

def data_134(+previous: Nat) -> List<&2, C.Task>:
  [data_131(previous), data_132(previous), data_133(), data_128(previous), data_105(), data_101(), data_102()]

def data_135(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_125(tick, previous, input, events, jobs), data_134(previous), data_97()}

def data_136() -> C.Task:
  C.ReadNode{2n}

def data_137(+previous: Nat) -> List<&2, C.Task>:
  [data_136(), data_132(previous), data_133(), data_128(previous), data_105(), data_101(), data_102()]

def data_138(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_125(tick, previous, input, events, jobs), data_137(previous), data_97()}

def data_139() -> C.Task:
  C.ReadPrepared{2n}

def data_140(+previous: Nat) -> List<&2, C.Task>:
  [data_139(), data_132(previous), data_133(), data_128(previous), data_105(), data_101(), data_102()]

def data_141(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_125(tick, previous, input, events, jobs), data_140(previous), data_97()}

def data_142(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16388, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_143(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_142(tick, previous)]

def data_144(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(3n, tick)}

def data_145(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_144(tick)]

def data_146(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_85(input)}

def data_147(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_143(tick, previous, input), data_145(tick), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_113(), data_75(), data_2(), data_25(), data_83()}

def data_148(+previous: Nat) -> List<&2, C.Task>:
  [data_132(previous), data_133(), data_128(previous), data_105(), data_101(), data_102()]

def data_149(+input: Nat) -> List<&2, R.Value>:
  [data_85(input)]

def data_150(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_147(tick, previous, input, events, jobs), data_148(previous), data_149(input)}

def data_151(+previous: Nat) -> List<&2, C.Task>:
  [data_133(), data_128(previous), data_105(), data_101(), data_102()]

def data_152(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_85(input)]

def data_153(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_147(tick, previous, input, events, jobs), data_151(previous), data_152(input)}

def data_154(+previous: Nat) -> List<&2, C.Task>:
  [data_128(previous), data_105(), data_101(), data_102()]

def data_155(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_156(+input: Nat) -> List<&2, R.Value>:
  [data_155(input)]

def data_157(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_147(tick, previous, input, events, jobs), data_154(previous), data_156(input)}

def data_158(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_159(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_158(tick, previous)]

def data_160(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_159(tick, previous, input), data_145(tick), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_161(+previous: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_127(previous), 0n, data_155(input), False{}, False{}, False{}, data_29()}

def data_162(+previous: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_161(previous, input), data_105(), data_101(), data_102()]

def data_163(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_160(tick, previous, input, events, jobs), data_162(previous, input), data_97()}

def data_164(+input: Nat) -> R.Slot:
  R.Present{data_155(input)}

def data_165(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_164(input), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_166(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_165(tick, previous, input)]

def data_167(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_166(tick, previous, input), data_145(tick), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_168() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_169() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_170() -> List<&2, C.Task>:
  [data_168(), data_169(), data_105(), data_101(), data_102()]

def data_171(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_167(tick, previous, input, events, jobs), data_170(), data_97()}

def data_172() -> List<&2, C.Task>:
  [data_169(), data_105(), data_101(), data_102()]

def data_173(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_167(tick, previous, input, events, jobs), data_172(), data_97()}

def data_174() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_175() -> List<&2, C.Task>:
  [data_174(), data_105(), data_101(), data_102()]

def data_176(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_167(tick, previous, input, events, jobs), data_175(), data_97()}

def data_177(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_164(input), False{}, 128, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_178(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(tick, previous, input), data_177(tick, previous, input)]

def data_179() -> List<&2, Nat>:
  [2n, 3n]

def data_180(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_178(tick, previous, input), data_145(tick), data_24(), 0n, 0n, False{}, data_179(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_181(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_180(tick, previous, input, events, jobs), data_106(), data_97()}

def data_182(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_178(tick, previous, input), data_145(tick), data_24(), 1n, 0n, False{}, data_179(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_183(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_182(tick, previous, input, events, jobs), data_106(), data_97()}

def data_184() -> C.Task:
  C.Seam{}

def data_185() -> List<&2, C.Task>:
  [data_184(), data_101(), data_102()]

def data_186(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_182(tick, previous, input, events, jobs), data_185(), data_97()}

def data_187() -> C.Task:
  C.Settle{}

def data_188() -> C.Task:
  C.AfterSettle{}

def data_189() -> List<&2, C.Task>:
  [data_187(), data_188(), data_101(), data_102()]

def data_190(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_182(tick, previous, input, events, jobs), data_189(), data_97()}

def data_191() -> C.Task:
  C.CommitIntake{0n}

def data_192() -> C.Task:
  C.TrimIntake{0n}

def data_193() -> C.Task:
  C.FinishSettleIntake{0n}

def data_194() -> List<&2, C.Task>:
  [data_191(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_195(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_182(tick, previous, input, events, jobs), data_194(), data_97()}

def data_196() -> C.Task:
  C.CommitPending{2n}

def data_197() -> C.Task:
  C.CommitIntake{1n}

def data_198() -> List<&2, C.Task>:
  [data_196(), data_197(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_199(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_182(tick, previous, input, events, jobs), data_198(), data_97()}

def data_200(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_85(input), data_2(), False{}, 0, 0, 0, 0n, data_87(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_201(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_200(tick, input), data_177(tick, previous, input)]

def data_202(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_201(tick, previous, input), data_145(tick), data_24(), 1n, 0n, False{}, data_179(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_203() -> List<&2, C.Task>:
  [data_197(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_204(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_202(tick, previous, input, events, jobs), data_203(), data_97()}

def data_205() -> C.Task:
  C.CommitPending{3n}

def data_206() -> C.Task:
  C.CommitIntake{2n}

def data_207() -> List<&2, C.Task>:
  [data_205(), data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_208(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_202(tick, previous, input, events, jobs), data_207(), data_97()}

def data_209(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_155(input), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_210(+tick: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_200(tick, input), data_209(tick, input)]

def data_211(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_210(tick, input), data_145(tick), data_24(), 1n, 0n, False{}, data_179(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_212() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_213() -> List<&2, C.Task>:
  [data_212(), data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_214(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_211(tick, input, events, jobs), data_213(), data_97()}

def data_215() -> O.Task:
  O.TrimDeps{3n}

def data_216() -> List<&2, O.Task>:
  [data_215()]

def data_217() -> C.Task:
  C.OwnerTasks{data_216()}

def data_218() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_219() -> List<&2, C.Task>:
  [data_217(), data_218(), data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_220(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_211(tick, input, events, jobs), data_219(), data_97()}

def data_221() -> List<&2, O.Task>:
  []

def data_222() -> C.Task:
  C.OwnerTasks{data_221()}

def data_223() -> List<&2, C.Task>:
  [data_222(), data_218(), data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_224(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_211(tick, input, events, jobs), data_223(), data_97()}

def data_225() -> List<&2, C.Task>:
  [data_218(), data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_226(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_211(tick, input, events, jobs), data_225(), data_97()}

def data_227() -> List<&2, C.Task>:
  [data_206(), data_192(), data_193(), data_188(), data_101(), data_102()]

def data_228(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_211(tick, input, events, jobs), data_227(), data_97()}

def data_229(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_210(tick, input), data_145(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_230() -> List<&2, C.Task>:
  [data_192(), data_193(), data_188(), data_101(), data_102()]

def data_231(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_230(), data_97()}

def data_232() -> List<&2, C.Task>:
  [data_193(), data_188(), data_101(), data_102()]

def data_233(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_232(), data_97()}

def data_234() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_235() -> C.Task:
  C.LandTransactions{data_234(), 0n}

def data_236() -> List<&2, C.Task>:
  [data_235(), data_188(), data_101(), data_102()]

def data_237(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_236(), data_97()}

def data_238() -> C.Task:
  C.CompleteSettle{data_234()}

def data_239() -> List<&2, C.Task>:
  [data_238(), data_188(), data_101(), data_102()]

def data_240(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_239(), data_97()}

def data_241() -> C.Task:
  C.ZombieLoop{data_25()}

def data_242() -> List<&2, C.Task>:
  [data_241(), data_188(), data_101(), data_102()]

def data_243(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_242(), data_97()}

def data_244() -> List<&2, C.Task>:
  [data_188(), data_101(), data_102()]

def data_245(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_229(tick, input, events, jobs), data_244(), data_97()}

def data_246(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_210(tick, input), data_145(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_247() -> C.Task:
  C.RenderQueue{}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_101(), data_102()]

def data_249(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_246(tick, input, events, jobs), data_248(), data_97()}

def data_250() -> C.Task:
  C.UserQueue{}

def data_251() -> List<&2, C.Task>:
  [data_250(), data_101(), data_102()]

def data_252(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_246(tick, input, events, jobs), data_251(), data_97()}

def data_253() -> List<&2, C.Task>:
  [data_101(), data_102()]

def data_254(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_246(tick, input, events, jobs), data_253(), data_97()}

def data_255(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_210(tick, input), data_145(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_124()]), [data_146(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_93()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2(), data_25(), data_83()}

def data_256() -> List<&2, C.Task>:
  [data_102()]

def data_257(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_255(tick, input, events, jobs), data_256(), data_97()}

def data_258() -> List<&2, C.Task>:
  []

def data_259(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_255(tick, input, events, jobs), data_258(), data_97()}

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_84(tick, previous, events, jobs)

def state_0(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_98(tick, previous, input, events, jobs)

def state_1(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_104(tick, previous, input, events, jobs)

def state_2(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_107(tick, previous, input, events, jobs)

def state_3(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_110(tick, previous, input, events, jobs)

def state_4(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_118(tick, previous, input, events, jobs)

def state_5(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_121(tick, previous, input, events, jobs)

def state_6(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_130(tick, previous, input, events, jobs)

def state_7(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_135(tick, previous, input, events, jobs)

def state_8(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_138(tick, previous, input, events, jobs)

def state_9(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_141(tick, previous, input, events, jobs)

def state_10(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_150(tick, previous, input, events, jobs)

def state_11(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_153(tick, previous, input, events, jobs)

def state_12(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_157(tick, previous, input, events, jobs)

def state_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_163(tick, previous, input, events, jobs)

def state_14(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_171(tick, previous, input, events, jobs)

def state_15(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_173(tick, previous, input, events, jobs)

def state_16(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_176(tick, previous, input, events, jobs)

def state_17(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_181(tick, previous, input, events, jobs)

def state_18(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_183(tick, previous, input, events, jobs)

def state_19(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_186(tick, previous, input, events, jobs)

def state_20(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_190(tick, previous, input, events, jobs)

def state_21(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_195(tick, previous, input, events, jobs)

def state_22(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_199(tick, previous, input, events, jobs)

def state_23(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_204(tick, previous, input, events, jobs)

def state_24(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_208(tick, previous, input, events, jobs)

def state_25(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_214(tick, input, events, jobs)

def state_26(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_220(tick, input, events, jobs)

def state_27(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_224(tick, input, events, jobs)

def state_28(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_226(tick, input, events, jobs)

def state_29(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_228(tick, input, events, jobs)

def state_30(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_231(tick, input, events, jobs)

def state_31(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_233(tick, input, events, jobs)

def state_32(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_237(tick, input, events, jobs)

def state_33(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_240(tick, input, events, jobs)

def state_34(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_243(tick, input, events, jobs)

def state_35(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_245(tick, input, events, jobs)

def state_36(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_249(tick, input, events, jobs)

def state_37(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_252(tick, input, events, jobs)

def state_38(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_254(tick, input, events, jobs)

def state_39(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_257(tick, input, events, jobs)

def state_40(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_259(tick, input, events, jobs)

def finalWorld(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_255(tick, input, events, jobs)

def publication_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.publishValue(C.world(state_13(tick, previous, input, events, jobs)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(tick, previous, input, events, jobs)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
