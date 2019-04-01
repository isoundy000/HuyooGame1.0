local Common = require("common.Common")
local GameCommon = require("game.laopai.GameCommon")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local OprationLayer = require("game.laopai.OprationLayer")
local GameLogic = require("game.laopai.GameLogic")
local Bit = require("common.Bit")


--游戏动作支持
local ActionLayer = class("ActionLayer",function()
    return ccui.Layout:create()
end)

function ActionLayer:create(timeBKSprite)
    local view = ActionLayer.new()
    view:onCreate(timeBKSprite)
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

function ActionLayer:onEnter()

end

function ActionLayer:onExit()
    if self.updateTimeTipsOver then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateTimeTipsOver)
        self.updateTimeTipsOver = nil
    end
end

function ActionLayer:onCreate(timeBKSprite)

    --卡牌表现
    self.m_sptMoveCard = nil
    self.m_sptMoveCardDice = {}

    --弃牌
    self.m_discardNode = {}

    --手牌节点
    self.m_hardCardNode = {} --0左 1自己 2右 3对
    self.m_hardCardCout = {}
    self.m_WeaveCardNode = {}

    --牌蹲节点
    self.m_StoreCardNode = {}
    self.m_StoreCardAll = {}
    self.m_wFirstDice = 0
    self.m_wSendStorePos = nil
    self.m_wSendStorePos2 = nil
    self.m_wSendStoreIndex = 0

    --时钟
    self.m_timeBKSprite = nil
    self.m_timeTipsSprite = nil
    self.m_timeTips = 0
    self.updateTimeTipsOver = nil
    self.updateTimeTipsTime = 0

    --剩余麻将
    self.m_LeftCardCoutLabel = nil

    --海底特效
    self.m_haidiArmature = nil

    --庄家要甩特效
    self.m_ZhuangShuaiArmature = nil

    --游戏结算表现
    self.m_pEndTips = {}

 
    local size = cc.Director:getInstance():getWinSize()

    --时钟配置
    self.m_timeBKSprite = timeBKSprite
   

    local layout = ccs.GUIReader:getInstance():widgetFromJsonFile("laopai/mjAinimation/Mjgame_action.json")
    self:addChild(layout)   --使用

    --手牌
    self.m_hardCardNode[1] = layout:getChildByName("Panel_handcard_left")
    self.m_hardCardNode[2] = layout:getChildByName("Panel_handcard_me")
    self.m_hardCardNode[3] = layout:getChildByName("Panel_handcard_right")
    self.m_hardCardNode[4] = layout:getChildByName("Panel_handcard_face")

    --弃牌
    self.m_discardNode[1] = layout:getChildByName("Panel_discard_left")
    self.m_discardNode[2] = layout:getChildByName("Panel_discard_me")
    self.m_discardNode[3] = layout:getChildByName("Panel_discard_right")
    self.m_discardNode[4] = layout:getChildByName("Panel_discard_face")

    --牌蹲
    self.m_StoreCardNode[1] = layout:getChildByName("Panel_Tableback_left")
    self.m_StoreCardNode[2] = layout:getChildByName("Panel_Tableback_me")
    self.m_StoreCardNode[3] = layout:getChildByName("Panel_Tableback_right")
    self.m_StoreCardNode[4] = layout:getChildByName("Panel_Tableback_face")


    self.m_wFirstDice = 0
    self.m_wSendStorePos = cc.p(0,0)
    self.m_wSendStorePos2 = cc.p(0,0)
    self.m_wSendStoreIndex = 0

    --吃牌
    self.m_WeaveCardNode[1] = cc.Node:create()
    self.m_WeaveCardNode[2] = cc.Node:create()
    self.m_WeaveCardNode[3] = cc.Node:create()
    self.m_WeaveCardNode[4] = cc.Node:create()

    self:addChild(self.m_WeaveCardNode[1])
    self:addChild(self.m_WeaveCardNode[2])
    self:addChild(self.m_WeaveCardNode[3])
    self:addChild(self.m_WeaveCardNode[4])
    
    --剩余麻将
    self.m_LeftCardCoutLabel = cc.LabelTTF:create("136","",32)
    self.m_LeftCardCoutLabel:setPosition(640.00,520.00)--95,30
    self.m_LeftCardCoutLabel:setColor(cc.c3b(225,225,129))
    self:addChild(self.m_LeftCardCoutLabel)
    self.m_LeftCardCoutLabel:setVisible(false)

    --海底
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/xuanhaidi.ExportJson")
    self.m_haidiArmature = ccs.Armature:create("xuanhaidi")
    self:addChild(self.m_haidiArmature)
    self.m_haidiArmature:setVisible(false)

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/zhuangjiayaoshai.ExportJson")
    self.m_ZhuangShuaiArmature = ccs.Armature:create("zhuangjiayaoshai")
    self:addChild(self.m_ZhuangShuaiArmature)
    self.m_ZhuangShuaiArmature:setVisible(false)

end

function ActionLayer:initAction()
    --时钟隐藏

    self:initTimeTips()

    self.m_haidiArmature:setVisible(false)
    self.m_ZhuangShuaiArmature:setVisible(false)
end

function ActionLayer:onActionDelay()
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_BegainMsg)
end

function ActionLayer:onActionDelayOver()
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
end

function ActionLayer:onUserOutCardNotify(wOutCardUser)
    if wOutCardUser == 1 then
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_showOutCardTips)
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end)))
end

function ActionLayer:onUserOperateNotify()
    
end

function ActionLayer:removeHandCard(wOutCardUser,cbOutCardData)
     for i=1 , 4 do 
        for j = 1, 17 do
            print("手牌减少前:",i-1,wOutCardUser,cbOutCardData,j,GameCommon.listdatacard[i-1][j]) 
        end 
    end
    for j = #GameCommon.listdatacard[wOutCardUser] , 1 ,-1 do
        if GameCommon.listdatacard[wOutCardUser][j] == cbOutCardData then
            print("手牌删除:",j,wOutCardUser,GameCommon.listdatacard[wOutCardUser][j],cbOutCardData) 
            table.remove(GameCommon.listdatacard[wOutCardUser],j)           
            cbOutCardData = 0
        end
    end   
    for i=1 , 4 do 
        for j = 1, 17 do
            print("手牌减少后:",i-1,wOutCardUser,cbOutCardData,j,GameCommon.listdatacard[i-1][j]) 
        end 
    end 
end

function ActionLayer:showUserOutCard(wOutCardUser,cbOutCardData,wChairID)
    --延迟动作
    --self:onActionDelay()
    local m_cbOutCardData = cbOutCardData
    self.m_sptMoveCard = GameCommon:GetCardHand(cbOutCardData,wOutCardUser)
    local point = self:GetOutCardPos(wOutCardUser)
    self.m_sptMoveCard:setPosition(cc.p(point))
    self:addChild(self.m_sptMoveCard)

    self:removeHandCard(wOutCardUser,cbOutCardData)
    --手牌减少
    if self.m_hardCardCout[wOutCardUser+1] == nil then
    self.m_hardCardCout[wOutCardUser+1] = 17
    end

    self.m_hardCardCout[wOutCardUser+1] = self.m_hardCardCout[wOutCardUser+1] - 1   
     
    if wOutCardUser == 0 then
        self:showLeftTableCard()
    elseif wOutCardUser == 1 then
    elseif wOutCardUser == 2 then
        self:showRightTableCard()
    elseif wOutCardUser == 3 then
        self:showFaceTableCard()
    end

    --弃牌位置+数据
    self.m_sptMoveCard:setTag(wOutCardUser*1000+cbOutCardData)
    self.m_sptMoveCard:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.ScaleTo:create(0.05,0.55,0.4),
            cc.MoveTo:create(0.05,self:GetMoveCardViewPos(wOutCardUser))
        ),
        cc.CallFunc:create(function(sender,event) self:showUserOutCardCallBack() end),
        cc.DelayTime:create(0.1),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
    ))
    local sex = GameCommon:getUserInfo(wChairID).cbSex
    for i = 1,4 do         --
        print("游戏音效：",i,wOutCardUser,GameCommon.tagUserInfoList[i].wChairID,sex ,GameCommon.tagUserInfoList[i].cbSex)       
    end 
    GameCommon:palyCDCardSound(sex,cbOutCardData)
    --MusicControl::getInstance()->palyCDCardSound(getUserInfo(wOutCardUser)->cbSex,cbOutCardData);
end

function ActionLayer:showUserOutCardCallBack()
    GameCommon:paySoundeffect(GameCommon.Soundeffect_outCard)
    --MusicControl::getInstance()->paySoundeffect(Soundeffect_outCard);
end

function ActionLayer:showUserSendCard(wOutCardUser,cbOutCardData,wSiceCount,wOperateCode)
    --延迟动作
    --self:onActionDelay()

    --处理弃牌
    self:sptMoveCardDiscardDeal()

    local pt = self:GetSendCardPos(wOutCardUser)
    local _spt = GameCommon:GetPartCardHand(0,self.m_wSendStoreIndex)
    _spt:setPosition(pt)
    self:addChild(_spt)
    --cbOutCardData  GameCommon.listdatacard[wOutCardUser]
    --手牌增加
    if self.m_hardCardCout[wOutCardUser+1] == nil then
        self.m_hardCardCout[wOutCardUser+1] = 0
    end
--    for j = 1 , self.m_hardCardCout[wOutCardUser+1] do
--        print("手牌777:",cbOutCardData,j,GameCommon.listdatacard[wOutCardUser][j])
--    end
    for i=1 , 4 do 
       for j = 1, 17 do
            print("手牌添加前:",i-1,wOutCardUser,cbOutCardData,j,GameCommon.listdatacard[i-1][j],self.m_hardCardCout[wOutCardUser+1]) 
       end 
    end
    self.m_hardCardCout[wOutCardUser+1] = self.m_hardCardCout[wOutCardUser+1]+1
    GameCommon.listdatacard[wOutCardUser][self.m_hardCardCout[wOutCardUser+1]] = cbOutCardData
    print("座子编号:",wOutCardUser+1,"手牌添加:", self.m_hardCardCout[wOutCardUser+1] )
    
    for i=1 , 4 do 
        for j = 1, 17 do
            print("手牌添加后:",i-1,wOutCardUser,cbOutCardData,j,GameCommon.listdatacard[i-1][j]) 
        end 
    end
    --弃牌位置+数据
    _spt:setTag(wOutCardUser*1000+cbOutCardData)
    _spt:runAction(cc.Sequence:create(
        cc.MoveTo:create(0.05,self:GetMoveHardViewPos(wOutCardUser)),
        cc.CallFunc:create(function(sender,event) self:showTableCardCallback(wOutCardUser) end),
        cc.CallFunc:create(function(sender,event) self:showUserSendCardCallBack() end),
        cc.RemoveSelf:create(),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
    ))

