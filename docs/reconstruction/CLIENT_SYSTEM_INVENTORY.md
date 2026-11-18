# Client system inventory

Target: extracted APK Lua source. Parsed 528 GameMgr Lua modules, 162 protocol Lua files, 1024 command constants (374 client request definitions), and 16049 asset files.

The inventory below maps source entry points by shipped directory. Presence does not imply a working server implementation or runtime feature. See `protocol_registry.json` and `IMPLEMENTATION_BACKLOG.md` for coverage.

| Client subsystem | Lua modules | Protocol send calls found | Config symbols found | Server/runtime status |
|---|---:|---:|---:|---|
| `Activity` | 3 | 9 | 3 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Animation3DMgr.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `AnimationMgr.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Battle` | 147 | 11 | 6 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `CSResourceMgr.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `ChainMan` | 1 | 0 | 1 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Chat` | 6 | 12 | 2 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `CocosModuleMgr.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Common` | 17 | 25 | 7 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `CommonDungeon` | 3 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Confraternity` | 2 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Data` | 28 | 59 | 22 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `DebugInfoMgr.lua` | 1 | 0 | 3 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `GameInit.lua` | 1 | 0 | 13 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `GameLogMgr.lua` | 1 | 2 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Item` | 38 | 62 | 9 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `LostTower` | 23 | 23 | 5 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Map` | 21 | 13 | 8 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Mission` | 7 | 9 | 4 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `ObjectPool.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `OrderMan` | 3 | 3 | 2 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Pet` | 47 | 25 | 10 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Player` | 74 | 99 | 11 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `PlistMgr.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `ProtoErrorTransferText.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Searching` | 20 | 20 | 8 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Support` | 27 | 3 | 4 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `TaskWatcher` | 44 | 2 | 2 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `UIStack.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `Update` | 3 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `ViewMgrUtils.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `login.lua` | 1 | 2 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |
| `platformCfg.lua` | 1 | 0 | 0 | Source inventoried; backend/Waydroid coverage requires per-feature verification |

## Module-by-module index

