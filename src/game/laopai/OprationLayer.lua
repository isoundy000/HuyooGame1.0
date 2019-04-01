local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Common = require("common.Common")
local Bit = require("common.Bit")
local GameLogic = require("game.laopai.GameLogic")
local GameCommon = require("game.laopai.GameCommon")
--游戏操作框
local OprationLayer = class("OprationLayer",function()
    return ccui.Layout:create()
end)

function OprationLayer:create()
    local view = OprationLayer.new()
    view:onCreate()
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit()   
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end



function OprationLayer:onEnter()

end

function OprationLayer:onExit()

end

function OprationLayer:onCreate()

    self.m_cardDataIndex = {}
    self.m_cbOperateCard = {}
    self.m_chiSelect = nil
    self.m_isSelf = false
end

function OprationLayer:initButtonStatus()
    self:removeAllChildren()
    self.m_chiSelect = cc.Node:create()
    self:addChild(self.m_chiSelect)
    self.m_cbOperateCard[1] = 0
    self.m_cbOperateCard[2] = 0
end

function OprationLayer:setButtonStatus(cbOperateCode,cbOperateCard,cbCardIndex,isSelf)
    self:stopAllActions()
    self:initButtonStatus()
    self.m_cardDataIndex = clone(cbCardIndex)
    self.m_cbOperateCard[1] = cbOperateCard[1]
    self.m_cbOperateCard[2] = cbOperateCard[2]
    self.m_isSelf = isSelf

    local _node = nil

    local Cout = 1
    local size = cc.Director:getInstance():getWinSize()
    local Opration_width = 150

    --过
    if true then
        
        _node = ccui.Button:create("game/op_guo.png","game/op_guo.png","game/op_guo.png")
        _node:setPressedActionEnabled(true)
        _node:setScale(0.8)
        _node:setTag(1)
        _node:setAnchorPoint(cc.p(0.5,0.5))
        Cout = Cout + 1
        _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
        self:addChild(_node)
        _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealGuo() end end)
    end
    if  Bit:_and(cbOperateCode,GameCommon.WIK_FILL) ~= 0 then
        if GameCommon.wKindID == 27 then
            --补牌
            _node = ccui.Button:create("game/op_bu.png","game/op_bu.png","game/op_bu.png")
            _node:setPressedActionEnabled(true)
            _node:setScale(0.8)
            _node:setTag(3)
            _node:setAnchorPoint(cc.p(0.5,0.5))
            Cout = Cout + 1
            _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
            self:addChild(_node)
            _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealBu() end end)
        end
    end
    --杠牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_GANG) ~= 0 then
        if GameCommon.wKindID == 27 then
            --杠牌
            _node = ccui.Button:create("game/op_gang.png","game/op_gang.png","game/op_gang.png")
            _node:setPressedActionEnabled(true)
            _node:setScale(0.8)
            _node:setTag(2)
            _node:setAnchorPoint(cc.p(0.5,0.5))
            Cout = Cout + 1
            _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
            self:addChild(_node)
            _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealGang() end end)
            --            end
        else
            _node = ccui.Button:create("game/op_gang.png","game/op_gang.png","game/op_gang.png")
            _node:setPressedActionEnabled(true)
            _node:setScale(0.8)
            _node:setTag(2)
            _node:setAnchorPoint(cc.p(0.5,0.5))
            Cout = Cout + 1
            _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
            self:addChild(_node)
            --_node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealBu() end end)
            _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealBu_tuoguan() end end)     
        end
    end
    --碰牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_PENG) ~= 0 then
        _node = ccui.Button:create("game/op_peng.png","game/op_peng.png","game/op_peng.png")
        _node:setPressedActionEnabled(true)
        _node:setScale(0.8)
        _node:setTag(4)
        _node:setAnchorPoint(cc.p(0.5,0.5))
        Cout = Cout + 1
        _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
        self:addChild(_node)
        _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealPen() end end)
    end

    --吃牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_LEFT) ~= 0 or Bit:_and(cbOperateCode,GameCommon.WIK_CENTER) ~= 0 or  Bit:_and(cbOperateCode,GameCommon.WIK_RIGHT) ~= 0 then
        _node = ccui.Button:create("game/op_chi.png","game/op_chi.png","game/op_chi.png")
        _node:setPressedActionEnabled(true)
        _node:setScale(0.8)
        _node:setTag(5)
        _node:setAnchorPoint(cc.p(0.5,0.5))
        Cout = Cout + 1
        _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
        self:addChild(_node)
        _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealChi() end end)
    end

    --胡牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_CHI_HU) ~= 0 then
        _node = ccui.Button:create("game/op_hu.png","game/op_hu.png","game/op_hu.png")
        _node:setPressedActionEnabled(true)
        _node:setScale(0.8)
        _node:setTag(6)
        _node:setAnchorPoint(cc.p(0.5,0.5))
        Cout = Cout + 1
        _node:setPosition(size.width-Opration_width*Cout,size.height*0.4)
        self:addChild(_node)
        _node:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealHu() end end)
    end
