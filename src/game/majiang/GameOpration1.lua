local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Common = require("common.Common")
local Bit = require("common.Bit")
local GameLogic = require("game.majiang.GameLogic1")
local GameCommon = require("game.majiang.GameCommon")

local GameOpration = class("GameOpration",function()
    return ccui.Layout:create()
end)

function GameOpration:create(pBuffer,opTtype)
    local view = GameOpration.new()
    view:onCreate(pBuffer,opTtype)
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

function GameOpration:onEnter()
    
end

function GameOpration:onExit()
    if self.uiPanel_opration then
        self.uiPanel_opration:release()
        self.uiPanel_opration = nil
    end
end

function GameOpration:onCreate(pBuffer,opTtype)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayerMaJiang_Operation.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    local uiListView_Opration = ccui.Helper:seekWidgetByName(self.root,"ListView_Opration")
    uiListView_Opration:removeAllItems()
    uiListView_Opration:setVisible(true)
    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    self.uiPanel_opration = uiListView_OprationType:getItem(0)
    self.uiPanel_opration:retain()
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(false)
    if opTtype == 1 then
        self:showHaiDi(pBuffer)
    else
        self:showOpration(pBuffer)
    end
    
    uiListView_Opration:refreshView()
    uiListView_Opration:setPositionX(cc.Director:getInstance():getVisibleSize().width*0.82-uiListView_Opration:getInnerContainerSize().width)
    uiListView_Opration:setDirection(ccui.ScrollViewDir.none)
end

function GameOpration:showOpration(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local uiListView_Opration = ccui.Helper:seekWidgetByName(self.root,"ListView_Opration")
    --吃
    if Bit:_and(cbOperateCode,GameCommon.WIK_LEFT) ~= 0 or Bit:_and(cbOperateCode,GameCommon.WIK_CENTER) ~= 0 or Bit:_and(cbOperateCode,GameCommon.WIK_RIGHT) ~= 0 then
        local img = "game/op_chi.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)        
        Common:addTouchEventListener(item,function() 
            self:dealChi(pBuffer)
        end)
    end
    --碰
    if Bit:_and(cbOperateCode,GameCommon.WIK_PENG) ~= 0 then
        local img = "game/op_peng.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            self:dealPeng(pBuffer)
        end)
    end
    --补
    if Bit:_and(cbOperateCode,GameCommon.WIK_FILL) ~= 0 then
        local img = "game/op_bu.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            self:dealBu(pBuffer)
        end)
    end
    --杠
    if Bit:_and(cbOperateCode,GameCommon.WIK_GANG) ~= 0 then
        local img = "game/op_gang.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            self:dealGang(pBuffer)
        end)
    end
    --胡
    if Bit:_and(cbOperateCode,GameCommon.WIK_CHI_HU) ~= 0 then
        local img = "game/op_hu.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            self:dealHu(pBuffer)
        end)
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xuanzhuanxing/xuanzhuanxing.ExportJson")
        local armature=ccs.Armature:create("xuanzhuanxing")
        armature:getAnimation():playWithIndex(0)
        item:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
    end
    --必胡
    if Bit:_and(cbOperateCode,GameCommon.WIK_BIHU) ~= 0 then
        local img = "game/op_hu.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            self:dealBiHu(pBuffer)
        end)
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xuanzhuanxing/xuanzhuanxing.ExportJson")
        local armature=ccs.Armature:create("xuanzhuanxing")
        armature:getAnimation():playWithIndex(0)
        item:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
    else
        --过
        local img = "game/op_guo.png"
        local item = ccui.Button:create(img,img,img)
        uiListView_Opration:pushBackCustomItem(item)
        Common:addTouchEventListener(item,function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_NULL,0)
            self:removeFromParent()
        end)
    end
    for key, var in pairs(uiListView_Opration:getItems()) do
        var:setScale(0.0)
        var:runAction(cc.Sequence:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.8))))
    end
end

