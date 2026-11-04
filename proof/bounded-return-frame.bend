# Committed-content composition for constructed actual returns.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./bounded-core-return.bend as Return
import ./committed-storage-frame.bend as Frame

def prepend(+before: C.Machine, +middle: C.Machine, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +length: Nat, +maximum: Nat,
  +prefix: {Steps.iterate(length, before) == middle : C.Machine}, +result: Return.Returned<middle, rest, stack, maximum>,
  firstFrame: {Frame.observe(C.world(middle)) == Frame.observe(C.world(before)) : Frame.View}, lastFrame: {Frame.observe(Return.world(middle, rest, stack, maximum, result)) == Frame.observe(C.world(middle)) : Frame.View}) ->
  {Frame.observe(Return.world(before, rest, stack, Nat.add(length, maximum), Return.prepend(before, middle, rest, stack, length, maximum, prefix, result))) == Frame.observe(C.world(before)) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(Return.world(before, rest, stack, Nat.add(length, maximum), Return.prepend(before, middle, rest, stack, length, maximum, prefix, result))), Frame.observe(Return.world(middle, rest, stack, maximum, result)), Frame.observe(C.world(before)),
    Equal.cong(R.World, Frame.View, world => Frame.observe(world), Return.world(before, rest, stack, Nat.add(length, maximum), Return.prepend(before, middle, rest, stack, length, maximum, prefix, result)), Return.world(middle, rest, stack, maximum, result), Return.prependWorld(before, middle, rest, stack, length, maximum, prefix, result)),
    Frame.compose(C.world(before), C.world(middle), Return.world(middle, rest, stack, maximum, result), lastFrame, firstFrame))

# Widening a source control bound keeps the exact returned World.
def widen(+before: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+maximum: Nat,+extra: Nat,+result: Return.Returned<before,rest,stack,maximum>,frame: {Frame.observe(Return.world(before,rest,stack,maximum,result)) == Frame.observe(C.world(before)) : Frame.View}) -> {Frame.observe(Return.world(before,rest,stack,Nat.add(maximum,extra),Return.widen(before,rest,stack,maximum,extra,result))) == Frame.observe(C.world(before)) : Frame.View}:
  Equal.trans(Frame.View,Frame.observe(Return.world(before,rest,stack,Nat.add(maximum,extra),Return.widen(before,rest,stack,maximum,extra,result))),Frame.observe(Return.world(before,rest,stack,maximum,result)),Frame.observe(C.world(before)),Equal.cong(R.World,Frame.View,world=>Frame.observe(world),Return.world(before,rest,stack,Nat.add(maximum,extra),Return.widen(before,rest,stack,maximum,extra,result)),Return.world(before,rest,stack,maximum,result),Return.widenWorld(before,rest,stack,maximum,extra,result)),frame)
