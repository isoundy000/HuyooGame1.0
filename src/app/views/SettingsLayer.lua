local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local HttpUrl = require("common.HttpUrl")
local SettingsLayer = class("SettingsLayer", cc.load("mvc").ViewBase)

function SettingsLayer:onEnter()
    
end

function SettingsLayer:onExit()
    
end

function SettingsLayer:onCreate(parames)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SettingsLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb

    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        require("common.SceneMgr"):switchOperation()
    end)
       local ListView_options = ccui.Helper:seekWidgetByName(self.root,"ListView_options")  
       local uiButton_xingxiao = ccui.Helper:seekWidgetByName(self.root,"Button_xingxiao")
       local uiButton_phz = ccui.Helper:seekWidgetByName(self.root,"Button_phz")
       local uiButton_mj = ccui.Helper:seekWidgetByName(self.root,"Button_mj")
       local uiButton_puke = ccui.Helper:seekWidgetByName(self.root,"Button_puke")
       local uiPanel_sound = ccui.Helper:seekWidgetByName(self.root,"Panel_sound") 
       local uiButton_Problem = ccui.Helper:seekWidgetByName(self.root,"Button_Problem") 
       local uiPanel_display = ccui.Helper:seekWidgetByName(self.root,"Panel_display")   
       local uiPanel_BUG = ccui.Helper:seekWidgetByName(self.root,"Panel_BUG")       

       if CHANNEL_ID == 4 or CHANNEL_ID == 5 then 
           ListView_options:removeItem(ListView_options:getIndex(uiButton_phz))
       end 
       if CHANNEL_ID == 18 or CHANNEL_ID == 19 then 
           ListView_options:removeItem(ListView_options:getIndex(uiButton_phz))
           ListView_options:removeItem(ListView_options:getIndex(uiButton_puke))
       end 
    local function showSettingType(type)
        if type == 1 then
            uiPanel_sound:setVisible(true)
            uiPanel_display:setVisible(false)
            uiPanel_BUG:setVisible(false)
            uiButton_xingxiao:setBright(true)                       
           if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(false)
                end 
                uiButton_puke:setBright(false)      
            end
            uiButton_mj:setBright(false)            
            uiButton_Problem:setBright(false)         
        elseif type == 2 then
            uiPanel_sound:setVisible(false)
            uiPanel_display:setVisible(true)
            uiPanel_BUG:setVisible(false)
            self:setGame(2)
            uiButton_xingxiao:setBright(false)
            if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(true)
                end 
                uiButton_puke:setBright(false)      
            end
            uiButton_mj:setBright(false)
            uiButton_Problem:setBright(false)   
        elseif type == 3 then
            uiPanel_sound:setVisible(false)
            uiPanel_display:setVisible(true)
            uiPanel_BUG:setVisible(false)
            self:setGame(3)
            uiButton_xingxiao:setBright(false)
            if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(false)
                end 
                uiButton_puke:setBright(false)      
            end
            uiButton_mj:setBright(true)
            uiButton_Problem:setBright(false)   
        elseif type == 4 then
            uiPanel_sound:setVisible(false)
            uiPanel_display:setVisible(true)
            uiPanel_BUG:setVisible(false)
            self:setGame(4)
            uiButton_xingxiao:setBright(false)
            if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(false)
                end 
                uiButton_puke:setBright(true)      
            end
            uiButton_mj:setBright(false)
            uiButton_Problem:setBright(false)   
        elseif type == 5 then
            uiPanel_sound:setVisible(false)
            uiPanel_display:setVisible(false)
            uiPanel_BUG:setVisible(true)
            uiButton_xingxiao:setBright(false)
            if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(false)
                end 
                uiButton_puke:setBright(false)      
            end
            uiButton_mj:setBright(false)
            uiButton_Problem:setBright(true)   
        else
            uiPanel_sound:setVisible(true)
            uiPanel_display:setVisible(false)
            uiPanel_BUG:setVisible(false)
            uiButton_xingxiao:setBright(true)
            if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
                if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
                    uiButton_phz:setBright(false)
                end 
                uiButton_puke:setBright(false)      
            end
            uiButton_mj:setBright(false)
            uiButton_Problem:setBright(false)   
        end          
    end     
    Common:addTouchEventListener(uiButton_xingxiao,function() showSettingType(1) end)
    if CHANNEL_ID ~= 18 and  CHANNEL_ID ~= 19 then
    if CHANNEL_ID ~= 4 and  CHANNEL_ID ~= 5 then 
        Common:addTouchEventListener(uiButton_phz,function() showSettingType(2) end)
        end 
        Common:addTouchEventListener(uiButton_puke,function() showSettingType(4) end)
    end
    Common:addTouchEventListener(uiButton_mj,function() showSettingType(3) end)    
    Common:addTouchEventListener(uiButton_Problem,function() showSettingType(5) end)  
    showSettingType(1)   
    self:initSound() 
    self:initBUG()   
