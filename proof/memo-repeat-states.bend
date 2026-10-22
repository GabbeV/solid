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

def data_36() -> R.Snapshot:
  R.NoSnapshotValue{}

def data_37() -> R.Question:
  R.QuestionZero{}

def data_38() -> R.NodeExtension:
  R.NodeExtension{0n, 0n, data_1(), data_2(), 0n, 0n, data_36(), 0n, data_5(), 0n, False{}, data_2(), data_3(), data_37(), data_2(), 0n, data_1()}

def data_39() -> List<&2, R.NodeExtension>:
  [data_38()]

def data_40() -> List<&2, R.CleanupAction>:
  []

def data_41() -> R.CleanupProgram:
  R.CleanupProgram{data_40(), False{}, 0n}

def data_42() -> List<&2, R.CleanupProgram>:
  [data_41()]

def data_43() -> List<&2, R.Report>:
  []

def data_44() -> R.OptionalIds:
  R.NoIds{}

def data_45() -> R.Transaction:
  R.Transaction{data_25(), data_25(), data_26(), data_25(), 0n, 0n, False{}, 0n, 0n, False{}, 0n, False{}, False{}, data_44()}

def data_46() -> List<&2, R.Transaction>:
  [data_45()]

def data_47() -> List<&2, List<&2, Nat>>:
  [data_25()]

def data_48() -> R.AsyncSettlement:
  R.Unresolved{}

def data_49() -> R.AsyncObject:
  R.AsyncObject{False{}, data_48(), data_25(), 0n}

def data_50() -> List<&2, R.AsyncObject>:
  [data_49()]

def data_51() -> R.AsyncObserver:
  R.AsyncObserver{0n, 0n, False{}, False{}, False{}, data_1(), data_1(), 0n}

def data_52() -> List<&2, R.AsyncObserver>:
  [data_51()]

def data_53() -> R.HostJob:
  R.FlushJob{}

def data_54() -> List<&2, R.HostJob>:
  [data_53()]

def data_55() -> List<&2, R.NextInput>:
  []

def data_56() -> R.StreamPlan:
  R.StreamPlan{data_55(), False{}, data_2(), 0n}

def data_57() -> List<&2, R.StreamPlan>:
  [data_56()]

def data_58() -> R.ExternalIterator:
  R.ExternalIterator{0n, 0n, 0n}

def data_59() -> List<&2, R.ExternalIterator>:
  [data_58()]

def data_60() -> R.StreamState:
  R.StreamState{0n, 0n, 0n, False{}, False{}, False{}, data_1(), 0n}

def data_61() -> List<&2, R.StreamState>:
  [data_60()]

def data_62() -> List<&2, R.IteratorEvent>:
  []

def data_63() -> R.Awaiter:
  R.Awaiter{data_4(), False{}, 0n, 0n, 0n, 0n, data_48(), False{}, 0n, False{}, False{}, 0n}

def data_64() -> List<&2, R.Awaiter>:
  [data_63()]

def data_65() -> R.AbortInput:
  R.AbortInput{False{}, data_1()}

def data_66() -> List<&2, R.AbortInput>:
  [data_65()]

def data_67() -> R.ContextKey:
  R.ContextKey{data_1(), data_2()}

def data_68() -> List<&2, R.ContextKey>:
  [data_67()]

def data_69() -> List<&2, R.ContextEntry>:
  []

def data_70() -> R.ContextRecord:
  R.ContextRecord{data_69()}

def data_71() -> List<&2, R.ContextRecord>:
  [data_70()]

def data_72() -> List<&2, R.Expr>:
  [data_4()]

def data_73() -> List<&2, R.ReactionState>:
  []

def data_74() -> List<&2, R.ComparatorBinding>:
  []

def data_75() -> List<&2, R.ActionState>:
  []

def data_76() -> List<&2, R.ActionWait>:
  []

def data_77() -> List<&2, R.ArrayData>:
  []

def data_78() -> List<&2, R.RepeatState>:
  []

def data_79() -> List<&2, R.MapState>:
  []

def data_80() -> List<&2, R.Guess>:
  []

def data_81() -> R.LaneMount:
  R.MountUnset{}

def data_82() -> R.LaneState:
  R.LaneState{data_25(), data_47(), data_25(), data_80(), 0n, data_81()}

def data_83() -> R.VerdictState:
  R.VerdictState{False{}, False{}, False{}, False{}}

