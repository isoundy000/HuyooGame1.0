local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local NetMsgId = require("common.NetMsgId")

local ModifyClubNameLayer = class("ModifyClubNameLayer", cc.load("mvc").ViewBase)

function ModifyClubNameLayer:onEnter() 
    EventMgr:registListener(EventType.RET_SETTINGS_CLUB,self,self.RET_SETTINGS_CLUB) 
end

function ModifyClubNameLayer:onExit()
    EventMgr:unregistListener(EventType.RET_SETTINGS_CLUB,self,self.RET_SETTINGS_CLUB) 
end


function ModifyClubNameLayer:onCreate(club)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("ModifyClubNameLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    self.dwClubID = club[1]
    self.szClubName = club[2]
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    local uiText_oldname = ccui.Helper:seekWidgetByName(self.root,"Text_oldname")
    uiText_oldname:setString(string.format("%s",self.szClubName)) 
    local uiText_ID = ccui.Helper:seekWidgetByName(self.root,"Text_ID")
    uiText_ID:setString(string.format("%d",self.dwClubID))
    
    local uiTextField_newname = ccui.Helper:seekWidgetByName(self.root,"TextField_newname")

    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_submit"),function() 
        local input = uiTextField_newname:getString()
        if input == "" then
            require("common.MsgBoxLayer"):create(0,self,"请输入亲友圈新昵称!")
            return
        else
            NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_CLUB,NetMsgId.REQ_SETTINGS_CLUB2,"bdnsonsdwww",
                3,self.dwClubID,32,input,false,256,"",0,0,0,1)
        end
        self:removeFromParent()
        print("请输入亲友圈新昵称:",input)
        
     end)
end
function ModifyClubNameLayer:RET_SETTINGS_CLUB(event)
    local data = event._usedata
    if data.lRet ~= 0 then
        require("common.MsgBoxLayer"):create(0,nil,"设置失败!")
    end
    require("common.MsgBoxLayer"):create(0,nil,"设置成功!")
    self.parent:removeAllChildren()
    UserData.Guild:refreshClub(data.dwClubID)
end
   
return ModifyClubNameLayer