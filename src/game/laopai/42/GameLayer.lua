local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local EventType = require("common.EventType")
local NetMsgId = require("common.NetMsgId")
local GameCommon = require("game.laopai.GameCommon")
local Bit = require("common.Bit")
local Default = require("common.Default")
local GameLogic = require("game.laopai.GameLogic")
local ActionLayer = require("game.laopai.ActionLayer")
local CardLayer = require("game.laopai.CardLayer")
local OprationLayer = require("game.laopai.OprationLayer")
local Base64 = require("common.Base64")
local GameDesc = require("common.GameDesc")
local GameLayer = class("GameLayer",function()
    return ccui.Layout:create()
end)

function GameLayer:create(...)
    local view = GameLayer.new()
    view:onCreate(...)
    local function onEventHandler(eventType)
        if eventType == "enter" then
            view:onEnter()
        elseif eventType == "exit" then
            view:onExit()
        elseif eventType == "cleanup" then
            view:onCleanup()
        end
    end
    view:registerScriptHandler(onEventHandler)
    return view
end

function GameLayer:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:registListener(EventType.GAMEVIEWMSG,self,self.OnViewMsg)
    EventMgr:registListener(EventType.HTTPMSG,self,self.onHTTPupdataTou)
    EventMgr:registListener(EventType.ClientSockEventMsg,self,self.OnNetMsg)
    EventMgr:registListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
    if GameCommon.serverData.cbRoomFriend ~= -1 then
    self.scheduleUpdateObj = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:update(delta) end, 0 ,false)
    end 
end

function GameLayer:onExit()
    EventMgr:unregistListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:unregistListener(EventType.GAMEVIEWMSG,self,self.OnViewMsg)
    EventMgr:unregistListener(EventType.HTTPMSG,self,self.onHTTPupdataTou)
    EventMgr:unregistListener(EventType.ClientSockEventMsg,self,self.OnNetMsg)
    EventMgr:unregistListener(EventType.SUB_GR_USER_ENTER,self,self.SUB_GR_USER_ENTER)
    
    if GameCommon.serverData.cbRoomFriend ~= -1 and self.scheduleUpdateObj then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdateObj)
    end
end

function GameLayer:onCleanup()

end

function GameLayer:onCreate(...)
    
    self:startGame(...)

end


--游戏开始
function GameLayer:startGame(...)
    local params = {...}
    self.dwUserID = params[1]
    GameCommon.tableConfig = params[2]
    GameCommon.playbackData = params[3]
    GameCommon.tagUserInfoList = nil
    GameCommon.serverData = {
        cbRoomFriend = 1,
        wKindID = GameCommon.tableConfig.wKindID
    }
    if GameCommon.playbackData ~= nil then
        GameCommon.serverData.cbRoomFriend = -1
    end
    GameCommon.friendsRoomInfo = {
        wTableNumber = GameCommon.tableConfig.wTableNumber,
        wCurrentNumber = GameCommon.tableConfig.wCurrentNumber,
        wTbaleID = GameCommon.tableConfig.wTbaleID,
        nTableType = GameCommon.tableConfig.nTableType,
        dwClubID = GameCommon.tableConfig.dwClubID,
    }
    GameCommon:setGameLogic("game.laopai.GameLogic")
    cc.Director:getInstance():getActionManager():removeAllActions()
    self:removeAllChildren()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayerlaopai.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    if GameCommon.serverData.cbRoomFriend == 1 or GameCommon.serverData.cbRoomFriend == -1  then
        GameCommon.isFriendsGame = true
    else
        GameCommon.isFriendsGame = false
    end

    self.cardLayer = nil            --卡牌表现
    self.actionLayer = nil          --动作表现
    self.outCardTips = nil          --出牌显示
    self.waitArmature = nil         --等待动画
    self.label_time = nil           --时间
    --场景静态表现
    self.Panel_eave = {}
    --正在执行动作
    self.blockTime = 0  --阻塞的时间
    self.isRunningActions = false
    self.userMsgArray = {} --消息缓存
    self.bWeaveItemCount = {}                      --组合组合数目
    self.weaveItemArray = {}                       --胡息组合扑克

    --几次没操作了
    self.outOprationIndex   = 0
    self.outOprationState = false
    self.outOprationLayOut = nil
    self.taskInfo = nil  --游戏任务
    self.breakLineCout = 0  --断线重连次数
    self.listview = {}    --头像列表
    self.max_COUNT = GameCommon.MAX_COUNT --最大卡牌数量


    GameCommon:init()
    GameCommon.dwUserID = self.dwUserID
    GameCommon.wPlayerCount = 4
    GameCommon.wKindID = GameCommon.serverData.wKindID
    Common.wKindID = GameCommon.serverData.wKindID
    GameCommon.cardStackWidth =7
    self.max_COUNT=15
    GameCommon.handCardalignment= GameCommon.centrealignment
    GameCommon.gameType = 0
    self.tableAddUserScore = {[1] = 0,[2] = 0,[3] = 0,[4] = 0}
    self.sendCountUpdateTime = 0
    self.sendCount = 0
    self.MeTableCard = 0

    GameCommon.isGameEnd = false
    self.friendReady = {[1]= false,[2] =false ,[3] = false,[4] = false}

    local visibleSize = cc.Director:getInstance():getVisibleSize()   -- 弹框按钮 
--    local uiPanel_function = ccui.Helper:seekWidgetByName(self.root,"Panel_function")
--    uiPanel_function:setPosition(visibleSize.width/2, visibleSize.height*1.1)
--    uiPanel_function:addTouchEventListener(function(sender,event)
--        if event == ccui.TouchEventType.ended then
--            GameCommon.hostedTime = os.time()
--            uiPanel_function:stopAllActions()
--            if uiPanel_function:getPositionY() > visibleSize.height then
--                uiPanel_function:runAction(cc.Sequence:create(
--                    cc.MoveTo:create(0.2,cc.p(visibleSize.width/2, visibleSize.height*1.0))))
--            else
--                uiPanel_function:runAction(cc.MoveTo:create(0.2,cc.p(visibleSize.width/2, visibleSize.height*1.1)))
--            end
--        end
--    end) 
    local uiButton_menu = ccui.Helper:seekWidgetByName(self.root,"Button_menu")
    local uiPanel_function = ccui.Helper:seekWidgetByName(self.root,"Panel_function")
    uiPanel_function:setEnabled(false)
    Common:addTouchEventListener(uiButton_menu,function() 
        uiPanel_function:stopAllActions()
        uiPanel_function:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-99,0)),cc.CallFunc:create(function(sender,event) 
            uiPanel_function:setEnabled(true)
        end)))
        uiButton_menu:stopAllActions()
        uiButton_menu:runAction(cc.ScaleTo:create(0.2,0))
    end)
    uiPanel_function:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
            uiPanel_function:stopAllActions()
            uiPanel_function:runAction(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
                uiPanel_function:setEnabled(false)
            end),cc.MoveTo:create(0.2,cc.p(0,0))))
            uiButton_menu:stopAllActions()
            uiButton_menu:runAction(cc.ScaleTo:create(0.2,1))
        end
    end) 
    
    local uiPanel_qipaitongji = ccui.Helper:seekWidgetByName(self.root,"Panel_qipaitongji")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_qipai"),function() 
            uiPanel_qipaitongji:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.2,cc.p(visibleSize.width/2, visibleSize.height/2))))
    end) 
    self:WithTheNewDiscard()
    uiPanel_qipaitongji:addTouchEventListener(function(sender,event)
        if event == ccui.TouchEventType.ended then
                uiPanel_qipaitongji:runAction(cc.Sequence:create(
                    cc.MoveTo:create(0.2,cc.p(-visibleSize.width/2, visibleSize.height/2))))
        end
    end)
        
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_settings"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("SettingsLayer"))
    end)

    local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")  --准备
    Common:addTouchEventListener(uiButton_ready,function() 
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"o",false)
    end)   
    local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")  -- 邀请好友
    local uiButton_out = ccui.Helper:seekWidgetByName(self.root,"Button_out")  
    uiButton_Invitation:setPressedActionEnabled(true)
    if StaticData.Hide[CHANNEL_ID].btn4 ~= 1 then
        uiButton_Invitation:setVisible(false)
        uiButton_out:setVisible(false)
    end
    Common:addTouchEventListener(uiButton_Invitation,function() 
        local currentPlayerCount = 0
        for key, var in pairs(GameCommon.player) do
            currentPlayerCount = currentPlayerCount + 1
        end
        local player = "("
        for key, var in pairs(GameCommon.tagUserInfoList) do
            if key == 1 then
                player = player..var.szNickName
            else
                player = player.."、"..var.szNickName
            end
        end
        player = player..")"
        local data = clone(UserData.Share.tableShareParameter[3])
        data.dwClubID = GameCommon.tableConfig.dwClubID
        data.szShareTitle = string.format(data.szShareTitle,StaticData.Games[GameCommon.serverData.wKindID].name,
            GameCommon.tableConfig.wTbaleID,GameCommon.friendsRoomInfo.wTableNumber,
            #GameCommon.tagUserInfoList,GameCommon.wPlayerCount-#GameCommon.tagUserInfoList)..player
        data.szShareContent = GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo).." (点击加入游戏)"
        data.szShareUrl = string.format(data.szShareUrl,UserData.User.userID, GameCommon.tableConfig.wTbaleID)
        if GameCommon.tableConfig.nTableType == TableType_ClubRoom then
            data.cbTargetType = Bit:_or(data.cbTargetType,0x20)
        end
        require("app.MyApp"):create(data, handler(self, self.pleaseOnlinePlayer)):createView("ShareLayer")
    end)
    local uiButton_disbanded = ccui.Helper:seekWidgetByName(self.root,"Button_disbanded")   -- 解散
    Common:addTouchEventListener(uiButton_disbanded,function() 
        require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
        end)
    end)
    
    local uiButton_position = ccui.Helper:seekWidgetByName(self.root,"Button_position")   -- 定位
    Common:addTouchEventListener(uiButton_position,function() 
        require("common.PositionLayer"):create(GameCommon.tableConfig.wKindID)
    end)
    local uiListView_function = ccui.Helper:seekWidgetByName(self.root,"ListView_function")
    local uiPanel_playerInfoBg = ccui.Helper:seekWidgetByName(self.root,"Panel_playerInfoBg")
    if  StaticData.Hide[CHANNEL_ID].btn10 == 0 then 
        uiListView_function:removeItem(uiListView_function:getIndex(uiButton_position)) 
        uiPanel_playerInfoBg:setVisible(false) 
    end    
    local uiButton_return = ccui.Helper:seekWidgetByName(self.root,"Button_return")
    Common:addTouchEventListener(uiButton_return,function() 
        require("common.MsgBoxLayer"):create(1,nil,"您确定返回大厅?",function()
            require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL)
        end)
    end)
    local uiText_title = ccui.Helper:seekWidgetByName(self.root,"Text_title")
--    local uiButton_auto = ccui.Helper:seekWidgetByName(self.root,"Button_auto")  --托管
--    Common:addTouchEventListener(uiButton_auto,function() 
--        self:startOutOpration()
--    end)

    local uiButton_cancel = ccui.Helper:seekWidgetByName(self.root,"Button_cancel")  --取消按钮
    Common:addTouchEventListener(uiButton_cancel,function() 
        require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    end) 
    
    local uiButton_out = ccui.Helper:seekWidgetByName(self.root,"Button_out")
    Common:addTouchEventListener(uiButton_out,function() 
        require("common.MsgBoxLayer"):create(1,nil,"您确定离开房间?\n房主离开意味着房间被解散",function()
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_LEAVE_TABLE_USER,"")
        end)
    end)  
    local uiPanel_guchou = ccui.Helper:seekWidgetByName(self.root,"Panel_guchou")      
    uiPanel_guchou:setVisible(false) 
    
    --解决UI差异
    if GameCommon.serverData.cbRoomFriend == 0 then--普通房
        local uiPanel_friendsRoom = ccui.Helper:seekWidgetByName(self.root,"Panel_friendsRoom")
        uiPanel_friendsRoom:removeFromParent()
        local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
        uiButton_voice:removeFromParent()
        uiButton_Invitation:setVisible(false)
        uiButton_ready:setVisible(false)
        uiButton_disbanded:setVisible(false)
--        uiButton_auto:setVisible(true)
        uiButton_cancel:setVisible(true)
        uiButton_out:setVisible(false)
    elseif GameCommon.serverData.cbRoomFriend == 1 then--好友房
	    self:addVoice()
        uiButton_cancel:setVisible(false)
        uiButton_out:setVisible(true)
--		uiButton_auto:setVisible(false)
        local uiPanel_friendsRoom = ccui.Helper:seekWidgetByName(self.root,"Panel_friendsRoom")
        local uiButton_disbanded = ccui.Helper:seekWidgetByName(self.root,"Button_disbanded")        
        uiButton_disbanded:setPressedActionEnabled(true)
        local function onEventDissolution(sender,event)
            if event == ccui.TouchEventType.ended then
                Common:palyButton()
                require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
                    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
                end)
            end
        end
        uiButton_disbanded:addTouchEventListener(onEventDissolution)

        local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")
        uiButton_Invitation:setPressedActionEnabled(true)
        if StaticData.Hide[CHANNEL_ID].btn4 ~= 1 then
            uiButton_Invitation:setVisible(false)
            uiButton_out:setVisible(false)
        end
        local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
        uiButton_ready:setPressedActionEnabled(true)
        local function onEventInvitationready(sender,event)
            if event == ccui.TouchEventType.ended then
                Common:palyButton()
                uiButton_ready:setVisible(false)
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_READY,"o",false)
                --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            end
        end
        
        --冲分按钮
        uiButton_ready:addTouchEventListener(onEventInvitationready)       
        local uiImage_atpoints = ccui.Helper:seekWidgetByName(self.root,"Image_atpoints")
        uiImage_atpoints:setVisible(false)        
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_blunt0"),function()   --不冲分
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SelectCF,"b",0)
            uiImage_atpoints:setVisible(false)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_blunt1"),function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SelectCF,"b",1)
            uiImage_atpoints:setVisible(false)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_blunt2"),function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SelectCF,"b",2)
            uiImage_atpoints:setVisible(false)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_blunt3"),function() 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_SelectCF,"b",3)
            uiImage_atpoints:setVisible(false)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        
        --箍丑按钮
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_guchou"),function()            
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_GuChou,"b",1)
--            OprationLayer:dealGuo() 
            print("发送箍丑1") 
--            uiPanel_guchou:setVisible(false)
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_buguchou"),function() 
            print("发送箍丑2") 
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_GuChou,"b",2)
            --uiPanel_guchou:setVisible(false)
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end)
        
        if GameCommon.friendsRoomInfo ~= nil then
            local roomID = tostring(GameCommon.tableConfig.wTbaleID)
            local uiText_zhaNiaoCount = ccui.Helper:seekWidgetByName(self.root,"Text_title")
            uiText_zhaNiaoCount:setString(string.format("溆浦老牌 房间号 %s 局数 %d/%d",roomID,GameCommon.friendsRoomInfo.wCurrentNumber,GameCommon.friendsRoomInfo.wTableNumber))
        end
    else    --回放    
        self:addVoice()
       -- uiButton_auto:setVisible(false)
        local uiPanel_friendsRoom = ccui.Helper:seekWidgetByName(self.root,"Panel_friendsRoom")
        uiPanel_friendsRoom:removeFromParent()

        if GameCommon.friendsRoomInfo ~= nil then
            local roomID = tostring(GameCommon.tableConfig.wTbaleID)
            local uiText_zhaNiaoCount = ccui.Helper:seekWidgetByName(self.root,"Text_title")
            uiText_zhaNiaoCount:setString(string.format("溆浦老牌 房间号 %s 局数 %d/%d",roomID,GameCommon.friendsRoomInfo.wCurrentNumber,GameCommon.friendsRoomInfo.wTableNumber))
        end     
    end

    for i = 1 , GameCommon.wPlayerCount do
        local uiPanel_player = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",i))
        uiPanel_player:setVisible(false)
    end
    local uiPanel_gameName = ccui.Helper:seekWidgetByName(self.root,"Panel_gameName")
    local img = ccui.ImageView:create(StaticData.Games[GameCommon.serverData.wKindID].imgDesk)
    uiPanel_gameName:addChild(img)
    img:setPosition(img:getParent():getContentSize().width/2,img:getParent():getContentSize().height/2+100)
    local uiPanel_bottom = ccui.Helper:seekWidgetByName(self.root,"Panel_bottom")
    local uiPanel_card = ccui.Helper:seekWidgetByName(self.root,"Panel_card")
    local uiPanel_effects = ccui.Helper:seekWidgetByName(self.root,"Panel_effects")
    local uiImage_rate = ccui.Helper:seekWidgetByName(self.root,"Image_rate")
    local uiAtlasLabel_rate = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_rate")    
    local uiButton_expression = ccui.Helper:seekWidgetByName(self.root,"Button_expression")
    uiButton_expression:setPressedActionEnabled(true)
    local function onEventExpression(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            require("common.GameChatLayer"):create(GameCommon.serverData.wKindID,function(index)
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_GF_USER_EXPRESSION,"ww",index,GameCommon:GetMeChairID())
            end,
            function(index,contents)
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SEND_CHAT,"dwbnsdns",
                    GameCommon:GetMeChairID(),index,GameCommon:getUserInfo(GameCommon:GetMeChairID()).cbSex,32,"",string.len(contents),string.len(contents),contents)
            end)
