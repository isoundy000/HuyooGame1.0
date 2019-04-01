local StaticData = require("app.static.StaticData")
local GameCommon = require("game.majiang.GameCommon") 
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
local GameLogic = require("game.majiang.GameLogic1")
local UserData = require("app.user.UserData")
local GameOpration = require("game.majiang.GameOpration1")
local GameSpecial = require("game.majiang.GameSpecial1")
local GameDesc = require("common.GameDesc")

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
    EventMgr:registListener(EventType.EVENT_TYPE_SKIN_CHANGE,self,self.EVENT_TYPE_SKIN_CHANGE)
end

function TableLayer:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_SKIN_CHANGE,self,self.EVENT_TYPE_SKIN_CHANGE)
end

function TableLayer:onCreate(root)
    self.flagNode = nil    --最后一张牌箭标
    self.root = root
    self.locationPos = cc.p(0,0)
    self.locationBeganPos = cc.p(0,0)
    local touchLayer = ccui.Layout:create()
    self.root:addChild(touchLayer)
    local function onTouchBegan(touch , event)
        self.locationPos = touch:getLocation()
        self.locationBeganPos = self.locationPos
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
    --重连最后出牌角标恢复
    if pBuffer.wLastOutCardUser then
        printInfo('Reconnect last card info = %d', pBuffer.wLastOutCardUser)
        local viewID = GameCommon:getViewIDByChairID(pBuffer.wLastOutCardUser)
        local uiPanel_discardCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_discardCard%d",viewID))
        if uiPanel_discardCard then
            local nodeArr = uiPanel_discardCard:getChildren()
            local childLen = #nodeArr
            if childLen > 0 then
                self:removeLastCardFlagEft()
                self:addLastCardFlagEft(nodeArr[childLen])
            end
        end
    end

    if GameCommon.tableConfig.wKindID == 50 and action == NetMsgId.SUB_S_SpecialCard_RESULT and pBuffer.wActionUser ~= GameCommon:getRoleChairID() then
    
    else
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()   
    end
    if action == NetMsgId.SUB_S_OUT_CARD_NOTIFY_MAJIANG then
        local wChairID = pBuffer.wOutCardUser   
        GameCommon.waitOutCardUser = wChairID
        self:showCountDown(wChairID)
        if wChairID == GameCommon:getRoleChairID() then
            local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
            uiPanel_outCardTips:removeAllChildren()
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/finger/finger.ExportJson")
            local armature = ccs.Armature:create("finger")
            uiPanel_outCardTips:addChild(armature)
            armature:getAnimation():playWithIndex(0)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
   
    elseif action == NetMsgId.SUB_S_OUT_CARD_RESULT then
        GameCommon.waitOutCardUser = nil
        local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
        uiPanel_outCardTips:removeAllChildren()
        local wChairID = pBuffer.wOutCardUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                end)))
        end
        uiSendOrOutCardNode = GameCommon:getDiscardCardAndWeaveItemArray(pBuffer.cbOutCardData,viewID)
        uiSendOrOutCardNode:setName("SendOrOutCardNode")
        uiSendOrOutCardNode.cbCardData = pBuffer.cbOutCardData
        uiSendOrOutCardNode.wChairID = wChairID
        uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
        local pos = nil
        if pBuffer.isNoDelete ~= true then
            if self.outData ~= nil and wChairID == GameCommon:getRoleChairID() and self.outData.cbCardData == pBuffer.cbOutCardData then
                --优先找出牌的节点
                local posCardData = -1
                for i = 1, GameCommon.player[wChairID].cbCardCount do
                    if GameCommon.player[wChairID].cbCardData[i] == pBuffer.cbOutCardData then
                        posCardData = i
                        break
                    end
                end
                local posCardNode = -1
                for key, var in pairs(GameCommon.player[wChairID].cardNode) do
                	if var.node == self.outData.cardNode then
                        posCardNode = key
                        break
                	end
                end
                if posCardData == -1 or posCardNode == -1 then
                    pos = self:removeHandCard(wChairID, pBuffer.cbOutCardData)
                else
                    table.remove(GameCommon.player[wChairID].cbCardData,posCardData)
                    local var = GameCommon.player[wChairID].cardNode[posCardNode]
                    pos = cc.p(var.node:getParent():convertToWorldSpace(cc.p(var.node:getPosition())))
                    var.node:removeFromParent()
                    table.remove(GameCommon.player[wChairID].cardNode,posCardNode)
                    GameCommon.player[wChairID].cbCardCount = GameCommon.player[wChairID].cbCardCount - 1
                end
                self.outData = nil
                self:showHandCard(wChairID,2)
            else
                self.outData = nil
                pos = self:removeHandCard(wChairID, pBuffer.cbOutCardData)
                self:showHandCard(wChairID,2)
            end
        end
        if pos == nil then
            uiSendOrOutCardNode:setPosition(uiPanel_tipsCardPos:getPosition())
            uiSendOrOutCardNode:setScale(0)
            uiSendOrOutCardNode:runAction(cc.ScaleTo:create(0.1,1))
        else
            uiSendOrOutCardNode:setPosition(cc.p(uiSendOrOutCardNode:getParent():convertToNodeSpace(pos)))
            uiSendOrOutCardNode:runAction(cc.MoveTo:create(0.1,cc.p(uiPanel_tipsCardPos:getPosition())))
        end
        GameCommon:playAnimation(self.root, pBuffer.cbOutCardData,wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        self:removeLastCardFlagEft()
        Common:playEffect("game/audio_card_out.mp3")
    elseif action == NetMsgId.SUB_S_SEND_CARD_MAJIANG then
        local wChairID = pBuffer.wCurrentUser
        GameCommon.waitOutCardUser = wChairID
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        if GameCommon.tableConfig.wKindID == 50 then
            for i = 1, 2 do
                local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName(string.format("SendOrOutCardNode%d",i))
                if uiSendOrOutCardNode ~= nil then
                uiSendOrOutCardNode:runAction(cc.Sequence:create(
                    cc.RemoveSelf:create(),
                    cc.CallFunc:create(function(sender,event) 
                        self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                        end)))
                end
            end
        end
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                    end)))
        end
        self:addOneHandCard(wChairID,pBuffer.cbCardData)
        self:showHandCard(wChairID,1)
        self:showCountDown(wChairID)
        self:updateLeftCardCount(GameCommon.cbLeftCardCount-1)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
    
    elseif action == NetMsgId.SUB_S_OPERATE_NOTIFY_MAJIANG then
        if GameCommon.tableConfig.wKindID == 50 and pBuffer.cbActionCard == 0 then
            pBuffer.tableActionCard = {}
            local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
            for i = 1, 2 do
                local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName(string.format("SendOrOutCardNode%d",i))
                if uiSendOrOutCardNode ~= nil then
                    pBuffer.tableActionCard[i] = uiSendOrOutCardNode.cbCardData
                end
            end
        end
        local oprationLayer = GameOpration:create(pBuffer)
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:addChild(oprationLayer)
        Common:playEffect("game/audio_tip_operate.mp3")
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == NetMsgId.SUB_S_OPERATE_RESULT then
        local uiPanel_siShou = ccui.Helper:seekWidgetByName(self.root,"Panel_siShou")   --报听
        if GameCommon.bAction == true and GameCommon.wBaoTingUser ~= 65535 then 
            GameCommon.wBaoTingUser = 65535 
            GameCommon.bAction = false
            uiPanel_siShou:setVisible(false)
            self:showHandCard(GameCommon:getRoleChairID(),0)
        end
        GameCommon.waitOutCardUser = pBuffer.wOperateUser
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:removeAllChildren()
        local wChairID = pBuffer.wOperateUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local cbOperateCode = pBuffer.cbOperateCard
        local WeaveItemArray = {}
        WeaveItemArray.cbWeaveKind = pBuffer.cbOperateCode
        WeaveItemArray.cbCenterCard = pBuffer.cbOperateCard
        WeaveItemArray.cbPublicCard = pBuffer.cbPublicCard
        WeaveItemArray.wProvideUser = pBuffer.wProvideUser
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiPanel_userTips = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_userTips%d",viewID))
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:removeFromParent()
        end
        if GameCommon.tableConfig.wKindID == 50 then
            for i = 1, 2 do
                local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName(string.format("SendOrOutCardNode%d",i))
                if uiSendOrOutCardNode ~= nil then
                    if uiSendOrOutCardNode.cbCardData == pBuffer.cbOperateCard then
                        uiSendOrOutCardNode:removeFromParent()
                    else
                        uiSendOrOutCardNode:runAction(cc.Sequence:create(
                            cc.RemoveSelf:create(),
                            cc.CallFunc:create(function(sender,event) 
                                self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                            end)))
                    end
                end
            end
        end
        if Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 then
            GameCommon:playAnimation(self.root, "杠",wChairID)
            GameCommon.waitOutCardUser = nil
        elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_FILL) ~= 0 then
            GameCommon:playAnimation(self.root, "补",wChairID)
            GameCommon.waitOutCardUser = nil
        elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_PENG) ~= 0 then
            GameCommon:playAnimation(self.root, "碰",wChairID)
        elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 or Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 or Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
            GameCommon:playAnimation(self.root, "吃",wChairID)
        else
        
        end
        self:addWeaveItemArray(wChairID, WeaveItemArray)
        self:showCountDown(wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
	
    elseif action == NetMsgId.SUB_S_GAME_END_MAJIANG then
        if pBuffer.wProvideUser >= GameCommon.gameConfig.bPlayerCount then
            GameCommon:playAnimation(self.root, "黄庄")
        else
            for i = 1, GameCommon.gameConfig.bPlayerCount do
                local wChairID = i - 1
                if pBuffer.wWinner[i] == true then
                    if wChairID == pBuffer.wProvideUser then
                        GameCommon:playAnimation(self.root, "自摸",wChairID)
                    else
                        GameCommon:playAnimation(self.root, "胡",wChairID)
                    end
                end
            end
        end

        local uiAtlasLabel_countdownTime = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_countdownTime")
        if uiAtlasLabel_countdownTime then
            uiAtlasLabel_countdownTime:stopAllActions()
        end
    
    elseif action == NetMsgId.SUB_S_SpecialCard then
        local oprationLayer = GameSpecial:create(pBuffer)
        local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
        uiPanel_operation:addChild(oprationLayer)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        
    elseif action == NetMsgId.SUB_S_SpecialCard_RESULT then        
        local wChairID = pBuffer.wActionUser
        local viewID = GameCommon:getViewIDByChairID(wChairID) 
        if pBuffer.wActionUser ~= GameCommon:getRoleChairID() then
            local cbCardCount = GameCommon.player[wChairID].cbCardCount
            local cbCardData = GameCommon.player[wChairID].cbCardData
            if pBuffer.wActionUser == GameCommon.wBankerUser then
                self:setHandCard(pBuffer.wActionUser,14, pBuffer.cbCardData)
            else
                self:setHandCard(pBuffer.wActionUser,13, pBuffer.cbCardData)
            end
            self:showHandCard(pBuffer.wActionUser,0)
            
            self:setHandCard(pBuffer.wActionUser,cbCardCount, cbCardData)
            local uiPanel_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_handCard%d",viewID))
            uiPanel_handCard:stopAllActions()
            uiPanel_handCard:runAction(cc.Sequence:create(
                cc.DelayTime:create(5),
                cc.CallFunc:create(function(sender,event) 
                    self:showHandCard(pBuffer.wActionUser,0)
                end)
            ))  
        end
        local time = 0.5
        local wSiceCount = pBuffer.wSiceCount
        if wSiceCount >= 2 then
            time = 3
            local visibleSize = cc.Director:getInstance():getVisibleSize()
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/yaoshaizi/yaoshaizi.ExportJson")
            local armature = ccs.Armature:create("yaoshaizi")
            armature:getAnimation():playWithIndex(0,-1,-1)
            armature:setPosition(visibleSize.width*0.5,visibleSize.height*0.5)
            self:addChild(armature)
            require("common.Common"):playEffect("majiang/sound/mandarin/yaoshuiazi.mp3")
            armature:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                local tableSiceCount = {}
                if wSiceCount >= 2 then
                    if wSiceCount <= 7 then
                        tableSiceCount[1] = math.random(1,wSiceCount-1)
                    else
                        tableSiceCount[1] = math.random(wSiceCount-6,6)
                    end
                    tableSiceCount[2] = wSiceCount - tableSiceCount[1]
                end
                for key, var in pairs(tableSiceCount) do
                    local img = ccui.ImageView:create(string.format("game/shuaiz_%d.png",var))
                    armature:addChild(img,1000)
                    img:setPosition(-55 + (key-1)*110,0)
                end
                local wChairID = pBuffer.wTargetUser
                local viewID = GameCommon:getViewIDByChairID(wChairID)
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/niaodonghua/niaodonghua.ExportJson")
                local armature1 = ccs.Armature:create("niaodonghua")
                armature1:getAnimation():playWithIndex(0,-1,-1)
                armature:addChild(armature1)
                armature1:setPosition(cc.p(armature1:getParent():convertToNodeSpace(cc.p(visibleSize.width*0.5,visibleSize.height*0.5))))
                local uiPanel_player = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
                armature1:runAction(
                cc.MoveTo:create(1,cc.p(armature1:getParent():convertToNodeSpace(cc.p(uiPanel_player:convertToWorldSpace(cc.p(uiPanel_player:getContentSize().width/2,uiPanel_player:getContentSize().height/2)))))))
            end),
            cc.DelayTime:create(1),
            cc.CallFunc:create(function(sender,event) 
                for i = 1, GameCommon.gameConfig.bPlayerCount do
                    local wChairID = i-1
                    local viewID = GameCommon:getViewIDByChairID(wChairID)
                    local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
                    local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID)) 
                    local uiTextAtlasScore = nil
                    if pBuffer.lGameScore[i] > 0 then
                        uiTextAtlasScore = ccui.TextAtlas:create(string.format(":%d",pBuffer.lGameScore[i]),"fonts/fonts_6.png",26,43,'0')
                    else
                        uiTextAtlasScore = ccui.TextAtlas:create(string.format(":%d",pBuffer.lGameScore[i]),"fonts/fonts_7.png",26,43,'0')
                    end
                    uiPanel_tipsCard:addChild(uiTextAtlasScore)
                    uiTextAtlasScore:setPosition(uiPanel_tipsCardPos:getPosition())  
                    uiTextAtlasScore:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.5),
                        cc.ScaleTo:create(0.5,1.2),
                        cc.ScaleTo:create(0.5,1.0),
                        cc.RemoveSelf:create())) 
                end
            end),
            cc.RemoveSelf:create()))
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
        if Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_SIXI_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "大四喜",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_BANBAN_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "无将胡",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_LIULIU_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "六六顺",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_QUEYISE_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "缺一色",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_BUBUGAO_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "步步高",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_SANTONG_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "三同",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_YIZHIHUA_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "一枝花",wChairID)
        elseif Bit:_and(pBuffer.cbUserAction,GameCommon.CHK_ZTSX_HU) ~= 0 then
            GameCommon:playAnimation(self.root, "中途四喜",wChairID)
        else

        end
        
    elseif action == NetMsgId.SUB_S_CASTDICE_RESULT then
        local wChairID = pBuffer.wCurrentUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                end)))
        end
        local tableCard = {}
        if pBuffer.wDiceCardOne ~= 0 then
            table.insert(tableCard,#tableCard+1,pBuffer.wDiceCardOne)
        end
        if pBuffer.wDiceCardTwo ~= 0 then
            table.insert(tableCard,#tableCard+1,pBuffer.wDiceCardTwo)
        end
        for key, var in pairs(tableCard) do
            uiSendOrOutCardNode = GameCommon:getDiscardCardAndWeaveItemArray(var,viewID)
            uiSendOrOutCardNode:setName(string.format("SendOrOutCardNode%d",key))
            uiSendOrOutCardNode.cbCardData = var
            uiSendOrOutCardNode.wChairID = wChairID
            uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
            uiSendOrOutCardNode:setPosition(uiPanel_tipsCardPos:getPosition())
            uiSendOrOutCardNode:setScale(0)
            uiSendOrOutCardNode:runAction(cc.ScaleTo:create(0.2,1))
            self:updateLeftCardCount(GameCommon.cbLeftCardCount-1)
            if #tableCard > 1 then
                if viewID == 1 then
                    if key == 1 then
                        uiSendOrOutCardNode:setPositionX(uiSendOrOutCardNode:getPositionX()-65)
                    else
                        uiSendOrOutCardNode:setPositionX(uiSendOrOutCardNode:getPositionX()+65)
                    end
                    
                elseif viewID == 2 then
                    if key == 1 then
                        uiSendOrOutCardNode:setPositionY(uiSendOrOutCardNode:getPositionY()-65)
                    else
                        uiSendOrOutCardNode:setPositionY(uiSendOrOutCardNode:getPositionY()+65)
                    end
                    
                elseif viewID == 3 then
                    if key == 1 then
                        uiSendOrOutCardNode:setPositionX(uiSendOrOutCardNode:getPositionX()+65)
                    else
                        uiSendOrOutCardNode:setPositionX(uiSendOrOutCardNode:getPositionX()-65)
                    end
                    
                elseif viewID == 4 then
                    if key == 1 then
                        uiSendOrOutCardNode:setPositionY(uiSendOrOutCardNode:getPositionY()+65)
                    else
                        uiSendOrOutCardNode:setPositionY(uiSendOrOutCardNode:getPositionY()-65)
                    end
                   
                end
            end
        end
        self:showCountDown(wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
	
    elseif action == NetMsgId.SUB_S_OPERATE_HAIDI then
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        if GameCommon.tableConfig.wKindID == 50 then
            for i = 1, 2 do
                local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName(string.format("SendOrOutCardNode%d",i))
                if uiSendOrOutCardNode ~= nil then
                    uiSendOrOutCardNode:runAction(cc.Sequence:create(
                        cc.RemoveSelf:create(),
                        cc.CallFunc:create(function(sender,event) 
                            self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                        end)))
                end
            end
        end
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                end)))
        end
	   if pBuffer.wCurrentUser == GameCommon:getRoleChairID() then
            local oprationLayer = GameOpration:create(pBuffer,1)
            local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
            uiPanel_operation:addChild(oprationLayer)
            Common:playEffect("game/audio_tip_operate.mp3")
       end
       self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))
    elseif action == NetMsgId.SUB_S_OPERATE_XIAPAO then    -- 下跑
    elseif action == NetMsgId.SUB_S_SEND_HAIDICARD then
        GameCommon.waitOutCardUser = nil
        local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
        uiPanel_outCardTips:removeAllChildren()
        local wChairID = pBuffer.wCurrentUser
        local viewID = GameCommon:getViewIDByChairID(wChairID)
        local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
        local uiPanel_tipsCard = ccui.Helper:seekWidgetByName(self.root,"Panel_tipsCard")
        local uiSendOrOutCardNode = uiPanel_tipsCard:getChildByName("SendOrOutCardNode")
        if uiSendOrOutCardNode ~= nil then
            uiSendOrOutCardNode:runAction(cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function(sender,event) 
                    self:addDiscardCard(sender.wChairID, sender.cbCardData) 
                end)))
        end
        uiSendOrOutCardNode = GameCommon:getDiscardCardAndWeaveItemArray(pBuffer.cbCardData,viewID)
        uiSendOrOutCardNode:setName("SendOrOutCardNode")
        uiSendOrOutCardNode.cbCardData = pBuffer.cbCardData
        uiSendOrOutCardNode.wChairID = wChairID
        uiPanel_tipsCard:addChild(uiSendOrOutCardNode)
        uiSendOrOutCardNode:setPosition(uiPanel_tipsCardPos:getPosition())
        uiSendOrOutCardNode:setScale(0)
        uiSendOrOutCardNode:runAction(cc.ScaleTo:create(0.2,1))
        GameCommon:playAnimation(self.root, pBuffer.cbOutCardData,wChairID)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK) end)))

    else
	
	end
	
