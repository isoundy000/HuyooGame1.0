local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local NetMsgId = require("common.NetMsgId")
local NetMsgId = require("common.NetMsgId")
local NetMgr = require("common.NetMgr")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local EventType = require("common.EventType")
local GameDesc = require("common.GameDesc")

local ProxyLayer = class("ProxyLayer", cc.load("mvc").ViewBase)

function ProxyLayer:onEnter()
    EventMgr:registListener(EventType.RET_SC_SUB_GET_PROXY_TABLE,self,self.RET_SC_SUB_GET_PROXY_TABLE)
end

function ProxyLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SC_SUB_GET_PROXY_TABLE,self,self.RET_SC_SUB_GET_PROXY_TABLE)
    
    if self.uiPanel_guildInfo then
        self.uiPanel_guildInfo:release()
        self.uiPanel_guildInfo = nil
    end
    if self.uiPanel_myGameItem then
        self.uiPanel_myGameItem:release()
        self.uiPanel_myGameItem = nil
    end
    
end

function ProxyLayer:onCreate(parames)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("ProxyLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb

    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        require("common.SceneMgr"):switchOperation()
    end)
    self.GameNum = 0 
--    local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
--    local items = uiListView_function:getItems()
--    for key, var in pairs(items) do
--        Common:addTouchEventListener(var,function() 
--            self:showUI(key)
--        end)
--    end
    --我的游戏
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_refresh"),function() 
        --刷新游戏
        self.GameNum = 0 
        self:showUI(1)
    end)
    self.uiPanel_myGameItem = ccui.Helper:seekWidgetByName(self.root,"Panel_myGameItem")
    self.uiPanel_myGameItem:retain()
    local uiListView_myGame = ccui.Helper:seekWidgetByName(self.root,"ListView_myGame")
    uiListView_myGame:removeAllItems()
    
    --代开房记录
    self:showUI(1)
end

function ProxyLayer:showUI(index)
--    local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
--    local items = uiListView_function:getItems()
--    for key, var in pairs(items) do
--    	var:setBright(false)
--    end
    local uiPanel_myGame = ccui.Helper:seekWidgetByName(self.root,"Panel_myGame") 
    uiPanel_myGame:setVisible(true)
    local uiPanel_NoGame = ccui.Helper:seekWidgetByName(self.root,"Panel_NoGame")
    uiPanel_NoGame:setVisible(true)
    local uiText_item = ccui.Helper:seekWidgetByName(self.root,"Text_item")
    uiText_item:setString(string.format("%d/4",self.GameNum))
--    items[1]:setBright(true)   
    local uiListView_myGame = ccui.Helper:seekWidgetByName(self.root,"ListView_myGame")
    uiListView_myGame:removeAllItems()
    UserData.Record:sendMsgGetProxyRoomTable()
    UserData.User:sendMsgUpdateUserInfo(1)    
end