end

function ActionLayer:showUserSendCardCallBack()
    --//MusicControl::getInstance()->paySoundeffect(Soundeffect_outCard);
end

function ActionLayer:showUserSpecialSendCard(wOutCardUser,cbOutCardData)
    --延迟动作
    --self:onActionDelay()

    --处理弃牌
    self:sptMoveCardDiscardDeal()
    if  GameCommon.wKindID == 32 then
        --显示效果
        self.m_haidiArmature:getAnimation():playWithIndex(0,-1,-1)
        self.m_haidiArmature:setPosition(self:GetMoveCardViewPos(wOutCardUser))
        self.m_haidiArmature:setVisible(true)
    end

    local size = cc.Director:getInstance():getWinSize()
    local _spt = GameCommon:GetPartCardHand(cbOutCardData,1)
    _spt:setScale(0.6)
    _spt:setPosition(self:GetSendCardPos(wOutCardUser))
    self:addChild(_spt)
    
    _spt:addTouchEventListener(function(sender,event) 
        if event == ccui.TouchEventType.began then
            _spt:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.8)))
        elseif event == ccui.TouchEventType.ended then
            _spt:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6)))
        end 
    end)
    
    _spt:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(0.2,cc.p(size.width*0.5,size.height*0.5)),
            cc.ScaleTo:create(0.2,0.8)
        ),
        cc.ScaleTo:create(0.2,0.6),
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
    ))
end

function ActionLayer:showUserOperateView(wOperateUser,cbOperateCode,cbOperateCard,cbUserCardCout)
    --延迟动作
    --self:onActionDelay()

    --处理弃牌
    if self.m_sptMoveCard == nil then
        self.m_sptMoveCard = cc.Sprite:create()
        self:addChild(self.m_sptMoveCard)
        self.m_sptMoveCard:setTag(wOperateUser*1000+cbOperateCard)
    else
        self.m_sptMoveCard:setTag(wOperateUser*1000+cbOperateCard)
    end
    self:sptMoveCardOperateDeal(cbOperateCard)
    
    if cbOperateCode == GameCommon.WIK_PENG then
        self:removeHandCard(wOperateUser,cbOperateCard)
        self:removeHandCard(wOperateUser,cbOperateCard)
    end
    if cbOperateCode == GameCommon.WIK_LEFT then
        local cbRemoveCard = {[1] = cbOperateCard+1,[2] = cbOperateCard+2}
        self:removeHandCard(wOperateUser,cbRemoveCard[1])
        self:removeHandCard(wOperateUser,cbRemoveCard[2])
    end
    if cbOperateCode == GameCommon.WIK_CENTER then
        local cbRemoveCard = {[1] = cbOperateCard+1,[2] = cbOperateCard-1}
        self:removeHandCard(wOperateUser,cbRemoveCard[1])
        self:removeHandCard(wOperateUser,cbRemoveCard[2])
    end
    if cbOperateCode == GameCommon.WIK_RIGHT then
        local cbRemoveCard = {[1] = cbOperateCard-2,[2] = cbOperateCard-1}
        self:removeHandCard(wOperateUser,cbRemoveCard[1])
        self:removeHandCard(wOperateUser,cbRemoveCard[2])
    end

    self.m_hardCardCout[wOperateUser+1] = cbUserCardCout
    print("玩家座子编号为:",wOperateUser+1, "（组合牌控制）手牌数量获取:",self.m_hardCardCout[wOperateUser+1],cbUserCardCout)
    --动作显示
    self:showAction(wOperateUser,cbOperateCode)

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
    ))
end

function ActionLayer:sptMoveCardDiscardDeal()
    for i = 1 , 2 do
        if self.m_sptMoveCardDice[i] == nil then
            
        else
            local _data = self.m_sptMoveCardDice[i]:getTag()
            local index = math.floor(_data / 1000)
            local cardData = _data%1000

            self.m_sptMoveCardDice[i]:runAction(cc.Sequence:create(
                cc.Spawn:create(
                cc.DelayTime:create((i-1)*0.05),
                cc.ScaleTo:create(0.05,0.47),
                cc.MoveTo:create(0.05,self:GetMoveDiscardViewPos(index,self.m_discardNode[index+1]:getChildrenCount()+(i-1))
                )),
                cc.CallFunc:create(function(sender,event) self:upDataDiscardView(_data) end),
                cc.RemoveSelf:create(),
                nil
            ))
            self.m_sptMoveCardDice[i] = nil
        end
    end

    if self.m_sptMoveCard == nil then
        return
    end

    local _data = self.m_sptMoveCard:getTag()
    local index = math.floor(_data / 1000)
    local cardData = _data %100

    self.m_sptMoveCard:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.ScaleTo:create(0.05,0.47),
        cc.MoveTo:create(0.05,self:GetMoveDiscardViewPos(index,self.m_discardNode[index+1]:getChildrenCount())
        )),
        cc.CallFunc:create(function(sender,event) self:upDataDiscardView(_data) end),
        cc.RemoveSelf:create(),
        nil
    ))
    
    self.m_sptMoveCard = nil
end

function ActionLayer:sptMoveCardOperateDeal(cbOperateCard)
    for i = 1 , 2 do
        if self.m_sptMoveCardDice[i] == nil then
        else
            local _data = self.m_sptMoveCardDice[i]:getTag()
            local index = math.floor(_data / 1000)
            local cardData = _data % 1000
            print("要处理的牌，弃牌",cbOperateCard,cardData)
            if cbOperateCard ~= cardData or ( self.m_sptMoveCardDice[1] ==  self.m_sptMoveCardDice[2] and i==2 ) then
                self.m_sptMoveCardDice[i]:runAction(cc.Sequence:create(
                cc.Spawn:create(
                cc.DelayTime:create((i-1)*0.2),
                cc.ScaleTo:create(0.2,0.47),
                cc.MoveTo:create(0.2,self:GetMoveDiscardViewPos(index,self.m_discardNode[index+1]:getChildrenCount()+(i-1))
                )),
                cc.CallFunc:create(function(sender,event) self:upDataDiscardView(_data) end),
                cc.RemoveSelf:create(),
                nil
                ))
            else
                local tmpsptMoveCardDice = self.m_sptMoveCardDice[i]
                _data = tmpsptMoveCardDice:getTag()
                self.m_sptMoveCardDice[i]:runAction(cc.Sequence:create(
--                    cc.Spawn:create(
--                    cc.ScaleTo:create(0.2,0.47),
--                    cc.MoveTo:create(0.2,self:GetMoveDiscardViewPos(index,self.m_discardNode[index+1]:getChildrenCount()+(i-1))
--                    )),
                    --cc.CallFunc:create(function(sender,event) self:upDataDiscardView(_data) end),
                    cc.RemoveSelf:create(),
                    nil
                ))
            end
            self.m_sptMoveCardDice[i] = nil
        end
    end

    if self.m_sptMoveCard == nil then
        return
    end

    local _data = self.m_sptMoveCard:getTag()
    local index = math.floor(_data / 1000)
    local cardData = _data %100

    self.m_sptMoveCard:runAction(cc.Sequence:create(
        cc.Spawn:create(
        cc.ScaleTo:create(0.2,0.1),
        cc.MoveTo:create(0.2,self:GetMoveOperateViewPos(index)
        )),
        cc.CallFunc:create(function(sender,event) self:upDataOperateView(_data) end),
        cc.RemoveSelf:create(),
        nil
    ))
    
    self.m_sptMoveCard = nil
    
end

function ActionLayer:showLeftCardView(leftCout)
    self.m_LeftCardCoutLabel:setString(string.format("剩余%d",leftCout))
    self.m_LeftCardCoutLabel:setVisible(true)
end

function ActionLayer:showCastDiceView(wDiceCount)
    --延迟动作
    --self:onActionDelay()

    local size = cc.Director:getInstance():getWinSize()

     ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/yaoshaizi.ExportJson")
     local m_outCardTips= ccs.Armature:create("yaoshaizi")
     m_outCardTips:getAnimation():playWithIndex(0,-1,0)
     m_outCardTips:setPosition(cc.p(size.width*0.5,size.height*0.5))
     self:addChild(m_outCardTips,1)
     m_outCardTips:setTag(wDiceCount)
--     local _data = m_outCardTips:getTag()
     m_outCardTips:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function(sender,event) self:showCastDiceCallBack(wDiceCount) end),
        cc.RemoveSelf:create(),
        nil
     ))
      GameCommon:paySoundeffect(GameCommon.Soundeffect_YaoShuaiZi);
     --MusicControl::getInstance()->paySoundeffect(Soundeffect_YaoShuaiZi);

end

function ActionLayer:showCastDiceCallBack(obj)
    local wDiceCount = obj

    local size = cc.Director:getInstance():getWinSize()
    local cbSiceFirst = Bit:_and( Bit:_rshift(wDiceCount,8),0xff)
    local cbSiceSecond = Bit:_and(wDiceCount,0xff)

    local _node = cc.Node:create()
    self:addChild(_node)

    local spt = GameCommon:GetShuaiZi(cbSiceFirst)
    spt:setPosition(size.width*0.45,size.height*0.52)
    spt:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.FadeOut:create(0.3),
        nil
    ))
    _node:addChild(spt)

    spt = GameCommon:GetShuaiZi(cbSiceSecond)
    spt:setPosition(size.width*0.55,size.height*0.52)
    spt:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function(sender,event) self:showCastDiceCallBackShowCard() end),
        cc.DelayTime:create(0.5),
        cc.RemoveSelf:create(),
        nil
    ))
    _node:addChild(spt)
end

