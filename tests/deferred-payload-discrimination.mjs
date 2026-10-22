// A domain-discrimination control: these payload-specific corruptions must
// remain invisible to the old natural-only proof and fail the broader proof.
// A failed numeric precondition is infrastructure failure, not a rejection.
import {spawnSync} from 'node:child_process';
const run=module=>spawnSync(process.execPath,['tests/proof-properties.mjs'],{
  env:{...process.env,BEND_PROOF_MODULE:module},encoding:'utf8',maxBuffer:1024*1024
});
const numeric=run('deferred-program');
if(numeric.status!==0)
  throw new Error('PROBE_PRECONDITION_FAILED: numeric control must still pass before testing the broader domain:\n'+numeric.stdout+'\n'+numeric.stderr);
const payload=run('deferred-payload-program');
process.stdout.write(payload.stdout);
process.stderr.write(payload.stderr);
if(payload.error||payload.signal||payload.status===null)
  throw new Error('Payload discrimination process failed: '+(payload.error?.message??payload.signal));
process.exit(payload.status);
