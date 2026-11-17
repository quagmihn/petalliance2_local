--vesion number 1.0
--@client side AuctionMgrNew.lua
--[[
这个文件是交易所客户端界面
--]]
--script writer Leon Lee
--creation time 2016-3-29

local AuctionMgrNew={}

AuctionMgrNew.MyAuctionNum = 0 --我出售的数量的成员变量
local useunblockloader = true

--翻译
local trans_jys = "exchange021" --"交易所"
local trans_gt = "exchange022" --"逛摊"
local trans_sh = "exchange023"--"商会"
local trans_sc = "exchange024" --"商城"
local trans_bt = "exchange025"--"摆摊"
local trans_mc = "exchange026"--"名称"
local trans_sj = "exchange027"--"售价"
local trans_sz = "exchange028"--"时 装"
local trans_jj = "exchange029"--"家 具"
local trans_zh = "exchange030"--"装 潢"
local trans_sucai = "exchange044"--改为技能了"素材"
local trasn_ts = "exchange031"--"每天0-9点交易所购买功能会关闭"
local trans_wdbg = "exchange032"--"我的背包"
local trans_wdtw = "exchange033"--"我的摊位"
local trans_djbt = "exchange034"--"点击下方背包内的物体进行摆摊"
local trans_lastpage = "exchange035"--"已是最后一页"
local trans_xianci = "exchange036"--"购买限次:"
local trans_wuxian = "exchange037"--"无限"
local trans_xiajia = "exchange038"--"是否确定让此商品下架？"
local trans_nobagitem = "exchange039"--"背包内没有可出售商品(时装、家具)"
local trans_rongliang = "exchange043"--"容量:"
local trans_notopen = "exchange049"--"您的等级不够，无法开启该设施"


local trans_errorBuySelf = "exchange050"--"不能自己买自己的商品"
local trans_alreadyHave = "exchange051"--"已拥有"
local trans_noitem = "没有该类型商品上架"

local firstTabArray = {
    [1]="逛摊",
    [2]="商会",
    [3]="商城",
}
local filterLabel  = {
   [1]={ --逛摊
   
        [1]={
            --[[2016-08-10 改成卖技能书了，所以去掉了
            "exchange041",--"通用",
            "exchange029",--"家具",
            "exchange030",--"装潢",
            "exchange028",--"时装",
            ]]
            "exchange045",--"主动",
            "exchange046",--"被动",
            "exchange047",--"奥义",
        },

       [2]={
            "exchange040", --"时装的素材"
            "lifeSkill027",--"头 饰",
            "lifeSkill028",--"衣 服",
            "lifeSkill029",--"裤 子",
            "lifeSkill030",--"背 饰",
            "lifeSkill031",--"武 器"
            "lifeSkill071",--"饰 品"
        },
    
    
        [4]={
            "exchange040", --"装潢的素材"
            "lifeSkill032",--"门牌",
            "lifeSkill033",--"门",
            "lifeSkill034",--"旅行箱",
            "lifeSkill035",--"墙纸",
            "lifeSkill036",--"地板",
            "lifeSkill037",--"盆栽",
            "lifeSkill038",--"墙饰",
            "lifeSkill039",--"吊灯"
            "lifeSkill073",--"徽章"
        },
        [3]={
            "exchange040", --"家具的素材"
            "lifeSkill040",--"床",
            "lifeSkill041",--"衣柜",
            "lifeSkill042",--"沙发",
            "lifeSkill043",--"桌子",
            "lifeSkill044",--"电视",
            "lifeSkill045",--"跑步机",
            "lifeSkill046",--"电脑"
            "lifeSkill072",--"增幅器"
        },
    },
    
    [2] ={--商会
        [1] ={},
        [2] ={},
        [3] ={},
    },
    
    [3] ={--商城
        [1] ={},
        [2] ={},
        [3] ={},    
    },

}

local filterLabelMarket ={
    [1]={},
    [2]={},
    [3]={},
}

local SecondTabLabel = { --第二排tab标签的名称列表,为了商城商会所加
    [1] = {trans_sucai,trans_sz,trans_jj,trans_zh},--逛摊
    [2]= {},--商会
    [3] = {},--商城


}


--数据初始化
--类型编号
local typeNumber = {
    [1] = { 
        --[[这个已经不卖了，改成卖技能书了
        --type ,subtypes 素材
        {itemType = 17,itemSubType =1},--通用
        {itemType = 17,itemSubType =2},--家具
        {itemType = 17,itemSubType =3},--装潢
        {itemType = 17,itemSubType =4},--时装
        ]]
        {itemType = 1,itemSubType =1},--主动技能
        {itemType = 1,itemSubType =2},--被动技能
        {itemType = 1,itemSubType =3},--奥义技能
    },
    
    [2] = { --type ,subtypes 时装
        {itemType = 17,itemSubType =4},--时装的素材
        {itemType = 22,itemSubType =1},--头饰
        {itemType = 22,itemSubType =2},--衣服
        {itemType = 22,itemSubType =3},--裤子
        {itemType = 22,itemSubType =4},--背饰
        {itemType = 22,itemSubType =5},--武器
        {itemType = 26,itemSubType =1},--饰品
    },
    
    [4] = { --type,subtypes 装潢
        {itemType = 17,itemSubType =3},--装潢的素材
        {itemType = 21,itemSubType =1},--门牌
        {itemType = 21,itemSubType =11},--门
        {itemType = 21,itemSubType =5},--旅行箱
        {itemType = 21,itemSubType =15},--墙纸
        {itemType = 21,itemSubType =16},--地板
        {itemType = 21,itemSubType =12},--盆栽
        {itemType = 21,itemSubType =13},--墙饰
        {itemType = 21,itemSubType =14},--吊灯
        {itemType = 26,itemSubType =3},--徽章
    },
    
    [3] = { --type,subtypes 家具
        {itemType = 17,itemSubType =2},--家具的素材
        {itemType = 21,itemSubType =2},--床
        {itemType = 21,itemSubType =3},--衣柜
        {itemType = 21,itemSubType =7},--沙发
        {itemType = 21,itemSubType =8},--桌子
        {itemType = 21,itemSubType =6},--电视
        {itemType = 21,itemSubType =9},--跑步机
        {itemType = 21,itemSubType =4},--电脑
        {itemType = 26,itemSubType =2},--增幅器
    },
}

local sellItemDataList = {
    [1]={}, --shi zhuang
    [2]={}, --jia ju
    [3]={}, --zhuang huang
    [4]={}, --shang cheng
    [5]={}, --shang hui
} --出售表

local filterBtnTable = {--过滤搜索按钮表
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},--商会
    [5] = {},--商城
}

local myItemDataList = {}
local lifeSkillInfo = {}
local coinTexture = {
    [1] = {texture ="UI/CommonFiles/icon_jinbi.png",scale = 0.42},--金币
    [2] = {texture ="UI/CommonFiles/ico_lanzuan.png",scale = 0.42},--钻石
    [3] = {texture ="UI/CommonFiles/Icn_silvery_cash.png",scale = 0.7},--银币
}

local coinTextureBottom = {
    [1] = {texture ="UI/CommonFiles/icon_jinbi.png",scale = 0.6},--金币
    [2] = {texture ="UI/CommonFiles/ico_lanzuan.png",scale = 0.6},--钻石
    [3] = {texture ="UI/CommonFiles/Icn_silvery_cash.png",scale = 1},--银币

}



local qianliInfo = 
{
    qianliLV = 0,
    qianliSkillInfo = nil
}

---------------------------------我是分割线------------------------------------

--ui初始化信息
local resNameAuctionMgrNew =  "" --列表UI资源
local resNameBg = ""--背景UI资源
local resName = "" --背包资源
local resNameTop = "" --顶部资源
local lastSelItem = nil --上次选择的项目
--UI数据
local currentFirstTab = 1 -- 1、逛摊  2、商会 3、商城  4、摆摊
local currentSecondTab = 1 --1、时装  2、家具 3、装潢 4、商会 5、商城

local currentFilterIndex = 1 --当前的筛选序号
local currentPageIndex = 0 --当前页数的序号
local currentSortType = 0
local currentItemId = 0
local currentSelectId = ""
local numPerPage = 6 --每页的数量

local firstTabCellTable ={} --tab页元素的合集
local firstTabOriginY = 0--tab页的原始位置

local secondTabCellTable={} --tab页元素的合集2
local secondTabOriginY = 0 --tab页的原始位置2

local firstTabTextArray = {trans_gt,trans_sh,trans_sc,trans_bt}
local secondTabTextArray = {trans_sucai,trans_sz,trans_jj,trans_zh}

local isRequested = false
local isTxtInited = false

local marketItemInfoTable = {} --可出售商品类型表
local marketTypeInfoTable = {}--商城类型列表
local shopMarketInfoTable = {}--玩家可出售列表

local marketItemTable = {} --可出售商品类型表
local marketTypeTable = {} --商城大类分类表
local marketSmllTypeTable ={}--商城小类表
local shopMarketTypeTable = {} --搜索分类表
local shopSellItemRecommPrice = {} --推荐价格表
local shopSellItemMinPrice = {} --最小价格表

local shopMarketSCTable = {} --商城列表
local shopMarketSHTable = {} --商会列表

local shopMarketSCSortTable = { --商城排序列表
    [1]= {},
    [2]= {},
}

local shopMarketSHSortTable = { --商会排序列表
    [1]={},
    [2]={},
}

local auctionBagInfo = {
}
--分类枚举,

local marketTypeEnum = { --、商会,商城
    ShangHui = 1,
    ShangCheng = 2,
}

local coinTypeEnum = { --货币分类
    GoldenCoin = 1,--金币
    MCoin =2,--钻石
    SilverCoint = 3 --银币
}

--页签货币数组
local tabCoinArray = {coinTypeEnum.SilverCoint,coinTypeEnum.SilverCoint,coinTypeEnum.MCoin,coinTypeEnum.SilverCoint}

local fontInfo = {

    txt_title={
        have_selstate = false, --是否有选中态
        outline_width = 1,
        font_color = {r =214,g=245,b=251,a=255},          
        outline_color = {r =26,g=37,b=48,a=255,w=1,s=1},   
            text = trans_jys                  
    },  

    btn_tab1={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =82,g=82,b=82,a=255},  --默认未选中
        outline_color = {r =230,g=230,b=230,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1}, --选中   
        text = trans_gt                     
    },
    

    btn_tab2={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =82,g=82,b=82,a=255},  --默认未选中
        outline_color = {r =230,g=230,b=230,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1}, --选中   
        text = trans_sh                  
    },


    btn_tab3={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =82,g=82,b=82,a=255},  --默认未选中
        outline_color = {r =230,g=230,b=230,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1}, --选中   
        text = trans_sc                     
    },  
    
    btn_tab4={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =82,g=82,b=82,a=255},  --默认未选中
        outline_color = {r =230,g=230,b=230,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =0,g=0,b=0,a=255,w=1}, --选中   
        text = trans_bt                     
    },  
    
    btn_tab11={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中   
        text = trans_sz                     
    },
 
    btn_tab12={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中   
        text = trans_jj                    
    },
    
    btn_tab13={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中   
        text = trans_jj                    
    },
    
    btn_tab14={
        have_selstate = true, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =10,g=22,b=65,a=255},     --默认未选中
        font_color_sel = {r =255,g=243,b=227,a=255},--选中  
        outline_color_sel = {r =89,g=47,b=5,a=255}, --选中   
        text = trans_jj                    
    },
    
    btn_filter={
        have_selstate = false, --是否有选中态
        outline_width = 2, 
        font_color = {r =98,g=128,b=166,a=255},  --默认未选中
        outline_color = {r =24,g=34,b=45,a=255},     --默认未选中
        font_color_sel = {r =255,g=255,b=255,a=255},--选中  
        outline_color_sel = {r =1,g=61,b=107,a=255}, --选中   
        text = "nodata"                  
    },
    
    
    txt_sortname={
        have_selstate = false, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255},     --默认未选中
        text = trans_mc                  
    },
    
    txt_sortprice={
        have_selstate = false, --是否有选中态
        outline_width = 2, 
        font_color = {r =227,g=233,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255},     --默认未选中
        text = trans_sj                 
    },

    txt_icontitle={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =189,g=231,b=252,a=255},  --默认未选中
        outline_color = {r =17,g=27,b=38,a=255,w=1,s=1},     --默认未选中
        text = "nodata"                 
    },
    
    txt_itemdesc={
        have_selstate = false, --是否有选中态
        outline_width = nil, 
        font_color = {r =71,g=96,b=103,a=255},  --默认未选中
        outline_color = {r =5,g=48,b=84,a=255},     --默认未选中
        text = "nodata"                 
    },
    
    txt_desc={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =98,g=128,b=166,a=255},  --默认未选中
        outline_color = {r =24,g=34,b=45,a=255},     --默认未选中
            text = trasn_ts                  
    }, 
    
    txt_sellnum={
        have_selstate = true, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =12,g=27,b=38,a=255},     --默认未选中
        font_color_sel = {r=147,g=254,b=6,a=255},
        outline_color_sel = {r =0,g=0,b=0,a=255},	
        text = "nodata"                  
    },      
    
    txt_bagtitle={
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        text = trans_wdbg       
    },
    
    txt_bttitle = {
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        text = trans_wdtw      
    },
    
    txt_btnum = {
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=255,b=255,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        text = "0/10"      
    },
    
    
    txt_btnumtitle = {
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =166,g=243,b=255,a=255},  --默认未选中
        outline_color = {r =12,g=27,b=38,a=255,w=1,s=1},     --默认未选中
        text = trans_rongliang    
    },
    
    
    
    txt_noitem = {
        have_selstate = false, --是否有选中态
        outline_width = 1, 
        font_color = {r =255,g=252,b=0,a=255},  --默认未选中
        outline_color = {r =0,g=0,b=0,a=255,w=1,s=1},     --默认未选中
        text = trans_djbt      
    },
    
    txt_sellcount = {
        have_selestate = false,
        outline_width = 1,
        font_color = {r = 255,g = 255,b=255,a = 255},
        outline_color = {r=5,g=48,b=84, a= 255},
        text = "nodata",
    },

    txt_pagenum = {
        have_selestate = false,
        outline_width = 1,
        font_color = {r = 255,g = 255,b=255,a = 255},
        outline_color = {r=0,g=0,b=0, a= 255,w=1,s=1},
        text = "nodata",
    },     
    
    txt_silvernum={
        have_selestate = false,
        outline_width = nil,
        font_color = {r = 255,g = 255,b=255,a = 255},
        outline_color = {r=255,g=255,b=255, a= 255},
        text = "nodata",        
    },
    
    txt_toplisttitle={
        have_selestate = false,
        outline_width = 1,
        font_color = {r = 255,g = 240,b=0,a = 255},
        outline_color = {r=17,g=27,b=38, a= 255,w=1,s=1},
        text = "nodata",        
       
    },
    
    txt_toplistsellcount = {
        have_selestate = false,
        outline_width = 1,
        font_color = {r = 255,g = 240,b=0,a = 255},
        outline_color = {r=17,g=27,b=38, a= 255,w=1,s=1},
        text = "nodata",       
        
    },
    
    txt_toplistsellnum = {
            have_selestate = false,
            outline_width = nil,
            font_color = {r = 255,g = 252,b=255,a = 255},
            outline_color = {r=0,g=0,b=0, a= 0},
            text = "nodata",      
    
    },
    
    txt_timeslimit = {
        have_selestate = false,
        outline_width = nil,
        font_color = {r = 71,g = 96,b=103,a = 255},
        outline_color = {r=0,g=0,b=0, a= 0},
        text = trans_xianci,       
    
    },
    
    
    txt_timesnum = {
            have_selestate = false,
            outline_width = nil,
            font_color = {r = 255,g = 0,b=1,a = 255},
            outline_color = {r=0,g=0,b=0, a= 0},
            text = "nodata",            
    },
    
    txt_timesnumnormal = {
            have_selestate = false,
            outline_width = nil,
            font_color = {r = 71,g = 96,b=103,a = 255},
            outline_color = {r=0,g=0,b=0, a= 0},
            text = "nodata",        
    
    },
    
    txt_nobagitem = {
        have_selestate = false,
        outline_width = 1,
        font_color = {r = 144,g = 238,b=255,a = 255},
        outline_color = {r=17,g=29,b=39, a= 255},
        text = trans_nobagitem,       
    
    },
    
    txt_biaoqian ={
        have_selestate = false,
        outline_width = 2,
        font_color = {r = 5,g = 221,b=253,a = 255},
        outline_color = {r=6,g=65,b=99, a= 255},
        text = trans_alreadyHave,      
    },
}


