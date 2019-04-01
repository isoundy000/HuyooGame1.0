local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsInfoLayer = class("SportsInfoLayer", cc.load("mvc").ViewBase)

function SportsInfoLayer:onEnter()
    EventMgr:registListener(EventType.RET_SPORTS_LIST,self,self.RET_SPORTS_LIST)
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    EventMgr:registListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:registListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:registListener(EventType.SUB_GR_MATCH_TABLE_ING,self,self.SUB_GR_MATCH_TABLE_ING)
    EventMgr:registListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
    EventMgr:registListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
end

function SportsInfoLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SPORTS_LIST,self,self.RET_SPORTS_LIST)
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    EventMgr:unregistListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:unregistListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:unregistListener(EventType.SUB_GR_MATCH_TABLE_ING,self,self.SUB_GR_MATCH_TABLE_ING)
    EventMgr:unregistListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
    EventMgr:unregistListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
    
    if self.uiPanel_item then
        self.uiPanel_item:release()
        self.uiPanel_item = nil
    end
    
    if self.uiListView_row then
        self.uiListView_row:release()
        self.uiListView_row = nil
    end
end

function SportsInfoLayer:onCleanup()

end

function SportsInfoLayer:onCreate(parameter)
    self.data = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsInfoLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_start"),function() 
        UserData.Game:sendMsgGetRoomInfo(self.data.wKindID, 2)
    end)
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_record"),function() 
        self:addChild(require("app.MyApp"):create(self.data):createView("SportsRecordLayer"))
    end)
    ccui.Helper:seekWidgetByName(self.root,"Button_record"):setVisible(false)
    
    local uiImage_icon = ccui.Helper:seekWidgetByName(self.root,"Image_icon")
    Common:requestUserAvatar(self.data.dwItemID,self.data.szItemImg,uiImage_icon,"img")
    local uiText_name = ccui.Helper:seekWidgetByName(self.root,"Text_name")
    uiText_name:setString("奖品："..self.data.szItemName)
    local uiText_sponsor = ccui.Helper:seekWidgetByName(self.root,"Text_sponsor")
    if self.data.cbType == 0 then
        uiText_sponsor:setString("发起人：官方竞技")
    else
        uiText_sponsor:setString("发起人："..self.data.szNickName)
    end
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    local date = os.date("*t",self.data.dwTime)
    uiText_time:setString(string.format("截止时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    if os.time() + 60*5 >= self.data.dwTime then
        uiText_time:setColor(cc.c3b(255,0,0))
    end
    local uiLoadingBar_pro = ccui.Helper:seekWidgetByName(self.root,"LoadingBar_pro")
    uiLoadingBar_pro:setPercent(self.data.dwCurrentCount/self.data.dwCount*100)
    local uiText_pro = ccui.Helper:seekWidgetByName(self.root,"Text_pro")
    uiText_pro:setString(string.format("%d/%d胜次",self.data.dwCurrentCount,self.data.dwCount))
    local uiText_parameter = ccui.Helper:seekWidgetByName(self.root,"Text_parameter")
    local desc = string.format("%s/1局/%s",StaticData.Games[self.data.wKindID].name,require("common.GameDesc"):getGameDesc(self.data.wKindID,self.data.tableParameter))
    uiText_parameter:setString(desc)
    local uiText_cost = ccui.Helper:seekWidgetByName(self.root,"Text_cost")
    uiText_cost:setString(string.format("参赛费：%s金币",Common:itemNumberToString(self.data.dwCost)))
end

function SportsInfoLayer:RET_SPORTS_LIST(event)
    local data = event._usedata
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
    if data.cbType == 0 then
        uiText_name:setString(data.szItemName.."官方竞技")
    elseif data.cbType == 1 then
        uiText_name:setString(data.szItemName.."-"..data.szNickName)
    else
        uiText_name:setString(data.szItemName)
    end
    local uiText_kind = ccui.Helper:seekWidgetByName(item,"Text_kind")
    uiText_kind:setColor(cc.c3b(0,0,0))
    uiText_kind:setString(string.format("玩法    ：%s",StaticData.Games[data.wKindID].name))
    local uiText_ID = ccui.Helper:seekWidgetByName(item,"Text_ID")
    uiText_ID:setColor(cc.c3b(0,0,0))
    uiText_ID:setString(string.format("场次ID  :%d",data.dwID))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    local date = os.date("*t",data.dwTime)
    uiText_time:setString(string.format("截止时间：%d-%02d-%02d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
    local uiText_number = ccui.Helper:seekWidgetByName(item,"Text_number")
    uiText_number:setColor(cc.c3b(0,0,0))
    uiText_number:setString(string.format("我的胜次：%d",data.dwMyCount))
    local uiLoadingBar_pro = ccui.Helper:seekWidgetByName(item,"LoadingBar_pro")
    uiLoadingBar_pro:setPercent(data.dwCurrentCount/data.dwCount)
    local uiText_desc = ccui.Helper:seekWidgetByName(item,"Text_desc")
    local uiText_cost = ccui.Helper:seekWidgetByName(item,"Text_cost")
    uiText_cost:setColor(cc.c3b(0,0,0))
    uiText_cost:setString(string.format("参赛费用:%d",data.dwCost))
    uiListView:pushBackCustomItem(item)
    Common:addTouchEventListener(item,function() 
        self:addChild(require("app.MyApp"):create(data):createView("SportsInfoLayer"))
    end)
    
end

function SportsInfoLayer:SUB_CL_GAME_SERVER(event)
    local data = event._usedata
    UserData.Game:sendMsgConnectGame(data)           
end

function SportsInfoLayer:SUB_CL_GAME_SERVER_ERROR(event)
    local data = event._usedata
    require("common.MsgBoxLayer"):create(0,nil,"服务器暂未开启！")         
end

function SportsInfoLayer:EVENT_TYPE_CONNECT_GAME_FAILED(event)
    local data = event._usedata
    require("common.MsgBoxLayer"):create(0,nil,"连接游戏服失败！")
end

function SportsInfoLayer:SUB_GR_LOGON_SUCCESS(event)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_MATCH_SPORTS_TABLE,"d",self.data.dwID)
end

function SportsInfoLayer:SUB_GR_MATCH_TABLE_ING(event)
    local data = event._usedata
    require("common.SceneMgr"):switchScene(require(StaticData.Games[data.wKindID].luaGameFile):create(UserData.User.userID, data),SCENE_GAME)
end

function SportsInfoLayer:SUB_GR_MATCH_TABLE_FAILED(event)
    local data = event._usedata
    if data.wErrorCode == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"您在游戏中!")
    elseif data.wErrorCode == 1 then
        require("common.MsgBoxLayer"):create(0,nil,"游戏配置发生错误!")
    elseif data.wErrorCode == 2 then
        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
    elseif data.wErrorCode == 3 then
        require("common.MsgBoxLayer"):create(0,nil,"您的金币已超过上限，请前往更高一级匹配!")
    elseif data.wErrorCode == 4 then
        require("common.MsgBoxLayer"):create(0,nil,"房间已满,稍后再试!")
    elseif data.wErrorCode == 5 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次不存在,请重新打开竞技场,刷新比赛!")
    elseif data.wErrorCode == 6 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次比赛未开始!")
    elseif data.wErrorCode == 7 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次正在等待发放奖品!")
    elseif data.wErrorCode == 8 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次比赛已结束!")
    elseif data.wErrorCode == 9 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次已被强制中止!")
    elseif data.wErrorCode == 10 then
        require("common.MsgBoxLayer"):create(0,nil,"该场次人数已满,请换其他比赛!")
    else
        require("common.MsgBoxLayer"):create(0,nil,"未知错误,请升级版本!") 
    end
end

function SportsInfoLayer:SUB_GR_USER_ENTER(event)
    local data = event._usedata
    require("common.SceneMgr"):switchScene(require(StaticData.Games[data.wKindID].luaGameFile):create(UserData.User.userID, data),SCENE_GAME)
end

return SportsInfoLayer