function ProxyLayer:RET_SC_SUB_GET_PROXY_TABLE(event)
    if event ~= nil then 
        self.GameNum = self.GameNum + 1
    end    
    local uiPanel_NoGame = ccui.Helper:seekWidgetByName(self.root,"Panel_NoGame")
    uiPanel_NoGame:setVisible(false)
    local data = event._usedata
    local wKindID = math.floor(data.dwTableID/10000)
    local uiListView_myGame = ccui.Helper:seekWidgetByName(self.root,"ListView_myGame")
    local item = self.uiPanel_myGameItem:clone()
    uiListView_myGame:pushBackCustomItem(item)
    local uiText_tableID = ccui.Helper:seekWidgetByName(item,"Text_tableID")
    uiText_tableID:setString(string.format("%d",data.dwTableID))
    uiText_tableID:setColor(cc.c3b(0,0,0))
    local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
    uiText_name:setColor(cc.c3b(0,0,0))
    uiText_name:setString(StaticData.Games[wKindID].name)
    local uiText_gameCount = ccui.Helper:seekWidgetByName(item,"Text_gameCount")
    uiText_gameCount:setColor(cc.c3b(0,0,0))
    uiText_gameCount:setString(string.format("%d/%d局",data.wCurrentGameCount,data.wGameCount))
    local uiText_time = ccui.Helper:seekWidgetByName(item,"Text_time")
    uiText_time:setColor(cc.c3b(0,0,0))
    if data.dwCreateTableTime > 0 and data.bIsGameStart ~= true then
        uiText_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function(sender,event) 
                if data.dwCreateTableTime <= 0 then
                    uiText_time:stopAllActions()
                    self.GameNum = 0 
                    self:showUI(1)
                else
                    uiText_time:setString(string.format("%02d:%02d",math.floor(data.dwCreateTableTime/60),data.dwCreateTableTime%60))
                    data.dwCreateTableTime = data.dwCreateTableTime - 1
                    if data.dwCreateTableTime < 0 then
                        data.dwCreateTableTime = 0
                    end
                end
            end),
            cc.DelayTime:create(1)
        )))
    else
        uiText_time:setString("0")
    end
    local uiText_playerCount = ccui.Helper:seekWidgetByName(item,"Text_playerCount")
    uiText_playerCount:setColor(cc.c3b(0,0,0))
    uiText_playerCount:setString(string.format("%d/%d人",data.wCurrentChairCount,data.wChairCount))
    local uiText_player = ccui.Helper:seekWidgetByName(item,"Text_player")
    uiText_player:setColor(cc.c3b(0,0,0))
    uiText_player:setString(GameDesc:getGameDesc(wKindID,data.tableParameter))
    local size = cc.size(520.42,73.32)
    uiText_player:ignoreContentAdaptWithSize(false)
    uiText_player:setContentSize(size)
    uiText_player:setTextAreaSize(size)
    local uiImage_start = ccui.Helper:seekWidgetByName(item,"Image_start")
    local uiListView_op = ccui.Helper:seekWidgetByName(item,"ListView_op")
    if data.bIsGameStart == true then
        uiImage_start:setVisible(true)
        uiListView_op:setVisible(false)
    else
        uiImage_start:setVisible(false)
        uiListView_op:setVisible(true)
        local items = uiListView_op:getItems()
        for key, var in pairs(items) do
        	Common:addTouchEventListener(var,function() 
                local uiPanel_op = ccui.Helper:seekWidgetByName(self.root,"Panel_op")
                uiPanel_op:stopAllActions()
                uiPanel_op:removeAllChildren()
    	        if key == 1 then
    	            --解散
                    uiPanel_op:addChild(require("app.MyApp"):create(data.dwTableID):createView("ProxyDisbandedLayer")) 
                    uiPanel_op:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                            self.GameNum = 0 
                            self:showUI(1)
                        end)))
                elseif key == 2 then
                    --邀请
                    uiPanel_op:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                        self.GameNum = 0 
                        self:showUI(1)
                    end))) 
--                    local dataShare = 
--                    if dataShare then
--                        UserData.Share:doShare(dataShare.dwIndexID,
--                            string.format("[%s]房号:%d,%d局",StaticData.Games[wKindID].name,data.dwTableID,data.wGameCount),
--                            GameDesc:getGameDesc(wKindID,data.tableParameter,{nTableType = TableType_HelpRoom}).." (点击加入游戏)",
--                            string.format("%s&Account=%s&channelID=%d",data.szShareUrl,UserData.User.szAccount,CHANNEL_ID),
--                            "")
--                    end
                elseif key == 3 then
                    --加入
                    uiPanel_op:addChild(require("app.MyApp"):create(data.dwTableID):createView("RoomJoinLayer"))
                    uiPanel_op:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                        self.GameNum = 0 
                        self:showUI(1)
                    end))) 
        	    end
        	end)
        end
    end  
    local uiText_item = ccui.Helper:seekWidgetByName(self.root,"Text_item")
    uiText_item:setString(string.format("%d/4",self.GameNum))
               
end

return ProxyLayer