--            function(index,contents)
--            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SEND_CHAT,"dwbnsdns",
--            GameCommon:getRoleChairID(),index,GameCommon:getUserInfo(GameCommon:getRoleChairID()).cbSex,32,"",string.len(contents),string.len(contents),contents)
--            end)
        end
    end
    uiButton_expression:addTouchEventListener(onEventExpression)
    local uiListView_operationSub = ccui.Helper:seekWidgetByName(self.root,"ListView_operationSub")
    local uiButton_defaultOperationSub = ccui.Helper:seekWidgetByName(self.root,"Button_defaultOperationSub")
    local uiImage_line = ccui.Helper:seekWidgetByName(self.root,"Image_line")
    uiImage_line:setVisible(false)
    self.cardLayer = CardLayer:create(uiImage_line)
    uiPanel_card:addChild(self.cardLayer)
    local uiImage_stack = ccui.Helper:seekWidgetByName(self.root,"Image_stack")
    uiImage_stack:setVisible(false) 
    self.actionLayer = ActionLayer:create(uiImage_stack)
    uiPanel_effects:addChild(self.actionLayer)
    self.oprationLayer = OprationLayer:create()
    self.actionLayer:addChild(self.oprationLayer,1)
    self.outOprationLayOut = ccui.Helper:seekWidgetByName(self.root,"Panel_outOpration")
    self.outOprationLayOut:setVisible(false)
    local uiButton_outOparation = ccui.Helper:seekWidgetByName(self.root,"Button_outOparation")
    uiButton_outOparation:setPressedActionEnabled(true)
    local function onEventOutOparation(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            self:overOutOpration()
        end
    end
    uiButton_outOparation:addTouchEventListener(onEventOutOparation)

    if tagUserInfoList == nil then
        self:startWaitArmature(true)
    else
        GameCommon.tagUserInfoList = tagUserInfoList
        for key, var in pairs(GameCommon.tagUserInfoList) do
            var.other = nil
            if var.dwUserID == self.dwUserID then
                GameCommon.meChairID = var.wChairID
                print("输出位置号111:",GameCommon.meChairID)
            end
        end
    end
    
    --显示系统时间
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    local function onEventRefreshTime(sender,event)
        local date = os.date("*t",os.time())
        uiText_time:setString(string.format("%02d:%02d",date.hour,date.min))--,date.sec:%02d
        uiText_time:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(onEventRefreshTime)))
    end
    onEventRefreshTime()
    
    if GameCommon.serverData.cbRoomFriend == 1 then
        local LocationSystem = require("common.LocationSystem")
        local pos = LocationSystem.pos
        print("位子",pos.x,pos.y)
        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_SET_POSITION,"aad",pos.x, pos.y, UserData.User.userID)
    end 
    
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_skin"),function() 
        local UserDefault_MaJiangpaizhuo = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_MaJiangpaizhuo,0)
        UserDefault_MaJiangpaizhuo = UserDefault_MaJiangpaizhuo + 1
        if UserDefault_MaJiangpaizhuo < 0 or UserDefault_MaJiangpaizhuo > 2 then
            UserDefault_MaJiangpaizhuo = 0
        end
        cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_MaJiangpaizhuo,UserDefault_MaJiangpaizhuo)
        uiPanel_bg:removeAllChildren()
        uiPanel_bg:addChild(ccui.ImageView:create(string.format("game/game_table_bg%d.jpg",UserDefault_MaJiangpaizhuo)))
    end)
 
    local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
  --  uiText_desc:setString(self:getGameDesc()) 
    uiText_desc:setString(GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo))   
    self:updatePlayerInfo()
    self:loadingPlayback()

    --水印
    local uiImage_watermark = ccui.Helper:seekWidgetByName(self.root,"Image_watermark")
    uiImage_watermark:loadTexture(StaticData.Channels[CHANNEL_ID].icon)
    uiImage_watermark:ignoreContentAdaptWithSize(true)
end

function GameLayer:loadingPlayback()
    if GameCommon.serverData.cbRoomFriend ~= -1 then
        return
    end
    local uiPanel_end = ccui.Helper:seekWidgetByName(self.root,"Panel_end")
    uiPanel_end:setVisible(true)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayer_PlaybacLayer.csb")
    uiPanel_end:addChild(csb)
    local root = csb:getChildByName("Panel_root")
    local uiButton_return = ccui.Helper:seekWidgetByName(root,"Button_return")
    Common:addTouchEventListener(uiButton_return,function() 
        require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    end)
    local uiButton_play = ccui.Helper:seekWidgetByName(root,"Button_play")
    uiButton_play:setColor(cc.c3b(170,170,170))
    local uiButton_nextStep = ccui.Helper:seekWidgetByName(root,"Button_nextStep")
    Common:addTouchEventListener(uiButton_play,function(sender,event)
        uiButton_nextStep:setColor(cc.c3b(170,170,170))
        uiButton_play:setColor(cc.c3b(255,255,255))
        root:stopAllActions() 
        root:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function(sender,event) self:update(0) end)
        )))
    end)
    Common:addTouchEventListener(uiButton_nextStep,function(sender,event) 
        uiButton_play:setColor(cc.c3b(170,170,170))
        uiButton_nextStep:setColor(cc.c3b(255,255,255))
        root:stopAllActions() 
        self:update()
    end)
    self:AnalysisPlaybackData()
end

function GameLayer:AnalysisPlaybackData()
    if GameCommon.playbackData == nil then
        return
    end
    
    local luaFunc = require("common.Serialize"):create("",0)
    local totalSize = 0
    for key, var in pairs(GameCommon.playbackData) do
        totalSize = totalSize + var.wDataSize
        luaFunc:writeSendBuffer(var.cbData,var.wDataSize)
    end
    local size = 0
    while 1 do
        local wIdentifier = luaFunc:readRecvWORD()           --类型标示
        local wDataSize = luaFunc:readRecvWORD()             --数据长度
        local mainCmdID = luaFunc:readRecvWORD()            --主命令码
        local subCmdID = luaFunc:readRecvWORD()             --子命令码
        size = size + wDataSize + 8
        print("回放标志:",wIdentifier,wDataSize,mainCmdID,subCmdID,size,totalSize)
        if size > totalSize then 
            return
        else
            self:readBuffer(luaFunc,mainCmdID,subCmdID)
        end       
    end
end

function GameLayer:SUB_GR_USER_ENTER(event)
    local data = event._usedata
    self:startGame(UserData.User.userID, data)
end

function GameLayer:EVENT_TYPE_NET_RECV_MESSAGE(event)
    local netID = event._usedata
    if netID ~= NetMgr.NET_GAME then
       return
    end
    local netInstance = NetMgr:getGameInstance()
    local mainCmdID = netInstance.cppFunc:GetMainCmdID()
    local subCmdID = netInstance.cppFunc:GetSubCmdID()
    print(string.format("game: mainCmdID = %d  subCmdID = %d",mainCmdID,subCmdID))
    local luaFunc = netInstance.cppFunc
    self:readBuffer(luaFunc, mainCmdID, subCmdID)
end