function ActionLayer:showCastDiceCallBackShowCard()
    if GameCommon.m_SiceType == GameCommon.SiceType_gameStart then
        return
    end

    local _node = cc.Node:create()
    self:addChild(_node)

    local size = cc.Director:getInstance():getWinSize()
    self:removeStoreCard(GameCommon.m_wDiceCount,GameCommon.WIK_GANG)

    for i = 1 ,2 do
        if GameCommon.m_wDiceCard[i] == 0 then
        else
            self.m_sptMoveCardDice[i] = GameCommon:GetPartCardHand(GameCommon.m_wDiceCard[i])
            self.m_sptMoveCardDice[i]:setTag(GameCommon.m_wDiceUser * 1000+GameCommon.m_wDiceCard[i])
            self.m_sptMoveCardDice[i]:setScale(0.8)
            if i == 1 then
                self.m_sptMoveCardDice[i]:setPosition(self.m_wSendStorePos)
            else
                self.m_sptMoveCardDice[i]:setPosition(self.m_wSendStorePos2)
            end
            self.m_sptMoveCardDice[i]:runAction(cc.MoveTo:create(0.2,cc.p(size.width*(0.45+i*0.1),size.height*0.52)))
            self:addChild(self.m_sptMoveCardDice[i])
        end
    end
    
    _node:runAction(cc.Sequence:create(
        cc.DelayTime:create(2.0),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        cc.RemoveSelf:create(),
        nil
    ))
end

function ActionLayer:showHaiDiView(wChairID)
    --处理弃牌
    self:sptMoveCardDiscardDeal()

    --显示效果
    self.m_haidiArmature:getAnimation():playWithIndex(0,-1,-1)
    self.m_haidiArmature:setPosition(self:GetMoveCardViewPos(wChairID))
    self.m_haidiArmature:setVisible(true)
end

function ActionLayer:showZhuangView(wChairID)
    --显示效果
--    self.m_ZhuangShuaiArmature:getAnimation():playWithIndex(0,-1,-1)
--    self.m_ZhuangShuaiArmature:setPosition(self:GetMoveCardViewPos(wChairID))
--    self.m_ZhuangShuaiArmature:setVisible(true)
end

function ActionLayer:GetOutCardPos(wActionUser)--出牌位置

    local size = cc.Director:getInstance():getWinSize()

   -- local cbTempCout = 13

    local point = cc.p(0,0)
    
    if wActionUser == 0 then
        point = self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(0,0))--0,cbTempCout*30     128,720
    elseif wActionUser == 1 then
        point = GameCommon.m_MyTurnPos
    elseif wActionUser == 2 then
        point = self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(0,0))--0,cbTempCout*30
    elseif wActionUser == 3 then
        point = self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(300,300))--cbTempCout*80*0.48,0
    else
        point = self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(size.width*0.5,size.height*0.5))
    end

    return point
end

function ActionLayer:GetSendCardPos(wActionUser)
    return self.m_wSendStorePos
end

function ActionLayer:GetMoveCardViewPos(wActionUser)
    local size = cc.Director:getInstance():getWinSize()

    if wActionUser == 0 then
        return cc.p(size.width*0.25,size.height*0.65)
    elseif wActionUser == 1 then
        return cc.p(size.width*0.25,size.height*0.55)
    elseif wActionUser == 2 then
        return cc.p(size.width*0.7,size.height*0.55)
    elseif wActionUser == 3 then
        return cc.p(size.width*0.7,size.height*0.65)
    else
        return cc.p(size.width*0.5,size.height*0.5)
    end
end

function ActionLayer:GetMoveHardViewPos(wActionUser,isMove)
    if isMove == nil then
        isMove = false
    end

    local size = cc.Director:getInstance():getWinSize()

    local cbTempCout = 17
    if isMove == true then
        cbTempCout = self.m_hardCardCout[wActionUser+1]
    end

    if wActionUser == 0 then
        return  cc.p(size.width*0.1,size.height*0.9)                   --self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(cbTempCout*30,cbTempCout*30))      --     -
    elseif wActionUser == 1 then
        return  cc.p(size.width*0.5,size.height*0.1)                                                    --cc.p(GameCommon.m_MyHandCardPos.x + 60,GameCommon.m_MyHandCardPos.y)
    elseif wActionUser == 2 then
        return  cc.p(size.width*0.9,size.height*0.1)                     --self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(cbTempCout*30,-cbTempCout*30))             -- 
    elseif wActionUser == 3 then
        return  cc.p(size.width*0.9,size.height*0.9)                    --self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(cbTempCout*30,cbTempCout*30))
    else
        return      cc.p(size.width*0.5,size.height*0.5)                    --self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(cc.p(size.width*0.5,size.height*0.5))
    end
end

function ActionLayer:GetMoveDiscardViewPos(wActionUser,Cout,isWorldPos)
    if isWorldPos == nil then
        isWorldPos = true
    end        
    local tag = 0
    local pt = cc.p(0,0)
    if wActionUser == 0 then
        tag = Cout
--        if Cout > 7 then
--            pt.x = pt.x + (Cout - 8)*80*0.4 - 310
--            pt.y = -96*0.40 + 10
--        else
            pt.x = pt.x + Cout*80*0.4 - 310
            pt.y = 0 
--        end
    elseif wActionUser == 1 then
        tag = Cout
--        if Cout > 7 then
--            tag = -100+Cout          
--            pt.x = pt.x + (Cout-8)*80*0.4 - 410 
--            pt.y = 150 - 96*0.4  
--        else
            pt.x = pt.x + Cout*80*0.4 - 410
            pt.y = 140
--        end
    elseif wActionUser == 2 then
        tag = 100-Cout
--        if Cout > 7 then           
--            pt.x = pt.x - (Cout-8)*80*0.4 + 320 
--            pt.y = 120 - 96*0.4 
--        else
            pt.x = pt.x - Cout*80*0.4 + 320
            pt.y = 110
--        end
    elseif wActionUser == 3 then
        tag = Cout
--        if Cout > 7 then           
--            pt.x = pt.x - (Cout-8)*80*0.4+ 420
--            pt.y = - 38 - 96*0.4
--        else
            pt.x = pt.x - Cout*80*0.4 + 425
            pt.y = - 28 
--        end        
    end

    
    if isWorldPos == true then
        local point = {}
        point = self.m_discardNode[wActionUser+1]:convertToWorldSpace(pt)
        return point
    else
        return pt
    end
end

function ActionLayer:GetMoveOperateViewPos(wActionUser,isWorldPos)
    if isWorldPos == nil then
        isWorldPos = true
    end

    local WeaveCout = GameCommon.m_cbWeaveCount[wActionUser+1]
    local pt = cc.p(0,0)

    if wActionUser == 0 then
        pt = cc.p(0,-(WeaveCout*3)*60*0.5)
    elseif wActionUser == 1 then
    elseif wActionUser == 2 then
        pt = cc.p(0,(WeaveCout*3 - 0.5)*60*0.5)
    elseif wActionUser == 3 then
        pt = cc.p(-(WeaveCout*3)*60*0.5,0)
    end

    if isWorldPos == true then
        return self.m_hardCardNode[wActionUser+1]:convertToWorldSpace(pt)
    else
        return pt
    end
end

function ActionLayer:GetActorPos(wActionUser)
    local size = cc.Director:getInstance():getWinSize()
    if wActionUser == 0 then
        return cc.p(size.width*0.2,size.height*0.55)
    elseif wActionUser == 1 then
        return cc.p(size.width*0.5,size.height*0.4)
    elseif wActionUser == 2 then
        return cc.p(size.width*0.8,size.height*0.55)
    elseif wActionUser == 3 then
        return cc.p(size.width*0.5,size.height*0.8)
    else
        return cc.p(size.width*0.5,size.height*0.5)
    end
end

function ActionLayer:GetClockPos(wActionUser)
    local size = cc.Director:getInstance():getWinSize()

    if wActionUser == 0 then
        return cc.p(size.width*0.3,size.height*0.65)
    elseif wActionUser == 1 then
        return cc.p(size.width*0.5,size.height*0.5)
    elseif wActionUser == 2 then
        return cc.p(size.width*0.7,size.height*0.35)
    elseif wActionUser == 3 then
        return cc.p(size.width*0.7,size.height*0.65)
    else
        return cc.p(size.width*0.5,size.height*0.5)
    end
end

function ActionLayer:initTimeTips()
    self.m_timeTips = 0
    self.m_timeBKSprite:setVisible(true)
end

function ActionLayer:showTimeTips(ViewID,isMe)
    self.m_timeTips=13
    if isMe == nil then
        isMe = false
    end
    local rot = 0
    if ViewID == 0 then
        rot = 90
    elseif ViewID == 1 then
        rot = 0
    elseif ViewID == 2 then
        rot = -90
    elseif ViewID == 3 then
        rot = 180
    else  
        self.m_timeTips = 1
    end
    self.m_timeBKSprite:setVisible(true)
    if ViewID == 1 then
        self.m_timeBKSprite:setTag(ViewID)
    else
        self.m_timeBKSprite:setTag(0)
    end
    local uiImage_current = ccui.Helper:seekWidgetByName(self.m_timeBKSprite,"Image_current")
    uiImage_current:setRotation(rot)
    local uiAtlasLabel_timeTips = ccui.Helper:seekWidgetByName(self.m_timeBKSprite,"AtlasLabel_timeTips")
    uiAtlasLabel_timeTips:setString(string.format("%d",self.m_timeTips))
    local function onEventCountdown(sender,event)
        self.m_timeTips = self.m_timeTips - 1
        if self.m_timeTips == 0 then
            self:showTimeTipsOver()
            uiAtlasLabel_timeTips:setString(string.format("%d",self.m_timeTips))
            uiImage_current:stopAllActions()
            uiImage_current:setOpacity(1)
            uiImage_current:runAction(cc.Sequence:create(cc.FadeIn:create(0.8)))          
            uiAtlasLabel_timeTips:stopAllActions()
            uiAtlasLabel_timeTips:setOpacity(1)
            uiAtlasLabel_timeTips:runAction(cc.Sequence:create(cc.FadeIn:create(0.8))) 
        else
            uiAtlasLabel_timeTips:setString(string.format("%d",self.m_timeTips))
            self.m_timeBKSprite:stopAllActions()
            self.m_timeBKSprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventCountdown)))
            uiImage_current:stopAllActions()
            uiImage_current:setOpacity(0)
            uiImage_current:runAction(cc.Sequence:create(cc.FadeIn:create(0.8),cc.FadeOut:create(0.2)))
            uiAtlasLabel_timeTips:stopAllActions()
            uiAtlasLabel_timeTips:setOpacity(0)
            uiAtlasLabel_timeTips:runAction(cc.Sequence:create(cc.FadeIn:create(0.8),cc.FadeOut:create(0.2))) 
        end
                
