# src/map.ts trySmallMove/commitSmallMove, plain identity-keyed mode. Scan and
# ledgers are typed source locals; no mapper or cleanup runs before commit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arrays.bend as Arrays
import ./keyed-map.bend as KeyedMap

type ScanResult is Data:
  Bail{}
  Scanned{scan: R.SmallScan}
  Exhausted{}

type PairResult is Data:
  Unmatched{}
  Paired{scan: R.SmallScan, consumed: List<&2, Bool>}
  Overflow{}

def noPlan() -> R.SmallPlan:
  R.SmallPlan{False{}, [], [], []}

def containsWindow(+fuel: Nat, +w: R.World, +items: Nat, +key: R.Value, +index: Nat) -> Bool:
  match fuel:
    case 0n:
      False{}
    case 1n+rest:
      B.choose(~Bool, B.equal(Arrays.at(w, items, index), key), _ => True{}, _ => containsWindow(rest, w, items, key, 1n+index))

# updateKeyedMap's probe, before trySmallMove. end/newEnd are exclusive.
def probe(+w: R.World, +id: Nat, +newItems: Nat, +start: Nat, +end: Nat, +newEnd: Nat) -> Bool:
  +m = Nat.add(start, Nat.div(Nat.sub(Nat.sub(newEnd, start), 1n), 2n))
  +hi = Nat.min(Nat.sub(end, 1n), Nat.add(m, 32n))
  +k = Nat.max(start, Nat.sub(m, 32n))
  containsWindow(Nat.add(Nat.sub(hi, k), 1n), w, R.MapState.items(KeyedMap.get(w, id)), Arrays.at(w, newItems, m), k)

# Lookahead returns zero for source -1; every found distance starts at one.
def look(+fuel: Nat, +w: R.World, +items: Nat, +key: R.Value, +index: Nat, +distance: Nat) -> Nat:
  match fuel:
    case 0n:
      0n
    case 1n+rest:
      B.choose(~Nat, B.equal(Arrays.at(w, items, Nat.add(index, distance)), key), _ => distance, _ => look(rest, w, items, key, index, 1n+distance))

def range(+size: Nat, +start: Nat) -> List<&2, Nat>:
  match size:
    case 0n:
      []
    case 1n+rest:
      start <> range(rest, 1n+start)

# Tail loops retain the exact ==32 guards and append order.
def tails(+size: Nat, +start: Nat, +positions: List<&2, Nat>) -> B.Bundle<Bool, List<&2, Nat>>:
  match size:
    case 0n:
      B.Bundle{True{}, positions}
    case 1n+rest:
      B.choose(~B.Bundle<Bool, List<&2, Nat>>, Nat.is_eq(B.length(Nat, positions), 32n), _ => B.Bundle{False{}, positions}, _ => tails(rest, 1n+start, B.append(Nat, positions, [start])))

def finishTails(+scan: R.SmallScan, +oldLen: Nat, +newLen: Nat) -> ScanResult:
  +src = tails(Nat.sub(oldLen, R.SmallScan.i(scan)), R.SmallScan.i(scan), R.SmallScan.srcPos(scan))
  B.choose(~ScanResult, B.first(Bool, List<&2, Nat>, src),
    _ =>
      +scan = R.SmallScan.with_srcPos(scan, B.second(Bool, List<&2, Nat>, src))
      +dst = tails(Nat.sub(newLen, R.SmallScan.j(scan)), R.SmallScan.j(scan), R.SmallScan.dstPos(scan))
      B.choose(~ScanResult, B.first(Bool, List<&2, Nat>, dst), _ => Scanned{R.SmallScan.with_dstPos(scan, B.second(Bool, List<&2, Nat>, dst))}, _ => Bail{}),
    _ => Bail{})

