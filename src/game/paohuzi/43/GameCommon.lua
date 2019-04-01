local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Common = require("common.Common")
local UserData = require("app.user.UserData")
local Bit = require("common.Bit")
local LocationSystem = require("common.LocationSystem")

local GameCommon = {
    -------------------------------------------------------------------------------
    --宏定义
    --动作定义
    ACK_NULL                    =0x0,                                   --空
    ACK_TI                      =0x1,                                   --提
    ACK_PAO                     =0x2,                                   --跑
    ACK_WEI                     =0x4,                                   --偎
    ACK_WD                      =0x8,                                   --王钓
    ACK_WC                      =0x10,                                  --王闯
    ACK_CHI                     =0x20,                                  --吃
    ACK_CHI_EX                  =0x40,                                  --吃
    ACK_PENG                    =0x80,                                  --碰
    ACK_CHIHU                   =0x100,                                 --胡
    ACK_BIHU				    =0x200,						           --必胡
    bFangPao                    = 1,                                   --0不能放跑  1能放炮
    
    PHZ_RULE_FANXING                    =0x0001,                     --回放翻省
    PHZ_RULE_GENXING                    =0x0002,                     --回放跟省
    PHZ_ALL_ACK                         =0xFFFFF,                    --公共比较
    --吃牌类型
    CK_NULL = 0,         --无效类型
    CK_XXD = 1,          --小小大搭
    CK_XDD = 2,          --小大大搭
    CK_EQS = 4,          --二七十吃
    CK_LEFT = 16,        --靠左对齐
    CK_CENTER = 32,      --居中对齐
    CK_RIGHT = 64,       --靠右对齐
    CK_YWS	=128,		--一五十吃
    --数值定义
    MAX_WEAVE = 7,       --最大组合
    MAX_INDEX = 20,      --最大索引
    MAX_COUNT = 21,      --最大数目
    MASK_COLOR = 240,    --花色掩码
    MASK_VALUE = 15,     --数值掩码
    --主要用于桌面显示
    ACK_CHOUWEI = 5,     --臭偎
    --牌间隔
    CARD_HUXI_HEIGHT = 40,
    CARD_HUXI_WIDTH = 40,
    CARD_COM_HEIGHT = 226,
    CARD_COM_WIDTH = 76,
    --游戏结束开始时间
    Game_end_time = 25.0,
    
    GameView_updataHuxi = 1,        --跟新胡息
    GameView_updataHardCard = 2,    --跟新手牌
    GameView_showOutCardTips = 3,   --显示出牌提示
    GameView_closeOutCardTips = 4,  --关闭出牌提示
    GameView_BegainMsg = 5,         --开始处理消息
    GameView_endMsg = 6,            --处理完消息了
    GameView_UpOpration = 7,        --更新操作超时
    GameView_OutOpration = 8,       --操作超时
    
    GameView_GamePaly=9,            --游戏装备

    ACTION_TIP = 1,                 --提示动作
    ACTION_TI_CARD = 2,             --提牌动作
    ACTION_PAO_CARD = 3,            --跑牌动作
    ACTION_WEI_CARD = 4,            --偎牌动作
    ACTION_PENG_CARD = 5,           --碰牌动作
    ACTION_HU_CARD = 6,             --胡牌动作
    ACTION_CHI_CARD = 7,            --吃牌动作
    ACTION_OUT_CARD = 8,            --出牌动作
    ACTION_SEND_CARD = 9,           --发牌动作
    ACTION_OPERATE_NOTIFY = 10,     --发牌动作
    ACTION_OUT_CARD_NOTIFY = 11,    --发牌动作
    ACTION_FANG_CARD = 12,          --翻省动作
    ACTION_VIEW_CARD = 13,          --表现动作
    ACTION_HUANG = 14,              --黄庄动作
    ACTION_WD = 15,                 --王钓动作
    ACTION_WC = 16,                 --王闯动作
    ACTION_3WC = 116,               --三王闯动作
    ACTION_SISHOU = 17,             --死守动作
    ACTION_WPei = 18,               --有王赔钱动作
    ACTION_ADDBASE=19,          --加倍动作
    ACTION_SHOW_CARD = 20,          --亮手牌
    
    Animition_chi = 0,          --吃
    Animition_peng = 1,         --碰
    Animition_hu = 2,           --胡
    Animition_ti = 3,           --提
    Animition_pao = 4,          --跑
    Animition_wei = 5,           --偎
    Animition_chouwei = 6,      --臭偎
    Animition_bi = 7,           --比
    Animition_wd = 8,           --王钓
    Animition_sishou = 9,       --死守
    Animition_wc = 10,          --王闯
    Animition_3wc = 110,        --三王闯
    Animition_fang = 11,        --翻省    
    Animition_Huang = 12,       --黄庄
    Animition_wpei = 13,        --王霸赔钱
    
    Animition_qing = 14,        --提变倾
    Animition_xiao = 15,        --偎变啸
    Animition_chouxiao = 16,    --臭啸
    Animition_xiahuo = 17,      --比变下火
    Animition_xiabi = 35,      --比变下比 （吃一个放一个）
    Animition_fangpao = 18,     --放炮
    --字牌变化
    Animition_sao = 19,         --煨变扫
    Animition_guosao = 20,      --臭喂变过扫
    Animition_saoquang = 21,    --提变扫穿
    Animition_tuo = 22,         --跑变开拓  
    
    Animition_addBase=23,       --加倍
    Animition_addBase_no=24,    --不加倍

    Animition_phz_pengshangd=25,--碰三大
    Animition_phz_pengsiq=26,       --碰四清

    Animition_phz_shaoshanp=27,     --扫三大
    Animition_phz_shaosiqing=28,      --扫四清

    Animition_phz_tilong=29,            --提龙
    Animition_phz_shuanglong=30,
    Animition_phz_xiaoqidui=31,
    Animition_phz_wufu=32,
    Animition_phz_tianhu=33,
    Animition_phz_dihu=34,

    Soundeffect_RunAction = 0,  --动作
    Soundeffect_RunCard = 1,    --卡牌
    Soundeffect_Huang = 2,      --黄庄
    Soundeffect_FangX = 3,      --翻省
    Soundeffect_getSz = 4,      --获取闪砖
    Soundeffect_getW = 5,       --摸到王牌
    
    timeAction_Null = 0,
    timeAction_OutCard = 1,
    timeAction_Opration = 2,
    CardData_WW = 33,
    
    leftalignment=1,
    centrealignment = 2,
    rightalignment = 3,
    
    CARDHEIGH = 90.0,
    CARDWIDTH = 95.0,
    BASEPOSITIONY = 55.0,
    BASEPOSITIONX = 50.0,
    
    ClientSockEvent_connectFaild = 1,                 --链接失败
    ClientSockEvent_connectError = 2,                 --网络错误
    ClientSockEvent_connectSucceed = 3,               --链接成功
    
    INVALID_TEAM = 65535,    --无效组号
    INVALID_TABLE = 65535,   --无效桌子
    INVALID_CHAIR = 65535,  
    INVALID_ID = 4294967295,
    Gamemode = {},                                     -- 游戏模式
    isfanxing = true,                             --true:翻省 ； false：跟省
    isGameEnd = false,                             -- true:游戏结束 ；false：游戏开始  （游戏预处理 ：控制解散好友房弹框）
    
    EARTH_RADIUS = 6371.004 ,                     --地球半径   
    -------------------------------------------------------------------------------
    meChairID = 0,
}

