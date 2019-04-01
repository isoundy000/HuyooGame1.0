local Common = require("common.Common")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Bit = require("common.Bit")
local LocationSystem = require("common.LocationSystem")

local GameCommon = {
    -------------------------------------------------------------------------------
    --宏定义
    
    --麻将动作定义
    WIK_NULL = 0x00,                         --没有类型
    WIK_LEFT = 0x01,                         --左吃类型
    WIK_CENTER = 0x02,                       --中吃类型
    WIK_RIGHT = 0x04,                        --右吃类型
    WIK_PENG = 0x08,                         --碰牌类型
    WIK_FILL = 0x10,                         --补牌类型
    WIK_GANG = 0x20,                         --杠牌类型
    WIK_CHI_HU = 0x40,                       --吃胡类型
    WIK_HAIDI = 0x80,                        --海底类型

    --麻将胡牌定义
    
    --非胡类型
    CHK_NULL = 0x0000,                       --非胡类型
    
    PHZ_RULE_FANXING                    =0x0001,                     --回放翻省
    PHZ_RULE_GENXING                    =0x0002,                     --回放跟省

    --小胡类型
    CHK_PING_HU = 0x0001,                    --平胡类型
    CHK_SIXI_HU = 0x0002,                    --四喜胡牌
    CHK_BANBAN_HU = 0x0004,                  --板板胡牌
    CHK_LIULIU_HU = 0x0008,                  --六六顺牌
    CHK_QUEYISE_HU = 0x0010,                 --缺一色牌

    --大胡类型
    CHK_PENG_PENG = 0x0002,                  --碰碰胡
    CHK_JIANG_JIANG = 0x0004,                --将将胡
    CHR_QING_YI_SE = 0x0008,                 --清一色
    CHR_QUAN_QIU_REN = 0x0010,               --全求人
    CHR_HAIDI = 0x0020,                      --海底胡				--权位
    CHK_QI_XIAO_DUI = 0x0040,                --七小对
    CHK_QI_XIAO_DUI_HAO = 0x0080,            --豪华七小对
    CHR_GANG = 0x0100,                       --杠上开花			--权位
    CHR_GANG_SHUANG = 0x0200,                --长沙：双杠上花  益阳：报听胡          --权位
    CHK_QI_XIAO_DUI_HAO_SHUANG = 0x0400,            --双豪华七小对   
    CHK_QI_XIAO_DUI_HAO_CHAO = 0x0800,            --超豪华七小队   
    
    --动作定义

--    ACK_NULL                    =0,                                --空
--    ACK_TI                      =1,                                --提
--    ACK_PAO                     =2 ,                               --跑
--    ACK_WEI                     =4,                                --偎
--    ACK_WD                      =8 ,                               --王钓
--    ACK_WC                      =16   ,                              --王闯
--    ACK_CHI                     =32   ,                             --吃
--    ACK_CHI_EX                  =64    ,                            --吃
--    ACK_PENG                    =128    ,                            --碰
--    ACK_CHIHU                   =256   ,                           --胡
--    ACK_BIHU				        =512,						    --必胡

    --吃牌类型
--    CK_NULL = 0,         --无效类型
--    CK_XXD = 1,          --小小大搭
--    CK_XDD = 2,          --小大大搭
--    CK_EQS = 4,          --二七十吃
--    CK_LEFT = 16,        --靠左对齐
--    CK_CENTER = 32,      --居中对齐
--    CK_RIGHT = 64,       --靠右对齐
--    CK_YWS	=128,		--一五十吃
    --数值定义
    MAX_WEAVE = 4,       --最大组合
    MAX_INDEX = 34,      --最大索引
    MAX_COUNT = 17,      --最大数目
    MAX_REPERTORY = 120,    --最大库存
    MASK_COLOR = 0xF0,    --花色掩码
    MASK_VALUE = 0x0F,     --数值掩码
    --主要用于桌面显示
--    ACK_CHOUWEI = 5,     --臭偎
    --牌间隔
    CARDHEIGH = 72,
    CARDWIDTH = 57,
    BASEPOSITIONY = 130,
    BASEPOSITIONX = 120,
    CARD_HUXI_HEIGHT = 40,
    CARD_HUXI_WIDTH = 40,
--    CARD_COM_HEIGHT = 226,
--    CARD_COM_WIDTH = 76,
    --游戏结束开始时间
--    Game_end_time = 25.0,
    
    GameView_updataHuxi = 1,        --跟新胡息
    GameView_updataHardCard = 2,    --跟新手牌
    GameView_showOutCardTips = 3,   --显示出牌提示
    GameView_closeOutCardTips = 4,  --关闭出牌提示
    GameView_BegainMsg = 5,         --开始处理消息
    GameView_endMsg = 6,            --处理完消息了
    GameView_UpOpration = 7,        --更新操作超时
    GameView_OutOpration = 8,       --操作超时
    GameView_SpecialStart = 9,
    GameView_SpecialOver = 10,
    GameView_UpdataUserScore = 11,  --跟新金币
    GameView_SortCardOver = 12,


    --骰子数据
    SiceType_gameStart = 0,
    SiceType_gangCard = 1,

    --服务端接收校验类型
    ReceiveClientKind_Null = 0,
    ReceiveClientKind_Xihu = 1,
    ReceiveClientKind_OutCard = 2,
    ReceiveClientKind_OperateSelf = 3,
    ReceiveClientKind_OperateAll = 4,
    ReceiveClientKind_Yaoshuaibuzhang = 5,
    ReceiveClientKind_HaiDi = 6,

--    ACTION_TIP = 1,                 --提示动作
--    ACTION_TI_CARD = 2,             --提牌动作
--    ACTION_PAO_CARD = 3,            --跑牌动作
--    ACTION_WEI_CARD = 4,            --偎牌动作
--    ACTION_PENG_CARD = 5,           --碰牌动作
--    ACTION_HU_CARD = 6,             --胡牌动作
--    ACTION_CHI_CARD = 7,            --吃牌动作
--    ACTION_OUT_CARD = 8,            --出牌动作
--    ACTION_SEND_CARD = 9,           --发牌动作
--    ACTION_OPERATE_NOTIFY = 10,     --发牌动作
--    ACTION_OUT_CARD_NOTIFY = 11,    --发牌动作
--    ACTION_FANG_CARD = 12,          --翻省动作
--    ACTION_VIEW_CARD = 13,          --表现动作
--    ACTION_HUANG = 14,              --黄庄动作
--    ACTION_WD = 15,                 --王钓动作
--    ACTION_WC = 16,                 --王闯动作
--    ACTION_SISHOU = 17,             --死守动作
--    ACTION_WPei = 18,               --有王赔钱动作
--    ACTION_ADDBASE=19,          --加倍动作
    
    Actor_chi = 0,                  --吃
    Actor_peng = 1,                 --碰
    Actor_gang = 2,                 --杠
    Actor_fangpao = 3,              --放炮
    Actor_zimo = 4,                 --自摸

    Actor_dsx = 5,                  --大四喜
    Actor_lls = 6,                  --66顺
    Actor_qys = 7,                  --却一色
    Actor_wjh = 8,                  --无将胡（板板胡）
--    Animition_chi = 0,          --吃
--    Animition_peng = 1,         --碰
--    Animition_hu = 2,           --胡
--    Animition_ti = 3,           --提
--    Animition_pao = 4,          --跑
--    Animition_wei = 5,           --偎
--    Animition_chouwei = 6,      --臭偎
--    Animition_bi = 7,           --比
--    Animition_wd = 8,           --王钓
--    Animition_sishou = 9,       --死守
--    Animition_wc = 10,          --王闯
--    Animition_fang = 11,        --翻省    
--    Animition_Huang = 12,       --黄庄
--    Animition_wpei = 13,        --王霸赔钱
    
--    Animition_qing = 14,        --提变倾
--    Animition_xiao = 15,        --偎变啸
--    Animition_chouxiao = 16,    --臭啸
--    Animition_xiahuo = 17,      --比变下火
--    Animition_fangpao = 18,     --放炮
    --字牌变化
--    Animition_sao = 19,         --煨变扫
--    Animition_guosao = 20,      --臭喂变过扫
--    Animition_saoquang = 21,    --提变扫穿
--    Animition_tuo = 22,         --跑变开拓  
    
--    Animition_addBase=23,       --加倍
--    Animition_addBase_no=24,    --不加倍


    Soundeffect_RunAction = 0,      --动作
    Soundeffect_YaoShuaiZi = 1,     --要帅
    Soundeffect_time = 2,           --时间
    Soundeffect_Huang = 3,          --黄庄
    Soundeffect_Chi = 4,            --吃
    Soundeffect_Peng = 5,           --碰
    Soundeffect_Gang = 6,           --杠
    Soundeffect_Hu = 7,             --胡
    Soundeffect_outCard = 8,        --出牌
    Soundeffect_send4Card = 9,      --发牌
    Soundeffect_AddSz = 10,         --加钻

    Soundeffect_xiPaiAnimation = 11,    --洗牌
--    Soundeffect_RunAction = 0,  --动作
--    Soundeffect_RunCard = 1,    --卡牌
--    Soundeffect_Huang = 2,      --黄庄
--    Soundeffect_FangX = 3,      --翻省
--    Soundeffect_getSz = 4,      --获取闪砖
--    Soundeffect_getW = 5,       --摸到王牌
    
    timeAction_Null = 0,
    timeAction_OutCard = 1,
    timeAction_Opration = 2,
    CardData_WW = 33,
    
    leftalignment=1,
    centrealignment = 2,
    rightalignment = 3,
    
--    CARDHEIGH = 90.0,
--    CARDWIDTH = 95.0,
--    BASEPOSITIONY = 55.0,
--    BASEPOSITIONX = 50.0,
    
    ClientSockEvent_connectFaild = 1,                 --链接失败
    ClientSockEvent_connectError = 2,                 --网络错误
    ClientSockEvent_connectSucceed = 3,               --链接成功
    
    INVALID_TEAM = 65535,    --无效组号
    INVALID_TABLE = 65535,   --无效桌子
    INVALID_CHAIR = 65535,  
    INVALID_ID = 4294967295,
    
    --无效数值
    INVALID_BYTE	=			0xFF,						--无效数值
    INVALID_WORD	=		    0xFFFF,					--无效数值
    INVALID_DWORD	=			0xFFFFFFFF,				--无效数值
    
    EARTH_RADIUS = 6371.004,                      --地球半径   
    -------------------------------------------------------------------------------
    number_dwHorse = 0 ,                --扎鸟数
    number_dwHorse = {},                 --游戏配置表  
    wBankerUser = 0,                  --庄家用户
    dwUserID = 0
}

