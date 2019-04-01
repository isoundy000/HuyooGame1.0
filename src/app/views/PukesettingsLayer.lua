local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")

local PukesettingsLayer = class("PukesettingsLayer", cc.load("mvc").ViewBase)

function PukesettingsLayer:onEnter()

end

function PukesettingsLayer:onExit()

end

function PukesettingsLayer:onCleanup()

end

function PukesettingsLayer:onCreate(parameter)
    self.wKindID = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("PukesettingsNode.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self:buttonEvents() 
end  
--按钮响应
function PukesettingsLayer:buttonEvents(event)
    local data  = {}
    --牌被
    data.Thepukebg = 0
    self.Button_zitipaibei = ccui.Helper:seekWidgetByName(self.root,"Button_zitipaibei")
    self.Button_Thezitipaibei = ccui.Helper:seekWidgetByName(self.root,"Button_Thezitipaibei")   
    local Pukepaibei = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_PukeCardBg",0)
    if Pukepaibei == 0 or Pukepaibei == nil  or event == 0  then
        self:showPaizhu(2,0)
        self.Button_zitipaibei:loadTextures("settings/settings141.png","settings/settings141.png","settings/settings141.png")  
        data.Thepukebg = 0 
    elseif Pukepaibei == 1 then
        self:showPaizhu(2,1)
        self.Button_zitipaibei:loadTextures("settings/settings142.png","settings/settings142.png","settings/settings142.png") 
        data.Thepukebg = 1
    else
        self:showPaizhu(2,2)
        self.Button_zitipaibei:loadTextures("settings/settings143.png","settings/settings143.png","settings/settings143.png")  
        data.Thepukebg = 2 
    end
    local  uiPanel_paizhumajiang = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhumajiang") 
    uiPanel_paizhumajiang:setVisible(false)      
    local  uiButton_green1 = ccui.Helper:seekWidgetByName(self.root,"Button_green1")     
    local  uiButton_yellow1 = ccui.Helper:seekWidgetByName(self.root,"Button_yellow1")
    local  uiButton_blue1 = ccui.Helper:seekWidgetByName(self.root,"Button_blue1")
    local function showPanel_paizhupaibei(type) 
        if type == 4 then      
            uiPanel_paizhumajiang:setVisible(true)
        elseif type == 0 then
            uiPanel_paizhumajiang:setVisible(false) 
            self:showPaizhu(2,0)
            self.Button_zitipaibei:loadTextures("settings/settings141.png","settings/settings141.png","settings/settings141.png")  
            data.Thepukebg = 0            
        elseif type == 1 then 
            uiPanel_paizhumajiang:setVisible(false)  
            self:showPaizhu(2,1)
            self.Button_zitipaibei:loadTextures ("settings/settings142.png","settings/settings142.png","settings/settings142.png") 
            data.Thepukebg = 1 
        elseif type == 2 then  
            uiPanel_paizhumajiang:setVisible(false)  
            self:showPaizhu(2,2)
            self.Button_zitipaibei:loadTextures ("settings/settings143.png","settings/settings143.png","settings/settings143.png") 
            data.Thepukebg = 2        
        end           
    end

    uiPanel_paizhumajiang:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_paizhumajiang:setVisible(false)         
        end
    end) 

    Common:addTouchEventListener(self.Button_zitipaibei,function() showPanel_paizhupaibei(4) end)
    Common:addTouchEventListener(self.Button_Thezitipaibei,function() showPanel_paizhupaibei(4) end)
    Common:addTouchEventListener(uiButton_blue1,function() showPanel_paizhupaibei(0) end)
    Common:addTouchEventListener(uiButton_yellow1,function() showPanel_paizhupaibei(1) end)
    Common:addTouchEventListener(uiButton_green1,function() showPanel_paizhupaibei(2) end)


    --字牌
    data.Thepukeziti = 0
    self.Button_ziti = ccui.Helper:seekWidgetByName(self.root,"Button_ziti")
    self.Button_Theziti = ccui.Helper:seekWidgetByName(self.root,"Button_Theziti")       
    local Pukeziti = nil 
    -- if CHANNEL_ID == 20 or CHANNEL_ID == 21 then
        Pukeziti =cc.UserDefault:getInstance():getIntegerForKey("UserDefault_PukeCard",0)
    -- else
    --     Pukeziti =cc.UserDefault:getInstance():getIntegerForKey("UserDefault_PukeCard",1)
    -- end 
    
    if Pukeziti == 0 or Pukeziti == nil  or event == 0  then
        self:showPaizhu(1,0)
        self.Button_ziti:loadTextures("settings/settings146.png","settings/settings146.png","settings/settings146.png")  
        data.Thepukeziti = 0  
    else     
        self:showPaizhu(1,1)
        self.Button_ziti:loadTextures("settings/settings147.png","settings/settings147.png","settings/settings147.png")  
        data.Thepukeziti = 1 
    end
    
    -- if (CHANNEL_ID == 20 or CHANNEL_ID == 21) and ( Pukeziti == nil or event == 0)then 
    --     self:showPaizhu(1,0)
    --     self.Button_ziti:loadTextures("settings/settings146.png","settings/settings146.png","settings/settings146.png") 
    --     data.Thepukeziti = 0
    -- end
    local  uiPanel_paizhuziti = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhuziti") 
    uiPanel_paizhuziti:setVisible(false)      
    local  uiButton_blue0 = ccui.Helper:seekWidgetByName(self.root,"Button_blue0")     
    local  uiButton_yellow0 = ccui.Helper:seekWidgetByName(self.root,"Button_yellow0")
    local function showPanel_paizhuziapi(type) 
        if type == 4 then      
            uiPanel_paizhuziti:setVisible(true)
        elseif type == 0 then
            uiPanel_paizhuziti:setVisible(false) 
            self:showPaizhu(1,0)
            self.Button_ziti:loadTextures("settings/settings146.png","settings/settings146.png","settings/settings146.png")  
            data.Thepukeziti= 0            
        elseif type == 1 then 
            uiPanel_paizhuziti:setVisible(false)  
            self:showPaizhu(1,1)
            self.Button_ziti:loadTextures ("settings/settings147.png","settings/settings147.png","settings/settings147.png") 
            data.Thepukeziti = 1  
        end           
    end

    uiPanel_paizhuziti:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_paizhuziti:setVisible(false)         
        end
    end) 

    Common:addTouchEventListener(self.Button_ziti,function() showPanel_paizhuziapi(4) end)
    Common:addTouchEventListener(self.Button_Theziti,function() showPanel_paizhuziapi(4) end)
    Common:addTouchEventListener(uiButton_blue0,function() showPanel_paizhuziapi(0) end)
    Common:addTouchEventListener(uiButton_yellow0,function() showPanel_paizhuziapi(1) end)
    
    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2")   
    local Zipailiangdu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_Pukeliangdu",0)
    if Zipailiangdu == 0  or Zipailiangdu == nil  or event == 0   then
        self:showPaizhu(3,0)
        self.uiButton_liangdu1:setBright(true)
        self.uiButton_liangdu2:setBright(false)
        self.uiButton_liangdu1:setColor(cc.c3b(255,255,255))
        self.uiButton_liangdu2:setColor(cc.c3b(170,170,170))       
    else
        self:showPaizhu(3,1)
        self.uiButton_liangdu1:setBright(false)
        self.uiButton_liangdu2:setBright(true)
        self.uiButton_liangdu1:setColor(cc.c3b(170,170,170))
        self.uiButton_liangdu2:setColor(cc.c3b(255,255,255))
    end

    local function setlaingduType(type)
        if type == 0 then
            self:showPaizhu(3,0)
            self.uiButton_liangdu1:setBright(true)
            self.uiButton_liangdu2:setBright(false)
            self.uiButton_liangdu2:setColor(cc.c3b(170,170,170))
            self.uiButton_liangdu1:setColor(cc.c3b(255,255,255))
        elseif type == 1 then
            self:showPaizhu(3,1)
            self.uiButton_liangdu1:setBright(false)
            self.uiButton_liangdu2:setBright(true)
            self.uiButton_liangdu1:setColor(cc.c3b(170,170,170))
            self.uiButton_liangdu2:setColor(cc.c3b(255,255,255))
        end
    end
    Common:addTouchEventListener(self.uiButton_liangdu1,function() setlaingduType(0) end)
    Common:addTouchEventListener(self.uiButton_liangdu2,function() setlaingduType(1) end)

    --牌桌背景
    data.Thebg = 0
    self.uiButton_TheArrow = ccui.Helper:seekWidgetByName(self.root,"Button_TheArrow")
    self.uiButton_Thebg = ccui.Helper:seekWidgetByName(self.root,"Button_Thebg")   
    local ZiPaipaizhu = nil
    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
        ZiPaipaizhu =  cc.UserDefault:getInstance():getIntegerForKey("UserDefault_Pukepaizhuo",2)
    else
        ZiPaipaizhu =  cc.UserDefault:getInstance():getIntegerForKey("UserDefault_Pukepaizhuo",0)
    end 

    if ZiPaipaizhu == 0 or ZiPaipaizhu == nil  or event == 0  then
        self:showPaizhu(4,0)
        self.uiButton_Thebg:loadTextures("settings/settings120.png","settings/settings120.png","settings/settings120.png")  
        data.Thebg = 0 
    elseif ZiPaipaizhu == 1 then
        self:showPaizhu(4,1)
        self.uiButton_Thebg:loadTextures("settings/settings121.png","settings/settings121.png","settings/settings121.png") 
        data.Thebg = 1
    else
        self:showPaizhu(4,2)
        self.uiButton_Thebg:loadTextures("settings/settings122.png","settings/settings122.png","settings/settings122.png")  
        data.Thebg = 2 
    end

    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
        if ZiPaipaizhu == nil or event == 0 then 
            self:showPaizhu(4,2)
            self.uiButton_Thebg:loadTextures("settings/settings122.png","settings/settings122.png","settings/settings122.png") 
            data.Thebg = 2 
        end 
    end
    
    local  uiPanel_paizhubeijing = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhubeijing") 
    uiPanel_paizhubeijing:setVisible(false)      
    local  uiButton_green = ccui.Helper:seekWidgetByName(self.root,"Button_green")     
    local  uiButton_yellow = ccui.Helper:seekWidgetByName(self.root,"Button_yellow")
    local  uiButton_blue = ccui.Helper:seekWidgetByName(self.root,"Button_blue")
    local function showPanel_paizhubeijing(type) 
        if type == 4 then      
            uiPanel_paizhubeijing:setVisible(true)
        elseif type == 0 then
            uiPanel_paizhubeijing:setVisible(false) 
            self:showPaizhu(4,0)
            self.uiButton_Thebg:loadTextures("settings/settings120.png","settings/settings120.png","settings/settings120.png")  
            self.Thebg = 0            
        elseif type == 1 then 
            uiPanel_paizhubeijing:setVisible(false)  
            self:showPaizhu(4,1)
            self.uiButton_Thebg:loadTextures ("settings/settings121.png","settings/settings121.png","settings/settings121.png") 
            self.Thebg = 1 

        elseif type == 2 then  
            uiPanel_paizhubeijing:setVisible(false)  
            self:showPaizhu(4,2)
            self.uiButton_Thebg:loadTextures ("settings/settings122.png","settings/settings122.png","settings/settings122.png") 
            self.Thebg = 2        
        end           
    end

    uiPanel_paizhubeijing:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_paizhubeijing:setVisible(false)         
        end
    end) 

    Common:addTouchEventListener(self.uiButton_TheArrow,function() showPanel_paizhubeijing(4) end)
    Common:addTouchEventListener(self.uiButton_Thebg,function() showPanel_paizhubeijing(4) end)
    Common:addTouchEventListener(uiButton_green,function() showPanel_paizhubeijing(0) end)
    Common:addTouchEventListener(uiButton_yellow,function() showPanel_paizhubeijing(1) end)
    Common:addTouchEventListener(uiButton_blue,function() showPanel_paizhubeijing(2) end)

    --默认与保存
    local uiButton_acquiescence = ccui.Helper:seekWidgetByName(self.root,"Button_acquiescence")
    local uiButton_preservation = ccui.Helper:seekWidgetByName(self.root,"Button_preservation")

    Common:addTouchEventListener(uiButton_acquiescence,function() self:restoreTheDefault() end)   
    Common:addTouchEventListener(uiButton_preservation,function() self:saveTheConfiguration(data) end)
