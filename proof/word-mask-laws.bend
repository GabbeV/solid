# Word-level mask algebra for actual U32 status operations. The proofs recurse
# over the representation, rather than enumerating concrete status words.
import Base
import ../representation/base.bend as B

def andFalse(+a: Bool) -> {Bool.and(a,False{}) == False{} : Bool}:
  match a:
    case False{}: {==}
    case True{}: {==}

def andAssocBool(+a: Bool,+b: Bool,+c: Bool) -> {Bool.and(Bool.and(a,b),c) == Bool.and(a,Bool.and(b,c)) : Bool}:
  match a:
    case False{}: {==}
    case True{}: {==}

def andZero(+n: Nat,+a: Word(n)) -> {Word.and(n,a,Word.zero(n)) == Word.zero(n) : Word(n)}:
  match n:
    case 0n: {==}
    case 1n+p:
      match a:
        case WCon{+head,+tail}:
          Equal.trans(Word(1n+p),Word.and(1n+p,WCon{head,tail},Word.zero(1n+p)),WCon{False{},Word.and(p,tail,Word.zero(p))},Word.zero(1n+p),Equal.cong(Bool,Word(1n+p),bit=>WCon{bit,Word.and(p,tail,Word.zero(p))},Bool.and(head,False{}),False{},andFalse(head)),Equal.cong(Word(p),Word(1n+p),word=>WCon{False{},word},Word.and(p,tail,Word.zero(p)),Word.zero(p),andZero(p,tail)))

def andAssoc(+n: Nat,+a: Word(n),+b: Word(n),+c: Word(n)) -> {Word.and(n,Word.and(n,a,b),c) == Word.and(n,a,Word.and(n,b,c)) : Word(n)}:
  match n:
    case 0n: {==}
    case 1n+p:
      match a b c:
        case WCon{+ah,+at} WCon{+bh,+bt} WCon{+ch,+ct}:
          Equal.trans(Word(1n+p),Word.and(1n+p,Word.and(1n+p,WCon{ah,at},WCon{bh,bt}),WCon{ch,ct}),WCon{Bool.and(ah,Bool.and(bh,ch)),Word.and(p,Word.and(p,at,bt),ct)},Word.and(1n+p,WCon{ah,at},Word.and(1n+p,WCon{bh,bt},WCon{ch,ct})),Equal.cong(Bool,Word(1n+p),bit=>WCon{bit,Word.and(p,Word.and(p,at,bt),ct)},Bool.and(Bool.and(ah,bh),ch),Bool.and(ah,Bool.and(bh,ch)),andAssocBool(ah,bh,ch)),Equal.cong(Word(p),Word(1n+p),word=>WCon{Bool.and(ah,Bool.and(bh,ch)),word},Word.and(p,Word.and(p,at,bt),ct),Word.and(p,at,Word.and(p,bt,ct)),andAssoc(p,at,bt,ct)))


def u32AndZero(+a: U32) -> {U32.and(a,0) == 0 : U32}:
  match a:
    case U32{+word}: Equal.cong(Word(32n),U32,w=>U32{w},Word.and(32n,word,Word.zero(32n)),Word.zero(32n),andZero(32n,word))

def u32AndAssoc(+a: U32,+b: U32,+c: U32) -> {U32.and(U32.and(a,b),c) == U32.and(a,U32.and(b,c)) : U32}:
  match a b c:
    case U32{+aw} U32{+bw} U32{+cw}: Equal.cong(Word(32n),U32,w=>U32{w},Word.and(32n,Word.and(32n,aw,bw),cw),Word.and(32n,aw,Word.and(32n,bw,cw)),andAssoc(32n,aw,bw,cw))


def clearPendingMask(+flags: U32) -> {U32.and(B.clear(flags,1),1) == 0 : U32}:
  Equal.trans(U32,U32.and(B.clear(flags,1),1),U32.and(flags,U32.and(U32.not(1),1)),0,u32AndAssoc(flags,U32.not(1),1),u32AndZero(flags))

