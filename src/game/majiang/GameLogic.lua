--游戏逻辑处理
local Bit = require("common.Bit")
local GameCommon = require("game.majiang.GameCommon")
local GameLogic = {}

function GameLogic:RemoveCard(cbCardIndex,cbRemoveCard)--删除麻将
    --效验扑克
    assert(self:IsValidCard(cbRemoveCard))
    assert(cbCardIndex[self:SwitchToCardIndex(cbRemoveCard)]>0)

    --删除扑克
    local cbRemoveIndex = self:SwitchToCardIndex(cbRemoveCard)
    if cbCardIndex[cbRemoveIndex] > 0 then
        cbCardIndex[cbRemoveIndex] = cbCardIndex[cbRemoveIndex] - 1
        return true,cbCardIndex
    end
    --失败效验
    assert(false)
    return false,nil
end

function GameLogic:RemoveCards(cbCardIndex, cbRemoveCard, bRemoveCount)--删除麻将
    --删除扑克
    for i = 1 , bRemoveCount do
        --效验扑克
        assert(self:IsValidCard(cbRemoveCard[i]))
        assert(cbCardIndex[self:SwitchToCardIndex( cbRemoveCard[i])] > 0)

        --删除扑克
        local cbRemoveIndex= self:SwitchToCardIndex(cbRemoveCard[i])
        if cbCardIndex[cbRemoveIndex] == 0 then
            --错误断言
            assert(false)
            --还原删除
            for j = 1 , i do
                assert(self:IsValidCard(cbRemoveCard[j]))
                local index = self:SwitchToCardIndex( cbRemoveCard[j])
                cbCardIndex[index] = cbCardIndex[index] + 1
            end

            return false,nil
        else 
            --删除扑克
            cbCardIndex[cbRemoveIndex] = cbCardIndex[cbRemoveIndex] - 1
        end
    end

    return true,cbCardIndex
end

function GameLogic:RemoveCardsEx(cbCardData, bCardCount, cbRemoveCard, bRemoveCount)--删除麻将
    --检验数据
    assert(bCardCount <= 14)
    assert(bRemoveCount <= bCardCount)

    --定义变量
    local bDeleteCount=0
    local cbTempCardData = {}
    if bCardCount > 14 then
        return false,nil
    end
    local cbTempCardData = clone(cbCardData)
   
    --置零麻将
    for i = 1 , bRemoveCount do
        for j = 1 , bCardCount do
            if cbRemoveCard[i] == cbTempCardData[j] then
                bDeleteCount = bDeleteCount + 1
                cbTempCardData[j]=0
                break
            end
        end
    end

    --成功判断
    if bDeleteCount ~= bRemoveCount then
        assert(false)
        return false
    end

    --清理扑克
    local bCardPos = 0
    for i = 1 , bCardCount do
        if cbTempCardData[i] ~= 0 then
            bCardPos = bCardPos + 1
            cbCardData[bCardPos] = cbTempCardData[i]
        end
    end
    return true
end

function GameLogic:IsValidCard(cbCardData)--有效判断
    local cbValue= Bit:_and(cbCardData,15)
    local cbColor= Bit:_rshift( Bit:_and(cbCardData,240), 4)
    if (cbValue>=1 and cbValue<=9 and cbColor<=2) or (cbValue >= 1 and cbValue <= 7 and cbColor == 3) then
    	return true
    end
    return false
end

function GameLogic:GetCardCount(cbCardIndex)--扑克数目
    local cbCount=0
    for i = 1 , 34 do
        cbCount = cbCount + cbCardIndex[i]
    end
    return cbCount
end

--获取组合
function GameLogic:GetWeaveCard(cbWeaveKind,cbCenterCard,bCardBuffer)

    --组合麻将
    if cbWeaveKind == GameCommon.WIK_LEFT then         --上牌操作
        --设置变量
        bCardBuffer[1] = cbCenterCard+1
        bCardBuffer[2] = cbCenterCard+2
        bCardBuffer[3] = cbCenterCard

        return 3
    elseif cbWeaveKind == GameCommon.WIK_RIGHT then    --上牌操作
        --设置变量
        bCardBuffer[1]=cbCenterCard-2
		bCardBuffer[2]=cbCenterCard-1
		bCardBuffer[3]=cbCenterCard

        return 3
        
    elseif cbWeaveKind == GameCommon.WIK_CENTER then    --上牌操作
        --设置变量
        bCardBuffer[1]=cbCenterCard-1
		bCardBuffer[2]=cbCenterCard
		bCardBuffer[3]=cbCenterCard+1

        return 3

    elseif cbWeaveKind == GameCommon.WIK_PENG then      --碰牌操作
        --设置变量
        bCardBuffer[1]=cbCenterCard
		bCardBuffer[2]=cbCenterCard
		bCardBuffer[3]=cbCenterCard

        return 3

    elseif cbWeaveKind == GameCommon.WIK_FILL then      --补牌操作
        --设置变量
        bCardBuffer[1]=cbCenterCard
		bCardBuffer[2]=cbCenterCard
		bCardBuffer[3]=cbCenterCard
		bCardBuffer[4]=cbCenterCard

        return 4

    elseif cbWeaveKind == GameCommon.WIK_GANG then      --杠牌操作
        --设置变量
        bCardBuffer[1]=cbCenterCard
		bCardBuffer[2]=cbCenterCard
		bCardBuffer[3]=cbCenterCard
		bCardBuffer[4]=cbCenterCard
        
        return 4

     else
        assert(false)
     end
        
     return 0

