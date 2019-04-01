local StaticData = require("app.static.StaticData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local UserData = require("app.user.UserData")
local Common = require("common.Common")

local XinLiaoInviteLayer = class("XinLiaoInviteLayer",function()
    return ccui.Layout:create()
end)

function XinLiaoInviteLayer:create(dwIndexID,szShareTitle,szShareContent,szShareUrl,filename,callback)
    local view = XinLiaoInviteLayer.new()
    view:onCreate(dwIndexID,szShareTitle,szShareContent,szShareUrl,filename,callback)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function XinLiaoInviteLayer:onEnter()

end

function XinLiaoInviteLayer:onExit()
end

function XinLiaoInviteLayer:onCreate(dwIndexID,szShareTitle,szShareContent,szShareUrl,filename,callback)
    self.root = nil
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("XinLiaoInviteLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
        
    local uiImage_bg = ccui.Helper:seekWidgetByName(self.root,"Image_bg")
    Common:playPopupAnim(uiImage_bg)
    
    Common:addTouchEventListener(self.root,function() 
        self:removeFromParent()
    end,true)
        
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_weiXin"),function() 
        UserData.Share:doShare(3,szShareTitle,szShareContent,szShareUrl,filename,callback)
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_xianLiao"),function() 
        UserData.Share:doShare(14,szShareTitle,szShareContent,szShareUrl,filename,callback)
    end)
end
return XinLiaoInviteLayer