end 

--保存选项
function PukesettingsLayer:restoreTheDefault()
    self:buttonEvents(0) 
end

--保存选项
function PukesettingsLayer:saveTheConfiguration(event)


    --牌被
    self.Button_zitipaibei  = ccui.Helper:seekWidgetByName(self.root,"Button_zitipaibei")
    self.Button_Thezitipaibei  = ccui.Helper:seekWidgetByName(self.root,"Button_Thezitipaibei") 
    if event.Thepukebg == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_PukeCardBg",0)
    elseif event.Thepukebg == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_PukeCardBg",1)
    elseif event.Thepukebg == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_PukeCardBg",2)
    end 
    
    --字牌
    self.Button_ziti  = ccui.Helper:seekWidgetByName(self.root,"Button_ziti")
    self.Button_Thezitipaibei  = ccui.Helper:seekWidgetByName(self.root,"Button_Theziti") 
    if event.Thepukeziti == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_PukeCard",0)
    elseif event.Thepukeziti == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_PukeCard",1)
    end 
   

    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2") 
    if self.uiButton_liangdu1:isBright() then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_Pukeliangdu",0)
    elseif self.uiButton_liangdu2:isBright() then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_Pukeliangdu",1)
    end 

    --牌桌背景
    self.uiButton_TheArrow  = ccui.Helper:seekWidgetByName(self.root,"Button_TheArrow")
    self.uiButton_Thebg  = ccui.Helper:seekWidgetByName(self.root,"Button_Thebg") 
    if event.Thebg == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_Pukepaizhuo",0)
    elseif event.Thebg == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_Pukepaizhuo",1)
    elseif event.Thebg == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_Pukepaizhuo",2)
    end  
    EventMgr:dispatch(EventType.EVENT_TYPE_SKIN_CHANGE,2)
    require("common.SceneMgr"):switchOperation()