function GameLayer:readBuffer(luaFunc, mainCmdID, subCmdID)
    local _tagMsg = {}
    _tagMsg.mainCmdID = mainCmdID
    _tagMsg.subCmdID = subCmdID
    _tagMsg.pBuffer = {}

    if mainCmdID == NetMsgId.MDM_GR_USER then
      
      if subCmdID == NetMsgId.SUB_GR_USER_READY then
            --服务器广播用户准备
            local dwUserID = luaFunc:readRecvDWORD()         --用户id
            local wChairID = luaFunc:readRecvWORD()         --椅子号
            self.friendReady[wChairID+1] = true
            if GameCommon.isGameEnd ~= true then
                self:updatePlayerInfo()
            end
            print("椅子号",wChairID)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function(sender,event)
                local viewID = GameCommon:SwitchViewChairID(wChairID) + 1
                local root = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
                local uiImage_ready = ccui.Helper:seekWidgetByName(root,"Image_ready")
                uiImage_ready:setVisible(true)
                if viewID == 2 then
                    local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
                    uiButton_ready:setVisible(false)
                end
            end)
            ))
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            return
        elseif subCmdID == NetMsgId.SUB_GR_USER_CONNECT then
            local luaFunc = NetMgr:getGameInstance().cppFunc
            local dwUserID=luaFunc:readRecvDWORD()--用户 I D
            local wChairID=luaFunc:readRecvWORD()--用户 I D            
            for key, var in pairs(GameCommon.tagUserInfoList) do
                if(var.dwUserID == dwUserID) then
                    print("用户上线 ",dwUserID,wChairID)
                    var.cbOnline = 0x00
                    break
                end
            end
            self:updatePlayerInfo()
            return        
         elseif subCmdID == NetMsgId.SUB_GR_USER_OFFLINE then
            local luaFunc = NetMgr:getGameInstance().cppFunc
            local dwUserID=luaFunc:readRecvDWORD()--用户 I D
            local wChairID=luaFunc:readRecvWORD()--用户 I D            
            for key, var in pairs(GameCommon.tagUserInfoList) do
                if(var.dwUserID == dwUserID) then
                    print("用户离线",dwUserID,wChairID)
                    var.cbOnline = 0x06
                    break
                end
            end
            self:updatePlayerInfo()
            return
	     elseif subCmdID == NetMsgId.SUB_GR_USER_STATISTICS then
            --好友房大结算
            _tagMsg.pBuffer.dwUserCount = luaFunc:readRecvDWORD()                       --用户总数
            _tagMsg.pBuffer.dwDataCount = luaFunc:readRecvDWORD()                       --数据条数
            _tagMsg.pBuffer.tScoreInfo = {}                                             --统计信息
            _tagMsg.pBuffer.bigWinner = 0
            _tagMsg.pBuffer.bigWinerScore = 0
            for i = 1, 8 do
                _tagMsg.pBuffer.tScoreInfo[i] = {}
                _tagMsg.pBuffer.tScoreInfo[i].dwUserID = luaFunc:readRecvDWORD()        --用户ID
                _tagMsg.pBuffer.tScoreInfo[i].player = GameCommon:getUserInfoByUserID(_tagMsg.pBuffer.tScoreInfo[i].dwUserID)
                _tagMsg.pBuffer.tScoreInfo[i].totalScore = 0
                _tagMsg.pBuffer.tScoreInfo[i].lScore = {}
                for j = 1, 20 do
                    _tagMsg.pBuffer.tScoreInfo[i].lScore[j] = luaFunc:readRecvLong()       --用户积分
                    _tagMsg.pBuffer.tScoreInfo[i].totalScore = _tagMsg.pBuffer.tScoreInfo[i].totalScore + _tagMsg.pBuffer.tScoreInfo[i].lScore[j]
                end
                if _tagMsg.pBuffer.tScoreInfo[i].totalScore > _tagMsg.pBuffer.bigWinerScore then
                    _tagMsg.pBuffer.bigWinner = _tagMsg.pBuffer.tScoreInfo[i].dwUserID
                    _tagMsg.pBuffer.bigWinerScore = _tagMsg.pBuffer.tScoreInfo[i].totalScore
                end
            end
            _tagMsg.pBuffer.dwTableOwnerID = luaFunc:readRecvDWORD()                    --房主ID
            _tagMsg.pBuffer.szOwnerName = luaFunc:readRecvString(32)                    --房主名字
            _tagMsg.pBuffer.szGameID = luaFunc:readRecvString(32)                    --结算唯一标志
            _tagMsg.pBuffer.tableConfig = GameCommon.tableConfig
            _tagMsg.pBuffer.serverData = GameCommon.serverData     --number_dwHorse
          --  _tagMsg.pBuffer.gameDesc = GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo)
            _tagMsg.pBuffer.gameConfig = GameCommon.number_dwHorse
            _tagMsg.pBuffer.gameDesc = GameDesc:getGameDesc(GameCommon.tableConfig.wKindID,GameCommon.number_dwHorse,GameCommon.tableConfig)
            _tagMsg.pBuffer.cbOrigin = luaFunc:readRecvByte() --解散原因

        elseif subCmdID == NetMsgId.SUB_GR_USER_LEAVE then
            --用户离开
            local luaFunc = NetMgr:getGameInstance().cppFunc
            local dwUserID=luaFunc:readRecvDWORD()--用户 I D
            local wChairID=luaFunc:readRecvWORD()--用户 I D

            for key, var in pairs(GameCommon.tagUserInfoList) do
                if(var.dwUserID == dwUserID) then
                    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
                    break
                end
            end
            self:updatePlayerInfo()
            return
            
        elseif subCmdID == NetMsgId.RET_GR_USER_SET_POSITION then
            local luaFunc = NetMgr:getGameInstance().cppFunc
            local location = {}
            location.x = luaFunc:readRecvDouble()
            location.y = luaFunc:readRecvDouble()
            local dwUserID = luaFunc:readRecvDWORD()
            local wChairID = luaFunc:readRecvWORD()
            for key, var in pairs(GameCommon.tagUserInfoList) do
                if(var.dwUserID == dwUserID) then
                    var.location = location
                    break
                end
            end
            return true
            
        elseif subCmdID == NetMsgId.SUB_GR_TABLE_STATUS then
            if GameCommon.friendsRoomInfo == nil then
                GameCommon.friendsRoomInfo = {}
            end
            GameCommon.friendsRoomInfo.wTableNumber = luaFunc:readRecvWORD()       --房间局数
            GameCommon.friendsRoomInfo.wCurrentNumber = luaFunc:readRecvWORD()    --当前局数
           
            local uiText_zhaNiaoCount = ccui.Helper:seekWidgetByName(self.root,"Text_title")
            uiText_zhaNiaoCount:setString(string.format("溆浦老牌 房间号 %s 局数 %d/%d",StaticData.Games[GameCommon.tableConfig.wKindID].name,GameCommon.friendsRoomInfo.wCurrentNumber,GameCommon.friendsRoomInfo.wTableNumber,2))
            return

        elseif subCmdID == NetMsgId.SUB_GR_DISMISS_TABLE_SUCCESS then
            GameCommon.isGameEnd = true
            print(#GameCommon.tagUserInfoList,GameCommon.wPlayerCount)
            if GameCommon.isFriendGameStart == true then
                require("common.MsgBoxLayer"):create(0,nil,"房间解散成功！")
            else
                require("common.MsgBoxLayer"):create(2,nil,"房间解散成功！",function(sender,event)
                    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL)
                end)
            end
            return
            
        elseif subCmdID == NetMsgId.SUB_GR_DISMISS_TABLE_STATE then
            local data = {}
            data.dwDisbandedTime = luaFunc:readRecvDWORD()
            data.wAdvocateDisbandedID = luaFunc:readRecvWORD()
            data.cbDisbandeState = {}
            for i = 1, 8 do
                data.cbDisbandeState[i] = luaFunc:readRecvByte()
            end
            data.dwUserIDALL = {}
            for i = 1, 8 do
                data.dwUserIDALL[i] = luaFunc:readRecvDWORD()
            end
            data.szNickNameALL = {}
            for i = 1, 8 do
                data.szNickNameALL[i] = luaFunc:readRecvString(32)
            end
            data.wKindID = GameCommon.serverData.wKindID
            require("common.DissolutionLayer"):create(GameCommon:getRoleChairID(),GameCommon.tagUserInfoList,data)
            return true
            
        elseif subCmdID == NetMsgId.SUB_GR_USER_COME then
            --用户进入
            if GameCommon.tagUserInfoList == nil then
                GameCommon.tagUserInfoList = {}
            end
            local data = {}
            data.dwUserID = luaFunc:readRecvDWORD()
            data.wChairID = luaFunc:readRecvWORD()
            data.szNickName = luaFunc:readRecvString(32)
            data.szPto = luaFunc:readRecvString(256)
            data.cbSex = luaFunc:readRecvByte()
            data.lScore = luaFunc:readRecvLong() 
            data.dwPlayAddr = luaFunc:readRecvDWORD() 
            data.cbOnline = luaFunc:readRecvByte()
            print("玩家用户进入中：",data.wChairID,data.cbOnline)         
            data.bReady = luaFunc:readRecvBool() 
            data.location = {}
            data.location.x = luaFunc:readRecvDouble()
            data.location.y = luaFunc:readRecvDouble()
            data.other = nil
            printInfo(data)
            if data.dwUserID == GameCommon.dwUserID or GameCommon.meChairID == nil then
                GameCommon.meChairID = data.wChairID
            end
            table.insert(GameCommon.tagUserInfoList,#GameCommon.tagUserInfoList+1,data)
            GameCommon.player = GameCommon.tagUserInfoList
            self:updatePlayerInfo()
--            self:updatePlayerOnline()
--            self:updatePlayerReady()
--            self:updatePlayerPosition()
            return true
            
        elseif subCmdID == NetMsgId.SUB_GR_PLAYER_INFO then 
                    --查看玩家信息
            _tagMsg.pBuffer.dwUserID = luaFunc:readRecvDWORD()
            _tagMsg.pBuffer.lWinCount = luaFunc:readRecvLong()  
            _tagMsg.pBuffer.lLostCount = luaFunc:readRecvLong()  
            _tagMsg.pBuffer.dwPlayTimeCount = luaFunc:readRecvDWORD()  
            _tagMsg.pBuffer.dwPlayAddr = luaFunc:readRecvDWORD() 
            _tagMsg.pBuffer.dwShamUserID = luaFunc:readRecvDWORD()
            if GameCommon.serverData.cbRoomFriend == 1 then
                _tagMsg.pBuffer.location = {}
                for i = 1, 8 do
                    _tagMsg.pBuffer.location[i-1] = {}
                    _tagMsg.pBuffer.location[i-1].x = luaFunc:readRecvDouble()
                    _tagMsg.pBuffer.location[i-1].y = luaFunc:readRecvDouble()
                    print("定位：",_tagMsg.pBuffer.location[i-1].x, _tagMsg.pBuffer.location[i-1].y)
                end
            else
                for i = 1, 8 do
                    if GameCommon.player[i-1] ~= nil then
                        GameCommon.player[i-1].dwOhterID = luaFunc:readRecvDWORD()
                    end
                end
            end
            self:showUserInfo(_tagMsg.pBuffer)
          --  require("common.PositionLayer"):create(GameCommon.wKindID,_tagMsg.pBuffer)
           

                   -- 
            return

        elseif subCmdID == NetMsgId.SUB_GR_SEND_CHAT then
            _tagMsg.pBuffer.dwUserID = luaFunc:readRecvDWORD()
            _tagMsg.pBuffer.dwSoundID = luaFunc:readRecvWORD()
            _tagMsg.pBuffer.cbSex = luaFunc:readRecvByte()
            _tagMsg.pBuffer.szNickName = luaFunc:readRecvString(32)
            _tagMsg.pBuffer.dwChatLength = luaFunc:readRecvDWORD()
            _tagMsg.pBuffer.szChatContent = luaFunc:readRecvString(_tagMsg.pBuffer.dwChatLength)
            --表情
            local viewID = GameCommon:SwitchViewChairID(_tagMsg.pBuffer.dwUserID)
            local pos=self.actionLayer:GetClockPos(viewID)
            local img = ccui.ImageView:create("laopai/table/word_plate_table19.png")
            img:setScale(0.8)
            self:addChild(img,1)
            img:setPosition(pos)
            img:runAction(cc.Sequence:create(cc.DelayTime:create(3.5),cc.RemoveSelf:create(),nil))
            local size = img:getContentSize()
            local contents = cc.Label:createWithSystemFont(_tagMsg.pBuffer.szChatContent, "Arial", 36)
            img:addChild(contents)
            contents:setWidth(size.width - 5)
            contents:setHeight(size.height - 5)
            contents:setAlignment(1,1)
            contents:setColor(cc.c3b(10,0,22))
            contents:setPosition(size.width/2,size.height/2)
            if _tagMsg.pBuffer.dwSoundID ~= 0 then
                if _tagMsg.pBuffer.cbSex == 1 then
                    require("common.Common"):playEffect(string.format("expression/sound_quick_xupu/quick_b_%d.mp3",_tagMsg.pBuffer.dwSoundID))
                else
                    require("common.Common"):playEffect(string.format("expression/sound_quick_xupu/quick_g_%d.mp3",_tagMsg.pBuffer.dwSoundID))

                end
            end
            return
        else
            print("not found this subCmdID : %d",subCmdID)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            return
        end

    elseif mainCmdID == NetMsgId.MDM_GR_LOGON then
        if subCmdID == NetMsgId.SUB_GR_LOGON_ERROR then
            _tagMsg.pBuffer.wErrolCode = luaFunc:readRecvWORD()    --错误代码
            _tagMsg.pBuffer.wServerID = luaFunc:readRecvWORD()     --错误代码
            _tagMsg.pBuffer.lScore = luaFunc:readRecvLong()        --分数
            _tagMsg.pBuffer.dwServerAddr = luaFunc:readRecvDWORD() --端口

        elseif subCmdID == NetMsgId.SUB_GR_LOGON_FINISH then
            return
        else
            print("not found this subCmdID : %d",subCmdID)
            return
        end

    elseif mainCmdID == NetMsgId.MDM_GF_GAME then
          if subCmdID == NetMsgId.RET_SC_GAME_CONFIG then
            local wGameHorse = {}           
            wGameHorse.numpep=luaFunc:readRecvByte()--    -- 代表4人玩 （ 写死）
            wGameHorse.mailiao=luaFunc:readRecvWORD()--    --买鸟数
            wGameHorse.fanbei=luaFunc:readRecvByte() --    --1、2、4 翻倍底分、
            wGameHorse.jiabei=luaFunc:readRecvByte() --    --庄家输赢做加减一倍底分、0无、1有
            wGameHorse.zimo=luaFunc:readRecvByte()   --    --只准自摸胡牌  1.有  0.无            
            wGameHorse.piaohua=luaFunc:readRecvByte()--    --1.有飘花、0.无飘花
            wGameHorse.bPlayerCount  = wGameHorse.numpep
            GameCommon.number_dwHorse = wGameHorse
            local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
 --           uiText_desc:setString(self:getGameDesc()) 
            uiText_desc:setString(GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo))       
            return
        elseif subCmdID == NetMsgId.SUB_S_GAME_SelectZhuang then
            _tagMsg.pBuffer.wBankerUser = luaFunc:readRecvWORD()        --庄家用户
            print("AAAAAAAAA",_tagMsg.pBuffer.wBankerUser) 
        elseif subCmdID == NetMsgId.SUB_S_GAME_START_MAJIANG then
            _tagMsg.pBuffer.wSiceCount = luaFunc:readRecvWORD()         --骰子点数
            _tagMsg.pBuffer.wBankerUser = luaFunc:readRecvWORD()        --庄家用户
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()       --当前用户          
            _tagMsg.pBuffer.cbCardData = {}                             --麻将列表
            for i = 1 , 17 do                                   
                if i == 17   then
                  _tagMsg.pBuffer.cbCardData[17] = luaFunc:readRecvByte() 
                  if _tagMsg.pBuffer.cbCardData[17] <= 60 then 
                  GameCommon.m_crad_17 = _tagMsg.pBuffer.cbCardData[i]
                  end 
                else 
                  _tagMsg.pBuffer.cbCardData[i] = luaFunc:readRecvByte()                
                end         
            end
            _tagMsg.pBuffer.wChairID = luaFunc:readRecvByte()
           
            local wChairID = GameCommon:SwitchViewChairID(_tagMsg.pBuffer.wChairID)         
            GameCommon.listdatacard[wChairID] = _tagMsg.pBuffer.cbCardData  

            for i = 1 ,#_tagMsg.pBuffer.cbCardData do                
                print("用户字牌数据:",GameCommon.wBankerUser,GameCommon:GetMeChairID(),_tagMsg.pBuffer.wBankerUser,wChairID,_tagMsg.pBuffer.wChairID,_tagMsg.pBuffer.wCurrentUser,i,_tagMsg.pBuffer.cbCardData[i])
            end 
        elseif subCmdID == NetMsgId.SUB_S_SpecialCard then
            _tagMsg.pBuffer.wActionUser = luaFunc:readRecvWORD()        --当前用户
            _tagMsg.pBuffer.cbUserAction = luaFunc:readRecvWORD()       --用户动作

        elseif subCmdID == NetMsgId.SUB_S_SpecialCard_RESULT then
            _tagMsg.pBuffer.wActionUser = luaFunc:readRecvWORD()        --当前用户
            _tagMsg.pBuffer.cbUserAction = luaFunc:readRecvWORD()       --用户动作
            _tagMsg.pBuffer.wSiceCount = luaFunc:readRecvWORD()         --骰子点数
            _tagMsg.pBuffer.lGameScore = {}
            for i = 1 , 4 do                                            --游戏输赢积分
                _tagMsg.pBuffer.lGameScore[i] = luaFunc:readRecvLong()
            end
            _tagMsg.pBuffer.cbCardData = {}
            for i = 1 , 17 do                                            --麻将列表
                _tagMsg.pBuffer.cbCardData[i] = luaFunc:readRecvByte()
            end

        elseif subCmdID == NetMsgId.SUB_S_OUT_CARD_NOTIFY_MAJIANG then             --用户提示出牌
            _tagMsg.pBuffer.wOutCardUser = luaFunc:readRecvWORD()       --还原用户
            print("----------------------------------------------------------")
            print("提示用户出牌1：",NetMsgId.SUB_S_OUT_CARD_NOTIFY_MAJIANG)
        elseif subCmdID == NetMsgId.SUB_S_OUT_CARD_RESULT then             --用户出牌
            _tagMsg.pBuffer.wOutCardUser = luaFunc:readRecvWORD()       --出牌用户
            _tagMsg.pBuffer.cbOutCardData = luaFunc:readRecvByte()      --出牌麻将
            print("用户出牌11:",_tagMsg.pBuffer.wOutCardUser,_tagMsg.pBuffer.cbOutCardData)
        elseif subCmdID == NetMsgId.SUB_S_SEND_CARD_MAJIANG then                   --发牌消息
            _tagMsg.pBuffer.cbCardData = luaFunc:readRecvByte()         --麻将数据
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()       --当前用户
            _tagMsg.pBuffer.wSiceCount = luaFunc:readRecvWORD()       --骰子点数
            _tagMsg.pBuffer.wOperateCode = luaFunc:readRecvWORD()       --执行发牌动作先前动作
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_NOTIFY_MAJIANG then              --操作提示
            _tagMsg.pBuffer.wResumeUser = luaFunc:readRecvWORD()        --还原用户
            _tagMsg.pBuffer.cbActionMask = luaFunc:readRecvWORD()       --动作掩码
            _tagMsg.pBuffer.cbActionCard = luaFunc:readRecvByte()       --动作麻将
            _tagMsg.pBuffer.bIsSelf = luaFunc:readRecvBool()            --
            
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_RESULT then              --操作结果
            _tagMsg.pBuffer.wOperateUser = luaFunc:readRecvWORD()       --操作用户
            _tagMsg.pBuffer.wProvideUser = luaFunc:readRecvWORD()       --供应用户
            _tagMsg.pBuffer.cbOperateCode = luaFunc:readRecvWORD()      --操作代码
            _tagMsg.pBuffer.cbOperateCard = luaFunc:readRecvByte()      --操作麻将
            _tagMsg.pBuffer.cbUserCardCout = luaFunc:readRecvByte()     --用户扑克

        elseif subCmdID == NetMsgId.SUB_S_CASTDICE_NOTIFY then             --要帅提示
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()       --要帅用户
            _tagMsg.pBuffer.bIsTingPai = luaFunc:readRecvBool()         --用户听牌
        elseif subCmdID == NetMsgId.SUB_S_CASTDICE_RESULT then             --要帅结果
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()       --要帅用户
            _tagMsg.pBuffer.DiceStatus = luaFunc:readRecvDWORD()         --掷骰状态          //原来是枚举类型 先用byte接
            _tagMsg.pBuffer.wDiceCount = luaFunc:readRecvWORD()         --骰子大小
            _tagMsg.pBuffer.wDiceCardOne = luaFunc:readRecvByte()
            _tagMsg.pBuffer.wDiceCardTwo = luaFunc:readRecvByte()
        elseif subCmdID == NetMsgId.SUB_S_GAME_END_MAJIANG then                    --游戏结束
            _tagMsg.pBuffer.wBankerUser = luaFunc:readRecvByte()        --庄家
            print("庄家",_tagMsg.pBuffer.wBankerUser)
            _tagMsg.pBuffer.cbChiHuCard = {}
            for i = 1,4 do
                _tagMsg.pBuffer.cbChiHuCard[i] = luaFunc:readRecvByte() --吃胡麻将
                print("吃胡麻将",i,_tagMsg.pBuffer.cbChiHuCard[i])
            end
            _tagMsg.pBuffer.bZhaNiao = {}
            for i = 1 , 6 do
                    _tagMsg.pBuffer.bZhaNiao[i] = luaFunc:readRecvByte()
                print("游戏结束玩家1",i,_tagMsg.pBuffer.bZhaNiao[i])
            end
            _tagMsg.pBuffer.wProvideUser = luaFunc:readRecvWORD()       --点炮用户
            print("点炮用户",_tagMsg.pBuffer.wProvideUser)
            _tagMsg.pBuffer.wWinner = {}
            for i = 1,4 do
                if i == 4 then
                    _tagMsg.pBuffer.wWinner[i] = luaFunc:readRecvBool() --赢家
                else
                    _tagMsg.pBuffer.wWinner[i] = luaFunc:readRecvBool()
                end
                print("赢家",i,_tagMsg.pBuffer.wWinner[i])
            end

            _tagMsg.pBuffer.lGameScore = {}
            for i = 1,4 do
                _tagMsg.pBuffer.lGameScore[i] = luaFunc:readRecvLong() --游戏积分
                print("游戏积分:",i,_tagMsg.pBuffer.lGameScore[i])
            end

            _tagMsg.pBuffer.wChiHuKind = {}
            for i = 1,4 do
                _tagMsg.pBuffer.wChiHuKind[i] = luaFunc:readRecvWORD() --胡牌类型
                print("胡牌类型",i,_tagMsg.pBuffer.wChiHuKind[i])
            end

            _tagMsg.pBuffer.cbCardCount = {}
            for i = 1,4 do
                _tagMsg.pBuffer.cbCardCount[i] = luaFunc:readRecvByte() --麻将数目
                print("麻将数目",i,_tagMsg.pBuffer.cbCardCount[i])
            end

            _tagMsg.pBuffer.cbCardData = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.cbCardData[i] = {}
                for j = 1 , 45 do
                    _tagMsg.pBuffer.cbCardData[i][j] = luaFunc:readRecvByte()   --麻将数据
                    print("麻将数据",i,j,_tagMsg.pBuffer.cbCardData[i][j])
                end
               
            end

            _tagMsg.pBuffer.strEnd = {}
            for i = 1 , 100 do
                _tagMsg.pBuffer.strEnd[i] = luaFunc:readRecvByte()
                print("玩家3",i,_tagMsg.pBuffer.strEnd[i])
            end
            _tagMsg.pBuffer.lCellScore =  luaFunc:readRecvLong()       --单位游戏币
            print("单位游戏币",_tagMsg.pBuffer.lCellScore)
            _tagMsg.pBuffer.lGameTax = luaFunc:readRecvInt()            --税收
            print("税收",_tagMsg.pBuffer.lGameTax)
            _tagMsg.pBuffer.cbChiHuSpecial = luaFunc:readRecvBool()     --特殊胡牌
            print("特殊胡牌",_tagMsg.pBuffer.cbChiHuSpecial)
            
           _tagMsg.pBuffer.bGuChou ={} 
            for i = 1 , 4 do
                if i == 4 then 
                    _tagMsg.pBuffer.bGuChou[i] = luaFunc:readRecvByte() 
                else
                    _tagMsg.pBuffer.bGuChou[i] = luaFunc:readRecvByte() 
                end   
                print("箍丑玩家3",i,_tagMsg.pBuffer.bGuChou[i])
            end
            
            _tagMsg.pBuffer.cbWeaveItemCount ={}            
            for i = 1 , 4 do
                if i == 4 then
                    _tagMsg.pBuffer.cbWeaveItemCount[i] = luaFunc:readRecvByte()    --组合数目
                else
                    _tagMsg.pBuffer.cbWeaveItemCount[i] = luaFunc:readRecvByte()    --组合数目
                end
                print("组合数目",i,_tagMsg.pBuffer.cbWeaveItemCount[i])
            end
 

            _tagMsg.pBuffer.WeaveItemArray ={}
            for i = 1 , 4 do
                _tagMsg.pBuffer.WeaveItemArray[i] = {}
                for j = 1 , 5 do
                    _tagMsg.pBuffer.WeaveItemArray[i][j] = {}
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbWeaveKind = luaFunc:readRecvWORD()   --组合类型
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbCenterCard = luaFunc:readRecvByte()  --中心麻将
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbPublicCard = luaFunc:readRecvByte()  --公开标志
                    _tagMsg.pBuffer.WeaveItemArray[i][j].wProvideUser = luaFunc:readRecvWORD()   --供应用户
                end
            end
            _tagMsg.pBuffer.bEndCard ={}                          --剩余牌蹲数据
            for i = 1 , 55 do 
                _tagMsg.pBuffer.bEndCard[i] = luaFunc:readRecvByte()
                print("箍丑玩家1",i,_tagMsg.pBuffer.bEndCard[i])   
            end 
            _tagMsg.pBuffer.wGameHorseCount ={} 
            for i = 1 , 4 do
                _tagMsg.pBuffer.wGameHorseCount[i] = luaFunc:readRecvByte()   
                print("箍丑玩家2",i,_tagMsg.pBuffer.wGameHorseCount[i])
            end
          

        elseif subCmdID == NetMsgId.SUB_S_OPERATE_HAIDI then
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()           --海底用户
            _tagMsg.pBuffer.bTingPai = luaFunc:readRecvBool()               --用户听牌
        elseif subCmdID == NetMsgId.SUB_S_GAME_END_TIPS_HUTYPE then
            return
            --            _tagMsg.pBuffer.wChiHuKind = {}
            --            for i = 1,4 do
            --                _tagMsg.pBuffer.wChiHuKind[i] = luaFunc:readRecvWORD() --胡牌类型
            --            end
        elseif subCmdID == NetMsgId.SUB_S_GAME_END_TIPS_MAJIANG then       --游戏胡牌提示
            _tagMsg.pBuffer.wBankerUser = luaFunc:readRecvByte()        --庄家
            _tagMsg.pBuffer.wProvideUser = luaFunc:readRecvWORD()       --点炮用户
            _tagMsg.pBuffer.wWinner = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.wWinner[i] = luaFunc:readRecvBool()     --赢家
            end

            _tagMsg.pBuffer.bZhaNiao = {}
            for i = 1 , 6 do
                if i == 6 then
                    _tagMsg.pBuffer.bZhaNiao[i] = luaFunc:readRecvByte()   --炸鸟麻将
                else
                    _tagMsg.pBuffer.bZhaNiao[i] = luaFunc:readRecvByte()
                end
            end

            _tagMsg.pBuffer.lGameScore = {}
            for i = 1,4 do
                _tagMsg.pBuffer.lGameScore[i] = luaFunc:readRecvLong() --游戏积分
            end
            _tagMsg.pBuffer.cbCardCount = {}
            for i = 1,4 do
                _tagMsg.pBuffer.cbCardCount[i] = luaFunc:readRecvByte() --麻将数目
            end

            _tagMsg.pBuffer.cbCardData = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.cbCardData[i] = {}
                for j = 1 , 45 do
                    _tagMsg.pBuffer.cbCardData[i][j] = luaFunc:readRecvByte()   --麻将数据
                end
            end
        elseif subCmdID == NetMsgId.SUB_S_SITFAILED then
            _tagMsg.pBuffer.wErrorCode = luaFunc:readRecvWORD() --错误代码
            _tagMsg.pBuffer.lScore = luaFunc:readRecvLong()     --积分

        elseif subCmdID == NetMsgId.SUB_GF_USER_EXPRESSION then
            _tagMsg.pBuffer.wIndex = luaFunc:readRecvWORD()     --索引
            _tagMsg.pBuffer.wChairID = luaFunc:readRecvWORD()   --椅子号
            local viewID = GameCommon:SwitchViewChairID(_tagMsg.pBuffer.wChairID)
            self:showUserExpression(viewID,_tagMsg.pBuffer.wIndex)
            return
        elseif subCmdID == NetMsgId.SUB_GF_USER_EFFECTS then
            local wIndex = luaFunc:readRecvWORD()     --索引
            local wChairID = luaFunc:readRecvWORD()   --椅子号
            local wTargetD = luaFunc:readRecvWORD()   --目标
            self.tableLayer:playSkelStartToEndPos(wChairID,wTargetD,wIndex)    
        elseif subCmdID == NetMsgId.SUB_S_ADD_BASE then    --用户加倍

        elseif subCmdID == NetMsgId.SUB_S_ADD_BASE_VIEW then    --用户加倍表现
            _tagMsg.pBuffer.wActionUser = luaFunc:readRecvWORD()    --动作用户
            _tagMsg.pBuffer.IsAdd = luaFunc:readRecvBool()    --加倍

        elseif subCmdID == NetMsgId.SUB_GF_USER_VOICE then
            print("语音")
            _tagMsg.pBuffer.wChairID = luaFunc:readRecvWORD()               --座位号
            _tagMsg.pBuffer.wPackCount = luaFunc:readRecvWORD()             --包总数
            _tagMsg.pBuffer.wPackIndex = luaFunc:readRecvWORD()            --当前包索引
            _tagMsg.pBuffer.dwTime = luaFunc:readRecvDWORD()                --播放时长
            _tagMsg.pBuffer.dwFileSize = luaFunc:readRecvDWORD()            --文件总长度
            _tagMsg.pBuffer.dwPeriodSize = luaFunc:readRecvDWORD()          --文件一段长度
            _tagMsg.pBuffer.szFileName = luaFunc:readRecvString(32)         --文件名字
            _tagMsg.pBuffer.szPeriodData = luaFunc:readRecvBuffer(_tagMsg.pBuffer.dwPeriodSize) --文件数据
            self:OnUserChatVoice(_tagMsg.pBuffer)
            return 
        elseif subCmdID == NetMsgId.SUB_S_GAME_SELECT_CF then
            _tagMsg.pBuffer.bBCF = luaFunc:readRecvBool()    --是否冲分
            print("是否冲：", _tagMsg.pBuffer.bBCF)
            if self.waitArmature ~= nil then 
                self.waitArmature:setVisible(false) 
            end 
        elseif subCmdID == NetMsgId.SUB_S_GAME_SELECT_CFDATA then
            _tagMsg.pBuffer.cbCFData = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.cbCFData[i] = luaFunc:readRecvByte() --冲多少分
                print("是否冲冲多少分：",i, _tagMsg.pBuffer.cbCFData[i])
                GameCommon.cbCFData[i] = _tagMsg.pBuffer.cbCFData[i]
            end   
            self:updatePlayerInfo()  
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        elseif subCmdID == NetMsgId.SUB_S_GAME_GUCHOU then 
            _tagMsg.pBuffer.m_GuChou = luaFunc:readRecvByte()                               --箍臭
            _tagMsg.pBuffer.wGuChouUser = luaFunc:readRecvWORD()
            print("箍臭:",_tagMsg.pBuffer.m_GuChou,_tagMsg.pBuffer.wGuChouUser)  
            local uiPanel_guchou =nil
            if GameCommon.serverData.cbRoomFriend ~= -1 then
               uiPanel_guchou = ccui.Helper:seekWidgetByName(self.root,"Panel_guchou") 
            end
            if _tagMsg.pBuffer.m_GuChou == 1 then 
                if GameCommon.serverData.cbRoomFriend ~= -1 then
                    uiPanel_guchou:setVisible(false)
                end
                GameCommon.m_guchou = _tagMsg.pBuffer.wGuChouUser
                if GameCommon.m_guchou == GameCommon.wBankerUser then
                    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_NULL,0)
                end
                print("等待游戏：",_tagMsg.pBuffer.wGuChouUser,GameCommon:GetMeChairID()) 
                self:updatePlayerInfo()
            else 
                if GameCommon:GetMeChairID() == _tagMsg.pBuffer.wGuChouUser then
                    if GameCommon.serverData.cbRoomFriend ~= -1 then
                        uiPanel_guchou:setVisible(false) 
                    end
                end 
            end             
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)              
			return
        else
            print("not found this subCmdID : %d",subCmdID)
            return 
        end

    elseif mainCmdID == NetMsgId.MDM_GF_FRAME then
      if subCmdID == NetMsgId.SUB_GF_CONFIG then
            local wGameHorse = {}
            wGameHorse.numpep=luaFunc:readRecvByte()--    -- 代表4人玩 （ 写死）
            wGameHorse.mailiao=luaFunc:readRecvWORD()--    --买鸟数
            wGameHorse.fanbei=luaFunc:readRecvByte() --    --1、2、4 翻倍底分、
            wGameHorse.jiabei=luaFunc:readRecvByte() --    --庄家输赢做加减一倍底分、0无、1有
            wGameHorse.zimo=luaFunc:readRecvByte()   --    --只准自摸胡牌  1.有  0.无            
            wGameHorse.piaohua=luaFunc:readRecvByte()--    --1.有飘花、0.无飘花
            wGameHorse.bPlayerCount  = wGameHorse.numpep  
            GameCommon.number_dwHorse = wGameHorse                  
            local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
 --           uiText_desc:setString(self:getGameDesc()) 
            uiText_desc:setString(GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo))         
            return
       elseif subCmdID == NetMsgId.SUB_GF_SCENE then
            --游戏信息
            _tagMsg.pBuffer.lCellScore = luaFunc:readRecvLong()                    --单元积分
            _tagMsg.pBuffer.wSiceCount = luaFunc:readRecvWORD()                    --骰子点数
            _tagMsg.pBuffer.wBankerUser = luaFunc:readRecvWORD()                   --庄家用户
            _tagMsg.pBuffer.wCurrentUser = luaFunc:readRecvWORD()                  --当前用户

            --状态变量
            _tagMsg.pBuffer.cbActionCard = luaFunc:readRecvByte()                 --动作麻将
            _tagMsg.pBuffer.cbActionMask = luaFunc:readRecvByte()
            _tagMsg.pBuffer.cbLeftCardCount = luaFunc:readRecvByte()               --剩余数目

            --出牌信息
            _tagMsg.pBuffer.wOutCardUser = luaFunc:readRecvWORD()                     --出牌用户
            _tagMsg.pBuffer.cbOutCardData = luaFunc:readRecvByte()                  --出牌麻将
            _tagMsg.pBuffer.cbDiscardCount = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.cbDiscardCount[i] = luaFunc:readRecvByte()          --丢弃数目
            end

            _tagMsg.pBuffer.cbDiscardCard = {}
            for i = 1,4 do
                _tagMsg.pBuffer.cbDiscardCard[i] = {}
                for j = 1 , 55 do
                    _tagMsg.pBuffer.cbDiscardCard[i][j] = luaFunc:readRecvByte()        --丢弃记录
                end
            end


            --麻将数据
            _tagMsg.pBuffer.cbCardCount = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.cbCardCount[i] = luaFunc:readRecvByte()          --麻将数目
            end

            _tagMsg.pBuffer.cbCardData = {}
            for i = 1 , 45 do
                _tagMsg.pBuffer.cbCardData[i] = luaFunc:readRecvByte()          --麻将列表
                print("老牌数据：",i,_tagMsg.pBuffer.cbCardData[i])
            end

            --组合麻将
            _tagMsg.pBuffer.cbWeaveCount = {}
            for i = 1 , 4 do
                if i == 4 then
                    _tagMsg.pBuffer.cbWeaveCount[i] = luaFunc:readRecvByte()
                else
                    _tagMsg.pBuffer.cbWeaveCount[i] = luaFunc:readRecvByte()          --组合数目
                end
            end

            _tagMsg.pBuffer.WeaveItemArray = {}                                     --组合麻将
            for i = 1,4 do
                if _tagMsg.pBuffer.WeaveItemArray[i] == nil then
                    _tagMsg.pBuffer.WeaveItemArray[i] = {}
                end
                for j = 1 , 5 do
                    if _tagMsg.pBuffer.WeaveItemArray[i][j] == nil then
                        _tagMsg.pBuffer.WeaveItemArray[i][j] = {}
                    end
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbWeaveKind = luaFunc:readRecvWORD()   --组合类型
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbCenterCard = luaFunc:readRecvByte()  --中心麻将
                    _tagMsg.pBuffer.WeaveItemArray[i][j].cbPublicCard = luaFunc:readRecvByte()  --公开标志
                    _tagMsg.pBuffer.WeaveItemArray[i][j].wProvideUser = luaFunc:readRecvWORD()  --供应用户
                    print("组合麻将:",i,j,_tagMsg.pBuffer.WeaveItemArray[i][j].cbWeaveKind,_tagMsg.pBuffer.WeaveItemArray[i][j].cbCenterCard,_tagMsg.pBuffer.WeaveItemArray[i][j].cbPublicCard,_tagMsg.pBuffer.WeaveItemArray[i][j].wProvideUser)
                end
            end

            --状态记录
            _tagMsg.pBuffer.cbReceiveClientKind = luaFunc:readRecvByte()            --等待状态
            _tagMsg.pBuffer.cbGangYaoshuai = luaFunc:readRecvBool()                 --是否要甩

            --骰子记录
            _tagMsg.pBuffer.m_wDiceCount = luaFunc:readRecvByte()

            _tagMsg.pBuffer.stDiceRecord = {}
            for i = 1 , 20 do
                _tagMsg.pBuffer.stDiceRecord[i] = {}
                _tagMsg.pBuffer.stDiceRecord[i].wSiceUser =  luaFunc:readRecvWORD() --骰子用户
                _tagMsg.pBuffer.stDiceRecord[i].wSiceCount =  luaFunc:readRecvWORD()    --骰子点数
                _tagMsg.pBuffer.stDiceRecord[i].wOperateCode =  luaFunc:readRecvWORD()  --动作
            end

            _tagMsg.pBuffer.m_StoreCardAll = {}
            for i = 1 ,120 do
                _tagMsg.pBuffer.m_StoreCardAll[i] = luaFunc:readRecvByte()              --库存麻将表现
            end
            
            _tagMsg.pBuffer.m_wGameHorseCountTmp= {};
            for i = 1 ,4 do
                _tagMsg.pBuffer.m_wGameHorseCountTmp[i] = luaFunc:readRecvByte()              --冲分数量
                print("断线重连积分：",i,_tagMsg.pBuffer.m_wGameHorseCountTmp[i])
            end
            _tagMsg.pBuffer.m_wGameHorseTmp = luaFunc:readRecvByte()                    --需不需要冲分
            _tagMsg.pBuffer.m_bGuChouEx= {};
            for i = 1 ,4 do
                _tagMsg.pBuffer.m_bGuChouEx[i] = luaFunc:readRecvByte()              --箍臭.  0.初始化.1.箍臭  2.不箍臭<还没进行箍臭操作的、做了出牌或碰之类的操作后进行默认不箍臭>
                print("箍臭：",i,_tagMsg.pBuffer.m_bGuChouEx[i],GameCommon:GetMeChairID())
            end
            local wGameHorse = {}
            wGameHorse.mailiao= _tagMsg.pBuffer.m_wGameHorseTmp--    --买鸟数
            wGameHorse.fanbei=luaFunc:readRecvByte() --    --1、2、4 翻倍底分、
            wGameHorse.jiabei=luaFunc:readRecvByte() --    --庄家输赢做加减一倍底分、0无、1有
            wGameHorse.zimo=luaFunc:readRecvByte()   --    --只准自摸胡牌  1.有  0.无            
            wGameHorse.piaohua=luaFunc:readRecvByte()--    --1.有飘花、0.无飘花
            GameCommon.number_dwHorse = wGameHorse 
            local uiText_desc = ccui.Helper:seekWidgetByName(self.root,"Text_desc")
            uiText_desc:setString(GameDesc:getGameDesc(GameCommon.serverData.wKindID,GameCommon.number_dwHorse,GameCommon.friendsRoomInfo))           