local listcellColorInfo = { --列表图片颜色信息
    pic_listbg = {
        have_selstate = false,
        color_default = {r=67,g=85,b=100,a=255},  
    },

    pic_listiconbg = {
        have_selstate = false,
        color_default = {r=128,g=161,b=172,a=255},         
    },
    
    pic_iconbg = {
        have_selstate = false,
        color_default = {r=71,g=96,b=103,a=255}
    },
    
    pic_biaoqian ={
        have_selstate = false,
        color_default = {r=0,g=0,b=0,a=255}   
    },
    
    pic_listouterbg = {
        have_selstate = true,
        color_default = {r=41,g=56,b=68,a=255},      
        color_sel = {r=54,g=75,b=90,a=255}
        
    }
}

local list2cellColorInfo = { 
    pic_toplistbg = {
        have_selstate = false,
        color_default = {r=70,g=90,b=96,a=255},         
    },
    
    pic_toplistcundi = {
        have_selstate = false,
        color_default = {r=173,g=190,b=193,a=255},     
    },
    
    
}
--初始化商会商城信息
local function initMarketInfo()

    --sort 排序
    local function compareMarketTypeTable(a,b)
        if a==nil or b ==nil then
            return false
        end

        return a.subtypeid < b.subtypeid
    end

    local function compareMarketSmallTypeTable(a,b)
        if a == nil or b == nil then

            return false;
        end

        return a.smalltype <b.smalltype
    end

    local scMarketTypeTable = {}
    local shMarketTypeTable = {}

    local scMarketSmallTypeTable = {}
    local shMarketSmallTypeTable = {}


    
    for k,v in pairs(marketTypeTable) do
        if v.type == "商会" then
            table.insert(shMarketTypeTable,v)
        end

        if v.type == "商城" then
            table.insert(scMarketTypeTable,v)
        end       
    end 
    
    for k,v in pairs(marketSmllTypeTable) do
        if v.type == "商会" then
            table.insert(shMarketSmallTypeTable,v)
        end

        if v.type == "商城" then
            table.insert(scMarketSmallTypeTable,v)
        end       
    end      
    
    
    --sort begin
    table.sort(shMarketTypeTable,compareMarketTypeTable)
    table.sort(scMarketTypeTable,compareMarketTypeTable)
    
    table.sort(shMarketSmallTypeTable,compareMarketSmallTypeTable)
    table.sort(scMarketSmallTypeTable,compareMarketSmallTypeTable)
    
    for i = 1,#shMarketTypeTable do
        table.insert(SecondTabLabel[2],shMarketTypeTable[i].subtypename)
        print("shSeconLabel" ..shMarketTypeTable[i].subtypename)
    end
    
    for i = 1,#scMarketTypeTable do
        table.insert(SecondTabLabel[3],scMarketTypeTable[i].subtypename)
        print("scSeconLabel" ..scMarketTypeTable[i].subtypename)
    end
    
    for i = 1,#shMarketSmallTypeTable do
        table.insert(filterLabel[2][tonumber(shMarketSmallTypeTable[i].subtypeid)],shMarketSmallTypeTable[i].smalltypename)
    end
    
    for i = 1,#scMarketSmallTypeTable do
        table.insert(filterLabel[3][tonumber(scMarketSmallTypeTable[i].subtypeid)],scMarketSmallTypeTable[i].smalltypename)
    end
    
    --init filter label
    

end



--初始化市场所有物品的排序信息
local function initMarketItemSortTable(allItemArray) 

    shopMarketSHTable = {}
    shopMarketSCTable = {}
    for key,v in pairs(allItemArray) do
        if v.marketType == marketTypeEnum.ShangHui then
            table.insert(shopMarketSHTable,v)
        end
        
        if v.marketType == marketTypeEnum.ShangCheng then
            table.insert(shopMarketSCTable,v)
        end
        print("all marketInfo itemType,subType "..v.vip)
    end
    
       --shopMarketSortTable  
    local function sortByItemName(a,b)
        if a==nil or b == nil then
            return false
        end
        
        return a.itemID < b.itemID 
    end
    
    local function sortByItemPrice(a,b)
        if a==nil or b==nil then
            return false
        end
        
        return a.num < b.num
    end
    
    table.sort(shopMarketSHTable,sortByItemName)
    for i = 1,#shopMarketSHTable do 
        --print("shopMarketSHTable:" ..shopMarketSHTable[i].vip)
        table.insert(shopMarketSHSortTable[1],shopMarketSHTable[i])
    end
    
    table.sort(shopMarketSHTable,sortByItemPrice)
    for i =1,#shopMarketSHTable do
        table.insert(shopMarketSHSortTable[2],shopMarketSHTable[i])
    end
    
    table.sort(shopMarketSCTable,sortByItemName)
    for i = 1,#shopMarketSCTable do 
        table.insert(shopMarketSCSortTable[1],shopMarketSCTable[i])
    end

    table.sort(shopMarketSCTable,sortByItemPrice)
    for i =1,#shopMarketSCTable do
        table.insert(shopMarketSCSortTable[2],shopMarketSCTable[i])
    end
    
end 

---读取可出售物品表
local function readConfigTxt()
    local marketItemInfoReader = TxtReader.new("Config/MarketItem.txt")
    marketItemInfoTable = marketItemInfoReader.init({"id","type","typename","subtype","subtypename","typeid","subtypeid"},1)
    marketItemTable = {}
    for key,v in pairs(marketItemInfoTable) do 
        local strkey = v.typeid.."-"..v.subtypeid
        marketItemTable[strkey] = v
    end
    
    marketTypeTable = {}
    local marketTypeReader = TxtReader.new("Config/MarketType.txt")
    marketTypeInfoTable = marketTypeReader.init({"id","type","typename","subtypeid","subtypename","smalltype","smalltypename"},1)
    for key,v in pairs(marketTypeInfoTable) do
        marketTypeTable[v.type..v.subtypename] = v
        marketSmllTypeTable[v.type..v.smalltypename] = v
    end
    
  
    initMarketInfo()  

    local shopMarketTypeReader = TxtReader.new("Config/ShopMarketType.txt")
    shopMarketInfoTable = shopMarketTypeReader.init({"id","type","subtype","recommenprice","minprice"},1)
    shopMarketTypeTable = {}
    for key,v in pairs(shopMarketInfoTable) do
        local keystr = v.type.."-"..v.subtype

        if shopMarketTypeTable[keystr] == nil then
            --print("init keystr:"..keystr)
            shopMarketTypeTable[keystr] = {}
            table.insert(shopMarketTypeTable[keystr],{v.id,v.recommenprice,v.minprice})
            --print("shopSellItemRecommPrice[v.id] price:......."..v.id,v.recommenprice)
            shopSellItemRecommPrice[tonumber(v.id)] = v.recommenprice
            shopSellItemMinPrice[tonumber(v.id)] = v.minprice
            print("shopSellItemMinPrice[v.id] price:......."..v.id,v.minprice)
        else
            --print("exist keystr:"..keystr,v.id)
            table.insert(shopMarketTypeTable[keystr],{v.id,v.recommenprice,v.minprice})
            --print("shopSellItemRecommPrice[v.id] price:......."..v.id,v.recommenprice)
            shopSellItemRecommPrice[tonumber(v.id)] = v.recommenprice
            shopSellItemMinPrice[tonumber(v.id)] = v.minprice
        end
        
    end
    
    local vec = ItemInfo.getAllMarketInfo()
   --[[
    shopMarketSHTable = {}
    shopMarketSCTable = {}
    for key,v in pairs(vec) do
        if v.marketType == marketTypeEnum.ShangHui then
            table.insert(shopMarketSHTable,v)
        end
        
        if v.marketType == marketTypeEnum.ShangCheng then
            table.insert(shopMarketSCTable,v)
        end
        print("all marketInfo itemType,subType "..v.itemID,v.subType,v.subTypeName,v.marketType,v.coinType,v.num,v.buyMax)
    end
    --]]
    initMarketItemSortTable(vec)
end
---------------------------------我是分割线------------------------------------

---设置label的字体
local function setLabel(label,string,outline,outlinewidth,textColor,maxwidth,singlelinewidth)

    CSResourceMgr.setLabelColorByNode(label,textColor)
    local singleline = singlelinewidth or nil
    if singleline~=nil then
        CSResourceMgr.setLabelStringByNode(label,string,nil,nil,singleline)
    else
         CSResourceMgr.setLabelStringByNode(label,string,nil)
    end
    if outlinewidth~=nil  then
        label:enableOutline(outline, outlinewidth)
    end

    if maxwidth~=nil then
        CSResourceMgr.setLabelMaxWidthByNode(label,maxwidth)
    end
end

---根据传入的数据创建列表
--@param data table {itemid = id,itemprice =price}
local function createListCell(data)
    local listcell = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_listexample"):clone()

    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listbg")
    listtitlebg:setColor(listcellColorInfo.pic_listbg.color_default)

    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(listcellColorInfo.pic_listiconbg.color_default)

    local coinbg = CSResourceMgr.seekNodeByName(listcell,"pic_coinbg")
    coinbg:setColor(listcellColorInfo.pic_iconbg.color_default)

    local iteminfo = ItemInfo.getItemInfoById(data.itemID)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,iteminfo.name,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)

    local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
    setLabel(itemdesc,iteminfo.desc,fontInfo.txt_itemdesc.outline_color,fontInfo.txt_itemdesc.outline_width,fontInfo.txt_itemdesc.font_color,350)

    local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
    picIcon:loadTexture(iteminfo.icon)
    
    local listicon = CSResourceMgr.seekNodeByName(listcell,"btn_listicon")
    local image = ItemInfo.getItemRareBGImage(data.itemID)
   
    CSResourceMgr.setButtonTextureByNode(listicon,image,image,image)

    local sellcount = CSResourceMgr.seekNodeByName(listcell,"txt_sellcount")
    setLabel(sellcount,tostring(data.sellNum),fontInfo.txt_sellcount.outline_color,fontInfo.txt_sellcount.outline_width,fontInfo.txt_sellcount.font_color)

    local sellnum = CSResourceMgr.seekNodeByName(listcell,"txt_sellnum")
    setLabel(sellnum,tostring(data.unitPrice),fontInfo.txt_sellnum.outline_color,fontInfo.txt_sellnum.outline_width,fontInfo.txt_sellnum.font_color)

    CSResourceMgr.seekNodeByName(listcell,"txt_timeslimit"):setVisible(false)
    CSResourceMgr.seekNodeByName(listcell,"txt_timesnum"):setVisible(false)
    CSResourceMgr.seekNodeByName(listcell,"txt_timesnum1"):setVisible(false)
  CSResourceMgr.seekNodeByName(listcell,"txt_timesnum2"):setVisible(false)    
    CSResourceMgr.seekNodeByName(listcell,"txt_timesnum3"):setVisible(false)
    
    local btn = CSResourceMgr.seekNodeByName(listcell,"btn_listexample1")
    CSResourceMgr.clickEventBindingByNode(btn,function()
        if tonumber(data.charID) ~= CharInfo.getCharID() then
            BuyInfoMgr.show(SceneMgr.getRunningScene,data)
        else
            StandardTipsMgr.show(1,trans_errorBuySelf)
        end
    end)
    
    local itemNode = CSResourceMgr.seekNodeByName(listcell,"btn_listicon")
    CSResourceMgr.buttonEventBindingByNode(itemNode, function ()
                    ItemInfoViewMgr.show({id = data.itemID}, false)
                end, function ()
                    ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    ItemInfoViewMgr.hide()
                end, true)

    return listcell

end