--        if self.m_timeTips > 0 then
--            self:showTimeTipsOver()
--            self.m_timeBKSprite:stopAllActions()
--            self.m_timeBKSprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventCountdown)))
--        end
    end
    onEventCountdown()
end
function ActionLayer:showTimeTipszhuang(ViewID)
    local rot = 0
    if ViewID == 0 then
        rot = 90
    elseif ViewID == 1 then
        rot = 0
    elseif ViewID == 2 then
        rot = -90
    elseif ViewID == 3 then
        rot = 180
    end
    local uiImage_current = ccui.Helper:seekWidgetByName(self.m_timeBKSprite,"Image_current")
    uiImage_current:setRotation(rot)
end
function ActionLayer:showTimeTipsOver(delta)
    self.m_timeTips = 0
    self.m_timeBKSprite:setVisible(true)
    if self.m_timeBKSprite:getTag() == 1 then
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_OutOpration)
    end
end
function ActionLayer:showTimeOver()
    self.m_timeTips = 1
    local uiImage_current = ccui.Helper:seekWidgetByName(self.m_timeBKSprite,"Image_current")
    local uiAtlasLabel_timeTips = ccui.Helper:seekWidgetByName(self.m_timeBKSprite,"AtlasLabel_timeTips")
    self.m_timeBKSprite:setTag(0)
end
function ActionLayer:setDiscardView(cbDiscardCount,cbDiscardCard)
    for i = 1 , 4 do
        local ID = GameCommon:SwitchViewChairID(i-1)
        self.m_discardNode[ID+1]:removeAllChildren()
        for j = 1 , cbDiscardCount[i] do
            local spt = GameCommon:GetPartCardHand(cbDiscardCard[i][j],ID)
            local Count = j-1
            local pt = cc.p(0,0)
            local tag = 0
            pt = self:GetMoveDiscardViewPos(ID,Count,false)

            if ID == 0 then
                tag = Count
            elseif ID == 1 then
                tag = Count
                if Count > 10 then
                    tag = -100+Count
                end
            elseif ID == 2 then
                tag = 100 - Count
            elseif ID == 3 then
                tag = Count
            end
            spt:setPosition(pt)
            spt:setScale(0.4)
            spt:setTouchEnabled(true)
            spt:addTouchEventListener(function(sender,event)                                          
                if event == ccui.TouchEventType.began then     
                    print("游戏点击1")  
                    self._sptCard = GameCommon:GetPartCardHand(cbDiscardCard[i][j],4)                                         
                    self._sptCard:setPosition(640,360)
                    self:addChild(self._sptCard)
                    self._sptCard:setScale(0.0)   
                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                  
                elseif event == ccui.TouchEventType.moved then 
                    self._sptCard:setScale(0.6,0,4)     
--                    print("游戏点击1")  
--                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
--                    self._sptCard:setPosition(640,360)
--                    self:addChild(self._sptCard)
--                    self._sptCard:setScale(0.0)   
--                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                     
                else
                    print("游戏点击22")  
                    self._sptCard:setVisible(false) 
                    self._sptCard:setScale(0.0)    
                    self:removeChild(self._sptCard)      
                end                    
            end) 
            self.m_discardNode[ID+1]:addChild(spt,tag)
        end
    end
end

function ActionLayer:upDataDiscardView(obj)
    local _data = obj
    local index = math.floor(_data/1000)
    local cardData = _data % 1000

    self.m_sptMoveCard = nil

    local spt = GameCommon:GetPartCardHand(cardData)
    local Cout = self.m_discardNode[index+1]:getChildrenCount()
    local pt = cc.p(0,0)
    local tag = 0

    if index == 0 then
        tag = Cout
--        if Cout > 7 then
--            pt.x = pt.x + (Cout - 8)*80*0.4 - 310
--            pt.y = -96*0.40 + 10
--        else
            pt.x = pt.x + Cout*80*0.4 - 310
            pt.y = 0 
--        end
    elseif index == 1 then
        tag = Cout
--        if Cout > 7 then
--            tag = -100+Cout          
--            pt.x = pt.x + (Cout-8)*80*0.4 - 410 
--            pt.y = 150 - 96*0.4 
--        else
            pt.x = pt.x + Cout*80*0.4 - 410
            pt.y = 140
--        end
    elseif index == 2 then
        tag = 100-Cout
--        if Cout > 7 then           
--            pt.x = pt.x - (Cout-8)*80*0.4 + 320 
--            pt.y = 120 - 96*0.4 
--        else
            pt.x = pt.x - Cout*80*0.4 + 320
            pt.y = 110
--        end
    elseif index == 3 then
        tag = Cout
--        if Cout > 7 then           
--            pt.x = pt.x - (Cout-8)*80*0.4+ 420
--            pt.y = - 38 - 96*0.4
--        else
            pt.x = pt.x - Cout*80*0.4 + 425
            pt.y = - 28 
--        end
    end
    spt:setPosition(pt)
    spt:setScale(0.4)
    spt:setTouchEnabled(true)
    spt:addTouchEventListener(function(sender,event)                                          
        if event == ccui.TouchEventType.began then     
            print("游戏点击1")  
            self._sptCard = GameCommon:GetPartCardHand(cardData,4)                                         
            self._sptCard:setPosition(640,360)
            self:addChild(self._sptCard)
            self._sptCard:setScale(0.0)   
            self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                  
        elseif event == ccui.TouchEventType.moved then
            self._sptCard:setScale(0.6,0,4)      
--            print("游戏点击1")  
--            self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
--            self._sptCard:setPosition(640,360)
--            self:addChild(self._sptCard)
--            self._sptCard:setScale(0.0)   
--            self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                     
        else
            print("游戏点击22")  
            self._sptCard:setVisible(false) 
            self._sptCard:setScale(0.0)    
            self:removeChild(self._sptCard)      
        end                    
    end) 
    self.m_discardNode[index+1]:addChild(spt,tag)
end

function ActionLayer:upDataOperateView(_obj)
    local _data = _obj
    local index = math.floor(_data/1000)
    local cardData = _data%1000

    if index == 0 then
        self:showLeftTableCard()
    elseif index == 1 then
    elseif index == 2 then
        self:showRightTableCard()
    elseif index == 3 then
        self:showFaceTableCard()
    end
end

function ActionLayer:initTableCard(wBankerUser)
    local count = 16

    for i = 1 ,4 do
        if i == 2 then
        
        else
            self.m_hardCardNode[i]:removeAllChildren()
            if wBankerUser == i -1 then
                count = 17
            else
                count = 16
            end
            local data = {}

            for x = 1 , count do
                data[x] = 0
            end
      

            self.m_hardCardCout[i] = count
            print("初始化游戏手牌999:",i, "手牌数量获取:",self.m_hardCardCout[i] )
            if i == 1 then
                self:showLeftTableCard(data,count,0)
            end

            if i == 3 then
                self:showRightTableCard(data,count,0)
            end

            if i == 4 then
                self:showFaceTableCard(data,count,0)
            end
        end
    end
    
end

function ActionLayer:showSpecialCard(cbCardData,wActionUser,cbUserAction)
    --self:onActionDelay()
    local cardCout = 0
    for i = 1 , 17 do
        if cbCardData[i] > 0 then
            cardCout = cardCout + 1
        end
    end
    
    local tempCardData = {}
    for x = 1 , 17 do
        tempCardData[x] = 0
    end
    
    local tempCardDataCout = 0
    local tempCardIndex = {}
    for x = 1 , 34 do
        tempCardIndex[x] = 0
    end
    

    tempCardIndex = GameLogic:SwitchToCardIndexTwo(cbCardData,cardCout)
    local count = 0
    local showLun = true
    if Bit:_and(cbUserAction,GameCommon.CHK_SIXI_HU) ~= 0 then
        self:showXhAction(wActionUser,GameCommon.CHK_SIXI_HU,count)

        for i = 1,34 do
            if tempCardIndex[i] > 3 then
                local data = GameLogic:SwitchToCardDataOne(i)
                for j = 1 , tempCardIndex[i] do
                    tempCardDataCout = tempCardDataCout+1
                    tempCardData[tempCardDataCout] = data
                end
            end
        end
        count = count+1
        showLun = false
    end
    if Bit:_and(cbUserAction,GameCommon.CHK_LIULIU_HU) ~= 0 then
        self:showXhAction(wActionUser,GameCommon.CHK_LIULIU_HU,count)
        for i = 1 ,34 do
            if tempCardIndex[i] >= 3 then
                local data = GameLogic:SwitchToCardDataOne(i)
                for j = 1 , 3 do
                    tempCardDataCout = tempCardDataCout + 1
                    tempCardData[tempCardDataCout] = data
                    
                end
                count = count + 1
                showLun = false
            end
        end
    end
    if Bit:_and(cbUserAction,GameCommon.CHK_BANBAN_HU) ~= 0 then
        self:showXhAction(wActionUser,GameCommon.CHK_BANBAN_HU,count)
        tempCardData = clone(cbCardData)
        tempCardDataCout = cardCout
        count = count + 1
        showLun = true
    end
    if Bit:_and(cbUserAction,GameCommon.CHK_QUEYISE_HU) ~= 0 then
        self:showXhAction(wActionUser,GameCommon.CHK_QUEYISE_HU,count)
        tempCardData = clone(cbCardData)
        tempCardDataCout = cardCout
        count = count + 1
        showLun = true
    end

    if showLun == true then
        self:runAction(cc.Sequence:create(
        cc.DelayTime:create(3.0),
--        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
        ))
    else
        self:runAction(cc.Sequence:create(
        cc.DelayTime:create(3.0),
        cc.CallFunc:create(function(sender,event) self:showSpecialCardCallBack(wActionUser) end),
--        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
        ))
    end

    --显示手牌
    if wActionUser == 0 then
        self:showLeftTableCard(tempCardData,cardCout,cbUserAction)
    elseif  wActionUser == 1 then
        self:showMeTableCard(tempCardData,cardCout,cbUserAction)
        self:setHandCard(tempCardData,cardCout,true)
    elseif  wActionUser == 2 then
        self:showRightTableCard(tempCardData,cardCout,cbUserAction)
    elseif  wActionUser == 3 then
        self:showFaceTableCard(tempCardData,cardCout,cbUserAction)
    end
