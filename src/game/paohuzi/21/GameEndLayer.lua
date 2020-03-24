local GameCommon = require("game.paohuzi.GameCommon")
local Bit = require("common.Bit")
local StaticData = require("app.static.StaticData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local GameLogic = require("game.paohuzi.GameLogic")
local Common = require("common.Common")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")

local GameEndLayer = class("GameEndLayer",function()
    return ccui.Layout:create()
end)

function GameEndLayer:create(pBuffer)
    local view = GameEndLayer.new()
    view:onCreate(pBuffer)
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

function GameEndLayer:onEnter()
    EventMgr:registListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
end

function GameEndLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_GR_MATCH_TABLE_FAILED,self,self.SUB_GR_MATCH_TABLE_FAILED)
end

function GameEndLayer:onCleanup()

end

function GameEndLayer:onCreate(pBuffer)   
    local csb = cc.CSLoader:createNode("GameLayerZiPai_End.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    local uiButton_return = ccui.Helper:seekWidgetByName(self.root,"Button_return")
    uiButton_return:setPressedActionEnabled(true)
    local function onEventReturn(sender,event)
    	if event == ccui.TouchEventType.ended then
            Common:palyButton()
            require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    	end
    end
    uiButton_return:addTouchEventListener(onEventReturn)
    local uiButton_continue = ccui.Helper:seekWidgetByName(self.root,"Button_continue")
    uiButton_continue:setPressedActionEnabled(true)
    local function onEventContinue(sender,event)
    	if event == ccui.TouchEventType.ended then
            Common:palyButton()
            if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
                if GameCommon.tableConfig.wTableNumber == GameCommon.tableConfig.wCurrentNumber then
                    EventMgr:dispatch(EventType.EVENT_TYPE_CACEL_MESSAGE_BLOCK)
                else
                    GameCommon:ContinueGame(GameCommon.tableConfig.cbLevel)
                end
            elseif GameCommon.tableConfig.nTableType == TableType_GoldRoom then 
                GameCommon:ContinueGame(GameCommon.tableConfig.cbLevel)
            else
                require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
            end          
    	end
    end
    uiButton_continue:addTouchEventListener(onEventContinue)
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        uiButton_return:setVisible(false)
    end
    if GameCommon.iscardcark == true then
        uiButton_return:setVisible(false)
        uiButton_continue:setVisible(false)
    end

    local Button_dissolve = ccui.Helper:seekWidgetByName(self.root,"Button_dissolve")
    Button_dissolve:setPressedActionEnabled(true)
    local function onEventReturn(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            require("common.MsgBoxLayer"):create(1,nil,"是否确定解散房间？",function()
                NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE,"")
            end)
        end
    end
    Button_dissolve:addTouchEventListener(onEventReturn)
    if (CHANNEL_ID == 10 or CHANNEL_ID == 11)  and  GameCommon.tableConfig.dwClubID ==nil and  GameCommon.tableConfig.dwClubID == 55404967 then 
        --Button_dissolve:setVisible(false)
    end 
    
    local uiPanel_look = ccui.Helper:seekWidgetByName(self.root,"Panel_look")
    local uiButton_look = ccui.Helper:seekWidgetByName(self.root,"Button_look")
    Common:addTouchEventListener(uiButton_look,function() 
        if uiPanel_look:isVisible() then
            uiPanel_look:setVisible(false)
            uiButton_look:setBright(false)
        else
            uiPanel_look:setVisible(true)
            uiButton_look:setBright(true)
        end
    end)
    if CHANNEL_ID == 8 or CHANNEL_ID == 9 then 
        uiButton_look:setPosition(127,678)
    end 
    --动画
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/wuguidonghua/wuguidonghua.ExportJson")
    local armature2=ccs.Armature:create("wuguidonghua")
    armature2:getAnimation():playWithIndex(0)
    local uiImage_bg = ccui.Helper:seekWidgetByName(self.root,"Image_bg")
    uiImage_bg:addChild(armature2)
    armature2:setPosition(0,armature2:getParent():getContentSize().height)
    armature2:runAction(cc.MoveTo:create(20,cc.p(armature2:getParent():getContentSize().width,armature2:getPositionY())))
    
    local uiAtlasLabel_jb = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_jb")
    local uiImage_iconjb = ccui.Helper:seekWidgetByName(self.root,"Image_iconjb")
    uiAtlasLabel_jb:setVisible(false)
    uiImage_iconjb:setVisible(false)
    local  integral = nil
	self.WPnumber = 0
	local number = 0
	--pBuffer.lGameScore[var.wChairID+1]
    for i=1 , GameCommon.gameConfig.bPlayerCount do
        if number < pBuffer.lGameScore[i] then 
            number = pBuffer.lGameScore[i]
        end

          
--           
--        end 
        print("玩家得分",pBuffer.lGameScore[i],number)    
    end  
    uiAtlasLabel_jb:setString(string.format(".%d",number))
       if GameCommon.tableConfig.nTableType ~= TableType_GoldRoom or GameCommon.iscardcark == true then
        uiImage_iconjb:loadTexture("game/game_table_score.png")
    else
       -- uiImage_iconjb:setVisible(true)
    end
--    if pBuffer.lGameScore[i]  <= 0 then
--            uiAtlasLabel_jb:setProperty(string.format(".%d",integral),"fonts/fonts_12.png",26,45,'.')
--    end
    local uiPanel_result = ccui.Helper:seekWidgetByName(self.root,"Panel_result")
    local uiImage_result = ccui.Helper:seekWidgetByName(self.root,"Image_result")
    local viewID = GameCommon:getViewIDByChairID(pBuffer.wWinUser)
    local textureName = nil
    if viewID == 1 then --自己胜
        textureName = "common/common_end1.png"   
    else
        textureName = "common/common_end2.png"       
    end
    local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
    uiImage_result:loadTexture(textureName)
    uiImage_result:setContentSize(texture:getContentSizeInPixels())   
    local distance = -90

    if(pBuffer.wProvideUser== GameCommon.INVALID_CHAIR) then
        --胡牌
        local spt =cc.Sprite:create("zipai/table/endlayerhupai.png")
        spt:setPosition(256 + distance,396)
        uiPanel_look:addChild(spt)
    else
        local viewID = GameCommon:getViewIDByChairID(pBuffer.wProvideUser)
        if viewID == 2 then
            local spt =cc.Sprite:create("zipai/table/endlayerfangpao_s.png")
            spt:setPosition(256 + distance,396)
            uiPanel_look:addChild(spt)
        elseif viewID == 1 then
            local spt =cc.Sprite:create("zipai/table/endlayerfangpao.png")
            spt:setPosition(256 + distance,396)
            uiPanel_look:addChild(spt)
        elseif viewID == 3 then
            local spt =cc.Sprite:create("zipai/table/endlayerfangpao_x.png")
            spt:setPosition(256 + distance,396)
            uiPanel_look:addChild(spt)
        else

        end
    end
    if GameCommon.tableConfig.nTableType ~= TableType_GoldRoom then
        uiImage_iconjb:loadTexture("game/game_table_score.png")
    end

    local uiText_beilv = ccui.Helper:seekWidgetByName(self.root,"Text_beilv")
    uiText_beilv:setString(string.format("倍率：%d",pBuffer.wBeilv))
    local uiText_xiaohao = ccui.Helper:seekWidgetByName(self.root,"Text_xiaohao")
    uiText_xiaohao:setString(string.format("本局消耗：%d",pBuffer.lGameTax))
    
    if GameCommon.tableConfig.nTableType ~= TableType_GoldRoom then
        uiText_beilv:setVisible(false)
        uiText_xiaohao:setVisible(false)
    else
        uiText_beilv:setVisible(true)
        uiText_xiaohao:setVisible(true)
    end

    
    --结算信息
    local uiListView_info = ccui.Helper:seekWidgetByName(self.root,"ListView_info")
    local uiPanel_defaultInfo = ccui.Helper:seekWidgetByName(self.root,"Panel_defaultInfo")
    uiPanel_defaultInfo:retain()
    uiListView_info:removeAllItems()
    
    local item = uiPanel_defaultInfo:clone()
    local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    uiImage_name = ccui.ImageView:create("zipai/table/endlayer_huxi.png")
    item:addChild(uiImage_name)
    uiImage_name:setAnchorPoint(cc.p(0,0.5))
    uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.HuCardInfo.cbHuXiCount),"fonts/fonts_8.png",18,27,'.')
    item:addChild(uiAtlasLabel_num)
    uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    uiListView_info:pushBackCustomItem(item)
    
    local item = uiPanel_defaultInfo:clone()
    local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    uiImage_name = ccui.ImageView:create("zipai/table/endlayer_fangshu.png")
    item:addChild(uiImage_name)
    uiImage_name:setAnchorPoint(cc.p(0,0.5))
    uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wFanCount),"fonts/fonts_8.png",18,27,'.')
    item:addChild(uiAtlasLabel_num)
    uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    uiListView_info:pushBackCustomItem(item)
    
    local item = uiPanel_defaultInfo:clone()
    local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    uiImage_name = ccui.ImageView:create("zipai/table/endlayer_tun.png")
    item:addChild(uiImage_name)
    uiImage_name:setAnchorPoint(cc.p(0,0.5))
    uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wTun),"fonts/fonts_8.png",18,27,'.')
    item:addChild(uiAtlasLabel_num)
    uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    uiListView_info:pushBackCustomItem(item)
    
    local item = uiPanel_defaultInfo:clone()
    local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    uiImage_name = ccui.ImageView:create("zipai/table/endlayer_alltun.png")
    item:addChild(uiImage_name)
    uiImage_name:setAnchorPoint(cc.p(0,0.5))
    uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wTun*pBuffer.wFanCount),"fonts/fonts_8.png",18,27,'.')
    item:addChild(uiAtlasLabel_num)
    uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    uiListView_info:pushBackCustomItem(item)
    uiPanel_defaultInfo:release()
    local ListView_Characterbox = nil
	local ListView_Characterbox4 = ccui.Helper:seekWidgetByName(self.root,"ListView_Characterbox4")
    ListView_Characterbox4:setVisible(false)    
    local ListView_Characterbox3 = ccui.Helper:seekWidgetByName(self.root,"ListView_Characterbox3")
    ListView_Characterbox3:setVisible(false)
    local ListView_Characterbox2 = ccui.Helper:seekWidgetByName(self.root,"ListView_Characterbox2")
    ListView_Characterbox2:setVisible(false)
    if GameCommon.gameConfig.bPlayerCount == 3 then
        ListView_Characterbox3:setVisible(true)
        ListView_Characterbox = ListView_Characterbox3
    elseif GameCommon.gameConfig.bPlayerCount == 4 then
        ListView_Characterbox4:setVisible(true)
        ListView_Characterbox = ListView_Characterbox4
    elseif GameCommon.gameConfig.bPlayerCount == 2 then
        ListView_Characterbox2:setVisible(true)
        ListView_Characterbox = ListView_Characterbox2
    end  
    for key, var in pairs(GameCommon.player) do
        local viewID = GameCommon:getViewIDByChairID(var.wChairID)     
        if GameCommon.gameConfig.bPlayerCount == 2 and  (CHANNEL_ID ==0 or CHANNEL_ID == 1 or CHANNEL_ID == 20 or CHANNEL_ID == 21)  and viewID == 2 then
            viewID = 3
        end        
        local root = ccui.Helper:seekWidgetByName(ListView_Characterbox,string.format("Panel_Characterbox%d",viewID))
        local uiImage_avatar = ccui.Helper:seekWidgetByName(root,"Image_avatar")
        Common:requestUserAvatar(var.dwUserID,var.szPto,uiImage_avatar,"img") 
        local uiText_name = ccui.Helper:seekWidgetByName(root,"Text_name")       
        uiText_name:setString(string.format("%s",var.szNickName)) 
        local uiText_ID = ccui.Helper:seekWidgetByName(root,"Text_ID")       
        uiText_ID:setString(string.format("ID:%s",var.dwUserID)) 
        local uiText_ZHX = ccui.Helper:seekWidgetByName(root,"Text_ZHX")
        local uiText_JSHX = ccui.Helper:seekWidgetByName(root,"Text_JSHX")
        uiText_ZHX:setVisible(false) 
        uiText_JSHX:setVisible(false) 
        local uiImage_yingjia = ccui.Helper:seekWidgetByName(root,"Image_yingjia")
        local uiAtlasLabel_money = ccui.Helper:seekWidgetByName(root,"Text_money")
       uiAtlasLabel_money:setFontSize(38)
        if GameCommon.tableConfig.nTableType == TableType_GoldRoom or GameCommon.tableConfig.nTableType  == TableType_SportsRoom then
            uiText_ID:setVisible(false)
        end 

        local dwGold = pBuffer.fWriteScoreArr[var.wChairID + 1]/100
        if pBuffer.lGameScore[var.wChairID + 1] > 0 then 
            uiImage_yingjia:setVisible(false) 
            uiAtlasLabel_money:setColor(cc.c3b(175,49,52))
            uiAtlasLabel_money:setString(string.format(" +%d\n(赛:+%0.2f)",pBuffer.lGameScore[var.wChairID + 1],dwGold))
        else  
            uiAtlasLabel_money:setColor(cc.c3b(30,85,60))         
            uiAtlasLabel_money:setString(string.format(" %d\n(赛:%0.2f)",pBuffer.lGameScore[var.wChairID + 1],dwGold))
        end   
        -- if GameCommon.tableConfig.nTableType ~= TableType_GoldRoom then 
        --     if pBuffer.lGameScore[var.wChairID+1]  <= 0 then
        --         uiImage_yingjia:setVisible(false) 
        --         uiAtlasLabel_money:setString(string.format("%d积分",pBuffer.lGameScore[var.wChairID+1] ))
        --     else
        --         uiAtlasLabel_money:setString(string.format("+%d积分",pBuffer.lGameScore[var.wChairID+1] ))
        --     end
		-- else
        --     if pBuffer.lGameScore[var.wChairID+1]  <= 0 then
        --         uiImage_yingjia:setVisible(false) 
        --         uiAtlasLabel_money:setString(string.format("%d金币",pBuffer.lGameScore[var.wChairID+1] ))
        --     else
        --         uiAtlasLabel_money:setString(string.format("+%d金币",pBuffer.lGameScore[var.wChairID+1] ))
        --     end
        -- end
        print("玩家得分",pBuffer.lGameScore[var.wChairID+1],var.wChairID)  
    end
    self:showPaiXing(pBuffer)
    self:showMingTang(pBuffer)
    self:showDiPai(pBuffer)
    local uiText_time = ccui.Helper:seekWidgetByName(self.root,"Text_time")
    -- uiText_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(function(sender,event) 
        local date = os.date("*t",os.time())
        uiText_time:setString(string.format("%d-%d-%d %02d:%02d:%02d",date.year,date.month,date.day,date.hour,date.min,date.sec))
        -- end),cc.DelayTime:create(1))))
    if CHANNEL_ID == 8 or CHANNEL_ID == 9 then 
        uiText_beilv:setPosition(1062,48)
        uiText_xiaohao:setPosition(1062,18)
        uiText_time:setPosition(1062,72)
    end 
