# lanes.ts:heldBy. These walks call only pure blocker/cache helpers, so the
# captured row lists cannot change during them; source order and txOf stores
# are retained. They prove no global reachability or once-only invariant.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./transaction.bend as X
import ./pending-state.bend as P

def single(sources: R.SourceSet,reader: Nat) -> Bool:
  match sources:
    case R.Sources{head <> Nil{}}: Nat.is_eq(head,reader)
    case _: False{}

def members(rows: List<&2,Nat>,+w: R.World,+unit: Nat,+reader: Nat) -> B.Bundle<R.World,Bool>:
  match rows:
    case Nil{}: B.Bundle{w,True{}}
    case +node <> +rest:
      B.choose(~B.Bundle<R.World,Bool>,Bool.or(Nat.is_eq(node,reader),Bool.not(B.has(R.Node.status(B.node(w,node)),K.STATUS_PENDING()))),_=>members(rest,w,unit,reader),
        _=>
          +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(R.NodeExtension.transaction(B.extension(w,node)),0n),_=>B.Bundle{w,unit},_=>X.txOf(w,node))
          +w = B.first(R.World,Nat,pair)
          B.choose(~B.Bundle<R.World,Bool>,Nat.is_ne(B.second(R.World,Nat,pair),unit),_=>members(rest,w,unit,reader),
            _=>B.choose(~B.Bundle<R.World,Bool>,Bool.and(X.isRender(R.Node.kind(B.node(w,node))),single(B.pendingSources(w,node),reader)),_=>members(rest,w,unit,reader),_=>B.Bundle{w,False{}})))

def units(rows: List<&2,Nat>,+w: R.World,+tx: Nat,+reader: Nat) -> B.Bundle<R.World,Bool>:
  match rows:
    case Nil{}: B.Bundle{w,True{}}
    case +unit <> +rest:
      +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(unit,tx),_=>B.Bundle{w,tx},_=>X.resolveTx(w,R.Transaction.parent(B.transaction(w,unit))))
      +w = B.first(R.World,Nat,pair)
      B.choose(~B.Bundle<R.World,Bool>,Nat.is_ne(B.second(R.World,Nat,pair),tx),_=>units(rest,w,tx,reader),
        _=>
          +pair = B.choose(~B.Bundle<R.World,Bool>,Nat.is_eq(unit,tx),_=>B.Bundle{w,False{}},_=>X.guessFlights(w,unit))
          +w = B.first(R.World,Bool,pair)
          B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,pair),_=>B.Bundle{w,False{}},
            _=>
              +pair = members(R.Transaction.nodes(B.transaction(w,unit)),w,unit,reader)
              B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,pair),_=>units(rest,B.first(R.World,Bool,pair),tx,reader),_=>pair)))

def heldBy(+w: R.World,+tx: Nat,+reader: Nat) -> B.Bundle<R.World,Bool>:
  B.choose(~B.Bundle<R.World,Bool>,Nat.is_ne(R.Transaction.open(B.transaction(w,tx)),0n),_=>B.Bundle{w,False{}},
    _=>
      +pair = B.choose(~B.Bundle<R.World,Bool>,R.Transaction.lane(B.transaction(w,tx)),_=>X.linkBlocked(w,tx),_=>B.Bundle{w,False{}})
      +w = B.first(R.World,Bool,pair)
      B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,pair),_=>B.Bundle{w,False{}},_=>units(tx <> R.LaneState.live(R.World.laneState(w)),w,tx,reader)))
