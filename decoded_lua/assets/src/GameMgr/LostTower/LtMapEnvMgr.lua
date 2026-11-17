-- create 2016-2-25

local LtMapEnvMgr = {}

--迷霧資源路徑
LtMapEnvMgr.fogRes = {
    active = nil,
    locked = { common = nil, monster = nil, }
}

--地砖资源
LtMapEnvMgr.groundRes = {
    img = nil,
    imgX = nil,
}

function LtMapEnvMgr.Init()
end

return LtMapEnvMgr