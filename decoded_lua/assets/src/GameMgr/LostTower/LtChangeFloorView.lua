local LtChangeFloorView = {}

local resName = "LostTower/Others/ChangeFloorView.csb"

local cunsumeID  = 0
local consumeNum = 0
LtChangeFloorView.recoverCount = 0

function LtChangeFloorView.Init()
    cunsumeID  = 0
    consumeNum = 0
    LtChangeFloorView.recoverCount = 0
end

function LtChangeFloorView.show(scene, floor, okCallback, cancelCallback,type)
    UIStack.push("LtChangeFloorView",LtChangeFloorView.hide)
    GameAudio.playUISound("popup")
    
    type = type or 1
    
    local db

    local function loadCSB()
        local layer = CSResourceMgr.createRes(scene,resName)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        db = CSResourceMgr.getNodeByName(resName,"db1")
        db:setVisible(false)

        -- title
        CSResourceMgr.setLabelColor(resName,{"db1","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","title"},"LtText71","",{r=38,g=54,b=76,a=255})  -- "友情提示"

        -- tip1
        CSResourceMgr.setLabelColor(resName,{"db1","tip1"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","tip1"},"LtText72","",nil)  -- "下一层宠物出现一览"
        
        -- tip2
        CSResourceMgr.setLabelColor(resName,{"db1","tip2"},{r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","tip2"},"LtText73","",{r=0,g=0,b=0,a=255,w=1})  -- "是否进入下一层？"

        CSResourceMgr.setButtonString(resName,{"db1","cancel"},"LtNo","",{r=0,g=0,b=0,a=255,w=1})  -- 取消
        CSResourceMgr.setButtonString(resName,{"db1","ok"},"LtYes","",{r=0,g=0,b=0,a=255,w=1})   -- 确定
        
        if type == 2 then
            db:loadTexture("empty.png")
            CSResourceMgr.getNodeByName(resName,{"db1","title"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName,{"db1","cancel"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName,{"db1","ok"}):setVisible(false)
            CSResourceMgr.getNodeByName(resName,{"db1","tip2"}):setVisible(false)
            CSResourceMgr.setLabelString(resName,{"db1","tip1"},CocosModuleMgr.createStringWithFormat({"LtText74", floor}),"",nil)  -- "第<1>层可能出现以下宠物"
            CSResourceMgr.clickEventBinding(resName,"block",function()
                LtChangeFloorView.hide()
            end)
        end
    end

    local function playCSB()
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end

    local function init()
        local info = LostTowerInfo.getFloorRelationInfoById(floor) or {}
        local monster = info.monster
        if not monster then return end
        
        local eventList = LostTowerInfo.getEventListInfoById(monster)
        local parent = CSResourceMgr.getNodeByName(resName,{"db1","db2"})
        local MAX_COL = 4
        
        local pets = {}
        local funcTable = {}
        for k, v in pairs(eventList.eventList) do
            local monsterInfo = LostTowerInfo.getLostTowerMonsterInfoById(v.event) or {}
            local pokeID = monsterInfo.petnumber
            local pokeInfo = PokemonInfo.getPokemonInfoByID(pokeID)
            
            if pokeInfo then
                local petInfo = {}
                petInfo.pokeID    = pokeID
                petInfo.level     = 1
                petInfo.star      = 0
                petInfo.rarePoint = pokeInfo.rarePoint
                
                table.insert(pets,petInfo)
            end
            if #pets >= 8 then break end
        end
        
        -- 按照宠物稀有度排序
        table.sort(pets,function(p1, p2)
            return p1.rarePoint > p2.rarePoint
        end)
        
        local max_pet_num = (#pets > 8) and 8 or #pets
        for k = 1, max_pet_num do
            local function itemFunc()
                local petInfo = pets[k]

                local col = (k % MAX_COL) == 0 and MAX_COL or (k % MAX_COL) 
                local row = math.ceil(k / MAX_COL)
                local returnObjectArray = ObjectPool.getObjectFromPool("PetListUI", 1)
                local object = returnObjectArray[1]
                local p = BattleFuncMgr.createPetCardWithObjectPool(object, petInfo, 3)
                p.level:setVisible(false)
                parent:addChild(p.button)
                p.button:setScale(100 / p.button:getContentSize().width)
                p.button:setPosition(100 + 120*(col - 1), 285 - 135*(row - 1))

                CSResourceMgr.clickEventBindingByNode(p.button,function()
                    PetInfoViewMgr.show(SceneMgr.getRunningScene, petInfo.pokeID)
                    local btn = CSResourceMgr.getNodeByName("Pet/PetInfoDownBar.csb","get")
                    if btn then btn:setVisible(false) end
                end)

                table.insert(pets,petInfo)
            end
            table.insert(funcTable, itemFunc)
        end
        
--        table.insert(funcTable, function()
--            BattleFuncMgr.endCreatePetCard()
--        end)
        
        -- UnblockLoader.load(funcTable,"LtChangeFloorView-initPets")
        for i = 1, #funcTable do funcTable[i]() end
    end

    local function buttonBinding()
        CSResourceMgr.clickEventBinding(resName,{"db1","cancel"},function()
            if cancelCallback then cancelCallback() end
            LtChangeFloorView.hide()
        end)

        CSResourceMgr.clickEventBinding(resName,{"db1","ok"},function()
            if okCallback then okCallback() end
            LtChangeFloorView.hide()
        end)

    end

    local funcTable = {loadCSB, playCSB, init, buttonBinding}

    UnblockLoader.load(funcTable,"LtChangeFloorView")

--    for i=1,#funcTable do
--        funcTable[i]()
--    end

end

function LtChangeFloorView.hide()
    UIStack.pop("LtChangeFloorView")
    GameAudio.playUISound("retract")
    CSResourceMgr.removeCSObjectByTag(resName)

    ObjectPool.reset("PetListUI")
end

return LtChangeFloorView