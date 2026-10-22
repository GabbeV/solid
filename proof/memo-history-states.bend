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
  R.StreamPlan{data_47(), False{}, data_2(), 0n}

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

def data_76(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_77(+input: Nat) -> R.Value:
  R.Number{input}

def data_78(+input: Nat) -> R.Slot:
  R.Present{data_77(input)}

def data_79(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_80(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_78(input), False{}, 0, 0, 0, 0n, data_79(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_81(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16392, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_82(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_81(tick, previous)]

def data_83() -> List<&2, Nat>:
  [3n]

def data_84() -> List<&2, Nat>:
  [2n]

def data_85() -> R.HostJob:
  R.FlushJob{}

def data_86(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_82(tick, previous, input), data_23(tick), data_83(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_87() -> C.Task:
  C.Round{}

def data_88() -> List<&2, C.Task>:
  [data_87()]

def data_89() -> List<&2, R.Value>:
  []

def data_90(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_86(tick, previous, input, events, jobs), data_88(), data_89()}

def data_91(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_82(tick, previous, input), data_23(tick), data_83(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_92() -> C.Task:
  C.RoundAfterSweep{}

def data_93() -> C.Task:
  C.FlushFinally{}

def data_94() -> C.Task:
  C.RoundEnd{}

def data_95() -> List<&2, C.Task>:
  [data_92(), data_93(), data_94()]

def data_96(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_91(tick, previous, input, events, jobs), data_95(), data_89()}

def data_97() -> C.Task:
  C.HeapLoop{}

def data_98() -> List<&2, C.Task>:
  [data_97(), data_93(), data_94()]

def data_99(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_91(tick, previous, input, events, jobs), data_98(), data_89()}

def data_100() -> C.Task:
  C.Recompute{3n, False{}}

def data_101() -> List<&2, C.Task>:
  [data_100(), data_97(), data_93(), data_94()]

def data_102(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_91(tick, previous, input, events, jobs), data_101(), data_89()}

def data_103(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_19(tick, previous)]

def data_104(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_103(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), events, data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_105() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n}

def data_106() -> List<&2, C.Task>:
  [data_105(), data_97(), data_93(), data_94()]

def data_107(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_104(tick, previous, input, events, jobs), data_106(), data_89()}

def data_108() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_97(), data_93(), data_94()]

def data_110(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_104(tick, previous, input, events, jobs), data_109(), data_89()}

def data_111(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 4, 0, Nat.add(1n, tick), data_3(), 1n, 0n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_112(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_111(tick, previous)]

def data_113() -> R.TraceEvent:
  R.Invoked{3n}

def data_114(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_112(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, events, [data_113()]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_115(+previous: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(previous)}

def data_116(+previous: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(previous), False{}, data_1(), 0n, False{}, 0n, data_89(), 0n, False{}}

def data_117(+previous: Nat) -> C.Task:
  C.Finish{data_116(previous)}

def data_118(+previous: Nat) -> List<&2, C.Task>:
  [data_115(previous), data_117(previous), data_97(), data_93(), data_94()]

def data_119(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_118(previous), data_89()}

def data_120(+previous: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(previous)}

def data_121(+previous: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(previous)}

def data_122() -> C.Task:
  C.Binary{0}

def data_123(+previous: Nat) -> List<&2, C.Task>:
  [data_120(previous), data_121(previous), data_122(), data_117(previous), data_97(), data_93(), data_94()]

def data_124(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_123(previous), data_89()}

def data_125() -> C.Task:
  C.ReadNode{2n}

def data_126(+previous: Nat) -> List<&2, C.Task>:
  [data_125(), data_121(previous), data_122(), data_117(previous), data_97(), data_93(), data_94()]

def data_127(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_126(previous), data_89()}

def data_128() -> C.Task:
  C.ReadPrepared{2n}

def data_129(+previous: Nat) -> List<&2, C.Task>:
  [data_128(), data_121(previous), data_122(), data_117(previous), data_97(), data_93(), data_94()]

def data_130(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_114(tick, previous, input, events, jobs), data_129(previous), data_89()}

def data_131(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16388, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_132(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_131(tick, previous)]

def data_133(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(3n, tick)}

def data_134(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_133(tick)]

def data_135(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_77(input)}

def data_136(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_132(tick, previous, input), data_134(tick), data_24(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_137(+previous: Nat) -> List<&2, C.Task>:
  [data_121(previous), data_122(), data_117(previous), data_97(), data_93(), data_94()]

def data_138(+input: Nat) -> List<&2, R.Value>:
  [data_77(input)]

def data_139(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_136(tick, previous, input, events, jobs), data_137(previous), data_138(input)}

def data_140(+previous: Nat) -> List<&2, C.Task>:
  [data_122(), data_117(previous), data_97(), data_93(), data_94()]

def data_141(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_77(input)]

def data_142(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_136(tick, previous, input, events, jobs), data_140(previous), data_141(input)}

def data_143(+previous: Nat) -> List<&2, C.Task>:
  [data_117(previous), data_97(), data_93(), data_94()]

def data_144(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_145(+input: Nat) -> List<&2, R.Value>:
  [data_144(input)]

def data_146(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_136(tick, previous, input, events, jobs), data_143(previous), data_145(input)}

def data_147(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_148(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_147(tick, previous)]

def data_149(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_148(tick, previous, input), data_134(tick), data_24(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_150(+previous: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_116(previous), 0n, data_144(input), False{}, False{}, False{}, data_29()}

def data_151(+previous: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_150(previous, input), data_97(), data_93(), data_94()]

def data_152(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_149(tick, previous, input, events, jobs), data_151(previous, input), data_89()}

def data_153(+input: Nat) -> R.Slot:
  R.Present{data_144(input)}

def data_154(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_153(input), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_155(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_154(tick, previous, input)]

def data_156(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_155(tick, previous, input), data_134(tick), data_24(), 0n, 0n, False{}, data_84(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_157() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_158() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}}

def data_159() -> List<&2, C.Task>:
  [data_157(), data_158(), data_97(), data_93(), data_94()]

def data_160(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_156(tick, previous, input, events, jobs), data_159(), data_89()}

def data_161() -> List<&2, C.Task>:
  [data_158(), data_97(), data_93(), data_94()]

def data_162(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_156(tick, previous, input, events, jobs), data_161(), data_89()}

def data_163() -> C.Task:
  C.QueuePublication{3n, False{}, False{}}

def data_164() -> List<&2, C.Task>:
  [data_163(), data_97(), data_93(), data_94()]

def data_165(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_156(tick, previous, input, events, jobs), data_164(), data_89()}

def data_166(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_153(input), False{}, 128, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_167(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_80(tick, previous, input), data_166(tick, previous, input)]

def data_168() -> List<&2, Nat>:
  [2n, 3n]

def data_169(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_167(tick, previous, input), data_134(tick), data_24(), 0n, 0n, False{}, data_168(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_170(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_169(tick, previous, input, events, jobs), data_98(), data_89()}

def data_171(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_167(tick, previous, input), data_134(tick), data_24(), 1n, 0n, False{}, data_168(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_172(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_98(), data_89()}

def data_173() -> C.Task:
  C.Seam{}

def data_174() -> List<&2, C.Task>:
  [data_173(), data_93(), data_94()]

def data_175(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_174(), data_89()}

def data_176() -> C.Task:
  C.Settle{}

def data_177() -> C.Task:
  C.AfterSettle{}

def data_178() -> List<&2, C.Task>:
  [data_176(), data_177(), data_93(), data_94()]

def data_179(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_178(), data_89()}

def data_180() -> C.Task:
  C.CommitIntake{0n}

def data_181() -> C.Task:
  C.TrimIntake{0n}

def data_182() -> C.Task:
  C.FinishSettleIntake{0n}

def data_183() -> List<&2, C.Task>:
  [data_180(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_184(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_183(), data_89()}

def data_185() -> C.Task:
  C.CommitPending{2n}

def data_186() -> C.Task:
  C.CommitIntake{1n}

def data_187() -> List<&2, C.Task>:
  [data_185(), data_186(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_188(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_171(tick, previous, input, events, jobs), data_187(), data_89()}

def data_189(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_77(input), data_2(), False{}, 0, 0, 0, 0n, data_79(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_190(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_189(tick, input), data_166(tick, previous, input)]

def data_191(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_190(tick, previous, input), data_134(tick), data_24(), 1n, 0n, False{}, data_168(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_192() -> List<&2, C.Task>:
  [data_186(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_193(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_191(tick, previous, input, events, jobs), data_192(), data_89()}

def data_194() -> C.Task:
  C.CommitPending{3n}

def data_195() -> C.Task:
  C.CommitIntake{2n}

def data_196() -> List<&2, C.Task>:
  [data_194(), data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_197(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_191(tick, previous, input, events, jobs), data_196(), data_89()}

def data_198(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_144(input), data_2(), False{}, 0, 16384, 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_199(+tick: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_189(tick, input), data_198(tick, input)]

def data_200(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_199(tick, input), data_134(tick), data_24(), 1n, 0n, False{}, data_168(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_201() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_202() -> List<&2, C.Task>:
  [data_201(), data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_203(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_200(tick, input, events, jobs), data_202(), data_89()}

def data_204() -> O.Task:
  O.TrimDeps{3n}

def data_205() -> List<&2, O.Task>:
  [data_204()]

def data_206() -> C.Task:
  C.OwnerTasks{data_205()}

def data_207() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_209(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_200(tick, input, events, jobs), data_208(), data_89()}

def data_210() -> List<&2, O.Task>:
  []

def data_211() -> C.Task:
  C.OwnerTasks{data_210()}

def data_212() -> List<&2, C.Task>:
  [data_211(), data_207(), data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_213(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_200(tick, input, events, jobs), data_212(), data_89()}

def data_214() -> List<&2, C.Task>:
  [data_207(), data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_215(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_200(tick, input, events, jobs), data_214(), data_89()}

def data_216() -> List<&2, C.Task>:
  [data_195(), data_181(), data_182(), data_177(), data_93(), data_94()]

def data_217(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_200(tick, input, events, jobs), data_216(), data_89()}

def data_218(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_199(tick, input), data_134(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_219() -> List<&2, C.Task>:
  [data_181(), data_182(), data_177(), data_93(), data_94()]

def data_220(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_219(), data_89()}

def data_221() -> List<&2, C.Task>:
  [data_182(), data_177(), data_93(), data_94()]

def data_222(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_221(), data_89()}

def data_223() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26()}

def data_224() -> C.Task:
  C.LandTransactions{data_223(), 0n}

def data_225() -> List<&2, C.Task>:
  [data_224(), data_177(), data_93(), data_94()]

def data_226(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_225(), data_89()}

def data_227() -> C.Task:
  C.CompleteSettle{data_223()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_177(), data_93(), data_94()]

def data_229(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_228(), data_89()}

def data_230() -> C.Task:
  C.ZombieLoop{data_25()}

def data_231() -> List<&2, C.Task>:
  [data_230(), data_177(), data_93(), data_94()]

def data_232(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_231(), data_89()}

def data_233() -> List<&2, C.Task>:
  [data_177(), data_93(), data_94()]

def data_234(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_218(tick, input, events, jobs), data_233(), data_89()}

def data_235(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_199(tick, input), data_134(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_236() -> C.Task:
  C.RenderQueue{}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_93(), data_94()]

def data_238(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(tick, input, events, jobs), data_237(), data_89()}

def data_239() -> C.Task:
  C.UserQueue{}

def data_240() -> List<&2, C.Task>:
  [data_239(), data_93(), data_94()]

def data_241(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(tick, input, events, jobs), data_240(), data_89()}

def data_242() -> List<&2, C.Task>:
  [data_93(), data_94()]

def data_243(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(tick, input, events, jobs), data_242(), data_89()}

def data_244(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_199(tick, input), data_134(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_113()]), [data_135(input)]), data_29(), False{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_85()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_245() -> List<&2, C.Task>:
  [data_94()]

def data_246(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_244(tick, input, events, jobs), data_245(), data_89()}

def data_247() -> List<&2, C.Task>:
  []

def data_248(+tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_244(tick, input, events, jobs), data_247(), data_89()}

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_76(tick, previous, events, jobs)

def state_0(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_90(tick, previous, input, events, jobs)

def state_1(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_96(tick, previous, input, events, jobs)

def state_2(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_99(tick, previous, input, events, jobs)

def state_3(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_102(tick, previous, input, events, jobs)

def state_4(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_107(tick, previous, input, events, jobs)

def state_5(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_110(tick, previous, input, events, jobs)

def state_6(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_119(tick, previous, input, events, jobs)

def state_7(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_124(tick, previous, input, events, jobs)

def state_8(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_127(tick, previous, input, events, jobs)

def state_9(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_130(tick, previous, input, events, jobs)

def state_10(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_139(tick, previous, input, events, jobs)

def state_11(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_142(tick, previous, input, events, jobs)

def state_12(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_146(tick, previous, input, events, jobs)

def state_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_152(tick, previous, input, events, jobs)

def state_14(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_160(tick, previous, input, events, jobs)

def state_15(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_162(tick, previous, input, events, jobs)

def state_16(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_165(tick, previous, input, events, jobs)

def state_17(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_170(tick, previous, input, events, jobs)

def state_18(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_172(tick, previous, input, events, jobs)

def state_19(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_175(tick, previous, input, events, jobs)

def state_20(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_179(tick, previous, input, events, jobs)

def state_21(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_184(tick, previous, input, events, jobs)

def state_22(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_188(tick, previous, input, events, jobs)

def state_23(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_193(tick, previous, input, events, jobs)

def state_24(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_197(tick, previous, input, events, jobs)

def state_25(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_203(tick, input, events, jobs)

def state_26(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_209(tick, input, events, jobs)

def state_27(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_213(tick, input, events, jobs)

def state_28(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_215(tick, input, events, jobs)

def state_29(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_217(tick, input, events, jobs)

def state_30(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_220(tick, input, events, jobs)

def state_31(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_222(tick, input, events, jobs)

def state_32(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_226(tick, input, events, jobs)

def state_33(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_229(tick, input, events, jobs)

def state_34(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_232(tick, input, events, jobs)

def state_35(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_234(tick, input, events, jobs)

def state_36(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_238(tick, input, events, jobs)

def state_37(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_241(tick, input, events, jobs)

def state_38(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_243(tick, input, events, jobs)

def state_39(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_246(tick, input, events, jobs)

def state_40(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_248(tick, input, events, jobs)

def finalWorld(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_244(tick, input, events, jobs)

def publication_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.publishValue(C.world(state_13(tick, previous, input, events, jobs)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(tick, previous, input, events, jobs)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