--    BYTE                            m_bGameScoreEx;
--    BYTE                            m_bGameZhuangScoreEx;
--    BYTE                            m_bGameZiMoEx;
--    BYTE                            m_bGamePiaoHuaEx;
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_SCORE then
            _tagMsg.pBuffer.lUserScore = {}
            for i = 1 , 4 do
                _tagMsg.pBuffer.lUserScore[i] = luaFunc:readRecvLong()
            end

        elseif subCmdID == NetMsgId.SUB_GF_CONFIG then
            local wGameHorse = {}
            wGameHorse.mailaio=luaFunc:readRecvWORD()--    --买鸟数
            wGameHorse.fanbei=luaFunc:readRecvByte() --    --1、2、4 翻倍底分、
            wGameHorse.jiabei=luaFunc:readRecvByte() --    --庄家输赢做加减一倍底分、0无、1有
            wGameHorse.zimo=luaFunc:readRecvByte()   --    --只准自摸胡牌  1.有  0.无            
            wGameHorse.piaohua=luaFunc:readRecvByte()--    --1.有飘花、0.无飘花
            GameCommon.number_dwHorse = wGameHorse
            local roomID = tostring(GameCommon.tableConfig.wTbaleID)
            local uiText_zhaNiaoCount = ccui.Helper:seekWidgetByName(self.root,"Text_title")
            uiText_zhaNiaoCount:setString(string.format("溆浦老牌 房间号 %s 局数 %d/%d",roomID,GameCommon.friendsRoomInfo.wCurrentNumber,GameCommon.friendsRoomInfo.wTableNumber,2))
            return 
        else
            print("not found this subCmdID : %d",subCmdID)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            return 
        end
    else
        print("not found this mainCmdID : %d",mainCmdID)
        return 
    end
    
    if self.userMsgArray == nil then 
        return 
    end

    table.insert(self.userMsgArray,#self.userMsgArray + 1,_tagMsg)
    print("当前消息数量:%d",#self.userMsgArray)
    printInfo(_tagMsg)
    return  
end

--消息队列
function GameLayer:update(delta)
    if self.isRunningActions then
        return
    end
    if #self.userMsgArray <=0 then
        return
    end
    self.isRunningActions = true
    local _tagMsg = self.userMsgArray[1]

    --操作初始化
    self.oprationLayer:initButtonStatus()
    local time = os.time()
    print("执行一条语句：",_tagMsg.mainCmdID,_tagMsg.subCmdID,#self.userMsgArray)
    self:OnGameMessageRun(_tagMsg)
    local dt = os.time() - time
    if dt > 0 then
        if self.maxTime == nil then
            self.maxTime = 0
        end
        if dt > self.maxTime then
            self.maxTime = dt
            print(string.format("诞生一条延迟最高(%d)的消息：mainCmdID = %d ,subCmdID = %d",dt,_tagMsg.mainCmdID,_tagMsg.subCmdID))
        else
            print("执行一条语句耗时：",dt,_tagMsg.mainCmdID,_tagMsg.subCmdID)
        end
    end

    --删除动作
    table.remove(self.userMsgArray,1)
end

--消息执行
function GameLayer:OnGameMessageRun(_tagMsg)
    local mainCmdID = _tagMsg.mainCmdID
    local subCmdID = _tagMsg.subCmdID
    local pBuffer = _tagMsg.pBuffer


    if mainCmdID == NetMsgId.MDM_GR_USER then
        if subCmdID == NetMsgId.SUB_GR_USER_STATISTICS then
            local uiPanel_end = ccui.Helper:seekWidgetByName(self.root,"Panel_end")
            print("大结算")
            uiPanel_end:setVisible(true)
            local isFriendPHZ_MJ_PDK = 2
            local layer = require("common.FriendsRoomEndLayer"):create(pBuffer)
            uiPanel_end:addChild(layer)
        else
            print("not found this subCmdID : %d",subCmdID)
            return
        end

    elseif mainCmdID == NetMsgId.MDM_GR_LOGON then
        if subCmdID == NetMsgId.SUB_GR_LOGON_ERROR then
            require("common.MsgBoxLayer"):create(2,nil , "您的金币不符" , function(sender,event)
                require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL)
            end)

        elseif subCmdID == NetMsgId.SUB_GR_LOGON_FINISH then

        else
            print("not found this subCmdID : %d",subCmdID)
            return
        end

    elseif mainCmdID == NetMsgId.MDM_GF_GAME then
          if subCmdID == NetMsgId.SUB_S_GAME_SelectZhuang then

            --重置准备状态
            self.friendReady = {[1]= false,[2] =false ,[3] = false,[4] = false}
--            if GameCommon.isFriendsGame == true then
--                local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
--                uiButton_ready:setVisible(false)
--            end
            GameCommon.isFriendGameStart = true
            GameCommon.wBankerUser = pBuffer.wBankerUser
            self:startWaitArmature(false)

            self:updatePlayerInfo()

            --开始特效
            local size=cc.Director:getInstance():getWinSize()

            local Armature=nil

            print("运行游戏") 
            self:begainStartPrepare() 
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            GameCommon:paySoundeffect(GameCommon.Soundeffect_xiPaiAnimation)
            --            self.actionLayer:onActionDelay()
        elseif subCmdID == NetMsgId.SUB_S_GAME_START_MAJIANG then
            local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
            uiPanel_ready:setVisible(false)
            if GameCommon.serverData.cbRoomFriend == -1 then               
                pBuffer.cbCardData[17] = GameCommon.m_crad_17 
                print("最后一张牌：",GameCommon.m_crad_17)
            elseif GameCommon.serverData.cbRoomFriend == 1 then 
                local uiPanel_guchou = ccui.Helper:seekWidgetByName(self.root,"Panel_guchou")      
                uiPanel_guchou:setVisible(true) 
            end
            self:startWaitArmature(false)
            self.actionLayer:initAction()
            self.actionLayer:showTimeTipszhuang(GameCommon:SwitchViewChairID(pBuffer.wBankerUser))           --光标指向庄家
            self.oprationLayer:initButtonStatus()
            --数据设置
            --GameCommon.wBankerUser = GameCommon:SwitchViewChairID(pBuffer.wBankerUser)
            GameCommon.wBankerUser = pBuffer.wBankerUser
           -- self.tableLayer:showCountDown(GameCommon.wBankerUser)
            local cardNum = 0
            if GameCommon:GetMeChairID() == pBuffer.wBankerUser then
                cardNum = 17
            else
                cardNum = 16
            end

            for x = 1 , 4 do
                GameCommon.m_cbWeaveCount[x] = 0
            end

            for x = 1 , 2 do
                GameCommon.m_wDiceCard[x] = 0
            end
 
            GameCommon.m_cbCardIndex = GameLogic:SwitchToCardIndexTwo(pBuffer.cbCardData,cardNum)
            
            GameCommon.m_cout_c,GameCommon.m_data_c = GameLogic:SwitchToCardDataTwo_luan(GameCommon.m_cbCardIndex)
            GameCommon.m_wSiceCount = pBuffer.wSiceCount
            --            self.actionLayer:onActionDelay()

            local dice = {}
            dice[1] = GameCommon.m_wSiceCount
            for x = 2 , 20 do
                dice[x] = 0
            end
                
            for i=1 , 4 do 
                for j = 1, 17 do
                    print("玩家手牌变化前:",i-1,j,GameCommon.listdatacard[i-1][j]) 
                end 
            end       
--            GameCommon.m_cbLeftCardCount = 120
            --GameCommon.meChairID
            --self.actionLayer:initStoreCard(dice, GameCommon.m_cbLeftCardCount)    -- 牌蹲发牌全套
            
           
            if pBuffer.wChairID == GameCommon.meChairID then  
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wChairID)   
            print("输出自己：",GameCommon.meChairID,pBuffer.wChairID,wChairID)          
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function(sender,event) self:timeToSendCard() end),
                nil))
