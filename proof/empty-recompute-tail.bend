# Recompute with no superseded staging/release tail selects the caller in both
# disposed/live arms. Collapse that selection in proofs, not in the runtime.
import Base
import ../runtime/core.bend as C
import ../runtime/constants.bend as K
import ../representation/records.bend as R
import ../representation/base.bend as B

def same(+rest: List<&2,C.Task>, flag: Bool) -> {B.choose(~List<&2,C.Task>,flag,_=>rest,_=>rest) == rest : List<&2,C.Task>}:
  match flag:
    case True{}: {==}
    case False{}: {==}

def resume(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+height: Nat,+value: R.Value) -> C.Machine:
  B.choose(~C.Machine,B.ok(w),_=>C.afterPass(w,B.choose(~List<&2,C.Task>,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_DISPOSED()),_=>rest,_=>rest),stack,id,False{},value,height,False{},R.Number{0n},0n,False{},False{},False{},False{},0n,False{}),_=>C.Machine{w,rest,stack})

def collapsed(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+height: Nat,+value: R.Value) ->
  {resume(w,rest,stack,id,height,value) == B.choose(~C.Machine,B.ok(w),_=>C.afterPass(w,rest,stack,id,False{},value,height,False{},R.Number{0n},0n,False{},False{},False{},False{},0n,False{}),_=>C.Machine{w,rest,stack}) : C.Machine}:
  Equal.cong(List<&2,C.Task>,C.Machine,caller=>B.choose(~C.Machine,B.ok(w),_=>C.afterPass(w,caller,stack,id,False{},value,height,False{},R.Number{0n},0n,False{},False{},False{},False{},0n,False{}),_=>C.Machine{w,rest,stack}),B.choose(~List<&2,C.Task>,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_DISPOSED()),_=>rest,_=>rest),rest,same(rest,B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_DISPOSED())))