function GameOpration:showHaiDi()
    --海底
    local uiListView_Opration = ccui.Helper:seekWidgetByName(self.root,"ListView_Opration")
    local img = "game/op_yaohaidi.png"
    local item = ccui.Button:create(img,img,img)
    item:setScale(0.8)
    uiListView_Opration:pushBackCustomItem(item)
    Common:addTouchEventListener(item,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_HAIDI,"wo",GameCommon:getRoleChairID(),true)
        self:removeFromParent()
    end)
    --过
    local img = "game/op_guo.png"
    local item = ccui.Button:create(img,img,img)
    item:setScale(0.8)
    uiListView_Opration:pushBackCustomItem(item)
    Common:addTouchEventListener(item,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_HAIDI,"wo",GameCommon:getRoleChairID(),false)
        self:removeFromParent()
    end)
    for key, var in pairs(uiListView_Opration:getItems()) do
        var:setScale(0.0)
        var:runAction(cc.Sequence:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.8))))
    end
end

function GameOpration:dealChi(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard
    
    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    local tableChiCard = {}
    if tableActionCard ~= nil then
        local wChairID = GameCommon:getRoleChairID()
        local cbCardCount = GameCommon.player[wChairID].cbCardCount
        local cbCardData = GameCommon.player[wChairID].cbCardData
        for key, var in pairs(tableActionCard) do
            local cbCardList = {[var-2] = 0,[var-1] = 0,[var+1] = 0,[var+2] = 0}
            for i = 1, cbCardCount do
                if cbCardList[cbCardData[i]] ~= nil then
                    cbCardList[cbCardData[i]] = cbCardList[cbCardData[i]] + 1
                end
            end
            if cbCardList[var+1] > 0 and cbCardList[var+2] > 0 and (tableActionCard[2] == nil or (var+1 ~= tableActionCard[2] and var+2 ~= tableActionCard[2])) then
                table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_LEFT,cbCenterCard = var, cbPublicCard = 0,wProvideUser = wResumeUser})
            end
            if cbCardList[var-1] > 0 and cbCardList[var+1] > 0 and (tableActionCard[2] == nil or (var-1 ~= tableActionCard[2] and var+1 ~= tableActionCard[2])) then
                table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_CENTER,cbCenterCard = var, cbPublicCard = 0,wProvideUser = wResumeUser})
            end
            if cbCardList[var-2] > 0 and cbCardList[var-1] > 0 and (tableActionCard[2] == nil or (var-2 ~= tableActionCard[2] and var-1 ~= tableActionCard[2])) then
                table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_RIGHT,cbCenterCard = var, cbPublicCard = 0,wProvideUser = wResumeUser})
            end
        end
    else
        if Bit:_and(cbOperateCode,GameCommon.WIK_LEFT) ~= 0 then
            table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_LEFT,cbCenterCard = cbOperateCard, cbPublicCard = 0,wProvideUser = wResumeUser})
        end
        if Bit:_and(cbOperateCode,GameCommon.WIK_CENTER) ~= 0 then
            table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_CENTER,cbCenterCard = cbOperateCard, cbPublicCard = 0,wProvideUser = wResumeUser})
        end
        if Bit:_and(cbOperateCode,GameCommon.WIK_RIGHT) ~= 0 then
            table.insert(tableChiCard,#tableChiCard+1,{cbWeaveKind = GameCommon.WIK_RIGHT,cbCenterCard = cbOperateCard, cbPublicCard = 0,wProvideUser = wResumeUser})
        end
    end
    
    if #tableChiCard == 1 then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",tableChiCard[1].cbWeaveKind,tableChiCard[1].cbCenterCard)
        self:removeFromParent()
    else
        local cardScale = 0.6
        local cardWidth = 81 * cardScale
        local cardHeight = 118 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth*3
        local stepY = 0
        for key, var in pairs(tableChiCard) do
            local item = self.uiPanel_opration:clone()
            uiListView_OprationType:pushBackCustomItem(item)
            local cbCardList = {}
            if Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                cbCardList = {var.cbCenterCard,var.cbCenterCard+1,var.cbCenterCard+2}
            elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                cbCardList = {var.cbCenterCard-1,var.cbCenterCard,var.cbCenterCard+1}
            elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                cbCardList = {var.cbCenterCard-2,var.cbCenterCard-1,var.cbCenterCard}
            end
            for k, v in pairs(cbCardList) do
                local card = GameCommon:getDiscardCardAndWeaveItemArray(v)     
                item:addChild(card)
                card:setScale(cardScale) 
                card:setPosition(cardWidth/2+(k-1)*cardWidth+28,card:getParent():getContentSize().height/2)
                item:addTouchEventListener(function(sender,event)
                    if event == ccui.TouchEventType.ended then
                        Common:palyButton()
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",var.cbWeaveKind,var.cbCenterCard)
                        self:removeFromParent()
                    end
                end)
            end
        end
        uiListView_OprationType:refreshView()
        uiListView_OprationType:setPositionX(cc.Director:getInstance():getVisibleSize().width*0.82-uiListView_OprationType:getInnerContainerSize().width)
        uiListView_OprationType:setDirection(ccui.ScrollViewDir.none)
    end
end

function GameOpration:dealPeng(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard

    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    local tablePengCard = {}
    if tableActionCard ~= nil then
        local wChairID = GameCommon:getRoleChairID()
        local cbCardCount = GameCommon.player[wChairID].cbCardCount
        local cbCardData = GameCommon.player[wChairID].cbCardData
        for key, var in pairs(tableActionCard) do
            local count = 0
            for i = 1, cbCardCount do
                if cbCardData[i] == var then
                    count = count + 1
                end
            end
            if count >= 2 and (#tablePengCard <= 0 or tablePengCard[1].cbCenterCard ~= var) then
                table.insert(tablePengCard,#tablePengCard+1,{cbWeaveKind = GameCommon.WIK_PENG,cbCenterCard = var, cbPublicCard = 0,wProvideUser = wResumeUser})
            end
        end
    else
        table.insert(tablePengCard,#tablePengCard+1,{cbWeaveKind = GameCommon.WIK_PENG,cbCenterCard = cbOperateCard, cbPublicCard = 0,wProvideUser = wResumeUser})
    end

    if #tablePengCard == 1 then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",tablePengCard[1].cbWeaveKind,tablePengCard[1].cbCenterCard)
        self:removeFromParent()
    else
        local cardScale = 0.6
        local cardWidth = 81 * cardScale
        local cardHeight = 118 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth*3
        local stepY = 0
        for key, var in pairs(tablePengCard) do
            local item = self.uiPanel_opration:clone()
            uiListView_OprationType:pushBackCustomItem(item)
            local cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
            for k, v in pairs(cbCardList) do
                local card = GameCommon:getDiscardCardAndWeaveItemArray(v)     
                item:addChild(card)
                card:setScale(cardScale) 
                card:setPosition(cardWidth/2+(k-1)*cardWidth+28,card:getParent():getContentSize().height/2)
                item:addTouchEventListener(function(sender,event)
                    if event == ccui.TouchEventType.ended then
                        Common:palyButton()
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",var.cbWeaveKind,var.cbCenterCard)
                        self:removeFromParent()
                    end
                end)
            end
        end
        uiListView_OprationType:refreshView()
        uiListView_OprationType:setPositionX(cc.Director:getInstance():getVisibleSize().width*0.82-uiListView_OprationType:getInnerContainerSize().width)
        uiListView_OprationType:setDirection(ccui.ScrollViewDir.none)
    end
end

function GameOpration:dealBu(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard
    local cbGangCard = pBuffer.cbGangCard
    local cbBuCard = pBuffer.cbBuCard

    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    local wChairID = GameCommon:getRoleChairID()
    local cbCardCount = GameCommon.player[wChairID].cbCardCount
    local cbCardData = GameCommon.player[wChairID].cbCardData
    local bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount
    local WeaveItemArray = GameCommon.player[wChairID].WeaveItemArray
    local tableWeaveItem = {}
    for key, var in pairs(cbBuCard) do
        if var ~= 0 then
            table.insert(tableWeaveItem,#tableWeaveItem+1,{cbWeaveKind = GameCommon.WIK_FILL,cbCenterCard = var, cbPublicCard = 1,wProvideUser = wResumeUser})
        end
    end
    if #tableWeaveItem == 1 then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",tableWeaveItem[1].cbWeaveKind,tableWeaveItem[1].cbCenterCard)
        self:removeFromParent()
    else
        local cardScale = 0.6
        local cardWidth = 81 * cardScale
        local cardHeight = 118 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth*3
        local stepY = 0
        for key, var in pairs(tableWeaveItem) do
            local item = self.uiPanel_opration:clone()
            uiListView_OprationType:pushBackCustomItem(item)
            for i = 1, 4 do
                local card = nil
                if var.cbPublicCard == 2 and i < 4 then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(var.cbCenterCard)     
                end
                item:addChild(card)
                if i == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(2-1)*cardWidth+28,card:getParent():getContentSize().height/2+10)
                else
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(i-1)*cardWidth+28,card:getParent():getContentSize().height/2)
                end
                item:addTouchEventListener(function(sender,event)
                    if event == ccui.TouchEventType.ended then
                        Common:palyButton()
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",var.cbWeaveKind,var.cbCenterCard)
                        self:removeFromParent()
                    end
                end)
            end
        end
        uiListView_OprationType:refreshView()
        uiListView_OprationType:setPositionX(cc.Director:getInstance():getVisibleSize().width*0.82-uiListView_OprationType:getInnerContainerSize().width)
        uiListView_OprationType:setDirection(ccui.ScrollViewDir.none)
    end
end

function GameOpration:dealGang(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard
    local cbGangCard = pBuffer.cbGangCard
    local cbBuCard = pBuffer.cbBuCard
    
    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    local wChairID = GameCommon:getRoleChairID()
    local cbCardCount = GameCommon.player[wChairID].cbCardCount
    local cbCardData = GameCommon.player[wChairID].cbCardData
    local bWeaveItemCount = GameCommon.player[wChairID].bWeaveItemCount
    local WeaveItemArray = GameCommon.player[wChairID].WeaveItemArray
    local tableWeaveItem = {}
    for key, var in pairs(cbGangCard) do
        if var ~= 0 then
            table.insert(tableWeaveItem,#tableWeaveItem+1,{cbWeaveKind = GameCommon.WIK_GANG,cbCenterCard = var, cbPublicCard = 1,wProvideUser = wResumeUser})
        end
    end
    if #tableWeaveItem == 1 then
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",tableWeaveItem[1].cbWeaveKind,tableWeaveItem[1].cbCenterCard)
        self:removeFromParent()
    else
        local cardScale = 0.6
        local cardWidth = 81 * cardScale
        local cardHeight = 118 * cardScale
        local beganX = cardWidth/2
        local beganY = cardHeight/2
        local stepX = cardWidth*3
        local stepY = 0
        for key, var in pairs(tableWeaveItem) do
            local item = self.uiPanel_opration:clone()
            uiListView_OprationType:pushBackCustomItem(item)
            for i = 1, 4 do
                local card = nil
                if var.cbPublicCard == 2 and i < 4 then
                    card = GameCommon:getDiscardCardAndWeaveItemArray(0)
                else
                    card = GameCommon:getDiscardCardAndWeaveItemArray(var.cbCenterCard)     
                end
                item:addChild(card)
                if i == 4 then
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(2-1)*cardWidth+28,card:getParent():getContentSize().height/2+10)
                else
                    card:setScale(cardScale) 
                    card:setPosition(cardWidth/2+(i-1)*cardWidth+28,card:getParent():getContentSize().height/2)
                end
                item:addTouchEventListener(function(sender,event)
                    if event == ccui.TouchEventType.ended then
                        Common:palyButton()
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",var.cbWeaveKind,var.cbCenterCard)
                        self:removeFromParent()
                    end
                end)
            end
        end
        uiListView_OprationType:refreshView()
        uiListView_OprationType:setPositionX(cc.Director:getInstance():getVisibleSize().width*0.82-uiListView_OprationType:getInnerContainerSize().width)
        uiListView_OprationType:setDirection(ccui.ScrollViewDir.none)
    end
end

function GameOpration:dealHu(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard

    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    if tableActionCard ~= nil then
        for key, var in pairs(tableActionCard) do
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_CHI_HU,var)
            self:removeFromParent()
            return
        end
    end
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_CHI_HU,cbOperateCard)
    self:removeFromParent()    
end

function GameOpration:dealBiHu(pBuffer)
    local cbOperateCard = pBuffer.cbActionCard
    local cbOperateCode = pBuffer.cbActionMask
    local wResumeUser = pBuffer.wResumeUser
    local bIsSelf = pBuffer.bIsSelf
    local tableActionCard = pBuffer.tableActionCard

    local uiListView_OprationType = ccui.Helper:seekWidgetByName(self.root,"ListView_OprationType")
    uiListView_OprationType:removeAllChildren()
    uiListView_OprationType:setVisible(true)
    if tableActionCard ~= nil then
        for key, var in pairs(tableActionCard) do
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_BIHU,var)
            self:removeFromParent()
            return
        end
    end
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_BIHU,cbOperateCard)
    self:removeFromParent()    
end

return GameOpration