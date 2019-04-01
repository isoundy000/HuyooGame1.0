local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Default = require("common.Default")
local Bit = require("common.Bit")
local GoldGameLayer = class("GoldGameLayer", cc.load("mvc").ViewBase)

function GoldGameLayer:onEnter()
    cc.UserDefault:getInstance():setStringForKey("UserDefault_Operation","GoldGameLayer")
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    EventMgr:registListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
    EventMgr:registListener(EventType.SUB_CL_GOLDROOM_CONFIG,self,self.SUB_CL_GOLDROOM_CONFIG)
    EventMgr:registListener(EventType.SUB_CL_GOLDROOM_CONFIG_END,self,self.SUB_CL_GOLDROOM_CONFIG_END)
    EventMgr:registListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:registListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:registListener(EventType.SUB_GR_MATCH_TABLE_ING,self,self.SUB_GR_MATCH_TABLE_ING)
    EventMgr:registListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
    EventMgr:registListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
end

function GoldGameLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    EventMgr:unregistListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
    EventMgr:unregistListener(EventType.SUB_CL_GOLDROOM_CONFIG,self,self.SUB_CL_GOLDROOM_CONFIG)
    EventMgr:unregistListener(EventType.SUB_CL_GOLDROOM_CONFIG_END,self,self.SUB_CL_GOLDROOM_CONFIG_END)
    EventMgr:unregistListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:unregistListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:unregistListener(EventType.SUB_GR_MATCH_TABLE_ING,self,self.SUB_GR_MATCH_TABLE_ING)
    EventMgr:unregistListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
    EventMgr:unregistListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
end

function GoldGameLayer:onCleanup()

end

function GoldGameLayer:onCreate(parameter)
    NetMgr:getGameInstance():closeConnect()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GoldGameLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function(sender,event) 
        cc.UserDefault:getInstance():setStringForKey("UserDefault_Operation","")
        self:removeFromParent()
    end)

    local uiText_roomCard = ccui.Helper:seekWidgetByName(self.root,"Text_roomCard")
    local dwGold = Common:itemNumberToString(UserData.User.dwGold)
    uiText_roomCard:setString(tostring(dwGold)) 
    local uiButton_roomCardBg = ccui.Helper:seekWidgetByName(self.root,"Button_roomCardBg")    
    Common:addTouchEventListener(uiButton_roomCardBg,function()      
        if StaticData.Hide[CHANNEL_ID].btn9 == 1 and  CHANNEL_ID ~= 16 and  CHANNEL_ID ~= 17 then  
            require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(1):createView("MallLayer")) 
        else 
            require("common.MsgBoxLayer"):create(2,nil,"请联系代理!")
        end 
    end)

    local uiImage_title = ccui.Helper:seekWidgetByName(self.root,"Image_title")
    local uiListView_gameTypeBtn = ccui.Helper:seekWidgetByName(self.root,"ListView_gameTypeBtn")
    local uiListView_games = ccui.Helper:seekWidgetByName(self.root,"ListView_games")