end

function ActionLayer:showSpecialCardCallBack(_obj)
    if _obj == 0 then
        self:showLeftTableCard()
    elseif _obj == 1 then
        self:showMeTableCard()
    elseif _obj == 2 then
        self:showRightTableCard()
    elseif _obj == 3 then
        self:showFaceTableCard()
    end
end

function ActionLayer:showLeftTableCard(cbCardData,Cout,cbUserAction)   --  0号位组合牌桌面显示
    if cbCardData == nil then
        cbCardData = nil
    end

--    if Cout == nil then
--        Cout = 0
--    end

    if cbUserAction == nil then
        cbUserAction = 0
    end
   -- GameCommon.listdatacard[1]
    local winSize = cc.Director:getInstance():getWinSize()
    local cbTempCardData = {}
    for x = 1 , #GameCommon.listdatacard[0] do
        cbTempCardData[x] = GameCommon.listdatacard[0][x]
        print("自己0：",cbTempCardData[x],GameCommon.listdatacard[0][x])
    end
    
    local cbTempCout = self.m_hardCardCout[1]
    self.m_hardCardNode[1]:removeAllChildren()
    if cbUserAction ~= 0 then
--        cbTempCardData = clone(cbCardData)
--        cbTempCout = Cout
--        self.m_hardCardCout[1] = cbTempCout
    end

    --吃碰牌
    local WeaveCout = GameCommon.m_cbWeaveCount[1]
    for j = 1 , WeaveCout do
        local WeaveItemCard = {}
        for x = 1 , 4 do
            WeaveItemCard[x] = 0
        end
        
        WeaveItemCard = self:GetWeaveItemCard(GameCommon.m_WeaveItemArray[1][j])
        for i = 1 , 3 do
        local pt = cc.p((j-1)*45-26.6,-(i-2.4)*120*0.4)
--           if j <= 2 then 
--                 pt = cc.p((i-1.2)*95*0.4+(j-1)*130,-(1-2.4)*120*0.4)
--           elseif j <= 4  then  
--                 pt = cc.p((i-1.2)*95*0.4+(j-3)*130,-(2-2.4)*120*0.4)
--           end 
            local _spt = GameCommon:GetPartCardHand(WeaveItemCard[i],0)
            if (GameCommon.m_WeaveItemArray[1][j].cbWeaveKind == GameCommon.WIK_LEFT or GameCommon.m_WeaveItemArray[1][j].cbWeaveKind == GameCommon.WIK_CENTER or GameCommon.m_WeaveItemArray[1][j].cbWeaveKind == GameCommon.WIK_RIGHT) and WeaveItemCard[i] == GameCommon.m_WeaveItemArray[1][j].cbCenterCard then
                _spt:setColor(cc.c3b(200,200,200))
            end
            _spt:setPosition(pt)
            _spt:setScale(0.4)
            _spt:setTouchEnabled(true)
            _spt:addTouchEventListener(function(sender,event)                                          
                if event == ccui.TouchEventType.began then     
                    print("游戏点击1")  
                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
                    self._sptCard:setPosition(640,360)
                    self:addChild(self._sptCard)
                    self._sptCard:setScale(0.0)   
                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))
                elseif event == ccui.TouchEventType.moved then 
                    self._sptCard:setScale(0.6,0,4)    
--                    print("游戏点击1")  
--                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
--                    self._sptCard:setPosition(640,360)
--                    self:addChild(self._sptCard)
--                    self._sptCard:setScale(0.0)   
--                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                     
                else
                    print("游戏点击22")  
                    self._sptCard:setVisible(false) 
                    self._sptCard:setScale(0.0)    
                    self:removeChild(self._sptCard)      
                end                    
            end) 
            self.m_hardCardNode[1]:addChild(_spt)
        end
    end
    if GameCommon.serverData.cbRoomFriend == -1 then
        if cbTempCout == 17 then
            cbTempCardData[17] = GameCommon.m_crad_17
        end  
        --手牌
        for j = 1 , cbTempCout do
            local _spt = nil
            print("手牌111",cbTempCardData[j],cbTempCout,j)
            if cbTempCardData[j] == 0 then
            _spt = GameCommon:GetPartCardHand(cbTempCardData[j],0)
            else
                _spt = GameCommon:GetPartCardHand(cbTempCardData[j],0)
            end
            local pt = cc.p(-((j-1))*95*0.3-40+456,-33)  
            if j > 17 then
                pt = cc.p(-((j-1-17))*95*0.3-40+456,-71)
            end          
            if cbTempCardData[j] == nil then 
            break 
            end
            _spt:setPosition(pt)
            _spt:setScale(0.3)
            self.m_hardCardNode[1]:addChild(_spt)
        end
    end 
end

function ActionLayer:showRightTableCard(cbCardData,Cout,cbUserAction)  --  2号位组合牌桌面显示

    if cbCardData == nil then
        cbCardData = nil
    end

--    if Cout == nil then
--        Cout = 0
--    end

    if cbUserAction == nil then
        cbUserAction = 0
    end

    local winSize = cc.Director:getInstance():getWinSize()
    local cbTempCardData = {}
    for x = 1 , #GameCommon.listdatacard[2] do
        cbTempCardData[x] = GameCommon.listdatacard[2][x]
        print("自己2：",cbTempCardData[x],GameCommon.listdatacard[2][x])
    end
    
    local cbTempCout = self.m_hardCardCout[3]
    self.m_hardCardNode[3]:removeAllChildren()

    if cbUserAction ~= 0 then
--        cbTempCardData = clone(cbCardData)
--        cbTempCout = Cout
--        self.m_hardCardCout[3] = cbTempCout
    print("玩家位置:",3, "手牌数量获取:",self.m_hardCardCout[3] )
    end

    --吃碰牌
    local WeaveCout = GameCommon.m_cbWeaveCount[3]
    for j = 1 , WeaveCout do
        local WeaveItemCard = {}
        for x = 1 , 4 do
            WeaveItemCard[x] = 0
        end
        
        WeaveItemCard = self:GetWeaveItemCard(GameCommon.m_WeaveItemArray[3][j])

        for i = 1 , 3 do     
            local pt = cc.p(-(j-1)*45 + 210,(i-2.4)*120*0.4+15 )
--            if j <= 2 then 
--                  pt = cc.p((6-i)*95*0.4-(j-1)*130 + 20,(1-2.4)*120*0.4+30)
--            elseif j <= 4  then  
--                  pt = cc.p((6-i)*95*0.4-(j-3)*130 + 20,(2-2.4)*120*0.4+30)
--            end 
            local _spt = GameCommon:GetPartCardHand(WeaveItemCard[i],2)
            if (GameCommon.m_WeaveItemArray[3][j].cbWeaveKind == GameCommon.WIK_LEFT or GameCommon.m_WeaveItemArray[3][j].cbWeaveKind == GameCommon.WIK_CENTER or GameCommon.m_WeaveItemArray[3][j].cbWeaveKind == GameCommon.WIK_RIGHT) and WeaveItemCard[i] == GameCommon.m_WeaveItemArray[3][j].cbCenterCard then
                _spt:setColor(cc.c3b(200,200,200))
            end 
            
            _spt:setPosition(pt)
            _spt:setScale(0.4)
            _spt:setTouchEnabled(true)
            _spt:addTouchEventListener(function(sender,event)                                          
                if event == ccui.TouchEventType.began then     
                    print("游戏点击1")  
                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
                    self._sptCard:setPosition(640,360)
                    self:addChild(self._sptCard)
                    self._sptCard:setScale(0.0)   
                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                  
                elseif event == ccui.TouchEventType.moved then    
                    self._sptCard:setScale(0.6,0,4) 
--                    print("游戏点击1")  
--                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
--                    self._sptCard:setPosition(640,360)
--                    self:addChild(self._sptCard)
--                    self._sptCard:setScale(0.0)   
--                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                     
                else
                    print("游戏点击22")  
                    self._sptCard:setVisible(false) 
                    self._sptCard:setScale(0.0)    
                    self:removeChild(self._sptCard)      
                end                    
            end)
          
            self.m_hardCardNode[3]:addChild(_spt,4-(i-1)+(10-(j-1))*10)
        end
    end
    
     if GameCommon.serverData.cbRoomFriend == -1 then
    --手牌
        if cbTempCout == 17 and cbTempCardData[17] >= 60 then
            cbTempCardData[17] = GameCommon.m_crad_17
        end  
        for j = 1 , cbTempCout do
            local _spt = nil
            if cbTempCardData[j] == 0 then
                _spt = GameCommon:GetCardHand(cbTempCardData[j],2)
            else
                _spt = GameCommon:GetPartCardHand(cbTempCardData[j])
            end
        local pt = cc.p((j-1)*95*0.3+210-456,60)
        if j > 17 then
            pt = cc.p((j-1-17)*95*0.3+210-456,22)
        end
            print("手牌222",cbTempCardData[j],cbTempCout)
            if cbTempCardData[j] == nil then 
                break 
            end
            _spt:setPosition(pt)
            _spt:setScale(0.3)
            self.m_hardCardNode[3]:addChild(_spt,cbTempCout - (j-1))
        end
    end 
end

function ActionLayer:showFaceTableCard(cbCardData,Cout,cbUserAction)   --  3号位组合牌桌面显示
    if cbCardData == nil then
        cbCardData = nil
    end
--    if Cout == nil then
--        Cout = 0
--    end
    if cbUserAction == nil then
        cbUserAction = 0
    end
    local winSize = cc.Director:getInstance():getWinSize()
    local cbTempCardData = {}
    for x = 1 , #GameCommon.listdatacard[3] do
        cbTempCardData[x] = GameCommon.listdatacard[3][x]
        print("自己3：",cbTempCardData[x],GameCommon.listdatacard[3][x])
    end  
    local cbTempCout = self.m_hardCardCout[4]
    self.m_hardCardNode[4]:removeAllChildren()
    if cbUserAction ~= 0 then
--        cbTempCardData = clone(cbCardData)
--        cbTempCout = Cout
--        self.m_hardCardCout[4] = cbTempCout
    print("玩家位置:",3, "手牌数量获取:",self.m_hardCardCout[4] )
    end
    --吃碰牌
    local WeaveCout = GameCommon.m_cbWeaveCount[4]
    for j = 1 , WeaveCout do
        local WeaveItemCard = {}
        for x = 1 , 4 do
            WeaveItemCard[x] = 0
        end
        
        WeaveItemCard = self:GetWeaveItemCard(GameCommon.m_WeaveItemArray[4][j])
        for i = 1 , 3 do
            local pt = cc.p(295-(j-1)*45,-(i-1.5)*120*0.4)
