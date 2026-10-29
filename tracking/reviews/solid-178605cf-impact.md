
> solid-signals-bend@0.1.0 upstream:impact
> node tools/upstream-impact.mjs /workspace/solid-next-178605cf

Baseline: Solid 2.0.0-rc.19 (ac28157aba6d03b806f0043bce70a87d515e953e).
Candidate: /workspace/solid-next-178605cf/packages/signals/src
Scope: signals src/**/*.ts; separately review tests, documentation, build conditions and initialization reachability
Correspondence and TS parity require review/revalidation. Existing Bend proofs remain about their pinned program, not this candidate.

changed: affects.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: boundaries.ts
  changed: boundaries.ts:boundarySeam -> [unported]; branch review required
  changed: boundaries.ts:catchStatus -> [unported]; branch review required
  changed: boundaries.ts:createBoundary -> [unported]; branch review required
  changed: boundaries.ts:fallback -> [unported]; branch review required
  changed: boundaries.ts:prune -> [unported]; branch review required
  added: boundaries.ts:reportOnAccessor -> [unported]; branch review required
  removed: boundaries.ts:unsettled -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/async.ts
  changed: core/async.ts:notifyStatus -> runtime/status.bend:notifyStatus, notifyStatusWith, storeStatus, Notify, wrapped; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
