local GameMachine = require("bombooService.Game.GameMachine.GameMachine")
local AttackStatusMachine = class("AttackStatusMachine",GameMachine)    
--进入时会调用的一个函数
function AttackStatusMachine:EnterMachineHandle()
end 

--有一个开始方法
function AttackStatusMachine:StartHandle()  
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function AttackStatusMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function AttackStatusMachine:CapHandle(player,index) 
    self._game:CapCard(player,index)--开始向外打出一张牌
    for v,k in pairs(self._game._tableCards) do
        print(v,k,self._game._cardsInfo[k][2])
    end 
    self:ChangeStatus(self.STATUS.CARD_CHECK)--切换状态为检验 
end 

--校验当前游戏
function AttackStatusMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function AttackStatusMachine:CardCheckHandle()
    assert(nil,"状态不是理想状态")
end 
--洗手牌
function AttackStatusMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function AttackStatusMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return AttackStatusMachine