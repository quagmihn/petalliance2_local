local LtRankAwardList = {}

local resName = ""
LtRankAwardList.Layer = nil
local bgNode = {}
local itemNode = {}

local tipsText = {}

function LtRankAwardList.Init()
    print("LtRankAwardList初始化")

    resName = "Player/Arena/ArenaRewardList.csb"

    bgNode = {}
    itemNode = {}
    
    tipsText = {"LtTips22", "Territorialtips22"}
end

function LtRankAwardList.show(scene, awardListTable, type, totalRank)
    type = type or 1

    local function playAction()
        local panel1 = CSResourceMgr.getNodeByName(resName, "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(resName, "panel_2")
        panel1:setVisible(true)
        panel2:setVisible(true)
        CocosModuleMgr.showUIAnimation(panel1, "down")
        CocosModuleMgr.showUIAnimation(panel2, "down")

        -- panel1:setOpacity(0)
        -- panel2:setOpacity(0)
        -- transition.fadeIn(panel1, {time=0.5})
        -- transition.fadeIn(panel2, {time=0.5})
    end

    local function turnToTop()
        CSResourceMgr.getNodeByName(resName, "list"):jumpToTop()
    end

    UIStack.push("LtRankAwardList", LtRankAwardList.hide, false)
    if CSResourceMgr.getCsbObj(resName) ~= nil then
        LtRankAwardList.Layer:setVisible(true)
        turnToTop()
        playAction()
        return
    end

    local function loadCSB()
        LtRankAwardList.Layer = CSResourceMgr.createRes(scene, resName)
        CSResourceMgr.setFullScreen(resName)
        LtRankAwardList.Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW + 2)
        -- LtRankAwardList.Layer:setOpacity(0)

        local panel1 = CSResourceMgr.getNodeByName(resName, "panel_1")
        local panel2 = CSResourceMgr.getNodeByName(resName, "panel_2")
        local list = CSResourceMgr.seekNodeByName(panel1, "list")
        local bg1  = CSResourceMgr.seekNodeByName(panel1, "bg1")
        local diff = CocosModuleMgr.getScreenSizeDiff()-- > 0 and CocosModuleMgr.getScreenSizeDiff() or 0
        ViewMgrUtils.vFitSetPos(diff, {panel1})
        ViewMgrUtils.vFitSetPos(-diff, {panel2})
        ViewMgrUtils.vFitStretch(diff, {list, bg1})

        panel1:setVisible(false)
        panel2:setVisible(false)

        -- transition.fadeIn(LtRankAwardList.Layer, {time=0.5})
    end

    local function loadUI()
        local title = CSResourceMgr.getNodeByName(resName, "title")
        local btnClose = CSResourceMgr.getNodeByName(resName, "btn_close")
        local rewardInfo = CSResourceMgr.getNodeByName(resName, "reward_info")
        local btnBG = CSResourceMgr.getNodeByName(resName, "btn")

        CSResourceMgr.setLabelStringByNode(title, "arena52", {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 250)
        local tip = tipsText[type]
        if totalRank then
            tip = "pvptasktips13"
        end
        CSResourceMgr.setLabelStringByNode(rewardInfo, tip, {r=0,g=0,b=0,a=255,w=1,s=2}, nil, 505)  -- 发放时间提示
        CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255})
        CSResourceMgr.setLabelColorByNode(rewardInfo, {r=144,g=238,b=255,a=255})

        CSResourceMgr.clickEventBindingByNode(btnClose, function ()
            LtRankAwardList.hide()
        end)
        CSResourceMgr.clickEventBindingByNode(btnBG, function ()
            LtRankAwardList.hide()
        end)
    end

    local function loadItems()
        local list = CSResourceMgr.getNodeByName(resName, "list")
        local parent = CSResourceMgr.getNodeByName(resName, "reward")

        local i = 1
        local itemFuncTable = {}
        for k,v in pairs(awardListTable) do
            local panelFunc = function()
                bgNode[i] = parent:clone()
    
                local info = awardListTable[i]
                if not info then return end
                
                local rankNum = info.id
    
                local bg1 = CSResourceMgr.seekNodeByName(bgNode[i], "bg1")
                local bg2 = CSResourceMgr.seekNodeByName(bgNode[i], "bg2")
                local title = CSResourceMgr.seekNodeByName(bgNode[i], "reward_title")
                bg1:setColor({r=24,g=44,b=58,a=255})
    
                local strRankNum = CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum})
                if type == 1 then -- 千层塔排行预览
                    if i ~= #awardListTable then--不是最后一个
                        if rankNum ~= (awardListTable[i + 1].id - 1) then--有差值
                            local rankNum2 = (awardListTable[i + 1].id - 1)
                            strRankNum = strRankNum.."~"..CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum2})
                        end
                    else
                        local rankNum2 = SystemInfo.getGlobalConfigAddInfoByID(78).values[1]
                        if totalRank then
                            rankNum2 = totalRank
                        end
                        strRankNum = strRankNum.."~"..CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum2})
                    end
                elseif type == 2 then -- 领主排行预览
                    strRankNum = CocosModuleMgr.createStringWithFormat({LuaSqlite.getLanguageByKey("arena54"), rankNum})   -- arena55-"第<1>名以后"
                end
                CSResourceMgr.setLabelStringByNode(title, strRankNum)
                CSResourceMgr.setLabelColorByNode(title, {r=255,g=234,b=0,a=255,w=1,w=2})
    
                local awardInfo = v  -- ArenaInfo.getArenaAwardInfo(rankNum)
                local numCol = {r=255,g=255,b=255,a=255}
    
                for var = 1, #awardInfo.awardItems do
                    local elementID = awardInfo.awardItems[var].elementID
                    local number    = awardInfo.awardItems[var].count
                    itemNode[var] = ItemInfo.getItemIconById(elementID, number, numCol)
                    
                    local posX = 295 + (var - 2) * 120
                    if totalRank then
                        posX = 235 + (var - 2) * 120
                    end
                    local posY = 65
                    itemNode[var]:setPosition(posX, posY)
                    itemNode[var]:removeFromParent()
                    itemNode[var]:addTo(bg2)
                    itemNode[var]:setScale(0.7)
    
                    CSResourceMgr.clickEventBindingByNode(itemNode[var], function ()
                        ItemInfoViewMgr.show({id = elementID}, false)
                    end)
                end
                list:pushBackCustomItem(bgNode[i])
                
                i = i + 1
            end
            table.insert(itemFuncTable, panelFunc)
        end
        
        UnblockLoader.load(itemFuncTable,"LtRankAwardList-setItems")
    end

    local funcTable = {loadCSB, loadUI, loadItems, playAction}
    UnblockLoader.load(funcTable,"LtRankAwardList")
    
--    loadCSB() loadUI() loadItems() playAction()
end

function LtRankAwardList.hide()
    -- LtRankAwardList.Layer:setOpacity(0)
    LtRankAwardList.Layer:setVisible(false)
    UnblockLoader.cancel("LtRankAwardList-setItems")
    UnblockLoader.cancel("LtRankAwardList")
    UIStack.pop("LtRankAwardList")

    bgNode = {}
    itemNode = {}
    
    CSResourceMgr.removeCSObjectByTag(resName)
end

return LtRankAwardList