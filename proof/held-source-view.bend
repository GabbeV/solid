# Profile-sufficient source observation across actor/question/debt boundaries.
# Counts are deliberately tracked by separate retirement theorems, not hidden
# inside a claim that this view preserves debt or the whole World.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def intos(rows: List<&2,R.Transaction>) -> List<&2,Nat>:
  match rows:
    case Nil{}: []
    case head <> tail: R.Transaction.into(head) <> intos(tail)

def intoLength(+rows: List<&2,R.Transaction>) -> {B.length(Nat,intos(rows)) == B.length(R.Transaction,rows) : Nat}:
  match rows:
    case Nil{}: {==}
    case head <> +tail:
      Equal.cong(Nat,Nat,n=>1n+n,B.length(Nat,intos(tail)),B.length(R.Transaction,tail),intoLength(tail))

def intoRead(+rows: List<&2,R.Transaction>,+id: Nat) -> {B.get(Nat,intos(rows),id,0n) == R.Transaction.into(B.get(R.Transaction,rows,id,B.blank_transaction())) : Nat}:
  match rows id:
    case Nil{} at: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+at: intoRead(tail,at)

type View is Data:
  Source{nodes: List<&2,R.Node>,links: List<&2,R.Link>,extensions: List<&2,R.NodeExtension>,comparators: List<&2,R.ComparatorBinding>,fault: R.Fault,marked: Bool,context: Nat,future: Nat,intos: List<&2,Nat>}

def observe(+w: R.World) -> View:
  Source{R.World.nodes(w),R.World.links(w),R.World.extensions(w),R.World.comparators(w),R.World.fault(w),R.World.marked(w),R.World.context(w),R.World.flushTransaction(w),intos(R.World.txArena(w))}

def nodes(view: View) -> List<&2,R.Node>:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: nodes

def sameNodes(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>}:
  Equal.cong(View,List<&2,R.Node>,view=>nodes(view),observe(next),observe(w),same)

def links(view: View) -> List<&2,R.Link>:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: links

def sameLinks(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}:
  Equal.cong(View,List<&2,R.Link>,view=>links(view),observe(next),observe(w),same)

def extensions(view: View) -> List<&2,R.NodeExtension>:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: extensions

def sameExtensions(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.extensions(next) == R.World.extensions(w) : List<&2,R.NodeExtension>}:
  Equal.cong(View,List<&2,R.NodeExtension>,view=>extensions(view),observe(next),observe(w),same)

def comparators(view: View) -> List<&2,R.ComparatorBinding>:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: comparators

def sameComparators(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  Equal.cong(View,List<&2,R.ComparatorBinding>,view=>comparators(view),observe(next),observe(w),same)

def fault(view: View) -> R.Fault:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: fault

def sameFault(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.fault(next) == R.World.fault(w) : R.Fault}:
  Equal.cong(View,R.Fault,view=>fault(view),observe(next),observe(w),same)

def marked(view: View) -> Bool:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: marked

def sameMarked(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.marked(next) == R.World.marked(w) : Bool}:
  Equal.cong(View,Bool,view=>marked(view),observe(next),observe(w),same)

def context(view: View) -> Nat:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: context

def sameContext(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.context(next) == R.World.context(w) : Nat}:
  Equal.cong(View,Nat,view=>context(view),observe(next),observe(w),same)

def future(view: View) -> Nat:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: future

def sameFuture(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.flushTransaction(next) == R.World.flushTransaction(w) : Nat}:
  Equal.cong(View,Nat,view=>future(view),observe(next),observe(w),same)

def routes(view: View) -> List<&2,Nat>:
  match view:
    case Source{nodes,links,extensions,comparators,fault,marked,context,future,intos}: intos

def sameInto(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : View}) -> {R.Transaction.into(B.transaction(next,id)) == R.Transaction.into(B.transaction(w,id)) : Nat}:
  Equal.trans(Nat,R.Transaction.into(B.transaction(next,id)),B.get(Nat,intos(R.World.txArena(next)),id,0n),R.Transaction.into(B.transaction(w,id)),Equal.sym(Nat,B.get(Nat,intos(R.World.txArena(next)),id,0n),R.Transaction.into(B.transaction(next,id)),intoRead(R.World.txArena(next),id)),Equal.trans(Nat,B.get(Nat,intos(R.World.txArena(next)),id,0n),B.get(Nat,intos(R.World.txArena(w)),id,0n),R.Transaction.into(B.transaction(w,id)),Equal.cong(View,Nat,view=>B.get(Nat,routes(view),id,0n),observe(next),observe(w),same),intoRead(R.World.txArena(w),id)))