function GameCommon:init()
	    --数据
    self.tagUserInfoList = {}
    self.cbCFData = {[1] = 4,[2] = 4,[3] = 4,[4] = 4}  -- 游戏冲分   4 没有冲分  1——3 冲分 0  不冲分
    self.wPlayerCount = 0
    self.gameType = 0
    self.bIsMyTurn = false                      --轮到我出牌了
    self.m_bIsGang = false                      --自己扛牌了
    self.m_bIsBaoTing = false                   --自己报听了
    self.m_MyTurnPos = {}                       --我出牌位置
    self.m_MyHandCardPos = {}                   --摸到手里位置
    self.m_SpecialTempCardData = {}                     --
    self.m_SpecialCardCout = 0                          --
    self.m_SpeciallGameScore = {[1] = 0,[2] = 0,[3] = 0,[4] = 0}    --游戏输赢积分 (长沙麻将表示特殊牌型)
    self.m_GangAllGameScore = {[1] = 0,[2] = 0,[3] = 0,[4] = 0}     --游戏输赢积分 (转转麻将表示杠牌出钱)
--    self.wBankerUser1 = 0                  --庄家用户
    self.m_cbLeftCardCount = 0              --剩余数目
    self.m_cbCardIndex = {}                 --手中扑克
    self.m_cbWeaveCount = {}                --组合数目
    self.m_WeaveItemArray = {}              --组合扑克
    self.m_wSiceCount = 0                   --起始摇甩
    self.m_SiceType = 0                     --摇甩状态
    self.m_wDiceCard = {}                   --摇帅的牌
    self.m_wDiceCount = 0                   --要甩点数
    self.m_wDiceUser = 0                    --
    self.m_data_c = {}                      --记录打乱的牌
    self.m_cout_c = 0                       --记录打乱的牌数
    self.isFriendGameStart = false          --游戏开始 
    self.m_guchou = nil                     --箍丑玩家   
    self.m_GuoZhangGang = {[1] = 0,[2] = 0,[3] = 0,[4] = 0}     --碰了不能再杠的牌
    self.m_CardNumber = {   [0]={ [1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,[7] = 0,[8] = 0,[9] = 0}, 
                            [1]={ [1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,[7] = 0,[8] = 0,[9] = 0}, 
                            [2]={ [1] = 0,[2] = 0,[3] = 0,[4] = 0,[5] = 0,[6] = 0,[7] = 0,[8] = 0,[9] = 0}, 
                            [3]={ [1] = 0,[2] = 0,[3] = 0}, }     --弃牌统计数组
--                            [01] = 0,[02] = 0,[03] = 0,[04] = 0,[05] = 0,[06] = 0,[07] = 0,[08] = 0,[09] = 0,
--                            [11] = 0,[12] = 0,[13] = 0,[14] = 0,[15] = 0,[16] = 0,[17] = 0,[18] = 0,[19] = 0,
--                            [21] = 0,[22] = 0,[23] = 0,[24] = 0,[25] = 0,[26] = 0,[27] = 0,[28] = 0,[29] = 0,
--                            [31] = 0,[32] = 0,[33] = 0
--    self.leftCardCount = 0
--    self.cardStackWidth = 0
--    self.handCardalignment = 0
 --   self.cbCardIndex = {}
 --   self.wBankerUser = 0
 --   self.bWeaveItemCount = {[1] = 0 , [2] = 0 , [3] = 0 }
 --   self.weaveItemArray = {}
 --   self.bUserCardCount = {}
    if self.bellv==nil then
        self.bellv = 0
    end
    self.meChairID = 0
 --   self.cbWWCout = 0
 --   self.restart = false
    self.restart = false
    self.isHuangZhuang = nil
    self.listdatacard = {[0] = {},[1] = {},[2] = {},[3] = {}}
    self.m_crad_17 = 0                      --回放暂时存放庄家第17张牌
    self.gameState = 0
end

function GameCommon:SwitchViewChairID(wChairID)
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
    local viewID = self:SwitchViewChairID(wChairID) + 1
--    local location = 1          --主角位置
--    local wPlayerCount = self.gameConfig.bPlayerCount      --玩家人数
--    local meChairID = self:getRoleChairID()     --主角的座位号
--    local viewID = (wChairID + wPlayerCount - meChairID)%wPlayerCount+1
    return viewID
end

function GameCommon:GetAnimation(pt,buff)
    local tempbuff = string.format("animition/%s.ExportJson",buff)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(tempbuff)
    local armature2= ccs.Armature:create(buff)
    armature2:setPosition(pt)
    armature2:getAnimation():playWithIndex(0,-1,0)
    armature2:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),cc.FadeOut:create(0.5),cc.RemoveSelf:create(),nil))
    return armature2
