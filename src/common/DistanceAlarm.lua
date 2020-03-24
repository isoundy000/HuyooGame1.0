local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local NetMsgId = require("common.NetMsgId")


local DistanceAlarm = class("DistanceAlarm", function()
    return ccui.Layout:create()
end)


function DistanceAlarm:create(wKindID)
    local view = DistanceAlarm.new()
    view:onCreate(wKindID)
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

function DistanceAlarm:onEnter()
    
end

function DistanceAlarm:onExit()
    
end

function DistanceAlarm:onCleanup()
end

function DistanceAlarm:onCreate(wKindID)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("DistanceAlarmLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local GameCommon = nil
    if wKindID == 43 then
       GameCommon = require("game.paohuzi.43.GameCommon") 
    elseif wKindID == 61 then
        GameCommon = require("game.paohuzi.61.GameCommon") 
    elseif wKindID == 97 then
        GameCommon = require("game.majiang.97.GameCommon") 
    elseif wKindID == 27 or wKindID == 31 or wKindID == 32 or wKindID == 33 or wKindID == 34 or wKindID == 35  or wKindID == 36  or wKindID == 37 then
        GameCommon = require("game.yongzhou.GameCommon") 
    elseif StaticData.Games[wKindID].type == 1 then
        GameCommon = require("game.paohuzi.GameCommon")
    elseif StaticData.Games[wKindID].type == 2 then
        GameCommon = require("game.puke.GameCommon")    
    elseif StaticData.Games[wKindID].type == 3 then 
        if wKindID == 42  then
            GameCommon = require("game.laopai.GameCommon")
        else
            GameCommon = require("game.majiang.GameCommon")
        end 
    else
        return
    end    
    if wKindID == 42 then       
        GameCommon.gameConfig = {}  
        GameCommon.gameConfig.bPlayerCount = 4
    end  
    local distance = nil
    for wChairID = 0, 3 do
        if GameCommon.player[wChairID] ~= nil then        
           if GameCommon.player[wChairID].location.x < 0.1 then
                if distance == nil then 
                    distance =string.format("%s未开启定位",GameCommon.player[wChairID].szNickName)
                else
                    distance =distance.."\n"..string.format("%s未开启定位",GameCommon.player[wChairID].szNickName)
                end  
           else
                for wTargetChairID = wChairID+1, GameCommon.gameConfig.bPlayerCount-1 do
                    if GameCommon.player[wTargetChairID].location.x > 0.1 then
                        local desc = nil                         
                        desc = GameCommon:GetDistance(GameCommon.player[wChairID].location,GameCommon.player[wTargetChairID].location)                                     
                        if desc~= nil and desc < 100 then
                            if distance == nil then 
                                distance =string.format("%s与%s距离为%dm",GameCommon.player[wChairID].szNickName,GameCommon.player[wTargetChairID].szNickName,desc)
                            else
                                distance =distance.."\n"..string.format("%s与%s距离为%dm",GameCommon.player[wChairID].szNickName,GameCommon.player[wTargetChairID].szNickName,desc)
                            end 
                        end
                    end 
                end
            end
        end
    end
    if distance ==nil then 
        self.root:removeFromParent() 
    end 
    local uiText_Warning = ccui.Helper:seekWidgetByName(self.root,"Text_Warning")
    uiText_Warning:setString(distance)
        
    --继续
    local uiButton_Continue = ccui.Helper:seekWidgetByName(self.root,"Button_Continue")
    if uiButton_Continue ~= nil then
        Common:addTouchEventListener(uiButton_Continue,function() 
            self:removeFromParent()
        end) 
    end
    require("common.SceneMgr"):switchOperation(self)
end

return DistanceAlarm
    