end

function OprationLayer:Tuoguan_Status(cbOperateCode,cbOperateCard,cbCardIndex,isSelf)
    --托管碰胡
    self:initButtonStatus()
    self.m_cardDataIndex = clone(cbCardIndex)
    self.m_cbOperateCard[1] = cbOperateCard[1]
    self.m_cbOperateCard[2] = cbOperateCard[2]
    self.m_isSelf = isSelf

    local _node = nil

    local Cout = 1
    local size = cc.Director:getInstance():getWinSize()
    local Opration_width = 150
    --胡牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_CHI_HU) ~= 0 then
         self:dealHu() 
         return
    end
    --杠牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_GANG) ~= 0 then
        if GameCommon.wKindID == 27 then
            self:dealGang() 
        else
            self:dealBu_tuoguan() 
            return
        end
    end
    --碰牌
    if Bit:_and(cbOperateCode,GameCommon.WIK_PENG) ~= 0 then
        self:dealPen() 
        return
    end
    self:dealGuo()
    return
end
function OprationLayer:dealGuo()
    --点过先遍历一遍过张杠
    local TempDataIndex = clone(self.m_cardDataIndex)
    local TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
    local TempWeaveCount = GameCommon.m_cbWeaveCount[2]
    if TempWeaveItemArray ~= nil then
        GameLogic:AnalyseGangCardGuo(TempDataIndex,TempWeaveItemArray,TempWeaveCount)
    end
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_NULL,0)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
    return
end

function OprationLayer:dealLeftChi(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_LEFT,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealCnterChi(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_CENTER,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealRightChi(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_RIGHT,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealGangResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_GANG,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealFillResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_FILL,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealPenResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_PENG,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealHuResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_CHI_HU,_obj)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end


function OprationLayer:dealYaoshuaiResult()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CASTDICE,"o",true)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealBuzhangResult()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CASTDICE,"o",false)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
    
end

function OprationLayer:dealHaidiNoResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_HAIDI,"wo",GameCommon:GetMeChairID(),false)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealHaidiYesResult()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_HAIDI,"wo",GameCommon:GetMeChairID(),true)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealXihuGuoResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu,"ow",0,GameCommon.CHK_NULL)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealXihusxResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu,"nw",1,GameCommon.CHK_SIXI_HU)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealXihuliuResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu,"nw",1,GameCommon.CHK_LIULIU_HU)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealXihubbResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu,"ow",1,GameCommon.CHK_PING_HU)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealXihuqysResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu,"nw",1,GameCommon.CHK_QUEYISE_HU)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end

function OprationLayer:dealzhuangSelectResult(_obj)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_ZhuangStart,"n",1)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
    self:initButtonStatus()
end