def clearPendingFalse(+flags: U32) -> {B.has(B.clear(flags,1),1) == False{} : Bool}:
  Equal.cong(U32,Bool,mask=>U32.is_ne(mask,0),U32.and(B.clear(flags,1),1),0,clearPendingMask(flags))

def andOrBool(+a: Bool,+b: Bool,+c: Bool) -> {Bool.and(Bool.or(a,b),c) == Bool.or(Bool.and(a,c),Bool.and(b,c)) : Bool}:
  match a b c:
    case False{} False{} False{}: {==}
    case False{} False{} True{}: {==}
    case False{} True{} False{}: {==}
    case False{} True{} True{}: {==}
    case True{} False{} False{}: {==}
    case True{} False{} True{}: {==}
    case True{} True{} False{}: {==}
    case True{} True{} True{}: {==}

def andOr(+n: Nat,+a: Word(n),+b: Word(n),+c: Word(n)) -> {Word.and(n,Word.or(n,a,b),c) == Word.or(n,Word.and(n,a,c),Word.and(n,b,c)) : Word(n)}:
  match n:
    case 0n: {==}
    case 1n+p:
      match a b c:
        case WCon{+ah,+at} WCon{+bh,+bt} WCon{+ch,+ct}:
          Equal.trans(Word(1n+p),Word.and(1n+p,Word.or(1n+p,WCon{ah,at},WCon{bh,bt}),WCon{ch,ct}),WCon{Bool.or(Bool.and(ah,ch),Bool.and(bh,ch)),Word.and(p,Word.or(p,at,bt),ct)},Word.or(1n+p,Word.and(1n+p,WCon{ah,at},WCon{ch,ct}),Word.and(1n+p,WCon{bh,bt},WCon{ch,ct})),Equal.cong(Bool,Word(1n+p),bit=>WCon{bit,Word.and(p,Word.or(p,at,bt),ct)},Bool.and(Bool.or(ah,bh),ch),Bool.or(Bool.and(ah,ch),Bool.and(bh,ch)),andOrBool(ah,bh,ch)),Equal.cong(Word(p),Word(1n+p),word=>WCon{Bool.or(Bool.and(ah,ch),Bool.and(bh,ch)),word},Word.and(p,Word.or(p,at,bt),ct),Word.or(p,Word.and(p,at,ct),Word.and(p,bt,ct)),andOr(p,at,bt,ct)))

def u32AndOr(+a: U32,+b: U32,+c: U32) -> {U32.and(U32.or(a,b),c) == U32.or(U32.and(a,c),U32.and(b,c)) : U32}:
  match a b c:
    case U32{+aw} U32{+bw} U32{+cw}: Equal.cong(Word(32n),U32,w=>U32{w},Word.and(32n,Word.or(32n,aw,bw),cw),Word.or(32n,Word.and(32n,aw,cw),Word.and(32n,bw,cw)),andOr(32n,aw,bw,cw))

def carryPendingMask(+flags: U32) -> {U32.and(U32.or(1,U32.and(flags,4)),1) == 1 : U32}:
  Equal.trans(U32,U32.and(U32.or(1,U32.and(flags,4)),1),U32.or(1,U32.and(U32.and(flags,4),1)),1,u32AndOr(1,U32.and(flags,4),1),Equal.cong(U32,U32,mask=>U32.or(1,mask),U32.and(U32.and(flags,4),1),0,Equal.trans(U32,U32.and(U32.and(flags,4),1),U32.and(flags,U32.and(4,1)),0,u32AndAssoc(flags,4,1),u32AndZero(flags))))

def carryErrorMask(+flags: U32) -> {U32.and(U32.or(1,U32.and(flags,4)),2) == 0 : U32}:
  Equal.trans(U32,U32.and(U32.or(1,U32.and(flags,4)),2),U32.or(0,U32.and(U32.and(flags,4),2)),0,u32AndOr(1,U32.and(flags,4),2),Equal.cong(U32,U32,mask=>U32.or(0,mask),U32.and(U32.and(flags,4),2),0,Equal.trans(U32,U32.and(U32.and(flags,4),2),U32.and(flags,U32.and(4,2)),0,u32AndAssoc(flags,4,2),u32AndZero(flags))))
