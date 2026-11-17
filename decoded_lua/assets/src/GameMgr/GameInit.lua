PlatformConfig      = require("src.GameMgr.Support.PlatformConfig")
TxtReader           = require("src.GameMgr.Support.TxtReader")
LoadingView         = require("src.GameMgr.Support.LoadingView")
CopyMapLoadingMgr   = require("src.GameMgr.Support.CopyMapLoadingMgr")
UnblockLoader       = require("src.GameMgr.Support.UnblockLoader")
BaseFunction        = require("src.GameMgr.Support.BaseFunction")
UserSettings        = require("src.GameMgr.Support.UserSettings")
LuaSqlite           = require("src.GameMgr.Support.LuaSqlite")
GetRandom           = require("src.GameMgr.Support.GetRandom")
GameAudio           = require("src.GameMgr.Support.GameAudio")
iOSFunction         = require("src.GameMgr.Support.iOSFunction")
AndroidFunction     = require("src.GameMgr.Support.AndroidFunction")
OvertimeListener    = require("src.GameMgr.Support.OvertimeListener")
NetInterface        = require("src.GameMgr.Support.NetInterface")
iWatchConnectivity  = require("src.GameMgr.Support.iWatchConnectivity")
QRCodeMgr           = require("src.GameMgr.Support.QRCodeMgr")

DebugInfoMgr        = require("src.GameMgr.DebugInfoMgr")
AnimationMgr        = require("src.GameMgr.AnimationMgr")
Animation3DMgr      = require("src.GameMgr.Animation3DMgr")
CSResourceMgr       = require("src.GameMgr.CSResourceMgr")
CocosModuleMgr      = require("src.GameMgr.CocosModuleMgr")
ViewMgrUtils        = require("src.GameMgr.ViewMgrUtils")

SystemInfo          = require("src.GameMgr.Data.SystemInfo")
CharInfo            = require("src.GameMgr.Data.CharInfo")
QuestInfo           = require("src.GameMgr.Data.QuestInfo")
PokemonInfo         = require("src.GameMgr.Data.PokemonInfo")
AdventureInfo       = require("src.GameMgr.Data.AdventureInfo")
ItemInfo            = require("src.GameMgr.Data.ItemInfo")
ActivityInfo        = require("src.GameMgr.Data.ActivityInfo")
ExperienceInfo      = require("src.GameMgr.Data.ExperienceInfo")
ArenaInfo           = require("src.GameMgr.Data.ArenaInfo")
TeamInfo            = require("src.GameMgr.Data.TeamInfo")
AchievementInfo     = require("src.GameMgr.Data.AchievementInfo")
TerritorialInfo     = require("src.GameMgr.Data.TerritorialInfo")
WorldMapInfo        = require("src.GameMgr.Data.WorldMapInfo")
ExploreInfo         = require("src.GameMgr.Data.ExploreInfo")
HomeInfo            = require("src.GameMgr.Data.HomeInfo")
FamilyInfo          = require("src.GameMgr.Data.FamilyInfo")
BattleInfo          = require("src.GameMgr.Data.BattleInfo")
FamilyDataInfo      = require("src.GameMgr.Data.FamilyDataInfo")
TeamCopyInfo        = require("src.GameMgr.Data.TeamCopyInfo")
TeamMapInfo         = require("src.GameMgr.Data.TeamMapInfo")
TreasureBoxInfo     = require("src.GameMgr.Data.TreasureBoxInfo")
LostTowerInfo       = require("src.GameMgr.Data.LostTowerInfo")
WorldBossInfo       = require("src.GameMgr.Data.WorldBossInfo")
PetEquipInfo        = require("src.GameMgr.Data.PetEquipInfo")
ScienceInfo         = require("src.GameMgr.Data.ScienceInfo")

SurviveBattleViewMgr= require("src.GameMgr.Activity.SurviveBattleViewMgr")
ActivityShopViewMgr = require("src.GameMgr.Activity.ActivityShopViewMgr")

SystemOptionsMgr    = require("src.GameMgr.Common.SystemOptionsMgr")
TipsMgr             = require("src.GameMgr.Common.TipsMgr")
StandardTipsMgr     = require("src.GameMgr.Common.StandardTipsMgr")
StatusBarMgr        = require("src.GameMgr.Common.StatusBarMgr")
DialogBoxMgr        = require("src.GameMgr.Common.DialogBoxMgr")
GameNoticeMgr       = require("src.GameMgr.Common.GameNoticeMgr")
BasicMenuMgr        = require("src.GameMgr.Common.BasicMenuMgr")
HomeMenuMgr         = require("src.GameMgr.Common.HomeMenuMgr")
LoginViewMgr        = require("src.GameMgr.Common.LoginViewMgr")
LoginMsgMgr         = require("src.GameMgr.Common.LoginMsgMgr")
CreateCharViewMgr   = require("src.GameMgr.Common.CreateCharViewMgr")
ChoosePetViewMgr    = require("src.GameMgr.Common.ChoosePetViewMgr")
GameGuideMgr        = require("src.GameMgr.Common.GameGuideMgr")
HorseLayerMgr       = require("src.GameMgr.Common.HorseLayerMgr")

SceneMgr            = require("src.GameMgr.Map.SceneMgr")
TownMapMgr          = require("src.GameMgr.Map.TownMapMgr")
HomeMapMgr          = require("src.GameMgr.Map.HomeMapMgr")
CopyMapMgr          = require("src.GameMgr.Map.CopyMapMgr")
FamilyCopyMapMgr    = require("src.GameMgr.Map.FamilyCopyMapMgr")
TeamCopyMapMgr      = require("src.GameMgr.Map.TeamCopyMapMgr")
BattleMapMgr        = require("src.GameMgr.Map.BattleMapMgr")
MiniMapMgr          = require("src.GameMgr.Map.MiniMapMgr")
MapSeekerMgr        = require("src.GameMgr.Map.MapSeekerMgr")
WorldMapMgr         = require("src.GameMgr.Map.WorldMapMgr")
WorldMapAwardsMgr   = require("src.GameMgr.Map.WorldMapAwardsMgr")
WorldMapMoveMgr     = require("src.GameMgr.Map.WorldMapMoveMgr")
EmbeddedMapMgr      = require("src.GameMgr.Map.EmbeddedMapMgr")
TownMapBoardMgr     = require("src.GameMgr.Map.TownMapBoardMgr")
IdlingMapMgr        = require("src.GameMgr.Map.IdlingMapMgr")
IdlingMapBoardMgr   = require("src.GameMgr.Map.IdlingMapBoardMgr")
AllWorldMapMgr      = require("src.GameMgr.Map.AllWorldMapMgr")
SearchingMapMgr     = require("src.GameMgr.Map.SearchingMapMgr")
BossMapMgr          = require("src.GameMgr.Map.BossMapMgr")
ExploreMapMgr       = require("src.GameMgr.Map.ExploreMapMgr")

