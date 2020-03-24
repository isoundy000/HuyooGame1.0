local GameCommon = require("game.majiang.97.GameCommon")
local Bit = require("common.Bit")
local StaticData = require("app.static.StaticData")
local GameLogic = require("game.majiang.97.GameLogic")
local Common = require("common.Common")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
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
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayerMaJiang_End.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    local uiButton_return = ccui.Helper:seekWidgetByName(self.root,"Button_return")
    uiButton_return:setPressedActionEnabled(true)
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        uiButton_return:setVisible(false)
    end
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
    
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("game/wuguidonghua/wuguidonghua.ExportJson")
    local armature2=ccs.Armature:create("wuguidonghua")
    armature2:getAnimation():playWithIndex(0)
    local uiImage_bjkuang = ccui.Helper:seekWidgetByName(self.root,"Image_bjkuang")
    uiImage_bjkuang:addChild(armature2,100)
    armature2:setPosition(0,armature2:getParent():getContentSize().height)
    armature2:runAction(cc.MoveTo:create(20,cc.p(1280,armature2:getPositionY())))
    
    --显示桌面、显示结算
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
    local uiText_info = ccui.Helper:seekWidgetByName(self.root,"Text_info")
    if GameCommon.tableConfig.nTableType == TableType_GoldRoom then
        uiText_info:setString(string.format("倍率 %d\n消耗%d",pBuffer.lCellScore,pBuffer.lGameTax))
    else
        uiText_info:setString("")
    end
    local uiImage_result = ccui.Helper:seekWidgetByName(self.root,"Image_biaoti") 
    local textureName = nil
    if pBuffer.wWinner[GameCommon:getRoleChairID()+1] == true then
        textureName = "common/common_end1.png"   
    else
        textureName = "common/common_end2.png"       
    end
    local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
    uiImage_result:loadTexture(textureName)
    uiImage_result:setContentSize(texture:getContentSizeInPixels())   
    
    local maCount = 0
    local uiText_mingtang = ccui.Helper:seekWidgetByName(self.root,"Text_mingtang")
    if GameCommon.gameConfig.bMaType == 1 then
        uiText_mingtang:setString("一五九")
        local maxRow = 3
        local uiPanel_zhong = ccui.Helper:seekWidgetByName(self.root,"Panel_zhong")
        local size = uiPanel_zhong:getContentSize()
        for i = 1, 85 do
            local data = pBuffer.bZhaNiao[i]
            if data ~= 0 and  data ~= 255  then
                local cardScale = 1
                local cardWidth = 55 * cardScale
                local cardHeight = 85 * cardScale
                local stepX = cardWidth + 5
                local stepY = -(cardHeight+12)
                local beganX = (size.width-stepX*3)/2+cardWidth/2
                local beganY = size.height - 50
                local size = cc.size(cardWidth,cardHeight)
                local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
                uiPanel_zhong:addChild(card)
                card:setScale(cardScale)
                local row = math.floor((i-1)/maxRow)
                local line = (i-1)%maxRow
                card:setPosition(beganX + stepX*line ,beganY + stepY*row)  
                local value = Bit:_and(data,0x0F)
                if value == 1 or value == 5 or value == 9 then
                    maCount = maCount + 1
                else
                    card:setColor(cc.c3b(170,170,170))
                end
            else
                break
            end
        end
    elseif GameCommon.gameConfig.bMaType == 2 then
        uiText_mingtang:setString("窝窝鸟")
        local maxRow = 3
        local uiPanel_zhong = ccui.Helper:seekWidgetByName(self.root,"Panel_zhong")
        local size = uiPanel_zhong:getContentSize()
        table.insert(pBuffer.bZhaNiao,1,pBuffer.cbZhaNiaoWOWO)
        for i = 1, 85 do
            local data = pBuffer.bZhaNiao[i]
            if data ~= 0 and  data ~= 255  then
                local cardScale = 1
                local cardWidth = 55 * cardScale
                local cardHeight = 85 * cardScale
                local stepX = cardWidth + 5
                local stepY = -(cardHeight+12)
                local beganX = (size.width-stepX*3)/2+cardWidth/2
                local beganY = size.height - 30
                local size = cc.size(cardWidth,cardHeight)
                local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
                uiPanel_zhong:addChild(card)
                card:setScale(cardScale)
                local row = math.floor((i-1)/maxRow)
                local line = (i-1)%maxRow
                if i == 1 then
                    line = line + 1
                else
                    row = math.floor((i-2)/maxRow)
                    line = (i-2)%maxRow
                    row = row + 1
                end
                card:setPosition(beganX + stepX*line ,beganY + stepY*row)  
                local value = Bit:_and(data,0x0F)
                if i ~= 1 and (value == 1 or value == 5 or value == 9) then
                    maCount = maCount + 1
                elseif i ~= 1 then
                    card:setColor(cc.c3b(170,170,170))
                end
            else
                break
            end
        end
    elseif GameCommon.gameConfig.bMaType == 6 then  
        uiText_mingtang:setString("翻几奖几") 
        local maxRow = 3
        local uiPanel_zhong = ccui.Helper:seekWidgetByName(self.root,"Panel_zhong")
        local size = uiPanel_zhong:getContentSize()
        local data = pBuffer.bZhaNiao[1]
        local i = 1
        if data ~= 0 and  data ~= 255  then
            local cardScale = 1
            local cardWidth = 55 * cardScale
            local cardHeight = 85 * cardScale
            local stepX = cardWidth + 5
            local stepY = -(cardHeight+12)
            local beganX = (size.width-stepX*3)/2+cardWidth/2
            local beganY = size.height - 50
            local size = cc.size(cardWidth,cardHeight)
            local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
            uiPanel_zhong:addChild(card)
            card:setScale(cardScale)
            local row = math.floor((i-1)/maxRow)
            local line = (i-1)%maxRow
            line = line + 1
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)  
            if data == 0x31 then
                maCount = 10
            else
                maCount = Bit:_and(data,0x0F)
            end
        end
    elseif GameCommon.gameConfig.bMaType == 3 then
        uiText_mingtang:setString("一马全中")
        local maxRow = 3
        local uiPanel_zhong = ccui.Helper:seekWidgetByName(self.root,"Panel_zhong")
        local size = uiPanel_zhong:getContentSize()
        local data = pBuffer.bZhaNiao[1]
        local i = 1
        if data ~= 0 and  data ~= 255  then
            local cardScale = 1
            local cardWidth = 55 * cardScale
            local cardHeight = 85 * cardScale
            local stepX = cardWidth + 5
            local stepY = -(cardHeight+12)
            local beganX = (size.width-stepX*3)/2+cardWidth/2
            local beganY = size.height - 50
            local size = cc.size(cardWidth,cardHeight)
            local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
            uiPanel_zhong:addChild(card)
            card:setScale(cardScale)
            local row = math.floor((i-1)/maxRow)
            local line = (i-1)%maxRow
            line = line + 1
            card:setPosition(beganX + stepX*line ,beganY + stepY*row)  
            if data == 0x31 then
                maCount = 10
            else
                maCount = Bit:_and(data,0x0F)
            end
        end
    elseif GameCommon.gameConfig.bMaType == 5 then
        uiText_mingtang:setString("摸几奖几")
        local maxRow = 3
        local uiPanel_zhong = ccui.Helper:seekWidgetByName(self.root,"Panel_zhong")
        local size = uiPanel_zhong:getContentSize()
        table.insert(pBuffer.bZhaNiao,1,pBuffer.cbZhaNiaoWOWO)
        for i = 1, 85 do
            local data = pBuffer.bZhaNiao[i]
            if data ~= 0 and  data ~= 255  then
                local cardScale = 1
                local cardWidth = 55 * cardScale
                local cardHeight = 85 * cardScale
                local stepX = cardWidth + 5
                local stepY = -(cardHeight+12)
                local beganX = (size.width-stepX*3)/2+cardWidth/2
                local beganY = size.height - 30
                local size = cc.size(cardWidth,cardHeight)
                local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
                uiPanel_zhong:addChild(card)
                card:setScale(cardScale)
                local row = math.floor((i-1)/maxRow)
                local line = (i-1)%maxRow
                if i == 1 then
                    line = line + 1
                else
                    row = math.floor((i-2)/maxRow)
                    line = (i-2)%maxRow
                    row = row + 1
                end
                card:setPosition(beganX + stepX*line ,beganY + stepY*row)  
                local value = Bit:_and(data,0x0F)
                if i ~= 1 and (value == 1 or value == 5 or value == 9) then
                    maCount = maCount + 1
                elseif i ~= 1 then
                    card:setColor(cc.c3b(170,170,170))
                end
            else
                break
            end
        end
    else
        uiText_mingtang:setString("不奖马")
    end

    local uiListView_player = ccui.Helper:seekWidgetByName(self.root,"ListView_player")
    local uiPanel_itemWin = ccui.Helper:seekWidgetByName(self.root,"Panel_itemWin")
    uiPanel_itemWin:retain()
    uiListView_player:removeAllItems()
    for i = 1,GameCommon.gameConfig.bPlayerCount do
        local wChairID = i-1    
        local var = GameCommon.player[wChairID]
        local viewID = GameCommon:getViewIDByChairID(wChairID)            
        local item = uiPanel_itemWin:clone()
        uiListView_player:pushBackCustomItem(item)
        local uiImage_avatar = ccui.Helper:seekWidgetByName(item,"Image_avatar")
        Common:requestUserAvatar(var.dwUserID,var.szPto,uiImage_avatar,"img")
        local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
        uiText_name:setString(string.format("%s\n%d",var.szNickName,var.dwUserID))
        if GameCommon.tableConfig.nTableType == TableType_GoldRoom or GameCommon.tableConfig.nTableType  == TableType_SportsRoom then
            uiText_name:setString(string.format("%s",var.szNickName))
        end 
        uiText_name:setTextColor(cc.c3b(0,0,0))
        local uiImage_zhuang = ccui.Helper:seekWidgetByName(item,"Image_zhuang")
        if i == GameCommon.wBankerUser + 1 then
            uiImage_zhuang:setVisible(true)
        else
            uiImage_zhuang:setVisible(false)
        end
        local uiListView_mingTang = ccui.Helper:seekWidgetByName(item,"ListView_mingTang")
        self:showMingTang(uiListView_mingTang, pBuffer.wChiHuKind[i])

        self:showCheng(uiListView_mingTang, pBuffer.mChengNum[i])
        local uiImage_zhongMa = ccui.Helper:seekWidgetByName(item,"Image_zhongMa")     
        if GameCommon.gameConfig.bMaType ~= 4 and pBuffer.wWinner[i] == true then
            uiImage_zhongMa:setVisible(true)
            local uiText_zhongnumber = ccui.Helper:seekWidgetByName(item,"Text_zhongnumber")
            uiText_zhongnumber:setString(string.format("x%d",maCount))--中马数量
            uiText_zhongnumber:setTextColor(cc.c3b(95,8,0))
        else
            uiImage_zhongMa:setVisible(false)
        end
        local uiImage_dice = ccui.Helper:seekWidgetByName(item,"Image_dice")
        uiImage_dice:setVisible(false)
        local uiImage_winType = ccui.Helper:seekWidgetByName(item,"Image_winType")
        if pBuffer.wProvideUser < GameCommon.gameConfig.bPlayerCount then
            if pBuffer.wProvideUser == wChairID and pBuffer.wWinner[i] == true then
                local textureName = "majiang/table/end_zimo.png"
                local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
                uiImage_winType:loadTexture(textureName)
                uiImage_winType:setContentSize(texture:getContentSizeInPixels())
            elseif pBuffer.wWinner[i] == true then
                local textureName = "majiang/table/end_hupai.png"
                local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
                uiImage_winType:loadTexture(textureName)
                uiImage_winType:setContentSize(texture:getContentSizeInPixels())
            elseif pBuffer.wProvideUser == wChairID and pBuffer.wWinner[i] == false then
                local textureName = "majiang/table/end_fangpao.png"
                local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
                uiImage_winType:loadTexture(textureName)
                uiImage_winType:setContentSize(texture:getContentSizeInPixels())
            else
                uiImage_winType:setVisible(false)
            end
        else
            uiImage_winType:setVisible(false)
        end
        
        local uiListView_card = ccui.Helper:seekWidgetByName(item,"ListView_card")
        for j = 1, pBuffer.cbWeaveItemCount[i] do
            local content = self:getWeaveItemArray(pBuffer.WeaveItemArray[i][j])
            uiListView_card:pushBackCustomItem(content)
        end
        local isFound = false
        local cbCardCount = {}
        for j = 1 , pBuffer.cbCardCount[i] do
            local data = pBuffer.cbCardData[i][j]
            if GameCommon.mChaoTianCard ~= 0 and  GameCommon.mChaoTianCard== data then 
                --王牌麻将，王牌放左边
                table.insert(cbCardCount,1,data)
            elseif GameCommon.mLaiZiCard ~= 0 and  GameCommon.mLaiZiCard== data then 
                local mChaoTianCard = 0
                for i =1 ,3 do
                    if cbCardCount[i] == GameCommon.mChaoTianCard then 
                        mChaoTianCard = mChaoTianCard + 1
                    end 
                end 
                --王牌麻将，王牌放左边
                table.insert(cbCardCount,mChaoTianCard+1,data)
            else
                table.insert(cbCardCount,#cbCardCount+1,data)
            end
        end 
        for j = 1 , #cbCardCount do
            local cardScale = 0.8
            local cardWidth = 55 * cardScale
            local cardHeight = 85 * cardScale
            local size = cc.size(cardWidth,cardHeight)
            local content = ccui.Layout:create()
            content:setContentSize(size)
            uiListView_card:pushBackCustomItem(content)
            local data = cbCardCount[j]
            local card = GameCommon:getDiscardCardAndWeaveItemArray(data,1)
            content:addChild(card)
            card:setScale(cardScale)
            card:setPosition(size.width/2,size.height/2)

            if GameCommon.mLaiZiCard ~= 0 and GameCommon.mLaiZiCard == data then
                local node = require("common.CircleLoadingBar"):create("newcommon/lai_left.png")
                node:setColor(cc.c3b(0,0,0))
                card:addChild(node)
                node:setPosition(14,70)
                node:start(0)
                node:setScale(0.7)    
            elseif GameCommon.mChaoTianCard ~= 0 and GameCommon.mChaoTianCard == data then 
                local node = require("common.CircleLoadingBar"):create("newcommon/chao_left.png")
                node:setColor(cc.c3b(0,0,0))
                card:addChild(node)
                node:setPosition(42,70)
                node:start(0)  
                node:setScale(0.7)   
            end

            if isFound == false and data == pBuffer.cbChiHuCard[i] then
                ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("majiang/animation/hudepaitishi/hudepaitishi.ExportJson")
                local armature = ccs.Armature:create("hudepaitishi")
                armature:getAnimation():playWithIndex(0,-1,1)
                armature:setAnchorPoint(cc.p(0,0))
                armature:setPosition(0,2)
                card:addChild(armature)
                armature:setScale(cardScale - 0.1, cardScale)
                isFound = true
                print('--------结束谁胡牌wChairID',wChairID)
            end
        end
        local uiAtlasLabel_score = ccui.Helper:seekWidgetByName(item,"AtlasLabel_score")
        uiAtlasLabel_score:setVisible(false)

        local uiText_result = ccui.Helper:seekWidgetByName(item,"Text_result")
        uiText_result:setTextColor(cc.c3b(255,209,81))
        uiText_result:setFontName("fonts/DFYuanW7-GB2312.ttf")
        local dwGold = pBuffer.fWriteScoreArr[i]/100
        if pBuffer.lGameScore[i] > 0 then 
            uiText_result:setColor(cc.c3b(175,49,52))
            uiText_result:setString(string.format(" +%d\n(赛:+%0.2f)",pBuffer.lGameScore[i],dwGold))
        else   
            uiText_result:setColor(cc.c3b(30,85,60))   
            uiText_result:setString(string.format(" %d\n(赛:%0.2f)",pBuffer.lGameScore[i],dwGold))
        end 

        -- if pBuffer.lGameScore[i] < 0 then       
        --     uiAtlasLabel_score:setProperty(string.format(".%d",pBuffer.lGameScore[i]),"fonts/fonts_12.png",26,45,'.')              
        -- elseif  pBuffer.lGameScore[i] > 0 then
        --     uiAtlasLabel_score:setProperty(string.format(".%d",pBuffer.lGameScore[i]),"fonts/fonts_13.png",26,45,'.')
        -- else
        --     uiAtlasLabel_score:setProperty(string.format(".%d",pBuffer.lGameScore[i]),"fonts/fonts_13.png",26,45,'.')
        -- end
    end
    uiPanel_itemWin:release()
end

function GameEndLayer:getWeaveItemArray(var)
    
    local cardScale = 0.8
    local cardWidth = 55 * cardScale
    local cardHeight = 85 * cardScale
    local size = cc.size(cardWidth*3+5,cardHeight)
    local content = ccui.Layout:create()
    content:setContentSize(size)
    local cbCardList = {}
    if Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_PENG) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard,var.cbCenterCard}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
        cbCardList = {var.cbCenterCard,var.cbCenterCard+1,var.cbCenterCard+2}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
        cbCardList = {var.cbCenterCard-1,var.cbCenterCard,var.cbCenterCard+1}
    elseif Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
        cbCardList = {var.cbCenterCard-1,var.cbCenterCard-2,var.cbCenterCard}
    else
        assert(false,"吃牌类型错误")
    end
    for k, v in pairs(cbCardList) do
        local card = nil
        local TS_gang =  false
        if GameCommon.mChaoTianCard ~= 0 and GameCommon.mChaoTianCard == v then
            TS_gang = true                       
        end 
        if k < 4 and var.cbPublicCard == 2 and (Bit:_and(var.cbWeaveKind,GameCommon.WIK_GANG) ~= 0 or Bit:_and(var.cbWeaveKind,GameCommon.WIK_FILL) ~= 0) then
            -- card = GameCommon:getDiscardCardAndWeaveItemArray(0,1)
            if TS_gang == true then 
                card = GameCommon:getDiscardCardAndWeaveItemArray(v,1)
            else
                card = GameCommon:getDiscardCardAndWeaveItemArray(0,1)
            end 
        else
            if TS_gang ~= true then 
                card = GameCommon:getDiscardCardAndWeaveItemArray(v,1)
                if k == 1 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_LEFT) ~= 0 then
                    card:setColor(cc.c3b(170,170,170))
                elseif k == 2 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_CENTER) ~= 0 then
                    card:setColor(cc.c3b(170,170,170))
                elseif k == 3 and Bit:_and(var.cbWeaveKind,GameCommon.WIK_RIGHT) ~= 0 then
                    card:setColor(cc.c3b(170,170,170))
                else
                end
            end
        end
        content:addChild(card)
        if GameCommon.mChaoTianCard ~= 0 and GameCommon.mChaoTianCard == v then 
            local node = require("common.CircleLoadingBar"):create("newcommon/chao_left.png")
            node:setColor(cc.c3b(0,0,0))
            card:addChild(node)
            node:setPosition(42,70)
            node:start(0)  
            node:setScale(0.7)   
        end
        if k == 4 then
            card:setScale(cardScale) 
            card:setPosition(cardWidth/2+(2-1)*cardWidth,size.height/2+12)
            card:setLocalZOrder(4)  
        else
            card:setScale(cardScale) 
            card:setPosition(cardWidth/2+(k-1)*cardWidth,size.height/2)
            card:setLocalZOrder(3-k)      
        end
    end
    return content
