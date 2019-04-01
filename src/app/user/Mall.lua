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

local Mall = {
    className = "com/coco2dx/org/HelperAndroid",
    talbeRecharge = {},
    tableRechargeConfig = {},
    tableMallProp = {},
}

local luaj = nil
if PLATFORM_TYPE == cc.PLATFORM_OS_ANDROID then
    luaj = require("cocos.cocos2d.luaj")
end

function Mall:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:registListener(EventType.EVENT_TYPE_FIRST_ENTER_HALL,self,self.EVENT_TYPE_FIRST_ENTER_HALL)
    
end

function Mall:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:unregistListener(EventType.EVENT_TYPE_FIRST_ENTER_HALL,self,self.EVENT_TYPE_FIRST_ENTER_HALL)
end

function Mall:EVENT_TYPE_NET_RECV_MESSAGE(event)
    local netID = event._usedata
    local netInstance = nil
    if netID == NetMgr.NET_LOGIN then
        netInstance = NetMgr:getLoginInstance()
    elseif netID == NetMgr.NET_LOGIC then
        netInstance = NetMgr:getLogicInstance()
    else
        return
    end
    local mainCmdID = netInstance.cppFunc:GetMainCmdID()
    local subCmdID = netInstance.cppFunc:GetSubCmdID()

    if netID == NetMgr.NET_LOGIC and mainCmdID == NetMsgId.MDM_CL_RECHARGE  and subCmdID == NetMsgId.SUB_CL_RECHARGE_CONFIG then
        --充值配置
        local data = {}
        data.dwKeyID = netInstance.cppFunc:readRecvDWORD()                      --主键
        data.dwChannelID = netInstance.cppFunc:readRecvDWORD()                   --渠道ID
        data.wRechargeID = netInstance.cppFunc:readRecvWORD()                    --充值ID
        data.wSortID = netInstance.cppFunc:readRecvWORD()                        --排序ID
        data.bIsOpen = netInstance.cppFunc:readRecvBool()                        --是否开启
        data.dwPrice = netInstance.cppFunc:readRecvDWORD()                       --充值价格
        data.dwValue = netInstance.cppFunc:readRecvDWORD()                       --充值数量
        data.szTitle = netInstance.cppFunc:readRecvString(32)                    --充值标题
        data.wFistRewardNum = netInstance.cppFunc:readRecvWORD()                --首充奖励
        data.tFistReward = {}
        for i = 1 , 5 do
            local rewardData = {}
            rewardData.wPropID = netInstance.cppFunc:readRecvWORD()
            rewardData.dwPropCount = netInstance.cppFunc:readRecvDWORD()
            data.tFistReward[i] = rewardData
        end
        if data.bIsOpen == true then
            self.tableRechargeConfig[data.wSortID] = data
        end
    elseif netID == NetMgr.NET_LOGIC and mainCmdID == NetMsgId.MDM_CL_RECHARGE  and subCmdID == NetMsgId.SUB_CL_RECHARGE_RECORD then
        --充值记录
        local data = {}
        data.wRecordCount = netInstance.cppFunc:readRecvWORD()                   --记录条数
        data.szFistRechargeRecord = netInstance.cppFunc:readRecvString(64)       --首充记录
        self.talbeRecharge = data
        printInfo(self.talbeRecharge)
        EventMgr:dispatch(EventType.SUB_CL_RECHARGE_RECORD)
    elseif netID == NetMgr.NET_LOGIC and mainCmdID == NetMsgId.MDM_CL_MALL  and subCmdID == NetMsgId.SUB_CL_MALL_CONFIG then
        --商城配置
        local data = {}
        data.dwKeyID = netInstance.cppFunc:readRecvDWORD()                      --主键
        data.dwChannelID = netInstance.cppFunc:readRecvDWORD()                    --渠道ID
        data.wMallID = netInstance.cppFunc:readRecvWORD()                       --商城ID
        data.wGoodsID = netInstance.cppFunc:readRecvWORD()                      --商品ID
        data.wSortID = netInstance.cppFunc:readRecvWORD()                        --排序ID
        data.bIsSell = netInstance.cppFunc:readRecvBool()                        --是否出售
        data.wGetWay = netInstance.cppFunc:readRecvWORD()                       --获得方式（1-金币购买 2-元宝购买）
        data.dwGetPrice = netInstance.cppFunc:readRecvDWORD()                     --获得价格
        data.wFistRewardNum = netInstance.cppFunc:readRecvWORD()                --首充奖励
        data.tFistReward = {}
        for i = 1 , 5 do
            local rewardData = {}
            rewardData.wPropID = netInstance.cppFunc:readRecvWORD()
            rewardData.dwPropCount = netInstance.cppFunc:readRecvDWORD()
            data.tFistReward[i] = rewardData
        end
        if data.bIsSell == true and data.wMallID == 1 and data.wGetWay == 1 then
            self.tableMallProp[data.wSortID] = data
        end
        
    elseif netID == NetMgr.NET_LOGIC and mainCmdID == NetMsgId.MDM_CL_MALL  and subCmdID == NetMsgId.SUB_CL_MALL_BUYGOODS then
        local data = {}
        data.wCode = netInstance.cppFunc:readRecvWORD()     --1000成功  1001失败   1002金币不足
        data.dwKeyID = netInstance.cppFunc:readRecvDWORD()
        EventMgr:dispatch(EventType.SUB_CL_MALL_BUYGOODS,data)
    else
    
    end