function GameCommon:init()
	    --数据
    self.regionSound = 0
    self.weiCardType = 0    --0明偎  1暗偎
    self.tiCardType = 0     --0明提  1暗提
    self.tagUserInfoList = {}
    self.wPlayerCount = 0
--    self.dwUserID = 0
    self.bIsMyTurn = false
    self.leftCardCount = 0
    self.cardStackWidth = 0
    self.handCardalignment = 0
    self.cbCardIndex = {}
    self.wBankerUser = -1
    self.bWeaveItemCount = {[1] = 0 , [2] = 0 , [3] = 0 , [4] = 0 }
    self.weaveItemArray = {}
    self.bUserCardCount = {}
    self.bellv = 0
--    self.meChairID = 0
    self.cbWWCout = 0
    self.cbWWCout_cb = {[1] = 0 , [2] = 0 , [3] = 0 }
    self.restart = false
    self.iscardcark = false
    self.wContinueWinCount = 0
    self.isFriendGameStart = false
    self.hostedTime = os.time()

    self.wBankerUser = 0
    self.bLeftCardCount = 0
    self.waitOutCardUser = nil
    self.isHosted = false
    
    self.GameState_Init = 0
    self.GameState_Start = 1
    self.GameState_Over = 2
    self.gameState = 0
end

