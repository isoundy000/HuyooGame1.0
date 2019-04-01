local GameCommon = require("game.laopai.GameCommon")
local GameLogic = require("game.laopai.GameLogic")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Bit = require("common.Bit")
local Common = require("common.Common")
--卡牌
local CardLayer = class("CardLayer",function()
    return ccui.Layout:create()
end)

function CardLayer:create(tipsXuXian)
    local view = CardLayer.new()
    view:onCreate(tipsXuXian)
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

function CardLayer:onEnter()

end

function CardLayer:onExit()

end

function CardLayer:onCreate(tipsXuXian)

    self.m_HardCard = {}
    self.m_hardCardNode = {}
    self.m_WeaveItemNode = nil

    self.m_fBaseStartPosx = 0
    self.m_fBaseEndPosx = 0

    self.m_pMoveSprite = nil
    self.m_pMoveIndex = 1

    self.m_timeClick = nil
    self.m_TouchEable = false
    self.m_timeClickTime = 0
    self.m_timeClickEnable = true
    self.tipsXuXian = nil
    self.BASEPOSITIONX = 120
    self.BASEPOSITIONY = 105
    local n_time2 =os.time()
    if self.m_timeClick2 == nil then
        self.m_timeClick2 = n_time2
    end
    GameCommon.m_MyHandCardPos = cc.p(self.BASEPOSITIONX,self.BASEPOSITIONY)
    self.tipsXuXian = tipsXuXian
    self.tipsXuXian:setVisible(false)
    self.tipsXuXian:setPosition(640,720* 0.31)
    for x = 1 , 4 do
        self.m_hardCardNode[x] = cc.Node:create()
        self:addChild(self.m_hardCardNode[x])
    end

    self.m_WeaveItemNode = cc.Node:create()
    self:addChild(self.m_WeaveItemNode)


    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(function(touch,unused_event) return self:onTouchBegan(touch,unused_event) end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch,unused_event) self:onTouchMoved(touch,unused_event) end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(function(touch,unused_event) self:onTouchEnded(touch,unused_event) end, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self)
    
    return true
end

function CardLayer:setTouchEable(eable)
    self.m_TouchEable = eable
end
function CardLayer : card_addpai ()
    local cbCardData = {}
    local cout = 16
    if 1 == GameCommon.wBankerUser then
        cout = 17
    end
    for x = 1 ,cout do
        cbCardData[x] = 50
    end  
    if cout > 0 then
        self:sortHandCard(cbCardData,cout)
        self:showHandCard(false)
        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_SortCardOver)
    end  
end
function CardLayer:card_addpai2 ()
    print("牌翻起来")
    self:updataHandCard()
    local cbCardData = {}
    local cout = 0
    cout,cbCardData = GameLogic:SwitchToCardDataTwo(GameCommon.m_cbCardIndex)
    if cout > 0 then
         self:sortHandCard(cbCardData,cout)
         self:showHandCard(false)
         EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_SortCardOver)
    end        
end
function CardLayer:onTouchBegan(touch, unused_event)
    print("touch")
    if GameCommon.bIsMyTurn == true then
        self.m_TouchEable = true
    end

    if self.m_TouchEable == false then
        return false
    end

    local winSize= cc.Director:getInstance():getWinSize()
    local touchPoint = touch:getLocation()
     if touchPoint.y < winSize.height*0.3 then
