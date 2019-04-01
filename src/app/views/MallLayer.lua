local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Bit = require("common.Bit")
local HttpUrl = require("common.HttpUrl")

local MallLayer = class("MallLayer", cc.load("mvc").ViewBase)

function MallLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_MALL_BUYGOODS,self,self.SUB_CL_MALL_BUYGOODS)
    EventMgr:registListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
    EventMgr:registListener(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,self,self.EVENT_TYPE_RECHARGE_GET_ORDER)
    EventMgr:registListener(EventType.EVENT_TYPE_RECHARGE_PAY_RESULT,self,self.EVENT_TYPE_RECHARGE_PAY_RESULT)
    EventMgr:registListener(EventType.SUB_CL_RECHARGE_RECORD,self,self.SUB_CL_RECHARGE_RECORD)

end

function MallLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_MALL_BUYGOODS,self,self.SUB_CL_MALL_BUYGOODS)
    EventMgr:unregistListener(EventType.SUB_CL_USER_INFO,self,self.SUB_CL_USER_INFO)
    EventMgr:unregistListener(EventType.EVENT_TYPE_RECHARGE_GET_ORDER,self,self.EVENT_TYPE_RECHARGE_GET_ORDER)
    EventMgr:unregistListener(EventType.EVENT_TYPE_RECHARGE_PAY_RESULT,self,self.EVENT_TYPE_RECHARGE_PAY_RESULT)
    EventMgr:unregistListener(EventType.SUB_CL_RECHARGE_RECORD,self,self.SUB_CL_RECHARGE_RECORD)
    if self.uiPanel_rechargeDefault then
        self.uiPanel_rechargeDefault:release()
        self.uiPanel_rechargeDefault = nil
    end
end

function MallLayer:onCreate(parames)
--    if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER and StaticData.Hide[CHANNEL_ID].btn1 == 1 and UserData.Guild.dwGuildID == 0 then
--        self:runAction(cc.Sequence:create(
--            cc.DelayTime:create(0),
--            cc.CallFunc:create(function(sender,event) 
--            require("common.MsgBoxLayer"):create(0,nil,"请先加入公会!")
--            require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer")) 
--        end)))
--        return
--    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("MallLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    
    --初始化充值
    self.uiPanel_rechargeDefault = ccui.Helper:seekWidgetByName(self.root,"Panel_rechargeDefault")
    self.uiPanel_rechargeDefault:retain()
    local uiPanel_pay = ccui.Helper:seekWidgetByName(self.root,"Panel_pay")
    uiPanel_pay:setVisible(false)
    uiPanel_pay:setTouchEnabled(true)
    uiPanel_pay:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_pay:setVisible(false)
        end
    end)
   
    self:updateRechargeUI()
    
    --初始化道具商城
    local uiPanel_prop = ccui.Helper:seekWidgetByName(self.root,"Panel_prop")
    local uiListView_prop = ccui.Helper:seekWidgetByName(self.root,"ListView_prop")
    local uiPanel_propDefault = ccui.Helper:seekWidgetByName(self.root,"Panel_propDefault")
    uiPanel_propDefault:retain()
    uiListView_prop:removeAllItems()
    local uiListView_prop1 = ccui.Helper:seekWidgetByName(self.root,"ListView_prop1")
    uiListView_prop1:removeAllItems()
    for key, var in pairs(UserData.Mall.tableMallProp) do
        local item = uiPanel_propDefault:clone()
        local uiButton_buy = ccui.Helper:seekWidgetByName(item,"Button_buy")
        local uiImage_moeny = ccui.Helper:seekWidgetByName(item,"Image_moeny")
        local uiImage_title = ccui.Helper:seekWidgetByName(item,"Image_title")
        local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
        Common:addTouchEventListener(uiButton_buy,function() 
            require("common.MsgBoxLayer"):create(1,nil,string.format("您确定要购买%s？",StaticData.Mall[var.wGoodsID].name),function() 
                self:buyProp(var)
            end)
        end)
        local dwGold = Common:itemNumberToString(var.dwGetPrice)   
        local texture = cc.TextureCache:getInstance():addImage(StaticData.Mall[var.wGoodsID].img)
        uiImage_icon:loadTexture(StaticData.Mall[var.wGoodsID].img)
        uiImage_icon:setContentSize(texture:getContentSizeInPixels())