function GameCommon:SwitchViewChairID(wChairID)
   -- print("游戏模式1",wChairID ,self.wPlayerCount,self:GetMeChairID())
    local index = wChairID + self.wPlayerCount - self:GetMeChairID()
    if self.wPlayerCount == 2 then
        index = index + 1
    elseif self.wPlayerCount == 3 then
        index = index + 1
    elseif self.wPlayerCount == 4 then
        index = index + 2
    elseif self.wPlayerCount == 5 then
        index = index + 2
    elseif self.wPlayerCount == 6 then
        index = index + 3
    elseif self.wPlayerCount == 7 then
        index = index + 3
    elseif self.wPlayerCount == 8 then
        index = index + 4
    end

    index = (self.wPlayerCount - 1) - index % self.wPlayerCount
    print("游戏模式2",index,self.wBankerUser,self.meChairID,wChairID)   
    return index
end

function GameCommon:GetMeChairID()
    for key, var in pairs(self.tagUserInfoList) do
        if var.dwUserID == self.dwUserID then
            return var.wChairID
        end
    end
    return self.meChairID
end

function GameCommon:getViewIDByChairID(wChairID)
    local location = 1          --主角位置
    local wPlayerCount = self.gameConfig.bPlayerCount      --玩家人数
    local meChairID = self:getRoleChairID()     --主角的座位号
    local viewID = (wChairID + location - meChairID)%wPlayerCount
    if viewID == 0 then
        viewID = wPlayerCount
    end
    return viewID
end

function GameCommon:getRoleChairID()
    return self.meChairID
end

function GameCommon:SwitchViewChairID_CF(wChairID)
    local index=nil
    if wChairID > self.meChairID then
        index =(wChairID-self:GetMeChairID()+1)%self.wPlayerCount
    elseif wChairID < self.meChairID then
        index =( self.wPlayerCount - self.meChairID + wChairID+1)%self.wPlayerCount
    elseif wChairID == self:GetMeChairID()then
        index = 1
    end
    return index
end
function GameCommon:GetCardNormal(data)
    local _spt = nil
    local str = ""
    if data == 0 then
        _spt = cc.Sprite:create("tszipai/card/cd_normalBG.png")
    elseif data==33 then
        _spt = cc.Sprite:create("tszipai/card/ww.png")
    elseif data <= 10 then
        str = string.format("tszipai/card/dx%d.png",data)
        _spt = cc.Sprite:create(str)
    elseif data > 10 then
        str = string.format("tszipai/card/dd%d.png",data - 16)
        _spt = cc.Sprite:create(str)
    else
    
    end
    return _spt
end