--    local uiButton_zipai = ccui.Helper:seekWidgetByName(self.root,"Button_zipai")
--    local uiButton_majiang = ccui.Helper:seekWidgetByName(self.root,"Button_majiang")
--    local uiButton_puke = ccui.Helper:seekWidgetByName(self.root,"Button_puke")
--    local uiButton_Recentlyoftenplay = ccui.Helper:seekWidgetByName(self.root,"Button_Recentlyoftenplay")--最近常玩
    local regionID = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_RegionID,0)
    local locationID = parameter[1]
    
    local uiButton_zipai = ccui.Helper:seekWidgetByName(self.root,"Button_zipai")    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("room/paohuziyeqiandonghua/paohuziyeqiandonghua.ExportJson")
    local armature1=ccs.Armature:create("paohuziyeqiandonghua")
    armature1:getAnimation():playWithIndex(0)
    uiButton_zipai:addChild(armature1)
    armature1:setPosition(armature1:getParent():getContentSize().width/2,armature1:getParent():getContentSize().height/2)

    local uiButton_majiang = ccui.Helper:seekWidgetByName(self.root,"Button_majiang")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("room/majiangyeqiandonghua/majiangyeqiandonghua.ExportJson")
    local armature2=ccs.Armature:create("majiangyeqiandonghua")
    armature2:getAnimation():playWithIndex(0)
    uiButton_majiang:addChild(armature2)
    armature2:setPosition(armature2:getParent():getContentSize().width/2,armature2:getParent():getContentSize().height/2)

    local uiButton_puke = ccui.Helper:seekWidgetByName(self.root,"Button_puke")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("room/pukeyeqiandonghua/pukeyeqiandonghua.ExportJson")
    local armature3=ccs.Armature:create("pukeyeqiandonghua")
    armature3:getAnimation():playWithIndex(0)
    uiButton_puke:addChild(armature3)
    armature3:setPosition(armature3:getParent():getContentSize().width/2,armature3:getParent():getContentSize().height/2)

    local uiButton_Recentlyoftenplay = ccui.Helper:seekWidgetByName(self.root,"Button_Recentlyoftenplay")--最近常玩
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("room/zuijinchangwanyeqiantexiao/zuijinchangwanyeqiantexiao.ExportJson")
    local armature4=ccs.Armature:create("zuijinchangwanyeqiantexiao")
    armature4:getAnimation():playWithIndex(0)
    uiButton_Recentlyoftenplay:addChild(armature4)
    armature4:setPosition(armature4:getParent():getContentSize().width/2,armature4:getParent():getContentSize().height/2)
    
    if locationID == nil then
        locationID = UserData.Game.talbeCommonGames[1]
    end
    local function showGameType(type)
        if type == 1 then
            uiImage_title:setVisible(false)
            uiListView_gameTypeBtn:setVisible(true)
            uiButton_zipai:setBright(true)
            uiButton_majiang:setBright(false)
            uiButton_puke:setBright(false)
            uiButton_Recentlyoftenplay:setBright(false)
            armature1:setVisible(true)
            armature2:setVisible(false)
            armature3:setVisible(false)
            armature4:setVisible(false)  
        elseif type == 2 then
            uiImage_title:setVisible(false)
            uiListView_gameTypeBtn:setVisible(true)
            uiButton_zipai:setBright(false)
            uiButton_majiang:setBright(false)
            uiButton_puke:setBright(true)
            uiButton_Recentlyoftenplay:setBright(false)
            armature1:setVisible(false)
            armature2:setVisible(false)
            armature3:setVisible(true)
            armature4:setVisible(false) 
        elseif type == 3 then
            uiImage_title:setVisible(false)
            uiListView_gameTypeBtn:setVisible(true)
            uiButton_zipai:setBright(false)
            uiButton_majiang:setBright(true)
            uiButton_puke:setBright(false)
            uiButton_Recentlyoftenplay:setBright(false)
            armature1:setVisible(false)
            armature2:setVisible(true)
            armature3:setVisible(false)
            armature4:setVisible(false) 
        elseif type == 4 then
            uiImage_title:setVisible(false)
            uiListView_gameTypeBtn:setVisible(true)
            uiButton_zipai:setBright(false)
            uiButton_majiang:setBright(false)
            uiButton_puke:setBright(false)
            uiButton_Recentlyoftenplay:setBright(true)
            armature1:setVisible(false)
            armature2:setVisible(false)
            armature3:setVisible(false)
            armature4:setVisible(true) 
        else
            uiImage_title:setVisible(true)
            uiListView_gameTypeBtn:setVisible(false)
        end
        uiListView_games:removeAllItems()
        local games = {}
        if type == 4 then
            games = clone(UserData.Game.talbeCommonGames)
        else
            games = clone(UserData.Game.tableSortGames)
        end 
        local isFound = false
        for key, var in pairs(games) do
            local wKindID = tonumber(var)
            local data = StaticData.Games[wKindID]
            if UserData.Game.tableGames[wKindID] ~= nil and Bit:_and(data.friends,2) ~= 0 and (type == 4 or data.type == type) then
                local item = ccui.Button:create(data.icon1,data.icons1,data.icons)
                -- item:setScale(0.9)
                item.wKindID = wKindID
                item:setBright(false)
                uiListView_games:pushBackCustomItem(item)
                Common:addTouchEventListener(item,function() self:showGameParameter(wKindID) end)
                if wKindID == locationID then
                    isFound = true
                end
            end 
        end
        if isFound == true then
            local btn = self:showGameParameter(locationID)
            if btn ~= nil then
                btn:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event)
                    --位置刷新
                    uiListView_games:refreshView()
                    local container = uiListView_games:getInnerContainer()
                    local pos = cc.p(btn:getPosition())
                    pos = cc.p(btn:getParent():convertToWorldSpace(pos))
                    pos = cc.p(container:convertToNodeSpace(pos))
                    local value = (1-pos.y/container:getContentSize().height)*100
                    uiListView_games:scrollToPercentVertical(value,1,true)
                end)))
            end
        else
            local item = uiListView_games:getItem(0)
            if item ~= nil then
                self:showGameParameter(item.wKindID)
            end
        end
    end
    Common:addTouchEventListener(uiButton_zipai,function() showGameType(1) end)
    Common:addTouchEventListener(uiButton_puke,function() showGameType(2) end)
    Common:addTouchEventListener(uiButton_majiang,function() showGameType(3) end)
    Common:addTouchEventListener(uiButton_Recentlyoftenplay,function() showGameType(4) end)
    for i = 1 , 3 do
        local uiButton_roomTypeInfo = ccui.Helper:seekWidgetByName(self.root,string.format("Button_roomTypeInfo%d",i))
        Common:addTouchEventListener(uiButton_roomTypeInfo,function() 
            local data = uiButton_roomTypeInfo.data
            if data == nil then
                require("common.MsgBoxLayer"):create(0,nil,"游戏房间暂未开放!")
                return
            elseif UserData.User.dwGold < data.dwMinScore then
                require("common.MsgBoxLayer"):create(2,nil,"您的金币不足,请前往商城充值!",function() 
                    require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("MallLayer"))
                end)
                return
            elseif UserData.User.dwGold > data.dwMaxScore and data.dwMaxScore ~= 0 then
                require("common.MsgBoxLayer"):create(0,nil,"您的金币已超过上限，请前往更高一级匹配")
                return               
            end
            self.cbLevel = data.cbLevel
            UserData.Game:sendMsgGetRoomInfo(data.wKindID, 1)
        end)
    end
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_roomTypeInfo0"),function()
        local isHave = false
        for i = 3 , 1, -1 do
            local uiButton_roomTypeInfo = ccui.Helper:seekWidgetByName(self.root,string.format("Button_roomTypeInfo%d",i))
            local data = uiButton_roomTypeInfo.data
            if data ~= nil then
                isHave = true
            end
            if data ~= nil and UserData.User.dwGold >= data.dwMinScore and (UserData.User.dwGold <= data.dwMaxScore or data.dwMaxScore == 0) then
                self.cbLevel = data.cbLevel
                UserData.Game:sendMsgGetRoomInfo(data.wKindID, 1)
                return
            end
        end
        if isHave == false then
            require("common.MsgBoxLayer"):create(0,nil,"休闲场暂未开放!") 
            return  
        else
            require("common.MsgBoxLayer"):create(2,nil,"您的金币不足,请前往商城充值!",function() 
                require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("MallLayer"))
            end)
            return         
        end       
    end)
    if  #UserData.Game.tableSortGames <= 5 then 
        showGameType()
    else
        if locationID == nil then
            showGameType(1)
        else
            showGameType(StaticData.Games[locationID].type)
        end
    end
