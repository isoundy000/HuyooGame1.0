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
    local csb = cc.CSLoader:createNode("RoomCreateLayer54.csb")
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
    --选择胡牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bHuType"] ~= nil and self.recordCreateParameter["bHuType"] == 1 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
--    items[2]:setBright(false)
--    items[2]:setEnabled(false)
--    items[2]:setColor(cc.c3b(170,170,170))
-- 
    --选择玩法
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)

    --报听胡
    if self.recordCreateParameter["bBTHu"] ~= nil and self.recordCreateParameter["bBTHu"] == 0 then
        items[1]:setBright(false)
    else
        items[1]:setBright(true)
    end    
    --清一色
    if self.recordCreateParameter["bQYSFlag"] ~= nil and self.recordCreateParameter["bQYSFlag"] == 1 then
        items[2]:setBright(true)
    else
        items[2]:setBright(false)
    end    
    --杠上花加倍
    if self.recordCreateParameter["bGSKHJB"] ~= nil and self.recordCreateParameter["bGSKHJB"] == 0 then
        items[3]:setBright(false)
    else
        items[3]:setBright(true)
    end


    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    --带下跑
    if self.recordCreateParameter["bDXPFlag"] ~= nil and self.recordCreateParameter["bDXPFlag"] == 1 then
        items[1]:setBright(true)
    else
        items[1]:setBright(false)
    end
    --连六
    if self.recordCreateParameter["bLLFlag"] ~= nil and self.recordCreateParameter["bLLFlag"] == 1 then
        items[2]:setBright(true)
    else
        items[2]:setBright(false)
    end

    --庄家加倍
    if self.recordCreateParameter["bZJJD"] ~= nil and self.recordCreateParameter["bZJJD"] == 1 then
        items[3]:setBright(true)
    else
        items[3]:setBright(false)
    end
    
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true,function(index) 
        if index == 4 then       
            local target = items[index]
            if target:isBright() then
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(255,255,255))
                    var:setEnabled(true)
                    if self.recordCreateParameter["bQDJFFlag"] ~= nil and self.recordCreateParameter["bQDJFFlag"] == 0 then
                        items[2]:setBright(true)
                    else
                        items[1]:setBright(true)
                    end
                end
            else
                local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
                for key, var in pairs(items) do
                    var:setColor(cc.c3b(170,170,170))
                    var:setEnabled(false)
                    var:setBright(false)
                end 
            end
        end
    end)
    --不带风
    if self.recordCreateParameter["bDFFlag"] ~= nil and self.recordCreateParameter["bDFFlag"] == 0 then
        items[1]:setBright(false)
    else
        items[1]:setBright(true)
    end
    --缺一门
    if self.recordCreateParameter["bQYMFlag"] ~= nil and self.recordCreateParameter["bQYMFlag"] == 0 then
        items[2]:setBright(false)
    else
        items[2]:setBright(true)
    end
    --不带混
    if self.recordCreateParameter["bDHPlayFlag"] ~= nil and self.recordCreateParameter["bDHPlayFlag"] == 0 then
        items[3]:setBright(false)
    else
        items[3]:setBright(true)
    end
    
    --七对
    if self.recordCreateParameter["bDHPlayFlag"] ~= nil and self.recordCreateParameter["bQDFlag"] == 0 then
        items[4]:setBright(false)
    else
        items[4]:setBright(true)
    end
    

    --选择七对   tableParameter.bQDFBFlag = 0   --加分
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bQDFlag"] == 0  then
        for key, var in pairs(items) do
            var:setColor(cc.c3b(170,170,170))
            var:setEnabled(false)
            var:setBright(false)
        end 
    elseif self.recordCreateParameter["bQDJFFlag"] ~= nil and self.recordCreateParameter["bQDJFFlag"] == 0 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
--    items[2]:setBright(false)
--    items[2]:setEnabled(false)
--    items[2]:setColor(cc.c3b(170,170,170))
 
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
                uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount))   
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
--    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
--    if items[1]:isBright() then
        tableParameter.bPlayerCount = 4
--    elseif items[2]:isBright() then
--        tableParameter.bPlayerCount = 3
--    elseif items[3]:isBright() then
--        tableParameter.bPlayerCount = 2
--    else
--        return
--    end
    --选择胡牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bHuType = 0
    elseif items[2]:isBright() then
        tableParameter.bHuType = 1
    else
        return
    end

    --选择玩法
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    --报听胡
    if items[1]:isBright() then
        tableParameter.bBTHu = 1
    else
        tableParameter.bBTHu = 0
    end
    --清一色
    if items[2]:isBright() then
        tableParameter.bQYSFlag = 1
    else
        tableParameter.bQYSFlag = 0
    end
    --杠上花加倍
    if items[3]:isBright() then
        tableParameter.bGSKHJB = 1
    else
        tableParameter.bGSKHJB = 0
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    --带下跑
    if items[1]:isBright() then
        tableParameter.bDXPFlag = 1
    else
        tableParameter.bDXPFlag = 0
    end
    --连六
    if items[2]:isBright() then
        tableParameter.bLLFlag = 1
    else
        tableParameter.bLLFlag = 0
    end

    --庄家加倍
    if items[3]:isBright() then
        tableParameter.bZJJD = 1
    else
        tableParameter.bZJJD = 0
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    --不带风
    if items[1]:isBright() then
        tableParameter.bDFFlag = 1
    else
        tableParameter.bDFFlag = 0
    end  
    --缺一门
    if items[2]:isBright() then
        tableParameter.bQYMFlag = 1
    else
        tableParameter.bQYMFlag = 0
    end  
    --不带混
    if items[3]:isBright() then
        tableParameter.bDHPlayFlag = 1
    else
        tableParameter.bDHPlayFlag = 0
    end

    --七对
    if items[4]:isBright() then
        tableParameter.bQDFlag = 1
    else
        tableParameter.bQDFlag = 0
    end
    
    --选择七对
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bQDJFFlag = 1   --0加分  1加倍
    elseif items[2]:isBright() then
        tableParameter.bQDJFFlag = 0
    else
        tableParameter.bQDJFFlag = 0
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
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足,请前往商城购买？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
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