end

--动作等级
function GameLogic:GetActionRank(cbUserAction)

    if Bit:_and(cbUserAction,GameCommon.WIK_CHI_HU) then
        return 4
    end

    if Bit:_and(cbUserAction,Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG)) then
        return 3
    end

    if Bit:_and(cbUserAction,GameCommon.WIK_PENG) then
        return 2
    end

    if Bit:_and(cbUserAction,Bit:_or(GameCommon.WIK_RIGHT,Bit:_or(GameCommon.WIK_CENTER,GameCommon.WIK_LEFT))) then
        return 0
    end
end

--胡牌等级
function GameLogic:GetChiHuActionRank(ChiHuResult)
    --变量定义
    local cbChiHuOrder = 0
    local wChiHuRight = ChiHuResult.wChiHuRight
    local wChiHuKind = Bit:_rshift(Bit:_and(ChiHuResult.wChiHuRight,0xFF00),4)

    --大胡升级
    for i = 1 , 8 do
        wChiHuKind = Bit:_rshift(wChiHuKind,1)
        if Bit:_and(wChiHuKind,0x0001) ~= 0 then
            cbChiHuOrder = cbChiHuOrder+1
        end
    end

    --权位升级
    for i = 1 , 16 do
        wChiHuRight = Bit:_rshift(wChiHuRight,1)
        if Bit:_and(wChiHuRight,0x0001) ~= 0 then
            cbChiHuOrder = cbChiHuOrder+1
        end
    end

    return cbChiHuOrder

end

--吃牌判断
function GameLogic:EstimateEatCard(cbCardIndex,cbCurrentCard)
    --参数效验
    assert(self:IsValidCard(cbCurrentCard))

    --过滤判断
    if cbCurrentCard >= 0x31 then
        return GameCommon.WIK_NULL
    end

    --变量定义
    local cbExcursion = {[1] = 0,[2] = 1,[3] = 2}
    local cbItemKind = {[1] = GameCommon.WIK_LEFT,[2] = GameCommon.WIK_CENTER,[3] = GameCommon.WIK_RIGHT}

    --吃牌判断
    local cbEatKind = 0
    local cbFirstIndex = 0
    local cbCurrentIndex = self:SwitchToCardIndex(cbCurrentCard)

    for i =1,#cbItemKind do
        local  cbValueIndex = (cbCurrentIndex-1)%9
        if cbValueIndex >= cbExcursion[i] and (cbValueIndex - cbExcursion[i])<=6 then
            --吃牌判断
            cbFirstIndex = cbCurrentIndex - cbExcursion[i]
            if cbCurrentIndex ~= cbFirstIndex and cbCardIndex[cbFirstIndex] == 0 then
            else
                if cbCurrentIndex ~= (cbFirstIndex+1) and cbCardIndex[cbFirstIndex+1] == 0 then
                else
                    if cbCurrentIndex ~= (cbFirstIndex+2) and cbCardIndex[cbFirstIndex+2] == 0 then
                    else
                        --设置类型
                        cbEatKind = Bit:_or(cbEatKind,cbItemKind[i])
                    end
                end
            end
        end
    end
    
    return cbEatKind

end

--碰牌判断
function GameLogic:EstimatePengCard(cbCardIndex,cbCurrentCard)
    --参数效验
    assert(self:IsValidCard(cbCurrentCard))

    --碰牌判断
    if cbCardIndex[self:SwitchToCardIndex(cbCurrentCard)] >= 2 then
        return GameCommon.WIK_PENG
    else
        return GameCommon.WIK_NULL
    end
end

--杠牌判断
function GameLogic:EstimateGangCard(cbCardIndex,cbCurrentCard)
    --参数判断
    assert(self:IsValidCard(cbCurrentCard))

    --杠牌判断
    if cbCardIndex[self:SwitchToCardIndex(cbCurrentCard)] >= 3 then
        return GameCommon.WIK_PENG
    else
        return GameCommon.WIK_NULL
    end
end