--逻辑服返回咨询结果  
end

function Mall:EVENT_TYPE_FIRST_ENTER_HALL(event)
    self:sendMsgGetRechargeRecord()
    self.tableRechargeConfig = {}
    self.tableMallProp = {}
 
    --请求充值配置
    NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_RECHARGE,NetMsgId.REQ_CL_RECHARGE_CONFIG,"d",CHANNEL_ID)
    --请求商城配置
    NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_MALL,NetMsgId.REQ_CL_MALL_CONFIG,"dw",CHANNEL_ID,1)
end

function Mall:sendMsgGetRechargeRecord()
    --请求充值记录
    self.talbeRecharge = {}
    NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_RECHARGE,NetMsgId.REQ_CL_RECHARGE_RECORD,"d",require("app.user.UserData").User.userID)
end

function Mall:sendMsgBuyProp(dwKeyID)
    NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_MALL, NetMsgId.REQ_CL_MALL_BUYGOODS,"wd",0,dwKeyID)
end

function Mall:requestGetOrder(data)
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("POST",HttpUrl.POST_URL_GameUserOrder)
    local function onHttpRequestCompletedGetOrderform()
        if xmlHttpRequest.status == 200 then
            print("获取订单号：",xmlHttpRequest.response)
            local response = json.decode(xmlHttpRequest.response)
            if response["Basis"]["Status"] == 100 then
                local data = {}
                data.ret = 0
                data.orderID = response["Result"]["OrderID"]
                EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,data)
                return
            end
        end
        EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,{ret = -1})
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompletedGetOrderform)
    xmlHttpRequest:send(string.format("{'query':{'UserId':'%d','Price':'%d','GoodsID':'%d','ChannelID':'%d'},'global':{'Sign':'bdjee766823sdds8767d'}}",
        require("app.user.UserData").User.userID,data.dwPrice,data.dwKeyID,CHANNEL_ID))
end

function Mall:requestGetPayReward(orderID,data)
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("POST",HttpUrl.POST_URL_GameUserGetPayReward)
    local function onHttpRequestCompletedCheckOrderform()
        if xmlHttpRequest.status == 200 then 
            print("充值结果：",xmlHttpRequest.response)
            local response = json.decode(xmlHttpRequest.response)
            if response["Basis"]["Status"] == 100 then
                local data = {}
                data.ret = 0
                data.orderID = response["Result"]["OrderID"]
                EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_GET_REWARD_RESULT,data)
                return
            end
        end
        EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_GET_REWARD_RESULT,{ret = -1})
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompletedCheckOrderform)
    xmlHttpRequest:send(string.format("{'query':{'OrderID':'%d','UserId':'%d','Price':'%d','ChannelID':'%d','GoodsID':'%d','BookNo':'%d'},'global':{'Sign':'bdjee766823sdds8767d'}}",
        orderID,require("app.user.UserData").User.userID,data.dwPrice,CHANNEL_ID,data.dwKeyID,0))
end

--SDK支付
function Mall:doPay(orderform,type,payCode,UserId,Money,chargeCode)
    orderform = tostring(orderform)
    type = tostring(type)
    payCode = tostring(payCode)
    UserId = tostring(UserId)
    Money = tostring(Money)
    chargeCode = tostring(chargeCode)
    local Common = require("common.Common")
    if PLATFORM_TYPE == cc.PLATFORM_OS_ANDROID  then
        local methodName = "jniDoPay" 
        local args = { orderform,type,payCode,UserId,Money,chargeCode }  
        local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String)V" 
        luaj.callStaticMethod(self.className ,methodName,args , nil)
    elseif PLATFORM_TYPE == cc.PLATFORM_OS_APPLE_REAL then
        cus.JniControl:getInstance():doWPPay(orderform,type,payCode,UserId,Money)
    end    
end

--SDK支付回调
function cc.exports.setPayResult(data)
    cc.Director:getInstance():getRunningScene():runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_PAY_RESULT,tonumber(data)) end)))    
end

function Mall:RequestRecharge365()
    local UserData = require("app.user.UserData")
    local xmlHttpRequest = cc.XMLHttpRequest:new()
    xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
    xmlHttpRequest:open("GET",string.format(HttpUrl.POST_URL_GetIsPay365,UserData.User.userID))
    local function onHttpRequestCompleted()
        if xmlHttpRequest.status == 200 then
            local data = json.decode(xmlHttpRequest.response)
            local ret = data["ret"] 
            EventMgr:dispatch(EventType.EVENT_TYPE_RECHARGE_365,ret)    
        end      
    end
    xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
    xmlHttpRequest:send() 
end

return Mall