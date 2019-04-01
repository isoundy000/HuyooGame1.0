local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")

local GuildActivityLayer = class("GuildActivityLayer", cc.load("mvc").ViewBase)

function GuildActivityLayer:onEnter()  
    EventMgr:registListener(EventType.SUB_SC_JSONCALLACTIVI,self,self.SUB_SC_JSONCALLACTIVI) 
end

function GuildActivityLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_JSONCALLACTIVI,self,self.SUB_SC_JSONCALLACTIVI) 
end

function GuildActivityLayer:onCreate()
    cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_GuilActivity,os.time())  
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GuildActivityLayer.csb")
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
    self.uiPanel_show = ccui.Helper:seekWidgetByName(self.root,"Panel_show")
    self.uiPanel_action = ccui.Helper:seekWidgetByName(self.root,"Panel_action")
    if UserData.Guild.dwGuildID == 0 then 
        self.uiPanel_show:setVisible(true)
        self.uiPanel_action:setVisible(false)
    end 
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_enter"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  
    end)
    self.uiListView_table = ccui.Helper:seekWidgetByName(self.root,"ListView_table")
    self.uiListView_table:removeAllChildren()    
    UserData.GuildActivity.RequestRanking()
   -- self:Action()  
end

function GuildActivityLayer:SUB_SC_JSONCALLACTIVI(event)
    local data = event._usedata
    local uiText_GuildName2 = ccui.Helper:seekWidgetByName(self.root,"Text_GuildName2")
    uiText_GuildName2:setString(UserData.Guild.societyName)
    uiText_GuildName2:setTextColor(cc.c3b(241,37,12)) 
    self.uiListView_table:removeAllChildren()
    if data["ret"] ~= 0 then    
        local Text_mynum = ccui.Helper:seekWidgetByName(self.root,"Text_mynum")
        Text_mynum:setString("暂无数据")
        Text_mynum:setTextColor(cc.c3b(22,0,0))         
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
        item:setScale(0,1)  
        item:runAction(cc.Sequence:create(cc.DelayTime:create(key*0.1),cc.ScaleTo:create(0.1,1.0,1.0)))        
        if  topData.UserID == UserData.User.userID then 
            local Text_mynum = ccui.Helper:seekWidgetByName(self.root,"Text_mynum")
            Text_mynum:setString("第"..tostring(topData.RowNumber).."名")
            Text_mynum:setTextColor(cc.c3b(22,0,0))           
            local Text_myname = ccui.Helper:seekWidgetByName(self.root,"Text_myname")
            Text_myname:setString(tostring(topData.NickName))
            Text_myname:setTextColor(cc.c3b(22,0,0)) 
            self.Showreward = true
        end 
    end
     
    if self.Showreward == false then 
        local Text_mynum = ccui.Helper:seekWidgetByName(self.root,"Text_mynum")
        Text_mynum:setString("暂无数据")
        Text_mynum:setTextColor(cc.c3b(22,0,0))         
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
        item:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.1),cc.ScaleTo:create(0.1,1.0,1.0)))  
    end
    
end 
return GuildActivityLayer