--杠牌分析
function GameLogic:AnalyseGangCard(cbCardIndex,WeaveItem,cbWeaveCount)
    --设置变量
    local cbActionMask = GameCommon.WIK_NULL
    local GangCardResult = {}
    GangCardResult.cbCardCount = 0
    GangCardResult.cbCardData = {}

    --手上杠牌
    for i = 1 , 34 do
        if cbCardIndex[i] == 4 then
            cbActionMask = Bit:_or(Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG),cbActionMask)
            GangCardResult.cbCardData[GangCardResult.cbCardCount+1] = Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG)
            GangCardResult.cbCardData[GangCardResult.cbCardCount+1] = self:SwitchToCardDataOne(i)
            GangCardResult.cbCardCount = GangCardResult.cbCardCount+1
            GangCardResult.tbyeGang = true
        end
    end    
    --组合杠牌
    for i = 1 , cbWeaveCount do
        if WeaveItem[i].cbWeaveKind == GameCommon.WIK_PENG then
            if cbCardIndex[self:SwitchToCardIndex(WeaveItem[i].cbCenterCard)] == 1 then
                cbActionMask = Bit:_or(Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG),cbActionMask)
                GangCardResult.cbCardData[GangCardResult.cbCardCount+1] = Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG)
                GangCardResult.cbCardData[GangCardResult.cbCardCount+1] = WeaveItem[i].cbCenterCard
                GangCardResult.cbCardCount = GangCardResult.cbCardCount+1
                GangCardResult.tbyeGang = false
            end
        end
    end
    
    return cbActionMask,GangCardResult
end

--过张杠牌
function GameLogic:AnalyseGangCardGuo(cbCardIndex,WeaveItem,cbWeaveCount)
    --组合杠牌
    for i = 1 , cbWeaveCount do
        if WeaveItem[i].cbWeaveKind == GameCommon.WIK_PENG then
            if cbCardIndex[self:SwitchToCardIndex(WeaveItem[i].cbCenterCard)] == 1 then
                GameCommon.m_GuoZhangGang[2] = WeaveItem[i].cbCenterCard
                print("标记过张杠",GameCommon.m_GuoZhangGang[2])
            end
        end
    end
end

--杠牌分析
function GameLogic:AnalyseGangCards(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard)
    --设置变量
    local cbActionMask = GameCommon.WIK_NULL
    local GangCardResult = {}

    --手上杠牌

    if cbCardIndex[self:SwitchToCardIndex(cbCurrentCard)] == 4 then
        cbActionMask = Bit:_or(Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG),cbActionMask)
        GangCardResult.cbCardData[GangCardResult.cbCardCount] = Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG)
        GangCardResult.cbCardData[GangCardResult.cbCardCount] = cbCurrentCard
        GangCardResult.cbCardCount = GangCardResult.cbCardCount+1
    end

    --组合杠牌
    for i = 1,cbWeaveCount do
       
       if WeaveItem[i].cbWeaveKind == GameCommon.WIK_PENG then
            if cbCardIndex[self:SwitchToCardIndex(WeaveItem[i].cbCenterCard)] == 1 and WeaveItem[i].cbCenterCard == cbCurrentCard then
                cbActionMask = Bit:_or(Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG),cbActionMask)
                GangCardResult.cbCardData[GangCardResult.cbCardCount] = Bit:_or(GameCommon.WIK_FILL,GameCommon.WIK_GANG)
                GangCardResult.cbCardData[GangCardResult.cbCardCount] = WeaveItem[i].cbCenterCard
                GangCardResult.cbCardCount = GangCardResult.cbCardCount+1
            end
       end

    end
    
    return cbActionMask,GangCardResult
    
end

