local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")

local PaohuzisettingsLayer = class("PaohuzisettingsLayer", cc.load("mvc").ViewBase)

function PaohuzisettingsLayer:onEnter()

end

function PaohuzisettingsLayer:onExit()

end

function PaohuzisettingsLayer:onCleanup()

end

function PaohuzisettingsLayer:onCreate(parameter)
    self.wKindID = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("PaohuizisettingsNode.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    --按钮响应    
    self:buttonEvents()

end

--按钮响应
function PaohuzisettingsLayer:buttonEvents(event)
    local data  = {}
    --牌被
    self.uiButton_paibei1 = ccui.Helper:seekWidgetByName(self.root,"Button_paibei1")
    self.uiButton_paibei2 = ccui.Helper:seekWidgetByName(self.root,"Button_paibei2")   
    local ZipaiCardBg = nil 
    if CHANNEL_ID == 10 or CHANNEL_ID == 11 or CHANNEL_ID == 2 or CHANNEL_ID == 3 then 
        ZipaiCardBg = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaiCardBg",1)
    else
        ZipaiCardBg = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaiCardBg",0)
    end 
    if ZipaiCardBg == 0 or ZipaiCardBg == nil or event == 0 then
        self:showPaizhu(2,0)
        self.uiButton_paibei1:setBright(true)
        self.uiButton_paibei2:setBright(false)
        self.uiButton_paibei2:setColor(cc.c3b(170,170,170))
        self.uiButton_paibei1:setColor(cc.c3b(255,255,255))
    else
        self:showPaizhu(2,1)
        self.uiButton_paibei1:setBright(false)
        self.uiButton_paibei2:setBright(true)
        self.uiButton_paibei1:setColor(cc.c3b(170,170,170))
        self.uiButton_paibei2:setColor(cc.c3b(255,255,255))
    end
    
    if( CHANNEL_ID == 10 or CHANNEL_ID == 11 or CHANNEL_ID == 2 or CHANNEL_ID == 3 ) and (ZipaiCardBg == nil or event == 0)then 
        self:showPaizhu(2,1)
        self.uiButton_paibei1:setBright(false)
        self.uiButton_paibei2:setBright(true)
        self.uiButton_paibei1:setColor(cc.c3b(170,170,170))
        self.uiButton_paibei2:setColor(cc.c3b(255,255,255))
    end
    
    local function setpaibeiType(type)
        if type == 0 then
            self:showPaizhu(2,0)
            self.uiButton_paibei1:setBright(true)
            self.uiButton_paibei2:setBright(false)
            self.uiButton_paibei2:setColor(cc.c3b(170,170,170))
            self.uiButton_paibei1:setColor(cc.c3b(255,255,255))
        elseif type == 1 then
            self:showPaizhu(2,1)
            self.uiButton_paibei1:setBright(false)
            self.uiButton_paibei2:setBright(true)
            self.uiButton_paibei1:setColor(cc.c3b(170,170,170))
            self.uiButton_paibei2:setColor(cc.c3b(255,255,255))
        end
    end
    Common:addTouchEventListener(self.uiButton_paibei1,function() setpaibeiType(0) end)
    Common:addTouchEventListener(self.uiButton_paibei2,function() setpaibeiType(1) end)

    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2")   
    local Zipailiangdu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPailiangdu",0)
    if Zipailiangdu == 0 or Zipailiangdu == nil  or event == 0   then
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
    self.Thebg = 0
    self.uiButton_TheArrow = ccui.Helper:seekWidgetByName(self.root,"Button_TheArrow")
    self.uiButton_Thebg = ccui.Helper:seekWidgetByName(self.root,"Button_Thebg")   
    local ZiPaipaizhu = nil 
    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
        ZiPaipaizhu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaipaizhuo",2)
    else
        ZiPaipaizhu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaipaizhuo",0)
    end 
    if ZiPaipaizhu == 0 or ZiPaipaizhu == nil or event == 0 then
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
            data.Thebg = 0             
        elseif type == 1 then 
            uiPanel_paizhubeijing:setVisible(false)  
            self:showPaizhu(4,1)
            self.uiButton_Thebg:loadTextures ("settings/settings121.png","settings/settings121.png","settings/settings121.png") 
            data.Thebg = 1 

        elseif type == 2 then  
            uiPanel_paizhubeijing:setVisible(false)  
            self:showPaizhu(4,2)
            self.uiButton_Thebg:loadTextures ("settings/settings122.png","settings/settings122.png","settings/settings122.png") 
            data.Thebg = 2        
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
    
    
    --字牌
    data.Theziti = 0
    self.Button_Theziti = ccui.Helper:seekWidgetByName(self.root,"Button_Theziti")
    self.Button_ziti = ccui.Helper:seekWidgetByName(self.root,"Button_ziti") 
    local ZipaiCard = nil   
    if CHANNEL_ID == 8 or CHANNEL_ID == 9 then 
        ZipaiCard = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaiCard",1)
    else
        ZipaiCard = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaiCard",0)
    end 
    if ZipaiCard == 0 or ZipaiCard == nil or event == 0 then
        self:showPaizhu(1,0)     
        self.Button_ziti:loadTextures("settings/settings136.png","settings/settings136.png","settings/settings136.png")  
        data.Theziti = 0
  
    elseif ZipaiCard == 1 then
        self:showPaizhu(1,1)
        self.Button_ziti:loadTextures("settings/settings137.png","settings/settings137.png","settings/settings137.png") 
        data.Theziti = 1
    elseif ZipaiCard == 3 then
        self:showPaizhu(1,1)
        self.Button_ziti:loadTextures("settings/settings144.png","settings/settings144.png","settings/settings144.png") 
        data.Theziti = 3
    else
        self:showPaizhu(1,2)
        self.Button_ziti:loadTextures("settings/settings138.png","settings/settings138.png","settings/settings138.png")  
        data.Theziti = 2 
    end
    
    if (CHANNEL_ID == 8 or CHANNEL_ID == 9) and (ZipaiCard == nil or event == 0)then 
        self:showPaizhu(1,1)
        self.Button_ziti:loadTextures("settings/settings137.png","settings/settings137.png","settings/settings137.png") 
        data.Theziti = 1
    end
      
    local  uiPanel_paizhuzipai = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhuzipai") 
    uiPanel_paizhubeijing:setVisible(false)      
    local  uiButton_green1 = ccui.Helper:seekWidgetByName(self.root,"Button_green1")     
    local  uiButton_yellow1 = ccui.Helper:seekWidgetByName(self.root,"Button_yellow1")
    local  uiButton_blue1 = ccui.Helper:seekWidgetByName(self.root,"Button_blue1")
    local  uiButton_red1 = ccui.Helper:seekWidgetByName(self.root,"Button_red1")
    local function showPanel_paizhuziti(type) 
        if type == 4 then      
            uiPanel_paizhuzipai:setVisible(true)
        elseif type == 0 then
            uiPanel_paizhuzipai:setVisible(false) 
            self:showPaizhu(1,0)
            self.Button_ziti:loadTextures("settings/settings136.png","settings/settings136.png","settings/settings136.png")  
            data.Theziti = 0             
        elseif type == 1 then 
            uiPanel_paizhuzipai:setVisible(false)  
            self:showPaizhu(1,1)
            self.Button_ziti:loadTextures ("settings/settings137.png","settings/settings137.png","settings/settings137.png") 
            data.Theziti = 1 
        elseif type == 2 then  
            uiPanel_paizhuzipai:setVisible(false)  
            self:showPaizhu(1,2)
            self.Button_ziti:loadTextures ("settings/settings138.png","settings/settings138.png","settings/settings138.png") 
            data.Theziti = 2 
        elseif type == 3 then  
            uiPanel_paizhuzipai:setVisible(false)  
            self:showPaizhu(1,3)
            self.Button_ziti:loadTextures ("settings/settings144.png","settings/settings144.png","settings/settings144.png") 
            data.Theziti = 3       
        end           
    end

    uiPanel_paizhuzipai:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_paizhuzipai:setVisible(false)         
        end
    end) 

    Common:addTouchEventListener(self.Button_ziti,function() showPanel_paizhuziti(4) end)
    Common:addTouchEventListener(self.Button_Theziti,function() showPanel_paizhuziti(4) end)
    Common:addTouchEventListener(uiButton_green1,function() showPanel_paizhuziti(0) end)
    Common:addTouchEventListener(uiButton_yellow1,function() showPanel_paizhuziti(1) end)
    Common:addTouchEventListener(uiButton_blue1,function() showPanel_paizhuziti(2) end)
    Common:addTouchEventListener(uiButton_red1,function() showPanel_paizhuziti(3) end)

    --默认与保存
    local uiButton_acquiescence = ccui.Helper:seekWidgetByName(self.root,"Button_acquiescence")
    local uiButton_preservation = ccui.Helper:seekWidgetByName(self.root,"Button_preservation")

    Common:addTouchEventListener(uiButton_acquiescence,function() self:restoreTheDefault() end)   
    Common:addTouchEventListener(uiButton_preservation,function() self:saveTheConfiguration(data) end)