def data_84(+initial: Nat, +first: Nat) -> R.World:
  R.World{data_20(first), data_23(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_54(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_85(+input: Nat) -> R.Value:
  R.Number{input}

def data_86(+input: Nat) -> R.Slot:
  R.Present{data_85(input)}

def data_87() -> R.Stamp:
  R.Stamped{3n}

def data_88(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_9(), data_10(first), data_86(input), False{}, 0, 0, 0, 0n, data_87(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_89(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16392, 0, 0n, data_3(), 1n, 1n, 2n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_90(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_89(first)]

def data_91() -> List<&2, Nat>:
  [3n]

def data_92() -> List<&2, Nat>:
  [2n]

def data_93() -> List<&2, R.HostJob>:
  [data_53(), data_53()]

def data_94(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_90(first, input), data_23(), data_91(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, False{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), True{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_95() -> C.Task:
  C.Round{}

def data_96() -> List<&2, C.Task>:
  [data_95()]

def data_97() -> List<&2, R.Value>:
  []

def data_98(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_94(initial, first, input), data_96(), data_97()}

def data_99(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_90(first, input), data_23(), data_91(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 3n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_100() -> C.Task:
  C.RoundAfterSweep{}

def data_101() -> C.Task:
  C.FlushFinally{}

def data_102() -> C.Task:
  C.RoundEnd{}

def data_103() -> List<&2, C.Task>:
  [data_100(), data_101(), data_102()]

def data_104(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_99(initial, first, input), data_103(), data_97()}

def data_105() -> C.Task:
  C.HeapLoop{}

def data_106() -> List<&2, C.Task>:
  [data_105(), data_101(), data_102()]

def data_107(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_99(initial, first, input), data_106(), data_97()}

def data_108() -> C.Task:
  C.Recompute{3n, False{}}

def data_109() -> List<&2, C.Task>:
  [data_108(), data_105(), data_101(), data_102()]

def data_110(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_99(initial, first, input), data_109(), data_97()}

def data_111(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_19(first)]

def data_112() -> R.LaneMount:
  R.MountFalse{}

def data_113() -> R.LaneState:
  R.LaneState{data_25(), data_47(), data_25(), data_80(), 0n, data_112()}

def data_114(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_111(first, input), data_23(), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_34(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_113(), data_83(), data_2()}

def data_115() -> C.LanePass:
  C.LanePass{0n, data_81(), data_112()}

def data_116() -> C.Task:
  C.RecomputeAfterTeardown{3n, 0n, data_115()}

def data_117() -> List<&2, C.Task>:
  [data_116(), data_105(), data_101(), data_102()]

def data_118(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_114(initial, first, input), data_117(), data_97()}

def data_119() -> C.Task:
  C.RecomputePrepared{3n, False{}, 0n, data_115()}

def data_120() -> List<&2, C.Task>:
  [data_119(), data_105(), data_101(), data_102()]

def data_121(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_114(initial, first, input), data_120(), data_97()}

def data_122(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 4, 0, 1n, data_3(), 1n, 0n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_123(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_122(first)]

def data_124(+initial: Nat, +first: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29()]

def data_125(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_123(first, input), data_23(), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_124(initial, first), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_113(), data_83(), data_2()}

def data_126(+first: Nat) -> C.Task:
  C.Evaluate{data_18(), data_14(first)}

def data_127(+first: Nat) -> C.PassFrame:
  C.PassFrame{3n, False{}, 0n, False{}, 0n, False{}, data_14(first), False{}, data_1(), 0n, False{}, 0n, data_97(), 0n, False{}, data_115()}

def data_128(+first: Nat) -> C.Task:
  C.Finish{data_127(first)}

def data_129(+first: Nat) -> List<&2, C.Task>:
  [data_126(first), data_128(first), data_105(), data_101(), data_102()]

def data_130(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_125(initial, first, input), data_129(first), data_97()}

def data_131(+first: Nat) -> C.Task:
  C.Evaluate{data_15(), data_14(first)}

def data_132(+first: Nat) -> C.Task:
  C.Evaluate{data_17(), data_14(first)}

def data_133() -> C.Task:
  C.Binary{0}

def data_134(+first: Nat) -> List<&2, C.Task>:
  [data_131(first), data_132(first), data_133(), data_128(first), data_105(), data_101(), data_102()]

def data_135(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_125(initial, first, input), data_134(first), data_97()}

def data_136() -> C.Task:
  C.ReadNode{2n}

def data_137(+first: Nat) -> List<&2, C.Task>:
  [data_136(), data_132(first), data_133(), data_128(first), data_105(), data_101(), data_102()]

def data_138(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_125(initial, first, input), data_137(first), data_97()}

def data_139() -> C.Task:
  C.ReadPrepared{2n}

def data_140(+first: Nat) -> List<&2, C.Task>:
  [data_139(), data_132(first), data_133(), data_128(first), data_105(), data_101(), data_102()]

def data_141(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_125(initial, first, input), data_140(first), data_97()}

def data_142(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16388, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_143(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_142(first)]

def data_144() -> R.Link:
  R.Link{2n, 3n, 0n, 0n, 0n, 3n}

def data_145() -> List<&2, R.Link>:
  [data_21(), data_144()]

def data_146(+input: Nat) -> R.TraceEvent:
  R.ReadValue{3n, 2n, data_85(input)}

def data_147(+initial: Nat, +first: Nat, +input: Nat) -> List<&2, R.TraceEvent>:
  [data_29(), data_31(initial), data_32(), data_29(), data_33(first), data_29(), data_146(input)]

def data_148(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_143(first, input), data_145(), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 3n, True{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_113(), data_83(), data_2()}

def data_149(+first: Nat) -> List<&2, C.Task>:
  [data_132(first), data_133(), data_128(first), data_105(), data_101(), data_102()]

def data_150(+input: Nat) -> List<&2, R.Value>:
  [data_85(input)]

def data_151(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_148(initial, first, input), data_149(first), data_150(input)}

def data_152(+first: Nat) -> List<&2, C.Task>:
  [data_133(), data_128(first), data_105(), data_101(), data_102()]

def data_153(+input: Nat) -> List<&2, R.Value>:
  [data_16(), data_85(input)]

def data_154(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_148(initial, first, input), data_152(first), data_153(input)}

def data_155(+first: Nat) -> List<&2, C.Task>:
  [data_128(first), data_105(), data_101(), data_102()]

def data_156(+input: Nat) -> R.Value:
  R.Number{Nat.add(input, 1n)}

def data_157(+input: Nat) -> List<&2, R.Value>:
  [data_156(input)]

def data_158(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_148(initial, first, input), data_155(first), data_157(input)}

def data_159(+first: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_160(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_159(first)]

def data_161(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_160(first, input), data_145(), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_162(+first: Nat, +input: Nat) -> C.Task:
  C.PassReleases{data_127(first), 0n, data_156(input), False{}, False{}, False{}, data_35()}

def data_163(+first: Nat, +input: Nat) -> List<&2, C.Task>:
  [data_162(first, input), data_105(), data_101(), data_102()]

def data_164(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_161(initial, first, input), data_163(first, input), data_97()}

def data_165(+input: Nat) -> R.Slot:
  R.Present{data_156(input)}

def data_166(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_165(input), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_167(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_166(first, input)]

def data_168(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_167(first, input), data_145(), data_24(), 0n, 0n, False{}, data_92(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_169() -> C.Task:
  C.PublishSettleSelf{3n, False{}}

def data_170() -> C.Task:
  C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n}

def data_171() -> List<&2, C.Task>:
  [data_169(), data_170(), data_105(), data_101(), data_102()]

def data_172(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_168(initial, first, input), data_171(), data_97()}

def data_173() -> List<&2, C.Task>:
  [data_170(), data_105(), data_101(), data_102()]

def data_174(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_168(initial, first, input), data_173(), data_97()}

def data_175() -> C.Task:
  C.QueuePublication{3n, False{}, False{}, 0n, 0n}

def data_176() -> List<&2, C.Task>:
  [data_175(), data_105(), data_101(), data_102()]

def data_177(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_168(initial, first, input), data_176(), data_97()}

def data_178(+first: Nat, +input: Nat) -> R.Node:
  R.Node{data_13(), data_14(first), data_165(input), False{}, 128, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_179(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_88(first, input), data_178(first, input)]

def data_180() -> List<&2, Nat>:
  [2n, 3n]

def data_181(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_179(first, input), data_145(), data_24(), 0n, 0n, False{}, data_180(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_182(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_181(initial, first, input), data_106(), data_97()}

def data_183(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_179(first, input), data_145(), data_24(), 1n, 0n, False{}, data_180(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_184(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_183(initial, first, input), data_106(), data_97()}

def data_185() -> C.Task:
  C.Seam{}

def data_186() -> List<&2, C.Task>:
  [data_185(), data_101(), data_102()]

def data_187(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_183(initial, first, input), data_186(), data_97()}

def data_188() -> C.Task:
  C.Settle{}

def data_189() -> C.Task:
  C.AfterSettle{}

def data_190() -> List<&2, C.Task>:
  [data_188(), data_189(), data_101(), data_102()]

def data_191(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_183(initial, first, input), data_190(), data_97()}

def data_192() -> C.Task:
  C.CommitIntake{0n}

def data_193() -> C.Task:
  C.TrimIntake{0n}

def data_194() -> C.Task:
  C.FinishSettleIntake{0n}

def data_195() -> List<&2, C.Task>:
  [data_192(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_196(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_183(initial, first, input), data_195(), data_97()}

def data_197() -> C.Task:
  C.CommitPending{2n}

def data_198() -> C.Task:
  C.CommitIntake{1n}

def data_199() -> List<&2, C.Task>:
  [data_197(), data_198(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_200(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_183(initial, first, input), data_199(), data_97()}

def data_201(+input: Nat) -> R.Node:
  R.Node{data_9(), data_85(input), data_2(), False{}, 0, 0, 0, 0n, data_87(), 0n, 0n, 0n, 1n, 1n, 0n, 0n, 0n, 0n, 0n, 0n, 0n, data_4(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_202(+first: Nat, +input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_201(input), data_178(first, input)]

def data_203(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_202(first, input), data_145(), data_24(), 1n, 0n, False{}, data_180(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_204() -> List<&2, C.Task>:
  [data_198(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_205(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_203(initial, first, input), data_204(), data_97()}

def data_206() -> C.Task:
  C.CommitPending{3n}

def data_207() -> C.Task:
  C.CommitIntake{2n}

def data_208() -> List<&2, C.Task>:
  [data_206(), data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_209(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_203(initial, first, input), data_208(), data_97()}

def data_210(+input: Nat) -> R.Node:
  R.Node{data_13(), data_156(input), data_2(), False{}, 0, 16384, 0, 1n, data_3(), 1n, 1n, 3n, 0n, 0n, 0n, 0n, 3n, 1n, 0n, 0n, 0n, data_18(), False{}, data_1(), 0n, False{}, 0n, 0n, 0n, 0n, data_5(), 0n, 0n, 0n, 0n}

def data_211(+input: Nat) -> List<&2, R.Node>:
  [data_6(), data_8(), data_201(input), data_210(input)]

def data_212(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_211(input), data_145(), data_24(), 1n, 0n, False{}, data_180(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_213() -> C.Task:
  C.CommitFinish{3n, False{}}

def data_214() -> List<&2, C.Task>:
  [data_213(), data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_215(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, first, input), data_214(), data_97()}

def data_216() -> O.Task:
  O.TrimDeps{3n}

def data_217() -> List<&2, O.Task>:
  [data_216()]

def data_218() -> C.Task:
  C.OwnerTasks{data_217()}

def data_219() -> C.Task:
  C.CommitAfterTrim{3n, False{}}

def data_220() -> List<&2, C.Task>:
  [data_218(), data_219(), data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_221(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, first, input), data_220(), data_97()}

def data_222() -> List<&2, O.Task>:
  []

def data_223() -> C.Task:
  C.OwnerTasks{data_222()}

def data_224() -> List<&2, C.Task>:
  [data_223(), data_219(), data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_225(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, first, input), data_224(), data_97()}

def data_226() -> List<&2, C.Task>:
  [data_219(), data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_227(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, first, input), data_226(), data_97()}

def data_228() -> List<&2, C.Task>:
  [data_207(), data_193(), data_194(), data_189(), data_101(), data_102()]

def data_229(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_212(initial, first, input), data_228(), data_97()}

def data_230(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_211(input), data_145(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, True{}, 1n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_231() -> List<&2, C.Task>:
  [data_193(), data_194(), data_189(), data_101(), data_102()]

def data_232(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_231(), data_97()}

def data_233() -> List<&2, C.Task>:
  [data_194(), data_189(), data_101(), data_102()]

def data_234(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_233(), data_97()}

def data_235() -> C.SeamFrame:
  C.SeamFrame{0n, data_25(), data_26(), data_25(), data_26()}

def data_236() -> C.Task:
  C.LandTransactions{data_235(), 0n}

def data_237() -> List<&2, C.Task>:
  [data_236(), data_189(), data_101(), data_102()]

def data_238(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_237(), data_97()}

def data_239() -> C.Task:
  C.CompleteSettle{data_235()}

def data_240() -> List<&2, C.Task>:
  [data_239(), data_189(), data_101(), data_102()]

def data_241(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_240(), data_97()}

def data_242() -> C.Task:
  C.ZombieLoop{data_25()}

def data_243() -> List<&2, C.Task>:
  [data_242(), data_189(), data_101(), data_102()]

def data_244(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_243(), data_97()}

def data_245() -> List<&2, C.Task>:
  [data_189(), data_101(), data_102()]

def data_246(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_230(initial, first, input), data_245(), data_97()}

def data_247(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_211(input), data_145(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, True{}, False{}, 2n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_248() -> C.Task:
  C.RenderQueue{}

def data_249() -> List<&2, C.Task>:
  [data_248(), data_101(), data_102()]

def data_250(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_247(initial, first, input), data_249(), data_97()}

def data_251() -> C.Task:
  C.UserQueue{}

def data_252() -> List<&2, C.Task>:
  [data_251(), data_101(), data_102()]

def data_253(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_247(initial, first, input), data_252(), data_97()}

def data_254() -> List<&2, C.Task>:
  [data_101(), data_102()]

def data_255(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_247(initial, first, input), data_254(), data_97()}

def data_256(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  R.World{data_211(input), data_145(), data_24(), 1n, 0n, False{}, data_25(), data_25(), data_25(), data_26(), 0n, False{}, False{}, False{}, 2n, 4n, data_28(), data_147(initial, first, input), data_35(), False{}, data_25(), data_39(), data_42(), data_25(), 0n, False{}, False{}, data_43(), 0n, data_46(), data_25(), 0n, 0n, 0n, 0n, data_25(), data_37(), data_47(), data_50(), data_52(), data_93(), 0n, data_57(), data_59(), data_61(), data_62(), data_64(), False{}, False{}, data_37(), data_66(), data_68(), data_71(), 0n, data_47(), False{}, data_72(), data_73(), data_74(), 0n, data_75(), data_76(), data_77(), data_78(), data_79(), 0n, data_82(), data_83(), data_2()}

def data_257() -> List<&2, C.Task>:
  [data_102()]

def data_258(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_256(initial, first, input), data_257(), data_97()}

def data_259() -> List<&2, C.Task>:
  []

def data_260(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{data_256(initial, first, input), data_259(), data_97()}

def origin(+initial: Nat, +first: Nat) -> R.World:
  data_84(initial, first)

def state_0(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_98(initial, first, input)

def state_1(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_104(initial, first, input)

def state_2(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_107(initial, first, input)

def state_3(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_110(initial, first, input)

def state_4(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_118(initial, first, input)

def state_5(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_121(initial, first, input)

def state_6(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_130(initial, first, input)

def state_7(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_135(initial, first, input)

def state_8(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_138(initial, first, input)

def state_9(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_141(initial, first, input)

def state_10(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_151(initial, first, input)

def state_11(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_154(initial, first, input)

def state_12(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_158(initial, first, input)

def state_13(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_164(initial, first, input)

def state_14(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_172(initial, first, input)

def state_15(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_174(initial, first, input)

def state_16(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_177(initial, first, input)

def state_17(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_182(initial, first, input)

def state_18(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_184(initial, first, input)

def state_19(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_187(initial, first, input)

def state_20(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_191(initial, first, input)

def state_21(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_196(initial, first, input)

def state_22(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_200(initial, first, input)

def state_23(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_205(initial, first, input)

def state_24(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_209(initial, first, input)

def state_25(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_215(initial, first, input)

def state_26(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_221(initial, first, input)

def state_27(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_225(initial, first, input)

def state_28(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_227(initial, first, input)

def state_29(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_229(initial, first, input)

def state_30(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_232(initial, first, input)

def state_31(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_234(initial, first, input)

def state_32(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_238(initial, first, input)

def state_33(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_241(initial, first, input)

def state_34(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_244(initial, first, input)

def state_35(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_246(initial, first, input)

def state_36(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_250(initial, first, input)

def state_37(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_253(initial, first, input)

def state_38(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_255(initial, first, input)

def state_39(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_258(initial, first, input)

def state_40(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  data_260(initial, first, input)

def finalWorld(+initial: Nat, +first: Nat, +input: Nat) -> R.World:
  data_256(initial, first, input)

# Isolate the actual publication helper to avoid re-expanding the entire
# pass-finally prefix during kernel conversion. This equation is checked.
def publication_13(+initial: Nat, +first: Nat, +input: Nat) ->
  {C.publishValue(C.world(state_13(initial, first, input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{})
    == B.Bundle{C.world(state_14(initial, first, input)), True{}} : B.Bundle<R.World, Bool>}:
  {==}
