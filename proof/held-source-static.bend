# Heap facts needed when a real transaction join changes the source group.
# Group/cache/selector facts are deliberately separate and must be supplied by
# the actual allocation/join operation, not inferred from this static view.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

type View is Data:
  Static{nodes: List<&2,R.Node>,links: List<&2,R.Link>,extensionLength: Nat,comparators: List<&2,R.ComparatorBinding>,fault: R.Fault,marked: Bool,context: Nat}

def observe(+w: R.World) -> View:
  Static{R.World.nodes(w),R.World.links(w),B.length(R.NodeExtension,R.World.extensions(w)),R.World.comparators(w),R.World.fault(w),R.World.marked(w),R.World.context(w)}

def nodes(view: View) -> List<&2,R.Node>:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: nodes

def sameNodes(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>}:
  Equal.cong(View,List<&2,R.Node>,view=>nodes(view),observe(next),observe(w),same)

def links(view: View) -> List<&2,R.Link>:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: links

def sameLinks(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}:
  Equal.cong(View,List<&2,R.Link>,view=>links(view),observe(next),observe(w),same)

def extensionLength(view: View) -> Nat:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: extensionLength

def sameExtensionLength(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {B.length(R.NodeExtension,R.World.extensions(next)) == B.length(R.NodeExtension,R.World.extensions(w)) : Nat}:
  Equal.cong(View,Nat,view=>extensionLength(view),observe(next),observe(w),same)

def comparators(view: View) -> List<&2,R.ComparatorBinding>:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: comparators

def sameComparators(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  Equal.cong(View,List<&2,R.ComparatorBinding>,view=>comparators(view),observe(next),observe(w),same)

def fault(view: View) -> R.Fault:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: fault

def sameFault(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.fault(next) == R.World.fault(w) : R.Fault}:
  Equal.cong(View,R.Fault,view=>fault(view),observe(next),observe(w),same)

def marked(view: View) -> Bool:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: marked

def sameMarked(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.marked(next) == R.World.marked(w) : Bool}:
  Equal.cong(View,Bool,view=>marked(view),observe(next),observe(w),same)

def context(view: View) -> Nat:
  match view:
    case Static{nodes,links,extensionLength,comparators,fault,marked,context}: context

def sameContext(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : View}) -> {R.World.context(next) == R.World.context(w) : Nat}:
  Equal.cong(View,Nat,view=>context(view),observe(next),observe(w),same)
