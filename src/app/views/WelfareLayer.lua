local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMsgId = require("common.NetMsgId")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")
local HttpUrl = require("common.HttpUrl")
local WelfareLayer = class("WelfareLayer", cc.load("mvc").ViewBase)

function WelfareLayer:onEnter()
    EventMgr:registListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT) 
    EventMgr:registListener(EventType.SUB_CL_CHECKRESULT,self,self.SUB_CL_CHECKRESULT) 
    EventMgr:registListener(EventType.SUB_CL_FLUSHCHECKRECORD,self,self.SUB_CL_FLUSHCHECKRECORD) 
end

function WelfareLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_SC_ACTIONRESULT,self,self.SUB_SC_ACTIONRESULT) 
    EventMgr:unregistListener(EventType.SUB_CL_CHECKRESULT,self,self.SUB_CL_CHECKRESULT) 
    EventMgr:unregistListener(EventType.SUB_CL_FLUSHCHECKRECORD,self,self.SUB_CL_FLUSHCHECKRECORD) 
end

function WelfareLayer:onCreate(parames)
    if StaticData.Hide[CHANNEL_ID].btn3 == 0 then
        self:setVisible(false)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.RemoveSelf:create()))
        return
    end
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("WelfareLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
        
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
        self:removeFromParent()
    end)
    --to上下
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
--    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_top"),function() 
--        uiListView_welfareBtns:scrollToTop(0.5,true)
--    end)
--    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_down"),function() 
--        uiListView_welfareBtns:scrollToBottom(0.5,true)
--    end)
            
    --隐藏所有items
    for i = 999, 1007 do
        local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_welfare%d",i))
        uiPanel_welfare:setVisible(false)
        local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Button_welfare%d",i))
        uiButton_welfare:setVisible(false)
        Common:addTouchEventListener(uiButton_welfare,function() 
            self:showItem(i)
        end)
        if CHANNEL_ID ~= 10 and  CHANNEL_ID ~= 11 and  CHANNEL_ID ~= 16 and  CHANNEL_ID ~= 17 then  --渠道10  11  没房卡充值 有签到
            if StaticData.Hide[CHANNEL_ID].btn9 ~= 1 then
                if i == 1000  then 
                    uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
                end
            end
        end 
        if i == 1006  then 
            uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare)) 
        end
--        if i == 1008 then 
--            uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
--        end
    end

    --初始化items
    self:initNotice()            --公告
    self:initRegister()         --注册
    self:initSign()             --签到
    self:initFirstCharge()      --首充
    self:initFriendsRoomFree()  --好友房免费
    self:initShare()            --分享朋友圈
    self:initInvitation()       --邀请好友
--    self:initLuckDraw()         --抽奖
    self:initBankruptcy()       --破产金
--    self:initBUG()              --BUG
    
    --显示items
    self:showItem(parames[1])
    if parames[1] == 1007 then
        local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
        uiListView_welfareBtns:refreshView()
        uiListView_welfareBtns:scrollToPercentVertical(100,1,true)
    end
    
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    uiText_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
        local date = os.date("*t",os.time())
        uiText_time:setString(string.format("ID:%d %d-%d-%d %02d:%02d:%02d",UserData.User.userID,date.year,date.month,date.day,date.hour,date.min,date.sec))
    end),cc.DelayTime:create(1))))
end

--items显示
function WelfareLayer:showItem(index)
    if index == nil then
        index = 999
    end
    if index == 999 then
        cc.UserDefault:getInstance():setBoolForKey(string.format("%d_%d",UserData.User.userID,UserData.Notice.notice.dwNoticeTime),false)
    elseif index == 1000 then
        cc.UserDefault:getInstance():setIntegerForKey(string.format(Default.UserDefault_Sign,UserData.User.userID),os.time())
    end
    local notFound = true
    local default = nil
	for i = 999, 1007 do
        local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Button_welfare%d",i))
        local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_welfare%d",i))
        if uiButton_welfare ~= nil and uiPanel_welfare ~= nil then
            if default == nil then
                default = i
            end
    	   if i == index then
    	        notFound = false
                uiPanel_welfare:setVisible(true)
                uiButton_welfare:setVisible(true)
                uiButton_welfare:setBright(false)
    	   else
                uiPanel_welfare:setVisible(false)
                uiButton_welfare:setVisible(true)
                uiButton_welfare:setBright(true)
    	   end
        end
    end
    if notFound == true and default == nil then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.RemoveSelf:create()))
        return
    elseif notFound == true and default ~= nil then
        self:showItem(default)
        return
    else
    
    end
