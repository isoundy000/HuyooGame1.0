local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local Default = require("common.Default")
local Bit = require("common.Bit")
local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").ViewBase)

function RoomCreateLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
end

function RoomCreateLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
end

function RoomCreateLayer:onCleanup()

end

function RoomCreateLayer:onCreate(parameter)
    local locationID = parameter[1]
    self.showType    = parameter[2]    --显示类型  0默认     1设置亲友圈参数  2亲友圈自定义创房 3竞技场设置玩法
    self.dwClubID = parameter[3]
    NetMgr:getGameInstance():closeConnect()
    self.tableFriendsRoomParams = nil
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function(sender,event) self:removeFromParent() end)
    
    local uiText_roomCard = ccui.Helper:seekWidgetByName(self.root,"Text_roomCard")
    uiText_roomCard:setString(string.format("%d",UserData.Bag:getBagPropCount(1003))) 
    local uiButton_roomCardBg = ccui.Helper:seekWidgetByName(self.root,"Button_roomCardBg")  
     
    if CHANNEL_ID == 20 or CHANNEL_ID == 21  then     
        uiButton_roomCardBg:setVisible(false)     
    end 
    local uiText_warning = ccui.Helper:seekWidgetByName(self.root,"Text_warning")    
    uiText_warning:setVisible(false)
    Common:addTouchEventListener(uiButton_roomCardBg,function()      
      if StaticData.Hide[CHANNEL_ID].btn9 == 1 and  CHANNEL_ID ~= 16 and  CHANNEL_ID ~= 17 then  
          require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) 
      else 
          require("common.MsgBoxLayer"):create(2,nil,"请联系代理!")
      end 
    end)
    if  CHANNEL_ID == 20 or CHANNEL_ID == 21 then 
        local uiImage_roomCard = ccui.Helper:seekWidgetByName(self.root,"Image_roomCard")    
        uiImage_roomCard:loadTexture("hall_6/hall_wowo_35.png")
    end
    local uiImage_title = ccui.Helper:seekWidgetByName(self.root,"Image_title")
    local uiListView_gameTypeBtn = ccui.Helper:seekWidgetByName(self.root,"ListView_gameTypeBtn")
    local uiListView_games = ccui.Helper:seekWidgetByName(self.root,"ListView_games")
    --  列表间距              uiListView_betting:setItemsMargin(10)
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
    
            
    local regionID = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_RegionID,0)
    if locationID == nil or locationID == 0 then
        for key, var in pairs(UserData.Game.talbeCommonGames) do
        	if var ~= 51 and var ~= 53  and var ~= 55 then
        	   locationID = var
        	   break
        	end
        end
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
        local tableNiuNiuUserID = {
            [10013998]=1,[10015147]=1,[10024831]=1,[10037008]=1,[10025776]=1,[10015230]=1,[10010001]=1,[10010046]=1,[10016543]=1,[10027104]=1,
        }
        for key, var in pairs(games) do
            local wKindID = tonumber(var)
            local data = StaticData.Games[wKindID]
            if UserData.Game.tableGames[wKindID] ~= nil and Bit:_and(data.friends,1) ~= 0 and (type == 4 or data.type == type or type == nil ) and (wKindID ~= 51 or locationID == 51 or tableNiuNiuUserID[UserData.User.userID] ~= nil) and (wKindID ~= 53 or locationID == 53 or tableNiuNiuUserID[UserData.User.userID] ~= nil) and (wKindID ~= 55 or locationID == 55 or tableNiuNiuUserID[UserData.User.userID] ~= nil) and wKindID ~= 45 and wKindID ~= 50 then--
                local item = ccui.Button:create(data.icon1,data.icons1,data.icons)
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
    if  #UserData.Game.tableSortGames <= 5 then  
        showGameType()
    else
        if locationID == nil or locationID == 0 or UserData.Game.tableGames[locationID] == nil then
            showGameType(1)
        else
            showGameType(StaticData.Games[locationID].type)
        end
    end
end

function RoomCreateLayer:showGameParameter(wKindID)
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
    local uiPanel_parameter = ccui.Helper:seekWidgetByName(self.root,"Panel_parameter")
    uiPanel_parameter:removeAllChildren() 
    local RoomCreateNode = nil 
    if wKindID ~= nil and wKindID == 48 and (CHANNEL_ID == 6 or CHANNEL_ID == 7) then 
        RoomCreateNode = require("app.MyApp"):create(wKindID,self.showType,self.dwClubID):createView("RoomCreateLayer48_1")
    else
        RoomCreateNode = require("app.MyApp"):create(wKindID,self.showType,self.dwClubID):createView(StaticData.Games[wKindID].luaCreateRoomFile)
    end 
   
    uiPanel_parameter:addChild(RoomCreateNode)
    RoomCreateNode.root:setOpacity(0)
    RoomCreateNode.root:runAction(cc.FadeIn:create(0.5))
    return node
end

function RoomCreateLayer:SUB_CL_USER_INFO(event)
    self:updateUserInfo()
end

function RoomCreateLayer:updateUserInfo()
    local uiText_roomCard = ccui.Helper:seekWidgetByName(self.root,"Text_roomCard")
    uiText_roomCard:setString(string.format("%d",UserData.Bag:getBagPropCount(1003)))
end

return RoomCreateLayer

