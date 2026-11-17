local PetEquipInfo = {}

local petEquipInfoConfig = nil
local petEquipEffectInfoConfig = nil
local petEquipEffectSetInfoConfig = nil
local petEquipPurifyExpInfoConfig = nil
local petEquipPurifyInfoConfig = nil
local petEquipRestorePurifyInfoConfig = nil
local petEquipRestoreStrengthenInfoConfig = nil
local petEquipStrengthenInfoConfig = nil

function PetEquipInfo.Init()
    if petEquipInfoConfig==nil then
        petEquipInfoConfig = require("src.DatReader.PetEquipInfoConfig")
        petEquipInfoConfig.init()
    end
    
    if petEquipEffectInfoConfig==nil then
        petEquipEffectInfoConfig = require("src.DatReader.PetEquipEffectInfoConfig")
        petEquipEffectInfoConfig.init()
    end
    
    if petEquipEffectSetInfoConfig==nil then
        petEquipEffectSetInfoConfig = require("src.DatReader.PetEquipEffectSetInfoConfig")
        petEquipEffectSetInfoConfig.init()
    end
    
    if petEquipPurifyExpInfoConfig==nil then
        petEquipPurifyExpInfoConfig = require("src.DatReader.PetEquipPurifyExpInfoConfig")
        petEquipPurifyExpInfoConfig.init()
    end
    
    if petEquipPurifyInfoConfig==nil then
        petEquipPurifyInfoConfig = require("src.DatReader.PetEquipPurifyInfoConfig")
        petEquipPurifyInfoConfig.init()
    end
    
    if petEquipRestorePurifyInfoConfig==nil then
        petEquipRestorePurifyInfoConfig = require("src.DatReader.PetEquipRestorePurifyInfoConfig")
        petEquipRestorePurifyInfoConfig.init()
    end
    
    if petEquipRestoreStrengthenInfoConfig==nil then
        petEquipRestoreStrengthenInfoConfig = require("src.DatReader.PetEquipRestoreStrengthenInfoConfig")
        petEquipRestoreStrengthenInfoConfig.init()
    end
    
    if petEquipStrengthenInfoConfig==nil then
        petEquipStrengthenInfoConfig = require("src.DatReader.PetEquipStrengthenInfoConfig")
        petEquipStrengthenInfoConfig.init()
    end
    
    PetEquipInfo.ATTR_NUM = Proto.PEET_SPENETRATION
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.name=Proto.parseString(entry); -- 装备名称
data.icon=Proto.parseString(entry); -- 装备icon
data.pos=Proto.parseBYTE(entry); -- 装备部位
data.quality=Proto.parseBYTE(entry); -- 装备品质
data.elemAttrRange=Proto.parseVector(entry,Proto.parseDWORD); -- 装备系别范围
data.elemAttrNum=Proto.parseBYTE(entry); -- 装备系别数量
data.hpMax=Proto.parseDWORD(entry); -- 生命上限
data.hpMin=Proto.parseDWORD(entry); -- 生命下限
data.atkMax=Proto.parseDWORD(entry); -- 物攻上限
data.atkMin=Proto.parseDWORD(entry); -- 物攻下限
data.defMax=Proto.parseDWORD(entry); -- 物防上限
data.defMin=Proto.parseDWORD(entry); -- 物防下线
data.satkMax=Proto.parseDWORD(entry); -- 魔攻上限
data.satkMin=Proto.parseDWORD(entry); -- 魔攻下限
data.sdefMax=Proto.parseDWORD(entry); -- 魔防上限
data.sdefMin=Proto.parseDWORD(entry); -- 魔防下限
data.speedMax=Proto.parseDWORD(entry); -- 速度上限
data.speedMin=Proto.parseDWORD(entry); -- 速度下限
data.strengthenMax=Proto.parseBYTE(entry); -- 强化上限
data.purifyMax=Proto.parseBYTE(entry); -- 淬炼上限
data.effects=Proto.parseVector(entry,Proto.parseDWORD); -- 词条池组
]]
function PetEquipInfo.getPetEquipInfoById(id)
    return petEquipInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.name=Proto.parseString(entry); -- 名称
data.quality=Proto.parseBYTE(entry); -- 品级
data.type=Proto.parseBYTE(entry); -- 类型
data.valueMax=Proto.parseDWORD(entry); -- 值上限
data.valueMin=Proto.parseDWORD(entry); -- 值下限
]]
function PetEquipInfo.getPetEquipEffectInfoById(id)
    return petEquipEffectInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.wordPoolName=Proto.parseString(entry); -- 
data.effects=Proto.parseVector(entry,Proto.parseDWORDPair); -- 词条权重组
]]
function PetEquipInfo.getPetEquipEffectSetInfoById(id)
    return petEquipEffectSetInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 品级
data.exp=Proto.parseDWORD(entry); -- 经验
]]
function PetEquipInfo.getPetEquipPurifyExpInfoById(id)
    return petEquipPurifyExpInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 装备品级
data.expAndpercents=Proto.parseVector(entry,Proto.parseDWORDPair); -- 经验和淬炼效果组
]]
function PetEquipInfo.getPetEquipPurifyInfoById(id)
    return petEquipPurifyInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 淬炼石返还
]]
function PetEquipInfo.getPetEquipRestorePurifyInfoById(id)
    return petEquipRestorePurifyInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 
