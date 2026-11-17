--
-- Author: Li Xiaolong
-- Date: 2014-10-12 13:07:51
-- 合并SDK
--require("utils.helper")

AllSDKManager = {
	SDK={
		TalkingData = "TalkingData",--数据分析
		WeiChat = "WeiChat",--微信分享
		FangCun = "FangCun",--方寸
		Advertise = "Advertise",--广告
	}
}
local sdkmt = {}
sdkmt.__index = function( tab,key )
	if 		AllSDKManager.SDK[key] then
        return require("src.Utils.sdk."..key)
	end
end
setmetatable(AllSDKManager, sdkmt)