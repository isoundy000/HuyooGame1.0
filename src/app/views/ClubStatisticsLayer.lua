local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local HttpUrl = require("common.HttpUrl")

local ClubStatisticsLayer = class("ClubStatisticsLayer", cc.load("mvc").ViewBase)

function ClubStatisticsLayer:onEnter()
       
end

function ClubStatisticsLayer:onExit()
    
end


function ClubStatisticsLayer:onCreate(parameter)
    local dwClubID = parameter[1]
    local isAdmin = parameter[2]
    print('--->>>',dwClubID,isAdmin)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("ClubStatisticsLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        --self:removeFromParent()
        EventMgr:dispatch(EventType.CLOSE_RECORDCLUB)
    end)
    
    local uiPanel_contents = ccui.Helper:seekWidgetByName(self.root,"Panel_contents")
    local uiButton_all = ccui.Helper:seekWidgetByName(self.root,"Button_all")
    local uiButton_personal = ccui.Helper:seekWidgetByName(self.root,"Button_personal")
    Common:addTouchEventListener(uiButton_all,function() 
        uiPanel_contents:removeAllChildren()
        uiButton_personal:setBright(false)
        uiButton_all:setBright(true)
        if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
            local uiWebView = ccexp.WebView:create()
            uiPanel_contents:addChild(uiWebView)
            uiWebView:setContentSize(uiPanel_contents:getContentSize())
            uiWebView:setAnchorPoint(cc.p(0.5,0.5))
            uiWebView:setPosition(uiWebView:getParent():getContentSize().width/2,uiWebView:getParent():getContentSize().height/2)
            uiWebView:setScalesPageToFit(true)
            --uiWebView:enableDpadNavigation(false)
            if CHANNEL_ID == 0 or CHANNEL_ID == 1 then
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatistics,dwClubID,0))
            else
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatisticsScore,dwClubID,0))
            end
        end
    end)
    
    Common:addTouchEventListener(uiButton_personal,function() 
        uiButton_personal:setBright(true)
        uiButton_all:setBright(false)
        uiPanel_contents:removeAllChildren()
        if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
            local uiWebView = ccexp.WebView:create()
            uiPanel_contents:addChild(uiWebView)
            uiWebView:setContentSize(uiPanel_contents:getContentSize())
            uiWebView:setAnchorPoint(cc.p(0.5,0.5))
            uiWebView:setPosition(uiWebView:getParent():getContentSize().width/2,uiWebView:getParent():getContentSize().height/2)
            uiWebView:setScalesPageToFit(true)
            --uiWebView:enableDpadNavigation(false)
            if CHANNEL_ID == 0 or CHANNEL_ID == 1 or CHANNEL_ID == 6 or CHANNEL_ID == 7 then
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatistics,dwClubID,UserData.User.userID))
            else
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatisticsScore,dwClubID,UserData.User.userID))
            end
        end
    end)
    if isAdmin == true then
        uiPanel_contents:removeAllChildren()
        uiButton_personal:setBright(false)
        uiButton_all:setBright(true)
        if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
            local uiWebView = ccexp.WebView:create()
            uiPanel_contents:addChild(uiWebView)
            uiWebView:setContentSize(uiPanel_contents:getContentSize())
            uiWebView:setAnchorPoint(cc.p(0.5,0.5))
            uiWebView:setPosition(uiWebView:getParent():getContentSize().width/2,uiWebView:getParent():getContentSize().height/2)
            uiWebView:setScalesPageToFit(true)
            --uiWebView:enableDpadNavigation(false)
            if CHANNEL_ID == 0 or CHANNEL_ID == 1 then
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatistics,dwClubID,0))
            else
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatisticsScore,dwClubID,0))
            end
        end
    else
        uiButton_all:setVisible(false)
        uiButton_personal:setPositionX(uiButton_personal:getParent():getContentSize().width/2)
        uiPanel_contents:removeAllChildren()
        uiButton_personal:setBright(true)
        uiButton_all:setVisible(false)
        if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
            local uiWebView = ccexp.WebView:create()
            uiPanel_contents:addChild(uiWebView)
            uiWebView:setContentSize(uiPanel_contents:getContentSize())
            uiWebView:setAnchorPoint(cc.p(0.5,0.5))
            uiWebView:setPosition(uiWebView:getParent():getContentSize().width/2,uiWebView:getParent():getContentSize().height/2)
            uiWebView:setScalesPageToFit(true)
            --uiWebView:enableDpadNavigation(false)
            if CHANNEL_ID == 0 or CHANNEL_ID == 1 or CHANNEL_ID == 6 or CHANNEL_ID == 7 then
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatistics,dwClubID,UserData.User.userID))
            else
                uiWebView:loadURL(string.format(HttpUrl.POST_URL_ClubStatisticsScore,dwClubID,UserData.User.userID))
            end
        end
    end
end


return ClubStatisticsLayer