--吃胡分析
function GameLogic:AnalyseChiHuCard(cbCardIndex,WeaveItem,cbWeaveCount,cbCurrentCard,wChiHuRight)
    --变量定义
    local wChiHuKind = GameCommon.CHK_NULL

    --设置变量
    local AnalyseItemArray ={}
    local ChiHuResult = {}
    
    --构造麻将
    local cbCardIndexTemp = {}
    for i = 1 , 34 do
        cbCardIndexTemp[i] = cbCardIndex[i]
    end
    
    --插入麻将
    if cbCurrentCard ~= 0 then
        local insetIndex = self:SwitchToCardIndex(cbCurrentCard)
        cbCardIndexTemp[insetIndex] = cbCardIndexTemp[insetIndex]+1
    end

    --特殊胡牌
    if self:IsQiXiaoDui(cbCardIndexTemp,WeaveItem,cbWeaveCount) then
        for i = 1 , 34 do
            if cbCardIndex[i] == 4 then
                wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_QI_XIAO_DUI_HAO)
            end
        end

        if Bit:_and(wChiHuKind,GameCommon.CHK_QI_XIAO_DUI_HAO) == 0 then
            wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_QI_XIAO_DUI)
        end
    end

    if self:IsJiangJiangHu(cbCardIndexTemp,WeaveItem,cbWeaveCount) == true then
        wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_JIANG_JIANG)
    end

    --特殊牌型
    if self:IsQuanQiuRen(cbCardIndexTemp,WeaveItem,cbWeaveCount) == true then
        wChiHuRight = Bit:_or(wChiHuRight,GameCommon.CHR_QUAN_QIU_REN)
    end
    if self:IsQingYiSe(cbCardIndexTemp,WeaveItem,cbWeaveCount) == true then
        wChiHuRight = Bit:_or(wChiHuRight,GameCommon.CHR_QING_YI_SE)
    end

    --分析麻将
    local trmpBool = false
    trmpBool,AnalyseItemArray = self:AnalyseCard(cbCardIndexTemp,WeaveItem,cbWeaveCount)

    --胡牌分析
    if #AnalyseItemArray > 0 then
        --眼牌需求
        local bNeedSymbol = false;
        if Bit:_and(wChiHuRight,0xFF00) == 0 then
            bNeedSymbol = true
        else
            bNeedSymbol = false
        end

        --牌型分析
        for i = 1 , #AnalyseItemArray do
            --变量定义
            local bLianCard = false
            local bPengCard = false 
            local b258Card = false

            --牌眼类型
            local cbEyeValue = Bit:_and(AnalyseItemArray[i].cbCardEye,15)

            --牌型分析
            for j = 1 ,#AnalyseItemArray[i].cbWeaveKind do
                local cbWeaveKind = AnalyseItemArray[i].cbWeaveKind[j]
                if Bit:_and(cbWeaveKind,(Bit:_or(GameCommon.WIK_PENG,(Bit:_or(GameCommon.WIK_GANG,GameCommon.WIK_FILL))))) ~= 0 then
                    bPengCard = true
                end

                if Bit:_and(cbWeaveKind,(Bit:_or(GameCommon.WIK_LEFT,(Bit:_or(GameCommon.WIK_CENTER,GameCommon.WIK_RIGHT))))) then
                    bLianCard = true
                end
            end

            --牌型判断
            assert(bLianCard == true or bPengCard == true)

            --判断2，5，8作对
            if Bit:_and(cbEyeValue,15) == 0x02 or Bit:_and(cbEyeValue,15) == 0x05 or Bit:_and(cbEyeValue,15) == 0x08 then
                if bLianCard then
                    wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_PING_HU)
                end
            end

            --判断乱将
            if Bit:_and(wChiHuRight,GameCommon.CHR_QING_YI_SE) or Bit:_and(wChiHuRight,GameCommon.CHR_QUAN_QIU_REN) then
                wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_PING_HU)
            end

            --特殊--碰碰胡
            if bLianCard == false and bPengCard == true then
                wChiHuKind = Bit:_or(wChiHuKind,GameCommon.CHK_PENG_PENG)
            end
            
        end
    end

    --判断结果
    if wChiHuKind ~= GameCommon.CHK_NULL then
        ChiHuResult.wChiHuKind = wChiHuKind
        ChiHuResult.wChiHuRight = wChiHuRight
        return GameCommon.WIK_CHI_HU,ChiHuResult
    end

    return GameCommon.WIK_NULL,ChiHuResult
end

function GameLogic:GetHuCardInfoData(wChairID, cbCardIndex, cbCurrentCard)--胡牌结果

    local ret = false                               --能不能组合
    local paotiwei = false                          --是否有跑提偎


	local stuTingCardInfo = {}    -- 可能的提牌
	stuTingCardInfo.cbCardData = 0
	stuTingCardInfo.isTingCard = false
	stuTingCardInfo.cbTingCount = 0
    stuTingCardInfo.cbCardIndexTing = {}
    
    --手牌四张变提 
    --手牌三张变喂 
    --变量定义
    --构造扑克   新牌
    local cbCardIndexTemp = clone(cbCardIndex)
    --设置结果
    local HuCardInfo = {}
    HuCardInfo.cbWeaveCount = 0
    HuCardInfo.cbHuXiCount = 0
    HuCardInfo.WeaveItemArray = {}


    cbCardIndexTemp[cbCurrentCard] = cbCardIndexTemp[cbCurrentCard] +1
    ret = self:AnalyseCard(cbCardIndexTemp)

    return ret
end

--分析扑克
function GameLogic:AnalyseCard(cbCardIndex)
    --变量定义
    local cbWeaveItemCount=0
    local WeaveItem = {}

    --数目统计
    local cbCardCount=0
    for i = 1 , 34 do
        cbCardCount = cbCardCount + cbCardIndex[i]
    end

    --数目判断
    if (cbCardCount==0) then
        return true
    end
    if ((cbCardCount%3 ~= 0) and ((cbCardCount+1)%3 ~=0)) then
        return false
    end

    --需求计算
    local bLessWeavItem=math.floor(cbCardCount/3)
    local bNeedCardEye=((cbCardCount+1)%3==0)

    --单吊判断
    if ((bLessWeavItem==0) and (bNeedCardEye==true)) then
        --牌眼判断
        for i = 1 , 34 do
            if (cbCardIndex[i]==2) then
                --变量定义
                return true
            end
        end

        return false
    end

    return self:NewHupai(cbCardIndex,bLessWeavItem,bNeedCardEye)
end