--         self.tipsXuXian:setVisible(GameCommon.bIsMyTurn)
         local CardSpriteVector=self.m_hardCardNode[2]:getChildren()
         for key, var in pairs(CardSpriteVector) do
            if cc.rectContainsPoint(var:getBoundingBox(),touchPoint) then
                local equalCount = 0
                local Stack_x = var:getTag()
                local _data = self.m_HardCard[Stack_x].data
                if self.m_pMoveSprite == nil then
                    local pt = cc.p(0,0)
                    pt.x = var:getPositionX()
                    pt.y = var:getPositionY()
                    var:setOpacity(100)
                    --手牌移动啊啊啊
                    self.m_pMoveSprite = GameCommon:GetPartCardHand(_data,4) 
                     self.m_pMoveSprite:setScale(0.6,0.4)  
                    self.m_pMoveSprite:setTag(var:getTag())
                    self.m_pMoveSprite:setPosition(var:getPosition())
                    self.m_pMoveSpriteUserData = pt
                    local _part = cc.ParticleSystemQuad:create("laopai/mjpartical/majiangshangguangxiao.plist")
                    _part:setPosition(cc.p(35,40))
                    self.m_pMoveSprite:addChild(_part)
                    self.m_pMoveSprite:runAction(cc.ScaleTo:create(0.3,0.6,0.4))
                    self:addChild(self.m_pMoveSprite)
                end
                return true
            end
         end
    end

    local delyTime = os.time()
    if self.m_timeClick ~= nil and delyTime - self.m_timeClick < 1 then
        if self.m_timeClickEnable == true then
                --双击位置大于0.2排序
            if  touchPoint.y > winSize.height * 0.21 then       
                self:updataHandCard()
                local cbCardData = {}
                local cout = 0
                cout,cbCardData = GameLogic:SwitchToCardDataTwo(GameCommon.m_cbCardIndex)
    
                if cout > 0 then
                    self:sortHandCard(cbCardData,cout)
                    self:showHandCard(false)
                    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_SortCardOver)
                    self.m_timeClickEnable = false
    
                    self:runAction(cc.Sequence:create(
                                        cc.DelayTime:create(3.0),
                                       cc.CallFunc:create(function(sender,event) self:onTimeClickEnable() end),
                                       nil
                                       ))
                end
             end
        end
    else
        self.m_timeClick = delyTime
    end
    return false
end

function CardLayer:onTimeClickEnable()
    self.m_timeClickEnable = true
end

function CardLayer:onTouchMoved(touch,unused_event)
    if self.m_TouchEable == false then
        return
    end
    local touchPoint = touch:getLocation()
    if self.m_pMoveSprite then
        self.m_pMoveSprite:setPosition(touchPoint)
    end
--    self.tipsXuXian:setVisible(GameCommon.bIsMyTurn) 
end

function CardLayer:onTouchEnded(touch, unused_event)
    if self.m_TouchEable == false then
        return
    end
--    self.tipsXuXian:setVisible(false) 
    if self.m_pMoveSprite==nil then
        return
    end

    local touchPoint = touch:getLocation()
    local winSize= cc.Director:getInstance():getWinSize()
    local bIsRplace =false
    local Stack_x = self.m_pMoveSprite:getTag()
    local _data=self.m_HardCard[Stack_x].data
    self.m_pMoveIndex = Stack_x
    local delyTimeEnded = os.time()
    
    if touchPoint.y > winSize.height * 0.3  or ( self.m_timeClick2~=nil and delyTimeEnded - self.m_timeClick2 < 1 ) then
        --判断是否是自己出牌 否则
        if GameCommon.bIsMyTurn then  
--            if self.m_HardCard[Stack_x].data~=49 or  GameCommon.wKindID == 33 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OUT_CARD,"b",self.m_HardCard[Stack_x].data)
                bIsRplace = true
                GameCommon.m_MyTurnPos.x = self.m_pMoveSprite:getPositionX()
                GameCommon.m_MyTurnPos.y = self.m_pMoveSprite:getPositionY()
                EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
                EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)  
                self:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.3),
                    cc.CallFunc:create(function(sender,event) self:card_addpai2() end),
                    nil
                ))           
