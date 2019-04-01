local Bit = require("common.Bit")
local Common = require("common.Common")
local Net = require("common.Net")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventMgr = require("common.EventMgr")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local HttpUrl = require("common.HttpUrl")
local Default = require("common.Default")

UserData.User:setLoginParameter()

local GuideLayer = class("GuideLayer", cc.load("mvc").ViewBase)

function GuideLayer:onEnter()

end

function GuideLayer:onExit()

end

function GuideLayer:onCreate(parames)
    local pos = parames[1]
    local layerColor = cc.LayerColor:create(cc.c4b(0,0,0,110)) --创建一个遮罩层,还是强调一下:第一个参数是颜色ccc4(r,g,b,a) a取值(0~255),越大越不透明
    self:addChild(layerColor)
    
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("hall_1/xinshoudonghua/xinshoudonghua.ExportJson")
    local armature=ccs.Armature:create("xinshoudonghua")
    armature:getAnimation():playWithIndex(0)
    self:addChild(armature)
    armature:setPosition(pos)

--    --创建剪裁节点
--    local pClip = cc.ClippingNode:create()
--    pClip:setInverted(true)--设置是否反向，将决定画出来的圆是透明的还是黑色的
--    self:addChild(pClip)
--    pClip:addChild(layerColor)--注意将LayerColor层添加到剪裁节点上
--    
--    --绘制圆形区域
--    --设置参数
--    local red = cc.c4b(1,0,0,1)--顶点颜色设置为红色，参数是R,G,B,透明度
--    local radius=55.0--设置圆的半径
--    local nCount=200--设置顶点数，此处我们将圆看成200边型
--    local angel=2.0 * math.pi/nCount--两个顶点与中心的夹角（弧度）
--    local circle = {}  --保存顶点的数组
--    for i=1, nCount do
--        local radian=i*angel --弧度
--        circle[i] = {}
--        circle[i].x=radius * math.cos(radian)--顶点x坐标
--        circle[i].y=radius * math.sin(radian)--顶点y坐标
--    end
--    --绘制多边形
--    --注意不要将pStencil addChild
--    local pStencil= cc.DrawNode:create()
--    pStencil:drawPolygon(circle, nCount, red, 0, red)--绘制这个多边形
-- 
--    --给圆添加一个放大缩小动作
--    pStencil:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleBy:create(0.5, 0.95),cc.ScaleTo:create(0.5, 1))))
--    pStencil:setPosition(pos)
--    --将这个圆形从剪裁节点上面抠出来，Stencil是模板的意思
--    pClip:setStencil(pStencil)
--    
--    
--    local sCircle = cc.Sprite:create("guide/guide_1.png")
--    sCircle:setPosition(pos)
--    sCircle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleBy:create(0.5, 0.95),cc.ScaleTo:create(0.5, 1))))
--    self:addChild(sCircle)
--    local texture = cc.TextureCache:getInstance():addImage("guide/guide_2.png")
--    local make = cc.Sprite:create("guide/guide_2.png")
--    if pos.x - radius - texture:getPixelsWide() / 2 < 0 then 
--        make:setFlippedX(true)
--        make:setPosition(cc.p(pos.x + radius + texture:getPixelsWide() / 2,pos.y))
--    else
--        make:setPosition(cc.p(pos.x - radius - texture:getPixelsWide() / 2,pos.y))
--    end
--    make:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(5, 0)),cc.MoveBy:create(0.5, cc.p( -5, 0)))))
--    self:addChild(make)
    local clippingRect = cc.rect(pos.x - 125 ,pos.y - 30,125 * 2, 30 * 2)
    local function onTouchBegan(touch , event)
        local point = cc.p(touch:getLocation()) 
        point = cc.p(self:convertToWorldSpace(point))
        --判断是否在裁剪矩形内  
        if cc.rectContainsPoint(clippingRect,point) then
            return false
        end
        return true
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener,self) 
end


return GuideLayer

