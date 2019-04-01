local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")

local GuilLayer_6 = class("GuilLayer_6", cc.load("mvc").ViewBase)

function GuilLayer_6:onEnter()
    EventMgr:registListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT) 
    EventMgr:registListener(EventType.RET_GET_GUILD_INFO_BY_GUILDID,self,self.RET_GET_GUILD_INFO_BY_GUILDID)        --查询公会
    EventMgr:registListener(EventType.RET_JOIN_GUILD,self,self.RET_JOIN_GUILD)      --加入公会
    EventMgr:registListener(EventType.RET_SETTINGS_GUILD,self,self.RET_SETTINGS_GUILD)    --更改公会 
    EventMgr:registListener(EventType.EVENT_TYPE_TO_VIEW_GUILD,self,self.EVENT_TYPE_TO_VIEW_GUILD)
    EventMgr:registListener(EventType.RET_SC_SUB_GET_PROXY_RECORD,self,self.RET_SC_SUB_GET_PROXY_RECORD)
    
end

function GuilLayer_6:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT) 
    EventMgr:unregistListener(EventType.RET_GET_GUILD_INFO_BY_GUILDID,self,self.RET_GET_GUILD_INFO_BY_GUILDID) 
    EventMgr:unregistListener(EventType.RET_JOIN_GUILD,self,self.RET_JOIN_GUILD) 
    EventMgr:unregistListener(EventType.RET_SETTINGS_GUILD,self,self.RET_SETTINGS_GUILD) 
    EventMgr:unregistListener(EventType.EVENT_TYPE_TO_VIEW_GUILD,self,self.EVENT_TYPE_TO_VIEW_GUILD)
    EventMgr:unregistListener(EventType.RET_SC_SUB_GET_PROXY_RECORD,self,self.RET_SC_SUB_GET_PROXY_RECORD)
   
end


function GuilLayer_6:onCreate()
    if PLATFORM_TYPE ~= cc.PLATFORM_OS_DEVELOPER then
        local tableLoginInfo ,data = UserData.User:readLoginInfo()
        if data ~= nil then 
            if data.wType == 1 then
                self:setVisible(false)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.RemoveSelf:create()))
                require("common.MsgBoxLayer"):create(1,nil,"是否注销账号,采用微信账号登陆即可加入公会(ps:如果登陆界面显示游客登陆,请重新启动游戏更新至最新版本)?",function() 
                    NetMgr:getLogicInstance():closeConnect()
                    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("LoginLayer"),SCENE_LOGIN)
                    EventMgr:dispatch(EventType.EVENT_TYPE_EXIT_HALL)
                end)
                return
            end
        end  
    end  
    if StaticData.Hide[CHANNEL_ID].btn1 == 0 then
        self:setVisible(false)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.RemoveSelf:create()))
        return
    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GuildLayer_6.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)            
        if UserData.Guild.dwGuildID ~= 0 then
            self:initFirst()
            self:initGuilInfo()      
            if CHANNEL_ID == 4 or CHANNEL_ID == 5 then
                self:showUI(2)
            else
                self:showUI(1)
            end
        else
            self:initFirst()
            self:showUI(0)
        end    
    cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_Guil,os.time())
end

function GuilLayer_6:showUI(index)
    local uiPanel_fisrt = ccui.Helper:seekWidgetByName(self.root,"Panel_fisrt")
	local uiPanel_information = ccui.Helper:seekWidgetByName(self.root,"Panel_information")
	local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare")
    local uiButton_setting = ccui.Helper:seekWidgetByName(self.root,"Button_setting")
    local uiButton_share = ccui.Helper:seekWidgetByName(self.root,"Button_share")
    local uiText_3 = ccui.Helper:seekWidgetByName(self.root,"Text_3")
    local uiText_4 = ccui.Helper:seekWidgetByName(self.root,"Text_4")
	if index == 0 then
	   uiPanel_fisrt:setVisible(true)
       uiPanel_information:setVisible(false)
    elseif index == -1 then
       UserData.Share:openURL(StaticData.Channels[CHANNEL_ID].guildFunction) --后台管理网站
	elseif index == 1 then
       uiPanel_fisrt:setVisible(false)
       uiPanel_information:setVisible(true)
        if self.proxyRecordPos == nil then
            self.proxyRecordPos = 1
        end
        UserData.Record:sendMsgGetProxyRecord(self.proxyRecordPos,self.proxyRecordPos+20)
    elseif index == 2 then
        uiPanel_fisrt:setVisible(false)
        uiPanel_information:setVisible(true)
        uiText_3:setVisible(false)
        uiText_4:setVisible(false)
        if self.proxyRecordPos == nil then
            self.proxyRecordPos = 1
        end
        UserData.Record:sendMsgGetProxyRecord(self.proxyRecordPos,self.proxyRecordPos+20)
           
    else
	   return
	end
   
