local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local NetMsgId = require("common.NetMsgId")




local GameplayLayer = class("GameplayLayer", cc.load("mvc").ViewBase)

function GameplayLayer:onEnter()

end

function GameplayLayer:onExit()

end

function GameplayLayer:onCreate(parames)
    NetMgr:getGameInstance():closeConnect()
    self.tableFriendsRoomParams = nil
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function(sender,event) self:removeFromParent() end)
    
    local uiButton_roomCardBg = ccui.Helper:seekWidgetByName(self.root,"Button_roomCardBg")    
    uiButton_roomCardBg:setVisible(false)
    local uiText_warning = ccui.Helper:seekWidgetByName(self.root,"Text_warning")    
    uiText_warning:setVisible(true)
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
    local locationID = parames[1]
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
            local textureName = "room/room_4.png"     
            local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
            uiImage_title:loadTexture(textureName)
            uiImage_title:setContentSize(texture:getContentSizeInPixels()) 
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
            if UserData.Game.tableGames[wKindID] ~= nil and wKindID ~= 51 and wKindID ~= 53 and wKindID ~= 55 then
                local data = StaticData.Games[wKindID]
                if type == 4 or data.type == type or type == nil then
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
        if locationID == nil then
            showGameType(1)
        else
            showGameType(StaticData.Games[locationID].type)
        end
    end

end

function GameplayLayer:showGameParameter(wKindID)
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
    if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
        local uiPanel_parameter = ccui.Helper:seekWidgetByName(self.root,"Panel_parameter")   
        uiPanel_parameter:removeAllChildren()  
        local uiWebView = ccexp.WebView:create()
        uiPanel_parameter:addChild(uiWebView)
        uiWebView:setContentSize(uiPanel_parameter:getContentSize())
        uiWebView:setAnchorPoint(cc.p(0.5,0.5))
        uiWebView:setPosition(uiWebView:getParent():getContentSize().width/2,uiWebView:getParent():getContentSize().height/2)
        uiWebView:setScalesPageToFit(true)
        uiWebView:loadURL(StaticData.Games[wKindID].ruleCSB)
        --uiWebView:enableDpadNavigation(false)
    end
    return node
end

return GameplayLayer
