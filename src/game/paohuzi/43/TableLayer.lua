local StaticData = require("app.static.StaticData")
local GameCommon = require("game.paohuzi.43.GameCommon") 
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMsgId = require("common.NetMsgId")
local Bit = require("common.Bit")
local Common = require("common.Common")
local Base64 = require("common.Base64")
local LocationSystem = require("common.LocationSystem")
local Default = require("common.Default")
local GameOperation = require("game.paohuzi.43.GameOperation")
local GameLogic = require("game.paohuzi.43.GameLogic")
local UserData = require("app.user.UserData")

local TableLayer = class("TableLayer",function()
    return ccui.Layout:create()
end)

function TableLayer:create(root)
    local view = TableLayer.new()
    view:onCreate(root)
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

function TableLayer:onEnter()
    
end

function TableLayer:onExit()

end

function TableLayer:onCreate(root)
    self.root = root
    self.locationPos = cc.p(0,0)
    local touchLayer = ccui.Layout:create()
    self.root:addChild(touchLayer)
    local function onTouchBegan(touch , event)
        GameCommon.hostedTime = os.time()
        self.locationPos = touch:getLocation()
        return true
    end
    local function onTouchMoved(touch , event)
        self.locationPos = touch:getLocation()
    end
    local function onTouchEnded(touch , event)
        self.locationPos = touch:getLocation()
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,touchLayer) 
    return true
end

function TableLayer:doAction(action,pBuffer)
    GameCommon.waitOutCardUser = nil
	if action == GameCommon.ACTION_OUT_CARD_NOTIFY then
        local wChairID = pBuffer.wCurrentUser   
        GameCommon.waitOutCardUser = wChairID
--        local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
--        uiPanel_outCardTips:setVisible(false)
--        if wChairID == GameCommon:getRoleChairID() then
--            uiPanel_outCardTips:setVisible(true)
--        end
        if wChairID == GameCommon:getRoleChairID() then
            local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
            uiPanel_outCardTips:removeAllChildren()
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/finger/finger.ExportJson")
            local armature = ccs.Armature:create("finger")
            uiPanel_outCardTips:addChild(armature)
            armature:getAnimation():playWithIndex(0)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == GameCommon.ACTION_TI_CARD then
        local wChairID = pBuffer.wActionUser
        local cbCardData = pBuffer.cbActionCard
        local cbCardIndex = GameLogic:SwitchToCardIndex(cbCardData)
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        --判断是不是存在吃牌组合中
        local isExist = false
        local location = GameCommon.player[wChairID].bWeaveItemCount + 1
        local value = Bit:_and(cbCardData,0x0F)
        local color = Bit:_rshift(Bit:_and(cbCardData,0xF0),4)
        for i = 1, GameCommon.player[wChairID].bWeaveItemCount do
            local key = i
            local var = GameCommon.player[wChairID].WeaveItemArray[i]
            local value1 = Bit:_and(var.cbCenterCard,0x0F)
            local color1 = Bit:_rshift(Bit:_and(var.cbCenterCard,0xF0),4)
            if value == value1 and ((color <= 1 and color1 <= 1) or (color > 1 and color1 > 1)) then
                isExist = true
                location = key
                GameCommon.player[wChairID].bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount - 1
                table.remove(GameCommon.player[wChairID].WeaveItemArray,key) 
                break
            end
        end
        local index = (cbCardIndex-1)%10+1
        local tableDel = {GameLogic:SwitchToCardData(index),GameLogic:SwitchToCardData(index),GameLogic:SwitchToCardData(index+10),GameLogic:SwitchToCardData(index+10)}
        if cbCardIndex > 40/2 then
            tableDel = {GameLogic:SwitchToCardData(index+20),GameLogic:SwitchToCardData(index+20),GameLogic:SwitchToCardData(index+30),GameLogic:SwitchToCardData(index+30)}
        end
        if isExist == false then
            for key, var in pairs(tableDel) do
                if GameLogic:IsValidCard(var) then
                    self:removeHandCard(wChairID, var)
                end
            end
            GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - pBuffer.cbRemoveCount
            self:showHandCard(wChairID,2)
        end
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_userTips = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_userTips%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        --添加吃牌组合
        local WeaveItemArray = {}
        WeaveItemArray.cbWeaveKind = GameCommon.ACK_TI
        WeaveItemArray.cbCardCount = 4
        WeaveItemArray.cbCenterCard = cbCardData
        WeaveItemArray.cbCardList = tableDel

        if uiSendOrOutCardNode ~= nil then
            self:addWeaveItemArray(wChairID, WeaveItemArray, location,cc.p(uiSendOrOutCardNode:getPosition()))
            for key, var in pairs(tableDel) do
                if uiSendOrOutCardNode.cbCardData == var then
                    uiSendOrOutCardNode:removeFromParent()
                    break
                end 
            end
        else
            self:addWeaveItemArray(wChairID, WeaveItemArray, location,cc.p(uiPanel_tipsCardPos:getPosition()))
        end
        self:showCountDown(wChairID)
        self:playAnimation("提",wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == GameCommon.ACTION_PAO_CARD then
        local wChairID = pBuffer.wActionUser
        local cbCardData = pBuffer.cbActionCard
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local cbCardIndex = GameLogic:SwitchToCardIndex(cbCardData)
        --判断是不是存在吃牌组合中
        local isExist = false
        local value = Bit:_and(cbCardData,0x0F)
        local color = Bit:_rshift(Bit:_and(cbCardData,0xF0),4)
        local location = GameCommon.player[wChairID].bWeaveItemCount + 1
        for i = 1, GameCommon.player[wChairID].bWeaveItemCount do
            local key = i
            local var = GameCommon.player[wChairID].WeaveItemArray[i]
            if var.cbWeaveKind == GameCommon.ACK_WEI or var.cbWeaveKind == GameCommon.ACK_PENG then
                local value1 = Bit:_and(var.cbCenterCard,0x0F)
                local color1 = Bit:_rshift(Bit:_and(var.cbCenterCard,0xF0),4)
                if value == value1 and ((color <= 1 and color1 <= 1) or (color > 1 and color1 > 1)) then
                    isExist = true
                    location = key
                    GameCommon.player[wChairID].bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount - 1
                    table.remove(GameCommon.player[wChairID].WeaveItemArray,key) 
                    break
                end
            end
        end
        local index = (cbCardIndex-1)%10+1
        local tableDel = {GameLogic:SwitchToCardData(index),GameLogic:SwitchToCardData(index),GameLogic:SwitchToCardData(index+10),GameLogic:SwitchToCardData(index+10)}
        if cbCardIndex > 40/2 then
            tableDel = {GameLogic:SwitchToCardData(index+20),GameLogic:SwitchToCardData(index+20),GameLogic:SwitchToCardData(index+30),GameLogic:SwitchToCardData(index+30)}
        end
        if isExist == false then
            for key, var in pairs(tableDel) do
                self:removeHandCard(wChairID, var)
            end
            GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - pBuffer.cbRemoveCount
            self:showHandCard(wChairID,2)
        end
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        --添加吃牌组合
        local WeaveItemArray = {}
        WeaveItemArray.cbWeaveKind = GameCommon.ACK_PAO
        WeaveItemArray.cbCardCount = 4
        WeaveItemArray.cbCenterCard = cbCardData
        WeaveItemArray.cbCardList = tableDel
        if uiSendOrOutCardNode ~= nil then
            self:addWeaveItemArray(wChairID, WeaveItemArray, location,cc.p(uiSendOrOutCardNode:getPosition()))
            uiSendOrOutCardNode:removeFromParent()
        else
            self:addWeaveItemArray(wChairID, WeaveItemArray, location,cc.p(uiPanel_tipsCardPos:getPosition()))
        end
        self:showCountDown(wChairID)
        self:playAnimation("跑",wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))

    elseif action == GameCommon.ACTION_WEI_CARD then
        local wChairID = pBuffer.wActionUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local WeaveItemArray = {}
        WeaveItemArray.cbWeaveKind = GameCommon.ACK_WEI
        WeaveItemArray.cbCardCount = 3
        WeaveItemArray.cbCenterCard = pBuffer.cbActionCard[3]
        WeaveItemArray.cbCardList = pBuffer.cbActionCard
        for key, var in pairs(WeaveItemArray.cbCardList) do
            self:removeHandCard(wChairID, var)
        end
        GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - 2
        self:showHandCard(wChairID,2)
        if uiSendOrOutCardNode ~= nil then
            self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiSendOrOutCardNode:getPosition()))
            uiSendOrOutCardNode:removeFromParent()
        else
            self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiPanel_tipsCardPos:getPosition()))
        end
        self:showCountDown(wChairID)
        if WeaveItemArray.cbWeaveKind == GameCommon.ACK_CHOUWEI then
            self:playAnimation("臭偎",wChairID)
        else
            self:playAnimation("偎",wChairID)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == GameCommon.ACTION_PENG_CARD then
        local wChairID = pBuffer.wActionUser
        local cbCardData = pBuffer.cbActionCard
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        --添加吃牌组合
        local WeaveItemArray = {}
        WeaveItemArray.cbWeaveKind = GameCommon.ACK_PENG
        WeaveItemArray.cbCardCount = 3
        WeaveItemArray.cbCenterCard = pBuffer.cbActionCard[3]
        WeaveItemArray.cbCardList = pBuffer.cbActionCard
        for key, var in pairs(WeaveItemArray.cbCardList) do
            self:removeHandCard(wChairID, var)
        end
        GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - 2
        self:showHandCard(wChairID,2)
        if uiSendOrOutCardNode ~= nil then
            self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiSendOrOutCardNode:getPosition()))
            uiSendOrOutCardNode:removeFromParent()
        else
            self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiPanel_tipsCardPos:getPosition()))
        end
        self:showCountDown(wChairID)
        self:playAnimation("碰",wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))

    elseif action == GameCommon.ACTION_CHI_CARD then
        local wChairID = pBuffer.wActionUser
        local cbActionCard = pBuffer.cbActionCard      
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local cbDebarCard = cbActionCard
        for i = 1, pBuffer.cbResultCount do
            --添加吃牌组合
            local cbCardData = pBuffer.cbCardData[i] 
            local count = 0 
            while 1 do
                local isFound = false
                for key, var in pairs(cbCardData) do
                    if var == cbActionCard then
                        table.remove(cbCardData,key)
                        isFound = true
                        break
                    end
                end
                if isFound == false then
                    break
                else
                    count = count + 1
                end
            end
            for num = 1, count do
                table.insert(cbCardData,3-count+num,cbActionCard)
            end
            local WeaveItemArray = {}
            WeaveItemArray.cbWeaveKind = GameCommon.ACK_CHI
            WeaveItemArray.cbCardCount = 3
            WeaveItemArray.cbCenterCard = cbActionCard
            WeaveItemArray.cbCardList = cbCardData
            for key, var in pairs(WeaveItemArray.cbCardList) do
                if cbDebarCard ~= var then
                    if GameLogic:IsValidCard(var) then
                        self:removeHandCard(wChairID, var)
                    end
                else
                    cbDebarCard = 0
                end
            end
            if uiSendOrOutCardNode ~= nil then
                self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiSendOrOutCardNode:getPosition()))
            else
                self:addWeaveItemArray(wChairID, WeaveItemArray, GameCommon.player[wChairID].bWeaveItemCount + 1,cc.p(uiPanel_tipsCardPos:getPosition()))
            end
            
        end
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:removeFromParent()
        end
        GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - (pBuffer.cbResultCount*3-1)
        self:showHandCard(wChairID,2)           
        self:showCountDown(wChairID)
        if pBuffer.cbResultCount > 1 then
            self:playAnimation("比",wChairID)
        else
            self:playAnimation("吃",wChairID)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == GameCommon.ACTION_SEND_CARD then
        local wChairID = pBuffer.wAttachUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local cbCardData = pBuffer.cbCardData
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("ShowCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,42/uiSendOrOutCardNode:getContentSize().width,42/uiSendOrOutCardNode:getContentSize().height),
                cc.RemoveSelf:create()))
        end
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,42/uiSendOrOutCardNode:getContentSize().width,42/uiSendOrOutCardNode:getContentSize().height),
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    local isOutCard = sender.isOutCard
                    if not isOutCard then
                        isOutCard = false
                    end
                   self:addDiscardCard(sender.wChairID, sender.cbCardData,isOutCard) 
                end)))
        end
        if pBuffer.cbShow ~= 0 then
            uiSendOrOutCardNode = self:getSendOrOutCard(cbCardData,true)
            self:playAnimation(GameLogic:SwitchToCardIndex(cbCardData),wChairID)
        else
            uiSendOrOutCardNode = self:getSendOrOutCard(0,true)
        end
        uiSendOrOutCardNode:setName("SendOrOutCardNode")
        uiSendOrOutCardNode.cbCardData = cbCardData
        uiSendOrOutCardNode.wChairID = wChairID
        uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
        uiSendOrOutCardNode:setPosition(uiImage_stack:getPosition())
        local time = 0.8
        self:updateLeftCardCount(GameCommon.bLeftCardCount-1, false, true)
        uiSendOrOutCardNode:setScale(0)
        uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.1,cc.p(uiPanel_tipsCardPos:getPosition())),cc.ScaleTo:create(0.2,1))))
        self:showCountDown(wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))

    elseif action == GameCommon.ACTION_OUT_CARD then
        local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
        uiPanel_outCardTips:removeAllChildren()
        local wChairID = pBuffer.wOutCardUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local cbCardData = pBuffer.cbOutCardData
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("ShowCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,42/uiSendOrOutCardNode:getContentSize().width,42/uiSendOrOutCardNode:getContentSize().height),
                cc.RemoveSelf:create()))
        end
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,42/uiSendOrOutCardNode:getContentSize().width,42/uiSendOrOutCardNode:getContentSize().height),
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData,true) 
                end)))
        end
        uiSendOrOutCardNode = self:getSendOrOutCard(cbCardData)
        uiSendOrOutCardNode:setName("SendOrOutCardNode")
        uiSendOrOutCardNode.cbCardData = cbCardData
        uiSendOrOutCardNode.wChairID = wChairID
        uiSendOrOutCardNode.isOutCard = true;
        uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
        uiSendOrOutCardNode:setPosition(uiPanel_tipsCardPos:getPosition())
        uiSendOrOutCardNode:setScale(0)
        uiSendOrOutCardNode:runAction(cc.ScaleTo:create(0.2,1))
        if self.outData ~= nil and wChairID == GameCommon:getRoleChairID() and 
            self.outData.cbCardData == cbCardData and
            GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x] ~= nil and 
            GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].cbCardData[self.outData.y] ~= nil and 
            GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].cbCardData[self.outData.y].node ~= nil and 
            GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].cbCardData[self.outData.y].data == cbCardData then
            local cbCardIndex = GameLogic:SwitchToCardIndex(self.outData.cbCardData)
            local node = GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].cbCardData[self.outData.y].node
            if node ~= nil then
                if node.copyNode ~= nil then
                    node.copyNode:removeFromParent()
                    node.copyNode = nil
                end
                node:removeFromParent()
                node = nil
            end
            GameCommon.player[self.outData.wChairID].bUserCardCount = GameCommon.player[self.outData.wChairID].bUserCardCount - 1
            GameCommon.player[self.outData.wChairID].cbCardIndex[cbCardIndex] = GameCommon.player[self.outData.wChairID].cbCardIndex[cbCardIndex] - 1
            GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].nCardCount = GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].nCardCount -1
            if GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].nCardCount <= 0 then
                table.remove(GameCommon.player[self.outData.wChairID].cardStackInfo,self.outData.x) --删除整列
            else
                table.remove(GameCommon.player[self.outData.wChairID].cardStackInfo[self.outData.x].cbCardData,self.outData.y)
            end
            self:showHandCard(self.outData.wChairID,2)
            self.outData = nil
        else
            self.outData = nil
            if GameLogic:IsValidCard(cbCardData) then
                self:removeHandCard(wChairID, cbCardData)
            end
            GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount - 1
            self:showHandCard(wChairID,2)
        end
        self:showCountDown(wChairID)
        self:playAnimation(GameLogic:SwitchToCardIndex(cbCardData),wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.8),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))

    elseif action == GameCommon.ACTION_OPERATE_NOTIFY then
        if pBuffer.cbOperateCode ~= GameCommon.ACK_NULL then
            local wChairID = GameCommon:getRoleChairID()
            local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
            uiPanel_operation:removeAllChildren()
            local oprationLayer = GameOperation:create(pBuffer.cbOperateCode,pBuffer.cbActionCard,GameCommon.player[wChairID].cbCardIndex,pBuffer.cbSubOperateCode)
            uiPanel_operation:addChild(oprationLayer)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
    
    elseif action == GameCommon.ACTION_FANG_CARD then
        local wChairID = pBuffer.wWinUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local card = self:getSendOrOutCard(pBuffer.cbShengCard, true)
        card.cbCardData = pBuffer.cbShengCard
        card.wChairID = wChairID
        uiPanel_tipsCard:addChild(card)
        card:setPosition(visibleSize.width/2,visibleSize.height*0.8)
        card:setScale(0)
        card:runAction(cc.ScaleTo:create(0.2,0.5))
        if GameCommon.gameConfig.stuFanXing.bType == 1 or GameCommon.gameConfig.stuFanXing.bType == 2 then
            self:playAnimation("翻省")
        else
            self:playAnimation("跟省")
        end 
    
    elseif action == GameCommon.ACTION_SISHOU then
        local wChairID = pBuffer.wCurrentUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        self:playAnimation("死守",wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
 
    elseif action == GameCommon.ACTION_HU_CARD then 
        local wChairID = pBuffer.wWinUser
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local uiImage_countdown = ccui.Helper:seekWidgetByName(self.root,"Image_countdown")
        uiImage_countdown:setVisible(false)
        local uiAtlasLabel_countdownTime = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_countdownTime")
        uiAtlasLabel_countdownTime:stopAllActions()
        if wChairID ~= GameCommon.INVALID_CHAIR then
            local viewID = GameCommon:getViewIDByChairID(wChairID)
            if pBuffer.wProvideUser < GameCommon.gameConfig.bPlayerCount then   
                self:playAnimation("放炮",wChairID)
            elseif pBuffer.wType == 1 then
                self:playAnimation("自摸",wChairID)
            else   
                self:playAnimation("胡",wChairID)
            end
        else
            self:playAnimation("黄庄")             
        end
        
    elseif action == GameCommon.ACTION_SHOW_CARD then
        local wChairID = pBuffer.wAttachUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local cbCardData = pBuffer.cbCardData
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,42/uiSendOrOutCardNode:getContentSize().width,42/uiSendOrOutCardNode:getContentSize().height),
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData,true) 
                end)))
        end
        if pBuffer.cbShow ~= 0 then
            uiSendOrOutCardNode = self:getSendOrOutCard(cbCardData,true)
            self:playAnimation(GameLogic:SwitchToCardIndex(cbCardData),wChairID)
        else
            uiSendOrOutCardNode = self:getSendOrOutCard(0,true)
        end
        uiSendOrOutCardNode:setName("ShowCardNode")
        uiSendOrOutCardNode.cbCardData = cbCardData
        uiSendOrOutCardNode.wChairID = wChairID
        uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
        uiSendOrOutCardNode:setPosition(uiImage_stack:getPosition())
        uiSendOrOutCardNode:setScale(0)
        uiSendOrOutCardNode:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveTo:create(0.1,cc.p(uiPanel_tipsCardPos:getPosition())),cc.ScaleTo:create(0.2,1))))
	end
	