end

function WelfareLayer:initNotice()            --公告
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Panel_welfare%d",999))
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,string.format("Button_welfare%d",999))
    local isPop = false
    if UserData.Notice.notice ~= nil then
        if  UserData.Notice.notice.wNoticeType == 1 and cc.FileUtils:getInstance():isFileExist(FileDir.dirTemp..UserData.Notice.notice.szNoticeTitle) then
            isPop = true             
        elseif UserData.Notice.notice.wNoticeType == 0 then
            isPop = true 
        end
    end 
    if isPop == false then
        uiPanel_welfare:removeFromParent()
        uiButton_welfare:removeFromParent()
        return
    end
    
    --显示图片公告
    local uiImage_noticeBg = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Image_noticeBg")
    local uiText_noticeContents = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_noticeContents")
    if  UserData.Notice.notice.wNoticeType == 1 and cc.FileUtils:getInstance():isFileExist(FileDir.dirTemp..UserData.Notice.notice.szNoticeTitle) then
        uiPanel_welfare:removeAllChildren()
        local img = ccui.ImageView:create(FileDir.dirTemp..UserData.Notice.notice.szNoticeTitle)
        uiPanel_welfare:addChild(img)
        img:setPosition(img:getParent():getContentSize().width/2,img:getParent():getContentSize().height/2)
    elseif UserData.Notice.notice.wNoticeType == 0 then
        uiText_noticeContents:setString(UserData.Notice.notice.szNoticeInfo)
    end
    
end

function WelfareLayer:count_month_day( year, mon )

    if mon == 2 then
        if year % 4 == 0 then
            return 29
        else
            return 28
        end
    elseif mon == 1 or mon == 3 or mon == 5 or mon == 7 or mon == 8 or mon == 10 or mon == 12 then
        return 31
    elseif mon == 4 or mon == 6 or mon == 9 or mon == 11 then
        return 30
    end
end

function WelfareLayer:count_first_day_wday( currenyDay, weekDay )

    print("count_first_day_wday currenyDay, weekDay "..currenyDay.."-"..weekDay)

    --通过 今天 是 周几 来计算 1号 是周几

    local p1 = ( currenyDay - 1 ) % 7

    local pWeek = weekDay - p1

    local pWeekNum = 0
    if pWeek <= 0 then
        pWeekNum = pWeek + 7
    else
        pWeekNum = pWeek
    end

    return (pWeekNum - 1)

end

