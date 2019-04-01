local HttpUrl = {
    POST_URL_StandbyServer = "http://download.hy.qilaigame.com/standbyservernew.json", --备用服务器列表
    POST_URL_GameUserInfo =  "https://graph.qq.com/user/get_user_info?access_token=%s&oauth_consumer_key=%s&openid=%s",
    POST_URL_GameUserSns =  "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s",                      
    POST_URL_GameUserAuth =  "https://api.weixin.qq.com/sns/auth?access_token=%s&openid=%s",                           
    POST_URL_GameUserToken = "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s",                        
    POST_URL_GameUserOauth = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code", 
    POST_URL_GameUserOrder = "http://pay.hy.qilaigame.com/Pay/CreateOrder.aspx",
    
    POST_URL_GameUserSociety = "http://pay.hy.qilaigame.com/api/Sociaty/GetSociatyByUserID?userid=%s",                  --获取公会信息
    POST_URL_GameUserApplyToJoin ="http://pay.hy.qilaigame.com/api/Sociaty/GetAddMember?userId=%s&sociatyId=%s",        --申请加入公会
    POST_URL_GameUserModify ="http://pay.hy.qilaigame.com/api/Sociaty/UpdateSociatyNotice",  --修改公告
    POST_URL_GuildInformation ="http://pay.hy.qilaigame.com/api/Sociaty/GetSociatyByAgentID?agentID=%s",              --查看公会
    POST_URL_GameUserLocation = "http://restapi.amap.com/v3/ip?output=JSON&key=ff5a4b284dcd748d8e57f3736dc42b16", --高德地图IP定位
    POST_URL_phoneMsg = "http://pay.hy.qilaigame.com/api/Sociaty/GetPhoneVerifica?phoneNum=%s&channelID=%d",                         --手机号码修改

    POST_URL_WhetherToSignUp = "http://pay.hy.qilaigame.com/api/Sociaty/GetIsMatch?sociatyID=%s",                                                    --判断该公会是否报错活动
    POST_URL_ToSignUp = "http://pay.hy.qilaigame.com/api/Sociaty/GetSignSociatyActive?sociatyID=%s",                                                    --公会报名参数活动
    POST_URL_RankingInformation = "http://pay.hy.qilaigame.com/api/Sociaty/GetSociatyRanking?sociatyID=%s&userId=%s",                                                    --获取公会排行榜     
    POST_URL_RankingInformation1 = "http://pay.hy.qilaigame.com/api/Sociaty/GetScoreRanking?userId=%s",     
    POST_URL_ActivityInvite = "http://pay.hy.qilaigame.com/api/Sociaty/GetShareFriendInfo?userId=%d",      
    POST_URL_ActivityInviteBind = "http://pay.hy.qilaigame.com/api/Sociaty/GetAddShareFriend?userID=%d&friendUserID=%s",
    POST_URL_ActivityInviteRedPack = "http://pay.hy.qilaigame.com/api/Sociaty/GetRedPack?userId=%d&channelID=%d",                                         --获取公会排行榜 
    POST_URL_GetPayRank = "http://pay.hy.qilaigame.com/api/Sociaty/GetPayRanking?userId=%s&channelID=%s",                                                                --获取土豪排行榜
    POST_URL_ReportSubmit ="http://pay.hy.qilaigame.com/api/Sociaty/ReportSubmit",                                                                    --举报
    POST_URL_GetIsPay365 ="http://pay.hy.qilaigame.com/api/Sociaty/GetIsPay365?userId=%s",        --申请加入公会
    POST_URL_ChatRoom = "share.hy.qilaigame.com/RegUser/ChatRoom?userID=%d&clubID=%d&appname=%s&isRegister=1",--聊天室
    POST_URL_ChatRoomShare = "http://share.hy.qilaigame.com/Group/SendMsg",  --聊天室分享
    POST_URL_ClubStatistics = "http://agent.qilaigame.com/Club/frmClubGameCount.html?ClubID=%d&UserID=%d",
    POST_URL_ClubStatisticsScore = "http://agent.qilaigame.com/Club/frmClubGameCountScore.html?ClubID=%d&UserID=%d",
    POST_URL_GetGameIpAddr = "http://pv.sohu.com/cityjson?ie=utf-8",
    POST_URL_CHATRECORD = 'http://share.hy.qilaigame.com/nim/fight?fid=%s',
}

return HttpUrl

