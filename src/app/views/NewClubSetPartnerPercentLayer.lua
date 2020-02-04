--[[
*名称:NewClubSetPartnerPercentLayer
*描述:设置分成百分比
*作者:admin
*创建日期:2020-01-13 15:58:25
*修改日期:
]]

local EventMgr          = require("common.EventMgr")
local EventType         = require("common.EventType")
local NetMgr            = require("common.NetMgr")
local NetMsgId          = require("common.NetMsgId")
local StaticData        = require("app.static.StaticData")
local UserData          = require("app.user.UserData")
local Common            = require("common.Common")
local GameConfig        = require("common.GameConfig")

local NewClubSetPartnerPercentLayer      = class("NewClubSetPartnerPercentLayer", cc.load("mvc").ViewBase)

function NewClubSetPartnerPercentLayer:onConfig()
    self.widget         = {
    	{"Text_myPercent"},
    	{"Button_close", "onClose"},
    	{"ListView_playwayList"},
    	{"Image_noPlayway"},
    	{"Image_partnerFrame"},
    	{"ListView_partner"},
        {"Button_item"},
        {"Image_item"},
    }

    self.lastPressBtn = nil
end

function NewClubSetPartnerPercentLayer:onEnter()
	EventMgr:registListener(EventType.RET_CLUB_PLAY_DISTRIBUTION ,self,self.RET_CLUB_PLAY_DISTRIBUTION)
	EventMgr:registListener(EventType.RET_SETTINGS_CLUB_PLAY_DISTRIBUTION ,self,self.RET_SETTINGS_CLUB_PLAY_DISTRIBUTION)
end

function NewClubSetPartnerPercentLayer:onExit()
	EventMgr:unregistListener(EventType.RET_CLUB_PLAY_DISTRIBUTION ,self,self.RET_CLUB_PLAY_DISTRIBUTION)
	EventMgr:unregistListener(EventType.RET_SETTINGS_CLUB_PLAY_DISTRIBUTION ,self,self.RET_SETTINGS_CLUB_PLAY_DISTRIBUTION)
end

function NewClubSetPartnerPercentLayer:onCreate(param)
	self.clubData = param[1]
	local playwaynum = self:getPlayWayNums()
	if playwaynum > 0 then
		self.Image_noPlayway:setVisible(false)
		self.Image_partnerFrame:setVisible(true)
		self:loadPlaywayList()
	else
		self.Image_noPlayway:setVisible(true)
		self.Image_partnerFrame:setVisible(false)
	end
end

function NewClubSetPartnerPercentLayer:onClose()
	self:removeFromParent()
end

function NewClubSetPartnerPercentLayer:loadPlaywayList()
	self.ListView_playwayList:removeAllItems()
	local count = 0
	for i,id in ipairs(self.clubData.dwPlayID) do
		local kindid = self.clubData.wKindID[i]
        local gameinfo = StaticData.Games[kindid]
        if id ~= 0 and gameinfo then
        	count = count + 1
	        local item = self.Button_item:clone()
            self.ListView_playwayList:pushBackCustomItem(item)
            item.playwayId = id
            local AtlasLabel_index = ccui.Helper:seekWidgetByName(item, 'AtlasLabel_index')
            local Text_gameName = ccui.Helper:seekWidgetByName(item, 'Text_gameName')
            local Text_playwayName = ccui.Helper:seekWidgetByName(item, 'Text_playwayName')
            Text_gameName:setColor(cc.c3b(160, 87, 8))
            Text_playwayName:setColor(cc.c3b(160, 87, 8))
            AtlasLabel_index:setString(count)
            Text_gameName:setString(gameinfo.name)
            if self.clubData.szParameterName[i] ~= "" and self.clubData.szParameterName[i] ~= " " then
		        Text_playwayName:setString(self.clubData.szParameterName[i])
		    else
		        Text_playwayName:setString(gameinfo.name)
		    end

		    if count == 1 then
	    		item:setBright(false)
		        item:setTouchEnabled(false)
		        self.lastPressBtn = item
		        self.ListView_partner:removeAllItems()
		        UserData.Guild:getClubPlayDistribution(self.clubData.dwClubID, id, UserData.User.userID)
		    end

		    item:setPressedActionEnabled(true)
		    item:addClickEventListener(function(sender)
		        require("common.Common"):playEffect("common/buttonplay.mp3")
		        if self.lastPressBtn then
		        	self.lastPressBtn:setBright(true)
		        	self.lastPressBtn:setTouchEnabled(true)
		        end
		        item:setBright(false)
		        item:setTouchEnabled(false)
		        self.lastPressBtn = item
		        self.ListView_partner:removeAllItems()
		        UserData.Guild:getClubPlayDistribution(self.clubData.dwClubID, id, UserData.User.userID)
		    end)
        end
	end
