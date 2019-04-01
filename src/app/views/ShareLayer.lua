local Common = require("common.Common")
local UserData = require("app.user.UserData")
local Bit = require("common.Bit")
local  HttpUrl = require("common.HttpUrl")
local ShareLayer = class("ShareLayer", cc.load("mvc").ViewBase)

function ShareLayer:onEnter()
    self.interval = 0
end

function ShareLayer:onExit()

end

function ShareLayer:onCleanup()

end

function ShareLayer:onCreate(params)
    local shareData = params[1]
    local callback = params[2]
    if shareData == nil then
        require("common.MsgBoxLayer"):create(0,nil,"分享配置错误!")
        return
    end
    dump(shareData,'-->')
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("ShareLayer.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    
    Common:addTouchEventListener(self.root,function() 
        require("common.SceneMgr"):switchTips()
    end,true)
    
    local function onEventShare(cbTargetType)
        local data = clone(shareData)
        data.cbTargetType = cbTargetType
        
        ---[[ 新聊天室
        if cbTargetType == 64 then
            if self.interval == 0 then
                self.interval = 5
                schedule(self, function()
                    self.interval = self.interval - 1
                    if self.interval <= 0 then
                        self.interval = 0
                        self:stopAllActions()
                    end
                end,1)
            else
                require("common.MsgBoxLayer"):create(0,self,self.interval .. "秒之后再操作")
                return
            end
            data.szShareUrl = string.format(HttpUrl.POST_URL_CHATRECORD, data.szGameID)
            dump(data,'=>>')
        
            local xmlHttpRequest = cc.XMLHttpRequest:new()
            xmlHttpRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
            xmlHttpRequest:setRequestHeader("Content-Type", "application/json; charset=utf-8")
            xmlHttpRequest:open("GET",data.szShareUrl)
            local function onHttpRequestCompleted()
                if xmlHttpRequest.status == 200 then
                    print('-->>>',xmlHttpRequest.response)
                    if tonumber(xmlHttpRequest.response)  == 1 then
                        require("common.MsgBoxLayer"):create(0,nil,"发送成功！")
                    else
                        require("common.MsgBoxLayer"):create(0,nil,"发送失败,错误码:" .. xmlHttpRequest.response)
                    end
                else
                    require("common.MsgBoxLayer"):create(0,nil,"发送失败！")
                end
            end
            xmlHttpRequest:registerScriptHandler(onHttpRequestCompleted)
            xmlHttpRequest:send()
            
            return
        end
        --]]

        require("common.LoadingAnimationLayer"):create(0.3)
        UserData.Share:doShare(data,function(ret) 
            -- if callback then
            --     callback(ret)
            -- end
        end)
    end
    local isInClub = shareData.isInClub;
    local uiListView_btn = ccui.Helper:seekWidgetByName(self.root,"ListView_btn")
    for i = 0, 6 do
        if Bit:_and((Bit:_rshift(shareData.cbTargetType,i)),1) == 1 then
            if i ~= 3 then
                if i==6 and (not isInClub) then--不在俱乐部不显示6

                else
                    local btnName = string.format("share/share%d.png",i)
                    local item = ccui.Button:create(btnName,btnName,btnName)
                    uiListView_btn:pushBackCustomItem(item)
                    item.cbTargetType = Bit:_lshift(1,i)
                    Common:addTouchEventListener(item,function()
                        if i == 5 then
                            if callback then
                                self:removeFromParent()
                                callback()
                            end
                        else
                            onEventShare(item.cbTargetType)
                        end
                    end)
                end
            end
        end
    end
    
    local items = uiListView_btn:getItems()
    if #items <= 0 then
        require("common.MsgBoxLayer"):create(0,nil,"分享配置错误!")
        return
    elseif #items == 1 then
        local item = items[1]
        Common:addTouchEventListener(item,onEventShare(item.cbTargetType))
    else
        local uiPanel_contents = ccui.Helper:seekWidgetByName(self.root,"Panel_contents")
        local margin = (uiPanel_contents:getContentSize().width-items[1]:getContentSize().width*#items)/(#items+1)
        uiListView_btn:refreshView()
        uiListView_btn:setItemsMargin(margin)--间距
        uiListView_btn:setContentSize(cc.size(items[1]:getContentSize().width*#items + margin*(#items-1) ,uiPanel_contents:getContentSize().height))
        uiListView_btn:setPositionX((uiPanel_contents:getContentSize().width - uiListView_btn:getContentSize().width)/2)
        
        require("common.SceneMgr"):switchTips(self)    
    end
end

return ShareLayer