--        uiImage_title:loadTexture(string.format("mall/good_%d.png",var.wGoodsID))
--        uiImage_moeny:loadTexture(string.format("mall/goods_%d.png",var.wGoodsID))
        
        uiImage_title:setVisible(false)
        uiImage_moeny:setVisible(false)
        local uiText_moeny = cc.Label:createWithSystemFont(string.format("%d金币",var.dwGetPrice),"Arial",24)
        uiText_moeny:setTextColor(cc.c3b(255,255,139))
        uiImage_moeny:getParent():addChild(uiText_moeny)
        uiText_moeny:setPosition(cc.p(uiImage_moeny:getPosition()))
        
        local uiText_title = cc.Label:createWithSystemFont(StaticData.Mall[var.wGoodsID].name,"Arial",24)
        uiText_title:setTextColor(cc.c3b(255,255,139))
        uiImage_title:getParent():addChild(uiText_title)
        uiText_title:setPosition(cc.p(uiImage_title:getPosition()))
        
        if var.wGoodsID - 1000 > 4 then 
            uiListView_prop1:pushBackCustomItem(item)
        else 
            uiListView_prop:pushBackCustomItem(item)
        end
        item:setScale(0)
        item:setAnchorPoint(cc.p(0.5,0.5))
        item:stopAllActions()
        item:runAction(cc.Sequence:create(cc.DelayTime:create(0.2*(key)),cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))   
    end
    uiPanel_propDefault:release()
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_recharge"),function() self:showUI(1) end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_prop"),function() self:showUI(2) end)
    --左右滑动

--    local uiButton_right = ccui.Helper:seekWidgetByName(self.root,"Button_right")
--    Common:addTouchEventListener(uiButton_right,function() 
--        local uiListView = nil
--        if uiPanel_recharge:isVisible() then
--            uiListView = ccui.Helper:seekWidgetByName(self.root,"ListView_recharge")
--        else
--            uiListView = ccui.Helper:seekWidgetByName(self.root,"ListView_prop")
--        end
--        uiListView:scrollToRight(0.5,true)
--    end)
--    local uiButton_left = ccui.Helper:seekWidgetByName(self.root,"Button_left")
--    Common:addTouchEventListener(uiButton_left,function() 
--        local uiListView = nil
--        if uiPanel_recharge:isVisible() then
--            uiListView = ccui.Helper:seekWidgetByName(self.root,"ListView_recharge")
--        else
--            uiListView = ccui.Helper:seekWidgetByName(self.root,"ListView_prop")
--        end
--        uiListView:scrollToLeft(0.5,true)
--    end)

    
    self:updateUserInfo()
    if StaticData.Hide[CHANNEL_ID].btn8 ~= 1 then
        self:showUI(2)
        local uiButton_recharge = ccui.Helper:seekWidgetByName(self.root,"Button_recharge")
        local uiButton_prop = ccui.Helper:seekWidgetByName(self.root,"Button_prop")
        uiButton_recharge:setVisible(false)
        uiButton_prop:setVisible(false)     
        if StaticData.Hide[CHANNEL_ID].btn9 ~= 1  then
            uiButton_prop:setVisible(false)
        end 
    else
        if parames[1] == nil or parames[1] == 1 then
            self:showUI(1)
        else
            self:showUI(2)
        end
    end
end

