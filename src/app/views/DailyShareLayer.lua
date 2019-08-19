local Common = require("common.Common")
local UserData = require("app.user.UserData")
local GameDesc = require("common.GameDesc")
local StaticData = require("app.static.StaticData")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local DailyShareLayer = class("DailyShareLayer", cc.load("mvc").ViewBase)

function DailyShareLayer:onEnter()
    EventMgr:registListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT)
end

function DailyShareLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT)
end

function DailyShareLayer:onCleanup()

end

function DailyShareLayer:onCreate()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("DailyShareLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    local uiPanel_share = ccui.Helper:seekWidgetByName(self.root,"Panel_share")
    local uiPanel_share_wowo = ccui.Helper:seekWidgetByName(self.root,"Panel_share_wowo")
    uiPanel_share_wowo:setVisible(false)
    uiPanel_share:setVisible(true)
    local callback = function()
        require("common.SceneMgr"):switchTips()
    end
    Common:playPopupAnim(uiPanel_share, nil, callback) 
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(uiPanel_share,"Button_return"),function()
        Common:playExitAnim(uiPanel_share, callback)
    end)

    local uiText_share = ccui.Helper:seekWidgetByName(self.root,"Text_share")
    local config = UserData.Welfare.tableWelfareConfig[1004]
    local record = UserData.Welfare.tableWelfare[1004]
    if config == nil or record == nil then
        uiText_share:setVisible(false)
    else
        local tableTemp = Common:stringSplit(config.tcPrize,"|")
        for key, var in pairs(tableTemp) do
            local tempData = Common:stringSplit(var,"_")            
            local wPropID = tonumber(tempData[1])
            local dwPropCount = tonumber(tempData[2])
            if wPropID == 1003 and ( CHANNEL_ID == 20 or CHANNEL_ID == 21 ) then 
                wPropID = 1002   --房卡转钻石
            end 
            uiText_share:setString(string.format("%sx%d",StaticData.Items[wPropID].name,dwPropCount))
        end
    end

    
    local uiText_invite = ccui.Helper:seekWidgetByName(self.root,"Text_invite")
    local config = UserData.Welfare.tableWelfareConfig[1005]
    local record = UserData.Welfare.tableWelfare[1005]
    if config == nil or record == nil then
        uiText_invite:setVisible(false)
    else
        local tableTemp = Common:stringSplit(config.tcPrize,"|")
        for key, var in pairs(tableTemp) do
            local tempData = Common:stringSplit(var,"_")
            local wPropID = tonumber(tempData[1])
            local dwPropCount = tonumber(tempData[2])
            if wPropID == 1003 and ( CHANNEL_ID == 20 or CHANNEL_ID == 21 ) then 
                wPropID = 1002   --房卡转钻石
            end 
            uiText_invite:setString(string.format("%sx%d",StaticData.Items[wPropID].name,dwPropCount))
        end
    end
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_share"),function() 
        local data = clone(UserData.Share.tableShareParameter[0])
        data.cbTargetType = 1
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then
            data.cbShareType = 2
        end
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1004]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1004)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"分享成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"分享失败")  
            end
        end)
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_invite"),function() 
        local data = clone(UserData.Share.tableShareParameter[0])
        data.cbTargetType = 2
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then
            data.cbShareType = 1
        end
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1005]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1005)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"邀请成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"邀请失败")  
            end  
        end)
    end)           
    require("common.SceneMgr"):switchTips(self)     
end

function DailyShareLayer:SUB_SC_ACTIONRESULT(event)
    local data = event._usedata
    if data.wCode == 0 then
        UserData.User:sendMsgUpdateUserInfo(0)
        --处理奖励
        local tableReward = {}
        local tempTable = Common:stringSplit(data.szReward,"|")
        for key, var in pairs(tempTable) do
            local tempReward = Common:stringSplit(var,"_")
            local rewardData = {}
            rewardData.wPropID = tonumber(tempReward[1])
            rewardData.dwPropCount = tonumber(tempReward[2])
            table.insert(tableReward,#tableReward + 1, rewardData)
        end
        local data = event._usedata
        --刷新活动
        require("common.RewardLayer"):create("福利奖励",nil,tableReward)
    else
        require("common.MsgBoxLayer"):create(0,nil,"领取奖励失败!")
    end
end

return DailyShareLayer