end

function GameEndLayer:showCheng(uiListView_mingTang,mChengNum)
    local uiText_OfflineTime = ccui.Text:create("0","fonts/DFYuanW7-GB2312.ttf","24")
    uiText_OfflineTime:setName('Text_OfflineTime')
    uiText_OfflineTime:setTextColor(cc.c3b(244,216,134)) 
    uiText_OfflineTime:enableOutline(cc.c4b(226, 139, 47), 2)
    uiText_OfflineTime:setAnchorPoint(cc.p(0,0.5))
    -- item:addChild(uiText_OfflineTime,100)
    uiListView_mingTang:pushBackCustomItem(uiText_OfflineTime)
    uiText_OfflineTime:setPosition(cc.p(uiText_OfflineTime:getParent():getContentSize().width*0.1,uiText_OfflineTime:getParent():getContentSize().height/2))                
    uiText_OfflineTime:setString(string.format("撑%d次",mChengNum))         
end 

function GameEndLayer:showMingTang(uiListView_mingTang,wChiHuKind)
    --清水胡
    if Bit:_and(wChiHuKind,GameCommon.CHR_QING_YI_SE) ~= 0 then
        local item = ccui.ImageView:create("majiang/table/mingtang_qingshuihu.png")
        uiListView_mingTang:pushBackCustomItem(item)
    end
    --小七对
    if Bit:_and(wChiHuKind,GameCommon.CHK_QI_XIAO_DUI) ~= 0 then
        local item = ccui.ImageView:create("majiang/table/mingtang_qixiaodui.png")
        uiListView_mingTang:pushBackCustomItem(item)
    end
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
    require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
end

return GameEndLayer