end
    
function GuilLayer_6:updateGuilInfo()
    if UserData.Guild.dwGuildID == 0 then
        return
    end
    local Text_name = ccui.Helper:seekWidgetByName(self.root,"Text_name")
    Text_name:setString(UserData.Guild.szGuildName)
    local Text_hz = ccui.Helper:seekWidgetByName(self.root,"Text_hz")
    Text_hz:setString(UserData.Guild.szPresidentName)
    local Text_ID = ccui.Helper:seekWidgetByName(self.root,"Text_ID")
    Text_ID:setString(UserData.Guild.dwGuildID)
--    local Text_num = ccui.Helper:seekWidgetByName(self.root,"Text_num")
--    Text_num:setString(UserData.Guil.societyMenberCount)
    local Text_announcement = ccui.Helper:seekWidgetByName(self.root,"Text_announcement")
    Text_announcement:setString(UserData.Guild.szGuildNotice)
    local uiButton_setting = ccui.Helper:seekWidgetByName(self.root,"Button_setting")
    if UserData.Guild.dwPresidentID == UserData.User.userID then
        uiButton_setting:setVisible(true)
    else
        uiButton_setting:setVisible(false)
    end
end

function GuilLayer_6:initFirst()
    local roomNumber = {}  
    local roomNum = ""
    local TextField_jion = ccui.Helper:seekWidgetByName(self.root,"TextField_jion")
    local TextField_jion_1 = ccui.Helper:seekWidgetByName(self.root,"TextField_jion_1")  
    if CHANNEL_ID == 8 or CHANNEL_ID == 9 then
        local function roomNumberDefault()   
                TextField_jion_1:setString("")      
                roomNumber = {}
                roomNum = "" 
        end
        TextField_jion:setVisible(false)
        roomNumberDefault()
    else
       local function roomNumberDefault()   
                TextField_jion:setString("")
                roomNumber = {}
                roomNum = "" 
        end
        TextField_jion_1:setVisible(false)
        roomNumberDefault()
    end
    
    local function roomNumberAdd(num)
        for i = 1 , 8 do
            if roomNumber[i] == nil then 
                roomNumber[i] = num
                roomNum = ""
                for j = 1 , i do
                    roomNum =roomNum..roomNumber[j]
                                         
                end
                TextField_jion:setString(string.sub(roomNum,1,8)) 
                TextField_jion_1:setString(string.sub(roomNum,1,8))  
                break 
            else                         
            end 
        end
    end 
    local function roomNumberDel()
        for i = 8 , 1 , -1 do
            if roomNumber[i] ~= nil then
                roomNumber[i] = nil
                roomNum = ""
                for j = 1 , i-1 do
                    roomNum = roomNum..roomNumber[j]                       
                end
                TextField_jion:setString(string.sub(roomNum,1,8)) 
                TextField_jion_1:setString(string.sub(roomNum,1,8)) 
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
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_jion"),function() 
        if TextField_jion:getString() == "" or TextField_jion_1:getString() == "" then
            require("common.MsgBoxLayer"):create(0,nil,"公会ID不能为空")
        else                      				               				                                                    
			 if CHANNEL_ID == 8 or CHANNEL_ID == 9 then 
                local n = tonumber(TextField_jion_1:getString())   
				print("公会ID不能为空",UserData.Guild,roomNum,n)
				roomNumber = {} 
				roomNum = ""   
                TextField_jion_1:setString("")
				UserData.Guild:getGuildInfoByGuildID(n)
			 else            
				local m = tonumber(TextField_jion:getString())             
				print("公会ID不能为空",UserData.Guild.societyID,roomNum,m)   
				roomNumber = {} 
				roomNum = ""   
				TextField_jion:setString("")  
				UserData.Guild:getGuildInfoByGuildID(m)
			 end 
			
        end     
    end)
end

