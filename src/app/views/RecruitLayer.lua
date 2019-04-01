local Common = require("common.Common")
local UserData = require("app.user.UserData")
local GameDesc = require("common.GameDesc")
local StaticData = require("app.static.StaticData")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local RecruitLayer = class("RecruitLayer", cc.load("mvc").ViewBase)

function RecruitLayer:onEnter()
    
end

function RecruitLayer:onExit()
    
end

function RecruitLayer:onCleanup()

end

function RecruitLayer:onCreate()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RecruitLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    local uiImage_recruit_1 = ccui.Helper:seekWidgetByName(self.root,"Image_recruit_1")
    local uiImage_recruit = ccui.Helper:seekWidgetByName(self.root,"Image_recruit")
    
    if CHANNEL_ID ~= 20 and CHANNEL_ID ~= 21 then
        uiImage_recruit_1:setVisible(false)
        uiImage_recruit:setVisible(true)
        local uiText_serviceVX = ccui.Helper:seekWidgetByName(self.root,"Text_serviceVX") 
        uiText_serviceVX:setString(string.format("%s , %s",StaticData.Channels[CHANNEL_ID].serviceVX_1,StaticData.Channels[CHANNEL_ID].serviceVX_2))
         Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return_1"),function() 
        self:removeFromParent()
    end)
    else
        uiImage_recruit_1:setVisible(true)
        uiImage_recruit:setVisible(false)
        local uiText_serviceVX_1 = ccui.Helper:seekWidgetByName(self.root,"Text_serviceVX_1") 
        uiText_serviceVX_1:setString(string.format("%s",StaticData.Channels[CHANNEL_ID].serviceVX_1))
        local uiText_serviceVX_2 = ccui.Helper:seekWidgetByName(self.root,"Text_serviceVX_2") 
        uiText_serviceVX_2:setString(string.format("%s",StaticData.Channels[CHANNEL_ID].serviceVX_2))
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return_2"),function() 
            self:removeFromParent()
        end)
    end
    
end
   
return RecruitLayer