end

function TableLayer:showCountDown(wChairID)
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiImage_countdown = ccui.Helper:seekWidgetByName(self.root,"Image_countdown")
    uiImage_countdown:setVisible(true)
    local uiPanel_userTips = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_userTips%d",viewID))
    uiImage_countdown:setPosition(uiPanel_userTips:getPosition())
    local uiAtlasLabel_countdownTime = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_countdownTime")
    uiAtlasLabel_countdownTime:setPosition(uiAtlasLabel_countdownTime:getParent():getContentSize().width/2,uiAtlasLabel_countdownTime:getParent():getContentSize().height/2)
    uiAtlasLabel_countdownTime:stopAllActions()
    uiAtlasLabel_countdownTime:setString(15)
    local function onEventTime(sender,event)
        local currentTime = tonumber(uiAtlasLabel_countdownTime:getString())
        currentTime = currentTime - 1
        if currentTime < 0 then
            currentTime = 0
        end
        uiAtlasLabel_countdownTime:setString(tostring(currentTime))
    end
    uiAtlasLabel_countdownTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventTime))))    

--    local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
--    uiPanel_outCardTips:setVisible(false)
end

function TableLayer:showLeftCardCount(bLeftCardCount, bLeftCardData)
    local uiPanel_showEndCard = ccui.Helper:seekWidgetByName(self.root,"Panel_showEndCard")
    local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
    uiImage_stack:removeAllChildren()
    local uiAtlasLabel_stack = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_stack")
    uiAtlasLabel_stack:setVisible(false)
    local uiPanel_showStack = ccui.Helper:seekWidgetByName(uiPanel_showEndCard,"Panel_showStack")
    local cardScale = 0.8
    local time = 0.1
    local cardWidth = 42 * cardScale
    local cardHeight = 42 * cardScale
    local stepX = cardWidth
    local stepY = cardHeight
    local size = uiPanel_showStack:getContentSize()
    local uidipai = cc.Sprite:create("tszipai/table/endlayer_dipai.png")   
    local beganX = (size.width - bLeftCardCount*stepX)/2 - stepX/2
    local beganY = stepY/2 
    uidipai:setPosition((size.width - bLeftCardCount*stepX)/2 - stepX/2-16,stepY/2 )
    uiPanel_showStack:addChild(uidipai)
    for i = 1, bLeftCardCount do
        local card = self:getDiscardCardAndWeaveItemArray(bLeftCardData[i])
        uiPanel_showStack:addChild(card)
        card:setPosition(uiImage_stack:getPosition())
        card:setScale(0)
        card:runAction(cc.Sequence:create(cc.DelayTime:create(1*i*0.03),cc.Spawn:create(cc.ScaleTo:create(time,cardScale),cc.MoveTo:create(time,cc.p(beganX + i * stepX,beganY)))))
    end
end