function OprationLayer:dealGang()
    self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)

    --主动不判
    if self.m_isSelf == true then
        --主动杠牌
        local TempDataIndex = {}
        local TempWeaveItemArray = {}
        local TempWeaveCount = 0
        local GangCardResult

        TempDataIndex = clone(self.m_cardDataIndex)
        TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
        if TempWeaveItemArray == nil then
            TempWeaveItemArray = {}
        end
        TempWeaveCount = GameCommon.m_cbWeaveCount[2]

        local cbUserAction ,GangCardResult = GameLogic:AnalyseGangCard(TempDataIndex,TempWeaveItemArray,TempWeaveCount)
        for i = 1 , GangCardResult.cbCardCount do
            TempDataIndex = clone(self.m_cardDataIndex)
            TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
            TempWeaveCount = clone(GameCommon.m_cbWeaveCount[2])
            if TempWeaveItemArray == nil then
                TempWeaveItemArray = {}
            end
            TempDataIndex[GameLogic:SwitchToCardIndex(GangCardResult.cbCardData[i])] = 0

            --杠牌处理
            local wIndex = 0
            local ispengGang = false
            --寻找组合
            for j = 1,TempWeaveCount do
                if TempWeaveItemArray[j] == nil then
                    TempWeaveItemArray[j] = {}
                end
                local cbWeaveKind = TempWeaveItemArray[j].cbWeaveKind
                local cbCenterCard = TempWeaveItemArray[j].cbCenterCard
                if cbCenterCard == GangCardResult.cbCardData[i] and cbWeaveKind == GameCommon.WIK_PENG then
                    wIndex = j
                    ispengGang = true
                    break
                end
            end
            --数据修改
            if ispengGang == false then
                wIndex = TempWeaveCount+1
                TempWeaveCount = TempWeaveCount + 1
            end
            if TempWeaveItemArray[wIndex] == nil then
                TempWeaveItemArray[wIndex] = {}
            end
            TempWeaveItemArray[wIndex].cbPublicCard = true
            TempWeaveItemArray[wIndex].cbCenterCard = GangCardResult.cbCardData[i]
            TempWeaveItemArray[wIndex].cbWeaveKind = GameCommon.WIK_GANG
            TempWeaveItemArray[wIndex].wProvideUser = GameCommon.INVALID_CHAIR
            if GameLogic:IsTingPaiStatus(TempDataIndex,TempWeaveItemArray,TempWeaveCount) then
                local data = GangCardResult.cbCardData[i]
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(9)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.4))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealGangResult(data) end end)
                self.m_chiSelect:addChild(_button)

                local cbRemoveCard = {[1] = data,[2] = data,[3] = data,[4] = data}
                for  i = 1 , 4 do
                    local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                    spt:setScale(0.5,0.40)
                    spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                    _button:addChild(spt)
                    if i == 4 then
                        spt:setPosition(pt.x+1*80*0.48,pt.y+15)
                    end
                end
            end
        end
    else
        for i = 1 , 2 do
            --被动杠牌
            local TempDataIndex = {}
            local TempWeaveItemArray = {}
            local TempWeaveCount = 0
            TempDataIndex = clone(self.m_cardDataIndex)
            TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
            TempWeaveCount = GameCommon.m_cbWeaveCount[2]
            if TempWeaveItemArray == nil then
                TempWeaveItemArray = {}
            end
            if GameLogic:IsValidCard(self.m_cbOperateCard[i]) == false then
            else
                if GameLogic:EstimateGangCard(TempDataIndex,self.m_cbOperateCard[i]) > GameCommon.WIK_NULL then
                    TempDataIndex[GameLogic:SwitchToCardIndex(self.m_cbOperateCard[i])] = 0
                    local wIndex = TempWeaveCount+1
                    TempWeaveCount = TempWeaveCount + 1
                    if TempWeaveItemArray[wIndex] == nil then
                        TempWeaveItemArray[wIndex] = {}
                    end
                    TempWeaveItemArray[wIndex].cbPublicCard = true
                    TempWeaveItemArray[wIndex].cbCenterCard = self.m_cbOperateCard[i]
                    TempWeaveItemArray[wIndex].cbWeaveKind = GameCommon.WIK_GANG
                    TempWeaveItemArray[wIndex].wProvideUser = GameCommon.INVALID_CHAIR
                end
                if GameLogic:IsTingPaiStatus(TempDataIndex,TempWeaveItemArray,TempWeaveCount) then
                    local data = self.m_cbOperateCard[1]
                    _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                    _button:setTag(9)
                    _button:setAnchorPoint(cc.p(0.5,0.0))
                    Cout = Cout+1
                    _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.4))
                    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealGangResult(data) end end)
                    self.m_chiSelect:addChild(_button)

                    local cbRemoveCard = {[1] = data,[2] = data,[3] = data,[4] = data}
                    for  i = 1 , 4 do
                        local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                        spt:setScale(0.5,0.40)
                      spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                        _button:addChild(spt)
                        if i == 4 then
                            spt:setPosition(pt.x+1*80*0.48,pt.y+15)
                        end
                    end
                end
            end
        end
    end
