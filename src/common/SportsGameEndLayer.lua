local StaticData = require("app.static.StaticData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local UserData = require("app.user.UserData")
local Common = require("common.Common")

local SportsGameEndLayer = class("SportsGameEndLayer",function()
    return ccui.Layout:create()
end)

function SportsGameEndLayer:create(pBuffer)
    local view = SportsGameEndLayer.new()
    view:onCreate(pBuffer)
    local function onEventHandler(eventType)  
        if eventType == "enter" then  
            view:onEnter() 
        elseif eventType == "exit" then
            view:onExit() 
        end  
    end  
    view:registerScriptHandler(onEventHandler)
    return view
end

function SportsGameEndLayer:onEnter()

end

function SportsGameEndLayer:onExit()
end

function SportsGameEndLayer:onCreate(pBuffer)
    cc.Director:getInstance():getRunningScene():removeChildByTag(LAYER_TIPS)    
    self.root = nil
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("SportsGameEndLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    local uiImage_win = ccui.Helper:seekWidgetByName(self.root,"Image_win")
    local GameCommon = nil
    if pBuffer.wKindID == 42 then
        GameCommon = require("game.laopai.GameCommon")
    elseif pBuffer.wKindID == 43 then
        GameCommon = require("game.paohuzi.43.GameCommon") 
    elseif StaticData.Games[pBuffer.wKindID].type == 1 then
        GameCommon = require("game.paohuzi.GameCommon")
    elseif StaticData.Games[pBuffer.wKindID].type == 2 then
        GameCommon = require("game.puke.GameCommon")
    elseif StaticData.Games[pBuffer.wKindID].type == 3 then
        GameCommon = require("game.majiang.GameCommon")
    elseif StaticData.Games[pBuffer.wKindID].type == 4 then
        GameCommon = require("game.laopai.GameCommon")
    elseif StaticData.Games[pBuffer.wKindID].type == 5 then
        GameCommon = require("game.paohuzi.43.GameCommon")            
        return
    end
    local uiAtlasLabel_number = ccui.Helper:seekWidgetByName(self.root,"AtlasLabel_number")
    local uiPanel_bg = ccui.Helper:seekWidgetByName(self.root,"Panel_bg")

--    local viewID = GameCommon:getViewIDByChairID(pBuffer.wWinUser)
    if pBuffer.lGameScore[GameCommon:getRoleChairID()+1] > 0 then --自己胜  
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("sports/bisaishenglidonghua/bisaishenglidonghua.ExportJson")
        local armature=ccs.Armature:create("bisaishenglidonghua")
        armature:getAnimation():playWithIndex(0,-1,0)
        uiPanel_bg:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)  
        uiImage_win:loadTexture("sportsgame/sportsgame_1.png")
        uiAtlasLabel_number:setString (string.format(".%d",pBuffer.lGameScore[GameCommon:getRoleChairID()+1]))   
        
    elseif pBuffer.lGameScore[GameCommon:getRoleChairID()+1] == 0 then --平局  
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("sports/pingjudonghua/pingjudonghua.ExportJson")
        local armature=ccs.Armature:create("pingjudonghua")
        armature:getAnimation():playWithIndex(0,-1,0)
        uiPanel_bg:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)  
        uiImage_win:loadTexture("sportsgame/sportsgame_1.png")
        uiAtlasLabel_number:setString (string.format(".%d",0))   
           
    else
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("sports/bisaishibaidonghua/bisaishibaidonghua.ExportJson")
        local armature=ccs.Armature:create("bisaishibaidonghua")
        armature:getAnimation():playWithIndex(0,1,0)
        uiPanel_bg:addChild(armature)
        armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2-30)      
        uiImage_win:loadTexture("sportsgame/sportsgame_2.png")        
        uiAtlasLabel_number:setString (string.format(".%d",0))
       
    end
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_ok"),function() 
        require("common.SceneMgr"):switchScene(require("app.MyApp"):create():createView("HallLayer"),SCENE_HALL) 
    end)
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_continue"),function() 
        GameCommon:ContinueGame(GameCommon.tableConfig.dwClubID)
    end)
end
return SportsGameEndLayer