local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local NetMsgId = require("common.NetMsgId")
local NetMsgId = require("common.NetMsgId")
local NetMgr = require("common.NetMgr")
local EventMgr = require("common.EventMgr")
local EventType = require("common.EventType")
local EventType = require("common.EventType")

local ProxyDisbandedLayer = class("ProxyDisbandedLayer", cc.load("mvc").ViewBase)

function ProxyDisbandedLayer:onEnter()
    EventMgr:registListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:registListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:registListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:registListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    
    NetMgr:getLogicInstance():sendMsgToSvr(NetMsgId.MDM_CL_HALL,NetMsgId.REQ_CL_GAME_SERVER_BY_ID,"d",self.dwTableID)
end

function ProxyDisbandedLayer:onExit()
    NetMgr:getGameInstance():closeConnect()
    EventMgr:unregistListener(EventType.EVENT_TYPE_NET_RECV_MESSAGE,self,self.EVENT_TYPE_NET_RECV_MESSAGE)
    EventMgr:unregistListener(EventType.EVENT_TYPE_CONNECT_GAME_FAILED,self,self.EVENT_TYPE_CONNECT_GAME_FAILED)
    EventMgr:unregistListener(EventType.SUB_GR_LOGON_SUCCESS,self,self.SUB_GR_LOGON_SUCCESS)
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER,self,self.SUB_CL_GAME_SERVER)
    EventMgr:unregistListener(EventType.SUB_CL_GAME_SERVER_ERROR,self,self.SUB_CL_GAME_SERVER_ERROR)
    
end

function ProxyDisbandedLayer:onCreate(parames)
    self.dwTableID = parames[1]
    self.callback = parames[2]
   
end




function ProxyDisbandedLayer:EVENT_TYPE_NET_RECV_MESSAGE(event)
    local netID = event._usedata
    if netID ~= NetMgr.NET_GAME then
        return
    end
    local netInstance = NetMgr:getGameInstance()
    local mainCmdID = netInstance.cppFunc:GetMainCmdID()
    local subCmdID = netInstance.cppFunc:GetSubCmdID()
    local luaFunc = netInstance.cppFunc
    local _tagMsg = {}
    _tagMsg.mainCmdID = mainCmdID
    _tagMsg.subCmdID = subCmdID
    _tagMsg.pBuffer = {}

    if mainCmdID == NetMsgId.MDM_GR_USER and subCmdID == NetMsgId.SUB_GR_DISMISS_TABLE_SUCCESS then   
        require("common.MsgBoxLayer"):create(0,nil,"房间解散成功！") 
        NetMgr:getGameInstance():closeConnect()
        if self.callback then
            self.callback(true)
        end
        self:removeFromParent()
    end
end

function ProxyDisbandedLayer:EVENT_TYPE_CONNECT_GAME_FAILED(event)
    local data = event._usedata
    if self.callback then
        self.callback(false)
    end
    self:removeFromParent()
end


--登陆游戏成功之后发送加入桌子信息
function ProxyDisbandedLayer:SUB_GR_LOGON_SUCCESS(event)
    NetMgr:getGameInstance():sendMsgToSvr(NetMsgId.MDM_GR_USER,NetMsgId.REQ_GR_DISMISS_TABLE_BY_OWNER,"d",self.dwTableID)
end

--获取房间ip地址和端口成功
function ProxyDisbandedLayer:SUB_CL_GAME_SERVER(event)
    local data = event._usedata
    UserData.Game:sendMsgConnectGame(data)
end

function ProxyDisbandedLayer:SUB_CL_GAME_SERVER_ERROR(event)
    local data = event._usedata
    require("common.MsgBoxLayer"):create(0,nil,"该房间不存在！")   
    NetMgr:getGameInstance():closeConnect()
    if self.callback then
        self.callback(false)
    end
    self:removeFromParent()
end

return ProxyDisbandedLayer