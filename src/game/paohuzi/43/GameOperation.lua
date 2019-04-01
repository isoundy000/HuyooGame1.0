local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local Common = require("common.Common")
local Bit = require("common.Bit")
local GameCommon = require("game.paohuzi.43.GameCommon")
local GameLogic = require("game.paohuzi.43.GameLogic")

local GameOperation = class("GameOperation",function()
    return ccui.Layout:create()
end)

function GameOperation:create(cbOperateCode,cbOperateCard,cbCardIndex,cbSubOperateCode)
    local view = GameOperation.new()
    view:onCreate(cbOperateCode,cbOperateCard,cbCardIndex,cbSubOperateCode)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit()
        elseif eventType == "cleanup" then
            view:onCleanup()
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function GameOperation:onEnter()

end

function GameOperation:onExit()
    if self.uiPanel_item ~= nil then
        self.uiPanel_item:release()
        self.uiPanel_item = nil
    end
    if self.Button_operation ~= nil then
        self.Button_operation:release()
        self.Button_operation = nil
    end
    if self.uiListView_list ~= nil then
        self.uiListView_list:release()
        self.uiListView_list = nil
    end
    
end

function GameOperation:onCleanup()

end

function GameOperation:onCreate(cbOperateCode,cbOperateCard,cbCardIndex,cbSubOperateCode)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayerZiPai_Operation.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    print("操作提示")
    printInfo(cbOperateCode)
    printInfo(cbOperateCard)
    printInfo(cbCardIndex)
    printInfo(cbSubOperateCode)
    self.cbOperateCode = cbOperateCode
    self.cbOperateCard = cbOperateCard
    self.cbCardIndex = cbCardIndex
    self.cbSubOperateCode = cbSubOperateCode
    self.operateClientData = {}
    
    local uiPanel_operation = ccui.Helper:seekWidgetByName(self.root,"Panel_operation")
    self.Button_operation = ccui.Helper:seekWidgetByName(self.root,"Button_operation")
    self.Button_operation:retain()
    uiPanel_operation:removeAllChildren()
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")
    uiPanel_bg:setVisible(false)
    local uiListView_panel = ccui.Helper:seekWidgetByName(self.root,"ListView_panel")
    uiListView_panel:setVisible(false)
    self.uiListView_list = ccui.Helper:seekWidgetByName(self.root,"ListView_list")
    self.uiListView_list:retain()
    self.Panel_jiantou = ccui.Helper:seekWidgetByName(self.root,"Panel_jiantou")
    self.Panel_jiantou:retain()
    self.uiPanel_item = ccui.Helper:seekWidgetByName(self.root,"Panel_item")
    self.uiPanel_item:retain()
    local uiListView_card = ccui.Helper:seekWidgetByName(self.root,"ListView_card")
    self.uiListView_list:removeAllItems()
    uiListView_panel:removeAllItems()
    --操作选项
    if (Bit:_and(cbOperateCode,GameCommon.ACK_BIHU) ~= 0) then
        local item = self.Button_operation:clone()
            item:loadTextures("game/op_hu.png","game/op_hu.png","game/op_hu.png")
        item:setPressedActionEnabled(true)
            uiPanel_operation:addChild(item)
        item:addTouchEventListener(function(sender,event) 
            if event == ccui.TouchEventType.ended then 
                Common:palyButton() 
                self:dealHu()
            end 
        end)
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xuanzhuanxing/xuanzhuanxing.ExportJson")
        local armature=ccs.Armature:create("xuanzhuanxing")
        armature:getAnimation():playWithIndex(0)
        item:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
    else
        if (Bit:_and(cbOperateCode,GameCommon.ACK_CHI) ~= 0) or (Bit:_and(cbOperateCode,GameCommon.ACK_CHI_EX) ~= 0) then
            if Bit:_and(cbOperateCode,GameCommon.ACK_CHI_EX) ~= 0 then
                self.operateClientData.cbOperateCode = GameCommon.ACK_CHI_EX
            else
                self.operateClientData.cbOperateCode = GameCommon.ACK_CHI
            end
            local item = self.Button_operation:clone()
                item:loadTextures("game/op_chi.png","game/op_chi.png","game/op_chi.png")
                item:setPressedActionEnabled(true)
                uiPanel_operation:addChild(item)
                item:addTouchEventListener(function(sender,event) 
                    if event == ccui.TouchEventType.ended then 
                        Common:palyButton() 
                        self:dealChi()
                    end 
                end)
          
            end
            if Bit:_and(cbOperateCode,GameCommon.ACK_PENG) ~= 0  then
                local item = self.Button_operation:clone()
                item:loadTextures("game/op_peng.png","game/op_peng.png","game/op_peng.png")
                item:setPressedActionEnabled(true)
                uiPanel_operation:addChild(item)
                item:addTouchEventListener(function(sender,event) 
                    if event == ccui.TouchEventType.ended then 
                        Common:palyButton() 
                        self:dealPen()
                    end 
                end)
            end
            if Bit:_and(cbOperateCode,GameCommon.ACK_CHIHU) ~= 0  then
                local item = self.Button_operation:clone()
                item:loadTextures("game/op_hu.png","game/op_hu.png","game/op_hu.png")
            item:setPressedActionEnabled(true)
                uiPanel_operation:addChild(item)
            item:addTouchEventListener(function(sender,event) 
                if event == ccui.TouchEventType.ended then 
                    Common:palyButton() 
                    self:dealHu()
                end 
            end)
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xuanzhuanxing/xuanzhuanxing.ExportJson")
            local armature=ccs.Armature:create("xuanzhuanxing")
            armature:getAnimation():playWithIndex(0)
            item:addChild(armature)
            armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
        end
        if Bit:_and(cbOperateCode,GameCommon.ACK_WD) ~= 0  then
            if GameCommon.tableConfig.wKindID == 14 or GameCommon.tableConfig.wKindID == 34 or GameCommon.tableConfig.wKindID == 35 or GameCommon.tableConfig.wKindID == 36 or GameCommon.tableConfig.wKindID == 37 then
                if Bit:_and(cbSubOperateCode,0x01) ~= 0  then
                    --4王 王钓
                    local item = self.Button_operation:clone()
                    item:loadTextures("game/paohuzi/res/table/word_plate_table5.png","game/paohuzi/res/table/word_plate_table5.png","game/paohuzi/res/table/word_plate_table5.png")
                    item:setPressedActionEnabled(true)
                    uiPanel_operation:pushBackCustomItem(item)
                    item:addTouchEventListener(function(sender,event) 
                        if event == ccui.TouchEventType.ended then 
                            Common:palyButton() 
                            self:dealWd()
                        end 
                    end)
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/paohuzi/res/animation/xuanzhuanxing/xuanzhuanxing.ExportJson")
                    local armature=ccs.Armature:create("xuanzhuanxing")
                    armature:getAnimation():playWithIndex(0)
                    item:addChild(armature)
                    armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
                end
                if Bit:_and(cbSubOperateCode,0x02) ~= 0  then
                    --4王 王闯
                    local item = self.Button_operation:clone()
                    item:loadTextures("game/paohuzi/res/table/word_plate_table6.png","game/paohuzi/res/table/word_plate_table6.png","game/paohuzi/res/table/word_plate_table6.png")
                    item:setPressedActionEnabled(true)
                        uiPanel_operation:addChild(item)
                    item:addTouchEventListener(function(sender,event) 
                        if event == ccui.TouchEventType.ended then 
                            Common:palyButton() 
                            self:dealWc()
                        end 
                    end)
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/paohuzi/res/animation/xuanzhuanxing/xuanzhuanxing.ExportJson")
                    local armature=ccs.Armature:create("xuanzhuanxing")
                    armature:getAnimation():playWithIndex(0)
                    item:addChild(armature)
                    armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
                end
                if Bit:_and(cbSubOperateCode,0x04) ~= 0  then
                    --4王 三王闯
                    local item = self.Button_operation:clone()
                    item:loadTextures("game/paohuzi/res/table/word_plate_table7.png","game/paohuzi/res/table/word_plate_table7.png","game/paohuzi/res/table/word_plate_table7.png")
                    item:setPressedActionEnabled(true)
                        uiPanel_operation:addChild(item)
                    item:addTouchEventListener(function(sender,event) 
                        if event == ccui.TouchEventType.ended then 
                            Common:palyButton() 
                            self:deal3Wc()
                        end 
                    end)
                    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/paohuzi/res/animation/xuanzhuanxing/xuanzhuanxing.ExportJson")
                    local armature=ccs.Armature:create("xuanzhuanxing")
                    armature:getAnimation():playWithIndex(0)
                    item:addChild(armature)
                    armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
                else

                end
            else
                local item = self.Button_operation:clone()
                item:loadTextures("game/paohuzi/res/table/word_plate_table5.png","game/paohuzi/res/table/word_plate_table5.png","game/paohuzi/res/table/word_plate_table5.png")
                item:setPressedActionEnabled(true)
                    uiPanel_operation:addChild(item)
                item:addTouchEventListener(function(sender,event) 
                    if event == ccui.TouchEventType.ended then 
                        Common:palyButton() 
                        self:dealWd()
                    end 
                end)
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/paohuzi/res/animation/xuanzhuanxing/xuanzhuanxing.ExportJson")
                local armature=ccs.Armature:create("xuanzhuanxing")
                armature:getAnimation():playWithIndex(0)
                item:addChild(armature)
                armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
            end
        end
        if Bit:_and(cbOperateCode,GameCommon.ACK_WC) ~= 0 then
            local item = self.Button_operation:clone()
            item:loadTextures("game/paohuzi/res/table/word_plate_table6.png","game/paohuzi/res/table/word_plate_table6.png","game/paohuzi/res/table/word_plate_table6.png")
            item:setPressedActionEnabled(true)
                uiPanel_operation:addChild(item)
            item:addTouchEventListener(function(sender,event) 
                if event == ccui.TouchEventType.ended then 
                    Common:palyButton() 
                    self:dealWc()
                end 
            end)
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/paohuzi/res/animation/xuanzhuanxing/xuanzhuanxing.ExportJson")
            local armature=ccs.Armature:create("xuanzhuanxing")
            armature:getAnimation():playWithIndex(0)
            item:addChild(armature)
            armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
        end

        local item = self.Button_operation:clone()
        item:loadTextures("game/op_guo.png","game/op_guo.png","game/op_guo.png")
        item:setPressedActionEnabled(true)
        uiPanel_operation:addChild(item)
        item:addTouchEventListener(function(sender,event) 
            if event == ccui.TouchEventType.ended then 
                Common:palyButton() 
                self:dealGuo()
            end 
        end)
    end
    local items = uiPanel_operation:getChildren()
    local interval = 50
    local width = items[1]:getContentSize().width
    local beganPos = (uiPanel_operation:getContentSize().width -  #items * width - (#items-1)*interval)/2 + width/2
    for key, var in pairs(items) do
        var:setPosition(beganPos + (key-1)*(width + interval), uiPanel_operation:getContentSize().height/2)
    end
end

function GameOperation:dealChi()
    local uiListView_panel = ccui.Helper:seekWidgetByName(self.root,"ListView_panel")
    uiListView_panel:removeAllItems()
    uiListView_panel:setVisible(true)
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")
    uiPanel_bg:setVisible(true)    
    uiPanel_bg:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            uiPanel_bg:setVisible(false)      
            uiListView_panel:setVisible(false)   
        end
    end)

    --第一阶段
    local uiListViewList1 = nil
    local cbCardIndex1 = clone(self.cbCardIndex)
    local chiCounts , pChiCardInfo1 = GameLogic:GetActionChiCard(cbCardIndex1,self.cbOperateCard)
    if chiCounts > 0 then
        uiListViewList1 = self.uiListView_list:clone()
        uiListView_panel:pushBackCustomItem(uiListViewList1)
    end
    for i = 1 , chiCounts  do
        local item = self.uiPanel_item:clone()
        uiListViewList1:pushBackCustomItem(item)
        local uiButton_chi = ccui.Helper:seekWidgetByName(item,"Button_chi")
        uiButton_chi.cardIndex = {}
        local uiListView_card = ccui.Helper:seekWidgetByName(item,"ListView_card")
        
        for j = 1 , 3 do
            local card = GameCommon:getDiscardCardAndWeaveItemArray(pChiCardInfo1[i].cbCardData[1][j], true)
            uiButton_chi.cardIndex[j] = pChiCardInfo1[i].cbCardData[1][j]
            uiButton_chi.cbChiKind = pChiCardInfo1[i].cbChiKind
            if uiButton_chi.cardIndex[j] == self.cbOperateCard then      
                if j == 1 then  
                    card:setColor(cc.c3b(200,200,200))                  
                elseif j == 2 then
                  if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] then 
                        card:setColor(cc.c3b(200,200,200))  
                  end   
                else 
                    if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] and uiButton_chi.cardIndex[j-2] ~= uiButton_chi.cardIndex[j]  then 
                        card:setColor(cc.c3b(200,200,200))  
                    end    
                end                
            end 
          
            if card ~= nil then
                uiListView_card:pushBackCustomItem(card)
            end
        end
        uiButton_chi:setPressedActionEnabled(true)
        uiButton_chi:addTouchEventListener(function(sender,event) 
            if event == ccui.TouchEventType.ended then 
                --移除UI
                local items = uiListView_panel:getItems()
                for i = 2 , #items do
                    uiListView_panel:removeItem(1)
                end
                --变个颜色
                local items = uiListViewList1:getItems()
                for key, var in pairs(items) do
                    local btn = ccui.Helper:seekWidgetByName(var,"Button_chi")
                    if btn == sender then
                        btn:loadTextures("zipai/table/zipai_table_opbg.png","zipai/table/zipai_table_opbg.png","zipai/table/zipai_table_opbg.png")                       
                    else
                        if  btn ~= nil then 
                            btn:loadTextures("zipai/table/zipai_table_op.png","zipai/table/zipai_table_op.png","zipai/table/zipai_table_op.png")
                        end
                    end
                end
                --第二阶段
                self.operateClientData.cbChiKind = sender.cbChiKind
                self.operateClientData.cbBiKind1 = 0
                self.operateClientData.cbBiKind2 = 0
                local uiListViewList2 = nil
                local cbCardIndex2 = clone(cbCardIndex1)
                for i = 1 , 3 do
                    local idx = GameLogic:SwitchToCardIndex(sender.cardIndex[i])
                    cbCardIndex2[idx] = cbCardIndex2[idx] - 1
                end
                
                local chiCounts , pChiCardInfo2 = GameLogic:GetActionChiCard(cbCardIndex2,self.cbOperateCard)
                if chiCounts > 0 then
                    uiListViewList2 = self.uiListView_list:clone()
                    uiListView_panel:pushBackCustomItem(uiListViewList2)
                else
                    printInfo("发送吃的牌型")
                    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",self.operateClientData.cbChiKind,self.operateClientData.cbOperateCode,self.operateClientData.cbBiKind1,self.operateClientData.cbBiKind2)
                    self:removeFromParent()
                end
                for i = 1 , chiCounts  do
                    local item = self.uiPanel_item:clone()
                    if  i ==  1 then 
                    local item_jiantou2 = self.Panel_jiantou:clone()
                    uiListViewList2:pushBackCustomItem(item_jiantou2)
                    end
                    uiListViewList2:pushBackCustomItem(item)
                    local uiButton_chi = ccui.Helper:seekWidgetByName(item,"Button_chi")
                    uiButton_chi.cardIndex = {}
                    local uiListView_card = ccui.Helper:seekWidgetByName(item,"ListView_card")
                    for j = 1 , 3 do
                        local card = GameCommon:getDiscardCardAndWeaveItemArray(pChiCardInfo2[i].cbCardData[1][j], true)
                        uiButton_chi.cardIndex[j] = pChiCardInfo2[i].cbCardData[1][j]
                        uiButton_chi.cbChiKind = pChiCardInfo2[i].cbChiKind                        
                        if uiButton_chi.cardIndex[j] == self.cbOperateCard then      
                            if j == 1 then  
                                card:setColor(cc.c3b(200,200,200))                  
                            elseif j == 2 then
                                if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] then 
                                    card:setColor(cc.c3b(200,200,200))  
                                end   
                            else 
                                if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] and uiButton_chi.cardIndex[j-2] ~= uiButton_chi.cardIndex[j]  then 
                                    card:setColor(cc.c3b(200,200,200))  
                                end    
                            end                
                        end 
                        
                        if card ~= nil then
                            uiListView_card:pushBackCustomItem(card)
                        end
                    end
                    uiButton_chi:setPressedActionEnabled(true)
                    uiButton_chi:addTouchEventListener(function(sender,event) 
                        if event == ccui.TouchEventType.ended then 
                            Common:palyButton() 
                            
                            --移除UI
                            local items = uiListView_panel:getItems()
                            for i = 3 , #items do
                                uiListView_panel:removeItem(2)
                            end
                            --变个颜色
                            local items = uiListViewList2:getItems()
                            for key, var in pairs(items) do
                                local btn = ccui.Helper:seekWidgetByName(var,"Button_chi")
                                if btn == sender then
                                    btn:loadTextures("zipai/table/zipai_table_opbg.png","zipai/table/zipai_table_opbg.png","zipai/table/zipai_table_opbg.png")  
                                else
                                    if  btn ~= nil then 
                                        btn:loadTextures("zipai/table/zipai_table_op.png","zipai/table/zipai_table_op.png","zipai/table/zipai_table_op.png")  
                                    end 
                                end
                            end
                            --第三阶段
                            self.operateClientData.cbBiKind1 = sender.cbChiKind
                            self.operateClientData.cbBiKind2 = 0
                            local uiListViewList3 = nil
                            local cbCardIndex3 = clone(cbCardIndex2)
                            for i = 1 , 3 do
                                local idx = GameLogic:SwitchToCardIndex(sender.cardIndex[i])
                                cbCardIndex3[idx] = cbCardIndex3[idx] - 1
                            end

                            local chiCounts , pChiCardInfo3 = GameLogic:GetActionChiCard(cbCardIndex3,self.cbOperateCard)
                            if chiCounts > 0 then
                                uiListViewList3 = self.uiListView_list:clone()
                                uiListView_panel:pushBackCustomItem(uiListViewList3)
                            else
                                --发送吃的牌型
                                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",self.operateClientData.cbChiKind,self.operateClientData.cbOperateCode,self.operateClientData.cbBiKind1,self.operateClientData.cbBiKind2)
                                self:removeFromParent()
                            end
                            for i = 1 , chiCounts  do
                                local item = self.uiPanel_item:clone()
                                if  i ==  1 then 
                                    local item_jiantou3 = self.Panel_jiantou:clone()
                                    uiListViewList3:pushBackCustomItem(item_jiantou3)
                                end
                                uiListViewList3:pushBackCustomItem(item)
                                local uiButton_chi = ccui.Helper:seekWidgetByName(item,"Button_chi")
                                uiButton_chi.cardIndex = {}
                                local uiListView_card = ccui.Helper:seekWidgetByName(item,"ListView_card")
                                for j = 1 , 3 do
                                    local card = GameCommon:getDiscardCardAndWeaveItemArray(pChiCardInfo3[i].cbCardData[1][j], true)
                                    uiButton_chi.cardIndex[j] = pChiCardInfo3[i].cbCardData[1][j]
                                    uiButton_chi.cbChiKind = pChiCardInfo3[i].cbChiKind
                                    
                                    if uiButton_chi.cardIndex[j] == self.cbOperateCard then      
                                        if j == 1 then  
                                            card:setColor(cc.c3b(200,200,200))                  
                                        elseif j == 2 then
                                            if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] then 
                                                card:setColor(cc.c3b(200,200,200))  
                                            end   
                                        else 
                                            if uiButton_chi.cardIndex[j-1] ~= uiButton_chi.cardIndex[j] and uiButton_chi.cardIndex[j-2] ~= uiButton_chi.cardIndex[j]  then 
                                                card:setColor(cc.c3b(200,200,200))  
                                            end    
                                        end                
                                    end 
                                    
                                    if card ~= nil then
                                        uiListView_card:pushBackCustomItem(card)
                                    end
                                end
                                uiButton_chi:setPressedActionEnabled(true)
                                uiButton_chi:addTouchEventListener(function(sender,event) 
                                    if event == ccui.TouchEventType.ended then 
                                        Common:palyButton() 
                                        self.operateClientData.cbBiKind2 = sender.cbChiKind
                                        printInfo("发送吃的牌型")
                                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",self.operateClientData.cbChiKind,self.operateClientData.cbOperateCode,self.operateClientData.cbBiKind1,self.operateClientData.cbBiKind2)
                                        self:removeFromParent()
                                    end 
                                end)
                            end  
                            if uiListViewList3 ~= nil then
                                uiListViewList3:refreshView()
                                uiListViewList3:setContentSize(cc.size(uiListViewList3:getInnerContainerSize().width,uiListViewList3:getInnerContainerSize().height))   
                                if #uiListView_panel:getItems() > 0 then
                                    local width = 0
                                    for key, var in pairs(uiListView_panel:getItems()) do
                                        width = width + var:getContentSize().width
                                    end
                                    uiListView_panel:refreshView()
                                    uiListView_panel:setContentSize(cc.size(width,uiListView_panel:getInnerContainerSize().height))
                                    uiListView_panel:setPositionX(cc.Director:getInstance():getVisibleSize().width/2)
                                else
                                    uiListView_panel:setVisible(false)
                                    print("吃牌错误!")
                                end
                            end
                        end 
                    end)
                end  
                if uiListViewList2 ~= nil then
                    uiListViewList2:refreshView()
                    uiListViewList2:setContentSize(cc.size(uiListViewList2:getInnerContainerSize().width,uiListViewList2:getInnerContainerSize().height))   
                    if #uiListView_panel:getItems() > 0 then
                        local width = 0
                        for key, var in pairs(uiListView_panel:getItems()) do
                            width = width + var:getContentSize().width
                        end
                        uiListView_panel:refreshView()
                        uiListView_panel:setContentSize(cc.size(width,uiListView_panel:getInnerContainerSize().height))
                        uiListView_panel:setPositionX(cc.Director:getInstance():getVisibleSize().width/2)
                    else
                        uiListView_panel:setVisible(false)
                        print("吃牌错误!")
                    end
                end
                
            end 
        end)
    end  
    if uiListViewList1 ~= nil then
        uiListViewList1:refreshView()
        uiListViewList1:setContentSize(cc.size(uiListViewList1:getInnerContainerSize().width,uiListViewList1:getInnerContainerSize().height))    
        if #uiListView_panel:getItems() > 0 then
            local width = 0
            for key, var in pairs(uiListView_panel:getItems()) do
                width = width + var:getContentSize().width
            end
            uiListView_panel:refreshView()
            uiListView_panel:setContentSize(cc.size(width,uiListView_panel:getInnerContainerSize().height))
            uiListView_panel:setPositionX(cc.Director:getInstance():getVisibleSize().width/2)
        else
            uiListView_panel:setVisible(false)
            print("吃牌错误!")
        end
    end

end

function GameOperation:dealPen()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",0,128,0,0)
    self:removeFromParent()
end

function GameOperation:dealHu()
    --发送消息
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",0,256,0,0)
    self:removeFromParent()
end

function GameOperation:dealGuo()
    --发送消息
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",self.cbOperateCard,0,0,0)
    self:removeFromParent()
end

function GameOperation:dealWd()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",0,8,0,0)
    self:removeFromParent()
end

function GameOperation:dealWc()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",0,16,0,0)
    self:removeFromParent()
end
function GameOperation:deal3Wc()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwwbb",0,8,0x04,0,0)
    self:removeFromParent()
end

return GameOperation