end

function NewClubSetPartnerPercentLayer:getPlayWayNums()
    local num = 0
    for i,v in ipairs(self.clubData.wKindID or {}) do
        local gameinfo = StaticData.Games[v]
        if v ~= 0 and gameinfo then
            num = num + 1
        end
    end
    return num
end

function NewClubSetPartnerPercentLayer:RET_CLUB_PLAY_DISTRIBUTION(event)
	local data = event._usedata
	dump(data)
    if data.lRet ~= 0 then
    	require("common.MsgBoxLayer"):create(0,nil,"获取亲友群玩法分成失败. lRet=" .. data.lRet)
        return
    end

    local item = self.Image_item:clone()
    self.ListView_partner:pushBackCustomItem(item)
    item:setName('Club_Percent_Item' .. data.dwUserID)
    local Image_head = ccui.Helper:seekWidgetByName(item, 'Image_head')
    local Text_offer = ccui.Helper:seekWidgetByName(item, 'Text_offer')
    local Text_name = ccui.Helper:seekWidgetByName(item, 'Text_name')
    local Text_id = ccui.Helper:seekWidgetByName(item, 'Text_id')
    local Text_percent = ccui.Helper:seekWidgetByName(item, 'Text_percent')
    local Button_control = ccui.Helper:seekWidgetByName(item, 'Button_control')
    Text_offer:setColor(cc.c3b(131, 88, 45))
    Text_name:setColor(cc.c3b(131, 88, 45))
    Text_id:setColor(cc.c3b(131, 88, 45))
    Text_percent:setColor(cc.c3b(131, 88, 45))
	Common:requestUserAvatar(data.dwUserID, data.szLogoInfo, Image_head, "img")
	Text_offer:setString(string.format('%d级合伙人', data.dwPartnerLevel))
	Text_name:setString(data.szNickName)
	Text_id:setString(data.dwUserID)
	Text_percent:setString(data.dwDistributionRatio .. '%')
	self.Text_myPercent:setString(string.format('自己比例:%d', data.dwAdministratorDistributionRatio) .. '%')

    Common:addTouchEventListener(Button_control, function()
    	local node = require("app.MyApp"):create(nil, 4, function(value)
        	UserData.Guild:setClubPlayDistribution(self.clubData.dwClubID, self.lastPressBtn.playwayId, UserData.User.userID, data.dwUserID, value)
        end):createView("NewClubInputFatigueLayer")
        self:addChild(node)
    end)
end

function NewClubSetPartnerPercentLayer:RET_SETTINGS_CLUB_PLAY_DISTRIBUTION(event)
	local data = event._usedata
    if data.lRet ~= 0 then
    	if data.lRet == 1 then
			require("common.MsgBoxLayer"):create(0,nil,"设置玩法分成比例不能大于自身比例!")
		elseif data.lRet == 2 then
			require("common.MsgBoxLayer"):create(0,nil,"目标成员不存在!")
		elseif data.lRet == 3 then
			require("common.MsgBoxLayer"):create(0,nil,"分成模式不支持!")
		elseif data.lRet == 4 then
			require("common.MsgBoxLayer"):create(0,nil,"玩法模式不支持!")
		elseif data.lRet == 5 then
			require("common.MsgBoxLayer"):create(0,nil,"权限不足!")
		else
			require("common.MsgBoxLayer"):create(0,nil,"设置亲友群玩法分成失败. lRet=" .. data.lRet)
    	end
        return
    end

    local item = self.ListView_partner:getChildByName('Club_Percent_Item' .. data.dwTargetUserID)
    if item then
    	local Text_percent = ccui.Helper:seekWidgetByName(item, 'Text_percent')
    	Text_percent:setString(data.dwDistributionRatio .. '%')
    end
end

return NewClubSetPartnerPercentLayer