end 

--保存选项
function PaohuzisettingsLayer:restoreTheDefault()
    self:buttonEvents(0) 
end

--保存选项
function PaohuzisettingsLayer:saveTheConfiguration(event)
    self.Button_Theziti = ccui.Helper:seekWidgetByName(self.root,"Button_Theziti")
    self.Button_ziti = ccui.Helper:seekWidgetByName(self.root,"Button_ziti")  
    if event.Theziti == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCard",0)
    elseif event.Theziti == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCard",1)
    elseif event.Theziti == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCard",2)
    elseif event.Theziti == 3  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCard",3)
    end 

    --牌被
    self.uiButton_paibei1 = ccui.Helper:seekWidgetByName(self.root,"Button_paibei1")
    self.uiButton_paibei2 = ccui.Helper:seekWidgetByName(self.root,"Button_paibei2")
    if self.uiButton_paibei1:isBright() then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCardBg",0)
    elseif self.uiButton_paibei2:isBright() then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaiCardBg",1)
    end 
    
    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2") 
    if self.uiButton_liangdu1:isBright() then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPailiangdu",0)
    elseif self.uiButton_liangdu2:isBright() then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPailiangdu",1)
    end 
   
    --牌桌背景
    self.uiButton_TheArrow  = ccui.Helper:seekWidgetByName(self.root,"Button_TheArrow")
    self.uiButton_Thebg  = ccui.Helper:seekWidgetByName(self.root,"Button_Thebg") 
    if event.Thebg == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaipaizhuo",0)
    elseif event.Thebg == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaipaizhuo",1)
    elseif event.Thebg == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_ZiPaipaizhuo",2)
    end 
    local MaJiangliangdu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPailiangdu",0) 
    local ZiPaipaizhu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_ZiPaipaizhuo",0)  
    EventMgr:dispatch(EventType.EVENT_TYPE_SKIN_CHANGE,1)
    require("common.SceneMgr"):switchOperation()