--                
--                GameCommon.listdatacard[pBuffer.wChairID] = pBuffer.cbCardData                     
            end 
           for i=1 , 4 do 
                for j = 1, 17 do
                    print("玩家手牌变化后:",i-1,j,GameCommon.listdatacard[i-1][j]) 
                end 
            end 
            --            GameCommon.m_SiceType = SiceType_gameStart
--            self.actionLayer:showCastDiceView(GameCommon.m_wSiceCount)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        elseif subCmdID == NetMsgId.SUB_S_SpecialCard then
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wActionUser)

            if wChairID == 1 then
                self.oprationLayer:showXihuiSelect(pBuffer.cbUserAction)
            end
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            self.isRunningActions=false
        elseif subCmdID == NetMsgId.SUB_S_SpecialCard_RESULT then
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wActionUser)
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
            GameCommon:upDataGold(pBuffer.lGameScore[GameCommon:GetMeChairID()+1],0)

            self.actionLayer:showSpecialCard(pBuffer.cbCardData,GameCommon:SwitchViewChairID(pBuffer.wActionUser),pBuffer.cbUserAction)

            GameCommon.m_SpeciallGameScore = clone(pBuffer.lGameScore)

            self.actionLayer:showSpecialCastDice(pBuffer.wSiceCount)
            
--            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpdataUserScore)
        elseif subCmdID == NetMsgId.SUB_S_OUT_CARD_NOTIFY_MAJIANG then             --用户提示出牌
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wOutCardUser)
            self.actionLayer:onUserOutCardNotify(wChairID)

            self:showTimeTips(wChairID)

            if self.outOprationState and wChairID == 1 then
                self:OnUserAutoOutCard()
            end
        elseif subCmdID == NetMsgId.SUB_S_OUT_CARD_RESULT then             --用户出牌
            self.actionLayer:showTimeOver()
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wOutCardUser)
            self:showTimeTips(wChairID)
            if wChairID == 1 then
                self.cardLayer:removeHandCard(pBuffer.cbOutCardData)

--                local cbValue = Bit:_and(pBuffer.cbOutCardData,0x0F)
--                local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOutCardData,0xF0),4)
--                GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1
            end
            local cbValue = Bit:_and(pBuffer.cbOutCardData,0x0F)
            local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOutCardData,0xF0),4)
            GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1            
            self:WithTheNewDiscard()
            self.actionLayer:showUserOutCard(GameCommon:SwitchViewChairID(pBuffer.wOutCardUser),pBuffer.cbOutCardData,pBuffer.wOutCardUser)
        elseif subCmdID == NetMsgId.SUB_S_SEND_CARD_MAJIANG then                   --发牌消息
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wCurrentUser)
            --剩余麻将
            self.actionLayer:removeStoreCard(pBuffer.wSiceCount,pBuffer.wOperateCode)
            GameCommon.m_cbLeftCardCount = GameCommon.m_cbLeftCardCount - 1
            self.actionLayer:showLeftCardView(GameCommon.m_cbLeftCardCount)
            
            
            --发牌表现
            if pBuffer.wOperateCode == GameCommon.WIK_HAIDI then
                self.actionLayer:showUserSpecialSendCard(GameCommon:SwitchViewChairID(pBuffer.wCurrentUser),pBuffer.cbCardData)
            else
                self.actionLayer:showUserSendCard(GameCommon:SwitchViewChairID(pBuffer.wCurrentUser),pBuffer.cbCardData,pBuffer.wSiceCount,pBuffer.wOperateCode)
            end

            if wChairID == 1 and pBuffer.wOperateCode ~= GameCommon.WIK_HAIDI then
                self.cardLayer:addHandCard(pBuffer.cbCardData)
                self:showShortCardTips(true)
            end
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_NOTIFY_MAJIANG then              --操作提示
            --if GameCommon:SwitchViewChairID(pBuffer.wResumeUser) ==  1 then
            self.cardLayer:updataHandCard()
            --end
            local data = {}

            for x = 1 , 2 do
                data[x] = 0
            end

            if pBuffer.cbActionCard == GameCommon.INVALID_BYTE then
                data[1] = GameCommon.m_wDiceCard[1]
                data[2] = GameCommon.m_wDiceCard[2]
            else
                data[1] = pBuffer.cbActionCard
            end

            --托管
            if self.outOprationState == true then
                --self:OnUserAutoOperateCard(pBuffer.cbActionMask,data[1])
                self.oprationLayer:Tuoguan_Status(pBuffer.cbActionMask,data,GameCommon.m_cbCardIndex,pBuffer.bIsSelf)
            else
                self.oprationLayer:setButtonStatus(pBuffer.cbActionMask,data,GameCommon.m_cbCardIndex,pBuffer.bIsSelf)
            end
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wResumeUser)
            --时钟提示
            self:showTimeTips(wChairID)
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            self.isRunningActions=false
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_RESULT then              --操作结果
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wOperateUser)

            --杠牌处理
            local wIndex = 0
            local ispengGang = false

            if pBuffer.cbOperateCode == GameCommon.WIK_FILL or pBuffer.cbOperateCode == GameCommon.WIK_GANG then
                --寻找组合
                for i = 1 , GameCommon.m_cbWeaveCount[wChairID+1] do
                    local cbWeaveKind = GameCommon.m_WeaveItemArray[wChairID+1][i].cbWeaveKind
                    local cbCenterCard = GameCommon.m_WeaveItemArray[wChairID+1][i].cbCenterCard
                    if cbCenterCard == pBuffer.cbOperateCard and cbWeaveKind == GameCommon.WIK_PENG then
                        wIndex = i
                        ispengGang = true
                        break
                    end
                end
            end

            --数据修改
            if GameCommon.m_cbWeaveCount[wChairID+1] == nil then
                GameCommon.m_cbWeaveCount[wChairID+1] = 0
            end
            if ispengGang == false then
                GameCommon.m_cbWeaveCount[wChairID+1] = GameCommon.m_cbWeaveCount[wChairID+1]+1
                wIndex = GameCommon.m_cbWeaveCount[wChairID+1]
            end
            if GameCommon.m_WeaveItemArray[wChairID+1] == nil then
                GameCommon.m_WeaveItemArray[wChairID+1] = {}
            end

            if GameCommon.m_WeaveItemArray[wChairID+1][wIndex] == nil then
                GameCommon.m_WeaveItemArray[wChairID+1][wIndex] = {}
            end
            
          
            
            GameCommon.m_WeaveItemArray[wChairID+1][wIndex].cbPublicCard = true
            GameCommon.m_WeaveItemArray[wChairID+1][wIndex].cbCenterCard = pBuffer.cbOperateCard
            GameCommon.m_WeaveItemArray[wChairID+1][wIndex].cbWeaveKind = pBuffer.cbOperateCode
            GameCommon.m_WeaveItemArray[wChairID+1][wIndex].wProvideUser = GameCommon.INVALID_CHAIR

            --用户操作结果表现
            self.actionLayer:showUserOperateView(wChairID,pBuffer.cbOperateCode,pBuffer.cbOperateCard,pBuffer.cbUserCardCout)

            --动作显示
            --self.actionLayer:showAction(wChairID,pBuffer.cbOperateCode)
                       
            if pBuffer.cbOperateCode == GameCommon.WIK_PENG then
                local cbValue = Bit:_and(pBuffer.cbOperateCard,0x0F)
                local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOperateCard,0xF0),4)
                GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 2
            end
            if pBuffer.cbOperateCode == GameCommon.WIK_LEFT then
                local cbValue = Bit:_and(pBuffer.cbOperateCard,0x0F)
                local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOperateCard,0xF0),4)
                GameCommon.m_CardNumber[cbColor][cbValue+1] = GameCommon.m_CardNumber[cbColor][cbValue+1] + 1
                GameCommon.m_CardNumber[cbColor][cbValue+2] = GameCommon.m_CardNumber[cbColor][cbValue+2] + 1
            end
            if pBuffer.cbOperateCode == GameCommon.WIK_CENTER then
                local cbValue = Bit:_and(pBuffer.cbOperateCard,0x0F)
                local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOperateCard,0xF0),4)
                GameCommon.m_CardNumber[cbColor][cbValue+1] = GameCommon.m_CardNumber[cbColor][cbValue+1] + 1
                GameCommon.m_CardNumber[cbColor][cbValue-1] = GameCommon.m_CardNumber[cbColor][cbValue-1] + 1
            end
            if pBuffer.cbOperateCode == GameCommon.WIK_RIGHT then
                local cbValue = Bit:_and(pBuffer.cbOperateCard,0x0F)
                local cbColor = Bit:_rshift(Bit:_and(pBuffer.cbOperateCard,0xF0),4)
                GameCommon.m_CardNumber[cbColor][cbValue-2] = GameCommon.m_CardNumber[cbColor][cbValue-2] + 1
                GameCommon.m_CardNumber[cbColor][cbValue-1] = GameCommon.m_CardNumber[cbColor][cbValue-1] + 1
            end
            self:WithTheNewDiscard()

            --移除手牌
            if wChairID == 1 then
                if pBuffer.cbOperateCode == GameCommon.WIK_PENG then
                    self.cardLayer:removeHandCard(pBuffer.cbOperateCard)
                    self.cardLayer:removeHandCard(pBuffer.cbOperateCard)
                end
                if pBuffer.cbOperateCode == GameCommon.WIK_LEFT then
                    local cbRemoveCard = {[1] = pBuffer.cbOperateCard+1,[2] = pBuffer.cbOperateCard+2}
                    self.cardLayer:removeHandCard(cbRemoveCard[1])
                    self.cardLayer:removeHandCard(cbRemoveCard[2])
                end
                if pBuffer.cbOperateCode == GameCommon.WIK_CENTER then
                    local cbRemoveCard = {[1] = pBuffer.cbOperateCard+1,[2] = pBuffer.cbOperateCard-1}
                    self.cardLayer:removeHandCard(cbRemoveCard[1])
                    self.cardLayer:removeHandCard(cbRemoveCard[2])
                end
                if pBuffer.cbOperateCode == GameCommon.WIK_RIGHT then
                    local cbRemoveCard = {[1] = pBuffer.cbOperateCard-2,[2] = pBuffer.cbOperateCard-1}
                    self.cardLayer:removeHandCard(cbRemoveCard[1])
                    self.cardLayer:removeHandCard(cbRemoveCard[2])
                end
                if pBuffer.cbOperateCode == GameCommon.WIK_FILL or pBuffer.cbOperateCode == GameCommon.WIK_GANG then
                    for i = 1 , 4 do
                        self.cardLayer:removeHandCard(pBuffer.cbOperateCard)
                    end

                end
            end
        elseif subCmdID == NetMsgId.SUB_S_CASTDICE_NOTIFY then             --要帅提示
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wCurrentUser)
            if wChairID == 1 then
               self.oprationLayer:showYaoShuaSelect(pBuffer.bIsTingPai)
--                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_CASTDICE,"o",true)
--                EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
--                self.oprationLayer:initButtonStatus()
            else

            end

            self:showTimeTips(wChairID)

            if self.outOprationState == true then
                self:OnUserAutoCastdice()
            end
        elseif subCmdID == NetMsgId.SUB_S_CASTDICE_RESULT then             --要帅结果
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wCurrentUser)

            local cbSiceFirst = Bit:_and(Bit:_rshift(pBuffer.wDiceCount,8),0xff)
            local cbSiceSecond = Bit:_and(pBuffer.wDiceCount,0xff)
            GameCommon.m_wDiceCard[1] = pBuffer.wDiceCardOne
            GameCommon.m_wDiceCard[2] = pBuffer.wDiceCardTwo

            GameCommon.m_SiceType = GameCommon.SiceType_gangCard
            GameCommon.m_wDiceUser = wChairID
            GameCommon.m_wDiceCount = pBuffer.wDiceCount
            self.actionLayer:showCastDiceView(pBuffer.wDiceCount)
       
            --移除桌面牌
            local removeCout = 0
            if pBuffer.wDiceCardOne ~= 0 then
                removeCout = removeCout+1
            end

            if pBuffer.wDiceCardTwo ~= 0 then
                removeCout = removeCout + 1
            end

            GameCommon.m_cbLeftCardCount = GameCommon.m_cbLeftCardCount - removeCout

            self.actionLayer:showLeftCardView(GameCommon.m_cbLeftCardCount)

            if wChairID == 1 then
                self:showUserGangCardTips()
            else

            end   
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        elseif subCmdID == NetMsgId.SUB_S_GAME_END_MAJIANG then                    --游戏结束        
               --     pBuffer.cbCardData[i] = {}
               --     for j = 1 , 45 do
               --     pBuffer.cbCardData[i][j]
            local uiPanel_card = ccui.Helper:seekWidgetByName(self.root,"Panel_card")        
            for i = 1 ,4 do  
                for j = 1 , 45 do
                    if pBuffer.cbCardData[i][j] ~= 0 then 
                       
                        local spt = GameCommon:GetPartCardHand(pBuffer.cbCardData[i][j])
                        spt:setScale(0.47)
                        uiPanel_card:addChild(spt)
                        local pt = cc.p(0,0) 
                        local minus =  1
                        local height = 0
                        local wide = 0
                        local ChairID=GameCommon:SwitchViewChairID(i)                
                        if ChairID == 0 then 
                            pt = cc.p(576,382)
                            minus =  -1
                        elseif ChairID == 1 then 
                            pt = cc.p(704,382)                           
                        elseif ChairID == 2 then
                            pt = cc.p(704,622)                                                      
                        elseif ChairID == 3 then 
                            pt = cc.p(576,622) 
                            minus =  -1
                        end
                        wide = math.floor((j-1)/3)
                        height =(j-1)%3
                        if j <= 0 then
                            height = 0 
                        end