---根据传入的数据创建列表,用于商城
--@param data table {itemid = id,itemprice =price}
local function createListCell2(data)

    local function isInDrawingPics(itemid) --判断是否拥有该图纸
        --[[
        if lifeSkillInfo.drawings == nil then
            return false

         else

            for i = 1,#lifeSkillInfo.drawings do
                local data = ItemInfo.getDrawingInfoById(lifeSkillInfo.drawings[i])
                if tonumber(data.itemID) == tonumber(itemid) then
                    return true
                end
            end
         end
         ]]
        return false
    end
    
    
    local listcell = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_listexample"):clone()

    local biaoqianpic = CSResourceMgr.seekNodeByName(listcell,"pic_biaoqian")
    biaoqianpic:setColor(listcellColorInfo.pic_biaoqian.color_default)
    --biaoqianpic:setOpacity(0.8)
    
    local biaoqian = CSResourceMgr.seekNodeByName(listcell,"txt_biaoqian")
    setLabel(biaoqian,fontInfo.txt_biaoqian.text,fontInfo.txt_biaoqian.outline_color,fontInfo.txt_biaoqian.outline_width,fontInfo.txt_biaoqian.font_color)
  
    
    --local ret = isInDrawingPics(data.itemID)
    local viplimit = data.vip
    local showviplimit = true
    if viplimit~=nil then 
        if tonumber(CharInfo.getVIPLevel()) >=tonumber(viplimit)+1 then 
            --print("viplevel,viplimit is",CharInfo.getVIPLevel(),viplimit)
            showviplimit = false
        end
    end
    if showviplimit == true  then  
        --print("data.vip is........"..data.vip)
        if data.vip > 0 then 
            biaoqianpic:setVisible(true)
            biaoqian:setVisible(true)
            local tmpstr =  CocosModuleMgr.createStringWithFormat({"Exchange0009", data.vip})--"限VIP"..data.vip
            setLabel(biaoqian,tmpstr,fontInfo.txt_biaoqian.outline_color,fontInfo.txt_biaoqian.outline_width,fontInfo.txt_biaoqian.font_color)
        else
             biaoqianpic:setVisible(false)
            biaoqian:setVisible(false)       
        end
    end
    
    local listtitlebg = CSResourceMgr.seekNodeByName(listcell,"pic_listbg")
    listtitlebg:setColor(listcellColorInfo.pic_listbg.color_default)

    local listiconbg = CSResourceMgr.seekNodeByName(listcell,"pic_listiconbg")
    listiconbg:setColor(listcellColorInfo.pic_listiconbg.color_default)

    local coinbg = CSResourceMgr.seekNodeByName(listcell,"pic_coinbg")
    coinbg:setColor(listcellColorInfo.pic_iconbg.color_default)

    local iteminfo = ItemInfo.getItemInfoById(data.itemID)

    local icontitle = CSResourceMgr.seekNodeByName(listcell,"txt_icontitle")
    setLabel(icontitle,iteminfo.name,fontInfo.txt_icontitle.outline_color,fontInfo.txt_icontitle.outline_width,fontInfo.txt_icontitle.font_color)

    local itemdesc = CSResourceMgr.seekNodeByName(listcell,"txt_itemdesc")
    setLabel(itemdesc,iteminfo.desc,fontInfo.txt_itemdesc.outline_color,fontInfo.txt_itemdesc.outline_width,fontInfo.txt_itemdesc.font_color,350)
    local listicon = CSResourceMgr.seekNodeByName(listcell,"btn_listicon")
    local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon")
    local iconPath = nil
    --local maskIcon = CSResourceMgr.seekNodeByName(listcell,"pic_mask")
    if iteminfo.itemType == 15 then 
        local itemIcon =  ItemInfo.getItemIconById(iteminfo.id)
        listcell:addChild(itemIcon)
        itemIcon:setPosition(listiconbg:getPosition())
        itemIcon:setPositionX(itemIcon:getPositionX()+10)
        listicon:setVisible(false)
        itemIcon:setScale(0.75)
        
        --picIcon:setScale(0.79)
        --maskIcon:setScale(0.79)
    else
        --maskIcon:setVisible(false)
        iconPath = iteminfo.icon 
    end
    picIcon:loadTexture(iconPath)


    local image = ItemInfo.getItemRareBGImage(data.itemID)

    CSResourceMgr.setButtonTextureByNode(listicon,image,image,image)

    local sellcount = CSResourceMgr.seekNodeByName(listcell,"txt_sellcount")
    --setLabel(sellcount,tostring(data.sellNum),fontInfo.txt_sellcount.outline_color,fontInfo.txt_sellcount.outline_width,fontInfo.txt_sellcount.font_color)
    sellcount:setVisible(false)
    
	local itemprice = data.unitPrice
	if qianliInfo.qianliSkillInfo~=nil then --如果有降价潜力点
		local arrow = CSResourceMgr.seekNodeByName(listcell,"pic_arrowicon")
		if currentFirstTab == 2 then --商会
			arrow:setVisible(true)
			local jiangjia = qianliInfo.qianliSkillInfo.params[1]
			local sjjiage = (100-jiangjia)/100
			itemprice = math.round(itemprice*sjjiage)
			data.unitPrice = itemprice
		end
		
	end

    local sellnum = CSResourceMgr.seekNodeByName(listcell,"txt_sellnum")

	if qianliInfo.qianliSkillInfo~= nil and currentFirstTab == 2  then --有潜力技能并且是商会
		setLabel(sellnum,tostring(itemprice)--[[(data.unitPrice)]],fontInfo.txt_sellnum.outline_color_sel,fontInfo.txt_sellnum.outline_width,fontInfo.txt_sellnum.font_color_sel)

	else
		setLabel(sellnum,tostring(itemprice)--[[(data.unitPrice)]],fontInfo.txt_sellnum.outline_color,fontInfo.txt_sellnum.outline_width,fontInfo.txt_sellnum.font_color)
	end    
    local timesnum = CSResourceMgr.seekNodeByName(listcell,"txt_timesnum")
    
    local timesnum1 = CSResourceMgr.seekNodeByName(listcell,"txt_timesnum1")
    local timesnum3 = CSResourceMgr.seekNodeByName(listcell,"txt_timesnum3")
    local timesnum2 = CSResourceMgr.seekNodeByName(listcell,"txt_timesnum2")
    
    local timeslimit = CSResourceMgr.seekNodeByName(listcell,"txt_timeslimit")
    setLabel(timeslimit,fontInfo.txt_timeslimit.text,fontInfo.txt_timeslimit.outline_color,fontInfo.txt_timeslimit.outline_width,fontInfo.txt_timeslimit.font_color)
    timeslimit:setVisible(true)
    
    local timesnumstr
    if data.buyMax == 0 then
        --timesnumstr = trans_wuxian
        --setLabel(timesnum,timesnumstr,fontInfo.txt_timesnumnormal.outline_color,fontInfo.txt_timesnumnormal.outline_width,fontInfo.txt_timesnumnormal.font_color)
        timesnum:setVisible(false)
        timesnum1:setVisible(false)
        timesnum2:setVisible(false)
        timesnum3:setVisible(false)
        timeslimit:setVisible(false)
    else
        timesnumstr = tostring(data.sellNum)
        if data.sellNum==0 then
            setLabel(timesnum1,timesnumstr,fontInfo.txt_timesnum.outline_color,fontInfo.txt_timesnum.outline_width,fontInfo.txt_timesnum.font_color)        
        else
            setLabel(timesnum1,timesnumstr,fontInfo.txt_timesnumnormal.outline_color,fontInfo.txt_timesnumnormal.outline_width,fontInfo.txt_timesnumnormal.font_color)        
        end
        timesnum1:setVisible(true)
        timesnum2:setVisible(true)
        timesnum:setVisible(false)
        setLabel(timesnum2,"/",fontInfo.txt_timesnumnormal.outline_color,fontInfo.txt_timesnumnormal.outline_width,fontInfo.txt_timesnumnormal.font_color)        
        timesnumstr = tostring(data.buyMax)
        setLabel(timesnum3,timesnumstr,fontInfo.txt_timesnumnormal.outline_color,fontInfo.txt_timesnumnormal.outline_width,fontInfo.txt_timesnumnormal.font_color)        
        timesnum3:setVisible(true)
       

        --timesnumstr = tostring(data.sellNum).."/"..tostring(data.buyMax)
    end
    --setLabel(timesnum,timesnumstr,fontInfo.txt_timesnum.outline_color,fontInfo.txt_timesnum.outline_width,fontInfo.txt_timesnum.font_color)
    --timesnum:setVisible(true)

    local btn = CSResourceMgr.seekNodeByName(listcell,"btn_listexample1")
    CSResourceMgr.clickEventBindingByNode(btn,function()
        if showviplimit then 
            StandardTipsMgr.show(1,"Exchange0008")
        else
            BuyInfoMgr2.show(SceneMgr.getRunningScene,data)
        end
    end)

    local itemNode = CSResourceMgr.seekNodeByName(listcell,"btn_listicon")
    CSResourceMgr.buttonEventBindingByNode(itemNode, function ()
                    ItemInfoViewMgr.show({id = data.itemID}, false)
                end, function ()
                    ItemInfoViewMgr.hide()
                end, function ()
                end, function ()
                    ItemInfoViewMgr.hide()
                end, true)

    local silvercash = CSResourceMgr.seekNodeByName(listcell,"pic_sellsilvericon")
    silvercash:loadTexture(coinTexture[data.coinType].texture)
    silvercash:setScale(coinTexture[data.coinType].scale)
    return listcell   
end




local function delMySellAuctionItem(data)
    local isRefresh = false
    DialogBoxMgr.showSmallDialogBox(SceneMgr.getRunningScene,2,trans_xiajia,function()
        NetInterface.sendWithBlock("GC_DELMYPRODUCT_ACK",function()
            local marketSend = require("src.Net.Send.MarketSend")
            local data = {productID = data.productID}
            marketSend.sendCG_DelMyProduct_Req(data)
        end,
        function() 
            AuctionMgrNew.refresh(2)
            isRefresh = true
        end,

        function(code)
            TipsMgr.showError(nil,code)
            if isRefresh == false then

                CSResourceMgr.setButtonEnabledByNode(data.listcell,true)

            end
        end
        )
    end,function() 
        if isRefresh == false then
           
            CSResourceMgr.setButtonEnabledByNode(data.listcell,true)
            
        end
    
    end)
end



---根据传入的数据创建列表,用于显示自己出售的商品
local function createList2Cell(dataTable)
    
    local listcell = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"panel_toplist"):clone()
    

    local toplistbg1 = CSResourceMgr.seekNodeByName(listcell,"pic_toplistbg1")
    toplistbg1:setColor(list2cellColorInfo.pic_toplistbg.color_default)
    
    local toplistbg2 = CSResourceMgr.seekNodeByName(listcell,"pic_toplistbg2")
    toplistbg2:setColor(list2cellColorInfo.pic_toplistbg.color_default)

    local toplistcundi1 = CSResourceMgr.seekNodeByName(listcell,"pic_toplistcundi1")
    toplistcundi1:setColor(list2cellColorInfo.pic_toplistcundi.color_default)
    
    local toplistcundi2 = CSResourceMgr.seekNodeByName(listcell,"pic_toplistcundi2")
    toplistcundi2:setColor(list2cellColorInfo.pic_toplistcundi.color_default)
    
 
    local function showProduct(data,i)
        local iteminfo = ItemInfo.getItemInfoById(data.itemID) 
        local toplisttitle = CSResourceMgr.seekNodeByName(listcell,"txt_toplisttitle"..i)
        setLabel(toplisttitle,iteminfo.name,fontInfo.txt_toplisttitle.outline_color,fontInfo.txt_toplisttitle.outline_width,fontInfo.txt_toplisttitle.font_color,nil,150)
        local picIcon = CSResourceMgr.seekNodeByName(listcell,"pic_icon"..i)
        picIcon:loadTexture(iteminfo.icon)
        
        local listicon = CSResourceMgr.seekNodeByName(listcell,"btn_toplisticon"..i)
        local image = ItemInfo.getItemRareBGImage(data.itemID)
        CSResourceMgr.setButtonTextureByNode(listicon,image,image,image)

        CSResourceMgr.buttonEventBindingByNode(listicon, function ()
                        ItemInfoViewMgr.show({id = data.itemID}, false)
                    end, function ()
                        ItemInfoViewMgr.hide()
                    end, function ()
                    end, function ()
                        ItemInfoViewMgr.hide()
                    end, true)
        
        local sellcount = CSResourceMgr.seekNodeByName(listcell,"txt_toplistsellcount"..i)
        setLabel(sellcount,tostring(data.sellNum),fontInfo.txt_toplistsellcount.outline_color,fontInfo.txt_toplistsellcount.outline_width,fontInfo.txt_toplistsellcount.font_color)
        
        local sellnum = CSResourceMgr.seekNodeByName(listcell,"txt_toplistsellnum"..i)
        setLabel(sellnum,tostring(data.unitPrice*data.sellNum),fontInfo.txt_toplistsellnum.outline_color,fontInfo.txt_toplistsellnum.outline_width,fontInfo.txt_toplistsellnum.font_color)

        local pricebg = CSResourceMgr.seekNodeByName(listcell,"pic_pricebg"..i)        
        pricebg:setColor({r=142,g=150,b=151,a=255})
        
    end
    
    

    if #dataTable == 2 then
        showProduct(dataTable[1],1)
        showProduct(dataTable[2],2)
        local no1 = CSResourceMgr.seekNodeByName(listcell,"btn_topcell1")
        local no2 = CSResourceMgr.seekNodeByName(listcell,"btn_topcell2")
        
        CSResourceMgr.clickEventBindingByNode(no1,function()
            CSResourceMgr.setButtonEnabledByNode(no1,false)
            dataTable[1].listcell = no1
            delMySellAuctionItem(dataTable[1])
        end)
        
        CSResourceMgr.clickEventBindingByNode(no2,function()
            CSResourceMgr.setButtonEnabledByNode(no2,false)
            dataTable[2].listcell = no2
            delMySellAuctionItem(dataTable[2])
        end)
    else
        showProduct(dataTable[1],1)
        local no1 = CSResourceMgr.seekNodeByName(listcell,"btn_topcell1")

        CSResourceMgr.clickEventBindingByNode(no1,function()
            CSResourceMgr.setButtonEnabledByNode(no1,false)
            dataTable[1].listcell = no1
            delMySellAuctionItem(dataTable[1])
        end)
        local no2 = CSResourceMgr.seekNodeByName(listcell,"btn_topcell2")
        no2:setVisible(false)
    end
    return listcell
    
end

