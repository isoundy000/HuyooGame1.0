local Bit = require("common.Bit")

local GameDesc = {}

function GameDesc:getGameDesc(wKindID,data,tableConfig)
    local desc = ""
	if wKindID == 45 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bWuTong == 0 then
            desc = desc.."/没有筒子"
        end 
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        elseif data.bMaType == 6 then
            desc = desc.."/翻几奖几"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        else

        end
        if data.bNiaoType == 1 then
            desc = desc.."/一马一分"
        elseif data.bNiaoType == 2 then
            desc = desc.."/一马两分"
        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bQingSH == 1 then
            desc = desc.."/清水胡"
        end
        -- if data.bQiDui == 1 then
        --     desc = desc.."/七对"
        -- end
    elseif wKindID == 42 then     
--        if data.bChongFen == 1 then
--            desc = desc.."冲分/"
--        else
--            desc = desc.."不冲分/"
--        end
--        if data.bFanBei == 0 then
--            desc = desc.."不翻倍"
--        else
--            desc = desc..string.format("%d倍",data.bFanBei)
--        end
        if data.mailiao == 1 then    --冲分
            desc = "冲分"
        elseif data.mailiao == 0 then
            desc = "不冲分"
        else
        end             
        if data.fanbei == 1 then
            desc = desc.."/一倍"
        elseif data.fanbei == 2 then
            desc = desc.."/两倍"
        elseif data.fanbei == 4 then
            desc = desc.."/四倍"
        else
        end
        if data.jiabei == 1 then
            desc = desc.."/带庄(加一底)"
        else
        end
        if data.zimo == 1 then
            desc = desc.."/只准自摸"
        else                
        end  
        if data.piaohua == 1 then 
            desc = desc.."/有飘花"
        elseif data.piaohua == 0 then 
            desc = desc.."/无飘花"
        else
        end
        
    elseif wKindID == 43 then   
        if data.bChongFen == 1 then
            desc = desc.."冲分/"
        else
            desc = desc.."不冲分/"
        end
        if data.bFanBei == 0 then
            desc = desc.."不翻倍"
        else
            desc = desc..string.format("%d倍",data.bFanBei)
        end
        
    elseif wKindID == 46 then       
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bWuTong == 0 then
            desc = desc.."/没有筒子"
        end 
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        else

        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.mNiaoType == 1 then
            desc = desc.."/一鸟一分"
        end
        if data.bQiDui == 1 then
            desc = desc.."/七对"
        end
    elseif wKindID == 61 then       
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        else

        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bQingSH == 1 then
            desc = desc.."/清水胡"
        end
    elseif wKindID == 52 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bHuQD == 1 then
            desc = desc.."/七小对"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个鸟"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个鸟"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个鸟"
        else
            dese = desc.."不扎鸟"
        end  
    
    elseif wKindID == 50 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end

        if data.bNiaoAdd == 1 then
            desc = desc.."/中鸟加分"
        elseif data.bNiaoAdd == 2 then
            desc = desc.."/中鸟翻倍"
        else
        end
        if data.mNiaoCount == 1 then
            desc = desc.."/1个鸟"
        elseif data.mNiaoCount == 2 then
            desc = desc.."/2个鸟"
        elseif data.mNiaoCount == 4 then
            desc = desc.."/4个鸟"
        elseif data.mNiaoCount == 6 then
            desc = desc.."/6个鸟"
        else
        end
        if data.mMaOne == 1 then
            desc = desc.."/一鸟一分"
        elseif data.mMaOne == 2 then
            desc = desc.."/一鸟两分"
        end
        if data.bMQFlag == 1 then
            desc = desc.."/门清"
        end
        if data.mZXFlag == 1 then
            desc = desc.."/庄闲(算分)"
        end
        if data.bJJHFlag == 1 then
            desc = desc.."/假将胡"
        end
        if data.mPFFlag == 1 then
            desc = desc.."/漂分"
        end
        -- desc = desc.."\n"
        if data.bLLSFlag == 1 then
            desc = desc.."/六六顺"
        end
        if data.bQYSFlag == 1 then
            desc = desc.."/缺一色"
        end
        if data.bWJHFlag == 1 then
            desc = desc.."/无将胡"
        end
        if data.bDSXFlag == 1 then
            desc = desc.."/大四喜"
        end
        if data.mZTSXlag == 1 then
            desc = desc.."/中途四喜"
        end
        if data.bBBGFlag == 1 then
            desc = desc.."/步步高"
        end
        if data.bSTFlag == 1 then
            desc = desc.."/三同"
        end
        if data.bYZHFlag == 1 then
            desc = desc.."/一枝花"
        end

        if data.bWuTong == 0 then
            desc = desc.."/去掉筒子"
        end

    elseif wKindID == 70 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end

        if data.bNiaoAdd == 1 then
            desc = desc.."/中鸟加分"
        elseif data.bNiaoAdd == 2 then
            desc = desc.."/中鸟翻倍"
        else
        end
        if data.mNiaoCount == 1 then
            desc = desc.."/1个鸟"
        elseif data.mNiaoCount == 2 then
            desc = desc.."/2个鸟"
        elseif data.mNiaoCount == 4 then
            desc = desc.."/4个鸟"
        elseif data.mNiaoCount == 6 then
            desc = desc.."/6个鸟"
        else
        end
        if data.mKGNPFlag == 2 then
            desc = desc.."/开杠两张牌"
        elseif data.mKGNPFlag == 4 then
            desc = desc.."/开杠四张牌"
        elseif data.mKGNPFlag == 6 then
            desc = desc.."/开杠六张牌"
        else
        end
        if data.mMaOne == 1 then
            desc = desc.."/一鸟一分"
        elseif data.mMaOne == 2 then
            desc = desc.."/一鸟两分"
        end
        if data.bMQFlag == 1 then
            desc = desc.."/门清"
        end
        if data.mZXFlag == 1 then
            desc = desc.."/庄闲(算分)"
        end
        if data.bJJHFlag == 1 then
            desc = desc.."/假将胡"
        end
        if data.mPFFlag == 1 then
            desc = desc.."/漂分"
        end
        -- desc = desc.."\n"
        if data.bLLSFlag == 1 then
            desc = desc.."/六六顺"
        end
        if data.mZTLLSFlag == 1 then
            desc = desc.."/中途六六顺"
        end
        if data.bQYSFlag == 1 then
            desc = desc.."/缺一色"
        end
        if data.bWJHFlag == 1 then
            desc = desc.."/无将胡"
        end
        if data.bDSXFlag == 1 then
            desc = desc.."/大四喜"
        end
        if data.mZTSXlag == 1 then
            desc = desc.."/中途四喜"
        end
        if data.bBBGFlag == 1 then
            desc = desc.."/步步高"
        end
        if data.bSTFlag == 1 then
            desc = desc.."/三同"
        end
        if data.bYZHFlag == 1 then
            desc = desc.."/一枝花"
        end

        if data.bWuTong == 0 then
            desc = desc.."/去掉筒子"
        end
        
    elseif wKindID == 16 then           
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bSuccessive == 0 then
            desc = desc.."/二连"
        elseif data.bSuccessive == 1 then 
            desc = desc.."/无限连庄"
        end
        
        if data.bQiangHuPai == 1 then
            desc = desc.."/必胡"
        end
        if data.bLianZhuangSocre == 0 then
            desc = desc.."/加一倍"
        elseif data.bLianZhuangSocre == 1 then 
            desc = desc.."/翻倍*2"
        end  
        
    elseif wKindID == 17 or wKindID == 18 or wKindID == 19 or wKindID == 20 then           
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bTotalHuXi == 100  then
            desc = desc.."/总胡息100"
        elseif data.bTotalHuXi == 200  then 
            desc = desc.."/总胡息200"
        end 
        
        if data.bMaxLost == 200  then
            desc = desc.."/上限200胡息"
        elseif data.bTotalHuXi == 400  then 
            desc = desc.."/上限400胡息"
        else
            desc = desc.."/无上限"
        end 
                            
    elseif wKindID == 24 then      
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."2人房"
            if data.bDeathCard == 1 then
                desc = desc.."/亡牌"
            end
        end
        if data.bYiWuShi == 1 then
            desc = desc.."/有一五十"
        end  
        if data.bHuType == 1 then
            desc = desc.."/必胡"
        end
        if data.FanXing.bType == 1 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if data.bPiaoHu == 1 then
            desc = desc.."/飘胡"
        end
        if data.bHongHu == 1 then
            desc = desc.."/多红多息"
        end 
        if Bit:_and(data.dwMingTang,0x0D00) ~= 0 then
            desc = desc.."/天地海底胡"
        end 
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/自摸翻倍"
        end
        if Bit:_and(data.dwMingTang,0x02) ~= 0 then
            desc = desc.."/红黑点胡"
        end
        if data.bStartTun == 1 then
            desc = desc.."/带一底"
        elseif data.bStartTun == 2 then
            desc = desc.."/带两底"
        elseif data.bStartTun == 3 then
            desc = desc.."/带三底"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end 
    elseif wKindID == 27 then 
        if data.bLaiZiCount == 0 then
            desc = "无王"
        elseif data.bLaiZiCount == 1 then
            desc = "单王"
        elseif data.bLaiZiCount == 2 then
            desc = "双王"
        else
        end           
        if data.bPlayerCount == 2 then
            desc = desc.."/双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."/3人房"
        elseif data.bPlayerCount == 4 then
            desc = desc.."/4人房"
        end
        if data.FanXing.bType == 1 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟省"
        else
            desc = desc.."/不翻省"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一省三囤"
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/一省一囤"
        else                
        end      
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 34 then 
        if data.bLaiZiCount == 0 then
            desc = "无王"
        elseif data.bLaiZiCount == 1 then
            desc = "单王"
        elseif data.bLaiZiCount == 2 then
            desc = "双王"
        else
        end             
        if data.bPlayerCount == 3 then
            desc = desc.."/3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."/2人房"
        else
            desc = desc.."/4人房"
        end
        if data.FanXing.bType == 1 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟省"
        else
            desc = desc.."/不翻省"
        end
        if data.FanXing.bType ~= 0 then 
            if data.bDouble == 1 then
                desc = desc.."/双省"
            else
                desc = desc.."/单省"
            end
        end 
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一省三囤"
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/一省一囤"
        else                
        end      
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
    
    elseif wKindID == 32 then       
        if data.bLaiZiCount == 1 then
            desc = desc.."单王"
        elseif data.bLaiZiCount == 2 then
            desc = desc.."双王"
        elseif data.bLaiZiCount == 3 then
            desc = desc.."三王"
        elseif data.bLaiZiCount == 4 then
            desc = desc.."四王"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡"
        elseif data.bCanHuXi == 4 then
            desc = desc.."/18胡"
        elseif data.bCanHuXi == 2 then
            desc = desc.."/21胡"
        end
        if data.FanXing.bType == 1 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟省"
        else
            desc = desc.."/不翻省"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一省三囤"
        elseif data.FanXing.bAddTun == 2 then
            desc = desc.."/双省"
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/单省"
        else                
        end  
        if data.bLaiZiCount == 4 then 
            if data.bLimit == 1 then
                desc = desc.."/按番限胡"
            elseif data.bLimit == 2 then
                desc = desc.."/按王限胡"
            end
        end
        if Bit:_and(data.dwMingTang,0x8) ~= 0 then
            desc = desc.."/红转点"
        end
        if Bit:_and(data.dwMingTang,0x10) ~= 0 then
            desc = desc.."/红转黑"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/带底"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
           
    elseif wKindID == 37 or wKindID == 33 or wKindID == 35 or wKindID == 36 then       
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 4 then
            desc = desc.."4人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        end
        desc = desc..string.format("/%d胡起胡",data.bCanHuXi) 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟省"
        else
            desc = desc.."/不翻省"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一省三囤"
        elseif data.FanXing.bAddTun == 2 then
            desc = desc.."/双省"
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/单省"
        else                
        end  
        if data.bLaiZiCount == 4 then 
            if data.bLimit == 1 then
                desc = desc.."/按番限胡"
            elseif data.bLimit == 2 then
                desc = desc.."/按王限胡"
            end
        end
        if Bit:_and(data.dwMingTang,0x8) ~= 0 then
            desc = desc.."/红转点"
        end
        if Bit:_and(data.dwMingTang,0x10) ~= 0 then
            desc = desc.."/红转黑"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/带底"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 31 then   
        if data.bLaiZiCount == 1 then
            desc = desc.."单王"
        elseif data.bLaiZiCount == 2 then
            desc = desc.."双王"
        elseif data.bLaiZiCount == 3 then
            desc = desc.."三王"
        elseif data.bLaiZiCount == 4 then
            desc = desc.."四王"
        end    
        if data.bPlayerCount == 3 then
            desc = desc.."/3人房"
        elseif data.bPlayerCount == 4 then
            desc = desc.."/4人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."/双人竞技"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息"
        else                
        end 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻省"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟省"
        else
            desc = desc.."/不翻省"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一省三囤"
        elseif data.FanXing.bAddTun == 2 then
            desc = desc.."/双省"
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/单省"
        else                
        end  
        if data.bLaiZiCount == 4 then 
            if data.bLimit == 1 then
                desc = desc.."/按番限胡"
            elseif data.bLimit == 2 then
                desc = desc.."/按王限胡"
            end
        end
        if Bit:_and(data.dwMingTang,0x8) ~= 0 then
            desc = desc.."/红转点"
        end
        if Bit:_and(data.dwMingTang,0x10) ~= 0 then
            desc = desc.."/红转黑"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/带底"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
    
    elseif wKindID == 38 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bYiWuShi == 1 then
            desc = desc.."/有一五十"
        end  
        if data.bStartTun == 2 then
            desc = desc.."/带底"
        end
        if data.bSettlement == 1 then
            desc = desc.."/三胡一囤"
        else            
            desc = desc.."/一胡一囤"
        end 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一垛三囤"    
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/一垛一囤" 
        else
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/自摸翻倍"
        end
        if Bit:_and(data.dwMingTang,0x02) ~= 0 then
            desc = desc.."/红黑点胡"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 40 then         
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bYiWuShi == 1 then
            desc = desc.."/有一五十"
        end  
        if data.bFangPao == 1 then
            desc = desc.."/明偎" 
        else            
            desc = desc.."/暗偎"
        end 
        if data.bStartTun == 2 then
            desc = desc.."/带底"
        end
        if data.bSettlement == 1 then
            desc = desc.."/三胡一囤"
        else            
            desc = desc.."/一胡一囤"
        end 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if data.FanXing.bAddTun == 3 then
            desc = desc.."/一垛三囤"   
        elseif data.FanXing.bAddTun == 1 then
            desc = desc.."/一垛一囤"
        else
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/自摸翻倍"
        end
        if Bit:_and(data.dwMingTang,0x02) ~= 0 then
            desc = desc.."/红黑点胡"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 22 then       
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bYiWuShi == 1 then
            desc = desc.."/有一五十"
        end  
        if data.bFangPao == 1 then
            desc = desc.."/明偎" 
        else            
            desc = desc.."/暗偎"
        end 
        print("选择分数1",self.bSettlement)
        if data.bSettlement == 2 then
            desc = desc.."/一息一分" 
        else            
            desc = desc.."/三息一分"
        end 
        if data.bStartTun == 2 then
            desc = desc.."/带底"
        end
        if data.bHuType == 2 then
            desc = desc.."/放炮必胡" 
        end 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/自摸翻倍"
        end
        if Bit:_and(data.dwMingTang,0x02) ~= 0 then
            desc = desc.."/红黑点胡"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 23 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."4人房"
        end
        if data.bYiWuShi == 1 then
            desc = desc.."/有一五十"
        end  
        if data.bFangPao == 1 then
            desc = desc.."/明偎" 
        else            
            desc = desc.."/暗偎"
        end 
        if data.bStartTun == 2 then
            desc = desc.."/带底"
        end
        if data.bHuType == 2 then
            desc = desc.."/放炮必胡" 
        end 
        if data.FanXing.bType == 1 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 2 then
            desc = desc.."/翻垛"
        elseif data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/自摸翻倍"
        end
        if Bit:_and(data.dwMingTang,0x02) ~= 0 then
            desc = desc.."/红黑点胡"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end
        
    elseif wKindID == 44 then       
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."2人PK"		
            if data.bDeathCard == 1 then
                desc = desc.."/去牌"
            elseif data.bDeathCard == 0 then
                desc = desc.."/不去牌"
            end
        else
            desc = desc.."4人PK(坐醒)"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息起胡"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息起胡"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息起胡"
        end
        if Bit:_and(data.dwMingTang,0x01) ~= 0 then
            desc = desc.."/15胡带名堂可自摸"
        end

        
     elseif wKindID == 39 then       
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."2人PK(21起胡)"
        end
        if data.FanXing.bType == 3 then
            desc = desc.."/跟垛"
        else
            desc = desc.."/无垛"
        end
        if Bit:_and(data.dwMingTang,0x08) ~= 0 then
            desc = desc.."/一点红"
        end
        if data.bFangPao == 1 then
            desc = desc.."/有冲招"
        else
            desc = desc.."/无冲招"
        end
        if data.bHuType == 1 then
            desc = desc.."/强制胡牌"
        end
        if data.bCanHuXi == 0 then
            desc = desc.."/无胡"
        end
        
    elseif wKindID == 47 then       
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 4 then
            desc = desc.."4人坐省"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息起胡"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息起胡"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息起胡"
        end
        if data.bStartTun == 1 then
            desc = desc.."/闷一底"
        elseif data.bStartTun == 2 then
            desc = desc.."/闷二底"
        elseif data.bStartTun == 3 then
            desc = desc.."/闷三底"
        elseif data.bStartTun == 4 then
            desc = desc.."/闷四底"
        elseif data.bStartTun == 5 then
            desc = desc.."/闷五底"
        else
            desc = desc.."/不闷"
        end
        if data.bTurn == 1 then
            desc = desc.."/轮庄"
        else
            desc = desc.."/抢庄"
        end
        
    elseif wKindID == 48 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 4 then
            desc = desc.."4人坐省"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息起胡"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息起胡"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息起胡"
        end
        if data.bStartBanker == 1 then
            desc = desc.."/首局房主坐庄"
        else
            desc = desc.."/首局随机坐庄"
        end
        if data.bTurn == 1 then
            desc = desc.."/轮庄"
        else
            desc = desc.."/抢庄"
        end
        if data.bMaxLost == 300 then
            desc = desc.."/300封顶"
        elseif data.bMaxLost == 600 then
            desc = desc.."/600封顶"
        end

        -- if Bit:_and(data.dwMingTang,0x02) ~= 0 then
        --     desc = desc.."/闷一底"
        -- end
        if data.bStartTun == 1 then
            desc = desc.."/闷一底"
        elseif data.bStartTun == 2 then
            desc = desc.."/闷二底"
        elseif data.bStartTun == 3 then
            desc = desc.."/闷三底"
        elseif data.bStartTun == 4 then
            desc = desc.."/闷四底"
        elseif data.bStartTun == 5 then
            desc = desc.."/闷五底"
        else
            desc = desc.."/不闷"
        end

        if Bit:_and(data.dwMingTang,0x04) ~= 0 then
            desc = desc.."/团圆不叠加"
        elseif Bit:_and(data.dwMingTang,0x10000) ~= 0 then
            desc = desc.."/团圆叠加"
        end
        if Bit:_and(data.dwMingTang,0x08) ~= 0 then
            desc = desc.."/真行行息"
        end
        if Bit:_and(data.dwMingTang,0x10) ~= 0 then
            desc = desc.."/假行行息*6"
        end
        if Bit:_and(data.dwMingTang,0x8000) ~= 0 then
            desc = desc.."/假行行息*4"
        end
        if data.bSiQiHong == 1 then
            desc = desc.."/四七红"
        end
        if Bit:_and(data.dwMingTang,0x20000) ~= 0 then
            desc = desc.."/捉小三"
        end
        if data.bPaoTips == 1 then
            desc = desc.."/明跑提示"
        end
        
    elseif wKindID == 49 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 4 then
            desc = desc.."4人坐省"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息起胡"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息起胡"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息起胡"
        end
        if data.bStartTun == 1 then
            desc = desc.."/闷一底"
        elseif data.bStartTun == 2 then
            desc = desc.."/闷二底"
        elseif data.bStartTun == 3 then
            desc = desc.."/闷三底"
        elseif data.bStartTun == 4 then
            desc = desc.."/闷四底"
        elseif data.bStartTun == 5 then
            desc = desc.."/闷五底"
        else
            desc = desc.."/不闷"
        end
        if data.bTurn == 1 then
            desc = desc.."/轮庄"
        else
            desc = desc.."/抢庄"
        end
        if Bit:_and(data.dwMingTang,0x0C00) ~= 0 then
            desc = desc.."/天地胡"
        end
        if data.STWK == 1 then
            desc = desc.."/三提五坎"
        end
        if data.bHuangFanAddUp == 1 then
            desc = desc.."/黄番"
        end

        
    elseif wKindID == 25 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."2人(PK)"
        end
        if data.bStartCard ~= 0 then
            desc = desc.."/首局黑桃3必出"
        else
            desc = desc.."/首局黑桃3不必出"
        end  
        if data.bBombSeparation == 1 then
            desc = desc.."/炸弹可拆"
        end
        if data.bRed10 == 1 then
            desc = desc.."/红桃10扎鸟"
        end
        if data.b4Add3 == 1 then
            desc = desc.."/可4带3"
        end
        if data.bShowCardCount == 1 then
            desc = desc.."/显示牌数"
        end
        if data.bAbandon == 1 then
            desc = desc.."/放走包赔"
        end
        if data.bCheating == 1 then
            desc = desc.."/防作弊"
        end
        if data.bFalseSpring == 1 then
            desc = desc.."/假春天"
        end
        desc = desc..string.format("/%d张全关",data.bSpringMinCount)
                
    elseif wKindID == 26 then         
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        else
            desc = desc.."2人(PK)"
        end
        if data.bStartCard ~= 0 then
            desc = desc.."/首局黑桃3必出"
        else
            desc = desc.."/首局黑桃3不必出"
        end  
        if data.bBombSeparation == 1 then
            desc = desc.."/炸弹可拆"
        end
        if data.bRed10 == 1 then
            desc = desc.."/红桃10扎鸟"
        end
        if data.b4Add3 == 1 then
            desc = desc.."/可4带3"
        end
        if data.bShowCardCount == 1 then
            desc = desc.."/显示牌数"
        end
        if data.bAbandon == 1 then
            desc = desc.."/放走包赔"
        end
        if data.bCheating == 1 then
            desc = desc.."/防作弊"
        end
        if data.bFalseSpring == 1 then
            desc = desc.."/假春天"
        end
        desc = desc..string.format("/%d张全关",data.bSpringMinCount)
        
    elseif wKindID == 51 or wKindID == 55 or wKindID == 56 or wKindID == 57 or wKindID == 58 or wKindID == 59 then          
        if data.bBankerType == 0 then
            desc = desc.."固定坐庄"
        elseif data.bBankerType == 1 then
            desc = desc.."明牌抢庄"
        elseif data.bBankerType == 2 then
            desc = desc.."双十上庄"
        elseif data.bBankerType == 3 then
            desc = desc.."通比双十"
        elseif data.bBankerType == 4 then
            desc = desc.."轮流坐庄"
        else
        
        end
        if data.bCanPlayingJoin == 1 then
            desc = desc.."/允许中途加入"
        end
        if data.bPush == 1 then
            desc = desc.."/闲家推注"
        end
        if data.bNoFlower == 1 then
            desc = desc.."/无花牌"
        end
        
        if data.bBettingType == 1 then
            desc = desc.."/(1/2/3/4)分"
        elseif data.bBettingType == 2 then
            desc = desc.."/(5/6/7/8)分"
        elseif data.bBettingType == 3 then
            desc = desc.."/(1/2)分"
        elseif data.bBettingType == 4 then
            desc = desc.."/(2/4)分"
        elseif data.bBettingType == 5 then
            desc = desc.."/(3/6)分"
        elseif data.bBettingType == 6 then
            desc = desc.."/(4/8)分"
        elseif data.bBettingType == 7 then
            desc = desc.."/(5/10)分"
        else
        
        end
        desc = desc..string.format("/庄家倍数%d倍",data.bMultiple)
        if data.bSettlementType == 0 then
            desc = desc.."/扫雷"
        else
            desc = desc.."\n"
        end
        if data.bNiuType_Flush == 1 then
            desc = desc.."同花顺x10 "
        end
        if data.bNiuType_Gourd == 1 then
            desc = desc.."葫芦x6 "
        end
        if data.bNiuType_SameColor == 1 then
            desc = desc.."同花x5 "
        end
        if data.bNiuType_Straight == 1 then
            desc = desc.."顺子x5 "
        end
        if data.bSettlementType == 1 then
            desc = desc.."金花x5 银花x4 双十x3 七~九x2"
        elseif data.bSettlementType == 2 then
            desc = desc.."五小x7 4炸x6 金花x5 银花x4 双十x3 七~九x2"
        elseif data.bSettlementType == 3 then
            desc = desc.."五小x8 4炸x7 金花x6 银花x5 双十x4 九x3 七~八x2"
        else
            
        end
        if data.bCuopai == 1 then
            desc = desc.."/搓牌 "
        end   
    elseif wKindID == 53 then                   
        if data.bBankerType == 0 then
            desc = desc.."房主坐庄"
        elseif data.bBankerType == 1 then
            desc = desc.."明牌抢庄"
        elseif data.bBankerType == 2 then
            desc = desc.."三公上庄"
        elseif data.bBankerType == 3 then
            desc = desc.."大吃小"
        elseif data.bBankerType == 4 then
            desc = desc.."牌大上庄"
        elseif data.bBankerType == 5 then
            desc = desc.."暗牌抢庄"
        else

        end 
        if data.bCanPlayingJoin == 1 then
            desc = desc.."/允许中途加入"
        end
        if data.bPush == 1 then
            desc = desc.."/闲家推注"
        end
        if data.bExtreme == 1 then
            desc = desc.."/至尊三公"
        end
        if data.bBettingType == 3 then
            desc = desc.."/(5--50)分"
        elseif data.bBettingType == 4 then
            desc = desc.."/(10--100)分"
        elseif data.bBettingType == 1 then
            desc = desc.."/(1/2/3/4)分"
        elseif data.bBettingType == 2 then
            desc = desc.."/(5/6/7/8)分"            
        end
        if data.bCuopai == 1 then
            desc = desc.."/搓牌 "
        end  
    elseif wKindID == 54 then
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end        
        if data.bDHPlayFlag == 1 then
            desc = desc.."带混"
        end
        if data.bDFFlag == 1 then
            desc = desc.." 带风"
        end     
        if data.bQYMFlag == 1 then
            desc = desc.." 缺一门"
        end      
        desc = desc.."\n"
        if data.bHuType == 0 then
            desc = desc.."/自摸胡"
        elseif data.bHuType == 1 then
            desc = desc.."/点炮胡"
        else
        end 
        if data.bQDFlag == 1 then         
            if data.bQDJFFlag == 0 then
                desc = desc.."/七对加分"
            elseif data.bQDJFFlag == 1 then
                desc = desc.."/七对翻倍"
            end 
        end   
        if data.bDXPFlag == 1 then
            desc = desc.." 带下跑<飘分>"
        end
        if data.bBTHu == 1 then
            desc = desc.." 报听胡"
        end 
   
        if data.bLLFlag == 1 then
            desc = desc.." 连六"
        end
        if data.bQYSFlag == 1 then
            desc = desc.." 清一色"
        end
        if data.bZJJD == 1 then
            desc = desc.." 庄家加底"
        end
        if data.bGSKHJB == 1 then
            desc = desc.." 杠上开花加倍"
        end
    elseif wKindID == 60 then        
        if data.bPlayerCount == 3 then
            desc = desc.."3人房"
        elseif data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 4 then
            desc = desc.."4人坐省"
        end
        if data.bCanHuXi == 15 then
            desc = desc.."/15胡息起胡"
        elseif data.bCanHuXi == 18 then
            desc = desc.."/18胡息起胡"
        elseif data.bCanHuXi == 21 then
            desc = desc.."/21胡息起胡"
        end
        if data.bStartTun == 1 then
            desc = desc.."/倒一"
        elseif data.bStartTun == 3 then
            desc = desc.."/倒三"
        elseif data.bStartTun == 5 then
            desc = desc.."/倒五"
        elseif data.bStartTun == 8 then
            desc = desc.."/倒八"
        end
        if data.bTurn == 1 then
            desc = desc.."/轮庄"
        else
            desc = desc.."/抢庄"
        end 
        if data.bStartBanker == 1 then
            desc = desc.."/房主当庄"
        else
            desc = desc.."/随机当庄"
        end 
     elseif wKindID == 63 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        else

        end
        if data.bNiaoType == 1 then
            desc = desc.."/一马一分"
        elseif data.bNiaoType == 2 then
            desc = desc.."/一马两分"
        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bQingSH == 1 then
            desc = desc.."/清水胡"
        end
    elseif wKindID == 65 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.." 3人"
        else
            desc = desc.." 4人"
        end
        if data.bMaiPiaoCount == 1 then
            desc = desc.." 有(买+漂)"
        elseif data.bMaiPiaoCount == 0 then
            desc = desc.." 无(买+漂)"
        else
        end
        if data.bDiCount == 1 then
            desc = desc.." 底分一分"
        elseif data.bDiCount == 2 then
            desc = desc.." 底分两分"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
    elseif wKindID == 67 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bWuTong == 0 then
            desc = desc.."/没有筒子"
        end 
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        elseif data.bMaCount == 8 then
            desc = desc.."/8个马"
        else

        end
        if data.bNiaoType == 1 then
            desc = desc.."/一马一分"
        elseif data.bNiaoType == 2 then
            desc = desc.."/一马两分"
        end

        if data.mDiFen == 1 then
            desc = desc.."/底分一分"
        elseif data.mDiFen == 2 then
            desc = desc.."/底分两分"
        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bQingSH == 1 then
            desc = desc.."/两片"
        end  
        if data.bQingYiSe == 1 then
            desc = desc.."/清一色"
        end 
        if data.bQiXiaoDui == 1 then
            desc = desc.."/七对"
        end 
        if data.bLongQD == 0 then
            desc = desc.."/龙七对"
        end
        if data.bPPHu == 1 then
            desc = desc.."/碰碰胡"
        end 
        if data.mPFFlag == 1 then
            desc = desc.."/飘分"
        end
        if data.mJFCount == 100 then
            desc = desc.."/100封顶"
        elseif data.mJFCount == 200  then
            desc = desc.."/200封顶"
        elseif data.mJFCount == 300  then
            desc = desc.."/300封顶"
        elseif data.mJFCount == 1000  then
            desc = desc.."/不封顶"
        end
    elseif wKindID == 68 then         
        if data.bPlayerCount == 2 then
            desc = desc.."双人竞技"
            if data.bWuTong == 0 then 
                desc = desc.."/无筒"
            end 
        elseif data.bPlayerCount == 3 then
            desc = desc.."3人"
        else
            desc = desc.."4人"
        end
        if data.bMaType == 1 then
            desc = desc.."/一五九"
        elseif data.bMaType == 2 then
            desc = desc.."/窝窝鸟"
        elseif data.bMaType == 3 then
            desc = desc.."/一马全中"
        elseif data.bMaType == 6 then
            desc = desc.."/翻几奖几"
        else
            desc = desc.."/摸几奖几"
        end
        if data.bMaCount == 2 then
            desc = desc.."/2个马"
        elseif data.bMaCount == 4 then
            desc = desc.."/4个马"
        elseif data.bMaCount == 6 then
            desc = desc.."/6个马"
        else

        end
        if data.bNiaoType == 1 then
            desc = desc.."/一马一分"
        elseif data.bNiaoType == 2 then
            desc = desc.."/一马两分"
        end
        if data.bQGHu == 1 then
            desc = desc.."/抢杠胡"
        else
            desc = desc.."/无抢杠胡"
        end
        if data.bQGHuJM == 1 then
            desc = desc.."/抢杠胡奖马"
        end
        if data.bHuangZhuangHG == 1 then
            desc = desc.."/黄庄荒杠"
        end
        if data.bJiePao == 1 then
            desc = desc.."/可接炮"
        end
        if data.bQingSH == 1 then
            desc = desc.."/清水胡"
        end
        if data.bQiDui == 1 then
            desc = desc.."/七对"
        end
    end
    
    if tableConfig ~= nil and tableConfig.nTableType ~= nil then
        if tableConfig.nTableType >= TableType_GuildRoom then
            desc = desc.."(公会房)"
        elseif tableConfig.nTableType == TableType_HelpRoom then
            desc = desc.."(代开房)"
        elseif tableConfig.nTableType == TableType_ClubRoom and tableConfig.dwClubID ~= 0 then
            desc = string.format("(亲友圈[%d])",tableConfig.dwClubID)..desc
        elseif tableConfig.nTableType == TableType_SportsRoom and tableConfig.dwClubID ~= 0 then
            desc = string.format("(竞技场次[%d])",tableConfig.dwClubID)..desc
        else
        end
    end
    return desc    
end

return GameDesc