function WelfareLayer:initSign()             --签到
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1000")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1000")
    if uiButton_welfare == nil or uiPanel_welfare == nil then
        return
    end
    if UserData.Sign.tableSignData == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    local uiAtlasLabel_month = ccui.Helper:seekWidgetByName(uiPanel_welfare,"AtlasLabel_month")    
    local data = UserData.Time:getServerTimeToTable()--os.date("*t")--
    uiAtlasLabel_month:setString(string.format("%d",data.month))
    local uiImage_list = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Image_list")    
    local uiPanel_mask = ccui.Helper:seekWidgetByName(self.root,"Panel_mask")
    local uiLoadingBar_pro = ccui.Helper:seekWidgetByName(uiPanel_welfare,"LoadingBar_pro")    
    local uiButton_sign = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_sign")    
    local uiButton_repair = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_repair")     
    for i = 1 , 5 do
        local uiImage_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,string.format("Image_reward%d",i))
    end
    local tableSign = {}
    local isCanRepair = false
    local isCanSign = false
    local currentYear = data.year
    local currentMon = data.month
    local currentDay = data.day
    local mondays = self:count_month_day( currentYear, currentMon )
    local start = self:count_first_day_wday( currentDay, data.wday )
    for i = 0, 41 do
        local uiText_day = ccui.Helper:seekWidgetByName(uiImage_list,string.format("Text_%d",i+1))
        uiText_day:removeAllChildren()
        uiText_day:setVisible(true)
        uiText_day:setTextColor( cc.c3b(123, 79, 80) )
        -- 添加当日背景色
        if (i == start - 1 + currentDay) then
            local img = ccui.ImageView:create("welfare/sign/sign_8.png")
            uiPanel_mask:addChild(img)
            img:setPosition(img:getParent():convertToNodeSpace(cc.p(uiText_day:getParent():convertToWorldSpace(cc.p(uiText_day:getPosition())))))
        end

        -- 计算上月日期
        local preMon = currentMon - 1
        local preYear = currentYear
        if preMon == 0 then
            preYear = currentYear - 1
            preMon = 12
        end
        local preMonDays = self:count_month_day( preYear, preMon )

        --计算展示日期
        local showDay = i - start + 1;
        if showDay < 1 then
            showDay = showDay + preMonDays
        elseif showDay > mondays then
            showDay = showDay - mondays
        end
        uiText_day:setString(string.format("%d",showDay))

        if (i <= start - 1) or (i > (start - 1 + mondays)) then
            uiText_day:setVisible(false)
        elseif (i == start - 1 + currentDay) then
            uiText_day:setTextColor( cc.c3b(43, 32, 24) )
            tableSign[showDay] = {day = showDay, node = uiText_day}
        else
            
        end
        
        if UserData.Sign.tableSignData.btData[showDay] == 1 then--已签到
            print(showDay,"已签到")
            local img = ccui.ImageView:create("welfare/sign/sign_yiqiandao.png")
            uiText_day:addChild(img)
            img:setPosition(img:getParent():getContentSize().width/2,img:getParent():getContentSize().height/2)
        elseif UserData.Sign.tableSignData.btData[showDay] == 2 then--已补签
            print(showDay,"已补签")
            local img = ccui.ImageView:create("welfare/sign/sign_buqian.png")
            uiText_day:addChild(img)
            img:setPosition(img:getParent():getContentSize().width/2 + 22,img:getParent():getContentSize().height/2 + 5)
        else--未签到
            if showDay < currentDay then
                isCanRepair = true
        elseif showDay == currentDay then
            isCanSign = true
        else

        end
        end
    end
    
    local uiPanel_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Panel_reward")
    uiPanel_reward:setVisible(false)