function GameLogic:NewHupai(cbCardIndex,bLessWeavItem,bNeedCardEye)

    local ectDui  = 2
	local ectEat  = 3
    local WeaveItem = {}
    --变量定义
    local AnalyseItem = {}
    --设置结果
    AnalyseItem.cbHuXiCount=0
    AnalyseItem.cbCardEye=cbCardEye
    AnalyseItem.cbWeaveCount=bLessWeavItem
    AnalyseItem.WeaveItemArray = {}
    local I = self:NewRemain(cbCardIndex)
    if(I == 100) then 
        return true  -- 递归退出条件：如果没有剩牌，则和牌返回。
    end    
	--2张组合(将牌)
	if(cbCardIndex[I] >=2) then 
        if (bNeedCardEye == true) then   --如果之前没有将牌，且当前牌不少于2张
          --  if I <= 27 and ( I%9 == 2 or I%9 == 5 or I%9 == 8 )then              
                bNeedCardEye = false
                cbCardIndex[I] = cbCardIndex[I] - 2
                if(self:NewHupai(cbCardIndex,bLessWeavItem,bNeedCardEye)) 	then	               
                    cbCardIndex[I] =cbCardIndex[I] + 2
                    return true 
                end
                cbCardIndex[I] = cbCardIndex[I] + 2
                bNeedCardEye = true
          --  end
        end
    end

    if(cbCardIndex[I] >=3) then 
			cbCardIndex[I] = cbCardIndex[I] - 3
			if(self:NewHupai(cbCardIndex,bLessWeavItem,bNeedCardEye)) 	then	              
				cbCardIndex[I] =cbCardIndex[I] + 3
				return true 
            end
			cbCardIndex[I] = cbCardIndex[I] + 3
			bNeedCardEye = true       
    end

	--顺子组合方式
	local FengCheckerCount = 0
	local FengChecker ={}
	local K = 0
	if  (I >= 1 and  I<= 7) or (I >=10 and I<=16)or (I >=17 and I<=23) then
	 	K = 2
    end
	for  J = I + 1,I + K do
		if (cbCardIndex[ J ] > 0 ) then		
			if(FengCheckerCount > 2)then			
				FengCheckerCount = 0
            end
            FengChecker[FengCheckerCount] = J            
            FengCheckerCount = FengCheckerCount + 1
        end
    end
	if ( FengCheckerCount == 2 ) then
	 --找到原始顺子
		cbCardIndex[ I ] = cbCardIndex[ I ] -1
		cbCardIndex[ FengChecker [ 0 ] ] = cbCardIndex[ FengChecker [ 0 ] ]-1
		cbCardIndex[ FengChecker [ 1 ] ] = cbCardIndex[ FengChecker [ 1 ] ] -1      --和牌数减1	
		if (self:NewHupai(cbCardIndex,bLessWeavItem,bNeedCardEye)) then      
			cbCardIndex[ I ] =cbCardIndex[ I ] +1
			cbCardIndex[ FengChecker [ 0 ] ] =cbCardIndex[ FengChecker [ 0 ] ] +1
			cbCardIndex[ FengChecker [ 1 ] ] =cbCardIndex[ FengChecker [ 1 ] ] +1
			return true 
        end
        cbCardIndex[ I ] =cbCardIndex[ I ] +1
        cbCardIndex[ FengChecker [ 0 ] ] =cbCardIndex[ FengChecker [ 0 ] ] +1
        cbCardIndex[ FengChecker [ 1 ] ] =cbCardIndex[ FengChecker [ 1 ] ] +1
    end
	-- 无法全部组合，不和！
	return false
end 

function GameLogic:NewRemain(cbCardIndex) 
    for i = 1, 34 do
        if cbCardIndex[i] ~= 0 then 
			return i
        end 
    end 
	return 100;

end

--清一色牌
function GameLogic:IsQingYiSe(cbCardIndex,WeaveItem,cbItemCount)
    --胡牌判断
    local cbCardColor = 0xFF

    local i = 1

    while i <= 34 do
        if cbCardIndex[i] ~= 0 then
            --花色判断
            if cbCardColor ~= 0xFF then
                return false
            end

            --设置花色
            cbCardColor = Bit:_and(self:SwitchToCardDataOne(i),0xF0)

            i = (((i-1)/9)+1)*9 + 1
        else
            i = i+1
        end
    end
    
    --组合判断
    for i = 1 , cbItemCount do
        local cbCenterCard = WeaveItem[i].cbCenterCard
        if Bit:_and(cbCenterCard,0xF0) ~= cbCardColor then
            return false
        end
    end
    
    return true
end

--七小对
function GameLogic:IsQiXiaoDui(cbCardIndex,WeaveItem,cbWeaveCount)
    --组合判断
    if cbWeaveCount ~= 0 then
        return false
    end

    --麻将判断
    for i = 1 , 34 do
        local cbCardCount = cbCardIndex[i]
        if cbCardCount ~= 0 and cbCardCount ~= 2 and cbCardCount ~= 4 then
            return false
        end
    end

    return true
    
end

--清一色七小对
function GameLogic:IsOneColQiXiaoDui(cbCardIndex,WeaveItem,cbWeaveCount)
    if self:IsQiXiaoDui(cbCardIndex,WeaveItem,cbWeaveCount) and self:IsQingYiSe(cbCardIndex,WeaveItem,cbWeaveCount) then
        return true
    end
    return false
end

--全求人
function GameLogic:IsQuanQiuRen(cbCardIndex,WeaveItem,cbWeaveCount)
    if cbWeaveCount ~= 4 then
        return false
    end

    for i = 1 ,34 do
        local cbCardCount = cbCardIndex[i]
        if cbCardCount ~= 0 and cbCardCount ~= 2 then
            return false
        end
    end

    return true
    