end

function SettingsLayer:initSound()

    --版本信息
    local uiText_edition = ccui.Helper:seekWidgetByName(self.root,"Text_edition")
    if require("loading.Update").version ~= "" then
        local versionInfo = string.format("v%s",require("loading.Update").version)
        versionInfo ="版本:".. versionInfo.."."..tostring(CHANNEL_ID)
        uiText_edition:setString(versionInfo)
    end       
    local uiButton_kai_1 = ccui.Helper:seekWidgetByName(self.root,"Button_kai_1")
    local uiButton_guan_1 = ccui.Helper:seekWidgetByName(self.root,"Button_guan_1")
    local volumeSound = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Sound",1)
    local function setSoundType(type)
        if type == 1 then           
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Sound",1)
            uiButton_kai_1:setBright(true)
            uiButton_guan_1:setBright(false)
        elseif type == 2 then            
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Sound",0)
            uiButton_kai_1:setBright(false)
            uiButton_guan_1:setBright(true)
        end
    end
    Common:addTouchEventListener(uiButton_kai_1,function() setSoundType(1) end)
    Common:addTouchEventListener(uiButton_guan_1,function() setSoundType(2) end)
    if volumeSound > 0 then
        uiButton_kai_1:setBright(true)
        uiButton_guan_1:setBright(false)
    else      
        uiButton_kai_1:setBright(false)
        uiButton_guan_1:setBright(true)
    end
    
    
    local uiButton_kai_2 = ccui.Helper:seekWidgetByName(self.root,"Button_kai_2")
    local uiButton_guan_2 = ccui.Helper:seekWidgetByName(self.root,"Button_guan_2")
    local volumeMusic = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Music",1)
    local function setMusicType(type)
        if type == 1 then
            cc.SimpleAudioEngine:getInstance():setMusicVolume(1)
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Music",1)
            uiButton_kai_2:setBright(true)
            uiButton_guan_2:setBright(false)
        elseif type == 2 then
            cc.SimpleAudioEngine:getInstance():setMusicVolume(0)
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Music",0)
            uiButton_kai_2:setBright(false)
            uiButton_guan_2:setBright(true)
        end
    end
    Common:addTouchEventListener(uiButton_kai_2,function() setMusicType(1) end)
    Common:addTouchEventListener(uiButton_guan_2,function() setMusicType(2) end)
    if volumeMusic > 0 then
        cc.SimpleAudioEngine:getInstance():setMusicVolume(1)
        uiButton_kai_2:setBright(true)
        uiButton_guan_2:setBright(false)
    else
        cc.SimpleAudioEngine:getInstance():setMusicVolume(0)
        uiButton_kai_2:setBright(false)
        uiButton_guan_2:setBright(true)
    end
    
    local uiButton_kai_3 = ccui.Helper:seekWidgetByName(self.root,"Button_kai_3")
    local uiButton_guan_3 = ccui.Helper:seekWidgetByName(self.root,"Button_guan_3")
    local items = {uiButton_kai_3, uiButton_guan_3}
    Common:addCheckTouchEventListener(items,false,function(index) 
        if index == 1 then
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Voice",1)
        else
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Voice",0)
        end
    end)
    local volumeVoice = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Voice",1)
    if volumeVoice > 0 then
        items[1]:setBright(true)
    else
        items[2]:setBright(true)
    end
    

    local uiButton_kai_4 = ccui.Helper:seekWidgetByName(self.root,"Button_kai_4")
    local uiButton_guan_4 = ccui.Helper:seekWidgetByName(self.root,"Button_guan_4")
    local items = {uiButton_kai_4, uiButton_guan_4}
    Common:addCheckTouchEventListener(items,false,function(index) 
        if index == 1 then
            cc.UserDefault:getInstance():setBoolForKey("CDisOpenTin",true)
        else
            cc.UserDefault:getInstance():setBoolForKey("CDisOpenTin",false)
        end
    end)
    local volumeVoice = cc.UserDefault:getInstance():getBoolForKey('CDisOpenTin', true)
    if volumeVoice then
        items[1]:setBright(true)
    else
        items[2]:setBright(true)
    end
    
    local uiButton_qingsong = ccui.Helper:seekWidgetByName(self.root,"Button_qingsong")
    local uiButton_huankuai = ccui.Helper:seekWidgetByName(self.root,"Button_huankuai")
    local uiButton_xiuxian = ccui.Helper:seekWidgetByName(self.root,"Button_xiuxian")
    local Musictype = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Musictype",1)
    local function settingMusicType(type)
        if type == 1 then
            local mousic = string.format("achannel/%d/music%d.mp3",CHANNEL_ID,type)
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Musictype",1)
            cc.SimpleAudioEngine:getInstance():playMusic(mousic,true)
            uiButton_qingsong:setBright(true)
            uiButton_huankuai:setBright(false)
            uiButton_xiuxian:setBright(false)
            uiButton_qingsong:setColor(cc.c3b(255,255,255))
            uiButton_huankuai:setColor(cc.c3b(170,170,170))
            uiButton_xiuxian:setColor(cc.c3b(170,170,170))
        elseif type == 2 then
            local mousic = string.format("achannel/%d/music%d.mp3",CHANNEL_ID,type)
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Musictype",2)
            cc.SimpleAudioEngine:getInstance():playMusic(mousic,true)
            uiButton_qingsong:setBright(false)
            uiButton_huankuai:setBright(true)
            uiButton_xiuxian:setBright(false)
            uiButton_qingsong:setColor(cc.c3b(170,170,170))
            uiButton_huankuai:setColor(cc.c3b(255,255,255))
            uiButton_xiuxian:setColor(cc.c3b(170,170,170))
        elseif type == 3 then
            local mousic = string.format("achannel/%d/music%d.mp3",CHANNEL_ID,type)
            cc.UserDefault:getInstance():setFloatForKey("UserDefault_Musictype",3)
            cc.SimpleAudioEngine:getInstance():playMusic(mousic,true)
            uiButton_qingsong:setBright(false)
            uiButton_huankuai:setBright(false)
            uiButton_xiuxian:setBright(true)
            uiButton_qingsong:setColor(cc.c3b(170,170,170))
            uiButton_huankuai:setColor(cc.c3b(170,170,170))
            uiButton_xiuxian:setColor(cc.c3b(255,255,255))
        end
    end
    if Musictype == 1 then
        uiButton_qingsong:setBright(true)
        uiButton_huankuai:setBright(false)
        uiButton_xiuxian:setBright(false)
        uiButton_qingsong:setColor(cc.c3b(255,255,255))
        uiButton_huankuai:setColor(cc.c3b(170,170,170))
        uiButton_xiuxian:setColor(cc.c3b(170,170,170))
    elseif Musictype == 2 then
        uiButton_qingsong:setBright(false)
        uiButton_huankuai:setBright(true)
        uiButton_xiuxian:setBright(false)
        uiButton_qingsong:setColor(cc.c3b(170,170,170))
        uiButton_huankuai:setColor(cc.c3b(255,255,255))
        uiButton_xiuxian:setColor(cc.c3b(170,170,170))
    elseif Musictype == 3 then
        uiButton_qingsong:setBright(false)
        uiButton_huankuai:setBright(false)
        uiButton_xiuxian:setBright(true)
        uiButton_qingsong:setColor(cc.c3b(170,170,170))
        uiButton_huankuai:setColor(cc.c3b(170,170,170))
        uiButton_xiuxian:setColor(cc.c3b(255,255,255))
    end
    Common:addTouchEventListener(uiButton_qingsong,function() settingMusicType(1) end)
    Common:addTouchEventListener(uiButton_huankuai,function() settingMusicType(2) end)
    Common:addTouchEventListener(uiButton_xiuxian,function() settingMusicType(3) end) 


    
    local uiImage_avatar = ccui.Helper:seekWidgetByName(self.root,"Image_avatar")
    Common:requestUserAvatar(UserData.User.userID,UserData.User.szLogoInfo,uiImage_avatar,"img")
     local uiText_name = ccui.Helper:seekWidgetByName(self.root,"Text_name")
    uiText_name:setString(string.format("昵称：%s",UserData.User.szNickName))
    local uiText_ID = ccui.Helper:seekWidgetByName(self.root,"Text_ID")
    uiText_ID:setString(string.format("账号：%d",UserData.User.userID))
    local uiButton_logout = ccui.Helper:seekWidgetByName(self.root,"Button_logout")
    Common:addTouchEventListener(uiButton_logout,function()        
            NetMgr:getLogicInstance():closeConnect()
            require("common.SceneMgr"):switchScene(require("app.MyApp"):create(false,false):createView("LoginLayer"),SCENE_LOGIN)
            EventMgr:dispatch(EventType.EVENT_TYPE_EXIT_HALL)
    end)
    local Update = require("loading.Update")
    local uiButton_Toreport = ccui.Helper:seekWidgetByName(self.root,"Button_Toreport")
    uiButton_Toreport:setVisible(false)
    Common:addTouchEventListener(uiButton_Toreport,function() 
--        if Update.version ~= Update.newVersion and  Update.version ~= nil then         
--            local versionInfoBB = string.format("当前最新版本为%s\n请更新到最新版本",Update.newVersion)                        
--            require("common.MsgBoxLayer"):create(1,nil,versionInfoBB,function() 
--                if resetPackageLoaded then
--                    resetPackageLoaded()
--                end
--                NetMgr:getLogicInstance():closeConnect()
--                EventMgr:dispatch(EventType.EVENT_TYPE_EXIT_HALL)    
--                local scene = cc.Director:getInstance():getRunningScene()
--                scene:removeAllChildren()
--                scene:addChild(require("loading.LoadingLayer"):create())
--            end)
--
--        else
--            require("common.MsgBoxLayer"):create(0,nil,string.format("已是最新版本，无需更新！！！"))
--        end   
    end)    