--更新牌堆
function TableLayer:updateLeftCardCount(bLeftCardCount, isEffects, isSendCardEffects)
    GameCommon.bLeftCardCount = bLeftCardCount
    local uiPanel_stack = ccui.Helper:seekWidgetByName(self.root,"Panel_stack")
    uiPanel_stack:setVisible(true)
    local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
    uiImage_stack:removeAllChildren()
    local uiAtlasLabel_stack = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_stack")
    uiAtlasLabel_stack:setString(string.format("%d",GameCommon.bLeftCardCount))
    local showCount = 7
    if GameCommon.bLeftCardCount < showCount then
        showCount = GameCommon.bLeftCardCount
    end
    local size = uiImage_stack:getContentSize()
    local initPos = cc.p(size.width/2, size.height + 100)
    for i = 1, showCount do
        local img = ccui.ImageView:create("tszipai/card/card_pile.png")
        local pos = cc.p(size.width*0.5,size.height*0.45+i*2+3)
        if isEffects == true then
            img:setPosition(initPos)
            img:runAction(cc.MoveTo:create(1*i*0.03,pos))
        else
            img:setPosition(pos)
        end
        uiImage_stack:addChild(img)
    end
    if isSendCardEffects == true and showCount >= 7 then
        local i = 8
        local img = ccui.ImageView:create("tszipai/table/word_plate_table27.png")
        local pos = cc.p(size.width*0.5,size.height*0.45+i*2+3)
        img:setPosition(pos)
        uiImage_stack:addChild(img)
        img:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0),cc.RemoveSelf:create()))
    end
end

-------------------------------------------------------吃牌组合-----------------------------------------------------

--添加吃牌组合
function TableLayer:addWeaveItemArray(wChairID,WeaveItemArray,location, pos)
    GameCommon.player[wChairID].bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount + 1
    table.insert(GameCommon.player[wChairID].WeaveItemArray, location, WeaveItemArray)
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local node = self:setWeaveItemArray(wChairID, GameCommon.player[wChairID].bWeaveItemCount, GameCommon.player[wChairID].WeaveItemArray,location)
    if pos ~= nil then
        local srcPos = cc.p(node:getPosition())
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        node:setPosition(cc.p(node:getParent():convertToNodeSpace(cc.p(uiPanel_tipsCardPos:getPosition()))))
        node:runAction(cc.MoveTo:create(0.2,srcPos))
    end
end

--更新吃牌组合
function TableLayer:setWeaveItemArray(wChairID, bWeaveItemCount, WeaveItemArray,location)
    GameCommon.player[wChairID].bWeaveItemCount = bWeaveItemCount
    GameCommon.player[wChairID].WeaveItemArray = WeaveItemArray
    local isShow = false
    if GameCommon.tableConfig.nTableType ~= TableType_Playback or GameCommon.gameState == GameCommon.GameState_Over then
    	isShow = true
    end
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_weaveItemArray = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_weaveItemArray%d",viewID))
    uiPanel_weaveItemArray:removeAllChildren()
    local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
    local pos = cc.p(uiPanel_tipsCardPos:getPosition())
    local anchorPoint = uiPanel_weaveItemArray:getAnchorPoint()
    local size = uiPanel_weaveItemArray:getContentSize()
    local bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount
    local WeaveItemArray = GameCommon.player[wChairID].WeaveItemArray
    local cardScale = 1
    local cardWidth = 42 * cardScale
    local cardHeight = 42 * cardScale
    local stepX = cardWidth + 5
    local stepY = cardHeight
    local maxRow = 7
    local beganX = 0
    if anchorPoint.x == 1 then
        beganX = size.width
        stepX = -cardWidth - 5
    end
    local node = nil
    for key = 1, bWeaveItemCount do
        local var = GameCommon.player[wChairID].WeaveItemArray[key]
        if var == nil then
            assert(false,"组合数量和组合牌型不对")
        end
        local content = ccui.Layout:create()
        if key == location then
            node = content
        end
        GameCommon.player[wChairID].WeaveItemArray[key].node = content
        uiPanel_weaveItemArray:addChild(content)
        content:setContentSize(cc.size(stepX,stepY*4))
        content:setPosition(beganX + stepX*(key-1),0)
        local beganY = 0
        if anchorPoint.y == 1 then
            beganY = size.height - var.cbCardCount * stepY
        end
        for k = 1, var.cbCardCount do
            local v = var.cbCardList[k]
            if GameLogic:IsValidCard(v) then
                local card = nil
                if var.cbWeaveKind == GameCommon.ACK_CHI then
                    card = self:getDiscardCardAndWeaveItemArray(v)
                    if k == 3 then
                        card:setColor(cc.c3b(180,180,180)) 
                    end
                    
                elseif var.cbWeaveKind == GameCommon.ACK_CHOUWEI then
                    if k < 3 then
                        card = self:getDiscardCardAndWeaveItemArray(0)
                    else
                        card = self:getDiscardCardAndWeaveItemArray(v)
                    end
                    
                elseif var.cbWeaveKind == GameCommon.ACK_WEI then
                    if GameCommon.weiCardType == 0 then
                        if k < 3 then
                            card = self:getDiscardCardAndWeaveItemArray(0)
                        else
                            card = self:getDiscardCardAndWeaveItemArray(v)
                        end
                    else
                        if GameCommon.tableConfig.nTableType ~= TableType_Playback or viewID == 1 then
                            card = self:getDiscardCardAndWeaveItemArray(v)
                            card:setColor(cc.c3b(180,180,180)) 
                        else
                            card = self:getDiscardCardAndWeaveItemArray(0)
                        end
                    end
                    
                elseif var.cbWeaveKind== GameCommon.ACK_TI then
                    if GameCommon.tiCardType == 0 then
                        if k < 4 then
                            card = self:getDiscardCardAndWeaveItemArray(0)
                        else
                            card = self:getDiscardCardAndWeaveItemArray(v)
                        end
                    else
                        if GameCommon.tableConfig.nTableType ~= TableType_Playback or viewID == 1  then
                            card = self:getDiscardCardAndWeaveItemArray(v)
                            card:setColor(cc.c3b(180,180,180)) 
                        else
                            card = self:getDiscardCardAndWeaveItemArray(0)
                        end
                    end
                    
                else
                    card = self:getDiscardCardAndWeaveItemArray(v)
                end
                content:addChild(card)
                card:setAnchorPoint(cc.p(anchorPoint.x,0))
                card:setScale(cardScale) 
                card:setPosition(0,beganY + (k-1)*stepY)
            end
        end
    end
    return node
end

-------------------------------------------------------弃牌-----------------------------------------------------

--添加弃牌
function TableLayer:addDiscardCard(wChairID, cbDiscardCard,isMask)
    if not isMask then
		isMask = false
	end
    GameCommon.player[wChairID].bDiscardCardCount = GameCommon.player[wChairID].bDiscardCardCount + 1 
    GameCommon.player[wChairID].bDiscardCard[GameCommon.player[wChairID].bDiscardCardCount] = cbDiscardCard
    GameCommon.player[wChairID].bOutCardMark[GameCommon.player[wChairID].bDiscardCardCount] = isMask
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local node = self:setDiscardCard(wChairID, GameCommon.player[wChairID].bDiscardCardCount, GameCommon.player[wChairID].bDiscardCard,GameCommon.player[wChairID].bOutCardMark)
    local pos = cc.p(node:getPosition())
    local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
    node:setPosition(cc.p(node:getParent():convertToNodeSpace(cc.p(uiPanel_tipsCardPos:getPosition()))))
    node:runAction(cc.MoveTo:create(0.2,pos))
end

--添加多个弃牌
function TableLayer:setDiscardCard(wChairID, bDiscardCardCount, bDiscardCard,bOutCardMark)
    GameCommon.player[wChairID].bDiscardCardCount = bDiscardCardCount
    GameCommon.player[wChairID].bDiscardCard = bDiscardCard
    bOutCardMark = bOutCardMark or {}
	GameCommon.player[wChairID].bOutCardMark = bOutCardMark
    
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    if viewID == 1 then
        viewID = 4
    end
    local uiPanel_discardCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_discardCard%d",viewID))
    uiPanel_discardCard:removeAllChildren()
    local anchorPoint = uiPanel_discardCard:getAnchorPoint()
    local size = uiPanel_discardCard:getContentSize()
    local bDiscardCardCount = GameCommon.player[wChairID].bDiscardCardCount
    local bDiscardCard = GameCommon.player[wChairID].bDiscardCard
    local cardScale = 0.9
    local cardWidth = 42 * cardScale
    local cardHeight = 42 * cardScale
    local stepX = cardWidth
    local stepY = cardHeight
    local maxRow = 7
    local beganX = cardWidth/2
    if anchorPoint.x == 1 then
        beganX = size.width - cardWidth/2
        stepX = -cardWidth
    end
    local beganY = cardHeight/2
    if anchorPoint.y == 1 then
        beganY = size.height - cardHeight/2
        stepY = -cardHeight
    end
    local lastNode = nil
    for i = 1, bDiscardCardCount do
        local card = self:getDiscardCardAndWeaveItemArray(bDiscardCard[i])
        lastNode = card
        uiPanel_discardCard:addChild(card)
        card:setScale(cardScale)

        local isMask = bOutCardMark[i]
		if isMask then
			card:setColor(cc.c3b(150, 150, 150))
		end
        local index = 0
        local row = i - 1
        if i > maxRow then
            row = i - maxRow - 1
            index = 1
        end    
        card:setPosition(beganX + stepX*row-1 ,beganY + stepY*index)
    end
    return lastNode
end

-------------------------------------------------------手牌-----------------------------------------------------
--设置手牌
function TableLayer:setHandCard(wChairID,bUserCardCount,cbCardIndex,maxHanCardRow,cbCardCoutWW)
    GameCommon.player[wChairID].bUserCardCount = bUserCardCount
    GameCommon.player[wChairID].maxHanCardRow = maxHanCardRow
    GameCommon.player[wChairID].cbCardIndex = cbCardIndex
    GameCommon.player[wChairID].cbCardCoutWW = 0

    --设置排序
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
    GameCommon.player[wChairID].cardStackInfo = self:sortHandCard(clone(cbCardIndex),maxHanCardRow,cc.p(uiImage_stack:getPosition()))
    if GameCommon.player[wChairID].cbCardCoutWW ~= nil then
        for i = 1 , cbCardCoutWW do
            self:addOneHandCard(wChairID, 33,cc.p(uiImage_stack:getPosition()))
        end
    end
end