end

function TableLayer:showCountDown(wChairID)
    for i = 0 ,3 do 
    local n = GameCommon:getViewIDByChairID(i) 
    print("接受2222消息",wChairID,i,n)
    end 
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiImage_direction = ccui.Helper:seekWidgetByName(self.root,"Image_direction")
    local uiAtlasLabel_countdownTime = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_countdownTime")
    local uiText_stack = ccui.Helper:seekWidgetByName(self.root,"Text_stack")
    print("接受4444消息",wChairID,viewID)
    local seat = 0
    local num = GameCommon:getViewIDByChairID(seat) 
    if GameCommon.gameConfig.bPlayerCount == 4 then
        if seat == 0 and num == 1 then
            uiImage_direction:setRotation(90)
            uiAtlasLabel_countdownTime:setRotation(270)
            uiText_stack:setRotation(270)
        elseif seat == 0 and num == 2 then
            uiImage_direction:setRotation(180)
            uiAtlasLabel_countdownTime:setRotation(180)
            uiText_stack:setRotation(180)
        elseif seat == 0 and num == 3 then
            uiImage_direction:setRotation(270)
            uiAtlasLabel_countdownTime:setRotation(90)
            uiText_stack:setRotation(90)
        elseif seat == 0 and num == 4 then
            uiImage_direction:setRotation(0)
            uiAtlasLabel_countdownTime:setRotation(0)
            uiText_stack:setRotation(0)
        end 
    elseif GameCommon.gameConfig.bPlayerCount == 3 then     
        if seat == 0 and num == 1 then
            uiImage_direction:setRotation(90)
            uiAtlasLabel_countdownTime:setRotation(270)
            uiText_stack:setRotation(270)
        elseif seat == 0 and num == 2 then
            uiImage_direction:setRotation(180)
            uiAtlasLabel_countdownTime:setRotation(180)
            uiText_stack:setRotation(180)
        elseif seat == 0 and num == 3 then
            uiImage_direction:setRotation(270)
            uiAtlasLabel_countdownTime:setRotation(90)
            uiText_stack:setRotation(90)
        elseif seat == 0 and num == 4 then
            uiImage_direction:setRotation(0)
            uiAtlasLabel_countdownTime:setRotation(0)
            uiText_stack:setRotation(0)
        end 
    elseif GameCommon.gameConfig.bPlayerCount == 2 then    
        if seat == 0 and num == 1 then
            uiImage_direction:setRotation(90)
            uiAtlasLabel_countdownTime:setRotation(270)
            uiText_stack:setRotation(270)
        elseif seat == 0 and num == 3 then
            uiImage_direction:setRotation(270)
            uiAtlasLabel_countdownTime:setRotation(90)
            uiText_stack:setRotation(90)
        end
    end 
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

        --自己出牌最后5秒倒计时音效
        if viewID == 1 and currentTime <= 5 then
            Common:playEffect('game/timeup_alarm.mp3')
        end
    end

    uiAtlasLabel_countdownTime:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventTime))))    
    local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
    uiPanel_outCardTips:removeAllChildren()
    local uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",1))
    if GameCommon.gameConfig.bPlayerCount == 4 then
        for i = 0 ,3 do
            uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",i))
            uiImage_dir:stopAllActions()
            uiImage_dir:setVisible(false)
        end
        uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",wChairID))          
    elseif GameCommon.gameConfig.bPlayerCount == 3 then    
        for i = 0 ,3 do
            uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",i))
            uiImage_dir:setVisible(false)
            uiImage_dir:stopAllActions()        
        end       
        if seat == 0 and num == 1 then
            if wChairID == 0 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",0))
            elseif wChairID == 1 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",1))          
            elseif wChairID == 2 then  
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",2))          
            end 
        elseif seat == 0 and num == 2 then
            if wChairID == 0 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",0))
            elseif wChairID == 1 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",1))          
            elseif wChairID == 2 then  
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",3))          
            end
        elseif seat == 0 and num == 3 then
            if wChairID == 0 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",0))
            elseif wChairID == 1 then 
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",2))          
            elseif wChairID == 2 then  
                uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",3))          
            end
        end
    elseif GameCommon.gameConfig.bPlayerCount == 2 then   
        for i = 0 ,3 do
            uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",i))
            uiImage_dir:setVisible(false)
            uiImage_dir:stopAllActions()        
        end
  
        if wChairID == 0 then 
            uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",0))        
        else
            uiImage_dir = ccui.Helper:seekWidgetByName(self.root,string.format("Image_%d",2))          
        end
    end
    uiImage_dir:runAction(cc.RepeatForever:create(cc.Blink:create(1,1)))
