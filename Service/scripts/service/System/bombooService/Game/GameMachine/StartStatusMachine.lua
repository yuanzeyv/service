local GameMachine = require("bombooService.Game.GameMachine.GameMachine")
local StartStatusMachine = class("StartStatusMachine",GameMachine)    
--进入时会调用的一个函数
function StartStatusMachine:EnterMachineHandle()
end 

--有一个开始方法
function StartStatusMachine:StartHandle() 
    self._game:InitCards()--首先初始化卡牌
    self._game:SetFirstPlayer() --设置第一个出牌人的信息
    self._game:DispatchHandCards() --发牌 
    self:ChangeStatus(self.STATUS.ATTACK)--修改状态到攻击模式
end 

--结束一场游戏
function StartStatusMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function StartStatusMachine:CapHandle(player,index)
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function StartStatusMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function StartStatusMachine:CardCheckHandle()
    assert(nil,"状态不是理想状态")
end 
--洗手牌
function StartStatusMachine:FlushHandCards()
    assert(nil,"状态不是理想状态")
end 
--洗底牌
function StartStatusMachine:FlushAwardCards()
    assert(nil,"状态不是理想状态")
end 
return StartStatusMachine