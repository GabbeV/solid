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
  R.Node{data_0(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_7() -> R.NodeKind:
  R.Root{}

def data_8() -> R.Node:
  R.Node{data_7(), data_1(), data_2(), True{}, 0, 0, 0, 0n, data_3(), 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, 3n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_9() -> R.NodeKind:
  R.Signal{}

def data_10(+previous: Nat) -> R.Value:
  R.Number{previous}

def data_11(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(2n, tick)}

def data_12(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_2(), False{}, 0, 0, 0, 0n, data_11(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

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

def data_19(+prior: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,prior,_=>0,_=>16384), 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_20(+prior: Bool, +tick: Nat, +previous: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_12(tick, previous), data_19(prior, tick, previous)]

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

def data_33() -> R.Value:
  R.Null{}

def data_34() -> R.Flight:
  R.FlightUndefined{}

def data_35() -> R.AskedIn:
  R.Unasked{}

def data_36() -> R.NodeExtension:
  R.NodeExtension{data_30(), 0n, data_1(), data_2(), 0n, 0n, data_31(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_32(), data_2(), 0n, data_33(), data_34(), data_3(), data_35()}

def data_37() -> List<&2, R.NodeExtension>:
  [data_36()]

def data_38() -> List<&2, R.CleanupAction>:
  []

def data_39() -> R.CleanupProgram:
  R.CleanupProgram{data_38(), False{}, 0n}

def data_40() -> List<&2, R.CleanupProgram>:
  [data_39()]

def data_41() -> List<&2, R.Report>:
  []

def data_42() -> R.OptionalIds:
  R.NoIds{}

def data_43() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_42(), False{}, 0n}

def data_44() -> List<&2, R.Transaction>:
  [data_43()]

def data_45() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_46() -> R.AsyncSettlement:
  R.Unresolved{}

def data_47() -> R.AsyncObject:
  R.AsyncObject{False{}, data_46(), data_25(), 0n}

def data_48() -> List<&2, R.AsyncObject>:
  [data_47()]

def data_49() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_50() -> List<&2, R.AsyncObserver>:
  [data_49()]

def data_51() -> List<&2, R.NextInput>:
  []

def data_52() -> R.FromState:
  R.FromNone{}

def data_53() -> R.StreamPlan:
  R.StreamPlan{data_51(), False{}, data_2(), 0n, 0n, data_2(), data_52()}

def data_54() -> List<&2, R.StreamPlan>:
  [data_53()]

def data_55() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_56() -> List<&2, R.ExternalIterator>:
  [data_55()]

def data_57() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_58() -> List<&2, R.StreamState>:
  [data_57()]

def data_59() -> List<&2, R.IteratorEvent>:
  []

def data_60() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_46(), False{}, 0n, False{}, False{}, 0n}

def data_61() -> List<&2, R.Awaiter>:
  [data_60()]

def data_62() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_63() -> List<&2, R.AbortInput>:
  [data_62()]

def data_64() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_65() -> List<&2, R.ContextKey>:
  [data_64()]

def data_66() -> List<&2, R.ContextEntry>:
  []

def data_67() -> R.ContextRecord:
  R.ContextRecord{data_66()}

def data_68() -> List<&2, R.ContextRecord>:
  [data_67()]

def data_69() -> List<&2, R.Expr>:
  [data_4()]

def data_70() -> List<&2, R.ReactionState>:
  []

def data_71() -> List<&2, R.ComparatorBinding>:
  []

def data_72() -> List<&2, R.ActionState>:
  []

def data_73() -> List<&2, R.ActionWait>:
  []

def data_74() -> List<&2, R.ArrayData>:
  []

def data_75() -> List<&2, R.RepeatState>:
  []

def data_76() -> List<&2, R.MapState>:
  []

def data_77() -> List<&2, R.Guess>:
  []

def data_78() -> R.LaneMount:
  R.MountUnset{}

def data_79() -> List<&2, R.KeptGuess>:
  []

def data_80() -> R.LaneState:
  R.LaneState{data_25(), data_45(), data_25(), data_77(), 0n, data_78(), data_25(), False{}, False{}, data_79(), data_25(), False{}, data_25(), data_25()}

def data_81() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_82() -> R.DeferredCell:
  R.DeferredCell{0n, data_33(), False{}, False{}}

def data_83() -> R.DeferredBinding:
  R.DeferredBinding{data_82(), 0n}

def data_84() -> List<&2, R.DeferredBinding>:
  [data_83()]

def data_85() -> List<&2, R.DeferredWait>:
  []

def data_86() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_87() -> List<&2, R.DeferredIterator>:
  [data_86()]

def data_88() -> R.DeferredArena:
  R.DeferredArena{data_84(), data_25(), data_85(), data_87()}

def data_89(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(prior, tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), jobs, 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_90(+input: Nat) -> R.Value:
  R.Number{input}

def data_91(+input: Nat) -> R.Slot:
  R.Present{data_90(input)}

def data_92(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_93(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_91(input), False{}, 0, 0, 0, 0n, data_92(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_94(+prior: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,prior,_=>8,_=>16392), 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_95(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_94(prior, tick, previous)]

def data_96() -> List<&2, Nat>:
  [3n]

def data_97() -> List<&2, Nat>:
  [2n]

def data_98() -> R.HostJob:
  R.FlushJob{}

def data_99(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_95(prior, tick, previous, input), data_23(tick), data_96(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_100() -> C.Task:
  C.Round{}

def data_101() -> List<&2, C.Task>:
  [data_100()]

def data_102() -> List<&2, R.Value>:
  []

def data_103(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_99(prior, tick, previous, input, events, jobs), data_101(), data_102()}

def data_104(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_95(prior, tick, previous, input), data_23(tick), data_96(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_105() -> C.Task:
  C.RoundAfterSweep{}

def data_106() -> C.Task:
  C.FlushFinally{}

def data_107() -> C.Task:
  C.RoundEnd{}

def data_108() -> List<&2, C.Task>:
  [data_105(), data_106(), data_107()]

def data_109(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_104(prior, tick, previous, input, events, jobs), data_108(), data_102()}

def data_110() -> C.Task:
  C.HeapLoop{}

def data_111() -> List<&2, C.Task>:
  [data_110(), data_106(), data_107()]

def data_112(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_104(prior, tick, previous, input, events, jobs), data_111(), data_102()}

def data_113() -> C.Task:
  C.Recompute{3n, False{}}

def data_114() -> List<&2, C.Task>:
  [data_113(), data_110(), data_106(), data_107()]

def data_115(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_104(prior, tick, previous, input, events, jobs), data_114(), data_102()}

def data_116(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_19(prior, tick, previous)]

def data_117() -> R.LaneMount:
  R.MountFalse{}

def data_118() -> R.LaneState:
  R.LaneState{data_25(), data_45(), data_25(), data_77(), 0n, data_117(), data_25(), False{}, False{}, data_79(), data_25(), False{}, data_25(), data_25()}

def data_119(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_116(prior, tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), events, data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_118(), data_81(), data_2(), data_25(), data_88()}

def data_120() -> C.LanePass:
  C.LanePass{0n, data_78(), data_117(), False{}, data_2(), False{}}

def data_121() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_120()}

def data_122() -> List<&2, C.Task>:
  [data_121(), data_110(), data_106(), data_107()]

def data_123(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_119(prior, tick, previous, input, events, jobs), data_122(), data_102()}

def data_124() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_120()}

def data_125() -> List<&2, C.Task>:
  [data_124(), data_110(), data_106(), data_107()]

def data_126(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_119(prior, tick, previous, input, events, jobs), data_125(), data_102()}

def data_127(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 4, 0, Nat.add(1n, tick), data_3(), 1n, 0n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_128(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_127(tick, previous)]

def data_129() -> R.TraceEvent:
  R.Invoked{3n}

def data_130(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_128(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, events, [data_129()]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_118(), data_81(), data_2(), data_25(), data_88()}

def data_131(+previous: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(previous)}

def data_132() -> R.Value:
  R.Number{0n}

def data_133(+previous: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(previous), False{}, data_132(), 0n, False{}, data_34(), data_102(), 0n, False{}, data_120()}

def data_134(+previous: Nat) -> C.Task:
  C.Finish{data_133(previous)}

def data_135(+previous: Nat) -> List<&2, C.Task>:
  [data_131(previous), data_134(previous), data_110(), data_106(), data_107()]

def data_136(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_130(tick, previous, input, events, jobs), data_135(previous), data_102()}

def data_137(+previous: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(previous)}

def data_138(+previous: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(previous)}

def data_139() -> C.Task:
  C.Binary{0}

def data_140(+previous: Nat) -> List<&2, C.Task>:
  [data_137(previous), data_138(previous), data_139(), data_134(previous), data_110(), data_106(), data_107()]

def data_141(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_130(tick, previous, input, events, jobs), data_140(previous), data_102()}

def data_142() -> C.Task:
  C.ReadNode{2n}

def data_143(+previous: Nat) -> List<&2, C.Task>:
  [data_142(), data_138(previous), data_139(), data_134(previous), data_110(), data_106(), data_107()]

def data_144(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_130(tick, previous, input, events, jobs), data_143(previous), data_102()}

def data_145() -> C.Task:
  C.ReadPrepared{2n}

def data_146(+previous: Nat) -> List<&2, C.Task>:
  [data_145(), data_138(previous), data_139(), data_134(previous), data_110(), data_106(), data_107()]

def data_147(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_130(tick, previous, input, events, jobs), data_146(previous), data_102()}

def data_148(+netted: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,netted,_=>4,_=>16388), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_149(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_148(netted, tick, previous)]

def data_150(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(3n, tick)}

def data_151(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_150(tick)]

def data_152(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_90(input)}

def data_153(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_149(netted, tick, previous, input), data_151(tick), data_24(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_118(), data_81(), data_2(), data_25(), data_88()}

def data_154(+previous: Nat) -> List<&2, C.Task>:
  [data_138(previous), data_139(), data_134(previous), data_110(), data_106(), data_107()]

def data_155(+input: Nat) -> List<&2, R.Value>:
  [data_90(input)]

def data_156(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_153(netted, tick, previous, input, events, jobs), data_154(previous), data_155(input)}

def data_157(+previous: Nat) -> List<&2, C.Task>:
  [data_139(), data_134(previous), data_110(), data_106(), data_107()]

def data_158(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_90(input)]

def data_159(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_153(netted, tick, previous, input, events, jobs), data_157(previous), data_158(input)}

def data_160(+previous: Nat) -> List<&2, C.Task>:
  [data_134(previous), data_110(), data_106(), data_107()]

def data_161(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_162(+input: Nat) -> List<&2, R.Value>:
  [data_161(input)]

def data_163(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_153(netted, tick, previous, input, events, jobs), data_160(previous), data_162(input)}

def data_164(+netted: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_165(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_164(netted, tick, previous)]

def data_166(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_165(netted, tick, previous, input), data_151(tick), data_24(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_167(+previous: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_133(previous), 0n, data_161(input), False{}, False{}, False{}, data_29()}

def data_168(+previous: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_167(previous, input), data_110(), data_106(), data_107()]

def data_169(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_166(netted, tick, previous, input, events, jobs), data_168(previous, input), data_102()}

def data_170(+input: Nat) -> R.Slot:
  R.Present{data_161(input)}

def data_171(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_170(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_172(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_171(netted, tick, previous, input)]

def data_173(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_172(netted, tick, previous, input), data_151(tick), data_24(), 0n, 0n, False{}, data_97(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_174() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_175() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_176() -> List<&2, C.Task>:
  [data_174(), data_175(), data_110(), data_106(), data_107()]

def data_177(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_173(netted, tick, previous, input, events, jobs), data_176(), data_102()}

def data_178() -> List<&2, C.Task>:
  [data_175(), data_110(), data_106(), data_107()]

def data_179(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_173(netted, tick, previous, input, events, jobs), data_178(), data_102()}

def data_180() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_181() -> List<&2, C.Task>:
  [data_180(), data_110(), data_106(), data_107()]

def data_182(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_173(netted, tick, previous, input, events, jobs), data_181(), data_102()}

def data_183(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_170(input), False{}, 128, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_184(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_93(tick, previous, input), data_183(netted, tick, previous, input)]

def data_185() -> List<&2, Nat>:
  [2n, 3n]

def data_186(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_184(netted, tick, previous, input), data_151(tick), data_24(), 0n, 0n, False{}, data_185(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_187(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_186(netted, tick, previous, input, events, jobs), data_111(), data_102()}

def data_188(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_184(netted, tick, previous, input), data_151(tick), data_24(), 1n, 0n, False{}, data_185(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_189(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_188(netted, tick, previous, input, events, jobs), data_111(), data_102()}

def data_190() -> C.Task:
  C.Seam{}

def data_191() -> List<&2, C.Task>:
  [data_190(), data_106(), data_107()]

def data_192(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_188(netted, tick, previous, input, events, jobs), data_191(), data_102()}

def data_193() -> C.Task:
  C.Settle{}

def data_194() -> C.Task:
  C.AfterSettle{}

def data_195() -> List<&2, C.Task>:
  [data_193(), data_194(), data_106(), data_107()]

def data_196(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_188(netted, tick, previous, input, events, jobs), data_195(), data_102()}

def data_197() -> C.Task:
  C.CommitIntake{0n}

def data_198() -> C.Task:
  C.TrimIntake{0n}

def data_199() -> C.Task:
  C.FinishSettleIntake{0n}

def data_200() -> List<&2, C.Task>:
  [data_197(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_201(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_188(netted, tick, previous, input, events, jobs), data_200(), data_102()}

def data_202() -> C.Task:
  C.CommitPending{2n}

def data_203() -> C.Task:
  C.CommitIntake{1n}

def data_204() -> List<&2, C.Task>:
  [data_202(), data_203(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_205(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_188(netted, tick, previous, input, events, jobs), data_204(), data_102()}

def data_206(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_90(input), data_2(), False{}, 0, 0, 0, 0n, data_92(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_207(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_206(tick, input), data_183(netted, tick, previous, input)]

def data_208(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_207(netted, tick, previous, input), data_151(tick), data_24(), 1n, 0n, False{}, data_185(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_209() -> List<&2, C.Task>:
  [data_203(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_210(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_208(netted, tick, previous, input, events, jobs), data_209(), data_102()}

def data_211() -> C.Task:
  C.CommitPending{3n}

def data_212() -> C.Task:
  C.CommitIntake{2n}

def data_213() -> List<&2, C.Task>:
  [data_211(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_214(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_208(netted, tick, previous, input, events, jobs), data_213(), data_102()}

def data_215(+netted: Bool, +tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_161(input), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n, False{}}

def data_216(+netted: Bool, +tick: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_206(tick, input), data_215(netted, tick, input)]

def data_217(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_216(netted, tick, input), data_151(tick), data_24(), 1n, 0n, False{}, data_185(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_218() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_219() -> List<&2, C.Task>:
  [data_218(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_220(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_217(netted, tick, input, events, jobs), data_219(), data_102()}

def data_221() -> O.Task:
  O.TrimDeps{3n}

def data_222() -> List<&2, O.Task>:
  [data_221()]

def data_223() -> C.Task:
  C.OwnerTasks{data_222()}

def data_224() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_225() -> List<&2, C.Task>:
  [data_223(), data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_226(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_217(netted, tick, input, events, jobs), data_225(), data_102()}

def data_227() -> List<&2, O.Task>:
  []

def data_228() -> C.Task:
  C.OwnerTasks{data_227()}

def data_229() -> List<&2, C.Task>:
  [data_228(), data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_230(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_217(netted, tick, input, events, jobs), data_229(), data_102()}

def data_231() -> List<&2, C.Task>:
  [data_224(), data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_232(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_217(netted, tick, input, events, jobs), data_231(), data_102()}

def data_233() -> List<&2, C.Task>:
  [data_212(), data_198(), data_199(), data_194(), data_106(), data_107()]

def data_234(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_217(netted, tick, input, events, jobs), data_233(), data_102()}

def data_235(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_216(netted, tick, input), data_151(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_236() -> List<&2, C.Task>:
  [data_198(), data_199(), data_194(), data_106(), data_107()]

def data_237(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_236(), data_102()}

def data_238() -> List<&2, C.Task>:
  [data_199(), data_194(), data_106(), data_107()]

def data_239(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_238(), data_102()}

def data_240() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_241() -> C.Task:
  C.LandTransactions{data_240(), 0n}

def data_242() -> List<&2, C.Task>:
  [data_241(), data_194(), data_106(), data_107()]

def data_243(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_242(), data_102()}

def data_244() -> C.Task:
  C.CompleteSettle{data_240()}

def data_245() -> List<&2, C.Task>:
  [data_244(), data_194(), data_106(), data_107()]

def data_246(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_245(), data_102()}

def data_247() -> C.Task:
  C.ZombieLoop{data_25()}

def data_248() -> List<&2, C.Task>:
  [data_247(), data_194(), data_106(), data_107()]

def data_249(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_248(), data_102()}

def data_250() -> List<&2, C.Task>:
  [data_194(), data_106(), data_107()]

def data_251(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_235(netted, tick, input, events, jobs), data_250(), data_102()}

def data_252(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_216(netted, tick, input), data_151(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_253() -> C.Task:
  C.RenderQueue{}

def data_254() -> List<&2, C.Task>:
  [data_253(), data_106(), data_107()]

def data_255(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_252(netted, tick, input, events, jobs), data_254(), data_102()}

def data_256() -> C.Task:
  C.UserQueue{}

def data_257() -> List<&2, C.Task>:
  [data_256(), data_106(), data_107()]

def data_258(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_252(netted, tick, input, events, jobs), data_257(), data_102()}

def data_259() -> List<&2, C.Task>:
  [data_106(), data_107()]

def data_260(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_252(netted, tick, input, events, jobs), data_259(), data_102()}

def data_261(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_216(netted, tick, input), data_151(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_129()]), [data_152(input)]), data_29(), False{}, data_25(), data_37(), data_40(), data_25(), 0n, False{}, False{}, data_41(), 0n, data_44(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_45(), data_48(), data_50(), B.append(R.HostJob, jobs, [data_98()]), 0n, data_54(), data_56(), data_58(), data_59(), data_61(), False{}, False{}, data_32(), data_63(), data_65(), data_68(), 0n, data_45(), False{}, data_69(), data_70(), data_71(), 0n, data_72(), data_73(), data_74(), data_75(), data_76(), 0n, data_80(), data_81(), data_2(), data_25(), data_88()}

def data_262() -> List<&2, C.Task>:
  [data_107()]

def data_263(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_261(netted, tick, input, events, jobs), data_262(), data_102()}

def data_264() -> List<&2, C.Task>:
  []

def data_265(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_261(netted, tick, input, events, jobs), data_264(), data_102()}

def origin(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_89(prior, tick, previous, events, jobs)

def at_0(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_103(prior, tick, previous, input, events, jobs)

def state_0(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_0(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_1(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_109(prior, tick, previous, input, events, jobs)

def state_1(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_1(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_2(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_112(prior, tick, previous, input, events, jobs)

def state_2(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_2(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_3(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_115(prior, tick, previous, input, events, jobs)

def state_3(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_3(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_4(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_123(prior, tick, previous, input, events, jobs)

def state_4(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_4(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_5(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_126(prior, tick, previous, input, events, jobs)

def state_5(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_5(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_6(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_136(tick, previous, input, events, jobs)

def state_6(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_6(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_7(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_141(tick, previous, input, events, jobs)

def state_7(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_7(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_8(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_144(tick, previous, input, events, jobs)

def state_8(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_8(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_9(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_147(tick, previous, input, events, jobs)

def state_9(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_9(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_10(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_156(netted, tick, previous, input, events, jobs)

def state_10(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_10(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_11(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_159(netted, tick, previous, input, events, jobs)

def state_11(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_11(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_12(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_163(netted, tick, previous, input, events, jobs)

def state_12(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_12(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_13(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_169(netted, tick, previous, input, events, jobs)

def state_13(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_13(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_14(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_177(netted, tick, previous, input, events, jobs)

def state_14(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_14(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_15(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_179(netted, tick, previous, input, events, jobs)

def state_15(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_15(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_16(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_182(netted, tick, previous, input, events, jobs)

def state_16(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_16(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_17(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_187(netted, tick, previous, input, events, jobs)

def state_17(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_17(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_18(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_189(netted, tick, previous, input, events, jobs)

def state_18(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_18(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_19(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_192(netted, tick, previous, input, events, jobs)

def state_19(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_19(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_20(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_196(netted, tick, previous, input, events, jobs)

def state_20(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_20(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_21(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_201(netted, tick, previous, input, events, jobs)

def state_21(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_21(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_22(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_205(netted, tick, previous, input, events, jobs)

def state_22(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_22(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_23(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_210(netted, tick, previous, input, events, jobs)

def state_23(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_23(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_24(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_214(netted, tick, previous, input, events, jobs)

def state_24(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_24(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_25(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_220(netted, tick, input, events, jobs)

def state_25(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_25(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_26(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_226(netted, tick, input, events, jobs)

def state_26(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_26(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_27(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_230(netted, tick, input, events, jobs)

def state_27(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_27(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_28(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_232(netted, tick, input, events, jobs)

def state_28(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_28(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_29(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_234(netted, tick, input, events, jobs)

def state_29(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_29(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_30(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_237(netted, tick, input, events, jobs)

def state_30(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_30(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_31(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_239(netted, tick, input, events, jobs)

def state_31(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_31(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_32(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_243(netted, tick, input, events, jobs)

def state_32(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_32(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_33(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_246(netted, tick, input, events, jobs)

def state_33(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_33(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_34(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_249(netted, tick, input, events, jobs)

def state_34(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_34(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_35(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_251(netted, tick, input, events, jobs)

def state_35(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_35(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_36(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_255(netted, tick, input, events, jobs)

def state_36(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_36(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_37(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_258(netted, tick, input, events, jobs)

def state_37(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_37(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_38(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_260(netted, tick, input, events, jobs)

def state_38(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_38(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_39(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_263(netted, tick, input, events, jobs)

def state_39(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_39(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_40(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_265(netted, tick, input, events, jobs)

def state_40(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_40(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def finalAt(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_261(netted, tick, input, events, jobs)

def finalWorld(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  finalAt(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def publicationAt_13(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.publishValue(C.world(at_13(prior, netted, tick, previous, input, events, jobs)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(at_14(prior, netted, tick, previous, input, events, jobs)), True{}} : B.Bundle<R.World, Bool>}:
  match prior netted:
    case True{} True{}: {==}
    case True{} False{}: {==}
    case False{} True{}: {==}
    case False{} False{}: {==}

def publication_13(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {C.publishValue(C.world(state_13(prior, tick, previous, input, events, jobs)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(prior, tick, previous, input, events, jobs)), True{}} : B.Bundle<R.World, Bool>}:
  publicationAt_13(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)
