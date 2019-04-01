local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsMySelfLayer = class("SportsMySelfLayer", cc.load("mvc").ViewBase)

function SportsMySelfLayer:onEnter()
    EventMgr:registListener(EventType.RET_SPORTS_LIST_BY_USER_ID,self,self.RET_SPORTS_LIST_BY_USER_ID)
end

function SportsMySelfLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SPORTS_LIST_BY_USER_ID,self,self.RET_SPORTS_LIST_BY_USER_ID)
    
    if self.uiButton_item then
        self.uiButton_item:release()
        self.uiButton_item = nil
    end
end

function SportsMySelfLayer:onCleanup()

end

function SportsMySelfLayer:onCreate(parameter)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsMySelfLayer.csb")
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
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(true)
    UserData.Sports:getMySportsList()
end

function SportsMySelfLayer:RET_SPORTS_LIST_BY_USER_ID(event)
    local data = event._usedata
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(false)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local items = uiListView_items:getItems()
    local item = self.uiButton_item:clone()
    local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    local uiImage_type = ccui.Helper:seekWidgetByName(item,"Image_type")
    if data.cbType == 0 then
        uiText_name:setString(data.szItemName.."官方竞技")
    elseif data.cbType == 1 then
        uiText_name:setString(data.szItemName.."-"..data.szNickName)
        uiImage_type:loadTexture("sports/sports_001.png")
    else
        uiText_name:setString(data.szItemName)
        uiImage_type:setVisible(false)
    end
    local uiText_kind = ccui.Helper:seekWidgetByName(item,"Text_kind")
    uiText_kind:setColor(cc.c3b(0,0,0))
    uiText_kind:setString(string.format("玩法    : %s",StaticData.Games[data.wKindID].name))
    local uiText_ID = ccui.Helper:seekWidgetByName(item,"Text_ID")
    uiText_ID:setColor(cc.c3b(0,0,0))
    uiText_ID:setString(string.format("场次ID  : %d",data.dwID))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    local date = os.date("*t",data.dwTime)
    uiText_time:setString(string.format("截止时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    if os.time() + 60*5 >= data.dwTime then
        uiText_time:setColor(cc.c3b(255,0,0))
    end
    local uiText_number = ccui.Helper:seekWidgetByName(item,"Text_number")
    if data.dwMyCount > 0 then
        uiText_number:setColor(cc.c3b(255,0,0))
    else
        uiText_number:setColor(cc.c3b(0,0,0))
    end
    uiText_number:setString(string.format("我的胜次：%d",data.dwMyCount))
    local uiText_desc = ccui.Helper:seekWidgetByName(item,"Text_desc")
    local uiText_cost = ccui.Helper:seekWidgetByName(item,"Text_cost")
    uiText_cost:setColor(cc.c3b(0,0,0))
    if data.dwCost == 0 then
        uiText_cost:setString("参赛费用: 免费")
    else
        uiText_cost:setString(string.format("参赛费用: %s",Common:itemNumberToString(data.dwCost)))
    end
    local uiLoadingBar_pro = ccui.Helper:seekWidgetByName(item,"LoadingBar_pro")
    uiLoadingBar_pro:setPercent(data.dwCurrentCount/data.dwCount*100)
    local uiText_pro = ccui.Helper:seekWidgetByName(item,"Text_pro")
    uiText_pro:setColor(cc.c3b(0,0,0))
    uiText_pro:setString(string.format("%d/%d胜次",data.dwCurrentCount,data.dwCount))
    uiListView_items:pushBackCustomItem(item)
    item:setSwallowTouches(false)
    Common:addTouchEventListener(item,function() 
        self:addChild(require("app.MyApp"):create(data):createView("SportsInfoLayer"))
    end,true)
    
end

return SportsMySelfLayer