end

--更新牌堆
function TableLayer:updateLeftCardCount(cbLeftCardCount)
    GameCommon.cbLeftCardCount = cbLeftCardCount
    local uiText_stack = ccui.Helper:seekWidgetByName(self.root,"Text_stack")
    uiText_stack:setString(string.format("剩余%d",GameCommon.cbLeftCardCount))
    uiText_stack:setVisible(true)
end

-------------------------------------------------------吃牌组合-----------------------------------------------------

--添加吃牌组合
function TableLayer:addWeaveItemArray(wChairID,WeaveItemArray)
    local cbCardList = self:getWeaveItemArray(WeaveItemArray)
    local isFound = false
    local pos = GameCommon.player[wChairID].bWeaveItemCount + 1
    if Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 then
        if WeaveItemArray.cbPublicCard == 0 then
            --先碰后来再杠的
            self:removeHandCard(wChairID,cbCardList[1])
            for i = 1, GameCommon.player[wChairID].bWeaveItemCount do
                local var = GameCommon.player[wChairID].WeaveItemArray[i]
                if var.cbCenterCard == WeaveItemArray.cbCenterCard then
                    GameCommon.player[wChairID].WeaveItemArray[i] = WeaveItemArray
                    isFound = true
                    pos = i
                    break
                end
            end
        elseif WeaveItemArray.cbPublicCard == 1 then
            --别人打的杠
            for key, var in pairs(cbCardList) do
                if key ~= 4 then
                    self:removeHandCard(wChairID,var)
                end
            end
        elseif WeaveItemArray.cbPublicCard == 2 then
            --暗杠
            for key, var in pairs(cbCardList) do
                self:removeHandCard(wChairID,var)
            end
        else
            
        end
                
    elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_FILL) ~= 0 then
        if WeaveItemArray.cbPublicCard == 0 then
            --先碰后来再杠的
            self:removeHandCard(wChairID,cbCardList[1])
            for i = 1, GameCommon.player[wChairID].bWeaveItemCount do
                local var = GameCommon.player[wChairID].WeaveItemArray[i]
                if var.cbCenterCard == WeaveItemArray.cbCenterCard then
                    GameCommon.player[wChairID].WeaveItemArray[i] = WeaveItemArray
                    isFound = true
                    pos = i
                    break
                end
            end
        elseif WeaveItemArray.cbPublicCard == 1 then
            --别人打的杠
            for key, var in pairs(cbCardList) do
                if key ~= 4 then
                    self:removeHandCard(wChairID,var)
                end
            end
        elseif WeaveItemArray.cbPublicCard == 2 then
            --暗杠
            for key, var in pairs(cbCardList) do
                self:removeHandCard(wChairID,var)
            end
        else

        end
         
    elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
        for key, var in pairs(cbCardList) do
            if key ~= 1 then
                self:removeHandCard(wChairID,var)
            end
        end
        
    elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
        for key, var in pairs(cbCardList) do
            if key ~= 2 then
                self:removeHandCard(wChairID,var)
            end
        end
        
    elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
        for key, var in pairs(cbCardList) do
            if key ~= 3 then
                self:removeHandCard(wChairID,var)
            end
        end
        
    elseif Bit:_and(WeaveItemArray.cbWeaveKind,GameCommon.WIK_PENG) ~= 0 then
        for key, var in pairs(cbCardList) do
            if key ~= 3 then
                self:removeHandCard(wChairID,var)
            end
        end
        
    else
     
    end
    self:showHandCard(wChairID,2)
    if isFound == false then
        GameCommon.player[wChairID].bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount + 1
        GameCommon.player[wChairID].WeaveItemArray[GameCommon.player[wChairID].bWeaveItemCount] = WeaveItemArray
    end
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local node = self:setWeaveItemArray(wChairID, GameCommon.player[wChairID].bWeaveItemCount, GameCommon.player[wChairID].WeaveItemArray,pos)
    local srcPos = cc.p(node:getPosition())
    local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
    node:setPosition(cc.p(node:getParent():convertToNodeSpace(cc.p(uiPanel_tipsCardPos:getPosition()))))
    node:runAction(cc.MoveTo:create(0.2,srcPos))
end

function TableLayer:getWeaveItemArray(var)
    local cbCardList = {}
    if Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_PENG) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard+1,var.cbCenterCard+2}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
        cbCardList = {var.cbCenterCard-1,var.cbCenterCard,var.cbCenterCard+1}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
        cbCardList = {var.cbCenterCard-2,var.cbCenterCard-1,var.cbCenterCard}
    else
        assert(false,"吃牌类型错误")
    end
    return cbCardList
