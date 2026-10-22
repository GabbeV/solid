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

def data_77() -> List<&2, Nat>:
  [2n]

def data_78(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_20(tick, previous), data_23(tick), data_24(), 1n, 0n, False{}, data_77(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_79(+input: Nat) -> R.Value:
  R.Number{input}

def data_80(+input: Nat) -> R.Slot:
  R.Present{data_79(input)}

def data_81(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_80(input), False{}, 0, 0, 0, 0n, data_11(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_82(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_81(tick, previous, input), data_19(tick, previous)]

def data_83(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_82(tick, previous, input), data_23(tick), data_24(), 1n, 0n, False{}, data_77(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_84(+tick: Nat) -> R.Stamp:
  R.Stamped{Nat.add(3n, tick)}

def data_85(+tick: Nat, +previous: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(previous), data_80(input), False{}, 0, 0, 0, 0n, data_84(tick), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_86(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_85(tick, previous, input), data_19(tick, previous)]

def data_87(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_86(tick, previous, input), data_23(tick), data_24(), 1n, 0n, False{}, data_77(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_88(+tick: Nat, +previous: Nat) -> R.Node:
  R.Node{data_13(), data_14(previous), data_2(), False{}, 0, 16392, 0, tick, data_3(), 1n, 1n, Nat.add(2n, tick), 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_89(+tick: Nat, +previous: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_85(tick, previous, input), data_88(tick, previous)]

def data_90() -> List<&2, Nat>:
  [3n]

def data_91(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_89(tick, previous, input), data_23(tick), data_90(), 0n, 0n, False{}, data_77(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), jobs, 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def data_92() -> R.HostJob:
  R.FlushJob{}

def data_93(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  R.World{data_89(tick, previous, input), data_23(tick), data_90(), 0n, 0n, False{}, data_77(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, Nat.add(1n, tick), Nat.add(3n, tick), data_28(), events, data_29(), True{}, data_25(), data_33(), data_36(), data_25(), 0n, False{}, False{}, data_37(), 0n, data_40(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_31(), data_41(), data_44(), data_46(), B.append(R.HostJob, jobs, [data_92()]), 0n, data_49(), data_51(), data_53(), data_54(), data_56(), False{}, False{}, data_31(), data_58(), data_60(), data_63(), 0n, data_41(), False{}, data_64(), data_65(), data_66(), 0n, data_67(), data_68(), data_69(), data_70(), data_71(), 0n, data_74(), data_75(), data_2()}

def origin(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_76(tick, previous, events, jobs)

def queued(+tick: Nat, +previous: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_78(tick, previous, events, jobs)

def slotted(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_83(tick, previous, input, events, jobs)

def stamped(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_87(tick, previous, input, events, jobs)

def inserted(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_91(tick, previous, input, events, jobs)

def scheduled(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> R.World:
  data_93(tick, previous, input, events, jobs)
