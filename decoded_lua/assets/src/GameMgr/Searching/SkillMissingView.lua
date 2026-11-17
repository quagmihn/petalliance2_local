local SkillMissingView = {}

local resName = "Searching/Other/SkillMissingView.csb"
local tag = ""

local Layer

function SkillMissingView.show(scene, skillID)
    GameAudio.playUISound("ok")

    scene = scene or SceneMgr.getRunningScene
    skillID = skillID
    
    local skillInfo = PokemonInfo.getPetSkillInfoById(skillID)
    
    local HandbookCInfoReader = TxtReader.new("Config/HandbookC.txt")
    HandbookCInfoReader.init({"id", "name", "attr", "type", "class", "rarePoint", "itemId", "icon", "hitMin", "hitMax", "powerMin", "powerMax", "desc", "ownPet", "mapSkill", "energy"}, 1)
    local mapSkillInfoReader = TxtReader.new("Config/MapSkill.txt")
    mapSkillInfoReader.init({"id","HandBookID","desc"},1)
    
    local mapskillInfo = mapSkillInfoReader.get(skillID)

    local function loadCSB()
        Layer = CSResourceMgr.createRes(scene,resName,tag)
        CSResourceMgr.setRelativePosition(resName, 320, 480)
        Layer:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        
        CSResourceMgr.getNodeByName(resName,"db1",tag):setVisible(false)
        
        -- title
        CSResourceMgr.setLabelColor(resName,{"db1","title"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","title"},"advtext10","",{r=38,g=54,b=76,a=255})
        
        -- skill name
        local skillName_color = ItemInfo.COLOR[skillInfo.airpower]
        CSResourceMgr.setLabelColor(resName,{"db1","db2","skillName"},skillName_color)
        CSResourceMgr.setLabelString(resName,{"db1","db2","skillName"},skillInfo.name,"",{r=0,g=0,b=0,a=255})
        
        -- skill icon
        local iconTexture = PokemonInfo.getSkillIcon(skillID)
        CSResourceMgr.getNodeByName(resName,{"db1","db2","skill_button","icon"},tag):loadTexture(iconTexture)
        
        -- tip1
        CSResourceMgr.setLabelColor(resName,{"db1","db2","tip1"},{r=143,g=176,b=217,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","db2","tip1"},"advtext11","",{r=18,g=33,b=45,a=255})
        --阿杜修改英文版显示
        CSResourceMgr.setLabelMaxWidth(resName, {"db1","db2","tip1"}, 300)
        
        -- tip2
        CSResourceMgr.setLabelColor(resName,{"db1","db2","tip2_t"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","db2","tip2_t"},"advtext12","",{r=38,g=54,b=76,a=255},nil,66)
        CSResourceMgr.setLabelColor(resName,{"db1","db2","tip2"},{r=217,g=234,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","db2","tip2"},mapskillInfo.desc,"",{r=0,g=0,b=0,a=255,w=1})
        
        -- tip3
        CSResourceMgr.setLabelColor(resName,{"db1","db2","tip3"},{r=144,g=238,b=255,a=255})
        CSResourceMgr.setLabelString(resName,{"db1","db2","tip3"},"advtext13","")
    end
    
    local function init()
        local handbookCInfo = HandbookCInfoReader.get(mapskillInfo.HandBookID)
        
        local pets = string.split(handbookCInfo.ownPet, ",")
        for i = 1, #pets do pets[i] = tonumber(pets[i]) end 
               
        SkillMissingView.resetPets(pets)
    end
    
    local function playAction()
        local node = CSResourceMgr.getNodeByName(resName,"db1",tag)
        node:setVisible(true)
        
        CocosModuleMgr.showUIAnimation(node,"down")
    end
    
    local function bindEvent()
        CSResourceMgr.clickEventBinding(resName,"block",function()
            SkillMissingView.hide()
        end,tag)
        
        CSResourceMgr.clickEventBinding(resName,{"db1","close"},function()
            SkillMissingView.hide()
        end,tag)
    end
    
    local funcTable = { loadCSB, init, playAction, bindEvent, }
    
    UnblockLoader.load(funcTable,"skillMissingView")
    
--    for i = 1, #funcTable do funcTable[i]() end
end

function SkillMissingView.hide()
    GameAudio.playUISound("back")
    CSResourceMgr.removeCSObjectByTag(resName,tag)
end

function SkillMissingView.resetPets(pokeIDs)
    local list = CSResourceMgr.getNodeByName(resName,{"db1","db2","listView"},tag)
    local sample = CSResourceMgr.getNodeByName(resName,"pdiban",tag)

    local function createPetNode(pokeID, tag)
        local node = sample:clone()
    
        local info = PokemonInfo.getPokemonInfoByID(pokeID)
        
        local iconTex = CSResourceMgr.seekNodeByName(node,"icon")
        iconTex:loadTexture(PokemonInfo.getPokemonIconByID(pokeID))
        iconTex:setScale(0.78)
        
        local rareRes = PokemonInfo.getStagePics(nil,info.elementAtt1, info.rarePoint)
        
        CSResourceMgr.setButtonTextureByNode(node,rareRes.p1,rareRes.p1,rareRes.p1)
        local attrdbTex = CSResourceMgr.seekNodeByName(node,"attrdb")
        attrdbTex:loadTexture(rareRes.p2)
        local attriTex = CSResourceMgr.seekNodeByName(node,"attri")
        local attriinfo = tonumber(info.elementAtt1)
        attriTex:loadTexture("Pet/AttriIcon/"..attriinfo..".png")

        local rareiTex = CSResourceMgr.seekNodeByName(node,"rarei")
        rareiTex:loadTexture(PetEducationMgr.getRareIcon(info.rarePoint))
        rareiTex:setScale(0.48)
        
        return node
    end
    
    for i=1, #pokeIDs do 
        list:performWithDelay(function()
            local p = createPetNode(pokeIDs[i],"skillMissingPage_pet"..i)
            list:pushBackCustomItem(p)
        end,0.05*(i-1))
    end
end

return SkillMissingView