--            if j <= 2 then 
--                  pt = cc.p(280-(i-1)*95*0.4-(j-1)*130,-(2-2.4)*124*0.4)
--            elseif j <= 4  then  
--                  pt = cc.p(280-(i-1)*95*0.4-(j-3)*130,-(3-2.4)*124*0.4)
--            end 
            local _spt = GameCommon:GetPartCardHand(WeaveItemCard[i])
            if (GameCommon.m_WeaveItemArray[4][j].cbWeaveKind == GameCommon.WIK_LEFT or GameCommon.m_WeaveItemArray[4][j].cbWeaveKind == GameCommon.WIK_CENTER or GameCommon.m_WeaveItemArray[4][j].cbWeaveKind == GameCommon.WIK_RIGHT) and WeaveItemCard[i] == GameCommon.m_WeaveItemArray[4][j].cbCenterCard then
                _spt:setColor(cc.c3b(200,200,200))
            end
            _spt:setPosition(pt)
            _spt:setScale(0.4)
            _spt:setTouchEnabled(true)
            _spt:addTouchEventListener(function(sender,event)                                          
                if event == ccui.TouchEventType.began then     
                    print("游戏点击1")  
                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
                    self._sptCard:setPosition(640,360)
                    self:addChild(self._sptCard)
                    self._sptCard:setScale(0.0)   
                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                  
                elseif event == ccui.TouchEventType.moved then  
                    self._sptCard:setScale(0.6,0,4)   
--                    print("游戏点击1")  
--                    self._sptCard = GameCommon:GetPartCardHand(WeaveItemCard[i],4)                                         
--                    self._sptCard:setPosition(640,360)
--                    self:addChild(self._sptCard)
--                    self._sptCard:setScale(0.0)   
--                    self._sptCard:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,0.6,0.4)))                     
                else 
                    print("游戏点击22")  
                    self._sptCard:setVisible(false) 
                    self._sptCard:setScale(0.0)    
                    self:removeChild(self._sptCard)      
                end                    
            end)            
            self.m_hardCardNode[4]:addChild(_spt)
        end
    end
    if GameCommon.serverData.cbRoomFriend == -1 then
        --手牌
        if cbTempCout == 17 then
        cbTempCardData[17] = GameCommon.m_crad_17
        end  
        for j = 1 , cbTempCout do 
            print("手牌333",cbTempCardData[j],cbTempCout)
            local _spt = nil
            if cbTempCardData[j] == 0 then
                _spt = GameCommon:GetCardHand(cbTempCardData[j],3)
            else
                _spt = GameCommon:GetPartCardHand(cbTempCardData[j])                
            end
        local pt = cc.p((j-1)*95*0.3+310-456,-78)
          if j > 17 then
             pt = cc.p((j-1-17)*95*0.3+310-456,-116)
          end
            if cbTempCardData[j] == nil then 
                break 
            end
            _spt:setPosition(pt)
            _spt:setScale(0.3)
            self.m_hardCardNode[4]:addChild(_spt)
        end
    end
end

function ActionLayer:showMeTableCard(cbCardData,Cout,cbUserAction)    
    if cbCardData == nil then
        cbCardData = nil
    end

    if Cout == nil then
        Cout = 0
    end

    if cbUserAction == nil then
        cbUserAction = 0
    end

    if cbUserAction ~= 0 then
        local cbTempCout = Cout
        self.m_hardCardCout[2] = cbTempCout
    end

    if cbUserAction > 0 then
        GameCommon.m_SpecialCardCout = Cout
        GameCommon.m_SpecialTempCardData = clone(cbCardData)
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_SpecialStart)
    else
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_SpecialOver)
    end
end

function ActionLayer:GetWeaveItemCard(_WeaveItemArray)
    local WeaveItemCard = {}

    for x = 1 , 4 do
        WeaveItemCard[x] = 0
    end
    

    if _WeaveItemArray.cbWeaveKind == GameCommon.WIK_GANG or _WeaveItemArray.cbWeaveKind == GameCommon.WIK_FILL then
        WeaveItemCard[1] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[2] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[3] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[4] = _WeaveItemArray.cbCenterCard
    elseif _WeaveItemArray.cbWeaveKind == GameCommon.WIK_LEFT then
        WeaveItemCard[2] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[1] = _WeaveItemArray.cbCenterCard+1
        WeaveItemCard[3] = _WeaveItemArray.cbCenterCard+2
    elseif _WeaveItemArray.cbWeaveKind == GameCommon.WIK_CENTER then
        WeaveItemCard[2] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[1] = _WeaveItemArray.cbCenterCard-1
        WeaveItemCard[3] = _WeaveItemArray.cbCenterCard+1
    elseif _WeaveItemArray.cbWeaveKind == GameCommon.WIK_RIGHT then
        WeaveItemCard[2] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[1] = _WeaveItemArray.cbCenterCard-1
        WeaveItemCard[3] = _WeaveItemArray.cbCenterCard-2
    elseif _WeaveItemArray.cbWeaveKind == GameCommon.WIK_PENG then
        WeaveItemCard[2] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[1] = _WeaveItemArray.cbCenterCard
        WeaveItemCard[3] = _WeaveItemArray.cbCenterCard
    end

    return WeaveItemCard
end

function ActionLayer:showTableCardCallback(_obj)
    if _obj == 0 then
        self:showLeftTableCard()
    elseif _obj ==1 then
        
    elseif _obj ==2 then
        self:showRightTableCard()
    elseif _obj ==3 then
        self:showFaceTableCard()
    end
end


function ActionLayer:falseCard()
    for i = 1 , 4 do
        self.m_StoreCardNode[i]:removeAllChildren()
    end
end
function ActionLayer:initStoreCardByStoreCard(wDiceCount,StoreCardAll)
    self.m_StoreCardAll = clone(StoreCardAll)

    self.m_wFirstDice = wDiceCount[1]

    --self:showStoreCard()
end

function ActionLayer:removeStoreCard(wSiceCount,wOperateCode,MoveTo,viewID)
    if MoveTo == nil then
        MoveTo = false
    end

    if viewID == nil then
        viewID = 1
    end


    local cbSiceFirst = Bit:_and(Bit:_rshift(self.m_wFirstDice,8),0xff)
    local cbSiceSecond = Bit:_and(self.m_wFirstDice,0xff)
    local indexStart = (GameCommon.wBankerUser + cbSiceFirst + cbSiceSecond -1)%4
    local cbSiceCout = {}
    cbSiceCout[1] = Bit:_and(Bit:_rshift(wSiceCount,8),0xff) + Bit:_and(wSiceCount,0xff)
    if Bit:_and(wSiceCount,0xff) < Bit:_and(Bit:_rshift(wSiceCount,8),0xff) then
        cbSiceCout[2] = Bit:_and(wSiceCount,0xff)
    else
        cbSiceCout[2] = Bit:_and(Bit:_rshift(wSiceCount,8),0xff)
    end

    if wOperateCode == GameCommon.WIK_FILL then
        for x = 1 ,4 do
            local index = (indexStart + 4 + x -1)%4
            if self.m_StoreCardNode[index+1]:getChildrenCount() > 0 then
                local maxCout = 17
                for i = 1 , maxCout do
                   for cj = 2 , 1 , -1 do
                        local _node = self.m_StoreCardNode[index+1]:getChildByName(string.format("store%d%d",i-1,cj-1))
                        if _node ~= nil then
                            local pt = cc.p(0,0)
                            pt.x = _node:getPositionX()
                            pt.y = _node:getPositionY()
                            self.m_wSendStorePos = self.m_StoreCardNode[index+1]:convertToWorldSpace(pt)
                            self.m_wSendStoreIndex = index
                            _node:removeFromParent()
                            return
                        end
                   end
                end
            end
        end
    elseif wOperateCode == GameCommon.WIK_GANG then
        for cbSiceCoutIndex = 1 , 2 do
            local tempCout = 0
            for x = 1 ,4 do
                local index = (indexStart+4+(x-1))%4
                if self.m_StoreCardNode[index+1]:getChildrenCount() > 0 then
                    local maxCout = 17
                    for i = 1 , maxCout do
                        for cj = 2 , 1 , -1 do
                            local _node = self.m_StoreCardNode[index+1]:getChildByName(string.format("store%d%d",i-1,cj-1))
                            if _node ~= nil then
                                tempCout = tempCout+1
                                if tempCout == cbSiceCout[cbSiceCoutIndex] then
                                    _node = self.m_StoreCardNode[index+1]:getChildByName(string.format("store%d%d",i-1,1))
                                    if _node ~= nil then
                                        local pt = cc.p(0,0)
                                        pt.x = _node:getPositionX()
                                        pt.y = _node:getPositionY()
                                        self.m_wSendStorePos = self.m_StoreCardNode[index+1]:convertToWorldSpace(pt)
                                        self.m_wSendStoreIndex = index
                                        _node:removeFromParent()
                                    end
                                    _node = self.m_StoreCardNode[index+1]:getChildByName(string.format("store%d%d",i-1,0))
                                    if _node ~= nil then
                                        local pt = cc.p(0,0)
                                        pt.x = _node:getPositionX()
                                        pt.y = _node:getPositionY()
                                        self.m_wSendStorePos2 = self.m_StoreCardNode[index+1]:convertToWorldSpace(pt)
                                        _node:removeFromParent()
                                    end
                                    return
                                end
                                break
                            end
                        end
                    end
                end
            end 
        end
    else
        local tempCout = 0
        for x = 1 , 4 do
            local index = 0
            if MoveTo == true then
                index = (indexStart+4-(x-1))%4
            else
                index = (indexStart+4-(x-1)-1)%4
            end

            if self.m_StoreCardNode[index+1]:getChildrenCount()>0 then
                local maxCout = 17

                for i = maxCout , 1 , -1 do
                    
                    tempCout = tempCout + 1

                    for cj = 2 , 1 ,-1 do
                    
                        local stringName = string.format("store%d%d",i-1,cj-1)
                        local _node = self.m_StoreCardNode[index+1]:getChildByName(stringName)
                        if indexStart == index and MoveTo == true then
                            
                            if _node ~= nil then
                                if cbSiceFirst > cbSiceSecond then
                                    if tempCout > cbSiceSecond then
                                        local pt = cc.p(0,0)
                                        pt.x = _node:getPositionX()
                                        pt.y = _node:getPositionY()
                                        self.m_wSendStorePos = self.m_StoreCardNode[index + 1]:convertToWorldSpace(pt)
                                        self.m_wSendStoreIndex = index
                                        _node:removeFromParent()

                                        if MoveTo == true then
                                            local spt = GameCommon:GetPartCardHand(0,index)
                                            spt:setPosition(self.m_wSendStorePos)
                                            self:addChild(spt)
                                            spt:setVisible(false)
                                            if self.m_hardCardCout[viewID+1] == nil then
                                                self.m_hardCardCout[viewID+1] = 0
                                            end
                                            self.m_hardCardCout[viewID+1] = self.m_hardCardCout[viewID+1]+1

                                            spt:runAction(cc.Sequence:create(
                                                
                                                cc.DelayTime:create(0.4),
                                                --cc.EaseExponentialOut:create(cc.MoveTo:create(0.4,self:GetMoveHardViewPos(viewID,true))),
                                                cc.CallFunc:create(function(sender,event) self:showTableCardCallback(viewID) end),
                                                cc.RemoveSelf:create(),
                                                nil
                                                 ))
                                        end
                                        return
                                    end
                                else
                                    if tempCout > cbSiceFirst then
                                        local pt = cc.p(0,0)
                                        pt.x = _node:getPositionX()
                                        pt.y = _node:getPositionY()
                                        self.m_wSendStorePos = self.m_StoreCardNode[index + 1]:convertToWorldSpace(pt)
                                        self.m_wSendStoreIndex = index
                                        _node:removeFromParent()

                                        if MoveTo == true then
                                            local spt = GameCommon:GetPartCardHand(0,index)
                                            spt:setPosition(self.m_wSendStorePos)
                                            self:addChild(spt)
                                            spt:setVisible(false)
                                            if self.m_hardCardCout[viewID+1] == nil then
                                                self.m_hardCardCout[viewID+1] = 0
                                            end
                                            self.m_hardCardCout[viewID+1] = self.m_hardCardCout[viewID+1]+1

                                            spt:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(0.4),
                                                --cc.EaseExponentialOut:create(cc.MoveTo:create(0.4,self:GetMoveHardViewPos(viewID,true))),
                                                cc.CallFunc:create(function(sender,event) self:showTableCardCallback(viewID) end),
                                                cc.RemoveSelf:create(),
                                                nil
                                                 ))
                                        end
                                        return
                                    end
                                end
                            end
                        else
                            if _node ~= nil then
                                local pt = cc.p(0,0)
                                pt.x = _node:getPositionX()
                                pt.y = _node:getPositionY()
                                self.m_wSendStorePos = self.m_StoreCardNode[index+1]:convertToWorldSpace(pt)
                                self.m_wSendStoreIndex = index
                                _node:removeFromParent()

                                if MoveTo == true then
                                    local spt = GameCommon:GetPartCardHand(0,index)
                                    spt:setPosition(self.m_wSendStorePos)
                                    self:addChild(spt)
                                    spt:setVisible(false)
                                    self.m_hardCardCout[viewID+1] = self.m_hardCardCout[viewID+1]+1
                                    spt:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(0.4),
                                                --cc.EaseExponentialOut:create(cc.MoveTo:create(0.4,self:GetMoveHardViewPos(viewID,true))),
                                                cc.CallFunc:create(function(sender,event) self:showTableCardCallback(viewID) end),
                                                cc.RemoveSelf:create(),
                                                nil
                                                 ))
                                end
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end