end

function OprationLayer:dealBu_tuoguan()
    self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)

    --主动不判
    if self.m_isSelf == true then
        local GangCardResult
        local cbUserAction = 0 
        if GameCommon.m_WeaveItemArray == nil then
            GameCommon.m_WeaveItemArray = {}
            GameCommon.m_WeaveItemArray[2] = {}
        end    
        if GameCommon.m_cbWeaveCount == nil then
            GameCommon.m_cbWeaveCount = {}
            GameCommon.m_cbWeaveCount[2] = {}
        end 
        cbUserAction ,GangCardResult = GameLogic:AnalyseGangCard(self.m_cardDataIndex,GameCommon.m_WeaveItemArray[2],GameCommon.m_cbWeaveCount[2])
        if cbUserAction ~= GameCommon.WIK_NULL and GangCardResult.cbCardCount >= 0 then
            for i = 1 , GangCardResult.cbCardCount do
                if GangCardResult.cbCardData[i] ~= 0 then
                    local data = GangCardResult.cbCardData[i]
                     self:dealFillResult(data) 
                     return
                end
            end
        end
    else
        for i = 1 , 2 do
            if self.m_cbOperateCard[i] == 0 or self.m_cbOperateCard[i] == GameCommon.INVALID_CHAIR then
            else
                if GameLogic:EstimateGangCard(self.m_cardDataIndex,self.m_cbOperateCard[i]) > GameCommon.WIK_NULL then
                    local data = self.m_cbOperateCard[i]
                     self:dealFillResult(data) 

                end
            end
        end
    end
end
function OprationLayer:dealBu()
     self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)
    --报听直接杠
    if GameCommon.m_bIsBaoTing == true then
        self:dealFillResult(self.m_cbOperateCard[1])
        return
    end
    --主动不判
    if self.m_isSelf == true then
        local GangCardResult
        local cbUserAction = 0 
        if GameCommon.m_WeaveItemArray == nil then
            GameCommon.m_WeaveItemArray = {}
            GameCommon.m_WeaveItemArray[2] = {}
        end    
        if GameCommon.m_cbWeaveCount == nil then
            GameCommon.m_cbWeaveCount = {}
            GameCommon.m_cbWeaveCount[2] = {}
        end 
        cbUserAction ,GangCardResult = GameLogic:AnalyseGangCard(self.m_cardDataIndex,GameCommon.m_WeaveItemArray[2],GameCommon.m_cbWeaveCount[2])
        if cbUserAction ~= GameCommon.WIK_NULL and GangCardResult.cbCardCount >= 0 then
            for i = 1 , GangCardResult.cbCardCount do
                if GangCardResult.cbCardData[i] ~= 0 then
                    local data = GangCardResult.cbCardData[i]
                    if (data~= GameCommon.m_GuoZhangGang[1] and  data~= GameCommon.m_GuoZhangGang[2]) then   
                        _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                        _button:setTag(10)                     
                        _button:setAnchorPoint(cc.p(0.5,0.0))
                        _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.4))
                        Cout = Cout+1
                        _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealFillResult(data) end end)
                        self.m_chiSelect:addChild(_button)
    
                        local cbRemoveCard = {[1] = data,[2] = data,[3] = data,[4] = data}
                        for i = 1 , 4 do
                            local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                            spt:setScale(0.5,0.40)
                          spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                            _button:addChild(spt)
                            if i == 4 then
                                spt:setPosition(pt.x+1*80*0.48,pt.y+15)
                            end
                        end
                        
                   end
                end
            end
        end
    else
        for i = 1 , 2 do
            if self.m_cbOperateCard[i] == 0 or self.m_cbOperateCard[i] == GameCommon.INVALID_CHAIR then
            else
                if GameLogic:EstimateGangCard(self.m_cardDataIndex,self.m_cbOperateCard[i]) > GameCommon.WIK_NULL then
                    local data = self.m_cbOperateCard[i]
                    _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                    _button:setTag(10)
                    _button:setAnchorPoint(cc.p(0.5,0.0)) 
                    _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.4))
                    Cout = Cout+1
                    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealFillResult(data) end end)
                    self.m_chiSelect:addChild(_button)
                    local cbRemoveCard = {[1] = data,[2] = data,[3] = data,[4] = data}
                    for i = 1 , 4 do
                        local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                        spt:setScale(0.5,0.40)
                      spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                        _button:addChild(spt)
                        if i == 4 then
                            spt:setPosition(pt.x+1*80*0.48,pt.y+15)
                        end
                    end
                end
            end
        end
    end