end

--更新吃牌组合
function TableLayer:setWeaveItemArray(wChairID, bWeaveItemCount, WeaveItemArray,pos)
    GameCommon.player[wChairID].bWeaveItemCount = bWeaveItemCount
    GameCommon.player[wChairID].WeaveItemArray = WeaveItemArray
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_weaveItemArray = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_weaveItemArray%d",viewID))
    uiPanel_weaveItemArray:removeAllChildren()
    local size = uiPanel_weaveItemArray:getContentSize()
    local bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount
    local WeaveItemArray = GameCommon.player[wChairID].WeaveItemArray
    local node = nil
    if viewID == 1 then
        local cardScale = 1
        local cardWidth = 55 * cardScale
        local cardHeight = 85 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth*3
        local stepY = 0
        for key = 1, bWeaveItemCount do
            local var = GameCommon.player[wChairID].WeaveItemArray[key]
            local content = ccui.Layout:create()
            if key == pos then
                node = content
            end
            GameCommon.player[wChairID].WeaveItemArray[key].node = content
            uiPanel_weaveItemArray:addChild(content)
            content:setContentSize(cc.size(cardWidth*3,size.height))
            content:setPosition(stepX*(key-1),0)
            local cbCardList = self:getWeaveItemArray(var)
            for k, v in pairs(cbCardList) do
                local card = nil
                if k < 4 and var.cbPublicCard == 2 and (Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 or Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0) then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0,viewID)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(v,viewID)
                    if k == 1 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 2 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 3 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    else
                    end
                end
                content:addChild(card)
                if k == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(2-1)*cardWidth,size.height/2+20)
                else
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(k-1)*cardWidth,size.height/2)
                end
            end
        end
        
    elseif viewID == 2 then
        local cardScale = 1
        local cardWidth = 54 * cardScale
        local cardHeight = 53 * cardScale
        local beganX = 0
        local beganY = size.height-(cardHeight-20)*3
        local stepX = 0
        local stepY = -((cardHeight-20)*3)
        for key = 1, bWeaveItemCount do
            local var = GameCommon.player[wChairID].WeaveItemArray[key]
            local content = ccui.Layout:create()
            if key == pos then
                node = content
            end
            GameCommon.player[wChairID].WeaveItemArray[key].node = content
            uiPanel_weaveItemArray:addChild(content)
            content:setContentSize(cc.size(size.width,(cardHeight-20)*3))
            content:setPosition(beganX,beganY + stepY*(key-1))
            local cbCardList = self:getWeaveItemArray(var)
            for k, v in pairs(cbCardList) do
                local card = nil
                if k < 4 and var.cbPublicCard == 2 and (Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 or Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0) then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0,viewID)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(v,viewID)
                    if k == 1 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 2 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 3 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    else
                    end
                end
                content:addChild(card)
                if k == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(size.width/2,cardHeight/2+(2-1)*(cardHeight-20))
                    card:setLocalZOrder(4)    
                else
                    card:setScale(cardScale) 
                    card:setPosition(size.width/2,cardHeight/2-20+(k-1)*(cardHeight-20))
                    card:setLocalZOrder(3-k)    
                end  
            end
        end
    elseif viewID == 3 then
        local cardScale = 1
        local cardWidth = 55 * cardScale
        local cardHeight = 85 * cardScale
        local beganX = size.width-cardWidth*3
        local beganY = 0
        local stepX = 0
        local stepY = -(cardWidth)*3
        for key = 1, bWeaveItemCount do
            local var = GameCommon.player[wChairID].WeaveItemArray[key]
            local content = ccui.Layout:create()
            if key == pos then
                node = content
            end
            GameCommon.player[wChairID].WeaveItemArray[key].node = content
            uiPanel_weaveItemArray:addChild(content)
            content:setContentSize(cc.size(cardWidth*3,size.height))
            content:setPosition(beganX + stepY*(key-1),beganY)
            local cbCardList = self:getWeaveItemArray(var)
            for k, v in pairs(cbCardList) do
                local card = nil
                if k < 4 and var.cbPublicCard == 2 and (Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 or Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0) then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0,viewID)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(v,viewID)
                    if k == 1 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 2 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 3 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    else
                    end
                end
                content:addChild(card)
                if k == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(2-1)*cardWidth,size.height/2+12)
                    card:setLocalZOrder(4)  
                else
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(k-1)*cardWidth,size.height/2)
                    card:setLocalZOrder(3-k)      
                end
            end
        end
    elseif viewID == 4 then
        local cardScale = 1
        local cardWidth = 54 * cardScale
        local cardHeight = 53 * cardScale
        local beganX = 0
        local beganY = 0
        local stepX = 0
        local stepY = (cardHeight-20)*3
        for key = 1, bWeaveItemCount do
            local var = GameCommon.player[wChairID].WeaveItemArray[key]
            local content = ccui.Layout:create()
            if key == pos then
                node = content
            end
            GameCommon.player[wChairID].WeaveItemArray[key].node = content
            uiPanel_weaveItemArray:addChild(content)
            content:setContentSize(cc.size(size.width,(cardHeight-20)*3))
            content:setPosition(beganX,beganY + stepY*(key-1))
            content:setLocalZOrder(bWeaveItemCount-key)  
            local cbCardList = self:getWeaveItemArray(var)
            for k, v in pairs(cbCardList) do
                local card = nil
                if k < 4 and var.cbPublicCard == 2 and (Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 or Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0) then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0,viewID)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(v,viewID)
                    if k == 1 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 2 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    elseif k == 3 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                        card:setColor(cc.c3b(170,170,170))
                    else
                    end
                end
                content:addChild(card)
                if k == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(size.width/2,cardHeight/2+(2-1)*(cardHeight))
                    card:setLocalZOrder(4)  
                else
                    card:setScale(cardScale) 
                    card:setPosition(size.width/2,cardHeight/2+(k-1)*(cardHeight-20))
                    card:setLocalZOrder(3-k)   
                end 
            end
        end
    end
    return node
end

-------------------------------------------------------弃牌-----------------------------------------------------

--添加弃牌
function TableLayer:addDiscardCard(wChairID, cbDiscardCard)
    GameCommon.player[wChairID].cbDiscardCount = GameCommon.player[wChairID].cbDiscardCount + 1 
    GameCommon.player[wChairID].cbDiscardCard[GameCommon.player[wChairID].cbDiscardCount] = cbDiscardCard
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local node = self:setDiscardCard(wChairID, GameCommon.player[wChairID].cbDiscardCount, GameCommon.player[wChairID].cbDiscardCard)
    local pos = cc.p(node:getPosition())
    local uiPanel_tipsCardPos = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_tipsCardPos%d",viewID))
    node:setPosition(cc.p(node:getParent():convertToNodeSpace(cc.p(uiPanel_tipsCardPos:getPosition()))))
    node:stopAllActions()
    node:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,pos), cc.CallFunc:create(function(sender,event) 
        --最后一个出的牌上添加箭标
        self:addLastCardFlagEft(node)
    end)))
end

--添加多个弃牌
function TableLayer:setDiscardCard(wChairID, cbDiscardCount, bDiscardCard)
    GameCommon.player[wChairID].cbDiscardCount = cbDiscardCount
    GameCommon.player[wChairID].cbDiscardCard = bDiscardCard
    
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_discardCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_discardCard%d",viewID))
    uiPanel_discardCard:removeAllChildren()
    local anchorPoint = uiPanel_discardCard:getAnchorPoint()
    local size = uiPanel_discardCard:getContentSize()
    local cbDiscardCount = GameCommon.player[wChairID].cbDiscardCount
    local bDiscardCard = GameCommon.player[wChairID].cbDiscardCard
    local maxRow = 10
    local lastNode = nil
    if viewID == 1 then
        local cardScale = 0.8
        local cardWidth = 55 * cardScale
        local cardHeight = 79 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth
        local stepY = cardHeight-12
        for i = 1, cbDiscardCount do
            local row = math.floor((i-1)/maxRow)
            local line = (i-1)%maxRow
            local card = GameCommon:getDiscardCardAndWeaveItemArray(bDiscardCard[i],viewID)
            lastNode = card
            uiPanel_discardCard:addChild(card)
            card:setScale(cardScale)
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)
            card:setLocalZOrder(cbDiscardCount-i)      
        end
        
    elseif viewID == 2 then
        local cardScale = 1
        local cardWidth = 54 * cardScale
        local cardHeight = 52 * cardScale
        local beganX = cardWidth/2
        local beganY = size.height-cardHeight/2
        local stepX = cardWidth
        local stepY = -(cardHeight-19)
        for i = 1, cbDiscardCount do
            local row = (i-1)%maxRow
            local line = math.floor((i-1)/maxRow)
            local card = GameCommon:getDiscardCardAndWeaveItemArray(bDiscardCard[i],viewID)
            lastNode = card
            card:setScale(cardScale)
            uiPanel_discardCard:addChild(card)
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)   
        end
        
    elseif viewID == 3 then
        local cardScale = 0.8
        local cardWidth = 55 * cardScale
        local cardHeight = 79 * cardScale
        local beganX = size.width - cardWidth/2
        local beganY = size.height - cardHeight/2
        local stepX = -cardWidth
        local stepY = -cardHeight+12
        for i = 1, cbDiscardCount do
            local row = math.floor((i-1)/maxRow)
            local line = (i-1)%maxRow
            local card = GameCommon:getDiscardCardAndWeaveItemArray(bDiscardCard[i],viewID)
            lastNode = card
            card:setScale(cardScale)
            uiPanel_discardCard:addChild(card)
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)
        end
        
    elseif viewID == 4 then
        local cardScale = 1
        local cardWidth = 54 * cardScale
        local cardHeight = 52 * cardScale
        local beganX = size.width - cardWidth/2
        local beganY = cardHeight/2
        local stepX = -cardWidth
        local stepY = cardHeight-19
        for i = 1, cbDiscardCount do
            local row = (i-1)%maxRow
            local line = math.floor((i-1)/maxRow)
            local card = GameCommon:getDiscardCardAndWeaveItemArray(bDiscardCard[i],viewID)
            lastNode = card
            card:setScale(cardScale)
            uiPanel_discardCard:addChild(card)
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)
            card:setLocalZOrder(cbDiscardCount-i)  
        end         
    end
    return lastNode