local function resetListCell(dataList)

    local list1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"list1") 

    --加载市场物品的限购时间信息
    local function loadMarketItem(datalist)
    
        local sendstr = {}
        local info = CharInfo.get()
 
        for i=1,#dataList do
            --没有获取过
            local data = dataList[i]
 
            if data.buyMax > 0 then
                local buynum = info["buymarketitemnum_"..data.productID]
                local timestamp = info["buymarketitemtime_"..data.productID]
                if buynum ==nil or  timestamp == nil then         
                    table.insert(sendstr,"buyMarketItemNum_"..data.productID)
                    table.insert(sendstr,"buyMarketItemTime_"..data.productID)
                end
                
            end
                  
       end
       
       local function loadList()
       
            local funcTable = {}
            UnblockLoader.cancel("AuctionMgrNew.setTab2")
            for i =1,#dataList do
                table.insert(funcTable,function()
                    local data = dataList[i]
                    local info = CharInfo.get()

                    local buynum = info["buymarketitemnum_"..data.productID]
                    local timestamp = info["buymarketitemtime_"..data.productID]
                    if buynum~=nil  then 
                        data.sellNum = data.buyMax-buynum 
                    end
                    if timestamp~=nil then 
                        data.timestamp = timestamp 
                        --判断时间戳
                        local daytimediff  = CocosModuleMgr.getDayTimeDiff(timestamp,CharInfo.getServerTime())
                        --print("daytimediff......" ..daytimediff)
                        if daytimediff>0 then
                            data.sellNum = data.buyMax
                        end
                    end

                    local listcell = createListCell2(data)
                    local listbg = CSResourceMgr.seekNodeByName(listcell,"pic_listouterbg")
                    if i%2 == 0 then
                        listbg:setColor(listcellColorInfo.pic_listouterbg.color_default)
                    else
                        listbg:setColor(listcellColorInfo.pic_listouterbg.color_sel)    

                    end
                    listcell:setScaleY(0)

                    list1:pushBackCustomItem(listcell)   
                    transition.scaleTo(listcell,{scale=1.0,time = 0.2})             
   
                end)
                --设置数值
                --funcTable[i]()
            end       
            
            UnblockLoader.load(funcTable,"AuctionMgrNew.setTab2")
       
       end
       
        if #sendstr > 0 then 
            NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
                local LoginSend = require("src.Net.Send.LoginSend")
                LoginSend.sendCG_GetCharacterValues_Req(sendstr) --petPacketNum
            end, function()
                loadList()
   
            end, function(code)
                TipsMgr.showError(nil, code)
            end)  
            
        else
        
            loadList()
        end
       
    end
    
  
    list1:removeAllChildren()
    if currentFirstTab == 1 then --玩家交易
        UnblockLoader.cancel("AuctionMgrNew.setTab1")
        local funcTable = {}
        for i =1,#dataList do
            local function func()
                local listcell = createListCell(dataList[i])
                local listbg = CSResourceMgr.seekNodeByName(listcell,"pic_listouterbg")
                if i%2 == 0 then
                    listbg:setColor(listcellColorInfo.pic_listouterbg.color_default)
                else
                    listbg:setColor(listcellColorInfo.pic_listouterbg.color_sel)     
                                   
                end
                list1:pushBackCustomItem(listcell)
                listcell:setScaleY(0)
                transition.scaleTo(listcell,{scale=1.0,time=0.2})
            end
            table.insert(funcTable,func)
        end
        UnblockLoader.load(funcTable, "AuctionMgrNew.setTab1")
    else --商会、商城
    --[[
         for i =1,#dataList do
            --先获取限购信息
            local listcell = createListCell2(dataList[i])
            list1:pushBackCustomItem(listcell)
         end    
         ]]   
        loadMarketItem(dataList)
    end

end

local function setTopListBannerAndText(dataList)

    local noitem = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitem")
    local showtext= #dataList.."/10"
    AuctionMgrNew.MyAuctionNum = #dataList
    if #dataList > 0 then
        noitem:setVisible(false)
    else
        noitem:setVisible(true)
    end
    
    local btnum = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_btnum")
    setLabel(btnum,showtext,fontInfo.txt_btnum.outline_color,fontInfo.txt_btnum.outline_width,fontInfo.txt_btnum.font_color)  

    local btnumtitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_btnumtitle")
    setLabel(btnumtitle,fontInfo.txt_btnumtitle.text,fontInfo.txt_btnumtitle.outline_color,fontInfo.txt_btnumtitle.outline_width,fontInfo.txt_btnumtitle.font_color) 
end

local function resetMyAuctionListCell(dataList)
    local list2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"list2")  
    if list2 == nil then return end 
    list2:removeAllChildren()
    
    
    setTopListBannerAndText(dataList)
    local dataTable = {}
    if #dataList == 1 then 
        local listcell = createList2Cell(dataList)
        list2:pushBackCustomItem(listcell)
     end
        
    if #dataList >1 then
       local listcell = nil
       for i =1,#dataList do
            if i%2~= 0 then
                dataTable = {}
                table.insert(dataTable,dataList[i])
                if i == #dataList then 
                    listcell = createList2Cell(dataTable)
                    list2:pushBackCustomItem(listcell)                      
                end
            else
                table.insert(dataTable,dataList[i])
                listcell = createList2Cell(dataTable)
                list2:pushBackCustomItem(listcell)                
            end
            
            
       end   
    end
    
    
end