--                        if j > 24 then
--                            height = 2 
--                        elseif j > 12 then
--                            height = 1 
--                        end                          
                        spt:setPosition(cc.p(pt.x+(wide)*95*0.47*minus,pt.y-height*150*0.47)) --
                    end                   
                end 
            end     
            GameCommon.m_guchou = nil   --箍丑玩家清空
        for i = 1 ,4 do 
           GameCommon.cbCFData[i] = 0
        end 
        if GameCommon.isHuangZhuang == true then
            self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(function(sender,event)
                if GameCommon.serverData.cbRoomFriend == 1 then
                    if GameCommon.friendsRoomInfo.wTableNumber == GameCommon.friendsRoomInfo.wCurrentNumber then
                        --是最后一局
                        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
                    else
                        --不是最后一局
                        GameCommon:ContinueGame()
                    end
                elseif GameCommon.serverData.cbRoomFriend == 0 then                 
                    GameCommon:ContinueGame()
                else
                    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
                end
            end)))
        else
            self:runAction(cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.CallFunc:create(function(sender,event)
                    local uiPanel_end = ccui.Helper:seekWidgetByName(self.root,"Panel_end")
                    if GameCommon.tableConfig.nTableType == TableType_SportsRoom then
                        pBuffer.wKindID =GameCommon.tableConfig.wKindID
                        uiPanel_end:addChild(require("common.SportsGameEndLayer"):create(pBuffer))  
                    else                    
                    uiPanel_end:addChild(require("game.laopai.42.GameEndLayer"):create(pBuffer))
                    end
                end),cc.DelayTime:create(20),
                cc.CallFunc:create(function(sender,event)
                    if GameCommon.serverData.cbRoomFriend == 1 then
                        if GameCommon.friendsRoomInfo.wTableNumber == GameCommon.friendsRoomInfo.wCurrentNumber then
                            --是最后一局
                            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
                                
                        else
                            --不是最后一局
                            for i = 1 ,4 do 
                                if pBuffer.wWinner[i]  == true then 
                                    GameCommon.wBankerUser = i - 1
                                end
                            end                           
                            GameCommon:ContinueGame()
                        end

                    else
                        
                        require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL)
                    end
                end)))

            if GameCommon.isFriendsGame == false then
                GameCommon:upDataGold(pBuffer.lGameScore[GameCommon:GetMeChairID()+1] - pBuffer.lGameTax,0)
            end
        end

        elseif subCmdID == NetMsgId.SUB_S_OPERATE_HAIDI then
            local wChairID = GameCommon:SwitchViewChairID(pBuffer.wCurrentUser)
            if wChairID == 1 then
                if self.outOprationState == true then
                    self.oprationLayer:dealHaidiNoResult()
                else
                    self.oprationLayer:showHaiDiSelect(pBuffer.bTingPai)
                end
            end

            self.actionLayer:showHaiDiView(wChairID)

            self:showTimeTips(wChairID)                  
            --            if self.outOprationState == true then
            --                self:OnUserAutoHaiDi()
            --            end
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            self.isRunningActions=false 
            --测试去除致骰子  
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_OutOpration)
        elseif subCmdID == NetMsgId.SUB_S_GAME_END_TIPS_HUTYPE then

        elseif subCmdID == NetMsgId.SUB_S_GAME_END_TIPS_MAJIANG then       --游戏胡牌提示
            if pBuffer.wProvideUser == GameCommon.INVALID_CHAIR then
                GameCommon.isHuangZhuang = true
                self.actionLayer:initAction()
        else
            GameCommon.isHuangZhuang = false
        end
        self:overOutOpration()

        self.actionLayer:initTimeTips()
        self.actionLayer:showHuGame(pBuffer)

        if pBuffer.wProvideUser == GameCommon.INVALID_CHAIR then
        else
            local pt_Cu = {}
            pt_Cu.x  = self:getPositionX()
            pt_Cu.y  = self:getPositionY()

            self:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.04,cc.p(pt_Cu.x+math.random(-10,0),pt_Cu.y)),
                cc.MoveTo:create(0.04,cc.p(pt_Cu.x+math.random(0,10),pt_Cu.y)),
                cc.MoveTo:create(0.04,cc.p(pt_Cu.x,pt_Cu.y+math.random(0,10))),
                cc.MoveTo:create(0.04,cc.p(pt_Cu.x,pt_Cu.y+math.random(-10,0))),
                cc.MoveTo:create(0.02,cc.p(pt_Cu.x,pt_Cu.y)),
                nil))
        end
        elseif subCmdID == NetMsgId.SUB_S_SITFAILED then
            local _LogonError = pBuffer
            if _LogonError.wErrorCode == 1 and GameCommon.isFriendsGame == false then
                UserData.loginSuccess.lScore = _LogonError.lScore
            end
        elseif subCmdID == NetMsgId.SUB_S_GAME_SELECT_CF then
            if  pBuffer.bBCF == true  then 
                local uiImage_atpoints = ccui.Helper:seekWidgetByName(self.root,"Image_atpoints")
                GameCommon.isFriendGameStart = true
                uiImage_atpoints:setVisible(true)
            end 
        elseif subCmdID == NetMsgId.SUB_S_GAME_SELECT_CFDATA then
            for i = 1 ,4 do 
                local wChairID = GameCommon:SwitchViewChairID(i)    
              if  pBuffer.cbCFData[i] == nil then 
              else
              end
            end 
            
            if pBuffer.cbCFData[1] ~= 4 and   pBuffer.cbCFData[2] ~= 4 and pBuffer.cbCFData[3] ~= 4 and  pBuffer.cbCFData[4] ~= 4  then

                EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            end 
            if  GameCommon.serverData.cbRoomFriend == -1   then
             EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            end                             
        else
            print("not found this subCmdID : %d",subCmdID)
            return
        end

    elseif mainCmdID == NetMsgId.MDM_GF_FRAME then
        if subCmdID == NetMsgId.SUB_GF_SCENE then
            local uiPanel_ready = ccui.Helper:seekWidgetByName(self.root,"Panel_ready")
            uiPanel_ready:setVisible(false)
            --重置准备状态
            self.friendReady = {[1]= false,[2] =false ,[3] = false,[4] = false}
            if GameCommon.isFriendsGame == true then
                local uiButton_ready = ccui.Helper:seekWidgetByName(self.root,"Button_ready")
                uiButton_ready:setVisible(false)
            end
            print("执行重置准备状态：",pBuffer.m_wGameHorseTmp)
            GameCommon.isFriendGameStart = true
            --等待动画
            self:startWaitArmature(false)
            
             if pBuffer.m_wGameHorseTmp ~= 0 then 
                for i = 1 , 4 do 
                  
                    local wChairID = GameCommon:SwitchViewChairID(i)   
                    GameCommon.cbCFData[i] = pBuffer.m_wGameHorseCountTmp[i]
                    print("等待动画:",i,wChairID,GameCommon:GetMeChairID(),GameCommon.cbCFData[i ],pBuffer.m_wGameHorseCountTmp[i]) 
                    if GameCommon:GetMeChairID() == i-1   and GameCommon.cbCFData[i] == 4 then 
                        local uiImage_atpoints = ccui.Helper:seekWidgetByName(self.root,"Image_atpoints")
                        uiImage_atpoints:setVisible(true)
                    end 
                end 

             end 
             
            --基础信息设置
            --GameCommon.wBankerUser = GameCommon:SwitchViewChairID(pBuffer.wBankerUser)
            GameCommon.wBankerUser = pBuffer.wBankerUser
            
            --箍丑断线处理
            local uiPanel_guchou = ccui.Helper:seekWidgetByName(self.root,"Panel_guchou") 
            local gucouVisible = true     
            uiPanel_guchou:setVisible(false) 
            for i = 1 ,4 do     --箍臭.  0.初始化.1.箍臭  2.不箍臭<还没进行箍臭操作的、做了出牌或碰之类的操作后进行默认不箍臭>
                print("箍臭888：",i,pBuffer.m_bGuChouEx[i],GameCommon:GetMeChairID())
                if pBuffer.m_bGuChouEx[i] == 1 then
                    GameCommon.m_guchou = i - 1  
                    gucouVisible = false
                    if i - 1 == GameCommon:GetMeChairID() then 
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"wb",GameCommon.WIK_NULL,0)
                        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
                    end
               end 
            end
            for i = 1 ,4 do     --箍臭.  0.初始化.1.箍臭  2.不箍臭<还没进行箍臭操作的、做了出牌或碰之类的操作后进行默认不箍臭>
                print("箍臭888：",i,pBuffer.m_bGuChouEx[i],GameCommon:GetMeChairID(),pBuffer.cbCardCount[i])
                if pBuffer.m_bGuChouEx[i] == 0 and i - 1 == GameCommon:GetMeChairID() and gucouVisible == true and pBuffer.cbCardCount[i]> 0 then               
                    uiPanel_guchou:setVisible(true) 
                end 
            end
                        
            self:updatePlayerInfo()
            local wChairID1 = GameCommon:SwitchViewChairID(pBuffer.wCurrentUser)
            self:showTimeTips(wChairID1)
            --状态变量
            GameCommon.m_cbLeftCardCount = pBuffer.cbLeftCardCount
            local dice = {}

            dice[1] = pBuffer.cbLeftCardCount

            for x = 2 , 20 do
                dice[x] = 0
            end

            self.actionLayer:initStoreCardByStoreCard(dice,pBuffer.m_StoreCardAll)
            self.actionLayer:showLeftCardView(GameCommon.m_cbLeftCardCount)

            --历史记录
            self.actionLayer:setDiscardView(pBuffer.cbDiscardCount,pBuffer.cbDiscardCard)

            for i = 1,4 do        -- 弃牌记录
                for j = 1 , 55 do
                    local cbValue = Bit:_and( pBuffer.cbDiscardCard[i][j],0x0F)
                    local cbColor = Bit:_rshift(Bit:_and( pBuffer.cbDiscardCard[i][j],0xF0),4)
                    print("弃牌记录:",i,j,cbColor,cbValue,GameCommon.m_CardNumber[cbColor][cbValue]) 
                    if GameCommon.m_CardNumber[cbColor][cbValue] ~= nil then 
                        GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1      
                    end                  
                end
            end             
            for i = 1,4 do         --组合麻将
                for j = 1 , 5 do
                    if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_PENG then
                        local cbValue = Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0x0F)
                        local cbColor = Bit:_rshift(Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0xF0),4)
                        GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 3
                    end
                    if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_LEFT then
                        local cbValue = Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0x0F)
                        local cbColor = Bit:_rshift(Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0xF0),4)
                        GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue+1] = GameCommon.m_CardNumber[cbColor][cbValue+1] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue+2] = GameCommon.m_CardNumber[cbColor][cbValue+2] + 1
                    end
                    if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_CENTER then
                        local cbValue = Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0x0F)
                        local cbColor = Bit:_rshift(Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0xF0),4)
                        GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue+1] = GameCommon.m_CardNumber[cbColor][cbValue+1] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue-1] = GameCommon.m_CardNumber[cbColor][cbValue-1] + 1
                    end
                    if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_RIGHT then
                        local cbValue = Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0x0F)
                        local cbColor = Bit:_rshift(Bit:_and(pBuffer.WeaveItemArray[i][j].cbCenterCard,0xF0),4)
                        GameCommon.m_CardNumber[cbColor][cbValue] = GameCommon.m_CardNumber[cbColor][cbValue] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue-2] = GameCommon.m_CardNumber[cbColor][cbValue-2] + 1
                        GameCommon.m_CardNumber[cbColor][cbValue-1] = GameCommon.m_CardNumber[cbColor][cbValue-1] + 1
                    end
                end
            end
            self:WithTheNewDiscard()
            
            for i = 1 , 4 do
                print("cbDiscardCount",pBuffer.cbDiscardCount[i])
            end
                      --cbWeaveCount
            --组合麻将
            for i = 1,4 do
                local ID = GameCommon:SwitchViewChairID(i-1)
                GameCommon.m_WeaveItemArray[ID+1] = clone(pBuffer.WeaveItemArray[i])
                GameCommon.m_cbWeaveCount[ID+1] = pBuffer.cbWeaveCount[i]
            end
            UserData.isStartGame=true
            --麻将数据
            for i = 1, 4 do
                local ID = GameCommon:SwitchViewChairID(i-1)

                local data = {}
                for x = 1 , 45 do  --
                    data[x] = 0
                end

                if ID == 0 then
                    self.actionLayer:showLeftTableCard(data,pBuffer.cbCardCount[i],1)
                elseif ID == 1 then
                    self.actionLayer:showMeTableCard(data,pBuffer.cbCardCount[i],1)
                    self.cardLayer:setHandCard(pBuffer.cbCardData,pBuffer.cbCardCount[i],true)
                elseif ID == 2 then
                    self.actionLayer:showRightTableCard(data,pBuffer.cbCardCount[i],1)
                elseif ID == 3 then
                    self.actionLayer:showFaceTableCard(data,pBuffer.cbCardCount[i],1)
                end
            end

            if pBuffer.cbGangYaoshuai == true then
                self:showUserGangCardTips()
            end

            if pBuffer.cbReceiveClientKind == GameCommon.ReceiveClientKind_OutCard then
                if pBuffer.wCurrentUser == GameCommon:GetMeChairID() then
                    self.actionLayer:onUserOutCardNotify(1)
                elseif cbReceiveClientKind == GameCommon.ReceiveClientKind_OperateSelf then

                end
            end

            self.cardLayer:setTouchEable(true)

            --出到桌面牌
            if pBuffer.wOutCardUser < GameCommon.wPlayerCount  and  pBuffer.cbOutCardData ~= 0  then         --出牌不为零，出牌用户不为空
                if pBuffer.wOutCardUser~= 65535 and pBuffer.wCurrentUser ~= 65535 and pBuffer.wOutCardUser ~= pBuffer.wCurrentUser then     --出牌用户不等于当前用户，不显示
                else
                if  GameCommon.serverData.cbRoomFriend ~= -1 then 
                    print("用户出牌33:",pBuffer.wOutCardUser,pBuffer.cbOutCardData)
                    self.actionLayer:showUserOutCard(GameCommon:SwitchViewChairID(pBuffer.wOutCardUser),pBuffer.cbOutCardData,pBuffer.wOutCardUser)
                end
            end
            end
            local selfIndex  = GameCommon:GetMeChairID()+1
            local cardNum =  pBuffer.cbCardCount[selfIndex]
            GameCommon.m_cbCardIndex = GameLogic:SwitchToCardIndexTwo(pBuffer.cbCardData,cardNum)
            if pBuffer.cbActionMask~= 0 then
                if pBuffer.cbActionCard ~= GameCommon.INVALID_BYTE then
                    local data = {}

                    for x = 1 , 2 do
                        data[x] = 0
                    end
                    data[1] = pBuffer.cbActionCard
                    if (GameCommon:GetMeChairID()== pBuffer.wOutCardUser) then
                        self.oprationLayer:setButtonStatus(pBuffer.cbActionMask,data,GameCommon.m_cbCardIndex,true)
                    else
                        self.oprationLayer:setButtonStatus(pBuffer.cbActionMask,data,GameCommon.m_cbCardIndex,false)
                    end
                end
            end
            --EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
            self.isRunningActions=false
            self:WithTheNewDiscard()
        elseif subCmdID == NetMsgId.SUB_S_OPERATE_SCORE then
            self.tableAddUserScore = pBuffer.lUserScore
            self:updatePlayerInfo()

        else
            print("not found this subCmdID : %d",subCmdID)
            return
        end

    else
        print("not found this mainCmdID : %d",mainCmdID)
        return
    end


end



