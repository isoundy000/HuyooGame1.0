local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")
local GameDesc = require("common.GameDesc")

local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").ViewBase)

function RoomCreateLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onCleanup()

end

function RoomCreateLayer:onCreate(parameter)
    self.wKindID  = parameter[1]
    self.showType = parameter[2]
    self.dwClubID = parameter[3]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer67.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)
    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)
 
        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end 
    end
    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    uiListView_parameterList:getItem(0):setVisible(false)
    Common:addCheckTouchEventListener(items)
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
        local var = items[4]
        if index == 3 then
            var:setEnabled(true)
            var:setColor(cc.c3b(255,255,255))
        else            
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    end)
    if self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 2 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 3 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    -- if self.wKindID == 67 then
    --     items[1]:setBright(true)
    --     items[2]:setBright(false)
    --     items[3]:setBright(false)
    --     items[2]:setEnabled(false)
    --     items[2]:setColor(cc.c3b(170,170,170))
    --     items[3]:setEnabled(false)
    --     items[3]:setColor(cc.c3b(170,170,170))
    -- end
    --选择奖马
    -- local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    -- Common:addCheckTouchEventListener(items,false,function(index)
    --     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    --     if index == 1 then
    --         local isHaveDefault = false
    --         for key, var in pairs(items) do
    --             var:setEnabled(true)
    --             var:setColor(cc.c3b(255,255,255))
    --             if var:isBright() then
    --                 isHaveDefault = true
    --             end
    --         end
    --         if isHaveDefault == false then
    --             items[2]:setBright(true)
    --         end
    --     else
    --         for key, var in pairs(items) do
    --             var:setBright(false)
    --             var:setEnabled(false)
    --             var:setColor(cc.c3b(170,170,170))
    --         end
    --     end

    -- end)
    -- if self.recordCreateParameter["bMaType"] ~= nil and self.recordCreateParameter["bMaType"] == 3 then
    --     items[2]:setBright(true)
    -- elseif self.recordCreateParameter["bMaType"] ~= nil and self.recordCreateParameter["bMaType"] == 5 then
    --     items[3]:setBright(true)
    -- elseif self.recordCreateParameter["bMaType"] ~= nil and self.recordCreateParameter["bMaType"] == 6 then
    --     items[4]:setBright(true)
    -- else
    --     items[1]:setBright(true)
    -- end
    -- if CHANNEL_ID == 6 or  CHANNEL_ID == 7 then
    --     items[4]:setVisible(false) 
    -- end
    --奖马数量
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMaCount"] ~= nil and self.recordCreateParameter["bMaCount"] == 4 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bMaCount"] ~= nil and self.recordCreateParameter["bMaCount"] == 6 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bMaCount"] ~= nil and self.recordCreateParameter["bMaCount"] == 8 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bMaType"] ~= nil and self.recordCreateParameter["bMaType"] == 6 then
        items[4]:setBright(true)
    else
        items[2]:setBright(true)
    end
    
    --奖马分数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bNiaoType"] ~= nil and self.recordCreateParameter["bNiaoType"] == 2 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --选择底分
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["mDiFen"] ~= nil and self.recordCreateParameter["mDiFen"] == 1 then
        items[1]:setBright(true)
    else
        items[2]:setBright(true)
    end
    --选择抢杠
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
        local var = items[1]
        if index == 2 then
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        else
            var:setEnabled(true)
            var:setColor(cc.c3b(255,255,255))
        end
    end)
    if self.recordCreateParameter["bQGHu"] ~= nil and self.recordCreateParameter["bQGHu"] == 0 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    --抢杠胡奖马
    if self.recordCreateParameter["bQGHuJM"] ~= nil and self.recordCreateParameter["bQGHuJM"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    if self.recordCreateParameter["bQGHu"] ~= nil and self.recordCreateParameter["bQGHu"] == 0 then
        items[1]:setBright(false)
        items[1]:setEnabled(false)
        items[1]:setColor(cc.c3b(170,170,170))
    end
    --黄庄荒杠
    if self.recordCreateParameter["bHuangZhuangHG"] ~= nil and self.recordCreateParameter["bHuangZhuangHG"] == 1 then
        items[2]:setBright(true)
    else
        items[2]:setBright(false)
    end
    --清水胡/两片
    if self.recordCreateParameter["bQingSH"] ~= nil and self.recordCreateParameter["bQingSH"] == 1 then
        items[3]:setBright(true)
    else
        items[3]:setBright(false)
    end   

    --两人场去掉筒子
    if self.recordCreateParameter["bPlayerCount"] == nil or self.recordCreateParameter["bPlayerCount"] ~= 2 then
        items[4]:setBright(false)
        items[4]:setEnabled(false)
        items[4]:setColor(cc.c3b(170,170,170))
    else            
        items[4]:setEnabled(true)
        items[4]:setColor(cc.c3b(255,255,255))        
        if self.recordCreateParameter["bWuTong"] ~= nil and self.recordCreateParameter["bWuTong"] == 0 then
            items[4]:setBright(true)
        else
            items[4]:setBright(false)
        end
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    --清一色
    if self.recordCreateParameter["bQingYiSe"] == nil or self.recordCreateParameter["bQingYiSe"] == 1 then
        items[1]:setBright(true)
    end
    --碰碰胡
    if self.recordCreateParameter["bPPHu"] == nil or self.recordCreateParameter["bPPHu"] == 1 then
        items[2]:setBright(true)
    end
    -- --七对
    -- if self.recordCreateParameter["bQiXiaoDui"] ~= nil or self.recordCreateParameter["bQiXiaoDui"] == 1 then        
    --     items[3]:setBright(true)
    -- end

    -- --飘分
    -- if self.recordCreateParameter["mPFFlag"] == nil or self.recordCreateParameter["mPFFlag"] == 1 then        
    --     items[3]:setBright(true)
    -- end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true,function(index) 
        if items[1]:isBright() then
            items[2]:setEnabled(true)
            -- items[2]:setBright(true)
            items[2]:setColor(cc.c3b(255,255,255))
        else
            items[2]:setBright(false)
            items[2]:setEnabled(false)
            items[2]:setColor(cc.c3b(170,170,170))
        end
    end)

    --七对
    if self.recordCreateParameter["bQiXiaoDui"] == nil or self.recordCreateParameter["bQiXiaoDui"] == 1 then        
        items[1]:setBright(true)
        items[2]:setEnabled(true)
        items[2]:setColor(cc.c3b(255,255,255))    
        --龙七对
        if self.recordCreateParameter["bLongQD"] == nil or self.recordCreateParameter["bLongQD"] == 0 then        
            items[2]:setBright(true)
        else
            items[2]:setBright(false)
        end
    else
        items[2]:setBright(false)
        items[2]:setEnabled(false)
        items[2]:setColor(cc.c3b(170,170,170))
    end

    --选择封顶
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
        if index == 1 or index == 2 or index == 3 or index == 4  then
            for key, var in pairs(items) do
                var:setBright(false)
            end
        end
    end)
    if self.recordCreateParameter["mJFCount"] ~= nil and self.recordCreateParameter["mJFCount"] == 300 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["mJFCount"] ~= nil and self.recordCreateParameter["mJFCount"] == 200 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["mJFCount"] ~= nil and self.recordCreateParameter["mJFCount"] == 100 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["mJFCount"] == nil or self.recordCreateParameter["mJFCount"] == 1000 then
        items[4]:setBright(true)
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
        if index == 1 or index == 2   then
            for key, var in pairs(items) do
                var:setBright(false)
            end
        end
    end)
    if self.recordCreateParameter["mJFCount"] ~= nil and self.recordCreateParameter["mJFCount"] == 30 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["mJFCount"] ~= nil and self.recordCreateParameter["mJFCount"] == 60 then
        items[2]:setBright(true)
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(11),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["mPFFlag"] ~= nil and self.recordCreateParameter["mPFFlag"] == 1 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["mPFFlag"] ~= nil and self.recordCreateParameter["mPFFlag"] == 2 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --选择托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(12),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(13),"ListView_parameter"):getItems()
        if index == 1 then         
            for key, var in pairs(items) do
                var:setBright(false)
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
        else
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255)) 
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end
    end)
    if self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 1 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 2 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 3 then
        items[4]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --选择托管局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(13),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bHostedTime"] == nil or self.recordCreateParameter["bHostedTime"] == 0 then
        for key, var in pairs(items) do
            var:setBright(false)
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    elseif self.recordCreateParameter["bHostedSession"] ~= nil and self.recordCreateParameter["bHostedSession"] == 3 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bHostedSession"] ~= nil and self.recordCreateParameter["bHostedSession"] >= 6 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end

    if self.showType == 3 then
        self.tableFriendsRoomParams = {[1] = {wGameCount = 1}}
        self:SUB_CL_FRIENDROOM_CONFIG_END()
    else
        UserData.Game:sendMsgGetFriendsRoomParam(self.wKindID)
    end
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG(event)
    local data = event._usedata
    if data.wKindID ~= self.wKindID then
        return
    end
    if self.tableFriendsRoomParams == nil then
        self.tableFriendsRoomParams = {}
    end
    self.tableFriendsRoomParams[data.dwIndexes] = data
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG_END(event)
    if self.tableFriendsRoomParams == nil then
        return
    end
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local uiListView_parameter = uiListView_parameterList:getItem(0)
    uiListView_parameter:setVisible(true)
    local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
    local isFound = false
    for key, var in pairs(items) do
        local data = self.tableFriendsRoomParams[key]
    	if data then
            local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
            uiText_desc:setString(string.format("%d局",data.wGameCount))
            local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
            if data.dwExpendType == 1 then
                uiText_addition:setString(string.format("金币x%d",data.dwExpendCount))
            elseif data.dwExpendType == 2 then
                uiText_addition:setString(string.format("元宝x%d",data.dwExpendCount))
            elseif data.dwExpendType == 3 then
                if CHANNEL_ID == 20 or CHANNEL_ID == 21 then 
                    uiText_addition:setString(string.format("(钻石x%d)",data.dwExpendCount)) 
                else
                    uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount)) 
                end
            else
                uiText_addition:setString("(无消耗)")
            end
            if isFound == false and self.recordCreateParameter["wGameCount"] ~= nil and self.recordCreateParameter["wGameCount"] == data.wGameCount then
                var:setBright(true)
                isFound = true
            end
    	else
    	   var:setBright(false)
    	   var:setVisible(false)
    	end
    end
    if isFound == false and items[1]:isVisible() then
        items[1]:setBright(true)
    end