--添加任意手牌
function TableLayer:addOneHandCard(wChairID, cbCard, pos)
    GameCommon.player[wChairID].bUserCardCount = GameCommon.player[wChairID].bUserCardCount + 1
    local cbCardIndex = GameLogic:SwitchToCardIndexs({cbCard},1)
    if GameCommon.player[wChairID].cbCardIndex == nil then
        self:setHandCard(wChairID,GameCommon.player[wChairID].bUserCardCount, cbCardIndex, 10, 0)
        return
    end
    local cbCardIndex = GameLogic:SwitchToCardIndex(cbCard)
    GameCommon.player[wChairID].cbCardIndex[cbCardIndex] = GameCommon.player[wChairID].cbCardIndex[cbCardIndex] + 1
    for key, var in pairs(GameCommon.player[wChairID].cardStackInfo) do
        if var.nCardCount < 3 then
            local _cardData = {}
            _cardData.data=cbCard
            _cardData.pt = pos

            table.insert(var.cbCardData,#var.cbCardData+1,_cardData)
            var.nCardCount = var.nCardCount + 1
            return GameCommon.player[wChairID].cardStackInfo
        end
    end

    local cardinfo = {}
    cardinfo.nCardCount = 1
    cardinfo.cbCardData = {}

    local _cardData = {}
    _cardData.data = cbCard
    _cardData.pt = pos
    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)

    table.insert(GameCommon.player[wChairID].cardStackInfo,#GameCommon.player[wChairID].cardStackInfo+1,cardinfo)
    return GameCommon.player[wChairID].cardStackInfo
end

--删除手牌
function TableLayer:removeHandCard(wChairID, cbCardData)
    if cbCardData == 0 or GameLogic:IsValidCard(cbCardData) == false then
        return
    end
    local cbCardIndex = GameLogic:SwitchToCardIndex(cbCardData)
    local pos = cc.p(0,0)
    if GameCommon.player[wChairID].cbCardIndex == nil then
        return pos
    end
    if self.copyHandCard ~= nil then
        self.copyHandCard.targetNode:setColor(cc.c3b(255,255,255))
        self.copyHandCard:removeFromParent()
        self.copyHandCard = nil
    end
    if GameCommon.player[wChairID].cbCardIndex[cbCardIndex] <= 0 then
        return
    end
    
    GameCommon.player[wChairID].cbCardIndex[cbCardIndex] = GameCommon.player[wChairID].cbCardIndex[cbCardIndex] - 1
    if GameCommon.player[wChairID].cardStackInfo ~= nil then
        local isDel = false
        for key, var in pairs(GameCommon.player[wChairID].cardStackInfo) do
            for k, v in pairs(var.cbCardData) do
                if v.data == cbCardData then
                    if v.node ~= nil then
                        v.node:removeFromParent()
                        v.node = nil
                    end
                    pos = v.pt
                    GameCommon.player[wChairID].cardStackInfo[key].nCardCount = GameCommon.player[wChairID].cardStackInfo[key].nCardCount -1
                    if GameCommon.player[wChairID].cardStackInfo[key].nCardCount <= 0 then
                        table.remove(GameCommon.player[wChairID].cardStackInfo,key) --删除整列
                    else
                        table.remove(GameCommon.player[wChairID].cardStackInfo[key].cbCardData,k)
                    end
                    isDel = true
                    break
                end
            end
            if isDel == true then
                break
            end
        end
    end
    return pos
end

--手牌排序
function TableLayer:sortHandCard(cardIndex, maxHanCardRow,pos)
    local cardStackInfo = {}    --1张遍历
    for i = 1, 10 do
        --三张
        if cardIndex[i+0] +  cardIndex[i+10] >= 3 then
            local cardinfo = {}
            cardinfo.nCardCount = cardIndex[i+0] +  cardIndex[i+10]
            cardinfo.cbCardData = {}
            for j = 1, cardIndex[i+0] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+0)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            for j = 1, cardIndex[i+10] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            cardIndex[i+0] = 0
            cardIndex[i+10] = 0
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
        if cardIndex[i+20] +  cardIndex[i+30] >= 3 then
            local cardinfo = {}
            cardinfo.nCardCount = cardIndex[i+20] +  cardIndex[i+30]
            cardinfo.cbCardData = {}
            for j = 1, cardIndex[i+20] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+20)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            for j = 1, cardIndex[i+30] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+30)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            cardIndex[i+20] = 0
            cardIndex[i+30] = 0
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
    end
    --对子
    for i = 1, 10 do
        if cardIndex[i+0] +  cardIndex[i+10] >= 2 then
            local cardinfo = {}
            cardinfo.nCardCount = cardIndex[i+0] +  cardIndex[i+10]
            cardinfo.cbCardData = {}
            for j = 1, cardIndex[i+0] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+0)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            for j = 1, cardIndex[i+10] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            cardIndex[i+0] = 0
            cardIndex[i+10] = 0
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
        if cardIndex[i+20] +  cardIndex[i+30] >= 2 then
            local cardinfo = {}
            cardinfo.nCardCount = cardIndex[i+20] +  cardIndex[i+30]
            cardinfo.cbCardData = {}
            for j = 1, cardIndex[i+20] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+20)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            for j = 1, cardIndex[i+30] do
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i+30)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
            end
            cardIndex[i+20] = 0
            cardIndex[i+30] = 0
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
    end
    --大二七十
    local tableCard = {2,7,10}
    if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
        cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
        cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
        local cardinfo = {}
        cardinfo.nCardCount = 3
        cardinfo.cbCardData = {}
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]] do
                cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]+10] do
                cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]] do
                cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]+10] do
                cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]] do
                cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]+10] do
                cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
    end
    
    --小二七十
    local tableCard = {22,27,30}
    if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
        cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
        cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
        local cardinfo = {}
        cardinfo.nCardCount = 3
        cardinfo.cbCardData = {}
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]] do
                cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]+10] do
                cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]] do
                cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]+10] do
                cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]] do
                cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]+10] do
                cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
    end
    --大一二三
    local tableCard = {1,2,3}
    if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
        cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
        cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
        local cardinfo = {}
        cardinfo.nCardCount = 3
        cardinfo.cbCardData = {}
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]] do
                cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]+10] do
                cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]] do
                cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]+10] do
                cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]] do
                cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]+10] do
                cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
    end

    --小一二三
    local tableCard = {21,22,23}
    if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
        cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
        cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
        local cardinfo = {}
        cardinfo.nCardCount = 3
        cardinfo.cbCardData = {}
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]] do
                cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 0 then
            for j = 1, cardIndex[tableCard[1]+10] do
                cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]] do
                cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 1 then
            for j = 1, cardIndex[tableCard[2]+10] do
                cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]] do
                cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        if #cardinfo.cbCardData <= 2 then
            for j = 1, cardIndex[tableCard[3]+10] do
                cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                break
            end
        end
        table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
    end
    
    --顺子
    for i = 1, 7 do
        --大顺子
        local tableCard = {i,i+1,i+2}
        if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
            cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
            cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
            local cardinfo = {}
            cardinfo.nCardCount = 3
            cardinfo.cbCardData = {}
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]] do
                    cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]+10] do
                    cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]] do
                    cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]+10] do
                    cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 2 then
                for j = 1, cardIndex[tableCard[3]] do
                    cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 2 then
                for j = 1, cardIndex[tableCard[3]+10] do
                    cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end

        --小顺子
        local tableCard = {20+i,20+i+1,20+i+2}
        if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
            cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 and 
            cardIndex[tableCard[3]] + cardIndex[tableCard[3]+10] > 0 then
            local cardinfo = {}
            cardinfo.nCardCount = 3
            cardinfo.cbCardData = {}
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]] do
                    cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]+10] do
                    cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]] do
                    cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]+10] do
                    cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 2 then
                for j = 1, cardIndex[tableCard[3]] do
                    cardIndex[tableCard[3]] = cardIndex[tableCard[3]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[3])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 2 then
                for j = 1, cardIndex[tableCard[3]+10] do
                    cardIndex[tableCard[3]+10] = cardIndex[tableCard[3]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[3]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
    end
    
    --两个大小
    for i=1 , 10 do
        local tableCard = {i,i+20}
        if cardIndex[tableCard[1]] + cardIndex[tableCard[1]+10] > 0 and 
            cardIndex[tableCard[2]] + cardIndex[tableCard[2]+10] > 0 then
            local cardinfo = {}
            cardinfo.nCardCount = 2
            cardinfo.cbCardData = {}
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]] do
                    cardIndex[tableCard[1]] = cardIndex[tableCard[1]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 0 then
                for j = 1, cardIndex[tableCard[1]+10] do
                    cardIndex[tableCard[1]+10] = cardIndex[tableCard[1]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[1]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]] do
                    cardIndex[tableCard[2]] = cardIndex[tableCard[2]] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2])
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            if #cardinfo.cbCardData <= 1 then
                for j = 1, cardIndex[tableCard[2]+10] do
                    cardIndex[tableCard[2]+10] = cardIndex[tableCard[2]+10] - 1
                    local _cardData = {}
                    _cardData.data=GameLogic:SwitchToCardData(tableCard[2]+10)
                    _cardData.pt = pos
                    table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                    break
                end
            end
            table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
        end
    end
    
    for i=1 ,40 do
        local count = cardIndex[i]
        for j = 1, count do
            if #cardStackInfo < maxHanCardRow then
                --如果一张牌都没有，则新建一列
                cardIndex[i] = cardIndex[i]-1
                local cardinfo = {}
                cardinfo.nCardCount = 1
                cardinfo.cbCardData = {}
                local _cardData = {}
                _cardData.data=GameLogic:SwitchToCardData(i)
                _cardData.pt = pos
                table.insert(cardinfo.cbCardData,#cardinfo.cbCardData + 1,_cardData)
                table.insert(cardStackInfo,#cardStackInfo+1,cardinfo)
            else
                for j= #cardStackInfo , 1 , -1 do
                    if cardStackInfo[j].nCardCount < 3 then
                        cardStackInfo[j].nCardCount = cardStackInfo[j].nCardCount + 1
                        cardIndex[i]=cardIndex[i]-1
                        local _cardData = {}
                        _cardData.data=GameLogic:SwitchToCardData(i)
                        _cardData.pt = pos
                        table.insert(cardStackInfo[j].cbCardData,#cardStackInfo[j].cbCardData+1,_cardData)
                        break
                    end
                end
            end
        end
    end
    return cardStackInfo
end

--更新手牌
function TableLayer:showHandCard(wChairID,effectsType,isShowEndCard)
    if GameCommon.player[wChairID].cbCardIndex == nil then
        return
    end
    local isCanMove = false
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiImage_line = ccui.Helper:seekWidgetByName(self.root,"Image_line")
    uiImage_line:setVisible(false)
    local lineY = uiImage_line:getPositionY()
    local uiPanel_handCard = nil
    local cardScale = 0.4
    if isShowEndCard == true then
        local uiPanel_card = ccui.Helper:seekWidgetByName(self.root,"Panel_card")
        uiPanel_handCard = ccui.Helper:seekWidgetByName(uiPanel_card,"Panel_handCard")
        uiPanel_handCard:removeAllChildren()
        local uiPanel_showEndCard = ccui.Helper:seekWidgetByName(self.root,"Panel_showEndCard")
        uiPanel_showEndCard:setVisible(true)
        uiPanel_handCard = ccui.Helper:seekWidgetByName(uiPanel_showEndCard,string.format("Panel_handCard%d",viewID))
        if viewID == 1 and (GameCommon.gameConfig.bPlayerCount == 3 or GameCommon.gameConfig.bPlayerCount == 4)  then
            cardScale = 1
            uiPanel_handCard = ccui.Helper:seekWidgetByName(uiPanel_showEndCard,"Panel_handCardRole")
        end
    else
        local uiPanel_card = ccui.Helper:seekWidgetByName(self.root,"Panel_card")
        uiPanel_handCard = ccui.Helper:seekWidgetByName(uiPanel_card,string.format("Panel_handCard%d",viewID))
        if viewID == 1 and (GameCommon.gameConfig.bPlayerCount == 3 or GameCommon.gameConfig.bPlayerCount == 4 or GameCommon.tableConfig.nTableType ~= TableType_Playback )  then
            cardScale = 1
            isCanMove = true
            uiPanel_handCard:removeAllChildren()
            uiPanel_handCard = ccui.Helper:seekWidgetByName(uiPanel_card,"Panel_handCardRole")
        end
    end
    uiPanel_handCard:removeAllChildren()
    local uiPanel_copyHandCard = ccui.Helper:seekWidgetByName(self.root,"Panel_copyHandCard")
    uiPanel_copyHandCard:removeAllChildren()
    self.copyHandCard = nil
    local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
    local pos = cc.p(uiPanel_handCard:getPosition())
    local cardStackInfo = GameCommon.player[wChairID].cardStackInfo
    local maxHanCardRow = GameCommon.player[wChairID].maxHanCardRow
    local nCardStackCount = #cardStackInfo
    local size = uiPanel_handCard:getContentSize()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    
    local anchorPoint = uiPanel_handCard:getAnchorPoint()
    local index = 0
    local time = 0.1
    local cardWidth = 98 * cardScale
    local cardHeight = 122 * cardScale
    local stepX = cardWidth
    local stepY = cardHeight * 0.7
    local beganX = (size.width - nCardStackCount * stepX) / 2
    if anchorPoint.x == 0 then
        beganX = 0
    elseif anchorPoint.x == 1 then
        beganX = size.width - nCardStackCount * stepX
    end
    for key, var in pairs(cardStackInfo) do
        for k, v in pairs(var.cbCardData) do
            local card = self:GetCardHand(v.data)
            uiPanel_handCard:addChild(card)
            v.node = card
            card:setLocalZOrder(4-k)
            if effectsType == 1 then--发牌特效
                index = index + 1
--                card:setPosition(uiPanel_handCard:convertToNodeSpace(cc.p(uiImage_stack:getParent():convertToWorldSpace(cc.p(uiImage_stack:getPosition())))))
--                v.pt = cc.p(beganX + key*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
--                card:setScale(0)
--                card:runAction(cc.Sequence:create(cc.DelayTime:create(1*index*0.03),cc.Spawn:create(cc.ScaleTo:create(time,cardScale),cc.MoveTo:create(time,v.pt))))
                if anchorPoint.x == 0.5 then
                    card:setPosition(uiPanel_handCard:getContentSize().width/2, stepY*(k-1) + cardHeight/2)
                elseif anchorPoint.x == 0 then
                    card:setPosition(beganX + 1*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
                else
                    card:setPosition(beganX + nCardStackCount*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
                end
                v.pt = cc.p(beganX + key*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
                card:setScale(cardScale)
                card:runAction(cc.MoveTo:create(math.abs(v.pt.x - card:getPositionX())*time*0.01,v.pt))
            elseif effectsType == 2 then
                index = index + 1
                card:setPosition(v.pt)
                v.pt = cc.p(beganX + key*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
                card:setScale(cardScale)
                card:runAction(cc.MoveTo:create(time,v.pt))
            else
                card:setPosition(v.pt)
                v.pt = cc.p(beganX + key*stepX - cardWidth/2, stepY*(k-1) + cardHeight/2)
                card:setPosition(v.pt)
                card:setScale(cardScale)
            end
            if isCanMove == true then --主角位置才能拖动手牌
                card:setTouchEnabled(true)
                local preRow = 0
                card:addTouchEventListener(function(sender,event)
                    if event == ccui.TouchEventType.began then
                        uiImage_line:setVisible(true)
                        local pos = cc.p(uiPanel_handCard:convertToNodeSpace(self.locationPos))
                        local posX = pos.x - beganX
                        local row = math.floor(posX/stepX)
                        if posX%stepX > 0 then
                            row = row + 1
                        end
                        --判断是否可以拖动
                        local isCan = true
                        if GameCommon.player[wChairID].cardStackInfo[row].nCardCount >= 3 then
                            isCan = false
                            local value = nil
                            for key, var in pairs(GameCommon.player[wChairID].cardStackInfo[row].cbCardData) do
                                if value ~= nil and value ~= var.data then
                                    isCan = true
                                    break
                                end
                                value = var.data
                            end
                        end
                        if isCan == false then
                            return
                        end
                        preRow = row
                        uiPanel_copyHandCard:removeAllChildren()
                        self.copyHandCard = nil
                        self.copyHandCard = card:clone()
                        self.copyHandCard.targetNode = card
                        card:setColor(cc.c3b(170,170,170))
                        uiPanel_copyHandCard:addChild(self.copyHandCard)
                        self.copyHandCard:setPosition(self.locationPos)
                    elseif event == ccui.TouchEventType.moved then
                        if self.copyHandCard ~= nil then
                            self.copyHandCard:setPosition(self.locationPos)
                        end
                    else
                        uiImage_line:setVisible(false)
                        if self.copyHandCard ~= nil then
                            uiPanel_copyHandCard:removeAllChildren()
                            self.copyHandCard = nil
                            card:setColor(cc.c3b(255,255,255))
                            if GameCommon.waitOutCardUser == GameCommon:getRoleChairID() and self.locationPos.y > lineY then
                                self.outData = {wChairID = wChairID, cbCardData = v.data, x = key, y = k} 
                                EventMgr:dispatch(EventType.EVENT_TYPE_OPERATIONAL_OUT_CARD,self.outData)
                                return
                            end
                            if GameCommon.waitOutCardUser ~= GameCommon:getRoleChairID() and self.locationPos.y > lineY then
                                return
                            end
                            
                            local pos = cc.p(uiPanel_handCard:convertToNodeSpace(self.locationPos))
                            local posX = pos.x - beganX
                            local row = math.floor(posX/stepX)
                            if posX%stepX > 0 then
                                row = row + 1
                            end
                            if row <= 0 then   --插入最左边
                                if nCardStackCount < maxHanCardRow or GameCommon.player[wChairID].cardStackInfo[preRow].nCardCount <= 1 then
                                    card:removeFromParent()
                                    v.node = nil
                                    GameCommon.player[wChairID].cardStackInfo[key].nCardCount = GameCommon.player[wChairID].cardStackInfo[key].nCardCount -1
                                    if GameCommon.player[wChairID].cardStackInfo[key].nCardCount <= 0 then
                                        table.remove(GameCommon.player[wChairID].cardStackInfo,key) --删除整列
                                    else
                                        table.remove(GameCommon.player[wChairID].cardStackInfo[key].cbCardData,k)
                                    end

                                    local cardinfo = {}
                                    cardinfo.nCardCount=1
                                    cardinfo.cbCardData = {}

                                    local _cardData = {}
                                    _cardData.data = v.data
                                    _cardData.pt = pos
                                    table.insert(cardinfo.cbCardData,1,_cardData)
                                    table.insert(GameCommon.player[wChairID].cardStackInfo, 1, cardinfo)

                                    self:showHandCard(wChairID,2)
                            end
                            elseif row > nCardStackCount then   --插入最右边
                                if nCardStackCount < maxHanCardRow or GameCommon.player[wChairID].cardStackInfo[preRow].nCardCount <= 1 then
                                    card:removeFromParent()
                                    v.node = nil
                                    GameCommon.player[wChairID].cardStackInfo[key].nCardCount = GameCommon.player[wChairID].cardStackInfo[key].nCardCount -1
                                    if GameCommon.player[wChairID].cardStackInfo[key].nCardCount <= 0 then
                                        table.remove(GameCommon.player[wChairID].cardStackInfo,key) --删除整列
                                    else
                                        table.remove(GameCommon.player[wChairID].cardStackInfo[key].cbCardData,k)
                                    end

                                    local cardinfo = {}
                                    cardinfo.nCardCount=1
                                    cardinfo.cbCardData = {}

                                    local _cardData = {}
                                    _cardData.data = v.data
                                    _cardData.pt = pos
                                    table.insert(cardinfo.cbCardData,1,_cardData)
                                    table.insert(GameCommon.player[wChairID].cardStackInfo, #GameCommon.player[wChairID].cardStackInfo + 1, cardinfo)

                                    self:showHandCard(wChairID,2)
                            end
                            else
                                if (GameCommon.player[wChairID].cardStackInfo[row].nCardCount < 3) or
                                    (row == key and k < var.nCardCount and GameCommon.player[wChairID].cardStackInfo[row].nCardCount < 4) then
                                    card:removeFromParent()
                                    v.node = nil
                                    local _cardData = {}
                                    _cardData.data = v.data
                                    _cardData.pt = pos
                                    GameCommon.player[wChairID].cardStackInfo[row].nCardCount = GameCommon.player[wChairID].cardStackInfo[row].nCardCount + 1
                                    table.insert(GameCommon.player[wChairID].cardStackInfo[row].cbCardData, #GameCommon.player[wChairID].cardStackInfo[row].cbCardData + 1, _cardData)

                                    GameCommon.player[wChairID].cardStackInfo[key].nCardCount = GameCommon.player[wChairID].cardStackInfo[key].nCardCount -1
                                    if GameCommon.player[wChairID].cardStackInfo[key].nCardCount <= 0 then
                                        table.remove(GameCommon.player[wChairID].cardStackInfo,key) --删除整列
                                    else
                                        table.remove(GameCommon.player[wChairID].cardStackInfo[key].cbCardData,k)
                                    end
                                    self:showHandCard(wChairID,2)
                                end
                            end 
                        end
                    end
                end)
            end
        end
    end
end

function TableLayer:initUI()
    --初始化UI
    require("common.Common"):playEffect("game/pipeidonghua.mp3")
    local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
    uiText_desc:setString("")
    local uiImage_countdown = ccui.Helper:seekWidgetByName(self.root,"Image_countdown")
    uiImage_countdown:setVisible(false)
--    local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
--    uiPanel_outCardTips:setVisible(false)
    local uiImage_line = ccui.Helper:seekWidgetByName(self.root,"Image_line")
    uiImage_line:setVisible(false)
    local visibleSize = cc.Director:getInstance():getVisibleSize()

    --水印
    local uiImage_watermark = ccui.Helper:seekWidgetByName(self.root,"Image_watermark")
    uiImage_watermark:loadTexture(StaticData.Channels[CHANNEL_ID].icon)
    uiImage_watermark:ignoreContentAdaptWithSize(true)
    
    --UI层
    local uiButton_menu = ccui.Helper:seekWidgetByName(self.root,"Button_menu")
    local uiPanel_function = ccui.Helper:seekWidgetByName(self.root,"Panel_function")
    uiPanel_function:setEnabled(false)
    Common:addTouchEventListener(uiButton_menu,function() 
        uiPanel_function:stopAllActions()
        uiPanel_function:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-99,0)),cc.CallFunc:create(function(sender,event) 
            uiPanel_function:setEnabled(true)
        end)))
        uiButton_menu:stopAllActions()
        uiButton_menu:runAction(cc.ScaleTo:create(0.2,0))
    end)
    uiPanel_function:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            uiPanel_function:stopAllActions()
            uiPanel_function:runAction(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
                uiPanel_function:setEnabled(false)
            end),cc.MoveTo:create(0.2,cc.p(0,0))))
            uiButton_menu:stopAllActions()
            uiButton_menu:runAction(cc.ScaleTo:create(0.2,0.8))
        end
    end)  
                   
    --表情
    local uiButton_expression = ccui.Helper:seekWidgetByName(self.root,"Button_expression")
    uiButton_expression:setPressedActionEnabled(true)
    local function onEventExpression(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            require("common.GameChatLayer"):create(GameCommon.tableConfig.wKindID,function(index) 
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_GF_USER_EXPRESSION,"ww",index,GameCommon:getRoleChairID())
            end,            
            function(index,contents)
                print("表情 ",index,contents)
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SEND_CHAT,"dwbnsdns",
                    GameCommon:getRoleChairID(),index,GameCommon:getUserInfo(GameCommon:getRoleChairID()).cbSex,32,"",string.len(contents),string.len(contents),contents)
            end)
        end
    end    
    uiButton_expression:addTouchEventListener(onEventExpression)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_settings"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("SettingsLayer"))
    end)
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_gameBg")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_skin"),function() 
        local UserDefault_ZiPaipaizhuo = nil
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
            UserDefault_ZiPaipaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,2)
        else
            UserDefault_ZiPaipaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,0)
        end
        UserDefault_ZiPaipaizhuo = UserDefault_ZiPaipaizhuo + 1
        if UserDefault_ZiPaipaizhuo < 0 or UserDefault_ZiPaipaizhuo > 2 then
            UserDefault_ZiPaipaizhuo = 0
        end
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_ZiPaipaizhuo,UserDefault_ZiPaipaizhuo)
        uiPanel_bg:removeAllChildren()
        uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_ZiPaipaizhuo)))
    end)
    local UserDefault_ZiPaipaizhuo = nil
    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
        UserDefault_ZiPaipaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,2)
    else
        UserDefault_ZiPaipaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_ZiPaipaizhuo,0)
    end
    if UserDefault_ZiPaipaizhuo < 0 or UserDefault_ZiPaipaizhuo > 2 then
        UserDefault_ZiPaipaizhuo = 0
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_ZiPaipaizhuo,UserDefault_ZiPaipaizhuo)
    end
    if UserDefault_ZiPaipaizhuo ~= 0 then
        uiPanel_bg:removeAllChildren()
        uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_ZiPaipaizhuo)))
    end
    local uiButton_disbanded = ccui.Helper:seekWidgetByName(self.root,"Button_disbanded")
    local uiPanel_end = ccui.Helper:seekWidgetByName(self.root,"Panel_end")
    Common:addTouchEventListener(uiButton_disbanded,function() 
        require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
        end)
    end)
    
    local uiButton_return = ccui.Helper:seekWidgetByName(self.root,"Button_return")
    Common:addTouchEventListener(uiButton_return,function() 
        require("common.MsgBoxLayer"):create(1,nil,"您确定返回大厅?",function()
            require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
        end)
    end) 
    
    local uiText_title = ccui.Helper:seekWidgetByName(self.root,"Text_title")