end 

function PukesettingsLayer:showPaizhu(type,event)

    if  type ==  1  then 
        local uiPanel_handCard1 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard1")       
        for i = 1 ,15 do          
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handCard1_%d",i))         
            local a = 13 -(i/3)
            local b = i%3 
            uiImage_handCard:loadTexture(string.format("puke/card/card%d/puke_%d_%d.png",event,b,a))
            print("字体:",i,a,b) 
        end  
    end

    local uiImage_CardBG = ccui.Helper:seekWidgetByName(self.root,"Image_CardBG")
    if  type ==  2 and event == 1  then  
        uiImage_CardBG:loadTexture(string.format("puke/table/puke_bg%d.png",event))
    elseif  type == 2 and event == 0 then 
        uiImage_CardBG:loadTexture(string.format("puke/table/puke_bg%d.png",event))
    elseif  type == 2 and event == 2 then 
        uiImage_CardBG:loadTexture(string.format("puke/table/puke_bg%d.png",event))
    end    
    local uiPanel_night = ccui.Helper:seekWidgetByName(self.root,"Panel_night")
    if  type ==  3 and event == 1  then  
        uiPanel_night:setVisible(true)  
    elseif  type == 3 and event == 0 then 
        uiPanel_night:setVisible(false) 
    end 
    
    local uiPanel_paizhu = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhuo")   
    if  type ==  4 and event == 0  then  
        uiPanel_paizhu:removeAllChildren()
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/PDK_table_bg%d.jpg",event)))
    elseif  type == 4 and event == 1  then 
        uiPanel_paizhu:removeAllChildren()
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/PDK_table_bg%d.jpg",event)))
    elseif  type == 4 and event == 2  then  
        uiPanel_paizhu:removeAllChildren()
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/PDK_table_bg%d.jpg",event)))
    end 

end


return PukesettingsLayer