| Source | Subsystem | Protocol calls | Lua dependencies | Config references |
|---|---|---|---|---|
| `decoded_lua/assets/src/GameMgr/Activity/ActivityShopViewMgr.lua` | `Activity` | `sendCG_GetCharacterValues_Req`, `sendCG_GetSelfActivityShopData_Req` | `src.Net.Send.ActivitySend`, `src.Net.Send.LoginSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Activity/SurviveBattleViewMgr.lua` | `Activity` | `sendCG_GetCharacterValues_Req`, `sendCG_GetSurvivalBattleData_Req`, `sendCG_SurvivalBattleEnd_Req` | `src.Net.Send.ActivitySend`, `src.Net.Send.LoginSend` | `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Activity/expeditionalViewMgr.lua` | `Activity` | `sendCG_BuyRollCount_Req`, `sendCG_ExpeditionBattleEnd_Req`, `sendCG_GetExpeditionData_Req`, `sendCG_GetPointLotteryData_Req`, `sendCG_RollDice_Req` | `src.GameMgr.Battle.BattleGetPetInfo`, `src.GameMgr.Data.ExpeditionalInfo`, `src.Net.Send.ExpeditionSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Animation3DMgr.lua` | `Animation3DMgr.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/AnimationMgr.lua` | `AnimationMgr.lua` | — | `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleAidFunc.lua` | `Battle` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleBasicValueCalc.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleBuffer.lua` | `Battle` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleBufferUI.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleCANI.lua` | `Battle` | — | `src.GameMgr.Battle.UI.BattleLangDB` | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleCCSB.lua` | `Battle` | `sendCG_BuyMarketItem_Req`, `sendCG_PVEPokemonCatch_Req` | `src.GameMgr.Battle.BattleCotroller`, `src.GameMgr.Battle.BattleGetPetInfo`, `src.GameMgr.Battle.BattleLoadRes`, `src.GameMgr.Battle.BattleWeather`, `src.GameMgr.Battle.UI.BattleLangDB`, `src.GameMgr.Pet.PetFeedViewMgr`, `src.GameMgr.Searching.AdvFailedView`, `src.Net.Send.MarketSend`, `src.Net.Send.PVESend` | `ExperienceInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleCotroller.lua` | `Battle` | — | `src.Utils.GenUtils` | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleFuncMgr.lua` | `Battle` | — | `src.GameMgr.Battle.type_damage`, `src.framework.cc.uiloader.CCSUILoader` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleGetPetInfo.lua` | `Battle` | — | — | `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleGuide.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleLabelAtlas.lua` | `Battle` | — | `src.framework.cc.uiloader.CCSUILoader` | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleLoadRes.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleMgr.lua` | `Battle` | — | `Utils.GenUtils`, `src.GameMgr.Battle.type_damage` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattlePVPMgr.lua` | `Battle` | `sendCG_GetCharacterValues_Req`, `sendCG_GetFriendDetail_Req`, `sendCG_GetPVPRecords_Req`, `sendCG_JoinPVP_Req`, `sendCG_LeavePVP_Req`, `sendCG_PVPBattleCommand_Req`, `sendCG_PVPBattleStart_Req`, `sendCG_ReadyPVP_Req`, `sendCG_StartPVP_Req` | `cjson`, `src.GameMgr.Battle.UI.PVPDailog`, `src.GameMgr.Battle.UI.PVPDetail`, `src.Net.Send.ChatUserSend`, `src.Net.Send.LoginSend`, `src.Net.Send.PVPSend`, `src.Net.Send.PVPSend.lua` | `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattlePassiveSkills.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BattleSkill.lua` | `Battle` | — | `src.GameMgr.Battle.type_damage` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleUIMgr.lua` | `Battle` | — | `src.GameMgr.Battle.BattleGetPetInfo`, `src.GameMgr.Battle.BattleWeather`, `src.GameMgr.Battle.UI.BattleLangDB`, `src.GameMgr.Battle.UI.actionStyle`, `src.GameMgr.Battle.type_damage`, `src.framework.cc.uiloader.CCSUILoader` | `ItemInfo`, `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/BattleWeather.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/BossBattleMgr.lua` | `Battle` | — | `src.GameMgr.Battle.boss.` | `PokemonInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/Buff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/Pet.lua` | `Battle` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/Skill.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/Team.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/UI/BattleLangDB.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/UI/PVPDailog.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/UI/PVPDetail.lua` | `Battle` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Battle/UI/actionStyle.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/boss/iceGiant.lua` | `Battle` | — | `framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Battle/boss/shachong.lua` | `Battle` | — | `framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AOEAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AOECure.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAnger.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAttRandom.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAttRatio.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAttRatioXP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAttXP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddAttribute.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddBuffRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddDamageByHp.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddDamageRate.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddDamageSelf.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddDebuffRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddEnergy.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AddTriggerRate.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/AttConvert.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/BattleTemplate.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/BattleTemplateData.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/BattleTemplateTypes.lua` | `Battle` | — | `src.GameMgr.Battle.templates.`, `src.Utils.GenUtils`, `templates.` | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/BuffToAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CalcCure.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CalcCureByMaxHP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CalcDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CalcDamageByMaxHP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ChangeTarget.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ChangeWeather.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ChangeWeatherRandom.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckActionCount.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckAttCompare.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckCountsIsUseSkill.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckCritical.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckDodge.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckElement.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckEnemyBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckEnemyHPRatio.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckEnemyNoBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckFullHP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckGetDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckHP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckHit.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckSelfBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckUseSkillCount.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CheckWeather.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ContinuedCure.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ContinuedDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CountAdd.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CountReduce.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/Cure.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/CureByMaxHP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/EmptyTemplate.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ExchangeBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ExtraAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ExtraAttackBase.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ExtraAttackSpeed.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ExtraDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ForbidChangePet.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ForceChangePet.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ImmuneBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ImmuneDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ImmuneElementAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ImmuneElementDefence.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ImmuneResurrect.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/Invincible.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/LimitAction.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/LimitDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/LimitSkill.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MultiAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MustCritical.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MustEvade.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MustHit.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MustKill.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/MustKillByRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/NextCritical.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/NextRoundCritical.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/NoAddAnger.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/NormalAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/OnceCure.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/OnceReturnDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/OtherAttack.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/OverlayDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RandomPower.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RateImmune.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RateImmuneBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RateRemoveBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAnger.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAtt.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAttRandom.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAttRatio.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAttRatioXP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAttValue.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceAttXP.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceDamageSelf.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceEnergy.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceEnergyIncrement.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReduceRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RefreshEnemyBuffRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RefreshSelfBuffRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RemoveBuffOnEnemy.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RemoveBuffOnSelf.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/RemoveCurBuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/Resurrect.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/ReturnDamage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/SecKill.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/SelfExplod.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/SpecialRound.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/StealAttribute.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/StealEnergy.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/TransferBuffToEnemy.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/TransferBuffToSelf.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/Vampire.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/VampireDebuff.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/VampireRatio.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/VampireRatioByAtt.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/damageEachOther.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/templates/removeEnemyBuffRate.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Battle/type_damage.lua` | `Battle` | — | — | — |
| `decoded_lua/assets/src/GameMgr/CSResourceMgr.lua` | `CSResourceMgr.lua` | — | `src.GameMgr.Support.CommonList`, `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/ChainMan/ChainManUIMgr.lua` | `ChainMan` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Chat/ChatBubbleMgr.lua` | `Chat` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Chat/ChatMsgMgr.lua` | `Chat` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Chat/ChatUIMgr.lua` | `Chat` | — | `coroutine`, `src.Net.Send.ChatSend`, `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Chat/MsgBoardView.lua` | `Chat` | `sendCG_GetMessagesFBByApprove_Req`, `sendCG_GetMessagesFBByTime_Req`, `sendCG_GetMessagesPetByApprove_Req`, `sendCG_GetMessagesPetByTime_Req`, `sendCG_PostApproveFB_Req`, `sendCG_PostApprovePet_Req`, `sendCG_PostMessageFB_Req`, `sendCG_PostMessagePet_Req` | `cjson`, `src.Net.Send.MessageBoardSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Chat/PetShareDetail.lua` | `Chat` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Chat/TownChatMgr.lua` | `Chat` | `sendCG_ChangeChannel_Req`, `sendCG_Chat_Req`, `sendCG_GetFriendDetail_Req`, `sendCG_InviteTeamMember_Req` | `cjson`, `coroutine`, `src.Net.Send.ChatSend`, `src.Net.Send.ChatUserSend`, `src.Net.Send.TeamSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/CocosModuleMgr.lua` | `CocosModuleMgr.lua` | — | `src.GameMgr.Support.RichLabel`, `src.framework.cc.uiloader.CCSUILoader` | — |
| `decoded_lua/assets/src/GameMgr/Common/BasicMenuMgr.lua` | `Common` | — | — | `LostTowerInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/ChoosePetViewMgr.lua` | `Common` | — | `src.Data.GenInfo`, `src.Net.Send.LoginSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/CreateCharViewMgr.lua` | `Common` | — | `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/DialogBoxMgr.lua` | `Common` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Common/GameGuideMgr.lua` | `Common` | — | `src.GameMgr.Common.GameGuideMgr1`, `src.GameMgr.Common.GameGuideMgr2`, `src.GameMgr.Common.GameGuideMgr3` | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Common/GameGuideMgr1.lua` | `Common` | `sendCG_CapsuleEggCDs_Req` | `src.Net.Send.PetSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/GameGuideMgr2.lua` | `Common` | — | `src.GameMgr.LostTower.LTGuideMgr` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/GameGuideMgr3.lua` | `Common` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/GameNoticeMgr.lua` | `Common` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Common/HomeMenuMgr.lua` | `Common` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Common/HorseLayerMgr.lua` | `Common` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/LoginMsgMgr.lua` | `Common` | `sendCG_CapsuleEggCDs_Req`, `sendCG_CheckUnReadMail_Req`, `sendCG_GetActivitiesData_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetCurrentAdventrue_Req`, `sendCG_GetExploreData_Req`, `sendCG_GetFinishedAdventures_Req`, `sendCG_GetItemPacket_Req`, `sendCG_GetMyFriends_Req`, `sendCG_GetMyMapNodeEventInfo_Req`, `sendCG_GetPetArmys_Req`, `sendCG_GetPetWiki_Req`, `sendCG_GetPokemonAchievements_Req`, `sendCG_GetPotentials_Req`, `sendCG_GetScienceDatas_Req`, `sendCG_GetWishingTreesData_Req`, `sendCG_GetWorldBoss_Req`, `sendCG_GetWorldOpenTime_Req`, `sendCG_LoadSigninData_Req`, `sendCG_QueryPokemons_Req`, `sendCG_RecoverStepNumber_Req`, `sendCG_VipAwardInfo_Req` | `src.Net.Send.AchievementSend`, `src.Net.Send.ActivitySend`, `src.Net.Send.AdventureSend`, `src.Net.Send.ChatUserSend`, `src.Net.Send.ExploreSend`, `src.Net.Send.ItemSend`, `src.Net.Send.LoginSend`, `src.Net.Send.LostTowerSend`, `src.Net.Send.MailSend`, `src.Net.Send.MonthCardSend`, `src.Net.Send.NewQuestSend`, `src.Net.Send.PetSend`, `src.Net.Send.SigninSend`, `src.Net.Send.VipSend`, `src.Net.Send.WishingTreeSend`, `src.Net.Send.WorldBossSend`, `src.framework.scheduler` | `PokemonInfo`, `QuestInfo`, `TreasureBoxInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Common/LoginViewMgr.lua` | `Common` | `sendCG_DeviceLogin_Req`, `sendCG_DeviceRelogin_Req`, `sendCG_QueryPokemons_Req` | `Utils.SDKManager`, `cjson`, `src.Data.GenInfo`, `src.GameMgr.login`, `src.Net.NetMgr`, `src.Net.Reconnector`, `src.Net.Send.LoginSend`, `src.Net.Send.PetSend` | — |
| `decoded_lua/assets/src/GameMgr/Common/StandardTipsMgr.lua` | `Common` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Common/StatusBarMgr.lua` | `Common` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Common/SystemOptionsMgr.lua` | `Common` | `sendCG_UseActivateCode_Req` | `src.Net.Send.ActivateCodeSend` | `ExploreInfo` |
| `decoded_lua/assets/src/GameMgr/Common/TipsMgr.lua` | `Common` | — | — | — |
| `decoded_lua/assets/src/GameMgr/CommonDungeon/DungeonMapMgr.lua` | `CommonDungeon` | — | `src.GameMgr.CommonDungeon.DungeonTestMapMgr`, `src.GameMgr.LostTower.LtMapNodeMgr`, `src.GameMgr.Searching.advNodePool` | — |
| `decoded_lua/assets/src/GameMgr/CommonDungeon/DungeonPlayerMgr.lua` | `CommonDungeon` | — | — | — |
| `decoded_lua/assets/src/GameMgr/CommonDungeon/DungeonTestMapMgr.lua` | `CommonDungeon` | — | `src.DatReader.MonsterGroupManInfoConfig`, `src.DatReader.MonstrosityInfoConfig` | — |
| `decoded_lua/assets/src/GameMgr/Confraternity/ConfraInfoViewMgr.lua` | `Confraternity` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Confraternity/ConfraListViewMgr.lua` | `Confraternity` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Data/AchievementInfo.lua` | `Data` | — | `src.DatReader.AchievementInfoConfig`, `src.DatReader.PokemonAchievementInfoConfig`, `src.DatReader.PotentialInfoConfig` | `AchievementInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ActivityInfo.lua` | `Data` | — | `src.DatReader.ActivityInfoClientConfig`, `src.DatReader.ActivityPokemonAchievementInfoConfig`, `src.DatReader.ActivityShopInfoConfig`, `src.DatReader.SurvivalBattleAwardInfoConfig` | — |
| `decoded_lua/assets/src/GameMgr/Data/AdventureInfo.lua` | `Data` | — | `cjson`, `src.DatReader.AdvAwardConfig`, `src.DatReader.AdventureInfoConfig`, `src.DatReader.DBossInfoConfig`, `src.DatReader.DisposableInfoConfig`, `src.DatReader.DropInfoConfig`, `src.DatReader.EventInfoConfig`, `src.DatReader.MapStarAwardConfig`, `src.DatReader.MonsterGroupManInfoConfig`, `src.DatReader.MonstrosityInfoConfig`, `src.DatReader.ResetInfoConfig`, `src.DatReader.RewardInfoConfig`, `src.DatReader.SceneInfoConfig` | `AdventureInfo`, `FamilyQuestInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ArenaInfo.lua` | `Data` | `sendCG_GetPVPArenaAward_Req` | `cjson`, `src.DatReader.ArenaAwardInfoConfig`, `src.DatReader.PVPArenaGradeInfoConfig`, `src.Net.Send.PVPSend`, `src.framework.scheduler` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Data/BattleInfo.lua` | `Data` | — | `src.DatReader.ElementSkillInfoConfig`, `src.DatReader.PotentialSkillInfoConfig`, `src.DatReader.SkillInfoConfig`, `src.DatReader.SkillTagInfoConfig`, `src.DatReader.SkillTemplateInfoConfig` | `PotentialSkillInfo`, `SkillInfo`, `SkillTagInfo`, `SkillTemplateInfo` |
| `decoded_lua/assets/src/GameMgr/Data/CharInfo.lua` | `Data` | `sendCG_GetActivitiesData_Req`, `sendCG_SelectTreasureBox_Req` | `cjson`, `src.DatReader.BuyPowerInfoConfig`, `src.DatReader.FashionShowAwardInfoConfig`, `src.DatReader.FashionShowRuleInfoConfig`, `src.DatReader.GoldPointInfoConfig`, `src.DatReader.SigninInfoConfig`, `src.DatReader.SigninRepairCostInfoConfig`, `src.DatReader.VipInfoConfig`, `src.GameMgr.Battle.BattleCotroller`, `src.GameMgr.Battle.UI.PVPDailog`, `src.Net.Send.ActivitySend`, `src.Net.Send.TreasureBoxSend` | `AdventureInfo`, `ExperienceInfo`, `ExploreInfo`, `ItemInfo`, `LostTowerInfo`, `QuestInfo`, `ScienceInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ExpeditionQuestInfo.lua` | `Data` | — | `src.DatReader.ExpeditionQuestInfoConfig` | `ExpeditionQuestInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ExpeditionalInfo.lua` | `Data` | — | `src.DatReader.ExpeditionInfoConfig`, `src.DatReader.ExpeditionLotteryInfoConfig`, `src.DatReader.ExpeditionMonsterInfoConfig`, `src.DatReader.ExpeditionMonsterPoolInfoConfig`, `src.DatReader.LotteryBuyCountInfoConfig`, `src.GameMgr.Data.ExpeditionQuestInfo` | `ExpeditionQuestInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ExperienceInfo.lua` | `Data` | — | `src.DatReader.ExperienceInfoConfig`, `src.DatReader.LifeSkillCareerChangeConfig`, `src.DatReader.LifeSkillExpConfig` | `ExperienceInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ExploreInfo.lua` | `Data` | — | `cjson`, `src.DatReader.ExploreEventSInfoConfig`, `src.DatReader.ExploreInfoConfig`, `src.DatReader.ExplorePacketBuyInfoConfig`, `src.DatReader.ExploreRandomAwardInfoConfig`, `src.framework.scheduler` | `ExploreInfo` |
| `decoded_lua/assets/src/GameMgr/Data/FamilyDataInfo.lua` | `Data` | — | `src.DatReader.FamilyAttributeChangeInfoConfig`, `src.DatReader.FamilyAwardInfoConfig`, `src.DatReader.FamilyDevoteBufferInfoConfig`, `src.DatReader.FamilyLevelInfoConfig`, `src.DatReader.FamilyMonsterInfoConfig`, `src.DatReader.FamilyObstacleInfoConfig`, `src.DatReader.FamilyRandomChestInfoConfig`, `src.DatReader.FamilyShopInfoConfig`, `src.DatReader.FamilyTransferInfoConfig` | — |
| `decoded_lua/assets/src/GameMgr/Data/FamilyInfo.lua` | `Data` | `sendCG_BuyFamilyShopGoods_Req`, `sendCG_Chat_Req`, `sendCG_DungeonBattleEnd_Req`, `sendCG_DungeonChangeFloor_Req`, `sendCG_DungeonMoveCell_Req`, `sendCG_FamilyDisplayCell_Req`, `sendCG_Family_Req`, `sendCG_FireDungeonCell_Req`, `sendCG_GetDungeonAwardInfo_Req`, `sendCG_GetDungeonAward_Req`, `sendCG_GetDungeonCreateTime_Req`, `sendCG_GetDungeonLog_Req`, `sendCG_GetDungeon_Req`, `sendCG_GetFamilyShopData_Req`, `sendCG_LevelReflashFamilyShop_Req`, `sendCG_RefalshFamilyShop_Req`, `sendCG_ResetDungeon_Req` | `cjson`, `src.Net.Send.ChatSend`, `src.Net.Send.FamilySend` | — |
| `decoded_lua/assets/src/GameMgr/Data/HomeInfo.lua` | `Data` | `sendCG_BuyHome_Req`, `sendCG_ChangeChannel_Req`, `sendCG_Chat_Req`, `sendCG_GetFriendDetail_Req`, `sendCG_GetHome_Req`, `sendCG_SetHome_Req` | `cjson`, `src.Net.Send.ChatSend`, `src.Net.Send.ChatUserSend`, `src.Net.Send.HomeSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ItemInfo.lua` | `Data` | `sendCG_QuerySomeItems_Req` | `cjson`, `src.DatReader.AwardElementInfoConfig`, `src.DatReader.ConsumeElementInfoConfig`, `src.DatReader.DrawingInfoConfig`, `src.DatReader.FashionItemInfoConfig`, `src.DatReader.FashionSuitEffectInfoConfig`, `src.DatReader.ItemInfoConfig`, `src.DatReader.MarketInfoConfig`, `src.DatReader.MonthCardRechargeInfoConfig`, `src.DatReader.NormalRechargeInfoConfig`, `src.DatReader.PetPieceInfoConfig`, `src.DatReader.PokemonBallInfoConfig`, `src.DatReader.ShopReflashInfoConfig`, `src.DatReader.WishingTreeInfoConfig`, `src.Net.Send.ItemSend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Data/LostTowerInfo.lua` | `Data` | — | `cjson`, `src.DatReader.AttributeChangeInfoConfig`, `src.DatReader.CollectionInfoConfig`, `src.DatReader.EmptyEventInfoConfig`, `src.DatReader.EventListInfoConfig`, `src.DatReader.FloorRelationInfoConfig`, `src.DatReader.LostTowerAwardInfoConfig`, `src.DatReader.LostTowerBossInfoConfig`, `src.DatReader.LostTowerDropInfoConfig`, `src.DatReader.LostTowerInfoConfig`, `src.DatReader.LostTowerMonsterInfoConfig`, `src.DatReader.LostTowerMonsterManGroupInfoConfig`, `src.DatReader.LostTowerRankAwardInfoConfig`, `src.DatReader.LostTowerResetInfoConfig`, `src.DatReader.ObstacleInfoConfig`, `src.DatReader.PickUpItemInfoConfig`, `src.DatReader.RandomChestInfoConfig`, `src.DatReader.RecoverEffectInfoConfig`, `src.DatReader.RecoverStateInfoConfig`, `src.DatReader.StationaryAwardInfoConfig`, `src.DatReader.TransferDoorInfoConfig`, `src.DatReader.TransferInfoConfig`, `src.DatReader.TrapInfoConfig`, `src.framework.scheduler` | `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/Data/PetEquipInfo.lua` | `Data` | `sendCG_GetCharacterValues_Req`, `sendCG_PetEquipAppraise_Req`, `sendCG_PetEquipBaptism_Req`, `sendCG_PetEquipCompose_Req`, `sendCG_PetEquipOff_Req`, `sendCG_PetEquipOn_Req`, `sendCG_PetEquipPurify_Req`, `sendCG_PetEquipRestore_Req`, `sendCG_PetEquipStrengthen_Req` | `src.DatReader.PetEquipEffectInfoConfig`, `src.DatReader.PetEquipEffectSetInfoConfig`, `src.DatReader.PetEquipInfoConfig`, `src.DatReader.PetEquipPurifyExpInfoConfig`, `src.DatReader.PetEquipPurifyInfoConfig`, `src.DatReader.PetEquipRestorePurifyInfoConfig`, `src.DatReader.PetEquipRestoreStrengthenInfoConfig`, `src.DatReader.PetEquipStrengthenInfoConfig`, `src.Net.Send.LoginSend`, `src.Net.Send.PetEquipSend` | `PetEquipInfo` |
| `decoded_lua/assets/src/GameMgr/Data/PetTrainPointsInfo.lua` | `Data` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Data/PokemonInfo.lua` | `Data` | `sendCG_UpdatePetArmys_Req` | `cjson`, `src.DatReader.CapsuleEggAwardInfoConfig`, `src.DatReader.CapsuleEggInfoConfig`, `src.DatReader.CustomSkillBookInfoConfig`, `src.DatReader.GeneInfoConfig`, `src.DatReader.GeneProbabilityInfoConfig`, `src.DatReader.PetAdvanceInfoConfig`, `src.DatReader.PetBufferInfoConfig`, `src.DatReader.PetEvoInfoConfig`, `src.DatReader.PetFreedomAwardGroupInfoConfig`, `src.DatReader.PetFreedomAwardInfoConfig`, `src.DatReader.PetFreedomStarpointInfoConfig`, `src.DatReader.PetResetStarInfoConfig`, `src.DatReader.PetSkillInfoConfig`, `src.DatReader.PetStarUpInfoConfig`, `src.DatReader.PetStrengthenInfoConfig`, `src.DatReader.PokemonInfoConfig`, `src.DatReader.SkillPlayConfig`, `src.DatReader.YokeEffectConfig`, `src.DatReader.YokeEffectPosConfig`, `src.DatReader.YokeInfoConfig`, `src.DatReader.YokeScoreConfig`, `src.Net.Send.PetSend` | `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Data/QuestInfo.lua` | `Data` | — | `src.DatReader.FamilyQuestInfoConfig`, `src.DatReader.NewQuestInfoConfig`, `src.DatReader.PVPArenaQuestInfoConfig`, `src.Net.Send.LoginSend`, `src.Net.Send.NewQuestSend` | `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Data/ScienceInfo.lua` | `Data` | — | `src.DatReader.ScienceConsumeInfoConfig`, `src.DatReader.ScienceInfoConfig` | `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Data/SystemInfo.lua` | `Data` | — | `src.DatReader.GlobalConfigAddInfoConfig` | `GlobalConfigAddInfo` |
| `decoded_lua/assets/src/GameMgr/Data/TeamCopyInfo.lua` | `Data` | `sendCG_ChangeArmyPet_Req`, `sendCG_DungeonChangeFloor_Req`, `sendCG_DungeonMoveCell_Req`, `sendCG_EnterTeamDungeon_Req`, `sendCG_FireDungeonCell_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetDungeon_Req`, `sendCG_LeaveTeamDungeon_Req`, `sendCG_QueryTeamDungeonMonsterHp_Req`, `sendCG_ReviveCharacter_Req`, `sendCG_TeamBattleEnd_Req`, `sendCG_TeamDungeonBattleStart_Req` | `src.Net.Send.FamilySend`, `src.Net.Send.LoginSend`, `src.Net.Send.TeamSend` | — |
| `decoded_lua/assets/src/GameMgr/Data/TeamInfo.lua` | `Data` | `sendCG_AutoJoinTeam_Req`, `sendCG_GetMyTeam_Req`, `sendCG_GetTeamMembers_Req`, `sendCG_KickTeamMember_Req`, `sendCG_RefuseJoinTeam_Req` | `cjson`, `src.Net.Send.TeamSend` | `PokemonInfo`, `TreasureBoxInfo` |
| `decoded_lua/assets/src/GameMgr/Data/TeamMapInfo.lua` | `Data` | — | `src.DatReader.TeamFloorInfoConfig`, `src.DatReader.TeamItemInfoConfig`, `src.DatReader.TeamMonsterInfoConfig`, `src.DatReader.TeamObstacleInfoConfig`, `src.DatReader.TeamPickUpItemInfoConfig`, `src.DatReader.TeamTransferInfoConfig` | — |
| `decoded_lua/assets/src/GameMgr/Data/TerritorialInfo.lua` | `Data` | `sendCG_TerritoryInfo_Req` | `cjson`, `src.DatReader.TerritorialAwardInfoConfig`, `src.DatReader.TerritorialInfoConfig`, `src.DatReader.TerritorialRankInfoConfig`, `src.Net.Send.TerritorialSend` | `TerritorialInfo` |
| `decoded_lua/assets/src/GameMgr/Data/TreasureBoxInfo.lua` | `Data` | `sendCG_GetCharacterValues_Req`, `sendCG_GetTreasureBoxData_Req` | `src.DatReader.TreasureBoxInfoConfig`, `src.Net.Send.LoginSend`, `src.Net.Send.TreasureBoxSend`, `src.framework.scheduler` | `TreasureBoxInfo` |
| `decoded_lua/assets/src/GameMgr/Data/WorldBossInfo.lua` | `Data` | `sendCG_AttackBoss_Req`, `sendCG_BossAttack_Req`, `sendCG_DiamondRecoverAll_Req`, `sendCG_DiamondRecoverPet_Req`, `sendCG_GetDamageRank_Req`, `sendCG_GetSelfWorldBossData_Req`, `sendCG_GetWorldBoss_Req`, `sendCG_NormalRecover_Req`, `sendCG_TakeAward_Req` | `src.DatReader.BossKillAwardInfoConfig`, `src.DatReader.WorldBossInfoConfig`, `src.DatReader.WorldBossWeekAwardInfoConfig`, `src.Net.Send.WorldBossSend`, `src.framework.scheduler` | `WorldBossInfo`, `WorldBossWeekAwardInfo` |
| `decoded_lua/assets/src/GameMgr/Data/WorldMapInfo.lua` | `Data` | — | — | `EventInfo` |
| `decoded_lua/assets/src/GameMgr/DebugInfoMgr.lua` | `DebugInfoMgr.lua` | — | `src.DatReader.ItemInfoConfig`, `src.DatReader.NewQuestInfoConfig`, `src.DatReader.PokemonInfoConfig`, `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/GameInit.lua` | `GameInit.lua` | — | `src.DatReader.AttributeStarImproveInfoConfig`, `src.GameMgr.Activity.ActivityShopViewMgr`, `src.GameMgr.Activity.SurviveBattleViewMgr`, `src.GameMgr.Activity.expeditionalViewMgr`, `src.GameMgr.Animation3DMgr`, `src.GameMgr.AnimationMgr`, `src.GameMgr.Battle.BattleAidFunc`, `src.GameMgr.Battle.BattleBasicValueCalc`, `src.GameMgr.Battle.BattleBuffer`, `src.GameMgr.Battle.BattleBufferUI`, `src.GameMgr.Battle.BattleCANI`, `src.GameMgr.Battle.BattleCCSB`, `src.GameMgr.Battle.BattleCotroller`, `src.GameMgr.Battle.BattleFuncMgr`, `src.GameMgr.Battle.BattleGuide`, `src.GameMgr.Battle.BattleLabelAtlas`, `src.GameMgr.Battle.BattleMgr`, `src.GameMgr.Battle.BattlePVPMgr`, `src.GameMgr.Battle.BattlePassiveSkills`, `src.GameMgr.Battle.BattleSkill`, `src.GameMgr.Battle.BattleUIMgr`, `src.GameMgr.Battle.BossBattleMgr`, `src.GameMgr.Battle.Buff`, `src.GameMgr.Battle.Pet`, `src.GameMgr.Battle.Skill`, `src.GameMgr.Battle.Team`, `src.GameMgr.Battle.templates.BattleTemplate`, `src.GameMgr.Battle.templates.BattleTemplateData`, `src.GameMgr.Battle.templates.BattleTemplateTypes`, `src.GameMgr.Battle.templates.ExtraAttackBase`, `src.GameMgr.CSResourceMgr`, `src.GameMgr.Chat.ChatBubbleMgr`, `src.GameMgr.Chat.ChatMsgMgr`, `src.GameMgr.Chat.ChatUIMgr`, `src.GameMgr.Chat.MsgBoardView`, `src.GameMgr.Chat.PetShareDetail`, `src.GameMgr.Chat.TownChatMgr`, `src.GameMgr.CocosModuleMgr`, `src.GameMgr.Common.BasicMenuMgr`, `src.GameMgr.Common.ChoosePetViewMgr`, `src.GameMgr.Common.CreateCharViewMgr`, `src.GameMgr.Common.DialogBoxMgr`, `src.GameMgr.Common.GameGuideMgr`, `src.GameMgr.Common.GameNoticeMgr`, `src.GameMgr.Common.HomeMenuMgr`, `src.GameMgr.Common.HorseLayerMgr`, `src.GameMgr.Common.LoginMsgMgr`, `src.GameMgr.Common.LoginViewMgr`, `src.GameMgr.Common.StandardTipsMgr`, `src.GameMgr.Common.StatusBarMgr`, `src.GameMgr.Common.SystemOptionsMgr`, `src.GameMgr.Common.TipsMgr`, `src.GameMgr.CommonDungeon.DungeonMapMgr`, `src.GameMgr.CommonDungeon.DungeonPlayerMgr`, `src.GameMgr.Confraternity.ConfraInfoViewMgr`, `src.GameMgr.Confraternity.ConfraListViewMgr`, `src.GameMgr.Data.AchievementInfo`, `src.GameMgr.Data.ActivityInfo`, `src.GameMgr.Data.AdventureInfo`, `src.GameMgr.Data.ArenaInfo`, `src.GameMgr.Data.BattleInfo`, `src.GameMgr.Data.CharInfo`, `src.GameMgr.Data.ExpeditionalInfo`, `src.GameMgr.Data.ExperienceInfo`, `src.GameMgr.Data.ExploreInfo`, `src.GameMgr.Data.FamilyDataInfo`, `src.GameMgr.Data.FamilyInfo`, `src.GameMgr.Data.HomeInfo`, `src.GameMgr.Data.ItemInfo`, `src.GameMgr.Data.LostTowerInfo`, `src.GameMgr.Data.PetEquipInfo`, `src.GameMgr.Data.PetTrainPointsInfo`, `src.GameMgr.Data.PokemonInfo`, `src.GameMgr.Data.QuestInfo`, `src.GameMgr.Data.ScienceInfo`, `src.GameMgr.Data.SystemInfo`, `src.GameMgr.Data.TeamCopyInfo`, `src.GameMgr.Data.TeamInfo`, `src.GameMgr.Data.TeamMapInfo`, `src.GameMgr.Data.TerritorialInfo`, `src.GameMgr.Data.TreasureBoxInfo`, `src.GameMgr.Data.WorldBossInfo`, `src.GameMgr.Data.WorldMapInfo`, `src.GameMgr.DebugInfoMgr`, `src.GameMgr.GameLogMgr`, `src.GameMgr.Item.ActivityCapsuleEggView`, `src.GameMgr.Item.ActivityHalloweenViewMgr`, `src.GameMgr.Item.ActivityPublicjMgr`, `src.GameMgr.Item.ActivitySnatch`, `src.GameMgr.Item.ActivityViewMgr`, `src.GameMgr.Item.AuctionMgr`, `src.GameMgr.Item.AuctionMgrNew`, `src.GameMgr.Item.AuctionSearch`, `src.GameMgr.Item.AwardsListMgr`, `src.GameMgr.Item.BagViewMgr`, `src.GameMgr.Item.BossDmgAwardsMgr`, `src.GameMgr.Item.BuyInfoMgr`, `src.GameMgr.Item.BuyInfoMgr2`, `src.GameMgr.Item.BuyItemViewMgr`, `src.GameMgr.Item.CollectPetActivityViewMgr`, `src.GameMgr.Item.DropInfoViewMgr`, `src.GameMgr.Item.FurnitureSofaMgr`, `src.GameMgr.Item.FurnitureTVMgr`, `src.GameMgr.Item.FurnitureViewMgr`, `src.GameMgr.Item.GachaViewMgr`, `src.GameMgr.Item.HalloweenCapsuleEggView`, `src.GameMgr.Item.ItemInfoViewMgr`, `src.GameMgr.Item.ItemNumViewMgr`, `src.GameMgr.Item.MailMgr`, `src.GameMgr.Item.PurchaseViewMgr`, `src.GameMgr.Item.RechargeViewMgr`, `src.GameMgr.Item.SellInfoMgr`, `src.GameMgr.Item.ShopListMgr`, `src.GameMgr.Item.SkillBookViewMgr`, `src.GameMgr.Item.TrainStoneMgr`, `src.GameMgr.Item.VipShopViewMgr`, `src.GameMgr.Item.WishCoinShop.WishCoinShopView`, `src.GameMgr.LostTower.LostTowerMgr`, `src.GameMgr.LostTower.LostTowerUIMgr`, `src.GameMgr.LostTower.LtChangeFloorView`, `src.GameMgr.LostTower.LtEventOption`, `src.GameMgr.LostTower.LtExBufferMgr`, `src.GameMgr.LostTower.LtExchangeViewMgr`, `src.GameMgr.LostTower.LtFuncMgr`, `src.GameMgr.LostTower.LtHealViewMgr`, `src.GameMgr.LostTower.LtMapNodeMgr`, `src.GameMgr.LostTower.LtMapOption`, `src.GameMgr.LostTower.LtOpenBoxView`, `src.GameMgr.LostTower.LtPetsMgr`, `src.GameMgr.LostTower.LtPickPetViewMgr`, `src.GameMgr.LostTower.LtPlayerMgr`, `src.GameMgr.LostTower.LtPropMgr`, `src.GameMgr.LostTower.LtRankAwardList`, `src.GameMgr.LostTower.LtRankingViewMgr`, `src.GameMgr.LostTower.LtResetViewMgr`, `src.GameMgr.LostTower.LtStepAddView`, `src.GameMgr.LostTower.LtTransferViewMgr`, `src.GameMgr.LostTower.LtWarFogMgr`, `src.GameMgr.Map.AllWorldMapMgr`, `src.GameMgr.Map.BattleMapMgr`, `src.GameMgr.Map.BossMapMgr`, `src.GameMgr.Map.CopyMapMgr`, `src.GameMgr.Map.EmbeddedMapMgr`, `src.GameMgr.Map.ExploreMapMgr`, `src.GameMgr.Map.FamilyCopyMapMgr`, `src.GameMgr.Map.HomeMapMgr`, `src.GameMgr.Map.IdlingMapBoardMgr`, `src.GameMgr.Map.IdlingMapMgr`, `src.GameMgr.Map.MapSeekerMgr`, `src.GameMgr.Map.MiniMapMgr`, `src.GameMgr.Map.SceneMgr`, `src.GameMgr.Map.SearchingMapMgr`, `src.GameMgr.Map.TeamCopyMapMgr`, `src.GameMgr.Map.TownMapBoardMgr`, `src.GameMgr.Map.TownMapMgr`, `src.GameMgr.Map.WorldMapAwardsMgr`, `src.GameMgr.Map.WorldMapMgr`, `src.GameMgr.Map.WorldMapMoveMgr`, `src.GameMgr.Mission.AchievementListMgr`, `src.GameMgr.Mission.MissionGuideMgr`, `src.GameMgr.Mission.MissionInfoMgr`, `src.GameMgr.Mission.MissionListMgr`, `src.GameMgr.Mission.NpcDialogueMgr`, `src.GameMgr.Mission.NpcMgr`, `src.GameMgr.Mission.TownMissionMgr`, `src.GameMgr.ObjectPool`, `src.GameMgr.OrderMan.OrderManDataMgr`, `src.GameMgr.Pet.BasicPetListMgr`, `src.GameMgr.Pet.BattleManualMgr`, `src.GameMgr.Pet.CommonPetBar`, `src.GameMgr.Pet.PetChangeNameMgr`, `src.GameMgr.Pet.PetCommonListViewMgr`, `src.GameMgr.Pet.PetEatPetViewMgr`, `src.GameMgr.Pet.PetEducationMgr`, `src.GameMgr.Pet.PetEffectMgr`, `src.GameMgr.Pet.PetEquipmentEvaluateMgr`, `src.GameMgr.Pet.PetEquipmentMgr`, `src.GameMgr.Pet.PetEquipmentOperationMgr`, `src.GameMgr.Pet.PetEquipmentRestoreMgr`, `src.GameMgr.Pet.PetEquipmentStrengthenEffectMgr`, `src.GameMgr.Pet.PetEvolutionEffectMgr`, `src.GameMgr.Pet.PetEvolutionMgr`, `src.GameMgr.Pet.PetExploreInfoMgr`, `src.GameMgr.Pet.PetExploreMgr`, `src.GameMgr.Pet.PetExploreRewardsMgr`, `src.GameMgr.Pet.PetFCEffectMgr`, `src.GameMgr.Pet.PetFeedViewMgr`, `src.GameMgr.Pet.PetFormationMgr`, `src.GameMgr.Pet.PetFreeListMgr`, `src.GameMgr.Pet.PetGetViewMgr`, `src.GameMgr.Pet.PetHandBook`, `src.GameMgr.Pet.PetInfoViewMgr`, `src.GameMgr.Pet.PetListMgr`, `src.GameMgr.Pet.PetMenuMgr`, `src.GameMgr.Pet.PetQuickTrainViewMgr`, `src.GameMgr.Pet.PetQuickViewMgr`, `src.GameMgr.Pet.PetSkillIconMgr`, `src.GameMgr.Pet.PetSkillViewMgr`, `src.GameMgr.Pet.PetStarUpMgr`, `src.GameMgr.Pet.PetStarupEffectMgr`, `src.GameMgr.Pet.PetStarupResetViewMgr`, `src.GameMgr.Pet.PetStrengthenMgr`, `src.GameMgr.Pet.PickItemViewMgr`, `src.GameMgr.Pet.PickPurifyViewMgr`, `src.GameMgr.Pet.PokedexMgr`, `src.GameMgr.Pet.TipsViewMgr`, `src.GameMgr.Pet.petTrainLimitMaterialView`, `src.GameMgr.Player.ArenaEffectMgr`, `src.GameMgr.Player.ArenaExchangeMgr`, `src.GameMgr.Player.ArenaMainMgr`, `src.GameMgr.Player.ArenaPKViewMgr`, `src.GameMgr.Player.ArenaRecordMgr`, `src.GameMgr.Player.ArenaRewardList`, `src.GameMgr.Player.ArenaTeamViewMgr`, `src.GameMgr.Player.ArenaViewMgr`, `src.GameMgr.Player.ArenaWinViewMgr`, `src.GameMgr.Player.AvatarViewMgr`, `src.GameMgr.Player.BossFailedMgr`, `src.GameMgr.Player.BossTopBarMgr`, `src.GameMgr.Player.CheckViewMgr`, `src.GameMgr.Player.CreateFamilyMgr`, `src.GameMgr.Player.ExchangeViewMgr`, `src.GameMgr.Player.ExitGameViewMgr`, `src.GameMgr.Player.ExploreViewMgr`, `src.GameMgr.Player.FamilyApplyListViewMgr`, `src.GameMgr.Player.FamilyCopyBonusMgr`, `src.GameMgr.Player.FamilyCopyEventMgr`, `src.GameMgr.Player.FamilyCopyMgr`, `src.GameMgr.Player.FamilyCopyTopBarMgr`, `src.GameMgr.Player.FamilyDonateMgr`, `src.GameMgr.Player.FamilyFloorInfoMgr`, `src.GameMgr.Player.FamilyIconMgr`, `src.GameMgr.Player.FamilyInfoMgr`, `src.GameMgr.Player.FamilyListViewMgr`, `src.GameMgr.Player.FamilyLogViewMgr`, `src.GameMgr.Player.FamilyNpcManagerViewMgr`, `src.GameMgr.Player.FamilyPlayerViewMgr`, `src.GameMgr.Player.FamilyQuestListMgr`, `src.GameMgr.Player.FamilyShopMgr`, `src.GameMgr.Player.FamilySignServer`, `src.GameMgr.Player.FamilySignView`, `src.GameMgr.Player.FamilyTransListViewMgr`, `src.GameMgr.Player.FriendsViewMgr`, `src.GameMgr.Player.LevelUpViewMgr`, `src.GameMgr.Player.LifeSkillBatchMaker`, `src.GameMgr.Player.LifeSkillFilterPopUp`, `src.GameMgr.Player.LifeSkillJobChangeViewMgr`, `src.GameMgr.Player.LifeSkillLstViewMgr`, `src.GameMgr.Player.LifeSkillSelViewMgr`, `src.GameMgr.Player.MArenaViewMgr`, `src.GameMgr.Player.MyFamilyLstViewMgr`, `src.GameMgr.Player.NoticeViewMgr`, `src.GameMgr.Player.PVPQuestListMgr`, `src.GameMgr.Player.PVPQuestRank`, `src.GameMgr.Player.PVPQuestShopMgr`, `src.GameMgr.Player.PersonalCenterMgr`, `src.GameMgr.Player.PlayerAnimeMgr`, `src.GameMgr.Player.PlayerInfoViewMgr`, `src.GameMgr.Player.PlayerOperationMgr`, `src.GameMgr.Player.PlayerShareMgr`, `src.GameMgr.Player.PokedexMenuViewMgr`, `src.GameMgr.Player.ScienceDevelopMgr`, `src.GameMgr.Player.ScienceViewMgr`, `src.GameMgr.Player.SearchFamilyMgr`, `src.GameMgr.Player.SelectBeautyViewMgr`, `src.GameMgr.Player.TeamCopyTopBarMgr`, `src.GameMgr.Player.TeamCopyWinMgr`, `src.GameMgr.Player.TeamDropMgr`, `src.GameMgr.Player.TeamInviteMgr`, `src.GameMgr.Player.TeamViewMgr`, `src.GameMgr.Player.TownPlayerListMgr`, `src.GameMgr.Player.TownPlayerMgr`, `src.GameMgr.Player.TownTreeMgr`, `src.GameMgr.Player.TreeInfoView`, `src.GameMgr.Player.WorldPlayerMgr`, `src.GameMgr.ProtoErrorTransferText`, `src.GameMgr.Searching.AdvCharMgr`, `src.GameMgr.Searching.AdvConfirmMgr`, `src.GameMgr.Searching.AdvConfirmMgrNew`, `src.GameMgr.Searching.AdvEnvironmentMgr`, `src.GameMgr.Searching.AdvPetsMgr`, `src.GameMgr.Searching.AdvStarMgr`, `src.GameMgr.Searching.SearchingFuncMgr`, `src.GameMgr.Searching.SearchingMgr`, `src.GameMgr.Searching.SearchingUIMgr`, `src.GameMgr.Searching.StageBossListMgr`, `src.GameMgr.Searching.advResetView`, `src.GameMgr.Support.AndroidFunction`, `src.GameMgr.Support.BaseFunction`, `src.GameMgr.Support.CopyMapLoadingMgr`, `src.GameMgr.Support.GameAudio`, `src.GameMgr.Support.GetRandom`, `src.GameMgr.Support.HighPerformList`, `src.GameMgr.Support.LoadingView`, `src.GameMgr.Support.LuaSqlite`, `src.GameMgr.Support.NetInterface`, `src.GameMgr.Support.OvertimeListener`, `src.GameMgr.Support.PlatformConfig`, `src.GameMgr.Support.QRCodeMgr`, `src.GameMgr.Support.TxtReader`, `src.GameMgr.Support.UnblockLoader`, `src.GameMgr.Support.UserSettings`, `src.GameMgr.Support.Voice.VoiceManager`, `src.GameMgr.Support.iOSFunction`, `src.GameMgr.Support.iWatchConnectivity`, `src.GameMgr.TaskWatcher.SevenDayFuBenData`, `src.GameMgr.TaskWatcher.SevenDayPetData`, `src.GameMgr.TaskWatcher.SevenDayRedPointManager`, `src.GameMgr.TaskWatcher.TaskWatcherManager`, `src.GameMgr.UIStack`, `src.GameMgr.ViewMgrUtils`, `src.LogConfig`, `src.Utils.HDVector`, `src.Utils.PerFormaceAnalyzer`, `src.Utils.XFangCunLogSender`, `src.Utils.pay.PayConfig` | `AchievementInfo`, `AdventureInfo`, `ExperienceInfo`, `ExploreInfo`, `ItemInfo`, `LostTowerInfo`, `PetEquipInfo`, `PokemonInfo`, `QuestInfo`, `ScienceInfo`, `TerritorialInfo`, `TreasureBoxInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/GameLogMgr.lua` | `GameLogMgr.lua` | `sendCG_ClientInfo_Req`, `sendCG_GetCharacterValues_Req` | `src.Net.Send.LoginSend` | — |
| `decoded_lua/assets/src/GameMgr/Item/ActivityCapsuleEggView.lua` | `Item` | `sendCG_TimeLimitCapsuleEgg_Req` | `cjson`, `src.Net.Send.ActivitySend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ActivityHalloweenViewMgr.lua` | `Item` | `sendCG_GetActivitiesData_Req` | `cjson`, `src.GameMgr.Item.ActivityInterface`, `src.GameMgr.Item.ActivityItemProcessor`, `src.Net.Send.ActivitySend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ActivityInterface.lua` | `Item` | `sendCG_BuyGrowthFund_Req`, `sendCG_FetchConsumeAwards_Req`, `sendCG_FetchGrowthFundAwards_Req`, `sendCG_FetchRechargeAwards_Req` | `src.Net.Send.ActivitySend` | — |
| `decoded_lua/assets/src/GameMgr/Item/ActivityItemProcessor.lua` | `Item` | `sendCG_FetchContinueLoginAwards_Req`, `sendCG_FetchDailyActionValue_Req`, `sendCG_FetchDailyCountActivityAward_Req`, `sendCG_FetchLoginAwards_Req`, `sendCG_FetchUpgradeAwards_Req`, `sendCG_GetActivitiesData_Req`, `sendCG_TimeLimitCapsuleEgg_Req` | `src.GameMgr.Item.ActivityInterface`, `src.Net.Send.ActivitySend`, `src/Net/Send/ActivitySend.lua` | `ItemInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ActivityPublicjMgr.lua` | `Item` | `sendCG_FetchSpokesmanGuessAwards_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetMyPlayerPoint_Req`, `sendCG_GetPlayerPointRank_Req` | `cjson`, `src.Net.Send.ActivitySend`, `src.Net.Send.LoginSend`, `src.framework.scheduler` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ActivitySnatch.lua` | `Item` | `sendCG_BuyOneMCashShop_Req`, `sendCG_GetOneMCashShopDetail_Req`, `sendCG_GetOneMCashShopLog_Req`, `sendCG_GetOneMCashShop_Req` | `cjson`, `src.Net.Send.NewShopSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ActivityViewMgr.lua` | `Item` | `sendCG_FetchContinueLoginAwards_Req`, `sendCG_FetchDailyActionValue_Req`, `sendCG_FetchFirstLoginAwards_Req`, `sendCG_FetchLoginAwards_Req`, `sendCG_FetchUpgradeAwards_Req`, `sendCG_GetActivitiesData_Req`, `sendCG_GetGMActivities_Req` | `cjson`, `src.GameMgr.Item.ActivityInterface`, `src.GameMgr.Item.SevenDaysActivity`, `src.Net.Send.ActivitySend`, `src.Utils.GenUtils`, `src.framework.scheduler`, `src/Net/Send/ActivitySend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/AuctionMgr.lua` | `Item` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Item/AuctionMgrNew.lua` | `Item` | `sendCG_BuyProduct_Req`, `sendCG_DelMyProduct_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetLifeSkillData_Req`, `sendCG_GetMyMarket_Req`, `sendCG_SearchProducts_Req`, `sendCG_SellOnMarket_Req` | `cjson`, `src.Net.Send.LifeSkillSend`, `src.Net.Send.LoginSend`, `src.Net.Send.MarketSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/AuctionSearch.lua` | `Item` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/AwardSelectViewMgr.lua` | `Item` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/AwardsListMgr.lua` | `Item` | — | `cjson` | `ItemInfo`, `PetEquipInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/BagViewMgr.lua` | `Item` | `sendCG_BuyPacket_Req`, `sendCG_GetItemPacket_Req` | `cjson`, `src.Net.Send.ItemSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/BossDmgAwardsMgr.lua` | `Item` | `sendCG_GetCharacterValues_Req`, `sendCG_GetWeekChampionData_Req`, `sendCG_TakeWeekAward_Req`, `sendCG_UpdateMessage_Req` | `src.Net.Send.LoginSend`, `src.Net.Send.WorldBossSend` | `ItemInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Item/BuyInfoMgr.lua` | `Item` | `sendCG_BuyProduct_Req`, `sendCG_GetCharacterValues_Req` | `src.Net.NetMgr`, `src.Net.Send.LoginSend`, `src.Net.Send.MarketSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/BuyInfoMgr2.lua` | `Item` | `sendCG_BuyMarketItem_Req`, `sendCG_GetCharacterValues_Req` | `src.Net.NetMgr`, `src.Net.Send.LoginSend`, `src.Net.Send.MarketSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/BuyItemViewMgr.lua` | `Item` | `sendCG_BuyActivityShopItem_Req`, `sendCG_BuyGoods_Req`, `sendCG_BuyMarketItem_Req` | `src.Net.Send.ActivitySend`, `src.Net.Send.CommonShopSend`, `src.Net.Send.MarketSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/CollectPetActivityViewMgr.lua` | `Item` | `sendCG_FinishPokemonAchievementActivity_Req`, `sendCG_GetPetWikiActivity_Req`, `sendCG_GetPokemonAchievementsAct_Req` | `src.Net.Send.ActivitySend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/DropInfoViewMgr.lua` | `Item` | — | — | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/FurnitureSofaMgr.lua` | `Item` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/FurnitureTVMgr.lua` | `Item` | `sendCG_RefreshMapNodeEvent_Req` | `src/Net/Send/AdventureSend.lua` | — |
| `decoded_lua/assets/src/GameMgr/Item/FurnitureViewMgr.lua` | `Item` | `sendCG_BuyPacket_Req`, `sendCG_ChangeChannel_Req` | `src.Net.Send.ChatSend`, `src.Net.Send.ItemSend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Item/GachaViewMgr.lua` | `Item` | `sendCG_CapsuleEggAllInfoCmd_Req`, `sendCG_CapsuleEggCDs_Req`, `sendCG_CapsuleEgg_Req`, `sendCG_Chat_Req` | `cjson`, `src.Net.Send.ChatSend`, `src.Net.Send.PetSend`, `src.framework.scheduler` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/HalloweenCapsuleEggView.lua` | `Item` | `sendCG_TimeLimitCapsuleEgg_Req` | `cjson`, `src.Net.Send.ActivitySend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ItemInfoViewMgr.lua` | `Item` | `sendCG_CompoundPetPiece_Req`, `sendCG_SellItem_Req`, `sendCG_UseItem_Req` | `cjson`, `src.GameMgr.Item.MultiItemBoxView`, `src.Net.Send.ItemSend`, `src.Net.Send.PetSend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `SkillInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ItemNumViewMgr.lua` | `Item` | — | — | `ItemInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Item/MailMgr.lua` | `Item` | `sendCG_CheckUnReadMail_Req`, `sendCG_DelMail_Req`, `sendCG_GetMailAttach_Req`, `sendCG_GetMail_Req`, `sendCG_GetSomeMails_Req` | `cjson`, `src.Net.Send.MailSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/MultiItemBoxView.lua` | `Item` | `sendCG_UseItem_Req` | `cjson`, `src.DatReader.SelectableAwardInfoConfig`, `src.Net.Send.ItemSend` | `ItemInfo`, `PokemonInfo`, `SelectableAwardInfo` |
| `decoded_lua/assets/src/GameMgr/Item/PurchaseViewMgr.lua` | `Item` | `sendCG_GetActivitiesData_Req`, `sendCG_GetVipAward_Req`, `sendCG_RechargeCD_Req`, `sendCG_RechargeTestCmd_Req`, `sendCG_VipAwardInfo_Req` | `cjson`, `src.GameMgr.Item.AwardSelectViewMgr`, `src.Net.Send.ActivitySend`, `src.Net.Send.MonthCardSend`, `src.Net.Send.VipSend`, `src.framework.scheduler` | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/RechargeViewMgr.lua` | `Item` | `sendCG_GetActivitiesData_Req` | `src.Net.Send.ActivitySend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/SellInfoMgr.lua` | `Item` | `sendCG_SellOnMarket_Req` | `src.Net.Send.MarketSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/SevenDaysActivity.lua` | `Item` | `sendCG_GetSevenDayAward_Req` | `src.DatReader.SevenDayInfoConfig`, `src.GameMgr.Item.AwardSelectViewMgr`, `src.GameMgr.TaskWatcher.MeiRiLiBaoWatcher`, `src.Net.Send.ActivitySend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/ShopListMgr.lua` | `Item` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Item/SkillBookViewMgr.lua` | `Item` | `sendCG_CompoundPetSkill_Req`, `sendCG_GetPetSkillWiki_Req`, `sendCG_ResolvePetSkill_Req` | `src.Net.Send.PetSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Item/TrainStoneMgr.lua` | `Item` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/VipShopViewMgr.lua` | `Item` | `sendCG_GetCharacterValues_Req` | `src.Net.Send.LoginSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Item/WishCoinShop/WishCoinShopTopBar.lua` | `Item` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Item/WishCoinShop/WishCoinShopView.lua` | `Item` | `sendCG_SystemRefreshGoods_Req`, `sendCG_getShop_Req` | `cjson`, `src.GameMgr.Item.WishCoinShop.WishCoinShopTopBar`, `src.Net.Send.CommonShopSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LTGuideMgr.lua` | `LostTower` | — | — | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LostTowerMgr.lua` | `LostTower` | `sendCG_GetLostTowerData_Req`, `sendCG_RecoverStepNumber_Req`, `sendCG_moveNewCell_Req` | `cjson`, `src.GameMgr.LostTower.LtMapOption`, `src.Net.Send.LostTowerSend`, `src/Net/Send/LostTowerSend.lua` | `LostTowerInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LostTowerUIMgr.lua` | `LostTower` | `sendCG_QueryFloorRank_Req`, `sendCG_QueryPointRank_Req`, `sendCG_ResetShop_Req`, `sendCG_getShop_Req` | `cjson`, `framework.scheduler`, `src.GameMgr.Battle.BattleFuncMgr`, `src.GameMgr.LostTower.LtMapNodeMgr`, `src.GameMgr.Searching.advNodePool`, `src.Net.Send.CommonShopSend`, `src.Net.Send.LostTowerSend` | `ItemInfo`, `LostTowerInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtChangeFloorView.lua` | `LostTower` | — | — | `LostTowerInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtEventOption.lua` | `LostTower` | `sendCG_FireAdventureEvent_Req` | `src.Net.Send.AdventureSend` | `AdventureInfo`, `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtExBufferMgr.lua` | `LostTower` | — | `cjson` | `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtExchangeViewMgr.lua` | `LostTower` | `sendCG_BuyGoods_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_RefreshGoods_Req`, `sendCG_ResetShop_Req`, `sendCG_SystemRefreshGoods_Req`, `sendCG_getShop_Req` | `src.Net.Send.CommonShopSend`, `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtFuncMgr.lua` | `LostTower` | `sendCG_ChangeFloor_Req`, `sendCG_EnterTransferDoor_Req`, `sendCG_MoneyOpenChest_Req`, `sendCG_fireEventCell_Req`, `sendCG_moveNewCell_Req`, `sendCG_onTrap_Req` | `cjson`, `src.GameMgr.LostTower.LTGuideMgr`, `src.Net.Send.LostTowerSend`, `src/Net/Send/LostTowerSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtHealViewMgr.lua` | `LostTower` | `sendCG_RecoverState_Req` | `src.DatReader.RecoverStateInfoConfig`, `src.GameMgr.TaskWatcher.TaskWatcherManager`, `src.Net.Send.LostTowerSend` | `ItemInfo`, `LostTowerInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtMapEnvMgr.lua` | `LostTower` | — | — | — |
| `decoded_lua/assets/src/GameMgr/LostTower/LtMapNodeMgr.lua` | `LostTower` | — | `src.GameMgr.LostTower.LostTowerMgr`, `src.GameMgr.LostTower.LtMapOption` | — |
| `decoded_lua/assets/src/GameMgr/LostTower/LtMapOption.lua` | `LostTower` | — | — | — |
| `decoded_lua/assets/src/GameMgr/LostTower/LtOpenBoxView.lua` | `LostTower` | — | — | `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtPetsMgr.lua` | `LostTower` | `sendCG_changeReadyPet_Req` | `src.Net.Send.LostTowerSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtPickPetViewMgr.lua` | `LostTower` | `sendCG_changeReadyPet_Req` | `src.GameMgr.Battle.BattleFuncMgr`, `src.Net.Send.LostTowerSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtPlayerMgr.lua` | `LostTower` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtPropMgr.lua` | `LostTower` | `sendCG_UseLostTowerItem_Req` | `cjson`, `src.Net.Send.LostTowerSend` | `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtRankAwardList.lua` | `LostTower` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtRankingViewMgr.lua` | `LostTower` | — | — | `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtResetViewMgr.lua` | `LostTower` | `sendCG_resetData_Req` | `src.DatReader.LostTowerResetInfoConfig`, `src.GameMgr.TaskWatcher.TaskWatcherManager`, `src/Net/Send/LostTowerSend.lua` | `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtStepAddView.lua` | `LostTower` | `sendCG_UseItem_Req` | `src.Net.Send.ItemSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtTransferViewMgr.lua` | `LostTower` | `sendCG_GetCharacterValues_Req`, `sendCG_TransferFloor_Req` | `src.GameMgr.TaskWatcher.TaskWatcherManager`, `src.Net.Send.LoginSend`, `src.Net.Send.LostTowerSend` | `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/LostTower/LtWarFogMgr.lua` | `LostTower` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/AllWorldMapMgr.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/BattleMapMgr.lua` | `Map` | `sendCG_CreatePVEBattle_Req`, `sendCG_GetFashions_Req`, `sendCG_PVEBattleEnd_Req` | `cjson`, `src.GameMgr.Battle.BattleCotroller`, `src.GameMgr.Battle.BattleGetPetInfo`, `src.Net.Send.FashionSend`, `src.Net.Send.PVESend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Map/BossMapMgr.lua` | `Map` | — | — | `PokemonInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Map/CopyAStar.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/CopyMapMgr.lua` | `Map` | — | `src.GameMgr.Map.CopyAStar` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Map/EmbeddedMapMgr.lua` | `Map` | `sendCG_TriggerNodeEvent_Req` | `src.Net.Send.AdventureSend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Map/ExploreMapMgr.lua` | `Map` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Map/FamilyCopyMapMgr.lua` | `Map` | — | `cjson` | — |
| `decoded_lua/assets/src/GameMgr/Map/HomeMapMgr.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/IdlingMapBoardMgr.lua` | `Map` | `sendCG_Explore_Req` | `src.Net.Send.ExploreSend` | `ExperienceInfo`, `ExploreInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Map/IdlingMapMgr.lua` | `Map` | `sendCG_EndExplore_Req` | `src.Net.Send.ExploreSend` | `ExploreInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Map/MapSeekerMgr.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/MiniMapMgr.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/SceneMgr.lua` | `Map` | — | `src.GameMgr.Update.UpdateMgr`, `src.app.scenes.` | — |
| `decoded_lua/assets/src/GameMgr/Map/SearchingMapMgr.lua` | `Map` | — | `cjson` | `AdventureInfo` |
| `decoded_lua/assets/src/GameMgr/Map/TeamCopyMapMgr.lua` | `Map` | `sendCG_GetMyTeam_Req` | `cjson`, `src.Net.Send.TeamSend` | — |
| `decoded_lua/assets/src/GameMgr/Map/TownMapBoardMgr.lua` | `Map` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Map/TownMapMgr.lua` | `Map` | `sendCG_Chat_Req`, `sendCG_QuerySelfTerritoryIDInfo_Req` | `cjson`, `src.Net.Send.ChatSend`, `src.Net.Send.TerritorialSend` | `PokemonInfo`, `TerritorialInfo` |
| `decoded_lua/assets/src/GameMgr/Map/WorldMapAwardsMgr.lua` | `Map` | `sendCG_GetCharacterValues_Req`, `sendCG_GetMapStarAward_Req` | `src.Net.Send.AdventureSend`, `src.Net.Send.LoginSend` | `AdventureInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Map/WorldMapMgr.lua` | `Map` | `sendCG_Chat_Req`, `sendCG_GetAdvAward_Req` | `cjson`, `src.Net.Send.AdventureSend`, `src.Net.Send.ChatSend` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `QuestInfo`, `TerritorialInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Map/WorldMapMoveMgr.lua` | `Map` | `sendCG_UseItem_Req` | `src.Net.Send.ItemSend` | `AdventureInfo`, `ItemInfo`, `TerritorialInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Mission/AchievementListMgr.lua` | `Mission` | `sendCG_BuyPotential_Req`, `sendCG_FinishAchievement_Req`, `sendCG_FinishPokemonAchievement_Req`, `sendCG_GetAchievements_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetPokemonAchievements_Req`, `sendCG_GetPotentials_Req`, `sendCG_ResetAchievement_Req` | `src.DatReader.PotentialInfoConfig`, `src.Net.Send.AchievementSend`, `src.Net.Send.LoginSend` | `AchievementInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Mission/MissionGuideMgr.lua` | `Mission` | — | — | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Mission/MissionInfoMgr.lua` | `Mission` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Mission/MissionListMgr.lua` | `Mission` | `sendCG_GetCharacterValues_Req`, `sendCG_GetDailyQuestStepAward_Req` | `src.Net.Send.LoginSend`, `src.Net.Send.NewQuestSend` | `ItemInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Mission/NpcDialogueMgr.lua` | `Mission` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Mission/NpcMgr.lua` | `Mission` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Mission/TownMissionMgr.lua` | `Mission` | — | — | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/ObjectPool.lua` | `ObjectPool.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/OrderMan/OrderManDataMgr.lua` | `OrderMan` | — | `src.DatReader.PasswordProductInfoConfig`, `src.GameMgr.OrderMan.OrderManServerMgr` | — |
| `decoded_lua/assets/src/GameMgr/OrderMan/OrderManServerMgr.lua` | `OrderMan` | `sendCG_BuyPasswordProduct_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_PasswordGift_Req` | `src.Net.Send.LoginSend`, `src.Net.Send.OrderManSend` | — |
| `decoded_lua/assets/src/GameMgr/OrderMan/OrderManUIMgr.lua` | `OrderMan` | — | `cjson`, `src.GameMgr.OrderMan.OrderManDataMgr` | `ItemInfo`, `PetEquipInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/BasicPetListMgr.lua` | `Pet` | — | — | `ExperienceInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/BasicValueCalc.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/BattleManualMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/CommonPetBar.lua` | `Pet` | — | `src.GameMgr.Battle.BattleFuncMgr` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/EduConsViewMgr.lua` | `Pet` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/EduSkillPageMgr.lua` | `Pet` | `sendCG_ChangePetEvoSkill_Req`, `sendCG_PokemonSkillChange_Req`, `sendCG_PokemonSkillLevelUp_Req` | `src.GameMgr.Pet.PetSkillIconMgr`, `src.Net.Send.PetEducationSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/GetMatsViewMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/PetChangeNameMgr.lua` | `Pet` | `sendCG_ChangePetName_Req` | `src.Net.Send.PetSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetCommonListViewMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEatPetViewMgr.lua` | `Pet` | `sendCG_EatPet_Req` | `src/Net/Send/PetEducationSend.lua` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEducationMgr.lua` | `Pet` | `sendCG_AddYokePet_Req`, `sendCG_ChangeYokePet_Req`, `sendCG_DelYokePet_Req`, `sendCG_PetStrengOverflow_Req`, `sendCG_PokemonAdvaStageLevel_Req`, `sendCG_ResetPetStreng_Req` | `cjson`, `src.GameMgr.Pet.GetMatsViewMgr`, `src.GameMgr.Pet.PetEducationMgrA`, `src.GameMgr.Pet.PetEducationMgrB`, `src.GameMgr.Pet.PetEducationMgrC`, `src.GameMgr.Pet.PetFeedViewMgr`, `src.Net.Send.PetEducationSend`, `src/Net/Send/PetEducationSend.lua` | `AchievementInfo`, `ExperienceInfo`, `ItemInfo`, `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEducationMgrA.lua` | `Pet` | — | `src.DatReader.PotentialInfoConfig` | `AchievementInfo`, `PokemonInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEducationMgrB.lua` | `Pet` | `sendCG_DelYokePet_Req` | `src/Net/Send/PetEducationSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEducationMgrC.lua` | `Pet` | `sendCG_ClearEvoSkills_Req` | `src.GameMgr.Pet.EduSkillPageMgr`, `src/Net/Send/PetEducationSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEffectMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/PetEquipmentEvaluateMgr.lua` | `Pet` | — | — | `ItemInfo`, `PetEquipInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEquipmentMgr.lua` | `Pet` | — | `cjson` | `ItemInfo`, `PetEquipInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEquipmentOperationMgr.lua` | `Pet` | — | — | `PetEquipInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEquipmentRestoreMgr.lua` | `Pet` | — | — | `ItemInfo`, `PetEquipInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEquipmentStrengthenEffectMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/PetEvolutionEffectMgr.lua` | `Pet` | — | — | `PokemonInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetEvolutionMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetExploreInfoMgr.lua` | `Pet` | — | — | `ExploreInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetExploreMgr.lua` | `Pet` | `sendCG_BuyExplorePacket_Req`, `sendCG_EndExplore_Req`, `sendCG_Explore_Req`, `sendCG_GetExploreData_Req`, `sendCG_QuerySelfTerritoryIDInfo_Req` | `src.Net.Send.ExploreSend`, `src.Net.Send.TerritorialSend` | `ExploreInfo`, `ItemInfo`, `PokemonInfo`, `TerritorialInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetExploreRewardsMgr.lua` | `Pet` | `sendCG_BuyExplorePacket_Req`, `sendCG_EndExplore_Req` | `src.Net.Send.ExploreSend` | `ExploreInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetFCEffectMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/PetFeedViewMgr.lua` | `Pet` | `sendCG_UseItem_Req` | `src.Net.Send.ItemSend` | `ExperienceInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetFormationMgr.lua` | `Pet` | `sendCG_UpdatePetArmys_Req` | `src.Net.Send.PetSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetFreeListMgr.lua` | `Pet` | — | `cjson` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetGetViewMgr.lua` | `Pet` | — | — | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetHandBook.lua` | `Pet` | — | `src.framework.scheduler` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetInfoViewMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetListMgr.lua` | `Pet` | `sendCG_BuyPacket_Req`, `sendCG_PetFreedom_Req`, `sendCG_UpdatePetArmys_Req` | `src.GameMgr.Battle.BattleFuncMgr`, `src.Net.Send.ItemSend`, `src.Net.Send.PetSend` | `ExperienceInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetMenuMgr.lua` | `Pet` | `sendCG_GetPetArmys_Req` | `src.Net.Send.PetSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetQuickTrainViewMgr.lua` | `Pet` | `sendCG_PetStreng_Req` | `framework.json`, `src/Net/Send/PetEducationSend.lua` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetQuickViewMgr.lua` | `Pet` | `sendCG_PetStarUp_Req`, `sendCG_PokemonAdvaStageLevel_Req` | `src/Net/Send/PetEducationSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetSkillIconMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetSkillViewMgr.lua` | `Pet` | `sendCG_PokemonSkillChange_Req`, `sendCG_PokemonSkillLevelUp_Req` | `src.Net.Send.PetEducationSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetStarUpMgr.lua` | `Pet` | `sendCG_PetStarUp_Req` | `src/Net/Send/PetEducationSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetStarupEffectMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetStarupResetViewMgr.lua` | `Pet` | `sendCG_ResetPetStar_Req` | `src/Net/Send/PetEducationSend.lua` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PetStrengthenMgr.lua` | `Pet` | — | — | `ExperienceInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PickItemViewMgr.lua` | `Pet` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PickPurifyViewMgr.lua` | `Pet` | — | — | `ItemInfo`, `PetEquipInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/PokedexMgr.lua` | `Pet` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Pet/TipsViewMgr.lua` | `Pet` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Pet/petTrainLimitMaterialView.lua` | `Pet` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaEffectMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/ArenaExchangeMgr.lua` | `Player` | `sendCG_BuyGoods_Req`, `sendCG_RefreshGoods_Req`, `sendCG_SystemRefreshGoods_Req` | `src.Net.Send.CommonShopSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaMainMgr.lua` | `Player` | — | `src.GameMgr.Player.WorldPKUIMgr` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaPKViewMgr.lua` | `Player` | `sendCG_CancelJoinPVPArena_Req`, `sendCG_JoinPVPArena_Req` | `src.Net.Send.PVPSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaRecordMgr.lua` | `Player` | `sendCG_GetArenaRecode_Req`, `sendCG_PlayArenaRecode_Req` | `cjson`, `src.Net.Send.ArenaSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/ArenaRewardList.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaTeamViewMgr.lua` | `Player` | `sendCG_ChangeArenaPetObjIDs_Req` | `src.Net.Send.ArenaSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaViewMgr.lua` | `Player` | `sendCG_ArenaRankFight_Req`, `sendCG_BuyArenaFightTimes_Req`, `sendCG_ClearArenaCD_Req`, `sendCG_GetArenaRecode_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_JoinArena_Req`, `sendCG_QueryArenaData_Req`, `sendCG_QueryArenaRank_Req`, `sendCG_QueryArenaSoldierDetail_Req`, `sendCG_RandomArenaEnemys_Req`, `sendCG_ResetShop_Req`, `sendCG_SystemRefreshGoods_Req`, `sendCG_getShop_Req` | `src.Net.Send.ArenaSend`, `src.Net.Send.CommonShopSend`, `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ArenaWinViewMgr.lua` | `Player` | `sendCG_GetArenaRecode_Req`, `sendCG_PlayArenaRecode_Req` | `cjson`, `src.Net.Send.ArenaSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/AvatarViewMgr.lua` | `Player` | `sendCG_GetFashions_Req`, `sendCG_SetFashions_Req` | `src.Net.Send.FashionSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/BossFailedMgr.lua` | `Player` | — | — | `PokemonInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Player/BossTopBarMgr.lua` | `Player` | — | — | `PokemonInfo`, `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Player/CheckViewMgr.lua` | `Player` | `sendCG_LoadSigninData_Req`, `sendCG_SigninRepair_Req`, `sendCG_Signin_Req` | `src.Net.Send.SigninSend`, `src.framework.scheduler` | `ItemInfo`, `PokemonInfo`, `SigninRepairCostInfo` |
| `decoded_lua/assets/src/GameMgr/Player/CreateFamilyMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/ExchangeViewMgr.lua` | `Player` | `sendCG_BuyGCash_Req`, `sendCG_BuyPower_Req`, `sendCG_GetCharacterValues_Req` | `src.Net.Send.LoginSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/ExitGameViewMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/ExploreViewMgr.lua` | `Player` | `sendCG_GetCharacterValues_Req`, `sendCG_GetServerTime_Req` | `src.Net.Send.LoginSend` | `ExploreInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyApplyListViewMgr.lua` | `Player` | — | `cjson` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyCopyBonusMgr.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyCopyEventMgr.lua` | `Player` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyCopyMgr.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyCopyTopBarMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyDonateMgr.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyFloorInfoMgr.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyIconMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyInfoMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyListViewMgr.lua` | `Player` | `sendCG_Family_Req` | `cjson`, `src.Net.Send.FamilySend` | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyLogViewMgr.lua` | `Player` | — | — | `ItemInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyNpcManagerViewMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyPlayerViewMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyQuestListMgr.lua` | `Player` | — | — | `ItemInfo`, `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilyShopMgr.lua` | `Player` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FamilySignData.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilySignServer.lua` | `Player` | `sendCG_Family_Req`, `sendCG_GetCharacterValues_Req` | `src.Net.Send.FamilySend`, `src.Net.Send.LoginSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilySignView.lua` | `Player` | — | `cjson`, `src.GameMgr.Player.FamilySignData` | — |
| `decoded_lua/assets/src/GameMgr/Player/FamilyTransListViewMgr.lua` | `Player` | — | `cjson` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/FriendsViewMgr.lua` | `Player` | `sendCG_AddFriend_Req`, `sendCG_BuyRedHeartGoods_Req`, `sendCG_ConfirmAddFriend_Req`, `sendCG_DelFriend_Req`, `sendCG_DisbandAllFriendApply_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetFriendDetail_Req`, `sendCG_GetMyFriends_Req`, `sendCG_GetMyRedHeartShopInfo_Req`, `sendCG_GetRecommendFriend_Req`, `sendCG_GetRedHeartShopInfo_Req`, `sendCG_RedHeart_Req`, `sendCG_StartPVP_Req`, `sendCG_UpdateFriendDetail_Req` | `cjson`, `src.Net.Send.ChatUserSend`, `src.Net.Send.LoginSend`, `src.Net.Send.NewShopSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/LevelUpViewMgr.lua` | `Player` | — | — | `ExperienceInfo` |
| `decoded_lua/assets/src/GameMgr/Player/LifeSkillBatchMaker.lua` | `Player` | — | `src.GameMgr.Item.ItemInfoViewMgr` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/LifeSkillFilterPopUp.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/LifeSkillJobChangeViewMgr.lua` | `Player` | `sendCG_ChangeLifeCareer_Req` | `src.Net.Send.LifeSkillSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/LifeSkillLstViewMgr.lua` | `Player` | `sendCG_BuyDrawings_Req`, `sendCG_ChangeLifeCareer_Req`, `sendCG_Manufacture_Req` | `cjson`, `src.GameMgr.Item.ItemInfoViewMgr`, `src.Net.Send.LifeSkillSend` | `AdventureInfo`, `ExperienceInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/LifeSkillSelViewMgr.lua` | `Player` | `sendCG_ChangeLifeCareer_Req`, `sendCG_GetLifeSkillData_Req`, `sendCG_Manufacture_Req`, `sendCG_UnlockLifeSkill_Req` | `cjson`, `src.Net.Send.LifeSkillSend` | `ExperienceInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/MArenaViewMgr.lua` | `Player` | `sendCG_BuyMArenaFightTimes_Req`, `sendCG_ClearArenaCD_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetFriendDetail_Req`, `sendCG_GetMArenaRecode_Req`, `sendCG_JoinMArena_Req`, `sendCG_MArenaRankFight_Req`, `sendCG_QueryMArenaData_Req`, `sendCG_QueryMArenaRank_Req`, `sendCG_QueryMArenaSoldierDetail_Req`, `sendCG_RandomMArenaEnemys_Req`, `sendCG_ResetShop_Req`, `sendCG_SystemRefreshGoods_Req`, `sendCG_getShop_Req` | `src.Net.Send.ArenaSend`, `src.Net.Send.ChatUserSend`, `src.Net.Send.CommonShopSend`, `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/MyFamilyLstViewMgr.lua` | `Player` | — | `cjson` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/NoticeViewMgr.lua` | `Player` | `sendCG_GetBulletin_Req`, `sendCG_ListBulletin_Req` | `src.Net.Send.BulletinSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/PVPQuestListMgr.lua` | `Player` | `sendCG_CommitPVPArenaQuest_Req`, `sendCG_GetMYPVPArenaQuests_Req`, `sendCG_GetPVPArenaQuestPowerAward_Req`, `sendCG_ResetPVPArenaQuest_Req` | `src.Net.Send.PVPSend` | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PVPQuestRank.lua` | `Player` | `sendCG_GetMyPVPArenaRank_Req`, `sendCG_GetPVPArenaRank_Req` | `src.DatReader.PVPArenaRankAwardConfig`, `src.Net.Send.PVPSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PVPQuestShopMgr.lua` | `Player` | `sendCG_BuyGoods_Req`, `sendCG_RefreshGoods_Req`, `sendCG_ResetShop_Req`, `sendCG_SystemRefreshGoods_Req`, `sendCG_getShop_Req` | `src.Net.Send.CommonShopSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PersonalCenterMgr.lua` | `Player` | `sendCG_GetFriendDetail_Req`, `sendCG_SetCharSign_Req` | `src.GameMgr.Player.PlayerChangeNameMgr`, `src.Net.Send.ChatUserSend`, `src.Net.Send.LoginSend` | `ExperienceInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PlayerAnimeMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/PlayerChangeNameMgr.lua` | `Player` | `sendCG_ChangeName_Req` | `src.Net.Send.ItemSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PlayerInfoViewMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/PlayerOperationMgr.lua` | `Player` | `sendCG_AddFriend_Req`, `sendCG_StartPVP_Req` | `src.Net.Send.ChatUserSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/PlayerShareMgr.lua` | `Player` | `sendCG_CheckUserCode_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_NewAccountBindOldRoleID_Req` | `src.Net.Send.LoginSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/PokedexMenuViewMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/RewardListView.lua` | `Player` | — | — | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ScienceDevelopMgr.lua` | `Player` | `sendCG_ScienceLevelUp_Req`, `sendCG_ScienceStarUp_Req` | `src.Net.Send.PetSend` | `ItemInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Player/ScienceViewMgr.lua` | `Player` | `sendCG_GetScienceDatas_Req`, `sendCG_ResetScienceConsumes_Req`, `sendCG_ScienceConsume_Req` | `src.Net.Send.PetSend` | `ItemInfo`, `ScienceInfo` |
| `decoded_lua/assets/src/GameMgr/Player/SearchFamilyMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/SelectBeautyViewMgr.lua` | `Player` | `sendCG_GetCharacterValues_Req`, `sendCG_GetFashionShowPeopers_Req`, `sendCG_GetFashionShowRank_Req`, `sendCG_GetFashions_Req`, `sendCG_GetLikeList_Req`, `sendCG_GetMyFriends_Req`, `sendCG_GetSingleFashionShow_Req`, `sendCG_LikeFashionShow_Req`, `sendCG_SaveFashionShow_Req`, `sendCG_TakeFashionShowRankAward_Req` | `cjson`, `src.Net.Send.ChatUserSend`, `src.Net.Send.FashionSend`, `src.Net.Send.FashionShowSend`, `src.Net.Send.LoginSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TeamCopyTopBarMgr.lua` | `Player` | — | — | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TeamCopyWinMgr.lua` | `Player` | `sendCG_OpenTreasureBox_Req`, `sendCG_SelectTreasureBox_Req`, `sendCG_UnlockTreasureBox_Req` | `src.Net.Send.TreasureBoxSend` | `TreasureBoxInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TeamDropMgr.lua` | `Player` | — | — | `ItemInfo`, `TreasureBoxInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TeamInviteMgr.lua` | `Player` | `sendCG_GetFriendDetail_Req`, `sendCG_GetMyFriends_Req`, `sendCG_InviteTeamMember_Req`, `sendCG_KickTeamMember_Req` | `cjson`, `src.Net.Send.ChatUserSend`, `src.Net.Send.TeamSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/TeamViewMgr.lua` | `Player` | `sendCG_AutoJoinTeam_Req`, `sendCG_CancelAutoJoinTeam_Req`, `sendCG_CreateTeam_Req`, `sendCG_OpenTreasureBox_Req`, `sendCG_SetTeamAutoJoin_Req`, `sendCG_SetTeamPets_Req`, `sendCG_SetTeamReady_Req`, `sendCG_SetTeamSort_Req`, `sendCG_UnlockTreasureBox_Req` | `src.Net.Send.TeamSend`, `src.Net.Send.TreasureBoxSend` | `PokemonInfo`, `TreasureBoxInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TownPlayerListMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/TownPlayerMgr.lua` | `Player` | — | `cjson` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/TownTreeMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Player/TreeInfoView.lua` | `Player` | `sendCG_GetCharacterValues_Req`, `sendCG_GetWishingTreesData_Req`, `sendCG_PrayToTree_Req` | `cjson`, `src.Net.Send.LoginSend`, `src.Net.Send.WishingTreeSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/WorldPKDataMgr.lua` | `Player` | — | `src.DatReader.WArenaRankAwardConfig`, `src.GameMgr.Player.WorldPKServerMgr` | — |
| `decoded_lua/assets/src/GameMgr/Player/WorldPKServerMgr.lua` | `Player` | `sendCG_BuyWArenaFightTimes_Req`, `sendCG_GetCharacterValues_Req`, `sendCG_GetWArenaRecode_Req`, `sendCG_JoinWArena_Req`, `sendCG_PlayWArenaRecode_Req`, `sendCG_QueryWArenaRank_Req`, `sendCG_RandomWArenaEnemys_Req`, `sendCG_WArenaRankFight_Req` | `cjson`, `src.GameMgr.Player.WorldPKUIMgr`, `src.Net.Send.LoginSend`, `src.Net.Send.WArenaSend` | — |
| `decoded_lua/assets/src/GameMgr/Player/WorldPKUIMgr.lua` | `Player` | — | `src.GameMgr.Player.RewardListView`, `src.GameMgr.Player.WorldPKDataMgr` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Player/WorldPlayerMgr.lua` | `Player` | — | — | — |
| `decoded_lua/assets/src/GameMgr/PlistMgr.lua` | `PlistMgr.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/ProtoErrorTransferText.lua` | `ProtoErrorTransferText.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Searching/AdvCharMgr.lua` | `Searching` | `sendCG_LostTowerPVPBattleEnd_Req`, `sendCG_fireEventCell_Req` | `framework.scheduler`, `src.Net.Send.LostTowerSend`, `src/Net/Send/LostTowerSend.lua` | `ItemInfo`, `LostTowerInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvClearView.lua` | `Searching` | — | — | `AdventureInfo`, `ExperienceInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvConfirmMgr.lua` | `Searching` | `sendCG_ActivePetArmy_Req`, `sendCG_CreateAdventure_Req`, `sendCG_QuickClearAdventure_Req` | `src.GameMgr.Searching.itemDescViewMgr`, `src.Net.Send.PetSend`, `src/Net/Send/AdventureSend.lua` | `AdventureInfo`, `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvConfirmMgrNew.lua` | `Searching` | `sendCG_CreateAdventure_Req`, `sendCG_QuickClearAdventure_Req`, `sendCG_ResetAdventureTimes_Req`, `sendCG_TerritorialResetInfo_Req`, `sendCG_TerritoryCountInfo_Req`, `sendCG_TerritoryFight_Req` | `src.GameMgr.Item.ItemInfoViewMgr`, `src.Net.Send.AdventureSend`, `src.Net.Send.TerritorialSend`, `src.framework.scheduler`, `src/Net/Send/AdventureSend.lua` | `AdventureInfo`, `ItemInfo`, `PokemonInfo`, `TerritorialInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvEnvironmentMgr.lua` | `Searching` | — | — | `AdventureInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvFailedView.lua` | `Searching` | `sendCG_CreateAdventure_Req` | `src/Net/Send/AdventureSend.lua` | `AdventureInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvPetsMgr.lua` | `Searching` | `sendCG_ActivePetArmy_Req`, `sendCG_AdventureDamage_Req`, `sendCG_UpdatePetArmys_Req` | `src.GameMgr.Searching.AdvFailedView`, `src.Net.Send.PetSend`, `src/Net/Send/AdventureSend.lua` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/AdvStarMgr.lua` | `Searching` | — | — | `AdventureInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/Astar.lua` | `Searching` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Searching/Point.lua` | `Searching` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Searching/SearchingFuncMgr.lua` | `Searching` | `sendCG_FinishAdventure_Req`, `sendCG_GetAdventureAward_Req`, `sendCG_MoveObstacle_Req`, `sendCG_fireEventCell_Req` | `src.GameMgr.Searching.AdvClearView`, `src.GameMgr.Searching.SkillMissingView`, `src.GameMgr.Searching.advNpcShopMgr`, `src.GameMgr.Searching.propMgr`, `src.framework.cc.utils.bit`, `src/Net/Send/AdventureSend.lua`, `src/Net/Send/LostTowerSend.lua` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/SearchingMgr.lua` | `Searching` | `sendCG_FinishAdventure_Req`, `sendCG_fireEventCell_Req` | `framework.scheduler`, `src.GameMgr.Searching.AdvFailedView`, `src.GameMgr.Searching.Astar`, `src.GameMgr.Searching.Point`, `src.GameMgr.Searching.propMgr`, `src/Net/Send/AdventureSend.lua`, `src/Net/Send/LostTowerSend.lua` | `AdventureInfo`, `EventInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/SearchingUIMgr.lua` | `Searching` | — | `src.GameMgr.Battle.BattleFuncMgr`, `src.GameMgr.CommonDungeon.DungeonMapMgr`, `src.GameMgr.Searching.advNodePool`, `src.GameMgr.Searching.propMgr` | `AdventureInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/SkillMissingView.lua` | `Searching` | — | — | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/StageBossListMgr.lua` | `Searching` | `sendCG_QueryArenaSoldierDetail_Req`, `sendCG_SelfTerritoryInfo_Req`, `sendCG_TerritoryInfoNoPets_Req`, `sendCG_TerritoryRankInfo_Req` | `src.GameMgr.Item.ItemInfoViewMgr`, `src.Net.Send.ArenaSend`, `src.Net.Send.TerritorialSend` | `AdventureInfo`, `ExploreInfo`, `ItemInfo`, `LostTowerInfo`, `PokemonInfo`, `TerritorialInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/advNodePool.lua` | `Searching` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Searching/advNpcShopMgr.lua` | `Searching` | `sendCG_BuyNpcShopGoods_Req` | `src.Net.Send.AdventureSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/advResetView.lua` | `Searching` | `sendCG_ResetAdventure_Req` | `src.GameMgr.Searching.propMgr`, `src/Net/Send/AdventureSend.lua` | `AdventureInfo`, `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/Searching/itemDescViewMgr.lua` | `Searching` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Searching/propMgr.lua` | `Searching` | — | `framework.scheduler`, `src.GameMgr.Searching.itemDescViewMgr` | — |
| `decoded_lua/assets/src/GameMgr/Support/AndroidFunction.lua` | `Support` | `sendCG_ImportEthPet_Req` | `src.GameMgr.Support.iOSFunction`, `src.Net.Send.PetSend` | — |
| `decoded_lua/assets/src/GameMgr/Support/BaseFunction.lua` | `Support` | `sendCG_GetServerTime_Req` | `src.Net.Send.LoginSend`, `src.framework.scheduler` | `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Support/CommonList.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/CopyMapLoadingMgr.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/GameAudio.lua` | `Support` | — | `src.DatReader.SoundEffectInfoConfig` | — |
| `decoded_lua/assets/src/GameMgr/Support/GetRandom.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/HighPerformList.lua` | `Support` | — | `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Support/IAPMgr.lua` | `Support` | — | `src.framework.cc.sdk.Store` | — |
| `decoded_lua/assets/src/GameMgr/Support/LoadingView.lua` | `Support` | — | `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Support/LuaSqlite.lua` | `Support` | — | `lsqlite3`, `src.GameMgr.Support.AndroidFunction`, `src.framework.crypto` | — |
| `decoded_lua/assets/src/GameMgr/Support/NetInterface.lua` | `Support` | — | `src.Net.CallbackMgr`, `src.Net.NetMgr`, `src.Net.Send.NewQuestSend` | `WorldBossInfo` |
| `decoded_lua/assets/src/GameMgr/Support/OvertimeListener.lua` | `Support` | — | `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Support/PlatformConfig.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/QRCodeMgr.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/RichLabel.lua` | `Support` | — | `framework.json` | — |
| `decoded_lua/assets/src/GameMgr/Support/TxtReader.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/UIDrag.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/UnblockLoader.lua` | `Support` | — | `coroutine`, `src.framework.scheduler` | — |
| `decoded_lua/assets/src/GameMgr/Support/UserSettings.lua` | `Support` | — | `lfs` | — |
| `decoded_lua/assets/src/GameMgr/Support/Utility.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/Voice/Impl_android.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/Voice/Impl_ios.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/Voice/Impl_windows.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/Voice/VoiceManager.lua` | `Support` | — | `src.GameMgr.Support.Voice.VoiceServerConfig` | — |
| `decoded_lua/assets/src/GameMgr/Support/Voice/VoiceServerConfig.lua` | `Support` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Support/iOSFunction.lua` | `Support` | — | `cjson`, `src.GameMgr.Support.IAPMgr`, `src.GameMgr.Update.UpdateMgr`, `src.Net.NetMgr`, `src.framework.cc.sdk.Store` | `QuestInfo` |
| `decoded_lua/assets/src/GameMgr/Support/iWatchConnectivity.lua` | `Support` | `sendCG_IwatchCatchPet_Req` | `cjson`, `src.Net.Send.PetSend` | `ItemInfo`, `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/BaiFangJiaJuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWChengJiuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWJiBanWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWJiBanXingJiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWJiNengTiHuanWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWJiNengXueXiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/CWShouJiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChaoZhiLiBaoWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuFangShengWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuJiNengWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuJinHuaWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuShengXingWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuXunLianChongZhiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ChongWuXunLianWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/DaLianMengWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/FubenTongGuanWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/JiaRuJiaZuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/JiaZuGongXianDuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/JiaZuRenWuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/JingJiChangWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/KuoJianJiaYuanWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/LeiJiChongZhiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/LostTowerCengShuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/LostTowerChongZhiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/LostTowerChuanSongWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/LostTowerHuiFuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/MapRoadWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/MeiRiLiBaoWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/QianLiShuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/QiangHuaChongWuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/RenWuDengJiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SHJiNengDengJiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SHJiNengJieSuoWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SHJiNengZhiZhuoWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SevenDayFuBenData.lua` | `TaskWatcher` | `sendCG_GetCharacterValues_Req` | `src.Net.Send.LoginSend` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SevenDayPetData.lua` | `TaskWatcher` | `sendCG_GetCharacterValues_Req` | `src.GameMgr.Item.SevenDaysActivity`, `src.Net.Send.LoginSend` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SevenDayRedPointManager.lua` | `TaskWatcher` | `sendCG_GetCharacterValues_Req` | `src.Net.Send.LoginSend` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/SuiPianHeChengWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/TaskWatcherBase.lua` | `TaskWatcher` | — | — | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/TaskWatcherManager.lua` | `TaskWatcher` | `sendCG_GetCharacterValues_Req`, `sendCG_GetLifeSkillData_Req` | `cjson`, `src.GameMgr.Item.SevenDaysActivity`, `src.GameMgr.TaskWatcher.BaiFangJiaJuWatcher`, `src.GameMgr.TaskWatcher.CWChengJiuWatcher`, `src.GameMgr.TaskWatcher.CWJiBanWatcher`, `src.GameMgr.TaskWatcher.CWJiBanXingJiWatcher`, `src.GameMgr.TaskWatcher.CWJiNengTiHuanWatcher`, `src.GameMgr.TaskWatcher.CWJiNengXueXiWatcher`, `src.GameMgr.TaskWatcher.CWShouJiWatcher`, `src.GameMgr.TaskWatcher.ChaoZhiLiBaoWatcher`, `src.GameMgr.TaskWatcher.ChongWuFangShengWatcher`, `src.GameMgr.TaskWatcher.ChongWuJiNengWatcher`, `src.GameMgr.TaskWatcher.ChongWuJinHuaWatcher`, `src.GameMgr.TaskWatcher.ChongWuShengXingWatcher`, `src.GameMgr.TaskWatcher.ChongWuXunLianChongZhiWatcher`, `src.GameMgr.TaskWatcher.ChongWuXunLianWatcher`, `src.GameMgr.TaskWatcher.DaLianMengWatcher`, `src.GameMgr.TaskWatcher.FubenTongGuanWatcher`, `src.GameMgr.TaskWatcher.JiaRuJiaZuWatcher`, `src.GameMgr.TaskWatcher.JiaZuGongXianDuWatcher`, `src.GameMgr.TaskWatcher.JiaZuRenWuWatcher`, `src.GameMgr.TaskWatcher.JingJiChangWatcher`, `src.GameMgr.TaskWatcher.KuoJianJiaYuanWatcher`, `src.GameMgr.TaskWatcher.LeiJiChongZhiWatcher`, `src.GameMgr.TaskWatcher.LostTowerCengShuWatcher`, `src.GameMgr.TaskWatcher.LostTowerChongZhiWatcher`, `src.GameMgr.TaskWatcher.LostTowerChuanSongWatcher`, `src.GameMgr.TaskWatcher.LostTowerHuiFuWatcher`, `src.GameMgr.TaskWatcher.MapRoadWatcher`, `src.GameMgr.TaskWatcher.MeiRiLiBaoWatcher`, `src.GameMgr.TaskWatcher.QianLiShuWatcher`, `src.GameMgr.TaskWatcher.QiangHuaChongWuWatcher`, `src.GameMgr.TaskWatcher.RenWuDengJiWatcher`, `src.GameMgr.TaskWatcher.SHJiNengDengJiWatcher`, `src.GameMgr.TaskWatcher.SHJiNengJieSuoWatcher`, `src.GameMgr.TaskWatcher.SHJiNengZhiZhuoWatcher`, `src.GameMgr.TaskWatcher.SuiPianHeChengWatcher`, `src.GameMgr.TaskWatcher.ZDFubenYaoQingHaoYouWatcher`, `src.GameMgr.TaskWatcher.ZhanDouLiWatcher`, `src.GameMgr.TaskWatcher.ZuDuiFuBenCiShuWatcher`, `src.GameMgr.TaskWatcher.ZuDuiFuBenWatcher`, `src.Net.Send.LifeSkillSend`, `src.Net.Send.LoginSend` | `ItemInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ZDFubenYaoQingHaoYouWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ZhanDouLiWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | `PokemonInfo` |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ZuDuiFuBenCiShuWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/TaskWatcher/ZuDuiFuBenWatcher.lua` | `TaskWatcher` | — | `src.GameMgr.TaskWatcher.TaskWatcherBase` | — |
| `decoded_lua/assets/src/GameMgr/UIStack.lua` | `UIStack.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Update/UpdateLogFunction.lua` | `Update` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Update/UpdateLogSender.lua` | `Update` | — | — | — |
| `decoded_lua/assets/src/GameMgr/Update/UpdateMgr.lua` | `Update` | — | `config`, `framework.cc.init`, `framework.init`, `framework.shortcodes`, `lfs`, `src.GameMgr.GameInit`, `src.GameMgr.Update.UpdateLogFunction`, `src.GameMgr.Update.UpdateLogSender` | — |
| `decoded_lua/assets/src/GameMgr/ViewMgrUtils.lua` | `ViewMgrUtils.lua` | — | — | — |
| `decoded_lua/assets/src/GameMgr/login.lua` | `login.lua` | `sendCG_DeviceBind_Req`, `sendCG_PlatformLogin_Req` | `framework.scheduler`, `message.ntf`, `message.preLoadMessage`, `scenes.CreateCharacterScene`, `scenes.LoadingScene`, `scenes.WifiBattleScene.message.WFB_Mes`, `src.Net.Send.PortalSend` | — |
| `decoded_lua/assets/src/GameMgr/platformCfg.lua` | `platformCfg.lua` | — | — | — |
