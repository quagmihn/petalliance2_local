local PlayerOperationMgr = {}

local bRes = ""
local resName = ""

local friendLockLevel = 1

function PlayerOperationMgr.Init()
    bRes = "Charactor/PressButton.csb"
    resName = "Charactor/OperationList/OperationList.csb"
    
    local value = SystemInfo.getGlobalConfigAddInfoByID(21006)
    if value then
        friendLockLevel = value.values[1]
    end
end

---以其他的玩家信息注册操作列表
--@param params table 玩家信息，格式为{playerRes="123.gaf", petRes="123.gaf", ...}
--{playerRes="", level="", confraternity="", nickname="", petRes="", petname="", posx=, speed=}
--@param playerRes string 玩家的gaf资源名称
--@param nickname string 玩家的昵称信息
--@param level string 玩家等级
--@param confraternity string 玩家所属公会
--@param petRes string 玩家携带宠物的gaf资源名称
--@param petname string 玩家携带宠物的昵称信息
--@param posx int 玩家相对地图的初始位置
--@param speed int 玩家的移动速度
function PlayerOperationMgr.rigist(params)
    local PressButton = CSResourceMgr.createRes(TownPlayerMgr.PlayerTable[params.charID][4], bRes, params.charID)
    PressButton:setPosition(50, -150)
    CSResourceMgr.clickEventBinding(bRes, "PressButton", function()
        local function closeOperationList()
            local list = CSResourceMgr.getCsbObj(resName)
            if list then
                transition.scaleTo(list, {scale = 0, time = 0.2})
                list:performWithDelay(function()
                    CSResourceMgr.removeCSObjectByTag(resName)
                end, 0.5)
            end
            TownPlayerMgr.PlayerTable[params.charID][6] = false
        end

        local isOperationListOpening = TownPlayerMgr.PlayerTable[params.charID][6]
        if not isOperationListOpening then
            local function initCsb()
                local list = CSResourceMgr.createRes(TownPlayerMgr.PlayerTable[params.charID][4], resName)
                list:setAnchorPoint(0.5, 0)
                list:setScale(1, 1)
                list:setPosition(75, 50)
                list:setVisible(false)

                for tags, val in pairs(TownPlayerMgr.PlayerTable) do
                    val[6] = false
                end
                TownPlayerMgr.PlayerTable[params.charID][6] = true
                
                if params.level<friendLockLevel or CharInfo.getLevel()<friendLockLevel 
                    or FriendsViewMgr.isHaveFriend({friendID=params.charID}) then
                    CSResourceMgr.setButtonEnabled(resName, "Button5", false)
                end
                if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil or params.confraternity then
                    CSResourceMgr.setButtonEnabled(resName, "Button6", false)
                end
                CSResourceMgr.setButtonEnabled(resName, "Button2", false)
            end  

            local function playCsb()
                CSResourceMgr.getCsbObj(resName):setVisible(true)
                CSResourceMgr.playAllFrame(resName, false)
                CSResourceMgr.playAllFrameWithCallback(resName, 1, function()
                    for var=1, 6 do
                        CSResourceMgr.clickEventBinding(resName, "Button"..var, function()
                            closeOperationList()
                            if var==1 then
                                PersonalCenterMgr.show(SceneMgr.getRunningScene, params.charID)
                            elseif var==2 then
                                TipsMgr.show(nil, "显示宠物信息")
                            elseif var==3 then
                                BattlePVPMgr.sendCG_StartPVP_Req(params.charID)
                            elseif var==4 then
                                TownChatMgr.setOneChat({name = params.nickname,id = params.charID})
                            elseif var==5 then
                                NetInterface.sendWithBlock("GC_AddFriend_Ack", function()
                                    local ChatUserSend = require("src.Net.Send.ChatUserSend")
                                    ChatUserSend.sendCG_AddFriend_Req({friendID = params.charID})
                                end, function()
                                	TipsMgr.show(nil, "tips26")
                                end, function(code)
                                	TipsMgr.showError(nil, code)
                                end)
                            elseif var==6 then
                                if CharInfo.getFamilyID() == nil or FamilyInfo.GetLocalFamilyInfo() == nil then
                                    StandardTipsMgr.show(1, "family10")
                                elseif params.level < SystemInfo.getGlobalConfigAddInfoByID(24005).values[1] then
                                    StandardTipsMgr.show(1, "family12")
                                else
                                    NetInterface.sendWithBlock("GC_Chat_Ack", function()
                                        FamilyInfo.SendInviteEnterFamily(params.charID)
                                    end, function()
                                        TipsMgr.show(nil, "tips27")
                                    end, function(code)
                                    	TipsMgr.showError(nil, code)
                                    end)
                                end
                            end
                        end, "", 3)
                    end
                end)
            end

            local funcTable = {initCsb, playCsb}
            UnblockLoader.load(funcTable)
        else
            closeOperationList()
        end
    end, params.charID)
end

return PlayerOperationMgr