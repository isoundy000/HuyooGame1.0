local GameCommon = require("game.paohuzi.GameCommon")
local Bit = require("common.Bit")
local StaticData = require("app.static.StaticData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local GameLogic = require("game.paohuzi.GameLogic")
local Common = require("common.Common")

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
    local csb = cc.CSLoader:createNode("GameLayerZiPai_End_1.csb")
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

    
    local uiText_xiaohao = ccui.Helper:seekWidgetByName(self.root,"Text_xiaohao")
    uiText_xiaohao:setString(string.format("本局消耗：%d",pBuffer.lGameTax))
    if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
        uiText_xiaohao:setVisible(false)
    else
        uiText_xiaohao:setVisible(true)
    end
    if CHANNEL_ID == 8 or CHANNEL_ID == 9 then 
        uiButton_look:setPosition(127,665)
        uiText_xiaohao:setPosition(992,68)
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
    if GameCommon.gameConfig.bPlayerCount == 3 then
        local uiPanel_playerInfo = ccui.Helper:seekWidgetByName(self.root,"Panel_playerInfo")
        local uiImage_player4 = ccui.Helper:seekWidgetByName(self.root,"Image_player4")
        uiImage_player4:setVisible(false)
    end 
    for key, var in pairs(GameCommon.player) do
        local viewID = GameCommon:getViewIDByChairID(var.wChairID)           
        local root = ccui.Helper:seekWidgetByName(self.root,string.format("Image_player%d",viewID))
        local uiImage_avatar = ccui.Helper:seekWidgetByName(root,"Image_avatar")        
        Common:requestUserAvatar(var.dwUserID,var.szPto,uiImage_avatar,"img") 
        local uiText_name = ccui.Helper:seekWidgetByName(root,"Text_name")
        uiText_name:setString(string.format("%s",var.szNickName)) 
        local uiText_peng = ccui.Helper:seekWidgetByName(root,"Text_peng")
        if pBuffer.lUserScore[var.wChairID+1] - pBuffer.lGameScore[var.wChairID+1] > 0 then 
            uiText_peng:setString(string.format("碰跑得分：+%s", pBuffer.lUserScore[var.wChairID+1] - pBuffer.lGameScore[var.wChairID+1] ))             
        else
            uiText_peng:setString(string.format("碰跑得分：%s", pBuffer.lUserScore[var.wChairID+1] - pBuffer.lGameScore[var.wChairID+1] )) 
        end 
        local uiText_hu = ccui.Helper:seekWidgetByName(root,"Text_hu")
        if pBuffer.lGameScore[var.wChairID+1] > 0 then 
            uiText_hu:setString(string.format("胡牌得分：+%s",pBuffer.lGameScore[var.wChairID+1])) 
        else
            uiText_hu:setString(string.format("胡牌得分：%s",pBuffer.lGameScore[var.wChairID+1])) 
        end 
      
        local uiImage_icon = ccui.Helper:seekWidgetByName(root,"Image_icon")

        if GameCommon.tableConfig.nTableType ~= TableType_GoldRoom and pBuffer.wContinueWinCount > 0 and pBuffer.lGameScore[var.wChairID+1] > 0  then        
            local lianzhuang = ccui.ImageView:create("zipai/table/lianzhuang.png")
            lianzhuang:removeAllChildren()
            root:addChild(lianzhuang)
            local bei = ccui.TextAtlas:create(string.format("%d",pBuffer.wContinueWinCount),"fonts/fonts_11.png",20,29, '0')  
            if pBuffer.wContinueWinCount == 1 then
                bei:setVisible(false)
            end
            lianzhuang:addChild(bei)
            lianzhuang:setTag(1000)
            lianzhuang:setAnchorPoint(cc.p(1,0.5))
            lianzhuang:setPosition(cc.p( 420,144))
            bei:setAnchorPoint(cc.p(1,0.5))
            bei:setPosition(cc.p(bei:getParent():getContentSize().width - 60,13))          
        end 
        local uiAtlasLabel_money = ccui.Helper:seekWidgetByName(root,"AtlasLabel_money")
        print("游戏金币",var.wChairID+1,pBuffer.lGameScore[var.wChairID+1],pBuffer.lUserScore[var.wChairID+1])         
        if pBuffer.lUserScore[var.wChairID+1]   < 0 then                   
            uiAtlasLabel_money:setProperty(string.format(".%d",pBuffer.lUserScore[var.wChairID+1]),"fonts/fonts_12.png",26,45,'.')
        else
            uiAtlasLabel_money:setProperty(string.format(".%d",pBuffer.lUserScore[var.wChairID+1]),"fonts/fonts_13.png",26,45,'.')   
        end
        if GameCommon.tableConfig.nTableType > TableType_GoldRoom then
            uiImage_icon:loadTexture("game/game_table_score.png")
        end
 
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
        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
            require("common.MsgBoxLayer"):create(2,nil,"您的金币不足,请前往商城充值!",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
        else
            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请联系会长购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
        end
    elseif data.wErrorCode == 3 then
        require("common.MsgBoxLayer"):create(0,nil,"您的金币已超过上限，请前往更高一级匹配!")
    elseif data.wErrorCode == 4 then
        require("common.MsgBoxLayer"):create(0,nil,"房间已满,稍后再试!")
    else
        require("common.MsgBoxLayer"):create(0,nil,"未知错误,请升级版本!") 
    end
end

return GameEndLayer