--    uiPanel_reward:setTouchEnabled(true)
--    uiPanel_reward:addTouchEventListener(function(sender,event) 
--        if event == ccui.TouchEventType.ended then
--            uiPanel_reward:stopAllActions()
--            uiPanel_reward:setVisible(false)
--        end
--    end)
    local uiImage_rewardBg = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Image_rewardBg")
    uiImage_rewardBg:setTouchEnabled(true)
    uiImage_rewardBg:addTouchEventListener(function(sender,event) 
        if event == ccui.TouchEventType.ended then
            Common:palyButton() 
            uiPanel_reward:stopAllActions()
            uiPanel_reward:setVisible(false)
        end
    end)
    local uiListView_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,"ListView_reward")
    for i = 1 , 5 do
        local uiButton_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,string.format("Button_reward%d",i))
        uiButton_reward:removeAllChildren()
        if UserData.Sign.tableSignData.btGetPrice[i] == 1 then  --未领取
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("welfare/sign/xuanzhuanxing/xuanzhuanxing.ExportJson")
            local armature=ccs.Armature:create("xuanzhuanxing")
            armature:getAnimation():playWithIndex(0)
            uiButton_reward:addChild(armature)
            armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
            Common:addTouchEventListener(uiButton_reward,function() 
                NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_CHECKIN,NetMsgId.SUB_CL_CHECKINRECORD,"b",i)
            end)
        else
            if UserData.Sign.tableSignData.btGetPrice[i] == 2 then  --已领取
                local img = ccui.ImageView:create("welfare/sign/sign_fang3.png")
                uiButton_reward:addChild(img)
                img:setPosition(img:getParent():getContentSize().width/2,img:getParent():getContentSize().height/2)
            else--不可领
                
            end
            Common:addTouchEventListener(uiButton_reward,function() 
                uiListView_reward:removeAllItems()
                uiPanel_reward:setVisible(true)
                uiPanel_reward:setOpacity(0)
                uiPanel_reward:stopAllActions()
                uiPanel_reward:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.DelayTime:create(2.5),cc.FadeOut:create(0.5),cc.Hide:create()))
                local tableReward = {}
                if i == 1 then
                    tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw3Day[1]},
                        {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw3Day[2]}}
                elseif i == 2 then
                    tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw5Day[1]},
                        {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw5Day[2]}}
                elseif i == 3 then
                    tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw7Day[1]},
                        {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw7Day[2]}}
                elseif i == 4 then
                    tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw15Day[1]},
                        {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw15Day[2]}}
                elseif i == 5 then
                    tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dwallDay[1]},
                        {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dwallDay[2]}}
                else
                
                end
                for key, var in pairs(tableReward) do
                    local uiImage_reward = ccui.ImageView:create(StaticData.Items[var.wPropID].img)
                    uiListView_reward:pushBackCustomItem(uiImage_reward)
                    uiImage_reward:setScale(0.7)
                    local uiText_count = cc.Label:createWithSystemFont(string.format("%d",var.dwPropCount),"Arial",24)
                    uiImage_reward:addChild(uiText_count)
                    uiText_count:setAnchorPoint(cc.p(0.5,1))
                    uiText_count:setTextColor(cc.c3b(255,240,190))
                    uiText_count:setPosition(uiText_count:getParent():getContentSize().width/2,0)
                end
                uiListView_reward:setPositionX(uiListView_reward:getParent():getContentSize().width/2)
                local pos = cc.p(uiButton_reward:getParent():convertToWorldSpace(cc.p(uiButton_reward:getPosition())))
                pos = uiPanel_reward:convertToNodeSpace(pos)
                uiImage_rewardBg:setPositionX(pos.x+60)
            end)

        end
        
    end
    local uiButton_sign = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_sign")
    Common:addTouchEventListener(uiButton_sign,function() 
        NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_CHECKIN,NetMsgId.SUB_CL_CHECKINRECORD,"b",6)
    end)
    if isCanSign == false then
        uiButton_sign:setTouchEnabled(false)
        uiButton_sign:setBright(false)
    end
    local uiButton_repair = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_repair")
    Common:addTouchEventListener(uiButton_repair,function()
        local index = UserData.Sign.tableSignData.btSupCheckIndex + 1
        if index > 5 then
            index = 5
        end 
        local gold = UserData.Sign.tableSignData.dwFee[index]
        if UserData.User.dwGold < gold then
            if StaticData.Hide[CHANNEL_ID].btn8 == 1 then
                require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，是否前往充值？",function() 
                    require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("MallLayer"))
                end)    
            else
               require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
            end
            return
        end
        require("common.MsgBoxLayer"):create(1,nil,string.format("您确定要花费%d金币进行补签？",gold),function()
            NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_CHECKIN,NetMsgId.SUB_CL_CHECKINRECORD,"b",7)
        end)
    end)
    if isCanRepair == false then
        uiButton_repair:setTouchEnabled(false)
        uiButton_repair:setBright(false)
    end
end