function GuilLayer_6:initGuilInfo()
    if UserData.Guild.dwGuildID == 0 then
        return
    end
    local uiButton_share = ccui.Helper:seekWidgetByName(self.root,"Button_share")
    Common:addTouchEventListener(uiButton_share,function() 
        local data = clone(UserData.Share.tableShareParameter[1])
        data.cbTargetType = 1
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID,UserData.Guild.dwGuildID)
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1008]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1008)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"分享成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"分享失败")  
            end  
        end)
    end)

    local uiButton_invitation = ccui.Helper:seekWidgetByName(self.root,"Button_invitation")
    Common:addTouchEventListener(uiButton_invitation,function() 
        local data = clone(UserData.Share.tableShareParameter[1])
        data.cbTargetType = 2
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID,UserData.Guild.dwGuildID)
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1009]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1009)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"邀请成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"邀请失败")  
            end  
        end)
    end)  
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_setting"),function() 
        print("跳后台")
        UserData.Share:openURL(StaticData.Channels[CHANNEL_ID].guildFunction) --后台管理网站
    end)   
    local uiText_noticeContents = ccui.Helper:seekWidgetByName(self.root,"Text_noticeContents")
    uiText_noticeContents:setString(UserData.Notice.notice.szNoticeInfo)
    self:updateGuilInfo()
end
    


function GuilLayer_6:SUB_SC_ACTIONRESULT(event)
    local data = event._usedata
    if data.wCode == 0 then
        UserData.User:sendMsgUpdateUserInfo(0)
        --处理奖励
        local tableReward = {}
        local tempTable = Common:stringSplit(data.szReward,"|")
        for key, var in pairs(tempTable) do
            local tempReward = Common:stringSplit(var,"_")
            local rewardData = {}
            rewardData.wPropID = tonumber(tempReward[1])
            rewardData.dwPropCount = tonumber(tempReward[2])
            table.insert(tableReward,#tableReward + 1, rewardData)
        end
        require("common.RewardLayer"):create("福利奖励",nil,tableReward)
    else
        require("common.MsgBoxLayer"):create(0,nil,"领取奖励失败!")
    end
end

function GuilLayer_6:RET_GET_GUILD_INFO_BY_GUILDID(event)
    local data = event._usedata
    if data.dwGuildID == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"加入失败!")
    else                  
        require("common.MsgBoxLayer"):create(1,nil,string.format("公会ID：  %s\n\n 公会名称： %s\n\n 会长名字：%s", data.dwGuildID,data.szGuildName, data.szPresidentName),
        function() 
            UserData.Guild:joinGuild(data.dwGuildID)
        end)                                    
    end      
end

function GuilLayer_6:RET_JOIN_GUILD(event)
    local data = event._usedata   
    if data.ret == 0 then   
        UserData.Guild.dwID = data.dwID
        UserData.Guild.dwGuildID = data.dwGuildID
        UserData.Guild.szGuildName = data.szGuildName
        UserData.Guild.szGuildNotice = data.szGuildNotice
        UserData.Guild.dwMemberCount = data.dwMemberCount
        UserData.Guild.dwPresidentID = data.dwPresidentID
        UserData.Guild.szPresidentName = data.szPresidentName
        UserData.Guild.szPresidentLogo = ""
        
        self:EVENT_TYPE_TO_VIEW_GUILD(event)
        if CHANNEL_ID ~= 8 and  CHANNEL_ID ~= 9 then      
            require("common.RewardLayer"):create("公会",nil,{{wPropID = 1003,dwPropCount = 5 }})    
        end 
        UserData.User:sendMsgUpdateUserInfo(1)   
    else 
        require("common.MsgBoxLayer"):create(0,nil,"请求失败！")          
    end
end

function GuilLayer_6:RET_SETTINGS_GUILD(event)
    local data = event._usedata
    if data == nil then
        require("common.MsgBoxLayer"):create(0,nil,"修改失败!")
    elseif data["ret"] == 1 then
        require("common.MsgBoxLayer"):create(0,nil,data["Obj"])
    elseif data["ret"] == 0 then 
        self:updateGuilInfo()
        if CHANNEL_ID == 4 or CHANNEL_ID == 5 then
            self:showUI(2)
        else
            self:showUI(1)
        end
        for key, var in pairs(self.tableBtn) do
            if key == 1 then
                var:setBright(false)
            else
                var:setBright(true)
            end
        end
    end
end

function GuilLayer_6:EVENT_TYPE_TO_VIEW_GUILD(event)
    self:initFirst()
    self:initGuilInfo()
    self:updateGuilInfo()
    if CHANNEL_ID == 4 or CHANNEL_ID == 5 then
        self:showUI(2)
    else
        self:showUI(1)
    end
    
end


function GuilLayer_6:RET_SC_SUB_GET_PROXY_RECORD(event)
   
end

return GuilLayer_6