local Common = require("common.Common")
local UserData = require("app.user.UserData")
local GameDesc = require("common.GameDesc")
local StaticData = require("app.static.StaticData")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")

local DailyShareLayer = class("DailyShareLayer", cc.load("mvc").ViewBase)

function DailyShareLayer:onEnter()
    EventMgr:registListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT)
    EventMgr:registListener(EventType.RET_GET_GUILD_INFO_BY_GUILDID,self,self.RET_GET_GUILD_INFO_BY_GUILDID)        --查询公会
    EventMgr:registListener(EventType.RET_JOIN_GUILD,self,self.RET_JOIN_GUILD)      --加入公会
    EventMgr:registListener(EventType.RET_SETTINGS_GUILD,self,self.RET_SETTINGS_GUILD)    --更改公会
    EventMgr:registListener(EventType.EVENT_TYPE_TO_VIEW_GUILD,self,self.EVENT_TYPE_TO_VIEW_GUILD)
end

function DailyShareLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT)
    EventMgr:unregistListener(EventType.RET_GET_GUILD_INFO_BY_GUILDID,self,self.RET_GET_GUILD_INFO_BY_GUILDID) 
    EventMgr:unregistListener(EventType.RET_JOIN_GUILD,self,self.RET_JOIN_GUILD) 
    EventMgr:unregistListener(EventType.RET_SETTINGS_GUILD,self,self.RET_SETTINGS_GUILD) 
    EventMgr:unregistListener(EventType.EVENT_TYPE_TO_VIEW_GUILD,self,self.EVENT_TYPE_TO_VIEW_GUILD)
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
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID)
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
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID)
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
function DailyShareLayer:RET_GET_GUILD_INFO_BY_GUILDID(event)
    local data = event._usedata
    if data.dwGuildID == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"加入失败!")
    else                  
        require("common.MsgBoxLayer"):create(1,nil,string.format("邀请码:%s", data.dwGuildID),
            function() 
                UserData.Guild:joinGuild(data.dwGuildID)
            end)                                    
    end      
end

function DailyShareLayer:RET_JOIN_GUILD(event)
    local data = event._usedata   
    if data.ret == 0 then   
        UserData.Guild.dwID = data.dwID
        UserData.Guild.dwGuildID = data.dwGuildID
        UserData.Guild.szGuildName = data.szGuildName
        UserData.Guild.szGuildNotice = data.szGuildNotice
        UserData.Guild.dwMemberCount = data.dwMemberCount
        UserData.Guild.dwPresidentID = data.dwPresidentID
        UserData.Guild.szPresidentName = data.szPresidentName
        UserData.Guild.szPresidentLogo = ""
        
        self:EVENT_TYPE_TO_VIEW_GUILD(event)          
        UserData.User:sendMsgUpdateUserInfo(1)   
    else 
        require("common.MsgBoxLayer"):create(0,nil,"请求失败！")          
    end
end

function DailyShareLayer:EVENT_TYPE_TO_VIEW_GUILD(event)
    local uiPanel_share_wowo = ccui.Helper:seekWidgetByName(self.root,"Panel_share_wowo")
    if CHANNEL_ID == 20 or CHANNEL_ID == 21 then  
        local uiButton_jion = ccui.Helper:seekWidgetByName(uiPanel_share_wowo,"Button_jion")  
        local uiImage_invite = ccui.Helper:seekWidgetByName(uiPanel_share_wowo,"Image_invite")
        local uiImage_txinvitation = ccui.Helper:seekWidgetByName(uiPanel_share_wowo,"Image_txinvitation")
        local uiText_invitation = ccui.Helper:seekWidgetByName(uiPanel_share_wowo,"Text_invitation")
        if UserData.Guild.dwGuildID == 0 or UserData.Guild.dwGuildID == nil  then 
            uiImage_txinvitation:setVisible(false)
            uiImage_invite:setVisible(true)
        else
            uiImage_txinvitation:setVisible(true)
            uiImage_invite:setVisible(false)
            uiButton_jion:setVisible(false)
            uiText_invitation:setString(string.format("%d",UserData.Guild.dwGuildID))
        end  
    end

end

return DailyShareLayer

