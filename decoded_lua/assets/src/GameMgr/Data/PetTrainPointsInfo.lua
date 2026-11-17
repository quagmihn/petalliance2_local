local PetTrainPointsInfo = {}
local att_oNums = {}
local att_oIDS  = {}

function PetTrainPointsInfo.init()
    if not SystemInfo.getGlobalConfigAddInfoByID(70004) then
        return 
    end
    local hpValues = SystemInfo.getGlobalConfigAddInfoByID(70004).values 
    att_oNums[Proto.PEET_HP] = {}
    att_oIDS[Proto.PEET_HP] = {}
    for key,var in pairs(hpValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_HP][#att_oNums[Proto.PEET_HP]+1] = var 
        else
            att_oIDS[Proto.PEET_HP][#att_oIDS[Proto.PEET_HP]+1] = var
        end
    end

    local atkValues = SystemInfo.getGlobalConfigAddInfoByID(70007).values
    att_oNums[Proto.PEET_ATK] = {}
    att_oIDS[Proto.PEET_ATK] = {}
    for key,var in pairs(atkValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_ATK][#att_oNums[Proto.PEET_ATK]+1] = var 
        else
            att_oIDS[Proto.PEET_ATK][#att_oIDS[Proto.PEET_ATK]+1] = var
        end
    end

    local defValues = SystemInfo.getGlobalConfigAddInfoByID(70009).values
    att_oNums[Proto.PEET_DEF] = {}
    att_oIDS[Proto.PEET_DEF] = {}
    for key,var in pairs(defValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_DEF][#att_oNums[Proto.PEET_DEF]+1] = var 
        else
            att_oIDS[Proto.PEET_DEF][#att_oIDS[Proto.PEET_DEF]+1] = var
        end
    end

    local satkValues = SystemInfo.getGlobalConfigAddInfoByID(70006).values
    att_oNums[Proto.PEET_SATK] = {}
    att_oIDS[Proto.PEET_SATK] = {}

    for key,var in pairs(satkValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_SATK][#att_oNums[Proto.PEET_SATK]+1] = var 
        else
            att_oIDS[Proto.PEET_SATK][#att_oIDS[Proto.PEET_SATK]+1] = var
        end
    end

    local sdefValues = SystemInfo.getGlobalConfigAddInfoByID(70008).values
    att_oNums[Proto.PEET_SDEF] = {}
    att_oIDS[Proto.PEET_SDEF] = {}

    for key,var in pairs(sdefValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_SDEF][#att_oNums[Proto.PEET_SDEF]+1] = var 
        else
            att_oIDS[Proto.PEET_SDEF][#att_oIDS[Proto.PEET_SDEF]+1] = var
        end
    end

    local speedValues = SystemInfo.getGlobalConfigAddInfoByID(70005).values
    att_oNums[Proto.PEET_SPEED] = {}
    att_oIDS[Proto.PEET_SPEED]  = {}
    for key,var in pairs(speedValues) do
        if key%2 == 0 then
            att_oNums[Proto.PEET_SPEED][#att_oNums[Proto.PEET_SPEED]+1] = var 
        else
            att_oIDS[Proto.PEET_SPEED][#att_oIDS[Proto.PEET_SPEED]+1] = var
        end
    end

    local tattolValues = SystemInfo.getGlobalConfigAddInfoByID(70001).values 
    local tattolIndex  = #att_oNums + 1
    att_oNums[tattolIndex]  = {}
    att_oIDS[tattolIndex]   = {}
    for key,var in pairs(tattolValues) do
        if key%2 == 0 then
            att_oNums[tattolIndex][#att_oNums[tattolIndex]+1] = var 
        else
            att_oIDS[tattolIndex][#att_oIDS[tattolIndex]+1] = var
        end
    end
    
end

--返回第一个值为道具数量，道具ID
function PetTrainPointsInfo.getTattolPointsExtraValue(level)
    if not level then
        level = 1
    end
    return att_oNums[#att_oNums][level],att_oIDS[#att_oIDS][level]
end

--返回第一个值为道具数量，道具ID
function PetTrainPointsInfo.getAttPointsExtraValue(index,level)
    if not level then
        level = 1
    end
    return att_oNums[index][level],att_oIDS[index][level]
end

--返回六围属性道具ID的集合
function PetTrainPointsInfo.getAttPointsExtraTable(index)
    return att_oNums[index],att_oIDS[index]
end

--返回训练点 道具ID的集合
function PetTrainPointsInfo.getTattolPointsExtraTable()
    return att_oNums[#att_oNums],att_oIDS[#att_oIDS]
end

return PetTrainPointsInfo