end

function OprationLayer:dealChi()
    self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)

    for index = 1 , 2 do
        local _data = self.m_cbOperateCard[index]
        if _data == 0 then
        else
            local _selectAll = GameLogic:EstimateEatCard(self.m_cardDataIndex,_data)
            if Bit:_and(_selectAll,GameCommon.WIK_LEFT) ~= 0 then
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(7)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.15*Cout),size.height*0.5))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealLeftChi(_data) end end)
                self.m_chiSelect:addChild(_button)
                local cbRemoveCard = {[1] = _data+1,[2] = _data,[3] = _data+2}
                for i = 1,3 do
                    local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                    spt:setScale(0.5,0.40)
                    spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                    _button:addChild(spt)
                    if i == 2 then
                        spt:setColor(cc.c3b(200,200,200))
                    end
                end
            end
            if Bit:_and(_selectAll,GameCommon.WIK_CENTER) ~= 0 then
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(8)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.15*Cout),size.height*0.5))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealCnterChi(_data) end end)
                self.m_chiSelect:addChild(_button)
                local cbRemoveCard = {[1] = _data-1,[2] = _data,[3] = _data+1}
                for i = 1,3 do
                    local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                    spt:setScale(0.5,0.40)
                  spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                    _button:addChild(spt)
                    if i == 2 then
                        spt:setColor(cc.c3b(200,200,200))
                    end
                end
            end
            if Bit:_and(_selectAll,GameCommon.WIK_RIGHT) ~= 0 then
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(8)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.15*Cout),size.height*0.5))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealRightChi(_data) end end)
                self.m_chiSelect:addChild(_button)
                local cbRemoveCard = {[1] = _data-2,[2] = _data,[3] = _data-1}
                for i = 1,3 do
                    local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                    spt:setScale(0.5,0.40)
                  spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                    _button:addChild(spt)
                    if i == 2 then
                        spt:setColor(cc.c3b(200,200,200))
                    end
                end
            end
        end
    end
end

