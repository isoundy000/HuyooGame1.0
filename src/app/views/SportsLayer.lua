local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsLayer = class("SportsLayer", cc.load("mvc").ViewBase)

function SportsLayer:onEnter()
    cc.UserDefault:getInstance():setStringForKey("UserDefault_Operation","SportsLayer")
    EventMgr:registListener(EventType.RET_SPORTS_LIST,self,self.RET_SPORTS_LIST)
    EventMgr:registListener(EventType.RET_SPORTS_CREATE,self,self.RET_SPORTS_CREATE)
    EventMgr:registListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
end

function SportsLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SPORTS_LIST,self,self.RET_SPORTS_LIST)
    EventMgr:unregistListener(EventType.RET_SPORTS_CREATE,self,self.RET_SPORTS_CREATE)
    EventMgr:unregistListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
    
    if self.uiPanel_item then
        self.uiPanel_item:release()
        self.uiPanel_item = nil
    end
    
    if self.uiListView_row then
        self.uiListView_row:release()
        self.uiListView_row = nil
    end
end

function SportsLayer:onCleanup()

end

function SportsLayer:onCreate(parameter)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        cc.UserDefault:getInstance():setStringForKey("UserDefault_Operation","")
        self:removeFromParent()
    end)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    self.uiListView_row = uiListView_items:getItem(0)
    self.uiPanel_item = self.uiListView_row:getItem(0)
    self.uiPanel_item:retain()
    self.uiListView_row:removeAllItems()
    self.uiListView_row:retain()
    uiListView_items:removeAllItems()
    uiListView_items:refreshView()
    uiListView_items:jumpToTop()
    local uiText_gold = ccui.Helper:seekWidgetByName(self.root,"Text_gold")
    local dwGold = Common:itemNumberToString(UserData.User.dwGold)
    uiText_gold:setString(tostring(dwGold))
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_goldBg"),function() 
        self:addChild(require("app.MyApp"):create():createView("MallLayer"))
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_create"),function() 
        self:addChild(require("app.MyApp"):create():createView("SportsCreateLayer"))
    end)
    ccui.Helper:seekWidgetByName(self.root,"Button_create"):setVisible(false)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_rule"),function() 
        self:addChild(require("app.MyApp"):create():createView("SportsRuleLayer"))
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_join"),function() 
        self:addChild(require("app.MyApp"):create():createView("SportsMySelfLayer"))
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_reward"),function() 

        self:addChild(require("app.MyApp"):create():createView("SportsRewardLayer"))
    end)
    
    local uiListView_type = ccui.Helper:seekWidgetByName(self.root,"ListView_type")
    uiListView_type:removeItem(1)
    local items = uiListView_type:getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        uiListView_items:removeAllItems()
        local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
        uiImage_noMatch:setVisible(true)
        UserData.Sports:getSportsList(index-1)
    end)
    items[1]:setBright(true)
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(true)
    UserData.Sports:getSportsList(0)
end

function SportsLayer:SUB_CL_USER_INFO(event)
    local uiText_gold = ccui.Helper:seekWidgetByName(self.root,"Text_gold")
    local dwGold = Common:itemNumberToString(UserData.User.dwGold)
    uiText_gold:setString(tostring(dwGold))
end

function SportsLayer:RET_SPORTS_LIST(event)
    local data = event._usedata
    local uiListView_type = ccui.Helper:seekWidgetByName(self.root,"ListView_type")
    local items = uiListView_type:getItems()
    if data.cbType == 0 and items[1]:isBright() == false then
        return
    elseif data.cbType == 1 and items[2]:isBright() == false then
        return
    end
    local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
    uiImage_noMatch:setVisible(false)
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local items = uiListView_items:getItems()
    local uiListView = nil
    for key, var in pairs(items) do
        if #var:getItems() < 2 then
    		uiListView = var
    	end
    end
    if uiListView == nil then
        uiListView = self.uiListView_row:clone()
        uiListView_items:pushBackCustomItem(uiListView)
    end
    
    local item = self.uiPanel_item:clone()
    local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    local uiImage_type = ccui.Helper:seekWidgetByName(item,"Image_type")
    uiImage_type:setVisible(false)
    if data.cbType == 0 then
        uiText_name:setString(data.szItemName.."官方竞技")
    elseif data.cbType == 1 then
        uiText_name:setString(data.szItemName.."-"..data.szNickName)
    else
        uiText_name:setString(data.szItemName)
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
    uiListView:pushBackCustomItem(item)
    item:setSwallowTouches(false)
    Common:addTouchEventListener(item,function() 
        self:addChild(require("app.MyApp"):create(data):createView("SportsInfoLayer"))
    end,true)
    uiListView_items:refreshView()
    uiListView_items:jumpToTop()
    
    item:setScale(0)
    item:setAnchorPoint(cc.p(0.5,0.5))
    item:stopAllActions()
    item:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*(uiListView_items:getIndex(uiListView)*2+uiListView:getIndex(item))),cc.ScaleTo:create(0.4,1.05),cc.ScaleTo:create(0.2,1)))   
end

function SportsLayer:RET_SPORTS_CREATE(event)
    local data = event._usedata
    if data.lRet == 0 then
        local uiListView_type = ccui.Helper:seekWidgetByName(self.root,"ListView_type")
        local items = uiListView_type:getItems()
        items[1]:setBright(false)
        items[2]:setBright(true)
        local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
        uiListView_items:removeAllItems()
        local uiImage_noMatch = ccui.Helper:seekWidgetByName(self.root,"Image_noMatch")
        uiImage_noMatch:setVisible(true)
        UserData.Sports:getSportsList(1)
    end
end

return SportsLayer

