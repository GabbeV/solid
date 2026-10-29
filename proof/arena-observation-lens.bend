# Projection-preserving existing-slot stores for arbitrary persistent arenas.
import Base
import ../representation/base.bend as B

def map(~Input: Data,~Output: Data,~project: Input -> Output,rows: List<&2,Input>) -> List<&2,Output>:
  match rows:
    case Nil{}: []
    case head <> tail: project(head) <> map(Input,Output,project,tail)

def set(~Input: Data,~Output: Data,~project: Input -> Output,+rows: List<&2,Input>,+id: Nat,+record: Input,+fallback: Input,same: {project(record) == project(B.get(Input,rows,id,fallback)) : Output}) -> {map(Input,Output,project,List.set(&2,Input,rows,id,record)) == map(Input,Output,project,rows) : List<&2,Output>}:
  match rows id:
    case Nil{} n: {==}
    case head <> +tail 0n: Equal.cong(Output,List<&2,Output>,value=>value <> map(Input,Output,project,tail),project(record),project(head),same)
    case +head <> +tail 1n+p: Equal.cong(List<&2,Output>,List<&2,Output>,values=>project(head) <> values,map(Input,Output,project,List.set(&2,Input,tail,p,record)),map(Input,Output,project,tail),set(Input,Output,project,tail,p,record,fallback,same))

def read(~Input: Data,~Output: Data,~project: Input -> Output,+rows: List<&2,Input>,+id: Nat,+fallback: Input) -> {B.get(Output,map(Input,Output,project,rows),id,project(fallback)) == project(B.get(Input,rows,id,fallback)) : Output}:
  match rows id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+p: read(Input,Output,project,tail,p,fallback)
