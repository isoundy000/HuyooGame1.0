local GameCommon = require("game.laopai.GameCommon")
local Bit = require("common.Bit")
local StaticData = require("app.static.StaticData")
local GameLogic = require("game.laopai.GameLogic")
local Common = require("common.Common")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
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

end

function GameEndLayer:onExit()
    
end

function GameEndLayer:onCleanup()

end

function GameEndLayer:onCreate(pBuffer)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("GameLayerlaopai_End.csb")
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
    if  GameCommon.serverData.cbRoomFriend == -1 then 
        uiButton_return:setVisible(true)
    else 
        uiButton_return:setVisible(false)
    end 
    local uiButton_continue = ccui.Helper:seekWidgetByName(self.root,"Button_continue")
    uiButton_continue:setPressedActionEnabled(true)
    if  GameCommon.serverData.cbRoomFriend ~= -1 then 
        uiButton_continue:setVisible(true)
    else 
        uiButton_continue:setVisible(false)
    end 
    local function onEventContinue(sender,event)
        if event == ccui.TouchEventType.ended then
            Common:palyButton()
            if GameCommon.isFriendsGame == true then
                if GameCommon.friendsRoomInfo.wTableNumber == GameCommon.friendsRoomInfo.wCurrentNumber then
                    EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
                    
                else
                   -- EventMgr:dispatch(EventType.GAMEVIEWMSG,GameCommon.GameView_endMsg)
                    GameCommon:ContinueGame()
                end
            else 
                GameCommon:ContinueGame()
            end
        end
    end
    uiButton_continue:addTouchEventListener(onEventContinue)

    local visibleSize = cc.Director:getInstance():getVisibleSize()
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
    print ("单位游戏币2:",GameCommon.number_dwHorse.fanbei)
    if GameCommon.number_dwHorse.fanbei == nil then
        uiText_info:setVisible(false)
    else
        uiText_info:setString(string.format("分数翻倍 %d",GameCommon.number_dwHorse.fanbei))   
    end
   
    local uiListView_player = ccui.Helper:seekWidgetByName(self.root,"ListView_player")
    local uiPanel_itemWin = ccui.Helper:seekWidgetByName(self.root,"Panel_itemWin")
    uiPanel_itemWin:retain()
    uiListView_player:removeAllItems()
    --赢家
    local index = 0
    for i = 1,4 do    
        local var = GameCommon.tagUserInfoList[i]
        local wChairID = GameCommon.tagUserInfoList[i].wChairID
        local viewID = GameCommon:SwitchViewChairID(var.wChairID) + 1  --控制显示自己              
        local uiImage_result = ccui.Helper:seekWidgetByName(self.root,"Image_biaoti")
        print("谁赢了",pBuffer.wWinner[1],pBuffer.wWinner[2],pBuffer.wWinner[3],pBuffer.wWinner[4],viewID)   
        local item = uiPanel_itemWin:clone()
        local textureName = nil
        if viewID == 1 then 
            textureName = "common/common_end1.png" 
        else 
            textureName = "common/common_end2.png"    
        end 
        local texture = cc.Director:getInstance():getTextureCache():addImage(textureName)
        uiImage_result:loadTexture(textureName)
        uiImage_result:setContentSize(texture:getContentSizeInPixels())   
        
                
        local tou = ccui.Helper:seekWidgetByName(item,"Image_avatar")
        Common:requestUserAvatar(GameCommon.tagUserInfoList[i].dwUserID,GameCommon.tagUserInfoList[i].szPto,tou,"img")
        local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
        uiText_name:setString(string.format("%s",GameCommon.tagUserInfoList[i].szNickName))
        uiText_name:setTextColor(cc.c3b(255,255,255))
        local uiImage_banker = ccui.Helper:seekWidgetByName(item,"Image_banker")
        if i == GameCommon.wBankerUser + 1 then
            uiImage_banker:setVisible(true)
        else
            uiImage_banker:setVisible(false)
        end

        -- 游戏冲分与箍丑
        local uiImage_chongfen = ccui.Helper:seekWidgetByName(item,"Image_chongfen")
        local uiImage_guchou = ccui.Helper:seekWidgetByName(item,"Image_guchou")
        if  pBuffer.wGameHorseCount[i] == 0 then
            uiImage_chongfen:setVisible(true)
            uiImage_chongfen:loadTexture("laopai/table/laopai_table8.png")
        else
            uiImage_chongfen:setVisible(true)
            uiImage_chongfen:loadTexture(string.format("laopai/table/laopai_table%s.png",pBuffer.wGameHorseCount[i]+4))
        end
        print("结算箍丑玩家",i,pBuffer.bGuChou[i])
        if pBuffer.bGuChou[i] == 1 then
            pBuffer.cbCardCount[i] = 16
            uiImage_guchou:setVisible(true)
        else
            uiImage_guchou:setVisible(false)
        end 
        --输赢            
        local uiImage_winType = ccui.Helper:seekWidgetByName(item,"Image_winType")
        local textureName = "laopai/endlayer/end_hupai.png"
        if pBuffer.wWinner[i] == true then 
            --胡牌
            local textureName = "laopai/endlayer/end_hupai.png"
            if pBuffer.wWinner[pBuffer.wProvideUser+1] == true then               
                textureName = "laopai/endlayer/end_huzimo.png"             
            end
            uiImage_winType:setVisible(true)
        else 
            textureName = "laopai/endlayer/end_fangpao.png"
            --放炮
            if i == pBuffer.wProvideUser + 1 then
                uiImage_winType:setVisible(true)
            else
                uiImage_winType:setVisible(false)
            end                
        end 
        -- 图片大小配对 
        local texture = cc.TextureCache:getInstance():addImage(textureName)
        uiImage_winType:loadTexture(textureName)
        uiImage_winType:setContentSize(texture:getContentSizeInPixels())      

        local uiAtlasLabel_score1 = ccui.Helper:seekWidgetByName(item,"AtlasLabel_score1")
        local uiAtlasLabel_score2 = ccui.Helper:seekWidgetByName(item,"AtlasLabel_score2")
        print ("玩家结算积分：",i,pBuffer.lGameScore[i])
        if pBuffer.lGameScore[i] < 0 then       
            uiAtlasLabel_score1:setVisible(false)
            uiAtlasLabel_score2:setString(string.format(".%d",pBuffer.lGameScore[i]))                    
        elseif  pBuffer.lGameScore[i] > 0 then
            uiAtlasLabel_score1:setString(string.format(".%d",pBuffer.lGameScore[i]))
            uiAtlasLabel_score2:setVisible(false)
        else
            uiAtlasLabel_score1:setString(string.format(".%d",pBuffer.lGameScore[i]))
            uiAtlasLabel_score2:setVisible(false)
            --uiAtlasLabel_score:setString(string.format(".%d",pBuffer.lGameScore[i]))
        end                                     


        local uiListView_card = ccui.Helper:seekWidgetByName(item,"ListView_card") 
       
        --桌面牌
        local pox = 0
        for j = 1 , pBuffer.cbWeaveItemCount[i] do
            local _CardData = pBuffer.WeaveItemArray[i][j].cbCenterCard
            local addCard = {}
            for x=1 , 3 do
                addCard[x] = 0
            end
            local addCardCout = 0
            if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_PENG then
                addCardCout = 3
                addCard[1] = _CardData
                addCard[2] = _CardData
                addCard[3] = _CardData
            end
            if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_LEFT then
                addCardCout = 3
                addCard[1] = _CardData
                addCard[2] = _CardData + 1
                addCard[3] = _CardData + 2
            end
            if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_CENTER then
                addCardCout = 3
                addCard[1] = _CardData +1
                addCard[2] = _CardData
                addCard[3] = _CardData -1
            end
            if pBuffer.WeaveItemArray[i][j].cbWeaveKind == GameCommon.WIK_RIGHT then
                addCardCout = 3
                addCard[1] = _CardData
                addCard[2] = _CardData - 1
                addCard[3] = _CardData - 2
            end
            for tempCout = 1 , addCardCout do
                local spt = GameCommon:GetCardHand(addCard[tempCout])
                spt:setAnchorPoint(cc.p(0,0))
                if pBuffer.wWinner[i] == false then 
                    spt:setPosition((pox*1.0+(tempCout-1))*35,0)
                else
                    spt:setPosition((pox*1.1+(tempCout-1))*35,0)
                end                   
                spt:setScale(0.36,0.2)
                uiListView_card:addChild(spt)
            end
            pox = pox + 3
        end           
        -- 手牌    
        local isshow = false
        if pBuffer.cbCardCount[i] > 17 then 
           pBuffer.cbCardCount[i] = 16
        end
        print("玩家手牌数：",pBuffer.cbCardCount[1],pBuffer.cbCardCount[2],pBuffer.cbCardCount[3],pBuffer.cbCardCount[4])
        for j = 1 , pBuffer.cbCardCount[i] do
            local spt = GameCommon:GetCardHand(pBuffer.cbCardData[i][j])
            spt:setScale(0.36,0.2)
            spt:setAnchorPoint(cc.p(0,0))            
            if pBuffer.cbCardData[i][j] == pBuffer.cbChiHuCard[i] and isshow==false then
                isshow = true
                spt:setPosition((18)*35,0)
                pox = pox -1
            else
                if pBuffer.wWinner[i] == false then 
                    spt:setPosition((j-1+pox*1)*35,0)
                else
                    if j > 3 then 
                        spt:setPosition((j-1+pox*1.1+0.3)*35,0)
                    elseif j > 6 then  
                        spt:setPosition((j-1+pox*1.1+0.6)*35,0)
                    elseif j > 9 then
                        spt:setPosition((j-1+pox*1.1+0.9)*35,0)
                    elseif j > 12 then
                        spt:setPosition((j-1+pox*1.1+1.2)*35,0)
                    elseif j > 15 then
                        spt:setPosition((j-1+pox*1.1+1.5)*35,0)
                    else
                        spt:setPosition((j-1+pox*1.1)*35,0)
                    end
                end                  
            end
            uiListView_card:addChild(spt)
        end         
        uiListView_player:pushBackCustomItem(item)                
    end

end

return GameEndLayer
