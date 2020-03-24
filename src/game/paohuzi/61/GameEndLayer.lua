local GameCommon = require("game.paohuzi.61.GameCommon")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local Bit = require("common.Bit")
local StaticData = require("app.static.StaticData")
local Common = require("common.Common")
local GameLogic = require("game.paohuzi.61.GameLogic")
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
        Button_dissolve:setVisible(false)
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
    if GameCommon.tableConfig.nTableType  ~= TableType_GoldRoom or GameCommon.iscardcark == true then
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
        textureName = "common/61/winflag.png"   
    else
        textureName = "common/61/looseflag.png"       
    end
    local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
    uiImage_result:loadTexture(textureName)
    uiImage_result:setContentSize(texture:getContentSizeInPixels())   
    local distance = -90
    -- if(pBuffer.wProvideUser== GameCommon.INVALID_CHAIR) then
    --     --胡牌
    --     local spt =cc.Sprite:create("zipai/table/endlayerhupai.png")
    --     spt:setPosition(256 + distance,396)
    --     uiPanel_look:addChild(spt)
    -- else
    --     local viewID = GameCommon:getViewIDByChairID(pBuffer.wProvideUser)
    --     if viewID == 2 then
    --         local spt =cc.Sprite:create("zipai/table/endlayerfangpao_s.png")
    --         spt:setPosition(256 + distance,396)
    --         uiPanel_look:addChild(spt)
    --     elseif viewID == 1 then
    --         local spt =cc.Sprite:create("zipai/table/endlayerfangpao.png")
    --         spt:setPosition(256 + distance,396)
    --         uiPanel_look:addChild(spt)
    --     elseif viewID == 3 then
    --         local spt =cc.Sprite:create("zipai/table/endlayerfangpao_x.png")
    --         spt:setPosition(256 + distance,396)
    --         uiPanel_look:addChild(spt)
    --     else
    --     end
    -- end
    if GameCommon.tableConfig.nTableType  ~= TableType_GoldRoom then
        uiImage_iconjb:loadTexture("game/game_table_score.png")
    end

    local uiText_beilv = ccui.Helper:seekWidgetByName(self.root,"Text_beilv")
    uiText_beilv:setString(string.format("倍率：%d",pBuffer.wBeilv))
    local uiText_xiaohao = ccui.Helper:seekWidgetByName(self.root,"Text_xiaohao")
    uiText_xiaohao:setString(string.format("本局消耗：%d",pBuffer.lGameTax))
    
    if GameCommon.tableConfig.nTableType  ~= TableType_GoldRoom then
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
    
    -- local item = uiPanel_defaultInfo:clone()
    -- local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    -- uiImage_name = ccui.ImageView:create("zipai/table/endlayer_fangshu.png")
    -- item:addChild(uiImage_name)
    -- uiImage_name:setAnchorPoint(cc.p(0,0.5))
    -- uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    -- local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wFanCount),"fonts/fonts_8.png",18,27,'.')
    -- item:addChild(uiAtlasLabel_num)
    -- uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    -- uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    -- uiListView_info:pushBackCustomItem(item)
    
    -- local item = uiPanel_defaultInfo:clone()
    -- local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    -- uiImage_name = ccui.ImageView:create("zipai/table/endlayer_tun.png")
    -- item:addChild(uiImage_name)
    -- uiImage_name:setAnchorPoint(cc.p(0,0.5))
    -- uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    -- local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wTun),"fonts/fonts_8.png",18,27,'.')
    -- item:addChild(uiAtlasLabel_num)
    -- uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    -- uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    -- uiListView_info:pushBackCustomItem(item)
    
    -- local item = uiPanel_defaultInfo:clone()
    -- local uiImage_name = ccui.Helper:seekWidgetByName(item,"Image_name")
    -- uiImage_name = ccui.ImageView:create("zipai/table/endlayer_alltun.png")
    -- item:addChild(uiImage_name)
    -- uiImage_name:setAnchorPoint(cc.p(0,0.5))
    -- uiImage_name:setPosition(0,uiImage_name:getParent():getContentSize().height/2)
    -- local uiAtlasLabel_num = ccui.TextAtlas:create(string.format("%d",pBuffer.wTun*pBuffer.wFanCount),"fonts/fonts_8.png",18,27,'.')
    -- item:addChild(uiAtlasLabel_num)
    -- uiAtlasLabel_num:setAnchorPoint(cc.p(1,0.5))
    -- uiAtlasLabel_num:setPosition(uiAtlasLabel_num:getParent():getContentSize().width,uiAtlasLabel_num:getParent():getContentSize().height/2)
    -- uiListView_info:pushBackCustomItem(item)

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
            uiImage_yingjia:setVisible(true) 
            uiAtlasLabel_money:setColor(cc.c3b(175,49,52))           
            uiAtlasLabel_money:setString(string.format(" +%d\n(赛:+%0.2f)",pBuffer.lGameScore[var.wChairID + 1],dwGold))
        else   
            uiImage_yingjia:setVisible(false)  
            uiAtlasLabel_money:setColor(cc.c3b(30,85,60))       
            uiAtlasLabel_money:setString(string.format(" %d\n(赛:%0.2f)",pBuffer.lGameScore[var.wChairID + 1],dwGold))
        end
        -- if GameCommon.tableConfig.nTableType  ~= TableType_GoldRoom then 
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


