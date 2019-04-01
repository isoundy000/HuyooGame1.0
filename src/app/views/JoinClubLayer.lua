local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")

local JoinClubLayer = class("JoinClubLayer", cc.load("mvc").ViewBase)

function JoinClubLayer:onEnter()
    EventMgr:registListener(EventType.RET_JOIN_CLUB,self,self.RET_JOIN_CLUB)
end

function JoinClubLayer:onExit()
    EventMgr:unregistListener(EventType.RET_JOIN_CLUB,self,self.RET_JOIN_CLUB) 
end


function JoinClubLayer:onCreate()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("JoinClubLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb

    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    
    local function roomNumberDefault()
        for i = 1 , 8 do       
            local uiText_number = ccui.Helper:seekWidgetByName(self.root,string.format("Text_number%d",i))
            uiText_number:setString("")
        end
    end
    roomNumberDefault()
    local function roomNumberAdd(num)
        local roomNumber = ""
        for i = 1 , 8 do
            local uiText_number = ccui.Helper:seekWidgetByName(self.root,string.format("Text_number%d",i))
            if uiText_number:getString() == "" then
                uiText_number:setString(tostring(num))
                roomNumber = roomNumber..uiText_number:getString()
                if i == 8 then  
                    self:joinClub(roomNumber)                      
                end
                break
            else
                roomNumber = roomNumber..uiText_number:getString()
            end
        end
    end
    local function roomNumberDel()
        for i = 8 , 1 , -1 do
            local uiText_number = ccui.Helper:seekWidgetByName(self.root,string.format("Text_number%d",i))
            if uiText_number:getString() ~= "" then
                uiText_number:setString("")
                break
            end
        end
    end
    local function onEventInput(sender,event)
        if event == ccui.TouchEventType.ended then
           Common:palyButton()
           local index = sender.index
           if index == 10 then
               roomNumberDefault()
           elseif index == 11 then
               roomNumberDel()
           else
               roomNumberAdd(index)
           end
        end
    end
    for i = 0 , 11 do
        local uiButton_num = ccui.Helper:seekWidgetByName(self.root,string.format("Button_num%d",i))
        uiButton_num:setPressedActionEnabled(true)
        uiButton_num:addTouchEventListener(onEventInput)
        uiButton_num.index = i
    end    
end

function JoinClubLayer:joinClub(dwClubID)
    local dwClubID = tonumber(dwClubID)
    UserData.Guild:joinClub(dwClubID)
end

function JoinClubLayer:RET_JOIN_CLUB(event)
    local data = event._usedata
    if data.lRet == 0 then
        require("common.MsgBoxLayer"):create(2,nil,"申请成功,等待群主审核!")
        self:removeFromParent()
    elseif data.lRet == 1 then 
        require("common.MsgBoxLayer"):create(0,nil,"亲友圈ID输入错误!")

    elseif data.lRet == 2 then
        require("common.MsgBoxLayer"):create(0,nil,"您已经存在该亲友圈,不可重复提交申请!")
        self:removeFromParent()
    else
        require("common.MsgBoxLayer"):create(0,nil,"申请加入失败,请升级到最新版本!")
        self:removeFromParent()
    end

end

return JoinClubLayer