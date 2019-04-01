local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local NetMgr = require("common.NetMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local Common = require("common.Common")
local Default = require("common.Default")

local RegionLayer = class("RegionLayer", cc.load("mvc").ViewBase)

function RegionLayer:onEnter()
end

function RegionLayer:onExit()
    if self.uiPanel_default then
        self.uiPanel_default:release()
        self.uiPanel_default = nil
    end
end

function RegionLayer:onCreate()
    cc.UserDefault:getInstance():setBoolForKey(Default.UserDefault_Guide,true)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RegionLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.csb = csb
    
    Common:addTouchEventListener(ccui.Helper:seekWidgetByName(self.root,"Button_return"),function() 
       self:removeFromParent()
    end)

    local regionID = cc.UserDefault:getInstance():getIntegerForKey(Default.UserDefault_RegionID,0)
    local uiButton_enter = ccui.Helper:seekWidgetByName(self.root,"Button_enter")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("region/diquzhizhen/jinrudiqutexiao.ExportJson")
    local armature=ccs.Armature:create("jinrudiqutexiao")
    armature:getAnimation():playWithIndex(0)
    uiButton_enter:addChild(armature)
    armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2+4)

    Common:addTouchEventListener(uiButton_enter,function() 
        local tempRegionID = uiButton_enter.regionID
        print("进入地图",tempRegionID,regionID,Default.UserDefault_RegionID)
        if tempRegionID == regionID then
            self:removeFromParent()
        else
            cc.UserDefault:getInstance():setIntegerForKey(Default.UserDefault_RegionID,tempRegionID)
            EventMgr:dispatch(EventType.EVENT_TYPE_WITH_NEW)
            self:removeFromParent() 
        end
    end)
    local uiPanel_region = ccui.Helper:seekWidgetByName(self.root,"Panel_region")
    uiPanel_region:setVisible(false)
    local uiPanel_high = ccui.Helper:seekWidgetByName(self.root,"Panel_high")
    local uiListView_regionBtn = ccui.Helper:seekWidgetByName(self.root,"ListView_regionBtn")
    local uiText_region = ccui.Helper:seekWidgetByName(self.root,"Text_region")
    local uiListView_games = ccui.Helper:seekWidgetByName(self.root,"ListView_games")
    self.uiPanel_default = ccui.Helper:seekWidgetByName(self.root,"Panel_default")
    self.uiPanel_default:retain()

    local function onEventSwitchRegion(sender,event)
        local i = sender.regionID
        --处理地区名字
        uiText_region:setString(StaticData.Regions[i].name.."地区玩法")
        uiListView_games:removeAllItems()
        --处理高亮
        uiPanel_high:removeAllChildren()
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("region/diquzhizhen/diquzhizhen.ExportJson")
        local armature=ccs.Armature:create("diquzhizhen")
        armature:getAnimation():playWithIndex(0)
        if i == 0 then
            uiPanel_region:setVisible(true)
            uiPanel_high:addChild(armature)
            armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
        else
            uiPanel_region:setVisible(false)
            local uiImage_high = ccui.Helper:seekWidgetByName(uiPanel_region,string.format("Image_high%d",i))
            local img = uiImage_high:clone()
            uiPanel_high:addChild(img)
            img:setPosition(cc.p(img:getParent():convertToNodeSpace(cc.p(uiImage_high:getParent():convertToWorldSpace(cc.p(uiImage_high:getPosition()))))))
            img:addChild(armature)
            armature:setPosition(armature:getParent():getContentSize().width/2,armature:getParent():getContentSize().height/2)
        end
        --处理选中按钮
        for index = 0, 14 do
            local uiButton_region = ccui.Helper:seekWidgetByName(uiListView_regionBtn,string.format("Button_region%d",index))
            if i == index then
                uiButton_region:setColor(cc.c3b(255,255,255))
            else
                uiButton_region:setColor(cc.c3b(100,100,100))
            end
        end
        --处理地区游戏信息
        local tableGame = {}
        local temp = Common:stringSplit(StaticData.Regions[i].games,";")
        for key, var in pairs(temp) do
            local id = tonumber(var)
            if StaticData.Games[id] ~= nil and UserData.Game.tableGames[id] ~= nil then
                table.insert(tableGame, #tableGame + 1, id)
            end
        end
        if #tableGame <= 0 then
            require("common.MsgBoxLayer"):create(0,nil,"该地区暂未开放，尽请期待！")
            uiButton_enter:setTouchEnabled(false)
            uiButton_enter:setColor(cc.c3b(100,100,100))
            return
        end
        for key, var in pairs(tableGame) do
            local item = self.uiPanel_default:clone()
            local uiText_name = ccui.Helper:seekWidgetByName(item,"Text_name")
            uiText_name:setString(string.format("-%s",StaticData.Games[var].name))
            uiText_name:setTextColor(cc.c3b(233,203,242))
            uiListView_games:pushBackCustomItem(item)
        end
        uiButton_enter:setTouchEnabled(true)
        uiButton_enter:setColor(cc.c3b(255,255,255))
        uiButton_enter.regionID = i
        print("地区显示",uiButton_enter.regionID)
    end
    for i = 0 , 14 do
        local uiButton_region = ccui.Helper:seekWidgetByName(uiListView_regionBtn,string.format("Button_region%d",i))
        uiButton_region.regionID = i
        Common:addTouchEventListener(uiButton_region,function() onEventSwitchRegion(uiButton_region) end)
    end

    local uiButton_region = ccui.Helper:seekWidgetByName(uiListView_regionBtn,string.format("Button_region%d",regionID))
    onEventSwitchRegion(uiButton_region)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(sender,event)
        --位置刷新
        uiListView_regionBtn:refreshView()
        local container = uiListView_regionBtn:getInnerContainer()
        local pos = cc.p(uiButton_region:getPosition())
        pos = cc.p(uiButton_region:getParent():convertToWorldSpace(pos))
        pos = cc.p(container:convertToNodeSpace(pos))
        local value = (1-pos.y/container:getContentSize().height)*100
        uiListView_regionBtn:scrollToPercentVertical(value,1,true)
    end)))
end

return RegionLayer