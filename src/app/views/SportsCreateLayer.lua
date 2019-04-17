local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsCreateLayer = class("SportsCreateLayer", cc.load("mvc").ViewBase)

function SportsCreateLayer:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,self,self.EVENT_TYPE_SETTINGS_CLUB_PARAMETER)
    EventMgr:registListener(EventType.RET_SPORTS_CONFIG_LIST,self,self.RET_SPORTS_CONFIG_LIST)
    EventMgr:registListener(EventType.RET_SPORTS_CREATE,self,self.RET_SPORTS_CREATE)
end

function SportsCreateLayer:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,self,self.EVENT_TYPE_SETTINGS_CLUB_PARAMETER)
    EventMgr:unregistListener(EventType.RET_SPORTS_CONFIG_LIST,self,self.RET_SPORTS_CONFIG_LIST)
    EventMgr:unregistListener(EventType.RET_SPORTS_CREATE,self,self.RET_SPORTS_CREATE)
    
    if self.uiListView_row then
        self.uiListView_row:release()
        self.uiListView_row = nil
    end
end

function SportsCreateLayer:onCleanup()

end

function SportsCreateLayer:onCreate(parameter)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsCreateLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    self.uiListView_row = uiListView_items:getItem(0)
    self.uiListView_row:retain()
    uiListView_items:removeAllItems()
    
    local uiPanel_contents = ccui.Helper:seekWidgetByName(self.root,"Panel_contents")
    uiPanel_contents:setVisible(false)
    local uiPanel_op = ccui.Helper:seekWidgetByName(self.root,"Panel_op")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_settings"),function() 
        if self.settingsData ~= nil and self.settingsData.wKindID ~= nil then
            uiPanel_op:addChild(require("app.MyApp"):create(self.settingsData.wKindID,3):createView("RoomCreateLayer"))
        else
            uiPanel_op:addChild(require("app.MyApp"):create(25,3):createView("RoomCreateLayer"))
        end
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_create"),function() 
        self:createSports()
    end)
    local uiListView_cost = ccui.Helper:seekWidgetByName(self.root,"ListView_cost")
    local items = uiListView_cost:getItems()
    Common:addCheckTouchEventListener(items,false,function(index) self:switchCost(index) end)
    UserData.Sports:getSportsConfigList()
end

function SportsCreateLayer:RET_SPORTS_CONFIG_LIST(event)
    local data = event._usedata
    local uiListView_items = ccui.Helper:seekWidgetByName(self.root,"ListView_items")
    local uiListView = nil
    local items = uiListView_items:getItems()
    for key, var in pairs(items) do
    	if #var:getItems() < 3 then
    	   uiListView = var
    	   break
    	end
    end
    if uiListView == nil then
        uiListView = self.uiListView_row:clone()
        uiListView_items:pushBackCustomItem(uiListView)
    end
    local item = ccui.ImageView:create("common/hall_5.png")
    item.data = data
    item:setContentSize(cc.size(120,120))
    item:setTouchEnabled(true)
    item:setScale9Enabled(true)
    item:setSwallowTouches(false)
    if data.cbState == 1 then
        item:setEnabled(true)
    else
        item:setEnabled(false)
        local uiImage_switch = ccui.ImageView:create("sports/sports_52.png")
        item:addChild(uiImage_switch)
        uiImage_switch:setPosition(uiImage_switch:getParent():getContentSize().width/2,uiImage_switch:getParent():getContentSize().height/2)
    end
    
    uiListView:pushBackCustomItem(item)
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,item,"img")
    Common:addTouchEventListener(item,function() 
        local items = uiListView_items:getItems()
        for key, var in pairs(items) do
            for k, v in pairs(var:getItems()) do
                if v.data.cbState == 1 then
                    v:removeAllChildren()
                end
                if v == item and v.data.cbState == 1 then
                    local uiImage_switch = ccui.ImageView:create("sports/sports_35.png")
                    v:addChild(uiImage_switch)
                    uiImage_switch:setPosition(uiImage_switch:getParent():getContentSize().width/2,uiImage_switch:getParent():getContentSize().height/2)
                end
            end
        end
        self:switchSports(data)
    end,true)
    local items = uiListView_items:getItems()
    for key, var in pairs(items) do
        for k, v in pairs(var:getItems()) do
            if v.data.cbState == 1 then
                if v:getChildrenCount() <= 0 then
                    local uiImage_switch = ccui.ImageView:create("sports/sports_35.png")
                    v:addChild(uiImage_switch)
                    uiImage_switch:setPosition(uiImage_switch:getParent():getContentSize().width/2,uiImage_switch:getParent():getContentSize().height/2)
                    self:switchSports(data)
                end
                return
            end
        end
    end