end

function GoldGameLayer:showGameParameter(wKindID)
    local uiListView_games = ccui.Helper:seekWidgetByName(self.root,"ListView_games")
    local items = uiListView_games:getItems()
    local node = nil
    for key, var in pairs(items) do
        if var.wKindID == wKindID then
            if var:isBright() then
                return nil
            end
            node = var
            var:setBright(true)
        else
            var:setBright(false)
        end
    end       
    self.wKindID = wKindID
    self.tableFriendsRoomParams = nil    
    local uiPanel_parameter = ccui.Helper:seekWidgetByName(self.root,"Panel_parameter") 
    local uiImage_8zi = ccui.Helper:seekWidgetByName(uiPanel_parameter,"Image_8zi")
    uiImage_8zi:loadTexture(StaticData.Games[self.wKindID].icon8)
    local uiText_Therules = ccui.Helper:seekWidgetByName(uiPanel_parameter,"Text_Therules")
    uiText_Therules:setString(StaticData.Games[self.wKindID].rules)
    for i = 1 , 3 do
        local uiButton_roomTypeInfo = ccui.Helper:seekWidgetByName(self.root,string.format("Button_roomTypeInfo%d",i))
        local uiText_info = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"Text_info")
        local uiAtlasLabel_rate = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"AtlasLabel_rate")
        local uiImage_rate = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"Image_rate")
        uiText_info:setString("暂未开放")
        uiAtlasLabel_rate:setVisible(false)
        uiImage_rate:setVisible(false)
        uiButton_roomTypeInfo.data = nil
    end
    UserData.Game:sendMsgGetGoldRoomParam(wKindID)     
    for i = 1 , 3 do
        local uiButton_roomTypeInfo = ccui.Helper:seekWidgetByName(self.root,string.format("Button_roomTypeInfo%d",i))
        uiButton_roomTypeInfo:setScale(0)
        uiButton_roomTypeInfo:stopAllActions()
        uiButton_roomTypeInfo:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(i-1)),cc.ScaleTo:create(0.4,1.1),cc.ScaleTo:create(0.2,1)))             
    end      
    return node
