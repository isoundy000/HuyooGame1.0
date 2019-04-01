local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Bit = require("common.Bit")
local HttpUrl = require("common.HttpUrl")

local PartnerLayer = class("PartnerLayer", cc.load("mvc").ViewBase)

function PartnerLayer:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,self,self.EVENT_TYPE_RECHARGE_GET_ORDER)
    EventMgr:registListener(EventType.EVENT_TYPE_RECHARGE_PAY_RESULT,self,self.EVENT_TYPE_RECHARGE_PAY_RESULT)
end

function PartnerLayer:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,self,self.EVENT_TYPE_RECHARGE_GET_ORDER)
    EventMgr:unregistListener(EventType.EVENT_TYPE_RECHARGE_PAY_RESULT,self,self.EVENT_TYPE_RECHARGE_PAY_RESULT)
end

function PartnerLayer:onCreate(parames)
    if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER and StaticData.Hide[CHANNEL_ID].btn1 == 1 and UserData.Guild.dwGuildID == 0 then
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0),
            cc.CallFunc:create(function(sender,event) 
                require("common.MsgBoxLayer"):create(0,nil,"请先加入公会!")
                require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer")) 
            end)))
        return
    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("PartnerLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb

    Common:addTouchEventListener(self.root,function() 
        require("common.SceneMgr"):switchOperation()
    end,true)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_365"),function() 
        for key, var in pairs(UserData.Mall.tableRechargeConfig) do
            if var.wRechargeID == 1009 then
                require("common.LoadingAnimationLayer"):create(3)
                UserData.Mall:requestGetOrder({dwKeyID = var.dwKeyID,dwPrice = var.dwPrice})
                break
            end
        end
    end)
    
end

--充值
function PartnerLayer:recharge()
    print("请求订单",self.payType)
    printInfo(self.rechargeConfig)
    require("common.LoadingAnimationLayer"):create(3)
    UserData.Mall:requestGetOrder(self.rechargeConfig)
end

function PartnerLayer:EVENT_TYPE_RECHARGE_GET_ORDER(event)
	local data = event._usedata
	if data.ret ~= 0 then
	   closeLoadingAnimationLayer()
	   require("common.MsgBoxLayer"):create(0,nil,"获取订单失败!")
	   return
	end
    self.orderID = data.orderID
    for key, var in pairs(UserData.Mall.tableRechargeConfig) do
        if var.wRechargeID == 1009 then
            require("common.LoadingAnimationLayer"):create(3)
            UserData.Mall:doPay(data.orderID,2,0,UserData.User.userID,var.dwPrice,0)
            break
        end
    end
end

function PartnerLayer:EVENT_TYPE_RECHARGE_PAY_RESULT(event)
	local data = event._usedata
	if data ~= 0 then
        closeLoadingAnimationLayer()
	   require("common.MsgBoxLayer"):create(0,nil,"充值失败！")
	   return
	end
    for key, var in pairs(UserData.Mall.tableRechargeConfig) do
        if var.wRechargeID == 1009 then
            local tableReward = clone(var.tFistReward)
            table.insert(tableReward,1,{wPropID = 1001,dwPropCount = var.dwValue})
            require("common.RewardLayer"):create("恭喜您成为合伙人",nil,tableReward)
            break
        end
    end
    UserData.Mall:RequestRecharge365()
    UserData.User:sendMsgUpdateUserInfo(1)    
    self:removeFromParent()
end

return PartnerLayer