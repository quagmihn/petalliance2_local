local PetSkillIconMgr = {}
local resName = "Pet/Education/SkillIcon.csb"
PetSkillIconMgr.skillLvIconTable = {
    "UI/CommonFiles/develop_effect_icon_lv1.png",
    "UI/CommonFiles/develop_effect_icon_lv2.png",
    "UI/CommonFiles/develop_effect_icon_lv3.png",
    "UI/CommonFiles/develop_effect_icon_lv4.png",
    "UI/CommonFiles/develop_effect_icon_lv5.png",
}
PetSkillIconMgr.skillBackGroundPath = {
    "Battle/downEdge_A/fight_skill_base_02.png",    --0主动
    "Battle/downEdge_A/fight_skill_base_02.png",    --1奥义
    "Battle/downEdge_A/fight_skill_base_02.png",    --2特性
    "Battle/downEdge_A/fight_skill_base_02.png",    --3物理
    "Battle/downEdge_A/fight_skill_base_02.png",    --4魔法
    "Battle/downEdge_A/fight_skill_base_02.png",    --5变化
    "Battle/downEdge_A/fight_skill_base_02.png",    --6被动
    "Battle/downEdge_A/fight_skill_base_02.png",    --7援助
    "Battle/downEdge_A/fight_skill_base_01.png",    --8天赋
}

PetSkillIconMgr.passiveSkillBackGroundPath = {
    "UI/CommonFiles/skill_passive_base_blue_01.png",
    "UI/CommonFiles/skill_passive_base_violet_01.png",
    "UI/CommonFiles/skill_passive_base_yellow_01.png",
    "UI/CommonFiles/skill_passive_base_nomal_01.png",
}

PetSkillIconMgr.aidSkillBackGroundPath = {
    "UI/CommonFiles/skill_aid_base_blue_01.png",
    "UI/CommonFiles/skill_aid_base_violet_01.png",
    "UI/CommonFiles/skill_aid_base_yellow_01.png",
    "UI/CommonFiles/skill_aid_base_orange_01.png",
    "UI/CommonFiles/skill_aid_base_nomal_01.png",
}

PetSkillIconMgr.skillRareBGPath = {
    "UI/CommonFiles/fight_skill_green.png",
    "UI/CommonFiles/fight_skill_blue.png",
    "UI/CommonFiles/fight_skill_purple.png",
    "UI/CommonFiles/fight_skill_yellow.png",
    "Battle/downEdge_A/skillStage/5.png",
    "Battle/downEdge_A/skillStage/6.png",
}

PetSkillIconMgr.irareString = {
    "Pet/Education/b.png",
    "Pet/Education/a.png",
    "Pet/Education/s.png",
    "Pet/Education/2s.png",
}

function PetSkillIconMgr.createPetSkillIcon(node, skillInfo, boxType)--boxType: 1.简易 2.详细
    if node then node:removeAllChildren() end
    if not boxType then boxType = 1 end

    local parent     = CSResourceMgr.createRes(nil, resName)
    local skillNodeA = CSResourceMgr.getNodeByName(resName, "skill1")
    local skillNodeB = CSResourceMgr.getNodeByName(resName, "skill2")
    local skillNodeC = CSResourceMgr.getNodeByName(resName, "skill3")
    local skillNodeD = CSResourceMgr.getNodeByName(resName, "skill4")

    local skillNode
    local skillType  = skillInfo.skill_A_Type
    if skillType == 1 then
        skillNode = skillNodeB:clone()
        if boxType == 1 then
            PetSkillIconMgr.setSimpleMaxSkill(skillNode, skillInfo)--技能信息，技能升级，技能替换界面用
        else
            PetSkillIconMgr.setMainPageMaxSkill(skillNode, skillInfo)
        end
    elseif skillType == 6 or skillType == 7 then
        if boxType == 1 then
            skillNode = skillNodeC:clone()
            PetSkillIconMgr.setSimplePaSkill(skillNode, skillInfo)
        else
            skillNode = skillNodeD:clone()
            PetSkillIconMgr.setPaSkill(skillNode, skillInfo)
        end
    else
        skillNode = skillNodeA:clone()
        if boxType == 1 then
            PetSkillIconMgr.setSimpleMainSkill(skillNode, skillInfo)
        else
            PetSkillIconMgr.setMainSkill(skillNode, skillInfo)
        end
    end

    skillNode:setVisible(true)
    skillNode:setPosition(0, 0)
    skillNode:removeFromParent()
    skillNode:addTo(node)
    
    return skillNode