end  

-------------------------------------------------------手牌-----------------------------------------------------
--设置手牌
function TableLayer:setHandCard(wChairID,cbCardCount,cbCardData)
    if  GameCommon.gameConfig.bDHPlayFlag == 1 and GameCommon.mHunCard ~= nil then
        local isFound = true         
        while isFound do
            isFound = false
            for i = 1, cbCardCount do
                if cbCardData[i] == GameCommon.mHunCard then
                    table.remove(cbCardData,i)
                    table.insert(cbCardData,1,GameCommon.mHunCard)
                    --isFound = true
                end
            end
        end
    end
    
    GameCommon.player[wChairID].cbCardCount = cbCardCount
    GameCommon.player[wChairID].cbCardData = cbCardData
    GameCommon.player[wChairID].cardNode = {}
    for i = 1, GameCommon.player[wChairID].cbCardCount do
        local data = {}
        if GameCommon.player[wChairID].cbCardData[i] == nil then
            GameCommon.player[wChairID].cbCardData[i] = 0
        end
        data.data = GameCommon.player[wChairID].cbCardData[i]
        data.pt = cc.p(0,0)
        data.node = nil
        table.insert(GameCommon.player[wChairID].cardNode,#GameCommon.player[wChairID].cardNode+1,data)
    end
    
--    GameCommon.player[wChairID].cbCardCount = cbCardCount
--    GameCommon.player[wChairID].cbCardData = cbCardData
--    GameCommon.player[wChairID].cardNode = {}
--    for i = 1, GameCommon.player[wChairID].cbCardCount do
--        local data = {}
--        if GameCommon.player[wChairID].cbCardData[i] == nil then
--            GameCommon.player[wChairID].cbCardData[i] = 0
--        end
--        data.data = GameCommon.player[wChairID].cbCardData[i]
--        data.pt = cc.p(0,0)
--        data.node = nil
--        if cbCardData[i]==GameCommon.mHunCard and  GameCommon.gameConfig.bDHPlayFlag == 1 then 
--            table.insert(GameCommon.player[wChairID].cardNode,1,data)
--        else         
--            table.insert(GameCommon.player[wChairID].cardNode,#GameCommon.player[wChairID].cardNode+1,data)
--        end
--    end
end

--添加任意手牌
function TableLayer:addOneHandCard(wChairID, cbCard, pos)
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_handCard%d",viewID))
    --插入手牌中
    if GameCommon.gameConfig.bDHPlayFlag == 1 and cbCard == GameCommon.mHunCard then
        --红中麻将，红中放左边
        table.insert(GameCommon.player[wChairID].cbCardData,1,cbCard)
    else
        local isInsert = false
        for i = 1, GameCommon.player[wChairID].cbCardCount do
        if cbCard < GameCommon.player[wChairID].cbCardData[i] and (GameCommon.gameConfig.bDHPlayFlag ~= 1 or GameCommon.player[wChairID].cbCardData[i] ~=  GameCommon.mHunCard) then --
                table.insert(GameCommon.player[wChairID].cbCardData,i,cbCard)
                isInsert = true
                break
            end
        end
        if isInsert == false then
            GameCommon.player[wChairID].cbCardData[GameCommon.player[wChairID].cbCardCount+1] = cbCard
        end 
    end
    GameCommon.player[wChairID].cbCardCount = GameCommon.player[wChairID].cbCardCount + 1    
    local size = uiPanel_handCard:getContentSize()
    local data = {}
    data.data = cbCard
    data.pt = cc.p(0,0)
    if viewID == 1 then
        local cardScale = 0.9
        local cardWidth = 80 * cardScale
        local cardHeight = 116 * cardScale
        data.pt = cc.p(size.width + cardWidth/2 + 10,size.height/2)
    elseif viewID == 2 then
        local cardScale = 0.6
        local cardWidth = 102* cardScale
        local cardHeight = 93 * cardScale
        data.pt = cc.p(size.width/2,-15)
    elseif viewID == 3 then
        local cardScale = 0.6
        local cardWidth = 81 * cardScale
        local cardHeight = 118 * cardScale
        data.pt = cc.p(-cardWidth/2-10,size.height/2)
    else
        local cardScale = 0.6
        local cardWidth = 102* cardScale
        local cardHeight = 93 * cardScale
        data.pt = cc.p(size.width/2,size.height + 15)
    end
    data.node = nil
    if GameCommon.gameConfig.bDHPlayFlag == 1 and cbCard == GameCommon.mHunCard then
        table.insert(GameCommon.player[wChairID].cardNode,1,data)
    else
        local isInsert = false
        for key, var in pairs(GameCommon.player[wChairID].cardNode) do
            if cbCard < var.data and (GameCommon.gameConfig.bDHPlayFlag ~= 1 or var.data ~=  GameCommon.mHunCard) then --and (GameCommon.tableConfig.wKindID ~= 45 or var.data ~= 0x31) 
                table.insert(GameCommon.player[wChairID].cardNode,key,data) 
                isInsert = true
                break
        	end
        end
        if isInsert == false then
            table.insert(GameCommon.player[wChairID].cardNode,#GameCommon.player[wChairID].cardNode+1,data) 
        end  
    end
end

--删除手牌
function TableLayer:removeHandCard(wChairID, cbCardData)
    local pos = nil
    if wChairID == GameCommon:getRoleChairID() and self.copyHandCard ~= nil then
        self.copyHandCard.targetNode:setColor(cc.c3b(255,255,255))
        self.copyHandCard:removeFromParent()
        self.copyHandCard = nil
    end
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_handCard%d",viewID))
    local items = uiPanel_handCard:getChildren()
    local foundNode = nil
    --优先找出牌的待出牌的节点
    if viewID == 4 then
        if #items >= 1 and items[1].data == cbCardData then
            foundNode = items[1]
        end
    else
        if #items >= 1 and items[#items].data == cbCardData then
            foundNode = items[#items]
        end
    end
    --遍历查找
    if foundNode == nil then
        for key, var in pairs(items) do
        	if var.data == cbCardData then
        	   foundNode = var
        	   break
        	end
        end
    end
    --都没找到删除待出牌的节点
    if foundNode == nil and #items >= 1 then
        if viewID == 4 then
            foundNode = items[1]
        else
            foundNode = items[#items]
        end
    end
    if foundNode ~= nil then
        pos = cc.p(foundNode:getParent():convertToWorldSpace(cc.p(foundNode:getPosition())))
        foundNode:removeFromParent()
    else
        return nil
    end
    local isFound = false
    for i = 1, GameCommon.player[wChairID].cbCardCount do
        if GameCommon.player[wChairID].cbCardData[i] == cbCardData then
            table.remove(GameCommon.player[wChairID].cbCardData,i)
            isFound = true
            break
        end
    end
    if isFound == false then
        GameCommon.player[wChairID].cbCardData[GameCommon.player[wChairID].cbCardCount] = 0
    end
    
    local isFound = false
    if GameCommon.player[wChairID].cardNode[#GameCommon.player[wChairID].cardNode].data == cbCardData then
        table.remove(GameCommon.player[wChairID].cardNode,#GameCommon.player[wChairID].cardNode)
        isFound = true
    end
    if isFound == false then
        for key, var in pairs(GameCommon.player[wChairID].cardNode) do
        	if var.data == cbCardData then
               table.remove(GameCommon.player[wChairID].cardNode,key)
        	   isFound = true
        	   break
        	end
        end
    end
    if isFound == false then
        table.remove(GameCommon.player[wChairID].cardNode,#GameCommon.player[wChairID].cardNode)
    end
    GameCommon.player[wChairID].cbCardCount = GameCommon.player[wChairID].cbCardCount - 1
    return pos
end

--更新手牌
function TableLayer:showHandCard(wChairID,effectsType,isShowEndCard)
    local viewID = GameCommon:getViewIDByChairID(wChairID)
    local uiPanel_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_handCard%d",viewID))
    uiPanel_handCard:stopAllActions()
    uiPanel_handCard:removeAllChildren()
    local items = uiPanel_handCard:getChildren()
    local size = uiPanel_handCard:getContentSize()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local anchorPoint = uiPanel_handCard:getAnchorPoint()
    local index = 0
    local time = 0.1
    if viewID == 1 then
        local cardScale = 1
        local cardWidth = 86 * cardScale
        local cardHeight = 126 * cardScale
        local step = cardWidth
        local uiPanel_copyHandCard = ccui.Helper:seekWidgetByName(self.root,"Panel_copyHandCard")
        uiPanel_copyHandCard:removeAllChildren()
        self.copyHandCard = nil
        local began = (size.width - GameCommon.player[wChairID].cbCardCount * cardWidth) + cardWidth/2
        if GameCommon.waitOutCardUser == wChairID then
            began = began + step
        end
        for i = 1, #GameCommon.player[wChairID].cardNode do
            local card = GameCommon:GetCardHand(GameCommon.player[wChairID].cardNode[i].data,viewID)
            local image = ccui.ImageView:create("game/game_hunpai.png")
            local liang = ccui.ImageView:create("game/game_baotingkuang.png")
            if GameCommon.gameConfig.bDHPlayFlag == 1 and GameCommon.mHunCard ~= nil and  GameCommon.mHunCard == GameCommon.player[wChairID].cardNode[i].data then 
                card:addChild(image)
                image:setPosition(image:getParent():getContentSize().width/2,image:getContentSize().height*0.35)
                image:setScale(0.73,0.7)
            end 
            if GameCommon.wBaoTingUser ~= 65535  and GameCommon.wBaoTingUser == GameCommon:getRoleChairID() and GameCommon.wBaoTingUser < 4 and 
            GameCommon.gameConfig.bBTHu == 1 and GameCommon.mBaoTingCard ~= nil and( GameCommon.bBaoTingUserTF[GameCommon.wBaoTingUser+1] == true 
            or ( GameCommon.bBaoTingUserTF[GameCommon.wBaoTingUser+1] == false and GameCommon.bAction == true ) )then 
                for j = 1 , 34 do 
                    print("发牌：",j,GameCommon.mBaoTingCard[j],GameCommon.player[wChairID].cardNode[i].data) 
                    if GameCommon.mBaoTingCard[j] == GameCommon.player[wChairID].cardNode[i].data then 
                        card:addChild(liang)
                        liang:setPosition(liang:getParent():getContentSize().width/2,liang:getParent():getContentSize().height/2+5)
                    end 
                 end 
            end 
            uiPanel_handCard:addChild(card)
            card:setScale(cardScale)
            card.data = GameCommon.player[wChairID].cardNode[i].data          
            GameCommon.player[wChairID].cardNode[i].node = card
            if effectsType == 0 then--发牌
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    card:setPosition(size.width + cardWidth/2 + 10,size.height/2)
                else
                    card:setPosition(began + step*(i-1),size.height/2)
                end
                GameCommon.player[wChairID].cardNode[i].pt = cc.p(card:getPosition())
                
            elseif effectsType == 1 then--添加
                local pos = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(pos)
                if pos.x > size.width then
                    Common:playGetCardAnim(card)
                end
                
            else--整理
                local original = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(original)
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(size.width + cardWidth/2 + 10,size.height/2)
                else
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(began + step*(i-1),size.height/2)
                end
                if original.x > size.width and i ~= GameCommon.player[wChairID].cbCardCount then
                    card:runAction(cc.Sequence:create(
                    cc.MoveTo:create(0.05,cc.p(original.x,original.y+cardHeight)),
                    cc.MoveTo:create(0.05,cc.p(GameCommon.player[wChairID].cardNode[i].pt.x,original.y+cardHeight)),
                    cc.MoveTo:create(0.05,GameCommon.player[wChairID].cardNode[i].pt)
                    ))
                else
                    card:runAction(cc.MoveTo:create(0.2,GameCommon.player[wChairID].cardNode[i].pt))
                end
            end
            
            local uiImage_line = ccui.Helper:seekWidgetByName(self.root,"Image_line")
            uiImage_line:setVisible(false)
            local lineY = uiImage_line:getPositionY()
            card:setTouchEnabled(true)
            card:addTouchEventListener(function(sender,event) 
                if event == ccui.TouchEventType.began then
                    if self.copyHandCard ~= nil then
                        self.copyHandCard.targetNode:setColor(cc.c3b(255,255,255))
                        self.copyHandCard = nil
                    end
                    uiPanel_copyHandCard:removeAllChildren()
                    self.copyHandCard = nil
                elseif event == ccui.TouchEventType.moved then
                    local pos = cc.pSub(self.locationBeganPos,self.locationPos)
                    if self.copyHandCard == nil and (math.abs(pos.x) > 30 or math.abs(pos.y) > 30) then
                       -- uiImage_line:setVisible(true)
                        self.copyHandCard = card:clone()
                        self.copyHandCard.targetNode = card
                        card:setColor(cc.c3b(170,170,170))
                        uiPanel_copyHandCard:addChild(self.copyHandCard)
                        self.copyHandCard:setPosition(self.locationPos)
                    elseif self.copyHandCard ~= nil then
                        self.copyHandCard:setPosition(self.locationPos)
                    end
                else
                    uiImage_line:setVisible(false)
                    if self.copyHandCard ~= nil then
                        uiPanel_copyHandCard:removeAllChildren()
                        self.copyHandCard = nil
                        card:setColor(cc.c3b(255,255,255))
                        if GameCommon.waitOutCardUser == GameCommon:getRoleChairID() and self.locationPos.y > lineY then
                            self.outData = {wChairID = wChairID, cbCardData = card.data, cardNode = card}
                            EventMgr:dispatch(EventType.EVENT_TYPE_OPERATIONAL_OUT_CARD, self.outData)
                            return
                        end
                    end
                    if self.locationPos.y <= lineY then
                        if GameCommon.waitOutCardUser == GameCommon:getRoleChairID() and card:getPositionY() > card:getParent():getContentSize().height/2 then
                            self.outData = {wChairID = wChairID, cbCardData = card.data, cardNode = card}
                            EventMgr:dispatch(EventType.EVENT_TYPE_OPERATIONAL_OUT_CARD, self.outData)
                            return
                        else
                            local items = uiPanel_handCard:getChildren()
                            for key, var in pairs(items) do
                                var:stopAllActions()
                                var:runAction(cc.MoveTo:create(0.2,GameCommon.player[wChairID].cardNode[key].pt))
                            end
                            card:stopAllActions()
                            card:runAction(cc.MoveTo:create(0.2,cc.p(GameCommon.player[wChairID].cardNode[i].pt.x,card:getParent():getContentSize().height/2+20)))
                        end
                    end
                end
            end)
        end
                
    elseif viewID == 2 then
        local cardScale = 1
        local cardWidth = 54* cardScale
        local cardHeight = 47 * cardScale
        local step = -(cardHeight - 20)
        local began = -(GameCommon.player[wChairID].cbCardCount-1) * step + cardHeight - cardHeight/2
        if GameCommon.waitOutCardUser == wChairID then
            began = began + step
        end
        for i = 1, #GameCommon.player[wChairID].cardNode do
            local card = GameCommon:GetCardHand(GameCommon.player[wChairID].cardNode[i].data,viewID)
            uiPanel_handCard:addChild(card)
            card:setScale(cardScale)
            card.data = GameCommon.player[wChairID].cardNode[i].data
            GameCommon.player[wChairID].cardNode[i].node = card
            if effectsType == 0 then--发牌
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    card:setPosition(size.width/2,-15)
                else
                    card:setPosition(size.width/2,began + step*(i-1))
                end
                GameCommon.player[wChairID].cardNode[i].pt = cc.p(card:getPosition())
            
            elseif effectsType == 1 then--添加
                local pos = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(pos)
                if pos.y < 0 then
                    card:setLocalZOrder(99)
                    Common:playGetCardAnim(card)
                end
                
            else--整理
                local original = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(original)
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(size.width/2,-15)
                else
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(size.width/2,began + step*(i-1))
                end
                if original.y < 0 and i ~= GameCommon.player[wChairID].cbCardCount then
                    card:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.05,cc.p(original.x + cardWidth,original.y)),
                        cc.MoveTo:create(0.05,cc.p(original.x + cardWidth,GameCommon.player[wChairID].cardNode[i].pt.y)),
                        cc.MoveTo:create(0.05,GameCommon.player[wChairID].cardNode[i].pt)
                    ))
                else
                    card:runAction(cc.MoveTo:create(0.2,GameCommon.player[wChairID].cardNode[i].pt))
                end               
            end
        end
    elseif viewID == 3 then
        local cardScale = 1
        local cardWidth = 51 * cardScale
        local cardHeight = 82 * cardScale
        local step = -cardWidth
        local began = -(GameCommon.player[wChairID].cbCardCount-1) * step + cardWidth - cardWidth/2 
        if GameCommon.waitOutCardUser == wChairID then
            began = began + step
        end
        for i = 1, #GameCommon.player[wChairID].cardNode do
            local card = GameCommon:GetCardHand(GameCommon.player[wChairID].cardNode[i].data,viewID)
            uiPanel_handCard:addChild(card)
            card:setScale(cardScale)
            card.data = GameCommon.player[wChairID].cardNode[i].data
            GameCommon.player[wChairID].cardNode[i].node = card
            if effectsType == 0 then--发牌
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    card:setPosition(-cardWidth/2-10,size.height/2)
                else
                    card:setPosition(began + step*(i-1),size.height/2)
                end
                GameCommon.player[wChairID].cardNode[i].pt = cc.p(card:getPosition())
                
            elseif effectsType == 1 then--添加
                local pos = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(pos)
                if pos.x < 0 then
                    Common:playGetCardAnim(card)
                end
                
            else--整理
                local original = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(original)
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(-cardWidth/2-10,size.height/2)
                else
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(began + step*(i-1),size.height/2)
                end
                if original.x < 0 and i ~= GameCommon.player[wChairID].cbCardCount then
                    card:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.05,cc.p(original.x,original.y-cardHeight)),
                        cc.MoveTo:create(0.05,cc.p(GameCommon.player[wChairID].cardNode[i].pt.x,original.y-cardHeight)),
                        cc.MoveTo:create(0.05,GameCommon.player[wChairID].cardNode[i].pt)
                    ))
                else
                    card:runAction(cc.MoveTo:create(0.2,GameCommon.player[wChairID].cardNode[i].pt))
                end
            end
        end
        
    elseif viewID == 4 then
        local cardScale = 1
        local cardWidth = 54* cardScale
        local cardHeight = 47 * cardScale
        local step = cardHeight - 20
        local began = size.height - (GameCommon.player[wChairID].cbCardCount-1) * step - cardHeight + cardHeight/2
        if GameCommon.waitOutCardUser == wChairID then
            began = began + step
        end
        for i = 1, #GameCommon.player[wChairID].cardNode do
            local card = GameCommon:GetCardHand(GameCommon.player[wChairID].cardNode[i].data,viewID)
            uiPanel_handCard:addChild(card)
--            card:setColor(cc.c3b(i*(255/#GameCommon.player[wChairID].cardNode),0,0))
            card:setLocalZOrder(GameCommon.player[wChairID].cbCardCount - i)
            card:setScale(cardScale)
            card.data = GameCommon.player[wChairID].cardNode[i].data
            GameCommon.player[wChairID].cardNode[i].node = card
            if effectsType == 0 then--发牌
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    card:setPosition(size.width/2,size.height + 15)
                else
                    card:setPosition(size.width/2,began + step*(i-1))
                end
                GameCommon.player[wChairID].cardNode[i].pt = cc.p(card:getPosition())
            
            elseif effectsType == 1 then--添加
                local pos = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(pos)
                if pos.y > size.height then
                    card:setLocalZOrder(-1)
                    Common:playGetCardAnim(card)
                end

            else--整理
                local original = GameCommon.player[wChairID].cardNode[i].pt
                card:setPosition(original)
                if i == GameCommon.player[wChairID].cbCardCount and GameCommon.waitOutCardUser == wChairID then
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(size.width/2,size.height + 15)
                else
                    GameCommon.player[wChairID].cardNode[i].pt = cc.p(size.width/2,began + step*(i-1))
                end
                if original.y > size.height and i ~= GameCommon.player[wChairID].cbCardCount then
                    card:runAction(cc.Sequence:create(
                        cc.MoveTo:create(0.05,cc.p(original.x-cardWidth,original.y)),
                        cc.MoveTo:create(0.05,cc.p(original.x-cardWidth,GameCommon.player[wChairID].cardNode[i].pt.y)),
                        cc.MoveTo:create(0.05,GameCommon.player[wChairID].cardNode[i].pt)
                    ))
                else
                    card:runAction(cc.MoveTo:create(0.2,GameCommon.player[wChairID].cardNode[i].pt))
                end
            end
        end
    end
end

function TableLayer:initUI()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    require("common.Common"):playEffect("game/pipeidonghua.mp3")
    --背景层
    local uiImage_watermark = ccui.Helper:seekWidgetByName(self.root,"Image_watermark")
    uiImage_watermark:loadTexture(StaticData.Channels[CHANNEL_ID].icon)
    uiImage_watermark:ignoreContentAdaptWithSize(true)
    local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
    uiText_desc:setString("")
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    uiText_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
        local date = os.date("*t",os.time())
        uiText_time:setString(string.format("%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    end),cc.DelayTime:create(1))))
    local uiImage_direction = ccui.Helper:seekWidgetByName(self.root,"Image_direction")
    uiImage_direction:setVisible(false)
    --卡牌层
    local uiImage_line = ccui.Helper:seekWidgetByName(self.root,"Image_line")
    uiImage_line:setVisible(false)
    local uiPanel_refreshHandCard = ccui.Helper:seekWidgetByName(self.root,"Panel_refreshHandCard")
    uiPanel_refreshHandCard:setTouchEnabled(false)
    uiPanel_refreshHandCard:addTouchEventListener(function(sender,event) 
        if event == ccui.TouchEventType.ended then
            self:showHandCard(GameCommon:getRoleChairID(),2)
        end
    end)
    --动画层
    
    --用户层
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
    --飘分
    local uiPanel_piaoFen = ccui.Helper:seekWidgetByName(self.root,"Panel_piaoFen")
    uiPanel_piaoFen:setVisible(false)
    local uiListView_piaoFen = ccui.Helper:seekWidgetByName(self.root,"ListView_piaoFen")
    local items = uiListView_piaoFen:getItems()
    for key, var in pairs(items) do
        Common:addTouchEventListener(var,function() 
            if key == 1 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",1)
            elseif key == 2 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",2)
            elseif key == 3 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",3)
            elseif key == 4 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",4)
            elseif key == 5 then
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",5)
            else
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_PiaoFen,"b",0)
            end
        end)
    end
    --UI层
    local uiPanel_siShou = ccui.Helper:seekWidgetByName(self.root,"Panel_siShou")   --报听
    uiPanel_siShou:setVisible(false)   
     
    local uiButton_siShou = ccui.Helper:seekWidgetByName(self.root,"Button_siShou")
    Common:addTouchEventListener(uiButton_siShou,function()  
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_BaoTing,"wo",GameCommon:getRoleChairID(),true)
        if (Bit:_and(GameCommon.cbActionMask,GameCommon.WIK_CHI_HU) ~= 0) or (Bit:_and(GameCommon.cbActionMask,GameCommon.WIK_GANG) ~= 0) then
           -- NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_NULL,0)
            GameOpration:removeFromParent()
        end        
    end)   
      
    local uiButton_noSiShou = ccui.Helper:seekWidgetByName(self.root,"Button_noSiShou")
    Common:addTouchEventListener(uiButton_noSiShou,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_BaoTing,"wo",GameCommon:getRoleChairID(),false)
    end) 
    
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
            uiButton_menu:runAction(cc.ScaleTo:create(0.2,1))
        end
    end)  
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_skin"),function() 
        local UserDefault_MaJiangpaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangpaizhuo,0)
        UserDefault_MaJiangpaizhuo = UserDefault_MaJiangpaizhuo + 1
        if UserDefault_MaJiangpaizhuo < 0 or UserDefault_MaJiangpaizhuo > 2 then
            UserDefault_MaJiangpaizhuo = 0
        end
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_MaJiangpaizhuo,UserDefault_MaJiangpaizhuo)
        uiPanel_bg:removeAllChildren()
        uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_MaJiangpaizhuo)))
    end)
    local UserDefault_MaJiangpaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangpaizhuo,0)
    if UserDefault_MaJiangpaizhuo < 0 or UserDefault_MaJiangpaizhuo > 2 then
        UserDefault_MaJiangpaizhuo = 0
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_MaJiangpaizhuo,UserDefault_MaJiangpaizhuo)
    end
    if UserDefault_MaJiangpaizhuo ~= 0 then
        uiPanel_bg:removeAllChildren()
        uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_MaJiangpaizhuo)))
    end
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_font"),function() 
        local UserDefault_MaJiangCard = nil 
        if CHANNEL_ID == 20 or CHANNEL_ID == 21 then 
            UserDefault_MaJiangCard = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangCard,3)
        else
            UserDefault_MaJiangCard = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangCard,0)
        end 
        UserDefault_MaJiangCard = UserDefault_MaJiangCard + 1
        if UserDefault_MaJiangCard < 0 or UserDefault_MaJiangCard > 3 then
            UserDefault_MaJiangCard = 0
        end
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_MaJiangCard,UserDefault_MaJiangCard)

        --牌背字体
        if GameCommon.gameConfig.bPlayerCount ~= nil then 
            for i = 0 , GameCommon.gameConfig.bPlayerCount-1 do
                local wChairID = i
                if GameCommon.player ~= nil and GameCommon.player[wChairID] ~= nil then
                    self:showHandCard(wChairID,i)
                    self:setWeaveItemArray(wChairID, GameCommon.player[wChairID].bWeaveItemCount, GameCommon.player[wChairID].WeaveItemArray)
                    self:setDiscardCard(wChairID, GameCommon.player[wChairID].cbDiscardCount, GameCommon.player[wChairID].cbDiscardCard)
                end
            end
        end 
    end)
    
    local uiPanel_night = ccui.Helper:seekWidgetByName(self.root,"Panel_night")
    local UserDefault_MaJiangliangdu = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangliangdu,0)
    if UserDefault_MaJiangliangdu == 0 then
        uiPanel_night:setVisible(false)
    else
        uiPanel_night:setVisible(true)
    end
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_settings"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("SettingsLayer"))
    end)
    local uiButton_expression = ccui.Helper:seekWidgetByName(self.root,"Button_expression")
    uiButton_expression:setPressedActionEnabled(true)
    local function onEventExpression(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            require("common.GameChatLayer"):create(GameCommon.tableConfig.wKindID,function(index) 
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_GF_USER_EXPRESSION,"ww",index,GameCommon:getRoleChairID())
            end, 
            function(index,contents)
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SEND_CHAT,"dwbnsdns",
                    GameCommon:getRoleChairID(),index,GameCommon:getUserInfo(GameCommon:getRoleChairID()).cbSex,32,"",string.len(contents),string.len(contents),contents)
            end)
        end
    end
    uiButton_expression:addTouchEventListener(onEventExpression)
    local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
    Common:addTouchEventListener(uiButton_ready,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"o",false)
    end) 
    local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")
    Common:addTouchEventListener(uiButton_Invitation,function() 
        local currentPlayerCount = 0
        for key, var in pairs(GameCommon.player) do
            currentPlayerCount = currentPlayerCount + 1
        end
        local player = "("
        for key, var in pairs(GameCommon.player) do
            if key == 0 then
                player = player..var.szNickName
            else
                player = player.."、"..var.szNickName
            end
        end
        player = player..")"
        local data = clone(UserData.Share.tableShareParameter[3])
        data.dwClubID = GameCommon.tableConfig.dwClubID
        data.szShareTitle = string.format(data.szShareTitle,StaticData.Games[GameCommon.tableConfig.wKindID].name,
            GameCommon.tableConfig.wTbaleID,GameCommon.tableConfig.wTableNumber,
            GameCommon.gameConfig.bPlayerCount,GameCommon.gameConfig.bPlayerCount-currentPlayerCount)..player
        data.szShareContent = GameDesc:getGameDesc(GameCommon.tableConfig.wKindID,GameCommon.gameConfig,GameCommon.tableConfig).." (点击加入游戏)"
        data.szShareUrl = string.format(data.szShareUrl,UserData.User.userID, GameCommon.tableConfig.wTbaleID)
        if GameCommon.tableConfig.nTableType == TableType_ClubRoom then
            data.cbTargetType = Bit:_or(data.cbTargetType,0x20)
        end
        require("app.MyApp"):create(data, handler(self, self.pleaseOnlinePlayer)):createView("ShareLayer")
    end)
    local uiButton_disbanded = ccui.Helper:seekWidgetByName(self.root,"Button_disbanded")
    Common:addTouchEventListener(uiButton_disbanded,function() 
        require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
        end)
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
    if GameCommon.tableConfig.wCurrentNumber == 0 and  GameCommon.tableConfig.nTableType > TableType_GoldRoom  then
        if CHANNEL_ID ~= 0 and CHANNEL_ID ~= 1 then
            uiPanel_playerInfoBg:setVisible(true) 
        else 
            uiPanel_playerInfoBg:setVisible(false)
        end
    end
    local uiButton_return = ccui.Helper:seekWidgetByName(self.root,"Button_return")
    Common:addTouchEventListener(uiButton_return,function() 
        require("common.MsgBoxLayer"):create(1,nil,"您确定返回大厅?",function()
            require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
        end)
    end)
    --结算层
    local uiPanel_end = ccui.Helper:seekWidgetByName(self.root,"Panel_end")
    uiPanel_end:setVisible(false)
    --灯光层
    local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
    local uiText_title = ccui.Helper:seekWidgetByName(self.root,"Text_title")    
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        self:addVoice()        
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        if  StaticData.Hide[CHANNEL_ID].btn10 == 0 then 
            uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
            uiPanel_playerInfoBg:setVisible(false)
        end 
        uiButton_cancel:setVisible(false)
        if GameCommon.gameState == GameCommon.GameState_Start  then
            local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
            uiPanel_ready:setVisible(false)

        elseif GameCommon.tableConfig.wCurrentNumber > 0 then
            uiButton_Invitation:setVisible(false)
            uiButton_out:setVisible(false)
        end 
        uiText_title:setString(string.format("%s 房间号:%d 局数:%d/%d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.tableConfig.wTbaleID,GameCommon.tableConfig.wCurrentNumber,GameCommon.tableConfig.wTableNumber))

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/dengdaihaoyou/dengdaihaoyou.ExportJson")
        local waitArmature=ccs.Armature:create("dengdaihaoyou")
        waitArmature:setPosition(-179.2,-158)
        if CHANNEL_ID == 6 or  CHANNEL_ID  == 7 then
            waitArmature:setPosition(0,-158)
        end 
        waitArmature:getAnimation():playWithIndex(0)
        uiButton_Invitation:addChild(waitArmature)   

    elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom then            
        self:addVoice()
        uiPanel_playerInfoBg:setVisible(false)
        uiButton_ready:setVisible(false)
        uiButton_Invitation:setVisible(false)
        uiButton_out:setVisible(false)
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_disbanded)) 
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
        local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
