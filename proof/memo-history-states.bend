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

def data_30() -> R.Flight:
  R.FlightEmpty{}

def data_31() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_32() -> R.Question:
  R.QuestionZero{}

def data_33() -> R.NodeExtension:
  R.NodeExtension{data_30(), 0n, data_1(), data_2(), 0n, 0n, data_31(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_32(), data_2(), 0n, data_1()}

def data_34() -> List<&2, R.NodeExtension>:
  [data_33()]

def data_35() -> List<&2, R.CleanupAction>:
  []

def data_36() -> R.CleanupProgram:
  R.CleanupProgram{data_35(), False{}, 0n}

def data_37() -> List<&2, R.CleanupProgram>:
  [data_36()]

def data_38() -> List<&2, R.Report>:
  []

def data_39() -> R.OptionalIds:
  R.NoIds{}

def data_40() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_39()}

def data_41() -> List<&2, R.Transaction>:
  [data_40()]

def data_42() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_43() -> R.AsyncSettlement:
  R.Unresolved{}

def data_44() -> R.AsyncObject:
  R.AsyncObject{False{}, data_43(), data_25(), 0n}

def data_45() -> List<&2, R.AsyncObject>:
  [data_44()]

def data_46() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_47() -> List<&2, R.AsyncObserver>:
  [data_46()]

def data_48() -> List<&2, R.NextInput>:
  []

def data_49() -> R.FromState:
  R.FromNone{}

def data_50() -> R.StreamPlan:
  R.StreamPlan{data_48(), False{}, data_2(), 0n, 0n, data_2(), data_49()}

def data_51() -> List<&2, R.StreamPlan>:
  [data_50()]

def data_52() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_53() -> List<&2, R.ExternalIterator>:
  [data_52()]

def data_54() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_55() -> List<&2, R.StreamState>:
  [data_54()]

def data_56() -> List<&2, R.IteratorEvent>:
  []

def data_57() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_43(), False{}, 0n, False{}, False{}, 0n}

def data_58() -> List<&2, R.Awaiter>:
  [data_57()]

def data_59() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_60() -> List<&2, R.AbortInput>:
  [data_59()]

def data_61() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_62() -> List<&2, R.ContextKey>:
  [data_61()]

def data_63() -> List<&2, R.ContextEntry>:
  []

def data_64() -> R.ContextRecord:
  R.ContextRecord{data_63()}

def data_65() -> List<&2, R.ContextRecord>:
  [data_64()]

def data_66() -> List<&2, R.Expr>:
  [data_4()]

def data_67() -> List<&2, R.ReactionState>:
  []

def data_68() -> List<&2, R.ComparatorBinding>:
  []

def data_69() -> List<&2, R.ActionState>:
  []

def data_70() -> List<&2, R.ActionWait>:
  []

def data_71() -> List<&2, R.ArrayData>:
  []

def data_72() -> List<&2, R.RepeatState>:
  []

def data_73() -> List<&2, R.MapState>:
  []

def data_74() -> List<&2, R.Guess>:
  []

def data_75() -> R.LaneMount:
  R.MountUnset{}

def data_76() -> List<&2, R.KeptGuess>:
  []

def data_77() -> R.LaneState:
  R.LaneState{data_25(), data_42(), data_25(), data_74(), 0n, data_75(), data_25(), False{}, False{}, data_76(), data_25(), False{}}

def data_78() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_79() -> R.Value:
  R.Null{}

def data_80() -> R.DeferredCell:
  R.DeferredCell{0n, data_79(), False{}, False{}}

def data_81() -> R.DeferredBinding:
  R.DeferredBinding{data_80(), 0n}

def data_82() -> List<&2, R.DeferredBinding>:
  [data_81()]

def data_83() -> List<&2, R.DeferredWait>:
  []

def data_84() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_85() -> List<&2, R.DeferredIterator>:
  [data_84()]

def data_86() -> R.DeferredArena:
  R.DeferredArena{data_82(), data_25(), data_83(), data_85()}