# Structural recursion budget oldLen+newLen+1 bounds a scan which advances at
# least one cursor each iteration. Exhaustion is explicit, never a false probe.
def scanLoop(+fuel: Nat, +w: R.World, +oldItems: Nat, +newItems: Nat, +oldLen: Nat, +newLen: Nat, +scan: R.SmallScan) -> ScanResult:
  match fuel:
    case 0n:
      Exhausted{}
    case 1n+rest:
      +i = R.SmallScan.i(scan)
      +j = R.SmallScan.j(scan)
      B.choose(~ScanResult, Bool.and(Nat.is_lt(i, oldLen), Nat.is_lt(j, newLen)),
        _ =>
          +oldItem = Arrays.at(w, oldItems, i)
          +newItem = Arrays.at(w, newItems, j)
          B.choose(~ScanResult, B.equal(oldItem, newItem),
            _ =>
              +runs = B.choose(~List<&2, Nat>, R.SmallScan.inRun(scan), _ => R.SmallScan.runs(scan), _ => B.append(Nat, R.SmallScan.runs(scan), [i, j, 0n]))
              +last = Nat.sub(B.length(Nat, runs), 1n)
              +runs = B.put(Nat, runs, last, 0n, 1n+B.get(Nat, runs, last, 0n))
              +scan = R.SmallScan.with_runs(scan, runs)
              +scan = R.SmallScan.with_i(R.SmallScan.with_j(R.SmallScan.with_inRun(scan, True{}), 1n+j), 1n+i)
              scanLoop(rest, w, oldItems, newItems, oldLen, newLen, scan),
            _ =>
              +scan = R.SmallScan.with_inRun(scan, False{})
              +lim = Nat.min(Nat.min(Nat.sub(32n, B.length(Nat, R.SmallScan.srcPos(scan))), Nat.sub(Nat.sub(oldLen, 1n), i)), R.SmallScan.budget(scan))
              +del = look(lim, w, oldItems, newItem, i, 1n)
              +spent = B.choose(~Nat, Nat.is_eq(del, 0n), _ => lim, _ => del)
              +scan = R.SmallScan.with_budget(scan, Nat.sub(R.SmallScan.budget(scan), spent))
              +lim = Nat.min(Nat.min(Nat.sub(32n, B.length(Nat, R.SmallScan.dstPos(scan))), Nat.sub(Nat.sub(newLen, 1n), j)), R.SmallScan.budget(scan))
              +ins = look(lim, w, newItems, oldItem, j, 1n)
              +spent = B.choose(~Nat, Nat.is_eq(ins, 0n), _ => lim, _ => ins)
              +scan = R.SmallScan.with_budget(scan, Nat.sub(R.SmallScan.budget(scan), spent))
              B.choose(~ScanResult, Bool.and(Nat.is_ne(del, 0n), Bool.or(Nat.is_eq(ins, 0n), Nat.is_le(del, ins))),
                _ =>
                  +scan = R.SmallScan.with_srcPos(scan, B.append(Nat, R.SmallScan.srcPos(scan), range(del, i)))
                  scanLoop(rest, w, oldItems, newItems, oldLen, newLen, R.SmallScan.with_i(scan, Nat.add(i, del))),
                _ => B.choose(~ScanResult, Nat.is_ne(ins, 0n),
                  _ =>
                    +scan = R.SmallScan.with_dstPos(scan, B.append(Nat, R.SmallScan.dstPos(scan), range(ins, j)))
                    scanLoop(rest, w, oldItems, newItems, oldLen, newLen, R.SmallScan.with_j(scan, Nat.add(j, ins))),
                  _ => B.choose(~ScanResult, Bool.or(Nat.is_eq(R.SmallScan.budget(scan), 0n), Bool.or(Nat.is_eq(B.length(Nat, R.SmallScan.srcPos(scan)), 32n), Nat.is_eq(B.length(Nat, R.SmallScan.dstPos(scan)), 32n))),
                    _ => Bail{},
                    _ =>
                      +scan = R.SmallScan.with_srcPos(scan, B.append(Nat, R.SmallScan.srcPos(scan), [i]))
                      +scan = R.SmallScan.with_dstPos(scan, B.append(Nat, R.SmallScan.dstPos(scan), [j]))
                      scanLoop(rest, w, oldItems, newItems, oldLen, newLen, R.SmallScan.with_i(R.SmallScan.with_j(scan, 1n+j), 1n+i)))))),
        _ => finishTails(scan, oldLen, newLen))