function GameEndLayer:showPaiXingChi(pBuffer)  --吃牌排序处理
    for WeaveItemIndex = 1 , pBuffer.HuCardInfo.cbWeaveCount do
        local   WeaveItemArray= pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex]            --组合扑克
        if not WeaveItemArray then
            break   
        end
        for i = 1 , WeaveItemArray.cbCardCount do
            local data = WeaveItemArray.cbCardList[i]
            if WeaveItemArray.cbWeaveKind == GameCommon.ACK_CHI or WeaveItemArray.cbWeaveKind == GameCommon.ACK_CHI_EX then                           
               local a = 0             
               if data == WeaveItemArray.cbCenterCard and i~= 3 then
                    a = WeaveItemArray.cbCardList[3]
                    WeaveItemArray.cbCardList[3] =  WeaveItemArray.cbCardList[i]
                    WeaveItemArray.cbCardList[i] =  a 
               end
            end                       
        end
    end

end 
--显示牌型和眼牌
function GameEndLayer:showPaiXing(pBuffer)
    local uiListView_weave = ccui.Helper:seekWidgetByName(self.root,"ListView_weave")
    local uiPanel_defaultWeave = ccui.Helper:seekWidgetByName(self.root,"Panel_defaultWeave")
    uiPanel_defaultWeave:retain()
    uiListView_weave:removeAllChildren()
    self:showPaiXingChi(pBuffer)
    local isAddHuPai = false
    for WeaveItemIndex = 1 , pBuffer.HuCardInfo.cbWeaveCount do
        local   WeaveItemArray= pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex]            --组合扑克
        if not WeaveItemArray then
            break
        end
        pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai = 0 
        if pBuffer.HuCardInfo.cbWeaveCount<=2 and pBuffer.HuCardInfo.cbCardEye1 ~=0  and pBuffer.HuCardInfo.cbCardEye1 == pBuffer.cbHuCard and pBuffer.HuCardInfo.cbCardEye2 ~=0  and pBuffer.HuCardInfo.cbCardEye2 == pBuffer.cbHuCard then
        else
            for i = 1 , WeaveItemArray.cbCardCount do
                local data = WeaveItemArray.cbCardList[i]
                local _spt=GameCommon:getDiscardCardAndWeaveItemArray(data)
                if data == pBuffer.cbHuCard and not isAddHuPai then --胡牌
                    local a = true
                    if WeaveItemArray.cbWeaveKind == GameCommon.ACK_WEI then                   
                        for num_Weave = WeaveItemIndex +1 , pBuffer.HuCardInfo.cbWeaveCount do
                            local WeaveItemArray_1= pBuffer.HuCardInfo.WeaveItemArray[num_Weave]            --组合扑克
                            for i = 1 , WeaveItemArray_1.cbCardCount do
                                local data = WeaveItemArray_1.cbCardList[i]
                                if data == pBuffer.cbHuCard then --胡牌
                                    a = false
                                end 
                            end 
                        end    
                        if a == true then 
                            pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai = 3
                            isAddHuPai = true
                        end  
                    elseif WeaveItemArray.cbWeaveKind == GameCommon.ACK_TI  then 
                        pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai = 4
                        isAddHuPai = true              
                    end              
                end
                if data == pBuffer.cbHuCard and not isAddHuPai  then --胡牌
                    -- pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai = i
                    -- isAddHuPai = true
                    local a = true
                    for num_Weave = WeaveItemIndex +1 , pBuffer.HuCardInfo.cbWeaveCount do
                        local WeaveItemArray_1= pBuffer.HuCardInfo.WeaveItemArray[num_Weave]            --组合扑克
                        for i = 1 , WeaveItemArray_1.cbCardCount do
                            local data = WeaveItemArray_1.cbCardList[i]
                            if data == pBuffer.cbHuCard then --胡牌
                                a = false
                            end 
                        end 
                    end    
                    if a == true then 
                        pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai = i
                        isAddHuPai = true
                    end  
                end
            end
        end 
    end


    for WeaveItemIndex = 1 , pBuffer.HuCardInfo.cbWeaveCount do
        local item = uiPanel_defaultWeave:clone()
        local   WeaveItemArray= pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex]            --组合扑克
        for i = 1 , WeaveItemArray.cbCardCount do
            local data = WeaveItemArray.cbCardList[i]
            local _spt=GameCommon:getDiscardCardAndWeaveItemArray(data)
            _spt:setPosition(cc.p(0,(i - 1)*GameCommon.CARD_HUXI_HEIGHT))
            _spt:setAnchorPoint(cc.p(0,0))
            item:addChild(_spt)
            
            if data == pBuffer.cbHuCard  and pBuffer.HuCardInfo.WeaveItemArray[WeaveItemIndex].isHupai == i then --胡牌
                local di = cc.Sprite:create('zipai/table/img_15.png')
                _spt:addChild(di)
                local size = _spt:getContentSize()
                di:setPosition(size.width / 2,size.height / 2)
                dump(size,'======================>>>')
            end
        end
        if WeaveItemArray.cbCenterCard ~= 0 then   
            local WeaveType = ccui.Text:create("0","fonts/DFYuanW7-GB2312.ttf","30")
            WeaveType:setName('Text_OfflineTime')
            WeaveType:setTextColor(cc.c3b(202,193,142)) 
            WeaveType:enableOutline(cc.c4b(220, 0, 0), 2)
            WeaveType:setAnchorPoint(cc.p(0.5,0.5))
            item:addChild(WeaveType,100)
            WeaveType:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,5*GameCommon.CARD_HUXI_HEIGHT))       
            WeaveType:setString(string.format("%s",self:getSptWeaveType(WeaveItemArray.cbWeaveKind)))      
        end
        local huxicout=GameLogic:GetWeaveHuXi(clone(WeaveItemArray))
        local Weavecout=cc.Label:createWithSystemFont(string.format("%d",huxicout), "Arial", 30)
        Weavecout:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,-GameCommon.CARD_HUXI_HEIGHT + 30))
        item:addChild(Weavecout)

        uiListView_weave:pushBackCustomItem(item)
    end
    uiPanel_defaultWeave:release()
    --眼牌
    if pBuffer.HuCardInfo.cbWeaveCount<=6 and pBuffer.HuCardInfo.cbCardEye ~=0 then
        local item = uiPanel_defaultWeave:clone()
        -- for i = 0 , 1 do
            local cbCardEye1 = pBuffer.HuCardInfo.cbCardEye1
            local _spt=GameCommon:getDiscardCardAndWeaveItemArray(cbCardEye1)
            _spt:setPosition(cc.p(0,0))
            _spt:setAnchorPoint(cc.p(0,0))
            item:addChild(_spt)
            if cbCardEye1 == pBuffer.cbHuCard and not isAddHuPai  then --胡牌
                local di = cc.Sprite:create('zipai/table/img_15.png')
                _spt:addChild(di)
                local size = _spt:getContentSize()
                di:setPosition(size.width / 2,size.height / 2)
                isAddHuPai = true
            end

            local cbCardEye2 = pBuffer.HuCardInfo.cbCardEye2
            local _spt=GameCommon:getDiscardCardAndWeaveItemArray(cbCardEye2)
            _spt:setPosition(cc.p(0,1*GameCommon.CARD_HUXI_HEIGHT))
            _spt:setAnchorPoint(cc.p(0,0))
            item:addChild(_spt)
            if cbCardEye2 == pBuffer.cbHuCard and not isAddHuPai  then --胡牌
                local di = cc.Sprite:create('zipai/table/img_15.png')
                _spt:addChild(di)
                local size = _spt:getContentSize()
                di:setPosition(size.width / 2,size.height / 2)
                isAddHuPai = true
            end

            local huxi_Eye = false
            if cbCardEye1 == cbCardEye2  then 
                huxi_Eye = true
            else      
                local a = {[1]={2,7,10},[2]={18,23,26}} 
                local b = a[1]
                local c = {[1]={false},[2]={false}}
                if cbCardEye1 > 18 then
                    b = a[2]
                end                
                for k,v in pairs(b) do
                    if cbCardEye1 == v then 
                        c[1] = true 
                    end
                    if cbCardEye2 == v then 
                        c[2] = true 
                    end
                end
                if c[1] == true and c[2] == true and cbCardEye1~= cbCardEye2 then
                    huxi_Eye = true                   
                end 
            end 
            if  huxi_Eye == true then
                local WeaveType = ccui.Text:create("0","fonts/DFYuanW7-GB2312.ttf","30")
                WeaveType:setName('Text_OfflineTime')
                WeaveType:setTextColor(cc.c3b(202,193,142)) 
                WeaveType:enableOutline(cc.c4b(220, 0, 0), 2)
                WeaveType:setAnchorPoint(cc.p(0.5,0.5))
                item:addChild(WeaveType,100)
                WeaveType:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,5*GameCommon.CARD_HUXI_HEIGHT))                
                WeaveType:setString(string.format("眼"))   
                local Weavecout=cc.Label:createWithSystemFont(string.format("1"), "Arial", 30)
                Weavecout:setPosition(cc.p(GameCommon.CARD_HUXI_WIDTH*0.5,-GameCommon.CARD_HUXI_HEIGHT + 20))
                item:addChild(Weavecout)
            end

        uiListView_weave:pushBackCustomItem(item)
    end 
