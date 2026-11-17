local AdvClearView = {}

local resNameBG = "Pet/Formation/FormationBGNew.csb"
local resName = "Searching/Summary/PlayerWinViewNew.csb"
local tag     = ""

local CHAR_MAX_LEVEL = 80
local CHAR_MAX_EXP

local listMoveFlag = false

--重复item整合
local function packItems()
    local items_afterPack = {}
    
    for key=1, #SearchingMgr.awardsTbl do --key, value in pairs(SearchingMgr.awardsTbl) do
        local value = SearchingMgr.awardsTbl[key]
        if value.elementType == "item" then
            local found = false
            for i=1, #items_afterPack do  --#items_afterPack为insert前长度
                if value.elementID == items_afterPack[i].elementID then
                    found = true
                    items_afterPack[i].num = items_afterPack[i].num + value.num
                end
            end
            if not found then 
                table.insert(items_afterPack, value)
            end
        end
    end
    
    return items_afterPack
end

local function getLevelWithExp(exp)
    local tmpExp = 0
    local tmpLevel = 0
    while exp >= tmpExp do
        if tmpLevel == CHAR_MAX_LEVEL then break end
        
        tmpLevel = tmpLevel + 1
        tmpExp = ExperienceInfo.getExperienceInfoByID(tmpLevel).roleExp
    end
    
    return tmpLevel
end

function AdvClearView.show(scene, _charInfo)
    listMoveFlag = false
    
    CHAR_MAX_EXP = ExperienceInfo.getExperienceInfoByID(CHAR_MAX_LEVEL).roleExp

    scene = scene or SceneMgr.getRunningScene
    
    local advInfo  = AdventureInfo.getAdventureInfoByID(SearchingMapMgr.currAdventure)
    if not advInfo then return end
    
    local Layer, board
    local title, flash1, flash2
    local coin_root, exp_root
    local expBar_db
    local gains_db
    
    local coin_label, exp_label
    local LvLabel, ExpLabel
    
    local winString, star_db
    
    local animateNodes = {}
    
    -- ############# segment ##############
    local starNum    = 0
    local gains_coin = 0
    local gains_exp  = 0
    local charLevel = _charInfo.level
    local expString = ""
    -- ####################################
    
    local function playSound()
        GameAudio.playUISound("completeLevel")
    end
    
    local function loadBG()
        local bgLayer = CSResourceMgr.createRes(scene, resNameBG, "AdvClearView")
        bgLayer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBG, 320, 480, "AdvClearView")
        bgLayer:setOpacity(0)
        transition.fadeIn(bgLayer, {time=0.3})
    end
    
    local function loadCSB()
        Layer = CSResourceMgr.createRes(scene,resName,tag)
        Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CocosModuleMgr.setRelativePosition(Layer, 320, 480)
        CSResourceMgr.setFullScreen(resName,tag)
        
        -- 一级动画
        title  = CSResourceMgr.getNodeByName(resName,{"board","title_db"},tag)
--        flash1 = CSResourceMgr.getNodeByName(resName,{"board","flash1"},tag)
--        flash2 = CSResourceMgr.getNodeByName(resName,{"board","flash2"},tag)
        title:setPositionY(title:getPositionY()-250)
        title:setScale(0)