--            end

        end                             
    else
        if (touchPoint.x > self.m_fBaseEndPosx  or  touchPoint.x < self.m_fBaseStartPosx) then
            bIsRplace = true
            --删掉原来的
            table.remove(self.m_HardCard,Stack_x)

            --增加新的
            local _cardData = {}
            _cardData.data=_data
            _cardData.pt = cc.p(self.m_pMoveSprite:getPosition())
            
            if touchPoint.x > self.m_fBaseEndPosx then
                table.insert(self.m_HardCard,#self.m_HardCard+1,_cardData)
            else
                table.insert(self.m_HardCard,1,_cardData)
            end
        elseif (touchPoint.x < self.m_fBaseEndPosx  and  touchPoint.x > self.m_fBaseStartPosx) then
            local CardSpriteVector = self.m_hardCardNode[2]:getChildren()
            local index = 0
            for key, var in pairs(CardSpriteVector) do
                index = index+1
                local rect = var:getBoundingBox()
                if (touchPoint.x >= cc.rectGetMinX(rect)  and  touchPoint.x <= cc.rectGetMaxX(rect)) then
                   
                    bIsRplace=true
                    --删掉原来的
                    table.remove(self.m_HardCard,Stack_x)

                    --增加新的
                    local _cardData = {}
                    _cardData.data=_data
                    _cardData.pt = cc.p(self.m_pMoveSprite:getPosition())
            
                    
                    table.insert(self.m_HardCard,index,_cardData)

                    break
                end   
            end
        end
        self.m_timeClick2 = delyTimeEnded
    end

    if bIsRplace==true then
        self.m_pMoveSprite:removeFromParent()
        self.m_pMoveSprite=nil
        self:showHandCard(true)
    else
        --隐藏掉原来的
        local CardSpriteVector=self.m_hardCardNode[2]:getChildren()
        for key, var in pairs(CardSpriteVector) do
        	if var:getOpacity() == 100 then
        		var:setVisible(false)
        		break
        	end
        end
        self.m_pMoveSprite:runAction(cc.Sequence:create(
            cc.MoveTo:create(0.3,self.m_pMoveSpriteUserData),
--            cc.ScaleTo:create(0.3,0.6,0.4),
            cc.CallFunc:create(function(sender,event)  self:moveSptCallBack() end),
            cc.RemoveSelf:create()
            ))
        self.m_pMoveSprite=nil
    end
end

function CardLayer:moveSptCallBack()
    self:showHandCard()
end

function CardLayer:updataHandCard()
    local _TempCbCardIndex = {}
    for x = 1 , 34 do
        _TempCbCardIndex[x] = 0
    end
    
    for key, var in pairs(self.m_HardCard) do
    	
        if GameLogic:IsValidCard(var.data) == false then
        else
            _TempCbCardIndex[GameLogic:SwitchToCardIndex(var.data)] = _TempCbCardIndex[GameLogic:SwitchToCardIndex(var.data)]+1
        end
    end
    GameCommon.m_cbCardIndex = clone(_TempCbCardIndex)
end


function CardLayer:setHandCard(_data, count,isSort)

    if isSort == nil then
        isSort = false
    end
    
    for x = 1 ,#self.m_HardCard do
        table.remove(self.m_HardCard,x)
    end
    
     
    if isSort == true then
        self:sortHandCard(_data,count)
    else
        local _card = nil
        for i = 0,count do
            _card = _data[i]
            table.insert(self.m_HardCard,_card)
        end
        
    end
    
    
    self:showHandCard()
end

function CardLayer:sortHandCard(_data, count)
    local tempData = {}
    for i = 1 , 17 do
        tempData[i] = 0
    end

    local CardIndex = {}
    for i = 1 , 34 do
        CardIndex[i] = 0
    end    
    CardIndex = GameLogic:SwitchToCardIndexTwo(_data,count)

    count,tempData = GameLogic:SwitchToCardDataTwo(CardIndex)

    for x = 1 ,#self.m_HardCard do
        table.remove(self.m_HardCard,1)
    end

    for i = 1 , count do
        local _card = {}
        _card.data = tempData[i]
        self.m_HardCard[i] = _card
    end
end

function CardLayer:showWeaveItemCard()
    local size= cc.Director:getInstance():getWinSize()

    --显示吃牌
    for  i = 1 , GameCommon.m_cbWeaveCount[2] do
        local cout = 0
        local WeaveItemCard = {}
        if GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_LEFT then
            WeaveItemCard[2] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            WeaveItemCard[1] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard + 1
            WeaveItemCard[3] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard + 2
            cout = 3
        elseif GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_CENTER then
            WeaveItemCard[2] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            WeaveItemCard[1] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard - 1
            WeaveItemCard[3] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard + 1
            cout = 3
        elseif GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_RIGHT then
            WeaveItemCard[2] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            WeaveItemCard[1] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard - 1
            WeaveItemCard[3] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard - 2
            cout = 3
        elseif GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_PENG then
            WeaveItemCard[1] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            WeaveItemCard[2] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            WeaveItemCard[3] = GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            cout = 3
        end

        for j = 1 , 3 do
            local spt = GameCommon:GetCardHand(WeaveItemCard[j])
            if (GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_LEFT or  
                GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_CENTER or
                GameCommon.m_WeaveItemArray[2][i].cbWeaveKind == GameCommon.WIK_RIGHT) and
                WeaveItemCard[j] == GameCommon.m_WeaveItemArray[2][i].cbCenterCard
            then
                spt:setColor(cc.c3b(200,200,200))
            end
            spt:setScale(0.45,0.35)    
            spt:setPosition(self.BASEPOSITIONX - 32 + (i-1)*140 + (j-1)*45 + 85,self.BASEPOSITIONY)
            self.m_WeaveItemNode:addChild(spt)
        end
    end
end

function CardLayer:showHandCard(isMove,Special)

    if isMove == nil then
    	isMove = false
    end

    if Special == nil then
        Special = false
    end

    self.m_hardCardNode[2]:removeAllChildren()
    local m_nCardStackCount = #self.m_HardCard
    if #self.m_HardCard >=17 then 
    m_nCardStackCount = 17
    end
    local winSize=cc.Director:getInstance():getWinSize()

    self:showWeaveItemCard()
    local moveX = GameCommon.m_cbWeaveCount[2]*140 + self.BASEPOSITIONX + 85
    local basePointX = moveX
    local endPointX = m_nCardStackCount*GameCommon.CARDWIDTH + moveX

    self.m_fBaseStartPosx = basePointX- GameCommon.CARDWIDTH*0.5                                          --基准起点
    self.m_fBaseEndPosx   = endPointX - GameCommon.CARDWIDTH*0.5                                          --基准终点 
--    local num = 0 
--    local site = 0 
    --显示手牌
    for j = 1 , #self.m_HardCard do
        local _spt = nil
        if Special == true then
            for  i = 1,17 do
                if self.m_HardCard[j].data == GameCommon.m_SpecialTempCardData[i] then
                    GameCommon.m_SpecialTempCardData[i] = 0
                    _spt = GameCommon:GetPartCardHand(self.m_HardCard[j].data)
                    _spt:setScale(0.6)
                    break
                end
            end
        end
        if _spt == nil then
            _spt = GameCommon:GetCardHand(self.m_HardCard[j].data)
            _spt:setScale(0.65,0.36)
        end
        local allCount = GameCommon.m_cbWeaveCount[2]*3+#self.m_HardCard
	    local pt = cc.p(basePointX+(j-1)*GameCommon.CARDWIDTH-22,self.BASEPOSITIONY) 
        if isMove == false then
            if self.upCard == j then
                if j == #self.m_HardCard and allCount == 17 then
                    print("self.upcard already up isMove = false")
                    _spt:setPosition(cc.p(pt.x+20,pt.y+20))
                else
                    print("self.upcard already up isMove = false")
                    _spt:setPosition(cc.p(pt.x,pt.y+20))
                end
            else
                if j == #self.m_HardCard and allCount == 17 then
                    _spt:setPosition(pt.x + 20,pt.y)
                else
                    _spt:setPosition(pt.x,pt.y)
                end

            end

        else
            if self.upCard == j then
                if j == #self.m_HardCard and allCount == 17 then
                    _spt:setPosition(cc.p(pt.x + 20,pt.y+20))
                else
                    _spt:setPosition(cc.p(pt.x,pt.y+20))
                end
            else
                if j == #self.m_HardCard and allCount == 17 then
                    _spt:setPosition(pt.x + 20,pt.y)
                else
                    _spt:setPosition(pt.x,pt.y)
                end
            end
        end

        if self.upCard == j then
            print("self.upcard already up")
            if j == #self.m_HardCard and allCount == 17 then
                _spt:runAction(cc.MoveTo:create(0.3,cc.p(pt.x+20,pt.y+20)))
            else
                _spt:runAction(cc.MoveTo:create(0.3,cc.p(pt.x,pt.y+20)))
            end

        else
            if j == #self.m_HardCard and allCount == 17 then
                _spt:runAction(cc.MoveTo:create(0.3,cc.p(pt.x + 20,pt.y)))
            else
                _spt:runAction(cc.MoveTo:create(0.3,cc.p(pt.x,pt.y)))
            end

        end

        _spt:setTag(j)
        self.m_HardCard[j].pt = pt
        GameCommon.m_MyHandCardPos = pt
        self.m_hardCardNode[2]:addChild(_spt)
    end
end

function CardLayer:addHandCard(_data)
    local cardData = {}
    cardData.data = _data

    if #self.m_HardCard > 0 then
        if cardData.pt == nil then
            cardData.pt = {}
        end
        cardData.pt = GameCommon.m_MyHandCardPos
        cardData.pt.x = GameCommon.m_MyHandCardPos.x + GameCommon.CARDWIDTH
    else
        cardData.pt = cc.p(self.BASEPOSITIONX,self.BASEPOSITIONY)
    end
    table.insert(self.m_HardCard,cardData)

    if self.m_pMoveSprite ~= nil then
        self.m_pMoveSprite:removeFromParent()
        self.m_pMoveSprite = nil
    end
    self:showHandCard(true)
end

function CardLayer:removeHandCard(_data)
    if self.m_pMoveIndex < #self.m_HardCard and self.m_HardCard[self.m_pMoveIndex].data == _data then
        if self.m_pMoveSprite ~= nil then
            GameCommon.m_MyTurnPos.x = self.m_pMoveSprite:getPositionX()
            GameCommon.m_MyTurnPos.y = self.m_pMoveSprite:getPositionY()
        end
        table.remove(self.m_HardCard,self.m_pMoveIndex)
        self:showHandCard(true)
        self.m_pMoveIndex = 1000
        return
    end

    for j = #self.m_HardCard , 1 ,-1 do
        if self.m_HardCard[j].data == _data then
            GameCommon.m_MyTurnPos.x = self.m_HardCard[j].pt.x
            GameCommon.m_MyTurnPos.y = self.m_HardCard[j].pt.y
            table.remove(self.m_HardCard,j)
            break
        end
    end

    if self.m_pMoveSprite ~= nil then
        GameCommon.m_MyTurnPos.x = self.m_pMoveSprite:getPositionX()
        GameCommon.m_MyTurnPos.y = self.m_pMoveSprite:getPositionY()
        self.m_pMoveSprite:removeFromParent()
        self.m_pMoveSprite = nil
    end
    self:showHandCard(true)
end
function CardLayer:guoZhangGang(_data)
    for j = #self.m_HardCard , 1 ,-1 do
        if self.m_HardCard[j].data == _data then
            if GameCommon.m_GuoZhangGang[1] == 0 then
                GameCommon.m_GuoZhangGang[1] = _data
            else
                GameCommon.m_GuoZhangGang[2] = _data
            end
            break
        end
    end
end
return CardLayer