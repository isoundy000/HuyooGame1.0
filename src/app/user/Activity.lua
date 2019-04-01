local Bit = require("common.Bit")
local Common = require("common.Common")
local Net = require("common.Net")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local StaticData = require("app.static.StaticData")
local EventType = require("common.EventType")
local Default = require("common.Default")
local HttpUrl = require("common.HttpUrl")
local json = require("json")

local Activity = {
}

function Activity:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_FIRST_ENTER_HALL,self,self.EVENT_TYPE_FIRST_ENTER_HALL)
end

function Activity:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_FIRST_ENTER_HALL,self,self.EVENT_TYPE_FIRST_ENTER_HALL)
end

function Activity:EVENT_TYPE_FIRST_ENTER_HALL(event)

end

function Activity:requestActivityInvite()
    local UserData = require("app.user.UserData")
    --邀请有礼活动
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_ActivityInvite,UserData.User.userID))
    local function onHttpRequestCompleted()
        if xmlHttpRequest.status == 200 then
            print("邀请有礼活动:",xmlHttpRequest.response)
            local response = json.decode(xmlHttpRequest.response)
            if response["ret"] == 0 then
                for key, var in pairs(response["Obj"]) do
                    local data = {}
                    data.isActivation = var["IsActivate"]
                    data.inviteFriendsCount = var["FriendCount"]
                    data.rewardState = var["PayCount"]
                    data.bindID = var["FriendUserID"]
                    EventMgr:dispatch(EventType.EVENT_TYPE_ACTIONINVITE_INFO,data)
                	break
                end
            end
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

--邀请有礼填写邀请码领取奖励
function Activity:requestActivityInviteInputInviteCode(inviteCode)
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_ActivityInviteBind,UserData.User.userID,inviteCode))
    local function onHttpRequestCompleted()
        if xmlHttpRequest.status == 200 then
            print("邀请有礼活动:",xmlHttpRequest.response)
            local response = json.decode(xmlHttpRequest.response)
            EventMgr:dispatch(EventType.EVENT_TYPE_ACTIONINVITE_INPUT_CODE,response)
        end
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

--邀请有礼领取现金红包
function Activity:requestActivityInviteGetMoney()
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_ActivityInviteRedPack,UserData.User.userID,CHANNEL_ID))
    local function onHttpRequestCompleted()
        if xmlHttpRequest.status == 200 then
            print("邀请有礼活动:",xmlHttpRequest.response)
            local response = json.decode(xmlHttpRequest.response)
            EventMgr:dispatch(EventType.EVENT_TYPE_ACTIONINVITE_GET_MONEY,response)
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

return  Activity