--        uiPanel_ready:setVisible(false)
        uiButton_voice:setVisible(false)
        uiButton_expression:setVisible(false)
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
        self:addVoice()
        uiPanel_playerInfoBg:setVisible(false)
        uiButton_ready:setVisible(false)
        uiButton_Invitation:setVisible(false)
        uiButton_out:setVisible(false)
        local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_disbanded)) 
        if  StaticData.Hide[CHANNEL_ID].btn10 == 0 then 
            uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
        end 
        local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
--        uiPanel_ready:setVisible(false)
        uiButton_voice:setVisible(false)
        uiButton_expression:setVisible(false)
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
end

function TableLayer:drawnout()
    local uiImage_timedown = ccui.Helper:seekWidgetByName(self.root,"Image_timedown")
    uiImage_timedown:setVisible(true)
    local uiText_stack = ccui.Helper:seekWidgetByName(self.root,"Text_stack")
    uiText_stack:setVisible(false)
    
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
          
    local uiPanel_outCardTips = ccui.Helper:seekWidgetByName(self.root,"Panel_outCardTips")
    uiPanel_outCardTips:removeAllChildren()
--    local uiImage_dir = ccui.Helper:seekWidgetByName(self.root,"Image_1")  
--    uiImage_dir:setRotation(0)
--    local uiImage_dir = ccui.Helper:seekWidgetByName(self.root,"Image_dir")
--    uiImage_dir:stopAllActions()
--    uiImage_dir:setVisible(true)
--    uiImage_dir:runAction(cc.RepeatForever:create(cc.Blink:create(1,1)))
end 