function ActionLayer:showAction(wOperateUser,cbOperateCode)
    local outCardTips = nil
    if cbOperateCode == GameCommon.WIK_LEFT or cbOperateCode == GameCommon.WIK_CENTER or cbOperateCode == GameCommon.WIK_RIGHT then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/chi-donghua.ExportJson")
        outCardTips= ccs.Armature:create("chi-donghua")
        outCardTips:setScale(1.3)
        outCardTips:getAnimation():playWithIndex(0,-1,0)
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Chi)
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_chi)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Chi);
		--MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_chi);
    elseif cbOperateCode == GameCommon.WIK_PENG then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/peng-donghua.ExportJson")
        outCardTips= ccs.Armature:create("peng-donghua")
        outCardTips:setScale(1.3)
        outCardTips:getAnimation():playWithIndex(0,-1,0)
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Peng)
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_peng)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Chi);
		--MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_chi);
    elseif cbOperateCode == GameCommon.WIK_GANG then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/gang-donghua.ExportJson")
        outCardTips= ccs.Armature:create("gang-donghua")
        outCardTips:setScale(1.3)
        outCardTips:getAnimation():playWithIndex(0,-1,0)
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Gang)
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_gang)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Chi);
		--MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_chi);
    elseif cbOperateCode == GameCommon.WIK_FILL then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/bu-donghua.ExportJson")
        outCardTips= ccs.Armature:create("bu-donghua")
        outCardTips:setScale(1.3)
        outCardTips:getAnimation():playWithIndex(0,-1,0)
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Gang)
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_gang)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Chi);
	    --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_chi);

    else
    end
    outCardTips:setPosition(self:GetMoveCardViewPos(wOperateUser))
    self:addChild(outCardTips,1)
    outCardTips:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(1.0),
                                                cc.FadeOut:create(0.5),
                                                cc.RemoveSelf:create(),
                                                nil
                                                 ))
end

function ActionLayer:showXhAction(wOperateUser,cbOperateCode,Cout)
    local buff = ""
    if cbOperateCode == GameCommon.CHK_SIXI_HU then
        buff = "dasixi"
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_dsx)
        --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_dsx);
    elseif cbOperateCode == GameCommon.CHK_LIULIU_HU  then
        buff = "liuliushun"
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_lls)
        --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_dsx);
    elseif cbOperateCode == GameCommon.CHK_BANBAN_HU  then
        buff = "wujianghu"
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_lls)
        -- MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_dsx);
    elseif cbOperateCode == GameCommon.CHK_QUEYISE_HU  then
        buff = "queyise"
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wOperateUser).cbSex, GameCommon.Actor_qys)
        --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wOperateUser)->cbSex,Actor_dsx);
    end

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshupaixing.ExportJson")
    local armature = ccs.Armature:create("teshupaixing")
    armature:getAnimation():play(buff,-1,0)
    armature:setPosition(self:GetMoveCardViewPos(wOperateUser))
    self:addChild(armature,1)
    armature:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(2.0),
                                                cc.RemoveSelf:create(),
                                                nil
                                                 ))
end

function ActionLayer:showHuGame(pEndTips)
    self.m_pEndTips = clone(pEndTips)
    --self:onActionDelay()

    local size = cc.Director:getInstance():getWinSize()
    if pEndTips.wProvideUser == GameCommon.INVALID_CHAIR then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/huangzhuang-donghua.ExportJson")
        local armature = ccs.Armature:create("huangzhuang-donghua")
        armature:getAnimation():playWithIndex(0,-1,0)
        armature:setPosition(size.width*0.5,size.height*0.4)
        self:addChild(armature)
        armature:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(1.2),
                                                cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
                                                nil
                                                 ))
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Huang)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Huang);
    end

    if pEndTips.wWinner[pEndTips.wProvideUser+1] == true then
        --自摸
        
        for i=0,3 do       
            local wID = GameCommon:SwitchViewChairID(i)
--            print("手牌手牌",pEndTips.cbCardData[i+1])
            if wID == 0 then
                self:showLeftTableCard(pEndTips.cbCardData[i+1],pEndTips.cbCardCount[i+1],1)
            elseif wID == 1 then
                self:showMeTableCard(pEndTips.cbCardData[i+1],pEndTips.cbCardCount[i+1],1)
            elseif wID == 2 then
                self:showRightTableCard(pEndTips.cbCardData[i+1],pEndTips.cbCardCount[i+1],1)
            elseif wID == 3 then
                self:showFaceTableCard(pEndTips.cbCardData[i+1],pEndTips.cbCardCount[i+1],1)
            end
        end
        local i = pEndTips.wProvideUser
        local wID = GameCommon:SwitchViewChairID(i)
        GameCommon:paySoundeffect(GameCommon.Soundeffect_Hu)
        GameCommon:palyCDActionSound(GameCommon:getUserInfo(wID).cbSex,GameCommon.Actor_zimo)
        --MusicControl::getInstance()->paySoundeffect(Soundeffect_Hu);
	    --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wID)->cbSex,Actor_hu);

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/hupaitexiao-ty.ExportJson")
        local armature = ccs.Armature:create("hupaitexiao-ty")
        armature:setScale(0.9)
        armature:getAnimation():playWithIndex(0,-1,0)
        armature:setPosition(self:GetClockPos(wID))
        self:getParent():addChild(armature,3)
        armature:runAction(cc.Sequence:create(
                                                cc.DelayTime:create(1.0),
                                                cc.MoveTo:create(0.2,self:GetMoveCardViewPos(self:GetMoveCardViewPos(pEndTips.wProvideUser+1))),
                                                cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) armature:setVisible(false) end),
                                                nil
                                                 ))
    else
        for i = 1 , 4 do
            if pEndTips.wWinner[i] == false then
            else
                local wID = GameCommon:SwitchViewChairID(i-1)
--                if wID == 0 then
                    self:showLeftTableCard(pEndTips.cbCardData[i],pEndTips.cbCardCount[i],1)
--                elseif wID == 1 then
                    self:showMeTableCard(pEndTips.cbCardData[i],pEndTips.cbCardCount[i],1)
--                elseif wID == 2 then
                    self:showRightTableCard(pEndTips.cbCardData[i],pEndTips.cbCardCount[i],1)
--                elseif wID == 3 then
                    self:showFaceTableCard(pEndTips.cbCardData[i],pEndTips.cbCardCount[i],1)
