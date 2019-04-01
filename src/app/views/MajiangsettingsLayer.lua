local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")

local MajiangsettingsLayer = class("MajiangsettingsLayer", cc.load("mvc").ViewBase)

function MajiangsettingsLayer:onEnter()

end

function MajiangsettingsLayer:onExit()

end

function MajiangsettingsLayer:onCleanup()

end

function MajiangsettingsLayer:onCreate(parameter)
    self.wKindID = parameter[1]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("MajiangsettingsNode.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self:buttonEvents() 
end  
--按钮响应
function MajiangsettingsLayer:buttonEvents(event)
    local data  = {}
    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2")   
    local Zipailiangdu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_MaJiangliangdu",0)
    if Zipailiangdu == 0  or Zipailiangdu == nil  or event == 0 then
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
    local ZiPaipaizhu = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_MaJiangpaizhuo",0)
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
    if CHANNEL_ID == 20 or CHANNEL_ID == 21 then 
        ZipaiCard = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_MaJiangCard",3)
    else
        ZipaiCard = cc.UserDefault:getInstance():getIntegerForKey("UserDefault_MaJiangCard",0)
    end 
    if ZipaiCard == 0 or ZipaiCard == nil or event == 0 then   
        self:showPaizhu(1,0)
        self.Button_ziti:loadTextures("settings/settings133.png","settings/settings133.png","settings/settings133.png")  
        data.Theziti = 0
    elseif ZipaiCard == 1 then
        self:showPaizhu(1,1)
        self.Button_ziti:loadTextures("settings/settings134.png","settings/settings134.png","settings/settings134.png") 
        data.Theziti = 1  
    elseif ZipaiCard == 2 then
        self:showPaizhu(1,2)
        self.Button_ziti:loadTextures("settings/settings135.png","settings/settings135.png","settings/settings135.png")  
        data.Theziti = 2   
   elseif ZipaiCard == 3 then
        self:showPaizhu(1,3)
        self.Button_ziti:loadTextures("settings/settings145.png","settings/settings145.png","settings/settings145.png") 
        data.Theziti = 3
    end
    if (CHANNEL_ID == 20 or CHANNEL_ID == 21) and ( ZipaiCard == nil or event == 0)then 
        self:showPaizhu(1,3)
        self.Button_ziti:loadTextures("settings/settings145.png","settings/settings145.png","settings/settings145.png") 
        data.Theziti = 3
    end     
    local  uiPanel_paizhumajiang = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhumajiang") 
    uiPanel_paizhubeijing:setVisible(false)      
    local  uiButton_green1 = ccui.Helper:seekWidgetByName(self.root,"Button_green1")     
    local  uiButton_yellow1 = ccui.Helper:seekWidgetByName(self.root,"Button_yellow1")
    local  uiButton_blue1 = ccui.Helper:seekWidgetByName(self.root,"Button_blue1")
    local  uiButton_red1 = ccui.Helper:seekWidgetByName(self.root,"Button_red1")
    local function showPanel_paizhuziti(type) 
        if type == 4 then      
            uiPanel_paizhumajiang:setVisible(true)
        elseif type == 0 then
            uiPanel_paizhumajiang:setVisible(false) 
            self:showPaizhu(1,0)
            self.Button_ziti:loadTextures("settings/settings133.png","settings/settings133.png","settings/settings133.png")  
            data.Theziti = 0             
        elseif type == 1 then 
            uiPanel_paizhumajiang:setVisible(false)  
            self:showPaizhu(1,1)
            self.Button_ziti:loadTextures ("settings/settings134.png","settings/settings134.png","settings/settings134.png") 
            data.Theziti = 1 
        elseif type == 2 then  
            uiPanel_paizhumajiang:setVisible(false)  
            self:showPaizhu(1,2)
            self.Button_ziti:loadTextures ("settings/settings135.png","settings/settings135.png","settings/settings135.png") 
            data.Theziti = 2 
        elseif type == 3 then  
            uiPanel_paizhumajiang:setVisible(false)  
            self:showPaizhu(1,3)
            self.Button_ziti:loadTextures ("settings/settings145.png","settings/settings145.png","settings/settings145.png") 
            data.Theziti = 3         
        end           
    end

    uiPanel_paizhumajiang:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_paizhumajiang:setVisible(false)         
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
function MajiangsettingsLayer:restoreTheDefault()
    self:buttonEvents(0) 
end

--保存选项
function MajiangsettingsLayer:saveTheConfiguration(event)

    self.Button_Theziti = ccui.Helper:seekWidgetByName(self.root,"Button_Theziti")
    self.Button_ziti = ccui.Helper:seekWidgetByName(self.root,"Button_ziti")  
    if event.Theziti == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangCard",0)
    elseif event.Theziti == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangCard",1)
    elseif event.Theziti == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangCard",2)
    elseif event.Theziti == 3  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangCard",3)
    end 

 
    --亮度
    self.uiButton_liangdu1 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu1")
    self.uiButton_liangdu2 = ccui.Helper:seekWidgetByName(self.root,"Button_liangdu2") 
    if self.uiButton_liangdu1:isBright() then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangliangdu",0)
    elseif self.uiButton_liangdu2:isBright() then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangliangdu",1)
    end 

    --牌桌背景
    self.uiButton_TheArrow  = ccui.Helper:seekWidgetByName(self.root,"Button_TheArrow")
    self.uiButton_Thebg  = ccui.Helper:seekWidgetByName(self.root,"Button_Thebg") 
    if event.Thebg == 0 then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangpaizhuo",0)
    elseif event.Thebg == 1  then  
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangpaizhuo",1)
    elseif event.Thebg == 2  then 
        cc.UserDefault:getInstance():setIntegerForKey("UserDefault_MaJiangpaizhuo",2)
    end  
    EventMgr:dispatch(EventType.EVENT_TYPE_SKIN_CHANGE,3)
    require("common.SceneMgr"):switchOperation()
end 

function MajiangsettingsLayer:showPaizhu(type,event)
   
    if  type ==  1  then 
        print("bianbai:",event) 
        local uiPanel_handCard1 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard1")       
        for i = 1 ,13 do          
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handCard1_%d",i)) 
            print("bianbai123:",event)          
            if i < 10 then   --Image_handCard1_1
                uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_card0%d.png",event,i))
            elseif i == 10 then
                uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_card%d.png",event,11))
            elseif i > 10 then
                uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_card%d.png",event,i))
            end 
        end 
        local uiPanel_handCard2 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard2")       
        for i = 1 ,8 do          
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handCard2_%d",i)) 
            print("bianbai123:",event)          
            uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_cardright_bg.png",event))
 
        end 
        local uiPanel_handCard3 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard3")       
        for i = 1 ,8 do          
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handCard3_%d",i)) 
            print("bianbai123:",event)       
            uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_card_bg.png",event))
        end 
        local uiPanel_handCard4 = ccui.Helper:seekWidgetByName(self.root,"Panel_handCard4")       
        for i = 1 ,8 do          
            local uiImage_handCard = ccui.Helper:seekWidgetByName(self.root,string.format("Image_handCard4_%d",i)) 
            print("bianbai123:",event)          
            uiImage_handCard:loadTexture(string.format("majiang/card/card%d/hand_cardright_bg.png",event))
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
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",event)))
    elseif  type == 4 and event == 1  then 
        uiPanel_paizhu:removeAllChildren()
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",event)))
    elseif  type == 4 and event == 2 then  
        uiPanel_paizhu:removeAllChildren()
        uiPanel_paizhu:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",event)))
    end 

end


return MajiangsettingsLayer