local function resetMyBagList()
    lastSelItem = nil
    UnblockLoader.cancel("AuctionMgrNewBag-reset")
    local funcTable = {}
    local panelTable = {}
    local list = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list3")
    CSResourceMgr.removeListByNode(list)
    --list:removeAllItems()

    local bagInfo = {}
    local curTab = 4
    --[[below code not use since 2016-08-16
    local bagItemInfo = ItemInfo.getCharItemInfo()
    for var=1, 4 do
        bagInfo[var] = {}
    end
    
    for key, var in pairs(bagItemInfo) do
        local iteminfo = ItemInfo.getItemInfoById(key)

        local itemtype = iteminfo.itemType
        local itemsubtype = iteminfo.itemTypeID
        local strkey = iteminfo.itemType.."-"..iteminfo.itemTypeID
        local itemtid = ItemInfo.getItemType(key)
        
        if type(var) ~= "number" then
            for objid,v in pairs(var) do
                print("itemtid is and key is:"..itemtid,key)
                if itemtid and marketItemTable[strkey] ~=nil then
                    --prinitTab(v)
                    if v.isBind ~=1 then -- 不绑定
                        table.insert(bagInfo[curTab], {key, v.num, v.isBind,objid})
                    end
                end
            end
        elseif var>0 then
            if itemtid and  marketItemTable[strkey] ~=nil then
                table.insert(bagInfo[curTab], {key, var})
            end
        end

    end

    --get my skill book for sale
    local mySkillBookInfo  = ItemInfo.getSkillBookInfo()
    for k,v in pairs(mySkillBookInfo) do 
        if v>0 then 
            local iteminfo = ItemInfo.getItemInfoById(k)
            if iteminfo~=nil then 
                local strkey = iteminfo.itemType.."-"..iteminfo.itemTypeID
                if marketItemTable[strkey] ~=nil then 
                    table.insert(bagInfo[curTab],{k,v})
                end
            end
        end
    end
    --]]
    bagInfo[curTab] = {}
    for k,v in pairs(auctionBagInfo) do
        if v~=nil then  
            if v[4]~=nil then  --objid is not nil
                for j =1,#v[4] do 
                    local iteminfo = {v[1],1,v[3],v[4][j]}
                    table.insert(bagInfo[curTab],iteminfo)
                end
            else
                table.insert(bagInfo[curTab],v)
            end
        end
    end

    local equipBags = PetEquipmentMgr.getAllPetEquipment2Evaluate();
    for k,v in pairs(equipBags) do
        local iteminfo = ItemInfo.getItemInfoById(v[1])

        if iteminfo ~=nil then 
            --print("equipBags iteminfo's itemRare&num is %d:%d is...........",iteminfo.itemRare,v[2])
            if iteminfo.itemRare < 5 then 
                table.insert(bagInfo[curTab],v)
            end
        end
    end

    table.sort(bagInfo[curTab],function(a,b) 
        return a[1] < b[1]
    end
    )
    --bagInfo[curTab] = auctionBagInfo
    --print("auctionBagInfo ..........num is:"..#auctionBagInfo)
    ------------------------------------------------------------------------------------
    local ranknum = 4
    local spawncount = 5
    local countperline = 4
    local allnum = countperline*spawncount
    for i=1, #bagInfo[curTab] do
        if i>allnum then break end
        local row = math.ceil(i/ranknum)
        local rank = i%ranknum
        if rank==0 then
            rank = ranknum
        end

        local bagItemInfo = bagInfo[curTab][i]
        local function itemFunc()
        if rank==1 then
            local panel = CSResourceMgr.getNodeByName(resName, "panel","AuctionMgrNewBagView"):clone()
            panel:setContentSize(585,170)
            table.insert(panelTable, panel)
            list:pushBackCustomItem(panel)
            panel.button = {}
        end
            local parent = panelTable[row]
            local label = CSResourceMgr.seekNodeByName(parent, "l"..rank)
            if bagItemInfo[2]==1 then
                CSResourceMgr.setLabelStringByNode(label, "1", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            elseif bagItemInfo[2]>999 then
                CSResourceMgr.setLabelStringByNode(label, "999+", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            else
                CSResourceMgr.setLabelStringByNode(label, bagItemInfo[2], CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS)
            end


            local sprite = CSResourceMgr.seekNodeByName(parent, "s"..rank)
            --local iconpath = ItemInfo.getItemInfoById(bagItemInfo[1]).icon
            --CSResourceMgr.setButtonTextureByNode(sprite, iconpath, iconpath, iconpath)
            local itembutton = ItemInfo.getItemIconById(bagItemInfo[1],bagItemInfo[2],nil,true,true)


            
            local diban = CSResourceMgr.seekNodeByName(parent, "b"..rank)
            local x = diban:getPositionX()
            local y = diban:getPositionY()+30
            itembutton:setPositionX(x)
            itembutton:setPositionY(y)
            parent:addChild(itembutton)
            parent.button[rank] = itembutton
            local recommonprice = shopSellItemRecommPrice[bagItemInfo[1]]
            local minprice = shopSellItemMinPrice[bagItemInfo[1]]
            if recommonprice==nil then 
                recommonprice = 0
            end

            CSResourceMgr.clickEventBindingByNode(itembutton, function()
                print("bagItemInfo[4]....................",bagItemInfo[4])
                print("shopSellItemMinPrice[bagItemInfo[1]] price:......."..bagItemInfo[1],minprice)
                SellInfoMgr.show(SceneMgr.getRunningScene,{itemID = bagItemInfo[1],itemNum = bagItemInfo[2],objid = bagItemInfo[4],minprice =minprice },{itembutton,bagInfo[curTab][i],recommonprice})   
  
            end,3)

            --itembutton:setScale(0, 0)
           -- itembutton:setRotation(180)
           -- transition.scaleTo(itembutton, {scale = 1.0, time = 0.2})
            --transition.rotateTo(itembutton, {rotate = 360, time = 0.2})
            --[[no need to code below 2016-08-11
            local btnRes = ItemInfo.getItemRareBGImage(bagItemInfo[1])
            CSResourceMgr.setButtonTextureByNode(diban, btnRes, btnRes, btnRes)
            CSResourceMgr.clickEventBindingByNode(diban, function()
                CocosModuleMgr.hideShiningToNode(diban)
                CSResourceMgr.seekNodeByName(diban, "light"):setVisible(true)
                if lastSelItem then
                    CSResourceMgr.seekNodeByName(lastSelItem, "light"):setVisible(false)
                end
                lastSelItem = diban
                SellInfoMgr.show(SceneMgr.getRunningScene,{itemID = bagItemInfo[1],itemNum = bagItemInfo[2],objid = bagItemInfo[4]})
            end,3)

            diban:setScale(0, 0)
            diban:setVisible(false)
            transition.scaleTo(diban, {scale = 1, time = 0.1})
            ]]
            --parent:setScale(0.95)
            --local nameLabel = CSResourceMgr.seekNodeByName(parent, "n"..rank)
            --CSResourceMgr.setLabelStringByNode(nameLabel, itemInfo[bagItemInfo[1]].name)
            --nameLabel:setTextColor({r=0,g=0,b=0,a=255})
        end
       --table.insert(funcTable, itemFunc)
        itemFunc()

    end


    if #bagInfo[curTab]>allnum then

        HighPerformList.makeHighPerFormVerticalList(list,spawncount,20,countperline,190,170,bagInfo[curTab],
        function(item,currentindex)
            
            for j=1,countperline do 
                local bagItemInfo = bagInfo[curTab][currentindex+j-1]
                local diban = CSResourceMgr.seekNodeByName(item, "b"..j)
                if bagItemInfo == nil then 
                    diban:setVisible(false)
                    item.button[j]:setVisible(false)
                else
                    diban:setVisible(false)
                    local itembutton = ItemInfo.getItemIconById(bagItemInfo[1],bagItemInfo[2],nil,true,true)
                    local x = diban:getPositionX()
                    local y = diban:getPositionY()
                    itembutton:setPositionX(x)
                    itembutton:setPositionY(y+30)
                    item.button[j]:removeFromParent()
                    item:addChild(itembutton)
                    item.button[j] = itembutton
                    if bagItemInfo[2] == 0 then 
                        CSResourceMgr.setButtonEnabledByNode(itembutton,false)
                        local sprite = CSResourceMgr.seekNodeByName(itembutton, "s")
                        sprite:setColor({r=77,g=77,b=77})
                    end

                  
                    local recommonprice = shopSellItemRecommPrice[bagItemInfo[1]]
                    local minprice = shopSellItemMinPrice[bagItemInfo[1]]
                     print("minprice....................",bagItemInfo[1],minprice)
                    if recommonprice==nil then 
                        recommonprice = 0
                    end

                    CSResourceMgr.clickEventBindingByNode(itembutton, function()
                      
                       print("bagItemInfo[4]....................",bagItemInfo[4])
                       print("shopSellItemMinPrice[bagItemInfo[1]] price:......."..bagItemInfo[1],minprice)
                       SellInfoMgr.show(SceneMgr.getRunningScene,{itemID = bagItemInfo[1],itemNum = bagItemInfo[2],objid = bagItemInfo[4],minprice =minprice},{itembutton,bagInfo[curTab][currentindex+j-1],recommonprice,minprice}) 
                    --[[
                    if  bagItemInfo[4]~=nil then 
                        --print("bagItemInfo[4]...................."..bagItemInfo[4])
                        if #bagItemInfo[4] >0 then 
                            SellInfoMgr.show(SceneMgr.getRunningScene,{itemID = bagItemInfo[1],itemNum = bagItemInfo[2],objid = bagItemInfo[4][1]},{itembutton,bagInfo[curTab][currentindex+j-1],recommonprice})
                        end
                    else
                            SellInfoMgr.show(SceneMgr.getRunningScene,{itemID = bagItemInfo[1],itemNum = bagItemInfo[2],objid = bagItemInfo[4]},{itembutton,bagInfo[curTab][currentindex+j-1],recommonprice})                        
                    end
                    ]]

            end,3)
                end

            end
        end)    
    else
        --CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitembg"):setVisible(true)            
    end

    if #bagInfo[curTab]> 0 then 
       CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitembg"):setVisible(false)
    else 
       CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitembg"):setVisible(true)        
    end
    --UnblockLoader.load(funcTable, "AuctionMgrNewBag-reset")
end




local function loadMyAuctionList()
    NetInterface.send("GC_GETMYMARKET_ACK",
        function() 
            local mymarketSend = require("src.Net.Send.MarketSend")
            mymarketSend.sendCG_GetMyMarket_Req()     
        end,

        function() 
            resetMyAuctionListCell(myItemDataList) 
            --resetMyBagList()
        end,

        function(code)
            TipsMgr.showError(nil,code)
            --resetMyBagList()
        end

    )

end


local function loadCurrentAuctionList(startPageIndex,filterIndex,sortType,itemId,selectid)
    currentSelectId = selectid
    selectid = selectid or ""
    sortType = sortType or 0
    itemId = itemId or 0
    currentItemId = itemId
   
    
    --print("search itemId currentSecondeTab filterIndex"..itemId,currentSecondTab,filterIndex)
    NetInterface.sendWithBlock("GC_SEARCHPRODUCTS_ACK",
        function()       
            local sellSend = require("src.Net.Send.MarketSend")
            print("selectid is ............."..selectid)
            -- print("currentSecondTab,filterIndex,itemSubType,itemType,startPageIndex:"..currentSecondTab,filterIndex,typeNumber[currentSecondTab][filterIndex].itemSubType,typeNumber[currentSecondTab][filterIndex].itemType,startPageIndex)
            local data = {itemID = currentItemId,itemSubType = typeNumber[currentSecondTab][filterIndex].itemSubType,itemType = typeNumber[currentSecondTab][filterIndex].itemType,startIndex =startPageIndex, searchNum = numPerPage,sortType = sortType,selectID = selectid} --0 name sort 1 price sort
            sellSend.sendCG_SearchProducts_Req(data)
        end,
        function()
            --print("sellItemDataList[currentSecondTab]......num"..#sellItemDataList[currentSecondTab])
            resetListCell(sellItemDataList[currentSecondTab]) 
     
           
            local pagenum =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_pagenum")
            local page = startPageIndex/numPerPage+1
            if #sellItemDataList[currentSecondTab] ==0 then 
               -- page = currentPageIndex/numPerPage+1 
                setLabel(pagenum,tostring(page),fontInfo.txt_pagenum.outline_color,fontInfo.txt_pagenum.outline_width,fontInfo.txt_pagenum.font_color)

            else
                --resetListCell(sellItemDataList[currentSecondTab]) 
                currentPageIndex = startPageIndex
                setLabel(pagenum,tostring(page),fontInfo.txt_pagenum.outline_color,fontInfo.txt_pagenum.outline_width,fontInfo.txt_pagenum.font_color)
            end
                      
        end,

        function(code)

            TipsMgr.showError(nil,code)
        end)

end

local function makeSellData(data)
    local selldata = {}
    selldata.id = data.id
    selldata.itemID = data.itemID
    selldata.itemSubType = data.itemSubType
    selldata.subTypeName = data.subTypeName
    selldata.productID = data.id
    selldata.coinType = data.coinType
    selldata.unitPrice = data.num
    selldata.buyMax = data.buyMax
    selldata.sellNum = data.buyMax  
    selldata.smallType = data.smallType
    selldata.smallTypeName = data.smallTypeName
    selldata.charID = data.charID
    selldata.vip = data.vip or 0
    --print("selldata sellnum"..selldata.sellNum)      
    return selldata
end

---获得当前市场的物品
--@param startPageIndex int 起始页
--@param filterIndex int 筛选
--@param sortType int 排序 0-按名称 1按价格
local function loadCurrentMarketList(startPageIndex,filterIndex,sortType)
    sortType = sortType or 0
    local marketListTable = {}
    local marketListTempTable = {}
    sellItemDataList[currentSecondTab] = {}
    

    if currentFirstTab == 2 then --商会
        marketListTempTable = shopMarketSHSortTable[sortType+1] --shopMarketSHTable
        
        --print("marketListTable num,sortType"..#marketListTable,sortType)
        
    end 
    
    if currentFirstTab == 3 then --商城
        marketListTempTable = shopMarketSCSortTable[sortType+1] --shopMarketSCTable
        --print("marketListTempTable count:"..#marketListTempTable,#shopMarketSCTable[sortType+1])
        
    end
    
    for i = 1,#marketListTempTable do
        --print("currentSecondTab,currentfirsttab,smallTypeName1,smallTypeName2,subTypeName1,subTypeName2:"..currentSecondTab,currentFirstTab,marketListTempTable[i].smallTypeName,filterLabelMarket[currentSecondTab][filterIndex],marketListTempTable[i].subTypeName,SecondTabLabel[currentFirstTab][currentSecondTab])

        if marketListTempTable[i].smallTypeName == filterLabelMarket[currentSecondTab][filterIndex] and  marketListTempTable[i].subTypeName == SecondTabLabel[currentFirstTab][currentSecondTab]  then
            local data = makeSellData(marketListTempTable[i])
            table.insert(marketListTable ,data)
         end
    end
    
    if startPageIndex+1 <=#marketListTable then
        local endindex = 0
        if startPageIndex+numPerPage <=#marketListTable then
            endindex = startPageIndex+numPerPage
        else
            endindex = #marketListTable
        end 
        
        print("startPageIndex+1,endindex"..startPageIndex+1,endindex)
        for i=startPageIndex+1,endindex do
           -- print("currentSecondTab,currentfirsttab,smallTypeName1,smallTypeName2,subTypeName1,subTypeName2:"..currentSecondTab,currentFirstTab,marketListTable[i].smallTypeName,filterLabelMarket[currentSecondTab][filterIndex],marketListTable[i].subTypeName,SecondTabLabel[currentFirstTab][currentSecondTab])
           -- print(marketTypeTable[firstTabArray[currentFirstTab]..marketListTable[i].smallTypeName],marketTypeTable[firstTabArray[currentFirstTab]..filterLabelMarket[filterIndex]],marketSmllTypeTable[firstTabArray[currentFirstTab]..marketListTable[i].subTypeName],marketSmllTypeTable[firstTabArray[currentFirstTab]..SecondTabLabel[currentFirstTab][currentSecondTab]])
           -- if marketListTable[i].smallTypeName == filterLabelMarket[currentSecondTab][filterIndex] and  marketListTable[i].subTypeName == SecondTabLabel[currentFirstTab][currentSecondTab]  then
                
                --local data = makeSellData(marketListTable[i])
                --print("marketListTable[i].vip is............."..marketListTable[i].vip)
            table.insert(sellItemDataList[currentSecondTab] ,marketListTable[i])
   
           --end


        end  
    end
    
    resetListCell(sellItemDataList[currentSecondTab]) 
    
end

---marketList排序

local function loadSortMarketList(startPageIndex,filterIndex)
     local marketListTable = nil
     
end

local function resetListPageNum()
    local pagenum =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_pagenum")
    setLabel(pagenum,tostring(currentPageIndex/numPerPage+1),fontInfo.txt_pagenum.outline_color,fontInfo.txt_pagenum.outline_width,fontInfo.txt_pagenum.font_color)
end

local function initQianliSkillInfo()
    local skillUpInfo,num = AchievementListMgr.getSkillUpInfo("price")
    
    qianliInfo.qianliLV = num
    qianliInfo.qianliSkillInfo = skillUpInfo

   
--    CSResourceMgr.createRes(SceneMgr.getRunningScene,resNameSkill)      
--    local skillBtn = CSResourceMgr.getNodeByName(resNameSkill, "skillBtn"):clone()


--    [[
--    local skillLv = CSResourceMgr.seekNodeByName(skillBtn, "skillLv")
--    CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
--    CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})
--    ]]

    local node1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_node1")
    if qianliInfo.qianliSkillInfo~=nil then
        local icon = CSResourceMgr.seekNodeByName(node1, "pic_icon")
        local iconRes = "Battle/skillIcon/"..skillUpInfo.icon
        --print("iconRes........"..iconRes)
        icon:setScale(0.5)
        CSResourceMgr.setSpriteTextureByNode(icon, iconRes)
        
        CSResourceMgr.clickEventBindingByNode(node1, function()
            AchievementListMgr.showSkillInfo(qianliInfo.qianliSkillInfo,false,false,nil)
        end)
    
        local skillLv = CSResourceMgr.seekNodeByName(node1, "txt_qllv")
        CSResourceMgr.setLabelColorByNode(skillLv, {r=255,g=255,b=255,a=255})
        CSResourceMgr.setLabelStringByNode(skillLv, "Lv"..num, {r=0,g=0,b=0,a=255})
   else
        node1:setVisible(false) 
   end
end

local function initUIBasedata()

    local title = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_title") 
    setLabel(title,fontInfo.txt_title.text,fontInfo.txt_title.outline_color,fontInfo.txt_title.outline_width,fontInfo.txt_title.font_color)

    local sortprice = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_sortprice") 
    setLabel(sortprice,fontInfo.txt_sortprice.text,fontInfo.txt_sortprice.outline_color,fontInfo.txt_sortprice.outline_width,fontInfo.txt_sortprice.font_color)
    
    local desc = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_desc")
    setLabel(desc,fontInfo.txt_desc.text,fontInfo.txt_desc.outline_color,fontInfo.txt_desc.outline_width,fontInfo.txt_desc.font_color)

    
    local tab1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab1")
    firstTabOriginY = tab1:getPositionY()
    
    local tab11 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab11")
    secondTabOriginY = tab11:getPositionY()
    
    local part1 =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_part1_menu")
    local part2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_part2_menu")
    
    part1:setVisible(true)
    part2:setVisible(false)
    
    local bagtitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bagtitle")
    setLabel(bagtitle,fontInfo.txt_bagtitle.text,fontInfo.txt_bagtitle.outline_color,fontInfo.txt_bagtitle.outline_width,fontInfo.txt_bagtitle.font_color)

    local bttitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bttitle")
    setLabel(bttitle,fontInfo.txt_bttitle.text,fontInfo.txt_bttitle.outline_color,fontInfo.txt_bttitle.outline_width,fontInfo.txt_bttitle.font_color) 
    
    local btnum = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_btnum")
    setLabel(btnum,fontInfo.txt_btnum.text,fontInfo.txt_btnum.outline_color,fontInfo.txt_btnum.outline_width,fontInfo.txt_btnum.font_color)  
    
    local noitem = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_noitem")
    setLabel(noitem,fontInfo.txt_noitem.text,fontInfo.txt_noitem.outline_color,fontInfo.txt_noitem.outline_width,fontInfo.txt_noitem.font_color)    
    
    
    local noitembag = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_nobagitem")
    setLabel(noitembag,fontInfo.txt_nobagitem.text,fontInfo.txt_nobagitem.outline_color,fontInfo.txt_nobagitem.outline_width,fontInfo.txt_nobagitem.font_color)    

    
    local silvercoin = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_silvernum")
    local silvercash = CharInfo.getSilverCash()
    if silvercash == nil then
        silvercash = 0
    end
    setLabel(silvercoin,tostring(silvercash),fontInfo.txt_silvernum.outline_color,fontInfo.txt_silvernum.outline_width,fontInfo.txt_silvernum.font_color)    

    
    resetListPageNum()

    local jiantour = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_jiantour")
    CSResourceMgr.clickEventBindingByNode(jiantour,function()
    
  --      if currentFirstTab == 1 then --逛摊
            if #sellItemDataList[currentSecondTab] ==0 or #sellItemDataList[currentSecondTab] < numPerPage then 
                if currentFirstTab == 1 then --逛摊
                    loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType,currentItemId,currentSelectId)
                else
                    --loadCurrentMarketList(currentPageIndex,currentFilterIndex,currentSortType)
                end
                
                if #sellItemDataList[currentSecondTab] ==0 or #sellItemDataList[currentSecondTab] < numPerPage then 
                     TipsMgr.show(nil,trans_lastpage)  
                end   
            else
                if currentFirstTab == 1 then --逛摊
                    loadCurrentAuctionList(currentPageIndex+numPerPage,currentFilterIndex,currentSortType,currentItemId,currentSelectId)
                else
                    loadCurrentMarketList(currentPageIndex+numPerPage,currentFilterIndex,currentSortType)                
                end
                currentPageIndex = currentPageIndex+numPerPage
                local page = currentPageIndex/numPerPage+1   
                local pagenum =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_pagenum")
                setLabel(pagenum,tostring(page),fontInfo.txt_pagenum.outline_color,fontInfo.txt_pagenum.outline_width,fontInfo.txt_pagenum.font_color)
                if #sellItemDataList[currentSecondTab] ==0 or #sellItemDataList[currentSecondTab] < numPerPage then 
                    TipsMgr.show(nil,trans_lastpage)  
                end 
            end
  --      else --其他
            
    --    end
    end,
    3)
    
    local jiantoul = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_jiantoul")
    CSResourceMgr.clickEventBindingByNode(jiantoul,function()
 --      if currentFirstTab == 1 then --逛摊
            local pageIndex = currentPageIndex-numPerPage
            
            if currentFirstTab == 1 then --逛摊
                if pageIndex < 0 then pageIndex = 0 end
                loadCurrentAuctionList(pageIndex,currentFilterIndex,currentSortType,currentItemId,currentSelectId)
            else
                if pageIndex >= 0 then
                    loadCurrentMarketList(pageIndex,currentFilterIndex,currentSortType)
                else
                    pageIndex = 0
                end
            end
            currentPageIndex = pageIndex
            local page = currentPageIndex/numPerPage+1   
            local pagenum =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_pagenum")
            setLabel(pagenum,tostring(page),fontInfo.txt_pagenum.outline_color,fontInfo.txt_pagenum.outline_width,fontInfo.txt_pagenum.font_color)
 --      else --其他
            
  --     end
         
    end,
    
    3)
    
    local sortname = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortname")
    CSResourceMgr.setButtonEnabledByNode(sortname,false)

    initQianliSkillInfo()
end


local function resize()

    local diff = CocosModuleMgr.getScreenSizeDiff()-80
    local frame = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "frame")
    local fsize = frame:getContentSize()
    frame:setContentSize(fsize.width, fsize.height+diff)
    
  --  local diban1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "panel_diwen1")
  --  local dbsize = diban1:getContentSize()
  --  diban1:setContentSize(dbsize.width, dbsize.height+diff)

 --   local diban2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "panel_diwen2")
  --  local dbsize = diban2:getContentSize()
 --   diban2:setContentSize(dbsize.width, dbsize.height+diff)

    
    local listbg1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_bg1")
    dbsize = listbg1:getContentSize()
    listbg1:setContentSize(dbsize.width, dbsize.height+diff)
    listbg1:setLocalZOrder(3)

    local listbg2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_bg2")
    dbsize = listbg2:getContentSize()
    listbg2:setContentSize(dbsize.width, dbsize.height+diff)
    --listbg2:setLocalZOrder(2)
    --listbg2:setVisible(false)
    

    local title = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "txt_title")
    local tposy = title:getPositionY()
    title:setPositionY(tposy+diff)
    local close = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "close")
    local cposy = close:getPositionY()
    close:setPositionY(cposy+diff)
    close:setVisible(false)

    local tab1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab1")
    local tposy = tab1:getPositionY()
    tab1:setPositionY(tposy+diff)


    local tab2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab2")
    local tposy = tab2:getPositionY()
    tab2:setPositionY(tposy+diff)


    local tab3 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab3")
    local tposy = tab3:getPositionY()
    tab3:setPositionY(tposy+diff)

    local tab4 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab4")
    local tposy = tab4:getPositionY()
    tab4:setPositionY(tposy+diff)
    
    local tab11 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab11")
    local tposy = tab11:getPositionY()
    tab11:setPositionY(tposy+diff)


    local tab12 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab12")
    local tposy = tab12:getPositionY()
    tab12:setPositionY(tposy+diff)


    local tab13 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab13")
    local tposy = tab13:getPositionY()
    tab13:setPositionY(tposy+diff)
    
    local tab14 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_tab14")
    local tposy = tab14:getPositionY()
    tab14:setPositionY(tposy+diff)

    --[[
    local part1_tab = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_part1_tab")
    local tposy = part1_tab:getPositionY()
    part1_tab:setPositionY(tposy+diff)
    part1_tab:setLocalZOrder(3)
]]
    local menunode = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_menunode")
    local tposy = menunode:getPositionY()
    menunode:setPositionY(tposy+diff)
    

    
    local part1_listbg = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_part1_listbg")
    dbsize = part1_listbg:getContentSize()
    part1_listbg:setContentSize(dbsize.width, dbsize.height+diff)
    
    local list1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list1")
    dbsize = list1:getContentSize()
    list1:setContentSize(dbsize.width, dbsize.height+diff)
    
    --[[
    local btn_sortname = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_sortname")
    local tposy = btn_sortname:getPositionY()
    btn_sortname:setPositionY(tposy+diff)
    
    
    local txt_sortname = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "txt_sortname")
    local tposy = txt_sortname:getPositionY()
    txt_sortname:setPositionY(tposy+diff)
    
    local btn_sortnamearrow = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_sortnamearrow")
    local tposy = btn_sortnamearrow:getPositionY()
    btn_sortnamearrow:setPositionY(tposy+diff)
    
    local btn_sortprice = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_sortprice")
    local tposy = btn_sortprice:getPositionY()
    btn_sortprice:setPositionY(tposy+diff)

    local txt_sortprice = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "txt_sortprice")
    local tposy = txt_sortprice:getPositionY()
    txt_sortprice:setPositionY(tposy+diff)

    local btn_sortpricearrow = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "btn_sortpricearrow")
    local tposy = btn_sortpricearrow:getPositionY()
    btn_sortpricearrow:setPositionY(tposy+diff)
    ]]
    local part1menu = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "pic_part1_menu")
    dbsize = part1menu:getContentSize()
    part1menu:setContentSize(dbsize.width, dbsize.height+diff)
    part1menu:setLocalZOrder(4)
    
    local part2menu = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_part2_menu")
    dbsize = part2menu:getContentSize()
    part2menu:setContentSize(dbsize.width, dbsize.height+diff)
    part2menu:setLocalZOrder(3)
    
    
    local bg12 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_bg12")
    local tposy = bg12:getPositionY()    
    bg12:setPositionY(tposy+diff)
    
    local btitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bttitle")
    local tposy = btitle:getPositionY()    
    btitle:setPositionY(tposy+diff)
    
    local btnum = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_btnum")
    local tposy = btnum:getPositionY()    
    btnum:setPositionY(tposy+diff) 
    
    local bagtitlebg = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitem")
    local tposy = bagtitlebg:getPositionY()    
    bagtitlebg:setPositionY(tposy+diff) 
    
    local topbg = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_topbg")
    local tposy = topbg:getPositionY()    
    topbg:setPositionY(tposy+diff) 
    
    local midbg = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_midbg")
    local tposy = midbg:getPositionY()    
    midbg:setPositionY(tposy+diff) 
    
    local noitembg = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_noitembg")
    local tposy = noitembg:getPositionY()    
    noitembg:setPositionY(tposy+diff)     
    
    local line = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"line")
    local tposy = line:getPositionY()    
    line:setPositionY(tposy+diff)    
    line:setLocalZOrder(3)   
 
    
    local bg13 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_bg13")
    local tposy = bg13:getPositionY()  
    bg13:setPositionY(tposy+diff)   
    
    local bagtitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bagtitle")
    local tposy = bagtitle:getPositionY()  
    bagtitle:setPositionY(tposy+diff)   
    
    local bagnumtitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bagumtitle")
    local tposy = bagnumtitle:getPositionY()  
    bagnumtitle:setPositionY(tposy+diff)   
    
    local btnumtitle = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_btnumtitle")
    local tposy = btnumtitle:getPositionY()  
    btnumtitle:setPositionY(tposy+diff)   

	local node1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_node1")
	local tposy = node1:getPositionY()
	node1:setPositionY(tposy+diff)
    
    
    
    local bagnum = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_bagnum")
    local tposy = bagnum:getPositionY()  
    bagnum:setPositionY(tposy+diff)   
         
    local list3 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list3")
    dbsize = list3:getContentSize()
    list3:setContentSize(dbsize.width, dbsize.height+diff)
