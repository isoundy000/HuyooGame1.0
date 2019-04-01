local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsRewardLayer = class("SportsRewardLayer", cc.load("mvc").ViewBase)

function SportsRewardLayer:onEnter()
    EventMgr:registListener(EventType.RET_SPORTS_REWARD_SELF_WINNING,self,self.RET_SPORTS_REWARD_SELF_WINNING)
    EventMgr:registListener(EventType.RET_SPORTS_REWARD_SELF_JOIN,self,self.RET_SPORTS_REWARD_SELF_JOIN)
    EventMgr:registListener(EventType.RET_SPORTS_REWARD_ALL,self,self.RET_SPORTS_REWARD_ALL)
end

function SportsRewardLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SPORTS_REWARD_SELF_WINNING,self,self.RET_SPORTS_REWARD_SELF_WINNING)
    EventMgr:unregistListener(EventType.RET_SPORTS_REWARD_SELF_JOIN,self,self.RET_SPORTS_REWARD_SELF_JOIN)
    EventMgr:unregistListener(EventType.RET_SPORTS_REWARD_ALL,self,self.RET_SPORTS_REWARD_ALL)
    
    if self.uiButton_item then
        self.uiButton_item:release()
        self.uiButton_item = nil
    end
end

function SportsRewardLayer:onCleanup()

end

function SportsRewardLayer:onCreate(parameter)
    if UserData.User.szPhone == "" and PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then-- 
        require("common.MsgBoxLayer"):create(1,nil,"请先实名认证,否则无法给您配送奖励",function() 
            if CHANNEL_ID ~= 20 and  CHANNEL_ID ~= 21 then 
                require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("PerfectInfoLayer"))
            else
                require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("PerfectInfoLayer_6"))
            end 
        end)
    end
    self.data = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsRewardLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    local uiImage_bg = ccui.Helper:seekWidgetByName(self.root,"Image_bg")
    uiImage_bg:setPositionX(-visibleSize.width/2)
    uiImage_bg:runAction(cc.MoveTo:create(0.2,cc.p(0,uiImage_bg:getPositionY())))
    
    Common:addTouchEventListener(self.root,function() 
        uiImage_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-visibleSize.width/2,uiImage_bg:getPositionY())),cc.CallFunc:create(function(sender,event) 
            self:removeFromParent()
        end)))
    end,true)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    self.uiButton_item = uiListView_items:getItem(0)
    self.uiButton_item:retain()
    uiListView_items:removeAllItems()
    
    local uiListView_title = ccui.Helper:seekWidgetByName(self.root,"ListView_title")
    local items = uiListView_title:getItems()
    Common:addCheckTouchEventListener(items,false,function(index) self:switch(index) end)
    items[1]:setBright(true)
    self:switch(1)
    
end

function SportsRewardLayer:switch(index)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    uiListView_items:removeAllItems()
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(true)
	if index == 2 then
        UserData.Sports:getSportsRewardSelfJoin()
	elseif index == 3 then
        UserData.Sports:getSportsRewardAll()
	else
        UserData.Sports:getSportsRewardSelfWinning()
	end
end

function SportsRewardLayer:RET_SPORTS_REWARD_SELF_WINNING(event)
    local data = event._usedata
    local uiListView_title = ccui.Helper:seekWidgetByName(self.root,"ListView_title")
    local items = uiListView_title:getItems()
    if items[1]:isBright() == false then
        return
    end
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(false)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local item = self.uiButton_item:clone()
    local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiImage_state = ccui.Helper:seekWidgetByName(item,"Image_state")
    if data.cbState == 100 then

    elseif data.cbState == 200 then
        uiImage_state:loadTexture("sports/sports_49.png")
    else
        uiImage_state:setVisible(false)
    end
    local uiText_reward = ccui.Helper:seekWidgetByName(item,"Text_reward")
    uiText_reward:setColor(cc.c3b(0,0,0))
    uiText_reward:setString(string.format("奖品：%s",data.szItemName))
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    uiText_name:setString(string.format("获奖者：%s",data.szWinnerNickName))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    local date = os.date("*t",data.dwTime)
    uiText_time:setString(string.format("获奖时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))

    uiListView_items:pushBackCustomItem(item)
--    Common:addTouchEventListener(item,function() 
--        self:addChild(require("app.MyApp"):create(data):createView("SportsRecordLayer"))
--    end,true)
end

function SportsRewardLayer:RET_SPORTS_REWARD_SELF_JOIN(event)
    local data = event._usedata
    local uiListView_title = ccui.Helper:seekWidgetByName(self.root,"ListView_title")
    local items = uiListView_title:getItems()
    if items[2]:isBright() == false then
        return
    end
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(false)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local item = self.uiButton_item:clone()
    local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiImage_state = ccui.Helper:seekWidgetByName(item,"Image_state")
    uiImage_state:setVisible(false)
    local uiText_reward = ccui.Helper:seekWidgetByName(item,"Text_reward")
    uiText_reward:setColor(cc.c3b(0,0,0))
    uiText_reward:setString(string.format("奖品：%s",data.szItemName))
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    uiText_name:setString(string.format("获奖者：%s",data.szWinnerNickName))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    local date = os.date("*t",data.dwTime)
    uiText_time:setString(string.format("获奖时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))

    uiListView_items:pushBackCustomItem(item)
--    Common:addTouchEventListener(item,function() 
--        self:addChild(require("app.MyApp"):create(data):createView("SportsRecordLayer"))
--    end,true)
end

function SportsRewardLayer:RET_SPORTS_REWARD_ALL(event)
    local data = event._usedata
    local uiListView_title = ccui.Helper:seekWidgetByName(self.root,"ListView_title")
    local items = uiListView_title:getItems()
    if items[3]:isBright() == false then
        return
    end
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(false)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local item = self.uiButton_item:clone()
    local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiImage_state = ccui.Helper:seekWidgetByName(item,"Image_state")
    uiImage_state:setVisible(false)
    local uiText_reward = ccui.Helper:seekWidgetByName(item,"Text_reward")
    uiText_reward:setColor(cc.c3b(0,0,0))
    uiText_reward:setString(string.format("奖品：%s",data.szItemName))
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    uiText_name:setString(string.format("获奖者：%s",data.szWinnerNickName))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    local date = os.date("*t",data.dwTime)
    uiText_time:setString(string.format("获奖时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    
    uiListView_items:pushBackCustomItem(item)
--    Common:addTouchEventListener(item,function() 
--        self:addChild(require("app.MyApp"):create(data):createView("SportsRecordLayer"))
--    end,true)
end

return SportsRewardLayer

