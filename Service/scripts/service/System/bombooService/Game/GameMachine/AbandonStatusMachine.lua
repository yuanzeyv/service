local GameMachine = require("bombooService.Game.GameMachine.GameMachine")
local AbandonStatusMachine = class("AbandonStatusMachine",GameMachine)    
--进入时会调用的一个函数
function AbandonStatusMachine:EnterMachineHandle()
    self:OverHandle()
end 

--有一个开始方法
function AbandonStatusMachine:StartHandle()  
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function AbandonStatusMachine:OverHandle()
    local isFlush = self._game:CheckCardTable(self._game:NowOperationalUser())--判断当前是否有牌如奖励牌库
    if not isFlush then
        self._game:OperationalUserChange()
    end
    self:ChangeStatus(self.STATUS.ATTACK)--修改状态到攻击模式--进入攻击模式
end 

--结束一场游戏
function AbandonStatusMachine:CapHandle(player,index) 
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function AbandonStatusMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function AbandonStatusMachine:CardCheckHandle() 
    assert(nil,"状态不是理想状态")
end 
--洗手牌
function AbandonStatusMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function AbandonStatusMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return AbandonStatusMachine