end
--局部函数


local function showTopInfoBar(callback)
    callback = callback or function() end
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    if node then
        node:setVisible(true)
        transition.moveBy(node, {y=-79, time=0.2})
        CSResourceMgr.clickEventBinding(resNameTop, "close", function()
            callback()
        end)
    end
end

local function hideTopInfoBar()
    local node = CSResourceMgr.getNodeByName(resNameTop, "up")
    if node then
        transition.moveBy(node, {y=79, time=0.1})
        node:setVisible(false)
        CSResourceMgr.removeCSObjectByTag(resNameTop)
    end
end

local function hideUI()
   
    UnblockLoader.cancel("AuctionMgrNew.show")
    UnblockLoader.cancel("AuctionMgrNew.setTab1")
    UnblockLoader.cancel("AuctionMgrNew.setTab2")  
    HighPerformList.resetAllSchedule()  
    --CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list1"):removeAllItems()
    --CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list2"):removeAllItems()
    --CSResourceMgr.getNodeByName(resNameAuctionMgrNew, "list3"):removeAllItems()
    CSResourceMgr.removeList(resNameAuctionMgrNew, "list1")
    CSResourceMgr.removeList(resNameAuctionMgrNew, "list2")
    CSResourceMgr.removeList(resNameAuctionMgrNew, "list3")
    CSResourceMgr.removeCSObjectByTag(resNameAuctionMgrNew)
    CSResourceMgr.removeCSObjectByTag(resNameBg,"AuctionMgrNewBg")
    CSResourceMgr.removeCSObjectByTag(resName,"AuctionMgrNewBagView")
    hideTopInfoBar()
    GameAudio.playUISound("retract")
    SceneMgr.setMapVisible(true)
    currentFirstTab = 1
    currentFilterIndex = 1
    currentSecondTab = 1
    lastSelItem = nil
end



---改变Tab的样式
--@param type int tab按钮类型 1-first 2-second
--@param tabindex 却换得序号 
--@param beSel bool 是否是选中状态
local function changeTabStyleByIndex(type,tabindex,beSel)
    local strcolor
    local stroutline
    local tabcelltable
    local tabtextarray
    if beSel then --如果被选中
        if tabindex == 1 then 
            if type ==1 then  
                strcolor = fontInfo.btn_tab1.font_color_sel
                stroutline = fontInfo.btn_tab1.outline_color_sel
            else
                strcolor = fontInfo.btn_tab11.font_color_sel
                stroutline = fontInfo.btn_tab11.outline_color_sel               
            end

        end

        if tabindex == 2 then  
            if type == 1 then
                strcolor = fontInfo.btn_tab2.font_color_sel
                stroutline = fontInfo.btn_tab2.outline_color_sel
            else
                strcolor = fontInfo.btn_tab12.font_color_sel
                stroutline = fontInfo.btn_tab12.outline_color_sel
            end
        end
    
    
        if tabindex == 3 then  
            if type == 1 then
                strcolor = fontInfo.btn_tab3.font_color_sel
                stroutline = fontInfo.btn_tab3.outline_color_sel
            else
                strcolor = fontInfo.btn_tab13.font_color_sel
                stroutline = fontInfo.btn_tab13.outline_color_sel               
            end
        end
        
        if tabindex == 4 then
        
            if type == 1 then
                strcolor = fontInfo.btn_tab4.font_color_sel
                stroutline = fontInfo.btn_tab4.outline_color_sel           
            else
                strcolor = fontInfo.btn_tab14.font_color_sel
                stroutline = fontInfo.btn_tab14.outline_color_sel              
            end

            
        end
        
        if type == 1 then
            --firstTabCellTable[tabindex]:setPositionY(firstTabOriginY+6)
            tabcelltable = firstTabCellTable
            tabtextarray = firstTabTextArray
        end
        
        if type == 2 then
            secondTabCellTable[tabindex]:setPositionY(secondTabOriginY+6)
            tabcelltable = secondTabCellTable
            tabtextarray = secondTabTextArray
        end
        
        
        
    else
        if tabindex == 1 then  
            if type == 1 then
                strcolor = fontInfo.btn_tab1.font_color
                stroutline = fontInfo.btn_tab1.outline_color
            else
                strcolor = fontInfo.btn_tab11.font_color
                stroutline = fontInfo.btn_tab11.outline_color
            end
        end

        if tabindex == 2 then 
            if type == 1 then 
                strcolor = fontInfo.btn_tab2.font_color
                stroutline = fontInfo.btn_tab2.outline_color
            else
                strcolor = fontInfo.btn_tab12.font_color
                stroutline = fontInfo.btn_tab12.outline_color               
            end
        end

        if tabindex == 3 then  
            if type == 1 then
                strcolor = fontInfo.btn_tab3.font_color
                stroutline = fontInfo.btn_tab3.outline_color
            else
                strcolor = fontInfo.btn_tab13.font_color
                stroutline = fontInfo.btn_tab13.outline_color                
            end
        end    

        if tabindex == 4 then
            if type == 1 then
                strcolor = fontInfo.btn_tab4.font_color
                stroutline = fontInfo.btn_tab4.outline_color    
            else
                strcolor = fontInfo.btn_tab14.font_color
                stroutline = fontInfo.btn_tab14.outline_color              
            end    
        end
        
        if type == 1 then
         
            firstTabCellTable[tabindex]:setPositionY(firstTabOriginY)
            tabtextarray = firstTabTextArray
            tabcelltable = firstTabCellTable
        end

        if type == 2 then
            
            secondTabCellTable[tabindex]:setPositionY(secondTabOriginY)
            tabtextarray = secondTabTextArray
            tabcelltable = secondTabCellTable
        end
    end
    
    
    CSResourceMgr.setButtonStringByNode(tabcelltable[tabindex],tabtextarray[tabindex],stroutline)
    CSResourceMgr.setButtonStringColorByNode(tabcelltable[tabindex],strcolor) 


    if currentFirstTab <4 then --逛滩 商会 商城
        --设置tab标签2
        for i=1,#secondTabCellTable do 
            secondTabCellTable[i]:setVisible(false)
        end
        
        for i=1,#SecondTabLabel[currentFirstTab] do
            print("SecondTabLabel[currentFirstTab]:"..i,SecondTabLabel[currentFirstTab][i])
            secondTabCellTable[i]:setVisible(true)
            CSResourceMgr.setButtonStringByNode(secondTabCellTable[i],SecondTabLabel[currentFirstTab][i])            
        end
    end

       

   


    
end


--设置tab切换的基础数据
local function setTabChangeData(type,tabindex)
    if type == 1 then
        currentFirstTab = tabindex
        currentSecondTab = 1
    else
        currentSecondTab = tabindex
    end
   
end

local function updateCashNum()
--[[
    local cashType = tabCoinArray[currentFirstTab]
    local cashNum = 0
    if cashType == coinTypeEnum.GoldenCoin then
        cashNum = CharInfo.getSilverCash()
    end
    
    if cashType == coinTypeEnum.MCoin then
        cashNum = CharInfo.getMCash()
    end
    
    if cashType == coinTypeEnum.SilverCoint then
        cashNum = CharInfo.getSilverCash()
        
    end
    
    if cashNum == nil then cashNum = 0 end
    
    local silvercoin = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"txt_silvernum")
    setLabel(silvercoin,tostring(cashNum),fontInfo.txt_silvernum.outline_color,fontInfo.txt_silvernum.outline_width,fontInfo.txt_silvernum.font_color)    

    local silveradd = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_silveradd")
    CSResourceMgr.setButtonTextureByNode(silveradd,coinTextureBottom[cashType].texture,coinTextureBottom[cashType].texture,coinTextureBottom[cashType].texture)
    silveradd:setScale(coinTextureBottom[cashType].scale) 
]]
    local silverCash = CharInfo.getSilverCash()
    if silverCash == nil then silverCash = 0 end
    CSResourceMgr.setLabelString(resNameTop, "hpoint", silverCash, "", nil, -1)
    CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1,100)
    CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1,100)
end

