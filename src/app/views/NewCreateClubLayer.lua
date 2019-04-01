--[[
*名称:NewCreateClubLayer
*描述:亲友圈创建
*作者:admin
*创建日期:2018-06-22 17:01:52
*修改日期:
]]

local EventMgr              = require("common.EventMgr")
local EventType             = require("common.EventType")
local NetMgr                = require("common.NetMgr")
local NetMsgId              = require("common.NetMsgId")
local StaticData            = require("app.static.StaticData")
local UserData              = require("app.user.UserData")
local Common                = require("common.Common")
local Default               = require("common.Default")
local GameConfig            = require("common.GameConfig")

local NewCreateClubLayer    = class("NewCreateClubLayer", cc.load("mvc").ViewBase)

function NewCreateClubLayer:onConfig()
    self.widget             = {
        {"Button_close", "onClose"},
        {"TextField_name"},
        {"Button_create","onCreateClub"},
    }
end

function NewCreateClubLayer:onEnter()
    EventMgr:registListener(EventType.RET_CREATE_CLUB,self,self.RET_CREATE_CLUB)
end

function NewCreateClubLayer:onExit()
    EventMgr:unregistListener(EventType.RET_CREATE_CLUB,self,self.RET_CREATE_CLUB)
end

function NewCreateClubLayer:onCreate()
    -- body
end

function NewCreateClubLayer:onClose()
    self:removeFromParent()
end

function NewCreateClubLayer:onCreateClub()
    local input = self.TextField_name:getString()
    if input == "" then
        require("common.MsgBoxLayer"):create(0,self,"请输入亲友圈昵称!")
        return
    end
    UserData.Guild:createClub(input)
end

function NewCreateClubLayer:RET_CREATE_CLUB(event)
    local data = event._usedata
    self:removeFromParent()
end

return NewCreateClubLayer