data.nums=Proto.parseVector(entry,Proto.parseDWORD); -- 强化石返还
]]
function PetEquipInfo.getPetEquipRestoreStrengthenInfoById(id)
    return petEquipRestoreStrengthenInfoConfig.readEntryByID(id)
end

--[[
data.id=Proto.parseDWORD(entry); -- 品级
data.infos=Proto.parseVector(entry,Proto.parsePetEquipStrengthenParam); -- 参数组
]]
function PetEquipInfo.getPetEquipStrengthenInfoById(id)
    return petEquipStrengthenInfoConfig.readEntryByID(id)
end

function PetEquipInfo.getEquipQualityBGImage(id)
    if not tonumber(id) then
        return "Item/ItemRare/0.png"
    end
    local quality = PetEquipInfo.getPetEquipInfoById(id).quality
    return "Item/ItemRare/"..quality..".png"
end

function PetEquipInfo.getPetEquip()
    local LoginSend = require("src.Net.Send.LoginSend")
    NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
        print("!!!!!!!!!!!!!!!getPetEquip---sendCG_GetCharacterValues_Req")
        LoginSend.sendCG_GetCharacterValues_Req({"petEquips"})
    end,function()
        PetEquipmentMgr.createAllPetEquipment()
    end, function(code)
        StandardTipsMgr.show(1,"getPetEquip failed code="..code)
    end, 60)
end

function PetEquipInfo.petEquipOn(petObjID, equipObjID, funcSuccess)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPON_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipOn---sendCG_PetEquipOn_Req", petObjID, equipObjID)
        PetEquipSend.sendCG_PetEquipOn_Req({petObjID = petObjID, equipObjID = equipObjID})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        if code==521 then
            StandardTipsMgr.show(1,"PetEquip52")
        else
            StandardTipsMgr.show(1,"petEquipOn failed code="..code)
        end
    end)
end

function PetEquipInfo.petEquipOff(petObjID, pos, funcSuccess)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPOFF_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipOff---sendCG_PetEquipOff_Req", petObjID, pos)
        PetEquipSend.sendCG_PetEquipOff_Req({petObjID = petObjID, pos = pos})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        StandardTipsMgr.show(1,"petEquipOff failed code="..code)
    end)
end

function PetEquipInfo.petEquipCompose(itemID)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPCOMPOSE_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipCompose---sendCG_PetEquipCompose_Req", itemID)
        PetEquipSend.sendCG_PetEquipCompose_Req({itemID = itemID})
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"petEquipCompose failed code="..code)
    end)
end

function PetEquipInfo.petEquipStrengthen(ObjID, pos, luckStoneID, funcSuccess, funcFail)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPSTRENGTHEN_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipStrengthen---sendCG_PetEquipStrengthen_Req", ObjID, pos, luckStoneID)
        PetEquipSend.sendCG_PetEquipStrengthen_Req({ObjID = ObjID, pos = pos, luckStoneID = luckStoneID})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        if funcFail then funcFail() end
        --StandardTipsMgr.show(1,"petEquipStrengthen failed code="..code)
        print("petEquipStrengthen failed code="..code)
    end)
end

function PetEquipInfo.petEquipBaptism(ObjID, pos, strengthenLevel)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPBAPTISM_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipBaptism---sendCG_PetEquipBaptism_Req", ObjID, pos, strengthenLevel)
        PetEquipSend.sendCG_PetEquipBaptism_Req({ObjID = ObjID, pos = pos, strengthenLevel = strengthenLevel})
    end,function()
    end, function(code)
        StandardTipsMgr.show(1,"petEquipBaptism failed code="..code)
    end)
end

function PetEquipInfo.petEquipPurify(ObjID, pos, purifyStoneNum, equips, funcSuccess)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPPURIFY_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipPurify---sendCG_PetEquipPurify_Req", ObjID, pos, purifyStoneNum, equips)
        PetEquipSend.sendCG_PetEquipPurify_Req({ObjID = ObjID, pos = pos, purifyStoneNum = purifyStoneNum, equips = equips})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        StandardTipsMgr.show(1,"petEquipPurify failed code="..code)
    end)
end

function PetEquipInfo.petEquipRestore(objID, pos, funcSuccess)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPRESTORE_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipRestore---sendCG_PetEquipRestore_Req", objID, pos)
        PetEquipSend.sendCG_PetEquipRestore_Req({objID = objID, pos = pos})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        StandardTipsMgr.show(1,"petEquipRestore failed code="..code)
    end)
end

function PetEquipInfo.petEquipAppraise(itemID, funcSuccess)
    local PetEquipSend = require("src.Net.Send.PetEquipSend")

    NetInterface.sendWithBlock("GC_PETEQUIPAPPRAISE_ACK", function()
        print("!!!!!!!!!!!!!!!petEquipAppraise---sendCG_PetEquipAppraise_Req", itemID)
        PetEquipSend.sendCG_PetEquipAppraise_Req({itemID = itemID})
    end,function()
        if funcSuccess then funcSuccess() end
    end, function(code)
        StandardTipsMgr.show(1,"petEquipAppraise failed code="..code)
    end)
end

return PetEquipInfo