local function onTabUIChange(type,tabindex)
    --GameAudio.playUISound("sheetClick")
    local function setTabCellStyle(tabCellTable,tabindex,tabtype)
        for i = 1 ,#tabCellTable do
            if tabindex == i then 
                CSResourceMgr.setButtonEnabledByNode(tabCellTable[tabindex],false) 
                changeTabStyleByIndex(tabtype,tabindex,true)
                if tabtype == 1 then
                    tabCellTable[tabindex]:setScale(1.2)
                    tabCellTable[tabindex]:setLocalZOrder(2)         
                end
            else
                CSResourceMgr.setButtonEnabledByNode(tabCellTable[i],true) 
                changeTabStyleByIndex(tabtype,i,false)
                
                if tabtype == 1 then
                    tabCellTable[i]:setScale(1.0)  
                    tabCellTable[i]:setLocalZOrder(1) 
                end
            end
        end    
    end
    
    
    local tabCellTable;
    if type ==1 then 
        --currentFirstTab = tabindex
        
        tabCellTable = secondTabCellTable
        setTabCellStyle(tabCellTable,currentSecondTab,2)  
        
        tabCellTable = firstTabCellTable
        setTabCellStyle(tabCellTable,tabindex,1)
     
        
        if tabindex == 1 then
            CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_search"):setVisible(true)
        else
            CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_search"):setVisible(false)       
        end
    else
        --currentSecondTab = tabindex
        tabCellTable = secondTabCellTable
        setTabCellStyle(tabCellTable,currentSecondTab,2)          
    end
    
    --[[
    for i = 1 ,#tabCellTable do
        if tabindex == i then 
            CSResourceMgr.setButtonEnabledByNode(tabCellTable[tabindex],false) 
            changeTabStyleByIndex(type,tabindex,true)
            if type == 1 then
                tabCellTable[tabindex]:setScale(1.2)
                tabCellTable[tabindex]:setLocalZOrder(2)         
            end
        else
            CSResourceMgr.setButtonEnabledByNode(tabCellTable[i],true) 
            changeTabStyleByIndex(type,i,false)
            
            if type == 1 then
                tabCellTable[i]:setScale(1.0)  
                tabCellTable[i]:setLocalZOrder(1) 
            end
        end
    end
    --]]
end





local function resetFilterBtn(type,curSecondTab)

    filterLabelMarket[curSecondTab] = {}
    print("firsttab,secondtab.."..currentFirstTab,curSecondTab)
    for i = 1,#filterLabel[currentFirstTab][curSecondTab] do
        table.insert(filterLabelMarket[curSecondTab],filterLabel[currentFirstTab][curSecondTab][i])  
        print("label text .." ..filterLabel[currentFirstTab][curSecondTab][i] )
    end

    
    if type == 1 then --上tab标签切换商会 商城 43 550
        currentFilterIndex = 1
        currentPageIndex = 0
        currentItemId = 0  
        local menunode = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_menunode") 
        menunode:removeAllChildren()    
        local i
        filterBtnTable[curSecondTab] = {} 
        
        for i = 1 ,#filterLabelMarket[curSecondTab] do 
            local btn = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_filter"):clone() 
            menunode:addChild(btn)
            btn:setPosition(43,550-70*(i-1)) 
            btn.selid = i
            if i == 1 then 
                CSResourceMgr.setButtonEnabledByNode(btn,false)  
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color_sel)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color_sel)   
            else
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color)           
            end
            table.insert(filterBtnTable[curSecondTab],btn)


            CSResourceMgr.clickEventBindingByNode(btn,function() 
                --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE == 3 then
                    transition.scaleTo(btn, {scale = 1.2, time = 0.05})
                    btn:performWithDelay(function()
                        transition.scaleTo(btn, {scale = 1, time = 0.05})
                    end,0.05)
                end
                --GameAudio.playUISound("sheetClick")
                CSResourceMgr.setButtonEnabledByNode(filterBtnTable[curSecondTab][currentFilterIndex],true)
                CSResourceMgr.setButtonStringByNode(filterBtnTable[curSecondTab][currentFilterIndex],filterLabelMarket[curSecondTab][currentFilterIndex],fontInfo.btn_filter.outline_color)
                CSResourceMgr.setButtonStringColorByNode(filterBtnTable[curSecondTab][currentFilterIndex],fontInfo.btn_filter.font_color) 
                currentFilterIndex = btn.selid
                CSResourceMgr.setButtonEnabledByNode(btn,false)
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color_sel)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color_sel)  
                currentPageIndex = 0
                currentItemId = 0
                resetListPageNum()
                loadCurrentMarketList(currentPageIndex,currentFilterIndex)
                --loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType,currentItemId)
            end,LuaSqlite.LANG_TYPE ~= 3 and 1 or nil)


        end
    end
    
    if type == 2 then -- 逛街标签切换
       currentFilterIndex = 1
       currentPageIndex = 0
       currentItemId = 0
       local menunode = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_menunode") 
       menunode:removeAllChildren()
       local i
       filterBtnTable[curSecondTab] = {}

       for i = 1 ,#filterLabelMarket[curSecondTab] do 
           local btn = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_filter"):clone() 
           menunode:addChild(btn)
           btn:setPosition(43,550-70*(i-1)) 
           btn.selid = i
           if i == 1 then 
                CSResourceMgr.setButtonEnabledByNode(btn,false)  
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color_sel)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color_sel) 
           else
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color)  
           end
           table.insert(filterBtnTable[curSecondTab],btn)

            
            CSResourceMgr.clickEventBindingByNode(btn,function() 
                --阿杜修改英文版显示
                if LuaSqlite.LANG_TYPE == 3 then
                    transition.scaleTo(btn, {scale = 1.2, time = 0.05})
                    btn:performWithDelay(function()
                        transition.scaleTo(btn, {scale = 1, time = 0.05})
                    end,0.05)
                end
               -- GameAudio.playUISound("sheetClick")
                CSResourceMgr.setButtonEnabledByNode(filterBtnTable[curSecondTab][currentFilterIndex],true)
                CSResourceMgr.setButtonStringByNode(filterBtnTable[curSecondTab][currentFilterIndex],filterLabelMarket[curSecondTab][currentFilterIndex],fontInfo.btn_filter.outline_color)
                CSResourceMgr.setButtonStringColorByNode(filterBtnTable[curSecondTab][currentFilterIndex],fontInfo.btn_filter.font_color)
                currentFilterIndex = btn.selid
                CSResourceMgr.setButtonEnabledByNode(btn,false)
                CSResourceMgr.setButtonStringByNode(btn,filterLabelMarket[curSecondTab][i],fontInfo.btn_filter.outline_color_sel)
                CSResourceMgr.setButtonStringColorByNode(btn,fontInfo.btn_filter.font_color_sel) 
                currentPageIndex = 0
                currentItemId = 0
                resetListPageNum()
                loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType,currentItemId)
            end,LuaSqlite.LANG_TYPE ~= 3 and 1 or nil)
            
           
       end
    end
end



local function resetTabCellTable()
    firstTabCellTable = {}
    secondTabCellTable = {}
    
    local tab1 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab1") 
    local tab2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab2") 
    local tab3 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab3")
    local tab4 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab4")

    table.insert(firstTabCellTable,tab1)
    table.insert(firstTabCellTable,tab2)
    table.insert(firstTabCellTable,tab3)
    table.insert(firstTabCellTable,tab4)
    
    local tab11 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab11") 
    local tab12 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab12") 
    local tab13 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab13")  
    local tab14 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_tab14")  

    table.insert(secondTabCellTable,tab11)
    table.insert(secondTabCellTable,tab12)
    table.insert(secondTabCellTable,tab13)   
    table.insert(secondTabCellTable,tab14)

    currentFirstTab = 1
    currentSecondTab = 1

    local function sendItemTestReq()
        local sellSend = require("src.Net.Send.MarketSend")
        local data = {itemID = 31001,objID = 0,sellNum = 1,unitPrice = 10}
        sellSend.sendCG_SellOnMarket_Req(data)
        
        local data = {itemID = 31002,objID = 0,sellNum = 1,unitPrice = 20}
        sellSend.sendCG_SellOnMarket_Req(data)
        
        local data = {itemID = 31003,objID = 0,sellNum = 1,unitPrice = 30}
        sellSend.sendCG_SellOnMarket_Req(data)
    end
    
    local function sendBuyProductReq()
        local buySend =require("src.Net.Send.MarketSend")
        local data = {productID = 1,num =1}
        buySend.sendCG_BuyProduct_Req(data)
    end
    
    local function getMyMarket()
        local mymarketSend = require("src.Net.Send.MarketSend")
        mymarketSend.sendCG_GetMyMarket_Req()
    end
    
    local function DelMyMarketReq()
        local delSend =require("src.Net.Send.MarketSend")
        local data = {productID = 2}
        delSend.sendCG_DelMyProduct_Req(data)     
    end
    
    local function searchMarketReq()
        local sellSend = require("src.Net.Send.MarketSend")
        local data = {itemID = 31002,itemSubType = 1,itemType = 22,startIndex =0, searchNum = 6,sortType = 1 } --0 name sort 1 price sort
        sellSend.sendCG_SearchProducts_Req(data)
    end
    

    
    local part1 =  CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_part1_menu")
    local part2 = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"pic_part2_menu")
    
    CSResourceMgr.clickEventBindingByNode(tab1,function() --[[resetListCellTable(drawingInfo[1],1)]]
        part1:setVisible(true)
        part2:setVisible(false)
        
        setTabChangeData(1,1)
        resetFilterBtn(2,currentSecondTab)  
        onTabUIChange(1,1) 
        resetListPageNum() 
        loadCurrentAuctionList(currentPageIndex,currentFilterIndex)
        updateCashNum()
        end)
    CSResourceMgr.clickEventBindingByNode(tab2,function() --[[resetListCellTable(drawingInfo[2],2)]] onTabUIChange(1,2)  
        part1:setVisible(true)
        part2:setVisible(false)
      
        setTabChangeData(1,2)
        resetFilterBtn(1,currentSecondTab) 
        onTabUIChange(1,2) 
        resetListPageNum() 
        loadCurrentMarketList(currentPageIndex,currentFilterIndex)
        updateCashNum()
    end)
    CSResourceMgr.clickEventBindingByNode(tab3,function() --[[resetListCellTable(drawingInfo[3],3)]] onTabUIChange(1,3)   
    
        part1:setVisible(true)
        part2:setVisible(false)
        
        setTabChangeData(1,3)
        resetFilterBtn(1,currentSecondTab)  
        onTabUIChange(1,3) 
        resetListPageNum() 
        loadCurrentMarketList(currentPageIndex,currentFilterIndex)
        updateCashNum()
    end)
    CSResourceMgr.clickEventBindingByNode(tab4,function() --[[resetListCellTable(drawingInfo[3],3)]] onTabUIChange(1,4)   

       part1:setVisible(false)
       part2:setVisible(true)
       UnblockLoader.cancel("AuctionMgrNewBag-reset")
       resetMyBagList()
       updateCashNum()
       loadMyAuctionList()
    end)  
    
    CSResourceMgr.clickEventBindingByNode(tab11,function() 
        
        setTabChangeData(2,1)
      
        if currentFirstTab ==1 then
            resetFilterBtn(2,currentSecondTab) 
        else
            resetFilterBtn(1,currentSecondTab)            
        end  
        onTabUIChange(2,1) 
 

        resetListPageNum() 
        if currentFirstTab ==1 then --玩家交易
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentItemId) 
        else --系统商城
            loadCurrentMarketList(currentPageIndex,currentFilterIndex)        
        end
    end)
        
        
    CSResourceMgr.clickEventBindingByNode(tab12,function()   
        
        setTabChangeData(2,2)
        if currentFirstTab ==1 then
            resetFilterBtn(2,currentSecondTab) 
        else
            resetFilterBtn(1,currentSecondTab)            
        end          
        onTabUIChange(2,2) 


        resetListPageNum()  
        if currentFirstTab ==1 then --玩家交易
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentItemId) 
        else --系统商城
            loadCurrentMarketList(currentPageIndex,currentFilterIndex)        
        end
    end)
    
    
    CSResourceMgr.clickEventBindingByNode(tab13,function()  
    
        setTabChangeData(2,3) 
        if currentFirstTab ==1 then
            resetFilterBtn(2,currentSecondTab) 
        else
          resetFilterBtn(1,currentSecondTab)            
        end  
        onTabUIChange(2,3) 
        resetListPageNum()  
        if currentFirstTab ==1 then --玩家交易
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentItemId) 
        else --系统商城
            loadCurrentMarketList(currentPageIndex,currentFilterIndex)        
        end  
    end)
    
    CSResourceMgr.clickEventBindingByNode(tab14,function()  

            setTabChangeData(2,4) 
            if currentFirstTab ==1 then
                resetFilterBtn(2,currentSecondTab) 
            else
                resetFilterBtn(1,currentSecondTab)            
            end  
            onTabUIChange(2,4) 
            resetListPageNum()  
            if currentFirstTab ==1 then --玩家交易
                loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentItemId) 
            else --系统商城
                loadCurrentMarketList(currentPageIndex,currentFilterIndex)        
            end  
    end)
      
    onTabUIChange(1,currentFirstTab)
    onTabUIChange(2,currentSecondTab)
     
end

local function buttonBinding()

    --local sortname = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortname")
    local sortprice = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortprice")
    local sortpricearrow = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortpricearrow")
    --[[
    CSResourceMgr.clickEventBindingByNode(sortname,function()
        currentPageIndex = 0
        currentSortType = 0
        resetListPageNum()
        if currentFirstTab == 1 then --逛摊 
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType)
        else
            loadCurrentMarketList(currentPageIndex,currentFilterIndex,currentSortType)
        end
        --CSResourceMgr.setButtonEnabledByNode(sortname,false)
        --CSResourceMgr.setButtonEnabledByNode(sortprice,true)
    end
    )
    ]]
    
    CSResourceMgr.clickEventBindingByNode(sortprice,function()
        currentPageIndex = 0
        currentSortType = 1
        resetListPageNum()
        if currentFirstTab == 1 then --逛摊 
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType)
        else
            loadCurrentMarketList(currentPageIndex,currentFilterIndex,currentSortType)
        end
       -- CSResourceMgr.setButtonEnabledByNode(sortname,true)
        --CSResourceMgr.setButtonEnabledByNode(sortprice,false)
    end
    ) 
    
    CSResourceMgr.clickEventBindingByNode(sortpricearrow,function()
        currentPageIndex = 0
        currentSortType = 1
        resetListPageNum()
        if currentFirstTab == 1 then --逛摊 
            loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType)
        else
            loadCurrentMarketList(currentPageIndex,currentFilterIndex,currentSortType)
        end
       -- CSResourceMgr.setButtonEnabledByNode(sortname,true)
        --CSResourceMgr.setButtonEnabledByNode(sortprice,false)
    end
    )     
    
    
    
    CSResourceMgr.clickEventBinding(resNameAuctionMgrNew,"btn_search",
    
    function()
        local itemType = typeNumber[currentSecondTab][currentFilterIndex].itemType
            local itemSubType = typeNumber[currentSecondTab][currentFilterIndex].itemSubType
            AuctionSearch.show(SceneMgr.getRunningScene,itemType,itemSubType)
    end,nil,3)
    
    
    --顶部通用条功能
    --[[
    CSResourceMgr.buttonEventBinding(resNameTop, "add_hpoint", function()
        ExchangeViewMgr.show(scene,ExchangeViewMgr.POWERTYPE)
    end)
    ]]
    CSResourceMgr.clickEventBinding(resNameTop, "add_gcoin", function()
        ExchangeViewMgr.show(SceneMgr.getRunningScene,ExchangeViewMgr.GCASHTYPE)
    end)
    CSResourceMgr.clickEventBinding(resNameTop, "add_mcoin", function()
        PurchaseViewMgr.show(SceneMgr.getRunningScene,AuctionMgrNew.hide)
    end)
    