function MallLayer:showUI(index)
    local uiPanel_recharge = ccui.Helper:seekWidgetByName(self.root,"Panel_recharge")
    local uiPanel_prop = ccui.Helper:seekWidgetByName(self.root,"Panel_prop")
    local uiButton_recharge = ccui.Helper:seekWidgetByName(self.root,"Button_recharge")
    local uiButton_prop = ccui.Helper:seekWidgetByName(self.root,"Button_prop")
 
	if index == 1 then
	    uiPanel_recharge:setVisible(true)
	    uiPanel_prop:setVisible(false)
	    uiButton_recharge:setBright(false)
	    uiButton_prop:setBright(true)   
        if StaticData.Hide[CHANNEL_ID].btn9 ~= 1  then 
	        uiButton_prop:setBright(false)
            uiButton_prop:setVisible(false)
        end   
        local index = 0
        for key, var in pairs(uiPanel_recharge:getChildren()) do
            for k, v in pairs(var:getItems()) do
                v:setScale(0)
                v:setAnchorPoint(cc.p(0.5,0.5))
                v:stopAllActions()
                v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(index)),cc.ScaleTo:create(0.4,1.1),cc.ScaleTo:create(0.2,1)))  
                index = index + 1 
            end
        end                           
	else
        uiPanel_recharge:setVisible(false)
        uiPanel_prop:setVisible(true)
        uiButton_recharge:setBright(true)
        uiButton_prop:setBright(false)
        local index = 0
        for key, var in pairs(uiPanel_prop:getChildren()) do
            for k, v in pairs(var:getItems()) do
                v:setScale(0)
                v:setAnchorPoint(cc.p(0.5,0.5))
                v:stopAllActions()
                v:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(index)),cc.ScaleTo:create(0.4,1.1),cc.ScaleTo:create(0.2,1)))  
                index = index + 1 
            end
        end 
	end
end

function MallLayer:updateUserInfo()
    local uiImage_goldBg = ccui.Helper:seekWidgetByName(self.root,"Image_goldBg")
    local uiText_gold = ccui.Helper:seekWidgetByName(self.root,"Text_gold")
    local dwGold = Common:itemNumberToString(UserData.User.dwGold)   
    uiText_gold:setString(tostring(dwGold))
    local uiText_roomCard = ccui.Helper:seekWidgetByName(self.root,"Text_roomCard")
    uiText_roomCard:setString(string.format("%d",UserData.Bag:getBagPropCount(1003)))
end

function MallLayer:updateRechargeUI()
    local uiPanel_pay = ccui.Helper:seekWidgetByName(self.root,"Panel_pay")
    local uiPanel_recharge = ccui.Helper:seekWidgetByName(self.root,"Panel_recharge")
    uiPanel_recharge:setVisible(false)
    local uiListView_recharge = ccui.Helper:seekWidgetByName(self.root,"ListView_recharge")
    uiListView_recharge:removeAllItems()
     local uiListView_recharge1 = ccui.Helper:seekWidgetByName(self.root,"ListView_recharge1")
    uiListView_recharge1:removeAllItems()
    local tableRecord = {}
    if UserData.Mall.talbeRecharge.szFistRechargeRecord then
        local temp = Common:stringSplit(UserData.Mall.talbeRecharge.szFistRechargeRecord,"_")
        for key, var in pairs(temp) do
            tableRecord[tonumber(var)] = tonumber(var)
        end
    end
    for key, var in pairs(UserData.Mall.tableRechargeConfig) do
        local item = self.uiPanel_rechargeDefault:clone()
        item.wRechargeID = var.wRechargeID
        if item.wRechargeID ~= 1009 then   
            local uiButton_buy = ccui.Helper:seekWidgetByName(item,"Button_buy")
            local uiImage_title = ccui.Helper:seekWidgetByName(item,"Image_title")
            local uiImage_moeny = ccui.Helper:seekWidgetByName(item,"Image_money")
            local uiImage_icon = ccui.Helper:seekWidgetByName(item,"Image_icon")
            local uiImage_first = ccui.Helper:seekWidgetByName(item,"Image_first")
            local uiText_first = ccui.Helper:seekWidgetByName(item,"Text_first")
    
            local function switchPayType()
                uiPanel_pay:setVisible(true)
                local uiPanel_payType = ccui.Helper:seekWidgetByName(self.root,"Panel_payType")
                uiPanel_payType:removeAllChildren()
                local payTypeBtn = nil
                for i = 1 , 3 do
                    local value = Bit:_and(Bit:_rshift(StaticData.Channels[CHANNEL_ID].payType,i-1),1)
                    if value == 1 then
                        local filename = string.format("mall/pay_%d.png",i)
                        payTypeBtn = ccui.Button:create(filename,filename,filename)
                        uiPanel_payType:addChild(payTypeBtn)
                        self.payType = i
                        Common:addTouchEventListener(payTypeBtn,function() 
                            self.rechargeConfig = clone(var)
                            self.payType = i
                            self:recharge()
                            uiPanel_pay:setVisible(false)
                        end)
                    end
                end
                if uiPanel_payType:getChildrenCount() == 1 then
                    self.rechargeConfig = clone(var)
                    self:recharge() 
                    uiPanel_pay:setVisible(false)
                else
                    --调整位置
                    local width = 245
                    local surplus = (uiPanel_payType:getContentSize().width - width*uiPanel_payType:getChildrenCount())/(uiPanel_payType:getChildrenCount()+1)
                    for key, var in pairs(uiPanel_payType:getChildren()) do
                        var:setPosition(surplus*key + (key-1)*width + width/2,var:getParent():getContentSize().height/2)
                    end
                    uiPanel_pay:stopAllActions()
                    Common:playPopupAnim(uiPanel_pay)
                end
            end
            Common:addTouchEventListener(uiButton_buy,switchPayType)
            uiImage_icon:loadTexture(string.format("mall/recharge%d.png",var.wRechargeID))