# Source's packing uses signed JS <<6 and >>6. This profile refuses overflow
# rather than treating that operation as unbounded multiplication.
def fits(+bits: Nat, +n: Nat) -> Bool:
  match bits:
    case 0n:
      Nat.is_eq(n, 0n)
    case 1n+rest:
      fits(rest, Nat.div(n, 2n))

def falseSlots(+size: Nat) -> List<&2, Bool>:
  match size:
    case 0n:
      []
    case 1n+rest:
      False{} <> falseSlots(rest)

def findPair(+fuel: Nat, +w: R.World, +oldItems: Nat, +newItem: R.Value, +srcPos: List<&2, Nat>, +consumed: List<&2, Bool>, +index: Nat) -> R.MapIndex:
  match fuel:
    case 0n:
      R.MapMissing{}
    case 1n+rest:
      B.choose(~R.MapIndex, Bool.and(Bool.not(B.get(Bool, consumed, index, False{})), B.equal(Arrays.at(w, oldItems, B.get(Nat, srcPos, index, 0n)), newItem)),
        _ => R.MapAt{index}, _ => findPair(rest, w, oldItems, newItem, srcPos, consumed, 1n+index))

def pairIndex(+position: R.MapIndex) -> Nat:
  match position:
    case R.MapAt{index}:
      1n+index
    case other:
      0n

def pairLoops(+fuel: Nat, +w: R.World, +oldItems: Nat, +newItems: Nat, +scan: R.SmallScan, +consumed: List<&2, Bool>, +index: Nat) -> PairResult:
  match fuel:
    case 0n:
      Paired{scan, consumed}
    case 1n+rest:
      +p = B.get(Nat, R.SmallScan.dstPos(scan), index, 0n)
      +found = pairIndex(findPair(B.length(Nat, R.SmallScan.srcPos(scan)), w, oldItems, Arrays.at(w, newItems, p), R.SmallScan.srcPos(scan), consumed, 0n))
      B.choose(~PairResult, Nat.is_ne(found, 0n),
        _ => B.choose(~PairResult, fits(25n, p),
          _ =>
            +at = Nat.sub(found, 1n)
            +consumed = B.put(Bool, consumed, at, False{}, True{})
            +scan = R.SmallScan.with_dstPos(scan, B.put(Nat, R.SmallScan.dstPos(scan), index, 0n, Nat.add(Nat.mul(p, 64n), at)))
            pairLoops(rest, w, oldItems, newItems, scan, consumed, 1n+index),
          _ => Overflow{}),
        _ => Unmatched{})

# Set membership uses SameValueZero, as in the source duplicate safeguard.
def containsKey(+items: List<&2, R.Value>, +value: R.Value) -> Bool:
  match items:
    case Nil{}:
      False{}
    case item <> tail:
      B.choose(~Bool, KeyedMap.sameKey(item, value), _ => True{}, _ => containsKey(tail, value))

def insertKey(+items: List<&2, R.Value>, +value: R.Value) -> List<&2, R.Value>:
  B.choose(~List<&2, R.Value>, containsKey(items, value), _ => items, _ => B.append(R.Value, items, [value]))

def displacedSource(+positions: List<&2, Nat>, +w: R.World, +oldItems: Nat, +items: List<&2, R.Value>) -> List<&2, R.Value>:
  match positions:
    case Nil{}:
      items
    case position <> tail:
      displacedSource(tail, w, oldItems, insertKey(items, Arrays.at(w, oldItems, position)))