end

function SettingsLayer:setGame(type)
    local uiPanel_paizhu = ccui.Helper:seekWidgetByName(self.root,"Panel_paizhuo")
    uiPanel_paizhu:removeAllChildren()
    if type == 2 then 
        uiPanel_paizhu:addChild(require("app.MyApp"):create():createView("PaohuzisettingsLayer"))
    elseif type == 3 then
        uiPanel_paizhu:addChild(require("app.MyApp"):create():createView("MajiangsettingsLayer"))
    elseif type == 4 then
        uiPanel_paizhu:addChild(require("app.MyApp"):create():createView("PukesettingsLayer"))
    end 
   
end 
function SettingsLayer:initBUG()         --问题反馈

    local uiTextField_BUG = ccui.Helper:seekWidgetByName(self.root,"TextField_BUG")
    local uiButton_BUG = ccui.Helper:seekWidgetByName(self.root,"Button_BUG")
    Common:addTouchEventListener(uiButton_BUG,function() 
        if uiTextField_BUG:getString() == "" then
            require("common.MsgBoxLayer"):create(0,nil,"提交内容不能为空")
        else                   
            print("提交内容不能为空",uiTextField_BUG:getString(),UserData.User.userID)                                                
            local xmlHttpRequest = cc.XMLHttpRequest:new()
            xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
            xmlHttpRequest:setRequestHeader("Content-Type","application/json; charset=utf-8")
            xmlHttpRequest:open("POST",string.format(HttpUrl.POST_URL_ReportSubmit))--require("app.user.UserData").User.userID,100000
            local function onHttpRequestCompleted()
                if xmlHttpRequest.status == 200 then
                    print("getWinXin",xmlHttpRequest.response)
                    local data = json.decode(xmlHttpRequest.response)                       
                    require("common.MsgBoxLayer"):create(0,nil,"提交成功，感谢您的参与！")          
                    return
                end
            end
            xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
            xmlHttpRequest:send(string.format("{'query':{'UserID':'%d','ReportInfo':'%s'}}",UserData.User.userID,uiTextField_BUG:getString()))   
            uiTextField_BUG:setString("")             
        end 
    end)
end

return SettingsLayer