function GameCommon:palyCDActionSound(sex ,data)
    local Actionbuf = ""
    if data == self.Animition_chi then
        Actionbuf = "chi"
    elseif data == self.Animition_peng then
        Actionbuf = "peng"
    elseif data == self.Animition_hu then
        Actionbuf = "hu"
    elseif data == self.Animition_ti then
        Actionbuf = "ti"
    elseif data == self.Animition_pao then
        Actionbuf = "pao"
    elseif data == self.Animition_wei then
        Actionbuf = "wei"
    elseif data == self.Animition_bi then
        Actionbuf = "bi"
    elseif data == self.Animition_chouwei then
        Actionbuf = "chouwei"
    elseif data == self.Animition_wd then
        Actionbuf = "wangdiao"
    elseif data == self.Animition_wc then
        Actionbuf = "wangchuang"
    elseif data == self.Animition_fang then
        Actionbuf = "operation_fanxing"
    elseif data == self.Animition_sishou then
        Actionbuf = "sishou"
    elseif data == self.Animition_fangpao then
        Actionbuf = "fangpao"
    elseif data == self.Animition_addBase_no then
        Actionbuf = "budatou"
    elseif data == self.Animition_addBase then
        if GameCommon.wKindID == 16 then
            Actionbuf = "wufubaojing"
        else
            Actionbuf = "datou"
        end
    elseif data == self.Animition_phz_pengshangd then
        Actionbuf = "pengsanda"
    elseif data == self.Animition_phz_pengsiq then
        Actionbuf = "pengsiqing"
   elseif data == self.Animition_phz_shaoshanp then
        Actionbuf = "saosanda"
    elseif data == self.Animition_phz_shaosiqing then
        Actionbuf = "saosiqing"
    elseif data == self.Animition_phz_tilong then
        Actionbuf = "tilong"
    else 
        print("not found this sound : ",data)
        return
    end
    print("语音",GameCommon.wKindID,sex)
    
    if sex == 1 then
        require("common.Common"):playEffect(string.format("tszipai/sound/card_b_%s.mp3",Actionbuf))        
    else
        require("common.Common"):playEffect(string.format("tszipai/sound/card_g_%s.mp3",Actionbuf))
    end
    if Actionbuf == "hu" and( CHANNEL_ID == 6 or CHANNEL_ID == 7) then 
        require("common.Common"):playEffect("common/win.mp3")
    end 
      
end

function GameCommon:getUserInfoByUserID(dwUserID)
    for key, var in pairs(self.tagUserInfoList) do
        if var.dwUserID == dwUserID then
            return var
        end
    end
    for key, var in pairs(self.player) do
        if var.dwUserID == dwUserID then
            return var
        end
    end
    return nil
end

function GameCommon:getDiscardCardAndWeaveItemArray(data, isUseHand)
    local _spt = nil
    local str = ""
    if data == 0 then
        _spt = ccui.ImageView:create("tszipai/card/discard.png")
    else
        local value = Bit:_and(data,0x0F)
        local color = Bit:_rshift(Bit:_and(data,0xF0),4)
        local path  = string.format("tszipai/card/discard%d_%d.png",color,value)
        if isUseHand then
            path = string.format("tszipai/card/hand%d_%d.png",color,value)
        end
        _spt = ccui.ImageView:create(path)
    end
    return _spt
end

function GameCommon:paySoundeffect(type)
    local Actionbuf = ""
    if type == self.Soundeffect_RunAction then
        Actionbuf = "tszipai/sound/runaction.mp3"
    elseif type == self.Soundeffect_RunCard then
        Actionbuf = "tszipai/sound/runcard.mp3"
    elseif type == self.Soundeffect_Huang then
        Actionbuf = "tszipai/sound/operation_huangzhuang.mp3"
    elseif type == self.Soundeffect_FangX then
        Actionbuf = "tszipai/sound/operation_fanxing.mp3"
    elseif type == self.Soundeffect_getW then
        Actionbuf = "tszipai/sound/getw.mp3"
    else
        print("not found this type:",type)
        return
    end
    require("common.Common"):playEffect(Actionbuf)
end

function GameCommon:getUserInfo(charID)
    for key, var in pairs(self.tagUserInfoList) do
    	if var.wChairID == charID then
    	    return clone(var)
    	end
    end
    
    for key, var in pairs(self.player) do
        if var.wChairID == charID then
            return clone(var)
        end
    end
    local var = {}
    var.cbSex = 0
    return var
end

function GameCommon:palyCDCardSound(sex ,data)
    local index = 0
    if data == 33 then
        index = 33
    elseif data <= 10 then
        index = data
    else
        index = data - 6
    end
    if sex == 1 then 
        require("common.Common"):playEffect(string.format("tszipai/sound/card_b_%s.mp3",index))
    else
        require("common.Common"):playEffect(string.format("tszipai/sound/card_g_%s.mp3",index))
    end

end