end

--刷新房间信息
function GoldGameLayer:SUB_CL_GOLDROOM_CONFIG(event)
    local data = event._usedata
    if data.wKindID ~= self.wKindID then
        return
    end
    if self.tableFriendsRoomParams == nil then
        self.tableFriendsRoomParams = {}
    end
    self.tableFriendsRoomParams[data.cbLevel] = data
end

function GoldGameLayer:SUB_CL_GOLDROOM_CONFIG_END(event)
    for i = 1 , 3 do
        local uiButton_roomTypeInfo = ccui.Helper:seekWidgetByName(self.root,string.format("Button_roomTypeInfo%d",i))
        local uiText_info = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"Text_info")
        local uiAtlasLabel_rate = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"AtlasLabel_rate")
        local uiImage_rate = ccui.Helper:seekWidgetByName(uiButton_roomTypeInfo,"Image_rate")
        if self.tableFriendsRoomParams ~= nil and self.tableFriendsRoomParams[i] ~= nil then
            local data = self.tableFriendsRoomParams[i]
            uiButton_roomTypeInfo.data = data
            if data.dwMaxScore ~= 0 then
                uiText_info:setString(string.format("%d -- %d",data.dwMinScore,data.dwMaxScore))
            else
                uiText_info:setString(string.format("%d -- 无限",data.dwMinScore))
            end
            uiAtlasLabel_rate:setVisible(true)
            uiAtlasLabel_rate:setString(string.format("%d",data.wCellScore))
            uiImage_rate:setVisible(true)
        end
    end 
end

--刷新个人信息
function GoldGameLayer:SUB_CL_USER_INFO(event)
    self:updateUserInfo()
end

function GoldGameLayer:updateUserInfo()
--    local uiButton_goldBg = ccui.Helper:seekWidgetByName(self.root,"Button_goldBg")
--    local uiText_gold = ccui.Helper:seekWidgetByName(self.root,"Text_gold")
--    local dwGold = Common:itemNumberToString(UserData.User.dwGold)
--    uiText_gold:setString(tostring(dwGold))
    local dwGold = Common:itemNumberToString(UserData.User.dwGold)
    local uiText_roomCard = ccui.Helper:seekWidgetByName(self.root,"Text_roomCard")
    uiText_roomCard:setString(tostring(dwGold))

end

--获取房间ip地址和端口成功
function GoldGameLayer:SUB_CL_GAME_SERVER(event)
    local data = event._usedata
    UserData.Game:sendMsgConnectGame(data)           
end

function GoldGameLayer:SUB_CL_GAME_SERVER_ERROR(event)
    local data = event._usedata
    require("common.MsgBoxLayer"):create(0,nil,"服务器暂未开启！")         
end

function GoldGameLayer:EVENT_TYPE_CONNECT_GAME_FAILED(event)
    local data = event._usedata
    require("common.MsgBoxLayer"):create(0,nil,"连接游戏服失败！")
end

function GoldGameLayer:SUB_GR_LOGON_SUCCESS(event)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_MATCH_GOLD_TABLE,"w",self.cbLevel)
end

function GoldGameLayer:SUB_GR_MATCH_TABLE_ING(event)
    local data = event._usedata
    require("common.SceneMgr"):switchScene(require(StaticData.Games[data.wKindID].luaGameFile):create(UserData.User.userID, data),SCENE_GAME)
end

function GoldGameLayer:SUB_GR_MATCH_TABLE_FAILED(event)
    local data = event._usedata
    if data.wErrorCode == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"您在游戏中!")
    elseif data.wErrorCode == 1 then
        require("common.MsgBoxLayer"):create(0,nil,"游戏配置发生错误!")
    elseif data.wErrorCode == 2 then
        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值!",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
    elseif data.wErrorCode == 3 then
        require("common.MsgBoxLayer"):create(0,nil,"您的金币已超过上限，请前往更高一级匹配!")
    elseif data.wErrorCode == 4 then
        require("common.MsgBoxLayer"):create(0,nil,"房间已满,稍后再试!")
    else
        require("common.MsgBoxLayer"):create(0,nil,"未知错误,请升级版本!") 
    end
end

function GoldGameLayer:SUB_GR_USER_ENTER(event)
    local data = event._usedata
    require("common.SceneMgr"):switchScene(require(StaticData.Games[data.wKindID].luaGameFile):create(UserData.User.userID, data),SCENE_GAME)
end


return GoldGameLayer

