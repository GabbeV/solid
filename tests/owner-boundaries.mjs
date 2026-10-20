import assert from 'node:assert/strict';
import {ownerBoundaries} from '../tools/owner-boundaries.mjs';
const report=ownerBoundaries();
assert.ok(report.coreUnbridgedCalls.some(call=>call.target==='flight:asyncWrite'),'asyncWrite remains an explicit pending migration');
assert.ok(report.coreUnbridgedCalls.some(call=>call.target==='pending:stageError'),'staged-error settlement remains an explicit pending migration');
assert.ok(!report.coreUnbridgedCalls.some(call=>call.target==='scheduler:settle'||call.target==='scheduler:commitPendingNode'),'active scheduler calls must retain their core continuations');
assert.ok(!report.directRestrictedCalls.some(call=>call.from.startsWith('signals:')),'native watch/until disposal must retain the owner/core bridge');
assert.ok(!report.coreUnbridgedCalls.some(call=>call.from==='core:recomputeAfterFlight'),'callback-free parking is not a user invocation');
console.log(`Owner-boundary inventory locates ${report.coreUnbridgedCalls.length} remaining core World-helper calls and preserves the migrated scheduler/trim distinction.`);
