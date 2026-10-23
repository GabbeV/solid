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

def data_49() -> R.StreamPlan:
  R.StreamPlan{data_48(), False{}, data_2(), 0n, 0n, data_2()}

def data_50() -> List<&2, R.StreamPlan>:
  [data_49()]

def data_51() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_52() -> List<&2, R.ExternalIterator>:
  [data_51()]

def data_53() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_54() -> List<&2, R.StreamState>:
  [data_53()]

def data_55() -> List<&2, R.IteratorEvent>:
  []

def data_56() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_43(), False{}, 0n, False{}, False{}, 0n}

def data_57() -> List<&2, R.Awaiter>:
  [data_56()]

def data_58() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_59() -> List<&2, R.AbortInput>:
  [data_58()]

def data_60() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_61() -> List<&2, R.ContextKey>:
  [data_60()]

def data_62() -> List<&2, R.ContextEntry>:
  []

def data_63() -> R.ContextRecord:
  R.ContextRecord{data_62()}

def data_64() -> List<&2, R.ContextRecord>:
  [data_63()]

def data_65() -> List<&2, R.Expr>:
  [data_4()]

def data_66() -> List<&2, R.ReactionState>:
  []

def data_67() -> List<&2, R.ComparatorBinding>:
  []

def data_68() -> List<&2, R.ActionState>:
  []

def data_69() -> List<&2, R.ActionWait>:
  []

def data_70() -> List<&2, R.ArrayData>:
  []

def data_71() -> List<&2, R.RepeatState>:
  []

def data_72() -> List<&2, R.MapState>:
  []

def data_73() -> List<&2, R.Guess>:
  []

def data_74() -> R.LaneMount:
  R.MountUnset{}

def data_75() -> R.LaneState:
  R.LaneState{data_25(), data_42(), data_25(), data_73(), 0n, data_74()}

def data_76() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_77() -> R.Value:
  R.Null{}

def data_78() -> R.DeferredCell:
  R.DeferredCell{0n, data_77(), False{}, False{}}

def data_79() -> R.DeferredBinding:
  R.DeferredBinding{data_78(), 0n}

def data_80() -> List<&2, R.DeferredBinding>:
  [data_79()]

def data_81() -> List<&2, R.DeferredWait>:
  []

def data_82() -> R.DeferredIterator:
  R.DeferredIterator{0n, 0n, 0n, False{}}

def data_83() -> List<&2, R.DeferredIterator>:
  [data_82()]

def data_84() -> R.DeferredArena:
  R.DeferredArena{data_80(), data_25(), data_81(), data_83()}

def data_85(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), False{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def data_86() -> List<&2, Nat>:
  [2n]

def data_87(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_86(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def data_88(+input: Nat) -> R.Value:
  R.Number{input}

def data_89(+input: Nat) -> R.Slot:
  R.Present{data_88(input)}

def data_90(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_89(input), False{}, 0, 0, 0, 0n, data_11(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_91(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_90(tick, previous, input), data_19(tick, previous)]

def data_92(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_91(tick, previous, input), data_23(tick), data_24(), 1n, 0n, False{}, data_86(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def data_93(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_94(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_89(input), False{}, 0, 0, 0, 0n, data_93(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_95(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(tick, previous, input), data_19(tick, previous)]

def data_96(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_95(tick, previous, input), data_23(tick), data_24(), 1n, 0n, False{}, data_86(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def data_97(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16392, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_98(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_94(tick, previous, input), data_97(tick, previous)]

def data_99() -> List<&2, Nat>:
  [3n]

def data_100(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_98(tick, previous, input), data_23(tick), data_99(), 0n, 0n, False{}, data_86(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), jobs, 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def data_101() -> R.HostJob:
  R.FlushJob{}

def data_102(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_98(tick, previous, input), data_23(tick), data_99(), 0n, 0n, False{}, data_86(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_34(), data_37(), data_25(), 0n, False{}, False{}, data_38(), 0n, data_41(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_32(), data_42(), data_45(), data_47(), B.append(R.HostJob, jobs, [data_101()]), 0n, data_50(), data_52(), data_54(), data_55(), data_57(), False{}, False{}, data_32(), data_59(), data_61(), data_64(), 0n, data_42(), False{}, data_65(), data_66(), data_67(), 0n, data_68(), data_69(), data_70(), data_71(), data_72(), 0n, data_75(), data_76(), data_2(), data_25(), data_84()}

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_85(tick, previous, events, jobs)

def queued(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_87(tick, previous, events, jobs)

def slotted(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_92(tick, previous, input, events, jobs)

def stamped(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_96(tick, previous, input, events, jobs)

def inserted(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_100(tick, previous, input, events, jobs)

def scheduled(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_102(tick, previous, input, events, jobs)
