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

local GuildActivity = {
    activity = false,              --是否为每日首次登陆
    iosactivity =  false,          --是否参加活动
}

function GuildActivity:onEnter()

end

function GuildActivity:onExit()  
  
end



function GuildActivity:RequestRanking(event)
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_RankingInformation,UserData.Guild.dwGuildID,UserData.User.userID))
    local function onHttpRequestCompleted()
        print("公会活动5",xmlHttpRequest.status,UserData.Guild.dwGuildID,UserData.User.userID)
        if xmlHttpRequest.status == 200 then
            print("公会活动6",xmlHttpRequest.response)
            local data = json.decode(xmlHttpRequest.response)
            EventMgr:dispatch(EventType.SUB_SC_JSONCALLACTIVI,data)
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

function GuildActivity:RequestRanking1(event)
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_RankingInformation1,UserData.User.userID))
    local function onHttpRequestCompleted()
        print("公会活动15",xmlHttpRequest.status,UserData.Guild.dwGuildID,UserData.User.userID)
        if xmlHttpRequest.status == 200 then
            print("公会活动16",xmlHttpRequest.response)
            local data = json.decode(xmlHttpRequest.response)
            EventMgr:dispatch(EventType.SUB_SC_JSONCALLACTIVI,data)
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

function GuildActivity:RequestTuHaoRanking(event)   --土豪排行帮PHP请求
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_GetPayRank,UserData.User.userID,CHANNEL_ID))
    local function onHttpRequestCompleted()
        print("公会活动25",xmlHttpRequest.status,UserData.User.userID)
        if xmlHttpRequest.status == 200 then
            print("公会活动26",xmlHttpRequest.response)
            local data = json.decode(xmlHttpRequest.response)
            EventMgr:dispatch(EventType.SUB_SC_TUHAOACTIVI,data)
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

return GuildActivity