function OprationLayer:isGangIng()
    print("isGangIng")
    local ret = false
    --主动不判
    if self.m_isSelf == true then
        --主动杠牌
        local TempDataIndex = {}
        local TempWeaveItemArray = {}
        local TempWeaveCount = 0
        local GangCardResult = {}
        GangCardResult.cbCardCount = 0
        GangCardResult.cbCardData = {}

        for x = 1 , 4 do
            GangCardResult.cbCardData[x] = 0
        end
        
        if GameCommon.m_WeaveItemArray[2] == nil then
            GameCommon.m_WeaveItemArray[2] = {}
        end

        if GameCommon.m_cbWeaveCount[2] == nil then
            GameCommon.m_cbWeaveCount[2] = 0
        end

        TempDataIndex = clone(self.m_cardDataIndex)
        for i = 1,#TempDataIndex do
                print("TempDataIndex11111",TempDataIndex[i])
            end
        TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
        TempWeaveCount = GameCommon.m_cbWeaveCount[2]

        local cbUserAction = 0 
        cbUserAction ,GangCardResult = GameLogic:AnalyseGangCard(TempDataIndex,TempWeaveItemArray,TempWeaveCount)

        for i = 1 , GangCardResult.cbCardCount do

        for i = 1,#TempDataIndex do
                print("TempDataIndex2222",TempDataIndex[i])
            end
            TempDataIndex[GameLogic:SwitchToCardIndex(GangCardResult.cbCardData[i])] = 0

            for i = 1,#TempDataIndex do
                print("TempDataIndex3333",TempDataIndex[i])
            end
            --杠牌处理
            local wIndex = 0
            local ispengGang = false
            --寻找组合
            if TempWeaveItemArray == nil then
                TempWeaveItemArray = {}
            end

            for j = 1,TempWeaveCount do
                local cbWeaveKind = TempWeaveItemArray[j].cbWeaveKind
                local cbCenterCard = TempWeaveItemArray[j].cbCenterCard
                if cbCenterCard == GangCardResult.cbCardData[i] and cbWeaveKind == GameCommon.WIK_PENG then
                    wIndex = j
                    ispengGang = true
                    break
                end
            end
            --数据修改
            if ispengGang == false then
                wIndex = TempWeaveCount+1
                TempWeaveCount = TempWeaveCount + 1
            end
            if TempWeaveItemArray[wIndex] == nil then
                TempWeaveItemArray[wIndex] = {}
            end
            TempWeaveItemArray[wIndex].cbPublicCard = true
            TempWeaveItemArray[wIndex].cbCenterCard = GangCardResult.cbCardData[i]
            TempWeaveItemArray[wIndex].cbWeaveKind = GameCommon.WIK_GANG
            TempWeaveItemArray[wIndex].wProvideUser = GameCommon.INVALID_CHAIR
           
            ret = GameLogic:IsTingPaiStatus(TempDataIndex,TempWeaveItemArray,TempWeaveCount)

            if ret == true then
                break
            end
        end
    else
        for i = 1 , 2 do
            --被动杠牌
            local TempDataIndex = {}
            local TempWeaveItemArray = {}
            local TempWeaveCount = 0
            TempDataIndex = clone(self.m_cardDataIndex)
            TempWeaveItemArray = clone(GameCommon.m_WeaveItemArray[2])
            TempWeaveCount = GameCommon.m_cbWeaveCount[2]
            if TempWeaveItemArray == nil then
                TempWeaveItemArray = {}
            end

            if GameLogic:IsValidCard(self.m_cbOperateCard[i]) == false then
            else
                if GameLogic:EstimateGangCard(TempDataIndex,self.m_cbOperateCard[i]) > GameCommon.WIK_NULL then
                    TempDataIndex[GameLogic:SwitchToCardIndex(self.m_cbOperateCard[i])] = 0
                    local wIndex = TempWeaveCount+1
                    TempWeaveCount = TempWeaveCount+1
                    if TempWeaveItemArray[wIndex] == nil then
                        TempWeaveItemArray[wIndex] = {}
                    end
                    TempWeaveItemArray[wIndex].cbPublicCard = true
                    TempWeaveItemArray[wIndex].cbCenterCard = self.m_cbOperateCard[i]
                    TempWeaveItemArray[wIndex].cbWeaveKind = GameCommon.WIK_GANG
                    TempWeaveItemArray[wIndex].wProvideUser = GameCommon.INVALID_CHAIR
                end
                ret = GameLogic:IsTingPaiStatus(TempDataIndex,TempWeaveItemArray,TempWeaveCount)
                if ret == true then
                    break
                end
            end
        end
    end
    return ret
end

function OprationLayer:dealPen()
    local  bbb=self.m_cbOperateCard[2]
    if self.m_cbOperateCard[2] == 0 then
        print("碰的命令")
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_PENG,self.m_cbOperateCard[1])
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
        self:initButtonStatus()
        return
    end

    self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)

    for index = 1 , 2 do
        local _data = self.m_cbOperateCard[index]
        if _data == 0 then
        else
            local _selectAll = GameLogic:EstimatePengCard(self.m_cardDataIndex,_data)
            if Bit:_and(_selectAll,GameCommon.WIK_PENG) ~= 0 then
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(7)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.5))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealPenResult(_data) end end)
                self.m_chiSelect:addChild(_button)
                local cbRemoveCard = {[1] = _data,[2] = _data,[3] = _data}
                for i = 1,3 do
                    local spt = GameCommon:GetCardHand(cbRemoveCard[i])
                    spt:setScale(0.5,0.40)
                   spt:setPosition(pt.x + (i-1)*95*0.5,pt.y+100)
                    _button:addChild(spt)
                end
            end
        end
    end