function WelfareLayer:SUB_CL_CHECKRESULT(event)
    local data = event._usedata
    if data.btResult == 0 then
        local tableReward = {}
        if data.btCMD == 1 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw3Day[1]},
                {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw3Day[2]}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 2 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw5Day[1]},
                {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw5Day[2]}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 3 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw7Day[1]},
                {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw7Day[2]}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 4 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw15Day[1]},
                {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dw15Day[2]}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 5 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dwallDay[1]},
                {wPropID = 1003,dwPropCount = UserData.Sign.tableSignData.dwallDay[2]}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 6 then
            tableReward = {{wPropID = 1001,dwPropCount = UserData.Sign.tableSignData.dw1Day}}
            require("common.RewardLayer"):create("签到成功",nil,tableReward)
        elseif data.btCMD == 7 then
            require("common.MsgBoxLayer"):create(0,nil,"补签成功!")
        else
            
        end
    elseif data.btResult == 1 then
        if data.btCMD >= 1 and data.btCMD <= 5 then--领取奖励成功
            require("common.MsgBoxLayer"):create(0,nil,"领取失败!")
        elseif data.btCMD == 6 then
            require("common.MsgBoxLayer"):create(0,nil,"签到失败!")
        elseif data.btCMD == 7 then
            require("common.MsgBoxLayer"):create(0,nil,"补签失败!")
        else
        end
    elseif data.btResult == 2 then
        require("common.MsgBoxLayer"):create(0,nil,"金币不足!")
    end
    UserData.User:sendMsgUpdateUserInfo(0)
end

function WelfareLayer:SUB_CL_FLUSHCHECKRECORD(event)
	self:initSign()
end

function WelfareLayer:initRegister()        --注册
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1001")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1001")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1001]
    local record = UserData.Welfare.tableWelfare[1001]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    local uiButton_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_reward")
    if record.IsEnded == 1 then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    else
        uiButton_reward:setVisible(true)
    end
    if uiButton_reward.isAddToucheEvent == nil then
        uiButton_reward.isAddToucheEvent = true
        Common:addTouchEventListener(uiButton_reward,function() 
            UserData.Welfare:sendMsgRequestWelfare(1001)
        end)
    end
end

function WelfareLayer:initFirstCharge()      --首充
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1002")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1002")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1002]
    local record = UserData.Welfare.tableWelfare[1002]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    local uiButton_recharge = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_recharge")
    if uiButton_recharge.isAddToucheEvent == nil then
        uiButton_recharge.isAddToucheEvent = true
        Common:addTouchEventListener(uiButton_recharge,function() 
            require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(1):createView("MallLayer"))
        end)
    end
end


function WelfareLayer:initFriendsRoomFree()  --好友房免费
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1003")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1003")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1003]
    local record = UserData.Welfare.tableWelfare[1003]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_createRoom"),function() 
        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("RoomCreateLayer"))
    end)
end

function WelfareLayer:initShare()            --分享朋友圈
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1004")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1004")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1004]
    local record = UserData.Welfare.tableWelfare[1004]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    local uiText_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_reward")
    local tableTemp = Common:stringSplit(config.tcPrize,"|")
    for key, var in pairs(tableTemp) do
        local tempData = Common:stringSplit(var,"_")
        local wPropID = tonumber(tempData[1])
        local dwPropCount = tonumber(tempData[2])
        uiText_reward:setString(string.format("%sx%d",StaticData.Items[wPropID].name,dwPropCount))
    end
    local uiButton_share = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_share")
    Common:addTouchEventListener(uiButton_share,function() 
        local data = clone(UserData.Share.tableShareParameter[0])
        data.cbTargetType = 1
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID)
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1004]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1004)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"分享成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"分享失败")  
            end
        end)
    end)
    
    --邀请好友
--     self:initInvitation()
end

function WelfareLayer:initInvitation()       --邀请好友
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1004")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1004")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1005]
    local record = UserData.Welfare.tableWelfare[1005]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end
    local uiText_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_reward_1")
    local tableTemp = Common:stringSplit(config.tcPrize,"|")
    for key, var in pairs(tableTemp) do
        local tempData = Common:stringSplit(var,"_")
        local wPropID = tonumber(tempData[1])
        local dwPropCount = tonumber(tempData[2])
        uiText_reward:setString(string.format("%sx%d",StaticData.Items[wPropID].name,dwPropCount))
    end
    local uiButton_invitation = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_invitation")
    Common:addTouchEventListener(uiButton_invitation,function() 
        local data = clone(UserData.Share.tableShareParameter[0])
        data.cbTargetType = 2
        data.szShareImg = string.format(data.szShareImg,UserData.User.userID)
        UserData.Share:doShare(data,function(ret) 
            local record = UserData.Welfare.tableWelfare[1005]
            if ret == 1 then
                if record ~= nil and record.IsEnded == 0 then
                    UserData.Welfare:sendMsgRequestWelfare(1005)  
                else
                    require("common.MsgBoxLayer"):create(0,nil,"邀请成功，您今天已经领取过奖励！")
                end
            else
                require("common.MsgBoxLayer"):create(0,nil,"邀请失败")  
            end  
        end)
    end)