PlayerAnimeMgr      = require("src.GameMgr.Player.PlayerAnimeMgr")
PlayerInfoViewMgr   = require("src.GameMgr.Player.PlayerInfoViewMgr")
PlayerOperationMgr  = require("src.GameMgr.Player.PlayerOperationMgr")
PlayerShareMgr      = require("src.GameMgr.Player.PlayerShareMgr")
TownPlayerListMgr   = require("src.GameMgr.Player.TownPlayerListMgr")
TownPlayerMgr       = require("src.GameMgr.Player.TownPlayerMgr")
WorldPlayerMgr      = require("src.GameMgr.Player.WorldPlayerMgr")
PersonalCenterMgr   = require("src.GameMgr.Player.PersonalCenterMgr")
PokedexMenuViewMgr  = require("src.GameMgr.Player.PokedexMenuViewMgr")
ArenaMainMgr        = require("src.GameMgr.Player.ArenaMainMgr")
ArenaEffectMgr      = require("src.GameMgr.Player.ArenaEffectMgr")
ArenaViewMgr        = require("src.GameMgr.Player.ArenaViewMgr")
MArenaViewMgr       = require("src.GameMgr.Player.MArenaViewMgr")
ArenaWinViewMgr     = require("src.GameMgr.Player.ArenaWinViewMgr")
ArenaRewardList     = require("src.GameMgr.Player.ArenaRewardList")
ArenaTeamViewMgr    = require("src.GameMgr.Player.ArenaTeamViewMgr")
ArenaExchangeMgr    = require("src.GameMgr.Player.ArenaExchangeMgr")
ArenaRecordMgr      = require("src.GameMgr.Player.ArenaRecordMgr")
ArenaPKViewMgr      = require("src.GameMgr.Player.ArenaPKViewMgr")
LevelUpViewMgr      = require("src.GameMgr.Player.LevelUpViewMgr")
AvatarViewMgr       = require("src.GameMgr.Player.AvatarViewMgr")
CheckViewMgr        = require("src.GameMgr.Player.CheckViewMgr")
FriendsViewMgr      = require("src.GameMgr.Player.FriendsViewMgr")
ExchangeViewMgr     = require("src.GameMgr.Player.ExchangeViewMgr")
LifeSkillLstViewMgr = require("src.GameMgr.Player.LifeSkillLstViewMgr")
LifeSkillSelViewMgr = require("src.GameMgr.Player.LifeSkillSelViewMgr")
LifeSkillJobChangeViewMgr = require("src.GameMgr.Player.LifeSkillJobChangeViewMgr")
LifeSkillFilterPopUp= require("src.GameMgr.Player.LifeSkillFilterPopUp")
LifeSkillBatchMaker = require("src.GameMgr.Player.LifeSkillBatchMaker")
SelectBeautyViewMgr = require("src.GameMgr.Player.SelectBeautyViewMgr")
CreateFamilyMgr     = require("src.GameMgr.Player.CreateFamilyMgr")
FamilyIconMgr       = require("src.GameMgr.Player.FamilyIconMgr")
SearchFamilyMgr     = require("src.GameMgr.Player.SearchFamilyMgr")
FamilyInfoMgr       = require("src.GameMgr.Player.FamilyInfoMgr")
FamilyPlayerViewMgr = require("src.GameMgr.Player.FamilyPlayerViewMgr")
FamilyNpcManagerViewMgr = require("src.GameMgr.Player.FamilyNpcManagerViewMgr")
FamilyQuestListMgr  = require("src.GameMgr.Player.FamilyQuestListMgr")
FamilyFloorInfoMgr  = require("src.GameMgr.Player.FamilyFloorInfoMgr")
FamilyLogViewMgr    = require("src.GameMgr.Player.FamilyLogViewMgr")
FamilyDonateMgr     = require("src.GameMgr.Player.FamilyDonateMgr")
FamilyShopMgr       = require("src.GameMgr.Player.FamilyShopMgr")
FamilyCopyMgr       = require("src.GameMgr.Player.FamilyCopyMgr")
FamilyCopyBonusMgr  = require("src.GameMgr.Player.FamilyCopyBonusMgr")
FamilyCopyEventMgr  = require("src.GameMgr.Player.FamilyCopyEventMgr")
FamilyCopyTopBarMgr = require("src.GameMgr.Player.FamilyCopyTopBarMgr")
TeamCopyTopBarMgr   = require("src.GameMgr.Player.TeamCopyTopBarMgr")
TeamCopyWinMgr      = require("src.GameMgr.Player.TeamCopyWinMgr")
ExploreViewMgr      = require("src.GameMgr.Player.ExploreViewMgr")
TreeInfoView        = require("src.GameMgr.Player.TreeInfoView")
TownTreeMgr         = require("src.GameMgr.Player.TownTreeMgr")
TeamViewMgr         = require("src.GameMgr.Player.TeamViewMgr")
TeamDropMgr         = require("src.GameMgr.Player.TeamDropMgr")
TeamInviteMgr       = require("src.GameMgr.Player.TeamInviteMgr")
ExitGameViewMgr     = require("src.GameMgr.Player.ExitGameViewMgr")
NoticeViewMgr       = require("src.GameMgr.Player.NoticeViewMgr")
BossFailedMgr       = require("src.GameMgr.Player.BossFailedMgr")
BossTopBarMgr       = require("src.GameMgr.Player.BossTopBarMgr")
ScienceViewMgr      = require("src.GameMgr.Player.ScienceViewMgr")
ScienceDevelopMgr   = require("src.GameMgr.Player.ScienceDevelopMgr")

PetInfoViewMgr      = require("src.GameMgr.Pet.PetInfoViewMgr")
PetGetViewMgr       = require("src.GameMgr.Pet.PetGetViewMgr")
PetEquipmentMgr     = require("src.GameMgr.Pet.PetEquipmentMgr")
PickItemViewMgr     = require("src.GameMgr.Pet.PickItemViewMgr")
PickPurifyViewMgr   = require("src.GameMgr.Pet.PickPurifyViewMgr")
PetEquipmentEvaluateMgr   = require("src.GameMgr.Pet.PetEquipmentEvaluateMgr")
PetEquipmentRestoreMgr   = require("src.GameMgr.Pet.PetEquipmentRestoreMgr")
PetEquipmentOperationMgr   = require("src.GameMgr.Pet.PetEquipmentOperationMgr")
PetEquipmentStrengthenEffectMgr   = require("src.GameMgr.Pet.PetEquipmentStrengthenEffectMgr")
BasicPetListMgr     = require("src.GameMgr.Pet.BasicPetListMgr")
PokedexMgr          = require("src.GameMgr.Pet.PokedexMgr")
PetMenuMgr          = require("src.GameMgr.Pet.PetMenuMgr")
PetEvolutionMgr     = require("src.GameMgr.Pet.PetEvolutionMgr")
PetStrengthenMgr    = require("src.GameMgr.Pet.PetStrengthenMgr")
PetFormationMgr     = require("src.GameMgr.Pet.PetFormationMgr")
PetFeedViewMgr      = require("src.GameMgr.Pet.PetFeedViewMgr")
PetEducationMgr     = require("src.GameMgr.Pet.PetEducationMgr")
PetChangeNameMgr    = require("src.GameMgr.Pet.PetChangeNameMgr")
PetQuickViewMgr     = require("src.GameMgr.Pet.PetQuickViewMgr")
PetExploreMgr       = require("src.GameMgr.Pet.PetExploreMgr")
PetExploreInfoMgr   = require("src.GameMgr.Pet.PetExploreInfoMgr")
PetExploreRewardsMgr= require("src.GameMgr.Pet.PetExploreRewardsMgr")
PetListMgr          = require("src.GameMgr.Pet.PetListMgr")
PetFreeListMgr      = require("src.GameMgr.Pet.PetFreeListMgr")
PetStarUpMgr        = require("src.GameMgr.Pet.PetStarUpMgr")
PetStarupEffectMgr  = require("src.GameMgr.Pet.PetStarupEffectMgr")
PetEvolutionEffectMgr= require("src.GameMgr.Pet.PetEvolutionEffectMgr")
PetEffectMgr        = require("src.GameMgr.Pet.PetEffectMgr")
PetFCEffectMgr      = require("src.GameMgr.Pet.PetFCEffectMgr")
PetCommonListViewMgr= require("src.GameMgr.Pet.PetCommonListViewMgr")
PetSkillIconMgr     = require("src.GameMgr.Pet.PetSkillIconMgr")
PetSkillViewMgr     = require("src.GameMgr.Pet.PetSkillViewMgr")
PetEatPetViewMgr	= require("src.GameMgr.Pet.PetEatPetViewMgr")
TipsViewMgr      	= require("src.GameMgr.Pet.TipsViewMgr")
CommonPetBar        = require("src.GameMgr.Pet.CommonPetBar")
BattleManualMgr     = require("src.GameMgr.Pet.BattleManualMgr")
PetStarupResetViewMgr= require("src.GameMgr.Pet.PetStarupResetViewMgr")
PetQuickTrainViewMgr= require("src.GameMgr.Pet.PetQuickTrainViewMgr")

BagViewMgr          = require("src.GameMgr.Item.BagViewMgr")
ActivityPublicjMgr  = require("src.GameMgr.Item.ActivityPublicjMgr")
ActivityViewMgr     = require("src.GameMgr.Item.ActivityViewMgr")
CollectPetActivityViewMgr     = require("src.GameMgr.Item.CollectPetActivityViewMgr")
ActivityHalloweenViewMgr = require("src.GameMgr.Item.ActivityHalloweenViewMgr")
HalloweenCapsuleEggView = require("src.GameMgr.Item.HalloweenCapsuleEggView")
ActivityCapsuleEggView = require("src.GameMgr.Item.ActivityCapsuleEggView")
ActivitySnatch 		= require("src.GameMgr.Item.ActivitySnatch")
RechargeViewMgr     = require("src.GameMgr.Item.RechargeViewMgr")
SkillBookViewMgr    = require("src.GameMgr.Item.SkillBookViewMgr")
FurnitureViewMgr    = require("src.GameMgr.Item.FurnitureViewMgr")
FurnitureTVMgr      = require("src.GameMgr.Item.FurnitureTVMgr")
FurnitureSofaMgr    = require("src.GameMgr.Item.FurnitureSofaMgr")
ItemInfoViewMgr     = require("src.GameMgr.Item.ItemInfoViewMgr")
ItemNumViewMgr      = require("src.GameMgr.Item.ItemNumViewMgr")
ShopListMgr         = require("src.GameMgr.Item.ShopListMgr")
AuctionMgr          = require("src.GameMgr.Item.AuctionMgr")
PurchaseViewMgr     = require("src.GameMgr.Item.PurchaseViewMgr")
VipShopViewMgr      = require("src.GameMgr.Item.VipShopViewMgr")
MailMgr             = require("src.GameMgr.Item.MailMgr")
AwardsListMgr       = require("src.GameMgr.Item.AwardsListMgr")
GachaViewMgr        = require("src.GameMgr.Item.GachaViewMgr")
AuctionMgrNew       = require("src.GameMgr.Item.AuctionMgrNew")
BuyInfoMgr          = require("src.GameMgr.Item.BuyInfoMgr")
SellInfoMgr         = require("src.GameMgr.Item.SellInfoMgr")
AuctionSearch       = require("src.GameMgr.Item.AuctionSearch")
BuyInfoMgr2         = require("src.GameMgr.Item.BuyInfoMgr2")
BuyItemViewMgr      = require("src.GameMgr.Item.BuyItemViewMgr")
DropInfoViewMgr     = require("src.GameMgr.Item.DropInfoViewMgr")
TrainStoneMgr       = require("src.GameMgr.Item.TrainStoneMgr")
BossDmgAwardsMgr    = require("src.GameMgr.Item.BossDmgAwardsMgr")