end

function GameCommon:palyCDActionSound(sex ,data)
   -- Actor_fangpao = 3,              --放炮
   -- Actor_zimo = 4,                 --自摸
    print("play sound ",data)
    local Actionbuf = ""
    if data == self.Actor_chi then
       Actionbuf="chi"
    elseif data == self.Actor_peng then
        Actionbuf="peng"
    elseif data == self.Actor_fangpao then         
        Actionbuf="fangpao"
    elseif data == self.Actor_fill then
        if self.wKindID == 27 then
            Actionbuf = "buzhang"
        else            
            Actionbuf="gang"
        end
    elseif data == self.Actor_zimo then
            Actionbuf="zimo"
    elseif data == self.Actor_dsx then
        Actionbuf="dasixi"
    elseif data == self.Actor_lls then
        Actionbuf="liu"
    elseif data == self.Actor_qys then
        Actionbuf="que"
    elseif data == self.Actor_wjh then
        Actionbuf="ban"
    else
        print("not found this sound : ",data)
        return
    end
    local buf = ""
    if sex == 1 then 
        require("common.Common"):playEffect(string.format("laopai/sound/card_b_%s.mp3",Actionbuf))
    else 
        require("common.Common"):playEffect(string.format("laopai/sound/card_g_%s.mp3",Actionbuf))
    end
    if  Actionbuf=="zimo" or Actionbuf=="fangpao" then     
       require("common.Common"):playEffect("common/win.mp3")
    end 
