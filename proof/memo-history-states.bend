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

def data_19(+prior: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,prior,_=>0,_=>16384), 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

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

def data_35() -> R.NodeExtension:
  R.NodeExtension{data_30(), 0n, data_1(), data_2(), 0n, 0n, data_31(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_32(), data_2(), 0n, data_33(), data_34(), data_3()}

def data_36() -> List<&2, R.NodeExtension>:
  [data_35()]

def data_37() -> List<&2, R.CleanupAction>:
  []

def data_38() -> R.CleanupProgram:
  R.CleanupProgram{data_37(), False{}, 0n}

def data_39() -> List<&2, R.CleanupProgram>:
  [data_38()]

def data_40() -> List<&2, R.Report>:
  []

def data_41() -> R.OptionalIds:
  R.NoIds{}

def data_42() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_41(), False{}}

def data_43() -> List<&2, R.Transaction>:
  [data_42()]

def data_44() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_45() -> R.AsyncSettlement:
  R.Unresolved{}

def data_46() -> R.AsyncObject:
  R.AsyncObject{False{}, data_45(), data_25(), 0n}

def data_47() -> List<&2, R.AsyncObject>:
  [data_46()]

def data_48() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n, 0n}

def data_49() -> List<&2, R.AsyncObserver>:
  [data_48()]

def data_50() -> List<&2, R.NextInput>:
  []

def data_51() -> R.FromState:
  R.FromNone{}

def data_52() -> R.StreamPlan:
  R.StreamPlan{data_50(), False{}, data_2(), 0n, 0n, data_2(), data_51()}

def data_53() -> List<&2, R.StreamPlan>:
  [data_52()]

def data_54() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_55() -> List<&2, R.ExternalIterator>:
  [data_54()]

def data_56() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_57() -> List<&2, R.StreamState>:
  [data_56()]

def data_58() -> List<&2, R.IteratorEvent>:
  []

def data_59() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_45(), False{}, 0n, False{}, False{}, 0n}

def data_60() -> List<&2, R.Awaiter>:
  [data_59()]

def data_61() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_62() -> List<&2, R.AbortInput>:
  [data_61()]

def data_63() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_64() -> List<&2, R.ContextKey>:
  [data_63()]

def data_65() -> List<&2, R.ContextEntry>:
  []

def data_66() -> R.ContextRecord:
  R.ContextRecord{data_65()}

def data_67() -> List<&2, R.ContextRecord>:
  [data_66()]

def data_68() -> List<&2, R.Expr>:
  [data_4()]

def data_69() -> List<&2, R.ReactionState>:
  []

def data_70() -> List<&2, R.ComparatorBinding>:
  []

def data_71() -> List<&2, R.ActionState>:
  []

def data_72() -> List<&2, R.ActionWait>:
  []

def data_73() -> List<&2, R.ArrayData>:
  []

def data_74() -> List<&2, R.RepeatState>:
  []

def data_75() -> List<&2, R.MapState>:
  []

def data_76() -> List<&2, R.Guess>:
  []

def data_77() -> R.LaneMount:
  R.MountUnset{}

def data_78() -> List<&2, R.KeptGuess>:
  []

def data_79() -> R.LaneState:
  R.LaneState{data_25(), data_44(), data_25(), data_76(), 0n, data_77(), data_25(), False{}, False{}, data_78(), data_25(), False{}, data_25()}

def data_80() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}, 0n}

def data_81() -> R.DeferredCell:
  R.DeferredCell{0n, data_33(), False{}, False{}}

def data_82() -> R.DeferredBinding:
  R.DeferredBinding{data_81(), 0n}

def data_83() -> List<&2, R.DeferredBinding>:
  [data_82()]

def data_84() -> List<&2, R.DeferredWait>:
  []

def data_85() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_86() -> List<&2, R.DeferredIterator>:
  [data_85()]

def data_87() -> R.DeferredArena:
  R.DeferredArena{data_83(), data_25(), data_84(), data_86()}

