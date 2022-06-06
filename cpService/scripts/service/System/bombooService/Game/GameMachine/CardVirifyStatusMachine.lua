local GameMachine = require("bombooService.Game.GameMachine.GameMachine")
local CardVirifyStatusMachine = class("CardVirifyStatusMachine",GameMachine)    
--进入时会调用的一个函数
function CardVirifyStatusMachine:EnterMachineHandle()
    self:CardCheckHandle()
end 

--有一个开始方法
function CardVirifyStatusMachine:StartHandle()  
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function CardVirifyStatusMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function CardVirifyStatusMachine:CapHandle(player,index) 
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function CardVirifyStatusMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function CardVirifyStatusMachine:CardCheckHandle() 
    if self._game:HandCardIsEmpty(self._game:NowOperationalUser()) then  --检查出牌玩家的手牌是否已经不足了 
        if self._game:AwarCardIsEmpty(self._game:NowOperationalUser()) then 
            self:ChangeStatus(self.StatusList.OVER)----直接进入结束模式 
            return 
        end
        print("换手啦")
        --置换手牌
        self._game:SwapHandCards(self._game:NowOperationalUser())
    end  
    self:ChangeStatus(self.STATUS.CHECK)--进入校验模式
end 
--洗手牌
function CardVirifyStatusMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function CardVirifyStatusMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return CardVirifyStatusMachine