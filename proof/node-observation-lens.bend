# Projection-polymorphic list/storage lens, checked on the shared node arena.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def map(~A: Data,~project: R.Node -> A,nodes: List<&2,R.Node>) -> List<&2,A>:
  match nodes:
    case Nil{}: []
    case node <> tail: project(node) <> map(A,project,tail)

def set(~A: Data,~project: R.Node -> A,+nodes: List<&2,R.Node>,+id: Nat,+record: R.Node,same: {project(record) == project(B.get(R.Node,nodes,id,B.blank_node())) : A}) -> {map(A,project,List.set(&2,R.Node,nodes,id,record)) == map(A,project,nodes) : List<&2,A>}:
  match nodes id:
    case Nil{} n: {==}
    case head <> +tail 0n: Equal.cong(A,List<&2,A>,value=>value <> map(A,project,tail),project(record),project(head),same)
    case +head <> +tail 1n+p: Equal.cong(List<&2,A>,List<&2,A>,values=>project(head) <> values,map(A,project,List.set(&2,R.Node,tail,p,record)),map(A,project,tail),set(A,project,tail,p,record,same))

def read(~A: Data,~project: R.Node -> A,+nodes: List<&2,R.Node>,+id: Nat) -> {B.get(A,map(A,project,nodes),id,project(B.blank_node())) == project(B.get(R.Node,nodes,id,B.blank_node())) : A}:
  match nodes id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+p: read(A,project,tail,p)

def observe(~A: Data,~project: R.Node -> A,w: R.World) -> List<&2,A>:
  map(A,project,R.World.nodes(w))

def readWorld(~A: Data,~project: R.Node -> A,+a: R.World,+b: R.World,+id: Nat,same: {observe(A,project,b) == observe(A,project,a) : List<&2,A>}) -> {project(B.node(b,id)) == project(B.node(a,id)) : A}:
  Equal.trans(A,project(B.node(b,id)),B.get(A,observe(A,project,b),id,project(B.blank_node())),project(B.node(a,id)),Equal.sym(A,B.get(A,observe(A,project,b),id,project(B.blank_node())),project(B.node(b,id)),read(A,project,R.World.nodes(b),id)),Equal.trans(A,B.get(A,observe(A,project,b),id,project(B.blank_node())),B.get(A,observe(A,project,a),id,project(B.blank_node())),project(B.node(a,id)),Equal.cong(List<&2,A>,A,values=>B.get(A,values,id,project(B.blank_node())),observe(A,project,b),observe(A,project,a),same),read(A,project,R.World.nodes(a),id)))