end

--创建空白主动技能
function PetSkillIconMgr.createPetSkillIconEmpty(node)
    if node then node:removeAllChildren() end
    local parent     = CSResourceMgr.createRes(nil, resName)
    local skillNode = CSResourceMgr.getNodeByName(resName, "skill1"):clone()
    local skillLv = CSResourceMgr.seekNodeByName(skillNode, "skill_lv")
    local skillAttr = CSResourceMgr.seekNodeByName(skillNode, "att_bg")
    local skillType = CSResourceMgr.seekNodeByName(skillNode, "skill_type_bg")
    local skillCostBG = CSResourceMgr.seekNodeByName(skillNode, "skill_cost_bg")
    local skillCost = CSResourceMgr.seekNodeByName(skillNode, "skill_cost")

    skillNode:setVisible(true)
    skillLv:setVisible(false)
    skillAttr:setVisible(false)
    skillType:setVisible(false)
    skillCostBG:setVisible(false)
    skillCost:setVisible(false)

    skillNode:setPosition(0, 0)
    skillNode:removeFromParent()
    skillNode:addTo(node)

    local spriteRare = PetSkillIconMgr.skillBackGroundPath[1]
    CSResourceMgr.setButtonTextureByNode(skillNode, spriteRare, spriteRare, spriteRare)
    
    return skillNode
end

