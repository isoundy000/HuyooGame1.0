local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")

local TuHaoActivityLayer = class("TuHaoActivityLayer", cc.load("mvc").ViewBase)

function TuHaoActivityLayer:onEnter()  
    EventMgr:registListener(EventType.SUB_SC_TUHAOACTIVI,self,self.SUB_SC_TUHAOACTIVI) 
end

function TuHaoActivityLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_TUHAOACTIVI,self,self.SUB_SC_TUHAOACTIVI) 
end

function TuHaoActivityLayer:onCreate()
    cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_TuHaoActivity,os.time())  
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("TuHaoActivityLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        require("common.SceneMgr"):switchOperation()
    end)
    self.Showreward = false 
    self.Panel_table = ccui.Helper:seekWidgetByName(self.root,"Panel_table")  --小战绩
    self.Panel_table:retain()
    self.Panel_table:setVisible(false)

    self.uiPanel_action = ccui.Helper:seekWidgetByName(self.root,"Panel_action")


    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_enter"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  
    end)
    self.uiListView_table = ccui.Helper:seekWidgetByName(self.root,"ListView_table")
    self.uiListView_table:removeAllChildren()    
    UserData.GuildActivity.RequestTuHaoRanking()
    -- self:Action()  
end

function TuHaoActivityLayer:SUB_SC_TUHAOACTIVI(event)
    local data = event._usedata
    self.uiListView_table:removeAllChildren()
    if data["ret"] ~= 0 then          
        local Text_myname = ccui.Helper:seekWidgetByName(self.root,"Text_myname")
        Text_myname:setString("暂无数据")
        Text_myname:setTextColor(cc.c3b(22,0,0))  
        for i = 1 , 10 do
            local item = self.Panel_table:clone()
            item:setVisible(true)
            self.uiListView_table:pushBackCustomItem(item)  
            local uiImage_table = ccui.Helper:seekWidgetByName(item,"Image_table")
            if (i+1)%2 == 0 then
                uiImage_table:loadTexture("GuildActivity/guild_activity_11.png")
            else
                uiImage_table:loadTexture("GuildActivity/guild_activity_10.png")
            end  
            item:setScale(0,1)
            item:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.01),cc.ScaleTo:create(0.01,1.0,1.0)))  
        end   
        return      
    end 
    for key, var in pairs(data["Msg"]) do
        --        local var = data["Msg"]         --pairs()
        local topData = {}
        topData.RowNumber = var["RowNumber"]
        topData.WinCount = var["WinCount"]
        topData.UserID = var["UserID"]
        topData.NickName = var["NickName"]
        local item = self.Panel_table:clone()
        item:setVisible(true)
        self.uiListView_table:pushBackCustomItem(item)   
        local uiImage_table = ccui.Helper:seekWidgetByName(item,"Image_table")
        if key%2 == 1 then
            uiImage_table:loadTexture("GuildActivity/guild_activity_11.png")
        else
            uiImage_table:loadTexture("GuildActivity/guild_activity_10.png")
        end  
 
        local uiText_ranking = ccui.Helper:seekWidgetByName(item,"Text_ranking")
        uiText_ranking:setString("第"..tostring(topData.RowNumber).."名")
        uiText_ranking:setColor(cc.c3b(22,0,0))         
        local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
        uiText_name:setString(tostring(Common:getShortName(topData.NickName,10,10)))
        uiText_name:setColor(cc.c3b(22,0,0))          
        local uiText_num = ccui.Helper:seekWidgetByName(item,"Text_num")
        uiText_num:setString(tostring(topData.WinCount))
        uiText_num:setColor(cc.c3b(22,0,0)) 
        local uiText_TUHAO = ccui.Helper:seekWidgetByName(item,"Text_TUHAO")
        print("土豪榜：",topData.RowNumber)
        uiText_TUHAO:setString(tostring(self:GetThePrize(topData.RowNumber)))
        uiText_TUHAO:setTextColor(cc.c3b(22,0,0))          
        item:setScale(0,1)  
        item:runAction(cc.Sequence:create(cc.DelayTime:create(key*0.1),cc.ScaleTo:create(0.1,1.0,1.0)))        
        if  topData.UserID == UserData.User.userID then 
            local Text_myname = ccui.Helper:seekWidgetByName(self.root,"Text_myname")
            Text_myname:setString("第"..tostring(topData.RowNumber).."名")
            Text_myname:setTextColor(cc.c3b(22,0,0))           
            self.Showreward = true
        end 
    end

    if self.Showreward == false then 
        local Text_myname = ccui.Helper:seekWidgetByName(self.root,"Text_myname")
        Text_myname:setString("暂无数据")
        Text_myname:setTextColor(cc.c3b(22,0,0))         

    end 

    for i = #data["Msg"] , 9 do
        local item = self.Panel_table:clone()
        item:setVisible(true)
        self.uiListView_table:pushBackCustomItem(item)  
        local uiImage_table = ccui.Helper:seekWidgetByName(item,"Image_table")
        if (i+1)%2 == 1 then
            uiImage_table:loadTexture("GuildActivity/guild_activity_11.png")
        else
            uiImage_table:loadTexture("GuildActivity/guild_activity_10.png")
        end  
        item:setScale(0,1)
        item:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.001),cc.ScaleTo:create(0.1,1.0,1.0)))  
    end

end 

function TuHaoActivityLayer:GetThePrize(event)
 local data = nil
 if event == 1 then
        data = "IPhone 8"
        return data
 elseif  event == 2  then 
        data = "IPhone 7plus"
        return data  
 elseif  event == 3  then 
        data = "IPhone 7"
        return data  
 elseif  event == 4  then
        data = "200元红包"
        return data   
 elseif  event == 5  then
        data = "100元红包"
        return data   
 elseif  event == 6  then
        data = "88张房卡"
        return data   
 elseif  event == 7  then
        data = "68张房卡"
        return data   
 elseif  event == 8  then 
        data = "48张房卡"
        return data  
 elseif  event == 9  then
        data = "10万金币"
        return data   
 elseif  event == 10  then
        data = "5万金币"
        return data   
 elseif  event > 10  then
        data = "无奖励"
        return data   
 end 
end

return TuHaoActivityLayer