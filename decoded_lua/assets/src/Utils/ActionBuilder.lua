local ActionBuilder = {}

function ActionBuilder.build(params)

    return ActionBuilder.buildAction(params)

end

function ActionBuilder.buildAction(params)

    if (not params or "table" ~= type(params)) then
        print("[Error] ActionBuilder.buildAction: Invalid params!")
        return nil
    end

    if (not params[1] or "string" ~= type(params[1])) then
        print("[Error] ActionBuilder.buildAction: No action type!")
        return nil
    end
    local actionType = params[1]
    
    if ("seq" == actionType) then
        return ActionBuilder.buildSequence(params)
    elseif ("spawn" == actionType) then
        return ActionBuilder.buildSpawn(params)
    elseif ("repeat" == actionType) then
        return ActionBuilder.buildRepeat(params)
    elseif ("easein" == actionType) then
        return ActionBuilder.buildEaseIn(params)
    elseif ("easeout" == actionType) then
        return ActionBuilder.buildEaseOut(params)
    elseif ("delay" == actionType) then
        return ActionBuilder.buildDelay(params)
    elseif ("moveto" == actionType) then
        return ActionBuilder.buildMoveTo(params)
    elseif ("moveby" == actionType) then
        return ActionBuilder.buildMoveBy(params)
    elseif ("rotto" == actionType) then
        return ActionBuilder.buildRotateTo(params)
    elseif ("rotby" == actionType) then
        return ActionBuilder.buildRotateBy(params)
    elseif ("scaleto" == actionType) then
        return ActionBuilder.buildScaleTo(params)
    elseif ("scaleby" == actionType) then
        return ActionBuilder.buildScaleBy(params)
    elseif ("fadeto" == actionType) then
        return ActionBuilder.buildFadeTo(params)
    elseif ("skewto" == actionType) then
        return ActionBuilder.buildSkewTo(params)
    elseif ("skewby" == actionType) then
        return ActionBuilder.buildSkewBy(params)
    elseif ("show" == actionType) then
        return ActionBuilder.buildShow(params)
    elseif ("hide" == actionType) then
        return ActionBuilder.buildHide(params)
    elseif ("flipx" == actionType) then
        return ActionBuilder.buildFlipX(params)
    elseif ("flipy" == actionType) then
        return ActionBuilder.buildFlipY(params)
    elseif ("call" == actionType) then
        return ActionBuilder.buildCall(params)
    else
        print("[Error] ActionBuilder.buildAction: Unknown action type " .. actionType)
        return nil
    end

end

function ActionBuilder.buildSequence(params)

    if (#params < 2) then
        print("[Error] ActionBuilder.buildSequence: No sequence content!")
    elseif (#params < 3) then
        print("[Warning] ActionBuilder.buildSequence: Only one sequence content!")
    end

    local array = CCArray:create()
    for i = 2, #params, 1 do
        array:addObject(ActionBuilder.buildAction(params[i]))
    end
    return CCSequence:create(array)

end

function ActionBuilder.buildSpawn(params)

    if (#params < 2) then
        print("[Error] ActionBuilder.buildSpawn: No spawn content!")
    elseif (#params < 3) then
        print("[Warning] ActionBuilder.buildSpawn: Only one spawn content!")
    end

    local array = CCArray:create()
    for i = 2, #params, 1 do
        array:addObject(ActionBuilder.buildAction(params[i]))
    end
    return CCSpawn:create(array)

end

function ActionBuilder.buildRepeat(params)

    if (#params ~= 3 or "table" ~= type(params[2]) or "number" ~= type(params[3])) then
        print("[Error] ActionBuilder.buildRepeat: Invalid repeat content!")
    end

    local action = ActionBuilder.buildAction(params[2])
    local times = params[3]
    if (times <= 0) then
        return CCRepeatForever:create(action)
    else
        return CCRepeat:create(action, times)
    end

end

function ActionBuilder.buildEaseIn(params)

    if (#params ~= 3 or "table" ~= type(params[2]) or "number" ~= type(params[3])) then
        print("[Error] ActionBuilder.buildEaseIn: Invalid repeat content!")
    end

    local action = ActionBuilder.buildAction(params[2])
    local rate = params[3]
    return CCEaseIn:create(action, rate)

end

function ActionBuilder.buildEaseOut(params)

    if (#params ~= 3 or "table" ~= type(params[2]) or "number" ~= type(params[3])) then
        print("[Error] ActionBuilder.buildEaseOut: Invalid repeat content!")
    end

    local action = ActionBuilder.buildAction(params[2])
    local rate = params[3]
    return CCEaseOut:create(action, rate)

end

function ActionBuilder.buildDelay(params)

    if (params[2] and "number" == type(params[2])) then
        return CCDelayTime:create(params[2])
    else
        print("[Error] ActionBuilder.buildDelay: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildMoveTo(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCMoveTo:create(params[2], ccp(params[3], params[4]))
    else
        print("[Error] ActionBuilder.buildMoveTo: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildMoveBy(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCMoveBy:create(params[2], ccp(params[3], params[4]))
    else
        print("[Error] ActionBuilder.buildMoveBy: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildRotateTo(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])) then
        return CCRotateTo:create(params[2], params[3])
    else
        print("[Error] ActionBuilder.buildMoveTo: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildRotateBy(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])) then
        return CCRotateBy:create(params[2], params[3])
    else
        print("[Error] ActionBuilder.buildMoveBy: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildScaleTo(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCScaleTo:create(params[2], params[3], params[4])
    elseif (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])) then
        return CCScaleTo:create(params[2], params[3])
    else
        print("[Error] ActionBuilder.buildScaleTo: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildScaleBy(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCScaleBy:create(params[2], params[3], params[4])
    elseif (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])) then
        return CCScaleBy:create(params[2], params[3])
    else
        print("[Error] ActionBuilder.buildScaleBy: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildFadeTo(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])) then
        return CCFadeTo:create(params[2], params[3])
    else
        print("[Error] ActionBuilder.buildFadeTo: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildSkewTo(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCSkewTo:create(params[2], params[3], params[4])
    else
        print("[Error] ActionBuilder.buildSkewTo: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildSkewBy(params)

    if (params[2] and "number" == type(params[2])
        and params[3] and "number" == type(params[3])
        and params[4] and "number" == type(params[4])) then
        return CCSkewBy:create(params[2], params[3], params[4])
    else
        print("[Error] ActionBuilder.CCSkewBy: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildShow(params)

    return CCShow:create()

end

function ActionBuilder.buildHide(params)

    return CCHide:create()

end

function ActionBuilder.buildFlipX(params)

    if (nil ~= params[2] and "boolean" == type(params[2])) then
        return CCFlipX:create(params[2])
    else
        print("[Error] ActionBuilder.buildFlipX: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildFlipY(params)

    if (nil ~= params[2] and "boolean" == type(params[2])) then
        return CCFlipY:create(params[2])
    else
        print("[Error] ActionBuilder.buildFlipY: Invalid params!")
        return nil
    end

end

function ActionBuilder.buildCall(params)

    if (params[2] and "function" == type(params[2])) then
        return CCCallFunc:create(params[2])
    else
        print("[Error] ActionBuilder.buildCall: Invalid params!")
        return nil
    end

end

return ActionBuilder