def sameGroupArenaSize(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {B.length(R.Transaction,R.World.txArena(next)) == B.length(R.Transaction,R.World.txArena(w)) : Nat}:
  Equal.trans(Nat,B.length(R.Transaction,R.World.txArena(next)),B.length(Nat,intos(R.World.txArena(next))),B.length(R.Transaction,R.World.txArena(w)),Equal.sym(Nat,B.length(Nat,intos(R.World.txArena(next))),B.length(R.Transaction,R.World.txArena(next)),intoLength(R.World.txArena(next))),Equal.trans(Nat,B.length(Nat,intos(R.World.txArena(next))),B.length(Nat,intos(R.World.txArena(w))),B.length(R.Transaction,R.World.txArena(w)),Equal.cong(View,Nat,view=>B.length(Nat,routes(view)),observe(next),observe(w),same),intoLength(R.World.txArena(w))))

def assemble(+left: View,+right: View,nodesEq: {nodes(left) == nodes(right) : List<&2,R.Node>},linksEq: {links(left) == links(right) : List<&2,R.Link>},extensionsEq: {extensions(left) == extensions(right) : List<&2,R.NodeExtension>},comparatorsEq: {comparators(left) == comparators(right) : List<&2,R.ComparatorBinding>},faultEq: {fault(left) == fault(right) : R.Fault},markedEq: {marked(left) == marked(right) : Bool},contextEq: {context(left) == context(right) : Nat},futureEq: {future(left) == future(right) : Nat},routesEq: {routes(left) == routes(right) : List<&2,Nat>}) -> {left == right : View}:
  match left right:
    case Source{+a0,+a1,+a2,+a3,+a4,+a5,+a6,+a7,+a8} Source{+b0,+b1,+b2,+b3,+b4,+b5,+b6,+b7,+b8}:
      Equal.trans(View,Source{a0,a1,a2,a3,a4,a5,a6,a7,a8},Source{b0,a1,a2,a3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(List<&2,R.Node>,View,value=>Source{value,a1,a2,a3,a4,a5,a6,a7,a8},a0,b0,nodesEq),Equal.trans(View,Source{b0,a1,a2,a3,a4,a5,a6,a7,a8},Source{b0,b1,a2,a3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(List<&2,R.Link>,View,value=>Source{b0,value,a2,a3,a4,a5,a6,a7,a8},a1,b1,linksEq),Equal.trans(View,Source{b0,b1,a2,a3,a4,a5,a6,a7,a8},Source{b0,b1,b2,a3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(List<&2,R.NodeExtension>,View,value=>Source{b0,b1,value,a3,a4,a5,a6,a7,a8},a2,b2,extensionsEq),Equal.trans(View,Source{b0,b1,b2,a3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(List<&2,R.ComparatorBinding>,View,value=>Source{b0,b1,b2,value,a4,a5,a6,a7,a8},a3,b3,comparatorsEq),Equal.trans(View,Source{b0,b1,b2,b3,a4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(R.Fault,View,value=>Source{b0,b1,b2,b3,value,a5,a6,a7,a8},a4,b4,faultEq),Equal.trans(View,Source{b0,b1,b2,b3,b4,a5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(Bool,View,value=>Source{b0,b1,b2,b3,b4,value,a6,a7,a8},a5,b5,markedEq),Equal.trans(View,Source{b0,b1,b2,b3,b4,b5,a6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(Nat,View,value=>Source{b0,b1,b2,b3,b4,b5,value,a7,a8},a6,b6,contextEq),Equal.trans(View,Source{b0,b1,b2,b3,b4,b5,b6,a7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,a8},Source{b0,b1,b2,b3,b4,b5,b6,b7,b8},Equal.cong(Nat,View,value=>Source{b0,b1,b2,b3,b4,b5,b6,value,a8},a7,b7,futureEq),Equal.cong(List<&2,Nat>,View,value=>Source{b0,b1,b2,b3,b4,b5,b6,b7,value},a8,b8,routesEq)))))))))