end

--显示牌型和眼牌
function GameEndLayer:showPaiXing(pBuffer)
    local uiListView_weave = ccui.Helper:seekWidgetByName(self.root,"ListView_weave")
    local uiPanel_defaultWeave = ccui.Helper:seekWidgetByName(self.root,"Panel_defaultWeave")
    uiPanel_defaultWeave:retain()
    uiListView_weave:removeAllChildren()
    for WeaveItemIndex = 1 , pBuffer.HuCardInfo.cbWeaveCount do
        local item = uiPanel_defaultWeave:clone()
        local   WeaveItemArray= pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex]            --组合扑克
        for i = 1 , WeaveItemArray.cbCardCount do
            local data = WeaveItemArray.cbCardList[i]
            local _spt=GameCommon:getDiscardCardAndWeaveItemArray(data)
            _spt:setPosition(cc.p(0,(i - 1)*GameCommon.CARD_HUXI_HEIGHT))
            _spt:setAnchorPoint(cc.p(0,0))
            item:addChild(_spt)
        end

        local WeaveType=self:getSptWeaveType(WeaveItemArray.cbWeaveKind)
        WeaveType:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,5*GameCommon.CARD_HUXI_HEIGHT))
        item:addChild(WeaveType)

        local huxicout=GameLogic:GetWeaveHuXi(clone(WeaveItemArray))
        local Weavecout=cc.Label:createWithSystemFont(string.format("%d",huxicout), "Arial", 30)
        Weavecout:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,-GameCommon.CARD_HUXI_HEIGHT + 20))
        item:addChild(Weavecout)

        uiListView_weave:pushBackCustomItem(item)
    end
    uiPanel_defaultWeave:release()
    --眼牌
    if pBuffer.HuCardInfo.cbWeaveCount<=6 and pBuffer.HuCardInfo.cbCardEye ~=0 then
        local item = uiPanel_defaultWeave:clone()
        for i = 0 , 1 do
            local data = pBuffer.HuCardInfo.cbCardEye
            local _spt=GameCommon:getDiscardCardAndWeaveItemArray(data)
            _spt:setPosition(cc.p(0,i*GameCommon.CARD_HUXI_HEIGHT))
            _spt:setAnchorPoint(cc.p(0,0))
            item:addChild(_spt)
        end
        uiListView_weave:pushBackCustomItem(item)
    end 