--            uiImage_title:loadTexture(string.format("mall/recharge_%d.png",var.wRechargeID))
--            uiImage_moeny:loadTexture(string.format("mall/recharges_%d.png",var.wRechargeID))
            uiImage_title:setVisible(false)
            uiImage_moeny:setVisible(false)
            local uiText_moeny = cc.Label:createWithSystemFont(string.format("%d元",var.dwPrice),"Arial",24)
            uiText_moeny:setTextColor(cc.c3b(255,255,139))
            uiImage_moeny:getParent():addChild(uiText_moeny)
            uiText_moeny:setPosition(cc.p(uiImage_moeny:getPosition()))

            local uiText_title = cc.Label:createWithSystemFont(string.format("%s",var.szTitle),"Arial",24)
            uiText_title:setTextColor(cc.c3b(255,255,139))
            uiImage_title:getParent():addChild(uiText_title)
            uiText_title:setPosition(cc.p(uiImage_title:getPosition()))
            
            if var.wFistRewardNum > 0 then
                uiImage_first:setVisible(true)
                local contents = ""
                for i = 1 , var.wFistRewardNum do
                    if StaticData.Items[var.tFistReward[i].wPropID] ~= nil then
                        if contents ~= "" then
                            contents = contents.."+"
                        end
                        print("请求订单2",var.wRechargeID,StaticData.Items[var.tFistReward[i].wPropID].name,var.tFistReward[i].dwPropCount)
                        local dwPropCount = Common:itemNumberToString(var.tFistReward[i].dwPropCount)
                        contents = contents..string.format("%sx%s",StaticData.Items[var.tFistReward[i].wPropID].name,dwPropCount)
                    end
                end
                uiText_first:setString(string.format("首充再送%s",contents))               
                uiText_first:setTextColor(cc.c3b(255,255,139))
                if tableRecord[var.wRechargeID] == nil then
                    uiImage_first:setVisible(true)
                else
                    uiImage_first:setVisible(false)
                end
            else
                uiImage_first:setVisible(false)
            end
            if var.wRechargeID - 1000 > 4 then 
                uiListView_recharge1:pushBackCustomItem(item)
            else 
                uiListView_recharge:pushBackCustomItem(item)
            end
        end 
    end
end