function TableLayer:updateGameState(state)
    GameCommon.gameState = state 
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    if state == GameCommon.GameState_Init then
    elseif state == GameCommon.GameState_Start then
		require("common.SceneMgr"):switchOperation()
        local uiPanel_playerInfoBg = ccui.Helper:seekWidgetByName(self.root,"Panel_playerInfoBg")
        uiPanel_playerInfoBg:setVisible(false)
        local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
        uiPanel_ready:setVisible(false)
        if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
            --距离报警  

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
        local uiImage_direction = ccui.Helper:seekWidgetByName(self.root,"Image_direction")
        uiImage_direction:setVisible(true)

        --在准备界面点击报错，修改进入牌桌才激活
        local uiPanel_refreshHandCard = ccui.Helper:seekWidgetByName(self.root,"Panel_refreshHandCard")
        uiPanel_refreshHandCard:setTouchEnabled(true)
    elseif state == GameCommon.GameState_Over then
        UserData.Game:addGameStatistics(GameCommon.tableConfig.wKindID)
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
            uiImage_avatar:loadTexture("common/common_dian2.png")
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
    elseif CHANNEL_ID == 10 or CHANNEL_ID == 11 then
        Chat = require("common.Chat")[0]
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
            filename = "biaoqing-xihuan"
        elseif pBuffer.wIndex == 3 then
            filename = "biaoqing-cool"
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

