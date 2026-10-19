// Read-only numeric observation of the exact binary-natural representation.
export function decodeQuestion(value){
  if(value.$==='QuestionZero')return 0;
  if(value.$==='QuestionOdd')return 2*decodeQuestion(value.half)+1;
  if(value.$==='QuestionEven')return 2*decodeQuestion(value.half)+2;
  throw new TypeError('Unknown question representation');
}
