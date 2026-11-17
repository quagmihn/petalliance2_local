local ServerIPMrg = {}

function ServerIPMrg.getServerIPInfo()
    local http = "http://192.168.240.1:8080"
    local serverListAddress = http .. "/mxmevoListWorld?channel=android"
    local worldListAddress = serverListAddress
    local gameServerAddress = {{"192.168.240.1", 5568}}
    local errorReportAddress = http .. "/debug.clientlog"
    local queryPlatformCharacterAddress = http .. "/mxmevoListUserCharacters"
    local queryDeviceCharacterAddress = http .. "/mxmevoGetCharBriefByDevice"
    local isWhiteUserAddress = http .. "/isWhiteUser?"
    local isServerListPublish = 1

    return serverListAddress, worldListAddress, gameServerAddress,
        errorReportAddress, queryPlatformCharacterAddress,
        queryDeviceCharacterAddress, isWhiteUserAddress, isServerListPublish
end

return ServerIPMrg