end

function RoomCreateLayer:onEventCreate(nTableType)
    NetMgr:getGameInstance():closeConnect()
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local tableParameter = {}
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[1] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
    elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
    elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
    else
        return
    end
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bPlayerCount = 4
    elseif items[2]:isBright() then
        tableParameter.bPlayerCount = 3
    elseif items[3]:isBright() then
        tableParameter.bPlayerCount = 2
    else
        return
    end
    --奖马数量
    tableParameter.bMaType = 1
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bMaCount = 4
    elseif items[2]:isBright() then
        tableParameter.bMaCount = 6
    elseif items[3]:isBright() then
        tableParameter.bMaCount = 8
    elseif items[4]:isBright() then
        tableParameter.bMaCount = 0
        tableParameter.bMaType = 6
    end
  
    --奖马分数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bNiaoType = 1
    elseif items[2]:isBright() then
        tableParameter.bNiaoType = 2
    end

    --选择底分
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.mDiFen = 1
    elseif items[2]:isBright() then
        tableParameter.mDiFen = 2
    else
        tableParameter.mDiFen = 2
    end
    
    --选择抢杠
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bQGHu = 1
    elseif items[2]:isBright() then
        tableParameter.bQGHu = 0
    else
        return
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    --抢杠胡奖马
    if items[1]:isBright() then
        tableParameter.bQGHuJM = 1
    else
        tableParameter.bQGHuJM = 0
    end
    --黄庄荒杠
    if items[2]:isBright() then
        tableParameter.bHuangZhuangHG = 1
    else
        tableParameter.bHuangZhuangHG = 0
    end
    --清水胡
    if items[3]:isBright() then
        tableParameter.bQingSH = 1
    else
        tableParameter.bQingSH = 0
    end
    tableParameter.bJiePao = 0
    --两人去筒
    if items[4]:isBright() then
        tableParameter.bWuTong = 0
    else
        tableParameter.bWuTong = 1
    end
    
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    --清一色
    if items[1]:isBright() then
        tableParameter.bQingYiSe = 1
    else
        tableParameter.bQingYiSe = 0
    end
    --碰碰胡
    if items[2]:isBright() then
        tableParameter.bPPHu= 1
    else
        tableParameter.bPPHu = 0
    end
    -- --七对
    -- if items[3]:isBright() then
    --     tableParameter.bQiXiaoDui = 1
    -- else
    --     tableParameter.bQiXiaoDui = 0
    -- end

    -- --飘分
    -- if items[3]:isBright() then
    --     tableParameter.mPFFlag = 1
    -- else
    --     tableParameter.mPFFlag = 0
    -- end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    --七对
    if items[1]:isBright() then
        tableParameter.bQiXiaoDui = 1
    else
        tableParameter.bQiXiaoDui = 0
    end
    --龙七对
    if items[2]:isBright() then
        tableParameter.bLongQD = 0
    else
        tableParameter.bLongQD = 1
    end

   --积分上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.mJFCount = 100
    elseif items[2]:isBright() then
        tableParameter.mJFCount = 200
    elseif items[3]:isBright() then
        tableParameter.mJFCount = 300
    elseif items[4]:isBright() then
        tableParameter.mJFCount = 1000
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.mJFCount = 30
    elseif items[2]:isBright() then
        tableParameter.mJFCount = 60
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(11),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.mPFFlag = 0
    elseif items[2]:isBright() then
        tableParameter.mPFFlag = 1
    elseif items[3]:isBright() then
        tableParameter.mPFFlag = 2
    end
    tableParameter.bHostedTime = 0
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(12),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHostedTime = 0
    elseif items[2]:isBright() then
        tableParameter.bHostedTime = 1
    elseif items[3]:isBright() then
        tableParameter.bHostedTime = 2
    elseif items[4]:isBright() then
        tableParameter.bHostedTime = 3
    end    
    
    --选择托管局数
    tableParameter.bHostedSession = 0
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(13),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHostedSession = 1
    elseif items[2]:isBright() then
        tableParameter.bHostedSession =  tableParameter.wGameCount
    elseif items[3]:isBright() then
        tableParameter.bHostedSession = 3
    end  

   if self.showType ~= 2 and (nTableType == TableType_FriendRoom or nTableType == TableType_HelpRoom) then
        --普通创房和代开需要判断金币
        local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
        local uiListView_parameter = uiListView_parameterList:getItem(0)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
        for key, var in pairs(items) do
            if var:isBright() then
                local data = self.tableFriendsRoomParams[key]
                if data.dwExpendType == 0 then--无消耗
                elseif data.dwExpendType == 1 then--金币
                    if UserData.User.dwGold  < data.dwExpendCount then
                        require("common.MsgBoxLayer"):create(0,nil,"您的金币不足!")
                        return
                    end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        require("common.MsgBoxLayer"):create(0,nil,"您的元宝不足!")
                        return
                    end 
                elseif data.dwExpendType == 3 then--道具
                    local itemCount = UserData.Bag:getBagPropCount(data.dwSubType)
                    if itemCount < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的道具不足,请前往商城购买?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(0,nil,"您的道具不足!")
                        end
                        return
                    end
                else
                    return
                end
                break
            end
        end
    end
    
    UserData.Game:saveCreateParameter(self.wKindID,tableParameter)

    --亲友圈自定义创房
    if self.showType == 2 then
        local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
        uiButton_create:removeAllChildren()
        uiButton_create:addChild(require("app.MyApp"):create(TableType_ClubRoom,1,self.wKindID,tableParameter.wGameCount,self.dwClubID,tableParameter):createView("InterfaceCreateRoomNode"))
        return
    end 
    --设置亲友圈   
    if nTableType == TableType_ClubRoom then
        EventMgr:dispatch(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,{wKindID = self.wKindID,wGameCount = tableParameter.wGameCount,tableParameter = tableParameter})      
        return
    end
    
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    uiButton_create:removeAllChildren()
    uiButton_create:addChild(require("app.MyApp"):create(nTableType,0,self.wKindID,tableParameter.wGameCount,UserData.Guild.dwPresidentID,tableParameter):createView("InterfaceCreateRoomNode"))
    
end

return RoomCreateLayer