end

--三同
function GameLogic:IsSanTong(wActionUser)
    local  m_queue = self:GetSameCard(wActionUser)
    local data = {}
    for i = 1 ,14 do 
        data[i] = 0  
    end 
    local num = 0    
    for i = 1 , 10 do     
        if m_queue[i].num >= 2 and  m_queue[i+10].num >= 2 and  m_queue[i+20].num >= 2   then 
            num = num + 1  
            data[num] =  m_queue[i].cbCardData 
        end 
    end 
    return data
end


--六六顺
function GameLogic:IsLiuLiu(wActionUser)
    local  m_queue = self:GetSameCard(wActionUser)
    local data = {}
    for i = 1 ,14 do 
        data[i] = 0  
    end 
    local num = 0  
    for i = 0 , 2 do
        for j = 1 , 8 do 
        local value = i*10 + j    
            if m_queue[value].num >= 3 and  m_queue[value+1].num >= 3 then 
                num = num + 1
                data[num] =  m_queue[value].cbCardData 
            end 
        end 
    end
    return data
end

--四喜
function GameLogic:IsSiXi(wActionUser)
    local  m_queue = self:GetSameCard(wActionUser)
    local data = {}
    for i = 1 ,14 do 
        data[i] = 0  
    end 
    local num = 0    
    for i = 1 , 30 do     
        if m_queue[i].num == 4  then 
            num = num + 1 
            data[num] =  m_queue[i].cbCardData 
        end 
    end 
    return data
end

--步步高
function GameLogic:IsBuBuGao(wActionUser)
    local  m_queue = self:GetSameCard(wActionUser)
    local data = {}
    for i = 1 ,14 do 
        data[i] = {}  
    end 
    local num = 0  
    for i = 0 , 2 do
        for j = 1 , 8 do 
            local value = i*10 + j     
            if m_queue[value].num >= 2 and  m_queue[value+1].num >= 2 and  m_queue[value+2].num >= 2   then 
                num = num + 1
                data[num].cbCardData =  m_queue[value].cbCardData 
            end 
        end 
    end 
    return data
end
  
--  牌  数组   b  m_pai[1] =  21      m_pai[2] =  21   m_pai[3] =  21  
   
function GameLogic:GetSameCard(wActionUser)
    local wChairID = wActionUser
    local viewID = GameCommon:getViewIDByChairID(wChairID) 
    local adwewev = {}
    for i = 1, 30  do 
        if adwewev[i] == nil then
           adwewev[i] = {}   
           adwewev[i].num = 0
           adwewev[i].cbCardData = 0
        end 
    end 
--    if wActionUser ~= GameCommon:getRoleChairID() then
        local cbCardCount = GameCommon.player[wChairID].cbCardCount
        local cbCardData = GameCommon.player[wChairID].cbCardData        
        local ads = 1
        for i = 1 ,#cbCardData do 
            local cbValue= Bit:_and(cbCardData[i],15)
            local cbColor= Bit:_rshift( Bit:_and(cbCardData[i],240), 4)
            local data = cbColor*10 + cbValue
            adwewev[data].num = adwewev[data].num + 1
            adwewev[data].cbCardData = cbCardData[i] 
            print("牌  数组",adwewev[data].cbCardData)
       end  
        
--            for j = i+1 ,cbCardData do 
--                if  cbCardData[i] == cbCardData[j] then   
--                    if adwewev[ads].num == nil then 
--                       adwewev[ads].num = 0
--                    end   
--                    adwewev[ads].num = adwewev[ads].num + 1  
--                    adwewev[ads].cbCardData = cbCardData[i] 
--                    i = j
--                else                     
--                    ads = ads + 1 
--                    break 
--                end 
--            end 
--        end
--        return false          
--    end
    
    return adwewev
end

function GameLogic:SwitchToCardDataOne(cbCardIndex)--麻将转换
    local cbCardIndex = cbCardIndex - 1
    assert(cbCardIndex<=34)

    local value3 = math.floor(cbCardIndex / 9)

    local value1 = Bit:_lshift(value3,4)
    local value2 = (cbCardIndex % 9 + 1 )
    local value = Bit:_or( value1 , value2)
    return value
end

function GameLogic:SwitchToCardIndex(cbCardData)--麻将转换
    assert(self:IsValidCard(cbCardData))
    local value = Bit:_rshift( Bit:_and(cbCardData,240),4) * 9 + Bit:_and(cbCardData,15) - 1 
    return value + 1
end

