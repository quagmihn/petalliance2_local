local BasicValueCalc = {}

function BasicValueCalc.calc(info,effortValue,personalValue,classRate)
    local classID = 10000 + classRate
    classRate = SystemInfo.getGlobalConfigAddInfoByID(classID).values[1] 
    local ret = (info.lifeRateValue + personalValue + effortValue)*classRate/100
    return math.floor(ret) 
end 

return BasicValueCalc