added: core/copies.ts
  added: core/copies.ts:checkForeignOwnerless -> [unported]; branch review required
  added: core/copies.ts:checkForeignRead -> [unported]; branch review required
  added: core/copies.ts:enterCopy -> [unported]; branch review required
  added: core/copies.ts:exitCopy -> [unported]; branch review required
  added: core/copies.ts:markCopyRooted -> [unported]; branch review required
  added: core/copies.ts:runAsSolidCopy -> [unported]; branch review required
  added: core/copies.ts:warnOnce -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/core.ts
  changed: core/core.ts:creatorPass -> [unported]; branch review required
  added: core/core.ts:devRead -> [unported]; branch review required
  changed: core/core.ts:read -> runtime/core.bend:readNode, readPrepared, readSignalFast, prepareSlow, serve; runtime/core.bend:readStatus, afterServe; runtime/core.bend:readStatus, readPendingStatus, readLaneValue, readLaneDone; branch review required
  changed: core/core.ts:recompute -> runtime/core.bend:LanePass, PassFrame, seatPass, passValue, recomputeFlight, recomputeAfterFlight, recomputeAfterTeardown, recomputePrepared, catchStatus, catchPass, startPassFinally, passFinallyBody, passFinallyTail, joinedPass, restoreMount, PassReleases, afterPass, PassLaneStage, stagePassAt, stagePass, publishState, publicationChanged, publishCompared, markPublishedEffectAs, publishStoresAs, PublishOutcome, publicationCompleted, retireOutgoing, FinishPublication, QueuePublication, queuePublicationIn, AfterDeadPass; existing flight/iterator/owner/pending continuations remain shared; runtime/transaction.bend:reenterHeld; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/dev.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/effect.ts
  changed: core/effect.ts:effect -> runtime/api.bend:createEffectWithHandlers, nestedEffect; runtime/core.bend:evaluate(EffectCreate), InitialEffect; branch review required
  changed: core/effect.ts:runEffect -> runtime/core.bend:runEffect, effectCatch, userError, errorArmCatch, applyEffect, effectFinally, ApplyEffect, InstallEffectCleanup, EffectFinally, ErrorArmFinally, installReturned, InstallReturnedCleanup, OwnerTasks, TrimFinallyRestore; runtime/callable.bend:cleanupAccessor, encodeAccessor, findAccessor, boundAccessor; runtime/core.bend:callbackAction CleanupBoundAccessor, ReadNode; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/lanes.ts
  changed: core/lanes.ts:endLanes -> runtime/core.bend:endLanes, endLanesLoop; branch review required
  changed: core/lanes.ts:enterLane -> runtime/lanes-state.bend:enterLane; branch review required
  changed: core/lanes.ts:inFlight -> runtime/transaction.bend:laneInFlight; runtime/lanes-state.bend:inFlight; branch review required
  changed: core/lanes.ts:laneCorrections -> runtime/core.bend:laneCorrections, laneCorrectionsLoop, laneCorrectionNodes, LaneCorrectionCompared; branch review required
  changed: core/lanes.ts:laneRead -> runtime/core.bend:laneRead, laneReadReader, laneReadRender, laneReadOutside, laneReadRenderEnd, laneReadEnter, laneReadEntered; branch review required
  changed: core/lanes.ts:laneSeams -> runtime/core.bend:laneSeams, laneLeakLoop, laneLeakAdmit, laneRevealLoop, laneEnteredLoop, laneEnteredPop; runtime/lanes-state.bend:enteredPrefix; branch review required
  changed: core/lanes.ts:laneStage -> runtime/lanes-state.bend:laneStage, leaveStage, leaveStageEnd, clearStageConfig, computationStage, effectStage, framePending, hasStageLane; StageError retains false/true/source forms; branch review required
  changed: core/lanes.ts:laneWrite -> runtime/core.bend:laneWrite, laneWriteChanged, LaneWriteCompared, LaneWriteDone; branch review required
  changed: core/lanes.ts:optimisticWrite -> runtime/core.bend:optimisticWrite, optimisticResolved, OptimisticResolved, OptimisticCompared; runtime/lanes-state.bend:pushGuess; branch review required
  added: core/lanes.ts:rerun -> [unported]; branch review required
  changed: core/lanes.ts:supersede -> runtime/core.bend:supersede, supersedeAfter, supersedeEnd; branch review required
  added: core/lanes.ts:take -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/owner.ts
  changed: core/owner.ts:createRoot -> runtime/api.bend:createRoot; runtime/core.bend:evaluate RootScope, RestoreContext; runtime/owner-state.bend:createOwner; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/scheduler.ts
  added: core/scheduler.ts:armGuessing -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: core/verdict.ts
  changed: core/verdict.ts:heldLatest -> runtime/verdict-state.bend:heldLatest; branch review required
  changed: core/verdict.ts:markVerdictReader -> runtime/verdict-state.bend:markVerdictReader; branch review required
  changed: core/verdict.ts:pendingVerdict -> runtime/verdict-state.bend:pendingVerdict; branch review required
  changed: core/verdict.ts:provisionalVerdict -> runtime/verdict-state.bend:provisionalVerdict; branch review required
  changed: core/verdict.ts:quietPending -> runtime/verdict-state.bend:quietPending, quietSources, reasks; branch review required
  changed: core/verdict.ts:route -> runtime/verdict-state.bend:route; branch review required
  changed: core/verdict.ts:verdictValue -> runtime/core.bend:verdictValue, verdictAfterPull, verdictOverride, verdictGuessValue, VerdictGuessCompared, verdictPlain, verdictHeld, VerdictHeldFinal, verdictHeldValue, verdictStaging, verdictTerminal, verdictBundle, VerdictPulled, VerdictRaiseHeight; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: index.ts
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: map.ts
  changed: map.ts:updateKeyedMap -> runtime/keyed-map.bend:updateParent, clear, frame, prepareIndices, saveItems, publishInitial, publishWindow; runtime/core.bend:mapRead, mapBegin, mapListValue, mapEmptyBody, mapFallbackCreate, mapRows, mapInvokeRow, mapInvokeIndex, mapMapped, mapAbort, mapPrefix, mapSuffix, mapPrepareStart, mapPrepare, mapPrepared, mapOld, mapOldPosition, mapRemoval, mapInitialCommit, mapCommitPrefix, mapWindow, mapWindowRows, mapWindowSuffix, mapRemoved; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/hooks.ts [store excluded; shared-hook review still required]
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/optimistic.ts [store excluded; shared-hook review still required]
  changed: store/optimistic.ts:arrangement -> [unported]; branch review required
  changed: store/optimistic.ts:arrangementEqual -> [unported]; branch review required
  removed: store/optimistic.ts:carriesLane -> [unported]; branch review required
  added: store/optimistic.ts:laneNodeOf -> [unported]; branch review required
  added: store/optimistic.ts:nodesOf -> [unported]; branch review required
  changed: store/optimistic.ts:rebaseChained -> [unported]; branch review required
  changed: store/optimistic.ts:rowSame -> [unported]; branch review required
  added: store/optimistic.ts:sameAction -> [unported]; branch review required
  changed: store/optimistic.ts:sweepOverlaid -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/projection.ts [store excluded; shared-hook review still required]
  changed: store/projection.ts:runProjectionComputed -> [unported]; branch review required
  changed: store/projection.ts:settleFamily -> [unported]; branch review required
  changed: store/projection.ts:wakeFamily -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/reconcile.ts [store excluded; shared-hook review still required]
  changed: store/reconcile.ts:applyAdopt -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/store.ts [store excluded; shared-hook review still required]
  changed: store/store.ts:cloneRaw -> [unported]; branch review required
  changed: store/store.ts:get -> [unported]; branch review required
  changed: store/store.ts:nodeValue -> [unported]; branch review required
  changed: store/store.ts:notifyFoldTail -> [unported]; branch review required
  changed: store/store.ts:notifyKeyDiff -> [unported]; branch review required
  changed: store/store.ts:pullFamily -> [unported]; branch review required
  changed: store/store.ts:storePark -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/target.ts [store excluded; shared-hook review still required]
  No indexed function-text change; inspect file-level changes.
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
changed: store/types.ts [store excluded; shared-hook review still required]
  added: store/types.ts:installShallowView -> [unported]; branch review required
  Review imports, fields, flags, module initializers, comments and unindexed operations as well as named functions.