end

function SportsCreateLayer:EVENT_TYPE_SETTINGS_CLUB_PARAMETER(event)
    local data = event._usedata
    local uiPanel_op = ccui.Helper:seekWidgetByName(self.root,"Panel_op")
    uiPanel_op:removeAllChildren()
    local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
    self.settingsData = data
    local desc = StaticData.Games[data.wKindID].name.."/1局/"..require("common.GameDesc"):getGameDesc(data.wKindID,self.settingsData.tableParameter)
    uiText_desc:setString(desc)
    local uiListView_cost = ccui.Helper:seekWidgetByName(self.root,"ListView_cost")
    local items = uiListView_cost:getItems()
    for key, var in pairs(items) do
        if var:isBright() then
    	   self:switchCost(key)
    	   return
    	end
    end
end

function SportsCreateLayer:switchSports(data)
    self.sportsData = data    
    local uiPanel_contents = ccui.Helper:seekWidgetByName(self.root,"Panel_contents")
    uiPanel_contents:setVisible(true)
    local uiImage_icon = ccui.Helper:seekWidgetByName(self.root,"Image_icon")
    Common:requestUserAvatar(data.dwItemID,data.szItemImg,uiImage_icon,"img")
    local uiText_reward = ccui.Helper:seekWidgetByName(self.root,"Text_reward")
    uiText_reward:setString(string.format("比赛奖品：%s",data.szItemName))
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    local str = "比赛时长："
    if data.dwTime == 0 then
        str = str.."不限时间"
    else
        local timeDay = math.floor(data.dwTime/86400)  
        local timeHour = math.fmod(math.floor(data.dwTime/3600), 24)  
        local timeMinute = math.fmod(math.floor(data.dwTime/60), 60)  
        local timeSecond = math.fmod(data.dwTime, 60) 
        if timeDay > 0 then
            str = str..string.format("%d天",timeDay)
        end
        if timeHour > 0 then
            str = str..string.format("%d时",timeHour)
        end
        if timeMinute > 0 then
            str = str..string.format("%d分",timeMinute)
        end
        if timeSecond > 0 then
            str = str..string.format("%d秒",timeSecond)
        end
    end
    uiText_time:setString(str)
    local uiText_condition = ccui.Helper:seekWidgetByName(self.root,"Text_condition")
    uiText_condition:setString(string.format("发起比赛金币必须达到：%s",Common:itemNumberToString(data.dwCreateCost)))
    local uiText_returnCost = ccui.Helper:seekWidgetByName(self.root,"Text_returnCost")
    uiText_returnCost:setString(string.format("比赛结束发起者奖励：%s",Common:itemNumberToString(data.dwReturnCost)))
    local uiText_number = ccui.Helper:seekWidgetByName(self.root,"Text_number")
    local uiListView_cost = ccui.Helper:seekWidgetByName(self.root,"ListView_cost")
    local items = uiListView_cost:getItems()
    for key, var in pairs(items) do
    	if var:isBright() then
           self:switchCost(key)
    	   return
    	end
    end
    items[1]:setBright(true)
    self:switchCost(1)
end

function SportsCreateLayer:switchCost(index)
    local count = 0
    local cost = 0
    if index == 1 then
        cost = 10000
    elseif index == 2 then
        cost = 20000
    elseif index == 3 then
        cost = 50000
    elseif index == 4 then
        cost = 100000
    else
        return
    end
    count = math.floor(self.sportsData.dwPrice/cost)
    if count ~= self.sportsData.dwPrice/cost then
        count = count + 1
    end
    local uiText_number = ccui.Helper:seekWidgetByName(self.root,"Text_number")
    uiText_number:setString(string.format("所需胜次：%d",count))
end

