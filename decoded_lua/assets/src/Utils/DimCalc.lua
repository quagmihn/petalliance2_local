local DimCalc = {}

function DimCalc.calcDist(x0, y0, x1, y1)

    return math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))

end

function DimCalc.calcDistXP(x0, y0, x1, y1)

    local dist = DimCalc.calcDist(x0, y0, x1, y1)
    return dist * 240 / CCDevice:getDPI()

end

function DimCalc.calcLen(diffX, diffY)

    return math.sqrt(diffX * diffX + diffY * diffY)

end

function DimCalc.calcLenXP(diffX, diffY)

    local len = DimCalc.calcLen(diffX, diffY)
    return len * 240 / CCDevice:getDPI()

end

return DimCalc