function GameLayer:OnViewMsg(event)
    local _integer = event._usedata
    print("OnViewMsg",_integer)
    if _integer == GameCommon.GameView_updataHuxi then

    elseif _integer == GameCommon.GameView_showOutCardTips then
        self:showOutCardTips(true)
    elseif _integer == GameCommon.GameView_closeOutCardTips then
        self:showOutCardTips(false)
    elseif _integer == GameCommon.GameView_BegainMsg then
        self.isRunningActions=true
    elseif _integer == GameCommon.GameView_endMsg then
        self.isRunningActions=false
    elseif _integer == GameCommon.GameView_updataHardCard then
        self.cardLayer:updataHandCard()
    elseif _integer == GameCommon.GameView_UpdataUserScore then
        self:updatePlayerInfo()
    elseif _integer == GameCommon.GameView_UpOpration then
        if self.isRunningActions == true then
            EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
        end
        --        self:overOutOpration()
    elseif _integer == GameCommon.GameView_OutOpration then
        if GameCommon.isFriendsGame == false then
            self:onOutOpration()
        end
    else

    end
end

function GameLayer:onHTTPupdataTou(_objData)
    if _objData.View == nil then
        return
    end
    local view =_objData.View
    for i=1 , #self.listview do
        if(self.listview[i]==view  and  cc.FileUtils:getInstance():isFileExist(_objData.self.fileName)) then
            if(view) then
                view:loadTexture(_objData.self.fileName)
            end
            return
        end
    end
end

function GameLayer:onOutOpration()
    self.outOprationIndex = self.outOprationIndex + 1
    if (self.outOprationIndex>=2) then
        self.outOprationIndex =0
        self.outOprationState =true
        self:startOutOpration()
    end
end

function GameLayer:startOutOpration()
    self.outOprationLayOut:setVisible(true)
    self.outOprationState =true
    self.outOprationIndex =0
end

function GameLayer:overOutOpration()
    self.outOprationIndex=0
    self.outOprationState =false
    self.outOprationLayOut:setVisible(false)
end

function GameLayer:OnUserAutoOutCard()
    self.cardLayer:updataHandCard()
    --寻找单牌
    local card = GameLogic:GetBestOutCard(GameCommon.m_cbCardIndex,0)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OUT_CARD,"b",card)
    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_closeOutCardTips)
    return false
end

function GameLayer:OnUserAutoOperateCard()
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_OPERATE_CARD,"bwbb",GameCommon.CK_NULL,0,GameCommon.ACK_NULL,0,0)
    return true
end

function GameLayer:startWaitArmature(isStart)
    if self.waitArmature ~= nil then
        self.waitArmature:removeFromParent()
        self.waitArmature = nil
    end
    if isStart == true then
        self.actionLayer:setVisible(false)
        self.cardLayer:setVisible(false)
--        if GameCommon.isFriendsGame ~= true then
--            local uiPanel_function = ccui.Helper:seekWidgetByName(self.root,"Panel_function")
--            uiPanel_function:setVisible(false)
--        end
        if GameCommon.serverData.cbRoomFriend == 0 then           
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/xunzhaoduishou/xunzhaoduishou.ExportJson")
            self.waitArmature = ccs.Armature:create("xunzhaoduishou")
            self:addChild(self.waitArmature)
            local size = cc.Director:getInstance():getWinSize()
            self.waitArmature:setPosition(cc.p(size.width*0.4,size.height*0.5))
            self.waitArmature:getAnimation():playWithIndex(0)
            local item = ccui.Button:create("common/common_cancel.png","common/common_cancel.png","common/common_cancel.png")
            Common:addTouchEventListener(item,function() 
                require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
            end)
            item:setPosition(150,-100)
            self.waitArmature:addChild(item,100)
        elseif GameCommon.serverData.cbRoomFriend == 1 then 
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/dengdaihaoyou/dengdaihaoyou.ExportJson")
            self.waitArmature = ccs.Armature:create("dengdaihaoyou")
            self:addChild(self.waitArmature)
            local size = cc.Director:getInstance():getWinSize()
            self.waitArmature:setPosition(cc.p(size.width*0.4,size.height*0.5))
            self.waitArmature:getAnimation():playWithIndex(0)
        else          
        end
    else
        self.actionLayer:setVisible(true)
        self.cardLayer:setVisible(true)
--        if GameCommon.isFriendsGame ~= true then
--            local uiPanel_function = ccui.Helper:seekWidgetByName(self.root,"Panel_function")
--            uiPanel_function:setVisible(true)
--        end
    end

end

function GameLayer:showUserInfo(pBuffer)
   -- require("common.PositionLayer"):create(GameCommon.serverData.wKindID,pBuffer)
    --点击头像查看信息
    local UIselect= nil
    local csb = cc.CSLoader:createNode("PositionLayer.csb")

    self:addChild(csb)
    local root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(root,function() 
        csb:removeFromParent()
    end,true)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local uiImage_playerInfoBg = ccui.Helper:seekWidgetByName(root,"Image_playerInfoBg")
    local wChairID = 0
    for key, var in pairs(GameCommon.player) do
        if var.dwUserID == pBuffer.dwUserID then
            wChairID = var.wChairID
            break
        end
    end    
    for wChairID = 1, 4 do
        if GameCommon.player[wChairID] ~= nil then
            --local viewID = GameCommon:getViewIDByChairID(wChairID)
            local viewID = wChairID
            local uiPanel_player = ccui.Helper:seekWidgetByName(root,string.format("Panel_player%d",viewID))
            local uiPanel_playerInfo = ccui.Helper:seekWidgetByName(uiPanel_player,"Panel_playerInfo")
            uiPanel_playerInfo:setVisible(true)
            local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_avatar")
            Common:requestUserAvatar(GameCommon.player[wChairID].dwUserID,GameCommon.player[wChairID].szPto,uiImage_avatar,"img")
            local uiText_name = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_name")
            uiText_name:setString(GameCommon.player[wChairID].szNickName)
            local uiText_ID = ccui.Helper:seekWidgetByName(uiPanel_player,"Text_ID")
            if GameCommon.player[wChairID].dwOhterID ~= nil and GameCommon.player[wChairID].dwOhterID ~= 0 then
                uiText_ID:setString(string.format("%d",GameCommon.player[wChairID].dwOhterID))
            else
                uiText_ID:setString(string.format("%d",GameCommon.player[wChairID].dwUserID))
            end
            local uiImage_gender = ccui.Helper:seekWidgetByName(uiPanel_player,"Image_gender")
            if GameCommon.player[wChairID].cbSex == 0 then
                uiImage_gender:loadTexture("user/user_g.png")
            end
            for wTargetChairID = 1, 4 do
               -- local targetViewID = GameCommon:getViewIDByChairID(wTargetChairID)
                local targetViewID = wTargetChairID
                if GameCommon.number_dwHorse.bPlayerCount == 3 and wTargetChairID == 3 then
                    viewID = 4
                end
                if wTargetChairID ~= wChairID then
                    local uiText_location = ccui.Helper:seekWidgetByName(root,string.format("Text_%dto%d",viewID,targetViewID))
                    if viewID > targetViewID then
                        uiText_location = ccui.Helper:seekWidgetByName(root,string.format("Text_%dto%d",targetViewID,viewID))
                    end
                    if uiText_location ~= nil then
                        local distance = uiText_location:getString()
                        if GameCommon.number_dwHorse.bPlayerCount == 3 and (wChairID == 3 or wTargetChairID == 3) then
                            distance = ""
                        elseif GameCommon.player[wChairID] == nil or GameCommon.player[wTargetChairID] == nil then
                            distance = "等待加入..."
                        elseif GameCommon.serverData.cbRoomFriend == 0 then
                            if distance == "500m" then
                                distance = math.random(1000,300000)
                            end
                        elseif pBuffer.location[wChairID].x < 0.1 then
                            distance = string.format("%s未开启定位",GameCommon.player[wChairID].szNickName)
                        elseif pBuffer.location[wTargetChairID].x < 0.1 then
                            distance = string.format("%s未开启定位",GameCommon.player[wTargetChairID].szNickName)
                        else
                            distance = GameCommon:GetDistance(pBuffer.location[wChairID],pBuffer.location[wTargetChairID]) 
                        end                     
                        if type(distance) == "string" then

                        elseif distance > 1000 then
                            distance = string.format("%dkm",distance/1000)
                        else
                            distance = string.format("%dm",distance)
                        end
                        uiText_location:setString(distance)
                    end
                end
            end
        end
    end



end

function GameLayer:GetClockPos(wActionUser)
    local size = cc.Director:getInstance():getWinSize()

    if wActionUser == 0 then
        return cc.p(size.width*0.2,size.height*0.8)
    elseif wActionUser == 1 then
        return cc.p(size.width*0.5,size.height*0.2)
    elseif wActionUser == 2 then
        return cc.p(size.width*0.8,size.height*0.5)
    elseif wActionUser == 3 then
        return cc.p(size.width*0.5,size.height*0.8)
    else
        return cc.p(size.width*0.5,size.height*0.5)
    end
end

function GameLayer:showUserExpression( viewID, index)
    local pos=self:GetClockPos(viewID)
    local buff = ""
    if index == 0 then
        buff ="biaoqing-kaixin"                   --笑
    elseif index == 1 then
        buff ="biaoqing-shengqi"                 --怒
    elseif index == 2 then
        buff ="biaoqing-cool"                      --装
    elseif index == 3 then
        buff ="biaoqing-xihuan"                 --色
    elseif index == 4 then
        buff ="biaoqing-jingdai"                   --惊
    elseif index == 5 then
        buff ="biaoqing-daku"                 --哭
    else
        return
    end

    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(string.format("expression/animation/%s.ExportJson",buff))
    local  armature2=ccs.Armature:create(buff)
    armature2:setScale(0.6)
    armature2:getAnimation():playWithIndex(0)
    armature2:setPosition(pos)
    armature2:runAction(cc.Sequence:create(cc.DelayTime:create(2.0),cc.RemoveSelf:create(),nil))
    self:addChild(armature2,1)

    GameCommon:payEmoticon(index)
end

function GameLayer:showOutCardTips(isShow)
    local winSize=cc.Director:getInstance():getWinSize()
    if isShow == true then
        if(self.outCardTips ~= nil) then
            self.outCardTips:removeFromParent()
            self.outCardTips = nil
        end
        if self.outOprationState then
            return
        end
        GameCommon.bIsMyTurn = true

        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("laopai/mjAinimation/finger.ExportJson")
        self.outCardTips=ccs.Armature:create("finger")
        self.outCardTips:getAnimation():playWithIndex(0)
        self.outCardTips:setPosition(winSize.width*0.85,winSize.height*0.35)
        local uiPanel_effects = ccui.Helper:seekWidgetByName(self.root,"Panel_effects")
        uiPanel_effects:addChild(self.outCardTips)
    else
        GameCommon.bIsMyTurn = false
        if (self.outCardTips ~= nil) then
            self.outCardTips:removeFromParent()
        end
        self.outCardTips =nil
    end
end

--更新玩家信息
function GameLayer:updatePlayerInfo()
    if GameCommon.serverData.cbRoomFriend == 1  then
        local uiButton_Invitation = ccui.Helper:seekWidgetByName(self.root,"Button_Invitation")
        local uiButton_out = ccui.Helper:seekWidgetByName(self.root,"Button_out")
        if #GameCommon.tagUserInfoList == GameCommon.wPlayerCount then
            uiButton_Invitation:setVisible(false)
            uiButton_out:setVisible(false)
        else
            uiButton_Invitation:setVisible(true)
            uiButton_out:setVisible(true)
            if StaticData.Hide[CHANNEL_ID].btn4 ~= 1 then
                uiButton_Invitation:setVisible(false)
                uiButton_out:setVisible(false)
            end
        end       
    else
    end

    --初始化全部隐藏
    for i = 1 , GameCommon.wPlayerCount do
        local root = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",i))
        root:setVisible(false)
    end
    for i = 1 , GameCommon.wPlayerCount do
        local var = GameCommon.tagUserInfoList[i]
        if var ~= nil then
            local wChairID = GameCommon.tagUserInfoList[i].wChairID
            local viewID = GameCommon:SwitchViewChairID(var.wChairID) + 1
            local root = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
            root:setVisible(true)
            --用户ID
            root.dwUserID = var.dwUserID
            --名字
            local uiText_name = ccui.Helper:seekWidgetByName(root,"Text_name")
            uiText_name:setString(var.szNickName)
            --庄家
            local uiImage_banker = ccui.Helper:seekWidgetByName(root,"Image_banker")
            if var.wChairID == GameCommon.wBankerUser then
                print("庄家是谁：",GameCommon.wBankerUser) 
                uiImage_banker:setVisible(true)
            else
                uiImage_banker:setVisible(false)
            end
            --GameCommon.cbCFData[i]           
            --冲分
            local uiImage_chongfen = ccui.Helper:seekWidgetByName(root,"Image_chongfen")
            if GameCommon.cbCFData[i] == 4 then  
               uiImage_chongfen:setVisible(false)
            elseif  GameCommon.cbCFData[i] == 0 then
                uiImage_chongfen:setVisible(true)
                uiImage_chongfen:loadTexture("laopai/table/laopai_table8.png")
            else
                uiImage_chongfen:setVisible(true)
                uiImage_chongfen:loadTexture(string.format("laopai/table/laopai_table%s.png",GameCommon.cbCFData[i]+4))
            end
            local uiImage_guchou = ccui.Helper:seekWidgetByName(root,"Image_guchou")
            print("箍臭123：",GameCommon.m_guchou,wChairID)
            if GameCommon.m_guchou == wChairID then
                uiImage_guchou:setVisible(true)
                else
                uiImage_guchou:setVisible(false)
            end
            --头像                                                                                                                                                              Image_defaultAvatar
            local uiImage_defaultAvatar = ccui.Helper:seekWidgetByName(root,"Image_defaultAvatar")
            Common:requestUserAvatar(var.dwUserID, var.szPto,uiImage_defaultAvatar,"img")
            uiImage_defaultAvatar:setTouchEnabled(true)
            uiImage_defaultAvatar:addTouchEventListener(function(sender,event)
                if event == ccui.TouchEventType.ended then
                    Common:palyButton()
--                    if(GameCommon.tagUserInfoList[i].lWinCount ~=nil) then
--                        self:showUserInfo(i)
--                    else
                        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_USER_PLAYER_INFO,"d",GameCommon.tagUserInfoList[i].dwUserID)
--                    end
                end
            end);
            --其他标志
            local uiImage_other = ccui.Helper:seekWidgetByName(root,"Image_other")
            uiImage_other:removeAllChildren()
            if var.other == nil then
                uiImage_other:setVisible(false)
            end

            --准备
            local uiImage_ready = ccui.Helper:seekWidgetByName(root,"Image_ready")
            uiImage_ready:setVisible(false)
            if self.friendReady[i] == true then
                --if var.ready == true then
                uiImage_ready:setVisible(true)
            else
                uiImage_ready:setVisible(false)
            end
            --喇叭标志
            local uiImage_laba = ccui.Helper:seekWidgetByName(root,"Image_laba")
            uiImage_laba:setVisible(false)

            --是否在线
            local text_lixian = cc.Sprite:create("laopai/table/majiang_table57.png")       --离线标志
            local pt = uiImage_defaultAvatar:getContentSize()

            if var.cbOnline == 0x06 then
                root:setColor(cc.c3b(170,170,170))
                uiImage_defaultAvatar:addChild(text_lixian)
                text_lixian:setPosition(pt.width/2,pt.height/2)
            else
                root:setColor(cc.c3b(255,255,255))
                uiImage_defaultAvatar:removeAllChildren()
                
            end
            --积分
--            local uiImage_scoreType = ccui.Helper:seekWidgetByName(root,"Image_scoreType")
            local uiText_score = ccui.Helper:seekWidgetByName(root,"Text_score")
--            if GameCommon.isFriendsGame == true then
--                uiImage_scoreType:loadTexture("game/paohuzi/res/endlayer/endlayer34.png")
--            else
--                uiImage_scoreType:setVisible(true)
--            end
            local lScore = Common:itemNumberToString(var.lScore)
            uiText_score:setString(lScore)
        end
    end
end

