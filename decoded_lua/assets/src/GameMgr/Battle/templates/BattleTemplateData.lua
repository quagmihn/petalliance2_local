local BattleTemplateData = class("BattleTemplateData")

function BattleTemplateData:ctor(ownerInfo,templateData)
    --ownerInfo:skillTagInfo
    self.ownerInfo = ownerInfo
    self.templateData = templateData
    self.template = BattleInfo.getTemplateInfoByID(self.templateData.id).instance
end

function BattleTemplateData:getTemplate()
    return self.template
end

function BattleTemplateData:getParamValue(paramName,templateLevel)
    for i=1,#self.templateData.params do
        if self.templateData.params[i].name == paramName then
            if #self.templateData.params[i].datas == 1 then
                return self.templateData.params[i].datas[1]
            end
            return self.templateData.params[i].datas[templateLevel]
        end
    end
    return nil
end


return BattleTemplateData