def displacedDestination(+positions: List<&2, Nat>, +w: R.World, +newItems: Nat, +items: List<&2, R.Value>) -> List<&2, R.Value>:
  match positions:
    case Nil{}:
      items
    case position <> tail:
      displacedDestination(tail, w, newItems, insertKey(items, Arrays.at(w, newItems, Nat.div(position, 64n))))

def runHasDisplaced(+size: Nat, +w: R.World, +oldItems: Nat, +start: Nat, +displaced: List<&2, R.Value>) -> Bool:
  match size:
    case 0n:
      False{}
    case 1n+rest:
      B.choose(~Bool, containsKey(displaced, Arrays.at(w, oldItems, start)), _ => True{}, _ => runHasDisplaced(rest, w, oldItems, 1n+start, displaced))

def duplicateRun(+runs: List<&2, Nat>, +w: R.World, +oldItems: Nat, +displaced: List<&2, R.Value>) -> Bool:
  match runs:
    case old <> next <> size <> tail:
      B.choose(~Bool, runHasDisplaced(size, w, oldItems, old, displaced), _ => True{}, _ => duplicateRun(tail, w, oldItems, displaced))
    case other:
      False{}

# copy aligned runs to sliced result/node arrays; captured originals stay fixed.
def copyRun(+size: Nat, +w: R.World, +oldMappings: Nat, +mappings: Nat, +oldNodes: List<&2, Nat>, +nodes: List<&2, Nat>, +old: Nat, +next: Nat) -> B.Bundle<R.World, List<&2, Nat>>:
  match size:
    case 0n:
      B.Bundle{w, nodes}
    case 1n+rest:
      +w = Arrays.put(w, mappings, next, Arrays.at(w, oldMappings, old))
      +nodes = B.put(Nat, nodes, next, 0n, B.get(Nat, oldNodes, old, 0n))
      copyRun(rest, w, oldMappings, mappings, oldNodes, nodes, 1n+old, 1n+next)

def copyRuns(+runs: List<&2, Nat>, +w: R.World, +oldMappings: Nat, +mappings: Nat, +oldNodes: List<&2, Nat>, +nodes: List<&2, Nat>) -> B.Bundle<R.World, List<&2, Nat>>:
  match runs:
    case old <> next <> size <> tail:
      +pair = B.choose(~B.Bundle<R.World, List<&2, Nat>>, Nat.is_eq(old, next), _ => B.Bundle{w, nodes}, _ => copyRun(size, w, oldMappings, mappings, oldNodes, nodes, old, next))
      copyRuns(tail, B.first(R.World, List<&2, Nat>, pair), oldMappings, mappings, oldNodes, B.second(R.World, List<&2, Nat>, pair))
    case other:
      B.Bundle{w, nodes}

def copyDisplaced(+positions: List<&2, Nat>, +w: R.World, +oldMappings: Nat, +mappings: Nat, +oldNodes: List<&2, Nat>, +nodes: List<&2, Nat>, +srcPos: List<&2, Nat>) -> B.Bundle<R.World, List<&2, Nat>>:
  match positions:
    case Nil{}:
      B.Bundle{w, nodes}
    case position <> tail:
      +p = Nat.div(position, 64n)
      +q = B.get(Nat, srcPos, Nat.mod(position, 64n), 0n)
      +w = Arrays.put(w, mappings, p, Arrays.at(w, oldMappings, q))
      +nodes = B.put(Nat, nodes, p, 0n, B.get(Nat, oldNodes, q, 0n))
      copyDisplaced(tail, w, oldMappings, mappings, oldNodes, nodes, srcPos)