end

--function WelfareLayer:initLuckDraw()         --抽奖
--    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
--    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1006")
--    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1006")
--    if uiButton_welfare == nil then
--        return
--    end
--    local config = UserData.Welfare.tableWelfareConfig[1006]
--    local record = UserData.Welfare.tableWelfare[1006]
--    if config == nil or record == nil then
--        uiPanel_welfare:removeFromParent()
--        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
--        return
--    end
--    
--    local uiImage_luckDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Image_luckDraw")
--    local tableTemp = Common:stringSplit(config.tcPrize,"|")
--    for key, var in pairs(tableTemp) do
--        local tempData = Common:stringSplit(var,"_")
--        local wPropID = tonumber(tempData[1])
--        local dwPropCount = tonumber(tempData[2])
--        local uiPanel_reward = ccui.Helper:seekWidgetByName(uiPanel_welfare,string.format("Panel_reward%d",key))
--        local img = ccui.ImageView:create(StaticData.Items[wPropID].img)
--        uiPanel_reward:addChild(img)
--        img:setScale(0.5)
--        img:setPosition(img:getParent():getContentSize().width/2,img:getParent():getContentSize().height/2)
--        local count = ccui.TextAtlas:create(string.format("x%d",dwPropCount),"fonts/fonts_2.png",45,52,"0")
--        img:addChild(count)
--        count:setAnchorPoint(cc.p(0.5,0))
--        count:setPosition(count:getParent():getContentSize().width/2,count:getParent():getContentSize().height)
--        if dwPropCount <= 1 then
--        	count:setVisible(false)
--        end
--    end
--    local uiButton_luackDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_luackDraw")
--    local uiListView_rewardRecord = ccui.Helper:seekWidgetByName(uiPanel_welfare,"ListView_rewardRecord")
--    local uiText_tips = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_tips")
----    uiText_tips:setString(string.format("每次抽奖消耗%s金币!",10000))
--    local uiListView_rewardRecord = ccui.Helper:seekWidgetByName(uiPanel_welfare,"ListView_rewardRecord")
--    uiListView_rewardRecord:removeAllItems()
--    local count = 0
--    local info = ""
--    if record.stInfo ~= "" then
--        count = tonumber(string.sub(record.stInfo,1,1))
--        info = string.sub(record.stInfo,2)
--    end
--    local tableTemp = Common:stringSplit(info,"|")
--    local uiText_count = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_count")
--    uiText_count:setString(string.format("%s次",3-count))
--    for key, var in pairs(tableTemp) do
--        local tempData = Common:stringSplit(var,"_")
--        local wPropID = tonumber(tempData[1])
--        local dwPropCount = tonumber(tempData[2])
--        local rewardRecord = ccui.Text:create(string.format("恭喜您,获得%sx%d",StaticData.Items[wPropID].name,dwPropCount),"Arial",24)
--        rewardRecord:setTextColor(cc.c3b(255,245,193))
--        uiListView_rewardRecord:pushBackCustomItem(rewardRecord)
--    end
--    local ALLROATE = 360--360度
--    local num = 8
--    --转盘角度数据
--    self.zhuanpanData = 
--    {
----        {start = (num-10)*ALLROATE/num + 0, ended = (num-9)*ALLROATE/num},
----        {start = (num-9)*ALLROATE/num + 1, ended = (num-8)*ALLROATE/num},
--        {start = (num-8)*ALLROATE/num + 1, ended = (num-7)*ALLROATE/num},
--        {start = (num-7)*ALLROATE/num + 1, ended = (num-6)*ALLROATE/num},
--        {start = (num-6)*ALLROATE/num + 1, ended = (num-5)*ALLROATE/num},
--        {start = (num-5)*ALLROATE/num + 1, ended = (num-4)*ALLROATE/num},
--        {start = (num-4)*ALLROATE/num + 1, ended = (num-3)*ALLROATE/num},
--        {start = (num-3)*ALLROATE/num + 1, ended = (num-2)*ALLROATE/num},
--        {start = (num-2)*ALLROATE/num + 1, ended = (num-1)*ALLROATE/num},
--        {start = (num-1)*ALLROATE/num + 1, ended = (num-0)*ALLROATE/num},
--    }
--    
--    self.lastAngle = uiImage_luckDraw:getRotation()
--    Common:addTouchEventListener(uiButton_luackDraw,function() 
--        if UserData.User.dwGold < 10000 then
--            if StaticData.Hide[CHANNEL_ID].btn8 == 1 then
--                require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，是否前往充值？",function() 
--                    require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("MallLayer"))
--                end)  
--            else
--               require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
--            end
--            
--        elseif UserData.User.szRealName  == "" then
--            require("common.MsgBoxLayer"):create(1,nil,"您没有填写手机号码，是否前往实名认证？",function() 
--                require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("PerfectInfoLayer"))
--            end)    
--        else
--            UserData.Welfare:sendMsgRequestWelfare(1006)
--        end
--    end)
--    if record.IsEnded == 1 then
--        uiButton_luackDraw:setTouchEnabled(false)
--        uiButton_luackDraw:setColor(cc.c3b(170,170,170))
--    end
--end