--充值
function MallLayer:recharge()
    print("请求订单",self.payType)
    printInfo(self.rechargeConfig)
    require("common.LoadingAnimationLayer"):create(3)
    UserData.Mall:requestGetOrder(self.rechargeConfig)
end

function MallLayer:EVENT_TYPE_RECHARGE_GET_ORDER(event)
	local data = event._usedata
	if data.ret ~= 0 then
	   closeLoadingAnimationLayer()
	   require("common.MsgBoxLayer"):create(0,nil,"获取订单失败!")
	   return
	end
    self.orderID = data.orderID
    UserData.Mall:doPay(data.orderID,self.payType,0,UserData.User.userID,self.rechargeConfig.dwPrice,0)
end

function MallLayer:EVENT_TYPE_RECHARGE_PAY_RESULT(event)
	local data = event._usedata
	if data ~= 0 then
        closeLoadingAnimationLayer()
	   require("common.MsgBoxLayer"):create(0,nil,"充值失败！")
	   return
	end
    local tableReward = clone(self.rechargeConfig.tFistReward)
    table.insert(tableReward,1,{wPropID = 1001,dwPropCount = self.rechargeConfig.dwValue})
    if UserData.Mall.talbeRecharge.szFistRechargeRecord then
        local temp = Common:stringSplit(UserData.Mall.talbeRecharge.szFistRechargeRecord,"_")
        for key, var in pairs(temp) do
            if tonumber(var) == self.rechargeConfig.wRechargeID then
                tableReward = {{wPropID = 1001,dwPropCount = self.rechargeConfig.dwValue }}
                break
            end
        end
    end
    require("common.RewardLayer"):create("充值成功",nil,tableReward)
    UserData.Mall:sendMsgGetRechargeRecord()
    UserData.User:sendMsgUpdateUserInfo(1)
end

function MallLayer:SUB_CL_RECHARGE_RECORD(event)
	local data = event._usedata
	local uiListView_recharge = ccui.Helper:seekWidgetByName(self.root,"ListView_recharge")
    local items = uiListView_recharge:getItems()
    local tableRecord = {}
    if UserData.Mall.talbeRecharge.szFistRechargeRecord then
        local temp = Common:stringSplit(UserData.Mall.talbeRecharge.szFistRechargeRecord,"_")
        for key, var in pairs(temp) do
            tableRecord[tonumber(var)] = tonumber(var)
        end
    end
	for key, var in pairs(items) do
		local uiImage_first = ccui.Helper:seekWidgetByName(var,"Image_first")
		if tableRecord[var.wRechargeID] == nil then
            uiImage_first:setVisible(true)
        else
            uiImage_first:setVisible(false)
        end
	end
end

--购买
function MallLayer:buyProp(data)
	if UserData.User.userID < data.dwGetPrice then
        if StaticData.Hide[CHANNEL_ID].btn8 == 1 then
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,是否前往充值？",function() 
                self:showUI(1)
            end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
        return
	end
    UserData.Mall:sendMsgBuyProp(data.dwKeyID)
end

--购买结果
function MallLayer:SUB_CL_MALL_BUYGOODS(event)
	local data = event._usedata
	if data.wCode == 1000 then
        print("购买成功!")
	    UserData.User:sendMsgUpdateUserInfo(0)
        UserData.Bag:sendMsgGetBag(0)
        for key, var in pairs(UserData.Mall.tableMallProp) do
            if var.dwKeyID == data.dwKeyID then
                require("common.RewardLayer"):create("购买成功",nil,var.tFistReward)
                break
            end
        end
        
	elseif data.wCode == 1002 then
        if StaticData.Hide[CHANNEL_ID].btn8 == 1 then
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,是否前往充值？",function() 
                self:showUI(1)
            end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
    else
        require("common.MsgBoxLayer"):create(0,nil,"购买失败!")
	end
end

--刷新个人信息
function MallLayer:SUB_CL_USER_INFO(event)
    self:updateUserInfo()
end

return MallLayer