--语音
function GameLayer:addVoice()
    self.tableVoice = {}
    local startVoiceTime = 0
    local maxVoiceTime = 15
    local intervalTimePackage = 0.1
    local fileName = "temp_voice.mp3"
    local uiButton_voice = ccui.Helper:seekWidgetByName(self.root,"Button_voice")
    local animVoice = cc.CSLoader:createNode("VoiceNode.csb")
    self:addChild(animVoice,120)
    local root = animVoice:getChildByName("Panel_root")
    local uiPanel_recording = ccui.Helper:seekWidgetByName(root,"Panel_recording")
    local uiPanel_cancel = ccui.Helper:seekWidgetByName(root,"Panel_cancel")
    local uiText_surplus = ccui.Helper:seekWidgetByName(root,"Text_surplus")
    animVoice:setVisible(false)

    --重置状态
    local duration = 0
    local function resetVoice()
        startVoiceTime = 0
        animVoice:stopAllActions()
        animVoice:setVisible(false)
        uiPanel_recording:setVisible(true)

        local uiImage_pro = ccui.Helper:seekWidgetByName(root,"Image_pro")
        uiImage_pro:removeAllChildren()
        local volumeMusic = cc.UserDefault:getInstance():getFloatForKey("UserDefault_Music",1)
        cc.SimpleAudioEngine:getInstance():setMusicVolume(volumeMusic)
        cc.SimpleAudioEngine:getInstance():setEffectsVolume(1)
        uiButton_voice:removeAllChildren()
        local node = require("common.CircleLoadingBar"):create("game/tablenew_23.png")
        node:setColor(cc.c3b(0,0,0))
        uiButton_voice:addChild(node)
        node:setPosition(node:getParent():getContentSize().width/2,node:getParent():getContentSize().height/2)
        node:start(1)
        uiButton_voice:setEnabled(false)
        uiButton_voice:stopAllActions()
        uiButton_voice:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
            uiButton_voice:setEnabled(true)
        end)))
    end

    root:setTouchEnabled(true)
    root:addTouchEventListener(function(sender,event) 
        UserData.Game:cancelVoice()
        resetVoice() 
    end)

    local function onEventSendVoic(event)
        if self.root == nil then
            return
        end
        if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
            if event == nil or string.len(event) <= 0 then
                return
            else
                event = Base64.decode(event)
            end
            local file = io.open(FileDir.dirVoice..fileName,"wb+")
            file:write(event)
            file:close()
        end
        if cc.FileUtils:getInstance():isFileExist(FileDir.dirVoice..fileName) == false then
            print("没有找到录音文件",FileDir.dirVoice..fileName)
            return
        end
        local fp = io.open(FileDir.dirVoice..fileName,"rb")
        local fileData = fp:read("*a")
        fp:close()

        local data = {}
        data.chirID = GameCommon:getRoleChairID()
        data.time = duration
        data.file = string.format("%d_%d.mp3",os.time(),UserData.User.userID)

        local fp = io.open(FileDir.dirVoice..data.file,"wb+")
        fp:write(fileData)
        fp:close()
        table.insert(self.tableVoice,#self.tableVoice + 1,data) 

        cc.FileUtils:getInstance():removeFile(FileDir.dirVoice..fileName)   --windows test

        local fileSize = string.len(fileData)
        local packSize = 1024
        local additional = fileSize%packSize
        if additional > 0 then
            additional = 1
        else
            additional = 0
        end
        local packCount = math.floor(fileSize/packSize) + additional
        local currentPos = 0
        for i = 1 , packCount do
            local periodData = string.sub(fileData,1,packSize)
            fileData = string.sub(fileData,packSize + 1)
            local periodSize = string.len(periodData)
            NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_GF_USER_VOICE,"wwwdddnsnf",GameCommon:getRoleChairID(),packCount,i,data.time,fileSize,periodSize,32,data.file,periodSize,periodData)
        end

    end

    local function onEventVoice(sender,event)
        if event == ccui.TouchEventType.began then
            startVoiceTime = 0
            uiButton_voice:setEnabled(false)
            animVoice:setVisible(true)
            cc.SimpleAudioEngine:getInstance():setMusicVolume(0) 
            cc.SimpleAudioEngine:getInstance():setEffectsVolume(0) 
            uiPanel_recording:setVisible(true)
            startVoiceTime = os.time()
            UserData.Game:startVoice(FileDir.dirVoice..fileName,maxVoiceTime,onEventSendVoic)

            local node = require("common.CircleLoadingBar"):create("common/yuying02.png")
            local uiImage_pro = ccui.Helper:seekWidgetByName(root,"Image_pro")
            uiImage_pro:removeAllChildren()
            uiImage_pro:addChild(node)
            node:setPosition(node:getParent():getContentSize().width/2,node:getParent():getContentSize().height/2)
            node:start(maxVoiceTime)

            local currentTime = 0
            uiText_surplus:stopAllActions()
            uiText_surplus:setString(string.format("还剩%d秒",maxVoiceTime - currentTime))
            uiText_surplus:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function(sender,event) 
                currentTime = currentTime + 1
                if currentTime > maxVoiceTime then
                    uiText_surplus:stopAllActions()
                    return
                end
                uiText_surplus:setString(string.format("还剩%d秒",maxVoiceTime - currentTime))
            end))))

        elseif event == ccui.TouchEventType.ended then
            if startVoiceTime == 0 or os.time() - startVoiceTime < 1 then
                UserData.Game:cancelVoice()
                resetVoice()
                return
            end
            duration = os.time() - startVoiceTime
            resetVoice()
            UserData.Game:overVoice()
            --onEventSendVoic() --windows test
        elseif event == ccui.TouchEventType.canceled then   
            if startVoiceTime == 0 or os.time() - startVoiceTime < 1 then
                resetVoice()
                return
            end
            resetVoice()
            UserData.Game:cancelVoice()
        end
    end
    uiButton_voice:addTouchEventListener(onEventVoice)
    local function onEventPlayVoice(sender,event)
        if #self.tableVoice > 0 then
            local data = self.tableVoice[1]
            table.remove(self.tableVoice,1)
            if data.time > maxVoiceTime then
                data.time = maxVoiceTime
            end
            local viewID = GameCommon:getViewIDByChairID(data.chirID)
            local wanjia = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_player%d",viewID))
            local uiImage_laba = ccui.Helper:seekWidgetByName(wanjia,"Image_laba")
            local blinks = math.floor(data.time*2)+1
            uiImage_laba:stopAllActions()
            uiImage_laba:runAction(cc.Sequence:create(
                cc.Show:create(),
                cc.CallFunc:create(function(sender,event) 
                    require("common.Common"):playVoice(FileDir.dirVoice..data.file)
                end),
                cc.Blink:create(data.time,blinks) ,
                cc.Hide:create(),
                cc.DelayTime:create(1),
                cc.CallFunc:create(function(sender,event) 
                    cc.FileUtils:getInstance():removeFile(FileDir.dirVoice..data.file) 
                    onEventPlayVoice()
                end)
            ))

        else
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(onEventPlayVoice)))
        end
    end
    onEventPlayVoice()
end

function GameLayer:OnUserChatVoice(event)
    if self.tableVoicePackages == nil then
        self.tableVoicePackages = {}
    end
    if self.tableVoicePackages[event.szFileName] == nil then
        self.tableVoicePackages[event.szFileName] = {}
    end
    self.tableVoicePackages[event.szFileName][event.wPackIndex] = event

    --组包
    if event.wPackCount == #self.tableVoicePackages[event.szFileName] then
        local fileData = ""
        for key, var in pairs(self.tableVoicePackages[event.szFileName]) do
            fileData = fileData..var.szPeriodData
        end 
        local data = {}
        data.chirID = self.tableVoicePackages[event.szFileName][1].wChairID
        data.time = self.tableVoicePackages[event.szFileName][1].dwTime
        data.file = self.tableVoicePackages[event.szFileName][1].szFileName
        local fp = io.open(FileDir.dirVoice..data.file,"wb+")
        fp:write(fileData)
        fp:close()
        table.insert(self.tableVoice,#self.tableVoice + 1,data)
        self.tableVoicePackages[event.szFileName] = nil
        print("插入一条语音...",fileData)
    end
end

function GameLayer:timeToSendCard()
    self.scheduleUpdateSendCard = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(delta) self:begainSendCard(delta) end, 0.001 ,false)
end

function GameLayer:begainSendCard(delta)

    self.sendCountUpdateTime = self.sendCountUpdateTime+1

    if self.sendCountUpdateTime == 17 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleUpdateSendCard)
    end

    local index = (GameCommon.wBankerUser+4+self.sendCount)%4
    local data = {}
    for x = 1 ,17 do
        data[x] = 0
    end
    local cout = 0
    cout, data = GameLogic:SwitchToCardDataTwo_luan(GameCommon.m_cbCardIndex)


    self.UpdateTime_n = 2
    --    if self.sendCount > 1 then
    --        GameCommon:paySoundeffect(GameCommon.Soundeffect_send4Card)
    --    end

    if self.sendCount > 15 then
        self.sendCount = 0
        self.MeTableCard = 0
        if GameCommon.serverData.cbRoomFriend == -1 then
--            if GameCommon.listdatacard[0]~= nil and GameCommon.listdatacard[1]~= nil and GameCommon.listdatacard[2]~= nil and GameCommon.listdatacard[3]~= nil then             
                return self:begainStartGame()
--            end
        else
            return self:begainStartGame()
        end 
    elseif  self.sendCount >= 12  then
        self.actionLayer:removeStoreCard(GameCommon.m_wSiceCount,0,true,index)
        if index == 1 then
            for i = self.MeTableCard + 1,GameCommon.m_cout_c do
                self.cardLayer:addHandCard(GameCommon.m_data_c[i])
            end
        end
    elseif self.sendCount < 12 then
        for i = 1 , 4 do
            self.actionLayer:removeStoreCard(GameCommon.m_wSiceCount,0,true,index)
            GameCommon.m_cbLeftCardCount = GameCommon.m_cbLeftCardCount-1
        end

        if index == 1 then
            for i = 1 , 4 do
                self.MeTableCard = self.MeTableCard+1
                self.cardLayer:addHandCard(GameCommon.m_data_c[self.MeTableCard])
            end

        end
    end
    self.sendCount = self.sendCount+1
    if self.sendCount==16 then
        self:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.0),
            --cc.CallFunc:create(function(sender,event) self.cardLayer:card_addpai() end),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function(sender,event)
                self.actionLayer:falseCard()
                self.cardLayer:card_addpai2() end),
            nil
        ))
    end

end

function GameLayer:WithTheNewDiscard()
    for i = 0 , 2 do 
        for j = 1 , 9 do 
            print("弃牌：",i,j,GameCommon.m_CardNumber[i][j])
            if  GameCommon.m_CardNumber[i][j] ~= 0 then 
                local uiTextNumber = ccui.Helper:seekWidgetByName(self.root,string.format("TextNumber_%d%d",i,j))
                uiTextNumber:setString( string.format("%d",GameCommon.m_CardNumber[i][j] ))
                uiTextNumber:setColor(cc.c3b(250,0,0))
            end
        end
    end

    for j = 1 , 3 do 
         print("弃牌：",3,j,GameCommon.m_CardNumber[3][j])
        if  GameCommon.m_CardNumber[3][j] ~= 0 then        
            local uiTextNumber = ccui.Helper:seekWidgetByName(self.root,string.format("TextNumber_%d%d",3,j))
            uiTextNumber:setString( string.format("%d",GameCommon.m_CardNumber[3][j] ))
            uiTextNumber:setColor(cc.c3b(250,0,0))
        end
    end

end

function GameLayer:begainStartGame()
    self.cardLayer:setTouchEable(true)
    local n_cardcout = 120
    if GameCommon.number_dwHorse.piaohua == nil then 
    elseif GameCommon.number_dwHorse.piaohua == 0 then 
        n_cardcout = 108
    end

    --剩余麻将
    GameCommon.m_cbLeftCardCount = n_cardcout - 16*4 - 1
    self.actionLayer:showLeftCardView(GameCommon.m_cbLeftCardCount)

    self.actionLayer:initTableCard(GameCommon.wBankerUser)

    local dice = {}
    dice[1] = GameCommon.m_wSiceCount
    for x=2 , 20 do
        dice[x] = 0
    end

    --self.actionLayer:initStoreCard(dice,GameCommon.m_cbLeftCardCount)   --  发牌后牌蹲

    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function(sender,event)
            self.actionLayer:onActionDelayOver()
        end),
        nil))
end

function GameLayer:begainStartPrepare()
    --时钟提示
    --    self:showTimeTips(GameCommon.wBankerUser)
    if GameCommon:SwitchViewChairID(GameCommon.wBankerUser) == 1 then
--        self.oprationLayer:showZhuangSelect()
    print("运行游戏")    
--        NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GF_GAME,NetMsgId.SUB_C_ZhuangStart,"n",1)   --临时注释

--        EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_UpOpration)
--        self:initButtonStatus()
    else
        self.actionLayer:showZhuangView(GameCommon:SwitchViewChairID(GameCommon.wBankerUser))
    end

    local dice = {}
    for x = 1 , 20 do
        dice[x] = 0
    end

    --self.actionLayer:initStoreCard(dice,120)    --初始牌蹲
end

function GameLayer:showTimeTips(viewID)
    self.actionLayer:showTimeTips(viewID)
    --    self.TouTipsArmature:setVisible(true)
    --    local actor = self.layout:getChildByName(string.format("Image_tou%d",viewID))
    --    if actor == nil then
    --        return
    --    end
    --
    --    local tou = actor:getChildByName("Image_bk")
    --    if tou == nil then
    --        return
    --    end
    --    self.TouTipsArmature:setPosition(tou:convertToWorldSpace(cc.p(33,33)))
    --    self.TouTipsArmature:setAnchorPoint(cc.p(0.5,0.5))
end

function GameLayer:showShortCardTips(isShow)
    local winSize = cc.Director:getInstance():getWinSize()
    if isShow == true then
        if self.shortCardTips ~= nil then
            self.shortCardTips:removeFromParent()
        end

    else
        if self.shortCardTips ~= nil then
            self.shortCardTips:removeFromParent()
            self.shortCardTips = nil
        end
    end
end
function GameLayer:showUserGangCardTips()
    GameCommon.m_bIsGang = true

    local size = cc.Director:getInstance():getWinSize()
    local spt =cc.Sprite:create("laopai/mjCommon/game_yaoshuaiTips.png")
    spt:setPosition(size.width*0.5,size.height*0.26)
    self.actionLayer:addChild(spt,4)

    self.cardLayer:setTouchEable(false)
end


--==============================--
--desc:表情互动
--time:2018-08-14 07:40:11
--@wChairID:
--@return 
--==============================--

function GameLayer:getViewWorldPosByChairID(wChairID)
	for key, var in pairs(GameCommon.player) do
		if wChairID == var.wChairID then
			local viewid = GameCommon:getViewIDByChairID(var.wChairID, true)
			local uiPanel_player = ccui.Helper:seekWidgetByName(self.root, string.format("Panel_player%d", viewid))
			local uiImage_avatar = ccui.Helper:seekWidgetByName(uiPanel_player, "Image_avatar")
			return uiImage_avatar:getParent():convertToWorldSpace(cc.p(uiImage_avatar:getPosition()))
		end
	end
end

function GameLayer:playSketlAnim(sChairID, eChairID, index,indexEx)

    local cusNode = cc.Director:getInstance():getNotificationNode()
    if not cusNode then
    	printInfo('global_node is nil!')
    	return
    end
    local arr = cusNode:getChildren()
    for i,v in ipairs(arr) do
        v:setVisible(false)
    end

	local Animation = require("game.paohuzi.Animation")
	local AnimCnf = Animation[22]
	
	if not AnimCnf[index] then
		return
	end
    
    indexEx = indexEx or ''
	local skele_key_name = 'hhhudong_' .. index .. indexEx
	local spos = self:getViewWorldPosByChairID(sChairID)
	local epos = self:getViewWorldPosByChairID(eChairID)
	local image = ccui.ImageView:create(AnimCnf[index].imageFile .. '.png')
	self:addChild(image)
	image:setPosition(spos)
	local moveto = cc.MoveTo:create(0.6, cc.p(epos))
	local callfunc = cc.CallFunc:create(function()
		local path = AnimCnf[index].animFile
		local skeletonNode = cusNode:getChildByName(skele_key_name)
		if not skeletonNode then
			skeletonNode = sp.SkeletonAnimation:create(path .. '.json', path .. '.atlas', 1)
			cusNode:addChild(skeletonNode)
			skeletonNode:setName(skele_key_name)
		end
		skeletonNode:setPosition(epos)
		skeletonNode:setAnimation(0, 'animation', false)
		skeletonNode:setVisible(true)
		image:removeFromParent()

		skeletonNode:registerSpineEventHandler(function(event)
			skeletonNode:setVisible(false)
		end, sp.EventType.ANIMATION_END)
		
		local soundData = AnimCnf[index]
		local soundFile = ''
		if soundData then
			local sound = soundData.sound
			if sound then
				soundFile = sound[0]
			end
		end
		if soundFile ~= "" then
			require("common.Common"):playEffect(soundFile)
		end
	end)
	image:runAction(cc.Sequence:create(moveto, callfunc))
end

--表情互动
function GameLayer:playSkelStartToEndPos(sChairID, eChairID, index)
	self.isOpen = cc.UserDefault:getInstance():getBoolForKey('HHOpenUserEffect', true) --是否接受别人的互动
	
	if GameCommon.meChairID == sChairID then --我发出
		if sChairID == eChairID then
			for i, v in pairs(GameCommon.player or {}) do
				if v.wChairID ~= sChairID then
					self:playSketlAnim(sChairID, v.wChairID, index, v.wChairID)
				end
			end
		else
			self:playSketlAnim(sChairID, eChairID, index)
		end
	else
		if self.isOpen then
			if sChairID == eChairID then
				for i, v in pairs(GameCommon.player or {}) do
					if v.wChairID ~= sChairID then
						self:playSketlAnim(sChairID, v.wChairID, index, v.wChairID)
					end
				end
			else
				self:playSketlAnim(sChairID, eChairID, index)
			end
		end
	end
end

--邀请在线好友
function GameLayer:pleaseOnlinePlayer()
    local dwClubID = GameCommon.tableConfig.dwClubID
    require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(dwClubID):createView("PleaseOnlinePlayerLayer"))
end


return GameLayer