--                end

                GameCommon:paySoundeffect(GameCommon.Soundeffect_Hu)
                GameCommon:palyCDActionSound(GameCommon:getUserInfo(wID).cbSex,GameCommon.Actor_fangpao)
                --MusicControl::getInstance()->paySoundeffect(Soundeffect_Hu);
			    --MusicControl::getInstance()->palyCDActionSound(getUserInfo(wID)->cbSex,Actor_hu);
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/fangpao.ExportJson")
                local armature = ccs.Armature:create("fangpao")
                armature:getAnimation():playWithIndex(0,-1,0)
                armature:setPosition(self:GetClockPos(GameCommon:SwitchViewChairID(pEndTips.wProvideUser)))
                self:getParent():addChild(armature,3)
                
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/hupaitexiao-ty.ExportJson")
                armature = ccs.Armature:create("hupaitexiao-ty")
                armature:setScale(0.9)
                armature:getAnimation():playWithIndex(0,-1,0)
                armature:setPosition(self:GetClockPos(wID))
                self:getParent():addChild(armature,3)
                armature:runAction(cc.Sequence:create(
                                   cc.DelayTime:create(1.5),
                                   cc.MoveTo:create(0.2,self:GetMoveCardViewPos(self:GetMoveCardViewPos(wID-1))),
                                   cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) armature:setVisible(false) end),
                                   nil
                       ))
            end
        end
        
    end
--    self:runAction(cc.Sequence:create(
--        cc.DelayTime:create(0.0),
--        cc.CallFunc:create(function(sender,event) self:showNiaoAnimation() end),
--        cc.DelayTime:create(1.0),
--        cc.CallFunc:create(function(sender,event) self:showNiaoGame() end),
--        nil
--    ))

    -- 临时运行  结束动画
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
        nil
    ))
end


function ActionLayer:showNiaoZhongCard(_obj)
    if  GameCommon.wKindID == 33 then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/maimadonghua.ExportJson")
        local armature = ccs.Armature:create("maimadonghua")
        armature:getAnimation():playWithIndex(0,-1,0)
        armature:setPosition(40,160)
        --armature:setScale(0.6)
        _obj:addChild(armature)
    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/niaodonghua.ExportJson")
        local armature = ccs.Armature:create("niaodonghua")
        armature:getAnimation():playWithIndex(0,-1,0)
        armature:setPosition(80,120)
        _obj:addChild(armature)
    end
end

function ActionLayer:showSpecialCastDice(wSiceCount)
    --self:onActionDelay()

    local size = cc.Director:getInstance():getWinSize()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/yaoshaizi.ExportJson")
    local armature = ccs.Armature:create("yaoshaizi")
    armature:getAnimation():playWithIndex(0,-1,0)
    armature:setPosition(size.width*0.5,size.height*0.5)
    self:addChild(armature,1)
    armature:setTag(wSiceCount)
    armature:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1.0),
                                   cc.CallFunc:create(function(sender,event) self:showSpecialCastDiceCallBack(armature) end),
                                   cc.RemoveSelf:create(),
                                   nil
                                   ))
    GameCommon:paySoundeffect(GameCommon.Soundeffect_YaoShuaiZi);
    --MusicControl::getInstance()->paySoundeffect(Soundeffect_YaoShuaiZi);
end

function ActionLayer:showSpecialCastDiceCallBack(obj)
    local wDiceCount = obj:getTag()
    local size = cc.Director:getInstance():getWinSize()

    local cbSiceFirst = Bit:_and(Bit:_rshift(wDiceCount,8),0xff)
    local cbSiceSecond = Bit:_and(wDiceCount,0xff)
    local _node = cc.Node:create()
    self:addChild(_node)

    local spt = GameCommon:GetShuaiZi(cbSiceFirst)
    spt:setPosition(size.width*0.45,size.height*0.52)
    spt:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1.0),
                                   cc.FadeOut:create(0.3),
                                   nil
                                   ))
    _node:addChild(spt)

    spt = GameCommon:GetShuaiZi(cbSiceSecond)
    spt:setPosition(size.width*0.55,size.height*0.52)
    spt:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1.0),
                                   cc.FadeOut:create(0.3),
                                   nil
                                   ))
    _node:addChild(spt)

    _node:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1.0),
                                    cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
                                    cc.DelayTime:create(0.5),
                                   cc.RemoveSelf:create(),
                                   nil
                                   ))

    for i = 1 , 4 do
        local ID = GameCommon:SwitchViewChairID(i-1)
        local diceCount = nil
        if GameCommon.m_SpeciallGameScore[i] > 0 then
            diceCount = ccui.TextAtlas:create(string.format(":%d",GameCommon.m_SpeciallGameScore[i]),"fonts/fonts_6.png",26,43,'0')
        else
            diceCount = ccui.TextAtlas:create(string.format(":%d",GameCommon.m_SpeciallGameScore[i]),"fonts/fonts_7.png",26,43,'0')
        end

        diceCount:setPosition(self:GetMoveCardViewPos(ID))
        self:addChild(diceCount)

        diceCount:runAction(cc.Sequence:create(
                                    cc.ScaleTo:create(0.1,1.0,0.8),
                                    cc.ScaleTo:create(0.2,1.0,1.2),
                                    cc.ScaleTo:create(0.1,1.0,1.0),
                                    cc.DelayTime:create(1.0),
                                    cc.FadeOut:create(1.5),
                                   cc.RemoveSelf:create(),
                                   nil
                                   ))
    end

    for i = 1 , 4 do
        if #GameCommon.tagUserInfoList ~= 4 then
            break
        end
        GameCommon.tagUserInfoList[i].lScore = GameCommon.tagUserInfoList[i].lScore + GameCommon.m_SpeciallGameScore[i]
    end
    
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpdataUserScore)
end

function ActionLayer:showGangScoreAction()
       for i = 1 , 4 do
        local ID = GameCommon:SwitchViewChairID(i-1)
        print("gang score ", GameCommon.m_GangAllGameScore[i])
        local diceCount = nil
        if GameCommon.m_GangAllGameScore[i] ~= 0 then
            if GameCommon.m_GangAllGameScore[i] > 0 then
                diceCount = ccui.TextAtlas:create(string.format(":%d",GameCommon.m_GangAllGameScore[i]),"fonts/fonts_6.png",26,43,'0')
            else
                diceCount = ccui.TextAtlas:create(string.format(":%d",GameCommon.m_GangAllGameScore[i]),"fonts/fonts_7.png",26,43,'0')
            end

            diceCount:setPosition(self:GetMoveCardViewPos(ID))
            self:addChild(diceCount)
            diceCount:runAction(cc.Sequence:create(
                                    cc.ScaleTo:create(0.1,1.0,0.8),
                                    cc.ScaleTo:create(0.2,1.0,1.2),
                                    cc.ScaleTo:create(0.1,1.0,1.0),
                                    cc.DelayTime:create(1.0),
                                    cc.FadeOut:create(1.5),
                                   cc.RemoveSelf:create(),
                                   nil
                                   ))
        end
    end
    for i = 1 , 4 do
        print("杠的钱",GameCommon.isFriendsGame,#GameCommon.tagUserInfoList,GameCommon.m_GangAllGameScore[i])
        if #GameCommon.tagUserInfoList ~= 4 then
            break
        end
        if GameCommon.isFriendsGame ~= true then
            GameCommon.tagUserInfoList[i].lScore = GameCommon.tagUserInfoList[i].lScore + GameCommon.m_GangAllGameScore[i]
        end
    end
    
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpdataUserScore)
end

function ActionLayer:addHuType(pGameStart)
    
    if GameCommon.wKindID == 27 then
    else    
        --        self:onActionDelayOver()
        return
    end

   for i = 1 ,4 do
        local HuKindData = pGameStart.wChiHuKind[i]
        local wWinUser = GameCommon:SwitchViewChairID(i-1)
        local Cout = 0
        local armature = nil
        --碰碰胡
        if Bit:_and(HuKindData,GameCommon.CHK_PENG_PENG) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("pengpenghu",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --将将胡
        if Bit:_and(HuKindData,GameCommon.CHK_JIANG_JIANG) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("jiangjianghu",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --清一色
        if Bit:_and(HuKindData,GameCommon.CHR_QING_YI_SE) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("qingyise",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --全球人
        if Bit:_and(HuKindData,GameCommon.CHR_QUAN_QIU_REN) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("quanqiuren",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --海底
        if Bit:_and(HuKindData,GameCommon.CHR_HAIDI) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("haidilaoyue",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --七小队
        if Bit:_and(HuKindData,GameCommon.CHK_QI_XIAO_DUI) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("qixiaodui",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --豪七
        if Bit:_and(HuKindData,GameCommon.CHK_QI_XIAO_DUI_HAO) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("haohuaqixiaodui",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --杠上花
        if Bit:_and(HuKindData,GameCommon.CHR_GANG) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("gangshanghua",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end
        --双杠上花
        if Bit:_and(HuKindData,GameCommon.CHR_GANG_SHUANG) ~= 0 then
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/teshuhupai.ExportJson")
            armature= ccs.Armature:create("teshuhupai")
            armature:getAnimation():play("gangshanghua",-1,0)
            local point = self:gethupaiTypePos(wWinUser)
            armature:setPosition(cc.p(point.x,point.y + Cout *40))
            Cout = Cout+1
            self:addChild(armature)
        end

        if armature ~= nil then
            if i == 2 then
                armature:runAction(cc.Sequence:create(
                 cc.MoveBy:create(0.5,cc.p(100,0)),
--                 cc.CallFunc:create(function(sender,event) self:onActionDelayOver() end),
                 cc.MoveBy:create(0.2,cc.p(0,0)),
                 cc.CallFunc:create(function(sender,event) armature:setVisible(false) end),
                 nil))
            else
                armature:runAction(cc.Sequence:create(
                cc.MoveBy:create(0.5,cc.p(-100,0)),
                 cc.MoveBy:create(0.2,cc.p(0,0)),
                 cc.CallFunc:create(function(sender,event) armature:setVisible(false) end),
                nil)) 
            end
        else
--            self:onActionDelayOver()
        end
    end
end

function ActionLayer:gethupaiTypePos(viewID)

    local size = cc.Director:getInstance():getWinSize()
    local pt = cc.p(0,0)
    if viewID == 0 then
        pt.x = size.width * 0.2 + 100
        pt.y = size.height * 0.55
    elseif viewID == 1 then
        pt.x = size.width * 0.5 + 100
        pt.y = size.height * 0.25
    elseif viewID == 2 then
        pt.x = size.width * 0.8 - 100
        pt.y = size.height * 0.55
    elseif viewID == 3 then
        pt.x = size.width * 0.5 + 100
        pt.y = size.height * 0.75
    end
    return pt
end

return ActionLayer