--详细被动技能样式(底框+Icon)
function PetSkillIconMgr.setPaSkill(skillNode, skillInfo)
    local spriteIocn = CSResourceMgr.seekNodeByName(skillNode, "skill_icon")
    local spriteType = CSResourceMgr.seekNodeByName(skillNode, "skill_type")
    local spriteAttr = CSResourceMgr.seekNodeByName(skillNode, "att_icon")
    local spriteRare = CSResourceMgr.seekNodeByName(skillNode, "skill_rare")

    local skillType = skillInfo.skill_A_Type
    local skillRare = skillInfo.airpower or 5
    local spriteBG = skillType == 6 and PetSkillIconMgr.passiveSkillBackGroundPath[skillRare - 1] or 
                                        PetSkillIconMgr.aidSkillBackGroundPath[skillRare - 1]
    local typeIcon = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon

    local skillIcon = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    CSResourceMgr.setButtonTextureByNode(skillNode, spriteBG, spriteBG, spriteBG)
    CSResourceMgr.setSpriteTextureByNode(spriteIocn, skillIcon)
    CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
    CSResourceMgr.setSpriteTextureByNode(spriteAttr, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
    CSResourceMgr.setSpriteTextureByNode(spriteRare, PetSkillIconMgr.irareString[skillInfo.airpower])
    
    spriteAttr:setScale(0.55)
    spriteRare:setScale(0.5)
    spriteIocn:setPositionX(skillType == 6 and 54 or 58)
    spriteIocn:setPositionY(skillType == 6 and 56 or 58)
end

--简易被动技能样式(底框+Icon)
function PetSkillIconMgr.setSimplePaSkill(skillNode, skillInfo)
    local spriteIocn = CSResourceMgr.seekNodeByName(skillNode, "skill_icon")
    local skillType = skillInfo.skill_A_Type
    local skillRare = skillInfo.airpower or 5
    local spriteBG = skillType == 6 and PetSkillIconMgr.passiveSkillBackGroundPath[skillRare - 1] or 
                                        PetSkillIconMgr.aidSkillBackGroundPath[skillRare - 1]
    local skillIcon = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    CSResourceMgr.setButtonTextureByNode(skillNode, spriteBG, spriteBG, spriteBG)
    CSResourceMgr.setSpriteTextureByNode(spriteIocn, skillIcon)
    spriteIocn:setPositionX(skillType == 6 and 54 or 58)
    spriteIocn:setPositionY(skillType == 6 and 56 or 58)
end

--详细主动技能样式(底框+Icon+等级+消耗+属性+类型)
function PetSkillIconMgr.setMainSkill(skillNode, skillInfo)
    local spriteIcon    = CSResourceMgr.seekNodeByName(skillNode, "skill_icon")
    local spriteLv      = CSResourceMgr.seekNodeByName(skillNode, "skill_lv")
    local spriteAttBG   = CSResourceMgr.seekNodeByName(skillNode, "att_bg")
    local spriteType    = CSResourceMgr.seekNodeByName(skillNode, "skill_type")
    local labelCost     = CSResourceMgr.seekNodeByName(skillNode, "skill_cost")
    local labelCostBG   = CSResourceMgr.seekNodeByName(skillNode, "skill_cost_bg")
    local spriteAdd     = CSResourceMgr.seekNodeByName(skillNode, "skill_add")
    local spriteBG      = CSResourceMgr.seekNodeByName(skillNode, "skill_bg")

    local skillIcon     = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    local skillLevel    = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
    local skillCost     = skillInfo.energy
    local skillType     = skillInfo.skill_A_Type
    local skillRare     = skillInfo.airpower
    local skillBG       = PetSkillIconMgr.skillBackGroundPath[skillType+1]
    local typeIcon      = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon

    spriteAttBG:setScale(0.5)

    if skillCost == 0 then
        labelCost:setVisible(false)
        labelCostBG:setVisible(false)
    end

    spriteIcon:setScale(1.14)
    spriteAdd:setVisible(false)

    local spriteRare = PetSkillIconMgr.skillRareBGPath[skillRare]

    CSResourceMgr.setButtonTextureByNode(skillNode, spriteRare, spriteRare, spriteRare)
    CSResourceMgr.setSpriteTextureByNode(spriteBG, skillBG)
    CSResourceMgr.setSpriteTextureByNode(spriteIcon, skillIcon)
    CSResourceMgr.setSpriteTextureByNode(spriteLv, PetSkillIconMgr.skillLvIconTable[skillLevel])
    CSResourceMgr.setSpriteTextureByNode(spriteAttBG, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
    CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
    CSResourceMgr.setLabelStringByNode(labelCost, skillCost, {r=0,g=0,b=0,a=255,w=1,s=1})
end

--简易主动技能样式(底框+Icon+消耗+类型)
function PetSkillIconMgr.setSimpleMainSkill(skillNode, skillInfo)
    local spriteIcon    = CSResourceMgr.seekNodeByName(skillNode, "skill_icon")
    local spriteLv      = CSResourceMgr.seekNodeByName(skillNode, "skill_lv")
    local spriteAttBG   = CSResourceMgr.seekNodeByName(skillNode, "att_bg")
    local spriteType    = CSResourceMgr.seekNodeByName(skillNode, "skill_type")
    local labelCost     = CSResourceMgr.seekNodeByName(skillNode, "skill_cost")
    local labelCostBG   = CSResourceMgr.seekNodeByName(skillNode, "skill_cost_bg")
    local spriteAdd     = CSResourceMgr.seekNodeByName(skillNode, "skill_add")
    local spriteBG      = CSResourceMgr.seekNodeByName(skillNode, "skill_bg")

    local skillIcon     = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    local skillLevel    = (skillInfo.id % 5 == 0) and 5 or skillInfo.id % 5
    local skillCost     = skillInfo.energy
    local skillType     = skillInfo.skill_A_Type
    local skillRare     = skillInfo.airpower
    local skillBG       = PetSkillIconMgr.skillBackGroundPath[skillType+1]
    local typeIcon      = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon

    if skillCost == 0 then
        labelCost:setVisible(false)
        labelCostBG:setVisible(false)
    end

    spriteLv:setVisible(false)
    spriteAttBG:setVisible(false)
    spriteIcon:setScale(1.14)
    spriteAdd:setVisible(false)

    local spriteRare = PetSkillIconMgr.skillRareBGPath[skillRare]

    CSResourceMgr.setButtonTextureByNode(skillNode, spriteRare, spriteRare, spriteRare)
    CSResourceMgr.setSpriteTextureByNode(spriteBG, skillBG)
    CSResourceMgr.setSpriteTextureByNode(spriteIcon, skillIcon)
    CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
    CSResourceMgr.setLabelStringByNode(labelCost, skillCost, {r=0,g=0,b=0,a=255,w=1,s=1})
end

--主页奥义技能样式
function PetSkillIconMgr.setMainPageMaxSkill(skillNode, skillInfo)
    local node1         = CSResourceMgr.seekNodeByName(skillNode, "icon_node")
    local node2         = CSResourceMgr.seekNodeByName(skillNode, "energy_node")
    local spriteIcon    = CSResourceMgr.seekNodeByName(node1, "skill_icon")
    local spriteAttBG   = CSResourceMgr.seekNodeByName(node1, "att_bg")
    local sprite_add    = CSResourceMgr.seekNodeByName(node1, "skill_add")

    node1:setVisible(true)
    node2:setVisible(false)

    local bgPath = "UI/CommonFiles/profound_meaning_skill_base.png"
    CSResourceMgr.setButtonTextureByNode(skillNode, bgPath, bgPath, bgPath)

    if not skillInfo.id then
        spriteIcon:setVisible(false)
        spriteAttBG:setVisible(false)
    else
        spriteIcon:setScale(1.45)
        spriteAttBG:setScale(0.5)
        sprite_add:setVisible(false)
        
        local skillIcon = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
        CSResourceMgr.setSpriteTextureByNode(spriteIcon, skillIcon)
        CSResourceMgr.setSpriteTextureByNode(spriteAttBG, "UI/CommonFiles/"..skillInfo.skillAtt..".png")
    end
end

function PetSkillIconMgr.setSimpleMaxSkill(skillNode, skillInfo)
    local node1         = CSResourceMgr.seekNodeByName(skillNode, "icon_node")
    local node2         = CSResourceMgr.seekNodeByName(skillNode, "energy_node")
    local spriteIcon    = CSResourceMgr.seekNodeByName(node2, "skill_icon")
    local energy        = CSResourceMgr.seekNodeByName(node2, "energy")
    local typeBG        = CSResourceMgr.seekNodeByName(node2, "skill_type_bg")
    local spriteType    = CSResourceMgr.seekNodeByName(typeBG, "skill_type")

    node1:setVisible(false)
    node2:setVisible(true)
    -- spriteIcon:setScale(1.45)

    local typeIcon = PokemonInfo.getSkillPlayById(skillInfo.id).typeIcon

    local skillIcon = skillInfo.icon and "Battle/skillIcon/"..skillInfo.icon..".png" or "empty.png"
    local bgPath = "UI/CommonFiles/esoteric_skill_base_011.png"
    CSResourceMgr.setButtonTextureByNode(skillNode, bgPath, bgPath, bgPath)
    CSResourceMgr.setSpriteTextureByNode(energy, PetEducationMgr.maxSkillEnergyPath[skillInfo.energy])
    CSResourceMgr.setSpriteTextureByNode(spriteIcon, skillIcon)
    CSResourceMgr.setSpriteTextureByNode(spriteType, typeIcon)
end

return PetSkillIconMgr