end

function GameCommon:paySoundeffect(type)
    local Actionbuf = ""
    if type == self.Soundeffect_RunAction then
        Actionbuf = "laopai/sound/runaction.mp3"
    elseif type == self.Soundeffect_YaoShuaiZi then
        Actionbuf = "laopai/sound/yaoshuiazi.mp3"
    elseif type == self.Soundeffect_time then
        Actionbuf = "laopai/sound/timed.mp3"
    else
        print("not found this type:",type)
        return
    end
    require("common.Common"):playEffect(Actionbuf)
end

function GameCommon:getUserInfo(charID)
--    charID = self:SwitchViewChairID(charID)
    for key, var in pairs(self.tagUserInfoList) do
    	if var.wChairID == charID then
    	    return clone(var)
    	end
    end
    local var = {}
    var.cbSex = 0
    return var
end

function GameCommon:palyCDCardSound(sex ,data)

    local cbValue= Bit:_and(data,15)
    local cbColor= Bit:_rshift( Bit:_and(data,240), 4)
    if sex == 1 then
        require("common.Common"):playEffect(string.format("laopai/sound/card_b_%d%d.mp3",cbColor,cbValue))
    else 
        require("common.Common"):playEffect(string.format("laopai/sound/card_g_%d%d.mp3",cbColor,cbValue))
    end
    
