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
    local csb = cc.CSLoader:createNode("RoomCreateLayer48.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    if self.showType == 1 then
        self.recordCreateParameter = self.dwClubID;  --showType = 1是创房参数
    else
        self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    end
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
        local var = items[1]
        if index ~= 3 then
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        elseif var:isBright() == false then
            var:setEnabled(true)
            var:setColor(cc.c3b(255,255,255))
        end

        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
        Common:addCheckTouchEventListener(items)
        if index == 2 then
            local isHave = false
            for key, var in pairs(items) do
        		var:setColor(cc.c3b(255,255,255))
                var:setEnabled(true)
                if var:isBright() then
                    isHave = true
                end
        	end
        	if isHave == false then
                items[1]:setBright(true)
        	end
        else
            for key, var in pairs(items) do
                var:setColor(cc.c3b(170,170,170))
                var:setEnabled(false)
                var:setBright(false)
            end
        end
    end)
    if self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 4 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end
    if self.showType == 3 then
        items[3]:setEnabled(false)
        items[3]:setColor(cc.c3b(170,170,170))
        if items[3]:isBright() then
            items[1]:setBright(true)
        end
    end
    --起胡胡息
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bCanHuXi"] ~= nil and self.recordCreateParameter["bCanHuXi"] == 18 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bCanHuXi"] ~= nil and self.recordCreateParameter["bCanHuXi"] == 21 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end

     --选择加底
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
     Common:addCheckTouchEventListener(items,false,function(index)
         if index == 1 or index == 2 or index == 3 then
             local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4), "ListView_parameter"):getItems()
             items[1]:setBright(false)
             items[2]:setBright(false)
             items[3]:setBright(false)
         end
     end )
     if self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 1 then
         items[2]:setBright(true)
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 2 then
         items[3]:setBright(true)
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 3 then
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 4 then
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 5 then
     else
         items[1]:setBright(true)
     end
 
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
     Common:addCheckTouchEventListener(items,false,function(index)
         if index == 1 or index == 2 or index == 3 then
             local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3), "ListView_parameter"):getItems()
             items[1]:setBright(false)
             items[2]:setBright(false)
             items[3]:setBright(false)
         end
     end )
     if self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 3 then
         items[1]:setBright(true)
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 4 then
         items[2]:setBright(true)
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 5 then
         items[3]:setBright(true)
     end


    --选择玩法
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    -- if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x04,self.recordCreateParameter["dwMingTang"]) ~= 0 then
    --     items[1]:setBright(true)
    -- end
    -- if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x02,self.recordCreateParameter["dwMingTang"]) ~= 0 then
    --     items[2]:setBright(true)
    -- end
    if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x20000,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[1]:setBright(true)
    end
    if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x08,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[2]:setBright(true)
    end    
    if self.recordCreateParameter["bSiQiHong"] and self.recordCreateParameter["bSiQiHong"] == 1 then      --四七红
        items[3]:setBright(true)
    end

    if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x100000,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        if items[4] ~= nil then
            items[4]:setBright(true)
        end
    end
    -- if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x8000,self.recordCreateParameter["dwMingTang"]) ~= 0 then
    --     items[4]:setBright(true)
    -- end
    if CHANNEL_ID == 6 or CHANNEL_ID == 7 then
        ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):removeItem(3)
    end
    
    --跑牌提示
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bPlayerCount"] == nil or self.recordCreateParameter["bPlayerCount"] ~= 4 then
        items[1]:setBright(false)
        items[1]:setEnabled(false)
        items[1]:setColor(cc.c3b(170,170,170))
    elseif self.recordCreateParameter["bTurn"] ~= nil and self.recordCreateParameter["bTurn"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    if self.recordCreateParameter["bStartBanker"] ~= nil and self.recordCreateParameter["bStartBanker"] == 1 then
        items[2]:setBright(true)
    end    

    if CHANNEL_ID == 6 or CHANNEL_ID == 7 then
        items[3]:setBright(false)
        items[3]:setVisible(false)
    else
        if self.recordCreateParameter["bPaoTips"] ~= nil and self.recordCreateParameter["bPaoTips"] == 1 then
            items[3]:setBright(true)
        end
    end

    --选择假行行息
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)

    if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x8000,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x10,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --选择团圆
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)

    if self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x04,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["dwMingTang"] ~= nil and Bit:_and(0x10000,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --单局上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 300 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 600 then
        items[4]:setBright(true)
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 100 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --选择亡牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bPlayerCount"] == nil or self.recordCreateParameter["bPlayerCount"] ~= 2 then
        for key, var in pairs(items) do
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    elseif self.recordCreateParameter["bDeathCard"] ~= nil and self.recordCreateParameter["bDeathCard"] == 1 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end


    --选择托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(11),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 

        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(12),"ListView_parameter"):getItems()
        if index == 1 or index == 2 or index == 3 or index == 4 then         
            for key, var in pairs(items) do
                var:setBright(false)
            end
        end
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
    elseif self.recordCreateParameter["bHostedTime"] == nil or self.recordCreateParameter["bHostedTime"] == 0 then
        items[1]:setBright(true)
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(12),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(11),"ListView_parameter"):getItems()
        if index == 1 then         
            for key, var in pairs(items) do
                var:setBright(false)
            end
        end
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(13),"ListView_parameter"):getItems()
        if index == 1 then         
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
    if self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] ~= 5 then
        items[1]:setBright(false)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 5 then
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
    elseif items[4]:isBright() and self.tableFriendsRoomParams[4] then         
        tableParameter.wGameCount = self.tableFriendsRoomParams[4].wGameCount
    else
        return
    end
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bPlayerCount = 3
        tableParameter.bPlayerCountType = 0
    elseif items[2]:isBright() then
        tableParameter.bPlayerCount = 2
        tableParameter.bPlayerCountType = 0
    elseif items[3]:isBright() then
        tableParameter.bPlayerCount = 4
        tableParameter.bPlayerCountType = 2
    else
        return
    end
    --起胡胡息
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bCanHuXi = 15
    elseif items[2]:isBright() then
        tableParameter.bCanHuXi = 18
    elseif items[3]:isBright() then
        tableParameter.bCanHuXi = 21
    else
        return
    end

    --选择加底
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bStartTun = 0
    elseif items[2]:isBright() then
        tableParameter.bStartTun = 1
    elseif items[3]:isBright() then
        tableParameter.bStartTun = 2
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bStartTun = 3
    elseif items[2]:isBright() then
        tableParameter.bStartTun = 4
    elseif items[3]:isBright() then
        tableParameter.bStartTun = 5
    end

    --选择玩法
    tableParameter.dwMingTang = 0xFFF
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x02)
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x04)
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x08)  
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x10)   
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x20000)
    end
    if items[2]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x08)
    end
    if items[4] ~= nil and items[4]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x100000)
    end   
     if items[3]:isBright() then   --四七红
        tableParameter.bSiQiHong = 1
    else
        tableParameter.bSiQiHong = 0
    end
    --跑牌提示
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bTurn = 1
    else
        tableParameter.bTurn = 0
    end
    if items[2]:isBright() then
        tableParameter.bStartBanker = 1
    else
        tableParameter.bStartBanker = 0
    end

    if items[3]:isBright() then
        tableParameter.bPaoTips = 1
    else
        tableParameter.bPaoTips = 0
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        -- tableParameter.bStartTun = 0
    elseif items[2]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x8000)
    elseif items[3]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x10)
    else
        return
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        -- tableParameter.bStartTun = 0
    elseif items[2]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x04)
    elseif items[3]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x10000)
    else
        return
    end

    --单局上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bMaxLost = 0
    elseif items[2]:isBright() then
        tableParameter.bMaxLost = 100
    elseif items[3]:isBright() then
        tableParameter.bMaxLost = 300
    elseif items[4]:isBright() then
        tableParameter.bMaxLost = 600
    else
        return
    end

    --亡牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(10),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bDeathCard = 0
    elseif items[2]:isBright() then
        tableParameter.bDeathCard = 1
    else
        tableParameter.bDeathCard = 0
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(11),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHostedTime = 0
    elseif items[2]:isBright() then
        tableParameter.bHostedTime = 1
    elseif items[3]:isBright() then
        tableParameter.bHostedTime = 2
    elseif items[4]:isBright() then
        tableParameter.bHostedTime = 3
    end  

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(12),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHostedTime = 5
    end  
    tableParameter.bHostedSession = 0
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(13),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHostedSession = 1
    elseif items[2]:isBright() then
        tableParameter.bHostedSession = tableParameter.wGameCount
    elseif items[3]:isBright() then
        tableParameter.bHostedSession = 3
    end  

    tableParameter.FanXing = {}
    tableParameter.FanXing.bType = 0
    tableParameter.FanXing.bCount = 0
    tableParameter.FanXing.bAddTun = 0
    tableParameter.bLaiZiCount = 0
    tableParameter.bYiWuShi = 0
    tableParameter.bLiangPai = 0
    tableParameter.bHuType = 0
    tableParameter.bFangPao = 0
    tableParameter.bSettlement = 0
    -- tableParameter.bStartTun = 0
    tableParameter.bSocreType = 1
    --tableParameter.bMaxLost = 0

    -- tableParameter.bSiQiHong = 0
    tableParameter.bDelShuaHou = 0
    tableParameter.bHuangFanAddUp = 0
    tableParameter.bTingHuAll = 0
    --tableParameter.bDeathCard = 0
      
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

