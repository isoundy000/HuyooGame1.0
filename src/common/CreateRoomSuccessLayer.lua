local UserData = require("app.user.UserData")
local StaticData = require("app.static.StaticData")
local Common = require("common.Common")
local CreateRoomSuccessLayer = class("CreateRoomSuccessLayer", function()
    return cc.Node:create()
end)

function CreateRoomSuccessLayer:create(wKindID,wTableID,wGameCount,desc)
    local view = CreateRoomSuccessLayer.new()
    view:onCreate(wKindID,wTableID,wGameCount,desc)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit()
        elseif eventType == "cleanup" then
            view:onCleanup()
        end  
    end 
    view:registerScriptHandler(onEventHandler)
    return view
end

function CreateRoomSuccessLayer:onEnter()

end

function CreateRoomSuccessLayer:onExit()

end

function CreateRoomSuccessLayer:onCleanup()

end

function CreateRoomSuccessLayer:onCreate(wKindID,wTableID,wGameCount,desc)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("CreateRoomSuccessLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    local uiButton_lookAt = ccui.Helper:seekWidgetByName(self.root,"Button_lookAt")
    local uiButton_invite = ccui.Helper:seekWidgetByName(self.root,"Button_invite")
    local uiButton_cancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")

    local uiText_contents = ccui.Helper:seekWidgetByName(self.root,"Text_contents")
    uiText_contents:setString(string.format(uiText_contents:getString(),wTableID)) 
    Common:addTouchEventListener(uiButton_lookAt,function() 
        self:removeFromParent()
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("ProxyLayer"))
    end)
--    local data = 
--    Common:addTouchEventListener(uiButton_invite,function() 
--        if data then
--            UserData.Share:doShare(data.dwIndexID,
--                string.format("[%s]房号:%d,%d局",StaticData.Games[wKindID].name,wTableID,wGameCount),
--                desc.."(代开房)".." (点击加入游戏)",
--                string.format("%s&Account=%s&channelID=%d", string.format(data.szShareUrl,wTableID),UserData.User.szAccount,CHANNEL_ID),
--                "")
--        end
--    end)
    
    Common:addTouchEventListener(uiButton_cancel,function() 
        self:removeFromParent()
    end)
    
    require("common.SceneMgr"):switchTips(self)
end

return CreateRoomSuccessLayer
