print("Begin running debug.lua")

-- g_p_step = g_p_step or 0

-- if g_p_step == 0 then
--  DebugHelper:StartLuaProfile(true)
--  g_p_step = 1
-- else
--  DebugHelper:StopLuaProfile()
--  DebugHelper:DumpLuaProfile(gameConfig.resourcePath.."LuaDebugDump.log")
--  g_p_step= 0
-- end

print(" 测试开始")
--dofile("D:/Cocos/MxMProject/client/QuickGameProject/src/GameMgr/DebugInfoMgr.lua")
--GameGuideMgr.firstEliteAdventure()
--GameGuideMgr.firstQuickClear()
--[[
if CharInfo.getFamilyID() == nil then --没家族
FamilyListViewMgr.show(SceneMgr.getRunningScene)
else --有家族
MyFamilyLstViewMgr.show(SceneMgr.getRunningScene)
end
]]
--[[
ObjectPool.init()
CSResourceMgr.createRes(nil,"Pet/BasicPetList_2/PetListPanelTemplate.csb")
for i=1,4 do
    local listcell = CSResourceMgr.getNodeByName("Pet/BasicPetList_2/PetListPanelTemplate.csb","panel"):clone()
    --listcell:retain()
    --listcell:release()
    ObjectPool.add("PetListUI",listcell)
end  
]]
--ObjectPool.freeAll()

--DebugInfoMgr.testAvatar();

--SceneMgr.replaceScene(SceneMgr.getRunningScene,"MainScene")

--FamilyListViewMgr.show(SceneMgr.getRunningScene)

--PerFormanceAnalyzer.OutPutPerformaceReport()

--PetHandBook.show(SceneMgr.getRunningScene)

--local iconBtn = ItemInfo.getItemIconById(20,90)
--iconBtn:setPosition(320,480)
--iconBtn:setLocalZOrder(100)
--SceneMgr.getRunningScene:addChild(iconBtn)
--local str = display.getCachedTextureInfo()

--PetStarupEffectMgr.show(SceneMgr.getRunningScene, 1, 1, nil)
--local t1 = os.clock()
--AudioEngine.AudioEngine:play2d(GameAudio.DEFAULT_BUTTON_SOUND)
--GameAudio.playSound(GameAudio.DEFAULT_BUTTON_SOUND)
--local t2 = os.clock()
--print("sound  take time:"..t2-t1)

--[[
AwardsListMgr.show(SceneMgr.getRunningScene, { {10002,99}, {10003,99}, {10006,99}, {10004,99}, {10005,99}, 
{38041,1}, {38042,2},{38043,2},{38044,2},{38045,2}})]]
--PerFormanceAnalyzer.OutPutPerformaceReport()
--GameAudio.preLoadBattleSound()
--[[
local frontRes = "Gaf/effect/createCharFront.gaf"
local scene = SceneMgr.getRunningScene
local size = scene:getContentSize()
local backRes = "Gaf/effect/createCharBack.gaf"
local effect = AnimationMgr.createAni(SceneMgr.getRunningScene,backRes,size.width/2,1200)
AnimationMgr.playAni(backRes,"do",true)
effect:setLocalZOrder(99)


local effect = AnimationMgr.createAni(SceneMgr.getRunningScene,frontRes,size.width/2,1020)
AnimationMgr.playAni(frontRes,"do",true)
effect:setLocalZOrder(100)
]]


--local loadingResSpine = "Spine/effects/loading.png"
--local aniBG = AnimationMgr.createAni(SceneMgr.getRunningScene, loadingResSpine, 320, 480)

--AnimationMgr.playAniWithCallback(aniBG.res, "animation",nil,nil, true)
--print(display.getCachedTextureInfo())
--local c1 = collectgarbage("count")
--display.removeUnusedSpriteFrames()
--print("结束后的lua内存:"..c1)
--DebugInfoMgr.testMain()
UIStack.onBackMenu()

--LifeSkillLstViewMgr.changeVisible(false)
print(" 测试结束")
print("End of debug.lua")
