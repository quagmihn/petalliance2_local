--平台相关的配置项，覆盖config.lua里的设定

gameConfig = {}

--语言(国别)版本
gameConfig.language = 
	"cn"		--中文简体
	--"tw"		--台湾繁体
	--"th"		--泰文


--最起始的服务器配置信息文件url， 配置各服务器地址、端口等信息。
gameConfig.startupConfigURL = 
	--曾经用过的地址
	--"http://192.168.240.1:8080/autoPatch/mtj_e/ver/FileListVer.lua"		--开发服
	--"http://192.168.240.1:8080/mtj_pub/FileListVer.lua"			--外网服(方寸)
	--"http://192.168.240.1:8080/FileListVer.lua"							--网易安卓
	--"http://192.168.240.1:8080/FileListVer_ios.lua"						--网易IOS
	--"http://192.168.240.1:8080/FileListVer_wangyi.lua"					--网易全公司安卓内测
	--"http://192.168.240.1:8080/mtj_taiwan/FileListVer.lua"			--台湾版北京ucloud服
	
	--正在用的地址
	--"http://192.168.240.1:8080/FileListVer_channel.lua"					--网易渠道服(1006 仅测试，不对外)
	--"http://192.168.240.1:8080/FileListVer_androidchannel.lua"			--2015.3.11版(1008 公测)
	"http://192.168.240.1:8080/patch/version.xml"						--2015.5.5公测版(1010)
	--"http://192.168.240.1:8080/FileListVer_qa.lua"						--网易QA服(1011)
	--"http://192.168.240.1:8080/FileListVer_yunying.lua"					--网易运营服(1012)
	--"http://192.168.240.1:8080/FileListVer_wangyupublic.lua"				--方寸版(忘语版)
	--"http://192.168.240.1:8080/FileListVer_androidreview.lua"			--(1014)


--IP地址形式的起始配置URL，仅在第一次连接域名形式地址失败时使用。若已经成功连接，则下次域名无法连接时，使用保存在localConfigTable中的IP地址
gameConfig.startupConfigURL_IP = 
	--"http://192.168.240.1/serverlist/FileListVer_channel.lua"			--网易渠道服(1006 仅测试，不对外)
	--"http://192.168.240.1/serverlist/FileListVer_androidchannel.lua"		--2015.3.11版(1008 公测)
	"http://192.168.240.1:8080/patch/version.xml"				--2015.5.5公测版(1010)
	--"http://192.168.240.1/serverlist/FileListVer_qa.lua"						--网易QA服(1011)
	--"http://192.168.240.1/serverlist/FileListVer_yunying.lua"					--网易运营服(1012)
	--"http://192.168.240.1/serverlist/FileListVer_wangyupublic.lua"		--方寸版(忘语版)
	--"http://192.168.240.1/serverlist/FileListVer_androidreview.lua"		--(1014)


--大渠道：为谁做的包。(登陆时选择的渠道称为小渠道，比如为网易做的包，可以登录网易、360等小渠道。)
gameConfig.bigChannel = 
	--"dev"	--开发渠道
	"wangyi"	--网易渠道
	--"taiwan"    --台湾

--游戏代号
gameConfig.GameCode = 
    "mtj"
    --"sister"
    --"hero"

--指定安卓版sd卡路径
--local androidPackageName = cc.FangCunSDKManager:getPackageInfo()
--print("androidPackageName=", androidPackageName)

--gameConfig.overrideAndroidSDCardPath = DeviceID:getExternalStoragePath().."/"..androidPackageName.."/"
--print("overrideAndroidSDCardPath=", gameConfig.overrideAndroidSDCardPath)