end

--显示名堂 
function GameEndLayer:showMingTang(pBuffer)

    self.PHZ_HT_Null     =0x00000000
    self.PHZ_HT_ZiMo     =0x00000001
    self.PHZ_HT_DuiDuiHu    =0x00000002
    self.PHZ_HT_DaZiHu     =0x00000004
    self.PHZ_HT_XiaoZiHu    =0x00000008
    self.PHZ_HT_13Hong     =0x00000010
    self.PHZ_HT_1Hong     =0x00000020
    self.PHZ_HT_HeiHu     =0x00000040
    self.PHZ_HT_HangHangXing   =0x00000080
    self.PHZ_HT_HaiDiHu    =0x00000100
    self.PHZ_HT_JiePai     =0x00000200
    self.PHZ_HT_BaoTing    =0x00000400
    self.PHZ_HT_TianHu     =0x00000800
    self.PHZ_HT_DiHu     =0x00001000
    self.PHZ_HT_1Dui     =0x00002000
    self.PHZ_HT_WuDui     =0x00004000
    self.PHZ_HT_QuanQiuRen  =0x00008000
    self.PHZ_HT_Max     =0x80000000

    local uiListView_player = ccui.Helper:seekWidgetByName(self.root,"ListView_player")
    local uiPanel_defaultPalyer = ccui.Helper:seekWidgetByName(self.root,"Panel_defaultPalyer")
    uiPanel_defaultPalyer:retain()
    uiListView_player:removeAllItems()
    -- 变量定义 
    local wHZCount = 0 
    local wDZCount = 0
    local wXZCount = 0
    local wTYCount = 0   -- 团圆次数
    local TY_cbCenterCard = {}
    local bIsDDH = true        
    local wTYCard = 0
    local sdata = {
        wTun = 0 ,          --囤
        wType = 0 ,         --数据
        wFanCount = 0,      --翻
    }
    --组合牌类型
    for cbIndex = 1 , pBuffer.HuCardInfo.cbWeaveCount do
        --变量定义
        local cbWeaveKind = pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbWeaveKind
        local cbWeaveCardCount = pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardCount
        --合法验证
        if cbWeaveKind ~= 0 then
            --组合内统计
            for cbCardIndex = 1 , cbWeaveCardCount do
                if pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardList[cbCardIndex] ~= 0 then
                    --大小字统计
                    if Bit:_and(pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardList[cbCardIndex] , GameCommon.MASK_COLOR) == 16 then
                        wDZCount = wDZCount + 1
                    else 
                        wXZCount = wXZCount + 1
                    end

                    --红字统计
                    if Bit:_and(pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardList[cbCardIndex] , GameCommon.MASK_VALUE)==2 
                        or Bit:_and(pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardList[cbCardIndex] , GameCommon.MASK_VALUE)==7 
                        or Bit:_and(pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCardList[cbCardIndex] , GameCommon.MASK_VALUE)==10 then
                        wHZCount = wHZCount + 1
                    end


                end               
            end
            --对对胡判断
            if cbWeaveKind== GameCommon.ACK_CHI or cbWeaveKind==GameCommon.ACK_CHI_EX then
                bIsDDH=false
            end
        end

        if cbWeaveKind == GameCommon.ACK_TI or cbWeaveKind == GameCommon.ACK_PAO then 
            local cbCenterCard = pBuffer.HuCardInfo.WeaveItemArray[cbIndex].cbCenterCard  
            wTYCard = wTYCard + 1    
            TY_cbCenterCard[wTYCard] = cbCenterCard  
        end
    end        

    --眼牌
    if pBuffer.HuCardInfo.cbCardEye~=0 then
            --大小字统计
            if Bit:_and(pBuffer.HuCardInfo.cbCardEye1 , GameCommon.MASK_COLOR) == 16 then
                wDZCount = wDZCount + 1
            else 
                wXZCount = wXZCount + 1
            end
            --红字统计
            if Bit:_and(pBuffer.HuCardInfo.cbCardEye1 , GameCommon.MASK_VALUE)==2  
                or Bit:_and(pBuffer.HuCardInfo.cbCardEye1, GameCommon.MASK_VALUE)==7 
                or Bit:_and(pBuffer.HuCardInfo.cbCardEye1, GameCommon.MASK_VALUE)==10 then

                wHZCount = wHZCount + 1
            end

            --大小字统计
            if Bit:_and(pBuffer.HuCardInfo.cbCardEye2 , GameCommon.MASK_COLOR) == 16 then
                wDZCount = wDZCount + 1
            else 
                wXZCount = wXZCount + 1
            end
            --红字统计
            if Bit:_and(pBuffer.HuCardInfo.cbCardEye2 , GameCommon.MASK_VALUE)==2  
                or Bit:_and(pBuffer.HuCardInfo.cbCardEye2, GameCommon.MASK_VALUE)==7 
                or Bit:_and(pBuffer.HuCardInfo.cbCardEye2, GameCommon.MASK_VALUE)==10 then
                wHZCount = wHZCount + 1
            end
    end

    --自摸判断
    if Bit:_and(pBuffer.wType,self.PHZ_HT_ZiMo)~= 0 then
        -- local item = uiPanel_defaultPalyer:clone()
        -- self:createMingTang(item,"自摸",10,"+","huxi")
        -- uiListView_player:pushBackCustomItem(item)      
    end 

    --对对胡=没有吃进的组合、手中没有单牌
    if Bit:_and(pBuffer.wType,self.PHZ_HT_DuiDuiHu) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"对子息","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"对子息","+120")
        else
            self:createMingTang(item,"对子息","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    --大字胡
    if Bit:_and(pBuffer.wType,self.PHZ_HT_DaZiHu)~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"全大","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"全大","+120")
        else
            self:createMingTang(item,"全大","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
        
    end 
    --小
    if Bit:_and(pBuffer.wType,self.PHZ_HT_XiaoZiHu)~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"全小","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"全小","+120")
        else
            self:createMingTang(item,"全小","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
        
    end 

    --13红
    if Bit:_and(pBuffer.wType,self.PHZ_HT_13Hong)~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"十三红","+"..string.format("%d",80+(wHZCount-13)*10))
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"十三红","+"..string.format("%d",100+(wHZCount-13)*10))
        else
            self:createMingTang(item,"十三红","+"..string.format("%d",80+(wHZCount-13)*10))
        end 
        uiListView_player:pushBackCustomItem(item)      
    end 
   --1红
    if Bit:_and(pBuffer.wType,self.PHZ_HT_1Hong)~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"一点红","+60")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"一点红","+80")
        else
            self:createMingTang(item,"一点红","+60")
        end 
        uiListView_player:pushBackCustomItem(item)      
    end  
    if Bit:_and(pBuffer.wType,self.PHZ_HT_HeiHu) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"全黑","+80")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"全黑","+100")
        else
            self:createMingTang(item,"全黑","+80")
        end 
        uiListView_player:pushBackCustomItem(item)
    end
   
    --行行息（真假）
    if Bit:_and(pBuffer.HuCardInfo.wDType,self.PHZ_HT_HangHangXing) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"行行息","+60")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"行行息","+80")
        else
            self:createMingTang(item,"行行息","+60")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_HaiDiHu) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"海捞","+30")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"海捞","+50")
        else
            self:createMingTang(item,"海捞","+30")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_JiePai) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"揭牌","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"揭牌","+120")
        else
            self:createMingTang(item,"揭牌","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
    end
    if Bit:_and(pBuffer.wType , self.PHZ_HT_BaoTing) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        ---self:createMingTang(item,"报听","+60")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"报听","+80")
        else
            self:createMingTang(item,"报听","+60")
        end 
        uiListView_player:pushBackCustomItem(item)
    end


    if Bit:_and(pBuffer.wType , self.PHZ_HT_TianHu) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"天胡","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"天胡","+120")
        else
            self:createMingTang(item,"天胡","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_DiHu) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"地胡","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"地胡","+120")
        else
            self:createMingTang(item,"地胡","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_1Dui) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"一对","+100")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"一对","+120")
        else
            self:createMingTang(item,"一对","+100")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_WuDui) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        --self:createMingTang(item,"无对","+120")
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"无对","+140")
        else
            self:createMingTang(item,"无对","+120")
        end 
        uiListView_player:pushBackCustomItem(item)
    end

    if Bit:_and(pBuffer.wType , self.PHZ_HT_QuanQiuRen) ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        if GameCommon.gameConfig.bMingTang == 2 then
            self:createMingTang(item,"全求人",60,"+","huxi")
        else
            self:createMingTang(item,"全求人",80,"+","huxi")
        end 
        uiListView_player:pushBackCustomItem(item)
    end
    local haofen= { [1]="一",[2]="二",[3]="三",[4]="四",[5]="五",[6]="六",[7]="七",[8]="八",[9]="九",[10]="十",
                    [11]="壹",[12]="贰",[13]="叁",[14]="肆",[15]="伍",[16]="陆",[17]="柒",[18]="捌",[19]="玖",[20]="拾",}
    for i=1 ,20 do
        if pBuffer.lHaoFen[i] ~= 0 then
            local item = uiPanel_defaultPalyer:clone()
            self:createMingTang(item,"豪牌"..haofen[i],"+"..string.format("%d",pBuffer.lHaoFen[i]))
            uiListView_player:pushBackCustomItem(item)
        end 
    end 
    if pBuffer.lTotalPiaoFen ~= 0 then
        local item = uiPanel_defaultPalyer:clone()
        self:createMingTang(item,"飘分","+"..string.format("%d",pBuffer.lTotalPiaoFen))
        uiListView_player:pushBackCustomItem(item)
    end 
    uiPanel_defaultPalyer:release()