function GameCommon:GetCardHand(data)
    --牌背会变化
    local _spt = nil
    local str = ""
    if data == 0 then
        _spt = cc.Sprite:create("tszipai/card/cd_HandBG.png")
    elseif data==33 then
        _spt = cc.Sprite:create("tszipai/card/dww.png")
    elseif data <= 10 then
        str = string.format("tszipai/card/x%d.png",data)
        _spt = cc.Sprite:create(str)
    elseif data > 10 then
        str = string.format("tszipai/card/d%d.png",data - 16)
        _spt = cc.Sprite:create(str)
    else
    
    end
    return _spt
end

function GameCommon:upDataGold(Gold, Diamond)
    if GameCommon.isFriendsGame == true then
        return
    end
--    local variable=  UserData.User.dwDiamond ;
--    UserData.User.dwDiamond = variable + Diamond
--    if UserData.User.dwDiamond < 0 then
--    	UserData.User.dwDiamond = 0
--    end
    local variable = UserData.User.dwGold
    UserData.User.dwGold = variable + Gold
    if UserData.User.dwGold < 0 then
    	UserData.User.dwGold = 0
    end
end

function GameCommon:payEmoticon( index)
    local buff = ""
    if index == 0 then
        buff ="biaoqing-kaixin"                   --笑
    elseif index == 1 then
        buff ="biaoqing-shengqi"                 --怒
    elseif index == 2 then
        buff ="biaoqing-cool"                      --装
    elseif index == 3 then
        buff ="biaoqing-xihuan"                 --色
    elseif index == 4 then
        buff ="biaoqing-jingdai"                   --惊
    elseif index == 5 then
        buff ="biaoqing-daku"                 --哭
    else
    
    end
    require("common.Common"):playEffect(string.format("expression/sound/%s.mp3",buff))
end

function GameCommon:ContinueGame(cbLevel)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SET_POSITION,"aad",LocationSystem.pos.x, LocationSystem.pos.y, GameCommon.dwUserID)
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_NEXT_GAME,"")
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"")
    elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_CONTINUE_GAME,"b",cbLevel)
    elseif GameCommon.tableConfig.nTableType == TableType_SportsRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_CONTINUE_GAME_BY_SPORTS,"d",cbLevel)
    end
end

-- 大数字转化
function GameCommon:itemNumberToString(num)  
    if num >= 1000000 then  
--        if num % 1000000 < 100000 then  
            return string.format("%d千公里", math.floor(num /1000000))  
--        else  
--            return string.format("%.1f千公里", (num - num % 100000)/1000000)  
--        end  
    elseif num >= 1000 then  
        if num % 1000 < 100 then  
            return string.format("%d公里", math.floor(num /1000))  
        else  
            return string.format("%.1f公里", (num - num % 100)/1000)  
        end  
    elseif num <= 1000 then   
        return string.format("%d米", num/1)  
    else
        return tostring("太远无法定位")  
    end  
end


function GameCommon:rad(d)
    return d* math.pi / 180.0;
end 

function GameCommon:GetDistance(lat1,lat2)
    local radLat1 = self:rad(lat1.x)
    local radLat2 = self:rad(lat2.x)
    local a = radLat1 - radLat2
    local b = self:rad(lat1.y) - self:rad(lat2.y)
    local s = 2 * math.asin(math.sqrt(math.pow(math.sin(a/2),2) +math.cos(radLat1)*math.cos(radLat2)*math.pow(math.sin(b/2),2)))
    s = s * self.EARTH_RADIUS*1000
 --   s = math.round(s * 10000) / 10000  
    return s;
end 



function GameCommon:CloseGame()
--    local SceneMgr = require("app.views.SceneMgr")
--    require("common.SceneMgr"):switchScene(SceneMgr.SceneName_Main)
end

cc.exports.GameLogic = nil

function GameCommon:setGameLogic(paramer)
    cc.exports.GameLogic = require(paramer)
end

function GameCommon:GetCardhuxi(data)
    local _spt = nil
    local str = ""
    if data == 0 then
        _spt = ccui.ImageView:create("tszipai/card/discard.png")
    else
        local value = Bit:_and(data,0x0F)
        local color = Bit:_rshift(Bit:_and(data,0xF0),4)
        _spt = ccui.ImageView:create(string.format("tszipai/card/discard%d_%d.png",color,value))
    end
    return _spt
end

return GameCommon