--    local uiButton_hosted = ccui.Helper:seekWidgetByName(self.root,"Button_hosted")
--    Common:addTouchEventListener(uiButton_hosted,function() 
--        GameCommon.hostedTime = 0
--        local uiPanel_hosted = ccui.Helper:seekWidgetByName(self.root,"Panel_hosted")
--        uiPanel_hosted:setVisible(true) 
--    end)
    local uiButton_cancelHosted = ccui.Helper:seekWidgetByName(self.root,"Button_cancelHosted")
    Common:addTouchEventListener(uiButton_cancelHosted,function() 
        GameCommon.hostedTime = os.time()
        local uiPanel_hosted = ccui.Helper:seekWidgetByName(self.root,"Panel_hosted")
        uiPanel_hosted:setVisible(false) 
    end)
    
    local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")
    local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
    Common:addTouchEventListener(uiButton_ready,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"o",false)
    end)   
    local uiButton_cancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")  --取消按钮
    Common:addTouchEventListener(uiButton_cancel,function() 
        require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    end)  
    
    local uiButton_out = ccui.Helper:seekWidgetByName(self.root,"Button_out")
    Common:addTouchEventListener(uiButton_out,function() 
        require("common.MsgBoxLayer"):create(1,nil,"您确定离开房间?\n房主离开意味着房间被解散",function()
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_LEAVE_TABLE_USER,"")
        end)
    end) 
    
    local uiButton_position = ccui.Helper:seekWidgetByName(self.root,"Button_position")   -- 定位
    Common:addTouchEventListener(uiButton_position,function() 
        require("common.PositionLayer"):create(GameCommon.tableConfig.wKindID)
    end)
    local uiPanel_playerInfoBg = ccui.Helper:seekWidgetByName(self.root,"Panel_playerInfoBg")
    if GameCommon.tableConfig.wCurrentNumber == 0 and  GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        if CHANNEL_ID ~= 0 and CHANNEL_ID ~= 1 then
            uiPanel_playerInfoBg:setVisible(true) 
        else 
            uiPanel_playerInfoBg:setVisible(false)
        end
    end 
    local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        self:addVoice()
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        if  StaticData.Hide[CHANNEL_ID].btn10 == 0 then 
            uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position))
            uiPanel_playerInfoBg:setVisible(false) 
        end 
        uiButton_disbanded:setVisible(true)
        uiButton_cancel:setVisible(false)
        if GameCommon.gameState == GameCommon.GameState_Start  then
            uiButton_ready:setVisible(false)
            if StaticData.Hide[CHANNEL_ID].btn4 ~= 1 then
                uiButton_Invitation:setVisible(false)
                uiButton_out:setVisible(false)
            else
                uiButton_Invitation:setVisible(true)
                uiButton_out:setVisible(true)
            end
        elseif GameCommon.tableConfig.wCurrentNumber > 0 then
            uiButton_Invitation:setVisible(false)
            uiButton_out:setVisible(false)
        end
        uiText_title:setString(string.format("%s 房间号:%d 局数:%d/%d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.tableConfig.wTbaleID,GameCommon.tableConfig.wCurrentNumber,GameCommon.tableConfig.wTableNumber))

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/dengdaihaoyou/dengdaihaoyou.ExportJson")
        local waitArmature=ccs.Armature:create("dengdaihaoyou")
        waitArmature:setPosition(-179.2,-158)
        waitArmature:getAnimation():playWithIndex(0)
        uiButton_Invitation:addChild(waitArmature)    

    elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom then
        uiPanel_playerInfoBg:setVisible(false)
        self:addVoice()
        uiButton_voice:setVisible(false)
        uiButton_Invitation:setVisible(false)
        uiButton_ready:setVisible(false)
        uiButton_out:setVisible(false)
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_disbanded))
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
        uiButton_cancel:setVisible(true)
        if GameCommon.tableConfig.cbLevel == 2 then
            uiText_title:setString(string.format("%s 中级场 倍率 %d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.tableConfig.wCellScore))
        elseif GameCommon.tableConfig.cbLevel == 3 then
            uiText_title:setString(string.format("%s 高级场 倍率 %d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.tableConfig.wCellScore))
        else
            uiText_title:setString(string.format("%s 初级场 倍率 %d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.tableConfig.wCellScore))
        end
        self:drawnout() 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xunzhaoduishou/xunzhaoduishou.ExportJson")
        local waitArmature=ccs.Armature:create("xunzhaoduishou")
        waitArmature:setPosition(0,-158)
        waitArmature:getAnimation():playWithIndex(0)
        uiButton_cancel:addChild(waitArmature)
        
    elseif GameCommon.tableConfig.nTableType == TableType_SportsRoom then
        uiPanel_playerInfoBg:setVisible(false)
        self:addVoice()
        uiButton_voice:setVisible(false)
        uiButton_Invitation:setVisible(false)
        uiButton_ready:setVisible(false)
        uiButton_out:setVisible(false)
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_disbanded))
        if  StaticData.Hide[CHANNEL_ID].btn10 == 0 then 
            uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
        end 
        uiButton_cancel:setVisible(true)
        uiText_title:setString(string.format("%s 竞技场",StaticData.Games[GameCommon.tableConfig.wKindID].name))
        self:drawnout() 
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xunzhaoduishou/xunzhaoduishou.ExportJson")
        local waitArmature=ccs.Armature:create("xunzhaoduishou")
        waitArmature:setPosition(0,-158)
        waitArmature:getAnimation():playWithIndex(0)
        uiButton_cancel:addChild(waitArmature)
    else
        local uiPanel_ui = ccui.Helper:seekWidgetByName(self.root,"Panel_ui")
        uiPanel_ui:setVisible(false)
        uiText_title:setString(string.format("%s 牌局回放",StaticData.Games[GameCommon.tableConfig.wKindID].name))
    end
    --初始化Card
    local uiPanel_stack = ccui.Helper:seekWidgetByName(self.root,"Panel_stack")
    uiPanel_stack:setVisible(false)
    --初始化用户
    for i = 1, 4 do
        local uiPanel_player = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",i))
        uiPanel_player:setVisible(false)
        local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_avatar")
        uiImage_avatar:loadTexture("common/hall_avatar.png")
        uiImage_avatar:addTouchEventListener(function(sender,event) 
            if event == ccui.TouchEventType.ended then
                for key, var in pairs(GameCommon.player) do
                    if GameCommon:getViewIDByChairID(var.wChairID) == i then
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_PLAYER_INFO,"d",var.dwUserID)
                        break
                    end
                end
            end
        end)
        local uiImage_avatarFrame = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_avatarFrame")
        local uiImage_laba = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_laba")
        uiImage_laba:setVisible(false)
        local uiImage_banker = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_banker")
        uiImage_banker:setVisible(false)
        local uiText_name = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_name")
        uiText_name:setString("")
        local uiText_huXi = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_huXi")
        uiText_huXi:setString("")
        local uiText_score = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_score")
        uiText_score:setString("")
        local uiImage_ready = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_ready")
        uiImage_ready:setVisible(false)
        local uiImage_chat = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_chat")
        uiImage_chat:setVisible(false)
    end
    --冲分
    local uiPanel_chongFen = ccui.Helper:seekWidgetByName(self.root,"Panel_chongFen")
    uiPanel_chongFen:setVisible(false)
    local uiListView_chongFen = ccui.Helper:seekWidgetByName(self.root,"ListView_chongFen")
    local items = uiListView_chongFen:getItems()
    for key, var in pairs(items) do
    	Common:addTouchEventListener(var,function() 
    	   if key == 1 then
    	       NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CHONG_FEN,"b",1)
    	   elseif key == 2 then
    	       NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CHONG_FEN,"b",2)
    	   elseif key == 3 then
    	       NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CHONG_FEN,"b",3)
    	   else
    	       NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CHONG_FEN,"b",0)
	       end
    	end)
    end
    --死守
    local uiPanel_siShou = ccui.Helper:seekWidgetByName(self.root,"Panel_siShou")
    uiPanel_siShou:setVisible(false)
    local uiButton_siShou = ccui.Helper:seekWidgetByName(self.root,"Button_siShou")
    local uiButton_noSiShou = ccui.Helper:seekWidgetByName(self.root,"Button_noSiShou")
    Common:addTouchEventListener(uiButton_siShou,function(sender,event) 
        require("common.MsgBoxLayer"):create(1,nil,"箍臭之后不能胡牌,您确定要箍臭？",function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SISHOU,"b",1)
        end)
    end)
    Common:addTouchEventListener(uiButton_noSiShou,function(sender,event) 
        require("common.MsgBoxLayer"):create(1,nil,"您确定要不箍臭？",function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SISHOU,"b",2)
        end)
    end)
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    uiText_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
        local date = os.date("*t",os.time())
        uiText_time:setString(string.format("%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    end),cc.DelayTime:create(1))))
end

function TableLayer:drawnout()
    local uiImage_timedown = ccui.Helper:seekWidgetByName(self.root,"Image_timedown")
    uiImage_timedown:setVisible(true)
    
    local uiText__timedown = ccui.Helper:seekWidgetByName(self.root,"Text__timedown")
    uiText__timedown:setPosition(uiText__timedown:getParent():getContentSize().width/2,uiText__timedown:getParent():getContentSize().height*0.56)
    uiText__timedown:stopAllActions()
    uiText__timedown:setString("00:00:00")
    local currentTime = 0
    local function onEventTime(sender,event)   
        currentTime = currentTime + 1
        uiText__timedown:setString(string.format("%02d:%02d:%02d",math.floor(currentTime/(60*60)),math.floor(currentTime/60),math.floor(currentTime%60)))
    end
    uiText__timedown:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventTime)))) 