end 

function PaohuzisettingsLayer:showPaizhu(type,event)
    local uiPanel_handCard1 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard1")
    if  type ==  1  then         
        for i = 1 ,20 do  
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handcard%d",i))          
            if i <= 10 then 
                uiImage_handCard:loadTexture(string.format("zipai/card/card%d/x%d.png",event,i))
            elseif i > 10 then
                uiImage_handCard:loadTexture(string.format("zipai/card/card%d/d%d.png",event,i-10))
            end 
        end 
    end
    
    if  type ==  2  then   
            
        for i = 1 ,3 do
            local uiImage_beipai = ccui.Helper:seekWidgetByName(self.root,string.format("Image_beipai%d",i))
            uiImage_beipai:loadTexture(string.format("zipai/card_bg/card_bg%d/card_bg_2.png",event))
        end
        local uiListView_stacks_0 = ccui.Helper:seekWidgetByName(self.root,"ListView_stacks_0")
        local uiListView_stacks_1 = ccui.Helper:seekWidgetByName(self.root,"ListView_stacks_1")
        if event == 0 then 
            uiListView_stacks_0:setVisible(true)
            uiListView_stacks_1:setVisible(false)
        else
            uiListView_stacks_0:setVisible(false)
            uiListView_stacks_1:setVisible(true)
        end 
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
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("achannel/%d/paohuzi_table_bg%d.jpg",CHANNEL_ID,event)))
        else
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/paohuzi_table_bg%d.jpg",event)))
        end
    elseif  type == 4 and event == 1  then 
        uiPanel_paizhu:removeAllChildren()
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("achannel/%d/paohuzi_table_bg%d.jpg",CHANNEL_ID,event)))
        else
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/paohuzi_table_bg%d.jpg",event)))
        end
    elseif  type == 4 and event == 2  then  
        uiPanel_paizhu:removeAllChildren()
        if CHANNEL_ID == 10 or CHANNEL_ID == 11 then 
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("achannel/%d/paohuzi_table_bg%d.jpg",CHANNEL_ID,event)))
        else
            uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/paohuzi_table_bg%d.jpg",event)))
        end
    end 
    
end 


return PaohuzisettingsLayer