def commit(+w: R.World, +id: Nat, +newItems: Nat, +newLen: Nat, +scan: R.SmallScan, +consumed: List<&2, Bool>) -> B.Bundle<R.World, R.SmallPlan>:
  +state = KeyedMap.get(w, id)
  +oldMappings = R.MapState.mappings(state)
  +oldNodes = R.MapState.nodes(state)
  +slice = Arrays.slice(w, oldMappings, 0n, newLen)
  +mappings = B.second(R.World, Nat, slice)
  +w = B.first(R.World, Nat, slice)
  +nodes = KeyedMap.takeNodes(newLen, oldNodes)
  +pair = copyRuns(R.SmallScan.runs(scan), w, oldMappings, mappings, oldNodes, nodes)
  +pair = copyDisplaced(R.SmallScan.dstPos(scan), B.first(R.World, List<&2, Nat>, pair), oldMappings, mappings, oldNodes, B.second(R.World, List<&2, Nat>, pair), R.SmallScan.srcPos(scan))
  +w = B.first(R.World, List<&2, Nat>, pair)
  +w = KeyedMap.store(w, id, R.MapState.with_mappings(KeyedMap.get(w, id), mappings))
  +w = KeyedMap.store(w, id, R.MapState.with_nodes(KeyedMap.get(w, id), B.second(R.World, List<&2, Nat>, pair)))
  +w = KeyedMap.store(w, id, R.MapState.with_len(KeyedMap.get(w, id), newLen))
  B.Bundle{KeyedMap.saveItems(w, id, newItems), R.SmallPlan{True{}, oldNodes, R.SmallScan.srcPos(scan), consumed}}

def paired(+w: R.World, +id: Nat, +newItems: Nat, +newLen: Nat, +pairs: PairResult) -> B.Bundle<R.World, R.SmallPlan>:
  match pairs:
    case Paired{+scan, consumed}:
      B.choose(~B.Bundle<R.World, R.SmallPlan>, Bool.or(Nat.is_ne(B.length(Nat, R.SmallScan.srcPos(scan)), 0n), Nat.is_ne(B.length(Nat, R.SmallScan.dstPos(scan)), 0n)),
        _ =>
          +oldItems = R.MapState.items(KeyedMap.get(w, id))
          +displaced = displacedSource(R.SmallScan.srcPos(scan), w, oldItems, [])
          +displaced = displacedDestination(R.SmallScan.dstPos(scan), w, newItems, displaced)
          B.choose(~B.Bundle<R.World, R.SmallPlan>, duplicateRun(R.SmallScan.runs(scan), w, oldItems, displaced), _ => B.Bundle{w, noPlan()}, _ => commit(w, id, newItems, newLen, scan, consumed)),
        _ => commit(w, id, newItems, newLen, scan, consumed))
    case Overflow{}:
      B.Bundle{R.World.with_fault(w, R.Unsupported{84n}), noPlan()}
    case Unmatched{}:
      B.Bundle{w, noPlan()}

def scanned(+w: R.World, +id: Nat, +newItems: Nat, +newLen: Nat, +result: ScanResult) -> B.Bundle<R.World, R.SmallPlan>:
  match result:
    case Scanned{+scan}:
      +dstLen = B.length(Nat, R.SmallScan.dstPos(scan))
      paired(w, id, newItems, newLen, pairLoops(dstLen, w, R.MapState.items(KeyedMap.get(w, id)), newItems, scan, B.choose(~List<&2, Bool>, Nat.is_ne(dstLen, 0n), _ => falseSlots(B.length(Nat, R.SmallScan.srcPos(scan))), _ => []), 0n))
    case Exhausted{}:
      B.Bundle{R.World.with_fault(w, R.Unsupported{85n}), noPlan()}
    case Bail{}:
      B.Bundle{w, noPlan()}

def trySmallMove(+w: R.World, +id: Nat, +newItems: Nat, +newLen: Nat, +start: Nat) -> B.Bundle<R.World, R.SmallPlan>:
  +state = KeyedMap.get(w, id)
  +oldLen = R.MapState.len(state)
  +scan = {R.SmallScan{[], [], [], 256n, start, start, False{}} : R.SmallScan}
  scanned(w, id, newItems, newLen, scanLoop(1n+Nat.add(oldLen, newLen), w, R.MapState.items(state), newItems, oldLen, newLen, scan))