BattleMgr           = require("src.GameMgr.Battle.BattleMgr")
BattleUIMgr         = require("src.GameMgr.Battle.BattleUIMgr")
BattleSkill         = require("src.GameMgr.Battle.BattleSkill") 
BattleBuffer        = require("src.GameMgr.Battle.BattleBuffer")
BattlePassiveSkills = require("src.GameMgr.Battle.BattlePassiveSkills") 
BattlePVPMgr        = require("src.GameMgr.Battle.BattlePVPMgr")
BattleFuncMgr       = require("src.GameMgr.Battle.BattleFuncMgr")
BattleBasicValueCalc= require("src.GameMgr.Battle.BattleBasicValueCalc")
BattleCCSB    	    = require("src.GameMgr.Battle.BattleCCSB")
BattleLabelAtlas  	= require("src.GameMgr.Battle.BattleLabelAtlas")
BattleCANI    	    = require("src.GameMgr.Battle.BattleCANI")
BattleBufferUI    	= require("src.GameMgr.Battle.BattleBufferUI") 
BattleCotroller   	= require("src.GameMgr.Battle.BattleCotroller")
BattleGuide         = require("src.GameMgr.Battle.BattleGuide")
BattleTemplateData  = require("src.GameMgr.Battle.templates.BattleTemplateData")
BattleTemplate      = require("src.GameMgr.Battle.templates.BattleTemplate")
ExtraAttackBase     = require("src.GameMgr.Battle.templates.ExtraAttackBase")
Skill               = require("src.GameMgr.Battle.Skill")
Buff                = require("src.GameMgr.Battle.Buff")
Pet                 = require("src.GameMgr.Battle.Pet")
Team                = require("src.GameMgr.Battle.Team")
AttributeStarImproveInfoConfig = require("src.DatReader.AttributeStarImproveInfoConfig")
HDVector            = require("src.Utils.HDVector")
BattleAidFunc       = require("src.GameMgr.Battle.BattleAidFunc")
require("src.GameMgr.Battle.templates.BattleTemplateTypes")
ExpeditionalInfo 	= require("src.GameMgr.Data.ExpeditionalInfo")
expeditionalViewMgr = require("src.GameMgr.Activity.expeditionalViewMgr") 

ConfraListViewMgr   = require("src.GameMgr.Confraternity.ConfraListViewMgr")
ConfraInfoViewMgr   = require("src.GameMgr.Confraternity.ConfraInfoViewMgr")

ChatUIMgr           = require("src.GameMgr.Chat.ChatUIMgr")
ChatBubbleMgr       = require("src.GameMgr.Chat.ChatBubbleMgr")
ChatMsgMgr          = require("src.GameMgr.Chat.ChatMsgMgr")
TownChatMgr         = require("src.GameMgr.Chat.TownChatMgr")
PetShareDetail      = require("src.GameMgr.Chat.PetShareDetail")
MsgBoardView        = require("src.GameMgr.Chat.MsgBoardView")

NpcDialogueMgr      = require("src.GameMgr.Mission.NpcDialogueMgr")
MissionGuideMgr     = require("src.GameMgr.Mission.MissionGuideMgr")
MissionInfoMgr      = require("src.GameMgr.Mission.MissionInfoMgr")
TownMissionMgr      = require("src.GameMgr.Mission.TownMissionMgr")
NpcMgr              = require("src.GameMgr.Mission.NpcMgr")
MissionListMgr      = require("src.GameMgr.Mission.MissionListMgr")
AchievementListMgr  = require("src.GameMgr.Mission.AchievementListMgr")

SearchingMgr        = require("src.GameMgr.Searching.SearchingMgr")
SearchingUIMgr      = require("src.GameMgr.Searching.SearchingUIMgr") 
AdvStarMgr          = require("src.GameMgr.Searching.AdvStarMgr")
AdvPetsMgr          = require("src.GameMgr.Searching.AdvPetsMgr")
SearchingFuncMgr    = require("src.GameMgr.Searching.SearchingFuncMgr")
AdvCharMgr          = require("src.GameMgr.Searching.AdvCharMgr")
AdvConfirmMgr       = require("src.GameMgr.Searching.AdvConfirmMgr")
StageBossListMgr    = require("src.GameMgr.Searching.StageBossListMgr")
AdvConfirmMgrNew    = require("src.GameMgr.Searching.AdvConfirmMgrNew")
AdvEnvironmentMgr   = require("src.GameMgr.Searching.AdvEnvironmentMgr")
advResetView        = require("src.GameMgr.Searching.advResetView")

LostTowerMgr        = require("src.GameMgr.LostTower.LostTowerMgr")
LtMapOption         = require("src.GameMgr.LostTower.LtMapOption")
LtEventOption       = require("src.GameMgr.LostTower.LtEventOption")
LtMapNodeMgr        = require("src.GameMgr.LostTower.LtMapNodeMgr")
LtPlayerMgr         = require("src.GameMgr.LostTower.LtPlayerMgr")
LostTowerUIMgr      = require("src.GameMgr.LostTower.LostTowerUIMgr")
LtFuncMgr           = require("src.GameMgr.LostTower.LtFuncMgr")
LtPetsMgr           = require("src.GameMgr.LostTower.LtPetsMgr")
LtPropMgr           = require("src.GameMgr.LostTower.LtPropMgr")
LtHealViewMgr       = require("src.GameMgr.LostTower.LtHealViewMgr")
LtRankingViewMgr    = require("src.GameMgr.LostTower.LtRankingViewMgr")
LtExchangeViewMgr   = require("src.GameMgr.LostTower.LtExchangeViewMgr")
LtResetViewMgr      = require("src.GameMgr.LostTower.LtResetViewMgr")
LtPickPetViewMgr    = require("src.GameMgr.LostTower.LtPickPetViewMgr")
LtWarFogMgr         = require("src.GameMgr.LostTower.LtWarFogMgr")
LtOpenBoxView       = require("src.GameMgr.LostTower.LtOpenBoxView")
LtTransferViewMgr   = require("src.GameMgr.LostTower.LtTransferViewMgr")
LtStepAddView       = require("src.GameMgr.LostTower.LtStepAddView")
LtExBufferMgr       = require("src.GameMgr.LostTower.LtExBufferMgr")
LtChangeFloorView   = require("src.GameMgr.LostTower.LtChangeFloorView")
LtRankAwardList     = require("src.GameMgr.LostTower.LtRankAwardList")

FamilyListViewMgr   = require("src.GameMgr.Player.FamilyListViewMgr")
MyFamilyLstViewMgr  = require("src.GameMgr.Player.MyFamilyLstViewMgr")
FamilyApplyListViewMgr = require("src.GameMgr.Player.FamilyApplyListViewMgr")
FamilyTransListViewMgr = require("src.GameMgr.Player.FamilyTransListViewMgr")
PetHandBook         = require("src.GameMgr.Pet.PetHandBook")
ObjectPool          = require("src.GameMgr.ObjectPool")
PerFormanceAnalyzer = require("src.Utils.PerFormaceAnalyzer")
DungeonMapMgr       = require("src.GameMgr.CommonDungeon.DungeonMapMgr")
DungeonPlayerMgr    = require("src.GameMgr.CommonDungeon.DungeonPlayerMgr")
HighPerformList     = require("src.GameMgr.Support.HighPerformList")
VoiceManager        = require("src.GameMgr.Support.Voice.VoiceManager")
XFangCunLogSender   = require("src.Utils.XFangCunLogSender")
PayConfig           = require("src.Utils.pay.PayConfig")
GameLogMgr          = require("src.GameMgr.GameLogMgr")
UIStack             = require("src.GameMgr.UIStack")
BattleLogConfig     = require("src.LogConfig")
ProtoErrorTransferText  = require("src.GameMgr.ProtoErrorTransferText")
TaskWatcherManager  =   require("src.GameMgr.TaskWatcher.TaskWatcherManager")
SevenDayPetData     =   require("src.GameMgr.TaskWatcher.SevenDayPetData")
SevenDayFuBenData   =   require("src.GameMgr.TaskWatcher.SevenDayFuBenData")
SevenDayRedPointManager = require("src.GameMgr.TaskWatcher.SevenDayRedPointManager")
BossBattleMgr           = require("src.GameMgr.Battle.BossBattleMgr")
PVPQuestListMgr  = require("src.GameMgr.Player.PVPQuestListMgr")
PVPQuestShopMgr  = require("src.GameMgr.Player.PVPQuestShopMgr")
PVPQuestRank     = require("src.GameMgr.Player.PVPQuestRank")

PetTrainPointsInfo = require("src.GameMgr.Data.PetTrainPointsInfo")
petTrainLimitMaterialView = require("src.GameMgr.Pet.petTrainLimitMaterialView")

WishCoinShopView = require("src.GameMgr.Item.WishCoinShop.WishCoinShopView")
OrderManDataMgr = require("src.GameMgr.OrderMan.OrderManDataMgr")

FamilySignView   =  require("src.GameMgr.Player.FamilySignView")
FamilySignServer = require("src.GameMgr.Player.FamilySignServer")

GameInit = {}
DEFAULT_GAME_SCREEN_WIDTH = 640
DEFAULT_GAME_SCREEN_HEIGHT = 960

