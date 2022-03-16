--游戏一上来的第一个状态
local NULLStatusMachine = class("GameMachine")  
function NULLStatusMachine:ctor(gameClass)
    self._gameClass = gameClass
end 

--进入时会调用的一个函数
function NULLStatusMachine:EnterMachineHandle()
end 

--有一个开始方法
function NULLStatusMachine:StartHandle() 
    self:ChangeStatus(GameMachine.StatusList.ATTACK)--修改状态到攻击模式
end 

--结束一场游戏
function NULLStatusMachine:OverHandle()
    assert(nil,"状态不是理想状态")
end 

--结束一场游戏
function NULLStatusMachine:CpaHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function NULLStatusMachine:CheckHandle()
    assert(nil,"状态不是理想状态")
end 

--校验当前游戏
function GameMachine:CardCheckHandle()
    assert(nil,"状态不是理想状态")
end 