def data_87(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_88(+input: Nat) -> R.Value:
  R.Number{input}

def data_89(+input: Nat) -> R.Slot:
  R.Present{data_88(input)}

def data_90(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_91(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_89(input), False{}, 0, 0, 0, 0n, data_90(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_92(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16392, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_93(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_92(tick, previous)]

def data_94() -> List<&2, Nat>:
  [3n]

def data_95() -> List<&2, Nat>:
  [2n]

def data_96() -> R.HostJob:
  R.FlushJob{}

def data_97(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_93(tick, previous, input), data_23(tick), data_94(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_98() -> C.Task:
  C.Round{}

def data_99() -> List<&2, C.Task>:
  [data_98()]

def data_100() -> List<&2, R.Value>:
  []

def data_101(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_97(tick, previous, input, events, jobs), data_99(), data_100()}

def data_102(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_93(tick, previous, input), data_23(tick), data_94(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_103() -> C.Task:
  C.RoundAfterSweep{}

def data_104() -> C.Task:
  C.FlushFinally{}

def data_105() -> C.Task:
  C.RoundEnd{}

def data_106() -> List<&2, C.Task>:
  [data_103(), data_104(), data_105()]

def data_107(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_102(tick, previous, input, events, jobs), data_106(), data_100()}

def data_108() -> C.Task:
  C.HeapLoop{}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_104(), data_105()]

def data_110(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_102(tick, previous, input, events, jobs), data_109(), data_100()}

def data_111() -> C.Task:
  C.Recompute{3n, False{}}

def data_112() -> List<&2, C.Task>:
  [data_111(), data_108(), data_104(), data_105()]

def data_113(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_102(tick, previous, input, events, jobs), data_112(), data_100()}

def data_114(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_19(tick, previous)]

def data_115() -> R.LaneMount:
  R.MountFalse{}

def data_116() -> R.LaneState:
  R.LaneState{data_25(), data_42(), data_25(), data_74(), 0n, data_115(), data_25(), False{}, False{}, data_76(), data_25(), False{}}

def data_117(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_114(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), events, data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_116(), data_78(), data_2(), data_25(), data_86()}

def data_118() -> C.LanePass:
  C.LanePass{0n, data_75(), data_115()}

def data_119() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_118()}

def data_120() -> List<&2, C.Task>:
  [data_119(), data_108(), data_104(), data_105()]

def data_121(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_117(tick, previous, input, events, jobs), data_120(), data_100()}

def data_122() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_118()}

def data_123() -> List<&2, C.Task>:
  [data_122(), data_108(), data_104(), data_105()]

def data_124(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_117(tick, previous, input, events, jobs), data_123(), data_100()}

def data_125(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 4, 0, Nat.add(1n, tick), data_3(), 1n, 0n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_126(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_125(tick, previous)]

def data_127() -> R.TraceEvent:
  R.Invoked{3n}

def data_128(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_126(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, events, [data_127()]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_116(), data_78(), data_2(), data_25(), data_86()}

def data_129(+previous: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(previous)}

def data_130() -> R.Flight:
  R.FlightUndefined{}

def data_131(+previous: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(previous), False{}, data_1(), 0n, False{}, data_130(), data_100(), 0n, False{}, data_118()}

def data_132(+previous: Nat) -> C.Task:
  C.Finish{data_131(previous)}

def data_133(+previous: Nat) -> List<&2, C.Task>:
  [data_129(previous), data_132(previous), data_108(), data_104(), data_105()]

def data_134(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_128(tick, previous, input, events, jobs), data_133(previous), data_100()}

def data_135(+previous: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(previous)}

def data_136(+previous: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(previous)}

def data_137() -> C.Task:
  C.Binary{0}

def data_138(+previous: Nat) -> List<&2, C.Task>:
  [data_135(previous), data_136(previous), data_137(), data_132(previous), data_108(), data_104(), data_105()]

def data_139(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_128(tick, previous, input, events, jobs), data_138(previous), data_100()}

def data_140() -> C.Task:
  C.ReadNode{2n}

def data_141(+previous: Nat) -> List<&2, C.Task>:
  [data_140(), data_136(previous), data_137(), data_132(previous), data_108(), data_104(), data_105()]

def data_142(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_128(tick, previous, input, events, jobs), data_141(previous), data_100()}

def data_143() -> C.Task:
  C.ReadPrepared{2n}

def data_144(+previous: Nat) -> List<&2, C.Task>:
  [data_143(), data_136(previous), data_137(), data_132(previous), data_108(), data_104(), data_105()]

def data_145(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_128(tick, previous, input, events, jobs), data_144(previous), data_100()}

def data_146(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16388, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_147(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_146(tick, previous)]

def data_148(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(3n, tick)}

def data_149(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_148(tick)]

def data_150(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_88(input)}

def data_151(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_147(tick, previous, input), data_149(tick), data_24(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_116(), data_78(), data_2(), data_25(), data_86()}

def data_152(+previous: Nat) -> List<&2, C.Task>:
  [data_136(previous), data_137(), data_132(previous), data_108(), data_104(), data_105()]

def data_153(+input: Nat) -> List<&2, R.Value>:
  [data_88(input)]

def data_154(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_151(tick, previous, input, events, jobs), data_152(previous), data_153(input)}

def data_155(+previous: Nat) -> List<&2, C.Task>:
  [data_137(), data_132(previous), data_108(), data_104(), data_105()]

def data_156(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_88(input)]

def data_157(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_151(tick, previous, input, events, jobs), data_155(previous), data_156(input)}

def data_158(+previous: Nat) -> List<&2, C.Task>:
  [data_132(previous), data_108(), data_104(), data_105()]

def data_159(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_160(+input: Nat) -> List<&2, R.Value>:
  [data_159(input)]

def data_161(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_151(tick, previous, input, events, jobs), data_158(previous), data_160(input)}

def data_162(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_163(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_162(tick, previous)]

def data_164(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_163(tick, previous, input), data_149(tick), data_24(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_165(+previous: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_131(previous), 0n, data_159(input), False{}, False{}, False{}, data_29()}

def data_166(+previous: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_165(previous, input), data_108(), data_104(), data_105()]

def data_167(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_164(tick, previous, input, events, jobs), data_166(previous, input), data_100()}

def data_168(+input: Nat) -> R.Slot:
  R.Present{data_159(input)}

def data_169(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_168(input), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_170(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_169(tick, previous, input)]

def data_171(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_170(tick, previous, input), data_149(tick), data_24(), 0n, 0n, False{}, data_95(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_172() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_173() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_174() -> List<&2, C.Task>:
  [data_172(), data_173(), data_108(), data_104(), data_105()]

def data_175(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_174(), data_100()}

def data_176() -> List<&2, C.Task>:
  [data_173(), data_108(), data_104(), data_105()]

def data_177(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_176(), data_100()}

def data_178() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_179() -> List<&2, C.Task>:
  [data_178(), data_108(), data_104(), data_105()]

def data_180(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_179(), data_100()}

def data_181(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_168(input), False{}, 128, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_182(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_91(tick, previous, input), data_181(tick, previous, input)]

def data_183() -> List<&2, Nat>:
  [2n, 3n]

def data_184(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_182(tick, previous, input), data_149(tick), data_24(), 0n, 0n, False{}, data_183(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_185(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_184(tick, previous, input, events, jobs), data_109(), data_100()}

def data_186(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_182(tick, previous, input), data_149(tick), data_24(), 1n, 0n, False{}, data_183(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_187(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(tick, previous, input, events, jobs), data_109(), data_100()}

def data_188() -> C.Task:
  C.Seam{}

def data_189() -> List<&2, C.Task>:
  [data_188(), data_104(), data_105()]

def data_190(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(tick, previous, input, events, jobs), data_189(), data_100()}

def data_191() -> C.Task:
  C.Settle{}

def data_192() -> C.Task:
  C.AfterSettle{}

def data_193() -> List<&2, C.Task>:
  [data_191(), data_192(), data_104(), data_105()]

def data_194(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(tick, previous, input, events, jobs), data_193(), data_100()}

def data_195() -> C.Task:
  C.CommitIntake{0n}

def data_196() -> C.Task:
  C.TrimIntake{0n}

def data_197() -> C.Task:
  C.FinishSettleIntake{0n}

def data_198() -> List<&2, C.Task>:
  [data_195(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_199(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(tick, previous, input, events, jobs), data_198(), data_100()}

def data_200() -> C.Task:
  C.CommitPending{2n}

def data_201() -> C.Task:
  C.CommitIntake{1n}

def data_202() -> List<&2, C.Task>:
  [data_200(), data_201(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_203(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(tick, previous, input, events, jobs), data_202(), data_100()}

def data_204(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_88(input), data_2(), False{}, 0, 0, 0, 0n, data_90(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_205(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_204(tick, input), data_181(tick, previous, input)]

def data_206(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_205(tick, previous, input), data_149(tick), data_24(), 1n, 0n, False{}, data_183(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_207() -> List<&2, C.Task>:
  [data_201(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_208(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_206(tick, previous, input, events, jobs), data_207(), data_100()}

def data_209() -> C.Task:
  C.CommitPending{3n}

def data_210() -> C.Task:
  C.CommitIntake{2n}

def data_211() -> List<&2, C.Task>:
  [data_209(), data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_212(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_206(tick, previous, input, events, jobs), data_211(), data_100()}

def data_213(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_159(input), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_214(+tick: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_204(tick, input), data_213(tick, input)]

def data_215(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_214(tick, input), data_149(tick), data_24(), 1n, 0n, False{}, data_183(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_216() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_217() -> List<&2, C.Task>:
  [data_216(), data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_218(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_215(tick, input, events, jobs), data_217(), data_100()}

def data_219() -> O.Task:
  O.TrimDeps{3n}

def data_220() -> List<&2, O.Task>:
  [data_219()]

def data_221() -> C.Task:
  C.OwnerTasks{data_220()}

def data_222() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_223() -> List<&2, C.Task>:
  [data_221(), data_222(), data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_224(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_215(tick, input, events, jobs), data_223(), data_100()}

def data_225() -> List<&2, O.Task>:
  []

def data_226() -> C.Task:
  C.OwnerTasks{data_225()}

def data_227() -> List<&2, C.Task>:
  [data_226(), data_222(), data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_228(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_215(tick, input, events, jobs), data_227(), data_100()}

def data_229() -> List<&2, C.Task>:
  [data_222(), data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_230(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_215(tick, input, events, jobs), data_229(), data_100()}

def data_231() -> List<&2, C.Task>:
  [data_210(), data_196(), data_197(), data_192(), data_104(), data_105()]

def data_232(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_215(tick, input, events, jobs), data_231(), data_100()}

def data_233(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_214(tick, input), data_149(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_234() -> List<&2, C.Task>:
  [data_196(), data_197(), data_192(), data_104(), data_105()]

def data_235(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_234(), data_100()}

def data_236() -> List<&2, C.Task>:
  [data_197(), data_192(), data_104(), data_105()]

def data_237(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_236(), data_100()}

def data_238() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_239() -> C.Task:
  C.LandTransactions{data_238(), 0n}

def data_240() -> List<&2, C.Task>:
  [data_239(), data_192(), data_104(), data_105()]

def data_241(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_240(), data_100()}

def data_242() -> C.Task:
  C.CompleteSettle{data_238()}

def data_243() -> List<&2, C.Task>:
  [data_242(), data_192(), data_104(), data_105()]

def data_244(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_243(), data_100()}

def data_245() -> C.Task:
  C.ZombieLoop{data_25()}

def data_246() -> List<&2, C.Task>:
  [data_245(), data_192(), data_104(), data_105()]

def data_247(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_246(), data_100()}

def data_248() -> List<&2, C.Task>:
  [data_192(), data_104(), data_105()]

def data_249(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_233(tick, input, events, jobs), data_248(), data_100()}

def data_250(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_214(tick, input), data_149(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_251() -> C.Task:
  C.RenderQueue{}

def data_252() -> List<&2, C.Task>:
  [data_251(), data_104(), data_105()]

def data_253(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_250(tick, input, events, jobs), data_252(), data_100()}

def data_254() -> C.Task:
  C.UserQueue{}

def data_255() -> List<&2, C.Task>:
  [data_254(), data_104(), data_105()]

def data_256(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_250(tick, input, events, jobs), data_255(), data_100()}

def data_257() -> List<&2, C.Task>:
  [data_104(), data_105()]

def data_258(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_250(tick, input, events, jobs), data_257(), data_100()}

def data_259(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_214(tick, input), data_149(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_127()]), [data_150(input)]), data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_96()]), 0n, data_51(), data_53(), data_55(), data_56(), data_58(), False{}, False{}, data_32(), data_60(), data_62(), data_65(), 0n, data_42(), False{}, data_66(), data_67(), data_68(), 0n, data_69(), data_70(), data_71(), data_72(), data_73(), 0n, data_77(), data_78(), data_2(), data_25(), data_86()}

def data_260() -> List<&2, C.Task>:
  [data_105()]

def data_261(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_259(tick, input, events, jobs), data_260(), data_100()}

def data_262() -> List<&2, C.Task>:
  []

def data_263(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_259(tick, input, events, jobs), data_262(), data_100()}

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_87(tick, previous, events, jobs)

def state_0(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_101(tick, previous, input, events, jobs)

def state_1(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_107(tick, previous, input, events, jobs)

def state_2(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_110(tick, previous, input, events, jobs)

def state_3(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_113(tick, previous, input, events, jobs)

def state_4(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_121(tick, previous, input, events, jobs)

def state_5(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_124(tick, previous, input, events, jobs)

def state_6(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_134(tick, previous, input, events, jobs)

def state_7(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_139(tick, previous, input, events, jobs)

def state_8(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_142(tick, previous, input, events, jobs)

def state_9(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_145(tick, previous, input, events, jobs)

def state_10(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_154(tick, previous, input, events, jobs)

def state_11(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_157(tick, previous, input, events, jobs)

def state_12(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_161(tick, previous, input, events, jobs)

def state_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_167(tick, previous, input, events, jobs)

def state_14(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_175(tick, previous, input, events, jobs)

def state_15(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_177(tick, previous, input, events, jobs)

def state_16(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_180(tick, previous, input, events, jobs)

def state_17(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_185(tick, previous, input, events, jobs)

def state_18(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_187(tick, previous, input, events, jobs)

def state_19(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_190(tick, previous, input, events, jobs)

def state_20(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_194(tick, previous, input, events, jobs)

def state_21(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_199(tick, previous, input, events, jobs)

def state_22(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_203(tick, previous, input, events, jobs)

def state_23(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_208(tick, previous, input, events, jobs)

def state_24(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_212(tick, previous, input, events, jobs)

def state_25(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_218(tick, input, events, jobs)

def state_26(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_224(tick, input, events, jobs)

def state_27(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_228(tick, input, events, jobs)

def state_28(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_230(tick, input, events, jobs)

def state_29(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_232(tick, input, events, jobs)

def state_30(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_235(tick, input, events, jobs)

def state_31(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_237(tick, input, events, jobs)

def state_32(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_241(tick, input, events, jobs)

def state_33(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_244(tick, input, events, jobs)

def state_34(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_247(tick, input, events, jobs)

def state_35(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_249(tick, input, events, jobs)

def state_36(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_253(tick, input, events, jobs)

def state_37(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_256(tick, input, events, jobs)

def state_38(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_258(tick, input, events, jobs)

def state_39(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_261(tick, input, events, jobs)

def state_40(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_263(tick, input, events, jobs)

def finalWorld(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_259(tick, input, events, jobs)

def publication_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.publishValue(C.world(state_13(tick, previous, input, events, jobs)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(tick, previous, input, events, jobs)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