end 

function TableLayer:updateGameState(state)
    GameCommon.gameState = state 
    local visibleSize = cc.Director:getInstance():getVisibleSize()       
    if state == GameCommon.GameState_Init then
        if GameCommon.tableConfig.nTableType ~= TableType_Playback then
        end
    elseif state == GameCommon.GameState_Start then
		require("common.SceneMgr"):switchOperation()
        local uiPanel_playerInfoBg = ccui.Helper:seekWidgetByName(self.root,"Panel_playerInfoBg")
        uiPanel_playerInfoBg:setVisible(false)
        if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
            local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")
            local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
            uiButton_Invitation:setVisible(false)
            uiButton_ready:setVisible(false)
            
            --距离报警  
            local DistanceAlarm = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_DistanceAlarm",0)
            cc.UserDefault:getInstance():setIntegerForKey("UserDefault_DistanceAlarm",1)
            if GameCommon.tableConfig.wCurrentNumber ~= nil and GameCommon.tableConfig.wCurrentNumber == 1 and DistanceAlarm ~= 1 then
                if StaticData.Hide[CHANNEL_ID].btn16 ==1 then 
                    GameCommon.DistanceAlarm = 1 
                    require("common.DistanceAlarm"):create(GameCommon.tableConfig.wKindID)
                end 
            end
            for i = 1, 4 do
                local uiPanel_player = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",i))
                local uiImage_ready = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_ready")
                uiImage_ready:setVisible(false)
            end
        elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom or GameCommon.tableConfig.nTableType == TableType_SportsRoom then
            local uiButton_expression = ccui.Helper:seekWidgetByName(self.root,"Button_expression")
            uiButton_expression:setVisible(true)
            local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
            uiButton_voice:setVisible(true)
        end         
        local uiButton_cancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")  --取消按钮
        uiButton_cancel:setVisible(false)
        local uiImage_timedown = ccui.Helper:seekWidgetByName(self.root,"Image_timedown")
        uiImage_timedown:setVisible(false)
        local uiButton_out = ccui.Helper:seekWidgetByName(self.root,"Button_out")  --取消按钮
        uiButton_out:setVisible(false)
    elseif state == GameCommon.GameState_Over then
        UserData.Game:addGameStatistics(GameCommon.tableConfig.wKindID)
        local uiPanel_hosted = ccui.Helper:seekWidgetByName(self.root,"Panel_hosted")
        uiPanel_hosted:setVisible(false)
    else
    
    end