function SportsCreateLayer:createSports()
	if self.settingsData == nil then
        require("common.MsgBoxLayer"):create(0,nil,"请设置游戏玩法!")
        return
    end
    if self.sportsData == nil then
        return
    end
    if UserData.User.dwGold < self.sportsData.dwCreateCost then
        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
            require("common.MsgBoxLayer"):create(1,nil,"您的金币没有达到发起比赛条件,请前往商城充值?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
        return
    end
    local uiListView_cost = ccui.Helper:seekWidgetByName(self.root,"ListView_cost")
    local items = uiListView_cost:getItems()
    local dwCost = 0
    for key, var in pairs(items) do
        if var:isBright() then
           if key == 1 then
              dwCost = 10000
           elseif key == 2 then
              dwCost = 20000
           elseif key == 3 then
              dwCost = 50000
           elseif key == 4 then
              dwCost = 100000
           else
                
           end
           break
        end
    end
    if dwCost == 0 then
        return
    end
 
    if self.settingsData.wKindID == 15 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount)

    elseif self.settingsData.wKindID == 21 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount)
            
    elseif self.settingsData.wKindID == 20 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbw",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bTotalHuXi,self.settingsData.tableParameter.bMaxLost)

    elseif self.settingsData.wKindID == 22 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang)

    elseif self.settingsData.wKindID == 23 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,
            self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang)

    elseif self.settingsData.wKindID == 24 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,
            self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,
            self.settingsData.tableParameter.bPiaoHu,self.settingsData.tableParameter.bHongHu) 

    elseif self.settingsData.wKindID == 33 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)
    elseif self.settingsData.wKindID == 16 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bSuccessive,self.settingsData.tableParameter.bQiangHuPai,
            self.settingsData.tableParameter.bLianZhuangSocre)           
    elseif self.settingsData.wKindID == 17 or self.settingsData.wKindID == 18 or self.settingsData.wKindID == 19  or self.settingsData.wKindID == 20 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,                 
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bTotalHuXi) 
    elseif self.settingsData.wKindID == 25 or self.settingsData.wKindID == 26  then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount, self.settingsData.tableParameter.bStartCard,self.settingsData.tableParameter.bBombSeparation,self.settingsData.tableParameter.bRed10,
            self.settingsData.tableParameter.b4Add3,self.settingsData.tableParameter.bShowCardCount,self.settingsData.tableParameter.bSpringMinCount,self.settingsData.tableParameter.bAbandon,self.settingsData.tableParameter.bCheating,self.settingsData.tableParameter.bFalseSpring)
    elseif self.settingsData.wKindID == 27 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang)
    elseif self.settingsData.wKindID == 34 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bDouble)
    elseif self.settingsData.wKindID == 35 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)

    elseif self.settingsData.wKindID == 36 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)

    elseif self.settingsData.wKindID == 37 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)
            
    elseif self.settingsData.wKindID == 31 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)

    elseif self.settingsData.wKindID == 32 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,self.settingsData.tableParameter.bPlayerCountType,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,
            self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,
            self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bLimit)

    elseif self.settingsData.wKindID == 44 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bTurn,self.settingsData.tableParameter.bPaoTips,self.settingsData.tableParameter.bStartBanker)
    elseif self.settingsData.wKindID == 38 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang)

    elseif self.settingsData.wKindID == 39 then     
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang)
    elseif self.settingsData.wKindID == 40 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbd",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,self.settingsData.tableParameter.bYiWuShi,
            self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bFangPao,
            self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,self.settingsData.tableParameter.dwMingTang)
    elseif self.settingsData.wKindID == 42 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbwbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.numpep,self.settingsData.tableParameter.mailiao,self.settingsData.tableParameter.fanbei,self.settingsData.tableParameter.jiabei,self.settingsData.tableParameter.zimo,self.settingsData.tableParameter.piaohua) 
    elseif self.settingsData.wKindID == 43 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bChongFen,self.settingsData.tableParameter.bFanBei)
    elseif self.settingsData.wKindID == 45 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbb",--b
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bMaType,self.settingsData.tableParameter.bMaCount,self.settingsData.tableParameter.bQGHu,
            self.settingsData.tableParameter.bQGHuJM,self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bQingSH,self.settingsData.tableParameter.bJiePao,self.settingsData.tableParameter.bNiaoType,
            self.settingsData.tableParameter.bWuTong)--,self.settingsData.tableParameter.bQiDui
    elseif self.settingsData.wKindID == 46 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bMaType,self.settingsData.tableParameter.bMaCount,self.settingsData.tableParameter.bQGHu,self.settingsData.tableParameter.bQGHuJM,
            self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bJiePao,self.settingsData.tableParameter.mNiaoType,self.settingsData.tableParameter.bQiDui,
            self.settingsData.tableParameter.bWuTong)   
    elseif self.settingsData.wKindID == 61 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bMaType,self.settingsData.tableParameter.bMaCount,self.settingsData.tableParameter.bQGHu,self.settingsData.tableParameter.bQGHuJM,
            self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bQingSH,self.settingsData.tableParameter.bJiePao)   

    elseif self.settingsData.wKindID == 47 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bTurn)  

    elseif self.settingsData.wKindID == 48 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bTurn,self.settingsData.tableParameter.bPaoTips,self.settingsData.tableParameter.bStartBanker)  

    elseif self.settingsData.wKindID == 49 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bTurn,self.settingsData.tableParameter.bDeathCard,self.settingsData.tableParameter.bStartBanker,
            self.settingsData.tableParameter.bHuangFanAddUp,self.settingsData.tableParameter.STWK)  

    elseif self.settingsData.wKindID == 50 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bNiaoAdd,self.settingsData.tableParameter.mNiaoCount,self.settingsData.tableParameter.bLLSFlag,self.settingsData.tableParameter.bQYSFlag,
            self.settingsData.tableParameter.bWJHFlag,self.settingsData.tableParameter.bDSXFlag,self.settingsData.tableParameter.bBBGFlag,self.settingsData.tableParameter.bSTFlag,
            self.settingsData.tableParameter.bYZHFlag,self.settingsData.tableParameter.bMQFlag,self.settingsData.tableParameter.mZXFlag,self.settingsData.tableParameter.mPFFlag,
            self.settingsData.tableParameter.mZTSXlag,self.settingsData.tableParameter.bJJHFlag,self.settingsData.tableParameter.bWuTong,self.settingsData.tableParameter.mMaOne)   

    elseif self.settingsData.wKindID == 70 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bNiaoAdd,self.settingsData.tableParameter.mNiaoCount,self.settingsData.tableParameter.bLLSFlag,self.settingsData.tableParameter.bQYSFlag,
            self.settingsData.tableParameter.bWJHFlag,self.settingsData.tableParameter.bDSXFlag,self.settingsData.tableParameter.bBBGFlag,self.settingsData.tableParameter.bSTFlag,
            self.settingsData.tableParameter.bYZHFlag,self.settingsData.tableParameter.bMQFlag,self.settingsData.tableParameter.mZXFlag,self.settingsData.tableParameter.mPFFlag,
            self.settingsData.tableParameter.mZTSXlag,self.settingsData.tableParameter.bJJHFlag,self.settingsData.tableParameter.bWuTong,self.settingsData.tableParameter.mMaOne,
            self.settingsData.tableParameter.mZTLLSFlag,self.settingsData.tableParameter.mKGNPFlag)   

    elseif self.settingsData.wKindID == 51 or self.settingsData.wKindID == 55 or self.settingsData.wKindID == 56 or self.settingsData.wKindID == 57 or self.settingsData.wKindID == 58 or self.settingsData.wKindID == 59 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bBankerType,self.settingsData.tableParameter.bMultiple,self.settingsData.tableParameter.bBettingType,
            self.settingsData.tableParameter.bSettlementType,self.settingsData.tableParameter.bPush,self.settingsData.tableParameter.bNoFlower,self.settingsData.tableParameter.bCanPlayingJoin,
            self.settingsData.tableParameter.bNiuType_Flush,self.settingsData.tableParameter.bNiuType_Gourd,self.settingsData.tableParameter.bNiuType_SameColor,self.settingsData.tableParameter.bNiuType_Straight,self.settingsData.tableParameter.bCuopai)

    elseif self.settingsData.wKindID == 52 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bQGHu,self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bJiePao,self.settingsData.tableParameter.bHuQD,self.settingsData.tableParameter.bMaCount)

    elseif self.settingsData.wKindID == 53 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bBankerType,self.settingsData.tableParameter.bMultiple,self.settingsData.tableParameter.bBettingType,
            self.settingsData.tableParameter.bPush,self.settingsData.tableParameter.bCanPlayingJoin,self.settingsData.tableParameter.bExtreme,self.settingsData.tableParameter.bCuopai)     
    elseif self.settingsData.wKindID == 54 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bHuType,self.settingsData.tableParameter.bDHPlayFlag,self.settingsData.tableParameter.bDFFlag,
            self.settingsData.tableParameter.bDXPFlag,self.settingsData.tableParameter.bBTHu,self.settingsData.tableParameter.bQYMFlag,self.settingsData.tableParameter.bQDJFFlag,
            self.settingsData.tableParameter.bLLFlag,self.settingsData.tableParameter.bQYSFlag,self.settingsData.tableParameter.bZJJD,self.settingsData.tableParameter.bGSKHJB,self.settingsData.tableParameter.bQDFlag)    
    elseif self.settingsData.wKindID == 60 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbwbbbbbbbbdbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.FanXing.bType,self.settingsData.tableParameter.FanXing.bCount,self.settingsData.tableParameter.FanXing.bAddTun,
            self.settingsData.tableParameter.bPlayerCountType,self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bLaiZiCount,self.settingsData.tableParameter.bMaxLost,
            self.settingsData.tableParameter.bYiWuShi,self.settingsData.tableParameter.bLiangPai,self.settingsData.tableParameter.bCanHuXi,self.settingsData.tableParameter.bHuType,
            self.settingsData.tableParameter.bFangPao,self.settingsData.tableParameter.bSettlement,self.settingsData.tableParameter.bStartTun,self.settingsData.tableParameter.bSocreType,
            self.settingsData.tableParameter.dwMingTang,self.settingsData.tableParameter.bTurn,self.settingsData.tableParameter.bStartBanker)  
    elseif self.settingsData.wKindID == 63 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bMaType,self.settingsData.tableParameter.bMaCount,self.settingsData.tableParameter.bQGHu,
            self.settingsData.tableParameter.bQGHuJM,self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bQingSH,self.settingsData.tableParameter.bJiePao,self.settingsData.tableParameter.bNiaoType)
    elseif self.settingsData.wKindID == 65 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bMaiPiaoCount,self.settingsData.tableParameter.bDiCount,self.settingsData.tableParameter.bHuangZhuangHG)
    elseif self.settingsData.wKindID == 67 then
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_SPORTS,NetMsgId.REQ_SPORTS_CREATE,"ddbdwbbbbbbbbbbbbbbbblb",
            CHANNEL_ID,self.sportsData.dwKey,1,dwCost,self.settingsData.wKindID,self.settingsData.tableParameter.bPlayerCount,
            self.settingsData.tableParameter.bPlayerCount,self.settingsData.tableParameter.bMaType,self.settingsData.tableParameter.bMaCount,self.settingsData.tableParameter.bQGHu,
            self.settingsData.tableParameter.bQGHuJM,self.settingsData.tableParameter.bHuangZhuangHG,self.settingsData.tableParameter.bQingSH,self.settingsData.tableParameter.bJiePao,self.settingsData.tableParameter.bNiaoType,            
            self.settingsData.tableParameter.bQingYiSe,self.settingsData.tableParameter.bQiXiaoDui,self.settingsData.tableParameter.bPPHu,self.settingsData.tableParameter.bWuTong,self.settingsData.tableParameter.mPFFlag,self.settingsData.tableParameter.mDiFen,
            self.settingsData.tableParameter.mJFCount,self.settingsData.tableParameter.bLongQD)   
    else
    end
end

function SportsCreateLayer:RET_SPORTS_CREATE(event)
    local data = event._usedata
    if data.lRet == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"创建成功!")
        self:removeFromParent()
    elseif data.lRet == -2 then
        require("common.MsgBoxLayer"):create(0,nil,"创建失败!您已经创建了一场比赛正在进行中,待结束方可再次创建!")
    elseif data.lRet == -3 then
        require("common.MsgBoxLayer"):create(0,nil,"创建失败!已达到比赛场次上限!")
    elseif data.lRet == -4 then
        require("common.MsgBoxLayer"):create(0,nil,"创建失败!您尚未达到创建该比赛的金币条件!")
    else
        require("common.MsgBoxLayer"):create(0,nil,"创建失败!")
    end
end

return SportsCreateLayer

