local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsRecordLayer = class("SportsRecordLayer", cc.load("mvc").ViewBase)

function SportsRecordLayer:onEnter()
    EventMgr:registListener(EventType.RET_SPORTS_USER_LIST,self,self.RET_SPORTS_USER_LIST)
    
end

function SportsRecordLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SPORTS_USER_LIST,self,self.RET_SPORTS_USER_LIST)
    
    if self.uiImage_item then
        self.uiImage_item:release()
        self.uiImage_item = nil
    end
end

function SportsRecordLayer:onCleanup()

end

function SportsRecordLayer:onCreate(parameter)
    self.data = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsRecordLayer.csb")
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
    self.uiImage_item = uiListView_items:getItem(0)
    self.uiImage_item:retain()
    uiListView_items:removeAllItems()
    
    local uiImage_icon = ccui.Helper:seekWidgetByName(self.root,"Image_icon")
    Common:requestUserAvatar(self.data.dwItemID,self.data.szItemImg,uiImage_icon,"img")
    local uiText_reward = ccui.Helper:seekWidgetByName(self.root,"Text_reward")
    uiText_reward:setString(string.format("奖品  ：%s",self.data.szItemName))
    local uiText_name = ccui.Helper:seekWidgetByName(self.root,"Text_name")
    uiText_name:setString(string.format("场次ID：%s",self.data.dwID))
    local uiText_myNumber = ccui.Helper:seekWidgetByName(self.root,"Text_myNumber")
    uiText_myNumber:setString("0")
    local uiText_winner = ccui.Helper:seekWidgetByName(self.root,"Text_winner")
    if self.data.cbState == 1 then
        uiText_winner:setString("状态  ：正在进行...")
    elseif self.data.cbState == 100 or self.data.cbState == 200 then
        uiText_winner:setString(string.format("获奖者  ：%s",self.data.szWinnerNickName))
    else
        uiText_winner:setString("状态  ：已结束")
    end
    
    UserData.Sports:getSportsUserList(self.data.dwID)
end

function SportsRecordLayer:RET_SPORTS_USER_LIST(event)
    local data = event._usedata
    if data.dwID ~= self.data.dwID then
        return
    end
    
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local item = self.uiImage_item:clone()
    local uiImage_avatar = ccui.Helper:seekWidgetByName(item,"Image_avatar")
    Common:requestUserAvatar(data.dwUserID,data.szLogoInfo,uiImage_avatar,"img")
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    uiText_name:setString(string.format("昵称：%s",data.szNickName))
    local uiText_id = ccui.Helper:seekWidgetByName(item,"Text_id")
    uiText_id:setColor(cc.c3b(0,0,0))
    uiText_id:setString(string.format("ID  ：%d",data.dwUserID))
    local uiText_number = ccui.Helper:seekWidgetByName(item,"Text_number")
    uiText_number:setColor(cc.c3b(0,0,0))
    uiText_number:setString(string.format("胜次：%d",data.dwMyCount))
    uiListView_items:pushBackCustomItem(item)
    
    if data.dwUserID == UserData.User.userID then
        local uiText_myNumber = ccui.Helper:seekWidgetByName(self.root,"Text_myNumber")
        uiText_myNumber:setString(string.format("%d",data.dwMyCount))
    end
end

return SportsRecordLayer