--        flash1:setVisible(false)
--        flash2:setVisible(false)

        local wordTex = CocosModuleMgr.getWordImage("adventureWin.png")
        CSResourceMgr.seekNodeByName(title,"winString"):loadTexture(wordTex)
        
        coin_root = CSResourceMgr.getNodeByName(resName,{"board","coin_db"},tag)
        exp_root  = CSResourceMgr.getNodeByName(resName,{"board","exp_db"},tag)
        coin_root:setPositionY(coin_root:getPositionY()-100)
        exp_root:setPositionY(exp_root:getPositionY()-100)
        coin_root:setOpacity(0)
        exp_root:setOpacity(0)
        
        expBar_db = CSResourceMgr.getNodeByName(resName,{"board","expBar_db"},tag)
        expBar_db:setPositionY(expBar_db:getPositionY()-100)
        expBar_db:setOpacity(0)
        
        gains_db = CSResourceMgr.getNodeByName(resName,{"board","gains_db"},tag)
        gains_db:setOpacity(0)
        
        -- 二级动画
        coin_label = CSResourceMgr.seekNodeByName(coin_root,"coin_n")
        exp_label  = CSResourceMgr.seekNodeByName(exp_root,"exp_n")
        
        LvLabel = CSResourceMgr.seekNodeByName(expBar_db,"lvLabel")
        ExpLabel = CSResourceMgr.seekNodeByName(expBar_db,"exp") 
        
        -- 新增动画
        winString = CSResourceMgr.getNodeByName(resName,{"board", "title_db", "winString"})
        star_db = CSResourceMgr.getNodeByName(resName,{"board", "title_db", "star_db"})
        winString:setVisible(false)
        star_db:setVisible(false)
        
        animateNodes = {
            scene, 
            title, coin_root, exp_root, expBar_db, gains_db, 
            coin_label, exp_label, LvLabel, ExpLabel,
            winString,star_db
        }
    end
    
    local function init()
        starNum = AdvStarMgr.getClearedStarNum()
        
        for _,v in pairs(SearchingMgr.awardsTbl) do
            if v.elementType == "g_cash" then gains_coin = gains_coin + v.num end
        end
        local aid = SearchingMapMgr.currAdventure
        local difficult = math.ceil(aid / 10000)
        if CharInfo.get()["advexp"..difficult] == 0 or aid > AdventureInfo.getHighestAdv(difficult) then
            gains_exp = advInfo.Exp_rewards
        else
            gains_exp = CharInfo.get()["advexp"..difficult]
        end
        
        CSResourceMgr.setLabelColorByNode(LvLabel,{r=255,g=252,b=0,a=255})
        CSResourceMgr.setLabelStringByNode(LvLabel,"Lv."..charLevel)
        LvLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        
        local Exp1 = _charInfo.exp - ExperienceInfo.getExperienceInfoByID(charLevel-1).roleExp
        local Exp2 = ExperienceInfo.getExperienceInfoByID(charLevel).roleExp - ExperienceInfo.getExperienceInfoByID(charLevel-1).roleExp
        CSResourceMgr.setLabelStringByNode(ExpLabel,Exp1.."/"..Exp2)
        ExpLabel:enableOutline({r=0,g=0,b=0,a=255}, 1)
        CSResourceMgr.seekNodeByName(expBar_db,"LoadingBar"):setPercent(100*Exp1/Exp2)
        
        -- CSResourceMgr.setLabelString(resName,{"board","gains_db","title_label"},"advtext16",tag,nil,nil,96) -- "获得物品"
        
        -- CSResourceMgr.setButtonString(resName, {"board", "share"}, "advtext3", tag)  -- "分享"
        CSResourceMgr.setButtonString(resName, {"board", "exit"},  "advtext4", tag, {r=0,g=0,b=0,a=255,w=1})  -- "退出"
    end
    
    local function playAction()
        local time = 0
        
        local scale1 = cc.ScaleTo:create(0.1,1.1)
        local scale2 = cc.ScaleTo:create(0.05,1.0)
        local move1 = cc.MoveBy:create(0.15,cc.p(0, 250+80))
        local move2 = cc.MoveBy:create(0.05,cc.p(0, -80))
        title:runAction(cc.Sequence:create(scale1,scale2,move1,move2))
        time = time + 0.35
        
        scene:performWithDelay(function()
--            flash1:setVisible(true)
--            flash2:setVisible(true)
--            local fade1 = cc.FadeTo:create(0.5, 128)
--            local fade2 = cc.FadeTo:create(0.6, 255)
--            local action = cc.RepeatForever:create(cc.Sequence:create(fade1, fade2))
--            flash1:runAction(action)

            local _resName = "Spine/effects/Ui_zhandoujiesuanguangxiao.png"
            local eff = AnimationMgr.createAni(title, _resName, 290, 147)
            AnimationMgr.playAni(_resName, "animation", true)
            eff:setLocalZOrder(-1) 
            
            local rate = 0.05
            local function action1()  -- winString animation
                winString:setVisible(true)
                winString:setScale(2.4)
                local scale1 = cc.ScaleTo:create(3*rate,0.8)
                local scale2 = cc.ScaleTo:create(2*rate,1.2)
                local scale3 = cc.ScaleTo:create(2*rate,1.0)
                winString:runAction(cc.Sequence:create(scale1,scale2,scale3))
            end
            local function action2()  -- star_db animation
                star_db:setVisible(true)
                star_db:setScale(2.0)
                local scale1 = cc.ScaleTo:create(3*rate,0.8)
                local scale2 = cc.ScaleTo:create(1*rate,1.0)
                star_db:runAction(cc.Sequence:create(scale1,scale2))
            end
            local action3 = {
                function()  -- action3_1
                    local _star = CSResourceMgr.seekNodeByName(star_db,"star1")
                    _star:setVisible(true)
                    local _x1, _y1 = 50, 46.5
                    local _x2, _y2 = _x1-145, _y1+16

                    _star:setPosition(_x2, _y2)

                    _star:setScale(4.5)
                    local scale1 = cc.ScaleTo:create(4*rate,0.9)
                    local scale2 = cc.ScaleTo:create(2*rate,1.1)
                    local scale3 = cc.ScaleTo:create(2*rate,1.0)
                    local move = cc.MoveBy:create(4*rate,cc.p(_x1-_x2,_y1-_y2))

                    _star:runAction(move)
                    _star:runAction(cc.Sequence:create(scale1,scale2,scale3))
                end,
                function()  -- action3_2
                    local _star = CSResourceMgr.seekNodeByName(star_db,"star3")
                    _star:setVisible(true)
                    local _x1, _y1 = 258, 46.5
                    local _x2, _y2 = _x1+145, _y1+16

                    _star:setPosition(_x2, _y2)

                    _star:setScale(4.5)
                    local scale1 = cc.ScaleTo:create(4*rate,0.9)
                    local scale2 = cc.ScaleTo:create(2*rate,1.1)
                    local scale3 = cc.ScaleTo:create(2*rate,1.0)
                    local move = cc.MoveBy:create(4*rate,cc.p(_x1-_x2,_y1-_y2))

                    _star:runAction(move)
                    _star:runAction(cc.Sequence:create(scale1,scale2,scale3))
                end,
                function()  -- action3_3
                    local _star = CSResourceMgr.seekNodeByName(star_db,"star2")
                    _star:setVisible(true)
                    local _x, _y = 154, 57

                    _star:setPosition(_x, _y)
                    _star:setScale(4.5)

                    local scale1 = cc.ScaleTo:create(4*rate,0.9)
                    local scale2 = cc.ScaleTo:create(2*rate,1.1)
                    local scale3 = cc.ScaleTo:create(2*rate,1.0)

                    _star:runAction(cc.Sequence:create(scale1,scale2,scale3))
                end,
            }

            action1()

            SceneMgr.getRunningScene:performWithDelay(function()
                action2()
            end,4*rate)
            
            for i=1, starNum do
                SceneMgr.getRunningScene:performWithDelay(function()
                    action3[i]()
                end,(8+7*(i-1))*rate)
            end
            
        end,time)
        
        time = time + 0.1
        
        scene:performWithDelay(function()
            coin_root:runAction(cc.MoveBy:create(0.1,cc.p(0, 100)))
            coin_root:runAction(cc.FadeTo:create(0.1, 255))
            exp_root:runAction(cc.MoveBy:create(0.1,cc.p(0, 100)))
            exp_root:runAction(cc.FadeTo:create(0.1, 255))
        end,time)
        
        time = time + 0.1
        
        scene:performWithDelay(function()
            -- 金币数字跳动
--            local coin_num = gains_coin
--            local duration = 100
--            local step = math.floor(coin_num/duration)
--            for i=0, duration do
--                local tmp = step*i
--                if i == duration then tmp = coin_num end
--                scene:performWithDelay(function()
--                    CSResourceMgr.setLabelStringByNode(coin_label,tmp)
--                end,0.01*i)
--            end
            CSResourceMgr.setLabelStringByNode(coin_label,gains_coin)
            
            -- 经验数字跳动
--            local exp_num = gains_exp
--            local duration = 100
--            local step = math.floor(exp_num/duration)
--            for i=0, duration do
--                local tmp = step*i
--                if i == duration then tmp = exp_num end
--                scene:performWithDelay(function()
--                    CSResourceMgr.setLabelStringByNode(exp_label,tmp)
--                end,0.01*i)
--            end
            CSResourceMgr.setLabelStringByNode(exp_label,gains_exp)
        
            local move = cc.MoveBy:create(0.1,cc.p(0, 100))
            local fade = cc.FadeTo:create(0.1, 255)
            expBar_db:runAction(move)
            expBar_db:runAction(fade)
        end,time)
        
        time = time + 0.15
        
        -- 经验条效果
        local function expEffect(node, expAdded)
            local loadingBar = CSResourceMgr.seekNodeByName(node,"LoadingBar")
            local lvLabel = CSResourceMgr.seekNodeByName(node,"lvLabel")
            local expLabel = CSResourceMgr.seekNodeByName(node,"exp")

            local duration = 100
            local step = math.floor(expAdded/duration)
            if step == 0 then step = 1 end
            for i=0, duration do
                if _charInfo.exp >= CHAR_MAX_EXP then break end
                
                local currExp = _charInfo.exp + step*i
                if i == duration then
                    currExp = _charInfo.exp + expAdded
                end
                if i > expAdded then -- fix小经验bug
                    break
                end
                
                local level = getLevelWithExp(currExp)

                node:performWithDelay(function()
                    local needExp = ExperienceInfo.getExperienceInfoByID(level).roleExp - ExperienceInfo.getExperienceInfoByID(level-1).roleExp
                    local littleExp = currExp - ExperienceInfo.getExperienceInfoByID(level-1).roleExp
                    local percent = 100*littleExp/needExp
                    CSResourceMgr.setLabelStringByNode(lvLabel,"Lv."..level)
                    CSResourceMgr.setLabelStringByNode(expLabel,littleExp.."/"..needExp)
                    loadingBar:setPercent(percent)
                end,0.01*i)
            end
        end

        local itemNum = 0
        local itemsNode = {}
        local itemOriginalY = 65
        local x, y = 310, itemOriginalY  --item 起始位置
        local gap  = 62

        --获得道具/宠物效果
        local function addItem(parent,itemInfo,item_num)
            -- num = num or 1
            local movetime = 0.1
            if itemNum > 0 and itemNum < 6 then
                x, y = itemsNode[itemNum]:getPosition()
                x = x + gap
                for i=1, itemNum do
                    transition.moveBy(itemsNode[i], {x=-gap, y=0, time=movetime})
                end
            end

            parent:performWithDelay(function()
                itemNum = itemNum + 1
                local item = ItemInfo.getItemIconById(itemInfo.id, item_num)  -- CSResourceMgr.getNodeByName(resName,"slot"):clone()
                item:setScale(110 / item:getContentSize().width)
                
                parent:addChild(item)

--                if item_num > 1 then
--                    local item_n = CSResourceMgr.seekNodeByName(item,"item_n")
--                    CSResourceMgr.setLabelStringByNode(item_n, item_num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
--                end
--                
--                local dbTexture = ItemInfo.getItemRareBGImage(itemInfo.id)
--                item:loadTexture(dbTexture)  -- 设置item品阶底板
--                local iconPath = itemInfo.icon
--                local icon = CSResourceMgr.seekNodeByName(item,"itemIcon")
--                CSResourceMgr.setButtonTextureByNode(icon, iconPath, iconPath, iconPath)
--                icon:setScale(0, 0)
--                icon:setRotation(180)
--                transition.scaleTo(icon, {scale = 1, time = 0.2})
--                transition.rotateTo(icon, {rotate = 360, time = 0.2})
                
                item:performWithDelay(function()
                    CSResourceMgr.buttonEventBindingByNode(item,function()
                        local info = {id = itemInfo.id, sum = item_num, type = 2}
                        ItemInfoViewMgr.show(info, false)
                        listMoveFlag = false
                    end,function()
                        ItemInfoViewMgr.hide()
                    end,function()
                        --if not listMoveFlag then
                        --    ItemInfoViewMgr.hide()
                        --    listMoveFlag = true
                        --end
                    end,function()
                        ItemInfoViewMgr.hide()
                    end)
                end,0.2)

                item:setPosition(x, y)
                table.insert(itemsNode,item)
            end,movetime)
        end
        
        local function itemEffect()
            local list = CSResourceMgr.getNodeByName(resName,{"board","gains_db","listView"},tag)
        
            local MaxRank = 5
            local panelTable = {}
            local itemFuncTable = {}
            local items = packItems()
            for i=1, #items do
                local row = math.ceil(i/MaxRank)
                local _rank = i % MaxRank
                if _rank == 0 then _rank = MaxRank end
                if _rank == 1 then
                    local panel = CSResourceMgr.getNodeByName(resName,"panel",tag):clone()
                    table.insert(panelTable,panel)
                    list:pushBackCustomItem(panel)
                end
                
                if i <= MaxRank then
                    local itemFunc = function()
                        local adward = items[i]
                        local itemInfo = ItemInfo.getItemInfoById(adward.elementID)
                        addItem(panelTable[row],itemInfo,adward.num)
                    end
                    table.insert(itemFuncTable,itemFunc)
                else
                    local adward = items[i]
                    local itemInfo = ItemInfo.getItemInfoById(adward.elementID)
                    
                    local parent = panelTable[row]
                    local item = ItemInfo.getItemIconById(itemInfo.id, adward.num)  -- CSResourceMgr.getNodeByName(resName,"slot"):clone()
                    item:setScale(110 / item:getContentSize().width)
                    parent:addChild(item)
                    
--                    local iconPath = itemInfo.icon
--                    local icon = CSResourceMgr.seekNodeByName(item,"itemIcon")
--                    CSResourceMgr.setButtonTextureByNode(icon, iconPath, iconPath, iconPath)
                    item:performWithDelay(function()
                        CSResourceMgr.buttonEventBindingByNode(item,function()
                            local info = {id = itemInfo.id, sum = adward.num, type = 2}
                            ItemInfoViewMgr.show(info, false)
                            listMoveFlag = false
                        end,function()
                            ItemInfoViewMgr.hide()
                        end,function()
                            --if not listMoveFlag then
                            --    ItemInfoViewMgr.hide()
                            --    listMoveFlag = true
                            --end
                        end,function()
                            ItemInfoViewMgr.hide()
                        end)
                    end,0.2)
                    
--                    if adward.num > 1 then
--                        local item_n = CSResourceMgr.seekNodeByName(item,"item_n")
--                        CSResourceMgr.setLabelStringByNode(item_n, adward.num, CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
--                    end

                    item:setPosition(72+124*(_rank-1), itemOriginalY)
                end
            end
            if #items > MaxRank then
                local tipFunc = function()
                    list:scrollToPercentHorizontal(10,0.2,true)
                    list:performWithDelay(function()
                        list:scrollToPercentHorizontal(0,0.2,true)
                    end,0.2)
                end
                table.insert(itemFuncTable,tipFunc)
            end
            UnblockLoader.load(itemFuncTable,"",0.2)
        end
        
        scene:performWithDelay(function()
            expEffect(expBar_db, gains_exp)
            
            local fade = cc.FadeTo:create(0.25, 255)
            gains_db:runAction(fade)
        end,time)
        
        -- 道具动画不取消
        local list = CSResourceMgr.getNodeByName(resName,{"board","gains_db","listView"},tag)
        list:performWithDelay(function()
            itemEffect()
        end,time)
        
        time = time + 0.25
        
        print(time)
    end
    
    local function bindEvent()
--        CSResourceMgr.clickEventBinding(resName,{"board","share"},function()
--            local list = CSResourceMgr.getNodeByName(resName,{"board","gains_db","listView"},tag)
--            list:scrollToPercentHorizontal(10,0.2,true)
--            list:performWithDelay(function()
--                list:scrollToPercentHorizontal(0,0.2,true)
--            end,0.2)
--        end,tag)
        
        CSResourceMgr.clickEventBinding(resName,{"board","exit"},function()
            AdvCharMgr.resetTrainers()
            
            SearchingMgr.closeAdventure()
            
            for i=1, #animateNodes do transition.stopTarget(animateNodes[i]) end
            AdvClearView.hide()
            
            SearchingMgr.UN_SCH_GLOBAL_CHECK()
            if SearchingMapMgr.firstAdventure then
                SearchingMapMgr.firstAdventure = false
                --if SearchingMapMgr.guideCallback ~= nil then
                --    SearchingMapMgr.guideCallback()
                --    SearchingMapMgr.guideCallback = nil
                --end
                --SceneMgr.replaceScene(scene, "MainScene")
            else
                --SceneMgr.replaceScene(scene, "MainScene")
            end

            if SearchingMapMgr.guideCallback ~= nil then
                SearchingMapMgr.guideCallback()
                SearchingMapMgr.guideCallback = nil
                SceneMgr.replaceScene(scene, "MainScene")
            else
                SceneMgr.replaceScene(scene, "MainScene")
            end
            
        end,tag)
        
        local firstFlag = false
        CSResourceMgr.clickEventBinding(resName,"block",function()
            if firstFlag then return end
        
            for i=1, #animateNodes do transition.stopTarget(animateNodes[i]) end
            
            title:setPositionY(890)
            title:setScale(1.0)
--            flash1:setVisible(true)
--            flash2:setVisible(true)
--            local fade1 = cc.FadeTo:create(0.5, 128)
--            local fade2 = cc.FadeTo:create(0.6, 255)
--            local action = cc.RepeatForever:create(cc.Sequence:create(fade1, fade2))
--            flash1:runAction(action)

            local _resName = "Spine/effects/Ui_zhandoujiesuanguangxiao.png"
            if not AnimationMgr.getGafObj(_resName) then
                local eff = AnimationMgr.createAni(title, _resName, 290, 147)
                AnimationMgr.playAni(_resName, "animation", true)
                eff:setLocalZOrder(-1)
            end
            
            winString:setScale(1.0)
            winString:setVisible(true)
            star_db:setScale(1.0)
            star_db:setVisible(true)
            local _star = {1,3,2}
            for i=1, starNum do
                CSResourceMgr.seekNodeByName(star_db,"star".._star[i]):setVisible(true)
            end
            
            coin_root:setPositionY(677)
            exp_root:setPositionY(605)
            coin_root:setOpacity(255)
            exp_root:setOpacity(255)
            CSResourceMgr.setLabelStringByNode(coin_label,gains_coin)
            CSResourceMgr.setLabelStringByNode(exp_label,gains_exp)
            
            expBar_db:setPositionY(510)
            expBar_db:setOpacity(255)
            
            local _level = getLevelWithExp(_charInfo.exp + gains_exp)
            local Exp1 = _charInfo.exp + gains_exp - ExperienceInfo.getExperienceInfoByID(_level-1).roleExp
            local Exp2 = ExperienceInfo.getExperienceInfoByID(_level).roleExp - ExperienceInfo.getExperienceInfoByID(_level-1).roleExp
            CSResourceMgr.setLabelStringByNode(LvLabel,"Lv.".._level)
            CSResourceMgr.setLabelStringByNode(ExpLabel,Exp1.."/"..Exp2)
            CSResourceMgr.seekNodeByName(expBar_db,"LoadingBar"):setPercent(100*Exp1/Exp2)
            
            gains_db:setOpacity(255)
        end,tag)
    end
    
    local funcTable = { playSound, loadBG, loadCSB, init, playAction, bindEvent, }

    UnblockLoader.load(funcTable,"AdvClearView")

--    for i=1, #funcTable do funcTable[i]() end
end

function AdvClearView.hide()
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end


return AdvClearView