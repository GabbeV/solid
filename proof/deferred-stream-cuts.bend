# Source operation transports only. Callers prove every intermediate equation;
# no successful post-state, callback outcome, or extra root premise is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/deferred-stream.bend as Stream
import ../runtime/deferred-runtime.bend as Deferred
import ../runtime/flight.bend as Flight
import ../runtime/iterator-state.bend as Iter
import ../runtime/from-state.bend as From

def wrapped(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+cell: Nat,+result: Nat,+node: Nat,+registered: R.World,
  healthy: {B.ok(w) == True{} : Bool},
  target: {R.DeferredCell.node(Deferred.cell(w,cell)) == node : Nat},
  registeredEq: {Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),node,result) == registered : R.World}) ->
  {C.deferredWrapped(rest,stack,cell,B.Bundle{w,result}) == C.consumeIterator(registered,C.DeferredAfterIterator{cell} <> rest,stack,node,result,result,False{},R.Undefined{}) : C.Machine}:
  Equal.trans(C.Machine,C.deferredWrapped(rest,stack,cell,B.Bundle{w,result}),C.consumeIterator(Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),R.DeferredCell.node(Deferred.cell(w,cell)),result),C.DeferredAfterIterator{cell} <> rest,stack,R.DeferredCell.node(Deferred.cell(w,cell)),result,result,False{},R.Undefined{}),C.consumeIterator(registered,C.DeferredAfterIterator{cell} <> rest,stack,node,result,result,False{},R.Undefined{}),
    Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.consumeIterator(Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),R.DeferredCell.node(Deferred.cell(w,cell)),result),C.DeferredAfterIterator{cell} <> rest,stack,R.DeferredCell.node(Deferred.cell(w,cell)),result,result,False{},R.Undefined{}),_=>C.Machine{w,rest,stack}),B.ok(w),True{},healthy),
    Equal.trans(C.Machine,C.consumeIterator(Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),R.DeferredCell.node(Deferred.cell(w,cell)),result),C.DeferredAfterIterator{cell} <> rest,stack,R.DeferredCell.node(Deferred.cell(w,cell)),result,result,False{},R.Undefined{}),C.consumeIterator(Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),node,result),C.DeferredAfterIterator{cell} <> rest,stack,node,result,result,False{},R.Undefined{}),C.consumeIterator(registered,C.DeferredAfterIterator{cell} <> rest,stack,node,result,result,False{},R.Undefined{}),
      Equal.cong(Nat,C.Machine,id=>C.consumeIterator(Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),id,result),C.DeferredAfterIterator{cell} <> rest,stack,id,result,result,False{},R.Undefined{}),R.DeferredCell.node(Deferred.cell(w,cell)),node,target),
      Equal.cong(R.World,C.Machine,next=>C.consumeIterator(next,C.DeferredAfterIterator{cell} <> rest,stack,node,result,result,False{},R.Undefined{}),Flight.startFlight(Deferred.ask(w,cell,Stream.flight(w,result)),node,result),registered,registeredEq)))

def created(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+node: Nat,+result: Nat,+after: R.World,+stream: Nat,
  ordinary: {From.factory(w,result) == False{} : Bool},
  made: {Iter.newStream(w,node,result,result,False{},R.Undefined{}) == B.Bundle{after,stream} : B.Bundle<R.World,Nat>},
  healthy: {B.ok(after) == True{} : Bool}) ->
  {C.consumeIterator(w,rest,stack,node,result,result,False{},R.Undefined{}) == C.attachIterator(after,rest,stack,node,stream,False{}) : C.Machine}:
  +pair = Iter.newStream(w,node,result,result,False{},R.Undefined{})
  +selected = Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.Machine{w,C.FromOpen{result} <> C.FromConsumeAcquired{node,result,False{},R.Undefined{}} <> rest,stack},_=>B.choose(~C.Machine,B.ok(B.first(R.World,Nat,pair)),_=>C.attachIterator(B.first(R.World,Nat,pair),rest,stack,node,B.second(R.World,Nat,pair),False{}),_=>C.Machine{B.first(R.World,Nat,pair),rest,stack})),From.factory(w,result),False{},ordinary)
  +substituted = Equal.cong(B.Bundle<R.World,Nat>,C.Machine,p=>B.choose(~C.Machine,B.ok(B.first(R.World,Nat,p)),_=>C.attachIterator(B.first(R.World,Nat,p),rest,stack,node,B.second(R.World,Nat,p),False{}),_=>C.Machine{B.first(R.World,Nat,p),rest,stack}),pair,B.Bundle{after,stream},made)
  Equal.trans(C.Machine,C.consumeIterator(w,rest,stack,node,result,result,False{},R.Undefined{}),B.choose(~C.Machine,B.ok(B.first(R.World,Nat,pair)),_=>C.attachIterator(B.first(R.World,Nat,pair),rest,stack,node,B.second(R.World,Nat,pair),False{}),_=>C.Machine{B.first(R.World,Nat,pair),rest,stack}),C.attachIterator(after,rest,stack,node,stream,False{}),selected,Equal.trans(C.Machine,B.choose(~C.Machine,B.ok(B.first(R.World,Nat,pair)),_=>C.attachIterator(B.first(R.World,Nat,pair),rest,stack,node,B.second(R.World,Nat,pair),False{}),_=>C.Machine{B.first(R.World,Nat,pair),rest,stack}),B.choose(~C.Machine,B.ok(after),_=>C.attachIterator(after,rest,stack,node,stream,False{}),_=>C.Machine{after,rest,stack}),C.attachIterator(after,rest,stack,node,stream,False{}),substituted,Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.attachIterator(after,rest,stack,node,stream,False{}),_=>C.Machine{after,rest,stack}),B.ok(after),True{},healthy)))

def launch(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+cell: Nat,+source: Nat,+after: R.World,+result: Nat,
  ordinary: {From.factory(w,source) == False{} : Bool},
  made: {Stream.wrap(w,cell,source) == B.Bundle{after,result} : B.Bundle<R.World,Nat>}) ->
  {C.deferredStream(w,rest,stack,cell,source) == C.deferredWrapped(rest,stack,cell,B.Bundle{after,result}) : C.Machine}:
  Equal.trans(C.Machine,C.deferredStream(w,rest,stack,cell,source),C.deferredWrapped(rest,stack,cell,Stream.wrap(w,cell,source)),C.deferredWrapped(rest,stack,cell,B.Bundle{after,result}),
    Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.Machine{w,C.FromOpen{source} <> C.FromDeferredAcquired{cell} <> rest,stack},_=>C.deferredWrapped(rest,stack,cell,Stream.wrap(w,cell,source))),From.factory(w,source),False{},ordinary),
    Equal.cong(B.Bundle<R.World,Nat>,C.Machine,p=>C.deferredWrapped(rest,stack,cell,p),Stream.wrap(w,cell,source),B.Bundle{after,result},made))