function GameLogic:SwitchToCardDataTwo(cbCardIndex)--麻将转换
    --转换麻将
    local cbCardData = {}
    local bPosition=0


    if GameCommon.wKindID == 33 then
        for i = 1,cbCardIndex[32] do
            assert(bPosition<14)
            bPosition = bPosition + 1
            cbCardData[bPosition]= self:SwitchToCardDataOne(32)
        end
        for i = 1 , 34 do
            if (cbCardIndex[i] ~= 0) and i~= 32 then
                for j = 1 , cbCardIndex[i] do
                    assert(bPosition<14)
                    bPosition = bPosition + 1
                    cbCardData[bPosition]= self:SwitchToCardDataOne(i)
                end
            end
        end
    else
        for i = 1,cbCardIndex[28] do
            assert(bPosition<14)
            bPosition = bPosition + 1
            cbCardData[bPosition]= self:SwitchToCardDataOne(28)
        end
        for i = 1 , 34 do
            if (cbCardIndex[i] ~= 0) and i~= 28 then
                for j = 1 , cbCardIndex[i] do
                    assert(bPosition<14)
                    bPosition = bPosition + 1
                    cbCardData[bPosition]= self:SwitchToCardDataOne(i)
                end
            end
        end
    end

    return bPosition,cbCardData
end
function GameLogic:SwitchToCardDataTwo_luan(cbCardIndex)--麻将转换
    --转换麻将
    local cbCardData = {}
    local bPosition=0

    for i = 1,cbCardIndex[28] do
        assert(bPosition<14)
        bPosition = bPosition + 1
        cbCardData[bPosition]= self:SwitchToCardDataOne(28)
    end

    for i = 1 , 34 do
        if (cbCardIndex[i] ~= 0) and i~= 28 then
            for j = 1 , cbCardIndex[i] do
                assert(bPosition<14)
                bPosition = bPosition + 1
                cbCardData[bPosition]= self:SwitchToCardDataOne(i)
            end
        end
    end
    --打乱牌
    for i = 1 , 100 do
        local j = math.random(1,13)
        local card_a = cbCardData[13]
        cbCardData[13] = cbCardData[j]
        cbCardData[j] = card_a 
    end    
    return bPosition,cbCardData
end
function GameLogic:SwitchToCardIndexTwo(cbCardData, cbCardCount)--麻将转换
    --设置变量
    local cbCardIndex = {}

    for x = 1 ,34 do
        cbCardIndex[x] = 0
    end
    if cbCardCount == nil then
        cbCardCount = 14 
    end 

    --转换扑克
    for i = 1 , cbCardCount do
        if cbCardData[i] ~= 0 then 
            assert(self:IsValidCard(cbCardData[i]))
            cbCardIndex[self:SwitchToCardIndex(cbCardData[i])] = cbCardIndex[self:SwitchToCardIndex(cbCardData[i])]+1
        end 
    end
    return cbCardIndex
end

--将将胡
function GameLogic:IsJiangJiangHu(cbCardIndex,WeaveItem,cbWeaveCount)
    --组合判断
    for i = 1 , cbWeaveCount do
        --类型判断
        local cbWeaveKind = WeaveItem[i].cbWeaveKind
        if cbWeaveKind ~= GameCommon.WIK_PENG and cbWeaveKind ~= GameCommon.WIK_GANG and cbWeaveCount ~= GameCommon.WIK_FILL then
            return false
        end

        --数值判断
        local cbCenterValue = Bit:_and(WeaveItem[i].cbCenterCard,15)
        if cbCenterValue ~= 0x02 and cbCenterValue ~= 0x05 and cbCenterValue ~= 0x08 then
            return false
        end
    end
    
    --麻将判断
    for i = 1 , 34 do
        if cbCardIndex[i] == 0 then
            
        else
            if Bit:_and(self:SwitchToCardDataOne(i),15) == 0x02 or Bit:_and(self:SwitchToCardDataOne(i),15) == 0x05 or Bit:_and(self:SwitchToCardDataOne(i),15) == 0x08 then
            
            else
                return false
            end
        end
    end
    
    return true

end

--有2，5，8做将

function  GameLogic:Have2_5_8Jiang(cbCardIndex)
    --检测2万
    if cbCardIndex[self:SwitchToCardIndex(0x02)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x12)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x22)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x05)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x15)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x25)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x08)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x18)] >= 2 then
        return true
    elseif cbCardIndex[self:SwitchToCardIndex(0x28)] >= 2 then
        return true
    end

    return false

end

--听牌状态
function GameLogic:IsTingPaiStatus(cbCardIndex,WeaveItem,cbWeaveCount)
    --构造扑克
    local cbTempCard = clone(cbCardIndex)
    
    local cbCardDataTemp = {[1] = 0x01,[2] = 0x02,[3] = 0x03,[4] = 0x04,[5] = 0x05,[6] = 0x06,[7] = 0x07,[8] = 0x08,[9] = 0x09,
                            [10] = 0x11,[11] = 0x12,[12] = 0x13,[13] = 0x14,[14] = 0x15,[15] = 0x16,[16] = 0x17,[17] = 0x18,[18] = 0x19,
                            [19] = 0x21,[20] = 0x22,[21] = 0x23,[22] = 0x24,[23] = 0x25,[24] = 0x26,[25] = 0x27,[26] = 0x28,[27] = 0x29
    }

    local pWeaveItem = clone(WeaveItem)

    --抽取麻将
    for i = 1 ,27 do
        local  ChiHuResult = {}
        local bHuKind = GameCommon.WIK_NULL

        bHuKind,ChiHuResult = self:AnalyseChiHuCard(cbTempCard,pWeaveItem,cbWeaveCount,cbCardDataTemp[i],0)

        if bHuKind ~= GameCommon.WIK_NULL then
            return true
        end
    end

    return false