end

--显示名堂
function GameEndLayer:showMingTang(pBuffer)
    self.PHZ_HT_TIANHU = 1            --自摸
    self.PHZ_HT_HONGHU = 2            --红胡    ①红字>=12  胡息*2
    self.PHZ_HT_DIANHU = 4            --点胡    只有一张红字       胡息*2
    self.PHZ_HT_HEIWU = 8             --黑乌    红字＝0，即全部是黑字     胡息*2                
    self.PHZ_HT_DIHU = 16              --地胡    胡息*2
    self.PHZ_HT_TIANHU = 32            --天胡    胡息*2

    local uiListView_player = ccui.Helper:seekWidgetByName(self.root,"ListView_player")
    local uiPanel_defaultPalyer = ccui.Helper:seekWidgetByName(self.root,"Panel_defaultPalyer")
    uiPanel_defaultPalyer:retain()
    uiListView_player:removeAllItems()

    --红胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_HONGHU) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"honghu",2,"x","huxi")
        uiListView_player:pushBackCustomItem(item)
    end

    --点胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_DIANHU) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"dianhu",2,"x","huxi")
        uiListView_player:pushBackCustomItem(item)
    end

    --黑胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_HEIWU) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"heihu",2,"x","huxi")
        uiListView_player:pushBackCustomItem(item)
    end

    --天胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_TIANHU) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"tianhu",2,"x","huxi")
        uiListView_player:pushBackCustomItem(item)
    end

    --地胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_TIANHU) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"dihu",2,"x","huxi")
        uiListView_player:pushBackCustomItem(item)
    end
    
    uiPanel_defaultPalyer:release()