end

function GameEndLayer:createMingTang(item,mingTang,num)
    if mingTang ~= "" then
        local uiText_OfflineTime = ccui.Text:create("0","fonts/DFYuanW7-GB2312.ttf","26")
        uiText_OfflineTime:setName('Text_OfflineTime')
        uiText_OfflineTime:setTextColor(cc.c3b(244,216,134)) 
        uiText_OfflineTime:enableOutline(cc.c4b(226, 139, 47), 2)
        uiText_OfflineTime:setAnchorPoint(cc.p(0,0.5))
        item:addChild(uiText_OfflineTime,100)
        uiText_OfflineTime:setPosition(cc.p(uiText_OfflineTime:getParent():getContentSize().width*0.1,uiText_OfflineTime:getParent():getContentSize().height/2))                
        uiText_OfflineTime:setString(string.format("%s",mingTang))         
    end 

    if num ~= "" then
        local uiText_OfflineTime = ccui.Text:create("0","fonts/DFYuanW7-GB2312.ttf","26")
        uiText_OfflineTime:setName('Text_OfflineTime')
        uiText_OfflineTime:setString(string.format("%s",num))         
        uiText_OfflineTime:setTextColor(cc.c3b(244,216,134)) 
        uiText_OfflineTime:enableOutline(cc.c4b(226, 139, 47), 2)
        uiText_OfflineTime:setAnchorPoint(cc.p(1,0.5))
        item:addChild(uiText_OfflineTime,100)
        uiText_OfflineTime:setPosition(cc.p(uiText_OfflineTime:getParent():getContentSize().width*0.8,uiText_OfflineTime:getParent():getContentSize().height/2))                       
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
        sptname="溜"
    elseif type == GameCommon.ACK_PAO then
        sptname="跑"
    elseif type == GameCommon.ACK_WEI then
        sptname="歪"
    elseif type == GameCommon.ACK_CHI then
        sptname="吃"
    elseif type == GameCommon.ACK_PENG then
        sptname="碰"
    elseif type == GameCommon.ACK_KAN then
        sptname="坎"     
    end
    return sptname
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