--function WelfareLayer:rotateSprite(sprite, time, rotateAngle_)
--    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1006")
--    local uiButton_luackDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_luackDraw")
--    require("common.CommonLayer"):create(time)
--    local action = cc.RotateBy:create(time, rotateAngle_)
--    local easeAction = cc.EaseCubicActionInOut:create(action)
--    require("common.Common"):playEffect("welfare/luckdraw/luckdraw_sound.mp3")
--    sprite:runAction(cc.Sequence:create(easeAction,cc.CallFunc:create(function(sender,event) uiButton_luackDraw:setTouchEnabled(true) end)))
--end

--function WelfareLayer:endperformWithDelayGlobal(targetIdx,rotateNum,duration)
--    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1006")
--    local uiButton_luackDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_luackDraw")
--    local uiImage_luckDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Image_luckDraw")
--    --@param duration  转动持续时间
--    --@param rotateNum 转动圈数
--    --@param targetIdx 服务器传来的值。
--    local targetData = self.zhuanpanData[targetIdx]
--    --        local rotateAngle = - math.random(targetData.start, targetData.ended) - 360 * rotateNum   --开始和结束中间随机
--    local rotateAngle = - (targetData.start + (targetData.ended - targetData.start) / 2) - 360 * rotateNum    --当前指针位置在边缘
--    --        local rotateAngle = - targetData.start - 360 * rotateNum    --当前指针正在某个奖品中间
--    print("随机角度是：", rotateAngle)
--    --第二次需要重置坐标点
--    if self.lastAngle ~= 0 then
--        self:rotateSprite(uiImage_luckDraw, duration, rotateAngle + self.lastAngle)
--    else
--        self:rotateSprite(uiImage_luckDraw, duration, rotateAngle)
--    end
--    self.lastAngle = -360 - rotateAngle - 360 * rotateNum
--end