end

--得到扎鸟位置
function GameLogic:CalZhaNiaoPos(wStartUser,cbCardValue,wPlayerCount)
    local cbCardTmpValue = Bit:_and(cbCardValue,15)
    cbCardTmpValue = (cbCardTmpValue - 1)%wPlayerCount
    if cbCardTmpValue > wStartUser then
        cbCardTmpValue = wStartUser+wPlayerCount-cbCardTmpValue
    else
        cbCardTmpValue=wStartUser-cbCardTmpValue
    end
    return cbCardTmpValue
end

function GameLogic:GetBestOutCard(cbCardIndex,nTeshuInex)
    local cbOutCard = 0
    local cbCardCount = 0
    for i = 1,34 do
        cbCardCount = cbCardCount+cbCardIndex[i]
    end

    local cbCopyCardIndex = clone(cbCardIndex)

    local bJiang = self:killBestCard(cbCopyCardIndex)

    --在提取有用牌后，剩余牌中寻找单个的牌,先出边上的牌，再出中间牌
    for i = 1 , 34 do
        if i == 1 or i == 10 or i ==18 then --一万，一条，一坨
            if cbCopyCardIndex[i] == 1 and cbCopyCardIndex[i+1] == 0 then
                cbOutCard = self:SwitchToCardDataOne(i)
                return cbOutCard
            end
        end
    end
    
    for i = 1 , 34 do
        if i == 9 or i == 18 or i ==27 then --九万，九条，九坨
            if cbCopyCardIndex[i] == 1 and cbCopyCardIndex[i-1] == 0 then
                cbOutCard = self:SwitchToCardDataOne(i)
                return cbOutCard
            end
        end
    end
    
    for i = 1 , 34 do
        if (i-1)%9 ~= 0 and i ~= 9 and i ~= 26 then
            if cbCopyCardIndex[i] == 1 and cbCopyCardIndex[i+1] == 0 and cbCopyCardIndex[i-1] == 0 then
                cbOutCard = self:SwitchToCardDataOne(i)
                return cbOutCard
            end
        end
    end

    for i = 1 , 34 do
        if bJiang then --有牌眼
            if cbCopyCardIndex[i] ~= 0 then
                cbOutCard = self:SwitchToCardDataOne(i)
                return cbOutCard
            end
        else
            --没有牌眼
            if Bit:_and(self:SwitchToCardDataOne(i),15) ~= 0x02 and Bit:_and(self:SwitchToCardDataOne(i),15) ~= 0x05 and Bit:_and(self:SwitchToCardDataOne(i),15) ~= 0x08 then
                if cbCopyCardIndex[i] ~= 0 then
                    cbOutCard = self:SwitchToCardDataOne(i)
                    return cbOutCard
                end
            end

            if cbCopyCardIndex[i] ~= 0 then
                cbOutCard = self:SwitchToCardDataOne(i)
                return cbOutCard
            end
        end
    end
    
    local card = 0
    local cout = 0

    while 1 do
    
        local i = math.random(0,34)
        if cbCardIndex[i] > 0 then
            card = self:SwitchToCardDataOne(i)
        end

        cout = cout+1;

        if card ~=0 or cout > 100 then
            break
        end
    end

    return card

end

function GameLogic:killBestCard(cbCopyCardIndex)
    local bJiang = false

    --提取3张
    for i =1 , 34 do
        if cbCopyCardIndex[i] >= 3 then
            cbCopyCardIndex[i] = 0
        end
    end

    --提取牌眼
    local yanCardIndex = {}
    local yanCardCout = 0

    for i = 1 , 34 do
        if cbCopyCardIndex[i] == 2 and (Bit:_and(self:SwitchToCardDataOne(i),15) == 0x02 or Bit:_and(self:SwitchToCardDataOne(i),15) == 0x05 or Bit:_and(self:SwitchToCardDataOne(i),15) == 0x08) then
            yanCardCout = yanCardCout+1
            yanCardIndex[yanCardCout] = i
        end
    end
    
    for i = 1,yanCardCout do
        --连牌判断
        if cbCopyCardIndex[i] == 0 then
        else
            if i < 32 and cbCopyCardIndex[i] > 0 and i%9 < 7 then
                for j = 1 , cbCopyCardIndex[i] do
                    if cbCopyCardIndex[i+1] >= j and cbCopyCardIndex[i+2] >= j then
                        cbCopyCardIndex[i] = cbCopyCardIndex[i] - 1
                        cbCopyCardIndex[i+1] = cbCopyCardIndex[i+1] - 1
                        cbCopyCardIndex[i+1] = cbCopyCardIndex[i+2] - 1
                    end
                end
                
            end
        end
    end
    
    return bJiang
end

return GameLogic