end

function GameEndLayer:createMingTang(item,mingTang,num,numType,unit)
    local uiImage_name = ccui.ImageView:create(string.format("zipai/table/end_play_%s.png",mingTang))
    item:addChild(uiImage_name)
    uiImage_name:setAnchorPoint(cc.p(0,0.5))
    uiImage_name:setPosition(cc.p(-uiImage_name:getParent():getContentSize().width*0.2,uiImage_name:getParent():getContentSize().height/2))

    if numType == "+" then--加
        local uiAtlasLabel_num = ccui.TextAtlas:create(string.format(".%d",num),"fonts/fonts_9.png",18,27,'.')
        item:addChild(uiAtlasLabel_num)
        uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
        uiAtlasLabel_num:setPosition(cc.p(uiAtlasLabel_num:getParent():getContentSize().width*0.63,uiAtlasLabel_num:getParent():getContentSize().height/2))
    elseif numType == "-" then--减
        local uiAtlasLabel_num = ccui.TextAtlas:create(string.format(".%d",num),"fonts/fonts_10.png",18,27,'.')
        item:addChild(uiAtlasLabel_num)
        uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
        uiAtlasLabel_num:setPosition(cc.p(uiAtlasLabel_num:getParent():getContentSize().width*0.63,uiAtlasLabel_num:getParent():getContentSize().height/2))
    else
        --乘
        local uiAtlasLabel_num = ccui.TextAtlas:create(string.format(".%d",num),"fonts/fonts_8.png",18,27,'.')
        item:addChild(uiAtlasLabel_num)
        uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
        uiAtlasLabel_num:setPosition(cc.p(uiAtlasLabel_num:getParent():getContentSize().width*0.63,uiAtlasLabel_num:getParent():getContentSize().height/2))
    end
    if unit ~= "" then
        local uiImage_type = ccui.ImageView:create(string.format("zipai/table/end_play_%s.png",unit))
        item:addChild(uiImage_type)
        uiImage_type:setAnchorPoint(cc.p(0,0.5))
        uiImage_type:setPosition(cc.p(uiImage_type:getParent():getContentSize().width*0.55,uiImage_type:getParent():getContentSize().height/2))
    else

    end
