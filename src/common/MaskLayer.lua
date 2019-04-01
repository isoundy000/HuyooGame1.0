local Common = require("common.Common")
local MaskLayer = class("MaskLayer", function()
    return cc.Layer:create()
end)

--@param    type: 0文本提示   1确定取消  2确定  3同意拒绝 
--@return   node: 制定加入的父节点
--require("common.MaskLayer"):create()



function MaskLayer:create()
    local view = MaskLayer.new()
    view:onCreate()
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

function MaskLayer:onEnter()

end

function MaskLayer:onExit()

end

function MaskLayer:onCleanup()

end

function MaskLayer:onCreate()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("MaskLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    self.root:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            self:removeFromParent() 
        end
    end)   
    require("common.SceneMgr"):switchGlobal(self)
end

return MaskLayer