end

--语音
function TableLayer:addVoice()
    self.tableVoice = {}
    local startVoiceTime = 0
    local maxVoiceTime = 15
    local intervalTimePackage = 0.1
    local fileName = "temp_voice.mp3"
    local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
    local animVoice = cc.CSLoader:createNode("VoiceNode.csb")
    self:addChild(animVoice,120)
    local root = animVoice:getChildByName("Panel_root")
    local uiPanel_recording = ccui.Helper:seekWidgetByName(root,"Panel_recording")
    local uiPanel_cancel = ccui.Helper:seekWidgetByName(root,"Panel_cancel")
    local uiText_surplus = ccui.Helper:seekWidgetByName(root,"Text_surplus")
    animVoice:setVisible(false)

    --重置状态
    local duration = 0
    local function resetVoice()
        startVoiceTime = 0
        animVoice:stopAllActions()
        animVoice:setVisible(false)
        uiPanel_recording:setVisible(true)

        local uiImage_pro = ccui.Helper:seekWidgetByName(root,"Image_pro")
        uiImage_pro:removeAllChildren()
        local volumeMusic = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Music",1)
        cc.SimpleAudioEngine:getInstance():setMusicVolume(volumeMusic)
        cc.SimpleAudioEngine:getInstance():setEffectsVolume(1)
        uiButton_voice:removeAllChildren()
        local node = require("common.CircleLoadingBar"):create("game/tablenew_23.png")
        node:setColor(cc.c3b(0,0,0))
        uiButton_voice:addChild(node)
        node:setPosition(node:getParent():getContentSize().width/2,node:getParent():getContentSize().height/2)
        node:start(1)
        uiButton_voice:setEnabled(false)
        uiButton_voice:stopAllActions()
        uiButton_voice:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
            uiButton_voice:setEnabled(true)
        end)))
    end

    root:setTouchEnabled(true)
    root:addTouchEventListener(function(sender,event) 
        UserData.Game:cancelVoice()
        resetVoice() 
    end)

    local function onEventSendVoic(event)
        if self.root == nil then
            return
        end
        if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
            if event == nil or string.len(event) <= 0 then
                return
            else
                event = Base64.decode(event)
            end
            local file = io.open(FileDir.dirVoice..fileName,"wb+")
            file:write(event)
            file:close()
        end
        if cc.FileUtils:getInstance():isFileExist(FileDir.dirVoice..fileName) == false then
            print("没有找到录音文件",FileDir.dirVoice..fileName)
            return
        end
        local fp = io.open(FileDir.dirVoice..fileName,"rb")
        local fileData = fp:read("*a")
        fp:close()

        local data = {}
        data.chirID = GameCommon:getRoleChairID()
        data.time = duration
        data.file = string.format("%d_%d.mp3",os.time(),UserData.User.userID)

        local fp = io.open(FileDir.dirVoice..data.file,"wb+")
        fp:write(fileData)
        fp:close()
        table.insert(self.tableVoice,#self.tableVoice + 1,data) 

        cc.FileUtils:getInstance():removeFile(FileDir.dirVoice..fileName)   --windows test

        local fileSize = string.len(fileData)
        local packSize = 1024
        local additional = fileSize%packSize
        if additional > 0 then
            additional = 1
        else
            additional = 0
        end
        local packCount = math.floor(fileSize/packSize) + additional
        local currentPos = 0
        for i = 1 , packCount do
            local periodData = string.sub(fileData,1,packSize)
            fileData = string.sub(fileData,packSize + 1)
            local periodSize = string.len(periodData)
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_GF_USER_VOICE,"wwwdddnsnf",GameCommon:getRoleChairID(),packCount,i,data.time,fileSize,periodSize,32,data.file,periodSize,periodData)
        end

    end

    local function onEventVoice(sender,event)
        if event == ccui.TouchEventType.began then
            startVoiceTime = 0
            uiButton_voice:setEnabled(false)
            animVoice:setVisible(true)
            cc.SimpleAudioEngine:getInstance():setMusicVolume(0) 
            cc.SimpleAudioEngine:getInstance():setEffectsVolume(0) 
            uiPanel_recording:setVisible(true)
            startVoiceTime = os.time()
            UserData.Game:startVoice(FileDir.dirVoice..fileName,maxVoiceTime,onEventSendVoic)

            local node = require("common.CircleLoadingBar"):create("common/yuying02.png")
            local uiImage_pro = ccui.Helper:seekWidgetByName(root,"Image_pro")
            uiImage_pro:removeAllChildren()
            uiImage_pro:addChild(node)
            node:setPosition(node:getParent():getContentSize().width/2,node:getParent():getContentSize().height/2)
            node:start(maxVoiceTime)

            local currentTime = 0
            uiText_surplus:stopAllActions()
            uiText_surplus:setString(string.format("还剩%d秒",maxVoiceTime - currentTime))
            uiText_surplus:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                currentTime = currentTime + 1
                if currentTime > maxVoiceTime then
                    uiText_surplus:stopAllActions()
                    return
                end
                uiText_surplus:setString(string.format("还剩%d秒",maxVoiceTime - currentTime))
            end))))

        elseif event == ccui.TouchEventType.ended then
            if startVoiceTime == 0 or os.time() - startVoiceTime < 1 then
                UserData.Game:cancelVoice()
                resetVoice()
                return
            end
            duration = os.time() - startVoiceTime
            resetVoice()
            UserData.Game:overVoice()
            --onEventSendVoic() --windows test
        elseif event == ccui.TouchEventType.canceled then   
            if startVoiceTime == 0 or os.time() - startVoiceTime < 1 then
                resetVoice()
                return
            end
            resetVoice()
            UserData.Game:cancelVoice()
        end
    end
    uiButton_voice:addTouchEventListener(onEventVoice)
    local function onEventPlayVoice(sender,event)
        if #self.tableVoice > 0 then
            local data = self.tableVoice[1]
            table.remove(self.tableVoice,1)
            if data.time > maxVoiceTime then
                data.time = maxVoiceTime
            end
            local viewID = GameCommon:getViewIDByChairID(data.chirID)
            local wanjia = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
            local uiImage_laba = ccui.Helper:seekWidgetByName(wanjia,"Image_laba")
            local blinks = math.floor(data.time*2)+1
            uiImage_laba:stopAllActions()
            uiImage_laba:runAction(cc.Sequence:create(
                cc.Show:create(),
                cc.CallFunc:create(function(sender,event) 
                    require("common.Common"):playVoice(FileDir.dirVoice..data.file)
                end),
                cc.Blink:create(data.time,blinks) ,
                cc.Hide:create(),
                cc.DelayTime:create(1),
                cc.CallFunc:create(function(sender,event) 
                    cc.FileUtils:getInstance():removeFile(FileDir.dirVoice..data.file) 
                    onEventPlayVoice()
                end)
            ))

        else
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(onEventPlayVoice)))
        end
    end
    onEventPlayVoice()
end

function TableLayer:OnUserChatVoice(event)
    if self.tableVoicePackages == nil then
        self.tableVoicePackages = {}
    end
    if self.tableVoicePackages[event.szFileName] == nil then
        self.tableVoicePackages[event.szFileName] = {}
    end
    self.tableVoicePackages[event.szFileName][event.wPackIndex] = event

    --组包
    if event.wPackCount == #self.tableVoicePackages[event.szFileName] then
        local fileData = ""
        for key, var in pairs(self.tableVoicePackages[event.szFileName]) do
            fileData = fileData..var.szPeriodData
        end 
        local data = {}
        data.chirID = self.tableVoicePackages[event.szFileName][1].wChairID
        data.time = self.tableVoicePackages[event.szFileName][1].dwTime
        data.file = self.tableVoicePackages[event.szFileName][1].szFileName
        local fp = io.open(FileDir.dirVoice..data.file,"wb+")
        fp:write(fileData)
        fp:close()
        table.insert(self.tableVoice,#self.tableVoice + 1,data)
        self.tableVoicePackages[event.szFileName] = nil
        print("插入一条语音...",fileData)
    end
end

function TableLayer:showPlayerPosition()   -- 显示玩家距离
    local wChairID = 0
    for key, var in pairs(GameCommon.player) do
        if var.dwUserID == GameCommon.dwUserID then
            wChairID = var.wChairID
            break
        end
    end
    EventMgr:dispatch(EventType.RET_GAMES_USER_POSITION)
    for wChairID = 1, 4 do
        local uiPanel_players = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_players%d",wChairID))
        local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_players,"Image_avatar")
        uiImage_avatar:loadTexture("common/common_dian1.png")
        local uiText_name = ccui.Helper:seekWidgetByName(uiPanel_players,"Text_name")
        uiText_name:setString("") 
        for i = wChairID+1 , 4 do 
            local  uiText_location = ccui.Helper:seekWidgetByName(self.root,string.format("Text_%dto%d",wChairID,i)) 
            uiText_location:setString("")       
        end 
    end  
    local viewID = GameCommon:getViewIDByChairID(wChairID) 
    for wChairID = 0, 3 do
        if GameCommon.player[wChairID] ~= nil then
            local viewID = GameCommon:getViewIDByChairID(wChairID)
            local uiPanel_players = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_players%d",viewID))
            local uiPanel_playerInfo = ccui.Helper:seekWidgetByName(uiPanel_players,"Panel_playerInfo")
            uiPanel_playerInfo:setVisible(true)
            local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_players,"Image_avatar")
            if GameCommon.player[wChairID] ~= nil then 
                uiImage_avatar:loadTexture("common/common_dian2.png")
            end 
            local uiText_name = ccui.Helper:seekWidgetByName(uiPanel_players,"Text_name")
            uiText_name:setString(GameCommon.player[wChairID].szNickName)
            for wTargetChairID = 0, GameCommon.gameConfig.bPlayerCount-1 do
                local targetViewID = GameCommon:getViewIDByChairID(wTargetChairID)
                if GameCommon.gameConfig.bPlayerCount == 3 and wTargetChairID == 3 then
                    viewID = 4
                end
                if wTargetChairID ~= wChairID then
                    local uiText_location = ccui.Helper:seekWidgetByName(self.root,string.format("Text_%dto%d",viewID,targetViewID))
                    if viewID > targetViewID then
                        uiText_location = ccui.Helper:seekWidgetByName(self.root,string.format("Text_%dto%d",targetViewID,viewID))
                    end
                    if uiText_location ~= nil then
                        local distance = uiText_location:getString()
                        if GameCommon.gameConfig.bPlayerCount == 3 and (wChairID == 3 or wTargetChairID == 3) then
                            distance = ""
                        elseif GameCommon.player[wChairID] == nil or GameCommon.player[wTargetChairID] == nil then
                            distance = "等待加入..."
                        elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom or GameCommon.tableConfig.nTableType == TableType_SportsRoom then
                            if distance == "500m" then
                                distance = math.random(1000,300000)
                            end
                        elseif GameCommon.player[wChairID].location.x < 0.1 then
                            distance = string.format("%s\n未开启定位",GameCommon.player[wChairID].szNickName)
                        elseif GameCommon.player[wTargetChairID].location.x < 0.1 then
                            distance = string.format("%s\n未开启定位",GameCommon.player[wTargetChairID].szNickName)
                        else
                            distance = GameCommon:GetDistance(GameCommon.player[wChairID].location,GameCommon.player[wTargetChairID].location) 
                        end                     
                        if type(distance) == "string" then

                        elseif distance > 1000 then
                            distance = string.format("%dkm",distance/1000)
                        else
                            distance = string.format("%dm",distance)
                        end
                        uiText_location:setString(distance)
                    end
                end
            end
        end
    end