function TableLayer:sendXiaoHu(cbOperateCode,tableCardData)
    local net = NetMgr:getGameInstance()
    if net.connected == false then
        return
    end
    if #tableCardData <= 0 then
        return
    end
    net.cppFunc:beginSendBuf(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_Xihu)
    net.cppFunc:writeSendBool(true,0)
    net.cppFunc:writeSendWORD(cbOperateCode,0)
    for key, var in pairs(tableCardData) do
        net.cppFunc:writeSendByte(var,0)
    end
    for i = #tableCardData+1, 14 do
        net.cppFunc:writeSendByte(0,0)
    end
    net.cppFunc:endSendBuf()
    net.cppFunc:sendSvrBuf()
end

function TableLayer:EVENT_TYPE_SKIN_CHANGE(event)
    local data = event._usedata
    if data ~= 3 then
        return
    end
    --背景
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")
    local UserDefault_MaJiangpaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangpaizhuo,0)
    if UserDefault_MaJiangpaizhuo < 0 or UserDefault_MaJiangpaizhuo > 2 then
        UserDefault_MaJiangpaizhuo = 0
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_MaJiangpaizhuo,UserDefault_MaJiangpaizhuo)
    end
    uiPanel_bg:removeAllChildren()
    uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_MaJiangpaizhuo)))

    --亮度
    local uiPanel_night = ccui.Helper:seekWidgetByName(self.root,"Panel_night")
    local UserDefault_MaJiangliangdu = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangliangdu,0)
    if UserDefault_MaJiangliangdu == 0 then
        uiPanel_night:setVisible(false)
    else
        uiPanel_night:setVisible(true)
    end
        
    --牌背字体
    for i = 0 , GameCommon.gameConfig.bPlayerCount-1 do
        local wChairID = i
        if GameCommon.player ~= nil and GameCommon.player[wChairID] ~= nil then
            self:showHandCard(wChairID,i)
            self:setWeaveItemArray(wChairID, GameCommon.player[wChairID].bWeaveItemCount, GameCommon.player[wChairID].WeaveItemArray)
            self:setDiscardCard(wChairID, GameCommon.player[wChairID].cbDiscardCount, GameCommon.player[wChairID].cbDiscardCard)
        end
    end
end

---
-- 添加当前最后出牌角标动作
-- @DateTime 2018-05-24
-- @param  node 当前最后出的牌节点
-- @return [description]
--
function TableLayer:addLastCardFlagEft(node)
    self:removeLastCardFlagEft()
    self.flagNode = ccui.ImageView:create('majiang/table/end_outcard_pos.png')
    node:addChild(self.flagNode)
    local size = node:getContentSize()
    local spos = cc.p(size.width / 2, size.height + 20)
    local epos = cc.p(size.width / 2, size.height)
    self.flagNode:setPosition(spos)
    local startMove = cc.MoveTo:create(0.3, epos)
    local reverseMove = cc.MoveTo:create(0.3, spos)
    local sequence = cc.Sequence:create(startMove, reverseMove)
    self.flagNode:runAction(cc.RepeatForever:create(sequence))

    local function onEventEnded(eventType)
        if eventType == "exit" then
            self.flagNode = nil
        end
    end
    self.flagNode:registerScriptHandler(onEventEnded)
end

---
-- 移除当前最后出牌角标动作
-- @DateTime 2018-05-24
-- @param  [description]
-- @return [description]
--
function TableLayer:removeLastCardFlagEft()
    if self.flagNode then
        self.flagNode:removeFromParent()
        self.flagNode = nil
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

--邀请在线好友
function TableLayer:pleaseOnlinePlayer()
    local dwClubID = GameCommon.tableConfig.dwClubID
    require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(dwClubID):createView("PleaseOnlinePlayerLayer"))
end

return TableLayer