end

function OprationLayer:dealHu()
    if self.m_cbOperateCard[2] == 0 then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_CHI_HU,self.m_cbOperateCard[1])
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
        self:initButtonStatus()
        return
    end

    self.m_chiSelect:removeAllChildren()
    local size = cc.Director:getInstance():getWinSize()
    local _button = nil
    local Cout = 0

    local  pt = cc.p(60,43)

    for index = 1 , 2 do
        local _data = self.m_cbOperateCard[index]
        if _data == 0 then
        else
            local wChiHuRight = 0
            local ChiHuResult = {}
            local _selectAll = 0
            _selectAll,ChiHuResult = GameLogic:AnalyseChiHuCard(self.m_cardDataIndex,GameCommon.m_WeaveItemArray[2],GameCommon.m_cbWeaveCount[2],_data,wChiHuRight)
            if Bit:_and(_selectAll,GameCommon.WIK_CHI_HU) ~= 0 then
                _button = ccui.Button:create("game/OprationSelect_bj.png","game/OprationSelect_bj.png","game/OprationSelect_bj.png")
                _button:setTag(11)
                _button:setAnchorPoint(cc.p(0.5,0.0))
                Cout = Cout+1
                _button:setPosition(cc.p(size.width*(0.7-0.2*Cout),size.height*0.5))
                _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealHuResult(_data) end end)
                self.m_chiSelect:addChild(_button)
                local cbRemoveCard = {[1] = _data,[2] = _data,[3] = _data}

                local spt = GameCommon:GetCardHand(cbRemoveCard[2])
                spt:setPosition(pt.x + 1*80*0.48,pt.y)
                _button:addChild(spt)
            end
        end
    end
end

function OprationLayer:showYaoShuaSelect(bTing)
    self:initButtonStatus()

    local _button = nil
    local size = cc.Director:getInstance():getWinSize()

    _button = ccui.Button:create("game/op_yaoshuai.png","game/op_yaoshuai.png","game/op_yaoshuai.png")
    _button:setTag(12)
    _button:setAnchorPoint(cc.p(0.5,0.5))
    _button:setPosition(cc.p(size.width*0.4,size.height*0.3))
    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealYaoshuaiResult() end end)
    self:addChild(_button)
    _button:setTouchEnabled(bTing)
    _button:setBright(bTing)

    _button = ccui.Button:create("game/op_buzhang.png","game/op_buzhang.png","game/op_buzhang.png")
    _button:setTag(13)
    _button:setAnchorPoint(cc.p(0.5,0.5))
    _button:setPosition(cc.p(size.width*0.6,size.height*0.3))
    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealBuzhangResult() end end)
    self:addChild(_button)

    --动画
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/qingyaoshai.ExportJson")
    local armature = ccs.Armature:create("qingyaoshai")
    armature:getAnimation():playWithIndex(0,-1,-1)
    armature:setPosition(size.width*0.5,size.height*0.5)
    self:addChild(armature,1)
      
      
--      self:dealBuzhangResult()
end

function OprationLayer:showHaiDiSelect(bTing)
    if bTing==false then
        self:dealHaidiNoResult()
        return
    end
    self:initButtonStatus()
    local _button = nil
    local size = cc.Director:getInstance():getWinSize()
    local Cout = 1

    _button = ccui.Button:create("game/op_guo.png","game/op_guo.png","game/op_guo.png")
    _button:setTag(14)
    _button:setAnchorPoint(cc.p(0.5,0.5))
    Cout = Cout+1
    _button:setPosition(cc.p(size.width+100-350*0.48*2,size.height*0.3))
    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealHaidiNoResult() end end)
    self:addChild(_button)

    _button = ccui.Button:create("game/op_yaohaidi.png","game/op_yaohaidi.png","game/op_yaohaidi.png")
    _button:setTag(15)
    _button:setAnchorPoint(cc.p(0.5,0.5))
    Cout = Cout+1
    _button:setPosition(cc.p(size.width+100-350*0.48*3,size.height*0.3))
    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealHaidiYesResult() end end)
    self:addChild(_button)
    _button:setTouchEnabled(bTing)
    _button:setBright(bTing)

    if bTing==false then
        local spt = cc.Sprite:create("game/game_op_nohaidi.png")
        spt:setPosition(size.width*0.5,size.height*0.3)
        self:addChild(spt)
    end