end

function TableLayer:showPlayerInfo(dwUserID,dwShamUserID)       -- 查看玩家信息
    Common:palyButton()
    require("common.PersonalLayer"):create(GameCommon.tableConfig.wKindID,dwUserID,dwShamUserID)
end

function TableLayer:showChat(pBuffer)
    local viewID = GameCommon:getViewIDByChairID(pBuffer.dwUserID)
    local uiPanel_player = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
    local uiImage_chat = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_chat")
    local uiText_chat = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_chat")
    uiText_chat:setString(pBuffer.szChatContent)
    uiImage_chat:setVisible(true)
    uiImage_chat:setScale(0)
    uiImage_chat:stopAllActions()
    uiImage_chat:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1),cc.DelayTime:create(5),cc.Hide:create()))
    local wKindID = GameCommon.tableConfig.wKindID
    local Chat = nil
    if CHANNEL_ID == 4 or CHANNEL_ID == 5 then 
        Chat = require("common.Chat")[3]
    else 
        if wKindID == 33 or wKindID == 34 or wKindID == 35 or wKindID == 36 or wKindID == 37 then
            Chat = require("common.Chat")[1]
        elseif wKindID == 47 or wKindID == 48 or wKindID == 49 then
            Chat = require("common.Chat")[2]
        else    
            Chat = require("common.Chat")[0]
        end
    end 
    local data = Chat[pBuffer.dwSoundID]
    if data ~= nil and data.sound[pBuffer.cbSex] ~= "" then
        require("common.Common"):playEffect(data.sound[pBuffer.cbSex])
    end

end

function TableLayer:showExperssion(pBuffer)
	local viewID = GameCommon:getViewIDByChairID(pBuffer.wChairID)
        local uiPanel_userTips = ccui.Helper:seekWidgetByName(self.root,"Panel_userTips")
        local uiPanel_userTipsPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_userTips%d",viewID))
        local filename = ""
        if pBuffer.wIndex == 0 then
            filename = "biaoqing-kaixin"
        elseif pBuffer.wIndex == 1 then
            filename = "biaoqing-shengqi"
        elseif pBuffer.wIndex == 2 then
            filename = "biaoqing-cool"
        elseif pBuffer.wIndex == 3 then
            filename = "biaoqing-xihuan"
        elseif pBuffer.wIndex == 4 then
            filename = "biaoqing-jingdai"
        elseif pBuffer.wIndex == 5 then
            filename = "biaoqing-daku" 
        else
            return
        end
        
        require("common.Common"):playEffect(string.format("expression/sound/%s.mp3",filename))
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("expression/animation/%s.ExportJson",filename))
        local  armature = ccs.Armature:create(filename)
        uiPanel_userTips:addChild(armature)
        armature:setScale(0.4)
        armature:getAnimation():playWithIndex(0)
        armature:setPosition(uiPanel_userTipsPos:getPosition())
        armature:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.RemoveSelf:create()))
end

--手牌资源
function TableLayer:GetCardHand(data)
    local _spt = nil
    local str = ""
    local value = Bit:_and(data,0x0F)
    local color = Bit:_rshift(Bit:_and(data,0xF0),4)
    if cc.FileUtils:getInstance():isFileExist(string.format("tszipai/card/hand%d_%d.png",color,value)) == false then
    	print(color,value)
    end
    _spt = ccui.ImageView:create(string.format("tszipai/card/hand%d_%d.png",color,value))
    return _spt
end

--吃牌组合资源
function TableLayer:getSendOrOutCard(data, isSendCard)
    local imgBg = nil
    if isSendCard == true then
        imgBg = ccui.ImageView:create("tszipai/card/card_send.png")    
    else
        imgBg = ccui.ImageView:create("tszipai/card/card_out.png")
    end
    local imgCard = nil
    if data == 0 then
        imgCard = ccui.ImageView:create("tszipai/card/card.png")
    else
        local value = Bit:_and(data,0x0F)
        local color = Bit:_rshift(Bit:_and(data,0xF0),4)
        imgCard = ccui.ImageView:create(string.format("tszipai/card/card%d_%d.png",color,value))
    end
    imgBg:addChild(imgCard)
    imgCard:setPosition(imgCard:getParent():getContentSize().width/2, imgCard:getParent():getContentSize().height/2)
    return imgBg
end

--获取棋牌或者吃牌组合资源
function TableLayer:getDiscardCardAndWeaveItemArray(data)
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

function TableLayer:playAnimation(id, wChairID)
    if type(id) == "number" then
        local data = GameLogic:SwitchToCardData(id)
        local value = Bit:_and(data,0x0F)
        local color = Bit:_and(data,0xF0)
        if color <= 0x10 then
            id = value + 10
        else
            id = value
        end
    end
    local AnimationPaoHuZi = require(string.format("game.paohuzi.43.Animation%d",GameCommon.regionSound))
    if AnimationPaoHuZi[id] == nil then
        print(GameCommon.regionSound,id)
        assert(false,string.format("找不到该动画：",GameCommon.regionSound,id))
        return
    end
    if AnimationPaoHuZi[id].animFile ~= "" then
        local visibleSize = cc.Director:getInstance():getVisibleSize()
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(AnimationPaoHuZi[id].animFile)
        local armature = ccs.Armature:create(AnimationPaoHuZi[id].animName)
        uiPanel_tipsCard:addChild(armature)
        armature:setScale(1.5)
        armature:getAnimation():playWithIndex(0,-1,0)
        armature:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.1,1),
            cc.DelayTime:create(1.0),
            cc.FadeOut:create(0.5),
            cc.RemoveSelf:create()))
        if id == "黄庄" then
            armature:setPosition(visibleSize.width/2, visibleSize.height/2)
        else
            local viewID = GameCommon:getViewIDByChairID(wChairID)
            local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
            armature:setPosition(uiPanel_tipsCardPos:getPosition())
        end
    end
    local soundFile = ""
    if wChairID ~= nil then
        soundFile = AnimationPaoHuZi[id].sound[GameCommon.player[wChairID].cbSex]
    else
        soundFile = AnimationPaoHuZi[id].sound[0]
    end
    if soundFile ~= "" then
        require("common.Common"):playEffect(AnimationPaoHuZi[id].sound[GameCommon.player[wChairID].cbSex])
    end
end

--==============================--
--desc:表情互动
--time:2018-08-14 07:40:11
--@wChairID:
--@return 
--==============================--

function TableLayer:getViewWorldPosByChairID(wChairID)
	for key, var in pairs(GameCommon.player) do
		if wChairID == var.wChairID then
			local viewid = GameCommon:getViewIDByChairID(var.wChairID, true)
			local uiPanel_player = ccui.Helper:seekWidgetByName(self.root, string.format("Panel_player%d", viewid))
			local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_player, "Image_avatar")
			return uiImage_avatar:getParent():convertToWorldSpace(cc.p(uiImage_avatar:getPosition()))
		end
	end
end

function TableLayer:playSketlAnim(sChairID, eChairID, index,indexEx)

    local cusNode = cc.Director:getInstance():getNotificationNode()
    if not cusNode then
    	printInfo('global_node is nil!')
    	return
    end
    local arr = cusNode:getChildren()
    for i,v in ipairs(arr) do
        v:setVisible(false)
    end

	local Animation = require("game.paohuzi.Animation")
	local AnimCnf = Animation[22]
	
	if not AnimCnf[index] then
		return
	end
    
    indexEx = indexEx or ''
	local skele_key_name = 'hhhudong_' .. index .. indexEx
	local spos = self:getViewWorldPosByChairID(sChairID)
	local epos = self:getViewWorldPosByChairID(eChairID)
	local image = ccui.ImageView:create(AnimCnf[index].imageFile .. '.png')
	self:addChild(image)
	image:setPosition(spos)
	local moveto = cc.MoveTo:create(0.6, cc.p(epos))
	local callfunc = cc.CallFunc:create(function()
		local path = AnimCnf[index].animFile
		local skeletonNode = cusNode:getChildByName(skele_key_name)
		if not skeletonNode then
			skeletonNode = sp.SkeletonAnimation:create(path .. '.json', path .. '.atlas', 1)
			cusNode:addChild(skeletonNode)
			skeletonNode:setName(skele_key_name)
		end
		skeletonNode:setPosition(epos)
		skeletonNode:setAnimation(0, 'animation', false)
		skeletonNode:setVisible(true)
		image:removeFromParent()

		skeletonNode:registerSpineEventHandler(function(event)
			skeletonNode:setVisible(false)
		end, sp.EventType.ANIMATION_END)
		
		local soundData = AnimCnf[index]
		local soundFile = ''
		if soundData then
			local sound = soundData.sound
			if sound then
				soundFile = sound[0]
			end
		end
		if soundFile ~= "" then
			require("common.Common"):playEffect(soundFile)
		end
	end)
	image:runAction(cc.Sequence:create(moveto, callfunc))
end

--表情互动
function TableLayer:playSkelStartToEndPos(sChairID, eChairID, index)
	self.isOpen = cc.UserDefault:getInstance():getBoolForKey('HHOpenUserEffect', true) --是否接受别人的互动
	
	if GameCommon.meChairID == sChairID then --我发出
		if sChairID == eChairID then
			for i, v in pairs(GameCommon.player or {}) do
				if v.wChairID ~= sChairID then
					self:playSketlAnim(sChairID, v.wChairID, index, v.wChairID)
				end
			end
		else
			self:playSketlAnim(sChairID, eChairID, index)
		end
	else
		if self.isOpen then
			if sChairID == eChairID then
				for i, v in pairs(GameCommon.player or {}) do
					if v.wChairID ~= sChairID then
						self:playSketlAnim(sChairID, v.wChairID, index, v.wChairID)
					end
				end
			else
				self:playSketlAnim(sChairID, eChairID, index)
			end
		end
	end
end

return TableLayer