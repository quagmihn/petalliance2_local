local BattleInfo = {}

local SkillTemplateInfo = nil
local SkillInfo = nil
local SkillTagInfo = nil
local PotentialSkillInfo = nil
local ElementSkillInfoConfig = nil

function BattleInfo.Init() 
    if SkillTemplateInfo==nil then
        SkillTemplateInfo = require("src.DatReader.SkillTemplateInfoConfig")
        SkillTemplateInfo.init()    
    end
    if SkillInfo==nil then
        SkillInfo = require("src.DatReader.SkillInfoConfig")
        SkillInfo.init()
    end
    if SkillTagInfo==nil then
        SkillTagInfo = require("src.DatReader.SkillTagInfoConfig")
        SkillTagInfo.init()
    end
    if PotentialSkillInfo==nil then
        PotentialSkillInfo = require("src.DatReader.PotentialSkillInfoConfig")
        PotentialSkillInfo.init()
    end
    if ElementSkillInfoConfig == nil then
        ElementSkillInfoConfig = require("src.DatReader.ElementSkillInfoConfig")
        ElementSkillInfoConfig.init()
    end
end

function BattleInfo.getSkillInfoByIDRaw(id) 
    local skillInfo = SkillInfo.readEntryByID(id)
    return skillInfo
end

function BattleInfo.getSkillInfoByID(id) 
    local skillInfo = SkillInfo.readEntryByID(id)
    if skillInfo == nil then
        print(string.format("find skill%d failed",id))
        return nil
    end
    if skillInfo.tags and skillInfo.langType ~= LuaSqlite.LANG_TYPE then
        skillInfo.tags = nil
    end
    local level = id%10
    if skillInfo.tags == nil then
        skillInfo.tags = {}
        skillInfo.langType = LuaSqlite.LANG_TYPE
        skillInfo.des = {}
        local tagCount = 0
        for index =1,#skillInfo.skillTags do
            local tagLevel = skillInfo.skillTags[index].powers[level]
            if tagLevel > 0 then
                tagCount = tagCount + 1
                skillInfo.tags[tagCount] = {}
                skillInfo.tags[tagCount].instance = BattleInfo.getSkillTagInfoByID(skillInfo.skillTags[index].id)
                skillInfo.tags[tagCount].tagLevel = tagLevel
            end
        end

        for index =1,#skillInfo.tags do
            local tagLevel = skillInfo.tags[index].tagLevel
            local descs = ""
            for i=1,#skillInfo.tags[index].instance.templateDatas do
                local tagTemplateInfo = skillInfo.tags[index].instance.templateDatas[i]
                for j=1,#tagTemplateInfo.actions do
                    local Template = tagTemplateInfo.actions[j]:getTemplate()
                    tagTemplateInfo.actions[j].skillid = id
                    print("skillid---",id)
                    descs = Template:onGetSkillDesc(tagTemplateInfo.actions[j],tagLevel)
                    break
                end
                if descs ~= false then
                    break
                end
            end

            if descs == false then
                print(string.format("技能标签<%s>未实现技能描述",skillInfo.tags[index].instance.name))
                if nil ~= skillInfo.tags[index].instance.descs[1] then 
                    descs = LuaSqlite.getLanguageByKey(skillInfo.tags[index].instance.descs[1])
                end
            end
            skillInfo.des[skillInfo.tags[index].instance.id] = descs
        end
    end
    
    return skillInfo
end

function BattleInfo.getSkillTagInfoByID(id)
    local skillTagInfo = SkillTagInfo.readEntryByID(id)
    if skillTagInfo.templateDatas == nil then
        --skillTagInfo.name = LuaSqlite.getLanguageByKey(skillTagInfo.name)
        skillTagInfo.templateDatas = {}
        for index =1,#skillTagInfo.templates do
            local tagTemplateInfo = skillTagInfo.templates[index]
            skillTagInfo.templateDatas[index] = {}
            skillTagInfo.templateDatas[index].event = tagTemplateInfo.event
            skillTagInfo.templateDatas[index].conditions = {}
            skillTagInfo.templateDatas[index].actions = {}
            for _index = 1,#tagTemplateInfo.conditions do
                skillTagInfo.templateDatas[index].conditions[_index] = BattleTemplateData.new(skillTagInfo,skillTagInfo.templates[index].conditions[_index]) 
            end
            for _index = 1,#tagTemplateInfo.actions do
                skillTagInfo.templateDatas[index].actions[_index] = BattleTemplateData.new(skillTagInfo,skillTagInfo.templates[index].actions[_index]) 
            end
        end
    end
    return skillTagInfo
end

function BattleInfo.getTemplateInfoByID(id)
    local templateInfo = SkillTemplateInfo.readEntryByID(id)
    if templateInfo.instance == nil then
        templateInfo.instance = getBattleTemplateInstance(templateInfo)
    end
    return templateInfo
end

function BattleInfo.getPotentialSkillInfoById(id)
    return PotentialSkillInfo.readEntryByID(id)
end

function BattleInfo.getSkillAttributeByID(id)

    local skillInfo = BattleInfo.getSkillInfoByID(id)

    local attTable = {}
    for index =1,#skillInfo.tags do
        local tagLevel = skillInfo.tags[index].tagLevel
        local descs = ""
        for i=1,#skillInfo.tags[index].instance.templateDatas do
            local tagTemplateInfo = skillInfo.tags[index].instance.templateDatas[i]
            for j=1,#tagTemplateInfo.actions do
                local Template = tagTemplateInfo.actions[j]:getTemplate()
                tagTemplateInfo.actions[j].skillid = id
                local att = Template:onGetSkillAttribute(tagTemplateInfo.actions[j],tagLevel)
                if att then
                    table.insert(attTable,att)
                end
            end
        end
    end

    return attTable
end

function BattleInfo.getElementSkillInfoCount()
    return ElementSkillInfoConfig.getEntryCount()
end

function BattleInfo.getElementSkillInfo(idx)
    return ElementSkillInfoConfig.readEntry(idx)
end

function BattleInfo.getSkillAttAdjust(data, attAdjust, level)

    local skillid = data.skillid
    local skillInfo = BattleInfo.getSkillInfoByIDRaw(skillid)
    if skillInfo.adjustRate > 0 then
        if #skillInfo.triggerRates > 0 then
            local adp = 1
            if skillInfo.changeValue == "强度" then
                adp = 0.1*(5+skillid%10)
            end
            for i=1,#skillInfo.skillTags do
                if skillInfo.skillTags[i].id == data.ownerInfo.id then
                    level = skillInfo.skillTags[i].powers[5]
                    break
                end
            end
            attAdjust = math.floor(skillInfo.adjustRate*100*adp/skillInfo.triggerRates[5])/100
        else
            attAdjust = skillInfo.adjustRate/100
        end
    end

    return attAdjust, level

end

return BattleInfo