end

--显示底牌
function GameEndLayer:showDiPai(pBuffer)
    local uiListView_diPai1 = ccui.Helper:seekWidgetByName(self.root,"ListView_diPai1")
    local uiListView_diPai2 = ccui.Helper:seekWidgetByName(self.root,"ListView_diPai2")
    for i = 1, pBuffer.bLeftCardCount do
        if pBuffer.bLeftCardDataEx[i] ~= 0 then
            local item = GameCommon:getDiscardCardAndWeaveItemArray(pBuffer.bLeftCardDataEx[i])
            if i<= 17 then
                uiListView_diPai1:pushBackCustomItem(item)
            else
                uiListView_diPai2:pushBackCustomItem(item)
            end
        end
    end
end

function GameEndLayer:getSptWeaveType(type)

    local sptname = ""
    if type == GameCommon.ACK_TI then
        sptname="zipai/table/endlayer14.png"
    elseif type == GameCommon.ACK_PAO then
        sptname="zipai/table/endlayer9.png"
    elseif type == GameCommon.ACK_WEI then
        sptname="zipai/table/endlayer7.png"
    elseif type == GameCommon.ACK_CHI then
        sptname="zipai/table/endlayer8.png"
    elseif type == GameCommon.ACK_PENG then
        sptname="zipai/table/endlayer10.png"
    else
       
    end
    return cc.Sprite:create(sptname)
end

function GameEndLayer:SUB_GR_MATCH_TABLE_FAILED(event)
    local data = event._usedata
    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    if data.wErrorCode == 0 then
        require("common.MsgBoxLayer"):create(0,nil,"您在游戏中!")
    elseif data.wErrorCode == 1 then
        require("common.MsgBoxLayer"):create(0,nil,"游戏配置发生错误!")
    elseif data.wErrorCode == 2 then
        require("common.MsgBoxLayer"):create(0,nil,"您的金币不足!")
    elseif data.wErrorCode == 3 then
        require("common.MsgBoxLayer"):create(0,nil,"您的金币已超过上限，请前往更高一级匹配!")
    elseif data.wErrorCode == 4 then
        require("common.MsgBoxLayer"):create(0,nil,"房间已满,稍后再试!")
    else
        require("common.MsgBoxLayer"):create(0,nil,"未知错误,请升级版本!") 
    end
end

return GameEndLayer