function WelfareLayer:initBankruptcy()       --破产金
    local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
    local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1007")
    local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1007")
    if uiButton_welfare == nil then
        return
    end
    local config = UserData.Welfare.tableWelfareConfig[1007]
    local record = UserData.Welfare.tableWelfare[1007]
    if config == nil or record == nil then
        uiPanel_welfare:removeFromParent()
        uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
        return
    end

    local uiButton_bankruptcy = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_bankruptcy")
    if uiButton_bankruptcy.isAddToucheEvent == nil then
        uiButton_bankruptcy.isAddToucheEvent = true
        Common:addTouchEventListener(uiButton_bankruptcy,function() 
            if UserData.User.dwGold > 500 then
                if StaticData.Hide[CHANNEL_ID].btn8 == 1 then
                    require("common.MsgBoxLayer"):create(1,nil,"您的金币不少于500，不能领取破产金!但您可以成为大富翁，是否前去充值？",function() 
                        require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("MallLayer"))
                    end)
                else
                    require("common.MsgBoxLayer"):create(0,nil,"您的金币不少于500，不能领取破产金!")
                end
            else
                UserData.Welfare:sendMsgRequestWelfare(1007)
            end
        end)
    end
    if record.IsEnded == 1 then
        uiButton_bankruptcy:setTouchEnabled(false)
        uiButton_bankruptcy:setBright(false)
    else
        uiButton_bankruptcy:setTouchEnabled(true)
        uiButton_bankruptcy:setBright(true)
        
    end
end


function WelfareLayer:SUB_SC_ACTIONRESULT(event)
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
        local data = event._usedata
        --刷新活动
        if data.dwActID == 1001 then
            self:initRegister()
            self:showItem(999)
        elseif data.dwActID == 1002 then
            self:initRegister()
        elseif data.dwActID == 1003 then
    
        elseif data.dwActID == 1004 then
        
        elseif data.dwActID == 1005 then
    
        elseif data.dwActID == 1006 then
--            self:endperformWithDelayGlobal(tonumber(data.parame) + 1,5,5)
--            self:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.CallFunc:create(function(sender,event) 
--                local uiListView_welfareBtns = ccui.Helper:seekWidgetByName(self.root,"ListView_welfareBtns")
--                local uiButton_welfare = ccui.Helper:seekWidgetByName(self.root,"Button_welfare1006")
--                local uiPanel_welfare = ccui.Helper:seekWidgetByName(self.root,"Panel_welfare1006")
--                if uiButton_welfare == nil then
--                    return
--                end
--                local config = UserData.Welfare.tableWelfareConfig[1006]
--                local record = UserData.Welfare.tableWelfare[1006]
--                if config == nil or record == nil then
--                    uiPanel_welfare:removeFromParent()
--                    uiListView_welfareBtns:removeItem(uiListView_welfareBtns:getIndex(uiButton_welfare))
--                    return
--                end
--                local uiListView_rewardRecord = ccui.Helper:seekWidgetByName(uiPanel_welfare,"ListView_rewardRecord")
--                uiListView_rewardRecord:removeAllItems()
--                local count = 0
--                local info = ""
--                if record.stInfo ~= "" then
--                    count = tonumber(string.sub(record.stInfo,1,1))
--                    info = string.sub(record.stInfo,2)
--                end
--                local tableTemp = Common:stringSplit(info,"|")
--                local uiText_count = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Text_count")
--                uiText_count:setString(string.format("%s次",3-count))
--                for key, var in pairs(tableTemp) do
--                    local tempData = Common:stringSplit(var,"_")
--                    local wPropID = tonumber(tempData[1])
--                    local dwPropCount = tonumber(tempData[2])
--                    local rewardRecord = ccui.Text:create(string.format("恭喜您,获得%sx%d",StaticData.Items[wPropID].name,dwPropCount),"Arial",24)
--                    rewardRecord:setTextColor(cc.c3b(50,14,0))
--                    uiListView_rewardRecord:pushBackCustomItem(rewardRecord)
--                end
--                local uiButton_luackDraw = ccui.Helper:seekWidgetByName(uiPanel_welfare,"Button_luackDraw")
--                if record.IsEnded == 1 then
--                    uiButton_luackDraw:setTouchEnabled(false)
--                    uiButton_luackDraw:setColor(cc.c3b(170,170,170))
--                end
--
--                require("common.RewardLayer"):create("福利奖励",nil,tableReward)
--            end)))
--            return
            
        elseif data.dwActID == 1007 then
            self:initBankruptcy()
        else
            return
        end
        require("common.RewardLayer"):create("福利奖励",nil,tableReward)
    else
        require("common.MsgBoxLayer"):create(0,nil,"领取奖励失败!")
    end
end



return WelfareLayer