end

function GameCommon:getUserInfoByUserID(dwUserID)
    for key, var in pairs(self.tagUserInfoList) do
        if var.dwUserID == dwUserID then
            return var
        end
    end
--    for key, var in pairs(self.player) do
--        if var.dwUserID == dwUserID then
--            return var
--        end
--    end
    return nil
end

function GameCommon:GetCardHand(data,ID)
    --牌背会变化
    if ID == nil then
        ID = 1
    end
    local _spt = nil
    local cbValue = Bit:_and(data,0x0F)
    local cbColor = Bit:_rshift(Bit:_and(data,0xF0),4)
    if cbColor == 3 and cbValue == 1 then
    end
    if ID == 0 then
        if data == 0 then
            _spt = cc.Sprite:create("laopai/xplpcard/hand_card_bg.png")


        else
            _spt = cc.Sprite:create(string.format("laopai/xplpcard/hand_card%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt = cc.Sprite:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    elseif ID == 1 then
        if data == 0 then
            _spt = cc.Sprite:create("laopai/xplpcard/hand_card_bg.png")
        else
            _spt = cc.Sprite:create(string.format("laopai/xplpcard/hand_card%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt = cc.Sprite:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    elseif ID == 2 then
        if data == 0 then
            _spt = cc.Sprite:create("laopai/xplpcard/hand_card_bg.png")

        else
            _spt = cc.Sprite:create(string.format("laopai/xplpcard/hand_card%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt = cc.Sprite:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    elseif ID == 3 then
        if data == 0 then
            _spt = cc.Sprite:create("laopai/xplpcard/hand_card_bg.png")

        else
            _spt = cc.Sprite:create(string.format("laopai/xplpcard/hand_card%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt = cc.Sprite:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    end

    return _spt

end

function GameCommon:GetPartCardHand(data,ID)
    --牌背会变化
    if ID == nil then
        ID = 1
    end
    local _spt = nil
    local cbValue = Bit:_and(data,0x0F)
    local cbColor = Bit:_rshift(Bit:_and(data,0xF0),4)
    if cbColor == 3 and cbValue == 1 then
    end 
    if ID == 4 then    
        if data == 0 then
            _spt =  ccui.ImageView:create("laopai/xplpcard/hand_card_bg.png")
        else
            _spt =  ccui.ImageView:create(string.format("laopai/xplpcard/hand_card%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt =  ccui.ImageView:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    else
        if data == 0 then
            _spt =  ccui.ImageView:create("laopai/xplpcard/hand_partcard_bg.png")
        else
            _spt =  ccui.ImageView:create(string.format("laopai/xplpcard/hand_partcard%d%d.png",cbColor,cbValue))
            if cbColor == 3 and cbValue == 1 and self.wKindID == 33 then
                _spt =  ccui.ImageView:create("laopai/xplpcard/hand_card31_2.png")
            end
        end
    
    end 
--   local card = _spt    --ccui.ImageView:create()
--   card:setTexture(_spt:getTexture())
--        card:setTextureRect(cc.rect(0,0,95,150))
--            card:setTextureRect(cc.rect(0,0,95,527)) 
   
    return _spt
end

function GameCommon:GetShuaiZi(Cout)
--    return cc.Sprite:create(string.format("game/laopai/res/mjCommon/shuaiz_%d.png",Cout))
end

function GameCommon:upDataGold(Gold, Diamond)
    if self.isFriendsGame == true then
        return
    end
    local UserData = require("app.user.UserData")
--    local variable=  UserData.User.dwDiamond ;
--    UserData.User.dwDiamond = variable + Diamond
--    if UserData.User.dwDiamond < 0 then
--        UserData.User.dwDiamond = 0
--    end
    local variable = UserData.User.dwGold
    UserData.User.dwGold = variable + Gold
    if UserData.User.dwGold < 0 then
        UserData.User.dwGold = 0
    end
end

function GameCommon:payEmoticon(index)
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
    if GameCommon.friendsRoomInfo.nTableType > TableType_GoldRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_NEXT_GAME,"")
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"")
    elseif GameCommon.friendsRoomInfo.nTableType == TableType_GoldRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_CONTINUE_GAME,"b",cbLevel)
    elseif GameCommon.tableConfig.nTableType == TableType_SportsRoom then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_CONTINUE_GAME_BY_SPORTS,"d",cbLevel)
    end
end

-- 大数字转化
function GameCommon:itemNumberToString(num)  
    if num >= 1000000 then  
            return string.format("%d千公里", math.floor(num / 1000000))    
    elseif num >= 1000 then  
        if num % 1000 < 100 then  
            return string.format("%d公里", math.floor(num / 1000))  
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
    return s;
end 

function GameCommon:CloseGame()
    local SceneMgr = require("app.views.SceneMgr")
    SceneMgr:switch(SceneMgr.SceneName_Main)
end

cc.exports.GameLogic = nil

function GameCommon:setGameLogic(paramer)
    cc.exports.GameLogic = require(paramer)
end

function GameCommon:sendCheckGameConnect()
    if NetMgr:getGameInstance().connected then
        local ret = NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_KN_COMMAND,NetMsgId.SUB_KN_DETECT_SOCKET,"")  
        if ret == -1 then
            NetMgr:getLogicInstance():closeConnect()
            local netID = NetMgr.NET_GAME
            require("app.views.GameScene"):netDisconnect(netID)
            local EventType = require("app.event.EventType")
            EventMgr:dispatch(EventType.NET_DISCONNET,netID)
        end
    end
end

function GameCommon:getRoleChairID()
    return self.meChairID
end
return GameCommon