---初始化游戏
--@param isReInit bool 是否是重新初始化(首次调用可不填，第二次调用请务必填true)
function GameInit.Init(isReInit,progressbar,endcallback)
    local function safeInit(name, initFunc)
        local ok, err = pcall(initFunc)
        if not ok then
            print("[GameInit] manager init warning:", name, err)
        end
        return ok
    end
    LoginViewMgr.isKickByServer = 0
	BattleLogConfig.configPrerequisites()
	BattleLogConfig.roundResult = false
	BattleLogConfig.passiveSkillTrigger = false
	BattleLogConfig.skillDesc = false

    if CONFIG_SCREEN_AUTOSCALE=="FIXED_WIDTH" then
        DEFAULT_GAME_SCREEN_WIDTH = 640
        DEFAULT_GAME_SCREEN_HEIGHT = 960
    else
        DEFAULT_GAME_SCREEN_WIDTH = 960
        DEFAULT_GAME_SCREEN_HEIGHT = 640
    end

    UnblockLoader.Init()    
    PerFormanceAnalyzer.Init() --性能分析器
    local function func0()
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(1)
        end 
    end

    local function funcend()
        PerFormanceAnalyzer.Start("root","GameInit-Init()")

        PerFormanceAnalyzer.Start("GameInit-Init()","BattleInfo-init()")
        safeInit("BattleInfo", function() BattleInfo.Init() end)
        PerFormanceAnalyzer.End("BattleInfo-init()")    
        

        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(100)
        end 
    end

    local function func1()
    
        PerFormanceAnalyzer.Start("GameInit-Init()","ObjectPool-init()")
        ObjectPool.init() --这个必须在第一个初始化
        PerFormanceAnalyzer.End("ObjectPool-init()")

        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(2)
        end 
    end
 
    local function func2()
        PerFormanceAnalyzer.Start("GameInit-Init()","PlatformConfig.Init()")   
        safeInit("PlatformConfig", function() PlatformConfig.Init() end)
        PerFormanceAnalyzer.End("PlatformConfig.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(5)
        end 
    end
    
    local function func3()
        PerFormanceAnalyzer.Start("GameInit-Init()","TxtReader.Init()")
        safeInit("TxtReader", function() TxtReader.Init() end)
        PerFormanceAnalyzer.End("TxtReader.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(6)
        end    
    end
    
    local function func4()
        PerFormanceAnalyzer.Start("GameInit-Init()","LoadingView.Init()")   
        safeInit("LoadingView", function() LoadingView.Init() end)
        PerFormanceAnalyzer.End("LoadingView.Init()")  
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(7)
        end    
    end

    local function func5()
        PerFormanceAnalyzer.Start("GameInit-Init()","CopyMapLoadingMgr.Init()")   
        safeInit("CopyMapLoadingMgr", function() CopyMapLoadingMgr.Init() end)
        PerFormanceAnalyzer.End("CopyMapLoadingMgr.Init()")  
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(10)
        end    
    end

    local function func6()
        PerFormanceAnalyzer.Start("GameInit-Init()","BaseFunction.Init()")         
        safeInit("BaseFunction", function() BaseFunction.Init() end)
        PerFormanceAnalyzer.End("BaseFunction.Init()")   
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(15)
        end      
    end

    local function func7()
        PerFormanceAnalyzer.Start("GameInit-Init()","UserSettings.Init()")        
        safeInit("UserSettings", function() UserSettings.Init() end)
        PerFormanceAnalyzer.End("UserSettings.Init()")  

        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(20)
        end 
    end

    local function func8()
        PerFormanceAnalyzer.Start("GameInit-Init()","LuaSqlite.Init()")         
        safeInit("LuaSqlite", function() LuaSqlite.Init() end)
        PerFormanceAnalyzer.End("LuaSqlite.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(25)
        end 
    end

    local function func9()
        PerFormanceAnalyzer.Start("GameInit-Init()","GetRandom.Init()")         
        safeInit("GetRandom", function() GetRandom.Init() end)
        PerFormanceAnalyzer.End("GetRandom.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(27)
        end 
    end

    local function func10()
        PerFormanceAnalyzer.Start("GameInit-Init()","GameAudio.Init()")       
        safeInit("GameAudio", function() GameAudio.Init() end)
        PerFormanceAnalyzer.End("GameAudio.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(30)
        end 
    end

    local function func11()
        PerFormanceAnalyzer.Start("GameInit-Init()","iOSFunction.Init()")            
        safeInit("iOSFunction", function() iOSFunction.Init() end)
        PerFormanceAnalyzer.End("iOSFunction.Init()") 

        PerFormanceAnalyzer.Start("GameInit-Init()","AndroidFunction.Init()")       
        safeInit("AndroidFunction", function() AndroidFunction.Init() end)
        PerFormanceAnalyzer.End("AndroidFunction.Init()")   

        PerFormanceAnalyzer.Start("GameInit-Init()","VoiceManager.Init()")
        safeInit("VoiceManager", function() VoiceManager.Init() end)
        PerFormanceAnalyzer.End("VoiceManager.Init()")

        PerFormanceAnalyzer.Start("GameInit-Init()","OvertimeListener.Init()")      
        safeInit("OvertimeListener", function() OvertimeListener.Init() end)
        PerFormanceAnalyzer.End("OvertimeListener.Init()")     
       
        safeInit("NetInterface", function() NetInterface.Init() end)
        safeInit("iWatchConnectivity", function() iWatchConnectivity.Init() end)
        safeInit("QRCodeMgr", function() QRCodeMgr.Init() end)
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(32)
        end 
    end

    local function func12()
        if not isReInit then
            PerFormanceAnalyzer.Start("GameInit-Init()","AnimationMgr.Init()")   
            safeInit("AnimationMgr", function() AnimationMgr.Init() end)
            PerFormanceAnalyzer.End("AnimationMgr.Init()")  
            PerFormanceAnalyzer.Start("GameInit-Init()","Animation3DMgr.Init()") 
            safeInit("Animation3DMgr", function() Animation3DMgr.Init() end)
            PerFormanceAnalyzer.End("Animation3DMgr.Init()") 
            PerFormanceAnalyzer.Start("GameInit-Init()","CSResourceMgr.Init()") 
            safeInit("CSResourceMgr", function() CSResourceMgr.Init() end)
            PerFormanceAnalyzer.End("CSResourceMgr.Init()") 
        end
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(35)
        end 
    end
    
    local function func13()
        PerFormanceAnalyzer.Start("GameInit-Init()","CocosModuleMgr.Init()") 
        safeInit("CocosModuleMgr", function() CocosModuleMgr.Init() end)
        PerFormanceAnalyzer.End("CocosModuleMgr.Init()")    
    
        PerFormanceAnalyzer.Start("GameInit-Init()","SystemInfo.Init()")     
        safeInit("SystemInfo", function() SystemInfo.Init() end)
        PerFormanceAnalyzer.End("SystemInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(36)
        end 
    end
    
    local function func14()
        PerFormanceAnalyzer.Start("GameInit-Init()","CharInfo.Init()")     
        safeInit("CharInfo", function() CharInfo.Init() end)
        PerFormanceAnalyzer.End("CharInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(40)
        end   
    end
    
    local function func15()
        PerFormanceAnalyzer.Start("GameInit-Init()","QuestInfo.Init()")          
        safeInit("QuestInfo", function() QuestInfo.Init() end)
        PerFormanceAnalyzer.End("QuestInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(50)
        end 
    end

    local function func16()
        PerFormanceAnalyzer.Start("GameInit-Init()","PokemonInfo.Init()")      
        safeInit("PokemonInfo", function() PokemonInfo.Init() end)
        PerFormanceAnalyzer.End("PokemonInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(55)
        end 
    end

    local function func17()
        PerFormanceAnalyzer.Start("GameInit-Init()","AdventureInfo.Init()")    
        safeInit("AdventureInfo", function() AdventureInfo.Init() end)
        PerFormanceAnalyzer.End("AdventureInfo.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","ItemInfo.Init()")      
        safeInit("ItemInfo", function() ItemInfo.Init() end)
        PerFormanceAnalyzer.End("ItemInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(60)
        end 
    end

    local function func18()
        PerFormanceAnalyzer.Start("GameInit-Init()","ActivityInfo.Init()")      
        safeInit("ActivityInfo", function() ActivityInfo.Init() end)
        PerFormanceAnalyzer.End("ActivityInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(62)
        end 
    end
    
    local function func19()
        PerFormanceAnalyzer.Start("GameInit-Init()","ExperienceInfo.Init()")  
        safeInit("ExperienceInfo", function() ExperienceInfo.Init() end)
        PerFormanceAnalyzer.End("ExperienceInfo.Init()") 
   
  
        PerFormanceAnalyzer.Start("GameInit-Init()","ArenaInfo.Init()")    
        safeInit("ArenaInfo", function() ArenaInfo.Init() end)
        safeInit("TeamInfo", function() TeamInfo.Init() end)
        PerFormanceAnalyzer.End("ArenaInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(63)
        end 
    end
    
    local function func20()
        PerFormanceAnalyzer.Start("GameInit-Init()","AchievementInfo.Init()")     
        safeInit("AchievementInfo", function() AchievementInfo.Init() end)
        PerFormanceAnalyzer.End("AchievementInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(66)
        end 
    end
    
    local function func21()
        PerFormanceAnalyzer.Start("GameInit-Init()","TerritorialInfo.Init()")
        safeInit("TerritorialInfo", function() TerritorialInfo.Init() end)
        PerFormanceAnalyzer.End("TerritorialInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(68)
        end 
    end
    
    local function func22()
        PerFormanceAnalyzer.Start("GameInit-Init()","WorldMapInfo.Init()")    
        safeInit("WorldMapInfo", function() WorldMapInfo.Init() end)
        PerFormanceAnalyzer.End("WorldMapInfo.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(70)
        end 
    end

    local function func23()
        PerFormanceAnalyzer.Start("GameInit-Init()","ExploreInfo.Init()")      
        safeInit("ExploreInfo", function() ExploreInfo.Init() end)
        PerFormanceAnalyzer.End("ExploreInfo.Init()")
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(72)
        end 
    end

    local function func24()
        PerFormanceAnalyzer.Start("GameInit-Init()","HomeInfo.Init()")      
        safeInit("HomeInfo", function() HomeInfo.Init() end)
        PerFormanceAnalyzer.End("HomeInfo.Init()")
    
        PerFormanceAnalyzer.Start("GameInit-Init()","FamilyInfo.Init()")  
        safeInit("FamilyInfo", function() FamilyInfo.Init() end)
        PerFormanceAnalyzer.End("FamilyInfo.Init()")
    
        PerFormanceAnalyzer.Start("GameInit-Init()","FamilyDataInfo.Init()") 
        safeInit("FamilyDataInfo", function() FamilyDataInfo.Init() end)
        PerFormanceAnalyzer.End("FamilyDataInfo.Init()")
        
        PerFormanceAnalyzer.Start("GameInit-Init()","TeamCopyInfo.Init()")
        safeInit("TeamCopyInfo", function() TeamCopyInfo.Init() end)
        PerFormanceAnalyzer.End("TeamCopyInfo.Init()")
        
        PerFormanceAnalyzer.Start("GameInit-Init()","TeamMapInfo.Init()")
        safeInit("TeamMapInfo", function() TeamMapInfo.Init() end)
        PerFormanceAnalyzer.End("TeamMapInfo.Init()")
        
        PerFormanceAnalyzer.Start("GameInit-Init()","TreasureBoxInfo.Init()")
        safeInit("TreasureBoxInfo", function() TreasureBoxInfo.Init() end)
        PerFormanceAnalyzer.End("TreasureBoxInfo.Init()")
        
        PerFormanceAnalyzer.Start("GameInit-Init()","ScienceInfo.Init()")
        safeInit("ScienceInfo", function() ScienceInfo.Init() end)
        PerFormanceAnalyzer.End("ScienceInfo.Init()")
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(75)
        end 
    end

    local function func25()
        PerFormanceAnalyzer.Start("GameInit-Init()","AllWorldMapMgr.Init()")     
        safeInit("AllWorldMapMgr", function() AllWorldMapMgr.Init() end)
        PerFormanceAnalyzer.End("AllWorldMapMgr.Init()")

        PerFormanceAnalyzer.Start("GameInit-Init()","SystemOptionsMgr.Init()")          
        safeInit("SystemOptionsMgr", function() SystemOptionsMgr.Init() end)
        PerFormanceAnalyzer.End("SystemOptionsMgr.Init()")

        PerFormanceAnalyzer.Start("GameInit-Init()","TipsMgr.Init()")         
        safeInit("TipsMgr", function() TipsMgr.Init() end)
        PerFormanceAnalyzer.End("TipsMgr.Init()")
    
        PerFormanceAnalyzer.Start("GameInit-Init()","StandardTipsMgr.Init()")     
        safeInit("StandardTipsMgr", function() StandardTipsMgr.Init() end)
        PerFormanceAnalyzer.End("StandardTipsMgr.Init()")
    
        PerFormanceAnalyzer.Start("GameInit-Init()","StatusBarMgr.Init()")      
        safeInit("StatusBarMgr", function() StatusBarMgr.Init() end)
        PerFormanceAnalyzer.End("StatusBarMgr.Init()")
    
        PerFormanceAnalyzer.Start("GameInit-Init()","DialogBoxMgr.Init()")      
        safeInit("DialogBoxMgr", function() DialogBoxMgr.Init() end)
        PerFormanceAnalyzer.End("DialogBoxMgr.Init()")
        PerFormanceAnalyzer.Start("GameInit-Init()","GameNoticeMgr.Init()") 
        safeInit("GameNoticeMgr", function() GameNoticeMgr.Init() end)
        PerFormanceAnalyzer.End("GameNoticeMgr.Init()") 
       
        PerFormanceAnalyzer.Start("GameInit-Init()","BasicMenuMgr.Init()") 
        safeInit("BasicMenuMgr", function() BasicMenuMgr.Init() end)
        PerFormanceAnalyzer.End("BasicMenuMgr.Init()") 
  
        PerFormanceAnalyzer.Start("GameInit-Init()","HomeMenuMgr.Init()")   
        safeInit("HomeMenuMgr", function() HomeMenuMgr.Init() end)
        PerFormanceAnalyzer.End("HomeMenuMgr.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","LoginViewMgr.Init()")   
        safeInit("LoginViewMgr", function() LoginViewMgr.Init() end)
        PerFormanceAnalyzer.End("LoginViewMgr.Init()") 
 
        PerFormanceAnalyzer.Start("GameInit-Init()","LoginMsgMgr.Init()")     
        safeInit("LoginMsgMgr", function() LoginMsgMgr.Init() end)
        PerFormanceAnalyzer.End("LoginMsgMgr.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","CreateCharViewMgr.Init()")       
        safeInit("CreateCharViewMgr", function() CreateCharViewMgr.Init() end)
        PerFormanceAnalyzer.End("CreateCharViewMgr.Init()") 
 
        PerFormanceAnalyzer.Start("GameInit-Init()","ChoosePetViewMgr.Init()")     
        safeInit("ChoosePetViewMgr", function() ChoosePetViewMgr.Init() end)
        PerFormanceAnalyzer.End("ChoosePetViewMgr.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","GameGuideMgr.Init()")     
        safeInit("GameGuideMgr", function() GameGuideMgr.Init() end)
        PerFormanceAnalyzer.End("GameGuideMgr.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(80)
        end 
    end

    local function func26()
        safeInit("HorseLayerMgr", function() HorseLayerMgr.Init() end)
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(85)
        end 
    end

    local function func27()
        PerFormanceAnalyzer.Start("GameInit-Init()","left1.Init()")        
        safeInit("SceneMgr", function() SceneMgr.Init() end)
        safeInit("TownMapMgr", function() TownMapMgr.Init() end)
        safeInit("HomeMapMgr", function() HomeMapMgr.Init() end)
        safeInit("CopyMapMgr", function() CopyMapMgr.Init() end)
        safeInit("FamilyCopyMapMgr", function() FamilyCopyMapMgr.Init() end)
        safeInit("TeamCopyMapMgr", function() TeamCopyMapMgr.Init() end)
        safeInit("BattleMapMgr", function() BattleMapMgr.Init() end)
        safeInit("MiniMapMgr", function() MiniMapMgr.Init() end)
        safeInit("MapSeekerMgr", function() MapSeekerMgr.Init() end)
        safeInit("WorldMapMgr", function() WorldMapMgr.Init() end)
        safeInit("WorldMapAwardsMgr", function() WorldMapAwardsMgr.Init() end)
        safeInit("WorldMapMoveMgr", function() WorldMapMoveMgr.Init() end)
        safeInit("EmbeddedMapMgr", function() EmbeddedMapMgr.Init() end)
        safeInit("TownMapBoardMgr", function() TownMapBoardMgr.Init() end)
        safeInit("IdlingMapBoardMgr", function() IdlingMapBoardMgr.Init() end)
        safeInit("IdlingMapMgr", function() IdlingMapMgr.Init() end)
        safeInit("SearchingMapMgr", function() SearchingMapMgr.Init() end)
        safeInit("BossMapMgr", function() BossMapMgr.Init() end)
        safeInit("ExploreMapMgr", function() ExploreMapMgr.Init() end)
        PerFormanceAnalyzer.End("left1.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(86)
        end 
    end
       
    local function func28()
        PerFormanceAnalyzer.Start("GameInit-Init()","player.Init()")   
        safeInit("PlayerAnimeMgr", function() PlayerAnimeMgr.Init() end)
        safeInit("PlayerInfoViewMgr", function() PlayerInfoViewMgr.Init() end)
        safeInit("PlayerOperationMgr", function() PlayerOperationMgr.Init() end)
        safeInit("PlayerShareMgr", function() PlayerShareMgr.Init() end)
        safeInit("TownPlayerListMgr", function() TownPlayerListMgr.Init() end)
        safeInit("TownPlayerMgr", function() TownPlayerMgr.Init() end)
        safeInit("PersonalCenterMgr", function() PersonalCenterMgr.Init() end)
        safeInit("PokedexMenuViewMgr", function() PokedexMenuViewMgr.Init() end)
        safeInit("ArenaMainMgr", function() ArenaMainMgr.Init() end)
        safeInit("ArenaViewMgr", function() ArenaViewMgr.Init() end)
        safeInit("MArenaViewMgr", function() MArenaViewMgr.Init() end)
        safeInit("ArenaWinViewMgr", function() ArenaWinViewMgr.Init() end)
        safeInit("ArenaRewardList", function() ArenaRewardList.Init() end)
        safeInit("ArenaTeamViewMgr", function() ArenaTeamViewMgr.Init() end)
        safeInit("ArenaExchangeMgr", function() ArenaExchangeMgr.Init() end)
        safeInit("ArenaRecordMgr", function() ArenaRecordMgr.Init() end)
        safeInit("ArenaPKViewMgr", function() ArenaPKViewMgr.Init() end)
        safeInit("LevelUpViewMgr", function() LevelUpViewMgr.Init() end)
        safeInit("AvatarViewMgr", function() AvatarViewMgr.Init() end)
    
        PerFormanceAnalyzer.Start("player.Init()","CheckViewMgr.Init()")  
        safeInit("CheckViewMgr", function() CheckViewMgr.Init() end)
        PerFormanceAnalyzer.End("CheckViewMgr.Init()") 
        safeInit("FriendsViewMgr", function() FriendsViewMgr.Init() end)
        safeInit("ExchangeViewMgr", function() ExchangeViewMgr.Init() end)
        safeInit("LifeSkillLstViewMgr", function() LifeSkillLstViewMgr.Init() end)
        safeInit("LifeSkillSelViewMgr", function() LifeSkillSelViewMgr.Init() end)
        safeInit("LifeSkillJobChangeViewMgr", function() LifeSkillJobChangeViewMgr.Init() end)
        safeInit("LifeSkillFilterPopUp", function() LifeSkillFilterPopUp.Init() end)
        safeInit("LifeSkillBatchMaker", function() LifeSkillBatchMaker.Init() end)
        safeInit("SelectBeautyViewMgr", function() SelectBeautyViewMgr.Init() end)
        safeInit("CreateFamilyMgr", function() CreateFamilyMgr.Init() end)
        safeInit("FamilyIconMgr", function() FamilyIconMgr.Init() end)
        safeInit("SearchFamilyMgr", function() SearchFamilyMgr.Init() end)
        safeInit("FamilyInfoMgr", function() FamilyInfoMgr.Init() end)
        safeInit("FamilyPlayerViewMgr", function() FamilyPlayerViewMgr.Init() end)
        safeInit("FamilyNpcManagerViewMgr", function() FamilyNpcManagerViewMgr.Init() end)
        safeInit("FamilyQuestListMgr", function() FamilyQuestListMgr.Init() end)
        safeInit("FamilyFloorInfoMgr", function() FamilyFloorInfoMgr.Init() end)
        safeInit("FamilyLogViewMgr", function() FamilyLogViewMgr.Init() end)
        safeInit("FamilyCopyMgr", function() FamilyCopyMgr.Init() end)
        safeInit("FamilyDonateMgr", function() FamilyDonateMgr.Init() end)
        safeInit("FamilyShopMgr", function() FamilyShopMgr.Init() end)
        safeInit("FamilyCopyBonusMgr", function() FamilyCopyBonusMgr.Init() end)
        safeInit("FamilyCopyEventMgr", function() FamilyCopyEventMgr.Init() end)
        safeInit("FamilyCopyTopBarMgr", function() FamilyCopyTopBarMgr.Init() end)
        safeInit("TeamCopyTopBarMgr", function() TeamCopyTopBarMgr.Init() end)
        safeInit("TeamCopyWinMgr", function() TeamCopyWinMgr.Init() end)
        safeInit("ExploreViewMgr", function() ExploreViewMgr.Init() end)
        safeInit("TreeInfoView", function() TreeInfoView.Init() end)
        safeInit("TownTreeMgr", function() TownTreeMgr.Init() end)
        safeInit("TeamViewMgr", function() TeamViewMgr.Init() end)
        safeInit("TeamDropMgr", function() TeamDropMgr.Init() end)
        safeInit("TeamInviteMgr", function() TeamInviteMgr.Init() end)
        safeInit("ExitGameViewMgr", function() ExitGameViewMgr.Init() end)
        safeInit("PVPQuestListMgr", function() PVPQuestListMgr.Init() end)
        safeInit("PVPQuestShopMgr", function() PVPQuestShopMgr.Init() end)
        safeInit("PVPQuestRank", function() PVPQuestRank.Init() end)
        PerFormanceAnalyzer.End("player.Init()") 
        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(87)
        end 
    end

    local function func29()
        PerFormanceAnalyzer.Start("GameInit-Init()","pet.Init()") 
        PerFormanceAnalyzer.Start("pet.Init()","PetInfoViewMgr.Init()") 
        safeInit("PetInfoViewMgr", function() PetInfoViewMgr.Init() end)
        PerFormanceAnalyzer.End("PetInfoViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetGetViewMgr.Init()") 
        safeInit("PetGetViewMgr", function() PetGetViewMgr.Init() end)
        PerFormanceAnalyzer.End("PetGetViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetEquipmentMgr.Init()") 
        safeInit("PetEquipmentMgr", function() PetEquipmentMgr.Init() end)
        PerFormanceAnalyzer.End("PetEquipmentMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PickItemViewMgr.Init()") 
        safeInit("PickItemViewMgr", function() PickItemViewMgr.Init() end)
        PerFormanceAnalyzer.End("PickItemViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PickPurifyViewMgr.Init()") 
        safeInit("PickPurifyViewMgr", function() PickPurifyViewMgr.Init() end)
        PerFormanceAnalyzer.End("PickPurifyViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetEquipmentEvaluateMgr.Init()") 
        safeInit("PetEquipmentEvaluateMgr", function() PetEquipmentEvaluateMgr.Init() end)
        PerFormanceAnalyzer.End("PetEquipmentEvaluateMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetEquipmentRestoreMgr.Init()") 
        safeInit("PetEquipmentRestoreMgr", function() PetEquipmentRestoreMgr.Init() end)
        PerFormanceAnalyzer.End("PetEquipmentRestoreMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetEquipmentOperationMgr.Init()") 
        safeInit("PetEquipmentOperationMgr", function() PetEquipmentOperationMgr.Init() end)
        PerFormanceAnalyzer.End("PetEquipmentOperationMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetEquipmentStrengthenEffectMgr.Init()") 
        safeInit("PetEquipmentStrengthenEffectMgr", function() PetEquipmentStrengthenEffectMgr.Init() end)
        PerFormanceAnalyzer.End("PetEquipmentStrengthenEffectMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","BasicPetListMgr.Init()")     
        safeInit("BasicPetListMgr", function() BasicPetListMgr.Init() end)
        PerFormanceAnalyzer.End("BasicPetListMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PokedexMgr.Init()")     
        safeInit("PokedexMgr", function() PokedexMgr.Init() end)
        PerFormanceAnalyzer.End("PokedexMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetMenuMgr.Init()")     
        safeInit("PetMenuMgr", function() PetMenuMgr.Init() end)
        PerFormanceAnalyzer.End("PetMenuMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetEvolutionMgr.Init()")      
        safeInit("PetEvolutionMgr", function() PetEvolutionMgr.Init() end)
        PerFormanceAnalyzer.End("PetEvolutionMgr.Init()")
     
        PerFormanceAnalyzer.Start("pet.Init()","PetStrengthenMgr.Init()")    
        safeInit("PetStrengthenMgr", function() PetStrengthenMgr.Init() end)
        PerFormanceAnalyzer.End("PetStrengthenMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetFormationMgr.Init()")     
        safeInit("PetFormationMgr", function() PetFormationMgr.Init() end)
        PerFormanceAnalyzer.End("PetFormationMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetFeedViewMgr.Init()")        
        safeInit("PetFeedViewMgr", function() PetFeedViewMgr.Init() end)
        PerFormanceAnalyzer.End("PetFeedViewMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetEducationMgr.Init()")        
        safeInit("PetEducationMgr", function() PetEducationMgr.Init() end)
        PerFormanceAnalyzer.End("PetEducationMgr.Init()")

        PerFormanceAnalyzer.Start("pet.Init()","PetChangeNameMgr.Init()")
        safeInit("PetChangeNameMgr", function() PetChangeNameMgr.Init() end)
		PerFormanceAnalyzer.End("PetChangeNameMgr.Init()")
		
		PerFormanceAnalyzer.Start("pet.Init()","PetQuickViewMgr.Init()")
        safeInit("PetQuickViewMgr", function() PetQuickViewMgr.Init() end)
		PerFormanceAnalyzer.End("PetQuickViewMgr.Init()")

        PerFormanceAnalyzer.Start("pet.Init()","PetExploreMgr.Init()")    
        safeInit("PetExploreMgr", function() PetExploreMgr.Init() end)
        PerFormanceAnalyzer.End("PetExploreMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetExploreInfoMgr.Init()")       
        safeInit("PetExploreInfoMgr", function() PetExploreInfoMgr.Init() end)
        PerFormanceAnalyzer.End("PetExploreInfoMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetExploreRewardsMgr.Init()")  
        safeInit("PetExploreRewardsMgr", function() PetExploreRewardsMgr.Init() end)
        PerFormanceAnalyzer.End("PetExploreRewardsMgr.Init()")
        
        PerFormanceAnalyzer.Start("pet.Init()","PetListMgr.Init()") 
        safeInit("PetListMgr", function() PetListMgr.Init() end)
        PerFormanceAnalyzer.End("PetListMgr.Init()") 
    
        PerFormanceAnalyzer.Start("pet.Init()","PetFreeListMgr.Init()")     
        safeInit("PetFreeListMgr", function() PetFreeListMgr.Init() end)
        PerFormanceAnalyzer.End("PetFreeListMgr.Init()")
     
        PerFormanceAnalyzer.Start("pet.Init()","PetStarUpMgr.Init()")    
        safeInit("PetStarUpMgr", function() PetStarUpMgr.Init() end)
     	PerFormanceAnalyzer.End("PetStarUpMgr.Init()")	 
     	safeInit("PetStarupEffectMgr", function() PetStarupEffectMgr.Init() end)	
     	PerFormanceAnalyzer.Start("pet.Init()","PetCommonListViewMgr.Init()")     
     	safeInit("PetCommonListViewMgr", function() PetCommonListViewMgr.Init() end)
     	safeInit("PetSkillViewMgr", function() PetSkillViewMgr.Init() end)
     	safeInit("PetEatPetViewMgr", function() PetEatPetViewMgr.Init() end)
     	safeInit("TipsViewMgr", function() TipsViewMgr.Init() end)
     	safeInit("CommonPetBar", function() CommonPetBar.Init() end)
     	safeInit("BattleManualMgr", function() BattleManualMgr.Init() end)
     	safeInit("PetStarupResetViewMgr", function() PetStarupResetViewMgr.Init() end)
     	safeInit("PetQuickTrainViewMgr", function() PetQuickTrainViewMgr.Init() end)
     	PerFormanceAnalyzer.End("PetCommonListViewMgr.Init()")
        PerFormanceAnalyzer.End("pet.Init()") 
    
        PerFormanceAnalyzer.Start("pet.Init()","PetEvolutionEffectMgr.Init()")     
        safeInit("PetEvolutionEffectMgr", function() PetEvolutionEffectMgr.Init() end)
        PerFormanceAnalyzer.End("PetEvolutionEffectMgr.Init()")
    
        PerFormanceAnalyzer.Start("pet.Init()","PetFCEffectMgr.Init()")     
        safeInit("PetFCEffectMgr", function() PetFCEffectMgr.Init() end)
        PerFormanceAnalyzer.End("PetFCEffectMgr.Init()")
         
        PerFormanceAnalyzer.Start("GameInit-Init()","other.Init()")   
        PerFormanceAnalyzer.Start("other.Init()","BagViewMgr.Init()")    
        safeInit("BagViewMgr", function() BagViewMgr.Init() end)
        PerFormanceAnalyzer.End("BagViewMgr.Init()") 
    
        PerFormanceAnalyzer.Start("other.Init()","ActivityViewMgr.Init()")
        safeInit("ActivityPublicjMgr", function() ActivityPublicjMgr.Init() end)
        safeInit("ActivityViewMgr", function() ActivityViewMgr.Init() end)
        PerFormanceAnalyzer.End("ActivityViewMgr.Init()")

        PerFormanceAnalyzer.Start("other.Init()","ActivityCapsuleEggView.Init()")    
        safeInit("ActivityCapsuleEggView", function() ActivityCapsuleEggView.Init() end)
        PerFormanceAnalyzer.End("ActivityCapsuleEggView.Init()")

        PerFormanceAnalyzer.Start("other.Init()","CollectPetActivityViewMgr.Init()")    
        safeInit("CollectPetActivityViewMgr", function() CollectPetActivityViewMgr.Init() end)
        PerFormanceAnalyzer.End("CollectPetActivityViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","HalloweenCapsuleEggView.Init()")    
        safeInit("HalloweenCapsuleEggView", function() HalloweenCapsuleEggView.Init() end)
        PerFormanceAnalyzer.End("HalloweenCapsuleEggView.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","ActivityHalloweenViewMgr.Init()")    
        safeInit("ActivityHalloweenViewMgr", function() ActivityHalloweenViewMgr.Init() end)
        PerFormanceAnalyzer.End("ActivityHalloweenViewMgr.Init()")

        PerFormanceAnalyzer.Start("other.Init()","RechargeViewMgr.Init()")    
        safeInit("RechargeViewMgr", function() RechargeViewMgr.Init() end)
        PerFormanceAnalyzer.End("RechargeViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","NoticeViewMgr.Init()")    
        safeInit("NoticeViewMgr", function() NoticeViewMgr.Init() end)
        PerFormanceAnalyzer.End("NoticeViewMgr.Init()") 
        
        PerFormanceAnalyzer.Start("other.Init()","BossFailedMgr.Init()")    
        safeInit("BossFailedMgr", function() BossFailedMgr.Init() end)
        PerFormanceAnalyzer.End("BossFailedMgr.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","BossTopBarMgr.Init()")    
        safeInit("BossTopBarMgr", function() BossTopBarMgr.Init() end)
        PerFormanceAnalyzer.End("BossTopBarMgr.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","ScienceViewMgr.Init()")    
        safeInit("ScienceViewMgr", function() ScienceViewMgr.Init() end)
        safeInit("ScienceDevelopMgr", function() ScienceDevelopMgr.Init() end)
        PerFormanceAnalyzer.End("ScienceViewMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","SkillBookViewMgr.Init()")     
        safeInit("SkillBookViewMgr", function() SkillBookViewMgr.Init() end)
        PerFormanceAnalyzer.End("SkillBookViewMgr.Init()") 
     
        PerFormanceAnalyzer.Start("other.Init()","FurnitureViewMgr.Init()")      
        safeInit("FurnitureViewMgr", function() FurnitureViewMgr.Init() end)
        PerFormanceAnalyzer.End("FurnitureViewMgr.Init()") 
    
        PerFormanceAnalyzer.Start("other.Init()","FurnitureTVMgr.Init()")         
        safeInit("FurnitureTVMgr", function() FurnitureTVMgr.Init() end)
        PerFormanceAnalyzer.End("FurnitureTVMgr.Init()")
     
        PerFormanceAnalyzer.Start("other.Init()","FurnitureSofaMgr.Init()")      
        safeInit("FurnitureSofaMgr", function() FurnitureSofaMgr.Init() end)
        PerFormanceAnalyzer.End("FurnitureSofaMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","ItemInfoViewMgr.Init()")    
        safeInit("ItemInfoViewMgr", function() ItemInfoViewMgr.Init() end)
        PerFormanceAnalyzer.End("ItemInfoViewMgr.Init()")
        
        PerFormanceAnalyzer.Start("other.Init()","ItemNumViewMgr.Init()") 
        safeInit("ItemNumViewMgr", function() ItemNumViewMgr.Init() end)
        PerFormanceAnalyzer.End("ItemNumViewMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","ShopListMgr.Init()")     
        safeInit("ShopListMgr", function() ShopListMgr.Init() end)
        PerFormanceAnalyzer.End("ShopListMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","AuctionMgr.Init()")      
        safeInit("AuctionMgr", function() AuctionMgr.Init() end)
        PerFormanceAnalyzer.End("AuctionMgr.Init()")
      
        PerFormanceAnalyzer.Start("other.Init()","PurchaseViewMgr.Init()")   
        safeInit("PurchaseViewMgr", function() PurchaseViewMgr.Init() end)
        PerFormanceAnalyzer.End("PurchaseViewMgr.Init()")

        PerFormanceAnalyzer.Start("other.Init()","PurchaseViewMgr.Init()")   
        safeInit("VipShopViewMgr", function() VipShopViewMgr.Init() end)
        PerFormanceAnalyzer.End("PurchaseViewMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","MailMgr.Init()")       
        safeInit("MailMgr", function() MailMgr.Init() end)
        PerFormanceAnalyzer.End("MailMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","AwardsListMgr.Init()")    
        safeInit("AwardsListMgr", function() AwardsListMgr.Init() end)
        PerFormanceAnalyzer.End("AwardsListMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","GachaViewMgr.Init()") 
        safeInit("GachaViewMgr", function() GachaViewMgr.Init() end)
        PerFormanceAnalyzer.End("GachaViewMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","AuctionMgrNew.Init()")     
        safeInit("AuctionMgrNew", function() AuctionMgrNew.Init() end)
        PerFormanceAnalyzer.End("AuctionMgrNew.Init()")
     
        PerFormanceAnalyzer.Start("other.Init()","BuyInfoMgr.Init()")     
        safeInit("BuyInfoMgr", function() BuyInfoMgr.Init() end)
        PerFormanceAnalyzer.End("BuyInfoMgr.Init()")
     
        PerFormanceAnalyzer.Start("other.Init()","BuyInfoMgr2.Init()")       
        safeInit("BuyInfoMgr2", function() BuyInfoMgr2.Init() end)
        PerFormanceAnalyzer.End("BuyInfoMgr2.Init()")

        PerFormanceAnalyzer.Start("other.Init()","BuyItemViewMgr.Init()")       
        safeInit("BuyItemViewMgr", function() BuyItemViewMgr.Init() end)
        PerFormanceAnalyzer.End("BuyItemViewMgr.Init()")
     
        PerFormanceAnalyzer.Start("other.Init()","SellInfoMgr.Init()")     
        safeInit("SellInfoMgr", function() SellInfoMgr.Init() end)
        PerFormanceAnalyzer.End("SellInfoMgr.Init()")
    
        PerFormanceAnalyzer.Start("other.Init()","AuctionSearch.Init()")      
        safeInit("AuctionSearch", function() AuctionSearch.Init() end)
    	PerFormanceAnalyzer.End("AuctionSearch.Init()")	 
    	PerFormanceAnalyzer.End("other.Init()")     
    	safeInit("DropInfoViewMgr", function() DropInfoViewMgr.Init() end)	
    	safeInit("TrainStoneMgr", function() TrainStoneMgr.Init() end)
    	safeInit("BossDmgAwardsMgr", function() BossDmgAwardsMgr.Init() end)
    	PerFormanceAnalyzer.Start("GameInit-Init()","Confra.Init()")   
    	safeInit("ConfraListViewMgr", function() ConfraListViewMgr.Init() end)
        safeInit("ConfraInfoViewMgr", function() ConfraInfoViewMgr.Init() end)
        PerFormanceAnalyzer.End("Confra.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","Chat.Init()")        
        safeInit("ChatUIMgr", function() ChatUIMgr.Init() end) 
        safeInit("ChatBubbleMgr", function() ChatBubbleMgr.Init() end)
        safeInit("ChatMsgMgr", function() ChatMsgMgr.Init() end)
        safeInit("TownChatMgr", function() TownChatMgr.Init() end)
        safeInit("PetShareDetail", function() PetShareDetail.Init() end)
        safeInit("MsgBoardView", function() MsgBoardView.Init() end)
        PerFormanceAnalyzer.End("Chat.Init()") 
        
        PerFormanceAnalyzer.Start("GameInit-Init()","Mission.Init()")     
        safeInit("NpcDialogueMgr", function() NpcDialogueMgr.Init() end)   
        safeInit("MissionGuideMgr", function() MissionGuideMgr.Init() end)
        safeInit("MissionInfoMgr", function() MissionInfoMgr.Init() end)
        safeInit("TownMissionMgr", function() TownMissionMgr.Init() end)
        safeInit("NpcMgr", function() NpcMgr.Init() end)
        safeInit("MissionListMgr", function() MissionListMgr.Init() end)
        safeInit("AchievementListMgr", function() AchievementListMgr.Init() end)
        PerFormanceAnalyzer.End("Mission.Init()") 
    
        PerFormanceAnalyzer.Start("GameInit-Init()","Adv.Init()") 
        safeInit("SearchingMgr", function() SearchingMgr.Init() end)
        safeInit("SearchingUIMgr", function() SearchingUIMgr.Init() end)
        safeInit("AdvStarMgr", function() AdvStarMgr.Init() end)
        safeInit("AdvPetsMgr", function() AdvPetsMgr.Init() end)
        safeInit("SearchingFuncMgr", function() SearchingFuncMgr.Init() end)
        safeInit("AdvCharMgr", function() AdvCharMgr.Init() end)
        safeInit("AdvConfirmMgr", function() AdvConfirmMgr.Init() end)
        safeInit("StageBossListMgr", function() StageBossListMgr.Init() end)
        safeInit("AdvConfirmMgrNew", function() AdvConfirmMgrNew.Init() end)
        safeInit("AdvEnvironmentMgr", function() AdvEnvironmentMgr.Init() end)
        safeInit("advResetView", function() advResetView.Init() end)
        PerFormanceAnalyzer.End("Adv.Init()") 
       
        PerFormanceAnalyzer.Start("GameInit-Init()","losttower.Init()")  
        safeInit("LostTowerInfo", function() LostTowerInfo.Init() end)
        safeInit("LostTowerMgr", function() LostTowerMgr.Init() end)
        safeInit("LtMapOption", function() LtMapOption.Init() end)
        safeInit("LtEventOption", function() LtEventOption.Init() end)
        safeInit("LtMapNodeMgr", function() LtMapNodeMgr.Init() end)
        safeInit("LtPlayerMgr", function() LtPlayerMgr.Init() end)
        safeInit("LostTowerUIMgr", function() LostTowerUIMgr.Init() end)
        safeInit("LtFuncMgr", function() LtFuncMgr.Init() end)
        safeInit("LtPetsMgr", function() LtPetsMgr.Init() end)
        safeInit("LtPropMgr", function() LtPropMgr.Init() end)
        safeInit("LtHealViewMgr", function() LtHealViewMgr.Init() end)
        safeInit("LtRankingViewMgr", function() LtRankingViewMgr.Init() end)
        safeInit("LtExchangeViewMgr", function() LtExchangeViewMgr.Init() end)
        safeInit("LtResetViewMgr", function() LtResetViewMgr.Init() end)
        safeInit("LtPickPetViewMgr", function() LtPickPetViewMgr.Init() end)
        safeInit("LtWarFogMgr", function() LtWarFogMgr.Init() end)
        safeInit("LtOpenBoxView", function() LtOpenBoxView.Init() end)
        safeInit("LtTransferViewMgr", function() LtTransferViewMgr.Init() end)
        safeInit("LtStepAddView", function() LtStepAddView.Init() end)
        safeInit("LtExBufferMgr", function() LtExBufferMgr.Init() end)
        safeInit("LtChangeFloorView", function() LtChangeFloorView.Init() end)
        safeInit("LtRankAwardList", function() LtRankAwardList.Init() end)
        PerFormanceAnalyzer.End("losttower.Init()") 
        
        PerFormanceAnalyzer.Start("GameInit-Init()","WorldBoss.Init()")
        safeInit("WorldBossInfo", function() WorldBossInfo.Init() end)
        PerFormanceAnalyzer.End("WorldBoss.Init()")
        
        PerFormanceAnalyzer.Start("GameInit-Init()","PetEquip.Init()")  
        safeInit("PetEquipInfo", function() PetEquipInfo.Init() end)
        PerFormanceAnalyzer.End("PetEquip.Init()")

        safeInit("SurviveBattleViewMgr", function() SurviveBattleViewMgr.Init() end)
        safeInit("ActivityShopViewMgr", function() ActivityShopViewMgr.Init() end)
           
        PerFormanceAnalyzer.Start("GameInit-Init()","Family.Init()")  
        safeInit("FamilyListViewMgr", function() FamilyListViewMgr.Init() end)
        safeInit("MyFamilyLstViewMgr", function() MyFamilyLstViewMgr.Init() end)
        safeInit("FamilyApplyListViewMgr", function() FamilyApplyListViewMgr.Init() end)
        safeInit("FamilyTransListViewMgr", function() FamilyTransListViewMgr.Init() end)
        safeInit("PetHandBook", function() PetHandBook.Init() end)
        PerFormanceAnalyzer.End("Family.Init()")  
        
        PerFormanceAnalyzer.Start("GameInit-Init()","DungeonMapMgr.Init()")     
        safeInit("DungeonMapMgr", function() DungeonMapMgr.Init() end)
        safeInit("DungeonPlayerMgr", function() DungeonPlayerMgr.Init() end)    
        PerFormanceAnalyzer.End("DungeonMapMgr.Init()")  
        safeInit("GameLogMgr", function() GameLogMgr.Init() end)   
        safeInit("XFangCunLogSender", function() XFangCunLogSender.Init() end)
        safeInit("UIStack", function() UIStack.Init() end)
        safeInit("PayConfig", function() PayConfig.Init() end)
        safeInit("SevenDayRedPointManager", function() SevenDayRedPointManager.Init() end)
        g_userID = -1
        
        PerFormanceAnalyzer.End("GameInit-Init()")

        if progressbar~=nil then 
            progressbar:setVisible(true)
            progressbar.progressTimer:setPercentage(90)
        end 
    end

    local funcTable = {funcend,func0,func1,func2,func3,func4,func5,func6,func7,func8,func9,func10,func11,func12,func13,func14,func15,func16,func17,func18,func19,func20,func21,func22,func23,func24,func25,func26,func27,func28,func29,endcallback}
    if isReInit then
        for var=1, #funcTable do
     		funcTable[var]()
     	end

        AllSDKManager.FangCun:restart()
    else
        if device.platform == "ios" then
            -- 默认为主包参数 -"com.joygames.mxm.two"
            local sdkAppId  = "1607130001"
            local sdkAppKey = "031c2aadfb17bfce49324365d0c228cb"
            
            local ok, ret = luaoc.callStaticMethod("iOSsystemFunc", "getBundleIdentifier", nil)
            if ok and ret == "com.alpha.monster2.luotianyi" then  -- 备包1
                sdkAppId  = "1610120001"
                sdkAppKey = "0b674d3560004d2aeb85238f89e514e0"
            end
            if ok and ret == "com.joygames.monster" then  -- 备包2
                sdkAppId  = "1611210001"
                sdkAppKey = "d8ef4b14829d6d24254547bee7a97393"
            end
            if ok and ret == "com.joygames.monsterworld" then  -- 备包3
                sdkAppId  = "1611210002"
                sdkAppKey = "8ba4188b16222a172c0be567a2ac423c"
            end

            if ok and ret == "com.gwlm.233" then  -- 备包3
                sdkAppId  = "1802130002"
                sdkAppKey = "f31dffb0c461a264287fc08555fac094"
            end
        
            iOSFunction.initSdk({appId=sdkAppId, appKey=sdkAppKey, channelId="1002", channelName="zyzs", isDebug="false"})
                
            iOSFunction.AdTrackingInit({appId="47b12ec842ee4927b84f8a52acfe2e05", channelId="AppStore"})
        end
        UnblockLoader.load(funcTable,"GameInit")
    end
end

return GameInit