end

function OprationLayer:showXihuiSelect(cbUserAction)
    self:initButtonStatus()

    local _button = nil
    local size = cc.Director:getInstance():getWinSize()
    local Cout = 1

    _button = ccui.Button:create("game/op_guo.png","game/op_guo.png","game/op_guo.png")
    _button:setTag(16)
    _button:setAnchorPoint(cc.p(0.5,0.5))
    _button:setPosition(cc.p(size.width-200,size.height*0.3))
    _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealXihuGuoResult() end end)
    self:addChild(_button)

    if Bit:_and(cbUserAction,GameCommon.CHK_SIXI_HU) ~= 0 then
        _button = ccui.Button:create("game/xh_dsx.png","game/xh_dsx.png","game/xh_dsx.png")
        _button:setTag(17)
        _button:setAnchorPoint(cc.p(0.5,0.5))
        _button:setPosition(cc.p(size.width-350*(0.2+Cout),size.height*0.3))
        Cout = Cout+1
        _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealXihusxResult() end end)
        self:addChild(_button)
    end

    if Bit:_and(cbUserAction,GameCommon.CHK_LIULIU_HU) ~= 0 then
        _button = ccui.Button:create("game/xh_lls.png","game/xh_lls.png","game/xh_lls.png")
        _button:setTag(18)
        _button:setAnchorPoint(cc.p(0.5,0.5))
        _button:setPosition(cc.p(size.width-350*(0.2+Cout),size.height*0.3))
        Cout = Cout+1
        _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealXihuliuResult() end end)
        self:addChild(_button)
    end

    if Bit:_and(cbUserAction,GameCommon.CHK_BANBAN_HU) ~= 0 then   -- 起手胡牌按钮
        _button = ccui.Button:create("game/op_hu.png","game/op_hu.png","game/op_hu.png")
        _button:setTag(19)
        _button:setAnchorPoint(cc.p(0.5,0.5))
        _button:setPosition(cc.p(size.width-350*(0.2+Cout),size.height*0.3))
        Cout = Cout+1
        _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealXihubbResult() end end)
        self:addChild(_button)
    end

    if Bit:_and(cbUserAction,GameCommon.CHK_QUEYISE_HU) ~= 0 then
        _button = ccui.Button:create("game/xh_qys.png","game/xh_qys.png","game/xh_qys.png")
        _button:setTag(20)
        _button:setAnchorPoint(cc.p(0.5,0.5))
        _button:setPosition(cc.p(size.width-350*(0.2+Cout),size.height*0.3))
        Cout = Cout+1
        _button:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealXihuqysResult() end end)
        self:addChild(_button)
    end
end


function OprationLayer:showZhuangSelect()
    local _button = nil
    local size = cc.Director:getInstance():getWinSize()

    local _Layout = ccui.Layout:create()
    _Layout:setSize(size)
    --_Layout:setBackGroundColorType(ccui.LAYOUT_COLOR_SOLID)
    _Layout:setBackGroundColor(cc.c3b(0,0,0))
    _Layout:setOpacity(100)
    _Layout:setTag(21)
    _Layout:setTouchEnabled(true)

    _Layout:addTouchEventListener(function(sender,event) if event == ccui.TouchEventType.ended then self:dealzhuangSelectResult() end end)
    self:addChild(_Layout)

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/qingyaoshai.ExportJson")     
    local armature = ccs.Armature:create("qingyaoshai")
    armature:getAnimation():playWithIndex(0,-1,-1)
    armature:setPosition(size.width*0.5,size.height*0.5)
    _Layout:addChild(armature,1)

    local spt = cc.Sprite:create("game/op_yaoshuaiTips.png")
    spt:setPosition(size.width*0.5,size.height*0.75)
    _Layout:addChild(spt)
end


return OprationLayer