end



local function addUI(scene)

    if CSResourceMgr.getCsbObj(resNameAuctionMgrNew) then
        return  
    end
    local bgUI = CSResourceMgr.createRes(scene,resNameBg ,"AuctionMgrNewBg")
    local csb = CSResourceMgr.createRes(scene,resNameAuctionMgrNew)
  
    CSResourceMgr.createRes(scene,resName,"AuctionMgrNewBagView")
    local function loadBG()
  
        bgUI:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameBg, 320, 480,"AuctionMgrNewBg")
    end
    
    
    local function loadCSB()
        currentPageIndex = 0
        local top = CSResourceMgr.createRes(scene, resNameTop)
        top:setLocalZOrder(CocosModuleMgr.ZORDER_FLOAT)
        CocosModuleMgr.setEdgeDistance(top, 0, nil, 0, nil)
    
        local silverCash = CharInfo.getSilverCash()
        if silverCash == nil then silverCash = 0 end
        CSResourceMgr.setLabelString(resNameTop, "hpoint", silverCash, "", nil, -1)
        CSResourceMgr.setLabelString(resNameTop, "gcoin", CharInfo.getGCash(), "", nil, -1,100)
        CSResourceMgr.setLabelString(resNameTop, "mcoin", CharInfo.getMCash(), "", nil, -1,100)
        CSResourceMgr.setLabelColor(resNameTop, "hpoint", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "gcoin", {r=190,g=221,b=245,a=255})
        CSResourceMgr.setLabelColor(resNameTop, "mcoin", {r=190,g=221,b=245,a=255})
        CSResourceMgr.getNodeByName(resNameTop, "up"):setVisible(false)

        csb:setLocalZOrder(CocosModuleMgr.ZORDER_WINDOW)
        CSResourceMgr.setRelativePosition(resNameAuctionMgrNew, 320, 480) 
 
        csb:setVisible(false)
       


        resize()
        initUIBasedata()
        resetTabCellTable()
        
        loadCurrentAuctionList(0,currentFilterIndex)
        --resetListCell(sellItemDataList[currentSecondTab])
        resetFilterBtn(2,currentSecondTab)
        --close按钮绑定
        CSResourceMgr.clickEventBinding(resNameAuctionMgrNew,"close",function()
            AuctionMgrNew.hide()
            --hideUI()
			--GameGuideMgr.checkProcessInTown()
        end)
    end    
    
    local function playCSB()
    
        CSResourceMgr.getCsbObj(resNameAuctionMgrNew):setVisible(true)
        CocosModuleMgr.showUIAnimation(CSResourceMgr.getCsbObj(resNameAuctionMgrNew), "up", function()
            end)
            
        showTopInfoBar(function()
            AuctionMgrNew.hide()
        --hideUI() 
        
        end)

    end
   
   
   if useunblockloader then
        --loadBG()
        --loadCSB()
        --playCSB()
        --buttonBinding()
        local funcTable = {loadBG,loadCSB,playCSB,buttonBinding}
        UnblockLoader.load(funcTable, "AuctionMgrNew.show")
   
   else
        loadBG()
        loadCSB()
        playCSB()
        buttonBinding()
   end 
   

   
   SceneMgr.setMapVisible(false)
end




---------------------------------我是分割线------------------------------------


function AuctionMgrNew.request(scene)
    
    local openlevel = SystemInfo.getGlobalConfigAddInfoByID(24006).values[1]
    if CharInfo.getLevel() < openlevel then 
        StandardTipsMgr.show(1,trans_notopen)
        return
    end
    
    --这段不需要了
    --[[2016-08-10
   if not NetInterface.isConnect then
        StandardTipsMgr.show(1,"无可用网络")
        return
    end
    ]]
    --添加生活技能请求
    --这段不需要了，因为不与生活技能挂钩了
    --[[2016-08-10
    NetInterface.sendWithBlock("GC_GetLifeSkillData_Ack",function() 
        local lifeSkillSend =  require("src.Net.Send.LifeSkillSend")
        lifeSkillSend.sendCG_GetLifeSkillData_Req()
    end,function() 
        local data = CharInfo.getLifeSkillInfo()
        local cjson = require("cjson")
        lifeSkillInfo = cjson.decode(data)


    end,

    function(code) 
        TipsMgr.showError(scene, code) 
    end)
    ]]
    AuctionMgrNew.show(scene)

    --这段不需要了，因为银币应该已经取到了
    --[[2016-08-10
    if isRequested then
        AuctionMgrNew.show(scene)
    else
        NetInterface.sendWithBlock("GC_GetCharacterValues_Ack", function()
            local LoginSend = require("src.Net.Send.LoginSend")
            LoginSend.sendCG_GetCharacterValues_Req({"goldCoin"}) --petPacketNum
        end, function()
            isRequested = true
            AuctionMgrNew.show(scene)
            --addUI(scene)
            --loadMyAuctionList()
        end, function(code)
            TipsMgr.showError(scene, code)
        end)
        

    end
    ]]
end

---刷新
--@param type int 1-玩家出售 2-我的出售 3-商会、商城
function AuctionMgrNew.refresh(type,refreshdata)
    if type == 1 then   loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType,currentItemId,currentSelectId) end
    if type == 2 then 
        loadMyAuctionList() 
        if refreshdata~=nil then
            AuctionMgrNew.__refreshAuctionBag(refreshdata)
        else 
            --resetMyBagList() 
        end
   
    end
    
    if type == 3 then 
        --loadCurrentAuctionList(currentPageIndex,currentFilterIndex,currentSortType,currentItemId)
        --loadMyAuctionList()
        loadCurrentMarketList(currentPageIndex,currentFilterIndex,currentSortType)
    end
    
    updateCashNum()
end


function AuctionMgrNew.Init()
    resNameAuctionMgrNew =  "Item/Auction/AuctionMainView.csb" 
    --resNameBg = "Map/IdlingMap/SelectBG.csb"
    resNameBg = "Pet/Formation/FormationBGNew.csb"
    resName = "Item/Bag/BagView.csb"
    resNameTop = "Charactor/TopInfoLayerSilverCoin.csb"
    isRequested = false
    if isTxtInited==false then
        readConfigTxt()
    	isTxtInited = true
    end
    
    lastSelItem = nil

    auctionBagInfo = {}
end

function AuctionMgrNew.show(scene)
    UIStack.push("AuctionMgrNew",AuctionMgrNew.hide,true)
    addUI(scene)
    loadMyAuctionList()

end

function AuctionMgrNew.onRecvSearchProductsAck(products)
    sellItemDataList[currentSecondTab] = {}
    --print("products count:" ..#products)
    for i = 1,#products do
        print("products.........."..products[i])
        local cjson = require("cjson")    
        local data = cjson.decode(products[i])
        table.insert(sellItemDataList[currentSecondTab],data)
    end

end

function AuctionMgrNew.onRecvGetMyMarketAck(products)

    myItemDataList = {}
    print("products count:" ..#products)  
    for i = 1,#products do 
        print("GetMyMarket products.........."..products[i]) 
        local cjson = require("cjson")
        local data = cjson.decode(products[i])
        table.insert(myItemDataList,data)          
    end    
  
end

function AuctionMgrNew.getMySellItemLst()

    return myItemDataList
end

function AuctionMgrNew.getSearchLabeleLst(keystr)
    print("keystr and count "..keystr)
    local labelLst={}
    for i=1,#shopMarketTypeTable[keystr] do
        table.insert(labelLst,shopMarketTypeTable[keystr][i][1])
    end
    
    return labelLst
end

function AuctionMgrNew.sendSearchRequest(itemid,selectid)
    loadCurrentAuctionList(0,currentFilterIndex,currentSortType,itemid,selectid)
end

function AuctionMgrNew.setSortBtnState(namestate,pricestate)
    local sortname = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortname")
    local sortprice = CSResourceMgr.getNodeByName(resNameAuctionMgrNew,"btn_sortprice")        
    
    CSResourceMgr.setButtonEnabledByNode(sortname,namestate)
    CSResourceMgr.setButtonEnabledByNode(sortprice,pricestate)
    
end

function AuctionMgrNew.hide()
    hideUI()
    GameGuideMgr.checkProcessInTown()
    UIStack.pop("AuctionMgrNew")
end

function AuctionMgrNew.changeVisible(visible)

    CSResourceMgr.getCsbObj(resNameAuctionMgrNew):setVisible(visible)
    CSResourceMgr.getCsbObj(resNameBg,"AuctionMgrNewBg"):setVisible(visible)
    CSResourceMgr.getCsbObj(resName,"AuctionMgrNewBagView"):setVisible(visible)
    CSResourceMgr.getCsbObj(resNameTop):setVisible(visible)   
end

function AuctionMgrNew.updateAuctionItem(itemid,isSkill)
    --print("AuctionMgrNew.updateAuctionItem itemid is.........."..itemid)
    
    local iteminfo = ItemInfo.getItemInfoById(itemid)
    if not iteminfo then
    	return
    end

    local itemtype = iteminfo.itemType
    local itemsubtype = iteminfo.itemTypeID
    local strkey = iteminfo.itemType.."-"..iteminfo.itemTypeID
    local itemtid = ItemInfo.getItemType(itemid)
    local charItemInfo = ItemInfo.getCharItemInfo()
    local skillBookInfo = ItemInfo.getSkillBookInfo()
    local var = nil
    if isSkill then 
        var = skillBookInfo[itemid]
    else
        var =  charItemInfo[itemid]
    end
    --如果var为nil的话，说明走的是宠物碎片，需要另外写代码。现在不支持出售宠物碎片
    if var == nil then auctionBagInfo[itemid] = nil return end
    --print("AuctionMgrNew.updateAuctionItem var is.........."..var)
    if type(var) ~= "number" then
        for objid,v in pairs(var) do
            print("itemtid is and key is:"..itemtid,key)
            if itemtid and marketItemTable[strkey] ~=nil then
                --prinitTab(v)
                if v.isBind ~=1 then -- 不绑定
                    if v.num <=0 then 
                        --auctionBagInfo[itemid] = nil
                    else
                        if auctionBagInfo[itemid] == nil then 
                            auctionBagInfo[itemid] = {itemid, v.num, v.isBind,{objid}}
                        else 
                            local isAlreadyHave = false
                            for i = 1,#auctionBagInfo[itemid][4] do 
                                if auctionBagInfo[itemid][4][i] == objid then 
                                    isAlreadyHave = true
                                    break
                                end
                            end
                            if isAlreadyHave == false then 
                                table.insert(auctionBagInfo[itemid][4],objid)
                                auctionBagInfo[itemid][2] = auctionBagInfo[itemid][2]+1
                            end
                        end
                        
                    end
                    --table.insert(auctionBagInfo, {itemid, v.num, v.isBind,objid})
                end
            end
        end
    else
        
        if itemtid and  marketItemTable[strkey] ~=nil then
            --table.insert(auctionBagInfo, {itemid, var})
            if var <= 0 then 
                auctionBagInfo[itemid] = nil
            else
               auctionBagInfo[itemid] = {itemid, var}
            end
        end
    end
end

--private
function AuctionMgrNew.__refreshAuctionBag(itemdata)
    if auctionBagInfo[itemdata.itemid]~=nil then 
        if itemdata.objID~=nil and itemdata.objID~=0 then 
            print("itemdata.objID i s ..........",itemdata.objID)
            for i = 1,#auctionBagInfo[itemdata.itemid][4] do
                print("auctionBagInfo[itemdata.itemid][4][i],itemdata.objID is........",auctionBagInfo[itemdata.itemid][4][i],itemdata.objID )
                if auctionBagInfo[itemdata.itemid][4][i] == itemdata.objID then 
                    table.remove(auctionBagInfo[itemdata.itemid][4],i)
                    auctionBagInfo[itemdata.itemid][2] = auctionBagInfo[itemdata.itemid][2]-1
                    print("auctionBagInfo[itemdata.itemid][2]  is ....................." ..auctionBagInfo[itemdata.itemid][2])
                    if #auctionBagInfo[itemdata.itemid][4]<=0 then 
                        auctionBagInfo[itemdata.itemid] = nil
                    end
                    break
                end
            end
        end
        local oldnum = itemdata.oldnum
        local nownum = oldnum - itemdata.num
        print("oldnum is ...........,nownum is....,itemdata.num"..oldnum,nownum,itemdata.num) 
        if nownum <=0 then 
            itemdata.oldnum = 0

            if itemdata.iconbutton~=nil  then 
                local sprite = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "s")
                sprite:setColor({r=77,g=77,b=77})
                local label = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "l")
                CSResourceMgr.setLabelStringByNode(label, "0", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
                CSResourceMgr.setButtonEnabledByNode(itemdata.iconbutton[1],false)
                itemdata.iconbutton[2][2] = 0
            end
            if itemdata.objID==nil then
                auctionBagInfo[itemdata.itemid] = nil
            end
        else
            auctionBagInfo[itemdata.itemid][2] = nownum
            local label = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "l")
                CSResourceMgr.setLabelStringByNode(label, tostring(nownum), CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
            itemdata.iconbutton[2][2] = nownum
        end
    else
        local nownum = 0
        local oldnum = itemdata.oldnum
        nownum = oldnum - itemdata.num
        if nownum<=0 then nownum = 0 end
        print("else oldnum is ...........,nownum is....,itemdata.num"..oldnum,nownum,itemdata.num) 
        if itemdata.iconbutton~=nil then 
            if nownum <1 then 
                local sprite = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "s")
                sprite:setColor({r=77,g=77,b=77})
                local label = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "l")
                CSResourceMgr.setLabelStringByNode(label, "0", CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
                CSResourceMgr.setButtonEnabledByNode(itemdata.iconbutton[1],false)
                itemdata.iconbutton[2][2] = nownum
            else 
                local label = CSResourceMgr.seekNodeByName(itemdata.iconbutton[1], "l")
                    CSResourceMgr.setLabelStringByNode(label, tostring(nownum), CSResourceMgr.DEFAULT_LABEL_OUTLINE_PARAMS, nil, 120)
                itemdata.iconbutton[2][2] = nownum                
            end
        end       
    end

end

return AuctionMgrNew