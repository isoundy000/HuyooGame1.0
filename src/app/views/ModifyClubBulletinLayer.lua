local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local NetMsgId = require("common.NetMsgId")

local ModifyClubBulletinLayer = class("ModifyClubBulletinLayer", cc.load("mvc").ViewBase)

function ModifyClubBulletinLayer:onEnter() 
    EventMgr:registListener(EventType.RET_UPDATE_GUILD,self,self.RET_UPDATE_GUILD) 
end

function ModifyClubBulletinLayer:onExit()
    EventMgr:unregistListener(EventType.RET_UPDATE_GUILD,self,self.RET_UPDATE_GUILD) 
end


function ModifyClubBulletinLayer:onCreate()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("ModifyClubDulletinLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)

    
    local uiTextField_bullentin = ccui.Helper:seekWidgetByName(self.root,"TextField_bullentin")

    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_submit"),function() 
        local input = uiTextField_bullentin:getString()
        if input == "" then
            require("common.MsgBoxLayer"):create(0,self,"请输入公告!")
            return
        else
            NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_GUILD,NetMsgId.REQ_UPDATE_GUILD,"dbns",UserData.Guild.dwGuildID,0,256,input)                   
        end
        print("请输入公告:",input)        
     end)
end
function ModifyClubBulletinLayer:RET_UPDATE_GUILD(event)
    local data = event._usedata
    if data.ret ~= 0 then
        require("common.MsgBoxLayer"):create(0,nil,"修改公告失败!")
    else 
        require("common.MsgBoxLayer"):create(0,nil,"修改公告成功!")
        UserData.Guild.szGuildNotice = data.szGuildNotice
        self:removeFromParent()
        EventMgr:dispatch(EventType.RET_UPDATE_GUILD)     
    end
     
end
   
return ModifyClubBulletinLayer