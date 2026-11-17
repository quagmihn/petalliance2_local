--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local AwardSelectViewMgr = {}

local resNameAwardSelect = "Item/Purchase/awardsSelectView.csb"
local curSelAwardId = 0
local curSelFrame  = nil 

local trans_errorSelTips = "recharge33"

local function hideUI()
    CSResourceMgr.removeCSObjectByTag(resNameAwardSelect)
end

local function showPetInfos(petInfos)
    local index = 0
    local startx = 100
    local starty = 260
    local levelPath = {"c","b","a","s","2s","3s"}
    for k,v in pairs(petInfos) do
        local pokemonInfo = v
        local petbtn = CSResourceMgr.getNodeByName(resNameAwardSelect,"petBtn"):clone()
        petbtn:setVisible(true)
        CSResourceMgr.setButtonTextureByNode(petbtn,"Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png","Pet/BasicPetList_2/Stage/"..pokemonInfo.rarePoint..".png")
        local monsterIcon = CSResourceMgr.seekNodeByName(petbtn,"icon")
        monsterIcon:setScale(0.95,0.95)
        CSResourceMgr.setSpriteTextureByNode(monsterIcon, "Pet/PetIcon/"..pokemonInfo.icon..".png")
        local monsterAttr = CSResourceMgr.seekNodeByName(petbtn,"attrIcon")
        CSResourceMgr.setSpriteTextureByNode(monsterAttr, "Pet/AttriIcon/"..pokemonInfo.elementAtt1..".png")
        local monsterAttrBack = CSResourceMgr.seekNodeByName(petbtn,"attr")
        CSResourceMgr.setSpriteTextureByNode(monsterAttrBack, "Pet/AttriIcon/small_"..pokemonInfo.elementAtt1..".png")
        local monsterLevel = CSResourceMgr.seekNodeByName(petbtn,"rare")
        CSResourceMgr.setSpriteTextureByNode(monsterLevel, "Pet/Education/"..levelPath[pokemonInfo.rarePoint]..".png")
        local name = CSResourceMgr.seekNodeByName(petbtn, "name")
        CSResourceMgr.setLabelColorByNode(name, PokemonInfo.COLOR[pokemonInfo.rarePoint])
        CSResourceMgr.setLabelStringByNode(name, pokemonInfo.name, {r=62,g=46,b=6,a=255})

        local backgroundNode = CSResourceMgr.getNodeByName(resNameAwardSelect,"background")
        backgroundNode:addChild(petbtn)
        petbtn:setPosition(startx+index*128,starty)
        petbtn.awardid = k
        CSResourceMgr.clickEventBindingByNode(petbtn,function() 
            curSelAwardId = petbtn.awardid
            if curSelFrame ~= nil then 
                curSelFrame:setVisible(false)
            end
            curSelFrame = CSResourceMgr.seekNodeByName(petbtn,"sel")
            curSelFrame:setVisible(true)
        end,3)
        index = index+1
    end
end

--@param scene 当前场景
--@param petInfoTable 宠物信息数组表
--@param callback 点击确定按钮后的回调，用于传入
function AwardSelectViewMgr.show(scene,petInfos,callback)
    curSelAwardId = 0
    curSelFrame = nil
    UIStack.push("AwardSelectViewMgr",AwardSelectViewMgr.hide,false)
    if CSResourceMgr.getCsbObj(resNameAwardSelect) then
        return;
    end    

    local function loadCSB()
        local curLayer = CSResourceMgr.createRes(scene, resNameAwardSelect)
        curLayer:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CSResourceMgr.setRelativePosition(resNameAwardSelect, 320, 480)
        CSResourceMgr.getNodeByName(resNameAwardSelect, "background"):setVisible(false)   
        showPetInfos(petInfos)
        local okbtn  = CSResourceMgr.getNodeByName(resNameAwardSelect,"confirmBtn")
        CSResourceMgr.clickEventBindingByNode(okbtn,function()
            if curSelAwardId == 0 then 
                StandardTipsMgr.show(1, trans_errorSelTips)
            else
                if callback~=nil then 
                    callback(curSelAwardId)
                end
                AwardSelectViewMgr.hide()
            end
        end)

        local title  = CSResourceMgr.getNodeByName(resNameAwardSelect,"title")
        CSResourceMgr.setLabelStringByNode(title, "recharge32", {r=255,g=255,b=255})
        local titleS  = CSResourceMgr.getNodeByName(resNameAwardSelect,"titleS")
        CSResourceMgr.setLabelStringByNode(titleS, "recharge31", {r=255,g=255,b=255})

        local cancelbtn  = CSResourceMgr.getNodeByName(resNameAwardSelect,"cancelBtn")

        CSResourceMgr.clickEventBindingByNode(cancelbtn,function() 
            AwardSelectViewMgr.hide()
        end)
    end

    local function playCSB()
        GameAudio.playUISound("popup")
        local db = CSResourceMgr.getNodeByName(resNameAwardSelect, "background")
        db:setVisible(true)
        CocosModuleMgr.showUIAnimation(db, "down")
    end
    
    loadCSB()
    playCSB()
end


function AwardSelectViewMgr.hide()
	hideUI()
	UIStack.pop("AwardSelectViewMgr")
end

return AwardSelectViewMgr;



--endregion
