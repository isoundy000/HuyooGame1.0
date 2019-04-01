local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local GameConfig = require("common.GameConfig")

local SportsRuleLayer = class("SportsRuleLayer", cc.load("mvc").ViewBase)

function SportsRuleLayer:onEnter()

end

function SportsRuleLayer:onExit()

end

function SportsRuleLayer:onCleanup()

end

function SportsRuleLayer:onCreate(parameter)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsRuleLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
end

return SportsRuleLayer