def data_88(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(prior, tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), jobs, 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_89(+input: Nat) -> R.Value:
  R.Number{input}

def data_90(+input: Nat) -> R.Slot:
  R.Present{data_89(input)}

def data_91(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_92(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_90(input), False{}, 0, 0, 0, 0n, data_91(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_93(+prior: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,prior,_=>8,_=>16392), 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_94(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_93(prior, tick, previous)]

def data_95() -> List<&2, Nat>:
  [3n]

def data_96() -> List<&2, Nat>:
  [2n]

def data_97() -> R.HostJob:
  R.FlushJob{}

def data_98(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_94(prior, tick, previous, input), data_23(tick), data_95(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_99() -> C.Task:
  C.Round{}

def data_100() -> List<&2, C.Task>:
  [data_99()]

def data_101() -> List<&2, R.Value>:
  []

def data_102(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_98(prior, tick, previous, input, events, jobs), data_100(), data_101()}

def data_103(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_94(prior, tick, previous, input), data_23(tick), data_95(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_104() -> C.Task:
  C.RoundAfterSweep{}

def data_105() -> C.Task:
  C.FlushFinally{}

def data_106() -> C.Task:
  C.RoundEnd{}

def data_107() -> List<&2, C.Task>:
  [data_104(), data_105(), data_106()]

def data_108(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_103(prior, tick, previous, input, events, jobs), data_107(), data_101()}

def data_109() -> C.Task:
  C.HeapLoop{}

def data_110() -> List<&2, C.Task>:
  [data_109(), data_105(), data_106()]

def data_111(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_103(prior, tick, previous, input, events, jobs), data_110(), data_101()}

def data_112() -> C.Task:
  C.Recompute{3n, False{}}

def data_113() -> List<&2, C.Task>:
  [data_112(), data_109(), data_105(), data_106()]

def data_114(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_103(prior, tick, previous, input, events, jobs), data_113(), data_101()}

def data_115(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_19(prior, tick, previous)]

def data_116() -> R.LaneMount:
  R.MountFalse{}

def data_117() -> R.LaneState:
  R.LaneState{data_25(), data_44(), data_25(), data_76(), 0n, data_116(), data_25(), False{}, False{}, data_78(), data_25(), False{}, data_25()}

def data_118(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_115(prior, tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), events, data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_117(), data_80(), data_2(), data_25(), data_87()}

def data_119() -> C.LanePass:
  C.LanePass{0n, data_77(), data_116(), False{}}

def data_120() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_119()}

def data_121() -> List<&2, C.Task>:
  [data_120(), data_109(), data_105(), data_106()]

def data_122(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_118(prior, tick, previous, input, events, jobs), data_121(), data_101()}

def data_123() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_119()}

def data_124() -> List<&2, C.Task>:
  [data_123(), data_109(), data_105(), data_106()]

def data_125(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_118(prior, tick, previous, input, events, jobs), data_124(), data_101()}

def data_126(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 4, 0, Nat.add(1n, tick), data_3(), 1n, 0n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_127(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_126(tick, previous)]

def data_128() -> R.TraceEvent:
  R.Invoked{3n}

def data_129(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_127(tick, previous, input), data_23(tick), data_24(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, events, [data_128()]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_117(), data_80(), data_2(), data_25(), data_87()}

def data_130(+previous: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(previous)}

def data_131() -> R.Value:
  R.Number{0n}

def data_132(+previous: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(previous), False{}, data_131(), 0n, False{}, data_34(), data_101(), 0n, False{}, data_119()}

def data_133(+previous: Nat) -> C.Task:
  C.Finish{data_132(previous)}

def data_134(+previous: Nat) -> List<&2, C.Task>:
  [data_130(previous), data_133(previous), data_109(), data_105(), data_106()]

def data_135(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_129(tick, previous, input, events, jobs), data_134(previous), data_101()}

def data_136(+previous: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(previous)}

def data_137(+previous: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(previous)}

def data_138() -> C.Task:
  C.Binary{0}

def data_139(+previous: Nat) -> List<&2, C.Task>:
  [data_136(previous), data_137(previous), data_138(), data_133(previous), data_109(), data_105(), data_106()]

def data_140(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_129(tick, previous, input, events, jobs), data_139(previous), data_101()}

def data_141() -> C.Task:
  C.ReadNode{2n}

def data_142(+previous: Nat) -> List<&2, C.Task>:
  [data_141(), data_137(previous), data_138(), data_133(previous), data_109(), data_105(), data_106()]

def data_143(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_129(tick, previous, input, events, jobs), data_142(previous), data_101()}

def data_144() -> C.Task:
  C.ReadPrepared{2n}

def data_145(+previous: Nat) -> List<&2, C.Task>:
  [data_144(), data_137(previous), data_138(), data_133(previous), data_109(), data_105(), data_106()]

def data_146(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_129(tick, previous, input, events, jobs), data_145(previous), data_101()}

def data_147(+netted: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,netted,_=>4,_=>16388), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_148(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_147(netted, tick, previous)]

def data_149(+tick: Nat) -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, Nat.add(3n, tick)}

def data_150(+tick: Nat) -> List<&2, R.Link>:
  [data_21(), data_149(tick)]

def data_151(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_89(input)}

def data_152(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_148(netted, tick, previous, input), data_150(tick), data_24(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_117(), data_80(), data_2(), data_25(), data_87()}

def data_153(+previous: Nat) -> List<&2, C.Task>:
  [data_137(previous), data_138(), data_133(previous), data_109(), data_105(), data_106()]

def data_154(+input: Nat) -> List<&2, R.Value>:
  [data_89(input)]

def data_155(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_152(netted, tick, previous, input, events, jobs), data_153(previous), data_154(input)}

def data_156(+previous: Nat) -> List<&2, C.Task>:
  [data_138(), data_133(previous), data_109(), data_105(), data_106()]

def data_157(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_89(input)]

def data_158(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_152(netted, tick, previous, input, events, jobs), data_156(previous), data_157(input)}

def data_159(+previous: Nat) -> List<&2, C.Task>:
  [data_133(previous), data_109(), data_105(), data_106()]

def data_160(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_161(+input: Nat) -> List<&2, R.Value>:
  [data_160(input)]

def data_162(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_152(netted, tick, previous, input, events, jobs), data_159(previous), data_161(input)}

def data_163(+netted: Bool, +tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_164(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_163(netted, tick, previous)]

def data_165(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_164(netted, tick, previous, input), data_150(tick), data_24(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_166(+previous: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_132(previous), 0n, data_160(input), False{}, False{}, False{}, data_29()}

def data_167(+previous: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_166(previous, input), data_109(), data_105(), data_106()]

def data_168(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_165(netted, tick, previous, input, events, jobs), data_167(previous, input), data_101()}

def data_169(+input: Nat) -> R.Slot:
  R.Present{data_160(input)}

def data_170(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_169(input), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_171(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_170(netted, tick, previous, input)]

def data_172(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_171(netted, tick, previous, input), data_150(tick), data_24(), 0n, 0n, False{}, data_96(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_173() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_174() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_175() -> List<&2, C.Task>:
  [data_173(), data_174(), data_109(), data_105(), data_106()]

def data_176(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_172(netted, tick, previous, input, events, jobs), data_175(), data_101()}

def data_177() -> List<&2, C.Task>:
  [data_174(), data_109(), data_105(), data_106()]

def data_178(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_172(netted, tick, previous, input, events, jobs), data_177(), data_101()}

def data_179() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_180() -> List<&2, C.Task>:
  [data_179(), data_109(), data_105(), data_106()]

def data_181(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_172(netted, tick, previous, input, events, jobs), data_180(), data_101()}

def data_182(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_169(input), False{}, 128, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_183(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_92(tick, previous, input), data_182(netted, tick, previous, input)]

def data_184() -> List<&2, Nat>:
  [2n, 3n]

def data_185(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_183(netted, tick, previous, input), data_150(tick), data_24(), 0n, 0n, False{}, data_184(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_186(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_185(netted, tick, previous, input, events, jobs), data_110(), data_101()}

def data_187(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_183(netted, tick, previous, input), data_150(tick), data_24(), 1n, 0n, False{}, data_184(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_188(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_187(netted, tick, previous, input, events, jobs), data_110(), data_101()}

def data_189() -> C.Task:
  C.Seam{}

def data_190() -> List<&2, C.Task>:
  [data_189(), data_105(), data_106()]

def data_191(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_187(netted, tick, previous, input, events, jobs), data_190(), data_101()}

def data_192() -> C.Task:
  C.Settle{}

def data_193() -> C.Task:
  C.AfterSettle{}

def data_194() -> List<&2, C.Task>:
  [data_192(), data_193(), data_105(), data_106()]

def data_195(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_187(netted, tick, previous, input, events, jobs), data_194(), data_101()}

def data_196() -> C.Task:
  C.CommitIntake{0n}

def data_197() -> C.Task:
  C.TrimIntake{0n}

def data_198() -> C.Task:
  C.FinishSettleIntake{0n}

def data_199() -> List<&2, C.Task>:
  [data_196(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_200(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_187(netted, tick, previous, input, events, jobs), data_199(), data_101()}

def data_201() -> C.Task:
  C.CommitPending{2n}

def data_202() -> C.Task:
  C.CommitIntake{1n}

def data_203() -> List<&2, C.Task>:
  [data_201(), data_202(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_204(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_187(netted, tick, previous, input, events, jobs), data_203(), data_101()}

def data_205(+tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_89(input), data_2(), False{}, 0, 0, 0, 0n, data_91(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_206(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_205(tick, input), data_182(netted, tick, previous, input)]

def data_207(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_206(netted, tick, previous, input), data_150(tick), data_24(), 1n, 0n, False{}, data_184(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_208() -> List<&2, C.Task>:
  [data_202(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_209(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_207(netted, tick, previous, input, events, jobs), data_208(), data_101()}

def data_210() -> C.Task:
  C.CommitPending{3n}

def data_211() -> C.Task:
  C.CommitIntake{2n}

def data_212() -> List<&2, C.Task>:
  [data_210(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_213(+netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_207(netted, tick, previous, input, events, jobs), data_212(), data_101()}

def data_214(+netted: Bool, +tick: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_160(input), data_2(), False{}, 0, B.choose(~U32,netted,_=>0,_=>16384), 0, Nat.add(1n, tick), data_3(), 1n, 1n, Nat.add(3n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_215(+netted: Bool, +tick: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_205(tick, input), data_214(netted, tick, input)]

def data_216(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_215(netted, tick, input), data_150(tick), data_24(), 1n, 0n, False{}, data_184(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_217() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_218() -> List<&2, C.Task>:
  [data_217(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_219(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_216(netted, tick, input, events, jobs), data_218(), data_101()}

def data_220() -> O.Task:
  O.TrimDeps{3n}

def data_221() -> List<&2, O.Task>:
  [data_220()]

def data_222() -> C.Task:
  C.OwnerTasks{data_221()}

def data_223() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_224() -> List<&2, C.Task>:
  [data_222(), data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_225(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_216(netted, tick, input, events, jobs), data_224(), data_101()}

def data_226() -> List<&2, O.Task>:
  []

def data_227() -> C.Task:
  C.OwnerTasks{data_226()}

def data_228() -> List<&2, C.Task>:
  [data_227(), data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_229(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_216(netted, tick, input, events, jobs), data_228(), data_101()}

def data_230() -> List<&2, C.Task>:
  [data_223(), data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_231(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_216(netted, tick, input, events, jobs), data_230(), data_101()}

def data_232() -> List<&2, C.Task>:
  [data_211(), data_197(), data_198(), data_193(), data_105(), data_106()]

def data_233(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_216(netted, tick, input, events, jobs), data_232(), data_101()}

def data_234(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_215(netted, tick, input), data_150(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, Nat.add(1n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_235() -> List<&2, C.Task>:
  [data_197(), data_198(), data_193(), data_105(), data_106()]

def data_236(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_235(), data_101()}

def data_237() -> List<&2, C.Task>:
  [data_198(), data_193(), data_105(), data_106()]

def data_238(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_237(), data_101()}

def data_239() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_240() -> C.Task:
  C.LandTransactions{data_239(), 0n}

def data_241() -> List<&2, C.Task>:
  [data_240(), data_193(), data_105(), data_106()]

def data_242(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_241(), data_101()}

def data_243() -> C.Task:
  C.CompleteSettle{data_239()}

def data_244() -> List<&2, C.Task>:
  [data_243(), data_193(), data_105(), data_106()]

def data_245(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_244(), data_101()}

def data_246() -> C.Task:
  C.ZombieLoop{data_25()}

def data_247() -> List<&2, C.Task>:
  [data_246(), data_193(), data_105(), data_106()]

def data_248(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_247(), data_101()}

def data_249() -> List<&2, C.Task>:
  [data_193(), data_105(), data_106()]

def data_250(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_234(netted, tick, input, events, jobs), data_249(), data_101()}

def data_251(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_215(netted, tick, input), data_150(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_252() -> C.Task:
  C.RenderQueue{}

def data_253() -> List<&2, C.Task>:
  [data_252(), data_105(), data_106()]

def data_254(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_251(netted, tick, input, events, jobs), data_253(), data_101()}

def data_255() -> C.Task:
  C.UserQueue{}

def data_256() -> List<&2, C.Task>:
  [data_255(), data_105(), data_106()]

def data_257(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_251(netted, tick, input, events, jobs), data_256(), data_101()}

def data_258() -> List<&2, C.Task>:
  [data_105(), data_106()]

def data_259(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_251(netted, tick, input, events, jobs), data_258(), data_101()}

def data_260(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_215(netted, tick, input), data_150(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(2n, tick), Nat.add(4n, tick), data_28(), B.append(R.TraceEvent, B.append(R.TraceEvent, events, [data_128()]), [data_151(input)]), data_29(), False{}, data_25(), data_36(), data_39(), data_25(), 0n, False{}, False{}, data_40(), 0n, data_43(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_44(), data_47(), data_49(), B.append(R.HostJob, jobs, [data_97()]), 0n, data_53(), data_55(), data_57(), data_58(), data_60(), False{}, False{}, data_32(), data_62(), data_64(), data_67(), 0n, data_44(), False{}, data_68(), data_69(), data_70(), 0n, data_71(), data_72(), data_73(), data_74(), data_75(), 0n, data_79(), data_80(), data_2(), data_25(), data_87()}

def data_261() -> List<&2, C.Task>:
  [data_106()]

def data_262(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_260(netted, tick, input, events, jobs), data_261(), data_101()}

def data_263() -> List<&2, C.Task>:
  []

def data_264(+netted: Bool, +tick: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{data_260(netted, tick, input, events, jobs), data_263(), data_101()}

def origin(+prior: Bool, +tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_88(prior, tick, previous, events, jobs)

def at_0(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_102(prior, tick, previous, input, events, jobs)

def state_0(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_0(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_1(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_108(prior, tick, previous, input, events, jobs)

def state_1(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_1(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_2(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_111(prior, tick, previous, input, events, jobs)

def state_2(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_2(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_3(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_114(prior, tick, previous, input, events, jobs)

def state_3(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_3(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_4(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_122(prior, tick, previous, input, events, jobs)

def state_4(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_4(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_5(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_125(prior, tick, previous, input, events, jobs)

def state_5(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_5(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_6(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_135(tick, previous, input, events, jobs)

def state_6(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_6(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_7(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_140(tick, previous, input, events, jobs)

def state_7(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_7(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_8(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_143(tick, previous, input, events, jobs)

def state_8(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_8(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_9(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_146(tick, previous, input, events, jobs)

def state_9(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_9(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_10(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_155(netted, tick, previous, input, events, jobs)

def state_10(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_10(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_11(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_158(netted, tick, previous, input, events, jobs)

def state_11(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_11(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_12(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_162(netted, tick, previous, input, events, jobs)

def state_12(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_12(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_13(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_168(netted, tick, previous, input, events, jobs)

def state_13(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_13(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_14(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_176(netted, tick, previous, input, events, jobs)

def state_14(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_14(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_15(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_178(netted, tick, previous, input, events, jobs)

def state_15(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_15(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_16(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_181(netted, tick, previous, input, events, jobs)

def state_16(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_16(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_17(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_186(netted, tick, previous, input, events, jobs)

def state_17(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_17(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_18(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_188(netted, tick, previous, input, events, jobs)

def state_18(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_18(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_19(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_191(netted, tick, previous, input, events, jobs)

def state_19(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_19(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_20(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_195(netted, tick, previous, input, events, jobs)

def state_20(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_20(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_21(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_200(netted, tick, previous, input, events, jobs)

def state_21(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_21(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_22(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_204(netted, tick, previous, input, events, jobs)

def state_22(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_22(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_23(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_209(netted, tick, previous, input, events, jobs)

def state_23(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_23(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_24(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_213(netted, tick, previous, input, events, jobs)

def state_24(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_24(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_25(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_219(netted, tick, input, events, jobs)

def state_25(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_25(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_26(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_225(netted, tick, input, events, jobs)

def state_26(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_26(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_27(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_229(netted, tick, input, events, jobs)

def state_27(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_27(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_28(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_231(netted, tick, input, events, jobs)

def state_28(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_28(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_29(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_233(netted, tick, input, events, jobs)

def state_29(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_29(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_30(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_236(netted, tick, input, events, jobs)

def state_30(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_30(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_31(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_238(netted, tick, input, events, jobs)

def state_31(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_31(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_32(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_242(netted, tick, input, events, jobs)

def state_32(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_32(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_33(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_245(netted, tick, input, events, jobs)

def state_33(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_33(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_34(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_248(netted, tick, input, events, jobs)

def state_34(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_34(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_35(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_250(netted, tick, input, events, jobs)

def state_35(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_35(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_36(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_254(netted, tick, input, events, jobs)

def state_36(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_36(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_37(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_257(netted, tick, input, events, jobs)

def state_37(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_37(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_38(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_259(netted, tick, input, events, jobs)

def state_38(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_38(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_39(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_262(netted, tick, input, events, jobs)

def state_39(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_39(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def at_40(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  data_264(netted, tick, input, events, jobs)

def state_40(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  at_40(prior, Nat.is_eq(input, previous), tick, previous, input, events, jobs)

def finalAt(+prior: Bool, +netted: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_260(netted, tick, input, events, jobs)

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
